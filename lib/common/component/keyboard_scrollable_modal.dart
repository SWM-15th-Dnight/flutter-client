import 'package:flutter/material.dart';

class KeyboardScrollableModal extends StatelessWidget {
  final String message;

  const KeyboardScrollableModal({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          appBar: AppBar(
            title: Text('This is AppBar'),
          ),
          body: Center(
            child: Text(message),
          )),
    );
  }
}
