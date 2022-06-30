import 'package:flutter/material.dart';

class DataNotFound extends StatelessWidget {
  final String infoText;
  DataNotFound(this.infoText);
  @override
  Widget build(BuildContext context) {
    
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.find_in_page, size: 60, color: Theme.of(context).primaryColor,),
          Text(infoText, textAlign: TextAlign.center, style: TextStyle( color:Colors.grey[400]),),
        ],
      ),
    );
  }
}