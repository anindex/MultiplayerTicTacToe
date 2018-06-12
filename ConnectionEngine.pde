import java.io.*;
import java.util.*;
import java.net.*;
import java.lang.*;

public static final int PORT = 11111;

class ConnectionEngine
{
  
  public PlayerState playerStatus;
}

class ConnectionHandler extends Thread
{
  private Socket socket;
  
  public Scanner receiveLine;
  public PrintWriter sendLine;
  
  public ConnectionHandler(Socket socket)
  {
     this.socket = socket;
  }
  
  public void run()
  {
    try
    {
      while(true)
      {
        
      }
    }
    catch(Exception e)
    {
      e.printStackTrace();
      System.out.println("Something wrong with the server! Server will exit!");
    }
  }
  
  private PlayerState handshake()
  {
    
  }
}
