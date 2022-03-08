import 'package:flutter/material.dart';
import 'package:smartdingdong/ui/widgets/text_field_container.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: this.controller,
        obscureText: true,
        onChanged: onChanged,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: "Seu pequeno segredo",
          icon: Icon(
            Icons.lock,
            color: Colors.white,
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: Colors.white,
          ),
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
