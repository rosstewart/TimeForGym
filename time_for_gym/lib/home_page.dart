// import 'dart:async';

// import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
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
  final StateSetter? setAuthenticationState;
  HomePage(this.setAuthenticationState);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final FocusNode _gymSearchFocusNode = FocusNode();
  final TextEditingController _searchTextController = TextEditingController();

  void _dismissKeyboard(MyAppState appState) {
    // Unfocus the text fields when tapped outside
    FocusScope.of(context).unfocus();
    appState.isHomePageSearchFieldFocused = false;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState
    // var pair = appState.current;
    final theme = Theme.of(context);

    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    return GestureDetector(
      onTap: () {
        _dismissKeyboard(appState);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(
                flex: 16,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: SizedBox(
                  height: 50,
                  child: Image.asset('assets/images/gym_brain_logo.png'),
                ),
              ),
              Spacer(
                flex: 15,
              ),
              GestureDetector(
                onTapDown: (tapDownDetails) {
                  showInfoDropdown(context, tapDownDetails.globalPosition);
                },
                child: Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onBackground.withOpacity(.65),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTapDown: (tapDownDetails) {
                  showOptionsDropdown(context, tapDownDetails.globalPosition);
                },
                child: Icon(
                  Icons.more_horiz,
                  color: theme.colorScheme.onBackground.withOpacity(.65),
                ),
              ),
            ],
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              // width: MediaQuery.of(context).size.width - 100,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                child: Text('Hello, ${authUser.displayName ?? ''}',
                    style: theme.textTheme.headlineSmall!
                        .copyWith(color: theme.colorScheme.onBackground),
                    textAlign: TextAlign.center,
                    maxLines: 1),
              ),
            ),
            PageSelectorButton(
              text: "Gym Occupancy",
              index: 3,
              icon: Icon(Icons.people),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Search Gyms near Coral Gables, FL',
              style: theme.textTheme.titleMedium!
                  .copyWith(color: theme.colorScheme.onBackground),
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

  void showOptionsDropdown(BuildContext context, Offset tapPosition) {
    final theme = Theme.of(context);
    final labelStyle =
        TextStyle(color: theme.colorScheme.onBackground, fontSize: 10);

    showMenu<String>(
      color: theme.colorScheme.primaryContainer,
      surfaceTintColor: theme.colorScheme.primaryContainer,
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Sign out',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            title: Text('Sign out', style: labelStyle),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Sign out') {
        if (widget.setAuthenticationState != null) {
          widget.setAuthenticationState!(() {
            isAuthenticated = false;
          });
        }
        FirebaseAuth.instance.signOut();
        print(isAuthenticated);
      }
    });
  }

  void showInfoDropdown(BuildContext context, Offset tapPosition) {
    final theme = Theme.of(context);
    final labelStyle =
        TextStyle(color: theme.colorScheme.onBackground, fontSize: 10);

    showMenu<String>(
      color: theme.colorScheme.primaryContainer,
      surfaceTintColor: theme.colorScheme.primaryContainer,
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            title: Text(
                'Developed by Ross Stewart\nReport issues to rosscstewart10@gmail.com',
                style: labelStyle.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(.65))),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Sign out') {
        if (widget.setAuthenticationState != null) {
          widget.setAuthenticationState!(() {
            isAuthenticated = false;
          });
        }
        FirebaseAuth.instance.signOut();
        print(isAuthenticated);
      }
    });
  }
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
                    _handleGymSubmit(appState.userGym!, appState);
                  },
                  child: Text('Your Gym', style: bodyLargeTheme),
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
                height: 265,
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
