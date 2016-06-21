// Experiment in Illegibility: Connected to Midi
  // The text: See text document inside of data folder  


// Global variables

import themidibus.*;  // the library
float cc[] = new float[256]; // Array can hold up to 256 values. Remembers values from midi
MidiBus myBus;

int index = 0;   // Used near the end to count through the array and to know when to start over
int timer = 1000; // Gives the first word a head start so it can be seen the first time through.

//float alpha = map(mouseX,0,width, 0, 255);


void setup() {
  //fullScreen();
  //size(1270,500);     // Window size
  size(500,500);      // For testing the textWidth constraint
  textAlign(CENTER, CENTER);    // Centers the text on the coordinate where told to draw
  background(255);
  noStroke();
  //frameRate(30);  // Set to above 60 (or 30 for vid) when you want it to go faster than one change each frame (frameCount can't be fractional)
  
  // Setting up midi controller
  MidiBus.list();  // Shows controllers in the console
  myBus = new MidiBus(this, "SLIDER/KNOB","CTRL");  // input and output
}
  
                   // NOTE!
int number;  // In Processing 3, these valiable declarations 
int value;       // must be in global, not setup or draw
  
void draw() {
  
// ORGANIZATION?:
  // Should we keep these midi controls together here, put the controls where they are imlemented (i.e. speed below w/ speed setting), or make objects?

// --------------------
// ALPHA CONTROL: for fade 
    // Used to be float alpha = map(mouseX,0,width, 0, 255);
  if(number == 16){
    float alpha = map(value,0,127,0,255);
    fill(255,alpha);  // fills screen-sized rectangle (below) with white w/ opacity determined by midi
    rect(0,0,width,height);
  }
              // OR  
  /*float alpha = cc[16]*map(value,0,127,0,255);
  fill(255,alpha);  // fills screen-sized rectangle (below) with white w/ opacity determined by midi
  rect(0,0,width,height);*/
  
// --------------------
// SPEED CONTROL: how often to change the word (if (frameCount % speed == 0...)) 
  //float speed = cc[17]*map(value,0,127,0,10);  // Edit 10 to find a good max speed.  Lower # = faster/change more often
                // OR  
  float speed = 1;
  if(number == 17){
    speed = cc[17]*map(value,0,127,1,10);  // Edit 10 to find a good max speed.  Lower # = faster/change more often
  }   // Do speed and alpha override each othr? Why are they freezing up?

// --------------------
// SIZE CONTROL: text size when dialed down from maximum for screen 
  //float sizeControl = cc[18]*map(value,0,127,0,10);  // Edit 50 to find a good parameter.  Higher # = smaller max text size... Reverse to be more intuitive?
                // OR  
  float sizeControl = 1;
  if(number == 18){
    sizeControl = cc[18]*map(value,0,127,2,50);  // Edit 50 to find a good parameter.  Higher # = smaller max text size... Reverse to be more intuitive?
  }


  
  // Create array of words from a text file
  String[] document = loadStrings("Tao.txt");   // Calls the text file from your data folder and loads it (by line breaks) into an array.
  String joinLines = join(document, " ");   // joins together what would otherwise be each line in a different spot in an array into one long string
  String[] words = split(joinLines, " ");   // splits paragraph (long single string) at spaces (" ") into different cells
    // Those last two steps are important especially if you have multiple paragraphs with line breaks.
    // This example code uses only one paragraph, but it's formatted for use with any text file.
  
  PFont font = loadFont("Monaco-500.vlw");
  
  fill(0);  // Set paragraph text color to black

  float fontSize = 100;      // set an arbitrary font size for the next calculations
  textFont(font, fontSize);  // set above fontSize as the size to use for textWidth, textDescent, and textAscent calculations
  //float maxSizeW = fontSize/textWidth(words[index]) * (width-(width/20));          // maximum font size to fit in the frame width-wise with a bit of space
  //float maxSizeH = fontSize/(textDescent()+textAscent()) * (height-(height/10));   // maximum font size to fit in the frame height-wise with a bit of space
  float maxSizeW = fontSize/textWidth(words[index]) * (width-(width/sizeControl));          // maximum font size to fit in the frame width-wise with a bit of space
  float maxSizeH = fontSize/(textDescent()+textAscent()) * (height-(height/(sizeControl)));   // maximum font size to fit in the frame height-wise with a bit of space
          // Make sure that space from top and bottom edge depends on ascenders and descenders + arbitrary space constant

  fontSize = (min(maxSizeW, maxSizeH));   // Reset fontSize to be the smaller of the two possible maximums for height and width
  textFont(font, fontSize); 
  
  // also scale text by mouseY
  float scale = map(mouseY, height,0, 0.1f, 1.0f);
  textFont(font, fontSize*scale); 

  // Draw Text
  text(words[index], width/2, (height/2)-50);  // Places text in middle of window.
                                        // MAKE DESCENDERS NOT FALL OFF BOTTOM... Not hardcoded, preferably
                                        // Keep different font ascenders/descenders in mind
  
  
  /*  // CHANGE BY TIME                         
  if (millis() - timer >= 500)   // use millis() and a timer to change the word every [# of milliseconds]
  {
    index ++;
    timer = millis();  // helps keep track of how much time has passed since last change
  }  */

  // CHANGE BY frameCount
  if (frameCount % speed == 0)   // every nth frame
    index ++;
   
   
  // Show how much time has ellapsed
      // Clean up with white background box
      // Call this function only when a button is pressed
  textSize(18);
  text(millis()/1000 + " seconds have passed since the start", 250,50); 
  text("you are in frame: " + frameCount,250,85);

   
  // Restart paragraph from beginning.
  if(index == words.length)   // When index reaches the end of the text (length of array), start over
  {
    
            //frameRate(0.6);  // Adds a pause before restarting
    index = 0;       // Sets index back to 0 to start from the beginning of the text
  }  
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
  this.value = value;
  this.number = number;
  cc[number] = map(value, 0, 127, 0, 1);
}