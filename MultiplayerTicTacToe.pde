Grid grid;

public static final int RESOLUTION = 20;
boolean started = true;

void setup()
{
  size(301, 301);
  
  try
  {
    grid = new Grid(width, height, RESOLUTION);
    grid.loadSprites("sprites/cross.png", "sprites/nought.png");
  }
  catch (InvalidResolution e)
  {
    started = false;
  }
}

void draw()
{
  if(started)
  { 
    grid.drawMap();
  }
}

void mouseClicked()
{
  if(mouseButton == LEFT)
  {
    grid.clicked(mouseX, mouseY, CellType.CROSS);
  }
  else if(mouseButton == RIGHT)
  {
    grid.clicked(mouseX, mouseY, CellType.NOUGHT);
  }
}
