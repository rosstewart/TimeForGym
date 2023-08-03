import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/main.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> muscleGroups = [];
  List<String> exerciseNames = [];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    final theme = Theme.of(context);
    // final suggestionStyle = theme.textTheme.bodyLarge!
    final titleStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);

    muscleGroups = appState.muscleGroups.keys.toList();

    List<List<Exercise>> exercisesByMuscleGroup =
        appState.muscleGroups.values.toList();
    List<Exercise> allExercises =
        exercisesByMuscleGroup.expand((innerList) => innerList).toList();
    exerciseNames = allExercises.map((exercise) => exercise.name).toList();

    List<String> upperBodyMuscleGroups = [...muscleGroups];
    upperBodyMuscleGroups.removeRange(7, 11);
    List<String> lowerBodyMuscleGroups = muscleGroups.getRange(7, 11).toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.background,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SizedBox(width: 5),
              Expanded(
                child: Container(
                  // width: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.onBackground),
                  child: ListTile(
                    leading: Icon(
                      Icons.search,
                      color: theme.colorScheme.background,
                    ),
                    title: Text(
                      'Search for an exercise',
                      style: TextStyle(
                          color: theme.colorScheme.background, fontSize: 16),
                    ),
                    onTap: () {
                      appState.changePage(10);
                    },
                    // child: TypeAheadField<String>(
                    //   textFieldConfiguration: TextFieldConfiguration(
                    //     style: TextStyle(color: theme.colorScheme.onBackground),
                    //     controller: searchController,
                    //     focusNode: focusNode,
                    //     onChanged: (value) {
                    //       if (value.isNotEmpty) {
                    //         openSuggestions();
                    //       }
                    //     },
                    //     decoration: InputDecoration(
                    //         border: InputBorder.none,
                    //         icon: Icon(
                    //           Icons.search,
                    //           color: theme.colorScheme.primary,
                    //         ),
                    //         suffixIcon: IconButton(
                    //           icon: Icon(
                    //             Icons.clear,
                    //             color: theme.colorScheme.onBackground
                    //                 .withOpacity(0.65),
                    //           ),
                    //           onPressed: () {
                    //             searchController
                    //                 .clear(); // Clear the text field
                    //             searchQuery =
                    //                 ''; // Clear user input if they click search right away
                    //           },
                    //         ),
                    //         labelText: 'Search for an Exercise',
                    //         labelStyle: TextStyle(
                    //             color: theme.colorScheme.onBackground
                    //                 .withOpacity(0.65)),
                    //         floatingLabelStyle: TextStyle(
                    //             color: theme.colorScheme.onBackground
                    //                 .withOpacity(0.65))),
                    //   ),
                    //   suggestionsCallback: (pattern) {
                    //     // setState(() {
                    //     //   isSuggestionsOpen = pattern.isNotEmpty;
                    //     // });
                    //     if (pattern.isEmpty) {
                    //       return List<String>.empty();
                    //     } else {
                    //       return exerciseNames.where((item) => item
                    //           .toLowerCase()
                    //           .contains(pattern.toLowerCase()));
                    //     }
                    //   },
                    //   itemBuilder: (context, suggestion) {
                    //     Exercise exercise =
                    //         allExercises[exerciseNames.indexOf(suggestion)];
                    //     return ListTile(
                    //       tileColor: theme.colorScheme.primaryContainer,
                    //       leading: SizedBox(
                    //         width: 40,
                    //         height: 40,
                    //         child: ImageContainer(exerciseName: exercise.name),
                    //       ),
                    //       title: Text(suggestion, style: suggestionStyle),
                    //       subtitle: Text(
                    //         exercise.mainMuscleGroup,
                    //         style: suggestionMuscleGroupStyle,
                    //       ),
                    //     );
                    //   },
                    //   onSuggestionSelected: (suggestion) {
                    //     setState(() {
                    //       searchQuery = suggestion;
                    //       searchController.text =
                    //           suggestion; // Update the text field
                    //     });
                    //     appState.changePageToExercise(
                    //         allExercises[exerciseNames.indexOf(suggestion)]);
                    //   },
                    // ),
                  ),
                ),
              ),
              // SizedBox(width: 5),
              // if (isSuggestionsOpen)
              //   TextButton(
              //       onPressed: () {
              //         closeSuggestions();
              //         FocusScope.of(context).requestFocus(FocusNode());
              //         // widget.focusNode.unfocus();
              //       },
              //       child: Text("Cancel", style: suggestionStyle)),
            ],
          ),
        ),
        // title: Text("Browse exercises", style: titleStyle,),
        body: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
              child: Text(
                "Upper Body Muscle Groups",
                style: titleStyle,
                textAlign: TextAlign.left,
              ),
            ),
            ScrollableButtonRow(
              names: upperBodyMuscleGroups,
              isExercise: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
              child: Text(
                "Lower Body Muscle Groups",
                style: titleStyle,
                textAlign: TextAlign.left,
              ),
            ),
            ScrollableButtonRow(
              names: lowerBodyMuscleGroups,
              isExercise: false,
            ),
            // if (appState.favoriteExercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
              child: Text(
                "Favorite Exercises",
                style: titleStyle,
                textAlign: TextAlign.left,
              ),
            ),
            if (appState.favoriteExercises.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: Text(
                  "No favorite exercises",
                  style: theme.textTheme.labelSmall!.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(.65)),
                  textAlign: TextAlign.left,
                ),
              ),
            if (appState.favoriteExercises.isNotEmpty)
              ScrollableButtonRow(
                names: appState.favoriteExercises
                    .map((exercise) => exercise.name)
                    .toList(),
                isExercise: true,
              ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SquareButton extends StatelessWidget {
  final String name;
  final bool isExercise;
  final Exercise? exercise;
  final VoidCallback onPressed;
  Widget image = Placeholder();

  SquareButton(
      {required this.name,
      required this.isExercise,
      required this.onPressed,
      required this.exercise});

  @override
  Widget build(BuildContext context) {
    if (!isExercise) {
      image = MuscleGroupImageContainer(muscleGroup: name);
    } else {
      image = ImageContainer(exercise: exercise!);
    }
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            // child: Image.asset('muscle_group_pictures/$name.jpeg', fit: BoxFit.cover,),
            child: image,
            // child: ,
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(name,
                style: isExercise
                    ? Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 10)
                    : Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ),
        ],
      ),
    );
  }
}

class ScrollableButtonRow extends StatelessWidget {
  final List<String> names;
  final bool isExercise;

  ScrollableButtonRow({required this.names, required this.isExercise});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 10), // Buffer space before the first button
          ...List.generate(
            names.length,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SquareButton(
                name: names[index],
                isExercise: isExercise,
                exercise: isExercise ? appState.favoriteExercises[index] : null,
                onPressed: () {
                  // Handle button press
                  if (!isExercise) {
                    // Muscle group
                    appState.changePageToMuscleGroup(names[index]);
                  } else {
                    // Favorite Exercise
                    appState.changePageToExercise(
                        appState.favoriteExercises[index]);
                  }
                },
              ),
            ),
          ).toList(),
          SizedBox(width: 10), // Buffer
        ],
      ),
    );
  }
}
