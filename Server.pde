
public class Server {
  
  private boolean active;
  private int port;
  private int mode;
  public static final int HTTP = 0;
  public static final int HTTPS = 1;
  
  private boolean directory_listing;
  
  private class ClientConnection implements Runnable {
    
    private Socket sock;
    
    public ClientConnection(Socket sock) {
      this.sock = sock;
    }
    
    public void run(){
      
      //println("connected to client at port: "+connection.getPort());
      cprintln("PORT CONNECTED: "+sock.getPort());
      
      try {
        InputStream in = sock.getInputStream();
        OutputStream out = sock.getOutputStream();
        
        Scanner reader = new Scanner(in,"UTF-8");
        PrintWriter writer = new PrintWriter(new OutputStreamWriter(out,"UTF-8"),true);
        
        ArrayList<String> message = new ArrayList<String>();
        
        while(active && !sock.isClosed()) {
          if(reader.hasNextLine()) {
            
            String line = reader.nextLine();
            message.add(line);
            
            byte[] response_data = new byte[0];
            
            if(line.trim().isEmpty()) {
              
              cprintln("");
              cprintln("GOT MESSAGE:");
              for(String msg : message) {
                
                cprintln(msg);
                
                String[] info = msg.split(" ");
                for(int i=0;i<info.length;i++) {
                  info[i] = info[i].trim();
                }
                
                try {
                  switch(info[0]) {
                    case "GET":
                      if(info[1].equals("/")) {
                        info[1] = "/index.html";
                      }
                      String path = sketchPath()+"/data"+info[1];
                      path = path.replace("%20"," ");
                      response_data = FileIO.read(path);
                      if(response_data==null) {
                        
                        if(path.indexOf("..")!=-1) {
                          
                          response_data = "invalid location, bich".getBytes();
                          
                        } else {
                          
                          int param_ind = path.indexOf("?");
                          if(param_ind!=-1) {
                            path = path.substring(0,param_ind);
                          }
                          path.replace("_page","order_page");
                          
                          
                          File file = new File(path);
                          
                          if(file.isDirectory()) {
                            if(directory_listing) {
                              StringBuilder dirlist = new StringBuilder();
                              dirlist.append("<html><head></head><body>");
                              dirlist.append("<p>directory listing:</p>");
                              for(File child : file.listFiles()) {
                                dirlist.append("<a href=\"");
                                dirlist.append(child.getName());
                                dirlist.append("\">");
                                dirlist.append(child.getName());
                                dirlist.append("</a><br>\n");
                              }
                              dirlist.append("</body></html>");
                              response_data = dirlist.toString().getBytes();
                            } else {
                              response_data = "access denied, bith".getBytes();
                            }
                          } else {
                            response_data = "404 error, file not found lmao".getBytes();
                          }
                        }
                        
                      } else {
                        if(info[1].lastIndexOf(".txt")==info[1].length()-4) {
                          String name = path.substring(path.lastIndexOf("/")+1);
                          response_data = ("<html><head><title>"+name+"</title></head><body>"+
                          "<pre style=\"word-wrap: break-word; white-space: pre-wrap;\">"+
                          new String(response_data)+"</body></html>").getBytes();
                        }
                      }
                      
                    break;
                  }
                } catch(Exception e) {
                  e.printStackTrace();
                  System.err.println("malformed message");
                }
                
              }
              
              // send reply...
              cprintln("SENDING RESPONSE...");
              
              writer.println("HTTP/1.1 200 OK");
              writer.println("Date: Sat, 09 Oct 2010 14:28:02 GMT");
              writer.println("Server: Apache");
              writer.println("Last-Modified: Tue, 01 Dec 2009 20:18:22 GMT");
              writer.println("ETag: \"51142bc1-7449-479b075b2891b\"");
              writer.println("Accept-Ranges: bytes");
              writer.println("Content-Length: "+response_data.length);
              writer.println("Content-Type: text/html");
              writer.println("");
              sock.getOutputStream().write(response_data);
              
              message.clear();
            }
            //println("message from client: "+line);
            
          } else {
            break; // ?
          }
        }
        
        cprintln("PORT DISCONNECTED: "+sock.getPort());
        
        sock.shutdownInput();
        sock.shutdownOutput();
        
        reader.close();
        writer.close();
        sock.close();
        
      } catch(Exception e) {
        e.printStackTrace();
      }
      
    }
  }
  
  private Runnable start_http = new Runnable(){public void run(){
    try {
      ServerSocket sock = new ServerSocket(port);
      sock.setReuseAddress(true);
      cprintln("LISTENING ON PORT: "+port);
      while(active) {
        Socket new_sock = sock.accept();
        new Thread(new ClientConnection(new_sock)).start();
        cprintln("handling message from: "+new_sock.getPort());
      }
      sock.close();
    } catch(Exception e) {
      e.printStackTrace();
    }
  }};
  
  private Runnable start_https = new Runnable(){public void run(){
    try {
      InetSocketAddress addr = new InetSocketAddress(8000);
      HttpsServer serv = HttpsServer.create(addr,0);
      SSLContext sslcon = SSLContext.getInstance("TLS");
      
      char[] pass = "fullbringhellblazer".toCharArray();
      KeyStore ks = KeyStore.getInstance("JKS");
      FileInputStream in = new FileInputStream(sketchPath()+"/data/keystore.jks");
      ks.load(in,pass);
      
      KeyManagerFactory kmf = KeyManagerFactory.getInstance("SunX509");
      kmf.init(ks,pass);
      
      TrustManagerFactory tmf = TrustManagerFactory.getInstance("SunX509");
      tmf.init(ks);
      
      sslcon.init(kmf.getKeyManagers(),tmf.getTrustManagers(),null);
      serv.setHttpsConfigurator(new HttpsConfigurator(sslcon) {
        public void configure(HttpsParameters params) {
          try {
            SSLContext defcon = SSLContext.getDefault();
            SSLEngine engine = defcon.createSSLEngine();
            params.setNeedClientAuth(false);
            params.setCipherSuites(engine.getEnabledCipherSuites());
            params.setProtocols(engine.getEnabledProtocols());
            
            SSLParameters defparams = defcon.getDefaultSSLParameters();
            params.setSSLParameters(defparams);
          } catch(Exception e) {
            e.printStackTrace();
          }
        }
      });
      serv.createContext("/servdata",new HttpHandler(){
        public void handle(HttpExchange t) throws IOException {
          String response = "this is america";
          HttpsExchange httpsex = (HttpsExchange)t;
          t.getResponseHeaders().add("Access-Control-Allow-Origin","*");
          t.sendResponseHeaders(200,response.getBytes().length);
          OutputStream os = t.getResponseBody();
          os.write(response.getBytes());
          os.close();
        }
      });
      serv.setExecutor(null);
      serv.start();
    } catch(Exception e) {
      e.printStackTrace();
    }
  }};
  
  public Server(int port) {
    this.port = port;
  }
  
  public void setPort(int port) {
    this.port = port;
  }
  
  public int getPort() {
    return port;
  }
  
  public void setMode(int mode) {
    this.mode = mode;
  }
  
  public int getMode() {
    return mode;
  }
  
  public void start() {
    if(!active) {
      active = true;
      switch(mode) {
        case HTTP:
          new Thread(start_http).start();
        break;
        case HTTPS:
          new Thread(start_https).start();
        break;
      }
    }
  }
  
  public void close() {
    if(active) {
      active = false;
      
    }
  }
  
}
