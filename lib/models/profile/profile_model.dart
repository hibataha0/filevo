// import 'package:flutter/material.dart';

// enum ProfileModelStatus {
//   Ended,
//   Loading,
//   Error,
// }

// class ProfileModel extends ChangeNotifier {
//   ProfileModelStatus _status;
//   String _errorCode;
//   String _errorMessage;

//   String get errorCode => _errorCode;
//   String get errorMessage => _errorMessage;
//   ProfileModelStatus get status => _status;

//   ProfileModel();

//   ProfileModel.instance() {
//     //TODO Add code here
//   }
  
//   void getter() {
//     _status = ProfileModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here

//     _status = ProfileModelStatus.Ended;
//     notifyListeners();
//   }

//   void setter() {
//     _status = ProfileModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = ProfileModelStatus.Ended;
//     notifyListeners();
//   }

//   void update() {
//     _status = ProfileModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = ProfileModelStatus.Ended;
//     notifyListeners();
//   }

//   void remove() {
//     _status = ProfileModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = ProfileModelStatus.Ended;
//     notifyListeners();
//   }
// }