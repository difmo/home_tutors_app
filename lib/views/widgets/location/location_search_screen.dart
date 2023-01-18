import 'package:app/controllers/statics.dart';
import 'package:app/controllers/user_controllers.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/models/autocomplate_prediction.dart';
import 'package:app/models/place_auto_complate_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../models/place_details_model.dart';
import '../../constants.dart';
import 'location_list_tile.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({Key? key}) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  List<AutocompletePrediction> locationList = [];
  PlaceDetailsModel? placeDetails;
  void placeAutoComplete(String query) async {
    Uri uri = Uri.https(
        "maps.googleapis.com",
        "maps/api/place/autocomplete/json",
        {"input": query, "key": googleApiKey});
    String? response = await UserControllers.getLocations(uri);
    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          locationList = result.predictions!;
        });
      }
    }
  }

  void getLocationDetails(String placeId) async {
    Uri uri = Uri.https("maps.googleapis.com", "maps/api/place/details/json",
        {"place_id": placeId, "key": googleApiKey});
    String? response = await UserControllers.getLocationDetails(uri);
    EasyLoading.dismiss();
    if (response != null) {
      setState(() {
        placeDetails = placeDetailsModelFromJson(response);
      });
      Navigator.pop(context, placeDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text(
          "Search Locality",
          style: TextStyle(color: textColorLightTheme),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: TextFormField(
                autofocus: true,
                onChanged: (value) {
                  placeAutoComplete(value);
                },
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: "Search your location",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(Icons.location_pin),
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),
          // Padding(
          //   padding: const EdgeInsets.all(defaultPadding),
          //   child: ElevatedButton.icon(
          //     onPressed: () {},
          //     icon: const Icon(Icons.my_location),
          //     label: const Text("Use my Current Location"),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: secondaryColor10LightTheme,
          //       foregroundColor: textColorLightTheme,
          //       elevation: 0,
          //       fixedSize: const Size(double.infinity, 40),
          //       shape: const RoundedRectangleBorder(
          //         borderRadius: BorderRadius.all(Radius.circular(10)),
          //       ),
          //     ),
          //   ),
          // ),
          // const Divider(
          //   height: 4,
          //   thickness: 4,
          //   color: secondaryColor5LightTheme,
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: locationList.length,
              itemBuilder: (context, index) {
                var item = locationList[index];
                return LocationListTile(
                  press: () {
                    Utils.loading(msg: "Getting details");
                    getLocationDetails(item.placeId!);
                  },
                  location: item.description ?? "",
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
