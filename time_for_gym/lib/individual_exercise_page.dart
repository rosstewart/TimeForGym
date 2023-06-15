import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';

const WAIT_MULTIPLIER_TO_MINUTES = 10;

class IndividualExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context); // Listening to MyAppState

    // List<Exercise> exercises = appState.muscleGroups[appState.currentMuscleGroup]!;
    // Exercise exercise = Exercise(name: "", description: "", musclesWorked: "", videoLink: "", waitMultiplier: -1, mainMuscleGroup: "");

    int backIndex = 4; // Exercises Page
    Exercise exercise;

    // if (appState.fromFavorites) {
    //   backIndex = 2;
    if (appState.fromSplitDayPage) {
      backIndex = 7; // Split Day Page
      exercise = appState.currentExerciseFromSplitDayPage;
    } else if (appState.fromSearchPage) {
      backIndex = 8; // Search Page
      exercise = appState.currentExercise;
    } else {
      // From exercises page or bottom icon
      exercise = appState.currentExercise;
    }

    print(
        "From search page: ${appState.fromSearchPage} ${appState.currentExercise}, From split day page: ${appState.fromSplitDayPage} ${appState.currentExerciseFromSplitDayPage}");

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

    if (exercise.waitMultiplier == -1) {
      print("ERROR - Exercise is null");
      return Placeholder();
    }

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
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

    return SwipeBack(
      appState: appState,
      index: backIndex,
      child: Scaffold(
        appBar: AppBar(
          leading: Back(appState: appState, index: backIndex),
          leadingWidth: 70,
          title: Text(
            exercise.name,
            style: titleStyle,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: ListView(
          children: [
            // Back(appState: appState, index: backIndex),

            // Column(
            //   children: [
            //

            // Padding(
            //   padding: const EdgeInsets.all(20),
            //   // child: Text("${wordPair.first} ${wordPair.second}", style: style),
            //   child: Text(
            //     exercise.name,
            //     style: titleStyle,
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(100, 10, 100, 20),
              child: ImageContainer(exercise: exercise),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExerciseCard(
                    exercise: exercise,
                    // name: exercise.name,
                    // description: exercise.description,
                    // mainMuscleGroup: exercise.mainMuscleGroup,
                    // musclesWorked: exercise.musclesWorked,
                    expectedWaitTime: (WAIT_MULTIPLIER_TO_MINUTES *
                            exercise.waitMultiplier *
                            ((appState.gymCount as int).toDouble() /
                                appState.maxCapacity.toDouble()))
                        .toStringAsFixed(0),
                  ), // Remove decimal place
                  // imageUrl: exercise.imageUrl,
                  // averageRating: exercise.starRating,
                  // userRating: exercise.userRating),
                  StrengthLevelForm(exercise: exercise),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: resolveColor(
                                theme.colorScheme.primaryContainer),
                            surfaceTintColor: resolveColor(
                                theme.colorScheme.primaryContainer)),
                        onPressed: () {
                          appState.toggleFavorite(exercise);
                        },
                        icon: Icon(icon, color: theme.colorScheme.primary),
                        label: Text('Favorite exercise',
                            style: TextStyle(
                                color: theme.colorScheme.onBackground)),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: resolveColor(
                                theme.colorScheme.primaryContainer),
                            surfaceTintColor: resolveColor(
                                theme.colorScheme.primaryContainer)),
                        onPressed: () {
                          launchUrl(Uri.parse(exercise.videoLink));
                        },
                        child: Text('Tutorial video',
                            style: TextStyle(
                                color: theme.colorScheme.onBackground)),
                      ),
                    ],
                  )
                ],
              ),
            ),

            //

            // Text(exercise.name),
            // Text(exercise.description),
            // Text(exercise.musclesWorked),
            // Text(exercise.videoLink),
            // Text(exercise.waitMultiplier.toString()),
            // if (exercise != null)
            // ExerciseSelectorButton(exerciseName: exercise.name),
            // BigButton(text: muscleGroupName, index: 0),4
            //   ],
            // ),
            // ),
          ],
        ),
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
        appState.userID,
        widget.exercise.name,
        widget.exercise.mainMuscleGroup,
        widget.exercise.userRating,
        widget.exercise.userOneRepMax);
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
          Form(
            key: _strengthFormKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextFormField(
                    validator: (value) {
                      return validateWeightInput(value);
                    },
                    style: formTextStyle,
                    controller: weightController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelStyle: labelStyle,
                      labelText: 'Weight Lifted (lbs)',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    validator: (value) {
                      return validateStrengthRepsInput(value);
                    },
                    style: formTextStyle,
                    controller: repsController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelStyle: labelStyle,
                      labelText: 'Number of Reps',
                    ),
                  ),
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
                  height: 30,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Predict Reps',
                              style: headingStyle,
                            ),
                            Form(
                              key: _weightToRepsFormKey,
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
                                  labelStyle: labelStyle,
                                  labelText: 'Weight (lbs)',
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
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
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
                            Form(
                              key: _repsToWeightFormKey,
                              child: TextFormField(
                                validator: (value) {
                                  String? validate = validateRepsInput(value);
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
                                  labelStyle: labelStyle,
                                  labelText: 'Number of Reps',
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
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
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
