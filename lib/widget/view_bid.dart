// @dart=2.9
import 'dart:convert';
import 'dart:ui';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:moneypot/models/game.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:intl/intl.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class ViewBid extends StatefulWidget {
  static const routeName = '/view-deails';
  final int bidID;
  final String type;

  ViewBid({
    Key key,
    this.bidID,
    this.type,
  }) : super(key: key);
  @override
  _ViewBidState createState() => _ViewBidState(bidID, type);
}

class _ViewBidState extends State<ViewBid> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  //  int bidID;
  int _bID;
  String _type;
  double _totalAmount = 0;
  bool _isLoader = true;
  String _sTime, _eTime, _dAndT;
  _ViewBidState(this._bID, this._type);

  List _games = [];
  List<int> _barData = [];

  Future _getBidDetails(bID) async {
    // print(_bID);
    // print(_type);
    final String url =
        _type == 'fiveMinGame' ? 'api/get_bid_data' : 'api/pana_game_bid_data';
    final data = jsonEncode(<String, dynamic>{'bid_id': _bID});

    try {
      var response = await postData(url, data, true);
      setState(() {
        _isLoader = true;
      });
      // print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          _isLoader = false;
        });

        var data = jsonDecode(response.body);
        List rData = _type == 'fiveMinGame'
            ? data['daily_5_minute_game']
            : data['pana_game'];
        // List<dynamic> barCode=[];
        // barCode = data['barcode_id'];
        // print('data');
        // print(data);
        setState(() {
          _sTime = data['s_time'];
          _eTime = data['end_time'];

          for (int i = 0; i < data['barcode_id'].length; i++) {
            _barData.add(int.parse(data['barcode_id'][i]));
          }
        });
        // print('_barData');
        // print(_barData);

        for (int i = 0; i <= rData.length - 1; i++) {
          // print(rData[i]['game_name']);
          setState(() {
            _games.add(
              Game(
                  amount: rData[i]['bid_amount'].toString(),
                  numbers: rData[i]['bid_number'].toString(),
                  type: rData[i]['is_open'].toString(),
                  gameName: rData[i]['game_name']),
            );
            _totalAmount = _totalAmount + double.parse(rData[i]['bid_amount']);
            //       if(_type!='fiveMinGame'){
            //   _games.add({"game_name":rData[i]['game_name']});
            // }
          });
        }

        // print('_games');
        // print(_games);
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
      // print(e);
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

    setState(() {
      _devices = [];
    });
    // print(_bID);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getBidDetails(_bID);
    });

    printerManager.startScan(Duration(seconds: 4));
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  void initPrin() {
    _startScanDevices();
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
  }

  Future<Ticket> printData(PaperSize paper) async {
    // final Ticket ticket = Ticket(paper);
    // ticket.text('JANTA RAJ',
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ),
    //     linesAfter: 1);

    // ticket.text('User Name - Raja', styles: PosStyles(align: PosAlign.center));
    // ticket.row([
    //   PosColumn(text: 'Sr No', width: 1),
    //   PosColumn(text: '     ', width: 1),
    //   PosColumn(text: 'Number', width: 3),
    //   PosColumn(text: '       ', width: 1),
    //   PosColumn(text: 'Amount', width: 6),
    // ]);

    // print(_games);

    // for (int i = 0; i <= _games.length-1; i++) {
    //   print( _games[i].amount);
    //   ticket.row([
    //     PosColumn(text: ' ' + (i + 1).toString(), width: 1),
    //     PosColumn(text: '           ', width: 1),
    //     PosColumn(text: _games[i].amount, width: 3),
    //     PosColumn(text: '    X    ', width: 1),
    //     PosColumn(text: _games[i].numbers, width: 6),
    //   ]);
    // }
    // ticket.hr();
    // ticket.row([
    //   PosColumn(
    //       text: 'TOTAL',
    //       width: 4,
    //       styles: PosStyles(
    //         height: PosTextSize.size1,
    //         width: PosTextSize.size1,
    //       )),
    //   PosColumn(text: '                  ', width: 4),
    //   PosColumn(
    //       text: '509',
    //       width: 4,
    //       styles: PosStyles(
    //         align: PosAlign.right,
    //         height: PosTextSize.size1,
    //         width: PosTextSize.size1,
    //       )),
    // ]);
    // ticket.hr(ch: '=', linesAfter: 1);
    // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    // ticket.barcode(Barcode.upcA(barData), height: 30);
    // final now = DateTime.now();
    // final formatter = DateFormat('MM/dd/yyyy H:m');
    // final String timestamp = formatter.format(now);
    // ticket.text(timestamp, styles: PosStyles(align: PosAlign.center));

    // ticket.feed(2);
    // ticket.cut();
    // return ticket;
    final Ticket ticket = Ticket(paper);

    ticket.text('JANTA RAJ',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size2,
          bold: true,
        ));
    ticket.text('by Galaxy Exch.',
        styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1),
        linesAfter: 1);
    ticket.text(
      "Rate : 1 X 10 total ten digit",
      styles: PosStyles(
        align: PosAlign.center,
      ),
    );
    ticket.text(
      "Game Time : " + _sTime + " - " + _eTime,
      styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1),
    );

    ticket.hr();
    ticket.row([
      PosColumn(
        text: '|',
        width: 1,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
          text: 'Sr.', width: 1, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Number', width: 3, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Amount', width: 4, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();
    for (int i = 0; i <= _games.length - 1; i++) {
      ticket.row([
        PosColumn(
          text: '|',
          width: 1,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
            text: '' + (i + 1).toString(),
            width: 1,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: _games[i].numbers,
            width: 3,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: _games[i].amount,
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    ticket.hr();
    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
            bold: true,
          )),
      PosColumn(
          text: 'Rs.' + _totalAmount.toString(),
          width: 7,
          styles: PosStyles(
            align: PosAlign.center,
            bold: true,
          )),
    ]);
    ticket.hr(ch: '=', linesAfter: 1);
    // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    ticket.barcode(Barcode.upcA(_barData), height: 30);
    // ticket.barcode(Barcode.upcA(barData), height: 30);
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp, styles: PosStyles(align: PosAlign.center));

    ticket.cut();
    // _games.clear();
    return ticket;
  }

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);
    const PaperSize paper = PaperSize.mm58;
    final PosPrintResult res =
        await printerManager.printTicket(await printData(paper));

    if (res != null) {
      final snackBar = SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                res.msg,
                textAlign: TextAlign.center,
                // style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    // showToast(res.msg);
  }

  @override
  Widget build(BuildContext context) {
    final int _routeData = ModalRoute.of(context).settings.arguments as int;

    Map<String, dynamic> _routeData1 = {
      "index": {
        "d_5_m_id": 1727,
        "s_time": "11:50 am",
        "is_winner_set": 0,
        "end_time": "11:55 am",
        "win_no": null,
        "game_date": "2020-12-05",
        "inserted_date": "2020-12-04 06:47:15"
      },
      "type": "dailyGame"
    };

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Bet Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoader
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height * 0.95,
              child: Column(
                children: [
                  Container(
                    height: 40,
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Sr. No',
                          textAlign: TextAlign.center,
                        ),
                        if (_type != 'fiveMinGame')
                          const Text(
                            'Game Name',
                            textAlign: TextAlign.center,
                          ),
                        // : const SizedBox(),
                        if (_type != 'fiveMinGame')
                          const Text(
                            'Type',
                            textAlign: TextAlign.center,
                          ),
                        // : const SizedBox(),
                        const Text(
                          'Number',
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          'Amount',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.74,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 8),
                                itemCount: _games.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    height: 48,
                                    margin: EdgeInsets.all(2),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30.0, right: 30.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: _type != "fiveMinGame"
                                                    ? 1
                                                    : 60,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  (index + 1).toString(),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              _type != 'fiveMinGame'
                                                  ? Expanded(
                                                      child: Text(
                                                        _games[index].gameName,
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              _type != 'fiveMinGame'
                                                  ? Expanded(
                                                      child: Text(
                                                        _games[index].type ==
                                                                '0'
                                                            ? 'O'
                                                            : _games[index]
                                                                        .type ==
                                                                    '1'
                                                                ? 'C'
                                                                : '',
                                                        textAlign: _type ==
                                                                "fiveMinGame"
                                                            ? TextAlign.start
                                                            : TextAlign.center,
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              Expanded(
                                                child: Text(
                                                  _games[index].numbers,
                                                  textAlign:
                                                      _type == "fiveMinGame"
                                                          ? TextAlign.start
                                                          : TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _games[index].amount,
                                                  textAlign:
                                                      _type == "fiveMinGame"
                                                          ? TextAlign.start
                                                          : TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
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
                            'Total Amount : $_totalAmount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SingleChildScrollView(
                                      child: Container(
                                        height: 200,
                                        child: _devices.length == 0
                                            ? Center(
                                                child: Text(
                                                    'Device Not found, Please on device/ pair device.'),
                                              )
                                            : ListView.builder(
                                                itemCount: _devices.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      _testPrint(
                                                          _devices[index]);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          height: 60,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            children: <Widget>[
                                                              Icon(Icons.print),
                                                              SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      _devices[index]
                                                                              .name ??
                                                                          '',
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Print',
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
