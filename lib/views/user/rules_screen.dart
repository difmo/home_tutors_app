import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        itemCount: rulesList.length,
        itemBuilder: (context, index) {
          return ListTile(
              leading: Text("${index + 1}."), title: Text(rulesList[index]));
        },
      )),
      appBar: AppBar(
        title: const Text("Rules"),
      ),
    );
  }
}

final List<String> rulesList = [
  "Tutor Registration is FREE.",
  "If Leads are grabbed from App directly, then only Leads cost in coin form will be charged or deducted from tutor wallet.",
  "Home tutors agency will collect the fees amount of only first month from parents and then transfer the rest amount, after the deduction of commission charges to the respective tutors account or in cash. And then from next month or instalment tutor can take fees from clients or parrent directly.",
  """If Lead or inquires are taken directly from us on private basis then,
   a). 50% to 60 % of the first month fee will be charged on month fee structure system. 
   b). Seven classes fees will be charged for hourly basis tuitions. ( mind 7 classes, not 7 hours). 
   c). If classes / tuition continues for short period ( less than 3 months) then only 30% commission of total fees amount will be charged as commission.""",
  "No commission will be charged if any tutor grab Leads directly from our Home tutors App.",
  "If any tutor will try to cheat us or our clients, then we can take legal action or approch you / your home directly.",
  "If leads are grabbed from our App. directly by tutors then whole responsibilities goes to tutor except until the lead will be proved invalid.",
  "f lead or leads proved invalid or unreasonable/ unresondable within 7 hours we will refund coin back to tutors wallet.",
  "If once a tutor recharged or upgraded his/her own wallet, money can't be refunded.",
  "If any tutor takes leads or inquiries from us on direct basis then whole responsibilities untill class will be done conformed.",
  "If we need, we can change our App. system over  own requirements and tutors feedback."
];
