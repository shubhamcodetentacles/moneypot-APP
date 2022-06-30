// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moneypot/models/wallet_amount.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/provider/store.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:moneypot/screen/log_screens/login_screen.dart';
import 'package:moneypot/screen/tab_screens/chart_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './home_screen.dart';
import './bids_screen.dart';
import './profile_screen.dart';
import 'result_screen.dart';
import '../../widget/wallet.dart';

class TabScreen extends StatefulWidget {
  static void updateAmount(BuildContext context) {
    _TabScreenState state = context.findAncestorStateOfType<_TabScreenState>();
    state.getWalletAmount();
  }

  final int selectedIndex;
  TabScreen({
    Key key,
    this.selectedIndex,
  }) : super(key: key);
  static const routeName = '/tabs';

  @override
  _TabScreenState createState() => _TabScreenState(
        selectedIndex: this.selectedIndex,
      );
}

class _TabScreenState extends State<TabScreen> {
  final List<Map<String, Object>> _pages = [
    {'page': HomeScreen(), 'title': 'Games'},
    {'page': BidsScreen(), 'title': 'Bets'},
    {'page': ResultScreen(), 'title': 'Results'},
    {'page': ChartScreen(), 'title': 'Charts'},
    {'page': ProfileScreen(), 'title': 'Profile'},
  ];

  String name = '', email = '', mNo = '';
  bool isRefreshingBalance = false;

  int selectedIndex;
  List bid = [];
  _TabScreenState({
    this.selectedIndex,
  });

  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      selectedIndex = null;
    });

    getWalletAmount();
  }

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Hello';
      email = prefs.getString('email') ?? '';
      mNo = prefs.getString('mobileNo') ?? '';
    });
  }

  getWalletAmount() async {
    final String url = 'api/get_user_wallet_amount';
    final data = jsonEncode({});

    try {
      var response = await postData(url, data, true);

      if (response.statusCode == 200) {
        final wData = jsonDecode(response.body);

        Provider.of<WalletAmount>(context, listen: false)
            .changeAmount(wData['wallet_amount']);
        Provider.of<WalletAmount>(context, listen: false)
            .changeExposureLimit(wData['exploser_limit'].toString());
      } else if (response.statusCode == 408) {
        AutoLogOut().popUpFor408(context);
      } else {
        final eData = jsonDecode(response.body);
      }
    } catch (e) {
      // print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getWalletAmount();
  }

  @override
  Widget build(BuildContext context) {
    final walletAmount = Provider.of<WalletAmount>(context);
    selectedIndex == 1
        ? _selectedPageIndex = selectedIndex
        : _selectedPageIndex = _selectedPageIndex;

    final appBar = AppBar(
      // toolbarHeight: 100,
      title: Text(_pages[_selectedPageIndex]['title']),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        Row(
          children: [
            Row(
              children: [
                Text(walletAmount.amount ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(
                    Icons.account_balance_wallet,
                    // color: Colors.white,
                  ),
                  onPressed: () {
                    
                    getWalletAmount();
                    Navigator.of(context).pushNamed(Wallet.routeName);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text(walletAmount.exposureLimit ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(
                    Icons.explicit_outlined,
                    // color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedPageIndex = 1;
                    });
                    // getWalletAmount();
                    // Navigator.of(context).pushNamed(Wallet.routeName);
                  },
                ),
              ],
            ),
            isRefreshingBalance
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      // color: Colors.white,
                    ),
                    onPressed: () async {
                      setState(() {
                        isRefreshingBalance = true;
                      });
                      await getWalletAmount();
                      setState(() {
                        isRefreshingBalance = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Latest wallet balance has been updated..."),
                        ),
                      );

                      // Navigator.of(context).pushNamed(Wallet.routeName);
                    },
                  )
          ],
        ),
      ],
    );

    final profileAppBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      bottom: PreferredSize(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.account_box,
              color: Theme.of(context).accentColor,
              size: 120,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      mNo,
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      email,
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.power_settings_new,
                    // color: Colors.white,
                  ),
                  onPressed: () async {
                    sharedStore.closeSession();
                    // SharedPreferences prefs =
                    //     await SharedPreferences.getInstance();
                    // await prefs.setString('token', '');
                    // await prefs.setString('name', '');
                    // await prefs.setString('email', '');
                    // await prefs.setString('mobileNo', '');
                    // await prefs.setString('walletAmount', '');
                    // await prefs.setBool('isLoggedIn', false);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        LoginScreen.routeName, (route) => false);
                  },
                )
              ],
            ),
          ],
        ),
        preferredSize: Size.fromHeight(64.0),
      ),
    );
    return Scaffold(
      appBar: _selectedPageIndex == 4 ? profileAppBar : appBar,
      body: Container(
        height:
            MediaQuery.of(context).size.height - appBar.preferredSize.height,
        child: _pages[_selectedPageIndex]['page'],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        // unselectedItemColor: Colors.white,
        // selectedItemColor: Theme.of(context).accentColor,
        currentIndex: widget.selectedIndex == 1
            ? _selectedPageIndex = 1
            : _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.home),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.games),
            label: 'Bets',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.flag),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.apps),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
