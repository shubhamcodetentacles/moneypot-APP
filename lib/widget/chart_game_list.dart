// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/provider/data.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/widget/game_chart.dart';

class ChartGameList extends StatefulWidget {
  @override
  _ChartGameListState createState() => _ChartGameListState();
}

class _ChartGameListState extends State<ChartGameList> {
  List componies;
  bool _isLoader = false;
  getCompaniesList() async {
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
      componies = companyList['company_list'];
     
    } else if (response.statusCode == 408) {
      setState(() {
        _isLoader = false;
      });
      AutoLogOut().popUpFor408(context);
    } else {
      setState(() {
        _isLoader = false;
      });
      final data = jsonDecode(response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    getCompaniesList();
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
            itemCount: componies.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  componies[index]['company_name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  componies[index]['open_time'] +
                      ' - ' +
                      componies[index]['close_time'],
                  style: TextStyle(),
                ),
                tileColor: index % 2 == 0 ? Colors.grey[200] : Colors.grey[300],
                trailing: Icon(
                  Icons.double_arrow,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameChart({
                              "company_name": componies[index]['company_name'],
                              "company_id": componies[index]['company_id'],
                            })),
                  );
                },
              );
            },
          );
  }
}
