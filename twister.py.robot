#! /usr/bin/python
import os

from twisted.internet import stdio
from twisted.protocols import basic

class Robot(basic.LineReceiver):
    delimiter = os.linesep

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
                self.sendLine('Error: ' + str(e))

    def do_print(self, message):
        self.sendLine('Print {0}'.format(message))

    def on_initialize(self, first):
        first = bool(int(first))


def main():
    stdio.StandardIO(Robot())
    from twisted.internet import reactor
    reactor.run()

if __name__ == "__main__":
    main()
