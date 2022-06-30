import 'package:flutter/material.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/games_screens/game_tabs.dart';
import "package:http/http.dart" as http;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
 
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.80,
            child: GameTabs(),
          ),
        ],
      ),
    );
  }
}
