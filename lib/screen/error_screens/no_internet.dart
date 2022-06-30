import 'package:flutter/material.dart';
class NoInternetConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 60, color: Theme.of(context).primaryColor),
          Text('Opps,', textAlign: TextAlign.center, style: TextStyle( color:Colors.grey[400]),),
          Text('No Internet Connection', textAlign: TextAlign.center, style: TextStyle( color:Colors.grey[400]),),
        ],
      ),
    );
  }
}