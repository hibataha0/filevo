// import 'package:flutter/material.dart';

// enum HomeModelStatus {
//   Ended,
//   Loading,
//   Error,
// }

// class HomeModel extends ChangeNotifier {
//   HomeModelStatus _status;
//   String _errorCode;
//   String _errorMessage;

//   String get errorCode => _errorCode;
//   String get errorMessage => _errorMessage;
//   HomeModelStatus get status => _status;

//   HomeModel();

//   HomeModel.instance() {
//     //TODO Add code here
//   }
  
//   void getter() {
//     _status = HomeModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here

//     _status = HomeModelStatus.Ended;
//     notifyListeners();
//   }

//   void setter() {
//     _status = HomeModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = HomeModelStatus.Ended;
//     notifyListeners();
//   }

//   void update() {
//     _status = HomeModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = HomeModelStatus.Ended;
//     notifyListeners();
//   }

//   void remove() {
//     _status = HomeModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = HomeModelStatus.Ended;
//     notifyListeners();
//   }
// }