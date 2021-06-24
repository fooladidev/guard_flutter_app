
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project2_app/constants.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQr extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

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

                  if (result != null)
                    Column(
                      children: [
                        Text("QR کد اسکن شد",style: TextStyle(fontSize: 20,fontFamily: 'IranSans',fontWeight: FontWeight.w800),),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 5,right: 5),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: KPrimaryColor
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context,result?.code);
                                  }, child:Text("ادامه دادن",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600)) ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5,right: 5),
                              child:ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: KPrimaryColor
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      result=null;
                                    });
                                  }, child:Text("اسکن مجدد",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600)) ),
                            )

                          ],
                        )
                      ],
                    )

                  else
                    Text('لطفا کد QR را اسکن کنید',style: TextStyle(fontSize: 20,fontFamily: 'IranSans',fontWeight: FontWeight.w800)),
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
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
