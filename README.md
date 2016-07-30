# OnTheMap

OnTheMap is an application that shows the user Udacity students' name, professional website, and location on a map view and a list view, and allows the user to add or update their own locations. 

This app is one of the Udacity iOS Development nanodegree assignments. It incorporates Udacity API and [Parse API](https://parseplatform.github.io) to retrieve and update students information.

##View Controller Scenes
###LoginViewController
LoginViewController is the initial view when the app first launches. It shows two ways of signing into the app, one is through Udacity e-mail, the other is Facebook sign in. I used [FBSDKLoginManager](https://developers.facebook.com/docs/reference/ios/4.8/class/FBSDKLoginManager/) frame work to implement the Facebook login feature. A session is created for the authenticated user.

###OnTheMapTabBarViewController
OnTheMapTabBarViewController is what shows up next when the user signs in. The tab bar's top navigation bar contains a logout button, a refresh button, and a pin button. When the pin button is pressed. PostLocationViewController, which I will explain later, is presented. 

###MapViewController
MapViewController displays a map using MapKit framework. It displays multiple pins, each one representing a student's current location. When the a is selected, an annotation would appear showing the student's name and website. 

###StudentsListTableViewController
StudentsListViewTableController shows the same student information as MapViewController but in a different form. It's arranged in a table view of student names. When a cell is selected, the app would re-direct the user to Safari displaying the website associated with that student. 

###PostLocationViewController
As mentioned above, PostLocationViewController is presented when the pin button on tab bar is pressed. PostLocationViewController has multiple layers of views. The first visible views contains UILabel with text prompting the user to type in their current location in text. When press the Find It Button, the current view would become hidden and the below layer of view, a map view with a pin located at the location specified by the user just now, would show up. There's a prompt here asking user to enter a personal website url string. When the Submit button is pressed, PostLocationViewController is dismissed and the user sees the MapViewController with updated pin within it. Note that as the user enters updated information, a POST HTTP request is sent to perform the update.


##Credits
Leqi Long

##Contacts
longleqi89@gmail.com