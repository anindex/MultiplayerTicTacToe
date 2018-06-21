import g4p_controls.*;

Grid grid;
GameEngine game;
Player player;
HostScanner scanner;

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
    
    scanner = new HostScanner();
  }
  catch (InvalidResolution e)
  {
    started = false;
  }
 
  createGUI();
  window1.setVisible(false);
  window2.setVisible(false);
  
  if(scanner != null)
  {
    label1.setText("Your IP: " + scanner.serverAddress);
  }
  
  server.start();
  scanner.start();
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
    if(server.serverStatus.state == ServerState.MATCHING)
    {
      server.processGameTurn(mouseX, mouseY);
    }
  }
}
