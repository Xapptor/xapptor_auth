import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/face_id/liveness_check/check_liveness.dart';
import 'package:xapptor_auth/face_id/liveness_check/feedback_layer.dart';
import 'package:xapptor_logic/get_image_size.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'analize_for_face_changes.dart';
import 'check_face_framing.dart';
import 'face_frame_painter.dart';
import 'start_image_stream.dart';

class LivenessCheck extends StatefulWidget {
  const LivenessCheck({
    required this.main_color,
    required this.logo_image_path,
    required this.session_life_time,
    required this.callback,
  });

  final Color main_color;
  final String logo_image_path;
  final int session_life_time;
  final Function(bool liveness_check_result) callback;

  @override
  _LivenessCheckState createState() => _LivenessCheckState();
}

class _LivenessCheckState extends State<LivenessCheck>
    with SingleTickerProviderStateMixin {
  late List<CameraDescription> cameras;
  CameraController? camera_controller = null;
  FaceDetector face_detector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      mode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableContours: false,
      enableClassification: true,
    ),
  );
  bool is_busy = false;

  bool minimize_frame = true;
  bool undetected_face_feedback = false;
  bool show_frame_toast = false;
  String frame_toast_text = "Frame Your Face";

  bool face_is_ready_to_init_scan = false;
  bool face_is_close_enough = false;
  bool pass_first_face_detection = false;

  late Animation<double>? animation;
  late AnimationController animation_controller;
  Tween<double> oval_size_multiplier = Tween(begin: 0.45, end: 0.8);

  int face_validation_time = 15;

  List<String> feedback_texts = [
    "Get Ready For\nYour Video Selfie",
    "Frame Your Face In The Oval,\nPress I'm Ready & Move Closer",
    "I'm Ready",
  ];

  List<String> failed_feedback_texts = [
    "We need a clearer video selfie",
    "No Glare or Extreme Lightning",
    "Try Again",
    "Your Selfie",
    "Ideal Pose",
  ];

  bool open_camera = true;

  double logo_image_width = 0;

  late Timer timer;

  int process_image_counter = 0;
  List<double> smiling_probability_list = [];
  List<double> left_eye_open_probability_list = [];
  List<double> right_eye_open_probability_list = [];

  bool smiling_probability_test_passed = false;
  bool left_eye_open_probability_test_passed = false;
  bool right_eye_open_probability_test_passed = false;

  bool face_distance_result_2 = false;
  bool liveness_test_passed = false;

  on_main_feedback_button_pressed() {
    minimize_frame = false;
    pass_first_face_detection = true;
    setState(() {});
    animation_controller.forward();
  }

  on_close_feedback_button_pressed() {
    Navigator.pop(context);
  }

  init_animation() async {
    animation_controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400),
    );

    Animation<double> animation_curve = CurvedAnimation(
      parent: animation_controller,
      curve: Curves.elasticOut,
    );

    animation = oval_size_multiplier.animate(animation_curve)
      ..addListener(() {
        setState(() {});
      });
  }

  init_camera() async {
    cameras = await availableCameras();

    camera_controller = CameraController(cameras[1], ResolutionPreset.max);
    await camera_controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      timer = Timer.periodic(Duration(seconds: widget.session_life_time),
          (Timer timer) {
        Navigator.pop(context);
      });

      if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS)
        start_image_stream(
          camera_controller: camera_controller!,
          cameras: cameras,
          process_image_function: process_image,
        );
    });
  }

  Future process_image(InputImage input_image) async {
    if (is_busy) return;
    is_busy = true;
    process_image_counter++;

    final faces = await face_detector.processImage(input_image);
    //print('Found ${faces.length} faces');

    if (faces.length > 0) {
      Face first_face = faces.first;

      if (liveness_test_passed) {
        print("-------------------------PASSED!-------------------------");
      } else {
        check_liveness(
            face: first_face,
            update_function: (
              new_smiling_probability_list,
              new_left_eye_open_probability_list,
              new_right_eye_open_probability_list,
            ) {
              smiling_probability_list = new_smiling_probability_list;
              left_eye_open_probability_list =
                  new_left_eye_open_probability_list;
              right_eye_open_probability_list =
                  new_right_eye_open_probability_list;

              //Analize for changes

              smiling_probability_test_passed =
                  analize_for_face_changes(smiling_probability_list);

              left_eye_open_probability_test_passed =
                  analize_for_face_changes(left_eye_open_probability_list);

              right_eye_open_probability_test_passed =
                  analize_for_face_changes(right_eye_open_probability_list);

              if (left_eye_open_probability_test_passed &&
                  right_eye_open_probability_test_passed)
                liveness_test_passed = true;
            });
      }

      if (process_image_counter % 7 == 0) {
        process_image_counter = 0;

        check_face_framing(
          face: first_face,
          context: context,
          pass_first_face_detection: pass_first_face_detection,
          update_face_distance_result_2: (
            bool new_face_distance_result_2,
          ) {
            face_distance_result_2 = new_face_distance_result_2;
          },
          update_framing_values: (
            bool new_face_is_ready_to_init_scan,
            bool new_face_is_close_enough,
            String new_frame_toast_text,
            bool new_show_frame_toast,
          ) {
            face_is_ready_to_init_scan = new_face_is_ready_to_init_scan;
            face_is_close_enough = new_face_is_close_enough;
            frame_toast_text = new_frame_toast_text;
            show_frame_toast = new_show_frame_toast;
          },
          callback: () {
            setState(() {});

            //print('face_distance: ${face_distance}');
            //print('nose_base_position: ${nose_base_position}');
          },
        );
      }
    }
    is_busy = false;
  }

  check_logo_image_width() async {
    logo_image_width = await check_if_image_is_square(
            image: Image.asset(widget.logo_image_path))
        ? logo_height(context)
        : logo_width(context);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init_animation();
    check_logo_image_width();
    if (open_camera) {
      init_camera();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    if (face_detector != null && camera_controller != null) {
      face_detector.close();
      camera_controller!.dispose();
    }

    widget.callback(face_distance_result_2 && pass_first_face_detection);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: Column(
              children: [
                Spacer(flex: 1),
                Expanded(
                  flex: 26,
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(
                          width: 4,
                          color: widget.main_color,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(outline_border_radius),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(outline_border_radius),
                            child: camera_controller == null
                                ? Container(
                                    color: Colors.blueGrey,
                                  )
                                : CameraPreview(
                                    camera_controller!,
                                  ),
                          ),
                          CustomPaint(
                            size: Size(
                              double.infinity,
                              double.infinity,
                            ),
                            painter: FaceFramePainter(
                              main_color: widget.main_color,
                              oval_size_multiplier: animation?.value ?? 1,
                            ),
                          ),
                          minimize_frame
                              ? FeedbackLayer(
                                  main_color: widget.main_color,
                                  texts: feedback_texts,
                                  on_main_button_pressed:
                                      on_main_feedback_button_pressed,
                                  main_button_enabled:
                                      face_is_ready_to_init_scan,
                                  on_close_button_pressed:
                                      on_close_feedback_button_pressed,
                                  undetected_face_feedback:
                                      undetected_face_feedback,
                                )
                              : Container(),
                          show_frame_toast
                              ? Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(
                                    bottom: screen_height *
                                        (animation!.value <= 0.46 ? 0.4 : 0.5),
                                  ),
                                  constraints: BoxConstraints(
                                    maxHeight: 50,
                                    maxWidth: screen_width * 0.65,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.main_color.withOpacity(0.85),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(outline_border_radius),
                                    ),
                                  ),
                                  child: Text(
                                    frame_toast_text,
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: logo_height(context),
                    width: logo_image_width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: AssetImage(
                          widget.logo_image_path,
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
