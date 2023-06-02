# TimeForGym
# Ross Stewart & James Johnson

Time for Gym
-------------
This is the README file for the Time for Gym project.


Description
-------------
The Time for Gym project is a mobile application to provide resources on various exercises & machines and act as a library for them.
It will also provide waiting times for machines as well as the current occupancy of the University of Miami gym.


File Organization
------------------
Documents folder: Includes SRS, SAS, and other documents.


Presentations folder: Includes both the midterm and final presentation slideshows.


Demo folder: Provides a minute-long screen recording of the app on an iPhone that demonstrates the various functionalities of the app.
In addition, there is a screenshot of the database that was used (Google Firebase) to store the user-inputted data. This screenshot
displays the data that was sent to the database during the demo. 


time_for_gym folder: Project folder for the application. Inside the "lib" folder is all of the source code.


Developer Notes
----------------

Since we have already received feedback for all of the documents for this project and finalized those documents, we decided to not change them
  to reflect unexpected architecture drift. This would require all of the documents to be changed, and since the software implementation
  is extra credit, we did not want to essentially change our entire project.

Architecture drift due to unexpected challenges during development and other constraints:

  Due to time constraints, I (Ross) chose to develop the app in Flutter rather than React Native, as it can be easier to learn. Due to my
    limited knowledge of recently learning Flutter, the design of the source code differs from that the documents, as I developed the
    code the best way that I could, given my limited knowledge of Flutter and Dart.
  
  Since each exercise has to be manually written into a file that is read, there are a limited amount of muscle groups and exercises available.
    Exercise data is stored in time_for_gym/ExerciseData.txt.

  In addition, due to budget constraints and simplicity, I chose to not use a Microsoft SQL server or have user accounts and store user
    data through Flutter's "User Preferences", as there was a minimal amount of data that needed to be stored. Exercise data is read from
    a file stored in this GitHub repository.

  During development, I chose to organize most of the .dart files by the page that they displayed.
    Some notes about the project structure compared to the SAS document:

    - main.dart is similar to the "Controller" class.
    
    - The page .dart files are similar to the "UserInterface" class; it made more sense to me to break them up into the different pages.
    
    - Exercise.dart is the same as the "Exercise" class.
    
    - The "MuscleGroup" class was simply implemented in main.dart as a map from the muscle group name (String)
        to a list of exercises (List<Exercise>) for that muscle group.
        
    - There are no "UserAccount" and "Authenticate" classes, as there is no sign-up or log-in required in the implementation.
    
    - The "GymCounter" class was implemented in main.dart for simplicity, as the current gym occupancy was just taken from the UM gym website.
    
    - Since we need vast amount of data to accurately predict gym occupancies for each time of the week, that chart cannot be displayed.
        Instead, users can input their perceived gym percent capacity into the app. This data is stored in a Google Firebase database.
        Ideally, enough data will be collected in the future so that a chart could be made for gym occupancy prediction.
        
    - Any component of the application that was not mentioned previously behaves as expected and was implemented according to the specifications.


Installation
-------------
Currently, this application is not available on any mobile app stores due to budget restraints and can only be deployed to a phone
through a cable connection.


Credits
--------
This project was develeoped by Ross Stewart, and designed by Ross Stewart and James Johnson
