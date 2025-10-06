import 'package:flutter/material.dart';

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
            'Type',
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
              _buildTypeChip('Image'),
              _buildTypeChip('Video'),
              _buildTypeChip('Audio'),
              _buildTypeChip('Compressed'),
              _buildTypeChip('Applications'),
              _buildTypeChip('Documents'),
              _buildTypeChip('Code'),
              _buildTypeChip('Other'),
            ],
          ),
          SizedBox(height: 16),

          // Time & Date Section
          Text(
            'Time & Date',
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
              _buildTimeChip('Yesterday'),
              _buildTimeChip('Last 7 days'),
              _buildTimeChip('Last 30 days'),
              _buildTimeChip('Last year'),
              _buildTimeChip('Custom'),
            ],
          ),
        ],
      ),
    );
  }

  double _getResponsiveValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 16.0;
    } else if (width < 900) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  // زر نوع الملف
  Widget _buildTypeChip(String type) {
    IconData? getIconForType(String type) {
      switch (type.toLowerCase()) {
        case 'image':
          return Icons.image;
        case 'video':
          return Icons.videocam;
        case 'audio':
          return Icons.audiotrack;
        case 'compressed':
          return Icons.folder_zip;
        case 'applications':
          return Icons.apps;
        case 'documents':
          return Icons.description;
        case 'code':
          return Icons.code;
        case 'other':
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

  // زر الوقت
  Widget _buildTimeChip(String time) {
    return ChoiceChip(
      label: Text(time),
      selected: widget.selectedTimeFilter == time,
      selectedColor: Color(0xFF00BFA5),
      onSelected: (selected) {
        widget.onTimeFilterChanged(selected ? time : 'All');
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