import 'package:flutter/material.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'get_random_demo_face_path.dart';

class FeedbackLayer extends StatefulWidget {
  FeedbackLayer({super.key, 
    required this.main_color,
    required this.texts,
    required this.on_main_button_pressed,
    required this.main_button_enabled,
    required this.on_close_button_pressed,
    required this.undetected_face_feedback,
    this.demo_face_path_1 = "",
    this.demo_face_path_2 = "",
  });

  final Color main_color;
  final List<String> texts;
  final Function on_main_button_pressed;
  final bool main_button_enabled;
  final Function on_close_button_pressed;
  final bool undetected_face_feedback;
  String demo_face_path_1;
  String demo_face_path_2;

  @override
  _FeedbackLayerState createState() => _FeedbackLayerState();
}

class _FeedbackLayerState extends State<FeedbackLayer> {
  get_random_demo_faces() {
    widget.demo_face_path_1 = get_random_demo_face_path();
    widget.demo_face_path_2 = get_random_demo_face_path();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    get_random_demo_faces();

    if (widget.undetected_face_feedback) {
      if (widget.demo_face_path_1.isEmpty || widget.demo_face_path_2.isEmpty) {
        get_random_demo_faces();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;
    int middle_space_flex = 22;

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => widget.on_close_button_pressed(),
                icon: Icon(
                  Icons.close_rounded,
                  color: widget.main_color,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              widget.texts[0],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.main_color,
              ),
            ),
          ),
          !widget.undetected_face_feedback
              ? Spacer(flex: middle_space_flex)
              : Expanded(
                  flex: middle_space_flex,
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SelfieExample(
                            demo_face_path: widget.demo_face_path_1,
                            description_text: widget.texts[3],
                            main_color: widget.main_color,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SelfieExample(
                            demo_face_path: widget.demo_face_path_2,
                            description_text: widget.texts[4],
                            main_color: widget.main_color,
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.main_color,
              ),
            ),
          ),
          const Spacer(flex: 1),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (widget.main_button_enabled) {
                  widget.on_main_button_pressed();
                }
              },
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(
                  0,
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  widget.main_button_enabled ? widget.main_color : Colors.grey,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      outline_border_radius,
                    ),
                  ),
                ),
              ),
              child: Text(
                widget.texts[2],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class SelfieExample extends StatelessWidget {
  const SelfieExample({super.key, 
    required this.demo_face_path,
    required this.description_text,
    required this.main_color,
  });

  final String demo_face_path;
  final String description_text;
  final Color main_color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              outline_border_radius,
            ),
            border: Border.all(
              color: main_color,
            ),
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: AssetImage(
                demo_face_path,
              ),
            ),
          ),
        ),
        Text(
          description_text,
          style: TextStyle(
            color: main_color,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
