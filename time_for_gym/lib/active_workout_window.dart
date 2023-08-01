import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:time_for_gym/active_workout.dart';
import 'package:time_for_gym/activity.dart';
import 'package:time_for_gym/exercise.dart';
// import 'package:time_for_gym/friends_page.dart';
import 'package:time_for_gym/gym_page.dart';
import 'package:time_for_gym/individual_exercise_page.dart';
import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/split.dart';

void showActiveWorkoutWindow(BuildContext context, MyAppState appState,
    ActiveWorkout workout, int dayIndex) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
          snap: true,
          snapSizes: [],
          initialChildSize:
              1, // Initial height of the sheet (0.5 means 50% of the screen height)
          minChildSize:
              .8, // Minimum height of the sheet when fully collapsed (0.2 means 20% of the screen height)
          maxChildSize:
              1, // Maximum height of the sheet when fully expanded (1.0 means 100% of the screen height)
          expand: false,
          builder: (context, scrollController) {
            return ActiveWorkoutWindow(
                workout, scrollController, dayIndex, appState);
          });
    },
  );
}

class ActiveWorkoutWindow extends StatefulWidget {
  final MyAppState appState;
  final ActiveWorkout workout;
  final ScrollController scrollController;
  final int dayIndex;

  ActiveWorkoutWindow(
      this.workout, this.scrollController, this.dayIndex, this.appState);

  @override
  _ActiveWorkoutWindowState createState() => _ActiveWorkoutWindowState();
}

class _ActiveWorkoutWindowState extends State<ActiveWorkoutWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late final PageController _pageController;
  final List<Widget> pages = [];
  late final GymOpeningHours? gymOpeningHours;

  Exercise getExercise(int i) {
    Exercise exercise = widget
            .appState.muscleGroups[widget.workout.trainingDay.muscleGroups[i]]![
        widget.appState.splitDayExerciseIndices[widget.dayIndex][i]];
    if (exercise.name != widget.workout.trainingDay.exerciseNames[i]) {
      print("ERROR - exercise name isn't same as exercise index");
      exercise = widget
          .appState.muscleGroups[widget.workout.trainingDay.muscleGroups[0]]!
          .firstWhere((element) =>
              element.name == widget.workout.trainingDay.exerciseNames[0]);
    }
    return exercise;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.workout.pageIndex);
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

    if (widget.appState.userGym != null &&
        widget.appState.userGym!.openingHours != null) {
      gymOpeningHours = GymOpeningHours(widget.appState.userGym!.openingHours!);
    } else {
      gymOpeningHours = null;
    }

    int totalSetCount = 0;
    for (int i = 0;
        i < widget.workout.trainingDay.setsPerMuscleGroup.length;
        i++) {
      totalSetCount += widget.workout.trainingDay.setsPerMuscleGroup[i];
    }
    int setIndex = 0;
    for (int i = 0; i < widget.workout.trainingDay.muscleGroups.length; i++) {
      Exercise exercise = getExercise(i);
      if (i < widget.workout.trainingDay.muscleGroups.length - 1 &&
          widget.workout.trainingDay.isSupersettedWithLast[i + 1]) {
        // Add superset
        Exercise newExercise = getExercise(i + 1);
        for (int j = 0;
            j < widget.workout.trainingDay.setsPerMuscleGroup[i];
            j++) {
          // Add superset, then timer page
          addExercisePage(exercise, j, i, true, totalSetCount, setIndex++);
          addExercisePage(newExercise, j, i, false, totalSetCount, setIndex++);
          addTimerPage(
              j,
              i,
              totalSetCount,
              newExercise,
              j < widget.workout.trainingDay.setsPerMuscleGroup[i] - 1
                  ? exercise
                  : getExercise(i + 2));
        }
        // Account for superset
        i++;
      } else {
        for (int j = 0;
            j < widget.workout.trainingDay.setsPerMuscleGroup[i];
            j++) {
          // Add superset, then timer page
          addExercisePage(exercise, j, i, null, totalSetCount, setIndex++);
          if (i != widget.workout.trainingDay.muscleGroups.length - 1 ||
              j != widget.workout.trainingDay.setsPerMuscleGroup[i] - 1) {
            // Last set, don't add timer
            addTimerPage(
                j,
                i,
                totalSetCount,
                exercise,
                j < widget.workout.trainingDay.setsPerMuscleGroup[i] - 1
                    ? exercise
                    : getExercise(i + 1));
          }
        }
      }
    }

    pages.add(ActiveWorkoutCompletionPage(
      scrollController: widget.scrollController,
      appState: widget.appState,
      pageController: _pageController,
    ));
    if (!widget.workout.areBannersAndTimersInitialized) {
      widget.workout.bannerTitles.add('Complete Your Workout');
      widget.workout.bannerSubtitles.add('');
      widget.workout.timers.add(null);
      widget.workout.restTimesInSeconds.add(null);
      widget.workout.timersSecondsLeft =
          List.filled(widget.workout.restTimesInSeconds.length, null);
    }

    widget.workout.areBannersAndTimersInitialized = true;
  }

  void addTimerPage(
      int j, int i, int totalSetCount, Exercise previous, Exercise next) {
    pages.add(ActiveWorkoutTimerPage(
      scrollController: widget.scrollController,
      set: j,
      numSets: widget.workout.trainingDay.setsPerMuscleGroup[i],
      trainingDay: widget.workout.trainingDay,
      totalSecondsTimer: widget.workout.trainingDay.restTimeInSeconds[i],
      exerciseNum: i,
      totalSetCount: totalSetCount,
      pageController: _pageController,
      workout: widget.workout,
      previousExercise: previous,
      upNext: next,
      appState: widget.appState,
      relativePageIndex: pages.length,
      pages: pages,
    ));
    if (!widget.workout.areBannersAndTimersInitialized) {
      // Format into minutes, seconds
      widget.workout.bannerTitles.add(
          'Resting • ${widget.workout.timersSecondsLeft.length > i && widget.workout.timersSecondsLeft[i] != null ? formatSecondsString(widget.workout.timersSecondsLeft[i]) : formatSecondsString(widget.workout.trainingDay.restTimeInSeconds[i])}');
      if (previous == next) {
        widget.workout.bannerSubtitles.add(
            'Up Next: ${previous.name} • Set ${j + 2} of ${widget.workout.trainingDay.setsPerMuscleGroup[i]}');
      } else {
        if (j == widget.workout.trainingDay.setsPerMuscleGroup[i] - 1) {
          // New exercise, not superset. Will not be out of bounds as there is no timer after last total set
          widget.workout.bannerSubtitles.add(
              'Up Next: ${next.name} • Set 1 of ${widget.workout.trainingDay.setsPerMuscleGroup[i + 1]}');
        } else {
          // Superset
          widget.workout.bannerSubtitles.add(
              'Up Next: ${next.name} • Set ${j + 2} of ${widget.workout.trainingDay.setsPerMuscleGroup[i + 1]}');
        }
      }
      widget.workout.timers.add(null);
      widget.workout.restTimesInSeconds
          .add(widget.workout.trainingDay.restTimeInSeconds[i]);
    }
  }

  void addExercisePage(Exercise exercise, int j, int i, bool? supersetA,
      int totalSetCount, int totalSetIndex) {
    pages.add(ActiveWorkoutExercisePage(
        exercise: exercise,
        scrollController: widget.scrollController,
        set: j,
        numSets: widget.workout.trainingDay.setsPerMuscleGroup[i],
        trainingDay: widget.workout.trainingDay,
        supersetA: supersetA,
        appState: widget.appState,
        exerciseNum: i,
        totalSetCount: totalSetCount,
        totalSetIndex: totalSetIndex,
        workout: widget.workout,
        pageController: _pageController,
        pages: pages,
        setActiveWorkoutWindowState: setState,
        gymOpeningHours: gymOpeningHours));
    if (!widget.workout.areBannersAndTimersInitialized) {
      widget.workout.bannerTitles.add(exercise.name);
      widget.workout.bannerSubtitles.add(
          'Set ${j + 1} of ${widget.workout.trainingDay.setsPerMuscleGroup[i]} • Exercise ${i + 1} of ${widget.workout.trainingDay.muscleGroups.length}');
      widget.workout.timers.add(null);
      widget.workout.restTimesInSeconds.add(null);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                widget.appState.updateWorkoutBannerPageIndex(index);
                if (widget.workout.areBannersAndTimersInitialized &&
                    widget.workout.bannerTitles[index].startsWith('Resting') &&
                    widget.workout.restTimesInSeconds[index] != null &&
                    widget.workout.timersSecondsLeft[index] == null) {
                  // Start timer automatically
                  stopExistingTimers(index);
                  widget.workout.timersSecondsLeft[index] =
                      widget.workout.restTimesInSeconds[index]!;
                  decrementTimer(index);
                }
              },
              children: pages),
        ),
      ),
    );
  }

  void stopExistingTimers(int index) {
    int left = index - 1;
    int right = index + 1;
    while (left >= 0) {
      // Complete timer
      if (widget.workout.areBannersAndTimersInitialized &&
          widget.workout.bannerTitles[left].startsWith('Resting') &&
          widget.workout.timersSecondsLeft[left] != null &&
          widget.workout.timersSecondsLeft[left]! > 0) {
        widget.workout.timersSecondsLeft[left] = 0;
        widget.appState.cancelTimerAtIndex(left);
        widget.appState.updateWorkoutBannerAtIndex(left, 'Timer complete');
        break;
      }
      left--;
    }
    while (right < widget.workout.timersSecondsLeft.length) {
      // Reset timer
      if (widget.workout.areBannersAndTimersInitialized &&
          widget.workout.bannerTitles[right].startsWith('Resting') &&
          widget.workout.timersSecondsLeft[right] != null &&
          widget.workout.timersSecondsLeft[right]! > 0) {
        widget.workout.timersSecondsLeft[right] = null;
        widget.appState.cancelTimerAtIndex(right);
        widget.appState.updateWorkoutBannerAtIndex(right,
            'Resting • ${formatSecondsString(widget.workout.restTimesInSeconds[right])}');
        break;
      }
      right++;
    }
  }

  void decrementTimer(int index) {
    if (widget.workout.timersSecondsLeft[index] == null) {
      print('Timer reset');
      widget.appState.updateWorkoutBannerAtIndex(index, 'Timer reset');
    } else if (widget.workout.timersSecondsLeft[index] != null &&
        widget.workout.timersSecondsLeft[index]! <= 0) {
      print('Timer complete');
      widget.appState.updateWorkoutBannerAtIndex(index, 'Timer complete');
    } else {
      widget.appState.updateWorkoutBannerAtIndex(index,
          'Resting • ${formatSecondsString(widget.workout.timersSecondsLeft[index])}');
      print(formatSecondsString(widget.workout.timersSecondsLeft[index]));
      widget.workout.timers[index] = Timer(Duration(seconds: 1), () {
        if (widget.workout.timersSecondsLeft[index] != null &&
            widget.workout.timersSecondsLeft[index] != 0) {
          widget.workout.timersSecondsLeft[index] =
              widget.workout.timersSecondsLeft[index]! - 1;
        }
        decrementTimer(index);
      });
    }
  }
}

// ignore: must_be_immutable
class ActiveWorkoutExercisePage extends StatefulWidget {
  Exercise exercise;
  final ScrollController scrollController;
  final int set;
  final int numSets;
  final TrainingDay trainingDay;
  final bool? supersetA;
  final MyAppState appState;
  final int exerciseNum;
  final int totalSetCount;
  final int totalSetIndex;
  final ActiveWorkout workout;
  final PageController pageController;
  final List<Widget> pages;
  final StateSetter setActiveWorkoutWindowState;
  final GymOpeningHours? gymOpeningHours;

  ActiveWorkoutExercisePage(
      {required this.exercise,
      required this.scrollController,
      required this.set,
      required this.numSets,
      required this.trainingDay,
      required this.supersetA,
      required this.appState,
      required this.exerciseNum,
      required this.totalSetCount,
      required this.totalSetIndex,
      required this.workout,
      required this.pageController,
      required this.pages,
      required this.setActiveWorkoutWindowState,
      required this.gymOpeningHours});
  @override
  State<ActiveWorkoutExercisePage> createState() =>
      _ActiveWorkoutExercisePageState();
}

class _ActiveWorkoutExercisePageState extends State<ActiveWorkoutExercisePage> {
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  bool hasInitializedTextControllers = false;
  int? previousWeight;
  int? previousReps;
  late List<Exercise> similarExercises;
  late Image musclesWorkedImage;
  String expectedWaitTime = '';
  double? percentCapacity;

  @override
  void initState() {
    super.initState();
    similarExercises = findSimilarExercises(widget.exercise, widget.appState);
    musclesWorkedImage = Image.memory(img.encodePng(applyFloodFill(
        widget.appState.defaultMuscleWorkedImage!,
        widget.exercise.musclesWorked,
        widget.exercise.musclesWorkedActivation,
        widget.appState.imageMuscleLocations)));
    // if (widget.setAppPageState != null) {
    //   widget.setAppPageState!(() {
    //     widget.appState.changeActiveWorkoutTitles(widget.exercise.name,
    //         'Set ${widget.set + 1} of ${widget.numSets} • Exercise ${widget.exerciseNum + 1} of ${widget.trainingDay.muscleGroups.length}');
    //   });
    // } else {
    // widget.workout.bannerTitle = widget.exercise.name;
    // widget.workout.bannerSubtitle =
    //     'Set ${widget.set + 1} of ${widget.numSets} • Exercise ${widget.exerciseNum + 1} of ${widget.trainingDay.muscleGroups.length}';
    // }
    // widget.appState.activeWorkoutBannerWidget = Positioned(
    //   bottom: 10,
    //   left: 40,
    //   right: 40,
    //   child: GestureDetector(
    //     onTap: () {
    //       showActiveWorkoutWindow(
    //           context,
    //           widget.appState,
    //           widget.appState.activeWorkout!,
    //           widget.appState.activeWorkout!.dayIndex,
    //           setState);
    //     },
    //     child: Container(
    //       decoration: BoxDecoration(
    //           color: Theme.of(context).colorScheme.primary.withOpacity(.9),
    //           borderRadius: BorderRadius.circular(5)),
    //       padding: EdgeInsets.all(12.0),
    //       child: ListTile(
    //         title: Text(
    //             widget.appState.activeWorkout!.bannerTitle ?? 'Resume workout',
    //             style: Theme.of(context).textTheme.titleSmall!.copyWith(
    //                 color: Theme.of(context).colorScheme.onBackground),
    //             textAlign: TextAlign.center),
    //         subtitle: Text(widget.appState.activeWorkout!.bannerSubtitle ?? ''),
    //       ),
    //     ),
    //   ),
    // );
  }

  List<Exercise> findSimilarExercises(Exercise exercise, MyAppState appState) {
    List<Exercise> allExercises = [];
    allExercises.addAll(appState.muscleGroups[exercise.mainMuscleGroup] ?? []);
    List<Exercise> similarExercises = allExercises
        .where((other) =>
            exercise.musclesWorked.isNotEmpty &&
            exercise.musclesWorkedActivation.isNotEmpty &&
            other.musclesWorked.isNotEmpty &&
            other.musclesWorkedActivation.isNotEmpty &&
            exercise.musclesWorked[0] == other.musclesWorked[0] &&
            exercise.musclesWorkedActivation[0] ==
                other.musclesWorkedActivation[0] &&
            exercise.name != other.name)
        .toList();
    return similarExercises;
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final largeTitleStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyTitleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    // final labelMediumStyle = theme.textTheme.labelMedium!
    //     .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    // final formHeadingStyle = theme.textTheme.bodyMedium!
    //     .copyWith(color: theme.colorScheme.onBackground);
    final formTextStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    // If exercise is swapped
    if (similarExercises.contains(widget.exercise)) {
      similarExercises = findSimilarExercises(widget.exercise, appState);
    }

    String equipmentNeededString = "None";
    if (widget.exercise.resourcesRequired != null &&
        widget.exercise.resourcesRequired!.isNotEmpty) {
      equipmentNeededString = "";
      for (String resourceRequired in widget.exercise.resourcesRequired!) {
        equipmentNeededString += "$resourceRequired, ";
      }
      if (equipmentNeededString.isNotEmpty) {
        // Remove trailing comma and space
        equipmentNeededString = equipmentNeededString.substring(
            0, equipmentNeededString.length - 2);
      }
    }

    if (!hasInitializedTextControllers) {
      if (widget.exercise.splitWeightAndReps.isEmpty) {
        List<List<int>>? weightAndReps =
            widget.exercise.initializeSplitWeightAndRepsFrom1RM(widget.numSets);
        // If one rep max isn't null, initialization was successful
        if (weightAndReps != null && weightAndReps[0].length > widget.set) {
          previousWeight = weightAndReps[0][widget.set];
          previousReps = weightAndReps[1][widget.set];
        }
        // If null, previous weight and reps will remain null
      } else {
        // Previous topset data
        if (widget.exercise.splitWeightPerSet.isEmpty ||
            widget.exercise.splitRepsPerSet.isEmpty) {
          List<List<int>>? weightAndReps =
              widget.exercise.initializeSetsFromTopSet(widget.numSets);
          if (weightAndReps != null && weightAndReps[0].length > widget.set) {
            previousWeight = weightAndReps[0][widget.set];
            previousReps = weightAndReps[1][widget.set];
          }
        } else {
          if (widget.exercise.splitWeightPerSet.length > widget.set &&
              widget.exercise.splitRepsPerSet.length > widget.set) {
            previousWeight = widget.exercise.splitWeightPerSet[widget.set];
            previousReps = widget.exercise.splitRepsPerSet[widget.set];
          }
        }
      }
      weightController.text = '${previousWeight ?? ''}';
      repsController.text = '${previousReps ?? ''}';
      hasInitializedTextControllers = true;
    }

    if (expectedWaitTime.isEmpty) {
      expectedWaitTime = getExpectedWaitTime(appState);
    }

    return Scaffold(
      body: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(alignment: AlignmentDirectional.topCenter, children: [
              SizedBox(
                  height: MediaQuery.of(context).size.width,
                  child: ImageContainer(exercise: widget.exercise)),
              Positioned(
                top: 45,
                left: 10,
                child: GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: theme.colorScheme.background, size: 35),
                  ),
                ),
              ),
              Positioned(
                  top: 45,
                  right: 10,
                  child: GestureDetector(
                    // onPressed: () {
                    //   print('ergiouerguioioeg');
                    // },
                    onTapDown: (tapDownDetails) {
                      showOptionsDropdown(
                          context, tapDownDetails.globalPosition, appState);
                    },
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Icon(Icons.more_horiz,
                          color: theme.colorScheme.background, size: 40),
                    ),
                  )),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(widget.exercise.name, style: largeTitleStyle),
                  ),
                  Center(
                    child: Text(
                        'Set ${widget.set + 1} of ${widget.numSets} • Exercise ${widget.exerciseNum + 1} of ${widget.trainingDay.muscleGroups.length}',
                        style: greyTitleStyle),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProgressBar(
                          percentFill:
                              widget.totalSetIndex / widget.totalSetCount),
                      SizedBox(width: 10),
                      Text(
                          '${(100 * widget.totalSetIndex / widget.totalSetCount).toStringAsFixed(0)}%',
                          style: greyTitleStyle),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: theme.colorScheme.tertiaryContainer),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 42,
                                    height: 38,
                                    child: TextFormField(
                                      maxLength: 3,
                                      style: formTextStyle,
                                      controller: weightController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        labelStyle: labelStyle.copyWith(
                                            color: theme
                                                .colorScheme.onBackground
                                                .withOpacity(.65)),
                                        // labelText: previousWeights[0],
                                      ),
                                    ),
                                  ),
                                  // if (weightSuffixIcons[0] != null)
                                  //   weightSuffixIcons[0]!,
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
                        width: 5,
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: theme.colorScheme.tertiaryContainer),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 42,
                                    height: 38,
                                    child: TextField(
                                      maxLength: 2,
                                      style: formTextStyle,
                                      controller: repsController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        labelStyle: labelStyle.copyWith(
                                            color: theme
                                                .colorScheme.onBackground
                                                .withOpacity(.65)),
                                        // labelText: previousReps[0],
                                      ),
                                    ),
                                  ),
                                  // if (repsSuffixIcons[0] != null)
                                  //   repsSuffixIcons[0]!,
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Reps', style: labelStyle),
                        ],
                      ),
                      SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      resolveColor(theme.colorScheme.primary),
                                  surfaceTintColor:
                                      resolveColor(theme.colorScheme.primary)),
                              onPressed: () {
                                if (weightController.text.isNotEmpty &&
                                    repsController.text.isNotEmpty &&
                                    (int.parse(weightController.text) !=
                                            previousWeight ||
                                        int.parse(repsController.text) !=
                                            previousReps)) {
                                  saveSet(appState, widget.exercise);
                                  print('saved set');
                                }
                                widget.pageController.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut);
                              },
                              label: Text(
                                'Next',
                                style: labelStyle,
                              ),
                              icon: Icon(
                                Icons.check,
                                color: theme.colorScheme.onBackground,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  if (expectedWaitTime != 'No gym selected' &&
                      expectedWaitTime !=
                          '${appState.userGym!.name} is currently closed')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expected Wait Time',
                          style: titleStyle,
                        ),
                        SizedBox(height: 5),
                        Text(
                          '$expectedWaitTime Minute${expectedWaitTime != '1' ? 's' : ''}',
                          style: labelStyle.copyWith(
                              color: int.parse(expectedWaitTime) < 4
                                  ? theme.colorScheme.primary
                                  : (int.parse(expectedWaitTime) < 7
                                      ? Colors.yellow
                                      : theme.colorScheme.secondary)),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  Text('Instructions', style: titleStyle),
                  SizedBox(height: 5),
                  Text(widget.exercise.description, style: greyLabelStyle),
                  SizedBox(height: 15),
                  Text(
                    'Equipment Needed',
                    style: titleStyle,
                  ),
                  SizedBox(height: 5),
                  Text(
                    equipmentNeededString,
                    style: greyLabelStyle,
                  ),
                  SizedBox(height: 15),
                  Text('Muscles Worked', style: titleStyle),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          for (int i = 0;
                              i < widget.exercise.musclesWorked.length;
                              i++)
                            MuscleFillBarPreview(
                                muscle: widget.exercise.musclesWorked[i],
                                fillLevel:
                                    widget.exercise.musclesWorkedActivation[i],
                                textStyle: labelStyle),
                        ],
                      ),
                      Spacer(flex: 3),
                      Hero(
                        tag: '2',
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenPhoto(
                                    photoTag: '2', photo: musclesWorkedImage),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            height: 180,
                            width: 180,
                            // Actual size: width: 496, height: 496
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: musclesWorkedImage,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Text(
                  //   'Similar Exercises',
                  //   style: theme.textTheme.titleMedium!
                  //       .copyWith(color: theme.colorScheme.onPrimary),
                  // ),
                  // SimilarExercisesRowPreview(
                  //   similarExercises: similarExercises,
                  //   appState: appState,
                  //   scrollController: widget.scrollController,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getExpectedWaitTime(MyAppState appState) {
    String expectedWaitTime;
    if (appState.userGym == null || widget.gymOpeningHours == null) {
      expectedWaitTime = 'No gym selected';
    } else {
      String currentlyOpenString;
      DateTime now = DateTime.now();
      percentCapacity =
          appState.avgGymCrowdData[now.weekday - 1][now.hour] / 12.0;
      if (appState.userGym!.openingHours == null) {
        // Assume it's open
        // print('Estimated ${(percentCapacity * 100).toInt()}% capactiy');
        expectedWaitTime = calculateExpectedWaitTimeForExercise(
            percentCapacity!, widget.exercise);
      } else {
        currentlyOpenString = widget.gymOpeningHours!.getCurrentlyOpenString();
        // 'Open - ...' or 'Open 24 hours'
        if (currentlyOpenString.startsWith('Open ')) {
          // print('Estimated ${(percentCapacity * 100).toInt()}% capactiy');
          expectedWaitTime = (WAIT_MULTIPLIER_TO_MINUTES *
                  widget.exercise.waitMultiplier *
                  percentCapacity!)
              .toStringAsFixed(0);
        } else {
          // Closed
          expectedWaitTime = '${appState.userGym!.name} is currently closed';
          percentCapacity = null;
        }
      }
    }
    return expectedWaitTime;
  }

  String calculateExpectedWaitTimeForExercise(
      double percentCapacity, Exercise exercise) {
    return (WAIT_MULTIPLIER_TO_MINUTES *
            exercise.waitMultiplier *
            percentCapacity)
        .toStringAsFixed(0);
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
        if (widget.pageController.page != 0)
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 'Jump to first page',
            child: ListTile(
              visualDensity: VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity),
              dense: true,
              leading: Icon(Icons.first_page,
                  color: theme.colorScheme.primary, size: 16),
              title: Text('Jump to first page',
                  style: labelStyle.copyWith(
                      color: theme.colorScheme.onBackground)),
            ),
          ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Jump to last page',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.last_page,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Jump to last page',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Cancel workout',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.do_disturb,
                color: theme.colorScheme.secondary, size: 16),
            title: Text('Cancel workout',
                style: labelStyle.copyWith(color: theme.colorScheme.secondary)),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Cancel workout') {
        Navigator.of(context).pop();
        appState.cancelWorkout();
      } else if (value == 'Change Exercise') {
        _showSwapExerciseWindow(
          context,
          appState,
          appState.muscleGroups.values
              .toList()
              .expand((innerList) => innerList)
              .toList(),
          similarExercises,
          widget.exercise,
          widget.workout.dayIndex,
          widget.exerciseNum,
          widget.pages,
          widget.scrollController,
          widget.set,
          widget.supersetA,
          widget.totalSetCount,
          widget.totalSetIndex,
          widget.workout,
          widget.pageController,
          setState,
          percentCapacity,
        );
      } else if (value == 'Jump to first page') {
        widget.pageController.jumpToPage(0);
      } else if (value == 'Jump to last page') {
        widget.pageController.jumpToPage(widget.pages.length - 1);
      }
    });
  }

  void saveSet(MyAppState appState, Exercise exercise) {
    String weight = weightController.text;
    String reps = repsController.text;
    bool isValidated = true;
    final DateTime now = DateTime.now();
    final DateTime currentDay = DateTime.parse(
        '${now.year}${now.month > 9 ? now.month : '0${now.month}'}${now.day > 9 ? now.day : '0${now.day}'}');
    final int millisecondsSinceEpoch = currentDay.millisecondsSinceEpoch;

    //TODO - Add kilo i/o functionality

    if (weight.isEmpty || reps.isEmpty || reps == '0') {
      isValidated = false;
    }

    if (isValidated) {
      // Update weight and reps

      if (exercise.splitWeightAndReps.isEmpty || widget.set == 0) {
        exercise.splitWeightAndReps = [int.parse(weight), int.parse(reps)];
      }
      // if (widget.setIndex > 0) {
      if (exercise.splitWeightPerSet.length <= widget.set ||
          exercise.splitRepsPerSet.length <= widget.set) {
        exercise.initializeSetsFromTopSet(widget.numSets);
      }
      // }
      exercise.splitWeightPerSet[widget.set] = int.parse(weight);
      exercise.splitRepsPerSet[widget.set] = int.parse(reps);
      print('updated weight and reps');

      // Update one rep max if applicable
      int? previousOneRepMax = exercise.userOneRepMax;
      int newOneRepMax = calculateOneRepMax(int.parse(weight), int.parse(reps));
      if (int.parse(reps) <= 30 &&
          (previousOneRepMax == null || newOneRepMax > previousOneRepMax)) {
        // Can update one rep max
        if (previousOneRepMax != null) {
          // Make new activity for the user to celebrate their PR
          widget.workout.prMessages[exercise.name] =
              '${exercise.name}: ${int.parse(weight)} lbs for ${int.parse(reps)} reps'; //\nNew estimated one-rep-max: $newOneRepMax';

          // Store split data
          appState.storeDataInFirestore();
        }
        exercise.userOneRepMax = newOneRepMax;
      }

      setState(() {
        previousWeight = int.parse(weight);
        previousReps = int.parse(reps);
      });

      // Check if user has submitted one rep max history today, only save 1 per day
      int sameDayMilliseconds = exercise.userOneRepMaxHistory.keys.firstWhere(
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
        exercise.userOneRepMaxHistory[millisecondsSinceEpoch] = newOneRepMax;
      } else {
        // Put best of both maxes
        exercise.userOneRepMaxHistory[sameDayMilliseconds] = math.max(
            newOneRepMax,
            exercise.userOneRepMaxHistory[sameDayMilliseconds] ?? -1);
      }
      appState.submitExercisePopularityDataToFirebase(
          appState.currentUser.username,
          exercise.name,
          exercise.mainMuscleGroup,
          exercise.userRating,
          exercise.userOneRepMax,
          exercise.splitWeightAndReps,
          exercise.splitWeightPerSet,
          exercise.splitRepsPerSet,
          exercise.userOneRepMaxHistory);
      print('submitted split weight & rep data to firebase');
    }
  }
}

// class SimilarExercisesRowPreview extends StatelessWidget {
//   const SimilarExercisesRowPreview(
//       {super.key,
//       required this.similarExercises,
//       required this.appState,
//       required this.scrollController});

//   final List<Exercise> similarExercises;
//   final MyAppState appState;
//   final ScrollController scrollController;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(width: 10), // Buffer space before the first button
//           ...List.generate(
//             similarExercises.length,
//             (index) => Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8),
//               child: GestureDetector(
//                 onTap: () {
//                   scrollController.animateTo(
//                     0,
//                     duration: Duration(
//                         milliseconds: 500), // Adjust the duration as desired
//                     curve: Curves.easeInOut, // Adjust the curve as desired
//                   );
//                 },
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       // child: Image.asset('muscle_group_pictures/$name.jpeg', fit: BoxFit.cover,),
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         child:
//                             ImageContainer(exercise: similarExercises[index]),
//                       ),
//                       // child: ,
//                     ),
//                     SizedBox(height: 8),
//                     SizedBox(
//                       width: 120,
//                       child: Text(
//                         similarExercises[index].name,
//                         style: Theme.of(context).textTheme.labelSmall!.copyWith(
//                             color: Theme.of(context).colorScheme.onBackground),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ).toList(),
//           SizedBox(width: 10), // Buffer
//         ],
//       ),
//     );
//   }
// }

class MuscleFillBarPreview extends StatelessWidget {
  final String muscle;
  final int fillLevel;
  final TextStyle textStyle;

  const MuscleFillBarPreview(
      {required this.muscle, required this.fillLevel, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    Color barColor = Colors.grey;
    double barFill = 0.0;

    if (fillLevel == 3) {
      barColor = Color.fromARGB(255, 235, 0, 0);
      barFill = 1.0;
    } else if (fillLevel == 2) {
      barColor = Color.fromARGB(255, 235, 100, 100);
      barFill = 0.75;
    } else if (fillLevel == 1) {
      barColor = Color.fromARGB(255, 235, 160, 160);
      barFill = 0.5;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          muscle,
          style: textStyle,
        ),
        SizedBox(height: 8.0),
        Container(
          height: 10.0,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey[350],
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: barFill,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.0),
      ],
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double percentFill;

  const ProgressBar({required this.percentFill});

  @override
  Widget build(BuildContext context) {
    Color barColor = Theme.of(context).colorScheme.primary;

    return Container(
      height: 10.0,
      width: 200,
      decoration: BoxDecoration(
          color: Colors.grey[350], borderRadius: BorderRadius.circular(5.0)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentFill,
        child: Container(
          decoration: BoxDecoration(
              color: barColor, borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }
}

class ActiveWorkoutTimerPage extends StatefulWidget {
  final TrainingDay trainingDay;
  final int totalSecondsTimer;
  final ScrollController scrollController;
  final int set;
  final int numSets;
  final int exerciseNum;
  final int totalSetCount;
  final PageController pageController;
  final ActiveWorkout workout;
  final Exercise previousExercise;
  final Exercise upNext;
  final MyAppState appState;
  final int relativePageIndex;
  final List<Widget> pages;

  ActiveWorkoutTimerPage(
      {required this.scrollController,
      required this.set,
      required this.numSets,
      required this.trainingDay,
      required this.totalSecondsTimer,
      required this.exerciseNum,
      required this.totalSetCount,
      required this.pageController,
      required this.workout,
      required this.previousExercise,
      required this.upNext,
      required this.appState,
      required this.relativePageIndex,
      required this.pages});
  @override
  State<ActiveWorkoutTimerPage> createState() => _ActiveWorkoutTimerPageState();
}

class _ActiveWorkoutTimerPageState extends State<ActiveWorkoutTimerPage> {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return Scaffold(
      body: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 45),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 10),
                GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onBackground, size: 35),
                  ),
                ),
                Spacer(),
                GestureDetector(
                    // onPressed: () {wef
                    //   print('ergiouerguioioeg');
                    // },
                    onTapDown: (tapDownDetails) {
                      showOptionsDropdown(
                          context, tapDownDetails.globalPosition, appState);
                    },
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Icon(Icons.more_horiz,
                          color: theme.colorScheme.onBackground, size: 40),
                    )),
                SizedBox(width: 10),
              ],
            ),
            Center(
              child: Text(
                '${formatSecondsString(widget.workout.restTimesInSeconds[widget.relativePageIndex])} Rest'
                    .replaceAll('min', 'Minute')
                    .replaceAll('sec', 'Second'),
                style: theme.textTheme.headlineSmall!
                    .copyWith(color: theme.colorScheme.onBackground),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                  appState
                      .activeWorkout!.bannerSubtitles[widget.relativePageIndex],
                  style: greyLabelStyle,
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 50),
            if (appState.activeWorkout!
                        .timersSecondsLeft[widget.relativePageIndex] !=
                    null &&
                appState.activeWorkout!
                        .restTimesInSeconds[widget.relativePageIndex] !=
                    null)
              Center(
                child: Stack(
                  children: [
                    TimerProgressIndicator(
                        fill: theme.colorScheme.primary,
                        background: Colors.grey[300]!,
                        percentCapacity:
                            appState.activeWorkout!.restTimesInSeconds[
                                        widget.relativePageIndex]! !=
                                    0
                                ? appState.activeWorkout!.timersSecondsLeft[
                                        widget.relativePageIndex]! /
                                    appState.activeWorkout!.restTimesInSeconds[
                                        widget.relativePageIndex]!
                                : 0,
                        size: 200,
                        strokeWidth: 8),
                    Positioned(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: Text(
                            appState.activeWorkout!
                                .bannerTitles[widget.relativePageIndex]
                                .replaceFirst(' • ', '\n'),
                            style: theme.textTheme.titleMedium!.copyWith(
                                color: theme.colorScheme.onBackground),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  style: ButtonStyle(
                      backgroundColor:
                          resolveColor(theme.colorScheme.primaryContainer),
                      surfaceTintColor:
                          resolveColor(theme.colorScheme.primaryContainer)),
                  onPressed: () {
                    if (appState.activeWorkout!
                            .restTimesInSeconds[widget.relativePageIndex] !=
                        null) {
                      int totalSeconds = appState.activeWorkout!
                          .restTimesInSeconds[widget.relativePageIndex]!;
                      appState.activeWorkout!
                              .timersSecondsLeft[widget.relativePageIndex] =
                          totalSeconds;
                      // Change the timer's message
                      appState.updateWorkoutBannerAtIndex(
                          widget.relativePageIndex,
                          totalSeconds > 0
                              ? 'Resting • ${formatSecondsString(totalSeconds)}'
                              : 'Timer complete');
                    }
                  },
                  icon: Icon(Icons.replay,
                      color: theme.colorScheme.primary, size: 40),
                ),
                if (appState.activeWorkout!
                            .timersSecondsLeft[widget.relativePageIndex] !=
                        null &&
                    appState.activeWorkout!
                            .restTimesInSeconds[widget.relativePageIndex] !=
                        null)
                  IconButton(
                    style: ButtonStyle(
                        backgroundColor:
                            resolveColor(theme.colorScheme.primary),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primary)),
                    onPressed: () {
                      if (appState.activeWorkout!
                              .timers[widget.relativePageIndex] !=
                          null) {
                        // Pause
                        appState.cancelTimerAtIndex(widget.relativePageIndex);
                      } else {
                        // Play
                        appState.decrementTimer(widget.relativePageIndex);
                      }
                    },
                    icon: Icon(
                        appState.activeWorkout!
                                    .timers[widget.relativePageIndex] !=
                                null
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: theme.colorScheme.onBackground,
                        size: 50),
                  ),
                IconButton(
                  style: ButtonStyle(
                      backgroundColor:
                          resolveColor(theme.colorScheme.primaryContainer),
                      surfaceTintColor:
                          resolveColor(theme.colorScheme.primaryContainer)),
                  onPressed: () {
                    appState.activeWorkout!
                        .timersSecondsLeft[widget.relativePageIndex] = 0;
                    appState.cancelTimerAtIndex(widget.relativePageIndex);
                    appState.updateWorkoutBannerAtIndex(
                        widget.relativePageIndex, 'Timer complete');
                    widget.pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  icon: Icon(Icons.skip_next,
                      color: theme.colorScheme.primary, size: 40),
                ),
              ],
            ),
            SizedBox(height: 100),
            // CustomAdWidget(),
            // Center(
            //   child: SizedBox(
            //     height: 100,
            //     width: 300,
            //     child: ListTile(
            //       dense: true,
            //       visualDensity: VisualDensity(
            //           vertical: VisualDensity.minimumDensity,
            //           horizontal: VisualDensity.minimumDensity),
            //       minVerticalPadding: 0,
            //       titleAlignment: ListTileTitleAlignment.titleHeight,
            //       leading: appState.activeWorkout!.timersSecondsLeft[widget.relativePageIndex] != null &&
            //               appState.activeWorkout!.restTimesInSeconds[
            //                       widget.relativePageIndex] !=
            //                   null
            //           ? TimerProgressIndicator(
            //               fill: theme.colorScheme.primary,
            //               background: theme.colorScheme.onBackground,
            //               percentCapacity: appState.activeWorkout!.restTimesInSeconds[
            //                           widget.relativePageIndex]! !=
            //                       0
            //                   ? appState.activeWorkout!.timersSecondsLeft[
            //                           widget.relativePageIndex]! /
            //                       appState.activeWorkout!
            //                           .restTimesInSeconds[widget.relativePageIndex]!
            //                   : 0,
            //               size: 30,
            //               strokeWidth: 4)
            //           : null,
            //       title: Text(
            //           appState.activeWorkout!
            //               .bannerTitles[widget.relativePageIndex],
            //           style: theme.textTheme.titleMedium!
            //               .copyWith(color: theme.colorScheme.onBackground),
            //           textAlign: TextAlign.center),
            //       subtitle: Text(
            //           appState.activeWorkout!
            //               .bannerSubtitles[widget.relativePageIndex],
            //           style: theme.textTheme.labelSmall!
            //               .copyWith(color: theme.colorScheme.onBackground),
            //           textAlign: TextAlign.center),
            //       trailing: appState.activeWorkout!.timersSecondsLeft[
            //                       widget.relativePageIndex] !=
            //                   null &&
            //               appState.activeWorkout!.restTimesInSeconds[
            //                       widget.relativePageIndex] !=
            //                   null
            //           ? GestureDetector(
            //               onTap: () {
            //                 if (appState.activeWorkout!
            //                         .timers[widget.relativePageIndex] !=
            //                     null) {
            //                   // Pause
            //                   appState
            //                       .cancelTimerAtIndex(widget.relativePageIndex);
            //                 } else {
            //                   // Play
            //                   appState.decrementTimer(widget.relativePageIndex);
            //                 }
            //               },
            //               child: Container(
            //                 decoration: BoxDecoration(),
            //                 child: Icon(
            //                     appState.activeWorkout!
            //                                 .timers[widget.relativePageIndex] !=
            //                             null
            //                         ? Icons.pause
            //                         : Icons.play_arrow,
            //                     color: theme.colorScheme.onBackground,
            //                     size: 30),
            //               ))
            //           : null,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
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
          // height: 50,
          padding: EdgeInsets.zero,
          value: 'Edit Timer',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.hourglass_empty,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Edit Timer',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          // height: 50,
          padding: EdgeInsets.zero,
          value: 'Edit All Timers',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.hourglass_full,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Edit All Timers',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Jump to first page',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.first_page,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Jump to first page',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Jump to last page',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.last_page,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Jump to last page',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          // height: 30,
          padding: EdgeInsets.zero,
          value: 'Cancel workout',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.do_disturb,
                color: theme.colorScheme.secondary, size: 16),
            title: Text('Cancel workout',
                style: labelStyle.copyWith(color: theme.colorScheme.secondary)),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Cancel workout') {
        Navigator.of(context).pop();
        appState.cancelWorkout();
      } else if (value == 'Edit Timer') {
        _showEditTimerWindow(
            context, appState, widget.relativePageIndex, widget.exerciseNum);
      } else if (value == 'Edit All Timers') {
        _showEditTimerWindow(context, appState, null, widget.exerciseNum);
      } else if (value == 'Jump to first page') {
        widget.pageController.jumpToPage(0);
      } else if (value == 'Jump to last page') {
        widget.pageController.jumpToPage(widget.pages.length - 1);
      }
    });
  }
}

class ActiveWorkoutCompletionPage extends StatefulWidget {
  final ScrollController scrollController;
  final MyAppState appState;
  final PageController pageController;
  ActiveWorkoutCompletionPage(
      {required this.scrollController,
      required this.appState,
      required this.pageController});
  @override
  State<ActiveWorkoutCompletionPage> createState() =>
      _ActiveWorkoutCompletionPageState();
}

class _ActiveWorkoutCompletionPageState
    extends State<ActiveWorkoutCompletionPage> {
  late TextEditingController _liftTitleController;
  TextEditingController _liftDescriptionController = TextEditingController();
  late String yourFollowersOrFriends;
  late List<String> postOptions; // = ['Your followers', 'Only you'];
  late String selectedPostOption; // = 'Your followers';
  String? imageErrorText;
  String? pickedFilePath;
  final ImagePicker _picker = ImagePicker();
  String? activityPictureUrl;
  Widget? activityPicture;
  String? errorText;

  @override
  void initState() {
    super.initState();
    int hour = DateTime.now().hour;
    String workoutName = widget.appState.activeWorkout!.trainingDay.splitDay;
    if (workoutName.isEmpty) {
      workoutName = 'Workout';
    }
    if (!workoutName.toLowerCase().contains('workout')) {
      workoutName += ' Workout';
    }
    _liftTitleController = TextEditingController(
        text: (hour < 4 || hour >= 23)
            ? 'Midnight $workoutName'
            : (hour < 12
                ? 'Morning $workoutName'
                : (hour < 18
                    ? 'Afternoon $workoutName'
                    : (hour < 21
                        ? 'Evening $workoutName'
                        : 'Night $workoutName'))));

    yourFollowersOrFriends = widget.appState.currentUser.onlyFriendsCanViewPosts
        ? 'Your friends'
        : 'Your followers';
    postOptions = [yourFollowersOrFriends, 'Only you'];
    selectedPostOption = yourFollowersOrFriends;

    if (widget.appState.activeWorkout != null) {
      if (widget.appState.activeWorkout!.completionTitle != null) {
        _liftTitleController.text =
            widget.appState.activeWorkout!.completionTitle!;
      }
      if (widget.appState.activeWorkout!.completionDescription != null) {
        _liftDescriptionController.text =
            widget.appState.activeWorkout!.completionDescription!;
      }
      if (widget.appState.activeWorkout!.completionErrorText != null) {
        errorText = widget.appState.activeWorkout!.completionErrorText;
      }
      if (widget.appState.activeWorkout!.completionImageErrorText != null) {
        imageErrorText =
            widget.appState.activeWorkout!.completionImageErrorText;
      }
      if (widget.appState.activeWorkout!.completionPickedFilePath != null) {
        pickedFilePath =
            widget.appState.activeWorkout!.completionPickedFilePath!;
      }
      if (widget.appState.activeWorkout!.completionPostOption != null) {
        if (postOptions
            .contains(widget.appState.activeWorkout!.completionPostOption)) {
          selectedPostOption =
              widget.appState.activeWorkout!.completionPostOption!;
        } // else
        // Changed profile settings, selectedPostOption doesn't change
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final largeTitleStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyTitleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    // final labelMediumStyle = theme.textTheme.labelMedium!
    //     .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    // final formHeadingStyle = theme.textTheme.bodyMedium!
    //     .copyWith(color: theme.colorScheme.onBackground);
    // final formTextStyle = theme.textTheme.labelSmall!
    //     .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProgressBar(
              percentFill: 1.0,
            ),
            SizedBox(width: 10),
            Text('100%', style: greyTitleStyle),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 45),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 10),
                GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onBackground, size: 35),
                  ),
                ),
                Spacer(),
                GestureDetector(
                    onTapDown: (tapDownDetails) {
                      showOptionsDropdown(
                          context, tapDownDetails.globalPosition, appState);
                    },
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Icon(Icons.more_horiz,
                          color: theme.colorScheme.onBackground, size: 40),
                    )),
                SizedBox(width: 10),
              ],
            ),
            Center(
              child: Text(
                'Complete Your Workout',
                style: theme.textTheme.headlineSmall!
                    .copyWith(color: theme.colorScheme.onBackground),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text('Post to your Activities',
                  style: greyLabelStyle, textAlign: TextAlign.center),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                SizedBox(width: 16),
                SizedBox(width: 92, child: Text('Title', style: titleStyle)),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: theme.colorScheme.primaryContainer),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: TextField(
                        onChanged: (value) {
                          // Save in memory
                          appState.activeWorkout!.completionTitle = value;
                        },
                        style: TextStyle(color: theme.colorScheme.onBackground),
                        controller: _liftTitleController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65),
                                size: 20),
                            onPressed: () {
                              _liftTitleController.clear();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 16),
                SizedBox(
                    width: 92, child: Text('Description', style: titleStyle)),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: theme.colorScheme.primaryContainer),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: TextField(
                        onChanged: (value) {
                          // Save in memory
                          appState.activeWorkout!.completionDescription = value;
                        },
                        maxLines: 2,
                        style: TextStyle(
                            color: theme.colorScheme.onBackground,
                            fontSize: 12),
                        controller: _liftDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'How did it go?',
                          labelStyle: greyLabelStyle,
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65),
                                size: 20),
                            onPressed: () {
                              _liftDescriptionController.clear();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                'Add a photo',
                style: largeTitleStyle,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    addPicture(true);
                  },
                  child: Container(
                    width: 205,
                    height: 45,
                    decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined,
                            color: theme.colorScheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'Choose from camera roll',
                          style: labelStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 5),
                IconButton(
                    onPressed: () {
                      addPicture(false);
                    },
                    icon: Icon(Icons.camera_alt_outlined,
                        color: theme.colorScheme.primary)),
              ],
            ),
            if (imageErrorText != null) SizedBox(height: 5),
            if (imageErrorText != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(imageErrorText!,
                      style: labelStyle.copyWith(
                          color: imageErrorText! == 'Attached'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary)),
                  if (imageErrorText! == 'Attached') SizedBox(width: 5),
                  if (imageErrorText! == 'Attached')
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            pickedFilePath = null;
                            imageErrorText = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Icon(Icons.close,
                              color: theme.colorScheme.onBackground
                                  .withOpacity(.65),
                              size: 12),
                        ))
                ],
              ),
            SizedBox(height: 30),
            Center(child: Text('New PRs hit', style: largeTitleStyle)),
            if (appState.activeWorkout != null)
              for (int i = 0;
                  i < appState.activeWorkout!.prMessages.values.length;
                  i++)
                Center(
                    child: Text(
                        appState.activeWorkout!.prMessages.values
                            .toList()[i]
                            .split(':')[0],
                        style: greyLabelStyle)),
            if (appState.activeWorkout != null &&
                appState.activeWorkout!.prMessages.values.isEmpty)
              Center(child: Text('No PRs hit', style: greyLabelStyle)),
            SizedBox(height: 30),
            Center(
                child: Text(
              'Who can view your activity?',
              style: largeTitleStyle,
            )),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...postOptions.map((option) {
                  bool isSelected = option == selectedPostOption;
                  if (isSelected) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ButtonStyle(
                            backgroundColor: resolveColor(
                                theme.colorScheme.primaryContainer),
                            surfaceTintColor: resolveColor(
                                theme.colorScheme.primaryContainer)),
                        icon: Icon(
                            option == 'Only you'
                                ? Icons.person_off
                                : Icons.people,
                            color: theme.colorScheme.primary),
                        label: Text(
                          option,
                          style: titleStyle,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedPostOption = option;
                          });
                          // Save in memory
                          widget.appState.activeWorkout!.completionPostOption =
                              option;
                        },
                        style: ButtonStyle(
                            backgroundColor: resolveColor(
                                theme.colorScheme.primaryContainer),
                            surfaceTintColor: resolveColor(
                                theme.colorScheme.primaryContainer)),
                        icon: Icon(
                            option == 'Only you'
                                ? Icons.person_off_outlined
                                : Icons.people_outline,
                            size: 18,
                            color: theme.colorScheme.onBackground
                                .withOpacity(.65)),
                        label: Text(
                          option,
                          style: greyLabelStyle,
                        ),
                      ),
                    );
                  }
                }).toList(),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_liftTitleController.text.isEmpty) {
                    setState(() {
                      errorText = 'Please enter a title';
                    });
                    // Save in memory
                    appState.activeWorkout!.completionErrorText = errorText;
                    return;
                  }
                  if (_liftTitleController.text.length > 150) {
                    setState(() {
                      errorText = 'Please enter a shorter title';
                    });
                    // Save in memory
                    appState.activeWorkout!.completionErrorText = errorText;
                    return;
                  }
                  if (_liftDescriptionController.text.length > 500) {
                    setState(() {
                      errorText = 'Description is too long';
                    });
                    // Save in memory
                    appState.activeWorkout!.completionErrorText = errorText;
                    return;
                  }
                  uploadNewActivity(appState).then((value) {
                    Navigator.of(context).pop();
                    appState.cancelWorkout();
                  });
                },
                style: ButtonStyle(
                    backgroundColor: resolveColor(theme.colorScheme.primary),
                    surfaceTintColor: resolveColor(theme.colorScheme.primary)),
                icon: Padding(
                  padding: const EdgeInsets.fromLTRB(100, 0, 0, 0),
                  child: Icon(Icons.post_add,
                      color: theme.colorScheme.onBackground),
                ),
                label: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 100, 0),
                  child: Text('Post', style: largeTitleStyle),
                ),
              ),
            ),
            if (errorText != null) SizedBox(height: 5),
            if (errorText != null)
              Center(
                child: Text(errorText!,
                    style: labelStyle.copyWith(
                        color: theme.colorScheme.secondary)),
              ),
          ],
        ),
      ),
    );
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
          value: 'Jump to first page',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.first_page,
                color: theme.colorScheme.primary, size: 16),
            title: Text('Jump to first page',
                style:
                    labelStyle.copyWith(color: theme.colorScheme.onBackground)),
          ),
        ),
        PopupMenuItem(
          // height: 30,
          padding: EdgeInsets.zero,
          value: 'Cancel workout',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.do_disturb,
                color: theme.colorScheme.secondary, size: 16),
            title: Text('Cancel workout',
                style: labelStyle.copyWith(color: theme.colorScheme.secondary)),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Cancel workout') {
        Navigator.of(context).pop();
        appState.cancelWorkout();
      } else if (value == 'Jump to first page') {
        widget.pageController.jumpToPage(0);
      }
    });
  }

  Future<void> uploadNewActivity(MyAppState appState) async {
    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    if (pickedFilePath != null) {
      try {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('userPhotos')
            .child(appState.currentUser.username)
            .child('activityPictures')
            .child(millisecondsSinceEpoch.toString());

        final uploadTask = storageRef.putFile(File(pickedFilePath!));
        final snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          activityPictureUrl = await snapshot.ref.getDownloadURL();
          activityPicture =
              Image.network(activityPictureUrl!, fit: BoxFit.cover);
        } else {
          print('Failed to upload image');
        }
      } catch (e) {
        print('Error uploading activity photo $e');
      }
    }
    // widget.setProfilePageState(() {
    // Milliseconds to minutes
    int totalMinutesDuration = (millisecondsSinceEpoch -
            appState.activeWorkout!.timeStarted.millisecondsSinceEpoch) ~/
        60000;
    appState.currentUser.activities.insert(
        0,
        Activity(
            username: appState.currentUser.username,
            type: 'active_workout',
            title: _liftTitleController.text,
            description: _liftDescriptionController.text,
            trainingDay: appState.activeWorkout!.trainingDay,
            millisecondsFromEpoch: millisecondsSinceEpoch,
            totalMinutesDuration: totalMinutesDuration,
            usernamesThatLiked: [],
            commentsFromEachUsername: {},
            pictureUrl: activityPictureUrl,
            picture: activityPicture,
            private: selectedPostOption == 'Only you',
            prsHit: appState.activeWorkout!.prMessages.values.isEmpty
                ? null
                : appState.activeWorkout!.prMessages.values.toList(),
            gym: appState.userGym?.name,
            repRanges: getRepRanges(appState)));
    // });
    await appState.storeDataInFirestore();
    _showSnackBar();
    // Friends page
    if (appState.pageIndex == 13) {
      appState.reloadFriendsPage = true;
      appState.notifyTheListeners();
    }
  }

  List<String?> getRepRanges(MyAppState appState) {
    List<String?> repRanges = [];
    for (int i = 0;
        i < appState.activeWorkout!.trainingDay.muscleGroups.length;
        i++) {
      int min = 9999;
      int max = -1;
      Exercise exercise = getExercise(i, appState.activeWorkout!.trainingDay);
      for (int j = 0; j < exercise.splitRepsPerSet.length; j++) {
        min = math.min(exercise.splitRepsPerSet[j], min);
        max = math.max(exercise.splitRepsPerSet[j], max);
      }
      if (max == -1) {
        // No data
        repRanges.add(null);
      } else if (min == max) {
        // Only 1 value
        repRanges.add('$max reps');
      } else {
        // More than 1 value
        repRanges.add('$min-$max reps');
      }
    }
    return repRanges;
  }

  Exercise getExercise(int i, TrainingDay trainingDay) {
    Exercise exercise =
        widget.appState.muscleGroups[trainingDay.muscleGroups[i]]![
            widget.appState.splitDayExerciseIndices[trainingDay.dayOfWeek][i]];
    if (exercise.name != trainingDay.exerciseNames[i]) {
      print("ERROR - exercise name isn't same as exercise index");
      exercise = widget.appState.muscleGroups[trainingDay.muscleGroups[0]]!
          .firstWhere(
              (element) => element.name == trainingDay.exerciseNames[0]);
    }
    return exercise;
  }

  Future<void> addPicture(bool fromGallery) async {
    String? oldPath = pickedFilePath;
    pickedFilePath = await setActivityPicture(fromGallery);
    if (pickedFilePath == '2') {
      pickedFilePath = null;
      setState(() {
        imageErrorText = 'Failed to upload image';
      });
    } else if (pickedFilePath == '1') {
      pickedFilePath = oldPath;
      if (pickedFilePath == null) {
        setState(() {
          imageErrorText = null;
        });
      }
    } else {
      setState(() {
        imageErrorText = 'Attached';
      });
    }
    // Save in memory
    widget.appState.activeWorkout!.completionImageErrorText = imageErrorText;
    widget.appState.activeWorkout!.completionPickedFilePath = pickedFilePath;
  }

  Future<String> setActivityPicture(bool fromGallery) async {
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(
          source: fromGallery ? ImageSource.gallery : ImageSource.camera);
    } catch (e) {
      print(e);
      return '2';
    }

    if (pickedFile == null) {
      return '1'; // Exit when no image is selected or camera doesn't work
    }

    return pickedFile.path;
  }

  void _showSnackBar() {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: theme.colorScheme.onBackground,
        content: SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Text('Activity posted!',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.background))),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

void _showEditTimerWindow(BuildContext context, MyAppState appState,
    int? indexIfSingular, int exerciseNum) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return EditTimerWindow(appState, indexIfSingular, exerciseNum);
    },
  );
}

class EditTimerWindow extends StatefulWidget {
  final MyAppState appState;
  final int? indexIfSingular;
  final int exerciseNum;

  EditTimerWindow(this.appState, this.indexIfSingular, this.exerciseNum);

  @override
  _EditTimerWindowState createState() => _EditTimerWindowState();
}

class _EditTimerWindowState extends State<EditTimerWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  TextEditingController _liftMinutesController = TextEditingController();
  TextEditingController _liftSecondsController = TextEditingController();
  String? errorText;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    // final bodyStyle = theme.textTheme.bodyMedium!
    //     .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            body: Column(
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
                  child: Text(
                      widget.indexIfSingular != null
                          ? 'Edit total rest time'
                          : 'Edit total rest time for all exercises',
                      style: theme.textTheme.titleSmall!
                          .copyWith(color: theme.colorScheme.onBackground)),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: theme.colorScheme.primaryContainer),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: TextField(
                              maxLength: 2,
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground,
                                  fontSize: 12),
                              controller: _liftMinutesController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  labelText: '00',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  labelStyle: greyLabelStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(.4))),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text('Minutes',
                            style: greyLabelStyle.copyWith(fontSize: 9)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(' : ',
                            style: TextStyle(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(.65),
                                fontSize: 20,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 17),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: theme.colorScheme.primaryContainer),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: TextField(
                              maxLength: 2,
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground,
                                  fontSize: 12),
                              controller: _liftSecondsController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  labelText: '00',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  labelStyle: greyLabelStyle.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(.4))),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text('Seconds',
                            style: greyLabelStyle.copyWith(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      int minutes, seconds;
                      if (_liftMinutesController.text.isEmpty) {
                        minutes = 0;
                      } else {
                        minutes = int.parse(_liftMinutesController.text);
                      }
                      if (_liftSecondsController.text.isEmpty) {
                        seconds = 0;
                      } else {
                        seconds = int.parse(_liftSecondsController.text);
                      }
                      if (seconds < 0 ||
                          seconds > 60 ||
                          minutes < 0 ||
                          minutes > 60) {
                        setState(() {
                          errorText = 'Badly formatted duration';
                        });
                        return;
                      }
                      if (setNewTimer(minutes, seconds, appState)) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          errorText = 'Please try again';
                        });
                        return;
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            resolveColor(theme.colorScheme.primary),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primary)),
                    child: Text('Save', style: labelStyle),
                  ),
                ),
                if (errorText != null) SizedBox(height: 5),
                if (errorText != null)
                  Center(
                    child: Text(errorText!,
                        style: labelStyle.copyWith(
                            color: theme.colorScheme.secondary)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool setNewTimer(int minutes, int seconds, MyAppState appState) {
    if (appState.activeWorkout != null) {
      int totalSeconds = (minutes * 60) + seconds;
      if (widget.indexIfSingular == null) {
        // Set all non-null rest times to new total seconds
        int count = 0;
        appState.activeWorkout!.restTimesInSeconds =
            appState.activeWorkout!.restTimesInSeconds.map((e) {
          if (e == null) {
            count++;
            return e;
          } else {
            if (appState.activeWorkout!.timersSecondsLeft[count] != null &&
                appState.activeWorkout!.timersSecondsLeft[count]! >
                    totalSeconds) {
              appState.activeWorkout!.timersSecondsLeft[count] = totalSeconds;
            }
            count++;
            return totalSeconds;
          }
        }).toList();
        if (appState.currentSplit != null) {
          Split split = appState.currentSplit;
          split.trainingDays[appState.activeWorkout!.dayIndex]
                  .restTimeInSeconds =
              List.filled(
                  split.trainingDays[appState.activeWorkout!.dayIndex]
                      .restTimeInSeconds.length,
                  totalSeconds);
          appState.storeDataInFirestore();
        }
        appState.updateAllWorkoutTimerBanners();
        // appState.notifyTheListeners();
        return true;
      } else if (appState
              .activeWorkout!.restTimesInSeconds[widget.indexIfSingular!] !=
          null) {
        // Set if non-null rest timeappState
        appState.activeWorkout!.restTimesInSeconds[widget.indexIfSingular!] =
            totalSeconds;
        // Set timerSecondsLeft if out of bounds;
        if (appState.activeWorkout!
                    .timersSecondsLeft[widget.indexIfSingular!] !=
                null &&
            appState.activeWorkout!
                    .timersSecondsLeft[widget.indexIfSingular!]! >
                totalSeconds) {
          appState.activeWorkout!.timersSecondsLeft[widget.indexIfSingular!] =
              totalSeconds;
        }
        if (appState.currentSplit != null) {
          Split split = appState.currentSplit;
          if (split.trainingDays[appState.activeWorkout!.dayIndex]
                  .restTimeInSeconds.length >
              widget.exerciseNum) {
            split.trainingDays[appState.activeWorkout!.dayIndex]
                .restTimeInSeconds[widget.exerciseNum] = totalSeconds;
            appState.storeDataInFirestore();
          }
        }
        // Don't change a complete timer's message
        if (appState.activeWorkout!.bannerTitles[widget.indexIfSingular!] !=
            'Timer complete') {
          appState.updateWorkoutBannerAtIndex(
              widget.indexIfSingular!,
              totalSeconds > 0
                  ? 'Resting • ${formatSecondsString(totalSeconds)}'
                  : 'Timer complete');
        } else {
          appState.notifyTheListeners();
        }
        return true;
      }
    }
    return false;
  }
}

void _showSwapExerciseWindow(
  BuildContext context,
  MyAppState appState,
  List<Exercise> allExercises,
  List<Exercise> similarExercises,
  Exercise oldExercise,
  int dayIndex,
  int exerciseNum,
  List<Widget> pages,
  final ScrollController masterScrollController,
  final int set,
  final bool? supersetA,
  final int totalSetCount,
  final int totalSetIndex,
  final ActiveWorkout workout,
  final PageController pageController,
  final StateSetter setActiveWorkoutExercisePageState,
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
      return SwapExercises(
          appState,
          allExercises,
          similarExercises,
          oldExercise,
          initialFilterOption,
          dayIndex,
          exerciseNum,
          pages,
          masterScrollController,
          set,
          supersetA,
          totalSetCount,
          totalSetIndex,
          workout,
          pageController,
          setActiveWorkoutExercisePageState,
          percentCapacity);
    },
  );
}

// ignore: must_be_immutable
class SwapExercises extends StatefulWidget {
  final MyAppState appState;
  final List<Exercise> allExercises;
  final List<Exercise> similarExercises;
  final Exercise oldExercise;
  String selectedFilterOption;
  final int dayIndex;
  final int exerciseNum;
  final List<Widget> pages;
  final ScrollController masterScrollController;
  final int set;
  final bool? supersetA;
  final int totalSetCount;
  final int totalSetIndex;
  final ActiveWorkout workout;
  final PageController pageController;
  final StateSetter setActiveWorkoutExercisePageState;
  final double? percentCapacity;

  SwapExercises(
      this.appState,
      this.allExercises,
      this.similarExercises,
      this.oldExercise,
      this.selectedFilterOption,
      this.dayIndex,
      this.exerciseNum,
      this.pages,
      this.masterScrollController,
      this.set,
      this.supersetA,
      this.totalSetCount,
      this.totalSetIndex,
      this.workout,
      this.pageController,
      this.setActiveWorkoutExercisePageState,
      this.percentCapacity);

  @override
  _SwapExercisesState createState() => _SwapExercisesState();
}

class _SwapExercisesState extends State<SwapExercises>
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
                // if (pattern.isEmpty)
                //   Center(
                //       child: Text('Similar Exercises',
                //           style: theme.textTheme.titleSmall!.copyWith(
                //               color: theme.colorScheme.onBackground))),

                // if (pattern.isEmpty) SizedBox(height: 5),
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
                          // Replace pages with new exercise
                          for (int i = 0; i < widget.pages.length; i++) {
                            if (widget.pages[i] is ActiveWorkoutExercisePage &&
                                (widget.pages[i] as ActiveWorkoutExercisePage)
                                        .exercise
                                        .name ==
                                    widget.oldExercise.name) {
                              widget.setActiveWorkoutExercisePageState(() {
                                (widget.pages[i] as ActiveWorkoutExercisePage)
                                    .exercise = exercise;
                                // widget.pages[i] = ActiveWorkoutExercisePage(
                                //     exercise: exercise,
                                //     scrollController:
                                //         widget.masterScrollController,
                                //     set: widget.set,
                                //     numSets: exerciseInfo[2],
                                //     trainingDay:
                                //         split.trainingDays[widget.dayIndex],
                                //     supersetA: widget.supersetA,
                                //     appState: appState,
                                //     exerciseNum: widget.exerciseNum,
                                //     totalSetCount: widget.totalSetCount,
                                //     totalSetIndex: widget.totalSetIndex,
                                //     workout: widget.workout,
                                //     pageController: widget.pageController,
                                //     pages: widget.pages,
                                //     setActiveWorkoutWindowState:
                                //         widget.setActiveWorkoutWindowState);
                              });
                              appState.updateWorkoutBannerAtIndex(
                                  i, exercise.name);
                            }
                          }
                          // if (widget.pageController.page != null) {
                          //   widget.pageController.jumpToPage(
                          //       widget.pageController.page!.toInt() + 1);
                          //   widget.pageController.jumpToPage(
                          //       widget.pageController.page!.toInt() - 1);
                          // }
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

// class CustomAdWidget extends StatefulWidget {
//   @override
//   _CustomAdWidgetState createState() => _CustomAdWidgetState();
// }

// class _CustomAdWidgetState extends State<CustomAdWidget> {
//   BannerAd? _bannerAd;

//   @override
//   void initState() {
//     super.initState();
//     _createBannerAd();
//   }

//   void _createBannerAd() {
//     _bannerAd = BannerAd(
//       adUnitId: 'ca-app-pub-3940256099942544/2934735716',
//       size: AdSize.banner,
//       request: AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (_) {
//           // Ad has been loaded successfully
//           setState(() {});
//         },
//         onAdFailedToLoad: (ad, error) {
//           // Ad failed to load
//         },
//         onAdOpened: (ad) {
//           // Ad is opened
//         },
//         onAdClosed: (ad) {
//           // Ad is closed
//         },
//         onAdImpression: (ad) {
//           // Ad impression recorded
//         },
//       ),
//     );

//     _bannerAd!.load();
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Your custom ad layout here
//     return Container(
//       color: Colors.grey, // Replace with your desired background color
//       width: _bannerAd?.size.width.toDouble() ?? 320.0,
//       height: _bannerAd?.size.height.toDouble() ?? 50.0,
//       child: _bannerAd == null
//           ? Center(child: CircularProgressIndicator())
//           : AdWidget(ad: _bannerAd!),
//     );
//   }
// }
