import 'package:flutter/material.dart';
import 'package:moneypot/provider/data.dart';

class TouchPanna extends StatefulWidget {
  final String type;
  final String no;

  TouchPanna(this.type,this.no);
  @override
  _TouchPannaState createState() => _TouchPannaState();
}

class _TouchPannaState extends State<TouchPanna> {
   List touchPanna=[];
  @override
  void initState() {
    _filterData();
    super.initState();
  }

  _filterData(){
 


    for(int i=0; i<TOUCH_PANNA.length;i++){
      if(TOUCH_PANNA[i].number==widget.type){
    if(widget.no=='1'){
touchPanna=TOUCH_PANNA[i].one;
    }else if(widget.no=='2'){
touchPanna=TOUCH_PANNA[i].two;
    }else if(widget.no=='3'){
touchPanna=TOUCH_PANNA[i].three;
    }else if(widget.no=='4'){
touchPanna=TOUCH_PANNA[i].four;
    }else if(widget.no=='5'){
touchPanna=TOUCH_PANNA[i].five;
    }else if(widget.no=='6'){
touchPanna=TOUCH_PANNA[i].six;
    }else if(widget.no=='7'){
 touchPanna=TOUCH_PANNA[i].seven;
    }else if(widget.no=='8'){
touchPanna=TOUCH_PANNA[i].eight;
    }else if(widget.no=='9'){
touchPanna=TOUCH_PANNA[i].nine;
    }else{
touchPanna=TOUCH_PANNA[i].zero;
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
                            children: List.generate(touchPanna.length, (index) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor,padding: EdgeInsets.all(8.0),),
                                child: Text(
                                  touchPanna[index],
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                
                                onPressed: () {
// _returnData(touchPanna,widget.type);
                                },
                              );
                            }),),
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
_returnData(touchPanna,widget.type);
                              },
                            ),
                    ],
                  ),),
    );
  }
}