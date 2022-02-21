import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/face_id/compare_faces/compare_faces.dart';
import 'package:xapptor_auth/face_id/face_recognition/check_liveness.dart';
import 'package:xapptor_auth/face_id/face_recognition/feedback_layer.dart';
import 'package:xapptor_logic/get_base64_from_remote_image.dart';
import 'package:xapptor_logic/get_image_size.dart';
import 'package:xapptor_logic/get_temporary_file_from_local.dart';
import 'package:xapptor_me/fe.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'analize_for_face_changes.dart';
import 'check_face_framing.dart';
import 'face_frame_painter.dart';
import 'start_image_stream.dart';

enum FaceIDProcess {
  register,
  compare,
}

class FaceID extends StatefulWidget {
  const FaceID({
    required this.face_id_process,
    this.front_camera = true,
    required this.main_color,
    required this.logo_image_path,
    required this.session_life_time,
    required this.callback,
    required this.service_location,
  });

  final FaceIDProcess face_id_process;
  final bool front_camera;
  final Color main_color;
  final String logo_image_path;
  final int session_life_time;
  final Function(bool liveness_check_result) callback;
  final ServiceLocation service_location;

  @override
  _FaceIDState createState() => _FaceIDState();
}

class _FaceIDState extends State<FaceID> with SingleTickerProviderStateMixin {
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
  Timer show_loader_timer = Timer(Duration(seconds: 9999), () {});

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

  on_main_feedback_button_pressed() {
    minimize_frame = false;
    pass_first_face_detection = true;
    setState(() {});
    animation_controller.forward();
    if (!timer_was_restart) {
      timer_was_restart = true;
      session_life_time_timer.cancel();
      init_timer();
    }
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

    camera_controller = CameraController(
      cameras[widget.front_camera ? 1 : 0],
      widget.front_camera ? ResolutionPreset.high : ResolutionPreset.medium,
    );
    await camera_controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      init_timer();

      if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS)
        start_image_stream(
          camera_controller: camera_controller!,
          camera: cameras[widget.front_camera ? 1 : 0],
          process_image_function: process_image,
        );
    });
  }

  bool timer_was_restart = false;

  init_timer() {
    session_life_time_timer =
        Timer(Duration(seconds: widget.session_life_time), () {
      Navigator.pop(context);
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

      if (process_image_counter % 3 == 0) {
        process_image_counter = 0;

        check_face_framing(
          face: first_face,
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
            if (face_distance_result_2 && pass_first_face_detection) {
              face_id_process();
            } else {
              setState(() {});
            }

            //print('face_distance: ${face_distance}');
            //print('nose_base_position: ${nose_base_position}');
          },
        );
      }
    }
    is_busy = false;
  }

  upload_new_face_id_file(Uint8List source_bytes, User current_user) async {
    FE fe = FE();
    Uint8List encrypted_bytes = fe.encrypt_bytes(
      b: source_bytes,
      k: current_user.uid,
      inverse: false,
    );

    File source_file = await get_temporary_file_from_local(
      bytes: encrypted_bytes,
      name: "temp_image_1.jpeg",
    );

    String timeStamp = DateTime.now().toIso8601String();

    Reference face_id_ref = FirebaseStorage.instance
        .ref()
        .child('face_id')
        .child('/' + current_user.uid)
        .child('/${timeStamp}.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': source_file.path},
    );

    face_id_ref.putFile(source_file, metadata).then((p0) {
      source_file.delete();
    });

    check_user_face_id_files_length(current_user);
  }

  check_user_face_id_files_length(User current_user) async {
    ListResult result = await FirebaseStorage.instance
        .ref()
        .child('face_id')
        .child('/' + current_user.uid)
        .listAll();

    if (result.items.length > 3) {
      result.items.sort((a, b) => a.name.compareTo(b.name));
      result.items.forEach((element) {
        print(element.name);
      });

      for (var i = 0; i <= (result.items.length - 3); i++) {
        await result.items[i].delete();
        if (i <= (result.items.length - 3)) {
          Navigator.pop(context);
        }
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<String> get_random_face_id_file_url(User current_user) async {
    ListResult result = await FirebaseStorage.instance
        .ref()
        .child('face_id')
        .child('/' + current_user.uid)
        .listAll();

    result.items.shuffle();

    return await result.items.first.getDownloadURL();
  }

  face_id_process() async {
    setState(() {});
    await camera_controller!.stopImageStream();

    Timer(Duration(milliseconds: 500), () {
      camera_controller!.takePicture().then((file) async {
        // show_loader_timer = Timer(Duration(milliseconds: 800), () {
        //   show_loader = true;
        //   setState(() {});
        // });

        User current_user = FirebaseAuth.instance.currentUser!;
        Uint8List source_bytes = await file.readAsBytes();

        if (widget.face_id_process == FaceIDProcess.register) {
          upload_new_face_id_file(source_bytes, current_user);
        } else {
          FE fe = FE();
          Uint8List target_bytes = await get_bytes_from_remote_image(
              await get_random_face_id_file_url(current_user));

          Uint8List decrypted_target_bytes = fe.encrypt_bytes(
            b: target_bytes,
            k: current_user.uid,
            inverse: true,
          );

          bool compare_faces_result = await compare_faces(
            service_location: widget.service_location,
            source_image_bytes: source_bytes,
            target_image_bytes: decrypted_target_bytes,
          );

          print("-------------compare_faces_result");
          print(compare_faces_result);

          if (compare_faces_result) {
            upload_new_face_id_file(source_bytes, current_user);
          } else {
            Navigator.pop(context);
          }
        }
      });
    });
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
    if (session_life_time_timer.isActive) {
      session_life_time_timer.cancel();
    }
    if (show_loader_timer.isActive) {
      show_loader_timer.cancel();
    }
    if (camera_controller != null) {
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
                          ? Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: screen_width / 7,
                                    width: screen_width / 7,
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: CircularProgressIndicator(
                                      color: widget.main_color,
                                      strokeWidth: screen_width / 60,
                                    ),
                                  ),
                                  Text(
                                    "Uploading Encrypted Face Points",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: widget.main_color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      outline_border_radius),
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
                                              (animation!.value <= 0.46
                                                  ? 0.4
                                                  : 0.5),
                                        ),
                                        constraints: BoxConstraints(
                                          maxHeight: 50,
                                          maxWidth: screen_width * 0.65,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.main_color
                                              .withOpacity(0.85),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                outline_border_radius),
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
