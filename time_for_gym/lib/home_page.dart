// import 'dart:async';

// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
import 'package:time_for_gym/main.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:google_maps_webservice/places.dart';
// import 'api_keys.dart';
import 'package:time_for_gym/gym.dart';
// import 'package:time_for_gym/gym_page.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class HomePage extends StatefulWidget {
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
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: SizedBox(
              height: 50,
              child: Image.asset('assets/images/gym_brain_logo.png'),
            ),
          ),

          // title: Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     RichText(
          //       text: TextSpan(
          //         style: TextStyle(),
          //         children: <TextSpan>[
          //           TextSpan(
          //             text: 'Gym',
          //             style: titleStyle1,
          //           ),
          //           TextSpan(
          //             text: 'Brain',
          //             style: titleStyle2,
          //           ),
          //         ],
          //       ),
          //     ),
          //     SizedBox(width: 10),
          //     Icon(Icons.self_improvement_sharp, color: theme.colorScheme.secondary,)
          //   ],
          // ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // PageSelectorButton(
            //   text: "Exercise Library",
            //   index: 8,
            //   icon: Icon(Icons.library_books),
            // ),
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
              // isFocused: _isSearchFieldFocused,
            ),
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

// ignore: must_be_immutable
class GymSearchBar extends StatefulWidget {
  final TextEditingController textEditingController;
  // final bool isFocused;

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

  void _handleGymSubmit(Gym gym, MyAppState appState) {
    // appState.loadGymPhotos(gym.placeId);

    setState(() {
      widget.textEditingController.text = gym.name;
      appState.isHomePageSearchFieldFocused = false;
    });
    appState.currentGym = gym;

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
