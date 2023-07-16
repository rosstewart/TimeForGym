// import 'dart:ffi';

// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/split.dart';

import 'gym.dart';
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

  // void cancelEditChanges(var appState) {
  //   appState.toSplitDayEditMode(false);
  // }

  // void saveEditChanges(var appState) {
  //   appState.saveEditChanges();
  // }

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
    final titleStyle = theme.textTheme.titleMedium!.copyWith(
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
                ],
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          body: OuterScroll(
            scrollMode: appState.splitDayReorderMode,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: appState.splitDayReorderMode ? 20 : 0,
                  ),
                  // if (!appState.splitDayEditMode)
                  //   Text(
                  //     trainingDays[widget.dayIndex].splitDay,
                  //     style: titleStyle,
                  //     textAlign: TextAlign.center,
                  //   ),
                  // if (appState.splitDayEditMode)
                  //   Form(
                  //     key: _titleFormKey,
                  //     child: ConstrainedBox(
                  //       constraints: BoxConstraints(
                  //         maxWidth: 250,
                  //       ),
                  //       child: TextFormField(
                  //         initialValue: trainingDays[widget.dayIndex].splitDay,
                  //         style: titleStyle.copyWith(
                  //             color: theme.colorScheme.onBackground
                  //                 .withOpacity(0.65)),
                  //         textAlign: TextAlign.center,
                  //         validator: (value) {
                  //           if (value == null || value.trim().isEmpty) {
                  //             return 'Please enter a value';
                  //           }
                  //           return null; // Return null to indicate the input is valid
                  //         },
                  //         onChanged: (value) {
                  //           setState(() {
                  //             trainingDays[widget.dayIndex].splitDay = value;
                  //           });
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // if (!appState.splitDayEditMode &&
                  // !appState.splitDayReorderMode)
                  if (!appState.splitDayReorderMode)
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    // ElevatedButton.icon(
                    //     style: ButtonStyle(
                    //         backgroundColor: resolveColor(
                    //             theme.colorScheme.primaryContainer),
                    //         surfaceTintColor: resolveColor(
                    //             theme.colorScheme.primaryContainer)),
                    //     onPressed: () {
                    //       appState.toSplitDayEditMode(true);
                    //     },
                    //     icon: Icon(Icons.edit,
                    //         color: theme.colorScheme.primary),
                    //     label: Text(
                    //       "Edit Day",
                    //       style: TextStyle(
                    //           color: theme.colorScheme.onBackground),
                    //     )),
                    // if (muscleGroupCards.length >
                    //     1) // If 0 or 1 muscle groups, no option to reorder
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
                              appState.toSplitDayReorderMode(true);
                            },
                            icon: Icon(Icons.edit,
                                color: theme.colorScheme.primary, size: 16),
                            label: Text(
                              'Edit',
                              style: theme.textTheme.labelSmall!.copyWith(
                                  color: theme.colorScheme.onBackground),
                            )),
                        ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    resolveColor(theme.colorScheme.primary),
                                surfaceTintColor:
                                    resolveColor(theme.colorScheme.primary)),
                            onPressed: () {
                              // Don't include exercises already in the split day
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
                                  widget.dayIndex);
                            },
                            icon: Icon(Icons.add,
                                color: theme.colorScheme.onBackground,
                                size: 16),
                            label: Text(
                              'Add exercise',
                              style: theme.textTheme.labelSmall!.copyWith(
                                  color: theme.colorScheme.onBackground),
                            )),
                      ],
                    ),
                  //   ],
                  // ),
                  // if (appState.splitDayEditMode || appState.splitDayReorderMode)
                  if (appState.splitDayReorderMode)
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
                                  // if (appState.splitDayEditMode) {
                                  //   cancelEditChanges(appState);
                                  // } else {
                                  cancelReorderChanges(appState);
                                  // }
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
                                  // if (appState.splitDayEditMode) {
                                  // Can only edit title in edit mode, not reorder mode
                                  if (_titleFormKey.currentState!.validate()) {
                                    // saveEditChanges(appState);
                                    saveReorderChanges(appState);
                                  }
                                  // } else {
                                  //   saveReorderChanges(appState);
                                  // }
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

                  if (appState
                      .splitDayReorderMode) // Drag and drop muscle group cards
                    Column(
                      children: [
                        // Add to end, then reorder
                        // AddButton(
                        //     appState: appState,
                        //     dayIndex: widget.dayIndex,
                        //     cardIndex: split.trainingDays[widget.dayIndex]
                        //         .muscleGroups.length),
                        SizedBox(height: 15),
                        SizedBox(
                          height: 557,
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
                                      muscleGroupAndExerciseIndexAndNumSetsAndIdentifier =
                                      appState.removeTempMuscleGroupFromSplit(
                                          widget.dayIndex, oldIndex);
                                  muscleGroupCards.insert(newIndex, card);
                                  appState.addTempMuscleGroupToSplit(
                                      widget.dayIndex,
                                      newIndex,
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
                                          5]);

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
                  // if (appState.splitDayReorderMode)
                  //   AddButton(
                  //       appState: appState,
                  //       dayIndex: widget.dayIndex,
                  //       cardIndex: split.trainingDays[widget.dayIndex]
                  //           .muscleGroups.length), // Add to end
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

// class AddButton extends StatefulWidget {
//   const AddButton({
//     super.key,
//     required this.appState,
//     required this.dayIndex,
//     required this.cardIndex,
//   });

//   final MyAppState appState;
//   final int dayIndex;
//   final int cardIndex;

//   @override
//   State<AddButton> createState() => _AddButtonState();
// }

// class _AddButtonState extends State<AddButton> {
//   // String _selectedItem = '';
//   List<String> muscleGroups = [];
//   List<String> exerciseNames = [];

//   void findMuscleGroupOrExercise(
//       MyAppState appState, String name, List<Exercise> allExercises) {
//     if (muscleGroups.contains(name)) {
//       // Muscle Group - Add first exercise in muscle group
//       // 3 sets default
//       // Identifier and set name default
//       appState.addTempMuscleGroupToSplit(widget.dayIndex, widget.cardIndex,
//           name, 0, 3, "", "", appState.muscleGroups[name]![0].name);
//     } else {
//       // Exercise - Find exercise index of the main muscle group
//       int index = exerciseNames.indexOf(name);
//       if (index == -1) {
//         // Invalid search query
//         print("Invalid search query");
//         return;
//       }

//       String mainMuscleGroupName = allExercises[index].mainMuscleGroup;
//       List<Exercise>? exercises = appState.muscleGroups[mainMuscleGroupName];
//       if (exercises == null) {
//         print("ERROR - null search");
//         return;
//       } else {
//         // 3 sets default
//         // Identifier and set name default
//         int exerciseIndex =
//             exercises.indexWhere((element) => element.name == name);
//         if (exerciseIndex == -1) {
//           exerciseIndex = 0; // If exercise name was changed
//         }
//         appState.addTempMuscleGroupToSplit(
//             widget.dayIndex,
//             widget.cardIndex,
//             mainMuscleGroupName,
//             exerciseIndex,
//             3,
//             "",
//             "",
//             exercises[exerciseIndex].name);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return IconButton(
//         style: ButtonStyle(
//             backgroundColor: resolveColor(theme.colorScheme.primaryContainer),
//             surfaceTintColor: resolveColor(theme.colorScheme.primaryContainer)),
//         onPressed: () {
//           showDropdownMenu(context);
//           // widget.appState.addTempMuscleGroupToSplit(widget.dayIndex, widget.cardIndex, "Chest");
//         },
//         icon: Icon(
//           Icons.add,
//           color: theme.colorScheme.primary,
//         ));
//   }

//   void showDropdownMenu(BuildContext context) {
//     final ThemeData theme = Theme.of(context);
//     // var appState = context.watch<MyAppState>();
//     final RenderBox button = context.findRenderObject() as RenderBox;
//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;

//     muscleGroups = widget.appState.muscleGroups.keys.toList();

//     List<Exercise> allExercises = widget.appState.muscleGroups.values
//         .toList()
//         .expand((innerList) => innerList)
//         .toList();
//     exerciseNames = allExercises.map((exercise) => exercise.name).toList();

//     final RelativeRect position = RelativeRect.fromRect(
//       Rect.fromPoints(
//         button.localToGlobal(button.size.bottomLeft(Offset.zero),
//             ancestor: overlay),
//         button.localToGlobal(button.size.bottomRight(Offset.zero),
//             ancestor: overlay),
//       ),
//       Offset.zero & overlay.size,
//     );

//     showMenu<String>(
//       color: theme.colorScheme.primaryContainer,
//       surfaceTintColor: theme.colorScheme.primaryContainer,
//       context: context,
//       position: position,
//       items: [
//         PopupMenuItem<String>(
//           value: 'Search Muscle Groups',
//           child: ListTile(
//             leading: Icon(Icons.search, color: theme.colorScheme.primary),
//             title: Text('Search Muscle Groups',
//                 style: TextStyle(color: theme.colorScheme.onBackground)),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Search All Exercises',
//           child: ListTile(
//             leading: Icon(Icons.search, color: theme.colorScheme.primary),
//             title: Text('Search All Exercises',
//                 style: TextStyle(color: theme.colorScheme.onBackground)),
//           ),
//         ),
//       ],
//     ).then((value) {
//       if (value == 'Search Muscle Groups') {
//         performSearchAction(muscleGroups, allExercises, false);
//       } else if (value == 'Search All Exercises') {
//         performSearchAction(exerciseNames, allExercises, true);
//       }
//     });
//   }

//   void performSearchAction(
//       List<String> list, List<Exercise> allExercises, bool searchExercise) {
//     TextEditingController searchController = TextEditingController();
//     String searchQuery = '';

//     final ThemeData theme = Theme.of(context);
//     final TextStyle whiteTextStyle = theme.textTheme.bodyLarge!
//         .copyWith(color: theme.colorScheme.onBackground);
//     final TextStyle textStyle = TextStyle(
//       color: theme.colorScheme.primary,
//     );
//     final TextStyle labelStyle = theme.textTheme.labelSmall!
//         .copyWith(color: theme.colorScheme.onBackground);

//     final focusNode = FocusNode();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return GestureDetector(
//           onTap: focusNode.unfocus,
//           child: AlertDialog(
//             backgroundColor: theme.colorScheme.background,
//             surfaceTintColor: theme.colorScheme.background,
//             title: Text(
//               searchExercise ? 'Find Exercise' : 'Find Muscle Group',
//               style: whiteTextStyle,
//               textAlign: TextAlign.center,
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(height: 30),
//                 TypeAheadField<String>(
//                   textFieldConfiguration: TextFieldConfiguration(
//                     focusNode: focusNode,
//                     style: theme.textTheme.bodyMedium!
//                         .copyWith(color: theme.colorScheme.onBackground),
//                     controller: searchController,
//                     decoration: InputDecoration(
//                       labelText: 'Search',
//                       labelStyle: whiteTextStyle.copyWith(
//                           color:
//                               theme.colorScheme.onBackground.withOpacity(0.65)),
//                       floatingLabelStyle: whiteTextStyle.copyWith(
//                           color:
//                               theme.colorScheme.onBackground.withOpacity(0.65)),
//                     ),
//                   ),
//                   suggestionsCallback: (pattern) {
//                     return list.where((item) =>
//                         item.toLowerCase().contains(pattern.toLowerCase()));
//                   },
//                   itemBuilder: (context, suggestion) {
//                     return ListTile(
//                       title: Text(
//                         suggestion,
//                         style: labelStyle,
//                       ),
//                       trailing: Container(
//                         color: theme.colorScheme.onBackground,
//                         height: 45,
//                         width: 45,
//                         child: ImageContainer(exerciseName: suggestion),
//                       ),
//                     );
//                   },
//                   onSuggestionSelected: (suggestion) {
//                     setState(() {
//                       searchQuery = suggestion;
//                       searchController.text =
//                           suggestion; // Update the text field
//                     });
//                   },
//                 ),
//                 SizedBox(height: 50),
//                 // ElevatedButton.icon(
//                 //   style: ButtonStyle(
//                 //       backgroundColor:
//                 //           resolveColor(theme.colorScheme.primaryContainer),
//                 //       surfaceTintColor:
//                 //           resolveColor(theme.colorScheme.primaryContainer)),
//                 //   onPressed: () {
//                 //     setState(() {
//                 //       findMuscleGroupOrExercise(
//                 //           widget.appState, searchQuery, allExercises);
//                 //       // _selectedItem = searchQuery;
//                 //     });
//                 //     Navigator.of(context).pop();
//                 //   },
//                 //   icon: Icon(
//                 //     Icons.add,
//                 //     color: theme.colorScheme.primary,
//                 //   ),
//                 //   label: Text(
//                 //     'Add',
//                 //     style: textStyle.copyWith(
//                 //         color: theme.colorScheme.onBackground),
//                 //   ),
//                 // ),
//               ],
//             ),
//             actions: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text(
//                   'Cancel',
//                   style: textStyle.copyWith(color: theme.colorScheme.primary),
//                 ),
//               ),
//               SizedBox(width: 20),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     findMuscleGroupOrExercise(
//                         widget.appState, searchQuery, allExercises);
//                   });
//                   Navigator.of(context).pop();
//                 },
//                 child: Text(
//                   'Add',
//                   style: textStyle.copyWith(color: theme.colorScheme.primary),
//                 ),
//               ),
//               // ElevatedButton.icon(
//               //   style: ButtonStyle(
//               //       backgroundColor:
//               //           resolveColor(theme.colorScheme.primaryContainer),
//               //       surfaceTintColor:
//               //           resolveColor(theme.colorScheme.primaryContainer)),
//               //   onPressed: () {
//               //     Navigator.of(context).pop();
//               //   },
//               //   icon: Icon(
//               //     Icons.close,
//               //     color: theme.colorScheme.primary,
//               //   ),
//               //   label: Text(
//               //     'Cancel',
//               //     style:
//               //         textStyle.copyWith(color: theme.colorScheme.onBackground),
//               //   ),
//               // ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

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

  List<Exercise> similarExercises = [];

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

  void changeExercise(
      MyAppState appState, Exercise previousExercise, bool next) {
    widget.exerciseIndex =
        widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex];
    // Change exercise to next similar exercise
    similarExercises = appState.muscleGroups[previousExercise.mainMuscleGroup]!
        .where((element) =>
            element.musclesWorked.isNotEmpty &&
            element.musclesWorkedActivation.isNotEmpty &&
            previousExercise.musclesWorked.isNotEmpty &&
            previousExercise.musclesWorkedActivation.isNotEmpty &&
            element.musclesWorked[0] == previousExercise.musclesWorked[0]) // &&
        // element.musclesWorkedActivation[0] ==
        // previousExercise.musclesWorkedActivation[0])
        .toList();

    switch (widget.split.equipmentLevel) {
      case 0:
        // Bodyweight exercises only
        similarExercises.removeWhere((element) =>
            element.resourcesRequired != null &&
            element.resourcesRequired!.isNotEmpty &&
            element.resourcesRequired![0] != 'None' &&
            element.resourcesRequired![0] != 'Bodyweight' &&
            element.resourcesRequired![0] != 'Pull-Up Bar' &&
            element.resourcesRequired![0] != 'Parallel Bars');
        break;
      case 1:
        // Dumbbell and bodyweight only
        similarExercises.removeWhere((element) =>
            element.resourcesRequired != null &&
            element.resourcesRequired!.isNotEmpty &&
            element.resourcesRequired![0] != 'None' &&
            element.resourcesRequired![0] != 'Bodyweight' &&
            element.resourcesRequired![0] != 'Pull-Up Bar' &&
            element.resourcesRequired![0] != 'Parallel Bars' &&
            !element.resourcesRequired!.contains('Dumbbells'));
        break;
      case 2:
        // Only select exercises that are available at the gym
        if (appState.userGym != null) {
          // canSupportExercise checks if resources available or machines available are empty
          similarExercises.removeWhere(
              (element) => !appState.userGym!.canSupportExercise(element));
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
      Exercise nextExercise = similarExercises[0];
      setState(() {
        widget.exerciseIndex = appState
            .muscleGroups[previousExercise.mainMuscleGroup]!
            .indexOf(nextExercise);
      });
    }
    // If index can change
    if (similarExerciseIndex != -1 && similarExercises.length > 1) {
      if (next) {
        // If last item
        if (similarExerciseIndex >= similarExercises.length - 1) {
          return;
        }
        Exercise nextExercise = similarExercises[similarExerciseIndex + 1];
        setState(() {
          // Next similar exercise
          widget.exerciseIndex = appState
              .muscleGroups[previousExercise.mainMuscleGroup]!
              .indexOf(nextExercise);
        });
      } else {
        if (similarExerciseIndex == 0) {
          return;
        }
        Exercise previousExercise = similarExercises[similarExerciseIndex - 1];
        setState(() {
          // Next similar exercise
          widget.exerciseIndex = appState
              .muscleGroups[previousExercise.mainMuscleGroup]!
              .indexOf(previousExercise);
        });
      }
    }

    // widget.exerciseIndex =
    //     widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex];
    // if (next) {
    //   if (widget.exerciseIndex >=
    //       appState.muscleGroups[widget.muscleGroup]!.length - 1) {
    //     // if will be out of bounds
    //     return;
    //   }
    //   setState(() {
    //     widget.exerciseIndex++;
    //   });
    // } else {
    //   // previous
    //   if (widget.exerciseIndex == 0) {
    //     // if will be out of bounds
    //     return;
    //   }
    //   setState(() {
    //     widget.exerciseIndex--;
    //   });
    // }

    // Set the "default" exercise to view in that muscle group of the split
    widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex] =
        widget.exerciseIndex;
  }

  void toExercise(MyAppState appState, Exercise exercise) {
    // print(widget.exerciseIndices[appState.currentDayIndex]
    //     [widget.splitDayCardIndex]);
    // print(appState.muscleGroups[widget.muscleGroup]![widget
    //     .exerciseIndices[appState.currentDayIndex][widget.splitDayCardIndex]]);
    appState.currentExerciseFromSplitDayPage = exercise;
    appState.changePageToExercise(exercise);
  }

  // String? validateWeightInput(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return '*';
  //   }
  //   if (double.tryParse(value) == null) {
  //     return '*';
  //   }
  //   if (double.parse(value) < 1) {
  //     return '*';
  //   }
  //   return null;
  // }

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
            appState.authUserId,
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
          appState.authUserId,
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

  void showPopUpSimilarExercises(BuildContext context, MyAppState appState,
      StateSetter setSplitDayPageState, Exercise previousExercise) {
    final theme = Theme.of(context);

    widget.exerciseIndex =
        widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex];
    // Change exercise to next similar exercise
    similarExercises = appState.muscleGroups[previousExercise.mainMuscleGroup]!
        .where((element) =>
            element.musclesWorked.isNotEmpty &&
            element.musclesWorkedActivation.isNotEmpty &&
            previousExercise.musclesWorked.isNotEmpty &&
            previousExercise.musclesWorkedActivation.isNotEmpty &&
            element.musclesWorked[0] == previousExercise.musclesWorked[0]) // &&
        // element.musclesWorkedActivation[0] ==
        // previousExercise.musclesWorkedActivation[0])
        .toList();
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
        previousWeights = List.filled(previousWeights.length, '');
        previousReps = List.filled(previousReps.length, '');
      });
      // Set the "default" exercise to view in that muscle group of the split
      widget.exerciseIndices[widget.dayIndex][widget.splitDayCardIndex] =
          widget.exerciseIndex;
      print(widget.exerciseIndices);
      appState.storeSplitInSharedPreferences();
      appState.saveSplitDayExerciseIndicesData();
    }
    Exercise selectedExercise = previousExercise;
    TextStyle labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    TextStyle secondarySmallLabelStyle = labelStyle.copyWith(
        color: theme.colorScheme.secondary.withOpacity(.65), fontSize: 10);
    TextStyle primarySmallLabelStyle =
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
                          print(widget.exerciseIndices);
                          setSplitDayPageState(() {
                            widget.exerciseIndex = appState
                                .muscleGroups[previousExercise.mainMuscleGroup]!
                                .indexOf(selectedExercise);
                            previousExercise = selectedExercise;
                            // Reset previous weights and reps
                            previousWeights =
                                List.filled(previousWeights.length, '');
                            previousReps = List.filled(previousReps.length, '');
                          });
                          // Set the "default" exercise to view in that muscle group of the split
                          widget.exerciseIndices[widget.dayIndex]
                              [widget.splitDayCardIndex] = widget.exerciseIndex;
                          print(widget.exerciseIndices);
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
            content: Container(
              width: MediaQuery.of(context)
                  .size
                  .width, // Adjust the width as needed
              height: MediaQuery.of(context).size.height *
                  0.6, // Adjust the height as needed
              child: GridView.count(
                childAspectRatio: 1.0,
                crossAxisCount: 2, // Adjust the number of columns as needed
                children: List.generate(
                  similarExercises.length,
                  (index) => SizedBox(
                    // height: 120,
                    // width: 90,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (selectedExercise != (similarExercises[index])) {
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
                                      exerciseName:
                                          similarExercises[index].name),
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
                            similarExercisesInGym
                                    .contains(similarExercises[index])
                                ? availableText
                                : notAvailableText,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: similarExercisesInGym
                                    .contains(similarExercises[index])
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
                            similarExercisesInGym
                                    .contains(similarExercises[index])
                                ? availableText
                                : notAvailableText,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: similarExercisesInGym
                                    .contains(similarExercises[index])
                                ? primarySmallLabelStyle
                                : secondarySmallLabelStyle,
                          ),
                        if (similarExercises[index].starRating >= 4.0)
                          SizedBox(
                            height: 3,
                          ),
                        if (similarExercises[index].starRating >= 4.0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: theme.colorScheme.primary,
                                size: 14,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                "Popular",
                                style: primarySmallLabelStyle.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(.65)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
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
    var appState = context.watch<MyAppState>();

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

    final formHeadingStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    final formTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    print(appState.splitDayExerciseIndices);

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
          // if (appState.splitDayEditMode)
          //   AddButton(
          //       appState: appState,
          //       dayIndex: widget.dayIndex,
          //       cardIndex: widget.splitDayCardIndex),
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
                    // if (appState.splitDayEditMode)
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
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
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
                              // if (appState.splitDayEditMode)
                              //   Padding(
                              //     padding:
                              //         const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              //     child: IconButton(
                              //       onPressed: () {
                              //         changeExercise(
                              //             appState, currentExercise, false);
                              //       },
                              //       icon: Column(
                              //         children: [
                              //           Icon(Icons.navigate_before),
                              //           Text(
                              //             'Similar Exercise',
                              //             style: TextStyle(
                              //                 fontSize: 10,
                              //                 color: theme
                              //                     .colorScheme.onBackground
                              //                     .withOpacity(.65)),
                              //             maxLines: 2,
                              //           )
                              //         ],
                              //       ),
                              //       color: theme.colorScheme.onBackground,
                              //     ),
                              //   ),
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
                                            style: labelStyle,
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
                                            exerciseName: currentExercise.name),
                                      ),
                                    ]),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showPopUpSimilarExercises(
                                            context,
                                            appState,
                                            setState,
                                            currentExercise);
                                      },
                                      style: ButtonStyle(
                                          backgroundColor: resolveColor(
                                              theme.colorScheme.primary),
                                          surfaceTintColor: resolveColor(
                                              theme.colorScheme.primary)),
                                      child: Text(
                                        'Similar Exercises',
                                        style: labelStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  // If star rating of exercise >= 4, it is popular
                                  // if (appState.splitDayEditMode &&
                                  //     currentExercise.starRating >= 4.0)
                                  //   // if (widget.exerciseIndices[appState.currentDayIndex]
                                  //   //         [widget.splitDayCardIndex] ==
                                  //   //     0) // First exercise in group, thus most popular
                                  //   Padding(
                                  //     padding: const EdgeInsets.fromLTRB(
                                  //         0, 10, 0, 0),
                                  //     child: Row(
                                  //       children: [
                                  //         Icon(
                                  //           Icons.local_fire_department,
                                  //           color: theme.colorScheme.primary,
                                  //           size: 20,
                                  //         ),
                                  //         SizedBox(
                                  //           width: 3,
                                  //         ),
                                  //         Text(
                                  //           "Popular Exercise",
                                  //           style: theme.textTheme.bodyMedium!
                                  //               .copyWith(
                                  //                   color: theme.colorScheme
                                  //                       .onBackground),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // Placeholder to keep alignment the same with and without popular exercise label
                                  // if (appState.splitDayEditMode &&
                                  //     currentExercise.starRating < 4.0)
                                  //   Padding(
                                  //     padding: const EdgeInsets.fromLTRB(
                                  //         0, 10, 0, 0),
                                  //     child: Row(
                                  //       children: [
                                  //         Icon(
                                  //           Icons.local_fire_department,
                                  //           color: theme
                                  //               .colorScheme.primaryContainer,
                                  //           size: 20,
                                  //         ),
                                  //         SizedBox(
                                  //           width: 3,
                                  //         ),
                                  //         Text(
                                  //           "Popular Exercise",
                                  //           style: theme.textTheme.bodyMedium!
                                  //               .copyWith(
                                  //                   color: theme.colorScheme
                                  //                       .primaryContainer),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                ],
                              ),
                              // if (appState.splitDayEditMode)
                              //   Padding(
                              //     padding:
                              //         const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              //     child: IconButton(
                              //       onPressed: () {
                              //         changeExercise(
                              //             appState, currentExercise, true);
                              //       },
                              //       icon: Column(
                              //         children: [
                              //           Icon(Icons.navigate_next),
                              //           Text('Similar Exercise',
                              //               style: TextStyle(
                              //                   fontSize: 10,
                              //                   color: theme
                              //                       .colorScheme.onBackground
                              //                       .withOpacity(.65)))
                              //         ],
                              //       ),
                              //       color: theme.colorScheme.onBackground,
                              //     ),
                              //   ),
                            ],
                          ),
                          // if (appState.splitDayEditMode)
                          // IconButton(
                          //   onPressed: () {
                          //     appState.removeTempMuscleGroupFromSplit(
                          //       widget.dayIndex,
                          //       widget.splitDayCardIndex,
                          //     );
                          //   },
                          //   icon: Icon(Icons.delete_forever),
                          //   color: theme.colorScheme.primary,
                          // ),
                          // if (!appState.splitDayEditMode)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      BorderRadius.circular(10),
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
                                                          border:
                                                              InputBorder.none,
                                                          floatingLabelBehavior:
                                                              FloatingLabelBehavior
                                                                  .never,
                                                          labelStyle: labelStyle
                                                              .copyWith(
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
                                                    if (weightSuffixIcons[0] !=
                                                        null)
                                                      weightSuffixIcons[0]!,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (showMoreSets)
                                              for (int i = 1; i < numSets; i++)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 10, 0, 0),
                                                  child: Container(
                                                    // width: 80,
                                                    // height: 44,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: theme.colorScheme
                                                            .tertiaryContainer),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(8, 0, 8, 0),
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
                                                                counterText: '',
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
                                                      BorderRadius.circular(10),
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
                                                          border:
                                                              InputBorder.none,
                                                          floatingLabelBehavior:
                                                              FloatingLabelBehavior
                                                                  .never,
                                                          labelStyle: labelStyle
                                                              .copyWith(
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
                                              for (int i = 1; i < numSets; i++)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 10, 0, 0),
                                                  child: Container(
                                                    // width: 80,
                                                    // height: 44,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: theme.colorScheme
                                                            .tertiaryContainer),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(8, 0, 8, 0),
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
                                                                counterText: '',
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
                                                            repsSuffixIcons[i]!,
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
                                              style: theme.textTheme.labelSmall!
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
                                                  color:
                                                      theme.colorScheme.primary,
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
          // SizedBox(width: 20),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  width: MediaQuery.of(context).size.width * .8,
                  backgroundColor: theme.colorScheme.onBackground,
                  content: SizedBox(
                      width: MediaQuery.of(context).size.width * .8,
                      child: Text(
                          'Removed ${appState.editModeTempSplit.trainingDays[widget.dayIndex].exerciseNames[widget.splitDayCardIndex]}',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: theme.colorScheme.background))),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              appState.removeTempMuscleGroupFromSplit(
                widget.dayIndex,
                widget.splitDayCardIndex,
              );
            },
            icon: Icon(Icons.delete_forever, size: 20),
            color: theme.colorScheme.primary,
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            color: theme.colorScheme.onBackground,
            height: 60,
            width: 60,
            child: ImageContainer(exerciseName: currentExercise.name),
          ),
          SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 220,
            child: Text(
              // exercise index
              currentExercise.name,
              style: labelStyle,
              textAlign: TextAlign.start,
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
  // String identifier = widget.split.trainingDays[widget.dayIndex]
  //     .exerciseIdentifiers[widget.splitDayCardIndex];
  // Gym? gym = appState.userGym;
  // Map<String, int> resourcesAvailable;

  // if (widget.split.equipmentLevel == 2) {
  //   resourcesAvailable = appState.userGym != null
  //       ? appState.userGym!.resourcesAvailable
  //       : {};
  // } else {
  //   resourcesAvailable = {};
  //   resourcesAvailable['Dumbbells'] = 1;
  // }

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
            // } else if (element.resourcesRequired!.contains('Dumbbells') ||
            //     element.resourcesRequired![0] == 'None' ||
            //     element.resourcesRequired![0] == 'Bodyweight' ||
            //     element.resourcesRequired![0] == 'Pull-Up Bar' ||
            //     element.resourcesRequired![0] == 'Parallel Bars') {
            //   // activation == 2
            //   // Preferable save dumbbell exercise over bodyweight one
            //   if (savedBodyweight) {
            //     savedIndex = i;
            //     savedBodyweight = false;
            //   } else {
            //     savedIndex ??= i;
            //   }
            // }
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

void _showSearchExercisesWindow(BuildContext context, MyAppState appState,
    List<Exercise> allExercises, int dayIndex) {
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
      return SearchExercises(
          appState, allExercises, initialFilterOption, dayIndex);
    },
  );
}

// ignore: must_be_immutable
class SearchExercises extends StatefulWidget {
  MyAppState appState;
  List<Exercise> allExercises;
  String selectedFilterOption;
  int dayIndex;

  SearchExercises(this.appState, this.allExercises, this.selectedFilterOption,
      this.dayIndex);

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
                              child:
                                  ImageContainer(exerciseName: exercise.name),
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
                          subtitle: Text(
                            exercise.mainMuscleGroup,
                            style: labelStyle.copyWith(
                                color: theme.colorScheme.primary),
                            maxLines: 2,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              appState.addMuscleGroupToSplit(
                                  appState.currentSplit,
                                  widget.dayIndex,
                                  appState
                                      .currentSplit
                                      .trainingDays[widget.dayIndex]
                                      .muscleGroups
                                      .length,
                                  exercise.mainMuscleGroup,
                                  appState
                                      .muscleGroups[exercise.mainMuscleGroup]!
                                      .indexOf(exercise),
                                  3,
                                  '',
                                  exercise.musclesWorked[0],
                                  exercise.name);
                              setState(() {
                                widget.allExercises.remove(exercise);
                              });
                              _showSnackBar(theme, exercise);
                              print(
                                  'Added ${exercise.name} to the end of training day ${widget.dayIndex}');
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
