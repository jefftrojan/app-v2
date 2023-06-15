import 'dart:async';
import 'dart:ui' as ui;

import 'package:app/src/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class ProductQRCode extends StatefulWidget {
  Product product;

  ProductQRCode({Key? key, required this.product}) : super(key: key);
  @override
  _ProductQRCodeState createState() => _ProductQRCodeState();
}

class _ProductQRCodeState extends State<ProductQRCode> {
  late Uint8List _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  @override
  initState() {
    super.initState();
    _requestPermission();
  }

  _saved(Uint8List imageFile) async {
    final result = await ImageGallerySaver.saveImage(imageFile);
    print("File Saved to Gallery");
    const snackBar = SnackBar(
      content: Text(
        'QR code saved to your gallery',
        textAlign: ui.TextAlign.center,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    // _toastInfo(info);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    final qrFutureBuilder = FutureBuilder<ui.Image>(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        final size = 280.0;
        if (!snapshot.hasData) {
          return Container(width: size, height: size);
        }
        return CustomPaint(
          size: Size.square(size),
          painter: QrPainter(
            data: widget.product.token,
            version: QrVersions.auto,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xff128760),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: Color(0xff1a5441),
            ),
            embeddedImage: snapshot.data,
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: const Size.square(60),
            ),
          ),
        );
      },
    );
    return Scaffold(
      body: MaterialApp(
        title: 'QR.Flutter',
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Material(
          color: Colors.white,
          child: SafeArea(
            top: true,
            bottom: true,
            child: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Screenshot(
                        controller: screenshotController,
                        child: Container(
                          width: 280,
                          child: qrFutureBuilder,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 20, horizontal: 40)
                            .copyWith(bottom: 40),
                    child: Column(
                      children: [
                        Text("Name: ${widget.product.name}"),
                        Text("Shebas: ${widget.product.points}"),
                        Text("Price: ${widget.product.price}")
                      ],
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        screenshotController
                            .capture(delay: Duration(milliseconds: 10))
                            .then((capturedImage) async {
                          print(capturedImage!);
                          setState(() {
                            _imageFile = capturedImage;
                          });

                          await _saved(_imageFile);
                        }).catchError((onError) {
                          print(onError);
                        });
                      },
                      child: const Text('Download the Code')),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).primaryColor,
                      )),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load('assets/sheba_logo.png');
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }
}
