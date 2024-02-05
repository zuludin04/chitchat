import 'package:chitchat/core/constants.dart';
import 'package:chitchat/data/chitchat_repository.dart';
import 'package:chitchat/data/result.dart';
import 'package:chitchat/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Injectable()
class AuthController extends GetxController {
  final ChitChatRepository repository;

  RxBool isEmailLoading = RxBool(false);
  RxBool isGoogleLoading = RxBool(false);

  AuthController({required this.repository}) {
    checkingLoginStatus();
  }

  @override
  void onInit() {
    checkingLoginStatus();
    super.onInit();
  }

  Future<void> signInWithEmail(String email, String password) async {
    isEmailLoading.value = true;

    var result = await repository.signInEmail(email, password);
    if (result.resultType == ResultType.success) {
      Get.snackbar('Success Sign In', 'sign in using Email');
      Get.offAllNamed(AppRoutes.group);
      _saveKeyStorePreferences(result.data);
    } else {
      Get.snackbar(
        'Failed Sign In',
        result.message ?? 'Error Sign In',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isEmailLoading.value = false;
  }

  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;

    var result = await repository.signGoogle();
    if (result.resultType == ResultType.success) {
      Get.snackbar('Success Sign In', 'Sign in using Google');
      Get.offAllNamed(AppRoutes.group);
      _saveKeyStorePreferences(result.data);
    } else {
      Get.snackbar(
        'Failed Sign In',
        result.message ?? 'Error Sign In',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isGoogleLoading.value = false;
  }

  Future<void> _saveKeyStorePreferences(String? profileId) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(profileIdKey, profileId ?? "");
    prefs.setBool(alreadyLoginKey, true);
  }

  Future<void> checkingLoginStatus() async {
    var prefs = await SharedPreferences.getInstance();
    var alreadyLogin = prefs.getBool(alreadyLoginKey) ?? false;
    if (alreadyLogin) {
      Get.offAllNamed(AppRoutes.group);
    }
  }
}
