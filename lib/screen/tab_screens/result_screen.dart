import 'package:flutter/material.dart';
import 'package:moneypot/widget/result.dart';

class ResultScreen extends StatefulWidget {
    static const routeName='/my-wins';
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  @override
  Widget build(BuildContext context) {
    return Result();
  }
}