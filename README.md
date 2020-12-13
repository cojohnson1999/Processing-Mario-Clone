# ProcessingMarioClone
A rudimentary, partial recreation of the first level of Super Mario Bros using the Java-based programming interface, Processing.  Sound is implemented using Processing package connections to Pure Data.

# Requirements
PureData requires the mrpeach library in order to connect the sounds to the actions specified in Processing.
Processing requires the oscP5 and netP5 libraries in order to connect with Pure Data.

# Details
All rights to the Nintendo properties within this project are owned by Nintendo.  This project was a proof-of-concept for game creation within Processing.  

Pure Data connection within this app requires open ports on your machine, specified by the lines of code within the application.  To change these, simply enter new port numbers within their setup calls in the code.

# Running
In order to run everything concurrently, open the .pd file and leave it open.  It controls the sound effects from the inputs, so you want to make sure it's open while running the Processing program.  Also make sure your sound is at a reasonable level.  Pure Data doesn't normalize sounds unless you make it, so it can get pretty loud...

But from there, run the program, and everything should run smoothly!
