#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA280TOK  บAutor  ณRanisses A. Corona  บ Data ณ  22/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada para validar os vendedores, nao permitindo บฑฑ
ฑฑบ          ณgerar/aglutinar titulos com vendedores diferentes.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFINA280                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FA280TOK
	Local Enter := CHR(13)+CHR(10)
	Local rRet	:= .T.
	Local rReg	:= ""
	Local cSql	:= ""
	Local nW

	//Armazena o RECNO dos titulos marcados
	For nW := 1 To Len(aMark)
		rReg := rReg + "'" + Alltrim(Str(aMark[nW])) + iif(nW<len(aMark),"',","'")
	Next

	//Seleciona os Titulos agrupando por Vendedor
	cSql	:= ""
	cSql	+= "SELECT COUNT(*) QUANT 						" + Enter
	cSql	+= "FROM (SELECT E1_VEND1 						" + Enter
	cSql	+= "	  FROM " + RetSqlName("SE1") + " SE1 	" + Enter
	cSql	+= "	  WHERE D_E_L_E_T_	= '' AND 			" + Enter
	cSql	+= "			R_E_C_N_O_	IN (" + rReg + ") 	" + Enter
	cSql	+= "	  GROUP BY E1_VEND1) VEND				" + Enter
	If chkfile("_RAC")
		dbSelectArea("_RAC")
		dbCloseArea()
	EndIf
	TCQuery cSql Alias "_RAC" New

	//Nao permite gerar a fatura quando houver vendedores diferentes
	If _RAC->QUANT > 1
		rRet	:= .F.
		MsgAlert("Nใo ้ permitido gerar Faturas com Vendedores Diferentes. Favor verificar.")
	EndIf

	If chkfile("_RAC")
		dbSelectArea("_RAC")
		dbCloseArea()
	EndIf

Return(rRet)