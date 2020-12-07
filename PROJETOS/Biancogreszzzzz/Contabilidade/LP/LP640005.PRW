#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP640005  º Autor ³ Ranisses A. Corona º Data ³  30/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Contas de PIS de Faturamento                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilizacao Faturamento                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP640005()
Private Enter6	:= CHR(13)+CHR(10)
Private cconta6	:= ""
Private cSql6	:= ""
Private xgrupo  := ""
Private cTes    := SD1->D1_TES

//Armazena area de Trabalho
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSF4	:= ""
Private cIndSF4	:= 0
Private cRegSF4	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SF4")
cArqSF4 := Alias()
cIndSF4 := IndexOrd()
cRegSF4 := Recno()

//Posicionando no TES
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+cTes,.F.)       // Pesquisa TES da NF de saida
	xGrupo := SF4->F4_YCCONT              // Carrega variavel com o Grupo Contab.
Endif

//Busca Conta Contabil pelo Tipo de Produto
cSql6 := ""
cSql6 += "SELECT	B1_COD, B1_YTPPROD, " + Enter6
cSql6 += "		Z6_CTRSVDI,  --VENDA MERC. INTERNO " + Enter6
cSql6 += "		Z6_CTRSVDE,  --VENDA MERC. EXTERNO " + Enter6
cSql6 += "		Z6_CTASERV,  --LOCACAO DE BENS " + Enter6
cSql6 += "		Z6_CTARSDV,  --DEVOLUCAO VENDA " + Enter6
cSql6 += "		Z6_CTAIPI,	 --IPI " + Enter6
cSql6 += "		Z6_CTAICMS,	 --ICMS " + Enter6
cSql6 += "		Z6_CTAPIS,   --PIS " + Enter6
cSql6 += "		Z6_CTACOF,   --COFINS " + Enter6
cSql6 += "		Z6_CTDESIN,	 --DESCONTO INCONDICIONAL " + Enter6
cSql6 += "		Z6_CTICMST,	 --ICMS SUBST. TRIBUTARIA " + Enter6
cSql6 += "		Z6_CTIPIDV,  --IPI DEVOLUCAO " + Enter6
cSql6 += "		Z6_CTICMDV,	 --ICMS DEVOLUCAO 		" + Enter6
cSql6 += "		Z6_CTPISDV,  --PIS DEVOLUCAO 		" + Enter6
cSql6 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO 	" + Enter6
cSql6 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter6
cSql6 += "WHERE	SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter6
cSql6 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter6
cSql6 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter6
cSql6 += "		SB1.B1_COD  	= '"+SD1->D1_COD+"'		AND	" + Enter6
cSql6 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter6
cSql6 += "		SB1.D_E_L_E_T_	= ''						" + Enter6
If chkfile("TRB6")
	DbSelectArea("TRB6")
	DbCloseArea("TRB6")
EndIf
TCQUERY cSql6 ALIAS "TRB6" NEW

IF xGrupo == '020' 
	cconta6 := TRB6->Z6_CTPISDV
ENDIF

//Volta area de Trabalho
If cArqSF4 <> ""
	dbSelectArea(cArqSF4)
	dbSetOrder(cIndSF4)
	dbGoTo(cRegSF4)
	RetIndex("SF4")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

//Fecha area de trabalho temporaria
DbSelectArea("TRB6")
DbCloseArea("TRB6")

Return(cconta6)
