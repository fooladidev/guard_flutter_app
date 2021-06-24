
import 'package:flutter/material.dart';

class ButtonAnim extends StatelessWidget {

  final Animation<double> controller ;

  final Animation<double> buttonWidth ;

  ButtonAnim({required this.controller}):
      buttonWidth=Tween(begin: 200.0,end: 50.0).animate(CurvedAnimation(parent: controller,curve: Interval(0.0,0.300)));



  Widget animBuilder(BuildContext context , Widget? child){
    return
    Container(
      margin: EdgeInsets.only(bottom: 20,top: 20),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius:BorderRadius.all(Radius.circular(30))
      ),
      width: buttonWidth.value,
      height: 50,
      alignment: Alignment.center,

      child: buttonWidth.value > 110
      ? Text("ورود",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 18),)
      :CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white70),
      )
    );

  }

  @override
  Widget build(BuildContext context) {
    
    
    return AnimatedBuilder(
        animation: controller,
        builder: animBuilder);

  }

}