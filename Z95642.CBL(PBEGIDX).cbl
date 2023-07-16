       IDENTIFICATION DIVISION.
      *--------------------
       PROGRAM-ID.    PBEGIDX
       AUTHOR.        Burak Kozluca.
      *--------------------
       ENVIRONMENT DIVISION.
      *--------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCT-REC  ASSIGN TO    ACCTREC
                            ORGANIZATION INDEXED
                            ACCESS       RANDOM
                            RECORD       ACCT-KEY
                            STATUS       ACCT-ST.
      *--------------------
       DATA DIVISION.
       FILE SECTION.
      *VSAM-FILE RECSZ: 48 KEY: 3
       FD  ACCT-REC.
       01  ACCT-FIELDS.
           03 ACCT-KEY.
              05 ACCT-ID            PIC S9(05)  COMP-3.
           03 ACCT-DVZ              PIC 9(03)   COMP.
           03 ACCT-NAME             PIC X(15).
           03 ACCT-SURNAME          PIC X(15).
           03 ACCT-DATE             PIC 9(8)    COMP-3.
           03 ACCT-BALANCE          PIC 9(15)   COMP-3.

       WORKING-STORAGE SECTION.
       01  WS-WORK-AREA.
           05 ACCT-ST               PIC 9(02).
              88 ACCT-EOF                       VALUE 10.
              88 ACCT-SUCCESS                   VALUE 00
                                                      97.
           05 INVALID-KEY           PIC X(01).
              88 INVL-KEY                       VALUE 'Y'.
           05 X-COUNTER             PIC 9(02)   VALUE 1.
           05 OUTPUT-VAR            PIC X(15).
           05 X-OP-COUNTER          PIC 9(02)   VALUE 1.

       LINKAGE SECTION.
       01 LS-SUB-AREA.
         07 LS-SUB-FUNC             PIC 9(01).
            88 LS-FUNC-READ                     VALUE 1.
            88 LS-FUNC-WRITE                    VALUE 2.
            88 LS-FUNC-UPDATE                   VALUE 3.
            88 LS-FUNC-DELETE                   VALUE 4.
         07 LS-SUB-ID               PIC X(05).
         07 LS-SUB-ISLEM            PIC X(04).
         07 LS-SUB-RC               PIC X(02).
         07 LS-SUB-ACIKLAMA         PIC X(30).
         07 LS-SUB-DATA             PIC X(41).

      *--------------------
       PROCEDURE DIVISION USING LS-SUB-AREA.

       0000-MAIN.
           PERFORM H100-OPEN-FILES.
           PERFORM H200-PROCESS.
           PERFORM H999-PROGRAM-EXIT.
       H100-OPEN-FILES.
           OPEN I-O ACCT-REC.
           IF (NOT ACCT-SUCCESS)
              DISPLAY 'ACCT FILE NOT OPEN: ' ACCT-ST
              MOVE ACCT-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
       H100-END. EXIT.

      *KEY KONTROLU YAPILARAK KAYIDIN OLUP OLMADIGI KONTROL EDILDI
      *KAYIT YOKSA GEREKLI BILGILER STRING IFADESIYLE YAZILDI
      *KAYIT VARSA PERFORM EVALUATE IFADESIYLE GEREKLI ISLEMLERIN
      *YAPILMASININ ARDINDAN STRING IFADESIYLE YAZDIRILDI
       H200-PROCESS.
           INITIALIZE INVALID-KEY
           COMPUTE ACCT-ID = FUNCTION NUMVAL (LS-SUB-ID).
           READ ACCT-REC
              INVALID KEY MOVE 'Y' TO INVALID-KEY.
           IF (ACCT-SUCCESS)
              MOVE ACCT-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.

           IF INVALID-KEY NOT = 'Y'
              PERFORM H300-EVALUATE
              STRING LS-SUB-ID '-' LS-SUB-ISLEM '-'
                 'RC:' ACCT-ST '-' LS-SUB-ACIKLAMA
              DELIMITED BY SIZE INTO LS-SUB-DATA
           ELSE
              PERFORM H300-EVALUATE
              MOVE 'KAYIT BULUNAMADI' TO LS-SUB-ACIKLAMA
              STRING LS-SUB-ID '-' LS-SUB-ISLEM '-'
                 'RC:' ACCT-ST '-' LS-SUB-ACIKLAMA
              DELIMITED BY SIZE INTO LS-SUB-DATA
           END-IF.
       H200-END. EXIT.

      *EVALUATE KISMINDA ANA PROGRAMDAN GELEN ISLEM TIPINE GORE
      *ILGILI KISMIN ISLETILMESI
       H300-EVALUATE.
           EVALUATE TRUE
              WHEN LS-FUNC-READ
                 PERFORM H400-READ-FILES
              WHEN LS-FUNC-UPDATE
                 PERFORM H500-UPDATE
              WHEN LS-FUNC-DELETE
                 PERFORM H600-DELETE
              WHEN LS-FUNC-WRITE
                 PERFORM H700-WRITE
              WHEN OTHER
                 DISPLAY 'INVALID FUNC' LS-SUB-FUNC
           END-EVALUATE.
       H300-END. EXIT.

      *READ ISLEMIYLE VSAMDAKI ILGILI KISIYI OKUYORUZ
       H400-READ-FILES.
           IF INVL-KEY
              MOVE 'READ' TO LS-SUB-ISLEM
           ELSE
              MOVE 'READ' TO LS-SUB-ISLEM
              MOVE 'KAYIT OKUNDU' TO LS-SUB-ACIKLAMA
           END-IF.
       H400-END. EXIT.

      *VSAM DOSYASINDAKI SOYISIMDEKI 'E' HARFLERINI 'I',
      *'A' HARFLERINI 'E' YAPIYORUZ VE ISIMDE BOSLUK VARSA
      *O BOSLUKLARI SILEREK ISMI TEKRARDAN VSAMA YAZDIRIYORUZ
       H500-UPDATE.
           IF INVL-KEY
              DISPLAY 'UPDT'
              MOVE 'UPDT' TO LS-SUB-ISLEM
           ELSE
              MOVE 'UPDT' TO LS-SUB-ISLEM
              INSPECT ACCT-SURNAME REPLACING ALL 'E' BY 'I'
              INSPECT ACCT-SURNAME REPLACING ALL 'A' BY 'E'
      *       SPACE SILME KISMI
              PERFORM VARYING X-COUNTER FROM 1 BY 1
                 UNTIL X-COUNTER > LENGTH OF ACCT-NAME
                 IF ACCT-NAME  (X-COUNTER:1) = ' '
                    CONTINUE
                 ELSE
                    MOVE ACCT-NAME  (X-COUNTER:1) TO
                         OUTPUT-VAR (X-OP-COUNTER:1)
                    ADD 1 TO X-OP-COUNTER
                 END-IF
              END-PERFORM
              MOVE 1 TO X-OP-COUNTER
              MOVE OUTPUT-VAR TO ACCT-NAME
              MOVE SPACES TO OUTPUT-VAR
              MOVE 'UPDATE YAPILDI' TO LS-SUB-ACIKLAMA
              REWRITE ACCT-FIELDS
           END-IF.
       H500-END. EXIT.

      *DELETE ISLEMIYLE VSAM DOSYASINDAKI ILGILI KISI SILINIYOR
       H600-DELETE.
           IF INVL-KEY
              MOVE 'DLTE' TO LS-SUB-ISLEM
           ELSE
              MOVE 'DLTE' TO LS-SUB-ISLEM
              DELETE ACCT-REC
              END-DELETE
              MOVE 'SILME TAMAMLANDI' TO LS-SUB-ACIKLAMA
           END-IF.
       H600-END. EXIT.

      *WRITE ISLEMINDE YENI BIR KULLANICI OLUSTURUYORUZ
      *YENI KULLANICININ BILGILERI KENDI BILGILERIMIZI ICERIYOR
       H700-WRITE.
           IF INVL-KEY
              MOVE 'WRIT' TO LS-SUB-ISLEM
           ELSE
              DISPLAY 'WRITE YAPTI'
              MOVE 'WRIT' TO LS-SUB-ISLEM
              MOVE 'BURAK' TO ACCT-NAME
              MOVE 'KOZLUCA' TO ACCT-SURNAME
              MOVE 'KAYIT EKLENDI' TO LS-SUB-ACIKLAMA
              REWRITE ACCT-FIELDS
           END-IF.
       H700-END. EXIT.
      
      *PROGRAM SONU
       H999-PROGRAM-EXIT.
           CLOSE ACCT-REC.
           EXIT PROGRAM.
       H999-END. EXIT.
