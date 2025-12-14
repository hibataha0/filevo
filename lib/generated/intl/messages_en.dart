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

  static String m0(version) => "App version ${version}";

  static String m1(fileName) =>
      "Are you sure you want to delete the file \'${fileName}\'?";

  static String m2(folderName) =>
      "Are you sure you want to delete the folder \'${folderName}\'? All files and subfolders will also be deleted.";

  static String m3(folderName) =>
      "Are you sure you want to permanently delete the folder \'${folderName}\'? This action cannot be undone. All files and subfolders will be permanently deleted.";

  static String m4(folderName) =>
      "Are you sure you want to remove the folder \'${folderName}\' from the room?";

  static String m5(memberName) =>
      "Are you sure you want to remove ${memberName} from the room?";

  static String m6(roomName) =>
      "Are you sure you want to delete \"${roomName}\"? All shared files and folders will also be deleted.";

  static String m7(email) => "Enter the 6-digit code sent to ${email}";

  static String m8(error) => "Error: ${error}";

  static String m9(error) => "Error accessing edited file: ${error}";

  static String m10(error) => "❌ Error deleting file: ${error}";

  static String m11(error) =>
      "❌ Error occurred while deleting folder: ${error}";

  static String m12(error) => "❌ Error downloading file: ${error}";

  static String m13(error) => "❌ Error downloading folder: ${error}";

  static String m14(error) => "Error fetching subfolders: ${error}";

  static String m15(error) => "Error loading file: ${error}";

  static String m16(error) => "Error loading file data: ${error}";

  static String m17(error) => "Error loading text file: ${error}";

  static String m18(error) => "❌ Error: ${error}";

  static String m19(error) => "Error opening file: ${error}";

  static String m20(error) =>
      "❌ Error occurred while permanently deleting folder: ${error}";

  static String m21(error) =>
      "❌ Error occurred while restoring folder: ${error}";

  static String m22(error) => "❌ Error uploading profile image: ${error}";

  static String m23(error) => "Error verifying image: ${error}";

  static String m24(error) => "Error verifying video: ${error}";

  static String m25(hours) => "Expires in ${hours} hours";

  static String m26(statusCode) => "Failed to load audio file (${statusCode})";

  static String m27(error) => "Failed to load file status: ${error}";

  static String m28(error) => "Failed to load PDF file: ${error}";

  static String m29(error) => "Failed to load PDF for display: ${error}";

  static String m30(statusCode) => "Failed to load video (${statusCode})";

  static String m31(error) => "Failed to open file: ${error}";

  static String m32(fileName) => "✅ File \'${fileName}\' deleted successfully";

  static String m33(fileName) => "✅ File downloaded successfully: ${fileName}";

  static String m34(error) => "File not available: ${error}";

  static String m35(folderName) => "Folder created successfully: ${folderName}";

  static String m36(folderName) =>
      "✅ Folder \'${folderName}\' deleted successfully";

  static String m37(fileName) =>
      "✅ Folder downloaded successfully: ${fileName}";

  static String m38(folderName) =>
      "✅ Folder \'${folderName}\' permanently deleted successfully";

  static String m39(folderName) =>
      "✅ Folder \'${folderName}\' restored successfully";

  static String m40(size) => "Font size: ${size}";

  static String m41(height) => "Height: ${height}";

  static String m42(roomName) =>
      "Are you sure you want to leave \"${roomName}\"? You will not be able to access this room after leaving.";

  static String m43(fileName) => "Open file as text: ${fileName}";

  static String m44(pageNumber) => "Page: ${pageNumber}";

  static String m45(statusCode) => "Failed to load PDF file (${statusCode})";

  static String m46(seconds) =>
      "Please wait ${seconds} seconds before resending";

  static String m47(x) => "Position X: ${x}";

  static String m48(y) => "Position Y: ${y}";

  static String m49(fileName) =>
      "Are you sure you want to remove \"${fileName}\" from this room?";

  static String m50(seconds) => "Resend (${seconds})";

  static String m51(roomName) => "${roomName}";

  static String m52(error) => "Search error: ${error}";

  static String m53(folderName) => "Select \"${folderName}\"";

  static String m54(count) => "Shared Files (${count})";

  static String m55(duration) => "Total duration: ${duration}";

  static String m56(email) => "Verification code sent to ${email}";

  static String m57(width) => "Width: ${width}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aacDescription": MessageLookupByLibrary.simpleMessage("Very good quality"),
    "aacFormat": MessageLookupByLibrary.simpleMessage("AAC"),
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "accessTokenNotFound": MessageLookupByLibrary.simpleMessage(
      "Access token not found",
    ),
    "accessed": MessageLookupByLibrary.simpleMessage("Accessed"),
    "accountActivatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Account activated successfully",
    ),
    "accountCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Account created successfully!",
    ),
    "active": MessageLookupByLibrary.simpleMessage("Active"),
    "activityLog": MessageLookupByLibrary.simpleMessage("Activity Log"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
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
    "adjustVolume": MessageLookupByLibrary.simpleMessage("Adjust Volume"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allActivities": MessageLookupByLibrary.simpleMessage("All Activities"),
    "allItems": MessageLookupByLibrary.simpleMessage("All Items"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account? ",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("Flievo"),
    "appVersion": m0,
    "applications": MessageLookupByLibrary.simpleMessage("Applications"),
    "apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("Back to Login"),
    "basicAppSettings": MessageLookupByLibrary.simpleMessage(
      "Basic app settings",
    ),
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
    "cannotIdentifyFile": MessageLookupByLibrary.simpleMessage(
      "Cannot identify file",
    ),
    "cannotIdentifyFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Error: Cannot identify folder",
    ),
    "cannotIdentifyUsers": MessageLookupByLibrary.simpleMessage(
      "Cannot identify users to unshare",
    ),
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "changesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to save changes",
    ),
    "changesSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Changes saved successfully",
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
    "chooseTimeInSeconds": MessageLookupByLibrary.simpleMessage(
      "Choose time in seconds:",
    ),
    "chooseTimeToExtractImage": MessageLookupByLibrary.simpleMessage(
      "Choose time to extract image",
    ),
    "code": MessageLookupByLibrary.simpleMessage("Code"),
    "codeResent": MessageLookupByLibrary.simpleMessage(
      "Code resent successfully",
    ),
    "codeSent": MessageLookupByLibrary.simpleMessage("Code sent successfully"),
    "codeVerified": MessageLookupByLibrary.simpleMessage(
      "Code verified successfully",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Color:"),
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
    "confirmDeleteFile": m1,
    "confirmDeleteFolder": m2,
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "confirmPermanentDelete": MessageLookupByLibrary.simpleMessage(
      "Confirm Permanent Delete",
    ),
    "confirmPermanentDeleteFolder": m3,
    "confirmRejectInvitation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reject this invitation?",
    ),
    "confirmRemoveFileFromRoom": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this file from the room?",
    ),
    "confirmRemoveFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this folder from the room?",
    ),
    "confirmRemoveFolderFromRoomWithName": m4,
    "confirmRemoveMember": m5,
    "convertFormat": MessageLookupByLibrary.simpleMessage("Convert Format"),
    "copyContent": MessageLookupByLibrary.simpleMessage("Copy Content"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create account"),
    "createFolder": MessageLookupByLibrary.simpleMessage("Create Folder"),
    "createNewFolder": MessageLookupByLibrary.simpleMessage(
      "Create New Folder",
    ),
    "createNewShareRoom": MessageLookupByLibrary.simpleMessage(
      "Create New Share Room",
    ),
    "createRoomFirst": MessageLookupByLibrary.simpleMessage(
      "Create a room first to share",
    ),
    "createdAt": MessageLookupByLibrary.simpleMessage("Created at"),
    "creationDate": MessageLookupByLibrary.simpleMessage("Creation Date"),
    "currentPassword": MessageLookupByLibrary.simpleMessage("Current Password"),
    "currentPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "Current password is required",
    ),
    "currentVersionSupports": MessageLookupByLibrary.simpleMessage(
      "Current version supports:",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteComment": MessageLookupByLibrary.simpleMessage("Delete Comment"),
    "deleteFile": MessageLookupByLibrary.simpleMessage("Delete File"),
    "deleteFolder": MessageLookupByLibrary.simpleMessage("Delete Folder"),
    "deleteRoom": MessageLookupByLibrary.simpleMessage("Delete Room"),
    "deleteRoomConfirm": m6,
    "deletedFiles": MessageLookupByLibrary.simpleMessage("Deleted Files"),
    "deletedFolders": MessageLookupByLibrary.simpleMessage("Deleted Folders"),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "didNotReceiveCode": MessageLookupByLibrary.simpleMessage(
      "Didn\'t receive the code?",
    ),
    "document": MessageLookupByLibrary.simpleMessage("Document"),
    "documents": MessageLookupByLibrary.simpleMessage("Documents"),
    "dontHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account? ",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadFile": MessageLookupByLibrary.simpleMessage("Download File"),
    "downloadingFile": MessageLookupByLibrary.simpleMessage(
      "Downloading file...",
    ),
    "downloadingFolder": MessageLookupByLibrary.simpleMessage(
      "Downloading folder...",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editEmail": MessageLookupByLibrary.simpleMessage("Edit Email"),
    "editFile": MessageLookupByLibrary.simpleMessage("Edit File"),
    "editFileMetadata": MessageLookupByLibrary.simpleMessage("Edit File"),
    "editImage": MessageLookupByLibrary.simpleMessage("Edit Image"),
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
    "emailVerification": MessageLookupByLibrary.simpleMessage(
      "Email Verification",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enter6DigitCode": MessageLookupByLibrary.simpleMessage(
      "Please enter a 6-digit code",
    ),
    "enterCodeToEmail": m7,
    "enterConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "enterEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter your email",
    ),
    "enterFolderName": MessageLookupByLibrary.simpleMessage(
      "Please enter folder name",
    ),
    "enterHours": MessageLookupByLibrary.simpleMessage("Enter number of hours"),
    "enterPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter your password",
    ),
    "enterPhone": MessageLookupByLibrary.simpleMessage(
      "Please enter your phone number",
    ),
    "enterSearchText": MessageLookupByLibrary.simpleMessage(
      "Enter search text",
    ),
    "enterUsername": MessageLookupByLibrary.simpleMessage(
      "Please enter your username",
    ),
    "enterUsernameOrEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter your username or email",
    ),
    "error": m8,
    "errorAccessingEditedFile": m9,
    "errorAccessingFile": MessageLookupByLibrary.simpleMessage(
      "Error accessing file",
    ),
    "errorDeletingFile": m10,
    "errorDeletingFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Error occurred while deleting folder",
    ),
    "errorDeletingFolderWithError": m11,
    "errorDownloadingFile": m12,
    "errorDownloadingFolder": m13,
    "errorFetchingData": MessageLookupByLibrary.simpleMessage(
      "Error fetching data",
    ),
    "errorFetchingSubfolders": m14,
    "errorLoadingFile": m15,
    "errorLoadingFileData": m16,
    "errorLoadingRoomDetails": MessageLookupByLibrary.simpleMessage(
      "Error loading room details",
    ),
    "errorLoadingSubfolders": MessageLookupByLibrary.simpleMessage(
      "Error loading subfolders",
    ),
    "errorLoadingTextFile": m17,
    "errorOccurred": m18,
    "errorOpeningFile": m19,
    "errorPermanentlyDeletingFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Error occurred while permanently deleting folder",
    ),
    "errorPermanentlyDeletingFolderWithError": m20,
    "errorRestoringFolder": MessageLookupByLibrary.simpleMessage(
      "❌ Error occurred while restoring folder",
    ),
    "errorRestoringFolderWithError": m21,
    "errorUpdating": MessageLookupByLibrary.simpleMessage("❌ Error updating"),
    "errorUploadingProfileImage": m22,
    "errorVerifyingImage": m23,
    "errorVerifyingVideo": m24,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expiresInHours": m25,
    "extension": MessageLookupByLibrary.simpleMessage("Extension"),
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
    "failedToExtractImage": MessageLookupByLibrary.simpleMessage(
      "Failed to extract image",
    ),
    "failedToExtractTextFromPdf": MessageLookupByLibrary.simpleMessage(
      "Failed to extract text from PDF",
    ),
    "failedToLoadAudio": m26,
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
    "failedToLoadFileStatus": m27,
    "failedToLoadImage": MessageLookupByLibrary.simpleMessage(
      "Failed to load image",
    ),
    "failedToLoadPdf": MessageLookupByLibrary.simpleMessage(
      "Failed to load PDF",
    ),
    "failedToLoadPdfFile": m28,
    "failedToLoadPdfForDisplay": m29,
    "failedToLoadPreview": MessageLookupByLibrary.simpleMessage(
      "Failed to load preview",
    ),
    "failedToLoadRoomData": MessageLookupByLibrary.simpleMessage(
      "Failed to load room data",
    ),
    "failedToLoadRoomDetails": MessageLookupByLibrary.simpleMessage(
      "Failed to load room details",
    ),
    "failedToLoadVideo": m30,
    "failedToMergeVideos": MessageLookupByLibrary.simpleMessage(
      "Failed to merge videos",
    ),
    "failedToMoveFile": MessageLookupByLibrary.simpleMessage(
      "Failed to move file",
    ),
    "failedToOpenFile": m31,
    "failedToRemoveFile": MessageLookupByLibrary.simpleMessage(
      "Failed to remove file from room",
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
    "failedToUploadProfileImage": MessageLookupByLibrary.simpleMessage(
      "❌ Failed to upload profile image",
    ),
    "favoriteFiles": MessageLookupByLibrary.simpleMessage("Favorite Files"),
    "featureUnderDevelopment": MessageLookupByLibrary.simpleMessage(
      "This feature is under development",
    ),
    "fieldRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileAddedToFavorites": MessageLookupByLibrary.simpleMessage(
      "✅ File added to favorites",
    ),
    "fileAlreadyAccessed": MessageLookupByLibrary.simpleMessage(
      "You have already accessed this file. One-time share only.",
    ),
    "fileAlreadyShared": MessageLookupByLibrary.simpleMessage(
      "This file is already shared with this room",
    ),
    "fileDeletedSuccessfully": m32,
    "fileDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "fileDownloadedSuccessfully": m33,
    "fileIdNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File ID not available",
    ),
    "fileIdNotFound": MessageLookupByLibrary.simpleMessage("File ID not found"),
    "fileInfo": MessageLookupByLibrary.simpleMessage("File Information"),
    "fileIsEmpty": MessageLookupByLibrary.simpleMessage("File is empty"),
    "fileLinkNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File link not available",
    ),
    "fileLinkNotAvailableNoPath": MessageLookupByLibrary.simpleMessage(
      "File link not available (no path)",
    ),
    "fileMovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "File moved successfully",
    ),
    "fileName": MessageLookupByLibrary.simpleMessage("File Name"),
    "fileNotAvailableError": m34,
    "fileNotLoaded": MessageLookupByLibrary.simpleMessage("File not loaded"),
    "fileNotValidPdf": MessageLookupByLibrary.simpleMessage(
      "File is not a valid PDF",
    ),
    "fileRemovedFromFavorites": MessageLookupByLibrary.simpleMessage(
      "✅ File removed from favorites",
    ),
    "fileRemovedFromRoom": MessageLookupByLibrary.simpleMessage(
      "File removed from room successfully",
    ),
    "fileReplacedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ File replaced successfully",
    ),
    "fileSavedAndUploaded": MessageLookupByLibrary.simpleMessage(
      "File saved and uploaded to server successfully",
    ),
    "fileSavedLocallyOnly": MessageLookupByLibrary.simpleMessage(
      "File saved locally only. Please try again to upload to server",
    ),
    "fileSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "File saved successfully",
    ),
    "fileUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ File updated successfully",
    ),
    "fileUrlNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File URL not available",
    ),
    "fileWithoutName": MessageLookupByLibrary.simpleMessage(
      "File without name",
    ),
    "files": MessageLookupByLibrary.simpleMessage("Files"),
    "filesCount": MessageLookupByLibrary.simpleMessage("Files Count"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "filterActivity": MessageLookupByLibrary.simpleMessage("Filter Activity"),
    "folder": MessageLookupByLibrary.simpleMessage("Folder"),
    "folderCreatedSuccessfully": m35,
    "folderDeletedSuccessfully": m36,
    "folderDownloadedSuccessfully": m37,
    "folderIdNotAvailable": MessageLookupByLibrary.simpleMessage(
      "❌ Error: Folder ID not available.",
    ),
    "folderIdNotFound": MessageLookupByLibrary.simpleMessage(
      "Error: Folder ID not found",
    ),
    "folderInfo": MessageLookupByLibrary.simpleMessage("Folder Info"),
    "folderNameHint": MessageLookupByLibrary.simpleMessage("Folder Name"),
    "folderPermanentlyDeletedSuccessfully": m38,
    "folderRestoredSuccessfully": m39,
    "folderWithoutName": MessageLookupByLibrary.simpleMessage(
      "Folder without name",
    ),
    "folders": MessageLookupByLibrary.simpleMessage("Folders"),
    "fontSize": m40,
    "forAdvancedSearchFeature": MessageLookupByLibrary.simpleMessage(
      "To benefit from advanced search feature, we recommend using:",
    ),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot Password?"),
    "forgotPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
      "Enter your email address and we\'ll send you a code to reset your password.",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Forgot your password?",
    ),
    "freeInternal": MessageLookupByLibrary.simpleMessage("Free Internal"),
    "freeInternalValue": MessageLookupByLibrary.simpleMessage("120.5 GB"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("General Settings"),
    "getHelpSupport": MessageLookupByLibrary.simpleMessage(
      "Get help and support",
    ),
    "height": m41,
    "helpSupport": MessageLookupByLibrary.simpleMessage("Help & Support"),
    "highlight": MessageLookupByLibrary.simpleMessage("Highlight"),
    "highlightSelectedText": MessageLookupByLibrary.simpleMessage(
      "Highlight selected text",
    ),
    "highlightText": MessageLookupByLibrary.simpleMessage("Highlight Text"),
    "highlights": MessageLookupByLibrary.simpleMessage("Highlights"),
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
    "invalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Invalid credentials",
    ),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "invalidOrExpiredCode": MessageLookupByLibrary.simpleMessage(
      "Invalid or expired code",
    ),
    "invalidPdfFile": MessageLookupByLibrary.simpleMessage(
      "This file is not a valid PDF or may be corrupted.",
    ),
    "invalidPhone": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid phone number (10-15 digits)",
    ),
    "invalidUrl": MessageLookupByLibrary.simpleMessage("Invalid URL"),
    "invalidVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Invalid verification code",
    ),
    "item": MessageLookupByLibrary.simpleMessage("item"),
    "items": MessageLookupByLibrary.simpleMessage("items"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "last30Days": MessageLookupByLibrary.simpleMessage("Last 30 days"),
    "last7Days": MessageLookupByLibrary.simpleMessage("Last 7 days"),
    "lastModified": MessageLookupByLibrary.simpleMessage("Last Modified"),
    "lastYear": MessageLookupByLibrary.simpleMessage("Last year"),
    "leave": MessageLookupByLibrary.simpleMessage("Leave"),
    "leaveRoom": MessageLookupByLibrary.simpleMessage("Leave Room"),
    "leaveRoomConfirm": m42,
    "legalPolicies": MessageLookupByLibrary.simpleMessage("Legal & Policies"),
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
    "loadingFile": MessageLookupByLibrary.simpleMessage("Loading file..."),
    "loadingFileData": MessageLookupByLibrary.simpleMessage(
      "Loading file data...",
    ),
    "loadingVideo": MessageLookupByLibrary.simpleMessage("Loading video..."),
    "logIn": MessageLookupByLibrary.simpleMessage("Log In"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
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
    "members": MessageLookupByLibrary.simpleMessage("Members"),
    "mergingAudioFiles": MessageLookupByLibrary.simpleMessage(
      "Merging audio files... This may take some time",
    ),
    "mergingVideos": MessageLookupByLibrary.simpleMessage(
      "Merging videos... This may take some time",
    ),
    "microphonePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Microphone permission required",
    ),
    "mobile": MessageLookupByLibrary.simpleMessage("Mobile"),
    "modified": MessageLookupByLibrary.simpleMessage("Modified"),
    "move": MessageLookupByLibrary.simpleMessage("Move"),
    "moveFolderToRoot": MessageLookupByLibrary.simpleMessage(
      "Move Folder to Root",
    ),
    "moveToRoot": MessageLookupByLibrary.simpleMessage("Move to Root"),
    "moveToRootDescription": MessageLookupByLibrary.simpleMessage(
      "Move folder to main folder",
    ),
    "moveToThisFolder": MessageLookupByLibrary.simpleMessage(
      "Move to this folder",
    ),
    "movingFile": MessageLookupByLibrary.simpleMessage("Moving file..."),
    "movingFolder": MessageLookupByLibrary.simpleMessage("Moving folder..."),
    "mp3Description": MessageLookupByLibrary.simpleMessage(
      "Good quality, small size",
    ),
    "mp3Format": MessageLookupByLibrary.simpleMessage("MP3"),
    "mustAllowCameraAccess": MessageLookupByLibrary.simpleMessage(
      "Must allow camera access",
    ),
    "mustAllowMicrophoneAccess": MessageLookupByLibrary.simpleMessage(
      "Must allow microphone access",
    ),
    "mustAllowPhotosAccess": MessageLookupByLibrary.simpleMessage(
      "Must allow photos access",
    ),
    "mustLogin": MessageLookupByLibrary.simpleMessage("You must log in first"),
    "mustLoginFirst": MessageLookupByLibrary.simpleMessage(
      "You must log in first",
    ),
    "mustLoginFirstError": MessageLookupByLibrary.simpleMessage(
      "Error: You must log in first",
    ),
    "mustSelectAtLeastTwoAudioFiles": MessageLookupByLibrary.simpleMessage(
      "You must select at least two audio files to merge",
    ),
    "myFiles": MessageLookupByLibrary.simpleMessage("My Files"),
    "myFolders": MessageLookupByLibrary.simpleMessage("My Folders"),
    "newCopySavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ New copy saved successfully",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "newPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "New password is required",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "noFavoriteFiles": MessageLookupByLibrary.simpleMessage(
      "No favorite files",
    ),
    "noFiles": MessageLookupByLibrary.simpleMessage("No files"),
    "noFilesInCategory": MessageLookupByLibrary.simpleMessage(
      "No files in this category.",
    ),
    "noFoldersAvailable": MessageLookupByLibrary.simpleMessage(
      "No folders available",
    ),
    "noItems": MessageLookupByLibrary.simpleMessage("No items"),
    "noMembers": MessageLookupByLibrary.simpleMessage("No members"),
    "noName": MessageLookupByLibrary.simpleMessage("No name"),
    "noRecentFiles": MessageLookupByLibrary.simpleMessage("No recent files"),
    "noRecentFolders": MessageLookupByLibrary.simpleMessage(
      "No recent folders",
    ),
    "noRoomsAvailable": MessageLookupByLibrary.simpleMessage(
      "No rooms available",
    ),
    "noSharedFiles": MessageLookupByLibrary.simpleMessage("No shared files"),
    "noSubfolders": MessageLookupByLibrary.simpleMessage("No subfolders"),
    "noTokenError": MessageLookupByLibrary.simpleMessage(
      "❌ Error: No token found.",
    ),
    "noUsersSharedWith": MessageLookupByLibrary.simpleMessage(
      "No users shared with this file",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "numberOfFiles": MessageLookupByLibrary.simpleMessage("Number of files:"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "oneItem": MessageLookupByLibrary.simpleMessage("One item"),
    "oneTimeShare": MessageLookupByLibrary.simpleMessage("One-time Share"),
    "oneTimeShareAccessRecorded": MessageLookupByLibrary.simpleMessage(
      "This file is shared for one time - your access has been recorded",
    ),
    "oneTimeShareDescription": MessageLookupByLibrary.simpleMessage(
      "Each user can open the file only once",
    ),
    "onlyOwnerCanDelete": MessageLookupByLibrary.simpleMessage(
      "Only room owner can delete it",
    ),
    "open": MessageLookupByLibrary.simpleMessage("Open"),
    "openAsText": MessageLookupByLibrary.simpleMessage("Open as Text"),
    "openFileAsText": m43,
    "openImageEditor": MessageLookupByLibrary.simpleMessage(
      "Open Image Editor",
    ),
    "openSettings": MessageLookupByLibrary.simpleMessage("Open Settings"),
    "openTextEditor": MessageLookupByLibrary.simpleMessage("Open Text Editor"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "ownerCannotLeave": MessageLookupByLibrary.simpleMessage(
      "Room owner cannot leave. Please delete the room instead",
    ),
    "page": m44,
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordConfirmationRequired": MessageLookupByLibrary.simpleMessage(
      "Password confirmation is required",
    ),
    "passwordMin": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters",
    ),
    "passwordUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Password updated successfully",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "pdfLoadFailed": m45,
    "pdfTextExtractionNote": MessageLookupByLibrary.simpleMessage(
      "Note: Text extraction may not be available for all PDF files.",
    ),
    "pdfTextExtractionNote2": MessageLookupByLibrary.simpleMessage(
      "You can select and highlight text after extraction.",
    ),
    "pendingInvitations": MessageLookupByLibrary.simpleMessage(
      "Pending Invitations",
    ),
    "permanentDelete": MessageLookupByLibrary.simpleMessage("Permanent Delete"),
    "permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Permission denied",
    ),
    "pleaseEnter6DigitCode": MessageLookupByLibrary.simpleMessage(
      "Please enter the 6-digit verification code",
    ),
    "pleaseEnterFolderName": MessageLookupByLibrary.simpleMessage(
      "Please enter folder name",
    ),
    "pleaseEnterRoomName": MessageLookupByLibrary.simpleMessage(
      "Please enter room name",
    ),
    "pleaseLoginAgain": MessageLookupByLibrary.simpleMessage(
      "Please login again",
    ),
    "pleaseSelectFileOrFolder": MessageLookupByLibrary.simpleMessage(
      "Please select a file or folder",
    ),
    "pleaseWaitBeforeResend": m46,
    "positionX": m47,
    "positionY": m48,
    "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
    "previous": MessageLookupByLibrary.simpleMessage("Previous"),
    "privacySecurity": MessageLookupByLibrary.simpleMessage(
      "Privacy & Security",
    ),
    "privacySettings": MessageLookupByLibrary.simpleMessage("Privacy settings"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileImageUploadedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Profile image uploaded successfully",
    ),
    "recentFiles": MessageLookupByLibrary.simpleMessage("Recent Files"),
    "recentFolders": MessageLookupByLibrary.simpleMessage("Recent Folders"),
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
    "removeFileFromRoomConfirm": m49,
    "removeFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "Remove Folder from Room",
    ),
    "removeFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Remove from Favorites",
    ),
    "removeFromRoom": MessageLookupByLibrary.simpleMessage("Remove from Room"),
    "removeMember": MessageLookupByLibrary.simpleMessage("Remove Member"),
    "replaceOldVersion": MessageLookupByLibrary.simpleMessage(
      "Replace old version",
    ),
    "resend": MessageLookupByLibrary.simpleMessage("Resend"),
    "resendCode": MessageLookupByLibrary.simpleMessage("Resend Code"),
    "resendWithCountdown": m50,
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "room": MessageLookupByLibrary.simpleMessage("Room"),
    "roomDetails": MessageLookupByLibrary.simpleMessage("Room Details"),
    "roomInfo": MessageLookupByLibrary.simpleMessage("Room Info"),
    "roomLabel": MessageLookupByLibrary.simpleMessage("Room"),
    "roomMembers": MessageLookupByLibrary.simpleMessage("Room Members"),
    "roomName": m51,
    "roomNamePlaceholder": MessageLookupByLibrary.simpleMessage("No name"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "saveNewCopy": MessageLookupByLibrary.simpleMessage("Save new copy"),
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
    "savingFolder": MessageLookupByLibrary.simpleMessage("Saving folder..."),
    "searchError": m52,
    "searchHint": MessageLookupByLibrary.simpleMessage("Search anything here"),
    "searchInPdf": MessageLookupByLibrary.simpleMessage("Search in PDF"),
    "searchInPdfNotAvailableMessage": MessageLookupByLibrary.simpleMessage(
      "PDF search is not currently available. You can open the file in an external app to search.",
    ),
    "seeAll": MessageLookupByLibrary.simpleMessage("See all"),
    "selectFolder": m53,
    "selectFolderDescription": MessageLookupByLibrary.simpleMessage(
      "Move to this folder",
    ),
    "selectImagePosition": MessageLookupByLibrary.simpleMessage(
      "Select Image Position",
    ),
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
    "shareFolderWithRoom": MessageLookupByLibrary.simpleMessage(
      "Share Folder with Room",
    ),
    "shareRequestSent": MessageLookupByLibrary.simpleMessage(
      "✅ Share request sent to room",
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
    "sharedFilesCount": m54,
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signInWith": MessageLookupByLibrary.simpleMessage("Sign in with"),
    "signOut": MessageLookupByLibrary.simpleMessage(
      "Sign out from your account",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
    "signUpWith": MessageLookupByLibrary.simpleMessage("Sign up with"),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "smartSearch": MessageLookupByLibrary.simpleMessage("Smart Search"),
    "speechRecognitionNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Speech recognition not available",
    ),
    "startAddingFiles": MessageLookupByLibrary.simpleMessage(
      "Start adding new files",
    ),
    "startTimeMustBeBeforeEndTime": MessageLookupByLibrary.simpleMessage(
      "Start time must be before end time",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "storage": MessageLookupByLibrary.simpleMessage("Storage"),
    "storageOverview": MessageLookupByLibrary.simpleMessage("Storage Overview"),
    "storageUsed": MessageLookupByLibrary.simpleMessage("Used"),
    "storageUsedValue": MessageLookupByLibrary.simpleMessage("60%"),
    "subfoldersCount": MessageLookupByLibrary.simpleMessage("Subfolders Count"),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "switchThemes": MessageLookupByLibrary.simpleMessage(
      "Switch between themes",
    ),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "tags": MessageLookupByLibrary.simpleMessage("Tags"),
    "tagsSeparatedByComma": MessageLookupByLibrary.simpleMessage(
      "Tags (separate with comma)",
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
    "textNotExtractedYet": MessageLookupByLibrary.simpleMessage(
      "Text not extracted yet",
    ),
    "timeAndDate": MessageLookupByLibrary.simpleMessage("Time & Date"),
    "tokenNotFound": MessageLookupByLibrary.simpleMessage(
      "❌ Error: Token not found",
    ),
    "totalDuration": m55,
    "trash": MessageLookupByLibrary.simpleMessage("Trash"),
    "trim": MessageLookupByLibrary.simpleMessage("Trim"),
    "trimAudio": MessageLookupByLibrary.simpleMessage("Trim Audio"),
    "type": MessageLookupByLibrary.simpleMessage("Type"),
    "unclassified": MessageLookupByLibrary.simpleMessage("Unclassified"),
    "unknownError": MessageLookupByLibrary.simpleMessage("Unknown error"),
    "unsavedChanges": MessageLookupByLibrary.simpleMessage("Unsaved changes"),
    "unsavedChangesMessage": MessageLookupByLibrary.simpleMessage(
      "You have unsaved changes. Do you want to exit without saving?",
    ),
    "unshare": MessageLookupByLibrary.simpleMessage("Unshare"),
    "unshareFailed": MessageLookupByLibrary.simpleMessage("Failed to unshare"),
    "unshareFile": MessageLookupByLibrary.simpleMessage("Unshare File"),
    "unshareFileConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to unshare this file with all users?",
    ),
    "unshareFileSuccess": MessageLookupByLibrary.simpleMessage(
      "✅ File unshared successfully",
    ),
    "unsupportedFile": MessageLookupByLibrary.simpleMessage("Unsupported File"),
    "updated": MessageLookupByLibrary.simpleMessage("Updated"),
    "updatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Updated successfully",
    ),
    "updating": MessageLookupByLibrary.simpleMessage("Updating..."),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Upload File"),
    "upload_success": MessageLookupByLibrary.simpleMessage(
      "File uploaded successfully",
    ),
    "used": MessageLookupByLibrary.simpleMessage("Used"),
    "usedStorage": MessageLookupByLibrary.simpleMessage("Used storage:"),
    "usedStorageValue": MessageLookupByLibrary.simpleMessage("149.5 GB"),
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
    "verificationCodeSent": MessageLookupByLibrary.simpleMessage(
      "✅ Verification code sent successfully",
    ),
    "verificationCodeSentTo": m56,
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "verifyCodeTitle": MessageLookupByLibrary.simpleMessage("Verify Code"),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoEditedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Video edited successfully",
    ),
    "videoMergedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "✅ Videos merged successfully",
    ),
    "videos": MessageLookupByLibrary.simpleMessage("Videos"),
    "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
    "viewDetails": MessageLookupByLibrary.simpleMessage("View Details"),
    "viewInfo": MessageLookupByLibrary.simpleMessage("View Info"),
    "viewOnly": MessageLookupByLibrary.simpleMessage("View Only"),
    "viewOnlyDescription": MessageLookupByLibrary.simpleMessage(
      "User can only view files",
    ),
    "viewedByAll": MessageLookupByLibrary.simpleMessage("Viewed by all"),
    "wavDescription": MessageLookupByLibrary.simpleMessage(
      "High quality, large size",
    ),
    "wavFormat": MessageLookupByLibrary.simpleMessage("WAV"),
    "width": m57,
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "youAreOwner": MessageLookupByLibrary.simpleMessage("You are the owner"),
  };
}
