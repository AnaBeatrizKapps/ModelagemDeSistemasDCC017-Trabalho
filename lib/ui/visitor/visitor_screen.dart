import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartdingdong/constants/app_themes.dart';
import 'package:smartdingdong/ui/qr_code_scanner/qr_code_scanner_screen.dart';
import 'package:smartdingdong/ui/widgets/touchable_opacity.dart';
import 'package:flutter_svg/svg.dart';

class VisitorScreen extends StatefulWidget {
  @override
  _VisitorScreenState createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  @override
  Widget build(BuildContext context) {
    var viewWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppThemes.lightBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Spacer(),
                    TouchableOpacity(
                      onTap: _presentLoginScreen,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 17,
                            color: AppThemes.lightPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                SvgPicture.asset(
                  'assets/images/ring_the_bell.svg',
                  width: viewWidth,
                ),
                Spacer(),
                Text(
                  "SmartDingDong",
                  style: TextStyle(
                      fontSize: 27,
                      color: AppThemes.lightPrimaryColor,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text("Row 2"),
                Spacer(),
                Text(
                  "Tocar Campainha",
                  style: TextStyle(fontSize: 15),
                ),
                Icon(
                  CupertinoIcons.arrow_down,
                  size: 19,
                ),
                SizedBox(height: 16),
                TouchableOpacity(
                  onTap: () {
                    scanQRCode(context);
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: new BoxDecoration(
                      color: AppThemes.lightPrimaryColor,
                      borderRadius: BorderRadius.circular(32.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 12,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Icon(
                      CupertinoIcons.qrcode_viewfinder,
                      size: 31,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void scanQRCode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScannerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _presentLoginScreen() {
    Navigator.pushNamed(context, '/signIn', arguments: {});
  }
}
