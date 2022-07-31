# prunc.sh

## Description
A shell script (bash) to manages PTS/PNTS services with one-liners.

Usage:

    prunc.sh <command> [prefix]

Where:  
'command' will be executed once for each of the services  
'prefix' is the prefix of the services to execute the command against  

Supported commands:

<table>
    <tr>
        <td>-h, --help</td>
        <td>Display help and exit</td>
    </tr>
    <tr>
        <td>-v, --version</td>
        <td>Display version and exit</td>
    </tr>
    <tr>
        <td>sa, sta, start</td>
        <td>Execute command 'start'</td>
    </tr>
    <tr>
        <td>so, sto, stop</td>
        <td>Execute command 'stop'</td>
    </tr>
    <tr>
        <td>rr, res, restart</td>
        <td>Execute command 'restart'</td>
    </tr>
    <tr>
        <td>ss, status</td>
        <td>Execute command 'status'</td>
    </tr>
</table>

Example:

    prunc.sh -h
    prunc.sh rr
    prunc.sh rr pnts22

Supported working modes:
- Manual
    - Specify both the command and the prefix.  
      Example: prunc.sh rr pnts22
- Predefined prefix
    - Specify the command only.  
      Example: prunc.sh rr  
      The environment variable 'prunc_prefix' must be created beforehand.  
      To create the variable run: export prunc_prefix=\[prefix\]
- Select the prefix
    - Specify the command only.  
      Example: prunc.sh rr  
      The environment variable 'prunc_prefix' must not exist.  
      The program will attempt to define a list of available prefixes.  
      If any, a menu to select the prefix will be displayed.

Notes:  
Working mode #3 makes use of the list of hardcoded prefixes.  
The list of postfixes for PTS/PNTS services is also hardcoded.
