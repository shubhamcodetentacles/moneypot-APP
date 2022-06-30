import 'package:flutter/material.dart';

class TimeDateCheck extends StatelessWidget {
  static const routeName = '/date-time';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(''),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Warning',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
              ),
              Text(
                'Your device date or time has been changed, Please change date or time',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'To change date and time',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Go to your device setting',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Ok',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
