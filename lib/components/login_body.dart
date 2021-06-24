import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:project2_app/components/rounded_input_field.dart';
import 'package:project2_app/components/rounded_password_field.dart';
import 'package:project2_app/screens/app_home.dart';
import 'package:dio/dio.dart';

import 'background.dart';
import 'button_anim.dart';

class LoginBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>LoginBodyState();

}
class LoginBodyState extends State<LoginBody>  with SingleTickerProviderStateMixin{
  String password ="";
  late AnimationController _buttonController ;
  bool isLoginBtnPressed = false ;
  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(vsync: this,duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _buttonController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;


    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("صفحه ورود",style: TextStyle(fontFamily:'IranSans',fontWeight: FontWeight.w600,fontSize: 22),),
            Image.asset("assets/images/sec3.png",height: size.height*0.36,),
            RoundedPasswordField(
              onChanged: (value){
                password= value;

              },
            ),
            GestureDetector(
              onTap: () async {
                if(!isLoginBtnPressed){

                  _buttonController.animateTo(0.300);
                  setState(() {
                    isLoginBtnPressed = !isLoginBtnPressed;
                  });
                  sendreq();
                }
                else{

                }


              },
              child: ButtonAnim(controller:_buttonController ),
            ),

          ],
        ),
      ),);
  }

  Future<void> sendreq() async {
    BaseOptions options = new BaseOptions(
      connectTimeout: 7000,
      receiveTimeout: 7000,
      baseUrl: "guard.poriazarei.ir",
    );
    Dio dio =Dio(options);
    Response response ;

    try{
      response = await dio.post("http://guard.poriazarei.ir/api/v1/auth/login",data: {'password':password});
      if(response.data['statusCode'].toString()=="200"){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>AppHome(data: response.data['data'],)));

      }
      else{

        _buttonController.reverse();
        setState(() {
          isLoginBtnPressed = false ;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(milliseconds: 3000),content: Text("نتوانستیم اطلاعات کاربری شما را دریافت کنیم")));

      }

    }on DioError catch(e){

      _buttonController.reverse();
      setState(() {
        isLoginBtnPressed = false ;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(milliseconds: 3000),content: Text("نتوانستیم اطلاعات کاربری شما را دریافت کنیم")));



    }
  }
}

