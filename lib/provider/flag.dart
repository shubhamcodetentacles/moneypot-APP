

import 'package:flutter/material.dart';

class Flag extends ChangeNotifier{
  String _flag='hi';

  String get bidFlag{
    return _flag;
  }

  void setFlag(String flag){
    _flag=flag;
    notifyListeners();
  }
}