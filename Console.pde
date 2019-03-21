
public class Console {
  
  private ArrayList<String> lines;
  private StringBuilder last_line;
  private int cursor = 0;
  private int select = -1;
  
  private boolean[] key_mask = null;
  private boolean input_enabled = true;
  
  private final boolean[] KEY_MASK_YN = new boolean[256];
  private final boolean[] KEY_MASK_NUM = new boolean[256];
  {
    createMask(KEY_MASK_YN,"yn");
    createMask(KEY_MASK_NUM,"0123456789");
  }
  
  private void createMask(boolean[] mask, String strmask) {
    for(int i=0;i<strmask.length();i++) {
      char c = strmask.charAt(i);
      mask[c-32] = true;
    }
  }
  
  public Console() {
    lines = new ArrayList<String>();
    last_line = new StringBuilder();
  }
  
  public boolean indexIsSelected(int index) {
    int lower = min(cursor,select);
    int upper = max(cursor,select);
    return index>=lower && index<upper;
  }
  
  public int getCursor() {
    return cursor;
  }
  
  public int lineCount() {
    return lines.size()+1;
  }
  
  public String getLine(int index) {
    if(index>lines.size() || index<0) {
      return "";
    } else if(index==lines.size()) {
      return last_line.toString();
    } else {
      return lines.get(index);
    }
  }
  
  public boolean isInputEnabled() {
    return input_enabled;
  }
  
  public void setInputEnabled(boolean value) {
    input_enabled = value;
  }
  
  public void setMask(boolean[] mask) {
    key_mask = mask;
  }
  
  public void clearMask() {
    key_mask = null;
  }
  
  public boolean[] getMask() {
    return key_mask;
  }
  
  public void sendKey(char key, int keyCode) {
    
    if(!input_enabled) {
      return;
    }
    if(key_mask!=null && !key_mask[keyCode]) {
      return;
    }
    
    switch(keyCode) {
      case ENTER:
        lines.add(last_line.toString());
        last_line.setLength(0);
        cursor = 0;
        select = -1;
      break;
      case BACKSPACE:
        if(moveCursorLeft()) {
          deleteAtCursor();
        }
      break;
      case DELETE:
        deleteAtCursor();
      break;
      case RIGHT:
        moveCursorRight();
      break;
      case LEFT:
        moveCursorLeft();
      break;
      case UP:
        cursor = 0;
      break;
      case DOWN:
        cursor = last_line.length();
      break;
      default:
        if(key!=CODED) {
          last_line.insert(cursor,key);
          cursor++;
        }
      break;
    }
    
  }
  
  public void print(String str) {
    for(int i=0;i<str.length();i++) {
      sendKey(str.charAt(i),0);
    }
  }
  
  public void println(String str) {
    print(str);
    sendKey('\0',ENTER);
  }
  
  private boolean moveCursorLeft() {
    if(cursor>0) {
      cursor--;
      return true;
    }
    return false;
  }
  
  private boolean moveCursorRight() {
    if(cursor<last_line.length()) {
      cursor++;
      return true;
    }
    return false;
  }
  
  private boolean deleteAtCursor() {
    if(cursor<last_line.length()) {
      last_line.deleteCharAt(cursor);
      return true;
    }
    return false;
  }
  
  private void beginSelect() {
    select = cursor;
  }
  
  private void endSelect() {
    select = -1;
  }
  
  public String getSelectedText() {
    if(select==-1 || cursor==select) {
      return null;
    }
    return last_line.substring(min(cursor,select),max(cursor,select));
  }
  
}
