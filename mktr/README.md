# mktr.sh

## Description
Iterate through all files in the target directory that match the pattern `<target directory>/<year>/<month>/<year>.<month>.<day>.md`

## Usage

`./mktr.sh <target_dir>`

## Positional and/or Named arguments

`$1` - string; full path to target directory

## Example

`./mktr.sh "~/work"`

# mktr.py

## Description
Reads the input file and finds all occurrences of the pattern `[0-9]{2}:[0-9]{2} - [0-9]{2}:[0-9]{2}`

Forms a CSV row and writes it to the output file.

Output CSV file field names are as follows:
- day_total_mark
- date
- over_goal_minutes
- below_goal_minutes
- time_in
- time_out
- year
- month
- day
- hour_in
- minute_in
- hour_out
- minute_out

Since there might be multiple occurrences of the mentioned pattern for a single day, special rows are written to represent the sum of matches for the day in question (day_total_mark == x).

## Usage

`mktr.py <file_name> <file_path> <output_dir>`

## Positional and/or Named arguments

`sys.argv[1]` - string; file name

`sys.argv[2]` - string; file path

`sys.argv[3]` - string; output directory

## Example

`mktr.py "2022.07.29.md" "~/work/2022/07/29" "~/Desktop"`
