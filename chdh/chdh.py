import os
import sys
import re
import argparse
import random
from datetime import date, datetime, timedelta

# choose daily hosts

_script_name = os.path.basename(sys.argv[0])
_script_version = "2022.08.29"

class StoreDateAction(argparse.Action):
    def __init__(self, option_strings, dest, nargs = None, **kwargs):
        if nargs is not None:
            raise ValueError("nargs not allowed")
        super().__init__(option_strings, dest, **kwargs)

    def __call__(self, parser, namespace, values, option_string = None):
        if re.match(r"\d{4}-\d{1,2}-\d{1,2}", values) is None:
            raise ValueError(f"date format not correct: {values}")
        x = map(lambda x : int(x), values.split("-"))
        setattr(namespace, self.dest, date(*x))

class StoreEmployeesAction(argparse.Action):
    def __init__(self, option_strings, dest, nargs = None, **kwargs):
        if nargs is not None:
            raise ValueError("nargs not allowed")
        super().__init__(option_strings, dest, **kwargs)

    def __call__(self, parser, namespace, values, option_string = None):
        if not os.path.exists(values):
            raise ValueError(f"file not found: {values}")

        with open(values, mode = "rt", encoding = "UTF-8") as f:
            fc = f.read().splitlines()

        setattr(namespace, self.dest, fc)

parser = argparse.ArgumentParser(
    prog = _script_name,
    description = "Choose Daily hosts.",
    formatter_class = argparse.RawDescriptionHelpFormatter
)

parser.add_argument(
    '-v', '--version',
    action = "version",
    version = _script_version
)

parser.add_argument(
    '-s', '--start-date',
    action = StoreDateAction,
    type = str,
    required = True,
    help = "Second day of the sprint.",
    metavar = "YYYY-MM-DD"
)

parser.add_argument(
    '-e', '--end-date',
    action = StoreDateAction,
    type = str,
    required = True,
    help = "Last day of the sprint.",
    metavar = "YYYY-MM-DD"
)

parser.add_argument(
    '-t', '--team',
    action = StoreEmployeesAction,
    type = str,
    required = True,
    help = "Employees' list.",
    metavar = "FILE_PATH"
)

args = parser.parse_args()

# https://stackoverflow.com/a/153667
def date_span(start_date, end_date, delta = timedelta(days = 1)):
    current_date = start_date
    while current_date <= end_date:
        yield current_date
        current_date += delta

def get_host():
    return random.choice(args.team)

team_size = len(args.team)

last_host = ""
processed = []

for day in date_span(args.start_date, args.end_date):
    if day.weekday() in [5, 6]:
        continue

    if len(processed) == team_size:
        processed = []

    host = get_host()

    if len(processed) == 0:
        processed.append(host)
    else:
        while host in processed or host == last_host:
            host = get_host()

        processed.append(host)
        last_host = host

    print(f"{day} - {host}")
