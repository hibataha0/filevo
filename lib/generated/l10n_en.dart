// // ignore: unused_import
// import 'package:intl/intl.dart' as intl;
// import 'l10n.dart';

// // ignore_for_file: type=lint

// /// The translations for English (`en`).
// class AppLocalizationsEn extends AppLocalizations {
//   AppLocalizationsEn([String locale = 'en']) : super(locale);

//   @override
//   String get appTitle => 'Flievo';

//   @override
//   String get loginSubtitle => 'Login to your account';

//   @override
//   String get usernameOrEmail => 'Username or Email';

//   @override
//   String get password => 'Password';

//   @override
//   String get forgotPassword => 'Forgot Password?';

//   @override
//   String get signIn => 'Sign In';

//   @override
//   String get signInWith => 'Sign in with';

//   @override
//   String get dontHaveAccount => 'Don\'t have an account? ';

//   @override
//   String get signUp => 'Sign up';

//   @override
//   String get loginSuccessful => 'Login successful!';

//   @override
//   String get invalidCredentials => 'Invalid credentials';

//   @override
//   String get createAccount => 'Create account';

//   @override
//   String get username => 'Username';

//   @override
//   String get email => 'Email';

//   @override
//   String get mobile => 'Mobile';

//   @override
//   String get confirmPassword => 'Confirm Password';

//   @override
//   String get create => 'Create';

//   @override
//   String get signUpWith => 'Sign up with';

//   @override
//   String get alreadyHaveAccount => 'Already have an account? ';

//   @override
//   String get logIn => 'Log In';

//   @override
//   String get accountCreatedSuccessfully => 'Account created successfully!';

//   @override
//   String get enterUsernameOrEmail => 'Please enter your username or email';

//   @override
//   String get invalidEmail => 'Please enter a valid email address';

//   @override
//   String get enterUsername => 'Please enter your username';

//   @override
//   String get usernameMin => 'Username must be at least 3 characters';

//   @override
//   String get usernameMax => 'Username cannot exceed 20 characters';

//   @override
//   String get usernameAllowedChars => 'Username can only contain letters, numbers and underscore';

//   @override
//   String get enterPassword => 'Please enter your password';

//   @override
//   String get passwordMin => 'Password must be at least 6 characters';

//   @override
//   String get enterConfirmPassword => 'Please confirm your password';

//   @override
//   String get passwordsDoNotMatch => 'Passwords do not match';

//   @override
//   String get enterPhone => 'Please enter your phone number';

//   @override
//   String get invalidPhone => 'Please enter a valid phone number (10-15 digits)';

//   @override
//   String get recentFolders => 'Recent Folders';

//   @override
//   String get seeAll => 'See all';

//   @override
//   String get recentFiles => 'Recent Files';

//   @override
//   String get storageUsed => 'Used';

//   @override
//   String get storageUsedValue => '60%';

//   @override
//   String get freeInternal => 'Free Internal';

//   @override
//   String get freeInternalValue => '120.5 GB';

//   @override
//   String get usedStorageValue => '149.5 GB';

//   @override
//   String get searchHint => 'Search anything here';

//   @override
//   String get all => 'All';

//   @override
//   String get myFiles => 'My Files';

//   @override
//   String get shared => 'Shared';

//   @override
//   String get allItems => 'All Items';

//   @override
//   String get myFolders => 'My Folders';

//   @override
//   String get sharedFiles => 'Shared Files';

//   @override
//   String get sharedFilesContent => 'Shared files content will be here';

//   @override
//   String get filter => 'Filter';

//   @override
//   String get images => 'Images';

//   @override
//   String get videos => 'Videos';

//   @override
//   String get audio => 'Audio';

//   @override
//   String get compressed => 'Compressed';

//   @override
//   String get applications => 'Applications';

//   @override
//   String get documents => 'Documents';

//   @override
//   String get code => 'Code';

//   @override
//   String get other => 'Other';

//   @override
//   String get type => 'Type';

//   @override
//   String get timeAndDate => 'Time & Date';

//   @override
//   String get yesterday => 'Yesterday';

//   @override
//   String get last7Days => 'Last 7 days';

//   @override
//   String get last30Days => 'Last 30 days';

//   @override
//   String get lastYear => 'Last year';

//   @override
//   String get custom => 'Custom';

//   @override
//   String get usedStorage => 'Used storage:';

//   @override
//   String get storageOverview => 'Storage Overview';

//   @override
//   String get settings => 'Settings';

//   @override
//   String get chooseLanguage => 'Choose Language';

//   @override
//   String get english => 'English';

//   @override
//   String get arabic => 'Arabic';

//   @override
//   String get general => 'General';

//   @override
//   String get generalSettings => 'General Settings';

//   @override
//   String get basicAppSettings => 'Basic app settings';

//   @override
//   String get darkMode => 'Dark Mode';

//   @override
//   String get switchThemes => 'Switch between themes';

//   @override
//   String get language => 'Language';

//   @override
//   String get preferences => 'Preferences';

//   @override
//   String get notifications => 'Notifications';

//   @override
//   String get manageNotifications => 'Manage notifications';

//   @override
//   String get storage => 'Storage';

//   @override
//   String get manageStorageSettings => 'Manage storage settings';

//   @override
//   String get privacySecurity => 'Privacy & Security';

//   @override
//   String get privacySettings => 'Privacy settings';

//   @override
//   String get support => 'Support';

//   @override
//   String get legalPolicies => 'Legal & Policies';

//   @override
//   String get termsPrivacyPolicy => 'Terms of service & privacy policy';

//   @override
//   String get helpSupport => 'Help & Support';

//   @override
//   String get getHelpSupport => 'Get help and support';

//   @override
//   String get about => 'About';

//   @override
//   String appVersion(Object version) {
//     return 'App version $version';
//   }

//   @override
//   String get logout => 'Logout';

//   @override
//   String get signOut => 'Sign out from your account';

//   @override
//   String get resetPassword => 'Reset Password';

//   @override
//   String get forgotPasswordTitle => 'Forgot your password?';

//   @override
//   String get forgotPasswordSubtitle => 'Enter your email address and we\'ll send you a code to reset your password.';

//   @override
//   String get sendCode => 'Send Code';

//   @override
//   String get enterEmail => 'Please enter your email';

//   @override
//   String get validEmail => 'Please enter a valid email';

//   @override
//   String get codeSent => 'Code sent successfully';

//   @override
//   String get failedSendCode => 'Failed to send code';

//   @override
//   String get backToLogin => 'Back to Login';

//   @override
//   String get verifyCodeTitle => 'Verify Code';

//   @override
//   String get enter6DigitCode => 'Please enter a 6-digit code';

//   @override
//   String enterCodeToEmail(Object email) {
//     return 'Enter the 6-digit code sent to $email';
//   }

//   @override
//   String get verify => 'Verify';

//   @override
//   String get resendCode => 'Resend Code';

//   @override
//   String get codeVerified => 'Code verified successfully';

//   @override
//   String get invalidOrExpiredCode => 'Invalid or expired code';

//   @override
//   String get codeResent => 'Code resent successfully';

//   @override
//   String get failedResendCode => 'Failed to resend code';

//   @override
//   String get mustLogin => 'You must log in first';

//   @override
//   String get errorFetchingData => 'Error fetching data';

//   @override
//   String get loginRequiredToAccessFiles => 'You must log in to access the files';

//   @override
//   String get retry => 'Retry';

//   @override
//   String get noFilesInCategory => 'No files in this category.';

//   @override
//   String get updated => 'Updated';

//   @override
//   String get numberOfFiles => 'Number of files:';

//   @override
//   String get upload_success => 'File uploaded successfully';

//   @override
//   String get createFolder => 'Create Folder';

//   @override
//   String get folderNameHint => 'Folder Name';

//   @override
//   String get enterFolderName => 'Please enter folder name';

//   @override
//   String get fileIdNotAvailable => 'File ID not available';

//   @override
//   String get fileAlreadyAccessed => 'You have already accessed this file. One-time share only.';

//   @override
//   String get oneTimeShareAccessRecorded => 'This file is shared for one time - your access has been recorded';

//   @override
//   String get cannotAccessFile => 'Cannot access file';

//   @override
//   String get errorAccessingFile => 'Error accessing file';

//   @override
//   String get fileUrlNotAvailable => 'File URL not available';

//   @override
//   String get invalidUrl => 'Invalid URL';

//   @override
//   String get unsupportedFile => 'Unsupported File';

//   @override
//   String get invalidPdfFile => 'This file is not a valid PDF or may be corrupted.';

//   @override
//   String get openAsText => 'Open as Text';

//   @override
//   String get shareFileWithRoom => 'Share File with Room';

//   @override
//   String get chooseRoomToShare => 'Choose a room to share this file';

//   @override
//   String get noRoomsAvailable => 'No rooms available';

//   @override
//   String get createRoomFirst => 'Create a room first to share';

//   @override
//   String get oneTimeShare => 'One-time Share';

//   @override
//   String get oneTimeShareDescription => 'Each user can open the file only once';

//   @override
//   String expiresInHours(Object hours) {
//     return 'Expires in $hours hours';
//   }

//   @override
//   String get enterHours => 'Enter number of hours';

//   @override
//   String get confirm => 'Confirm';

//   @override
//   String get share => 'Share';

//   @override
//   String get fileAlreadyShared => 'This file is already shared with this room';

//   @override
//   String get roomDetails => 'Room Details';

//   @override
//   String get onlyOwnerCanDelete => 'Only room owner can delete it';

//   @override
//   String get ownerCannotLeave => 'Room owner cannot leave. Please delete the room instead';

//   @override
//   String get deleteRoom => 'Delete Room';

//   @override
//   String get leaveRoom => 'Leave Room';

//   @override
//   String roomName(Object roomName) {
//     return '$roomName';
//   }

//   @override
//   String get roomNamePlaceholder => 'No name';

//   @override
//   String get leave => 'Leave';

//   @override
//   String get owner => 'Owner';

//   @override
//   String get members => 'Members';

//   @override
//   String get files => 'Files';

//   @override
//   String get folders => 'Folders';

//   @override
//   String get sendInvitation => 'Send Invitation';

//   @override
//   String get comments => 'Comments';

//   @override
//   String get roomInfo => 'Room Info';

//   @override
//   String get createdAt => 'Created at';

//   @override
//   String get lastModified => 'Last Modified';

//   @override
//   String get viewAll => 'View All';

//   @override
//   String get noMembers => 'No members';

//   @override
//   String sharedFilesCount(Object count) {
//     return 'Shared Files ($count)';
//   }

//   @override
//   String get addFile => 'Add File';

//   @override
//   String get addFileToRoom => 'Add File to Room';

//   @override
//   String get addFolder => 'Add Folder';

//   @override
//   String get addFolderToRoom => 'Add Folder to Room';

//   @override
//   String get selectFolder => 'Select';

//   @override
//   String get noFoldersAvailable => 'No folders available';

//   @override
//   String get noSubfolders => 'No subfolders';

//   @override
//   String get errorLoadingSubfolders => 'Error loading subfolders';

//   @override
//   String get open => 'Open';

//   @override
//   String get viewDetails => 'View Details';

//   @override
//   String get removeFromFavorites => 'Remove from Favorites';

//   @override
//   String get addToFavorites => 'Add to Favorites';

//   @override
//   String get removeFromRoom => 'Remove from Room';

//   @override
//   String get viewInfo => 'View Info';

//   @override
//   String get edit => 'Edit';

//   @override
//   String get move => 'Move';

//   @override
//   String get delete => 'Delete';

//   @override
//   String get download => 'Download';

//   @override
//   String get saveToMyAccount => 'Save to My Account';

//   @override
//   String get cannotAddSharedFilesToFavorites => 'Cannot add shared files in room to favorites';

//   @override
//   String get noName => 'No name';

//   @override
//   String get fileWithoutName => 'File without name';

//   @override
//   String get noRecentFolders => 'No recent folders';

//   @override
//   String get noRecentFiles => 'No recent files';

//   @override
//   String get folder => 'Folder';

//   @override
//   String get noItems => 'No items';

//   @override
//   String get oneItem => 'One item';

//   @override
//   String get item => 'item';

//   @override
//   String get items => 'items';

//   @override
//   String get fileSavedSuccessfully => 'File saved successfully';

//   @override
//   String get fileSavedAndUploaded => 'File saved and uploaded to server successfully';

//   @override
//   String get fileSavedLocallyOnly => 'File saved locally only. Please try again to upload to server';

//   @override
//   String get failedToSaveFile => 'Failed to save file';

//   @override
//   String get unsavedChanges => 'Unsaved changes';

//   @override
//   String get unsavedChangesMessage => 'You have unsaved changes. Do you want to exit without saving?';

//   @override
//   String get exit => 'Exit';

//   @override
//   String get copyContent => 'Copy Content';

//   @override
//   String get accessTokenNotFound => 'Access token not found';

//   @override
//   String get fileIsEmpty => 'File is empty';

//   @override
//   String get loadingFileData => 'Loading file data...';

//   @override
//   String get failedToLoadFileData => 'Failed to load file data';

//   @override
//   String get fileInfo => 'File Information';

//   @override
//   String get extension => 'Extension';

//   @override
//   String get size => 'Size';

//   @override
//   String get description => 'Description';

//   @override
//   String get tags => 'Tags';

//   @override
//   String get shareWithRoom => 'Share with Room';

//   @override
//   String get shareFeatureComingSoon => 'Share feature coming soon';

//   @override
//   String get image => 'Image';

//   @override
//   String get video => 'Video';

//   @override
//   String get document => 'Document';

//   @override
//   String get unclassified => 'Unclassified';

//   @override
//   String get extractingTextFromPdf => 'Extracting text from PDF...';

//   @override
//   String error(String error) {
//     return 'Error: $error';
//   }

//   @override
//   String get status => 'Status';

//   @override
//   String get youAreOwner => 'You are the owner';

//   @override
//   String get sharedFile => 'Shared file';

//   @override
//   String get unshareFile => 'Unshare File';

//   @override
//   String get unshare => 'Unshare';

//   @override
//   String get mustLoginFirst => 'You must log in first';

//   @override
//   String get editFile => 'Edit File';

//   @override
//   String get editImage => 'Edit Image';

//   @override
//   String get openImageEditor => 'Open Image Editor';

//   @override
//   String get imageEdited => 'Image edited';

//   @override
//   String get reloadOriginalImage => 'Reload Original Image';

//   @override
//   String get editText => 'Edit Text';

//   @override
//   String get openTextEditor => 'Open Text Editor';

//   @override
//   String get textEdited => 'Text edited';

//   @override
//   String get failedToLoadImage => 'Failed to load image';

//   @override
//   String get failedToSaveTempImage => 'Failed to save temporary image';

//   @override
//   String get loadedImageIsEmpty => 'Loaded image is empty';

//   @override
//   String errorVerifyingImage(String error) {
//     return 'Error verifying image: $error';
//   }

//   @override
//   String get loadingVideo => 'Loading video...';

//   @override
//   String failedToLoadVideo(int statusCode) {
//     return 'Failed to load video ($statusCode)';
//   }

//   @override
//   String get failedToSaveTempVideo => 'Failed to save temporary video';

//   @override
//   String get loadedVideoIsEmpty => 'Loaded video is empty';

//   @override
//   String errorVerifyingVideo(String error) {
//     return 'Error verifying video: $error';
//   }

//   @override
//   String get extractingImage => 'Extracting image...';

//   @override
//   String get imageExtracted => 'Image extracted';

//   @override
//   String get saveThisImage => 'Do you want to save this image?';

//   @override
//   String get failedToExtractImage => 'Failed to extract image';

//   @override
//   String get mergingVideos => 'Merging videos... This may take some time';

//   @override
//   String get failedToMergeVideos => 'Failed to merge videos';

//   @override
//   String failedToLoadAudio(int statusCode) {
//     return 'Failed to load audio file ($statusCode)';
//   }

//   @override
//   String get failedToSaveTempAudio => 'Failed to save temporary audio file';

//   @override
//   String get loadedAudioIsEmpty => 'Loaded audio file is empty';

//   @override
//   String get startTimeMustBeBeforeEndTime => 'Start time must be before end time';

//   @override
//   String get failedToLoadAudioFile => 'Failed to load audio file';

//   @override
//   String get failedToLoadBaseAudio => 'Failed to load base audio file';

//   @override
//   String get mustSelectAtLeastTwoAudioFiles => 'You must select at least two audio files to merge';

//   @override
//   String get mergingAudioFiles => 'Merging audio files... This may take some time';

//   @override
//   String pdfLoadFailed(int statusCode) {
//     return 'Failed to load PDF file ($statusCode)';
//   }

//   @override
//   String get failedToLoadPdf => 'Failed to load PDF';

//   @override
//   String get failedToLoadFile => 'Failed to load file';

//   @override
//   String get imageEditedSuccessfully => '✅ Image edited successfully';

//   @override
//   String get editedImageIsEmpty => '⚠️ Edited image is empty';

//   @override
//   String get failedToSaveEditedImage => '⚠️ Failed to save edited image';

//   @override
//   String get textEditedSuccessfully => '✅ Text edited successfully. Press \"Save Changes\" to upload to server';

//   @override
//   String get saveOptions => 'Save Options';

//   @override
//   String get saveOptionsDescription => 'How do you want to save the edited image?\n\n• Save new copy: The edited image will be saved as a new file\n• Replace old version: The old file will be deleted and replaced with the edited image';

//   @override
//   String get saveNewCopy => 'Save new copy';

//   @override
//   String get replaceOldVersion => 'Replace old version';

//   @override
//   String get extract => 'Extract';

//   @override
//   String get trimAudio => 'Trim Audio';

//   @override
//   String totalDuration(String duration) {
//     return 'Total duration: $duration';
//   }

//   @override
//   String get trim => 'Trim';

//   @override
//   String get adjustVolume => 'Adjust Volume';

//   @override
//   String get apply => 'Apply';

//   @override
//   String get convertFormat => 'Convert Format';

//   @override
//   String get chooseOutputFormat => 'Choose output format:';

//   @override
//   String get wavFormat => 'WAV';

//   @override
//   String get wavDescription => 'High quality, large size';

//   @override
//   String get mp3Format => 'MP3';

//   @override
//   String get mp3Description => 'Good quality, small size';

//   @override
//   String get aacFormat => 'AAC';

//   @override
//   String get aacDescription => 'Very good quality';

//   @override
//   String get addTextAnnotation => 'Add Text (Annotation)';

//   @override
//   String positionX(String x) {
//     return 'Position X: $x';
//   }

//   @override
//   String positionY(String y) {
//     return 'Position Y: $y';
//   }

//   @override
//   String fontSize(String size) {
//     return 'Font size: $size';
//   }

//   @override
//   String page(String pageNumber) {
//     return 'Page: $pageNumber';
//   }

//   @override
//   String get add => 'Add';

//   @override
//   String get selectImagePosition => 'Select Image Position';

//   @override
//   String width(String width) {
//     return 'Width: $width';
//   }

//   @override
//   String height(String height) {
//     return 'Height: $height';
//   }

//   @override
//   String get highlightText => 'Highlight Text';

//   @override
//   String get color => 'Color:';

//   @override
//   String get highlight => 'Highlight';

//   @override
//   String get videoEditedSuccessfully => '✅ Video edited successfully';

//   @override
//   String get editedVideoIsEmpty => '⚠️ Edited video is empty';

//   @override
//   String get failedToSaveEditedVideo => '⚠️ Failed to save edited video';

//   @override
//   String get videoMergedSuccessfully => '✅ Videos merged successfully';

//   @override
//   String get textAddedSuccessfully => '✅ Text added successfully';

//   @override
//   String get imageAddedSuccessfully => '✅ Image added successfully';

//   @override
//   String get textHighlightedSuccessfully => '✅ Text highlighted successfully';

//   @override
//   String get fileUpdatedSuccessfully => '✅ File updated successfully';

//   @override
//   String get fileReplacedSuccessfully => '✅ File replaced successfully';

//   @override
//   String get newCopySavedSuccessfully => '✅ New copy saved successfully';

//   @override
//   String get changesSavedSuccessfully => '✅ Changes saved successfully';

//   @override
//   String errorOccurred(String error) {
//     return '❌ Error: $error';
//   }

//   @override
//   String get imageExtractedSuccessfully => '✅ Image extracted successfully';

//   @override
//   String get editedFileNotFound => 'Edited file not found. Please edit again';

//   @override
//   String errorAccessingEditedFile(String error) {
//     return 'Error accessing edited file: $error';
//   }

//   @override
//   String get chooseTimeToExtractImage => 'Choose time to extract image';

//   @override
//   String get chooseTimeInSeconds => 'Choose time in seconds:';

//   @override
//   String get save => 'Save';

//   @override
//   String get cancel => 'Cancel';

//   @override
//   String get editFileMetadata => 'Edit File';

//   @override
//   String get fileName => 'File Name';

//   @override
//   String get fileDescription => 'Description';

//   @override
//   String get tagsSeparatedByComma => 'Tags (separate with comma)';

//   @override
//   String get changesSaveFailed => '❌ Failed to save changes';

//   @override
//   String confirmDeleteFile(String fileName) {
//     return 'Are you sure you want to delete the file \'$fileName\'?';
//   }

//   @override
//   String get noTokenError => '❌ Error: No token found.';

//   @override
//   String fileDeletedSuccessfully(String fileName) {
//     return '✅ File \'$fileName\' deleted successfully';
//   }

//   @override
//   String errorDeletingFile(String error) {
//     return '❌ Error deleting file: $error';
//   }

//   @override
//   String get noUsersSharedWith => 'No users shared with this file';

//   @override
//   String get cannotIdentifyUsers => 'Cannot identify users to unshare';

//   @override
//   String get unshareFileSuccess => '✅ File unshared successfully';

//   @override
//   String get unshareFailed => 'Failed to unshare';

//   @override
//   String get fileAddedToFavorites => '✅ File added to favorites';

//   @override
//   String get fileRemovedFromFavorites => '✅ File removed from favorites';

//   @override
//   String get errorUpdating => '❌ Error updating';

//   @override
//   String get downloadingFile => 'Downloading file...';

//   @override
//   String fileDownloadedSuccessfully(String fileName) {
//     return '✅ File downloaded successfully: $fileName';
//   }

//   @override
//   String get failedToDownloadFile => 'Failed to download file';

//   @override
//   String errorDownloadingFile(String error) {
//     return '❌ Error downloading file: $error';
//   }

//   @override
//   String get cannotIdentifyFile => 'Cannot identify file';

//   @override
//   String get shareRequestSent => '✅ Share request sent to room';

//   @override
//   String get unshareFileConfirm => 'Are you sure you want to unshare this file with all users?';

//   @override
//   String get updating => 'Updating...';

//   @override
//   String get deleteFile => 'Delete File';

//   @override
//   String get saveChanges => 'Save Changes';

//   @override
//   String get mustLoginFirstError => 'Error: You must log in first';

//   @override
//   String errorLoadingFileData(String error) {
//     return 'Error loading file data: $error';
//   }

//   @override
//   String get file => 'File';

//   @override
//   String get failedToLoadPreview => 'Failed to load preview';

//   @override
//   String get modified => 'Modified';

//   @override
//   String failedToLoadPdfFile(String error) {
//     return 'Failed to load PDF file: $error';
//   }

//   @override
//   String failedToOpenFile(String error) {
//     return 'Failed to open file: $error';
//   }

//   @override
//   String failedToLoadPdfForDisplay(String error) {
//     return 'Failed to load PDF for display: $error';
//   }

//   @override
//   String get pdfTextExtractionNote => 'Note: Text extraction may not be available for all PDF files.';

//   @override
//   String get pdfTextExtractionNote2 => 'You can select and highlight text after extraction.';

//   @override
//   String get failedToExtractTextFromPdf => 'Failed to extract text from PDF';

//   @override
//   String get canViewPdfAndSearch => 'You can view PDF and search in it';

//   @override
//   String get textHighlighted => 'Selected text highlighted';

//   @override
//   String get searchInPdfNotAvailableMessage => 'PDF search is not currently available. You can open the file in an external app to search.';

//   @override
//   String get searchInPdf => 'Search in PDF';

//   @override
//   String get forAdvancedSearchFeature => 'To benefit from advanced search feature, we recommend using:';

//   @override
//   String get currentVersionSupports => 'Current version supports:';

//   @override
//   String get ok => 'OK';

//   @override
//   String get loadingFile => 'Loading file...';

//   @override
//   String get fileNotLoaded => 'File not loaded';

//   @override
//   String get extractingText => 'Extracting text...';

//   @override
//   String get highlightSelectedText => 'Highlight selected text';

//   @override
//   String get removeAllHighlights => 'Remove all highlights';

//   @override
//   String get highlights => 'Highlights';

//   @override
//   String get textNotExtractedYet => 'Text not extracted yet';

//   @override
//   String get extractText => 'Extract Text';

//   @override
//   String get removeFileFromRoom => 'Remove File from Room';

//   @override
//   String removeFileFromRoomConfirm(String fileName) {
//     return 'Are you sure you want to remove \"$fileName\" from this room?';
//   }

//   @override
//   String get remove => 'Remove';

//   @override
//   String get fileRemovedFromRoom => 'File removed from room successfully';

//   @override
//   String get failedToRemoveFile => 'Failed to remove file from room';

//   @override
//   String get fileIdNotFound => 'File ID not found';

//   @override
//   String get movingFile => 'Moving file...';

//   @override
//   String get fileMovedSuccessfully => 'File moved successfully';

//   @override
//   String get failedToMoveFile => 'Failed to move file';

//   @override
//   String get noFiles => 'No files';

//   @override
//   String get startAddingFiles => 'Start adding new files';

//   @override
//   String get viewedByAll => 'Viewed by all';

//   @override
//   String get active => 'Active';

//   @override
//   String get accessed => 'Accessed';

//   @override
//   String get completed => 'Completed';

//   @override
//   String get sharedBy => 'Shared by';

//   @override
//   String get moveToRoot => 'Move to Root';

//   @override
//   String get moveToRootDescription => 'Move folder to main folder';

//   @override
//   String get selectFolderDescription => 'Move to this folder';

//   @override
//   String get deleteFolder => 'Delete Folder';

//   @override
//   String confirmDeleteFolder(String folderName) {
//     return 'Are you sure you want to delete the folder \'$folderName\'? All files and subfolders will also be deleted.';
//   }

//   @override
//   String get folderIdNotAvailable => '❌ Error: Folder ID not available.';

//   @override
//   String folderDeletedSuccessfully(String folderName) {
//     return '✅ Folder \'$folderName\' deleted successfully';
//   }

//   @override
//   String get errorDeletingFolder => '❌ Error occurred while deleting folder';

//   @override
//   String errorDeletingFolderWithError(String error) {
//     return '❌ Error occurred while deleting folder: $error';
//   }

//   @override
//   String folderRestoredSuccessfully(String folderName) {
//     return '✅ Folder \'$folderName\' restored successfully';
//   }

//   @override
//   String get errorRestoringFolder => '❌ Error occurred while restoring folder';

//   @override
//   String errorRestoringFolderWithError(String error) {
//     return '❌ Error occurred while restoring folder: $error';
//   }

//   @override
//   String get confirmPermanentDelete => 'Confirm Permanent Delete';

//   @override
//   String confirmPermanentDeleteFolder(String folderName) {
//     return 'Are you sure you want to permanently delete the folder \'$folderName\'? This action cannot be undone. All files and subfolders will be permanently deleted.';
//   }

//   @override
//   String get permanentDelete => 'Permanent Delete';

//   @override
//   String folderPermanentlyDeletedSuccessfully(String folderName) {
//     return '✅ Folder \'$folderName\' permanently deleted successfully';
//   }

//   @override
//   String get errorPermanentlyDeletingFolder => '❌ Error occurred while permanently deleting folder';

//   @override
//   String errorPermanentlyDeletingFolderWithError(String error) {
//     return '❌ Error occurred while permanently deleting folder: $error';
//   }

//   @override
//   String get cannotIdentifyFolder => '❌ Error: Cannot identify folder';

//   @override
//   String get downloadingFolder => 'Downloading folder...';

//   @override
//   String folderDownloadedSuccessfully(String fileName) {
//     return '✅ Folder downloaded successfully: $fileName';
//   }

//   @override
//   String get failedToDownloadFolder => 'Failed to download folder';

//   @override
//   String errorDownloadingFolder(String error) {
//     return '❌ Error downloading folder: $error';
//   }

//   @override
//   String get pleaseEnter6DigitCode => 'Please enter the 6-digit verification code';

//   @override
//   String get accountActivatedSuccessfully => '✅ Account activated successfully';

//   @override
//   String get invalidVerificationCode => 'Invalid verification code';

//   @override
//   String pleaseWaitBeforeResend(int seconds) {
//     return 'Please wait $seconds seconds before resending';
//   }

//   @override
//   String get verificationCodeSent => '✅ Verification code sent successfully';

//   @override
//   String get failedToResendCode => '❌ Failed to resend verification code';

//   @override
//   String get emailVerification => 'Email Verification';

//   @override
//   String verificationCodeSentTo(String email) {
//     return 'Verification code sent to $email';
//   }

//   @override
//   String get didNotReceiveCode => 'Didn\'t receive the code?';

//   @override
//   String resendWithCountdown(int seconds) {
//     return 'Resend ($seconds)';
//   }

//   @override
//   String get resend => 'Resend';

//   @override
//   String get openFileAsText => 'Open file as text';

//   @override
//   String get fileLinkNotAvailable => 'File link not available';

//   @override
//   String get failedToCreateTempFile => 'Failed to create temporary file';

//   @override
//   String failedToLoadFileStatus(String error) {
//     return 'Failed to load file status: $error';
//   }

//   @override
//   String errorOpeningFile(String error) {
//     return 'Error opening file: $error';
//   }

//   @override
//   String fileNotAvailableError(String error) {
//     return 'File not available: $error';
//   }

//   @override
//   String errorLoadingFile(String error) {
//     return 'Error loading file: $error';
//   }

//   @override
//   String get fileNotValidPdf => 'File is not a valid PDF';

//   @override
//   String get createNewShareRoom => 'Create New Share Room';

//   @override
//   String get pleaseEnterRoomName => 'Please enter room name';

//   @override
//   String searchError(String error) {
//     return 'Search error: $error';
//   }

//   @override
//   String get folderInfo => 'Folder Info';

//   @override
//   String get loadMore => 'Load More';

//   @override
//   String get filesCount => 'Files Count';

//   @override
//   String get subfoldersCount => 'Subfolders Count';

//   @override
//   String get creationDate => 'Creation Date';

//   @override
//   String get featureUnderDevelopment => 'This feature is under development';

//   @override
//   String get folderWithoutName => 'Folder without name';

//   @override
//   String get movingFolder => 'Moving folder...';

//   @override
//   String errorFetchingSubfolders(String error) {
//     return 'Error fetching subfolders: $error';
//   }

//   @override
//   String get moveFolderToRoot => 'Move Folder to Root';

//   @override
//   String get rejectInvitation => 'Reject Invitation';

//   @override
//   String get confirmRejectInvitation => 'Are you sure you want to reject this invitation?';

//   @override
//   String get reject => 'Reject';

//   @override
//   String get pendingInvitations => 'Pending Invitations';

//   @override
//   String get accept => 'Accept';

//   @override
//   String get pleaseSelectFileOrFolder => 'Please select a file or folder';

//   @override
//   String get deleteComment => 'Delete Comment';

//   @override
//   String get confirmDeleteComment => 'Are you sure you want to delete this comment?';

//   @override
//   String get room => 'Room';

//   @override
//   String get errorLoadingRoomDetails => 'Error loading room details';

//   @override
//   String get failedToLoadRoomDetails => 'Failed to load room details';

//   @override
//   String get pleaseLoginAgain => 'Please login again';

//   @override
//   String get deleteRoomConfirm => 'Are you sure you want to delete this room? All shared files and folders will also be deleted.';

//   @override
//   String get confirmRemoveFileFromRoom => 'Are you sure you want to remove this file from the room?';

//   @override
//   String get removeFolderFromRoom => 'Remove Folder from Room';

//   @override
//   String get confirmRemoveFolderFromRoom => 'Are you sure you want to remove this folder from the room?';

//   @override
//   String confirmRemoveFolderFromRoomWithName(String folderName) {
//     return 'Are you sure you want to remove the folder \'$folderName\' from the room?';
//   }

//   @override
//   String get savingFolder => 'Saving folder...';

//   @override
//   String get saveToRoot => 'Save to Root';

//   @override
//   String get failedToLoadRoomData => 'Failed to load room data';

//   @override
//   String get noSharedFiles => 'No shared files';

//   @override
//   String get shareFilesWithRoom => 'Share Files with Room';

//   @override
//   String get createNewFolder => 'Create New Folder';

//   @override
//   String get pleaseEnterFolderName => 'Please enter folder name';

//   @override
//   String folderCreatedSuccessfully(String folderName) {
//     return 'Folder created successfully: $folderName';
//   }

//   @override
//   String get failedToCreateFolder => 'Failed to create folder';

//   @override
//   String get removeMember => 'Remove Member';

//   @override
//   String get confirmRemoveMember => 'Are you sure you want to remove this member from the room?';

//   @override
//   String get roomMembers => 'Room Members';

//   @override
//   String get viewOnly => 'View Only';

//   @override
//   String get viewOnlyDescription => 'User can only view files';

//   @override
//   String get editor => 'Editor';

//   @override
//   String get editorDescription => 'User can edit files';

//   @override
//   String get commenter => 'Commenter';

//   @override
//   String get commenterDescription => 'User can comment on files';

//   @override
//   String get shareFolderWithRoom => 'Share Folder with Room';

//   @override
//   String get shareWithThisRoom => 'Share with this room';

//   @override
//   String get mustAllowPhotosAccess => 'Must allow photos access';

//   @override
//   String get profileImageUploadedSuccessfully => '✅ Profile image uploaded successfully';

//   @override
//   String get failedToUploadProfileImage => '❌ Failed to upload profile image';

//   @override
//   String errorUploadingProfileImage(String error) {
//     return '❌ Error uploading profile image: $error';
//   }

//   @override
//   String get mustAllowCameraAccess => 'Must allow camera access';

//   @override
//   String get unknownError => 'Unknown error';

//   @override
//   String get chooseFromGallery => 'Choose from Gallery';

//   @override
//   String get takePhotoFromCamera => 'Take Photo from Camera';

//   @override
//   String get used => 'Used';

//   @override
//   String get microphonePermissionRequired => 'Microphone permission required';

//   @override
//   String get openSettings => 'Open Settings';

//   @override
//   String get permissionDenied => 'Permission denied';

//   @override
//   String get mustAllowMicrophoneAccess => 'Must allow microphone access';

//   @override
//   String get speechRecognitionNotAvailable => 'Speech recognition not available';

//   @override
//   String get enterSearchText => 'Enter search text';

//   @override
//   String get smartSearch => 'Smart Search';

//   @override
//   String get fileLinkNotAvailableNoPath => 'File link not available (no path)';

//   @override
//   String errorLoadingTextFile(String error) {
//     return 'Error loading text file: $error';
//   }

//   @override
//   String get activityLog => 'Activity Log';

//   @override
//   String get previous => 'Previous';

//   @override
//   String get next => 'Next';

//   @override
//   String get filterActivity => 'Filter Activity';

//   @override
//   String get allActivities => 'All Activities';

//   @override
//   String get uploadFile => 'Upload File';

//   @override
//   String get downloadFile => 'Download File';

//   @override
//   String get shareFile => 'Share File';

//   @override
//   String get login => 'Login';

//   @override
//   String get userLabel => 'User';

//   @override
//   String get system => 'System';

//   @override
//   String get roomLabel => 'Room';

//   @override
//   String get reset => 'Reset';

//   @override
//   String get logoutSuccess => '✅ Logged out successfully';

//   @override
//   String get tokenNotFound => '❌ Error: Token not found';

//   @override
//   String get trash => 'Trash';

//   @override
//   String get deletedFiles => 'Deleted Files';

//   @override
//   String get deletedFolders => 'Deleted Folders';

//   @override
//   String get profile => 'Profile';

//   @override
//   String get editUsername => 'Edit Username';

//   @override
//   String get editEmail => 'Edit Email';

//   @override
//   String get fieldRequired => 'This field is required';

//   @override
//   String get validEmailRequired => 'Invalid email address';

//   @override
//   String get updatedSuccessfully => '✅ Updated successfully';

//   @override
//   String get changePassword => 'Change Password';

//   @override
//   String get currentPassword => 'Current Password';

//   @override
//   String get currentPasswordRequired => 'Current password is required';

//   @override
//   String get newPassword => 'New Password';

//   @override
//   String get newPasswordRequired => 'New password is required';

//   @override
//   String get passwordMinLength => 'Password must be at least 8 characters';

//   @override
//   String get confirmNewPassword => 'Confirm New Password';

//   @override
//   String get passwordConfirmationRequired => 'Password confirmation is required';

//   @override
//   String get passwordUpdatedSuccessfully => '✅ Password updated successfully';

//   @override
//   String get favoriteFiles => 'Favorite Files';

//   @override
//   String get noFavoriteFiles => 'No favorite files';

//   @override
//   String get addFilesToFavorites => 'Add files to favorites';
// }
