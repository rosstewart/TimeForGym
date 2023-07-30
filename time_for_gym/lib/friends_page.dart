import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/activity.dart';
import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/profile_page.dart';
import 'package:time_for_gym/user.dart';

class FriendsPage extends StatefulWidget {
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<User> friends = [];
  List<User> friendsThatBothFollow = [];
  final List<ActivityWithAuthorIndex> allActivities = [];
  bool isLoadingFriends = true;

  @override
  Widget build(BuildContext context) {
    final MyAppState appState = context.watch<MyAppState>();

    final theme = Theme.of(context);
    // final titleStyle = theme.textTheme.titleMedium!
    //     .copyWith(color: theme.colorScheme.onBackground);
    final greyTitleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    if (friends.isEmpty && isLoadingFriends) {
      loadFriends(appState);
    } else if (appState.reloadFriendsPage == true) {
      reloadFriends(appState);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.background,
          toolbarHeight: 40,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: theme.colorScheme.onBackground),
                    child: ListTile(
                      leading: Icon(
                        Icons.search,
                        color: theme.colorScheme.background,
                      ),
                      title: Text(
                        'Find friends',
                        style: TextStyle(
                            color: theme.colorScheme.background, fontSize: 16),
                      ),
                      onTap: () {
                        appState.changePage(14);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            if (friends.length <= 1 && !isLoadingFriends)
              Center(child: Text('No friends yet', style: greyTitleStyle)),
            if (friends.length <= 1 && !isLoadingFriends) SizedBox(height: 20),
            if (isLoadingFriends && friends.length > 1)
              Center(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator())),
            if (!isLoadingFriends && friends.length > 1)
              Expanded(
                  child: ListView.builder(
                itemCount: allActivities.length,
                itemBuilder: (context, index) {
                  final activityWithAuthorIndex = allActivities[index];
                  final author = activityWithAuthorIndex.author;
                  final activity = activityWithAuthorIndex.activity;
                  final activityIndex = activityWithAuthorIndex.activityIndex;
                  if (index == 0) {
                    return Column(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 10),
                              for (User friend in friendsThatBothFollow)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (appState.pageIndex == 13) {
                                        // print('View ${widget.author}\'s profile');
                                        if (friend.username !=
                                            appState.currentUser.username) {
                                          appState.userProfileStack.add(friend);
                                          appState.changePage(15);
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                              radius: 30,
                                              backgroundImage:
                                                  friend.profilePicture,
                                              child:
                                                  friend.profilePicture == null
                                                      ? Icon(Icons.person,
                                                          color: theme
                                                              .colorScheme
                                                              .onBackground,
                                                          size: 32)
                                                      : null),
                                          SizedBox(height: 5),
                                          Text(
                                            friend.username,
                                            style: labelStyle,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ActivityPreviewCard(author, activity, activityIndex,
                          setState, allActivities)
                    ]);
                  }
                  return ActivityPreviewCard(
                      author, activity, activityIndex, setState, allActivities);
                },
              )),
          ],
        ),
      ),
    );
  }

  void loadFriends(final MyAppState appState) async {
    if (friends.isNotEmpty) {
      return;
    }
    List<String> friendUsernames = appState.currentUser.following
        // .where((element) => appState.currentUser.followers.contains(element))
        .toList();
    friendUsernames.add(appState.currentUser.username);
    for (int i = 0; i < friendUsernames.length; i++) {
      User? newUser;
      if (friendUsernames[i] != appState.currentUser.username) {
        newUser = await getUserDataFromFirestore(friendUsernames[i], appState);
      } else {
        newUser = appState.currentUser;
      }
      if (newUser != null) {
        friends.add(newUser);
        if (appState.currentUser.followers.contains(newUser.username)) {
          // Follow goes both ways
          friendsThatBothFollow.add(newUser);
        }
        for (int activityIndex = 0;
            activityIndex < newUser.activities.length;
            activityIndex++) {
          final activity = newUser.activities[activityIndex];
          if (activity.private != true) {
            allActivities.add(ActivityWithAuthorIndex(
                author: newUser,
                activity: activity,
                activityIndex: activityIndex));
          }
        }
      }
    }
    allActivities.sort((a, b) => b.activity.millisecondsFromEpoch
        .compareTo(a.activity.millisecondsFromEpoch));

    setState(() {
      isLoadingFriends = false;
    });
  }

  void reloadFriends(MyAppState appState) {
    appState.reloadFriendsPage = false;
    setState(() {
      isLoadingFriends = true;
    });
    friends.clear();
    friendsThatBothFollow.clear();
    allActivities.clear();
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

class ActivityWithAuthorIndex {
  final User author;
  final Activity activity;
  final int activityIndex;

  ActivityWithAuthorIndex({
    required this.author,
    required this.activity,
    required this.activityIndex,
  });
}
