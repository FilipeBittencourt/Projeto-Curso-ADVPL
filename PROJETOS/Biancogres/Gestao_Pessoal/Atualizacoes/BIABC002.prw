#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"

User Function BIABC002()
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Barbara Luan Gomes Coelho
Programa  := BIABC002
Empresa   := Biancogres Cerâmica S/A
Data      := 11/01/19
Uso       := Gestão Pessoal
Aplicação :=  Rotina para limpar o sequencial das tabelas que 
              controlam a leitura e apontamento dos registros AFD.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Local Enter := chr(13) + Chr(10)

private aPergs := {}

	If !ValidPerg()
		Return
	EndIf


GU004 :=	""
MV_PAR01 := DaySub(MV_PAR01,1)
DtIni := SUBSTR(Year2Str(MV_PAR01),3,2) + Month2Str(MV_PAR01) + Day2Str(MV_PAR01)

GU004 += "DELETE " + Enter   
GU004 += "  FROM " + RetSqlName("RFB") + Enter
GU004 += " WHERE D_E_L_E_T_ = ' '" + Enter 
GU004 += "   AND SUBSTRING(RFB_DTHRLI,1,6) >= '" + DtIni + "'" + Enter

U_BIAMsgRun("Aguarde... Apagando registros AFD... ",,{|| TcSQLExec(GU004) })

ProcRegua(0)

MsgINFO("Exclusão de registros AFD realizada com sucesso!!!")

Return

Static Function ValidPerg()

	local cLoad	    := "BIABC002"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	
	aAdd( aPergs ,{1,"Informe a Data inicial ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	

	If ParamBox(aPergs ,"Exclusão de registros AFD",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

		if empty(MV_PAR03) 
			MV_PAR03 := AllTrim(GetTempPath()) 	
		endif
	EndIf
Return lRet




