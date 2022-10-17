// To parse this JSON data, do
//
//     final cityListModel = cityListModelFromJson(jsonString);

import 'dart:convert';

CityListModel cityListModelFromJson(String str) =>
    CityListModel.fromJson(json.decode(str));

String cityListModelToJson(CityListModel data) => json.encode(data.toJson());

class CityListModel {
  CityListModel({
    this.error,
    this.msg,
    this.data,
  });

  bool? error;
  String? msg;
  List<String>? data;

  factory CityListModel.fromJson(Map<String, dynamic> json) => CityListModel(
        error: json["error"],
        msg: json["msg"],
        data: List<String>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "msg": msg,
        "data": List<dynamic>.from(data!.map((x) => x)),
      };
}
