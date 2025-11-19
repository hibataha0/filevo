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

  static String m1(email) => "Enter the 6-digit code sent to ${email}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "accountCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Account created successfully!"),
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
        "chooseLanguage":
            MessageLookupByLibrary.simpleMessage("Choose Language"),
        "code": MessageLookupByLibrary.simpleMessage("Code"),
        "codeResent":
            MessageLookupByLibrary.simpleMessage("Code resent successfully"),
        "codeSent":
            MessageLookupByLibrary.simpleMessage("Code sent successfully"),
        "codeVerified":
            MessageLookupByLibrary.simpleMessage("Code verified successfully"),
        "compressed": MessageLookupByLibrary.simpleMessage("Compressed"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Create account"),
        "createFolder": MessageLookupByLibrary.simpleMessage("Create Folder"),
        "custom": MessageLookupByLibrary.simpleMessage("Custom"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "documents": MessageLookupByLibrary.simpleMessage("Documents"),
        "dontHaveAccount":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account? "),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enter6DigitCode":
            MessageLookupByLibrary.simpleMessage("Please enter a 6-digit code"),
        "enterCodeToEmail": m1,
        "enterConfirmPassword": MessageLookupByLibrary.simpleMessage(
            "Please confirm your password"),
        "enterEmail":
            MessageLookupByLibrary.simpleMessage("Please enter your email"),
        "enterFolderName":
            MessageLookupByLibrary.simpleMessage("Please enter folder name"),
        "enterPassword":
            MessageLookupByLibrary.simpleMessage("Please enter your password"),
        "enterPhone": MessageLookupByLibrary.simpleMessage(
            "Please enter your phone number"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Please enter your username"),
        "enterUsernameOrEmail": MessageLookupByLibrary.simpleMessage(
            "Please enter your username or email"),
        "errorFetchingData":
            MessageLookupByLibrary.simpleMessage("Error fetching data"),
        "failedResendCode":
            MessageLookupByLibrary.simpleMessage("Failed to resend code"),
        "failedSendCode":
            MessageLookupByLibrary.simpleMessage("Failed to send code"),
        "filter": MessageLookupByLibrary.simpleMessage("Filter"),
        "folderNameHint": MessageLookupByLibrary.simpleMessage("Folder Name"),
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
        "invalidPhone": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid phone number (10-15 digits)"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "last30Days": MessageLookupByLibrary.simpleMessage("Last 30 days"),
        "last7Days": MessageLookupByLibrary.simpleMessage("Last 7 days"),
        "lastYear": MessageLookupByLibrary.simpleMessage("Last year"),
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
        "manageNotifications":
            MessageLookupByLibrary.simpleMessage("Manage notifications"),
        "manageStorageSettings":
            MessageLookupByLibrary.simpleMessage("Manage storage settings"),
        "mobile": MessageLookupByLibrary.simpleMessage("Mobile"),
        "mustLogin":
            MessageLookupByLibrary.simpleMessage("You must log in first"),
        "myFiles": MessageLookupByLibrary.simpleMessage("My Files"),
        "myFolders": MessageLookupByLibrary.simpleMessage("My Folders"),
        "noFilesInCategory":
            MessageLookupByLibrary.simpleMessage("No files in this category."),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "numberOfFiles":
            MessageLookupByLibrary.simpleMessage("Number of files:"),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordMin": MessageLookupByLibrary.simpleMessage(
            "Password must be at least 6 characters"),
        "passwordsDoNotMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
        "privacySecurity":
            MessageLookupByLibrary.simpleMessage("Privacy & Security"),
        "privacySettings":
            MessageLookupByLibrary.simpleMessage("Privacy settings"),
        "recentFiles": MessageLookupByLibrary.simpleMessage("Recent Files"),
        "recentFolders": MessageLookupByLibrary.simpleMessage("Recent Folders"),
        "resendCode": MessageLookupByLibrary.simpleMessage("Resend Code"),
        "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Search anything here"),
        "seeAll": MessageLookupByLibrary.simpleMessage("See all"),
        "sendCode": MessageLookupByLibrary.simpleMessage("Send Code"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "shared": MessageLookupByLibrary.simpleMessage("Shared"),
        "sharedFiles": MessageLookupByLibrary.simpleMessage("Shared Files"),
        "sharedFilesContent": MessageLookupByLibrary.simpleMessage(
            "Shared files content will be here"),
        "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
        "signInWith": MessageLookupByLibrary.simpleMessage("Sign in with"),
        "signOut":
            MessageLookupByLibrary.simpleMessage("Sign out from your account"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "signUpWith": MessageLookupByLibrary.simpleMessage("Sign up with"),
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
        "type": MessageLookupByLibrary.simpleMessage("Type"),
        "updated": MessageLookupByLibrary.simpleMessage("Updated"),
        "upload_success":
            MessageLookupByLibrary.simpleMessage("File uploaded successfully"),
        "used": MessageLookupByLibrary.simpleMessage("Used"),
        "usedStorage": MessageLookupByLibrary.simpleMessage("Used storage:"),
        "usedStorageValue": MessageLookupByLibrary.simpleMessage("149.5 GB"),
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
        "verify": MessageLookupByLibrary.simpleMessage("Verify"),
        "verifyCodeTitle": MessageLookupByLibrary.simpleMessage("Verify Code"),
        "videos": MessageLookupByLibrary.simpleMessage("Videos"),
        "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday")
      };
}
