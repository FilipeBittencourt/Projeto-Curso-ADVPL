#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP640006  º Autor ³ Ranisses A. Corona º Data ³  30/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Contas de COFINS de Faturamento                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilizacao Faturamento                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP640006()
Private Enter7	:= CHR(13)+CHR(10)
Private cconta7	:= ""
Private cSql7	:= ""
Private xGrupo	:= ""
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
cSql7 := ""
cSql7 += "SELECT	B1_COD, B1_YTPPROD, " + Enter7
cSql7 += "		Z6_CTRSVDI,  --VENDA MERC. INTERNO " + Enter7
cSql7 += "		Z6_CTRSVDE,  --VENDA MERC. EXTERNO " + Enter7
cSql7 += "		Z6_CTASERV,  --LOCACAO DE BENS " + Enter7
cSql7 += "		Z6_CTARSDV,  --DEVOLUCAO VENDA " + Enter7
cSql7 += "		Z6_CTAIPI,	 --IPI " + Enter7
cSql7 += "		Z6_CTAICMS,	 --ICMS " + Enter7
cSql7 += "		Z6_CTAPIS,   --PIS " + Enter7
cSql7 += "		Z6_CTACOF,   --COFINS " + Enter7
cSql7 += "		Z6_CTDESIN,	 --DESCONTO INCONDICIONAL " + Enter7
cSql7 += "		Z6_CTICMST,	 --ICMS SUBST. TRIBUTARIA " + Enter7
cSql7 += "		Z6_CTIPIDV,  --IPI DEVOLUCAO 	" + Enter7
cSql7 += "		Z6_CTICMDV,	 --ICMS DEVOLUCAO 	" + Enter7
cSql7 += "		Z6_CTPISDV,  --PIS DEVOLUCAO 	" + Enter7
cSql7 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO " + Enter7
cSql7 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter7
cSql7 += "WHERE	SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter7
cSql7 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter7
cSql7 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter7
cSql7 += "		SB1.B1_COD  	= '"+SD1->D1_COD+"'		AND	" + Enter7
cSql7 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter7
cSql7 += "		SB1.D_E_L_E_T_	= ''						" + Enter7
If chkfile("TRB7")
	DbSelectArea("TRB7")
	DbCloseArea("TRB7")
EndIf
TCQUERY cSql7 ALIAS "TRB7" NEW

IF xGrupo == '020' 
	cconta7 := TRB7->Z6_CTCOFDV
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
DbSelectArea("TRB7")
DbCloseArea("TRB7")

Return(cconta7)
