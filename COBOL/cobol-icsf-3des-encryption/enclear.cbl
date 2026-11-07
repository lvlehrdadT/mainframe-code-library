
      *------------------------------------------------------------*
      * PROGRAM : ENCLEAR                                          *
      * PURPOSE : 3DES ENCRYPTION USING CLEAR KEY                   *
      *           DB2 INTEGRATION WITH IBM ICSF                    *
      *------------------------------------------------------------*

       IDENTIFICATION DIVISION.
       PROGRAM-ID. ENCLEAR.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *------------------------------------------------------------*
      * ICSF RETURN CODES                                           *
      *------------------------------------------------------------*

       01 WS-RETURN-CODE          PIC 9(08) COMP VALUE ZERO.
       01 WS-REASON-CODE          PIC 9(08) COMP VALUE ZERO.
       01 WS-EXIT-DATA-LENGTH     PIC 9(08) COMP VALUE ZERO.
       01 WS-EXIT-DATA            PIC X(04) VALUE SPACES.

      *------------------------------------------------------------*
      * ENCRYPTION RULE ARRAY                                       *
      *------------------------------------------------------------*

       01 WS-RULE-ARRAY-COUNT     PIC 9(08) COMP VALUE 1.
       01 WS-RULE-ARRAY           PIC X(08) VALUE 'DES     '.

      *------------------------------------------------------------*
      * CLEAR KEY CONFIGURATION                                     *
      *------------------------------------------------------------*

       01 WS-KEY-LENGTH           PIC 9(08) COMP VALUE 24.
       01 WS-CLEAR-KEY            PIC X(24) VALUE
          '123456789012345678901234'.

      *------------------------------------------------------------*
      * ENCRYPTION PARAMETERS                                       *
      *------------------------------------------------------------*

       01 WS-KEY-PARMS-LENGTH     PIC 9(08) COMP VALUE ZERO.
       01 WS-KEY-PARMS            PIC X(04) VALUE SPACES.

       01 WS-BLOCK-SIZE           PIC 9(08) COMP VALUE 8.
       01 WS-IV-LENGTH            PIC 9(08) COMP VALUE 8.
       01 WS-IV                   PIC X(08) VALUE LOW-VALUES.

       01 WS-CHAIN-LEN            PIC 9(08) COMP VALUE 16.
       01 WS-CHAIN-DATA           PIC X(16) VALUE LOW-VALUES.

       01 WS-TEXT-LEN             PIC 9(08) COMP VALUE 24.
       01 WS-CLEAR-TEXT           PIC X(24) VALUE 'HELLO0123'.
       01 WS-CIPHER-TEXT          PIC X(24).
       01 WS-DECRYPTED-TEXT       PIC X(24).

       01 WS-OPT-LEN              PIC 9(08) COMP VALUE ZERO.
       01 WS-OPT-DATA             PIC X(04) VALUE SPACES.

      *------------------------------------------------------------*
      * HEX CONVERSION VARIABLES                                    *
      *------------------------------------------------------------*

       01 WS-I                    PIC 9(04) COMP VALUE ZERO.
       01 WS-BYTE                 PIC 9(04) COMP.
       01 WS-HIGH                 PIC 9(02) COMP.
       01 WS-LOW                  PIC 9(02) COMP.

       01 WS-HEX-TABLE            PIC X(16)
          VALUE '0123456789ABCDEF'.
       01 WS-HEX-OUT              PIC X(02).

      *------------------------------------------------------------*
      * DB2 HOST VARIABLES                                          *
      *------------------------------------------------------------*

       01 DCLPAN.
          10 WS-PAN               PIC S9(19)V COMP-3.
          10 PAN-ID               PIC S9(10)V COMP-3.

       01 IND1                    PIC S9(4) COMP.
       01 IND2                    PIC S9(4) COMP.

      *------------------------------------------------------------*
      * DB2 SQLCA AND CURSOR                                        *
      *------------------------------------------------------------*

           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.

           EXEC SQL
               DECLARE CURRSP CURSOR WITH HOLD FOR
               SELECT
                   PAN_ID,
                   PAN
               FROM INSTANCE.SCHEMA.TABLENAME
               FETCH FIRST 1 ROWS ONLY
               WITH UR
           END-EXEC.

       PROCEDURE DIVISION.

      *============================================================*
      * STEP 1: FETCH DATA FROM DB2                                 *
      *============================================================*

           EXEC SQL
               OPEN CURRSP
           END-EXEC.

           DISPLAY 'SQLCODE OPEN: ' SQLCODE.

           EXEC SQL
               FETCH CURRSP
               INTO
                   :PAN-ID :IND1,
                   :WS-PAN :IND2
           END-EXEC.

           DISPLAY 'SQLCODE FETCH: ' SQLCODE.
           DISPLAY 'PAN-ID: ' PAN-ID.

           MOVE WS-PAN TO WS-CLEAR-TEXT.

           DISPLAY '=== 3DES ENCRYPTION - CLEAR KEY ==='.
           DISPLAY 'CLEAR TEXT: ' WS-CLEAR-TEXT.

      *============================================================*
      * STEP 2: ENCRYPT DATA USING ICSF CSNBSYE                     *
      *============================================================*

           CALL 'CSNBSYE' USING
               WS-RETURN-CODE
               WS-REASON-CODE
               WS-EXIT-DATA-LENGTH
               WS-EXIT-DATA
               WS-RULE-ARRAY-COUNT
               WS-RULE-ARRAY
               WS-KEY-LENGTH
               WS-CLEAR-KEY
               WS-KEY-PARMS-LENGTH
               WS-KEY-PARMS
               WS-BLOCK-SIZE
               WS-IV-LENGTH
               WS-IV
               WS-CHAIN-LEN
               WS-CHAIN-DATA
               WS-TEXT-LEN
               WS-CLEAR-TEXT
               WS-TEXT-LEN
               WS-CIPHER-TEXT
               WS-OPT-LEN
               WS-OPT-DATA.

           DISPLAY 'ENCRYPTION RETURN CODE: '
               WS-RETURN-CODE.
           DISPLAY 'ENCRYPTION REASON CODE: '
               WS-REASON-CODE.

      *============================================================*
      * STEP 3: CONVERT CIPHER TEXT TO HEXADECIMAL                  *
      *============================================================*

           DISPLAY 'CIPHER HEX: ' WITH NO ADVANCING.

           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-TEXT-LEN

               COMPUTE WS-BYTE =
                   FUNCTION ORD(WS-CIPHER-TEXT(WS-I:1)) - 1

               DIVIDE WS-BYTE BY 16
                   GIVING WS-HIGH
                   REMAINDER WS-LOW

               MOVE WS-HEX-TABLE(WS-HIGH + 1:1)
                   TO WS-HEX-OUT(1:1)

               MOVE WS-HEX-TABLE(WS-LOW + 1:1)
                   TO WS-HEX-OUT(2:1)

               DISPLAY WS-HEX-OUT WITH NO ADVANCING

           END-PERFORM.

           DISPLAY SPACE.

      *============================================================*
      * STEP 4: INSERT ENCRYPTED DATA INTO DB2                      *
      *============================================================*

           EXEC SQL
               INSERT INTO SCHEMA2.TABLENAME2
               (
                   ID,
                   PAN
               )
               VALUES
               (
                   :PAN-ID :IND1,
                   :WS-CIPHER-TEXT
               )
           END-EXEC.

           DISPLAY 'INSERT SQLCODE: ' SQLCODE.

           EXEC SQL
               CLOSE CURRSP
           END-EXEC.

           EXEC SQL
               COMMIT WORK
           END-EXEC.

      *============================================================*
      * STEP 5: DECRYPT DATA USING ICSF CSNBSYD                     *
      *============================================================*

           MOVE LOW-VALUES TO WS-CHAIN-DATA.
           MOVE ZERO TO WS-RETURN-CODE.
           MOVE ZERO TO WS-REASON-CODE.

           CALL 'CSNBSYD' USING
               WS-RETURN-CODE
               WS-REASON-CODE
               WS-EXIT-DATA-LENGTH
               WS-EXIT-DATA
               WS-RULE-ARRAY-COUNT
               WS-RULE-ARRAY
               WS-KEY-LENGTH
               WS-CLEAR-KEY
               WS-KEY-PARMS-LENGTH
               WS-KEY-PARMS
               WS-BLOCK-SIZE
               WS-IV-LENGTH
               WS-IV
               WS-CHAIN-LEN
               WS-CHAIN-DATA
               WS-TEXT-LEN
               WS-CIPHER-TEXT
               WS-TEXT-LEN
               WS-DECRYPTED-TEXT
               WS-OPT-LEN
               WS-OPT-DATA.

           DISPLAY 'DECRYPTION RETURN CODE: '
               WS-RETURN-CODE.
           DISPLAY 'DECRYPTION REASON CODE: '
               WS-REASON-CODE.
           DISPLAY 'DECRYPTED TEXT: '
               WS-DECRYPTED-TEXT(1:WS-TEXT-LEN).

      *============================================================*
      * PROGRAM END                                                 *
      *============================================================*

           GOBACK.
