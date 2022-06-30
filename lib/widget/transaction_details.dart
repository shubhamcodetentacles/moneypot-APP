import 'package:flutter/material.dart';
import 'package:moneypot/provider/wallet_details.dart';

class TransactionDetails extends StatefulWidget {
  dynamic transactionData;
  TransactionDetails({this.transactionData, Key? key}) : super(key: key);

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  final WalletDetailsApi _walletDetailsApi = WalletDetailsApi();
  late Map<String, dynamic> data;
  @override
  void initState() {
    super.initState();
    data = {
      "bid_id": widget.transactionData['bid_id'],
      "is_pana_game": widget.transactionData["is_pana_game"]
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Transaction Details"),
        ),
        body: FutureBuilder(
          future: _walletDetailsApi.getTransactionDetails(data),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> apiData =
                  (snapshot.data as Map<String, dynamic>);

              return Stack(
                fit: StackFit.expand,
                children: [

                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Game ID :",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text("${apiData['game_id']}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w300)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    const Text("Date:",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text("${apiData['date_time']}"),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          child: const Text(
                                            "Bet ID",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text("${apiData['bid_id']}",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800))
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          child: const Text(
                                            "Account Balance",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text("${apiData['account_balance']}",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800))
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        widget.transactionData['is_pana_game']
                            ? PanaTable(
                                fiveMinData: apiData['game'],
                              )
                            : FiveMinTable(
                                fiveMinData: apiData['game'],
                              ),
                        Container(
                          color: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 4),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Total",
                                  textAlign: TextAlign.start,
                                  style:  TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Expanded(
                                  child: Text(
                                "${apiData['bid_amount']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.end,
                              ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  
                  Positioned.fill(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: IntrinsicHeight(
                      child: Container(
                        
                        padding: const EdgeInsets.symmetric(vertical: 8 ),
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (apiData['is_winner'] == "0")
                              Column(
                                children: [
                                  Text(
                                    "SORRY!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    "Better Luck Next Time",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            if (apiData['is_winner'] == "1")
                              const Text(
                                "WIN!!!",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                              ),
                            apiData['new_w_amount'] == "null" ||
                                    apiData['new_w_amount'] == null
                                ? const SizedBox()
                                : const SizedBox(
                                    height: 15,
                                  ),
                            apiData['new_w_amount'] == "null" ||
                                    apiData['new_w_amount'] == null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: const Text(
                                                  "Old Balance Amount",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                "${apiData['previous_amount']}",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: const BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: const Text(
                                                  "Win Account Balance",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text("${apiData['new_w_amount']}",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800))
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
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

class PanaTable extends StatelessWidget {
  dynamic fiveMinData;
  PanaTable({
    this.fiveMinData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.orange[50],
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                  child: Text("Bid No",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600))),
              Expanded(
                  child: Text("Type",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600))),
              Expanded(
                  child: Text("Game Name",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600))),
              Expanded(
                  child: Text(
                "Amount",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.end,
              )),
            ],
          ),
        ),
        const Divider(
          height: 0,
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (fiveMinData as List).length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
              color: (fiveMinData as List)[index]['is_winner'] == "1"
                  ? Colors.greenAccent[100]
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${(fiveMinData as List)[index]['bid_number']}",
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (fiveMinData as List)[index]['is_open'] == 1
                          ? "O"
                          : (fiveMinData as List)[index]['is_open'] == 2
                              ? "C"
                              : "J",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${(fiveMinData as List)[index]['game_name']}",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    "${(fiveMinData as List)[index]['bid_amount']}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  )),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(
            height: 0,
          ),
        ),
      ],
    );
  }
}

class FiveMinTable extends StatelessWidget {
  List<dynamic> fiveMinData;
  FiveMinTable({
    required this.fiveMinData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.orange[50],
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                  child: Text("Bid No",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600))),
              Expanded(
                  child: Text(
                "Amount",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.end,
              )),
            ],
          ),
        ),
        const Divider(
          height: 0,
        ),
        ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                color: fiveMinData[index]['is_winner'] == "1"
                    ? Colors.greenAccent[100]
                    : Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${fiveMinData[index]['bid_number']}",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Expanded(
                        child: Text(
                      "${fiveMinData[index]['bid_amount']}",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.end,
                    )),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(
                  height: 0,
                ),
            itemCount: fiveMinData.length),
      ],
    );
  }
}
