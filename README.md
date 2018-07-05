# TestApp
PhotoLocations

Assumptions and Description of behavior:
* App supports iPhone/iPod UI, with Portrait orientation
* The minimal Deployment Target is iOS 11.3
* The app does not provide an ability to move or delete already saved locations
* The app download default locations from the Internet, if download failed the app will load default locations from bundle.
* The app has no limitations regarding a number of the number of locations
* New location saving: 
>>> 1. Press to (+) button. Location will be added to the current user position - this logic could be easily changed
>>> 2. Set location more accurately if it is necessary by dragging map view (Annotation will be set on senter)
>>> 3. Press (+) button on annotation or press (v) button
>>> 4. Details screen will be opened with prefilled location name "New"
>>> 5. To save the location user shold press "Save" button, or press "Cancel" if he don't want to save it
>>> 6. User is able to cancel creation by pressing (x)
 * The app provide an ability to add only a one note for a location.
 * The app provide an ability to edit notes for all saved locations
 
