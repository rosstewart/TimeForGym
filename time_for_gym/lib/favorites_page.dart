// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// // import 'dart:io';

// import 'package:time_for_gym/main.dart';
// import 'package:time_for_gym/exercise.dart';
// // import 'package:time_for_gym/muscle_groups_page.dart';

// class FavoritesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>(); // Listening to MyAppState

//     final theme = Theme.of(context);
//     final titleStyle = theme.textTheme.headlineSmall!.copyWith(
//       color: theme.colorScheme.onBackground,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         leading: Back(appState: appState, index: 0),
//         leadingWidth: 70,
//         title: Text(
//           "Favorite Exercises",
//           style: titleStyle,
//         ),
//         backgroundColor: theme.scaffoldBackgroundColor,
//       ),
//       body: ListView(
//         children: [
//           // Back(appState: appState, index: 0),

//           // Column(
//           //   children: [
//           //     Padding(
//           //       padding: const EdgeInsets.all(20),
//           //       child: Text(
//           //         "Favorite Exercises",
//           //         style: titleStyle,
//           //         textAlign: TextAlign.center,
//           //       ),
//           //     ),
//           //     SizedBox(
//           //       height: 20,
//           //     ),
//           if (appState.favoriteExercises.isEmpty)
//             Padding(
//               padding: const EdgeInsets.all(25),
//               child: Card(
//                 color: theme.colorScheme.surface,
//                 elevation: 10, // Shadow
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Text(
//                     "You have no favorite exercises",
//                     textAlign: TextAlign.center,
//                     style: theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onPrimary),
//                   ),
//                 ),
//               ),
//             ),
//           for (Exercise exercise in appState.favoriteExercises)
//             // ExerciseSelectorButton(exerciseName: exercise.name, fromFavorites: true,),
//             FavoriteExerciseSelectorButton(exercise: exercise),
//         ],
//       ),
//       // ),
//       // ],
//     );
//   }
// }
