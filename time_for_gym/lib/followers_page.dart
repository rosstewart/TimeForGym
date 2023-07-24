import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/activity.dart';
import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/user.dart';

class FollowersPage extends StatefulWidget {
  final User? user;
  final bool fromBottomNavBar;
  FollowersPage(this.user, this.fromBottomNavBar);
  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<User> users = [];

  void _dismissKeyboard(MyAppState appState) {
    FocusScope.of(context).unfocus();
  }

  // late TabController _tabController;
  // int _currentTabIndex = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = DefaultTabController.of(context);
  //   _tabController.addListener(_handleTabChange);
  // }

  // @override
  // void dispose() {
  //   _tabController.removeListener(_handleTabChange);
  //   _tabController.dispose();
  //   super.dispose();
  // }

  // void _handleTabChange() {
  //   setState(() {
  //     _currentTabIndex = _tabController.index;
  //   });
  // }

  // void changeTab(int index) {
  //   _tabController.index = index;
  // }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // if (widget.fromBottomNavBar) {
    //   widget.user = appState.userProfileStackFromOwnProfile.isNotEmpty
    //       ? appState.userProfileStackFromOwnProfile.last
    //       : appState.currentUser;
    // } else {
    //   widget.user = appState.userProfileStack.isNotEmpty
    //       ? appState.userProfileStack.last
    //       : null;
    // }
    if (widget.user == null) {
      return Placeholder();
    }
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyTitleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    if (users.isEmpty) {
      getAllUserData(
          {...widget.user!.followers, ...widget.user!.following}.toList(),
          appState);
    }

    return GestureDetector(
      onTap: () {
        _dismissKeyboard(appState);
      },
      child: SwipeBack(
        appState: appState,
        swipe: true,
        index: widget.fromBottomNavBar
            ? (appState.userProfileStackFromOwnProfile.isEmpty ? 11 : 17)
            : 15,
        child: DefaultTabController(
          length: 2,
          initialIndex: (widget.fromBottomNavBar
                  ? appState.defaultProfilePageFollowersPage
                  : appState.defaultFriendsPageFollowersPage)
              ? 0
              : 1,
          child: Scaffold(
            appBar: AppBar(
              leading: Back(
                  appState: appState,
                  index: widget.fromBottomNavBar
                      ? (appState.userProfileStackFromOwnProfile.isEmpty
                          ? 11
                          : 17)
                      : 15),
              leadingWidth: 70,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: widget.user!.profilePicture,
                    child: widget.user!.profilePicture == null
                        ? Icon(Icons.person,
                            color: theme.colorScheme.onBackground)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.user!.username,
                    style: titleStyle,
                  ),
                  Spacer(flex: 2),
                ],
              ),
              bottom: TabBar(
                unselectedLabelColor: theme.colorScheme.onBackground,
                tabs: [
                  Tab(text: 'Followers'),
                  Tab(text: 'Following'),
                ],
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
            body:
                TabBarView(physics: NeverScrollableScrollPhysics(), children: [
              Column(
                children: [
                  if (widget.user!.followers.isEmpty) SizedBox(height: 20),
                  if (widget.user!.followers.isEmpty)
                    Text('No followers yet', style: greyTitleStyle),
                  if (widget.user!.followers.isNotEmpty) SizedBox(height: 5),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.user!.followers.length,
                      itemBuilder: (context, index) {
                        String username = widget.user!.followers[index];
                        User user = users.firstWhere(
                            (element) => element.username == username,
                            orElse: () =>
                                User(username: '', uid: '', email: ''));
                        return ListTile(
                            onTap: () async {
                              if (username == appState.currentUser.username) {
                                tryChangePageToOwnProfile(appState);
                                return;
                              }
                              User? newUser = await getUserDataFromFirestore(
                                  username, appState);
                              if (newUser != null) {
                                widget.fromBottomNavBar
                                    ? appState.userProfileStackFromOwnProfile
                                        .add(newUser)
                                    : appState.userProfileStack.add(newUser);
                                appState.changePage(
                                    widget.fromBottomNavBar ? 17 : 15);
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
                            ));
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  if (widget.user!.following.isEmpty) SizedBox(height: 20),
                  if (widget.user!.following.isEmpty)
                    Text('No following yet', style: greyTitleStyle),
                  if (widget.user!.following.isNotEmpty) SizedBox(height: 5),
                  if (widget.user!.following.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.user!.following.length,
                        itemBuilder: (context, index) {
                          String username = widget.user!.following[index];
                          User user = users.firstWhere(
                              (element) => element.username == username,
                              orElse: () =>
                                  User(username: '', uid: '', email: ''));
                          return ListTile(
                            onTap: () async {
                              if (username == appState.currentUser.username) {
                                tryChangePageToOwnProfile(appState);
                                return;
                              }
                              User? newUser = await getUserDataFromFirestore(
                                  username, appState);
                              if (newUser != null) {
                                widget.fromBottomNavBar
                                    ? appState.userProfileStackFromOwnProfile
                                        .add(newUser)
                                    : appState.userProfileStack.add(newUser);
                                appState.changePage(
                                    widget.fromBottomNavBar ? 17 : 15);
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
                          );
                        },
                      ),
                    ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void tryChangePageToOwnProfile(MyAppState appState) {
    if (appState.bottomNavigationIndex == 4) {
      print('Nothing happens');
    } else {
      if (appState.userProfileStackFromOwnProfile.isNotEmpty) {
        if (appState.savedBottomProfileIndex == 2) {
          appState.changePage(17);
        } else if (appState.savedBottomProfileIndex == 1) {
          appState.changePage(12);
        } else {
          print('ERROR - bottom page index');
          appState.changePage(11);
          appState.userProfileStackFromOwnProfile.clear();
        }
      } else {
        if (appState.savedBottomProfileIndex == 2) {
          print('ERROR - bottom page index');
          appState.changePage(11);
        } else if (appState.savedBottomProfileIndex == 1) {
          appState.changePage(12);
        } else {
          appState.changePage(11);
        }
      }
      appState.bottomNavigationIndex = 4;
    }
  }

  void getAllUserData(List<String> usernames, MyAppState appState) async {
    for (String commentUsername in usernames) {
      User? commentUser = await getUserData(commentUsername, appState);
      if (commentUser != null) {
        users.add(commentUser);
      }
    }
    setState(() {});
  }

  Future<User?> getUserData(String username, MyAppState appState) async {
    User? user;
    if (username == appState.currentUser.username) {
      user = appState.currentUser;
    } else {
      user = await getUserDataFromFirestore(username, appState);
    }
    return user;
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
