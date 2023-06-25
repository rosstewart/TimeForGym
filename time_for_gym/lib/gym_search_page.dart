// import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'api_keys.dart';



// class GymSearchBar extends StatefulWidget {
//   @override
//   _GymSearchBarState createState() => _GymSearchBarState();
// }

// class _GymSearchBarState extends State<GymSearchBar> {
//   final places = GoogleMapsPlaces(apiKey: googleMapsApiKey);
//   List<PlacesSearchResult> searchResults = [];

//   Future<void> searchGyms(String searchTerm) async {
//     final response = await places.searchByText(
//       'gym $searchTerm',
//       type: 'gym',
//     );

//     if (response.status == 'OK') {
//       setState(() {
//         searchResults = response.results;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 onChanged: (value) {
//                   searchGyms(value);
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Search Gyms',
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: searchResults.length,
//                 itemBuilder: (context, index) {
//                   final place = searchResults[index];
//                   return ListTile(
//                     title: Text(place.name),
//                     subtitle: Text(place.formattedAddress ?? ''),
//                     onTap: () {
//                       // Handle the selection of a gym place
//                       // You can navigate to another screen or perform any other action
//                       print(place.placeId);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//     );
//   }

//   @override
//   void dispose() {
//     places.dispose();
//     super.dispose();
//   }
// }
