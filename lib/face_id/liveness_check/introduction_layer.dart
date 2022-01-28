import 'package:flutter/material.dart';

class IntroductionLayer extends StatefulWidget {
  const IntroductionLayer({
    required this.border_color,
  });

  final Color border_color;

  @override
  _IntroductionLayerState createState() => _IntroductionLayerState();
}

class _IntroductionLayerState extends State<IntroductionLayer> {
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
