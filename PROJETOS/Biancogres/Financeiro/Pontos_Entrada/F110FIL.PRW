#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ F110FIL    ³ Autor ³ Wanisay               ³ Data ³ 13/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acrescenta filtro na montagem da baixa automatica a receber  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function F110FIL()
Private cQUERY  := ""
Private wFiltro := "" //Retonar o Filtro para o P.E.
Private nNumFat := "" //Acertar o Numero da Fatura para 6 digitos apenas para permitir filtro na tabela SE1
/*
wAlias  := Alias()

cPar01  := MV_PAR01
cPar02  := MV_PAR02
cPar03  := MV_PAR03
cPar04  := MV_PAR04
cPar05  := MV_PAR05
cPar06  := MV_PAR06
cPar07  := MV_PAR07
cPar08  := MV_PAR08

Pergunte("FNA110",.T.)

//Define Numero Fatura
If Len(Alltrim(MV_PAR02)) == 9
	nNumFat	:= Substr(Alltrim(MV_PAR02),4,6)
Else
	nNumFat	:= Alltrim(MV_PAR02)
EndIf


IF MV_PAR01 == 1	
	DO CASE
		CASE cEmpAnt == '01'
			cQUERY := ""
			cQUERY += " UPDATE "+RetSQLName("SE1")+" "
			cQUERY += " SET "
			cQUERY += " E1_PROJETO = '"+nNumFat+"', E1_PORCJUR = 0 "
			cQUERY += " FROM SE2070 SE2, SE1010 SE1 "
			cQUERY += " WHERE SE2.E2_FATURA = '"+MV_PAR02+"' "
			cQUERY += " AND SE1.E1_NUM     = SE2.E2_NUM "
			cQUERY += " AND SE1.E1_PREFIXO = SE2.E2_PREFIXO "
			cQUERY += " AND SE1.E1_PARCELA = SE2.E2_PARCELA "
			cQUERY += " AND SE1.E1_TIPO    = SE2.E2_TIPO "
			cQUERY += " AND SE1.E1_CLIENTE = '010064' "
			cQUERY += " AND SE2.E2_FORNECE = '000534' "
			cQUERY += " AND SE2.D_E_L_E_T_ = '' "
			cQUERY += " AND SE1.D_E_L_E_T_ = '' "
			TCSQLExec(cQuery)
		CASE cEmpAnt == '05'
			cQUERY := ""
			cQUERY += " UPDATE "+RetSQLName("SE1")+" "
			cQUERY += " SET "
			cQUERY += " E1_PROJETO = '"+nNumFat+"', E1_PORCJUR = 0 "
			cQUERY += " FROM SE2070 SE2, SE1050 SE1 "
			cQUERY += " WHERE SE2.E2_FATURA = '"+MV_PAR02+"' "
			cQUERY += " AND SE1.E1_NUM     = SE2.E2_NUM "
			cQUERY += " AND SE1.E1_PREFIXO = SE2.E2_PREFIXO "
			cQUERY += " AND SE1.E1_PARCELA = SE2.E2_PARCELA "
			cQUERY += " AND SE1.E1_TIPO    = SE2.E2_TIPO "
			cQUERY += " AND SE1.E1_CLIENTE = '010064' "
			cQUERY += " AND SE2.E2_FORNECE = '002912' "
			cQUERY += " AND SE2.D_E_L_E_T_ = '' "
			cQUERY += " AND SE1.D_E_L_E_T_ = '' "
			TCSQLExec(cQuery)

		CASE cEmpAnt == '06' // TIAGO ROSSINI - OS: 2160-14 - CLEBES JOSE ANDRE
			cQUERY := ""
			cQUERY += " UPDATE "+RetSQLName("SE1")+" "
			cQUERY += " SET "
			cQUERY += " E1_PROJETO = '"+nNumFat+"', E1_PORCJUR = 0 "
			cQUERY += " FROM SE2010 SE2, SE1060 SE1 "
			cQUERY += " WHERE SE2.E2_FATURA = '"+MV_PAR02+"' "
			cQUERY += " AND SE1.E1_NUM     = SE2.E2_NUM "
			cQUERY += " AND SE1.E1_PREFIXO = SE2.E2_PREFIXO "
			cQUERY += " AND SE1.E1_PARCELA = SE2.E2_PARCELA "
			cQUERY += " AND SE1.E1_TIPO    = SE2.E2_TIPO "
			cQUERY += " AND SE1.E1_CLIENTE = '000481' "
			cQUERY += " AND SE2.E2_FORNECE = '007437' "
			cQUERY += " AND SE2.D_E_L_E_T_ = '' "
			cQUERY += " AND SE1.D_E_L_E_T_ = '' "
			TCSQLExec(cQuery)
			
		CASE cEmpAnt == '13'
			cQUERY := ""
			cQUERY += " UPDATE "+RetSQLName("SE1")+" "
			cQUERY += " SET "
			cQUERY += " E1_PROJETO = '"+nNumFat+"', E1_PORCJUR = 0 "
			cQUERY += " FROM SE2070 SE2, SE1130 SE1 "
			cQUERY += " WHERE SE2.E2_FATURA = '"+MV_PAR02+"' "
			cQUERY += " AND SE1.E1_NUM     = SE2.E2_NUM "
			cQUERY += " AND SE1.E1_PREFIXO = SE2.E2_PREFIXO "
			cQUERY += " AND SE1.E1_PARCELA = SE2.E2_PARCELA "
			cQUERY += " AND SE1.E1_TIPO    = SE2.E2_TIPO "
			cQUERY += " AND SE1.E1_CLIENTE = '010064' "
			cQUERY += " AND SE2.E2_FORNECE = '004695' "
			cQUERY += " AND SE2.D_E_L_E_T_ = '' "
			cQUERY += " AND SE1.D_E_L_E_T_ = '' "
			TCSQLExec(cQuery)
		CASE cEmpAnt == '14'   // CARLOS JUNQUEIRA - SOLITAÇÃO CLEBES OS 2087-14 - BIANCO/VITCER
			cQUERY := ""
			cQUERY += " UPDATE "+RetSQLName("SE1")+" "
			cQUERY += " SET "
			cQUERY += " E1_PROJETO = '"+nNumFat+"', E1_PORCJUR = 0 "
			cQUERY += " FROM SE2010 SE2, SE1140 SE1 "
			cQUERY += " WHERE SE2.E2_FATURA = '"+MV_PAR02+"' "
			cQUERY += " AND SE1.E1_NUM     = SE2.E2_NUM "
			cQUERY += " AND SE1.E1_PREFIXO = SE2.E2_PREFIXO "
			cQUERY += " AND SE1.E1_PARCELA = SE2.E2_PARCELA "
			cQUERY += " AND SE1.E1_TIPO    = SE2.E2_TIPO "
			cQUERY += " AND SE1.E1_CLIENTE = '000481' "
			cQUERY += " AND SE2.E2_FORNECE = '003721' "
			cQUERY += " AND SE2.D_E_L_E_T_ = '' "
			cQUERY += " AND SE1.D_E_L_E_T_ = '' "
			TCSQLExec(cQuery)			
		OTHERWISE
			MsgBox("Empresa não está disponível para realizar esta operação","Empresa","ALERT")
	ENDCASE
	
	wFiltro := " E1_PROJETO = '"+nNumFat+"' "	
	
ENDIF

DbSelectArea(wAlias)
MV_PAR01 := cPar01
MV_PAR02 := cPar02
MV_PAR03 := cPar03
MV_PAR04 := cPar04
MV_PAR05 := cPar05
MV_PAR06 := cPar06
MV_PAR07 := cPar07
MV_PAR08 := cPar08
*/
Return(wFiltro)