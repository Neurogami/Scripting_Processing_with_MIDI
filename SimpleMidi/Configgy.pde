
class Configgy {

  String[] configTextLines;
  JSONObject json;

  Configgy(String configFile) {
    try {
      configTextLines = getDataLines(loadStrings(configFile));

      String line = trim(configTextLines[0]);
      if (line.charAt(0) == '{') {
        json = loadJSONObject(configFile);
      } else {
        String jsonString = configToJson(configTextLines);
        json = parseJSONObject(jsonString);
      }
    } catch(Exception e) {
      println("Error loading data from '" + configFile + "'");
      e.printStackTrace();
    }


  }

  // Return just the lines that have config data
  String[] getDataLines(String[] configTextLines) {
    String[] dataLines = {};
    String line;

    for (int i=0; i < configTextLines.length; i++) {
      line = trim(configTextLines[i]);

      if ( ( line.indexOf("#") != 0 ) &&  ( line.indexOf(":") > 0 ) )  {
        dataLines = append(dataLines,  line);  
      }
    }
    return dataLines ;
  }


// Assumes we have a set of congig lines, each being of the form
//    keyName: validJsonExpression
  String configToJson(String[] configTextLines) {
    String line;
    String[] jsonStrings = {"{" };
    String[] splitString;
    String newJsonLine = "";
    for (int i=0; i < configTextLines.length; i++) {
      line = trim(configTextLines[i]);

      if ( ( line.indexOf("#") != 0 ) &&  ( line.indexOf(":") > 0 ) )  {
        splitString = split(configTextLines[i], ':'); 
        newJsonLine = "\"" + splitString[0] + "\":"  + join(subset(splitString,1), ":" ) + ", ";
        jsonStrings = append(jsonStrings,  newJsonLine);  

      }
    }

    jsonStrings = append(jsonStrings, "}"  );  

    return  join(jsonStrings, "\n");

  }


  // Assorted accessor methods
  String getValue(String k) { return json.getString(k); }
  String getString(String k) { return json.getString(k); }
  int getInt(String k) { return json.getInt(k); }
  float getFloat(String k) { return json.getFloat(k); }
  boolean getBoolean(String k) { return json.getBoolean(k); }

  String[] getStrings(String k) {
    JSONArray values = json.getJSONArray(k);
    String[] strings = new String[values.size()];
    for (int i = 0; i < values.size(); i++) {
      strings[i] = values.getString(i);
    }
    return strings;
  }


  int[] getInts(String k) {
    JSONArray values = json.getJSONArray(k);
    int[] ints = new int[values.size()];
    for (int i = 0; i < values.size(); i++) {
      ints[i] = values.getInt(i); 
    }
    return ints;
  }

  float[] getFloats(String k) {
    JSONArray values = json.getJSONArray(k);
    float[] floats = new float[values.size()];
    for (int i = 0; i < values.size(); i++) {
      floats[i] = values.getFloat(i); 
    }
    return floats;
  }


  boolean[] getBooleans(String k) {
    JSONArray values = json.getJSONArray(k);
    boolean[] booleans= new boolean[values.size()];
    for (int i = 0; i < values.size(); i++) {
      booleans[i] = values.getBoolean(i); 
    }
    return booleans;
  }

}


