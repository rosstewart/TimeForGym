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

  void _dismissKeyboard() {
    // Unfocus the text fields when tapped outside
    FocusScope.of(context).unfocus();
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
        dayIndex: widget.dayIndex,
      ),
    );

    // var exercises = appState.muscleGroups[appState.currentMuscleGroup];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    // bool scrollBarThumbVisibility = appState.splitDayEditMode;

    return GestureDetector(
      onTap: _dismissKeyboard, // Handle tap gesture
      child: SwipeBack(
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
                          style: titleStyle.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.65)),
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
                  if (!appState.splitDayEditMode &&
                      !appState.splitDayReorderMode)
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
                                  Icons.close,
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
                                    if (_titleFormKey.currentState!
                                        .validate()) {
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
                                        muscleGroupAndExerciseIndexAndNumSets[
                                            0],
                                        muscleGroupAndExerciseIndexAndNumSets[
                                            1],
                                        muscleGroupAndExerciseIndexAndNumSets[
                                            2]);

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
                        dayIndex: widget.dayIndex,
                      ),
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
          Icons.add,
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

    final focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: focusNode.unfocus,
          child: AlertDialog(
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
                    focusNode: focusNode,
                    style: whiteTextStyle,
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      labelStyle: whiteTextStyle.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.65)),
                      floatingLabelStyle: whiteTextStyle.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.65)),
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
                      searchController.text =
                          suggestion; // Update the text field
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
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
                  icon: Icon(
                    Icons.add,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    'Add',
                    style: textStyle.copyWith(
                        color: theme.colorScheme.onBackground),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        resolveColor(theme.colorScheme.primaryContainer),
                    surfaceTintColor:
                        resolveColor(theme.colorScheme.primaryContainer)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  'Cancel',
                  style:
                      textStyle.copyWith(color: theme.colorScheme.onBackground),
                ),
              ),
            ],
          ),
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
    required this.dayIndex,
  });

  final String muscleGroup;
  final int splitDayCardIndex;
  final Split split;
  final List<List<int>> exerciseIndices;
  final bool isDraggable;
  int exerciseIndex = 0;
  final int dayIndex;

  @override
  State<SplitMuscleGroupCard> createState() => _SplitMuscleGroupCardState();
}

class _SplitMuscleGroupCardState extends State<SplitMuscleGroupCard> {
  // TextEditingController weightController = TextEditingController();
  // TextEditingController repsController = TextEditingController();

  bool showPreviousReps = false;
  bool showPreviousWeight = false;

  // String previousWeight = "";
  // String previousReps = "";

  late List<String> previousWeights;
  late List<String> previousReps;

  final _trackTopSetFormKey = GlobalKey<FormState>();

  // bool _isWeightFieldEmpty = true;
  // bool _isRepsFieldEmpty = true;

  late List<Widget?> weightSuffixIcons;
  late List<Widget?> repsSuffixIcons;

  bool hasSavedTopSet = false;

  Timer? _timer;

  late List<TextEditingController> setsWeightControllers;
  late List<TextEditingController> setsRepsControllers;
  late int numSets;

  Widget suffixIcon =
      Text('*', style: TextStyle(color: Colors.red, fontSize: 20));

  @override
  void initState() {
    super.initState();
    setsWeightControllers = [];
    setsRepsControllers = [];
    previousWeights = [];
    previousReps = [];
    weightSuffixIcons = [];
    repsSuffixIcons = [];
    numSets = widget.split.trainingDays[widget.dayIndex]
        .setsPerMuscleGroup[widget.splitDayCardIndex];
    for (int i = 0; i < numSets; i++) {
      setsWeightControllers.add(TextEditingController());
      setsRepsControllers.add(TextEditingController());
      previousWeights.add('');
      previousReps.add('');
      weightSuffixIcons.add(null);
      repsSuffixIcons.add(null);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void changeExercise(var appState, bool next) {
    widget.exerciseIndex =
        widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex];
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
    widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex] =
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

  void saveTopSet(
      MyAppState appState, Exercise currentExercise, bool showMoreSets) {
    List<String> weights = setsWeightControllers.map((e) => e.text).toList();
    List<String> reps = setsRepsControllers.map((e) => e.text).toList();
    // String weight = weightController.text;
    // String reps = repsController.text;
    bool isValidated = true;

    //TODO - Add kilo i/o functionality

    // if (_trackTopSetFormKey.currentState!.validate()) {
    //   _trackTopSetFormKey.currentState!.save();
    // } else {
    //   isValidated = false;
    // }

    if (!showMoreSets) {
      if (weights[0].isNotEmpty &&
          weights[0] != '0' &&
          reps[0].isNotEmpty &&
          reps[0] != '0') {
        setState(() {
          weightSuffixIcons[0] = null;
          repsSuffixIcons[0] = null;
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
        if (weights[0].isEmpty || weights[0] == '0') {
          setState(() {
            weightSuffixIcons[0] = suffixIcon;
          });
        } else {
          weightSuffixIcons[0] = null;
        }
        if (reps[0].isEmpty || reps[0] == '0') {
          setState(() {
            repsSuffixIcons[0] = suffixIcon;
          });
        } else {
          repsSuffixIcons[0] = null;
        }
      }

      if (isValidated) {
        // Update weight and reps
        currentExercise.splitWeightAndReps = [
          int.parse(weights[0]),
          int.parse(reps[0])
        ];
        print('updated weight and reps');

        // Update one rep max if applicable
        int? previousOneRepMax = currentExercise.userOneRepMax;
        int newOneRepMax =
            calculateOneRepMax(int.parse(weights[0]), int.parse(reps[0]));
        if (int.parse(reps[0]) <= 30 &&
            (previousOneRepMax == null || newOneRepMax > previousOneRepMax)) {
          // Can update one rep max
          currentExercise.userOneRepMax = newOneRepMax;

          print('updated one rep max');
        }

        setState(() {
          previousWeights[0] = weights[0];
          previousReps[0] = reps[0];
        });

        appState.submitExercisePopularityDataToFirebase(
            appState.userID,
            currentExercise.name,
            currentExercise.mainMuscleGroup,
            currentExercise.userRating,
            currentExercise.userOneRepMax,
            currentExercise.splitWeightAndReps,
            currentExercise.splitWeightPerSet,
            currentExercise.splitRepsPerSet);
        print('submitted split weight & rep data to firebase');
      }
    } else {
      // Show more sets == true
      for (int i = 0; i < numSets; i++) {
        if (weights[i].isEmpty) {
          weights[i] = previousWeights[i]; // Submit previous weight if any
        }
        if (reps[i].isEmpty) {
          reps[i] = previousReps[i]; // Submit previous reps if any
        }
        if (weights[i].isNotEmpty &&
            weights[i] != '0' &&
            reps[i].isNotEmpty &&
            reps[i] != '0') {
          setState(() {
            weightSuffixIcons[i] = null;
            repsSuffixIcons[i] = null;
          });
        } else {
          setState(() {
            hasSavedTopSet = false;
          });
          isValidated = false;
          if (weights[i].isEmpty || weights[i] == '0') {
            setState(() {
              weightSuffixIcons[i] = suffixIcon;
            });
          } else {
            weightSuffixIcons[i] = null;
          }
          if (reps[i].isEmpty || reps[i] == '0') {
            setState(() {
              repsSuffixIcons[i] = suffixIcon;
            });
          } else {
            repsSuffixIcons[i] = null;
          }
        }
      }

      if (isValidated) {
        setState(() {
          hasSavedTopSet = true;
        });
        _trackTopSetFormKey.currentState!.save();
        _timer = Timer(Duration(seconds: 2), () {
          setState(() {
            hasSavedTopSet = false;
          });
        });
        // Update weight and reps
        currentExercise.splitWeightAndReps = [
          int.parse(weights[0]),
          int.parse(reps[0])
        ];
        currentExercise.splitWeightPerSet =
            weights.map((string) => int.parse(string)).toList();
        currentExercise.splitRepsPerSet =
            reps.map((string) => int.parse(string)).toList();
        print('updated weight and reps');

        // Update one rep max if applicable
        int? previousOneRepMax = currentExercise.userOneRepMax;
        for (int i = 0; i < numSets; i++) {
          // Check every set if they hit a new calculated one rep max
          int newOneRepMax =
              calculateOneRepMax(int.parse(weights[i]), int.parse(reps[i]));
          if (int.parse(reps[i]) <= 30 &&
              (previousOneRepMax == null || newOneRepMax > previousOneRepMax)) {
            // Can update one rep max
            currentExercise.userOneRepMax = newOneRepMax;

            print('updated one rep max');
          }
        }

        setState(() {
          previousWeights = weights;
          previousReps = reps;
          // for (int i = 0; i < numSets; i++) {
          //   previousWeights[i] = weights[i];
          //   previousReps[i] = reps[i];
          // }
        });

        appState.submitExercisePopularityDataToFirebase(
          appState.userID,
          currentExercise.name,
          currentExercise.mainMuscleGroup,
          currentExercise.userRating,
          currentExercise.userOneRepMax,
          currentExercise.splitWeightAndReps,
          currentExercise.splitWeightPerSet,
          currentExercise.splitRepsPerSet,
        );
        print('submitted split weight & rep data to firebase');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    Exercise currentExercise = appState.muscleGroups[widget.muscleGroup]![
        widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex]];

    // print(
    // 'accessory: ${appState.muscleGroups[widget.muscleGroup]![widget.exerciseIndices[appState.currentDayIndex][widget.splitDayCardIndex]].isAccessoryMovement}');

    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.titleSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    final smallTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    final formHeadingStyle = theme.textTheme.bodyMedium!.copyWith(
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
        widget.exerciseIndices[widget.dayIndex].length) {
      widget.exerciseIndices[widget.dayIndex].add(0);
    }

    // Reset exercise index if out of bounds
    if (widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex] >=
        appState.muscleGroups[widget.muscleGroup]!.length) {
      widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex] = 0;
    }

    CrossAxisAlignment startOrEnd = appState.splitDayEditMode
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    // No previous topset data
    if (currentExercise.splitWeightAndReps.isEmpty) {
      List<List<int>>? weightAndReps =
          currentExercise.initializeSplitWeightAndRepsFrom1RM(numSets);
      // If one rep max isn't null, initialization was successful
      if (weightAndReps != null) {
        for (int i = 0; i < weightAndReps[0].length; i++) {
          previousWeights[i] = weightAndReps[0][i].toString();
          previousReps[i] = weightAndReps[1][i].toString();
        }
      }
      // If null, previous weight and reps will remain an empty string
    } else {
      // Previous topset data
      // List<int> weightAndReps = currentExercise.splitWeightAndReps;
      if (currentExercise.splitWeightPerSet.isEmpty ||
          currentExercise.splitRepsPerSet.isEmpty) {
        List<List<int>>? weightAndReps =
            currentExercise.initializeSetsFromTopSet(numSets);
        if (weightAndReps != null) {
          for (int i = 0; i < weightAndReps[0].length; i++) {
            previousWeights[i] = weightAndReps[0][i].toString();
            previousReps[i] = weightAndReps[1][i].toString();
          }
        }
      } else {
        previousWeights = currentExercise.splitWeightPerSet.map((e) => e.toString()).toList();
        previousReps = currentExercise.splitRepsPerSet.map((e) => e.toString()).toList();
        // Fill arrays if numSets was incremented
        if (previousWeights.length < numSets) {
          for (int i = previousWeights.length; i < numSets; i++) {
            previousWeights.add(previousWeights[previousWeights.length-1]);
          }
        }
        if (previousReps.length < numSets) {
          for (int i = previousReps.length; i < numSets; i++) {
            previousReps.add(previousReps[previousReps.length-1]);
          }
        }
      }
    }

    bool showMoreSets = (numSets > 1 &&
        previousWeights[0].isNotEmpty &&
        previousReps[0].isNotEmpty);

    // List<String> weightAndRepsPerSet = [];
    // if

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
                dayIndex: widget.dayIndex,
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
                    if (numSets != 1)
                      Text(
                        '-  $numSets Sets',
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                    if (numSets == 1)
                      Text(
                        '-  1 Set',
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                    if (appState.splitDayEditMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Increment number of sets
                                if (numSets < 10) {
                                  setState(() {
                                    widget.split.trainingDays[widget.dayIndex]
                                            .setsPerMuscleGroup[
                                        widget.splitDayCardIndex]++;
                                    numSets++;
                                    setsWeightControllers
                                        .add(TextEditingController());
                                    setsRepsControllers
                                        .add(TextEditingController());
                                    previousWeights.add('');
                                    previousReps.add('');
                                    weightSuffixIcons.add(null);
                                    repsSuffixIcons.add(null);
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
                                if (numSets > 1) {
                                  setState(() {
                                    widget.split.trainingDays[widget.dayIndex]
                                            .setsPerMuscleGroup[
                                        widget.splitDayCardIndex]--;
                                    numSets--;
                                    setsWeightControllers[
                                            setsWeightControllers.length - 1]
                                        .dispose();
                                    setsWeightControllers.removeLast();
                                    setsRepsControllers[
                                            setsRepsControllers.length - 1]
                                        .dispose();
                                    setsRepsControllers.removeLast();
                                    previousWeights.removeLast();
                                    previousReps.removeLast();
                                    weightSuffixIcons.removeLast();
                                    repsSuffixIcons.removeLast();
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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                                            style: smallTextStyle,
                                            textAlign: TextAlign.center),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        color: theme.colorScheme.onBackground,
                                        height: 120,
                                        width: 120,
                                        child: ImageContainer(
                                            exercise: currentExercise),
                                      ),
                                    ]),
                                  ),
                                  // If star rating of exercise >= 4, it is popular
                                  if (appState.splitDayEditMode &&
                                      currentExercise.starRating >= 4.0)
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
                                  if (appState.splitDayEditMode &&
                                      currentExercise.starRating < 4.0)
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
                                  widget.dayIndex,
                                  widget.splitDayCardIndex,
                                );
                              },
                              icon: Icon(Icons.delete_forever),
                              color: theme.colorScheme.primary,
                            ),
                          if (!appState.splitDayEditMode)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (!showMoreSets)
                                  Text(
                                    'Track Top Set',
                                    style: formHeadingStyle,
                                  ),
                                if (showMoreSets)
                                  Text(
                                    'Track Sets',
                                    style: formHeadingStyle,
                                  ),
                                SizedBox(
                                  height: 10,
                                ),
                                Form(
                                  key: _trackTopSetFormKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                // width: 80,
                                                // height: 44,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: theme.colorScheme
                                                        .tertiaryContainer),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 0, 8, 0),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 42,
                                                        height: 38,
                                                        child: TextFormField(
                                                          maxLength: 3,
                                                          style: formTextStyle,
                                                          controller:
                                                              setsWeightControllers[
                                                                  0],
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
                                                            counterText: '',
                                                            border: InputBorder
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
                                                                previousWeights[
                                                                    0],
                                                            // suffix: weightSuffixIcon,
                                                            // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                          ),
                                                        ),
                                                      ),
                                                      if (weightSuffixIcons[
                                                              0] !=
                                                          null)
                                                        weightSuffixIcons[0]!,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (showMoreSets)
                                                for (int i = 1;
                                                    i < numSets;
                                                    i++)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 10, 0, 0),
                                                    child: Container(
                                                      // width: 80,
                                                      // height: 44,
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
                                                            SizedBox(
                                                              width: 42,
                                                              height: 38,
                                                              child:
                                                                  TextFormField(
                                                                maxLength: 3,
                                                                style:
                                                                    formTextStyle,
                                                                controller:
                                                                    setsWeightControllers[
                                                                        i],
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
                                                                  counterText:
                                                                      '',
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
                                                                      previousWeights[
                                                                          i],
                                                                  // suffix: weightSuffixIcon,
                                                                  // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                                ),
                                                              ),
                                                            ),
                                                            if (weightSuffixIcons[
                                                                    i] !=
                                                                null)
                                                              weightSuffixIcons[
                                                                  i]!,
                                                          ],
                                                        ),
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
                                            width: 5,
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                // width: 80,
                                                // height: 44,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: theme.colorScheme
                                                        .tertiaryContainer),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 0, 8, 0),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 42,
                                                        height: 38,
                                                        child: TextFormField(
                                                          maxLength: 2,
                                                          validator: (value) {
                                                            return validateRepsInput(
                                                                value);
                                                          },
                                                          style: formTextStyle,
                                                          controller:
                                                              setsRepsControllers[
                                                                  0],
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
                                                            counterText: '',
                                                            border: InputBorder
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
                                                                previousReps[0],
                                                            // suffix: repsSuffixIcon,
                                                            // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                          ),
                                                        ),
                                                      ),
                                                      if (repsSuffixIcons[0] !=
                                                          null)
                                                        repsSuffixIcons[0]!,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (showMoreSets)
                                                for (int i = 1;
                                                    i < numSets;
                                                    i++)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 10, 0, 0),
                                                    child: Container(
                                                      // width: 80,
                                                      // height: 44,
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
                                                            SizedBox(
                                                              width: 42,
                                                              height: 38,
                                                              child:
                                                                  TextFormField(
                                                                maxLength: 2,
                                                                validator:
                                                                    (value) {
                                                                  return validateRepsInput(
                                                                      value);
                                                                },
                                                                style:
                                                                    formTextStyle,
                                                                controller:
                                                                    setsRepsControllers[
                                                                        i],
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
                                                                  counterText:
                                                                      '',
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
                                                                      previousReps[
                                                                          i],
                                                                  // suffix: repsSuffixIcon,
                                                                  // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                                ),
                                                              ),
                                                            ),
                                                            if (repsSuffixIcons[
                                                                    i] !=
                                                                null)
                                                              repsSuffixIcons[
                                                                  i]!,
                                                          ],
                                                        ),
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
                                                        color: theme.colorScheme
                                                            .onBackground),
                                              ),
                                            ],
                                          ),
                                          // if (!showMoreSets)
                                          SizedBox(
                                            width: 5,
                                          ),
                                          // if (!showMoreSets)
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                child: IconButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          resolveColor(theme
                                                              .colorScheme
                                                              .secondaryContainer),
                                                      surfaceTintColor:
                                                          resolveColor(theme
                                                              .colorScheme
                                                              .secondaryContainer)),
                                                  onPressed: () {
                                                    saveTopSet(
                                                        appState,
                                                        currentExercise,
                                                        showMoreSets);
                                                  },
                                                  // label: Text(
                                                  //   'Save',
                                                  //   style: labelStyle,
                                                  // ),
                                                  icon: Icon(
                                                    Icons.save_alt,
                                                    color: theme
                                                        .colorScheme.primary,
                                                    size: 20,
                                                  ),
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
                                          )
                                        ],
                                      ),
                                      // SizedBox(
                                      //   height: 10,
                                      // ),
                                      // if (showMoreSets)
                                      //   Column(
                                      //     crossAxisAlignment:
                                      //         CrossAxisAlignment.start,
                                      //     children: [
                                      //       for (int i = 1; i < numSets; i++)
                                      //         Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.start,
                                      //           children: [
                                      //             if (i < numSets - 1)
                                      //               Text(
                                      //                 'Set ${i + 1} -',
                                      //                 style: labelStyle,
                                      //               ),
                                      //             if (i == numSets - 1)
                                      //               Text(
                                      //                 'Set ${i + 1} (Dropset) -',
                                      //                 style: labelStyle,
                                      //               ),
                                      //           ],
                                      //         ),
                                      //       Column(
                                      //         mainAxisAlignment:
                                      //             MainAxisAlignment.start,
                                      //         children: [
                                      //           SizedBox(
                                      //             child: IconButton(
                                      //               style: ButtonStyle(
                                      //                   backgroundColor:
                                      //                       resolveColor(theme
                                      //                           .colorScheme
                                      //                           .secondaryContainer),
                                      //                   surfaceTintColor:
                                      //                       resolveColor(theme
                                      //                           .colorScheme
                                      //                           .secondaryContainer)),
                                      //               onPressed: () {
                                      //                 saveTopSet(appState,
                                      //                     currentExercise);
                                      //               },
                                      //               // label: Text(
                                      //               //   'Save',
                                      //               //   style: labelStyle,
                                      //               // ),
                                      //               icon: Icon(
                                      //                 Icons.save_alt,
                                      //                 color: theme
                                      //                     .colorScheme.primary,
                                      //                 size: 20,
                                      //               ),
                                      //             ),
                                      //           ),
                                      //           if (hasSavedTopSet)
                                      //             Padding(
                                      //               padding: const EdgeInsets
                                      //                   .fromLTRB(0, 5, 0, 0),
                                      //               child: Text(
                                      //                 'Saved',
                                      //                 style:
                                      //                     labelStyle.copyWith(
                                      //                   color: theme.colorScheme
                                      //                       .onBackground
                                      //                       .withOpacity(.65),
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //         ],
                                      //       )
                                      //     ],
                                      //   )
                                      // IconButton(
                                      //   style: ButtonStyle(
                                      //       padding:
                                      //           MaterialStateProperty.all(
                                      //               EdgeInsets.all(10)),
                                      //       backgroundColor: resolveColor(
                                      //           theme.colorScheme
                                      //               .secondaryContainer),
                                      //       surfaceTintColor:
                                      //           resolveColor(theme
                                      //               .colorScheme
                                      //               .secondaryContainer)),
                                      //   onPressed: () {
                                      //     saveTopSet(
                                      //         appState, currentExercise);
                                      //   },
                                      //   // label: Text(
                                      //   //   'Save',
                                      //   //   style: labelStyle,
                                      //   // ),
                                      //   icon: Icon(
                                      //     Icons.save_alt,
                                      //     color:
                                      //         theme.colorScheme.primary,
                                      //   ),
                                      // ),
                                      // if (hasSavedTopSet)
                                      //   Padding(
                                      //     padding:
                                      //         const EdgeInsets.fromLTRB(
                                      //             0, 5, 0, 0),
                                      //     child: Text(
                                      //       'Saved',
                                      //       style: labelStyle.copyWith(
                                      //         color: theme.colorScheme
                                      //             .onBackground
                                      //             .withOpacity(.65),
                                      //       ),
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                ),
                              ],
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
              currentExercise.name,
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
