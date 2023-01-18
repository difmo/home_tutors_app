import 'package:flutter/material.dart';

class ClearDataWidget extends StatelessWidget {
  final void Function() onSubmit;
  final String title;
  final String desc;
  const ClearDataWidget(
      {super.key,
      required this.onSubmit,
      required this.title,
      required this.desc});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(desc),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel")),
        TextButton(onPressed: onSubmit, child: const Text("Proceed"))
      ],
    );
  }
}
