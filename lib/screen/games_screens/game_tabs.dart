// @dart=2.9
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneypot/models/componeis.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/error_screens/comming_soon.dart';
import 'package:moneypot/screen/tab_screens/tab_screen.dart';
import 'package:moneypot/widget/game_chart.dart';
import 'package:moneypot/widget/one_day_bids.dart';
import 'package:moneypot/widget/five_min_games.dart';
import 'package:moneypot/widget/rate_master.dart';
import 'package:ntp/ntp.dart';

var dt = DateTime.now();

class GameTabs extends StatefulWidget {
  @override
  _GameTabsState createState() => _GameTabsState();
}

class _GameTabsState extends State<GameTabs> {
  String _netDate;
  List componies;
  bool _isLoader = false;
  getNetworkTime() async {
    var now = await NTP.now();

    setState(() {
      _netDate = (DateFormat.yMMMMd().format(now)).toString();
    });
  }

  getCompanyList() async {
    componies = [];
    setState(() {
      _isLoader = true;
    });
    final String url = 'api/company_list';
    final data = jsonEncode(<String, dynamic>{});

    final response = await postData(url, data, false);

    if (response.statusCode == 200) {
      setState(() {
        _isLoader = false;
      });
      var companyList = jsonDecode(response.body);

      List<dynamic> data = [];
      data = companyList['company_list'];
      setState(() {
        componies.add(Componies(
            id: '0',
            componyName: 'JANTA RAJ',
            openTime: '11:30 AM',
            closeTime: '12:30 PM',
            date: (DateFormat.yMMMMd().format(dt)).toString(),
            open: '-',
            close: '-',
            openPatti: '---',
            closePatti: '---',
            bidCount: 'No Bids',
            isPlay: false,
            
            type: '5 Min Game'));
      });
      for (int i = 0; i < companyList['company_list'].length; i++) {
// if(companyList['company_list'][i]['open_time'][0]=='0'){
//   companyList['company_list'][i]['open_time']=companyList['company_list'][i]['open_time'].substring(1);
// }
// if(companyList['company_list'][i]['close_time'][0]=='0'){
//   companyList['company_list'][i]['close_time']=companyList['company_list'][i]['close_time'].substring(1);
// }
        setState(() {
          componies.add(
            Componies(
              isCommingSoon: data[i]['is_comingsoon'],
                id: companyList['company_list'][i]['company_id'].toString(),
                componyName: companyList['company_list'][i]['company_name'],
                openTime: data[i]['open_time'],
                closeTime: companyList['company_list'][i]['close_time'],
                date: (DateFormat.yMMMMd().format(dt)).toString(),
                utcOpenTime: DateTime.tryParse(
                    companyList['company_list'][i]['UTC_open_time']),
                utcCloseTime: DateTime.tryParse(
                    companyList['company_list'][i]["UTC_close_time"]),
                open: companyList['company_list'][i]['openWineNo'] != null
                    ? companyList['company_list'][i]['openWineNo'].toString()
                    : '-',
                close: companyList['company_list'][i]['closeWineNo'] != null
                    ? companyList['company_list'][i]['closeWineNo'].toString()
                    : '-',
                openPatti: companyList['company_list'][i]['openPatti'] != null
                    ? companyList['company_list'][i]['openPatti']
                    : '---',
                closePatti: companyList['company_list'][i]['closePatti'] != null
                    ? companyList['company_list'][i]['closePatti']
                    : '---',
                bidCount: 'No Bids',
                isPlay: false,
                type: 'Day Game'),
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
  void initState() {
    super.initState();
    getNetworkTime();
    getCompanyList();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoader
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          )
        : ListView.builder(
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0),
                child: InkWell(
                  onTap: () async {
                    if (componies[index].componyName == 'JANTA RAJ') {
                      await Navigator.of(context)
                          .pushNamed(FiveMinGames.routeName);
                      // if (result == null) {
                      // }

                    } else {
                      // Navigator.of(context)
                      //     .pushNamed(CommingSoon.routeName);
//                                      Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             Bids(routeData: <
//                                                                 String,
//                                                                 dynamic>{
//                                                           'index':
//                                                              {"d_5_m_id": 14385, "s_time": "10:40 pm", "c_s_time": "22:40:00", "is_winner_set": 0, "end_time": "10:45 pm",
// "c_end_time": "22:45:00", "win_no": null, "game_date": "2021-04-20", "inserted_date": "2021-04-20 00:00:02", "game_date_time": "2021-04-20 22:45:00",
// "test": "1618938900", "win_time": "2021-04-19 18:30:02", "is_result_set": 0, "set_win_no": null},
//                                                           'type': 'allGame'
//                                                         }),
//                                                       ),
//                                                     );
//

                      if (componies[index].componyName == "JANTA RAJ NIGHT" ||
                          componies[index].componyName == "JANTA RAJ EVENING" ||
                          componies[index].componyName ==
                              "JANTA RAJ AFTERNOON" ||
                          componies[index].componyName == "JANTA RAJ MORNING"  ||  componies[index].isCommingSoon) {
                        DateTime currentDateTime = DateTime.now();

                        if (!currentDateTime
                            .isAfter(componies[index].utcCloseTime)) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OneDayBids(routeData: {
                                'index': {
                                  "componie_name": componies[index].componyName,
                                  "d_5_m_id": componies[index].id,
                                  "s_time": componies[index].openTime,
                                  "c_s_time": "22:40:00",
                                  "utcOpenTime": componies[index].utcOpenTime,
                                  "utcCloseTime": componies[index].utcCloseTime,
                                  "is_winner_set": 0,
                                  "end_time": componies[index].closeTime,
                                  "c_end_time": "22:45:00",
                                  "win_no": {
                                    "open": componies[index].open,
                                    "close": componies[index].close,
                                    "openPatti": componies[index].openPatti,
                                    "closePatti": componies[index].closePatti
                                  },
                                  "game_date": componies[index].date,
                                  "inserted_date": "2021-04-20 00:00:02",
                                  "game_date_time": "2021-04-20 22:45:00",
                                  "test": "1618938900",
                                  "win_time": "2021-04-19 18:30:02",
                                  "is_result_set": 0,
                                  "set_win_no": null
                                },
                                'type': 'allGame'
                              }),
                            ),
                          );
                        } else {
                          Scaffold.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Sorry time has been exprired or not yet initialized")));
                        }
                        // List<String> oList =
                        //     componies[index].openTime.split("");
                        // int startTime = int.parse(oList[0].split(":")[0]);
                        // String startAmOrPm = oList[1];

                        // List<String> cList = data.split("");
                        // int currentTime = int.parse(cList[0].split(":")[0]);
                        // String currentAmOrPm = cList[1];

                        // List<String> eList = componies[index].endTime.split("");
                        // int endTime = int.parse(eList[0].split(":")[0]);
                        // String endAmOrPm = eList[1];

                      } else {
                        await Navigator.pushNamed(
                            context, CommingSoon.routeName);
                      }
                    }
                    TabScreen.updateAmount(context);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white70, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  componies[index].type,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                                Text(
                                  _netDate.toString(),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.black12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              componies[index].componyName != 'JANTA RAJ'
                                  ? Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 25,
                                        width: 80,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(40.0),
                                              bottomRight:
                                                  Radius.circular(40.0)),
                                        ),
                                        child: Text(
                                          componies[index].openTime,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  componies[index].componyName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              componies[index].componyName != 'JANTA RAJ'
                                  ? Expanded(
                                      flex: 1,
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
                                          componies[index].closeTime,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(5.0),
                                  bottomRight: Radius.circular(5.0)),
                              color: Colors.grey[100],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                componies[index].componyName == 'JANTA RAJ'
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: SizedBox(
                                          height: 20,
                                          width: 100,
                                          child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=> RateMaster()));
                                              },
                                              child: Text(
                                                'Rate Master',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 12),
                                              )),
                                        ),
                                        // child: Text(
                                        //   componies[index].componyName ==
                                        //           'JANTA RAJ'
                                        //       ? 'Rate:1×10=10 total ten digit'
                                        //       : '',
                                        //   style: TextStyle(
                                        //       color: Colors.red, fontSize: 12),
                                        // ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: SizedBox(
                                          height: 20,
                                          width: 65,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            // borderSide: BorderSide(
                                            //   color: Theme.of(context).primaryColor,
                                            // ),
                                            child: Text(
                                              'Chart',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 12),
                                            ),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GameChart({
                                                          "company_name":
                                                              componies[index]
                                                                  .componyName,
                                                          "company_id":
                                                              componies[index]
                                                                  .id,
                                                        })),
                                              );
                                              TabScreen.updateAmount(context);
                                            },
                                          ),
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: SizedBox(
                                    height: 20,
                                    width: 61,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      child: Text(
                                        'Play',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 12),
                                      ),
                                      onPressed: () async {
                                        if (componies[index].componyName ==
                                            'JANTA RAJ') {
                                          await Navigator.of(context).pushNamed(
                                              FiveMinGames.routeName);
                                        } else {
                                          // Navigator.of(context)
                                          //     .pushNamed(CommingSoon.routeName);
//                                      Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             Bids(routeData: <
//                                                                 String,
//                                                                 dynamic>{
//                                                           'index':
//                                                              {"d_5_m_id": 14385, "s_time": "10:40 pm", "c_s_time": "22:40:00", "is_winner_set": 0, "end_time": "10:45 pm",
// "c_end_time": "22:45:00", "win_no": null, "game_date": "2021-04-20", "inserted_date": "2021-04-20 00:00:02", "game_date_time": "2021-04-20 22:45:00",
// "test": "1618938900", "win_time": "2021-04-19 18:30:02", "is_result_set": 0, "set_win_no": null},
//                                                           'type': 'allGame'
//                                                         }),
//                                                       ),
//                                                     );
//

                                          if (componies[index].componyName ==
                                                  "JANTA RAJ NIGHT" ||
                                              componies[index].componyName ==
                                                  "JANTA RAJ EVENING" ||
                                              componies[index].componyName ==
                                                  "JANTA RAJ AFTERNOON" ||
                                              componies[index].componyName ==
                                                  "JANTA RAJ MORNING") {
                                            DateTime currentDateTime =
                                                DateTime.now();

                                            if (!currentDateTime.isAfter(
                                                componies[index]
                                                    .utcCloseTime)) {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OneDayBids(routeData: {
                                                    'index': {
                                                      "componie_name":
                                                          componies[index]
                                                              .componyName,
                                                      "utcOpenTime":
                                                          componies[index]
                                                              .utcOpenTime,
                                                      "utcCloseTime":
                                                          componies[index]
                                                              .utcCloseTime,
                                                      "d_5_m_id":
                                                          componies[index].id,
                                                      "s_time": componies[index]
                                                          .openTime,
                                                      "c_s_time": "22:40:00",
                                                      "is_winner_set": 0,
                                                      "end_time":
                                                          componies[index]
                                                              .closeTime,
                                                      "c_end_time": "22:45:00",
                                                      "win_no": {
                                                        "open": componies[index]
                                                            .open,
                                                        "close":
                                                            componies[index]
                                                                .close,
                                                        "openPatti":
                                                            componies[index]
                                                                .openPatti,
                                                        "closePatti":
                                                            componies[index]
                                                                .closePatti
                                                      },
                                                      "game_date":
                                                          componies[index].date,
                                                      "inserted_date":
                                                          "2021-04-20 00:00:02",
                                                      "game_date_time":
                                                          "2021-04-20 22:45:00",
                                                      "test": "1618938900",
                                                      "win_time":
                                                          "2021-04-19 18:30:02",
                                                      "is_result_set": 0,
                                                      "set_win_no": null
                                                    },
                                                    'type': 'allGame'
                                                  }),
                                                ),
                                              );
                                            } else {
                                              Scaffold.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Sorry time has been exprired or not yet initialized",
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            await Navigator.pushNamed(
                                                context, CommingSoon.routeName);
                                          }
                                        }
                                        TabScreen.updateAmount(context);
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
            itemCount: componies.length,
          );
  }
}
