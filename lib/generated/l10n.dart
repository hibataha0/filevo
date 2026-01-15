// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flievo`
  String get appTitle {
    return Intl.message('Flievo', name: 'appTitle', desc: '', args: []);
  }

  /// `Login to your account`
  String get loginSubtitle {
    return Intl.message(
      'Login to your account',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Username or Email`
  String get usernameOrEmail {
    return Intl.message(
      'Username or Email',
      name: 'usernameOrEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message('Sign In', name: 'signIn', desc: '', args: []);
  }

  /// `Sign in with`
  String get signInWith {
    return Intl.message('Sign in with', name: 'signInWith', desc: '', args: []);
  }

  /// `Don't have an account? `
  String get dontHaveAccount {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'dontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
  }

  /// `Login successful!`
  String get loginSuccessful {
    return Intl.message(
      'Login successful!',
      name: 'loginSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Invalid credentials`
  String get invalidCredentials {
    return Intl.message(
      'Invalid credentials',
      name: 'invalidCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Create account`
  String get createAccount {
    return Intl.message(
      'Create account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Mobile`
  String get mobile {
    return Intl.message('Mobile', name: 'mobile', desc: '', args: []);
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Sign up with`
  String get signUpWith {
    return Intl.message('Sign up with', name: 'signUpWith', desc: '', args: []);
  }

  /// `Already have an account? `
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account? ',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get logIn {
    return Intl.message('Log In', name: 'logIn', desc: '', args: []);
  }

  /// `Account created successfully!`
  String get accountCreatedSuccessfully {
    return Intl.message(
      'Account created successfully!',
      name: 'accountCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your username or email`
  String get enterUsernameOrEmail {
    return Intl.message(
      'Please enter your username or email',
      name: 'enterUsernameOrEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get invalidEmail {
    return Intl.message(
      'Please enter a valid email address',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your username`
  String get enterUsername {
    return Intl.message(
      'Please enter your username',
      name: 'enterUsername',
      desc: '',
      args: [],
    );
  }

  /// `Username must be at least 3 characters`
  String get usernameMin {
    return Intl.message(
      'Username must be at least 3 characters',
      name: 'usernameMin',
      desc: '',
      args: [],
    );
  }

  /// `Username cannot exceed 20 characters`
  String get usernameMax {
    return Intl.message(
      'Username cannot exceed 20 characters',
      name: 'usernameMax',
      desc: '',
      args: [],
    );
  }

  /// `Username can only contain letters, numbers and underscore`
  String get usernameAllowedChars {
    return Intl.message(
      'Username can only contain letters, numbers and underscore',
      name: 'usernameAllowedChars',
      desc: '',
      args: [],
    );
  }

  /// `Enter password`
  String get enterPassword {
    return Intl.message(
      'Enter password',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordMin {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordMin',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password`
  String get enterConfirmPassword {
    return Intl.message(
      'Please confirm your password',
      name: 'enterConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone number`
  String get enterPhone {
    return Intl.message(
      'Please enter your phone number',
      name: 'enterPhone',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number (10-15 digits)`
  String get invalidPhone {
    return Intl.message(
      'Please enter a valid phone number (10-15 digits)',
      name: 'invalidPhone',
      desc: '',
      args: [],
    );
  }

  /// `Recent Folders`
  String get recentFolders {
    return Intl.message(
      'Recent Folders',
      name: 'recentFolders',
      desc: '',
      args: [],
    );
  }

  /// `See all`
  String get seeAll {
    return Intl.message('See all', name: 'seeAll', desc: '', args: []);
  }

  /// `Recent Files`
  String get recentFiles {
    return Intl.message(
      'Recent Files',
      name: 'recentFiles',
      desc: '',
      args: [],
    );
  }

  /// `Used`
  String get storageUsed {
    return Intl.message('Used', name: 'storageUsed', desc: '', args: []);
  }

  /// `60%`
  String get storageUsedValue {
    return Intl.message('60%', name: 'storageUsedValue', desc: '', args: []);
  }

  /// `Free Internal`
  String get freeInternal {
    return Intl.message(
      'Free Internal',
      name: 'freeInternal',
      desc: '',
      args: [],
    );
  }

  /// `120.5 GB`
  String get freeInternalValue {
    return Intl.message(
      '120.5 GB',
      name: 'freeInternalValue',
      desc: '',
      args: [],
    );
  }

  /// `149.5 GB`
  String get usedStorageValue {
    return Intl.message(
      '149.5 GB',
      name: 'usedStorageValue',
      desc: '',
      args: [],
    );
  }

  /// `Search... (e.g., photos from last week)`
  String get searchHint {
    return Intl.message(
      'Search... (e.g., photos from last week)',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Search by tag (e.g., project, important)`
  String get searchByTagsHint {
    return Intl.message(
      'Search by tag (e.g., project, important)',
      name: 'searchByTagsHint',
      desc: '',
      args: [],
    );
  }

  /// `Switch to tag search`
  String get switchToTagSearch {
    return Intl.message(
      'Switch to tag search',
      name: 'switchToTagSearch',
      desc: '',
      args: [],
    );
  }

  /// `Switch to text search`
  String get switchToTextSearch {
    return Intl.message(
      'Switch to text search',
      name: 'switchToTextSearch',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `My Files`
  String get myFiles {
    return Intl.message('My Files', name: 'myFiles', desc: '', args: []);
  }

  /// `Shared`
  String get shared {
    return Intl.message('Shared', name: 'shared', desc: '', args: []);
  }

  /// `All Items`
  String get allItems {
    return Intl.message('All Items', name: 'allItems', desc: '', args: []);
  }

  /// `My Folders`
  String get myFolders {
    return Intl.message('My Folders', name: 'myFolders', desc: '', args: []);
  }

  /// `Shared Files`
  String get sharedFiles {
    return Intl.message(
      'Shared Files',
      name: 'sharedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Shared files content will be here`
  String get sharedFilesContent {
    return Intl.message(
      'Shared files content will be here',
      name: 'sharedFilesContent',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `Images`
  String get images {
    return Intl.message('Images', name: 'images', desc: '', args: []);
  }

  /// `Videos`
  String get videos {
    return Intl.message('Videos', name: 'videos', desc: '', args: []);
  }

  /// `Audio`
  String get audio {
    return Intl.message('Audio', name: 'audio', desc: '', args: []);
  }

  /// `Compressed`
  String get compressed {
    return Intl.message('Compressed', name: 'compressed', desc: '', args: []);
  }

  /// `Applications`
  String get applications {
    return Intl.message(
      'Applications',
      name: 'applications',
      desc: '',
      args: [],
    );
  }

  /// `Documents`
  String get documents {
    return Intl.message('Documents', name: 'documents', desc: '', args: []);
  }

  /// `Code`
  String get code {
    return Intl.message('Code', name: 'code', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `Type`
  String get type {
    return Intl.message('Type', name: 'type', desc: '', args: []);
  }

  /// `Time & Date`
  String get timeAndDate {
    return Intl.message('Time & Date', name: 'timeAndDate', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `Last 7 days`
  String get last7Days {
    return Intl.message('Last 7 days', name: 'last7Days', desc: '', args: []);
  }

  /// `Last 30 days`
  String get last30Days {
    return Intl.message('Last 30 days', name: 'last30Days', desc: '', args: []);
  }

  /// `Last year`
  String get lastYear {
    return Intl.message('Last year', name: 'lastYear', desc: '', args: []);
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Used storage:`
  String get usedStorage {
    return Intl.message(
      'Used storage:',
      name: 'usedStorage',
      desc: '',
      args: [],
    );
  }

  /// `Storage Overview`
  String get storageOverview {
    return Intl.message(
      'Storage Overview',
      name: 'storageOverview',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Choose Language`
  String get chooseLanguage {
    return Intl.message(
      'Choose Language',
      name: 'chooseLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `General Settings`
  String get generalSettings {
    return Intl.message(
      'General Settings',
      name: 'generalSettings',
      desc: '',
      args: [],
    );
  }

  /// `Basic app settings`
  String get basicAppSettings {
    return Intl.message(
      'Basic app settings',
      name: 'basicAppSettings',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Switch between themes`
  String get switchThemes {
    return Intl.message(
      'Switch between themes',
      name: 'switchThemes',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Preferences`
  String get preferences {
    return Intl.message('Preferences', name: 'preferences', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Manage notifications`
  String get manageNotifications {
    return Intl.message(
      'Manage notifications',
      name: 'manageNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get storage {
    return Intl.message('Storage', name: 'storage', desc: '', args: []);
  }

  /// `Manage storage settings`
  String get manageStorageSettings {
    return Intl.message(
      'Manage storage settings',
      name: 'manageStorageSettings',
      desc: '',
      args: [],
    );
  }

  /// `Privacy & Security`
  String get privacySecurity {
    return Intl.message(
      'Privacy & Security',
      name: 'privacySecurity',
      desc: '',
      args: [],
    );
  }

  /// `Privacy settings`
  String get privacySettings {
    return Intl.message(
      'Privacy settings',
      name: 'privacySettings',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Legal & Policies`
  String get legalPolicies {
    return Intl.message(
      'Legal & Policies',
      name: 'legalPolicies',
      desc: '',
      args: [],
    );
  }

  /// `Terms of service & privacy policy`
  String get termsPrivacyPolicy {
    return Intl.message(
      'Terms of service & privacy policy',
      name: 'termsPrivacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Help & Support`
  String get helpSupport {
    return Intl.message(
      'Help & Support',
      name: 'helpSupport',
      desc: '',
      args: [],
    );
  }

  /// `Get help and support`
  String get getHelpSupport {
    return Intl.message(
      'Get help and support',
      name: 'getHelpSupport',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `App version {version}`
  String appVersion(Object version) {
    return Intl.message(
      'App version $version',
      name: 'appVersion',
      desc: '',
      args: [version],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Sign out from your account`
  String get signOut {
    return Intl.message(
      'Sign out from your account',
      name: 'signOut',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get forgotPasswordTitle {
    return Intl.message(
      'Forgot your password?',
      name: 'forgotPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address and we'll send you a code to reset your password.`
  String get forgotPasswordSubtitle {
    return Intl.message(
      'Enter your email address and we\'ll send you a code to reset your password.',
      name: 'forgotPasswordSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Send Code`
  String get sendCode {
    return Intl.message('Send Code', name: 'sendCode', desc: '', args: []);
  }

  /// `Please enter your email`
  String get enterEmail {
    return Intl.message(
      'Please enter your email',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get validEmail {
    return Intl.message(
      'Please enter a valid email',
      name: 'validEmail',
      desc: '',
      args: [],
    );
  }

  /// `Code sent successfully`
  String get codeSent {
    return Intl.message(
      'Code sent successfully',
      name: 'codeSent',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send code`
  String get failedSendCode {
    return Intl.message(
      'Failed to send code',
      name: 'failedSendCode',
      desc: '',
      args: [],
    );
  }

  /// `Back to Login`
  String get backToLogin {
    return Intl.message(
      'Back to Login',
      name: 'backToLogin',
      desc: '',
      args: [],
    );
  }

  /// `Verify Code`
  String get verifyCodeTitle {
    return Intl.message(
      'Verify Code',
      name: 'verifyCodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a 6-digit code`
  String get enter6DigitCode {
    return Intl.message(
      'Please enter a 6-digit code',
      name: 'enter6DigitCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter the 6-digit code sent to {email}`
  String enterCodeToEmail(Object email) {
    return Intl.message(
      'Enter the 6-digit code sent to $email',
      name: 'enterCodeToEmail',
      desc: '',
      args: [email],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `Resend Code`
  String get resendCode {
    return Intl.message('Resend Code', name: 'resendCode', desc: '', args: []);
  }

  /// `Code verified successfully`
  String get codeVerified {
    return Intl.message(
      'Code verified successfully',
      name: 'codeVerified',
      desc: '',
      args: [],
    );
  }

  /// `The code is invalid or has expired`
  String get invalidOrExpiredCode {
    return Intl.message(
      'The code is invalid or has expired',
      name: 'invalidOrExpiredCode',
      desc: '',
      args: [],
    );
  }

  /// `Code resent successfully`
  String get codeResent {
    return Intl.message(
      'Code resent successfully',
      name: 'codeResent',
      desc: '',
      args: [],
    );
  }

  /// `Failed to resend code`
  String get failedResendCode {
    return Intl.message(
      'Failed to resend code',
      name: 'failedResendCode',
      desc: '',
      args: [],
    );
  }

  /// `You must log in first`
  String get mustLogin {
    return Intl.message(
      'You must log in first',
      name: 'mustLogin',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching data`
  String get errorFetchingData {
    return Intl.message(
      'Error fetching data',
      name: 'errorFetchingData',
      desc: '',
      args: [],
    );
  }

  /// `You must log in to access the files`
  String get loginRequiredToAccessFiles {
    return Intl.message(
      'You must log in to access the files',
      name: 'loginRequiredToAccessFiles',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `No files in this category.`
  String get noFilesInCategory {
    return Intl.message(
      'No files in this category.',
      name: 'noFilesInCategory',
      desc: '',
      args: [],
    );
  }

  /// `Updated`
  String get updated {
    return Intl.message('Updated', name: 'updated', desc: '', args: []);
  }

  /// `Number of files:`
  String get numberOfFiles {
    return Intl.message(
      'Number of files:',
      name: 'numberOfFiles',
      desc: '',
      args: [],
    );
  }

  /// `File uploaded successfully`
  String get upload_success {
    return Intl.message(
      'File uploaded successfully',
      name: 'upload_success',
      desc: '',
      args: [],
    );
  }

  /// `Create Folder`
  String get createFolder {
    return Intl.message(
      'Create Folder',
      name: 'createFolder',
      desc: '',
      args: [],
    );
  }

  /// `Enter folder name`
  String get folderNameHint {
    return Intl.message(
      'Enter folder name',
      name: 'folderNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter folder name`
  String get enterFolderName {
    return Intl.message(
      'Please enter folder name',
      name: 'enterFolderName',
      desc: '',
      args: [],
    );
  }

  /// `File ID not available`
  String get fileIdNotAvailable {
    return Intl.message(
      'File ID not available',
      name: 'fileIdNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `You have already accessed this file. One-time share only.`
  String get fileAlreadyAccessed {
    return Intl.message(
      'You have already accessed this file. One-time share only.',
      name: 'fileAlreadyAccessed',
      desc: '',
      args: [],
    );
  }

  /// `This file is shared for one time - your access has been recorded`
  String get oneTimeShareAccessRecorded {
    return Intl.message(
      'This file is shared for one time - your access has been recorded',
      name: 'oneTimeShareAccessRecorded',
      desc: '',
      args: [],
    );
  }

  /// `Cannot access file`
  String get cannotAccessFile {
    return Intl.message(
      'Cannot access file',
      name: 'cannotAccessFile',
      desc: '',
      args: [],
    );
  }

  /// `Error accessing file`
  String get errorAccessingFile {
    return Intl.message(
      'Error accessing file',
      name: 'errorAccessingFile',
      desc: '',
      args: [],
    );
  }

  /// `File URL not available`
  String get fileUrlNotAvailable {
    return Intl.message(
      'File URL not available',
      name: 'fileUrlNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Invalid URL`
  String get invalidUrl {
    return Intl.message('Invalid URL', name: 'invalidUrl', desc: '', args: []);
  }

  /// `Unsupported File`
  String get unsupportedFile {
    return Intl.message(
      'Unsupported File',
      name: 'unsupportedFile',
      desc: '',
      args: [],
    );
  }

  /// `The file is too small or corrupted`
  String get invalidPdfFile {
    return Intl.message(
      'The file is too small or corrupted',
      name: 'invalidPdfFile',
      desc: '',
      args: [],
    );
  }

  /// `Open as Text`
  String get openAsText {
    return Intl.message('Open as Text', name: 'openAsText', desc: '', args: []);
  }

  /// `Share File with Room`
  String get shareFileWithRoom {
    return Intl.message(
      'Share File with Room',
      name: 'shareFileWithRoom',
      desc: '',
      args: [],
    );
  }

  /// `Choose a room to share this file`
  String get chooseRoomToShare {
    return Intl.message(
      'Choose a room to share this file',
      name: 'chooseRoomToShare',
      desc: '',
      args: [],
    );
  }

  /// `No rooms available`
  String get noRoomsAvailable {
    return Intl.message(
      'No rooms available',
      name: 'noRoomsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Create a room first to share`
  String get createRoomFirst {
    return Intl.message(
      'Create a room first to share',
      name: 'createRoomFirst',
      desc: '',
      args: [],
    );
  }

  /// `One-time Share`
  String get oneTimeShare {
    return Intl.message(
      'One-time Share',
      name: 'oneTimeShare',
      desc: '',
      args: [],
    );
  }

  /// `Each user can open the file only once`
  String get oneTimeShareDescription {
    return Intl.message(
      'Each user can open the file only once',
      name: 'oneTimeShareDescription',
      desc: '',
      args: [],
    );
  }

  /// `Expires in {hours} hours`
  String expiresInHours(Object hours) {
    return Intl.message(
      'Expires in $hours hours',
      name: 'expiresInHours',
      desc: '',
      args: [hours],
    );
  }

  /// `Enter number of hours`
  String get enterHours {
    return Intl.message(
      'Enter number of hours',
      name: 'enterHours',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `ℹ️ File is already shared with this room`
  String get fileAlreadyShared {
    return Intl.message(
      'ℹ️ File is already shared with this room',
      name: 'fileAlreadyShared',
      desc: '',
      args: [],
    );
  }

  /// `Room Details`
  String get roomDetails {
    return Intl.message(
      'Room Details',
      name: 'roomDetails',
      desc: '',
      args: [],
    );
  }

  /// `Only room owner can delete it`
  String get onlyOwnerCanDelete {
    return Intl.message(
      'Only room owner can delete it',
      name: 'onlyOwnerCanDelete',
      desc: '',
      args: [],
    );
  }

  /// `Room owner cannot leave. Please delete the room instead`
  String get ownerCannotLeave {
    return Intl.message(
      'Room owner cannot leave. Please delete the room instead',
      name: 'ownerCannotLeave',
      desc: '',
      args: [],
    );
  }

  /// `Delete Room`
  String get deleteRoom {
    return Intl.message('Delete Room', name: 'deleteRoom', desc: '', args: []);
  }

  /// `Leave Room`
  String get leaveRoom {
    return Intl.message('Leave Room', name: 'leaveRoom', desc: '', args: []);
  }

  /// `Room Name`
  String get roomName {
    return Intl.message('Room Name', name: 'roomName', desc: '', args: []);
  }

  /// `No name`
  String get roomNamePlaceholder {
    return Intl.message(
      'No name',
      name: 'roomNamePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Leave`
  String get leave {
    return Intl.message('Leave', name: 'leave', desc: '', args: []);
  }

  /// `Owner`
  String get owner {
    return Intl.message('Owner', name: 'owner', desc: '', args: []);
  }

  /// `Members`
  String get members {
    return Intl.message('Members', name: 'members', desc: '', args: []);
  }

  /// `Files`
  String get files {
    return Intl.message('Files', name: 'files', desc: '', args: []);
  }

  /// `Folders`
  String get folders {
    return Intl.message('Folders', name: 'folders', desc: '', args: []);
  }

  /// `Send Invitation`
  String get sendInvitation {
    return Intl.message(
      'Send Invitation',
      name: 'sendInvitation',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get comments {
    return Intl.message('Comments', name: 'comments', desc: '', args: []);
  }

  /// `Room Info`
  String get roomInfo {
    return Intl.message('Room Info', name: 'roomInfo', desc: '', args: []);
  }

  /// `Created at`
  String get createdAt {
    return Intl.message('Created at', name: 'createdAt', desc: '', args: []);
  }

  /// `Last modified`
  String get lastModified {
    return Intl.message(
      'Last modified',
      name: 'lastModified',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message('View All', name: 'viewAll', desc: '', args: []);
  }

  /// `No members`
  String get noMembers {
    return Intl.message('No members', name: 'noMembers', desc: '', args: []);
  }

  /// `Shared Files ({count})`
  String sharedFilesCount(Object count) {
    return Intl.message(
      'Shared Files ($count)',
      name: 'sharedFilesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Add File`
  String get addFile {
    return Intl.message('Add File', name: 'addFile', desc: '', args: []);
  }

  /// `Add File to Room`
  String get addFileToRoom {
    return Intl.message(
      'Add File to Room',
      name: 'addFileToRoom',
      desc: '',
      args: [],
    );
  }

  /// `Add Folder`
  String get addFolder {
    return Intl.message('Add Folder', name: 'addFolder', desc: '', args: []);
  }

  /// `Add Folder to Room`
  String get addFolderToRoom {
    return Intl.message(
      'Add Folder to Room',
      name: 'addFolderToRoom',
      desc: '',
      args: [],
    );
  }

  /// `Select Folder`
  String selectFolder(String folderName) {
    return Intl.message(
      'Select Folder',
      name: 'selectFolder',
      desc: '',
      args: [folderName],
    );
  }

  /// `No folders available. Please create one first.`
  String get noFoldersAvailable {
    return Intl.message(
      'No folders available. Please create one first.',
      name: 'noFoldersAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No subfolders`
  String get noSubfolders {
    return Intl.message(
      'No subfolders',
      name: 'noSubfolders',
      desc: '',
      args: [],
    );
  }

  /// `Error loading subfolders`
  String get errorLoadingSubfolders {
    return Intl.message(
      'Error loading subfolders',
      name: 'errorLoadingSubfolders',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `View Details`
  String get viewDetails {
    return Intl.message(
      'View Details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Remove from Favorites`
  String get removeFromFavorites {
    return Intl.message(
      'Remove from Favorites',
      name: 'removeFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Add to Favorites`
  String get addToFavorites {
    return Intl.message(
      'Add to Favorites',
      name: 'addToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Remove from Room`
  String get removeFromRoom {
    return Intl.message(
      'Remove from Room',
      name: 'removeFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `View Info`
  String get viewInfo {
    return Intl.message('View Info', name: 'viewInfo', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Move`
  String get move {
    return Intl.message('Move', name: 'move', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Save to My Account`
  String get saveToMyAccount {
    return Intl.message(
      'Save to My Account',
      name: 'saveToMyAccount',
      desc: '',
      args: [],
    );
  }

  /// `Cannot add shared files in room to favorites`
  String get cannotAddSharedFilesToFavorites {
    return Intl.message(
      'Cannot add shared files in room to favorites',
      name: 'cannotAddSharedFilesToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `No name`
  String get noName {
    return Intl.message('No name', name: 'noName', desc: '', args: []);
  }

  /// `File without name`
  String get fileWithoutName {
    return Intl.message(
      'File without name',
      name: 'fileWithoutName',
      desc: '',
      args: [],
    );
  }

  /// `No recent folders`
  String get noRecentFolders {
    return Intl.message(
      'No recent folders',
      name: 'noRecentFolders',
      desc: '',
      args: [],
    );
  }

  /// `No recent files`
  String get noRecentFiles {
    return Intl.message(
      'No recent files',
      name: 'noRecentFiles',
      desc: '',
      args: [],
    );
  }

  /// `Folder`
  String get folder {
    return Intl.message('Folder', name: 'folder', desc: '', args: []);
  }

  /// `No items`
  String get noItems {
    return Intl.message('No items', name: 'noItems', desc: '', args: []);
  }

  /// `One item`
  String get oneItem {
    return Intl.message('One item', name: 'oneItem', desc: '', args: []);
  }

  /// `item`
  String get item {
    return Intl.message('item', name: 'item', desc: '', args: []);
  }

  /// `items`
  String get items {
    return Intl.message('items', name: 'items', desc: '', args: []);
  }

  /// `File saved successfully`
  String get fileSavedSuccessfully {
    return Intl.message(
      'File saved successfully',
      name: 'fileSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `File saved and uploaded successfully`
  String get fileSavedAndUploaded {
    return Intl.message(
      'File saved and uploaded successfully',
      name: 'fileSavedAndUploaded',
      desc: '',
      args: [],
    );
  }

  /// `Saved locally, {errorMessage}`
  String fileSavedLocallyOnly(Object errorMessage) {
    return Intl.message(
      'Saved locally, $errorMessage',
      name: 'fileSavedLocallyOnly',
      desc: '',
      args: [errorMessage],
    );
  }

  /// `Failed to save file`
  String get failedToSaveFile {
    return Intl.message(
      'Failed to save file',
      name: 'failedToSaveFile',
      desc: '',
      args: [],
    );
  }

  /// `Unsaved Changes`
  String get unsavedChanges {
    return Intl.message(
      'Unsaved Changes',
      name: 'unsavedChanges',
      desc: '',
      args: [],
    );
  }

  /// `You have unsaved changes. Are you sure you want to exit?`
  String get unsavedChangesMessage {
    return Intl.message(
      'You have unsaved changes. Are you sure you want to exit?',
      name: 'unsavedChangesMessage',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `Copy Content`
  String get copyContent {
    return Intl.message(
      'Copy Content',
      name: 'copyContent',
      desc: '',
      args: [],
    );
  }

  /// `Access token not found`
  String get accessTokenNotFound {
    return Intl.message(
      'Access token not found',
      name: 'accessTokenNotFound',
      desc: '',
      args: [],
    );
  }

  /// `File is empty`
  String get fileIsEmpty {
    return Intl.message(
      'File is empty',
      name: 'fileIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Loading file data...`
  String get loadingFileData {
    return Intl.message(
      'Loading file data...',
      name: 'loadingFileData',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load file data`
  String get failedToLoadFileData {
    return Intl.message(
      'Failed to load file data',
      name: 'failedToLoadFileData',
      desc: '',
      args: [],
    );
  }

  /// `File Information`
  String get fileInfo {
    return Intl.message(
      'File Information',
      name: 'fileInfo',
      desc: '',
      args: [],
    );
  }

  /// `Extension`
  String get extension {
    return Intl.message('Extension', name: 'extension', desc: '', args: []);
  }

  /// `Size`
  String get size {
    return Intl.message('Size', name: 'size', desc: '', args: []);
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Tags`
  String get tags {
    return Intl.message('Tags', name: 'tags', desc: '', args: []);
  }

  /// `Share with Room`
  String get shareWithRoom {
    return Intl.message(
      'Share with Room',
      name: 'shareWithRoom',
      desc: '',
      args: [],
    );
  }

  /// `Share feature coming soon`
  String get shareFeatureComingSoon {
    return Intl.message(
      'Share feature coming soon',
      name: 'shareFeatureComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message('Image', name: 'image', desc: '', args: []);
  }

  /// `Video`
  String get video {
    return Intl.message('Video', name: 'video', desc: '', args: []);
  }

  /// `Document`
  String get document {
    return Intl.message('Document', name: 'document', desc: '', args: []);
  }

  /// `Unclassified`
  String get unclassified {
    return Intl.message(
      'Unclassified',
      name: 'unclassified',
      desc: '',
      args: [],
    );
  }

  /// `Extracting text from PDF...`
  String get extractingTextFromPdf {
    return Intl.message(
      'Extracting text from PDF...',
      name: 'extractingTextFromPdf',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String error(String error) {
    return Intl.message(
      'Error: $error',
      name: 'error',
      desc: '',
      args: [error],
    );
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `You are the owner`
  String get youAreOwner {
    return Intl.message(
      'You are the owner',
      name: 'youAreOwner',
      desc: '',
      args: [],
    );
  }

  /// `Shared file`
  String get sharedFile {
    return Intl.message('Shared file', name: 'sharedFile', desc: '', args: []);
  }

  /// `Unshare File`
  String get unshareFile {
    return Intl.message(
      'Unshare File',
      name: 'unshareFile',
      desc: '',
      args: [],
    );
  }

  /// `Unshare`
  String get unshare {
    return Intl.message('Unshare', name: 'unshare', desc: '', args: []);
  }

  /// `You must login first`
  String get mustLoginFirst {
    return Intl.message(
      'You must login first',
      name: 'mustLoginFirst',
      desc: '',
      args: [],
    );
  }

  /// `Edit File`
  String get editFile {
    return Intl.message('Edit File', name: 'editFile', desc: '', args: []);
  }

  /// `Edit Image`
  String get editImage {
    return Intl.message('Edit Image', name: 'editImage', desc: '', args: []);
  }

  /// `Open Image Editor`
  String get openImageEditor {
    return Intl.message(
      'Open Image Editor',
      name: 'openImageEditor',
      desc: '',
      args: [],
    );
  }

  /// `Image edited`
  String get imageEdited {
    return Intl.message(
      'Image edited',
      name: 'imageEdited',
      desc: '',
      args: [],
    );
  }

  /// `Reload Original Image`
  String get reloadOriginalImage {
    return Intl.message(
      'Reload Original Image',
      name: 'reloadOriginalImage',
      desc: '',
      args: [],
    );
  }

  /// `Edit Text`
  String get editText {
    return Intl.message('Edit Text', name: 'editText', desc: '', args: []);
  }

  /// `Open Text Editor`
  String get openTextEditor {
    return Intl.message(
      'Open Text Editor',
      name: 'openTextEditor',
      desc: '',
      args: [],
    );
  }

  /// `Text edited`
  String get textEdited {
    return Intl.message('Text edited', name: 'textEdited', desc: '', args: []);
  }

  /// `Failed to load image`
  String get failedToLoadImage {
    return Intl.message(
      'Failed to load image',
      name: 'failedToLoadImage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save temporary image`
  String get failedToSaveTempImage {
    return Intl.message(
      'Failed to save temporary image',
      name: 'failedToSaveTempImage',
      desc: '',
      args: [],
    );
  }

  /// `Loaded image is empty`
  String get loadedImageIsEmpty {
    return Intl.message(
      'Loaded image is empty',
      name: 'loadedImageIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Error verifying image: {error}`
  String errorVerifyingImage(String error) {
    return Intl.message(
      'Error verifying image: $error',
      name: 'errorVerifyingImage',
      desc: '',
      args: [error],
    );
  }

  /// `Loading video...`
  String get loadingVideo {
    return Intl.message(
      'Loading video...',
      name: 'loadingVideo',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load video ({statusCode})`
  String failedToLoadVideo(int statusCode) {
    return Intl.message(
      'Failed to load video ($statusCode)',
      name: 'failedToLoadVideo',
      desc: '',
      args: [statusCode],
    );
  }

  /// `Failed to save temporary video`
  String get failedToSaveTempVideo {
    return Intl.message(
      'Failed to save temporary video',
      name: 'failedToSaveTempVideo',
      desc: '',
      args: [],
    );
  }

  /// `Loaded video is empty`
  String get loadedVideoIsEmpty {
    return Intl.message(
      'Loaded video is empty',
      name: 'loadedVideoIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Error verifying video: {error}`
  String errorVerifyingVideo(String error) {
    return Intl.message(
      'Error verifying video: $error',
      name: 'errorVerifyingVideo',
      desc: '',
      args: [error],
    );
  }

  /// `Extracting image...`
  String get extractingImage {
    return Intl.message(
      'Extracting image...',
      name: 'extractingImage',
      desc: '',
      args: [],
    );
  }

  /// `Image extracted`
  String get imageExtracted {
    return Intl.message(
      'Image extracted',
      name: 'imageExtracted',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to save this image?`
  String get saveThisImage {
    return Intl.message(
      'Do you want to save this image?',
      name: 'saveThisImage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to extract image`
  String get failedToExtractImage {
    return Intl.message(
      'Failed to extract image',
      name: 'failedToExtractImage',
      desc: '',
      args: [],
    );
  }

  /// `Merging videos... This may take some time`
  String get mergingVideos {
    return Intl.message(
      'Merging videos... This may take some time',
      name: 'mergingVideos',
      desc: '',
      args: [],
    );
  }

  /// `Failed to merge videos`
  String get failedToMergeVideos {
    return Intl.message(
      'Failed to merge videos',
      name: 'failedToMergeVideos',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load audio file ({statusCode})`
  String failedToLoadAudio(int statusCode) {
    return Intl.message(
      'Failed to load audio file ($statusCode)',
      name: 'failedToLoadAudio',
      desc: '',
      args: [statusCode],
    );
  }

  /// `Failed to save temporary audio file`
  String get failedToSaveTempAudio {
    return Intl.message(
      'Failed to save temporary audio file',
      name: 'failedToSaveTempAudio',
      desc: '',
      args: [],
    );
  }

  /// `Loaded audio file is empty`
  String get loadedAudioIsEmpty {
    return Intl.message(
      'Loaded audio file is empty',
      name: 'loadedAudioIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Start time must be before end time`
  String get startTimeMustBeBeforeEndTime {
    return Intl.message(
      'Start time must be before end time',
      name: 'startTimeMustBeBeforeEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load audio file`
  String get failedToLoadAudioFile {
    return Intl.message(
      'Failed to load audio file',
      name: 'failedToLoadAudioFile',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load base audio file`
  String get failedToLoadBaseAudio {
    return Intl.message(
      'Failed to load base audio file',
      name: 'failedToLoadBaseAudio',
      desc: '',
      args: [],
    );
  }

  /// `You must select at least two audio files to merge`
  String get mustSelectAtLeastTwoAudioFiles {
    return Intl.message(
      'You must select at least two audio files to merge',
      name: 'mustSelectAtLeastTwoAudioFiles',
      desc: '',
      args: [],
    );
  }

  /// `Merging audio files... This may take some time`
  String get mergingAudioFiles {
    return Intl.message(
      'Merging audio files... This may take some time',
      name: 'mergingAudioFiles',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load PDF file ({statusCode})`
  String pdfLoadFailed(int statusCode) {
    return Intl.message(
      'Failed to load PDF file ($statusCode)',
      name: 'pdfLoadFailed',
      desc: '',
      args: [statusCode],
    );
  }

  /// `Failed to load PDF file`
  String get failedToLoadPdf {
    return Intl.message(
      'Failed to load PDF file',
      name: 'failedToLoadPdf',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load file`
  String get failedToLoadFile {
    return Intl.message(
      'Failed to load file',
      name: 'failedToLoadFile',
      desc: '',
      args: [],
    );
  }

  /// `✅ Image edited successfully`
  String get imageEditedSuccessfully {
    return Intl.message(
      '✅ Image edited successfully',
      name: 'imageEditedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Edited image is empty`
  String get editedImageIsEmpty {
    return Intl.message(
      '⚠️ Edited image is empty',
      name: 'editedImageIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Failed to save edited image`
  String get failedToSaveEditedImage {
    return Intl.message(
      '⚠️ Failed to save edited image',
      name: 'failedToSaveEditedImage',
      desc: '',
      args: [],
    );
  }

  /// `✅ Text edited successfully. Press "Save Changes" to upload to server`
  String get textEditedSuccessfully {
    return Intl.message(
      '✅ Text edited successfully. Press "Save Changes" to upload to server',
      name: 'textEditedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Save Options`
  String get saveOptions {
    return Intl.message(
      'Save Options',
      name: 'saveOptions',
      desc: '',
      args: [],
    );
  }

  /// `How do you want to save the edited image?\n\n• Save new copy: The edited image will be saved as a new file\n• Replace old version: The old file will be deleted and replaced with the edited image`
  String get saveOptionsDescription {
    return Intl.message(
      'How do you want to save the edited image?\n\n• Save new copy: The edited image will be saved as a new file\n• Replace old version: The old file will be deleted and replaced with the edited image',
      name: 'saveOptionsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Save new copy`
  String get saveNewCopy {
    return Intl.message(
      'Save new copy',
      name: 'saveNewCopy',
      desc: '',
      args: [],
    );
  }

  /// `Replace old version`
  String get replaceOldVersion {
    return Intl.message(
      'Replace old version',
      name: 'replaceOldVersion',
      desc: '',
      args: [],
    );
  }

  /// `Extract`
  String get extract {
    return Intl.message('Extract', name: 'extract', desc: '', args: []);
  }

  /// `Trim Audio`
  String get trimAudio {
    return Intl.message('Trim Audio', name: 'trimAudio', desc: '', args: []);
  }

  /// `Total duration: {duration}`
  String totalDuration(String duration) {
    return Intl.message(
      'Total duration: $duration',
      name: 'totalDuration',
      desc: '',
      args: [duration],
    );
  }

  /// `Trim`
  String get trim {
    return Intl.message('Trim', name: 'trim', desc: '', args: []);
  }

  /// `Adjust Volume`
  String get adjustVolume {
    return Intl.message(
      'Adjust Volume',
      name: 'adjustVolume',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Convert Format`
  String get convertFormat {
    return Intl.message(
      'Convert Format',
      name: 'convertFormat',
      desc: '',
      args: [],
    );
  }

  /// `Choose output format:`
  String get chooseOutputFormat {
    return Intl.message(
      'Choose output format:',
      name: 'chooseOutputFormat',
      desc: '',
      args: [],
    );
  }

  /// `WAV`
  String get wavFormat {
    return Intl.message('WAV', name: 'wavFormat', desc: '', args: []);
  }

  /// `High quality, large size`
  String get wavDescription {
    return Intl.message(
      'High quality, large size',
      name: 'wavDescription',
      desc: '',
      args: [],
    );
  }

  /// `MP3`
  String get mp3Format {
    return Intl.message('MP3', name: 'mp3Format', desc: '', args: []);
  }

  /// `Good quality, small size`
  String get mp3Description {
    return Intl.message(
      'Good quality, small size',
      name: 'mp3Description',
      desc: '',
      args: [],
    );
  }

  /// `AAC`
  String get aacFormat {
    return Intl.message('AAC', name: 'aacFormat', desc: '', args: []);
  }

  /// `Very good quality`
  String get aacDescription {
    return Intl.message(
      'Very good quality',
      name: 'aacDescription',
      desc: '',
      args: [],
    );
  }

  /// `Add Text (Annotation)`
  String get addTextAnnotation {
    return Intl.message(
      'Add Text (Annotation)',
      name: 'addTextAnnotation',
      desc: '',
      args: [],
    );
  }

  /// `Position X: {x}`
  String positionX(String x) {
    return Intl.message(
      'Position X: $x',
      name: 'positionX',
      desc: '',
      args: [x],
    );
  }

  /// `Position Y: {y}`
  String positionY(String y) {
    return Intl.message(
      'Position Y: $y',
      name: 'positionY',
      desc: '',
      args: [y],
    );
  }

  /// `Font size: {size}`
  String fontSize(String size) {
    return Intl.message(
      'Font size: $size',
      name: 'fontSize',
      desc: '',
      args: [size],
    );
  }

  /// `Page: {pageNumber}`
  String page(String pageNumber) {
    return Intl.message(
      'Page: $pageNumber',
      name: 'page',
      desc: '',
      args: [pageNumber],
    );
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Select Image Position`
  String get selectImagePosition {
    return Intl.message(
      'Select Image Position',
      name: 'selectImagePosition',
      desc: '',
      args: [],
    );
  }

  /// `Width: {width}`
  String width(String width) {
    return Intl.message(
      'Width: $width',
      name: 'width',
      desc: '',
      args: [width],
    );
  }

  /// `Height: {height}`
  String height(String height) {
    return Intl.message(
      'Height: $height',
      name: 'height',
      desc: '',
      args: [height],
    );
  }

  /// `Highlight Text`
  String get highlightText {
    return Intl.message(
      'Highlight Text',
      name: 'highlightText',
      desc: '',
      args: [],
    );
  }

  /// `Color:`
  String get color {
    return Intl.message('Color:', name: 'color', desc: '', args: []);
  }

  /// `Highlight`
  String get highlight {
    return Intl.message('Highlight', name: 'highlight', desc: '', args: []);
  }

  /// `✅ Video edited successfully`
  String get videoEditedSuccessfully {
    return Intl.message(
      '✅ Video edited successfully',
      name: 'videoEditedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Edited video is empty`
  String get editedVideoIsEmpty {
    return Intl.message(
      '⚠️ Edited video is empty',
      name: 'editedVideoIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Failed to save edited video`
  String get failedToSaveEditedVideo {
    return Intl.message(
      '⚠️ Failed to save edited video',
      name: 'failedToSaveEditedVideo',
      desc: '',
      args: [],
    );
  }

  /// `✅ Videos merged successfully`
  String get videoMergedSuccessfully {
    return Intl.message(
      '✅ Videos merged successfully',
      name: 'videoMergedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `✅ Text added successfully`
  String get textAddedSuccessfully {
    return Intl.message(
      '✅ Text added successfully',
      name: 'textAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `✅ Image added successfully`
  String get imageAddedSuccessfully {
    return Intl.message(
      '✅ Image added successfully',
      name: 'imageAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `✅ Text highlighted successfully`
  String get textHighlightedSuccessfully {
    return Intl.message(
      '✅ Text highlighted successfully',
      name: 'textHighlightedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `✅ File updated successfully`
  String get fileUpdatedSuccessfully {
    return Intl.message(
      '✅ File updated successfully',
      name: 'fileUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `✅ File replaced successfully`
  String get fileReplacedSuccessfully {
    return Intl.message(
      '✅ File replaced successfully',
      name: 'fileReplacedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `✅ New copy saved successfully`
  String get newCopySavedSuccessfully {
    return Intl.message(
      '✅ New copy saved successfully',
      name: 'newCopySavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Changes saved successfully`
  String get changesSavedSuccessfully {
    return Intl.message(
      'Changes saved successfully',
      name: 'changesSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String errorOccurred(String error) {
    return Intl.message(
      'An error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [error],
    );
  }

  /// `✅ Image extracted successfully`
  String get imageExtractedSuccessfully {
    return Intl.message(
      '✅ Image extracted successfully',
      name: 'imageExtractedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Edited file not found. Please edit again`
  String get editedFileNotFound {
    return Intl.message(
      'Edited file not found. Please edit again',
      name: 'editedFileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Error accessing edited file: {error}`
  String errorAccessingEditedFile(String error) {
    return Intl.message(
      'Error accessing edited file: $error',
      name: 'errorAccessingEditedFile',
      desc: '',
      args: [error],
    );
  }

  /// `Choose time to extract image`
  String get chooseTimeToExtractImage {
    return Intl.message(
      'Choose time to extract image',
      name: 'chooseTimeToExtractImage',
      desc: '',
      args: [],
    );
  }

  /// `Choose time in seconds:`
  String get chooseTimeInSeconds {
    return Intl.message(
      'Choose time in seconds:',
      name: 'chooseTimeInSeconds',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Edit File Metadata`
  String get editFileMetadata {
    return Intl.message(
      'Edit File Metadata',
      name: 'editFileMetadata',
      desc: '',
      args: [],
    );
  }

  /// `File Name`
  String get fileName {
    return Intl.message('File Name', name: 'fileName', desc: '', args: []);
  }

  /// `Description`
  String get fileDescription {
    return Intl.message(
      'Description',
      name: 'fileDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tags (separate by comma)`
  String get tagsSeparatedByComma {
    return Intl.message(
      'Tags (separate by comma)',
      name: 'tagsSeparatedByComma',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save changes`
  String get changesSaveFailed {
    return Intl.message(
      'Failed to save changes',
      name: 'changesSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete '{fileName}'?`
  String confirmDeleteFile(String fileName) {
    return Intl.message(
      'Are you sure you want to delete \'$fileName\'?',
      name: 'confirmDeleteFile',
      desc: '',
      args: [fileName],
    );
  }

  /// `No token available`
  String get noTokenError {
    return Intl.message(
      'No token available',
      name: 'noTokenError',
      desc: '',
      args: [],
    );
  }

  /// `File '{fileName}' deleted successfully`
  String fileDeletedSuccessfully(String fileName) {
    return Intl.message(
      'File \'$fileName\' deleted successfully',
      name: 'fileDeletedSuccessfully',
      desc: '',
      args: [fileName],
    );
  }

  /// `Error deleting file: {error}`
  String errorDeletingFile(String error) {
    return Intl.message(
      'Error deleting file: $error',
      name: 'errorDeletingFile',
      desc: '',
      args: [error],
    );
  }

  /// `No users to unshare with`
  String get noUsersSharedWith {
    return Intl.message(
      'No users to unshare with',
      name: 'noUsersSharedWith',
      desc: '',
      args: [],
    );
  }

  /// `Cannot identify users`
  String get cannotIdentifyUsers {
    return Intl.message(
      'Cannot identify users',
      name: 'cannotIdentifyUsers',
      desc: '',
      args: [],
    );
  }

  /// `File unshared successfully`
  String get unshareFileSuccess {
    return Intl.message(
      'File unshared successfully',
      name: 'unshareFileSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to unshare file`
  String get unshareFailed {
    return Intl.message(
      'Failed to unshare file',
      name: 'unshareFailed',
      desc: '',
      args: [],
    );
  }

  /// `File added to favorites`
  String get fileAddedToFavorites {
    return Intl.message(
      'File added to favorites',
      name: 'fileAddedToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `File removed from favorites`
  String get fileRemovedFromFavorites {
    return Intl.message(
      'File removed from favorites',
      name: 'fileRemovedFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update`
  String get errorUpdating {
    return Intl.message(
      'Failed to update',
      name: 'errorUpdating',
      desc: '',
      args: [],
    );
  }

  /// `Downloading file...`
  String get downloadingFile {
    return Intl.message(
      'Downloading file...',
      name: 'downloadingFile',
      desc: '',
      args: [],
    );
  }

  /// `File '{fileName}' downloaded successfully`
  String fileDownloadedSuccessfully(String fileName) {
    return Intl.message(
      'File \'$fileName\' downloaded successfully',
      name: 'fileDownloadedSuccessfully',
      desc: '',
      args: [fileName],
    );
  }

  /// `Failed to download file`
  String get failedToDownloadFile {
    return Intl.message(
      'Failed to download file',
      name: 'failedToDownloadFile',
      desc: '',
      args: [],
    );
  }

  /// `Error downloading file: {error}`
  String errorDownloadingFile(String error) {
    return Intl.message(
      'Error downloading file: $error',
      name: 'errorDownloadingFile',
      desc: '',
      args: [error],
    );
  }

  /// `Cannot identify file`
  String get cannotIdentifyFile {
    return Intl.message(
      'Cannot identify file',
      name: 'cannotIdentifyFile',
      desc: '',
      args: [],
    );
  }

  /// `Share request sent`
  String get shareRequestSent {
    return Intl.message(
      'Share request sent',
      name: 'shareRequestSent',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove sharing?`
  String get unshareFileConfirm {
    return Intl.message(
      'Are you sure you want to remove sharing?',
      name: 'unshareFileConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Updating...`
  String get updating {
    return Intl.message('Updating...', name: 'updating', desc: '', args: []);
  }

  /// `Delete File`
  String get deleteFile {
    return Intl.message('Delete File', name: 'deleteFile', desc: '', args: []);
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `You must login first`
  String get mustLoginFirstError {
    return Intl.message(
      'You must login first',
      name: 'mustLoginFirstError',
      desc: '',
      args: [],
    );
  }

  /// `Error loading file data: {error}`
  String errorLoadingFileData(String error) {
    return Intl.message(
      'Error loading file data: $error',
      name: 'errorLoadingFileData',
      desc: '',
      args: [error],
    );
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Failed to load preview`
  String get failedToLoadPreview {
    return Intl.message(
      'Failed to load preview',
      name: 'failedToLoadPreview',
      desc: '',
      args: [],
    );
  }

  /// `Modified`
  String get modified {
    return Intl.message('Modified', name: 'modified', desc: '', args: []);
  }

  /// `Failed to load PDF file: {error}`
  String failedToLoadPdfFile(String error) {
    return Intl.message(
      'Failed to load PDF file: $error',
      name: 'failedToLoadPdfFile',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to open file`
  String failedToOpenFile(String error) {
    return Intl.message(
      'Failed to open file',
      name: 'failedToOpenFile',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to load PDF for display: {error}`
  String failedToLoadPdfForDisplay(String error) {
    return Intl.message(
      'Failed to load PDF for display: $error',
      name: 'failedToLoadPdfForDisplay',
      desc: '',
      args: [error],
    );
  }

  /// `Note: Text extraction may not be available for all PDF files.`
  String get pdfTextExtractionNote {
    return Intl.message(
      'Note: Text extraction may not be available for all PDF files.',
      name: 'pdfTextExtractionNote',
      desc: '',
      args: [],
    );
  }

  /// `You can select and highlight text after extraction.`
  String get pdfTextExtractionNote2 {
    return Intl.message(
      'You can select and highlight text after extraction.',
      name: 'pdfTextExtractionNote2',
      desc: '',
      args: [],
    );
  }

  /// `Failed to extract text from PDF`
  String get failedToExtractTextFromPdf {
    return Intl.message(
      'Failed to extract text from PDF',
      name: 'failedToExtractTextFromPdf',
      desc: '',
      args: [],
    );
  }

  /// `You can view PDF and search in it`
  String get canViewPdfAndSearch {
    return Intl.message(
      'You can view PDF and search in it',
      name: 'canViewPdfAndSearch',
      desc: '',
      args: [],
    );
  }

  /// `Selected text highlighted`
  String get textHighlighted {
    return Intl.message(
      'Selected text highlighted',
      name: 'textHighlighted',
      desc: '',
      args: [],
    );
  }

  /// `PDF search is not currently available. You can open the file in an external app to search.`
  String get searchInPdfNotAvailableMessage {
    return Intl.message(
      'PDF search is not currently available. You can open the file in an external app to search.',
      name: 'searchInPdfNotAvailableMessage',
      desc: '',
      args: [],
    );
  }

  /// `Search in PDF`
  String get searchInPdf {
    return Intl.message(
      'Search in PDF',
      name: 'searchInPdf',
      desc: '',
      args: [],
    );
  }

  /// `To benefit from advanced search feature, we recommend using:`
  String get forAdvancedSearchFeature {
    return Intl.message(
      'To benefit from advanced search feature, we recommend using:',
      name: 'forAdvancedSearchFeature',
      desc: '',
      args: [],
    );
  }

  /// `Current version supports:`
  String get currentVersionSupports {
    return Intl.message(
      'Current version supports:',
      name: 'currentVersionSupports',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Loading file...`
  String get loadingFile {
    return Intl.message(
      'Loading file...',
      name: 'loadingFile',
      desc: '',
      args: [],
    );
  }

  /// `File not loaded`
  String get fileNotLoaded {
    return Intl.message(
      'File not loaded',
      name: 'fileNotLoaded',
      desc: '',
      args: [],
    );
  }

  /// `Extracting text...`
  String get extractingText {
    return Intl.message(
      'Extracting text...',
      name: 'extractingText',
      desc: '',
      args: [],
    );
  }

  /// `Highlight selected text`
  String get highlightSelectedText {
    return Intl.message(
      'Highlight selected text',
      name: 'highlightSelectedText',
      desc: '',
      args: [],
    );
  }

  /// `Remove all highlights`
  String get removeAllHighlights {
    return Intl.message(
      'Remove all highlights',
      name: 'removeAllHighlights',
      desc: '',
      args: [],
    );
  }

  /// `Highlights`
  String get highlights {
    return Intl.message('Highlights', name: 'highlights', desc: '', args: []);
  }

  /// `Text not extracted yet`
  String get textNotExtractedYet {
    return Intl.message(
      'Text not extracted yet',
      name: 'textNotExtractedYet',
      desc: '',
      args: [],
    );
  }

  /// `Extract Text`
  String get extractText {
    return Intl.message(
      'Extract Text',
      name: 'extractText',
      desc: '',
      args: [],
    );
  }

  /// `Remove File from Room`
  String get removeFileFromRoom {
    return Intl.message(
      'Remove File from Room',
      name: 'removeFileFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove "{fileName}" from this room?`
  String removeFileFromRoomConfirm(String fileName) {
    return Intl.message(
      'Are you sure you want to remove "$fileName" from this room?',
      name: 'removeFileFromRoomConfirm',
      desc: '',
      args: [fileName],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `File removed from room successfully`
  String get fileRemovedFromRoom {
    return Intl.message(
      'File removed from room successfully',
      name: 'fileRemovedFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `Failed to remove file from room`
  String get failedToRemoveFile {
    return Intl.message(
      'Failed to remove file from room',
      name: 'failedToRemoveFile',
      desc: '',
      args: [],
    );
  }

  /// `File ID not found`
  String get fileIdNotFound {
    return Intl.message(
      'File ID not found',
      name: 'fileIdNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Moving file...`
  String get movingFile {
    return Intl.message(
      'Moving file...',
      name: 'movingFile',
      desc: '',
      args: [],
    );
  }

  /// `File moved successfully`
  String get fileMovedSuccessfully {
    return Intl.message(
      'File moved successfully',
      name: 'fileMovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to move file`
  String get failedToMoveFile {
    return Intl.message(
      'Failed to move file',
      name: 'failedToMoveFile',
      desc: '',
      args: [],
    );
  }

  /// `No files`
  String get noFiles {
    return Intl.message('No files', name: 'noFiles', desc: '', args: []);
  }

  /// `Start adding new files`
  String get startAddingFiles {
    return Intl.message(
      'Start adding new files',
      name: 'startAddingFiles',
      desc: '',
      args: [],
    );
  }

  /// `Viewed by all`
  String get viewedByAll {
    return Intl.message(
      'Viewed by all',
      name: 'viewedByAll',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message('Active', name: 'active', desc: '', args: []);
  }

  /// `Accessed`
  String get accessed {
    return Intl.message('Accessed', name: 'accessed', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Shared by`
  String get sharedBy {
    return Intl.message('Shared by', name: 'sharedBy', desc: '', args: []);
  }

  /// `Move to root`
  String get moveToRoot {
    return Intl.message('Move to root', name: 'moveToRoot', desc: '', args: []);
  }

  /// `Move folder to main folder`
  String get moveToRootDescription {
    return Intl.message(
      'Move folder to main folder',
      name: 'moveToRootDescription',
      desc: '',
      args: [],
    );
  }

  /// `Move to this folder`
  String get selectFolderDescription {
    return Intl.message(
      'Move to this folder',
      name: 'selectFolderDescription',
      desc: '',
      args: [],
    );
  }

  /// `Move to this folder`
  String get moveToThisFolder {
    return Intl.message(
      'Move to this folder',
      name: 'moveToThisFolder',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave "{roomName}"? You will not be able to access this room after leaving.`
  String leaveRoomConfirm(String roomName) {
    return Intl.message(
      'Are you sure you want to leave "$roomName"? You will not be able to access this room after leaving.',
      name: 'leaveRoomConfirm',
      desc: '',
      args: [roomName],
    );
  }

  /// `Delete Folder`
  String get deleteFolder {
    return Intl.message(
      'Delete Folder',
      name: 'deleteFolder',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the folder '{folderName}'? All files and subfolders will also be deleted.`
  String confirmDeleteFolder(String folderName) {
    return Intl.message(
      'Are you sure you want to delete the folder \'$folderName\'? All files and subfolders will also be deleted.',
      name: 'confirmDeleteFolder',
      desc: '',
      args: [folderName],
    );
  }

  /// `❌ Error: Folder ID not available.`
  String get folderIdNotAvailable {
    return Intl.message(
      '❌ Error: Folder ID not available.',
      name: 'folderIdNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder '{folderName}' deleted successfully`
  String folderDeletedSuccessfully(String folderName) {
    return Intl.message(
      '✅ Folder \'$folderName\' deleted successfully',
      name: 'folderDeletedSuccessfully',
      desc: '',
      args: [folderName],
    );
  }

  /// `❌ Error occurred while deleting folder`
  String get errorDeletingFolder {
    return Intl.message(
      '❌ Error occurred while deleting folder',
      name: 'errorDeletingFolder',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error occurred while deleting folder: {error}`
  String errorDeletingFolderWithError(String error) {
    return Intl.message(
      '❌ Error occurred while deleting folder: $error',
      name: 'errorDeletingFolderWithError',
      desc: '',
      args: [error],
    );
  }

  /// `✅ Folder '{folderName}' restored successfully`
  String folderRestoredSuccessfully(String folderName) {
    return Intl.message(
      '✅ Folder \'$folderName\' restored successfully',
      name: 'folderRestoredSuccessfully',
      desc: '',
      args: [folderName],
    );
  }

  /// `❌ Error occurred while restoring folder`
  String get errorRestoringFolder {
    return Intl.message(
      '❌ Error occurred while restoring folder',
      name: 'errorRestoringFolder',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error occurred while restoring folder: {error}`
  String errorRestoringFolderWithError(String error) {
    return Intl.message(
      '❌ Error occurred while restoring folder: $error',
      name: 'errorRestoringFolderWithError',
      desc: '',
      args: [error],
    );
  }

  /// `Confirm Permanent Delete`
  String get confirmPermanentDelete {
    return Intl.message(
      'Confirm Permanent Delete',
      name: 'confirmPermanentDelete',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to permanently delete the folder '{folderName}'? This action cannot be undone. All files and subfolders will be permanently deleted.`
  String confirmPermanentDeleteFolder(String folderName) {
    return Intl.message(
      'Are you sure you want to permanently delete the folder \'$folderName\'? This action cannot be undone. All files and subfolders will be permanently deleted.',
      name: 'confirmPermanentDeleteFolder',
      desc: '',
      args: [folderName],
    );
  }

  /// `Permanently Delete`
  String get permanentDelete {
    return Intl.message(
      'Permanently Delete',
      name: 'permanentDelete',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder '{folderName}' permanently deleted successfully`
  String folderPermanentlyDeletedSuccessfully(String folderName) {
    return Intl.message(
      '✅ Folder \'$folderName\' permanently deleted successfully',
      name: 'folderPermanentlyDeletedSuccessfully',
      desc: '',
      args: [folderName],
    );
  }

  /// `❌ Error occurred while permanently deleting folder`
  String get errorPermanentlyDeletingFolder {
    return Intl.message(
      '❌ Error occurred while permanently deleting folder',
      name: 'errorPermanentlyDeletingFolder',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error occurred while permanently deleting folder: {error}`
  String errorPermanentlyDeletingFolderWithError(String error) {
    return Intl.message(
      '❌ Error occurred while permanently deleting folder: $error',
      name: 'errorPermanentlyDeletingFolderWithError',
      desc: '',
      args: [error],
    );
  }

  /// `❌ Error: Cannot identify folder`
  String get cannotIdentifyFolder {
    return Intl.message(
      '❌ Error: Cannot identify folder',
      name: 'cannotIdentifyFolder',
      desc: '',
      args: [],
    );
  }

  /// `Downloading folder...`
  String get downloadingFolder {
    return Intl.message(
      'Downloading folder...',
      name: 'downloadingFolder',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder downloaded successfully: {fileName}`
  String folderDownloadedSuccessfully(String fileName) {
    return Intl.message(
      '✅ Folder downloaded successfully: $fileName',
      name: 'folderDownloadedSuccessfully',
      desc: '',
      args: [fileName],
    );
  }

  /// `Failed to download folder`
  String get failedToDownloadFolder {
    return Intl.message(
      'Failed to download folder',
      name: 'failedToDownloadFolder',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error downloading folder: {error}`
  String errorDownloadingFolder(String error) {
    return Intl.message(
      '❌ Error downloading folder: $error',
      name: 'errorDownloadingFolder',
      desc: '',
      args: [error],
    );
  }

  /// `Please enter the 6-digit verification code`
  String get pleaseEnter6DigitCode {
    return Intl.message(
      'Please enter the 6-digit verification code',
      name: 'pleaseEnter6DigitCode',
      desc: '',
      args: [],
    );
  }

  /// `✅ Account activated successfully`
  String get accountActivatedSuccessfully {
    return Intl.message(
      '✅ Account activated successfully',
      name: 'accountActivatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Verification code is incorrect`
  String get invalidVerificationCode {
    return Intl.message(
      'Verification code is incorrect',
      name: 'invalidVerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `Please wait {seconds} seconds before resending`
  String pleaseWaitBeforeResend(int seconds) {
    return Intl.message(
      'Please wait $seconds seconds before resending',
      name: 'pleaseWaitBeforeResend',
      desc: '',
      args: [seconds],
    );
  }

  /// `Verification code sent to your email`
  String get verificationCodeSent {
    return Intl.message(
      'Verification code sent to your email',
      name: 'verificationCodeSent',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to resend verification code`
  String get failedToResendCode {
    return Intl.message(
      '❌ Failed to resend verification code',
      name: 'failedToResendCode',
      desc: '',
      args: [],
    );
  }

  /// `Email Verification`
  String get emailVerification {
    return Intl.message(
      'Email Verification',
      name: 'emailVerification',
      desc: '',
      args: [],
    );
  }

  /// `Verification code sent to {email}`
  String verificationCodeSentTo(String email) {
    return Intl.message(
      'Verification code sent to $email',
      name: 'verificationCodeSentTo',
      desc: '',
      args: [email],
    );
  }

  /// `Didn't receive the code?`
  String get didNotReceiveCode {
    return Intl.message(
      'Didn\'t receive the code?',
      name: 'didNotReceiveCode',
      desc: '',
      args: [],
    );
  }

  /// `Resend ({seconds})`
  String resendWithCountdown(int seconds) {
    return Intl.message(
      'Resend ($seconds)',
      name: 'resendWithCountdown',
      desc: '',
      args: [seconds],
    );
  }

  /// `Resend`
  String get resend {
    return Intl.message('Resend', name: 'resend', desc: '', args: []);
  }

  /// `Open file as text: {fileName}`
  String openFileAsText(String fileName) {
    return Intl.message(
      'Open file as text: $fileName',
      name: 'openFileAsText',
      desc: '',
      args: [fileName],
    );
  }

  /// `File link not available`
  String get fileLinkNotAvailable {
    return Intl.message(
      'File link not available',
      name: 'fileLinkNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create temporary file`
  String get failedToCreateTempFile {
    return Intl.message(
      'Failed to create temporary file',
      name: 'failedToCreateTempFile',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load file status: {error}`
  String failedToLoadFileStatus(String error) {
    return Intl.message(
      'Failed to load file status: $error',
      name: 'failedToLoadFileStatus',
      desc: '',
      args: [error],
    );
  }

  /// `Error opening file: {error}`
  String errorOpeningFile(String error) {
    return Intl.message(
      'Error opening file: $error',
      name: 'errorOpeningFile',
      desc: '',
      args: [error],
    );
  }

  /// `File not available: {error}`
  String fileNotAvailableError(String error) {
    return Intl.message(
      'File not available: $error',
      name: 'fileNotAvailableError',
      desc: '',
      args: [error],
    );
  }

  /// `Error loading file: {error}`
  String errorLoadingFile(String error) {
    return Intl.message(
      'Error loading file: $error',
      name: 'errorLoadingFile',
      desc: '',
      args: [error],
    );
  }

  /// `File is not a valid PDF`
  String get fileNotValidPdf {
    return Intl.message(
      'File is not a valid PDF',
      name: 'fileNotValidPdf',
      desc: '',
      args: [],
    );
  }

  /// `Create New Share Room`
  String get createNewShareRoom {
    return Intl.message(
      'Create New Share Room',
      name: 'createNewShareRoom',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Please enter a room name`
  String get pleaseEnterRoomName {
    return Intl.message(
      '⚠️ Please enter a room name',
      name: 'pleaseEnterRoomName',
      desc: '',
      args: [],
    );
  }

  /// `Search error: {error}`
  String searchError(String error) {
    return Intl.message(
      'Search error: $error',
      name: 'searchError',
      desc: '',
      args: [error],
    );
  }

  /// `Folder Info`
  String get folderInfo {
    return Intl.message('Folder Info', name: 'folderInfo', desc: '', args: []);
  }

  /// `Load More`
  String get loadMore {
    return Intl.message('Load More', name: 'loadMore', desc: '', args: []);
  }

  /// `Files`
  String get filesCount {
    return Intl.message('Files', name: 'filesCount', desc: '', args: []);
  }

  /// `Subfolders count`
  String get subfoldersCount {
    return Intl.message(
      'Subfolders count',
      name: 'subfoldersCount',
      desc: '',
      args: [],
    );
  }

  /// `Creation date`
  String get creationDate {
    return Intl.message(
      'Creation date',
      name: 'creationDate',
      desc: '',
      args: [],
    );
  }

  /// `This feature is under development`
  String get featureUnderDevelopment {
    return Intl.message(
      'This feature is under development',
      name: 'featureUnderDevelopment',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed folder`
  String get folderWithoutName {
    return Intl.message(
      'Unnamed folder',
      name: 'folderWithoutName',
      desc: '',
      args: [],
    );
  }

  /// `Moving folder...`
  String get movingFolder {
    return Intl.message(
      'Moving folder...',
      name: 'movingFolder',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching subfolders: {error}`
  String errorFetchingSubfolders(String error) {
    return Intl.message(
      'Error fetching subfolders: $error',
      name: 'errorFetchingSubfolders',
      desc: '',
      args: [error],
    );
  }

  /// `Move Folder to Root`
  String get moveFolderToRoot {
    return Intl.message(
      'Move Folder to Root',
      name: 'moveFolderToRoot',
      desc: '',
      args: [],
    );
  }

  /// `Reject Invitation`
  String get rejectInvitation {
    return Intl.message(
      'Reject Invitation',
      name: 'rejectInvitation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this invitation?`
  String get confirmRejectInvitation {
    return Intl.message(
      'Are you sure you want to reject this invitation?',
      name: 'confirmRejectInvitation',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `Pending Invitations`
  String get pendingInvitations {
    return Intl.message(
      'Pending Invitations',
      name: 'pendingInvitations',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Please select a file or folder`
  String get pleaseSelectFileOrFolder {
    return Intl.message(
      'Please select a file or folder',
      name: 'pleaseSelectFileOrFolder',
      desc: '',
      args: [],
    );
  }

  /// `Delete Comment`
  String get deleteComment {
    return Intl.message(
      'Delete Comment',
      name: 'deleteComment',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this comment?`
  String get confirmDeleteComment {
    return Intl.message(
      'Are you sure you want to delete this comment?',
      name: 'confirmDeleteComment',
      desc: '',
      args: [],
    );
  }

  /// `Room`
  String get room {
    return Intl.message('Room', name: 'room', desc: '', args: []);
  }

  /// `Error loading room details`
  String get errorLoadingRoomDetails {
    return Intl.message(
      'Error loading room details',
      name: 'errorLoadingRoomDetails',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load room details`
  String get failedToLoadRoomDetails {
    return Intl.message(
      'Failed to load room details',
      name: 'failedToLoadRoomDetails',
      desc: '',
      args: [],
    );
  }

  /// `Please login again`
  String get pleaseLoginAgain {
    return Intl.message(
      'Please login again',
      name: 'pleaseLoginAgain',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete "{roomName}"? All shared files and folders will also be deleted.`
  String deleteRoomConfirm(String roomName) {
    return Intl.message(
      'Are you sure you want to delete "$roomName"? All shared files and folders will also be deleted.',
      name: 'deleteRoomConfirm',
      desc: '',
      args: [roomName],
    );
  }

  /// `Are you sure you want to remove this file from the room?`
  String get confirmRemoveFileFromRoom {
    return Intl.message(
      'Are you sure you want to remove this file from the room?',
      name: 'confirmRemoveFileFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `Remove Folder from Room`
  String get removeFolderFromRoom {
    return Intl.message(
      'Remove Folder from Room',
      name: 'removeFolderFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this folder from the room?`
  String get confirmRemoveFolderFromRoom {
    return Intl.message(
      'Are you sure you want to remove this folder from the room?',
      name: 'confirmRemoveFolderFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove the folder '{folderName}' from the room?`
  String confirmRemoveFolderFromRoomWithName(String folderName) {
    return Intl.message(
      'Are you sure you want to remove the folder \'$folderName\' from the room?',
      name: 'confirmRemoveFolderFromRoomWithName',
      desc: '',
      args: [folderName],
    );
  }

  /// `Saving folder...`
  String get savingFolder {
    return Intl.message(
      'Saving folder...',
      name: 'savingFolder',
      desc: '',
      args: [],
    );
  }

  /// `Save to Root`
  String get saveToRoot {
    return Intl.message('Save to Root', name: 'saveToRoot', desc: '', args: []);
  }

  /// `Failed to load room data`
  String get failedToLoadRoomData {
    return Intl.message(
      'Failed to load room data',
      name: 'failedToLoadRoomData',
      desc: '',
      args: [],
    );
  }

  /// `No shared files found`
  String get noSharedFiles {
    return Intl.message(
      'No shared files found',
      name: 'noSharedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Share Files with Room`
  String get shareFilesWithRoom {
    return Intl.message(
      'Share Files with Room',
      name: 'shareFilesWithRoom',
      desc: '',
      args: [],
    );
  }

  /// `Create New Folder`
  String get createNewFolder {
    return Intl.message(
      'Create New Folder',
      name: 'createNewFolder',
      desc: '',
      args: [],
    );
  }

  /// `Please enter folder name`
  String get pleaseEnterFolderName {
    return Intl.message(
      'Please enter folder name',
      name: 'pleaseEnterFolderName',
      desc: '',
      args: [],
    );
  }

  /// `Folder created successfully: {folderName}`
  String folderCreatedSuccessfully(String folderName) {
    return Intl.message(
      'Folder created successfully: $folderName',
      name: 'folderCreatedSuccessfully',
      desc: '',
      args: [folderName],
    );
  }

  /// `Failed to create folder`
  String get failedToCreateFolder {
    return Intl.message(
      'Failed to create folder',
      name: 'failedToCreateFolder',
      desc: '',
      args: [],
    );
  }

  /// `Remove Member`
  String get removeMember {
    return Intl.message(
      'Remove Member',
      name: 'removeMember',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove {memberName} from the room?`
  String confirmRemoveMember(String memberName) {
    return Intl.message(
      'Are you sure you want to remove $memberName from the room?',
      name: 'confirmRemoveMember',
      desc: '',
      args: [memberName],
    );
  }

  /// `Room Members`
  String get roomMembers {
    return Intl.message(
      'Room Members',
      name: 'roomMembers',
      desc: '',
      args: [],
    );
  }

  /// `View Only`
  String get viewOnly {
    return Intl.message('View Only', name: 'viewOnly', desc: '', args: []);
  }

  /// `User can only view files`
  String get viewOnlyDescription {
    return Intl.message(
      'User can only view files',
      name: 'viewOnlyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Editor`
  String get editor {
    return Intl.message('Editor', name: 'editor', desc: '', args: []);
  }

  /// `User can edit files`
  String get editorDescription {
    return Intl.message(
      'User can edit files',
      name: 'editorDescription',
      desc: '',
      args: [],
    );
  }

  /// `Commenter`
  String get commenter {
    return Intl.message('Commenter', name: 'commenter', desc: '', args: []);
  }

  /// `User can comment on files`
  String get commenterDescription {
    return Intl.message(
      'User can comment on files',
      name: 'commenterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Share Folder with Room`
  String get shareFolderWithRoom {
    return Intl.message(
      'Share Folder with Room',
      name: 'shareFolderWithRoom',
      desc: '',
      args: [],
    );
  }

  /// `Share with this room`
  String get shareWithThisRoom {
    return Intl.message(
      'Share with this room',
      name: 'shareWithThisRoom',
      desc: '',
      args: [],
    );
  }

  /// `Must allow photos access`
  String get mustAllowPhotosAccess {
    return Intl.message(
      'Must allow photos access',
      name: 'mustAllowPhotosAccess',
      desc: '',
      args: [],
    );
  }

  /// `✅ Profile image uploaded successfully`
  String get profileImageUploadedSuccessfully {
    return Intl.message(
      '✅ Profile image uploaded successfully',
      name: 'profileImageUploadedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to upload profile image`
  String get failedToUploadProfileImage {
    return Intl.message(
      '❌ Failed to upload profile image',
      name: 'failedToUploadProfileImage',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error uploading profile image: {error}`
  String errorUploadingProfileImage(String error) {
    return Intl.message(
      '❌ Error uploading profile image: $error',
      name: 'errorUploadingProfileImage',
      desc: '',
      args: [error],
    );
  }

  /// `Must allow camera access`
  String get mustAllowCameraAccess {
    return Intl.message(
      'Must allow camera access',
      name: 'mustAllowCameraAccess',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error occurred`
  String get unknownError {
    return Intl.message(
      'Unknown error occurred',
      name: 'unknownError',
      desc: '',
      args: [],
    );
  }

  /// `Choose from Gallery`
  String get chooseFromGallery {
    return Intl.message(
      'Choose from Gallery',
      name: 'chooseFromGallery',
      desc: '',
      args: [],
    );
  }

  /// `Take Photo from Camera`
  String get takePhotoFromCamera {
    return Intl.message(
      'Take Photo from Camera',
      name: 'takePhotoFromCamera',
      desc: '',
      args: [],
    );
  }

  /// `Used`
  String get used {
    return Intl.message('Used', name: 'used', desc: '', args: []);
  }

  /// `Microphone Permission Required`
  String get microphonePermissionRequired {
    return Intl.message(
      'Microphone Permission Required',
      name: 'microphonePermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Open Settings`
  String get openSettings {
    return Intl.message(
      'Open Settings',
      name: 'openSettings',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied. Microphone access is required for voice search.`
  String get permissionDenied {
    return Intl.message(
      'Permission denied. Microphone access is required for voice search.',
      name: 'permissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `You must allow microphone access`
  String get mustAllowMicrophoneAccess {
    return Intl.message(
      'You must allow microphone access',
      name: 'mustAllowMicrophoneAccess',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition is not available on this device`
  String get speechRecognitionNotAvailable {
    return Intl.message(
      'Speech recognition is not available on this device',
      name: 'speechRecognitionNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Enter search text`
  String get enterSearchText {
    return Intl.message(
      'Enter search text',
      name: 'enterSearchText',
      desc: '',
      args: [],
    );
  }

  /// `Smart Search`
  String get smartSearch {
    return Intl.message(
      'Smart Search',
      name: 'smartSearch',
      desc: '',
      args: [],
    );
  }

  /// `File link not available (no path)`
  String get fileLinkNotAvailableNoPath {
    return Intl.message(
      'File link not available (no path)',
      name: 'fileLinkNotAvailableNoPath',
      desc: '',
      args: [],
    );
  }

  /// `Error loading text file: {error}`
  String errorLoadingTextFile(String error) {
    return Intl.message(
      'Error loading text file: $error',
      name: 'errorLoadingTextFile',
      desc: '',
      args: [error],
    );
  }

  /// `Activity Log`
  String get activityLog {
    return Intl.message(
      'Activity Log',
      name: 'activityLog',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previous {
    return Intl.message('Previous', name: 'previous', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Filter Activity`
  String get filterActivity {
    return Intl.message(
      'Filter Activity',
      name: 'filterActivity',
      desc: '',
      args: [],
    );
  }

  /// `All Activities`
  String get allActivities {
    return Intl.message(
      'All Activities',
      name: 'allActivities',
      desc: '',
      args: [],
    );
  }

  /// `Upload File`
  String get uploadFile {
    return Intl.message('Upload File', name: 'uploadFile', desc: '', args: []);
  }

  /// `Download File`
  String get downloadFile {
    return Intl.message(
      'Download File',
      name: 'downloadFile',
      desc: '',
      args: [],
    );
  }

  /// `Share File`
  String get shareFile {
    return Intl.message('Share File', name: 'shareFile', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `User`
  String get userLabel {
    return Intl.message('User', name: 'userLabel', desc: '', args: []);
  }

  /// `System`
  String get system {
    return Intl.message('System', name: 'system', desc: '', args: []);
  }

  /// `Room`
  String get roomLabel {
    return Intl.message('Room', name: 'roomLabel', desc: '', args: []);
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `✅ Logged out successfully`
  String get logoutSuccess {
    return Intl.message(
      '✅ Logged out successfully',
      name: 'logoutSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error: Token not found`
  String get tokenNotFound {
    return Intl.message(
      '❌ Error: Token not found',
      name: 'tokenNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Trash`
  String get trash {
    return Intl.message('Trash', name: 'trash', desc: '', args: []);
  }

  /// `Deleted Files`
  String get deletedFiles {
    return Intl.message(
      'Deleted Files',
      name: 'deletedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Deleted Folders`
  String get deletedFolders {
    return Intl.message(
      'Deleted Folders',
      name: 'deletedFolders',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Edit Username`
  String get editUsername {
    return Intl.message(
      'Edit Username',
      name: 'editUsername',
      desc: '',
      args: [],
    );
  }

  /// `Edit Email`
  String get editEmail {
    return Intl.message('Edit Email', name: 'editEmail', desc: '', args: []);
  }

  /// `This field is required`
  String get fieldRequired {
    return Intl.message(
      'This field is required',
      name: 'fieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get validEmailRequired {
    return Intl.message(
      'Invalid email address',
      name: 'validEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `✅ Updated successfully`
  String get updatedSuccessfully {
    return Intl.message(
      '✅ Updated successfully',
      name: 'updatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get currentPassword {
    return Intl.message(
      'Current Password',
      name: 'currentPassword',
      desc: '',
      args: [],
    );
  }

  /// `Current password is required`
  String get currentPasswordRequired {
    return Intl.message(
      'Current password is required',
      name: 'currentPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `New password is required`
  String get newPasswordRequired {
    return Intl.message(
      'New password is required',
      name: 'newPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters`
  String get passwordMinLength {
    return Intl.message(
      'Password must be at least 8 characters',
      name: 'passwordMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password`
  String get confirmNewPassword {
    return Intl.message(
      'Confirm New Password',
      name: 'confirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password confirmation is required`
  String get passwordConfirmationRequired {
    return Intl.message(
      'Password confirmation is required',
      name: 'passwordConfirmationRequired',
      desc: '',
      args: [],
    );
  }

  /// `✅ Password updated successfully`
  String get passwordUpdatedSuccessfully {
    return Intl.message(
      '✅ Password updated successfully',
      name: 'passwordUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Favorite Files`
  String get favoriteFiles {
    return Intl.message(
      'Favorite Files',
      name: 'favoriteFiles',
      desc: '',
      args: [],
    );
  }

  /// `No favorite files`
  String get noFavoriteFiles {
    return Intl.message(
      'No favorite files',
      name: 'noFavoriteFiles',
      desc: '',
      args: [],
    );
  }

  /// `Add files to favorites`
  String get addFilesToFavorites {
    return Intl.message(
      'Add files to favorites',
      name: 'addFilesToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Error: Folder ID not found`
  String get folderIdNotFound {
    return Intl.message(
      'Error: Folder ID not found',
      name: 'folderIdNotFound',
      desc: 'Message shown when the folder ID is missing',
      args: [],
    );
  }

  /// `View and manage deleted files and folders`
  String get viewDeletedFilesAndFolders {
    return Intl.message(
      'View and manage deleted files and folders',
      name: 'viewDeletedFilesAndFolders',
      desc: '',
      args: [],
    );
  }

  /// `View all your activities in the app`
  String get viewAllActivities {
    return Intl.message(
      'View all your activities in the app',
      name: 'viewAllActivities',
      desc: '',
      args: [],
    );
  }

  /// `Root`
  String get root {
    return Intl.message('Root', name: 'root', desc: '', args: []);
  }

  /// `Upload/create in root (no parent folder)`
  String get uploadCreateInRoot {
    return Intl.message(
      'Upload/create in root (no parent folder)',
      name: 'uploadCreateInRoot',
      desc: '',
      args: [],
    );
  }

  /// `Upload/create in this folder`
  String get uploadCreateInThisFolder {
    return Intl.message(
      'Upload/create in this folder',
      name: 'uploadCreateInThisFolder',
      desc: '',
      args: [],
    );
  }

  /// `Edit Folder`
  String get editFolder {
    return Intl.message('Edit Folder', name: 'editFolder', desc: '', args: []);
  }

  /// `Folder Name`
  String get folderName {
    return Intl.message('Folder Name', name: 'folderName', desc: '', args: []);
  }

  /// `Description`
  String get folderDescription {
    return Intl.message(
      'Description',
      name: 'folderDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get folderTags {
    return Intl.message('Tags', name: 'folderTags', desc: '', args: []);
  }

  /// `Tags separated by commas (optional)`
  String get folderTagsHint {
    return Intl.message(
      'Tags separated by commas (optional)',
      name: 'folderTagsHint',
      desc: '',
      args: [],
    );
  }

  /// `Folder description (optional)`
  String get folderDescriptionHint {
    return Intl.message(
      'Folder description (optional)',
      name: 'folderDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Move folder to main folder`
  String get moveFolderToMainFolder {
    return Intl.message(
      'Move folder to main folder',
      name: 'moveFolderToMainFolder',
      desc: '',
      args: [],
    );
  }

  /// `Saving file...`
  String get savingFile {
    return Intl.message(
      'Saving file...',
      name: 'savingFile',
      desc: '',
      args: [],
    );
  }

  /// `Move file to root (no folder)`
  String get moveFileToRoot {
    return Intl.message(
      'Move file to root (no folder)',
      name: 'moveFileToRoot',
      desc: '',
      args: [],
    );
  }

  /// `Move folder to root (no parent folder)`
  String get moveFolderToRootNoParent {
    return Intl.message(
      'Move folder to root (no parent folder)',
      name: 'moveFolderToRootNoParent',
      desc: '',
      args: [],
    );
  }

  /// `Failed to move folder - Feature under development`
  String get failedToMoveFolder {
    return Intl.message(
      'Failed to move folder - Feature under development',
      name: 'failedToMoveFolder',
      desc: '',
      args: [],
    );
  }

  /// `Searching...`
  String get searching {
    return Intl.message('Searching...', name: 'searching', desc: '', args: []);
  }

  /// `Invalid link`
  String get invalidLink {
    return Intl.message(
      'Invalid link',
      name: 'invalidLink',
      desc: '',
      args: [],
    );
  }

  /// `Open File`
  String get openFile {
    return Intl.message('Open File', name: 'openFile', desc: '', args: []);
  }

  /// `Removing from favorites...`
  String get removingFromFavorites {
    return Intl.message(
      'Removing from favorites...',
      name: 'removingFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Open Folder`
  String get openFolder {
    return Intl.message('Open Folder', name: 'openFolder', desc: '', args: []);
  }

  /// `File not found`
  String get fileNotFound {
    return Intl.message(
      'File not found',
      name: 'fileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Select "{folderName}"`
  String selectFolderName(String folderName) {
    return Intl.message(
      'Select "$folderName"',
      name: 'selectFolderName',
      desc: '',
      args: [folderName],
    );
  }

  /// `Folder moved successfully`
  String get folderMovedSuccessfully {
    return Intl.message(
      'Folder moved successfully',
      name: 'folderMovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `File saved to your account`
  String get fileSavedToAccount {
    return Intl.message(
      'File saved to your account',
      name: 'fileSavedToAccount',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch folder information`
  String get failedToFetchFolderInfo {
    return Intl.message(
      'Failed to fetch folder information',
      name: 'failedToFetchFolderInfo',
      desc: '',
      args: [],
    );
  }

  /// `Shared with`
  String get sharedWith {
    return Intl.message('Shared with', name: 'sharedWith', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Total size`
  String get totalSize {
    return Intl.message('Total size', name: 'totalSize', desc: '', args: []);
  }

  /// `✅ Folder updated successfully`
  String get folderUpdatedSuccessfully {
    return Intl.message(
      '✅ Folder updated successfully',
      name: 'folderUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed folder`
  String get unnamedFolder {
    return Intl.message(
      'Unnamed folder',
      name: 'unnamedFolder',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update folder`
  String get folderUpdateFailed {
    return Intl.message(
      'Failed to update folder',
      name: 'folderUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to move folder`
  String get folderMoveFailed {
    return Intl.message(
      'Failed to move folder',
      name: 'folderMoveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update favorites: {message}`
  String favoriteUpdateFailed(Object message) {
    return Intl.message(
      'Failed to update favorites: $message',
      name: 'favoriteUpdateFailed',
      desc: '',
      args: [message],
    );
  }

  /// `✅ Folder added to favorites`
  String get folderAddedToFavorites {
    return Intl.message(
      '✅ Folder added to favorites',
      name: 'folderAddedToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder removed from favorites`
  String get folderRemovedFromFavorites {
    return Intl.message(
      '✅ Folder removed from favorites',
      name: 'folderRemovedFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Move folder: {folderName}`
  String moveFolderTitle(Object folderName) {
    return Intl.message(
      'Move folder: $folderName',
      name: 'moveFolderTitle',
      desc: '',
      args: [folderName],
    );
  }

  /// `Failed to fetch folder list`
  String get failedToFetchFolderList {
    return Intl.message(
      'Failed to fetch folder list',
      name: 'failedToFetchFolderList',
      desc: '',
      args: [],
    );
  }

  /// `Loading folders...`
  String get loadingFolders {
    return Intl.message(
      'Loading folders...',
      name: 'loadingFolders',
      desc: '',
      args: [],
    );
  }

  /// `No folders in root`
  String get noRootFolders {
    return Intl.message(
      'No folders in root',
      name: 'noRootFolders',
      desc: '',
      args: [],
    );
  }

  /// `You can upload files/folders directly to the root using the option above`
  String get uploadToRootHint {
    return Intl.message(
      'You can upload files/folders directly to the root using the option above',
      name: 'uploadToRootHint',
      desc: '',
      args: [],
    );
  }

  /// `Select this folder`
  String get selectFolderTooltip {
    return Intl.message(
      'Select this folder',
      name: 'selectFolderTooltip',
      desc: '',
      args: [],
    );
  }

  /// `update`
  String get update {
    return Intl.message('update', name: 'update', desc: '', args: []);
  }

  /// `Search in your files`
  String get searchYourFiles {
    return Intl.message(
      'Search in your files',
      name: 'searchYourFiles',
      desc: '',
      args: [],
    );
  }

  /// `No results for:`
  String get noResultsFor {
    return Intl.message(
      'No results for:',
      name: 'noResultsFor',
      desc: '',
      args: [],
    );
  }

  /// `Try searching with different keywords`
  String get tryDifferentKeywords {
    return Intl.message(
      'Try searching with different keywords',
      name: 'tryDifferentKeywords',
      desc: '',
      args: [],
    );
  }

  /// `Found`
  String get foundText {
    return Intl.message('Found', name: 'foundText', desc: '', args: []);
  }

  /// `result`
  String get resultWord {
    return Intl.message('result', name: 'resultWord', desc: '', args: []);
  }

  /// `for search:`
  String get forSearch {
    return Intl.message('for search:', name: 'forSearch', desc: '', args: []);
  }

  /// `View as list`
  String get tooltipListView {
    return Intl.message(
      'View as list',
      name: 'tooltipListView',
      desc: '',
      args: [],
    );
  }

  /// `View as grid`
  String get tooltipGridView {
    return Intl.message(
      'View as grid',
      name: 'tooltipGridView',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed file`
  String get unnamedfile {
    return Intl.message(
      'Unnamed file',
      name: 'unnamedfile',
      desc: '',
      args: [],
    );
  }

  /// `Account activated successfully`
  String get accountActivated {
    return Intl.message(
      'Account activated successfully',
      name: 'accountActivated',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send verification code`
  String get verificationCodeSendFailed {
    return Intl.message(
      'Failed to send verification code',
      name: 'verificationCodeSendFailed',
      desc: '',
      args: [],
    );
  }

  /// `Code verified successfully`
  String get verificationSuccess {
    return Intl.message(
      'Code verified successfully',
      name: 'verificationSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPasswordTitle {
    return Intl.message(
      'Reset Password',
      name: 'resetPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create new password`
  String get createNewPassword {
    return Intl.message(
      'Create new password',
      name: 'createNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your new password for {email}`
  String enterNewPasswordFor(Object email) {
    return Intl.message(
      'Enter your new password for $email',
      name: 'enterNewPasswordFor',
      desc: '',
      args: [email],
    );
  }

  /// `Make sure your password is at least 6 characters long`
  String get passwordAtLeast6Chars {
    return Intl.message(
      'Make sure your password is at least 6 characters long',
      name: 'passwordAtLeast6Chars',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all fields`
  String get pleaseFillAllFields {
    return Intl.message(
      'Please fill all fields',
      name: 'pleaseFillAllFields',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordTooShort {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `✅ Password reset successfully!`
  String get passwordResetSuccess {
    return Intl.message(
      '✅ Password reset successfully!',
      name: 'passwordResetSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to reset password`
  String get passwordResetFailed {
    return Intl.message(
      'Failed to reset password',
      name: 'passwordResetFailed',
      desc: '',
      args: [],
    );
  }

  /// `Back to Verification`
  String get backToVerification {
    return Intl.message(
      'Back to Verification',
      name: 'backToVerification',
      desc: '',
      args: [],
    );
  }

  /// `Registration failed`
  String get registrationFailed {
    return Intl.message(
      'Registration failed',
      name: 'registrationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get audio duration`
  String get audioDurationError {
    return Intl.message(
      'Failed to get audio duration',
      name: 'audioDurationError',
      desc: '',
      args: [],
    );
  }

  /// `Failed to play audio file`
  String get audioPlayError {
    return Intl.message(
      'Failed to play audio file',
      name: 'audioPlayError',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pause audio file`
  String get audioPauseError {
    return Intl.message(
      'Failed to pause audio file',
      name: 'audioPauseError',
      desc: '',
      args: [],
    );
  }

  /// `Failed to seek audio`
  String get audioSeekError {
    return Intl.message(
      'Failed to seek audio',
      name: 'audioSeekError',
      desc: '',
      args: [],
    );
  }

  /// `Failed to change playback speed`
  String get audioSpeedChangeError {
    return Intl.message(
      'Failed to change playback speed',
      name: 'audioSpeedChangeError',
      desc: '',
      args: [],
    );
  }

  /// `Loading audio file...`
  String get loadingAudio {
    return Intl.message(
      'Loading audio file...',
      name: 'loadingAudio',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load audio file`
  String get audioLoadFailed {
    return Intl.message(
      'Failed to load audio file',
      name: 'audioLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Check your internet connection and URL`
  String get checkInternet {
    return Intl.message(
      'Check your internet connection and URL',
      name: 'checkInternet',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message('Play', name: 'play', desc: '', args: []);
  }

  /// `Pause`
  String get pause {
    return Intl.message('Pause', name: 'pause', desc: '', args: []);
  }

  /// `Stop`
  String get stop {
    return Intl.message('Stop', name: 'stop', desc: '', args: []);
  }

  /// `Restart from beginning`
  String get restart {
    return Intl.message(
      'Restart from beginning',
      name: 'restart',
      desc: '',
      args: [],
    );
  }

  /// `🎵 Playing...`
  String get playingStatus {
    return Intl.message(
      '🎵 Playing...',
      name: 'playingStatus',
      desc: '',
      args: [],
    );
  }

  /// `⏸️ Paused`
  String get pausedStatus {
    return Intl.message('⏸️ Paused', name: 'pausedStatus', desc: '', args: []);
  }

  /// `⏹️ Stopped`
  String get stoppedStatus {
    return Intl.message(
      '⏹️ Stopped',
      name: 'stoppedStatus',
      desc: '',
      args: [],
    );
  }

  /// `Playback speed:`
  String get playbackSpeedLabel {
    return Intl.message(
      'Playback speed:',
      name: 'playbackSpeedLabel',
      desc: '',
      args: [],
    );
  }

  /// `File Information`
  String get fileInfoTitle {
    return Intl.message(
      'File Information',
      name: 'fileInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `File Name`
  String get fileNameLabel {
    return Intl.message('File Name', name: 'fileNameLabel', desc: '', args: []);
  }

  /// `Description`
  String get descriptionLabel {
    return Intl.message(
      'Description',
      name: 'descriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get tagsLabel {
    return Intl.message('Tags', name: 'tagsLabel', desc: '', args: []);
  }

  /// `Edit Content`
  String get editContentTitle {
    return Intl.message(
      'Edit Content',
      name: 'editContentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Editing the content of this type of file is not supported currently.\nYou can only edit the name, description, and tags.`
  String get editContentDescription {
    return Intl.message(
      'Editing the content of this type of file is not supported currently.\nYou can only edit the name, description, and tags.',
      name: 'editContentDescription',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update file`
  String get updateFileError {
    return Intl.message(
      'Failed to update file',
      name: 'updateFileError',
      desc: '',
      args: [],
    );
  }

  /// `File uploaded but failed to delete old file:`
  String get fileUploadedButDeleteFailed {
    return Intl.message(
      'File uploaded but failed to delete old file:',
      name: 'fileUploadedButDeleteFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload updated file`
  String get fileUpdateFailed {
    return Intl.message(
      'Failed to upload updated file',
      name: 'fileUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save the new version`
  String get saveNewVersionFailed {
    return Intl.message(
      'Failed to save the new version',
      name: 'saveNewVersionFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save changes`
  String get saveChangesFailed {
    return Intl.message(
      'Failed to save changes',
      name: 'saveChangesFailed',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get detailType {
    return Intl.message('Type', name: 'detailType', desc: '', args: []);
  }

  /// `Folder`
  String get detailFolder {
    return Intl.message('Folder', name: 'detailFolder', desc: '', args: []);
  }

  /// `Size`
  String get detailSize {
    return Intl.message('Size', name: 'detailSize', desc: '', args: []);
  }

  /// `Files count`
  String get detailFilesCount {
    return Intl.message(
      'Files count',
      name: 'detailFilesCount',
      desc: '',
      args: [],
    );
  }

  /// `Subfolders count`
  String get detailSubfoldersCount {
    return Intl.message(
      'Subfolders count',
      name: 'detailSubfoldersCount',
      desc: '',
      args: [],
    );
  }

  /// `Created at`
  String get detailCreatedAt {
    return Intl.message(
      'Created at',
      name: 'detailCreatedAt',
      desc: '',
      args: [],
    );
  }

  /// `Last modified`
  String get detailUpdatedAt {
    return Intl.message(
      'Last modified',
      name: 'detailUpdatedAt',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get detailDescription {
    return Intl.message(
      'Description',
      name: 'detailDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get detailTags {
    return Intl.message('Tags', name: 'detailTags', desc: '', args: []);
  }

  /// `—`
  String get detailEmpty {
    return Intl.message('—', name: 'detailEmpty', desc: '', args: []);
  }

  /// `Shared with`
  String get detailSharedWith {
    return Intl.message(
      'Shared with',
      name: 'detailSharedWith',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get detailCategory {
    return Intl.message('Category', name: 'detailCategory', desc: '', args: []);
  }

  /// `Total size`
  String get detailTotalSize {
    return Intl.message(
      'Total size',
      name: 'detailTotalSize',
      desc: '',
      args: [],
    );
  }

  /// `Edit Folder`
  String get editFolderTitle {
    return Intl.message(
      'Edit Folder',
      name: 'editFolderTitle',
      desc: '',
      args: [],
    );
  }

  /// `Folder name`
  String get folderNameLabel {
    return Intl.message(
      'Folder name',
      name: 'folderNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Folder description (optional)`
  String get descriptionHint {
    return Intl.message(
      'Folder description (optional)',
      name: 'descriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Comma-separated tags (optional)`
  String get tagsHint {
    return Intl.message(
      'Comma-separated tags (optional)',
      name: 'tagsHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a folder name`
  String get enterFolderNameError {
    return Intl.message(
      'Please enter a folder name',
      name: 'enterFolderNameError',
      desc: '',
      args: [],
    );
  }

  /// `Folder updated successfully`
  String get folderUpdateSuccess {
    return Intl.message(
      'Folder updated successfully',
      name: 'folderUpdateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Folder protection enabled successfully`
  String get folderProtectionEnabled {
    return Intl.message(
      'Folder protection enabled successfully',
      name: 'folderProtectionEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Folder protection disabled successfully`
  String get folderProtectionDisabled {
    return Intl.message(
      'Folder protection disabled successfully',
      name: 'folderProtectionDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Folder moved successfully`
  String get folderMoveSuccess {
    return Intl.message(
      'Folder moved successfully',
      name: 'folderMoveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Folder added to favorites`
  String get favoriteAdded {
    return Intl.message(
      'Folder added to favorites',
      name: 'favoriteAdded',
      desc: '',
      args: [],
    );
  }

  /// `Folder removed from favorites`
  String get favoriteRemoved {
    return Intl.message(
      'Folder removed from favorites',
      name: 'favoriteRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update favorite status`
  String get favoriteUpdateFaile {
    return Intl.message(
      'Failed to update favorite status',
      name: 'favoriteUpdateFaile',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching subfolders: {error}`
  String subfoldersFetchError(Object error) {
    return Intl.message(
      'Error fetching subfolders: $error',
      name: 'subfoldersFetchError',
      desc: '',
      args: [error],
    );
  }

  /// `Move folder to the main folder`
  String get moveToRootSubtitle {
    return Intl.message(
      'Move folder to the main folder',
      name: 'moveToRootSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Select "{folderName}"`
  String selectCurrentFolder(Object folderName) {
    return Intl.message(
      'Select "$folderName"',
      name: 'selectCurrentFolder',
      desc: '',
      args: [folderName],
    );
  }

  /// `Move to this folder`
  String get selectCurrentFolderSubtitle {
    return Intl.message(
      'Move to this folder',
      name: 'selectCurrentFolderSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No subfolders available`
  String get noSubfoldersAvailable {
    return Intl.message(
      'No subfolders available',
      name: 'noSubfoldersAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Delete Folder: {title}`
  String deleteFolder1(Object title) {
    return Intl.message(
      'Delete Folder: $title',
      name: 'deleteFolder1',
      desc: '',
      args: [title],
    );
  }

  /// `Move File: {title}`
  String moveFile(Object title) {
    return Intl.message(
      'Move File: $title',
      name: 'moveFile',
      desc: '',
      args: [title],
    );
  }

  /// `Category Details: {title}`
  String categoryDetails(Object title) {
    return Intl.message(
      'Category Details: $title',
      name: 'categoryDetails',
      desc: '',
      args: [title],
    );
  }

  /// `Folder Protection`
  String get folderProtection {
    return Intl.message(
      'Folder Protection',
      name: 'folderProtection',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwordHint {
    return Intl.message('Password', name: 'passwordHint', desc: '', args: []);
  }

  /// `Biometric`
  String get biometric {
    return Intl.message('Biometric', name: 'biometric', desc: '', args: []);
  }

  /// `Account verified successfully`
  String get emailVerifiedSuccess {
    return Intl.message(
      'Account verified successfully',
      name: 'emailVerifiedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Verification code is incorrect`
  String get verificationCodeIncorrect {
    return Intl.message(
      'Verification code is incorrect',
      name: 'verificationCodeIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `Failed to resend verification code`
  String get verificationCodeResendFailed {
    return Intl.message(
      'Failed to resend verification code',
      name: 'verificationCodeResendFailed',
      desc: '',
      args: [],
    );
  }

  /// `Verification code sent to your email`
  String get forgotPasswordSuccess {
    return Intl.message(
      'Verification code sent to your email',
      name: 'forgotPasswordSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send verification code`
  String get forgotPasswordFailed {
    return Intl.message(
      'Failed to send verification code',
      name: 'forgotPasswordFailed',
      desc: '',
      args: [],
    );
  }

  /// `Code verified successfully`
  String get resetCodeVerified {
    return Intl.message(
      'Code verified successfully',
      name: 'resetCodeVerified',
      desc: '',
      args: [],
    );
  }

  /// `Code is invalid or expired`
  String get resetCodeInvalid {
    return Intl.message(
      'Code is invalid or expired',
      name: 'resetCodeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Password reset successfully`
  String get resetPasswordSuccess {
    return Intl.message(
      'Password reset successfully',
      name: 'resetPasswordSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to reset password`
  String get resetPasswordFailed {
    return Intl.message(
      'Failed to reset password',
      name: 'resetPasswordFailed',
      desc: '',
      args: [],
    );
  }

  /// `Login failed`
  String get loginFailed {
    return Intl.message(
      'Login failed',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `Account requires email verification`
  String get needsEmailVerification {
    return Intl.message(
      'Account requires email verification',
      name: 'needsEmailVerification',
      desc: '',
      args: [],
    );
  }

  /// `second`
  String get second {
    return Intl.message('second', name: 'second', desc: '', args: []);
  }

  /// `Text`
  String get textLabel {
    return Intl.message('Text', name: 'textLabel', desc: '', args: []);
  }

  /// `File`
  String get defaultFileName {
    return Intl.message('File', name: 'defaultFileName', desc: '', args: []);
  }

  /// `Cannot determine the file`
  String get cannotDetermineFile {
    return Intl.message(
      'Cannot determine the file',
      name: 'cannotDetermineFile',
      desc: '',
      args: [],
    );
  }

  /// `Error loading file details: {error}`
  String errorLoadingFileDetails(Object error) {
    return Intl.message(
      'Error loading file details: $error',
      name: 'errorLoadingFileDetails',
      desc: '',
      args: [error],
    );
  }

  /// `File Details`
  String get fileDetails {
    return Intl.message(
      'File Details',
      name: 'fileDetails',
      desc: '',
      args: [],
    );
  }

  /// `File ID: {id}`
  String fileIdLabel(Object id) {
    return Intl.message(
      'File ID: $id',
      name: 'fileIdLabel',
      desc: '',
      args: [id],
    );
  }

  /// `PDF`
  String get pdf {
    return Intl.message('PDF', name: 'pdf', desc: '', args: []);
  }

  /// `Shared with ({count})`
  String sharedWithCount(Object count) {
    return Intl.message(
      'Shared with ($count)',
      name: 'sharedWithCount',
      desc: '',
      args: [count],
    );
  }

  /// `❌ One-time shared files cannot view details, download, comment, or save`
  String get oneTimeSharedFileError {
    return Intl.message(
      '❌ One-time shared files cannot view details, download, comment, or save',
      name: 'oneTimeSharedFileError',
      desc: '',
      args: [],
    );
  }

  /// `❌ Only the room owner or members with editor role can remove files`
  String get removeFilePermissionError {
    return Intl.message(
      '❌ Only the room owner or members with editor role can remove files',
      name: 'removeFilePermissionError',
      desc: '',
      args: [],
    );
  }

  /// `Choose a folder to save the file`
  String get chooseFolderTitle {
    return Intl.message(
      'Choose a folder to save the file',
      name: 'chooseFolderTitle',
      desc: '',
      args: [],
    );
  }

  /// `Move file: {fileName}`
  String moveFileTitle(Object fileName) {
    return Intl.message(
      'Move file: $fileName',
      name: 'moveFileTitle',
      desc: '',
      args: [fileName],
    );
  }

  /// `One time`
  String get oneTime {
    return Intl.message('One time', name: 'oneTime', desc: '', args: []);
  }

  /// `Bytes`
  String get bytes {
    return Intl.message('Bytes', name: 'bytes', desc: '', args: []);
  }

  /// `KB`
  String get kb {
    return Intl.message('KB', name: 'kb', desc: '', args: []);
  }

  /// `MB`
  String get mb {
    return Intl.message('MB', name: 'mb', desc: '', args: []);
  }

  /// `Failed to load:`
  String get failedToLoad {
    return Intl.message(
      'Failed to load:',
      name: 'failedToLoad',
      desc: '',
      args: [],
    );
  }

  /// `File is empty`
  String get fileEmpty {
    return Intl.message('File is empty', name: 'fileEmpty', desc: '', args: []);
  }

  /// `Failed to load image: {error}`
  String failedToLoadImage1(Object error) {
    return Intl.message(
      'Failed to load image: $error',
      name: 'failedToLoadImage1',
      desc: '',
      args: [error],
    );
  }

  /// `Loading image...`
  String get loadingImage {
    return Intl.message(
      'Loading image...',
      name: 'loadingImage',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get errorr {
    return Intl.message('Error', name: 'errorr', desc: '', args: []);
  }

  /// `View Image`
  String get viewImage {
    return Intl.message('View Image', name: 'viewImage', desc: '', args: []);
  }

  /// `Error loading image: {error}`
  String errorLoadingImage(Object error) {
    return Intl.message(
      'Error loading image: $error',
      name: 'errorLoadingImage',
      desc: '',
      args: [error],
    );
  }

  /// `Invalid image URL`
  String get invalidImageUrl {
    return Intl.message(
      'Invalid image URL',
      name: 'invalidImageUrl',
      desc: '',
      args: [],
    );
  }

  /// `File not found: {path}`
  String fileNotFoundd(Object path) {
    return Intl.message(
      'File not found: $path',
      name: 'fileNotFoundd',
      desc: '',
      args: [path],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `URL: {url}`
  String urlLabel(Object url) {
    return Intl.message('URL: $url', name: 'urlLabel', desc: '', args: [url]);
  }

  /// `Failed to open file. Please install a suitable app (e.g., Microsoft Office or Google Slides)`
  String get installAppPrompt {
    return Intl.message(
      'Failed to open file. Please install a suitable app (e.g., Microsoft Office or Google Slides)',
      name: 'installAppPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Error while downloading file: {error}`
  String downloadError(Object error) {
    return Intl.message(
      'Error while downloading file: $error',
      name: 'downloadError',
      desc: '',
      args: [error],
    );
  }

  /// `Error opening file: {error}`
  String openFileError(Object error) {
    return Intl.message(
      'Error opening file: $error',
      name: 'openFileError',
      desc: '',
      args: [error],
    );
  }

  /// `Download failed (Error {status})`
  String downloadFailedStatus(Object status) {
    return Intl.message(
      'Download failed (Error $status)',
      name: 'downloadFailedStatus',
      desc: '',
      args: [status],
    );
  }

  /// `Choose Action`
  String get chooseAction {
    return Intl.message(
      'Choose Action',
      name: 'chooseAction',
      desc: '',
      args: [],
    );
  }

  /// `No app installed to open this file. Choose an action:`
  String get noAppFoundPrompt {
    return Intl.message(
      'No app installed to open this file. Choose an action:',
      name: 'noAppFoundPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Open with App`
  String get openWithApp {
    return Intl.message(
      'Open with App',
      name: 'openWithApp',
      desc: '',
      args: [],
    );
  }

  /// `Page {current} of {total}`
  String pageOf(Object current, Object total) {
    return Intl.message(
      'Page $current of $total',
      name: 'pageOf',
      desc: '',
      args: [current, total],
    );
  }

  /// `Search in document`
  String get searchInDocument {
    return Intl.message(
      'Search in document',
      name: 'searchInDocument',
      desc: '',
      args: [],
    );
  }

  /// `Show PDF`
  String get showPdf {
    return Intl.message('Show PDF', name: 'showPdf', desc: '', args: []);
  }

  /// `Show Text`
  String get showText {
    return Intl.message('Show Text', name: 'showText', desc: '', args: []);
  }

  /// `Hide navigation bar`
  String get hideNavBar {
    return Intl.message(
      'Hide navigation bar',
      name: 'hideNavBar',
      desc: '',
      args: [],
    );
  }

  /// `Show navigation bar`
  String get showNavBar {
    return Intl.message(
      'Show navigation bar',
      name: 'showNavBar',
      desc: '',
      args: [],
    );
  }

  /// `Full screen mode`
  String get fullScreenMode {
    return Intl.message(
      'Full screen mode',
      name: 'fullScreenMode',
      desc: '',
      args: [],
    );
  }

  /// `The PDF file is corrupted or encrypted. Attempting another way...`
  String get pdfCorruptedOrEncrypted {
    return Intl.message(
      'The PDF file is corrupted or encrypted. Attempting another way...',
      name: 'pdfCorruptedOrEncrypted',
      desc: '',
      args: [],
    );
  }

  /// `The PDF file may be corrupted or encrypted. Page {page}: {error}`
  String pdfCorruptedAtPage(Object page, Object error) {
    return Intl.message(
      'The PDF file may be corrupted or encrypted. Page $page: $error',
      name: 'pdfCorruptedAtPage',
      desc: '',
      args: [page, error],
    );
  }

  /// `First Page`
  String get firstPage {
    return Intl.message('First Page', name: 'firstPage', desc: '', args: []);
  }

  /// `Previous Page`
  String get previousPage {
    return Intl.message(
      'Previous Page',
      name: 'previousPage',
      desc: '',
      args: [],
    );
  }

  /// `Next Page`
  String get nextPage {
    return Intl.message('Next Page', name: 'nextPage', desc: '', args: []);
  }

  /// `Last Page`
  String get lastPage {
    return Intl.message('Last Page', name: 'lastPage', desc: '', args: []);
  }

  /// `Search Suggestions:`
  String get searchSuggestions {
    return Intl.message(
      'Search Suggestions:',
      name: 'searchSuggestions',
      desc: '',
      args: [],
    );
  }

  /// `Search Help`
  String get searchHelp {
    return Intl.message('Search Help', name: 'searchHelp', desc: '', args: []);
  }

  /// `Close Search`
  String get closeSearch {
    return Intl.message(
      'Close Search',
      name: 'closeSearch',
      desc: '',
      args: [],
    );
  }

  /// `Local file not found: {path}`
  String localFileNotFound(Object path) {
    return Intl.message(
      'Local file not found: $path',
      name: 'localFileNotFound',
      desc: '',
      args: [path],
    );
  }

  /// `Edit Mode`
  String get editMode {
    return Intl.message('Edit Mode', name: 'editMode', desc: '', args: []);
  }

  /// `Unsaved changes`
  String get unsavedChangesLabel {
    return Intl.message(
      'Unsaved changes',
      name: 'unsavedChangesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Start typing...`
  String get startTyping {
    return Intl.message(
      'Start typing...',
      name: 'startTyping',
      desc: '',
      args: [],
    );
  }

  /// `No content available`
  String get noContent {
    return Intl.message(
      'No content available',
      name: 'noContent',
      desc: '',
      args: [],
    );
  }

  /// `Error reading file`
  String get errorReadingFile {
    return Intl.message(
      'Error reading file',
      name: 'errorReadingFile',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload file to server`
  String get failedToUploadFile {
    return Intl.message(
      'Failed to upload file to server',
      name: 'failedToUploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Connection reset by server. Please check your connection.`
  String get connectionReset {
    return Intl.message(
      'Connection reset by server. Please check your connection.',
      name: 'connectionReset',
      desc: '',
      args: [],
    );
  }

  /// `Upload timed out. The file might be too large.`
  String get timeoutError {
    return Intl.message(
      'Upload timed out. The file might be too large.',
      name: 'timeoutError',
      desc: '',
      args: [],
    );
  }

  /// `Cannot connect to server. Please check your internet connection.`
  String get socketError {
    return Intl.message(
      'Cannot connect to server. Please check your internet connection.',
      name: 'socketError',
      desc: '',
      args: [],
    );
  }

  /// `Error uploading file: {error}`
  String uploadError(Object error) {
    return Intl.message(
      'Error uploading file: $error',
      name: 'uploadError',
      desc: '',
      args: [error],
    );
  }

  /// `Video Viewer`
  String get videoViewerTitle {
    return Intl.message(
      'Video Viewer',
      name: 'videoViewerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load video`
  String get videoLoadFailed {
    return Intl.message(
      'Failed to load video',
      name: 'videoLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load video: {error}`
  String videoLoadError(Object error) {
    return Intl.message(
      'Failed to load video: $error',
      name: 'videoLoadError',
      desc: '',
      args: [error],
    );
  }

  /// `Subtitle Settings`
  String get subtitlesSettings {
    return Intl.message(
      'Subtitle Settings',
      name: 'subtitlesSettings',
      desc: '',
      args: [],
    );
  }

  /// `Choose subtitle language:`
  String get chooseSubtitleLanguage {
    return Intl.message(
      'Choose subtitle language:',
      name: 'chooseSubtitleLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Additional Settings:`
  String get additionalSettings {
    return Intl.message(
      'Additional Settings:',
      name: 'additionalSettings',
      desc: '',
      args: [],
    );
  }

  /// `Increase font size`
  String get increaseFontSize {
    return Intl.message(
      'Increase font size',
      name: 'increaseFontSize',
      desc: '',
      args: [],
    );
  }

  /// `Subtitle color`
  String get subtitleColor {
    return Intl.message(
      'Subtitle color',
      name: 'subtitleColor',
      desc: '',
      args: [],
    );
  }

  /// `Delete feature will be added soon`
  String get featureComingSoon {
    return Intl.message(
      'Delete feature will be added soon',
      name: 'featureComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Subtitles disabled`
  String get subtitlesDisabled {
    return Intl.message(
      'Subtitles disabled',
      name: 'subtitlesDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Subtitles enabled: {name}`
  String subtitlesEnabled(Object name) {
    return Intl.message(
      'Subtitles enabled: $name',
      name: 'subtitlesEnabled',
      desc: '',
      args: [name],
    );
  }

  /// `Quality changed to {quality}`
  String qualityChanged(Object quality) {
    return Intl.message(
      'Quality changed to $quality',
      name: 'qualityChanged',
      desc: '',
      args: [quality],
    );
  }

  /// `No Subtitles`
  String get noSubtitles {
    return Intl.message(
      'No Subtitles',
      name: 'noSubtitles',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get french {
    return Intl.message('French', name: 'french', desc: '', args: []);
  }

  /// `Spanish`
  String get spanish {
    return Intl.message('Spanish', name: 'spanish', desc: '', args: []);
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Welcome to the Video Player`
  String get welcomeVideoPlayer {
    return Intl.message(
      'Welcome to the Video Player',
      name: 'welcomeVideoPlayer',
      desc: '',
      args: [],
    );
  }

  /// `You can control subtitles and settings`
  String get controlSubtitlesSettings {
    return Intl.message(
      'You can control subtitles and settings',
      name: 'controlSubtitlesSettings',
      desc: '',
      args: [],
    );
  }

  /// `Enjoy watching your video!`
  String get enjoyWatchingVideo {
    return Intl.message(
      'Enjoy watching your video!',
      name: 'enjoyWatchingVideo',
      desc: '',
      args: [],
    );
  }

  /// `Font size settings will be added soon`
  String get fontSizeSettingsComingSoon {
    return Intl.message(
      'Font size settings will be added soon',
      name: 'fontSizeSettingsComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Color settings will be added soon`
  String get colorSettingsComingSoon {
    return Intl.message(
      'Color settings will be added soon',
      name: 'colorSettingsComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message('Auto', name: 'auto', desc: '', args: []);
  }

  /// `Playback Speed`
  String get playbackSpeed {
    return Intl.message(
      'Playback Speed',
      name: 'playbackSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Quality`
  String get quality {
    return Intl.message('Quality', name: 'quality', desc: '', args: []);
  }

  /// `Upload Options`
  String get uploadOptions {
    return Intl.message(
      'Upload Options',
      name: 'uploadOptions',
      desc: '',
      args: [],
    );
  }

  /// `Upload Photo/Video`
  String get uploadPhotoVideo {
    return Intl.message(
      'Upload Photo/Video',
      name: 'uploadPhotoVideo',
      desc: '',
      args: [],
    );
  }

  /// `✅ Upload successful`
  String get uploadSuccess {
    return Intl.message(
      '✅ Upload successful',
      name: 'uploadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `File upload failed`
  String get uploadFailed {
    return Intl.message(
      'File upload failed',
      name: 'uploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Upload cancelled`
  String get uploadCancelled {
    return Intl.message(
      'Upload cancelled',
      name: 'uploadCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Connection error. Please check your internet.`
  String get connectionError {
    return Intl.message(
      'Connection error. Please check your internet.',
      name: 'connectionError',
      desc: '',
      args: [],
    );
  }

  /// `Access denied. Please check your permissions.`
  String get accessDenied {
    return Intl.message(
      'Access denied. Please check your permissions.',
      name: 'accessDenied',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Scanning file for security...`
  String get scanningFile {
    return Intl.message(
      'Scanning file for security...',
      name: 'scanningFile',
      desc: '',
      args: [],
    );
  }

  /// `File is secure`
  String get fileSecure {
    return Intl.message(
      'File is secure',
      name: 'fileSecure',
      desc: '',
      args: [],
    );
  }

  /// `Warning: File may be insecure`
  String get fileInsecure {
    return Intl.message(
      'Warning: File may be insecure',
      name: 'fileInsecure',
      desc: '',
      args: [],
    );
  }

  /// `Storage is full. Please upgrade your plan.`
  String get storageFull {
    return Intl.message(
      'Storage is full. Please upgrade your plan.',
      name: 'storageFull',
      desc: '',
      args: [],
    );
  }

  /// `Create Folder`
  String get CreateFolder {
    return Intl.message(
      'Create Folder',
      name: 'CreateFolder',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Folder name is required`
  String get folderNameRequired {
    return Intl.message(
      '⚠️ Folder name is required',
      name: 'folderNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Please login first`
  String get loginFirst {
    return Intl.message(
      '⚠️ Please login first',
      name: 'loginFirst',
      desc: '',
      args: [],
    );
  }

  /// `📁 Pick the files you want to add to the folder...`
  String get folderUploadStart {
    return Intl.message(
      '📁 Pick the files you want to add to the folder...',
      name: 'folderUploadStart',
      desc: '',
      args: [],
    );
  }

  /// `📁 Reading files...`
  String get readingFiles {
    return Intl.message(
      '📁 Reading files...',
      name: 'readingFiles',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Security Warning`
  String get securityWarning {
    return Intl.message(
      '⚠️ Security Warning',
      name: 'securityWarning',
      desc: '',
      args: [],
    );
  }

  /// `Dangerous files detected:\n\n{files}\n\nThey will be converted to safe text files (.txt) to prevent execution.\n\nDo you want to proceed?`
  String dangerousFilesDetected(Object files) {
    return Intl.message(
      'Dangerous files detected:\n\n$files\n\nThey will be converted to safe text files (.txt) to prevent execution.\n\nDo you want to proceed?',
      name: 'dangerousFilesDetected',
      desc: '',
      args: [files],
    );
  }

  /// `🔐 Converting dangerous file: {fileName}`
  String convertingDangerousFile(Object fileName) {
    return Intl.message(
      '🔐 Converting dangerous file: $fileName',
      name: 'convertingDangerousFile',
      desc: '',
      args: [fileName],
    );
  }

  /// `❌ Cannot read selected files`
  String get cannotReadFiles {
    return Intl.message(
      '❌ Cannot read selected files',
      name: 'cannotReadFiles',
      desc: '',
      args: [],
    );
  }

  /// `Select Target Folder`
  String get selectTargetFolder {
    return Intl.message(
      'Select Target Folder',
      name: 'selectTargetFolder',
      desc: '',
      args: [],
    );
  }

  /// `📁 Uploading folder "{folderName}" ({count} files)...`
  String uploadingFolder(Object folderName, Object count) {
    return Intl.message(
      '📁 Uploading folder "$folderName" ($count files)...',
      name: 'uploadingFolder',
      desc: '',
      args: [folderName, count],
    );
  }

  /// `✅ Folder "{folderName}" uploaded successfully! ({count} files)`
  String uploadFolderSuccess(Object folderName, Object count) {
    return Intl.message(
      '✅ Folder "$folderName" uploaded successfully! ($count files)',
      name: 'uploadFolderSuccess',
      desc: '',
      args: [folderName, count],
    );
  }

  /// `❌ Failed to upload folder`
  String get uploadFolderFailed {
    return Intl.message(
      '❌ Failed to upload folder',
      name: 'uploadFolderFailed',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error uploading folder: {error}`
  String errorUploadingFolder(Object error) {
    return Intl.message(
      '❌ Error uploading folder: $error',
      name: 'errorUploadingFolder',
      desc: '',
      args: [error],
    );
  }

  /// `⚠️ Please grant storage permission from settings`
  String get storagePermissionRequired {
    return Intl.message(
      '⚠️ Please grant storage permission from settings',
      name: 'storagePermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Uploading file...`
  String get uploadingSingleFile {
    return Intl.message(
      'Uploading file...',
      name: 'uploadingSingleFile',
      desc: '',
      args: [],
    );
  }

  /// `Uploading files...`
  String get uploadingMultipleFiles {
    return Intl.message(
      'Uploading files...',
      name: 'uploadingMultipleFiles',
      desc: '',
      args: [],
    );
  }

  /// `✅ {uploadedCount} files uploaded, {errorsCount} rejected after scanning`
  String uploadSuccessWithErrors(Object uploadedCount, Object errorsCount) {
    return Intl.message(
      '✅ $uploadedCount files uploaded, $errorsCount rejected after scanning',
      name: 'uploadSuccessWithErrors',
      desc: '',
      args: [uploadedCount, errorsCount],
    );
  }

  /// `✅ {uploadedCount} files uploaded successfully`
  String uploadSuccessCount(Object uploadedCount) {
    return Intl.message(
      '✅ $uploadedCount files uploaded successfully',
      name: 'uploadSuccessCount',
      desc: '',
      args: [uploadedCount],
    );
  }

  /// `Some files were rejected after virus scanning: {errorNames}`
  String virusScanRejectedPartial(Object errorNames) {
    return Intl.message(
      'Some files were rejected after virus scanning: $errorNames',
      name: 'virusScanRejectedPartial',
      desc: '',
      args: [errorNames],
    );
  }

  /// `❌ All files were rejected after virus scanning: {errorNames}`
  String virusScanRejectedAll(Object errorNames) {
    return Intl.message(
      '❌ All files were rejected after virus scanning: $errorNames',
      name: 'virusScanRejectedAll',
      desc: '',
      args: [errorNames],
    );
  }

  /// `❌ Error uploading files: {error}`
  String errorUploadingFiles(Object error) {
    return Intl.message(
      '❌ Error uploading files: $error',
      name: 'errorUploadingFiles',
      desc: '',
      args: [error],
    );
  }

  /// `Continue`
  String get continuee {
    return Intl.message('Continue', name: 'continuee', desc: '', args: []);
  }

  /// `❌ All files were rejected after virus scanning: {errorNames}`
  String allFilesRejectedVirus(Object errorNames) {
    return Intl.message(
      '❌ All files were rejected after virus scanning: $errorNames',
      name: 'allFilesRejectedVirus',
      desc: '',
      args: [errorNames],
    );
  }

  /// `Some files were rejected after virus scanning`
  String get someFilesRejectedVirus {
    return Intl.message(
      'Some files were rejected after virus scanning',
      name: 'someFilesRejectedVirus',
      desc: '',
      args: [],
    );
  }

  /// `📁 Folder "{folderName}" created successfully`
  String folderCreatedSuccess(Object folderName) {
    return Intl.message(
      '📁 Folder "$folderName" created successfully',
      name: 'folderCreatedSuccess',
      desc: '',
      args: [folderName],
    );
  }

  /// `❌ Failed to create folder: {error}`
  String folderCreateFailed(Object error) {
    return Intl.message(
      '❌ Failed to create folder: $error',
      name: 'folderCreateFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Choose Upload Method`
  String get chooseUploadMethod {
    return Intl.message(
      'Choose Upload Method',
      name: 'chooseUploadMethod',
      desc: '',
      args: [],
    );
  }

  /// `Upload Folder`
  String get uploadFolder {
    return Intl.message(
      'Upload Folder',
      name: 'uploadFolder',
      desc: '',
      args: [],
    );
  }

  /// `Choose folder name then select files`
  String get uploadFolderSubtitle {
    return Intl.message(
      'Choose folder name then select files',
      name: 'uploadFolderSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Upload Multiple Files`
  String get uploadMultipleFiles {
    return Intl.message(
      'Upload Multiple Files',
      name: 'uploadMultipleFiles',
      desc: '',
      args: [],
    );
  }

  /// `Select multiple individual files`
  String get uploadMultipleFilesSubtitle {
    return Intl.message(
      'Select multiple individual files',
      name: 'uploadMultipleFilesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Create an empty folder`
  String get createEmptyFolderSubtitle {
    return Intl.message(
      'Create an empty folder',
      name: 'createEmptyFolderSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Upload Files`
  String get uploadFiles {
    return Intl.message(
      'Upload Files',
      name: 'uploadFiles',
      desc: '',
      args: [],
    );
  }

  /// `Select one or multiple files`
  String get uploadFilesSubtitle {
    return Intl.message(
      'Select one or multiple files',
      name: 'uploadFilesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Added to favorites`
  String get addedToFavorites {
    return Intl.message(
      'Added to favorites',
      name: 'addedToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Removed from favorites`
  String get removedFromFavorites {
    return Intl.message(
      'Removed from favorites',
      name: 'removedFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Bytes`
  String get unitBytes {
    return Intl.message('Bytes', name: 'unitBytes', desc: '', args: []);
  }

  /// `KB`
  String get unitKB {
    return Intl.message('KB', name: 'unitKB', desc: '', args: []);
  }

  /// `MB`
  String get unitMB {
    return Intl.message('MB', name: 'unitMB', desc: '', args: []);
  }

  /// `GB`
  String get unitGB {
    return Intl.message('GB', name: 'unitGB', desc: '', args: []);
  }

  /// `Starred Folders`
  String get starredFolders {
    return Intl.message(
      'Starred Folders',
      name: 'starredFolders',
      desc: '',
      args: [],
    );
  }

  /// `No favorite folders found`
  String get noFavoriteFolders {
    return Intl.message(
      'No favorite folders found',
      name: 'noFavoriteFolders',
      desc: '',
      args: [],
    );
  }

  /// `Failed to remove from favorites`
  String get failedToRemoveFromFavorites {
    return Intl.message(
      'Failed to remove from favorites',
      name: 'failedToRemoveFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update `
  String get failedToUpdate {
    return Intl.message(
      'Failed to update ',
      name: 'failedToUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update password`
  String get failedToUpdatePassword {
    return Intl.message(
      'Failed to update password',
      name: 'failedToUpdatePassword',
      desc: '',
      args: [],
    );
  }

  /// `You must allow microphone access to search by voice.\n\nPlease open app settings and grant microphone permission.`
  String get microphonePermissionContent {
    return Intl.message(
      'You must allow microphone access to search by voice.\n\nPlease open app settings and grant microphone permission.',
      name: 'microphonePermissionContent',
      desc: '',
      args: [],
    );
  }

  /// `Search failed`
  String get searchFailed {
    return Intl.message(
      'Search failed',
      name: 'searchFailed',
      desc: '',
      args: [],
    );
  }

  /// `Listening...`
  String get listening {
    return Intl.message('Listening...', name: 'listening', desc: '', args: []);
  }

  /// `All`
  String get scopeAll {
    return Intl.message('All', name: 'scopeAll', desc: '', args: []);
  }

  /// `My Files`
  String get scopeMyFiles {
    return Intl.message('My Files', name: 'scopeMyFiles', desc: '', args: []);
  }

  /// `Shared`
  String get scopeShared {
    return Intl.message('Shared', name: 'scopeShared', desc: '', args: []);
  }

  /// `Rooms`
  String get scopeRooms {
    return Intl.message('Rooms', name: 'scopeRooms', desc: '', args: []);
  }

  /// `Search in your files`
  String get searchInFiles {
    return Intl.message(
      'Search in your files',
      name: 'searchInFiles',
      desc: '',
      args: [],
    );
  }

  /// `Example: "Project files"`
  String get searchExample {
    return Intl.message(
      'Example: "Project files"',
      name: 'searchExample',
      desc: '',
      args: [],
    );
  }

  /// `Voice Search`
  String get voiceSearch {
    return Intl.message(
      'Voice Search',
      name: 'voiceSearch',
      desc: '',
      args: [],
    );
  }

  /// `Registration stopped`
  String get Registrationstopped {
    return Intl.message(
      'Registration stopped',
      name: 'Registrationstopped',
      desc: '',
      args: [],
    );
  }

  /// `File Uploaded`
  String get file_uploaded {
    return Intl.message(
      'File Uploaded',
      name: 'file_uploaded',
      desc: '',
      args: [],
    );
  }

  /// `File Downloaded`
  String get file_downloaded {
    return Intl.message(
      'File Downloaded',
      name: 'file_downloaded',
      desc: '',
      args: [],
    );
  }

  /// `File Deleted`
  String get file_deleted {
    return Intl.message(
      'File Deleted',
      name: 'file_deleted',
      desc: '',
      args: [],
    );
  }

  /// `File Restored`
  String get file_restored {
    return Intl.message(
      'File Restored',
      name: 'file_restored',
      desc: '',
      args: [],
    );
  }

  /// `File Permanently Deleted`
  String get file_permanently_deleted {
    return Intl.message(
      'File Permanently Deleted',
      name: 'file_permanently_deleted',
      desc: '',
      args: [],
    );
  }

  /// `File Updated`
  String get file_updated {
    return Intl.message(
      'File Updated',
      name: 'file_updated',
      desc: '',
      args: [],
    );
  }

  /// `File Moved`
  String get file_moved {
    return Intl.message('File Moved', name: 'file_moved', desc: '', args: []);
  }

  /// `Added File to Favorites`
  String get file_starred {
    return Intl.message(
      'Added File to Favorites',
      name: 'file_starred',
      desc: '',
      args: [],
    );
  }

  /// `Removed File from Favorites`
  String get file_unstarred {
    return Intl.message(
      'Removed File from Favorites',
      name: 'file_unstarred',
      desc: '',
      args: [],
    );
  }

  /// `File Shared`
  String get file_shared {
    return Intl.message('File Shared', name: 'file_shared', desc: '', args: []);
  }

  /// `File Unshared`
  String get file_unshared {
    return Intl.message(
      'File Unshared',
      name: 'file_unshared',
      desc: '',
      args: [],
    );
  }

  /// `One-time File Access`
  String get file_accessed_onetime {
    return Intl.message(
      'One-time File Access',
      name: 'file_accessed_onetime',
      desc: '',
      args: [],
    );
  }

  /// `File Viewed by All Members`
  String get file_viewed_by_all_members {
    return Intl.message(
      'File Viewed by All Members',
      name: 'file_viewed_by_all_members',
      desc: '',
      args: [],
    );
  }

  /// `Folder Created`
  String get folder_created {
    return Intl.message(
      'Folder Created',
      name: 'folder_created',
      desc: '',
      args: [],
    );
  }

  /// `Folder Uploaded`
  String get folder_uploaded {
    return Intl.message(
      'Folder Uploaded',
      name: 'folder_uploaded',
      desc: '',
      args: [],
    );
  }

  /// `Folder Deleted`
  String get folder_deleted {
    return Intl.message(
      'Folder Deleted',
      name: 'folder_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Folder Restored`
  String get folder_restored {
    return Intl.message(
      'Folder Restored',
      name: 'folder_restored',
      desc: '',
      args: [],
    );
  }

  /// `Folder Permanently Deleted`
  String get folder_permanently_deleted {
    return Intl.message(
      'Folder Permanently Deleted',
      name: 'folder_permanently_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Folder Updated`
  String get folder_updated {
    return Intl.message(
      'Folder Updated',
      name: 'folder_updated',
      desc: '',
      args: [],
    );
  }

  /// `Folder Moved`
  String get folder_moved {
    return Intl.message(
      'Folder Moved',
      name: 'folder_moved',
      desc: '',
      args: [],
    );
  }

  /// `Added Folder to Favorites`
  String get folder_starred {
    return Intl.message(
      'Added Folder to Favorites',
      name: 'folder_starred',
      desc: '',
      args: [],
    );
  }

  /// `Removed Folder from Favorites`
  String get folder_unstarred {
    return Intl.message(
      'Removed Folder from Favorites',
      name: 'folder_unstarred',
      desc: '',
      args: [],
    );
  }

  /// `Folder Shared`
  String get folder_shared {
    return Intl.message(
      'Folder Shared',
      name: 'folder_shared',
      desc: '',
      args: [],
    );
  }

  /// `Folder Unshared`
  String get folder_unshared {
    return Intl.message(
      'Folder Unshared',
      name: 'folder_unshared',
      desc: '',
      args: [],
    );
  }

  /// `Profile Updated`
  String get profile_updated {
    return Intl.message(
      'Profile Updated',
      name: 'profile_updated',
      desc: '',
      args: [],
    );
  }

  /// `Password Changed`
  String get password_changed {
    return Intl.message(
      'Password Changed',
      name: 'password_changed',
      desc: '',
      args: [],
    );
  }

  /// `Email Changed`
  String get email_changed {
    return Intl.message(
      'Email Changed',
      name: 'email_changed',
      desc: '',
      args: [],
    );
  }

  /// `Account Deleted`
  String get account_deleted {
    return Intl.message(
      'Account Deleted',
      name: 'account_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Password Reset Requested`
  String get password_reset_requested {
    return Intl.message(
      'Password Reset Requested',
      name: 'password_reset_requested',
      desc: '',
      args: [],
    );
  }

  /// `Password Reset Completed`
  String get password_reset_completed {
    return Intl.message(
      'Password Reset Completed',
      name: 'password_reset_completed',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Action`
  String get unknown_action {
    return Intl.message(
      'Unknown Action',
      name: 'unknown_action',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get entityFile {
    return Intl.message('File', name: 'entityFile', desc: '', args: []);
  }

  /// `Folder`
  String get entityFolder {
    return Intl.message('Folder', name: 'entityFolder', desc: '', args: []);
  }

  /// `User`
  String get entityUser {
    return Intl.message('User', name: 'entityUser', desc: '', args: []);
  }

  /// `System`
  String get entitySystem {
    return Intl.message('System', name: 'entitySystem', desc: '', args: []);
  }

  /// `Room`
  String get entityRoom {
    return Intl.message('Room', name: 'entityRoom', desc: '', args: []);
  }

  /// `Just now`
  String get now {
    return Intl.message('Just now', name: 'now', desc: '', args: []);
  }

  /// `{count, plural, =1{1 minute ago} other{{count} minutes ago}}`
  String minutesAgo(num count) {
    return Intl.plural(
      count,
      one: '1 minute ago',
      other: '$count minutes ago',
      name: 'minutesAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 hour ago} other{{count} hours ago}}`
  String hoursAgo(num count) {
    return Intl.plural(
      count,
      one: '1 hour ago',
      other: '$count hours ago',
      name: 'hoursAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 day ago} other{{count} days ago}}`
  String daysAgo(num count) {
    return Intl.plural(
      count,
      one: '1 day ago',
      other: '$count days ago',
      name: 'daysAgo',
      desc: '',
      args: [count],
    );
  }

  /// `Showing last 100 activity logs`
  String get showingLast100Logs {
    return Intl.message(
      'Showing last 100 activity logs',
      name: 'showingLast100Logs',
      desc: '',
      args: [],
    );
  }

  /// `No activities found`
  String get noActivities {
    return Intl.message(
      'No activities found',
      name: 'noActivities',
      desc: '',
      args: [],
    );
  }

  /// `Your activities will be displayed here`
  String get activitiesWillShowHere {
    return Intl.message(
      'Your activities will be displayed here',
      name: 'activitiesWillShowHere',
      desc: '',
      args: [],
    );
  }

  /// `Total Activity`
  String get totalActivity {
    return Intl.message(
      'Total Activity',
      name: 'totalActivity',
      desc: '',
      args: [],
    );
  }

  /// `Period`
  String get period {
    return Intl.message('Period', name: 'period', desc: '', args: []);
  }

  /// `Last 30 days`
  String get days30 {
    return Intl.message('Last 30 days', name: 'days30', desc: '', args: []);
  }

  /// `Action`
  String get actionLabel {
    return Intl.message('Action', name: 'actionLabel', desc: '', args: []);
  }

  /// `Item Type`
  String get entityTypeLabel {
    return Intl.message(
      'Item Type',
      name: 'entityTypeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get detailsTitle {
    return Intl.message('Details', name: 'detailsTitle', desc: '', args: []);
  }

  /// `Additional Information`
  String get additionalInfo {
    return Intl.message(
      'Additional Information',
      name: 'additionalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get typeLabel {
    return Intl.message('Type', name: 'typeLabel', desc: '', args: []);
  }

  /// `Date`
  String get dateLabel {
    return Intl.message('Date', name: 'dateLabel', desc: '', args: []);
  }

  /// `Storage Usage`
  String get storageUsage {
    return Intl.message(
      'Storage Usage',
      name: 'storageUsage',
      desc: '',
      args: [],
    );
  }

  /// `Used {used} GB of {total} GB`
  String usedOfTotal(Object used, Object total) {
    return Intl.message(
      'Used $used GB of $total GB',
      name: 'usedOfTotal',
      desc: '',
      args: [used, total],
    );
  }

  /// `Buy More Storage`
  String get buyStorage {
    return Intl.message(
      'Buy More Storage',
      name: 'buyStorage',
      desc: '',
      args: [],
    );
  }

  /// `Purchase flow coming soon!`
  String get purchaseComingSoon {
    return Intl.message(
      'Purchase flow coming soon!',
      name: 'purchaseComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `File restored successfully`
  String get fileRestoredSuccess {
    return Intl.message(
      'File restored successfully',
      name: 'fileRestoredSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to restore file`
  String get errorRestoringFile {
    return Intl.message(
      'Failed to restore file',
      name: 'errorRestoringFile',
      desc: '',
      args: [],
    );
  }

  /// `File permanently deleted`
  String get fileDeletedPermanently {
    return Intl.message(
      'File permanently deleted',
      name: 'fileDeletedPermanently',
      desc: '',
      args: [],
    );
  }

  /// `Restore File`
  String get restoreFile {
    return Intl.message(
      'Restore File',
      name: 'restoreFile',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Permanent Deletion`
  String get confirmDeleteTitle {
    return Intl.message(
      'Confirm Permanent Deletion',
      name: 'confirmDeleteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to permanently delete the file '{fileName}'? This action cannot be undone.`
  String confirmDeleteMessage(Object fileName) {
    return Intl.message(
      'Are you sure you want to permanently delete the file \'$fileName\'? This action cannot be undone.',
      name: 'confirmDeleteMessage',
      desc: '',
      args: [fileName],
    );
  }

  /// `Empty Trash`
  String get emptyTrashTitle {
    return Intl.message(
      'Empty Trash',
      name: 'emptyTrashTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to empty the trash? All files will be permanently deleted and cannot be restored.`
  String get emptyTrashMessage {
    return Intl.message(
      'Are you sure you want to empty the trash? All files will be permanently deleted and cannot be restored.',
      name: 'emptyTrashMessage',
      desc: '',
      args: [],
    );
  }

  /// `Empty`
  String get empty {
    return Intl.message('Empty', name: 'empty', desc: '', args: []);
  }

  /// `Trash`
  String get trashTitle {
    return Intl.message('Trash', name: 'trashTitle', desc: '', args: []);
  }

  /// `Empty Trash`
  String get emptyTrash {
    return Intl.message('Empty Trash', name: 'emptyTrash', desc: '', args: []);
  }

  /// `Will be permanently deleted after 30 days`
  String get autoDeleteNotice {
    return Intl.message(
      'Will be permanently deleted after 30 days',
      name: 'autoDeleteNotice',
      desc: '',
      args: [],
    );
  }

  /// `No deleted files found`
  String get noDeletedFiles {
    return Intl.message(
      'No deleted files found',
      name: 'noDeletedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Unnamed file`
  String get unnamedFile {
    return Intl.message(
      'Unnamed file',
      name: 'unnamedFile',
      desc: '',
      args: [],
    );
  }

  /// `Deleted at: {date}`
  String deletedAt(Object date) {
    return Intl.message(
      'Deleted at: $date',
      name: 'deletedAt',
      desc: '',
      args: [date],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message('Restore', name: 'restore', desc: '', args: []);
  }

  /// `✅ Folder restored successfully`
  String get folderRestoredSuccess {
    return Intl.message(
      '✅ Folder restored successfully',
      name: 'folderRestoredSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to restore folder`
  String get folderRestoredError {
    return Intl.message(
      '❌ Failed to restore folder',
      name: 'folderRestoredError',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder deleted permanently`
  String get folderPermanentDeleteSuccess {
    return Intl.message(
      '✅ Folder deleted permanently',
      name: 'folderPermanentDeleteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to permanently delete folder`
  String get folderPermanentDeleteError {
    return Intl.message(
      '❌ Failed to permanently delete folder',
      name: 'folderPermanentDeleteError',
      desc: '',
      args: [],
    );
  }

  /// `Restore Folder`
  String get restoreFolder {
    return Intl.message(
      'Restore Folder',
      name: 'restoreFolder',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Permanent Deletion`
  String get confirmFolderDeleteTitle {
    return Intl.message(
      'Confirm Permanent Deletion',
      name: 'confirmFolderDeleteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to permanently delete the folder '{folderName}'? This action cannot be undone. All sub-files and folders will be permanently deleted.`
  String confirmFolderDeleteMessage(Object folderName) {
    return Intl.message(
      'Are you sure you want to permanently delete the folder \'$folderName\'? This action cannot be undone. All sub-files and folders will be permanently deleted.',
      name: 'confirmFolderDeleteMessage',
      desc: '',
      args: [folderName],
    );
  }

  /// `Deleted Folders`
  String get deletedFoldersTitle {
    return Intl.message(
      'Deleted Folders',
      name: 'deletedFoldersTitle',
      desc: '',
      args: [],
    );
  }

  /// `Folders`
  String get foldersCount {
    return Intl.message('Folders', name: 'foldersCount', desc: '', args: []);
  }

  /// `No deleted folders found`
  String get noDeletedFolders {
    return Intl.message(
      'No deleted folders found',
      name: 'noDeletedFolders',
      desc: '',
      args: [],
    );
  }

  /// `Will be permanently deleted after 30 days`
  String get autoDeleteNoticeFolders {
    return Intl.message(
      'Will be permanently deleted after 30 days',
      name: 'autoDeleteNoticeFolders',
      desc: '',
      args: [],
    );
  }

  /// `Deleted at: {date}`
  String deletedAta(Object date) {
    return Intl.message(
      'Deleted at: $date',
      name: 'deletedAta',
      desc: '',
      args: [date],
    );
  }

  /// `Select custom date range`
  String get selectCustomDateRange {
    return Intl.message(
      'Select custom date range',
      name: 'selectCustomDateRange',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message('From', name: 'from', desc: '', args: []);
  }

  /// `To`
  String get to {
    return Intl.message('To', name: 'to', desc: '', args: []);
  }

  /// `Unclassify`
  String get unclassify {
    return Intl.message('Unclassify', name: 'unclassify', desc: '', args: []);
  }

  /// `Clear Date`
  String get clearDate {
    return Intl.message('Clear Date', name: 'clearDate', desc: '', args: []);
  }

  /// `{count, plural, =0{No results found} =1{Search results: 1 result} other{Search results: {count} results}}`
  String searchResults(num count) {
    return Intl.plural(
      count,
      zero: 'No results found',
      one: 'Search results: 1 result',
      other: 'Search results: $count results',
      name: 'searchResults',
      desc: '',
      args: [count],
    );
  }

  /// `No search results found`
  String get noSearchResults {
    return Intl.message(
      'No search results found',
      name: 'noSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `Folders ({count})`
  String foldersWithCount(Object count) {
    return Intl.message(
      'Folders ($count)',
      name: 'foldersWithCount',
      desc: '',
      args: [count],
    );
  }

  /// `Files ({count})`
  String filesWithCount(Object count) {
    return Intl.message(
      'Files ($count)',
      name: 'filesWithCount',
      desc: '',
      args: [count],
    );
  }

  /// `Enter room name`
  String get roomNameHint {
    return Intl.message(
      'Enter room name',
      name: 'roomNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Room Description (Optional)`
  String get roomDescription {
    return Intl.message(
      'Room Description (Optional)',
      name: 'roomDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enter room description`
  String get roomDescriptionHint {
    return Intl.message(
      'Enter room description',
      name: 'roomDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `✅ Room created successfully`
  String get roomCreatedSuccess {
    return Intl.message(
      '✅ Room created successfully',
      name: 'roomCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to create room`
  String get roomCreatedError {
    return Intl.message(
      '❌ Failed to create room',
      name: 'roomCreatedError',
      desc: '',
      args: [],
    );
  }

  /// `File link is unavailable - Missing path or ID`
  String get fileLinkUnavailable {
    return Intl.message(
      'File link is unavailable - Missing path or ID',
      name: 'fileLinkUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `File unavailable (Error: {code})`
  String fileUnavailableWithCode(Object code) {
    return Intl.message(
      'File unavailable (Error: $code)',
      name: 'fileUnavailableWithCode',
      desc: '',
      args: [code],
    );
  }

  /// `Error downloading file`
  String get errorDownloadingFile1 {
    return Intl.message(
      'Error downloading file',
      name: 'errorDownloadingFile1',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Loading contents...`
  String get loadingContents {
    return Intl.message(
      'Loading contents...',
      name: 'loadingContents',
      desc: '',
      args: [],
    );
  }

  /// `Folder is empty`
  String get emptyFolderTitle {
    return Intl.message(
      'Folder is empty',
      name: 'emptyFolderTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can add new files or folders`
  String get emptyFolderSubtitle {
    return Intl.message(
      'You can add new files or folders',
      name: 'emptyFolderSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get deleteConfirmTitle {
    return Intl.message(
      'Confirm Delete',
      name: 'deleteConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the folder "{folderName}"?\nAll contents will be permanently deleted.`
  String deleteConfirmMessage(Object folderName) {
    return Intl.message(
      'Are you sure you want to delete the folder "$folderName"?\nAll contents will be permanently deleted.',
      name: 'deleteConfirmMessage',
      desc: '',
      args: [folderName],
    );
  }

  /// `Images`
  String get catImages {
    return Intl.message('Images', name: 'catImages', desc: '', args: []);
  }

  /// `Videos`
  String get catVideos {
    return Intl.message('Videos', name: 'catVideos', desc: '', args: []);
  }

  /// `Audio`
  String get catAudio {
    return Intl.message('Audio', name: 'catAudio', desc: '', args: []);
  }

  /// `Documents`
  String get catDocuments {
    return Intl.message('Documents', name: 'catDocuments', desc: '', args: []);
  }

  /// `Compressed`
  String get catCompressed {
    return Intl.message(
      'Compressed',
      name: 'catCompressed',
      desc: '',
      args: [],
    );
  }

  /// `Applications`
  String get catApplications {
    return Intl.message(
      'Applications',
      name: 'catApplications',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get catCode {
    return Intl.message('Code', name: 'catCode', desc: '', args: []);
  }

  /// `Others`
  String get catOthers {
    return Intl.message('Others', name: 'catOthers', desc: '', args: []);
  }

  /// `User`
  String get unknownUser {
    return Intl.message('User', name: 'unknownUser', desc: '', args: []);
  }

  /// `Speech recognition error: {error}`
  String speechRecognitionError(Object error) {
    return Intl.message(
      'Speech recognition error: $error',
      name: 'speechRecognitionError',
      desc: '',
      args: [error],
    );
  }

  /// `Could not initialize voice service`
  String get speechInitializationError {
    return Intl.message(
      'Could not initialize voice service',
      name: 'speechInitializationError',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition error: {message}`
  String speechError(Object message) {
    return Intl.message(
      'Speech recognition error: $message',
      name: 'speechError',
      desc: '',
      args: [message],
    );
  }

  /// `Could not initialize voice service`
  String get speechInitError {
    return Intl.message(
      'Could not initialize voice service',
      name: 'speechInitError',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition is not available on this device`
  String get speechNotAvailable {
    return Intl.message(
      'Speech recognition is not available on this device',
      name: 'speechNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Microphone Permission Required`
  String get micPermissionRequired {
    return Intl.message(
      'Microphone Permission Required',
      name: 'micPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Microphone access is required for voice search.\n\nPlease open app settings and allow microphone access.`
  String get micPermissionMessage {
    return Intl.message(
      'Microphone access is required for voice search.\n\nPlease open app settings and allow microphone access.',
      name: 'micPermissionMessage',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition service is unavailable`
  String get speechServiceUnavailable {
    return Intl.message(
      'Speech recognition service is unavailable',
      name: 'speechServiceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Recognized text: {text}`
  String recognizedText(Object text) {
    return Intl.message(
      'Recognized text: $text',
      name: 'recognizedText',
      desc: '',
      args: [text],
    );
  }

  /// `Stop Listening`
  String get stopListening {
    return Intl.message(
      'Stop Listening',
      name: 'stopListening',
      desc: '',
      args: [],
    );
  }

  /// `Rooms`
  String get rooms {
    return Intl.message('Rooms', name: 'rooms', desc: '', args: []);
  }

  /// `Create share room`
  String get createShareRoomTooltip {
    return Intl.message(
      'Create share room',
      name: 'createShareRoomTooltip',
      desc: '',
      args: [],
    );
  }

  /// `No share rooms found`
  String get noShareRooms {
    return Intl.message(
      'No share rooms found',
      name: 'noShareRooms',
      desc: '',
      args: [],
    );
  }

  /// `Click on + to create a new share room`
  String get clickToAddRoom {
    return Intl.message(
      'Click on + to create a new share room',
      name: 'clickToAddRoom',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed`
  String get unnamed {
    return Intl.message('Unnamed', name: 'unnamed', desc: '', args: []);
  }

  /// `❌ Only the room owner or editors can edit the room`
  String get onlyOwnerOrEditorCanEdit {
    return Intl.message(
      '❌ Only the room owner or editors can edit the room',
      name: 'onlyOwnerOrEditorCanEdit',
      desc: '',
      args: [],
    );
  }

  /// `Invalid file URL`
  String get invalidFileUrl {
    return Intl.message(
      'Invalid file URL',
      name: 'invalidFileUrl',
      desc: '',
      args: [],
    );
  }

  /// `File unavailable (Error {code})`
  String fileUnavailable(Object code) {
    return Intl.message(
      'File unavailable (Error $code)',
      name: 'fileUnavailable',
      desc: '',
      args: [code],
    );
  }

  /// `📁 Folder "{name}" created successfully`
  String createFolderSuccess(Object name) {
    return Intl.message(
      '📁 Folder "$name" created successfully',
      name: 'createFolderSuccess',
      desc: '',
      args: [name],
    );
  }

  /// `❌ {error}`
  String createFolderFailure(Object error) {
    return Intl.message(
      '❌ $error',
      name: 'createFolderFailure',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to create folder`
  String get createFolderFailureDefault {
    return Intl.message(
      'Failed to create folder',
      name: 'createFolderFailureDefault',
      desc: '',
      args: [],
    );
  }

  /// `✅ Room created successfully`
  String get roomCreatedSuccessfully {
    return Intl.message(
      '✅ Room created successfully',
      name: 'roomCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Edit Room`
  String get editRoom {
    return Intl.message('Edit Room', name: 'editRoom', desc: '', args: []);
  }

  /// `Description (Optional)`
  String get descriptionOptional {
    return Intl.message(
      'Description (Optional)',
      name: 'descriptionOptional',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Room name cannot be empty`
  String get roomNameEmptyError {
    return Intl.message(
      '⚠️ Room name cannot be empty',
      name: 'roomNameEmptyError',
      desc: '',
      args: [],
    );
  }

  /// `✅ Room updated successfully`
  String get updateRoomSuccess {
    return Intl.message(
      '✅ Room updated successfully',
      name: 'updateRoomSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to update room`
  String get updateRoomFailure {
    return Intl.message(
      '❌ Failed to update room',
      name: 'updateRoomFailure',
      desc: '',
      args: [],
    );
  }

  /// ` member`
  String get oneMember {
    return Intl.message(' member', name: 'oneMember', desc: '', args: []);
  }

  /// `{count, plural, =0{No members} =1{1 Member} other{{count} Members}}`
  String membersCount(num count) {
    return Intl.plural(
      count,
      zero: 'No members',
      one: '1 Member',
      other: '$count Members',
      name: 'membersCount',
      desc: '',
      args: [count],
    );
  }

  /// `✅ Invitation accepted successfully`
  String get invitationAccepted {
    return Intl.message(
      '✅ Invitation accepted successfully',
      name: 'invitationAccepted',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to accept invitation`
  String get invitationAcceptFailed {
    return Intl.message(
      '❌ Failed to accept invitation',
      name: 'invitationAcceptFailed',
      desc: '',
      args: [],
    );
  }

  /// `✅ Invitation declined`
  String get invitationRejected {
    return Intl.message(
      '✅ Invitation declined',
      name: 'invitationRejected',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to decline invitation`
  String get invitationRejectFailed {
    return Intl.message(
      '❌ Failed to decline invitation',
      name: 'invitationRejectFailed',
      desc: '',
      args: [],
    );
  }

  /// `No pending invitations`
  String get noPendingInvitations {
    return Intl.message(
      'No pending invitations',
      name: 'noPendingInvitations',
      desc: '',
      args: [],
    );
  }

  /// `Invitations will appear here when received`
  String get invitationsHint {
    return Intl.message(
      'Invitations will appear here when received',
      name: 'invitationsHint',
      desc: '',
      args: [],
    );
  }

  /// `invited you to join a room`
  String get invitedYouToJoin {
    return Intl.message(
      'invited you to join a room',
      name: 'invitedYouToJoin',
      desc: '',
      args: [],
    );
  }

  /// `Role: {role}`
  String roleLabel(Object role) {
    return Intl.message(
      'Role: $role',
      name: 'roleLabel',
      desc: '',
      args: [role],
    );
  }

  /// `Admin`
  String get roleAdmin {
    return Intl.message('Admin', name: 'roleAdmin', desc: '', args: []);
  }

  /// `Editor`
  String get roleEditor {
    return Intl.message('Editor', name: 'roleEditor', desc: '', args: []);
  }

  /// `Viewer`
  String get roleViewer {
    return Intl.message('Viewer', name: 'roleViewer', desc: '', args: []);
  }

  /// `❌ You don't have permission to add comments. Only Owner, Editor, and Commenter can add comments`
  String get noPermissionAddComment {
    return Intl.message(
      '❌ You don\'t have permission to add comments. Only Owner, Editor, and Commenter can add comments',
      name: 'noPermissionAddComment',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a comment`
  String get pleaseEnterComment {
    return Intl.message(
      'Please enter a comment',
      name: 'pleaseEnterComment',
      desc: '',
      args: [],
    );
  }

  /// `✅ Comment added successfully`
  String get addCommentSuccess {
    return Intl.message(
      '✅ Comment added successfully',
      name: 'addCommentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to add comment`
  String get addCommentFailure {
    return Intl.message(
      '❌ Failed to add comment',
      name: 'addCommentFailure',
      desc: '',
      args: [],
    );
  }

  /// `✅ Comment deleted successfully`
  String get deleteCommentSuccess {
    return Intl.message(
      '✅ Comment deleted successfully',
      name: 'deleteCommentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to delete comment`
  String get deleteCommentFailure {
    return Intl.message(
      '❌ Failed to delete comment',
      name: 'deleteCommentFailure',
      desc: '',
      args: [],
    );
  }

  /// `Select file or folder`
  String get selectFileOrFolder {
    return Intl.message(
      'Select file or folder',
      name: 'selectFileOrFolder',
      desc: '',
      args: [],
    );
  }

  /// `File/Folder ID`
  String get fileOrFolderId {
    return Intl.message(
      'File/Folder ID',
      name: 'fileOrFolderId',
      desc: '',
      args: [],
    );
  }

  /// `Select a file or folder to view comments`
  String get selectTargetToViewComments {
    return Intl.message(
      'Select a file or folder to view comments',
      name: 'selectTargetToViewComments',
      desc: '',
      args: [],
    );
  }

  /// `No comments yet`
  String get noCommentsYet {
    return Intl.message(
      'No comments yet',
      name: 'noCommentsYet',
      desc: '',
      args: [],
    );
  }

  /// `Be the first to comment`
  String get beTheFirstToComment {
    return Intl.message(
      'Be the first to comment',
      name: 'beTheFirstToComment',
      desc: '',
      args: [],
    );
  }

  /// `Write a comment...`
  String get writeComment {
    return Intl.message(
      'Write a comment...',
      name: 'writeComment',
      desc: '',
      args: [],
    );
  }

  /// `MMM d, yyyy`
  String get fullDateFormat {
    return Intl.message(
      'MMM d, yyyy',
      name: 'fullDateFormat',
      desc: '',
      args: [],
    );
  }

  /// `💡 To share: Open the file/folder from its page and select "Share with Room"`
  String get shareInstruction {
    return Intl.message(
      '💡 To share: Open the file/folder from its page and select "Share with Room"',
      name: 'shareInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Unknown File`
  String get unknownFile {
    return Intl.message(
      'Unknown File',
      name: 'unknownFile',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{Shared Folders} =1{Shared Folder (1)} other{Shared Folders ({count})}}`
  String sharedFoldersTitle(num count) {
    return Intl.plural(
      count,
      zero: 'Shared Folders',
      one: 'Shared Folder (1)',
      other: 'Shared Folders ($count)',
      name: 'sharedFoldersTitle',
      desc: '',
      args: [count],
    );
  }

  /// `💡 To share: Open the folder from the Folders page and select "Share with Room"`
  String get folderShareInstruction {
    return Intl.message(
      '💡 To share: Open the folder from the Folders page and select "Share with Room"',
      name: 'folderShareInstruction',
      desc: '',
      args: [],
    );
  }

  /// `No shared folders`
  String get noSharedFolders {
    return Intl.message(
      'No shared folders',
      name: 'noSharedFolders',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Folder`
  String get unknownFolder {
    return Intl.message(
      'Unknown Folder',
      name: 'unknownFolder',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to update favorite status`
  String get failedToUpdateFavorite {
    return Intl.message(
      '❌ Failed to update favorite status',
      name: 'failedToUpdateFavorite',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to remove file from room`
  String get failedToRemoveFileFromRoom {
    return Intl.message(
      '❌ Failed to remove file from room',
      name: 'failedToRemoveFileFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder removed from room successfully`
  String get folderRemovedFromRoom {
    return Intl.message(
      '✅ Folder removed from room successfully',
      name: 'folderRemovedFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to remove folder from room`
  String get failedToRemoveFolderFromRoom {
    return Intl.message(
      '❌ Failed to remove folder from room',
      name: 'failedToRemoveFolderFromRoom',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder added to favorite successfully`
  String get folderAddedToFavorite {
    return Intl.message(
      '✅ Folder added to favorite successfully',
      name: 'folderAddedToFavorite',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder removed from favorite successfully`
  String get folderRemovedFromFavorite {
    return Intl.message(
      '✅ Folder removed from favorite successfully',
      name: 'folderRemovedFromFavorite',
      desc: '',
      args: [],
    );
  }

  /// `✅ Room deleted successfully`
  String get roomDeletedSuccessfully {
    return Intl.message(
      '✅ Room deleted successfully',
      name: 'roomDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to delete room`
  String get roomDeletionFailed {
    return Intl.message(
      '❌ Failed to delete room',
      name: 'roomDeletionFailed',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error: {errorMessage}`
  String errorPrefix(Object errorMessage) {
    return Intl.message(
      '❌ Error: $errorMessage',
      name: 'errorPrefix',
      desc: '',
      args: [errorMessage],
    );
  }

  /// `✅ Left room successfully`
  String get roomLeftSuccessfully {
    return Intl.message(
      '✅ Left room successfully',
      name: 'roomLeftSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to leave room`
  String get roomLeaveFailed {
    return Intl.message(
      '❌ Failed to leave room',
      name: 'roomLeaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `File not found or has expired`
  String get fileNotFoundOrExpired {
    return Intl.message(
      'File not found or has expired',
      name: 'fileNotFoundOrExpired',
      desc: '',
      args: [],
    );
  }

  /// `File has expired`
  String get fileExpired {
    return Intl.message(
      'File has expired',
      name: 'fileExpired',
      desc: '',
      args: [],
    );
  }

  /// `Room Folders`
  String get roomFolders {
    return Intl.message(
      'Room Folders',
      name: 'roomFolders',
      desc: '',
      args: [],
    );
  }

  /// `Share Folders with Room`
  String get shareFoldersWithRoom {
    return Intl.message(
      'Share Folders with Room',
      name: 'shareFoldersWithRoom',
      desc: '',
      args: [],
    );
  }

  /// `❌ Only the room owner or members with Editor role can remove folders`
  String get removeFolderPermissionError {
    return Intl.message(
      '❌ Only the room owner or members with Editor role can remove folders',
      name: 'removeFolderPermissionError',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder "{folderName}" has been saved to your account successfully`
  String saveFolderSuccess(Object folderName) {
    return Intl.message(
      '✅ Folder "$folderName" has been saved to your account successfully',
      name: 'saveFolderSuccess',
      desc: '',
      args: [folderName],
    );
  }

  /// `❌ Failed to save folder`
  String get saveFolderFailure {
    return Intl.message(
      '❌ Failed to save folder',
      name: 'saveFolderFailure',
      desc: '',
      args: [],
    );
  }

  /// `Select a folder to save to`
  String get selectDestinationFolder {
    return Intl.message(
      'Select a folder to save to',
      name: 'selectDestinationFolder',
      desc: '',
      args: [],
    );
  }

  /// `Folder will be saved in Main Directory`
  String get willBeSavedInRoot {
    return Intl.message(
      'Folder will be saved in Main Directory',
      name: 'willBeSavedInRoot',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder removed from room successfully`
  String get removeFolderFromRoomSuccess {
    return Intl.message(
      '✅ Folder removed from room successfully',
      name: 'removeFolderFromRoomSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to remove folder from room`
  String get removeFolderFromRoomFailure {
    return Intl.message(
      '❌ Failed to remove folder from room',
      name: 'removeFolderFromRoomFailure',
      desc: '',
      args: [],
    );
  }

  /// `✅ Role updated successfully`
  String get updateRoleSuccess {
    return Intl.message(
      '✅ Role updated successfully',
      name: 'updateRoleSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to update role`
  String get updateRoleFailure {
    return Intl.message(
      '❌ Failed to update role',
      name: 'updateRoleFailure',
      desc: '',
      args: [],
    );
  }

  /// `✅ Member removed successfully`
  String get removeMemberSuccess {
    return Intl.message(
      '✅ Member removed successfully',
      name: 'removeMemberSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to remove member`
  String get removeMemberFailure {
    return Intl.message(
      '❌ Failed to remove member',
      name: 'removeMemberFailure',
      desc: '',
      args: [],
    );
  }

  /// `Share Permission`
  String get sharepermission {
    return Intl.message(
      'Share Permission',
      name: 'sharepermission',
      desc: '',
      args: [],
    );
  }

  /// `Update Role`
  String get updateRole {
    return Intl.message('Update Role', name: 'updateRole', desc: '', args: []);
  }

  /// `Allow Sharing`
  String get allowSharing {
    return Intl.message(
      'Allow Sharing',
      name: 'allowSharing',
      desc: '',
      args: [],
    );
  }

  /// `User can share files and folders in this room`
  String get allowSharingDescription {
    return Intl.message(
      'User can share files and folders in this room',
      name: 'allowSharingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Member`
  String get member {
    return Intl.message('Member', name: 'member', desc: '', args: []);
  }

  /// `❌ Cannot modify the owner's role`
  String get cannotModifyOwnerRole {
    return Intl.message(
      '❌ Cannot modify the owner\'s role',
      name: 'cannotModifyOwnerRole',
      desc: '',
      args: [],
    );
  }

  /// `✅ Invitation sent successfully`
  String get invitationSentSuccess {
    return Intl.message(
      '✅ Invitation sent successfully',
      name: 'invitationSentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to send invitation`
  String get invitationSentFailure {
    return Intl.message(
      '❌ Failed to send invitation',
      name: 'invitationSentFailure',
      desc: '',
      args: [],
    );
  }

  /// `Invite New User`
  String get inviteNewUser {
    return Intl.message(
      'Invite New User',
      name: 'inviteNewUser',
      desc: '',
      args: [],
    );
  }

  /// `Enter email address to send an invitation`
  String get enterEmailToInvite {
    return Intl.message(
      'Enter email address to send an invitation',
      name: 'enterEmailToInvite',
      desc: '',
      args: [],
    );
  }

  /// `Email Address*`
  String get emailAddress {
    return Intl.message(
      'Email Address*',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Role*`
  String get role {
    return Intl.message('Role*', name: 'role', desc: '', args: []);
  }

  /// `Message (Optional)`
  String get messageLabel {
    return Intl.message(
      'Message (Optional)',
      name: 'messageLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add a welcome message...`
  String get messageHint {
    return Intl.message(
      'Add a welcome message...',
      name: 'messageHint',
      desc: '',
      args: [],
    );
  }

  /// `ℹ️ Folder is already shared with this room`
  String get folderAlreadyShared {
    return Intl.message(
      'ℹ️ Folder is already shared with this room',
      name: 'folderAlreadyShared',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ You do not have permission to share in this room`
  String get noPermissionToShareInRoom {
    return Intl.message(
      '⚠️ You do not have permission to share in this room',
      name: 'noPermissionToShareInRoom',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Only room owner can share`
  String get onlyRoomOwnerCanShare {
    return Intl.message(
      '⚠️ Only room owner can share',
      name: 'onlyRoomOwnerCanShare',
      desc: '',
      args: [],
    );
  }

  /// `✅ File shared with the room (One-time) successfully`
  String get fileSharedSuccessOneTime {
    return Intl.message(
      '✅ File shared with the room (One-time) successfully',
      name: 'fileSharedSuccessOneTime',
      desc: '',
      args: [],
    );
  }

  /// `✅ File shared with the room successfully`
  String get fileSharedSuccess {
    return Intl.message(
      '✅ File shared with the room successfully',
      name: 'fileSharedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to share file `
  String get fileShareFailed {
    return Intl.message(
      '❌ Failed to share file ',
      name: 'fileShareFailed',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Files opened outside the app (Office, ZIP, etc.) cannot be shared as one-time access.`
  String get externalFilesWarning {
    return Intl.message(
      '⚠️ Files opened outside the app (Office, ZIP, etc.) cannot be shared as one-time access.',
      name: 'externalFilesWarning',
      desc: '',
      args: [],
    );
  }

  /// `Please enter User ID`
  String get pleaseEnterUserId {
    return Intl.message(
      'Please enter User ID',
      name: 'pleaseEnterUserId',
      desc: '',
      args: [],
    );
  }

  /// `User is already in the list`
  String get userAlreadyInList {
    return Intl.message(
      'User is already in the list',
      name: 'userAlreadyInList',
      desc: '',
      args: [],
    );
  }

  /// `Please add at least one user`
  String get addAtLeastOneUser {
    return Intl.message(
      'Please add at least one user',
      name: 'addAtLeastOneUser',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder shared successfully`
  String get folderSharedSuccessfully {
    return Intl.message(
      '✅ Folder shared successfully',
      name: 'folderSharedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to share folder`
  String get failedToShareFolder {
    return Intl.message(
      '❌ Failed to share folder',
      name: 'failedToShareFolder',
      desc: '',
      args: [],
    );
  }

  /// `No starred folders found`
  String get noStarredFolders {
    return Intl.message(
      'No starred folders found',
      name: 'noStarredFolders',
      desc: '',
      args: [],
    );
  }

  /// `Share Folder `
  String get shareFolder {
    return Intl.message(
      'Share Folder ',
      name: 'shareFolder',
      desc: '',
      args: [],
    );
  }

  /// `You can add folders to favorites through the menu`
  String get addToFavoritesInstruction {
    return Intl.message(
      'You can add folders to favorites through the menu',
      name: 'addToFavoritesInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch folders list`
  String get failedToFetchFolders {
    return Intl.message(
      'Failed to fetch folders list',
      name: 'failedToFetchFolders',
      desc: '',
      args: [],
    );
  }

  /// `Move Folder`
  String get moveFolder {
    return Intl.message('Move Folder', name: 'moveFolder', desc: '', args: []);
  }

  /// `Moving folder to root...`
  String get movingToRoot {
    return Intl.message(
      'Moving folder to root...',
      name: 'movingToRoot',
      desc: '',
      args: [],
    );
  }

  /// `Request timed out. The folder might be too large. Please try again.`
  String get transferTimeout {
    return Intl.message(
      'Request timed out. The folder might be too large. Please try again.',
      name: 'transferTimeout',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while moving the folder: {error}`
  String transferError(Object error) {
    return Intl.message(
      'An error occurred while moving the folder: $error',
      name: 'transferError',
      desc: '',
      args: [error],
    );
  }

  /// `Add Users`
  String get addUsers {
    return Intl.message('Add Users', name: 'addUsers', desc: '', args: []);
  }

  /// `Enter User ID to share`
  String get enterUserIdToShare {
    return Intl.message(
      'Enter User ID to share',
      name: 'enterUserIdToShare',
      desc: '',
      args: [],
    );
  }

  /// `Selected Users ({count})`
  String selectedUsersCount(Object count) {
    return Intl.message(
      'Selected Users ($count)',
      name: 'selectedUsersCount',
      desc: '',
      args: [count],
    );
  }

  /// `Permissions`
  String get permissions {
    return Intl.message('Permissions', name: 'permissions', desc: '', args: []);
  }

  /// `View and Edit`
  String get viewAndEdit {
    return Intl.message(
      'View and Edit',
      name: 'viewAndEdit',
      desc: '',
      args: [],
    );
  }

  /// `View, Edit, and Delete`
  String get fullAccess {
    return Intl.message(
      'View, Edit, and Delete',
      name: 'fullAccess',
      desc: '',
      args: [],
    );
  }

  /// `✅ Folder shared with the room successfully`
  String get folderSharedSuccess {
    return Intl.message(
      '✅ Folder shared with the room successfully',
      name: 'folderSharedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to share the folder`
  String get folderSharedFailed {
    return Intl.message(
      '❌ Failed to share the folder',
      name: 'folderSharedFailed',
      desc: '',
      args: [],
    );
  }

  /// `New file shared: {fileName}`
  String newFileShared(String fileName) {
    return Intl.message(
      'New file shared: $fileName',
      name: 'newFileShared',
      desc: '',
      args: [fileName],
    );
  }

  /// `New folder shared: {folderName}`
  String newFolderShared(String folderName) {
    return Intl.message(
      'New folder shared: $folderName',
      name: 'newFolderShared',
      desc: '',
      args: [folderName],
    );
  }

  /// `Create a room first to start sharing`
  String get createRoomFirstToShare {
    return Intl.message(
      'Create a room first to start sharing',
      name: 'createRoomFirstToShare',
      desc: '',
      args: [],
    );
  }

  /// `Shared`
  String get sharedd {
    return Intl.message('Shared', name: 'sharedd', desc: '', args: []);
  }

  /// `Select "{name}"`
  String selectFolderNamed(Object name) {
    return Intl.message(
      'Select "$name"',
      name: 'selectFolderNamed',
      desc: '',
      args: [name],
    );
  }

  /// `Lock Folder`
  String get lockFolder {
    return Intl.message('Lock Folder', name: 'lockFolder', desc: '', args: []);
  }

  /// `Remove Folder Protection`
  String get unlockFolder {
    return Intl.message(
      'Remove Folder Protection',
      name: 'unlockFolder',
      desc: '',
      args: [],
    );
  }

  /// `Folder: {folderName}`
  String folderLabel(String folderName) {
    return Intl.message(
      'Folder: $folderName',
      name: 'folderLabel',
      desc: '',
      args: [folderName],
    );
  }

  /// `Enter password to lock folder:`
  String get enterPasswordToLockFolder {
    return Intl.message(
      'Enter password to lock folder:',
      name: 'enterPasswordToLockFolder',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwordLabel {
    return Intl.message('Password', name: 'passwordLabel', desc: '', args: []);
  }

  /// `Enter password (at least 4 characters)`
  String get enterPasswordHint {
    return Intl.message(
      'Enter password (at least 4 characters)',
      name: 'enterPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPasswordLabel {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Re-enter password`
  String get reenterPasswordHint {
    return Intl.message(
      'Re-enter password',
      name: 'reenterPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to remove protection from this folder?`
  String get removeProtectionQuestion {
    return Intl.message(
      'Do you want to remove protection from this folder?',
      name: 'removeProtectionQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get currentPasswordLabel {
    return Intl.message(
      'Current Password',
      name: 'currentPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter password to remove protection`
  String get enterPasswordToRemoveProtection {
    return Intl.message(
      'Enter password to remove protection',
      name: 'enterPasswordToRemoveProtection',
      desc: '',
      args: [],
    );
  }

  /// `Please enter password`
  String get pleaseEnterPassword {
    return Intl.message(
      'Please enter password',
      name: 'pleaseEnterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 4 characters`
  String get passwordMin4Chars {
    return Intl.message(
      'Password must be at least 4 characters',
      name: 'passwordMin4Chars',
      desc: '',
      args: [],
    );
  }

  /// `Failed to enable folder protection`
  String get failedToEnableProtection {
    return Intl.message(
      'Failed to enable folder protection',
      name: 'failedToEnableProtection',
      desc: '',
      args: [],
    );
  }

  /// `Failed to remove folder protection`
  String get failedToRemoveProtection {
    return Intl.message(
      'Failed to remove folder protection',
      name: 'failedToRemoveProtection',
      desc: '',
      args: [],
    );
  }

  /// `Protected Folder`
  String get protectedFolder {
    return Intl.message(
      'Protected Folder',
      name: 'protectedFolder',
      desc: '',
      args: [],
    );
  }

  /// `Folder "{folderName}" is protected`
  String folderIsProtected(String folderName) {
    return Intl.message(
      'Folder "$folderName" is protected',
      name: 'folderIsProtected',
      desc: '',
      args: [folderName],
    );
  }

  /// `Use fingerprint to access`
  String get useFingerprintToAccess {
    return Intl.message(
      'Use fingerprint to access',
      name: 'useFingerprintToAccess',
      desc: '',
      args: [],
    );
  }

  /// `Verify with Fingerprint`
  String get verifyWithFingerprint {
    return Intl.message(
      'Verify with Fingerprint',
      name: 'verifyWithFingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get incorrectPassword {
    return Intl.message(
      'Incorrect password',
      name: 'incorrectPassword',
      desc: '',
      args: [],
    );
  }

  /// `Fingerprint not available on this device`
  String get fingerprintNotAvailable {
    return Intl.message(
      'Fingerprint not available on this device',
      name: 'fingerprintNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Please verify fingerprint to access folder`
  String get pleaseVerifyFingerprint {
    return Intl.message(
      'Please verify fingerprint to access folder',
      name: 'pleaseVerifyFingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Failed to verify fingerprint`
  String get failedToVerifyFingerprint {
    return Intl.message(
      'Failed to verify fingerprint',
      name: 'failedToVerifyFingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Fingerprint verification error: {error}`
  String fingerprintVerificationError(String error) {
    return Intl.message(
      'Fingerprint verification error: $error',
      name: 'fingerprintVerificationError',
      desc: '',
      args: [error],
    );
  }

  /// `Available`
  String get storageAvailable {
    return Intl.message(
      'Available',
      name: 'storageAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Cannot share protected folders`
  String get cannotShareProtectedFolder {
    return Intl.message(
      'Cannot share protected folders',
      name: 'cannotShareProtectedFolder',
      desc: '',
      args: [],
    );
  }

  /// `Folder is protected. Please verify password first`
  String get folderProtectedVerifyPassword {
    return Intl.message(
      'Folder is protected. Please verify password first',
      name: 'folderProtectedVerifyPassword',
      desc: '',
      args: [],
    );
  }

  /// `Error loading folder contents: {error}`
  String errorLoadingFolderContents(String error) {
    return Intl.message(
      'Error loading folder contents: $error',
      name: 'errorLoadingFolderContents',
      desc: '',
      args: [error],
    );
  }

  /// `Rate limit exceeded. Please try again later.`
  String get rateLimitExceeded {
    return Intl.message(
      'Rate limit exceeded. Please try again later.',
      name: 'rateLimitExceeded',
      desc: '',
      args: [],
    );
  }

  /// `File not found in this room or inside a shared folder`
  String get fileNotFoundInRoom {
    return Intl.message(
      'File not found in this room or inside a shared folder',
      name: 'fileNotFoundInRoom',
      desc: '',
      args: [],
    );
  }

  /// `Error loading video: {error}`
  String errorLoadingVideoFolderContents(String error) {
    return Intl.message(
      'Error loading video: $error',
      name: 'errorLoadingVideoFolderContents',
      desc: '',
      args: [error],
    );
  }

  /// `You do not have permission to access this file`
  String get noPermissionToAccessFile {
    return Intl.message(
      'You do not have permission to access this file',
      name: 'noPermissionToAccessFile',
      desc: '',
      args: [],
    );
  }

  /// `Access denied or file already accessed`
  String get accessDeniedOrFileAlreadyAccessed {
    return Intl.message(
      'Access denied or file already accessed',
      name: 'accessDeniedOrFileAlreadyAccessed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
