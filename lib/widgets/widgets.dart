import 'package:maintenance_app/shared/constants.dart';
import 'package:flutter/material.dart';

const InputDecoration textInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
  border: InputBorder.none,
  hintStyle: TextStyle(
    color: Colors.black45,
    fontSize: 22,
  ),
  suffixIcon: Icon(Icons.visibility_off, color: Colors.black12),
);

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenRemove(context, page) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => page),
        (route) => false,
  );
}

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}

Widget floatBtn(page){
  return StatefulBuilder(
    builder: (context, setState) => FloatingActionButton(
      onPressed: () {
        nextScreen(context, page);
      },
      backgroundColor: Constants().primaryColor,
      child: const Icon(Icons.support_agent, color: Colors.white),
    ),
  );
}

