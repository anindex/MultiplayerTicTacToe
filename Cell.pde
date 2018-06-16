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
  
  public String toString()
  {
    return x + "," + y;
  }
}

class MarkedCoordinate extends Coordinate
{
  public CellType type;
  
  MarkedCoordinate()
  {  
    super();
  }
  
  MarkedCoordinate(int x, int y)
  {  
    super(x, y);
  }
  
  public void print()
  {
    System.out.println(type + " x: " + x + ", y: " + y);
  }
  
  public String toString()
  {
    if(type == CellType.CROSS)
    {
      return "C-" + super.toString();
    }
    else if(type == CellType.NOUGHT)
    {
      return "N-" + super.toString();
    }
    else
    {
      return super.toString();
    }
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
