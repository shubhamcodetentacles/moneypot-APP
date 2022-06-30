// @dart=2.9
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
// import 'package:timer_builder/timer_builder.dart';

class BidDetails extends StatefulWidget {
  final Map<String, dynamic> companyData;
  final String type;

  BidDetails({this.companyData, this.type});

  @override
  _BidDetailsState createState() => _BidDetailsState();
}

class _BidDetailsState extends State<BidDetails> {
  double fullHeight = 100.0;
  double firstRowHeight = 30.0;
  double secondRowHeight = 30.0;
  double thirdRowHeight = 40.0;

  @override
  void dispose() {
    if (!mounted) {
      return;
    }
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> getNetworkTime() async {
    var now = await NTP.now();
    
    setState(() {
      // _digitalClock = new DateFormat("hh:mm:ss aa").format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final openTimeSplit = widget.companyData['s_time'].split(' ');
    final closeTimeSplit = widget.companyData['end_time'].split(' ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
            bottom: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 15,
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right:
                            BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
                      ),
                    ),
                    height: firstRowHeight,
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      new DateFormat.MMM().format(new DateTime.now()),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right:
                            BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
                      ),
                    ),
                    height: thirdRowHeight,
                    alignment: Alignment.center,
                    child: Text(
                      new DateFormat.d().format(new DateTime.now()),
                      style: TextStyle(
                        fontSize: 26.0,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right:
                            BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
                      ),
                    ),
                    height: firstRowHeight,
                    alignment: Alignment.topCenter,
                    child: Text(
                      new DateFormat.y().format(new DateTime.now()),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 50,
              child: Container(
                height: fullHeight,
                child: widget.type == 'dailyGame'
                    ? Column(
                        children: <Widget>[
                          Expanded(
                            flex: 100,
                            child: Container(
                              height: fullHeight,
                              child: Column(
                                children: [
                                  Container(
                                    height: thirdRowHeight,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          'Play Between',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 100,
                            child: Container(
                              height: fullHeight,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'Starts At :',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            openTimeSplit[0],
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          ),
                                          Text(
                                            ' ' + openTimeSplit[1],
                                            style: TextStyle(
                                              fontSize: 10.0,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          ' Ends At :',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            closeTimeSplit[0],
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          ),
                                          Text(
                                            ' ' + closeTimeSplit[1],
                                            style: TextStyle(
                                              fontSize: 10.0,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Expanded(
                            flex: 35,
                            child: Container(
                              height: fullHeight,
                              child: Column(
                                children: [
                                  Container(
                                    height: thirdRowHeight,
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        widget.companyData['s_time'],
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: thirdRowHeight,
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      widget.companyData['win_no']['openPatti'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 30,
                            child: Container(
                              height: fullHeight,
                              alignment: Alignment.center,
                              child: Text(
                                widget.companyData['win_no']['open'] +
                                    widget.companyData['win_no']['close'],
                                style: TextStyle(
                                  fontSize: 44.0,
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 35,
                            child: Container(
                              height: fullHeight,
                              child: Column(
                                children: [
                                  Container(
                                    height: thirdRowHeight,
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        widget.companyData['end_time'],
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: thirdRowHeight,
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      widget.companyData['win_no']
                                          ['closePatti'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
              ),
            ),
            Expanded(
              flex: 35,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
                  ),
                ),
                height: fullHeight,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: DigitalClock(
                        digitAnimationStyle: Curves.elasticOut,
                        is24HourTimeFormat: false,
                        areaDecoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        areaAligment: AlignmentDirectional.center,
                        hourMinuteDigitTextStyle: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 25,
                        ),
                        hourMinuteDigitDecoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(5)),
                        secondDigitDecoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(5)),
                        amPmDigitTextStyle: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget digiTimer() {
  //   return TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
  //     getNetworkTime();
  //     return Text(
  //       "${_digitalClock.toString()}",
  //       textAlign: TextAlign.center,
  //       style: TextStyle(
  //         fontSize: 20.0,
  //         color: Theme.of(context).accentColor,
  //       ),
  //     );
  //   });
  // }
}
