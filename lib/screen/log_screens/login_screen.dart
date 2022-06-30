// @dart=2.9
import 'dart:convert';
import 'package:moneypot/main.dart';
import 'package:moneypot/models/user.dart';
import 'package:moneypot/provider/store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../models/login.dart';
import './change_password_screen.dart';
import '../tab_screens/tab_screen.dart';
import '../../provider/apiCall.dart';
import "package:http/http.dart" as http;

// ignore: use_key_in_widget_constructors
class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ignore: unnecessary_new
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _passwordFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _saveLogForm = Login(mobileNumber: null, password: '');
  bool _isHidden = true;
  bool _isLoginButtonVisible = true;
  User userData;
  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getLogo();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }
    _form.currentState.save();

    setState(() {
      _isLoginButtonVisible = false;
    });

    const String url = 'api/user_login';
    final data = jsonEncode(<String, dynamic>{
      'mobile_number': _saveLogForm.mobileNumber.toString(),
      'password': _saveLogForm.password,
    });

    final response = await postData(url, data, false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
       await sharedStore.openSession(data);
      } catch (e) {
        print(e);
      }
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('token', data['token']);
      // await prefs.setString('name', data['user_data']['user_name']);
      // await prefs.setString('email', data['user_data']['user_email']);
      // await prefs.setString('mobileNo', data['user_data']['mobile_number']);
      // await prefs.setString('walletAmount', data['user_data']['wallet_amount']);
      // await prefs.setString("appColor", data["user_data"]['color_code']);
      // await prefs.setString("font_color", data["user_data"]['font_color']);
      // await prefs.setBool('isLoggedIn', true);
      MyApp.setAppColor(context);

      setState(() {
        _isLoginButtonVisible = true;
      });

      Navigator.of(context)
          .pushNamedAndRemoveUntil(TabScreen.routeName, (route) => false);
    } else {
      setState(() {
        _isLoginButtonVisible = true;
      });
      final snackBar = SnackBar(
        content: Row(
          children: const [
            Icon(Icons.thumb_down),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Text(
                'Mobile Number or Password wrong',
              ),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<String> getLogo() async {
    try {
      http.Response response = await http.get(Uri.parse(baseAPI + "api/logo"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'APPKEY': 'money_pot_app_123'
          });
      if (response.statusCode == 200) {
        dynamic jsonData = json.decode(response.body);
        return jsonData["data"];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        // ignore: sized_box_for_whitespace
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 40,
              left: 40,
              top: 100,
            ),
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        FutureBuilder(
                            future: getLogo(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data == null) {
                                  return const Text("Logo Not Found");
                                }
                                return Image.network(
                                  snapshot.data,
                                  width: 250,
                                  height: 100,
                                  fit: BoxFit.contain,
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }),
                        Text(
                          '',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24.00,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Hi there! Nice to see you again!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Mobile No',
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please provide mobile no.';
                      }
                      if (value.length > 10 || value.length < 10) {
                        return 'Please enter valid mobile no.';
                      }

                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    onChanged: (newValue) {
                      _saveLogForm = Login(
                        mobileNumber: int.parse(newValue),
                        password: _saveLogForm.password,
                      );
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isHidden = !_isHidden;
                          });
                        },
                        child: _isHidden
                            ? const Icon(
                                Icons.remove_red_eye,
                                color: Colors.black38,
                              )
                            : const Icon(Icons.remove_red_eye,
                                color: Colors.pink),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    obscureText: _isHidden,
                    focusNode: _passwordFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please provide password';
                      }
                      if (value.length < 4) {
                        return 'Please provide 4 digit password';
                      }

                      return null;
                    },
                    onChanged: (newValue) {
                      _saveLogForm = Login(
                        mobileNumber: _saveLogForm.mobileNumber,
                        password: newValue,
                      );
                    },
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor),
                            onPressed: _isLoginButtonVisible ? _saveForm : null,
                            child: Text('Sign In',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 16)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(ChangePasswordScreen.routeName);
                              },
                              child: const Text(
                                'Forget Password?',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
