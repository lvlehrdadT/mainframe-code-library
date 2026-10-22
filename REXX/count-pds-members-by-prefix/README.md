# Count PDS Members by Prefix

## Overview

This REXX utility counts the members of a partitioned data set (PDS) whose names start with a specified prefix.

## Use Case

Useful for counting related members in a PDS when multiple members share the same name prefix.

## Configuration

Update the `PREFIX` variable in the REXX program with the beginning of the member names you want to count.

Example:

If the PDS contains the following members:

- `BNKBACK1`
- `BNKBACK2`
- `BNKBACK3`
- `BNKLOAD1`

Set the prefix to:

`PREFIX = 'BNKBACK'`

Expected result:

`COUNT IS 3`

## Requirements

- IBM z/OS
- TSO environment
- REXX interpreter

## Program File

`count_pds_members_by_prefix.rexx`
