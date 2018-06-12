class InvalidResolution extends Exception
{
  public InvalidResolution()
  {
    println("Cannot create map due to invalid resolution. (Screen Width - 1) % resolution and (Screen Height - 1) % resolution must be zero");
  }
}   

class Grid
{
 public Cell[][] cells;
 
 public PImage cross;
 public PImage nought;
 
 private int res;
 
 private int cellRows;
 private int cellCols;
 
 Grid(int screenWidth, int screenHeight, int res) throws InvalidResolution
 {
   this.res = res;
   
   if((screenWidth - 1) % res == 0 && (screenHeight - 1) % res == 0) // must be replaced by throwing an exception
   {
     cellCols = screenWidth / res;
     cellRows = screenHeight / res;  
     
     // populate Cells
     cells = new Cell[cellCols][];
     for(int col = 0; col < cellCols; col++)
     {
       cells[col] = new Cell[cellRows];
       
       for(int row = 0; row < cellRows; row++)
       {
         cells[col][row] = new Cell(new Coordinate(col * res, row * res)); 
       }
     }
   }
   else
   {
     throw new InvalidResolution();
   }
 }
 
 private void drawCells() 
 { 
   stroke(0);
   fill(255); //set default color white
   for(Cell[] cellCol : cells)
   {
     for(Cell cell : cellCol)
     {     
       rect(cell.pos.x, cell.pos.y, res, res);
       
       if(cell.type == CellType.CROSS)
       {
         image(cross, cell.pos.x, cell.pos.y, res, res);
       }
       else if(cell.type == CellType.NOUGHT)
       {
         image(nought, cell.pos.x, cell.pos.y, res, res);
       }
     }   
   }
}
 
 public void drawMap()
 {
   drawCells();
 }
 
 public void loadSprites(String crossPath, String noughtPath)
 {
   try
   {
     cross = loadImage(crossPath);
     nought = loadImage(noughtPath);
   }
   catch(Exception e)
   {
     System.out.println("Sprites for tic-tac-toe load failed!");
   }
 }
 
 public Cell[] neighborCells(Cell cell, int mode)
 {
   int colId = cell.pos.x / res;
   int rowId = cell.pos.y / res;
   return neighborCells(colId, rowId, mode);
 }
 
 public Cell[] neighborCells(int rowId, int colId, int mode)
 {
   ArrayList<Cell> neighbors = new ArrayList<Cell>();
   for(int i = -1; i < 2; i++)
   {
       for(int j = -1; j < 2; j++)
       {
         if (abs(i) == abs(j))
         {
           if(i == 0 || mode == 0)
           {
             continue;
           }
         }
         
         if((colId + i) < 0 || (rowId + j) < 0 || (colId + i) >= cellCols || (rowId + j) >= cellRows)
         {
           continue;
         }
         
         neighbors.add(cells[colId + i][rowId + j]);
       }
   }
   
   Cell[] result = new Cell[neighbors.size()];
   neighbors.toArray(result);
   return result;
 }
 
 public Cell retrieveCell(int x, int y)
 {
  return cells[x / res][y / res]; 
 }  
 
 public void clicked(int mX, int mY, CellType type) // will add sprite
 {
   Cell cell = retrieveCell(mX, mY);
   cell.type = type;
 }
 
 public Grid deepCopy()
 {
   Grid newGrid;
   try
   {
     newGrid = new Grid(this.cellCols * this.res + 1, this.cellRows * this.res + 1, this.res);
   }
   catch(InvalidResolution e)
   {
     return null;
   }
   
   for(int col = 0; col < this.cellCols; col++) // no need to copy coordinate because they are the same
   {
     for(int row = 0; row < this.cellRows; row++)
     {
       newGrid.cells[col][row].type = this.cells[col][row].type;
       newGrid.cells[col][row].pos = new Coordinate(cells[col][row].pos.x, cells[col][row].pos.y);
     }
   }
   
   return newGrid;
 }
}
