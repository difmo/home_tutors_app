import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../controllers/utils.dart';

class AmountOptionsScreen extends StatefulWidget {
  const AmountOptionsScreen({super.key});

  @override
  State<AmountOptionsScreen> createState() => _AmountOptionsScreenState();
}

class _AmountOptionsScreenState extends State<AmountOptionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController coinsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Widget amountCard(BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemCount: docs?.length ?? 0,
      itemBuilder: (context, index) {
        var item = docs?[index];
        return Dismissible(
          key: Key(item?.id ?? "az"),
          onDismissed: (direction) async {
            await AdminControllers.deleteAmountOption(id: item?.id ?? "");
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Amount deleted')));
          },
          child: ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text("Coins: ${item?["coins"]}"),
            trailing: Text("Amount: ₹${item?["amount"]}"),
            subtitle: Text(formatWithMonthNameTime.format(
                item?["createdOn"] == null
                    ? DateTime.now()
                    : item?["createdOn"].toDate())),
          ),
        );
      },
    );
  }

  Widget addNewAmount(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.all(20.0),
      title: const Text("Add wallet amount option"),
      content: SizedBox(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                autofocus: true,
                controller: coinsController,
                keyboardType: TextInputType.number,
                inputFormatters: numberOnlyInput,
                decoration: const InputDecoration(
                    labelText: "Coins",
                    hintText: 'Wallet coins',
                    border: InputBorder.none),
                maxLength: 5,
                validator: (value) {
                  if (value!.length >= 2) {
                    return null;
                  } else {
                    return "Enter valid coin";
                  }
                },
              ),
              TextFormField(
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  inputFormatters: numberOnlyInput,
                  decoration: const InputDecoration(
                      labelText: "Amount",
                      hintText: 'INR',
                      border: InputBorder.none),
                  maxLength: 5,
                  validator: (value) {
                    if (value!.length >= 2) {
                      return null;
                    } else {
                      return "Enter valid amount";
                    }
                  }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Cancel",
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: () async {
            formSubmitFunction(
                formKey: _formKey,
                submitFunction: () async {
                  Map<String, dynamic> bodyData = {
                    "coins": int.parse(coinsController.text),
                    "amount": int.parse(amountController.text),
                    "createdOn": FieldValue.serverTimestamp()
                  };
                  Utils.loading();
                  await AdminControllers.createAmountOption(postBody: bodyData);
                  EasyLoading.dismiss();
                  amountController.clear();
                  coinsController.clear();
                  Navigator.pop(context);
                });
          },
          child: const Text(
            "Add",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    coinsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
            stream: AdminControllers.fetchAmountOptions(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Center(child: Text('No data'));
                case ConnectionState.waiting:
                  return const Center(child: Text('Awaiting...'));
                case ConnectionState.active:
                case ConnectionState.done:
                  return amountCard(
                    context,
                    snapshot.data?.docs,
                  );
              }
            }),
      ),
      appBar: AppBar(
        title: const Text("Amount Options"),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return addNewAmount(context);
                  });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          )
        ],
      ),
    );
  }
}
