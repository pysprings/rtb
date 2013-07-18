#! /usr/bin/python
import os

from twisted.internet import stdio
from twisted.protocols import basic

class Robot(basic.LineReceiver):
    delimiter = os.linesep
    name = 'twister'
    home_color = '000fff444'
    away_color = '000dddaaa'

    def lineReceived(self, line):
        # Ignore blank lines
        if not line: return 
        # Parse the command
        commandParts = line.split()
        command = commandParts[0].lower()
        args = commandParts[1:]

        # Dispatch the command to the appropriate method.  Note that all you
        # need to do to implement a new action is add another on_* method.
        try:
            method = getattr(self, 'on_' + command)
        except AttributeError, e:
            self.do_print('Error: no method for "{0}"'.format(command))
        else:
            try:
                method(*args)
            except Exception, e:
                self.do_print('Exception: ' + str(e))

    def do_print(self, message):
        """
        Print message on the message window.
        """
        self.sendLine('Print {0}'.format(message))

    def do_name(self, name):
        """
        When receiving the Initialize message with argument 1, indicating that
        this is the first sequence, you should send both your name and your
        colour. If your name ends with the string Team: teamname, you will be
        in the team teamname. For example "Name foo Team: bar" will assign you
        to the team bar and your name will be foo. All robots in a team will
        have the same colour and will recognize them over the RobotInfo
        message. For a more sophisticated possibilities, please take a look
        onto the RealTimeBattle Team Framework.
        """
        self.sendLine('Name {0}'.format(name))

    def do_color(self, home_color, away_color):
        """
        The colours are like normal football shirts, the home colour is used
        unless it is already used. Otherwise the away colour or, as a last
        resort, a non-occupied colour is selected randomly.
        """
        self.sendLine('Colour {0} {1}'.format(home_color, away_color))

    def do_accelerate(self, amount):
        """
        Set the robot acceleration. Value is bounded by Robot max/min
        acceleration.
        """
        self.sendLine('Accelerate {0}'.format(amount))

    def do_rotate(self, what, velocity):
        """
        Set the angular velocity for the robot, its cannon and/or its radar.
        Set 'what to rotate' to 1 for robot, 2 for cannon, 4 for radar or to a
        sum of these to rotate more objects at the same time. The angular
        velocity is given in radians per second and is limited by Robot
        (cannon/radar) max rotate speed.
        """
        self.sendLine('Rotate {1} {0}'.format(what, velocity))

    def do_shoot(self, energy):
        """
        Shoot with the given energy. The shot options give more information.
        """
        self.sendLine('Shoot {0}'.format(energy))

    def on_initialize(self, first):
        """
        This is the very first message the robot will get. If the argument is
        one, it is the first sequence in the tournament and it should send Name
        and Colour to the server, otherwise it should wait for YourName and
        YourColour messages.
        """
        first = bool(int(first))

        if first:
            self.do_name(self.name)
            self.do_color(self.home_color, self.away_color)

    def on_gamestarts(self):
        """This message is sent when the game starts."""

    def on_robotinfo(self, energy_level, teammate):
        """
        If you detect a robot with your radar, this message will follow, giving
        some information on the robot. The opponents energy level will be given
        in the same manner as your own energy. The second argument is only
        interesting in team-mode, 1 means a teammate and 0 an enemy.
        """

    def on_robotsleft(self, robots):
        """
        At the beginning of the game and when a robot is killed the number of
        remaining robots is broadcasted to all living robots.
        """
        robots = int(robots)

    def on_gameoption(self, opt_number, opt_value):
        """
        At the beginning of each game the robots will be sent a number of
        settings, which can be useful for the robot. For a complete list of
        these, look in the file Messagetypes.h for the game_option_type enum.
        In the options chapter you can get more detailed information on each
        option. The debug level is also sent as a game option even though it is
        not in the options list.
        """
        opt_number = int(opt_number)
        opt_value = float(opt_value)

    def on_radar(self, distance, object_type, radar_angle):
        """
        This message gives information from the radar each turn. Remember that
        the radar-angle is relative to the robot front; it is given in radians.
        """
        distance = float(distance)
        object_type = int(object_type)
        radar_angle = float(radar_angle) # in unnormalized radians, IIRC

    def on_coordinates(self, x, y, angle):
        """
        Tells you the current robot position. It is only sent if the option
        Send robot coordinates is 1 or 2. If it is 1 the coordinates are sent
        relative the starting position, which has the effect that the robot
        doesn't know where it is starting, but only where it has moved since.
        """
        x = float(x)
        y = float(y)
        angle = float(angle)

    def on_info(self, time, speed, angle):
        """
        The Info message does always follow the Radar message. It gives more
        general information on the state of the robot. The time is the
        game-time elapsed since the start of the game. This is not necessarily
        the same as the real time elapsed, due to time scale and max timestep.
        """
        time = float(time)
        speed = float(speed)
        angle = float(angle)

    def on_energy(self, energy_level):
        """
        The end of each round the robot will get to know its energy level. It
        will not, however, get the exact energy, instead it is discretized into
        a number of energy levels.
        """
        energy_level = float(energy_level)

    def on_collision(self, object_type, angle):
        """
        When a robot hits (or is hit by) something it gets this message. In the
        file Messagetypes.h you can find a list of the object types. You get
        the angle from where the collision occurred (the angle relative the
        robot) and the type of object hitting you, but not how severe the
        collision was. This can, however, be determined indirectly
        (approximately) by the loss of energy.
        """

    def on_warning(self, warning_type, message):
        warning_type = int(warning_type)
        warnings = ['UNKNOWN_MESSAGE', 'PROCESS_TIME_LOW',
                    'MESSAGE_SENT_IN_ILLEGAL_STATE', 'UNKNOWN_OPTION',
                    'OBSOLETE_KEYWORD', 'NAME_NOT_GIVEN', 'COLOUR_NOT_GIVEN']
        self.do_print(warnings[warning_type] + ": " + message)

    def on_dead(self):
        """
        Robot died. Do not try to send more messages to the server until the
        end of the game, the server doesn't read them.
        """

    def on_gamefinished(self):
        """
        Current game is finished, get prepared for the next!
        """

    def on_exitrobot(self):
        """
        Exit from the program immediately! Otherwise it will be killed
        forcefully.
        """

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
    stdio.StandardIO(Razzister())
    from twisted.internet import reactor
    reactor.run()

if __name__ == "__main__":
    main()
