import 'dart:convert';
import "dart:developer" as dev;
import 'package:flutter/material.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';

class DayIndex {
  late int index;
  late String day;
  String id;
  DayIndex(this.index, this.day, this.id);
}

class GameChart extends StatefulWidget {
  final Map<String, dynamic> companyData;
  GameChart(this.companyData);
  @override
  _GameChartState createState() => _GameChartState();
}

class _GameChartState extends State<GameChart> {
  bool _isLoader = false;
  List<dynamic> chartData = [];
  List<dynamic> getData = [];

  List<DayIndex> dayIndex = [
    DayIndex(0, "DATE", "Date"),
    DayIndex(1, "MON", "Mon"),
    DayIndex(2, "TUE", "Tue"),
    DayIndex(3, "WED", "Wed"),
    DayIndex(4, "THU", 'Thu'),
    DayIndex(5, "FRI", "Fri"),
    DayIndex(6, "SAT", "Sat"),
  ];

  int tue = 2;

  dataManipulation() async {
    const String url = 'api/pana_game_chart';
    final data = jsonEncode(
        <String, dynamic>{"company_id": widget.companyData['company_id']});
    setState(() {
      _isLoader = true;
    });
    try {
      var response = await postData(url, data, true);
      if (response.statusCode == 200) {
        final grData = jsonDecode(response.body);
        // dev.log()
        getData = grData['pana_game_chart'];

        setState(() {
          for (int i = 0; i < getData.length; i++) {
            List dummy = [];
            List date = (getData[i]['date']).split(' ');
            dummy.add({
              "o": date[0],
              "d": date[1],
              "c": date[2],
              "isdate": true,
              "date_index": 0
            });
            for (int j = 0; j < getData[i]['data'].length; j++) {
              List openPatti = (getData[i]['data'][j]['openPatti']).split('');
              List closePatti = (getData[i]['data'][j]['closePatti']).split('');

              dummy.add({
                "o": openPatti,
                "d": getData[i]['data'][j]['jodi'],
                "c": closePatti,
                "isdate": false,
                "day": getData[i]['data'][j]['day'],
                "date_index": getData[i]['data'][j]['index']
              });
            }

            for (int l = 1; l < 6; l++) {
              dummy.firstWhere((element) => element["date_index"] == l,
                  orElse: () {
                dummy.insert(l, {
                  "o": null,
                  "d": null,
                  "c": null,
                  "isdate": false,
                  "day": null,
                  "date_index": null
                });
              });
            }

            chartData.add({"data": dummy});
          }
          _isLoader = false;
        });
      } else if (response.statusCode == 408) {
        setState(() {
          _isLoader = false;
        });
        AutoLogOut().popUpFor408(context);
      } else {
        setState(() {
          _isLoader = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoader = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dataManipulation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.companyData['company_name'] + ' CHART'),
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
                GridView.count(
                    primary: false,
                    shrinkWrap: true,
                    crossAxisCount: 7,
                    childAspectRatio: 4 / 2.5,
                    children: dayIndex
                        .map((e) => Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                e.day,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor),
                              ),
                              color: Colors.grey[200],
                            ))
                        .toList()),
                Expanded(
                  child: ListView.builder(
                    itemCount: chartData.length,
                    itemBuilder: (context, index) {
                      return GridView.count(
                        primary: false,
                        shrinkWrap: true,
                        crossAxisCount: 7,
                        children:
                            List.generate(chartData[index]['data'].length, (i) {
                          if (chartData[index]['data'][i]['date_index'] == null) {
                            return const SizedBox();
                          }
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      chartData[index]['data'][i]['isdate']
                                          ? chartData[index]['data'][i]['o']
                                          : chartData[index]['data'][i]['o'][0],
                                      style: chartData[index]['data'][i]
                                              ['isdate']
                                          ? const TextStyle(fontSize: 10)
                                          : const TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      chartData[index]['data'][i]['isdate']
                                          ? chartData[index]['data'][i]['d']
                                          : chartData[index]['data'][i]['o'][1],
                                      style: chartData[index]['data'][i]
                                              ['isdate']
                                          ? const TextStyle(fontSize: 10)
                                          : const TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      chartData[index]['data'][i]['isdate']
                                          ? chartData[index]['data'][i]['c']
                                          : chartData[index]['data'][i]['o'][2],
                                      style: chartData[index]['data'][i]
                                              ['isdate']
                                          ? const TextStyle(fontSize: 10)
                                          : const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                                !chartData[index]['data'][i]['isdate']
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            chartData[index]['data'][i]['d'],
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                !chartData[index]['data'][i]['isdate']
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            chartData[index]['data'][i]['c'][0],
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                          Text(
                                            chartData[index]['data'][i]['c'][1],
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                          Text(
                                            chartData[index]['data'][i]['c'][2],
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          );
                        }),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
