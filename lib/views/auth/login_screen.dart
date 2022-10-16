import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 90.0,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset(
                            "assets/animations/monkey.gif",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50.0),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
                  decoration: const InputDecoration(
                      label: Text('Registered email'),
                      hintText: "mail@example.com"),
                  validator: (value) {
                    if (!emailController.text.trim().isValidEmail()) {
                      return "Invalid email";
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  maxLength: 16,
                  decoration: const InputDecoration(
                      label: Text('Password'), hintText: "********"),
                  validator: (value) {
                    if (passwordController.text.trim().length < 8) {
                      return "Invalid password";
                    } else {
                      return null;
                    }
                  },
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'New here? ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Register ',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.go(AppRoutes.register);
                          },
                      ),
                      const TextSpan(
                        text: 'or ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Forgot password?',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            if (emailController.text.isNotEmpty) {
                              Utils.loading();
                              await AuthControllers.changePassword(
                                  email: emailController.text.trim());
                              EasyLoading.dismiss();
                            } else {
                              Utils.toast("Enter registered email");
                            }
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50.0),
                ElevatedButton(
                    onPressed: () {
                      formSubmitFunction(
                          formKey: _formKey,
                          submitFunction: () async {
                            Utils.loading();
                            var user = await AuthControllers.login(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim());
                            EasyLoading.dismiss();
                            if (user?.uid != null) {
                              if (mounted) {
                                context.go(AppRoutes.home);
                              }
                            }
                          });
                    },
                    child: const Text('Proceed'))
              ],
            ),
          ),
        ),
      )),
    );
  }
}
