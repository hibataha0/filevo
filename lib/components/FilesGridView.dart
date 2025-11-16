import 'package:filevo/components/FolderFileCard.dart';
import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';

class FilesGridView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool showFileCount;
  final int? crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? childAspectRatio;
  final void Function(Map<String, dynamic>)? onItemTap; // <--- أضفنا

  const FilesGridView({
    Key? key,
    required this.items,
    required this.showFileCount,
    this.crossAxisCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.onItemTap, // <--- أضفنا
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount ?? ResponsiveUtils.getResponsiveValue(
          context,
          mobile: showFileCount ? 3 : 2,
          tablet: showFileCount ? 4 : 4,
          desktop: showFileCount ? 5 : 5,
        ).toInt(),
        mainAxisSpacing: mainAxisSpacing ?? ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 10.0,
          tablet: 14.0,
          desktop: 18.0,
        ),
        crossAxisSpacing: crossAxisSpacing ?? ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 10.0,
          tablet: 14.0,
          desktop: 18.0,
        ),
        childAspectRatio: childAspectRatio ?? ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 0.95,
          tablet: 1.1,
          desktop: 1.2,
        ),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            if (onItemTap != null) {
              onItemTap!(item); // <--- هنا ينادي الكولباك
            }
          },
          child: FolderFileCard(
            title: item['title'] as String,
            fileCount: item['fileCount'] as int,
            size: item['size'] as String,
            showFileCount: showFileCount,
          ),
        );
      },
    );
  }
}
