enum GameCondition {DRAW, WIN, LOSE, CONTINUE};

class GameEngine //this class is singleton
{
  public Grid gameState;
  public Player player;
  
  public boolean inTurned;
  
  public int spaceLeft;
  
  public GameEngine(Grid gameState, Player player)
  {
    this.gameState = gameState;
    this.player = player;
    
    inTurned = true;
    spaceLeft = gameState.cells.length * gameState.cells[0].length;
  }
  
  public GameCondition checkEndGame()
  {
    if(inTurned)
    {
      spaceLeft--;
      
      int w = gameState.cells.length;
      int h = gameState.cells[0].length;
      
      //check y
      int line = 0;
      for(int i = -4; i <= 4; i++)
      {
         if(player.lastMove.y + i >= 0 && player.lastMove.y + i < h)
         {
            if(gameState.cells[player.lastMove.x][player.lastMove.y + i].type == player.markType)
            {
              line++;
              if(line == 5)
              {
                return GameCondition.WIN;
              }
            }
            else
            {
              line = 0;
            }
         }
      }
      
      //check x
      line = 0;
      for(int i = -4; i <= 4; i++)
      {
         if(player.lastMove.x + i >= 0 && player.lastMove.x + i < w)
         {
            if(gameState.cells[player.lastMove.x + i][player.lastMove.y].type == player.markType)
            {
              line++;
              if(line == 5)
              {
                return GameCondition.WIN;
              }
            }
            else
            {
              line = 0;
            }
         }
      }
      
      //check diagonal
      line = 0;
      for(int i = -4; i <= 4; i++)
      {
         if(player.lastMove.x + i >= 0 && player.lastMove.x + i < w && player.lastMove.y + i >= 0 && player.lastMove.y + i < h)
         {
            if(gameState.cells[player.lastMove.x + i][player.lastMove.y + i].type == player.markType)
            {
              line++;
              if(line == 5)
              {
                return GameCondition.WIN;
              }
            }
            else
            {
              line = 0;
            }
         }
      }
      
      //check anti-diagonal
      line = 0;
      for(int i = -4; i <= 4; i++)
      {
         if(player.lastMove.x - i >= 0 && player.lastMove.x - i < w && player.lastMove.y + i >= 0 && player.lastMove.y + i < h)
         {
            if(gameState.cells[player.lastMove.x - i][player.lastMove.y + i].type == player.markType)
            {
              line++;
              if(line == 5)
              {
                return GameCondition.WIN;
              }
            }
            else
            {
              line = 0;
            }
         }
      }
      
      if(spaceLeft == 0)
      {
        return GameCondition.DRAW;
      }
    }
    
    return GameCondition.CONTINUE;
  }
  
  public void name_change()
  {
    this.player.name = textfield2.getText();
  }
}
