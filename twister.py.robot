#! /usr/bin/python
import random

from robot import Robot

def enum(*sequential, **named):
    enums = dict(zip(sequential, range(len(sequential))), **named)
    reverse = dict((value, key) for key, value in enums.iteritems())
    enums['reverse_mapping'] = reverse
    return type('Enum', (), enums)

PartType = enum(ROBOT=1, CANNON=2, RADAR=4)

ObjectType = enum(NOOBJECT = -1,
                   ROBOT = 0,
                   SHOT = 1,
                   WALL = 2,
                   COOKIE = 3,
                   MINE = 4,
                   LAST_OBJECT_TYPE = 5)

class Twister(Robot):
    name = 'Twister'
    home_color = '228035'
    away_color = 'B7DEA9'

    def __init__(self):
        pass

    def on_radar(self, distance, object_type, radar_angle):
        self.distance = float(distance)
        self.object_type = int(object_type)
        self.radar_angle = float(radar_angle) # in unnormalized radians, IIRC

    def on_info(self, time, speed, angle):
        actions = [lambda : self.do_rotate(PartType.ROBOT, -4),
                   lambda : self.do_rotate(PartType.ROBOT, 4),
                   lambda : None]
        if self.object_type == ObjectType.ROBOT:
            actions.append(lambda : self.do_shoot(1))
        if self.distance > 4:
            actions.append(lambda : self.do_accelerate(1))
        else:
            actions.append(lambda : self.do_accelerate(-1))

        random.choice(actions)()

def main():
    from twisted.internet import stdio
    stdio.StandardIO(Twister())
    from twisted.internet import reactor
    reactor.run()

if __name__ == "__main__":
    main()
