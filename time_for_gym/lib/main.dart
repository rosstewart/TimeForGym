import 'dart:io';
//import 'dart:js_util';
import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/favorites_page.dart';
import 'package:time_for_gym/home_page.dart';
import 'package:time_for_gym/muscle_groups_page.dart';
import 'package:time_for_gym/exercises_page.dart';
import 'package:time_for_gym/individual_exercise_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Time for Gym',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState() {
    initializeMuscleGroups();
  }

  var favoriteExercises = <Exercise>[];
  var pageIndex = 0;

  var muscleGroups = <String, List<Exercise>>{}; // Map<String,Exercise>();

  var areMuscleGroupsInitialized = false;

  var currentMuscleGroup; // String
  var currentExercise;

  var fromFavorites;

  void initializeMuscleGroups() async {
    if (areMuscleGroupsInitialized) {
      // Stop from initializing multiple times
      return;
    }
    const filePath = '/Users/rossaroni/FlutterProjects/time_for_gym/ExerciseData.txt';
    muscleGroups = await readLinesFromFile(filePath);


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
  }


  Future<Map<String, List<Exercise>>> readLinesFromFile(String filePath) async {

  final file = File(filePath);
  final lines = await file.readAsLines();
  Map<String, List<Exercise>> newMap = <String, List<Exercise>>{};
  List<String> attributes;
  List<Exercise> exercises = <Exercise>[];
  Exercise exercise;
  
  String muscleGroup = "";
  bool start = true;

  for (final line in lines) {
    if (line.startsWith('MuscleGroup: ')) {
      if (!start){
        // print(muscleGroup);
        // print(exercises);
        newMap.putIfAbsent(muscleGroup, () => exercises);
        // print(newMap);
        exercises = <Exercise>[]; // Allocate memory for new list of exercises
        // print(newMap);
      } else{
        start = false;
      }
      muscleGroup = line.substring('MuscleGroup: '.length); // Save muscle group

    } else {
      attributes = line.split("|"); 
      exercise = Exercise(name: attributes[0], description: attributes[1], musclesWorked: attributes[2], videoLink: attributes[3], waitMultiplier: double.parse(attributes[4]));
      // print("else: $exercise");
      exercises.add(exercise);
      // print("else: $exercises");
    }
  }

  // print(muscleGroup);
  // print(exercises);

  newMap.putIfAbsent(muscleGroup, () => exercises);

  print(newMap);

  return newMap;

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

  void changePageToExercise(String exerciseName) {
    // Exercise page from muscleGroup
    pageIndex = 5;
    // currentMuscleGroup should match the correct muscleGroup for the exercise
    // Need a different approach for viewing exercises from favorites because of back button
    currentExercise = exerciseName;
    notifyListeners();
  }

  void changePageToFavoriteExercise(Exercise exercise){
        pageIndex = 5;
        currentExercise = exercise.name;
        fromFavorites = true;
        notifyListeners();
  }

  void toggleFavorite(Exercise exercise) {
    if (favoriteExercises.contains(exercise)) {
      favoriteExercises.remove(exercise);
    } else {
      favoriteExercises.add(exercise);
    }
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
        page = HomePage();
        break;
      case 1:
        page = MuscleGroupsPage();
        break;
      case 2:
        page = FavoritesPage(); // Favorites page
        break;
      case 3:
        page = Placeholder(); // Gym crowd page
        break;
      case 4:
        page = ExercisesPage();
        break;
      case 5:
        page = IndividualExercisePage(); // Exercise page
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
    required this.exerciseName,
    // required this.index,
  });

  final String exerciseName;
  // final int index;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    void togglePressed() {
      appState.changePageToExercise(exerciseName);
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
              exerciseName,
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



// class GeneratorPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();
//     var pair = appState.current;

//     IconData icon;
//     if (appState.favorites.contains(pair)) {
//       icon = Icons.favorite;
//     } else {
//       icon = Icons.favorite_border;
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           BigCard(wordPair: pair),
//           SizedBox(height: 10),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: () {
//                   appState.toggleFavorite();
//                 },
//                 icon: Icon(icon),
//                 label: Text('Like'),
//               ),
//               SizedBox(width: 10),
//               ElevatedButton(
//                 onPressed: () {
//                   appState.getNext();
//                 },
//                 child: Text('Next'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FavoritesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();
//     var favorites = appState.favorites;

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: ListView(
//           children: [
//             if (favorites.isEmpty) Text("You have no favorites"),
//             if (favorites.length == 1)
//               Text("You have ${favorites.length} favorite"),
//             if (favorites.length > 1)
//               Text("You have ${favorites.length} favorites"),
//             SizedBox(
//               height: 20,
//             ),
//             for (WordPair wordPair in favorites)
//               FavoriteLine(wordPair: wordPair),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FavoriteLine extends StatelessWidget {
//   const FavoriteLine({
//     super.key,
//     required this.wordPair,
//   });

//   final WordPair wordPair;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(height: 25),
//         FavoriteIconButton(wordPair: wordPair),
//         SizedBox(width: 10),
//         Text(wordPair.toString()),
//       ],
//     );
//   }
// }

// class FavoriteIconButton extends StatefulWidget {
//   const FavoriteIconButton({
//     super.key,
//     required this.wordPair,
//   });

//   final WordPair wordPair;

//   @override
//   _FavoriteIconButtonState createState() =>
//       _FavoriteIconButtonState(wordPair: wordPair);
// }

// class _FavoriteIconButtonState extends State<FavoriteIconButton> {
//   bool _isPressed = true;

//   _FavoriteIconButtonState({
//     required this.wordPair,
//   });

//   final WordPair wordPair;

//   void _togglePressed() {
//     var appState = Provider.of<MyAppState>(context, listen: false);
//     setState(() {
//       _isPressed = !_isPressed;
//     });
//     if (_isPressed) {
//       // If got changed to be a favorite
//       appState.favorites.add(wordPair);
//     } else {
//       // If got changed to not a favorite
//       appState.favorites.remove(wordPair);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();

//     return IconButton(
//       icon: _isPressed ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
//       onPressed: _togglePressed,
//     );
//   }
// }

class ExerciseCard extends StatelessWidget {
  const ExerciseCard(
      {super.key,
      required this.description,
      required this.musclesWorked,
      required this.expectedWaitTime});

  final String description;
  final String musclesWorked;
  final String expectedWaitTime;

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
