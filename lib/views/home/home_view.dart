import 'package:filevo/views/home/components/StorageCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import model
import 'package:filevo/models/home/home_model.dart';
// import controller
import 'package:filevo/controllers/home/home_controller.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF28336F),
       body: SafeArea(
         child: Column(
             children: [
               StorageCard(), // الكارت اللي فوق
               // باقي الصفحة...
               SizedBox(height: 20), // مسافة بين الكارت وباقي الصفحة
          Expanded(
               child: Container(
          width: double.infinity,   // عرض الشاشة كامل
          decoration: BoxDecoration(
            color: Color( 0xFFE9E9E9), // خلفية بيضاء
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30), // يعطي شكل بيضاوي من فوق
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Folders',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     
         TextButton(
               onPressed: () {
          // هون بتحطي الأكشن تبع الزر
               },
               child: Text(
          "See all",
          style: TextStyle(
            color: Color(0xFF00BFA5),
            fontSize: 16,
          ),
               ),
             ),
         
                  ],
                ),
                SizedBox(height: 10),
                // هنا ممكن تضيف قائمة الملفات الأخيرة
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 10, // عدد الملفات الأخيرة
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.insert_drive_file, color: Colors.blue),
                      title: Text('File $index'),
                      subtitle: Text('Size: ${(index + 1) * 10} MB'),
                      trailing: Text('Date: 2024-0${index + 1}-01'),
                    );
                  },
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