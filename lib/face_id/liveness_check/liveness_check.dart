import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:xapptor_auth/face_id/liveness_check/feedback_layer.dart';
import 'package:xapptor_logic/get_image_size.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'face_frame_painter.dart';

class LivenessCheck extends StatefulWidget {
  const LivenessCheck({
    required this.main_color,
    required this.logo_image_path,
  });

  final Color main_color;
  final String logo_image_path;

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

  int min_distance_1 = 400;
  int max_distance_1 = 500;

  int min_distance_2 = 800;
  int max_distance_2 = 1000;

  int nose_min_x = 300;
  int nose_max_x = 400;

  int nose_min_y = 630;
  int nose_max_y = 730;

  on_main_feedback_button_pressed() {
    minimize_frame = false;
    pass_first_face_detection = true;
    setState(() {});
    animation_controller.forward();
  }

  on_close_feedback_button_pressed() {
    Navigator.pop(context);
  }

  init_animation() {
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

  change_frame_toast_text() {
    frame_toast_text = "";
  }

  init_camera() async {
    cameras = await availableCameras();

    camera_controller = CameraController(cameras[1], ResolutionPreset.max);
    await camera_controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      camera_controller!.startImageStream((CameraImage camera_image) {
        final WriteBuffer allBytes = WriteBuffer();
        for (Plane plane in camera_image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final Size imageSize =
            Size(camera_image.width.toDouble(), camera_image.height.toDouble());

        final InputImageRotation imageRotation =
            InputImageRotationMethods.fromRawValue(
                    cameras[1].sensorOrientation) ??
                InputImageRotation.Rotation_0deg;

        final InputImageFormat inputImageFormat =
            InputImageFormatMethods.fromRawValue(camera_image.format.raw) ??
                InputImageFormat.NV21;

        final planeData = camera_image.planes.map(
          (Plane plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            );
          },
        ).toList();

        final inputImageData = InputImageData(
          size: imageSize,
          imageRotation: imageRotation,
          inputImageFormat: inputImageFormat,
          planeData: planeData,
        );

        InputImage input_image = InputImage.fromBytes(
            bytes: camera_image.planes.first.bytes,
            inputImageData: inputImageData);

        process_image(input_image);
      });
    });
  }

  Future process_image(InputImage input_image) async {
    if (is_busy) return;
    is_busy = true;

    final faces = await face_detector.processImage(input_image);
    //print('Found ${faces.length} faces');

    if (faces.length > 0) {
      Face first_face = faces.first;

      FaceLandmark? left_eye = first_face.getLandmark(FaceLandmarkType.leftEye);
      FaceLandmark? nose_base =
          first_face.getLandmark(FaceLandmarkType.noseBase);
      FaceLandmark? left_cheek =
          first_face.getLandmark(FaceLandmarkType.leftCheek);
      FaceLandmark? right_cheek =
          first_face.getLandmark(FaceLandmarkType.rightCheek);
      FaceLandmark? bottom_mouth =
          first_face.getLandmark(FaceLandmarkType.bottomMouth);

      Offset left_eye_position = left_eye?.position ?? Offset.zero;
      Offset nose_base_position = nose_base?.position ?? Offset.zero;
      Offset left_cheek_position = left_cheek?.position ?? Offset.zero;
      Offset right_cheek_position = right_cheek?.position ?? Offset.zero;
      Offset bottom_mouth_position = bottom_mouth?.position ?? Offset.zero;

      double distance_between_cheeks =
          (right_cheek_position.dx - left_cheek_position.dx).abs();

      double distance_between_mouth_and_eye =
          (bottom_mouth_position.dy - left_eye_position.dy).abs();

      double face_distance =
          (distance_between_cheeks + distance_between_mouth_and_eye).abs();

      if (nose_base_position.dx >= nose_min_x &&
          nose_base_position.dx <= nose_max_x &&
          nose_base_position.dy >= nose_min_y &&
          nose_base_position.dy <= nose_max_y) {
        if (!pass_first_face_detection) {
          if (face_distance >= min_distance_1 &&
              face_distance <= max_distance_1) {
            face_is_ready_to_init_scan = true;
            show_frame_toast = false;
          } else {
            face_is_ready_to_init_scan = false;
            face_is_close_enough = false;

            frame_toast_text = "Frame Your Face";
            show_frame_toast = true;
          }
          setState(() {});
        } else {
          // Future.delayed(Duration(seconds: face_validation_time), () {
          //   if (face_distance >= 1 &&
          //       face_distance <= 6 &&
          //       pass_first_face_detection) {
          //     //
          //   } else {
          //     //
          //   }
          // });
          if (face_distance >= min_distance_2 &&
              face_distance <= max_distance_2 &&
              pass_first_face_detection) {
            face_is_close_enough = true;
            show_frame_toast = false;
          } else {
            if (face_distance < min_distance_2) {
              frame_toast_text = "Move Closer";
            } else if (face_distance > max_distance_2) {
              frame_toast_text = "Move Further";
            }
            face_is_ready_to_init_scan = false;
            face_is_close_enough = false;
            show_frame_toast = true;
          }
          setState(() {});
        }
      } else {
        frame_toast_text = "Frame Your Face";
        show_frame_toast = true;
        setState(() {});
      }

      //print('face_distance: ${face_distance}');
      print('nose_base_position: ${nose_base_position}');
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
    if (face_detector != null && camera_controller != null) {
      face_detector.close();
      camera_controller!.dispose();
    }
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
                        color: Colors.orange,
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
                                      bottom: screen_height / 2),
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
