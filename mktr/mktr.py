import sys
import re
import datetime
import csv
import os.path

# make time report

_script_name = os.path.basename(sys.argv[0])
_script_version = "2022.08.08"

_TIME_GOAL_MIN = 540

_file_name = sys.argv[1]
_file_path = sys.argv[2]

_report_file_dir = sys.argv[3]
_report_file_name = "time_report.csv"
_report_file_path = f"{_report_file_dir}/{_report_file_name}"

_year, _month, _day, _file_ext = _file_name.split(".")

_date = f"{_day}/{_month}/{_year}"

with open(_file_path, mode = "rt", encoding = "utf-8") as f:
    fc = f.readlines()

with open(_report_file_path, "a", newline = "") as csvfile:
    fieldnames = [
        "day_total_mark", "date",
        "over_goal_minutes", "below_goal_minutes",
        "time_in", "time_out",
        "year", "month", "day",
        "hour_in", "minute_in",
        "hour_out", "minute_out"
        ]

    csv_writer = csv.DictWriter(csvfile, fieldnames = fieldnames)

    if os.path.getsize(_report_file_path) == 0:
        csv_writer.writeheader()

    _td_minutes_total = 0

    for line in fc:
        _matches = re.findall(r"[0-9]{2}:[0-9]{2} - [0-9]{2}:[0-9]{2}", line)

        if len(_matches) > 0:
            for _match in _matches:
                _time_in, _time_out = _match.split(" - ")
                _hour_in, _minute_in = _time_in.split(":")
                _hour_out, _minute_out = _time_out.split(":")

                t1 = datetime.datetime.fromisoformat(
                    f"{_year}-{_month}-{_day} {_hour_in}:{_minute_in}:00.000000"
                )

                t2 = datetime.datetime.fromisoformat(
                    f"{_year}-{_month}-{_day} {_hour_out}:{_minute_out}:00.000000"
                )

                td = t2 - t1

                td_minutes = td.seconds // 60
                _td_minutes_total += td_minutes

                csv_writer.writerow({
                    "day_total_mark": "-",
                    "date": _date,
                    "over_goal_minutes": "-",
                    "below_goal_minutes": "-",
                    "time_in": _time_in,
                    "time_out": _time_out,
                    "year": _year,
                    "month": _month,
                    "day": _day,
                    "hour_in": _hour_in,
                    "minute_in": _minute_in,
                    "hour_out": _hour_out,
                    "minute_out": _minute_out
                })

    if _td_minutes_total > _TIME_GOAL_MIN:
        _over_goal_minutes = _td_minutes_total - _TIME_GOAL_MIN
        _below_goal_minutes = 0
    else:
        _over_goal_minutes = 0
        _below_goal_minutes = _TIME_GOAL_MIN - _td_minutes_total

    csv_writer.writerow({
        "day_total_mark": "x",
        "date": _date,
        "over_goal_minutes": _over_goal_minutes,
        "below_goal_minutes": _below_goal_minutes,
        "time_in": "-",
        "time_out": "-",
        "year": "-",
        "month": "-",
        "day": "-",
        "hour_in": "-",
        "minute_in": "-",
        "hour_out": "-",
        "minute_out": "-"
    })