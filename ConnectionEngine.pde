import java.io.*;
import java.util.*;
import java.net.*;
import java.lang.*;

public static final int PORT = 11111;

enum ServerState {
  STANDBY, MATCHING, SPECTATOR
};
enum ConnectionType {
  UNKNOWN, MATCHING, SPECTATOR
};

class ConnectionEngine extends Thread
{
  public ServerStateRef serverStatus;
  public GameEngine game;

  public ArrayList<ConnectionHandler> clients;

  public ConnectionHandlerRef inHandshake; // a hack to update matching connection
  public ConnectionHandlerRef currentMatching; // 

  public ServerSocket serverSocket;

  public ConnectionEngine(GameEngine game)
  {
    this.game = game;

    serverStatus = new ServerStateRef();


    clients = new ArrayList<ConnectionHandler>();
    currentMatching = new ConnectionHandlerRef();
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
        Socket incommingConnection = serverSocket.accept();

        ConnectionHandler connection = new ConnectionHandler(incommingConnection, this.serverStatus, game.player.name, false);
        inHandshake.connection = connection;
        connection.handshake(3);

        if (connection.connected)
        {
          clients.add(connection);
        }
        else
        {
          System.out.println("Receiver timeout!");
        }
        inHandshake.connection = null;
      }
      catch(Exception e)
      {
        System.out.println("Incomming connection establishing failed!");
      }
    }
  }

  public void button_connect()
  {
    try
    {      
      InetAddress host = InetAddress.getByName(textfield1.getText());
      Socket socket = new Socket(host, PORT);

      ConnectionHandler connection = new ConnectionHandler(socket, this.serverStatus, game.player.name, true);
      inHandshake.connection = connection;
      connection.handshake(3);

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
}

class ConnectionHandler extends Thread
{
  private Socket socket;

  public Scanner receiveLine;
  public PrintWriter sendLine;

  public String hostname; //hostname of the target host
  public ConnectionType type;

  public String playerName;

  public ServerStateRef serverStatus;

  public boolean isInitiator;
  public boolean answeredChallenge;
  public boolean connected;

  public ConnectionHandler(Socket socket, ServerStateRef serverStatus, String playerName, boolean isInitiator)
  {
    this.socket = socket;
    this.hostname = socket.getInetAddress().getHostName();

    this.type = ConnectionType.UNKNOWN;
    this.serverStatus = serverStatus;

    this.playerName = playerName;

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

  public void handshake(int timeout) // handshake for knowing each other states, need synchronized to prevent data race
  {
    try
    {
      sendLine.println(serverStatus.state);
      ServerState targetState = ServerState.valueOf(receiveLine.next().toUpperCase());

      if (this.serverStatus.state == ServerState.STANDBY && (targetState == ServerState.STANDBY || targetState == ServerState.SPECTATOR))
      {
        if (isInitiator)
        {
          sendChallenge();
        } else
        {
          String challenger = receiveLine.nextLine();
          System.out.println("receive " + challenger);
          label4.setText(challenger + " want to challenge you!!! Accept?");
          window1.setVisible(true);

          int then = second();
          while ((second() - then < timeout) && !answeredChallenge);

          if (!this.connected && !answeredChallenge)
          {
            button_no();
            System.out.println("Sender timeout!");
          }
        }
      } else if (this.serverStatus.state == ServerState.STANDBY && targetState == ServerState.MATCHING)
      {
        this.type = ConnectionType.SPECTATOR;
        this.serverStatus.state = ServerState.SPECTATOR;
      } else if (this.serverStatus.state == ServerState.MATCHING && targetState == ServerState.STANDBY)
      {
        this.type = ConnectionType.SPECTATOR;
      } else if (this.serverStatus.state == ServerState.SPECTATOR && targetState == ServerState.STANDBY)
      {
        String challenger = receiveLine.nextLine();
        label4.setText(challenger + " want to challenge you!!! Accept?");
        window1.setVisible(true);
      }
    }
    catch(Exception e)
    {
      e.printStackTrace();
      System.out.println("Connection to " + this.hostname + " failed! Connection will close!");
      close();
    }
  }

  public void run() //listen and maintain connection
  {
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

  private void sendChallenge()
  {
    if (sendLine != null && receiveLine != null)
    {
      System.out.println("Sending " + this.playerName);
      sendLine.println(this.playerName); //introduce yourself

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
