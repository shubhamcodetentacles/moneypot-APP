import 'package:flutter/material.dart';

class Info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom:10.0),
            child: Text('Play Game', style: TextStyle(fontSize: 20, color:Colors.grey[800]),),
          ),
          Text('1. Choose Number', style: TextStyle( color:Colors.grey[600]),),
          Text('2. Enter Amoount', style: TextStyle( color:Colors.grey[600]),),
          Text('3. Press Add', style: TextStyle( color:Colors.grey[600]),),
        ],
      ),
    );
  }
}