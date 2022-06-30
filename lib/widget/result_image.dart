// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class ResultImage extends StatefulWidget {
  final String resultNo;
  ResultImage(this.resultNo);

  @override
  _ResultImageState createState() => _ResultImageState();
}

class _ResultImageState extends State<ResultImage>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  bool _showResult = false;
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
      value: 0.1,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceInOut,
    );
    _controller.forward();
    showAnimation(1);
    hideAnimation(3);
  }

  Future showAnimation(sec) async {
    await Future.delayed(Duration(seconds: sec));
    setState(() {
      _showResult = true;
    });
  }

  Future hideAnimation(sec) async {
    await Future.delayed(Duration(seconds: sec));
    setState(() {
      _showResult = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
              height: 200,
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !_showResult
                      ? Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).accentColor,
                          ),
                          child: Center(
                            child: Text(widget.resultNo,
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor)),
                          ),
                        )
                      : ScaleTransition(
                          scale: _animation,
                          child: Container(
                              height: 148,
                              width: 148,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).accentColor,
                              ),
                              child: Center(
                                child: Text(
                                  widget.resultNo != null
                                      ? widget.resultNo
                                      : '-',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 120,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ))),
                ],
              ));
        });
  }
}
