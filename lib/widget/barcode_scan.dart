// @dart=2.9
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moneypot/models/game.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/error_screens/result_not_set.dart';
import 'package:moneypot/screen/tab_screens/tab_screen.dart';

class BarcodeScan extends StatefulWidget {
  static const routeName = '/barcode-scan';
  final data;
  final List barcode;
  BarcodeScan(this.data, this.barcode);
  @override
  _BarcodeScanState createState() => _BarcodeScanState();
}

class _BarcodeScanState extends State<BarcodeScan> {
  List _games = [];
  String _winAmount = '0.00';
  bool _isResultDeclered;
  bool _win = false;

  _onWin(barcode, paid) async {
    final String url = 'api/barcode_data_is_paid';
    final data =
        jsonEncode(<String, dynamic>{"barcode_id": barcode, "is_paid": paid});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {}
    } catch (e) {
      final List error = [];
      return error;
    }
  }

  @override
  void initState() {
    super.initState();

    final List gameData = widget.data['data'];

    if (widget.data['is_result_set'] == 1) {
      _isResultDeclered = true;
    } else {
      _isResultDeclered = false;
    }

    for (int i = 0; i <= gameData.length - 1; i++) {
      setState(() {
        _games.add(
          Game(
              amount: gameData[i]['bid_amount'].toString(),
              numbers: gameData[i]['bid_number'].toString(),
              type: '',
              isWinner: gameData[i]['is_winner']),
        );
        if (!_win) {
          if (gameData[i]['win_amount'] != "0.00") {
            setState(() {
              _winAmount = gameData[i]['win_amount'];
              _win = true;
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bet Payment')),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        child: _isResultDeclered
            ? Column(
                children: [
                  Container(
                    height: 100,
                    child: _win
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Winning Amount',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor)),
                              Text(
                                _winAmount,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Text(
                                  'Lost',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                  ),
                  Container(
                    height: 40,
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sr. No',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Number',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Amount',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Winning Status',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.64,
                              padding: EdgeInsets.only(left: 16.0, right: 16.0),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _games.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    height: 48,
                                    margin: EdgeInsets.all(2),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              (index + 1).toString(),
                                              textAlign: TextAlign.start,
                                            ),
                                            Text(
                                              _games[index].numbers,
                                              textAlign: TextAlign.start,
                                            ),
                                            Text(
                                              _games[index].amount,
                                              textAlign: TextAlign.start,
                                            ),
                                            _games[index].isWinner == 0
                                                ? Text(
                                                    'Lost',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                    textAlign: TextAlign.start,
                                                  )
                                                : Text(
                                                    'Won',
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                    textAlign: TextAlign.start,
                                                  ),
                                          ],
                                        ),
                                        const Divider(),
                                      ],
                                    ),
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
                            'Winning Amount : $_winAmount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              // fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            child: ElevatedButton(
                              onPressed: () {
                                (_win && widget.data['is_paid'] == 0)
                                    ? _onWin(widget.barcode, 1)
                                    : (_win && widget.data['is_paid'] == 1)
                                        ? null
                                        : Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => TabScreen(
                                                      selectedIndex: 0,
                                                    )),
                                            (route) => false);
                              },
                              child: Text(
                                (_win && widget.data['is_paid'] == 0)
                                    ? 'Pay'
                                    : (_win && widget.data['is_paid'] == 1)
                                        ? 'Already Paid'
                                        : 'Play More',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ResultNotSet('Result Not Decleared Yet'),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Payment made successfully.',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
