import 'dart:developer';

import 'package:app/controllers/profile_controllers.dart';
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

import '../../../providers/profile_provider.dart';

// ignore: must_be_immutable
class WalletScreen extends HookConsumerWidget {
  WalletScreen({super.key});
  final List<WalletRechargeOptionsModel> _walletRechargeOptionsList = [
    WalletRechargeOptionsModel(coins: 250, amount: 500),
    WalletRechargeOptionsModel(coins: 500, amount: 1000),
    WalletRechargeOptionsModel(coins: 1500, amount: 3000),
  ];
  final Razorpay _razorpay = Razorpay();
  int walletBalance = 0;
  int selectedAmount = 0;
  String? paymentDocId = "";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProvider = ref.watch(profileDataProvider);
    final transactionsProvider = ref.watch(alTransactionsProvider(false));

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
        await ProfileController.updateProfile(
            profileBody: {"wallet_balance": (walletBalance + selectedAmount)});
        EasyLoading.dismiss();
        EasyLoading.showSuccess("Payment successful");
        ref.refresh(profileDataProvider);
        ref.refresh(alTransactionsProvider(false));
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
        ref.refresh(alTransactionsProvider(false));
      }

      ref.refresh(alTransactionsProvider(false));
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
        return () {
          _razorpay.clear();
        };
      },
      [],
    );

    return profileProvider.when(data: (data) {
      walletBalance = data?["wallet_balance"];
      return Scaffold(
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recharge your wallet :",
                style: pageSubTitleStyle,
              ),
              const SizedBox(height: 25.0),
              Wrap(
                children: _walletRechargeOptionsList
                    .map((item) => InkWell(
                          onTap: () async {
                            selectedAmount = item.amount;
                            FirebaseAuth auth = FirebaseAuth.instance;
                            Map<String, dynamic> postData = {
                              "uid": auth.currentUser?.uid,
                              "amount": selectedAmount,
                              "previous_balance": walletBalance,
                              "email": auth.currentUser?.email,
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
                              'key': 'rzp_test_8d1I1Tu9gRbJcH',
                              'amount': item.amount * 100,
                              'name': 'VIPTUTORS @ SYBRA CORPORATION',
                              'description': 'Wallet recharge',
                              'prefill': {
                                'contact': data?["phone"] ?? "8427373281",
                                'email': data?["email"] ?? "vipndls@gmail.com"
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
                                Text("₹${item.amount} for"),
                                const SizedBox(height: 5.0),
                                Text(
                                  "${item.coins} Coins",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
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
              transactionsProvider.when(
                data: (listData) {
                  return Expanded(
                      child: TransactionsListScreen(data: listData));
                },
                error: (error, stackTrace) {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                },
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
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

class WalletRechargeOptionsModel {
  final int coins;
  final int amount;
  WalletRechargeOptionsModel({required this.coins, required this.amount});
}
