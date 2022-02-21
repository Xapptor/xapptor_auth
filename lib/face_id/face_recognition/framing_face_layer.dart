import 'package:flutter/material.dart';

class FramingFaceLayer extends StatefulWidget {
  const FramingFaceLayer({
    required this.border_color,
  });

  final Color border_color;

  @override
  _FramingFaceLayerState createState() => _FramingFaceLayerState();
}

class _FramingFaceLayerState extends State<FramingFaceLayer> {
  init_camera() async {
    //
  }

  @override
  void initState() {
    super.initState();
    init_camera();
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
    );
  }
}
