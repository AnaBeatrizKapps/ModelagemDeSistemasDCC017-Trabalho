import 'package:flutter/material.dart';
import 'package:smartdingdong/ui/widgets/text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  const RoundedInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: this.controller,
        onChanged: onChanged,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white),
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
