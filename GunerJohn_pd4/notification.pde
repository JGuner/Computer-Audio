enum NotificationType { left_hand, right_hand, back, left_knee, right_knee, chest}

class Notification {
   
  int timestamp;
  NotificationType type; // muscle type
  int contraction;
  int rom;
  int x_pos;
  int priority;
  
  public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    //time in seconds for playback from sketch start
    
    String typeString = json.getString("type");
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }
    
    
    if (json.isNull("contraction")) {
      this.contraction = 0;
    }
    else {
      this.contraction = json.getInt("contraction");
    }
    
    if (json.isNull("rom")) {
      this.rom = 0;
    }
    else {
      this.rom = json.getInt("rom");      
    }
    
    if (json.isNull("x_pos")) {
      this.x_pos = 0;
    }
    else {
      this.x_pos = json.getInt("x_pos");  
    }
    this.priority = json.getInt("priority");
  }
  
  public int getTimestamp() { return timestamp; }
  public NotificationType getType() { return type; }
  public int getContraction() { return contraction; }
  public int getRom() { return rom; }
  public int getX_pos() { return x_pos; }
  public int getPriorityLevel() { return priority; }

  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(contraction: " + getContraction() + ") ";
      output += "(rom: " + getRom() + ") ";
      output += "(x_pos: " + getX_pos() + ") ";
      output += "(priority: " + getPriorityLevel() + ") ";
      return output;
    }
}
