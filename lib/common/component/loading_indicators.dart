import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicators extends StatelessWidget {
  final Color color;

  LoadingIndicators({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => SpinKitChasingDots(
        color: color,
        size: 30.0,
      );
}
