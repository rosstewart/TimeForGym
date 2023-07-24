import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/activity.dart';
// import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/main.dart';
// import 'package:time_for_gym/split.dart';
import 'package:time_for_gym/user.dart';

// ignore: must_be_immutable
class SearchFriendsPage extends StatefulWidget {
  @override
  _SearchFriendsPageState createState() => _SearchFriendsPageState();
}

class _SearchFriendsPageState extends State<SearchFriendsPage> {
  String pattern = '';

  final TextEditingController searchController = TextEditingController();
  // final ScrollController scrollController = ScrollController();
  final searchFocusNode = FocusNode();
  bool showSearchError = false;

  @override
  void dispose() {
    searchController.dispose();
    // scrollController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    List<String> filteredUsernames;
    if (pattern.isNotEmpty) {
      filteredUsernames = appState.allUsernames
          .where((element) =>
              element.toLowerCase().contains(pattern.toLowerCase()))
          .toList();
    } else {
      // Friends
      filteredUsernames = appState.currentUser.following.where((element) => appState.currentUser.followers.contains(element)).toList();
    }

    return SwipeBack(
      swipe: true,
      appState: appState,
      index: 13,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: theme.colorScheme.background,
            title: // Search bar
                Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: theme.colorScheme.primaryContainer),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                      child: TextField(
                        focusNode: searchFocusNode,
                        autofocus: true,
                        style: TextStyle(color: theme.colorScheme.onBackground),
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            // If value is empty, no search query
                            pattern = value;
                          });
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.search,
                              color: theme.colorScheme.primary,
                            ),
                            suffixIcon: searchFocusNode.hasFocus
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.65),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        pattern = '';
                                      });
                                      searchController
                                          .clear(); // Clear the text field
                                    },
                                  )
                                : null,
                            labelText: 'Search',
                            labelStyle: labelStyle.copyWith(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65)),
                            floatingLabelStyle: labelStyle.copyWith(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65))),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    appState.changePage(13);
                  },
                  child: Container(
                      decoration: BoxDecoration(),
                      child: Text('Cancel', style: labelStyle)),
                ),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  // controller: scrollController,
                  itemCount: filteredUsernames.length,
                  itemBuilder: (context, index) {
                    String username = filteredUsernames[index];
                    // Empty user will have blank profile picture
                    User user = appState.visitedUsers.firstWhere(
                      (element) => element.username == username,
                      orElse: () => User(username: '', email: '', uid: ''),
                    );
                    return ListTile(
                        onTap: () async {
                          User? newUser = await getUserDataFromFirestore(
                              username, appState);
                          if (newUser != null) {
                            setState(() {
                              showSearchError = false;
                            });
                            appState.userProfileStack.add(newUser);
                            appState.changePage(15);
                          } else {
                            setState(() {
                              showSearchError = true;
                            });
                          }
                        },
                        leading: CircleAvatar(
                            radius: 12,
                            backgroundImage: user.profilePicture,
                            child: user.profilePicture == null
                                ? Icon(Icons.person,
                                    color: theme.colorScheme.onBackground,
                                    size: 14)
                                : null),
                        title: Text(
                          username,
                          style: labelStyle,
                          maxLines: 2,
                        ),
                        subtitle: showSearchError
                            ? Text('Something went wrong, please try again',
                                style: labelStyle.copyWith(
                                    color: theme.colorScheme.secondary))
                            : null);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<User?> getUserDataFromFirestore(
      String username, MyAppState appState) async {
    try {
      User visitedUser = appState.visitedUsers.firstWhere(
          (element) => element.username == username,
          orElse: () => User(username: '', email: '', uid: ''));
      if (visitedUser.username.isNotEmpty) {
        return visitedUser;
      }

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(username);
      DocumentSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        User newUser = User(
            username: username,
            email: userData['email'] ?? '',
            uid: userData['uid'] ?? '',
            userGymId: userData['userGymId'] ?? '',
            favoritesString: userData['favoritesString'] ?? '',
            profileName: userData['profileName'] ?? '',
            profileDescription: userData['profileDescription'] ?? '');
        newUser.profilePictureUrl =
            userData['profilePictureUrl']; // Could be null
        newUser.followers = (userData['followers'] ?? []).cast<String>();
        newUser.following = (userData['following'] ?? []).cast<String>();
        List<dynamic> activityListJson = userData['activities'] ?? [];
        newUser.activities = activityListJson
            .map((e) => Activity.fromJson(json.decode(e)))
            .toList();
        newUser.splitJson = userData['split']; // Could be null
        newUser.initializeProfilePicData();
        appState.visitedUsers.add(newUser);
        return newUser;
      } else {
        print('User $username not found');
        return null;
      }
    } catch (e) {
      print('ERROR - User $username not found: $e');
      return null;
    }
  }
}
