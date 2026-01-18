// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(errorNames) =>
      "❌ All files were rejected after virus scanning: ${errorNames}";

  static String m1(version) => "App version ${version}";

  static String m2(title) => "Category Details: ${title}";

  static String m3(fileName) =>
      "Are you sure you want to delete \'${fileName}\'?";

  static String m4(folderName) =>
      "Are you sure you want to delete the folder \'${folderName}\'? All files and subfolders will also be deleted.";

  static String m5(fileName) =>
      "Are you sure you want to permanently delete the file \'${fileName}\'? This action cannot be undone.";

  static String m6(folderName) =>
      "Are you sure you want to permanently delete the folder \'${folderName}\'? This action cannot be undone. All sub-files and folders will be permanently deleted.";

  static String m7(folderName) =>
      "Are you sure you want to permanently delete the folder \'${folderName}\'? This action cannot be undone. All files and subfolders will be permanently deleted.";

  static String m8(folderName) =>
      "Are you sure you want to remove the folder \'${folderName}\' from the room?";

  static String m9(memberName) =>
      "Are you sure you want to remove ${memberName} from the room?";

  static String m10(fileName) => "🔐 Converting dangerous file: ${fileName}";

  static String m11(error) => "❌ ${error}";

  static String m12(name) => "📁 Folder \"${name}\" created successfully";

  static String m13(files) =>
      "Dangerous files detected:\n\n${files}\n\nThey will be converted to safe text files (.txt) to prevent execution.\n\nDo you want to proceed?";

  static String m14(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m15(folderName) =>
      "Are you sure you want to delete the folder \"${folderName}\"?\nAll contents will be permanently deleted.";

  static String m16(title) => "Delete Folder: ${title}";

  static String m17(roomName) =>
      "Are you sure you want to delete \"${roomName}\"? All shared files and folders will also be deleted.";

  static String m18(date) => "Deleted at: ${date}";

  static String m19(date) => "Deleted at: ${date}";

  static String m20(error) => "Error while downloading file: ${error}";

  static String m21(status) => "Download failed (Error ${status})";

  static String m22(email) => "Enter the 6-digit code sent to ${email}";

  static String m130(email) => "Enter your new password for ${email}";

  static String m23(error) => "Error: ${error}";

  static String m24(error) => "Error accessing edited file: ${error}";

  static String m25(error) => "Error deleting file: ${error}";

  static String m26(error) =>
      "❌ Error occurred while deleting folder: ${error}";

  static String m27(error) => "Error downloading file: ${error}";

  static String m28(error) => "❌ Error downloading folder: ${error}";

  static String m29(error) => "Error fetching subfolders: ${error}";

  static String m30(error) => "Error loading file: ${error}";

  static String m31(error) => "Error loading file data: ${error}";

  static String m32(error) => "Error loading file details: ${error}";

  static String m33(error) => "Error loading folder contents: ${error}";

  static String m34(error) => "Error loading image: ${error}";

  static String m35(error) => "Error loading text file: ${error}";

  static String m36(error) => "Error loading video: ${error}";

  static String m37(error) => "An error occurred";

  static String m38(error) => "Error opening file: ${error}";

  static String m39(error) =>
      "❌ Error occurred while permanently deleting folder: ${error}";

  static String m40(errorMessage) => "❌ Error: ${errorMessage}";

  static String m41(error) =>
      "❌ Error occurred while restoring folder: ${error}";

  static String m42(error) => "❌ Error uploading files: ${error}";

  static String m43(error) => "❌ Error uploading folder: ${error}";

  static String m44(error) => "❌ Error uploading profile image: ${error}";

  static String m45(error) => "Error verifying image: ${error}";

  static String m46(error) => "Error verifying video: ${error}";

  static String m47(hours) => "Expires in ${hours} hours";

  static String m48(statusCode) => "Failed to load audio file (${statusCode})";

  static String m49(error) => "Failed to load file status: ${error}";

  static String m50(error) => "Failed to load image: ${error}";

  static String m51(error) => "Failed to load PDF file: ${error}";

  static String m52(error) => "Failed to load PDF for display: ${error}";

  static String m53(statusCode) => "Failed to load video (${statusCode})";

  static String m54(error) => "Failed to open file";

  static String m55(message) => "Failed to update favorites: ${message}";

  static String m56(fileName) => "File \'${fileName}\' deleted successfully";

  static String m57(fileName) => "File \'${fileName}\' downloaded successfully";

  static String m58(id) => "File ID: ${id}";

  static String m59(error) => "File not available: ${error}";

  static String m60(path) => "File not found: ${path}";

  static String m61(errorMessage) => "Saved locally, ${errorMessage}";

  static String m62(code) => "File unavailable (Error ${code})";

  static String m63(code) => "File unavailable (Error: ${code})";

  static String m64(count) => "Files (${count})";

  static String m65(error) => "Fingerprint verification error: ${error}";

  static String m66(error) => "❌ Failed to create folder: ${error}";

  static String m67(folderName) =>
      "📁 Folder \"${folderName}\" created successfully";

  static String m68(folderName) => "Folder created successfully: ${folderName}";

  static String m69(folderName) =>
      "✅ Folder \'${folderName}\' deleted successfully";

  static String m70(fileName) =>
      "✅ Folder downloaded successfully: ${fileName}";

  static String m71(folderName) => "Folder \"${folderName}\" is protected";

  static String m72(folderName) => "Folder: ${folderName}";

  static String m73(folderName) =>
      "✅ Folder \'${folderName}\' permanently deleted successfully";

  static String m74(folderName) =>
      "✅ Folder \'${folderName}\' restored successfully";

  static String m75(count) => "Folders (${count})";

  static String m76(size) => "Font size: ${size}";

  static String m77(height) => "Height: ${height}";

  static String m78(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m79(roomName) =>
      "Are you sure you want to leave \"${roomName}\"? You will not be able to access this room after leaving.";

  static String m80(path) => "Local file not found: ${path}";

  static String m81(count) =>
      "${Intl.plural(count, zero: 'No members', one: '1 Member', other: '${count} Members')}";

  static String m82(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m83(title) => "Move File: ${title}";

  static String m84(fileName) => "Move file: ${fileName}";

  static String m85(folderName) => "Move folder: ${folderName}";

  static String m86(fileName) => "New file shared: ${fileName}";

  static String m87(folderName) => "New folder shared: ${folderName}";

  static String m88(fileName) => "Open file as text: ${fileName}";

  static String m89(error) => "Error opening file: ${error}";

  static String m90(pageNumber) => "Page: ${pageNumber}";

  static String m91(current, total) => "Page ${current} of ${total}";

  static String m92(page, error) =>
      "The PDF file may be corrupted or encrypted. Page ${page}: ${error}";

  static String m93(statusCode) => "Failed to load PDF file (${statusCode})";

  static String m94(seconds) =>
      "Please wait ${seconds} seconds before resending";

  static String m95(x) => "Position X: ${x}";

  static String m96(y) => "Position Y: ${y}";

  static String m97(quality) => "Quality changed to ${quality}";

  static String m98(text) => "Recognized text: ${text}";

  static String m99(fileName) =>
      "Are you sure you want to remove \"${fileName}\" from this room?";

  static String m100(seconds) => "Resend (${seconds})";

  static String m101(role) => "Role: ${role}";

  static String m102(folderName) =>
      "✅ Folder \"${folderName}\" has been saved to your account successfully";

  static String m103(error) => "Search error: ${error}";

  static String m104(count) =>
      "${Intl.plural(count, zero: 'No results found', one: 'Search results: 1 result', other: 'Search results: ${count} results')}";

  static String m105(folderName) => "Select \"${folderName}\"";

  static String m106(folderName) => "Select Folder";

  static String m131(folderName) => "Select \"${folderName}\"";

  static String m107(name) => "Select \"${name}\"";

  static String m108(count) => "Selected Users (${count})";

  static String m109(count) => "Shared Files (${count})";

  static String m110(count) =>
      "${Intl.plural(count, zero: 'Shared Folders', one: 'Shared Folder (1)', other: 'Shared Folders (${count})')}";

  static String m111(count) => "Shared with (${count})";

  static String m112(message) => "Speech recognition error: ${message}";

  static String m113(error) => "Speech recognition error: ${error}";

  static String m114(error) => "Error fetching subfolders: ${error}";

  static String m115(name) => "Subtitles enabled: ${name}";

  static String m116(duration) => "Total duration: ${duration}";

  static String m117(error) =>
      "An error occurred while moving the folder: ${error}";

  static String m118(error) => "Error uploading file: ${error}";

  static String m119(folderName, count) =>
      "✅ Folder \"${folderName}\" uploaded successfully! (${count} files)";

  static String m120(uploadedCount) =>
      "✅ ${uploadedCount} files uploaded successfully";

  static String m121(uploadedCount, errorsCount) =>
      "✅ ${uploadedCount} files uploaded, ${errorsCount} rejected after scanning";

  static String m122(folderName, count) =>
      "📁 Uploading folder \"${folderName}\" (${count} files)...";

  static String m123(url) => "URL: ${url}";

  static String m124(used, total) => "Used ${used} GB of ${total} GB";

  static String m125(email) => "Verification code sent to ${email}";

  static String m126(error) => "Failed to load video: ${error}";

  static String m127(errorNames) =>
      "❌ All files were rejected after virus scanning: ${errorNames}";

  static String m128(errorNames) =>
      "Some files were rejected after virus scanning: ${errorNames}";

  static String m129(width) => "Width: ${width}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "CreateFolder": MessageLookupByLibrary.simpleMessage("Create Folder"),
    "Registrationstopped": MessageLookupByLibrary.simpleMessage(
      "Registration stopped",
    ),
    "aacDescription": MessageLookupByLibrary.simpleMessage("Very good quality"),
    "aacFormat": MessageLookupByLibrary.simpleMessage("AAC"),
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "accessDenied": MessageLookupByLibrary.simpleMessage(
      "Access denied. Please check your permissions.",
    ),
    "accessDeniedOrFileAlreadyAccessed": MessageLookupByLibrary.simpleMessage(
      "Access denied or file already accessed",
    ),
    "accessTokenNotFound": MessageLookupByLibrary.simpleMessage(
      "Access token not found",
    ),
    "accessed": MessageLookupByLibrary.simpleMessage("Accessed"),
    "accountActivated": MessageLookupByLibrary.simpleMessage(
      "Account activated successfully",
    ),
    "accountActivatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Account activated successfully",
    ),
    "accountCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Account created successfully!",
    ),
    "account_deleted": MessageLookupByLibrary.simpleMessage("Account Deleted"),
    "actionLabel": MessageLookupByLibrary.simpleMessage("Action"),
    "active": MessageLookupByLibrary.simpleMessage("Active"),
    "activitiesWillShowHere": MessageLookupByLibrary.simpleMessage(
      "Your activities will be displayed here",
    ),
    "activityLog": MessageLookupByLibrary.simpleMessage("Activity Log"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addAtLeastOneUser": MessageLookupByLibrary.simpleMessage(
      "Please add at least one user",
    ),
    "addCommentFailure": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to add comment",
    ),
    "addCommentSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Comment added successfully",
    ),
    "addFile": MessageLookupByLibrary.simpleMessage("Add File"),
    "addFileToRoom": MessageLookupByLibrary.simpleMessage("Add File to Room"),
    "addFilesToFavorites": MessageLookupByLibrary.simpleMessage(
      "Add files to favorites",
    ),
    "addFolder": MessageLookupByLibrary.simpleMessage("Add Folder"),
    "addFolderToRoom": MessageLookupByLibrary.simpleMessage(
      "Add Folder to Room",
    ),
    "addTextAnnotation": MessageLookupByLibrary.simpleMessage(
      "Add Text (Annotation)",
    ),
    "addToFavorites": MessageLookupByLibrary.simpleMessage("Add to Favorites"),
    "addToFavoritesInstruction": MessageLookupByLibrary.simpleMessage(
      "You can add folders to favorites through the menu",
    ),
    "addUsers": MessageLookupByLibrary.simpleMessage("Add Users"),
    "addedToFavorites": MessageLookupByLibrary.simpleMessage(
      "Added to favorites",
    ),
    "additionalInfo": MessageLookupByLibrary.simpleMessage(
      "Additional Information",
    ),
    "additionalSettings": MessageLookupByLibrary.simpleMessage(
      "Additional Settings:",
    ),
    "adjustVolume": MessageLookupByLibrary.simpleMessage("Adjust Volume"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allActivities": MessageLookupByLibrary.simpleMessage("All Activities"),
    "allFilesRejectedVirus": m0,
    "allItems": MessageLookupByLibrary.simpleMessage("All Items"),
    "allowSharing": MessageLookupByLibrary.simpleMessage("Allow Sharing"),
    "allowSharingDescription": MessageLookupByLibrary.simpleMessage(
      "User can share files and folders in this room",
    ),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account? ",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("Flievo"),
    "appVersion": m1,
    "applications": MessageLookupByLibrary.simpleMessage("Applications"),
    "apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "audioDurationError": MessageLookupByLibrary.simpleMessage(
      "Failed to get audio duration",
    ),
    "audioLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to load audio file",
    ),
    "audioPauseError": MessageLookupByLibrary.simpleMessage(
      "Failed to pause audio file",
    ),
    "audioPlayError": MessageLookupByLibrary.simpleMessage(
      "Failed to play audio file",
    ),
    "audioSeekError": MessageLookupByLibrary.simpleMessage(
      "Failed to seek audio",
    ),
    "audioSpeedChangeError": MessageLookupByLibrary.simpleMessage(
      "Failed to change playback speed",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoDeleteNotice": MessageLookupByLibrary.simpleMessage(
      "Will be permanently deleted after 30 days",
    ),
    "autoDeleteNoticeFolders": MessageLookupByLibrary.simpleMessage(
      "Will be permanently deleted after 30 days",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("Back to Login"),
    "backToVerification": MessageLookupByLibrary.simpleMessage(
      "Back to Verification",
    ),
    "basicAppSettings": MessageLookupByLibrary.simpleMessage(
      "Basic app settings",
    ),
    "beTheFirstToComment": MessageLookupByLibrary.simpleMessage(
      "Be the first to comment",
    ),
    "biometric": MessageLookupByLibrary.simpleMessage("Biometric"),
    "buyStorage": MessageLookupByLibrary.simpleMessage("Buy More Storage"),
    "bytes": MessageLookupByLibrary.simpleMessage("Bytes"),
    "canViewPdfAndSearch": MessageLookupByLibrary.simpleMessage(
      "You can view PDF and search in it",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotAccessFile": MessageLookupByLibrary.simpleMessage(
      "Cannot access file",
    ),
    "cannotAddSharedFilesToFavorites": MessageLookupByLibrary.simpleMessage(
      "Cannot add shared files in room to favorites",
    ),
    "cannotDetermineFile": MessageLookupByLibrary.simpleMessage(
      "Cannot determine the file",
    ),
    "cannotIdentifyFile": MessageLookupByLibrary.simpleMessage(
      "Cannot identify file",
    ),
    "cannotIdentifyFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Error: Cannot identify folder",
    ),
    "cannotIdentifyUsers": MessageLookupByLibrary.simpleMessage(
      "Cannot identify users",
    ),
    "cannotModifyOwnerRole": MessageLookupByLibrary.simpleMessage(
      "❌ Cannot modify the owner\'s role",
    ),
    "cannotReadFiles": MessageLookupByLibrary.simpleMessage(
      "❌ Cannot read selected files",
    ),
    "cannotShareProtectedFolder": MessageLookupByLibrary.simpleMessage(
      "Cannot share protected folders",
    ),
    "catApplications": MessageLookupByLibrary.simpleMessage("Applications"),
    "catAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "catCode": MessageLookupByLibrary.simpleMessage("Code"),
    "catCompressed": MessageLookupByLibrary.simpleMessage("Compressed"),
    "catDocuments": MessageLookupByLibrary.simpleMessage("Documents"),
    "catImages": MessageLookupByLibrary.simpleMessage("Images"),
    "catOthers": MessageLookupByLibrary.simpleMessage("Others"),
    "catVideos": MessageLookupByLibrary.simpleMessage("Videos"),
    "category": MessageLookupByLibrary.simpleMessage("Category"),
    "categoryDetails": m2,
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "changesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to save changes",
    ),
    "changesSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Changes saved successfully",
    ),
    "checkInternet": MessageLookupByLibrary.simpleMessage(
      "Check your internet connection and URL",
    ),
    "chooseAction": MessageLookupByLibrary.simpleMessage("Choose Action"),
    "chooseFolderTitle": MessageLookupByLibrary.simpleMessage(
      "Choose a folder to save the file",
    ),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage(
      "Choose from Gallery",
    ),
    "chooseLanguage": MessageLookupByLibrary.simpleMessage("Choose Language"),
    "chooseOutputFormat": MessageLookupByLibrary.simpleMessage(
      "Choose output format:",
    ),
    "chooseRoomToShare": MessageLookupByLibrary.simpleMessage(
      "Choose a room to share this file",
    ),
    "chooseSubtitleLanguage": MessageLookupByLibrary.simpleMessage(
      "Choose subtitle language:",
    ),
    "chooseTimeInSeconds": MessageLookupByLibrary.simpleMessage(
      "Choose time in seconds:",
    ),
    "chooseTimeToExtractImage": MessageLookupByLibrary.simpleMessage(
      "Choose time to extract image",
    ),
    "chooseUploadMethod": MessageLookupByLibrary.simpleMessage(
      "Choose Upload Method",
    ),
    "clearDate": MessageLookupByLibrary.simpleMessage("Clear Date"),
    "clickToAddRoom": MessageLookupByLibrary.simpleMessage(
      "Click on + to create a new share room",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeSearch": MessageLookupByLibrary.simpleMessage("Close Search"),
    "code": MessageLookupByLibrary.simpleMessage("Code"),
    "codeResent": MessageLookupByLibrary.simpleMessage(
      "Code resent successfully",
    ),
    "codeSent": MessageLookupByLibrary.simpleMessage("Code sent successfully"),
    "codeVerified": MessageLookupByLibrary.simpleMessage(
      "Code verified successfully",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Color:"),
    "colorSettingsComingSoon": MessageLookupByLibrary.simpleMessage(
      "Color settings will be added soon",
    ),
    "commenter": MessageLookupByLibrary.simpleMessage("Commenter"),
    "commenterDescription": MessageLookupByLibrary.simpleMessage(
      "User can comment on files",
    ),
    "comments": MessageLookupByLibrary.simpleMessage("Comments"),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "compressed": MessageLookupByLibrary.simpleMessage("Compressed"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmDeleteComment": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this comment?",
    ),
    "confirmDeleteFile": m3,
    "confirmDeleteFolder": m4,
    "confirmDeleteMessage": m5,
    "confirmDeleteTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm Permanent Deletion",
    ),
    "confirmFolderDeleteMessage": m6,
    "confirmFolderDeleteTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm Permanent Deletion",
    ),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "confirmPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "confirmPermanentDelete": MessageLookupByLibrary.simpleMessage(
      "Confirm Permanent Delete",
    ),
    "confirmPermanentDeleteFolder": m7,
    "confirmRejectInvitation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reject this invitation?",
    ),
    "confirmRemoveFileFromRoom": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this file from the room?",
    ),
    "confirmRemoveFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this folder from the room?",
    ),
    "confirmRemoveFolderFromRoomWithName": m8,
    "confirmRemoveMember": m9,
    "connectionError": MessageLookupByLibrary.simpleMessage(
      "Connection error. Please check your internet.",
    ),
    "connectionReset": MessageLookupByLibrary.simpleMessage(
      "Connection reset by server. Please check your connection.",
    ),
    "continuee": MessageLookupByLibrary.simpleMessage("Continue"),
    "controlSubtitlesSettings": MessageLookupByLibrary.simpleMessage(
      "You can control subtitles and settings",
    ),
    "convertFormat": MessageLookupByLibrary.simpleMessage("Convert Format"),
    "convertingDangerousFile": m10,
    "copyContent": MessageLookupByLibrary.simpleMessage("Copy Content"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create account"),
    "createEmptyFolderSubtitle": MessageLookupByLibrary.simpleMessage(
      "Create an empty folder",
    ),
    "createFolder": MessageLookupByLibrary.simpleMessage("Create Folder"),
    "createFolderFailure": m11,
    "createFolderFailureDefault": MessageLookupByLibrary.simpleMessage(
      "Failed to create folder",
    ),
    "createFolderSuccess": m12,
    "createNewFolder": MessageLookupByLibrary.simpleMessage(
      "Create New Folder",
    ),
    "createNewPassword": MessageLookupByLibrary.simpleMessage(
      "Create new password",
    ),
    "createNewShareRoom": MessageLookupByLibrary.simpleMessage(
      "Create New Share Room",
    ),
    "createRoomFirst": MessageLookupByLibrary.simpleMessage(
      "Create a room first to share",
    ),
    "createRoomFirstToShare": MessageLookupByLibrary.simpleMessage(
      "Create a room first to start sharing",
    ),
    "createShareRoomTooltip": MessageLookupByLibrary.simpleMessage(
      "Create share room",
    ),
    "createdAt": MessageLookupByLibrary.simpleMessage("Created at"),
    "creationDate": MessageLookupByLibrary.simpleMessage("Creation date"),
    "currentPassword": MessageLookupByLibrary.simpleMessage("Current Password"),
    "currentPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "Current Password",
    ),
    "currentPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "Current password is required",
    ),
    "currentVersionSupports": MessageLookupByLibrary.simpleMessage(
      "Current version supports:",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "dangerousFilesDetected": m13,
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "dateLabel": MessageLookupByLibrary.simpleMessage("Date"),
    "days30": MessageLookupByLibrary.simpleMessage("Last 30 days"),
    "daysAgo": m14,
    "defaultFileName": MessageLookupByLibrary.simpleMessage("File"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteComment": MessageLookupByLibrary.simpleMessage("Delete Comment"),
    "deleteCommentFailure": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to delete comment",
    ),
    "deleteCommentSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Comment deleted successfully",
    ),
    "deleteConfirmMessage": m15,
    "deleteConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm Delete",
    ),
    "deleteFile": MessageLookupByLibrary.simpleMessage("Delete File"),
    "deleteFolder": MessageLookupByLibrary.simpleMessage("Delete Folder"),
    "deleteFolder1": m16,
    "deleteRoom": MessageLookupByLibrary.simpleMessage("Delete Room"),
    "deleteRoomConfirm": m17,
    "deletedAt": m18,
    "deletedAta": m19,
    "deletedFiles": MessageLookupByLibrary.simpleMessage("Deleted Files"),
    "deletedFolders": MessageLookupByLibrary.simpleMessage("Deleted Folders"),
    "deletedFoldersTitle": MessageLookupByLibrary.simpleMessage(
      "Deleted Folders",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "descriptionHint": MessageLookupByLibrary.simpleMessage(
      "Folder description (optional)",
    ),
    "descriptionLabel": MessageLookupByLibrary.simpleMessage("Description"),
    "descriptionOptional": MessageLookupByLibrary.simpleMessage(
      "Description (Optional)",
    ),
    "detailCategory": MessageLookupByLibrary.simpleMessage("Category"),
    "detailCreatedAt": MessageLookupByLibrary.simpleMessage("Created at"),
    "detailDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "detailEmpty": MessageLookupByLibrary.simpleMessage("—"),
    "detailFilesCount": MessageLookupByLibrary.simpleMessage("Files count"),
    "detailFolder": MessageLookupByLibrary.simpleMessage("Folder"),
    "detailSharedWith": MessageLookupByLibrary.simpleMessage("Shared with"),
    "detailSize": MessageLookupByLibrary.simpleMessage("Size"),
    "detailSubfoldersCount": MessageLookupByLibrary.simpleMessage(
      "Subfolders count",
    ),
    "detailTags": MessageLookupByLibrary.simpleMessage("Tags"),
    "detailTotalSize": MessageLookupByLibrary.simpleMessage("Total size"),
    "detailType": MessageLookupByLibrary.simpleMessage("Type"),
    "detailUpdatedAt": MessageLookupByLibrary.simpleMessage("Last modified"),
    "detailsTitle": MessageLookupByLibrary.simpleMessage("Details"),
    "didNotReceiveCode": MessageLookupByLibrary.simpleMessage(
      "Didn\'t receive the code?",
    ),
    "document": MessageLookupByLibrary.simpleMessage("Document"),
    "documents": MessageLookupByLibrary.simpleMessage("Documents"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "dontHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account? ",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadError": m20,
    "downloadFailedStatus": m21,
    "downloadFile": MessageLookupByLibrary.simpleMessage("Download File"),
    "downloadingFile": MessageLookupByLibrary.simpleMessage(
      "Downloading file...",
    ),
    "downloadingFolder": MessageLookupByLibrary.simpleMessage(
      "Downloading folder...",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editContentDescription": MessageLookupByLibrary.simpleMessage(
      "Editing the content of this type of file is not supported currently.\nYou can only edit the name, description, and tags.",
    ),
    "editContentTitle": MessageLookupByLibrary.simpleMessage("Edit Content"),
    "editEmail": MessageLookupByLibrary.simpleMessage("Edit Email"),
    "editFile": MessageLookupByLibrary.simpleMessage("Edit File"),
    "editFileMetadata": MessageLookupByLibrary.simpleMessage(
      "Edit File Metadata",
    ),
    "editFolder": MessageLookupByLibrary.simpleMessage("Edit Folder"),
    "editFolderTitle": MessageLookupByLibrary.simpleMessage("Edit Folder"),
    "editImage": MessageLookupByLibrary.simpleMessage("Edit Image"),
    "editMode": MessageLookupByLibrary.simpleMessage("Edit Mode"),
    "editRoom": MessageLookupByLibrary.simpleMessage("Edit Room"),
    "editText": MessageLookupByLibrary.simpleMessage("Edit Text"),
    "editUsername": MessageLookupByLibrary.simpleMessage("Edit Username"),
    "editedFileNotFound": MessageLookupByLibrary.simpleMessage(
      "Edited file not found. Please edit again",
    ),
    "editedImageIsEmpty": MessageLookupByLibrary.simpleMessage(
      "⚠️ Edited image is empty",
    ),
    "editedVideoIsEmpty": MessageLookupByLibrary.simpleMessage(
      "⚠️ Edited video is empty",
    ),
    "editor": MessageLookupByLibrary.simpleMessage("Editor"),
    "editorDescription": MessageLookupByLibrary.simpleMessage(
      "User can edit files",
    ),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailAddress": MessageLookupByLibrary.simpleMessage("Email Address*"),
    "emailChangedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Email changed successfully",
    ),
    "emailVerification": MessageLookupByLibrary.simpleMessage(
      "Email Verification",
    ),
    "emailVerifiedSuccess": MessageLookupByLibrary.simpleMessage(
      "Account verified successfully",
    ),
    "email_changed": MessageLookupByLibrary.simpleMessage("Email Changed"),
    "empty": MessageLookupByLibrary.simpleMessage("Empty"),
    "emptyFolderSubtitle": MessageLookupByLibrary.simpleMessage(
      "You can add new files or folders",
    ),
    "emptyFolderTitle": MessageLookupByLibrary.simpleMessage("Folder is empty"),
    "emptyTrash": MessageLookupByLibrary.simpleMessage("Empty Trash"),
    "emptyTrashMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to empty the trash? All files will be permanently deleted and cannot be restored.",
    ),
    "emptyTrashTitle": MessageLookupByLibrary.simpleMessage("Empty Trash"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enjoyWatchingVideo": MessageLookupByLibrary.simpleMessage(
      "Enjoy watching your video!",
    ),
    "enter6DigitCode": MessageLookupByLibrary.simpleMessage(
      "Please enter a 6-digit code",
    ),
    "enterCodeToEmail": m22,
    "enterConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "enterEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter your email",
    ),
    "enterEmailToInvite": MessageLookupByLibrary.simpleMessage(
      "Enter email address to send an invitation",
    ),
    "enterFolderName": MessageLookupByLibrary.simpleMessage(
      "Please enter folder name",
    ),
    "enterFolderNameError": MessageLookupByLibrary.simpleMessage(
      "Please enter a folder name",
    ),
    "enterHours": MessageLookupByLibrary.simpleMessage("Enter number of hours"),
    "enterNewPasswordFor": m130,
    "enterPassword": MessageLookupByLibrary.simpleMessage("Enter password"),
    "enterPasswordHint": MessageLookupByLibrary.simpleMessage(
      "Enter password (at least 4 characters)",
    ),
    "enterPasswordToLockFolder": MessageLookupByLibrary.simpleMessage(
      "Enter password to lock folder:",
    ),
    "enterPasswordToRemoveProtection": MessageLookupByLibrary.simpleMessage(
      "Enter password to remove protection",
    ),
    "enterPhone": MessageLookupByLibrary.simpleMessage(
      "Please enter your phone number",
    ),
    "enterSearchText": MessageLookupByLibrary.simpleMessage(
      "Enter search text",
    ),
    "enterUserIdToShare": MessageLookupByLibrary.simpleMessage(
      "Enter User ID to share",
    ),
    "enterUsername": MessageLookupByLibrary.simpleMessage(
      "Please enter your username",
    ),
    "enterUsernameOrEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter your username or email",
    ),
    "entityFile": MessageLookupByLibrary.simpleMessage("File"),
    "entityFolder": MessageLookupByLibrary.simpleMessage("Folder"),
    "entityRoom": MessageLookupByLibrary.simpleMessage("Room"),
    "entitySystem": MessageLookupByLibrary.simpleMessage("System"),
    "entityTypeLabel": MessageLookupByLibrary.simpleMessage("Item Type"),
    "entityUser": MessageLookupByLibrary.simpleMessage("User"),
    "error": m23,
    "errorAccessingEditedFile": m24,
    "errorAccessingFile": MessageLookupByLibrary.simpleMessage(
      "Error accessing file",
    ),
    "errorDeletingFile": m25,
    "errorDeletingFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Error occurred while deleting folder",
    ),
    "errorDeletingFolderWithError": m26,
    "errorDownloadingFile": m27,
    "errorDownloadingFile1": MessageLookupByLibrary.simpleMessage(
      "Error downloading file",
    ),
    "errorDownloadingFolder": m28,
    "errorFetchingData": MessageLookupByLibrary.simpleMessage(
      "Error fetching data",
    ),
    "errorFetchingSubfolders": m29,
    "errorLoadingFile": m30,
    "errorLoadingFileData": m31,
    "errorLoadingFileDetails": m32,
    "errorLoadingFolderContents": m33,
    "errorLoadingImage": m34,
    "errorLoadingRoomDetails": MessageLookupByLibrary.simpleMessage(
      "Error loading room details",
    ),
    "errorLoadingSubfolders": MessageLookupByLibrary.simpleMessage(
      "Error loading subfolders",
    ),
    "errorLoadingTextFile": m35,
    "errorLoadingVideoFolderContents": m36,
    "errorOccurred": m37,
    "errorOpeningFile": m38,
    "errorPermanentlyDeletingFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Error occurred while permanently deleting folder",
    ),
    "errorPermanentlyDeletingFolderWithError": m39,
    "errorPrefix": m40,
    "errorReadingFile": MessageLookupByLibrary.simpleMessage(
      "Error reading file",
    ),
    "errorRestoringFile": MessageLookupByLibrary.simpleMessage(
      "Failed to restore file",
    ),
    "errorRestoringFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Error occurred while restoring folder",
    ),
    "errorRestoringFolderWithError": m41,
    "errorUpdating": MessageLookupByLibrary.simpleMessage("Failed to update"),
    "errorUploadingFiles": m42,
    "errorUploadingFolder": m43,
    "errorUploadingProfileImage": m44,
    "errorVerifyingImage": m45,
    "errorVerifyingVideo": m46,
    "errorr": MessageLookupByLibrary.simpleMessage("Error"),
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expiresInHours": m47,
    "extension": MessageLookupByLibrary.simpleMessage("Extension"),
    "externalFilesWarning": MessageLookupByLibrary.simpleMessage(
      "⚠️ Files opened outside the app (Office, ZIP, etc.) cannot be shared as one-time access.",
    ),
    "extract": MessageLookupByLibrary.simpleMessage("Extract"),
    "extractText": MessageLookupByLibrary.simpleMessage("Extract Text"),
    "extractingImage": MessageLookupByLibrary.simpleMessage(
      "Extracting image...",
    ),
    "extractingText": MessageLookupByLibrary.simpleMessage(
      "Extracting text...",
    ),
    "extractingTextFromPdf": MessageLookupByLibrary.simpleMessage(
      "Extracting text from PDF...",
    ),
    "failedResendCode": MessageLookupByLibrary.simpleMessage(
      "Failed to resend code",
    ),
    "failedSendCode": MessageLookupByLibrary.simpleMessage(
      "Failed to send code",
    ),
    "failedToCreateFolder": MessageLookupByLibrary.simpleMessage(
      "Failed to create folder",
    ),
    "failedToCreateTempFile": MessageLookupByLibrary.simpleMessage(
      "Failed to create temporary file",
    ),
    "failedToDownloadFile": MessageLookupByLibrary.simpleMessage(
      "Failed to download file",
    ),
    "failedToDownloadFolder": MessageLookupByLibrary.simpleMessage(
      "Failed to download folder",
    ),
    "failedToEnableProtection": MessageLookupByLibrary.simpleMessage(
      "Failed to enable folder protection",
    ),
    "failedToExtractImage": MessageLookupByLibrary.simpleMessage(
      "Failed to extract image",
    ),
    "failedToExtractTextFromPdf": MessageLookupByLibrary.simpleMessage(
      "Failed to extract text from PDF",
    ),
    "failedToFetchFolderInfo": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch folder information",
    ),
    "failedToFetchFolderList": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch folder list",
    ),
    "failedToFetchFolders": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch folders list",
    ),
    "failedToLoad": MessageLookupByLibrary.simpleMessage("Failed to load:"),
    "failedToLoadAudio": m48,
    "failedToLoadAudioFile": MessageLookupByLibrary.simpleMessage(
      "Failed to load audio file",
    ),
    "failedToLoadBaseAudio": MessageLookupByLibrary.simpleMessage(
      "Failed to load base audio file",
    ),
    "failedToLoadFile": MessageLookupByLibrary.simpleMessage(
      "Failed to load file",
    ),
    "failedToLoadFileData": MessageLookupByLibrary.simpleMessage(
      "Failed to load file data",
    ),
    "failedToLoadFileStatus": m49,
    "failedToLoadImage": MessageLookupByLibrary.simpleMessage(
      "Failed to load image",
    ),
    "failedToLoadImage1": m50,
    "failedToLoadPdf": MessageLookupByLibrary.simpleMessage(
      "Failed to load PDF file",
    ),
    "failedToLoadPdfFile": m51,
    "failedToLoadPdfForDisplay": m52,
    "failedToLoadPreview": MessageLookupByLibrary.simpleMessage(
      "Failed to load preview",
    ),
    "failedToLoadRoomData": MessageLookupByLibrary.simpleMessage(
      "Failed to load room data",
    ),
    "failedToLoadRoomDetails": MessageLookupByLibrary.simpleMessage(
      "Failed to load room details",
    ),
    "failedToLoadVideo": m53,
    "failedToMergeVideos": MessageLookupByLibrary.simpleMessage(
      "Failed to merge videos",
    ),
    "failedToMoveFile": MessageLookupByLibrary.simpleMessage(
      "Failed to move file",
    ),
    "failedToMoveFolder": MessageLookupByLibrary.simpleMessage(
      "Failed to move folder - Feature under development",
    ),
    "failedToOpenFile": m54,
    "failedToRemoveFile": MessageLookupByLibrary.simpleMessage(
      "Failed to remove file from room",
    ),
    "failedToRemoveFileFromRoom": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to remove file from room",
    ),
    "failedToRemoveFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to remove folder from room",
    ),
    "failedToRemoveFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Failed to remove from favorites",
    ),
    "failedToRemoveProtection": MessageLookupByLibrary.simpleMessage(
      "Failed to remove folder protection",
    ),
    "failedToResendCode": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to resend verification code",
    ),
    "failedToSaveEditedImage": MessageLookupByLibrary.simpleMessage(
      "⚠️ Failed to save edited image",
    ),
    "failedToSaveEditedVideo": MessageLookupByLibrary.simpleMessage(
      "⚠️ Failed to save edited video",
    ),
    "failedToSaveFile": MessageLookupByLibrary.simpleMessage(
      "Failed to save file",
    ),
    "failedToSaveTempAudio": MessageLookupByLibrary.simpleMessage(
      "Failed to save temporary audio file",
    ),
    "failedToSaveTempImage": MessageLookupByLibrary.simpleMessage(
      "Failed to save temporary image",
    ),
    "failedToSaveTempVideo": MessageLookupByLibrary.simpleMessage(
      "Failed to save temporary video",
    ),
    "failedToShareFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to share folder",
    ),
    "failedToUpdate": MessageLookupByLibrary.simpleMessage("Failed to update "),
    "failedToUpdateFavorite": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to update favorite status",
    ),
    "failedToUpdatePassword": MessageLookupByLibrary.simpleMessage(
      "Failed to update password",
    ),
    "failedToUploadFile": MessageLookupByLibrary.simpleMessage(
      "Failed to upload file to server",
    ),
    "failedToUploadProfileImage": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to upload profile image",
    ),
    "failedToVerifyFingerprint": MessageLookupByLibrary.simpleMessage(
      "Failed to verify fingerprint",
    ),
    "favoriteAdded": MessageLookupByLibrary.simpleMessage(
      "Folder added to favorites",
    ),
    "favoriteFiles": MessageLookupByLibrary.simpleMessage("Favorite Files"),
    "favoriteRemoved": MessageLookupByLibrary.simpleMessage(
      "Folder removed from favorites",
    ),
    "favoriteUpdateFaile": MessageLookupByLibrary.simpleMessage(
      "Failed to update favorite status",
    ),
    "favoriteUpdateFailed": m55,
    "featureComingSoon": MessageLookupByLibrary.simpleMessage(
      "Delete feature will be added soon",
    ),
    "featureUnderDevelopment": MessageLookupByLibrary.simpleMessage(
      "This feature is under development",
    ),
    "fieldRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileAddedToFavorites": MessageLookupByLibrary.simpleMessage(
      "File added to favorites",
    ),
    "fileAlreadyAccessed": MessageLookupByLibrary.simpleMessage(
      "You have already accessed this file. One-time share only.",
    ),
    "fileAlreadyShared": MessageLookupByLibrary.simpleMessage(
      "ℹ️ File is already shared with this room",
    ),
    "fileDeletedPermanently": MessageLookupByLibrary.simpleMessage(
      "File permanently deleted",
    ),
    "fileDeletedSuccessfully": m56,
    "fileDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "fileDetails": MessageLookupByLibrary.simpleMessage("File Details"),
    "fileDownloadedSuccessfully": m57,
    "fileEmpty": MessageLookupByLibrary.simpleMessage("File is empty"),
    "fileExpired": MessageLookupByLibrary.simpleMessage("File has expired"),
    "fileIdLabel": m58,
    "fileIdNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File ID not available",
    ),
    "fileIdNotFound": MessageLookupByLibrary.simpleMessage("File ID not found"),
    "fileInfo": MessageLookupByLibrary.simpleMessage("File Information"),
    "fileInfoTitle": MessageLookupByLibrary.simpleMessage("File Information"),
    "fileInsecure": MessageLookupByLibrary.simpleMessage(
      "Warning: File may be insecure",
    ),
    "fileIsEmpty": MessageLookupByLibrary.simpleMessage("File is empty"),
    "fileLinkNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File link not available",
    ),
    "fileLinkNotAvailableNoPath": MessageLookupByLibrary.simpleMessage(
      "File link not available (no path)",
    ),
    "fileLinkUnavailable": MessageLookupByLibrary.simpleMessage(
      "File link is unavailable - Missing path or ID",
    ),
    "fileMovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "File moved successfully",
    ),
    "fileName": MessageLookupByLibrary.simpleMessage("File Name"),
    "fileNameLabel": MessageLookupByLibrary.simpleMessage("File Name"),
    "fileNotAvailableError": m59,
    "fileNotFound": MessageLookupByLibrary.simpleMessage("File not found"),
    "fileNotFoundInRoom": MessageLookupByLibrary.simpleMessage(
      "File not found in this room or inside a shared folder",
    ),
    "fileNotFoundOrExpired": MessageLookupByLibrary.simpleMessage(
      "File not found or has expired",
    ),
    "fileNotFoundd": m60,
    "fileNotLoaded": MessageLookupByLibrary.simpleMessage("File not loaded"),
    "fileNotValidPdf": MessageLookupByLibrary.simpleMessage(
      "File is not a valid PDF",
    ),
    "fileOrFolderId": MessageLookupByLibrary.simpleMessage("File/Folder ID"),
    "fileRemovedFromFavorites": MessageLookupByLibrary.simpleMessage(
      "File removed from favorites",
    ),
    "fileRemovedFromRoom": MessageLookupByLibrary.simpleMessage(
      "File removed from room successfully",
    ),
    "fileReplacedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ File replaced successfully",
    ),
    "fileRestoredSuccess": MessageLookupByLibrary.simpleMessage(
      "File restored successfully",
    ),
    "fileSavedAndUploaded": MessageLookupByLibrary.simpleMessage(
      "File saved and uploaded successfully",
    ),
    "fileSavedLocallyOnly": m61,
    "fileSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "File saved successfully",
    ),
    "fileSavedToAccount": MessageLookupByLibrary.simpleMessage(
      "File saved to your account",
    ),
    "fileSecure": MessageLookupByLibrary.simpleMessage("File is secure"),
    "fileShareFailed": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to share file ",
    ),
    "fileSharedSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ File shared with the room successfully",
    ),
    "fileSharedSuccessOneTime": MessageLookupByLibrary.simpleMessage(
      "✅ File shared with the room (One-time) successfully",
    ),
    "fileUnavailable": m62,
    "fileUnavailableWithCode": m63,
    "fileUpdateFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to upload updated file",
    ),
    "fileUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ File updated successfully",
    ),
    "fileUploadedButDeleteFailed": MessageLookupByLibrary.simpleMessage(
      "File uploaded but failed to delete old file:",
    ),
    "fileUrlNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File URL not available",
    ),
    "fileWithoutName": MessageLookupByLibrary.simpleMessage(
      "File without name",
    ),
    "file_accessed_onetime": MessageLookupByLibrary.simpleMessage(
      "One-time File Access",
    ),
    "file_deleted": MessageLookupByLibrary.simpleMessage("File Deleted"),
    "file_downloaded": MessageLookupByLibrary.simpleMessage("File Downloaded"),
    "file_moved": MessageLookupByLibrary.simpleMessage("File Moved"),
    "file_permanently_deleted": MessageLookupByLibrary.simpleMessage(
      "File Permanently Deleted",
    ),
    "file_restored": MessageLookupByLibrary.simpleMessage("File Restored"),
    "file_shared": MessageLookupByLibrary.simpleMessage("File Shared"),
    "file_starred": MessageLookupByLibrary.simpleMessage(
      "Added File to Favorites",
    ),
    "file_unshared": MessageLookupByLibrary.simpleMessage("File Unshared"),
    "file_unstarred": MessageLookupByLibrary.simpleMessage(
      "Removed File from Favorites",
    ),
    "file_updated": MessageLookupByLibrary.simpleMessage("File Updated"),
    "file_uploaded": MessageLookupByLibrary.simpleMessage("File Uploaded"),
    "file_viewed_by_all_members": MessageLookupByLibrary.simpleMessage(
      "File Viewed by All Members",
    ),
    "files": MessageLookupByLibrary.simpleMessage("Files"),
    "filesCount": MessageLookupByLibrary.simpleMessage("Files"),
    "filesWithCount": m64,
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "filterActivity": MessageLookupByLibrary.simpleMessage("Filter Activity"),
    "fingerprintNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Fingerprint not available on this device",
    ),
    "fingerprintVerificationError": m65,
    "firstPage": MessageLookupByLibrary.simpleMessage("First Page"),
    "folder": MessageLookupByLibrary.simpleMessage("Folder"),
    "folderAddedToFavorite": MessageLookupByLibrary.simpleMessage(
      "✅ Folder added to favorite successfully",
    ),
    "folderAddedToFavorites": MessageLookupByLibrary.simpleMessage(
      "✅ Folder added to favorites",
    ),
    "folderAlreadyShared": MessageLookupByLibrary.simpleMessage(
      "ℹ️ Folder is already shared with this room",
    ),
    "folderCreateFailed": m66,
    "folderCreatedSuccess": m67,
    "folderCreatedSuccessfully": m68,
    "folderDeletedSuccessfully": m69,
    "folderDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "folderDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Folder description (optional)",
    ),
    "folderDownloadedSuccessfully": m70,
    "folderIdNotAvailable": MessageLookupByLibrary.simpleMessage(
      "❌ Error: Folder ID not available.",
    ),
    "folderIdNotFound": MessageLookupByLibrary.simpleMessage(
      "Error: Folder ID not found",
    ),
    "folderInfo": MessageLookupByLibrary.simpleMessage("Folder Info"),
    "folderIsProtected": m71,
    "folderLabel": m72,
    "folderMoveFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to move folder",
    ),
    "folderMoveSuccess": MessageLookupByLibrary.simpleMessage(
      "Folder moved successfully",
    ),
    "folderMovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Folder moved successfully",
    ),
    "folderName": MessageLookupByLibrary.simpleMessage("Folder Name"),
    "folderNameHint": MessageLookupByLibrary.simpleMessage("Enter folder name"),
    "folderNameLabel": MessageLookupByLibrary.simpleMessage("Folder name"),
    "folderNameRequired": MessageLookupByLibrary.simpleMessage(
      "⚠️ Folder name is required",
    ),
    "folderPermanentDeleteError": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to permanently delete folder",
    ),
    "folderPermanentDeleteSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Folder deleted permanently",
    ),
    "folderPermanentlyDeletedSuccessfully": m73,
    "folderProtectedVerifyPassword": MessageLookupByLibrary.simpleMessage(
      "Folder is protected. Please verify password first",
    ),
    "folderProtection": MessageLookupByLibrary.simpleMessage(
      "Folder Protection",
    ),
    "folderProtectionDisabled": MessageLookupByLibrary.simpleMessage(
      "Folder protection disabled successfully",
    ),
    "folderProtectionEnabled": MessageLookupByLibrary.simpleMessage(
      "Folder protection enabled successfully",
    ),
    "folderRemovedFromFavorite": MessageLookupByLibrary.simpleMessage(
      "✅ Folder removed from favorite successfully",
    ),
    "folderRemovedFromFavorites": MessageLookupByLibrary.simpleMessage(
      "✅ Folder removed from favorites",
    ),
    "folderRemovedFromRoom": MessageLookupByLibrary.simpleMessage(
      "✅ Folder removed from room successfully",
    ),
    "folderRestoredError": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to restore folder",
    ),
    "folderRestoredSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Folder restored successfully",
    ),
    "folderRestoredSuccessfully": m74,
    "folderShareInstruction": MessageLookupByLibrary.simpleMessage(
      "💡 To share: Open the folder from the Folders page and select \"Share with Room\"",
    ),
    "folderSharedFailed": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to share the folder",
    ),
    "folderSharedSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Folder shared with the room successfully",
    ),
    "folderSharedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Folder shared successfully",
    ),
    "folderTags": MessageLookupByLibrary.simpleMessage("Tags"),
    "folderTagsHint": MessageLookupByLibrary.simpleMessage(
      "Tags separated by commas (optional)",
    ),
    "folderUpdateFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to update folder",
    ),
    "folderUpdateSuccess": MessageLookupByLibrary.simpleMessage(
      "Folder updated successfully",
    ),
    "folderUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Folder updated successfully",
    ),
    "folderUploadStart": MessageLookupByLibrary.simpleMessage(
      "📁 Pick the files you want to add to the folder...",
    ),
    "folderWithoutName": MessageLookupByLibrary.simpleMessage("Unnamed folder"),
    "folder_created": MessageLookupByLibrary.simpleMessage("Folder Created"),
    "folder_deleted": MessageLookupByLibrary.simpleMessage("Folder Deleted"),
    "folder_moved": MessageLookupByLibrary.simpleMessage("Folder Moved"),
    "folder_permanently_deleted": MessageLookupByLibrary.simpleMessage(
      "Folder Permanently Deleted",
    ),
    "folder_restored": MessageLookupByLibrary.simpleMessage("Folder Restored"),
    "folder_shared": MessageLookupByLibrary.simpleMessage("Folder Shared"),
    "folder_starred": MessageLookupByLibrary.simpleMessage(
      "Added Folder to Favorites",
    ),
    "folder_unshared": MessageLookupByLibrary.simpleMessage("Folder Unshared"),
    "folder_unstarred": MessageLookupByLibrary.simpleMessage(
      "Removed Folder from Favorites",
    ),
    "folder_updated": MessageLookupByLibrary.simpleMessage("Folder Updated"),
    "folder_uploaded": MessageLookupByLibrary.simpleMessage("Folder Uploaded"),
    "folders": MessageLookupByLibrary.simpleMessage("Folders"),
    "foldersCount": MessageLookupByLibrary.simpleMessage("Folders"),
    "foldersWithCount": m75,
    "fontSize": m76,
    "fontSizeSettingsComingSoon": MessageLookupByLibrary.simpleMessage(
      "Font size settings will be added soon",
    ),
    "forAdvancedSearchFeature": MessageLookupByLibrary.simpleMessage(
      "To benefit from advanced search feature, we recommend using:",
    ),
    "forSearch": MessageLookupByLibrary.simpleMessage("for search:"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot Password?"),
    "forgotPasswordFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to send verification code",
    ),
    "forgotPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
      "Enter your email address and we\'ll send you a code to reset your password.",
    ),
    "forgotPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Verification code sent to your email",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Forgot your password?",
    ),
    "foundText": MessageLookupByLibrary.simpleMessage("Found"),
    "freeInternal": MessageLookupByLibrary.simpleMessage("Free Internal"),
    "freeInternalValue": MessageLookupByLibrary.simpleMessage("120.5 GB"),
    "french": MessageLookupByLibrary.simpleMessage("French"),
    "from": MessageLookupByLibrary.simpleMessage("From"),
    "fullAccess": MessageLookupByLibrary.simpleMessage(
      "View, Edit, and Delete",
    ),
    "fullDateFormat": MessageLookupByLibrary.simpleMessage("MMM d, yyyy"),
    "fullScreenMode": MessageLookupByLibrary.simpleMessage("Full screen mode"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("General Settings"),
    "getHelpSupport": MessageLookupByLibrary.simpleMessage(
      "Get help and support",
    ),
    "height": m77,
    "helpSupport": MessageLookupByLibrary.simpleMessage("Help & Support"),
    "hideNavBar": MessageLookupByLibrary.simpleMessage("Hide navigation bar"),
    "highlight": MessageLookupByLibrary.simpleMessage("Highlight"),
    "highlightSelectedText": MessageLookupByLibrary.simpleMessage(
      "Highlight selected text",
    ),
    "highlightText": MessageLookupByLibrary.simpleMessage("Highlight Text"),
    "highlights": MessageLookupByLibrary.simpleMessage("Highlights"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "hoursAgo": m78,
    "image": MessageLookupByLibrary.simpleMessage("Image"),
    "imageAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Image added successfully",
    ),
    "imageEdited": MessageLookupByLibrary.simpleMessage("Image edited"),
    "imageEditedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Image edited successfully",
    ),
    "imageExtracted": MessageLookupByLibrary.simpleMessage("Image extracted"),
    "imageExtractedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Image extracted successfully",
    ),
    "images": MessageLookupByLibrary.simpleMessage("Images"),
    "incorrectPassword": MessageLookupByLibrary.simpleMessage(
      "Incorrect password",
    ),
    "increaseFontSize": MessageLookupByLibrary.simpleMessage(
      "Increase font size",
    ),
    "installAppPrompt": MessageLookupByLibrary.simpleMessage(
      "Failed to open file. Please install a suitable app (e.g., Microsoft Office or Google Slides)",
    ),
    "invalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Invalid credentials",
    ),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "invalidFileUrl": MessageLookupByLibrary.simpleMessage("Invalid file URL"),
    "invalidImageUrl": MessageLookupByLibrary.simpleMessage(
      "Invalid image URL",
    ),
    "invalidLink": MessageLookupByLibrary.simpleMessage("Invalid link"),
    "invalidOrExpiredCode": MessageLookupByLibrary.simpleMessage(
      "The code is invalid or has expired",
    ),
    "invalidPdfFile": MessageLookupByLibrary.simpleMessage(
      "The file is too small or corrupted",
    ),
    "invalidPhone": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid phone number (10-15 digits)",
    ),
    "invalidUrl": MessageLookupByLibrary.simpleMessage("Invalid URL"),
    "invalidVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Verification code is incorrect",
    ),
    "invitationAcceptFailed": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to accept invitation",
    ),
    "invitationAccepted": MessageLookupByLibrary.simpleMessage(
      "✅ Invitation accepted successfully",
    ),
    "invitationRejectFailed": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to decline invitation",
    ),
    "invitationRejected": MessageLookupByLibrary.simpleMessage(
      "✅ Invitation declined",
    ),
    "invitationSentFailure": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to send invitation",
    ),
    "invitationSentSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Invitation sent successfully",
    ),
    "invitationsHint": MessageLookupByLibrary.simpleMessage(
      "Invitations will appear here when received",
    ),
    "inviteNewUser": MessageLookupByLibrary.simpleMessage("Invite New User"),
    "invitedYouToJoin": MessageLookupByLibrary.simpleMessage(
      "invited you to join a room",
    ),
    "item": MessageLookupByLibrary.simpleMessage("item"),
    "items": MessageLookupByLibrary.simpleMessage("items"),
    "kb": MessageLookupByLibrary.simpleMessage("KB"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "last30Days": MessageLookupByLibrary.simpleMessage("Last 30 days"),
    "last7Days": MessageLookupByLibrary.simpleMessage("Last 7 days"),
    "lastModified": MessageLookupByLibrary.simpleMessage("Last modified"),
    "lastPage": MessageLookupByLibrary.simpleMessage("Last Page"),
    "lastYear": MessageLookupByLibrary.simpleMessage("Last year"),
    "leave": MessageLookupByLibrary.simpleMessage("Leave"),
    "leaveRoom": MessageLookupByLibrary.simpleMessage("Leave Room"),
    "leaveRoomConfirm": m79,
    "legalPolicies": MessageLookupByLibrary.simpleMessage("Legal & Policies"),
    "listening": MessageLookupByLibrary.simpleMessage("Listening..."),
    "loadMore": MessageLookupByLibrary.simpleMessage("Load More"),
    "loadedAudioIsEmpty": MessageLookupByLibrary.simpleMessage(
      "Loaded audio file is empty",
    ),
    "loadedImageIsEmpty": MessageLookupByLibrary.simpleMessage(
      "Loaded image is empty",
    ),
    "loadedVideoIsEmpty": MessageLookupByLibrary.simpleMessage(
      "Loaded video is empty",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "loadingAudio": MessageLookupByLibrary.simpleMessage(
      "Loading audio file...",
    ),
    "loadingContents": MessageLookupByLibrary.simpleMessage(
      "Loading contents...",
    ),
    "loadingFile": MessageLookupByLibrary.simpleMessage("Loading file..."),
    "loadingFileData": MessageLookupByLibrary.simpleMessage(
      "Loading file data...",
    ),
    "loadingFolders": MessageLookupByLibrary.simpleMessage(
      "Loading folders...",
    ),
    "loadingImage": MessageLookupByLibrary.simpleMessage("Loading image..."),
    "loadingVideo": MessageLookupByLibrary.simpleMessage("Loading video..."),
    "localFileNotFound": m80,
    "lockFolder": MessageLookupByLibrary.simpleMessage("Lock Folder"),
    "logIn": MessageLookupByLibrary.simpleMessage("Log In"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginFailed": MessageLookupByLibrary.simpleMessage("Login failed"),
    "loginFirst": MessageLookupByLibrary.simpleMessage("⚠️ Please login first"),
    "loginRequiredToAccessFiles": MessageLookupByLibrary.simpleMessage(
      "You must log in to access the files",
    ),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Login to your account",
    ),
    "loginSuccessful": MessageLookupByLibrary.simpleMessage(
      "Login successful!",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Logged out successfully",
    ),
    "manageNotifications": MessageLookupByLibrary.simpleMessage(
      "Manage notifications",
    ),
    "manageStorageSettings": MessageLookupByLibrary.simpleMessage(
      "Manage storage settings",
    ),
    "mb": MessageLookupByLibrary.simpleMessage("MB"),
    "member": MessageLookupByLibrary.simpleMessage("Member"),
    "members": MessageLookupByLibrary.simpleMessage("Members"),
    "membersCount": m81,
    "mergingAudioFiles": MessageLookupByLibrary.simpleMessage(
      "Merging audio files... This may take some time",
    ),
    "mergingVideos": MessageLookupByLibrary.simpleMessage(
      "Merging videos... This may take some time",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Add a welcome message...",
    ),
    "messageLabel": MessageLookupByLibrary.simpleMessage("Message (Optional)"),
    "micPermissionMessage": MessageLookupByLibrary.simpleMessage(
      "Microphone access is required for voice search.\n\nPlease open app settings and allow microphone access.",
    ),
    "micPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Microphone Permission Required",
    ),
    "microphonePermissionContent": MessageLookupByLibrary.simpleMessage(
      "You must allow microphone access to search by voice.\n\nPlease open app settings and grant microphone permission.",
    ),
    "microphonePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Microphone Permission Required",
    ),
    "minutesAgo": m82,
    "mobile": MessageLookupByLibrary.simpleMessage("Mobile"),
    "modified": MessageLookupByLibrary.simpleMessage("Modified"),
    "move": MessageLookupByLibrary.simpleMessage("Move"),
    "moveFile": m83,
    "moveFileTitle": m84,
    "moveFileToRoot": MessageLookupByLibrary.simpleMessage(
      "Move file to root (no folder)",
    ),
    "moveFolder": MessageLookupByLibrary.simpleMessage("Move Folder"),
    "moveFolderTitle": m85,
    "moveFolderToMainFolder": MessageLookupByLibrary.simpleMessage(
      "Move folder to main folder",
    ),
    "moveFolderToRoot": MessageLookupByLibrary.simpleMessage(
      "Move Folder to Root",
    ),
    "moveFolderToRootNoParent": MessageLookupByLibrary.simpleMessage(
      "Move folder to root (no parent folder)",
    ),
    "moveToRoot": MessageLookupByLibrary.simpleMessage("Move to root"),
    "moveToRootDescription": MessageLookupByLibrary.simpleMessage(
      "Move folder to main folder",
    ),
    "moveToRootSubtitle": MessageLookupByLibrary.simpleMessage(
      "Move folder to the main folder",
    ),
    "moveToThisFolder": MessageLookupByLibrary.simpleMessage(
      "Move to this folder",
    ),
    "movingFile": MessageLookupByLibrary.simpleMessage("Moving file..."),
    "movingFolder": MessageLookupByLibrary.simpleMessage("Moving folder..."),
    "movingToRoot": MessageLookupByLibrary.simpleMessage(
      "Moving folder to root...",
    ),
    "mp3Description": MessageLookupByLibrary.simpleMessage(
      "Good quality, small size",
    ),
    "mp3Format": MessageLookupByLibrary.simpleMessage("MP3"),
    "mustAllowCameraAccess": MessageLookupByLibrary.simpleMessage(
      "Must allow camera access",
    ),
    "mustAllowMicrophoneAccess": MessageLookupByLibrary.simpleMessage(
      "You must allow microphone access",
    ),
    "mustAllowPhotosAccess": MessageLookupByLibrary.simpleMessage(
      "Must allow photos access",
    ),
    "mustLogin": MessageLookupByLibrary.simpleMessage("You must log in first"),
    "mustLoginFirst": MessageLookupByLibrary.simpleMessage(
      "You must login first",
    ),
    "mustLoginFirstError": MessageLookupByLibrary.simpleMessage(
      "You must login first",
    ),
    "mustSelectAtLeastTwoAudioFiles": MessageLookupByLibrary.simpleMessage(
      "You must select at least two audio files to merge",
    ),
    "myFiles": MessageLookupByLibrary.simpleMessage("My Files"),
    "myFolders": MessageLookupByLibrary.simpleMessage("My Folders"),
    "needsEmailVerification": MessageLookupByLibrary.simpleMessage(
      "Account requires email verification",
    ),
    "newCopySavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ New copy saved successfully",
    ),
    "newFileShared": m86,
    "newFolderShared": m87,
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "newPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "New password is required",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "nextPage": MessageLookupByLibrary.simpleMessage("Next Page"),
    "noActivities": MessageLookupByLibrary.simpleMessage("No activities found"),
    "noAppFoundPrompt": MessageLookupByLibrary.simpleMessage(
      "No app installed to open this file. Choose an action:",
    ),
    "noCommentsYet": MessageLookupByLibrary.simpleMessage("No comments yet"),
    "noContent": MessageLookupByLibrary.simpleMessage("No content available"),
    "noDeletedFiles": MessageLookupByLibrary.simpleMessage(
      "No deleted files found",
    ),
    "noDeletedFolders": MessageLookupByLibrary.simpleMessage(
      "No deleted folders found",
    ),
    "noFavoriteFiles": MessageLookupByLibrary.simpleMessage(
      "No favorite files",
    ),
    "noFavoriteFolders": MessageLookupByLibrary.simpleMessage(
      "No favorite folders found",
    ),
    "noFiles": MessageLookupByLibrary.simpleMessage("No files"),
    "noFilesInCategory": MessageLookupByLibrary.simpleMessage(
      "No files in this category.",
    ),
    "noFoldersAvailable": MessageLookupByLibrary.simpleMessage(
      "No folders available. Please create one first.",
    ),
    "noItems": MessageLookupByLibrary.simpleMessage("No items"),
    "noMembers": MessageLookupByLibrary.simpleMessage("No members"),
    "noName": MessageLookupByLibrary.simpleMessage("No name"),
    "noPendingInvitations": MessageLookupByLibrary.simpleMessage(
      "No pending invitations",
    ),
    "noPermissionAddComment": MessageLookupByLibrary.simpleMessage(
      "❌ You don\'t have permission to add comments. Only Owner, Editor, and Commenter can add comments",
    ),
    "noPermissionToAccessFile": MessageLookupByLibrary.simpleMessage(
      "You do not have permission to access this file",
    ),
    "noPermissionToShareInRoom": MessageLookupByLibrary.simpleMessage(
      "⚠️ You do not have permission to share in this room",
    ),
    "noRecentFiles": MessageLookupByLibrary.simpleMessage("No recent files"),
    "noRecentFolders": MessageLookupByLibrary.simpleMessage(
      "No recent folders",
    ),
    "noResultsFor": MessageLookupByLibrary.simpleMessage("No results for:"),
    "noRoomsAvailable": MessageLookupByLibrary.simpleMessage(
      "No rooms available",
    ),
    "noRootFolders": MessageLookupByLibrary.simpleMessage("No folders in root"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No search results found",
    ),
    "noShareRooms": MessageLookupByLibrary.simpleMessage(
      "No share rooms found",
    ),
    "noSharedFiles": MessageLookupByLibrary.simpleMessage(
      "No shared files found",
    ),
    "noSharedFolders": MessageLookupByLibrary.simpleMessage(
      "No shared folders",
    ),
    "noStarredFolders": MessageLookupByLibrary.simpleMessage(
      "No starred folders found",
    ),
    "noSubfolders": MessageLookupByLibrary.simpleMessage("No subfolders"),
    "noSubfoldersAvailable": MessageLookupByLibrary.simpleMessage(
      "No subfolders available",
    ),
    "noSubtitles": MessageLookupByLibrary.simpleMessage("No Subtitles"),
    "noTokenError": MessageLookupByLibrary.simpleMessage("No token available"),
    "noUsersSharedWith": MessageLookupByLibrary.simpleMessage(
      "No users to unshare with",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "now": MessageLookupByLibrary.simpleMessage("Just now"),
    "numberOfFiles": MessageLookupByLibrary.simpleMessage("Number of files:"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "oneItem": MessageLookupByLibrary.simpleMessage("One item"),
    "oneMember": MessageLookupByLibrary.simpleMessage(" member"),
    "oneTime": MessageLookupByLibrary.simpleMessage("One time"),
    "oneTimeShare": MessageLookupByLibrary.simpleMessage("One-time Share"),
    "oneTimeShareAccessRecorded": MessageLookupByLibrary.simpleMessage(
      "This file is shared for one time - your access has been recorded",
    ),
    "oneTimeShareDescription": MessageLookupByLibrary.simpleMessage(
      "Each user can open the file only once",
    ),
    "oneTimeSharedFileError": MessageLookupByLibrary.simpleMessage(
      "❌ One-time shared files cannot view details, download, comment, or save",
    ),
    "onlyOwnerCanDelete": MessageLookupByLibrary.simpleMessage(
      "Only room owner can delete it",
    ),
    "onlyOwnerOrEditorCanEdit": MessageLookupByLibrary.simpleMessage(
      "❌ Only the room owner or editors can edit the room",
    ),
    "onlyRoomOwnerCanShare": MessageLookupByLibrary.simpleMessage(
      "⚠️ Only room owner can share",
    ),
    "open": MessageLookupByLibrary.simpleMessage("Open"),
    "openAsText": MessageLookupByLibrary.simpleMessage("Open as Text"),
    "openFile": MessageLookupByLibrary.simpleMessage("Open File"),
    "openFileAsText": m88,
    "openFileError": m89,
    "openFolder": MessageLookupByLibrary.simpleMessage("Open Folder"),
    "openImageEditor": MessageLookupByLibrary.simpleMessage(
      "Open Image Editor",
    ),
    "openSettings": MessageLookupByLibrary.simpleMessage("Open Settings"),
    "openTextEditor": MessageLookupByLibrary.simpleMessage("Open Text Editor"),
    "openWithApp": MessageLookupByLibrary.simpleMessage("Open with App"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "ownerCannotLeave": MessageLookupByLibrary.simpleMessage(
      "Room owner cannot leave. Please delete the room instead",
    ),
    "page": m90,
    "pageOf": m91,
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordAtLeast6Chars": MessageLookupByLibrary.simpleMessage(
      "Make sure your password is at least 6 characters long",
    ),
    "passwordConfirmationRequired": MessageLookupByLibrary.simpleMessage(
      "Password confirmation is required",
    ),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordMin": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwordMin4Chars": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 4 characters",
    ),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters",
    ),
    "passwordResetFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to reset password",
    ),
    "passwordResetSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Password reset successfully!",
    ),
    "passwordTooShort": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwordUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Password updated successfully",
    ),
    "password_changed": MessageLookupByLibrary.simpleMessage(
      "Password Changed",
    ),
    "password_reset_completed": MessageLookupByLibrary.simpleMessage(
      "Password Reset Completed",
    ),
    "password_reset_requested": MessageLookupByLibrary.simpleMessage(
      "Password Reset Requested",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "pausedStatus": MessageLookupByLibrary.simpleMessage("⏸️ Paused"),
    "pdf": MessageLookupByLibrary.simpleMessage("PDF"),
    "pdfCorruptedAtPage": m92,
    "pdfCorruptedOrEncrypted": MessageLookupByLibrary.simpleMessage(
      "The PDF file is corrupted or encrypted. Attempting another way...",
    ),
    "pdfLoadFailed": m93,
    "pdfTextExtractionNote": MessageLookupByLibrary.simpleMessage(
      "Note: Text extraction may not be available for all PDF files.",
    ),
    "pdfTextExtractionNote2": MessageLookupByLibrary.simpleMessage(
      "You can select and highlight text after extraction.",
    ),
    "pendingInvitations": MessageLookupByLibrary.simpleMessage(
      "Pending Invitations",
    ),
    "period": MessageLookupByLibrary.simpleMessage("Period"),
    "permanentDelete": MessageLookupByLibrary.simpleMessage(
      "Permanently Delete",
    ),
    "permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Permission denied. Microphone access is required for voice search.",
    ),
    "permissions": MessageLookupByLibrary.simpleMessage("Permissions"),
    "play": MessageLookupByLibrary.simpleMessage("Play"),
    "playbackSpeed": MessageLookupByLibrary.simpleMessage("Playback Speed"),
    "playbackSpeedLabel": MessageLookupByLibrary.simpleMessage(
      "Playback speed:",
    ),
    "playingStatus": MessageLookupByLibrary.simpleMessage("🎵 Playing..."),
    "pleaseEnter6DigitCode": MessageLookupByLibrary.simpleMessage(
      "Please enter the 6-digit verification code",
    ),
    "pleaseEnterComment": MessageLookupByLibrary.simpleMessage(
      "Please enter a comment",
    ),
    "pleaseEnterFolderName": MessageLookupByLibrary.simpleMessage(
      "Please enter folder name",
    ),
    "pleaseEnterPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter password",
    ),
    "pleaseEnterRoomName": MessageLookupByLibrary.simpleMessage(
      "⚠️ Please enter a room name",
    ),
    "pleaseEnterUserId": MessageLookupByLibrary.simpleMessage(
      "Please enter User ID",
    ),
    "pleaseFillAllFields": MessageLookupByLibrary.simpleMessage(
      "Please fill all fields",
    ),
    "pleaseLoginAgain": MessageLookupByLibrary.simpleMessage(
      "Please login again",
    ),
    "pleaseSelectFileOrFolder": MessageLookupByLibrary.simpleMessage(
      "Please select a file or folder",
    ),
    "pleaseVerifyFingerprint": MessageLookupByLibrary.simpleMessage(
      "Please verify fingerprint to access folder",
    ),
    "pleaseWaitBeforeResend": m94,
    "positionX": m95,
    "positionY": m96,
    "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
    "previous": MessageLookupByLibrary.simpleMessage("Previous"),
    "previousPage": MessageLookupByLibrary.simpleMessage("Previous Page"),
    "privacySecurity": MessageLookupByLibrary.simpleMessage(
      "Privacy & Security",
    ),
    "privacySettings": MessageLookupByLibrary.simpleMessage("Privacy settings"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileImageUploadedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Profile image uploaded successfully",
    ),
    "profile_updated": MessageLookupByLibrary.simpleMessage("Profile Updated"),
    "protectedFolder": MessageLookupByLibrary.simpleMessage("Protected Folder"),
    "purchaseComingSoon": MessageLookupByLibrary.simpleMessage(
      "Purchase flow coming soon!",
    ),
    "quality": MessageLookupByLibrary.simpleMessage("Quality"),
    "qualityChanged": m97,
    "rateLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Rate limit exceeded. Please try again later.",
    ),
    "readingFiles": MessageLookupByLibrary.simpleMessage("📁 Reading files..."),
    "recentFiles": MessageLookupByLibrary.simpleMessage("Recent Files"),
    "recentFolders": MessageLookupByLibrary.simpleMessage("Recent Folders"),
    "recognizedText": m98,
    "reenterPasswordHint": MessageLookupByLibrary.simpleMessage(
      "Re-enter password",
    ),
    "registrationFailed": MessageLookupByLibrary.simpleMessage(
      "Registration failed",
    ),
    "reject": MessageLookupByLibrary.simpleMessage("Reject"),
    "rejectInvitation": MessageLookupByLibrary.simpleMessage(
      "Reject Invitation",
    ),
    "reloadOriginalImage": MessageLookupByLibrary.simpleMessage(
      "Reload Original Image",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "removeAllHighlights": MessageLookupByLibrary.simpleMessage(
      "Remove all highlights",
    ),
    "removeFileFromRoom": MessageLookupByLibrary.simpleMessage(
      "Remove File from Room",
    ),
    "removeFileFromRoomConfirm": m99,
    "removeFilePermissionError": MessageLookupByLibrary.simpleMessage(
      "❌ Only the room owner or members with editor role can remove files",
    ),
    "removeFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "Remove Folder from Room",
    ),
    "removeFolderFromRoomFailure": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to remove folder from room",
    ),
    "removeFolderFromRoomSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Folder removed from room successfully",
    ),
    "removeFolderPermissionError": MessageLookupByLibrary.simpleMessage(
      "❌ Only the room owner or members with Editor role can remove folders",
    ),
    "removeFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Remove from Favorites",
    ),
    "removeFromRoom": MessageLookupByLibrary.simpleMessage("Remove from Room"),
    "removeMember": MessageLookupByLibrary.simpleMessage("Remove Member"),
    "removeMemberFailure": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to remove member",
    ),
    "removeMemberSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Member removed successfully",
    ),
    "removeProtectionQuestion": MessageLookupByLibrary.simpleMessage(
      "Do you want to remove protection from this folder?",
    ),
    "removedFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Removed from favorites",
    ),
    "removingFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Removing from favorites...",
    ),
    "replaceOldVersion": MessageLookupByLibrary.simpleMessage(
      "Replace old version",
    ),
    "resend": MessageLookupByLibrary.simpleMessage("Resend"),
    "resendCode": MessageLookupByLibrary.simpleMessage("Resend Code"),
    "resendWithCountdown": m100,
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetCodeInvalid": MessageLookupByLibrary.simpleMessage(
      "Code is invalid or expired",
    ),
    "resetCodeVerified": MessageLookupByLibrary.simpleMessage(
      "Code verified successfully",
    ),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "resetPasswordFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to reset password",
    ),
    "resetPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Password reset successfully",
    ),
    "resetPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Reset Password",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Restart from beginning"),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreFile": MessageLookupByLibrary.simpleMessage("Restore File"),
    "restoreFolder": MessageLookupByLibrary.simpleMessage("Restore Folder"),
    "resultWord": MessageLookupByLibrary.simpleMessage("result"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "role": MessageLookupByLibrary.simpleMessage("Role*"),
    "roleAdmin": MessageLookupByLibrary.simpleMessage("Admin"),
    "roleEditor": MessageLookupByLibrary.simpleMessage("Editor"),
    "roleLabel": m101,
    "roleViewer": MessageLookupByLibrary.simpleMessage("Viewer"),
    "room": MessageLookupByLibrary.simpleMessage("Room"),
    "roomCreatedError": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to create room",
    ),
    "roomCreatedSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Room created successfully",
    ),
    "roomCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Room created successfully",
    ),
    "roomDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Room deleted successfully",
    ),
    "roomDeletionFailed": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to delete room",
    ),
    "roomDescription": MessageLookupByLibrary.simpleMessage(
      "Room Description (Optional)",
    ),
    "roomDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Enter room description",
    ),
    "roomDetails": MessageLookupByLibrary.simpleMessage("Room Details"),
    "roomFolders": MessageLookupByLibrary.simpleMessage("Room Folders"),
    "roomInfo": MessageLookupByLibrary.simpleMessage("Room Info"),
    "roomLabel": MessageLookupByLibrary.simpleMessage("Room"),
    "roomLeaveFailed": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to leave room",
    ),
    "roomLeftSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Left room successfully",
    ),
    "roomMembers": MessageLookupByLibrary.simpleMessage("Room Members"),
    "roomName": MessageLookupByLibrary.simpleMessage("Room Name"),
    "roomNameEmptyError": MessageLookupByLibrary.simpleMessage(
      "⚠️ Room name cannot be empty",
    ),
    "roomNameHint": MessageLookupByLibrary.simpleMessage("Enter room name"),
    "roomNamePlaceholder": MessageLookupByLibrary.simpleMessage("No name"),
    "rooms": MessageLookupByLibrary.simpleMessage("Rooms"),
    "root": MessageLookupByLibrary.simpleMessage("Root"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "saveChangesFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to save changes",
    ),
    "saveFolderFailure": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to save folder",
    ),
    "saveFolderSuccess": m102,
    "saveNewCopy": MessageLookupByLibrary.simpleMessage("Save new copy"),
    "saveNewVersionFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to save the new version",
    ),
    "saveOptions": MessageLookupByLibrary.simpleMessage("Save Options"),
    "saveOptionsDescription": MessageLookupByLibrary.simpleMessage(
      "How do you want to save the edited image?\n\n• Save new copy: The edited image will be saved as a new file\n• Replace old version: The old file will be deleted and replaced with the edited image",
    ),
    "saveThisImage": MessageLookupByLibrary.simpleMessage(
      "Do you want to save this image?",
    ),
    "saveToMyAccount": MessageLookupByLibrary.simpleMessage(
      "Save to My Account",
    ),
    "saveToRoot": MessageLookupByLibrary.simpleMessage("Save to Root"),
    "savingFile": MessageLookupByLibrary.simpleMessage("Saving file..."),
    "savingFolder": MessageLookupByLibrary.simpleMessage("Saving folder..."),
    "scanningFile": MessageLookupByLibrary.simpleMessage(
      "Scanning file for security...",
    ),
    "scopeAll": MessageLookupByLibrary.simpleMessage("All"),
    "scopeMyFiles": MessageLookupByLibrary.simpleMessage("My Files"),
    "scopeRooms": MessageLookupByLibrary.simpleMessage("Rooms"),
    "scopeShared": MessageLookupByLibrary.simpleMessage("Shared"),
    "searchByTagsHint": MessageLookupByLibrary.simpleMessage(
      "Search by tag (e.g., project, important)",
    ),
    "searchError": m103,
    "searchExample": MessageLookupByLibrary.simpleMessage(
      "Example: \"Project files\"",
    ),
    "searchFailed": MessageLookupByLibrary.simpleMessage("Search failed"),
    "searchHelp": MessageLookupByLibrary.simpleMessage("Search Help"),
    "searchHint": MessageLookupByLibrary.simpleMessage(
      "Search... (e.g., photos from last week or #work)",
    ),
    "searchInDocument": MessageLookupByLibrary.simpleMessage(
      "Search in document",
    ),
    "searchInFiles": MessageLookupByLibrary.simpleMessage(
      "Search in your files",
    ),
    "searchInPdf": MessageLookupByLibrary.simpleMessage("Search in PDF"),
    "searchInPdfNotAvailableMessage": MessageLookupByLibrary.simpleMessage(
      "PDF search is not currently available. You can open the file in an external app to search.",
    ),
    "searchResults": m104,
    "searchSuggestions": MessageLookupByLibrary.simpleMessage(
      "Search Suggestions:",
    ),
    "searchYourFiles": MessageLookupByLibrary.simpleMessage(
      "Search in your files",
    ),
    "searching": MessageLookupByLibrary.simpleMessage("Searching..."),
    "second": MessageLookupByLibrary.simpleMessage("second"),
    "securityWarning": MessageLookupByLibrary.simpleMessage(
      "⚠️ Security Warning",
    ),
    "seeAll": MessageLookupByLibrary.simpleMessage("See all"),
    "selectCurrentFolder": m105,
    "selectCurrentFolderSubtitle": MessageLookupByLibrary.simpleMessage(
      "Move to this folder",
    ),
    "selectCustomDateRange": MessageLookupByLibrary.simpleMessage(
      "Select custom date range",
    ),
    "selectDestinationFolder": MessageLookupByLibrary.simpleMessage(
      "Select a folder to save to",
    ),
    "selectFileOrFolder": MessageLookupByLibrary.simpleMessage(
      "Select file or folder",
    ),
    "selectFolder": m106,
    "selectFolderDescription": MessageLookupByLibrary.simpleMessage(
      "Move to this folder",
    ),
    "selectFolderName": m131,
    "selectFolderNamed": m107,
    "selectFolderTooltip": MessageLookupByLibrary.simpleMessage(
      "Select this folder",
    ),
    "selectImagePosition": MessageLookupByLibrary.simpleMessage(
      "Select Image Position",
    ),
    "selectTargetFolder": MessageLookupByLibrary.simpleMessage(
      "Select Target Folder",
    ),
    "selectTargetToViewComments": MessageLookupByLibrary.simpleMessage(
      "Select a file or folder to view comments",
    ),
    "selectedUsersCount": m108,
    "sendCode": MessageLookupByLibrary.simpleMessage("Send Code"),
    "sendInvitation": MessageLookupByLibrary.simpleMessage("Send Invitation"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "shareFeatureComingSoon": MessageLookupByLibrary.simpleMessage(
      "Share feature coming soon",
    ),
    "shareFile": MessageLookupByLibrary.simpleMessage("Share File"),
    "shareFileWithRoom": MessageLookupByLibrary.simpleMessage(
      "Share File with Room",
    ),
    "shareFilesWithRoom": MessageLookupByLibrary.simpleMessage(
      "Share Files with Room",
    ),
    "shareFolder": MessageLookupByLibrary.simpleMessage("Share Folder "),
    "shareFolderWithRoom": MessageLookupByLibrary.simpleMessage(
      "Share Folder with Room",
    ),
    "shareFoldersWithRoom": MessageLookupByLibrary.simpleMessage(
      "Share Folders with Room",
    ),
    "shareInstruction": MessageLookupByLibrary.simpleMessage(
      "💡 To share: Open the file/folder from its page and select \"Share with Room\"",
    ),
    "shareRequestSent": MessageLookupByLibrary.simpleMessage(
      "Share request sent",
    ),
    "shareWithRoom": MessageLookupByLibrary.simpleMessage("Share with Room"),
    "shareWithThisRoom": MessageLookupByLibrary.simpleMessage(
      "Share with this room",
    ),
    "shared": MessageLookupByLibrary.simpleMessage("Shared"),
    "sharedBy": MessageLookupByLibrary.simpleMessage("Shared by"),
    "sharedFile": MessageLookupByLibrary.simpleMessage("Shared file"),
    "sharedFiles": MessageLookupByLibrary.simpleMessage("Shared Files"),
    "sharedFilesContent": MessageLookupByLibrary.simpleMessage(
      "Shared files content will be here",
    ),
    "sharedFilesCount": m109,
    "sharedFoldersTitle": m110,
    "sharedWith": MessageLookupByLibrary.simpleMessage("Shared with"),
    "sharedWithCount": m111,
    "sharedd": MessageLookupByLibrary.simpleMessage("Shared"),
    "sharepermission": MessageLookupByLibrary.simpleMessage("Share Permission"),
    "showNavBar": MessageLookupByLibrary.simpleMessage("Show navigation bar"),
    "showPdf": MessageLookupByLibrary.simpleMessage("Show PDF"),
    "showText": MessageLookupByLibrary.simpleMessage("Show Text"),
    "showingLast100Logs": MessageLookupByLibrary.simpleMessage(
      "Showing last 100 activity logs",
    ),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signInWith": MessageLookupByLibrary.simpleMessage("Sign in with"),
    "signOut": MessageLookupByLibrary.simpleMessage(
      "Sign out from your account",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
    "signUpWith": MessageLookupByLibrary.simpleMessage("Sign up with"),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "smartSearch": MessageLookupByLibrary.simpleMessage("Smart Search"),
    "socketError": MessageLookupByLibrary.simpleMessage(
      "Cannot connect to server. Please check your internet connection.",
    ),
    "someFilesRejectedVirus": MessageLookupByLibrary.simpleMessage(
      "Some files were rejected after virus scanning",
    ),
    "spanish": MessageLookupByLibrary.simpleMessage("Spanish"),
    "speechError": m112,
    "speechInitError": MessageLookupByLibrary.simpleMessage(
      "Could not initialize voice service",
    ),
    "speechInitializationError": MessageLookupByLibrary.simpleMessage(
      "Could not initialize voice service",
    ),
    "speechNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Speech recognition is not available on this device",
    ),
    "speechRecognitionError": m113,
    "speechRecognitionNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Speech recognition is not available on this device",
    ),
    "speechServiceUnavailable": MessageLookupByLibrary.simpleMessage(
      "Speech recognition service is unavailable",
    ),
    "starredFolders": MessageLookupByLibrary.simpleMessage("Starred Folders"),
    "startAddingFiles": MessageLookupByLibrary.simpleMessage(
      "Start adding new files",
    ),
    "startTimeMustBeBeforeEndTime": MessageLookupByLibrary.simpleMessage(
      "Start time must be before end time",
    ),
    "startTyping": MessageLookupByLibrary.simpleMessage("Start typing..."),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopListening": MessageLookupByLibrary.simpleMessage("Stop Listening"),
    "stoppedStatus": MessageLookupByLibrary.simpleMessage("⏹️ Stopped"),
    "storage": MessageLookupByLibrary.simpleMessage("Storage"),
    "storageAvailable": MessageLookupByLibrary.simpleMessage("Available"),
    "storageFull": MessageLookupByLibrary.simpleMessage(
      "Storage is full. Please upgrade your plan.",
    ),
    "storageOverview": MessageLookupByLibrary.simpleMessage("Storage Overview"),
    "storagePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "⚠️ Please grant storage permission from settings",
    ),
    "storageUsage": MessageLookupByLibrary.simpleMessage("Storage Usage"),
    "storageUsed": MessageLookupByLibrary.simpleMessage("Used"),
    "storageUsedValue": MessageLookupByLibrary.simpleMessage("60%"),
    "subfoldersCount": MessageLookupByLibrary.simpleMessage("Subfolders count"),
    "subfoldersFetchError": m114,
    "subtitleColor": MessageLookupByLibrary.simpleMessage("Subtitle color"),
    "subtitlesDisabled": MessageLookupByLibrary.simpleMessage(
      "Subtitles disabled",
    ),
    "subtitlesEnabled": m115,
    "subtitlesSettings": MessageLookupByLibrary.simpleMessage(
      "Subtitle Settings",
    ),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "switchThemes": MessageLookupByLibrary.simpleMessage(
      "Switch between themes",
    ),
    "switchToTagSearch": MessageLookupByLibrary.simpleMessage(
      "Switch to tag search",
    ),
    "switchToTextSearch": MessageLookupByLibrary.simpleMessage(
      "Switch to text search",
    ),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "tags": MessageLookupByLibrary.simpleMessage("Tags"),
    "tagsHint": MessageLookupByLibrary.simpleMessage(
      "Comma-separated tags (optional)",
    ),
    "tagsLabel": MessageLookupByLibrary.simpleMessage("Tags"),
    "tagsSeparatedByComma": MessageLookupByLibrary.simpleMessage(
      "Tags (separate by comma)",
    ),
    "takePhotoFromCamera": MessageLookupByLibrary.simpleMessage(
      "Take Photo from Camera",
    ),
    "termsPrivacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Terms of service & privacy policy",
    ),
    "textAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Text added successfully",
    ),
    "textEdited": MessageLookupByLibrary.simpleMessage("Text edited"),
    "textEditedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Text edited successfully. Press \"Save Changes\" to upload to server",
    ),
    "textHighlighted": MessageLookupByLibrary.simpleMessage(
      "Selected text highlighted",
    ),
    "textHighlightedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Text highlighted successfully",
    ),
    "textLabel": MessageLookupByLibrary.simpleMessage("Text"),
    "textNotExtractedYet": MessageLookupByLibrary.simpleMessage(
      "Text not extracted yet",
    ),
    "timeAndDate": MessageLookupByLibrary.simpleMessage("Time & Date"),
    "timeoutError": MessageLookupByLibrary.simpleMessage(
      "Upload timed out. The file might be too large.",
    ),
    "to": MessageLookupByLibrary.simpleMessage("To"),
    "tokenNotFound": MessageLookupByLibrary.simpleMessage(
      "❌ Error: Token not found",
    ),
    "tooltipGridView": MessageLookupByLibrary.simpleMessage("View as grid"),
    "tooltipListView": MessageLookupByLibrary.simpleMessage("View as list"),
    "totalActivity": MessageLookupByLibrary.simpleMessage("Total Activity"),
    "totalDuration": m116,
    "totalSize": MessageLookupByLibrary.simpleMessage("Total size"),
    "transferError": m117,
    "transferTimeout": MessageLookupByLibrary.simpleMessage(
      "Request timed out. The folder might be too large. Please try again.",
    ),
    "trash": MessageLookupByLibrary.simpleMessage("Trash"),
    "trashTitle": MessageLookupByLibrary.simpleMessage("Trash"),
    "trim": MessageLookupByLibrary.simpleMessage("Trim"),
    "trimAudio": MessageLookupByLibrary.simpleMessage("Trim Audio"),
    "tryDifferentKeywords": MessageLookupByLibrary.simpleMessage(
      "Try searching with different keywords",
    ),
    "type": MessageLookupByLibrary.simpleMessage("Type"),
    "typeLabel": MessageLookupByLibrary.simpleMessage("Type"),
    "unclassified": MessageLookupByLibrary.simpleMessage("Unclassified"),
    "unclassify": MessageLookupByLibrary.simpleMessage("Unclassify"),
    "unitBytes": MessageLookupByLibrary.simpleMessage("Bytes"),
    "unitGB": MessageLookupByLibrary.simpleMessage("GB"),
    "unitKB": MessageLookupByLibrary.simpleMessage("KB"),
    "unitMB": MessageLookupByLibrary.simpleMessage("MB"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownError": MessageLookupByLibrary.simpleMessage(
      "Unknown error occurred",
    ),
    "unknownFile": MessageLookupByLibrary.simpleMessage("Unknown File"),
    "unknownFolder": MessageLookupByLibrary.simpleMessage("Unknown Folder"),
    "unknownUser": MessageLookupByLibrary.simpleMessage("User"),
    "unknown_action": MessageLookupByLibrary.simpleMessage("Unknown Action"),
    "unlockFolder": MessageLookupByLibrary.simpleMessage(
      "Remove Folder Protection",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "unnamedFile": MessageLookupByLibrary.simpleMessage("Unnamed file"),
    "unnamedFolder": MessageLookupByLibrary.simpleMessage("Unnamed folder"),
    "unnamedfile": MessageLookupByLibrary.simpleMessage("Unnamed file"),
    "unsavedChanges": MessageLookupByLibrary.simpleMessage("Unsaved Changes"),
    "unsavedChangesLabel": MessageLookupByLibrary.simpleMessage(
      "Unsaved changes",
    ),
    "unsavedChangesMessage": MessageLookupByLibrary.simpleMessage(
      "You have unsaved changes. Are you sure you want to exit?",
    ),
    "unshare": MessageLookupByLibrary.simpleMessage("Unshare"),
    "unshareFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to unshare file",
    ),
    "unshareFile": MessageLookupByLibrary.simpleMessage("Unshare File"),
    "unshareFileConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove sharing?",
    ),
    "unshareFileSuccess": MessageLookupByLibrary.simpleMessage(
      "File unshared successfully",
    ),
    "unsupportedFile": MessageLookupByLibrary.simpleMessage("Unsupported File"),
    "update": MessageLookupByLibrary.simpleMessage("update"),
    "updateFileError": MessageLookupByLibrary.simpleMessage(
      "Failed to update file",
    ),
    "updateRole": MessageLookupByLibrary.simpleMessage("Update Role"),
    "updateRoleFailure": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to update role",
    ),
    "updateRoleSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Role updated successfully",
    ),
    "updateRoomFailure": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to update room",
    ),
    "updateRoomSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Room updated successfully",
    ),
    "updated": MessageLookupByLibrary.simpleMessage("Updated"),
    "updatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Updated successfully",
    ),
    "updating": MessageLookupByLibrary.simpleMessage("Updating..."),
    "uploadCancelled": MessageLookupByLibrary.simpleMessage("Upload cancelled"),
    "uploadCreateInRoot": MessageLookupByLibrary.simpleMessage(
      "Upload/create in root (no parent folder)",
    ),
    "uploadCreateInThisFolder": MessageLookupByLibrary.simpleMessage(
      "Upload/create in this folder",
    ),
    "uploadError": m118,
    "uploadFailed": MessageLookupByLibrary.simpleMessage("File upload failed"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Upload File"),
    "uploadFiles": MessageLookupByLibrary.simpleMessage("Upload Files"),
    "uploadFilesSubtitle": MessageLookupByLibrary.simpleMessage(
      "Select one or multiple files",
    ),
    "uploadFolder": MessageLookupByLibrary.simpleMessage("Upload Folder"),
    "uploadFolderFailed": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to upload folder",
    ),
    "uploadFolderSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose folder name then select files",
    ),
    "uploadFolderSuccess": m119,
    "uploadMultipleFiles": MessageLookupByLibrary.simpleMessage(
      "Upload Multiple Files",
    ),
    "uploadMultipleFilesSubtitle": MessageLookupByLibrary.simpleMessage(
      "Select multiple individual files",
    ),
    "uploadOptions": MessageLookupByLibrary.simpleMessage("Upload Options"),
    "uploadPhotoVideo": MessageLookupByLibrary.simpleMessage(
      "Upload Photo/Video",
    ),
    "uploadSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ Upload successful",
    ),
    "uploadSuccessCount": m120,
    "uploadSuccessWithErrors": m121,
    "uploadToRootHint": MessageLookupByLibrary.simpleMessage(
      "You can upload files/folders directly to the root using the option above",
    ),
    "upload_success": MessageLookupByLibrary.simpleMessage(
      "File uploaded successfully",
    ),
    "uploadingFolder": m122,
    "uploadingMultipleFiles": MessageLookupByLibrary.simpleMessage(
      "Uploading files...",
    ),
    "uploadingSingleFile": MessageLookupByLibrary.simpleMessage(
      "Uploading file...",
    ),
    "urlLabel": m123,
    "useFingerprintToAccess": MessageLookupByLibrary.simpleMessage(
      "Use fingerprint to access",
    ),
    "used": MessageLookupByLibrary.simpleMessage("Used"),
    "usedOfTotal": m124,
    "usedStorage": MessageLookupByLibrary.simpleMessage("Used storage:"),
    "usedStorageValue": MessageLookupByLibrary.simpleMessage("149.5 GB"),
    "userAlreadyInList": MessageLookupByLibrary.simpleMessage(
      "User is already in the list",
    ),
    "userLabel": MessageLookupByLibrary.simpleMessage("User"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameAllowedChars": MessageLookupByLibrary.simpleMessage(
      "Username can only contain letters, numbers and underscore",
    ),
    "usernameMax": MessageLookupByLibrary.simpleMessage(
      "Username cannot exceed 20 characters",
    ),
    "usernameMin": MessageLookupByLibrary.simpleMessage(
      "Username must be at least 3 characters",
    ),
    "usernameOrEmail": MessageLookupByLibrary.simpleMessage(
      "Username or Email",
    ),
    "validEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email",
    ),
    "validEmailRequired": MessageLookupByLibrary.simpleMessage(
      "Invalid email address",
    ),
    "verificationCodeIncorrect": MessageLookupByLibrary.simpleMessage(
      "Verification code is incorrect",
    ),
    "verificationCodeResendFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to resend verification code",
    ),
    "verificationCodeSendFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to send verification code",
    ),
    "verificationCodeSent": MessageLookupByLibrary.simpleMessage(
      "Verification code sent to your email",
    ),
    "verificationCodeSentTo": m125,
    "verificationSuccess": MessageLookupByLibrary.simpleMessage(
      "Code verified successfully",
    ),
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "verifyCodeTitle": MessageLookupByLibrary.simpleMessage("Verify Code"),
    "verifyWithFingerprint": MessageLookupByLibrary.simpleMessage(
      "Verify with Fingerprint",
    ),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoEditedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Video edited successfully",
    ),
    "videoLoadError": m126,
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to load video",
    ),
    "videoMergedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Videos merged successfully",
    ),
    "videoViewerTitle": MessageLookupByLibrary.simpleMessage("Video Viewer"),
    "videos": MessageLookupByLibrary.simpleMessage("Videos"),
    "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
    "viewAllActivities": MessageLookupByLibrary.simpleMessage(
      "View all your activities in the app",
    ),
    "viewAndEdit": MessageLookupByLibrary.simpleMessage("View and Edit"),
    "viewDeletedFilesAndFolders": MessageLookupByLibrary.simpleMessage(
      "View and manage deleted files and folders",
    ),
    "viewDetails": MessageLookupByLibrary.simpleMessage("View Details"),
    "viewImage": MessageLookupByLibrary.simpleMessage("View Image"),
    "viewInfo": MessageLookupByLibrary.simpleMessage("View Info"),
    "viewOnly": MessageLookupByLibrary.simpleMessage("View Only"),
    "viewOnlyDescription": MessageLookupByLibrary.simpleMessage(
      "User can only view files",
    ),
    "viewedByAll": MessageLookupByLibrary.simpleMessage("Viewed by all"),
    "virusScanRejectedAll": m127,
    "virusScanRejectedPartial": m128,
    "voiceSearch": MessageLookupByLibrary.simpleMessage("Voice Search"),
    "wavDescription": MessageLookupByLibrary.simpleMessage(
      "High quality, large size",
    ),
    "wavFormat": MessageLookupByLibrary.simpleMessage("WAV"),
    "welcomeVideoPlayer": MessageLookupByLibrary.simpleMessage(
      "Welcome to the Video Player",
    ),
    "width": m129,
    "willBeSavedInRoot": MessageLookupByLibrary.simpleMessage(
      "Folder will be saved in Main Directory",
    ),
    "writeComment": MessageLookupByLibrary.simpleMessage("Write a comment..."),
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "youAreOwner": MessageLookupByLibrary.simpleMessage("You are the owner"),
  };
}
