// Experiment in Illegibility: Connected to Midi
  // The text: See text document inside of data folder
  
// Turn knobs/dials to max value before starting


// Global variables
 
import themidibus.*;
float cc[] = new float[256];
MidiBus myBus;

int index = 0;
int timer = 1000; // Gives the first word a head start so it can be seen the first time through.


void setup() {
  //fullScreen();
  size(1270,500);
  //size(500,500);
  textAlign(CENTER, CENTER);
  background(255);
  noStroke();
  //frameRate(30);  // Set to above 60 (or 30 for vid) when you want it to go faster than one change each frame (frameCount can't be fractional)
  
  // Setting up midi controller
  MidiBus.list();  // Shows controllers in the console
  myBus = new MidiBus(this, "SLIDER/KNOB","CTRL");  // input and output
  
  for (int i = 0; i < cc.length; i++) {
    cc[i] = 127;
  }
}
  
                   // NOTE!
                  // Take these out completely because they are not reliable containers for all the different knobs.
//int number;            // They save the value of the last knob/slider/etc. that got touched.
//int value;      // We probably mixed two tutorials that weren't compatible.
  
  
void draw() {
  
// ORGANIZATION?:
  // Should we keep these midi controls together here, put the controls where they are implemented (i.e. speed below w/ speed setting), or make objects?

// --------------------
// ALPHA CONTROL: for fade  
  float alphaControl = map(cc[16],0,127,0,255);
  fill(255,alphaControl);  // fills screen-sized rectangle (below) with white w/ opacity determined by midi
  rect(0,0,width,height);
// --------------------
// SPEED CONTROL: how often to change the word (if (frameCount % speed == 0...)) 
  int speedControl = round(map(cc[17],0,127,10,1));  // Shouldn't be float b/c % 0
// --------------------
// TEXT BOX SIZE CONTROL: how much of the screen text should take up (in box)
  float boxSizeControl = map(cc[18],0,127,0.1,1);
// --------------------
// MAX SIZE CONTROL: changing the biggest font sizes to match b/w short and long words
      // The fraction of the screen height to allow the font to be (if short word)
  float fontSizeControl = map(cc[19],0,127,0.1,1);
// --------------------
// FONT SELECTION
  PFont[] font = {loadFont("Monaco-500.vlw"), loadFont("OCRAStd-500.vlw"),
                  loadFont("Impact-500.vlw"), loadFont("Helvetica-500.vlw"),
                  loadFont("Palatino-Roman-500.vlw"), loadFont("Wingdings2-500.vlw"),
                  loadFont("SynchroLET-500.vlw")};
// --------------------
  
  
  // Put dyslexic scrambler in function/object because it's messy.
          // Could set scramble strength in a scramble class
  // Only make functions/objects for things that are long and have a lot of data... 
          // Easy ones (speed, box size, etc) can stay here.
  
  
  // Create array of words from a text file
  String[] document = loadStrings("Tao.txt");   // Calls the text file from your data folder and loads it (by line breaks) into an array.
  String joinLines = join(document, " ");   // joins together what would otherwise be each line in a different spot in an array into one long string
  String[] words = split(joinLines, " ");   // splits paragraph (long single string) at spaces (" ") into different cells
  
  //PFont font = loadFont("Monaco-500.vlw");
  fill(0);
  float fontSize = 100;
  textFont(font[int(random(font.length-1))], fontSize);
  float maxSizeW = fontSize/textWidth(words[index]) * (width*boxSizeControl);
  float maxSizeH = fontSize/(textDescent()+textAscent()) * (height*boxSizeControl);
          // Make sure that space from top and bottom edge depends on ascenders and descenders + arbitrary space constant
          // SHIFT THE MAX BOUNDARY, NOT THE OVERALL SCALE

  fontSize = (min(maxSizeW, maxSizeH));   // Reset fontSize to be the smaller of the two possible maximums for height and width
  fontSize = min(fontSize, fontSizeControl*height*boxSizeControl);

// HOW DO I GET IT TO CYCLE THROUGH FONTS AND SIZE TEXT ACCORDINGLY FOR DIFFERENT FONTS?
  
    // CHANGE BY frameCount
  if (frameCount % speedControl == 0) {  // every nth frame
      for (int i = 0; i <= font.length-1; i++) {
        textFont(font[i], fontSize);
      } 
    // Draw Text
    text(words[index], width/2, (height/2)-50);  // Places text in middle of window.
    index ++;  // advance one word
  }
  
  /*  // CHANGE BY TIME                         
  if (millis() - timer >= 500)   // use millis() and a timer to change the word every [# of milliseconds]
  {
    index ++;
    timer = millis();  // helps keep track of how much time has passed since last change
  }  */

   
  // Show how much time has ellapsed
      // Clean up with white background box
      // Call this function only when a button is pressed
  textSize(18);
  text(millis()/1000 + " seconds have passed since the start", 250,50); 
  text("you are in frame: " + frameCount,250,85);

   
  // Restart paragraph from beginning.
  if(index == words.length)
        index = 0;     
}

                       // midi #  (ex:) knob #    # from knob, mapped to be b/w 0 and 1
  void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
  //this.value = value;       // "this" refers (in Porcessing) to variables in the global space if this function is in the global space
  //this.number = number;     // Took these out b/c not reliable (mixed tutorials badly)
  //cc[number] = map(value, 0, 127, 0, 1);
  cc[number] = value;  // saves the midi output # to be converted later for what we need
}

boolean pauseToggle = true;

void keyPressed() {
   if (key == 'p' || key == 'P') {  // PAUSE
     if (pauseToggle) { noLoop(); pauseToggle = false; }
     else { loop(); pauseToggle = true; }
  }
  
   if (key == 'r' || key == 'R') {  // RESTART
     index = 0; }
  
}
