// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moneypot/models/game.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/tab_screens/tab_screen.dart';

class DayGameViewResult extends StatefulWidget {
  static const routeName = '/day-game-view-result';

  final int bidID;

  DayGameViewResult({
    Key key,
    this.bidID,
  }) : super(key: key);

  @override
  _DayGameViewResultState createState() => _DayGameViewResultState(bidID);
}

class _DayGameViewResultState extends State<DayGameViewResult> {
  int _bID;
  bool _isLoader = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _DayGameViewResultState(this._bID);
  List _games = [];

  Future _getBidDetails(bID) async {
    final String url = 'api/pana_game_bid_data';
    final data = jsonEncode(<String, dynamic>{'bid_id': _bID});

    try {
      var response = await postData(url, data, true);

      setState(() {
        _isLoader = true;
      });
      if (response.statusCode == 200) {
        setState(() {
          _isLoader = false;
        });

        var data = jsonDecode(response.body);
        
        final List rData = data['pana_game'];
        for (int i = 0; i <= rData.length - 1; i++) {
          setState(() {
            _games.add(
              Game(
                  amount: rData[i]['bid_amount'].toString(),
                  numbers: rData[i]['bid_number'].toString(),
                  type: rData[i]['is_open'] == 1
                      ? 'O'
                      : rData[i]['is_open'] == 2
                          ? 'C'
                          : '',
                  gameName: rData[i]['game_name'],
                  isWinner: rData[i]['is_winner']),
            );
          });
        }
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        setState(() {
          _isLoader = false;
        });

        final eData = jsonDecode(response.body);
        final snackBar = SnackBar(
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(Icons.thumb_down),
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: Text(eData['message']),
              ),
            ],
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      setState(() {
        _isLoader = false;
      });

      final snackBar = SnackBar(
        content: Row(
          children: [
            Icon(Icons.thumb_down),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Text(
                'Somthing went wrong',
              ),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  getBid(bID) async {
    await _getBidDetails(bID);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getBidDetails(_bID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Result Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        child: Column(
          children: [
            Container(
              height: 40,
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(2.0, 0.0),
                  ),
                ],
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 16,
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Text(
                      'SN',
                    ),
                  ),
                  Container(
                    height: 16,
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Text(
                      'Type',
                    ),
                  ),
                  Container(
                    height: 16,
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.24,
                    child: Text(
                      'Name',
                    ),
                  ),
                  Container(
                    height: 16,
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Text(
                      'Number',
                    ),
                  ),
                  Container(
                    height: 16,
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Text(
                      'Amount',
                    ),
                  ),
                  Container(
                    height: 16,
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.11,
                    child: Text(
                      'Status',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        // padding: EdgeInsets.only(left: 16.0, right: 16.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.74,
                        child: ListView.builder(
                          padding:
                              EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                          itemCount: _games.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 16,
                                      alignment: Alignment.centerLeft,
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      child: Text(
                                        (index + 1).toString(),
                                        // textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Container(
                                      height: 16,
                                      alignment: Alignment.centerLeft,
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      child: Text(
                                        _games[index].type,
                                        // textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Container(
                                      height: 16,
                                      alignment: Alignment.centerLeft,
                                      width: MediaQuery.of(context).size.width *
                                          0.24,
                                      child: Text(
                                        _games[index].gameName,
                                        // textAlign: TextAlign.start,
                                      ),
                                    ),

                                    Container(
                                      height: 16,
                                      alignment: Alignment.centerLeft,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Text(
                                        _games[index].numbers,
                                        // textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Container(
                                      height: 16,
                                      alignment: Alignment.centerLeft,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Text(
                                        _games[index].amount,
                                        // textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Container(
                                      height: 16,
                                      alignment: Alignment.centerLeft,
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      child: _games[index].isWinner == 0
                                          ? Text(
                                              'Lost',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )
                                          : Text(
                                              'Won',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                    ),

                                    // Text(
                                    //   _games[index].type,
                                    //   textAlign: TextAlign.start,
                                    // ),
                                    // Text(
                                    //   _games[index].numbers,
                                    //   textAlign: TextAlign.start,
                                    // ),
                                    // Text(
                                    //   _games[index].amount,
                                    //   textAlign: TextAlign.start,
                                    // ),
                                    // _games[index].isWinner == 0
                                    //     ? Text(
                                    //       'Lost',
                                    //       style: TextStyle(
                                    //           color: Colors.red),
                                    //       textAlign: TextAlign.start,
                                    //     )
                                    //     : Text(
                                    //       'Won',
                                    //       style: TextStyle(
                                    //           color: Colors.green),
                                    //       textAlign: TextAlign.start,
                                    //     ),
                                  ],
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(2.0, 0.0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    Container(
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TabScreen(
                                        selectedIndex: 0,
                                      )),
                              (route) => false);
                        },
                        child: Text(
                          'Play More',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).accentColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
