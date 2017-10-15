/*

Class for handling falling balls.

I have accomodated for the possibility of the balls being able to fall from
the top, left and right of the screen. However currently balls only fall from
the top of the screen.

*/

class Ball {

  PVector pos; //Stores ball position.
  PVector velocity; //Stores ball velocity.
  int direction; //Stores the direction where the ball will fall from.
  color colour; //Stores balls colour. Good thing colour isn't a reserved word :)

  //Constructor method for instanciating the ball.

  Ball(float x, float y, float speed, int dir) {

    pos = new PVector(x, y);

    float vx = 0;
    float vy = 0;

    //Applies the correct velocity for the ball based on it's direction.

    switch (dir) {

    case 0:
      vy = speed;
      vx = 0;
      break;
    case 1:
      vy = 0;
      vx = speed;
    case 2:
      vy = 0;
      vx = -speed;

    }

    velocity = new PVector(vx, vy);

    colour = color(random(255),random(255),random(255));

  }

  //Accessor method to return the ball's position vector.

  PVector getPosition() {

    return pos;

  }

  //Accessor method to return the ball's velocity vector.

  PVector getVelocity() {

    return velocity;

  }

  //Accessor method to return the ball's colour.

  color getColour() {

    return colour;

  }

  //Method for moving the ball.

  public void move() {

    updatePosition(getPosition().x + getVelocity().x, getPosition().y + getVelocity().y);

  }

  //Modifier method for updating the ball's postion.

  public void updatePosition(float x, float y) {

    pos.set(x, y);

  }
  
}
