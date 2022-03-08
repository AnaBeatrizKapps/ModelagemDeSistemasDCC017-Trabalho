import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartdingdong/constants/app_themes.dart';
import 'package:smartdingdong/models/call_model.dart';
import 'package:smartdingdong/models/history_item_model.dart';
import 'package:smartdingdong/models/house_model.dart';
import 'package:smartdingdong/models/user_model.dart';
import 'package:smartdingdong/provider/auth_provider.dart';
import 'package:smartdingdong/services/firestore_database.dart';
import 'package:smartdingdong/ui/edit_house/edit_house_screen.dart';
import 'package:smartdingdong/ui/home/widgets/history_item_cell.dart';
import 'package:smartdingdong/ui/incoming_call_screen/incoming_call_screen.dart';
import 'package:smartdingdong/ui/qr_code_scanner/qr_code_scanner_screen.dart';
import 'package:smartdingdong/ui/user_profile/user_profile_screen.dart';
import 'package:smartdingdong/ui/widgets/touchable_opacity.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final double _btnQRCodeSize = 65;
  List<HouseModel> myHouses = [];
  HouseModel selectedHouse;

  @override
  void initState() {
    // TODO: implement initState
    _loadSelectedHouse();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var viewWidth = MediaQuery.of(context).size.width;
    var bottomMargin = MediaQuery.of(context).viewPadding.bottom;
    final authProvider = Provider.of<AuthProvider>(context);
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: true);

    return StreamBuilder(
      stream: authProvider.user,
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        final UserModel currentUser = snapshot.data;
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        final DocumentReference userReference =
            firestore.collection('accounts').doc(snapshot.data.uid);
        return StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('calls')
              .where('incoming', isEqualTo: userReference)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> querySnapshot) {
            if (querySnapshot.hasData) {
              querySnapshot.data.docChanges.forEach((change) {
                Map<String, dynamic> objectBody = change.doc.data();
                CallModel item =
                    CallModel.fromMap(objectBody, change.doc.reference);

                final DateTime now = DateTime.now();
                final secondsDifference =
                    now.difference(item.createdAt).inSeconds;
                switch (change.type) {
                  case DocumentChangeType.added:
                    print('added');
                    DocumentReference incomingReference =
                        objectBody['outgoing'];
                    firestoreDatabase.getUser(incomingReference).then((result) {
                      print('outgoingUser: $result');
                      if (result != null) {
                        item.outgoingUser = result;
                        if (item.incoming == userReference &&
                            secondsDifference <= 60) {
                          Future.delayed(Duration.zero, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IncomingCallScreen(
                                  callObject: item,
                                ),
                                fullscreenDialog: true,
                              ),
                            );
                          });
                        }
                      }
                    });
                    break;
                  case DocumentChangeType.modified:
                    break;
                  case DocumentChangeType.removed:
                    Navigator.pop(context);
                    break;
                }
              });
            }
            return StreamBuilder<List<HouseModel>>(
              // get history from selected house
              stream: firestoreDatabase.todosStream(),
              builder: (context, housesSnapshot) {
                myHouses = housesSnapshot.hasData ? housesSnapshot.data : [];
                return StreamBuilder<List<HistoryItemModel>>(
                  stream: firestoreDatabase.historyTeste(selectedHouse != null
                      ? selectedHouse.id
                      : myHouses[0] != null
                          ? myHouses[0].id
                          : null),
                  builder: (context, historySnapshot) {
                    List<HistoryItemModel> history =
                        historySnapshot.hasData ? historySnapshot.data : [];

                    return Scaffold(
                      // backgroundColor: AppThemes.lightBackgroundColor,
                      body: SafeArea(
                        bottom: false,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    top: 16,
                                    left: 16,
                                    right: 16,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Olá${currentUser != null && currentUser.displayName != null ? _userFirstName(currentUser.displayName) : ""}!",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          PopupMenuButton(
                                            itemBuilder: (context) {
                                              var list = List<
                                                  PopupMenuEntry<Object>>();
                                              list.add(
                                                PopupMenuItem(
                                                  child: Text("Editar Casa"),
                                                  value: -1,
                                                ),
                                              );
                                              list.add(
                                                PopupMenuDivider(
                                                  height: 10,
                                                ),
                                              );
                                              myHouses.asMap().forEach(
                                                    (index, house) => {
                                                      list.add(
                                                        CheckedPopupMenuItem(
                                                          child:
                                                              Text(house.name),
                                                          checked: selectedHouse ==
                                                                      null &&
                                                                  index == 0
                                                              ? true
                                                              : selectedHouse ==
                                                                  house,
                                                          value: index,
                                                        ),
                                                      ),
                                                    },
                                                  );
                                              return list;
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  selectedHouse != null
                                                      ? selectedHouse.name
                                                      : (myHouses[0] != null
                                                          ? myHouses[0].name
                                                          : "Criar Casa"),
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppThemes
                                                        .lightPrimaryColor,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  CupertinoIcons
                                                      .arrowtriangle_down_fill,
                                                  size: 17,
                                                  color: AppThemes
                                                      .lightPrimaryColor,
                                                ),
                                              ],
                                            ),
                                            offset: Offset(0, 50),
                                            onSelected: (value) {
                                              if (value == -1) {
                                                editHouse(
                                                  house: selectedHouse != null
                                                      ? selectedHouse
                                                      : myHouses[0],
                                                );
                                              } else {
                                                _selectHouse(myHouses[value]);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      TouchableOpacity(
                                        onTap: () async {
                                          await authProvider.signOut();
                                          // _presentUserProfile();
                                          // await authProvider.signOut();
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: currentUser != null &&
                                                      currentUser.photoURL !=
                                                          null
                                                  ? NetworkImage(
                                                      'https://images.unsplash.com/photo-1457449940276-e8deed18bfff?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8cHJvZmlsZXxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80')
                                                  : AssetImage(
                                                      'assets/images/user_profile.png',
                                                    ),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildContent(historySnapshot.connectionState,
                                    history, viewWidth, bottomMargin),
                                // history != null && history.isNotEmpty
                                //     ? _buildHistoryList(history, bottomMargin)
                                //     : _buildEmptyHistoryPlaceholder(viewWidth),
                              ],
                            ),
                            Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(bottom: bottomMargin + 16),
                                child: Column(
                                  children: [
                                    Spacer(),
                                    _btnScanQRCode(context),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(ConnectionState connectionState,
      List<HistoryItemModel> history, double viewWidth, double bottomMargin) {
    switch (connectionState) {
      case ConnectionState.waiting:
        return Expanded(
          child: Column(
            children: [
              Spacer(),
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Carregando Histório...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Spacer(),
            ],
          ),
        );
      default:
        return history != null && history.isNotEmpty
            ? _buildHistoryList(history, bottomMargin)
            : _buildEmptyHistoryPlaceholder(viewWidth);
    }
  }

  Widget _buildHistoryList(List<HistoryItemModel> list, double bottomMargin) {
    return Expanded(
      child: GroupedListView<HistoryItemModel, String>(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: bottomMargin + _btnQRCodeSize + 32,
        ),
        elements: list,
        groupBy: (item) => item.sectionTitle,
        separator: SizedBox(height: 16),
        itemComparator: (item1, item2) =>
            item2.createdAt.compareTo(item1.createdAt),
        sort: true,
        groupSeparatorBuilder: (value) {
          return Container(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 8,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        },
        itemBuilder: (context, item) {
          return HistoryItemCell(
            historyItem: item,
          );
        },
      ),
    );
  }

  void editHouse({HouseModel house}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHouseScreen(
          selectedHouse: house,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildEmptyHistoryPlaceholder(double viewWidth) {
    return Expanded(
      child: Column(
        children: [
          Spacer(),
          Column(
            children: [
              SvgPicture.asset(
                'assets/images/empty_history.svg',
                width: viewWidth,
              ),
              SizedBox(height: 30),
              Text(
                "Você ainda não recebeu nenhuma visita",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _btnScanQRCode(BuildContext context) {
    return TouchableOpacity(
      onTap: () {
        scanQRCode(context);
      },
      child: Container(
        width: _btnQRCodeSize,
        height: _btnQRCodeSize,
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
    );
  }

  String _userFirstName(String displayName) {
    if (displayName != null) {
      var nameArr = displayName.split(' ');
      return ", ${nameArr.first}";
    }
    return "Usuário";
  }

  void _selectHouse(HouseModel house) async {
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString('selectedHouse', house.id);
    setState(() {
      selectedHouse = house;
    });
  }

  void _loadSelectedHouse() async {
    // final prefs = await SharedPreferences.getInstance();
    // final selectedHouseId = prefs.getString('selectedHouse');
    // if (selectedHouseId != null && myHouses.isNotEmpty) {
    //   final index = myHouses.indexWhere((e) => e.id == selectedHouseId);
    //   if (index != null) {
    //     setState(() {
    //       selectedHouse = myHouses[index];
    //     });
    //   }
    // }
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

  void _presentUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
