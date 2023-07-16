//DELDEF01 JOB ' ',CLASS=A,MSGLEVEL=(1,1),
//          MSGCLASS=X,NOTIFY=&SYSUID
//DELET100 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
   DELETE Z95642.QSAM.AA NONVSAM
   IF LASTCC LE 08 THEN SET MAXCC = 00
//DELET500 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
    DELETE Z95642.VSAM.AA CLUSTER PURGE
    IF LASTCC LE 08 THEN SET MAXCC = 00

        DEF CL ( NAME(Z95642.VSAM.AA)         -
                FREESPACE( 20 20 )            -
                SHR( 2,3 )                    -
                KEYS(3 0)                     -
                INDEXED SPEED                 -
                RECSZ(48 48)                  -
                TRK (10 10)                   -
                LOG(NONE)                     -
                VOLUMES (VPWRKB)              -
                UNIQUE )                      -
        DATA ( NAME(Z95642.VSAM.AA.DATA))     -
        INDEX ( NAME(Z95642.VSAM.AA.INDEX))
//REPRO600 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//INN001 DD DSN=Z95642.QSAM.BB,DISP=SHR
//OUT001 DD DSN=Z95642.VSAM.AA,DISP=SHR
//SYSIN DD *
    REPRO INFILE(INN001) OUTFILE(OUT001)
