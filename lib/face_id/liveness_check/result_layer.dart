import 'package:flutter/material.dart';

class ResultLayer extends StatefulWidget {
  const ResultLayer({
    required this.border_color,
  });

  final Color border_color;

  @override
  _ResultLayerState createState() => _ResultLayerState();
}

class _ResultLayerState extends State<ResultLayer> {
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
