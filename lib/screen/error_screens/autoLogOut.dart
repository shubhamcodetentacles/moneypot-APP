import 'package:flutter/material.dart';
import 'package:moneypot/screen/log_screens/login_screen.dart';

class AutoLogOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        );
  }

   popUpFor408(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Bet is already playing on another device, because someone is using your account on another device ',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
                // color: Theme.of(context).primaryColor,
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                   Navigator.pushNamedAndRemoveUntil(
                              context, LoginScreen.routeName, (route) => false);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
