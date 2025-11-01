/// ملف أمثلة على استخدام API
/// هذا الملف يحتوي على أمثلة توضيحية فقط وليس للاستخدام الفعلي

import 'package:filevo/services/auth_service.dart';
import 'package:filevo/services/folders_service.dart';
import 'package:filevo/services/api_service.dart';
import 'package:filevo/services/api_endpoints.dart';

/// مثال 1: تسجيل الدخول
/// 
/// ```dart
/// Future<void> loginExample() async {
///   final authService = AuthService();
///   
///   final result = await authService.login(
///     email: 'user@example.com',
///     password: 'password123',
///   );
///   
///   if (result['success'] == true) {
///     // نجح تسجيل الدخول
///     print('Login successful!');
///     print('Token: ${result['data']['token']}');
///     // يتم حفظ الـ token تلقائيًا في StorageService
///   } else {
///     // فشل تسجيل الدخول
///     print('Login failed: ${result['error']}');
///   }
/// }
/// ```

/// مثال 2: الحصول على جميع المجلدات
/// 
/// ```dart
/// Future<void> getFoldersExample() async {
///   final foldersService = FoldersService();
///   
///   final result = await foldersService.getAllFolders();
///   
///   if (result['success'] == true) {
///     final folders = result['data']['folders'] as List;
///     print('Found ${folders.length} folders');
///     // استخدم المجلدات في UI
///   } else {
///     print('Error: ${result['error']}');
///   }
/// }
/// ```

/// مثال 3: استخدام ApiService مباشرة
/// 
/// ```dart
/// Future<void> directApiUsageExample() async {
///   final apiService = ApiService();
///   
///   // GET request
///   final getResult = await apiService.get(
///     ApiEndpoints.folders,
///     token: 'your_token_here',
///     queryParameters: {
///       'page': '1',
///       'limit': '10',
///     },
///   );
///   
///   // POST request
///   final postResult = await apiService.post(
///     ApiEndpoints.folders,
///     body: {
///       'name': 'New Folder',
///       'description': 'Folder description',
///     },
///     token: 'your_token_here',
///   );
///   
///   // PUT request
///   final putResult = await apiService.put(
///     ApiEndpoints.folderById('folder_id'),
///     body: {
///       'name': 'Updated Folder Name',
///     },
///     token: 'your_token_here',
///   );
///   
///   // DELETE request
///   final deleteResult = await apiService.delete(
///     ApiEndpoints.folderById('folder_id'),
///     token: 'your_token_here',
///   );
/// }
/// ```

/// مثال 4: استخدام في Flutter Widget
/// 
/// ```dart
/// class MyLoginWidget extends StatefulWidget {
///   @override
///   _MyLoginWidgetState createState() => _MyLoginWidgetState();
/// }
/// 
/// class _MyLoginWidgetState extends State<MyLoginWidget> {
///   final _emailController = TextEditingController();
///   final _passwordController = TextEditingController();
///   bool _isLoading = false;
///   String? _errorMessage;
///   
///   Future<void> _handleLogin() async {
///     setState(() {
///       _isLoading = true;
///       _errorMessage = null;
///     });
///     
///     final authService = AuthService();
///     final result = await authService.login(
///       email: _emailController.text,
///       password: _passwordController.text,
///     );
///     
///     setState(() {
///       _isLoading = false;
///     });
///     
///     if (result['success'] == true) {
///       // نجح تسجيل الدخول
///       Navigator.pushReplacementNamed(context, 'Main');
///     } else {
///       // فشل تسجيل الدخول
///       setState(() {
///         _errorMessage = result['error'] as String;
///       });
///     }
///   }
///   
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Column(
///         children: [
///           TextField(controller: _emailController),
///           TextField(controller: _passwordController),
///           if (_errorMessage != null)
///             Text(_errorMessage!, style: TextStyle(color: Colors.red)),
///           _isLoading
///             ? CircularProgressIndicator()
///             : ElevatedButton(
///                 onPressed: _handleLogin,
///                 child: Text('Login'),
///               ),
///         ],
///       ),
///     );
///   }
/// }
/// ```

