enum CellType {BLANK, NOUGHT, CROSS};

class Coordinate
{
  public int x;
  public int y;
  
  Coordinate()
  {
    this.x = 0;
    this.y = 0;
  }
  
  Coordinate(int x, int y)
  {
    this.x = x;
    this.y = y;
  }
  
  public void print()
  {
    System.out.println("x: " + x + ", y: " + y);
  }
}


class Cell
{ 
  public CellType type;
  public Coordinate pos;
  
  Cell(Coordinate pos)
  { 
    this.type = CellType.BLANK;
    this.pos = pos;
  }
  
  Cell(Coordinate pos, CellType type)
  {
    this.type = type;
    this.pos = pos;
  }
}
