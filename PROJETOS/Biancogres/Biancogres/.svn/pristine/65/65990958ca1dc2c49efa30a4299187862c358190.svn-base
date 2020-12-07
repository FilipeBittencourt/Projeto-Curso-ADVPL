#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Ranisses A. Corona
Alterado  := Thiago Dantas
Programa  := BIA861
Empresa   := Biancogres Cerâmica S/A
Data      := 29/04/14
Uso       := Cadastro Cliente / BIZAGI
Aplicação := Automatiza sequencia do codigo do Cadastro de Cliente
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA861()
Local nSeq := "000000"
Local lFuncio := .F.

If !Empty(Alltrim(M->A1_CGC)) .Or. M->A1_TIPO == "X"
    
    cAliasAnt := GetArea()	
	cQry:="SELECT SUM(QTD) QTD 			"
	cQry+="FROM (                       "
	cQry+="SELECT COUNT(0) QTD from SRA010 WITH (NOLOCK) WHERE RA_CIC = '"+M->A1_CGC+"' "
	cQry+="UNION                        "
	cQry+="SELECT COUNT(0) QTD from SRA050 WITH (NOLOCK) WHERE RA_CIC = '"+M->A1_CGC+"' "
	cQry+="UNION                        "
	cQry+="SELECT COUNT(0) QTD from SRA060 WITH (NOLOCK) WHERE RA_CIC = '"+M->A1_CGC+"' "
	cQry+="UNION                        "
	cQry+="SELECT COUNT(0) QTD from SRA120 WITH (NOLOCK) WHERE RA_CIC = '"+M->A1_CGC+"' "
	cQry+="UNION                        "
	cQry+="SELECT COUNT(0) QTD from SRA130 WITH (NOLOCK) WHERE RA_CIC = '"+M->A1_CGC+"' "
	cQry+="UNION                        "
	cQry+="SELECT COUNT(0) QTD from SRA140 WITH (NOLOCK) WHERE RA_CIC = '"+M->A1_CGC+"' "
	cQry+=") TMP                        "    
   	TCQUERY cQry ALIAS "TMP" NEW
   	dbSelectArea("TMP")
   	TMP->(dbGotop())
  
   	lFuncio := (TMP->QTD > 0)
   	TMP->(dbCloseArea())
    
    RestArea(cAliasAnt)

    If cEmpAnt == "02"
    	nSeq := M->A1_COD
    Else 
	    If Len(Alltrim(M->A1_CGC)) == 11 .And. lFuncio
			nSeq := GetSxENum("SA1","A1_COD","SA1_FUN")
			M->A1_YCDGREG := '000023'
		Else
			nSeq := GetSxENum("SA1","A1_COD","SA1_CLI")
			M->A1_YCDGREG := '000001'
		EndIf
	EndIf
	
EndIf

Return(nSeq)