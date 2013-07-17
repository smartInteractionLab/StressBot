float getAverageIBI() {
	int _sampleSize = 10;
  	if (beatIntervals.size() < _sampleSize) return -1;
  	else {
	  float _bpmAvg = 0;
	  for (int i=beatIntervals.size()-_sampleSize; i<beatIntervals.size(); i++) {
	    _bpmAvg += beatIntervals.get(i); //add up all the IBI values
	  }
	  return abs(_bpmAvg / _sampleSize); //get the average IBI value
	}
}

int getAverageBPM() {
	float _avgIBI = getAverageIBI(); //get the average interbeat interval in 
	if (_avgIBI == -1) return -1;
  	else {
		_avgIBI /= 1000; //divide by 1000 to convert to seconds
		return round(60/_avgIBI); //divide 60 by the average IBI to get BPM. Round and return as int
	}
}

float getAvgIBIDelta() {
	int _sampleSize =10;
	if (beatIntervals.size() <= _sampleSize) return -1;
	else {		
		float _totalDelta = 0;
		for (int i=beatIntervals.size()-_sampleSize; i<beatIntervals.size(); i++) {
			_totalDelta += abs(beatIntervals.get(i)-beatIntervals.get(i-1)); //add up the differences of the last 20 IBI values
		}
		return abs(_totalDelta / _sampleSize); //return the average delta value
	}
}

int getIBICycleLength() {
	int _startBeat = -1;
	for (int i=0; i<beatIntervals.size(); i++) {
		if (beatIntervals.get(i) == beatIntervals.min()) {
			_startBeat = i; //should be the trough of a wave
		}
		if (_startBeat > -1) {
			if (beatIntervals.get(i+1) < beatIntervals.get(i)) {
				return i - _startBeat; //should be the length of half a wave
			}
		}
	}
	return -1;
}

int getIBICycleCrestPoint() { //get the highest point of the first IBI cycle. This is used to sync up the IBI wave with the sample sine wave
	for (int i=0; i<beatIntervals.size(); i++) {
		if (beatIntervals.get(i) == beatIntervals.max()) return i;
	}
	return -1;
}

String describeBPM() {
	int _heartRate = getAverageBPM();
	if (_heartRate < 0) return "";
	else if (_heartRate < 60) return "low";
	else if (_heartRate < 75) return "cool";
	else return "a bit high";
}
