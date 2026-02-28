import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  bool get isDarkMode =>
      themeMode.value == ThemeMode.dark ||
      (themeMode.value == ThemeMode.system &&
          WidgetsBinding
                  .instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  void setDarkMode(bool value) {
    themeMode.value = value ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }
}
