// @dart=2.9
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:moneypot/models/transaction.dart';
import 'package:moneypot/models/wallet_amount.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/error_screens/data_not_found.dart';
import 'package:moneypot/screen/log_screens/login_screen.dart';
import 'package:moneypot/widget/transaction_details.dart';
import 'package:provider/provider.dart';
import '../provider/apiCall.dart';
import '../provider/data.dart';

class Wallet extends StatefulWidget {
  static const routeName = '/wallet';

  const Wallet({Key key}) : super(key: key);
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String amount = "";
  String exposurelimit = "";
  String _mode;
  bool _isLoading = true;
  bool _isBottomLoading = false;
  bool _showTransaction = false;
  bool _dataNotSet = false;
  bool _isCancel = false;

  List transactions = [];
  final _amountCtrl = TextEditingController();
  final _amountForm = GlobalKey<FormState>();
  final _remarkCtrl = TextEditingController();

  Future<void> _getWalletInfo() async {
    const String url = 'api/wallet_info';
    final data = jsonEncode(<String, dynamic>{});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        final wData = jsonDecode(response.body);
        Provider.of<WalletAmount>(context, listen: false)
            .changeAmount(wData['wallet_amount']);
        Provider.of<WalletAmount>(context, listen: false)
            .changeExposureLimit(wData['exploser_limit'].toString());
        setState(() {
          amount = wData['wallet_amount'];
          exposurelimit = wData['exploser_limit'].toString();
          transactions = wData['wallet_details'] == null
              ? []
              : wData['wallet_details'].reversed.toList();
          _isLoading = false;
          _showTransaction = true;
          _dataNotSet = false;
        });
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        setState(() {
          _isLoading = false;
          _showTransaction = false;
        });
        if (response.statusCode == 401) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
        }
      }
      // ignore: empty_catches
    } catch (e) {
      print(e);
      setState(() {});
    }
  }

  Future _withdrawMoney() async {
    const String url = 'api/withdraw_money';
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

  // ignore: missing_return
  Future<String> _requestMoney() async {
    const String url = 'api/request_money';
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
            decoration: const InputDecoration(
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

  Future _showDialog(mode) async {
    if (mode == null) {
      return;
    }
    mode == 'Request Money' ? _requestMoney() : _withdrawMoney();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            mode,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text('Request sent successfully'),
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            width: double.infinity,
            height: 340,
            child: Column(
              children: [
                SizedBox(
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
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: TextField(
                                      controller: _amountCtrl,
                                      style: const TextStyle(
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
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
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
                                          _amountCtrl.text.isNotEmpty) {
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
                            child: const Icon(
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
                        child: SizedBox(
                            height: 280,
                            child: GridView.count(
                              crossAxisCount: 3,
                              padding: const EdgeInsets.all(20.0),
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
                                            style: const TextStyle(
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
          if (double.parse(_amountCtrl.text) > double.parse(amount) &&
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

  @override
  void dispose() {
    _remarkCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getWalletInfo();
    _remarkCtrl.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            bottom: PreferredSize(
              child: SizedBox(
                height: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16.0,
                          ),
                        ),
                        amount == "" || exposurelimit == ""
                            ? const SizedBox()
                            : Text(
                                'Rs.' +
                                    (double.tryParse(amount) +
                                            double.tryParse(exposurelimit))
                                        .toString(),
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 16.0,
                              ),
                            ),
                            Text(
                              'Rs.' + amount,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exploser Balance',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 16.0,
                              ),
                            ),
                            Text(
                              'Rs.' + exposurelimit,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.13),
            ),
          ),
          body: (_isLoading && !_dataNotSet)
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                )
              : (_showTransaction && !_dataNotSet)
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 45.0,
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction History',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: RefreshIndicator(
                                color: Theme.of(context).primaryColor,
                                onRefresh: () async {
                                  transactions.clear();
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _getWalletInfo();
                                },
                                child: ListView.separated(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: transactions[index]['is_bet']
                                          ? () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TransactionDetails(
                                                            transactionData:
                                                                transactions[
                                                                    index],
                                                          )));
                                            }
                                          : null,
                                      child: Container(
                                        height: 38.0,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  transactions[index][
                                                          'transaction_name'] ??
                                                      'Unknown',
                                                  style: const TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Row(
                                                  children: [
                                                    transactions[index][
                                                                'transaction_type'] ==
                                                            "0"
                                                        ? const Text(
                                                            '+ ',
                                                            style: TextStyle(
                                                                fontSize: 16.0,
                                                                color: Colors
                                                                    .green),
                                                          )
                                                        : const Text(
                                                            '- ',
                                                            style: TextStyle(
                                                                fontSize: 16.0,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                    Text(
                                                      transactions[index]
                                                          ['amount'],
                                                      style: TextStyle(
                                                          color: transactions[
                                                                          index]
                                                                      [
                                                                      'transaction_type'] ==
                                                                  "0"
                                                              ? Colors.green
                                                              : Colors.red),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    transactions[index]
                                                        ['date_time'],
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                transactions[index]['is_bet']
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            "Read more",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[850],
                                                              fontSize: 12.0,
                                                            ),
                                                          ),
                                                          const Icon(
                                                            Icons
                                                                .chevron_right_outlined,
                                                            size: 14,
                                                          )
                                                        ],
                                                      )
                                                    : const SizedBox()
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(),
                                  itemCount: transactions.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: DataNotFound('Transacion not found'),
                    ),
        ),
        Positioned(
          top : MediaQuery.of(context).size.height * 0.18 + MediaQuery.of(context).padding.top ,
          // height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ButtonTheme(
                height: 45.0,
                minWidth: 120.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).accentColor,
                    elevation: 15,
                  ),
                  child: Text(
                    'Deposit Money',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onPressed: () {
                    _onDGModel('request');
                  },
                ),
              ),
              ButtonTheme(
                height: 45.0,
                minWidth: 120.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).accentColor,
                    elevation: 15,
                  ),
                  child: Text(
                    'Withdraw',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onPressed: () {
                    _onDGModel('withdraw');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
