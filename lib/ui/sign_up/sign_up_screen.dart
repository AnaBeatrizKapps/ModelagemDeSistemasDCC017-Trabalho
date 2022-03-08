import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smartdingdong/models/user_model.dart';
import 'package:smartdingdong/provider/auth_provider.dart';
import 'package:smartdingdong/ui/widgets/already_have_an_account_acheck.dart';
import 'package:smartdingdong/ui/widgets/auth_screen_background.dart';
import 'package:smartdingdong/ui/widgets/rounded_button.dart';
import 'package:smartdingdong/ui/widgets/rounded_input_field.dart';
import 'package:smartdingdong/ui/widgets/rounded_password_field.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
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
                "SIGNUP",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/signup.svg",
                height: size.height * 0.35,
              ),
              RoundedInputField(
                controller: nameController,
                hintText: "Nome Completo",
              ),
              RoundedInputField(
                controller: emailController,
                hintText: "Email",
              ),
              RoundedPasswordField(
                controller: passwordController,
              ),
              RoundedButton(
                text: "SIGNUP",
                press: () async {
                  UserModel _ = await authProvider.registerWithEmailAndPassword(
                    displayName: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                  );
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
