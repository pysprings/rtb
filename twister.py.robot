#! /usr/bin/python
print 'RobotOption 3 0'
print 'RobotOption 1 1\n'
print 'Name twister'
print 'Colour ee299 aaffaa\n'
x = raw_input()
while x != 'Dead' or x != 'GameFinishes':
    print 'Accelerate 0.5\n'
    print 'Rotate 7 3\n'
    for i in range(0,10):
        print 'Shoot 10\n'
    x = raw_input()
