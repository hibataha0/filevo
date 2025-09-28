import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:filevo/views/home/components/StorageChartPainter.dart';
import 'package:flutter/material.dart';

class StorageCard extends StatelessWidget {
  const StorageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
           Colors.white.withOpacity(0.6),
           Colors.white.withOpacity(0.001),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
             Container(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: StorageChartPainter(),
                child: Center(
                  child: Container(
                    width: 80 ,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:Color(0xFF00BFA5),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                         Text(
                          'Used',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '60%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
             ),
              SizedBox(width: 32),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(width: 12,),
                         // معلومات التخزين
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Free Intrtnal',
                              style: TextStyle(
                                color:Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                          '120.5 GB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 24),
                
                // Used
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(0xFF00BFA5),
                        shape: BoxShape.circle,
                      ),
                    
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Used',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '149.5 GB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20  ,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                )
                  ],
                ),
              ),
        ],
      ),
    );

           
           
          
        
      
    
  }
}
