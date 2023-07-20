// import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:numberpicker/numberpicker.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
// import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/gym.dart';

import 'package:time_for_gym/exercise.dart';
// import 'api_keys.dart';

// ignore: must_be_immutable
class GymPage extends StatefulWidget {
  GymPage({required this.gym, required this.isSelectedGym});

  Gym? gym;
  bool isSelectedGym;

  @override
  State<GymPage> createState() => _GymPageState();
}

class _GymPageState extends State<GymPage> {
  // final places = GoogleMapsPlaces(apiKey: googleMapsApiKey);

  // List<String> urls = [];
  // List<Widget> images = [];

  DateTime currentTime = DateTime.now();

  bool editResourcesMode = false;
  bool editMachinesMode = false;

  late bool isSelectedGym;
  late String currentlyOpenString;
  List<int> chartOpeningTimes = [0, 0, 0, 0, 0, 0, 0];
  List<int> chartClosingTimes = [24, 24, 24, 24, 24, 24, 24];
  // bool showAllOpenTimes = false;

  // List<String> resourceKeys = [
  //   'Barbell',
  //   'Dumbbells',
  //   'Bench',
  //   'Squat Rack',
  //   'Cable',
  //   'Cable Lat Pulldown',
  //   'Cable Row',
  //   'Machine',
  //   'EZ-bar',
  //   'Pull-Up Bar',
  //   'Preacher Bench',
  //   'Parallel Bars',
  // ];

  List<String> resourceNames = [
    'Free Weights',
    'Adjustable Benches',
    'Cables / Machines',
    'Bench Presses',
    'Calisthenics',
    'Cardio'
  ];
  List<bool> showResources = [false, false, false, false, false, false];

  List<String> freeWeightsResourceKeys = [
    'Barbell',
    'Dumbbells',
    'Squat Rack',
    'EZ-bar',
    'Kettlebell',
  ];

  List<String> benchesResourceKeys = [
    'Bench',
    'Decline Bench',
    'Preacher Bench',
    'Hyper Extension',
  ];

  List<String> cableResourceKeys = [
    'Cable',
    'Cable Lat Pulldown',
    'Cable Row',
    'Machine',
    'Smith Machine',
  ];

  List<String> benchPressResourceKeys = [
    'Bench Press',
    'Incline Bench Press',
    'Decline Bench Press',
  ];

  List<String> calisthenicsResourceKeys = [
    'Parallel Bars',
    'Pull-Up Bar',
  ];

  List<String> cardioResourceKeys = [
    'Treadmill',
    'Bike',
    'Elliptical',
    'Stair Master',
  ];

  late List<List<String>> typesOfResources;
  late Map<String, int> resourceLimitsMap;

  // List<int> resourceLimits = [20, 200, 20, 20, 20, 50, 10, 20, 10, 10];

  // late List<TextEditingController> textEditingControllers;

  late Map<String, int> resourcesAvailable;
  late List<Exercise> machinesAvailable;

  @override
  void initState() {
    super.initState();
    isSelectedGym = widget.isSelectedGym;

    typesOfResources = [
      freeWeightsResourceKeys,
      benchesResourceKeys,
      cableResourceKeys,
      benchPressResourceKeys,
      calisthenicsResourceKeys,
      cardioResourceKeys
    ];
    resourceLimitsMap = {};
    for (List<String> resourceList in typesOfResources) {
      for (String resource in resourceList) {
        int limit;
        switch (resource) {
          case 'Dumbbells':
          case 'Kettlebell':
            limit = 200;
            break;
          case 'Machine':
          case 'Treadmill':
            limit = 50;
            break;
          case 'Cable Lat Pulldown':
          case 'Cable Row':
          case 'EZ-bar':
          case 'Pull-Up Bar':
          case 'Parallel Bars':
          case 'Decline Bench':
          case 'Preacher Bench':
          case 'Hyper Extension':
          case 'Incline Bench Press':
          case 'Decline Bench Press':
            limit = 10;
            break;
          default:
            limit = 20;
            break;
        }
        resourceLimitsMap[resource] = limit;
      }
    }

    // textEditingControllers =
    // List.filled(resourceKeys.length, TextEditingController());
    if (widget.gym != null && widget.gym!.resourcesAvailable.isNotEmpty) {
      resourcesAvailable = Map.from(widget.gym!.resourcesAvailable);
    } else {
      resourcesAvailable = {};
      widget.gym!.resourcesAvailable = Map.from(resourcesAvailable);
    }
    if (widget.gym != null && widget.gym!.machinesAvailable.isNotEmpty) {
      machinesAvailable = List.from(widget.gym!.machinesAvailable);
    } else {
      machinesAvailable = [];
    }

    // if (widget.gym != null) {
    //   print(widget.gym!.photos.length);
    //   for (int i = 0; i < widget.gym!.photos.length; i++) {
    //     urls.add(widget.gym!.photos[i].photoReference);
    //     // 1000 arbitrary for scale
    //     urls[i] =
    //         'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photo_reference=${urls[i]}&key=$googleMapsApiKey';
    //     images.add(GymImageContainer(
    //       imageUrl: urls[i],
    //     ));
    //   }
    // }

    // currentlyOpenString = getCurrentlyOpenString(DateTime.now());
    if (widget.gym!.openingHours == null) {
      currentlyOpenString = '';
    } else {
      final GymOpeningHours gymOpeningHours =
          GymOpeningHours(widget.gym!.openingHours!);
      currentlyOpenString = gymOpeningHours.getCurrentlyOpenString();
      setChartTimes(
          chartOpeningTimes, chartClosingTimes, widget.gym!.openingHours!);
    }
    if (chartOpeningTimes.isEmpty || chartClosingTimes.isEmpty) {
      chartOpeningTimes = List.filled(7, 0);
      chartOpeningTimes = List.filled(7, 24);
    }
    print(currentlyOpenString);
  }

  // Sets the values in chartOpeningTimes and chartClosingTimes
  void setChartTimes(List<int> chartOpeningTimes, List<int> chartClosingTimes,
      List<String> openingHours) {
    for (int i = 0; i < chartOpeningTimes.length; i++) {
      final String openingHour = openingHours[i];
      final String hoursPart =
          openingHour.substring(openingHour.indexOf(':') + 2).trim();
      if (hoursPart == 'Open 24 hours') {
        chartOpeningTimes[i] = (0);
        chartClosingTimes[i] = (24);
      } else if (hoursPart == 'Closed') {
        chartOpeningTimes[i] = (-1);
        chartClosingTimes[i] = (-1);
        // chartOpeningTimes.add(0);
        // chartClosingTimes.add(24);
      } else {
        final List<String> timeParts = hoursPart.split('–');
        String openingTimeStr = timeParts[0].trim();
        String closingTimeStr = timeParts[1].trim();

        // Replace weird characters in string
        openingTimeStr = openingTimeStr.replaceAll('\u202F', ' ').trim();
        closingTimeStr = closingTimeStr.replaceAll('\u202F', ' ').trim();

        bool closingPM = closingTimeStr.endsWith('PM');
        bool openingPM;
        if (openingTimeStr.endsWith('AM')) {
          openingPM = false;
        } else if (openingTimeStr.endsWith('PM')) {
          openingPM = true;
        } else {
          // No AM or PM value, assume it's the same as closing value
          openingPM = closingPM;
        }
        int hourOpen = int.parse(openingTimeStr.split(':')[0]);
        int hourClose = int.parse(closingTimeStr.split(':')[0]);
        if (hourOpen == 12 && !openingPM) {
          hourOpen = 0;
        }
        if (hourClose == 12 && !closingPM) {
          hourClose = 0;
        }
        hourOpen += (hourOpen != 12 && openingPM) ? 12 : 0;
        hourClose += (hourClose != 12 && closingPM) ? 12 : 0;
        if (hourClose < hourOpen) {
          // Close is on the next day
          hourClose += 24;
        }
        chartOpeningTimes[i] = (hourOpen);
        chartClosingTimes[i] = (hourClose);
      }
    }
  }

  void showPopUpMachinesDialog(BuildContext context, MyAppState appState,
      StateSetter setGymPageState, List<Exercise> gymMachines) {
    final theme = Theme.of(context);
    List<Exercise> allMachineExercises = [];
    for (List<Exercise> list in appState.muscleGroups.values) {
      allMachineExercises.addAll(list);
    }
    allMachineExercises = allMachineExercises
        .where((exercise) =>
            (exercise.resourcesRequired ?? []).contains('Machine'))
        .toList();
    // Remove exercises already in gym list
    allMachineExercises
        .removeWhere((exercise) => gymMachines.contains(exercise));
    List<Exercise> displayExercises = allMachineExercises.toList();
    for (int i = 0; i < displayExercises.length; i++) {
      if (displayExercises.indexWhere((element) =>
              (element.machineAltName ?? element.name) ==
              (displayExercises[i].machineAltName ??
                  displayExercises[i].name)) !=
          i) {
        // Duplicate machine, don't display
        displayExercises.removeAt(i);
        i--;
      }
    }
    List<Exercise> selectedMachines = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  Text(
                    'Add Machines',
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
                    icon: Icon(Icons.close,
                        color: theme.colorScheme.primary, size: 20),
                  ),
                  SizedBox(width: 10),
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
                      setGymPageState(() {
                        gymMachines.addAll(selectedMachines);
                      });
                      // Close the dialog
                      Navigator.of(context).pop();
                      print(gymMachines);
                    },
                    icon: Icon(
                      Icons.check,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
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
                childAspectRatio: 0.9,
                crossAxisCount: 3, // Adjust the number of columns as needed
                children: List.generate(displayExercises.length, (index) {
                  // Don't display duplicate machines, e.g. Leg Press & Leg Press Calf Raise
                  // if (allMachineExercises.indexWhere((element) => (element.machineAltName ?? element.name) == (allMachineExercises[index].machineAltName ?? allMachineExercises[index].name)) != index) {
                  //   return SizedBox.shrink();
                  // }
                  // if (allMachineExercises[index].machineAltName == 'Preacher Curl') {
                  //   return SizedBox.shrink();
                  // }
                  return SizedBox(
                    // height: 120,
                    // width: 90,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedMachines
                                  .contains(displayExercises[index])) {
                                // selectedMachines
                                //     .remove(allMachineExercises[index]);
                                selectedMachines.removeWhere((element) =>
                                    (element.machineAltName ?? element.name) ==
                                    (displayExercises[index].machineAltName ??
                                        displayExercises[index].name));
                                print(selectedMachines);
                              } else {
                                // selectedMachines
                                //     .add(allMachineExercises[index]);
                                print(allMachineExercises);
                                selectedMachines.addAll(
                                    allMachineExercises.where((element) =>
                                        (element.machineAltName ??
                                            element.name) ==
                                        (displayExercises[index]
                                                .machineAltName ??
                                            displayExercises[index].name)));
                                print(selectedMachines);
                              }
                            });
                          },
                          child: SizedBox(
                              height: 70,
                              width: 70,
                              child: Stack(children: [
                                ImageContainer(
                                    exerciseName: displayExercises[index].name),
                                Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      selectedMachines
                                              .contains(displayExercises[index])
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    )),
                              ])),
                        ),
                        SizedBox(height: 3),
                        Text(
                          displayExercises[index].machineAltName ??
                              displayExercises[index].name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall!
                              .copyWith(color: theme.colorScheme.onBackground),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          );
        });
      },
    );
  }

  bool isHoliday(DateTime now) {
    return false;
  }

  void _launchPhoneCall(String phoneNumber) async {
    // Format correctly
    final url = 'tel:${phoneNumber.replaceAll(RegExp(r'\s+|-'), '')}';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print(e);
      // print('If on a simulator, ignore next error:');
      // print('ERROR - Invalid phone number $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gym == null) {
      return Placeholder();
    }
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    // String? s = widget.gym!.openingHours?[currentTime.weekday - 1];
    // s = s?.substring(s.indexOf(':') + 2);

    // if (s != null) {
    //   if (s == 'Open 24 hours') {

    //   }
    //   List<String> times = s.split(' – ');
    //   String startTime = times[0];
    //   String endTime = times[1];

    //   int startHour = int.parse(startTime.split(':')[0]);
    //   int endHour = int.parse(endTime.split(':')[0]);

    //   if (startTime.endsWith('AM') && startHour == 12) {
    //     startHour = 0;
    //   } else if (startTime.endsWith('PM') && startHour != 12) {
    //     startHour += 12;
    //   }
    //   if (endTime.endsWith('AM') && endHour == 12) {
    //     endHour = 0;
    //   } else if (endTime.endsWith('PM') && endHour != 12) {
    //     endHour += 12;
    //   }

    //   print(startHour);
    //   print(endHour);
    // }

    // print('weekday ${currentTime.weekday}'); // 1 - 7
    // print('hour ${currentTime.hour}');

    // Open 24 hours or Open -
    String weightedAverageString = '';
    if (currentlyOpenString.contains('Open ') ||
        widget.gym!.openingHours == null) {
      double currentHourPctCapacity =
          (appState.avgGymCrowdData[currentTime.weekday - 1][currentTime.hour] /
                  13.0) *
              100;
      double nextHourPctCapacity;
      if (currentTime.hour + 1 == 24) {
        // Next day, 12 AM
        nextHourPctCapacity =
            (appState.avgGymCrowdData[currentTime.weekday % 7][0] / 13.0) * 100;
      } else {
        nextHourPctCapacity = (appState.avgGymCrowdData[currentTime.weekday - 1]
                    [currentTime.hour + 1] /
                13.0) *
            100;
      }
      double weight = currentTime.minute /
          60.0; // Calculate the weight based on the current minute (0 to 1)
      double weightedAverage = currentHourPctCapacity * (1 - weight) +
          nextHourPctCapacity * weight; // Calculate the weighted average
      weightedAverageString = '${weightedAverage.toInt()}%';
    }

    // if (appState.currentGymPlacesDetailsResponse != null) {
    //   PlaceDetails gymDetails = appState.currentGymPlacesDetailsResponse!;
    //   print('Phone number: ${gymDetails.website}');
    //   print(widget.gym!.openingHours);
    //   print('International Phone number: ${gymDetails.internationalPhoneNumber}');
    //   print('Icon: ${gymDetails.icon}');
    // }

    Widget photosRow;

    if (appState.currentGymPhotos.isNotEmpty) {
      // print('full ${appState.currentGymPhotos}');
      photosRow = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (Widget photo in appState.currentGymPhotos)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Hero(
                tag: '${appState.currentGymPhotos.indexOf(photo)}',
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenPhoto(
                          photoTag:
                              '${appState.currentGymPhotos.indexOf(photo)}',
                          photo: photo,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(height: 175, width: 175, child: photo),
                ),
              ),
            ),
          SizedBox(width: 15),
        ],
      );
    } else {
      // print('empty ${appState.currentGymPhotos}');
      photosRow = SizedBox(
        height: 175,
        width: 175,
        child: Padding(
          padding: const EdgeInsets.all(65),
          child: CircularProgressIndicator(),
        ),
      );
    }

    int backIndex = 0; // Home page

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final headlineStyle = theme.textTheme.titleSmall!.copyWith(
        color: currentlyOpenString.startsWith('Closed')
            ? theme.colorScheme.secondary
            : theme.colorScheme.primary);
    final subHeadlineStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final bodyMedium = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final textStyle = theme.textTheme.bodySmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    Widget selectButtonLabel;
    Widget selectButtonIcon;
    if (!isSelectedGym) {
      selectButtonIcon = Icon(Icons.check_box_outline_blank,
          size: 16, color: theme.colorScheme.onBackground);
      selectButtonLabel = Text('Select gym', style: textStyle);
    } else {
      selectButtonIcon = Icon(Icons.check_box, size: 16);
      selectButtonLabel = Text('Selected gym', style: textStyle);
    }

    double resourceWidth = editResourcesMode ? 100 : 90;
    double resourceHeight = editResourcesMode ? 145 : 120;

    // print(machinesAvailable);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SwipeBack(
        appState: appState,
        index: backIndex,
        child: Scaffold(
          appBar: AppBar(
            leading: Back(appState: appState, index: backIndex),
            leadingWidth: 70,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(flex: 3),
                    Text(
                      widget.gym!.name,
                      style: titleStyle,
                    ),
                    Spacer(flex: 5),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  if (currentlyOpenString.isEmpty) Spacer(),
                  if (widget.gym!.googleMapsRating != null &&
                      widget.gym!.googleMapsRating! > 4.0)
                    Text(
                      '${widget.gym!.googleMapsRating ?? 0}',
                      style: textStyle.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.65)),
                    ),
                  if (widget.gym!.googleMapsRating != null &&
                      (widget.gym!.googleMapsRating! <= 4.0 &&
                          widget.gym!.googleMapsRating! > 2.5))
                    Text(
                      '${widget.gym!.googleMapsRating ?? 0}',
                      style: textStyle.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.65)),
                    ),
                  if (widget.gym!.googleMapsRating != null &&
                      widget.gym!.googleMapsRating! <= 2.5)
                    Text(
                      '${widget.gym!.googleMapsRating ?? 0}',
                      style: textStyle.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.65)),
                    ),
                  if (widget.gym!.googleMapsRating == null)
                    Text(
                      'No rating available',
                      style: textStyle.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.65),
                      ),
                    ),
                  if (widget.gym!.googleMapsRating != null) SizedBox(width: 3),
                  for (int i = 0; i < 5; i++)
                    if (i + 1 <= widget.gym!.googleMapsRating!)
                      Icon(Icons.star,
                          color: theme.colorScheme.primary, size: 14)
                    else if (i + 0.5 <= widget.gym!.googleMapsRating!)
                      Icon(Icons.star_half,
                          color: theme.colorScheme.primary, size: 14)
                    else
                      Icon(Icons.star_border,
                          color: theme.colorScheme.primary, size: 14),
                  // There is openingHours data for the gym
                  Spacer(),
                  if (currentlyOpenString.isNotEmpty)
                    if (!currentlyOpenString.contains('-'))
                      Text(currentlyOpenString, style: headlineStyle),
                  if (currentlyOpenString.isNotEmpty)
                    if (currentlyOpenString.contains('-'))
                      Text(currentlyOpenString.split('-')[0],
                          style: headlineStyle),
                  if (currentlyOpenString.isNotEmpty)
                    if (currentlyOpenString.contains('-'))
                      Text('-${currentlyOpenString.split('-')[1]}',
                          style: subHeadlineStyle),
                  if (currentlyOpenString.isNotEmpty)
                    GestureDetector(
                        onTapDown: (tapDownDetails) {
                          setState(() {
                            showPopupMenu(context, widget.gym!.openingHours!,
                                tapDownDetails.globalPosition);
                          });
                        },
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color:
                              theme.colorScheme.onBackground.withOpacity(.65),
                        )),
                  Spacer(),
                ]),
                SizedBox(height: 5),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(flex: 1),
                      Text(
                        widget.gym!.formattedAddress,
                        style: labelStyle.copyWith(
                            color: labelStyle.color!.withOpacity(.65)),
                      ),
                      Spacer(flex: 4),
                    ]),
              ],
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            toolbarHeight: 90,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor: resolveColor(
                                  (isSelectedGym || appState.userGym != null)
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.primary),
                              surfaceTintColor: resolveColor(
                                  (isSelectedGym || appState.userGym != null)
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.primary)),
                          onPressed: () {
                            if (isSelectedGym) {
                              setState(() {
                                isSelectedGym = false;
                                appState.userGym = null;
                              });
                              appState.removeUserGymFromSharedPreferences();
                            } else {
                              setState(() {
                                isSelectedGym = true;
                                appState.userGym = widget.gym;
                              });
                              appState.storeUserGymInSharedPreferences();
                            }
                            print(isSelectedGym);
                          },
                          label: selectButtonLabel,
                          icon: selectButtonIcon,
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor: resolveColor(
                                  theme.colorScheme.primaryContainer),
                              surfaceTintColor: resolveColor(
                                  theme.colorScheme.primaryContainer)),
                          onPressed: () {
                            launchUrl(Uri.parse(widget.gym!.url));
                          },
                          icon: Icon(Icons.location_pin, size: 16),
                          label: Text('Map', style: labelStyle),
                        ),
                        if (widget.gym!.gymUrl != null) SizedBox(width: 10),
                        if (widget.gym!.gymUrl != null)
                          ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor: resolveColor(
                                    theme.colorScheme.primaryContainer),
                                surfaceTintColor: resolveColor(
                                    theme.colorScheme.primaryContainer)),
                            onPressed: () {
                              launchUrl(Uri.parse(widget.gym!.gymUrl!));
                            },
                            icon: Icon(Icons.web, size: 16),
                            label: Text('Website', style: labelStyle),
                          ),
                        if (widget.gym!.internationalPhoneNumber != null)
                          SizedBox(width: 10),
                        if (widget.gym!.internationalPhoneNumber != null)
                          ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor: resolveColor(
                                    theme.colorScheme.primaryContainer),
                                surfaceTintColor: resolveColor(
                                    theme.colorScheme.primaryContainer)),
                            onPressed: () {
                              _launchPhoneCall(
                                  widget.gym!.internationalPhoneNumber!);
                            },
                            icon: Icon(Icons.call, size: 16),
                            label: Text('Call', style: labelStyle),
                          ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Photo
                // if (appState.currentGymPhotos.isNotEmpty)
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: photosRow),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current expected occupancy', style: titleStyle),
                      SizedBox(
                          height: weightedAverageString.isEmpty &&
                                  currentlyOpenString.isNotEmpty
                              ? 10
                              : 15),
                      if (weightedAverageString.isEmpty &&
                          currentlyOpenString.isNotEmpty)
                        Text('Closed',
                            style: labelStyle.copyWith(
                                color: labelStyle.color!.withOpacity(.65))),
                      if (weightedAverageString.isNotEmpty ||
                          currentlyOpenString.isEmpty)
                        Row(
                          children: [
                            SizedBox(width: 5),
                            Column(
                              children: [
                                CustomCircularProgressIndicator(
                                    percentCapacity: double.parse(
                                            weightedAverageString.substring(
                                                0,
                                                weightedAverageString.length -
                                                    1)) /
                                        100.0,
                                    strokeWidth: 4,
                                    size: 30.0),
                                SizedBox(height: 5),
                                Text(weightedAverageString,
                                    style: headlineStyle.copyWith(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(width: 15),
                            SizedBox(
                              height: 50,
                              child: Column(
                                children: [
                                  Text('Percent',
                                      style: labelStyle.copyWith(
                                          color: labelStyle.color!
                                              .withOpacity(.65))),
                                  Text('capacity',
                                      style: labelStyle.copyWith(
                                          color: labelStyle.color!
                                              .withOpacity(.65))),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Gym Resources',
                            style: titleStyle,
                          ),
                          SizedBox(width: 10),
                          if (!editResourcesMode)
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
                                setState(() {
                                  editResourcesMode = true;
                                });
                              },
                              icon: Icon(Icons.edit,
                                  color: theme.colorScheme.primary, size: 16),
                              // label: Text('Edit', style: TextStyle(color: theme.colorScheme.onBackground),),
                            ),
                          if (editResourcesMode)
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
                                setState(() {
                                  print(resourcesAvailable);
                                  print(widget.gym!.resourcesAvailable);
                                  resourcesAvailable =
                                      Map.from(widget.gym!.resourcesAvailable);
                                  editResourcesMode = false;
                                });
                              },
                              icon: Icon(Icons.cancel,
                                  color: theme.colorScheme.primary, size: 20),
                              // label: Text('Edit', style: TextStyle(color: theme.colorScheme.onBackground),),
                            ),
                          if (editResourcesMode) SizedBox(width: 10),
                          if (editResourcesMode)
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
                                setState(() {
                                  widget.gym!.resourcesAvailable =
                                      Map.from(resourcesAvailable);
                                  editResourcesMode = false;
                                  // Submit updated gym data to firebase
                                  appState.submitGymDataToFirebase(widget.gym!);
                                });
                              },
                              icon: Icon(Icons.check,
                                  color: theme.colorScheme.primary, size: 24),
                              // label: Text('Edit', style: TextStyle(color: theme.colorScheme.onBackground),),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            for (int i = 0; i < resourceNames.length; i++)
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showResources[i] = !showResources[i];
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          resourceNames[i],
                                          style: textStyle,
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          showResources[i]
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: theme.colorScheme.primary,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: showResources[i] ? 10 : 5),
                                  if (showResources[i])
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int j = 0;
                                              j < typesOfResources[i].length;
                                              j++)
                                            Row(
                                              children: [
                                                Container(
                                                  height: resourceHeight,
                                                  width: resourceWidth,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 25,
                                                        width: 25,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Image.asset(
                                                            'assets/images/resource_icons/${typesOfResources[i][j]}.png'),
                                                      ),
                                                      SizedBox(height: 5),
                                                      if (typesOfResources[i][j]
                                                          .endsWith('h'))
                                                        Text(
                                                          '${typesOfResources[i][j]}es',
                                                          style: labelStyle,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                        ),
                                                      if (typesOfResources[i][j]
                                                          .endsWith('s'))
                                                        Text(
                                                            typesOfResources[i]
                                                                [j],
                                                            style: labelStyle,
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 2),
                                                      if (!typesOfResources[i]
                                                                  [j]
                                                              .endsWith('h') &&
                                                          !typesOfResources[i]
                                                                  [j]
                                                              .endsWith('s'))
                                                        Text(
                                                          '${typesOfResources[i][j]}s',
                                                          style: labelStyle,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                        ),
                                                      Spacer(),
                                                      if (!editResourcesMode)
                                                        Container(
                                                            decoration: BoxDecoration(
                                                                color: theme
                                                                    .colorScheme
                                                                    .secondaryContainer,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        12,
                                                                        10,
                                                                        12,
                                                                        10),
                                                                child: Text(
                                                                  '${resourcesAvailable[typesOfResources[i][j]] ?? 'No value'}',
                                                                  style:
                                                                      labelStyle,
                                                                ))),
                                                      if ((typesOfResources[i]
                                                                      [j] ==
                                                                  'Dumbbells' ||
                                                              typesOfResources[
                                                                      i][j] ==
                                                                  'Kettlebell') &&
                                                          editResourcesMode)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color: theme
                                                                  .colorScheme
                                                                  .secondaryContainer,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: NumberPicker(
                                                            textStyle: labelStyle.copyWith(
                                                                color: theme
                                                                    .colorScheme
                                                                    .onBackground
                                                                    .withOpacity(
                                                                        .4)),
                                                            selectedTextStyle:
                                                                bodyMedium,
                                                            value: resourcesAvailable[
                                                                    typesOfResources[
                                                                            i]
                                                                        [j]] ??
                                                                0,
                                                            minValue: 0,
                                                            maxValue: resourceLimitsMap[
                                                                    typesOfResources[
                                                                            i]
                                                                        [j]] ??
                                                                20,
                                                            step: 5,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                resourcesAvailable[
                                                                    typesOfResources[
                                                                            i][
                                                                        j]] = value;
                                                              });
                                                            },
                                                            itemHeight:
                                                                20, // Customize the height of each item
                                                            // itemCount: 2,
                                                          ),
                                                        ),
                                                      if (typesOfResources[i]
                                                                  [j] ==
                                                              'Dumbbells' ||
                                                          typesOfResources[i]
                                                                  [j] ==
                                                              'Kettlebell')
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 3, 0, 0),
                                                          child: Text(
                                                            'Max Weight',
                                                            style: labelStyle.copyWith(
                                                                color: theme
                                                                    .colorScheme
                                                                    .onBackground
                                                                    .withOpacity(
                                                                        .65)),
                                                          ),
                                                        ),
                                                      if (typesOfResources[i]
                                                                  [j] !=
                                                              'Dumbbells' &&
                                                          typesOfResources[i]
                                                                  [j] !=
                                                              'Kettlebell' &&
                                                          editResourcesMode)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color: theme
                                                                  .colorScheme
                                                                  .secondaryContainer,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: NumberPicker(
                                                            textStyle: labelStyle.copyWith(
                                                                color: theme
                                                                    .colorScheme
                                                                    .onBackground
                                                                    .withOpacity(
                                                                        .4)),
                                                            selectedTextStyle:
                                                                bodyMedium,
                                                            value: resourcesAvailable[
                                                                    typesOfResources[
                                                                            i]
                                                                        [j]] ??
                                                                0,
                                                            minValue: 0,
                                                            maxValue: resourceLimitsMap[
                                                                    typesOfResources[
                                                                            i]
                                                                        [j]] ??
                                                                20,
                                                            step: 1,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                resourcesAvailable[
                                                                    typesOfResources[
                                                                            i][
                                                                        j]] = value;
                                                              });
                                                            },
                                                            itemHeight:
                                                                20, // Customize the height of each item
                                                          ),
                                                        ),
                                                      if (typesOfResources[i]
                                                                  [j] !=
                                                              'Dumbbells' &&
                                                          typesOfResources[i]
                                                                  [j] !=
                                                              'Kettlebell')
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 3, 0, 0),
                                                          child: Text(
                                                            'Count',
                                                            style: labelStyle.copyWith(
                                                                color: theme
                                                                    .colorScheme
                                                                    .onBackground
                                                                    .withOpacity(
                                                                        .65)),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (j <
                                                    typesOfResources[i].length -
                                                        1)
                                                  // if (editResourcesMode)
                                                  SizedBox(width: 10),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: showResources[i] ? 10 : 0),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Machines Available',
                            style: titleStyle,
                          ),
                          SizedBox(width: 10),
                          if (!editMachinesMode)
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
                                setState(() {
                                  editMachinesMode = true;
                                });
                              },
                              icon: Icon(Icons.edit,
                                  color: theme.colorScheme.primary, size: 16),
                              // label: Text('Edit', style: TextStyle(color: theme.colorScheme.onBackground),),
                            ),
                          if (editMachinesMode)
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
                                setState(() {
                                  print(machinesAvailable);
                                  print(widget.gym!.machinesAvailable);
                                  machinesAvailable =
                                      List.from(widget.gym!.machinesAvailable);
                                  editMachinesMode = false;
                                });
                              },
                              icon: Icon(Icons.cancel,
                                  color: theme.colorScheme.primary, size: 20),
                              // label: Text('Edit', style: TextStyle(color: theme.colorScheme.onBackground),),
                            ),
                          if (editMachinesMode) SizedBox(width: 10),
                          if (editMachinesMode)
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
                                setState(() {
                                  widget.gym!.machinesAvailable =
                                      List.from(machinesAvailable);
                                  editMachinesMode = false;
                                  // Submit updated gym data to firebase
                                  appState.submitGymDataToFirebase(widget.gym!);
                                });
                              },
                              icon: Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              // label: Text('Edit', style: TextStyle(color: theme.colorScheme.onBackground),),
                            ),
                        ],
                      ),
                      if (machinesAvailable.isEmpty && !editMachinesMode)
                        SizedBox(height: 10),
                      if (!(machinesAvailable.isEmpty && !editMachinesMode))
                        SizedBox(height: 5),
                      if (machinesAvailable.isEmpty && !editMachinesMode)
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
                            setState(() {
                              editMachinesMode = true;
                              // Trigger add exercise pop up
                              showPopUpMachinesDialog(context, appState,
                                  setState, machinesAvailable);
                            });
                            print(machinesAvailable);
                          },
                          icon: Icon(
                            Icons.add,
                            color: theme.colorScheme.primary,
                          ),
                          label: Text(
                            'Add Machines',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ),
                      if (!(machinesAvailable.isEmpty && !editMachinesMode))
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (editMachinesMode)
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
                                    setState(() {
                                      // Trigger add exercise pop up
                                      showPopUpMachinesDialog(context, appState,
                                          setState, machinesAvailable);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              if (editMachinesMode) SizedBox(width: 10),
                              if (machinesAvailable.isNotEmpty)
                                Container(
                                  // height: 200,
                                  decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(20)),
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 0;
                                          i < machinesAvailable.length;
                                          i++)
                                        // Don't display duplicate machines, e.g. Leg Press & Leg Press Calf Raise
                                        if (machinesAvailable.indexWhere(
                                                (element) =>
                                                    (element.machineAltName ??
                                                        element.name) ==
                                                    (machinesAvailable[i]
                                                            .machineAltName ??
                                                        machinesAvailable[i]
                                                            .name)) ==
                                            i)
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: editMachinesMode
                                                    ? 192
                                                    : 168,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        appState
                                                            .changePageToExercise(
                                                                machinesAvailable[
                                                                    i]);
                                                      },
                                                      child: Container(
                                                        width: 120,
                                                        height: 120,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        // child: Image.asset('muscle_group_pictures/$name.jpeg', fit: BoxFit.cover,),
                                                        child: ImageContainer(
                                                            exerciseName:
                                                                machinesAvailable[
                                                                        i]
                                                                    .name),
                                                        // child: ,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    SizedBox(
                                                      width: 120,
                                                      child: Text(
                                                        machinesAvailable[i]
                                                                .machineAltName ??
                                                            machinesAvailable[i]
                                                                .name,
                                                        style: bodyMedium,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    if (editMachinesMode)
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            // machinesAvailable
                                                            //     .removeAt(i);
                                                            machinesAvailable.removeWhere((element) =>
                                                                (element.machineAltName ??
                                                                    element
                                                                        .name) ==
                                                                (machinesAvailable[
                                                                            i]
                                                                        .machineAltName ??
                                                                    machinesAvailable[
                                                                            i]
                                                                        .name));
                                                          });
                                                          print(
                                                              machinesAvailable);
                                                        },
                                                        child: Icon(
                                                            Icons
                                                                .delete_forever,
                                                            size: 20,
                                                            color: theme
                                                                .colorScheme
                                                                .primary),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              if (i <
                                                  machinesAvailable.length - 1)
                                                SizedBox(width: 10),
                                            ],
                                          ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    height: 400,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: GymCrowdednessChart(appState.avgGymCrowdData,
                        chartOpeningTimes, chartClosingTimes),
                  ),
                ),
                SizedBox(
                  height: 40,
                ), // Extra scrolling buffer
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showPopupMenu(
      BuildContext context, List<String> menuItems, Offset tapPosition) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    print(tapPosition);

    showMenu(
      color: theme.colorScheme.secondaryContainer,
      surfaceTintColor: theme.colorScheme.secondaryContainer,
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy + 15,
        tapPosition.dx + 1,
        tapPosition.dy + 15 + 1,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Column(
            children: menuItems
                .map((item) => SizedBox(
                      width: 200,
                      child: ListTile(
                        visualDensity: VisualDensity(
                            vertical: VisualDensity.minimumDensity,
                            horizontal: VisualDensity.minimumDensity),
                        dense: true,
                        title: Text(item.substring(0, item.indexOf(':')),
                            style: textStyle),
                        subtitle: Text(item.substring(item.indexOf(':') + 2),
                            style: labelStyle),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // String getCurrentlyOpenString(DateTime now) {
  //   String? openingHours = widget.gym!.openingHours?[currentTime.weekday - 1];
  //   String result = '';

  //   if (openingHours != null) {
  //     // Check if current date is a holiday
  //     if (isHoliday(now)) {
  //       result = 'Holiday Hours';
  //     } else if (openingHours.contains('Open 24 hours')) {
  //       result = 'Open 24 hours';
  //     } else {
  //       openingHours = openingHours.substring(openingHours.indexOf(':') + 2);
  //       List<String> times = openingHours.split(' – ');
  //       String startTime = times[0];
  //       String endTime = times[1];

  //       int startHour = int.parse(startTime.split(':')[0]);
  //       int endHour = int.parse(endTime.split(':')[0]);

  //       if (startTime.endsWith('AM') && startHour == 12) {
  //         startHour = 0;
  //       } else if (startTime.endsWith('PM') && startHour != 12) {
  //         startHour += 12;
  //       }
  //       if (endTime.endsWith('AM') && endHour == 12) {
  //         endHour = 0;
  //       } else if (endTime.endsWith('PM') && endHour != 12) {
  //         endHour += 12;
  //       }

  //       if (endHour < startHour) {
  //         // Check if the current time is within the opening hours
  //         if (currentTime.hour >= startHour || currentTime.hour < endHour) {
  //           result = 'Open';
  //           int totalMinutesUntilClose =
  //               ((endHour - currentTime.hour + 24 - 1) % 24) * 60 +
  //                   (60 - currentTime.minute);
  //           int hoursUntilClose = totalMinutesUntilClose ~/ 60;
  //           int minutesUntilClose = totalMinutesUntilClose % 60;
  //           result +=
  //               ' - Closes in $hoursUntilClose hours and $minutesUntilClose minutes';
  //         } else {
  //           // Check if previous day is still open
  //           String? previousDayOpeningHours =
  //               widget.gym!.openingHours?[(currentTime.weekday - 2) % 7];
  //           if (previousDayOpeningHours != null) {
  //             previousDayOpeningHours = previousDayOpeningHours
  //                 .substring(previousDayOpeningHours.indexOf(':') + 2);
  //             List<String> previousTimes = previousDayOpeningHours.split(' – ');
  //             String previousEndTime = previousTimes[1];
  //             int previousEndHour = int.parse(previousEndTime.split(':')[0]);

  //             if (previousEndTime.endsWith('AM') && previousEndHour == 12) {
  //               previousEndHour = 0;
  //             } else if (previousEndTime.endsWith('PM') &&
  //                 previousEndHour != 12) {
  //               previousEndHour += 12;
  //             }

  //             if (previousEndHour > currentTime.hour) {
  //               // Previous day is still open
  //               result = 'Open';
  //               int totalMinutesUntilClose =
  //                   (previousEndHour - currentTime.hour - 1) * 60 +
  //                       (60 - currentTime.minute);
  //               int hoursUntilClose = totalMinutesUntilClose ~/ 60;
  //               int minutesUntilClose = totalMinutesUntilClose % 60;
  //               result +=
  //                   ' - Closes in $hoursUntilClose hours and $minutesUntilClose minutes';
  //             } else {
  //               result = 'Closed';
  //               int totalMinutesUntilOpen =
  //                   (startHour - currentTime.hour - 1) * 60 +
  //                       (60 - currentTime.minute);
  //               int hoursUntilOpen = totalMinutesUntilOpen ~/ 60;
  //               int minutesUntilOpen = totalMinutesUntilOpen % 60;
  //               result +=
  //                   ' - Opens in $hoursUntilOpen hours and $minutesUntilOpen minutes';
  //             }
  //           } else {
  //             result = 'Closed';
  //             int totalMinutesUntilOpen =
  //                 (startHour - currentTime.hour - 1) * 60 +
  //                     (60 - currentTime.minute);
  //             int hoursUntilOpen = totalMinutesUntilOpen ~/ 60;
  //             int minutesUntilOpen = totalMinutesUntilOpen % 60;
  //             result +=
  //                 ' - Opens in $hoursUntilOpen hours and $minutesUntilOpen minutes';
  //           }
  //         }
  //       } else {
  //         if (currentTime.hour >= startHour && currentTime.hour < endHour) {
  //           result = 'Open';
  //           int totalMinutesUntilClose =
  //               (endHour - currentTime.hour) * 60 + (60 - currentTime.minute);
  //           int hoursUntilClose = totalMinutesUntilClose ~/ 60;
  //           int minutesUntilClose = totalMinutesUntilClose % 60;
  //           result +=
  //               ' - Closes in $hoursUntilClose hours and $minutesUntilClose minutes';
  //         } else {
  //           // Check if previous day is still open
  //           String? previousDayOpeningHours =
  //               widget.gym!.openingHours?[(currentTime.weekday - 2) % 7];
  //           if (previousDayOpeningHours != null) {
  //             previousDayOpeningHours = previousDayOpeningHours
  //                 .substring(previousDayOpeningHours.indexOf(':') + 2);
  //             List<String> previousTimes = previousDayOpeningHours.split(' – ');
  //             String previousEndTime = previousTimes[1];
  //             int previousEndHour = int.parse(previousEndTime.split(':')[0]);

  //             if (previousEndTime.endsWith('AM') && previousEndHour == 12) {
  //               previousEndHour = 0;
  //             } else if (previousEndTime.endsWith('PM') &&
  //                 previousEndHour != 12) {
  //               previousEndHour += 12;
  //             }

  //             if (previousEndHour > currentTime.hour) {
  //               // Previous day is still open
  //               result = 'Open';
  //               int totalMinutesUntilClose =
  //                   (previousEndHour - currentTime.hour - 1) * 60 +
  //                       (60 - currentTime.minute);
  //               int hoursUntilClose = totalMinutesUntilClose ~/ 60;
  //               int minutesUntilClose = totalMinutesUntilClose % 60;
  //               result +=
  //                   ' - Closes in $hoursUntilClose hours and $minutesUntilClose minutes';
  //             } else {
  //               result = 'Closed';
  //               int totalMinutesUntilOpen =
  //                   (startHour - currentTime.hour - 1) * 60 +
  //                       (60 - currentTime.minute);
  //               int hoursUntilOpen = totalMinutesUntilOpen ~/ 60;
  //               int minutesUntilOpen = totalMinutesUntilOpen % 60;
  //               result +=
  //                   ' - Opens in $hoursUntilOpen hours and $minutesUntilOpen minutes';
  //             }
  //           } else {
  //             result = 'Closed';
  //             int totalMinutesUntilOpen =
  //                 (startHour - currentTime.hour - 1) * 60 +
  //                     (60 - currentTime.minute);
  //             int hoursUntilOpen = totalMinutesUntilOpen ~/ 60;
  //             int minutesUntilOpen = totalMinutesUntilOpen % 60;
  //             result +=
  //                 ' - Opens in $hoursUntilOpen hours and $minutesUntilOpen minutes';
  //           }
  //         }
  //       }

  //       // Grammar
  //       result.replaceAll('1 hours', '1 hour');
  //       result.replaceAll('1 minutes', '1 minute');

  //       // if (endHour < startHour) {
  //       //   // Handle case where end hour is less than start hour (e.g., 9 PM - 3 AM)
  //       //   if (currentTime.hour >= startHour || currentTime.hour < endHour) {
  //       //     result = 'Open';
  //       //     int hoursUntilClose = (endHour - currentTime.hour + 24) % 24;
  //       //     int minutesUntilClose =
  //       //         hoursUntilClose * 60 + (60 - currentTime.minute);
  //       //     result +=
  //       //         ' - Closes in $hoursUntilClose hours and ${minutesUntilClose % 60} minutes';
  //       //   } else {
  //       //     result = 'Closed';
  //       //     int hoursUntilOpen = (startHour - currentTime.hour + 24) % 24;
  //       //     int minutesUntilOpen =
  //       //         hoursUntilOpen * 60 + (60 - currentTime.minute);
  //       //     result +=
  //       //         ' - Opens in $hoursUntilOpen hours and ${minutesUntilOpen % 60} minutes';
  //       //   }
  //       // } else {
  //       //   // Handle normal case
  //       //   if (currentTime.hour >= startHour && currentTime.hour < endHour) {
  //       //     result = 'Open';
  //       //     int hoursUntilClose = (endHour - currentTime.hour) % 24;
  //       //     int minutesUntilClose =
  //       //         hoursUntilClose * 60 + (60 - currentTime.minute);
  //       //     result +=
  //       //         ' - Closes in $hoursUntilClose hours and ${minutesUntilClose % 60} minutes';
  //       //   } else {
  //       //     result = 'Closed';
  //       //     int hoursUntilOpen = (startHour - currentTime.hour + 24) % 24;
  //       //     int minutesUntilOpen =
  //       //         hoursUntilOpen * 60 + (60 - currentTime.minute);
  //       //     result +=
  //       //         ' - Opens in $hoursUntilOpen hours and ${minutesUntilOpen % 60} minutes';
  //       //   }
  //       // }
  //     }
  //   }

  //   return result;

  //   String? openingHours = widget.gym!.openingHours?[currentTime.weekday - 1];
  //   String result = '';

  //   if (openingHours != null) {
  //     // Check if current date is a holiday
  //     DateTime now = DateTime.now();
  //     if (isHoliday(now)) {
  //       result = 'Holiday Hours';
  //     } else if (openingHours.contains('Open 24 hours')) {
  //       result = 'Open 24 hours';
  //     } else {
  //       openingHours = openingHours.substring(openingHours.indexOf(':') + 2);
  //       List<String> times = openingHours.split(' – ');
  //       String startTime = times[0];
  //       String endTime = times[1];

  //       int startHour = int.parse(startTime.split(':')[0]);
  //       int endHour = int.parse(endTime.split(':')[0]);

  //       if (startTime.endsWith('AM') && startHour == 12) {
  //         startHour = 0;
  //       } else if (startTime.endsWith('PM') && startHour != 12) {
  //         startHour += 12;
  //       }
  //       if (endTime.endsWith('AM') && endHour == 12) {
  //         endHour = 0;
  //       } else if (endTime.endsWith('PM') && endHour != 12) {
  //         endHour += 12;
  //       }

  //       if (currentTime.hour >= startHour && currentTime.hour < endHour) {
  //         result = 'Open';
  //         int minutesUntilClose =
  //             (endHour - currentTime.hour - 1) * 60 + (60 - currentTime.minute);
  //         result += ' - Closes in $minutesUntilClose minutes';
  //       } else {
  //         // Check if previous day is still open
  //         String? previousDayOpeningHours =
  //             widget.gym!.openingHours?[(currentTime.weekday - 2) % 7];
  //         if (previousDayOpeningHours != null) {
  //           previousDayOpeningHours = previousDayOpeningHours
  //               .substring(previousDayOpeningHours.indexOf(':') + 2);
  //           List<String> previousTimes = previousDayOpeningHours.split(' – ');
  //           String previousEndTime = previousTimes[1];
  //           int previousEndHour = int.parse(previousEndTime.split(':')[0]);

  //           if (previousEndTime.endsWith('AM') && previousEndHour == 12) {
  //             previousEndHour = 0;
  //           } else if (previousEndTime.endsWith('PM') &&
  //               previousEndHour != 12) {
  //             previousEndHour += 12;
  //           }

  //           if (previousEndHour > currentTime.hour) {
  //             // Previous day is still open
  //             result = 'Open';
  //             int minutesUntilClose =
  //                 (previousEndHour - currentTime.hour - 1) * 60 +
  //                     (60 - currentTime.minute);
  //             result += ' - Closes in $minutesUntilClose minutes';
  //           } else {
  //             result = 'Closed';
  //             int minutesUntilOpen = (startHour - currentTime.hour - 1) * 60 +
  //                 (60 - currentTime.minute);
  //             result += ' - Opens in $minutesUntilOpen minutes';
  //           }
  //         } else {
  //           result = 'Closed';
  //           int minutesUntilOpen = (startHour - currentTime.hour - 1) * 60 +
  //               (60 - currentTime.minute);
  //           result += ' - Opens in $minutesUntilOpen minutes';
  //         }
  //       }
  //     }
  //   }
  //   return result;
}

// String getGymStatus(List<String>? openingHoursStrings, DateTime now) {
//   // DateTime now = DateTime.now();
//   if (openingHoursStrings == null) {
//     return '';
//   }
//   if (isHoliday(now)) {
//     return 'Holiday Hours';
//   } else if (openingHoursStrings[now.weekday - 1].contains('Open 24 hours')) {
//     return 'Open 24 hours';
//   }
//   List<int?> openingHours = List<int?>.filled(168, null);

//   // Helper function to convert time string to minutes past 12 AM
//   int convertTimeToMinutes(String timeString) {
//     List<String> timeParts = timeString.split(':');
//     // timeParts[0] = timeParts[0].replaceAll('00', '0');
//     // timeParts[1] = timeParts[1].replaceAll('00', '0');
//     int hours = int.parse(timeParts[0].trim());
//     int minutes = int.parse(timeParts[1].substring(0, 2));
//     bool isPM = timeParts[1].endsWith('PM');

//     if (hours == 12) {
//       hours = 0;
//     }
//     if (isPM) {
//       hours += 12;
//     }

//     return hours * 60 + minutes;
//   }

//   // Parse opening hours strings into openingHours array
//   for (int i = 0; i < openingHoursStrings.length; i++) {
//     String openingHoursString = openingHoursStrings[i];
//     openingHoursString =
//         openingHoursString.substring(openingHoursString.indexOf(':') + 2);
//     List<String> timeRangeParts = openingHoursString.split(' – ');

//     int startMinutes = convertTimeToMinutes(timeRangeParts[0]);
//     int endMinutes = convertTimeToMinutes(timeRangeParts[1]);

//     // Handle case when closing time is in the AM of the next day
//     if (endMinutes < startMinutes) {
//       endMinutes += 24 * 60;
//     }

//     for (int j = startMinutes; j <= endMinutes; j++) {
//       openingHours[i * 24 + (j % 24)] = j;
//     }
//   }

//   // Rest of the code remains the same
//   int currentDayIndex = (now.weekday + 5) % 7; // Fix index calculation
//   int currentHourIndex = currentDayIndex * 24 + now.hour;

//   // Check if the current time is within the opening hours
//   if (openingHours[currentHourIndex] != null) {
//     int minutesUntilClose =
//         openingHours[currentHourIndex]! - (now.hour * 60 + now.minute);
//     if (minutesUntilClose < 0) {
//       minutesUntilClose += 24 * 60;
//     }
//     int hoursUntilClose = minutesUntilClose ~/ 60;
//     minutesUntilClose %= 60;
//     return 'Open - Closes in $hoursUntilClose hours and $minutesUntilClose minutes';
//   }

//   int? currentOpeningHour = openingHours[currentHourIndex];
//   if (currentOpeningHour != null) {
//     if (currentOpeningHour >= 0) {
//       int hoursUntilClose = currentOpeningHour ~/ 60;
//       int minutesUntilClose = currentOpeningHour % 60;
//       return 'Open - Closes in $hoursUntilClose hours and $minutesUntilClose minutes';
//     } else {
//       int minutesUntilOpen = -currentOpeningHour;
//       return 'Closed - Opens in $minutesUntilOpen minutes';
//     }
//   } else {
//     int nextOpeningIndex = currentHourIndex;
//     int nextClosingIndex = currentHourIndex;

//     while (openingHours[nextOpeningIndex] == null) {
//       nextOpeningIndex = (nextOpeningIndex + 1) % openingHours.length;
//     }

//     while (openingHours[nextClosingIndex] == null) {
//       nextClosingIndex = (nextClosingIndex + 1) % openingHours.length;
//     }

//     int hoursUntilOpen = ((nextOpeningIndex - currentHourIndex) + 168) % 168;
//     int minutesUntilOpen = openingHours[nextOpeningIndex]!;
//     int hoursUntilClose = ((nextClosingIndex - currentHourIndex) + 168) % 168;
//     int minutesUntilClose = -openingHours[nextClosingIndex]!;

//     return 'Closed - Opens in $hoursUntilOpen hours and $minutesUntilOpen minutes\n'
//         'Open - Closes in $hoursUntilClose hours and $minutesUntilClose minutes';
//   }
// }
// }

// class GymImageContainer extends StatefulWidget {
//   final Uint8List bytes;

//   GymImageContainer({required this.bytes});

//   @override
//   _GymImageContainerState createState() => _GymImageContainerState();
// }

// class _GymImageContainerState extends State<GymImageContainer> {
//   bool _loading = true;
//   bool _error = false;

//   void _loadImage() {
//     // Image.network(widget.imageUrl)
//     //     .image
//     //     .resolve(const ImageConfiguration())
//     //     .addListener(ImageStreamListener((info, _) {
//     //       if (mounted) {
//     //         setState(() {
//     //           _loading = false;
//     //         });
//     //       }
//     //     }, onError: (_, __) {
//     //       if (mounted) {
//     //         setState(() {
//     //           _loading = false;
//     //           _error = true;
//     //         });
//     //       }
//     //     }));
//     Image.memory(widget.bytes)
//         .image
//         .resolve(const ImageConfiguration())
//         .addListener(ImageStreamListener((info, _) {
//           if (mounted) {
//             setState(() {
//               _loading = false;
//             });
//           }
//         }, onError: (_, __) {
//           if (mounted) {
//             setState(() {
//               _loading = false;
//               _error = true;
//             });
//           }
//         }));
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadImage();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Container(
//         color: Colors.grey,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     } else if (_error) {
//       return Container(
//         color: Colors.grey,
//       );
//     } else {
//       return Image.memory(
//         widget.bytes,
//         fit: BoxFit.cover,
//       );
//     }
//   }
// }

class FullScreenPhoto extends StatelessWidget {
  final String photoTag;
  final Widget photo;

  const FullScreenPhoto({required this.photoTag, required this.photo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme
          .colorScheme.background, // Background color of the fullscreen screen
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Exit fullscreen mode
        },
        child: Stack(
          children: [
            // Blurred background
            BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 10, sigmaY: 10), // Adjust blur intensity as needed
              child: Container(
                color:
                    theme.colorScheme.background, // Adjust opacity as needed),
              ),
            ),
            // Expanded photo widget
            Center(
              child: Hero(
                tag: photoTag,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width, child: (photo)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class NumberScrollingInput extends StatefulWidget {
//   final int maxInput;
//   final int step;
//   const NumberScrollingInput({required this.maxInput, this.step = 1});
//   @override
//   _NumberScrollingInputState createState() => _NumberScrollingInputState();
// }

// class _NumberScrollingInputState extends State<NumberScrollingInput> {
//   int selectedValue = 0;

//   @override
//   Widget build(BuildContext context) {
//     return NumberPicker(
//       value: selectedValue,
//       minValue: 0,
//       maxValue: widget.maxInput,
//       onChanged: (value) {
//         setState(() {
//           selectedValue = value;
//         });
//       },
//       itemHeight: 50, // Customize the height of each item
//       step: widget.step,
//     );
//   }
// }

class GymStatus {
  final String dayOfWeek;
  final TimeOfDay? openingTime;
  final TimeOfDay? closingTime;

  GymStatus(this.dayOfWeek, this.openingTime, this.closingTime);
}

class GymOpeningHours {
  final DateFormat dateFormat = DateFormat('hh:mm a');
  final List<String> openingHours;

  GymOpeningHours(this.openingHours);

  List<GymStatus> parseOpeningHours() {
    return openingHours.map((openingHour) {
      final String dayOfWeek = openingHour.split(':')[0];
      final String hoursPart =
          openingHour.substring(openingHour.indexOf(':') + 2).trim();

      if (hoursPart == 'Open 24 hours') {
        return GymStatus(dayOfWeek, null, null);
      } else if (hoursPart == 'Closed') {
        return GymStatus(dayOfWeek, TimeOfDay(hour: 0, minute: 0),
            TimeOfDay(hour: 0, minute: 0));
      } else {
        final List<String> timeParts = hoursPart.split('–');
        final String openingTimeStr = timeParts[0].trim();
        final String closingTimeStr = timeParts[1].trim();

        // final TimeOfDay openingTime = parseTime(openingTimeStr);
        // final TimeOfDay closingTime = parseTime(closingTimeStr);
        List<TimeOfDay> openAndClosingTime =
            parseTime('$openingTimeStr-$closingTimeStr');

        return GymStatus(
            dayOfWeek, openAndClosingTime[0], openAndClosingTime[1]);
      }
    }).toList();
  }

//   TimeOfDay parseTime(String timeStr) {
//   final String formattedTimeStr = timeStr.replaceAll('\u202F', ' ').trim();
//   final DateTime dateTime = dateFormat.parse(formattedTimeStr);
//   return TimeOfDay.fromDateTime(dateTime);
// }

  List<TimeOfDay> parseTime(String timeStr) {
    final String formattedTimeStr = timeStr.replaceAll('\u202F', ' ').trim();
    final List<String> timeParts = formattedTimeStr.split('-');
    final String openingTimeStr = timeParts[0].trim();
    final String closingTimeStr = timeParts[1].trim();

    String openingTimeFormatted = openingTimeStr;
    String closingTimeFormatted = closingTimeStr;

    if (!openingTimeStr.contains(RegExp('[APM]'))) {
      // If opening time does not contain AM/PM, assume it is the same as closing time's AM/PM
      final RegExp pmRegex = RegExp('PM');
      final RegExp amRegex = RegExp('AM');

      if (pmRegex.hasMatch(closingTimeStr)) {
        openingTimeFormatted += ' PM';
      } else if (amRegex.hasMatch(closingTimeStr)) {
        openingTimeFormatted += ' AM';
      }
    }

    final DateTime openingDateTime = dateFormat.parse(openingTimeFormatted);
    final DateTime closingDateTime = dateFormat.parse(closingTimeFormatted);

    return [
      TimeOfDay.fromDateTime(openingDateTime),
      TimeOfDay.fromDateTime(closingDateTime)
    ];
  }

  String getCurrentlyOpenString() {
    final DateTime now = DateTime.now();
    final int currentDayOfWeek = now.weekday;

    final List<GymStatus> gymStatusList = parseOpeningHours();
    final GymStatus gymStatus = gymStatusList[currentDayOfWeek - 1];

    if (gymStatus.openingTime == null || gymStatus.closingTime == null) {
      return 'Open 24 Hours';
    } else if (gymStatus.openingTime == TimeOfDay(hour: 0, minute: 0) &&
        gymStatus.closingTime == TimeOfDay(hour: 0, minute: 0)) {
      final DateTime? nextOpeningDateTime =
          findNextOpenDate(now, gymStatusList);
      if (nextOpeningDateTime == null) {
        print('ERROR - ALL SUBSEQUENT DAYS ARE CLOSED');
        return '';
      }
      return 'Closed - Opens ${formatHours(nextOpeningDateTime.hour)} ${[
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][nextOpeningDateTime.weekday - 1]}';
      // return 'Closed';
    } else {
      final DateTime openingDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        gymStatus.openingTime!.hour,
        gymStatus.openingTime!.minute,
      );
      DateTime closingDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        gymStatus.closingTime!.hour,
        gymStatus.closingTime!.minute,
      );

      if (gymStatus.closingTime!.hour == 12) {
        // Adjust closing time from 12 AM to 12 PM
        closingDateTime = closingDateTime.add(Duration(hours: 12));
      } else if (gymStatus.closingTime!.hour < gymStatus.openingTime!.hour) {
        // Adjust closing time if it is on the next day
        closingDateTime = closingDateTime.add(Duration(days: 1));
      }

      if (now.isBefore(openingDateTime)) {
        return 'Closed - Opens ${formatHours(openingDateTime.hour)}';
        // final Duration timeUntilOpen = openingDateTime.difference(now);
        // return 'Closed - Opens in ${formatDuration(timeUntilOpen)}';
      } else if (now.isAfter(closingDateTime)) {
        final DateTime? nextOpeningDateTime =
            findNextOpenDate(now, gymStatusList);
        if (nextOpeningDateTime == null) {
          print('ERROR - ALL SUBSEQUENT DAYS ARE CLOSED');
          return '';
        }
        // final DateTime nextOpeningDateTime = DateTime(
        //   now.year,
        //   now.month,
        //   now.day + 1,
        //   gymStatusList[(currentDayOfWeek) % 7].openingTime!.hour,
        //   gymStatusList[(currentDayOfWeek) % 7].openingTime!.minute,
        // );

        return 'Closed - Opens ${formatHours(nextOpeningDateTime.hour)} ${[
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun'
        ][nextOpeningDateTime.weekday - 1]}';
        // final Duration timeUntilOpen = nextOpeningDateTime.difference(now);
        // return 'Closed - Opens in ${formatDuration(timeUntilOpen)}';
      } else {
        return 'Open - Closes ${formatHours(closingDateTime.hour)}';
        // final Duration timeUntilClose = closingDateTime.difference(now);
        // return 'Open - Closes in ${formatDuration(timeUntilClose)}';
      }
    }
  }

  DateTime? findNextOpenDate(
      DateTime currentDate, List<GymStatus> gymStatusList) {
    final int currentDayOfWeek = currentDate.weekday;

    int nextDay = currentDayOfWeek;
    do {
      nextDay = (nextDay % 7) + 1; // Get the next day of the week
      final GymStatus nextDayStatus = gymStatusList[nextDay - 1];
      final TimeOfDay? openingTime = nextDayStatus.openingTime;
      final TimeOfDay? closingTime = nextDayStatus.closingTime;

      if (openingTime == null || closingTime == null) {
        // Open 24 hours
        return DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day + (nextDay - currentDayOfWeek),
          0,
          0,
        );
      }

      if (openingTime != TimeOfDay(hour: 0, minute: 0) ||
          closingTime != TimeOfDay(hour: 0, minute: 0)) {
        // Found a day where it is not closed the whole day
        return DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day + (nextDay - currentDayOfWeek),
          openingTime.hour,
          openingTime.minute,
        );
      }
    } while (nextDay !=
        currentDayOfWeek); // Keep iterating until returning to the current day

    return null; // Return null if no open day is found
  }

  String formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    return '$hours hours, $minutes minutes';
  }
}

String formatHours(int hour) {
  if (hour == 0) {
    return '12 AM';
  }
  if (hour == 12) {
    return '12 PM';
  }
  if (hour < 12) {
    return '$hour AM';
  } else if (hour < 24) {
    return '${hour % 12} PM';
  } else {
    // hour >= 24
    return formatHours(hour % 24);
  }
}

class GymCrowdednessChart extends StatefulWidget {
  final List<List<int>> data;
  final List<int> openingTimes;
  final List<int> closingTimes;

  GymCrowdednessChart(this.data, this.openingTimes, this.closingTimes);

  @override
  _GymCrowdednessChartState createState() => _GymCrowdednessChartState();
}

class _GymCrowdednessChartState extends State<GymCrowdednessChart> {
  int selectedWeekday = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall;
    final titleStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text('Predicted Gym Occupancy', style: titleStyle)),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int index = 0; index < widget.data.length; index++)
                Padding(
                  padding: index != 0
                      ? const EdgeInsets.fromLTRB(3, 0, 0, 0)
                      : EdgeInsets.zero,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedWeekday = index;
                      });
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        backgroundColor: resolveColor(selectedWeekday == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primaryContainer),
                        surfaceTintColor: resolveColor(selectedWeekday == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primaryContainer)),
                    child: Text(
                      getWeekdayName(index),
                      style: labelStyle!.copyWith(
                        fontSize: 10,
                        color: selectedWeekday == index
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: GestureDetector(
            onHorizontalDragUpdate:
                (_) {}, // Empty callback to prevent horizontal swiping
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: LineChart(
                createChartData(
                    widget.data[selectedWeekday],
                    widget.data,
                    widget.openingTimes[selectedWeekday],
                    widget.closingTimes[selectedWeekday],
                    selectedWeekday),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData createChartData(List<int> data, List<List<int>> allData,
      int minX, int maxX, int weekday) {
    final DateTime now = DateTime.now();
    final theme = Theme.of(context);
    final labelStyle = TextStyle(color: theme.colorScheme.onBackground);
    if (minX == -1 || maxX == -1) {
      return LineChartData(
          axisTitleData: FlAxisTitleData(
              topTitle: AxisTitle(
                  showTitle: true,
                  titleText: 'Closed',
                  textStyle: labelStyle.copyWith(
                      fontSize: 16,
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500),
                  reservedSize: 15)),
          lineBarsData: [
            LineChartBarData(
              show: true,
              spots: [FlSpot(100, 0)],
            )
          ],
          maxX: 1,
          minX: 0,
          maxY: 1,
          minY: 0,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false));
    }
    return LineChartData(
      extraLinesData: ExtraLinesData(verticalLines: [
        if (now.hour <= maxX && now.hour >= minX)
          VerticalLine(
              // Out of bounds if max x
              x: (now.hour + (now.hour != maxX ? (now.minute / 60.0) : 0)),
              dashArray: [8, 10],
              color: theme.colorScheme.primary,
              label: VerticalLineLabel(
                  show: true,
                  labelResolver: (p0) => 'Current time',
                  style: labelStyle,
                  alignment:
                      now.hour > 12 ? Alignment.topLeft : Alignment.topRight))
      ]),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final spot = touchedSpot;
              final xValue = spot.x.toInt();
              final String hour;
              hour = formatHours(xValue);
              final yValue = spot.y.toInt();
              return LineTooltipItem(
                '$hour\n$yValue% capacity',
                TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.white.withOpacity(.07)),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.white.withOpacity(.07)),
      ),
      axisTitleData: FlAxisTitleData(
          bottomTitle: AxisTitle(
              showTitle: true,
              titleText: getWeekdayFullName(selectedWeekday),
              textStyle: labelStyle,
              reservedSize: 23),
          leftTitle: AxisTitle(
              showTitle: true,
              titleText: 'Percent Capacity',
              textStyle: labelStyle,
              reservedSize: 23)),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 45,
          getTextStyles: (value) => TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(.65),
            fontSize: 12,
          ),
          getTitles: (value) => value % 10 == 0 ? '${value.toInt()}%' : '',
        ),
        // Buffer space
        rightTitles: SideTitles(
          showTitles: true,
          reservedSize: 25,
          checkToShowTitle:
              (minValue, maxValue, sideTitles, appliedInterval, value) => false,
        ),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(.65),
          ),
          getTitles: (value) {
            // X value
            if (value == minX) {
              return formatHours(minX);
            } else if (value == maxX) {
              return formatHours(maxX);
            } else if (maxX - minX >= 12) {
              if (value == minX + (3 * (maxX - minX)) ~/ 4) {
                return formatHours(minX + (3 * (maxX - minX)) ~/ 4);
              }
              if (value == minX + (2 * (maxX - minX)) ~/ 4) {
                return formatHours(minX + (2 * (maxX - minX)) ~/ 4);
              }
              if (value == minX + (maxX - minX) ~/ 4) {
                return formatHours(minX + (maxX - minX) ~/ 4);
              }
            } else if (maxX - minX >= 9) {
              if (value == minX + (2 * (maxX - minX)) ~/ 3) {
                return formatHours(minX + (2 * (maxX - minX)) ~/ 3);
              }
              if (value == minX + (maxX - minX) ~/ 3) {
                return formatHours(minX + (maxX - minX) ~/ 3);
              }
            } else if (maxX - minX >= 2 && value == (maxX + minX) ~/ 2) {
              return formatHours((maxX + minX) ~/ 2);
            }
            // switch (value.toInt()) {
            // case 0:
            //   return '12 AM';
            // case 6:
            //   return '6 AM';
            // case 12:
            //   return '12 PM';
            // case 18:
            //   return '6 PM';
            // case 23:
            //   return '11 PM';
            // }
            return '';
          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: Colors.white.withOpacity(.07))),
      minX: minX.toDouble(),
      maxX: maxX.toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        // if (minX != -1 && maxX != -1)
        LineChartBarData(
          spots: List.generate(
            maxX - minX + 1,
            (index) {
              if (index + minX < 24) {
                return FlSpot((index + minX).toDouble(),
                    (data[index + minX] * 100 / 13).round().toDouble());
              } else {
                // Check occupancy for next day
                int nextWeekdayIndex = (selectedWeekday + 1) % 7;
                int adjustedHourIndex = (index + minX) % 24;
                return FlSpot(
                    (index + minX).toDouble(),
                    (allData[nextWeekdayIndex][adjustedHourIndex] * 100 / 13)
                        .round()
                        .toDouble());
              }
            },
          ),
          isCurved: true,
          colors: [Theme.of(context).colorScheme.primary],
          barWidth: 4,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: true),
        ),
      ],
    );
  }

  String getWeekdayName(int index) {
    final weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return weekdays[index];
  }

  String getWeekdayFullName(int index) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[index];
  }

  int calculatePercentage(int value) {
    int result = (value * 100 / 13).round();
    return result;
  }
}
