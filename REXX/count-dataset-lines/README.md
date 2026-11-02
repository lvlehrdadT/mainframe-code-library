**IBM z/OS | TSO/E | REXX**

Counts the number of records in a sequential data set or a PDS/PDSE member using the REXX `EXECIO` command.

## Features

- Reads the data set one record at a time.
- Counts records without loading the entire data set into memory.
- Checks allocation and read errors.
- Displays the data set name and total record count.

## Usage

Submit the following JCL to execute the REXX program in batch:

```jcl
//CNTFIL   JOB (ACCT),'COUNT DATASET',CLASS=A,MSGCLASS=X
//STEP1    EXEC PGM=IKJEFT01,REGION=0K,
//         PARM='%COUNTDS YOUR.DATA.SET'
//SYSEXEC  DD DSN=YOUR.REXX.LIBRARY,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD DUMMY
```

Replace `YOUR.REXX.LIBRARY` with the REXX library name, %COUNTDS with the rexx code member and `YOUR.DATA.SET` with the input data set name.

**Language:** REXX  
**Platform:** IBM z/OS
