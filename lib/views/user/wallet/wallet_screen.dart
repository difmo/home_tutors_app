import 'dart:developer';

import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/views/constants.dart';
import 'package:app/views/user/wallet/transactions_list_screen.dart';
import 'package:app/views/widgets/error_widget_screen.dart';
import 'package:app/views/widgets/loading_widget_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../controllers/admin/admin_controllers.dart';
import '../../../providers/profile_provider.dart';

// ignore: must_be_immutable
class WalletScreen extends HookConsumerWidget {
  WalletScreen({super.key});

  final Razorpay _razorpay = Razorpay();
  int walletBalance = 0;
  int selectedAmount = 0;
  String? paymentDocId = "";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProvider = ref.watch(profileDataProvider);
    final amtOptionsProvider = ref.watch(amountOptionsProvider);
    final selectedStatus = useState("All");
    final scrollController = useScrollController();
    final limitCount = useState(20);

    final handlePaymentSuccess =
        useCallback((PaymentSuccessResponse response) async {
      if (paymentDocId != null) {
        EasyLoading.show(
            status: "Please wait", maskType: EasyLoadingMaskType.clear);

        // update transaction
        Map<String, dynamic> postData = {
          "status": true,
          "order_id": response.orderId ?? "",
          "payment_id": response.paymentId ?? "",
          "payment_signature": response.signature ?? "",
          "message": "success"
        };

        await ProfileController.updateTransaction(
            postBody: postData, docId: paymentDocId!);
        // update wallet
        await ProfileController.updateProfile(profileBody: {
          "wallet_balance": (walletBalance + (selectedAmount / 2))
        });
        EasyLoading.dismiss();
        EasyLoading.showSuccess("Payment successful");
        ref.refresh(profileDataProvider);
      }
    }, []);
    //error
    final handlePaymentError =
        useCallback((PaymentFailureResponse response) async {
      if (paymentDocId != null) {
        EasyLoading.show(
            status: "Please wait", maskType: EasyLoadingMaskType.clear);

        // update transaction
        Map<String, dynamic> postData = {
          "message": response.message ?? "success"
        };
        await ProfileController.updateTransaction(
            postBody: postData, docId: paymentDocId!);
        EasyLoading.dismiss();
        EasyLoading.showError(response.message ?? "Something went wrong");
      }

      log("payment error ${response.message}");
    }, []);
    // wallet
    final handleExternalWallet =
        useCallback((ExternalWalletResponse response) {}, []);

    useEffect(
      () {
        _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
        _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
        _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
        scrollController.addListener(() {
          if (scrollController.position.atEdge) {
            if (scrollController.position.pixels == 0) {
            } else {
              limitCount.value = limitCount.value + 20;
            }
          }
        });
        return () {
          _razorpay.clear();
        };
      },
      [],
    );

    return profileProvider.when(data: (data) {
      walletBalance = data?["wallet_balance"].toInt();
      return Scaffold(
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(17.0, 17.0, 17.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recharge your wallet :",
                style: pageSubTitleStyle,
              ),
              const SizedBox(height: 25.0),
              amtOptionsProvider.when(
                data: (listData) {
                  return Wrap(
                    children: listData.docs
                        .map((item) => InkWell(
                              onTap: () async {
                                selectedAmount = item["amount"];
                                FirebaseAuth auth = FirebaseAuth.instance;
                                Map<String, dynamic> postData = {
                                  "uid": auth.currentUser?.uid,
                                  "amount": selectedAmount,
                                  "previous_balance": walletBalance,
                                  "phone": auth.currentUser?.phoneNumber,
                                  "status": false,
                                  "order_id": "",
                                  "payment_id": "",
                                  "payment_signature": "",
                                  "message": "",
                                  'createdOn': FieldValue.serverTimestamp()
                                };
                                EasyLoading.show(
                                    status: "Please wait",
                                    maskType: EasyLoadingMaskType.clear);

                                paymentDocId =
                                    await ProfileController.createTransaction(
                                        postBody: postData);
                                EasyLoading.dismiss();

                                var options = {
                                  'key': 'rzp_live_5HtAsZL4CVxxEn',
                                  'amount': item["amount"] * 100,
                                  'name': 'VIPTUTORS @ SYBRA CORPORATION',
                                  'description': 'Wallet recharge',
                                  'prefill': {
                                    'contact': data?["phone"] ?? "8427373281",
                                    'email':
                                        data?["email"] ?? "vipndls@gmail.com"
                                  }
                                };
                                _razorpay.open(options);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(7.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade300,
                                        spreadRadius: 3,
                                        blurRadius: 5)
                                  ],
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Text("₹${item["amount"]} for"),
                                    const SizedBox(height: 5.0),
                                    Text(
                                      "${item["coins"]} Coins",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
                error: (error, stackTrace) {
                  return Text("Something went wrong");
                },
                loading: () {
                  return const LinearProgressIndicator();
                },
              ),
              const SizedBox(height: 25.0),
              const Text(
                "Transactions :",
                style: pageSubTitleStyle,
              ),
              const SizedBox(height: 10.0),
              Row(
                children: const [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10.0),
                  Text("Successfull"),
                  SizedBox(width: 30.0),
                  Icon(
                    Icons.error_outlined,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10.0),
                  Text("Failed")
                ],
              ),
              const SizedBox(height: 15.0),
              StreamBuilder(
                  stream: ProfileController.fetchAllTransactions(
                      false, limitCount.value, selectedStatus.value),
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
                        return Expanded(
                            child: transactionListWidget(
                          context,
                          controller: scrollController,
                          data: snapshot.data?.docs,
                          isAdmin: false,
                        ));

                      case ConnectionState.done:
                        return Expanded(
                            child: transactionListWidget(
                          context,
                          controller: scrollController,
                          data: snapshot.data?.docs,
                          isAdmin: false,
                        ));
                    }
                  }),
            ],
          ),
        )),
        appBar: AppBar(
          title: const Text("Wallet"),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Text(
                  "${data?["wallet_balance"]} Coins left",
                  style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow),
                ),
              ),
            )
          ],
        ),
      );
    }, error: (error, stackTrace) {
      return const ErrorWidgetScreen();
    }, loading: () {
      return const LoadingWidgetScreen();
    });
  }
}
