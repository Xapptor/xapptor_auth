import 'package:flutter/material.dart';
import 'package:xapptor_ui/values/ui.dart';

class FeedbackLayer extends StatefulWidget {
  const FeedbackLayer({
    required this.main_color,
    required this.texts,
    required this.on_button_pressed,
    required this.undetected_face_feedback,
    this.demo_face_1 = "",
    this.demo_face_2 = "",
  });

  final Color main_color;
  final List<String> texts;
  final Function on_button_pressed;
  final bool undetected_face_feedback;
  final String demo_face_1;
  final String demo_face_2;

  @override
  _FeedbackLayerState createState() => _FeedbackLayerState();
}

class _FeedbackLayerState extends State<FeedbackLayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Spacer(flex: 2),
          Expanded(
            flex: 2,
            child: Text(
              widget.texts[0],
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          !widget.undetected_face_feedback
              ? Spacer(flex: 10)
              : Expanded(
                  flex: 10,
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                outline_border_radius,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: AssetImage(
                                  widget.demo_face_1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                outline_border_radius,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: AssetImage(
                                  widget.demo_face_1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          Expanded(
            flex: 2,
            child: Text(
              widget.texts[1],
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Spacer(flex: 1),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.on_button_pressed();
              },
              child: Text(
                widget.texts[2],
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
