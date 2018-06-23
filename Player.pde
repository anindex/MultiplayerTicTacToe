class Player
{
  public int win;
  public int lose;
  
  public String name;
  
  public Coordinate lastMove;
  public CellType markType; // depend on current setting 
  
  Player()
  {
    this.win = 0;
    this.lose = 0;
    
    this.name = "BLANK";
    lastMove = new Coordinate();
  }
  
  public void reset()
  {
    this.win = 0;
    this.lose = 0;
    
    lastMove = new Coordinate();
  }
  
  public String print()
  {
    return this.name + ","  + String.valueOf(this.win);
  }
}
