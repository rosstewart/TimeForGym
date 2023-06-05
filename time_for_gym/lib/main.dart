import 'dart:io';
//import 'dart:js_util';
import 'dart:ui';
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
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/favorites_page.dart';
import 'package:time_for_gym/home_page.dart';
import 'package:time_for_gym/muscle_groups_page.dart';
import 'package:time_for_gym/exercises_page.dart';
import 'package:time_for_gym/individual_exercise_page.dart';
import 'package:time_for_gym/gym_crowd_page.dart';
import 'package:time_for_gym/split_page.dart';
import 'package:time_for_gym/split.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'TimeForGym',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Time for Gym',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier with WidgetsBindingObserver {
  late SharedPreferences _prefs;
  String _favoritesString = '';
  String _currentSplitString = '';
  String _splitDayExerciseIndicesString = '';

  MyAppState() {
    initializeMuscleGroups();
    initializeGymCount();
    initPrefs(); // Initializes the user's old favorite exercises
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

  var favoriteExercises = <Exercise>[];
  var pageIndex = 0;

  var muscleGroups = <String, List<Exercise>>{}; // Map<String,Exercise>();
  var gymCount = -1;
  var maxCapacity = 200;

  var areMuscleGroupsInitialized = false;
  var isGymCountInitialized = false;

  var currentMuscleGroup = ""; // String
  var currentExercise = Exercise();

  var fromFavorites = false;
  var fromSplitDayPage = false;

  final databaseRef = FirebaseDatabase.instance.ref();

  var hasSubmittedData = false;

  var currentSplit;
  var makeNewSplit = true;

  var currentDayIndex;
  bool splitDayEditMode = false;
  var editModeTempSplit;
  var editModeTempExerciseIndices;

  List<List<int>> splitDayExerciseIndices = [[], [], [], [], [], [], []];

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

  void shiftSplit(int numDays) {
    currentSplit.shift(numDays);
    shiftExerciseIndices(numDays);

    print("shifted split: $currentSplit");
    print("shifted exercise indices: $splitDayExerciseIndices");
    notifyListeners();

    storeSplitInSharedPreferences();
    saveSplitDayExerciseIndicesData();
  }

  void shiftExerciseIndices(int numDays) {
    int n = splitDayExerciseIndices.length;
    int k;

    if (numDays >= 0) {
      k = numDays % n;
    } else {
      k = (n - (-numDays % n)) % n;
    }

    reverseExerciseIndices(0, n - 1);
    reverseExerciseIndices(0, k - 1);
    reverseExerciseIndices(k, n - 1);
  }

  void reverseExerciseIndices(int start, int end) {
    while (start < end) {
      List<int> temp = splitDayExerciseIndices[start];
      splitDayExerciseIndices[start] = splitDayExerciseIndices[end];
      splitDayExerciseIndices[end] = temp;
      start++;
      end--;
    }
  }

  void toSplitDayEditMode(bool edit) {
    // print("current split $splitDayExerciseIndices");
    // print("temp split $editModeTempExerciseIndices");
    splitDayEditMode = edit;
    if (edit) {
      editModeTempSplit = Split.deepCopy(currentSplit);
      editModeTempExerciseIndices =
          splitDayExerciseIndices.map((innerList) => [...innerList]).toList();
      ;
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

  void addTempMuscleGroupToSplit(int dayIndex, int cardIndex,
      String muscleGroup, int muscleGroupExerciseIndex) {
    editModeTempSplit.trainingDays[dayIndex]
        .insertMuscleGroup(cardIndex, muscleGroup);
    editModeTempExerciseIndices[dayIndex]
        .insert(cardIndex, muscleGroupExerciseIndex);
    notifyListeners();
  }

  void removeTempMuscleGroupFromSplit(int dayIndex, int cardIndex) {
    editModeTempSplit.trainingDays[dayIndex].removeMuscleGroup(cardIndex);
    editModeTempExerciseIndices[dayIndex].removeAt(cardIndex);
    notifyListeners();
  }

  void initializeMuscleGroups() async {
    if (areMuscleGroupsInitialized) {
      // Stop from initializing multiple times
      return;
    }
    // const filePath = '/Users/rossaroni/FlutterProjects/time_for_gym/ExerciseData.txt';
    String url =
        'https://raw.githubusercontent.com/rosstewart/TimeForGym/main/time_for_gym/ExerciseData.txt';
    muscleGroups = await readLinesFromFile(url);

    // var exercises = <Exercise>[];
    // var exercises2 = <Exercise>[];
    // var exercise = Exercise(
    //     name: "Bench Press",
    //     description:
    //         "Lie down on bench, grip the bar, lower to your chest, and press up.",
    //     musclesWorked: "Chest, Front Delts, Triceps",
    //     videoLink: "https://youtu.be/rT7DgCr-3pg",
    //     waitMultiplier: 1.0);
    // exercises.add(exercise);
    // exercises2.add(Exercise(name: "Barbell Row", description: "While standing, hinge down and pull a barbell to your stomach.", musclesWorked: "Back, Biceps, Rear Delts", videoLink: "https://youtu.be/FWJR5Ve8bnQ", waitMultiplier: 0.5));
    // muscleGroups.putIfAbsent("Chest", () => exercises);
    // // muscleGroups.putIfAbsent("Shoulders", () => exercises);
    // // muscleGroups.putIfAbsent("Arms", () => exercises);
    // muscleGroups.putIfAbsent("Back", () => exercises2);

    areMuscleGroupsInitialized = true;

    // Wait until map is initialized before extracting previous favorite exercises & split data
    initializeOldFavorites();
    retrieveSplitFromSharedPreferences();
    initializeSplitDataAndExerciseIndices();
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

    for (final line in lines) {
      if (line.isEmpty) {
        // EOF
        // print("exit");
        break;
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

        // Would make 3 different versions of "Squat", with 3 different mainMuscleGroups. Since mainMuscleGroup is only used for finding an exercise, this does not cause any issues.
        exercise = Exercise(
            name: attributes[0],
            description: attributes[1],
            musclesWorked: attributes[2],
            videoLink: attributes[3],
            waitMultiplier: double.parse(attributes[4]),
            mainMuscleGroup: muscleGroup,
            // Temporarily all image must be gifs and images have same name as exercise name
            imageUrl: "${url.replaceFirst("ExerciseData.txt", "exercise_pictures/")}${attributes[0]}.gif");

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
      throw Exception('Failed to load image. Status code: ${response.statusCode}');
      // return Container(); // Return an empty container if image loading fails
    }
  }

  void initializeGymCount() async {
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

      int index =
          binarySearchExerciseList(muscleGroups[muscleGroupOfExercise]!, name);
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
    fromFavorites = false;
    notifyListeners();
  }

  void changePageToExercise(Exercise exercise) {
    // Exercise page from muscleGroup
    pageIndex = 5;
    // currentMuscleGroup should match the correct muscleGroup for the exercise
    // Need a different approach for viewing exercises from favorites because of back button
    currentExercise = exercise;
    notifyListeners();
  }

  void changePageToFavoriteExercise(Exercise exercise) {
    pageIndex = 5;
    currentExercise = exercise;
    fromFavorites = true;
    notifyListeners();
  }

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
    for (Exercise favoriteExercise in favoriteExercises) {
      if (exercise.compareTo(favoriteExercise) == 0) {
        // If duplicate exercise is already in favorites
        favoriteExercises.remove(favoriteExercise);
        foundFavorite = true;
        break;
      }
    }
    if (!foundFavorite) {
      favoriteExercises.add(exercise);
    }

    favoriteExercises.sort(); // Sort favorite exercises alphabetically

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
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;
    switch (appState.pageIndex) {
      case 0:
        appState.fromSplitDayPage = false;
        page = HomePage();
        break;
      case 1:
        page = MuscleGroupsPage();
        break;
      case 2:
        page = FavoritesPage(); // Favorites page
        break;
      case 3:
        page = GymCrowdPage(); // Gym crowd page
        break;
      case 4:
        page = ExercisesPage();
        break;
      case 5:
        // appState.splitDayEditMode = false;
        page = IndividualExercisePage(); // Exercise page
        break;
      case 6:
        // Reversion changes are already stored in currentSplit
        appState.splitDayEditMode = false;
        page = SplitPage();
        break;
      case 7:
        appState.fromSplitDayPage = true;
        appState.fromFavorites = false;
        page = SplitDayPage(appState.currentDayIndex);
        break;
      default:
        throw UnimplementedError('no widget for ${appState.pageIndex}');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
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
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
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
  });

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    void togglePressed() {
      appState.changePage(index);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
          // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: togglePressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          // child: Text("${wordPair.first} ${wordPair.second}", style: style),
          child: Center(
            child: Text(
              text,
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
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
        SizedBox(width: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.fromRGBO(200, 200, 200, 1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
            child: BackButton(
              onPressed: togglePressed,
            ),
          ),
        ),
      ],
    );
  }
}

class BackFromSplitPage extends Back {
  BackFromSplitPage({required super.appState, required super.index});

  @override
  void togglePressed() {
    if (appState.currentSplit != null && appState.makeNewSplit) {
      // On the regenerate split page
      appState.makeNewSplit = false;
    }
    appState.changePage(index);
  }
}

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
    final style = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    void togglePressed() {
      appState.changePageToMuscleGroup(muscleGroupName);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
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
    final style = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    void togglePressed() {
      appState.changePageToExercise(exercise);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
          // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: togglePressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          // child: Text("${wordPair.first} ${wordPair.second}", style: style),
          child: Center(
            child: Text(
              exercise.name,
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class FavoriteExerciseSelectorButton extends StatelessWidget {
  const FavoriteExerciseSelectorButton({
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
    final style = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    void togglePressed() {
      appState.changePageToFavoriteExercise(exercise);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
          // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: togglePressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          // child: Text("${wordPair.first} ${wordPair.second}", style: style),
          child: Center(
            child: Text(
              exercise.name,
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  const ExerciseCard(
      {super.key,
      required this.name,
      required this.description,
      required this.musclesWorked,
      required this.expectedWaitTime,
      required this.imageUrl});

  final String name;
  final String description;
  final String musclesWorked;
  final String expectedWaitTime;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        color: theme.colorScheme.surface,
        elevation: 10, // Shadow
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(name,style: titleStyle),
              // Image.asset('assets/images/Barbell Bench Press.gif'),
              RichText(
                text: TextSpan(
                  style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Instructions:  ',
                      style: headingStyle,
                    ),
                    TextSpan(
                      text: description,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Muscles worked:  ',
                      style: headingStyle,
                    ),
                    TextSpan(
                      text: musclesWorked,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Expected wait time:  ',
                      style: headingStyle,
                    ),
                    TextSpan(
                      text: '$expectedWaitTime minutes',
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
    var appState = context.watch<MyAppState>();
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
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        color: theme.colorScheme.surface,
        elevation: 10, // Shadow
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Max Capacity:  ',
                      style: headingStyle,
                    ),
                    TextSpan(
                      text: appState.maxCapacity.toString(),
                      style: textStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              chart,
              SizedBox(
                height: 10,
              ),
              Text("${(chart.percentCapacity * 100).toInt()} %"),
              SizedBox(
                height: 30,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Current capacity:  ',
                      style: headingStyle,
                    ),
                    TextSpan(
                      text: appState.gymCount.toString(),
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
  const ImageContainer({
    super.key,
    required this.exercise,
  });

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    try {
      return Padding(
        padding: EdgeInsets.fromLTRB(50, 10, 50, 20),
        child: FutureBuilder<ImageProvider<Object>>(
          future: _loadImage(exercise.imageUrl),
          builder: (BuildContext context,
              AsyncSnapshot<ImageProvider<Object>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                print('Error loading image: ${snapshot.error}');
                return Text('Failed to load image');
              }
              return Image(image: snapshot.data!);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      );
    } catch (e) {
      print('Failed to load image: $e');
      return Text('Failed to load image');
    }
  }

  Future<ImageProvider<Object>> _loadImage(String imageUrl) async {
    final completer = Completer<ImageProvider<Object>>();
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final imageProvider = MemoryImage(response.bodyBytes);
      completer.complete(imageProvider);
    } else {
      completer.completeError(
          'Failed to load image. Status code: ${response.statusCode}');
    }
    return completer.future;
  }
}