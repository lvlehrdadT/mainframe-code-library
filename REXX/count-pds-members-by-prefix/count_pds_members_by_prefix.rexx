
/* REXX */
/*------------------------------------------------------------*/
/* Program : COUNT_PDS_MEMBERS_BY_PREFIX                      */
/* Purpose : Count PDS members whose names start with a       */
/*           specified prefix.                                */
/*------------------------------------------------------------*/

PARSE ARG DSNAME

ADDRESS TSO

DSNAME = STRIP(DSNAME)

IF DSNAME = '' THEN DO
    SAY 'ERROR: DATASET NAME IS REQUIRED.'
    SAY 'USAGE: EX: COUNTMEM ''YOUR.PDS.NAME'''
    EXIT 8
END

PREFIX = 'NAME_FOR_SEARCH'
CNT = 0

SAY 'DSN IS' DSNAME

X = OUTTRAP('LIST.')

"LISTDS '"DSNAME"' MEMBERS"
TRAP_RC = RC

X = OUTTRAP('OFF')

IF TRAP_RC <> 0 THEN DO
    SAY 'ERROR: LISTDS FAILED.'
    SAY 'RC =' TRAP_RC
    EXIT TRAP_RC
END

DO I = 1 TO LIST.0
    LINE = STRIP(LIST.I)

    IF LEFT(LINE, LENGTH(PREFIX)) = PREFIX THEN
        CNT = CNT + 1
END

SAY 'PREFIX IS' PREFIX
SAY 'COUNT IS' CNT

EXIT 0
