#! /usr/bin/python
import collections
import sys

from robot import Robot

def enum(*sequential, **named):
    enums = dict(zip(sequential, range(len(sequential))), **named)
    reverse = dict((value, key) for key, value in enums.iteritems())
    enums['reverse_mapping'] = reverse
    return type('Enum', (), enums)

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
        self.cookie_seen = False

    def on_radar(self, distance, object_type, radar_angle):
        object_type = int(object_type)
        """
        This message gives information from the radar each turn. Remember that
        the radar-angle is relative to the robot front; it is given in radians.
        """
        sys.stderr.write("{0}\n"
                         .format(ObjectType.reverse_mapping[object_type]))
        if object_type == ObjectType.COOKIE:
            self.cookie_seen = True
            self.do_print("Cookie Seen!")
            self.cookie_angle = float(radar_angle)

    def on_info(self, time, speed, angle):
        if self.cookie_seen:
            self.do_accelerate(1)
            self.do_rotate(7, -3)
        else:
            self.do_rotate(7, 3)

def main():
    from twisted.internet import stdio
    stdio.StandardIO(Twister())
    from twisted.internet import reactor
    reactor.run()

if __name__ == "__main__":
    main()
