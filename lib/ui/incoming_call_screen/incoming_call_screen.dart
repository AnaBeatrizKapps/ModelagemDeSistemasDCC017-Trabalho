import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:smartdingdong/models/call_model.dart';
import 'package:smartdingdong/services/firestore_database.dart';
import 'package:smartdingdong/ui/widgets/touchable_opacity.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallModel callObject;
  IncomingCallScreen({Key key, @required this.callObject}) : super(key: key);
  @override
  _IncomingCallScreen createState() => _IncomingCallScreen();
}

class _IncomingCallScreen extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  AnimationController _controller;
  bool _cancellingCall = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF47171),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(bottom: 16),
          child: Center(
            child: Column(
              children: [
                Spacer(),
                _buildRipple(),
                SizedBox(height: 25),
                Text(
                  "${widget.callObject.outgoingUser['name']} está na sua porta...",
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                _cancellingCall == true
                    ? Text(
                        "Finalizando Chamanda...",
                        style: TextStyle(
                          fontSize: 17,
                          color: _cancellingCall
                              ? Colors.red
                              : Colors.black.withOpacity(0.5),
                        ),
                      )
                    : SizedBox(),
                Spacer(),
                Builder(
                  builder: (context) {
                    final GlobalKey<SlideActionState> _key = GlobalKey();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SlideAction(
                        onSubmit: () {
                          _acceptCall();
                        },
                        key: _key,
                        child: Text(
                          "Arraste para confirmar",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        outerColor: Colors.black.withOpacity(0.15),
                        elevation: 0,
                        sliderButtonIcon: Icon(
                          CupertinoIcons.chevron_right,
                          color: Color(0xFFF47171),
                        ),
                        sliderButtonIconSize: 27,
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                TouchableOpacity(
                  onTap: () {
                    _declineCall();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Recusar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
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

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(1 - _controller.value),
      ),
    );
  }

  Future<void> _acceptCall() async {
    try {
      // accepted = 0
      // declined = 1
      await widget.callObject.reference.update({'status': 0});
      await widget.callObject.reference.delete();
      await createHistoryItem(0);
    } catch (error) {
      print(error);
    }
  }

  Future<void> _declineCall() async {
    setState(() {
      _cancellingCall = true;
    });

    try {
      // accepted = 0
      // declined = 1
      await widget.callObject.reference.update({'status': 1});
      await widget.callObject.reference.delete();
      await createHistoryItem(1);
    } catch (error) {
      print(error);
    }
  }

  Future<dynamic> createHistoryItem(int status) async {
    try {
      Map<String, dynamic> data = {
        'createdAt': Timestamp.now(),
        'status': status,
      };

      widget.callObject.historyItemReference.update(data);

      return Future.value(null);
    } catch (error) {
      return Future.value(error);
    }
  }
}
