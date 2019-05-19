## Watch Your Head

This is a game that uses OpenCV to detect where your face is using your computer's webcam.
The aim of the game is to avoid as many falling balls as possible. If your head touches a ball you lose!

### Current Bugs:

- If more than 5 faces are being detected at a given time memory is consumed very fast and can lead to crashes.
- No validation is in place to check if the user has a webcam before running.
- When first booting up the program, the program may time out. Simply restart the program to fix.
- If multiple faces are detected when playing the game, only one of those will collide with the balls.

### Planned Features / Changes:

- Reduce the rate of which facial detection takes place to improve performace.
- Allow multiple people to play at the same time.
- Limit detection past 5 faces.
