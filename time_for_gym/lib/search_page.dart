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

    muscleGroups = appState.muscleGroups.keys.toList();

    List<List<Exercise>> exercisesByMuscleGroup =
        appState.muscleGroups.values.toList();
    List<Exercise> allExercises =
        exercisesByMuscleGroup.expand((innerList) => innerList).toList();
    exerciseNames = allExercises.map((exercise) => exercise.name).toList();

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
                      color: theme.colorScheme.onBackground),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                    child: TypeAheadField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: searchController,
                        focusNode: focusNode,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            openSuggestions();
                          }
                        },
                        decoration: InputDecoration(
                          icon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear(); // Clear the text field
                              searchQuery =
                                  ''; // Clear user input if they click search right away
                            },
                          ),
                          labelText: 'Search for an Exercise',
                          labelStyle: TextStyle(color: appState.onBackground),
                        ),
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
                    },
                    child: Text("Cancel", style: suggestionStyle)),
            ],
          ),
        ),
        // title: Text("Browse exercises", style: titleStyle,),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text("View Muscle Groups", style: theme.textTheme.titleLarge!.copyWith(color: theme.colorScheme.onBackground), textAlign: TextAlign.left,),
            ),
            ScrollableButtonRow(
              names: appState.muscleGroups.keys.toList(),
            ),
            PageSelectorButton(text: "Exercise Library", index: 8),
            PageSelectorButton(text: "Exercises by Muscle Group", index: 1),
            PageSelectorButton(text: "Favorite Exercises", index: 2),
            PageSelectorButton(text: "Gym Occupancy", index: 3),
          ],
        ),
      ),
    );
  }
}

class SquareButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;

  SquareButton({required this.name, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
            child: MuscleGroupImageContainer(muscleGroup: name),
            // child: ,
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onBackground),
          ),
        ],
      ),
    );
  }
}

class ScrollableButtonRow extends StatelessWidget {
  final List<String> names;

  ScrollableButtonRow({required this.names});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 10), // Buffer space before the first button
          ...List.generate(
            names.length,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SquareButton(
                name: names[index],
                onPressed: () {
                  // Handle button press
                  appState.changePageToMuscleGroup(names[index]);
                },
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }
}
