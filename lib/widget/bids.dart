// @dart=2.9
import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:moneypot/models/wallet_amount.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/error_screens/sys_date_time_change.dart';
import 'package:moneypot/screen/error_screens/time_date_check.dart';
import 'package:moneypot/widget/number_animation.dart';
import 'package:moneypot/widget/result_image.dart';
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
import '../widget/play_number.dart';
import 'bid_details.dart';
import 'wallet.dart';

class Bids extends StatefulWidget {
  static const routeName = '/bids';
  final Map<String, dynamic> routeData;
  Bids({Key key, this.routeData}) : super(key: key);
  @override
  _BidsState createState() => _BidsState();
}

class _BidsState extends State<Bids>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  List<Game> _games = [];
  String _number = '';
  String _type = '';
  bool _isEmpty = false;
  bool _isEdit = false;
  bool _isAddEnabled = true;
  bool _isUpdateAmount = false;
  int _currentIndex;
  String _totalAmount = '0';

  String _wAmount = '0';
  bool _isUpdate = false;
  bool flagPlace = true;
  List<FiveMinGameResult> _fiveMinGameResult = [];
  TextEditingController amountCtrl = TextEditingController();
  DateTime _myTime;
  DateTime _ntpTime;
  int _hour12;
  int _year;
  int _month;
  int _day;
  int _min;
  int _sec;

  Map<String, dynamic> _gameData;
  Map<String, dynamic> _result;
  String _walletAmount = '0';
  bool _showSlotMachine = false;
  bool _showResult = false;
  bool _placeBitButton = true;
  bool _isPlaying = false;
  bool _isPlaying1 = false;
  bool _numberNotSet = false;
  int _finalSec;
  AnimationController _animationController;
  Animation<double> _animation;
  List<int> _barData = [];
  Timer timer1, timer2;

  AudioCache cache = AudioCache();
  AudioCache audioCache = AudioCache();
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
                type == 'allGame'
                    ? _onChooseNumber(context)
                    : _onDGChooseNumber();
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

  // _closePopUP() {
  //   if (_showSlotMachine) {
  //     Navigator.of(context).pop();
  //   } else {
  //     Future.delayed(Duration(seconds: 1), () {
  //       _closePopUP();
  //     });
  //   }
  // }

  _startOrStop() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    } else {
      _animationController.reset();
      _animationController.forward();
    }
  }

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

  _getFiveMinGameResult() async {
    final String url = 'api/daily_5_minute_game_past_result';
    final data = jsonEncode(<String, dynamic>{});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        final grData = jsonDecode(response.body);

        List rData = grData['data'];

        setState(() {
          _fiveMinGameResult = [];
          for (int i = 0; i < rData.length; i++) {
            _fiveMinGameResult.add(FiveMinGameResult(
              openTime: rData[i]['s_time'],
              closeTime: rData[i]['end_time'],
              resultNo: rData[i]['win_no'],
            ));
          }
        });
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
    // print('widget.routeData');
    // print(widget.routeData);
    _gameData = widget.routeData;

    _showSlotMachine = false;
    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 150),
    );
    _animation = Tween(begin: 1.0, end: 30.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
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
      _getFiveMinGameResult();

      setState(() {
        _devices = [];
      });

      _getTime();
    }
  }

  _getTime() {
    DateTime mt = DateTime.now();
    setState(() {
      _myTime = mt;
    });

    _year = mt.year;
    _month = mt.month;
    _day = mt.day;
    _min = mt.minute;
    _sec = mt.second;
    // print(_sec);
    var hour = int.parse((mt.hour).toString());

    // print(hour);
    for (int i = 1; i <= 24; i++) {
      if (i == 12) {
        _hour12 = 12;
        break;
      } else if (hour > 12) {
        _hour12 = hour - 12;
        break;
      } else {
        _hour12 = hour;
        break;
      }
    }

    final _gameStartTime = _gameData['index']['s_time'];
    final _gameEndTime = _gameData['index']['end_time'];
    // final _gameStartTime = '3:55 pm';
    // final _gameEndTime = '4:00 pm';

    List _gET = [];
    _gET = _gameEndTime.split(' ');
    _gET = _gET[0].split(':');
    List _gST = [];
    _gST = _gameStartTime.split(' ');
    _gST = _gST[0].split(':');
    final now = new DateTime.now();
    String _currentTime = DateFormat('jm').format(now);
    List _cT = [];
    _cT = _currentTime.split(' ');
    _cT = _cT[0].split(':');

    var hrs = int.parse(_gET[0]) - int.parse(_cT[0]);
    var calHr, calMin, calSec;

    var geHr,
        geMin,
        geSec,
        cHr,
        cMin,
        cSec,
        hrToSec,
        minToSec,
        hr,
        min,
        sec,
        finalSec;
    geHr = int.parse(_gET[0]);
    geMin = int.parse(_gET[1]);
    geSec = 0;
    cHr = _hour12;
    cMin = _min;
    cSec = _sec;
    // print('geMin ' + geMin.toString());
    // print('cMin ' + cMin.toString());
    if (hrs == 0) {
      min = geMin - cMin;
      hrToSec = hrs * 60 * 60;
      minToSec = min * 60;
      sec = 60 - cSec;
      finalSec = hrToSec + minToSec + sec;
      var finalSecCal = finalSec - 70;
      var finalSecResult = finalSec - 58;
      setState(() {
        _finalSec = finalSecCal;
      });
      // print(finalSecCal);
      // print(finalSecResult);
      showWheel(finalSecCal);
      showResult(finalSecResult);
    } else if (geMin > cMin) {
      hr = geHr - cHr;
      min = geMin - cMin;
      hrToSec = hrs * 60 * 60;
      minToSec = min * 60;
      sec = 60 - cSec;
      finalSec = hrToSec + minToSec + sec;
      var finalSecCal = finalSec - 70;
      var finalSecResult = finalSec - 58;
      setState(() {
        _finalSec = finalSecCal;
      });
      showWheel(finalSecCal);
      showResult(finalSecResult);
      // print(finalSecCal);
      // print(finalSecResult);
    } else {
      hr = geHr - cHr;
      // print(_gST);
      // print(_gET);
      if (_gST[1] == '55' && _gET[1] == '00') {
        hr = hr - 1;

        // print('hr ' + hr.toString());
        // print('_gST[1] ' + _gST[1]);
        final rMin = (cMin - int.parse(_gST[1]));
        min = (5 - rMin) - 1;
        // print('min ' + min.toString());
        hrToSec = 0 * 60 * 60;
        // print('hrToSec ' + hrToSec.toString());
        minToSec = min * 60;
        // print('minToSec ' + minToSec.toString());
        // print('cSec ' + cSec.toString());
        final nowSec = 60 - cSec;
        finalSec = hrToSec + minToSec + nowSec;
        // print(finalSec);
        var finalSecCal = finalSec - 10;
        var finalSecResult = finalSec;
        setState(() {
          _finalSec = finalSecCal;
        });
        showWheel(finalSecCal);
        showResult(finalSecResult);
        // print(finalSecCal);
        // print(finalSecResult);
      }
    }
  }

  showWheel(sec) {
    timer1 = Timer(Duration(seconds: sec), () async {
      setState(() {
        _isPlaying = true;
        _showSlotMachine = true;
        _startOrStop();
        _showResult = false;
      });
      player = await cache.play('a1.wav');
    });

    // await Future.delayed(Duration(seconds: sec));
    // setState(() {
    //   _isPlaying = true;
    //   _showSlotMachine = true;
    //   _startOrStop();
    //   _showResult = false;
    // });
    // // player.play('a1.wav');
    // if (!_isback) {
    //   // audioCache.play('a1.wav');
    //   player = await cache.play('a1.wav');
    // }
    changeData();
    // audioCache.play('SW-1.mp3');
  }

  showResult(sec) {
    // await Future.delayed(Duration(seconds: sec));
    // if (_showSlotMachine) {
    //   if (!_isback) {
    //     _recursiveCall();
    //   }
    // }

    timer2 = Timer(Duration(seconds: sec), () async {
      if (_showSlotMachine) {
        _recursiveCall();
      }
    });
  }

  _recursiveCall() async {
    final String url = 'api/get_one_game_result';
    final data = jsonEncode(
        <String, dynamic>{'d_5_m_id': _gameData['index']['d_5_m_id']});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        // print(response.body);
        final result = jsonDecode(response.body);

        if (result['result'] == null) {
          _recursiveCall();
        } else {
          setState(() {
            _isPlaying1 = true;
            _result = result;
            // _showSlotMachine = false;
            _startOrStop();
            _showResult = true;
          });
          await _getWalletAmount();

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
    // print(res.msg);
    // print(res.value);
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
    final String url = 'api/set_bid';
    final data = jsonEncode(bidData);
    setState(() {
      flagPlace = false;
    });

    var response = await postData(url, data, true);
    // print(response.statusCode);
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
          isRefreshing = false;
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

    if (_isUpdate) {
      _updateGame(_currentIndex);
    } else {
      if (_games.length == 0 &&
          (_number != '' || _number.isEmpty) &&
          amountCtrl.text != '') {
        _games.insert(
          0,
          Game(
            amount: amountCtrl.text,
            numbers: _number,
            type: _type,
          ),
        );
      } else {
        for (int i = 0; i <= _games.length - 1; i++) {
          if (_games[i].numbers == _number) {
            _games[i].amount =
                (int.parse(_games[i].amount) + int.parse(amountCtrl.text))
                    .toString();
            setState(() {
              flag = false;
            });
          }
        }

        if (flag) {
          _games.insert(
            0,
            Game(
              amount: amountCtrl.text,
              numbers: _number,
              type: _type,
            ),
          );
        }
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
    setState(() {
      _games.removeAt(index);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // print("app in resumed");
        // if (!_isPlaying) {
        if (_isPlaying) {
          player.stop();
        }
        if (_isPlaying1) {
          player1.stop();
        }
        _getTime();
        // }
        break;
      case AppLifecycleState.inactive:
        if (_isPlaying) {
          player.stop();
        }
        if (_isPlaying1) {
          player1.stop();
        }
        timer1?.cancel();
        timer2?.cancel();

        // print("app in inactive");
        break;
      case AppLifecycleState.paused:
        if (_isPlaying) {
          player.stop();
        }
        if (_isPlaying1) {
          player1.stop();
        }
        timer1?.cancel();
        timer2?.cancel();

        // print("app in paused");
        break;
      case AppLifecycleState.detached:
        timer1?.cancel();
        timer2?.cancel();
        if (_isPlaying) {
          if (player != null) {
            player.stop();
          }
        }

        // print("app in detached");
        break;
    }
  }

  @override
  void deactivate() {
    timer1?.cancel();
    timer2?.cancel();
    if (_isPlaying) {
      player.stop();
    }
    if (_isPlaying1) {
      player1.stop();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    timer1?.cancel();
    timer2?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _animationController.stop();
    _animationController.dispose();
    _resizableController.dispose();
    _amountController.dispose();

    if (_isPlaying) {
      player.stop();
    }
    if (_isPlaying1) {
      player1.stop();
    }
    if (!mounted) {
      if (_isPlaying) {
        player.stop();
      }
      if (_isPlaying1) {
        player1.stop();
      }
      return; // Just do nothing if the widget is disposed.
    }
    super.dispose();
  }

  _onChooseNumber(context) async {
    await Navigator.of(context).pushNamed(PlayNumber.routeName).then((value) {
      final Map<String, dynamic> data = value;
      setState(() {
        _number = data['number'];
        _type = data['type'];
      });
    });
  }

  _onDGChooseNumber() {
    if (_number == '' && _numberNotSet) {
      setState(() {
        _numberNotSet = false;
      });
    } else {
      setState(() {
        _numberNotSet = true;
      });
    }

    showModalBottomSheet(
        isDismissible: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (BuildContext context) {
          // _closePopUP();
          return Container(
            height: 210,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 20),
                  child: Text(
                    'Choose One Number',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 12),
                  ),
                ),
                Container(
                  height: 180,
                  child: GridView.count(
                    crossAxisCount: 5,
                    padding: EdgeInsets.all(20.0),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: NUMBER_LIST.map(
                      (number) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            textStyle: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          child: Text(
                            number.number,
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _number = number.number;
                              _type = '5 min game';
                            });

                            Navigator.pop(context);
                            _onDGModel();
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          );
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

  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final walletAmount = Provider.of<WalletAmount>(context);

    _edit(index, context) async {
      amountCtrl.text = _games[index].amount;
      await Navigator.of(context)
          .pushNamed(PlayNumber.routeName, arguments: _games[index].type)
          .then((value) {
        final Map<String, dynamic> data = value;
        setState(() {
          _isUpdate = true;
          _currentIndex = index;
          _isEdit = true;
          _type = data['type'];
          _number = data['number'];
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
        _showSlotMachine = false;
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
          title: const Text('JANTA RAJ'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _showSlotMachine = false;
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
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      player.stop();
                    }
                    if (_isPlaying1) {
                      player1.stop();
                    }

                    Navigator.of(context).pushNamed(Wallet.routeName);
                  },
                ),
                isRefreshing
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
                            isRefreshing = true;
                          });

                          try {
                            await _getWalletAmount();

                            walletAmount.changeAmount(_walletAmount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Wallet amount is updated..."),
                              ),
                            );
                          } catch (e) {
                            // print(e.toString());
                          }
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
            // decoration: BoxDecoration(
            //     image: DecorationImage(image: AssetImage("assets/crackers.gif"), fit: BoxFit.cover),
            //   ),
            width: double.infinity,
            child: (_showSlotMachine)
                ? Column(children: [
                    SizedBox(height: 10),
                    Text('---------- Game End ----------',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                        _showResult
                            ? '----------' +
                                'Win - ' +
                                _result['result'] +
                                '----------'
                            : '---------- Wait For Result ----------',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Stack(
                      children: [
                        Container(
                          height: 400,
                          width: 400,
                          padding: EdgeInsets.all(10.0),
                          child: AnimatedBuilder(
                              animation: _animation,
                              child: Container(
                                  child: Image.asset('assets/new-wheel.png')),
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _animation.value * 5.0 * math.pi,
                                  child: child,
                                );
                              }),
                        ),
                        Positioned(
                          // top: MediaQuery.of(context).size.height*0.14,
                          // left: MediaQuery.of(context).size.width*0.25,
                          child: _showResult
                              ? Container(
                                  height: 400,
                                  width: 400,
                                  child: ResultImage(_result['result']))
                              : Container(
                                  height: 400,
                                  width: 400,
                                  child: NumberAnimation()),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.04,
                          left: MediaQuery.of(context).size.width * 0.075,
                          child: _showResult
                              ? Image.asset(
                                  "assets/animation_gif.gif",
                                  height: 350.0,
                                  width: 350.0,
                                )
                              : SizedBox(),
                        ),
                        _showResult
                            ? Image.asset(
                                "assets/stars.gif",
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                width: double.infinity,
                              )
                            : SizedBox(),
                      ],
                    ),
                    // SlotMachine(),
                    SizedBox(height: 16),
                    _showResult
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor),
                            onPressed: () {
                              setState(() {
                                _showSlotMachine = false;
                                _showResult = false;
                              });
                              timer1?.cancel();
                              timer2?.cancel();
                              _getGameInfo();
                              _getWalletInfo();
                              _getFiveMinGameResult();
                            },
                            child: const Text('Play More',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          )
                        : SizedBox(),
                  ])
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
                                            onTap: _onDGChooseNumber,
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
                                            onTap: _onDGChooseNumber,
                                            child: Container(
                                              height: 30,
                                              width: 140,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Number -',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                  ),
                                                  Text(
                                                    _number,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                          textDirection: ui.TextDirection.rtl,
                                          showCursor: true,
                                          readOnly: true,
                                          decoration: InputDecoration(
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
                                          'Type',
                                          textAlign: TextAlign.center,
                                        )),
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
                                                                _edit(index,
                                                                    context);
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
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white,
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                                width: 1.0,
                                                              ),
                                                              color: int.tryParse(
                                                                          _fiveMinGameResult[index]
                                                                              .resultNo)
                                                                      .isEven
                                                                  ? Colors
                                                                      .blue[800]
                                                                  : Colors.green[
                                                                      700],
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
                                                    'amount': _games[i].amount
                                                  };
                                                  bidData.add(bData);
                                                }

                                                Map<String, dynamic> finalData =
                                                    {
                                                  'd_5_m_id': _gameData['index']
                                                      ['d_5_m_id'],
                                                  'bid_data': bidData
                                                };

                                                double _wA =
                                                    double.parse(_wAmount);
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
                    setState(() {
                      _showSlotMachine = false;
                    });

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
                                          // _testPrint(_devices[index]);
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
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                // color: Theme.of(context).primaryColor,
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
