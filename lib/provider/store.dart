import "package:shared_preferences/shared_preferences.dart";
import "package:rxdart/rxdart.dart";

class SharedStore {
  final PublishSubject<bool> _isSessionValid = PublishSubject<bool>();
  Stream<bool> get isSessionValid => _isSessionValid.stream;

  void restoreSession() async {
    bool session = await isSession();
    if (session) {
      _isSessionValid.sink.add(true);
    } else {
      _isSessionValid.sink.add(false);
    }
  }

  void openSession(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("UserToken", data['token']);
    await prefs.setString('name', data['user_data']['user_name']);
    await prefs.setString('email', data['user_data']['user_email']);
    await prefs.setString('mobileNo', data['user_data']['mobile_number']);
    await prefs.setString('walletAmount', data['user_data']['wallet_amount']);
    await prefs.setString("appColor", data["user_data"]['color_code']);
    await prefs.setString("font_color", data["user_data"]['font_color']);
    await prefs.setBool('isLoggedIn', true);
    bool session = await isSession();
    if (session) {
      _isSessionValid.sink.add(true);
    }
  }

  void closeSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("UserToken");
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('mobileNo');
    await prefs.remove('walletAmount');
    await prefs.remove('appColor');
    await prefs.remove('font_color');
    await prefs.remove('isLoggedIn');
    bool isContain = prefs.containsKey("UserToken");
    if (isContain) {
      bool isUserTokenRemoved = await prefs.remove("UserToken");
      // bool isSourceRemoved = await prefs.remove("Source");
      if (isUserTokenRemoved ) {
        _isSessionValid.sink.add(false);
      } else {
        _isSessionValid.sink.add(true);
      }
    }
  }

 Future<Map<String,String>> getAppColor() async {
   SharedPreferences pref = await SharedPreferences.getInstance();
    String colorCode = pref.getString("appColor");
    String fontColor = pref.getString("font_color");
    return {"appColor":colorCode,"font_color":fontColor};
  }

  Future<String?> getSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isContainKey = prefs.containsKey("UserToken");
    if (isContainKey) {
      String? UserToken = prefs.getString("UserToken");
      // Map<String, String> mapData = parseStoredData(UserToken);
      return UserToken;
    }
    return null;
  }

  Future<bool> isSession() async {
    String? sessionKey = await getSessionKey();
    if (sessionKey != "" && sessionKey != null) {
      return true;
    }
    return false;
  }

  setOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('onboarding', true);
  }

  void dispose() {
    _isSessionValid.close();
  }
}

SharedStore sharedStore = SharedStore();