#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH" 

User Function FCACGA01()

Local nHrAtu := U_calcHori(DATE(),IIF(EMPTY(M->AA3_YDTHOR),M->AA3_DTVEND,M->AA3_YDTHOR), M->AA3_HORDIA,M->AA3_DIAOPE,M->AA3_YHORIM)

RETURN nHrAtu