// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/error_screens/data_not_found.dart';
import 'package:moneypot/widget/barcode_scan.dart';
import 'package:moneypot/widget/view_result.dart';

class ResultFiveMinGame extends StatefulWidget {
  @override
  _ResultFiveMinGameState createState() => _ResultFiveMinGameState();
}

class _ResultFiveMinGameState extends State<ResultFiveMinGame> {
  List _all = [];
  List _wins = [];
  List _loose = [];
  bool _isLoading = true;
  String _scanBarcode = 'Unknown';
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    if (_scanBarcode != 'Unknown') {
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", "Cancel", true, ScanMode.BARCODE);

        List barCodeNo = barcodeScanRes.split('');

        List returnCode = [];
        for (int i = 0; i <= 10; i++) {
          returnCode.add(int.parse(barCodeNo[i]));
        }

        final String url = 'api/barcode_data';
        final data = jsonEncode(<String, dynamic>{
          'barcode_id': returnCode,
        });
        try {
          var response = await postData(url, data, true);
          if (response.statusCode == 200) {
            setState(() {
              _isLoading = false;
            });

            final rData = jsonDecode(response.body);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BarcodeScan(rData, returnCode)));
          } else if (response.statusCode == 408) {
            AutoLogOut().popUpFor408(context);
          } else {
            setState(() {
              _isLoading = false;
            });

            final List data = [];
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });

          return e;
        }
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }
    }
  }

  Future<void> _getResultInfo() async {
    final String url = 'api/user_result_data';
    final data = jsonEncode(<String, dynamic>{});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });

        var bData = jsonDecode(response.body);
        List bidData = bData['data'];
        for (int i = 0; i < bidData.length; i++) {
          setState(() {
            _all.add(bidData[i]);
          });
          if (bidData[i]['is_winner'] == 0 || bidData[i]['is_winner'] == "0") {
            setState(() {
              _loose.add(bidData[i]);
            });
          } else {
            setState(() {
              _wins.add(bidData[i]);
            });
          }
        }
        return bData['data'];
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        setState(() {
          _isLoading = false;
        });

        final List data = [];
        return data;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      final List error = [];
      return error;
    }
  }

  @override
  void initState() {
    _getResultInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            backgroundColor: Colors.grey[300],
            elevation: 0,
            bottom: TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(
                  text: "All",
                ),
                Tab(
                  text: "Wins",
                ),
                Tab(
                  text: "Loose",
                ),
              ],
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              )
            : TabBarView(
                children: [
                  _all.length != 0
                      ? ListView.builder(
                          itemBuilder: (ctx, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0, right: 5.0, top: 2.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewResult(
                                            bidID: int.parse(
                                                _all[index]['bid_id']))),
                                  );
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
                                              CircleAvatar(
                                                radius: 10,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                child: Text(
                                                  _all[index]['win_no'],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ),
                                              Text(
                                                _all[index]['game_date'],
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
                                                _all[index]['s_time'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ),
                                            Text(
                                              'JANTA RAJ',
                                              style: TextStyle(
                                                fontSize: 18,
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
                                                _all[index]['end_time'],
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
                                                child: Text(
                                                  'Bet - ' +
                                                      _all[index]['bid_count']
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              _all[index]['is_winner'] == 0 || _all[index]['is_winner'] == "0"
                                                  ? Text(
                                                      'Lost',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  : Text(
                                                      'Won',
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 61,
                                                  child: OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'View',
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
                                                                ViewResult(
                                                                    bidID: int.parse(
                                                                        _all[index]
                                                                            [
                                                                            'bid_id']))),
                                                      );
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
                          itemCount: _all.length,
                        )
                      : DataNotFound('Result not found'),
                  _wins.length != 0
                      ? ListView.builder(
                          itemBuilder: (ctx, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0, right: 5.0, top: 2.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewResult(
                                            bidID: int.parse(
                                                _wins[index]['bid_id']))),
                                  );
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
                                              CircleAvatar(
                                                radius: 10,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                child: Text(
                                                  _all[index]['win_no'],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ),
                                              Text(
                                                _wins[index]['game_date'],
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
                                                _wins[index]['s_time'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ),
                                            Text(
                                              'JANTA RAJ',
                                              style: TextStyle(
                                                fontSize: 18,
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
                                                _wins[index]['end_time'],
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
                                                child: Text(
                                                  'Bet - ' +
                                                      _wins[index]['bid_count']
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              Text(
                                                'Won',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 61,
                                                  child: OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'View',
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
                                                            builder: (context) => ViewResult(
                                                                bidID: int.parse(
                                                                    _wins[index]
                                                                        [
                                                                        'bid_id']))),
                                                      );
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
                          itemCount: _wins.length,
                        )
                      : DataNotFound('Wins result not found'),
                  _loose.length != 0
                      ? ListView.builder(
                          itemBuilder: (ctx, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0, right: 5.0, top: 2.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewResult(
                                            bidID: int.parse(
                                                _loose[index]['bid_id']))),
                                  );
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
                                              CircleAvatar(
                                                radius: 10,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                child: Text(
                                                  _all[index]['win_no'],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ),
                                              Text(
                                                _loose[index]['game_date'],
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
                                                _loose[index]['s_time'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ),
                                            Text(
                                              'JANTA RAJ',
                                              style: TextStyle(
                                                fontSize: 18,
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
                                                _loose[index]['end_time'],
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
                                                child: Text(
                                                  'Bet - ' +
                                                      _loose[index]['bid_count']
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              Text(
                                                'Lost',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 61,
                                                  child: OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'View',
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
                                                            builder: (context) => ViewResult(
                                                                bidID: int.parse(
                                                                    _loose[index]
                                                                        [
                                                                        'bid_id']))),
                                                      );
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
                          itemCount: _loose.length,
                        )
                      : DataNotFound('Loose result not found'),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            scanBarcodeNormal();
          },
          child: FaIcon(
            FontAwesomeIcons.barcode,
            color: Theme.of(context).accentColor,
            size: 20.0,
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
