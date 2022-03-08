import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartdingdong/auth_widget_builder.dart';
import 'package:smartdingdong/constants/app_themes.dart';
import 'package:smartdingdong/flavor.dart';
import 'package:smartdingdong/models/user_model.dart';
import 'package:smartdingdong/provider/auth_provider.dart';
import 'package:smartdingdong/routes.dart';
import 'package:smartdingdong/services/firestore_database.dart';
import 'package:smartdingdong/ui/home/home_screen.dart';
import 'package:smartdingdong/ui/visitor/visitor_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.databaseBuilder}) : super(key: key);
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  @override
  Widget build(BuildContext context) {
    return AuthWidgetBuilder(
      databaseBuilder: databaseBuilder,
      builder: (BuildContext context, AsyncSnapshot<UserModel> userSnapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Provider.of<Flavor>(context).toString(),
          routes: Routes.routes,
          // theme: AppThemes.lightTheme,
          theme: ThemeData(
            fontFamily: 'Nunito',
            scaffoldBackgroundColor: AppThemes.lightBackgroundColor,
            primaryColorLight: AppThemes.lightPrimaryColor,
          ),
          home: Consumer<AuthProvider>(
            builder: (_, authProviderRef, __) {
              if (userSnapshot.connectionState == ConnectionState.active) {
                return userSnapshot.hasData ? HomeScreen() : VisitorScreen();
              }

              return Material(
                child: CircularProgressIndicator(),
              );
            },
          ),
        );
      },
    );
  }
}
