// @dart=2.9
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final String baseAPI = 'http://galaxyexch7.com/';
// final String baseAPI ='http://3.232.141.140/';
// http://54.89.139.190/api/get_bid_data
postData(url, data, tokenReq) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String finalUrl = baseAPI + url;
 
  var postData;
  if (tokenReq) {
    postData = jsonDecode(data);
    postData['token'] = prefs.getString('UserToken') ?? '';
    postData = jsonEncode(postData);

   
  } else {
    postData = data;
  }

  return await http.post(
    Uri.parse(finalUrl),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'APPKEY': 'money_pot_app_123'
    },
    body: postData,
  );
}
