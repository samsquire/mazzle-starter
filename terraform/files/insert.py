import os
import json
import fileinput

from neo4j.v1 import GraphDatabase, basic_auth

driver = GraphDatabase.driver("bolt://127.0.0.1:7687", auth=basic_auth("neo4j", os.environ["NEO4J_PASSWORD"]))
session = driver.session()

for line in fileinput.input():
  data = json.loads(line)
  segments = data["segments"]

  for a_station, b_station in zip(segments[:-1], segments[1:]):
    #print("creating {} -> {}".format(a_station["tiploc_code"], b_station["tiploc_code"]))
    #print("creating {} -> {}".format(a_station["public_departure"], b_station["public_arrival"]))

    if not a_station["public_departure"]:
      print(a_station) 

    if not b_station["public_arrival"]:
      print(b_station) 

    args = {
      "a_station": a_station["tiploc_code"],
      "b_station": b_station["tiploc_code"],
      "departs": a_station["public_departure"],
      "arrives": b_station["public_arrival"],
      "schedule_id": data["CIF_train_uid"]

    }

    with session.begin_transaction() as tx:
      result = tx.run("Match (n:Station) where n.tiploc = {a_station} return n", args)
      if list(result): 
        print("skipping {}, already exists".format(args["a_station"])) 
      else:
        result = tx.run("MERGE (a:Station {tiploc: {a_station}}) RETURN a", args)
      result = tx.run("Match (n:Station) where n.tiploc = {b_station} return n", args)
      if list(result): 
        print("skipping {}, already exists".format(args["b_station"])) 
      else:
        result = tx.run("MERGE (b:Station {tiploc: {b_station}}) RETURN b", args)
      print("associating schedule to {} -> {}", args["a_station"], args["b_station"])
      result = tx.run("MATCH (a:Station {tiploc: {a_station}}),(b:Station {tiploc: {b_station}}) CREATE UNIQUE (a)-[r:connection {departs: {departs}, arrives: {arrives}, schedule_id: {schedule_id}}]->(b) RETURN r", args)
      tx.success = True 

   # for record in result:
   #     print(record)
      
  
session.close()
