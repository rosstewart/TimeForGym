// import 'dart:async';

// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/gym_page.dart';
// import 'package:provider/provider.dart';
import 'package:time_for_gym/main.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:time_for_gym/gym.dart';

// import 'api_keys.dart';
// import 'package:time_for_gym/gym_page.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  // final StateSetter? setAuthenticationState;
  // HomePage(this.setAuthenticationState);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final FocusNode _gymSearchFocusNode = FocusNode();
  String? currentlyOpenString;
  String weightedAverageString = '';
  DateTime currentTime = DateTime.now();
  final TextEditingController _searchTextController = TextEditingController();

  void _dismissKeyboard(MyAppState appState) {
    // Unfocus the text fields when tapped outside
    FocusScope.of(context).unfocus();
    appState.isHomePageSearchFieldFocused = false;
  }

  void _handleGymSubmit(Gym gym, MyAppState appState) async {
    appState.loadGymPhotos(gym.placeId);

    setState(() {
      appState.isHomePageSearchFieldFocused = false;
    });

    appState.currentGym = gym;
    // Change to gym page
    appState.changePage(9);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState
    // var pair = appState.current;
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final titleStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);

    // Open 24 hours or Open -
    if (currentlyOpenString == null) {
      if (appState.userGym == null || appState.userGym!.openingHours == null) {
        currentlyOpenString = '';
      } else {
        final GymOpeningHours gymOpeningHours =
            GymOpeningHours(appState.userGym!.openingHours!);
        currentlyOpenString = gymOpeningHours.getCurrentlyOpenString();
      }
      if (currentlyOpenString!.contains('Open ') ||
          (appState.userGym != null &&
              appState.userGym!.openingHours == null)) {
        double currentHourPctCapacity =
            (appState.avgGymCrowdData[currentTime.weekday - 1]
                        [currentTime.hour] /
                    13.0) *
                100;
        double nextHourPctCapacity;
        if (currentTime.hour + 1 == 24) {
          // Next day, 12 AM
          nextHourPctCapacity =
              (appState.avgGymCrowdData[currentTime.weekday % 7][0] / 13.0) *
                  100;
        } else {
          nextHourPctCapacity =
              (appState.avgGymCrowdData[currentTime.weekday - 1]
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
    }
    currentlyOpenString ??= '';

    final headlineStyle = theme.textTheme.titleSmall!.copyWith(
        color: currentlyOpenString!.startsWith('Closed')
            ? theme.colorScheme.secondary
            : theme.colorScheme.primary);
    final subHeadlineStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return GestureDetector(
      onTap: () {
        _dismissKeyboard(appState);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 65,
          title: appState.userGym != null
              ?
              //  ElevatedButton(
              //     style: ButtonStyle(
              //       backgroundColor: resolveColor(
              //         theme.colorScheme.primaryContainer,
              //       ),
              //       surfaceTintColor: resolveColor(
              //         theme.colorScheme.primaryContainer,
              //       ),
              //     ),
              //     onPressed: () {},
              //     child: SizedBox(
              //       height: 100,
              GestureDetector(
                  onTap: () {
                    _handleGymSubmit(appState.userGym!, appState);
                  },
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Column(
                      children: [
                        Text(
                          appState.userGym!.name,
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        if (currentlyOpenString != null)
                          SizedBox(
                            width: 200,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // There is openingHours data for the gym
                                  if (currentlyOpenString!.isNotEmpty)
                                    if (!currentlyOpenString!.contains('-'))
                                      Text(currentlyOpenString!,
                                          style: headlineStyle,
                                          textAlign: TextAlign.center),
                                  if (currentlyOpenString!.isNotEmpty)
                                    if (currentlyOpenString!.contains('-'))
                                      Text(currentlyOpenString!.split('-')[0],
                                          style: headlineStyle,
                                          textAlign: TextAlign.center),
                                  if (currentlyOpenString!.isNotEmpty)
                                    if (currentlyOpenString!.contains('-'))
                                      Text(
                                          '-${currentlyOpenString!.split('-')[1]}',
                                          style: subHeadlineStyle,
                                          textAlign: TextAlign.center),
                                ]),
                          ),
                        if (weightedAverageString.isNotEmpty ||
                            (currentlyOpenString != null &&
                                currentlyOpenString!.isEmpty))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,3,0,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomCircularProgressIndicator(
                                    percentCapacity: double.parse(
                                            weightedAverageString.substring(
                                                0,
                                                weightedAverageString.length -
                                                    1)) /
                                        100.0,
                                    strokeWidth: 1.5,
                                    size: 9.0),
                                SizedBox(width: 6),
                                Text('Estimated $weightedAverageString capacity',
                                    style: labelStyle),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              //   ),
              // )
              : null,
          // title: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Spacer(
          //       flex: 23,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          //       child: SizedBox(
          //         height: 50,
          //         child: Image.asset('assets/images/gym_brain_logo.png'),
          //       ),
          //     ),
          //     Spacer(
          //       flex: 15,
          //     ),
          //     GestureDetector(
          //       onTapDown: (tapDownDetails) {
          //         showInfoDropdown(context, tapDownDetails.globalPosition);
          //       },
          //       child: Icon(
          //         Icons.info_outline,
          //         color: theme.colorScheme.onBackground.withOpacity(.65),
          //       ),
          //     ),
          //     SizedBox(width: 10),
          //     GestureDetector(
          //       onTapDown: (tapDownDetails) {
          //         showOptionsDropdown(
          //             context, tapDownDetails.globalPosition, appState);
          //       },
          //       child: Icon(
          //         Icons.more_horiz,
          //         color: theme.colorScheme.onBackground.withOpacity(.65),
          //       ),
          //     ),
          //   ],
          // ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // SizedBox(
            //   // width: MediaQuery.of(context).size.width - 100,
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
            //     child: Text(
            //         'Hello, ${appState.currentUser.profileName.isNotEmpty ? appState.currentUser.profileName : (appState.currentUser.username)}',
            //         style: theme.textTheme.headlineSmall!
            //             .copyWith(color: theme.colorScheme.onBackground),
            //         textAlign: TextAlign.center,
            //         maxLines: 1),
            //   ),
            // ),
            // PageSelectorButton(
            //   text: "Gym Occupancy",
            //   index: 3,
            //   icon: Icon(Icons.people),
            // ),
            SizedBox(
              height: 100,
            ),
            SizedBox(
              width: 350,
              child: Column(
                children: [
                  Text('Search Gyms near',
                      style: theme.textTheme.titleMedium!
                          .copyWith(color: theme.colorScheme.onBackground),
                      textAlign: TextAlign.center),
                  Text('Coral Gables, FL',
                      style: theme.textTheme.headlineSmall!
                          .copyWith(color: theme.colorScheme.onBackground),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),

            GymSearchBar(
              textEditingController: _searchTextController,
            ),
          ],
        ),
      ),
    );
  }

  // void showOptionsDropdown(
  //     BuildContext context, Offset tapPosition, MyAppState appState) {
  //   final theme = Theme.of(context);
  //   final labelStyle =
  //       TextStyle(color: theme.colorScheme.onBackground, fontSize: 10);

  //   showMenu<String>(
  //     color: theme.colorScheme.primaryContainer,
  //     surfaceTintColor: theme.colorScheme.primaryContainer,
  //     context: context,
  //     position: RelativeRect.fromLTRB(
  //       tapPosition.dx,
  //       tapPosition.dy,
  //       tapPosition.dx + 1,
  //       tapPosition.dy + 1,
  //     ),
  //     items: [
  //       PopupMenuItem(
  //         padding: EdgeInsets.zero,
  //         value: 'Sign out',
  //         child: ListTile(
  //           visualDensity: VisualDensity(
  //               vertical: VisualDensity.minimumDensity,
  //               horizontal: VisualDensity.minimumDensity),
  //           dense: true,
  //           title: Text('Sign out', style: labelStyle),
  //         ),
  //       ),
  //     ],
  //   ).then((value) {
  //     if (value == 'Sign out') {
  //       if (widget.setAuthenticationState != null) {
  //         widget.setAuthenticationState!(() {
  //           isAuthenticated = false;
  //           // appState.currentUser = null;
  //           appState.currentSplit = null;
  //           appState.makeNewSplit = true;
  //           appState.editModeTempSplit = null;
  //           appState.editModeTempExerciseIndices = null;
  //           appState.splitDayExerciseIndices = [[], [], [], [], [], [], []];
  //           appState.goStraightToSplitDayPage = false;
  //           appState.hasSubmittedData = false;
  //           appState.isInitializing = true;
  //           appState.isHomePageSearchFieldFocused = false;
  //           appState.lastVisitedSearchPage = 8;
  //           appState.userGym = null;
  //           appState.showAdBeforeExerciseCounter = 2;
  //           appState.presetHomePage = 0;
  //           appState.presetSearchPage = 0;
  //           appState.muscleGroups = {};
  //           appState.favoriteExercises = [];
  //           appState.pageIndex = 13;
  //           appState.gymCount = -1;
  //           appState.maxCapacity = 200;
  //           appState.areMuscleGroupsInitialized = false;
  //           appState.isGymCountInitialized = false;
  //           appState.userProfileStack = [];
  //           appState.userProfileStackFromOwnProfile = [];
  //         });
  //       }

  //       FirebaseAuth.instance.signOut();
  //       print(isAuthenticated);
  //     }
  //   });
  // }

  // void showInfoDropdown(BuildContext context, Offset tapPosition) {
  //   final theme = Theme.of(context);
  //   final labelStyle =
  //       TextStyle(color: theme.colorScheme.onBackground, fontSize: 10);

  //   showMenu<String>(
  //     color: theme.colorScheme.primaryContainer,
  //     surfaceTintColor: theme.colorScheme.primaryContainer,
  //     context: context,
  //     position: RelativeRect.fromLTRB(
  //       tapPosition.dx,
  //       tapPosition.dy,
  //       tapPosition.dx + 1,
  //       tapPosition.dy + 1,
  //     ),
  //     items: [
  //       PopupMenuItem(
  //         enabled: false,
  //         padding: EdgeInsets.zero,
  //         child: ListTile(
  //           visualDensity: VisualDensity(
  //               vertical: VisualDensity.minimumDensity,
  //               horizontal: VisualDensity.minimumDensity),
  //           dense: true,
  //           title: Text(
  //               'Developed by Ross Stewart\nReport issues to rosscstewart10@gmail.com',
  //               style: labelStyle.copyWith(
  //                   color: theme.colorScheme.onBackground.withOpacity(.65))),
  //         ),
  //       ),
  //     ],
  //   ).then((value) {
  //     if (value == 'Sign out') {
  //       if (widget.setAuthenticationState != null) {
  //         widget.setAuthenticationState!(() {
  //           isAuthenticated = false;
  //         });
  //       }
  //       FirebaseAuth.instance.signOut();
  //       print(isAuthenticated);
  //     }
  //   });
  // }
}

class GymSearchBar extends StatefulWidget {
  final TextEditingController textEditingController;

  GymSearchBar({
    required this.textEditingController,
  });
  @override
  _GymSearchBarState createState() => _GymSearchBarState();
}

class _GymSearchBarState extends State<GymSearchBar> {
  // final places = GoogleMapsPlaces(apiKey: googleMapsApiKey);
  // List<PlacesSearchResult> searchResults = [];
  // List<PlacesDetailsResponse> updatedResults = [];

  List<Gym> searchResults = [];
  FocusNode focusNode = FocusNode();

  // bool _isTextFieldFocused = false;
  // Timer? _timer;

  // String _textFieldValue = '';

  // @override
  // void initState() {
  //   super.initState();
  //   widget.textFocusNode.addListener(_handleFocusChange);
  // }

  // void _handleFocusChange() {
  //   setState(() {
  //     _isTextFieldFocused = widget.textFocusNode.hasFocus;
  //   });
  // }

  void _handleGymSubmit(Gym gym, MyAppState appState) async {
    appState.loadGymPhotos(gym.placeId);

    setState(() {
      widget.textEditingController.text = gym.name;
      appState.isHomePageSearchFieldFocused = false;
    });
    appState.currentGym = gym;

    // try {
    //   // appState.currentGymPlacesDetailsResponse =
    //   //     (await GoogleMapsPlaces(apiKey: googleMapsApiKey).getDetailsByPlaceId(gym.placeId)).result;
    //   for (String gymKey in appState.gyms.keys) {
    //     PlaceDetails placeDetails = (await GoogleMapsPlaces(apiKey: googleMapsApiKey).getDetailsByPlaceId(gymKey)).result;
    //     List<String>? openingHours;
    //     if (placeDetails.openingHours == null) {
    //       print('ERROR - $gymKey: ${placeDetails.name} opening hours is null');
    //     } else {
    //       openingHours = placeDetails.openingHours!.weekdayText;
    //     }
    //     Gym theGym = appState.gyms[gymKey]!;
    //     theGym.openingHours = openingHours; // Could be null
    //     theGym.gymUrl = placeDetails.website; // Could be null
    //     theGym.internationalPhoneNumber = placeDetails.internationalPhoneNumber; // Could be null
    //     appState.submitGymDataToFirebase(theGym);
    //   }
    // } catch (e) {
    //   print('Error loading gym - $e');
    // }

    // Change to gym page
    appState.changePage(9);
  }

  // void _handleTextFieldSubmit(PlaceDetails place, MyAppState appState) {
  //   setState(() {
  //     widget.textEditingController.text = place.name;
  //     // _isTextFieldFocused = false;
  //     appState.isHomePageSearchFieldFocused = false;
  //   });
  //   print(place.name);
  //   print(place.placeId);
  //   // print('vicinity ${place.vicinity}');
  //   // print('perm closed ${place.permanentlyClosed}');
  //   // print('price ${place.priceLevel}');
  //   // print('opening hours ${place.openingHours!.}');
  //   // print('types ${place.types}');
  //   // print('reference ${place.reference}');
  //   // print('scope ${place.scope}');
  //   print('rating ${place.rating}');

  //   // if (photos.isNotEmpty) {
  //   //   print('photo reference ${photos[0].photoReference}');
  //   // }
  //   // print('length ${photos.length}');
  //   // place.photos;
  //   // return;
  //   // if (place) {
  //   //   widget.textEditingController.text = 'This location is permanently closed';
  //   // } else {
  //   bool? openNow;
  //   double? googleMapsRating;
  //   if (place.openingHours != null) {
  //     openNow = place.openingHours!.openNow;
  //   }
  //   if (place.rating != null) {
  //     googleMapsRating = place.rating!.toDouble();
  //   }

  //   List<String> urls = [];
  //   // List<Widget> images = [];

  //   if (appState.gyms[place.placeId] != null) {
  //     // Gym entry already exists
  //     appState.currentGym = appState.gyms[place.placeId];
  //     appState.currentGym!.updateGoogleMapsData(
  //       place.name,
  //       place.formattedAddress ?? '',
  //       // images,
  //       openNow,
  //       googleMapsRating,
  //       place.url ?? '',
  //     );
  //   } else {
  //     // Only request new photos if new gym entry to reduce api requests
  //     for (int i = 0; i < place.photos.length; i++) {
  //       urls.add(place.photos[i].photoReference);
  //       // 1000 arbitrary for scale
  //       urls[i] =
  //           'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photo_reference=${urls[i]}&key=$googleMapsApiKey';
  //       // images.add(GymImageContainer(
  //       //   imageUrl: urls[i],
  //       // ));
  //     }
  //     // Make new gym entry
  //     Gym gym = Gym(
  //         name: place.name,
  //         placeId: place.placeId,
  //         formattedAddress: place.formattedAddress ?? '',
  //         photos: [],
  //         openNow: openNow,
  //         googleMapsRating: googleMapsRating,
  //         url: place.url ?? '',
  //         machinesAvailable: [],
  //         resourcesAvailable: {});
  //     appState.currentGym = gym;
  //     appState.gyms.putIfAbsent(place.placeId, () => gym);
  //     appState.submitGymDataToFirebase(appState.currentGym!, urls);
  //     // Fetch firebase photos and store them in gym
  //   }
  //   // Change to gym page
  //   // appState.changePage(9);
  //   // }
  // }

  void searchGyms(String searchTerm, MyAppState appState) {
    print(appState.gyms.values);

    setState(() {
      searchResults = appState.gyms.values
          .where((gym) =>
              gym.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
      searchResults.sort();
      List<Gym> universityGym = searchResults
          .where((gym) => gym.name == 'Patti and Allan Herbert Wellness Center')
          .toList();
      if (universityGym.isNotEmpty) {
        searchResults.remove(universityGym[0]);
        searchResults.insert(0, universityGym[0]);
      }
    });
    print(searchResults);
  }

  // Future<void> searchGyms(String searchTerm, var appState) async {
  //   // print('all places length ${places.}');
  //   final location = [
  //     25.7174,
  //     -80.2760
  //   ]; // Latitude and longitude for the University of Miami

  //   try {
  //     final response = await places.searchByText(
  //       'gym $searchTerm',
  //       type: 'gym',
  //       radius: 5000, // Set a larger radius (e.g., 5 km)
  //       location: Location(lat: location[0], lng: location[1]),
  //     );

  //     List<PlacesSearchResult> results = response.results;

  //     String nextPageToken = '';

  //     do {
  //       final stringLocation =
  //           '${location[0]},${location[1]}'; // Specify the latitude and longitude of the desired location
  //       final encodedLocation = Uri.encodeQueryComponent(stringLocation);

  //       final url = Uri.parse(
  //           'https://maps.googleapis.com/maps/api/place/textsearch/json?query=gym+$searchTerm&location=$encodedLocation&key=$googleMapsApiKey&pagetoken=$nextPageToken');
  //       final response = await http.get(url);
  //       final decodedResponse = jsonDecode(response.body);

  //       if (decodedResponse['status'] == 'OK') {
  //         results
  //             .addAll(PlacesSearchResponse.fromJson(decodedResponse).results);
  //         nextPageToken = decodedResponse['next_page_token'] ?? '';
  //       } else {
  //         break;
  //       }

  //       // Wait for a few seconds before making the next request
  //       await Future.delayed(Duration(seconds: 2));
  //     } while (nextPageToken.isNotEmpty);

  //     print('places length ${response.results.length}');

  //     if (response.status == 'OK') {
  //       updatedResults = await Future.wait(response.results
  //           .map((place) => places.getDetailsByPlaceId(place.placeId)));

  //       setState(() {
  //         searchResults = response.results;
  //       });
  //     }

  //     for (PlacesDetailsResponse updatedResult in updatedResults) {
  //       _handleTextFieldSubmit(updatedResult.result, appState);
  //     }
  //   } catch (e) {
  //     // Sometimes a network error is thrown here
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final bodyLargeTheme = theme.textTheme.bodyLarge!
        .copyWith(color: theme.colorScheme.onBackground);
    bool autofocus = appState.userGym != null;
    return Column(
      children: [
        if (!appState.isHomePageSearchFieldFocused && appState.userGym != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    _handleGymSubmit(appState.userGym!, appState);
                  },
                  icon: Icon(Icons.fitness_center, size: 20),
                  label: Text('Your Gym', style: bodyLargeTheme),
                ),
                SizedBox(
                  width: 5,
                ),
                IconButton(
                  onPressed: () {
                    searchGyms(widget.textEditingController.text, appState);
                    // widget.textEditingController
                    //     .clear(); // Clear the text in the controller
                    // FocusScope.of(context).requestFocus(
                    //     focusNode); // Request focus on the text field
                    setState(() {
                      appState.isHomePageSearchFieldFocused = true;
                    });
                  },
                  icon: Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        if (appState.isHomePageSearchFieldFocused || appState.userGym == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextFormField(
                  autofocus: autofocus,
                  // focusNode: focusNode,
                  textInputAction: TextInputAction.done,
                  // onEditingComplete: () {
                  //   searchGyms(widget.textEditingController.text, appState);
                  //   widget.textEditingController.clear();
                  // },
                  onTap: () {
                    searchGyms('', appState);
                    setState(() {
                      // _isTextFieldFocused = true;
                      appState.isHomePageSearchFieldFocused = true;
                    });
                  },
                  controller: widget.textEditingController,
                  style: TextStyle(color: theme.colorScheme.onBackground),
                  onChanged: (value) {
                    searchGyms(value, appState);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                    ),
                    labelText: 'Search Gyms',
                    labelStyle: TextStyle(
                        color:
                            theme.colorScheme.onBackground.withOpacity(0.65)),
                    floatingLabelStyle: TextStyle(
                        color:
                            theme.colorScheme.onBackground.withOpacity(0.65)),
                    suffixIcon: widget.textEditingController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              widget.textEditingController.clear();
                              appState.isHomePageSearchFieldFocused = true;
                              searchGyms('', appState);
                              // Clear any search results or perform any other action
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        if (appState.isHomePageSearchFieldFocused)
          Column(
            children: [
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 350,
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    // final place = searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ListTile(
                          onTap: () {
                            _handleGymSubmit(searchResults[index], appState);
                          },
                          title: Text(
                            searchResults[index].name,
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          subtitle: Text(
                            searchResults[index].formattedAddress,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    // _textEditingController.dispose();
    // widget.textFocusNode.removeListener(_handleFocusChange);
    // widget.textFocusNode.dispose();
    // _timer?.cancel();
    // places.dispose();
    super.dispose();
  }
}
