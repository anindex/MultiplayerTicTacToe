import g4p_controls.*;

Grid grid;
GameEngine game;
Player player;

ConnectionEngine server;

public static final int RESOLUTION = 20;
boolean started = true;

void setup()
{
  size(601, 601, JAVA2D);
  
  try
  {
    grid = new Grid(width, height, RESOLUTION);
    grid.loadSprites("sprites/cross.png", "sprites/nought.png");
    
    player = new Player();
    player.markType = CellType.CROSS;
    
    game = new GameEngine(grid, player);
    
    server = new ConnectionEngine(game);
  }
  catch (InvalidResolution e)
  {
    started = false;
  }
 
  createGUI();
  window1.setVisible(false);
  window2.setVisible(false);
  
  server.run();
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
  }
  else if(mouseButton == RIGHT)
  {
    game.gameState.clicked(mouseX, mouseY, CellType.NOUGHT);
  }
}
