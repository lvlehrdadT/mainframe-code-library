# REXX – FTP File Size and Download

A REXX program for IBM z/OS that connects to an FTP server, searches for a specified remote file, retrieves its file size, and downloads it to a sequential data set.

## Overview

This program demonstrates how to use the FTPAPI interface in REXX to communicate with an FTP server and retrieve remote file information.

It also demonstrates how to use TSO commands and the FTP client to allocate a data set and transfer a remote file to z/OS.

## Features

- Connects to an FTP server using FTPAPI.
- Retrieves the remote directory listing.
- Searches for a specified file by name.
- Retrieves the file size using the FTP `QUOTE SIZE` command.
- Converts the file size from bytes to megabytes.
- Allocates a sequential data set on specified DASD volumes.
- Downloads the remote file to the allocated data set using FTP.

## Configuration

Update the following variables before running the program:

| Variable | Description |
|---|---|
| `HST` | FTP server IP address or hostname |
| `USR` | FTP username |
| `PASS` | FTP password |
| `FILE_name` | Name of the remote file |
| `DS` | Target data set name |
| `DSKPFX` | DASD volume serial prefix |

The volume suffix configuration must also be initialized according to the volume naming convention used in the target environment.

## Requirements

- IBM z/OS
- TSO/E REXX
- FTPAPI interface
- FTP server access
- Appropriate permissions to allocate and delete data sets
- Access to the specified DASD volumes

## Notes

- The program uses FTPAPI for FTP connection management and remote file information retrieval.
- The actual file transfer is performed using the z/OS FTP client.
- The data set allocation parameters, including record format, logical record length, block size, and volume configuration, may need to be adjusted for the target environment.
- Replace all sample connection details with environment-specific values before execution.

**Language:** REXX  
**Platform:** IBM z/OS / TSO/E  
**Interface:** FTPAPI
