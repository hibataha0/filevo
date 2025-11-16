import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';

class FilesListView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final EdgeInsetsGeometry? itemMargin;
  final bool showMoreOptions;
  final void Function(Map<String, dynamic>)? onItemTap; // <--- أضفنا

  const FilesListView({
    Key? key,
    required this.items,
    this.itemMargin,
    this.showMoreOptions = true,
    this.onItemTap, // <--- أضفنا
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemBuilder: (context, index) {
        final file = items[index];
        return Card(
          margin: itemMargin ?? EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(Icons.insert_drive_file, color: Color(0xFF00BFA5)),
            title: Text(
              file['title'] as String,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 14.0,
                  tablet: 15.0,
                  desktop: 16.0,
                ),
              ),
            ),
            subtitle: Text(
              file['size'] as String,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 13.0,
                  desktop: 14.0,
                ),
              ),
            ),
            trailing: showMoreOptions ? Icon(Icons.more_vert) : null,
            onTap: () {
              if (onItemTap != null) {
                onItemTap!(file); // <--- هنا يستدعي الكولباك
              }
            },
          ),
        );
      },
    );
  }
}
