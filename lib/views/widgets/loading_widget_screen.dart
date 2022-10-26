import 'package:app/views/constants.dart';
import 'package:flutter/material.dart';

class LoadingWidgetScreen extends StatelessWidget {
  const LoadingWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 15.0),
              Text(
                "Loading... Please wait",
                textAlign: TextAlign.center,
                style: pagetitleStyle,
              ),
            ],
          ),
        ),
      )),
      appBar: AppBar(
        title: const Text("Loading....."),
        centerTitle: false,
      ),
    );
  }
}
