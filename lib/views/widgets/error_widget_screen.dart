import 'package:app/views/constants.dart';
import 'package:flutter/material.dart';

class ErrorWidgetScreen extends StatelessWidget {
  const ErrorWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
          child: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Something went wrong, please try again later",
            textAlign: TextAlign.center,
            style: pagetitleStyle,
          ),
        ),
      )),
      appBar: AppBar(
        title: const Text("Error"),
        centerTitle: false,
      ),
    );
  }
}
