// import 'dart:ffi';
import 'dart:io';
//import 'dart:js_util';
// import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:time_for_gym/split_day_page.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:typed_data';
// import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:connectivity/connectivity.dart';

import 'package:time_for_gym/exercise.dart';
// import 'package:time_for_gym/favorites_page.dart';
import 'package:time_for_gym/home_page.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';
import 'package:time_for_gym/exercises_page.dart';
import 'package:time_for_gym/individual_exercise_page.dart';
import 'package:time_for_gym/gym_crowd_page.dart';
import 'package:time_for_gym/split_page.dart';
import 'package:time_for_gym/split.dart';
import 'package:time_for_gym/search_page.dart';
// import 'package:time_for_gym/split_exercise_index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'TimeForGym',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  // const?
  MyApp({
    super.key,
  });

  // final Color primaryColor = Color.fromRGBO(0, 159, 153, 1);

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

//     final textTheme = TextTheme(
//   displayLarge: TextStyle(fontFamily: 'Montserrat-Regular'),
//   displayMedium: TextStyle(fontFamily: 'Montserrat-Regular'),
//   displaySmall: TextStyle(fontFamily: 'Montserrat-Regular'),
//   headlineLarge: TextStyle(fontFamily: 'Montserrat-Regular'),
//   headlineMedium: TextStyle(fontFamily: 'Montserrat-Regular'),
//   headlineSmall: TextStyle(fontFamily: 'Montserrat-Regular'),
//   titleLarge: TextStyle(fontFamily: 'Montserrat-Regular'),
//   titleMedium: TextStyle(fontFamily: 'Montserrat-Regular'),
//   titleSmall: TextStyle(fontFamily: 'Montserrat-Regular'),
//   bodyLarge: TextStyle(fontFamily: 'Montserrat-Regular'),
//   bodyMedium: TextStyle(fontFamily: 'Montserrat-Regular'),
//   bodySmall: TextStyle(fontFamily: 'Montserrat-Regular'),
//   labelLarge: TextStyle(fontFamily: 'Montserrat-Regular'),
//   labelMedium: TextStyle(fontFamily: 'Montserrat-Regular'),
//   labelSmall: TextStyle(fontFamily: 'Montserrat-Regular'),
// );

    ThemeData theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: primarySwatch,
          primaryColorDark: onBackground,
          accentColor: secondaryColor,
          // cardColor: Color.fromRGBO(20, 20, 20, 1),
          backgroundColor: Color.fromRGBO(20, 20, 20, 1),
        ),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color.fromRGBO(20, 20, 20, 1),
        dialogBackgroundColor: Color.fromRGBO(20, 20, 20, 1),
        // textTheme: textTheme,
        dialogTheme: DialogTheme(
            surfaceTintColor: Color.fromRGBO(20, 20, 20, 1),
            backgroundColor: Color.fromRGBO(20, 20, 20, 1)),
        appBarTheme: AppBarTheme(
          // color: Color.fromRGBO(20, 20, 20, 1),
          surfaceTintColor: Color.fromRGBO(20, 20, 20, 1),
        ));

    // Create a new theme based on the original theme with the updated onBackground color
    theme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        onBackground:
            Color.fromRGBO(235, 235, 235, 1), // Replace with your desired color
        onPrimary: Color.fromRGBO(235, 235, 235, 1),
        tertiary: Color.fromRGBO(17, 75, 95, 1),
        primaryContainer: Color.fromRGBO(30, 30, 30, 1),
        secondaryContainer: Color.fromRGBO(40, 40, 40, 1),
        tertiaryContainer: Color.fromRGBO(50, 50, 50, 1),
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
  late SharedPreferences _prefs;
  String _favoritesString = '';
  // String _currentSplitString = '';
  String _splitDayExerciseIndicesString = '';

  // final Color onBackground = Color.fromRGBO(17, 75, 95, 1);

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
    notifyListeners();
    await initializeUserID(); // Need user id for muscle group exercise user popularity data
    await initPrefs(); // Need to initialize shared preferences strings to initialize favorites in initializeMuscleGroups
    await initializeMuscleGroups();
    await initializeGymCount();
    // initializeOldFavorites();
    // initializeFirebase(); // For storing user-reported occupancy data
  }

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _favoritesString = _prefs.getString('favorites') ?? '';
    // _currentSplitString = _prefs.getString('currentSplit') ?? '';
    _splitDayExerciseIndicesString =
        _prefs.getString('splitDayExerciseIndices') ?? '';
    // initializeOldFavorites();
    notifyListeners();
  }

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
          "${exercise.toString()}-${exercise.mainMuscleGroup},";
    }
    if (favoriteExercisesAsString.isNotEmpty) {
      // Remove last comma
      favoriteExercisesAsString = favoriteExercisesAsString.substring(
          0, favoriteExercisesAsString.length - 1);
    }
    _favoritesString = favoriteExercisesAsString;
    await _prefs.setString('favorites', _favoritesString);
  }

  // Future<void> saveSplitData() async {
  //   print(currentSplit.toMuscleGroupString());
  //   await _prefs.setString('currentSplit', currentSplit.toMuscleGroupString());
  // }

  Future<void> saveSplitDayExerciseIndicesData() async {
    print(splitDayExerciseIndices.toString());
    await _prefs.setString(
        'splitDayExerciseIndices', splitDayExerciseIndices.toString());
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
  //   WidgetsBinding.instance.removeObserver(this);
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
  var pageIndex = 0;

  var muscleGroups = <String, List<Exercise>>{}; // Map<String,Exercise>();
  var gymCount = -1;
  var maxCapacity = 200;

  var areMuscleGroupsInitialized = false;
  var isGymCountInitialized = false;

  var currentMuscleGroup = ""; // String
  var currentExercise = Exercise(splitWeightAndReps: []);
  var currentExerciseFromSplitDayPage = Exercise(splitWeightAndReps: []);

  // var fromFavorites = false;
  var fromSplitDayPage = false;
  var fromSearchPage = false;

  final databaseRef = FirebaseDatabase.instance.ref();

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
  String searchQuery = '';

  List<List<int>> splitDayExerciseIndices = [[], [], [], [], [], [], []];

  String userID = '';

  List<Widget> appPages = [
    HomePage(),
    Placeholder(),
    Placeholder(),
    GymCrowdPage(),
    ExercisesPage(),
    IndividualExercisePage(),
    SplitPage(),
    SplitDayPage(0),
    SearchPage()
  ];

  void setSplit(Split split) {
    currentSplit = split;
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
    }
    notifyListeners();
  }

  void saveEditChanges() {
    // Variables now point to the new objects
    currentSplit = editModeTempSplit;
    splitDayExerciseIndices = editModeTempExerciseIndices;

    storeSplitInSharedPreferences();
    saveSplitDayExerciseIndicesData();
    toSplitDayEditMode(false);
  }

  void saveReorderChanges() {
    // Variables now point to the new objects
    currentSplit = editModeTempSplit;
    splitDayExerciseIndices = editModeTempExerciseIndices;

    storeSplitInSharedPreferences();
    saveSplitDayExerciseIndicesData();
    toSplitDayReorderMode(false);
  }

  void addTempMuscleGroupToSplit(int dayIndex, int cardIndex,
      String muscleGroup, int muscleGroupExerciseIndex, int numSets) {
    editModeTempSplit.trainingDays[dayIndex]
        .insertMuscleGroup(cardIndex, muscleGroup, numSets);
    editModeTempExerciseIndices[dayIndex]
        .insert(cardIndex, muscleGroupExerciseIndex);
    notifyListeners();
  }

  List<dynamic> removeTempMuscleGroupFromSplit(int dayIndex, int cardIndex) {
    final muscleGroupAndNumSets =
        editModeTempSplit.trainingDays[dayIndex].removeMuscleGroup(cardIndex);
    final exerciseIndex =
        editModeTempExerciseIndices[dayIndex].removeAt(cardIndex);
    notifyListeners();
    // muscle group, exercise index, number of sets
    return [muscleGroupAndNumSets[0], exerciseIndex, muscleGroupAndNumSets[1]];
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
    retrieveSplitFromSharedPreferences();
    initializeSplitDataAndExerciseIndices();
    isInitializing = false;
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

    Map<String, List<double?>> exerciseDataMap = await fetchExerciseData();

    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      }
      if (line.startsWith('MuscleGroup: ')) {
        if (!start) {
          exercises.sort(); // Sort alphabetically
          newMap.putIfAbsent(muscleGroup, () => exercises);
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
        } else {
          userRatingAndAverageRatingAnd1RMAndWeightAndReps =
              exerciseDataMap[attributes[0]]!;
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
        }
        print(
            "${attributes[0]} ${userRatingAndAverageRatingAnd1RMAndWeightAndReps[0]} ${userRatingAndAverageRatingAnd1RMAndWeightAndReps[1]} $userOneRepMax $userSplitWeightAndReps");

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
                waitMultiplier =
                    userRatingAndAverageRatingAnd1RMAndWeightAndReps[1]! /
                        5.0; // Always a number 0-5 or 0
                break resourceRequiredLoop;
              case 'Preacher Curl Bench':
                waitMultiplier += 0.3;
                break;
              case 'Parallel Bars':
                waitMultiplier += 0.2;
                break;
              case 'Rack':
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

        // Would make 3 different versions of "Squat", with 3 different mainMuscleGroups. Since mainMuscleGroup is only used for finding an exercise, this does not cause any issues.
        exercise = Exercise(
            name: attributes[0],
            description: attributes[1],
            musclesWorked: attributes[2],
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
            userOneRepMax: userOneRepMax,
            isAccessoryMovement: int.parse(attributes[6]) != 0,
            splitWeightAndReps: userSplitWeightAndReps);

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

    print("Muscle group map: $newMap");

    // print(jsonEncode(newMap));
    // File file = File("/Users/rossaroni/Desktop/MuscleGroupMap.json");
    // file.writeAsStringSync(jsonEncode(newMap));
    // print('JSON data written to file: MuscleGroupMap.json');

    return newMap;
  }

// Function to download and create a container with the image from a URL
  Future<Uint8List> downloadImageFromUrl(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      // Uint8List imageBytes = response.bodyBytes;
      // ImageProvider imageProvider = MemoryImage(imageBytes);

      return response.bodyBytes;

      // print("worked $imageUrl");

      // return Container(
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //       image: imageProvider,
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      // );
    } else {
      print(imageUrl);
      // print('Failed to load image. Status code: ${response.statusCode}');
      throw Exception(
          'Failed to load image. Status code: ${response.statusCode}');
      // return Container(); // Return an empty container if image loading fails
    }
  }

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
    if (_favoritesString.isEmpty) {
      print("No favorite exercises");
      return;
    }

    List<String> favoriteStrings = _favoritesString.split(",");

    for (String favoriteString in favoriteStrings) {
      // For each exercise
      List<String> nameAndMuscleGroup =
          favoriteString.split("-"); // Split up name and muscle group
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
    if (_splitDayExerciseIndicesString.isEmpty) {
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

    String splitDayExerciseIndicesStringTemp = _splitDayExerciseIndicesString
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

  // Storing the Split object in SharedPreferences
  void storeSplitInSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String splitJson = json.encode(currentSplit.toJson());
    await prefs.setString('split', splitJson);
  }

// Retrieving the Split object from SharedPreferences
  void retrieveSplitFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? splitJson = prefs.getString('split');
    if (splitJson != null) {
      Map<String, dynamic> splitMap = json.decode(splitJson);
      currentSplit = Split.fromJson(splitMap);
      makeNewSplit = false;
      print("initialized split: $currentSplit");
    } else {
      print("No split saved");
    }
  }

  Future<void> initializeUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userID');
    if (uid != null) {
      // userID is intialized as empty string
      userID = uid;
    } else {
      userID = await getDeviceId(); // Generate unique user id for each device
      prefs.setString('userID', userID);
    }
    print("userID: $userID");
  }

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String? deviceId; // Make the variable nullable and assign a default value

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }

    return deviceId ?? ''; // Return a default value if deviceId is null
  }

  void submitExercisePopularityDataToFirebase(
      String userID,
      String exerciseName,
      String mainMuscleGroup,
      double? numStars,
      int? oneRepMax,
      List<int> splitWeightAndReps) {
    // String timestamp = DateTime.now().toString();
    ExercisePopularityData data = ExercisePopularityData(userID, exerciseName,
        mainMuscleGroup, numStars, oneRepMax, splitWeightAndReps);
    // Unique child for each exercise name
    databaseRef
        .child('exercisePopularityData')
        .child(data.exerciseName)
        .child(data.userID)
        .set(data.toJson());
    // databaseRef.child('exercisePopularityData').push().set(data.toJson());
    // hasSubmittedData = true;
    // notifyListeners();
    print("Submitted exercise popularity data to firebase database");
    // Null values simply don't appear as entries on database
  }

  Future<Map<String, List<double?>>> fetchExerciseData() async {
    Map<String, List<double?>> exerciseStarDataMap = <String, List<double?>>{};

    try {
      DatabaseEvent event =
          await databaseRef.child('exercisePopularityData').once();
      // .orderByChild('exerciseName')
      // .equalTo(exerciseName)
      // .child(exerciseName)
      // .once();

      DataSnapshot snapshot = event.snapshot;

      Map<dynamic, dynamic>? exerciseData =
          snapshot.value as Map<dynamic, dynamic>?;

      // print (exerciseData.toString());

      if (exerciseData != null) {
        exerciseData.forEach((exercise, uidData) {
          String exerciseName = exercise.toString();
          Map<dynamic, dynamic> userIDData = uidData;

          double? userNumStars;
          double avgNumStars = 0.0;
          double userCounter = 0.0;
          double? userOneRepMax;
          double? userSplitWeight;
          double? userSplitReps;

          // String exerciseName;
          String? mainMuscleGroup;

          userIDData.forEach((key, data) {
            String uid = key.toString();
            Map<dynamic, dynamic> exercisePopularity = data;

            // exerciseName = exercisePopularity['exerciseName'];
            mainMuscleGroup = exercisePopularity['mainMuscleGroup'];
            if (uid == userID) {
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
            }
            if (exercisePopularity['numStars'] != null) {
              avgNumStars = avgNumStars +
                  (exercisePopularity['numStars'] + 0.0); // Avoid error
              userCounter++;
            }

            print("User ID: $uid");
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
                    userNumStars,
                    avgNumStars,
                    userOneRepMax,
                    userSplitWeight,
                    userSplitReps
                  ]);
        });
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
    String timestamp = DateTime.now().toString();
    OccupancyData data = OccupancyData(currentOccupancy, timestamp);
    databaseRef.child('occupancyData').push().set(data.toJson());
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

  void changePageToExercise(Exercise exercise) {
    // Exercise page from muscleGroup
    pageIndex = 5;
    // currentMuscleGroup should match the correct muscleGroup for the exercise
    // Need a different approach for viewing exercises from favorites because of back button
    if (fromSplitDayPage) {
      currentExerciseFromSplitDayPage = exercise;
    } else {
      currentExercise = exercise;
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
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _bottomNavigationIndex = 0;

  bool isReloadingInternet = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
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

    if (appState.noInternetInitialization) {
      return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
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
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
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
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                        )),
                  // CircularProgressIndicator(),
                  Spacer(),
                  SizedBox(
                    height: 150,
                  ),
                ]));
      });
    }

    if (appState.isInitializing) {
      return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
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
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
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
                  Spacer(),
                  CircularProgressIndicator(),
                  Spacer(),
                  SizedBox(
                    height: 150,
                  ),
                ]));
      });
    }

    Widget page;
    switch (appState.pageIndex) {
      case 0:
        appState.fromSplitDayPage = false;
        _bottomNavigationIndex = 0; // Update navigation bar
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
        appState.presetSearchPage = 1;
        page = ExercisesPage();
        break;
      case 5:
        // appState.splitDayEditMode = false;
        // Only remembers exercise from search page if an exercise is not looked at from another page
        // if (appState.fromSearchPage) {
        if (!appState.fromSplitDayPage) {
          // Only update if clicking on exercise from search page or exercises page
          appState.presetSearchPage = 2;
        }
        // } else if (appState.fromFavorites || appState.fromSplitDayPage) {
        //   appState.presetSearchPage = 0;
        // }
        page = IndividualExercisePage(); // Exercise page
        break;
      case 6:
        // Reversion changes are already stored in currentSplit
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
        appState.goStraightToSplitDayPage =
            true; // Go back to the split day page they were last on
        page = SplitDayPage(appState.currentDayIndex);
        break;
      case 8:
        // Search screen
        // appState.fromFavorites = false;
        appState.fromSplitDayPage = false;
        appState.fromSearchPage = true;
        _bottomNavigationIndex = 1; // Update navigation bar
        appState.presetSearchPage = 0;
        page = SearchPage();
        break;
      default:
        throw UnimplementedError('no widget for ${appState.pageIndex}');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        // body: _bottomScreens[_currentIndex],
        body: Row(
          children: [
            // SafeArea(
            //   child: NavigationRail(
            //     extended: constraints.maxWidth >= 600,
            //     destinations: [
            //       NavigationRailDestination(
            //         icon: Icon(Icons.home),
            //         label: Text('Home'),
            //       ),
            //       NavigationRailDestination(
            //         icon: Icon(Icons.favorite),
            //         label: Text('Favorites'),
            //       ),
            //     ],
            //     selectedIndex: selectedIndex,
            //     onDestinationSelected: (value) {
            //       setState(() {
            //         selectedIndex = value;
            //       });
            //     },
            //   ),
            // ),
            Expanded(
              child: Container(
                // color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: theme.colorScheme.onBackground,
          selectedItemColor: theme.colorScheme.primary,
          currentIndex: _bottomNavigationIndex,
          onTap: (int index) {
            setState(() {
              if (appState.currentSplit != null && appState.makeNewSplit) {
                // On the regenerate split page, if they already have a split put them back to view split option
                appState.makeNewSplit = false;
              }
              if (index == 0) {
                // Home
                appState.changePage(0);
                appState.splitDayEditMode =
                    false; // Cancel changes when changing to different screen
                appState.splitDayReorderMode = false;
                appState.splitWeekEditMode = false;
              } else if (index == 1) {
                // Search Page

                if (appState.pageIndex == 4 ||
                    (appState.pageIndex == 5 && !appState.fromSplitDayPage) ||
                    appState.presetSearchPage == 0) {
                  // Exercises page or individual exercise page or other tab, or if search page is preset
                  appState.changePage(8);
                  appState.splitDayEditMode =
                      false; // Cancel changes when changing to different screen
                  appState.splitDayReorderMode = false;
                  appState.splitWeekEditMode = false;
                  appState.fromSplitDayPage = false;
                } else {
                  appState.fromSplitDayPage = false;
                  if (appState.presetSearchPage == 1) {
                    appState.changePage(4);
                  } else {
                    // Preset search page == 2
                    appState.changePage(5);
                  }
                }
              } else if (index == 2) {
                appState.fromSearchPage = false;
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
              }
              _bottomNavigationIndex = index;
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
              label: 'Your Split',
            ),
          ],
        ),
      );
    });
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
    appState.changePage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 15),
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
  const SwipeBack({
    Key? key,
    required this.appState,
    required this.index,
    required this.child,
  }) : super(key: key);

  final MyAppState appState;
  final int index;
  final Widget child;

  @override
  _SwipeBackState createState() => _SwipeBackState();
}

class _SwipeBackState extends State<SwipeBack> {
  bool _isDismissed = false;

  void toggleSwipe() {
    widget.appState.changePage(widget.index);
  }

  @override
  Widget build(BuildContext context) {
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

class ExerciseSelectorButton extends StatelessWidget {
  const ExerciseSelectorButton({
    super.key,
    required this.exercise,
    // required this.index,
  });

  final Exercise exercise;
  // final int index;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    void togglePressed() {
      // Coming from individual muscle group page
      appState.fromSearchPage = false;
      // appState.fromFavorites = false;
      appState.fromSplitDayPage = false;
      appState.changePageToExercise(exercise);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: TextButton(
        onPressed: togglePressed,
        child: Row(children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: theme.colorScheme.onBackground),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ImageContainer(exercise: exercise),
            ),
          ),
          SizedBox(width: 25),
          Text(
            exercise.name,
            style: style,
          ),
        ]),
      ),
      //  ElevatedButton(
      //   style: ButtonStyle(
      //     backgroundColor:
      //         MaterialStateProperty.all<Color>(theme.colorScheme.primary),
      //     // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      //   ),
      //   onPressed: togglePressed,
      //   child: Padding(
      //     padding: const EdgeInsets.all(20),
      //     child: Center(
      //       child: Text(
      //         exercise.name,
      //         style: style,
      //         textAlign: TextAlign.center,
      //       ),
      //     ),
      //   ),
      // ),
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

// ignore: must_be_immutable
class ExerciseCard extends StatefulWidget {
  ExerciseCard({
    super.key,
    required this.exercise,
    // required this.name,
    // required this.description,
    // required this.mainMuscleGroup,
    // required this.musclesWorked,
    required this.expectedWaitTime,
    // required this.imageUrl,
    // required this.averageRating,
    // this.userRating});
  });

  Exercise exercise;

  // final String name = exercise.name;
  // final String description;
  // final String mainMuscleGroup;
  // final String musclesWorked;
  final String expectedWaitTime;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isSubmitButtonPressed = false;
  Timer? _timer;
  double? initialStars;
  double? starsToSubmit;

  @override
  void initState() {
    super.initState();
    initialStars = widget.exercise.userRating;
    initialStars ??= 2.5; // if null set to 2.5
    starsToSubmit = initialStars;
    print("initial stars $initialStars");
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleSubmitButtonPress(double starsToSubmit) {
    setState(() {
      _isSubmitButtonPressed = true;
    });

    widget.exercise.userRating =
        starsToSubmit; // Update exercise data in memory

    _timer = Timer(Duration(seconds: 2), () {
      setState(() {
        widget.exercise.userRating =
            starsToSubmit; // Update exercise data in memory
        _isSubmitButtonPressed = false;
      });
    });

    // _timer;
  }

  // final String imageUrl;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context);
    // final titleStyle = theme.textTheme.displaySmall!.copyWith(
    //   color: theme.colorScheme.secondary,
    // );
    final headingStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      // fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    Icon submittedIcon;
    Text submittedText;
    print(
        "$_isSubmitButtonPressed ${widget.exercise.userRating} $starsToSubmit");
    if (!_isSubmitButtonPressed &&
        widget.exercise.userRating != starsToSubmit) {
      submittedIcon = Icon(
        Icons.send,
        color: theme.colorScheme.primary,
      );
      submittedText = Text('Submit',
          style: TextStyle(color: theme.colorScheme.onBackground));
    } else {
      submittedIcon = Icon(
        Icons.check,
        color: theme.colorScheme.primary,
      );
      submittedText = Text('Submitted',
          style: TextStyle(color: theme.colorScheme.onBackground));
    }

    String equipmentNeededString = "None";
    if (widget.exercise.resourcesRequired != null &&
        widget.exercise.resourcesRequired!.isNotEmpty) {
      equipmentNeededString = "";
      for (String resourceRequired in widget.exercise.resourcesRequired!) {
        equipmentNeededString += "$resourceRequired, ";
      }
      if (equipmentNeededString.isNotEmpty) {
        // Remove trailing comma and space
        equipmentNeededString = equipmentNeededString.substring(
            0, equipmentNeededString.length - 2);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      // child: Card(
      //   color: theme.colorScheme.surface,
      //   elevation: 10, // Shadow
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions',
              style: headingStyle,
            ),
            SizedBox(height: 5),
            Text(
              widget.exercise.description,
              style: textStyle,
            ),
            // Text(name,style: titleStyle),
            // Image.asset('assets/images/Barbell Bench Press.gif'),
            SizedBox(
              height: 30,
            ),
            Text(
              'Muscles Worked',
              style: headingStyle,
            ),
            SizedBox(height: 5),
            Text(
              widget.exercise.musclesWorked,
              style: textStyle,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Expected Wait Time',
              style: headingStyle,
            ),
            SizedBox(height: 5),
            Text(
              '${widget.expectedWaitTime} Minutes',
              style: textStyle,
            ),
            SizedBox(
              height: 30,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Average Star Rating',
                  style: headingStyle,
                ),
                Spacer(),
                if (widget.exercise.userRating == null)
                  Text(
                    'Leave a Rating',
                    style: headingStyle,
                  ),
                if (widget.exercise.userRating != null)
                  Text(
                    'Edit Rating',
                    style: headingStyle,
                  ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.exercise.starRating}',
                  style: textStyle,
                ),
                SizedBox(
                  width: 10,
                ),
                for (int i = 0; i < 5; i++)
                  if (i + 1 <= widget.exercise.starRating)
                    Icon(Icons.star, color: theme.colorScheme.primary)
                  else if (i + 0.5 <= widget.exercise.starRating)
                    Icon(Icons.star_half, color: theme.colorScheme.primary)
                  else
                    Icon(Icons.star_border, color: theme.colorScheme.primary),

                Spacer(),
                // if (userRating == null)
                // for (int i = 0; i < 5; i++)

                // StarRatingButton(
                //   onRatingSelected: (rating) {
                //     // Handle the selected rating value
                //     print('Selected rating: $rating');
                //   },
                // )

                RatingBar.builder(
                  unratedColor: theme.colorScheme.primaryContainer,
                  initialRating: initialStars!,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 23.5,
                  glow: false,
                  itemBuilder: (context, index) {
                    return Icon(Icons.star, color: theme.colorScheme.primary);
                  },
                  onRatingUpdate: (rating) {
                    // Handle the selected rating value
                    print('Selected rating: $rating');
                    setState(() {
                      starsToSubmit = rating;
                    });
                  },
                ),

                // for (int i = 0; i < 5; i++)
                //   if (i + 1 <= averageRating)
                //     Icon(Icons.star, color: theme.colorScheme.onBackground,)
                //   else if (i + 0.5 <= averageRating)
                //     Icon(Icons.star_half, color: theme.colorScheme.onBackground)
                //   else
                //     Icon(Icons.star_border,
                //         color: theme.colorScheme.onBackground),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        resolveColor(theme.colorScheme.primaryContainer),
                    surfaceTintColor:
                        resolveColor(theme.colorScheme.primaryContainer)),
                onPressed: () {
                  // if (widget.exercise.userRating == null) {
                  // User hasn't submitted data for this exercise yet

                  // Doesn't matter if user has submitted data already
                  if (!_isSubmitButtonPressed &&
                      widget.exercise.userRating != starsToSubmit) {
                    appState.submitExercisePopularityDataToFirebase(
                        appState.userID,
                        widget.exercise.name,
                        widget.exercise.mainMuscleGroup,
                        starsToSubmit,
                        widget.exercise.userOneRepMax,
                        widget.exercise.splitWeightAndReps);
                    _handleSubmitButtonPress(starsToSubmit!);
                  }
                  // } else {
                  // User has already submitted data for this exercise, update data
                  //   appState.submitExercisePopularityDataToFirebase(
                  //       appState.userID,
                  //       widget.exercise.name,
                  //       widget.exercise.mainMuscleGroup,
                  //       starsToSubmit);
                  //   widget.exercise.userRating = starsToSubmit;
                  // }
                },
                label: submittedIcon,
                icon: submittedText,
              ),
            ),
            Text(
              'Equipment Needed',
              style: headingStyle,
            ),
            SizedBox(height: 5),
            Text(
              equipmentNeededString,
              style: textStyle,
            ),
          ],
        ),
      ),
      // ),
    );
  }
}

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

  CustomCircularProgressIndicator(
      {this.strokeWidth = 10.0, this.percentCapacity = 0.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 60.0,
      height: 60.0,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        value: percentCapacity,
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        backgroundColor: theme.colorScheme.onPrimary,
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
  // bool isImageInitialized = false;

  @override
  Widget build(BuildContext context) {
    try {
      return FutureBuilder(
        future: checkAssetExists("exercise_pictures/${exercise.name}.gif"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data == true) {
              return Image.asset('exercise_pictures/${exercise.name}.gif');
            } else {
              print(('Failed to load $exercise image'));
              return Container();
              // return Text('Failed to load image');
            }
          } else {
            return CircularProgressIndicator();
          }
        },

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
      );
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
    } catch (e) {
      print('Failed to load image: $e');
      return Text('Failed to load image');
    }
  }

  // Future<bool> loadImageAsset(BuildContext context) async {
  //   try {
  //     await precacheImage(
  //         AssetImage('exercise_pictures/${exercise.name}.gif'), context);
  //     return true; // Image loaded successfully
  //   } catch (error) {
  //     return false; // Asset not found or error occurred
  //   }
  // }

  // Future<ImageProvider<Object>> _loadImage(String imageUrl) async {
  //   final completer = Completer<ImageProvider<Object>>();
  //   final response = await http.get(Uri.parse(imageUrl));
  //   if (response.statusCode == 200) {
  //     final imageProvider = MemoryImage(response.bodyBytes);
  //     completer.complete(imageProvider);
  //   } else {
  //     completer.completeError(
  //         'Failed to load image. Status code: ${response.statusCode}');
  //   }
  //   return completer.future;
  // }
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
    try {
      return FutureBuilder(
        future: checkAssetExists("muscle_group_pictures/$muscleGroup.jpeg"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data == true) {
              return Image.asset(
                'muscle_group_pictures/$muscleGroup.jpeg',
                fit: BoxFit.cover,
              );
            } else {
              print('Failed to load image $muscleGroup');
              return Container();
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    } catch (e) {
      print('Failed to load image: $e');
      return Text('Failed to load image');
    }
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
