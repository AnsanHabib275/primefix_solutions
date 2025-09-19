import 'package:get/get.dart';

import '../data/models/user_model.dart';

class AuthController extends GetxController {
  // Observable variables
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'user'.obs;

  // Methods
  Future<void> sendOTP(String phoneNumber) async {
    try {
      isLoading.value = true;
      await AuthService.sendOTP(phoneNumber);
      Get.toNamed('/otp-verification');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(String otp) async {
    // OTP verification logic
    // Navigate based on user role
    if (selectedRole.value == 'user') {
      Get.offAllNamed('/user-home');
    } else {
      Get.offAllNamed('/worker-dashboard');
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    currentUser.value = null;
    Get.offAllNamed('/welcome');
  }
}
