import 'dart:developer';

import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/profile_provider.dart';

final _formKey = GlobalKey<FormState>();

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRegister = ref.read(isRegisterProvider);
    final phoneController = useTextEditingController();
    final sendOtp = useCallback((String mobile) async {
      try {
        SendOtpResponseModel response =
            SendOtpResponseModel(phone: phoneController.text.trim());
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: mobile,
          timeout: const Duration(seconds: 30),
          verificationCompleted: (PhoneAuthCredential credential) async {},
          verificationFailed: (FirebaseAuthException e) {
            log(e.toString());

            EasyLoading.dismiss();
            response.error = e.message;
          },
          codeSent: (String verificationId, int? resendToken) async {
            EasyLoading.dismiss();

            response.id = verificationId;
            response.token = resendToken;
            if (response.id != null) {
              context.push(AppRoutes.otpScreen, extra: response);
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            EasyLoading.dismiss();

            response.id = verificationId;
          },
        );
        return response;
      } on FirebaseAuthException catch (error) {
        EasyLoading.dismiss();
        EasyLoading.showError(error.code);

        rethrow;
      }
    }, []);
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Hero(
                    tag: "logo",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        "assets/logo.png",
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                    ),
                  ),
                ),
                Text(
                  isRegister ? 'Register' : 'Login',
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  autofocus: true,
                  controller: phoneController,
                  inputFormatters: numberOnlyInput,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: const InputDecoration(
                      label: Text('Phone number'),
                      hintText: "10 digit valid mobile number"),
                  validator: (value) {
                    if (phoneController.text.length != 10) {
                      return "Invalid number";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () {
                        formSubmitFunction(
                            formKey: _formKey,
                            submitFunction: () async {
                              Utils.loading();
                              log('tapped');
                              await sendOtp(
                                "+91${phoneController.text.trim()}",
                              );
                            });
                      },
                      child: const Text('GET OTP')),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}
