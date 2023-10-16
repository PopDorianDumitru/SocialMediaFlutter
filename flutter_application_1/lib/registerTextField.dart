import 'package:flutter/material.dart';

Padding registerTextField(
    String labelText, bool isPassword, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
    child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
          child: TextField(
            controller: controller,
            showCursor: true,
            obscureText: isPassword,
            cursorRadius: Radius.circular(30),
            cursorHeight: 20,
            decoration: InputDecoration(
                labelText: labelText,
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                floatingLabelAlignment: FloatingLabelAlignment.start),
          ),
        )),
  );
}
