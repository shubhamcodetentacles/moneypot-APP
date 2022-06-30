// @dart=2.9
import 'package:flutter/material.dart';
import 'package:moneypot/main.dart';
import 'package:moneypot/provider/data.dart';

class AllPanna extends StatefulWidget {
  final String type;
  final bool isEndOpen;
  AllPanna(this.type, {this.isEndOpen = false});
  @override
  _AllPannaState createState() => _AllPannaState();
}

class _AllPannaState extends State<AllPanna> {
  List<Map<String, dynamic>> data;
  List cpData = [];
  String _gameTime = '';
  List<dynamic> selectedIndex = [];
  void _returnData(number, pattiType) {
    if (_gameTime == '') {
      _showOpenorCloseDialog();
    } else {
      final Map<String, dynamic> data = {
        "number": number,
        "type": widget.type,
        "patti_type": pattiType,
        "game_time": _gameTime
      };

      Navigator.pop(
        context,
        data,
      );
    }
  }

  getData() {
    setState(() {
      data = [];
    });
    if (widget.type == 'ARB Cut Panna') {
      // data = ABR_CUT_PANNA;
      for (int i = 0; i < ABR_CUT_PANNA.length; i++) {
        data.add({'number': ABR_CUT_PANNA[i], 'isSelected': true});
      }
    }
    if (widget.type == 'Running Panna') {
      // data = RUNNING_PANNA;
      for (int i = 0; i < RUNNING_PANNA.length; i++) {
        data.add({'number': RUNNING_PANNA[i], 'isSelected': true});
      }
    }

    if (widget.type == 'Aki Beki Running Panna') {
      // data = AKI_BEKI_RUNING_PANNA;
      for (int i = 0; i < AKI_BEKI_RUNING_PANNA.length; i++) {
        data.add({'number': AKI_BEKI_RUNING_PANNA[i], 'isSelected': true});
      }
    }
    if (widget.type == 'Aki Running Panna') {
      // data = AKI_RUNING_PANNA;
      for (int i = 0; i < AKI_RUNING_PANNA.length; i++) {
        data.add({'number': AKI_RUNING_PANNA[i], 'isSelected': true});
      }
    }
    if (widget.type == 'Beki Running Panna') {
      // data = BEKI_RUNING_PANNA;
      for (int i = 0; i < BEKI_RUNING_PANNA.length; i++) {
        data.add({'number': BEKI_RUNING_PANNA[i], 'isSelected': true});
      }
    }
    if (widget.type == 'Aki Beki Panna') {
      // data = AKI_BEKI_PANNA;
      for (int i = 0; i < AKI_BEKI_PANNA.length; i++) {
        data.add({'number': AKI_BEKI_PANNA[i], 'isSelected': true});
      }
    }
    if (widget.type == 'Aki Panna') {
      // data = AKI_PANNA;
      for (int i = 0; i < AKI_PANNA.length; i++) {
        data.add({'number': AKI_PANNA[i], 'isSelected': true});
      }
    }
    if (widget.type == 'Beki Panna') {
      // data = BEKI_PANNA;
      for (int i = 0; i < BEKI_PANNA.length; i++) {
        data.add({'number': BEKI_PANNA[i], 'isSelected': true});
      }
    }
    if (widget.type == 'CP') {
      for (int i = 0; i < CP_PATTI.length; i++) {
        data.add({'number': CP_PATTI[i].number, 'isSelected': false});
        // data.add(CP_PATTI[i].number);
      }
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(widget.type == 'CP' ? 'Choose One CP' : widget.type),
      backgroundColor: Theme.of(context).primaryColor,
    );
    return Scaffold(
      appBar: appBar,
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              'Choose One Type',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _gameTime != 'O'
                    ? OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Theme.of(context).primaryColor,
                              style: BorderStyle.solid,
                              width: 1),
                          primary: Theme.of(context).primaryColor,
                        ),
                        child: Text('Open',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        onPressed: widget.isEndOpen
                            ? (){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(openBidMessage)));
                            }
                            : () {
                                setState(() {
                                  _gameTime = 'O';
                                });
                              },
                      )
                    : ElevatedButton(
                        child: Text('Open',
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        onPressed: () {
                          setState(() {
                            _gameTime = 'O';
                          });
                        },
                      ),
                _gameTime != 'C'
                    ? OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Theme.of(context).primaryColor,
                              style: BorderStyle.solid,
                              width: 1),
                          primary: Theme.of(context).primaryColor,
                        ),
                        child: Text('Close',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        onPressed: () {
                          setState(() {
                            _gameTime = 'C';
                          });
                        },
                      )
                    : ElevatedButton(
                        child: Text('Close',
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        onPressed: () {
                          setState(() {
                            _gameTime = 'C';
                          });
                        },
                      ),
              ],
            ),
            const Divider(),
            Expanded(
              child: GridView.count(
                crossAxisCount: widget.type == 'CP' ? 4 : 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 2.5,
                children: List.generate(data.length, (index) {
                  return
                      // selectedIndex.length==0 || selectedIndex[index]!=index?
                      !data[index]['isSelected']
                          ? OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    style: BorderStyle.solid,
                                    width: 1),
                                primary: Theme.of(context).primaryColor,
                              ),
                              child: Text(data[index]['number'],
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor)),
                              onPressed: () {
                                setState(() {
                                  if (widget.type == 'CP') {
                                    selectedIndex.add(index);
                                    data[index]['isSelected'] = true;
                                    cpData.add(data[index]['number']);
                                  }
                                  // _gameTime='C';
                                });
                              },
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                padding: EdgeInsets.all(8.0),
                              ),
                              child: Text(
                                data[index]['number'],
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (widget.type == 'CP') {
                                    data[index]['isSelected'] = false;
                                    cpData.remove(data[index]['number']);
                                  }
                                });
                              },
                            );
                }),
              ),
            ),
            widget.type == 'CP'
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      padding: EdgeInsets.all(8.0),
                    ),
                    child: Text(
                      'Play',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    onPressed: () {
                      _returnData(cpData, widget.type);
                    },
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      padding: EdgeInsets.all(8.0),
                    ),
                    child: Text(
                      'Play All',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    onPressed: () {
                      _returnData(widget.type, widget.type);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOpenorCloseDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Wrong Format',style: TextStyle(
          //                     color: Theme.of(context).primaryColor,
          //                     fontWeight: FontWeight.bold,)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please Select Open or Close',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
