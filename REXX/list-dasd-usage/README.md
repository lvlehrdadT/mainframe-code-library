# List DASD Usage

A REXX utility for IBM z/OS that uses the MXI interface to display DASD volume serials and their usage percentages.

## Overview

This program executes an MXI DASD command, processes the returned output, and displays the volume serial and usage percentage for each matching volume.

## Requirements

- IBM z/OS
- TSO/E with REXX support
- MXI installed and configured
- Access to the MXI REXX interface

## Configuration

Before running the program, update the following values to match your environment.

### 1. MXI Library

Find this statement in the program:

`ADDRESS TSO CALL 'YOUR.MXI.LOADLIB(MXIREXX)'`

Replace `YOUR.MXI.LOADLIB` with the data set name of the MXI load library available in your environment.

### 2. DASD Volume Pattern

The default command is:

`MXICMD = 'DASD VOL*'`

Replace `VOL*` with the volume serial pattern you want to search for.

Examples:

- `DASD PROD*` — Select volumes whose serials start with `PROD`.
- `DASD VOL001` — Select a specific volume, if supported by your MXI command syntax.

The pattern must be valid for your MXI installation.

## Execution

Run the REXX program in a TSO environment using your site's normal REXX execution procedure.

The program uses `DASD VOL*` when no command argument is supplied. If an MXI command is passed as an argument, it uses that command instead.

## Example Output

```text
MXI COMMAND SUCCESSFUL. OUTPUT:
VOLSER: VOL001 %USE: 85
VOLSER: VOL002 %USE: 42
VOLSER: VOL003 %USE: 97
```

The values above are illustrative examples, not actual system results.

## Notes

- The program relies on fixed column positions in the MXI output.
- Output formatting may differ between MXI environments.
- Review the extraction positions if your MXI output layout differs.
