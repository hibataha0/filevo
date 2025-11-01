# دليل دمج API مع التطبيق

تم إعداد نظام API بالكامل للاتصال بالباك إند على الرابط:
```
http://localhost:8000/api/v1
```

## الملفات المُنشأة

### 1. `lib/config/api_config.dart`
يحتوي على إعدادات API الأساسية:
- Base URL
- Headers افتراضية
- Timeout settings

### 2. `lib/services/api_service.dart`
خدمة عامة للتعامل مع HTTP requests:
- GET, POST, PUT, DELETE, PATCH
- معالجة الأخطاء التلقائية
- دعم Authentication token

### 3. `lib/services/api_endpoints.dart`
يحتوي على جميع endpoints للـ API (يمكنك تعديلها حسب احتياجك)

### 4. `lib/services/storage_service.dart`
خدمة لحفظ واسترجاع البيانات المحلية مثل الـ token

### 5. `lib/services/auth_service.dart`
مثال على استخدام ApiService للتعامل مع عمليات المصادقة

### 6. `lib/services/folders_service.dart`
مثال على استخدام ApiService للتعامل مع المجلدات

## كيفية الاستخدام

### 1. تسجيل الدخول

```dart
import 'package:filevo/services/auth_service.dart';

final authService = AuthService();

final result = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

if (result['success'] == true) {
  // نجح تسجيل الدخول
  // الـ token يتم حفظه تلقائيًا
  Navigator.pushReplacementNamed(context, 'Main');
} else {
  // فشل تسجيل الدخول
  print('Error: ${result['error']}');
}
```

### 2. الحصول على المجلدات

```dart
import 'package:filevo/services/folders_service.dart';

final foldersService = FoldersService();

final result = await foldersService.getAllFolders();

if (result['success'] == true) {
  final folders = result['data']['folders'] as List;
  // استخدم المجلدات في UI
} else {
  print('Error: ${result['error']}');
}
```

### 3. استخدام ApiService مباشرة

```dart
import 'package:filevo/services/api_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';

final apiService = ApiService();
final token = await StorageService.getToken();

// GET request
final result = await apiService.get(
  ApiEndpoints.folders,
  token: token,
  queryParameters: {
    'page': '1',
    'limit': '10',
  },
);

// POST request
final postResult = await apiService.post(
  ApiEndpoints.folders,
  body: {
    'name': 'New Folder',
  },
  token: token,
);
```

## تحديث Base URL

إذا احتجت تغيير الرابط، افتح `lib/config/api_config.dart` وغير:
```dart
static const String baseUrl = 'http://localhost:8000/api/v1';
```

## إضافة Endpoints جديدة

افتح `lib/services/api_endpoints.dart` وأضف endpoints جديدة:
```dart
class ApiEndpoints {
  // ... endpoints موجودة
  
  // إضافة جديدة
  static const String myNewEndpoint = '/my-endpoint';
  static String myEndpointById(String id) => '/my-endpoint/$id';
}
```

## إنشاء خدمات جديدة

يمكنك إنشاء خدمات جديدة على غرار `auth_service.dart` و `folders_service.dart`:

```dart
import 'package:filevo/services/api_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';

class MyNewService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> myMethod() async {
    final token = await StorageService.getToken();
    
    return await _apiService.get(
      ApiEndpoints.myNewEndpoint,
      token: token,
    );
  }
}
```

## تثبيت الحزم المطلوبة

قم بتشغيل:
```bash
flutter pub get
```

## ملاحظات مهمة

1. **Token**: يتم حفظ الـ token تلقائيًا عند تسجيل الدخول
2. **Headers**: يتم إضافة headers التلقائية (Content-Type, Authorization)
3. **Error Handling**: يتم معالجة الأخطاء تلقائيًا وإرجاع رسائل واضحة
4. **Timeout**: مهلة الاتصال هي 30 ثانية (يمكن تغييرها في `api_config.dart`)

## مثال كامل لصفحة تسجيل الدخول

راجع `lib/examples/api_usage_example.dart` لأمثلة كاملة.

