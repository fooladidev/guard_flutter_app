import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project2_app/components/background_prof.dart';
import 'package:project2_app/constants.dart';
import 'package:project2_app/screens/scan_qr.dart';
import 'package:location/location.dart';

class AppHome extends StatefulWidget {
  final Map data ;
  const AppHome({Key? key,required this.data}) : super(key: key);

  @override
  _AppHomeState createState() => _AppHomeState(data);
}

class _AppHomeState extends State<AppHome> with SingleTickerProviderStateMixin {
  final Map data ;
  late LocationData locationData ;
  List<dynamic>? shifts ;
  bool isSendBtnPressed =false;


  String? qrData;
  String? locString;

  _AppHomeState(this.data);


  Future<LocationData> getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {

      }
    }

    _locationData = await location.getLocation();
    setState(() {
      locationData=_locationData;
      locString=_locationData.latitude.toString()+","+_locationData.longitude.toString();

    });
    return _locationData ;
  }

  late AnimationController animationController;
  late Animation rotateAnim;


  @override
  initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    getShifts();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 500),
    );
    rotateAnim = Tween(begin: 0.0, end: -180.0).animate(animationController);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Scaffold(

      body: BackgroundProf(
          child: Directionality(textDirection: TextDirection.rtl,
            child:SingleChildScrollView(

              child:Column(

                children: [
                  Text("محیط کاربری",style: TextStyle(fontFamily:'IranSans',fontWeight: FontWeight.w600,fontSize: 22),),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.only(left: 10,top: 20,right: 25,bottom: 20),
                    height: 140.0,
                    width: size.width*0.82,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(

                            offset: const Offset(1.0, 1.0),
                            color: Colors.grey,
                            blurRadius: 5,
                            spreadRadius:0.6,
                          )
                        ]
                    ),
                    child: Scrollbar(
                      child: SingleChildScrollView(

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text("نام :  "+data['user']['name'],style:TextStyle(fontFamily: 'IranSans',fontSize: 18),),
                            Text("شماره موبایل :  "+data['user']['mobile'],style:TextStyle(fontFamily: 'IranSans',fontSize: 18),),
                            if(shifts!=null&&shifts?.length!=0)
                              Text("نام نیروگاه : "+ shifts?[0]['station'],style:TextStyle(fontFamily: 'IranSans',fontSize: 18))
                            else
                              Text("")
                          ],


                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top:4,bottom: 8,left: 18,right: 10),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text("موقعیت مکانی ",style: TextStyle(fontFamily:'IranSans',fontSize: 18)),
                            if(locString!=null)
                              Icon(Icons.check_circle_outline,color: Colors.lightGreen,)

                            else
                              Icon(Icons.cancel_outlined,color: Colors.red,)

                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top:4,bottom: 8,left: 10,right: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text("اسکن QR کد ",style: TextStyle(fontFamily:'IranSans',fontSize: 18)),
                            if(qrData!=null)
                              Icon(Icons.check_circle_outline,color: Colors.lightGreen,)
                            else
                              Icon(Icons.cancel_outlined,color: Colors.red,)
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: KPrimaryColor,
                          padding: EdgeInsets.symmetric(vertical: 6,horizontal: 25)
                      ),
                      onPressed: ()async {
                        String res= await Navigator.push(context, MaterialPageRoute(builder: (context)=>ScanQr()));
                        setState(() {
                          locString=locString;
                          qrData=res ;
                        });
                      },

                      child: Text("اسکن QR کد",style: TextStyle(fontSize: 16),),

                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: KPrimaryColor,
                          padding: EdgeInsets.symmetric(vertical: 6,horizontal: 25)
                      ),

                      onPressed: ()async {
                        if(!isSendBtnPressed){
                          if(qrData!=null){
                            sendreq1();
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("نتوانستیم کد را دریافت کنیم")));
                          }
                          setState(() {
                            isSendBtnPressed=!isSendBtnPressed ;
                          });
                          Timer(Duration(seconds: 10),(){
                            setState(() {
                              isSendBtnPressed=!isSendBtnPressed ;
                            });
                          });

                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("لطفا 10 ثانیه بعد امتحان کنید")));
                        }

                      },

                      child: Text("ارسال اطلاعات",style: TextStyle(fontSize: 16),),

                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10,top: 5),
                    child: Divider(
                      height: 2,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width*0.03),
                        child: Text("شیفت ها",style: TextStyle(fontFamily: "IranSans",fontSize: 18,fontWeight: FontWeight.w700),),
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width*0.03),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: KPrimaryColor,

                          ),
                          onPressed: (){
                            if(animationController.isCompleted){
                              animationController.reset();
                              animationController.forward();
                            }
                            animationController.forward();
                            getShifts();
                          },
                          child: Row(
                            children: [
                              Text("بروزرسانی شیفت ها ",style: TextStyle(fontFamily: "IranSans",fontSize: 16,color: Colors.white)),
                              AnimatedBuilder(
                                animation: animationController,
                                builder: (context,widget){
                                  return Transform.rotate(angle: rotateAnim.value,child: Icon(Icons.refresh,size: 16,color: Colors.white,),);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),

                  shifts!=null
                      ? shifts?.length==0
                      ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("شیفتی تعریف نشده ",style: TextStyle(fontFamily: "IranSans",fontSize: 16,fontWeight: FontWeight.w600),),
                  )
                      : Container(
                    child: ListView.builder(itemBuilder: (context,index){
                      Map map =  shifts?[index]['locations'];
                      String shift = shifts?[index]['shift'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: size.width*0.05),
                            child: Text("شیفت "+ shift + " ( "+  (shifts?[index]['shift_start']).toString() + "," + (shifts?[index]['shift_end']).toString() + " ) ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                          ),
                          ListView.builder(itemBuilder: (context,co1){
                            Map location = map.values.elementAt(co1) ;
                            return Container(

                              child: Row(
                                children: [
                                  Container(
                                    margin:EdgeInsets.symmetric(horizontal: size.width*0.07) ,
                                    width: size.width*0.4,
                                    child: Text(location['name'].toString()),
                                  ),
                                  if(location['is_done'])
                                    Icon(Icons.check_circle_outline,color: Colors.lightGreen,)
                                  else
                                    Icon(Icons.cancel_outlined,color: Colors.red,),
                                  Container(
                                    width:  size.width*0.3,
                                    margin:EdgeInsets.symmetric(horizontal: size.width*0.05) ,
                                    child: Text(location['time'].toString()),
                                  ),



                                ],
                              ),
                              margin: EdgeInsets.symmetric(vertical: 4),
                            );
                          },
                            itemCount: map.length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                        ],
                      );


                    },
                      itemCount: shifts?.length,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),

                    ),
                  )
                      :ElevatedButton(onPressed: (){getShifts();}, child: Text("تلاش مجدد",style: TextStyle(fontSize: 16,)),style: ElevatedButton.styleFrom(primary: KPrimaryColor),)




                ],
              ),
            ),
          )
      ),
    );
  }

  Future<void> sendreq1()async {
    BaseOptions options = new BaseOptions(
      connectTimeout: 7000,
      receiveTimeout: 7000,
      baseUrl: "guard.poriazarei.ir",
    );
    Dio dio =Dio(options);
    Response response ;

    try{
      response = await dio.post("http://guard.poriazarei.ir/api/v1/guard/scan",data: {'_token':data['token'],'scanData':qrData,'location':locString});
      if(response.data["data"]["status"].toString().contains("true")){
        getShifts();
        showDialog(context: context, builder: (context)=> AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              Text("عملیات موفقیت آمیز بود",style: TextStyle(fontFamily: "IranSans",fontSize: 16),),
              Container(
                margin: EdgeInsets.only(left: 7),
                child: Icon(Icons.check,color: Colors.lightGreen,),
              ),

            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: KPrimaryColor,
              ),
              onPressed: (){
                SystemNavigator.pop();
              },
              child: Text("خروج از برنامه"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: KPrimaryColor,
              ),
              onPressed: (){
                Navigator.pop(context);

              },
              child: Text("ادامه دادن"),
            ),
          ],
        ));

      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(milliseconds: 3000),content: Text(response.data['data']["message"])));
      }



    }on DioError catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(milliseconds: 3000),content: Text("نتوانستیم اطلاعات را بفرستیم.مجدد سعی کنید")));

    }
  }

  Future<void> getShifts() async {
    BaseOptions options = new BaseOptions(
      connectTimeout: 7000,
      receiveTimeout: 7000,
      baseUrl: "guard.poriazarei.ir",
    );
    Dio dio =Dio(options);
    Response response1  ;

    try{
      response1 = await dio.post("http://guard.poriazarei.ir/api/v1/guard/shifts",data: {'_token':data['token']});
      if(response1.data['statusCode'].toString() == "200"){
        setState(() {
          shifts=response1.data['data'];
        });

      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(milliseconds: 3000),content: Text("نتوانستیم شیفت ها را دریافت کنیم.مجدد سعی کنید")));

      }

    }on DioError catch(e){

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(milliseconds: 3000),content: Text("نتوانستیم شیفت ها را دریافت کنیم.مجدد سعی کنید")));


    }


  }
}
