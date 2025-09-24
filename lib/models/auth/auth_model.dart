// import 'package:flutter/material.dart';

// enum AuthModelStatus {
//   Ended,
//   Loading,
//   Error,
// }

// class AuthModel extends ChangeNotifier {
//   AuthModelStatus _status;
//   String _errorCode;
//   String _errorMessage;

//   String get errorCode => _errorCode;
//   String get errorMessage => _errorMessage;
//   AuthModelStatus get status => _status;

//   AuthModel();

//   AuthModel.instance() {
//     //TODO Add code here
//   }
  
//   void getter() {
//     _status = AuthModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here

//     _status = AuthModelStatus.Ended;
//     notifyListeners();
//   }

//   void setter() {
//     _status = AuthModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = AuthModelStatus.Ended;
//     notifyListeners();
//   }

//   void update() {
//     _status = AuthModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = AuthModelStatus.Ended;
//     notifyListeners();
//   }

//   void remove() {
//     _status = AuthModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = AuthModelStatus.Ended;
//     notifyListeners();
//   }
// }