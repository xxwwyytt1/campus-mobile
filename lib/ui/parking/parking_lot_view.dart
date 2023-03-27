import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:provider/provider.dart';

import '../../core/hooks/parking_query.dart';
import '../../core/models/parking.dart';
import '../../core/providers/user.dart';

class ParkingLotsView extends HookWidget {

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
      child: parkingLotsList(context, parking, userDataProvider),
    );
  }

  // builds the listview that will be put into ContainerView
  Widget parkingLotsList(BuildContext context, UseQueryResult parking, UserDataProvider userDataProvider) {
    final showedScaffold = useState(false);
    List<String> lots = [];
    for (ParkingModel model in parking.data!) {
      if (model.isStructure! == false) {
        lots.add(model.locationName!);
      }
    }
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
    for (var i = 0; i < lots.length; i++) {
      bool lotViewState = userDataProvider.userProfileModel!.isParkingLotEnabled(lots[i]);
      list.add(
        ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              lots[i],
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // lotViewState ? ColorPrimary : Colors.black,
                  fontSize: 20),
            ),
          ),
          trailing:
              Icon(lotViewState ? Icons.cancel_rounded : Icons.add_rounded),
          onTap: () {
            if (selectedLots == 10 && !lotViewState && !showedScaffold.value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'You have reached the maximum number of lots (10) that can be selected. You need to deselect some lots before you can add any more.'),
                duration: Duration(seconds: 5),
              ));
              showedScaffold.value = !showedScaffold.value;
            }
            //  only allow select if doesn't exceed maximum allowed
            // if (lotViewState
            //     || (!lotViewState && selectedLots < ParkingModel.MAX_SELECTED_LOTS)) {
            //   selectedLots = selectedLots + (lotViewState ? -1 : 1);
            //   userDataProvider.userProfileModel!.disabledParkingLots![lots[i]] = !(userDataProvider.userProfileModel!.disabledParkingLots![lots[i]]!);
            //   userDataProvider.postUserProfile(userDataProvider.userProfileModel);
            // }
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
