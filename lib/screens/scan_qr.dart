
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project2_app/constants.dart';
import 'package:project2_app/screens/app_home.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQr extends StatefulWidget {
  final Map data ;
  final String? locString ;

  const ScanQr({Key? key,required this.data, this.locString}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanQrState(data,locString);
}


class _ScanQrState extends State<ScanQr> {
  final Map data ;
  final String? locString ;
  ElevatedButton? elevatedButton ;
  Barcode? result;
  QRViewController? controller;
  late BuildContext context01;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  _ScanQrState(this.data,this.locString);

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }


  @override
  Widget build(BuildContext context) {
    context01=context;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(

              fit: BoxFit.contain,
              child: Directionality(textDirection: TextDirection.rtl,child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: KPrimaryColor
                            ),
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('روشن/خاموش کردن فلش گوشی',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600));
                              },
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: KPrimaryColor
                            ),
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'برعکس کردن دوربین',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600));
                                } else {
                                  return Text('در حال بارگذاری',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600));
                                }
                              },
                            )),
                      )
                    ],
                  ),
                ],
              ),),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      this.controller?.pauseCamera();
      sendreq1();
    });

  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> sendreq1()async {
    BaseOptions options = new BaseOptions(
      connectTimeout: 7000,
      receiveTimeout: 7000,
      baseUrl: "guard.poriazarei.ir",
    );
    Dio dio =Dio(options);
    Response response ;
    print(12);


    try{
      response = await dio.post("http://guard.poriazarei.ir/api/v1/guard/scan",data: {'_token':data['token'],'scanData':result?.code,'location':locString});
      print(13);
      if(response.data["data"]["status"].toString().contains("true")){
        // getShifts();
        showDialog(
            barrierDismissible: false,
            context: context, builder: (context)=> AlertDialog(
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
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("برگشت"),
            ),

          ],

        ));

      }
      else{
        showDialog(barrierDismissible: false,context: context, builder: (context)=> AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              Text(response.data['data']["message"],style: TextStyle(fontFamily: "IranSans",fontSize: 16),),
              Container(
                margin: EdgeInsets.only(left: 16),
                child: Icon(Icons.cancel_outlined,color: Colors.red,),
              ),

            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: KPrimaryColor,
              ),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("برگشت"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: KPrimaryColor,
              ),
              onPressed: (){
                Navigator.pop(context);
                this.controller?.resumeCamera();

              },
              child: Text("سعی مجدد"),
            ),

          ],
        ));
      }



    }on DioError catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(milliseconds: 3000),content: Text("نتوانستیم اطلاعات را بفرستیم.مجدد سعی کنید")));

    }
  }
}
