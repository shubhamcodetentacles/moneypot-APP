import 'dart:convert';

import 'package:moneypot/provider/apiCall.dart';

class WalletDetailsApi {
  getTransactionDetails(Map<String, dynamic> data) async {
    const String url = 'api/walletBetHistoryInfo';
    try {
      var response = await postData(url, jsonEncode(data), true);
        final wData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return wData;
      } else {
        return Future.error(wData['errors']);
      }
    } catch (e) {
     return Future.error("Couldn't fetch data");
    }
  }

  getRateMaster() async {
    const String url = 'api/rateMaster';
    try {
      var response = await postData(url, jsonEncode({}), true);
        final wData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return wData;
      } else {
        return Future.error(wData['errors']);
      }
    } catch (e) {
     return Future.error("Couldn't fetch data");
    }
  }
}
