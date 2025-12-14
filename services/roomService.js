const asyncHandler = require("express-async-handler");
const Room = require("../models/roomModel");
const RoomInvitation = require("../models/roomInvitationModel");
const User = require("../models/userModel");
const ApiError = require("../utils/apiError");
const { logActivity } = require("./activityLogService");

// Helper function to get permissions based on role
const getPermissionsFromRole = (role) => {
  const rolePermissions = {
    owner: ["view", "edit", "delete", "share"],
    editor: ["view", "edit"],
    viewer: ["view"],
    commenter: ["view", "comment"],
  };
  return rolePermissions[role] || [];
};

// Helper function to check if role has specific permission
const hasPermission = (role, permission) => {
  const permissions = getPermissionsFromRole(role);
  return permissions.includes(permission);
};

// Export helper functions for use in other modules
exports.getPermissionsFromRole = getPermissionsFromRole;
exports.hasPermission = hasPermission;

// Helper function to clean up old invitations
const cleanupOldInvitations = async () => {
  try {
    // Check if mongoose is connected
    const mongoose = require("mongoose");
    if (mongoose.connection.readyState !== 1) {
      console.log("Database not connected yet, skipping cleanup");
      return 0;
    }

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const result = await RoomInvitation.deleteMany(
      {
        status: { $in: ["accepted", "rejected", "cancelled"] },
        respondedAt: { $lt: thirtyDaysAgo },
      },
      {
        maxTimeMS: 5000, // Set timeout to 5 seconds
      }
    );

    return result.deletedCount;
  } catch (error) {
    console.error("Error in cleanupOldInvitations:", error.message);
    return 0; // Return 0 instead of throwing error
  }
};

// Export the cleanup function for direct use (without asyncHandler wrapper)
exports.cleanupOldInvitationsDirect = cleanupOldInvitations;

// @desc    View/Download room file (marks as accessed for one-time shares)
// @route   GET /api/rooms/:id/files/:fileId/view
// @access  Private
exports.viewRoomFile = asyncHandler(async (req, res, next) => {
  const { id: roomId, fileId } = req.params;
  const userId = req.user._id;
  const fs = require("fs");
  const path = require("path");

  // Find room with file populated
  const room = await Room.findById(roomId).populate("files.fileId");
  if (!room) {
    return next(new ApiError("Room not found", 404));
  }

  // Check if user is a member
  const isMember = room.members.some(
    (m) => m.user.toString() === userId.toString()
  );
  if (!isMember) {
    return next(new ApiError("You must be a room member to view files", 403));
  }

  // Find file entry
  const fileEntry = room.files.find(
    (f) =>
      f.fileId &&
      (f.fileId._id ? f.fileId._id.toString() : f.fileId.toString()) === fileId
  );
  if (!fileEntry) {
    return next(new ApiError("File not shared in this room", 404));
  }

  const file = fileEntry.fileId;
  if (!file) {
    return next(new ApiError("File not found", 404));
  }

  // Check if file exists on disk
  const filePath = file.path;
  if (!fs.existsSync(filePath)) {
    return next(new ApiError("File not found on server", 404));
  }

  // Check if user is file owner or the one who shared it
  const fileUserId =
    file.userId &&
    (file.userId._id ? file.userId._id.toString() : file.userId.toString());
  const sharedByUserId =
    fileEntry.sharedBy &&
    (fileEntry.sharedBy._id
      ? fileEntry.sharedBy._id.toString()
      : fileEntry.sharedBy.toString());

  const isFileOwner = fileUserId === userId.toString();
  const isSharedBy = sharedByUserId === userId.toString();

  // If it's a one-time share, check if user already accessed it
  // BUT: allow file owner and sharer to access unlimited times
  if (fileEntry.isOneTimeShare && !isFileOwner && !isSharedBy) {
    const userAccessed =
      fileEntry.accessedBy &&
      fileEntry.accessedBy.some((a) => {
        const accessUserId =
          (a.user &&
            (a.user._id ? a.user._id.toString() : a.user.toString())) ||
          a.user;
        return accessUserId === userId.toString();
      });

    if (userAccessed) {
      return next(
        new ApiError(
          "You have already viewed this file. One-time access only.",
          403
        )
      );
    }

    // Add user to accessedBy list (only for non-owners/non-sharers)
    if (!fileEntry.accessedBy) {
      fileEntry.accessedBy = [];
    }
    fileEntry.accessedBy.push({
      user: userId,
      accessedAt: new Date(),
    });

    // Check if all members have viewed the file
    // Count only non-owner/non-sharer members
    const membersToCount = room.members.filter((m) => {
      const memberId =
        (m.user && (m.user._id ? m.user._id.toString() : m.user.toString())) ||
        m.user;
      return memberId !== fileUserId && memberId !== sharedByUserId;
    });

    if (fileEntry.accessedBy.length >= membersToCount.length) {
      fileEntry.allMembersViewed = true;
      fileEntry.viewedByAllAt = new Date();

      // ✅ Remove file from room when all members have viewed it
      room.files = room.files.filter(
        (f) =>
          f.fileId &&
          (f.fileId._id ? f.fileId._id.toString() : f.fileId.toString()) !==
            fileId
      );

      // ✅ Log activity for file removal
      await logActivity(
        userId,
        "file_removed_after_all_viewed",
        "file",
        file._id,
        file.name,
        {
          roomId: room._id,
          roomName: room.name,
          reason: "All members viewed the one-time shared file",
        }
      );
    }

    await room.save();

    // Log activity
    await logActivity(
      userId,
      "file_viewed_onetime",
      "file",
      file._id,
      file.name,
      {
        roomId: room._id,
        roomName: room.name,
        isOneTimeShare: true,
      }
    );
  }

  // Send file
  res.download(filePath, file.name, (err) => {
    if (err) {
      console.error("Error sending file:", err);
      if (!res.headersSent) {
        return next(new ApiError("Error downloading file", 500));
      }
    }
  });
});

// @desc    Get all rooms for user
// @route   GET /api/rooms
// @access  Private
exports.getRooms = asyncHandler(async (req, res, next) => {
  const userId = req.user._id;

  // Find all rooms where user is a member
  const rooms = await Room.find({
    "members.user": userId,
  })
    .populate("owner", "name email")
    .populate("members.user", "name email")
    .select(
      "name description owner members files folders createdAt updatedAt isActive"
    )
    .lean();

  // Calculate files and folders count for each room
  const roomsWithCounts = rooms.map((room) => {
    const filesCount = room.files ? room.files.length : 0;
    const foldersCount = room.folders ? room.folders.length : 0;

    return {
      ...room,
      filesCount: filesCount,
      foldersCount: foldersCount,
    };
  });

  res.status(200).json({
    message: "Rooms retrieved successfully",
    rooms: roomsWithCounts,
  });
});

// @desc    Get room details
// @route   GET /api/rooms/:id
// @access  Private
exports.getRoomDetails = asyncHandler(async (req, res, next) => {
  const roomId = req.params.id;
  const userId = req.user._id;

  // First check if user is a member (without loading all data)
  const roomCheck = await Room.findById(roomId).select("members").lean();

  if (!roomCheck) {
    return next(new ApiError("Room not found", 404));
  }

  const isMember = roomCheck.members.some(
    (m) => m.user.toString() === userId.toString()
  );

  if (!isMember) {
    return next(
      new ApiError("Access denied. You are not a member of this room", 403)
    );
  }

  // Now load full room data with optimized populate
  // Also clean up one-time shared files that have been accessed
  const room = await Room.findById(roomId)
    .populate("owner", "name email")
    .populate("members.user", "name email")
    .populate({
      path: "files.fileId",
      select:
        "name type size category userId createdAt updatedAt isStarred path", // ✅ إضافة isStarred و path
      populate: {
        path: "userId",
        select: "name email",
      },
    })
    .populate({
      path: "folders.folderId",
      select: "name size userId createdAt updatedAt isStarred", // ✅ إضافة isStarred
    })
    .lean(); // Use lean() for better performance

  // No cleanup needed - files stay in room, just hidden from users who accessed them

  if (!room) {
    return next(new ApiError("Room not found", 404));
  }

  // Process files: filter one-time shared files that user already accessed
  const processedFiles = [];

  for (const fileEntry of room.files) {
    const file = fileEntry.fileId;

    // Skip if file is null or undefined
    if (!file) {
      continue;
    }

    // ✅ Log isStarred for debugging
    console.log(
      `📊 [getRoomDetails] Processing file ${file._id}: isStarred = ${
        file.isStarred
      }, keys = ${Object.keys(file).join(", ")}`
    );

    // If it's a one-time share, check if user already accessed it
    if (fileEntry.isOneTimeShare) {
      // Check if file has expired
      if (fileEntry.expiresAt && new Date() > new Date(fileEntry.expiresAt)) {
        continue; // Skip expired files
      }

      // ✅ Hide file if all members have viewed it (file should be removed)
      if (fileEntry.allMembersViewed) {
        continue; // Skip files that all members have viewed
      }

      // Check if current user has already accessed it
      const userAccessed =
        fileEntry.accessedBy &&
        fileEntry.accessedBy.some((access) => {
          const accessUser = access.user;
          const accessUserId =
            (accessUser &&
              (accessUser._id
                ? accessUser._id.toString()
                : accessUser.toString())) ||
            accessUser;
          return accessUserId === userId.toString();
        });

      // Hide file if user already accessed it (one-time access only)
      if (userAccessed) {
        continue; // Skip this file for this user
      }
    }

    // Show the file (either not one-time share, or one-time share not accessed yet)
    processedFiles.push(fileEntry);
  }

  // Update room files with processed list
  room.files = processedFiles;

  // ✅ Ensure isStarred is included in response (fallback to false if missing)
  // ✅ This ensures that isStarred is always present in the response
  if (room.files && room.files.length > 0) {
    console.log("📊 [getRoomDetails] Files count:", room.files.length);
    room.files.forEach((fileEntry, index) => {
      const file = fileEntry.fileId;
      if (file) {
        // ✅ Ensure isStarred is always present (default to false if missing)
        if (file.isStarred === undefined || file.isStarred === null) {
          file.isStarred = false;
        }
        console.log(
          `📊 [getRoomDetails] File ${index + 1} (${file._id}): isStarred = ${
            file.isStarred
          }`
        );
      }
    });
  }

  res.status(200).json({
    message: "Room details retrieved successfully",
    room: room,
  });
});

// @desc    Share file with room
// @route   POST /api/rooms/:id/share-file
// @access  Private
exports.shareFileWithRoom = asyncHandler(async (req, res, next) => {
  const roomId = req.params.id;

  // Check if user is authenticated
  if (!req.user || !req.user._id) {
    return next(new ApiError("Cannot identify user. Please re-login", 401));
  }

  const userId = req.user._id;
  const { fileId } = req.body;

  if (!fileId) {
    return next(new ApiError("File ID is required", 400));
  }

  const File = require("../models/fileModel");

  // Find room
  const room = await Room.findById(roomId);
  if (!room) {
    return next(new ApiError("Room not found", 404));
  }

  // Check if user is a member
  const isMember = room.members.find(
    (m) => m.user.toString() === userId.toString()
  );
  if (!isMember) {
    return next(new ApiError("You must be a room member to share files", 403));
  }

  // Find file
  const file = await File.findById(fileId);
  if (!file) {
    return next(new ApiError("File not found", 404));
  }

  // Check if file is already shared with this room
  const alreadyShared = room.files.find((f) => f.fileId.toString() === fileId);
  if (alreadyShared) {
    return next(new ApiError("File already shared with this room", 400));
  }

  // Add file to room
  room.files.push({ fileId, sharedBy: userId });
  await room.save();
  console.log("File shared with room:", room);
  res.status(200).json({
    message: "✅ File shared with room successfully",
    room: room,
  });
});

// @desc    Share file with room (one-time access)
// @route   POST /api/rooms/:id/share-file-onetime
// @access  Private
exports.shareFileWithRoomOneTime = asyncHandler(async (req, res, next) => {
  const roomId = req.params.id;

  // Check if user is authenticated
  if (!req.user || !req.user._id) {
    return next(new ApiError("Cannot identify user. Please re-login", 401));
  }

  const userId = req.user._id;
  const { fileId, expiresInHours } = req.body;

  console.log(
    "📤 [shareFileWithRoomOneTime] Starting - roomId:",
    roomId,
    "fileId:",
    fileId,
    "userId:",
    userId
  );

  if (!fileId) {
    console.log("❌ [shareFileWithRoomOneTime] File ID is required");
    return next(new ApiError("File ID is required", 400));
  }

  const File = require("../models/fileModel");
  const room = await Room.findById(roomId);
  if (!room) {
    console.log("❌ [shareFileWithRoomOneTime] Room not found");
    return next(new ApiError("Room not found", 404));
  }

  const isMember = room.members.some(
    (m) => m.user.toString() === userId.toString()
  );
  if (!isMember) {
    console.log("❌ [shareFileWithRoomOneTime] User is not a member");
    return next(new ApiError("You must be a room member to share files", 403));
  }

  const file = await File.findById(fileId);
  if (!file) {
    console.log("❌ [shareFileWithRoomOneTime] File not found");
    return next(new ApiError("File not found", 404));
  }

  const alreadyShared = room.files.some(
    (f) => f.fileId.toString() === fileId.toString()
  );
  if (alreadyShared) {
    console.log(
      "❌ [shareFileWithRoomOneTime] File already shared with this room"
    );
    return next(new ApiError("File already shared with this room", 400));
  }

  const hours = expiresInHours || 24;
  const expiresAt = new Date(Date.now() + hours * 60 * 60 * 1000);

  // Add file to room with one-time share flag
  room.files.push({
    fileId,
    sharedBy: userId,
    isOneTimeShare: true,
    expiresAt,
    accessedBy: [],
    allMembersViewed: false,
    visibleForOwner: true,
  });

  await room.save();

  // Log activity
  await logActivity(
    userId,
    "file_shared_onetime",
    "file",
    file._id,
    file.name,
    {
      roomId: room._id,
      roomName: room.name,
      expiresAt: expiresAt,
      expiresInHours: hours,
    }
  );

  // Reload the full room object with all necessary populations
  const updatedRoom = await Room.findById(roomId)
    .populate("owner", "name email")
    .populate("members.user", "name email")
    .populate({
      path: "files.fileId",
      select:
        "name type size category userId createdAt updatedAt isStarred path", // ✅ إضافة isStarred و path
      populate: {
        path: "userId",
        select: "name email",
      },
    })
    .populate({
      path: "folders.folderId",
      select: "name size userId createdAt updatedAt",
    })
    .lean();

  res.status(200).json({
    message: "✅ File shared with room (one-time access)",
    file: {
      _id: file._id,
      name: file.name,
    },
    expiresAt,
    room: updatedRoom,
  });
});

// @desc    Delete room
// @route   DELETE /api/rooms/:id
// @access  Private (owner only)
exports.deleteRoom = asyncHandler(async (req, res, next) => {
  const roomId = req.params.id;
  const userId = req.user._id;

  // Check if user is authenticated
  if (!req.user || !req.user._id) {
    return next(new ApiError("Cannot identify user. Please re-login", 401));
  }

  // Find room
  const room = await Room.findById(roomId);
  if (!room) {
    return next(new ApiError("Room not found", 404));
  }

  // Check if current user is the room owner
  if (room.owner.toString() !== userId.toString()) {
    return next(new ApiError("Only room owner can delete the room", 403));
  }

  // Get room with populated files and folders for logging
  const roomWithDetails = await Room.findById(roomId)
    .populate("files.fileId", "name userId")
    .populate("folders.folderId", "name userId");

  // Log activity for each file removed from room
  const File = require("../models/fileModel");
  if (
    roomWithDetails &&
    roomWithDetails.files &&
    roomWithDetails.files.length > 0
  ) {
    for (const fileEntry of roomWithDetails.files) {
      if (fileEntry.fileId) {
        await logActivity(
          userId,
          "file_removed_from_room_on_delete",
          "file",
          fileEntry.fileId._id || fileEntry.fileId,
          fileEntry.fileId.name || "Unknown",
          {
            roomId: roomId,
            roomName: room.name,
            reason: "Room deleted",
          }
        );
      }
    }
  }

  // Log activity for each folder removed from room
  const Folder = require("../models/folderModel");
  if (
    roomWithDetails &&
    roomWithDetails.folders &&
    roomWithDetails.folders.length > 0
  ) {
    for (const folderEntry of roomWithDetails.folders) {
      if (folderEntry.folderId) {
        await logActivity(
          userId,
          "folder_removed_from_room_on_delete",
          "folder",
          folderEntry.folderId._id || folderEntry.folderId,
          folderEntry.folderId.name || "Unknown",
          {
            roomId: roomId,
            roomName: room.name,
            reason: "Room deleted",
          }
        );
      }
    }
  }

  // Delete all invitations related to this room
  await RoomInvitation.deleteMany({ room: roomId });

  // Delete all comments related to this room
  const Comment = require("../models/commentModel");
  await Comment.deleteMany({ room: roomId });

  // Delete the room (this will automatically remove all files and folders from room.files and room.folders)
  await Room.findByIdAndDelete(roomId);

  // Log activity for room deletion
  const filesCount =
    (roomWithDetails &&
      roomWithDetails.files &&
      roomWithDetails.files.length) ||
    0;
  const foldersCount =
    (roomWithDetails &&
      roomWithDetails.folders &&
      roomWithDetails.folders.length) ||
    0;

  await logActivity(
    userId,
    "room_deleted",
    "room",
    roomId,
    room.name,
    {
      filesCount: filesCount,
      foldersCount: foldersCount,
      membersCount: room.members.length,
    },
    {
      ipAddress: req.ip,
      userAgent: req.get("User-Agent"),
    }
  );

  res.status(200).json({
    message: "✅ Room deleted successfully",
    details: {
      filesRemoved: filesCount,
      foldersRemoved: foldersCount,
      membersCount: room.members.length,
    },
  });
});

// @desc    Leave room (user removes themselves from room)
// @route   DELETE /api/rooms/:id/leave
// @access  Private
exports.leaveRoom = asyncHandler(async (req, res, next) => {
  const roomId = req.params.id;
  const userId = req.user._id;

  // Check if user is authenticated
  if (!req.user || !req.user._id) {
    return next(new ApiError("Cannot identify user. Please re-login", 401));
  }

  // Find room
  const room = await Room.findById(roomId);
  if (!room) {
    return next(new ApiError("Room not found", 404));
  }

  // Check if user is a member
  const member = room.members.find(
    (m) => m.user.toString() === userId.toString()
  );

  if (!member) {
    return next(new ApiError("You are not a member of this room", 403));
  }

  // If user is the room owner, delete the room instead of leaving
  if (room.owner.toString() === userId.toString()) {
    // Get room with populated files and folders for logging
    const roomWithDetails = await Room.findById(roomId)
      .populate("files.fileId", "name userId")
      .populate("folders.folderId", "name userId");

    // Log activity for each file removed from room
    const File = require("../models/fileModel");
    if (
      roomWithDetails &&
      roomWithDetails.files &&
      roomWithDetails.files.length > 0
    ) {
      for (const fileEntry of roomWithDetails.files) {
        if (fileEntry.fileId) {
          await logActivity(
            userId,
            "file_removed_from_room_on_delete",
            "file",
            fileEntry.fileId._id || fileEntry.fileId,
            fileEntry.fileId.name || "Unknown",
            {
              roomId: roomId,
              roomName: room.name,
              reason: "Room deleted by owner leaving",
            }
          );
        }
      }
    }

    // Log activity for each folder removed from room
    const Folder = require("../models/folderModel");
    if (
      roomWithDetails &&
      roomWithDetails.folders &&
      roomWithDetails.folders.length > 0
    ) {
      for (const folderEntry of roomWithDetails.folders) {
        if (folderEntry.folderId) {
          await logActivity(
            userId,
            "folder_removed_from_room_on_delete",
            "folder",
            folderEntry.folderId._id || folderEntry.folderId,
            folderEntry.folderId.name || "Unknown",
            {
              roomId: roomId,
              roomName: room.name,
              reason: "Room deleted by owner leaving",
            }
          );
        }
      }
    }

    // Delete all invitations related to this room
    await RoomInvitation.deleteMany({ room: roomId });

    // Delete all comments related to this room
    const Comment = require("../models/commentModel");
    await Comment.deleteMany({ room: roomId });

    // Delete the room
    await Room.findByIdAndDelete(roomId);

    // Log activity for room deletion
    const filesCount =
      (roomWithDetails &&
        roomWithDetails.files &&
        roomWithDetails.files.length) ||
      0;
    const foldersCount =
      (roomWithDetails &&
        roomWithDetails.folders &&
        roomWithDetails.folders.length) ||
      0;

    await logActivity(
      userId,
      "room_deleted",
      "room",
      roomId,
      room.name,
      {
        filesCount: filesCount,
        foldersCount: foldersCount,
        membersCount: room.members.length,
        reason: "Owner left the room",
      },
      {
        ipAddress: req.ip,
        userAgent: req.get("User-Agent"),
      }
    );

    return res.status(200).json({
      message: "✅ Room deleted successfully (owner left the room)",
      details: {
        filesRemoved: filesCount,
        foldersRemoved: foldersCount,
        membersCount: room.members.length,
      },
    });
  }

  // Regular member leaving - remove from members array
  room.members = room.members.filter(
    (m) => m.user.toString() !== userId.toString()
  );

  await room.save();

  // Log activity
  await logActivity(
    userId,
    "room_left",
    "room",
    roomId,
    room.name,
    {},
    {
      ipAddress: req.ip,
      userAgent: req.get("User-Agent"),
    }
  );

  res.status(200).json({
    message: "✅ You have left the room successfully",
    room: room,
  });
});
