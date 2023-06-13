import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:time_for_gym/main.dart';
// import 'package:flutter/services.dart' show rootBundle;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>(); // Listening to MyAppState
    // var pair = appState.current;
    final theme = Theme.of(context);
    final titleStyle1 = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontFamily: 'Courier',
    );
    final titleStyle2 = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
      fontFamily: 'Courier',
    );

    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Gym',
                    style: titleStyle1,
                  ),
                  TextSpan(
                    text: 'Brain',
                    style: titleStyle2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.self_improvement_sharp, color: theme.colorScheme.secondary,)
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: 
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PageSelectorButton(text: "Exercise Library", index: 8, icon: Icon(Icons.library_books),),
                PageSelectorButton(text: "Gym Occupancy", index: 3, icon: Icon(Icons.people),),
              ],
            ),
          ),
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
