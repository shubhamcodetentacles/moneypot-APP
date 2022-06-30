import 'package:flutter/material.dart';
import 'package:moneypot/provider/data.dart';

class AllCharts extends StatefulWidget {
  final String type;
  final String no;

  AllCharts(this.type, this.no);
  @override
  _AllChartsState createState() => _AllChartsState();
}

class _AllChartsState extends State<AllCharts> {
  List chartPanna = [];
  @override
  void initState() {
    _filterData();
    super.initState();
  }

  _filterData() {
    for (int i = 0; i < CHARTS.length; i++) {
      if (CHARTS[i].name == widget.type) {
        if (widget.no == '1') {
          chartPanna = CHARTS[i].one;
        } else if (widget.no == '2') {
          chartPanna = CHARTS[i].two;
        } else if (widget.no == '3') {
          chartPanna = CHARTS[i].three;
        } else if (widget.no == '4') {
          chartPanna = CHARTS[i].four;
        } else if (widget.no == '5') {
          chartPanna = CHARTS[i].five;
        } else if (widget.no == '6') {
          chartPanna = CHARTS[i].six;
        } else if (widget.no == '7') {
          chartPanna = CHARTS[i].seven;
        } else if (widget.no == '8') {
          chartPanna = CHARTS[i].eight;
        } else if (widget.no == '9') {
          chartPanna = CHARTS[i].nine;
        } else {
          chartPanna = CHARTS[i].zero;
        }
      }
    }
  }

  void _returnData(number, pattiType) {
    final Map<String, dynamic> data = {
      "number": number,
      "type": widget.type,
      "patti_type": pattiType
    };

    Navigator.pop(
      context,
      data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose One Panna'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 2.5,
                children: List.generate(chartPanna.length, (index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor,padding: EdgeInsets.all(8.0),),
                    child: Text(
                      chartPanna[index],
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    
                    onPressed: () {
// _returnData(chartPanna[index],widget.type);
                    },
                  );
                }),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor,padding: EdgeInsets.all(8.0),),
              child: Text(
                'Play All',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              
              onPressed: () {
                _returnData(chartPanna, widget.type);
              },
            ),
          ],
        ),
      ),
    );
  }
}
