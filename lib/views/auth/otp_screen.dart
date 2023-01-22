import 'dart:async';

import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/statics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../controllers/auth_controllers.dart';
import '../../controllers/utils.dart';
import '../constants.dart';

final _formKey = GlobalKey<FormState>();

class OtpVerifyScreen extends StatefulWidget {
  final SendOtpResponseModel data;
  const OtpVerifyScreen({super.key, required this.data});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  int secondsRemaining = 30;
  bool enableResend = false;
  late Timer timer;
  final TextEditingController otpController = TextEditingController();
  SendOtpResponseModel response = SendOtpResponseModel();

  @override
  initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  void _resendCode() async {
    Utils.loading();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.data.phone,
      timeout: const Duration(seconds: 30),
      forceResendingToken: response.token ?? widget.data.token,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        EasyLoading.dismiss();
        response.error = e.message;
      },
      codeSent: (String verificationId, int? resendToken) async {
        EasyLoading.dismiss();
        response.id = verificationId;
        response.token = resendToken;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        EasyLoading.dismiss();
        response.id = verificationId;
      },
    );
    setState(() {
      secondsRemaining = 30;
      enableResend = false;
    });
  }

  @override
  dispose() {
    otpController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'ENTER OTP',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50.0),
                Pinput(
                  controller: otpController,
                  autofocus: true,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  validator: (s) {
                    return s?.length == 6 ? null : 'Enter valid key';
                  },
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (pin) => debugPrint(pin),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: enableResend ? _resendCode : null,
                  child: const Text('Resend Code'),
                ),
                Text(
                  'after $secondsRemaining seconds',
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 40.0),
                ElevatedButton(
                    onPressed: () {
                      formSubmitFunction(
                          formKey: _formKey,
                          submitFunction: () async {
                            Utils.loading();
                            User? user = await AuthControllers.verifyOtp(
                              id: widget.data.id!,
                              code: otpController.text.trim(),
                            );
                            if (user != null) {
                              if (user.phoneNumber == adminPhone) {
                                EasyLoading.dismiss();
                                context.go(AppRoutes.adminHome);
                                return;
                              }
                              var profileData = await ProfileController()
                                  .fetchProfileData(
                                      FirebaseAuth.instance.currentUser?.uid);
                              EasyLoading.dismiss();
                              Future.delayed(Duration.zero).then((value) async {
                                if (profileData?["email"] == null) {
                                  await ProfileController.createProfile();
                                  Future.delayed(Duration.zero)
                                      .then((value) async {
                                    context.go(AppRoutes.teacherProfile);
                                  });
                                } else {
                                  context.go(AppRoutes.home);
                                }
                              });
                            }
                          });
                    },
                    child: const Text('LOGIN'))
              ],
            ),
          ),
        ),
      )),
    );
  }
}
