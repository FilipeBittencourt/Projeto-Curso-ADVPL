#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

// U_TSTFIL
User Function M030PALT()

  /*Local aEmp	:= {"010","050","070","120","130","140","160","170"}
  Local x		:= 0
  Local cSql	:= ""
  Local oContaCont := TContaContabil():New()

  IF EMPTY(SA1->A1_YCTAADI)
    cCContabil := oContaCont:SetContContab("C", SA1->A1_COD, SA1->A1_LOJA, "RA") //M->A1_YCTAADI	//Conta Adiantamento RA
    For x := 1 to Len(aEmp)
      cSql := ("UPDATE SA1"+aEmp[x]+" SET A1_YCTAADI = '"+cCContabil+"' WHERE A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"'  AND D_E_L_E_T_ = ''")
      TcSqlExec(cSql)
    Next
  ENDIF*/

RETURN