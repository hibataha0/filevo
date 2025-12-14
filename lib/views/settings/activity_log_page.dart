import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/activity_controller.dart';
import 'package:intl/intl.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({Key? key}) : super(key: key);

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  int _currentPage = 1;
  final int _limit = 20;
  String? _selectedAction;
  String? _selectedEntityType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivities();
    });
  }

  void _loadActivities() {
    final controller = Provider.of<ActivityController>(context, listen: false);
    controller.getUserActivityLog(
      page: _currentPage,
      limit: _limit,
      action: _selectedAction,
      entityType: _selectedEntityType,
    );
  }

  String _getActionIcon(String action) {
    if (action.contains('upload')) return '📤';
    if (action.contains('download')) return '📥';
    if (action.contains('delete')) return '🗑️';
    if (action.contains('restore')) return '♻️';
    if (action.contains('star')) return '⭐';
    if (action.contains('share')) return '🔗';
    if (action.contains('move')) return '📁';
    if (action.contains('create')) return '➕';
    if (action.contains('update')) return '✏️';
    if (action.contains('login')) return '🔐';
    if (action.contains('logout')) return '🚪';
    return '📋';
  }

  String _getActionName(String action) {
    final actionMap = {
      'file_uploaded': 'رفع ملف',
      'file_downloaded': 'تحميل ملف',
      'file_deleted': 'حذف ملف',
      'file_restored': 'استعادة ملف',
      'file_permanently_deleted': 'حذف ملف نهائياً',
      'file_updated': 'تحديث ملف',
      'file_moved': 'نقل ملف',
      'file_starred': 'إضافة ملف للمفضلة',
      'file_unstarred': 'إزالة ملف من المفضلة',
      'file_shared': 'مشاركة ملف',
      'file_unshared': 'إلغاء مشاركة ملف',
      'file_accessed_onetime': 'وصول لملف لمرة واحدة',
      'file_viewed_by_all_members': 'عرض ملف من قبل جميع الأعضاء',
      'folder_created': 'إنشاء مجلد',
      'folder_uploaded': 'رفع مجلد',
      'folder_deleted': 'حذف مجلد',
      'folder_restored': 'استعادة مجلد',
      'folder_permanently_deleted': 'حذف مجلد نهائياً',
      'folder_updated': 'تحديث مجلد',
      'folder_moved': 'نقل مجلد',
      'folder_starred': 'إضافة مجلد للمفضلة',
      'folder_unstarred': 'إزالة مجلد من المفضلة',
      'folder_shared': 'مشاركة مجلد',
      'folder_unshared': 'إلغاء مشاركة مجلد',
      'profile_updated': 'تحديث الملف الشخصي',
      'password_changed': 'تغيير كلمة المرور',
      'email_changed': 'تغيير البريد الإلكتروني',
      'account_deleted': 'حذف الحساب',
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'password_reset_requested': 'طلب إعادة تعيين كلمة المرور',
      'password_reset_completed': 'إعادة تعيين كلمة المرور',
    };
    return actionMap[action] ?? action;
  }

  String _getEntityTypeName(String entityType) {
    final typeMap = {
      'file': 'ملف',
      'folder': 'مجلد',
      'user': 'مستخدم',
      'system': 'نظام',
      'room': 'غرفة',
    };
    return typeMap[entityType] ?? entityType;
  }

  Color _getActionColor(String action) {
    if (action.contains('delete')) return Colors.red;
    if (action.contains('upload') || action.contains('create'))
      return Colors.green;
    if (action.contains('download')) return Colors.blue;
    if (action.contains('update') || action.contains('move'))
      return Colors.orange;
    if (action.contains('star') || action.contains('share'))
      return Colors.purple;
    if (action.contains('login') || action.contains('logout'))
      return Colors.teal;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return DateFormat('yyyy/MM/dd HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('سجل النشاط'),
        backgroundColor: const Color(0xff28336f),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'يعرض آخر 100 سجل نشاط',
              style: TextStyle(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: Consumer<ActivityController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.activities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null &&
              controller.activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage ?? 'حدث خطأ',
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadActivities,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (controller.activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد أنشطة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سيتم عرض نشاطك هنا',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _currentPage = 1;
              _loadActivities();
            },
            child: Column(
              children: [
                // ✅ إحصائيات سريعة
                if (controller.statistics != null)
                  _buildStatisticsCard(controller.statistics!),

                // ✅ قائمة الأنشطة
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        controller.activities.length +
                        (controller.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.activities.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final activity = controller.activities[index];
                      return _buildActivityCard(activity);
                    },
                  ),
                ),

                // ✅ Pagination
                if (controller.pagination != null)
                  _buildPagination(controller.pagination!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> statistics) {
    final totalActivities = statistics['totalActivities'] ?? 0;
    final period = statistics['period'] ?? '30 days';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'إجمالي النشاط',
            totalActivities.toString(),
            Icons.history,
          ),
          _buildStatItem('الفترة', period, Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xff28336f), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff28336f),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final action = activity['action'] as String? ?? '';
    final entityType = activity['entityType'] as String? ?? '';
    final entityName = activity['entityName'] as String?;
    final createdAt = activity['createdAt'] != null
        ? DateTime.parse(activity['createdAt'])
        : DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getActionColor(action).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              _getActionIcon(action),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          _getActionName(action),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (entityName != null)
              Text(
                entityName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getActionColor(action).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getEntityTypeName(entityType),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getActionColor(action),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () {
          _showActivityDetails(activity);
        },
      ),
    );
  }

  Widget _buildPagination(Map<String, dynamic> pagination) {
    final currentPage = pagination['currentPage'] ?? 1;
    final totalPages = pagination['totalPages'] ?? 1;
    final hasNext = pagination['hasNext'] ?? false;
    final hasPrev = pagination['hasPrev'] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: hasPrev
                ? () {
                    setState(() {
                      _currentPage = currentPage - 1;
                    });
                    _loadActivities();
                  }
                : null,
            child: const Text('السابق'),
          ),
          Text(
            'صفحة $currentPage من $totalPages',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: hasNext
                ? () {
                    setState(() {
                      _currentPage = currentPage + 1;
                    });
                    _loadActivities();
                  }
                : null,
            child: const Text('التالي'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية النشاط'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAction,
                decoration: const InputDecoration(
                  labelText: 'الإجراء',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل')),
                  const DropdownMenuItem(
                    value: 'file_uploaded',
                    child: Text('رفع ملف'),
                  ),
                  const DropdownMenuItem(
                    value: 'file_downloaded',
                    child: Text('تحميل ملف'),
                  ),
                  const DropdownMenuItem(
                    value: 'file_deleted',
                    child: Text('حذف ملف'),
                  ),
                  const DropdownMenuItem(
                    value: 'file_shared',
                    child: Text('مشاركة ملف'),
                  ),
                  const DropdownMenuItem(
                    value: 'folder_created',
                    child: Text('إنشاء مجلد'),
                  ),
                  const DropdownMenuItem(
                    value: 'login',
                    child: Text('تسجيل الدخول'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAction = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEntityType,
                decoration: const InputDecoration(
                  labelText: 'نوع العنصر',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل')),
                  const DropdownMenuItem(value: 'file', child: Text('ملف')),
                  const DropdownMenuItem(value: 'folder', child: Text('مجلد')),
                  const DropdownMenuItem(value: 'user', child: Text('مستخدم')),
                  const DropdownMenuItem(value: 'system', child: Text('نظام')),
                  const DropdownMenuItem(value: 'room', child: Text('غرفة')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedEntityType = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedAction = null;
                _selectedEntityType = null;
              });
            },
            child: const Text('إعادة تعيين'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _currentPage = 1;
              _loadActivities();
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(Map<String, dynamic> activity) {
    final action = activity['action'] as String? ?? '';
    final entityType = activity['entityType'] as String? ?? '';
    final entityName = activity['entityName'] as String?;
    final createdAt = activity['createdAt'] != null
        ? DateTime.parse(activity['createdAt'])
        : DateTime.now();
    final details = activity['details'] as Map<String, dynamic>? ?? {};
    final metadata = activity['metadata'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getActionColor(action),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getActionIcon(action),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getActionName(action),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (entityName != null)
                          Text(
                            entityName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('النوع', _getEntityTypeName(entityType)),
                    _buildDetailRow(
                      'التاريخ',
                      DateFormat('yyyy/MM/dd HH:mm').format(createdAt),
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'التفاصيل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...details.entries.map(
                        (entry) =>
                            _buildDetailRow(entry.key, entry.value.toString()),
                      ),
                    ],
                    if (metadata.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'معلومات إضافية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...metadata.entries.map(
                        (entry) =>
                            _buildDetailRow(entry.key, entry.value.toString()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
