// @dart=2.9
import 'dart:convert';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import "package:audioplayers/audioplayers.dart";
import 'dart:ui' as ui;
import 'package:moneypot/models/wallet_amount.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/error_screens/result_not_set.dart';
import 'package:moneypot/screen/error_screens/sys_date_time_change.dart';
import 'package:moneypot/screen/error_screens/time_date_check.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneypot/models/five_min_game_result.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/provider/data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import 'play_number.dart';
import 'bid_details.dart';
import 'wallet.dart';

class OneDayBids extends StatefulWidget {
  static const routeName = '/daily-bids';
  final Map<String, dynamic> routeData;
  OneDayBids({Key key, this.routeData}) : super(key: key);
  @override
  _OneDayBidsState createState() => _OneDayBidsState();
}

class _OneDayBidsState extends State<OneDayBids>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  List<Game> _games = [];
  String _number = '';
  String _type = '';
  String _patti_type = '';
  bool _isEmpty = false;
  bool _isEdit = false;
  bool _isAddEnabled = true;
  bool _isUpdateAmount = false;
  int _currentIndex;
  int _game_id;
  String _totalAmount = '0';
  String _game_time = '';
  String _wAmount = '0';
  bool _isUpdate = false;
  bool flagPlace = true;
  List<FiveMinGameResult> _fiveMinGameResult = [];
  TextEditingController amountCtrl = TextEditingController();
  int _hour12;

  int _min;
  int _sec;
  List _cpData = [];
  Map<String, dynamic> _gameData;
  Map<String, dynamic> _result;
  String _walletAmount = '0';
  // bool _showSlotMachine = false;
  bool _showResult = false;
  bool _placeBitButton = true;
  bool _isPlaying = false;
  bool _isPlaying1 = false;
  bool _numberNotSet = false;
  int _finalSec;

  bool isOpenEnd = false;
  bool isCloseEnd = false;
  // AnimationController _animationController;
  // Animation<double> _animation;
  List<int> _barData = [];
  List<String> _kaichiJodiData = [];
  Timer timer1, timer2;
  AudioCache cache = AudioCache();
  AudioPlayer player, player1;

  AnimationController _resizableController;
  AnimationController _amountController;

  AnimatedBuilder getContainer(type) {
    return new AnimatedBuilder(
        animation: _resizableController,
        builder: (context, child) {
          return Container(
            height: 30,
            width: 140,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(1)),
              border: Border.all(
                  color: Theme.of(context).accentColor,
                  width: _resizableController.value * 3),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: Text(
                'Choose Number',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                _onChooseNumber(context);
              },
            ),
          );
        });
  }

  AnimatedBuilder getAmountContainer() {
    return new AnimatedBuilder(
        animation: _amountController,
        builder: (context, child) {
          return Container(
            height: 30,
            width: 140,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(1)),
              border: Border.all(
                  color: Theme.of(context).accentColor,
                  width: _amountController.value * 3),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: Text(
                amountCtrl.text == '' ? 'Enter Amount' : amountCtrl.text,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                _onDGModel();
              },
            ),
          );
        });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // _startOrStop() {
  //   if (_animationController.isAnimating) {
  //     _animationController.stop();
  //   } else {
  //     _animationController.reset();
  //     _animationController.forward();
  //   }
  // }

  Future<void> _getWalletInfo() async {
    final String url = 'api/wallet_info';
    final data = jsonEncode(<String, dynamic>{});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        final wData = jsonDecode(response.body);
        setState(() {
          _wAmount = wData['wallet_amount'];
        });
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        final wData = jsonDecode(response.body);
        setState(() {});
      }
    } catch (e) {}
  }

  _getOpenResult() async {
    final String url = 'api/';
    final data = jsonEncode(<String, dynamic>{});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        final grData = jsonDecode(response.body);

        List rData = grData['data'];

        setState(() {});
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        setState(() {});
      }
    } catch (e) {}
  }

  _getCloseResult() async {
    final String url = 'api/';
    final data = jsonEncode(<String, dynamic>{});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        final grData = jsonDecode(response.body);

        List rData = grData['data'];

        setState(() {});
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        setState(() {});
      }
    } catch (e) {}
  }

  changeData() {
    setState(() {
      _number = '';
      amountCtrl.clear();
      _isAddEnabled = true;
      _isUpdate = false;
      _totalAmount = '0';
      _games = [];
      _games.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getTimeZone();
    _gameData = widget.routeData;
    // _showSlotMachine = false;
    // _animationController = new AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 150),
    // );
    // _animation = Tween(begin: 1.0, end: 30.0).animate(
    //     CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _resizableController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    _resizableController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _resizableController.reverse();
          break;
        case AnimationStatus.dismissed:
          _resizableController.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _resizableController.forward();

    _amountController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    _amountController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _amountController.reverse();
          break;
        case AnimationStatus.dismissed:
          _amountController.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _amountController.forward();

    printerManager.startScan(Duration(seconds: 4));
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
  }

  _getTimeZone() async {
    bool checkFlag = await SysDateTimeChange().checkDateAndTime(context);

    if (checkFlag) {
      Navigator.pushNamed(context, TimeDateCheck.routeName);
    } else {
      _getWalletInfo();
      setState(() {
        _devices = [];
      });

      _getTime();
    }
  }

  _getTime() {
    DateTime mt = DateTime.now();
    String _currentTime = DateFormat('jm').format(mt);
    _min = mt.minute;
    _sec = mt.second;

    var hour = mt.hour;
    var currentAMorPM = (_currentTime).split(' ')[1];
    var startAMorPM = (_gameData['index']['s_time']).split(' ')[1];
    var endAMorPM = (_gameData['index']['end_time']).split(' ')[1];

    var sStopHr, sStopMin, eStopHr, eStopMin;

    if (hour == 12) {
      _hour12 = 12;
    } else if (hour > 12) {
      _hour12 = hour - 12;
    } else {
      _hour12 = hour;
    }

    List _gST = [];
    _gST = _gameData['index']['s_time'].split(' ');
    _gST = _gST[0].split(':');

    List _gET = [];
    _gET = _gameData['index']['end_time'].split(' ');
    _gET = _gET[0].split(':');

    List _cT = [];
    _cT = _currentTime.split(' ');
    _cT = _cT[0].split(':');

    // print(mt);
    // print(hour);
    // print(_hour12);
    // print(currentAMorPM);
    // print(startAMorPM);
    // print(endAMorPM);
    // print(_gST);
    // print(_gET);
    // print(_hour12);
    // print(_min);

//     if (startAMorPM == currentAMorPM) {
//       if(int.parse(_gST[0]) == _hour12){
//             if(int.parse(_gST[1])==00){
//                 sStopHr=int.parse(_gST[0])-1;
//                 sStopMin=40;
//             }else if((int.parse(_gST[1])>00) && (int.parse(_gST[1])<20)){
//               sStopHr=int.parse(_gST[0])-1;
//               sStopMin=40+int.parse(_gST[1]);
//             }else{
//               sStopHr=int.parse(_gST[0]);
//               sStopMin=int.parse(_gST[1])-20;
//             }
//       }else if(int.parse(_gST[0]) > _hour12){
//             if(int.parse(_gST[1])==00){
//                 sStopHr=int.parse(_gST[0])-_hour12;
//                 sStopMin=40;
//             }else if((int.parse(_gST[1])>00) && (int.parse(_gST[1])<20)){
//               sStopHr=int.parse(_gST[0])-_hour12;
//               sStopMin=40+int.parse(_gST[1]);
//             }else{
//               sStopHr=int.parse(_gST[0]);
//               sStopMin=int.parse(_gST[1])-20;
//             }
//       }else{
// setState(() {
//             isOpenEnd = true;
//           });
//       }
//       print(isOpenEnd);

//       if(sStopHr!=_hour12 && sStopMin!=_min){
//         setState(() {
//             isOpenEnd = true;
//           });
//       }

//       print('--------------');
//       print(sStopHr);
//       print(sStopMin);
//       print('--------------');
//     }

//     if (endAMorPM == currentAMorPM) {
//       if(int.parse(_gET[0]) == _hour12){
//             if(int.parse(_gET[1])==00){
//                 eStopHr=int.parse(_gET[0])-1;
//                 eStopMin=40;
//             }else if((int.parse(_gET[1])>00) && (int.parse(_gET[1])<20)){
//               eStopHr=int.parse(_gET[0])-1;
//               eStopMin=40+int.parse(_gET[1]);
//             }else{
//               eStopHr=int.parse(_gET[0]);
//               eStopMin=int.parse(_gET[1])-20;
//             }
//       }else if(int.parse(_gET[0]) > _hour12){
//             if(int.parse(_gET[1])==00){
//                 eStopHr=int.parse(_gET[0])-_hour12;
//                 eStopMin=40;
//             }else if((int.parse(_gET[1])>00) && (int.parse(_gET[1])<20)){
//               eStopHr=int.parse(_gET[0])-_hour12;
//               eStopMin=40+int.parse(_gET[1]);
//             }else{
//               eStopHr=int.parse(_gET[0]);
//               eStopMin=int.parse(_gET[1])-20;
//             }
//       }else{
// setState(() {
//             isCloseEnd = true;
//           });
//       }
//       print(isCloseEnd);

//       if(eStopHr!=_hour12 && eStopMin!=_min){
//         setState(() {
//             isCloseEnd = true;
//           });
//       }

//       print('--------------');
//       print(eStopHr);
//       print(eStopMin);
//       print('--------------');
//     }

    if (startAMorPM == currentAMorPM) {
      if (int.parse(_gST[0]) == _hour12) {
        int min = int.parse(_gST[1]) - 20;
        if (min > _cT[1]) {
          final sec = min * 60;
          openTimeEnd(sec);
        } else {
          setState(() {
            isOpenEnd = true;
          });
        }
      } else if (int.parse(_gST[0]) > _hour12) {
        int hr = 0, min = 0, sec = 0;
        if (int.parse(_gST[1]) == 00 || int.parse(_gST[1]) == 0) {
          hr = int.parse(_gST[0]) - 1;
          min = hr * 60 + 40;
          sec = min * 60;
          openTimeEnd(sec);
        } else if (int.parse(_gST[1]) >= 01 && int.parse(_gST[1]) <= 19) {
          hr = int.parse(_gST[0]) - 1;
          min = hr * 60 + 40 + int.parse(_gST[1]);
          sec = min * 60;
          openTimeEnd(sec);
        } else {
          hr = int.parse(_gST[0]) - int.parse(_cT[0]);
          min = hr * 60 + int.parse(_cT[1]) + (int.parse(_gST[1]) - 20);
          sec = min * 60;
          openTimeEnd(sec);
        }
      } else {
        setState(() {
          isOpenEnd = true;
        });
      }
    } else {
      setState(() {
        // isOpenEnd = true;
      });
    }

    if (endAMorPM == currentAMorPM) {
      if (endAMorPM == 'PM' && int.parse(_gET[0]) != _hour12) {
        //  _gET[0]=(int.parse(_gET[0])+12).toString();
      }
      if (int.parse(_gET[0]) == _hour12) {
        int min = int.parse(_gET[1]) - 20;
        if (min > int.parse(_cT[1])) {
          final sec = min * 60;
          closeTimeEnd(sec);
        } else {
          setState(() {
            isCloseEnd = true;
          });
          // print(' 1');
          // print(isCloseEnd);
        }
      } else if (int.parse(_gET[0]) > _hour12) {
        int hr = 0, min = 0, sec = 0;
        if (int.parse(_gET[1]) == 00 || int.parse(_gET[1]) == 0) {
          hr = int.parse(_gET[0]) - 1;
          min = hr * 60 + 40;
          sec = min * 60;
          // print('isCloseEnd--1');
          // print(sec);
          closeTimeEnd(sec);
        } else if (int.parse(_gET[1]) >= 01 && int.parse(_gET[1]) <= 19) {
          hr = int.parse(_gET[0]) - 1;
          min = hr * 60 + 40 + int.parse(_gET[1]);
          sec = min * 60;
          // print('isCloseEnd--2');
          closeTimeEnd(sec);
        } else {
          hr = int.parse(_gET[0]) - int.parse(_cT[0]);
          min = hr * 60 + int.parse(_cT[1]) + (int.parse(_gET[1]) - 20);
          sec = min * 60;
          // print('isCloseEnd--3');
          closeTimeEnd(sec);
        }
      } else {
        setState(() {
          // isCloseEnd = true;
        });
        // print('_hour12');
        // print(_hour12);
        // print(_gET[0]);
      }
    }
    // print('isCloseEnd');
    // print(isCloseEnd);
  }

  openTimeEnd(sec) {
    timer1 = Timer(Duration(seconds: sec), () async {
      setState(() {
        isOpenEnd = true;
      });
    });
  }

  closeTimeEnd(sec) {
    timer2 = Timer(Duration(seconds: sec), () async {
      setState(() {
        isCloseEnd = true;
      });
    });
  }

  showResult(sec) {
    timer2 = Timer(Duration(seconds: sec), () async {
      // if (_showSlotMachine) {
      _recursiveCall();
      // }
    });
  }

  _recursiveCall() async {
    final String url = 'api/get_one_game_result';
    final data = jsonEncode(
        <String, dynamic>{'d_5_m_id': _gameData['index']['d_5_m_id']});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['result'] == null) {
          _recursiveCall();
        } else {
          setState(() {
            _isPlaying1 = true;
            _result = result;
            // _showSlotMachine = false;
            // _startOrStop();
            _showResult = true;
          });
          // player.clearCache();
          if (_isPlaying) {
            player.stop();
          }

          player1 = await cache.play('SF-1.mp3');
        }
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        if (_isPlaying) {
          player.stop();
        }

        if (_isPlaying1) {
          player1.stop();
        }

        // setState(() {});
      }
    } catch (e) {
      // print(e);
    }
  }

  void _startScanDevices() {
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  Future<Ticket> printData(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);

    ticket.text(_gameData['index']['componie_name'],
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size2,
          bold: true,
        ));
    // ticket.text('by Galaxy Exch.',
    //     styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1),
    //     linesAfter: 1);
    // ticket.text(
    //   "Rate : 1 X 10 total ten digit",
    //   styles: PosStyles(
    //     align: PosAlign.center,
    //   ),
    // );
    ticket.text(
      "Game Time : " +
          _gameData['index']['s_time'] +
          " - " +
          _gameData['index']['end_time'],
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
          text: 'Game', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Number', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Amount', width: 2, styles: PosStyles(align: PosAlign.right)),
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
            text: _games[i].gameName,
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: _games[i].numbers,
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '|', width: 1, styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: _games[i].amount,
            width: 2,
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
          text: 'Rs.' + _totalAmount,
          width: 7,
          styles: PosStyles(
            align: PosAlign.center,
            bold: true,
          )),
    ]);
    ticket.hr(ch: '=', linesAfter: 1);
    // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];

    ticket.barcode(Barcode.upcA(_barData), height: 30);
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp, styles: PosStyles(align: PosAlign.center));

    ticket.cut();
    _games.clear();
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
              ),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _placeBid(bidData, BuildContext context) async {
    Navigator.of(context).pop();
    final String url = 'api/pana_game_set_bid';
    final data = jsonEncode(bidData);
    setState(() {
      flagPlace = false;
    });

    var response = await postData(url, data, true);

    if (response.statusCode == 200) {
      final rData = jsonDecode(response.body);
      bidData = rData['barcode_id'];
      final List bCode = bidData;
      setState(() {
        flagPlace = true;
        _placeBitButton = true;
      });
      setState(() {
        for (int i = 0; i < bCode.length; i++) {
          _barData.add(bCode[i]);
        }
      });
      _getWalletAmount();
      _printDialog();
    } else if (response.statusCode == 408) {
      setState(() {
        flagPlace = true;
        _placeBitButton = true;
      });
      AutoLogOut().popUpFor408(context);
    } else {
      setState(() {
        flagPlace = true;
        _placeBitButton = true;
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
  }

  bool _isRefresh = false;
  _getWalletAmount() async {
    final String url = 'api/get_user_wallet_amount';
    final data = jsonEncode({});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await postData(url, data, true);

      if (response.statusCode == 200) {
        final wData = jsonDecode(response.body);
        setState(() {
          _walletAmount = wData['wallet_amount'];
        });
        await prefs.setString('walletAmount', wData['wallet_amount']);
        setState(() {
          _isRefresh = false;
        });
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        final eData = jsonDecode(response.body);
      }
    } catch (e) {
      // print(e);
    }
  }

  void _addGame() {
    bool flag = true;
    // print('Add Game');
    // print(_type);
    // print(_number);
    if (_isUpdate) {
      _updateGame(_currentIndex);
    } else {
      int amt;
      if (_games.length == 0 &&
          (_number != '' || _number.isEmpty) &&
          amountCtrl.text != '') {
        //               List cpData=[];
//               for(int i=0;i<CP_PATTI.length;i++){
//                 if(CP_PATTI[i].number==_number){
//                   cpData=CP_PATTI[i].patti;
//                 }
//               }
// for(int i=0;i<cpData.length;i++){
//   _games.insert(
//           0,
//           Game(
//             amount: amountCtrl.text,
//             numbers: cpData[i],
//             type: _type,
//           ),
//         );

        if (_type == 'CP') {
          List cps = [];
          for (int i = 0; i < _cpData.length; i++) {
            for (int j = 0; j < CP_PATTI.length; j++) {
              if (_cpData[i] == CP_PATTI[j].number) {
                setState(() {
                  for (int k = 0; k < CP_PATTI[j].patti.length; k++) {
                    cps.add({'cp': CP_PATTI[j].patti[k], 'number': _cpData[i]});
                  }
                });
              }
            }
          }

          for (int i = 0; i < cps.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cps[i]['cp'],
                  type: _patti_type + '-' + cps[i]['number'],
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }

// amt=int.parse(amountCtrl.text)*10;
// }else{
//   amt=int.parse(amountCtrl.text);
        } else if (_type == 'Touch Panna') {
          List cpData = [];

          for (int i = 0; i < TOUCH_PANNA.length; i++) {
            if (TOUCH_PANNA[i].number == _patti_type) {
              cpData = _number == '1'
                  ? TOUCH_PANNA[i].one
                  : _number == '2'
                      ? TOUCH_PANNA[i].two
                      : _number == '3'
                          ? TOUCH_PANNA[i].three
                          : _number == '4'
                              ? TOUCH_PANNA[i].four
                              : _number == '5'
                                  ? TOUCH_PANNA[i].five
                                  : _number == '6'
                                      ? TOUCH_PANNA[i].six
                                      : _number == '7'
                                          ? TOUCH_PANNA[i].seven
                                          : _number == '8'
                                              ? TOUCH_PANNA[i].eight
                                              : _number == '9'
                                                  ? TOUCH_PANNA[i].nine
                                                  : _number == '0'
                                                      ? TOUCH_PANNA[i].zero
                                                      : '';
            }
          }
          for (int i = 0; i < cpData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cpData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Family Panna') {
          List cpData = [];
          for (int i = 0; i < FAMALY_PANA.length; i++) {
            if (FAMALY_PANA[i].id == _patti_type) {
              cpData = FAMALY_PANA[i].data;
            }
          }
          for (int i = 0; i < cpData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cpData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Charts') {
          List cpData = [];
          for (int i = 0; i < CHARTS.length; i++) {
            if (CHARTS[i].name == _patti_type) {
              cpData = _number == '1'
                  ? CHARTS[i].one
                  : _number == '2'
                      ? CHARTS[i].two
                      : _number == '3'
                          ? CHARTS[i].three
                          : _number == '4'
                              ? CHARTS[i].four
                              : _number == '5'
                                  ? CHARTS[i].five
                                  : _number == '6'
                                      ? CHARTS[i].six
                                      : _number == '7'
                                          ? CHARTS[i].seven
                                          : _number == '8'
                                              ? CHARTS[i].eight
                                              : _number == '9'
                                                  ? CHARTS[i].nine
                                                  : _number == '0'
                                                      ? CHARTS[i].zero
                                                      : '';
            }
          }
          for (int i = 0; i < cpData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cpData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'ARB Cut Panna') {
          for (int i = 0; i < ABR_CUT_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: ABR_CUT_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Running Panna') {
          for (int i = 0; i < RUNNING_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: RUNNING_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki Beki Running Panna') {
          for (int i = 0; i < AKI_BEKI_RUNING_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: AKI_BEKI_RUNING_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki Running Panna') {
          for (int i = 0; i < AKI_RUNING_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: AKI_RUNING_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Beki Running Panna') {
          for (int i = 0; i < BEKI_RUNING_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: BEKI_RUNING_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki Beki Panna') {
          for (int i = 0; i < AKI_BEKI_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: AKI_BEKI_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki Panna') {
          for (int i = 0; i < AKI_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: AKI_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Beki Panna') {
          for (int i = 0; i < BEKI_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: BEKI_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Ank Start Panna') {
          List cpData = [];
          for (int i = 0; i < ANK_START_PANNA.length; i++) {
            if (ANK_START_PANNA[i].number == _number) {
              cpData = _patti_type == 'sp'
                  ? ANK_START_PANNA[i].sp
                  : ANK_START_PANNA[i].dp;
            }
          }
          for (int i = 0; i < cpData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cpData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == ' Kaichi Jodi/Running Jodi') {
          for (int i = 0; i < _kaichiJodiData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _kaichiJodiData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'SP') {
          if (_number.length == 1) {
            for (int i = 0; i < NUMBER_LIST.length; i++) {
              List cpData = [];

              if (NUMBER_LIST[i].number == _number) {
                cpData = NUMBER_LIST[i].sp;
              }

              for (int i = 0; i < cpData.length; i++) {
                _games.insert(
                  0,
                  Game(
                      amount: amountCtrl.text,
                      numbers: cpData[i],
                      type: _patti_type,
                      gameName: _game_time,
                      gameId: _game_id),
                );
              }
            }
          } else {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _number,
                  type: _type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'DP') {
          if (_number.length == 1) {
            for (int i = 0; i < NUMBER_LIST.length; i++) {
              List cpData = [];

              if (NUMBER_LIST[i].number == _number) {
                cpData = NUMBER_LIST[i].dp;
              }

              for (int i = 0; i < cpData.length; i++) {
                _games.insert(
                  0,
                  Game(
                      amount: amountCtrl.text,
                      numbers: cpData[i],
                      type: _patti_type,
                      gameName: _game_time,
                      gameId: _game_id),
                );
              }
            }
          } else {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _number,
                  type: _type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'TP') {
          if (_number == 'All') {
            for (int i = 0; i < ALL_TP.length; i++) {
              _games.insert(
                0,
                Game(
                    amount: amountCtrl.text,
                    numbers: ALL_TP[i],
                    type: _patti_type,
                    gameName: _game_time,
                    gameId: _game_id),
              );
            }
          } else if (_type == 'Aki') {
            if (_number == 'All') {
              for (int i = 0; i < AKI.length; i++) {
                // print(AKI[i]);
                _games.insert(
                  0,
                  Game(
                      amount: amountCtrl.text,
                      numbers: AKI[i],
                      type: _type,
                      gameName: _game_time,
                      gameId: _game_id),
                );
              }
            }
          } else if (_type == 'Beki') {
            if (_number == 'All') {
              for (int i = 0; i < BEKI.length; i++) {
                _games.insert(
                  0,
                  Game(
                      amount: amountCtrl.text,
                      numbers: BEKI[i],
                      type: _patti_type,
                      gameName: _game_time,
                      gameId: _game_id),
                );
              }
            }
          } else {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _number,
                  type: _type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki') {
          if (_number == 'All') {
            for (int i = 0; i < AKI.length; i++) {
              setState(() {
                _games.insert(
                  0,
                  Game(
                      amount: amountCtrl.text,
                      numbers: AKI[i],
                      type: _type,
                      gameName: _game_time,
                      gameId: _game_id),
                );
              });
            }
          }
        } else if (_type == 'Beki') {
          if (_number == 'All') {
            for (int i = 0; i < BEKI.length; i++) {
              _games.insert(
                0,
                Game(
                    amount: amountCtrl.text,
                    numbers: BEKI[i],
                    type: _patti_type,
                    gameName: _game_time,
                    gameId: _game_id),
              );
            }
          }
        } else if (_type == 'open' || _type == 'Open') {
          _games.insert(
            0,
            Game(
                amount: amountCtrl.text,
                numbers: _number,
                type: _type,
                gameName: _game_time,
                gameId: _game_id),
          );
        } else if (_type == 'close' || _type == 'Close') {
          _games.insert(
            0,
            Game(
                amount: amountCtrl.text,
                numbers: _number,
                type: _type,
                gameName: _game_time,
                gameId: _game_id),
          );
        } else {
          _games.insert(
            0,
            Game(
                amount: amountCtrl.text,
                numbers: _number,
                type: _type,
                gameName: _game_time,
                gameId: _game_id),
          );
        }
      } else {
        // for (int i = 0; i <= _games.length - 1; i++) {
        //   if(_type=='open'){
        //   if (_games[i].numbers == _number) {
        //     _games[i].amount =
        //         (int.parse(_games[i].amount) + int.parse(amountCtrl.text))
        //             .toString();
        //     setState(() {
        //       flag = false;
        //     });
        //   }

        //   }else if(_type=='close'){
        //     if (_games[i].numbers == _number) {
        //     _games[i].amount =
        //         (int.parse(_games[i].amount) + int.parse(amountCtrl.text))
        //             .toString();
        //     setState(() {
        //       flag = false;
        //     });
        //   }
        //   }
        // }

        // if (flag) {

        if (_type == 'CP') {
          List cps = [];
          for (int i = 0; i < _cpData.length; i++) {
            for (int j = 0; j < CP_PATTI.length; j++) {
              if (_cpData[i] == CP_PATTI[j].number) {
                setState(() {
                  for (int k = 0; k < CP_PATTI[j].patti.length; k++) {
                    cps.add({'cp': CP_PATTI[j].patti[k], 'number': _cpData[i]});
                  }
                });
              }
            }
          }

          for (int i = 0; i < cps.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cps[i]['cp'],
                  type: _patti_type + '-' + cps[i]['number'],
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }

// amt=int.parse(amountCtrl.text)*10;
// }else{
//   amt=int.parse(amountCtrl.text);
        } else if (_type == 'Touch Panna') {
          List cpData = [];

          for (int i = 0; i < TOUCH_PANNA.length; i++) {
            if (TOUCH_PANNA[i].number == _patti_type) {
              cpData = _number == '1'
                  ? TOUCH_PANNA[i].one
                  : _number == '2'
                      ? TOUCH_PANNA[i].two
                      : _number == '3'
                          ? TOUCH_PANNA[i].three
                          : _number == '4'
                              ? TOUCH_PANNA[i].four
                              : _number == '5'
                                  ? TOUCH_PANNA[i].five
                                  : _number == '6'
                                      ? TOUCH_PANNA[i].six
                                      : _number == '7'
                                          ? TOUCH_PANNA[i].seven
                                          : _number == '8'
                                              ? TOUCH_PANNA[i].eight
                                              : _number == '9'
                                                  ? TOUCH_PANNA[i].nine
                                                  : _number == '0'
                                                      ? TOUCH_PANNA[i].zero
                                                      : '';
            }
          }
          for (int i = 0; i < cpData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cpData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Family Panna') {
          List cpData = [];
          for (int i = 0; i < FAMALY_PANA.length; i++) {
            if (FAMALY_PANA[i].id == _patti_type) {
              cpData = FAMALY_PANA[i].data;
            }
          }
          for (int i = 0; i < cpData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cpData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Charts') {
          List cpData = [];
          for (int i = 0; i < CHARTS.length; i++) {
            if (CHARTS[i].name == _patti_type) {
              cpData = _number == '1'
                  ? CHARTS[i].one
                  : _number == '2'
                      ? CHARTS[i].two
                      : _number == '3'
                          ? CHARTS[i].three
                          : _number == '4'
                              ? CHARTS[i].four
                              : _number == '5'
                                  ? CHARTS[i].five
                                  : _number == '6'
                                      ? CHARTS[i].six
                                      : _number == '7'
                                          ? CHARTS[i].seven
                                          : _number == '8'
                                              ? CHARTS[i].eight
                                              : _number == '9'
                                                  ? CHARTS[i].nine
                                                  : _number == '0'
                                                      ? CHARTS[i].zero
                                                      : '';
            }
          }
          for (int i = 0; i < cpData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cpData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'ARB Cut Panna') {
          for (int i = 0; i < ABR_CUT_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: ABR_CUT_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Running Panna') {
          for (int i = 0; i < RUNNING_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: RUNNING_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki Beki Running Panna') {
          for (int i = 0; i < AKI_BEKI_RUNING_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: AKI_BEKI_RUNING_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki Running Panna') {
          for (int i = 0; i < AKI_RUNING_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: AKI_RUNING_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Beki Running Panna') {
          for (int i = 0; i < BEKI_RUNING_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: BEKI_RUNING_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki Beki Panna') {
          for (int i = 0; i < AKI_BEKI_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: AKI_BEKI_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki Panna') {
          for (int i = 0; i < AKI_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: AKI_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Beki Panna') {
          for (int i = 0; i < BEKI_PANNA.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: BEKI_PANNA[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Ank Start Panna') {
          List cpData = [];
          for (int i = 0; i < ANK_START_PANNA.length; i++) {
            if (ANK_START_PANNA[i].number == _number) {
              cpData = _patti_type == 'sp'
                  ? ANK_START_PANNA[i].sp
                  : ANK_START_PANNA[i].dp;
            }
          }
          for (int i = 0; i < cpData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: cpData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == ' Kaichi Jodi/Running Jodi') {
          for (int i = 0; i < _kaichiJodiData.length; i++) {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _kaichiJodiData[i],
                  type: _patti_type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'SP') {
          if (_number.length == 1) {
            for (int i = 0; i < NUMBER_LIST.length; i++) {
              List cpData = [];

              if (NUMBER_LIST[i].number == _number) {
                cpData = NUMBER_LIST[i].sp;
              }

              for (int i = 0; i < cpData.length; i++) {
                _games.insert(
                  0,
                  Game(
                      amount: amountCtrl.text,
                      numbers: cpData[i],
                      type: _patti_type,
                      gameName: _game_time,
                      gameId: _game_id),
                );
              }
            }
          } else {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _number,
                  type: _type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'DP') {
          if (_number.length == 1) {
            for (int i = 0; i < NUMBER_LIST.length; i++) {
              List cpData = [];

              if (NUMBER_LIST[i].number == _number) {
                cpData = NUMBER_LIST[i].dp;
              }

              for (int i = 0; i < cpData.length; i++) {
                _games.insert(
                  0,
                  Game(
                      amount: amountCtrl.text,
                      numbers: cpData[i],
                      type: _patti_type,
                      gameName: _game_time,
                      gameId: _game_id),
                );
              }
            }
          } else {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _number,
                  type: _type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'TP') {
          if (_number == 'All') {
            for (int i = 0; i < ALL_TP.length; i++) {
              _games.insert(
                0,
                Game(
                    amount: amountCtrl.text,
                    numbers: ALL_TP[i],
                    type: _patti_type,
                    gameName: _game_time,
                    gameId: _game_id),
              );
            }
          } else {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _number,
                  type: _type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'Aki') {
          if (_number == 'All') {
            for (int i = 0; i < AKI.length; i++) {
              setState(() {
                _games.insert(
                  0,
                  Game(
                      amount: amountCtrl.text,
                      numbers: AKI[i],
                      type: _type,
                      gameName: _game_time,
                      gameId: _game_id),
                );
              });
            }
          }
        } else if (_type == 'Beki') {
          if (_number == 'All') {
            for (int i = 0; i < BEKI.length; i++) {
              _games.insert(
                0,
                Game(
                    amount: amountCtrl.text,
                    numbers: BEKI[i],
                    type: _type,
                    gameName: _game_time,
                    gameId: _game_id),
              );
            }
          }
        } else if (_type == 'open' || _type == 'Open') {
          if (_games.length > 0) {
            for (int i = 0; i <= _games.length - 1; i++) {
              if (_games[i].type == 'open' || _games[i].type == 'Open') {
                if (_games[i].numbers == _number) {
                  _games[i].amount =
                      (int.parse(_games[i].amount) + int.parse(amountCtrl.text))
                          .toString();
                  setState(() {
                    flag = false;
                  });
                }
              }
            }
            if (flag) {
              _games.insert(
                0,
                Game(
                    amount: amountCtrl.text,
                    numbers: _number,
                    type: _type,
                    gameName: _game_time,
                    gameId: _game_id),
              );
            }
          } else {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _number,
                  type: _type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else if (_type == 'close' || _type == 'Close') {
          if (_games.length > 0) {
            for (int i = 0; i <= _games.length - 1; i++) {
              if (_games[i].type == 'close' || _games[i].type == 'Close') {
                if (_games[i].numbers == _number) {
                  _games[i].amount =
                      (int.parse(_games[i].amount) + int.parse(amountCtrl.text))
                          .toString();
                  setState(() {
                    flag = false;
                  });
                }
              }
            }
            if (flag) {
              _games.insert(
                0,
                Game(
                    amount: amountCtrl.text,
                    numbers: _number,
                    type: _type,
                    gameName: _game_time,
                    gameId: _game_id),
              );
            }
          } else {
            _games.insert(
              0,
              Game(
                  amount: amountCtrl.text,
                  numbers: _number,
                  type: _type,
                  gameName: _game_time,
                  gameId: _game_id),
            );
          }
        } else {
          _games.insert(
            0,
            Game(
                amount: amountCtrl.text,
                numbers: _number,
                type: _type,
                gameName: _game_time,
                gameId: _game_id),
          );
        }

        // }
      }

      setState(() {
        _number = '';
        amountCtrl.clear();
        _isAddEnabled = true;
        _isUpdate = false;
      });
      _calculateTotal(_games, false);
    }
  }

  void deleteGame(index, isDelete) {
    var details = _games[index];
    // print(details.gameName);
    // print(details.type);
    setState(() {
      for (int i = 0; i < _games.length; i++) {
        if (_games[i].type == details.type &&
            _games[i].gameName == details.gameName &&
            _games[i].amount == details.amount) {
          //  _games.remove(_games[i]);
          _games.removeAt(i);
          i = i - 1;
          //  .removeAt(i);
        }
      }
    });
    _calculateTotal(_games, isDelete);
  }

  void _calculateTotal(game, isDelete) {
    int _amount = 0;

    for (int i = 0; i <= game.length - 1; i++) {
      _amount = _amount + int.parse(_games[i].amount);
    }
    setState(() {
      _totalAmount = _amount.toString();
    });

    // Navigator.of(context).pop();

    if (double.parse(_totalAmount) >
        double.parse(
            Provider.of<WalletAmount>(context, listen: false).amount)) {
      Navigator.of(context).pop();
      setState(() {
        _totalAmount =
            (int.parse(_totalAmount) - int.parse(_games[0].amount)).toString();
        _games.removeAt(0);
      });
      _errorDialog();
    } else {
      if (!isDelete) {
        Navigator.of(context).pop();
      }
    }
  }

  void _updateGame(index) {
    if (amountCtrl.text == '' || _number == '') {
      _showErrorDialog(1);
      return;
    }

    setState(() {
      _games[index].amount = amountCtrl.text;
      _games[index].numbers = _number;
      _games[index].type = _type;
      amountCtrl.clear();
      _isEdit = false;
      _isUpdate = false;
      _number = '';
    });

    _calculateTotal(_games, false);
  }

  @override
  void deactivate() {
    timer1?.cancel();
    timer2?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    timer1?.cancel();
    timer2?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // _animationController.stop();
    // _animationController.dispose();
    _resizableController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  _onChooseNumber(context) async {
    DateTime currentDateTime = DateTime.now();

    if (currentDateTime.isAfter(widget.routeData["index"]["utcOpenTime"])) {
      setState(() {
        isOpenEnd = true;
      });
    }

    await Navigator.of(context).pushNamed(
      PlayNumber.routeName,
      arguments: {'isOpenEnd': isOpenEnd},
    ).then((value) {
      final Map<String, dynamic> data = value;
      // print('data');
      // print(data);

      setState(() {
        // _cpData=data['number'];
        _number =
            data['type'] == 'CP' ? data['number'].join(",") : data['number'];
        _type = data['type'];
        _patti_type = data['patti_type'];
        _game_time = data['game_time'];
        _game_id = int.parse(data['game_id']);
        _cpData = _number.split(',');
      });

      // print(_cpData);
      // print(_number);
      if (_type == ' Kaichi Jodi/Running Jodi') {
        _kaichiJodiData = _number.split(',');
      }
    });
  }

  _onDGModel() {
    if (_number == '') {
      setState(() {
        _numberNotSet = true;
      });
    } else {
      setState(() {
        _numberNotSet = false;
      });
    }
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
          // _closePopUP();
          return Container(
            height: 294,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: TextField(
                          controller: amountCtrl,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          textDirection: ui.TextDirection.rtl,
                          showCursor: true,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Enter Amount',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),

                            // border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(10.0),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        onPressed: () {
                          if (amountCtrl.text != null &&
                              amountCtrl.text.length > 0) {
                            amountCtrl.text = amountCtrl.text
                                .substring(0, amountCtrl.text.length - 1);
                          }
                        },
                        child: Icon(
                          Icons.keyboard_backspace,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                  height: 220,
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
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          child: number.setText
                              ? Text(
                                  number.text,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    // fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
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
                              Navigator.of(context).pop();
                              setState(() {
                                // _isEmpty = true;
                              });
                            } else if (number.number == '12') {
                              if (_number == '' ||
                                  _number.isEmpty ||
                                  amountCtrl.text == '' ||
                                  amountCtrl.text.isEmpty) {
                                setState(() {
                                  _isEmpty = true;
                                });
                                Navigator.of(context).pop();
                              } else {
                                _addGame();
                                // Navigator.of(context).pop();
                              }
                            } else {
                              if (_isUpdateAmount) {
                                amountCtrl.text = '';
                                setState(() {
                                  _isUpdateAmount = false;
                                });
                              }

                              amountCtrl.text = amountCtrl.text + number.number;
                              if (amountCtrl.text[0] == '0') {
                                amountCtrl.text = '';
                              }
                            }
                            // Navigator.pop(
                            //     context);
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          );
        }).whenComplete(() {
      if (_isEmpty) {
        _showErrorDialog(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletAmount = Provider.of<WalletAmount>(context);

    _edit(context) async {
      await Navigator.of(context).pushNamed(
        PlayNumber.routeName,
        arguments: {'isOpenEnd': isOpenEnd},
      ).then((value) {
        final Map<String, dynamic> data = value;

        setState(() {
          _isUpdate = true;
          // _currentIndex = index;
          _isEdit = true;
          _type = data['type'];
          _number = data['number'];
          _patti_type = data['patti_type'];
        });
      });
    }

    _editDG(index, flag) {
      _onDGModel();
      setState(() {
        _isUpdate = true;
        _currentIndex = index;
        _isEdit = true;
        _number = _games[index].numbers;
        amountCtrl.text = _games[index].amount;
        _isUpdateAmount = flag;
      });
    }

    Future<void> _getGameInfo() async {
      final String url = 'api/daily_5_minute_game_list';
      final data = jsonEncode(<String, dynamic>{"page": 1});
      try {
        var response = await postData(url, data, true);
        if (response.statusCode == 200) {
          final gData = jsonDecode(response.body);
          setState(() {
            _gameData = {'index': gData['data'][0], 'type': 'dailyGame'};
          });
          List moreGames = [];
          // setState(() {
          //   if (count == 1) {
          //     _games = gData['data'];
          //     _isLoading = false;

          //   }
          // });

          _getTime();
        } else if (response.statusCode == 408) {
          AutoLogOut().popUpFor408(context);
        } else {
          final List data = [];
          // data.add({"status": response.statusCode});

          return data;
        }
      } catch (e) {
        // final error = {"status": 'offline'};
        final List error = [];
        return error;
      }
    }

    Future<bool> _onBackPressed() {
      setState(() {
        // _showSlotMachine = false;
        timer1?.cancel();
        timer2?.cancel();
      });

      if (_isPlaying) {
        player.stop();
      }
      Navigator.of(context).pop();
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_gameData['index']['componie_name']),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  // _showSlotMachine = false;
                  // _isback = true;
                  timer1?.cancel();
                  timer2?.cancel();
                });

                if (_isPlaying) {
                  player.stop();
                }
                if (_isPlaying1) {
                  player1.stop();
                }
                Navigator.of(context).pop();
              }),
          // Text(_routeData['index'].componyName),
          actions: [
            Row(
              children: [
                Text(walletAmount.amount,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // setState(() {
                    //   player.stop();
                    // });

                    if (_isPlaying) {
                      player.stop();
                    }
                    if (_isPlaying1) {
                      player1.stop();
                    }

                    Navigator.of(context).pushNamed(Wallet.routeName);
                  },
                ),
                _isRefresh
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(() {
                            _isRefresh = true;
                          });
                          await _getWalletAmount();
                          walletAmount.changeAmount(_walletAmount);
                        },
                      )
              ],
            ),
          ],
          backgroundColor: Theme.of(context).primaryColor,
          bottom: PreferredSize(
            child: BidDetails(
                companyData: _gameData['index'], type: _gameData['type']),
            preferredSize: Size.fromHeight(120.0),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: isCloseEnd
                ? Padding(
                    padding: EdgeInsets.only(
                        top: ((MediaQuery.of(context).size.height * 0.6) / 2)),
                    child: Column(
                      children: [
                        ResultNotSet('Game Ended'),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Back',
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor),
                        )
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                (_number == '' && !_numberNotSet)
                                    ? getContainer(_gameData['type'])
                                    : (_number == '' && _numberNotSet)
                                        ? InkWell(
                                            onTap: () {
                                              _edit(context);
                                            },
                                            child: Container(
                                              height: 30,
                                              width: 140,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Number not choose',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              _edit(context);
                                            },
                                            child: Container(
                                              height: 30,
                                              width: 140,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      // 'Number -',
                                                      _type == 'Touch Panna'
                                                          ? _patti_type
                                                          : _type,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                  (_type == 'ARB Cut Panna' ||
                                                          _type ==
                                                              'Running Panna' ||
                                                          _type ==
                                                              'Aki Beki Running Panna' ||
                                                          _type ==
                                                              'Aki Running Panna' ||
                                                          _type ==
                                                              'Beki Running Panna' ||
                                                          _type ==
                                                              'Aki Beki Panna' ||
                                                          _type ==
                                                              'Aki Panna' ||
                                                          _type ==
                                                              'Beki Panna' ||
                                                          _type ==
                                                              ' Kaichi Jodi/Running Jodi')
                                                      ? Text(
                                                          _type ==
                                                                  ' Kaichi Jodi/Running Jodi'
                                                              ? ''
                                                              : ' - All',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      : Text(
                                                          _type == 'CP'
                                                              ? ''
                                                              : ' - ' + _number,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                (_number == '' && !_numberNotSet)
                                    ? Container(
                                        width: 140,
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: TextField(
                                          controller: amountCtrl,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                          textDirection: ui.TextDirection.rtl,
                                          showCursor: true,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter Amount',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.all(7.0),
                                          ),
                                          onTap: _onDGModel,
                                        ),
                                      )
                                    : getAmountContainer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.65,
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
                              child: _gameData['type'] == 'allGame'
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                            child: Text(
                                          'Name',
                                          textAlign: TextAlign.center,
                                        )),
                                        SizedBox(
                                          width: 40,
                                          child: Text(
                                            'Type',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Number',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Amount',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                              // width: 30,
                                              ),
                                        )
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 65.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  'Number',
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Amount',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.30,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 35.0,
                                              ),
                                              Text(
                                                'Past Result',
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                            ),
                            _gameData['type'] == 'allGame'
                                ? Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: _games.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                            height: 48,
                                            margin: EdgeInsets.all(2),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _games[index].type,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 40,
                                                      child: Text(
                                                        _games[index]
                                                                    .gameName ==
                                                                ""
                                                            ? _games[index]
                                                                .type[0]
                                                                .toUpperCase()
                                                            : _games[index]
                                                                .gameName,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        _games[index].numbers ??
                                                            '0',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Text(
                                                      _games[index].amount,
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Container(
                                                            height: 30,
                                                            width: 30,
                                                            child:
                                                                RawMaterialButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _currentIndex =
                                                                      index;
                                                                });
                                                                _edit(context);
                                                              },
                                                              elevation: 2.0,
                                                              fillColor:
                                                                  Colors.green,
                                                              child: Icon(
                                                                Icons.edit,
                                                                size: 15.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              shape:
                                                                  CircleBorder(),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 30,
                                                            width: 30,
                                                            child:
                                                                RawMaterialButton(
                                                              onPressed: () {
                                                                deleteGame(
                                                                    index,
                                                                    true);
                                                              },
                                                              elevation: 2.0,
                                                              fillColor:
                                                                  Colors.red,
                                                              child: Icon(
                                                                Icons
                                                                    .delete_forever,
                                                                size: 15.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              shape:
                                                                  CircleBorder(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(),
                                              ],
                                            ));
                                      },
                                    ),
                                  )
                                : Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.70,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.54,
                                              child: ListView.builder(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                itemCount: _games.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Container(
                                                    height: 48,
                                                    margin: EdgeInsets.all(2),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                _games[index]
                                                                        .numbers ??
                                                                    '0',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Text(
                                                              _games[index]
                                                                  .amount,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            )),
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Container(
                                                                    height: 30,
                                                                    width: 30,
                                                                    child:
                                                                        RawMaterialButton(
                                                                      onPressed:
                                                                          () {
                                                                        _editDG(
                                                                            index,
                                                                            true);
                                                                      },
                                                                      elevation:
                                                                          2.0,
                                                                      fillColor:
                                                                          Colors
                                                                              .green,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .edit,
                                                                        size:
                                                                            15.0,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      shape:
                                                                          CircleBorder(),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    height: 30,
                                                                    width: 30,
                                                                    child:
                                                                        RawMaterialButton(
                                                                      onPressed:
                                                                          () {
                                                                        deleteGame(
                                                                            index,
                                                                            true);
                                                                      },
                                                                      elevation:
                                                                          2.0,
                                                                      fillColor:
                                                                          Colors
                                                                              .red,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .delete_forever,
                                                                        size:
                                                                            15.0,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      shape:
                                                                          CircleBorder(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
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
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.30,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.54,
                                                // color: Theme.of(context)
                                                //     .primaryColor,
                                                child: _fiveMinGameResult
                                                            .length ==
                                                        0
                                                    ? Center(
                                                        child: Column(
                                                        children: [
                                                          Text(
                                                            'Data',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .accentColor),
                                                          ),
                                                          Text(
                                                            'Not',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .accentColor),
                                                          ),
                                                          Text(
                                                            'Found',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .accentColor),
                                                          ),
                                                        ],
                                                      ))
                                                    : ListView.builder(
                                                        itemCount:
                                                            _fiveMinGameResult
                                                                .length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Container(
                                                            height: 80,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  style:
                                                                      BorderStyle
                                                                          .solid,
                                                                  width: 1.0,
                                                                ),
                                                                color: int.tryParse(_fiveMinGameResult[index].resultNo).isEven ? 
                                                                Colors.blue[800] : 
                                                                Colors.green[700]
                                                                // color: (index ==
                                                                //             0 ||
                                                                //         index ==
                                                                //             4)
                                                                //     ? Color(
                                                                //         0xFF4285F4)
                                                                //     : (index == 1 ||
                                                                //             index ==
                                                                //                 5)
                                                                //         ? Color(
                                                                //             0xFFDB4437)
                                                                //         : (index == 2 ||
                                                                //                 index ==
                                                                //                     6)
                                                                //             ? Color(
                                                                //                 0xFFF4B400)
                                                                //             : Color(
                                                                //                 0xFF0F9D58),
                                                                ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  _fiveMinGameResult[
                                                                          index]
                                                                      .resultNo,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        34,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5.0,
                                                                ),
                                                                Text(
                                                                  _fiveMinGameResult[
                                                                              index]
                                                                          .openTime +
                                                                      '-' +
                                                                      _fiveMinGameResult[
                                                                              index]
                                                                          .closeTime,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 2.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(2.0, 0.0),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Amount : $_totalAmount',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 2.0),
                                      child: ElevatedButton(
                                        onPressed: _placeBitButton
                                            ? () {
                                                final List<Game> data = _games;

                                                List bidData = [];

                                                for (int i = 0;
                                                    i < _games.length;
                                                    i++) {
                                                  Map<String, dynamic> bData = {
                                                    'no': _games[i].numbers,
                                                    'amount': _games[i].amount,
                                                    // 'game_name':
                                                    //     _games[i].type
                                                    'game_id': _games[i].gameId,
                                                    "is_open": _games[i]
                                                                    .gameName ==
                                                                'O' ||
                                                            _games[i].type ==
                                                                "open"
                                                        ? 1
                                                        : _games[i].gameName ==
                                                                    'C' ||
                                                                _games[i]
                                                                        .type ==
                                                                    "close"
                                                            ? 2
                                                            : 3
                                                  };

                                                  bidData.add(bData);
                                                }

                                                Map<String, dynamic> finalData =
                                                    {
                                                  // 'd_5_m_id': _gameData['index']
                                                  //     ['d_5_m_id'],
                                                  'company_id':
                                                      _gameData['index']
                                                          ['d_5_m_id'],
                                                  'bid_data': bidData
                                                };

                                                double _wA =
                                                    double.parse(_wAmount);
                                                // double _wA =
                                                //     double.parse('40000');
                                                double _tA =
                                                    double.parse(_totalAmount);

                                                if (_totalAmount == '0') {
                                                  _showErrorDialog(1);
                                                } else {
                                                  if (_wA >= _tA) {
                                                    _confirmationDialog(
                                                        finalData);
                                                  } else {
                                                    _errorDialog();
                                                  }
                                                }
                                              }
                                            : null,
                                        child: Text(
                                          'Place Bet',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary:
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _printDialog() async {
    //  _timer1 = Timer(Duration(seconds: 5), () {
    //   Navigator.of(context).pop();
    // });
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final walletAmount = Provider.of<WalletAmount>(context);
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Bet place successfully!',
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
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  onPressed: () {
                    walletAmount.changeAmount(_walletAmount);
                    _games.clear();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // setState(() {
                    //   _showSlotMachine = false;
                    // });

                    if (_isPlaying) {
                      player.stop();
                    }
                    if (_isPlaying1) {
                      player1.stop();
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: Text(
                    'Print',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  onPressed: () {
                    walletAmount.changeAmount(_walletAmount);
                    Navigator.of(context).pop();
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
                                        (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () {
                                          _testPrint(_devices[index]);
                                          Navigator.pop(context);
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              height: 60,
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(Icons.print),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
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
                    ).whenComplete(() {
                      changeData();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: Text(
                    'Play More',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  onPressed: () {
                    walletAmount.changeAmount(_walletAmount);
                    setState(() {
                      _number = '';
                      amountCtrl.clear();
                      _isAddEnabled = true;
                      _isUpdate = false;
                      _totalAmount = '0';
                      _games = [];
                      _games.clear();
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        });
      },
    );
    //   .then((value){
    //       if (_timer1.isActive) {
    //   _timer1.cancel();
    // }
    //   });
  }

  Future<void> _confirmationDialog(finalData) async {
    bool checkFlag = await SysDateTimeChange().checkDateAndTime(context);

    if (checkFlag) {
      Navigator.pushNamed(context, TimeDateCheck.routeName);
    } else {
      //    _timer = Timer(Duration(seconds: 5), () {
      //   Navigator.of(context).pop();
      // });
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!

        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(
                        'Do you want to place Bet?',
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
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _placeBitButton = false;
                          });

                          _placeBid(finalData, context);
                        }),
                  ),
                ],
              );
            },
          );
        },
      );
      //     .then((value) {
      //         if (_timer.isActive) {
      //   _timer.cancel();
      // }
      //     }) ;
    }
  }

  Future<void> _errorDialog() async {
    // if (!_showSlotMachine) {
    //   _closePopUP();
    // }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Insufficient balance, please contact admin or raise request'),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // _placeBid(finalData, context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(int flag) async {
    // if (!_showSlotMachine) {
    //   _closePopUP();
    // }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: flag == 1
              ? Text('How to play game')
              : Text('Choose another number'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                flag == 1
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1. Choose Number'),
                          Text('2. Enter Amount'),
                          Text('3. Place Bet'),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(_number == ''
                              ? 'Please choose one number'
                              : amountCtrl.text == ''
                                  ? 'Please enter amount'
                                  : 'Please choose one number and enter amount'),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Number already chose'),
                          ]),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isEmpty = false;

                    _numberNotSet = false;

                    amountCtrl.clear();
                  });
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
