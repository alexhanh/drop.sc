# Encoding: UTF-8
import re
import os, sys
import os.path
from datetime import datetime
import time
import sqlalchemy
from sqlalchemy import *
from sqlalchemy.orm import *
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/sc2reader")

from mpyq import MPQArchive

import sc2reader

os.chdir("parser/")

base_path = "../files/%s/";

class DBMessage(object):
    pass

class DBPlay(object):
    pass
    
class DBPlayer(object):
    pass

class DBReplay(object):
    pass

def get_environment():
    if os.path.exists("production.txt"):
        return ''
    
    return 'postgresql://:@localhost/dropsc_development'

def has_alias(name, aliases):
    for alias in aliases.split(','):
        if alias == name:
            return True

    return False

def find_or_create_player(session, DBPlayer, player, date_played):
    # TODO: refine filters
    r = session.query(DBPlayer).filter(and_(DBPlayer.bnet_id==str(player.uid), DBPlayer.sub_region==player.subregion, DBPlayer.gateway==player.gateway.upper())).first()
    
    if r is None:
        r = DBPlayer()
        r.name = unicode(player.name, "utf-8")
        r.bnet_id = player.uid
        r.gateway = player.gateway.upper()
        r.sub_region = player.subregion
        r.region = player.region.upper()
        r.last_played = date_played
        r.aliases = player.name + ","
        
        session.add(r)
        session.commit()
    else:
        # Update player name to newest one
        if r.last_played < date_played:
            #print "Updating player name: %s -> %s" % (r.name, player.name)
            r.name = unicode(player.name, "utf-8")
            r.last_played = date_played
        
        if has_alias(player.name, r.aliases) is False:
            r.aliases = r.aliases + player.name + ","
        
        session.add(r)
        
    return r

SPEEDS = { 
    "Slower" : 60, 
    "Slow" : 45, 
    "Normal" : 36, 
    "Fast" : 30, 
    "Faster" : 26 
}

def convert_time(from_speed, to_speed, amount):
    return amount * SPEEDS[from_speed] / SPEEDS[to_speed]

def to_real_time(from_speed, amount):
    return convert_time(from_speed, "Normal", amount)

def parse_replay(session, DBPlayer, replay_id):
    r = session.query(DBReplay).get(replay_id)
    
    print "Parsing " + str(r.id)
    
    if r:
        base_path = "../files/replays/"
        file_path =  base_path + r.file
       
        try:
            print "Opening replay file"
            replay = sc2reader.read_file(file_path)

            if replay is None:
                print "None :()"
                raise 
                
            print "Done opening replay file"

            r.saved_at = replay.utc_date
            r.map_name = unicode(replay.map, "utf-8")
            r.game_format = replay.type.lower()
            r.gateway = replay.gateway.upper()
            r.version = replay.release_string
            r.game_speed = replay.speed
            r.game_length = str(to_real_time(r.game_speed, replay.seconds))
            r.game_type = replay.category

            r.zergs = r.protosses = r.terrans = 0
            if r.gateway != "XX":
                for player in replay.players:
                    if player.type == "Human":
                        p = find_or_create_player(session, DBPlayer, player, replay.utc_date)
                    
                    play = DBPlay()
                    play.player_id = p.id
                    play.replay_id = r.id
                    play.pid = player.pid
                    play.chosen_race = player.pick_race[0].upper()
                    play.race = player.play_race[0].upper()
                    if play.race == 'Z':
                        r.zergs = r.zergs + 1
                    if play.race == 'T':
                        r.terrans = r.terrans + 1
                    if play.race == 'P':
                        r.protosses = r.protosses + 1
                    play.color = "#" + player.color.hex
                    play.avg_apm = to_real_time(r.game_speed, player.avg_apm)
                    play.won = (player.result == "Win")
                    if play.won:
                        r.winner_known = True
                   
                    play.team = player.team.number
                    play.player_type = player.type
                    play.difficulty = player.difficulty
               
                    # apm = dict()            
                    # for i in range(0, replay.seconds/60):
                    #     apm[i] = "0"
                    # for minute, actions in player.apm.iteritems():
                    #     apm[minute] = str(actions)
                    # 
                    # play.apm = ','.join(apm.values())

                    session.add(play)
               
                msg_number = 0
                for message in replay.messages:
                   # TODO: use a more general url regexp instead
                   # Filter certain messages
                    if message.text == "sc2.replays.net":
                        continue
               
                    m = DBMessage()
                    m.replay_id = r.id
                    m.msg_order = msg_number
                    m.sender = message.sender.name
                    m.sender_color = "#" + message.sender.color.hex
                    m.msg = message.text
                    m.target = message.target
                    m.time = message.time.seconds
                    m.pid = message.sender.pid
               
                    msg_number += 1

                    session.add(m)
           
           # new_file_name = ""
           # if replay.type == "1v1":
           #     new_file_name = "%s_vs_%s_%s.SC2Replay" % (replay.players[0].name, replay.players[1].name, r.id)
           # else:
           #     new_file_name = "%s_%s_%s.SC2Replay" % (replay.type, replay.map, r.id)
   
           # print "Renaming file"
           # os.rename(file_path, base_path + new_file_name)
           # print "Done renaming file"
   
           # print "Processing..."
           # r.file = unicode(new_file_name, "utf-8")
           
            r.state = 'success'
            session.add(r)
            session.commit()
            print "Done processing"
                  
        except:
            print "EXCEPT"
            # Enable for debugging!!!
            raise
            r.state = 'failed'
            session.add(r)
            session.commit()
   
    print "Parser ended"
    

if __name__ == '__main__':
    print "Parser started"
    
    #replay_id = int(sys.argv[1])
    
    print "Creating engine"
    engine = create_engine(get_environment())
    metadata = MetaData(engine)
    print "Done creating engine"
    
    messages = Table('messages', metadata, autoload=True, autoload_with=engine)
    plays = Table('plays', metadata, autoload=True, autoload_with=engine)
    players = Table('players', metadata, autoload=True, autoload_with=engine)
    replays = Table('replays', metadata, autoload=True, autoload_with=engine)
        
    messagemapper = mapper(DBMessage, messages)
    playmapper = mapper(DBPlay, plays)
    playermapper = mapper(DBPlayer, players)
    replaymapper = mapper(DBReplay, replays)
    
    print "Creating session"
    Session = sessionmaker()
    session = Session()
    print "Done creating session"

    # for replay_id in session.query(DBReplay.id).order_by(desc(DBReplay.created_at))[:1]:
    #     print replay_id
    # parse_replay(session, DBPlayer, "2")
    while True:
        # Order from the newest unprocessed replays to oldest (to prevent massive replay packs clogging the queue)
        for replay_id in session.query(DBReplay.id).filter(DBReplay.state == "unprocessed").order_by(desc(DBReplay.created_at))[:1]:
            parse_replay(session, DBPlayer, replay_id)
    
        time.sleep(5)
    
       