// @dart=2.9
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:moneypot/provider/store.dart';
import 'package:moneypot/screen/log_screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  static const routeName = '/onboarding_screen';

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int page = 0;
  LiquidController liquidController;
  UpdateType updateType;
  addBoolToSF() async {
    sharedStore.setOnboarding();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool('onboarding', true);
  }

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
  }

  static const TextStyle descriptionWhiteStyle = TextStyle(
    color: Colors.white,
    fontSize: 20.0,
  );

  static const TextStyle whitestyle = TextStyle(
    color: Colors.white,
    fontSize: 40.0,
  );
  static const TextStyle boldstyle = TextStyle(
    color: Colors.black,
    fontSize: 50.0,
    fontWeight: FontWeight.bold,
  );
  final pages = [
    Container(
      color: Colors.redAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/onboarding-1.png"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Online',
                  style: whitestyle,
                ),
                Text(
                  'Betting',
                  style: boldstyle,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Temporibus autem aut\n"
                  "officiis debitis aut rerum\n"
                  "necessitatibus",
                  style: descriptionWhiteStyle,
                ),
              ],
            ),
          )
        ],
      ),
    ),
    Container(
      color: Color(0xFF55006c),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/onboarding-2.png"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Online',
                  style: whitestyle,
                ),
                Text(
                  'Gambling',
                  style: whitestyle,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Excepteur sint occaecat cupidatat\n"
                  "non proident, sunt in\n"
                  "culpa qui officia",
                  style: descriptionWhiteStyle,
                ),
              ],
            ),
          )
        ],
      ),
    ),
    Container(
      color: Colors.orange,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset("assets/onboarding-1.png"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Online",
                  style: whitestyle,
                ),
                Text(
                  "Gambling",
                  style: boldstyle,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Temporibus autem aut\n"
                  "officiis debitis aut rerum\n"
                  "necessitatibus",
                  style: descriptionWhiteStyle,
                ),
              ],
            ),
          )
        ],
      ),
    ),
  ];

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page ?? 0) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return new Container(
      width: 25.0,
      child: new Center(
        child: new Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: new Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            LiquidSwipe(
              pages: pages,
              onPageChangeCallback: pageChangeCallback,
              waveType: WaveType.liquidReveal,
              liquidController: liquidController,
              enableSlideIcon: true,
              enableLoop: false,
              slideIconWidget: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(pages.length, _buildDot),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    addBoolToSF();
                    Navigator.of(context).pushNamed(LoginScreen.routeName);
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    primary: Colors.white.withOpacity(0.01),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    if (liquidController.currentPage == 2) {
                      addBoolToSF();
                      Navigator.of(context).pushNamed(LoginScreen.routeName);
                    } else {
                      liquidController.animateToPage(
                          page: liquidController.currentPage + 1,
                          duration: 500);
                    }
                  },
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    primary: Colors.white.withOpacity(0.01),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }
}
