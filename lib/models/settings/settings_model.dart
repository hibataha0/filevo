// import 'package:flutter/material.dart';

// enum SettingsModelStatus {
//   Ended,
//   Loading,
//   Error,
// }

// class SettingsModel extends ChangeNotifier {
//   SettingsModelStatus _status;
//   String _errorCode;
//   String _errorMessage;

//   String get errorCode => _errorCode;
//   String get errorMessage => _errorMessage;
//   SettingsModelStatus get status => _status;

//   SettingsModel();

//   SettingsModel.instance() {
//     //TODO Add code here
//   }
  
//   void getter() {
//     _status = SettingsModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here

//     _status = SettingsModelStatus.Ended;
//     notifyListeners();
//   }

//   void setter() {
//     _status = SettingsModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = SettingsModelStatus.Ended;
//     notifyListeners();
//   }

//   void update() {
//     _status = SettingsModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = SettingsModelStatus.Ended;
//     notifyListeners();
//   }

//   void remove() {
//     _status = SettingsModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = SettingsModelStatus.Ended;
//     notifyListeners();
//   }
// }