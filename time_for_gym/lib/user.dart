import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:flutter/material.dart';

class User {
  User(
      {required this.username,
      required this.email,
      required this.uid,
      this.favoritesString = '',
      this.splitDayExerciseIndicesString = '',
      this.userGymId = '',});
  // required this.authUser

  void initializeData() async {
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

  void removeFollowerInFirebase(String otherUsername) async {
    // Create a reference to the user document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(username);
    DocumentReference otherUserRef =
        FirebaseFirestore.instance.collection('users').doc(otherUsername);

    userRef
        .update({'followers': followers})
        .then((value) => print('Updated followers'))
        .catchError((error) => print('Failed to update followers: $error'));

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
      otherUserRef
          .update({'followers': otherFollowing})
          .then((value) =>
              print('Updated other user\'s ($otherUsername) following'))
          .catchError((error) =>
              print('Failed to update other user\'s following: $error'));
    } else {
      print('ERROR - Other user $otherUsername does not exist');
    }
  }

  void updateFollowingInFirebase(String otherUsername, bool follow) async {
    // Create a reference to the user document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(username);
    DocumentReference otherUserRef =
        FirebaseFirestore.instance.collection('users').doc(otherUsername);

    userRef
        .update({'following': following})
        .then((value) => print('Updated following'))
        .catchError((error) => print('Failed to update following: $error'));

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
      otherUserRef
          .update({'followers': otherFollowers})
          .then((value) =>
              print('Updated other user\'s ($otherUsername) followers'))
          .catchError((error) =>
              print('Failed to update other user\'s followers: $error'));
    } else {
      print('ERROR - Other user $otherUsername does not exist');
    }
  }

  // Future<ImageProvider?> getProfilePicture() async {
  //   if (profilePicture != null) {
  //     return profilePicture;
  //   }
  //   if (profilePictureUrl != null) {
  //     profilePicture = NetworkImage(profilePictureUrl!);
  //     return profilePicture;
  //   }
  //   try {
  //     final Reference storageRef = FirebaseStorage.instance
  //         .ref()
  //         .child('userPhotos')
  //         .child(username)
  //         .child('profilePicture.jpg');
  //     final images = (await storageRef.listAll()).items;
  //     if (images.isNotEmpty) {
  //       profilePictureUrl = await images[0].getDownloadURL();
  //       if (profilePictureUrl != null) {
  //         profilePicture = NetworkImage(profilePictureUrl!);
  //         return profilePicture;
  //       }
  //     }
  //     print('Error - No profile picture in storage');
  //   } catch (error) {
  //     print("Error loading profile picture - $error");
  //   }
  //   return null;
  // }

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
      return null; // Exit when no image is selected
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

// final Directory pickedFileDirectory = Directory(pickedFile.path).parent;
// final String tempPath = '${pickedFileDirectory.path}/gym_brain_profile_compressed.jpg';
//     // String tempPath = (await getTemporaryDirectory()).path;
//     const int targetFileSizeInBytes =
//         1024 * 1024; // Target file size in bytes (e.g., 1MB)
//     int quality =
//         100; // Start at highest quality in case image is already low-quality

//     int compressedFileSizeInBytes = 0;
//     XFile? compressedFile;

//     while (compressedFileSizeInBytes < targetFileSizeInBytes) {
//       compressedFile = await FlutterImageCompress.compressAndGetFile(
//         pickedFile.path,
//         tempPath,
//         quality: quality,
//       );

//       compressedFileSizeInBytes = (await compressedFile?.length()) ?? 0;
//       quality -= 5; // Decrease quality level by 5 for each iteration
//       if (quality < 0) {
//         break; // Stop compressing if the quality level becomes negative
//       }
//       print(quality);
//     }

//     final file = File(tempPath);
//     final uploadTask = storageRef.putFile(file);
//     // Clean up the temporary compressed file
//     file.delete();

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

  void followUser(String otherUID) {
    following.add(otherUID);
    updateFollowingInFirebase(otherUID, true);
  }

  void unfollowUser(String otherUID) {
    following.remove(otherUID);
    updateFollowingInFirebase(otherUID, false);
  }

  void removeFromFollowers(int index) {
    removeFollowerInFirebase(followers.removeAt(index));
  }

  String username;
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

  final ImagePicker _picker = ImagePicker();
}
