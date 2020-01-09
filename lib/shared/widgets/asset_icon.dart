import 'package:flutter/material.dart';

class AssetIcon extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final Color color;

  AssetIcon({
    @required this.name,
    this.color,
    this.width = 24,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/$name.png',
      width: width,
      height: height,
    );
  }
}
