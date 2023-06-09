import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:numberpicker/numberpicker.dart';

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
  // List<String> urls = [];
  // List<Widget> images = [];

  bool editResourcesMode = false;
  bool editMachinesMode = false;

  late bool isSelectedGym;

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
      // for (String resource in resourceKeys) {
      //   // resourcesAvailable = {};
      //   resourcesAvailable.putIfAbsent(resource, () => 0);
      // }
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
                        SizedBox(
                          height: 3,
                        ),
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

  @override
  Widget build(BuildContext context) {
    if (widget.gym == null) {
      return Placeholder();
    }
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

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
          SizedBox(
            width: 15,
          ),
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
    final titleStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final headlineStyle = theme.textTheme.titleSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final bodyMedium = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final textStyle = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    Widget selectButtonLabel;
    Widget selectButtonIcon;
    if (!isSelectedGym) {
      selectButtonLabel = Icon(
        Icons.check_box_outline_blank,
        size: 20,
      );
      selectButtonIcon = Text('Select gym', style: textStyle);
    } else {
      selectButtonLabel = Icon(
        Icons.check_box,
        size: 20,
      );
      selectButtonIcon = Text('Selected gym', style: textStyle);
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
              children: [
                Text(
                  widget.gym!.name,
                  style: titleStyle,
                ),
                if (widget.gym!.openNow != null &&
                    widget.gym!.isOpenNow() == true)
                  Text(
                    'Open Now',
                    style: headlineStyle.copyWith(
                        color: theme.colorScheme.primary),
                  ),
                if (widget.gym!.openNow != null &&
                    widget.gym!.isOpenNow() == false)
                  Text(
                    'Closed',
                    style: headlineStyle.copyWith(
                        color: theme.colorScheme.secondary),
                  ),
              ],
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.gym!.formattedAddress,
                    style: labelStyle,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
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

                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rating - ',
                          style: bodyMedium,
                        ),
                        if (widget.gym!.googleMapsRating != null &&
                            widget.gym!.googleMapsRating! > 4.0)
                          Text(
                            '${widget.gym!.googleMapsRating ?? 0} Stars',
                            style: textStyle.copyWith(
                                color: theme.colorScheme.primary),
                          ),
                        if (widget.gym!.googleMapsRating != null &&
                            (widget.gym!.googleMapsRating! <= 4.0 &&
                                widget.gym!.googleMapsRating! > 2.5))
                          Text(
                            '${widget.gym!.googleMapsRating ?? 0} Stars',
                            style: textStyle.copyWith(color: Colors.yellow),
                          ),
                        if (widget.gym!.googleMapsRating != null &&
                            widget.gym!.googleMapsRating! <= 2.5)
                          Text(
                            '${widget.gym!.googleMapsRating ?? 0} Stars',
                            style: textStyle.copyWith(color: Colors.yellow),
                          ),
                        if (widget.gym!.googleMapsRating == null)
                          Text(
                            'No rating available',
                            style: textStyle.copyWith(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.65),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.gym!.googleMapsRating != null)
                          for (int i = 0; i < 5; i++)
                            if (i + 1 <= widget.gym!.googleMapsRating!)
                              Icon(
                                Icons.star,
                                color: theme.colorScheme.primary,
                                size: 20,
                              )
                            else if (i + 0.5 <= widget.gym!.googleMapsRating!)
                              Icon(
                                Icons.star_half,
                                color: theme.colorScheme.primary,
                                size: 20,
                              )
                            else
                              Icon(
                                Icons.star_border,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: resolveColor(
                                theme.colorScheme.primaryContainer,
                              ),
                              surfaceTintColor: resolveColor(
                                theme.colorScheme.primaryContainer,
                              ),
                            ),
                            onPressed: () {
                              launchUrl(Uri.parse(widget.gym!.url));
                            },
                            child: Text('View on Map', style: labelStyle),
                          ),
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
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            'Gym Resources',
                            style: titleStyle,
                          ),
                          SizedBox(
                            width: 10,
                          ),
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
                              icon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
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
                              icon: Icon(
                                Icons.cancel,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              // label: Text('Edit', style: TextStyle(color: theme.colorScheme.onBackground),),
                            ),
                          if (editResourcesMode)
                            SizedBox(
                              width: 10,
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
                                  widget.gym!.resourcesAvailable =
                                      Map.from(resourcesAvailable);
                                  editResourcesMode = false;
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
                      SizedBox(
                        height: 10,
                      ),
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
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          showResources[i]
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: theme.colorScheme.primary,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: showResources[i] ? 10 : 5,
                                  ),
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
                                                      SizedBox(
                                                        height: 5,
                                                      ),
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
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                        ),
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
                                                              ),
                                                            )),
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
                                                  SizedBox(
                                                    width: 10,
                                                  ),
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
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            'Machines Available',
                            style: titleStyle,
                          ),
                          SizedBox(
                            width: 10,
                          ),
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
                              icon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
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
                              icon: Icon(
                                Icons.cancel,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              // label: Text('Edit', style: TextStyle(color: theme.colorScheme.onBackground),),
                            ),
                          if (editMachinesMode)
                            SizedBox(
                              width: 10,
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
                        SizedBox(
                          height: 10,
                        ),
                      if (!(machinesAvailable.isEmpty && !editMachinesMode))
                        SizedBox(
                          height: 5,
                        ),
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
                              if (editMachinesMode)
                                SizedBox(
                                  width: 10,
                                ),
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
                                                          Icons.delete_forever,
                                                          size: 20,
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              if (i <
                                                  machinesAvailable.length - 1)
                                                SizedBox(
                                                  width: 10,
                                                ),
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
}

class GymImageContainer extends StatefulWidget {
  final Uint8List bytes;

  GymImageContainer({required this.bytes});

  @override
  _GymImageContainerState createState() => _GymImageContainerState();
}

class _GymImageContainerState extends State<GymImageContainer> {
  bool _loading = true;
  bool _error = false;

  void _loadImage() {
    // Image.network(widget.imageUrl)
    //     .image
    //     .resolve(const ImageConfiguration())
    //     .addListener(ImageStreamListener((info, _) {
    //       if (mounted) {
    //         setState(() {
    //           _loading = false;
    //         });
    //       }
    //     }, onError: (_, __) {
    //       if (mounted) {
    //         setState(() {
    //           _loading = false;
    //           _error = true;
    //         });
    //       }
    //     }));
    Image.memory(widget.bytes)
        .image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        }, onError: (_, __) {
          if (mounted) {
            setState(() {
              _loading = false;
              _error = true;
            });
          }
        }));
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: Colors.grey,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_error) {
      return Container(
        color: Colors.grey,
      );
    } else {
      return Image.memory(
        widget.bytes,
        fit: BoxFit.cover,
      );
    }
  }
}

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
