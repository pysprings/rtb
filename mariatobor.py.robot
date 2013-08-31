#! /usr/bin/python
import random
from robot import Robot

class MariaTobor(Robot):
    name = 'MariaTobor'
    home_color = '123456789'
    away_color = '987654321'

    def on_info(self, time, speed, angle):
        self.do_accelerate(random.random())
        time = float(time)
        if time % 2 < 1:
            rotate_amount = 9
        else:
            rotate_amount = -9
        self.do_rotate(rotate_amount, 3)
        for __ in xrange(random.randrange(10)):
            self.do_shoot(10)

def main():
    from twisted.internet import stdio
    stdio.StandardIO(MariaTobor())
    from twisted.internet import reactor
    reactor.run()

if __name__ == "__main__":
    main()
