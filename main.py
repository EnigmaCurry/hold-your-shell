#!/usr/bin/env python3
import curses
import textwrap
import subprocess
import sys
import os
import shlex


def main(stdscr, script_text, interpreter):
    # initialize curses modes and color
    curses.curs_set(0)
    curses.noecho()
    curses.cbreak()
    stdscr.keypad(True)
    curses.start_color()
    curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLACK)
    stdscr.bkgd(" ", curses.color_pair(1))
    stdscr.clear()

    # layout
    height, width = stdscr.getmaxyx()
    pager_height = height - 2  # leave room for separator & prompt

    # wrap script text into lines
    lines = []
    for line in script_text.splitlines() or [""]:
        wrapped = textwrap.wrap(line, width - 1) or [""]
        lines.extend(wrapped)

    max_offset = max(len(lines) - pager_height, 0)
    offset = 0

    # confirmation options
    options = ["Yes", "No"]
    selection = 1  # default to "No"

    # prepare prompt with interpreter name
    prog_name = " ".join(interpreter)
    prompt = f"Do you want to run this script via {prog_name}?"

    while True:
        stdscr.erase()

        # display pager content
        for i in range(pager_height):
            idx = offset + i
            if idx < len(lines):
                stdscr.addstr(i, 0, lines[idx])

        # separator
        stdscr.hline(pager_height, 0, curses.ACS_HLINE, width)

        # prompt + buttons
        stdscr.addstr(pager_height + 1, 0, prompt)
        x = len(prompt) + 2
        for idx, opt in enumerate(options):
            if idx == selection:
                stdscr.attron(curses.A_REVERSE)
            stdscr.addstr(pager_height + 1, x, f" {opt} ")
            if idx == selection:
                stdscr.attroff(curses.A_REVERSE)
            x += len(opt) + 3

        stdscr.refresh()

        # input handling
        key = stdscr.getch()
        if key in (curses.KEY_UP, ord("k")):
            offset = max(0, offset - 1)
        elif key in (curses.KEY_DOWN, ord("j")):
            offset = min(offset + 1, max_offset)
        elif key == curses.KEY_NPAGE:
            offset = min(offset + pager_height, max_offset)
        elif key == curses.KEY_PPAGE:
            offset = max(0, offset - pager_height)
        elif key == curses.KEY_LEFT:
            selection = max(0, selection - 1)
        elif key == curses.KEY_RIGHT:
            selection = min(len(options) - 1, selection + 1)
        elif key in (curses.KEY_ENTER, 10, 13):
            return options[selection]


def run():
    # require piped stdin
    if sys.stdin.isatty():
        print(
            "Error: this tool expects a script via stdin; please pipe a script.",
            file=sys.stderr,
        )
        sys.exit(1)

    script_text = sys.stdin.read()
    if not script_text.strip():
        print("Error: no script provided on stdin.", file=sys.stderr)
        sys.exit(1)

    # parse shebang or default
    interpreter = ["/bin/bash", "-s"]
    lines = script_text.splitlines()
    if lines and lines[0].startswith("#!"):
        shebang = lines[0][2:].strip()
        interpreter = shlex.split(shebang)

    # redirect stdio to controlling TTY for curses
    try:
        fd = os.open("/dev/tty", os.O_RDWR)
        os.dup2(fd, 0)
        os.dup2(fd, 1)
        os.dup2(fd, 2)
    except OSError:
        pass

    # launch TUI
    try:
        choice = curses.wrapper(main, script_text, interpreter)
    except Exception:
        curses.endwin()
        raise

    # execute or cancel
    if choice == "Yes":
        result = subprocess.run(interpreter, input=script_text, text=True)
        sys.exit(result.returncode)
    else:
        print("Cancelled.")
        sys.exit(1)


if __name__ == "__main__":
    run()
