import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:time_for_gym/active_workout.dart';

import 'activity.dart';

class User {
  User(
      {required this.username,
      required this.email,
      required this.uid,
      this.favoritesString = '',
      this.splitDayExerciseIndicesString = '',
      this.userGymId = '',
      this.profileName = '',
      this.profileDescription = ''});
  // required this.authUser

  void initializeProfilePicData() async {
    // Initialize profile picture
    if (profilePicture == null && profilePictureUrl != null) {
      // Retrieve from storage
      profilePicture = NetworkImage(profilePictureUrl!);
    }
  }

  @override
  String toString() {
    return username;
  }

  Future<bool> removeFollowerInFirebase(String otherUsername) async {
    // Create a reference to the user document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(username);
    DocumentReference otherUserRef =
        FirebaseFirestore.instance.collection('users').doc(otherUsername);
    bool error = false;

    await userRef.update({'followers': followers}).then((value) {
      print('Updated followers');
    }).catchError((error) {
      print('Failed to update followers: $error');
      error = true;
    });
    if (error == true) {
      return false;
    }

    // Get the document snapshot
    DocumentSnapshot snapshot = await otherUserRef.get();

    // Check if the document exists
    if (snapshot.exists) {
      // Get the data as a Map
      Map<String, dynamic> otherUserData =
          snapshot.data() as Map<String, dynamic>;

      List<dynamic> otherFollowingAsObjects = otherUserData['following'] ?? [];
      List<String> otherFollowing = otherFollowingAsObjects.cast<String>();
      otherFollowing.remove(username);
      await otherUserRef.update({'followers': otherFollowing}).then((value) {
        print('Updated other user\'s ($otherUsername) following');
      }).catchError((error) {
        print('Failed to update other user\'s following: $error');
        error = true;
      });
      if (error == true) {
        return false;
      } else {
        return true;
      }
    } else {
      print('ERROR - Other user $otherUsername does not exist');
      return false;
    }
  }

  Future<bool> updateFollowingInFirebase(
      String otherUsername, bool follow, User other) async {
    // Create a reference to the user document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(username);
    DocumentReference otherUserRef =
        FirebaseFirestore.instance.collection('users').doc(otherUsername);
    bool error = false;

    await userRef.update({'following': following}).then((value) {
      print('Updated following');
    }).catchError((error) {
      print('Failed to update following: $error');
      error = true;
    });

    if (error == true) {
      return false;
    }

    // Get the document snapshot
    DocumentSnapshot snapshot = await otherUserRef.get();

    // Check if the document exists
    if (snapshot.exists) {
      // Get the data as a Map
      Map<String, dynamic> otherUserData =
          snapshot.data() as Map<String, dynamic>;

      List<dynamic> otherFollowersAsObjects = otherUserData['followers'] ?? [];
      List<String> otherFollowers = otherFollowersAsObjects.cast<String>();
      follow ? otherFollowers.add(username) : otherFollowers.remove(username);
      await otherUserRef.update({'followers': otherFollowers}).then((value) {
        print('Updated other user\'s ($otherUsername) followers');
      }).catchError((error) {
        print('Failed to update other user\'s followers: $error');
        error = true;
      });
      if (error == true) {
        return false;
      } else {
        // Update memory of other user & profile screen without redownloading from firebase
        follow
            ? other.followers.add(username)
            : other.followers.remove(username);
        return true;
      }
    } else {
      print('ERROR - Other user $otherUsername does not exist');
      return false;
    }
  }

  Future<ImageProvider?> setProfilePicture(bool fromGallery,
      StateSetter setProfilePageState, List<bool> isProfilePicLoading) async {
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(
          source: fromGallery ? ImageSource.gallery : ImageSource.camera);
    } catch (e) {
      print(e);
      return null;
    }

    if (pickedFile == null) {
      return null; // Exit when no image is selected or camera doesn't work
    }

    // print('savedPath: $profilePictureDevicePath, pickedFile.path: ${pickedFile.path}');
    // Note - Does not work on simulators
    if (profilePictureDevicePath != null &&
        profilePictureDevicePath == pickedFile.path) {
      return null; // Exit when same image is selected
    }

    // Only set loading bar to be visible if actually loading a new image
    setProfilePageState(() {
      isProfilePicLoading[0] = true;
    });

    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('userPhotos')
        .child(username)
        .child('profilePicture.jpg');

    final uploadTask = storageRef.putFile(File(pickedFile.path));
    final snapshot = await uploadTask; //.whenComplete(() {});

    if (snapshot.state == TaskState.success) {
      profilePictureUrl = await snapshot.ref.getDownloadURL();
      profilePictureDevicePath = pickedFile.path;
      profilePicture = NetworkImage(profilePictureUrl!);
      // Update firestore database
      FirebaseFirestore.instance.collection('users').doc(username).update({
        'profilePictureUrl': profilePictureUrl,
        'profilePictureDevicePath': profilePictureDevicePath
      });
      print('File uploaded: $profilePictureUrl, $profilePictureDevicePath');
      return profilePicture;
    } else {
      print('Failed to upload image');
      return null;
    }
  }

  Future<bool> followUser(String otherUsername, User other) async {
    following.add(otherUsername);
    return await updateFollowingInFirebase(otherUsername, true, other);
  }

  Future<bool> unfollowUser(String otherUsername, User other) async {
    following.remove(otherUsername);
    return await updateFollowingInFirebase(otherUsername, false, other);
  }

  Future<bool> removeFromFollowers(int index) async {
    return await removeFollowerInFirebase(followers.removeAt(index));
  }

  String username;
  String profileName;
  String profileDescription;
  String email;
  String uid;
  String favoritesString;
  String splitDayExerciseIndicesString;
  String? splitJson;
  String userGymId;
  // auth.User authUser;
  List<String> followers = [];
  List<String> following = [];
  String? profilePictureUrl;
  String? profilePictureDevicePath;
  ImageProvider? profilePicture;
  List<Activity> activities = [];
  ActiveWorkout? workout;
  bool onlyFriendsCanViewPosts = false;

  final ImagePicker _picker = ImagePicker();
}
