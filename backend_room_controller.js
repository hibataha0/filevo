const asyncHandler = require('express-async-handler');
const Room = require('./models/roomModel'); // تأكد من المسار الصحيح
const ApiError = require('./utils/apiError'); // تأكد من المسار الصحيح

// ✅ إزالة عضو من الغرفة
// يمكن لمالك الروم (room.owner) أو من له role 'owner' أو 'admin' في الـ members حذف الأعضاء
// - مالك الروم (من أنشأ الروم) يمكنه حذف أي عضو
// - من له role 'owner' يمكنه حذف الأعضاء (لكن لا يمكنه حذف عضو آخر له role 'owner')
// - من له role 'admin' يمكنه حذف الأعضاء (لكن لا يمكنه حذف عضو له role 'owner' أو مالك الروم)
exports.removeMember = asyncHandler(async (req, res, next) => {
  const roomId = req.params.id;
  const memberId = req.params.memberId;
  const userId = req.user._id;

  // Find room
  const room = await Room.findById(roomId);
  if (!room) {
    return next(new ApiError('Room not found', 404));
  }

  // Check if current user is the room owner (من أنشأ الروم)
  const isRoomOwner = room.owner.toString() === userId.toString();

  // Check if current user has 'owner' or 'admin' role in members
  const currentMember = room.members.find(
    m => m.user.toString() === userId.toString()
  );
  const hasOwnerRole = currentMember && currentMember.role === 'owner';
  const hasAdminRole = currentMember && currentMember.role === 'admin';

  // السماح لمالك الروم (من أنشأ الروم) أو من له role 'owner' أو 'admin' في الـ members بحذف الأعضاء
  if (!isRoomOwner && !hasOwnerRole && !hasAdminRole) {
    return next(new ApiError('Only room owner, member with owner role, or admin can remove members', 403));
  }

  // Find target member
  const member = room.members.id(memberId);
  if (!member) {
    return next(new ApiError('Member not found', 404));
  }

  // Cannot remove the room owner (من أنشأ الروم)
  const isTargetMemberRoomOwner = room.owner.toString() === member.user.toString();
  if (isTargetMemberRoomOwner) {
    return next(new ApiError('Cannot remove room owner', 400));
  }

  // Cannot remove member with 'owner' role unless you are the room owner
  // (من له role 'owner' لا يمكن حذفه إلا من قبل مالك الروم الأصلي)
  // هذا ينطبق على من له role 'owner' أو 'admin' - فقط مالك الروم يمكنه حذف عضو له role 'owner'
  if (member.role === 'owner' && !isRoomOwner) {
    return next(new ApiError('Only room owner can remove members with owner role', 403));
  }

  // Remove member from array
  // استخدام filter() لحذف العضو من المصفوفة
  room.members = room.members.filter(
    m => m._id.toString() !== memberId.toString()
  );
  
  // بديل آخر إذا لم يعمل filter() (استخدم أحد الطريقتين):
  // room.members.pull(memberId);
  
  await room.save();

  res.status(200).json({
    message: "✅ Member removed successfully",
    room: room
  });
});

// ✅ إزالة ملف من الغرفة
// يمكن لمالك الروم (room.owner) أو من شارك الملف (sharedBy) أو من له role 'owner' أو 'admin' في الـ members إزالة الملف
// - مالك الروم (من أنشأ الروم) يمكنه إزالة أي ملف
// - من شارك الملف (sharedBy) يمكنه إزالة الملف الذي شاركه
// - من له role 'owner' أو 'admin' يمكنه إزالة أي ملف
exports.removeFileFromRoom = asyncHandler(async (req, res, next) => {
  const roomId = req.params.id;
  const fileId = req.params.fileId;
  const userId = req.user._id;

  // Find room
  const room = await Room.findById(roomId);
  if (!room) {
    return next(new ApiError('Room not found', 404));
  }

  // Check if current user is the room owner (من أنشأ الروم)
  const isRoomOwner = room.owner.toString() === userId.toString();

  // Check if current user has 'owner' or 'admin' role in members
  const currentMember = room.members.find(
    m => m.user.toString() === userId.toString()
  );
  const hasOwnerRole = currentMember && currentMember.role === 'owner';
  const hasAdminRole = currentMember && currentMember.role === 'admin';

  // Find target file in room
  const fileIndex = room.files.findIndex(
    f => f.fileId.toString() === fileId.toString()
  );
  
  if (fileIndex === -1) {
    return next(new ApiError('File not found in room', 404));
  }

  const file = room.files[fileIndex];

  // Check if current user is the one who shared the file (sharedBy)
  const isFileSharer = file.sharedBy && file.sharedBy.toString() === userId.toString();

  // السماح لمالك الروم أو من شارك الملف أو من له role 'owner' أو 'admin' بإزالة الملف
  if (!isRoomOwner && !isFileSharer && !hasOwnerRole && !hasAdminRole) {
    return next(new ApiError('Only room owner, file sharer, member with owner role, or admin can remove files', 403));
  }

  // Remove file from array
  room.files = room.files.filter(
    f => f.fileId.toString() !== fileId.toString()
  );
  
  await room.save();

  res.status(200).json({
    message: "✅ File removed from room successfully",
    room: room
  });
});

// ✅ إزالة مجلد من الغرفة
// يمكن لمالك الروم (room.owner) أو من شارك المجلد (sharedBy) أو من له role 'owner' أو 'admin' في الـ members إزالة المجلد
// - مالك الروم (من أنشأ الروم) يمكنه إزالة أي مجلد
// - من شارك المجلد (sharedBy) يمكنه إزالة المجلد الذي شاركه
// - من له role 'owner' أو 'admin' يمكنه إزالة أي مجلد
exports.removeFolderFromRoom = asyncHandler(async (req, res, next) => {
  const roomId = req.params.id;
  const folderId = req.params.folderId;
  const userId = req.user._id;

  // Find room
  const room = await Room.findById(roomId);
  if (!room) {
    return next(new ApiError('Room not found', 404));
  }

  // Check if current user is the room owner (من أنشأ الروم)
  const isRoomOwner = room.owner.toString() === userId.toString();

  // Check if current user has 'owner' or 'admin' role in members
  const currentMember = room.members.find(
    m => m.user.toString() === userId.toString()
  );
  const hasOwnerRole = currentMember && currentMember.role === 'owner';
  const hasAdminRole = currentMember && currentMember.role === 'admin';

  // Find target folder in room
  const folderIndex = room.folders.findIndex(
    f => f.folderId.toString() === folderId.toString()
  );
  
  if (folderIndex === -1) {
    return next(new ApiError('Folder not found in room', 404));
  }

  const folder = room.folders[folderIndex];

  // Check if current user is the one who shared the folder (sharedBy)
  const isFolderSharer = folder.sharedBy && folder.sharedBy.toString() === userId.toString();

  // السماح لمالك الروم أو من شارك المجلد أو من له role 'owner' أو 'admin' بإزالة المجلد
  if (!isRoomOwner && !isFolderSharer && !hasOwnerRole && !hasAdminRole) {
    return next(new ApiError('Only room owner, folder sharer, member with owner role, or admin can remove folders', 403));
  }

  // Remove folder from array
  room.folders = room.folders.filter(
    f => f.folderId.toString() !== folderId.toString()
  );
  
  await room.save();

  res.status(200).json({
    message: "✅ Folder removed from room successfully",
    room: room
  });
});

