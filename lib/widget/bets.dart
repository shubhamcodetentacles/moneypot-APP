import 'package:flutter/material.dart';
import 'package:moneypot/widget/my_bids.dart';
import 'package:moneypot/widget/one_day_my_bids.dart';
class Bets extends StatefulWidget {
// final List<dynamic> fiveMinData; 
// final List<dynamic> dayData; 

// Bets(this.fiveMinData, this.dayData);

  @override
  _BetsState createState() => _BetsState();
}

class _BetsState extends State<Bets> {
    @override
  void initState() {
   
    super.initState();
  }
   
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              backgroundColor: Theme.of(context).accentColor,
              elevation: 0,
              bottom: TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                tabs: [
                  Tab(
                    text: "5 Min Game",
                  ),
                  Tab(
                    text: "Day Game",
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              
              MyBids(),
              OneDayMyBids(),
              ],
          ),
        ),
      ),
    );
  }
}