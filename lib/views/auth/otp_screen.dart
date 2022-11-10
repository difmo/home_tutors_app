import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../controllers/auth_controllers.dart';
import '../../controllers/utils.dart';
import '../constants.dart';

final _formKey = GlobalKey<FormState>();

class OtpVerifyScreen extends HookConsumerWidget {
  final SendOtpResponseModel data;
  const OtpVerifyScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = useTextEditingController();
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
                const SizedBox(height: 50.0),
                ElevatedButton(
                    onPressed: () {
                      formSubmitFunction(
                          formKey: _formKey,
                          submitFunction: () async {
                            Utils.loading();
                            User? user = await AuthControllers.verifyOtp(
                              id: data.id!,
                              code: otpController.text.trim(),
                            );
                            EasyLoading.dismiss();
                            if (user != null) {
                              var profileData =
                                  await ProfileController().fetchProfileData();
                              if (profileData?["email"] == null) {
                                await ProfileController.createProfile();
                                Future.delayed(Duration.zero).then((value) {
                                  context.go(AppRoutes.teacherProfile);
                                });
                              } else {
                                Future.delayed(Duration.zero)
                                    .then((value) async {
                                  if (profileData?["is_admin"]) {
                                    context.go(AppRoutes.adminHome);
                                  } else {
                                    context.go(AppRoutes.home);
                                  }
                                });
                              }
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
