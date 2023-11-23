import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AppSnackBar {

  static void successSnackBar(
    String message, [
    int sec = 3,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  ]) {
    return customSnackBar(
      message,
      const Icon(Icons.check, color: Colors.white),
      Colors.green,
      snackPosition: snackPosition,
    );
  }

   static void errorSnackBar(
    String message, [
    int sec = 3,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  ]) {
    return customSnackBar(
      message,
      const Icon(Icons.cancel_rounded, color: Colors.white),
      Colors.redAccent,
      snackPosition: snackPosition,
    );
  }

  static void customSnackBar(
    String message,
    Icon icon,
    Color bgColor, {
    int sec = 3,
    Color fgColor = Colors.white,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    Get.rawSnackbar(
      message: message,
      snackPosition: snackPosition,
      shouldIconPulse: false,
      icon: icon,
      duration: Duration(seconds: sec),
      backgroundColor: bgColor,
      overlayColor: fgColor,
      borderRadius: 8.0,
    );
  }
}
