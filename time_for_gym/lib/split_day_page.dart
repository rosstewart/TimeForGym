// import 'dart:ffi';

// import 'package:flutter/gestures.dart';

// import 'dart:isolate';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/services.dart';
import 'package:time_for_gym/active_workout.dart';
import 'package:time_for_gym/activity.dart';
import 'package:time_for_gym/gym_page.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:time_for_gym/individual_exercise_page.dart';
// import 'package:time_for_gym/individual_exercise_page.dart';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/split.dart';
import 'package:time_for_gym/active_workout_window.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'gym.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

// ignore: constant_identifier_names
const double WAIT_MULTIPLIER_TO_MINUTES = 10.0;

class SplitDayPage extends StatefulWidget {
  final int dayIndex;
  // int scrollingHeight = 532;

  SplitDayPage(this.dayIndex);

  @override
  State<SplitDayPage> createState() => _SplitDayPageState();
}

class _SplitDayPageState extends State<SplitDayPage> {
  final Map<int, PageController> _pageControllers = {};
  final Map<int, int> _currentDotIndices = {};

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

  void cancelReorderChanges(MyAppState appState) {
    appState.toSplitDayReorderMode(false);
  }

  void saveReorderChanges(MyAppState appState) {
    appState.saveReorderChanges();
  }

  void _dismissKeyboard() {
    // Unfocus the text fields when tapped outside
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    final GymOpeningHours? gymOpeningHours;
    if (appState.userGym != null && appState.userGym!.openingHours != null) {
      gymOpeningHours = GymOpeningHours(appState.userGym!.openingHours!);
    } else {
      gymOpeningHours = null;
    }

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

    final int numNonSupersets = trainingDays[widget.dayIndex]
        .isSupersettedWithLast
        .where((element) => element == false)
        .length;
    // Draggable cards for reorder mode, only include the first exercise of supersets
    List<SplitMuscleGroupCard> muscleGroupCards = [];

    if (appState.splitDayReorderMode) {
      int totalSetIndex = 0;
      for (int i = 0; i < numNonSupersets; i++) {
        while (trainingDays[widget.dayIndex]
            .isSupersettedWithLast[totalSetIndex]) {
          totalSetIndex++;
        }
        muscleGroupCards.add(SplitMuscleGroupCard(
          key: ValueKey(i), // Assign a unique key to each SplitMuscleGroupCard
          muscleGroup:
              split.trainingDays[widget.dayIndex].muscleGroups[totalSetIndex],
          splitDayCardIndex: totalSetIndex,
          split: split,
          exerciseIndices: exerciseIndices,
          isDraggable: true,
          dayIndex: widget.dayIndex,
          addSupersetOption: false,
          gymOpeningHours: gymOpeningHours,
          setSplitDayPageState: setState,
        ));
        totalSetIndex++;
      }
    }

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final textStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return GestureDetector(
      onTap: _dismissKeyboard, // Handle tap gesture
      child: SwipeBack(
        swipe: true,
        appState: appState,
        index: 6,
        child: Scaffold(
          appBar: AppBar(
            leading: Back(appState: appState, index: 6),
            leadingWidth: 70,
            title: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    daysOfWeek[widget.dayIndex],
                    style: titleStyle,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '-',
                    style: titleStyle,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  if (!appState.splitDayReorderMode)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 180,
                      ),
                      child: Text(
                        trainingDays[widget.dayIndex].splitDay,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                        maxLines: 3,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (appState.splitDayReorderMode)
                    SizedBox(
                      width: 120,
                      child: Form(
                        key: _titleFormKey,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 120,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: theme.colorScheme.primaryContainer),
                            padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                            child: TextFormField(
                              decoration: InputDecoration(
                                floatingLabelStyle: TextStyle(fontSize: 0),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: InputBorder.none,
                              ),
                              initialValue:
                                  trainingDays[widget.dayIndex].splitDay,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.onBackground
                                      .withOpacity(0.65)),
                              textAlign: TextAlign.center,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null; // Return null to indicate the input is valid
                              },
                              onChanged: (value) {
                                setState(() {
                                  trainingDays[widget.dayIndex].splitDay =
                                      value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  Spacer(flex: 2),
                  if (!appState.splitDayReorderMode)
                    GestureDetector(
                        onTapDown: (tapDownDetails) {
                          showOptionsDropdown(
                              context,
                              tapDownDetails.globalPosition,
                              appState,
                              trainingDays[widget.dayIndex]);
                        },
                        child: Container(
                            decoration: BoxDecoration(),
                            child: Icon(Icons.more_horiz,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(.65))))
                ],
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          body: Stack(children: [
            OuterScroll(
              scrollMode: appState.splitDayReorderMode,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: appState.splitDayReorderMode ? 20 : 0,
                    ),
                    if (!appState.splitDayReorderMode)
                      Center(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // children: [
                        // ElevatedButton.icon(
                        //     style: ButtonStyle(
                        //         backgroundColor: resolveColor(
                        //             theme.colorScheme.primaryContainer),
                        //         surfaceTintColor: resolveColor(
                        //             theme.colorScheme.primaryContainer)),
                        //     onPressed: () {
                        //       appState.toSplitDayReorderMode(true);
                        //     },
                        //     icon: Icon(Icons.edit,
                        //         color: theme.colorScheme.primary, size: 16),
                        //     label: Text(
                        //       'Edit',
                        //       style: theme.textTheme.labelSmall!.copyWith(
                        //           color: theme.colorScheme.onBackground),
                        //     )),
                        child: TextButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    resolveColor(theme.colorScheme.primary),
                                surfaceTintColor:
                                    resolveColor(theme.colorScheme.primary)),
                            onPressed: () {
                              // Don't include exercises already in the split day
                              // Don't add exercise as a superset
                              _showSearchExercisesWindow(
                                  context,
                                  appState,
                                  appState.muscleGroups.values
                                      .toList()
                                      .expand((innerList) => innerList)
                                      .toList()
                                      .where((element) => !split
                                          .trainingDays[widget.dayIndex]
                                          .exerciseNames
                                          .contains(element.name))
                                      .toList(),
                                  widget.dayIndex,
                                  null,
                                  null);
                            },
                            icon: Icon(Icons.add,
                                color: theme.colorScheme.onBackground,
                                size: 14),
                            label: Text(
                              'Add exercise',
                              style: theme.textTheme.labelSmall!.copyWith(
                                  color: theme.colorScheme.onBackground,
                                  fontSize: 10),
                            )),
                        // ],
                      ),
                    if (appState.splitDayReorderMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor: resolveColor(
                                          theme.colorScheme.primaryContainer),
                                      surfaceTintColor: resolveColor(
                                          theme.colorScheme.primaryContainer)),
                                  onPressed: () {
                                    cancelReorderChanges(appState);
                                  },
                                  icon: Icon(Icons.close,
                                      color: theme.colorScheme.primary,
                                      size: 16),
                                  label: Text(
                                    "Cancel",
                                    style: theme.textTheme.labelSmall!.copyWith(
                                      color: theme.colorScheme.onBackground,
                                    ),
                                  )),
                              Spacer(),
                              TextButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor: resolveColor(
                                          theme.colorScheme.primaryContainer),
                                      surfaceTintColor: resolveColor(
                                          theme.colorScheme.primaryContainer)),
                                  onPressed: () {
                                    if (_titleFormKey.currentState!
                                        .validate()) {
                                      saveReorderChanges(appState);
                                    }
                                  },
                                  icon: Icon(Icons.save_alt,
                                      color: theme.colorScheme.primary,
                                      size: 16),
                                  label: Text(
                                    "Save",
                                    style: theme.textTheme.labelSmall!.copyWith(
                                      color: theme.colorScheme.onBackground,
                                    ),
                                  ))
                            ]),
                      ),
                    if (appState
                        .splitDayReorderMode) // Drag and drop muscle group cards
                      Column(
                        children: [
                          // Add to end, then reorder
                          SizedBox(height: 15),
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 298,
                            child: ReorderableListView(
                              children: muscleGroupCards,
                              onReorder: (oldCardIndex, newCardIndex) {
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
                                    if (newCardIndex > oldCardIndex) {
                                      newCardIndex -=
                                          1; // Adjust the index when moving an item down
                                    }

                                    int splitDayCardIndex =
                                        muscleGroupCards[oldCardIndex]
                                            .getSplitDayCardIndex();
                                    int newSplitDayCardIndex;
                                    if (muscleGroupCards.length >
                                        newCardIndex) {
                                      newSplitDayCardIndex =
                                          muscleGroupCards[newCardIndex]
                                              .getSplitDayCardIndex();
                                    } else {
                                      newSplitDayCardIndex =
                                          muscleGroupCards.length;
                                    }
                                    final List<dynamic>
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier =
                                        appState.removeTempMuscleGroupFromSplit(
                                            widget.dayIndex, splitDayCardIndex);

                                    List<dynamic>? supersetExerciseInfo;
                                    // Check next exercise to see if it's a superset, old index gets shifted into superset spot
                                    if (split.trainingDays[widget.dayIndex]
                                                .isSupersettedWithLast.length >
                                            splitDayCardIndex &&
                                        split.trainingDays[widget.dayIndex]
                                                .isSupersettedWithLast[
                                            splitDayCardIndex]) {
                                      supersetExerciseInfo = appState
                                          .removeTempMuscleGroupFromSplit(
                                              widget.dayIndex,
                                              splitDayCardIndex);
                                    }
                                    final SplitMuscleGroupCard card =
                                        muscleGroupCards.removeAt(oldCardIndex);
                                    muscleGroupCards.insert(newCardIndex, card);

                                    if (supersetExerciseInfo != null) {
                                      // Shift newSplitDayCardIndex by 1
                                      if (newSplitDayCardIndex >
                                          splitDayCardIndex) {
                                        newSplitDayCardIndex--;
                                      } else if (newSplitDayCardIndex >
                                          splitDayCardIndex) {
                                        newSplitDayCardIndex++;
                                      }
                                    }
                                    appState.addTempMuscleGroupToSplit(
                                        widget.dayIndex,
                                        newSplitDayCardIndex,
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier[
                                            0],
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier[
                                            1],
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier[
                                            2],
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier[
                                            3],
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier[
                                            4],
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier[
                                            5],
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier[
                                            6],
                                        muscleGroupAndExerciseIndexAndNumSetsAndIdentifier[
                                            7]);

                                    if (supersetExerciseInfo != null) {
                                      // Add superset also
                                      appState.addTempMuscleGroupToSplit(
                                          widget.dayIndex,
                                          newSplitDayCardIndex + 1,
                                          supersetExerciseInfo[0],
                                          supersetExerciseInfo[1],
                                          supersetExerciseInfo[2],
                                          supersetExerciseInfo[3],
                                          supersetExerciseInfo[4],
                                          supersetExerciseInfo[5],
                                          supersetExerciseInfo[6],
                                          supersetExerciseInfo[7]);
                                    }

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
                        // If i is a superset, don't show as it was shown in the previous row
                        split.trainingDays[widget.dayIndex]
                                    .isSupersettedWithLast[i] ==
                                false
                            ? ((i <
                                        split.trainingDays[widget.dayIndex]
                                                .muscleGroups.length -
                                            1 &&
                                    split.trainingDays[widget.dayIndex]
                                            .isSupersettedWithLast[i + 1] ==
                                        true)

                                // If a superset vs not a superset
                                ? Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Superset   ',
                                                style: titleStyle.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                                textAlign: TextAlign.center),
                                            if (split
                                                    .trainingDays[
                                                        widget.dayIndex]
                                                    .setsPerMuscleGroup[i] !=
                                                1)
                                              Text(
                                                '-  ${split.trainingDays[widget.dayIndex].setsPerMuscleGroup[i]} Sets',
                                                textAlign: TextAlign.center,
                                                style: textStyle,
                                              ),
                                            if (split
                                                    .trainingDays[
                                                        widget.dayIndex]
                                                    .setsPerMuscleGroup[i] ==
                                                1)
                                              Text(
                                                '-  1 Set',
                                                textAlign: TextAlign.center,
                                                style: textStyle,
                                              ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 0, 0, 0),
                                              child: Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      // Increment number of sets
                                                      if (split
                                                              .trainingDays[
                                                                  widget
                                                                      .dayIndex]
                                                              .setsPerMuscleGroup[i] <
                                                          10) {
                                                        setState(() {
                                                          split
                                                              .trainingDays[
                                                                  widget
                                                                      .dayIndex]
                                                              .setsPerMuscleGroup[i]++;
                                                          split
                                                                  .trainingDays[
                                                                      widget
                                                                          .dayIndex]
                                                                  .setsPerMuscleGroup[
                                                              i + 1]++;
                                                        });
                                                        appState
                                                            .storeSplitInSharedPreferences();
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons.keyboard_arrow_up,
                                                      color: theme
                                                          .colorScheme.primary,
                                                      size: 14,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      // Decrement number of sets
                                                      if (split
                                                              .trainingDays[
                                                                  widget
                                                                      .dayIndex]
                                                              .setsPerMuscleGroup[i] >
                                                          1) {
                                                        setState(() {
                                                          split
                                                              .trainingDays[
                                                                  widget
                                                                      .dayIndex]
                                                              .setsPerMuscleGroup[i]--;
                                                          split
                                                                  .trainingDays[
                                                                      widget
                                                                          .dayIndex]
                                                                  .setsPerMuscleGroup[
                                                              i + 1]--;
                                                        });
                                                        appState
                                                            .storeSplitInSharedPreferences();
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: theme
                                                          .colorScheme.primary,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 230,
                                              child: PageView(
                                                controller:
                                                    _pageControllers[i] ??
                                                        (_pageControllers[i] =
                                                            PageController()),
                                                onPageChanged: (int index) {
                                                  setState(() {
                                                    _currentDotIndices[i] =
                                                        index;
                                                  });
                                                },
                                                children: [
                                                  // First card
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: SplitMuscleGroupCard(
                                                      muscleGroup: split
                                                          .trainingDays[
                                                              widget.dayIndex]
                                                          .muscleGroups[i],
                                                      splitDayCardIndex: i,
                                                      split: split,
                                                      exerciseIndices:
                                                          exerciseIndices,
                                                      isDraggable: false,
                                                      dayIndex: widget.dayIndex,
                                                      addSupersetOption: false,
                                                      gymOpeningHours:
                                                          gymOpeningHours,
                                                      setSplitDayPageState:
                                                          setState,
                                                    ),
                                                  ),
                                                  // Second card
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: SplitMuscleGroupCard(
                                                      muscleGroup: split
                                                          .trainingDays[
                                                              widget.dayIndex]
                                                          .muscleGroups[i + 1],
                                                      splitDayCardIndex: i + 1,
                                                      split: split,
                                                      exerciseIndices:
                                                          exerciseIndices,
                                                      isDraggable: false,
                                                      dayIndex: widget.dayIndex,
                                                      addSupersetOption: false,
                                                      gymOpeningHours:
                                                          gymOpeningHours,
                                                      setSplitDayPageState:
                                                          setState,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            DotsIndicator(
                                              key: Key('$i'),
                                              dotsCount: 2,
                                              position: _currentDotIndices[i] ??
                                                  (_currentDotIndices[i] = 0),
                                              decorator: DotsDecorator(
                                                activeColor:
                                                    theme.colorScheme.primary,
                                                size: const Size.square(8.0),
                                                activeSize:
                                                    const Size.square(8.0),
                                                activeShape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                            ),
                                            // SizedBox(height: 10),
                                          ],
                                        ),
                                        // ),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: SplitMuscleGroupCard(
                                      muscleGroup: split
                                          .trainingDays[widget.dayIndex]
                                          .muscleGroups[i],
                                      splitDayCardIndex: i,
                                      split: split,
                                      exerciseIndices: exerciseIndices,
                                      isDraggable: false,
                                      dayIndex: widget.dayIndex,
                                      addSupersetOption: true,
                                      gymOpeningHours: gymOpeningHours,
                                      setSplitDayPageState: setState,
                                    ),
                                  ))
                            : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
            if (appState.activeWorkout == null &&
                split.trainingDays[widget.dayIndex].muscleGroups.isNotEmpty)
              Positioned(
                bottom: 10,
                left: 40,
                right: 40,
                child: GestureDetector(
                  onTap: () {
                    // Start new workout if null
                    showActiveWorkoutWindow(
                        context,
                        appState,
                        ActiveWorkout(
                            dayIndex: widget.dayIndex,
                            split: split,
                            trainingDay: split.trainingDays[widget.dayIndex],
                            timeStarted: DateTime.now()),
                        widget.dayIndex);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(.9),
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.all(12.0),
                    child: Text('Start workout',
                        style: titleStyle, textAlign: TextAlign.center),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  void showOptionsDropdown(BuildContext context, Offset tapPosition,
      MyAppState appState, TrainingDay trainingDay) {
    final theme = Theme.of(context);
    final labelStyle =
        TextStyle(color: theme.colorScheme.onBackground, fontSize: 10);

    showMenu<String>(
      color: theme.colorScheme.primaryContainer,
      surfaceTintColor: theme.colorScheme.primaryContainer,
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Edit',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.edit_outlined,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Edit',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Analyze Workout',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.analytics_outlined,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Analyze Workout',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Edit') {
        appState.toSplitDayReorderMode(true);
      } else if (value == 'Analyze Workout') {
        _showWorkoutAnalysis(context, appState, trainingDay);
      }
    });
  }
}

// ignore: must_be_immutable
class SplitMuscleGroupCard extends StatefulWidget {
  SplitMuscleGroupCard(
      {super.key,
      required this.muscleGroup,
      required this.splitDayCardIndex,
      required this.split,
      required this.exerciseIndices,
      required this.isDraggable,
      required this.dayIndex,
      required this.addSupersetOption,
      required this.gymOpeningHours,
      required this.setSplitDayPageState});

  final String muscleGroup;
  final int splitDayCardIndex;
  final Split split;
  final List<List<int>> exerciseIndices;
  final bool isDraggable;
  int exerciseIndex = 0;
  final int dayIndex;
  final bool addSupersetOption;
  GymOpeningHours? gymOpeningHours;
  final StateSetter setSplitDayPageState;

  int getSplitDayCardIndex() {
    return splitDayCardIndex;
  }

  @override
  State<SplitMuscleGroupCard> createState() => _SplitMuscleGroupCardState();
}

class _SplitMuscleGroupCardState extends State<SplitMuscleGroupCard>
    with SingleTickerProviderStateMixin {
  bool showPreviousReps = false;
  bool showPreviousWeight = false;
  late List<String> previousWeights;
  late List<String> previousReps;

  final _trackTopSetFormKey = GlobalKey<FormState>();

  late List<Widget?> weightSuffixIcons;
  late List<Widget?> repsSuffixIcons;

  bool hasSavedTopSet = false;
  bool hasSavedRestTimes = false;

  Timer? _timer;
  Timer? _restSavedTimer;

  late List<TextEditingController> setsWeightControllers;
  late List<TextEditingController> setsRepsControllers;
  late int numSets;

  Widget suffixIcon =
      Text('*', style: TextStyle(color: Colors.red, fontSize: 20));

  List<Exercise> similarExercises = [];

  TextEditingController restFormMinutesController = TextEditingController();
  TextEditingController restFormSecondsController = TextEditingController();
  String? previousRestMinutes;
  String? previousRestSeconds;
  Widget? restMinutesSuffixIcon;
  Widget? restSecondsSuffixIcon;

  late int previousSeconds;
  late int previousMinutes;
  late TabController _tabController;
  late PageController _pageController;
  Image? musclesWorkedImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _pageController = PageController(initialPage: 0);
    _tabController.addListener(_handleTabChange);
    updatePreviousSecondsAndMinutes();
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

  void updatePreviousSecondsAndMinutes() {
    setState(() {
      previousSeconds = widget.split.trainingDays[widget.dayIndex]
          .restTimeInSeconds[widget.splitDayCardIndex];
      previousMinutes = previousSeconds ~/ 60;
      previousSeconds %= 60;
      previousRestMinutes = previousMinutes >= 10
          ? previousMinutes.toString()
          : '0$previousMinutes';
      previousRestSeconds = previousSeconds >= 10
          ? previousSeconds.toString()
          : '0$previousSeconds';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restSavedTimer?.cancel();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    _pageController.animateToPage(
      _tabController.index == 0 ? 1 : 0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void toExercise(MyAppState appState, Exercise exercise) {
    appState.currentExerciseFromSplitDayPage = exercise;
    appState.changePageToExercise(exercise);
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
    bool isValidated = true;
    final DateTime now = DateTime.now();
    final DateTime currentDay = DateTime.parse(
        '${now.year}${now.month > 9 ? now.month : '0${now.month}'}${now.day > 9 ? now.day : '0${now.day}'}');
    final int millisecondsSinceEpoch = currentDay.millisecondsSinceEpoch;

    //TODO - Add kilo i/o functionality

    if (!showMoreSets) {
      if (weights[0].isNotEmpty &&
          // weights[0] != '0' &&
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
        if (weights[0].isEmpty) {
          // || weights[0] == '0') {
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
          if (previousOneRepMax != null) {
            // Make new activity for the user to celebrate their PR
            appState.currentUser.activities.insert(
                0,
                Activity(
                    username: appState.currentUser.username,
                    type: 'auto_pr',
                    title: 'Hit a new PR!',
                    description:
                        '${currentExercise.name}: ${int.parse(weights[0])} lbs for ${int.parse(reps[0])} reps\nNew estimated one-rep-max: $newOneRepMax',
                    trainingDay: null,
                    millisecondsFromEpoch: now.millisecondsSinceEpoch,
                    totalMinutesDuration: 0,
                    usernamesThatLiked: [],
                    commentsFromEachUsername: {},
                    pictureUrl: null,
                    picture: null,
                    private: false,
                    prsHit: null,
                    gym: appState.userGym?.name,
                    repRanges: []));
            appState.storeDataInFirestore();
          }
          currentExercise.userOneRepMax = newOneRepMax;

          print('updated one rep max');
        }

        setState(() {
          previousWeights[0] = weights[0];
          previousReps[0] = reps[0];
        });

        // Check if user has submitted one rep max history today, only save 1 per day
        int sameDayMilliseconds =
            currentExercise.userOneRepMaxHistory.keys.firstWhere(
          (milliseconds) {
            DateTime time = DateTime.fromMillisecondsSinceEpoch(milliseconds);
            return (time.day == currentDay.day &&
                time.month == currentDay.month &&
                time.year == currentDay.year);
          },
          orElse: () {
            return -1;
          },
        );

        // Save the new one rep max of the day, rather than the all-time
        if (sameDayMilliseconds == -1) {
          currentExercise.userOneRepMaxHistory[millisecondsSinceEpoch] =
              newOneRepMax;
        } else {
          // Put best of both maxes
          currentExercise.userOneRepMaxHistory[sameDayMilliseconds] = math.max(
              newOneRepMax,
              currentExercise.userOneRepMaxHistory[sameDayMilliseconds] ?? -1);
        }
        appState.submitExercisePopularityDataToFirebase(
            appState.currentUser.username,
            currentExercise.name,
            currentExercise.mainMuscleGroup,
            currentExercise.userRating,
            currentExercise.userOneRepMax,
            currentExercise.splitWeightAndReps,
            currentExercise.splitWeightPerSet,
            currentExercise.splitRepsPerSet,
            currentExercise.userOneRepMaxHistory);
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
        int bestOneRepMaxFromSubmission = -1;
        int? bestWeight;
        int? bestReps;
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
          if (int.parse(reps[i]) <= 30 &&
              newOneRepMax > bestOneRepMaxFromSubmission) {
            bestOneRepMaxFromSubmission = newOneRepMax;
            bestWeight = int.parse(weights[i]);
            bestReps = int.parse(reps[i]);
          }
        }
        if (previousOneRepMax != null &&
            bestOneRepMaxFromSubmission > previousOneRepMax &&
            bestWeight != null &&
            bestReps != null) {
          // Make new activity for the user to celebrate their PR
          appState.currentUser.activities.insert(
              0,
              Activity(
                  username: appState.currentUser.username,
                  type: 'auto_pr',
                  title: 'Hit a new PR on ${currentExercise.name}!',
                  description:
                      '$bestWeight lbs for $bestReps reps\nEstimated one-rep max: $bestOneRepMaxFromSubmission lbs',
                  trainingDay: null,
                  millisecondsFromEpoch: now.millisecondsSinceEpoch,
                  totalMinutesDuration: 0,
                  usernamesThatLiked: [],
                  commentsFromEachUsername: {},
                  pictureUrl: null,
                  picture: null,
                  private: false,
                  prsHit: null,
                  gym: appState.userGym?.name,
                  repRanges: []));
          appState.storeDataInFirestore();
        }

        setState(() {
          previousWeights = weights;
          previousReps = reps;
          // for (int i = 0; i < numSets; i++) {
          //   previousWeights[i] = weights[i];
          //   previousReps[i] = reps[i];
          // }
        });

        if (bestOneRepMaxFromSubmission != -1) {
          // Check if user has submitted one rep max history today, only save 1 per day
          // Check if user has submitted one rep max history today, only save 1 per day
          int sameDayMilliseconds =
              currentExercise.userOneRepMaxHistory.keys.firstWhere(
            (milliseconds) {
              DateTime time = DateTime.fromMillisecondsSinceEpoch(milliseconds);
              return (time.day == currentDay.day &&
                  time.month == currentDay.month &&
                  time.year == currentDay.year);
            },
            orElse: () {
              return -1;
            },
          );

          // Save the new one rep max of the day, rather than the all-time
          if (sameDayMilliseconds == -1) {
            currentExercise.userOneRepMaxHistory[millisecondsSinceEpoch] =
                bestOneRepMaxFromSubmission;
          } else {
            // Put best of both maxes
            currentExercise.userOneRepMaxHistory[sameDayMilliseconds] =
                math.max(
                    bestOneRepMaxFromSubmission,
                    currentExercise.userOneRepMaxHistory[sameDayMilliseconds] ??
                        -1);
          }
        }
        appState.submitExercisePopularityDataToFirebase(
            appState.currentUser.username,
            currentExercise.name,
            currentExercise.mainMuscleGroup,
            currentExercise.userRating,
            currentExercise.userOneRepMax,
            currentExercise.splitWeightAndReps,
            currentExercise.splitWeightPerSet,
            currentExercise.splitRepsPerSet,
            currentExercise.userOneRepMaxHistory);
        print('submitted split weight & rep data to firebase');
      }
    }
  }

  void showPopUpSimilarExercises(BuildContext context, MyAppState appState,
      StateSetter setSplitDayPageState, Exercise previousExercise) {
    final theme = Theme.of(context);

    widget.exerciseIndex =
        widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex];
    List<Exercise> similarExercisesInGym = similarExercises.toList();
    String availableText;
    String notAvailableText;

    switch (widget.split.equipmentLevel) {
      case 0:
        // Bodyweight exercises only
        similarExercisesInGym.removeWhere((element) =>
            element.resourcesRequired != null &&
            element.resourcesRequired!.isNotEmpty &&
            element.resourcesRequired![0] != 'None' &&
            element.resourcesRequired![0] != 'Bodyweight' &&
            element.resourcesRequired![0] != 'Pull-Up Bar' &&
            element.resourcesRequired![0] != 'Parallel Bars');
        availableText = 'Bodyweight';
        notAvailableText = 'Not bodyweight';
        break;
      case 1:
        // Dumbbell and bodyweight only
        similarExercisesInGym.removeWhere((element) =>
            element.resourcesRequired != null &&
            element.resourcesRequired!.isNotEmpty &&
            element.resourcesRequired![0] != 'None' &&
            element.resourcesRequired![0] != 'Bodyweight' &&
            element.resourcesRequired![0] != 'Pull-Up Bar' &&
            element.resourcesRequired![0] != 'Parallel Bars' &&
            !element.resourcesRequired!.contains('Dumbbells'));
        availableText = 'Dumbbell-Only';
        notAvailableText = 'Not Dumbbell-Only';
        break;
      case 2:
        // Only select exercises that are available at the gym
        if (appState.userGym != null) {
          // canSupportExercise checks if resources available or machines available are empty
          similarExercisesInGym.removeWhere(
              (element) => !appState.userGym!.canSupportExercise(element));
          if (appState.userGym!.resourcesAvailable.isNotEmpty) {
            availableText = 'Available in Your Gym';
            notAvailableText = 'Not Available in Your Gym';
          } else {
            availableText = 'No Gym Data';
            notAvailableText = 'No Gym Data';
          }
        } else {
          availableText = 'No Gym Selected';
          notAvailableText = 'No Gym selected';
        }
        break;
      default:
        print('ERROR - Equipment Level');
        return;
    }
    int similarExerciseIndex = similarExercises.indexOf(previousExercise);
    if (similarExercises.isNotEmpty && similarExerciseIndex == -1) {
      // User gym has changed, previous exercise not in resources of current gym
      // Set to most popular exercise that satisfies the resource requirements
      Exercise nextExercise;
      if (similarExercisesInGym.isNotEmpty) {
        nextExercise = similarExercisesInGym[0];
      } else {
        nextExercise = similarExercises[0];
      }
      setState(() {
        widget.exerciseIndex = appState
            .muscleGroups[previousExercise.mainMuscleGroup]!
            .indexOf(nextExercise);
        previousExercise = nextExercise;
        // Reset previous weights and reps
        previousWeights =
            List.filled(previousWeights.length, '', growable: true);
        previousReps = List.filled(previousReps.length, '', growable: true);
      });
      // Set the "default" exercise to view in that muscle group of the split
      widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex] =
          widget.exerciseIndex;
      // print(widget.exerciseIndices);
      appState.storeSplitInSharedPreferences();
      appState.saveSplitDayExerciseIndicesData();
    }
    Exercise selectedExercise = previousExercise;
    final TextStyle labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final TextStyle secondarySmallLabelStyle = labelStyle.copyWith(
        color: theme.colorScheme.secondary.withOpacity(.65), fontSize: 10);
    final TextStyle primarySmallLabelStyle =
        secondarySmallLabelStyle.copyWith(color: theme.colorScheme.primary);
    // Move available exercises to front
    List<Exercise> firstExercises = similarExercises
        .where((element) => similarExercisesInGym.contains(element))
        .toList();
    similarExercises.removeWhere((element) => firstExercises.contains(element));
    similarExercises.insertAll(0, firstExercises);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      Text(
                        'Select an Exercise',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium!
                            .copyWith(color: theme.colorScheme.onBackground),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      IconButton(
                        style: ButtonStyle(
                          backgroundColor: resolveColor(
                            theme.colorScheme.primaryContainer,
                          ),
                          surfaceTintColor: resolveColor(
                            theme.colorScheme.primaryContainer,
                          ),
                        ),
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        style: ButtonStyle(
                          backgroundColor: resolveColor(
                            theme.colorScheme.primaryContainer,
                          ),
                          surfaceTintColor: resolveColor(
                            theme.colorScheme.primaryContainer,
                          ),
                        ),
                        onPressed: () {
                          // print(widget.exerciseIndices);
                          setSplitDayPageState(() {
                            widget.exerciseIndex = appState
                                .muscleGroups[previousExercise.mainMuscleGroup]!
                                .indexOf(selectedExercise);
                            previousExercise = selectedExercise;
                            // Reset previous weights and reps
                            previousWeights = List.filled(
                                previousWeights.length, '',
                                growable: true);
                            previousReps = List.filled(previousReps.length, '',
                                growable: true);
                          });
                          // Set the "default" exercise to view in that muscle group of the split
                          widget.exerciseIndices[widget.dayIndex]
                              [widget.splitDayCardIndex] = widget.exerciseIndex;
                          // print(widget.exerciseIndices);
                          appState.storeSplitInSharedPreferences();
                          appState.saveSplitDayExerciseIndicesData();
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.check,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  if (widget.split.equipmentLevel == 2 &&
                      appState.userGym != null)
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: resolveColor(
                                appState.userGym!.resourcesAvailable.isNotEmpty
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.primary),
                            surfaceTintColor: resolveColor(
                                appState.userGym!.resourcesAvailable.isNotEmpty
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.primary)),
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                          appState.currentGym = appState.userGym;
                          appState.changePage(9);
                        },
                        child: Text(
                          appState.userGym!.resourcesAvailable.isNotEmpty
                              ? 'Your Gym'
                              : 'Enter Gym Data',
                          style: primarySmallLabelStyle.copyWith(
                              color: appState
                                      .userGym!.resourcesAvailable.isNotEmpty
                                  ? theme.colorScheme.onBackground
                                      .withOpacity(.65)
                                  : theme.colorScheme.onBackground),
                        )),
                  if (widget.split.equipmentLevel == 2 &&
                      appState.userGym == null)
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              resolveColor(theme.colorScheme.primary),
                          surfaceTintColor:
                              resolveColor(theme.colorScheme.primary)),
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                        appState.changePage(0);
                      },
                      child: Text('Select a Gym',
                          style: primarySmallLabelStyle.copyWith(
                            color: theme.colorScheme.onBackground,
                          )),
                    )
                ],
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context)
                  .size
                  .width, // Adjust the width as needed
              height: MediaQuery.of(context).size.height *
                  0.6, // Adjust the height as needed
              child: GridView.count(
                childAspectRatio: 0.95,
                crossAxisCount: 2, // Adjust the number of columns as needed
                children: List.generate(
                  similarExercises.length,
                  (index) {
                    String expectedWaitTime;
                    if (appState.userGym == null ||
                        widget.gymOpeningHours == null) {
                      expectedWaitTime = '';
                    } else {
                      String currentlyOpenString;
                      DateTime now = DateTime.now();
                      double percentCapacity =
                          appState.avgGymCrowdData[now.weekday - 1][now.hour] /
                              12.0;
                      if (appState.userGym!.openingHours == null) {
                        // Assume it's open
                        // print('Estimated ${(percentCapacity * 100).toInt()}% capactiy');
                        expectedWaitTime = (WAIT_MULTIPLIER_TO_MINUTES *
                                similarExercises[index].waitMultiplier *
                                percentCapacity)
                            .toStringAsFixed(0);
                      } else {
                        currentlyOpenString =
                            widget.gymOpeningHours!.getCurrentlyOpenString();
                        // 'Open - ...' or 'Open 24 hours'
                        if (currentlyOpenString.startsWith('Open ')) {
                          // print('Estimated ${(percentCapacity * 100).toInt()}% capactiy');
                          expectedWaitTime = (WAIT_MULTIPLIER_TO_MINUTES *
                                  similarExercises[index].waitMultiplier *
                                  percentCapacity)
                              .toStringAsFixed(0);
                        } else {
                          // Closed
                          expectedWaitTime = '';
                        }
                      }
                    }
                    final bool gymContainsExercise =
                        similarExercisesInGym.contains(similarExercises[index]);
                    return SizedBox(
                      // height: 120,
                      // width: 90,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (selectedExercise !=
                                  (similarExercises[index])) {
                                setState(() {
                                  selectedExercise = (similarExercises[index]);
                                });
                              }
                            },
                            child: SizedBox(
                                height: 70,
                                width: 70,
                                child: Stack(children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: theme.colorScheme.onBackground),
                                    child: ImageContainer(
                                        exercise: similarExercises[index]),
                                  ),
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        selectedExercise ==
                                                similarExercises[index]
                                            ? Icons.check_circle
                                            : Icons.check_circle_outline,
                                        color: theme.colorScheme.primary,
                                        size: 16,
                                      )),
                                ])),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            similarExercises[index].name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: labelStyle,
                          ),
                          if (widget.split.equipmentLevel < 2 ||
                              (appState.userGym != null &&
                                  appState
                                      .userGym!.resourcesAvailable.isNotEmpty))
                            SizedBox(
                              height: 3,
                            ),
                          if (widget.split.equipmentLevel < 2)
                            Text(
                              gymContainsExercise
                                  ? availableText
                                  : notAvailableText,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: gymContainsExercise
                                  ? primarySmallLabelStyle
                                  : secondarySmallLabelStyle,
                            ),
                          if (widget.split.equipmentLevel == 2 &&
                              (appState.userGym == null ||
                                  appState.userGym!.resourcesAvailable.isEmpty))
                            Text(
                              notAvailableText,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: secondarySmallLabelStyle,
                            ),
                          if (widget.split.equipmentLevel == 2 &&
                              appState.userGym != null &&
                              appState.userGym!.resourcesAvailable.isNotEmpty)
                            Text(
                              gymContainsExercise
                                  ? availableText
                                  : notAvailableText,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: gymContainsExercise
                                  ? primarySmallLabelStyle
                                  : secondarySmallLabelStyle,
                            ),
                          if ((expectedWaitTime.isNotEmpty &&
                                  gymContainsExercise) ||
                              similarExercises[index].starRating >= 4.0)
                            SizedBox(height: 3),
                          if (expectedWaitTime.isNotEmpty &&
                                  gymContainsExercise ||
                              similarExercises[index].starRating >= 4.0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (expectedWaitTime.isNotEmpty &&
                                    gymContainsExercise)
                                  Text('$expectedWaitTime min',
                                      style: labelStyle.copyWith(
                                          color: int.parse(expectedWaitTime) < 4
                                              ? theme.colorScheme.primary
                                              : (int.parse(expectedWaitTime) < 7
                                                  ? Colors.yellow
                                                  : theme
                                                      .colorScheme.secondary))),
                                if (expectedWaitTime.isNotEmpty &&
                                        gymContainsExercise ||
                                    similarExercises[index].starRating >= 4.0)
                                  SizedBox(width: 5),
                                if (similarExercises[index].starRating >= 4.0)
                                  Icon(Icons.local_fire_department_sharp,
                                      color: theme.colorScheme.primary,
                                      size: 11.5),
                                if (similarExercises[index].starRating >= 4.0)
                                  SizedBox(width: 3),
                                if (similarExercises[index].starRating >= 4.0)
                                  Text("Popular",
                                      style: primarySmallLabelStyle.copyWith(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.65))),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        });
      },
    );
  }

  late Exercise currentExercise;

  @override
  Widget build(BuildContext context) {
    // Superset sets went up
    while (widget.split.trainingDays[widget.dayIndex]
            .setsPerMuscleGroup[widget.splitDayCardIndex] >
        numSets) {
      numSets++;
      setsWeightControllers.add(TextEditingController());
      setsRepsControllers.add(TextEditingController());
      previousWeights.add('');
      previousReps.add('');
      weightSuffixIcons.add(null);
      repsSuffixIcons.add(null);
    }
    // Superset sets went down
    while (widget.split.trainingDays[widget.dayIndex]
            .setsPerMuscleGroup[widget.splitDayCardIndex] <
        numSets) {
      numSets--;
      setsWeightControllers[setsWeightControllers.length - 1].dispose();
      setsWeightControllers.removeLast();
      setsRepsControllers[setsRepsControllers.length - 1].dispose();
      setsRepsControllers.removeLast();
      previousWeights.removeLast();
      previousReps.removeLast();
      weightSuffixIcons.removeLast();
      repsSuffixIcons.removeLast();
    }

    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onBackground, fontWeight: FontWeight.w600);
    final textStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final formHeadingStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final formTextStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    // final greyLabelStyle = theme.textTheme.labelSmall!
    //     .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    // print(appState.splitDayExerciseIndices);

    // If exercise isn't in exercise indices
    if (widget.splitDayCardIndex >=
        widget.exerciseIndices[widget.dayIndex].length) {
      addExerciseToSplit(
          appState,
          widget.split.trainingDays[widget.dayIndex]
              .exerciseIdentifiers[widget.splitDayCardIndex],
          appState.userGym,
          widget.exerciseIndices,
          widget.dayIndex,
          widget.splitDayCardIndex,
          widget.split);
      // Update exercise names
      appState.storeSplitInSharedPreferences();
      // Save new indices
      appState.saveSplitDayExerciseIndicesData();
    }
    currentExercise = appState.muscleGroups[widget.muscleGroup]![
        widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex]];

    // Reset exercise index if out of bounds
    if (widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex] >=
        appState.muscleGroups[widget.muscleGroup]!.length) {
      widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex] = 0;
      print('Resetting exercise index');
    }

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
        previousWeights =
            currentExercise.splitWeightPerSet.map((e) => e.toString()).toList();
        previousReps =
            currentExercise.splitRepsPerSet.map((e) => e.toString()).toList();
        // Fill arrays if numSets was incremented
        if (previousWeights.length < numSets) {
          for (int i = previousWeights.length; i < numSets; i++) {
            previousWeights.add(previousWeights[previousWeights.length - 1]);
          }
        }
        if (previousReps.length < numSets) {
          for (int i = previousReps.length; i < numSets; i++) {
            previousReps.add(previousReps[previousReps.length - 1]);
          }
        }
      }
    }

    bool showMoreSets = (numSets > 1 &&
        previousWeights[0].isNotEmpty &&
        previousReps[0].isNotEmpty);

    // Create musclesWorkedImage if not yet created
    musclesWorkedImage = appState.getMusclesWorkedImage(currentExercise);
    // musclesWorkedImage ??= Image.memory(img.encodePng(applyFloodFill(
    //     appState.defaultMuscleWorkedImage!,
    //     currentExercise.musclesWorked,
    //     currentExercise.musclesWorkedActivation,
    //     appState.imageMuscleLocations)));

    if (similarExercises.isEmpty) {
      similarExercises = appState.muscleGroups[currentExercise.mainMuscleGroup]!
          .where((element) =>
              element.musclesWorked.isNotEmpty &&
              element.musclesWorkedActivation.isNotEmpty &&
              currentExercise.musclesWorked.isNotEmpty &&
              currentExercise.musclesWorkedActivation.isNotEmpty &&
              element.musclesWorked[0] ==
                  currentExercise.musclesWorked[0]) // &&
          // element.musclesWorkedActivation[0] ==
          // previousExercise.musclesWorkedActivation[0])
          .toList();
    }

    if (!widget.isDraggable) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.addSupersetOption)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.split.trainingDays[widget.dayIndex]
                      .setNames[widget.splitDayCardIndex].isNotEmpty)
                    Text(
                        '${widget.split.trainingDays[widget.dayIndex].setNames[widget.splitDayCardIndex]}   ',
                        style: headingStyle,
                        textAlign: TextAlign.center),
                  if (widget.split.trainingDays[widget.dayIndex]
                      .setNames[widget.splitDayCardIndex].isEmpty)
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
                              appState.storeSplitInSharedPreferences();
                            }
                          },
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            color: theme.colorScheme.primary,
                            size: 14,
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
                              appState.storeSplitInSharedPreferences();
                            }
                          },
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: theme.colorScheme.primary,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            Container(
              // height: 300,
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(5),
                color: theme.colorScheme.primaryContainer,
              ),
              child: SizedBox(
                // height: 300,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RotatedBox(
                          quarterTurns: 3,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(16, 16, 16, 1)),
                            height: 40,
                            width: 230,
                            child: TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              unselectedLabelColor:
                                  theme.colorScheme.onBackground,
                              tabs: [Tab(text: 'Sets'), Tab(text: 'Overview')],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(16, 16, 16, 1)),
                          width: 5,
                          height: 230,
                        )
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 45,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              if (!widget.addSupersetOption) Spacer(flex: 4),
                              if (!widget.addSupersetOption)
                                Center(
                                  child: Text(
                                      widget
                                              .split
                                              .trainingDays[widget.dayIndex]
                                              .setNames[
                                                  widget.splitDayCardIndex]
                                              .isNotEmpty
                                          ? widget
                                                  .split
                                                  .trainingDays[widget.dayIndex]
                                                  .setNames[
                                              widget.splitDayCardIndex]
                                          : widget.muscleGroup,
                                      style: headingStyle,
                                      textAlign: TextAlign.center),
                                ),
                              Spacer(flex: 3),
                              GestureDetector(
                                  onTapDown: (tapDownDetails) {
                                    showOptionsDropdown(
                                        context,
                                        tapDownDetails.globalPosition,
                                        appState);
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Icon(Icons.more_horiz,
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.65)),
                                    ),
                                  ))
                            ],
                          ),
                          SizedBox(
                            // IMPORTANT
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: PageView(
                                  scrollDirection: Axis.vertical,
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    _tabController
                                        .animateTo(index == 0 ? 1 : 0);
                                  },
                                  physics: NeverScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      // height: 300,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          toExercise(appState,
                                                              currentExercise);
                                                        },
                                                        child: Column(
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    55,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(5)),
                                                                      height:
                                                                          140,
                                                                      width:
                                                                          140,
                                                                      // Actual size: width: 496, height: 496
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(2),
                                                                        child: ImageContainer(
                                                                            exercise:
                                                                                currentExercise),
                                                                      ),
                                                                    ),
                                                                    if (musclesWorkedImage !=
                                                                        null)
                                                                      Hero(
                                                                        tag:
                                                                            'sdp${widget.splitDayCardIndex}',
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => FullScreenPhoto(photoTag: 'sdp${widget.splitDayCardIndex}', photo: musclesWorkedImage!),
                                                                              ),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                                                            height:
                                                                                140,
                                                                            width:
                                                                                140,
                                                                            // Actual size: width: 496, height: 496
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(2),
                                                                              child: musclesWorkedImage,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
                                                              SizedBox(
                                                                // width: 150,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    55,
                                                                child: Text(
                                                                    // exercise index
                                                                    currentExercise
                                                                        .name,
                                                                    style:
                                                                        labelStyle,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                            ]),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                              child: SizedBox(
                                                height: 160,
                                                child: SingleChildScrollView(
                                                  physics:
                                                      AlwaysScrollableScrollPhysics(),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
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
                                                                    color: theme
                                                                        .colorScheme
                                                                        .tertiaryContainer),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          8,
                                                                          0,
                                                                          8,
                                                                          2),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            32,
                                                                        height:
                                                                            28,
                                                                        child:
                                                                            TextFormField(
                                                                          maxLength:
                                                                              3,
                                                                          style:
                                                                              formTextStyle,
                                                                          controller:
                                                                              setsWeightControllers[0],
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                          ],
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          // textInputAction:
                                                                          //     TextInputAction
                                                                          //         .done,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            counterText:
                                                                                '',
                                                                            border:
                                                                                InputBorder.none,
                                                                            floatingLabelBehavior:
                                                                                FloatingLabelBehavior.never,
                                                                            labelStyle:
                                                                                labelStyle.copyWith(color: theme.colorScheme.onBackground.withOpacity(.65)),
                                                                            labelText:
                                                                                previousWeights[0],
                                                                            // suffix: weightSuffixIcon,
                                                                            // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      if (weightSuffixIcons[
                                                                              0] !=
                                                                          null)
                                                                        weightSuffixIcons[
                                                                            0]!,
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (showMoreSets)
                                                                for (int i = 1;
                                                                    i < numSets;
                                                                    i++)
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            10,
                                                                            0,
                                                                            0),
                                                                    child:
                                                                        Container(
                                                                      // width: 80,
                                                                      // height: 44,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                          color: theme
                                                                              .colorScheme
                                                                              .tertiaryContainer),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            8,
                                                                            0,
                                                                            8,
                                                                            0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 32,
                                                                              height: 28,
                                                                              child: TextFormField(
                                                                                maxLength: 3,
                                                                                style: formTextStyle,
                                                                                controller: setsWeightControllers[i],
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.digitsOnly
                                                                                ],
                                                                                keyboardType: TextInputType.number,
                                                                                // textInputAction:
                                                                                //     TextInputAction
                                                                                //         .done,
                                                                                decoration: InputDecoration(
                                                                                  counterText: '',
                                                                                  border: InputBorder.none,
                                                                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                  labelStyle: labelStyle.copyWith(color: theme.colorScheme.onBackground.withOpacity(.65)),
                                                                                  labelText: previousWeights[i],
                                                                                  // suffix: weightSuffixIcon,
                                                                                  // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            if (weightSuffixIcons[i] !=
                                                                                null)
                                                                              weightSuffixIcons[i]!,
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
                                                                  style: labelStyle.copyWith(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .onBackground
                                                                          .withOpacity(
                                                                              .65),
                                                                      fontSize:
                                                                          8)),
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
                                                                    color: theme
                                                                        .colorScheme
                                                                        .tertiaryContainer),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          8,
                                                                          0,
                                                                          8,
                                                                          2),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            32,
                                                                        height:
                                                                            28,
                                                                        child:
                                                                            TextFormField(
                                                                          maxLength:
                                                                              2,
                                                                          validator:
                                                                              (value) {
                                                                            return validateRepsInput(value);
                                                                          },
                                                                          style:
                                                                              formTextStyle,
                                                                          controller:
                                                                              setsRepsControllers[0],
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                          ],
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          // textInputAction:
                                                                          //     TextInputAction
                                                                          //         .done,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            counterText:
                                                                                '',
                                                                            border:
                                                                                InputBorder.none,
                                                                            floatingLabelBehavior:
                                                                                FloatingLabelBehavior.never,
                                                                            labelStyle:
                                                                                labelStyle.copyWith(color: theme.colorScheme.onBackground.withOpacity(.65)),
                                                                            labelText:
                                                                                previousReps[0],
                                                                            // suffix: repsSuffixIcon,
                                                                            // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      if (repsSuffixIcons[
                                                                              0] !=
                                                                          null)
                                                                        repsSuffixIcons[
                                                                            0]!,
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (showMoreSets)
                                                                for (int i = 1;
                                                                    i < numSets;
                                                                    i++)
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            10,
                                                                            0,
                                                                            0),
                                                                    child:
                                                                        Container(
                                                                      // width: 80,
                                                                      // height: 44,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                          color: theme
                                                                              .colorScheme
                                                                              .tertiaryContainer),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            8,
                                                                            0,
                                                                            8,
                                                                            0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 32,
                                                                              height: 28,
                                                                              child: TextFormField(
                                                                                maxLength: 2,
                                                                                validator: (value) {
                                                                                  return validateRepsInput(value);
                                                                                },
                                                                                style: formTextStyle,
                                                                                controller: setsRepsControllers[i],
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.digitsOnly
                                                                                ],
                                                                                keyboardType: TextInputType.number,
                                                                                // textInputAction:
                                                                                //     TextInputAction
                                                                                //         .done,
                                                                                decoration: InputDecoration(
                                                                                  counterText: '',
                                                                                  border: InputBorder.none,
                                                                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                  labelStyle: labelStyle.copyWith(color: theme.colorScheme.onBackground.withOpacity(.65)),
                                                                                  labelText: previousReps[i],
                                                                                  // suffix: repsSuffixIcon,
                                                                                  // suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            if (repsSuffixIcons[i] !=
                                                                                null)
                                                                              repsSuffixIcons[i]!,
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text('Reps',
                                                                  style: labelStyle.copyWith(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .onBackground
                                                                          .withOpacity(
                                                                              .65),
                                                                      fontSize:
                                                                          8)),
                                                            ],
                                                          ),
                                                          // if (!showMoreSets)
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          // if (!showMoreSets)
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 40,
                                                                child:
                                                                    IconButton(
                                                                  style: ButtonStyle(
                                                                      backgroundColor: resolveColor(theme
                                                                          .colorScheme
                                                                          .secondaryContainer),
                                                                      surfaceTintColor: resolveColor(theme
                                                                          .colorScheme
                                                                          .secondaryContainer)),
                                                                  onPressed:
                                                                      () {
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
                                                                    Icons
                                                                        .save_alt,
                                                                    color: theme
                                                                        .colorScheme
                                                                        .primary,
                                                                    size: 20,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (hasSavedTopSet)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          0,
                                                                          5,
                                                                          0,
                                                                          0),
                                                                  child: Text(
                                                                    'Saved',
                                                                    style: labelStyle
                                                                        .copyWith(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .onBackground
                                                                          .withOpacity(
                                                                              .65),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'Set Rest Period',
                                              style: formHeadingStyle,
                                            ),
                                            SizedBox(height: 10),
                                            Row(children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: theme.colorScheme
                                                        .tertiaryContainer),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 0, 8, 2),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 25,
                                                        height: 28,
                                                        child: TextFormField(
                                                          maxLength: 2,
                                                          style: formTextStyle,
                                                          controller:
                                                              restFormMinutesController,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
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
                                                                previousRestMinutes ??
                                                                    '00',
                                                          ),
                                                        ),
                                                      ),
                                                      if (restMinutesSuffixIcon !=
                                                          null)
                                                        restMinutesSuffixIcon!,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                ' : ',
                                                style: TextStyle(
                                                    color: theme.colorScheme
                                                        .onBackground,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: theme.colorScheme
                                                        .tertiaryContainer),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 0, 8, 2),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 25,
                                                        height: 28,
                                                        child: TextFormField(
                                                          maxLength: 2,
                                                          style: formTextStyle,
                                                          controller:
                                                              restFormSecondsController,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
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
                                                                previousRestSeconds ??
                                                                    '00',
                                                          ),
                                                        ),
                                                      ),
                                                      if (restSecondsSuffixIcon !=
                                                          null)
                                                        restSecondsSuffixIcon!,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]),
                                            SizedBox(height: 5),
                                            TextButton.icon(
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
                                                  try {
                                                    int? seconds;
                                                    String minutesText =
                                                        restFormMinutesController
                                                            .text;
                                                    String secondsText =
                                                        restFormSecondsController
                                                            .text;
                                                    if ((minutesText
                                                                .isNotEmpty &&
                                                            secondsText
                                                                .isEmpty) ||
                                                        (secondsText
                                                                .isNotEmpty &&
                                                            int.parse(
                                                                    secondsText) <
                                                                60)) {
                                                      if (restMinutesSuffixIcon !=
                                                              null ||
                                                          restSecondsSuffixIcon !=
                                                              null) {
                                                        setState(() {
                                                          restMinutesSuffixIcon =
                                                              null;
                                                          restSecondsSuffixIcon =
                                                              null;
                                                        });
                                                      }
                                                      if (minutesText
                                                              .isNotEmpty &&
                                                          secondsText
                                                              .isNotEmpty) {
                                                        seconds = (int.parse(
                                                                    minutesText) *
                                                                60) +
                                                            int.parse(
                                                                secondsText);
                                                      } else if (minutesText
                                                          .isNotEmpty) {
                                                        seconds = int.parse(
                                                                    minutesText) *
                                                                60 +
                                                            previousSeconds;
                                                      } else if (secondsText
                                                          .isNotEmpty) {
                                                        seconds = int.parse(
                                                                secondsText) +
                                                            (previousMinutes *
                                                                60);
                                                      }
                                                      if (seconds != null) {
                                                        // Don't restore in firebase if already the same value
                                                        if (widget
                                                                    .split
                                                                    .trainingDays[
                                                                        widget
                                                                            .dayIndex]
                                                                    .restTimeInSeconds[
                                                                widget
                                                                    .splitDayCardIndex] ==
                                                            seconds) {
                                                          return;
                                                        }
                                                        widget
                                                                .split
                                                                .trainingDays[
                                                                    widget.dayIndex]
                                                                .restTimeInSeconds[
                                                            widget
                                                                .splitDayCardIndex] = seconds;
                                                        // Update potential supersets
                                                        if (widget
                                                                    .split
                                                                    .trainingDays[
                                                                        widget
                                                                            .dayIndex]
                                                                    .isSupersettedWithLast[
                                                                widget
                                                                    .splitDayCardIndex] &&
                                                            widget.splitDayCardIndex !=
                                                                0) {
                                                          widget
                                                              .split
                                                              .trainingDays[
                                                                  widget
                                                                      .dayIndex]
                                                              .restTimeInSeconds[widget
                                                                  .splitDayCardIndex -
                                                              1] = seconds;
                                                        } else if (widget
                                                                    .split
                                                                    .trainingDays[
                                                                        widget
                                                                            .dayIndex]
                                                                    .isSupersettedWithLast
                                                                    .length >
                                                                widget.splitDayCardIndex +
                                                                    1 &&
                                                            widget
                                                                .split
                                                                .trainingDays[
                                                                    widget
                                                                        .dayIndex]
                                                                .isSupersettedWithLast[widget
                                                                    .splitDayCardIndex +
                                                                1]) {
                                                          widget
                                                              .split
                                                              .trainingDays[
                                                                  widget
                                                                      .dayIndex]
                                                              .restTimeInSeconds[widget
                                                                  .splitDayCardIndex +
                                                              1] = seconds;
                                                        }
                                                        // Update split data in firestore
                                                        appState
                                                            .storeDataInFirestore();
                                                        updatePreviousSecondsAndMinutes();
                                                        setState(() {
                                                          hasSavedRestTimes =
                                                              true;
                                                        });
                                                        _restSavedTimer = Timer(
                                                            Duration(
                                                                seconds: 2),
                                                            () {
                                                          setState(() {
                                                            hasSavedRestTimes =
                                                                false;
                                                          });
                                                        });
                                                      }
                                                    } else {
                                                      if (restMinutesSuffixIcon ==
                                                              null ||
                                                          restSecondsSuffixIcon ==
                                                              null) {
                                                        setState(() {
                                                          restMinutesSuffixIcon =
                                                              suffixIcon;
                                                          restSecondsSuffixIcon =
                                                              suffixIcon;
                                                        });
                                                      }
                                                    }
                                                  } catch (e) {
                                                    print(
                                                        'ERROR - Saving rest times $e');
                                                  }
                                                },
                                                icon: Icon(Icons.save_alt,
                                                    color: theme
                                                        .colorScheme.primary,
                                                    size: 14),
                                                label: Text('Save',
                                                    style: labelStyle.copyWith(
                                                        color: theme.colorScheme
                                                            .primary,
                                                        fontSize: 10))),
                                            if (hasSavedRestTimes)
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
                                                      fontSize: 10),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ),
          ],
        ),
      );
    } else {
      // Draggable
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // SizedBox(width: 20),
          IconButton(
            onPressed: () {
              removeSetAndSuperset(context, theme, appState);
            },
            icon: Icon(Icons.delete_outlined, size: 20),
            color: theme.colorScheme.primary,
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            color: theme.colorScheme.onBackground,
            height: 60,
            width: 60,
            child: ImageContainer(exercise: currentExercise),
          ),
          SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // exercise index
                  currentExercise.name,
                  style: labelStyle,
                  textAlign: TextAlign.start,
                ),
                if (widget.split.trainingDays[widget.dayIndex]
                            .isSupersettedWithLast.length >
                        widget.splitDayCardIndex + 1 &&
                    widget.split.trainingDays[widget.dayIndex]
                        .isSupersettedWithLast[widget.splitDayCardIndex + 1])
                  Text(
                    'Superset',
                    style: labelStyle.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(.65)),
                    textAlign: TextAlign.start,
                  ),
              ],
            ),
          ),
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

  void removeSetAndSuperset(
      BuildContext context, ThemeData theme, MyAppState appState) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: theme.colorScheme.onBackground,
        content: SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Text(
                'Removed ${appState.editModeTempSplit.trainingDays[widget.dayIndex].exerciseNames[widget.splitDayCardIndex]} ${widget.split.trainingDays[widget.dayIndex].isSupersettedWithLast.length > widget.splitDayCardIndex + 1 && widget.split.trainingDays[widget.dayIndex].isSupersettedWithLast[widget.splitDayCardIndex + 1] ? '& ${appState.editModeTempSplit.trainingDays[widget.dayIndex].exerciseNames[widget.splitDayCardIndex + 1]} Superset' : ''}',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.background))),
        duration: Duration(milliseconds: 1500),
      ),
    );
    if (widget.split.trainingDays[widget.dayIndex].isSupersettedWithLast
                .length >
            widget.splitDayCardIndex + 1 &&
        widget.split.trainingDays[widget.dayIndex]
            .isSupersettedWithLast[widget.splitDayCardIndex + 1]) {
      appState.removeTempMuscleGroupFromSplit(
        widget.dayIndex,
        widget.splitDayCardIndex,
      );
    }
    // Remove twice if superset
    appState.removeTempMuscleGroupFromSplit(
      widget.dayIndex,
      widget.splitDayCardIndex,
    );
  }

  void removeExercise(
      BuildContext context, ThemeData theme, MyAppState appState) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: theme.colorScheme.onBackground,
        content: SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Text(
                'Removed ${widget.split.trainingDays[widget.dayIndex].exerciseNames[widget.splitDayCardIndex]}',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.background))),
        duration: Duration(milliseconds: 1500),
      ),
    );
    if (widget.split.trainingDays[widget.dayIndex].isSupersettedWithLast
                .length >
            widget.splitDayCardIndex + 1 &&
        widget.split.trainingDays[widget.dayIndex]
            .isSupersettedWithLast[widget.splitDayCardIndex + 1]) {
      // Remove superset
      widget.split.trainingDays[widget.dayIndex]
          .isSupersettedWithLast[widget.splitDayCardIndex + 1] = false;
      appState.removeMuscleGroupFromSplit(
        widget.split,
        widget.dayIndex,
        widget.splitDayCardIndex,
      );
    } else {
      appState.removeMuscleGroupFromSplit(
        widget.split,
        widget.dayIndex,
        widget.splitDayCardIndex,
      );
    }
  }

  void showOptionsDropdown(
      BuildContext context, Offset tapPosition, MyAppState appState) {
    final theme = Theme.of(context);
    final labelStyle =
        TextStyle(color: theme.colorScheme.onBackground, fontSize: 10);

    showMenu<String>(
      color: theme.colorScheme.primaryContainer,
      surfaceTintColor: theme.colorScheme.primaryContainer,
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Info',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.info_outline,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Info',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Tutorial',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.video_collection,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Tutorial',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Change Exercise',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.swap_vert,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Change Exercise',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        if (widget.addSupersetOption)
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 'Add superset',
            child: ListTile(
              visualDensity: VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity),
              dense: true,
              leading:
                  Icon(Icons.add, color: theme.colorScheme.primary, size: 16),
              title: Text('Add superset',
                  style: labelStyle.copyWith(
                      color: theme.colorScheme.onBackground)),
            ),
          ),
        if (widget.split.trainingDays[widget.dayIndex].isSupersettedWithLast
                    .length >
                widget.splitDayCardIndex + 1 &&
            widget.split.trainingDays[widget.dayIndex]
                .isSupersettedWithLast[widget.splitDayCardIndex + 1])
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 'Detach superset A',
            child: ListTile(
              visualDensity: VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity),
              dense: true,
              leading: Icon(Icons.splitscreen,
                  color: theme.colorScheme.primary, size: 16),
              title: Text('Detach superset',
                  style: labelStyle.copyWith(
                      color: theme.colorScheme.onBackground)),
            ),
          ),
        if (widget.split.trainingDays[widget.dayIndex].isSupersettedWithLast
                    .length >
                widget.splitDayCardIndex &&
            widget.split.trainingDays[widget.dayIndex]
                .isSupersettedWithLast[widget.splitDayCardIndex])
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 'Detach superset B',
            child: ListTile(
              visualDensity: VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity),
              dense: true,
              leading: Icon(Icons.splitscreen,
                  color: theme.colorScheme.primary, size: 16),
              title: Text('Detach superset',
                  style: labelStyle.copyWith(
                      color: theme.colorScheme.onBackground)),
            ),
          ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Remove Exercise',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.delete_outline,
                color: theme.colorScheme.secondary, size: 16),
            title: Text('Remove Exercise',
                style: labelStyle.copyWith(color: theme.colorScheme.secondary)),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Change Exercise') {
        _showSwapExercisesWindow(
          context,
          appState,
          appState.muscleGroups.values
              .toList()
              .expand((innerList) => innerList)
              .toList(),
          similarExercises,
          currentExercise,
          widget.dayIndex,
          widget.splitDayCardIndex,
          getPercentCapacity(appState),
        );
      } else if (value == 'Add superset') {
        _showSearchExercisesWindow(
            context,
            appState,
            appState.muscleGroups.values
                .toList()
                .expand((innerList) => innerList)
                .toList()
                .where((element) => !widget
                    .split.trainingDays[widget.dayIndex].exerciseNames
                    .contains(element.name))
                .toList(),
            widget.dayIndex,
            widget.splitDayCardIndex + 1,
            widget.split.trainingDays[widget.dayIndex]
                .setsPerMuscleGroup[widget.splitDayCardIndex]);
      } else if (value == 'Detach superset A') {
        widget.setSplitDayPageState(() {
          widget.split.trainingDays[widget.dayIndex]
              .isSupersettedWithLast[widget.splitDayCardIndex + 1] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * .8,
          backgroundColor: theme.colorScheme.onBackground,
          content: SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: Text('Detached superset!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.background))),
          duration: Duration(milliseconds: 1500),
        ));
      } else if (value == 'Detach superset B') {
        widget.setSplitDayPageState(() {
          widget.split.trainingDays[widget.dayIndex]
              .isSupersettedWithLast[widget.splitDayCardIndex] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * .8,
          backgroundColor: theme.colorScheme.onBackground,
          content: SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: Text('Detached superset!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.background))),
          duration: Duration(milliseconds: 1500),
        ));
      } else if (value == 'Info') {
        toExercise(appState, currentExercise);
      } else if (value == 'Tutorial') {
        launchUrl(Uri.parse(currentExercise.videoLink));
      } else if (value == 'Remove Exercise') {
        removeExercise(context, theme, appState);
      }
    });
  }

  double? getPercentCapacity(MyAppState appState) {
    if (appState.userGym == null || widget.gymOpeningHours == null) {
      return null;
    } else {
      String currentlyOpenString;
      DateTime now = DateTime.now();
      double percentCapacity =
          appState.avgGymCrowdData[now.weekday - 1][now.hour] / 12.0;
      if (appState.userGym!.openingHours != null) {
        currentlyOpenString = widget.gymOpeningHours!.getCurrentlyOpenString();
        // 'Open - ...' or 'Open 24 hours'
        if (currentlyOpenString.startsWith('Open ')) {
          return percentCapacity;
        } else {
          return null;
        }
      } else {
        return percentCapacity;
      }
    }
  }

  String calculateExpectedWaitTimeForExercise(
      double percentCapacity, Exercise exercise) {
    return (WAIT_MULTIPLIER_TO_MINUTES *
            exercise.waitMultiplier *
            percentCapacity)
        .toStringAsFixed(0);
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

void addExerciseToSplit(
  MyAppState appState,
  String identifier,
  Gym? gym,
  List<List<int>> exerciseIndices, // Add exerciseIndices as a parameter
  int dayIndex, // Add dayIndex as a parameter
  int splitDayCardIndex, // Add splitDayCardIndex as a parameter
  Split split,
) {
  switch (identifier) {
    case 'chestPress':
      // Add most popular chest press
      findValidExercise(
          appState,
          gym,
          'Chest',
          ['Mid Chest', 'Lower Chest', 'Front Delts'],
          [3, 2, 1],
          null,
          exerciseIndices,
          dayIndex,
          splitDayCardIndex,
          split);
      break;
    case 'upperChestPress':
      findValidExercise(appState, gym, 'Chest', ['Upper Chest', 'Front Delts'],
          [3, 2], null, exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'cableUpperChest':
      // Upper chest fly variation
      findValidExercise(appState, gym, 'Chest', ['Upper Chest', 'Biceps'],
          [3, 1], 'Cable', exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'cableLowerChest':
      findValidExercise(appState, gym, 'Chest', ['Lower Chest'], [3], 'Cable',
          exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'shoulderPressMachine':
      findValidExercise(
          appState,
          gym,
          'Front Delts',
          ['Front Delts', 'Triceps'],
          [3, 1],
          'Machine',
          exerciseIndices,
          dayIndex,
          splitDayCardIndex,
          split);
      break;
    case 'cableFrontRaise':
      findValidExercise(appState, gym, 'Front Delts', ['Front Delts', 'Biceps'],
          [3, 1], 'Cable', exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'dumbbellLateralRaise':
      findValidExercise(appState, gym, 'Side Delts', ['Side Delts'], [3],
          'Dumbbells', exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'cableLateralRaise':
      findValidExercise(appState, gym, 'Side Delts', ['Side Delts'], [3],
          'Cable', exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'cableTricepPushdown':
      findValidExercise(appState, gym, 'Triceps', ['Tricep Long Head'], [3],
          'Cable', exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'overheadTricep':
      findValidExercise(appState, gym, 'Triceps', ['Tricep Lateral Head'], [3],
          'Cable', exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'latPulldown':
      findValidExercise(appState, gym, 'Back', ['Lats', 'Lower Back'], [3, 0],
          null, exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'chestSupportedUpperBackRow':
      findValidExercise(appState, gym, 'Back', ['Upper Back'], [3], 'Machine',
          exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'hammerCurl':
      findValidExercise(appState, gym, 'Biceps', ['Brachialis'], [3], null,
          exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'regularCurl':
      findValidExercise(
          appState,
          gym,
          'Biceps',
          ['Bicep Long Head', 'Bicep Short Head'],
          [3, 3],
          null,
          exerciseIndices,
          dayIndex,
          splitDayCardIndex,
          split);
      break;
    case 'longHeadCurl':
      findValidExercise(
          appState,
          gym,
          'Biceps',
          ['Bicep Long Head', 'Bicep Short Head'],
          [3, 2],
          null,
          exerciseIndices,
          dayIndex,
          splitDayCardIndex,
          split);
      break;
    case 'shortHeadCurl':
      findValidExercise(
          appState,
          gym,
          'Biceps',
          ['Bicep Short Head', 'Bicep Long Head'],
          [3, 2],
          null,
          exerciseIndices,
          dayIndex,
          splitDayCardIndex,
          split);
      break;
    case 'rearDelt':
      findValidExercise(appState, gym, 'Rear Delts', ['Rear Delts'], [3], null,
          exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'upperAbs':
      findValidExercise(appState, gym, 'Abs', ['Upper Abs'], [3], null,
          exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'lowerAbs':
      findValidExercise(appState, gym, 'Abs', ['Lower Abs'], [3], null,
          exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'gluteSquat':
      findValidExercise(appState, gym, 'Glutes', ['Glutes', 'Quads'], [3, 3],
          null, exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'gluteRDL':
      findValidExercise(appState, gym, 'Glutes', ['Glutes', 'Hamstrings'],
          [3, 2], null, exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'quadSquat':
      findValidExercise(appState, gym, 'Quads', ['Quads', 'Glutes'], [3, 2],
          'Machine', exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'legExtension':
      findValidExercise(appState, gym, 'Quads', ['Quads', 'Glutes'], [3, 0],
          null, exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    case 'seatedLegCurl':
      findValidExercise(
          appState,
          gym,
          'Hamstrings',
          ['Hamstrings', 'Glutes'],
          [3, 0],
          'Machine',
          exerciseIndices,
          dayIndex,
          splitDayCardIndex,
          split);
      break;
    case 'calf':
      findValidExercise(appState, gym, 'Calves', ['Calves'], [3], 'Machine',
          exerciseIndices, dayIndex, splitDayCardIndex, split);
      break;
    default:
      // Case "" or any other case
      // Focused exercises, or shoulder day
      String subMuscleGroup;
      switch (split.trainingDays[dayIndex].muscleGroups[splitDayCardIndex]) {
        case 'Chest':
          subMuscleGroup = 'Mid Chest';
          break;
        case 'Back':
          subMuscleGroup = 'Lats';
          break;
        case 'Biceps':
          subMuscleGroup = 'Bicep Long Head';
          break;
        case 'Triceps':
          subMuscleGroup = 'Tricep Long Head';
          break;
        case 'Abs':
          subMuscleGroup = 'Upper Abs';
          break;
        case 'Glutes':
          // Isolation glute exercise for additional exercises
          findValidExercise(
              appState,
              gym,
              split.trainingDays[dayIndex].muscleGroups[splitDayCardIndex],
              ['Glutes', 'Quads'],
              [3, 0],
              null,
              exerciseIndices,
              dayIndex,
              splitDayCardIndex,
              split);
          print("added exercise index for card $splitDayCardIndex");
          return;
        default:
          subMuscleGroup =
              split.trainingDays[dayIndex].muscleGroups[splitDayCardIndex];
          break;
      }
      findValidExercise(
          appState,
          gym,
          split.trainingDays[dayIndex].muscleGroups[splitDayCardIndex],
          [subMuscleGroup],
          [3],
          null,
          exerciseIndices,
          dayIndex,
          splitDayCardIndex,
          split);
      break;
  }
  print("added exercise index for card $splitDayCardIndex");
}

void findValidExercise(
  MyAppState appState,
  Gym? gym,
  String muscleGroupToCheck,
  List<String> musclesWorkedCheck,
  List<int> targetActivation,
  String? preferredResource,
  List<List<int>> exerciseIndices, // Add exerciseIndices as a parameter
  int dayIndex, // Add dayIndex as a parameter
  int splitDayCardIndex, // Add splitDayCardIndex as a parameter
  Split split,
) {
  if (split.equipmentLevel != 2) {
    if (split.equipmentLevel == 0) {
      // Bodyweight-only
      int? savedIndex;
      int savedPriorityFlag =
          5; // 0: allMusclesHit return, 1: allMusclesHit calisthenic, 2: notAllMusclesHit, 3: notAllMusclesHitCalisthenic, 4: generalNonCalisthenic, 5: generalCalisthenic
      for (int i = 0;
          i < appState.muscleGroups[muscleGroupToCheck]!.length;
          i++) {
        Exercise element = appState.muscleGroups[muscleGroupToCheck]![i];
        if (element.resourcesRequired != null &&
            element.resourcesRequired!.isNotEmpty &&
            (element.resourcesRequired![0] == 'None' ||
                element.resourcesRequired![0] == 'Bodyweight' ||
                element.resourcesRequired![0] == 'Pull-Up Bar' || // Add bench?
                element.resourcesRequired![0] == 'Parallel Bars')) {
          if (element.musclesWorked.isNotEmpty &&
              musclesWorkedCheck.isNotEmpty &&
              element.musclesWorked[0] == musclesWorkedCheck[0]) {
            // If they don't have the same first sub muscle, assume not a high priority exercise
            bool allMusclesHit = true;
            for (int j = 0; j < musclesWorkedCheck.length; j++) {
              if (targetActivation[j] == 0) {
                // Don't include the muscle
                if (element.musclesWorked.contains(musclesWorkedCheck[j])) {
                  allMusclesHit = false;
                  break;
                } else {
                  continue;
                }
              }
              if (element.musclesWorked.contains(musclesWorkedCheck[j]) &&
                  element.musclesWorkedActivation[element.musclesWorked
                          .indexOf(musclesWorkedCheck[j])] ==
                      targetActivation[j]) {
                continue;
              } else {
                allMusclesHit = false;
                break;
              }
            }
            if (allMusclesHit) {
              if (element.resourcesRequired![0] == 'Pull-Up Bar' ||
                  element.resourcesRequired![0] == 'Parallel Bars' &&
                      savedPriorityFlag > 1) {
                savedIndex = i;

                /// allMusclesHit calisthenic (1)
                savedPriorityFlag = 1;
              } else {
                exerciseIndices[dayIndex].add(i); // Highest priority (0)
                return;
              }
            } else {
              // Not all muscles hit
              if (element.resourcesRequired![0] == 'Pull-Up Bar' ||
                  element.resourcesRequired![0] == 'Parallel Bars' &&
                      savedPriorityFlag > 3) {
                savedIndex = i; // notAllMusclesHit calisthenic
                savedPriorityFlag = 3;
              } else if (savedPriorityFlag > 2) {
                savedIndex = i; // notAllMusclesHit nonCalisthenic
                savedPriorityFlag = 2;
              }
            }
          } else if (savedPriorityFlag > 4) {
            // Doesn't satisfy the target sub muscle, but still is eligible to be saved
            if (element.resourcesRequired![0] == 'Pull-Up Bar' ||
                element.resourcesRequired![0] == 'Parallel Bars') {
              savedIndex ??= i; // General calisthenic, least priority (5)
            } else {
              savedIndex = i; // General nonCalisthenic
              savedPriorityFlag = 4;
            }
          }
        }
      }
      // Add 0 if no index was found
      exerciseIndices[dayIndex].add(savedIndex ?? 0);
    } else {
      // == 1, Dumbbells & Bodyweight exercises
      int? savedIndex;
      // bool savedBodyweight = false;
      for (int i = 0;
          i < appState.muscleGroups[muscleGroupToCheck]!.length;
          i++) {
        Exercise element = appState.muscleGroups[muscleGroupToCheck]![i];
        if (element.resourcesRequired != null &&
            element.resourcesRequired!.isNotEmpty &&
            element.musclesWorked.isNotEmpty &&
            musclesWorkedCheck.isNotEmpty) {
          bool allMusclesHit = true;
          for (int j = 0; j < musclesWorkedCheck.length; j++) {
            if (targetActivation[j] == 0) {
              // Don't include the muscle
              if (element.musclesWorked.contains(musclesWorkedCheck[j])) {
                allMusclesHit = false;
                break;
              } else {
                continue;
              }
            }
            if (element.musclesWorked.contains(musclesWorkedCheck[j]) &&
                element.musclesWorkedActivation[
                        element.musclesWorked.indexOf(musclesWorkedCheck[j])] ==
                    targetActivation[j]) {
              continue;
            } else {
              allMusclesHit = false;
              break;
            }
          }
          if (allMusclesHit) {
            // if (element.musclesWorkedActivation[
            //       element.musclesWorked.indexOf(musclesWorkedCheck[0])] ==
            //   3) {
            // Prefer dumbbells over bodyweight exercises
            if (element.resourcesRequired!.contains('Dumbbells')) {
              exerciseIndices[dayIndex].add(i);
              return;
            } else if (element.resourcesRequired![0] == 'None' ||
                element.resourcesRequired![0] == 'Bodyweight' ||
                element.resourcesRequired![0] == 'Pull-Up Bar' ||
                element.resourcesRequired![0] == 'Parallel Bars') {
              // if (savedIndex == null) {
              //   savedBodyweight = true;
              // }
              savedIndex ??= i;
            }
          }
        }
      }
      // Add 0 if no index was found
      exerciseIndices[dayIndex].add(savedIndex ?? 0);
    }
    return;
  } else {
    int? savedIndex;
    for (int i = 0;
        i < appState.muscleGroups[muscleGroupToCheck]!.length;
        i++) {
      Exercise element = appState.muscleGroups[muscleGroupToCheck]![i];
      if (exerciseSatisfiesMusclesWorked(
        element.musclesWorked,
        element.musclesWorkedActivation,
        musclesWorkedCheck,
        targetActivation,
        element.resourcesRequired ?? [],
        element,
        gym,
      )) {
        if (exerciseIsPreferredResource(element, preferredResource)) {
          exerciseIndices[dayIndex].add(i);
          return;
        } else {
          savedIndex ??= i; // If null, save first satisfied index
        }
      }
    }
    // Add 0 if no index was found
    exerciseIndices[dayIndex].add(savedIndex ?? 0);
  }
}

bool exerciseSatisfiesMusclesWorked(
  List<String> musclesWorked,
  List<int> musclesWorkedActivation,
  List<String> musclesWorkedCheck,
  List<int> targetActivation,
  List<String> resourcesNeeded,
  // Map<String, int> resourcesAvailable,
  Exercise exercise,
  Gym? gym,
) {
  // if (musclesWorked.length != musclesWorkedCheck.length) {
  //   return false;
  // }
  // int count = 0;
  for (int i = 0; i < musclesWorkedCheck.length; i++) {
    // Check for exclusion of muscle group
    if (targetActivation[i] == 0) {
      if (musclesWorked.contains(musclesWorkedCheck[i])) {
        return false;
      } else {
        continue;
      }
    }
    // If muscles worked isn't long enough to fit requirements
    if (i >= musclesWorked.length || i >= musclesWorkedActivation.length) {
      return false;
    }
    // If same muscle in same order
    if (musclesWorked[i] == musclesWorkedCheck[i]) {
      // If sufficient activation, continue
      if (musclesWorkedActivation[i] == targetActivation[i]) {
        continue;
      } else {
        return false;
      }
    } else {
      int muscleIndex = musclesWorked.indexOf(musclesWorkedCheck[i]);
      // If target muscle is not in musclesWorked
      if (muscleIndex == -1) {
        return false;
      }
      // If target muscle has sufficient activation, continue
      if (musclesWorkedActivation[muscleIndex] == targetActivation[i]) {
        continue;
      } else {
        return false;
      }
    }
  }
  if (gym == null) {
    // Assume user gym supports exercise if not initialized yet
    return true;
  }
  return gym.canSupportExercise(exercise);
}

bool exerciseIsPreferredResource(
    Exercise theExercise, String? preferredResource) {
  if (preferredResource == null) {
    // Don't prefer bodyweight exercises, unless for abs
    if (theExercise.mainMuscleGroup != 'Abs' &&
        theExercise.resourcesRequired != null &&
        (theExercise.resourcesRequired!.contains('None') ||
            theExercise.resourcesRequired!.contains('Pull-Up Bar') ||
            theExercise.resourcesRequired!.contains('Parallel Bars'))) {
      return false;
    }
    // Prefer any exercise
    return true;
  }
  if (theExercise.resourcesRequired != null &&
      theExercise.resourcesRequired!.contains(preferredResource)) {
    return true;
  }
  return false;
}

void _showSearchExercisesWindow(
    BuildContext context,
    MyAppState appState,
    List<Exercise> allExercises,
    int dayIndex,
    int? indexAfterSuperset,
    int? numSetsToSuperset) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      String initialFilterOption = 'None';
      if (appState.currentSplit.equipmentLevel < 2) {
        initialFilterOption = appState.currentSplit.equipmentLevel == 1
            ? 'Dumbbell-Only'
            : 'No Equipment';
      }
      return SearchExercises(appState, allExercises, initialFilterOption,
          dayIndex, indexAfterSuperset, numSetsToSuperset);
    },
  );
}

// ignore: must_be_immutable
class SearchExercises extends StatefulWidget {
  MyAppState appState;
  List<Exercise> allExercises;
  String selectedFilterOption;
  int dayIndex;
  int? indexAfterSuperset;
  int? numSetsToSuperset;

  SearchExercises(this.appState, this.allExercises, this.selectedFilterOption,
      this.dayIndex, this.indexAfterSuperset, this.numSetsToSuperset);

  @override
  _SearchExercisesState createState() => _SearchExercisesState();
}

class _SearchExercisesState extends State<SearchExercises>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  String pattern = '';
  final ScrollController scrollController = ScrollController();

  List<String> filterOptions = [
    'Dumbbell-Only',
    'No Equipment',
    'Machine-Only'
  ];

  late TextEditingController searchController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showSnackBar(ThemeData theme, Exercise exercise) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: theme.colorScheme.onBackground,
        content: SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Text('${exercise.name} added!',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.background))),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    List<Exercise> filteredExercises = [];
    if (widget.selectedFilterOption == 'Dumbbell-Only') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('Dumbbells');
        }
        return true;
      }).toList();
    } else if (widget.selectedFilterOption == 'No Equipment') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('None') ||
              exercise.resourcesRequired!.contains('Pull-Up Bar') ||
              exercise.resourcesRequired!.contains('Parallel Bars');
        }
        return true;
      }).toList();
    } else if (widget.selectedFilterOption == 'Machine-Only') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('Machine');
        }
        return true;
      }).toList();
    } else {
      // No filter option
      filteredExercises = widget.allExercises;
    }

    List<Exercise> searchFilteredExercises;
    if (pattern.isNotEmpty) {
      searchFilteredExercises = filteredExercises
          .where((element) =>
              element.name.toLowerCase().contains(pattern.toLowerCase()) ||
              element.mainMuscleGroup
                  .toLowerCase()
                  .contains(pattern.toLowerCase()) ||
              element.musclesWorked[0]
                  .toLowerCase()
                  .contains(pattern.toLowerCase()))
          .toList();
    } else {
      searchFilteredExercises = filteredExercises.toList();
    }

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            key: _scaffoldKey,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // _animationController.reverse().then((_) {
                          // _animationController.reverse();
                          Navigator.of(context).pop();
                          // });
                        },
                        child: Text('Cancel',
                            style: TextStyle(
                                color: theme.colorScheme.onBackground)),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: theme.colorScheme.primaryContainer),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                            child: TextField(
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground),
                              controller: searchController,
                              onChanged: (value) {
                                setState(() {
                                  // If value is empty, no search query
                                  pattern = value;
                                });
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
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
                                      setState(() {
                                        pattern = '';
                                      });
                                      searchController
                                          .clear(); // Clear the text field
                                    },
                                  ),
                                  labelText:
                                      'Search for an exercise or muscle group',
                                  labelStyle: labelStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.65)),
                                  floatingLabelStyle: labelStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.65))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5, // Buffer space from left
                      ),
                      ...filterOptions.map((option) {
                        bool isSelected = option == widget.selectedFilterOption;
                        if (isSelected) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  scrollController.animateTo(
                                    0.0,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                  if (!isSelected) {
                                    widget.selectedFilterOption = option;
                                  } else {
                                    widget.selectedFilterOption = 'None';
                                  }
                                });
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      resolveColor(theme.colorScheme.primary),
                                  surfaceTintColor:
                                      resolveColor(theme.colorScheme.primary)),
                              label: Text(
                                option,
                                style: labelStyle,
                              ),
                              icon: Icon(Icons.cancel,
                                  color: theme.colorScheme.onBackground,
                                  size: 16),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  scrollController.animateTo(
                                    0.0,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                  widget.selectedFilterOption = option;
                                });
                              },
                              style: ButtonStyle(
                                  backgroundColor: resolveColor(
                                      theme.colorScheme.primaryContainer),
                                  surfaceTintColor: resolveColor(
                                      theme.colorScheme.primaryContainer)),
                              child: Text(
                                option,
                                style: labelStyle,
                              ),
                            ),
                          );
                        }
                      }).toList(),
                      SizedBox(
                        width: 5, // Buffer space from right
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: searchFilteredExercises.length,
                    itemBuilder: (context, index) {
                      Exercise exercise = searchFilteredExercises[index];
                      return ListTile(
                          leading: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: theme.colorScheme.onBackground),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: ImageContainer(exercise: exercise),
                            ),
                          ),
                          title: Row(children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                exercise.name,
                                style: labelStyle,
                                maxLines: 2,
                              ),
                            ),
                          ]),
                          subtitle: Row(
                            children: [
                              Text(
                                '${exercise.mainMuscleGroup} ',
                                style: labelStyle.copyWith(
                                    color: theme.colorScheme.primary),
                              ),
                              if (exercise.mainMuscleGroup !=
                                  exercise.musclesWorked[0])
                                Text(
                                  '(${exercise.musclesWorked[0]})',
                                  style: labelStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(.65)),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              appState.addMuscleGroupToSplit(
                                  appState.currentSplit,
                                  widget.dayIndex,
                                  // Add to end if not superset
                                  widget.indexAfterSuperset ??
                                      appState
                                          .currentSplit
                                          .trainingDays[widget.dayIndex]
                                          .muscleGroups
                                          .length,
                                  exercise.mainMuscleGroup,
                                  appState
                                      .muscleGroups[exercise.mainMuscleGroup]!
                                      .indexOf(exercise),
                                  // Add same number of sets as superset, otherwise default to 3
                                  widget.numSetsToSuperset ?? 3,
                                  '',
                                  exercise.musclesWorked.length < 2
                                      ? exercise.musclesWorked[0]
                                      : (exercise.musclesWorkedActivation[1] >=
                                              2
                                          ? '${exercise.musclesWorked[0]}/${exercise.musclesWorked[1]}'
                                          : exercise.musclesWorked[0]),
                                  exercise.name,
                                  widget.indexAfterSuperset != null,
                                  exercise.isAccessoryMovement == false
                                      ? 180
                                      : 120);
                              setState(() {
                                widget.allExercises.remove(exercise);
                              });
                              _showSnackBar(theme, exercise);
                              print(
                                  'Added ${exercise.name} to the end of training day ${widget.dayIndex}');
                              if (widget.indexAfterSuperset != null) {
                                Navigator.of(context).pop();
                              }
                            },
                            icon: Icon(Icons.add,
                                color: theme.colorScheme.onBackground,
                                size: 20),
                          ));
                    },
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

void _showSwapExercisesWindow(
  BuildContext context,
  MyAppState appState,
  List<Exercise> allExercises,
  List<Exercise> similarExercises,
  Exercise oldExercise,
  int dayIndex,
  int exerciseNum,
  final double? percentCapacity,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      String initialFilterOption = 'Similar Exercises';
      // if (appState.currentSplit.equipmentLevel < 2) {
      //   initialFilterOption = appState.currentSplit.equipmentLevel == 1
      //       ? 'Dumbbell-Only'
      //       : 'No Equipment';
      // }
      return SwapExercise(appState, allExercises, similarExercises, oldExercise,
          initialFilterOption, dayIndex, exerciseNum, percentCapacity);
    },
  );
}

// ignore: must_be_immutable
class SwapExercise extends StatefulWidget {
  final MyAppState appState;
  final List<Exercise> allExercises;
  final List<Exercise> similarExercises;
  final Exercise oldExercise;
  String selectedFilterOption;
  final int dayIndex;
  final int exerciseNum;
  final double? percentCapacity;

  SwapExercise(
      this.appState,
      this.allExercises,
      this.similarExercises,
      this.oldExercise,
      this.selectedFilterOption,
      this.dayIndex,
      this.exerciseNum,
      this.percentCapacity);

  @override
  _SwapExerciseState createState() => _SwapExerciseState();
}

class _SwapExerciseState extends State<SwapExercise>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  String pattern = '';
  final ScrollController scrollController = ScrollController();

  List<String> filterOptions = [
    'Similar Exercises',
    'Dumbbell-Only',
    'No Equipment',
    'Machine-Only',
  ];

  late TextEditingController searchController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showSnackBar(ThemeData theme, Exercise newExercise) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: theme.colorScheme.onBackground,
        content: SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Text(
                '${widget.oldExercise.name} replaced by ${newExercise.name}!',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.background))),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    List<Exercise> filteredExercises = [];
    if (widget.selectedFilterOption == 'Similar Exercises') {
      filteredExercises = widget.similarExercises.toList();
    } else if (widget.selectedFilterOption == 'Dumbbell-Only') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('Dumbbells');
        }
        return true;
      }).toList();
    } else if (widget.selectedFilterOption == 'No Equipment') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('None') ||
              exercise.resourcesRequired!.contains('Pull-Up Bar') ||
              exercise.resourcesRequired!.contains('Parallel Bars');
        }
        return true;
      }).toList();
    } else if (widget.selectedFilterOption == 'Machine-Only') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('Machine');
        }
        return true;
      }).toList();
    } else {
      // No filter option
      filteredExercises = widget.allExercises;
    }

    List<Exercise> searchFilteredExercises;
    if (pattern.isNotEmpty) {
      searchFilteredExercises = filteredExercises
          .where((element) =>
              element.name.toLowerCase().contains(pattern.toLowerCase()) ||
              element.mainMuscleGroup
                  .toLowerCase()
                  .contains(pattern.toLowerCase()) ||
              element.musclesWorked[0]
                  .toLowerCase()
                  .contains(pattern.toLowerCase()))
          .toList();
    } else {
      searchFilteredExercises = filteredExercises.toList();
    }

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            key: _scaffoldKey,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel',
                            style: TextStyle(
                                color: theme.colorScheme.onBackground)),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: theme.colorScheme.primaryContainer),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                            child: TextField(
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground),
                              controller: searchController,
                              onChanged: (value) {
                                setState(() {
                                  // If value is empty, no search query
                                  pattern = value;
                                });
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
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
                                      setState(() {
                                        pattern = '';
                                      });
                                      searchController
                                          .clear(); // Clear the text field
                                    },
                                  ),
                                  labelText:
                                      'Search for an exercise or muscle group',
                                  labelStyle: labelStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.65)),
                                  floatingLabelStyle: labelStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.65))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5, // Buffer space from left
                      ),
                      ...filterOptions.map((option) {
                        bool isSelected = option == widget.selectedFilterOption;
                        if (isSelected) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  scrollController.animateTo(
                                    0.0,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                  if (!isSelected) {
                                    widget.selectedFilterOption = option;
                                  } else {
                                    widget.selectedFilterOption = 'None';
                                  }
                                });
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      resolveColor(theme.colorScheme.primary),
                                  surfaceTintColor:
                                      resolveColor(theme.colorScheme.primary)),
                              label: Text(
                                option,
                                style: labelStyle,
                              ),
                              icon: Icon(Icons.cancel,
                                  color: theme.colorScheme.onBackground,
                                  size: 16),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  scrollController.animateTo(
                                    0.0,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                  widget.selectedFilterOption = option;
                                });
                              },
                              style: ButtonStyle(
                                  backgroundColor: resolveColor(
                                      theme.colorScheme.primaryContainer),
                                  surfaceTintColor: resolveColor(
                                      theme.colorScheme.primaryContainer)),
                              child: Text(
                                option,
                                style: labelStyle,
                              ),
                            ),
                          );
                        }
                      }).toList(),
                      SizedBox(
                        width: 5, // Buffer space from right
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: searchFilteredExercises.length,
                    itemBuilder: (context, index) {
                      Exercise exercise = searchFilteredExercises[index];
                      int? expectedWaitTime;
                      if (widget.percentCapacity != null) {
                        expectedWaitTime = int.parse(
                            calculateExpectedWaitTimeForExercise(
                                widget.percentCapacity!, exercise));
                      }
                      return ListTile(
                        onTap: () {
                          Split split = appState.currentSplit;
                          final List<dynamic> exerciseInfo =
                              appState.removeMuscleGroupFromSplit(
                                  split, widget.dayIndex, widget.exerciseNum);
                          appState.addMuscleGroupToSplit(
                            split,
                            widget.dayIndex,
                            widget.exerciseNum,
                            exercise.mainMuscleGroup,
                            appState.muscleGroups[exercise.mainMuscleGroup]!
                                .indexOf(exercise),
                            exerciseInfo[2], // numSets
                            '',
                            exercise.musclesWorked.length < 2
                                ? exercise.musclesWorked[0]
                                : (exercise.musclesWorkedActivation[1] >= 2
                                    ? '${exercise.musclesWorked[0]}/${exercise.musclesWorked[1]}'
                                    : exercise.musclesWorked[0]),
                            exercise.name,
                            exerciseInfo[6], // isSuperset
                            exerciseInfo[7], // Rest time
                          );
                          _showSnackBar(theme, exercise);
                          Navigator.of(context).pop();
                        },
                        leading: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: theme.colorScheme.onBackground),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: ImageContainer(exercise: exercise),
                          ),
                        ),
                        title: Row(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 230,
                            child: Text(
                              exercise.name,
                              style: labelStyle,
                              maxLines: 2,
                            ),
                          ),
                        ]),
                        subtitle: Row(
                          children: [
                            Text(
                              '${exercise.mainMuscleGroup} ',
                              style: labelStyle.copyWith(
                                  color: theme.colorScheme.primary),
                            ),
                            if (exercise.mainMuscleGroup !=
                                exercise.musclesWorked[0])
                              Text(
                                '(${exercise.musclesWorked[0]})',
                                style: labelStyle.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(.65)),
                              ),
                          ],
                        ),
                        trailing: widget.percentCapacity != null &&
                                expectedWaitTime != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Expected wait',
                                    style: labelStyle.copyWith(
                                        color: theme.colorScheme.onBackground
                                            .withOpacity(.65),
                                        fontSize: 10),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '$expectedWaitTime minute${expectedWaitTime != 1 ? 's' : ''}',
                                    style: labelStyle.copyWith(
                                        color: expectedWaitTime < 4
                                            ? theme.colorScheme.primary
                                            : (expectedWaitTime < 7
                                                ? Colors.yellow
                                                : theme.colorScheme.secondary),
                                        fontSize: 10),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String calculateExpectedWaitTimeForExercise(
      double percentCapacity, Exercise exercise) {
    return (WAIT_MULTIPLIER_TO_MINUTES *
            exercise.waitMultiplier *
            percentCapacity)
        .toStringAsFixed(0);
  }
}

void _showWorkoutAnalysis(
    BuildContext context, MyAppState appState, TrainingDay trainingDay) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return WorkoutAnalysisWindow(appState, trainingDay);
    },
  );
}

class WorkoutAnalysisWindow extends StatefulWidget {
  final TrainingDay trainingDay;
  final MyAppState appState;

  WorkoutAnalysisWindow(this.appState, this.trainingDay);

  @override
  _WorkoutAnalysisWindowState createState() => _WorkoutAnalysisWindowState();
}

class _WorkoutAnalysisWindowState extends State<WorkoutAnalysisWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  Map<String, double> musclesWorkedActivationPercents = {};
  Map<String, int> musclesWorkedActivationCount = {};
  int totalActivation = 0;
  Image? muscleBalanceImage;
  double maxPercentActivation = -1;
  List<String> sortedPercentKeys = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    if (widget.trainingDay.muscleGroups.length ==
        widget.trainingDay.setsPerMuscleGroup.length) {
      for (int i = 0; i < widget.trainingDay.muscleGroups.length; i++) {
        Exercise exercise = getExercise(i, widget.trainingDay, widget.appState);
        int numSets = widget.trainingDay.setsPerMuscleGroup[i];
        if (exercise.musclesWorked.length ==
            exercise.musclesWorkedActivation.length) {
          for (int j = 0; j < exercise.musclesWorked.length; j++) {
            String muscleWorked = exercise.musclesWorked[j];
            int activation = exercise.musclesWorkedActivation[j];
            List<String>? evenSplit = _checkToSplitEvenly(muscleWorked);
            if (evenSplit == null) {
              // Add to muscle group
              musclesWorkedActivationCount[muscleWorked] =
                  (musclesWorkedActivationCount[muscleWorked] ?? 0) +
                      activation * numSets;
              totalActivation = totalActivation + activation * numSets;
            } else {
              // Add to each evenly
              for (String subMuscleGroup in evenSplit) {
                musclesWorkedActivationCount[subMuscleGroup] =
                    (musclesWorkedActivationCount[subMuscleGroup] ?? 0) +
                        activation * numSets;
                totalActivation = totalActivation + activation * numSets;
              }
            }
          }
        } else {
          print(
              'ERROR - muscles worked length: ${exercise.musclesWorked} ${exercise.musclesWorkedActivation}');
        }
      }
      for (String key in musclesWorkedActivationCount.keys) {
        maxPercentActivation = math.max(maxPercentActivation,
            musclesWorkedActivationCount[key]! / totalActivation);
      }
      for (String key in musclesWorkedActivationCount.keys) {
        musclesWorkedActivationPercents[key] =
            musclesWorkedActivationCount[key]! / totalActivation;
        musclesWorkedActivationCount[key] =
            musclesWorkedActivationPercents[key]! >
                    2.0 * maxPercentActivation / 3.0
                ? 3
                : musclesWorkedActivationPercents[key]! >
                        maxPercentActivation / 3.0
                    ? 2
                    : 1;
      }
      muscleBalanceImage = Image.memory(img.encodePng(applyFloodFill(
          widget.appState.defaultMuscleWorkedImage!,
          musclesWorkedActivationCount.keys.toList(),
          musclesWorkedActivationCount.values.toList(),
          widget.appState.imageMuscleLocations)));

      // for (String key in musclesWorkedActivationPercents.keys.toList()) {
      //   double percent = musclesWorkedActivationPercents[key]!;
      //   checkToSplitEvenly(key, percent);
      // }
      sortedPercentKeys = musclesWorkedActivationPercents.keys.toList();
      // Sort decreasing order of percents
      sortedPercentKeys.sort(((a, b) => musclesWorkedActivationPercents[b]!
          .compareTo(musclesWorkedActivationPercents[a]!)));
    }
    print(musclesWorkedActivationCount);
    print(totalActivation);
  }

  List<String>? _checkToSplitEvenly(String key) {
    switch (key) {
      case 'Chest':
        return ['Upper Chest', 'Mid Chest', 'Lower Chest'];
      case 'Biceps':
        return ['Bicep Long Head', 'Bicep Short Head'];
      case 'Triceps':
        return [
          'Tricep Long Head',
          'Tricep Lateral Head',
          'Tricep Medial Head',
        ];
      case 'Back':
        return ['Lats', 'Upper Back', 'Mid Back', 'Lower Back'];
      case 'Abs':
        return ['Upper Abs', 'Lower Abs'];
    }
    return null;
  }

  // void checkToSplitEvenly(String key, double percent) {
  //   switch (key) {
  //     case 'Chest':
  //       splitEvenly(
  //           percent, 'Chest', ['Upper Chest', 'Mid Chest', 'Lower Chest']);
  //       break;
  //     case 'Biceps':
  //       splitEvenly(percent, 'Biceps',
  //           ['Bicep Long Head', 'Bicep Short Head']);
  //       break;
  //     case 'Triceps':
  //       splitEvenly(percent, 'Triceps', [
  //         'Tricep Long Head',
  //         'Tricep Lateral Head',
  //         'Tricep Medial Head',
  //       ]);
  //       break;
  //     case 'Back':
  //       splitEvenly(percent, 'Back',
  //           ['Lats', 'Upper Back', 'Mid Back', 'Lower Back']);
  //       break;
  //     case 'Abs':
  //       splitEvenly(percent, 'Abs', ['Upper Abs', 'Lower Abs']);
  //       break;
  //   }
  // }

  // void splitEvenly(
  //     double percent, String muscleGroup, List<String> subMuscleGroups) {
  //   bool found = false;
  //   for (String subMuscleGroup in subMuscleGroups) {
  //     if (musclesWorkedActivationPercents[subMuscleGroup] != null) {
  //       found = true;
  //       break;
  //     }
  //   }
  //   if (!found) {
  //     return;
  //   }
  //   for (String subMuscleGroup in subMuscleGroups) {
  //     musclesWorkedActivationPercents[subMuscleGroup] =
  //         (musclesWorkedActivationPercents[subMuscleGroup] ?? 0) +
  //             percent / subMuscleGroups.length;
  //   }
  //   musclesWorkedActivationPercents.remove(muscleGroup);
  // }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Exercise getExercise(int i, TrainingDay trainingDay, MyAppState appState) {
    if (i >= appState.splitDayExerciseIndices[trainingDay.dayOfWeek].length ||
        appState.splitDayExerciseIndices[trainingDay.dayOfWeek][i] >=
            appState.muscleGroups[trainingDay.muscleGroups[i]]!.length) {
      print("ERROR - exercise index is out of bounds");
      return appState.muscleGroups[trainingDay.muscleGroups[i]]!.firstWhere(
          (element) => element.name == trainingDay.exerciseNames[i]);
    }
    Exercise exercise = appState.muscleGroups[trainingDay.muscleGroups[i]]![
        appState.splitDayExerciseIndices[trainingDay.dayOfWeek][i]];
    if (exercise.name != trainingDay.exerciseNames[i]) {
      print(
          'Exercise name: ${exercise.name}, saved exercise name: ${trainingDay.exerciseNames[i]}');
      print("ERROR - exercise name isn't same as exercise index");
      exercise = appState.muscleGroups[trainingDay.muscleGroups[i]]!.firstWhere(
          (element) => element.name == trainingDay.exerciseNames[i]);
    }
    return exercise;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: theme.colorScheme.onBackground)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                      child: Text('Your Workout Analysis',
                          style: theme.textTheme.titleSmall!.copyWith(
                              color: theme.colorScheme.onBackground))),
                  SizedBox(height: 10),
                  if (muscleBalanceImage != null)
                    Hero(
                      tag: 'muscleBalanceImage',
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenPhoto(
                                  photoTag: 'muscleBalanceImage',
                                  photo: muscleBalanceImage!),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            height: 200,
                            width: 200,
                            // Actual size: width: 496, height: 496
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: muscleBalanceImage,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  for (String key in sortedPercentKeys)
                    MuscleBalanceBar(
                        muscle: key,
                        percentFill: musclesWorkedActivationPercents[key]!,
                        highestPercent: maxPercentActivation,
                        textStyle: theme.textTheme.labelSmall!.copyWith(
                            color: theme.colorScheme.onBackground,
                            fontSize: 8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MuscleBalanceBar extends StatelessWidget {
  final String muscle;
  final double percentFill;
  final double highestPercent;
  final TextStyle textStyle;

  const MuscleBalanceBar(
      {required this.muscle,
      required this.percentFill,
      required this.highestPercent,
      required this.textStyle});

  @override
  Widget build(BuildContext context) {
    Color barColor = Colors.grey;
    double percentOfHighest = percentFill / highestPercent;
    int gbColor = ((1 - percentOfHighest) * 255).toInt();

    barColor = Color.fromARGB(255, 235, gbColor, gbColor);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 58,
            child: Text(
              muscle,
              style: textStyle,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            height: 10.0,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentOfHighest,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 58,
            child: Text('${(percentFill * 100).toInt()}%', style: textStyle),
          ),
        ],
      ),
    );
  }
}
