import 'package:flutter/material.dart';

class CommingSoon extends StatelessWidget {
  static const routeName = '/comming-soon';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/comming-soon.jpg'),
            SizedBox(
              height: 20,
            ),
            Text(
              'Play more game',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'One day-One game',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Win and Enjoy',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                child: Text(
                  'Back',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        ),
      ),
    );
  }
}
