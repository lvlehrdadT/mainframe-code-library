
/* REXX */
/*----------------------------------------------------------------*/
/* Program : LIST_DASD_USAGE                                      */
/* Purpose : Display DASD volume serials and usage percentages     */
/* Platform: IBM z/OS - TSO/E                                     */
/* Requires: MXI REXX interface                                   */
/*----------------------------------------------------------------*/

PARSE ARG MXICMD

/* Set the default MXI command. */
IF MXICMD = '' THEN
    MXICMD = 'DASD VOL*'

/* Configure the MXI REXX interface. */
MXIREXX_SERVER    = 'MXI'
MXIREXX_STEMLEVEL = 2

/* Load the MXI REXX interface. */
ADDRESS TSO CALL 'YOUR.MXI.LOADLIB(MXIREXX)'

/* Execute the MXI command. */
LRC = MXIREXX('LINE.', MXICMD)

IF LRC = 0 THEN DO

    SAY 'MXI COMMAND SUCCESSFUL. OUTPUT:'

    DO I = 1 TO LINE.0

        L = LINE.I

        /* Skip MXI messages, headers, and empty lines. */
        IF POS('MXI', L) > 0 THEN ITERATE
        IF POS('VOLSER', L) > 0 THEN ITERATE
        IF STRIP(L) = '' THEN ITERATE

        /* Extract volume serial and usage percentage. */
        VOL = SUBSTR(L, 1, 6)
        USD = SUBSTR(L, 52, 6)

        SAY 'VOLSER:' VOL '%USE:' USD

    END

END
ELSE
    SAY 'MXI COMMAND FAILED, RC=' LRC

EXIT 0
