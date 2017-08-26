import sys
import fileinput
import json 
from pprint import pprint
JSON_SCHEDULE = "JsonScheduleV1"
SCHEDULE_SEGMENT = "schedule_segment"
SCHEDULE_LOCATION = "schedule_location"
RECORD_IDENTITY = "record_identity"
PUBLIC_ARRIVAL = "public_arrival"
PUBLIC_DEPARTURE = "public_departure"

def valid_segment(segment):
  if segment[RECORD_IDENTITY] == "LI" and (segment[PUBLIC_DEPARTURE] == None or segment[PUBLIC_ARRIVAL] == None):
    return False
  elif (PUBLIC_DEPARTURE in segment and segment[PUBLIC_DEPARTURE] != None) or \
   (PUBLIC_ARRIVAL in segment and segment[PUBLIC_ARRIVAL] != None):
    return True
  else:
    return False

for line in fileinput.input():
  parsed = json.loads(line)
  if JSON_SCHEDULE in parsed:
    data = parsed[JSON_SCHEDULE] 
    if SCHEDULE_SEGMENT in data:
      schedule_segment = data[SCHEDULE_SEGMENT]
      if SCHEDULE_LOCATION in schedule_segment:
        schedule_location = schedule_segment[SCHEDULE_LOCATION]
        valid_segments = list(filter(valid_segment, schedule_location))
        if valid_segments:
          output = {
            "segments": valid_segments,
            "CIF_train_uid": data["CIF_train_uid"] 
          }
          print(json.dumps(output))

sys.stderr.write("Done\n")


