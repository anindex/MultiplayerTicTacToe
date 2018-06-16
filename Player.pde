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
    
    this.name = "";
    lastMove = new Coordinate();
  }
}
