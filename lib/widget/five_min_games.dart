// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/error_screens/data_not_found.dart';
import 'bids.dart';

class FiveMinGames extends StatefulWidget {
  static const routeName = '/5-min-game';

  @override
  _FiveMinGamesState createState() => _FiveMinGamesState();
}

class _FiveMinGamesState extends State<FiveMinGames> {
  List _games = [];
  int count = 1;
  int _lastCount;
  bool _isLoading = true;
  bool _isBottomLoading = false;
  final ScrollController _scrollController = ScrollController();
  _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _getGameInfo(count) async {
    const String url = 'api/daily_5_minute_game_list';
    final data = jsonEncode(<String, dynamic>{"page": count});
    var response = await postData(url, data, true);
    // ignore: avoid_print
    
    if (response.statusCode == 200) {
      var gData = jsonDecode(response.body);
     
      List moreGames = [];
      setState(() {
        if (count == 1) {
          _games = gData['data'];
          _isLoading = false;
          _isBottomLoading = false;
          _lastCount = gData['last_page'];
        } else {
          moreGames = gData['data'];
          _games.addAll(moreGames);
          _isLoading = false;
          _isBottomLoading = false;
        }
      });
    } else if (response.statusCode == 408) {
      AutoLogOut().popUpFor408(context);
    } else {
      final List data = [];
      return data;
    }
  }

  _onMore() {
    setState(() {
      count += 1;
      _isBottomLoading = true;
    });
    _getGameInfo(count);
  }

  @override
  void initState() {
    super.initState();
    _getGameInfo(count);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      appBar: AppBar(
        title: const Text('JANTA RAJ (5 Minutes Game)'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              )
            : _games.length == 0
                ? Center(
                    child: DataNotFound("Game's Not Found"),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          controller: _scrollController,
                          itemCount: _games.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0, right: 5.0, top: 2.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Bids(
                                          routeData: <String, dynamic>{
                                            'index': _games[index],
                                            'type': 'dailyGame'
                                          }),
                                    ),
                                  ).then((value) {
                                    _getGameInfo(count);
                                  });
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.white70, width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '5 Min Game',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                              Text(
                                                _games[index]['game_date'],
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          color: Colors.black12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 25,
                                              width: 80,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(40.0),
                                                    bottomRight:
                                                        Radius.circular(40.0)),
                                              ),
                                              child: Text(
                                                _games[index]['s_time'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ),
                                            Text(
                                              'JANTA RAJ',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              height: 25,
                                              width: 80,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(40.0),
                                                    bottomLeft:
                                                        Radius.circular(40.0)),
                                              ),
                                              child: Text(
                                                _games[index]['end_time'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(5.0),
                                                bottomRight:
                                                    Radius.circular(5.0)),
                                            color: Colors.grey[100],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: const Text(
                                                  'No Bids',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 60,
                                                  child: OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Play',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: 12),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Bids(routeData: <
                                                                  String,
                                                                  dynamic>{
                                                            'index':
                                                                _games[index],
                                                            'type': 'dailyGame'
                                                          }),
                                                        ),
                                                      ).then((value) {
                                                        _getGameInfo(count);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      count != _lastCount
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _onMore();
                                  },
                                  child: _isBottomLoading
                                      ? SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor:
                                                  Theme.of(context).accentColor,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'More Games',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                  style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).primaryColor),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
      ),
    );
  }
}
