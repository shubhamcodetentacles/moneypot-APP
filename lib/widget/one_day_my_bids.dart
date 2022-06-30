// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/error_screens/data_not_found.dart';
import 'package:moneypot/widget/view_bid.dart';

class OneDayMyBids extends StatefulWidget {
  // final List<dynamic> data;
  // const OneDayMyBids(this.data);

  @override
  _OneDayMyBidsState createState() => _OneDayMyBidsState();
}

class _OneDayMyBidsState extends State<OneDayMyBids> {
  Future<void> _getBidInfo() async {
    final String url = 'api/bid_list';
    final data = jsonEncode(<String, dynamic>{});
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        var bData = jsonDecode(response.body);
        return bData['pana_game_data'];
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        final List data = [];
        return data;
      }
    } catch (e) {
      final List error = [];
      return error;
    }
  }

  @override
  void initState() {
    _getBidInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getBidInfo(),
        // future: widget.bData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.hasData == null) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ]));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          }

          if (snapshot.hasData) {
            return snapshot.data.length == 0
                ? DataNotFound('Bet Data Not Found \n Play Game')
                : ListView.builder(
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 2.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewBid(
                                      bidID: int.parse(
                                          snapshot.data[index]['bid_id']),
                                      type: 'dayGame')),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white70, width: 1),
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
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          snapshot.data[index]['game_date'],
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
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
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 25,
                                          width: 80,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(40.0),
                                                bottomRight:
                                                    Radius.circular(40.0)),
                                          ),
                                          child: Text(
                                            snapshot.data[index]['s_time'],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex:3,
                                        child: Text(
                                          snapshot.data[index]['company_name'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex:1,
                                        child: Container(
                                          height: 25,
                                          width: 80,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(40.0),
                                                bottomLeft:
                                                    Radius.circular(40.0)),
                                          ),
                                          child: Text(
                                            snapshot.data[index]['end_time'],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
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
                                          bottomLeft: Radius.circular(5.0),
                                          bottomRight: Radius.circular(5.0)),
                                      color: Colors.grey[100],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            'Bet - ' +
                                                snapshot.data[index]
                                                        ['bid_count']
                                                    .toString(),
                                            style: TextStyle(
                                                color: Colors.green[800]),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: SizedBox(
                                            height: 20,
                                            width: 60,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              child: Text(
                                                'View',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 12),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewBid(
                                                              bidID: int.parse(
                                                                  snapshot.data[
                                                                          index]
                                                                      [
                                                                      'bid_id']),
                                                              type: 'dayGame')),
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
                    itemCount: snapshot.data.length,
                  );
          }
        });

    // widget.data.length == 0
    //             ? DataNotFound('Bet Data Not Found \n Play Game')
    //             :ListView.builder(
    //                 itemBuilder: (ctx, index) {
    //                   return Padding(
    //                     padding: const EdgeInsets.only(
    //                         left: 5.0, right: 5.0, top: 2.0),
    //                     child: Card(
    //                       shape: RoundedRectangleBorder(
    //                         side: BorderSide(color: Colors.white70, width: 1),
    //                         borderRadius: BorderRadius.circular(5),
    //                       ),
    //                       elevation: 5,
    //                       child: Padding(
    //                         padding: const EdgeInsets.only(top: 10),
    //                         child: Column(
    //                           mainAxisSize: MainAxisSize.min,
    //                           mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                           children: <Widget>[
    //                             Padding(
    //                               padding: const EdgeInsets.only(
    //                                   left: 10.0, right: 10),
    //                               child: Row(
    //                                 mainAxisAlignment:
    //                                     MainAxisAlignment.spaceBetween,
    //                                 children: [
    //                                   Text(
    //                                     '5 Min Game',
    //                                     style: TextStyle(
    //                                         fontSize: 12, color: Colors.grey),
    //                                   ),
    //                                   Text(
    //                                     widget.data[index]['game_date'],
    //                                     style: TextStyle(
    //                                         fontSize: 12, color: Colors.grey),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             const Divider(
    //                               color: Colors.black12,
    //                             ),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 Container(
    //                                   height: 25,
    //                                   width: 80,
    //                                   alignment: Alignment.center,
    //                                   decoration: BoxDecoration(
    //                                     color: Colors.green,
    //                                     borderRadius: BorderRadius.only(
    //                                         topRight: Radius.circular(40.0),
    //                                         bottomRight: Radius.circular(40.0)),
    //                                   ),
    //                                   child: Text(
    //                                     widget.data[index]['s_time'],
    //                                     style: TextStyle(
    //                                         color:
    //                                             Theme.of(context).accentColor),
    //                                   ),
    //                                 ),
    //                                 Text(
    //                                   'JANTA RAJ',
    //                                   style: TextStyle(
    //                                     fontSize: 18,
    //                                     fontWeight: FontWeight.bold,
    //                                   ),
    //                                 ),
    //                                 Container(
    //                                   height: 25,
    //                                   width: 80,
    //                                   alignment: Alignment.center,
    //                                   decoration: BoxDecoration(
    //                                     color: Colors.red,
    //                                     borderRadius: BorderRadius.only(
    //                                         topLeft: Radius.circular(40.0),
    //                                         bottomLeft: Radius.circular(40.0)),
    //                                   ),
    //                                   child: Text(
    //                                     widget.data[index]['end_time'],
    //                                     style: TextStyle(
    //                                         color:
    //                                             Theme.of(context).accentColor),
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                             SizedBox(
    //                               height: 8,
    //                             ),
    //                             Container(
    //                               height: 30,
    //                               decoration: BoxDecoration(
    //                                 borderRadius: BorderRadius.only(
    //                                     bottomLeft: Radius.circular(5.0),
    //                                     bottomRight: Radius.circular(5.0)),
    //                                 color: Colors.grey[100],
    //                               ),
    //                               child: Row(
    //                                 mainAxisAlignment:
    //                                     MainAxisAlignment.spaceBetween,
    //                                 children: [
    //                                   Padding(
    //                                     padding:
    //                                         const EdgeInsets.only(left: 10.0),
    //                                     child: Text(
    //                                       'Bet - ' +
    //                                           widget.data[index]['bid_count']
    //                                               .toString(),
    //                                       style: TextStyle(
    //                                           color: Colors.green[800]),
    //                                     ),
    //                                   ),
    //                                   Padding(
    //                                     padding:
    //                                         const EdgeInsets.only(right: 10.0),
    //                                     child: SizedBox(
    //                                       height: 20,
    //                                       width: 60,
    //                                       child: OutlineButton(
    //                                         borderSide: BorderSide(
    //                                           color: Theme.of(context)
    //                                               .primaryColor,
    //                                         ),
    //                                         child: Text(
    //                                           'View',
    //                                           style: TextStyle(
    //                                               color: Theme.of(context)
    //                                                   .primaryColor,
    //                                               fontSize: 12),
    //                                         ),
    //                                         onPressed: () {
    //                                           // Navigator.push(
    //                                           //   context,
    //                                           //   MaterialPageRoute(
    //                                           //       builder: (context) =>
    //                                           //           ViewBid(
    //                                           //               bidID: snapshot
    //                                           //                       .data[index]
    //                                           //                   ['bid_id'])),
    //                                           // );
    //                                         },
    //                                       ),
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   );
    //                 },
    //                 itemCount: widget.data.length,
    //               );
  }
}
