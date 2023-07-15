import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/split.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

// import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/gym_page.dart';

const double WAIT_MULTIPLIER_TO_MINUTES = 10.0;

class IndividualExercisePage extends StatefulWidget {
  @override
  State<IndividualExercisePage> createState() => _IndividualExercisePageState();
}

class _IndividualExercisePageState extends State<IndividualExercisePage> {
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    // Unfocus the text fields when tapped outside
    FocusScope.of(context).unfocus();
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
    var appState = Provider.of<MyAppState>(context); // Listening to MyAppState

    // List<Exercise> exercises = appState.muscleGroups[appState.currentMuscleGroup]!;
    // Exercise exercise = Exercise(name: "", description: "", musclesWorked: "", videoLink: "", waitMultiplier: -1, mainMuscleGroup: "");

    int backIndex = 4; // Exercises Page
    Exercise exercise;
    Image? musclesWorkedImage;

    // if (appState.fromFavorites) {
    //   backIndex = 2;
    if (appState.fromSplitDayPage) {
      backIndex = 7; // Split Day Page
      exercise = appState.currentExerciseFromSplitDayPage;
      musclesWorkedImage = appState.currentMuscleWorkedImageFromSplitDayPage;
    } else if (appState.fromSearchPage) {
      backIndex = 8; // Search Page
      exercise = appState.currentExercise;
      musclesWorkedImage = appState.currentMuscleWorkedImage;
    } else if (appState.fromGymPage) {
      backIndex = 9;
      exercise = appState.currentExerciseFromGymPage;
      musclesWorkedImage = appState.currentMuscleWorkedImageFromGymPage;
    } else {
      // From exercises page or bottom icon
      exercise = appState.currentExercise;
      musclesWorkedImage = appState.currentMuscleWorkedImage;
    }

    String expectedWaitTime;
    if (appState.userGym == null) {
      expectedWaitTime = 'No gym selected';
    } else {
      String currentlyOpenString;
      DateTime now = DateTime.now();
      double percentCapacity =
          appState.avgGymCrowdData[now.weekday - 1][now.hour] / 12.0;
      if (appState.userGym!.openingHours == null) {
        // Assume it's open
        print('Estimated ${(percentCapacity * 100).toInt()}% capactiy');
        expectedWaitTime = (WAIT_MULTIPLIER_TO_MINUTES *
                exercise.waitMultiplier *
                percentCapacity)
            .toStringAsFixed(0);
      } else {
        final GymOpeningHours gymOpeningHours =
            GymOpeningHours(appState.userGym!.openingHours!);
        currentlyOpenString = gymOpeningHours.getCurrentlyOpenString();
        // 'Open - ...' or 'Open 24 hours'
        if (currentlyOpenString.startsWith('Open ')) {
          print('Estimated ${(percentCapacity * 100).toInt()}% capactiy');
          expectedWaitTime = (WAIT_MULTIPLIER_TO_MINUTES *
                  exercise.waitMultiplier *
                  percentCapacity)
              .toStringAsFixed(0);
        } else {
          // Closed
          expectedWaitTime = '${appState.userGym!.name} is currently closed';
        }
      }
    }

    print(
        "From search page: ${appState.fromSearchPage} ${appState.currentExercise}, From split day page: ${appState.fromSplitDayPage} ${appState.currentExerciseFromSplitDayPage}");

    List<Exercise> similarExercises = findSimilarExercises(exercise, appState);

    // print("${appState.fromFavorites}")

    // Below - DEPRECATED: Search of exercises

    // if (exercises == null) {
    //   print("ERROR - List of exercises is null");
    //   return Placeholder();
    // }

    // try {
    //     exercise =
    //     exercises.firstWhere((e) => e.name == appState.currentExercise.name);
    // }
    // catch (exception){
    //   // Have to find the exercise again
    //   String muscleGroup = appState.currentExercise.getMainMuscleGroup();
    //   appState.currentMuscleGroup = muscleGroup;
    //   var exercisesByMuscleGroup = appState.muscleGroups[muscleGroup];
    //   if (exercisesByMuscleGroup == null){
    //     print("ERROR - Muscle group is null");
    //     return Placeholder();
    //   }
    //   for (Exercise e in exercisesByMuscleGroup){
    //       if (e.name == appState.currentExercise.name){

    //         exercise = e; // Found exercise
    //       break;
    //     }
    //   }

    // Below: Deprecated slower method for finding exercise

    // outerLoop: for (String muscleGroup in appState.muscleGroups.keys){
    //   var exercisesByMuscleGroup = appState.muscleGroups[muscleGroup];
    //   // print(muscleGroup);
    //   if (exercisesByMuscleGroup == null){
    //     print("ERROR - Muscle group is null");
    //     return Placeholder();
    //   }
    //   for (Exercise e in exercisesByMuscleGroup){
    //     if (e.name == appState.currentExercise){
    //       exercise = e; // Found exercise
    //       break outerLoop;
    //     }
    //   }
    // }
    // }

    print('Wait Multiplier: ${exercise.waitMultiplier}');
    if (exercise.waitMultiplier == -1) {
      print("ERROR - Exercise is null");
      print(exercise);
      return Placeholder();
    }

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    IconData icon = Icons.abc;
    bool foundFavorite = false;
    for (Exercise favoriteExercise in appState.favoriteExercises) {
      if (exercise.name == favoriteExercise.name) {
        // If duplicate exercise is already in favorites
        icon = Icons.favorite;
        foundFavorite = true;
        break;
      }
    }
    if (!foundFavorite) {
      icon = Icons.favorite_border;
    }

    return GestureDetector(
      //   behavior: HitTestBehavior.opaque, // Handle the tap gesture directly
      onTap: _dismissKeyboard,
      child: SwipeBack(
        appState: appState,
        index: backIndex,
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              leading: Back(appState: appState, index: backIndex),
              leadingWidth: 70,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(flex: 3),
                      Text(
                        exercise.name,
                        style: titleStyle,
                      ),
                      Spacer(flex: 5),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Spacer(flex: 3),
                      Text(
                        '${exercise.starRating}',
                        style: theme.textTheme.labelSmall!.copyWith(
                            color: theme.colorScheme.onBackground
                                .withOpacity(.65)),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      for (int i = 0; i < 5; i++)
                        if (i + 1 <= exercise.starRating)
                          Icon(Icons.star,
                              color: theme.colorScheme.primary, size: 16)
                        else if (i + 0.5 <= exercise.starRating)
                          Icon(Icons.star_half,
                              color: theme.colorScheme.primary, size: 16)
                        else
                          Icon(Icons.star_border,
                              color: theme.colorScheme.primary, size: 16),
                      Spacer(flex: 5),
                    ],
                  ),
                ],
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
              bottom: TabBar(
                unselectedLabelColor: theme.colorScheme.onBackground,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Strength'),
                  Tab(text: 'Rating'),
                ],
              ),
            ),
            body:
                TabBarView(physics: NeverScrollableScrollPhysics(), children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: '2',
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullScreenPhoto(
                                            photoTag: '2',
                                            photo: Image.asset(
                                              'exercise_pictures/${exercise.name}_m.gif',
                                              frameBuilder: (BuildContext
                                                      context,
                                                  Widget child,
                                                  int? frame,
                                                  bool wasSynchronouslyLoaded) {
                                                // Calculate custom duration based on the desired animation speed
                                                const frameDuration = Duration(
                                                    milliseconds:
                                                        500); // Set your desired frame duration here
                                                return AnimatedSwitcher(
                                                  duration: frameDuration,
                                                  switchInCurve: Curves.linear,
                                                  switchOutCurve: Curves.linear,
                                                  layoutBuilder: (Widget?
                                                          currentChild,
                                                      List<Widget>
                                                          previousChildren) {
                                                    return Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        ...previousChildren,
                                                        if (currentChild !=
                                                            null)
                                                          currentChild,
                                                      ],
                                                    );
                                                  },
                                                  child: child,
                                                );
                                              },
                                            ),
                                          )));
                            },
                            child: Container(
                              color: theme.colorScheme.onBackground,
                              height: 150,
                              width: 150,
                              child:
                                  ImageContainer(exerciseName: exercise.name),
                            ),
                          ),
                        ),
                        if (musclesWorkedImage != null)
                          SizedBox(
                            width: 30,
                          ),
                        if (musclesWorkedImage != null)
                          Hero(
                            tag: '1',
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenPhoto(
                                        photoTag: '1',
                                        photo: musclesWorkedImage!),
                                  ),
                                );
                              },
                              child: Container(
                                color: theme.colorScheme.onBackground,
                                height: 150,
                                width: 150,
                                // Actual size: width: 496, height: 496
                                child: musclesWorkedImage,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if ((appState.splitDayReorderMode &&
                                        appState.editModeTempSplit != null) ||
                                    (!appState.splitDayReorderMode &&
                                        appState.currentSplit != null))
                                  SizedBox(width: 15),
                                if ((appState.splitDayReorderMode &&
                                        appState.editModeTempSplit != null) ||
                                    (!appState.splitDayReorderMode &&
                                        appState.currentSplit != null))
                                  ElevatedButton.icon(
                                    style: ButtonStyle(
                                      backgroundColor: resolveColor(
                                        theme.colorScheme.primary,
                                      ),
                                      surfaceTintColor: resolveColor(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                    onPressed: () {
                                      _showBottomUpWindow(
                                          context,
                                          appState.splitDayReorderMode
                                              ? appState.editModeTempSplit
                                              : appState.currentSplit,
                                          exercise,
                                          appState);
                                    },
                                    icon: Icon(Icons.list_alt,
                                        color: theme.colorScheme.onBackground,
                                        size: 16),
                                    label:
                                        Text('Add to Split', style: labelStyle),
                                  ),
                                SizedBox(width: 15),
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: resolveColor(
                                      theme.colorScheme.primaryContainer,
                                    ),
                                    surfaceTintColor: resolveColor(
                                      theme.colorScheme.primaryContainer,
                                    ),
                                  ),
                                  onPressed: () {
                                    appState.toggleFavorite(exercise);
                                  },
                                  icon: Icon(icon, size: 16),
                                  label: Text('Favorite', style: labelStyle),
                                ),
                                SizedBox(width: 15),
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: resolveColor(
                                      theme.colorScheme.primaryContainer,
                                    ),
                                    surfaceTintColor: resolveColor(
                                      theme.colorScheme.primaryContainer,
                                    ),
                                  ),
                                  onPressed: () {
                                    launchUrl(Uri.parse(exercise.videoLink));
                                  },
                                  icon: Icon(Icons.video_collection, size: 16),
                                  label: Text('Tutorial', style: labelStyle),
                                ),
                                SizedBox(width: 15),
                              ],
                            ),
                          ),
                          ExerciseCard(
                            exercise: exercise,
                            // expectedWaitTime: (WAIT_MULTIPLIER_TO_MINUTES *
                            //         exercise.waitMultiplier *
                            //         ((appState.gymCount as int).toDouble() /
                            //             appState.maxCapacity.toDouble()))
                            //     .toStringAsFixed(0),
                            expectedWaitTime: expectedWaitTime,
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 5, 0, 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Similar Exercises',
                                style: theme.textTheme.titleMedium!.copyWith(
                                    color: theme.colorScheme.onPrimary),
                              ),
                            ),
                          ),
                          SimilarExercisesRow(
                            similarExercises: similarExercises,
                            appState: appState,
                            scrollController: _scrollController,
                          ),

                          // SizedBox(
                          //     height:
                          //         200), // Add some empty space at the bottom for scrolling
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: StrengthLevelForm(exercise: exercise),
              ),
              RatingBarWidget(exercise),
              // Column(children: [
              // RatingBar(
              //   unratedColor: theme.colorScheme.tertiaryContainer,
              //   initialRating: initialStars!,
              //   minRating: 0,
              //   direction: Axis.horizontal,
              //   allowHalfRating: true,
              //   itemCount: 5,
              //   itemSize: 16,
              //   glow: false,
              //   ratingWidget: RatingWidget(
              //       full: Icon(Icons.star, color: theme.colorScheme.primary),
              //       half: Icon(Icons.star_half,
              //           color: theme.colorScheme.primary),
              //       empty: Icon(Icons.star_border,
              //           color: theme.colorScheme.primary)),
              //   updateOnDrag: true,
              //   onRatingUpdate: (double rating) {
              //     // Handle the selected rating value
              //     print('Selected rating: $rating');
              //     setState(() {
              //       starsToSubmit = rating;
              //     });
              //   },
              // ),
              // RatingBar.builder(
              //   unratedColor: theme.colorScheme.tertiaryContainer,
              //   initialRating: initialStars!,
              //   minRating: 0,
              //   direction: Axis.horizontal,
              //   allowHalfRating: true,
              //   itemCount: 5,
              //   itemSize: 16,
              //   glow: false,
              //   itemBuilder: (context, index) {
              //     return Icon(Icons.star, color: theme.colorScheme.primary);
              //   },
              //   onRatingUpdate: (rating) {
              //     // Handle the selected rating value
              //     print('Selected rating: $rating');
              //     setState(() {
              //       starsToSubmit = rating;
              //     });
              //   },
              // ),

              // ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class SimilarExercisesRow extends StatelessWidget {
  const SimilarExercisesRow({
    super.key,
    required this.similarExercises,
    required this.appState,
    required this.scrollController,
  });

  final List<Exercise> similarExercises;
  final MyAppState appState;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 10), // Buffer space before the first button
          ...List.generate(
            similarExercises.length,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  appState
                      .changeExerciseFromExercisePage(similarExercises[index]);
                  scrollController.animateTo(
                    0,
                    duration: Duration(
                        milliseconds: 500), // Adjust the duration as desired
                    curve: Curves.easeInOut, // Adjust the curve as desired
                  );
                },
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
                      child: ImageContainer(
                          exerciseName: similarExercises[index].name),
                      // child: ,
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: Text(
                        similarExercises[index].name,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).toList(),
          SizedBox(width: 10), // Buffer
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class StrengthLevelForm extends StatefulWidget {
  StrengthLevelForm({
    super.key,
    required this.exercise,
  });

  Exercise exercise;

  @override
  _StrengthLevelFormState createState() => _StrengthLevelFormState();
}

class _StrengthLevelFormState extends State<StrengthLevelForm> {
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightToRepsController = TextEditingController();
  TextEditingController repsToWeightController = TextEditingController();
  late bool canPredict;
  bool showRepsPrediction = false;
  bool showWeightPrediction = false;
  String repsPrediction = "";
  String weightPrediction = "";

  final _strengthFormKey = GlobalKey<FormState>();
  final _weightToRepsFormKey = GlobalKey<FormState>();
  final _repsToWeightFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    canPredict = widget.exercise.userOneRepMax != null;
  }

  void submitStrengthLevel(MyAppState appState) {
    String weight = weightController.text;
    String reps = repsController.text;
    bool isValidated = true;

    //TODO - Add kilo i/o functionality

    if (_strengthFormKey.currentState!.validate()) {
      _strengthFormKey.currentState!.save();
    } else {
      isValidated = false;
    }

    if (isValidated) {
      handleStrengthLevelSubmission(appState, weight, reps);

      setState(() {
        canPredict = true;
      });
    }
  }

  void submitWeightToReps() {
    String weight = weightToRepsController.text;
    bool isValidated = true;

    //TODO - Add kilo input functionality

    if (_weightToRepsFormKey.currentState!.validate()) {
      _weightToRepsFormKey.currentState!.save();
    } else {
      isValidated = false;
    }

    if (isValidated) {
      int prediction = calculateWeightToReps(
          int.parse(weight), widget.exercise.userOneRepMax!);
      if (prediction != 31) {
        setState(() {
          repsPrediction = prediction.toString();
          showRepsPrediction = true;
        });
      } else {
        setState(() {
          repsPrediction = '> ${prediction - 1}';
          showRepsPrediction = true;
        });
      }
    }
  }

  void submitRepsToWeight() {
    String reps = repsToWeightController.text;
    bool isValidated = true;

    //TODO - Add kilo output functionality

    if (_repsToWeightFormKey.currentState!.validate()) {
      _repsToWeightFormKey.currentState!.save();
    } else {
      isValidated = false;
    }

    if (isValidated) {
      setState(() {
        weightPrediction = calculateRepsToWeight(
                int.parse(reps), widget.exercise.userOneRepMax!)
            .toString();
        showWeightPrediction = true;
      });
    }
  }

  void handleStrengthLevelSubmission(
      MyAppState appState, String weight, String reps) {
    widget.exercise.userOneRepMax =
        calculateOneRepMax(int.parse(weight), int.parse(reps));
    appState.submitExercisePopularityDataToFirebase(
        appState.authUserId,
        widget.exercise.name,
        widget.exercise.mainMuscleGroup,
        widget.exercise.userRating,
        widget.exercise.userOneRepMax,
        widget.exercise.splitWeightAndReps,
        widget.exercise.splitWeightPerSet,
        widget.exercise.splitRepsPerSet);
    print(
        'submitted to firebase: Weight: $weight, Reps: $reps, One rep max: ${widget.exercise.userOneRepMax}');
  }

  String? validateWeightInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the weight in lbs';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a number';
    }
    if (double.parse(value) < 1) {
      // Greater than 200% occupancy
      return 'Please enter a positive number';
    }
    return null;
  }

  String? validateStrengthRepsInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the number of reps';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a number';
    }
    if (double.parse(value) < 1) {
      return 'Please enter a positive number';
    }
    if (double.parse(value) > 12) {
      return 'Enter number ≤ 12';
    }
    return null;
  }

  String? validateRepsInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the number of reps';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a number';
    }
    if (double.parse(value) < 1) {
      return 'Please enter a positive number';
    }
    if (double.parse(value) > 30) {
      return 'Enter number ≤ 30';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    ThemeData theme = Theme.of(context);

    final headingStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final textStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    final formTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final labelStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            canPredict ? "Edit Strength Level" : "Calculate Strength Level",
            style: headingStyle,
          ),
          SizedBox(
            height: 10,
          ),
          Form(
            key: _strengthFormKey,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.colorScheme.secondaryContainer),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                      child: TextFormField(
                        validator: (value) {
                          return validateWeightInput(value);
                        },
                        style: formTextStyle,
                        controller: weightController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: labelStyle,
                          labelText: 'Weight Lifted (lbs)',
                          errorMaxLines: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.colorScheme.secondaryContainer),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                      child: TextFormField(
                        validator: (value) {
                          return validateStrengthRepsInput(value);
                        },
                        style: formTextStyle,
                        controller: repsController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: labelStyle,
                          labelText: 'Number of Reps',
                          errorMaxLines: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                if (!canPredict)
                  ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor:
                            resolveColor(theme.colorScheme.primary),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primary)),
                    onPressed: () {
                      submitStrengthLevel(appState);
                    },
                    child: Text(
                      'Calculate',
                      style: labelStyle,
                    ),
                  ),
                if (canPredict)
                  ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor:
                            resolveColor(theme.colorScheme.primaryContainer),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primaryContainer)),
                    onPressed: () {
                      submitStrengthLevel(appState);
                    },
                    child: Text(
                      'Update',
                      style: labelStyle,
                    ),
                  ),
              ],
            ),
          ),
          if (canPredict)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Your One-Rep Max',
                  style: headingStyle,
                ),
                SizedBox(height: 5),
                Text(
                  '${widget.exercise.userOneRepMax} lbs',
                  style: textStyle,
                ),
                SizedBox(
                  height: 30,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       'Predict Reps',
                //       style: headingStyle,
                //     ),
                //     Spacer(),
                //     SizedBox(
                //       width: 32,
                //     ),
                //     Text(
                //       'Predict Weight',
                //       style: headingStyle,
                //     ),
                //     Spacer(),
                //   ],
                // ),
                Container(
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Predict Reps',
                              style: headingStyle,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Form(
                              key: _weightToRepsFormKey,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        theme.colorScheme.secondaryContainer),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 4),
                                  child: TextFormField(
                                    validator: (value) {
                                      return validateWeightInput(value);
                                    },
                                    style: formTextStyle,
                                    controller: weightToRepsController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelStyle: labelStyle,
                                      labelText: 'Weight (lbs)',
                                      errorMaxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (showRepsPrediction)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                  '$repsPrediction Reps',
                                  style: headingStyle,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                        child: IconButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(10)),
                              backgroundColor: resolveColor(
                                  theme.colorScheme.primaryContainer),
                              surfaceTintColor: resolveColor(
                                  theme.colorScheme.primaryContainer),
                            ),
                            onPressed: () {
                              submitWeightToReps();
                            },
                            icon: Icon(
                              Icons.trending_up,
                              color: theme.colorScheme.primary,
                            )),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Predict Weight',
                              style: headingStyle,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Form(
                              key: _repsToWeightFormKey,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        theme.colorScheme.secondaryContainer),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 4),
                                  child: TextFormField(
                                    validator: (value) {
                                      String? validate =
                                          validateRepsInput(value);
                                      if (validate == 'Enter number ≤ 30') {
                                        repsToWeightController.text = '30';
                                      }
                                      return validate;
                                    },
                                    style: formTextStyle,
                                    controller: repsToWeightController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelStyle: labelStyle,
                                      labelText: 'Number of Reps',
                                      errorMaxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (showWeightPrediction)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                  '$weightPrediction lbs',
                                  style: headingStyle,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                        child: IconButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(10)),
                              backgroundColor: resolveColor(
                                  theme.colorScheme.primaryContainer),
                              surfaceTintColor: resolveColor(
                                  theme.colorScheme.primaryContainer),
                            ),
                            onPressed: () {
                              submitRepsToWeight();
                            },
                            icon: Icon(
                              Icons.trending_up,
                              color: theme.colorScheme.primary,
                            )),
                      ),
                    ],
                  ),
                )

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     // ElevatedButton(
                //     //   style: ButtonStyle(
                //     //       backgroundColor:
                //     //           resolveColor(theme.colorScheme.primaryContainer),
                //     //       surfaceTintColor:
                //     //           resolveColor(theme.colorScheme.primaryContainer)),
                //     //   onPressed: () {
                //     //     print('Weight to Reps: ${weightToRepsController.text}');
                //     //   },
                //     //   child: Text(
                //     //     'Predict',
                //     //     style: TextStyle(color: theme.colorScheme.onBackground),
                //     //   ),
                //     // ),
                //     // ElevatedButton(
                //     //   style: ButtonStyle(
                //     //       backgroundColor:
                //     //           resolveColor(theme.colorScheme.primaryContainer),
                //     //       surfaceTintColor:
                //     //           resolveColor(theme.colorScheme.primaryContainer)),
                //     //   onPressed: () {
                //     //     print('Reps to Weight: ${repsToWeightController.text}');
                //     //   },
                //     //   child: Text(
                //     //     'Predict',
                //     //     style: TextStyle(color: theme.colorScheme.onBackground),
                //     //   ),
                //     // ),
                //   ],
                // ),
              ],
            ),
        ],
      ),
    );
  }
}

// class StarRatingButton extends StatefulWidget {
//   final Function(double) onRatingSelected;

//   const StarRatingButton({required this.onRatingSelected});

//   @override
//   _StarRatingButtonState createState() => _StarRatingButtonState();
// }

// class _StarRatingButtonState extends State<StarRatingButton> {
//   double _selectedRating = 0.0;

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return GestureDetector(
//       onHorizontalDragUpdate: (details) {
//         _updateRatingFromDrag(details.localPosition);
//       },
//       onHorizontalDragEnd: (_) {
//         widget.onRatingSelected(_selectedRating);
//       },
//       onTapUp: (details) {
//         final tapPosition = details.localPosition;
//         _updateRatingFromTap(tapPosition);
//         widget.onRatingSelected(_selectedRating);
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(5, (index) {
//           final starValue = (index + 1) * 0.5;
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedRating = starValue;
//               });
//               widget.onRatingSelected(_selectedRating);
//             },
//             child: _selectedRating >= starValue ? Icon(Icons.star, color: theme.colorScheme.primary,) : Icon(Icons.star_border, color: theme.colorScheme.primary,),
//           );
//         }),
//       ),
//     );
//   }

//   void _updateRatingFromDrag(Offset position) {
//     final box = context.findRenderObject() as RenderBox?;
//     if (box != null) {
//       final dx = position.dx.clamp(0.0, box.size.width);
//       final totalWidth = box.size.width;
//       final ratingPercentage = dx / totalWidth;
//       setState(() {
//         _selectedRating = ratingPercentage * 5.0;
//       });
//     }
//   }

//   void _updateRatingFromTap(Offset position) {
//     final box = context.findRenderObject() as RenderBox?;
//     if (box != null) {
//       final dx = position.dx.clamp(0.0, box.size.width);
//       final totalWidth = box.size.width;
//       final ratingPercentage = dx / totalWidth;
//       setState(() {
//         _selectedRating = ratingPercentage * 5.0;
//       });
//     }
//   }
// }

img.Image applyFloodFill(img.Image originalImage, List<String> musclesWorked,
    List<int> activation, Map<String, List<Pixel>> muscleLocations) {
  final modifiedImage = originalImage.clone();
  final highActivationColor = img.ColorInt8.rgba(235, 0, 0, 255);
  final mediumActivationColor = img.ColorInt8.rgba(235, 100, 100, 255);
  final lowActivationColor = img.ColorInt8.rgba(235, 160, 160, 255);
  final visitedPixels = Set<Pixel>();

  String muscle;
  int activationStrength; // 0 - 3
  bool hasFilledChest = false;
  bool hasFilledBiceps = false;
  img.ColorInt8 fillColor;
  for (int i = 0; i < musclesWorked.length; i++) {
    muscle = musclesWorked[i];
    activationStrength = activation[i];
    // Chest & biceps both only have 1 visual segment
    switch (muscle) {
      case 'Upper Chest':
        if (hasFilledChest) {
          continue;
        }
        muscle = 'Chest';
        hasFilledChest = true;
        break;
      case 'Mid Chest':
        if (hasFilledChest) {
          continue;
        }
        muscle = 'Chest';
        hasFilledChest = true;
        break;
      case 'Lower Chest':
        if (hasFilledChest) {
          continue;
        }
        muscle = 'Chest';
        hasFilledChest = true;
        break;
      case 'Bicep Long Head':
        if (hasFilledBiceps) {
          continue;
        }
        muscle = 'Biceps';
        hasFilledBiceps = true;
        break;
      case 'Bicep Short Head':
        if (hasFilledBiceps) {
          continue;
        }
        muscle = 'Biceps';
        hasFilledBiceps = true;
        break;
      case 'Brachialis':
        if (hasFilledBiceps) {
          continue;
        }
        muscle = 'Biceps';
        hasFilledBiceps = true;
        break;
    }
    if (muscleLocations[muscle] != null &&
        muscleLocations[muscle]!.isNotEmpty) {
      if (activationStrength == 3) {
        fillColor = highActivationColor;
      } else if (activationStrength == 2) {
        fillColor = mediumActivationColor;
      } else if (activationStrength == 1) {
        fillColor = lowActivationColor;
      } else {
        print(
            'ERROR - Activation strength is $activationStrength, not from 1-3');
        continue;
      }
      for (int j = 0; j < muscleLocations[muscle]!.length; j++) {
        floodFill(modifiedImage, muscleLocations[muscle]![j].x,
            muscleLocations[muscle]![j].y, fillColor, visitedPixels);
        // Clear visited pixels after each use
        visitedPixels.clear();
      }
    }
  }
  return modifiedImage;
}

void floodFill(
    img.Image image, int x, int y, img.Color color, Set<Pixel> visitedPixels) {
  if (!isInBounds(x, y, image.width, image.height) ||
      visitedPixels.contains(Pixel(x, y))) {
    return; // Stop if the coordinates are out of bounds or the pixel has been visited
  }

  final targetColor = image.getPixel(x, y);

  if (targetColor == color) {
    return; // Stop if the target pixel already has the desired color
  }

  final stack = <Pixel>[];
  stack.add(Pixel(x, y));

  while (stack.isNotEmpty) {
    final pixel = stack.removeLast();
    if (visitedPixels.contains(Pixel(pixel.x, pixel.y))) {
      // Already checked this pixel
      continue;
    }
    // visitedPixels.add(pixel); // remove

    int left = pixel.x;
    int right = pixel.x;

    // Find the left boundary of the fill area
    while (left >= 0 &&
        colorEquals(image.getPixel(left, pixel.y), targetColor, 40)) {
      // print('left: ${image.getPixel(left, pixel.y).r} ${image.getPixel(left, pixel.y).g} ${image.getPixel(left, pixel.y).b}');
      left--;
    }
    left++;

    // Find the right boundary of the fill area
    while (right < image.width &&
        colorEquals(image.getPixel(right, pixel.y), targetColor, 40)) {
      // print('right: ${image.getPixel(right, pixel.y).r} ${image.getPixel(right, pixel.y).g} ${image.getPixel(right, pixel.y).b}');
      right++;
    }
    right--;

    // Fill the scanline with the new color
    for (int i = left; i <= right; i++) {
      if (i != x || pixel.y != y) {
        // Don't set original pixel until done, otherwise targetColor will change
        image.setPixel(i, pixel.y, color);
      }
      visitedPixels.add(Pixel(i, pixel.y));

      // Check and push the neighboring pixels to the stack
      if (pixel.y > 0) {
        checkAndPushPixel(
            image, stack, i, pixel.y - 1, targetColor, color, visitedPixels);
      }
      if (pixel.y < image.height - 1) {
        checkAndPushPixel(
            image, stack, i, pixel.y + 1, targetColor, color, visitedPixels);
      }
    }
  }
  // Set original pixel
  image.setPixel(x, y, color);
}

void checkAndPushPixel(img.Image image, List<Pixel> stack, int x, int y,
    img.Color targetColor, img.Color color, Set<Pixel> visitedPixels) {
  if (colorEquals(image.getPixel(x, y), targetColor, 40) &&
      !visitedPixels.contains(Pixel(x, y))) {
    // print('adding ($x, $y): ${image.getPixel(x, y).r} ${image.getPixel(x, y).g} ${image.getPixel(x, y).b}');
    stack.add(Pixel(x, y));
    // visitedPixels.add(Pixel(x, y));
  }
}

bool isInBounds(int x, int y, int width, int height) {
  return x >= 0 && x < width && y >= 0 && y < height;
}

bool colorEquals(img.Color color1, img.Color color2, int threshold) {
  final redDiff = (color1.r - color2.r).abs();
  final greenDiff = (color1.g - color2.g).abs();
  final blueDiff = (color1.b - color2.b).abs();
  final alphaDiff = (color1.a - color2.a).abs();

  return redDiff <= threshold &&
      greenDiff <= threshold &&
      blueDiff <= threshold &&
      alphaDiff <= threshold;
}

class Pixel {
  final int x;
  final int y;

  Pixel(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pixel &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

// ignore: must_be_immutable
class ExerciseCard extends StatefulWidget {
  ExerciseCard({
    super.key,
    required this.exercise,
    // required this.name,
    // required this.description,
    // required this.mainMuscleGroup,
    // required this.musclesWorked,
    required this.expectedWaitTime,
    // required this.imageUrl,
    // required this.averageRating,
    // this.userRating});
  });

  Exercise exercise;

  // final String name = exercise.name;
  // final String description;
  // final String mainMuscleGroup;
  // final String musclesWorked;
  final String expectedWaitTime;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  // final String imageUrl;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context);
    // final titleStyle = theme.textTheme.displaySmall!.copyWith(
    //   color: theme.colorScheme.secondary,
    // );
    final headingStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onPrimary);
    final whiteTextStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final textStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onPrimary.withOpacity(.65));
    // final labelStyle = theme.textTheme.labelSmall!
    //     .copyWith(color: theme.colorScheme.onPrimary);

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      // child: Card(
      //   color: theme.colorScheme.surface,
      //   elevation: 10, // Shadow
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions',
              style: headingStyle,
            ),
            SizedBox(height: 5),
            Text(
              widget.exercise.description,
              style: textStyle,
            ),
            // Text(name,style: titleStyle),
            // Image.asset('assets/images/Barbell Bench Press.gif'),
            SizedBox(height: 15),
            Text(
              'Muscles Worked',
              style: headingStyle,
            ),
            SizedBox(height: 10),
            for (int i = 0; i < widget.exercise.musclesWorked.length; i++)
              MuscleFillBar(
                  muscle: widget.exercise.musclesWorked[i],
                  fillLevel: widget.exercise.musclesWorkedActivation[i],
                  textStyle: whiteTextStyle),
            SizedBox(height: 15),
            Text(
              'Expected Wait Time',
              style: headingStyle,
            ),
            SizedBox(height: 5),
            if (widget.expectedWaitTime != 'No gym selected' &&
                widget.expectedWaitTime !=
                    '${appState.userGym!.name} is currently closed')
              Text('${widget.expectedWaitTime} Minutes', style: textStyle),
            if (widget.expectedWaitTime == 'No gym selected' ||
                widget.expectedWaitTime ==
                    '${appState.userGym!.name} is currently closed')
              Text(widget.expectedWaitTime, style: textStyle),
            SizedBox(height: 15),
            // Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            // Column(children: [
            //   Text(
            //     'Average Rating',
            //     style: headingStyle,
            //   ),
            //   Row(
            //     children: [
            //       Text(
            //         '${widget.exercise.starRating}',
            //         style: textStyle,
            //       ),
            //       SizedBox(
            //         width: 3,
            //       ),
            //       for (int i = 0; i < 5; i++)
            //         if (i + 1 <= widget.exercise.starRating)
            //           Icon(Icons.star,
            //               color: theme.colorScheme.primary, size: 16)
            //         else if (i + 0.5 <= widget.exercise.starRating)
            //           Icon(Icons.star_half,
            //               color: theme.colorScheme.primary, size: 16)
            //         else
            //           Icon(Icons.star_border,
            //               color: theme.colorScheme.primary, size: 16),
            //     ],
            //   ),
            // ]),
            // Column(children: [
            //   if (widget.exercise.userRating == null)
            //     Text(
            //       'Leave a Rating',
            //       style: headingStyle,
            //     ),
            //   if (widget.exercise.userRating != null)
            //     Text(
            //       'Edit Rating',
            //       style: headingStyle,
            //     ),
            //   RatingBar.builder(
            //     unratedColor: theme.colorScheme.tertiaryContainer,
            //     initialRating: initialStars!,
            //     minRating: 0,
            //     direction: Axis.horizontal,
            //     allowHalfRating: true,
            //     itemCount: 5,
            //     itemSize: 16,
            //     glow: false,
            //     itemBuilder: (context, index) {
            //       return Icon(Icons.star,
            //           color: theme.colorScheme.primary);
            //     },
            //     onRatingUpdate: (rating) {
            //       // Handle the selected rating value
            //       print('Selected rating: $rating');
            //       setState(() {
            //         starsToSubmit = rating;
            //       });
            //     },
            //   ),
            //   ElevatedButton.icon(
            //     style: ButtonStyle(
            //         backgroundColor:
            //             resolveColor(theme.colorScheme.primaryContainer),
            //         surfaceTintColor:
            //             resolveColor(theme.colorScheme.primaryContainer)),
            //     onPressed: () {
            //       if (!_isSubmitButtonPressed &&
            //           widget.exercise.userRating != starsToSubmit) {
            //         appState.submitExercisePopularityDataToFirebase(
            //             appState.authUserId,
            //             widget.exercise.name,
            //             widget.exercise.mainMuscleGroup,
            //             starsToSubmit,
            //             widget.exercise.userOneRepMax,
            //             widget.exercise.splitWeightAndReps,
            //             widget.exercise.splitWeightPerSet,
            //             widget.exercise.splitRepsPerSet);
            //         _handleSubmitButtonPress(starsToSubmit!);
            //       }
            //     },
            //     label: submittedIcon,
            //     icon: submittedText,
            //   ),
            // ]),
            // ]),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Spacer(),
            //     Text(
            //       'Average Rating',
            //       style: headingStyle,
            //     ),
            //     Spacer(flex: 3),
            //     if (widget.exercise.userRating == null)
            //       Text(
            //         'Leave a Rating',
            //         style: headingStyle,
            //       ),
            //     if (widget.exercise.userRating != null)
            //       Text(
            //         'Edit Rating',
            //         style: headingStyle,
            //       ),
            //     Spacer(),
            //   ],
            // ),
            // SizedBox(height: 5),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Spacer(),
            //     Text(
            //       '${widget.exercise.starRating}',
            //       style: textStyle,
            //     ),
            //     SizedBox(
            //       width: 10,
            //     ),
            //     for (int i = 0; i < 5; i++)
            //       if (i + 1 <= widget.exercise.starRating)
            //         Icon(Icons.star, color: theme.colorScheme.primary, size: 16)
            //       else if (i + 0.5 <= widget.exercise.starRating)
            //         Icon(Icons.star_half,
            //             color: theme.colorScheme.primary, size: 16)
            //       else
            //         Icon(Icons.star_border,
            //             color: theme.colorScheme.primary, size: 16),
            //     Spacer(flex: 3),
            //     RatingBar.builder(
            //       unratedColor: theme.colorScheme.primaryContainer,
            //       initialRating: initialStars!,
            //       minRating: 0,
            //       direction: Axis.horizontal,
            //       allowHalfRating: true,
            //       itemCount: 5,
            //       itemSize: 16,
            //       glow: false,
            //       itemBuilder: (context, index) {
            //         return Icon(Icons.star, color: theme.colorScheme.primary);
            //       },
            //       onRatingUpdate: (rating) {
            //         // Handle the selected rating value
            //         print('Selected rating: $rating');
            //         setState(() {
            //           starsToSubmit = rating;
            //         });
            //       },
            //     ),
            //     Spacer(),
            //   ],
            // ),
            // SizedBox(
            //   height: 8,
            // ),
            // Container(
            //   alignment: Alignment.centerRight,
            //   child: ElevatedButton.icon(
            //     style: ButtonStyle(
            //         backgroundColor:
            //             resolveColor(theme.colorScheme.primaryContainer),
            //         surfaceTintColor:
            //             resolveColor(theme.colorScheme.primaryContainer)),
            //     onPressed: () {
            //       if (!_isSubmitButtonPressed &&
            //           widget.exercise.userRating != starsToSubmit) {
            //         appState.submitExercisePopularityDataToFirebase(
            //             appState.authUserId,
            //             widget.exercise.name,
            //             widget.exercise.mainMuscleGroup,
            //             starsToSubmit,
            //             widget.exercise.userOneRepMax,
            //             widget.exercise.splitWeightAndReps,
            //             widget.exercise.splitWeightPerSet,
            //             widget.exercise.splitRepsPerSet);
            //         _handleSubmitButtonPress(starsToSubmit!);
            //       }
            //     },
            //     label: submittedIcon,
            //     icon: submittedText,
            //   ),
            // ),
            Text(
              'Equipment Needed',
              style: headingStyle,
            ),
            SizedBox(height: 5),
            Text(
              equipmentNeededString,
              style: textStyle,
            ),
          ],
        ),
      ),
      // ),
    );
  }
}

class MuscleFillBar extends StatelessWidget {
  final String muscle;
  final int fillLevel;
  final TextStyle textStyle;

  const MuscleFillBar(
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
          width: 200,
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

// ignore: must_be_immutable
class RatingBarWidget extends StatefulWidget {
  Exercise exercise;
  RatingBarWidget(this.exercise);
  @override
  _RatingBarWidgetState createState() => _RatingBarWidgetState();
}

class _RatingBarWidgetState extends State<RatingBarWidget> {
  bool _isSubmitButtonPressed = false;
  Timer? _timer;
  double? initialStars;
  double? starsToSubmit;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleSubmitButtonPress(double starsToSubmit) {
    setState(() {
      _isSubmitButtonPressed = true;
    });

    widget.exercise.userRating =
        starsToSubmit; // Update exercise data in memory

    _timer = Timer(Duration(seconds: 2), () {
      setState(() {
        widget.exercise.userRating =
            starsToSubmit; // Update exercise data in memory
        _isSubmitButtonPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    ThemeData theme = Theme.of(context);

    initialStars = widget.exercise.userRating;
    initialStars ??= 2.5; // if null set to 2.5
    starsToSubmit ??= initialStars;
    print(widget.exercise.userRating);
    print("initial stars $initialStars");

    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final headingStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);

    Icon submittedIcon;
    Text submittedText;
    print(
        "$_isSubmitButtonPressed ${widget.exercise.userRating} $starsToSubmit");
    if (!_isSubmitButtonPressed &&
        widget.exercise.userRating != starsToSubmit) {
      submittedIcon =
          Icon(Icons.send, color: theme.colorScheme.primary, size: 16);
      submittedText = Text('Submit', style: labelStyle);
    } else {
      submittedIcon =
          Icon(Icons.check, color: theme.colorScheme.primary, size: 16);
      submittedText = Text('Submitted', style: labelStyle);
    }

    return Column(
      children: [
        SizedBox(height: 30),
        if (widget.exercise.userRating == null)
          Text(
            'Leave a Rating',
            style: headingStyle,
          ),
        if (widget.exercise.userRating != null)
          Text(
            'Edit Rating',
            style: headingStyle,
          ),
        SizedBox(height: 5),
        RatingBar(
          unratedColor: theme.colorScheme.tertiaryContainer,
          initialRating: initialStars!,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 16,
          glow: false,
          ignoreGestures: false,
          ratingWidget: RatingWidget(
            full: Icon(Icons.star, color: theme.colorScheme.primary),
            half: Icon(Icons.star_half, color: theme.colorScheme.primary),
            empty: Icon(Icons.star_border, color: theme.colorScheme.primary),
          ),
          updateOnDrag: true,
          onRatingUpdate: (double rating) {
            // Handle the selected rating value
            print('Selected rating: $rating');
            setState(() {
              starsToSubmit = rating;
            });
          },
        ),
        SizedBox(height: 5),
        ElevatedButton.icon(
          style: ButtonStyle(
              backgroundColor: resolveColor(theme.colorScheme.primaryContainer),
              surfaceTintColor:
                  resolveColor(theme.colorScheme.primaryContainer)),
          onPressed: () {
            if (!_isSubmitButtonPressed &&
                widget.exercise.userRating != starsToSubmit) {
              appState.submitExercisePopularityDataToFirebase(
                  appState.authUserId,
                  widget.exercise.name,
                  widget.exercise.mainMuscleGroup,
                  starsToSubmit,
                  widget.exercise.userOneRepMax,
                  widget.exercise.splitWeightAndReps,
                  widget.exercise.splitWeightPerSet,
                  widget.exercise.splitRepsPerSet);
              _handleSubmitButtonPress(starsToSubmit!);
            }
          },
          label: submittedIcon,
          icon: submittedText,
        ),
      ],
    );
  }
}

void _showBottomUpWindow(
    BuildContext context, Split split, Exercise exercise, MyAppState appState) {
  List<TrainingDay> initialSelectedTrainingDays = split.trainingDays
      .where((trainingDay) => trainingDay.exerciseNames.contains(exercise.name))
      .toList();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return BottomUpWindow(
        selectedTrainingDays: initialSelectedTrainingDays.toList(),
        split: split,
        trainingDays: split.trainingDays,
        onDonePressed: (selectedIndices) {
          List<int> unselectedIndices = [0, 1, 2, 3, 4, 5, 6];
          for (int selectedIndex in selectedIndices) {
            unselectedIndices.remove(selectedIndex);
          }
          // Handle selected weekdays here
          print('Selected training days: $selectedIndices');
          for (int selectedIndex in selectedIndices) {
            if (initialSelectedTrainingDays
                .contains(split.trainingDays[selectedIndex])) {
              continue;
            }
            appState.addMuscleGroupToSplit(
                split,
                selectedIndex,
                split.trainingDays[selectedIndex].muscleGroups.length,
                exercise.mainMuscleGroup,
                appState.muscleGroups[exercise.mainMuscleGroup]!
                    .indexOf(exercise),
                3,
                '',
                exercise.musclesWorked[0],
                exercise.name);
            print(
                'Added ${exercise.name} to the end of training day $selectedIndex');
          }
          for (int unselectedIndex in unselectedIndices) {
            if (!initialSelectedTrainingDays
                .contains(split.trainingDays[unselectedIndex])) {
              continue;
            }
            // Remove unselected
            appState.removeMuscleGroupFromSplit(
                split,
                unselectedIndex,
                split.trainingDays[unselectedIndex].exerciseNames
                    .indexOf(exercise.name));
            print(
                'Removed ${exercise.name} from training day $unselectedIndex');
          }
        },
      );
    },
  );
}

class BottomUpWindow extends StatefulWidget {
  final List<TrainingDay> selectedTrainingDays;
  final Split split;
  final List<TrainingDay> trainingDays;
  final void Function(List<int>) onDonePressed;

  BottomUpWindow({
    required this.selectedTrainingDays,
    required this.split,
    required this.trainingDays,
    required this.onDonePressed,
  });

  @override
  _BottomUpWindowState createState() => _BottomUpWindowState();
}

class _BottomUpWindowState extends State<BottomUpWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  int currentWeekdayIndex = DateTime.now().weekday - 1;

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

  void _toggleWeekday(TrainingDay trainingDay) {
    setState(() {
      if (widget.selectedTrainingDays.contains(trainingDay)) {
        widget.selectedTrainingDays.remove(trainingDay);
      } else {
        widget.selectedTrainingDays.add(trainingDay);
      }
    });
  }

  void _handleDonePressed() {
    List<int> selectedIndices = [];
    for (int i = 0; i < widget.trainingDays.length; i++) {
      if (widget.selectedTrainingDays.contains(widget.trainingDays[i])) {
        selectedIndices.add(i);
      }
    }
    widget.onDonePressed(selectedIndices);
    // _animationController.reverse().then((_) {
    Navigator.of(context).pop();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final headingStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    return SlideTransition(
      position: _animation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
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
                    child: Text('Cancel', style: labelStyle),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.trainingDays.length,
                itemBuilder: (context, index) {
                  String weekday = weekdays[index];
                  bool isSelected = widget.selectedTrainingDays
                      .contains(widget.trainingDays[index]);
                  return ListTile(
                    onTap: () {
                      _toggleWeekday(widget.trainingDays[index]);
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(weekday,
                            style: currentWeekdayIndex == index
                                ? headingStyle.copyWith(
                                    color: theme.colorScheme.primary)
                                : headingStyle),
                        Spacer(),
                        Text(widget.trainingDays[index].splitDay,
                            style: currentWeekdayIndex == index
                                ? labelStyle.copyWith(
                                    color: theme.colorScheme.primary)
                                : labelStyle),
                        SizedBox(width: 10),
                      ],
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            color: theme.colorScheme.primary)
                        : Icon(Icons.circle_outlined,
                            color: theme.colorScheme.primary),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: resolveColor(
                      theme.colorScheme.primary,
                    ),
                    surfaceTintColor: resolveColor(
                      theme.colorScheme.primary,
                    ),
                  ),
                  onPressed: _handleDonePressed,
                  child: Text('Done', style: headingStyle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
