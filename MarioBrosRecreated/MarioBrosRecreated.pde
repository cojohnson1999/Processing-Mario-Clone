/**
 * MarioBrosProject - A working version of World 1-1 from Super Mario Bros
 * functioning within Processing.  
 *
 * By Cody Johnson and Jack Li
 * December 11, 2019
 */

import processing.sound.*;
import java.awt.Rectangle;

import oscP5.*;
import netP5.*;

//Links to sprites found on https://www.spriters-resource.com/nes/supermariobros/sheet/50365/
//Links to sound effects at https://themushroomkingdom.net/media/smb/wav

//Level and sound variables
SoundFile theme, deathSF, stageClearSF, jumpSF;
PImage level;

//Addressing methods to gain access to Pure Data
OscP5 oscP5;
NetAddress puredata;

//States for Mario to have depending on user input
String idle_r = "mario-r-standing.png", idle_l = "mario-l-standing.png";
String run_r1 = "mario-r-run1.png",     run_r2 = "mario-r-run2.png",    run_r3 = "mario-r-run3.png";       
String run_l1 = "mario-l-run1.png",     run_l2 = "mario-l-run2.png",    run_l3 = "mario-l-run3.png";
String jump_r = "mario-r-jump.png",     jump_l = "mario-l-jump.png";
String crouch_r = "mario-r-crouch.png", crouch_l = "mario-l-crouch.png"; 
String[] mario_run_r = new String[3];
String[] mario_run_l = new String[3];
int delay = 25;
int loopMillis = 0;
int run_i = 0; //Runs through the animations as a pseudo-loop with the two variables above

//Declaration of Mario (player object)
PImage mario; 

//Variables for Mario (player)
boolean facingR = true;
boolean jumping = false;
boolean collidedL = false;
boolean collidedR = false;
boolean dead = false;
boolean deathSFPlayed = false;
boolean stageClearSFPlayed = false;

//Movement
float playerX = 100;
float playerY = 400;
float playerSpeedX = 0;
float playerSpeedY = 0;
float nextX;
float nextY;
float playerHeight;
float playerWidth;
float runSpeed = 3;
float groundY = 400;

//Scene-based variables
float sceneX = 0, sceneY = 0; //Moves the image along as the player advances through the level
float windowX = 800, windowY = 448; //Length and width of the window
float middleWindowX = windowX/2; //Keeps track of middle of window
final int sceneWidth = 6784, sceneHeight = 448; //Params of the level
float endOfLevel = 0; //Gauges the location of the left side of the window along the scene

//Declaration of ArrayList containing the rectangles that make up the entire level
ArrayList<Rectangle> collision = new ArrayList<Rectangle>();



void setup() {
  size(800,448);

  //The object that sends the messages to Pure Data
  oscP5 = new OscP5(this, 12000);
  //Pure Data's net address
  puredata = new NetAddress("127.0.0.1", 9001);
  
  //Load theme to play repeatedly
  theme = new SoundFile(this, "SuperMarioBros.mp3");
  theme.amp(0.4);
  theme.play();
  theme.loop();
  
  //Level and Mario setup
  level = loadImage("World1-1-BG.png");
  level.loadPixels();
  level.resize(sceneWidth, sceneHeight); //Makes the level image twice as big for better viewing
  mario = loadImage(idle_r);
  playerHeight = mario.height; 
  playerWidth = mario.width;
  
  //Load frames for run animations
  mario_run_r[0] = run_r1;
  mario_run_r[1] = run_r2; 
  mario_run_r[2] = run_r3;
  mario_run_l[0] = run_l1;
  mario_run_l[1] = run_l2; 
  mario_run_l[2] = run_l3;
  
  
  //All rectangle collision boxes for every obstacle in the level
  collision.add(new Rectangle(0, (int)groundY, 2207, 48));    //ground 1
  collision.add(new Rectangle(2272, (int)groundY, 480, 48));  //ground 2
  collision.add(new Rectangle(2848, (int)groundY, 2048, 48)); //ground 3
  collision.add(new Rectangle(4960, (int)groundY, 1824, 48)); //ground 4
  
  //collision.add(new Rectangle(0, 0, 1, (int)windowY));     //left boundary box
  
  //Adds all of the other objects in the level in as they appear sequentially
  collision.add(new Rectangle(512, 272, 32, 32));             //q block 1
  collision.add(new Rectangle(704, 144, 32, 32));             //q block 2
  collision.add(new Rectangle(640, 272, 160, 32));            //combo block 1
  collision.add(new Rectangle(896, 336, 64, 64));             //pipe 1
  collision.add(new Rectangle(1216, 304, 64, 96));            //pipe 2
  collision.add(new Rectangle(1472, 272, 64, 128));           //pipe 3
  collision.add(new Rectangle(1824, 272, 64, 128));           //pipe 4
  collision.add(new Rectangle(2464, 272, 96, 32));            //combo block 2
  collision.add(new Rectangle(2560, 144, 256, 32));           //bricks 1
  collision.add(new Rectangle(2912, 144, 128, 32));           //combo block 3
  collision.add(new Rectangle(3008, 272, 32, 32));            //bricks 2
  collision.add(new Rectangle(3200, 272, 64, 32));            //bricks 3
  collision.add(new Rectangle(3392, 272, 32, 32));            //q block 3
  collision.add(new Rectangle(3488, 272, 32, 32));            //q block 4
  collision.add(new Rectangle(3584, 272, 32, 32));            //q block 5
  collision.add(new Rectangle(3488, 144, 32, 32));            //q block 6
  collision.add(new Rectangle(3776, 272, 32, 32));            //bricks 4
  collision.add(new Rectangle(3872, 144, 96, 32));            //bricks 5
  collision.add(new Rectangle(4096, 144, 128, 32));           //combo block 4
  collision.add(new Rectangle(4128, 272, 64, 32));            //bricks 6
  
  //The stair objects at the end of the level
  collision.add(new Rectangle(4288, 368, 32, 32));            //stair 1 piece 1
  collision.add(new Rectangle(4320, 336, 32, 64));            //stair 1 piece 2
  collision.add(new Rectangle(4352, 304, 32, 96));            //stair 1 piece 3
  collision.add(new Rectangle(4384, 272, 32, 128));           //stair 1 piece 4
  
  collision.add(new Rectangle(4480, 272, 32, 128));           //stair 2 piece 1
  collision.add(new Rectangle(4512, 304, 32, 96));            //stair 2 piece 2
  collision.add(new Rectangle(4544, 336, 32, 64));            //stair 2 piece 3
  collision.add(new Rectangle(4576, 368, 32, 32));            //stair 2 piece 4
  
  collision.add(new Rectangle(4736, 368, 32, 32));            //stair 3 piece 1
  collision.add(new Rectangle(4768, 336, 32, 64));            //stair 3 piece 2
  collision.add(new Rectangle(4800, 304, 32, 96));            //stair 3 piece 3
  collision.add(new Rectangle(4832, 272, 64, 128));           //stair 3 piece 4
  
  collision.add(new Rectangle(4960, 272, 32, 128));           //stair 4 piece 1
  collision.add(new Rectangle(4992, 304, 32, 96));            //stair 4 piece 2
  collision.add(new Rectangle(5024, 336, 32, 64));            //stair 4 piece 3
  collision.add(new Rectangle(5056, 368, 32, 32));            //stair 4 piece 4
  
  collision.add(new Rectangle(5216, 336, 64, 64));            //pipe 5
  collision.add(new Rectangle(5376, 272, 128, 32));           //combo block 5
  collision.add(new Rectangle(5728, 336, 64, 64));            //pipe 6
  
  collision.add(new Rectangle(5792, 368, 32, 32));            //last stair piece 1
  collision.add(new Rectangle(5824, 336, 32, 64));            //last stair piece 2
  collision.add(new Rectangle(5856, 304, 32, 96));            //last stair piece 3
  collision.add(new Rectangle(5888, 272, 32, 128));           //last stair piece 4
  collision.add(new Rectangle(5920, 240, 32, 160));           //last stair piece 1
  collision.add(new Rectangle(5952, 208, 32, 192));           //last stair piece 2
  collision.add(new Rectangle(5984, 176, 32, 224));           //last stair piece 3
  collision.add(new Rectangle(6016, 144, 64, 256));           //last stair piece 8
}





void draw() {
  //Draws the level image on the screen, scrolls
  image(level, sceneX, sceneY);
  
  //Change the X and Y values of the player by the current respective speeds
  playerX += playerSpeedX;
  playerY += playerSpeedY;
  
  //Check for character death
  if(playerY > windowY) {
    dead = true;
  }
  
  //Adds a constant -1 to player speed to keep the player moving with the level scrolling
  if(!dead && !jumping && endOfLevel + windowX <= sceneWidth-5) {
    playerSpeedX = -1;
  }
  
  //If Mario dies, play the sound effect
  if(dead) {
    playerSpeedX = 0;
    if(!deathSFPlayed) {
      theme.stop();
      oscP5.send(new OscMessage("/oscP5/deathsf"), puredata);
      deathSFPlayed = true;
    }
  }
  
  if( !(endOfLevel + windowX <= sceneWidth-5) && !stageClearSFPlayed ) {
    theme.stop();
    oscP5.send(new OscMessage("/oscP5/winsf"), puredata);
    stageClearSFPlayed = true;
  }
  
  //Makes the screen and collision boxes of the objects move automatically
  if(!dead && endOfLevel + windowX <= sceneWidth-5) {
    sceneX -= 1;
    endOfLevel += 1;
    
    //Moves all of the collision boxes in the ArrayList
    for(int i = 0; i < collision.size(); i++) {
      Rectangle rectangle = collision.get(i);
      rectangle.translate(-1, 0);
    }
  }
  
  //Check for key inputs, control character
  //Only move if player is alive
  if(!dead) {
    if(keyPressed) {
      //Player moves left, move them -1 extra to give them equivalent speed to right movement
      if(keyCode == LEFT) {
        playerSpeedX = -runSpeed-1;
      }
      //Player moves right at the normal run speed
      if(keyCode == RIGHT) {
        playerSpeedX = runSpeed;
      }
    }
  }
  
  //Checks for collision STRICTLY on the large chunks of ground, no other objects
  for(int i = 0; i < 4; i++) {
    Rectangle rectangle = collision.get(i);
    
    //Checks for collision with the ground
    if (playerY + playerHeight > rectangle.y &&
        playerX < rectangle.x + rectangle.width &&
        playerX + playerWidth > rectangle.x) {

      //Snap the player's bottom to the ground's y position
      playerY = groundY - playerHeight;

      //Stop the player falling
      playerSpeedY = 0;

      //Allows jumping again
      jumping = false;
    }
    //Player is not colliding with the ground
    else {
      //Gravity accelerates the movement speed
      playerSpeedY = playerSpeedY + 0.25; //+0.25 to account for running through the loop 4 times each time, technically +1
    }
  }
  
  //Checks for collision on every other object other than the ground chunks
  for(int i = 4; i < collision.size(); i++) {
    Rectangle rectangle = collision.get(i);
    //Check X collision
    if(playerX + playerWidth + playerSpeedX > rectangle.x && 
       playerX + playerSpeedX < rectangle.x + rectangle.width && 
       playerY + playerHeight > rectangle.y && 
       playerY < rectangle.y + rectangle.height) {
        
      //Check if player is left of object
      if(playerX < rectangle.x) {
        playerSpeedX = -1; //-1 to make player follow the constant -1 of the screen and not get stuck in objects
      }
      //Player is right of the object
      else {
        playerSpeedX = 0; //Player gets stopped
      }
    }

    //Check Y collision
    if(playerX + playerWidth > rectangle.x && 
       playerX < rectangle.x + rectangle.width && 
       playerY + playerHeight + playerSpeedY > rectangle.y && 
       playerY + playerSpeedY < rectangle.y + rectangle.height) {

      //Stops player on top of the platform
      playerSpeedY = 0;
       
      //Player is allowed to jump again
      jumping = false;
    }
    
    //Bug Testing to show collision boxes commented out
    //fill(255,0,0);
    //rect(rectangle.x, rectangle.y, rectangle.width, rectangle.height); //Create the visual collision boxes
  }
  
  //Create the player at the X and Y values given after running through draw and the conditions
  image(mario, playerX, playerY);
}




//Used to control animations of the player when pressing a key
void keyPressed() {
  if(!dead) {
    if(keyCode == LEFT) {
      facingR = false;
      //Player can't be jumping if you want to show the run cycle
      if(!jumping) { 
      
        //Animates the player's run movements with a (loopMillis) millisecond interval
        if(millis() - loopMillis > delay && run_i < 3) {
          mario = loadImage(mario_run_l[run_i]);
          run_i++;
        }
        //Resets "loop"
        else {
          run_i = 0;
        }
        //Get the new value of loopMillis from the current millis() time
        loopMillis = millis();
      }
      //If player is jumping left, show it
      else {
        mario = loadImage(jump_l);
      }
    }
  
    //If the player is facing right 
    if(keyCode == RIGHT) {  
      facingR = true;

      if(!jumping) {
        //Animates the player's run movements with a (loopMillis) millisecond interval
        if(millis() - loopMillis > delay && run_i < 3) {
          mario = loadImage(mario_run_r[run_i]);
          run_i++;
        }
        //Resets the "loop"
        else {
          run_i = 0;
        }
        //Gets the new value of loopMillis
        loopMillis = millis();
      }
      //Player is jumping right, show it!
      else {
        mario = loadImage(jump_r);
      }
    }
  
    //Shows player jumping
    if(keyCode == UP) {
      //You can only jump if you aren't already jumping
      if (!jumping) {
        //Plays the jump sound effect when the user jumps
        oscP5.send(new OscMessage("/oscP5/jumpsf"), puredata);
        //The player is facing right, show them jumping right
        if(facingR) {
          mario = loadImage(jump_r);
        }
        //The player is facing left, show them jumping left
        else {
          mario = loadImage(jump_l);
        }
        //going up at -17.5
        playerSpeedY = -17.5;
        //Disallow jumping while already jumping
        jumping = true;
      }
    }
  
    //Allows player to crouch if they aren't jumping
    if(keyCode == DOWN && !jumping) {
      //Player is facing right, show the crouching that way
      if(facingR) {
        mario = loadImage(crouch_r);
      }
      //Player is facing left, show them crouching left
      else {
        mario = loadImage(crouch_l);
      }
      //While the screen is still scrolling
      if(endOfLevel + windowX <= sceneWidth-5) {
        //Makes the player speed -1 to match the level scrolling, crouching makes them stop
        playerSpeedX = -1;
      }
    }
  }
}





void keyReleased() {
  
  if(keyCode == LEFT) {
    playerSpeedX = 0; //If we release left, the player needs to stop moving left
    run_i = 0; //Resets the animation number on the run cycle to fully reset it
    
    //If they're not jumping, show their idle animation left
    if(!jumping) {
      mario = loadImage(idle_l);
    }
  }
  
  if(keyCode == RIGHT) {
    playerSpeedX = 0; //If we release right, we need to stop the right movement
    run_i = 0; //Resets the animation number on the cycle to fully reset it
    
    //If they're not jumping, show their idle animation right
    if(!jumping) {
      mario = loadImage(idle_r);
    }
  }
  
  //If you release down
  if(keyCode == DOWN) {
    
    //If you're facing right and you're not jumping, show the idle animation right
    if(facingR && !jumping) {
      mario = loadImage(idle_r);
    }
    //If you're facing left and not jumping, show the idle animation left
    else if(!facingR && !jumping){
      mario = loadImage(idle_l);
    }
  }
}
