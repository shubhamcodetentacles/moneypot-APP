// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moneypot/main.dart';
import 'package:moneypot/models/categories.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/widget/all_charts.dart';
import 'package:moneypot/widget/all_pannas.dart';
import 'package:moneypot/widget/ank_start_pannas.dart';
import 'package:moneypot/widget/family_panna.dart';
import 'package:moneypot/widget/touch_panna.dart';
import '../provider/data.dart';

class PlayNumber extends StatefulWidget {
  static const routeName = '/play-number';
  @override
  _PlayNumberState createState() => _PlayNumberState();
}

class _PlayNumberState extends State<PlayNumber> {
  String _currentButtonIndex = 'b1';
  bool _isJodiOn = false;
  bool _isKaichiJodiOn = false;
  bool _isOpenOn = false;
  bool _isCloseOn = false;
  bool _isPattiOn = false;
  bool _isNumbersOn = false;
  bool _isCPOn = false;
  bool _isMPOn = false;
  bool _isEkiOn = false;
  bool _isBekiOn = false;
  bool _isSangamOn = false;
  bool _isHalfSangamOn = false;
  bool _isHide = false;

  bool _touchPanna = false;
  bool _familyPanna = false;
  bool _charts = false;
  bool _arbCutPanna = false;
  bool _runningPanna = false;
  bool _akiBekiRunningPanna = false;
  bool _akiRunningPanna = false;
  bool _bekiRunningPanna = false;
  bool _akiBekiPanna = false;
  bool _akiPanna = false;
  bool _bekiPanna = false;
  bool _ankStartPanna = false;
  bool _cpPatti = false;

  bool _allPanna = false;

  bool _isNextOn = false;
  bool _isLoader = false;

  String _gameTime = '';
  String _mpType = '';
  String _open = '-';
  String _close = '-';
  String _fNo = '-';
  String _gameType = '';
  String _pattiType = '';
  String _selectedType;
  String _mpString = '';
  String _kaichiJodi = '-';
  String _pattiesNumber = '-';

  List<String> _patties = NUMBER_LIST[0].sp;
  List<String> numbers = [];
  List<String> _sp = [];
  List<String> _dp = [];
  List<String> _openKaichiJodi = [];
  List<String> _closeKaichiJodi = [];

  List<int> _mpNumbers = [];
  List categories;
  Map<String, String> bitData = {};

  @override
  void dispose() {
    _isJodiOn = false;
    _isOpenOn = false;
    _isCloseOn = false;
    _isPattiOn = false;
    _open = '-';
    _close = '-';
    _pattiType = '';

    super.dispose();
  }

  @override
  void initState() {
    _getGameList();
    super.initState();
  }

  _getGameList() async {
    categories = [];
    setState(() {
      _isLoader = true;
    });
    final String url = 'api/game_list';
    final data = jsonEncode(<String, dynamic>{});

    final response = await postData(url, data, false);

    if (response.statusCode == 200) {
      setState(() {
        _isLoader = false;
      });
      var gameList = jsonDecode(response.body);

      List<dynamic> data = [];
      data = gameList['game_list'];

      for (int i = 0; i < gameList['game_list'].length; i++) {
        setState(() {
          categories.add(
            Categories(
                cId: gameList['game_list'][i]['id'].toString(),
                name: gameList['game_list'][i]['game_name']),
          );
        });
      }
    } else if (response.statusCode == 408) {
      AutoLogOut().popUpFor408(context);
    } else {
      final data = jsonDecode(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final String _routeData =
    //     ModalRoute.of(context).settings.arguments as String;
    final arguments = ModalRoute.of(context).settings.arguments as Map;
    // print('arguments');
    // print(arguments['isOpenEnd']);
    _returnData(number, pattiType) {
      // print('number');
      // print(number);
      if (_gameTime == '' && !_isJodiOn && !_isOpenOn && !_isCloseOn) {
        _showOpenorCloseDialog();
      } else {
        final Map<String, dynamic> data = {
          "number": number,
          // "type": _gameType=='Touch Panna'?pattiType:_gameType,
          "type": _isMPOn ? _mpType : _gameType,
          "patti_type": pattiType,
          "game_time": _gameTime,
          "game_id": _currentButtonIndex
        };
        // print(data);
        Navigator.pop(
          context,
          data,
        );
      }
    }

    flags(
        isJodiOn,
        isOpenOn,
        isCloseOn,
        isPattiOn,
        isNumbersOn,
        isCPOn,
        isMPOn,
        isEkiOn,
        isBekiOn,
        isSangamOn,
        isHalfSangamOn,
        touchPanna,
        familyPanna,
        charts,
        arbCutPanna,
        runningPanna,
        akiBekiRunningPanna,
        akiRunningPanna,
        bekiRunningPanna,
        akiBekiPanna,
        akiPanna,
        bekiPanna,
        ankStartPanna,
        cpPatti,
        isKaichiJodiOn) {
      setState(() {
        _isPattiOn = isPattiOn;
        _isKaichiJodiOn = isKaichiJodiOn;
        _isJodiOn = isJodiOn;
        _isOpenOn = isOpenOn;
        _isCloseOn = isCloseOn;
        _isNumbersOn = isNumbersOn;
        _isCPOn = isCPOn;
        _isMPOn = isMPOn;
        _isEkiOn = isEkiOn;
        _isBekiOn = isBekiOn;
        _isSangamOn = isSangamOn;
        _isHalfSangamOn = isHalfSangamOn;
        _touchPanna = touchPanna;
        _familyPanna = familyPanna;
        _charts = charts;
        // _allPanna=allPanna;

        _arbCutPanna = arbCutPanna;
        _runningPanna = runningPanna;
        _akiBekiRunningPanna = akiBekiRunningPanna;
        _akiRunningPanna = akiRunningPanna;
        _bekiRunningPanna = bekiRunningPanna;
        _akiBekiPanna = akiBekiPanna;
        _akiPanna = akiPanna;
        _bekiPanna = bekiPanna;
        _ankStartPanna = ankStartPanna;
        _cpPatti = cpPatti;
      });

      // print(_familyPanna);
    }

    _setFlag(name) {
      switch (name) {
        case 'Open':
        case 'open':
          flags(
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          _open = name;
          _close = '-';
          _pattiType = name;
          break;
        case 'Close':
        case 'close':
          flags(
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          _open = "-";
          _close = name;
          _pattiType = name;
          break;
        case 'Jodi':
        case 'jodi':
          flags(
              true,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          _open = '-';
          _close = '-';
          _pattiType = name;
          break;
        case 'SP':
        case 'DP':
        case 'TP':
          setState(() {
            flags(
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false);
            _open = '-';
            _close = '-';
            _pattiType = name;
          });
          break;
        case 'CP':
          setState(() {
            flags(
                false,
                true,
                false,
                false,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false);
            _open = '-';
            _close = '-';
            _pattiType = name;
          });
          break;
        case 'MP':
          setState(() {
            flags(
                false,
                false,
                false,
                false,
                true,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false);

            _pattiType = name;
          });
          break;
        case 'Berij':
          flags(
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Farak':
          flags(
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Aki':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          numbers = [];
          for (int i = 0; i < NUMBER_LIST.length; i++) {
            numbers.add(NUMBER_LIST[i].number);
            i += 1;
          }
          break;
        case 'Beki':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          numbers = [];
          for (int i = 1; i < NUMBER_LIST.length; i++) {
            numbers.add(NUMBER_LIST[i].number);
            i += 1;
          }
          break;

        case 'Touch Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Family Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Charts':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'All Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'ARB Cut Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Running Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;

        case 'Aki Beki Running Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Aki Running Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Beki Running Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Aki Beki Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
              false);
          break;
        case 'Aki Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false);
          break;
        case 'Beki Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false,
              false);
          break;

        case 'Ank Start Panna':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false,
              false);
          break;
        case 'CP Patti':
          flags(
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true,
              false);
          break;
        case ' Kaichi Jodi/Running Jodi':
          flags(
              false,
              true,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              true);
          setState(() {
            _pattiType = 'Kaichi Jodi/Running Jodi';
          });
          break;

        default:
          setState(() {
            flags(
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false);
            _open = '-';
            _close = '-';
            _pattiType = '';
          });
      }
    }

    _pageNavigator(name) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => AllPanna(
                    name,
                    isEndOpen: arguments['isOpenEnd'],
                  ))).then((value) {
        final Map<String, dynamic> data = value;
        setState(() {
          _gameTime = data['game_time'];
        });
        // print('AllPanna');
        // print(data['number']);
        _returnData(
            data['type'] == 'CP' ? data['number'] : data['type'], data['type']);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text((_isPattiOn && _isHide)
            ? 'Choose One Patti'
            : _isHide
                ? 'Choose One Number'
                : 'Choose One Game'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoader
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            )
          : Column(
              children: [
                !_isHide
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.82,
                        padding: EdgeInsets.all(10),
                        child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 2.5,
                            children: List.generate(categories.length, (index) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor,
                                  padding: EdgeInsets.all(8.0),
                                ),
                                child: Text(
                                  categories[index].name,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                onPressed: ((arguments['isOpenEnd'] &&
                                            (categories[index].name == 'Open' ||
                                                categories[index].name ==
                                                    'open')) ||
                                        (arguments['isOpenEnd'] &&
                                            (categories[index].name == 'Jodi' ||
                                                categories[index].name ==
                                                    'jodi')))
                                    ? null
                                    : () {
                                        setState(() {
                                          _currentButtonIndex =
                                              categories[index].cId;
                                          _gameType = categories[index].name;
                                          if (categories[index].name ==
                                              'ARB Cut Panna') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else if (categories[index].name ==
                                              'Running Panna') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else if (categories[index].name ==
                                              'Aki Beki Running Panna') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else if (categories[index].name ==
                                              'Aki Running Panna') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else if (categories[index].name ==
                                              'Beki Running Panna') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else if (categories[index].name ==
                                              'Aki Beki Panna') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else if (categories[index].name ==
                                              'Aki Panna') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else if (categories[index].name ==
                                              'Beki Panna') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else if (categories[index].name ==
                                              'CP') {
                                            _isHide = false;
                                            _pageNavigator(
                                                categories[index].name);
                                          } else {
                                            _isHide = true;
                                          }
                                        });
                                        _setFlag(categories[index].name);
                                      },
                              );
                            })))
                    : SizedBox(),
                (_isJodiOn && _isHide)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !_isOpenOn
                              ? OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        style: BorderStyle.solid,
                                        width: 1),
                                    primary: _isOpenOn
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).accentColor,
                                  ),
                                  child: Text(
                                    'Choose Open Number',
                                    style: TextStyle(
                                        color: _isOpenOn
                                            ? Theme.of(context).accentColor
                                            : Colors.black),
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        _isOpenOn = true;
                                        _isCloseOn = false;
                                      },
                                    );
                                  },
                                )
                              : TextButton(
                                  child: Text(
                                    'Choose Open Number',
                                    style: TextStyle(
                                        color: Colors.black),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: _isOpenOn
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).accentColor,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        _isOpenOn = true;
                                        _isCloseOn = false;
                                      },
                                    );
                                  },
                                ),
                          !_isCloseOn
                              ? OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        style: BorderStyle.solid,
                                        width: 1),
                                    primary: _isCloseOn
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).accentColor,
                                  ),
                                  child: Text(
                                    'Choose Close Number',
                                    style: TextStyle(
                                        color: _isCloseOn
                                            ? Theme.of(context).accentColor
                                            : Colors.black),
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        _isOpenOn = false;
                                        _isCloseOn = true;
                                      },
                                    );
                                  },
                                )
                              : TextButton(
                                  child: Text(
                                    'Choose Close Number',
                                    style: TextStyle(
                                        color:  Colors.black),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: _isCloseOn
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).accentColor,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        _isOpenOn = false;
                                        _isCloseOn = true;
                                      },
                                    );
                                  },
                                ),
                        ],
                      )
                    : SizedBox(),
                (_isJodiOn && _isHide) ? const Divider() : SizedBox(),
                (_isKaichiJodiOn && _isHide)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            child: Text(
                              'Choose Open Number',
                              style: TextStyle(
                                  color: _isOpenOn
                                      ? Theme.of(context).accentColor
                                      : Colors.black),
                            ),
                            style: TextButton.styleFrom(
                              primary: _isOpenOn
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  _isOpenOn = true;
                                  _isCloseOn = false;
                                },
                              );
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Choose Close Number',
                              style: TextStyle(
                                  color: _isCloseOn
                                      ? Theme.of(context).accentColor
                                      : Colors.black),
                            ),
                            style: TextButton.styleFrom(
                              primary: _isCloseOn
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  _isOpenOn = false;
                                  _isCloseOn = true;
                                },
                              );
                            },
                          ),
                        ],
                      )
                    : SizedBox(),
                (_isKaichiJodiOn && _isHide) ? const Divider() : SizedBox(),
                (_isPattiOn && _isHide)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              top: 10,
                              left: 24,
                              right: 24,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text(
                                //   'Choose One Patti',
                                //   style: TextStyle(
                                //       color: Theme.of(context).primaryColor,
                                //       fontSize: 12),
                                // ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isPattiOn = false;
                                      _isHide = true;
                                    });
                                  },
                                  child: Text(
                                    '< Back',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Container(
                          //   width: double.infinity,
                          //   height: 300.0,
                          //   child: Text('Choose one type'),
                          // ),

                          Container(
                            width: double.infinity,
                            height: 300.0,
                            child: GridView.count(
                              crossAxisCount: 3,
                              padding: EdgeInsets.all(20.0),
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio:
                                  MediaQuery.of(context).size.width /
                                      (MediaQuery.of(context).size.height / 4),
                              children: _patties.map((patti) {
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor,
                                    textStyle: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  child: Text(
                                    patti,
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    _returnData(patti, _pattiType);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          _pattiType == 'TP'
                              ? SizedBox()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      child: Text('Play All',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor)),
                                      style: ElevatedButton.styleFrom(
                                          primary:
                                              Theme.of(context).primaryColor),
                                      onPressed: () {
                                        _returnData(_pattiesNumber, _pattiType);
                                      },
                                    ),
                                  ],
                                ),
                        ],
                      )
                    : _isHide
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container(
                              //   padding: EdgeInsets.only(
                              //     top: 10,
                              //     left: 24,
                              //     right: 20,
                              //   ),
                              //   child: Text(
                              //     'Choose One Number',
                              //     style: TextStyle(
                              //         color: Theme.of(context).primaryColor,
                              //         fontSize: 12),
                              //   ),
                              // ),
                              (_isNumbersOn ||
                                      _touchPanna ||
                                      _charts ||
                                      _familyPanna ||
                                      _ankStartPanna ||
                                      _isEkiOn ||
                                      _isBekiOn)
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Choose One Type',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _gameTime != 'O'
                                                ? OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          style:
                                                              BorderStyle.solid,
                                                          width: 1),
                                                      primary: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    child: Text('Open',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor)),
                                                    onPressed:
                                                        arguments['isOpenEnd']
                                                            ? (){
                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(openBidMessage)));
                                                            }
                                                            : () {
                                                                setState(() {
                                                                  _gameTime =
                                                                      'O';
                                                                });
                                                              },
                                                  )
                                                : ElevatedButton(
                                                    child: Text('Open',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor)),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                    onPressed:
                                                        arguments['isOpenEnd']
                                                            ? (){
                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(openBidMessage)));
                                                            }
                                                            : () {
                                                                setState(() {
                                                                  _gameTime =
                                                                      'O';
                                                                });
                                                              },
                                                  ),
                                            _gameTime != 'C'
                                                ? OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          style:
                                                              BorderStyle.solid,
                                                          width: 1),
                                                      primary: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    child: Text('Close',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor)),
                                                    onPressed: () {
                                                      setState(() {
                                                        _gameTime = 'C';
                                                      });
                                                    },
                                                  )
                                                : ElevatedButton(
                                                    child: Text('Close',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor)),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                    onPressed: () {
                                                      setState(() {
                                                        _gameTime = 'C';
                                                      });
                                                    },
                                                  ),
                                          ],
                                        ),
                                        _isMPOn ? const Divider() : SizedBox(),
                                        _isMPOn
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  _mpType != 'SPMP'
                                                      ? OutlinedButton(
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            side: BorderSide(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                                width: 1),
                                                            primary: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                          ),
                                                          child: Text('SPMP',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor)),
                                                          onPressed: () {
                                                            setState(() {
                                                              _mpType = 'SPMP';
                                                            });
                                                          },
                                                        )
                                                      : ElevatedButton(
                                                          child: Text('SPMP',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .accentColor)),
                                                          style: ElevatedButton.styleFrom(
                                                              primary: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          onPressed: () {
                                                            setState(() {
                                                              _mpType = 'SPMP';
                                                            });
                                                          },
                                                        ),
                                                  _mpType != 'DPMP'
                                                      ? OutlinedButton(
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            side: BorderSide(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                                width: 1),
                                                            primary: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                          ),
                                                          child: Text('DPMP',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor)),
                                                          onPressed: () {
                                                            setState(() {
                                                              _mpType = 'DPMP';
                                                            });
                                                          },
                                                        )
                                                      : ElevatedButton(
                                                          child: Text('DPMP',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .accentColor)),
                                                          style: ElevatedButton.styleFrom(
                                                              primary: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          onPressed: () {
                                                            setState(() {
                                                              _mpType = 'DPMP';
                                                            });
                                                          },
                                                        ),
                                                  _mpType != 'SPDPMP'
                                                      ? OutlinedButton(
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            side: BorderSide(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                                width: 1),
                                                            primary: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                          ),
                                                          child: Text('SPDPMP',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor)),
                                                          onPressed: () {
                                                            setState(() {
                                                              _mpType =
                                                                  'SPDPMP';
                                                            });
                                                          },
                                                        )
                                                      : ElevatedButton(
                                                          child: Text('SPDPMP',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .accentColor)),
                                                          style: ElevatedButton.styleFrom(
                                                              primary: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          onPressed: () {
                                                            setState(() {
                                                              _mpType =
                                                                  'SPDPMP';
                                                            });
                                                          },
                                                        ),
                                                ],
                                              )
                                            : SizedBox(),
                                        const Divider(),
                                      ],
                                    )
                                  : SizedBox(),
                              (!_touchPanna &&
                                      !_charts &&
                                      !_familyPanna &&
                                      !_ankStartPanna)
                                  ? Container(
                                      width: double.infinity,
                                      height: 170.0,
                                      child: GridView.count(
                                        crossAxisCount: 5,
                                        padding: EdgeInsets.all(20.0),
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        children: _isEkiOn || _isBekiOn
                                            ? numbers.map((number) {
                                                return ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Theme.of(context)
                                                        .primaryColor,
                                                    textStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                      side: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    number,
                                                    style: TextStyle(
                                                      fontSize: 30.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    // _returnData(number, _pattiType);
                                                  },
                                                );
                                              }).toList()
                                            : NUMBER_LIST.map((number) {
                                                return ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Theme.of(context)
                                                        .primaryColor,
                                                    textStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                      side: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    number.number,
                                                    style: TextStyle(
                                                      fontSize: 30.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (_pattiType == 'SP' &&
                                                        !_isPattiOn &&
                                                        _isNumbersOn) {
                                                      setState(() {
                                                        _pattiesNumber =
                                                            number.number;
                                                        _patties = number.sp;
                                                        _isPattiOn = true;
                                                      });
                                                    }
                                                    if (_pattiType == 'DP' &&
                                                        !_isPattiOn &&
                                                        _isNumbersOn) {
                                                      _patties = [];
                                                      setState(() {
                                                        _pattiesNumber =
                                                            number.number;
                                                        _patties = number.dp;
                                                        _isPattiOn = true;
                                                      });
                                                    }
                                                    if (_pattiType == 'TP' &&
                                                        !_isPattiOn &&
                                                        _isNumbersOn) {
                                                      _patties = [];
                                                      setState(() {
                                                        _pattiesNumber =
                                                            number.number;
                                                        _patties = number.tp;
                                                        _isPattiOn = true;
                                                      });
                                                    }

                                                    if (_pattiType == 'MP' &&
                                                        _isNumbersOn) {
                                                      // print('object');

                                                      setState(() {
                                                        _isMPOn = true;
                                                        // _ge = true;
                                                        if (_mpNumbers.length ==
                                                            0) {
                                                          _mpNumbers.add(
                                                              int.parse(number
                                                                  .number));
                                                          setState(() {
                                                            _mpString =
                                                                _mpNumbers
                                                                    .join();
                                                          });
                                                        } else {
                                                          _mpNumbers.add(
                                                              int.parse(number
                                                                  .number));

                                                          int f = _mpNumbers[
                                                              _mpNumbers
                                                                      .length -
                                                                  2];
                                                          int s = _mpNumbers[
                                                              _mpNumbers
                                                                      .length -
                                                                  1];

                                                          if (s == 0) {
                                                            setState(() {
                                                              s = 10;
                                                            });
                                                          }

                                                          if (f == 0) {
                                                            setState(() {
                                                              f = 10;
                                                            });
                                                          }

                                                          // print(f);
                                                          // print(s);

                                                          // for(int i=0; i<_mpNumbers.length;i++){
                                                          setState(() {
                                                            _mpString =
                                                                _mpNumbers
                                                                    .join();
                                                          });

                                                          // }
                                                          if (f > s || f == s) {
                                                            _mpNumbers
                                                                .removeLast();
                                                            setState(() {
                                                              _mpString =
                                                                  _mpNumbers
                                                                      .join();
                                                            });
                                                            _showMPerrDialog();
                                                          }
                                                        }
                                                      });
                                                    }

                                                    if (_isOpenOn &&
                                                        !_isJodiOn &&
                                                        !_isMPOn &&
                                                        !_isKaichiJodiOn) {
                                                      setState(() {
                                                        _open = number.number;
                                                      });
                                                      _returnData(
                                                          _open, _pattiType);
                                                    }
                                                    if (_isCloseOn &&
                                                        !_isJodiOn &&
                                                        !_isMPOn &&
                                                        !_isKaichiJodiOn) {
                                                      setState(() {
                                                        _close = number.number;
                                                      });
                                                      _returnData(
                                                          _close, _pattiType);
                                                    }

                                                    if (_isOpenOn &&
                                                        _isJodiOn) {
                                                      setState(() {
                                                        _open = number.number;
                                                      });
                                                    }
                                                    if (_isCloseOn &&
                                                        _isJodiOn) {
                                                      setState(() {
                                                        _close = number.number;
                                                      });
                                                    }

                                                    if (_isOpenOn &&
                                                        _isKaichiJodiOn) {
                                                      bool ikjo = false;
                                                      if (_openKaichiJodi
                                                              .length !=
                                                          0) {
                                                        for (int i = 0;
                                                            i <
                                                                _openKaichiJodi
                                                                    .length;
                                                            i++) {
                                                          if (_openKaichiJodi[
                                                                  i] ==
                                                              number.number) {
                                                            ikjo = true;

                                                            break;
                                                          } else {
                                                            ikjo = false;
                                                            // break;
                                                          }
                                                        }
                                                        if (ikjo) {
                                                          _showNumberExitsDialog();
                                                        } else {
                                                          setState(() {
                                                            _openKaichiJodi.add(
                                                                number.number);
                                                          });
                                                          if (_closeKaichiJodi
                                                                  .length !=
                                                              0) {
                                                            List kaichiJodi =
                                                                [];
                                                            for (int i = 0;
                                                                i <
                                                                    _openKaichiJodi
                                                                        .length;
                                                                i++) {
                                                              for (int j = 0;
                                                                  j <
                                                                      _closeKaichiJodi
                                                                          .length;
                                                                  j++) {
                                                                kaichiJodi.add(
                                                                    _openKaichiJodi[
                                                                            i] +
                                                                        _closeKaichiJodi[
                                                                            j]);
                                                              }
                                                            }
                                                            setState(() {
                                                              _kaichiJodi =
                                                                  kaichiJodi
                                                                      .join(
                                                                          ',');
                                                            });
                                                          }
                                                        }
                                                      } else {
                                                        setState(() {
                                                          _openKaichiJodi.add(
                                                              number.number);
                                                        });
                                                        if (_closeKaichiJodi
                                                                .length !=
                                                            0) {
                                                          List kaichiJodi = [];
                                                          for (int i = 0;
                                                              i <
                                                                  _openKaichiJodi
                                                                      .length;
                                                              i++) {
                                                            for (int j = 0;
                                                                j <
                                                                    _closeKaichiJodi
                                                                        .length;
                                                                j++) {
                                                              kaichiJodi.add(
                                                                  _openKaichiJodi[
                                                                          i] +
                                                                      _closeKaichiJodi[
                                                                          j]);
                                                            }
                                                          }
                                                          setState(() {
                                                            _kaichiJodi =
                                                                kaichiJodi
                                                                    .join(',');
                                                          });
                                                        }
                                                      }
                                                    }
                                                    if (_isCloseOn &&
                                                        _isKaichiJodiOn) {
                                                      bool ikjc = false;
                                                      if (_closeKaichiJodi
                                                              .length !=
                                                          0) {
                                                        for (int i = 0;
                                                            i <
                                                                _closeKaichiJodi
                                                                    .length;
                                                            i++) {
                                                          if (_closeKaichiJodi[
                                                                  i] ==
                                                              number.number) {
                                                            ikjc = true;

                                                            break;
                                                          } else {
                                                            ikjc = false;
                                                            // break;
                                                          }
                                                        }
                                                        if (ikjc) {
                                                          _showNumberExitsDialog();
                                                        } else {
                                                          setState(() {
                                                            _closeKaichiJodi
                                                                .add(number
                                                                    .number);
                                                          });
                                                          if (_openKaichiJodi
                                                                  .length !=
                                                              0) {
                                                            List kaichiJodi =
                                                                [];
                                                            for (int i = 0;
                                                                i <
                                                                    _openKaichiJodi
                                                                        .length;
                                                                i++) {
                                                              for (int j = 0;
                                                                  j <
                                                                      _closeKaichiJodi
                                                                          .length;
                                                                  j++) {
                                                                kaichiJodi.add(
                                                                    _openKaichiJodi[
                                                                            i] +
                                                                        _closeKaichiJodi[
                                                                            j]);
                                                              }
                                                            }
                                                            // print(kaichiJodi);
                                                            setState(() {
                                                              _kaichiJodi =
                                                                  kaichiJodi
                                                                      .join(
                                                                          ',');
                                                            });
                                                          }
                                                        }
                                                      } else {
                                                        setState(() {
                                                          _closeKaichiJodi.add(
                                                              number.number);
                                                        });
                                                        if (_openKaichiJodi
                                                                .length !=
                                                            0) {
                                                          List kaichiJodi = [];
                                                          for (int i = 0;
                                                              i <
                                                                  _openKaichiJodi
                                                                      .length;
                                                              i++) {
                                                            for (int j = 0;
                                                                j <
                                                                    _closeKaichiJodi
                                                                        .length;
                                                                j++) {
                                                              kaichiJodi.add(
                                                                  _openKaichiJodi[
                                                                          i] +
                                                                      _closeKaichiJodi[
                                                                          j]);
                                                            }
                                                          }
                                                          // print(kaichiJodi);
                                                          setState(() {
                                                            _kaichiJodi =
                                                                kaichiJodi
                                                                    .join(',');
                                                          });
                                                        }
                                                      }
                                                    }

                                                    if (_isNumbersOn &&
                                                        !_isPattiOn &&
                                                        !_isMPOn) {
                                                      _returnData(number.number,
                                                          _pattiType);
                                                    }
                                                  },
                                                );
                                              }).toList(),
                                      ),
                                    )
                                  : _touchPanna
                                      ? Column(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.45,
                                              child: GridView.count(
                                                crossAxisCount: 2,
                                                padding: EdgeInsets.all(20.0),
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                childAspectRatio: 3.5,
                                                children: TOUCH_PANNA.map((tp) {
                                                  var index =
                                                      TOUCH_PANNA.indexOf(tp);
                                                  int clickedIndex;
                                                  return ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: index ==
                                                              clickedIndex
                                                          ? Colors.green
                                                          : Theme.of(context)
                                                              .primaryColor,
                                                      textStyle: TextStyle(
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18.0),
                                                        side: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      tp.number,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        // fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _isNextOn = true;
                                                        clickedIndex = index;
                                                        _selectedType =
                                                            tp.number;
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            _isNextOn
                                                ? Text(
                                                    'Choose One Number',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                  )
                                                : SizedBox(),
                                            _isNextOn
                                                ? Container(
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    child: GridView.count(
                                                      crossAxisCount: 5,
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      crossAxisSpacing: 20,
                                                      mainAxisSpacing: 20,
                                                      children: NUMBER_LIST
                                                          .map((number) {
                                                        return ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            primary: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            textStyle:
                                                                TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                            ),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              side: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            number.number,
                                                            style: TextStyle(
                                                              fontSize: 30.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              _isNextOn = false;
                                                            });
                                                            // _returnData(number.number, _selectedType);
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        TouchPanna(
                                                                            _selectedType,
                                                                            number.number))).then(
                                                                (value) {
                                                              final Map<String,
                                                                      dynamic>
                                                                  data = value;
                                                              // _returnData(data['number'], data['type']);
                                                              _returnData(
                                                                  number.number,
                                                                  _selectedType);
                                                            });
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        )
                                      : _charts
                                          ? Column(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.45,
                                                  child: GridView.count(
                                                    crossAxisCount: 2,
                                                    padding:
                                                        EdgeInsets.all(20.0),
                                                    crossAxisSpacing: 10,
                                                    mainAxisSpacing: 10,
                                                    childAspectRatio: 3.5,
                                                    children: CHARTS.map((cts) {
                                                      var index =
                                                          CHARTS.indexOf(cts);
                                                      int clickedIndex;
                                                      return ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary: index ==
                                                                  clickedIndex
                                                              ? Colors.green
                                                              : Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                          textStyle: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor,
                                                          ),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                            side: BorderSide(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          cts.name,
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            // fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          // _returnData(patti, _pattiType);

                                                          setState(() {
                                                            _isNextOn = true;
                                                            clickedIndex =
                                                                index;
                                                            _selectedType =
                                                                cts.name;
                                                          });
                                                        },
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                _isNextOn
                                                    ? Text(
                                                        'Choose One Number',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      )
                                                    : SizedBox(),
                                                _isNextOn
                                                    ? Container(
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        child: GridView.count(
                                                          crossAxisCount: 5,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  20.0),
                                                          crossAxisSpacing: 20,
                                                          mainAxisSpacing: 20,
                                                          children: NUMBER_LIST
                                                              .map((number) {
                                                            return ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .accentColor,
                                                                ),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              18.0),
                                                                  side: BorderSide(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                number.number,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      30.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  _isNextOn =
                                                                      false;
                                                                });
                                                                //  _returnData(number.number, _selectedType);
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (BuildContext context) => AllCharts(
                                                                            _selectedType,
                                                                            number.number))).then(
                                                                    (value) {
                                                                  final Map<
                                                                          String,
                                                                          dynamic>
                                                                      data =
                                                                      value;
                                                                  // _returnData(data['number'], data['type']);
                                                                  _returnData(
                                                                      number
                                                                          .number,
                                                                      _selectedType);
                                                                });
                                                              },
                                                            );
                                                          }).toList(),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              ],
                                            )
                                          : _familyPanna
                                              ? Container(
                                                  width: double.infinity,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.70,
                                                  child: GridView.count(
                                                    crossAxisCount: 3,
                                                    padding:
                                                        EdgeInsets.all(20.0),
                                                    crossAxisSpacing: 10,
                                                    mainAxisSpacing: 10,
                                                    childAspectRatio: 3.0,
                                                    children:
                                                        FAMALY_PANA.map((fp) {
                                                      var index = FAMALY_PANA
                                                          .indexOf(fp);
                                                      int clickedIndex;

                                                      return ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary: index ==
                                                                  clickedIndex
                                                              ? Colors.green
                                                              : Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                          textStyle: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor,
                                                          ),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                            side: BorderSide(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          fp.id,
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            // fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          // _returnData(patti, _pattiType);

                                                          setState(() {
                                                            clickedIndex =
                                                                index;
                                                            _selectedType =
                                                                fp.id;
                                                          });
                                                          // _returnData(_selectedType, _selectedType);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      FamilyPanna(
                                                                          _selectedType,
                                                                          fp.data))).then(
                                                              (value) {
                                                            final Map<String,
                                                                    dynamic>
                                                                data = value;
                                                            // _returnData(data['number'], data['type']);
                                                            _returnData(
                                                                _selectedType,
                                                                _selectedType);
                                                          });
                                                        },
                                                      );
                                                    }).toList(),
                                                  ),
                                                )
                                              : _ankStartPanna
                                                  ? Column(
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 200,
                                                          child: GridView.count(
                                                            crossAxisCount: 3,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    20.0),
                                                            crossAxisSpacing:
                                                                10,
                                                            mainAxisSpacing: 10,
                                                            childAspectRatio:
                                                                3.0,
                                                            children:
                                                                ANK_START_PANNA
                                                                    .map((asp) {
                                                              var index =
                                                                  ANK_START_PANNA
                                                                      .indexOf(
                                                                          asp);
                                                              int clickedIndex;

                                                              return ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: index ==
                                                                          clickedIndex
                                                                      ? Colors
                                                                          .green
                                                                      : Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                  textStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor,
                                                                  ),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            18.0),
                                                                    side: BorderSide(
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  asp.number,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16.0,
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  // _returnData(patti, _pattiType);

                                                                  setState(() {
                                                                    _sp = [];
                                                                    _dp = [];
                                                                    _sp =
                                                                        asp.sp;
                                                                    _dp =
                                                                        asp.dp;
                                                                    _isNextOn =
                                                                        true;
                                                                    clickedIndex =
                                                                        index;
                                                                    _selectedType =
                                                                        asp.number;
                                                                  });
                                                                  // print(
                                                                  // _selectedType);
                                                                },
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                        _isNextOn
                                                            ? Text(
                                                                'Choose One Type',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor),
                                                              )
                                                            : SizedBox(),
                                                        _isNextOn
                                                            ? Row(
                                                                children: [
                                                                  _selectedType ==
                                                                          '9 Start'
                                                                      ? SizedBox()
                                                                      : Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 20.0, right: 5),
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                primary: Theme.of(context).primaryColor,
                                                                                textStyle: TextStyle(
                                                                                  color: Theme.of(context).accentColor,
                                                                                ),
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(18.0),
                                                                                  side: BorderSide(color: Theme.of(context).primaryColor),
                                                                                ),
                                                                              ),
                                                                              child: Text(
                                                                                'SP',
                                                                                style: TextStyle(
                                                                                  fontSize: 16.0,
                                                                                  // fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                // _returnData(patti, _pattiType);

                                                                                setState(() {
                                                                                  _isNextOn = false;
                                                                                });
                                                                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AnkStartPanna(_selectedType, _sp))).then((value) {
                                                                                  final Map<String, dynamic> data = value;
                                                                                  _returnData(data['number'], 'sp');
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                  Expanded(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: _selectedType == '9 Start'
                                                                              ? 20
                                                                              : 5.0,
                                                                          right:
                                                                              20),
                                                                      child:
                                                                          ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          primary:
                                                                              Theme.of(context).primaryColor,
                                                                          textStyle:
                                                                              TextStyle(
                                                                            color:
                                                                                Theme.of(context).accentColor,
                                                                          ),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(18.0),
                                                                            side:
                                                                                BorderSide(color: Theme.of(context).primaryColor),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'DP',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16.0,
                                                                            // fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          // _returnData(patti, _pattiType);

                                                                          setState(
                                                                              () {
                                                                            _isNextOn =
                                                                                false;
                                                                          });
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (BuildContext context) => AnkStartPanna(_selectedType, _dp))).then((value) {
                                                                            final Map<String, dynamic>
                                                                                data =
                                                                                value;
                                                                            _returnData(data['number'],
                                                                                'dp');
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : SizedBox(),
                                                      ],
                                                    )
                                                  : SizedBox(),
                            ],
                          )
                        : SizedBox(),
                (_isJodiOn && _isHide) ? const Divider() : SizedBox(),
                (_isJodiOn && _isHide)
                    ? Column(
                        children: [
                          Text('Your Jodi'),
                          Text(
                            _open + _close,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          ElevatedButton(
                            child: Text('Submit',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor)),
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor),
                            onPressed: () {
                              if (_open == '-' || _close == '-') {
                                _showMyDialog();
                              } else {
                                setState(() {});
                                _returnData('$_open$_close', _pattiType);
                              }
                            },
                          ),
                        ],
                      )
                    : SizedBox(),
                ((_isEkiOn || _isBekiOn) && _isHide)
                    ? const Divider()
                    : SizedBox(),
                ((_isEkiOn || _isBekiOn) && _isHide)
                    ? ElevatedButton(
                        child: Text('Play All',
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        onPressed: () {
                          _returnData('All', _pattiType);
                        },
                      )
                    : SizedBox(),
                (_isKaichiJodiOn && _isHide) ? const Divider() : SizedBox(),
                (_isKaichiJodiOn && _isHide)
                    ? Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Open Numbers'),
                              SizedBox(
                                height: 5,
                              ),
                              _openKaichiJodi.length != 0
                                  ? Text(_openKaichiJodi.join(","),
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20))
                                  : Text('Numbers not selected',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                              SizedBox(
                                height: 15,
                              ),
                              Text('Close Numbers'),
                              SizedBox(
                                height: 5,
                              ),
                              _closeKaichiJodi.length != 0
                                  ? Text(_closeKaichiJodi.join(","),
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20))
                                  : Text('Numbers not selected',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                              SizedBox(
                                height: 20,
                              ),
                              Text('Kaichi Jodi'),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 10, left: 10),
                                child: Text(
                                  _kaichiJodi,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                child: Text('Submit',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor)),
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor),
                                onPressed: () {
                                  if (_kaichiJodi == '-') {
                                    _showKaichiJodiDialog();
                                  } else {
                                    setState(() {});
                                    _returnData(_kaichiJodi, _pattiType);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
                (_pattiType == 'TP' && !_isPattiOn && _isNumbersOn)
                    ? const Divider()
                    : SizedBox(),
                (_pattiType == 'TP' && !_isPattiOn && _isNumbersOn)
                    ? ElevatedButton(
                        child: Text('Play All',
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        onPressed: () {
                          _returnData('All', _pattiType);
                        },
                      )
                    : SizedBox(),
                (_isMPOn && _isHide) ? const Divider() : SizedBox(),
                (_isMPOn && _isHide)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            child: Text('Remove All',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor)),
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor),
                            onPressed: () {
                              setState(() {
                                _mpNumbers.clear();
                                _mpString = '';
                              });
                            },
                          ),
                          ElevatedButton(
                            child: Text('Remove Last',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor)),
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor),
                            onPressed: () {
                              setState(() {
                                if (_mpNumbers.length > 0) {
                                  _mpNumbers.removeLast();
                                  _mpString = _mpNumbers.join();
                                }
                              });
                            },
                          ),
                        ],
                      )
                    : SizedBox(),
                (_isMPOn && _isHide) ? const Divider() : SizedBox(),
                (_isMPOn && _isHide)
                    ? Column(
                        children: [
                          Text('Your MP',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          Text(
                            _mpString,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          ElevatedButton(
                            child: Text('Submit',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor)),
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor),
                            onPressed: () {
                              // print(_mpNumbers.length);
                              if (_mpNumbers.length != 0 &&
                                  _mpNumbers.length != 1 &&
                                  _mpNumbers.length != 2 &&
                                  _mpNumbers.length != 3) {
                                // setState(() {
                                //   _isMPOn=false;
                                // });
                                _returnData(_mpString, _pattiType);
                              }
                              if (_mpNumbers.length >= 0 &&
                                  _mpNumbers.length <= 3) {
                                _showEmptyMPDialog();
                              }
                            },
                          ),
                        ],
                      )
                    : SizedBox(),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_open == '-'
              ? 'Open Missing'
              : _close == '-'
                  ? 'Close Missing'
                  : ''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'For jodi format game please choose open number and close number'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMPerrDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Wrong Format',style: TextStyle(
          //                     color: Theme.of(context).primaryColor,
          //                     fontWeight: FontWeight.bold,)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please enter correct format',
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showKaichiJodiDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Wrong Format',style: TextStyle(
          //                     color: Theme.of(context).primaryColor,
          //                     fontWeight: FontWeight.bold,)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please choose open numbers and close numbers',
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEmptyMPDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Wrong Format',style: TextStyle(
          //                     color: Theme.of(context).primaryColor,
          //                     fontWeight: FontWeight.bold,)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please enter minimum 4 number and maximum 9 number',
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showOpenorCloseDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Wrong Format',style: TextStyle(
          //                     color: Theme.of(context).primaryColor,
          //                     fontWeight: FontWeight.bold,)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please Select Open or Close',
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNumberExitsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Wrong Format',style: TextStyle(
          //                     color: Theme.of(context).primaryColor,
          //                     fontWeight: FontWeight.bold,)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Number already choosed, please choose another number ',
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
              },
            ),
          ],
        );
      },
    );
  }
}
