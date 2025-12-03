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

  static String m1(roomName) =>
      "Are you sure you want to delete \"${roomName}\"? All data associated with the room will be deleted.";

  static String m2(email) => "Enter the 6-digit code sent to ${email}";

  static String m3(hours) => "Expires in ${hours} hours";

  static String m4(statusCode) => "File not available (error ${statusCode})";

  static String m5(count) => "${count}";

  static String m6(roomName) =>
      "Are you sure you want to leave \"${roomName}\"? You will not be able to access this room after leaving.";

  static String m9(fileName) =>
      "Are you sure you want to remove \"${fileName}\" from this room?";

  static String m7(roomName) => "${roomName}";

  static String m8(count) => "Shared Files (${count})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "accessed": MessageLookupByLibrary.simpleMessage("Accessed"),
        "accountCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Account created successfully!"),
        "active": MessageLookupByLibrary.simpleMessage("Active"),
        "addFile": MessageLookupByLibrary.simpleMessage("Add File"),
        "addFileToRoom":
            MessageLookupByLibrary.simpleMessage("Add File to Room"),
        "addFolder": MessageLookupByLibrary.simpleMessage("Add Folder"),
        "addFolderToRoom":
            MessageLookupByLibrary.simpleMessage("Add Folder to Room"),
        "addToFavorites":
            MessageLookupByLibrary.simpleMessage("Add to Favorites"),
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "allItems": MessageLookupByLibrary.simpleMessage("All Items"),
        "alreadyHaveAccount":
            MessageLookupByLibrary.simpleMessage("Already have an account? "),
        "appTitle": MessageLookupByLibrary.simpleMessage("Flievo"),
        "appVersion": m0,
        "applications": MessageLookupByLibrary.simpleMessage("Applications"),
        "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
        "audio": MessageLookupByLibrary.simpleMessage("Audio"),
        "backToLogin": MessageLookupByLibrary.simpleMessage("Back to Login"),
        "basicAppSettings":
            MessageLookupByLibrary.simpleMessage("Basic app settings"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cannotAccessFile":
            MessageLookupByLibrary.simpleMessage("Cannot access file"),
        "changePassword":
            MessageLookupByLibrary.simpleMessage("Change Password"),
        "chooseLanguage":
            MessageLookupByLibrary.simpleMessage("Choose Language"),
        "chooseRoomToShare": MessageLookupByLibrary.simpleMessage(
            "Choose a room to share this file"),
        "code": MessageLookupByLibrary.simpleMessage("Code"),
        "codeResent":
            MessageLookupByLibrary.simpleMessage("Code resent successfully"),
        "codeSent":
            MessageLookupByLibrary.simpleMessage("Code sent successfully"),
        "codeVerified":
            MessageLookupByLibrary.simpleMessage("Code verified successfully"),
        "comments": MessageLookupByLibrary.simpleMessage("Comments"),
        "completed": MessageLookupByLibrary.simpleMessage("Completed"),
        "compressed": MessageLookupByLibrary.simpleMessage("Compressed"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmNewPassword":
            MessageLookupByLibrary.simpleMessage("Confirm New Password"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Create account"),
        "createFolder": MessageLookupByLibrary.simpleMessage("Create Folder"),
        "createRoomFirst": MessageLookupByLibrary.simpleMessage(
            "Create a room first to share"),
        "createdAt": MessageLookupByLibrary.simpleMessage("Created at"),
        "currentPassword":
            MessageLookupByLibrary.simpleMessage("Current Password"),
        "currentPasswordRequired": MessageLookupByLibrary.simpleMessage(
            "Current password is required"),
        "custom": MessageLookupByLibrary.simpleMessage("Custom"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteRoom": MessageLookupByLibrary.simpleMessage("Delete Room"),
        "deleteRoomConfirm": m1,
        "deletedFiles": MessageLookupByLibrary.simpleMessage("Deleted Files"),
        "deletedFolders":
            MessageLookupByLibrary.simpleMessage("Deleted Folders"),
        "documents": MessageLookupByLibrary.simpleMessage("Documents"),
        "dontHaveAccount":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account? "),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editEmail": MessageLookupByLibrary.simpleMessage("Edit Email"),
        "editUsername": MessageLookupByLibrary.simpleMessage("Edit Username"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enter6DigitCode":
            MessageLookupByLibrary.simpleMessage("Please enter a 6-digit code"),
        "enterCodeToEmail": m2,
        "enterConfirmPassword": MessageLookupByLibrary.simpleMessage(
            "Please confirm your password"),
        "enterEmail":
            MessageLookupByLibrary.simpleMessage("Please enter your email"),
        "enterFolderName":
            MessageLookupByLibrary.simpleMessage("Please enter folder name"),
        "enterHours":
            MessageLookupByLibrary.simpleMessage("Enter number of hours"),
        "enterPassword":
            MessageLookupByLibrary.simpleMessage("Please enter your password"),
        "enterPhone": MessageLookupByLibrary.simpleMessage(
            "Please enter your phone number"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Please enter your username"),
        "enterUsernameOrEmail": MessageLookupByLibrary.simpleMessage(
            "Please enter your username or email"),
        "errorAccessingFile":
            MessageLookupByLibrary.simpleMessage("Error accessing file"),
        "errorFetchingData":
            MessageLookupByLibrary.simpleMessage("Error fetching data"),
        "errorLoadingFile":
            MessageLookupByLibrary.simpleMessage("Error loading file"),
        "errorLoadingRoomDetails":
            MessageLookupByLibrary.simpleMessage("Error loading room details"),
        "errorLoadingSubfolders":
            MessageLookupByLibrary.simpleMessage("Error loading subfolders"),
        "errorOpeningFile":
            MessageLookupByLibrary.simpleMessage("Error opening file"),
        "expiresInHours": m3,
        "failedResendCode":
            MessageLookupByLibrary.simpleMessage("Failed to resend code"),
        "failedSendCode":
            MessageLookupByLibrary.simpleMessage("Failed to send code"),
        "failedToLoadRoomDetails":
            MessageLookupByLibrary.simpleMessage("Failed to load room details"),
        "failedToMoveFile":
            MessageLookupByLibrary.simpleMessage("Failed to move file"),
        "failedToRemoveFile": MessageLookupByLibrary.simpleMessage(
            "Failed to remove file from room"),
        "fieldRequired":
            MessageLookupByLibrary.simpleMessage("This field is required"),
        "file": MessageLookupByLibrary.simpleMessage("File"),
        "fileAlreadyAccessed": MessageLookupByLibrary.simpleMessage(
            "You have already accessed this file. One-time share only."),
        "fileAlreadyShared": MessageLookupByLibrary.simpleMessage(
            "This file is already shared with this room"),
        "fileIdNotAvailable":
            MessageLookupByLibrary.simpleMessage("File ID not available"),
        "fileIdNotFound":
            MessageLookupByLibrary.simpleMessage("Error: File ID not found"),
        "fileMovedSuccessfully":
            MessageLookupByLibrary.simpleMessage("File moved successfully"),
        "fileNotAvailable": m4,
        "fileRemovedFromRoom": MessageLookupByLibrary.simpleMessage(
            "File removed from room successfully"),
        "fileUrlNotAvailable":
            MessageLookupByLibrary.simpleMessage("File URL not available"),
        "files": MessageLookupByLibrary.simpleMessage("Files"),
        "filesCount": m5,
        "filter": MessageLookupByLibrary.simpleMessage("Filter"),
        "folderIdNotAvailable":
            MessageLookupByLibrary.simpleMessage("Error: Folder ID not found"),
        "folderNameHint": MessageLookupByLibrary.simpleMessage("Folder Name"),
        "folders": MessageLookupByLibrary.simpleMessage("Folders"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot Password?"),
        "forgotPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
            "Enter your email address and we\'ll send you a code to reset your password."),
        "forgotPasswordTitle":
            MessageLookupByLibrary.simpleMessage("Forgot your password?"),
        "freeInternal": MessageLookupByLibrary.simpleMessage("Free Internal"),
        "freeInternalValue": MessageLookupByLibrary.simpleMessage("120.5 GB"),
        "general": MessageLookupByLibrary.simpleMessage("General"),
        "generalSettings":
            MessageLookupByLibrary.simpleMessage("General Settings"),
        "getHelpSupport":
            MessageLookupByLibrary.simpleMessage("Get help and support"),
        "helpSupport": MessageLookupByLibrary.simpleMessage("Help & Support"),
        "images": MessageLookupByLibrary.simpleMessage("Images"),
        "invalidCredentials":
            MessageLookupByLibrary.simpleMessage("Invalid credentials"),
        "invalidEmail": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid email address"),
        "invalidOrExpiredCode":
            MessageLookupByLibrary.simpleMessage("Invalid or expired code"),
        "invalidPdfFile": MessageLookupByLibrary.simpleMessage(
            "This file is not a valid PDF or may be corrupted."),
        "invalidPhone": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid phone number (10-15 digits)"),
        "invalidUrl": MessageLookupByLibrary.simpleMessage("Invalid URL"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "last30Days": MessageLookupByLibrary.simpleMessage("Last 30 days"),
        "last7Days": MessageLookupByLibrary.simpleMessage("Last 7 days"),
        "lastModified": MessageLookupByLibrary.simpleMessage("Last Modified"),
        "lastYear": MessageLookupByLibrary.simpleMessage("Last year"),
        "leave": MessageLookupByLibrary.simpleMessage("Leave"),
        "leaveRoom": MessageLookupByLibrary.simpleMessage("Leave Room"),
        "leaveRoomConfirm": m6,
        "legalPolicies":
            MessageLookupByLibrary.simpleMessage("Legal & Policies"),
        "logIn": MessageLookupByLibrary.simpleMessage("Log In"),
        "loginRequiredToAccessFiles": MessageLookupByLibrary.simpleMessage(
            "You must log in to access the files"),
        "loginSubtitle":
            MessageLookupByLibrary.simpleMessage("Login to your account"),
        "loginSuccessful":
            MessageLookupByLibrary.simpleMessage("Login successful!"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutSuccess":
            MessageLookupByLibrary.simpleMessage("Logged out successfully"),
        "manageNotifications":
            MessageLookupByLibrary.simpleMessage("Manage notifications"),
        "manageStorageSettings":
            MessageLookupByLibrary.simpleMessage("Manage storage settings"),
        "members": MessageLookupByLibrary.simpleMessage("Members"),
        "mobile": MessageLookupByLibrary.simpleMessage("Mobile"),
        "modified": MessageLookupByLibrary.simpleMessage("Modified"),
        "move": MessageLookupByLibrary.simpleMessage("Move"),
        "moveFile": MessageLookupByLibrary.simpleMessage("Move File"),
        "moveToRoot": MessageLookupByLibrary.simpleMessage("Move to Root"),
        "moveToRootDescription":
            MessageLookupByLibrary.simpleMessage("Move folder to main folder"),
        "movingFile": MessageLookupByLibrary.simpleMessage("Moving file..."),
        "mustLogin":
            MessageLookupByLibrary.simpleMessage("You must log in first"),
        "mustLoginFirst": MessageLookupByLibrary.simpleMessage(
            "Error: You must log in first"),
        "myFiles": MessageLookupByLibrary.simpleMessage("My Files"),
        "myFolders": MessageLookupByLibrary.simpleMessage("My Folders"),
        "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
        "newPasswordRequired":
            MessageLookupByLibrary.simpleMessage("New password is required"),
        "noFiles": MessageLookupByLibrary.simpleMessage("No files"),
        "noFilesInCategory":
            MessageLookupByLibrary.simpleMessage("No files in this category."),
        "noFoldersAvailable":
            MessageLookupByLibrary.simpleMessage("No folders available"),
        "noMembers": MessageLookupByLibrary.simpleMessage("No members"),
        "noRoomsAvailable":
            MessageLookupByLibrary.simpleMessage("No rooms available"),
        "noSharedFiles":
            MessageLookupByLibrary.simpleMessage("No shared files"),
        "noSubfolders": MessageLookupByLibrary.simpleMessage("No subfolders"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "numberOfFiles":
            MessageLookupByLibrary.simpleMessage("Number of files:"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "oneTimeShare": MessageLookupByLibrary.simpleMessage("One-time Share"),
        "oneTimeShareAccessRecorded": MessageLookupByLibrary.simpleMessage(
            "This file is shared for one time - your access has been recorded"),
        "oneTimeShareDescription": MessageLookupByLibrary.simpleMessage(
            "Each user can open the file only once"),
        "onlyOwnerCanDelete": MessageLookupByLibrary.simpleMessage(
            "Only room owner can delete it"),
        "open": MessageLookupByLibrary.simpleMessage("Open"),
        "openAsText": MessageLookupByLibrary.simpleMessage("Open as Text"),
        "openFileDetailsToShare": MessageLookupByLibrary.simpleMessage(
            "Please open the file details page and share it with the room from there"),
        "openFolderDetailsToShare": MessageLookupByLibrary.simpleMessage(
            "Please open the folder details page and share it with the room from there"),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "owner": MessageLookupByLibrary.simpleMessage("Owner"),
        "ownerCannotLeave": MessageLookupByLibrary.simpleMessage(
            "Room owner cannot leave. Please delete the room instead"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordConfirmationRequired": MessageLookupByLibrary.simpleMessage(
            "Password confirmation is required"),
        "passwordMin": MessageLookupByLibrary.simpleMessage(
            "Password must be at least 6 characters"),
        "passwordMinLength": MessageLookupByLibrary.simpleMessage(
            "Password must be at least 6 characters"),
        "passwordUpdateFailed":
            MessageLookupByLibrary.simpleMessage("Failed to update password"),
        "passwordUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Password updated successfully"),
        "passwordsDoNotMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
        "privacySecurity":
            MessageLookupByLibrary.simpleMessage("Privacy & Security"),
        "privacySettings":
            MessageLookupByLibrary.simpleMessage("Privacy settings"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "recentFiles": MessageLookupByLibrary.simpleMessage("Recent Files"),
        "recentFolders": MessageLookupByLibrary.simpleMessage("Recent Folders"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "removeFileFromRoom":
            MessageLookupByLibrary.simpleMessage("Remove File from Room"),
        "removeFileFromRoomConfirm": m9,
        "removeFromFavorites":
            MessageLookupByLibrary.simpleMessage("Remove from Favorites"),
        "removeFromRoom":
            MessageLookupByLibrary.simpleMessage("Remove from Room"),
        "resendCode": MessageLookupByLibrary.simpleMessage("Resend Code"),
        "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "roomDetails": MessageLookupByLibrary.simpleMessage("Room Details"),
        "roomInfo": MessageLookupByLibrary.simpleMessage("Room Info"),
        "roomName": m7,
        "roomNamePlaceholder": MessageLookupByLibrary.simpleMessage("No name"),
        "root": MessageLookupByLibrary.simpleMessage("Root"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Search anything here"),
        "seeAll": MessageLookupByLibrary.simpleMessage("See all"),
        "selectFolder": MessageLookupByLibrary.simpleMessage("Select"),
        "selectFolderDescription":
            MessageLookupByLibrary.simpleMessage("Move to this folder"),
        "selectTargetFolder":
            MessageLookupByLibrary.simpleMessage("Select Target Folder"),
        "sendCode": MessageLookupByLibrary.simpleMessage("Send Code"),
        "sendInvitation":
            MessageLookupByLibrary.simpleMessage("Send Invitation"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "shareFileWithRoom":
            MessageLookupByLibrary.simpleMessage("Share File with Room"),
        "shareFilesWithRoom":
            MessageLookupByLibrary.simpleMessage("Share files with this room"),
        "shared": MessageLookupByLibrary.simpleMessage("Shared"),
        "sharedBy": MessageLookupByLibrary.simpleMessage("Shared by"),
        "sharedFiles": MessageLookupByLibrary.simpleMessage("Shared Files"),
        "sharedFilesContent": MessageLookupByLibrary.simpleMessage(
            "Shared files content will be here"),
        "sharedFilesCount": m8,
        "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
        "signInWith": MessageLookupByLibrary.simpleMessage("Sign in with"),
        "signOut":
            MessageLookupByLibrary.simpleMessage("Sign out from your account"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "signUpWith": MessageLookupByLibrary.simpleMessage("Sign up with"),
        "startAddingFiles":
            MessageLookupByLibrary.simpleMessage("Start adding new files"),
        "storage": MessageLookupByLibrary.simpleMessage("Storage"),
        "storageOverview":
            MessageLookupByLibrary.simpleMessage("Storage Overview"),
        "storageUsed": MessageLookupByLibrary.simpleMessage("Used"),
        "storageUsedValue": MessageLookupByLibrary.simpleMessage("60%"),
        "support": MessageLookupByLibrary.simpleMessage("Support"),
        "switchThemes":
            MessageLookupByLibrary.simpleMessage("Switch between themes"),
        "termsPrivacyPolicy": MessageLookupByLibrary.simpleMessage(
            "Terms of service & privacy policy"),
        "timeAndDate": MessageLookupByLibrary.simpleMessage("Time & Date"),
        "tokenNotFound":
            MessageLookupByLibrary.simpleMessage("Token not found"),
        "trash": MessageLookupByLibrary.simpleMessage("Trash"),
        "type": MessageLookupByLibrary.simpleMessage("Type"),
        "unknownFile": MessageLookupByLibrary.simpleMessage("Unknown file"),
        "unsupportedFile":
            MessageLookupByLibrary.simpleMessage("Unsupported File"),
        "updateFailed":
            MessageLookupByLibrary.simpleMessage("Failed to update"),
        "updated": MessageLookupByLibrary.simpleMessage("Updated"),
        "updatedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Updated successfully"),
        "upload_success":
            MessageLookupByLibrary.simpleMessage("File uploaded successfully"),
        "used": MessageLookupByLibrary.simpleMessage("Used"),
        "usedStorage": MessageLookupByLibrary.simpleMessage("Used storage:"),
        "usedStorageValue": MessageLookupByLibrary.simpleMessage("149.5 GB"),
        "user": MessageLookupByLibrary.simpleMessage("User"),
        "username": MessageLookupByLibrary.simpleMessage("Username"),
        "usernameAllowedChars": MessageLookupByLibrary.simpleMessage(
            "Username can only contain letters, numbers and underscore"),
        "usernameMax": MessageLookupByLibrary.simpleMessage(
            "Username cannot exceed 20 characters"),
        "usernameMin": MessageLookupByLibrary.simpleMessage(
            "Username must be at least 3 characters"),
        "usernameOrEmail":
            MessageLookupByLibrary.simpleMessage("Username or Email"),
        "validEmail":
            MessageLookupByLibrary.simpleMessage("Please enter a valid email"),
        "validEmailRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid email address"),
        "verify": MessageLookupByLibrary.simpleMessage("Verify"),
        "verifyCodeTitle": MessageLookupByLibrary.simpleMessage("Verify Code"),
        "videos": MessageLookupByLibrary.simpleMessage("Videos"),
        "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("View Details"),
        "viewInfo": MessageLookupByLibrary.simpleMessage("View Info"),
        "viewedByAll": MessageLookupByLibrary.simpleMessage("Viewed by all"),
        "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday")
      };
}
