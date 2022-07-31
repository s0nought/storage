# mktr.sh

## Description
Just a shell to run a python script against all work report files.

## Usage

`mktr.sh <target_dir>`

## Positional and/or Named arguments

`$1` - target directory (work reports directory)

## Example

`mktr.sh "~/work"`

# mktr.py

## Description
Parses working hours from the input file(s) and writes it to the time report file.

## Usage

`mktr.py <file_name> <file_path> <output_dir>`

## Positional and/or Named arguments

`sys.argv[1]` - work report file name
`sys.argv[2]` - work report file path
`sys.argv[3]` - time report output directory

## Example

`mktr.py "2022.07.29.md" "~/work/2022/07/29" "~/Desktop"`