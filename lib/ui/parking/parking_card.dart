import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/hooks/parking_query.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/parking/circular_parking_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:provider/provider.dart';

import '../../core/providers/user.dart';

class ParkingCard extends HookWidget {
  // instead of didChangeDependencies, useMemoized(userDataProvider), find example in availability card

  final String cardId = 'parking';

  // ignore: must_call_super
  Widget build(BuildContext context) {
    final userDataProvider = useMemoized(() {
      debugPrint("Memoized UserDataProvider!");
      return Provider.of<UserDataProvider>(context);
    }, [context]);
    useListenable(userDataProvider);

    final parking = useFetchParkingModels();
    final PageController _controller = usePageController();

    Map<String, Function> menuOption = {
      "Manage Lots": (context) =>
      {Navigator.pushNamed(context, RoutePaths.ManageParkingView)},
      "Manage Spots": (context) =>
      {Navigator.pushNamed(context, RoutePaths.SpotTypesView)}
    };
    //super.build(context);
    return CardContainer(
      titleText: CardTitleConstants.titleMap[cardId],
      isLoading: parking.isFetching,
      reload: () => parking.refetch(),
      errorText: parking.error.toString(),
      child: () => buildParkingCard(context, parking, userDataProvider, _controller),
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildParkingCard(BuildContext context, UseQueryResult parking, UserDataProvider userDataProvider, PageController pc) {
    try {
      List<Widget> selectedLotsViews = [];
      for (ParkingModel model in parking.data) {
        if (userDataProvider.userProfileModel!.isParkingLotDisabled(model.locationName!)) {
          selectedLotsViews.add(CircularParkingIndicators(model: model));
        }
      }
      if (selectedLotsViews.isEmpty) {
        return (Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No Lots to Display",
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Add a Lot via 'Manage Lots'",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ));
      }
      return Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: pc,
              children: selectedLotsViews,
            ),
          ),
          DotsIndicator(
            controller: pc,
            itemCount: selectedLotsViews.length,
            onPageSelected: (int index) {
              pc.animateToPage(index,
                  duration: Duration(seconds: 1), curve: Curves.decelerate);
            },
          ),
        ],
      );
    } catch (e) {
      print(e);
      return Container(
        width: double.infinity,
        child: Center(
          child: Container(
            child: Text('An error occurred, please try again.'),
          ),
        ),
      );
    }
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        primary: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'Manage Lots',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.ManageParkingView);
      },
    ));
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        primary: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'Manage Spots',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.SpotTypesView);
      },
    ));
    return actionButtons;
  }
}

// import 'package:campus_mobile_experimental/app_constants.dart';
// import 'package:campus_mobile_experimental/core/models/parking.dart';
// import 'package:campus_mobile_experimental/core/providers/cards.dart';
// import 'package:campus_mobile_experimental/core/providers/parking.dart';
// import 'package:campus_mobile_experimental/ui/common/card_container.dart';
// import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
// import 'package:campus_mobile_experimental/ui/parking/circular_parking_indicator.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class ParkingCard extends StatefulWidget {
//   @override
//   _ParkingCardState createState() => _ParkingCardState();
// }
//
// class _ParkingCardState extends State<ParkingCard> {
//   late ParkingDataProvider _parkingDataProvider;
//   final _controller = new PageController();
//   String cardId = 'parking';
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _parkingDataProvider = Provider.of<ParkingDataProvider>(context);
//   }
//
//   // ignore: must_call_super
//   Widget build(BuildContext context) {
//     Map<String, Function> menuOption = {
//       "Manage Lots": (context) =>
//           {Navigator.pushNamed(context, RoutePaths.ManageParkingView)},
//       "Manage Spots": (context) =>
//           {Navigator.pushNamed(context, RoutePaths.SpotTypesView)}
//     };
//     //super.build(context);
//     return CardContainer(
//       titleText: CardTitleConstants.titleMap[cardId],
//       isLoading: _parkingDataProvider.isLoading,
//       reload: () => {_parkingDataProvider.fetchParkingData()},
//       errorText: _parkingDataProvider.error,
//       child: () => buildParkingCard(context),
//       active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
//       hide: () => Provider.of<CardsDataProvider>(context, listen: false)
//           .toggleCard(cardId),
//       actionButtons: buildActionButtons(),
//     );
//   }
//
//   Widget buildParkingCard(BuildContext context) {
//     try {
//       List<Widget> selectedLotsViews = [];
//       for (ParkingModel model in _parkingDataProvider.parkingModels) {
//         if (_parkingDataProvider.parkingViewState![model.locationName] ==
//             true) {
//           selectedLotsViews.add(CircularParkingIndicators(model: model));
//         }
//       }
//       if (selectedLotsViews.isEmpty) {
//         return (Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "No Lots to Display",
//               style: TextStyle(fontSize: 24),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Text(
//                 "Add a Lot via 'Manage Lots'",
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ],
//         ));
//       }
//       return Column(
//         children: <Widget>[
//           Expanded(
//             child: PageView(
//               controller: _controller,
//               children: selectedLotsViews,
//             ),
//           ),
//           DotsIndicator(
//             controller: _controller,
//             itemCount: selectedLotsViews.length,
//             onPageSelected: (int index) {
//               _controller.animateToPage(index,
//                   duration: Duration(seconds: 1), curve: Curves.decelerate);
//             },
//           ),
//         ],
//       );
//     } catch (e) {
//       print(e);
//       return Container(
//         width: double.infinity,
//         child: Center(
//           child: Container(
//             child: Text('An error occurred, please try again.'),
//           ),
//         ),
//       );
//     }
//   }
//
//   List<Widget> buildActionButtons() {
//     List<Widget> actionButtons = [];
//     actionButtons.add(TextButton(
//       style: TextButton.styleFrom(
//         // primary: Theme.of(context).buttonColor,
//         primary: Theme.of(context).backgroundColor,
//       ),
//       child: Text(
//         'Manage Lots',
//       ),
//       onPressed: () {
//         Navigator.pushNamed(context, RoutePaths.ManageParkingView);
//       },
//     ));
//     actionButtons.add(TextButton(
//       style: TextButton.styleFrom(
//         // primary: Theme.of(context).buttonColor,
//         primary: Theme.of(context).backgroundColor,
//       ),
//       child: Text(
//         'Manage Spots',
//       ),
//       onPressed: () {
//         Navigator.pushNamed(context, RoutePaths.SpotTypesView);
//       },
//     ));
//     return actionButtons;
//   }
// }
