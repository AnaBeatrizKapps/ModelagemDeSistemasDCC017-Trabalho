import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartdingdong/models/user_model.dart';
import 'package:smartdingdong/provider/auth_provider.dart';
import 'package:smartdingdong/services/firestore_database.dart';

class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder(
      {Key key, @required this.builder, @required this.databaseBuilder})
      : super(key: key);
  final Widget Function(BuildContext, AsyncSnapshot<UserModel>) builder;
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthProvider>(context, listen: false);
    return StreamBuilder<UserModel>(
      stream: authService.user,
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          final UserModel user = snapshot.data;
          if (user != null) {
            return MultiProvider(
              providers: [
                Provider<UserModel>.value(value: user),
                Provider<FirestoreDatabase>(
                  create: (context) => databaseBuilder(context, user.uid),
                ),
              ],
              child: builder(context, snapshot),
            );
          }
        }
        return builder(context, snapshot);
      },
    );
  }
}
