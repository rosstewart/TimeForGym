// import 'dart:ffi';

// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/split.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

// ignore: must_be_immutable
class SplitDayPage extends StatefulWidget {
  int dayIndex;
  // int scrollingHeight = 532;

  SplitDayPage(this.dayIndex);

  @override
  State<SplitDayPage> createState() => _SplitDayPageState();
}

class _SplitDayPageState extends State<SplitDayPage> {
  final _titleFormKey = GlobalKey<FormState>();

  List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  void cancelEditChanges(var appState) {
    appState.toSplitDayEditMode(false);
  }

  void saveEditChanges(var appState) {
    appState.saveEditChanges();
  }

  void cancelReorderChanges(var appState) {
    appState.toSplitDayReorderMode(false);
  }

  void saveReorderChanges(var appState) {
    appState.saveReorderChanges();
  }

  // int getNewCardIndex(Split split, List<SplitMuscleGroupCard> muscleGroupCards,
  //     int dayIndex, int cardIndex) {
  //   final reorderedIndices =
  //       getReorderedIndices(split, muscleGroupCards, dayIndex);
  //   return reorderedIndices.indexOf(cardIndex);
  // }

  // List<int> getReorderedIndices(
  //     Split split, List<SplitMuscleGroupCard> muscleGroupCards, int dayIndex) {
  //   final muscleGroupCount = split.trainingDays[dayIndex].muscleGroups.length;
  //   final reorderedIndices = List.generate(muscleGroupCount, (index) => index);

  //   for (int i = 0; i < muscleGroupCards.length; i++) {
  //     final cardIndex = muscleGroupCards[i].splitDayCardIndex;
  //     final newIndex = reorderedIndices.indexOf(cardIndex);
  //     reorderedIndices.removeAt(newIndex);
  //     reorderedIndices.insert(i, cardIndex);
  //   }

  //   return reorderedIndices;
  // }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    Split split;
    List<List<int>> exerciseIndices;

    if (widget.dayIndex == -1) {
      return Placeholder();
    }

    if (!appState.splitDayEditMode && !appState.splitDayReorderMode) {
      split = appState.currentSplit;
      exerciseIndices = appState.splitDayExerciseIndices;
      // print("not edit mode current split $exerciseIndices");
    } else {
      split = appState.editModeTempSplit;
      exerciseIndices = appState.editModeTempExerciseIndices;
      // print("edit mode temp split $exerciseIndices");
    }

    List<TrainingDay> trainingDays = split.trainingDays;

    // Draggable cards for reorder mode
    List<Widget> muscleGroupCards = List.generate(
      split.trainingDays[widget.dayIndex].muscleGroups.length,
      (i) => SplitMuscleGroupCard(
        key: ValueKey(i), // Assign a unique key to each SplitMuscleGroupCard
        muscleGroup: split.trainingDays[widget.dayIndex].muscleGroups[i],
        splitDayCardIndex: i,
        split: split,
        exerciseIndices: exerciseIndices,
        isDraggable: true,
      ),
    );

    // var exercises = appState.muscleGroups[appState.currentMuscleGroup];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    // bool scrollBarThumbVisibility = appState.splitDayEditMode;

    return SwipeBack(
      appState: appState,
      index: 6,
      child: Scaffold(
        appBar: AppBar(
          leading: Back(appState: appState, index: 6),
          leadingWidth: 70,
          title: Text(
            daysOfWeek[widget.dayIndex],
            style: titleStyle,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: OuterScroll(
          scrollMode: appState.splitDayReorderMode,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                if (!appState.splitDayEditMode)
                  Text(
                    trainingDays[widget.dayIndex].splitDay,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                if (appState.splitDayEditMode)
                  Form(
                    key: _titleFormKey,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 250,
                      ),
                      child: TextFormField(
                        initialValue: trainingDays[widget.dayIndex].splitDay,
                        style: titleStyle,
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a value';
                          }
                          return null; // Return null to indicate the input is valid
                        },
                        onChanged: (value) {
                          setState(() {
                            trainingDays[widget.dayIndex].splitDay = value;
                          });
                        },
                      ),
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                if (!appState.splitDayEditMode && !appState.splitDayReorderMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor: resolveColor(
                                  theme.colorScheme.primaryContainer),
                              surfaceTintColor: resolveColor(
                                  theme.colorScheme.primaryContainer)),
                          onPressed: () {
                            appState.toSplitDayEditMode(true);
                          },
                          icon: Icon(Icons.edit,
                              color: theme.colorScheme.primary),
                          label: Text(
                            "Edit Day",
                            style: TextStyle(
                                color: theme.colorScheme.onBackground),
                          )),
                      if (muscleGroupCards.length >
                          1) // If 0 or 1 muscle groups, no option to reorder
                        ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor: resolveColor(
                                    theme.colorScheme.primaryContainer),
                                surfaceTintColor: resolveColor(
                                    theme.colorScheme.primaryContainer)),
                            onPressed: () {
                              appState.toSplitDayReorderMode(true);
                            },
                            icon: Icon(Icons.reorder,
                                color: theme.colorScheme.primary),
                            label: Text(
                              "Reorder Muscle Groups",
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground),
                            )),
                    ],
                  ),
                if (appState.splitDayEditMode || appState.splitDayReorderMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: resolveColor(
                                      theme.colorScheme.primaryContainer),
                                  surfaceTintColor: resolveColor(
                                      theme.colorScheme.primaryContainer)),
                              onPressed: () {
                                if (appState.splitDayEditMode) {
                                  cancelEditChanges(appState);
                                } else {
                                  cancelReorderChanges(appState);
                                }
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: theme.colorScheme.primary,
                              ),
                              label: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground,
                                ),
                              )),
                          Spacer(),
                          ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: resolveColor(
                                      theme.colorScheme.primaryContainer),
                                  surfaceTintColor: resolveColor(
                                      theme.colorScheme.primaryContainer)),
                              onPressed: () {
                                if (appState.splitDayEditMode) {
                                  // Can only edit title in edit mode, not reorder mode
                                  if (_titleFormKey.currentState!.validate()) {
                                    saveEditChanges(appState);
                                  }
                                } else {
                                  saveReorderChanges(appState);
                                }
                              },
                              icon: Icon(
                                Icons.save_alt,
                                color: theme.colorScheme.primary,
                              ),
                              label: Text(
                                "Save",
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground,
                                ),
                              ))
                        ]),
                  ),

                // ignore: unnecessary_null_comparison
                if (split.trainingDays[widget.dayIndex] != null)
                  if (appState
                      .splitDayReorderMode) // Drag and drop muscle group cards
                    Column(
                      children: [
                        SizedBox(height: 20),
                        SizedBox(
                          height: 599,
                          child: ReorderableListView(
                            children: muscleGroupCards,
                            onReorder: (oldIndex, newIndex) {
                              print(
                                  "Muscle groups before reorder: ${split.trainingDays[widget.dayIndex].muscleGroups}");
                              print(
                                  "Exercise indices before reorder: ${exerciseIndices[widget.dayIndex]}");
                              print(
                                  "Number of sets after reorder: ${split.trainingDays[widget.dayIndex].setsPerMuscleGroup}");
                              try {
                                setState(() {
                                  // if (newIndex >= muscleGroupCards.length ||
                                  //     newIndex < 0) {
                                  //   // Avoid out of bounds error
                                  //   return;
                                  // }
                                  if (newIndex > oldIndex) {
                                    newIndex -=
                                        1; // Adjust the index when moving an item down
                                  }
                                  final card =
                                      muscleGroupCards.removeAt(oldIndex);
                                  final List<dynamic>
                                      muscleGroupAndExerciseIndexAndNumSets =
                                      appState.removeTempMuscleGroupFromSplit(
                                          widget.dayIndex, oldIndex);
                                  muscleGroupCards.insert(newIndex, card);
                                  appState.addTempMuscleGroupToSplit(
                                      widget.dayIndex,
                                      newIndex,
                                      muscleGroupAndExerciseIndexAndNumSets[0],
                                      muscleGroupAndExerciseIndexAndNumSets[1],
                                      muscleGroupAndExerciseIndexAndNumSets[2]);

                                  print(
                                      "Muscle groups after reorder: ${split.trainingDays[widget.dayIndex].muscleGroups}");
                                  print(
                                      "Exercise indices after reorder: ${exerciseIndices[widget.dayIndex]}");
                                  print(
                                      "Number of sets after reorder: ${split.trainingDays[widget.dayIndex].setsPerMuscleGroup}");
                                });
                              } catch (e) {
                                print("Drag and drop error - $e");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                if (!appState.splitDayReorderMode)
                  for (int i = 0;
                      i <
                          split.trainingDays[widget.dayIndex].muscleGroups
                              .length;
                      i++)
                    SplitMuscleGroupCard(
                      muscleGroup:
                          split.trainingDays[widget.dayIndex].muscleGroups[i],
                      splitDayCardIndex: i,
                      split: split,
                      exerciseIndices: exerciseIndices,
                      isDraggable: false,
                    ),
                if (appState.splitDayEditMode) SizedBox(height: 15),
                if (appState.splitDayEditMode)
                  AddButton(
                      appState: appState,
                      dayIndex: widget.dayIndex,
                      cardIndex: split.trainingDays[widget.dayIndex]
                          .muscleGroups.length), // Add to end
                // BigButton(text: muscleGroupName, index: 0),4
              ],
            ),
            // ),
          ],
        ),
      ),
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

  void findMuscleGroupOrExercise(
      MyAppState appState, String name, List<Exercise> allExercises) {
    if (muscleGroups.contains(name)) {
      // Muscle Group - Add first exercise in muscle group
      // 3 sets default
      appState.addTempMuscleGroupToSplit(
          widget.dayIndex, widget.cardIndex, name, 0, 3);
    } else {
      // Exercise - Find exercise index of the main muscle group
      int index = exerciseNames.indexOf(name);
      if (index == -1) {
        // Invalid search query
        print("Invalid search query");
        return;
      }

      String mainMuscleGroupName = allExercises[index].mainMuscleGroup;
      List<Exercise>? exercises = appState.muscleGroups[mainMuscleGroupName];
      if (exercises == null) {
        print("ERROR - null search");
        return;
      } else {
        // 3 sets default
        appState.addTempMuscleGroupToSplit(
            widget.dayIndex,
            widget.cardIndex,
            mainMuscleGroupName,
            exercises.indexWhere((element) => element.name == name),
            3);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ElevatedButton.icon(
        style: ButtonStyle(
            backgroundColor: resolveColor(theme.colorScheme.primaryContainer),
            surfaceTintColor: resolveColor(theme.colorScheme.primaryContainer)),
        onPressed: () {
          showDropdownMenu(context);
          // widget.appState.addTempMuscleGroupToSplit(widget.dayIndex, widget.cardIndex, "Chest");
        },
        icon: Icon(
          Icons.add_box,
          color: theme.colorScheme.primary,
        ),
        label: Text(
          "Add Exercise",
          style: TextStyle(color: theme.colorScheme.onBackground),
        ));
  }

  void showDropdownMenu(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // var appState = context.watch<MyAppState>();
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
      color: theme.colorScheme.primaryContainer,
      surfaceTintColor: theme.colorScheme.primaryContainer,
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'Search Muscle Groups',
          child: ListTile(
            leading: Icon(Icons.search, color: theme.colorScheme.primary),
            title: Text('Search Muscle Groups',
                style: TextStyle(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Search All Exercises',
          child: ListTile(
            leading: Icon(Icons.search, color: theme.colorScheme.primary),
            title: Text('Search All Exercises',
                style: TextStyle(color: theme.colorScheme.onBackground)),
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

    final ThemeData theme = Theme.of(context);
    final TextStyle whiteTextStyle = TextStyle(
      color: theme.colorScheme.onBackground,
    );
    final TextStyle textStyle = TextStyle(
      color: theme.colorScheme.primary,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.background,
          surfaceTintColor: theme.colorScheme.background,
          title: Text(
            'Add Muscle Group or Exercise',
            style: whiteTextStyle,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  style: whiteTextStyle,
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    labelStyle: whiteTextStyle,
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return list.where((item) =>
                      item.toLowerCase().contains(pattern.toLowerCase()));
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(
                      suggestion,
                      style: whiteTextStyle,
                    ),
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
                style: ButtonStyle(
                    backgroundColor:
                        resolveColor(theme.colorScheme.primaryContainer),
                    surfaceTintColor:
                        resolveColor(theme.colorScheme.primaryContainer)),
                onPressed: () {
                  setState(() {
                    findMuscleGroupOrExercise(
                        widget.appState, searchQuery, allExercises);
                    // _selectedItem = searchQuery;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Add',
                  style: textStyle,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      resolveColor(theme.colorScheme.primaryContainer),
                  surfaceTintColor:
                      resolveColor(theme.colorScheme.primaryContainer)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: textStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ignore: must_be_immutable
class SplitMuscleGroupCard extends StatefulWidget {
  SplitMuscleGroupCard({
    super.key,
    required this.muscleGroup,
    required this.splitDayCardIndex,
    required this.split,
    required this.exerciseIndices,
    required this.isDraggable,
  });

  final String muscleGroup;
  final int splitDayCardIndex;
  final Split split;
  final List<List<int>> exerciseIndices;
  final bool isDraggable;
  int exerciseIndex = 0;

  @override
  State<SplitMuscleGroupCard> createState() => _SplitMuscleGroupCardState();
}

class _SplitMuscleGroupCardState extends State<SplitMuscleGroupCard> {
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  bool showPreviousReps = false;
  bool showPreviousWeight = false;

  String previousWeight = "";
  String previousReps = "";

  final _trackTopSetFormKey = GlobalKey<FormState>();

  // bool _isWeightFieldEmpty = true;
  // bool _isRepsFieldEmpty = true;

  Widget? weightSuffixIcon;
  Widget? repsSuffixIcon;

  bool hasSavedTopSet = false;

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

  void toExercise(MyAppState appState, Exercise exercise) {
    // print(widget.exerciseIndices[appState.currentDayIndex]
    //     [widget.splitDayCardIndex]);
    // print(appState.muscleGroups[widget.muscleGroup]![widget
    //     .exerciseIndices[appState.currentDayIndex][widget.splitDayCardIndex]]);
    appState.currentExerciseFromSplitDayPage = exercise;
    appState.changePageToExercise(exercise);
  }

  String? validateWeightInput(String? value) {
    if (value == null || value.isEmpty) {
      return '*';
    }
    if (double.tryParse(value) == null) {
      return '*';
    }
    if (double.parse(value) < 1) {
      return '*';
    }
    return null;
  }

  String? validateRepsInput(String? value) {
    if (value == null || value.isEmpty) {
      return '*';
    }
    if (double.tryParse(value) == null) {
      return '*';
    }
    if (double.parse(value) < 1) {
      return '*';
    }
    return null;
  }

  void saveTopSet(MyAppState appState, Exercise currentExercise) {
    String weight = weightController.text;
    String reps = repsController.text;
    bool isValidated = true;

    //TODO - Add kilo i/o functionality

    // if (_trackTopSetFormKey.currentState!.validate()) {
    //   _trackTopSetFormKey.currentState!.save();
    // } else {
    //   isValidated = false;
    // }

    if (weightController.text.isNotEmpty &&
        weightController.text != '0' &&
        repsController.text.isNotEmpty &&
        repsController.text != '0') {
      setState(() {
        weightSuffixIcon = null;
        repsSuffixIcon = null;
        hasSavedTopSet = true;
      });
      _trackTopSetFormKey.currentState!.save();
      _timer = Timer(Duration(seconds: 2), () {
        setState(() {
          hasSavedTopSet = false;
        });
      });
    } else {
      setState(() {
        hasSavedTopSet = false;
      });
      isValidated = false;
      if (weightController.text.isEmpty || weightController.text == '0') {
        setState(() {
          weightSuffixIcon =
              Text('*', style: TextStyle(color: Colors.red, fontSize: 20));
        });
      } else {
        weightSuffixIcon = null;
      }
      if (repsController.text.isEmpty || repsController.text == '0') {
        setState(() {
          repsSuffixIcon =
              Text('*', style: TextStyle(color: Colors.red, fontSize: 20));
        });
      } else {
        repsSuffixIcon = null;
      }
    }

    if (isValidated) {
      // Update weight and reps
      currentExercise.splitWeightAndReps = [int.parse(weight), int.parse(reps)];
      print('updated weight and reps');

      // Update one rep max if applicable
      int? previousOneRepMax = currentExercise.userOneRepMax;
      int newOneRepMax = calculateOneRepMax(int.parse(weight), int.parse(reps));
      if (int.parse(reps) <= 30 &&
          (previousOneRepMax == null || newOneRepMax > previousOneRepMax)) {
        // Can update one rep max
        appState
            .muscleGroups[widget.muscleGroup]![
                widget.exerciseIndices[appState.currentDayIndex]
                    [widget.splitDayCardIndex]]
            .userOneRepMax = newOneRepMax;

        print('updated one rep max');
      }

      setState(() {
        previousWeight = weight;
        previousReps = reps;
      });

      appState.submitExercisePopularityDataToFirebase(
          appState.userID,
          currentExercise.name,
          currentExercise.mainMuscleGroup,
          currentExercise.userRating,
          currentExercise.userOneRepMax,
          currentExercise.splitWeightAndReps);
      print('submitted split weight & rep data to firebase');
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    Exercise currentExercise = appState.muscleGroups[widget.muscleGroup]![widget
        .exerciseIndices[appState.currentDayIndex][widget.splitDayCardIndex]];

    // print(
    // 'accessory: ${appState.muscleGroups[widget.muscleGroup]![widget.exerciseIndices[appState.currentDayIndex][widget.splitDayCardIndex]].isAccessoryMovement}');

    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    final smallTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    final formHeadingStyle = theme.textTheme.titleSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    final formTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
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

    CrossAxisAlignment startOrEnd = appState.splitDayEditMode
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    // No previous topset data
    if (appState
        .muscleGroups[widget.muscleGroup]![
            widget.exerciseIndices[appState.currentDayIndex]
                [widget.splitDayCardIndex]]
        .splitWeightAndReps
        .isEmpty) {
      List<int>? weightAndReps =
          currentExercise.initializeSplitWeightAndRepsFrom1RM();
      // If one rep max isn't null, initialization was successful
      if (weightAndReps != null) {
        previousWeight = weightAndReps[0].toString();
        previousReps = weightAndReps[1].toString();
      }
      // If null, previous weight and reps will remain an empty string
    } else {
      // Previous topset data
      List<int> weightAndReps = currentExercise.splitWeightAndReps;
      previousWeight = weightAndReps[0].toString();
      previousReps = weightAndReps[1].toString();
    }

    if (!widget.isDraggable) {
      return Column(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${widget.muscleGroup}   ',
                        style: headingStyle, textAlign: TextAlign.center),
                        if (widget.split.trainingDays[appState.currentDayIndex].setsPerMuscleGroup[widget.splitDayCardIndex] != 1)
                    Text(
                      '-  ${widget.split.trainingDays[appState.currentDayIndex].setsPerMuscleGroup[widget.splitDayCardIndex]} Sets',
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
                    if (widget.split.trainingDays[appState.currentDayIndex].setsPerMuscleGroup[widget.splitDayCardIndex] == 1)
                    Text(
                      '-  1 Set',
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
                    if (appState.splitDayEditMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10,0,0,0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Increment number of sets
                                if (widget.split.trainingDays[appState.currentDayIndex].setsPerMuscleGroup[widget.splitDayCardIndex] < 10) {
                                  setState(() {
                                    widget.split.trainingDays[appState.currentDayIndex].setsPerMuscleGroup[widget.splitDayCardIndex]++;
                                  });
                                }
                              },
                              child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Decrement number of sets
                                if (widget.split.trainingDays[appState.currentDayIndex].setsPerMuscleGroup[widget.splitDayCardIndex] > 1) {
                                  setState(() {
                                    widget.split.trainingDays[appState.currentDayIndex].setsPerMuscleGroup[widget.splitDayCardIndex]--;
                                  });
                                }
                              },
                              child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: startOrEnd,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (appState.splitDayEditMode)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: IconButton(
                                    onPressed: () {
                                      changeExercise(appState, false);
                                    },
                                    icon: Icon(Icons.navigate_before),
                                    color: theme.colorScheme.onBackground,
                                  ),
                                ),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      toExercise(appState, currentExercise);
                                    },
                                    child: Column(children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                            // exercise index
                                            currentExercise.name,
                                            style: textStyle,
                                            textAlign: TextAlign.center),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        color: theme.colorScheme.onBackground,
                                        height: 150,
                                        width: 150,
                                        child: ImageContainer(
                                            exercise: currentExercise),
                                      ),
                                    ]),
                                  ),
                                  // If star rating of exercise >= 4, it is popular
                                  if (currentExercise.starRating >= 4.0)
                                    // if (widget.exerciseIndices[appState.currentDayIndex]
                                    //         [widget.splitDayCardIndex] ==
                                    //     0) // First exercise in group, thus most popular
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.local_fire_department,
                                            color: theme.colorScheme.primary,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            "Popular Exercise",
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                    color: theme.colorScheme
                                                        .onBackground),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Placeholder to keep alignment the same with and without popular exercise label
                                  if (appState
                                          .muscleGroups[widget.muscleGroup]![
                                              widget.exerciseIndices[
                                                      appState.currentDayIndex]
                                                  [widget.splitDayCardIndex]]
                                          .starRating <
                                      4.0)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.local_fire_department,
                                            color: theme
                                                .colorScheme.primaryContainer,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            "Popular Exercise",
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                    color: theme.colorScheme
                                                        .primaryContainer),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              if (appState.splitDayEditMode)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: IconButton(
                                    onPressed: () {
                                      changeExercise(appState, true);
                                    },
                                    icon: Icon(Icons.navigate_next),
                                    color: theme.colorScheme.onBackground,
                                  ),
                                ),
                            ],
                          ),
                          if (appState.splitDayEditMode)
                            IconButton(
                              onPressed: () {
                                appState.removeTempMuscleGroupFromSplit(
                                  appState.currentDayIndex,
                                  widget.splitDayCardIndex,
                                );
                              },
                              icon: Icon(Icons.delete_forever),
                              color: theme.colorScheme.primary,
                            ),
                          if (!appState.splitDayEditMode)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: SizedBox(
                                width: 179,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Track Top Set',
                                      style: formHeadingStyle,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Form(
                                      key: _trackTopSetFormKey,
                                      child: SizedBox(
                                        // height: 200,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      width: 80,
                                                      height: 44,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: theme
                                                              .colorScheme
                                                              .tertiaryContainer),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                8, 0, 8, 0),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 54,
                                                              height: 44,
                                                              child:
                                                                  TextFormField(
                                                                style:
                                                                    formTextStyle,
                                                                controller:
                                                                    weightController,
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                // textInputAction:
                                                                //     TextInputAction
                                                                //         .done,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .never,
                                                                  labelStyle: labelStyle.copyWith(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .onBackground
                                                                          .withOpacity(
                                                                              .65)),
                                                                  labelText:
                                                                      previousWeight,
                                                                  // suffix: weightSuffixIcon,
                                                                  // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                                ),
                                                              ),
                                                            ),
                                                            if (weightSuffixIcon !=
                                                                null)
                                                              weightSuffixIcon!,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'Weight (lbs)',
                                                      style: labelStyle,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      width: 80,
                                                      height: 44,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: theme
                                                              .colorScheme
                                                              .tertiaryContainer),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                8, 0, 8, 0),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 54,
                                                              height: 44,
                                                              child:
                                                                  TextFormField(
                                                                validator:
                                                                    (value) {
                                                                  return validateRepsInput(
                                                                      value);
                                                                },
                                                                style:
                                                                    formTextStyle,
                                                                controller:
                                                                    repsController,
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                // textInputAction:
                                                                //     TextInputAction
                                                                //         .done,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .never,
                                                                  labelStyle: labelStyle.copyWith(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .onBackground
                                                                          .withOpacity(
                                                                              .65)),
                                                                  labelText:
                                                                      previousReps,
                                                                  // suffix: repsSuffixIcon,
                                                                  // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                                ),
                                                              ),
                                                            ),
                                                            if (repsSuffixIcon !=
                                                                null)
                                                              repsSuffixIcon!,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'Reps',
                                                      style: theme
                                                          .textTheme.labelSmall!
                                                          .copyWith(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onBackground),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            ElevatedButton.icon(
                                              style: ButtonStyle(
                                                  padding:
                                                      MaterialStateProperty.all(
                                                          EdgeInsets.all(10)),
                                                  backgroundColor: resolveColor(
                                                      theme.colorScheme
                                                          .secondaryContainer),
                                                  surfaceTintColor:
                                                      resolveColor(theme
                                                          .colorScheme
                                                          .secondaryContainer)),
                                              onPressed: () {
                                                saveTopSet(
                                                    appState, currentExercise);
                                              },
                                              label: Text(
                                                'Save',
                                                style: labelStyle,
                                              ),
                                              icon: Icon(
                                                Icons.save_alt,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                            if (hasSavedTopSet)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 0, 0),
                                                child: Text(
                                                  'Saved',
                                                  style: labelStyle.copyWith(
                                                    color: theme.colorScheme
                                                        .onBackground
                                                        .withOpacity(.65),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Draggable
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(width: 20),
          Container(
            color: theme.colorScheme.onBackground,
            height: 60,
            width: 60,
            child: ImageContainer(exercise: currentExercise),
          ),
          SizedBox(
            width: 20,
          ),
          Text(
              // exercise index
              appState
                  .muscleGroups[widget.muscleGroup]![
                      widget.exerciseIndices[appState.currentDayIndex]
                          [widget.splitDayCardIndex]]
                  .name,
              style: smallTextStyle,
              textAlign: TextAlign.center),
          Spacer(),
          Icon(
            Icons.reorder,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 20),
        ]),
      );
    }
  }
}

class OuterScroll extends StatelessWidget {
  final bool scrollMode;
  final List<Widget> children;

  const OuterScroll(
      {super.key, required this.scrollMode, required this.children});

  @override
  Widget build(BuildContext context) {
    if (scrollMode) {
      return Column(children: children);
    } else {
      return ListView(children: children);
    }
  }
}
