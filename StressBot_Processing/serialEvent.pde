
void serialEvent(Serial port) {   
  String inData = port.readStringUntil('\n');  

  if (inData.charAt(0) == 'Q') {          // leading 'Q' means time between beats in milliseconds
    inData = inData.substring(1);        // cut off the leading 'Q'
    inData = trim(inData);               // trim the \n off the end
    IBI = int(inData);                  // convert ascii string to integer IBI 
    beatIntervals.append(IBI);              // add this beat to the ArrayList
//    println("IBI: " + IBI);  
//    println("IBI Interval:" + str(getAvgIBIDelta()));
//      println(beatIntervals);
    output.println(IBI+","+getAvgIBIDelta()+","+beatIntervals.size());
    return;
  }

  if (inData.charAt(0) == 'S') {          // leading 'S' means sensor data
    inData = inData.substring(1);        // cut off the leading 'S'
    inData = trim(inData);               // trim the \n off the end
    ppgY = int(inData);                 // convert to integer
    outputRaw.println(ppgY);
    if (ppgY > maxppgY) maxppgY = ppgY;   // reset the max interval value if needed
    return;
  }   

  if (inData.charAt(0) == 'F') {          // leading 'F' means finger data
    inData = inData.substring(1);        // cut off the leading 'F'
    inData = trim(inData);               // trim the \n off the end
    if (int(inData) == 1){ 
    fingerIsInserted = true;             //set finger flag
    }
    if (int(inData) == 0){ 
    fingerIsInserted = false;             //set finger flag
    }
    return;
  }

//  if (inData.charAt(0) == 'P') {        // leading 'P' means prox sensor data
//    inData = inData.substring(1);       // cut off leading 'P'
//    inData = trim(inData);              // trim the \n off the end
//    if (int(inData) == 1) 
//    personIsNear = true;                //set proximity flag
//    return;
//  }
}// END OF SERIAL EVENT

