// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/split.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
// import 'package:flutter_multiselect/flutter_multiselect.dart';

// import 'package:time_for_gym/exercise.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class SplitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall!.copyWith(
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
            padding: const EdgeInsets.all(20),
            child: appState.makeNewSplit
                ? GymGoalAndDayOfWeekSelector()
                : SplitCard(),
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
  String? selectedGymGoalOption = "Build Muscle";

  List<String> gymGoalOptions = [
    'Build Muscle',
    'Build Strength',
    'Cardio Focused'
  ];

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

  void submitSplitOnPressed(var appState) {
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
    // No focused muscle groups temporarily
    if (selectedGymGoalOption != null) {
      appState.setSplit(Split(
          selectedGymGoalOption!, trainingDaysInput, 60, selectedMuscleGroups));
    }

    for (int i = 0; i < appState.currentSplit.trainingDays.length; i++) {
      // First split or previous rest day
      if (appState.splitDayExerciseIndices[i].isEmpty) {
        for (int j = 0;
            j < appState.currentSplit.trainingDays[i].muscleGroups.length;
            j++) {
          appState.splitDayExerciseIndices[i]
              .add(0); // Initialize current exercise in split to index 0
          // String muscleGroup = appState.currentSplit.trainingDays[i].muscleGroups[j];
        }
      } else {
        // set all to 0
        for (int j = 0;
            j < appState.currentSplit.trainingDays[i].muscleGroups.length;
            j++) {
          if (j >= appState.splitDayExerciseIndices[i].length) {
            // New split day goes over more muscle groups than previous split day
            appState.splitDayExerciseIndices[i].add(0);
          }
          appState.splitDayExerciseIndices[i][j] =
              0; // Initialize current exercise in split to index 0
        }
      }
    }

    appState.storeSplitInSharedPreferences();
    appState.saveSplitDayExerciseIndicesData(); // Initialize as 0s to be saved
  }

  void restorePreviousSplit(var appState) {
    appState.setMakeNewSplit(false);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    List<String> muscleGroupOptions = appState.muscleGroups.keys.toList();

    final theme = Theme.of(context); //.copyWith(
    //   dialogBackgroundColor: Colors.black,
    // );
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.primary,
    );
    final whiteTextStyle = theme.textTheme.bodyLarge!.copyWith(
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
                      label: Text("Restore Previous Split",
                          style: textStyle.copyWith(
                              color: theme.colorScheme.onBackground)))
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        Text(
          "Select Gym Goal:",
          style: headingStyle,
        ),
        SizedBox(height: 20),
        // Column(
        //   children: gymGoalOptions.map((gymGoalOption) {
        //     return RadioListTile<String>(
        //       title: Text(gymGoalOption),
        //       value: gymGoalOption,
        //       groupValue: selectedGymGoalOption,
        //       onChanged: (value) {
        //         setState(() {
        //           selectedGymGoalOption = value;
        //         });
        //       },
        //     );
        //   }).toList(),
        // ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
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
                    style: whiteTextStyle,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          "Select Days to Train:",
          style: headingStyle,
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: dayOfWeekOptions.map((dayOfWeekOption) {
              return CheckboxListTile(
                title: Text(
                  dayOfWeekOption,
                  style: whiteTextStyle,
                ),
                checkColor: theme.colorScheme.onBackground,
                activeColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: theme.colorScheme
                        .onBackground, // Set the desired border color
                  ),
                ),
                value: selectedDayOfWeekOptions.contains(dayOfWeekOption),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedDayOfWeekOptions.add(dayOfWeekOption);
                    } else {
                      selectedDayOfWeekOptions.remove(dayOfWeekOption);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          "Select Muscle Groups to Focus:",
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
            buttonText: Text(
              "Select none for a balanced split",
              style: whiteTextStyle,
            ),
            buttonIcon: Icon(
              Icons.keyboard_arrow_down,
              color: Color.fromRGBO(80, 80, 80, 1),
            ),
            items: muscleGroupOptions
                .map((muscleGroupOption) => MultiSelectItem<String>(
                      muscleGroupOption,
                      muscleGroupOption,
                    ))
                .toList(),
            title: Text(
              "Muscle Groups",
              style: TextStyle(color: theme.colorScheme.onBackground),
            ), //, style: theme.textTheme.bodyLarge),
            initialValue: selectedMuscleGroups,
            backgroundColor: theme.colorScheme.background,
            // barrierColor: Colors.orange[50],
            barrierColor: Color.fromRGBO(10, 10, 10, 0.8),
            searchable: true,
            itemsTextStyle: whiteTextStyle,
            searchTextStyle: whiteTextStyle,
            searchHintStyle: whiteTextStyle,
            selectedItemsTextStyle: whiteTextStyle,
            selectedColor: theme.colorScheme.primary,
            unselectedColor: theme.colorScheme.onBackground,
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
              });
            },
            chipDisplay: MultiSelectChipDisplay<String>(
              onTap: (value) {
                setState(() {
                  selectedMuscleGroups.remove(value);
                });
              },
            ),
          ),
        ), //),
        SizedBox(
          height: 30,
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    resolveColor(theme.colorScheme.primaryContainer),
                surfaceTintColor:
                    resolveColor(theme.colorScheme.primaryContainer)),
            onPressed: () {
              submitSplitOnPressed(appState);
            },
            child: Text(
              "Generate Split",
              style: textStyle,
            ))
      ],
    );
  }
}

class SplitCard extends StatefulWidget {
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
    final textStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.primary,
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
          textStyle: textStyle,
          appState: appState),
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
                        Icons.cancel,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text("Cancel", style: headingStyle)),
                  Spacer(),
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
                      label: Text("Save", style: headingStyle))
                ],
              ),
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
                  style: headingStyle,
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
                  style: headingStyle,
                ),
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
                  Icons.edit,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  appState.toSplitWeekEditMode(true);
                },
                label: Text(
                  "Edit Split",
                  style: headingStyle,
                ),
              ),
              Spacer(),
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
                  "Make a New Split",
                  style: headingStyle,
                ),
              ),
            ],
          ),
        SizedBox(
          height: 20,
        ),

        if (!appState.splitWeekEditMode)
        for (Widget dayOfWeekButton in dayOfWeekButtons)
          dayOfWeekButton,

        if (appState.splitWeekEditMode)
        SizedBox(
          height: 521,
          child: ReorderableListView(
            children: dayOfWeekButtons,
            onReorder: (oldIndex, newIndex) {
              print(
                  "Training days before reorder: ${split.trainingDays}");
              print(
                  "Exercise indices before reorder: $exerciseIndices");
              try {
                setState(() {
                  // if (newIndex >= dayOfWeekButtons.length || newIndex < 0) {
                  //   // Avoid out of bounds error
                  //   return;
                  // }
                  if (newIndex > oldIndex) {
                    newIndex -= 1; // Adjust the index when moving an item down
                  }
                  final card = dayOfWeekButtons.removeAt(oldIndex);
                  final TrainingDay trainingDay = split.trainingDays.removeAt(oldIndex);
                  final List<int> exerciseIndicesForTheDay = exerciseIndices.removeAt(oldIndex);
                  dayOfWeekButtons.insert(newIndex, card);
                  split.trainingDays.insert(newIndex, trainingDay);
                  exerciseIndices.insert(newIndex,exerciseIndicesForTheDay);

                  print(
                      "Trainings days after reorder: ${split.trainingDays}");
                  print(
                      "Exercise indices after reorder: $exerciseIndices");
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
  });

  final ThemeData theme;
  final List<String> daysOfWeek;
  final int i;
  final TextStyle headingStyle;
  final Split split;
  final TextStyle textStyle;
  final MyAppState appState;

  void viewDayOfWeek(MyAppState appState, int dayIndex) {
    appState.currentDayIndex = dayIndex;
    appState.changePage(7);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 70,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: resolveColor(theme.colorScheme.primaryContainer),
              surfaceTintColor:
                  resolveColor(theme.colorScheme.primaryContainer)),
          onPressed: () {
            viewDayOfWeek(appState, i);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${daysOfWeek[i]}:',
                  style: headingStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                Spacer(),
                Expanded(
                  child: Text(
                    split.trainingDays[i].toString(),
                    style: textStyle,
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