// import 'package:app/controllers/utils.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:go_router/go_router.dart';

// import '../../controllers/auth_controllers.dart';
// import '../../controllers/routes.dart';

// class RegistrationScreen extends StatefulWidget {
//   const RegistrationScreen({super.key});

//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();

//   @override
//   void dispose() {
//     super.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//           child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(17.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 25.0),
//                   child: Hero(
//                     tag: "logo",
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10.0),
//                       child: Image.asset(
//                         "assets/logo.png",
//                         width: MediaQuery.of(context).size.width * 0.3,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const Text(
//                   'Register',
//                   style: TextStyle(
//                     fontSize: 40.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 50.0),
//                 TextFormField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   maxLength: 50,
//                   decoration: const InputDecoration(
//                       label: Text('Email'), hintText: "mail@example.com"),
//                   validator: (value) {
//                     if (!emailController.text.trim().isValidEmail()) {
//                       return "Invalid email";
//                     } else {
//                       return null;
//                     }
//                   },
//                 ),
//                 TextFormField(
//                   controller: passwordController,
//                   keyboardType: TextInputType.visiblePassword,
//                   obscureText: true,
//                   maxLength: 16,
//                   decoration: const InputDecoration(
//                       label: Text('Password'), hintText: "********"),
//                   validator: (value) {
//                     if (passwordController.text.trim().length < 8) {
//                       return "Invalid password";
//                     } else if (passwordController.text.trim() !=
//                         confirmPasswordController.text.trim()) {
//                       return "Different password";
//                     } else {
//                       return null;
//                     }
//                   },
//                 ),
//                 TextFormField(
//                     controller: confirmPasswordController,
//                     keyboardType: TextInputType.visiblePassword,
//                     obscureText: true,
//                     maxLength: 16,
//                     decoration: const InputDecoration(
//                         label: Text('Confirm Password'), hintText: "********"),
//                     validator: (value) {
//                       if (confirmPasswordController.text.trim().length < 8) {
//                         return "Invalid password";
//                       } else if (passwordController.text.trim() !=
//                           confirmPasswordController.text.trim()) {
//                         return "Different password";
//                       } else {
//                         return null;
//                       }
//                     }),
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       const TextSpan(
//                         text: 'Already registered? ',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                       TextSpan(
//                         text: 'Login ',
//                         style: const TextStyle(color: Colors.blue),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             context.go(AppRoutes.login);
//                           },
//                       ),
//                       const TextSpan(
//                         text: 'or ',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                       TextSpan(
//                         text: 'Need help?',
//                         style: const TextStyle(color: Colors.blue),
//                         recognizer: TapGestureRecognizer()..onTap = () {},
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 50.0),
//                 ElevatedButton(
//                     onPressed: () {
//                       formSubmitFunction(
//                           formKey: _formKey,
//                           submitFunction: () async {
//                             Utils.loading();
//                             var user = await AuthControllers.register(
//                                 email: emailController.text.trim(),
//                                 password: passwordController.text.trim());
//                             EasyLoading.dismiss();
//                             if (user?.uid != null) {
//                               user!.sendEmailVerification();
//                               if (mounted) {
//                                 context.go(AppRoutes.emailVerification);
//                               }
//                             }
//                           });
//                     },
//                     child: const Text('Proceed')),
//               ],
//             ),
//           ),
//         ),
//       )),
//     );
//   }
// }
