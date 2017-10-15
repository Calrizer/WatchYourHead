//Watch Your Head v1.0

//Libraries used.

import gab.opencv.*;
import processing.video.*;
import processing.sound.*;
import java.awt.*;
import java.util.concurrent.ThreadLocalRandom;

Capture video; //Stores output from the device camera.
OpenCV opencv; //OpenCV instance used for image processing.

enum LevelNames {
  WELCOME, TUTORIAL, MAINLEVEL, LOST //Enum outlining the types of level.
}

LevelNames level = LevelNames.WELCOME; //Sets initial level context to WELCOME.

//Globals for UI operations...

//Title variables.

int titleY = 0;
int startY = 0;
boolean isUp = false;

//Tutorial variables.

Ball tutorialBall;
int tutorialProgression = 0;
String message = "Let's get started...";
float arcProgress = 0;

//Warning image variables.

PImage warning;
float warningOpacity = 100;
boolean isUpWarning = false;

//Sound file variables.

SoundFile beep;
SoundFile woosh;
SoundFile ouch;

//Main game variables.

boolean gameInPlay = false;
int preGameProgression = 0;
int currentBall = 0;
int score = 0;

ArrayList<Ball> balls = new ArrayList<Ball>();

//Game setup...

void setup() {

  size(640, 360, P3D);

  frameRate(60);

  titleY = (height / 2) - 25;
  startY = (height / 2) + 30;

  video = new Capture(this, 640, 360); //Stores the capture from the users webcam in video object.
  opencv = new OpenCV(this, 640, 360); //Creates new OpenCV object.
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); //Loads cascase xml file for facial detection.

  //Assigning files to their variables.

  warning = loadImage("warning.png");

  beep = new SoundFile(this, "beep.mp3");
  woosh = new SoundFile(this, "woosh.mp3");
  ouch = new SoundFile(this, "splat.mp3");

  tutorialBall = new Ball(width / 2, 0, 30, 0); //Creates new Ball object for the tutorial.

  //Iterates to create 999 Ball objects.

  for (int i = 0; i < 999; i++) {

    balls.add(new Ball(ThreadLocalRandom.current().nextInt(50, width - 50), 0, 30, 0)); //Appends new Ball object to balls ArrayList. Gentrates random x position.

  }

  video.start(); //Starts capturing video from users webcam.

}

//Called 60 times a second to render to the screen.

void draw() {

  //Checks each level context and calls appropriate method for the current level.

  switch (level) {

  case WELCOME:
    welcome();
    break;

  case TUTORIAL:
    tutorial();
    break;

  case MAINLEVEL:
    mainLevel();
    break;

  case LOST:
    lost();
    break;

  }

}

//Stub for using video capture.

void captureEvent(Capture c) {

  c.read();

}

//Method for showing the welcome screen to the user.

void welcome() {

  image(video, 0, 0); //Renders user's webcam output to the screen.

  //Adds rectangles with 90% opacity over the users webcam output.

  fill(0, 90);
  rect(0, 0, width, height);
  rect(0, 0, width, height);
  rect(0, 0, width, height);
  rect(0, 0, width, height);

  //Loads and configures new font.

  PFont font = createFont("main.ttf", 70);
  textFont(font);
  textAlign(CENTER, CENTER);

  //Renders text to the screen.

  fill(12, 136, 222);
  text("WATCH YOUR HEAD!", width / 2, (titleY) - 25);
  fill(222, 12, 12);
  text("WATCH YOUR HEAD!", (width / 2) - 4, (titleY) - 25);
  textSize(30);
  fill(255);
  text("Press any key to begin...", width / 2, (startY) + 30);

  //Animates the titles to hover up and down.

  if (isUp) {
    titleY--;
    startY--;
    if (titleY <= ((height / 2) - 25) - 5) isUp = false;
  } else {
    titleY++;
    startY++;
    if (titleY >= ((height / 2) - 25) + 5) isUp = true;
  }

}

//Method for allowing the user to complete the tutorial.

void tutorial() {

  //Renders user's webcam output to the screen.

  clear();
  noTint();
  image(video, 0, 0);

  opencv.loadImage(video); //Loads the users webcam output into OpenCV.
  Rectangle[] faces = opencv.detect(); //Tests user's webcam output against facial detection cascase, then stores detected faces in an array of Java Rectangles.

  //Tests for multiple faces.

  boolean multipleFaces = false;

  if (faces.length > 1) {
    multipleFaces = true;
    stroke(255, 0, 0);
  } else {
    stroke(0, 255, 0);
  }

  strokeWeight(2);
  noFill();

  //Iterates over the faces detected.

  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height, 20); //Renders rectangles around the detected faces.
  }

  //Adds rectangles with 90% opacity over the screen.

  noStroke();
  fill(0, 90);
  rect(0, 320, width, 40);
  rect(0, 320, width, 40);
  rect(0, 320, width, 40);
  rect(0, 320, width, 40);

  noFill();
  stroke(255);
  strokeWeight(2);

  //Detects how far the user has progressed over the tutorial.

  switch (tutorialProgression) {

  case 0:

    arc(width - 25, height - 20, 20, 20, 0, arcProgress, OPEN); //Renders an arc as a timer.

    //Animates the arc counting down.

    if (arcProgress < 7) {
      arcProgress = arcProgress + 0.25;
    } else {
      tutorialProgression = 1;
      arcProgress = 0;
    }

    break;

  case 1:

    message = "Make sure you are the only face in the frame..."; //Sets message.

    arc(width - 25, height - 20, 20, 20, 0, arcProgress, OPEN);

    if (multipleFaces) arcProgress = 0; //Resets arc timer if multiple faces are detected.

    if (arcProgress < 7) {
      arcProgress = arcProgress + 0.25;
    } else {
      tutorialProgression = 2;
      arcProgress = 0;
    }

    break;

  case 2:

    message = "When you see this warning a ball is about to fall!";

    arc(width - 25, height - 20, 20, 20, 0, arcProgress, OPEN);

    displayWarning(width / 2); //Displays and animates warning icon where ball will fall.

    if (multipleFaces) arcProgress = 0;

    if (arcProgress < 7) {
      arcProgress = arcProgress + 0.25;
    } else {
      tutorialProgression = 3;
      arcProgress = 0;
    }

    break;

  case 3:

    tutorialBall.updatePosition(width / 2, 0); //Sets initial position for the ball that will fall.

    message = "Make sure to move out of the way!";

    arc(width - 25, height - 20, 20, 20, 0, arcProgress, OPEN);

    displayWarning(width / 2);

    if (multipleFaces) arcProgress = 0;

    if (arcProgress < 7) {
      arcProgress = arcProgress + 0.25;
    } else {
      tutorialProgression = 4;
      woosh.play();
      arcProgress = 0;
    }

    break;

  case 4:

    message = "INCOMING!";

    //Sets up and renders the falling ball to the screen.

    fill(tutorialBall.getColour());
    noStroke();
    ellipse(tutorialBall.getPosition().x + 15, tutorialBall.getPosition().y, 40, 40);

    tutorialBall.move(); //Moves the ball.

    //Detects if there is a face present and if the face hitbox touches the ball make user retry.

    if (faces.length > 0) {
      if (hasTouched(tutorialBall.getPosition(), new PVector(faces[0].x, faces[0].y), faces[0].width, faces[0].height)) {
        tutorialProgression = 5;
        ouch.play();
      }
    }

    //When ball leaves the screen, continue with the tutorial.

    if (tutorialBall.getPosition().y > height) {
      tutorialProgression = 6;
    }

    break;

  case 5:

    message = "Ouch! Let's try that again.";

    arc(width - 25, height - 20, 20, 20, 0, arcProgress, OPEN);

    if (multipleFaces) arcProgress = 0;

    if (arcProgress < 7) {
      arcProgress = arcProgress + 0.25;
    } else {
      tutorialProgression = 3;
      arcProgress = 0;
    }

    break;

  case 6:

    message = "Great! Looks like you are ready to play.";

    arc(width - 25, height - 20, 20, 20, 0, arcProgress, OPEN);

    if (multipleFaces) arcProgress = 0;

    if (arcProgress < 7) {
      arcProgress = arcProgress + 0.25;
    } else {
      tutorialProgression = 0;
      arcProgress = 0;
      level = LevelNames.MAINLEVEL; //Tutorial complete, start full game.
    }

  }

  //Sets up and renders text to the screen.

  textSize(24);
  textAlign(CENTER, CENTER);
  fill(255);

  text(message, width / 2, height - 20);

}

//Method for running the full game.

void mainLevel() {

  clear();
  image(video, 0, 0);

  //Detects if the countdown has completed.

  if (gameInPlay) {

    opencv.loadImage(video); //Loads the users webcam output into OpenCV.
    Rectangle[] faces = opencv.detect(); //Tests user's webcam output against facial detection cascase, then stores detected faces in an array of Java Rectangles.

    if (faces.length > 1) {
      stroke(255, 0, 0);
    } else {
      stroke(0, 255, 0);
    }

    strokeWeight(2);
    noFill();

    //Iterates over the faces detected.

    for (int i = 0; i < faces.length; i++) {
      rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height, 20); //Renders rectangles around the detected faces.
    }

    //Detects if the current ball ready to drop is not the first ball.

    if (currentBall > 0) {

      displayWarning(balls.get(currentBall).getPosition().x); //Displays the warning where the next ball will drop.

      Ball fallingBall = balls.get(currentBall - 1); //Sets the falling ball to the previous ball generated.

      //Sets up and renders the ball to the screen.

      fill(fallingBall.getColour());
      noStroke();
      ellipse(fallingBall.getPosition().x + 15, fallingBall.getPosition().y, 40, 40);

      fallingBall.move(); //Moves the falling ball.

      //Detects if there is a face detected and if the user's hitbox has collided with the falling ball.

      if (faces.length > 0) {
        if (hasTouched(fallingBall.getPosition(), new PVector(faces[0].x, faces[0].y), faces[0].width, faces[0].height)) {
          ouch.play();
          level = LevelNames.LOST; //Stops the game and shows the user their score.
        }
      }

    } else {

      displayWarning(balls.get(0).getPosition().x); //Displays a warning where the ball will drop.

    }

    //Increases the current ball and users score every ten frames.

    if (frameCount % 10 == 0) {

      currentBall++;
      score = currentBall - 1;

    }

    //Sets up and renders the users score to the screen.

    PFont font = createFont("digital.otf", 20);
    textFont(font);
    textAlign(CENTER, CENTER);
    fill(255);
    text(score, 30, 30);

  } else {

    //Increases the countdown every sixty frames.

    if (frameCount % 60 == 0) {

      preGameProgression++;

    }

    //Sets up countdown titles.

    PFont font = createFont("main.ttf", 70);
    textFont(font);
    textAlign(CENTER, CENTER);

    //Displays the correct message corresponding to the countdown time.

    switch (preGameProgression) {

    case 0:

      fill(12, 136, 222);
      text("READY?", width / 2, height / 2);
      fill(222, 12, 12);
      text("READY?", (width / 2) - 4, height / 2);
      break;

    case 1:

      fill(12, 136, 222);
      text("THREE", width / 2, height / 2);
      fill(222, 12, 12);
      text("THREE", (width / 2) - 4, height / 2);

      break;

    case 2:

      fill(12, 136, 222);
      text("TWO", width / 2, height / 2);
      fill(222, 12, 12);
      text("TWO", (width / 2) - 4, height / 2);

      break;

    case 3:

      fill(12, 136, 222);
      text("ONE", width / 2, height / 2);
      fill(222, 12, 12);
      text("ONE", (width / 2) - 4, height / 2);

      break;

    case 4:

      fill(12, 136, 222);
      text("GO!", width / 2, height / 2);
      fill(222, 12, 12);
      text("GO!", (width / 2) - 4, height / 2);
      gameInPlay = true;

      break;
    }

  }

}

//Method for displaying when the user has lost the game.

void lost() {

  clear();
  image(video, 0, 0);

  fill(0, 90);
  rect(0, 0, width, height);
  rect(0, 0, width, height);
  rect(0, 0, width, height);
  rect(0, 0, width, height);

  //Sets up and displays the users score and loss title.

  PFont font = createFont("main.ttf", 70);
  textFont(font);
  textAlign(CENTER, CENTER);
  fill(12, 136, 222);
  text("OUCH!", width / 2, (titleY) - 25);
  fill(222, 12, 12);
  text("OUCH!", (width / 2) - 4, (titleY) - 25);
  font = createFont("digital.otf", 14);
  textFont(font);
  fill(255);
  text("You dodged " + score + " balls! Press any key to retry", width / 2, (startY) + 30);

  //Animates the title and score.

  if (isUp) {
    titleY--;
    startY--;
    if (titleY <= ((height / 2) - 25) - 5) isUp = false;
  } else {
    titleY++;
    startY++;
    if (titleY >= ((height / 2) - 25) + 5) isUp = true;
  }
}

//Function for detecting if the user's hitbox has touched a ball.

boolean hasTouched(PVector ballPosition, PVector playerPosition, float playerWidth, float playerHeight) {

  if (ballPosition.x > playerPosition.x && ballPosition.x < playerPosition.x + playerWidth && ballPosition.y > playerPosition.y && ballPosition.y < playerPosition.y + playerHeight) {
    return true;
  }

  return false;

}

//Method for displaying and animating ball warnings.

void displayWarning(float x) {

  if (isUpWarning) {
    warningOpacity = warningOpacity + 30;
    if (warningOpacity >= 100) isUpWarning = false;
  } else {
    warningOpacity = warningOpacity - 30;
    if (warningOpacity <= 0) isUpWarning = true;
  }

  tint(255, warningOpacity);
  image(warning, x - 15, 20, 30, 30);
  noTint();

}

//Method for resetting the balls for the next game.

void resetBalls(){

  balls.clear();

  for (int i = 0; i < 999; i++) {

    balls.add(new Ball(ThreadLocalRandom.current().nextInt(50, width - 50), 0, 30, 0));

  }

}

//Method for detecting when the user clicks a key.

void keyPressed() {

  //Checks each level context and sets a new level context.

  switch (level) {

  case WELCOME:
    level = LevelNames.TUTORIAL;
    break;

  case TUTORIAL:
    level = LevelNames.MAINLEVEL;
    break;

  case LOST:
    level = LevelNames.MAINLEVEL;
    score = 0;
    currentBall = 0;
    resetBalls();
    break;

  }

}
