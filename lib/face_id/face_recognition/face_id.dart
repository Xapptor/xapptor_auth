import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:xapptor_auth/check_logo_image_width.dart';
import 'package:xapptor_auth/face_id/compare_faces/compare_faces.dart';
import 'package:xapptor_auth/face_id/face_recognition/comparison_result_container.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id_container.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id_loader.dart';
import 'package:xapptor_auth/face_id/face_recognition/feedback_layer.dart';
import 'package:xapptor_auth/face_id/face_recognition/frame_container.dart';
import 'package:xapptor_auth/face_id/face_recognition/init_animation.dart';
import 'package:xapptor_auth/face_id/face_recognition/init_camera.dart';
import 'package:xapptor_auth/face_id/face_recognition/on_main_feedback_button_pressed.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'face_frame_painter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum FaceIDProcess {
  register,
  compare,
}

class FaceID extends StatefulWidget {
  const FaceID({
    super.key,
    required this.face_id_process,
    this.front_camera = true,
    required this.main_color,
    required this.logo_image_path,
    required this.session_life_time,
    required this.callback,
    required this.service_location,
    required this.remote_service_endpoint,
    required this.remote_service_endpoint_api_key,
    required this.remote_service_endpoint_region,
  });

  final FaceIDProcess face_id_process;
  final bool front_camera;
  final Color main_color;
  final String logo_image_path;
  final int session_life_time;
  final Function(bool liveness_check_result) callback;
  final ServiceLocation service_location;
  final String remote_service_endpoint;
  final String remote_service_endpoint_api_key;
  final String remote_service_endpoint_region;

  @override
  State<FaceID> createState() => FaceIDState();
}

class FaceIDState extends State<FaceID> with SingleTickerProviderStateMixin {
  late List<CameraDescription> cameras;
  CameraController? camera_controller;

  final face_detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
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

  late Timer session_life_time_timer;

  int process_image_counter = 0;
  List<double> smiling_probability_list = [];
  List<double> left_eye_open_probability_list = [];
  List<double> right_eye_open_probability_list = [];

  bool smiling_probability_test_passed = false;
  bool left_eye_open_probability_test_passed = false;
  bool right_eye_open_probability_test_passed = false;

  bool face_distance_result_2 = false;
  bool liveness_test_passed = false;
  bool show_loader = false;
  bool show_comparison_result = false;
  bool comparison_result = false;
  bool comparison_result_animate = false;

  on_close_feedback_button_pressed() {
    Navigator.pop(context);
  }

  bool timer_was_restart = false;

  init_timer() {
    session_life_time_timer = Timer(Duration(seconds: widget.session_life_time), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    init_animation();
    check_logo_image_width(
      context: context,
      logo_path: widget.logo_image_path,
      callback: (new_logo_image_width) => setState(() {
        logo_image_width = new_logo_image_width;
      }),
    );

    if (open_camera) {
      init_camera();
    }
  }

  @override
  void dispose() {
    if (session_life_time_timer.isActive) {
      session_life_time_timer.cancel();
    }
    if (camera_controller != null) {
      face_detector.close();
      camera_controller!.dispose();
    }

    widget.callback(comparison_result);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    return face_id_container(
      child: Column(
        children: [
          const Spacer(flex: 1),
          Expanded(
            flex: 26,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 4,
                    color: widget.main_color,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(outline_border_radius),
                  ),
                ),
                child: show_loader
                    ? face_id_loader(
                        screen_width: screen_width,
                      )
                    : show_comparison_result
                        ? comparison_result_container(
                            screen_width: screen_width,
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(outline_border_radius),
                                child: camera_controller == null
                                    ? Container(
                                        color: Colors.blueGrey,
                                      )
                                    : CameraPreview(
                                        camera_controller!,
                                      ),
                              ),
                              CustomPaint(
                                size: const Size(
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
                                      on_main_button_pressed: on_main_feedback_button_pressed,
                                      main_button_enabled: face_is_ready_to_init_scan,
                                      on_close_button_pressed: on_close_feedback_button_pressed,
                                      undetected_face_feedback: undetected_face_feedback,
                                    )
                                  : Container(),
                              show_frame_toast
                                  ? frame_container(
                                      screen_width: screen_width,
                                      screen_height: screen_height,
                                      outline_border_radius: outline_border_radius,
                                    )
                                  : Container(),
                            ],
                          ),
              ),
            ),
          ),
          const Spacer(flex: 1),
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
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
