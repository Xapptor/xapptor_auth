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

  final face_detector = GoogleMlKit.vision.faceDetector();
  bool is_busy = false;
  bool camera_preview_full_size = true;

  late Animation<double> animation;
  late AnimationController controller;

  Tween<double> _rotationTween = Tween(begin: 23, end: 23);

  List<Widget> ui_layers = [];

  bool undetected_face_feedback = false;
  List<String> feedback_texts = [];

  on_feedback_button_pressed() {
    //
  }

  fill_ui_layers() {
    ui_layers = [
      FeedbackLayer(
        main_color: widget.main_color,
        texts: feedback_texts,
        on_button_pressed: on_feedback_button_pressed,
        undetected_face_feedback: undetected_face_feedback,
      ),
    ];
    setState(() {});
  }

  init_animation() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    animation = _rotationTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();
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
    check_logo_image_width();
  }

  Future process_image(InputImage input_image) async {
    if (is_busy) return;
    is_busy = true;
    final faces = await face_detector.processImage(input_image);
    print('Found ${faces.length} faces');

    is_busy = false;
  }

  double logo_image_width = 0;

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
    init_camera();
  }

  @override
  void dispose() {
    face_detector.close();
    camera_controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    double camera_preview_height = (screen_width * 1.4) * 0.9;
    double camera_preview_width = (screen_width * 0.8) * 0.9;

    if (camera_controller == null) {
      return Container();
    }
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: Container(
                height: camera_preview_height,
                width: camera_preview_width,
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
                child: CameraPreview(
                  camera_controller!,
                  child: CustomPaint(
                    painter: FaceFramePainter(
                      border_color: widget.main_color,
                      frame_height: camera_preview_height,
                      frame_width: camera_preview_width,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
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
          ],
        ),
      ),
    );
  }
}
