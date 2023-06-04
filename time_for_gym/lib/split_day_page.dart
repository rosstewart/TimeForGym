import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/split.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class SplitDayPage extends StatelessWidget {
  int dayIndex;
  List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  SplitDayPage(this.dayIndex);

  void cancelChanges(var appState) {
    appState.toSplitDayEditMode(false);
  }

  void saveChanges(var appState) {
    appState.saveEditChanges();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    Split split;
    List<List<int>> exerciseIndices;

    if (!appState.splitDayEditMode) {
      split = appState.currentSplit;
      exerciseIndices = appState.splitDayExerciseIndices;
      // print("not edit mode current split $exerciseIndices");
    } else {
      split = appState.editModeTempSplit;
      exerciseIndices = appState.editModeTempExerciseIndices;
      // print("edit mode temp split $exerciseIndices");
    }

    List<TrainingDay> trainingDays = split.trainingDays;

    // var exercises = appState.muscleGroups[appState.currentMuscleGroup];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return ListView(
      children: [
        Back(appState: appState, index: 6),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "${daysOfWeek[dayIndex]} - ${trainingDays[dayIndex].splitDay}",
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
            ),
            if (!appState.splitDayEditMode)
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toSplitDayEditMode(true);
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Edit Split")),
            SizedBox(
              height: 20,
            ),
            if (appState.splitDayEditMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            cancelChanges(appState);
                          },
                          icon: Icon(Icons.cancel),
                          label: Text("Cancel")),
                      Spacer(),
                      ElevatedButton.icon(
                          onPressed: () {
                            saveChanges(appState);
                          },
                          icon: Icon(Icons.save_alt),
                          label: Text("Save"))
                    ]),
              ),

            if (split.trainingDays[dayIndex] != null)
              for (int i = 0;
                  i < split.trainingDays[dayIndex].muscleGroups.length;
                  i++)
                SplitMuscleGroupCard(
                  muscleGroup: split.trainingDays[dayIndex].muscleGroups[i],
                  splitDayCardIndex: i,
                  split: split,
                  exerciseIndices: exerciseIndices,
                ),
            if (appState.splitDayEditMode) SizedBox(height: 15),
            if (appState.splitDayEditMode)
              AddButton(
                  appState: appState,
                  dayIndex: dayIndex,
                  cardIndex: split.trainingDays[dayIndex].muscleGroups
                      .length), // Add to end
            // BigButton(text: muscleGroupName, index: 0),4
          ],
        ),
        // ),
      ],
    );
  }
}

class AddButton extends StatefulWidget {
  const AddButton({
    super.key,
    required this.appState,
    required this.dayIndex,
    required this.cardIndex,
  });

  final MyAppState appState;
  final int dayIndex;
  final int cardIndex;

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  // String _selectedItem = '';
  List<String> muscleGroups = [];
  List<String> exerciseNames = [];

  void findMuscleGroupOrExercise(MyAppState appState, String name, List<Exercise> allExercises) {
    if (muscleGroups.contains(name)) {
      // Muscle Group - Add first exercise in muscle group
      appState.addTempMuscleGroupToSplit(widget.dayIndex, widget.cardIndex, name, 0);
    } else {
      // Exercise - Find exercise index of the main muscle group
      int index = exerciseNames.indexOf(name);
      if (index == -1){
        // Invalid search query
        print("Invalid search query");
        return;
      }

      String mainMuscleGroupName = allExercises[index].mainMuscleGroup;
      List<Exercise>? exercises = appState.muscleGroups[mainMuscleGroupName];
      if (exercises == null){
        print("ERROR - null search");
        return;
      } else{
        appState.addTempMuscleGroupToSplit(widget.dayIndex, widget.cardIndex, mainMuscleGroupName, exercises.indexWhere((element) => element.name == name));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () {
          showDropdownMenu(context);
          // widget.appState.addTempMuscleGroupToSplit(widget.dayIndex, widget.cardIndex, "Chest");
        },
        icon: Icon(Icons.add_box),
        label: Text("Add Exercise"));
  }

  void showDropdownMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    muscleGroups = widget.appState.muscleGroups.keys.toList();

    List<List<Exercise>> exercisesByMuscleGroup =
        widget.appState.muscleGroups.values.toList();
    List<Exercise> allExercises =
        exercisesByMuscleGroup.expand((innerList) => innerList).toList();
    exerciseNames = allExercises.map((exercise) => exercise.name).toList();

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'Search Muscle Groups',
          child: ListTile(
            leading: Icon(Icons.search),
            title: Text('Search Muscle Groups'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Search All Exercises',
          child: ListTile(
            leading: Icon(Icons.search),
            title: Text('Search All Exercises'),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Search Muscle Groups') {
        performSearchAction(muscleGroups, allExercises);
      } else if (value == 'Search All Exercises') {
        performSearchAction(exerciseNames, allExercises);
      }
    });
  }

  void performSearchAction(List<String> list, List<Exercise> allExercises) {
    TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Muscle Group or Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return list.where((item) =>
                      item.toLowerCase().contains(pattern.toLowerCase()));
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    searchQuery = suggestion;
                    searchController.text = suggestion; // Update the text field
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    findMuscleGroupOrExercise(widget.appState, searchQuery, allExercises);
                    // _selectedItem = searchQuery;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Add'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class SplitMuscleGroupCard extends StatefulWidget {
  SplitMuscleGroupCard({
    super.key,
    required this.muscleGroup,
    required this.splitDayCardIndex,
    required this.split,
    required this.exerciseIndices,
  });

  final String muscleGroup;
  final int splitDayCardIndex;
  final Split split;
  final List<List<int>> exerciseIndices;
  int exerciseIndex = 0;

  @override
  State<SplitMuscleGroupCard> createState() => _SplitMuscleGroupCardState();
}

class _SplitMuscleGroupCardState extends State<SplitMuscleGroupCard> {
  String _selectedItem = '';
  List<String> _items = ['Option 1', 'Option 2', 'Option 3'];
  List<String> _searchItems = [
    'Search Option 1',
    'Search Option 2',
    'Search Option 3'
  ];

  void changeExercise(var appState, bool next) {
    widget.exerciseIndex = widget.exerciseIndices[appState.currentDayIndex]
        [widget.splitDayCardIndex];
    if (next) {
      if (widget.exerciseIndex >=
          appState.muscleGroups[widget.muscleGroup].length - 1) {
        // if will be out of bounds
        return;
      }
      setState(() {
        widget.exerciseIndex++;
      });
    } else {
      // previous
      if (widget.exerciseIndex == 0) {
        // if will be out of bounds
        return;
      }
      setState(() {
        widget.exerciseIndex--;
      });
    }

    // print("before next");
    // print("local split ${widget.exerciseIndices.hashCode}");
    // print("current split ${appState.splitDayExerciseIndices.hashCode}");
    // print("temp split ${appState.editModeTempExerciseIndices.hashCode}");

    // Set the "default" exercise to view in that muscle group of the split
    widget.exerciseIndices[appState.currentDayIndex][widget.splitDayCardIndex] =
        widget.exerciseIndex;

    // print("after next");
    // print("local split ${widget.exerciseIndices}");
    // print("current split ${appState.splitDayExerciseIndices}");
    // print("temp split ${appState.editModeTempExerciseIndices}");

    // appState.saveSplitDayExerciseIndicesData();
  }

  void toExercise(var appState, Exercise exercise) {
    print(widget.exerciseIndices[appState.currentDayIndex]
        [widget.splitDayCardIndex]);
    print(appState.muscleGroups[widget.muscleGroup]![widget
        .exerciseIndices[appState.currentDayIndex][widget.splitDayCardIndex]]);
    appState.changePageToExercise(exercise);
  }

  // void cancelChanges(var appState) {
  //   appState.toSplitDayEditMode(false);
  // }

  // void saveChanges() {

  // }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.secondary,
    );

    // If exercise isn't in exercise indices
    if (widget.splitDayCardIndex >=
        widget.exerciseIndices[appState.currentDayIndex].length) {
      widget.exerciseIndices[appState.currentDayIndex].add(0);
    }

    // Reset exercise index if out of bounds
    if (widget.exerciseIndices[appState.currentDayIndex]
            [widget.splitDayCardIndex] >=
        appState.muscleGroups[widget.muscleGroup]!.length) {
      widget.exerciseIndices[appState.currentDayIndex]
          [widget.splitDayCardIndex] = 0;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
      child: Column(
        children: [
          // if (appState.splitDayEditMode)
          //   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          //     ElevatedButton.icon(
          //         onPressed: () {cancelChanges(appState);},
          //         icon: Icon(Icons.cancel),
          //         label: Text("Cancel")),
          //     Spacer(),
          //     ElevatedButton.icon(
          //         onPressed: saveChanges,
          //         icon: Icon(Icons.save_alt),
          //         label: Text("Save"))
          //   ]),
          if (appState.splitDayEditMode)
            AddButton(
                appState: appState,
                dayIndex: appState.currentDayIndex,
                cardIndex: widget.splitDayCardIndex),
          // ElevatedButton.icon(
          //     onPressed: () {
          //       appState.addTempMuscleGroupToSplit(appState.currentDayIndex,
          //           widget.splitDayCardIndex, "Chest");
          //     },
          //     icon: Icon(Icons.add_box),
          //     label: Text("Add Muscle Group")),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (appState.splitDayEditMode)
                IconButton(
                    onPressed: () {
                      changeExercise(appState, false);
                    },
                    icon: Icon(Icons.navigate_before)),
              Expanded(
                child: Card(
                  color: theme.colorScheme.surface,
                  elevation: 10, // Shadow
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Column(
                      children: [
                        Text(widget.muscleGroup,
                            style: headingStyle, textAlign: TextAlign.center),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                            // exercise index
                            appState
                                .muscleGroups[widget.muscleGroup]![
                                    widget.exerciseIndices[
                                            appState.currentDayIndex]
                                        [widget.splitDayCardIndex]]
                                .name,
                            style: textStyle,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Empty Expanded widgets to create spacing
                            // Expanded(
                            //     child:
                            //         Container()), // Adjust the flex factor as needed
                            // Expanded(
                            //     child:
                            //         Container()), // Adjust the flex factor as needed
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  toExercise(
                                      appState,
                                      appState.muscleGroups[widget
                                          .muscleGroup]![widget.exerciseIndices[
                                              appState.currentDayIndex]
                                          [widget.splitDayCardIndex]]);
                                },
                                child: Text("View Exercise"),
                              ),
                            ),
                            if (appState.splitDayEditMode)
                              Expanded(child: Container()),
                            if (appState.splitDayEditMode)
                              IconButton(
                                  onPressed: () {
                                    appState.removeTempMuscleGroupFromSplit(
                                        appState.currentDayIndex,
                                        widget.splitDayCardIndex);
                                  },
                                  icon: Icon(Icons.delete_forever)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (appState.splitDayEditMode)
                IconButton(
                    onPressed: () {
                      changeExercise(appState, true);
                    },
                    icon: Icon(Icons.navigate_next)),
            ],
          ),
        ],
      ),
    );
  }
}
