import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About us")),
      body: const SafeArea(
          child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Text(
            "VIP tutors is a tutor/teacher & faculty employment empowering site, Powered by “SYBRA CORPORATION” to promote employment at Local and National Level for Social and Educational Development. \n\nHere “Home Tutor Job” app is designed to disperse quick requirement & inquiries related to 1 to 1 private tuition tutors, online private tuition, group tuition and faculty placement job. \n\nWe are the cities best Private tutors, online tuition tutors, home tutors and faculty placement Service provider since 2011. We offer the best and qualified teachers to our students and having more than 71000+ nearby Home Tutors available with us. \n\n🙏 Thanks."),
      )),
    );
  }
}
