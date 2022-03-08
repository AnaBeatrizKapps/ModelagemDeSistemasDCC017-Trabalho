import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartdingdong/flavor.dart';
import 'package:smartdingdong/my_app.dart';
import 'package:smartdingdong/provider/auth_provider.dart';
import 'package:smartdingdong/services/firestore_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) async {
      runApp(
        MultiProvider(
          providers: [
            Provider<Flavor>.value(value: Flavor.dev),
            ChangeNotifierProvider<AuthProvider>(
              create: (context) => AuthProvider(),
            ),
          ],
          child: MyApp(
            databaseBuilder: (_, uid) => FirestoreDatabase(uid: uid),
          ),
        ),
      );
    },
  );
}
