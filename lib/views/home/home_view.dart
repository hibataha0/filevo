// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// // import model
// import 'package:filevo/models/home/home_model.dart';
// // import controller
// import 'package:filevo/controllers/home/home_controller.dart';

// class HomeView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     HomeController viewController = HomeController();
//     return ChangeNotifierProvider<HomeModel>(
//       create: (context) => HomeModel.instance(),
//       child: Consumer<HomeModel>(
//         builder: (context, viewModel, child) {
//           return Container(
//               //TODO Add layout or component here
//               );
//         },
//       ),
//     );
//   }
// }