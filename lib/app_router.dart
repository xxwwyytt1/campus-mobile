import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/map/map_search_view.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_list_view.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_affiliations.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_initial_screen.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_login.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_screen.dart';
import 'package:campus_mobile_experimental/ui/profile/cards.dart';
import 'package:campus_mobile_experimental/ui/profile/notifications.dart';
import 'package:campus_mobile_experimental/ui/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.BottomNavigationBar:
        return MaterialPageRoute(builder: (_) => BottomTabBar());
      case RoutePaths.OnboardingInitial:
        return MaterialPageRoute(builder: (_) => OnboardingInitial());
      case RoutePaths.Onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case RoutePaths.OnboardingAffiliations:
        return MaterialPageRoute(builder: (_) => OnboardingAffiliations());
      case RoutePaths.OnboardingLogin:
        return MaterialPageRoute(builder: (_) => OnboardingLogin());
      case RoutePaths.Home:
        return MaterialPageRoute(builder: (_) => Home());
      case RoutePaths.Map:
        return MaterialPageRoute(builder: (_) => prefix0.Maps());
      case RoutePaths.MapSearch:
        return MaterialPageRoute(builder: (_) => MapSearchView());
      case RoutePaths.Notifications:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return NotificationsListView();
        });
      case RoutePaths.Profile:
        return MaterialPageRoute(builder: (_) => Profile());
      case RoutePaths.CardsView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return CardsView();
        });
      case RoutePaths.NotificationsSettingsView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return NotificationsSettingsView();
        });
      default:
        return MaterialPageRoute(builder: (_) => Home());
    }
  }
}
