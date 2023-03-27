import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../core/hooks/parking_query.dart';
import '../../core/providers/user.dart';

class CircularParkingIndicators extends HookWidget {
  const CircularParkingIndicators({
    Key? key,
    required this.model,
  }) : super(key: key);

  final ParkingModel model;

  @override
  Widget build(BuildContext context) {
    final userDataProvider = useMemoized(() {
      debugPrint("Memoized UserDataProvider!");
      return Provider.of<UserDataProvider>(context);
    }, [context]);
    useListenable(userDataProvider);

    final parkingSpots = useFetchSpotTypesModel();
    final parking = useFetchParkingModels();

    return (parking.isFetching || parkingSpots.isFetching)? Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary)) : Column(
      children: [
        buildLocationTitle(),
        buildLocationContext(context),
        buildSpotsAvailableText(context, parking),
        buildHistoricInfo(),
        buildAllParkingAvailability(context, parkingSpots, userDataProvider),
      ],
    );
  }

  Widget buildAllParkingAvailability(BuildContext context, UseQueryResult parkingSpots, UserDataProvider userDataProvider) {
    List<Widget> listOfCircularParkingInfo = [];

    List<String> selectedSpots = [];

    // find 3 displayable parking spots
    parkingSpots.data.forEach((Spot spot) {
      if (selectedSpots.length < 4
          && userDataProvider.userProfileModel!.isParkingSpotEnabled(spot.spotKey!)) {
        selectedSpots.add(spot.spotKey!);
      }
    });
    // find spot according to the spot key
    int found = 0;
    Map<String, Spot> spotMap = Map<String, Spot>();
    for (Spot spot in parkingSpots.data) {
      if (found == 3) {
        break;
      }
      for (String spotKey in selectedSpots) {
        if (spotKey == spot.spotKey!) {
          spotMap[spotKey] = spot;
          found++;
          break;
        }
      }
    }
    for (String spot in selectedSpots) {
      if (model.availability != null) {
        listOfCircularParkingInfo.add(buildCircularParkingInfo(
            spotMap[spot],
            model.availability![spot],
            context));
      }
    }
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: listOfCircularParkingInfo,
      ),
    );
  }

  Widget buildCircularParkingInfo(
      Spot? spotType, dynamic locationData, BuildContext context) {
    int open;
    int total;
    if (locationData != null) {
      if (locationData["Open"] is String) {
        open = locationData["Open"] == "" ? 0 : int.parse(locationData["Open"]);
      } else {
        open = locationData["Open"] == null ? 0 : locationData["Open"];
      }
      if (locationData["Total"] is String) {
        total =
        locationData["Total"] == "" ? 0 : int.parse(locationData["Total"]);
      } else {
        total = locationData["Total"] == null ? 0 : locationData["Total"];
      }
    } else {
      open = 0;
      total = 0;
    }

    return locationData != null
        ? Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: 75,
                    width: 75,
                    child: CircularPercentIndicator(
                      radius: 37,
                      animation: true,
                      animationDuration: 1000,
                      lineWidth: 7.5,
                      percent: open / total,
                      center: Text(
                          ((open / total) * 100).round().toString() + "%",
                          style: TextStyle(fontSize: 22)),
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: colorFromHex('#EDECEC'),
                      progressColor: getColor(open / total),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: spotType != null
                ? CircleAvatar(
              backgroundColor: colorFromHex(spotType.color!),
              child: spotType.text!.contains("&#x267f;")
                  ? Icon(
                Icons.accessible,
                size: 25.0,
                color: colorFromHex(spotType.textColor!),
              )
                  : Text(
                spotType.spotKey!.contains("SR")
                    ? "RS"
                    : spotType.text!,
                style: TextStyle(
                  color: colorFromHex(spotType.textColor!),
                ),
              ),
            )
                : Container(),
          )
        ],
      ),
    )
        : Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: 75,
                    width: 75,
                    child: CircularPercentIndicator(
                      radius: 37,
                      animation: false,
                      lineWidth: 7.5,
                      percent: 0.0,
                      center: Text("N/A", style: TextStyle(fontSize: 22)),
                      backgroundColor: colorFromHex('#EDECEC'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: spotType != null
                ? CircleAvatar(
              backgroundColor: colorFromHex(spotType.color!),
              child: spotType.text!.contains("&#x267f;")
                  ? Icon(Icons.accessible,
                  size: 25.0,
                  color: colorFromHex(spotType.textColor!))
                  : Text(
                spotType.spotKey!.contains("SR")
                    ? "RS"
                    : spotType.text!,
                style: TextStyle(
                  color: colorFromHex(spotType.textColor!),
                ),
              ),
            )
                : Container(),
          )
        ],
      ),
    );
  }

  Color colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor =
          'FF' + hexColor; // FF as the opacity value if you don't add it.
    }
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Color getColor(double value) {
    if (value > .75) {
      return Colors.green;
    }
    if (value > .25) {
      return Colors.yellow;
    }
    return Colors.red;
  }

  Widget buildLocationContext(BuildContext context) {
    return Center(
      child: Text(model.locationContext ?? "",
          style: TextStyle(
            color: Colors.grey,
          )),
    );
  }

  Widget buildLocationTitle() {
    return Text(
      model.locationName ?? "",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget buildHistoricInfo() {
    if (model.locationProvider == "Historic") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.black,
          ),
          Padding(
            padding: EdgeInsets.only(right: 1.0),
          ),
          Text(
            "No Live Data. Estimated availability shown.",
          )
        ],
      );
    } else {
      return Text("");
    }
  }

  /// Returns the total number of spots open at a given location
  /// does not filter based on spot type
  Map<String, num> getApproxNumOfOpenSpots(String? locationId, UseQueryResult parking) {
    Map<String, ParkingModel> _parkingModels = Map<String, ParkingModel>.fromIterable(parking.data,
        key: (parkingModel) => parkingModel.locationName!,
        value: (parkingModel) => parkingModel);
    Map<String, num> totalAndOpenSpots = {"Open": 0, "Total": 0};
    if (_parkingModels![locationId] != null &&
        _parkingModels![locationId]!.availability != null) {
      for (dynamic spot in _parkingModels![locationId]!.availability!.keys) {
        if (_parkingModels![locationId]!.availability![spot]['Open'] != null &&
            _parkingModels![locationId]!.availability![spot]['Open'] != "") {
          totalAndOpenSpots["Open"] = totalAndOpenSpots["Open"]! +
              (_parkingModels![locationId]!.availability![spot]['Open']
              is String
                  ? int.parse(
                  _parkingModels![locationId]!.availability![spot]['Open'])
                  : _parkingModels![locationId]!.availability![spot]['Open']);
        }

        if (_parkingModels![locationId]!.availability![spot]['Total'] != null &&
            _parkingModels![locationId]!.availability![spot]['Total'] != "") {
          totalAndOpenSpots["Total"] = totalAndOpenSpots["Total"]! +
              (_parkingModels![locationId]!.availability![spot]['Total']
              is String
                  ? int.parse(
                  _parkingModels![locationId]!.availability![spot]['Total'])
                  : _parkingModels![locationId]!.availability![spot]['Total']);
        }
      }
    }
    return totalAndOpenSpots;
  }

  Widget buildSpotsAvailableText(BuildContext context, UseQueryResult parking) {
    return parking.isFetching ? Text("") : Center(
      child: Text("~" +
          getApproxNumOfOpenSpots(model.locationName, parking)["Open"]
              .toString() +
          " of " +
          getApproxNumOfOpenSpots(model.locationName, parking)["Total"]
              .toString() +
          " Spots Available"),
    );
  }
}