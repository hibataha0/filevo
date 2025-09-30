import 'package:filevo/components/FolderFileCard.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/home/components/StorageCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/models/home/home_model.dart';
import 'package:filevo/controllers/home/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xfff28336f),
      body: SafeArea(
        top: true,
        bottom: false,
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
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFE9E9E9),
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 16.0,
                      tablet: 24.0,
                      desktop: 32.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                            onPressed: () {
                              // الأكشن هنا
                            },
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
                      
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 10.0,
                          tablet: 15.0,
                          desktop: 20.0,
                        ),
                      ),
                      
                     GridView.count(

  crossAxisCount: ResponsiveUtils.getResponsiveValue(
    context,
    mobile: 3,   // دايمًا 3 كروت في الصف
    tablet: 4,
    desktop: 5,
  ).toInt(),
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  crossAxisSpacing: ResponsiveUtils.getResponsiveValue(
    context,
    mobile: 10.0,
    tablet: 14.0,
    desktop: 18.0,
  ),
  mainAxisSpacing: ResponsiveUtils.getResponsiveValue(
    context,
    mobile: 10.0,
    tablet: 14.0,
    desktop: 18.0,
  ),
  childAspectRatio: ResponsiveUtils.getResponsiveValue(
    context,
    mobile: 0.95,   // مناسب لـ 3 كروت في الموبايل
    tablet: 1.1,
    desktop: 1.2,
  ),
  children: [
    FolderFileCard(title: "Cyber Nexus", fileCount: 12, size: "12 GB"),
    FolderFileCard(title: "Product Development", fileCount: 21, size: "8 GB"),
    FolderFileCard(title: "Vendor Contracts", fileCount: 122, size: "32 GB"),
    // FolderFileCard(title: "Marketing", fileCount: 9, size: "5 GB"),
  ],

) ,

                      // SizedBox(height: 10.0),
                      
                      Padding(
                        padding:  EdgeInsets.zero,
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
                            TextButton(
                              onPressed: () {
                                // الأكشن هنا
                              },
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

                    ],
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

