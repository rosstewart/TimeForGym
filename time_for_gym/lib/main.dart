// SKU: gymBrain_ross_stewart
// import 'dart:ffi';
// import 'dart:io';
//import 'dart:js_util';
// import 'dart:ui';
import 'dart:convert';
import 'dart:math';

// import 'package:flutter/cupertino.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_gif/flutter_gif.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:time_for_gym/active_workout.dart';
import 'package:time_for_gym/active_workout_window.dart';
import 'package:time_for_gym/activity.dart';
import 'package:time_for_gym/followers_page.dart';
import 'package:time_for_gym/friends_page.dart';
import 'package:time_for_gym/profile_page.dart';
import 'package:time_for_gym/search_friends_page.dart';
import 'package:time_for_gym/split_day_page.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image/image.dart' as img;
import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/gym.dart';
// import 'package:time_for_gym/favorites_page.dart';
import 'package:time_for_gym/home_page.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';
import 'package:time_for_gym/exercises_page.dart';
import 'package:time_for_gym/individual_exercise_page.dart';
import 'package:time_for_gym/gym_crowd_page.dart';
import 'package:time_for_gym/split_page.dart';
import 'package:time_for_gym/split.dart';
import 'package:time_for_gym/search_page.dart';
import 'package:time_for_gym/gym_page.dart';
import 'package:time_for_gym/auth_page.dart';
import 'package:time_for_gym/search_exercises_page.dart';
import 'package:time_for_gym/user.dart';

// import 'package:time_for_gym/split_exercise_index.dart';

// late final FirebaseApp app;
// late final FirebaseAuth auth;
late bool isAuthenticated;
late auth.User authUser;
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// /// Streams are created so that app can respond to notification-related events
// /// since the plugin is initialised in the `main` function
// final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
//     StreamController<ReceivedNotification>.broadcast();

// final StreamController<String?> selectNotificationStream =
//     StreamController<String?>.broadcast();
// // const String portName = 'notification_send_port';

// class ReceivedNotification {
//   ReceivedNotification({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.payload,
//   });

//   final int id;
//   final String? title;
//   final String? body;
//   final String? payload;
// }

// const String navigationActionId = 'id_3';

// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) {
//   // ignore: avoid_print
//   print('notification(${notificationResponse.id}) action tapped: '
//       '${notificationResponse.actionId} with'
//       ' payload: ${notificationResponse.payload}');
//   if (notificationResponse.input?.isNotEmpty ?? false) {
//     // ignore: avoid_print
//     print(
//         'notification action tapped with input: ${notificationResponse.input}');
//   }
// }

// const notificationPlatForm = MethodChannel('com.example.timeForGym.playSplitTimer');

void main() async {
  // GoogleMapsFlutter.init('YOUR_API_KEY');
  WidgetsFlutterBinding.ensureInitialized();
  // app = ...
  await Firebase.initializeApp(
    name: 'TimeForGym',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize();
  // Add the test device ID to the testDeviceIdentifiers list
  await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
    testDeviceIds: ['8fcb70467cd17250c50374ad37c5b590','2ED5E142-352D-4E02-822F-6A003D06EA30'], // Replace with your test device ID
  ));
  print(MobileAds.instance);
  await FirebaseAppCheck.instance.activate(
    // webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    // androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
        // your preferred provider. Choose from:
        // 1. Debug provider
        // 2. Device Check provider
        // 3. App Attest provider
        // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    // appleProvider: AppleProvider.debug,
    appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
  );


  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Ideal time to initialize
  // auth = FirebaseAuth.instanceFor(app: app);
  // auth.authStateChanges()...

  auth.FirebaseAuth.instance.authStateChanges().listen((auth.User? theUser) {
    if (theUser == null) {
      print('User is not previously authenticated');
      isAuthenticated = false;
    } else {
      print('User is previously authenticated');
      authUser = theUser;
      isAuthenticated = true;
    }
  });

  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true, // Enable offline persistence
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // var initializationSettingsAndroid =
  //     AndroidInitializationSettings('app_icon');
  // var initializationSettingsIOS = DarwinInitializationSettings(
  //   onDidReceiveLocalNotification:
  //       (int id, String? title, String? body, String? payload) async {
  //     didReceiveLocalNotificationStream.add(
  //       ReceivedNotification(
  //         id: id,
  //         title: title,
  //         body: body,
  //         payload: payload,
  //       ),
  //     );
  //   },
  // );
  // final DarwinInitializationSettings initializationSettingsDarwin =
  //     DarwinInitializationSettings(
  //   requestSoundPermission: true,
  //   requestBadgePermission: true,
  //   requestAlertPermission: true,
  //   onDidReceiveLocalNotification:
  //       (int id, String? title, String? body, String? payload) async {
  //     didReceiveLocalNotificationStream.add(
  //       ReceivedNotification(
  //         id: id,
  //         title: title,
  //         body: body,
  //         payload: payload,
  //       ),
  //     );
  //   },
  // );
  // var initializationSettings = InitializationSettings(
  //     // android: initializationSettingsAndroid,
  //     iOS: initializationSettingsDarwin);

  // await flutterLocalNotificationsPlugin.initialize(
  //   initializationSettings,
  //   onDidReceiveNotificationResponse:
  //       (NotificationResponse notificationResponse) {
  //     switch (notificationResponse.notificationResponseType) {
  //       case NotificationResponseType.selectedNotification:
  //         selectNotificationStream.add(notificationResponse.payload);
  //         break;
  //       case NotificationResponseType.selectedNotificationAction:
  //         if (notificationResponse.actionId == navigationActionId) {
  //           selectNotificationStream.add(notificationResponse.payload);
  //         }
  //         break;
  //     }
  //   },
  //   onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  // );
  tz.initializeTimeZones();

  // await auth.useAuthEmulator('localhost', 9099);

  runApp(MyApp());
}

Future<void> onReceivedNotificationResponse(var message) async {
  // This callback is triggered when the user interacts with the notification.
  // You can handle the action based on the payload of the notification.
  // For example, you can navigate to a specific screen in your app or perform some other action.
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  // const?
  MyApp({
    super.key,
  });

  final int red = 0;
  final int green = 159;
  final int blue = 153;

  final Color onBackground = Color.fromRGBO(17, 75, 95, 1);
  final Color secondaryColor = Color.fromRGBO(244, 91, 105, 1);

  @override
  Widget build(BuildContext context) {
    final MaterialColor primarySwatch = MaterialColor(
      Color.fromRGBO(2, 128, 144, 1).value,
      <int, Color>{
        50: Color.fromRGBO(red, green, blue, 0.1),
        100: Color.fromRGBO(red, green, blue, 0.2),
        200: Color.fromRGBO(red, green, blue, 0.3),
        300: Color.fromRGBO(red, green, blue, 0.4),
        400: Color.fromRGBO(red, green, blue, 0.5),
        500: Color.fromRGBO(red, green, blue, 0.6),
        600: Color.fromRGBO(red, green, blue, 0.7),
        700: Color.fromRGBO(red, green, blue, 0.8),
        800: Color.fromRGBO(red, green, blue, 0.9),
        900: Color.fromRGBO(red, green, blue, 1.0),
      },
    );

    Color backgroundColor = Color.fromRGBO(10, 10, 10, 1);
    Color container1 = Color.fromRGBO(20, 20, 20, 1);
    Color container2 = Color.fromRGBO(25, 25, 25, 1);
    Color container3 = Color.fromRGBO(30, 30, 30, 1);

    ThemeData theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: primarySwatch,
          primaryColorDark: onBackground,
          accentColor: secondaryColor,
          // cardColor: Color.fromRGBO(20, 20, 20, 1),
          backgroundColor: backgroundColor,
        ),
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundColor,
        dialogBackgroundColor: backgroundColor,
        // textTheme: textTheme,
        dialogTheme: DialogTheme(
            surfaceTintColor: backgroundColor,
            backgroundColor: backgroundColor),
        appBarTheme: AppBarTheme(
          // color: Color.fromRGBO(20, 20, 20, 1),
          surfaceTintColor: backgroundColor,
        ));

    // Create a new theme based on the original theme with the updated onBackground color
    theme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        onBackground: Color.fromRGBO(230, 230, 230, 1),
        onPrimary: Color.fromRGBO(235, 235, 235, 1),
        tertiary: Color.fromRGBO(17, 75, 95, 1),
        primaryContainer: container1,
        secondaryContainer: container2,
        tertiaryContainer: container3,
      ),
    );

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Time for Gym',
        theme: theme,
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier with WidgetsBindingObserver {
  late SharedPreferences prefs;
  // String _favoritesString = '';
  // String _currentSplitString = '';
  // String _splitDayExerciseIndicesString = '';

  // Local notifications
  // LocalNotificationTimerState localNotificationTimerState =
  //     LocalNotificationTimerState();

  // Google AdMob
  // late BannerAd _bannerAd;
  // late Widget bannerAdWidget;

  late String authUserId;
  String? authUsername;
  late User currentUser;
  List<User> visitedUsers = [];
  // TODO - In the future, with more users, getting all of the usernames on initialization will be too slow
  late List<String> allUsernames;

  // final Color onBackground = Color.fromRGBO(17, 75, 95, 1);

  // late bool isAuthenticated = false;
  bool noInternetInitialization = false;

  MyAppState() {
    initEverything();
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
      // _connectionStatus = 'No internet connection';
    } else {
      return true;
      // _connectionStatus = 'Connected';
    }
  }

  void initEverything() async {
    if (!(await checkConnectivity())) {
      // No internet connection
      noInternetInitialization = true;
      notifyListeners();
      return;
    }
    noInternetInitialization = false;

    if (!isAuthenticated) {
      notifyListeners();
      return;
    }
    await initEverythingAfterAuthentication();
    // initializeOldFavorites();
    // initializeFirebase(); // For storing user-reported occupancy data
    // uploadFolder();
  }

  // User will be initialized when this is called
  Future<void> initEverythingAfterAuthentication() async {
    authUserId = authUser
        .uid; // Need user id for muscle group exercise user popularity data
    // authUsername is initialized during sign up, otherwise use user display name
    authUsername ??= authUser.displayName;
    currentUser =
        User(username: authUsername!, email: authUser.email!, uid: authUserId);
    visitedUsers.add(currentUser);
    print('loading $currentUser');
    print('authentication user id: $authUserId');
    prefs = await SharedPreferences.getInstance();
    // initAds();
    // notifyListeners();
    // await initializeUserID(); // Need user id for muscle group exercise user popularity data
    await getDataFromFirestore(); // Need to initialize firestore strings to initialize favorites in initializeMuscleGroups
    currentUser.initializeProfilePicData();
    // await initPrefs(); // Need to initialize shared preferences strings to initialize favorites in initializeMuscleGroups
    await initializeMuscleGroups();
    await initGyms();
    await initializeGymCount();
    await initializeDefaultMusclesWorkedImage();
    isInitializing = false;
    notifyListeners();
    // initializeOldFavorites();
    // initializeFirebase(); // For storing user-reported occupancy data
    // uploadFolder();
  }

  Future<void> getDataFromFirestore() async {
    getAllUsernames();

    // Create a reference to the user document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(authUsername);

    // Get the document snapshot
    DocumentSnapshot snapshot = await userRef.get();

    // Check if the document exists
    if (snapshot.exists) {
      // Get the data as a Map
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

      currentUser.favoritesString = userData['favorites'] ?? '';
      currentUser.splitDayExerciseIndicesString =
          userData['splitDayExerciseIndices'] ?? '';
      currentUser.userGymId = userData['userGymId'] ?? '';
      currentUser.profilePictureUrl =
          userData['profilePictureUrl']; // Could be null
      currentUser.profilePictureDevicePath =
          userData['profilePictureDevicePath']; // Could be null
      currentUser.followers = (userData['followers'] ?? []).cast<String>();
      currentUser.following = (userData['following'] ?? []).cast<String>();
      currentUser.profileName = userData['profileName'] ?? '';
      currentUser.profileDescription = userData['profileDescription'] ?? '';
      currentUser.onlyFriendsCanViewPosts =
          userData['onlyFriendsCanViewPosts'] ?? false;

      List<dynamic> activityListJson = userData['activities'] ?? [];
      currentUser.activities = activityListJson
          .map((e) => Activity.fromJson(json.decode(e)))
          .toList();
      print(currentUser.activities);

      currentUser.splitJson = userData['split'];
      if (currentUser.splitJson != null) {
        Map<String, dynamic> splitMap = json.decode(currentUser.splitJson!);
        currentSplit = Split.fromJson(splitMap);
        makeNewSplit = false;
        print("initialized split: $currentSplit");

        // Shared preferences has priority
        if (prefs.containsKey('activeWorkout') && currentSplit != null) {
          currentUser.workout = ActiveWorkout.fromJson(
              json.decode(prefs.getString('activeWorkout')!), currentSplit);
          activeWorkout = currentUser.workout;
          activeWorkoutBannerPageController =
              PageController(initialPage: activeWorkout!.pageIndex);
        } else {
          String? workoutJson = userData['activeWorkout'];
          if (workoutJson != null && currentSplit != null) {
            currentUser.workout =
                ActiveWorkout.fromJson(json.decode(workoutJson), currentSplit);
            activeWorkout = currentUser.workout;
            activeWorkoutBannerPageController =
                PageController(initialPage: activeWorkout!.pageIndex);
            prefs.setString(
                'activeWorkout', json.encode(currentUser.workout!.toJson()));
            userRef.update({'activeWorkout': null}); // Remove from firebase
          }
        }
      } else {
        print("No split saved");
      }
      notifyListeners();
    } else {
      print('User $authUsername not found');
    }
  }

  Future<void> storeDataInFirestore() async {
    // Create a reference to the user document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(authUsername);
    if (currentSplit != null) {
      currentUser.splitJson = json.encode(currentSplit.toJson());
    } else {
      currentUser.splitJson = null;
    }

    // Create a map of user data
    Map<String, dynamic> userData = {
      'favorites': currentUser.favoritesString,
      'splitDayExerciseIndices': splitDayExerciseIndices
          .toString(), // TODO? : Store and retrieveas List<List<int>>
      'split': currentUser.splitJson,
      'userGymId': currentUser.userGymId,
      'profilePictureUrl': currentUser.profilePictureUrl,
      'profilePictureDevicePath': currentUser.profilePictureDevicePath,
      'followers': currentUser.followers,
      'following': currentUser.following,
      'profileName': currentUser.profileName,
      'profileDescription': currentUser.profileDescription,
      'activities': currentUser.activities.map((e) => json.encode(e.toJson())),
      'onlyFriendsCanViewPosts': currentUser.onlyFriendsCanViewPosts,
      // 'activeWorkout': currentUser.workout?.toJson(), // Could be null
    };

    // Set the user data to the document
    await userRef
        .update(userData)
        .then((value) => print('User data stored successfully'))
        .catchError((error) => print('Failed to store user data: $error'));
  }

  Future<void> getAllUsernames() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      allUsernames = querySnapshot.docs.map((doc) => doc.id).toList();
      allUsernames.remove(authUsername);
    } catch (e) {
      allUsernames = [];
      print('Error getting all usernames: $e');
    }
  }

  Future<void> initializeDefaultMusclesWorkedImage() async {
    final imageData =
        await rootBundle.load('muscle_group_pictures/muscle_anatomy_2.png');
    final bytes = Uint8List.view(imageData.buffer);
    defaultMuscleWorkedImage = img.decodePng(bytes);
    // Set the missing pixel in the rear left inner calf
    defaultMuscleWorkedImage?.setPixel(
        366, 382, img.ColorInt8.rgba(150, 150, 150, 255));
  }

  // void initAds() {
  //   _bannerAd = BannerAd(
  //     adUnitId: 'ca-app-pub-3940256099942544/2934735716',
  //     size: AdSize.banner,
  //     request: AdRequest(),
  //     listener: BannerAdListener(),
  //   );
  //   _bannerAd.load();
  //   bannerAdWidget = buildBannerAd();
  // }

  // Widget buildBannerAd() {
  //   return Container(
  //     alignment: Alignment.center,
  //     width: _bannerAd.size.width.toDouble(),
  //     height: _bannerAd.size.height.toDouble(),
  //     child: AdWidget(ad: _bannerAd),
  //   );
  // }

  Future<void> initGyms() async {
    // print('5 ${databaseRef.child('gymData').once()}');
    gyms = await fetchGymData();
    // Retrieve user gym from shared preferences id string
    // where is used and not first where to avoid error if not in the list
    List<Gym> userGymList = gyms.values
        .where((gym) => gym.placeId == currentUser.userGymId)
        .toList();
    if (userGymList.isNotEmpty) {
      userGym = userGymList[0];
    }
    print(currentUser.userGymId.isNotEmpty
        ? currentUser.userGymId
        : 'No user gym set');
  }

  // Future<void> initPrefs() async {
  // _prefs = await SharedPreferences.getInstance();
  // _favoritesString = _prefs.getString('favorites') ?? '';
  // _currentSplitString = _prefs.getString('currentSplit') ?? '';
  // _splitDayExerciseIndicesString =
  //     _prefs.getString('splitDayExerciseIndices') ?? '';
  // initializeOldFavorites();
  // userGymId = _prefs.getString('userGymId') ?? '';
  //   notifyListeners();
  // }

  // String get favoritesString => _favoritesString;

  // set favoritesString(String value) {
  //   _favoritesString = value;
  //   _prefs.setString('favorites', value);
  //   notifyListeners();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
  //     saveData();
  //   }
  // }

  Future<void> saveData() async {
    String favoriteExercisesAsString = "";
    for (Exercise exercise in favoriteExercises) {
      // name-muscleGroup,name-muscleGroup,etc.
      favoriteExercisesAsString +=
          "${exercise.toString()}=${exercise.mainMuscleGroup},";
    }
    if (favoriteExercisesAsString.isNotEmpty) {
      // Remove last comma
      favoriteExercisesAsString = favoriteExercisesAsString.substring(
          0, favoriteExercisesAsString.length - 1);
    }
    currentUser.favoritesString = favoriteExercisesAsString;
    storeDataInFirestore();
    // await _prefs.setString('favorites', _favoritesString);
  }

  // Future<void> saveSplitData() async {
  //   print(currentSplit.toMuscleGroupString());
  //   await _prefs.setString('currentSplit', currentSplit.toMuscleGroupString());
  // }

  Future<void> saveSplitDayExerciseIndicesData() async {
    print(splitDayExerciseIndices.toString());
    storeDataInFirestore();
    // await _prefs.setString(
    //     'splitDayExerciseIndices', splitDayExerciseIndices.toString());
  }

  // bool _appResumed = false;

  // bool get appResumed => _appResumed;

  // void updateAppResumed(bool resumed) {
  //   _appResumed = resumed;
  //   notifyListeners();
  // }

  // void init() {
  //   WidgetsBinding.instance.addObserver(this);
  // }

  // @override
  // void dispose() {
  //   // _bannerAd.dispose();
  //   super.dispose();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     updateAppResumed(true);
  //   } else {
  //     // App is paused, save favorite exercises data
  //     String favoriteExercisesAsString = "";
  //     for (Exercise exercise in favoriteExercises){
  //       favoriteExercisesAsString += "${exercise.toString()}-${exercise.mainMuscleGroup},";
  //     }
  //     if (favoriteExercisesAsString.isNotEmpty){ // Remove last comma
  //       favoriteExercisesAsString = favoriteExercisesAsString.substring(0,favoriteExercisesAsString.length-1);
  //     }
  //     storeString("favorites", favoriteExercisesAsString);
  //     updateAppResumed(false);
  //   }
  // }

// Store a favorite exercises upon app termination, in a string
// void storeString(String key, String value) async {
//   final prefs = await SharedPreferences.getInstance();
//   prefs.setString(key, value);
// }

// // Retrieve stored favorite exercsies
// Future<String?> getString(String key) async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString(key);
// }

  bool isInitializing = true;

  var favoriteExercises = <Exercise>[];
  int pageIndex = 13;

  Map<String, List<Exercise>> muscleGroups =
      <String, List<Exercise>>{}; // Map<String, List<Exercise>>
  Map<String, bool> areMuscleGroupImagesInitialized = {};
  var gymCount = -1;
  var maxCapacity = 200;

  var areMuscleGroupsInitialized = false;
  var isGymCountInitialized = false;

  var currentMuscleGroup = ""; // String
  Exercise currentExercise = Exercise(
      splitWeightAndReps: [],
      splitWeightPerSet: [],
      splitRepsPerSet: [],
      musclesWorked: [],
      musclesWorkedActivation: [],
      userOneRepMaxHistory: {});
  Exercise currentExerciseFromSplitDayPage = Exercise(
      splitWeightAndReps: [],
      splitWeightPerSet: [],
      splitRepsPerSet: [],
      musclesWorked: [],
      musclesWorkedActivation: [],
      userOneRepMaxHistory: {});
  Exercise currentExerciseFromGymPage = Exercise(
      splitWeightAndReps: [],
      splitWeightPerSet: [],
      splitRepsPerSet: [],
      musclesWorked: [],
      musclesWorkedActivation: [],
      userOneRepMaxHistory: {});
  Exercise currentExerciseFromProfilePage = Exercise(
      splitWeightAndReps: [],
      splitWeightPerSet: [],
      splitRepsPerSet: [],
      musclesWorked: [],
      musclesWorkedActivation: [],
      userOneRepMaxHistory: {});
  Exercise currentExerciseFromFriendsPage = Exercise(
      splitWeightAndReps: [],
      splitWeightPerSet: [],
      splitRepsPerSet: [],
      musclesWorked: [],
      musclesWorkedActivation: [],
      userOneRepMaxHistory: {});
  img.Image? defaultMuscleWorkedImage;
  Image? currentMuscleWorkedImage;
  Image? currentMuscleWorkedImageFromSplitDayPage;
  Image? currentMuscleWorkedImageFromGymPage;
  Image? currentMuscleWorkedImageFromProfilePage;
  Image? currentMuscleWorkedImageFromFriendsPage;

  Map<String, List<Widget>> gymPhotosMap = {};

  Map<String, List<Pixel>> imageMuscleLocations = {
    'Chest': [Pixel(108, 115), Pixel(143, 115)],
    'Front Delts': [Pixel(84, 107), Pixel(166, 107)],
    'Triceps': [
      Pixel(325, 148), // Long
      Pixel(317, 148), // Medial
      Pixel(312, 148), // Lateral
      Pixel(421, 148), // Long
      Pixel(430, 148), // Medial
      Pixel(435, 148) // Lateral
    ],
    'Biceps': [Pixel(72, 140), Pixel(179, 140)],
    'Brachioradialis': [
      Pixel(52, 183),
      Pixel(200, 183),
      Pixel(286, 215),
      Pixel(460, 215)
    ],
    'Tricep Long Head': [Pixel(325, 148), Pixel(421, 148)],
    'Tricep Medial Head': [Pixel(317, 148), Pixel(430, 148)],
    'Tricep Lateral Head:2': [Pixel(312, 148), Pixel(435, 148)],
    'Side Delts': [Pixel(74, 100), Pixel(178, 100)],
    'Upper Abs': [
      Pixel(115, 141),
      Pixel(115, 156),
      Pixel(135, 141),
      Pixel(135, 156)
    ],
    'Lower Abs': [
      Pixel(115, 173),
      Pixel(115, 200),
      Pixel(135, 173),
      Pixel(135, 200)
    ],
    'Glutes': [Pixel(355, 227), Pixel(390, 227)], // Glute maximus
    'Glute Medius': [
      Pixel(350, 202), // Glute medius
      Pixel(395, 202), // Glute medius
    ],
    'Hip Abductors': [
      Pixel(340, 257), // Tensor fascia latae
      Pixel(407, 258) // Tensor fascia latae
    ],
    'Quads': [
      Pixel(97, 298), // Outer
      Pixel(155, 295), // Outer
      Pixel(100, 260), // Mid
      Pixel(152, 260), // Mid
      Pixel(114, 304), // Inner
      Pixel(138, 304), // Inner
    ],
    'Hamstrings': [
      Pixel(342, 285), // Outer
      Pixel(352, 285), // Mid
      Pixel(361, 312), // Inner
      Pixel(385, 312),
      Pixel(393, 285),
      Pixel(405, 285)
    ],
    'Hip Adductors': [
      Pixel(119, 245),
      Pixel(131, 245),
      Pixel(364, 260),
      Pixel(381, 260)
    ],
    'Calves': [
      Pixel(115, 375), // Front
      Pixel(135, 375), // Front
      Pixel(346, 355), // Outer left
      Pixel(360, 355), // Inner left
      Pixel(388, 358), // Inner right
      Pixel(400, 355), // Outer right
    ],
    'Forearms': [
      Pixel(52, 183), // Brachioradialis
      Pixel(200, 183), // Brachioradialis
      Pixel(286, 215), // Brachioradialis
      Pixel(460, 215), // Brachioradialis
      Pixel(67, 177), // Underside Top
      Pixel(184, 177), // Underside Top
      Pixel(54, 195), // Underside Middle
      Pixel(198, 195), // Underside Middle
      Pixel(59, 198), // Underside Inner
      Pixel(192, 198), // Underside Inner
      Pixel(299, 193), // Outside Middle
      Pixel(448, 193), // Outside Middle
      Pixel(308, 193), // Outside Inner
      Pixel(439, 193), // Outside Inner
    ],
    'Rear Delts': [Pixel(325, 105), Pixel(420, 105)],
    'Obliques': [
      Pixel(100, 190),
      Pixel(151, 190),
      Pixel(348, 185),
      Pixel(397, 185)
    ],
    'Lower Back': [Pixel(363, 190), Pixel(382, 190)],
    'Upper Back': [
      // Upper traps
      Pixel(365, 82), // Rear view
      Pixel(383, 82), // Rear view
      Pixel(103, 87), // Front view
      Pixel(147, 87) // Front view
    ],
    'Traps': [
      // Upper traps
      Pixel(365, 82), // Rear view
      Pixel(383, 82), // Rear view
      Pixel(103, 87), // Front view
      Pixel(147, 87) // Front view
    ],
    'Mid Back': [
      // Upper traps
      Pixel(340, 115), // Teres
      Pixel(405, 115), // Teres
      Pixel(360, 115), // Lower Traps
      Pixel(385, 115) // Lower Traps
    ],
    'Lats': [
      Pixel(89, 140), // Front view
      Pixel(163, 140), // Front view
      Pixel(352, 150), // Rear view
      Pixel(392, 150) // Rear view
    ],
  };

  // var fromFavorites = false;
  bool fromSplitDayPage = false;
  bool fromSearchPage = false;
  bool fromGymPage = false;
  bool fromProfilePage = false;
  bool fromFriendsPage = false;
  int bottomNavigationIndex = 0;
  int lastVisitedSearchPage = -1;
  int savedBottomProfileIndex = 0;
  int savedFriendsPageIndex = 0;
  bool lastFriendsOrFriendsSearch = true;
  List<User> userProfileStack = []; // Which profiles the user is looking at
  List<User> userProfileStackFromOwnProfile =
      []; // Which profiles the user is looking at

  DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  Reference cloudStorageRef = FirebaseStorage.instance.ref();

  // Future<void> uploadFolder() async {
  //   final Directory folder = Directory('/Users/rossaroni/Desktop/gymPhotos');

  //   // Get a list of files in the folder
  //   final List<FileSystemEntity> keys = folder.listSync();
  //   int count = 0;
  //   for (final directory in keys) {
  //     print(count++);
  //     if (directory is Directory) {
  //       final String key = directory.path.split('/').last;
  //       // Get a list of files in the folder
  //       final List<FileSystemEntity> images = directory.listSync();
  //       for (final file in images) {
  //         if (file is File) {
  //           // Get the file name
  //           final String fileName = file.path.split('/').last;

  //           // Create a reference to the file in Firebase Storage
  //           final Reference storageRef =
  //               cloudStorageRef.child('gymPhotos').child(key).child(fileName);

  //           try {
  //             // Attempt to retrieve the download URL
  //             await storageRef.getDownloadURL();
  //             continue; // File exists
  //           } catch (e) {
  //             if (e is FirebaseException && e.code == 'object-not-found') {
  //               // File does not exist
  //               // Upload the file
  //               final TaskSnapshot snapshot = await storageRef.putFile(file);

  //               // Get the download URL for the uploaded file
  //               final String downloadURL = await snapshot.ref.getDownloadURL();

  //               // Print the download URL (optional)
  //               print('File uploaded: $downloadURL');
  //             }
  //             // Handle other exceptions
  //             rethrow;
  //           }
  //         }
  //       }
  //     }
  //   }
  // }

  var hasSubmittedData = false;

  var currentSplit;
  var makeNewSplit = true;

  int currentDayIndex = -1;
  bool splitDayEditMode = false;
  bool splitDayReorderMode = false;
  var editModeTempSplit;
  var editModeTempExerciseIndices;

  bool splitWeekEditMode = false;

  bool goStraightToSplitDayPage = false;
  int presetSearchPage =
      0; // 0 for search page, 1 for muscle group, 2 for exercise
  int presetHomePage = 0;
  bool defaultFriendsPageFollowersPage = true;
  bool defaultProfilePageFollowersPage = true;

  List<List<int>> splitDayExerciseIndices = [[], [], [], [], [], [], []];

  // String userID = '';

  List<Widget> appPages = [
    HomePage(),
    Placeholder(),
    Placeholder(),
    GymCrowdPage(),
    ExercisesPage(),
    IndividualExercisePage(),
    SplitPage(),
    SplitDayPage(0),
    SearchPage(),
    GymPage(
      gym: null,
      isSelectedGym: false,
    ),
    SearchExercisesPage([]),
    ProfilePage(null, true, true, null),
    FollowersPage(null, true),
    FriendsPage(),
    SearchFriendsPage(),
    OtherUserProfilePage(null, false),
    FollowersPage(null, false),
    OtherUserProfilePage(null, true),
  ];
  bool reloadFriendsPage = false;

  bool isHomePageSearchFieldFocused = false;
  Map<String, Gym> gyms = <String, Gym>{};
  Gym? currentGym;
  // PlaceDetails? currentGymPlacesDetailsResponse;
  Gym? userGym;

  List<Widget> currentGymPhotos = [];
  // Monday - Sunday, 12 AM - 11 PM
  final List<List<int>> avgGymCrowdData = [
    [0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 4, 3, 4, 5, 5, 6, 10, 11, 11, 8, 6, 3, 3, 2],
    [1, 0, 0, 0, 1, 2, 3, 3, 2, 2, 3, 3, 5, 5, 5, 5, 10, 10, 12, 9, 4, 4, 3, 2],
    [1, 0, 0, 0, 2, 2, 3, 3, 3, 3, 4, 3, 4, 5, 4, 7, 10, 12, 10, 9, 5, 4, 3, 2],
    [2, 0, 0, 0, 2, 2, 6, 4, 3, 2, 3, 3, 5, 5, 4, 5, 10, 12, 10, 8, 5, 3, 3, 2],
    [2, 0, 0, 0, 2, 2, 3, 4, 3, 2, 3, 5, 4, 6, 7, 7, 10, 10, 7, 4, 3, 2, 2, 2],
    [1, 1, 0, 0, 0, 0, 2, 2, 2, 4, 7, 8, 6, 6, 6, 5, 5, 4, 4, 2, 2, 1, 2, 1],
    [0, 0, 0, 0, 0, 0, 1, 1, 2, 3, 4, 4, 4, 4, 3, 4, 4, 3, 2, 2, 2, 1, 1, 1]
  ];

  // String userGymId = '';
  int showAdBeforeExerciseCounter =
      2; // Number of exercises before ad pops up (-1)

  ActiveWorkout? activeWorkout;
  late PageController activeWorkoutBannerPageController;

  void setSplit(Split split) {
    currentSplit = split;
    // Reset exercise indices
    splitDayExerciseIndices = [[], [], [], [], [], [], []];
    for (int i = 0; i < split.trainingDays.length; i++) {
      print(
          'exercise names length: ${split.trainingDays[i].exerciseNames.length}');
      for (int j = 0; j < split.trainingDays[i].exerciseNames.length; j++) {
        addExerciseToSplit(this, split.trainingDays[i].exerciseIdentifiers[j],
            userGym, splitDayExerciseIndices, i, j, split);

        // Compound movement, adjust rest time
        if (split.trainingDays[i].restTimeInSeconds.length > j) {
          if (muscleGroups[split.trainingDays[i].muscleGroups[j]]![
                      splitDayExerciseIndices[i][j]]
                  .isAccessoryMovement ==
              false) {
            split.trainingDays[i].restTimeInSeconds[j] = 180;
          }
        }
        print('Added exercise to day $i, exercise $j');
      }
    }
    cancelWorkout(true); // Don't notifyListeners twice
    storeSplitInSharedPreferences(); // Also sets the values of exerciseNames
    print(split.trainingDays[0].exerciseNames);
    saveSplitDayExerciseIndicesData();
    makeNewSplit = false;
    notifyListeners();
  }

  // Split is still saved in currentSplit, but user can now make a new split
  void setMakeNewSplit(bool regenerate) {
    makeNewSplit = regenerate;
    notifyListeners();
  }

  void shiftSplit(Split split, List<List<int>> exerciseIndices, int numDays) {
    split.shift(numDays);
    shiftExerciseIndices(exerciseIndices, numDays);

    print("shifted split: $split");
    print("shifted exercise indices: $exerciseIndices");
    notifyListeners();

    // storeSplitInSharedPreferences();
    // saveSplitDayExerciseIndicesData();
  }

  void shiftExerciseIndices(List<List<int>> exerciseIndices, int numDays) {
    int n = exerciseIndices.length;
    int k;

    if (numDays >= 0) {
      k = numDays % n;
    } else {
      k = (n - (-numDays % n)) % n;
    }

    reverseExerciseIndices(exerciseIndices, 0, n - 1);
    reverseExerciseIndices(exerciseIndices, 0, k - 1);
    reverseExerciseIndices(exerciseIndices, k, n - 1);
  }

  void reverseExerciseIndices(
      List<List<int>> exerciseIndices, int start, int end) {
    while (start < end) {
      List<int> temp = exerciseIndices[start];
      exerciseIndices[start] = exerciseIndices[end];
      exerciseIndices[end] = temp;
      start++;
      end--;
    }
  }

  void toSplitWeekEditMode(bool edit) {
    splitWeekEditMode = edit;
    if (edit) {
      // Use same temporary data structures for split week edit
      editModeTempSplit = Split.deepCopy(currentSplit);
      editModeTempExerciseIndices =
          splitDayExerciseIndices.map((innerList) => [...innerList]).toList();
    }
    notifyListeners();
  }

  void saveWeekEditChanges() {
    // Variables now point to the new objects
    currentSplit = editModeTempSplit;
    splitDayExerciseIndices = editModeTempExerciseIndices;

    storeSplitInSharedPreferences();
    saveSplitDayExerciseIndicesData();
    toSplitWeekEditMode(false);
  }

  void toSplitDayEditMode(bool edit) {
    // print("current split $splitDayExerciseIndices");
    // print("temp split $editModeTempExerciseIndices");
    splitDayEditMode = edit;
    if (edit) {
      editModeTempSplit = Split.deepCopy(currentSplit);
      editModeTempExerciseIndices =
          splitDayExerciseIndices.map((innerList) => [...innerList]).toList();
    }
    notifyListeners();
  }

  void toSplitDayReorderMode(bool reorder) {
    // print("current split $splitDayExerciseIndices");
    // print("temp split $editModeTempExerciseIndices");
    splitDayReorderMode = reorder;
    if (reorder) {
      // Use edit mode copies for reorder mode, as they don't overlap
      editModeTempSplit = Split.deepCopy(currentSplit);
      editModeTempExerciseIndices =
          splitDayExerciseIndices.map((innerList) => [...innerList]).toList();
    } else {
      editModeTempSplit = null;
      editModeTempExerciseIndices = null;
    }
    notifyListeners();
  }

  // void saveEditChanges() {
  //   // Variables now point to the new objects
  //   currentSplit = editModeTempSplit;
  //   splitDayExerciseIndices = editModeTempExerciseIndices;

  //   storeSplitInSharedPreferences();
  //   saveSplitDayExerciseIndicesData();
  //   toSplitDayEditMode(false);
  // }

  void saveReorderChanges() {
    // Variables now point to the new objects
    if (editModeTempSplit != null && editModeTempExerciseIndices != null) {
      currentSplit = editModeTempSplit;
      splitDayExerciseIndices = editModeTempExerciseIndices;
    }

    storeSplitInSharedPreferences();
    saveSplitDayExerciseIndicesData();
    toSplitDayReorderMode(false);
  }

  void addTempMuscleGroupToSplit(
      int dayIndex,
      int cardIndex,
      String muscleGroup,
      int muscleGroupExerciseIndex,
      int numSets,
      String identifier,
      String setName,
      String exerciseName,
      bool isSuperset,
      int restTime) {
    editModeTempSplit.trainingDays[dayIndex].insertMuscleGroup(
        cardIndex,
        muscleGroup,
        numSets,
        identifier,
        setName,
        exerciseName,
        isSuperset,
        restTime);
    editModeTempExerciseIndices[dayIndex]
        .insert(cardIndex, muscleGroupExerciseIndex);
    notifyListeners();
  }

  void addMuscleGroupToSplit(
      Split split,
      int dayIndex,
      int cardIndex,
      String muscleGroup,
      int muscleGroupExerciseIndex,
      int numSets,
      String identifier,
      String setName,
      String exerciseName,
      bool isSuperset,
      int restTime) {
    split.trainingDays[dayIndex].insertMuscleGroup(cardIndex, muscleGroup,
        numSets, identifier, setName, exerciseName, isSuperset, restTime);
    if (split == currentSplit) {
      // If pointers are the same
      splitDayExerciseIndices[dayIndex]
          .insert(cardIndex, muscleGroupExerciseIndex);
      storeSplitInSharedPreferences();
      saveSplitDayExerciseIndicesData();
    } else {
      editModeTempExerciseIndices[dayIndex]
          .insert(cardIndex, muscleGroupExerciseIndex);
    }
    notifyListeners();
  }

  List<dynamic> removeMuscleGroupFromSplit(
      Split split, int dayIndex, int cardIndex) {
    final muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName =
        split.trainingDays[dayIndex].removeMuscleGroup(cardIndex);
    final exerciseIndex = split == currentSplit
        ? splitDayExerciseIndices[dayIndex].removeAt(cardIndex)
        : editModeTempExerciseIndices[dayIndex].removeAt(cardIndex);
    if (split == currentSplit) {
      // If pointers are the same
      storeSplitInSharedPreferences();
      saveSplitDayExerciseIndicesData();
    }
    notifyListeners();
    // muscle group, exercise index, number of sets
    return [
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[0],
      exerciseIndex,
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[1],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[2],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[3],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[4],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[5],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[6],
    ];
  }

  List<dynamic> removeTempMuscleGroupFromSplit(int dayIndex, int cardIndex) {
    final muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName =
        editModeTempSplit.trainingDays[dayIndex].removeMuscleGroup(cardIndex);
    final exerciseIndex =
        editModeTempExerciseIndices[dayIndex].removeAt(cardIndex);
    notifyListeners();
    // muscle group, exercise index, number of sets
    return [
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[0],
      exerciseIndex,
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[1],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[2],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[3],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[4],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[5],
      muscleGroupAndNumSetsAndIdentifierAndSetAndExerciseName[6],
    ];
  }

  Future<void> initializeMuscleGroups() async {
    if (areMuscleGroupsInitialized) {
      // Stop from initializing multiple times
      return;
    }
    // const filePath = '/Users/rossaroni/FlutterProjects/time_for_gym/ExerciseData.txt';
    String url =
        'https://raw.githubusercontent.com/rosstewart/TimeForGym/main/time_for_gym/ExerciseData.txt';
    muscleGroups = await readLinesFromFile(url);

    areMuscleGroupsInitialized = true;

    // Wait until map is initialized before extracting previous favorite exercises & split data
    initializeOldFavorites();
    // await retrieveSplitFromSharedPreferences(); // This action is performed in initializing from firestore
    initializeSplitDataAndExerciseIndices();
    notifyListeners();
  }

  Future<Map<String, List<Exercise>>> readLinesFromFile(String url) async {
    // final file = File(filePath);
    // final lines = await file.readAsLines();

    http.Response response = await http.get(Uri.parse(url));
    String fileContents = response.body;
    // print(fileContents);
    List<String> lines = fileContents.split("\n");

    Map<String, List<Exercise>> newMap = <String, List<Exercise>>{};
    List<String> attributes;
    List<Exercise> exercises = <Exercise>[];
    Exercise exercise;

    String muscleGroup = "";
    bool start = true;

    Map<String, List<dynamic>> exerciseDataMap = await fetchExerciseData();
    // String => [List<double?>, List<int>, List<int>]

    String midChestFly =
        'Mid Chest:3, Upper Chest:2, Lower Chest:2, Front Delts:1, Biceps:1';
    String chestPress =
        'Mid Chest:3, Lower Chest:2, Upper Chest:2, Front Delts:2, Triceps:1';
    String inclinePress =
        'Upper Chest:3, Mid Chest:2, Front Delts:2, Triceps:1';
    String lowerPress = 'Lower Chest:3, Mid Chest:2, Front Delts:2, Triceps:1';
    String latPulldown = 'Lats:3, Mid Back:1, Biceps:1, Rear Delts:1';
    String upperBackRow =
        'Upper Back:3, Mid Back:2, Lats:1, Lower Back:1, Biceps:1, Rear Delts:1';
    String lowRow =
        'Mid Back:3, Lats:2, Upper Back:1, Lower Back:1, Biceps:1, Rear Delts:1';
    String upperBackChestSupportedRow =
        'Upper Back:3, Mid Back:2, Lats:1, Biceps:1, Rear Delts:1';
    String lowChestSupportedRow =
        'Mid Back:3, Lats:2, Upper Back:1, Biceps:1, Rear Delts:1';
    String overallBicep = 'Bicep Long Head:3, Bicep Short Head:3';
    String bicepLongHead = 'Bicep Long Head:3, Bicep Short Head:2';
    String bicepShortHead = 'Bicep Short Head:3, Bicep Long Head:2';
    String bicepBrachialis =
        'Brachialis:3, Bicep Long Head:2, Bicep Short Head:2, Brachioradialis:2';
    String tricepLongHead =
        'Tricep Long Head:3, Tricep Lateral Head:2, Tricep Medial Head:2';
    String tricepLateralHead =
        'Tricep Lateral Head:3, Tricep Long Head:2, Tricep Medial Head:2';
    String tricepMedialHead =
        'Tricep Medial Head:3, Tricep Long Head:2, Tricep Lateral Head:2';
    String seatedShoulderPress = 'Front Delts:3, Triceps:2, Side Delts:1';
    String standingShoulderPress =
        'Front Delts:3, Triceps:2, Side Delts:1, Lower Back:1';

    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      }
      if (line.startsWith('MuscleGroup: ')) {
        if (!start) {
          exercises.sort(); // Sort alphabetically
          newMap.putIfAbsent(muscleGroup, () => exercises);
          initializeMuscleGroupImageExists(muscleGroup);
          // print(newMap);
          exercises = <Exercise>[]; // Allocate memory for new list of exercises
          // print(newMap);
        } else {
          start = false;
        }
        muscleGroup =
            line.substring('MuscleGroup: '.length); // Save muscle group
      } else {
        attributes = line.split("|");

        // User rating will be null if there doesn't exist an entry for that user under the exercise
        // List<double?> userRatingAndAverageRating =
        //     await fetchExerciseData(attributes[0]);
        List<double?> userRatingAndAverageRatingAnd1RMAndWeightAndReps;
        int? userOneRepMax;
        List<int> userSplitWeightAndReps;
        List<int> userSplitWeightPerSet;
        List<int> userSplitRepsPerSet;
        Map<int, int> userOneRepMaxHistory;

        if (exerciseDataMap[attributes[0]] == null) {
          // No star data or one rep max data for this exercise
          userRatingAndAverageRatingAnd1RMAndWeightAndReps = [
            null,
            0.0,
            null,
            null,
            null
          ]; // user rating and one rep max are null
          userOneRepMax = null;
          userSplitWeightAndReps = [];
          userSplitWeightPerSet = [];
          userSplitRepsPerSet = [];
          userOneRepMaxHistory = {};
        } else {
          userRatingAndAverageRatingAnd1RMAndWeightAndReps =
              exerciseDataMap[attributes[0]]![0];
          if (userRatingAndAverageRatingAnd1RMAndWeightAndReps[1] == null) {
            userRatingAndAverageRatingAnd1RMAndWeightAndReps[1] = 0.0;
          }
          if (userRatingAndAverageRatingAnd1RMAndWeightAndReps[2] != null) {
            userOneRepMax =
                userRatingAndAverageRatingAnd1RMAndWeightAndReps[2]!.toInt();
          } else {
            userOneRepMax = null;
          }
          if (userRatingAndAverageRatingAnd1RMAndWeightAndReps[3] != null &&
              userRatingAndAverageRatingAnd1RMAndWeightAndReps[4] != null) {
            userSplitWeightAndReps = [
              userRatingAndAverageRatingAnd1RMAndWeightAndReps[3]!.toInt(),
              userRatingAndAverageRatingAnd1RMAndWeightAndReps[4]!.toInt()
            ];
          } else {
            userSplitWeightAndReps = [];
          }
          if (exerciseDataMap[attributes[0]]![1] == null ||
              exerciseDataMap[attributes[0]]![2] == null) {
            // Either they are both null or both not null
            userSplitWeightPerSet = [];
            userSplitRepsPerSet = [];
          } else {
            userSplitWeightPerSet = exerciseDataMap[attributes[0]]![1];
            userSplitRepsPerSet = exerciseDataMap[attributes[0]]![2];
          }
          userOneRepMaxHistory = exerciseDataMap[attributes[0]]![3] ?? {};
        }
        print(
            "${attributes[0]} ${userRatingAndAverageRatingAnd1RMAndWeightAndReps[0]} ${userRatingAndAverageRatingAnd1RMAndWeightAndReps[1]} $userOneRepMax $userSplitWeightAndReps");
        print("$userSplitWeightPerSet $userSplitRepsPerSet");

        // if (userRatingAndAverageRating[1] == null) {
        //   // No rating data
        //   userRatingAndAverageRating[1] =
        //       0.0; // Default value for average star rating
        // }

        String videoLink = attributes[3];
        if (videoLink.isEmpty || videoLink == 'Video Link') {
          // If no video link attribute
          videoLink =
              "https://www.youtube.com/results?search_query=how+to+${attributes[0].replaceAll(' ', '+')}";
        }

        List<String> resourcesRequired = attributes[5].split(",");
        double waitMultiplier = 0.0;
        if (!resourcesRequired.contains('None')) {
          resourceRequiredLoop:
          for (String resourceRequired in resourcesRequired) {
            // TODO:
            // To accurately calculate wait multiplier, will need list of how many of each resource available in the gym
            // Also, will need to loop through every exercise and add up the popularity of benches, dumbbells, etc.
            switch (resourceRequired) {
              // Wait multiplier estimation for UM gym
              case 'Barbell':
                waitMultiplier += 0.4;
                break;
              case 'Dumbbells':
                waitMultiplier += 0.2;
                break;
              case 'Bench':
                waitMultiplier += 0.6;
                break;
              case 'Cable':
                waitMultiplier += 0.5;
                break;
              case 'EZ-bar':
                waitMultiplier += 0.3;
                break;
              case 'Pull-Up Bar':
                waitMultiplier += 0.2;
                break;
              case 'Machine':
                // If machine, wait multiplier will just be how popular the machine is on average
                if (userRatingAndAverageRatingAnd1RMAndWeightAndReps[1]! != 0) {
                  waitMultiplier =
                      userRatingAndAverageRatingAnd1RMAndWeightAndReps[1]! /
                          5.0; // Always a number 0-5 or 0
                } else {
                  // No rating
                  waitMultiplier += 0.5;
                }
                break resourceRequiredLoop;
              case 'Preacher Bench':
                waitMultiplier += 0.3;
                break;
              case 'Parallel Bars':
                waitMultiplier += 0.2;
                break;
              case 'Rack':
                waitMultiplier += 0.5;
                break;
              case 'Cable Lat Pulldown':
                waitMultiplier += 0.5;
                break;
              case 'Cable Row':
                waitMultiplier += 0.5;
                break;
              case 'Incline Bench Press':
                waitMultiplier += 0.5;
                break;
              case 'Decline Bench Press':
                waitMultiplier += 0.5;
                break;
              default:
                print('Unsupported: $resourceRequired');
                break;
            }
          }
        }
        if (waitMultiplier > 1.0) {
          waitMultiplier = 1.0;
        }
        String? machineAltName;
        if (resourcesRequired.contains('Machine')) {
          if (attributes.length == 8) {
            machineAltName = attributes[7];
          }
        }
        String musclesWorkedString = attributes[2];
        String exerciseIdentifer = "";
        switch (musclesWorkedString) {
          case "midChestFly":
            // Code for overallChest
            musclesWorkedString = midChestFly;
            exerciseIdentifer = "midChestFly";
            break;
          case "chestPress":
            // Code for chestPress
            musclesWorkedString = chestPress;
            exerciseIdentifer = "chestPress";
            break;
          case "inclinePress":
            // Code for inclinePress
            musclesWorkedString = inclinePress;
            exerciseIdentifer = "inclinePress";
            break;
          case "lowerPress":
            // Code for lowerPress
            musclesWorkedString = lowerPress;
            exerciseIdentifer = "lowerPress";
            break;
          case "latPulldown":
            // Code for latPulldown
            musclesWorkedString = latPulldown;
            exerciseIdentifer = "latPulldown";
            break;
          case "upperBackRow":
            // Code for upperBackRow
            musclesWorkedString = upperBackRow;
            exerciseIdentifer = "upperBackRow";
            break;
          case "lowRow":
            // Code for lowRow
            musclesWorkedString = lowRow;
            exerciseIdentifer = "lowRow";
            break;
          case "upperBackChestSupportedRow":
            // Code for upperBackChestSupportedRow
            musclesWorkedString = upperBackChestSupportedRow;
            exerciseIdentifer = "upperBackChestSupportedRow";
            break;
          case "lowChestSupportedRow":
            // Code for lowChestSupportedRow
            musclesWorkedString = lowChestSupportedRow;
            exerciseIdentifer = "lowChestSupportedRow";
            break;
          case "overallBicep":
            // Code for overallBicep
            musclesWorkedString = overallBicep;
            exerciseIdentifer = "overallBicep";
            break;
          case "bicepLongHead":
            // Code for bicepLongHead
            musclesWorkedString = bicepLongHead;
            exerciseIdentifer = "bicepLongHead";
            break;
          case "bicepShortHead":
            // Code for bicepShortHead
            musclesWorkedString = bicepShortHead;
            exerciseIdentifer = "bicepShortHead";
            break;
          case "bicepBrachialis":
            // Code for bicepBrachialis
            musclesWorkedString = bicepBrachialis;
            exerciseIdentifer = "bicepBrachialis";
            break;
          case "tricepLongHead":
            // Code for tricepLongHead
            musclesWorkedString = tricepLongHead;
            exerciseIdentifer = "tricepLongHead";
            break;
          case "tricepLateralHead":
            // Code for tricepLateralHead
            musclesWorkedString = tricepLateralHead;
            exerciseIdentifer = "tricepLateralHead";
            break;
          case "tricepMedialHead":
            // Code for tricepMedialHead
            musclesWorkedString = tricepMedialHead;
            exerciseIdentifer = "tricepMedialHead";
            break;
          case "seatedShoulderPress":
            // Code for seatedShoulderPress
            musclesWorkedString = seatedShoulderPress;
            exerciseIdentifer = "seatedShoulderPress";
            break;
          case "standingShoulderPress":
            // Code for standingShoulderPress
            musclesWorkedString = standingShoulderPress;
            exerciseIdentifer = "standingShoulderPress";
            break;
          default:
            print(musclesWorkedString);
            break;
        }

        List<String> musclesWorkedList =
            musclesWorkedString.split(',').map((e) => e.trim()).toList();
        List<String> musclesWorked = [];
        List<int> musclesWorkedActivation = [];
        for (String muscleAndActivationString in musclesWorkedList) {
          List<String> muscleAndActivation =
              muscleAndActivationString.split(':');
          musclesWorked.add(muscleAndActivation[0]);
          musclesWorkedActivation.add(int.parse(muscleAndActivation[1]));
        }

        // Would make 3 different versions of "Squat", with 3 different mainMuscleGroups. Since mainMuscleGroup is only used for finding an exercise, this does not cause any issues.
        exercise = Exercise(
            name: attributes[0],
            description: attributes[1],
            musclesWorked: musclesWorked,
            musclesWorkedActivation: musclesWorkedActivation,
            identifier: exerciseIdentifer,
            // videoLink: attributes[3],
            videoLink: videoLink,
            // waitMultiplier: double.parse(attributes[4]),
            waitMultiplier: waitMultiplier,
            mainMuscleGroup: muscleGroup,
            starRating: userRatingAndAverageRatingAnd1RMAndWeightAndReps[1]!,
            // Temporarily all image must be gifs and images have same name as exercise name
            imageUrl:
                "${url.replaceFirst("ExerciseData.txt", "exercise_pictures/")}${attributes[0]}.gif",
            userRating: userRatingAndAverageRatingAnd1RMAndWeightAndReps[0],
            resourcesRequired: attributes[5].split(","),
            machineAltName: machineAltName,
            userOneRepMax: userOneRepMax,
            isAccessoryMovement: int.parse(attributes[6]) != 0,
            splitWeightAndReps: userSplitWeightAndReps,
            splitWeightPerSet: userSplitWeightPerSet,
            splitRepsPerSet: userSplitRepsPerSet,
            userOneRepMaxHistory: userOneRepMaxHistory);

        initializeExerciseImageExists(exercise);

        // // If exercise already in favorites, no need to allocate memory for a new exercise
        // if (favoriteExercises.contains(exercise)){
        //   print("Adding previous favorite exercise to map");
        //   exercises.add(favoriteExercises.firstWhere((e) => e.name == exercise.name));
        // } else {
        exercises.add(exercise);
        // }
      }
    }

    // print(muscleGroup);
    // print(exercises);

    newMap.putIfAbsent(muscleGroup, () => exercises);
    initializeMuscleGroupImageExists(muscleGroup);

    print("Muscle group map: $newMap");

    // print(jsonEncode(newMap));
    // File file = File("/Users/rossaroni/Desktop/MuscleGroupMap.json");
    // file.writeAsStringSync(jsonEncode(newMap));
    // print('JSON data written to file: MuscleGroupMap.json');

    return newMap;
  }

  void initializeExerciseImageExists(Exercise exercise) async {
    exercise.imageExists =
        await checkAssetExists("exercise_pictures/${exercise.name}_m.gif");
  }

  void initializeMuscleGroupImageExists(String muscleGroup) async {
    areMuscleGroupImagesInitialized[muscleGroup] =
        await checkAssetExists("muscle_group_pictures/$muscleGroup.jpeg");
  }

// Function to download and create a container with the image from a URL
  // Future<Uint8List> downloadImageFromUrl(String imageUrl) async {
  //   http.Response response = await http.get(Uri.parse(imageUrl));
  //   if (response.statusCode == 200) {
  //     // Uint8List imageBytes = response.bodyBytes;
  //     // ImageProvider imageProvider = MemoryImage(imageBytes);

  //     return response.bodyBytes;

  //     // print("worked $imageUrl");

  //     // return Container(
  //     //   decoration: BoxDecoration(
  //     //     image: DecorationImage(
  //     //       image: imageProvider,
  //     //       fit: BoxFit.cover,
  //     //     ),
  //     //   ),
  //     // );
  //   } else {
  //     print(imageUrl);
  //     // print('Failed to load image. Status code: ${response.statusCode}');
  //     throw Exception(
  //         'Failed to load image. Status code: ${response.statusCode}');
  //     // return Container(); // Return an empty container if image loading fails
  //   }
  // }

  Future<void> initializeGymCount() async {
    if (isGymCountInitialized) {
      // Stop from initializing multiple times
      return;
    }
    gymCount = await getLiveCount();
    print("Initialized gym count: $gymCount");
    isGymCountInitialized = true;
  }

  Future<int> getLiveCount() async {
    String url = 'https://wellness.miami.edu/facilityoccupancy/';

    http.Response response = await http.get(Uri.parse(url));
    String fileContents = response.body;
    // print(fileContents);
    List<String> lines = fileContents.split("\n");

    String htmlCount =
        "                            <p class=\"occupancy-count\"><strong>";
    int liveCountIndex = htmlCount.length;
    int liveCountLength = 3;
    int liveCount;

    for (final line in lines) {
      if (line.startsWith(htmlCount)) {
        String liveCountString =
            line.substring(liveCountIndex, liveCountIndex + liveCountLength);
        if (liveCountString.endsWith('<')) {
          // 2 digit
          liveCountString = liveCountString.substring(0, 2);
        } else if (liveCountString.endsWith('/')) {
          // 1 digit
          liveCountString = liveCountString.substring(0, 1);
        } // Otherwise, 3 digit
        liveCount = int.parse(liveCountString);
        return liveCount;
      }
    }

    return -1;
  }

  void initializeOldFavorites() {
    if (currentUser.favoritesString.isEmpty) {
      print("No favorite exercises");
      return;
    }

    List<String> favoriteStrings = currentUser.favoritesString.split(",");

    for (String favoriteString in favoriteStrings) {
      // For each exercise
      List<String> nameAndMuscleGroup =
          favoriteString.split("="); // Split up name and muscle group
      String name = nameAndMuscleGroup[0];
      String muscleGroupOfExercise = nameAndMuscleGroup[1];

      // print(muscleGroupOfExercise);
      if (muscleGroups[muscleGroupOfExercise] == null) {
        print("Error - muscleGroups is null");
        return;
      }

      // No binary search as exercises aren't sorted by name anymore
      int index = muscleGroups[muscleGroupOfExercise]!
          .indexWhere((exercise) => exercise.name == name);
      // binarySearchExerciseList(muscleGroups[muscleGroupOfExercise]!, name);
      if (index < 0) {
        print("ERROR - previous favorite exercise not found");
      } else {
        print(
            "Favorite exercise <${muscleGroups[muscleGroupOfExercise]![index].toString()}> found at muscle group <$muscleGroupOfExercise>, index $index");
        favoriteExercises.add(muscleGroups[muscleGroupOfExercise]![index]);
      }

      // for (Exercise exercise in muscleGroups[muscleGroupOfExercise]!) {
      //   if  // Binary search?
      // }
    }
  }

  void initializeSplitDataAndExerciseIndices() {
    // splitDayExerciseIndices = [[],[],[],[],[],[],[]];
    // _splitDayExerciseIndicesString = "";
    // return;
    if (currentUser.splitDayExerciseIndicesString.isEmpty) {
      print("No split exercise index data saved");
      return;
    }

    // // Remove the enclosing square brackets
    // String cleanedInput = _splitDayExerciseIndicesString.substring(
    //     1, _splitDayExerciseIndicesString.length - 1);

    // // Split the string into individual row strings
    // List<String> rowStrings = cleanedInput.split(']');

    // // Parse each row string into a List<int>
    // splitDayExerciseIndices = rowStrings.map((rowString) {
    //   if (rowString.isEmpty || rowString == ']') {
    //     return <int>[];
    //   }

    //   // Remove trailing ']'
    //   rowString = rowString.substring(0, rowString.length - 1);

    //   // Split the row string into individual elements
    //   List<String> elementStrings = rowString.split(',');

    //   // Parse each element string into an int
    //   List<int> row = elementStrings
    //       .map((elementString) => int.parse(elementString.trim()))
    //       .toList();

    //   return row;
    // }).toList();

    String splitDayExerciseIndicesStringTemp = currentUser
        .splitDayExerciseIndicesString
        .substring(2); // remove first two square brackets
    List<String> rows = splitDayExerciseIndicesStringTemp.split("[");
    List<List<int>> indices = [];
    for (String s in rows) {
      s = s.trim().substring(0, s.trim().length - 2); // remove "]," or "]]"
      if (s.isEmpty) {
        indices.add(<int>[]);
        continue;
      }
      List<String> sToList = s.split(",");
      List<int> intToList = [];
      for (String s2 in sToList) {
        s2 = s2.trim();
        intToList.add(int.parse(s2));
      }
      indices.add(intToList); // Add each day
    }
    splitDayExerciseIndices = indices;

    print("initialized indices: $splitDayExerciseIndices");

    print(currentSplit);

    if (currentSplit != null) {
      for (int i = 0; i < splitDayExerciseIndices.length; i++) {
        if (currentSplit.trainingDays[i].exerciseNames.length !=
            splitDayExerciseIndices[i].length) {
          print("ERROR - exercise names isn't the right length");
          return;
        }
        for (int j = 0; j < splitDayExerciseIndices[i].length; j++) {
          if (splitDayExerciseIndices[i][j] == -1 ||
              splitDayExerciseIndices[i][j] >=
                  muscleGroups[currentSplit.trainingDays[i].muscleGroups[j]]!
                      .length) {
            splitDayExerciseIndices[i][j] = 0; // Reset if out of bounds
          }
          if (currentSplit.trainingDays[i].exerciseNames[j] !=
              muscleGroups[currentSplit.trainingDays[i].muscleGroups[j]]![
                      splitDayExerciseIndices[i][j]]
                  .name) {
            // Set to updated index due to popularity chagne
            print(
                '${currentSplit.trainingDays[i].exerciseNames[j]} changed index due to a popularity change');
            splitDayExerciseIndices[i][j] =
                muscleGroups[currentSplit.trainingDays[i].muscleGroups[j]]!
                    .indexWhere((element) =>
                        element.name ==
                        currentSplit.trainingDays[i].exerciseNames[j]);
          }
        }
      }
    }

    // _currentSplitString = _currentSplitString.substring(2); // remove first two square brackets
    // List<String> muscleGroupsPerDay = _currentSplitString.split("[");
    // List<List<String>> muscleGroupsforAllDays = [];
    // for (String s in muscleGroupsPerDay){
    //   s = s.substring(0,s.length - 2); // remove "]," or "]]"
    //   List<String> sToList = s.split(",");
    //   for (String s2 in sToList){
    //     s2 = s2.trim();
    //   }
    //   muscleGroupsforAllDays.add(sToList); // Add each day
    // }
  }

  void storeUserGymInSharedPreferences() {
    if (userGym == null) {
      currentUser.userGymId = '';
      print('ERROR - storing user gym, but user gym is null');
      return;
    }
    currentUser.userGymId = userGym!.placeId;
    storeDataInFirestore();
    // _prefs.setString('userGymId', userGymId);
    print('stored userGymId ${currentUser.userGymId}');
  }

  void removeUserGymFromSharedPreferences() {
    currentUser.userGymId = '';
    storeDataInFirestore();
    // _prefs.remove('userGymId');
  }

  // Storing the Split object in SharedPreferences
  void storeSplitInSharedPreferences() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < splitDayExerciseIndices.length; i++) {
      // print(currentSplit.trainingDays[i].exerciseNames.length);
      // print(splitDayExerciseIndices[i].length);
      // if (currentSplit.trainingDays[i].exerciseNames.length !=
      //     splitDayExerciseIndices[i].length) {
      //   print("ERROR - exercise names isn't the right length");
      //   // currentSplit.trainingDays[i].exerciseNames =
      //   //     List.filled(splitDayExerciseIndices[i].length, '');
      // }
      for (int j = 0; j < splitDayExerciseIndices[i].length; j++) {
        currentSplit.trainingDays[i].exerciseNames[j] =
            muscleGroups[currentSplit.trainingDays[i].muscleGroups[j]]![
                    splitDayExerciseIndices[i][j]]
                .name;
      }
    }
    storeDataInFirestore();
    // String splitJson = json.encode(currentSplit.toJson());
    // await prefs.setString('split', splitJson);
  }

// Retrieving the Split object from SharedPreferences
  // Future<void> retrieveSplitFromSharedPreferences() async {
  //   // SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? splitJson = prefs.getString('split');
  //   if (splitJson != null) {
  //     Map<String, dynamic> splitMap = json.decode(splitJson);
  //     currentSplit = Split.fromJson(splitMap);
  //     makeNewSplit = false;
  //     print("initialized split: $currentSplit");
  //   } else {
  //     print("No split saved");
  //   }
  // }

  // Future<void> initializeUserID() async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String? uid = prefs.getString('userID');
  // if (uid != null) {
  //   // userID is intialized as empty string
  //   userID = uid;
  // } else {
  //   userID = await getDeviceId(); // Generate unique user id for each device
  //   prefs.setString('userID', userID);
  // }
  // print("userID: $userID");
  // }

  // Future<String> getDeviceId() async {
  //   DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  //   String? deviceId; // Make the variable nullable and assign a default value

  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
  //     deviceId = androidInfo.id;
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
  //     deviceId = iosInfo.identifierForVendor;
  //   }

  //   return deviceId ?? ''; // Return a default value if deviceId is null
  // }

  void submitExercisePopularityDataToFirebase(
      String username,
      String exerciseName,
      String mainMuscleGroup,
      double? numStars,
      int? oneRepMax,
      List<int> splitWeightAndReps,
      List<int> splitWeightPerSet,
      List<int> splitRepsPerSet,
      Map<int, int> userOneRepMaxHistory) {
    // String timestamp = DateTime.now().toString();
    ExercisePopularityData data = ExercisePopularityData(
        username,
        exerciseName,
        mainMuscleGroup,
        numStars,
        oneRepMax,
        splitWeightAndReps,
        splitWeightPerSet,
        splitRepsPerSet,
        userOneRepMaxHistory);
    // Unique child for each exercise name
    FirebaseFirestore.instance
        .collection('exercisePopularityData')
        .doc(data.exerciseName)
        .set({data.username: data.toJson()}, SetOptions(merge: true));
    // databaseRef
    //     .child('exercisePopularityData')
    //     .child(data.exerciseName)
    //     .child(data.userID)
    //     .set(data.toJson());
    // databaseRef.child('exercisePopularityData').push().set(data.toJson());
    // hasSubmittedData = true;
    // notifyListeners();
    print("Submitted exercise popularity data to firestore");
    // Null values simply don't appear as entries on database
  }

  void submitGymDataToFirebase(Gym gym) async {
    // Create a list to store the converted GymImageContainers
    try {
      // List<String> imagesAsBase64 = [];

      // for (int i = 0; i < photoUrls.length; i++) {
      //   Uint8List imageBytes = await http
      //       .get(Uri.parse(photoUrls[i]))
      //       .then((response) => response.bodyBytes);

      //   String base64Image = base64Encode(imageBytes);

      //   imagesAsBase64.add(base64Image);
      // }

      GymData data = GymData(
          gym.name,
          gym.placeId,
          gym.formattedAddress,
          // imagesAsBase64,
          gym.googleMapsRating,
          gym.machinesAvailable.map((exercise) => exercise.name).toList(),
          gym.resourcesAvailable,
          gym.url,
          gym.gymUrl,
          gym.openingHours,
          gym.internationalPhoneNumber,
          gym.priceLevel,
          gym.usernamesThatSelected);

      FirebaseFirestore.instance
          .collection('gymData')
          .doc(data.placeId)
          .set(data.toJson(), SetOptions(merge: true));

      // Convert each GymImageContainer to a Map
      // Upload each GymImageContainer image to Firebase Storage

      // String timestamp = DateTime.now().toString();
      // GymData data = GymData(gym.name, gym.placeId, gym.formattedAddress, gym.photos,
      //     gym.googleMapsRating, gym.machinesAvailable, gym.resourcesAvailable, gym.url);

      // databaseRef.child('gymData').child(data.placeId).set(data.toJson());
      print("Submitted gym data to firebase database");
      // Null values simply don't appear as entries on database
    } catch (e) {
      print('ERROR - submit gym data to firebase $e');
    }
  }

  Future<void> loadGymPhotos(String placeId) async {
    if (gymPhotosMap[placeId] != null) {
      currentGymPhotos = gymPhotosMap[placeId]!.toList();
      print('loaded old gym photos');
      return;
    }

    currentGymPhotos = [];
    notifyListeners();

    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('gymPhotos').child(placeId);
      final images = (await storageRef.listAll()).items;
      for (final image in images) {
        currentGymPhotos.add(Image.network(await image.getDownloadURL()));
      }
      gymPhotosMap[placeId] = currentGymPhotos.toList();
      // DatabaseEvent event =
      //     await databaseRef.child('gymPhotos').child(placeId).once();
      // DataSnapshot snapshot = event.snapshot;

      // List<Object?> objectData = snapshot.value as List<Object?>;

      // List<String> photosData = objectData.cast<String>();
      // List<Uint8List> binaryData = objectData.cast<Uint8List>();

      // for (String base64Encoding in photosData) {
      // print('$gym photo');
      // Uint8List imageBytes = base64Decode(base64Encoding);
      // binaryData.add(imageBytes);
      // currentGymPhotos.add(GymImageContainer(bytes: imageBytes));
      // }
      // await databaseRef.child('gymPhotos').child(gym.placeId).set(binaryData);
    } catch (error) {
      print("Error loading photos - $error");
    }
    notifyListeners();
    // }
  }

  Future<Map<String, Gym>> fetchGymData() async {
    Map<String, Gym> gyms = <String, Gym>{};
    // print('5 ${databaseRef.child('gymData').once()}');

    try {
      // print('5 ${databaseRef.child('gymData').once().snapshot}');
      // print('${(await databaseRef.child('gymData').orderByChild(path).child('ChIJ128R0nW32YgRx7bngPUd0ZA').once()).snapshot.value}');
      // print('${(await databaseRef.once()}');
      // List<String> placeIds = [
      //   'ChIJ128R0nW32YgRx7bngPUd0ZA',
      //   'ChIJ3f9F25HH2YgRTANgQAmMVno',
      //   'ChIJ4dr6hsa22YgR42TJ1LneeRU',
      //   'ChIJ4wCTIri32YgRx3yco1Ojd_w',
      //   'ChIJ78w6rOK22YgRMza8Y2HOIXU',
      //   'ChIJ91EtDsu32YgRT6IgvLBLmA0',
      //   'ChIJBUHi5HC42YgRg1Sm4Rbk2MA',
      //   'ChIJE8YYDVm32YgRv_bmKSwUPd0',
      //   'ChIJEVL3cc-32YgRH4OBRXpejAE',
      //   'ChIJEYA9iGS42YgRk22ATRJZnSM',
      //   'ChIJG4DVFpi32YgRnuZXYjI7cEs',
      //   'ChIJGVsE3SvB2YgREZUNWXAIkSE',
      //   'ChIJIcLgnu632YgReeVQF-_8jyY',
      //   'ChIJJXlTGmi32YgRiZB0358tyeA',
      //   'ChIJJzaSzeu32YgRkZMoJoiEsLg',
      //   'ChIJK66W4Me32YgRkYiWI6qlQW0',
      //   'ChIJKZYj6Zu32YgR9tMgd2U4qOU',
      //   'ChIJLxbjDWW42YgRZHml134Slgk',
      //   'ChIJNQK-vm7H2YgRoKrE-9iHMFQ',
      //   'ChIJNzo8Moi42YgRIUJLxVsL3qQ',
      //   'ChIJO7bhu7DH2YgR7DEL0afQxPo',
      //   'ChIJP5A5CgDI2YgRv9iE7x0QLtc',
      //   'ChIJP9Ok-oK32YgRLI6FVENJ64s',
      //   'ChIJPWAi0VK22YgRUXCfCJLMdPo',
      //   'ChIJRaIxiGS42YgR8g24v3kvGcQ',
      //   'ChIJUS8HNuXH2YgRGaSKAhF5n4g',
      //   'ChIJUTwtJ3u42YgRtrD5cMNpA1k',
      //   'ChIJUeEK4sa42YgRn_9EBx3LQNY',
      //   'ChIJWTfeV8252YgR0vLjqRSRc50',
      //   'ChIJXRwy4ZXH2YgRDVcQkQndIiU',
      //   'ChIJXZCyno-42YgRLuq1vnEpAvE',
      //   'ChIJXys049bH2YgRQONBECEDnIY',
      //   'ChIJZzmdC5bH2YgR8xDPqiBn9vY',
      //   'ChIJZzmdC5bH2YgRWNSGlED6ov8',
      //   'ChIJ__8_bc-32YgRh0WL7TIbXfA',
      //   'ChIJa1pEF5q32YgRgcGvHhKfIW0',
      //   'ChIJaaRUpES42YgRbmquTIQze8U',
      //   'ChIJac1WeqzH2YgR9onkgFzuAeI',
      //   'ChIJbVJqqga52YgRZFV_CEySrFI',
      //   'ChIJbfQaeFG22YgRWgi3ljE_Gfg',
      //   'ChIJbx8j7ZXH2YgRqJx7PwZvRdc',
      //   'ChIJcXeeYOO42YgR8BylrFjtPFU',
      //   'ChIJdb4tL5q32YgRw91LKqYDJ-k',
      //   'ChIJddQ0U0O32YgRONyhOlio1n0',
      //   'ChIJeeY2_fnG2YgR2bXNeOga0Eg',
      //   'ChIJgd1l3W-32YgRwxRtYc-QpQ0',
      //   'ChIJhwoRhtG32YgROMeUOYDt8O4',
      //   'ChIJi8H19WO32YgRJ2Wcg_y1qAA',
      //   'ChIJiYnm-L-52YgRt_eWnl__yfQ',
      //   'ChIJl54f4M632YgRW5BHy8LsmwI',
      //   'ChIJm99KUNa52YgREOSu4LvwuCg',
      //   'ChIJq2tnoZe32YgR1MdFNTphB44',
      //   'ChIJqxe6C_622YgRry45oUZIukQ',
      //   'ChIJr7oeoevH2YgRRSohseRRUvs',
      //   'ChIJrVqyc0u42YgR1K4TyTLZSrc',
      //   'ChIJt4LjLeq32YgRtZdiCgxRUSc',
      //   'ChIJu5slXga32YgRND32Rz9NG10',
      //   'ChIJv5yQgvrH2YgR3Ur0PZYrjjk',
      //   'ChIJv82U_Ia32YgRt4VT4QWIfgM',
      //   'ChIJvXx86eu32YgRuJ2JH4YMpx0',
      //   'ChIJxXRgY_DH2YgR8zf5S-gHwEU',
      //   'ChIJxesb4grH2YgRP7ikGVtEefA',
      // ];

      // for (String placeId in placeIds) {
      // DatabaseEvent event = await databaseRef.child('gymData').once();
      // // await databaseRef.child('gymData').child(placeId).child('photosAsBase64').remove();

      // DataSnapshot snapshot = event.snapshot;

      // print('snapshot value ${snapshot.value}');
      // (await databaseRef.child('gymData').once()).snapshot.value;
      // return gyms;

      // Map<dynamic, dynamic>? gymData = snapshot.value as Map<dynamic, dynamic>?;

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('gymData').get();

      // Check if the document exists
      if (querySnapshot.docs.isNotEmpty) {
        for (Map<String, dynamic> data
            in querySnapshot.docs.map((e) => e.data())) {
          // if (gymData != null) {
          // data.remove('photosAsBase64');
          // gymData.forEach((placeId, data) {
          // List<Widget> gymImageContainers = [];
          // List<dynamic> photosAsObjects = data['photosAsBase64'] ?? [];
          // List<String> photosAsBase64 = photosAsObjects.cast<String>();
          // if (photosAsBase64.isNotEmpty) {
          //   // databaseRef.child('gymPhotos').child(placeId).set(photosAsBase64);
          //   for (String base64 in photosAsBase64) {
          //     Uint8List imageBytes = base64Decode(base64);
          //     gymImageContainers.add(GymImageContainer(bytes: imageBytes));
          //   }
          // }
          List<dynamic> machinesAsObjects = data['machinesAvailable'] ?? [];
          List<String> machineNames = machinesAsObjects.cast<String>();

          List<Exercise> allExercises = [];
          for (List<Exercise> list in muscleGroups.values) {
            allExercises.addAll(list);
          }
          List<Exercise> machinesAvailable = allExercises
              .where((exercise) => machineNames.contains(exercise.name))
              .toList();
          Map<Object?, Object?>? resourcesObjects = data['resourcesAvailable'];
          // If null create empty map
          resourcesObjects ??= {};

          List<dynamic>? openingHoursAsObjects = data['openingHours'];
          List<String>? openingHours;
          openingHours = openingHoursAsObjects?.cast<String>();
          List<dynamic>? usernamesAsObjects = data['usernamesThatSelected'];
          List<String>? usernamesThatSelected =
              usernamesAsObjects?.cast<String>();

          Gym gym = Gym(
              name: data['name'] ?? '',
              placeId: data['placeId'] ?? '',
              formattedAddress: data['formattedAddress'] ?? '',
              photos: [],
              // openNow: null,
              googleMapsRating: data['googleMapsRating'] + 0.0,
              machinesAvailable: machinesAvailable,
              resourcesAvailable: resourcesObjects.cast<String, int>(),
              url: data['url'] ?? '',
              gymUrl: data['gymUrl'], // Could be null
              openingHours: openingHours, // Could be null
              internationalPhoneNumber:
                  data['internationalPhoneNumber'], // Could be null
              priceLevel: data['priceLevel'], // Could be null
              usernamesThatSelected: usernamesThatSelected ?? []);

          gyms.putIfAbsent(data['placeId'] ?? '', () => gym);

          // DocumentReference gymsRef =
          //     FirebaseFirestore.instance.collection('gymData').doc(placeId);
          // GymData uploadData = GymData(
          //     gym.name,
          //     gym.placeId,
          //     gym.formattedAddress,
          //     gym.googleMapsRating,
          //     gym.machinesAvailable.map((exercise) => exercise.name).toList(),
          //     gym.resourcesAvailable,
          //     gym.url,
          //     gym.gymUrl,
          //     gym.openingHours,
          //     gym.internationalPhoneNumber,
          //     gym.priceLevel,
          //     gym.usernamesThatSelected);
          // gymsRef.set(uploadData.toJson(), SetOptions(merge: true)).then((value) {
          //   print('${gym.name} in firestore');
          // }).catchError((error) {
          //   print('${gym.name} failed: $error');
          // });
        }
      } else {
        print("ERROR - gymData is null");
      }
      // }
      print('Done downloading gym data');
    } catch (error) {
      print("Error retrieving gym data: $error");
    }

    return gyms;
  }

  Future<Map<String, List<dynamic>>> fetchExerciseData() async {
    Map<String, List<dynamic>> exerciseStarDataMap = <String, List<dynamic>>{};
    // String => [List<double?>, List<int>, List<int>]

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('exercisePopularityData')
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (Map<String, dynamic> exerciseData
            in querySnapshot.docs.map((e) => e.data())) {
          // DatabaseEvent event =
          //     await databaseRef.child('exercisePopularityData').once();
          // print('6 ${(await databaseRef.child('exercisePopularityData').once()).snapshot.value}');
          // print('7 ${(await databaseRef.child('gymData').once()).snapshot.value}');

          // .orderByChild('exerciseName')
          // .equalTo(exerciseName)
          // .child(exerciseName)
          // .once();
          // print('1 $event');

          // DataSnapshot snapshot = event.snapshot;

          // Map<dynamic, dynamic>? exerciseData =
          //     snapshot.value as Map<dynamic, dynamic>?;

          // print (exerciseData.toString());

          // if (exerciseData != null) {
          // exerciseData.forEach((exercise, uidData) {
          // String exerciseName = exercise.toString();
          // Map<dynamic, dynamic> userIDData = uidData;

          double? userNumStars;
          double avgNumStars = 0.0;
          double userCounter = 0.0;
          double? userOneRepMax;
          double? userSplitWeight;
          double? userSplitReps;
          List<int>? userSplitWeightPerSet;
          List<int>? userSplitRepsPerSet;
          Map<int, int> userOneRepMaxHistory = {};

          // String exerciseName;
          String? mainMuscleGroup;
          String exerciseName = '';

          exerciseData.forEach((username, exercisePopularity) {
            exerciseName = exercisePopularity['exerciseName']!;
            // userIDData.forEach((key, data) {
            // String uid = key.toString();
            // Map<dynamic, dynamic> exercisePopularity = data;

            // exerciseName = exercisePopularity['exerciseName'];
            mainMuscleGroup = exercisePopularity['mainMuscleGroup'];
            if (username == currentUser.username) {
              if (exercisePopularity['numStars'] != null) {
                userNumStars =
                    exercisePopularity['numStars'] + 0.0; // Avoid error
              }
              if (exercisePopularity['oneRepMax'] != null) {
                userOneRepMax =
                    exercisePopularity['oneRepMax'] + 0.0; // Avoid error
              }
              if (exercisePopularity['splitWeight'] != null) {
                userSplitWeight =
                    exercisePopularity['splitWeight'] + 0.0; // Avoid error
              }
              if (exercisePopularity['splitReps'] != null) {
                userSplitReps =
                    exercisePopularity['splitReps'] + 0.0; // Avoid error
              }
              if (exercisePopularity['splitWeightPerSet'] != null) {
                List<dynamic> weightsAsObjects =
                    exercisePopularity['splitWeightPerSet'];
                userSplitWeightPerSet = weightsAsObjects.cast<int>();
              }
              if (exercisePopularity['splitRepsPerSet'] != null) {
                List<dynamic> repsAsObjects =
                    exercisePopularity['splitRepsPerSet'];
                userSplitRepsPerSet = repsAsObjects.cast<int>();
              }
              if (exercisePopularity['userOneRepMaxHistory'] != null) {
                userOneRepMaxHistory = Map<int, int>.from(
                    (exercisePopularity['userOneRepMaxHistory']
                            as Map<dynamic, dynamic>)
                        .map((key, value) => MapEntry(int.parse(key.toString()),
                            int.parse(value.toString()))));
              }
            }
            if (exercisePopularity['numStars'] != null) {
              avgNumStars = avgNumStars +
                  (exercisePopularity['numStars'] + 0.0); // Avoid error
              userCounter++;
            }

            print("Username: $username");
            // print("User ID: $uid");
            // print("Main Muscle Group: $mainMuscleGroup");
            // print("Number of Stars: ${exercisePopularity['numStars']}");
          });

          print(
              "Exercise Name: $exerciseName, Main Muscle Group: $mainMuscleGroup");

          if (userCounter > 0) {
            avgNumStars = avgNumStars / userCounter;
            avgNumStars =
                (avgNumStars * 2.0).round() / 2.0; // Round to nearest half
          }

          print(
              "User number of stars: $userNumStars, Average number of Stars: $avgNumStars, User one rep max: $userOneRepMax");

          // Star data for each exercise
          exerciseStarDataMap.putIfAbsent(
              exerciseName,
              () => [
                    [
                      userNumStars,
                      avgNumStars,
                      userOneRepMax,
                      userSplitWeight,
                      userSplitReps
                    ],
                    userSplitWeightPerSet,
                    userSplitRepsPerSet,
                    userOneRepMaxHistory
                  ]);
        }
        print('Exercise star map[\'\']: ${exerciseStarDataMap['']}');
      } else {
        // print("No user popularity data found for exercise: $exerciseName");
        print("exerciseData is null");
      }
    } catch (error) {
      print("Error retrieving exercise popularity data: $error");
    }

    return exerciseStarDataMap;
  }

  // Future<void> initializeFirebase() async {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // }

  // Listen for user input and write data to the database
  void submitOccupancyDataToFirebase(int currentOccupancy) {
    int millisecondsFromEpoch = DateTime.now().millisecondsSinceEpoch;
    OccupancyData data = OccupancyData(currentOccupancy, millisecondsFromEpoch);
    FirebaseFirestore.instance
        .collection('occupancyData')
        .doc(millisecondsFromEpoch.toString())
        .set(data.toJson());
    // databaseRef.child('occupancyData').push().set(data.toJson());
    hasSubmittedData = true;
    notifyListeners();
    print("Submitted $currentOccupancy to firebase database");
  }

  void changePage(int index) {
    pageIndex = index;

    notifyListeners();
  }

  void changePageToMuscleGroup(String muscleGroupName) {
    pageIndex = 4;
    currentMuscleGroup = muscleGroupName;
    // fromFavorites = false;
    fromSplitDayPage = false;
    notifyListeners();
  }

  void changePageToExercise(Exercise exercise) async {
    // Exercise page from muscleGroup
    pageIndex = 5;
    showAdBeforeExerciseCounter--;
    print('decrementer ad counter to $showAdBeforeExerciseCounter');

    // currentMuscleGroup should match the correct muscleGroup for the exercise
    // Need a different approach for viewing exercises from favorites because of back button
    if (bottomNavigationIndex == 2) {
      currentExerciseFromSplitDayPage = exercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImageFromSplitDayPage = Image.memory(img.encodePng(
            applyFloodFill(defaultMuscleWorkedImage!, exercise.musclesWorked,
                exercise.musclesWorkedActivation, imageMuscleLocations)));
      }
    } else if (bottomNavigationIndex == 3) {
      currentExerciseFromGymPage = exercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImageFromGymPage = Image.memory(img.encodePng(
            applyFloodFill(defaultMuscleWorkedImage!, exercise.musclesWorked,
                exercise.musclesWorkedActivation, imageMuscleLocations)));
      }
    } else if (bottomNavigationIndex == 4) {
      currentExerciseFromProfilePage = exercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImageFromProfilePage = Image.memory(img.encodePng(
            applyFloodFill(defaultMuscleWorkedImage!, exercise.musclesWorked,
                exercise.musclesWorkedActivation, imageMuscleLocations)));
      }
    } else if (bottomNavigationIndex == 0) {
      currentExerciseFromFriendsPage = exercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImageFromFriendsPage = Image.memory(img.encodePng(
            applyFloodFill(defaultMuscleWorkedImage!, exercise.musclesWorked,
                exercise.musclesWorkedActivation, imageMuscleLocations)));
      }
    } else {
      currentExercise = exercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImage = Image.memory(img.encodePng(applyFloodFill(
            defaultMuscleWorkedImage!,
            exercise.musclesWorked,
            exercise.musclesWorkedActivation,
            imageMuscleLocations)));
      }
    }

    notifyListeners();
  }

  // void changePageToFavoriteExercise(Exercise exercise) {
  //   pageIndex = 5;
  //   currentExercise = exercise;
  //   fromFavorites = true;
  //   notifyListeners();
  // }

  void toggleFavorite(Exercise exercise) {
    // if (favoriteExercises.contains(exercise)) {
    //   favoriteExercises.remove(exercise);
    // } else {
    //   bool foundFavorite = false;
    //   Exercise? exerciseToBeRemoved;
    //   for (Exercise favoriteExercise in favoriteExercises) {
    //     if (exercise.compareTo(favoriteExercise) == 0) {
    //       // If duplicate exercise is already in favorites
    //       exerciseToBeRemoved = favoriteExercise;
    //       foundFavorite = true;
    //       break;
    //     }
    //   }
    //   if (!foundFavorite) {
    //     favoriteExercises.add(exercise);
    //   } else{
    //     favoriteExercises.remove(exerciseToBeRemoved);
    //   }
    // }
    bool foundFavorite = false;
    print(favoriteExercises);
    for (Exercise favoriteExercise in favoriteExercises) {
      if (favoriteExercise.name == exercise.name) {
        favoriteExercises.remove(favoriteExercise);
        foundFavorite = true;
        break;
      }
    }
    if (!foundFavorite) {
      favoriteExercises.add(exercise);
    }

    favoriteExercises.sort(); // Sort favorite exercises by star rating

    /* In case there are deprecated exercises in favoriteExercises:
    favoriteExercises.clear();
    print(favoriteExercises);
    */

    saveData(); // Save favorite exercises so they can be accessed after the app terminates

    notifyListeners();
  }

  void changeExerciseFromExercisePage(Exercise newExercise) {
    print('changing exercise to $newExercise');
    if (fromGymPage) {
      currentExerciseFromGymPage = newExercise;
      if (bottomNavigationIndex == 3) {
        currentMuscleWorkedImageFromGymPage = Image.memory(img.encodePng(
            applyFloodFill(defaultMuscleWorkedImage!, newExercise.musclesWorked,
                newExercise.musclesWorkedActivation, imageMuscleLocations)));
      }
    } else if (bottomNavigationIndex == 2) {
      currentExerciseFromSplitDayPage = newExercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImageFromSplitDayPage = Image.memory(img.encodePng(
            applyFloodFill(defaultMuscleWorkedImage!, newExercise.musclesWorked,
                newExercise.musclesWorkedActivation, imageMuscleLocations)));
      }
    } else if (bottomNavigationIndex == 4) {
      currentExerciseFromProfilePage = newExercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImageFromProfilePage = Image.memory(img.encodePng(
            applyFloodFill(defaultMuscleWorkedImage!, newExercise.musclesWorked,
                newExercise.musclesWorkedActivation, imageMuscleLocations)));
      }
    } else if (bottomNavigationIndex == 0) {
      currentExerciseFromFriendsPage = newExercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImageFromFriendsPage = Image.memory(img.encodePng(
            applyFloodFill(defaultMuscleWorkedImage!, newExercise.musclesWorked,
                newExercise.musclesWorkedActivation, imageMuscleLocations)));
      }
    } else {
      currentExercise = newExercise;
      if (defaultMuscleWorkedImage != null) {
        currentMuscleWorkedImage = Image.memory(img.encodePng(applyFloodFill(
            defaultMuscleWorkedImage!,
            newExercise.musclesWorked,
            newExercise.musclesWorkedActivation,
            imageMuscleLocations)));
      }
    }

    notifyListeners();
  }

  void startWorkout(ActiveWorkout workout) {
    activeWorkout = workout;
    activeWorkoutBannerPageController = PageController();
    // notifyListeners();
    prefs.setString('activeWorkout', json.encode(activeWorkout!.toJson()));
  }

  void cancelWorkout(bool? duringBuild) {
    // Cancel timers
    if (activeWorkout != null) {
      activeWorkout!.timeToCompleteTimer = null;
      for (Timer? timer in activeWorkout!.timers) {
        if (timer != null) {
          timer.cancel();
        }
      }
    }
    activeWorkout = null;
    activeWorkoutBannerPageController = PageController();
    if (duringBuild != true) {
      notifyListeners();
    }
    prefs.remove('activeWorkout');
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(authUsername);
    userRef.update({'activeWorkout': null}); // Remove from firebase
  }

  void updateWorkoutBannerPageIndex(int index) {
    if (activeWorkout != null) {
      activeWorkout!.pageIndex = index;
      if (activeWorkoutBannerPageController.hasClients) {
        activeWorkoutBannerPageController.jumpToPage(index);
      } else {
        // Banners have not yet been built
        activeWorkoutBannerPageController = PageController(initialPage: index);
      }
      notifyListeners();
      prefs.setString('activeWorkout', json.encode(activeWorkout!.toJson()));
    }
  }

  void updateWorkoutBannerAtIndex(int index, String updated) {
    if (activeWorkout != null) {
      activeWorkout!.bannerTitles[index] = updated;
      notifyListeners();
      prefs.setString('activeWorkout', json.encode(activeWorkout!.toJson()));
    }
  }

  void updateAllWorkoutTimerBanners() {
    if (activeWorkout != null) {
      for (int i = 0; i < activeWorkout!.bannerTitles.length; i++) {
        if (activeWorkout!.bannerTitles[i].startsWith('Resting')) {
          // Don't change a complete timer's message
          if (activeWorkout!.bannerTitles[i] != 'Timer complete') {
            activeWorkout!.bannerTitles[i] = activeWorkout!
                        .timersSecondsLeft[i] !=
                    0
                ? 'Resting • ${formatSecondsString(activeWorkout!.timersSecondsLeft[i])}'
                : 'Timer complete';
          }
        }
      }
      notifyListeners();
      prefs.setString('activeWorkout', json.encode(activeWorkout!.toJson()));
    }
  }

  void stopExistingTimers(int index) {
    if (activeWorkout != null) {
      activeWorkout!.timeToCompleteTimer = null;
      int left = index - 1;
      int right = index + 1;
      while (left >= 0) {
        // Complete timer
        if (activeWorkout!.areBannersAndTimersInitialized &&
            activeWorkout!.bannerTitles[left].startsWith('Resting') &&
            activeWorkout!.timersSecondsLeft[left] != null &&
            activeWorkout!.timersSecondsLeft[left]! > 0) {
          activeWorkout!.timersSecondsLeft[left] = 0;
          cancelTimerAtIndex(left);
          updateWorkoutBannerAtIndex(left, 'Timer complete');
          break;
        }
        left--;
      }
      while (right < activeWorkout!.timersSecondsLeft.length) {
        // Reset timer
        if (activeWorkout!.areBannersAndTimersInitialized &&
            activeWorkout!.bannerTitles[right].startsWith('Resting') &&
            activeWorkout!.timersSecondsLeft[right] != null &&
            activeWorkout!.timersSecondsLeft[right]! > 0) {
          activeWorkout!.timersSecondsLeft[right] = null;
          cancelTimerAtIndex(right);
          updateWorkoutBannerAtIndex(right,
              'Resting • ${formatSecondsString(activeWorkout!.restTimesInSeconds[right])}');
          break;
        }
        right++;
      }
      prefs.setString('activeWorkout', json.encode(activeWorkout!.toJson()));
    }
  }

  void decrementTimer(int index) {
    if (activeWorkout != null) {
      if (activeWorkout!.timersSecondsLeft[index] == null) {
        print('Timer reset');
        updateWorkoutBannerAtIndex(index, 'Timer reset');
        // widget.workout.bannerTitles[index] = 'Timer reset';
      } else if (activeWorkout!.timersSecondsLeft[index] != null &&
          activeWorkout!.timersSecondsLeft[index]! <= 0) {
        print('Timer complete');
        // widget.workout.bannerTitles[index] = 'Timer complete';
        updateWorkoutBannerAtIndex(index, 'Timer complete');
      } else {
        updateWorkoutBannerAtIndex(index,
            'Resting • ${formatSecondsString(activeWorkout!.timersSecondsLeft[index])}');
        // widget.workout.bannerTitles[index] =
        //     'Resting • ${widget.workout.timersSecondsLeft[index]} seconds left';
        print(formatSecondsString(activeWorkout!.timersSecondsLeft[index]));
        activeWorkout!.timers[index] = Timer(Duration(seconds: 1), () {
          if (activeWorkout?.timersSecondsLeft[index] != null &&
              activeWorkout?.timersSecondsLeft[index] != 0) {
            if (activeWorkout?.timeToCompleteTimer != null &&
                DateTime.now()
                        .add(Duration(
                            seconds: activeWorkout!.timersSecondsLeft[index]!))
                        .difference(activeWorkout!.timeToCompleteTimer!)
                        .inSeconds >
                    1) {
              // Timer is behind, likely due to the app being in background
              activeWorkout!.timersSecondsLeft[index] = activeWorkout!
                  .timeToCompleteTimer!
                  .difference(DateTime.now())
                  .inSeconds;
            } else {
              activeWorkout!.timersSecondsLeft[index] =
                  activeWorkout!.timersSecondsLeft[index]! - 1;
            }
          }
          decrementTimer(index);
        });
      }
    }
  }

  void cancelTimerAtIndex(int index) {
    while (activeWorkout != null &&
        activeWorkout!.timers[index] != null &&
        activeWorkout!.timers[index]!.isActive) {
      activeWorkout?.timers[index]?.cancel();
    }
    activeWorkout?.timers[index] = null;
    notifyListeners();
  }

  Image getMusclesWorkedImage(Exercise exercise) {
    musclesWorkedImages[exercise.name] ??= Image.memory(img.encodePng(
        applyFloodFill(defaultMuscleWorkedImage!, exercise.musclesWorked,
            exercise.musclesWorkedActivation, imageMuscleLocations)));
    if (musclesWorkedImages.length > 20) {
      // Don't have too many images in memory, remove first
      musclesWorkedImages.remove(musclesWorkedImages.keys.first);
    }
    return musclesWorkedImages[exercise.name]!;
  }

  Map<String, Image> musclesWorkedImages = {};

  void notifyTheListeners() {
    notifyListeners();
  }

  // void changeActiveWorkoutTitles(String title, String subtitle) {
  //   activeWorkout?.bannerTitle = title;
  //   activeWorkout?.bannerSubtitle = subtitle;
  //   // notifyListeners();
  // }

  // Widget? activeWorkoutBannerWidget;
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _bottomNavigationIndex = 0;

  bool isReloadingInternet = false;
  Timer? _timer;
  InterstitialAd? _interstitialAd;

  // ScrollController _scrollController = ScrollController();
  // bool _isAdVisible = true;

  // @override
  // void initState() {
  //   super.initState();
  //   // Visible ads give fps drops, remove when scrolling
  //   // _scrollController.addListener(() {
  //   //   print('listening');
  //   //   if (_scrollController.position.isScrollingNotifier.value) {
  //   //     print('moving');
  //   //   }
  //   //   if (!_scrollController.position.isScrollingNotifier.value) {
  //   //     print('idle');
  //   //   }
  //   //   if (_scrollController.position.userScrollDirection ==
  //   //       ScrollDirection.idle) {
  //   //   print('idle');
  //   //     setState(() {
  //   //       _isAdVisible = true;
  //   //     });
  //   //   } else if (_scrollController.position.userScrollDirection ==
  //   //           ScrollDirection.forward ||
  //   //       _scrollController.position.userScrollDirection ==
  //   //           ScrollDirection.reverse) {
  //   //   print('scrolling');
  //   //     setState(() {
  //   //       _isAdVisible = false;
  //   //     });
  //   //   }
  //   // });
  // }

  @override
  void dispose() {
    _timer?.cancel();
    // _scrollController.dispose();
    super.dispose();
  }

  void reloadInternetAnimation() {
    setState(() {
      isReloadingInternet = true;
    });
    _timer = Timer(Duration(milliseconds: 300), () {
      setState(() {
        isReloadingInternet = false;
      });
    });
  }

  // final List<Widget> _bottomScreens = [
  //   HomePage(),
  //   MuscleGroupsPage(),
  //   SplitPage(),
  // ];
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    if (!isAuthenticated) {
      return LayoutBuilder(builder: (context, constraints) {
        return AuthPage(setState);
      });
    }

    if (appState.noInternetInitialization) {
      return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
            bottomSheet: Container(
              color: theme.colorScheme.background,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copyright_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Ross Stewart",
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    )
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: SizedBox(
                  height: 50,
                  child: Image.asset('assets/images/gym_brain_logo.png'),
                ),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Spacer(),
                    Text(
                      "Check Internet Connection",
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (isReloadingInternet) CircularProgressIndicator(),
                    if (!isReloadingInternet)
                      ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.primary),
                            surfaceTintColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.primary),
                          ),
                          onPressed: () async {
                            // Restart app
                            reloadInternetAnimation();
                            appState.initEverything();
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: theme.colorScheme.onBackground,
                          ),
                          label: Text(
                            'Refresh',
                            style: TextStyle(
                                color: theme.colorScheme.onBackground),
                          )),
                    // CircularProgressIndicator(),
                    Spacer(),
                    SizedBox(
                      height: 150,
                    ),
                  ]),
            ));
      });
    }

    if (appState.isInitializing) {
      return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
            bottomSheet: Container(
              color: theme.colorScheme.background,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copyright_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Ross Stewart",
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    )
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: SizedBox(
                  height: 50,
                  child: Image.asset('assets/images/gym_brain_logo.png'),
                ),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Spacer(),
                    CircularProgressIndicator(),
                    Spacer(),
                    SizedBox(
                      height: 150,
                    ),
                  ]),
            ));
      });
    }

    Widget page;
    switch (appState.pageIndex) {
      case 0:
        // appState.fromSplitDayPage = false;
        // appState.fromSearchPage = false;
        // appState.fromGymPage = false;
        _bottomNavigationIndex = 3; // Update navigation bar
        appState.presetHomePage = 0;
        page = HomePage();
        break;
      case 1: // Deprecated
        // page = MuscleGroupsPage();
        page = Placeholder();
        break;
      case 2: // Deprecated
        // appState.fromFavorites = true;
        // appState.fromSplitDayPage = false;
        // appState.fromSearchPage = false;
        // page = FavoritesPage(); // Favorites page
        page = Placeholder();
        break;
      case 3:
        page = GymCrowdPage(); // Gym crowd page
        break;
      case 4:
        // appState.fromFavorites = false;
        appState.fromSplitDayPage = false;
        appState.fromSearchPage = false;
        appState.fromGymPage = false;
        appState.fromProfilePage = false;
        appState.fromFriendsPage = false;
        appState.presetSearchPage = 1;
        appState.lastVisitedSearchPage = appState.pageIndex;
        appState.lastVisitedSearchPage = 4;
        // if (!isExercisePopUpAdClosed) {
        //   page = YourWidget4(
        //     onClose: () {
        //       // Called when the widget is closed
        //       setState(() {
        //         isExercisePopUpAdClosed = true;
        //       });
        //     },
        //   );
        // } else {
        page = ExercisesPage(); // Switch to another widget
        // }
        break;
      case 5:
        print('pageindex is 5');
        // appState.splitDayEditMode = false;
        // Only remembers exercise from search page if an exercise is not looked at from another page
        // if (appState.fromSearchPage) {
        if (!appState.fromSplitDayPage &&
            !appState.fromGymPage &&
            !appState.fromProfilePage &&
            !appState.fromFriendsPage) {
          // Only update if clicking on exercise from search page or exercises page
          appState.presetSearchPage = 2;
        }
        // } else if (appState.fromFavorites || appState.fromSplitDayPage) {
        //   appState.presetSearchPage = 0;
        // }
        showInterstitialAd(appState);
        page = IndividualExercisePage(); // Exercise page
        break;
      case 6:
        // Reversion changes are already stored in currentSplit
        // appState.fromSplitDayPage = false;
        // appState.fromSearchPage = false;
        // appState.fromGymPage = false;
        appState.splitDayEditMode = false;
        appState.splitDayReorderMode = false;
        _bottomNavigationIndex = 2; // Update navigation bar
        appState.goStraightToSplitDayPage =
            false; // Don't go back to split day page if they were last on split page
        page = SplitPage();
        // setState(() {
        //   appState.currentDayIndex = -1;
        // });
        break;
      case 7:
        appState.splitWeekEditMode = false;
        // appState.fromFavorites = false;
        appState.fromSplitDayPage = true;
        appState.fromSearchPage = false;
        appState.fromGymPage = false;
        appState.fromProfilePage = false;
        appState.fromFriendsPage = false;
        appState.goStraightToSplitDayPage =
            true; // Go back to the split day page they were last on
        page = SplitDayPage(appState.currentDayIndex);
        break;
      case 8:
        // Search screen
        // appState.fromFavorites = false;
        appState.fromSplitDayPage = false;
        appState.fromSearchPage = true;
        appState.fromGymPage = false;
        appState.fromProfilePage = false;
        appState.fromFriendsPage = false;
        _bottomNavigationIndex = 1; // Update navigation bar
        appState.presetSearchPage = 0;
        appState.lastVisitedSearchPage = 8;
        page = SearchPage();
        break;
      case 9:
        appState.fromSplitDayPage = false;
        appState.fromSearchPage = false;
        appState.fromGymPage = true;
        appState.fromProfilePage = false;
        appState.fromFriendsPage = false;
        appState.presetHomePage = 1;
        _bottomNavigationIndex = 3; // Update navigation bar
        page = GymPage(
          gym: appState.currentGym,
          isSelectedGym: appState.userGym == appState.currentGym,
        );
        break;
      case 10:
        // All exercises
        page = SearchExercisesPage(appState.muscleGroups.values
            .toList()
            .expand((innerList) => innerList)
            .toList());
        appState.presetSearchPage = 3;
        appState.lastVisitedSearchPage = 10;
        break;
      case 11:
        _bottomNavigationIndex = 4; // Update navigation bar
        appState.fromSplitDayPage = false;
        appState.fromSearchPage = false;
        appState.fromGymPage = false;
        appState.fromProfilePage = true;
        appState.fromFriendsPage = false;
        page = ProfilePage(
            // appState.userProfileStackFromOwnProfile.isNotEmpty
            //     ? appState.userProfileStackFromOwnProfile.last
            appState.currentUser,
            true,
            true,
            setState);
        appState.savedBottomProfileIndex = 0;
        break;
      case 12:
        _bottomNavigationIndex = 4; // Update navigation bar
        page = FollowersPage(
            appState.userProfileStackFromOwnProfile.isNotEmpty
                ? appState.userProfileStackFromOwnProfile.last
                : appState.currentUser,
            true);
        appState.savedBottomProfileIndex = 1;
        break;
      case 13:
        _bottomNavigationIndex = 0; // Update navigation bar
        appState.savedFriendsPageIndex = 0;
        appState.lastFriendsOrFriendsSearch = true;
        appState.fromFriendsPage = true;
        appState.fromSplitDayPage = false;
        appState.fromSearchPage = false;
        appState.fromGymPage = false;
        appState.fromProfilePage = false;
        page = FriendsPage();
        break;
      case 14:
        appState.savedFriendsPageIndex = 1;
        appState.lastFriendsOrFriendsSearch = false;
        page = SearchFriendsPage();
        break;
      case 15:
        page = OtherUserProfilePage(
            appState.userProfileStack.isNotEmpty
                ? appState.userProfileStack.last
                : null,
            false);
        appState.savedFriendsPageIndex = 2;
        // page = Placeholder();
        break;
      case 16:
        page = FollowersPage(
            appState.userProfileStack.isNotEmpty
                ? appState.userProfileStack.last
                : null,
            false);
        appState.savedFriendsPageIndex = 3;
        break;
      case 17:
        _bottomNavigationIndex = 4; // Update navigation bar
        page = OtherUserProfilePage(
            appState.userProfileStackFromOwnProfile.isNotEmpty
                ? appState.userProfileStackFromOwnProfile.last
                : null,
            true);
        appState.savedBottomProfileIndex = 2;
        // page = Placeholder();
        break;
      default:
        throw UnimplementedError('No widget for ${appState.pageIndex}');
    }
    appState.bottomNavigationIndex = _bottomNavigationIndex;
    appState.appPages[appState.pageIndex] = page;

    return LayoutBuilder(builder: (context, constraints) {
      // Unknown error
      if (appState.activeWorkout != null &&
          appState.activeWorkout!.areBannersAndTimersInitialized &&
          appState.activeWorkout!.bannerTitles.isEmpty) {
        appState.cancelWorkout(true);
      }
      return Scaffold(
        body: Stack(children: [
          page,
          // Active workout ongoing
          if (appState.activeWorkout != null &&
              appState.activeWorkout!.areBannersAndTimersInitialized)
            // appState.activeWorkoutBannerWidget!
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  showActiveWorkoutWindow(
                      context,
                      appState,
                      appState.activeWorkout!,
                      appState.activeWorkout!.dayIndex);
                },
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                      color: appState.activeWorkout!.bannerTitles[
                                  appState.activeWorkout!.pageIndex] !=
                              'Complete Workout'
                          ? Color.alphaBlend(
                              theme.colorScheme.background.withOpacity(.87),
                              theme.colorScheme.primary,
                            ).withOpacity(.97)
                          : theme.colorScheme.primary.withOpacity(.97),
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.all(12.0),
                  child: PageView(
                    controller: appState.activeWorkoutBannerPageController,
                    onPageChanged: (int index) {
                      appState.activeWorkout!.pageIndex = index;
                      if (appState
                              .activeWorkout!.areBannersAndTimersInitialized &&
                          appState.activeWorkout!.bannerTitles[index]
                              .startsWith('Resting') &&
                          appState.activeWorkout!.restTimesInSeconds[index] !=
                              null &&
                          appState.activeWorkout!.timersSecondsLeft[index] ==
                              null) {
                        // Start timer automatically
                        appState.stopExistingTimers(index);
                        appState.activeWorkout!.timersSecondsLeft[index] =
                            appState.activeWorkout!.restTimesInSeconds[index]!;
                        appState.activeWorkout!.timeToCompleteTimer =
                            DateTime.now().add(Duration(
                                seconds: appState.activeWorkout!
                                    .restTimesInSeconds[index]!));
                        appState.decrementTimer(index);
                      }
                      appState.prefs.setString('activeWorkout',
                          json.encode(appState.activeWorkout!.toJson()));
                      if (appState.activeWorkout!.pageIndex >=
                          appState.activeWorkout!.bannerTitles.length - 2) {
                        appState.notifyTheListeners();
                      }
                    },
                    children: [
                      for (int i = 0;
                          i < appState.activeWorkout!.bannerTitles.length;
                          i++)
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                          dense: true,
                          visualDensity: VisualDensity(
                              vertical: VisualDensity.minimumDensity,
                              horizontal: VisualDensity.minimumDensity),
                          minVerticalPadding: 0,
                          titleAlignment: ListTileTitleAlignment.titleHeight,
                          leading:
                              appState.activeWorkout!.timersSecondsLeft[i] !=
                                          null &&
                                      appState.activeWorkout!
                                              .restTimesInSeconds[i] !=
                                          null
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 2, 0),
                                      child: TimerProgressIndicator(
                                          fill: theme.colorScheme.primary,
                                          background:
                                              theme.colorScheme.onBackground,
                                          percentCapacity: appState
                                                      .activeWorkout!
                                                      .restTimesInSeconds[i]! !=
                                                  0
                                              ? appState.activeWorkout!
                                                      .timersSecondsLeft[i]! /
                                                  appState.activeWorkout!
                                                      .restTimesInSeconds[i]!
                                              : 1.0,
                                          size: 30,
                                          strokeWidth: 4),
                                    )
                                  : null,
                          title: Text(appState.activeWorkout!.bannerTitles[i],
                              style: theme.textTheme.titleMedium!.copyWith(
                                  color: theme.colorScheme.onBackground),
                              textAlign: TextAlign.center),
                          subtitle: Text(
                              appState.activeWorkout!.bannerSubtitles[i],
                              style: theme.textTheme.labelSmall!.copyWith(
                                  color: theme.colorScheme.onBackground),
                              textAlign: TextAlign.center),
                          trailing: appState.activeWorkout!
                                          .timersSecondsLeft[i] !=
                                      null &&
                                  appState.activeWorkout!
                                          .restTimesInSeconds[i] !=
                                      null
                              ? GestureDetector(
                                  onTap: () {
                                    if (appState.activeWorkout!.timers[i] !=
                                        null) {
                                      // Pause
                                      appState.activeWorkout!
                                          .timeToCompleteTimer = null;
                                    } else {
                                      // Play
                                      appState.activeWorkout!
                                              .timeToCompleteTimer =
                                          DateTime.now().add(Duration(
                                              seconds: appState.activeWorkout!
                                                  .timersSecondsLeft[i]!));
                                      appState.decrementTimer(i);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: Icon(
                                        appState.activeWorkout!.timers[i] !=
                                                null
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: theme.colorScheme.onBackground,
                                        size: 30),
                                  ))
                              : null,
                        ),
                    ],
                    // child: ListTile(
                    //   dense: true,
                    //   visualDensity: VisualDensity(
                    //       vertical: VisualDensity.minimumDensity,
                    //       horizontal: VisualDensity.minimumDensity),
                    //   minVerticalPadding: 0,
                    //   title: Text(
                    //       appState.activeWorkout!
                    //           .bannerTitles[appState.activeWorkout!.pageIndex],
                    //       style: theme.textTheme.titleMedium!
                    //           .copyWith(color: theme.colorScheme.onBackground),
                    //       textAlign: TextAlign.center),
                    //   subtitle: Text(
                    //       appState.activeWorkout!.bannerSubtitles[
                    //           appState.activeWorkout!.pageIndex],
                    //       style: theme.textTheme.labelSmall!
                    //           .copyWith(color: theme.colorScheme.onBackground),
                    //       textAlign: TextAlign.center),
                    // ),
                  ),
                ),
              ),
            ),
        ]),
        bottomNavigationBar: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 100,
                child: BottomNavigationBar(
                  unselectedItemColor: theme.colorScheme.onBackground,
                  selectedItemColor: theme.colorScheme.primary,
                  currentIndex: _bottomNavigationIndex,
                  onTap: (int index) {
                    setState(() {
                      if (appState.currentSplit != null &&
                          appState.makeNewSplit) {
                        // On the regenerate split page, if they already have a split put them back to view split option
                        appState.makeNewSplit = false;
                      }
                      if (index == 3) {
                        appState.toSplitDayReorderMode(false);
                        // appState.fromSearchPage = false;
                        // appState.fromSplitDayPage = false;
                        // Home
                        if (appState.presetHomePage == 0 ||
                            appState.pageIndex == 9) {
                          appState.changePage(0);
                        } else {
                          // presetHomePage == 1
                          // Current gym will stay the same
                          appState.changePage(9);
                        }
                        appState.splitDayEditMode =
                            false; // Cancel changes when changing to different screen
                        appState.splitDayReorderMode = false;
                        appState.splitWeekEditMode = false;
                      } else if (index == 1) {
                        // Search Page
                        appState.toSplitDayReorderMode(false);
                        if (appState.pageIndex == 4 ||
                            (appState.pageIndex == 5 &&
                                !appState.fromSplitDayPage &&
                                !appState.fromGymPage &&
                                !appState.fromProfilePage &&
                                !appState.fromFriendsPage) ||
                            appState.presetSearchPage == 0) {
                          // Exercises page or individual exercise page or other tab, or if search page is preset
                          appState.changePage(8);
                          appState.splitDayEditMode =
                              false; // Cancel changes when changing to different screen
                          appState.splitDayReorderMode = false;
                          appState.splitWeekEditMode = false;
                          appState.fromSplitDayPage = false;
                          appState.fromGymPage = false;
                          appState.fromProfilePage = false;
                          appState.fromFriendsPage = false;
                        } else {
                          appState.fromSplitDayPage = false;
                          appState.fromGymPage = false;
                          appState.fromProfilePage = false;
                          appState.fromFriendsPage = false;
                          if (appState.presetSearchPage == 1) {
                            appState.changePage(4);
                          } else {
                            // Preset search page == 2
                            appState.changePage(5);
                          }
                        }
                      } else if (index == 2) {
                        appState.toSplitDayReorderMode(false);
                        // appState.fromSearchPage = false;
                        // appState.fromGymPage = false;
                        print(
                            "Changing to split page: ${appState.currentDayIndex} ${appState.pageIndex}");
                        // Split Page
                        if (appState.pageIndex == 7 ||
                            !appState.goStraightToSplitDayPage) {
                          // No current day or get out of split page
                          appState.changePage(6);
                          // appState.currentDayIndex = -1; // Reset current day index
                        } else {
                          // Changes page to split day with the current day index
                          appState.changePage(7);
                        }
                      } else if (index == 0) {
                        appState.toSplitDayReorderMode(false);

                        if (appState.bottomNavigationIndex == 0) {
                          // Go back to home profile
                          print('Clearing friends page profile stack');
                          appState.changePage(13);
                          appState.userProfileStack.clear();
                        } else {
                          if (appState.userProfileStack.isNotEmpty) {
                            if (appState.savedFriendsPageIndex == 3) {
                              appState.changePage(16);
                              // DefaultTabController.of(context).index = (appState.defaultFriendsPageFollowersPage ? 0 : 1);
                            } else if (appState.savedFriendsPageIndex == 2) {
                              appState.changePage(15);
                            } else if (appState.savedFriendsPageIndex == 1) {
                              print('ERROR - friends page index');
                              appState.changePage(14);
                              appState.userProfileStack.clear();
                            } else {
                              print('ERROR - friends page index');
                              appState.changePage(13);
                              appState.userProfileStack.clear();
                            }
                          } else {
                            if (appState.savedFriendsPageIndex == 3) {
                              print('ERROR - friends page index');
                              appState.changePage(16);
                              // DefaultTabController.of(context).index = (appState.defaultFriendsPageFollowersPage ? 0 : 1);
                            } else if (appState.savedFriendsPageIndex == 2) {
                              print('ERROR - friends page index');
                              appState.changePage(15);
                            } else if (appState.savedFriendsPageIndex == 1) {
                              appState.changePage(14);
                            } else {
                              appState.changePage(13);
                            }
                          }
                        }

                        appState.splitDayReorderMode = false;
                        appState.splitWeekEditMode = false;
                      } else if (index == 4) {
                        appState.toSplitDayReorderMode(false);
                        if (appState.bottomNavigationIndex == 4) {
                          // Go back to home profile
                          print('Clearing profile stack');
                          appState.changePage(11);
                          appState.userProfileStackFromOwnProfile.clear();
                        } else {
                          if (appState
                              .userProfileStackFromOwnProfile.isNotEmpty) {
                            if (appState.savedBottomProfileIndex == 2) {
                              appState.changePage(17);
                            } else if (appState.savedBottomProfileIndex == 1) {
                              appState.changePage(12);
                              // DefaultTabController.of(context).index = (appState.defaultProfilePageFollowersPage ? 0 : 1);
                            } else {
                              print('ERROR - bottom page index');
                              appState.changePage(11);
                              appState.userProfileStackFromOwnProfile.clear();
                            }
                          } else {
                            if (appState.savedBottomProfileIndex == 2) {
                              print('ERROR - bottom page index');
                              appState.changePage(11);
                            } else if (appState.savedBottomProfileIndex == 1) {
                              appState.changePage(12);
                              // DefaultTabController.of(context).index = (appState.defaultProfilePageFollowersPage ? 0 : 1);
                            } else {
                              appState.changePage(11);
                            }
                          }
                        }

                        appState.splitDayReorderMode = false;
                        appState.splitWeekEditMode = false;
                      }
                      _bottomNavigationIndex = index;
                      appState.bottomNavigationIndex = _bottomNavigationIndex;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.list_alt),
                      label: 'Split',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.fitness_center),
                      label: 'Gyms',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void showInterstitialAd(MyAppState appState) async {
    if (appState.showAdBeforeExerciseCounter <= 0) {
      InterstitialAd.load(
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print(ad);
            setState(() {
              _interstitialAd = ad;
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            print(error);
          },
        ),
        // adUnitId: 'ca-app-pub-3940256099942544/4411468910', // Test Id
        adUnitId: 'ca-app-pub-4103823838490114/4076820388', // Release Id
        request: AdRequest(),
      );
      if (_interstitialAd != null) {
        print('Ad loaded');
        print(_interstitialAd!.adUnitId);
        _interstitialAd!.show();
        // User can view 1, 2, or 3 more exercises without seeing another ad
        appState.showAdBeforeExerciseCounter = Random().nextInt(3) + 2;
        print(
            'loaded ad, new counter: ${appState.showAdBeforeExerciseCounter}');
      } else {
        print('interstitial ad is null');
      }
    }
  }
}

class PageSelectorButton extends StatelessWidget {
  const PageSelectorButton({
    super.key,
    required this.text,
    required this.index,
    required this.icon,
  });

  final String text;
  final int index;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    void togglePressed() {
      appState.changePage(index);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              theme.colorScheme.primaryContainer),
          surfaceTintColor: MaterialStateProperty.all<Color>(
              theme.colorScheme.primaryContainer),
          // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: togglePressed,
        icon: icon,
        label: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class Back extends StatelessWidget {
  const Back({
    super.key,
    required this.appState,
    required this.index,
  });

  final MyAppState appState;
  final int index;

  void togglePressed() {
    // Going back from user profile page, remove it from the stack
    if (appState.pageIndex == 15) {
      if (appState.userProfileStack.isNotEmpty) {
        appState.userProfileStack.removeLast();
      }
    } else if (appState.pageIndex == 17) {
      // From bottom nav
      if (appState.userProfileStackFromOwnProfile.isNotEmpty) {
        appState.userProfileStackFromOwnProfile.removeLast();
      }
    }
    appState.changePage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // SizedBox(width: 15),
        IconButton(
          color: Theme.of(context).colorScheme.onPrimary,
          onPressed: togglePressed,
          icon: Icon(Icons.arrow_back_ios_new),
        )
        // Container(
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(20),
        //     color: Color.fromRGBO(200, 200, 200, 1),
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
        //     child: BackButton(
        //       onPressed: togglePressed,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class SwipeBack extends StatefulWidget {
  const SwipeBack(
      {Key? key,
      required this.appState,
      required this.index,
      required this.child,
      required this.swipe})
      : super(key: key);

  final MyAppState appState;
  final int index;
  final Widget child;
  final bool swipe;

  @override
  _SwipeBackState createState() => _SwipeBackState();
}

class _SwipeBackState extends State<SwipeBack> {
  bool _isDismissed = false;

  void toggleSwipe() {
    // Swiping back from user profile page, remove it from the stack
    if (widget.appState.pageIndex == 15) {
      if (widget.appState.userProfileStack.isNotEmpty) {
        widget.appState.userProfileStack.removeLast();
      }
    } else if (widget.appState.pageIndex == 17) {
      // From bottom nav
      if (widget.appState.userProfileStackFromOwnProfile.isNotEmpty) {
        widget.appState.userProfileStackFromOwnProfile.removeLast();
      }
    }
    widget.appState.changePage(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.swipe) {
      return widget.child;
    }
    if (widget.index == 7) {
      widget.appState.appPages[widget.index] =
          SplitDayPage(widget.appState.currentDayIndex);
    }
    if (widget.index == 9) {
      widget.appState.appPages[widget.index] = GymPage(
          gym: widget.appState.currentGym,
          isSelectedGym: widget.appState.currentGym == widget.appState.userGym);
    }
    if (widget.index == 10) {
      widget.appState.appPages[widget.index] = SearchExercisesPage(widget
          .appState.muscleGroups.values
          .toList()
          .expand((innerList) => innerList)
          .toList());
    }
    if (widget.index == 11) {
      widget.appState.appPages[widget.index] = ProfilePage(
          // widget.appState.userProfileStackFromOwnProfile.isNotEmpty
          //     ? widget.appState.userProfileStackFromOwnProfile.last
          widget.appState.currentUser,
          true,
          true,
          null);
    }
    if (widget.index == 12) {
      widget.appState.appPages[widget.index] = FollowersPage(
          widget.appState.userProfileStackFromOwnProfile.isNotEmpty
              ? widget.appState.userProfileStackFromOwnProfile.last
              : widget.appState.currentUser,
          true);
    }
    if (widget.index == 15) {
      widget.appState.appPages[widget.index] = OtherUserProfilePage(
          widget.appState.userProfileStack.isNotEmpty
              ? widget.appState.userProfileStack.last
              : null,
          false);
    }
    if (widget.index == 16) {
      widget.appState.appPages[widget.index] = FollowersPage(
          widget.appState.userProfileStack.length > 1
              ? widget.appState
                  .userProfileStack[widget.appState.userProfileStack.length - 2]
              : null,
          false);
    }
    if (widget.index == 17) {
      widget.appState.appPages[widget.index] = OtherUserProfilePage(
          widget.appState.userProfileStackFromOwnProfile.isNotEmpty
              ? widget.appState.userProfileStackFromOwnProfile.last
              : null,
          false);
    }
    final Widget swipeChild = widget.appState.appPages[widget.index];
    return _isDismissed
        ? SizedBox.shrink() // Remove the Dismissible widget from the tree
        : Stack(
            children: [
              swipeChild, // Show the swipeChild beneath the Dismissible
              Dismissible(
                key: const Key('back'),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    toggleSwipe();
                    setState(() {
                      _isDismissed = true;
                    });
                  }
                },
                child: widget.child,
              ),
            ],
          );
  }
}

// class SwipeBack extends StatefulWidget {
//   const SwipeBack({
//     Key? key,
//     required this.appState,
//     required this.index,
//     required this.child,
//   }) : super(key: key);

//   final MyAppState appState;
//   final int index;
//   final Widget child;

//   @override
//   _SwipeBackState createState() => _SwipeBackState();
// }

// class _SwipeBackState extends State<SwipeBack> {
//   final PageController _pageController = PageController();

//   void toggleSwipe() {
//     widget.appState.changePage(widget.index);
//   }

//   @override
//   Widget build(BuildContext context) {

//     List<Widget> pages = context.watch<MyAppState>().appPages;
//     return GestureDetector(
//       onHorizontalDragUpdate: (details) {
//         // Calculate the drag percentage
//         final screenWidth = MediaQuery.of(context).size.width;
//         final dragPercentage = details.primaryDelta! / screenWidth;

//         // Update the page controller to show the page as you swipe
//         _pageController.jumpTo(_pageController.offset + dragPercentage);
//       },
//       onHorizontalDragEnd: (details) {
//         // Calculate the velocity of the swipe
//         final swipeVelocity = details.velocity.pixelsPerSecond.dx;

//         // Determine if the swipe was significant to navigate to the previous page
//         if (swipeVelocity < -1000) {
//           toggleSwipe();
//         }
//       },
//       child: PageView(
//               controller: _pageController,
//               physics: NeverScrollableScrollPhysics(), // Disable swiping between pages
//               children: pages,
//             ),
//     );
//   }
// }

// class BackFromSplitPage extends Back {
//   BackFromSplitPage({required super.appState, required super.index});

//   @override
//   void togglePressed() {
//     if (appState.currentSplit != null && appState.makeNewSplit) {
//       // On the regenerate split page
//       appState.makeNewSplit = false;
//     }
//     appState.changePage(index);
//   }
// }

class MuscleGroupSelectorButton extends StatelessWidget {
  const MuscleGroupSelectorButton({
    super.key,
    required this.muscleGroupName,
    // required this.index,
  });

  final String muscleGroupName;
  // final int index;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    void togglePressed() {
      appState.changePageToMuscleGroup(muscleGroupName);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(theme.colorScheme.primary),
          // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: togglePressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          // child: Text("${wordPair.first} ${wordPair.second}", style: style),
          child: Center(
            child: Text(
              muscleGroupName,
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// class FavoriteExerciseSelectorButton extends StatelessWidget {
//   const FavoriteExerciseSelectorButton({
//     super.key,
//     required this.exercise,
//     // required this.index,
//   });

//   final Exercise exercise;
//   // final int index;

//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();
//     final theme = Theme.of(context);
//     final style = theme.textTheme.titleLarge!.copyWith(
//       color: theme.colorScheme.onPrimary,
//     );

//     void togglePressed() {
//       appState.changePageToFavoriteExercise(exercise);
//     }

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
//       child: ElevatedButton(
//         style: ButtonStyle(
//           backgroundColor:
//               MaterialStateProperty.all<Color>(theme.colorScheme.primary),
//           // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//         ),
//         onPressed: togglePressed,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           // child: Text("${wordPair.first} ${wordPair.second}", style: style),
//           child: Center(
//             child: Text(
//               exercise.name,
//               style: style,
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CapacityChart extends StatelessWidget {
//   final int capacity;
//   final int maxCapacity;

//   CapacityChart({required this.capacity, required this.maxCapacity});

//   @override
//   Widget build(BuildContext context) {
//     double percentage = capacity / maxCapacity;

//     return LinearProgressIndicator(
//       value: percentage,
//       backgroundColor: Colors.grey[300],
//       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//     );
//   }
// }

class CustomCircularProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final double percentCapacity;
  final double size;

  CustomCircularProgressIndicator(
      {this.strokeWidth = 10.0, this.percentCapacity = 0.0, this.size = 60.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        value: percentCapacity,
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        backgroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}

class TimerProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final double percentCapacity;
  final double size;
  final Color fill;
  final Color background;

  TimerProgressIndicator(
      {this.strokeWidth = 10.0,
      this.percentCapacity = 0.0,
      this.size = 60.0,
      required this.fill,
      required this.background});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        value: percentCapacity,
        valueColor: AlwaysStoppedAnimation<Color>(background),
        backgroundColor: fill,
      ),
    );
  }
}

class GymCrowdCard extends StatelessWidget {
  const GymCrowdCard({
    super.key,
    required this.chart,
  });

  final CustomCircularProgressIndicator chart;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Max Capacity',
                style: headingStyle,
              ),
              SizedBox(height: 5),
              Text(
                appState.maxCapacity.toString(),
                style: textStyle,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Current Capacity',
                style: headingStyle,
              ),
              SizedBox(height: 5),
              Text(
                appState.gymCount.toString(),
                style: textStyle,
              ),
            ]),
            Spacer(),
            Column(
              children: [
                chart,
                SizedBox(
                  height: 15,
                ),
                Text(
                  "${(chart.percentCapacity * 100).toInt()} %",
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ],
            ),
            SizedBox(
              width: 40,
            ),
          ],
        ),
      ),
    );
  }
}

// class OccupancyFormCard extends StatelessWidget {
//   const OccupancyFormCard(
//       {super.key,
//       });

//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();
//     final theme = Theme.of(context);
//     final headingStyle = theme.textTheme.titleLarge!.copyWith(
//       color: theme.colorScheme.secondary,
//       fontWeight: FontWeight.bold,
//     );
//     final textStyle = theme.textTheme.titleLarge!.copyWith(
//       color: theme.colorScheme.secondary,
//     );

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
//       child: Card(
//         color: theme.colorScheme.surface,
//         elevation: 10, // Shadow
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             // mainAxisAlignment: MainAxisAlignment.spaceEvenly
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               RichText(
//                 text: TextSpan(
//                   style: TextStyle(),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'Max Capacity:  ',
//                       style: headingStyle,
//                     ),
//                     TextSpan(
//                       text: appState.maxCapacity.toString(),
//                       style: textStyle,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               chart,
//               SizedBox(height: 10,),
//               Text("${(chart.percentCapacity * 100).toInt()} %"),
//               SizedBox(
//                 height: 30,
//               ),
//               RichText(
//                 text: TextSpan(
//                   style: TextStyle(),
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'Current capacity:  ',
//                       style: headingStyle,
//                     ),
//                     TextSpan(
//                       text: appState.gymCount.toString(),
//                       style: textStyle,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

int binarySearchExerciseList(List<Exercise> array, String targetName) {
  int min = 0;
  int max = array.length - 1;

  while (min <= max) {
    int mid = ((max - min) / 2).floor() + min;
    if (array[mid].name.compareTo(targetName) == 0) {
      return mid;
    } else if (array[mid].name.compareTo(targetName) < 0) {
      min = mid + 1;
    } else {
      max = mid - 1;
    }
  }

  return -1;
}

class ImageContainer extends StatelessWidget {
  ImageContainer({
    super.key,
    required this.exercise,
  });

  final Exercise exercise;

//   @override
//   State<ImageContainer> createState() => _ImageContainerState();
// }

// class _ImageContainerState extends State<ImageContainer>
//     with TickerProviderStateMixin {
  // late FlutterGifController controller;
  // bool isImageInitialized = false;

  // @override
  // void initState() {
  //   super.initState();

  // //   controller = FlutterGifController(
  // //   vsync: this,
  // //   duration: const Duration(milliseconds: 150),
  // //   reverseDuration: const Duration(milliseconds: 150),
  // // );

  // // SchedulerBinding.instance?.addPostFrameCallback((_) {
  // //   controller.repeat(min: 0, max: controller.frameCount.toDouble(), period: const Duration(milliseconds: 1000)); // Start animation playback
  // // });

  // }

  // bool isImageInitialized = false;
  @override
  Widget build(BuildContext context) {
    // try {
    //   return FutureBuilder(
    //     future:
    //         checkAssetExists("exercise_pictures/${widget.exerciseName}_m.gif"),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         if (snapshot.hasData && snapshot.data == true) {
    // );
    return exercise.imageExists
        ? Image.asset(
            'exercise_pictures/${exercise.name}_m.gif',
            fit: BoxFit.cover,
          )
        : Container(
            color: Colors.grey[200],
          );
    //     } else {
    //       print(('Failed to load ${widget.exerciseName} image'));
    //       return Container(
    //         color: Colors.grey[200],
    //       );
    //       // return Text('Failed to load image');
    //     }
    //   } else {
    //     return CircularProgressIndicator();
    //   }
    // },

    // child: FutureBuilder<void>(
    //   future: loadImageAsset(context),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       if (snapshot.hasData == false) {
    //         return Text('Failed to load image');
    //       } else {
    //         return Image.asset('exercise_pictures/${exercise.name}.gif');
    //       }
    //     } else {
    //       return CircularProgressIndicator();
    //     }
    //   },
    // ),

    // child: FutureBuilder(
    //   future: _loadImage("assets/images/${exercise.name}.gif"),
    //   builder: (BuildContext context,
    //       AsyncSnapshot<ImageProvider<Object>> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       if (snapshot.hasError) {
    //         print('Error loading image: ${snapshot.error}');
    //         return Text('Failed to load image');
    //       }
    //       return Image(image: snapshot.data!);
    //     } else {
    //       return CircularProgressIndicator();
    //     }
    //   },),

    // child: Image.asset("exercise_pictures/${exercise.name}.gif"),
    // );
    // return Padding(
    //   padding: EdgeInsets.fromLTRB(50, 10, 50, 20),
    //   child: FutureBuilder<ImageProvider<Object>>(
    //     future: _loadImage(exercise.imageUrl),
    //     builder: (BuildContext context,
    //         AsyncSnapshot<ImageProvider<Object>> snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         if (snapshot.hasError) {
    //           print('Error loading image: ${snapshot.error}');
    //           return Text('Failed to load image');
    //         }
    //         image = Image(image: snapshot.data!);
    //         isImageInitialized = true;
    //         return image;
    //       } else {
    //         return CircularProgressIndicator();
    //       }
    //     },
    //   ),
    // );
    // } catch (e) {
    //   print('Failed to load image: $e');
    //   return Text('Failed to load image');
    // }
  }
}

class MuscleGroupImageContainer extends StatelessWidget {
  MuscleGroupImageContainer({
    super.key,
    required this.muscleGroup,
  });

  final String muscleGroup;
  // bool isImageInitialized = false;

  @override
  Widget build(BuildContext context) {
    final MyAppState appState = context.watch<MyAppState>();
    return appState.areMuscleGroupImagesInitialized[muscleGroup] == true
        ? Image.asset(
            'muscle_group_pictures/$muscleGroup.jpeg',
            fit: BoxFit.cover,
          )
        : Container(
            color: Colors.grey[200],
          );
  }
}

Future<bool> checkAssetExists(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true; // Asset file exists
  } catch (error) {
    return false; // Asset file not found or error occurred
  }
}

MaterialStateColor resolveColor(Color color) {
  return MaterialStateColor.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      // Color when the button is pressed
      return color.withOpacity(0.8);
    } else if (states.contains(MaterialState.hovered)) {
      // Color when the button is hovered
      return color.withOpacity(0.6);
    } else {
      // Default color
      return color;
    }
  });
}

// Verify inputs before calling method
int calculateOneRepMax(int weightLifted, int repetitions) {
  // print(((weightLifted) / ((1.0278) - (0.0278 * repetitions))));
  // Returns a truncated double
  return (weightLifted) ~/ ((1.0278) - (0.0278 * repetitions));
}

int calculateWeightToReps(int weight, int oneRepMax) {
  // return oneRepMax = (weight) ~/ ((1.0278) - (0.0278 * repetitions));
  List<double> percentageWeightPerNumReps = [
    1.0,
    .97,
    .94,
    .92,
    .89,
    .86,
    .83,
    .81,
    .78,
    .75,
    .73,
    .71,
    .7,
    .68,
    .67,
    .65,
    .64,
    .63,
    .61,
    .6,
    .59,
    .58,
    .57,
    .56,
    .55,
    .54,
    .53,
    .52,
    .51,
    .5
  ];
  double percentage = weight.toDouble() / oneRepMax.toDouble();
  if (percentage < .5) {
    return percentageWeightPerNumReps.length + 1;
  }
  int index =
      binarySearchBackwardsClosestIndex(percentageWeightPerNumReps, percentage);
  if (index == -1) {
    return -1;
  }
  return index + 1;
}

int calculateRepsToWeight(int reps, int oneRepMax) {
  // return (oneRepMax * ((1.0278) - (0.0278 * reps))).toInt();
  List<double> percentageWeightPerNumReps = [
    1.0,
    .97,
    .94,
    .92,
    .89,
    .86,
    .83,
    .81,
    .78,
    .75,
    .73,
    .71,
    .7,
    .68,
    .67,
    .65,
    .64,
    .63,
    .61,
    .6,
    .59,
    .58,
    .57,
    .56,
    .55,
    .54,
    .53,
    .52,
    .51,
    .5
  ];
  return (percentageWeightPerNumReps[reps - 1] * oneRepMax).toInt();
}

int binarySearchBackwardsClosestIndex(List<double> numbers, double target) {
  int low = 0;
  int high = numbers.length - 1;
  int closestIndex = 0;

  while (low <= high) {
    int mid = (low + high) ~/ 2;
    double current = numbers[mid];

    // Check if the current value is equal to the target
    if (current == target) {
      return mid;
    }

    // Update the closest index if needed
    if ((target - current).abs() < (target - numbers[closestIndex]).abs()) {
      closestIndex = mid;
    }

    // Update the search range based on the comparison with the target
    if (current < target) {
      high = mid - 1;
    } else {
      low = mid + 1;
    }
  }

  return closestIndex;
}

MaterialStateProperty<EdgeInsetsGeometry?> resolveButtonPaddingProperty(
    double padding) {
  return MaterialStateProperty.resolveWith<EdgeInsetsGeometry?>(
    (Set<MaterialState> states) {
      // Return the desired EdgeInsets value based on the states
      return EdgeInsets.all(padding);
    },
  );
}

// Future<void> scheduleNotificationAndStartTimer() async {
//   int timerDuration = 3 * 60; // 3 minutes in seconds
//   // timerDuration = 5; // 3 minutes in seconds
//   // const String channelId = 'my_channel_id';
//   // const String channelName = 'My Channel';
//   // const String channelDescription = 'Channel for My App';
//   const String notificationTitle = 'Timer Notification';
//   const String notificationText = 'Your timer has started.';
//   const int notificationId = 0;

//   // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//   //   channelId,
//   //   channelName,
//   //   channelDescription: channelDescription,
//   //   importance: Importance.max,
//   //   priority: Priority.high,
//   //   ongoing: true, // This makes the notification persistent
//   //   onlyAlertOnce: true,
//   //   playSound: false,
//   //   showProgress: true, // This enables the progress bar for the timer.
//   // );
//   var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//     // android: androidPlatformChannelSpecifics,
//     iOS: iOSPlatformChannelSpecifics,
//   );

//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     notificationId,
//     notificationTitle,
//     '$timerDuration seconds left',
//     tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
//     platformChannelSpecifics,
//     // androidAllowWhileIdle: true,
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     payload: timerDuration
//         .toString(), // Store the initial timer value in the notification payload.
//   );

//   // Start the timer
//   Timer.periodic(Duration(seconds: 1), (timer) {
//     timerDuration--;
//     if (timerDuration <= 0) {
//       timer.cancel(); // Timer is finished
//       // Here you can update the notification or perform any other actions when the timer is done.
//     } else {
//       // Update the notification to show the remaining time in the progress bar.
//       flutterLocalNotificationsPlugin.zonedSchedule(
//         notificationId,
//         notificationTitle,
//         '$timerDuration seconds left',
//         tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
//         platformChannelSpecifics,
//         // androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         payload: timerDuration
//             .toString(), // Store the remaining time in the notification payload.
//       );
//     }
//   });
// }

// Future<void> handleNotificationAction(String? payload) async {
//   if (payload == null) return;

//   if (payload == 'start') {
//     // Start the timer logic here.
//     // Call the function that sets up the timer.
//     scheduleNotificationAndStartTimer();
//   } else if (payload == 'stop') {
//     // Stop the timer logic here.
//     // You can stop the timer or cancel the notification.
//     flutterLocalNotificationsPlugin.cancelAll();
//   }
// }

// Future<void> scheduleNotificationAndStartTimer(MyAppState appState) async {
//   // final timerState = Provider.of<LocalNotificationTimerState>(context, listen: false);
//   final timerState = appState.localNotificationTimerState;
//   const String notificationTitle = 'Timer Notification';
//   const int notificationId = 0;

//   var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//     iOS: iOSPlatformChannelSpecifics,
//   );

//   // Start the timer
//   timerState.startTimer();

//   // Update the notification with the remaining time
//   flutterLocalNotificationsPlugin.zonedSchedule(
//     notificationId,
//     notificationTitle,
//     '${timerState.timerDuration} seconds left',
//     tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
//     platformChannelSpecifics,
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     payload: timerState.timerDuration.toString(),
//   );
// }

// Future<void> scheduleNotificationAndStartTimer() async {
//   int timerDuration = 3 * 60; // 3 minutes in seconds
//   const String notificationTitle = 'Timer Notification';
//   const int notificationId = 0;

//   var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//     iOS: iOSPlatformChannelSpecifics,
//   );

//   // Schedule the notification
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     notificationId,
//     notificationTitle,
//     '$timerDuration seconds left',
//     tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
//     platformChannelSpecifics,
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     payload: timerDuration.toString(),
//   );

//   // Start the timer
//   Timer.periodic(Duration(seconds: 1), (timer) {
//     timerDuration--;
//     if (timerDuration <= 0) {
//       timer.cancel(); // Timer is finished
//       // Here you can update the notification or perform any other actions when the timer is done.
//     } else {
//       // Update the notification to show the remaining time in the progress bar.
//       _updateNotification(
//         notificationId,
//         notificationTitle,
//         '$timerDuration seconds left',
//         platformChannelSpecifics,
//       );
//     }
//   });
// }

// Helper function to update the notification
// void _updateNotification(int id, String title, String body,
//     NotificationDetails notificationDetails) {
//   flutterLocalNotificationsPlugin.show(
//     id,
//     title,
//     body,
//     // tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
//     notificationDetails,
//     // uiLocalNotificationDateInterpretation:
//     //     UILocalNotificationDateInterpretation.absoluteTime,
//     payload: body,
//     // matchDateTimeComponents: DateTimeComponents.time
//   );
// }

// class LocalNotificationTimerState {
//   int _timerDuration = 3 * 60; // 3 minutes in seconds
//   Timer? _timer;
//   bool _isPaused = false;

//   int get timerDuration => _timerDuration;
//   bool get isPaused => _isPaused;

//   void startTimer() {
//     _timer ??= Timer.periodic(Duration(seconds: 1), (timer) {
//       if (!_isPaused) {
//         _timerDuration--;
//         // notifyListeners();
//         if (_timerDuration <= 0) {
//           completeTimer(); // Timer is finished
//           // notifyListeners();
//           // Perform any other actions when the timer is done.
//         }
//       }
//     });
//     // notifyListeners();
//   }

//   void pauseTimer() {
//     _isPaused = true;
//     // notifyListeners();
//   }

//   void resumeTimer() {
//     _isPaused = false;
//     // notifyListeners();
//   }

//   void completeTimer() {
//     _timer?.cancel();
//     _timer = null;
//     _timerDuration = 0;
//     // notifyListeners();
//   }

//   bool hasStarted() {
//     return _timer != null;
//   }
// }

// Future<void> updateTimerDuration(int seconds) async {
//   try {
//     await notificationPlatForm.invokeMethod('updateTimerDuration', {'seconds': seconds});
//   } on PlatformException catch (e) {
//     print("Failed to update timer duration: ${e.message}");
//   }
// }

// Future<void> scheduleNotificationAndStartTimer(MyAppState appState, int timerDuration) async {

//   tz.initializeTimeZones();

//   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   const String notificationTitle = 'Timer Notification';
//   const int notificationId = 0;

//   var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//     iOS: iOSPlatformChannelSpecifics,
//   );

//   // Start the timer
//   appState.localNotificationTimerState.startTimer();

//   // Schedule the initial notification with the timer duration in the payload
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     notificationId,
//     notificationTitle,
//     '$timerDuration seconds left',
//     tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
//     platformChannelSpecifics,
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     payload: '$timerDuration seconds left',
//   );
// }

// const platform = MethodChannel('com.example.timeForGym.playSplitTimer');
// class NotificationService {

//   static Future<void> updateTimerDuration(int seconds) async {
//     await platform.invokeMethod('updateTimerDuration', {'seconds': seconds});
//     // await platform.invokeMethod('startTimer', {});
//     print('test');
//   }
// }

// Future<void> scheduleNotificationAndStartTimer() async {
//   int timerDuration = 20; // 20 seconds for demonstration purposes

//   // Schedule the initial notification with the timer duration in the payload
//   await NotificationService.updateTimerDuration(timerDuration);
// }

String formatSecondsString(int? seconds) {
  if (seconds == null) {
    return '';
  }
  if (seconds < 60) {
    return '$seconds sec';
  } else {
    String minutesPart = '';
    if (seconds ~/ 60 > 0) {
      minutesPart = '${seconds ~/ 60} min';
    }
    if (seconds % 60 != 0) {
      return '$minutesPart, ${seconds % 60} sec';
    } else {
      // Remove ', ' at end
      return '$minutesPart';
    }
  }
}

Future<User?> getUserDataFromFirestore(
    String username, MyAppState appState) async {
  try {
    User visitedUser = appState.visitedUsers.firstWhere(
        (element) => element.username == username,
        orElse: () => User(username: '', email: '', uid: ''));
    if (visitedUser.username.isNotEmpty) {
      return visitedUser;
    }
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(username);
    DocumentSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
      User newUser = User(
          username: username,
          email: userData['email'] ?? '',
          uid: userData['uid'] ?? '',
          userGymId: userData['userGymId'] ?? '',
          favoritesString: userData['favoritesString'] ?? '',
          profileName: userData['profileName'] ?? '',
          profileDescription: userData['profileDescription'] ?? '');
      newUser.profilePictureUrl =
          userData['profilePictureUrl']; // Could be null
      newUser.followers = (userData['followers'] ?? []).cast<String>();
      newUser.following = (userData['following'] ?? []).cast<String>();
      List<dynamic> activityListJson = userData['activities'] ?? [];
      newUser.activities = activityListJson
          .map((e) => Activity.fromJson(json.decode(e)))
          .toList();
      newUser.splitJson = userData['split']; // Could be null
      newUser.initializeProfilePicData();
      newUser.onlyFriendsCanViewPosts =
          userData['onlyFriendsCanViewPosts'] ?? false;
      appState.visitedUsers.add(newUser);
      return newUser;
    } else {
      print('User $username not found');
      return null;
    }
  } catch (e) {
    print('ERROR - User $username not found: $e');
    return null;
  }
}
