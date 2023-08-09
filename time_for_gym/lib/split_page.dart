// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:core';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/split.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
// import 'package:flutter_multiselect/flutter_multiselect.dart';

// import 'package:time_for_gym/exercise.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class SplitPage extends StatefulWidget {
  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  late String realTimeDayOfWeek;

  String getDayOfWeekString(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    int dayOfWeek = now.weekday;

    realTimeDayOfWeek = getDayOfWeekString(dayOfWeek);
    // print('Today is $dayOfWeekString');
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70,
        title: Text(
          "Custom Workout Split",
          style: titleStyle,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: OuterScroll(
        scrollMode: appState.splitWeekEditMode,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: appState.makeNewSplit
                ? GymGoalAndDayOfWeekSelector()
                : SplitCard(realTimeDayOfWeek),
          ),
        ],
      ),
    );
  }
}

class GymGoalAndDayOfWeekSelector extends StatefulWidget {
  @override
  _GymGoalAndDayOfWeekSelectorState createState() =>
      _GymGoalAndDayOfWeekSelectorState();
}

class _GymGoalAndDayOfWeekSelectorState
    extends State<GymGoalAndDayOfWeekSelector> {
  final GlobalKey<FormFieldState<List<String>>> _multiSelectKey =
      GlobalKey<FormFieldState<List<String>>>();

  String? selectedGymGoalOption = "Build Muscle";
  String? equipmentChoice = "Full Gym";
  int equipmentLevel = 2;

  List<String> gymGoalOptions = [
    'Build Muscle',
    // 'Build Strength',
    // 'Cardio Focused'
  ];

  List<String> equipmentOptions = ['Full Gym', 'Dumbbell-Only', 'Bodyweight'];

  List<String> selectedDayOfWeekOptions = [];

  List<String> dayOfWeekOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  List<String> selectedMuscleGroups = [];
  List<MultiSelectItem<String>> chipItems = [];

  bool isValidatedDayOfWeek = true;
  bool isValidatedMuscleGroups = true;

  void submitSplitOnPressed(MyAppState appState) {
    // Since selectedDayOfWeekOptions is unsorted:
    String trainingDaysInput = "";
    for (String dayOfWeek in dayOfWeekOptions) {
      if (selectedDayOfWeekOptions.contains(dayOfWeek)) {
        trainingDaysInput += "t"; // train
      } else {
        trainingDaysInput += "r"; // rest
      }
    }
    // Set at 60 training minutes per session temporarily
    if (selectedGymGoalOption != null) {
      appState.setSplit(Split(selectedGymGoalOption!, trainingDaysInput, 60,
          selectedMuscleGroups, equipmentLevel));
    }

    // appState.splitDayExerciseIndices = [[], [], [], [], [], [], []];
    // for (int i = 0; i < appState.currentSplit.trainingDays.length; i++) {
    //   // First split or previous rest day
    //   if (appState.splitDayExerciseIndices[i].isEmpty) {
    //     for (int j = 0;
    //         j < appState.currentSplit.trainingDays[i].muscleGroups.length;
    //         j++) {
    //       appState.splitDayExerciseIndices[i]
    //           .add(0); // Initialize current exercise in split to index 0
    //       // String muscleGroup = appState.currentSplit.trainingDays[i].muscleGroups[j];
    //     }
    //   } else {
    //     print('ERROR - split day exercise indices[$i] is not empty');
    //     // set all to 0
    //     for (int j = 0;
    //         j < appState.currentSplit.trainingDays[i].muscleGroups.length;
    //         j++) {
    //       if (j >= appState.splitDayExerciseIndices[i].length) {
    //         // New split day goes over more muscle groups than previous split day
    //         appState.splitDayExerciseIndices[i].add(0);
    //       }
    //       appState.splitDayExerciseIndices[i][j] =
    //           0; // Initialize current exercise in split to index 0
    //     }
    //   }
    // }

    print(appState.currentSplit);
    print(appState.splitDayExerciseIndices);
  }

  void restorePreviousSplit(var appState) {
    appState.setMakeNewSplit(false);
  }

  void toggleChipSelection(String value) {
    print(selectedMuscleGroups);
    // setState(() {
    //   if (selectedMuscleGroups.contains(value)) {
    //     selectedMuscleGroups.remove(value);
    //   }
    // });

    // setState(() {
    //   // Modify the chipItems list as needed
    //   chipItems = selectedMuscleGroups.map((value) {
    //     return MultiSelectItem<String>(value, value);
    //   }).toList();
    // });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final state = _multiSelectKey.currentState;
    //   if (state != null) {
    //     state.didChange(selectedMuscleGroups);
    //   }
    // });
    // print(selectedMuscleGroups);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    List<String> muscleGroupOptions = appState.muscleGroups.keys.toList();

    final theme = Theme.of(context); //.copyWith(
    //   dialogBackgroundColor: Colors.black,
    // );
    final headingStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onBackground,
      // fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.primary,
    );
    final whiteTextStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return Column(
      children: [
        if (appState.currentSplit != null)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              resolveColor(theme.colorScheme.primaryContainer),
                          surfaceTintColor:
                              resolveColor(theme.colorScheme.primaryContainer)),
                      onPressed: () {
                        restorePreviousSplit(appState);
                      },
                      icon: Icon(
                        Icons.restore,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text("Restore Previous Split", style: labelStyle))
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 25,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Select Gym Goal",
                    style: headingStyle,
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedGymGoalOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGymGoalOption = newValue;
                        });
                      },
                      style: whiteTextStyle,
                      underline: SizedBox(), // Remove default underline
                      dropdownColor: theme.colorScheme.primaryContainer,
                      items: [
                        ...gymGoalOptions.map((gymGoalOption) {
                          return DropdownMenuItem<String>(
                            value: gymGoalOption,
                            child: Text(
                              gymGoalOption,
                              style: (selectedGymGoalOption == gymGoalOption)
                                  ? whiteTextStyle
                                  : whiteTextStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(.65)),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Select Equipment Level",
                    style: headingStyle,
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: equipmentChoice,
                      onChanged: (String? newValue) {
                        setState(() {
                          equipmentChoice = newValue;
                          switch (equipmentChoice) {
                            case 'Full Gym':
                              equipmentLevel = 2;
                              break;
                            case 'Dumbbell-Only':
                              equipmentLevel = 1;
                              break;
                            case 'Bodyweight':
                              equipmentLevel = 0;
                              break;
                            default:
                              break;
                          }
                        });
                      },
                      style: whiteTextStyle,
                      underline: SizedBox(), // Remove default underline
                      dropdownColor: theme.colorScheme.primaryContainer,
                      items: [
                        ...equipmentOptions.map((equipmentOption) {
                          return DropdownMenuItem<String>(
                            value: equipmentOption,
                            child: Text(
                              equipmentOption,
                              style: (equipmentChoice == equipmentOption)
                                  ? whiteTextStyle
                                  : whiteTextStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(.65)),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 25,
              child: Column(
                children: [
                  Text("Select Days to Train", style: headingStyle),
                  SizedBox(height: 20),
                  Container(
                    width: (MediaQuery.of(context).size.width / 2) - 25,
                    // padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: dayOfWeekOptions.map((dayOfWeekOption) {
                        return CheckboxListTile(
                          title: Text(dayOfWeekOption, style: labelStyle),
                          controlAffinity: ListTileControlAffinity.leading,
                          checkColor: theme.colorScheme.onBackground,
                          activeColor: theme.colorScheme.primary,
                          dense: true,
                          visualDensity: VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity),
                          fillColor: resolveColor(theme.colorScheme.primary),
                          value: selectedDayOfWeekOptions
                              .contains(dayOfWeekOption),
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                selectedDayOfWeekOptions.add(dayOfWeekOption);
                              } else {
                                selectedDayOfWeekOptions
                                    .remove(dayOfWeekOption);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // SizedBox(
        //   height: 30,
        // ),

        SizedBox(
          height: 30,
        ),
        Text(
          "Select Muscle Groups to Focus",
          style: headingStyle,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          // child: Theme(
          //   data: Theme.of(context).copyWith(
          //     dialogBackgroundColor: Colors.white,
          //   ),
          child: MultiSelectDialogField<String>(
            key: _multiSelectKey,
            buttonText: Text(
              "Select none for a balanced split",
              style: whiteTextStyle.copyWith(
                  color: whiteTextStyle.color!.withOpacity(.65)),
            ),
            buttonIcon: Icon(
              Icons.keyboard_arrow_down,
              color: theme.colorScheme.onBackground.withOpacity(0.65),
            ),
            items: muscleGroupOptions
                .map((muscleGroupOption) => MultiSelectItem<String>(
                      muscleGroupOption,
                      muscleGroupOption,
                    ))
                .toList(),
            title: Text(
              "Muscle Groups",
              style: headingStyle,
            ), //, style: theme.textTheme.bodyLarge),
            initialValue: selectedMuscleGroups,
            backgroundColor: theme.colorScheme.background,
            // barrierColor: Colors.orange[50],
            barrierColor: Color.fromRGBO(10, 10, 10, 0.8),
            searchable: true,
            itemsTextStyle: whiteTextStyle.copyWith(
                color: whiteTextStyle.color!.withOpacity(.65)),
            searchTextStyle: whiteTextStyle,
            searchHintStyle: whiteTextStyle.copyWith(
                color: whiteTextStyle.color!.withOpacity(.65)),
            selectedItemsTextStyle: whiteTextStyle,
            selectedColor: theme.colorScheme.primary,
            unselectedColor: theme.colorScheme.primary,
            checkColor: theme.colorScheme.onBackground,
            searchIcon: Icon(
              Icons.search,
              color: theme.colorScheme.primary,
            ),
            closeSearchIcon: Icon(
              Icons.clear,
              color: theme.colorScheme.primary,
            ),
            // searchHint: "Search",
            onConfirm: (List<String> results) {
              setState(() {
                selectedMuscleGroups = results;
                chipItems = selectedMuscleGroups.map((value) {
                  return MultiSelectItem<String>(value, value);
                }).toList();
              });
            },
            chipDisplay: MultiSelectChipDisplay<String>(
              // textStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(.65)),
              items: chipItems,
              onTap: (value) {
                toggleChipSelection(value);
              },
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor: resolveColor(theme.colorScheme.primary),
                    surfaceTintColor: resolveColor(theme.colorScheme.primary)),
                onPressed: () {
                  if (selectedDayOfWeekOptions.isEmpty ||
                      selectedMuscleGroups.length > 6) {
                    setState(() {
                      isValidatedDayOfWeek =
                          selectedDayOfWeekOptions.isNotEmpty;
                      isValidatedMuscleGroups =
                          selectedMuscleGroups.length <= 6;
                    });
                  } else {
                    if (!isValidatedDayOfWeek && !isValidatedMuscleGroups) {
                      setState(() {
                        isValidatedDayOfWeek = true;
                        isValidatedMuscleGroups = true;
                      });
                    }
                    submitSplitOnPressed(appState);
                  }
                },
                icon: Icon(
                  Icons.add,
                  color: theme.colorScheme.onBackground,
                ),
                label: Text(
                  "Generate Split",
                  style:
                      textStyle.copyWith(color: theme.colorScheme.onBackground),
                )),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        resolveColor(theme.colorScheme.primaryContainer),
                    surfaceTintColor:
                        resolveColor(theme.colorScheme.primaryContainer)),
                onPressed: () {
                  // Generate empty split
                  equipmentLevel = 2;
                  selectedDayOfWeekOptions = [];
                  selectedMuscleGroups = [];
                  selectedGymGoalOption = "Build Muscle";
                  submitSplitOnPressed(appState);
                },
                child: Text(
                  "Make Empty Split",
                  style:
                      textStyle.copyWith(color: theme.colorScheme.onBackground),
                )),
          ],
        ),
        if (!isValidatedDayOfWeek || !isValidatedMuscleGroups)
          SizedBox(height: 5),
        if (!isValidatedDayOfWeek || !isValidatedMuscleGroups)
          Text(
            // If day of week isn't valid, display that. If it is valid, muscles group must be invalid
            isValidatedDayOfWeek
                ? 'Please Select 6 Muscle Groups or Less'
                : 'Please Select Days to Train',
            style: labelStyle.copyWith(color: theme.colorScheme.secondary),
          )
      ],
    );
  }
}

class SplitCard extends StatefulWidget {
  SplitCard(this.realTimeDayOfWeek);
  final String realTimeDayOfWeek;

  @override
  State<SplitCard> createState() => _SplitCardState();
}

class _SplitCardState extends State<SplitCard> {
  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  void regenerateSplit(var appState) {
    appState.setMakeNewSplit(true);
  }

  void cancelEditChanges(var appState) {
    appState.toSplitWeekEditMode(false);
  }

  void saveEditChanges(var appState) {
    appState.saveWeekEditChanges();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onBackground,
      // fontWeight: FontWeight.bold,
    );
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    Split split;
    List<List<int>> exerciseIndices;
    if (appState.splitWeekEditMode) {
      split = appState.editModeTempSplit;
      exerciseIndices = appState.editModeTempExerciseIndices;
    } else {
      split = appState.currentSplit;
      exerciseIndices = appState.splitDayExerciseIndices;
    }

    List<Widget> dayOfWeekButtons = List.generate(
      split.trainingDays.length,
      (i) => DayOfWeekButton(
          key: ValueKey(i), // Assign a unique key to each SplitMuscleGroupCard
          theme: theme,
          daysOfWeek: daysOfWeek,
          i: i,
          headingStyle: headingStyle,
          split: split,
          textStyle: labelStyle,
          appState: appState,
          realTimeDayOfWeek: widget.realTimeDayOfWeek),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (appState.splitWeekEditMode)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              resolveColor(theme.colorScheme.primaryContainer),
                          surfaceTintColor:
                              resolveColor(theme.colorScheme.primaryContainer)),
                      onPressed: () {
                        cancelEditChanges(appState);
                      },
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text("Cancel", style: labelStyle)),
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              resolveColor(theme.colorScheme.primaryContainer),
                          surfaceTintColor:
                              resolveColor(theme.colorScheme.primaryContainer)),
                      onPressed: () {
                        saveEditChanges(appState);
                      },
                      icon: Icon(
                        Icons.save_alt,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text("Save", style: labelStyle))
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                            resolveColor(theme.colorScheme.primaryContainer),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primaryContainer)),
                    icon: Icon(
                      Icons.keyboard_arrow_up,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      appState.shiftSplit(split, exerciseIndices, -1);
                    },
                    label: Text(
                      "Shift Up",
                      style: labelStyle,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                            resolveColor(theme.colorScheme.primaryContainer),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primaryContainer)),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      appState.shiftSplit(split, exerciseIndices, 1);
                    },
                    label: Text(
                      "Shift Down",
                      style: labelStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (!appState.splitWeekEditMode)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        resolveColor(theme.colorScheme.primaryContainer),
                    surfaceTintColor:
                        resolveColor(theme.colorScheme.primaryContainer)),
                icon: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  appState.toSplitWeekEditMode(true);
                },
                label: Text(
                  "Edit",
                  style: labelStyle,
                ),
              ),
              ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        resolveColor(theme.colorScheme.primaryContainer),
                    surfaceTintColor:
                        resolveColor(theme.colorScheme.primaryContainer)),
                onPressed: () {
                  regenerateSplit(appState);
                },
                icon: Icon(
                  Icons.autorenew,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  "New",
                  style: labelStyle,
                ),
              ),
            ],
          ),
        SizedBox(
          height: 20,
        ),
        if (!appState.splitWeekEditMode)
          for (Widget dayOfWeekButton in dayOfWeekButtons) dayOfWeekButton,
        if (appState.splitWeekEditMode)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 556),
            // height: ,
            child: ReorderableListView(
              children: dayOfWeekButtons,
              onReorder: (oldIndex, newIndex) {
                print("Training days before reorder: ${split.trainingDays}");
                print("Exercise indices before reorder: $exerciseIndices");
                try {
                  setState(() {
                    // if (newIndex >= dayOfWeekButtons.length || newIndex < 0) {
                    //   // Avoid out of bounds error
                    //   return;
                    // }
                    if (newIndex > oldIndex) {
                      newIndex -=
                          1; // Adjust the index when moving an item down
                    }
                    final card = dayOfWeekButtons.removeAt(oldIndex);
                    final TrainingDay trainingDay =
                        split.trainingDays.removeAt(oldIndex);
                    final List<int> exerciseIndicesForTheDay =
                        exerciseIndices.removeAt(oldIndex);
                    dayOfWeekButtons.insert(newIndex, card);
                    split.trainingDays.insert(newIndex, trainingDay);
                    exerciseIndices.insert(newIndex, exerciseIndicesForTheDay);

                    print(
                        "Trainings days after reorder: ${split.trainingDays}");
                    print("Exercise indices after reorder: $exerciseIndices");
                  });
                } catch (e) {
                  print("Drag and drop error - $e");
                }
              },
            ),
          ),
      ],
    );
  }
}

class DayOfWeekButton extends StatelessWidget {
  const DayOfWeekButton({
    super.key,
    required this.theme,
    required this.daysOfWeek,
    required this.i,
    required this.headingStyle,
    required this.split,
    required this.textStyle,
    required this.appState,
    required this.realTimeDayOfWeek,
  });

  final ThemeData theme;
  final List<String> daysOfWeek;
  final int i;
  final TextStyle headingStyle;
  final Split split;
  final TextStyle textStyle;
  final MyAppState appState;
  final String realTimeDayOfWeek;

  void viewDayOfWeek(MyAppState appState, int dayIndex) {
    appState.currentDayIndex = dayIndex;
    appState.changePage(7);
  }

  @override
  Widget build(BuildContext context) {
    final Color dayColor;
    if (realTimeDayOfWeek == daysOfWeek[i]) {
      dayColor = theme.colorScheme.primary;
    } else {
      dayColor = theme.colorScheme.onBackground;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: resolveColor(theme.colorScheme.primaryContainer),
              surfaceTintColor:
                  resolveColor(theme.colorScheme.primaryContainer)),
          onPressed: () {
            viewDayOfWeek(appState, i);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${daysOfWeek[i]}:',
                style: headingStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dayColor,
                ),
                textAlign: TextAlign.left,
              ),
              Spacer(),
              Expanded(
                child: Text(
                  split.trainingDays[i].toString(),
                  style: theme.textTheme.labelSmall!
                      .copyWith(color: dayColor, fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              if (appState.splitWeekEditMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                  child: Icon(
                    Icons.reorder,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
