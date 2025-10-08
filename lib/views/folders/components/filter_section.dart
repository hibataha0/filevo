import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart';

class FilterSection extends StatefulWidget {
  final List<String> selectedTypes;
  final String selectedTimeFilter;
  final Function(List<String>) onTypesChanged;
  final Function(String) onTimeFilterChanged;

  const FilterSection({
    Key? key,
    required this.selectedTypes,
    required this.selectedTimeFilter,
    required this.onTypesChanged,
    required this.onTimeFilterChanged,
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
          // Type Section
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
              _buildTypeChip(S.of(context).images),
              _buildTypeChip(S.of(context).videos),
              _buildTypeChip(S.of(context).audio),
              _buildTypeChip(S.of(context).compressed),
              _buildTypeChip(S.of(context).applications),
              _buildTypeChip(S.of(context).documents),
              _buildTypeChip(S.of(context).code),
              _buildTypeChip(S.of(context).other),
            ],
          ),
          SizedBox(height: 16),

          // Time & Date Section
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
              _buildTimeChip(S.of(context).yesterday),
              _buildTimeChip(S.of(context).last7Days),
              _buildTimeChip(S.of(context).last30Days),
              _buildTimeChip(S.of(context).lastYear),
              _buildTimeChip(S.of(context).custom),
            ],
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

  Widget _buildTypeChip(String type) {
    IconData? getIconForType(String type) {
      switch (type.toLowerCase()) {
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

    bool isSelected = widget.selectedTypes.contains(type);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (getIconForType(type) != null)
            Icon(
              getIconForType(type),
              size: 16,
              color: isSelected ? Colors.white : Colors.black,
            ),
          SizedBox(width: 4),
          Text(type),
        ],
      ),
      selected: isSelected,
      selectedColor: Color(0xFF00BFA5),
      onSelected: (selected) {
        List<String> newSelectedTypes = List.from(widget.selectedTypes);
        if (selected) {
          newSelectedTypes.add(type);
        } else {
          newSelectedTypes.remove(type);
        }
        widget.onTypesChanged(newSelectedTypes);
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

  Widget _buildTimeChip(String time) {
    return ChoiceChip(
      label: Text(time),
      selected: widget.selectedTimeFilter == time,
      selectedColor: Color(0xFF00BFA5),
      onSelected: (selected) {
        widget.onTimeFilterChanged(selected ? time : S.of(context).all);
      },
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: widget.selectedTimeFilter == time ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}
