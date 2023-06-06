import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';
//import 'package:csv/csv.dart';

import 'package:time_for_gym/main.dart';

class MuscleGroupsPage extends StatelessWidget {
  /*
  Future<List<Exercise>> readExercisesFromCsv(String filePath) async {
    // Move to main class
    try {
      final file = File(filePath);
      final csvData = await file.readAsString();
      final csvList = CsvToListConverter().convert(csvData);
      // List<Exercise> readExercisesFromCsv(String filePath) {
      //   try {
      //     final file = File(filePath);
      //     final csvData = file.readAsString();
      //     final csvList = CsvToListConverter().convert(csvData as String);
      //
      final exercises = csvList
          .map((exerciseList) => Exercise(
                name: exerciseList[0],
                description: exerciseList[1],
                musclesWorked: exerciseList[2],
                videoLink: exerciseList[3],
                waitMultiplier: double.parse(exerciseList[4]),
              ))
          .toList();
      return exercises;
    } catch (exception) {
      print("CSV error");
      return <Exercise>[];
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    var muscleGroupMap = appState.muscleGroups;

    // var pair = appState.current;
    // final theme = Theme.of(context);
    // final titleStyle = theme.textTheme.displayMedium!.copyWith(
    //   color: theme.colorScheme.onBackground,
    // );

    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    // return Scaffold(
    //   appBar: AppBar(

    //           actions: <Widget>[ Row(
    //             mainAxisAlignment: MainAxisAlignment.end,
    //             children: [
    //               Back(appState: appState, index: 0),
    //             ],
    //           )],
    //   ),
    //   body:
    // return ListView(
    // shrinkWrap: true,
    // children: [
    return Scaffold(
      appBar: AppBar(
        leading: Back(appState: appState, index: 0),
        leadingWidth: 70,
        title: Text(
          "Muscle Groups",
          style: titleStyle,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: ListView(
        children: [
          // Back(appState: appState, index: 0),
          Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(20),
              //   child: Text(
              //     "Muscle Groups",
              //     style: titleStyle,
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              for (String muscleGroupName in muscleGroupMap.keys)
                MuscleGroupSelectorButton(muscleGroupName: muscleGroupName),
            ],
          ),
        ],
      ),
    );

    // ],
    // );
  }
}

// class Back extends StatelessWidget {
//   const Back({
//     super.key,
//     required this.appState,
//     required this.index,
//   });

//   final MyAppState appState;
//   final int index;

//   void togglePressed() {
//     appState.changePage(index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         SizedBox(width: 20),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Color.fromRGBO(200, 200, 200, 1),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
//             child: BackButton(
//               onPressed: togglePressed,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class BigButton extends StatelessWidget {
//   const BigButton({
//     super.key,
//     required this.text,
//     required this.index,
//   });

//   final String text;
//   final int index;

//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();
//     final theme = Theme.of(context);
//     final style = theme.textTheme.headlineSmall!.copyWith(
//       color: theme.colorScheme.onSecondary,
//     );

//     void togglePressed() {
//       appState.changePage(index);
//     }

//     return Padding(
//       padding: const EdgeInsets.all(30),
//       child: ElevatedButton(
//         style: ButtonStyle(
//           backgroundColor:
//               MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
//           // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//         ),
//         onPressed: togglePressed,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           // child: Text("${wordPair.first} ${wordPair.second}", style: style),
//           child: Center(
//             child: Text(
//               text,
//               style: style,
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
