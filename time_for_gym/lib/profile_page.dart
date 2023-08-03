import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/activity.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/friends_page.dart';
import 'package:time_for_gym/gym_page.dart';
import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/split.dart';
import 'package:time_for_gym/user.dart';

// class MaySwipeBack extends StatelessWidget {
//   final bool fromBottomNavBar;
//   final MyAppState appState;
//   final Widget child;
//   MaySwipeBack(this.fromBottomNavBar, this.appState, this.child);
//   @override
//   Widget build(BuildContext context) {
//     int? index = fromBottomNavBar
//         ? (appState.userProfileStackFromOwnProfile.isNotEmpty ? 12 : null)
//         : (appState.userProfileStack.length <= 1 ? 14 : 16);
//     return SwipeBack(
//         swipe: index != null,
//         appState: appState,
//         index: index ?? 0,
//         child: child);
//   }
// }

class OtherUserProfilePage extends StatefulWidget {
  final User? user;
  final bool fromBottomNavBar;
  OtherUserProfilePage(this.user, this.fromBottomNavBar);
  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ProfilePage(widget.user, widget.fromBottomNavBar, false, null);
  }
}

class ProfilePage extends StatefulWidget {
  final User? user;
  final bool fromBottomNavBar;
  final bool isOwnUser;
  final StateSetter? setAuthenticationState;
  ProfilePage(this.user, this.fromBottomNavBar, this.isOwnUser,
      this.setAuthenticationState);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ImageProvider<Object>? profilePictureProvider;
  // List to modify through different scopes
  final List<bool> isProfilePicLoading = [false];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      profilePictureProvider = widget.user!.profilePicture;
      if (profilePictureProvider == null &&
          widget.user!.profilePictureUrl != null) {
        // Retrieve from storage
        widget.user!.profilePicture =
            NetworkImage(widget.user!.profilePictureUrl!);
        profilePictureProvider = widget.user!.profilePicture;
      }
      // profilePictureProvider will remain null if no previous profile picture data
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Placeholder();
    }
    if (profilePictureProvider != widget.user!.profilePicture) {
      if (widget.user!.profilePictureUrl != null) {
        // Retrieve from storage
        widget.user!.profilePicture =
            NetworkImage(widget.user!.profilePictureUrl!);
        profilePictureProvider = widget.user!.profilePicture;
      } else {
        profilePictureProvider = null;
      }
    }
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    bool doTitleFlex = widget.fromBottomNavBar
        ? (appState.userProfileStackFromOwnProfile.isNotEmpty ? true : false)
        : (appState.userProfileStack.length <= 1 ? true : true);
    int titleFlexTopLeft = doTitleFlex ? 4 : 3;
    int titleFlexTopRight = doTitleFlex ? 7 : 2;
    // int titleFlexBottom = doTitleFlex ? 5 : 1;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      // child: SwipeBack(
      // swipe: appState.userProfileStackFromOwnProfile.isNotEmpty,
      // swipe: widget.fromBottomNavBar
      //     ? (appState.userProfileStackFromOwnProfile.isNotEmpty
      //         ? true
      //         : false)
      //     : (appState.userProfileStack.length <= 1 ? true : true),
      // appState: appState,
      // index: widget.fromBottomNavBar
      //     ? (appState.userProfileStackFromOwnProfile.isNotEmpty ? 12 : 0)
      //     : (appState.userProfileStack.length <= 1 ? 14 : 16),
      // index: appState.userProfileStackFromOwnProfile.isNotEmpty ? 12 : 0,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight-17,
            leading: widget.fromBottomNavBar
                ? (appState.userProfileStackFromOwnProfile.isNotEmpty
                    ? Back(appState: appState, index: 12)
                    : null)
                : (appState.userProfileStack.length <= 1
                    ? (appState.lastFriendsOrFriendsSearch
                        ? Back(appState: appState, index: 13)
                        : Back(appState: appState, index: 14))
                    : Back(appState: appState, index: 16)),
            leadingWidth: 70,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: titleFlexTopLeft),
                Text(widget.user!.username, style: titleStyle),
                Spacer(flex: titleFlexTopRight),
                if (widget.setAuthenticationState != null &&
                    appState.currentUser == widget.user)
                  GestureDetector(
                    onTapDown: (tapDownDetails) {
                      showInfoDropdown(context, tapDownDetails.globalPosition);
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onBackground.withOpacity(.65),
                    ),
                  ),
                if (widget.setAuthenticationState != null &&
                    appState.currentUser == widget.user)
                  SizedBox(width: 10),
                if (widget.setAuthenticationState != null &&
                    appState.currentUser == widget.user)
                  GestureDetector(
                    onTapDown: (tapDownDetails) {
                      showOptionsDropdown(
                          context, tapDownDetails.globalPosition, appState);
                    },
                    child: Icon(
                      Icons.more_horiz,
                      color: theme.colorScheme.onBackground.withOpacity(.65),
                    ),
                  ),
              ],
            ),
            // if (widget.user!.userGymId.isNotEmpty)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Spacer(),
            //       Text('Goes to ', style: greyLabelStyle),
            //       GestureDetector(
            //         onTap: () {
            //           appState.currentGym =
            //               appState.gyms[widget.user!.userGymId]!;
            //           appState.changePage(9);
            //           // GymPage(gym: appState.currentGym, isSelectedGym: appState.userGym == appState.gyms[widget.user!.userGymId]!);
            //         },
            //         child: Container(
            //           decoration: BoxDecoration(),
            //           child: Text(
            //               appState.gyms[widget.user!.userGymId]!.name,
            //               style: labelStyle.copyWith(
            //                   color: theme.colorScheme.primary)),
            //         ),
            //       ),
            //       Spacer(flex: titleFlexBottom),
            //     ],
            //   ),
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 30),
                  Column(
                    children: [
                      GestureDetector(
                        onTapDown: (tapDownDetails) {
                          showGalleryOrCameraMenu(
                              context, tapDownDetails.globalPosition);
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundImage: profilePictureProvider,
                              child: isProfilePicLoading[0]
                                  ? CircularProgressIndicator(
                                      color: theme.colorScheme.onBackground,
                                    )
                                  : (profilePictureProvider == null
                                      ? Icon(
                                          Icons.person,
                                          color: theme.colorScheme.onBackground,
                                          size: 40,
                                        )
                                      : null),
                            ),
                            // if (user.profilePicture != null)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Icon(Icons.add,
                                    color: theme.colorScheme.onBackground,
                                    size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        widget.fromBottomNavBar
                            ? appState.defaultProfilePageFollowersPage = true
                            : appState.defaultFriendsPageFollowersPage = true;
                        appState.changePage(widget.fromBottomNavBar ? 12 : 16);
                      },
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          children: [
                            Text('${widget.user!.followers.length}',
                                style: titleStyle),
                            Text('Followers',
                                style: titleStyle.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(.65)))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        widget.fromBottomNavBar
                            ? appState.defaultProfilePageFollowersPage = false
                            : appState.defaultFriendsPageFollowersPage = false;
                        appState.changePage(widget.fromBottomNavBar ? 12 : 16);
                      },
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          children: [
                            Text('${widget.user!.following.length}',
                                style: titleStyle),
                            Text('Following',
                                style: titleStyle.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(.65)))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                ],
              ),
              if (widget.user!.profileName.isNotEmpty) SizedBox(height: 5),
              if (widget.user!.profileName.isNotEmpty)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Text(widget.user!.profileName,
                      maxLines: 1, style: bodyStyle),
                ),
              if (widget.user!.userGymId.isNotEmpty)
                SizedBox(height: widget.user!.profileName.isEmpty ? 10 : 5),
              if (widget.user!.userGymId.isNotEmpty)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Row(
                    children: [
                      Text('Goes to ',
                          style: greyLabelStyle.copyWith(fontSize: 10)),
                      GestureDetector(
                        onTap: () {
                          appState.currentGym =
                              appState.gyms[widget.user!.userGymId]!;
                          appState.changePage(9);
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text(
                              appState.gyms[widget.user!.userGymId]!.name,
                              style: labelStyle.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.user!.profileDescription.isNotEmpty)
                SizedBox(height: 5),
              if (widget.user!.profileDescription.isNotEmpty)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Text(widget.user!.profileDescription,
                      maxLines: 3,
                      style: labelStyle.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(.9))),
                ),
              SizedBox(height: 10),
              if (appState.currentUser == widget.user)
                Center(
                    child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: resolveColor(
                                theme.colorScheme.primaryContainer),
                            surfaceTintColor: resolveColor(
                                theme.colorScheme.primaryContainer)),
                        onPressed: () {
                          _showEditProfile(
                              context,
                              appState,
                              widget.user!.profileName,
                              widget.user!.profileDescription,
                              widget.user!,
                              setState);
                        },
                        child: Text(
                          'Edit Profile',
                          style: labelStyle,
                        ))),
              if (appState.currentUser != widget.user)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!appState.currentUser.following
                        .contains(widget.user!.username))
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                resolveColor(theme.colorScheme.primary),
                            surfaceTintColor:
                                resolveColor(theme.colorScheme.primary)),
                        onPressed: () async {
                          bool success = await appState.currentUser
                              .followUser(widget.user!.username, widget.user!);
                          if (success) {
                            setState(() {});
                          }
                        },
                        child: Text(
                          'Follow',
                          style: labelStyle,
                        ),
                      ),
                    if (appState.currentUser.following
                        .contains(widget.user!.username))
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: resolveColor(
                                theme.colorScheme.primaryContainer),
                            surfaceTintColor: resolveColor(
                                theme.colorScheme.primaryContainer)),
                        onPressed: () async {
                          bool success = await appState.currentUser
                              .unfollowUser(
                                  widget.user!.username, widget.user!);
                          if (success) {
                            setState(() {
                              widget.user!.followers;
                            });
                          }
                        },
                        child: Text(
                          'Unfollow',
                          style: labelStyle,
                        ),
                      ),
                    // Friends
                    // if (appState.currentUser.following
                    //         .contains(widget.user!.username) &&
                    //     appState.currentUser.followers
                    //         .contains(widget.user!.username))
                    //   SizedBox(width: 20),
                    // if (appState.currentUser.following
                    //         .contains(widget.user!.username) &&
                    //     appState.currentUser.followers
                    //         .contains(widget.user!.username))
                    //   ElevatedButton.icon(
                    //     style: ButtonStyle(
                    //         backgroundColor: resolveColor(
                    //             theme.colorScheme.primaryContainer),
                    //         surfaceTintColor: resolveColor(
                    //             theme.colorScheme.primaryContainer)),
                    //     onPressed: () async {
                    //       print('Nudge ${widget.user!.username}');
                    //     },
                    //     icon: Icon(Icons.fitness_center, size: 20),
                    //     label: Text(
                    //       'Nudge',
                    //       style: labelStyle,
                    //     ),
                    //   ),
                  ],
                ),
              SizedBox(height: 3),
              TabBar(
                unselectedLabelColor: theme.colorScheme.onBackground,
                tabs: [
                  Tab(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Icon(Icons.history, size: 16),
                        SizedBox(width: 10),
                        Text('Activities', style: labelStyle)
                      ])),
                  // Only if not current user's profile
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 16),
                        SizedBox(width: 10),
                        Text('Split', style: labelStyle)
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 12),
                        SizedBox(width: 7),
                        Text('Favorites', style: labelStyle)
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        if (appState.currentUser == widget.user)
                          SizedBox(height: 20),
                        if (appState.currentUser == widget.user)
                          ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      resolveColor(theme.colorScheme.primary),
                                  surfaceTintColor:
                                      resolveColor(theme.colorScheme.primary)),
                              onPressed: () {
                                _showAddManualActivity(
                                    context, appState, widget.user!, setState);
                              },
                              icon: Icon(Icons.add,
                                  color: theme.colorScheme.onBackground,
                                  size: 16),
                              label: Text(
                                'Manual Activity',
                                style: labelStyle,
                              )),
                        SizedBox(height: 20),
                        if (appState.currentUser == widget.user ||
                            (!widget.user!.onlyFriendsCanViewPosts ||
                                (appState.currentUser.following
                                        .contains(widget.user!.username) &&
                                    widget.user!.following.contains(
                                        appState.currentUser.username))))
                          for (int i = 0;
                              i < widget.user!.activities.length;
                              i++)
                            ActivityPreviewCard(widget.user!,
                                widget.user!.activities[i], i, setState, null)
                        else
                          Text(
                              'Only ${widget.user!.username}\'s friends can view their posts\n(Make sure you both follow each other)',
                              style: greyLabelStyle,
                              textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                  SplitPreview(widget.user!.splitJson != null
                      ? Split.fromJson(json.decode(widget.user!.splitJson!))
                      : null),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: ListView.builder(
                      itemCount: widget.user!.favoritesString.split(',').length,
                      itemBuilder: (context, index) {
                        if (widget.user!.favoritesString.isEmpty) {
                          return ListTile(
                            title: Text('No favorite exercises',
                                style: greyLabelStyle,
                                textAlign: TextAlign.center),
                          );
                        }
                        final List<String> temps =
                            widget.user!.favoritesString.split(',');
                        List<String> temp2 = temps[index].split('=');
                        Exercise exercise = appState.muscleGroups[temp2[1]]!
                            .firstWhere((element) => element.name == temp2[0]);
                        return ListTile(
                            onTap: () {
                              appState.fromProfilePage = true;
                              appState.changePageToExercise(exercise);
                            },
                            leading: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: theme.colorScheme.onBackground),
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: ImageContainer(exercise: exercise),
                              ),
                            ),
                            title: Row(children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  exercise.name,
                                  style: labelStyle,
                                  maxLines: 2,
                                ),
                              ),
                            ]),
                            subtitle: Row(
                              children: [
                                Text(
                                  '${exercise.mainMuscleGroup} ',
                                  style: labelStyle.copyWith(
                                      color: theme.colorScheme.primary),
                                ),
                                if (exercise.mainMuscleGroup !=
                                    exercise.musclesWorked[0])
                                  Text(
                                    '(${exercise.musclesWorked[0]})',
                                    style: labelStyle.copyWith(
                                        color: theme.colorScheme.onBackground
                                            .withOpacity(.65)),
                                  ),
                              ],
                            ));
                      },
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
      // ),
    );
  }

  void showOptionsDropdown(
      BuildContext context, Offset tapPosition, MyAppState appState) {
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
          if (appState.activeWorkout != null) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(appState.authUsername)
                .update({
              'activeWorkout': json.encode(appState.activeWorkout!.toJson())
            });
          }
          widget.setAuthenticationState!(() {
            isAuthenticated = false;
            // appState.currentUser = null;
            appState.currentSplit = null;
            appState.makeNewSplit = true;
            appState.editModeTempSplit = null;
            appState.editModeTempExerciseIndices = null;
            appState.splitDayExerciseIndices = [[], [], [], [], [], [], []];
            appState.goStraightToSplitDayPage = false;
            appState.hasSubmittedData = false;
            appState.isInitializing = true;
            appState.isHomePageSearchFieldFocused = false;
            appState.lastVisitedSearchPage = 8;
            appState.userGym = null;
            appState.showAdBeforeExerciseCounter = 2;
            appState.presetHomePage = 0;
            appState.presetSearchPage = 0;
            appState.muscleGroups = {};
            appState.favoriteExercises = [];
            appState.pageIndex = 13;
            appState.gymCount = -1;
            appState.maxCapacity = 200;
            appState.areMuscleGroupsInitialized = false;
            appState.isGymCountInitialized = false;
            appState.userProfileStack = [];
            appState.userProfileStackFromOwnProfile = [];
            appState.activeWorkout = null;
            appState.activeWorkoutBannerPageController = PageController();
            appState.areMuscleGroupImagesInitialized = {};
            appState.prefs.clear();
            appState.visitedUsers = [];
            // appState.musclesWorkedImages = {};
          });
        }

        auth.FirebaseAuth.instance.signOut();
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
    );
  }

  void showGalleryOrCameraMenu(BuildContext context, Offset tapPosition) {
    final theme = Theme.of(context);
    final labelStyle =
        TextStyle(color: theme.colorScheme.onBackground, fontSize: 10);
    // final RenderBox button = context.findRenderObject() as RenderBox;
    // final RenderBox overlay =
    //     Overlay.of(context).context.findRenderObject() as RenderBox;

    // final RelativeRect position = RelativeRect.fromRect(
    //   Rect.fromPoints(
    //     button.localToGlobal(button.size.bottomLeft(Offset.zero),
    //         ancestor: overlay),
    //     button.localToGlobal(button.size.bottomRight(Offset.zero),
    //         ancestor: overlay),
    //   ),
    //   Offset.zero & overlay.size,
    // );

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
          value: 'Choose from camera roll',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.photo_library,
                color: theme.colorScheme.primary, size: 14),
            title: Text('Choose from Camera roll', style: labelStyle),
          ),
        ),
        PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          value: 'Take a picture',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.camera_alt,
                color: theme.colorScheme.primary, size: 14),
            title: Text('Take a picture', style: labelStyle),
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'Choose from camera roll') {
        await setProfilePicture(true);
      } else if (value == 'Take a picture') {
        await setProfilePicture(false);
      }
    });
  }

  Future<void> setProfilePicture(bool fromGallery) async {
    ImageProvider<Object>? imageProvider = await widget.user!
        .setProfilePicture(fromGallery, setState, isProfilePicLoading);
    if (imageProvider != null) {
      setState(() {
        profilePictureProvider = imageProvider;
      });
    }
    setState(() {
      isProfilePicLoading[0] = false;
    });
  }
}

class SplitPreview extends StatefulWidget {
  final Split? split;
  SplitPreview(this.split);
  @override
  State<SplitPreview> createState() => _SplitPreviewState();
}

class _SplitPreviewState extends State<SplitPreview> {
  final PageController _pageController = PageController();
  int _dotIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    if (widget.split == null) {
      return Column(children: [
        SizedBox(height: 20),
        Text(
          'No split saved',
          style: titleStyle.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(.65)),
        )
      ]);
    } else {
      return Column(children: [
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15)),
          height: 300,
          child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _dotIndex = index;
                });
              },
              children: List.generate(widget.split!.trainingDays.length,
                  (index) => SplitPreviewCard(widget.split!, index))),
        ),
        SizedBox(height: 10),
        DotsIndicator(
          onTap: (position) {
            setState(() {
              _pageController.animateToPage(position,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            });
          },
          key: Key('0'),
          dotsCount: widget.split!.trainingDays.length,
          position: _dotIndex,
          decorator: DotsDecorator(
            activeColor: theme.colorScheme.primary,
            size: const Size.square(8.0),
            activeSize: const Size.square(8.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ]);
    }
  }
}

class SplitPreviewCard extends StatelessWidget {
  final Split split;
  final int dayIndex;
  final List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  SplitPreviewCard(this.split, this.dayIndex);
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.8));
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${weekdayNames[dayIndex]} - ',
                style: titleStyle,
              ),
              Text(split.trainingDays[dayIndex].splitDay,
                  style: titleStyle.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(.65)))
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: split.trainingDays[dayIndex].muscleGroups.length,
              itemBuilder: (context, index) {
                TrainingDay trainingDay = split.trainingDays[dayIndex];
                List<Exercise> exercisesTestList = appState
                    .muscleGroups[trainingDay.muscleGroups[index]]!
                    .where((element) =>
                        trainingDay.exerciseNames[index] == element.name)
                    .toList();
                if (exercisesTestList.length != 1) {
                  return null;
                }
                Exercise exercise = exercisesTestList[0];
                return Column(
                  children: [
                    if (trainingDay.isSupersettedWithLast[index])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.swap_vert,
                            color:
                                theme.colorScheme.onBackground.withOpacity(.8),
                            size: 16,
                          ),
                          Text(' Superset ', style: labelStyle),
                          Icon(
                            Icons.swap_vert,
                            color:
                                theme.colorScheme.onBackground.withOpacity(.8),
                            size: 16,
                          ),
                        ],
                      ),
                    ListTile(
                      onTap: () {
                        toExercise(appState, exercise);
                      },
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.onBackground),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ImageContainer(exercise: exercise),
                        ),
                      ),
                      title: Row(children: [
                        SizedBox(
                            width: 200,
                            child: Text(exercise.name,
                                style: labelStyle, maxLines: 2)),
                      ]),
                      subtitle: Row(
                        children: [
                          Text(
                            '${exercise.mainMuscleGroup} ',
                            style: labelStyle.copyWith(
                                color: theme.colorScheme.primary),
                          ),
                          if (exercise.mainMuscleGroup !=
                              exercise.musclesWorked[0])
                            Text(
                              '(${exercise.musclesWorked[0]})',
                              style: labelStyle.copyWith(
                                  color: theme.colorScheme.onBackground
                                      .withOpacity(.65)),
                            ),
                        ],
                      ),
                      trailing: Text(
                        '${trainingDay.setsPerMuscleGroup[index]} sets',
                        style: greyLabelStyle,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void toExercise(MyAppState appState, Exercise exercise) {
    appState.fromProfilePage = true;
    // appState.currentExerciseFromProfilePage = exercise;
    appState.changePageToExercise(exercise);
  }
}

void _showEditProfile(
    BuildContext context,
    MyAppState appState,
    String previousName,
    String previousDescription,
    User user,
    StateSetter setProfilePageState) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return EditProfileWindow(appState, previousName, previousDescription,
          user, setProfilePageState);
    },
  );
}

class EditProfileWindow extends StatefulWidget {
  final MyAppState appState;
  final String previousName;
  final String previousDescription;
  final User user;
  final StateSetter setProfilePageState;

  EditProfileWindow(this.appState, this.previousName, this.previousDescription,
      this.user, this.setProfilePageState);

  @override
  _EditProfileWindowState createState() => _EditProfileWindowState();
}

class _EditProfileWindowState extends State<EditProfileWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool onlyFriendsCanViewPosts = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _nameController = TextEditingController(text: widget.previousName);
    _descriptionController =
        TextEditingController(text: widget.previousDescription);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground)),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(width: 92, child: Text('Name', style: bodyStyle)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: TextField(
                            style: TextStyle(
                                color: theme.colorScheme.onBackground),
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.65),
                                    size: 20),
                                onPressed: () {
                                  _nameController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(
                        width: 92,
                        child: Text('Description', style: bodyStyle)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: TextField(
                            maxLines: 2,
                            style: TextStyle(
                                color: theme.colorScheme.onBackground,
                                fontSize: 12),
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.65),
                                    size: 20),
                                onPressed: () {
                                  _descriptionController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                    child: Text(
                  'Who can view your activities?',
                  style:
                      bodyStyle.copyWith(color: theme.colorScheme.onBackground),
                )),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (onlyFriendsCanViewPosts) {
                            setState(() {
                              onlyFriendsCanViewPosts = false;
                            });
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: resolveColor(
                                theme.colorScheme.primaryContainer),
                            surfaceTintColor: resolveColor(
                                theme.colorScheme.primaryContainer)),
                        icon: Icon(
                            !onlyFriendsCanViewPosts
                                ? Icons.people
                                : Icons.people_outline,
                            size: !onlyFriendsCanViewPosts ? null : 18,
                            color: !onlyFriendsCanViewPosts
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onBackground
                                    .withOpacity(.65)),
                        label: Text('Your followers',
                            style: !onlyFriendsCanViewPosts
                                ? bodyStyle.copyWith(
                                    color: theme.colorScheme.onBackground)
                                : greyLabelStyle),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (!onlyFriendsCanViewPosts) {
                                setState(() {
                                  onlyFriendsCanViewPosts = true;
                                });
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor: resolveColor(
                                    theme.colorScheme.primaryContainer),
                                surfaceTintColor: resolveColor(
                                    theme.colorScheme.primaryContainer)),
                            icon: Icon(
                                onlyFriendsCanViewPosts
                                    ? Icons.emoji_people
                                    : Icons.emoji_people_outlined,
                                size: onlyFriendsCanViewPosts ? null : 18,
                                color: onlyFriendsCanViewPosts
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onBackground
                                        .withOpacity(.65)),
                            label: Text(
                              'Your friends',
                              style: onlyFriendsCanViewPosts
                                  ? bodyStyle.copyWith(
                                      color: theme.colorScheme.onBackground)
                                  : greyLabelStyle,
                            ),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '(Mutual Followers)',
                          style: greyLabelStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.length > 30) {
                        setState(() {
                          errorText = 'Name is over 30 characters';
                        });
                        return;
                      }
                      print(_descriptionController.text.length);
                      if (_descriptionController.text.length > 155) {
                        setState(() {
                          errorText = 'Description is over 155 characters';
                        });
                        return;
                      }
                      widget.setProfilePageState(() {
                        widget.user.profileName = _nameController.text;
                        widget.user.profileDescription =
                            _descriptionController.text;
                        widget.user.onlyFriendsCanViewPosts =
                            onlyFriendsCanViewPosts;
                      });
                      appState.storeDataInFirestore();
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            resolveColor(theme.colorScheme.primary),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primary)),
                    child: Text('Done', style: labelStyle),
                  ),
                ),
                if (errorText != null) SizedBox(height: 5),
                if (errorText != null)
                  Center(
                    child: Text(errorText!,
                        style: labelStyle.copyWith(
                            color: theme.colorScheme.secondary)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showAddManualActivity(BuildContext context, MyAppState appState,
    User user, StateSetter setProfilePageState) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ManualActivityWindow(appState, user, setProfilePageState);
    },
  );
}

class ManualActivityWindow extends StatefulWidget {
  final MyAppState appState;
  final User user;
  final StateSetter setProfilePageState;

  ManualActivityWindow(this.appState, this.user, this.setProfilePageState);

  @override
  _ManualActivityWindowState createState() => _ManualActivityWindowState();
}

class _ManualActivityWindowState extends State<ManualActivityWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late TextEditingController _liftTitleController;
  TextEditingController _liftDescriptionController = TextEditingController();
  TextEditingController _liftHoursController = TextEditingController();
  TextEditingController _liftMinutesController = TextEditingController();

  String? errorText;
  String? imageErrorText;
  final ImagePicker _picker = ImagePicker();
  int millisecondsFromEpoch = DateTime.now().millisecondsSinceEpoch;
  String? pickedFilePath;
  String? activityPictureUrl;
  Widget? activityPicture;
  late String yourFollowersOrFriends;
  late List<String> postOptions; // = ['Your followers', 'Only you'];
  late String selectedPostOption; // = 'Your followers';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    int hour = DateTime.fromMillisecondsSinceEpoch(millisecondsFromEpoch).hour;
    _liftTitleController = TextEditingController(
        text: (hour < 4 || hour >= 23)
            ? 'Midnight workout'
            : (hour < 12
                ? 'Morning workout'
                : (hour < 18
                    ? 'Afternoon workout'
                    : (hour < 21 ? 'Evening workout' : 'Night workout'))));

    yourFollowersOrFriends =
        widget.user.onlyFriendsCanViewPosts ? 'Your friends' : 'Your followers';
    postOptions = [yourFollowersOrFriends, 'Only you'];
    selectedPostOption = yourFollowersOrFriends;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground)),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text('Add Manual Activity',
                      style: theme.textTheme.titleSmall!
                          .copyWith(color: theme.colorScheme.onBackground)),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(width: 92, child: Text('Title', style: bodyStyle)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: TextField(
                            style: TextStyle(
                                color: theme.colorScheme.onBackground),
                            controller: _liftTitleController,
                            decoration: InputDecoration(
                              // labelText: 'What did you do for your workout?',
                              // labelStyle: greyLabelStyle,
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.65),
                                    size: 20),
                                onPressed: () {
                                  _liftTitleController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(
                        width: 92,
                        child: Text('Description', style: bodyStyle)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: TextField(
                            maxLines: 2,
                            style: TextStyle(
                                color: theme.colorScheme.onBackground,
                                fontSize: 12),
                            controller: _liftDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'What did you do? How did it go?',
                              labelStyle: greyLabelStyle,
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.65),
                                    size: 20),
                                onPressed: () {
                                  _liftDescriptionController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(
                        width: 92, child: Text('Duration', style: bodyStyle)),
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: theme.colorScheme.primaryContainer),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: TextField(
                                  maxLength: 2,
                                  style: TextStyle(
                                      color: theme.colorScheme.onBackground,
                                      fontSize: 12),
                                  controller: _liftHoursController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                      labelText: '00',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      labelStyle: greyLabelStyle.copyWith(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.4))),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text('Hours',
                                style: greyLabelStyle.copyWith(fontSize: 9)),
                          ],
                        ),
                        Column(
                          children: [
                            Text(' : ',
                                style: TextStyle(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(.65),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500)),
                            SizedBox(height: 17),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: theme.colorScheme.primaryContainer),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: TextField(
                                  maxLength: 2,
                                  style: TextStyle(
                                      color: theme.colorScheme.onBackground,
                                      fontSize: 12),
                                  controller: _liftMinutesController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                      labelText: '00',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      labelStyle: greyLabelStyle.copyWith(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.4))),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text('Minutes',
                                style: greyLabelStyle.copyWith(fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Add a photo',
                    style: bodyStyle.copyWith(
                        color: theme.colorScheme.onBackground),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        addPicture(true);
                      },
                      child: Container(
                        width: 205,
                        height: 45,
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_outlined,
                                color: theme.colorScheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'Choose from camera roll',
                              style: labelStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    IconButton(
                        onPressed: () {
                          addPicture(false);
                        },
                        icon: Icon(Icons.camera_alt_outlined,
                            color: theme.colorScheme.primary)),
                  ],
                ),
                if (imageErrorText != null) SizedBox(height: 5),
                if (imageErrorText != null)
                  Center(
                    child: Text(imageErrorText!,
                        style: labelStyle.copyWith(
                            color: imageErrorText! == 'Attached'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary)),
                  ),
                SizedBox(height: 20),
                Center(
                    child: Text(
                  'Who can view your activity?',
                  style:
                      bodyStyle.copyWith(color: theme.colorScheme.onBackground),
                )),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...postOptions.map((option) {
                      bool isSelected = option == selectedPostOption;
                      if (isSelected) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ButtonStyle(
                                backgroundColor: resolveColor(
                                    theme.colorScheme.primaryContainer),
                                surfaceTintColor: resolveColor(
                                    theme.colorScheme.primaryContainer)),
                            icon: Icon(
                                option == 'Only you'
                                    ? Icons.person_off
                                    : Icons.people,
                                color: theme.colorScheme.primary),
                            label: Text(
                              option,
                              style: bodyStyle.copyWith(
                                  color: theme.colorScheme.onBackground),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedPostOption = option;
                              });
                            },
                            style: ButtonStyle(
                                backgroundColor: resolveColor(
                                    theme.colorScheme.primaryContainer),
                                surfaceTintColor: resolveColor(
                                    theme.colorScheme.primaryContainer)),
                            icon: Icon(
                                option == 'Only you'
                                    ? Icons.person_off_outlined
                                    : Icons.people_outline,
                                size: 18,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(.65)),
                            label: Text(
                              option,
                              style: greyLabelStyle,
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_liftTitleController.text.isEmpty) {
                        setState(() {
                          errorText = 'Please enter a title';
                        });
                        return;
                      }
                      if (_liftTitleController.text.length > 150) {
                        setState(() {
                          errorText = 'Please enter a shorter title';
                        });
                        return;
                      }
                      if (_liftDescriptionController.text.length > 500) {
                        setState(() {
                          errorText = 'Description is too long';
                        });
                        return;
                      }
                      int hours, minutes;
                      if (_liftHoursController.text.isEmpty) {
                        hours = 0;
                      } else {
                        hours = int.parse(_liftHoursController.text);
                      }
                      if (_liftMinutesController.text.isEmpty) {
                        minutes = 0;
                      } else {
                        minutes = int.parse(_liftMinutesController.text);
                      }
                      if (minutes < 0 || minutes > 60 || hours < 0) {
                        setState(() {
                          errorText = 'Badly formatted duration';
                        });
                        return;
                      }
                      uploadNewActivity(hours, minutes, appState);
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            resolveColor(theme.colorScheme.primary),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primary)),
                    child: Text('Done', style: labelStyle),
                  ),
                ),
                if (errorText != null) SizedBox(height: 5),
                if (errorText != null)
                  Center(
                    child: Text(errorText!,
                        style: labelStyle.copyWith(
                            color: theme.colorScheme.secondary)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> uploadNewActivity(
      int hours, int minutes, MyAppState appState) async {
    if (pickedFilePath != null) {
      try {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('userPhotos')
            .child(widget.user.username)
            .child('activityPictures')
            .child(millisecondsFromEpoch.toString());

        final uploadTask = storageRef.putFile(File(pickedFilePath!));
        final snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          activityPictureUrl = await snapshot.ref.getDownloadURL();
          activityPicture =
              Image.network(activityPictureUrl!, fit: BoxFit.cover);
        } else {
          print('Failed to upload image');
        }
      } catch (e) {
        print('Error uploading activity photo $e');
      }
    }
    widget.setProfilePageState(() {
      widget.user.activities.insert(
          0,
          Activity(
              username: widget.user.username,
              type: 'Manual',
              title: _liftTitleController.text,
              description: _liftDescriptionController.text,
              trainingDay: null,
              millisecondsFromEpoch: millisecondsFromEpoch,
              totalMinutesDuration: (hours * 60) + minutes,
              usernamesThatLiked: [],
              commentsFromEachUsername: {},
              pictureUrl: activityPictureUrl,
              picture: activityPicture,
              private: selectedPostOption == 'Only you',
              prsHit: null,
              gym: appState.userGym?.name,
              repRanges: []));
    });
    appState.storeDataInFirestore();
  }

  Future<void> addPicture(bool fromGallery) async {
    String? oldPath = pickedFilePath;
    pickedFilePath = await setActivityPicture(fromGallery);
    if (pickedFilePath == '2') {
      pickedFilePath = null;
      setState(() {
        imageErrorText = 'Failed to upload image';
      });
    } else if (pickedFilePath == '1') {
      pickedFilePath = oldPath;
      if (pickedFilePath == null) {
        setState(() {
          imageErrorText = null;
        });
      }
    } else {
      setState(() {
        imageErrorText = 'Attached';
      });
    }
  }

  Future<String> setActivityPicture(bool fromGallery) async {
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(
          source: fromGallery ? ImageSource.gallery : ImageSource.camera);
    } catch (e) {
      print(e);
      return '2';
    }

    if (pickedFile == null) {
      return '1'; // Exit when no image is selected or camera doesn't work
    }

    return pickedFile.path;
  }
}

class ActivityPreviewCard extends StatefulWidget {
  final User author;
  final Activity activity;
  final int activityIndex;
  final StateSetter setProfilePageState;
  final List<ActivityWithAuthorIndex>? friendsPageAllActivities;

  ActivityPreviewCard(this.author, this.activity, this.activityIndex,
      this.setProfilePageState, this.friendsPageAllActivities);

  @override
  State<ActivityPreviewCard> createState() => _ActivityPreviewCardState();
}

class _ActivityPreviewCardState extends State<ActivityPreviewCard> {
  final List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

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

  bool isDayBefore(DateTime timeOfPost, DateTime now) {
    if (now.day != 1) {
      return timeOfPost.day == now.day - 1 &&
          timeOfPost.month == now.month &&
          timeOfPost.year == now.year;
    } else {
      if (now.month == 1) {
        // First of the year
        return timeOfPost.day == 31 &&
            timeOfPost.month == 12 &&
            timeOfPost.year == now.year - 1;
      } else {
        // First of a different month
        int daysInPreviousMonth = DateTime(now.year, now.month - 1, 0).day;
        return timeOfPost.day == daysInPreviousMonth &&
            timeOfPost.month == now.month - 1 &&
            timeOfPost.year == now.year;
      }
    }
  }

  bool isTwoDaysBefore(DateTime timeOfPost, DateTime now) {
    if (now.day >= 2) {
      return timeOfPost.day == now.day - 2 &&
          timeOfPost.month == now.month &&
          timeOfPost.year == now.year;
    } else {
      if (now.month == 1) {
        // First two days of the year
        if (now.day == 1) {
          return timeOfPost.day == 30 &&
              timeOfPost.month == 12 &&
              timeOfPost.year == now.year - 1;
        } else {
          // now.day == 0
          return timeOfPost.day == 31 &&
              timeOfPost.month == 12 &&
              timeOfPost.year == now.year - 1;
        }
      } else {
        // First two days of a different month
        int lastMonthDays = DateTime(now.year, now.month - 1, 0).day;
        if (now.day == 1) {
          return timeOfPost.day == lastMonthDays - 1 &&
              timeOfPost.month == now.month - 1 &&
              timeOfPost.year == now.year;
        } else {
          // now.day == 0
          return timeOfPost.day == lastMonthDays &&
              timeOfPost.month == now.month - 1 &&
              timeOfPost.year == now.year;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.8));
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    DateTime timeOfPost = DateTime.fromMillisecondsSinceEpoch(
        widget.activity.millisecondsFromEpoch);
    DateTime now = DateTime.now();
    // Duration timeDifference = now.difference(timeOfPost);
    String timeDifferenceString;
    // if (timeDifference.inSeconds < 60) {
    //   timeDifferenceString =
    //       '${timeDifference.inSeconds} second${timeDifference.inSeconds == 1 ? '' : 's'} ago';
    // } else if (timeDifference.inMinutes < 60) {
    //   timeDifferenceString =
    //       '${timeDifference.inMinutes} minute${timeDifference.inMinutes == 1 ? '' : 's'} ago';
    // } else if (timeDifference.inHours < 24) {
    //   timeDifferenceString =
    //       '${timeDifference.inHours} hour${timeDifference.inHours == 1 ? '' : 's'} ago';
    // } else if (timeDifference.inDays < 7) {
    //   timeDifferenceString =
    //       '${timeDifference.inDays} day${timeDifference.inDays == 1 ? '' : 's'} ago';
    // } else if (timeOfPost.year == now.year) {
    //   timeDifferenceString =
    //       '${months[timeOfPost.month - 1]} ${timeOfPost.day}';
    // } else {
    //   timeDifferenceString =
    //       '${months[timeOfPost.month - 1]} ${timeOfPost.day}, ${timeOfPost.year}';
    // }
    String hoursString = '';
    String amPM = '';
    if (timeOfPost.hour == 0) {
      hoursString = '12';
      amPM = 'AM';
    } else if (timeOfPost.hour == 12) {
      hoursString = '12';
      amPM = 'PM';
    } else if (timeOfPost.hour < 12) {
      hoursString = timeOfPost.hour.toString();
      amPM = 'AM';
    } else if (timeOfPost.hour > 12) {
      hoursString = '${timeOfPost.hour - 12}';
      amPM = 'PM';
    }
    String minutesString = timeOfPost.minute < 10
        ? '0${timeOfPost.minute}'
        : timeOfPost.minute.toString();
    if (timeOfPost.day == now.day &&
        timeOfPost.month == now.month &&
        timeOfPost.year == now.year) {
      timeDifferenceString = 'Today at $hoursString:$minutesString $amPM';
    } else if (isDayBefore(timeOfPost, now)) {
      timeDifferenceString = 'Yesterday at $hoursString:$minutesString $amPM';
    } else if (isTwoDaysBefore(timeOfPost, now)) {
      timeDifferenceString =
          'Two days ago at $hoursString:$minutesString $amPM';
    } else if (timeOfPost.year == now.year) {
      timeDifferenceString =
          '${months[timeOfPost.month - 1]} ${timeOfPost.day}, at $hoursString:$minutesString $amPM';
    } else {
      timeDifferenceString =
          '${months[timeOfPost.month - 1]} ${timeOfPost.day}, ${timeOfPost.year}, at $hoursString:$minutesString $amPM';
    }

    int numComments = widget.activity.commentsFromEachUsername.values
        .toList()
        .expand((innerList) => innerList)
        .length;

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            if (appState.pageIndex == 13) {
              // print('View ${widget.author}\'s profile');
              if (widget.author == appState.currentUser) {
                tryChangePageToOwnProfile(appState);
                return;
              }
              User? newUser = await getUserDataFromFirestore(
                  widget.author.username, appState);
              if (newUser != null) {
                appState.userProfileStack.add(newUser);
                appState.changePage(15);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(),
            child: Row(
              children: [
                SizedBox(width: 10),
                Row(
                  children: [
                    CircleAvatar(
                        radius: 12,
                        backgroundImage: widget.author.profilePicture,
                        child: widget.author.profilePicture == null
                            ? Icon(Icons.person,
                                color: theme.colorScheme.onBackground, size: 14)
                            : null),
                    SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                      child: Text(
                        widget.author.username,
                        style: titleStyle,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                if (appState.currentUser == widget.author)
                  GestureDetector(
                      onTapDown: (tapDownDetails) {
                        _showOptionsDropdown(
                            context, tapDownDetails.globalPosition);
                      },
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Icon(Icons.more_horiz,
                            color: theme.colorScheme.onBackground
                                .withOpacity(.65)),
                      )),
                SizedBox(width: 15),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Container(
            decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(5)),
            // height: 200,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text(
                      widget.activity.title,
                      style: theme.textTheme.titleMedium!
                          .copyWith(color: theme.colorScheme.onBackground),
                    ),
                  ),
                  if (widget.activity.private == true) SizedBox(height: 3),
                  if (widget.activity.private == true)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_person_outlined,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(.65),
                                size: 14),
                            SizedBox(width: 5),
                            Text('Private',
                                style: greyLabelStyle.copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  if (widget.activity.gym != null)
                    SizedBox(height: widget.activity.private == true ? 5 : 3),
                  if (widget.activity.gym != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Row(
                          children: [
                            Text('At ',
                                style: greyLabelStyle.copyWith(fontSize: 10)),
                            Text(widget.activity.gym!,
                                style: labelStyle.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 5),
                  if (widget.activity.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text(widget.activity.description,
                          style: greyLabelStyle),
                    ),
                  if (widget.activity.trainingDay != null) SizedBox(height: 10),
                  if (widget.activity.trainingDay != null)
                    TrainingDayPreviewCard(widget.activity.trainingDay!,
                        widget.activity.repRanges),
                  if (widget.activity.pictureUrl != null ||
                      (widget.activity.prsHit != null &&
                          widget.activity.prsHit!.isNotEmpty))
                    SizedBox(
                        height: widget.activity.trainingDay != null ? 15 : 10),
                  if (widget.activity.prsHit != null &&
                      widget.activity.prsHit!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 0),
                          Row(
                            children: [
                              Text('New PRs Hit', style: bodyStyle),
                              SizedBox(width: 5),
                              Icon(Icons.emoji_events,
                                  size: 20, color: Colors.amber[300]),
                            ],
                          ),
                          SizedBox(height: 5),
                          for (int i = 0;
                              i < widget.activity.prsHit!.length;
                              i++)
                            Text(widget.activity.prsHit![i],
                                style: greyLabelStyle),
                        ],
                      ),
                    ),
                  if (widget.activity.prsHit != null &&
                      widget.activity.prsHit!.isNotEmpty &&
                      widget.activity.pictureUrl != null)
                    SizedBox(height: 20),
                  if (widget.activity.pictureUrl != null)
                    Hero(
                      tag: widget.activityIndex,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenPhoto(
                                  photoTag: widget.activityIndex.toString(),
                                  photo: widget.activity.picture ??
                                      (widget.activity.picture = Image.network(
                                          widget.activity.pictureUrl!,
                                          fit: BoxFit.cover))),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            color: theme.colorScheme.onBackground,
                            // Natural size, up to 175 high
                            height: 175,
                            // width: MediaQuery.of(context).size.width - 100,
                            child: widget.activity.picture ??
                                (widget.activity.picture = Image.network(
                                    widget.activity.pictureUrl!,
                                    fit: BoxFit.cover)),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                      height: widget.activity.pictureUrl != null ? 20 : 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        // color: theme.colorScheme.secondaryContainer,
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  if (!widget.activity.usernamesThatLiked
                                      .contains(
                                          appState.currentUser.username)) {
                                    setState(() {
                                      widget.activity.usernamesThatLiked
                                          .add(appState.currentUser.username);
                                    });
                                  } else {
                                    setState(() {
                                      widget.activity.usernamesThatLiked.remove(
                                          appState.currentUser.username);
                                    });
                                  }
                                  DocumentReference authorRef =
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.author.username);

                                  authorRef
                                      .update({
                                        'activities': widget.author.activities
                                            .map(
                                                (e) => json.encode(e.toJson())),
                                      })
                                      .then((value) => print(
                                          '${widget.author} post at index ${widget.activityIndex} likes updated to ${widget.activity.usernamesThatLiked.length}'))
                                      .catchError((error) => print(
                                          'Failed to update likes: $error'));
                                },
                                child: widget.activity.usernamesThatLiked
                                        .contains(appState.currentUser.username)
                                    ? Icon(Icons.favorite,
                                        color: theme.colorScheme.secondary,
                                        size: 26)
                                    : Icon(Icons.favorite_border,
                                        color: theme.colorScheme.onBackground,
                                        size: 26)),
                            SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                _showLikes(
                                    context,
                                    appState,
                                    widget.author,
                                    widget.activity,
                                    widget.activityIndex,
                                    setState);
                              },
                              child: Container(
                                decoration: BoxDecoration(),
                                child: Text(
                                  '${widget.activity.usernamesThatLiked.length < 10000 ? widget.activity.usernamesThatLiked.length : '${widget.activity.usernamesThatLiked.length ~/ 10000}K'}',
                                  style: labelStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showComments(
                                          context,
                                          appState,
                                          widget.author,
                                          widget.activity,
                                          widget.activityIndex,
                                          setState);
                                    },
                                    child: Icon(Icons.comment,
                                        color: theme.colorScheme.onBackground,
                                        size: 26),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _showComments(
                                          context,
                                          appState,
                                          widget.author,
                                          widget.activity,
                                          widget.activityIndex,
                                          setState);
                                    },
                                    child: Container(
                                      width: 8,
                                      height: 24,
                                      decoration: BoxDecoration(),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _showComments(
                                          context,
                                          appState,
                                          widget.author,
                                          widget.activity,
                                          widget.activityIndex,
                                          setState);
                                    },
                                    child: Text(
                                      '${numComments < 10000 ? numComments : '${numComments ~/ 10000}K'}',
                                      style: labelStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            SizedBox(width: 10),
            Text(
              timeDifferenceString,
              style: greyLabelStyle,
            ),
            Spacer(),
            if (widget.activity.totalMinutesDuration > 0)
              Text(
                '${widget.activity.totalMinutesDuration ~/ 60 != 0 ? '${widget.activity.totalMinutesDuration ~/ 60} hour${widget.activity.totalMinutesDuration ~/ 60 == 1 ? '' : 's'}, ' : ''}${widget.activity.totalMinutesDuration % 60} minute${widget.activity.totalMinutesDuration % 60 == 1 ? '' : 's'}',
                style: greyLabelStyle,
              ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 25),
      ],
    );
  }

  void _showOptionsDropdown(BuildContext context, Offset tapPosition) {
    final theme = Theme.of(context);
    final labelStyle =
        TextStyle(color: theme.colorScheme.secondary, fontSize: 12);

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
          value: 'Delete post',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline,
                    color: theme.colorScheme.secondary, size: 16),
                SizedBox(width: 5),
                Text('Delete post', style: labelStyle),
              ],
            ),
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'Delete post') {
        bool error = false;
        int millisecondsFromEpochOfActivity =
            widget.activity.millisecondsFromEpoch;
        String titleOfActivity = widget.activity.title;
        widget.setProfilePageState(() {
          final activity =
              widget.author.activities.removeAt(widget.activityIndex);
          // Remove from friends page if applicable
          widget.friendsPageAllActivities
              ?.removeWhere((element) => activity == element.activity);
        });
        DocumentReference authorRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.author.username);

        authorRef.update({
          'activities':
              widget.author.activities.map((e) => json.encode(e.toJson())),
        }).then((value) {
          print(
              '${widget.author} removed post at index ${widget.activityIndex}');
        }).catchError((error) {
          print('Failed to delete post: $error');
          error = true;
        });

        try {
          final Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('userPhotos')
              .child(widget.author.username)
              .child('activityPictures')
              .child(millisecondsFromEpochOfActivity.toString());
          storageRef.delete().catchError((onError) {
            print('No photo to delete');
          });
        } catch (e) {
          print('Error deleting activity photo $e');
        }

        if (!error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              width: MediaQuery.of(context).size.width * .8,
              backgroundColor: theme.colorScheme.onBackground,
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  child: Text(
                      'Deleted post \'${titleOfActivity.length > 20 ? '${titleOfActivity.substring(0, 20)}...' : titleOfActivity}\'',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.background))),
              duration: Duration(milliseconds: 1500),
            ),
          );
        }
      }
    });
  }
}

class TrainingDayPreviewCard extends StatelessWidget {
  final TrainingDay trainingDay;
  final List<String?> repRanges;
  TrainingDayPreviewCard(this.trainingDay, this.repRanges);
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.8));
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(5)),
      height: 175,
      // width: MediaQuery.of(context).size.width - 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: ListView.builder(
          itemCount: trainingDay.muscleGroups.length,
          itemBuilder: (context, index) {
            List<Exercise> exercisesTestList = appState
                .muscleGroups[trainingDay.muscleGroups[index]]!
                .where((element) =>
                    trainingDay.exerciseNames[index] == element.name)
                .toList();
            if (exercisesTestList.length != 1) {
              return null;
            }
            Exercise exercise = exercisesTestList[0];
            return Column(
              children: [
                if (trainingDay.isSupersettedWithLast[index])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_vert,
                        color: theme.colorScheme.onBackground.withOpacity(.8),
                        size: 16,
                      ),
                      Text(' Superset ', style: labelStyle),
                      Icon(
                        Icons.swap_vert,
                        color: theme.colorScheme.onBackground.withOpacity(.8),
                        size: 16,
                      ),
                    ],
                  ),
                ListTile(
                  onTap: () {
                    toExercise(appState, exercise);
                  },
                  contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  leading: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: theme.colorScheme.onBackground),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: ImageContainer(exercise: exercise),
                    ),
                  ),
                  title: Row(children: [
                    SizedBox(
                        width: 150,
                        child: Text(exercise.name,
                            style: labelStyle, maxLines: 2)),
                  ]),
                  subtitle: Row(
                    children: [
                      Text(
                        '${exercise.mainMuscleGroup} ',
                        style: labelStyle.copyWith(
                            color: theme.colorScheme.primary),
                      ),
                      if (exercise.mainMuscleGroup != exercise.musclesWorked[0])
                        Text(
                          '(${exercise.musclesWorked[0]})',
                          style: labelStyle.copyWith(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(.65)),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${trainingDay.setsPerMuscleGroup[index]} sets',
                          style: greyLabelStyle),
                      if (repRanges.isNotEmpty &&
                          repRanges.length > index &&
                          repRanges[index] != null)
                        SizedBox(height: 3),
                      if (repRanges.isNotEmpty &&
                          repRanges.length > index &&
                          repRanges[index] != null)
                        Text('${repRanges[index]}', style: greyLabelStyle),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void toExercise(MyAppState appState, Exercise exercise) {
    appState.fromProfilePage = true;
    // appState.currentExerciseFromProfilePage = exercise;
    appState.changePageToExercise(exercise);
  }
}

void _showComments(BuildContext context, MyAppState appState, User author,
    Activity activity, int activityIndex, StateSetter setActivityPreviewState) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return CommentsWindow(
          appState, author, activity, activityIndex, setActivityPreviewState);
    },
  );
}

class CommentsWindow extends StatefulWidget {
  final MyAppState appState;
  final User author;
  final Activity activity;
  final int activityIndex;
  final StateSetter setActivityPreviewState;

  CommentsWindow(this.appState, this.author, this.activity, this.activityIndex,
      this.setActivityPreviewState);

  @override
  _CommentsWindowState createState() => _CommentsWindowState();
}

class _CommentsWindowState extends State<CommentsWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late TextEditingController _addCommentController = TextEditingController();

  List<User> usersThatCommented = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final labelMediumStyle = theme.textTheme.labelMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    // List<String> comments = widget.activity.commentsFromEachUsername.values.toList()
    //         .expand((innerList) => innerList)
    //         .toList();

    List<String> usernamesThatCommented =
        widget.activity.commentsFromEachUsername.keys.toList();

    if (usersThatCommented.isEmpty) {
      getAllCommentUserData(usernamesThatCommented, appState);
    }

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: theme.colorScheme.primaryContainer),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: TextField(
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                          controller: _addCommentController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Enter a comment',
                            labelStyle: greyLabelStyle,
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send,
                                  color: theme.colorScheme.onBackground,
                                  size: 20),
                              onPressed: () {
                                if (_addCommentController.text.length > 500) {
                                  _addCommentController.text =
                                      _addCommentController.text
                                          .substring(0, 500);
                                }
                                widget.setActivityPreviewState(() {
                                  setState(() {
                                    if (widget.activity
                                                .commentsFromEachUsername[
                                            appState.currentUser.username] ==
                                        null) {
                                      widget.activity.commentsFromEachUsername[
                                          appState.currentUser.username] = [
                                        _addCommentController.text
                                      ];
                                    } else {
                                      widget
                                          .activity
                                          .commentsFromEachUsername[
                                              appState.currentUser.username]!
                                          .add(_addCommentController.text);
                                    }
                                  });
                                });
                                DocumentReference authorRef = FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(widget.author.username);

                                authorRef.update({
                                  'activities': widget.author.activities
                                      .map((e) => json.encode(e.toJson())),
                                }).then((value) {
                                  _addCommentController.clear();
                                  FocusScope.of(context).unfocus();
                                  print(
                                      '${widget.author} post at index ${widget.activityIndex} added comment from ${appState.currentUser.username}');
                                }).catchError((error) {
                                  print('Failed to update likes: $error');
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground)),
                        ),
                      ),
                      Spacer(flex: 7),
                      Text('Comments',
                          style: theme.textTheme.titleSmall!
                              .copyWith(color: theme.colorScheme.onBackground)),
                      Spacer(flex: 10),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                if (usernamesThatCommented.isEmpty)
                  Center(
                    child: Text(
                      'Be the first one to comment',
                      style: greyLabelStyle,
                    ),
                  ),
                if (usernamesThatCommented.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: usernamesThatCommented.length,
                      itemBuilder: (context, index) {
                        String commentUsername = usernamesThatCommented[index];
                        List<String> commentsFromUsername = widget.activity
                                .commentsFromEachUsername[commentUsername] ??
                            [];
                        // Empty user will have blank profile picture
                        User commentUser = usersThatCommented.firstWhere(
                            (element) => element.username == commentUsername,
                            orElse: () =>
                                User(username: '', uid: '', email: ''));
                        return Column(
                          children: [
                            for (int j = 0;
                                j < commentsFromUsername.length;
                                j++)
                              ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                contentPadding:
                                    EdgeInsets.fromLTRB(16, 0, 16, 0),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      radius: 7,
                                      backgroundImage:
                                          commentUser.profilePicture,
                                      //  widget.author.username ==
                                      //         commentUsername
                                      //     ? widget.author.profilePicture
                                      //     : null,
                                      child: commentUser.profilePicture == null
                                          ? Icon(Icons.person,
                                              color: theme
                                                  .colorScheme.onBackground,
                                              size: 9)
                                          : null,
                                      // widget.author.username ==
                                      //         commentUsername
                                      //     ? (widget.author.profilePicture ==
                                      //             null
                                      //         ? Icon(Icons.person,
                                      //             color: theme
                                      //                 .colorScheme.onBackground,
                                      //             size: 9)
                                      //         : null)
                                      //     : Icon(Icons.person,
                                      //         color: theme
                                      //             .colorScheme.onBackground,
                                      //         size: 9),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      commentUsername,
                                      style: labelMediumStyle,
                                    ),
                                    Spacer(),
                                    if (appState.currentUser == widget.author)
                                      GestureDetector(
                                        onTap: () {
                                          if (widget.activity
                                                      .commentsFromEachUsername[
                                                  appState
                                                      .currentUser.username] !=
                                              null) {
                                            widget.setActivityPreviewState(() {
                                              setState(() {
                                                widget
                                                    .activity
                                                    .commentsFromEachUsername[
                                                        appState.currentUser
                                                            .username]!
                                                    .removeAt(j);
                                              });
                                            });
                                            DocumentReference authorRef =
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(
                                                        widget.author.username);

                                            authorRef.update({
                                              'activities': widget
                                                  .author.activities
                                                  .map((e) =>
                                                      json.encode(e.toJson())),
                                            }).then((value) {
                                              print(
                                                  '${widget.author} post at index ${widget.activityIndex} removed comment number $j from $commentUsername');
                                            }).catchError((error) {
                                              print(
                                                  'Failed to update likes: $error');
                                            });
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: theme.colorScheme.secondary,
                                            size: 14,
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(19, 0, 0, 0),
                                  child: Text(commentsFromUsername[j],
                                      style: greyLabelStyle, maxLines: 5),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getAllCommentUserData(
      List<String> usernamesThatCommented, MyAppState appState) async {
    for (String commentUsername in usernamesThatCommented) {
      User? commentUser = await getCommentUserData(commentUsername, appState);
      if (commentUser != null) {
        usersThatCommented.add(commentUser);
      }
    }
    setState(() {});
  }

  Future<User?> getCommentUserData(
      String commentUsername, MyAppState appState) async {
    User? commentUser;
    if (commentUsername == appState.currentUser.username) {
      commentUser = appState.currentUser;
    } else {
      commentUser = await getUserDataFromFirestore(commentUsername, appState);
    }
    return commentUser;
  }
}

void _showLikes(BuildContext context, MyAppState appState, User author,
    Activity activity, int activityIndex, StateSetter setActivityPreviewState) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return LikesWindow(
          appState, author, activity, activityIndex, setActivityPreviewState);
    },
  );
}

class LikesWindow extends StatefulWidget {
  final MyAppState appState;
  final User author;
  final Activity activity;
  final int activityIndex;
  final StateSetter setActivityPreviewState;

  LikesWindow(this.appState, this.author, this.activity, this.activityIndex,
      this.setActivityPreviewState);

  @override
  _LikesWindowState createState() => _LikesWindowState();
}

class _LikesWindowState extends State<LikesWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  List<User> usersThatLiked = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final labelMediumStyle = theme.textTheme.labelMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    List<String> usernamesThatLiked = widget.activity.usernamesThatLiked;

    if (usersThatLiked.isEmpty) {
      getAllLikesUserData(usernamesThatLiked, appState);
    }

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground)),
                        ),
                      ),
                      Spacer(flex: 7),
                      Text('Likes',
                          style: theme.textTheme.titleSmall!
                              .copyWith(color: theme.colorScheme.onBackground)),
                      Spacer(flex: 10),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                if (usernamesThatLiked.isEmpty)
                  Center(
                    child: Text(
                      'No likes yet',
                      style: greyLabelStyle,
                    ),
                  ),
                if (usernamesThatLiked.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: usernamesThatLiked.length,
                      itemBuilder: (context, index) {
                        String likesUsername = usernamesThatLiked[index];
                        // Empty user will have blank profile picture
                        User likesUser = usersThatLiked.firstWhere(
                            (element) => element.username == likesUsername,
                            orElse: () =>
                                User(username: '', uid: '', email: ''));
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                radius: 7,
                                backgroundImage: likesUser.profilePicture,
                                child: likesUser.profilePicture == null
                                    ? Icon(Icons.person,
                                        color: theme.colorScheme.onBackground,
                                        size: 9)
                                    : null,
                              ),
                              SizedBox(width: 5),
                              Text(
                                likesUsername,
                                style: labelMediumStyle,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getAllLikesUserData(
      List<String> usernamesThatLiked, MyAppState appState) async {
    for (String commentUsername in usernamesThatLiked) {
      User? likesUser = await getLikesUserData(commentUsername, appState);
      if (likesUser != null) {
        usersThatLiked.add(likesUser);
      }
    }
    setState(() {});
  }

  Future<User?> getLikesUserData(
      String likesUsername, MyAppState appState) async {
    User? likesUser;
    if (likesUsername == appState.currentUser.username) {
      likesUser = appState.currentUser;
    } else {
      likesUser = await getUserDataFromFirestore(likesUsername, appState);
    }
    return likesUser;
  }
}

// Future<void> sendNotification(
//     String recipientToken, String senderUsername) async {
//   // Replace YOUR_FCM_SERVER_KEY with your actual FCM server key from the Firebase console
//   const String serverKey = '2983018103981223317';

//   // Construct the FCM notification payload
//   final Map<String, dynamic> notification = {
//     'title': 'Nudge from $senderUsername',
//     'body': 'You have been nudged to go to the gym!',
//     'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//   };

//   // Construct the FCM request body
//   final Map<String, dynamic> requestBody = {
//     'to': recipientToken,
//     'notification': notification,
//     'priority':
//         'high', // Set the priority to high for time-sensitive notifications
//   };

//   // Send the FCM request
//   final response = await http.post(
//     Uri.parse('https://fcm.googleapis.com/fcm/send'),
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'key=$serverKey',
//     },
//     body: jsonEncode(requestBody),
//   );

//   if (response.statusCode == 200) {
//     print('Notification sent successfully.');
//   } else {
//     print('Failed to send notification. Status code: ${response.statusCode}');
//   }
// }
