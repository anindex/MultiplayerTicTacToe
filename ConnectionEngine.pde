import java.io.*;
import java.util.*;
import java.net.*;
import java.lang.*;

public static final int PORT = 11111;

class ConnectionEngine extends Thread
{
  public static final String RESPONSE_SERVER_STATUS = "STATUS";
  public static final String RESPONSE_GAME_STATE = "GAMESTATE";
  public static final String RESPONSE_GAME_UPDATE = "GAMEUPDATE";

  public static final String INVALID = "INVALID";
  public static final String BYE = "BYE";

  public ServerStateRef serverStatus;
  public GameEngine game;

  public ArrayList<ConnectionHandler> clients;

  public ConnectionHandlerRef inHandshake; // a hack to update matching connection

  public ServerSocket serverSocket;

  public ConnectionEngine(GameEngine game)
  {
    this.game = game;

    serverStatus = new ServerStateRef();


    clients = new ArrayList<ConnectionHandler>();
    inHandshake = new ConnectionHandlerRef();

    try
    {
      serverSocket = new ServerSocket(PORT);
    }
    catch(Exception e)
    {
      System.out.println("Server initialization failed! Exiting.");
      System.exit(1);
    }
  }

  public void run()
  {
    while (true)
    {
      try
      {
        clearDisconnectedConnections(); // clear dead connections

        Socket incommingConnection = serverSocket.accept();

        ConnectionHandler connection = new ConnectionHandler(incommingConnection, this.serverStatus, game, clients, false);
        inHandshake.connection = connection;
        connection.handshake();

        if (connection.connected)
        {
          clients.add(connection);
        }

        inHandshake.connection = null;
        System.out.println(clients.size());
      }
      catch(Exception e)
      {
        System.out.println("Incomming connection establishing failed!");
      }
    }
  }

  public void processGameTurn(int moveX, int moveY)
  {
    Coordinate move = game.gameState.retrieveCellIndex(moveX, moveY);

    if (game.inTurned)
    {
      game.updateCell(move, game.player.markType);
      game.inTurned = false;

      for (ConnectionHandler viewer : clients)
      {
        viewer.sendLine.println(viewer.processRequest(ClientRequest.GET_GAME_UPDATE)); // send move decision to all listener, including matching component
      }
    }
  }

  public void button_connect()
  {
    try
    {      
      InetAddress host = InetAddress.getByName(textfield1.getText());
      Socket socket = new Socket(host, PORT);

      ConnectionHandler connection = new ConnectionHandler(socket, this.serverStatus, game, clients,true);
      inHandshake.connection = connection;
      connection.handshake();

      if (connection.connected)
      {
        clients.add(connection);
      }
      inHandshake.connection = null;
    }
    catch(Exception e)
    {
      System.out.println("Host " + textfield1.getText() + " does not exit or refused!");
    }
  }

  public void button_resign()
  {
  }

  private void clearDisconnectedConnections()
  {
    for (ConnectionHandler connection : clients)
    {
      if (!connection.connected)
      {
        clients.remove(connection);
      }
    }
  }
}
