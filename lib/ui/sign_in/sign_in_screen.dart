import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smartdingdong/provider/auth_provider.dart';
import 'package:smartdingdong/ui/widgets/already_have_an_account_acheck.dart';
import 'package:smartdingdong/ui/widgets/auth_screen_background.dart';
import 'package:smartdingdong/ui/widgets/rounded_button.dart';
import 'package:smartdingdong/ui/widgets/rounded_input_field.dart';
import 'package:smartdingdong/ui/widgets/rounded_password_field.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: AuthScreenBackground(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.35,
              ),
              SizedBox(height: size.height * 0.03),
              RoundedInputField(
                controller: emailController,
                hintText: "Seu email",
              ),
              RoundedPasswordField(
                controller: passwordController,
              ),
              RoundedButton(
                text: "LOGIN",
                press: () async {
                  print(emailController.text);
                  bool _ = await authProvider.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.pushNamed(context, '/signUp', arguments: {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
