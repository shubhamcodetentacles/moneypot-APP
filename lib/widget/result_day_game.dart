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
import 'package:moneypot/widget/day_game_view_result.dart';
import 'package:moneypot/widget/view_result.dart';

class ResultDayGame extends StatefulWidget {
  @override
  _ResultDayGameState createState() => _ResultDayGameState();
}

class _ResultDayGameState extends State<ResultDayGame> {
  List all = [];
  List wins = [];
  List loose = [];
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
    final String url = 'api/pana_game_result_data';
    final data = jsonEncode(<String, dynamic>{});

    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });

        var bData = jsonDecode(response.body);
        // print('data');
        // print(bData);
        List bidData = bData['pana_game_data'];
        for (int i = 0; i < bidData.length; i++) {
          setState(() {
            all.add(bidData[i]);
          });
          if (bidData[i]['is_winner'] == 0 || bidData[i]['is_winner'] == "0") {
            setState(() {
              loose.add(bidData[i]);
            });
          } else {
            setState(() {
              wins.add(bidData[i]);
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
                  all.length != 0
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
                                        builder: (context) => DayGameViewResult(
                                            bidID: all[index]['bid_id'])),
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
                                                'Day Game',
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
                                                  '0',
                                                  // all[index]['bid_number'],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ),
                                              Text(
                                                all[index]['game_date'],
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
                                                all[index]['s_time'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ),
                                            Text(
                                              all[index]['company_name'],
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
                                                all[index]['end_time'],
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
                                                      all[index]['bid_count']
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              all[index]['is_winner'] == 0 ||
                                                      all[index]['is_winner'] ==
                                                          "0"
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
                                                                DayGameViewResult(
                                                                    bidID: all[
                                                                            index]
                                                                        [
                                                                        'bid_id'])),
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
                          itemCount: all.length,
                        )
                      : DataNotFound('Result not found'),
                  wins.length != 0
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
                                        builder: (context) => DayGameViewResult(
                                            bidID: wins[index]['bid_id'])),
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
                                                'Day Game',
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
                                                  '0',
                                                  // wins[index]['bid_number'],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ),
                                              Text(
                                                wins[index]['game_date'],
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
                                                wins[index]['s_time'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ),
                                            Text(
                                              wins[index]['company_name'],
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
                                                wins[index]['end_time'],
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
                                                      wins[index]['bid_count']
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
                                                            builder: (context) =>
                                                                DayGameViewResult(
                                                                    bidID: wins[
                                                                            index]
                                                                        [
                                                                        'bid_id'])),
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
                          itemCount: wins.length,
                        )
                      : DataNotFound('Wins result not found'),
                  loose.length != 0
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
                                        builder: (context) => DayGameViewResult(
                                            bidID: loose[index]['bid_id'])),
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
                                                'Day Game',
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
                                                  '0',
                                                  // loose[index]['bid_number'],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ),
                                              Text(
                                                loose[index]['game_date'],
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
                                                loose[index]['s_time'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ),
                                            Text(
                                              loose[index]['company_name'],
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
                                                loose[index]['end_time'],
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
                                                      loose[index]['bid_count']
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
                                                            builder: (context) =>
                                                                DayGameViewResult(
                                                                    bidID: loose[
                                                                            index]
                                                                        [
                                                                        'bid_id'])),
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
                          itemCount: loose.length,
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
