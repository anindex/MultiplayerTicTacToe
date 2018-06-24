import java.io.*; //<>// //<>// //<>//
import java.util.*;
import java.net.*;
import java.lang.*;

public static final int PORT = 11111;

class ConnectionEngine extends Thread
{
  public static final String RESPONSE_SERVER_STATUS = "STATUS";
  public static final String RESPONSE_GAME_STATE = "GAMESTATE";
  public static final String RESPONSE_GAME_UPDATE = "GAMEUPDATE";
  public static final String RESPONSE_CLEAR_MAP = "CLEARMAP";
  public static final String RESPONSE_PLAYER_STAT = "PLAYERSTAT";

  public static final String INVALID = "INVALID";
  public static final String BYE = "BYE";

  public ServerStateRef serverStatus;
  public GameEngine game;

  public ArrayList<ConnectionHandler> clients;

  public ConnectionHandlerRef inPromt; // a hack to update matching connection

  public ServerSocket serverSocket;

  public ConnectionEngine(GameEngine game)
  {
    this.game = game;

    serverStatus = new ServerStateRef();


    clients = new ArrayList<ConnectionHandler>();
    inPromt = new ConnectionHandlerRef();

    try
    {
      serverSocket = new ServerSocket(PORT);
    }
    catch(Exception e)
    {
      System.out.println("[ConnectionEngine.contructor]Server initialization failed! Exiting.");
      System.exit(1);
    }
  }

  public void run()
  {
    while (true)
    {
      try
      {
        System.out.println("Wait for connection, has: " + clients.size());

        Socket incommingConnection = serverSocket.accept();

        ConnectionHandler connection = new ConnectionHandler(incommingConnection, this.serverStatus, game, clients, false);
        inPromt.connection = connection;
        connection.handshake();

        if (connection.connected)
        {
          connection.start();
          clients.add(connection);
        }

        inPromt.connection = null;
        System.out.println("After process new connection: " + clients.size());
      }
      catch(Exception e)
      {
        System.out.println("[ConnectionEngine.run]Incomming connection establishing failed!");
      }
    }
  }

  public void processGameTurn(int moveX, int moveY)
  {
    Coordinate move = game.gameState.retrieveCellIndex(moveX, moveY);

    if (game.inTurned && game.gameState.retrieveCell(moveX, moveY).type == CellType.BLANK)
    {
      game.updateCell(move, game.player.markType);
      
      GameCondition gameStatus = game.checkEndGame();
      System.out.println(gameStatus);
      
      game.inTurned = false;     

      if (gameStatus == GameCondition.CONTINUE)
      {
        for (ConnectionHandler viewer : clients)
        {
          viewer.sendLine.println(viewer.processRequest(ClientRequest.GET_GAME_UPDATE)); // send move decision to all listener, including matching component
        }
      } else if (gameStatus == GameCondition.WIN || gameStatus == GameCondition.DRAW)
      {
        for (ConnectionHandler viewer : clients)
        {
          viewer.sendLine.println(viewer.processRequest(ClientRequest.DO_CLEAR_MAP)); // send move decision to all listener, including matching component
        }

        if (gameStatus == GameCondition.WIN)
        {
          game.player1.win += 1;
          label5.setText(game.player1.name + " : " + String.valueOf(game.player1.win)); // update stat
        }
        
        game.gameState.clearMark();
      }
    }
  }

  public void button_connect() // no need inHandshake
  {
    Socket socket;
    try
    {      
      InetAddress host = InetAddress.getByName(textfield1.getText());
      socket = new Socket(host, PORT);
    }
    catch(Exception e)
    {
      System.out.println("[ConnectionEngine.button_connect]Host " + textfield1.getText() + " does not exit or refused!");  
      return;
    }

    ConnectionHandler connection = new ConnectionHandler(socket, this.serverStatus, game, clients, true);
    try
    {
      connection.handshake();
    }
    catch(Exception e)
    {
      System.out.println("[ConnectionEngine.button_connect]Target host: " + textfield1.getText() + " handshake failed!");
      connection.close();
    }

    if (connection.connected)
    {
      connection.start();
      clients.add(connection);
    }
    else
    {
      connection.close();
    }
  }

  public void button_resign()
  {
    for (ConnectionHandler connection : clients) // find and close spectator connection
    {
      if ((serverStatus.state == ServerState.MATCHING && connection.type == ConnectionType.MATCHING) || (serverStatus.state == ServerState.SPECTATOR && connection.type == ConnectionType.SPECTATOR)) // for safety
      {
        connection.sendLine.println(ClientRequest.BYE);
        connection.close();
        break;
      }
    }
  }
}
