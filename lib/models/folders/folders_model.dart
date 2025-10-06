// import 'package:flutter/material.dart';

// enum FoldersModelStatus {
//   Ended,
//   Loading,
//   Error,
// }

// class FoldersModel extends ChangeNotifier {
//   FoldersModelStatus _status;
//   String _errorCode;
//   String _errorMessage;

//   String get errorCode => _errorCode;
//   String get errorMessage => _errorMessage;
//   FoldersModelStatus get status => _status;

//   FoldersModel();

//   FoldersModel.instance() {
//     //TODO Add code here
//   }
  
//   void getter() {
//     _status = FoldersModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here

//     _status = FoldersModelStatus.Ended;
//     notifyListeners();
//   }

//   void setter() {
//     _status = FoldersModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = FoldersModelStatus.Ended;
//     notifyListeners();
//   }

//   void update() {
//     _status = FoldersModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = FoldersModelStatus.Ended;
//     notifyListeners();
//   }

//   void remove() {
//     _status = FoldersModelStatus.Loading;
//     notifyListeners();

//     //TODO Add code here
    
//     _status = FoldersModelStatus.Ended;
//     notifyListeners();
//   }
// }