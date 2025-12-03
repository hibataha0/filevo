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
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
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
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flievo`
  String get appTitle {
    return Intl.message(
      'Flievo',
      name: 'appTitle',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with`
  String get signInWith {
    return Intl.message(
      'Sign in with',
      name: 'signInWith',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Mobile`
  String get mobile {
    return Intl.message(
      'Mobile',
      name: 'mobile',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Sign up with`
  String get signUpWith {
    return Intl.message(
      'Sign up with',
      name: 'signUpWith',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Log In',
      name: 'logIn',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'See all',
      name: 'seeAll',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Used',
      name: 'storageUsed',
      desc: '',
      args: [],
    );
  }

  /// `60%`
  String get storageUsedValue {
    return Intl.message(
      '60%',
      name: 'storageUsedValue',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `My Files`
  String get myFiles {
    return Intl.message(
      'My Files',
      name: 'myFiles',
      desc: '',
      args: [],
    );
  }

  /// `Shared`
  String get shared {
    return Intl.message(
      'Shared',
      name: 'shared',
      desc: '',
      args: [],
    );
  }

  /// `All Items`
  String get allItems {
    return Intl.message(
      'All Items',
      name: 'allItems',
      desc: '',
      args: [],
    );
  }

  /// `My Folders`
  String get myFolders {
    return Intl.message(
      'My Folders',
      name: 'myFolders',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `Images`
  String get images {
    return Intl.message(
      'Images',
      name: 'images',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get videos {
    return Intl.message(
      'Videos',
      name: 'videos',
      desc: '',
      args: [],
    );
  }

  /// `Audio`
  String get audio {
    return Intl.message(
      'Audio',
      name: 'audio',
      desc: '',
      args: [],
    );
  }

  /// `Compressed`
  String get compressed {
    return Intl.message(
      'Compressed',
      name: 'compressed',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Documents',
      name: 'documents',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get code {
    return Intl.message(
      'Code',
      name: 'code',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  /// `Time & Date`
  String get timeAndDate {
    return Intl.message(
      'Time & Date',
      name: 'timeAndDate',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message(
      'Yesterday',
      name: 'yesterday',
      desc: '',
      args: [],
    );
  }

  /// `Last 7 days`
  String get last7Days {
    return Intl.message(
      'Last 7 days',
      name: 'last7Days',
      desc: '',
      args: [],
    );
  }

  /// `Last 30 days`
  String get last30Days {
    return Intl.message(
      'Last 30 days',
      name: 'last30Days',
      desc: '',
      args: [],
    );
  }

  /// `Last year`
  String get lastYear {
    return Intl.message(
      'Last year',
      name: 'lastYear',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message(
      'Custom',
      name: 'custom',
      desc: '',
      args: [],
    );
  }

  /// `Used`
  String get used {
    return Intl.message(
      'Used',
      name: 'used',
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

  /// `Used storage:`
  String get usedStorage {
    return Intl.message(
      'Used storage:',
      name: 'usedStorage',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabic {
    return Intl.message(
      'Arabic',
      name: 'arabic',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get preferences {
    return Intl.message(
      'Preferences',
      name: 'preferences',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Storage',
      name: 'storage',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Support',
      name: 'support',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Send Code',
      name: 'sendCode',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get resendCode {
    return Intl.message(
      'Resend Code',
      name: 'resendCode',
      desc: '',
      args: [],
    );
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

  /// `Invalid or expired code`
  String get invalidOrExpiredCode {
    return Intl.message(
      'Invalid or expired code',
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
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Updated',
      name: 'updated',
      desc: '',
      args: [],
    );
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

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
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
    return Intl.message(
      'Invalid URL',
      name: 'invalidUrl',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Open as Text',
      name: 'openAsText',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Delete Room',
      name: 'deleteRoom',
      desc: '',
      args: [],
    );
  }

  /// `Leave Room`
  String get leaveRoom {
    return Intl.message(
      'Leave Room',
      name: 'leaveRoom',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete "{roomName}"? All data associated with the room will be deleted.`
  String deleteRoomConfirm(String roomName) {
    return Intl.message(
      'Are you sure you want to delete "$roomName"? All data associated with the room will be deleted.',
      name: 'deleteRoomConfirm',
      desc: '',
      args: [roomName],
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
    return Intl.message(
      'Leave',
      name: 'leave',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get owner {
    return Intl.message(
      'Owner',
      name: 'owner',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get members {
    return Intl.message(
      'Members',
      name: 'members',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get files {
    return Intl.message(
      'Files',
      name: 'files',
      desc: '',
      args: [],
    );
  }

  /// `Folders`
  String get folders {
    return Intl.message(
      'Folders',
      name: 'folders',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Comments',
      name: 'comments',
      desc: '',
      args: [],
    );
  }

  /// `Room Info`
  String get roomInfo {
    return Intl.message(
      'Room Info',
      name: 'roomInfo',
      desc: '',
      args: [],
    );
  }

  /// `Created at`
  String get createdAt {
    return Intl.message(
      'Created at',
      name: 'createdAt',
      desc: '',
      args: [],
    );
  }

  /// `Last Modified`
  String get lastModified {
    return Intl.message(
      'Last Modified',
      name: 'lastModified',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message(
      'View All',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }

  /// `No members`
  String get noMembers {
    return Intl.message(
      'No members',
      name: 'noMembers',
      desc: '',
      args: [],
    );
  }

  /// `Shared Files ({count})`
  String sharedFilesCount(String count) {
    return Intl.message(
      'Shared Files ($count)',
      name: 'sharedFilesCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count}`
  String filesCount(Object count) {
    return Intl.message(
      '$count',
      name: 'filesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Add File`
  String get addFile {
    return Intl.message(
      'Add File',
      name: 'addFile',
      desc: '',
      args: [],
    );
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

  /// `Please open the file details page and share it with the room from there`
  String get openFileDetailsToShare {
    return Intl.message(
      'Please open the file details page and share it with the room from there',
      name: 'openFileDetailsToShare',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Add Folder`
  String get addFolder {
    return Intl.message(
      'Add Folder',
      name: 'addFolder',
      desc: '',
      args: [],
    );
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

  /// `Please open the folder details page and share it with the room from there`
  String get openFolderDetailsToShare {
    return Intl.message(
      'Please open the folder details page and share it with the room from there',
      name: 'openFolderDetailsToShare',
      desc: '',
      args: [],
    );
  }

  /// `Error: Folder ID not found`
  String get folderIdNotAvailable {
    return Intl.message(
      'Error: Folder ID not found',
      name: 'folderIdNotAvailable',
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

  /// `Error loading room details`
  String get errorLoadingRoomDetails {
    return Intl.message(
      'Error loading room details',
      name: 'errorLoadingRoomDetails',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Edit Email',
      name: 'editEmail',
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

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
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

  /// `Current password is required`
  String get currentPasswordRequired {
    return Intl.message(
      'Current password is required',
      name: 'currentPasswordRequired',
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

  /// `Password confirmation is required`
  String get passwordConfirmationRequired {
    return Intl.message(
      'Password confirmation is required',
      name: 'passwordConfirmationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordMinLength {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordMinLength',
      desc: '',
      args: [],
    );
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

  /// `Please enter a valid email address`
  String get validEmailRequired {
    return Intl.message(
      'Please enter a valid email address',
      name: 'validEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Updated successfully`
  String get updatedSuccessfully {
    return Intl.message(
      'Updated successfully',
      name: 'updatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update`
  String get updateFailed {
    return Intl.message(
      'Failed to update',
      name: 'updateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Password updated successfully`
  String get passwordUpdatedSuccessfully {
    return Intl.message(
      'Password updated successfully',
      name: 'passwordUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update password`
  String get passwordUpdateFailed {
    return Intl.message(
      'Failed to update password',
      name: 'passwordUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Trash`
  String get trash {
    return Intl.message(
      'Trash',
      name: 'trash',
      desc: '',
      args: [],
    );
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

  /// `Token not found`
  String get tokenNotFound {
    return Intl.message(
      'Token not found',
      name: 'tokenNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Logged out successfully`
  String get logoutSuccess {
    return Intl.message(
      'Logged out successfully',
      name: 'logoutSuccess',
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

  /// `Share files with this room`
  String get shareFilesWithRoom {
    return Intl.message(
      'Share files with this room',
      name: 'shareFilesWithRoom',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message(
      'File',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `File not available (error {statusCode})`
  String fileNotAvailable(Object statusCode) {
    return Intl.message(
      'File not available (error $statusCode)',
      name: 'fileNotAvailable',
      desc: '',
      args: [statusCode],
    );
  }

  /// `Error loading file`
  String get errorLoadingFile {
    return Intl.message(
      'Error loading file',
      name: 'errorLoadingFile',
      desc: '',
      args: [],
    );
  }

  /// `Error opening file`
  String get errorOpeningFile {
    return Intl.message(
      'Error opening file',
      name: 'errorOpeningFile',
      desc: '',
      args: [],
    );
  }

  /// `Unknown file`
  String get unknownFile {
    return Intl.message(
      'Unknown file',
      name: 'unknownFile',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message(
      'User',
      name: 'user',
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
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Accessed`
  String get accessed {
    return Intl.message(
      'Accessed',
      name: 'accessed',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Shared by`
  String get sharedBy {
    return Intl.message(
      'Shared by',
      name: 'sharedBy',
      desc: '',
      args: [],
    );
  }

  /// `Modified`
  String get modified {
    return Intl.message(
      'Modified',
      name: 'modified',
      desc: '',
      args: [],
    );
  }

  /// `No files`
  String get noFiles {
    return Intl.message(
      'No files',
      name: 'noFiles',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
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

  /// `Error: File ID not found`
  String get fileIdNotFound {
    return Intl.message(
      'Error: File ID not found',
      name: 'fileIdNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Error: You must log in first`
  String get mustLoginFirst {
    return Intl.message(
      'Error: You must log in first',
      name: 'mustLoginFirst',
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

  /// `Move File`
  String get moveFile {
    return Intl.message(
      'Move File',
      name: 'moveFile',
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

  /// `Root`
  String get root {
    return Intl.message(
      'Root',
      name: 'root',
      desc: '',
      args: [],
    );
  }

  /// `Move to Root`
  String get moveToRoot {
    return Intl.message(
      'Move to Root',
      name: 'moveToRoot',
      desc: '',
      args: [],
    );
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

  /// `Select`
  String get selectFolder {
    return Intl.message(
      'Select',
      name: 'selectFolder',
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
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'View Info',
      name: 'viewInfo',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Move`
  String get move {
    return Intl.message(
      'Move',
      name: 'move',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
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
