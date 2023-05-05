import 'dart:convert';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/models/user_profile.dart';
import '../providers/cards.dart';
import '../services/authentication.dart';
import '../services/user.dart';
import '../utils/user_credentials.dart';

// GLOBAL DATA SOURCE: "the user profile model", stored in the Hive database (NoSQL)
//
// useFetchUserProfileModel() -> UserProfileModel?
// isLoggedIn() -> bool
//
// _fetchUserProfileFromNetwork(String base64EncodedWithEncryptedPassword) -> UserProfileModel
// _saveUserProfile(UserProfileModel) -> void
// _loadUserProfile() -> UserProfileModel?
//
// NOTE: if we are not using Hive for encryption, create an EncryptionHelper class
// to handle encryption/decryption the way instead of copy/pasting everywhere
//
// [ x ] silentLogin() (delete this)
// [ x ] manualLogin() (TENTATIVE: not sure yet, most likely)

//if this function gets too long, split into 2 functions and can make one a private function by adding an underscore in the front
UseQueryResult<AuthenticationModel?, dynamic> useFetchAuthenticationModel(String base64EncodedWithEncryptedPassword, String username, String password)
{
  return useQuery(['authentication'], () async {
    //TODO: check if user and password exist, otherwise return null
    //TODO: move manualLogin function from user.dart into this file
    //TODO: move all silentLogin into this file, return null if doesn't exist, if there is error throw exception
    ///INITIALIZE SERVICES

    ///default authentication model and profile is needed in this class

    var userProfileModel = UserProfileModel.fromJson({});
    //silent login
    bool silentLogin = false;
    String? user = await getUsernameFromDevice();
    String? encryptedPassword = await getEncryptedPasswordFromDevice();
    /// Allow silentLogin if username, pw are set, and the user is not logged in
    if (user != null && encryptedPassword != null) {
      silentLogin = true;
      if (await AuthenticationService()
          .login(base64EncodedWithEncryptedPassword)) {
        //update Authentication Model
        _updateAuthenticationModel(AuthenticationService().data);
        //fetch user profile
        await _fetchUserProfile();

        CardsDataProvider _cardsDataProvider = CardsDataProvider();
        _cardsDataProvider
            .updateAvailableCards(userProfileModel.ucsdaffiliation);

        //subscribe to push notification provider
        PushNotificationDataProvider().unsubscribeFromAllTopics();
        for (String? topic in userProfileModel.subscribedTopics!) {
          PushNotificationDataProvider().toggleNotificationsForTopic(topic);
        }

        PushNotificationDataProvider()
            .registerDevice(AuthenticationService().data!.accessToken);
        await FirebaseAnalytics().logEvent(name: 'loggedIn');
      }
    }
    else {
      _logout();
    }
    //manual login
    if (username.isNotEmpty && password.isNotEmpty) {
      encryptAndSaveCredentials(username!, password);
      if (silentLogin) {
        if (userProfileModel!.classifications!.student!) {
          CardsDataProvider().showAllStudentCards();
        } else if (userProfileModel!.classifications!.staff!) {
          CardsDataProvider().showAllStaffCards();
        }
      } else {
        return null;
      }
    }
    /// fetch data
    /// MODIFIED TO USE EXPONENTIAL RETRY
    var response = await NetworkHelper().authorizedPublicPost(
        "https://uokdbiyx00.execute-api.us-west-2.amazonaws.com/qa/v1.1/access-profile", {
      'x-api-key': "uRgcQKJKMW4WzC2scgUXUjbE7e8TQJN7JsfjVBK6",
      'Authorization': base64EncodedWithEncryptedPassword,
    }, null);

    /// check to see if response has an error
    if (response['errorMessage'] != null) {
      throw (response['errorMessage']);
    }
    /// parse data
    AuthenticationModel data = AuthenticationModel.fromJson(response);
    debugPrint("AuthenticationModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    return data;
  });
}

Future _fetchUserProfile() async {
  var authenticationModel = AuthenticationModel.fromJson({});

  if (authenticationModel!.isLoggedIn(_lastUpdated)) {
    /// we fetch the user data now
    final Map<String, String> headers = {
      'Authorization': 'Bearer ' + authenticationModel!.accessToken!
    };
    if (await UserProfileService().downloadUserProfile(headers)) {
      /// if the user profile has no ucsd affiliation then we know the user is new
      /// so create a new profile and upload to DB using [postUserProfile]
      UserProfileModel newModel = UserProfileService().userProfileModel!;
      if (newModel.ucsdaffiliation == null) {
        newModel = await _createNewUser(newModel);
        await _postUserProfile(newModel);
      } else {
        newModel.username = await getUsernameFromDevice();
        newModel.ucsdaffiliation = authenticationModel!.ucsdaffiliation;
        newModel.pid = authenticationModel!.pid;
        List<String> castSubscriptions =
        newModel.subscribedTopics!.cast<String>();
        newModel.subscribedTopics = castSubscriptions.toSet().toList();

        final studentPattern = RegExp('[BGJMU]');
        final staffPattern = RegExp('[E]');

        if ((newModel.ucsdaffiliation ?? "").contains(studentPattern)) {
          newModel
            ..classifications =
            Classifications.fromJson({'student': true, 'staff': false});
        } else if ((newModel.ucsdaffiliation ?? "").contains(staffPattern)) {
          newModel
            ..classifications =
            Classifications.fromJson({'staff': true, 'student': false});
        } else {
          newModel.classifications =
              Classifications.fromJson({'student': false, 'staff': false});
        }
        //update user profile model
        await _updateUserProfileModel(newModel);
        PushNotificationDataProvider()
            .subscribeToTopics(newModel.subscribedTopics!.cast<String>());
      }
    } else {
      return null;
    }
  } else {
    return null;
  }
}

Future<UserProfileModel> _createNewUser() async
{


  await PushNotificationDataProvider().fetchTopicsList();
  try {
    UserProfileModel profile;
    profile.username = await getUsernameFromDevice();
    profile.ucsdaffiliation = _authenticationModel!.ucsdaffiliation;
    profile.pid = _authenticationModel!.pid;
    profile.subscribedTopics = PushNotificationDataProvider().publicTopics();

    final studentPattern = RegExp('[BGJMU]');
    final staffPattern = RegExp('[E]');

    if ((profile.ucsdaffiliation ?? "").contains(studentPattern)) {
      profile
        ..classifications =
        Classifications.fromJson({'student': true, 'staff': false})
        ..subscribedTopics!
            .addAll(PushNotificationDataProvider().studentTopics());
    } else if ((profile.ucsdaffiliation ?? "").contains(staffPattern)) {
      profile
        ..classifications =
        Classifications.fromJson({'staff': true, 'student': false})
        ..subscribedTopics!
            .addAll(PushNotificationDataProvider().staffTopics());
    } else {
      profile.classifications =
          Classifications.fromJson({'student': false, 'staff': false});
    }
  } catch (e) {
    print(e.toString());
    rethrow;
  }
  return profile;
}

Future _postUserProfile(UserProfileModel? profile) async {
  /// save settings to local storage
  await _updateUserProfileModel(profile);
  /// check if user is logged in
  if (_authenticationModel!.isLoggedIn(AuthenticationService().lastUpdated)) {
    /// we only want to push data that is not null
    var tempJson = Map<String, dynamic>();
    for (var key in profile!.toJson().keys) {
      if (profile.toJson()[key] != null) {
        tempJson[key] = profile.toJson()[key];
      }
    }
  }
}

Future _updateUserProfileModel(UserProfileModel? model) async {
  var box;
  try {
    box = Hive.box<UserProfileModel?>('UserProfileModel');
  } catch (e) {
    box = await Hive.openBox<UserProfileModel?>('UserProfileModel');
  }
  await box.put('UserProfileModel', model);
  _lastUpdated = DateTime.now();
}

void _logout() async {
  PushNotificationDataProvider()
      .unregisterDevice(_authenticationModel!.accessToken);
  _updateAuthenticationModel(AuthenticationModel.fromJson({}));
  _updateUserProfileModel(await _createNewUser(UserProfileModel.fromJson({})));
  deleteUserCredentialsFromDevice();
  CardsDataProvider _cardsDataProvider = CardsDataProvider();
  _cardsDataProvider.updateAvailableCards("");
  var box = await Hive.openBox<AuthenticationModel?>('AuthenticationModel');
  await box.clear();
  await FirebaseAnalytics().logEvent(name: 'loggedOut');
}

Future _updateAuthenticationModel(AuthenticationModel? model) async {
  var box = await Hive.openBox<AuthenticationModel?>('AuthenticationModel');
  await box.put('AuthenticationModel', model);
  _lastUpdated = DateTime.now();
  return model;
}
