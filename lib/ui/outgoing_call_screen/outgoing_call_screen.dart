import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartdingdong/constants/app_themes.dart';
import 'package:smartdingdong/models/call_model.dart';
import 'package:smartdingdong/models/history_item_model.dart';
import 'package:smartdingdong/services/firestore_database.dart';
import 'package:smartdingdong/ui/call_status/call_status_screen.dart';
import 'package:smartdingdong/ui/visitor/visitor_screen.dart';
import 'package:smartdingdong/ui/widgets/touchable_opacity.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String houseId;
  OutgoingCallScreen({Key key, @required this.houseId}) : super(key: key);

  @override
  _OutgoingCallScreen createState() => _OutgoingCallScreen();
}

class _OutgoingCallScreen extends State<OutgoingCallScreen>
    with TickerProviderStateMixin {
  AnimationController _controller;
  CallModel _callObject;
  bool _cancellingCall = false;
  Timer _timer;
  int _seconds = 10;

  String status;

  @override
  void initState() {
    _startCall(context);

    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(seconds: 3),
    )..repeat();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: _callObject != null
          ? firestore
              .collection('calls')
              .where(FieldPath.documentId, isEqualTo: _callObject.reference)
              .snapshots(includeMetadataChanges: false)
          : null,
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
        if (querySnapshot.hasData) {
          querySnapshot.data.docChanges.forEach((change) {
            switch (change.type) {
              case DocumentChangeType.modified:
                final callStatus = change.doc.data()['status'];
                if (callStatus != null) {
                  switch (callStatus) {
                    case 0:
                      _presentCallStatus(context, CallStatus.accepted);
                      break;
                    case 1:
                      _presentCallStatus(context, CallStatus.declined);
                      break;
                    default:
                      break;
                  }
                }
                break;
              // case DocumentChangeType.removed:
              //   print("REMOVED");
              //   _closeCall(context);
              //   break;
              default:
                break;
            }
          });
        }

        return Scaffold(
          backgroundColor: AppThemes.lightBackgroundColor,
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Spacer(),
                    _buildRipple(),
                    SizedBox(height: 25),
                    _buildUsernameText(),
                    SizedBox(height: 8),
                    Text(
                      _cancellingCall == true
                          ? "Finalizando Chamanda..."
                          : _callObject != null
                              ? "Chamando..."
                              : "Conectando...",
                      style: TextStyle(
                        fontSize: 17,
                        color: _cancellingCall
                            ? Colors.red
                            : Colors.black.withOpacity(0.5),
                      ),
                    ),
                    Spacer(),
                    TouchableOpacity(
                      onTap: () {
                        _cancelCall(context);
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
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
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
      },
    );
  }

  Widget _buildRipple() {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
      builder: (context, child) {
        return Container(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildContainer(180 * _controller.value),
              _buildContainer(230 * _controller.value),
              _buildContainer(280 * _controller.value),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/user_profile.png',
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsernameText() {
    return _callObject != null
        ? Text(
            "Chamando a atenção de ${_callObject.incomingUser['name']}",
            style: TextStyle(
              fontSize: 21,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          )
        : SizedBox();
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppThemes.lightPrimaryColor.withOpacity(1 - _controller.value),
      ),
    );
  }

  void _startCall(BuildContext context) async {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    try {
      final result =
          await firestoreDatabase.makeCallToHouse(id: widget.houseId);
      print(result.reference.id);

      setState(() {
        _callObject = result;
      });

      _startTimer(context);
    } catch (error) {
      print(error);
    }
  }

  void _startTimer(BuildContext context) {
    const oneSecond = Duration(seconds: 1);
    _timer = new Timer.periodic(oneSecond, (Timer timer) {
      if (_seconds == 0) {
        stopTimer(timer);
        // _cancelCall(context);
        _missedCall(context);
      } else {
        setState(() {
          _seconds--;
        });
        print(_seconds);
      }
    });
  }

  void stopTimer(Timer timer) {
    setState(() {
      timer.cancel();
    });
  }

  void _closeCall(BuildContext context) {
    Future.delayed(Duration.zero, () {
      final nav = Navigator.of(context);
      nav.pop();
      nav.pop();
    });
  }

  void _presentCallStatus(BuildContext context, CallStatus status) {
    _timer.cancel();

    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallStatusScreen(
            call: _callObject,
            callStatus: status,
          ),
        ),
      );
    });
  }

  void _missedCall(BuildContext context) async {
    stopTimer(_timer);
    setState(() {
      _cancellingCall = true;
    });

    try {
      await _callObject.reference.update({
        'status': 2,
      });
      await _callObject.reference.delete();
      await createHistoryItem();

      _presentCallStatus(context, CallStatus.missed);
    } catch (error) {
      print(error);
    }
  }

  void _cancelCall(BuildContext context) async {
    stopTimer(_timer);
    setState(() {
      _cancellingCall = true;
    });

    try {
      await _callObject.reference.update({
        'status': 2,
      });
      await _callObject.reference.delete();
      await createHistoryItem();

      _closeCall(context);
    } catch (error) {
      print(error);
    }
  }

  Future<dynamic> createHistoryItem() async {
    try {
      Map<String, dynamic> data = {
        'createdAt': Timestamp.now(),
        'status': 2,
        // 'message': message,
      };

      _callObject.historyItemReference.update(data);

      return Future.value(null);
    } catch (error) {
      return Future.value(error);
    }
  }
}
