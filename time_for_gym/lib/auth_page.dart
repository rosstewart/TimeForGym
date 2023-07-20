import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/main.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthPage extends StatefulWidget {
  final StateSetter setAuthenticationState;
  AuthPage(this.setAuthenticationState);
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();
  // final TextEditingController _signUpFirstNameController =
  //     TextEditingController();
  final TextEditingController _signUpUsernameController =
      TextEditingController();
  final TextEditingController _logInEmailController = TextEditingController();
  final TextEditingController _logInPasswordController =
      TextEditingController();
  final TextEditingController _forgotPasswordController =
      TextEditingController();
  bool _isSigningIn = false;
  String signUpErrorText = '';
  String logInErrorText = '';
  Icon? sentResetPasswordLinkIcon;

  @override
  void dispose() {
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    // _signUpFirstNameController.dispose();
    _signUpUsernameController.dispose();
    _logInEmailController.dispose();
    _logInPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register(MyAppState appState) async {
    try {
      setState(() {
        _isSigningIn = true;
      });
      final String username = _signUpUsernameController.text.trim();

      if (username.isEmpty) {
        setState(() {
          signUpErrorText = 'Username is empty';
          _isSigningIn = false;
        });
        return;
      } else {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(username);
        DocumentSnapshot snapshot = await userRef.get();
        // Check if the document exists
        if (snapshot.exists) {
          // Username already exists
          setState(() {
            signUpErrorText = 'Username is taken';
            _isSigningIn = false;
          });
          return;
        }

        // Username is not taken

        final String email = _signUpEmailController.text.trim();
        final String password = _signUpPasswordController.text.trim();
        // final String displayName = _signUpFirstNameController.text.trim();

        final auth.UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final auth.User? user = userCredential.user;

        if (user != null) {
          // User successfully registered and signed in
          // Navigate to the next screen or perform any additional operations
          print('User is successfully registered with email');
          hideAllErrorText();

          makeProfileInFirestore(username, user, userRef);

          user.updateDisplayName(username);
          user.sendEmailVerification();
          authUser = user;
          appState.authUsername = username;
          appState.initEverythingAfterAuthentication();
          widget.setAuthenticationState(() {
            isAuthenticated = true;
          });
        }
      }
    } catch (e) {
      // Handle registration errors
      print(e.toString());
      handleErrors(e.toString(), false);

      // if (e.toString() == 'email-already-in-use') {
      //   _showErrorDialog('Error', 'Email address is already in use.');
      // }
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  void makeProfileInFirestore(
      String username, auth.User user, DocumentReference<Object?> userRef) {
    Map<String, dynamic> userData = {
      'username': username,
      'uid': user.uid,
      'email': user.email,
    };

    userRef
        .set(userData)
        .then((value) => print('User data stored successfully'))
        .catchError((error) => print('Failed to store user data: $error'));
  }

  Future<void> _login(MyAppState appState) async {
    try {
      setState(() {
        _isSigningIn = true;
      });

      final String email = _logInEmailController.text.trim();
      final String password = _logInPasswordController.text.trim();

      final auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final auth.User? user = userCredential.user;

      if (user != null) {
        // User successfully signed in
        // Navigate to the next screen or perform any additional operations
        print('User is successfully signed in with email');
        hideAllErrorText();
        authUser = user;
        appState.initEverythingAfterAuthentication();
        widget.setAuthenticationState(() {
          isAuthenticated = true;
        });
      }
    } catch (e) {
      // Handle login errors
      print(e.toString());
      handleErrors(e.toString(), true);
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  void handleErrors(String error, bool login) {
    if (error.startsWith('[firebase_auth')) {
      showErrorText(error.split(']')[1].substring(1), login);
    }
  }

  void showErrorText(String text, bool login) {
    setState(() {
      login ? logInErrorText = text : signUpErrorText = text;
    });
  }

  void hideAllErrorText() {
    setState(() {
      logInErrorText = '';
      signUpErrorText = '';
    });
  }

  // Future<void> _signInWithGoogle() async {
  //   try {
  //     setState(() {
  //       _isSigningIn = true;
  //     });

  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser!.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);
  //     final User? user = userCredential.user;

  //     if (user != null) {
  //       // User successfully signed in
  //       // If the user doesn't have an account, create one
  //       final User currentUser = _auth.currentUser!;
  //       if (currentUser.displayName == null) {
  //         // Check if the email address is already in use
  //         final userExists = await _checkIfUserExists(currentUser.email!);
  //         if (userExists) {
  //           _showErrorDialog('Error', 'Email address is already in use.');
  //           _auth.signOut();
  //         } else {
  //           // Update the display name to the email address (use email as the username)
  //           await currentUser.updateDisplayName(currentUser.email!);

  //           // Navigate to the next screen or perform any additional operations
  //           print('Successfully registered with Google');
  //         }
  //       } else {
  //         // User already has an account
  //         // Navigate to the next screen or perform any additional operations
  //         print('Successfully signed in with Google');
  //       }
  //     }
  //   } catch (e) {
  //     // Handle sign-in errors
  //     print(e.toString());
  //   } finally {
  //     setState(() {
  //       _isSigningIn = false;
  //     });
  //   }
  // }

  // Future<bool> _checkIfUserExists(String email) async {
  //   // Implement your own logic to check if a user with the provided email already exists
  //   // Return true if the user exists, false otherwise
  //   // You can use Firebase Firestore or any other data storage mechanism to perform the check
  //   // For simplicity, we'll simulate a check by comparing with a static list of email addresses
  //   final existingEmails = [
  //     'user1@example.com',
  //     'user2@example.com',
  //     'user3@example.com'
  //   ];
  //   return existingEmails.contains(email);
  // }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('User Authentication'),
    //   ),
    return GestureDetector(
        onTap: FocusScope.of(context).unfocus, // Dismiss keyboard
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                bottomSheet: Container(
                  color: theme.colorScheme.background,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.copyright_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Ross Stewart",
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                        )
                      ],
                    ),
                  ),
                ),
                appBar: AppBar(
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: SizedBox(
                      height: 50,
                      child: Image.asset('assets/images/gym_brain_logo.png'),
                    ),
                  ),
                  backgroundColor: theme.scaffoldBackgroundColor,
                  bottom: TabBar(
                    unselectedLabelColor: theme.colorScheme.onBackground,
                    tabs: [
                      Tab(text: 'Sign Up'),
                      Tab(text: 'Log In'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create an Account',
                                  style: theme.textTheme.titleMedium!.copyWith(
                                      color: theme.colorScheme.onBackground),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                // Container(
                                //   decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(16),
                                //       color:
                                //           theme.colorScheme.primaryContainer),
                                //   padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
                                //   child: TextField(
                                //     style: TextStyle(
                                //         color: theme.colorScheme.onBackground),
                                //     controller: _signUpFirstNameController,
                                //     decoration: InputDecoration(
                                //       border: InputBorder.none,
                                //       labelStyle: TextStyle(
                                //           color: theme.colorScheme.onBackground
                                //               .withOpacity(.65)),
                                //       prefixIcon: Icon(Icons.face,
                                //           color: theme.colorScheme.primary),
                                //       labelText: 'Name',
                                //     ),
                                //   ),
                                // ),
                                SizedBox(height: 12.0),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color:
                                          theme.colorScheme.primaryContainer),
                                  padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
                                  child: TextField(
                                    style: TextStyle(
                                        color: theme.colorScheme.onBackground),
                                    controller: _signUpUsernameController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelStyle: TextStyle(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.65)),
                                      prefixIcon: Icon(Icons.person_outline,
                                          color: theme.colorScheme.primary),
                                      labelText: 'Username',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.0),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color:
                                          theme.colorScheme.primaryContainer),
                                  padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
                                  child: TextField(
                                    style: TextStyle(
                                        color: theme.colorScheme.onBackground),
                                    controller: _signUpEmailController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelStyle: TextStyle(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.65)),
                                      prefixIcon: Icon(Icons.email_outlined,
                                          color: theme.colorScheme.primary),
                                      labelText: 'Email',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.0),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color:
                                          theme.colorScheme.primaryContainer),
                                  padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
                                  child: TextField(
                                    controller: _signUpPasswordController,
                                    style: TextStyle(
                                        color: theme.colorScheme.onBackground),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelStyle: TextStyle(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.65)),
                                      prefixIcon: Icon(Icons.lock_outline,
                                          color: theme.colorScheme.primary),
                                      labelText: 'Password',
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                SizedBox(height: 16),
                                if (!_isSigningIn)
                                  ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: resolveColor(
                                            theme.colorScheme.primary),
                                        surfaceTintColor: resolveColor(
                                            theme.colorScheme.primary)),
                                    onPressed: () {
                                      _register(appState);
                                    },
                                    child: Text('Sign Up',
                                        style: TextStyle(
                                            color: theme
                                                .colorScheme.onBackground)),
                                  ),
                                SizedBox(
                                  height: 10,
                                ),
                                if (signUpErrorText.isNotEmpty && !_isSigningIn)
                                  Text(
                                    signUpErrorText,
                                    style: TextStyle(
                                        color: theme.colorScheme.secondary),
                                    textAlign: TextAlign.center,
                                  )
                                // if (!_isSigningIn)
                                //   ElevatedButton(
                                //     onPressed: _signInWithGoogle,
                                //     child: Row(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       children: [
                                //         Container(color: Colors.grey[200], height: 24, width: 24),
                                //         // Image.asset(
                                //         //   'assets/google_logo.png',
                                //         //   height: 24.0,
                                //         // ),
                                //         SizedBox(width: 16.0),
                                //         Text('Sign in with Google'),
                                //       ],
                                //     ),
                                //   ),
                              ],
                              //   ),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 150,
                          ),
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: theme.textTheme.titleMedium!.copyWith(
                                      color: theme.colorScheme.onBackground),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color:
                                          theme.colorScheme.primaryContainer),
                                  padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
                                  child: TextField(
                                    style: TextStyle(
                                        color: theme.colorScheme.onBackground),
                                    controller: _logInEmailController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelStyle: TextStyle(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.65)),
                                      prefixIcon: Icon(Icons.email_outlined,
                                          color: theme.colorScheme.primary),
                                      labelText: 'Email',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.0),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color:
                                          theme.colorScheme.primaryContainer),
                                  padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
                                  child: TextField(
                                    controller: _logInPasswordController,
                                    style: TextStyle(
                                        color: theme.colorScheme.onBackground),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelStyle: TextStyle(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.65)),
                                      prefixIcon: Icon(Icons.lock_outline,
                                          color: theme.colorScheme.primary),
                                      labelText: 'Password',
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                SizedBox(height: 16),
                                if (!_isSigningIn)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Spacer(flex: 5),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor: resolveColor(
                                                theme.colorScheme.primary),
                                            surfaceTintColor: resolveColor(
                                                theme.colorScheme.primary)),
                                        onPressed: () {
                                          _login(appState);
                                        },
                                        child: Text('Log In',
                                            style: TextStyle(
                                                color: theme
                                                    .colorScheme.onBackground)),
                                      ),
                                      Spacer(flex: 2),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                sentResetPasswordLinkIcon =
                                                    null;
                                              });
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                    dialogContext) {
                                                  String? errorText;
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter
                                                            setDialogState) {
                                                      return GestureDetector(
                                                        onTap: FocusScope.of(
                                                                context)
                                                            .unfocus,
                                                        child: AlertDialog(
                                                          title: Text(
                                                              'Reset Password',
                                                              style: TextStyle(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .onBackground)),
                                                          content: TextField(
                                                            style: TextStyle(
                                                                color: theme
                                                                    .colorScheme
                                                                    .onBackground),
                                                            controller:
                                                                _forgotPasswordController,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  'Enter your email',
                                                              labelStyle: TextStyle(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .onBackground
                                                                      .withOpacity(
                                                                          .65)),
                                                              errorText:
                                                                  errorText,
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                handleForgotPassword(
                                                                    () {
                                                                  Navigator.pop(
                                                                      dialogContext);
                                                                  setState(() {
                                                                    sentResetPasswordLinkIcon =
                                                                        Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: theme
                                                                          .colorScheme
                                                                          .primary,
                                                                      size: 16,
                                                                    );
                                                                  });
                                                                }, (newErrorText) {
                                                                  setDialogState(
                                                                      () {
                                                                    errorText =
                                                                        newErrorText;
                                                                  });
                                                                });
                                                              },
                                                              child: Text(
                                                                  'Send Link'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  'Cancel',
                                                                  style: TextStyle(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .onBackground
                                                                          .withOpacity(
                                                                              .65))),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: theme
                                                      .colorScheme.primary),
                                            ),
                                          ),
                                          if (sentResetPasswordLinkIcon != null)
                                            SizedBox(
                                              height: 3,
                                            ),
                                          if (sentResetPasswordLinkIcon != null)
                                            Row(
                                              children: [
                                                Text(
                                                  'Sent',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: theme.colorScheme
                                                          .onBackground),
                                                ),
                                                SizedBox(width: 3),
                                                sentResetPasswordLinkIcon!,
                                              ],
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                SizedBox(
                                  height: 10,
                                ),
                                if (logInErrorText.isNotEmpty && !_isSigningIn)
                                  Text(
                                    logInErrorText,
                                    style: TextStyle(
                                        color: theme.colorScheme.secondary),
                                    textAlign: TextAlign.center,
                                  )
                              ],
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 150,
                          ),
                        ]),
                  ],
                ))));
  }

  void handleForgotPassword(
      Function resetCallback, Function updateErrorText) async {
    try {
      await _auth.sendPasswordResetEmail(email: _forgotPasswordController.text);
      print('Password reset sent');
      _forgotPasswordController.clear();
      updateErrorText(null);
      resetCallback();
    } catch (error) {
      print(error.toString());
      updateErrorText(error.toString().split(']')[1].substring(1));
    }
  }
}
