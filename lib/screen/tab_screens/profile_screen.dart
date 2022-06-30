// @dart=2.9
import 'dart:convert';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:moneypot/models/wallet_amount.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/provider/data.dart';

import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/widget/rate_master.dart';

import 'package:moneypot/widget/wallet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String wAmount = '';
  final _amountCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();
  final _amountForm = GlobalKey<FormState>();
  String _mode;
  String _msg = '';
  bool _isBottomLoading = false;
  bool _isLoading = true;
  bool _isCancel = false;
  bool _err = false;
  Map<String, dynamic> _history;
  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      wAmount = prefs.getString('walletAmount');
    });
  }

  Future _playingHistory() async {
    final String url = 'api/playing_history';
    final data = jsonEncode(<String, dynamic>{});
    try {
      var response = await postData(url, data, true);

      if (response.statusCode == 200) {
        final phData = jsonDecode(response.body);
        ;
        setState(() {
          _history = phData;
          _isLoading = false;
        });
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        final phData = jsonDecode(response.body);
        ;
        setState(() {
          _msg = phData['message'];
          _err = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isBottomLoading = false;
      });
    }
  }

  Future _withdrawMoney() async {
    final String url = 'api/withdraw_money';
    final data = jsonEncode(<String, dynamic>{
      "amount": _amountCtrl.text,
      "remark": _remarkCtrl.text
    });
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        setState(() {
          _isBottomLoading = false;
        });
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        setState(() {
          _isBottomLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isBottomLoading = false;
      });
    }
  }

  Future<String> _requestMoney() async {
    final String url = 'api/request_money';
    final data = jsonEncode(<String, dynamic>{
      "amount": _amountCtrl.text,
      "remark": _remarkCtrl.text
    });
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        setState(() {
          _isBottomLoading = false;
        });

        return jsonEncode(<String, dynamic>{
          "loading": _isBottomLoading,
          "code": response.statusCode,
          "message": response.body
        });
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        setState(() {
          _isBottomLoading = false;
        });
        return jsonEncode(<String, dynamic>{
          "loading": _isBottomLoading,
          "code": response.statusCode,
          "message": response.body
        });
      }
    } catch (e) {
      setState(() {
        _isBottomLoading = false;
      });
      return jsonEncode(<String, dynamic>{
        "loading": _isBottomLoading,
        "code": e.statusCode,
        "message": e.body
      });
    }
  }

  Future _showDialog(mode) async {
    if (mode == null) {
      return;
    }
    mode == 'Request Money' ? _requestMoney() : _withdrawMoney();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            mode,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text('Request sent.....'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                _amountCtrl.clear();
                setState(() {
                  _mode = null;
                  _remarkCtrl.text = '';
                  _amountCtrl.text = '';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onDGModel(mode) {
    showModalBottomSheet(
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            height: 340,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 340,
                  child: Stack(
                    children: [
                      Form(
                        key: _amountForm,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                  height: 30.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      mode == 'request'
                                          ? 'Request Money'
                                          : 'Withdraw Money',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: TextField(
                                      controller: _amountCtrl,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      textDirection: ui.TextDirection.rtl,
                                      showCursor: true,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Amount',
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(10.0),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).accentColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_amountCtrl.text != null &&
                                          _amountCtrl.text.length > 0) {
                                        _amountCtrl.text = _amountCtrl.text
                                            .substring(
                                                0, _amountCtrl.text.length - 1);
                                      }
                                    },
                                    child: Icon(
                                      Icons.keyboard_backspace,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5.0,
                        top: 5.0,
                        child: InkResponse(
                          onTap: () {
                            setState(() {
                              _amountCtrl.text = '';
                              _isCancel = true;
                            });
                            Navigator.of(context).pop('');
                          },
                          child: CircleAvatar(
                            maxRadius: 10,
                            minRadius: 10,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 120.0),
                        child: Container(
                            height: 280,
                            // width: 50,
                            child: GridView.count(
                              crossAxisCount: 3,
                              padding: EdgeInsets.all(20.0),
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              childAspectRatio: 3,
                              children: NUMBER_LIST_2.map(
                                (number) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: number.setText
                                          ? Theme.of(context).accentColor
                                          : Theme.of(context).primaryColor,
                                      textStyle: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    child: number.setText
                                        ? Text(
                                            number.text,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          )
                                        : Text(
                                            number.number,
                                            style: TextStyle(
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    onPressed: () {
                                      if (number.number == '11') {
                                        setState(() {
                                          _amountCtrl.text = '';
                                          _isCancel = true;
                                        });
                                        Navigator.of(context).pop();
                                      } else if (number.number == '12') {
                                        final isValid =
                                            _amountForm.currentState.validate();

                                        if (!isValid) {
                                          return;
                                        }
                                        _amountForm.currentState.save();
                                        setState(() {
                                          _isBottomLoading = true;
                                          _isCancel = false;

                                          mode == 'request'
                                              ? _mode = 'Request Money'
                                              : _mode = 'Withdraw Money';
                                        });

                                        Navigator.pop(context);
                                      } else {
                                        _amountCtrl.text =
                                            _amountCtrl.text + number.number;
                                        if (_amountCtrl.text[0] == '0') {
                                          _amountCtrl.text = '';
                                        }
                                      }
                                    },
                                  );
                                },
                              ).toList(),
                            )),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }).whenComplete(() {
      if (!_isCancel) {
        if (_amountCtrl.text != '') {
          if (double.parse(_amountCtrl.text) > double.parse(wAmount) &&
              _mode == 'Withdraw Money') {
            _showErrorAmountCompair(_mode);
          } else {
            _showMsgDialog(_mode);
          }
        } else {
          _showErrorMag(_mode);
        }
      }
    });
  }

  Future _showErrorAmountCompair(mode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please enter amount which less than your wallet amount',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _onDGModel(mode == 'Withdraw Money' ? 'withdraw' : 'request');
              },
            ),
          ],
        );
      },
    );
  }

  Future _showErrorMag(mode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please Enter some amount',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _onDGModel(mode == 'Withdraw Money' ? 'withdraw' : 'request');
              },
            ),
          ],
        );
      },
    );
  }

  Future _showMsgDialog(mode) async {
    if (_mode == null) {
      return;
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter your remark',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          content: TextFormField(
            controller: _remarkCtrl,
            decoration: InputDecoration(
              labelText: 'Remark',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Submit',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showDialog(mode);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
    _playingHistory();
  }

  bool isRefreshingBalance = false;

  @override
  void dispose() {
    _remarkCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletAmount = Provider.of<WalletAmount>(context);
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Wallet.routeName);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        walletAmount.amount,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 5,),
                      Icon(Icons.account_balance_wallet,
                          color: Theme.of(context).primaryColor),
                    ],
                  ),
                ),
              ),
             isRefreshingBalance ?  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ):IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  setState(() {
                    isRefreshingBalance = true;
                  });
                  await getData();
                  setState(() {
                    isRefreshingBalance = false;
                  });
                  walletAmount.changeAmount(wAmount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Latest wallet balance has been updated..."),
                    ),
                  );

                  // Navigator.of(context).pushNamed(Wallet.routeName);
                },
              )
            ],
          ),
          Divider(),
          SizedBox(
            height: 16,
          ),
          Text(
            'Playing History ',
          ),
          SizedBox(
            height: 6,
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                )
              : _err
                  ? Center(
                      child: Text(
                        _msg,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).accentColor,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.28,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    right: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    bottom: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  )),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      FaIcon(FontAwesomeIcons.gamepad,
                                          size: 20, color: Colors.grey[500]),
                                      Text(
                                        _history['total_game'],
                                        style: TextStyle(
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Total Game',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  )),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      FaIcon(FontAwesomeIcons.trophy,
                                          size: 20, color: Colors.grey[500]),
                                      Text(
                                        _history['total_win'],
                                        style: TextStyle(
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Total Win',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    right: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  )),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      FaIcon(FontAwesomeIcons.moneyBillWaveAlt,
                                          size: 20, color: Colors.grey[500]),
                                      Text(
                                        _history['total_amount'].toString(),
                                        style: TextStyle(
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Winnig Amount',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    children: [
                                     const SizedBox(
                                        height: 10,
                                      ),
                                      FaIcon(
                                        FontAwesomeIcons.plusCircle,
                                        size: 28,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'More',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _onDGModel('request');
                    },
                    child: Text(
                      'Request',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _onDGModel('withdraw');
                    },
                    child: Text(
                      'Withdraw',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>RateMaster()));
                    },
                    child: Text(
                      'Rate Master',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
