import 'package:flutter/material.dart';

class ServiceNameText extends StatelessWidget {
  final String serviceName;
  final Color? textColor;

  const ServiceNameText({
    super.key,
    required this.serviceName,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      serviceName,
      style: TextStyle(
        color: textColor ?? Colors.black,
        fontFamily: 'Rockwell',
        fontWeight: FontWeight.bold,
        fontSize: 40,
      ),
    );
  }
}
