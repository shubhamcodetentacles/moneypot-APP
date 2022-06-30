import 'package:flutter/material.dart';
import 'package:moneypot/widget/chart_game_list.dart';

class ChartScreen extends StatefulWidget {
  static const routeName = '/chart';
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  Widget build(BuildContext context) {
    return ChartGameList();
  }
}
