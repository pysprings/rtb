#! /usr/bin/python
from robot import Robot

class Twister(Robot):
    name = 'Twister'
    home_color = '228035'
    away_color = 'B7DEA9'
    def on_radar(self, distance, object_type, radar_angle):
        """
        This message gives information from the radar each turn. Remember that
        the radar-angle is relative to the robot front; it is given in radians.
        """
        self.do_print(' '.join([distance, object_type, radar_angle]))

def main():
    from twisted.internet import stdio
    stdio.StandardIO(Twister())
    from twisted.internet import reactor
    reactor.run()

if __name__ == "__main__":
    main()
