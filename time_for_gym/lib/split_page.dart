import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

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
      body: ListView(
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
                        color: appState.onBackground,
                      ),
                      label: Text("Restore Previous Split", style: textStyle))
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

class SplitCard extends StatelessWidget {
  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  void viewDayOfWeek(var appState, int dayIndex) {
    appState.currentDayIndex = dayIndex;
    appState.changePage(7);
  }

  void regenerateSplit(var appState) {
    appState.setMakeNewSplit(true);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                appState.shiftSplit(-1);
              },
              label: Text(
                "Shift Up",
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                appState.shiftSplit(1);
              },
              label: Text(
                "Shift Down",
                style: headingStyle,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        for (int i = 0; i < 7; i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 70,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        resolveColor(theme.colorScheme.primaryContainer),
                    surfaceTintColor:
                        resolveColor(theme.colorScheme.primaryContainer)),
                onPressed: () {
                  viewDayOfWeek(appState, i);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${daysOfWeek[i]}:',
                          style: headingStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          appState.currentSplit.trainingDays[i].toString(),
                          style: textStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
