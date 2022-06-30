import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

class SysDateTimeChange extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  checkDateAndTime(context) async {
    var netTime = await NTP.now();
    var sysTime = DateTime.now();
    List net = [];
    List sys = [];
    net = (netTime.toString()).split(' ');
    sys = (sysTime.toString()).split(' ');

    

    
    List netSlitTime = [];
    List sysSlitTime = [];

    netSlitTime = (net[1].toString()).split(':');
    sysSlitTime = (sys[1].toString()).split(':');
    
    

    if ((net[0] != sys[0]) ||
        netSlitTime[0] != sysSlitTime[0] ||
        netSlitTime[1] != sysSlitTime[1]) {
     
      return true;
    } else {
     
      return false;
    }

  }

  popUpForDateTimeChange(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Your device date or time has been changed, Please change date or time',
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
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
