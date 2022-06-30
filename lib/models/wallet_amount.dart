// @dart=2.9
import 'package:flutter/widgets.dart';

class WalletAmount extends ChangeNotifier {
  String _amount;
  String _exposureLimit;
  String get amount => _amount;
  String get exposureLimit => _exposureLimit;

  WalletAmount();

  void changeAmount(
    String val,
  ) {
    _amount = val;

    notifyListeners();
  }

  void changeExposureLimit(
    String val,
  ) {
    _exposureLimit = val;

    notifyListeners();
  }
}
