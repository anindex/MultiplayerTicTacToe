enum ServerState {
  STANDBY, MATCHING, SPECTATOR
};
enum ConnectionType {
  UNKNOWN, MATCHING, SPECTATOR
};
enum ClientRequest
{
  GET_SERVER_STATUS, GET_GAME_STATE, GET_GAME_UPDATE, BYE
};


class ConnectionHandler extends Thread
{
  private Socket socket;

  public Scanner receiveLine;
  public PrintWriter sendLine;

  public String hostname; //hostname of the target host
  public ConnectionType type;

  public GameEngine game;

  public ArrayList<ConnectionHandler> clients; // for broadcasting last move of opponent

  public ServerStateRef serverStatus;

  public static final int PROMT_TIMEOUT = 3;

  public boolean isInitiator;
  public boolean answeredChallenge;
  public boolean connected;

  public ConnectionHandler(Socket socket, ServerStateRef serverStatus, GameEngine game, ArrayList<ConnectionHandler> clients, boolean isInitiator)
  {
    this.socket = socket;
    this.hostname = socket.getInetAddress().getHostName();

    this.type = ConnectionType.UNKNOWN;
    this.serverStatus = serverStatus;

    this.game = game;

    this.clients = clients;

    this.isInitiator = isInitiator;
    this.answeredChallenge = false;
    this.connected = false;

    try
    {
      receiveLine = new Scanner(socket.getInputStream());
      sendLine = new PrintWriter(socket.getOutputStream(), true);
    }
    catch(Exception e)
    {
      e.printStackTrace();
      System.out.println("Connection to " + this.hostname + " failed! Connection will close!");
      close();
    }
  }

  public void handshake() // handshake for knowing each other states, need synchronized to prevent data race
  {
    try
    {
      //these line of codes for testing client request messages
      //sendLine.println(ClientRequest.GET_SERVER_STATUS);      
      //ClientRequest handshakeRequest = ClientRequest.valueOf(receiveLine.nextLine().toUpperCase());
      //sendLine.println(processRequest(handshakeRequest));

      sendLine.println(processRequest(ClientRequest.GET_SERVER_STATUS));
      String response = receiveLine.nextLine();
      System.out.println(response);

      if (!processResponse(response))
      {
        System.out.println("Error on sending and receiving message! Connection will close!");
        close();
        this.connected = false; // for safety
      }
    }
    catch(Exception e)
    {
      e.printStackTrace();
      System.out.println("Connection to " + this.hostname + " failed! Connection will close!");
      close();
    }
  }

  public void run() //listen and maintain connections
  {
    while (this.connected)
    {
      String updateMessage = receiveLine.nextLine();

      processResponse(updateMessage);
    }
  }

  public void button_yes()
  {
    sendLine.println("YES");
    this.type = ConnectionType.MATCHING;
    this.serverStatus.state = ServerState.MATCHING;

    this.answeredChallenge = true;
    this.connected = true;

    window1.setVisible(false);
  }

  public void button_no()
  {
    sendLine.println("NO");
    close();

    this.answeredChallenge = true;

    window1.setVisible(false);
  }

  public void close()
  {
    if (this.receiveLine != null)
    {
      this.receiveLine.close();
    }

    if (this.sendLine != null)
    {
      this.sendLine.close();
    }

    if (this.socket != null)
    {
      try
      {
        this.socket.close();
      }
      catch(Exception e)
      {
        e.printStackTrace();
        System.out.println("Connection has error on closing!");
      }
    }
  }

  public String processRequest(ClientRequest request)
  {
    if (request == ClientRequest.GET_SERVER_STATUS)
    {
      return ConnectionEngine.RESPONSE_SERVER_STATUS + ":" + String.valueOf(this.serverStatus.state);
    } else if (request == ClientRequest.GET_GAME_STATE)
    {
      String gameState = ConnectionEngine.RESPONSE_GAME_STATE + ":";

      for (Cell[] cellCol : this.game.gameState.cells)
      {
        for (Cell cell : cellCol)
        {     
          if (cell.type == CellType.CROSS)
          {
            gameState += game.gameState.retrieveCellIndex(cell.pos).toString() + ";";
          }
        }
      }

      gameState += " ";

      for (Cell[] cellCol : this.game.gameState.cells)
      {
        for (Cell cell : cellCol)
        {     
          if (cell.type == CellType.NOUGHT)
          {
            gameState += game.gameState.retrieveCellIndex(cell.pos).toString() + ";";
          }
        }
      }

      return gameState;
    } else if (request == ClientRequest.GET_GAME_UPDATE)
    {
      return ConnectionEngine.RESPONSE_GAME_UPDATE + ":" + game.lastUpdate.toString();
    } else if (request == ClientRequest.BYE)
    {
      return "BYE:";
    } else
    {
      return ConnectionEngine.INVALID;
    }
  }

  public boolean processResponse(String response)
  {
    String[] message = response.split(":", 0);
    if (message[0].equals(ConnectionEngine.RESPONSE_SERVER_STATUS))
    {
      ServerState targetState = ServerState.valueOf(message[1].toUpperCase());
      if (this.serverStatus.state == ServerState.STANDBY && (targetState == ServerState.STANDBY || targetState == ServerState.SPECTATOR))
      {
        if (isInitiator)
        {
          sendChallenge();

          game.player.markType = CellType.NOUGHT;
        } else
        {
          promtChallenge(PROMT_TIMEOUT);

          game.player.markType = CellType.CROSS;
          game.inTurned = true;
        }
      } else if (this.serverStatus.state == ServerState.STANDBY && targetState == ServerState.MATCHING)
      {
        this.type = ConnectionType.SPECTATOR;
        this.serverStatus.state = ServerState.SPECTATOR;
        this.connected = true;

        processResponse(receiveLine.nextLine()); // update current game state
      } else if (this.serverStatus.state == ServerState.MATCHING && targetState == ServerState.STANDBY)
      {
        this.type = ConnectionType.SPECTATOR;
        this.connected = true;

        sendLine.println(processRequest(ClientRequest.GET_GAME_STATE));
      } else if (this.serverStatus.state == ServerState.SPECTATOR && targetState == ServerState.STANDBY)
      {
        promtChallenge(PROMT_TIMEOUT);
      }

      return true;
    } else if (message[0].equals(ConnectionEngine.RESPONSE_GAME_STATE))
    {
      game.gameState.clearMark(); // clear all to update the whole states

      String[] marks = message[1].split(" ", 0);
      String[] listOfCross = marks[0].split(";", 0);
      String[] listOfNought = marks[1].split(";", 0);

      for (int i = 0; i < listOfCross.length - 1; i++)
      {
        String[] cross = listOfCross[i].split(",", 0);
        game.gameState.cells[Integer.valueOf(cross[0])][Integer.valueOf(cross[1])].type = CellType.CROSS;
      }

      for (int i = 0; i < listOfNought.length - 1; i++)
      {
        String[] nought = listOfNought[i].split(",", 0);
        game.gameState.cells[Integer.valueOf(nought[0])][Integer.valueOf(nought[1])].type = CellType.NOUGHT;
      }

      return true;
    } else if (message[0].equals(ConnectionEngine.RESPONSE_GAME_UPDATE))
    {
      String[] markedCell = message[1].split("-", 0);
      String[] coord = markedCell[1].split(",", 0);
      int x = Integer.valueOf(coord[0]);
      int y = Integer.valueOf(coord[1]);

      if (markedCell[0].equals("C"))
      {
        game.gameState.cells[x][y].type = CellType.CROSS;
      } else if (markedCell[0].equals("N"))
      {
        game.gameState.cells[x][y].type = CellType.NOUGHT;
      }

      if (serverStatus.state == ServerState.MATCHING)
      {
        game.inTurned = true; //it's turn for the receiver

        for (ConnectionHandler viewer : clients)
        {
          if(viewer != this)
          {
            viewer.sendLine.println(viewer.processRequest(ClientRequest.GET_GAME_UPDATE)); // send move decision to all viewers
          }        
        }
      }

      return true;
    } else if (message[0].equals(ConnectionEngine.BYE))
    {
      close();
      this.connected = false;

      if (serverStatus.state == ServerState.SPECTATOR) // if MATCHING server disconnect this client, client turns to STANDBY 
      {
        serverStatus.state = ServerState.STANDBY;
      }

      return true;
    } else
    {
      return false;
    }
  }      

  private void sendChallenge()
  {
    if (sendLine != null && receiveLine != null)
    {
      sendLine.println(game.player.name); //introduce yourself

      String response = receiveLine.nextLine();
      if (response.equals("YES"))
      {
        this.type = ConnectionType.MATCHING;
        this.serverStatus.state = ServerState.MATCHING;
        this.connected = true;
      } else
      {
        close();
      }
    } else
    {
      System.out.println("Connection to " + this.hostname + " initialize failed! Connection will close!");
      close();
    }
  }

  private void promtChallenge(int timeout)
  {
    String challenger = receiveLine.nextLine();
    label4.setText(challenger + " want to challenge you!!! Accept?");
    window1.setVisible(true);

    int then = second();
    while ((second() - then < timeout) && !answeredChallenge);

    if (!this.connected && !answeredChallenge)
    {
      button_no();
      System.out.println("Challenge acceptance timeout!");
    }
  }
} 

class ServerStateRef // a reference hack to update ServerState in ConnectionHandler
{
  public ServerState state;
  public ServerStateRef()
  {
    this.state = ServerState.STANDBY;
  }
}

class ConnectionHandlerRef // a reference hack to update ServerState in ConnectionHandler
{
  public ConnectionHandler connection;
}
