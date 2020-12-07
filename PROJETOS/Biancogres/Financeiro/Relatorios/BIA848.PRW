#include "rwmake.ch"
#include "topconn.ch"
#include "Totvs.ch"                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA848         ºAutor  ³Ranisses A. Corona  º Data ³  04/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rel. Listagem para Conferencia	                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                     	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA848()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local 	nEmp	:= ""
Local 	Enter := CHR(13)+CHR(10)
Private	cSQL	:= ""
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := ""
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "BIA848"
cPerg      := "BIA848"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "DRE Cliente"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "BIA848"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.

pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

//Cancela a impressao
If nLastKey == 27
	Return
Endif

//Relacao dos Parametros
/*
MV_PAR01 - Emissao De
MV_PAR02 - Emissao Ate
MV_PAR03 - Empresa      
*/

//Define a Empresa
If cEmpAnt == "01"
	Do Case
		Case MV_PAR03 == 1 	//BIANCOGRES
			nEmp	:= "0101"
		Case MV_PAR03 == 2 	//INCESA
			nEmp	:= "0501"
		Case MV_PAR03 == 3 	//BELLACASA
			nEmp	:= "0599"
		Case MV_PAR03 == 4	//INCESA/BELLACASA
			nEmp	:= "05"
	EndCase
Else
	Do Case
		Case MV_PAR03 == 1 	//INCESA
			nEmp	:= "0501"
		Case MV_PAR03 == 2 	//BELLACASA
			nEmp	:= "0599"
		Case MV_PAR03 == 3	//INCESA/BELLACASA
			nEmp	:= "05"
	EndCase
EndIf

cQuery := ""
cQuery += "ALTER VIEW VW_BIA848 AS 																																							" + Enter
cQuery += "SELECT	A3.A3_NOME, A1.A1_NOME, D2.D2_DOC, D2.D2_QUANT, D2.D2_COD, D2.D2_GRUPO, A1.A1_MUN, A1.A1_EST, " + Enter
cQuery += "				D2.D2_EMISSAO, A3.A3_COD, A1.A1_COD, D2.D2_SERIE, D2.D2_UM, A3.A3_NREDUZ 											" + Enter
cQuery += "FROM VW_SF2 F2, VW_SD2 D2, SA1010 A1, SA3010 A3			" + Enter
cQuery += "WHERE 	F2_FILIAL				= '"+xFilial('SF2')+"' AND 		" + Enter
cQuery += "				A1_FILIAL   		= '"+xFilial('SA1')+"' AND		" + Enter
cQuery += "				A3_FILIAL   		= '"+xFilial('SA3')+"' AND		" + Enter
cQuery += "				D2_FILIAL   		= '"+xFilial('SD2')+"' AND		" + Enter
cQuery += "				F2.F2_DOC				= D2.D2_DOC			AND		" + Enter
cQuery += "				F2.F2_SERIE     = D2.D2_SERIE   AND		" + Enter
cQuery += "				F2.F2_CLIENTE   = D2.D2_CLIENTE	AND		" + Enter
cQuery += "				F2.F2_LOJA			= D2.D2_LOJA		AND		" + Enter
cQuery += "				F2.F2_YEMP			= D2.D2_YEMP		AND		" + Enter
cQuery += "				F2.F2_YEMPORI		= D2.D2_YEMPORI	AND		" + Enter
cQuery += "				F2.F2_CLIENTE   = A1.A1_COD			AND		" + Enter
cQuery += "				F2.F2_LOJA      = A1.A1_LOJA		AND		" + Enter
cQuery += "				F2.F2_VEND1			= A3.A3_COD			AND		" + Enter
cQuery += "				D2.D2_GRUPO			= 'PA' 					AND		" + Enter
cQuery += "				D2.F4_DUPLIC		= 'S' 					AND		" + Enter
cQuery += "				D2.D2_UM				= 'M2' 					AND		" + Enter
cQuery += "		  	D2.D2_EMISSAO		>= '"+Dtos(MV_PAR01)+"'		AND	" + Enter
cQuery += "		  	D2.D2_EMISSAO 	<= '"+Dtos(MV_PAR02)+"'		AND	" + Enter
If Len(Alltrim(nEmp)) == 4
	cQuery += "			F2.F2_YEMP	 	= '"+nEmp+"' AND		" + Enter
Else
	cQuery += "			SUBSTRING(F2.F2_YEMP,1,2) = '"+nEmp+"' AND	" + Enter
EndIf
cQuery += "			A1.D_E_L_E_T_ = ''	AND " + Enter
cQuery += "			A3.D_E_L_E_T_ = ''			" + Enter
TcSQLExec(cQuery)

If aReturn[5]==1
	//Parametros Crystal Em Disco
	cOpcao:="1;0;1;Listagem Conferencia"
Else
	//Direto Impressora
	cOpcao:="3;0;1;Listagem Conferencia"
Endif

//Chama Relatorio em Crystal
Callcrys("BIA848",Dtos(MV_PAR01)+";"+Dtos(MV_PAR02)+";"+cEmpAnt,cOpcao)

Return