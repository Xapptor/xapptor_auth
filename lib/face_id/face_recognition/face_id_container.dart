import 'package:flutter/material.dart';

face_id_container({
  required Widget child,
}) =>
    WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            body: Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: child,
            ),
          ),
        ),
      ),
    );
