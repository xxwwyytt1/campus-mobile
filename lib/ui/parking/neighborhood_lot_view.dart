import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:provider/provider.dart';

import '../../core/hooks/parking_query.dart';
import '../../core/providers/user.dart';

class NeighborhoodLotsView extends HookWidget  {
  final List<String> args;
  const NeighborhoodLotsView(this.args);


  @override
  Widget build(BuildContext context) {
    final parking = useFetchParkingModels();
    final userDataProvider = useMemoized(() {
      debugPrint("Memoized UserDataProvider!");
      return Provider.of<UserDataProvider>(context);
    }, [context]);
    useListenable(userDataProvider);

    return parking.isFetching? Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary)) :
    ContainerView(
      child: lotsList(context, args, parking, userDataProvider),
    );
  }

  // builds the listview that will be put into ContainerView
  Widget lotsList(BuildContext context, List<String> arguments, UseQueryResult parking, UserDataProvider userDataProvider) {
    final showedScaffold = useState(false);
    // creates a list that will hold the list of building names
    List<Widget> list = [];
    list.add(ListTile(
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          "Parking Lots:",
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    ));

    int selectedLots = 0;
    parking.data!.forEach((parkingModel) {
      if (userDataProvider.userProfileModel!.isParkingLotEnabled(parkingModel.locationName)) {
        selectedLots++;
      }
    });
    // loops through and adds buttons for the user to click on
    for (int i = 0; i < arguments.length; i++) {
      bool lotState = userDataProvider.userProfileModel!.isParkingLotEnabled(arguments[i]);
      debugPrint("lotState is $lotState");
      list.add(
        ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              arguments[i],
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // lotState ? colorFromHex('#006A96') : Theme.of(context).colorScheme.secondary,
                  fontSize: 20),
            ),
          ),
          trailing: Icon(lotState ? Icons.cancel_rounded : Icons.add_rounded),
          onTap: () {
            if (selectedLots == 10 && !lotState && !showedScaffold.value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'You have reached the maximum number of lots (10) that can be selected. You need to deselect some lots before you can add any more.'),
                duration: Duration(seconds: 5),
              ));
              showedScaffold.value = !showedScaffold.value;
            }
            debugPrint(userDataProvider.userProfileModel!.disabledParkingLots!.toString());
            //  only allow select if doesn't exceed maximum allowed
            if (lotState
                || (!lotState && selectedLots < ParkingModel.MAX_SELECTED_LOTS)) {
              selectedLots = selectedLots + (lotState ? -1 : 1);
              // sync with user data provider
              if (lotState) {
                //  disable the parking -> put parking lot into map
                userDataProvider.userProfileModel!.disabledParkingLots!.add(arguments[i]);
              } else {
                // enable the parking -> delete parking lot from map
                userDataProvider.userProfileModel!.disabledParkingLots!.remove(arguments[i]);
              }
              // userDataProvider.userProfileModel!.disabledParkingLots![arguments[i]] = !(userDataProvider.userProfileModel!.disabledParkingLots![arguments[i]]!);
              userDataProvider.postUserProfile(userDataProvider.userProfileModel);
            }
          },
        ),
      );
    }

    // adds SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }

}

Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF' + hexColor; // FF as the opacity value if you don't add it.
  }
  return Color(int.parse('FF$hexCode', radix: 16));
}

class ScreenArguments {
  final List<String> lotList;

  ScreenArguments(this.lotList);
}
