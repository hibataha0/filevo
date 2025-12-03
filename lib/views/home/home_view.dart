import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/home/components/StorageCard.dart';
import 'package:flutter/material.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/views/search/smart_search_page.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isFilesGridView = true;

  final folders = [
    {"title": "Cyber Nexus", "fileCount": 12, "size": "12 GB"},
    {"title": "Product Development", "fileCount": 21, "size": "8 GB"},
    {"title": "Vendor Contracts", "fileCount": 122, "size": "32 GB"},
  ];

  final files = [
    {"title": "Annual Report 2024.pdf", "fileCount": 0, "size": "2.5 MB"},
    {"title": "Marketing Strategy.pptx", "fileCount": 0, "size": "5.2 MB"},
    {"title": "Financial Data.xlsx", "fileCount": 0, "size": "1.8 MB"},
    {"title": "Project Proposal.docx", "fileCount": 0, "size": "890 KB"},
    {"title": "Client Meeting Notes.txt", "fileCount": 0, "size": "45 KB"},
    {"title": "Design Mockups.fig", "fileCount": 0, "size": "12 MB"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkAppBar : AppColors.lightAppBar,
      appBar: AppBar(
        title: Text('الرئيسية'),
        backgroundColor: isDarkMode ? AppColors.darkAppBar : AppColors.lightAppBar,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SmartSearchPage(),
                ),
              );
            },
            tooltip: 'بحث ذكي',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: Column(
          children: [
            StorageCard(),

            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 15.0,
                tablet: 20.0,
                desktop: 25.0,
              ),
            ),

            Expanded(
              child: Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 25.0,
                        tablet: 30.0,
                        desktop: 35.0,
                      ),
                    ),
                  ),
                ),
                color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveValue(
                            context,
                            mobile: 10.0,
                            tablet: 15.0,
                            desktop: 20.0,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).recentFolders,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveValue(
                                    context,
                                    mobile: 20.0,
                                    tablet: 24.0,
                                    desktop: 28.0,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  S.of(context).seeAll,
                                  style: TextStyle(
                                    color: Color(0xFF00BFA5),
                                    fontSize: ResponsiveUtils.getResponsiveValue(
                                      context,
                                      mobile: 14.0,
                                      tablet: 16.0,
                                      desktop: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveUtils.getResponsiveValue(
                            context,
                            mobile: 15.0,
                            tablet: 20.0,
                            desktop: 25.0,
                          ),
                        ),

                        // FilesGridView(
                        //   items: folders,
                        //   showFileCount: true,
                        // ),

                        SizedBox(
                          height: ResponsiveUtils.getResponsiveValue(
                            context,
                            mobile: 20.0,
                            tablet: 25.0,
                            desktop: 30.0,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).recentFiles,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveValue(
                                    context,
                                    mobile: 20.0,
                                    tablet: 24.0,
                                    desktop: 28.0,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ViewToggleButtons(
                                isGridView: isFilesGridView,
                                onViewChanged: (isGrid) {
                                  setState(() {
                                    isFilesGridView = isGrid;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveUtils.getResponsiveValue(
                            context,
                            mobile: 15.0,
                            tablet: 20.0,
                            desktop: 25.0,
                          ),
                        ),

                        // if (isFilesGridView)
                        //   FilesGridView(
                        //     items: files,
                        //     showFileCount: false,
                        //   ),

                        // if (!isFilesGridView)
                        //   FilesListView(
                        //     items: files,
                        //     itemMargin: EdgeInsets.only(bottom: 10),
                        //     showMoreOptions: true,
                        //   ),

                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}