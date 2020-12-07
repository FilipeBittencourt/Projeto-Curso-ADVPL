#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} REL_TIVE
@author Bruno Madaleno
@since 16/04/07
@version 1.0
@description Relatório de Títulos a Vencer 
@type function
/*/

User Function REL_TIVE()

//Declaracao de Variaveis                                             ³
Private cSQL
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "TITULOS A VENCER"
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "REL_TIVE"
cPerg      := "TIAVEN"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "TITULOS A VENCER"
Cabec1     := ""                                   
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "TIAVEN"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.
cEmpresa   := cEmpant

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.								     ³
//³ Verifica Posicao do Formulario na Impressora.				             ³
//³ Solicita os parametros para a emissao do relatorio			             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

//Cancela a impressao
If nLastKey == 27
	Return
Endif

//Preenchimento dos Paramentros
nCliDe	:= MV_PAR01 
nCliAte	:= MV_PAR02
nGrpDe	:= MV_PAR03
nGrpAte	:= MV_PAR04
nVenDe	:= MV_PAR05
nVenAte	:= MV_PAR06
nNatDe	:= MV_PAR07
nNatAte	:= MV_PAR08
dEmisDe	:= DTOS(MV_PAR09)
dEmisAt := DTOS(MV_PAR10)
dVencDe := DTOS(MV_PAR11)
dVencAt	:= DTOS(MV_PAR12)
nTpSeg	:= MV_PAR13
nTpRel	:= MV_PAR14
Do Case
	Case MV_PAR13 == 1 //Revenda
		nTpSeg	:= "R"
	Case MV_PAR13 == 2 //Engenharia
		nTpSeg	:= "E"	
	Case MV_PAR13 == 3 //Home Center
		nTpSeg	:= "H"	
	Case MV_PAR13 == 4 //Exportacao
		nTpSeg	:= "X"	
	Case MV_PAR13 == 5 //Todos
		nTpSeg	:= "T"	
EndCase

If MV_PAR14 == 1
	nTpRel	:= "A"
	nReport	:= "TIT_VEN_A"
Else
	nTpRel	:= "S"
	nReport	:= "TIT_VEN_S"
EndIf                          

//*************************************************************************
//*************************************************************************
//View para trazer as informacoes doS LIMITES DE CREDITO
//*************************************************************************
//*************************************************************************
Enter := chr(13) + Chr(10)
cSQL := ""
cSQL += "ALTER VIEW VW_TIT_ATRA AS " + Enter
cSQL += "SELECT A1_YTPSEG, A3_COD, A3_NOME, A3_FAX, A3_TEL, A3_TELEX, ISNULL(ACY_GRPVEN,'999999') ACY_GRPVEN , ISNULL(ACY_DESCRI,'SEM GRUPO') ACY_DESCRI, A1_COD, A1_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCTO, E1_HIST, E1_SALDO " + Enter
cSQL += "FROM " + RetSqlName("SE1") + " AS SE1 WITH (NOLOCK) " + Enter
cSQL += "	INNER JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) " + Enter
cSQL += "		ON SA1.A1_COD = SE1.E1_CLIENTE " + Enter
cSQL += "			AND SA1.A1_LOJA = SE1.E1_LOJA " + Enter
cSQL += "			AND SA1.A1_GRPVEN BETWEEN '" + nGrpDe + "' AND '" + nGrpAte + "' " + Enter
If nTpSeg <> "T"
	cSQL += "			AND SA1.A1_YTPSEG = '" + nTpSeg + "' AND " + Enter
EndIf
cSQL += "			AND SA1.D_E_L_E_T_ 	= ' ' " + Enter
cSQL += "	INNER JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) " + Enter
cSQL += "		ON SA3.A3_COD = SE1.E1_VEND1 " + Enter
cSQL += "			AND SA3.D_E_L_E_T_ 	= ' ' " + Enter
cSQL += "	LEFT JOIN " + RetSqlName("ACY") + " AS ACY WITH (NOLOCK) " + Enter
cSQL += "		ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN " + Enter
cSQL += "			AND ACY.D_E_L_E_T_ 	= ' ' " + Enter
cSQL += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' " + Enter
cSQL += "	AND SE1.E1_SALDO > 0 " + Enter
cSQL += "	AND SE1.E1_CLIENTE BETWEEN '" + nCliDe +  "' AND '" + nCliAte + "' " + Enter
cSQL += "	AND SE1.E1_VEND1   BETWEEN '" + nVenDe +  "' AND '" + nVenAte + "' " + Enter
cSQL += "	AND SE1.E1_NATUREZ BETWEEN '" + nNatDe +  "' AND '" + nNatAte + "' " + Enter
cSQL += "	AND SE1.E1_EMISSAO BETWEEN '" + dEmisDe + "' AND '" + dEmisAt + "' " + Enter
cSQL += "	AND SE1.E1_VENCTO  BETWEEN '" + dVencDe + "' AND '" + dVencAt + "' " + Enter
cSQL += "	AND SUBSTRING(SE1.E1_PREFIXO,1,2) NOT IN ('RA','PR','CT') "
cSQL += "	AND SE1.D_E_L_E_T_ = ' ' " + Enter


TcSQLExec(cSQL)    

If aReturn[5]==1
	//Parametros Crystal Em Disco
	cOpcao:="1;0;1;Apuracao"
Else
	//Direto Impressora
	cOpcao:="3;0;1;Apuracao"
Endif
callcrys(nReport,nCliDe+";"+nCliAte+";"+nGrpDe+";"+nGrpAte+";"+nVenDe+";"+nVenAte+";"+nNatDe+";"+nNatAte+";"+dEmisDe+";"+dEmisAt+";"+dVencDe+";"+dVencAt+";"+nTpSeg+";"+nTpRel+";"+cEmpAnt,cOpcao)

Return