# Aces-iOS
Aces app for Apple users

Latest changes not uploaded yet:

- Lots of bug fixes
- Tracks cancelled/completed rides much better
- Much better looking UI
- Loading disc when signing in
- Search is now done via local database that I entered manually, instead of google’s servers
- Search is on the same screen rather than on a new screen so it takes less time to get there
- When tapping to change number of riders, can tap anywhere to release focus/prevents user from 
  having the selector open while also searching a location, requesting ride, or sliding the map
- Wayyy better memory management. Whenever going to a new screen, it goes back to a previously 
  created one (and sets everything to blank) if there is one, rather than creating a new one every time.
