// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moneypot/provider/apiCall.dart';
import 'package:moneypot/screen/error_screens/autoLogOut.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './login_screen.dart';
import '../../models/change_password.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = '/change-password';
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formCP = GlobalKey<FormState>();
  final _mobileForm = GlobalKey<FormState>();
  final _otpForm = GlobalKey<FormState>();
  var _saveChangePassForm = Changepassword(exPassword: '', newPassword: '');
  bool _isOldPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  final _mobileNumber = TextEditingController();
  final _otp = TextEditingController();
  bool _isMobileFormOn = true;
  bool _isOTPFormOn = false;
  bool _isPasswordFormOn = false;

  @override
  void initState() {
    _isMobileFormOn = true;
    _isOTPFormOn = false;
    _isPasswordFormOn = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _saveCPForm() async {
    final isValid = _formCP.currentState.validate();
    if (!isValid) {
      return;
    }
    _formCP.currentState.save();
    final String url = 'api/set_new_password';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(<String, dynamic>{
      'token': prefs.getString('token'),
      'new_password': _saveChangePassForm.newPassword,
      'confirm_password': _saveChangePassForm.exPassword,
    });

    final response = await postData(url, data, false);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      Navigator.of(context)
          .pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
    } else if (response.statusCode == 408) {
      AutoLogOut().popUpFor408(context);
    } else {
      final data = jsonDecode(response.body);
      
      final snackBar = SnackBar(
        content: Text(
          data['message'], textAlign: TextAlign.center,
          // style: TextStyle(color: Colors.red),
        ),
      );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _mobileNoSend() async {
    final isValid = _mobileForm.currentState.validate();
    if (!isValid) {
      return;
    }
    _mobileForm.currentState.save();

    final String url = 'api/forgot_password';
    final data = jsonEncode(<String, dynamic>{
      'mobile_number': _mobileNumber.text,
    });

    final response = await postData(url, data, false);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      setState(() {
        _isMobileFormOn = false;
        _isOTPFormOn = true;
        _isPasswordFormOn = false;
      });
    } else if (response.statusCode == 408) {
      AutoLogOut().popUpFor408(context);
    } else {
      final data = jsonDecode(response.body);
      final snackBar = SnackBar(
        content: Text(
          data['message'] == null ? 'Something went wrong' : data['message'],
          textAlign: TextAlign.center,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _sendOTP() async {
    final isValid = _otpForm.currentState.validate();
    if (!isValid) {
      return;
    }
    _otpForm.currentState.save();
    final String url = 'api/otp_forgot_password';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(<String, dynamic>{
      'token': prefs.getString('token'),
      'otp': _otp.text,
    });

    final response = await postData(url, data, false);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      setState(() {
        _isMobileFormOn = false;
        _isOTPFormOn = false;
        _isPasswordFormOn = true;
      });
    } else if (response.statusCode == 408) {
      AutoLogOut().popUpFor408(context);
    } else {
      final data = jsonDecode(response.body);
      final snackBar = SnackBar(
        content: Text(
          data['message'],
          textAlign: TextAlign.center,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.only(
              right: 40,
              left: 40,
              top: 100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/newLogo.jpg',
                        width: 250,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
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
                SizedBox(
                  height: 50,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 24.00,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Change password and confirm it by re-tying',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                _isMobileFormOn
                    ? Form(
                        key: _mobileForm,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _mobileNumber,
                              decoration: InputDecoration(
                                labelText: 'Mobile No',
                              ),
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
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                _isOTPFormOn
                    ? Form(
                        key: _otpForm,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _otp,
                              decoration: InputDecoration(
                                labelText: 'OTP',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please provide OTP.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                _isPasswordFormOn
                    ? Form(
                        key: _formCP,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isOldPasswordHidden =
                                          !_isOldPasswordHidden;
                                    });
                                  },
                                  child: _isOldPasswordHidden
                                      ? Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.black38,
                                        )
                                      : Icon(Icons.remove_red_eye,
                                          color: Colors.pink),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              obscureText: _isOldPasswordHidden,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please provide your new password.';
                                }
                                if (value.length < 4) {
                                  return 'Please provide 4 digit password';
                                }
                                return null;
                              },
                              onChanged: (newValue) {
                                _saveChangePassForm = Changepassword(
                                  exPassword: newValue,
                                  newPassword: _saveChangePassForm.newPassword,
                                );
                              },
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Confirm New Password',
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isNewPasswordHidden =
                                          !_isNewPasswordHidden;
                                    });
                                  },
                                  child: _isNewPasswordHidden
                                      ? Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.black38,
                                        )
                                      : Icon(Icons.remove_red_eye,
                                          color: Colors.pink),
                                ),
                              ),
                              obscureText: _isNewPasswordHidden,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please confirm your new password.';
                                }
                                if (value.length < 4) {
                                  return 'Please provide 4 digit password';
                                }
                                if (_saveChangePassForm.exPassword !=
                                    _saveChangePassForm.newPassword) {
                                  return 'Password not matched.';
                                }
                                return null;
                              },
                              onChanged: (newValue) {
                                _saveChangePassForm = Changepassword(
                                  exPassword: _saveChangePassForm.exPassword,
                                  newPassword: newValue,
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _isMobileFormOn
                          ? SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor),
                                onPressed: _mobileNoSend,
                                child: Text('Submit',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 16)),
                              ),
                            )
                          : SizedBox(),
                      _isOTPFormOn
                          ? SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor),
                                onPressed: _sendOTP,
                                child: Text('Submit',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 16)),
                              ),
                            )
                          : SizedBox(),
                      _isPasswordFormOn
                          ? SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor),
                                onPressed: _saveCPForm,
                                child: Text('Change',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 16)),
                              ),
                            )
                          : SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(LoginScreen.routeName);
                            },
                            child: Text(
                              'Login?',
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
    );
  }
}
