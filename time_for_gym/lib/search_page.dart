import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/main.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // bool isFocused = false;

  late TextEditingController searchController;
  late FocusNode focusNode;
  bool isSuggestionsOpen = false;
  String searchQuery = '';

  List<String> muscleGroups = [];
  List<String> exerciseNames = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          isSuggestionsOpen = false;
        });
      }
    });
    //   widget.focusNode.addListener(() {
    // setState(() {
    //   isFocused = widget.focusNode.hasFocus;
    // });
// });
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void openSuggestions() {
    if (!isSuggestionsOpen) {
      setState(() {
        isSuggestionsOpen = true;
      });
    }
  }

  void closeSuggestions() {
    if (isSuggestionsOpen) {
      setState(() {
        isSuggestionsOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    final theme = Theme.of(context);
    final suggestionStyle = theme.textTheme.bodyLarge!
        .copyWith(color: theme.colorScheme.onBackground);
    final suggestionMuscleGroupStyle =
        theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.primary);
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

    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    return GestureDetector(
      onTap: () {
        closeSuggestions();
        // if (!isSuggestionsOpen) {
        FocusScope.of(context).requestFocus(FocusNode());
        // }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.background,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  // width: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: theme.colorScheme.primaryContainer),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                    child: TypeAheadField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        style: TextStyle(color: theme.colorScheme.onBackground),
                        controller: searchController,
                        focusNode: focusNode,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            openSuggestions();
                          }
                        },
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.search,
                              color: theme.colorScheme.primary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65),
                              ),
                              onPressed: () {
                                searchController
                                    .clear(); // Clear the text field
                                searchQuery =
                                    ''; // Clear user input if they click search right away
                              },
                            ),
                            labelText: 'Search for an Exercise',
                            labelStyle: TextStyle(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65)),
                            floatingLabelStyle: TextStyle(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65))),
                      ),
                      suggestionsCallback: (pattern) {
                        // setState(() {
                        //   isSuggestionsOpen = pattern.isNotEmpty;
                        // });
                        if (pattern.isEmpty) {
                          return List<String>.empty();
                        } else {
                          return exerciseNames.where((item) => item
                              .toLowerCase()
                              .contains(pattern.toLowerCase()));
                        }
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          tileColor: theme.colorScheme.primaryContainer,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  suggestion,
                                  textAlign: TextAlign.left,
                                  style: suggestionStyle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  allExercises[
                                          exerciseNames.indexOf(suggestion)]
                                      .mainMuscleGroup,
                                  textAlign: TextAlign.right,
                                  style: suggestionMuscleGroupStyle,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        setState(() {
                          searchQuery = suggestion;
                          searchController.text =
                              suggestion; // Update the text field
                        });
                        appState.changePageToExercise(
                            allExercises[exerciseNames.indexOf(suggestion)]);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              if (isSuggestionsOpen)
                TextButton(
                    onPressed: () {
                      closeSuggestions();
                      FocusScope.of(context).requestFocus(FocusNode());
                      // widget.focusNode.unfocus();
                    },
                    child: Text("Cancel", style: suggestionStyle)),
            ],
          ),
        ),
        // title: Text("Browse exercises", style: titleStyle,),
        body: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
              child: Text(
                "Favorite Exercises",
                style: titleStyle,
                textAlign: TextAlign.left,
              ),
            ),
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
  final VoidCallback onPressed;
  Widget image = Placeholder();

  SquareButton(
      {required this.name, required this.isExercise, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (!isExercise) {
      image = MuscleGroupImageContainer(muscleGroup: name);
    } else {
      image = ImageContainer(exerciseName: name);
    }
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
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
            width: 120,
            child: Text(
              name,
              style: isExercise
                  ? Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground)
                  : Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),
              textAlign: TextAlign.center,
            ),
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
