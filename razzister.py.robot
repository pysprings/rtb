#! /usr/bin/python
from robot import Robot

class Razzister(Robot):
    name = 'Razzister'
    home_color = 'fff000000'
    away_color = '000ffffff'
    def on_info(self, time, speed, angle):
        self.do_accelerate(0.5)
        self.do_rotate(7, 3)
        for __ in xrange(10):
            self.do_shoot(10)

def main():
    from twisted.internet import stdio
    stdio.StandardIO(Razzister())
    from twisted.internet import reactor
    reactor.run()

if __name__ == "__main__":
    main()
