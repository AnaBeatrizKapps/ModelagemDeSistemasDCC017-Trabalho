import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartdingdong/constants/app_themes.dart';
import 'package:smartdingdong/models/house_model.dart';
import 'package:smartdingdong/services/firestore_database.dart';
import 'package:smartdingdong/ui/widgets/touchable_opacity.dart';

import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EditHouseScreen extends StatefulWidget {
  final HouseModel selectedHouse;
  EditHouseScreen({Key key, @required this.selectedHouse}) : super(key: key);

  @override
  _EditHouseScreen createState() => _EditHouseScreen();
}

class _EditHouseScreen extends State<EditHouseScreen> {
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.selectedHouse.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TouchableOpacity(
                          onTap: () {
                            close(context);
                          },
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Spacer(),
                        TouchableOpacity(
                          onTap: () {
                            save(context);
                          },
                          child: Text(
                            "Salvar",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Editar Casa",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.lightPrimaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 36),
                Stack(
                  children: <Widget>[
                    QrImage(
                      data: widget.selectedHouse.id,
                      gapless: true,
                      size: 200,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    )
                  ],
                ),
                SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  height: 60.0,
                  decoration: new ShapeDecoration(
                    color: Colors.white,
                    shape: new ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                  ),
                  child: new TextFormField(
                    // initialValue: selectedHouse.name,
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nome da casa',
                      hintStyle: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void close(BuildContext context) {
    Navigator.pop(context);
  }

  void save(BuildContext context) {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    firestoreDatabase.updateHouseName(widget.selectedHouse, controller.text);
    Navigator.pop(context);
  }
}
