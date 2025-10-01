import 'package:filevo/components/FolderFileCard.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/home/components/StorageCard.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isFoldersGridView = true;
  bool isFilesGridView = true;

  Icon _getFileIcon(String fileName) {
    if (fileName.endsWith('.pdf')) return Icon(Icons.picture_as_pdf, color: Colors.red);
    if (fileName.endsWith('.pptx')) return Icon(Icons.slideshow, color: Colors.orange);
    if (fileName.endsWith('.xlsx')) return Icon(Icons.table_chart, color: Colors.green);
    if (fileName.endsWith('.docx')) return Icon(Icons.description, color: Colors.blue);
    if (fileName.endsWith('.txt')) return Icon(Icons.text_snippet, color: Colors.grey);
    if (fileName.endsWith('.fig')) return Icon(Icons.design_services, color: Colors.purple);
    return Icon(Icons.insert_drive_file, color: Color(0xFF00BFA5));
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: const Color(0xff28336f),
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
                color: const Color(0xFFE9E9E9),
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
                                'Recent Folders',
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
                                  "See all",
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

                        GridView.builder(
                          itemCount: folders.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 3,
                              tablet: 4,
                              desktop: 5,
                            ).toInt(),
                            mainAxisSpacing: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 10.0,
                              tablet: 14.0,
                              desktop: 18.0,
                            ),
                            crossAxisSpacing: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 10.0,
                              tablet: 14.0,
                              desktop: 18.0,
                            ),
                            childAspectRatio: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 0.95,
                              tablet: 1.1,
                              desktop: 1.2,
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final folder = folders[index];
                            return FolderFileCard(
                              title: folder['title'] as String,
                              fileCount: folder['fileCount'] as int,
                              size: folder['size'] as String,
                              showFileCount: true,
                            );
                          },
                        ),

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
                                'Recent Files',
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
                              Container(
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
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isFilesGridView = true;
                                        });
                                      },
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
                                          color: isFilesGridView
                                              ? Colors.white
                                              : Colors.transparent,
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
                                          color: isFilesGridView
                                              ? Color(0xFF00BFA5)
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isFilesGridView = false;
                                        });
                                      },
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
                                          color: !isFilesGridView
                                              ? Colors.white
                                              : Colors.transparent,
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
                                          color: !isFilesGridView
                                              ? Color(0xFF00BFA5)
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
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

                        if (isFilesGridView)
                          GridView.builder(
                            itemCount: files.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 2,
                                tablet: 4,
                                desktop: 5,
                              ).toInt(),
                              mainAxisSpacing: ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 10.0,
                                tablet: 14.0,
                                desktop: 18.0,
                              ),
                              crossAxisSpacing: ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 10.0,
                                tablet: 14.0,
                                desktop: 18.0,
                              ),
                              childAspectRatio: ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 0.95,
                                tablet: 1.1,
                                desktop: 1.2,
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final file = files[index];
                              return FolderFileCard(
                                title: file['title'] as String,
                                fileCount: file['fileCount'] as int,
                                size: file['size'] as String,
                                showFileCount: false,
                              );
                            },
                          ),

                        if (!isFilesGridView)
                          ListView.builder(
                            itemCount: files.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            itemBuilder: (context, index) {
                              final file = files[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: _getFileIcon(file['title'] as String),
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
                                  trailing: Icon(Icons.more_vert),
                                ),
                              );
                            },
                          ),

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