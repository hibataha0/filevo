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

  /// `Please enter your password`
  String get enterPassword {
    return Intl.message(
      'Please enter your password',
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

  /// `Search anything here`
  String get searchHint {
    return Intl.message(
      'Search anything here',
      name: 'searchHint',
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

  /// `Folder Name`
  String get folderNameHint {
    return Intl.message(
      'Folder Name',
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

  /// `This file is not a valid PDF or may be corrupted.`
  String get invalidPdfFile {
    return Intl.message(
      'This file is not a valid PDF or may be corrupted.',
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

  /// `This file is already shared with this room`
  String get fileAlreadyShared {
    return Intl.message(
      'This file is already shared with this room',
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

  /// `{roomName}`
  String roomName(Object roomName) {
    return Intl.message(
      '$roomName',
      name: 'roomName',
      desc: '',
      args: [roomName],
    );
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

  /// `Select "{folderName}"`
  String selectFolder(String folderName) {
    return Intl.message(
      'Select "$folderName"',
      name: 'selectFolder',
      desc: '',
      args: [folderName],
    );
  }

  /// `No folders available`
  String get noFoldersAvailable {
    return Intl.message(
      'No folders available',
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

  /// `File saved and uploaded to server successfully`
  String get fileSavedAndUploaded {
    return Intl.message(
      'File saved and uploaded to server successfully',
      name: 'fileSavedAndUploaded',
      desc: '',
      args: [],
    );
  }

  /// `File saved locally only. Please try again to upload to server`
  String get fileSavedLocallyOnly {
    return Intl.message(
      'File saved locally only. Please try again to upload to server',
      name: 'fileSavedLocallyOnly',
      desc: '',
      args: [],
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

  /// `Unsaved changes`
  String get unsavedChanges {
    return Intl.message(
      'Unsaved changes',
      name: 'unsavedChanges',
      desc: '',
      args: [],
    );
  }

  /// `You have unsaved changes. Do you want to exit without saving?`
  String get unsavedChangesMessage {
    return Intl.message(
      'You have unsaved changes. Do you want to exit without saving?',
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

  /// `Failed to load PDF`
  String get failedToLoadPdf {
    return Intl.message(
      'Failed to load PDF',
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

  /// `✅ Changes saved successfully`
  String get changesSavedSuccessfully {
    return Intl.message(
      '✅ Changes saved successfully',
      name: 'changesSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error: {error}`
  String errorOccurred(String error) {
    return Intl.message(
      '❌ Error: $error',
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

  /// `Edit File`
  String get editFileMetadata {
    return Intl.message(
      'Edit File',
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

  /// `Tags (separate with comma)`
  String get tagsSeparatedByComma {
    return Intl.message(
      'Tags (separate with comma)',
      name: 'tagsSeparatedByComma',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to save changes`
  String get changesSaveFailed {
    return Intl.message(
      '❌ Failed to save changes',
      name: 'changesSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the file '{fileName}'?`
  String confirmDeleteFile(String fileName) {
    return Intl.message(
      'Are you sure you want to delete the file \'$fileName\'?',
      name: 'confirmDeleteFile',
      desc: '',
      args: [fileName],
    );
  }

  /// `❌ Error: No token found.`
  String get noTokenError {
    return Intl.message(
      '❌ Error: No token found.',
      name: 'noTokenError',
      desc: '',
      args: [],
    );
  }

  /// `✅ File '{fileName}' deleted successfully`
  String fileDeletedSuccessfully(String fileName) {
    return Intl.message(
      '✅ File \'$fileName\' deleted successfully',
      name: 'fileDeletedSuccessfully',
      desc: '',
      args: [fileName],
    );
  }

  /// `❌ Error deleting file: {error}`
  String errorDeletingFile(String error) {
    return Intl.message(
      '❌ Error deleting file: $error',
      name: 'errorDeletingFile',
      desc: '',
      args: [error],
    );
  }

  /// `No users shared with this file`
  String get noUsersSharedWith {
    return Intl.message(
      'No users shared with this file',
      name: 'noUsersSharedWith',
      desc: '',
      args: [],
    );
  }

  /// `Cannot identify users to unshare`
  String get cannotIdentifyUsers {
    return Intl.message(
      'Cannot identify users to unshare',
      name: 'cannotIdentifyUsers',
      desc: '',
      args: [],
    );
  }

  /// `✅ File unshared successfully`
  String get unshareFileSuccess {
    return Intl.message(
      '✅ File unshared successfully',
      name: 'unshareFileSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to unshare`
  String get unshareFailed {
    return Intl.message(
      'Failed to unshare',
      name: 'unshareFailed',
      desc: '',
      args: [],
    );
  }

  /// `✅ File added to favorites`
  String get fileAddedToFavorites {
    return Intl.message(
      '✅ File added to favorites',
      name: 'fileAddedToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `✅ File removed from favorites`
  String get fileRemovedFromFavorites {
    return Intl.message(
      '✅ File removed from favorites',
      name: 'fileRemovedFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error updating`
  String get errorUpdating {
    return Intl.message(
      '❌ Error updating',
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

  /// `✅ File downloaded successfully: {fileName}`
  String fileDownloadedSuccessfully(String fileName) {
    return Intl.message(
      '✅ File downloaded successfully: $fileName',
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

  /// `❌ Error downloading file: {error}`
  String errorDownloadingFile(String error) {
    return Intl.message(
      '❌ Error downloading file: $error',
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

  /// `✅ Share request sent to room`
  String get shareRequestSent {
    return Intl.message(
      '✅ Share request sent to room',
      name: 'shareRequestSent',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to unshare this file with all users?`
  String get unshareFileConfirm {
    return Intl.message(
      'Are you sure you want to unshare this file with all users?',
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

  /// `Error: You must log in first`
  String get mustLoginFirstError {
    return Intl.message(
      'Error: You must log in first',
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

  /// `Failed to open file: {error}`
  String failedToOpenFile(String error) {
    return Intl.message(
      'Failed to open file: $error',
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

  /// `Move to Root`
  String get moveToRoot {
    return Intl.message('Move to Root', name: 'moveToRoot', desc: '', args: []);
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

  /// `Permanent Delete`
  String get permanentDelete {
    return Intl.message(
      'Permanent Delete',
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

  /// `Verification code has been sent to your email`
  String get verificationCodeSent {
    return Intl.message(
      'Verification code has been sent to your email',
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

  /// `Please enter room name`
  String get pleaseEnterRoomName {
    return Intl.message(
      'Please enter room name',
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

  /// `Files count`
  String get filesCount {
    return Intl.message('Files count', name: 'filesCount', desc: '', args: []);
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

  /// `Folder without name`
  String get folderWithoutName {
    return Intl.message(
      'Folder without name',
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

  /// `No shared files`
  String get noSharedFiles {
    return Intl.message(
      'No shared files',
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

  /// `Unknown error`
  String get unknownError {
    return Intl.message(
      'Unknown error',
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

  /// `Microphone permission required`
  String get microphonePermissionRequired {
    return Intl.message(
      'Microphone permission required',
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

  /// `Permission denied`
  String get permissionDenied {
    return Intl.message(
      'Permission denied',
      name: 'permissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Must allow microphone access`
  String get mustAllowMicrophoneAccess {
    return Intl.message(
      'Must allow microphone access',
      name: 'mustAllowMicrophoneAccess',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition not available`
  String get speechRecognitionNotAvailable {
    return Intl.message(
      'Speech recognition not available',
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

  /// `❌ Failed to update folder`
  String get folderUpdateFailed {
    return Intl.message(
      '❌ Failed to update folder',
      name: 'folderUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to move folder`
  String get folderMoveFailed {
    return Intl.message(
      '❌ Failed to move folder',
      name: 'folderMoveFailed',
      desc: '',
      args: [],
    );
  }

  /// `❌ Failed to update favorite status`
  String get favoriteUpdateFailed {
    return Intl.message(
      '❌ Failed to update favorite status',
      name: 'favoriteUpdateFailed',
      desc: '',
      args: [],
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

  /// `Move folder`
  String get moveFolderTitle {
    return Intl.message(
      'Move folder',
      name: 'moveFolderTitle',
      desc: '',
      args: [],
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

  /// `Tags (separate with commas)`
  String get tagsLabel {
    return Intl.message(
      'Tags (separate with commas)',
      name: 'tagsLabel',
      desc: '',
      args: [],
    );
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
