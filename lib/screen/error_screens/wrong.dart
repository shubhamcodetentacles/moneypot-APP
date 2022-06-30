import 'package:flutter/material.dart';
class Wrong extends StatelessWidget {
  final String infoText;
  Wrong(this.infoText);
  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.report_problem, size: 60, color: Theme.of(context).primaryColor,),
          Text(infoText==''?'Something Went Wrong':infoText, textAlign: TextAlign.center, style: TextStyle( color:Colors.grey[400]),),
        ],
      ),
    );
  }
}