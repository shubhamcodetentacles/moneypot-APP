import 'package:flutter/material.dart';
import 'package:moneypot/provider/wallet_details.dart';

class RateMaster extends StatefulWidget {
  RateMaster({Key? key}) : super(key: key);

  @override
  State<RateMaster> createState() => _RateMasterState();
}

class _RateMasterState extends State<RateMaster> {
  WalletDetailsApi walletDetailsApi = WalletDetailsApi();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "Rate Master",
          ),
        ),
        body: FutureBuilder(
          future: walletDetailsApi.getRateMaster(),
          builder: (context, snap) {
            if (snap.hasData) {
            List<dynamic> apiData = (snap.data as Map)['rate_master'];
              return Column(
                children: [
                  Container(
                    color: Colors.orange[50],
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text("S.NO",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                            flex: 2,
                            child: Text("Game Name",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                            flex: 2,
                            child: Text("Bid Amount",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                            flex: 2,
                            child: Text("Win Amount",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                              // color: Colors.orange[50],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${index + 1}",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${apiData[index]['game_name']}",
                                      textAlign: TextAlign.left,
                                      // maxLines: 1,

                                      style: const TextStyle(
                                          // overflow: TextOverflow.ellipsis,
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${apiData[index]['bid_amount']}",
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${apiData[index]['win_amount']}",
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ));
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            height: 0,
                          );
                        },
                        itemCount: apiData.length),
                  )
                ],
              );
            }
            if (snap.hasError) {
              return Center(
                child: Text(
                  snap.error.toString(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          },
        ));
  }
}
