import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;
import java.lang.*;
import java.net.InetSocketAddress;

// https imports
import com.sun.net.httpserver.HttpsServer;
import java.security.KeyStore;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.TrustManagerFactory;
import com.sun.net.httpserver.*;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.SSLParameters;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URLConnection;
import javax.net.ssl.*;
import java.security.cert.X509Certificate;
import java.net.InetAddress;
import com.sun.net.httpserver.*;

Server server;

Console console;
int scroll;
int blink;
float cursor;

void cprintln(String str) {
  println(str);
  console.println(str);
  if(scroll<console.lineCount()-26) {
    scroll = console.lineCount()-26;
  }
}

void setup() {
  
  surface.setTitle("server");
  surface.setIcon(createImage(1,1,ARGB));
  size(640,480);
  background(0);
  noSmooth();
  textFont(createFont("courier new bold",12));
  
  console = new Console();
  
  server = new Server(80);
  //server.setMode(Server.HTTPS);
  //server.start();
}

void keyPressed() {
  
  console.sendKey(key,keyCode);
  
  blink = 0;
  if(key!=CODED && scroll<console.lineCount()-26) {
    scroll = console.lineCount()-26;
  }
  
  if(keyCode==ENTER) {
    String line = console.getLine(console.lineCount()-2);
    String[] args = line.split(" ");
    for(int i=0;i<args.length;i++) {
      args[i] = args[i].trim();
    }
    switch(args[0]) {
      case "help":
        cprintln("open [port=80] - start the server on the given port");
        cprintln("close - shut off the server");
        cprintln("exit - shut off the server and exit the console");
      break;
      case "close":
        cprintln("SERVER SHUTTING DOWN");
        //cprintln("");
        server.close();
      break;
      case "open":
        cprintln("SERVER STARTING");
        //cprintln("");
        server.setPort(args.length>1?parseInt(args[1]):80);
        server.start();
      break;
      case "exit":
        server.close();
        exit();
      break;
      default:
        cprintln("UNKNOWN COMMAND");
        //cprintln("");
      break;
    }
    cprintln("");
  }
  
}

void mouseWheel(MouseEvent e) {
  scroll += e.getCount();
  scroll = min(scroll,console.lineCount()-1);
  scroll = max(scroll,0);
}

void draw() {
  
  background(0);
  
  // draw the border of the console window
  stroke(255);
  fill(0);
  float border = 55;
  rect(border,border,width-border*2,height-border*2);
  
  // draw the console text
  fill(255);
  textAlign(LEFT,TOP);
  for(int i=0;i<min(26,console.lineCount()-scroll);i++) {
    String line = console.getLine(i+scroll);
    if(textWidth(line)>(width-border*2)) {
      //line = line.length()+" characters long, off screen";
      line = line.substring(0,75);
    }
    text(line,border+4,border+4+14*i);
  }
  
  // draw the console cursor
  try {
    int cursor_y = console.lineCount()-scroll-1;
    if(cursor_y<26 && (blink/16)%2==0) {
      String line = console.getLine(console.lineCount()-1);
      int textw = (int)textWidth(line.substring(0,console.getCursor()));
      cursor += (textw-cursor)*.5;
      noStroke();
      rect(border+4+cursor,border+4+14*cursor_y,2,14);
    }
  } catch(Exception e) {}
  blink++;
  
}
