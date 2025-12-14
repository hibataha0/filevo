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

  static String m1(folderName) =>
      "Are you sure you want to remove \"${folderName}\" from this room?";

  static String m2(memberName) =>
      "Are you sure you want to remove ${memberName} from the room?";

  static String m3(roomName) =>
      "Are you sure you want to delete \"${roomName}\"? All data associated with the room will be deleted.";

  static String m4(email) => "Enter the 6-digit code sent to ${email}";

  static String m5(error) => "Error: ${error}";

  static String m6(error) => "Error fetching subfolders: ${error}";

  static String m7(error) => "Error loading file: ${error}";

  static String m8(error) => "Error loading text file: ${error}";

  static String m9(error) => "Error opening file: ${error}";

  static String m10(error) => "Error verifying image: ${error}";

  static String m11(error) => "Error verifying video: ${error}";

  static String m12(hours) => "Expires in ${hours} hours";

  static String m13(statusCode) => "Failed to load audio file (${statusCode})";

  static String m14(statusCode) => "Failed to load file: ${statusCode}";

  static String m15(error) => "Failed to load PDF file: ${error}";

  static String m16(error) => "Failed to load PDF for display: ${error}";

  static String m17(statusCode) => "Failed to load video (${statusCode})";

  static String m18(error) => "Failed to open file: ${error}";

  static String m19(statusCode) => "File not available (error ${statusCode})";

  static String m20(statusCode) => "File not available (error ${statusCode})";

  static String m21(folderName) =>
      "Folder \"${folderName}\" created successfully";

  static String m22(roomName) =>
      "Are you sure you want to leave \"${roomName}\"? You will not be able to access this room after leaving.";

  static String m23(fileName) => "Open file as text: ${fileName}";

  static String m24(countdown) =>
      "Please wait ${countdown} seconds before resending";

  static String m31(fileName) =>
      "Are you sure you want to remove \"${fileName}\" from this room?";

  static String m25(countdown) => "Resend (${countdown})";

  static String m26(roomName) => "${roomName}";

  static String m27(error) => "Search error: ${error}";

  static String m28(folderName) => "Select \"${folderName}\"";

  static String m29(count) => "Shared Files (${count})";

  static String m30(email) =>
      "A 6-digit verification code has been sent to:\n${email}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "accessTokenNotFound": MessageLookupByLibrary.simpleMessage(
      "Access token not found",
    ),
    "accessed": MessageLookupByLibrary.simpleMessage("Accessed"),
    "accountActivatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Account activated successfully. You can now login",
    ),
    "accountCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Account created successfully!",
    ),
    "active": MessageLookupByLibrary.simpleMessage("Active"),
    "activityLog": MessageLookupByLibrary.simpleMessage("Activity Log"),
    "addFile": MessageLookupByLibrary.simpleMessage("Add File"),
    "addFileToRoom": MessageLookupByLibrary.simpleMessage("Add File to Room"),
    "addFilesToFavorites": MessageLookupByLibrary.simpleMessage(
      "You can add files to favorites through the menu",
    ),
    "addFolder": MessageLookupByLibrary.simpleMessage("Add Folder"),
    "addFolderToRoom": MessageLookupByLibrary.simpleMessage(
      "Add Folder to Room",
    ),
    "addToFavorites": MessageLookupByLibrary.simpleMessage("Add to Favorites"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allActivities": MessageLookupByLibrary.simpleMessage("All"),
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
      "You can view PDF and search in it.",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotAccessFile": MessageLookupByLibrary.simpleMessage(
      "Cannot access file",
    ),
    "cannotAddSharedFilesToFavorites": MessageLookupByLibrary.simpleMessage(
      "Cannot add shared files in room to favorites",
    ),
    "category": MessageLookupByLibrary.simpleMessage("Category"),
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "chooseFileOrFolder": MessageLookupByLibrary.simpleMessage(
      "Choose file or folder",
    ),
    "chooseLanguage": MessageLookupByLibrary.simpleMessage("Choose Language"),
    "chooseRoomToShare": MessageLookupByLibrary.simpleMessage(
      "Choose a room to share this file",
    ),
    "chooseTimeInSeconds": MessageLookupByLibrary.simpleMessage(
      "Choose time in seconds:",
    ),
    "chooseTimeToExtractImage": MessageLookupByLibrary.simpleMessage(
      "Choose Time to Extract Image",
    ),
    "code": MessageLookupByLibrary.simpleMessage("Code"),
    "codeResent": MessageLookupByLibrary.simpleMessage(
      "Code resent successfully",
    ),
    "codeSent": MessageLookupByLibrary.simpleMessage("Code sent successfully"),
    "codeVerified": MessageLookupByLibrary.simpleMessage(
      "Code verified successfully",
    ),
    "commenter": MessageLookupByLibrary.simpleMessage("Commenter"),
    "commenterDescription": MessageLookupByLibrary.simpleMessage(
      "Can comment on files",
    ),
    "comments": MessageLookupByLibrary.simpleMessage("Comments"),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "compressed": MessageLookupByLibrary.simpleMessage("Compressed"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmDeleteComment": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this comment?",
    ),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "confirmRejectInvitation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reject this invitation?",
    ),
    "confirmRemoveFileFromRoom": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this file from the room?",
    ),
    "confirmRemoveFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this folder from the room?",
    ),
    "confirmRemoveFolderFromRoomWithName": m1,
    "confirmRemoveMember": m2,
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
    "deleteRoom": MessageLookupByLibrary.simpleMessage("Delete Room"),
    "deleteRoomConfirm": m3,
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
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editEmail": MessageLookupByLibrary.simpleMessage("Edit Email"),
    "editFile": MessageLookupByLibrary.simpleMessage("Edit File"),
    "editImage": MessageLookupByLibrary.simpleMessage("Edit Image"),
    "editText": MessageLookupByLibrary.simpleMessage("Edit Text"),
    "editUsername": MessageLookupByLibrary.simpleMessage("Edit Username"),
    "editor": MessageLookupByLibrary.simpleMessage("Editor"),
    "editorDescription": MessageLookupByLibrary.simpleMessage("Can edit files"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailVerification": MessageLookupByLibrary.simpleMessage(
      "Email Verification",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enter6DigitCode": MessageLookupByLibrary.simpleMessage(
      "Please enter a 6-digit code",
    ),
    "enterCodeToEmail": m4,
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
    "error": m5,
    "errorAccessingFile": MessageLookupByLibrary.simpleMessage(
      "Error accessing file",
    ),
    "errorFetchingData": MessageLookupByLibrary.simpleMessage(
      "Error fetching data",
    ),
    "errorFetchingSubfolders": m6,
    "errorLoadingFile": m7,
    "errorLoadingFileData": MessageLookupByLibrary.simpleMessage(
      "Error loading file data",
    ),
    "errorLoadingRoomDetails": MessageLookupByLibrary.simpleMessage(
      "Error loading room details",
    ),
    "errorLoadingSubfolders": MessageLookupByLibrary.simpleMessage(
      "Error loading subfolders",
    ),
    "errorLoadingTextFile": m8,
    "errorOpeningFile": m9,
    "errorVerifyingImage": m10,
    "errorVerifyingVideo": m11,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expiresInHours": m12,
    "extension": MessageLookupByLibrary.simpleMessage("Extension"),
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
    "failedToExtractImage": MessageLookupByLibrary.simpleMessage(
      "Failed to extract image",
    ),
    "failedToExtractTextFromPdf": MessageLookupByLibrary.simpleMessage(
      "Failed to extract text from PDF.",
    ),
    "failedToFetchFolderInfo": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch folder information",
    ),
    "failedToLoadAudio": m13,
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
    "failedToLoadFileStatus": m14,
    "failedToLoadImage": MessageLookupByLibrary.simpleMessage(
      "Failed to load image",
    ),
    "failedToLoadPdf": MessageLookupByLibrary.simpleMessage(
      "Failed to load PDF file",
    ),
    "failedToLoadPdfFile": m15,
    "failedToLoadPdfForDisplay": m16,
    "failedToLoadPreview": MessageLookupByLibrary.simpleMessage(
      "Failed to load preview",
    ),
    "failedToLoadRoomData": MessageLookupByLibrary.simpleMessage(
      "Failed to load room data",
    ),
    "failedToLoadRoomDetails": MessageLookupByLibrary.simpleMessage(
      "Failed to load room details",
    ),
    "failedToLoadVideo": m17,
    "failedToMergeVideos": MessageLookupByLibrary.simpleMessage(
      "Failed to merge clips",
    ),
    "failedToMoveFile": MessageLookupByLibrary.simpleMessage(
      "Failed to move file",
    ),
    "failedToOpenFile": m18,
    "failedToRemoveFile": MessageLookupByLibrary.simpleMessage(
      "Failed to remove file from room",
    ),
    "failedToResendCode": MessageLookupByLibrary.simpleMessage(
      "Failed to resend verification code",
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
    "favoriteFiles": MessageLookupByLibrary.simpleMessage("Favorite Files"),
    "featureUnderDevelopment": MessageLookupByLibrary.simpleMessage(
      "Information feature under development",
    ),
    "fieldRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileAlreadyAccessed": MessageLookupByLibrary.simpleMessage(
      "You have already accessed this file. One-time share only.",
    ),
    "fileAlreadyShared": MessageLookupByLibrary.simpleMessage(
      "This file is already shared with this room",
    ),
    "fileIdNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File ID not available",
    ),
    "fileIdNotFound": MessageLookupByLibrary.simpleMessage(
      "Error: File ID not found",
    ),
    "fileInfo": MessageLookupByLibrary.simpleMessage("File Information"),
    "fileIsEmpty": MessageLookupByLibrary.simpleMessage("File is empty"),
    "fileLinkNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File link not available",
    ),
    "fileLinkNotAvailableNoPath": MessageLookupByLibrary.simpleMessage(
      "File link not available - no path or _id",
    ),
    "fileMovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "File moved successfully",
    ),
    "fileNotAvailable": m19,
    "fileNotAvailableError": m20,
    "fileNotLoaded": MessageLookupByLibrary.simpleMessage("File not loaded"),
    "fileNotValidPdf": MessageLookupByLibrary.simpleMessage(
      "This file is not a valid PDF or may be corrupted.",
    ),
    "fileRemovedFromRoom": MessageLookupByLibrary.simpleMessage(
      "File removed from room successfully",
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
    "fileUrlNotAvailable": MessageLookupByLibrary.simpleMessage(
      "File URL not available",
    ),
    "fileWithoutName": MessageLookupByLibrary.simpleMessage(
      "File without name",
    ),
    "files": MessageLookupByLibrary.simpleMessage("Files"),
    "filesCount": MessageLookupByLibrary.simpleMessage("Number of Files"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "filterActivity": MessageLookupByLibrary.simpleMessage("Filter Activity"),
    "folder": MessageLookupByLibrary.simpleMessage("Folder"),
    "folderCreatedSuccessfully": m21,
    "folderIdNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Folder ID not available",
    ),
    "folderInfo": MessageLookupByLibrary.simpleMessage("Folder Information"),
    "folderNameHint": MessageLookupByLibrary.simpleMessage("Folder Name"),
    "folderWithoutName": MessageLookupByLibrary.simpleMessage(
      "Folder without name",
    ),
    "folders": MessageLookupByLibrary.simpleMessage("Folders"),
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
    "helpSupport": MessageLookupByLibrary.simpleMessage("Help & Support"),
    "highlightSelectedText": MessageLookupByLibrary.simpleMessage(
      "Highlight selected text",
    ),
    "highlights": MessageLookupByLibrary.simpleMessage("highlight"),
    "image": MessageLookupByLibrary.simpleMessage("Image"),
    "imageEdited": MessageLookupByLibrary.simpleMessage("Image Edited"),
    "imageExtracted": MessageLookupByLibrary.simpleMessage("Image Extracted"),
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
    "invalidPdfFile": MessageLookupByLibrary.simpleMessage("Invalid PDF file"),
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
    "leaveRoomConfirm": m22,
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
      "Logged out successfully",
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
      "Merging clips... This may take some time",
    ),
    "microphonePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Microphone Permission Required",
    ),
    "mobile": MessageLookupByLibrary.simpleMessage("Mobile"),
    "modified": MessageLookupByLibrary.simpleMessage("Modified"),
    "move": MessageLookupByLibrary.simpleMessage("Move"),
    "moveFile": MessageLookupByLibrary.simpleMessage("Move File"),
    "moveFolderToRoot": MessageLookupByLibrary.simpleMessage(
      "Move folder to main folder",
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
    "mustAllowMicrophoneAccess": MessageLookupByLibrary.simpleMessage(
      "You must allow microphone access for voice search.",
    ),
    "mustLogin": MessageLookupByLibrary.simpleMessage("You must log in first"),
    "mustLoginFirst": MessageLookupByLibrary.simpleMessage(
      "You must login first",
    ),
    "mustSelectAtLeastTwoAudioFiles": MessageLookupByLibrary.simpleMessage(
      "Must select at least two audio files to merge",
    ),
    "myFiles": MessageLookupByLibrary.simpleMessage("My Files"),
    "myFolders": MessageLookupByLibrary.simpleMessage("My Folders"),
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
    "openFileAsText": m23,
    "openFileDetailsToShare": MessageLookupByLibrary.simpleMessage(
      "Please open the file details page and share it with the room from there",
    ),
    "openFolderDetailsToShare": MessageLookupByLibrary.simpleMessage(
      "Please open the folder details page and share it with the room from there",
    ),
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
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordConfirmationRequired": MessageLookupByLibrary.simpleMessage(
      "Password confirmation is required",
    ),
    "passwordMin": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwordUpdateFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to update password",
    ),
    "passwordUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Password updated successfully",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "pdfTextExtractionNote": MessageLookupByLibrary.simpleMessage(
      "Note: Text extraction may not be available for all PDF files.",
    ),
    "pdfTextExtractionNote2": MessageLookupByLibrary.simpleMessage(
      "You can select and highlight text after extraction.",
    ),
    "pendingInvitations": MessageLookupByLibrary.simpleMessage(
      "Pending Invitations",
    ),
    "permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Permission denied. You must allow microphone access for voice search.",
    ),
    "pleaseEnter6DigitCode": MessageLookupByLibrary.simpleMessage(
      "Please enter the 6-digit verification code",
    ),
    "pleaseEnterComment": MessageLookupByLibrary.simpleMessage(
      "Please enter a comment",
    ),
    "pleaseEnterFolderName": MessageLookupByLibrary.simpleMessage(
      "Please enter folder name",
    ),
    "pleaseEnterRoomName": MessageLookupByLibrary.simpleMessage(
      "Please enter a room name",
    ),
    "pleaseLoginAgain": MessageLookupByLibrary.simpleMessage(
      "Please login again",
    ),
    "pleaseSelectFileOrFolder": MessageLookupByLibrary.simpleMessage(
      "Please select a file/folder to comment on",
    ),
    "pleaseWaitBeforeResend": m24,
    "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
    "previous": MessageLookupByLibrary.simpleMessage("Previous"),
    "privacySecurity": MessageLookupByLibrary.simpleMessage(
      "Privacy & Security",
    ),
    "privacySettings": MessageLookupByLibrary.simpleMessage("Privacy settings"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
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
    "removeFileFromRoomConfirm": m31,
    "removeFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "Remove Folder from Room",
    ),
    "removeFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Remove from Favorites",
    ),
    "removeFromRoom": MessageLookupByLibrary.simpleMessage("Remove from Room"),
    "removeMember": MessageLookupByLibrary.simpleMessage("Remove Member"),
    "resend": MessageLookupByLibrary.simpleMessage("Resend"),
    "resendCode": MessageLookupByLibrary.simpleMessage("Resend Code"),
    "resendWithCountdown": m25,
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "room": MessageLookupByLibrary.simpleMessage("Room"),
    "roomDetails": MessageLookupByLibrary.simpleMessage("Room Details"),
    "roomInfo": MessageLookupByLibrary.simpleMessage("Room Info"),
    "roomLabel": MessageLookupByLibrary.simpleMessage("Room"),
    "roomMembers": MessageLookupByLibrary.simpleMessage("Room Members"),
    "roomName": m26,
    "roomNamePlaceholder": MessageLookupByLibrary.simpleMessage("No name"),
    "root": MessageLookupByLibrary.simpleMessage("Root"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveThisImage": MessageLookupByLibrary.simpleMessage(
      "Do you want to save this image?",
    ),
    "saveToMyAccount": MessageLookupByLibrary.simpleMessage(
      "Save to My Account",
    ),
    "saveToRoot": MessageLookupByLibrary.simpleMessage("Save to Root"),
    "savingFolder": MessageLookupByLibrary.simpleMessage("Saving folder..."),
    "searchError": m27,
    "searchHint": MessageLookupByLibrary.simpleMessage("Search anything here"),
    "searchInPdf": MessageLookupByLibrary.simpleMessage("Search in PDF"),
    "searchInPdfNotAvailableMessage": MessageLookupByLibrary.simpleMessage(
      "Search in PDF is not currently available. You can open the file in an external app to search.",
    ),
    "seeAll": MessageLookupByLibrary.simpleMessage("See all"),
    "selectFolder": m28,
    "selectFolderDescription": MessageLookupByLibrary.simpleMessage(
      "Move to this folder",
    ),
    "selectTargetFolder": MessageLookupByLibrary.simpleMessage(
      "Select Target Folder",
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
      "Share files with this room",
    ),
    "shareFolderWithRoom": MessageLookupByLibrary.simpleMessage(
      "Share Folder with Room",
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
    "sharedFilesCount": m29,
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
      "Speech recognition service not available",
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
    "subfoldersCount": MessageLookupByLibrary.simpleMessage(
      "Number of Subfolders",
    ),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "switchThemes": MessageLookupByLibrary.simpleMessage(
      "Switch between themes",
    ),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "tags": MessageLookupByLibrary.simpleMessage("Tags"),
    "termsPrivacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Terms of service & privacy policy",
    ),
    "textEdited": MessageLookupByLibrary.simpleMessage("Text Edited"),
    "textHighlighted": MessageLookupByLibrary.simpleMessage(
      "Selected text highlighted",
    ),
    "textNotExtractedYet": MessageLookupByLibrary.simpleMessage(
      "Text not extracted yet",
    ),
    "timeAndDate": MessageLookupByLibrary.simpleMessage("Time & Date"),
    "tokenNotFound": MessageLookupByLibrary.simpleMessage("Token not found"),
    "trash": MessageLookupByLibrary.simpleMessage("Trash"),
    "type": MessageLookupByLibrary.simpleMessage("Type"),
    "typeLabel": MessageLookupByLibrary.simpleMessage("Type"),
    "unclassified": MessageLookupByLibrary.simpleMessage("Unclassified"),
    "unknownFile": MessageLookupByLibrary.simpleMessage("Unknown file"),
    "unsavedChanges": MessageLookupByLibrary.simpleMessage("Unsaved changes"),
    "unsavedChangesMessage": MessageLookupByLibrary.simpleMessage(
      "You have unsaved changes. Do you want to exit without saving?",
    ),
    "unshare": MessageLookupByLibrary.simpleMessage("Unshare"),
    "unshareFile": MessageLookupByLibrary.simpleMessage("Unshare File"),
    "unshareFileConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to unshare this file with all users?",
    ),
    "unsupportedFile": MessageLookupByLibrary.simpleMessage("Unsupported File"),
    "updateFailed": MessageLookupByLibrary.simpleMessage("Failed to update"),
    "updated": MessageLookupByLibrary.simpleMessage("Updated"),
    "updatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Updated successfully",
    ),
    "updating": MessageLookupByLibrary.simpleMessage("Updating..."),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Upload File"),
    "upload_success": MessageLookupByLibrary.simpleMessage(
      "File uploaded successfully",
    ),
    "used": MessageLookupByLibrary.simpleMessage("Used"),
    "usedStorage": MessageLookupByLibrary.simpleMessage("Used storage:"),
    "usedStorageValue": MessageLookupByLibrary.simpleMessage("149.5 GB"),
    "user": MessageLookupByLibrary.simpleMessage("User"),
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
      "Please enter a valid email address",
    ),
    "verificationCodeSent": MessageLookupByLibrary.simpleMessage(
      "Verification code sent to your email",
    ),
    "verificationCodeSentTo": m30,
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "verifyCodeTitle": MessageLookupByLibrary.simpleMessage("Verify Code"),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videos": MessageLookupByLibrary.simpleMessage("Videos"),
    "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
    "viewDetails": MessageLookupByLibrary.simpleMessage("View Details"),
    "viewInfo": MessageLookupByLibrary.simpleMessage("View Info"),
    "viewOnly": MessageLookupByLibrary.simpleMessage("View Only"),
    "viewOnlyDescription": MessageLookupByLibrary.simpleMessage(
      "Can only view files",
    ),
    "viewedByAll": MessageLookupByLibrary.simpleMessage("Viewed by all"),
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "youAreOwner": MessageLookupByLibrary.simpleMessage("You are the owner"),
  };
}
