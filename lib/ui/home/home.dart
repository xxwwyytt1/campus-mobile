import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/webview_container.dart';
import 'package:campus_mobile_experimental/ui/weather/weather_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cardMargin, vertical: 0.0),
      child: ListView(
        padding: EdgeInsets.only(
            top: cardMargin + 2.0, right: 0.0, bottom: 0.0, left: 0.0),
        children: createList(context),
      ),
    );
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> orderedCards =
        getOrderedCardsList(Provider.of<CardsDataProvider>(context).cardOrder!);
    return orderedCards;
  }

  List<Widget> getOrderedCardsList(List<String> order) {
    List<Widget> orderedCards = [];
    Map<String, CardsModel?>? webCards =
        Provider.of<CardsDataProvider>(context, listen: false).webCards;

    for (String card in order) {
      if (!webCards!.containsKey(card)) {
        switch (card) {
          case 'weather':
            orderedCards.add(WeatherCard());
            break;
        }
      } else {
        // dynamically insert webCards into the list
        orderedCards.add(WebViewContainer(
          titleText: webCards[card]!.titleText,
          initialUrl: webCards[card]!.initialURL,
          cardId: card,
          requireAuth: webCards[card]!.requireAuth,
        ));
      }
    }
    return orderedCards;
  }
}
