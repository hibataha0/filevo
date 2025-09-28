// import 'package:flutter/material.dart';

// enum MainModelStatus {
//   Ended,
//   Loading,
//   Error,
// }

// class MainModel extends ChangeNotifier {
//   MainModelStatus _status;
//   String _errorCode;
//   String _errorMessage;

//   String get errorCode => _errorCode;
//   String get errorMessage => _errorMessage;
//   MainModelStatus get status => _status;

//   MainModel();

//   MainModel.instance() {
//     //TODO Add code here
//   }
  
//   void getter() {
//     _status = MainModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here

//     _status = MainModelStatus.Ended;
//     notifyListeners();
//   }

//   void setter() {
//     _status = MainModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = MainModelStatus.Ended;
//     notifyListeners();
//   }

//   void update() {
//     _status = MainModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = MainModelStatus.Ended;
//     notifyListeners();
//   }

//   void remove() {
//     _status = MainModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = MainModelStatus.Ended;
//     notifyListeners();
//   }
// }