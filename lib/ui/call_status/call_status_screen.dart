import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartdingdong/constants/app_themes.dart';
import 'package:smartdingdong/models/call_model.dart';
import 'package:smartdingdong/models/history_item_model.dart';
import 'package:smartdingdong/ui/widgets/touchable_opacity.dart';

class CallStatusScreen extends StatefulWidget {
  final CallModel call;
  final CallStatus callStatus;
  CallStatusScreen({
    Key key,
    @required this.call,
    @required this.callStatus,
  }) : super(key: key);

  @override
  _CallStatusScreen createState() => _CallStatusScreen();
}

class _CallStatusScreen extends State<CallStatusScreen> {
  TextEditingController _messageController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    var viewWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        TouchableOpacity(
                          onTap: () {
                            _close(context);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(),
                              color: Color(0xFFCBCBCB),
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer()
                  ],
                ),
              ),
              Column(
                children: [
                  Spacer(),
                  _buildIllustration(viewWidth),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _buildTextMessage(),
                      style: TextStyle(
                        fontSize: 21,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Spacer(),
                  widget.callStatus != CallStatus.accepted
                      ? Padding(
                          padding: EdgeInsets.all(16),
                          child: TouchableOpacity(
                            onTap: () {
                              _showMyDialog();
                            },
                            child: Text(
                              "Deixar uma mensagem...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppThemes.lightPrimaryColor,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deixe uma mensagem...'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Deixe uma mensagem para que o(s) moradore(s) visualizem assim que possível.'),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(hintText: 'Sua mensagem...'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Enviar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                saveMessage(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveMessage(BuildContext context) async {
    if (widget.callStatus == CallStatus.declined ||
        widget.callStatus == CallStatus.missed) {
      if (_messageController.text.isNotEmpty) {
        try {
          await widget.call.historyItemReference.update({
            'message': _messageController.text,
          });

          Navigator.of(context).pop();
          _close(context);
        } catch (error) {
          print(error);
        }
      }
    }
  }

  SvgPicture _buildIllustration(double viewWidth) {
    switch (widget.callStatus) {
      case CallStatus.accepted:
        return SvgPicture.asset(
          'assets/images/call_accepted.svg',
          width: viewWidth,
        );
      default:
        return SvgPicture.asset(
          'assets/images/call_missed.svg',
          width: viewWidth,
        );
    }
  }

  String _buildTextMessage() {
    switch (widget.callStatus) {
      case CallStatus.accepted:
        return '${widget.call.incomingUser['name']} está vindo te atender...';
      case CallStatus.declined:
        return 'Parece que não foi possível atender no momento...';
      case CallStatus.missed:
        return 'Parece que não há ninguém em casa...';
      default:
        return '';
    }
  }

  void _close(BuildContext context) {
    Future.delayed(Duration.zero, () {
      final nav = Navigator.of(context);
      nav.pop();
      nav.pop();
      nav.pop();
    });
  }
}
