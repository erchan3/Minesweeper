import de.bezier.guido.*;
//Declare and initialize constants NUM_ROWS and NUM_COLS = 20
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines = new ArrayList<MSButton>(); //ArrayList of just the minesweeper buttons that are mined
private static int NUM_ROWS = 20;
private static int NUM_COLS = 20;
private static int NUM_MINES = 50;
private boolean gameStarted = false;
private boolean gameOver = false;
private Text t;

public void reset() {
    for (int i = 0; i < buttons.length; i++) {
      for (int j = 0; j < buttons[i].length; j++) {
        buttons[i][j].reset();
      }
    }
  mines.clear();
  t.setText("");
  gameStarted = false;
  gameOver = false;
}


void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );
    
    //your code to initialize buttons goes here
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    for (int i = 0; i < buttons.length; i++) {
      for (int j = 0; j < buttons[i].length; j++) {
        buttons[i][j] = new MSButton(i, j);
      }
    }
    t = new Text();
    reset();
}
public void setMines()
{
  mines.clear();
    //your code
    while (mines.size() < NUM_MINES) {
      int r = (int)(Math.random() * NUM_ROWS);
      int c = (int)(Math.random() * NUM_COLS);
      if (!mines.contains(buttons[r][c])) {
        mines.add(buttons[r][c]);
      }
    }
    
}

public void draw ()
{
    background( 0 );
    if(!gameOver && isWon())
        displayWinningMessage();
}
public boolean isWon()
{
    //your code here
    for (int i = 0; i < buttons.length; i++) {
          for (int j = 0; j < buttons[i].length; j++) {
            if (!mines.contains(buttons[i][j]) && !buttons[i][j].clicked) { // a button that isn't a mine hasn't been clicked so no win yet
              return false;
            }
          }
        }
    return true;
}
public void displayLosingMessage()
{
    //your code here
    gameOver = true;
    for (int i = 0; i < buttons.length; i++) {
      for (int j = 0; j < buttons[i].length; j++) {
        buttons[i][j].unflag();
        buttons[i][j].mousePressed();
      }
    }
    t.setText("YOU LOSE");
}
public void displayWinningMessage()
{
    //your code here
    gameOver = true;
    // unflag everything
    for (int i = 0; i < buttons.length; i++) {
      for (int j = 0; j < buttons[i].length; j++) {
        buttons[i][j].unflag();
      }
    }
    // set mines to clicked since everything not mine is clicked
    for (int i = 0; i < mines.size(); i++) {
      mines.get(i).clickMe();
    }
    t.setText("YOU WIN");
}
public boolean isValid(int r, int c)
{
    //your code here
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}
public int countMines(int row, int col)
{
    int numMines = 0;
    //your code here
    for (int i = row - 1; i <= row + 1; i++) {
      for (int j = col - 1; j <= col + 1; j++) {
        if (isValid(i, j) && mines.contains(buttons[i][j])) {
          numMines++;
        }
      }
    }
    if (mines.contains(buttons[row][col])) {
      numMines--;
    }
    return numMines;
}
public class MSButton
{
    private int myRow, myCol;
    private float x,y, width, height;
    private boolean clicked, flagged;
    private String myLabel;
    
    public MSButton ( int row, int col )
    {
        width = 400/NUM_COLS;
        height = 400/NUM_ROWS;
        myRow = row;
        myCol = col; 
        x = myCol*width;
        y = myRow*height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add( this ); // register it with the manager
    }
    
    public void reset() {
      myLabel = "";
      flagged = clicked = false;
    }

    // called by manager
    public void mousePressed () 
    {
      if (clicked) return;
      if (mouseButton == LEFT) {
        // do nothing if left click flagged square
        if (flagged) return;
        
        // at the start of the game set mines so the first click hits an empty square
        if (!gameStarted) {
          while (true) {
            setMines();
            if (!(mines.contains(this)) && countMines(myRow, myCol) == 0) {
              break;
            }
          }
          gameStarted = true;
        }
        
        // in game logic part stuffs
        clicked = true;
        if (mines.contains(this)) { // you died
          displayLosingMessage();
        }
        int numMines = countMines(myRow, myCol);
        if (numMines == 0) { // no mines so click around recursively
          for (int i = myRow - 1; i <= myRow + 1; i++) {
            for (int j = myCol - 1; j <= myCol + 1; j++) {
              if (isValid(i, j)) {
                // because the mousePressed function returns immediately if clicked already
                // I don't have to check now
                buttons[i][j].mousePressed();
              }
            }
          }
        } else if (!mines.contains(this)) { // otherwise label number of mines
          myLabel = "" + numMines;
        }
      } else if (mouseButton == RIGHT && !clicked) {
        flagged = !flagged;
      }
    }
    public void draw () 
    {    
        if (flagged)
            fill(0);
         else if( clicked && mines.contains(this) ) 
             fill(255,0,0);
        else if(clicked)
            fill( 200 );
        else 
            fill( 100 );

        rect(x, y, width, height);
        fill(0);
        textSize(15);
        text(myLabel,x+width/2,y+height/2);
    }
    public void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }
    public void setLabel(int newLabel)
    {
        myLabel = ""+ newLabel;
    }
    public boolean isFlagged()
    {
        return flagged;
    }
    public void clickMe() {
      clicked = true;
    }
    public void unflag() {
      flagged = false;
    }
}

public class Text {
  public String text_;
  public Text() {
    text_ = "";
    Interactive.add(this);
  }
  public void draw() {
    textSize(60);
    fill(0);
    text(text_, 200, 200);
  }
  public void setText(String t) {
    text_ = t;
  }
  // guido complains when this doesn't exist
  public boolean isInside(float mx, float my) {
    return false;
  }
}
