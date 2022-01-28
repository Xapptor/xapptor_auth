import 'package:flutter/material.dart';

class UndetectedFaceLayer extends StatefulWidget {
  const UndetectedFaceLayer({
    required this.border_color,
  });

  final Color border_color;

  @override
  _UndetectedFaceLayerState createState() => _UndetectedFaceLayerState();
}

class _UndetectedFaceLayerState extends State<UndetectedFaceLayer> {
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
