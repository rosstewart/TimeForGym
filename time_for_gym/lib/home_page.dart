import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>(); // Listening to MyAppState
    // var pair = appState.current;
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          // child: Text("${wordPair.first} ${wordPair.second}", style: style),
          child: Text(
            "Time for Gym",
            style: titleStyle,
          ),
        ),
        SizedBox(
          height: 150,
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PageSelectorButton(text: "Exercises by Muscle Group", index: 1),
              SizedBox(
                height: 15,
              ),
              PageSelectorButton(text: "Favorite Exercises", index: 2),
              SizedBox(
                height: 15,
              ),
              PageSelectorButton(text: "Gym Crowdedness", index: 3),
              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     ElevatedButton.icon(
              //       onPressed: () {
              //         appState.toggleFavorite();
              //       },
              //       icon: Icon(icon),
              //       label: Text('Like'),
              //     ),
              //     SizedBox(width: 10),
              //     ElevatedButton(
              //       onPressed: () {
              //         appState.getNext();
              //       },
              //       child: Text('Next'),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

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
