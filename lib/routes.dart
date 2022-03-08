import 'package:flutter/material.dart';
import 'package:smartdingdong/ui/home/home_screen.dart';
import 'package:smartdingdong/ui/sign_in/sign_in_screen.dart';
import 'package:smartdingdong/ui/sign_up/sign_up_screen.dart';
import 'package:smartdingdong/ui/visitor/visitor_screen.dart';

class Routes {
  Routes._();

  static const String signIn = '/signIn';
  static const String signUp = '/signUp';
  static const String home = '/home';
  static const String visitor = '/visitor';

  static final routes = <String, WidgetBuilder>{
    signIn: (BuildContext context) => SignInScreen(),
    signUp: (BuildContext context) => SignUpScreen(),
    home: (BuildContext context) => HomeScreen(),
    visitor: (BuildContext context) => VisitorScreen(),
  };
}
