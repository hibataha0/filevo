import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';

class ViewToggleButtons extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final String? label;

  const ViewToggleButtons({
    Key? key,
    required this.isGridView,
    required this.onViewChanged,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 6.0,
          tablet: 8.0,
          desktop: 10.0,
        ),
        vertical: ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 4.0,
          tablet: 5.0,
          desktop: 6.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 13.0,
                  desktop: 14.0,
                ),
                color: Colors.grey[700],
              ),
            ),
            SizedBox(width: 8),
          ],
          InkWell(
            onTap: () => onViewChanged(true),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 6.0,
                  tablet: 7.0,
                  desktop: 8.0,
                ),
              ),
              decoration: BoxDecoration(
                color: isGridView ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 18.0,
                  tablet: 20.0,
                  desktop: 22.0,
                ),
                color: isGridView ? Color(0xFF00BFA5) : Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 4),
          InkWell(
            onTap: () => onViewChanged(false),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 6.0,
                  tablet: 7.0,
                  desktop: 8.0,
                ),
              ),
              decoration: BoxDecoration(
                color: !isGridView ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.list,
                size: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 18.0,
                  tablet: 20.0,
                  desktop: 22.0,
                ),
                color: !isGridView ? Color(0xFF00BFA5) : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}