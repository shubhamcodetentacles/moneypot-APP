// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:moneypot/models/wallet_amount.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/provider/store.dart';
import 'package:moneypot/screen/error_screens/comming_soon.dart';
import 'package:moneypot/screen/error_screens/time_date_check.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:moneypot/screen/onboarding_screen/onboarding_screen.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:moneypot/widget/five_min_games.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import './provider/flag.dart';
import './widget/play_number.dart';
import './widget/wallet.dart';
import './screen/tab_screens/bids_screen.dart';
import './screen/tab_screens/profile_screen.dart';
import 'screen/tab_screens/result_screen.dart';
import './screen/tab_screens/home_screen.dart';
import './screen/tab_screens/tab_screen.dart';
import './screen/log_screens/login_screen.dart';
import './screen/log_screens/change_password_screen.dart';
import './screen/error_screens/time_date_check.dart';
import './widget/bids.dart';

const bool isProduction = bool.fromEnvironment('dart.vm.product');
const String openBidMessage = "Time has been expired for open bid...!";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences.setMockInitialValues({});
// ignore: avoid_print
  print(isProduction);
  if (isProduction) {
    debugPrint = (String message, {int wrapWidth}) {};
  }
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
  static void setAppColor(BuildContext context) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setStoreColor();
  }
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _onBoarding = false;
  Color appColor = Colors.pink;
  Color textAppColor = Color.fromRGBO(20, 51, 51, 1);

  Future<void> loginScreen() async {
    sharedStore.restoreSession();
    sharedStore.isSessionValid.first.then((value) {
      if (value == true) {
        setState(() {
          _isLoggedIn = true;
          _onBoarding = true;
        });
      }
    });
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    // bool onBoarding = prefs.getBool('onboarding') ?? false;
    // setState(() {
    //   _isLoggedIn = isLoggedIn;
    //   _onBoarding = onBoarding;
    // });
  }

  setStoreColor() async {
    await sharedStore.getAppColor().then((value) {
      if (value['appColor'] != null && value['font_color'] != null) {
        setState(() {
          appColor = HexColor(value['appColor']);
          textAppColor = HexColor(value['font_color']);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    loginScreen();
    setStoreColor();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Flag()),
        ChangeNotifierProvider(
          create: (context) => WalletAmount(),
        )
      ],
      child: MaterialApp(
        title: 'Galaxy Exch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: appColor,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              unselectedItemColor: textAppColor,
              selectedLabelStyle: TextStyle(color: textAppColor),
              unselectedLabelStyle: TextStyle(color: textAppColor),
              unselectedIconTheme: IconThemeData(color: textAppColor),
              selectedItemColor: textAppColor,
              selectedIconTheme: IconThemeData(color: textAppColor)),
          appBarTheme: AppBarTheme(
              actionsIconTheme: IconThemeData(color: textAppColor),
              iconTheme: IconThemeData(color: textAppColor),
              color: textAppColor,
              titleTextStyle: TextStyle(color: textAppColor, fontSize: 22)),
          accentColor: Colors.white,
          primaryColorLight: appColor.withOpacity(0.2),
          textTheme: ThemeData.light().textTheme.copyWith(
              bodyText1: const TextStyle(
                color: Color.fromRGBO(20, 51, 51, 1),
              ),
              bodyText2: const TextStyle(
                color: Color.fromRGBO(20, 51, 51, 1),
              ),
              headline1: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'RobotoCondensed',
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(20, 51, 51, 1))),
        ),
        home: (_onBoarding && _isLoggedIn)
            ? TabScreen(selectedIndex: 0)
            : (_onBoarding && !_isLoggedIn)
                ? LoginScreen()
                : OnBoardingScreen(),
        routes: {
          OnBoardingScreen.routeName: (ctx) => OnBoardingScreen(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          BidsScreen.routeName: (ctx) => BidsScreen(),
          ResultScreen.routeName: (ctx) => ResultScreen(),
          ProfileScreen.routeName: (ctx) => ProfileScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          ChangePasswordScreen.routeName: (ctx) => ChangePasswordScreen(),
          TabScreen.routeName: (ctx) => TabScreen(selectedIndex: 0),
          Bids.routeName: (ctx) => Bids(),
          Wallet.routeName: (ctx) => Wallet(),
          PlayNumber.routeName: (ctx) => PlayNumber(),
          CommingSoon.routeName: (ctx) => CommingSoon(),
          FiveMinGames.routeName: (ctx) => FiveMinGames(),
          TimeDateCheck.routeName: (ctx) => TimeDateCheck(),
        },
      ),
    );
  }
}
