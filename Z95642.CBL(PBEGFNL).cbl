       IDENTIFICATION DIVISION.
      *--------------------
       PROGRAM-ID.    PBEGFNL
       AUTHOR.        Burak Kozluca.
      *--------------------
       ENVIRONMENT DIVISION.
      *--------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OUT-LINE  ASSIGN TO    OUTFILE
                            STATUS       OUT-ST.
           SELECT INP-FILE  ASSIGN TO    INPFILE
                            STATUS       INP-ST.
       DATA DIVISION.
      *--------------------
       FILE SECTION.
       FD  OUT-LINE RECORDING MODE F.
       01  OUT-FIELDS.
           05 OUT-DATA                PIC X(41).

       FD  INP-FILE RECORDING MODE F.
       01  INP-FIELDS.
           05 INP-ISLEM-TIPI          PIC X(01).
           05 INP-ID                  PIC X(05).

       WORKING-STORAGE SECTION.
       01  WS-WORK-AREA.
           05 WS-PBEGIDX              PIC X(08)  VALUE 'PBEGIDX'.
           05 OUT-ST                  PIC 9(02).
              88 OUT-SUCCESS                     VALUE 00
                                                       97.
           05 INP-ST                  PIC 9(02).
              88 INP-EOF                         VALUE 10.
              88 INP-SUCCESS                     VALUE 00
                                                       97.
           05 WS-ISLEM-TIPI           PIC 9(01).
              88 WS-ISLEM-TIPI-VALID             VALUE 1 THRU 9.
           05 INVALID-KEY             PIC X(01).
              88 INVL-KEY                        VALUE 'Y'.
           05 WS-SUB-AREA.
              07 WS-SUB-FUNC          PIC 9(01).
                 88 WS-FUNC-READ                 VALUE 1.
                 88 WS-FUNC-WRITE                VALUE 2.
                 88 WS-FUNC-UPDATE               VALUE 3.
                 88 WS-FUNC-DELETE               VALUE 4.
              07 WS-SUB-ID            PIC X(05).
              07 WS-SUB-ISLEM         PIC X(04).
              07 WS-SUB-RC            PIC X(02).
              07 WS-SUB-ACIKLAMA      PIC X(30).
              07 WS-SUB-DATA          PIC X(41).

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM H100-OPEN-FILES.
           PERFORM H200-PROCESS UNTIL INP-EOF.
           PERFORM H999-PROGRAM-EXIT.
       
       H100-OPEN-FILES.
           OPEN INPUT INP-FILE.
           IF NOT INP-SUCCESS 
              DISPLAY 'UNABLE TO OPEN INP-FILE: ' INP-ST
              MOVE INP-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           OPEN OUTPUT OUT-LINE.
           IF NOT OUT-SUCCESS 
              DISPLAY 'UNABLE TO OPEN OUT-FILE: ' OUT-ST
              MOVE OUT-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           READ INP-FILE.
           IF NOT INP-SUCCESS 
              DISPLAY 'UNABLE TO READ INP-FILE: ' INP-ST
              MOVE INP-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
       H100-END. EXIT.

      *INP-FILE'DAKI ISLEM TIPINE GORE GEREKLI FONKSIYON TRUE YAPILDI
      *BU ISLEMIN ARDINDAN GEREKLI TUM DEGERLERI KULLANARAK
      *ALT-PROGRAM CAGIRILDI ARDINDAN OUT DOSYASINA YAZDIRILDI.
       H200-PROCESS.
           MOVE INP-ID TO WS-SUB-ID
           EVALUATE INP-ISLEM-TIPI
              WHEN 'R'
                 SET WS-FUNC-READ   TO TRUE
              WHEN 'U'
                 SET WS-FUNC-UPDATE TO TRUE
              WHEN 'W'
                 SET WS-FUNC-WRITE  TO TRUE
              WHEN 'D'
                 SET WS-FUNC-DELETE TO TRUE
              WHEN OTHER
                 DISPLAY 'INVALID FUNCTION'
           END-EVALUATE.
           CALL WS-PBEGIDX USING WS-SUB-AREA.
           MOVE WS-SUB-DATA TO OUT-DATA
           WRITE OUT-FIELDS
           READ INP-FILE.
       H200-END. EXIT.

       H300-CLOSE-FILES.
           CLOSE OUT-LINE
                 INP-FILE.
       H300-END. EXIT.
       
      *PROGRAM SONU
       H999-PROGRAM-EXIT.
           PERFORM H300-CLOSE-FILES.
           STOP RUN.
       H999-END. EXIT.
