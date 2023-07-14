import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class GymCrowdPage extends StatefulWidget {
  @override
  State<GymCrowdPage> createState() => _GymCrowdPageState();
}

class _GymCrowdPageState extends State<GymCrowdPage> {
  void _dismissKeyboard() {
    // Unfocus the text fields when tapped outside
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    // Create a reference to the Firebase Realtime Database

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: SwipeBack(
          appState: appState,
          index: 0,
          child: Scaffold(
        appBar: AppBar(
          leading: Back(appState: appState, index: 0),
          leadingWidth: 70,
          title: Text(
            "Gym Occupancy",
            style: titleStyle,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: ListView(
            children: [
              SizedBox(height: 30),
              // Padding(
              //   padding: const EdgeInsets.all(20),
              //   child: Text(
              //     "Gym Occupancy",
              //     style: titleStyle,
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              GymCrowdCard(
                  chart: CustomCircularProgressIndicator(
                      percentCapacity: (appState.gymCount).toDouble() /
                          (appState.maxCapacity).toDouble(),
                      strokeWidth: 10)),
              // PageSelectorButton(text: "Popular times", index: 6),
              // FloatingActionButton(
              //   onPressed: () {
              //     // Code to execute when the button is pressed
              //     submitOccupancyData(69);
              //   },
              //   tooltip: 'Submit Current Occupancy',
              //   child: Icon(Icons.add),
              // ),
              SizedBox(
                height: 50,
              ),
              OccupancyForm(),
            ],
          ),
        ),
        // ),
      ),
    );
  }
}

// Define a data model for the occupancy data
class OccupancyData {
  int currentOccupancy;
  String timestamp;

  OccupancyData(this.currentOccupancy, this.timestamp);

  Map<String, dynamic> toJson() => {
        'currentOccupancy': currentOccupancy,
        'timestamp': timestamp,
      };
}

class OccupancyForm extends StatefulWidget {
  @override
  _OccupancyFormState createState() => _OccupancyFormState();
}

class _OccupancyFormState extends State<OccupancyForm> {
  final _formKey = GlobalKey<FormState>();
  late String _occupancy;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );

    if (!appState.hasSubmittedData) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "At the gym? Help us collect data:",
                style: headingStyle,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(color: theme.colorScheme.onPrimary),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: theme
                              .colorScheme.onPrimary), // Color when focused
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: theme.colorScheme
                              .secondary), // Color when there's an error
                    ),
                    labelText: 'Perceived percent occupancy (e.g: 50%)',
                    labelStyle: theme.textTheme.bodyMedium!
                        .copyWith(color: theme.colorScheme.onBackground),
                    // floatingLabelAlignment: FloatingLabelAlignment.center,
                  ),
                  validator: (value) {
                    if (value!.contains('%')) {
                      value = value.replaceAll('%', '');
                    }
                    if (value.isEmpty) {
                      return 'Please enter the current occupancy';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a number';
                    }
                    if (double.parse(value) < 1 || double.parse(value) > 100) {
                      // Greater than 200% occupancy
                      return 'Please enter a number between 1 and 100';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value!.contains('%')) {
                      value = value.replaceAll('%', '');
                    }
                    _occupancy = value;
                  },
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        resolveColor(theme.colorScheme.primaryContainer),
                    surfaceTintColor:
                        resolveColor(theme.colorScheme.primaryContainer)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Save the occupancy data to the database
                    if (_occupancy.contains('%')) {
                      // Is a percent
                      _occupancy.replaceAll('%', '');
                      appState.submitOccupancyDataToFirebase(
                          ((double.parse(_occupancy) / 100) * 200).toInt());
                    } else {
                      // Is an occupancy number
                      appState.submitOccupancyDataToFirebase(
                          double.parse(_occupancy).toInt());
                    }
                  }
                },
                label: Icon(Icons.send, color: theme.colorScheme.primary,),
                icon: Text(
                  'Submit',
                  style: TextStyle(color: theme.colorScheme.onBackground),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "Thanks for submitting!",
          textAlign: TextAlign.center,
          style: headingStyle,
        ),
      );
    }
  }
}
