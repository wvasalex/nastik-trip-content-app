import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatefulWidget {
  final Size childSize;
  final Widget child;

  ImageViewer({
    @required this.child,
    @required this.childSize,
  });

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return PhotoView.customChild(
      childSize: widget.childSize,
      child: widget.child,
    );
  }
}
