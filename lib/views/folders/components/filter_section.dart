import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart';

class FilterSection extends StatefulWidget {
  final List<String> selectedTypes; // ✅ للفلترة القديمة (يمكن إزالتها لاحقاً)
  final String selectedTimeFilter;
  final String? selectedCategory; // ✅ التصنيف المحدد (واحد فقط)
  final String? selectedDateRange; // ✅ نطاق التاريخ المحدد
  final Function(List<String>) onTypesChanged;
  final Function(String) onTimeFilterChanged;
  final Function(String?) onCategoryChanged; // ✅ callback للتصنيف
  final Function(String?) onDateRangeChanged; // ✅ callback للتاريخ
  final Function(DateTime?) onStartDateChanged; // ✅ callback لتاريخ البداية
  final Function(DateTime?) onEndDateChanged; // ✅ callback لتاريخ النهاية

  const FilterSection({
    Key? key,
    required this.selectedTypes,
    required this.selectedTimeFilter,
    this.selectedCategory,
    this.selectedDateRange,
    required this.onTypesChanged,
    required this.onTimeFilterChanged,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  }) : super(key: key);

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveValue(context),
        vertical: 16.0,
      ),
      color: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Section (تصنيف واحد فقط للبحث الذكي)
          Text(
            S.of(context).type,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(S.of(context).images),
              _buildCategoryChip(S.of(context).videos),
              _buildCategoryChip(S.of(context).audio),
              _buildCategoryChip(S.of(context).compressed),
              _buildCategoryChip(S.of(context).applications),
              _buildCategoryChip(S.of(context).documents),
              _buildCategoryChip(S.of(context).code),
              _buildCategoryChip(S.of(context).other),
              // ✅ زر لإلغاء التصنيف
              if (widget.selectedCategory != null)
                _buildClearCategoryChip(),
            ],
          ),
          SizedBox(height: 16),

          // Time & Date Section (نطاق تاريخ واحد فقط للبحث الذكي)
          Text(
            S.of(context).timeAndDate,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDateRangeChip(S.of(context).yesterday),
              _buildDateRangeChip(S.of(context).last7Days),
              _buildDateRangeChip(S.of(context).last30Days),
              _buildDateRangeChip(S.of(context).lastYear),
              _buildDateRangeChip(S.of(context).custom),
              // ✅ زر لإلغاء التاريخ
              if (widget.selectedDateRange != null && widget.selectedDateRange != S.of(context).all)
                _buildClearDateRangeChip(),
            ],
          ),
          // ✅ عرض التواريخ المخصصة إذا كانت محددة
          if (widget.selectedDateRange == S.of(context).custom)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر نطاق التاريخ المخصص',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          'من',
                          widget.onStartDateChanged,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildDatePicker(
                          'إلى',
                          widget.onEndDateChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  double _getResponsiveValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16.0;
    if (width < 900) return 24.0;
    return 32.0;
  }


  // ✅ بناء chip للتصنيف (واحد فقط)
  Widget _buildCategoryChip(String category) {
    IconData? getIconForCategory(String category) {
      switch (category.toLowerCase()) {
        case 'images':
        case 'صور':
          return Icons.image;
        case 'videos':
        case 'فيديوهات':
          return Icons.videocam;
        case 'audio':
        case 'صوتيات':
          return Icons.audiotrack;
        case 'compressed':
        case 'مضغوط':
          return Icons.folder_zip;
        case 'applications':
        case 'تطبيقات':
          return Icons.apps;
        case 'documents':
        case 'مستندات':
          return Icons.description;
        case 'code':
        case 'رمز/كود':
          return Icons.code;
        case 'other':
        case 'أخرى':
          return Icons.more_horiz;
        default:
          return null;
      }
    }

    final isSelected = widget.selectedCategory == category;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (getIconForCategory(category) != null)
            Icon(
              getIconForCategory(category),
              size: 16,
              color: isSelected ? Colors.white : Colors.black,
            ),
          SizedBox(width: 4),
          Text(category),
        ],
      ),
      selected: isSelected,
      selectedColor: Color(0xFF00BFA5),
      onSelected: (selected) {
        widget.onCategoryChanged(selected ? category : null);
      },
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      checkmarkColor: Colors.white,
    );
  }

  // ✅ زر لإلغاء التصنيف
  Widget _buildClearCategoryChip() {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.clear, size: 16, color: Colors.red),
          SizedBox(width: 4),
          Text('إلغاء التصنيف', style: TextStyle(fontSize: 12)),
        ],
      ),
      onPressed: () {
        widget.onCategoryChanged(null);
      },
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: Colors.red),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // ✅ بناء chip لنطاق التاريخ (واحد فقط)
  Widget _buildDateRangeChip(String dateRange) {
    final isSelected = widget.selectedDateRange == dateRange;

    return ChoiceChip(
      label: Text(dateRange),
      selected: isSelected,
      selectedColor: Color(0xFF00BFA5),
      onSelected: (selected) {
        widget.onDateRangeChanged(selected ? dateRange : null);
      },
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  // ✅ زر لإلغاء التاريخ
  Widget _buildClearDateRangeChip() {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.clear, size: 16, color: Colors.red),
          SizedBox(width: 4),
          Text('إلغاء التاريخ', style: TextStyle(fontSize: 12)),
        ],
      ),
      onPressed: () {
        widget.onDateRangeChanged(null);
        widget.onStartDateChanged(null);
        widget.onEndDateChanged(null);
      },
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: Colors.red),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // ✅ بناء date picker للتواريخ المخصصة
  Widget _buildDatePicker(String label, Function(DateTime?) onDateSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: Locale('ar', 'SA'),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
            Icon(Icons.calendar_today, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
