import 'package:chitchat/di/injection.dart';
import 'package:chitchat/ui/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthController controller = Get.put(getIt<AuthController>());

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                const Icon(
                  Icons.person_pin,
                  size: 128,
                  color: Colors.purple,
                ),
                const SizedBox(height: 32),
                _inputField('Email', emailController),
                const SizedBox(height: 16),
                _inputField('Password', passwordController),
                const SizedBox(height: 32),
                _signInButton(
                  () => controller.signInWithEmail(
                    emailController.text,
                    passwordController.text,
                  ),
                  const Text('Sign In'),
                  controller.isEmailLoading,
                ),
                const SizedBox(height: 16),
                const Text('OR'),
                const SizedBox(height: 16),
                _signInButton(
                  () => controller.signInWithGoogle(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.google),
                      SizedBox(width: 8),
                      Text('Login With Google'),
                    ],
                  ),
                  controller.isGoogleLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.black,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 3,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _signInButton(Function() onTap, Widget child, RxBool loading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        child: Obx(() {
          if (loading.value) {
            return const CircularProgressIndicator();
          } else {
            return child;
          }
        }),
      ),
    );
  }
}
