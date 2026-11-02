/* REXX */

/* Get the data set name from the command line */
PARSE ARG DSNAME

IF DSNAME = '' THEN DO
    SAY 'ERROR: PLEASE PROVIDE A DATA SET NAME.'
    EXIT 8
END

/* Allocate the input data set */
"ALLOC F(INPUT) DA('"DSNAME"') SHR REUSE"

IF RC <> 0 THEN DO
    SAY 'ERROR: DATA SET ALLOCATION FAILED. RC=' RC
    EXIT 8
END

COUNTFILE = 0
READ_RC = 0

/* Read the data set one record at a time */
DO FOREVER
    "EXECIO 1 DISKR INPUT (STEM DATALINES."

    IF RC = 1 THEN LEAVE

    IF RC <> 0 THEN DO
        READ_RC = RC
        LEAVE
    END

    IF DATALINES.0 = 0 THEN LEAVE

    COUNTFILE = COUNTFILE + 1
END

/* Close and free the input data set */
"EXECIO 0 DISKR INPUT (FINIS"
FINIS_RC = RC

"FREE F(INPUT)"
FREE_RC = RC

/* Display the result */
IF READ_RC <> 0 THEN
    SAY 'ERROR: DATA SET READ FAILED. RC=' READ_RC
ELSE DO
    SAY '**********************************************************'
    SAY '  DATA SET NAME  = ' DSNAME
    SAY '  RECORD COUNT   = ' COUNTFILE
    SAY '**********************************************************'
END

IF FINIS_RC <> 0 THEN
    SAY 'WARNING: EXECIO FINIS RETURN CODE = ' FINIS_RC

IF FREE_RC <> 0 THEN
    SAY 'WARNING: FREE RETURN CODE = ' FREE_RC

IF READ_RC <> 0 THEN
    EXIT 8

EXIT 0
