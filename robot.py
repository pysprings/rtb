#! /usr/bin/python
import os

from twisted.internet import stdio
from twisted.protocols import basic

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

GameOption = enum(
    ROBOT_MAX_ROTATE=0,
    ROBOT_CANNON_MAX_ROTATE=1, 
    ROBOT_RADAR_MAX_ROTATE=2,
    ROBOT_MAX_ACCELERATION=3, 
    ROBOT_MIN_ACCELERATION=4,
    ROBOT_START_ENERGY=5, 
    ROBOT_MAX_ENERGY=6, 
    ROBOT_ENERGY_LEVELS=7,
    SHOT_SPEED=8, 
    SHOT_MIN_ENERGY=9, 
    SHOT_MAX_ENERGY=10,
    SHOT_ENERGY_INCREASE_SPEED=11,
    TIMEOUT=12,
    DEBUG_LEVEL=13,
    SEND_ROBOT_COORDINATES= 14)

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
        self.sendLine('Rotate {0} {1}'.format(what, velocity))

    def do_rotateto(self, what, velocity, angle):
        self.sendLine('RotateTo {0} {1} {2}'.format(what, velocity, angle))

    def do_rotateamount(self, what, velocity, angle):
        """
        Rotate the given part (robot, turret or radar) to the given angle,
        at the given velocity, relative to the current angle.
        """
        self.sendLine('RotateAngle {0} {1} {2}'.format(what, velocity, angle))

    def do_sweep(self, what, velocity, right_angle, left_angle):
        """
        This does not work with the robot. This will set the radar or turret to
        sweep between the given angles at the given angular velocity.

        NOTE: There may be an error where the radar does not report events when
        in sweep mode.
        """
        self.sendLine('Sweep {0} {1} {2} {3}'.format(what, velocity,
            right_angle, left_angle))

    def do_shoot(self, energy):
        """
        Shoot with the given energy. The shot options give more information.
        """
        self.sendLine('Shoot {0}'.format(energy))

    def do_brake(self, portion):
        """
        Applies the brake. `Portion' ranges from 0.0 to 1.0, where
        1.0 means that the friction is equal to the (world-defined) 
        slide friction
        """
        self.sendLine('Brake {0}'.format(portion))

    def do_debug(self, message):
        """
        Prints a message in the message window if in debug mode.

        TODO:
        Maybe turn off this command if it's not in debug mode
        """
        self.sendLine('Debug {0}'.format(message))

    def do_debugline(self, angle1, radius1, angle2, radius2):
        """
        From the docs:
        Draw a line direct to the arena. This is only allowed in the highest
        debug level(5), otherwise a warning message is sent. The arguments are
        the start and end point of the line given in polar coordinates relative
        to the robot.

        All of the arguments are doubles.
        """
        self.sendLine('DebugLine {0} {1} {2} {3}'.format(angle1, radius1,
            angle2, radius2))

    def do_debugcircle(self, center_angle, center_radius, circle_radius):
        """
        From the docs:
        Similar to DebugLine above, but draws a circle. The first two arguments
        are the angle and radius of the central point of the circle relative to
        the robot. The third argument gives the radius of the circle.

        All arguments are doubles
        """
        self.sendLine('DebugCircle {0} {1} {2}'.format(center_angle,
            center_radius, circle_radius))

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
        if opt_number == GameOption.ROBOT_MAX_ROTATE:
            self.max_rotation = opt_value
        elif opt_number == GameOption.ROBOT_CANNON_MAX_ROTATE:
            self.max_cannon_rotation = opt_value
        elif opt_number == GameOption.ROBOT_RADAR_MAX_ROTATE:
            self.max_radar_rotation = opt_value
        elif opt_number == GameOption.ROBOT_MAX_ACCELERATION:
            self.robot_max_acceleration = opt_value
        elif opt_number == GameOption.ROBOT_MIN_ACCELERATION:
            self.robot_min_acceleration = opt_value
        elif opt_number == GameOption.ROBOT_MAX_ENERGY:
            self.max_energy = opt_value
        elif opt_number == GameOption.ROBOT_ENERGY_LEVELS:
            self.energy_levels = opt_value
        elif opt_number == GameOption.SHOT_SPEED:
            self.robot_speed = opt_value
        elif opt_number == GameOption.SHOT_MIN_ENERGY:
            self.shot_min_energy = opt_value
        elif opt_number == GameOption.SHOT_MAX_ENERGY:
            self.shot_max_energy = opt_value
        elif opt_number == GameOption.TIMEOUT:
            self.timeout = opt_value
        elif opt_number == GameOption.DEBUG_LEVEL:
            self.debug_level = opt_value
        elif opt_number == GameOption.SEND_ROBOT_COORDINATES:
            self.send_coordinates = opt_value
        else:
            self.do_debug('Error: Unknown game option {0}'.format(opt_value))

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
