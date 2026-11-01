      *----------------------------------------------------------------
      * DB2 TABLE REPLICATION EXAMPLE - SOURCE TO TARGET                                    
      *----------------------------------------------------------------
       IDENTIFICATION DIVISION.                                        
      *-------------------------                                       
       PROGRAM-ID.     DB2REPL.                                        
       ENVIRONMENT DIVISION.                                           
      *-------------------------                                       
       CONFIGURATION SECTION.
       DATA DIVISION.
WORKING-STORAGE SECTION.                                        
       01  RESP.                                                       
           10 col-id                   PIC S9(19)V USAGE COMP-3.       
           10 col-num1                 PIC S9(4) USAGE COMP.           
           10 col-num2                 PIC S9(4) USAGE COMP.           
           10 col-date                 PIC S9(9) USAGE COMP.           
           10 col-num3                 PIC S9(19)V USAGE COMP-3.       
           10 COL-REFERENCE             PIC S9(19)V USAGE COMP-3.       
           10 col-num4                 PIC S9(19)V USAGE COMP-3.       
           10 col-num5                 PIC S9(19)V USAGE COMP-3.       
           10 col-num6                 PIC X(26).                      
           10 col-num7                 PIC X(999).                     
           10 col-num8                 PIC S9(4) USAGE COMP.           
      *                                                                
        01 PREVIOUS-ID             PIC S9(19)V USAGE COMP-3 VALUE 0.           
        01 LAST-ID                 PIC S9(19)V USAGE COMP-3 VALUE 0.           
        01 NUM-ERROR-REC           PIC S9(19)V USAGE COMP-3 VALUE 1.           
        01 IND1                    PIC S9(4) USAGE COMP.               
        01 IND2                    PIC S9(4) USAGE COMP.               
        01 IND3                    PIC S9(4) USAGE COMP.               
        01 IND4                    PIC S9(4) USAGE COMP.               
        01 IND5                    PIC S9(4) USAGE COMP.               
        01 IND6                    PIC S9(4) USAGE COMP.               
        01 IND7                    PIC S9(4) USAGE COMP.               
        01 IND8                    PIC S9(4) USAGE COMP.               
        01 IND9                    PIC S9(4) USAGE COMP.               
        01 IND10                   PIC S9(4) USAGE COMP.               
        01 IND11                   PIC S9(4) USAGE COMP.               
                                                                       
        77 P-MAX-ID          PIC S9(19)V USAGE COMP-3.                 
        77 P-MAX-DATE        PIC S9(9)  USAGE COMP.                    
        77 S-MAX-ID          PIC S9(19)V USAGE COMP-3.                 
        77 SUB-ID            PIC ZZZ,ZZZ,ZZ9.                       
        77 SUB-CNT           PIC ZZZ,ZZZ,ZZ9.                       
        77 TIME-START-SEL    PIC X(26).                             
        77 COUNTXS           PIC ZZZ,ZZZ,ZZ9.                       
        77 COUNTXP           PIC ZZZ,ZZZ,ZZ9.                       
        77 COUNTS            PIC S9(18) USAGE COMP VALUE 0.         
        77 COUNTP            PIC S9(18) USAGE COMP VALUE 0.         
        77 SQLC              PIC S9(9) USAGE COMP.                             
        77 COUNTER           PIC S9(18) USAGE COMP VALUE 0.         
        77 COMMIT-COUNT      PIC S9(18) VALUE 50000.                
        77 COUNTERX          PIC ZZZ,ZZZ,ZZ9.                       
        77 TSS1              PIC S9(2)  USAGE COMP.                 
        77 TSS2              PIC S9(2)  USAGE COMP.                 
        77 TSS3              PIC S9(2)  USAGE COMP.                 
        77 COMPARE-TIME      PIC X(26).                             
        77 START-DATE1       PIC S9(8)  USAGE COMP.                 
        77 START-DATE2       PIC S9(8)  USAGE COMP.                 
        77 MSG               PIC X(30)  VALUE "*************".      
        77 MSGT              PIC X(30)  VALUE "TIME IS UP...".      
            EXEC SQL INCLUDE SQLCA END-EXEC.                        
            EXEC SQL DECLARE CURRSP CURSOR WITH HOLD FOR            
              SELECT                                                
                     col_id   ,                    
                     col_num1       ,                    
                     col_num2             ,                    
                     col_date               ,                    
                     col_num3              ,                    
                     COL_REFERENCE      ,                    
                     col_num4      ,                        
                     col_num5             ,                        
                     col_num6               ,                        
                     col_num7 ,                                
                     col_num8                                      
              FROM   SOURCE_SCHEMA.SOURCE_TABLE                           
              WHERE  col_id >  :P-MAX-ID               
              AND    col_id <= :S-MAX-ID               
              ORDER BY col_id                          
              FETCH FIRST 100    ROWS ONLY                              
              WITH UR                                                   
            END-EXEC.                                                   
       PROCEDURE DIVISION.                                              
      *------------------                                               
       PROG-START.                                                      
            DISPLAY'**************************************************'.
            DISPLAY'**              START REPLICATION               **'.
            DISPLAY'**     TABLE NAME : SOURCE_SCHEMA.SOURCE_TABLE    **'.
            DISPLAY'**************************************************'.
            MOVE FUNCTION CURRENT-DATE TO COMPARE-TIME.                 
            MOVE COMPARE-TIME(1:8)     TO START-DATE1.                  
              EXEC SQL                                                  
                SELECT COALESCE(MAX(col_id), 0)                     
                       INTO :P-MAX-ID                                   
                FROM   TARGET_SCHEMA.TARGET_TABLE               
                WITH UR                                                 
              END-EXEC.                                                 
            DISPLAY' LAST ID (TARGET) : ' P-MAX-ID                                                       
              EXEC SQL                                                  
                SELECT COALESCE(MAX(col_date), 0)                                 
                       INTO :P-MAX-DATE                                 
                FROM   TARGET_SCHEMA.TARGET_TABLE               
                WITH UR                                                 
              END-EXEC.                                                 
              EXEC SQL                                                  
                SELECT COALESCE(MAX(col_id), 0)                     
                       INTO :S-MAX-ID                                   
                FROM   SOURCE_SCHEMA.SOURCE_TABLE                 
                WITH UR                                                 
              END-EXEC.                                                 
            DISPLAY' LAST ID (SOURCE):' S-MAX-ID. 
            COMPUTE SUB-ID = S-MAX-ID - P-MAX-ID.                       
            DISPLAY'**************************************************'.
            DISPLAY' COUNT OF ROWS THAT MUST BE REPLICATE IS : 'SUB-ID. 
            DISPLAY'**************************************************'.
       OPENFILE.                                                        
            MOVE FUNCTION CURRENT-DATE TO TIME-START-SEL.               
            MOVE TIME-START-SEL(9:2)  TO TSS1.                          
            MOVE TIME-START-SEL(11:2) TO TSS2.                          
            MOVE TIME-START-SEL(13:2) TO TSS3.                          
            MOVE TIME-START-SEL(1:8)  TO START-DATE2.                   
            IF TSS1 = 00 AND START-DATE2 NOT= START-DATE1 THEN          
              MOVE MSGT TO MSG                                          
             GO TO PROG-END3                                        
           END-IF.                                                  
     *     IF TSS1 = 09 THEN                                        
     *       MOVE MSGT TO MSG                                       
     *       GO TO PROG-END3                                        
     *     END-IF.                                                  
           IF TSS1 = 17 AND TSS2 >= 50 THEN                         
             MOVE MSGT TO MSG                                       
             GO TO PROG-END3                                        
           END-IF.                                                  
           IF TSS1 < 20  AND   TSS1 > 9     THEN                    
             MOVE 10000 TO COMMIT-COUNT                             
           END-IF.                                                  
              EXEC SQL OPEN CURRSP END-EXEC.                        
      NEXT-FETCH.                                                   
             EXEC SQL FETCH CURRSP                                  
             INTO                                                   
                :col-id        :IND1,              
                :col-num1            :IND2,              
                :col-num2                  :IND3,              
                :col-date                    :IND4,              
                :col-num3                   :IND5,              
                :COL-REFERENCE           :IND6,              
                :col-num4           :IND7,              
                :col-num5                  :IND8,              
                :col-num6                    :IND9,              
                :col-num7                  :IND10,
                 :col-num8              :IND11              
              END-EXEC.                                              
            IF SQLCODE =  100 GO TO COMMIT-STEP.                     
       NEXT-INSERT.                                                  
              EXEC SQL INSERT INTO TARGET_SCHEMA.TARGET_TABLE         
                    (col_id  ,                      
                     col_num1      ,                      
                     col_num2            ,                      
                     col_date              ,                      
                     col_num3             ,                      
                     COL_REFERENCE     ,                      
                     col_num4     ,                      
                     col_num5            ,                      
                     col_num6              ,                      
                     col_num7        ,                      
                     col_num8 )                                 
              VALUES                                                 
                (:col-id        :IND1,              
                 :col-num1            :IND2,              
                 :col-num2                  :IND3,              
                 :col-date                    :IND4,              
                 :col-num3                   :IND5,              
                 :COL-REFERENCE           :IND6,              
                 :col-num4           :IND7,              
                 :col-num5                  :IND8,              
                 :col-num6                    :IND9,              
                 :col-num7                  :IND10,
                 :col-num8              :IND11)             
              END-EXEC.                                              
            MOVE SQLCODE TO SQLC                                        
            IF SQLCODE NOT = 0                                          
            DISPLAY 'SQLCODE :' SQLCODE                                 
            GO TO PROG-END2                                             
            END-IF.                                                     
            ADD 1 TO COUNTER.                                           
            IF FUNCTION MOD(COUNTER,50) = 0                             
              DISPLAY' COUNT : 'COUNTER' , ID : 'col-id
            END-IF.                                                     
            IF FUNCTION MOD(COUNTER,COMMIT-COUNT) = 0                   
               EXEC SQL COMMIT WORK END-EXEC                            
               DISPLAY' COMMITED        '                               
            END-IF.                                                     
            MOVE col-id TO PREVIOUS-ID.                
            MOVE 1 TO NUM-ERROR-REC.                                    
            GO TO NEXT-FETCH.                                           
       COMMIT-STEP.                                                     
               EXEC SQL COMMIT WORK END-EXEC.                           
               EXEC SQL CLOSE CURRSP END-EXEC.                          
            MOVE col-id TO P-MAX-ID.                   
            IF P-MAX-ID = S-MAX-ID GO TO PROG-END1.                     
            GO TO OPENFILE.                                             
       PROG-END1.                                                       
            DISPLAY'**************************************************'.
            DISPLAY'**       INFORMATION AFTER ENDING PROGRAM:      **'.
            DISPLAY'**************************************************'.
            MOVE SQLCODE TO SQLC.                                       
            DISPLAY'** SQLCODE  : '  SQLC.                              
              EXEC SQL COMMIT WORK END-EXEC.                            
            MOVE COUNTER TO COUNTERX.                                   
            DISPLAY'** COUNT OF REPLICATED RECORDS : ' COUNTERX.        
              EXEC SQL                                                  
                SELECT COUNT(*) INTO :COUNTP                            
                FROM   TARGET_SCHEMA.TARGET_TABLE                       
                WHERE  col_date >= :P-MAX-DATE                          
                WITH UR                                                 
              END-EXEC.                                                 
              EXEC SQL                                                  
                SELECT COUNT(*) INTO :COUNTS                            
                FROM   SOURCE_SCHEMA.SOURCE_TABLE                         
                WHERE  col_id <= :S-MAX-ID             
                AND    col_date >= :P-MAX-DATE                          
                WITH UR                                                 
              END-EXEC.                                                 
           MOVE COUNTP TO COUNTXP.                                      
           MOVE COUNTS TO COUNTXS.                                      
           DISPLAY'**************************************************'. 
           DISPLAY'** COUNT OF NEW ROWS IN TARGET, TODAY : ' COUNTXP.   
           DISPLAY'** COUNT OF NEW ROWS IN SOURCE, TODAY : ' COUNTXS.   
           DISPLAY'**************************************************'. 
           IF COUNTP = COUNTS THEN                                      
           DISPLAY'**                                              **'  
           DISPLAY'**               CONGRATULATION                 **'  
           DISPLAY'**                                              **'  
           DISPLAY'**  *ALL OF ROWS ARE REPLICATED SUCCESSFULLY*   **'  
           DISPLAY'**                                              **'  
            IF SQLC NOT= 0 DISPLAY'**  BUT SQLCODE IS : ' SQLC          
           DISPLAY'**                                              **'  
            DISPLAY' ================================================ ' 
            DISPLAY'|        OPERATOR ACTION PLEASE CALL DBA         |' 
            DISPLAY' ================================================ ' 
            END-IF                                                      
           ELSE                                                         
           COMPUTE SUB-CNT = COUNTS - COUNTP                            
           DISPLAY'**                                              **'  
           DISPLAY'**                 WARNING!!!                   **'  
           DISPLAY'**                                              **'  
           DISPLAY'**WE HAVE SOME ROWS IN SOURCE THAT THEY AREN''T**'  
           DISPLAY'** IN TARGET, AND ITS COUNT IS : 'SUB-CNT           
           DISPLAY'**'                                                  
            IF SQLC NOT= 0 DISPLAY'**   AND SQLCODE IS : ' SQLC         
            DISPLAY'**                                              **' 
            END-IF                                                      
           DISPLAY' ================================================ '  
           DISPLAY'|        OPERATOR ACTION PLEASE CALL DBA         |'  
           DISPLAY' ================================================ '  
           END-IF.                                                      
           DISPLAY'**************************************************'. 
           GOBACK.                                                      
       PROG-END2.                                                       
           EXEC SQL COMMIT WORK END-EXEC.                               
           DISPLAY'**************************************************'. 
           DISPLAY'**               ERROR IN INSERT!               **'. 
           DISPLAY'**************************************************'. 
           DISPLAY'** SQLCODE IS : ' SQLC.                              
           MOVE COUNTER TO COUNTERX.                                    
           IF NUM-ERROR-REC = 1                                         
              MOVE PREVIOUS-ID TO LAST-ID                               
           END-IF.                                                      
           DISPLAY'** COUNT OF REPLICATED RECORDS : ' COUNTERX.         
           DISPLAY'** LAST   ID BEFORE ERROR IS : ' LAST-ID.            
           DISPLAY'** NUMBER OF RECORD HAS SKIP : ' NUM-ERROR-REC.      
           DISPLAY' ================================================ '. 
           DISPLAY'|        OPERATOR ACTION PLEASE CALL DBA         |'. 
           DISPLAY' ================================================ '. 
           ADD NUM-ERROR-REC TO  PREVIOUS-ID.                           
           MOVE PREVIOUS-ID TO P-MAX-ID.                                
           ADD 1 TO NUM-ERROR-REC.                                      
                                                
           GO TO OPENFILE.                                              
       PROG-END3.                                                       
           DISPLAY'**************************************************'. 
           DISPLAY'**       INFORMATION AFTER ENDING TIME!!!       **'. 
           DISPLAY'**************************************************'. 
           MOVE SQLCODE TO SQLC.                                        
           DISPLAY'** SQLCODE  : '  SQLC.                               
              EXEC SQL COMMIT WORK END-EXEC.                            
      *    DISPLAY' SQLERRMC : '  SQLERRMC.                             
      *    DISPLAY' SQLTERRP : '  SQLERRP.                              
      *    DISPLAY' SQLSTATE : '  SQLSTATE.                             
           MOVE COUNTER TO COUNTERX.                                    
           DISPLAY'** COUNT OF REPLICATED RECORDS : ' COUNTERX.         
           DISPLAY'**************************************************'. 
           DISPLAY'**                                              **'. 
           DISPLAY'**                 WARNING!!!                   **'. 
           DISPLAY'**                                              **'. 
           DISPLAY'**                'MSG.                              
           DISPLAY'**                                              **'. 
           DISPLAY'**        WE HAVE SOME ROWS IN SOURCE THAT     **'. 
           DISPLAY'**        THEY DIDN''T REPLICATE TO instance2      **' 
           DISPLAY'**        BECAUSE TIME IS UP!                   **'. 
           DISPLAY'**                                              **'. 
           IF SQLC NOT= 0 DISPLAY'**   AND SQLCODE IS : ' SQLC          
           DISPLAY'**                                              **'  
           END-IF.                                                      
           DISPLAY'**************************************************'. 
           DISPLAY'**     TABLE NAME : SOURCE_SCHEMA.SOURCE_TABLE    **'. 
           DISPLAY'**             END OF REPLICATION               **'. 
           DISPLAY'**************************************************'. 
           GOBACK.                                                      		   
