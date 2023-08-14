// import 'package:algolia/algolia.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:unicons/unicons.dart';

// class StayLocationSearchDelegate extends SearchDelegate {
//   late SharedPreferences _preferences;
//   Future<SharedPreferences> _initPrefs() async {
//     return _preferences = await SharedPreferences.getInstance();
//   }

//   StayLocationSearchDelegate({required final String hintText})
//       : super(searchFieldLabel: hintText);

//   late PlaceApiProvider apiClient;

//   final LocationService _locationService = LocationService();

//   // Future<List<String>?> _getRecentSearches() async {
//   //   final _preferences = await _initPrefs();
//   //   final List<String>? allSearches =
//   //       _preferences.getStringList("recentSearches");
//   //   return allSearches; //?.where((search) => search.startsWith(query)).toList();
//   // }

//   Future<void> _saveToRecentSearches(String? searchText) async {
//     if (searchText == null) return; //Should not be null
//     _preferences = await _initPrefs();

//     //Use `Set` to avoid duplication of recentSearches
//     Set<String> allSearches =
//         _preferences.getStringList("recentSearches")?.toSet() ?? {};

//     //Place it at first in the set
//     allSearches = {searchText, ...allSearches};
//     _preferences.setStringList("recentSearches", allSearches.toList());
//   }

//   @override
//   PreferredSizeWidget buildBottom(BuildContext context) {
//     final theme = Theme.of(context);
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(56.0),
//       child: ListTile(
//         leading: const Icon(UniconsLine.location_pin_alt),
//         title: Text(
//           AppLocalizations.of(context)!.current_location,
//           style: theme.textTheme.titleMedium,
//         ),
//         onTap: () async {
//           final currentLocation =
//               await _locationService.getAddressFromCoordinates();
//           debugPrint(
//               '${currentLocation?.latitude} ${currentLocation?.longitude} ${currentLocation?.region} ${currentLocation?.country}');
//           Navigator.of(context).pop({
//             'cityOrStay': AppLocalizations.of(context)!.current_location,
//             'coordinates': UserLocation(
//               latitude: currentLocation?.latitude,
//               longitude: currentLocation?.longitude,
//             ),
//             'city': currentLocation?.region,
//             'country': currentLocation?.country,
//             'locationType': 'current_location'
//           });
//         },
//       ),
//     );
//   }

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         tooltip: AppLocalizations.of(context)!.clear,
//         icon: (query != '') ? const Icon(UniconsLine.times) : Container(),
//         onPressed: () {
//           query = '';
//         },
//       )
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return CustomBackButton();
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     final theme = Theme.of(context);
//     return FutureBuilder<List<AlgoliaObjectSnapshot>>(
//         future: query == "" || query.length < 2
//             ? null
//             : AlgoliaSearchService().initiateStaySearch(query).timeout(
//                   const Duration(minutes: 1),
//                 ),
//         builder: (context, snapshot) {
//           _saveToRecentSearches(query);
//           if (query == '') {
//             return Container(
//               padding: const EdgeInsets.all(16.0),
//               alignment: Alignment.topCenter,
//               child: TextWithDivider(
//                 Utilities.capitalize(AppLocalizations.of(context)!.history),
//               ),
//             );
//           }
//           if (snapshot.hasData) {
//             return Container(
//               margin: EdgeInsets.only(top: Doubles.sm),
//               child: ListView.separated(
//                   separatorBuilder: (context, index) => const Divider(
//                         height: 1,
//                       ),
//                   itemCount:
//                       snapshot.data!.length < 10 ? snapshot.data!.length : 10,
//                   itemBuilder: (context, index) {
//                     final SearchLocation searchLocation =
//                         SearchLocation.fromMap(snapshot.data![index].data);
//                     return ListTile(
//                       tileColor: theme.colorScheme.surface,
//                       dense: true,
//                       isThreeLine: false,
//                       horizontalTitleGap: 0.0,
//                       leading: Icon(
//                         LocationIconGenerator.icon(
//                             searchLocation.type ?? 'location'),
//                         color: theme.iconTheme.color,
//                       ),
//                       title: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Text(
//                             searchLocation.name,
//                             style: theme.textTheme.bodyLarge!
//                                 .copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${searchLocation.region}, ${searchLocation.country}',
//                             style: theme.textTheme.bodyLarge,
//                           ),
//                         ],
//                       ),
//                       onTap: () async {
//                         close(context, {
//                           'cityOrStay': searchLocation.name,
//                           'city': searchLocation.region,
//                           'country': searchLocation.country,
//                           'coordinates': UserLocation(
//                             latitude: searchLocation.coordinates![0],
//                             longitude: searchLocation.coordinates![1],
//                           ),
//                           'locationType': searchLocation.type
//                         });
//                       },
//                     );
//                   }),
//             );
//           }
//           return const Center(
//             child: CircularProgressIndicator.adaptive(),
//           );
//           // query == ''
//           // ? Column(
//           //     children: [
//           //       Container(
//           //         alignment: Alignment.topCenter,
//           //         padding: const EdgeInsets.all(16.0),
//           //         child: Row(
//           //           mainAxisAlignment: MainAxisAlignment.center,
//           //           mainAxisSize: MainAxisSize.min,
//           //           children: <Widget>[
//           //             Expanded(
//           //               child: Divider(
//           //                 color: _color,
//           //                 thickness: 1.0,
//           //                 endIndent: Doubles.lg,
//           //               ),
//           //             ),
//           //             Text(
//           //               AppLocalizations.of(context)!.recent_searches'),
//           //               style: theme.textTheme.bodyText1!.apply(
//           //                 color: _color,
//           //               ),
//           //             ),
//           //             Expanded(
//           //               child: Divider(
//           //                 color: _color,
//           //                 thickness: 1.0,
//           //                 indent: Doubles.lg,
//           //               ),
//           //             ),
//           //           ],
//           //         ),
//           //       ),
//           //       Flexible(
//           //         child: FutureBuilder<List<String>?>(
//           //             future: _getRecentSearches(),
//           //             builder: (context, snapshot) {
//           //               return ListView.separated(
//           //                 itemBuilder: (context, index) => ListTile(
//           //                     title: Text(snapshot.data![index]),
//           //                     ),
//           //                 separatorBuilder: (context, index) => Divider(
//           //                   // indent: Doubles.xl,
//           //                 ),
//           //                 itemCount: snapshot.data!.length,
//           //               );
//           //             }),
//           //       )
//           //     ],
//           //   )
//           // :
//         });
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final theme = Theme.of(context);
//     return FutureBuilder<List<AlgoliaObjectSnapshot>>(
//         future: query == "" || query.length < 2
//             ? null
//             : AlgoliaSearchService().initiateStaySearch(query).timeout(
//                   const Duration(minutes: 1),
//                 ),
//         builder: (context, snapshot) {
//           _saveToRecentSearches(query);
//           if (query == '') {
//             return Container(
//               padding: const EdgeInsets.all(16.0),
//               alignment: Alignment.topCenter,
//               child: TextWithDivider(
//                 Utilities.capitalize(AppLocalizations.of(context)!.history),
//               ),
//             );
//           }
//           if (snapshot.hasData) {
//             return ListView.separated(
//                 separatorBuilder: (context, index) => const Divider(
//                       height: 1,
//                     ),
//                 itemCount:
//                     snapshot.data!.length < 10 ? snapshot.data!.length : 10,
//                 itemBuilder: (context, index) {
//                   final SearchLocation searchLocation =
//                       SearchLocation.fromMap(snapshot.data![index].data);
//                   return ListTile(
//                     tileColor: theme.colorScheme.surface,
//                     dense: true,
//                     isThreeLine: false,
//                     horizontalTitleGap: 0.0,
//                     leading: Icon(
//                       LocationIconGenerator.icon(
//                           searchLocation.type ?? 'location'),
//                       color: theme.iconTheme.color,
//                     ),
//                     title: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text(
//                           searchLocation.name,
//                           style: theme.textTheme.bodyLarge!
//                               .copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '${searchLocation.region}, ${searchLocation.country}',
//                           style: theme.textTheme.bodyLarge,
//                         ),
//                       ],
//                     ),
//                     onTap: () async {
//                       close(context, {
//                         'cityOrStay': searchLocation.name,
//                         'city': searchLocation.region,
//                         'country': searchLocation.country,
//                         'coordinates': UserLocation(
//                           latitude: searchLocation.coordinates![0],
//                           longitude: searchLocation.coordinates![1],
//                         ),
//                         'locationType': searchLocation.type
//                       });
//                     },
//                   );
//                 });
//           }
//           return const Center(
//             child: CircularProgressIndicator.adaptive(),
//           );
//           // query == ''
//           // ? Column(
//           //     children: [
//           //       Container(
//           //         alignment: Alignment.topCenter,
//           //         padding: const EdgeInsets.all(16.0),
//           //         child: Row(
//           //           mainAxisAlignment: MainAxisAlignment.center,
//           //           mainAxisSize: MainAxisSize.min,
//           //           children: <Widget>[
//           //             Expanded(
//           //               child: Divider(
//           //                 color: _color,
//           //                 thickness: 1.0,
//           //                 endIndent: Doubles.lg,
//           //               ),
//           //             ),
//           //             Text(
//           //               AppLocalizations.of(context)!.recent_searches'),
//           //               style: theme.textTheme.bodyText1!.apply(
//           //                 color: _color,
//           //               ),
//           //             ),
//           //             Expanded(
//           //               child: Divider(
//           //                 color: _color,
//           //                 thickness: 1.0,
//           //                 indent: Doubles.lg,
//           //               ),
//           //             ),
//           //           ],
//           //         ),
//           //       ),
//           //       Flexible(
//           //         child: FutureBuilder<List<String>?>(
//           //             future: _getRecentSearches(),
//           //             builder: (context, snapshot) {
//           //               return ListView.separated(
//           //                 itemBuilder: (context, index) => ListTile(
//           //                     title: Text(snapshot.data![index]),
//           //                     ),
//           //                 separatorBuilder: (context, index) => Divider(
//           //                   // indent: Doubles.xl,
//           //                 ),
//           //                 itemCount: snapshot.data!.length,
//           //               );
//           //             }),
//           //       )
//           //     ],
//           //   )
//           // :
//         });

//     // return FutureBuilder<List<SearchLocation>>(
//     // future: query == '' || query.length < 3
//     //     ? null
//     //     : apiClient.getLocationSuggestions(
//     //         input: query,
//     //         lang: Localizations.localeOf(context).languageCode),
//     // builder: (context, snapshot) => query == ''
//     //     ? Container(
//     //         padding: const EdgeInsets.all(16.0),
//     //         alignment: Alignment.topCenter,
//     //         child: const Text('History'),
//     //       )
//     //     : snapshot.hasData
//     //         ? ListView.separated(
//     //             separatorBuilder: (context, index) => const Divider(
//     //               height: 0,
//     //             ),
//     //             itemBuilder: (context, index) {
//     //               final SearchLocation searchLocation =
//     //                   (snapshot.data![index]);
//     //               return ListTile(
//     //                 dense: true,
//     //                 leading: Icon(
//     //                   LocationIconGenerator.icon(
//     //                       searchLocation.type ?? 'location'),
//     //                 ),
//     //                 title: Text(searchLocation.name),
//     //                 subtitle: Text(searchLocation.city!),
//     //                 onTap: () async {
//     //                   final placeCoordinates = await _locationService
//     //                       .getCoordinatesFromAddress(searchLocation.name);
//     //                   close(context, {
//     //                     'cityOrHotel': searchLocation.name,
//     //                     // 'city': searchLocation.region,
//     //                     'country': searchLocation.country,
//     //                     'coordinates': placeCoordinates,
//     //                     'locationType': searchLocation.type,
//     //                   });
//     //                 },
//     //               );
//     //             },
//     //             itemCount: snapshot.data!.length,
//     //           )
//     //         : const Center(child: CircularProgressIndicator.adaptive()));
//   }
// }