import g4p_controls.*;

Grid grid;
GameEngine game;
Player player;

public static final int RESOLUTION = 20;
boolean started = true;

void setup()
{
  size(601, 601, JAVA2D);
  
  try
  {
    grid = new Grid(width, height, RESOLUTION);
    grid.loadSprites("sprites/cross.png", "sprites/nought.png");
    
    player = new Player("anindex");
    player.markType = CellType.CROSS;
    
    game = new GameEngine(grid, player);
  }
  catch (InvalidResolution e)
  {
    started = false;
  }
  
  createGUI();
}

void draw()
{
  if(started)
  { 
    game.gameState.drawMap();
  }
}

void mouseClicked()
{
  if(mouseButton == LEFT)
  {
    game.gameState.clicked(mouseX, mouseY, CellType.CROSS);
    game.player.lastMove = game.gameState.retrieveCellIndex(mouseX, mouseY);
    game.player.lastMove.print();
  }
  else if(mouseButton == RIGHT)
  {
    game.gameState.clicked(mouseX, mouseY, CellType.NOUGHT);
  }
}
