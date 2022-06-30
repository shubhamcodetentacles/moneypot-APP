// @dart=2.9
import 'package:flutter/material.dart';

class NumberAnimation extends StatefulWidget {
  @override
  _NumberAnimationState createState() => _NumberAnimationState();
}

class _NumberAnimationState extends State<NumberAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController1;
  Animation<int> _animation1;

  @override
  void initState() {
    super.initState();

    _animationController1 = new AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation1 = IntTween(begin: 9, end: 0).animate(
        CurvedAnimation(parent: _animationController1, curve: Curves.easeOut));
    _animationController1.repeat(period: Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _animationController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController1,
        builder: (context, child) {
          return Container(
              height: 200,
              width: 200,
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).accentColor,
                      ),
                      child: Center(
                          child: Text(
                        _animation1.value.toString(),
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: _animation1.value == 0
                                ? Colors.green[400]
                                : _animation1.value == 1
                                    ? Colors.purple
                                    : _animation1.value == 2
                                        ? Colors.red
                                        : _animation1.value == 3
                                            ? Colors.blue[400]
                                            : _animation1.value == 4
                                                ? Colors.red
                                                : _animation1.value == 5
                                                    ? Colors.orange[800]
                                                    : _animation1.value == 6
                                                        ? Colors
                                                            .greenAccent[700]
                                                        : _animation1.value == 7
                                                            ? Colors.blue[400]
                                                            : _animation1
                                                                        .value ==
                                                                    8
                                                                ? Colors.red
                                                                : Colors
                                                                    .blue[900]),
                      )))
                ],
              ));
        });
  }
}
