
public static class FileIO {
  
  public static byte[] read(String path) {
    File file = new File(path);
    if(file.exists() && !file.isDirectory()) {
      try {
        FileInputStream in = new FileInputStream(path);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int index = 0;
        while((index=in.read(buffer,0,buffer.length))!=-1) {
          baos.write(buffer,0,index);
        }
        in.close();
        byte[] data = baos.toByteArray();
        baos.close();
        return data;
      } catch(Exception e) {
        e.printStackTrace();
      }
    }
    return null;
  }
  
}
