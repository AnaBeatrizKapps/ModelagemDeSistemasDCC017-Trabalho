import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smartdingdong/ui/outgoing_call_screen/outgoing_call_screen.dart';
import 'package:smartdingdong/ui/widgets/touchable_opacity.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({Key key}) : super(key: key);
  @override
  _QRCodeScannerScreen createState() => _QRCodeScannerScreen();
}

class _QRCodeScannerScreen extends State<QRCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;

  @override
  void initState() {
    // _startCall(houseId: '0f7iYQWQolj55EUj5Bfk');
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                children: [
                  (result != null)
                      ? Text(
                          "Barcode Type: ${describeEnum(result.format)}\nData: ${result.code}")
                      : Text("Scan a Code"),
                  TouchableOpacity(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text("Close"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      setState(() {
        result = scanData;
      });
      _startCall(houseId: result.code);
    });
  }

  void _startCall({String houseId}) {
    Future.delayed(Duration.zero, () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OutgoingCallScreen(
            houseId: houseId,
          ),
          fullscreenDialog: true,
        ),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
