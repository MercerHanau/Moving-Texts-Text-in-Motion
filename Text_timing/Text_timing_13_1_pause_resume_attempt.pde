// Experiment in Illegibility: Connected to Midi
  // The text: See text document inside of data folder
  
// Turn knobs/dials to max value before starting


/*  Change log:

  Set midi button #64 (first [R] button on left) to turn text red as long as it is pressed
  
  Changed from fontSpeedControl to fontSelect (not cycling through fonts but now set with dial)
  
  
  TO DO:
  
    Move pause, resume, and restart to midi
    
    State change on [o] for always red.
      Maybe make the quick red do something else if state red is active?
      
    Get console to say font name, not just number
  
    Now so efficient I had to increase the speed range to slow it down!
        Alpha: 255 alpha at this speed it WAY too powerful, wipes things out 'til they can't be seen.
     
    Rearrange code to restore multiple font changes on each word?

*/


// Global variables  
 
import themidibus.*;
float cc[] = new float[256];
MidiBus myBus;

int wordIndex = 0;
int tempWordIndex = wordIndex;
int fontIndex = 0;
int fontSelect = 0;  // To show in console which font is being used
boolean pauseToggle = true;

String[] words;
PFont[] fonts;
int timer = 1000; // Gives the first word a head start so it can be seen the first time through.


void setup() {
  fullScreen();
  //size(1270,500);
  //size(500,500);

  textAlign(CENTER, CENTER);
  background(255);
  noStroke();
  frameRate(30);  // Limits speed from over-optimization. Set to above 60 (or 30 for vid) when you want it to go faster than one change each frame (frameCount can't be fractional)
  
  // Setting up midi controller
  MidiBus.list();  // Shows controllers in the console
  myBus = new MidiBus(this, "SLIDER/KNOB","CTRL");  // input and output
  
  /*for (int i = 0; i < cc.length; i++) {  // Sets all controls to be max @ start
    cc[i] = 127;
  }*/
  for (int i = 0; i < 24; i++) {  // Sets only the knobs (16-23) and sliders (0-7) to be max @ start
    cc[i] = 127;
  }
  
  
  // Create array of words from a text file
  String[] document = loadStrings("Tao.txt");   // Calls the text file from your data folder and loads it (by line breaks) into an array.
  String joinLines = join(document, " ");   // joins together what would otherwise be each line in a different spot in an array into one long string
  words = split(joinLines, " ");   // splits paragraph (long single string) at spaces (" ") into different cells


  // Array of font names
  //String[] fontNames = {"Palatino-Roman-500.vlw", "Helvetica-500.vlw", "Impact-500.vlw", "Monaco-500.vlw",
  //                      "OCRAStd-500.vlw", "SynchroLET-500.vlw", "Wingdings2-500.vlw"};
  String[] fontNames = {"Wingdings2-500.vlw", "SynchroLET-500.vlw", "Monaco-500.vlw", "OCRAStd-500.vlw", 
                        "Impact-500.vlw", "Helvetica-500.vlw", "Palatino-Roman-500.vlw"};
                          // ADD LUCIDA FONTS RELATED TO WINGDINGS?

  // Array of actual fonts, loaded using names in array above
  fonts = new PFont[fontNames.length];   // Make its size match the # of fonts

  // Loads all the fonts into the array
  for (int i = 0; i < fontNames.length; i++) {
    fonts[i] = loadFont(fontNames[i]);
  }  
}
  
  
void draw() {
  
// ORGANIZATION?:
  // Should we keep these midi controls together here, put the controls where they are implemented (i.e. speed below w/ speed setting), or make objects?

// --------------------
// ALPHA CONTROL: for fade  
  float alphaControl = map(cc[16],0,127,0,255);
  //fill(255,alphaControl);  // Moved these to where the text is being drawn
  //rect(0,0,width,height);
// --------------------
// SPEED CONTROL: how often to change the word (if (frameCount % speed == 0...)) 
  int speedControl = round(map(cc[17],0,127,30,1));  // Shouldn't be float b/c % 0
// --------------------
// TEXT BOX SIZE CONTROL: how much of the screen text should take up (in box)
  float boxSizeControl = map(cc[18],0,127,0.1,1);
// --------------------
// MAX SIZE CONTROL: changing the biggest font sizes to match b/w short and long words
      // The fraction of the screen height to allow the font to be (if short word)
  float fontSizeControl = map(cc[19],0,127,0.1,1);
// --------------------
// FONT SELECTION
  //int fontSpeedControl = round(map(cc[20],0,127,500,10));  // This is for changing the speed at which the fonts cycle rather than custom selection
  fontSelect = round(map(cc[20],0,127,0,fonts.length-1));  // Pick font based on dial
                                                                // Rearrange fonts in array for logical progression
// --------------------
// QUICK RED: text is red as long as the button is pushed
  // This is now in the loop that draws text and the background
  // Maybe make this a function? Doesn't matter if it's here. I just like having all our "effects" together here
  // ADD ALTERNATE FUNCTION, i.e. BG SHIFT, IF RED STATE IS ACTIVE
// --------------------
// PAUSE
  if (cc[42] == 127) {
     if (pauseToggle) { 
       noLoop();                  // Don't use noLoop: can't resume
       pauseToggle = false; 
     }    
     else { 
       loop(); 
       pauseToggle = true; 
     }
  }
// --------------------
// RESTART: Go back to the beginning of the text
   if (cc[46] == 127) {  
     wordIndex = 0; }
  
  
  
  // CALCULATE MAX FONT SIZE
  float fontSize = 100;   // arbitrary, just for calculating correct size below
  textFont(fonts[fontSelect], fontSize);   // Tell the computer that size for the following calculations
  float maxSizeW = fontSize/textWidth(words[wordIndex]) * (width*boxSizeControl);
  float maxSizeH = fontSize/(textDescent()+textAscent()) * (height*boxSizeControl);

  fontSize = (min(maxSizeW, maxSizeH));   // Reset fontSize to be the smaller of the two possible maximums for height and width
  fontSize = min(fontSize, fontSizeControl*height*boxSizeControl);
  textSize(fontSize);
  
  
  // CHANGE BY frameCount
  if (frameCount % speedControl == 0) {     // every n'th frame
    
    // BG fade layer draws whenever text draws
    fill(255,alphaControl);  // fills screen-sized rectangle (below) with white w/ opacity determined by midi
    rect(0,0,width,height);
    
    // QUICK RED
    if (cc[64] == 127)  // If the value of button # 64 ([R]) is 127 (pushed)
      fill(200,0,0);    // make the fill color red
    else fill(0);
    //fill(0);  // Make text black (after white BG)
    text(words[wordIndex], width/2, (height/2)-30);  // Draws text in middle of window.
    wordIndex ++;  // advance one word

    
    // Check if it's time to restart text from beginning
    if(wordIndex == words.length)
      wordIndex = 0;  
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
  textSize(16);
  fill(200);
  text(millis()/1000 + " seconds have passed since the start", 250,50); 
  text("you are in frame: " + frameCount,250,85);
   
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
  println("Frame rate:"+frameRate);
  //println("Font:"+fontNames[fontSelect]);   // How can I get it to say the font name, not just the #?
  println("Font number:"+fontSelect);
  cc[number] = value;  // saves the midi output # to be converted later for what we need
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}


/*
boolean pauseToggle = true;

void keyPressed() {  // no longer keyPressed? Is there something else for midi buttons?
   if (cc[42] == 127) {  // PAUSE
     if (pauseToggle) { noLoop(); pauseToggle = false; }
     else { loop(); pauseToggle = true; }
  }
  
   if (cc[46] == 127) {  // RESTART
     wordIndex = 0; }
}



// RED STATE: toggle red text off and on
  boolean redToggle = true;   // start as not red

void keyPressed() {
  if (cc[45] == 127) {
    if (redToggle == true) {
      fill(200,0,0);
      redToggle = false;
    }
    else {
     fill(0);
     redToggle = true;
    }
  }
}
*/