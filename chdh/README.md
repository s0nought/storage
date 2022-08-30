# chdh.py

## Description
Choose Daily hosts randomly.

## Usage

`chdh.py -s YYYY-MM-DD -e YYYY-MM-DD -t FILE_PATH`

## Positional and/or Named arguments

-h, --help  
show the help message and exit

-v, --version  
show program's version number and exit

-s YYYY-MM-DD, --start-date YYYY-MM-DD  
Second day of the sprint.

-e YYYY-MM-DD, --end-date YYYY-MM-DD  
Last day of the sprint.

-t FILE_PATH, --team FILE_PATH  
Employees' list.

## Example

`chdh.py -s 2022-8-30 -e 2022-9-9 -t employees.txt`