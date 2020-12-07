#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP610008  º Autor ³ Ranisses A. Corona º Data ³  31/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Contas de ICMS Substituicao Tributaria                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilizacao Faturamento                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP610008()

Private Enter8	:= CHR(13)+CHR(10)
Private cconta8	:= ""
Private cSql8	:= ""
Private xgrupo  := ""

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

//Busca Conta Contabil pelo Tipo de Produto 
cSql8 := ""
cSql8 += "SELECT	B1_COD, B1_YTPPROD, " + Enter8
cSql8 += "		Z6_CTRSVDI,  --VENDA MERC. INTERNO " + Enter8
cSql8 += "		Z6_CTRSVDE,  --VENDA MERC. EXTERNO " + Enter8 
cSql8 += "		Z6_CTASERV,  --LOCACAO DE BENS " + Enter8 
cSql8 += "		Z6_CTARSDV,  --DEVOLUCAO VENDA " + Enter8
cSql8 += "		Z6_CTAIPI,	 --IPI " + Enter8
cSql8 += "		Z6_CTAICMS,	 --ICMS " + Enter8
cSql8 += "		Z6_CTAPIS,   --PIS " + Enter8
cSql8 += "		Z6_CTACOF,   --COFINS " + Enter8
cSql8 += "		Z6_CTDESIN,	 --DESCONTO INCONDICIONAL " + Enter8
cSql8 += "		Z6_CTICMST,	 --ICMS SUBST. TRIBUTARIA " + Enter8
cSql8 += "		Z6_CTIPIDV,  --IPI DEVOLUCAO 	" + Enter8
cSql8 += "		Z6_CTICMDV,	 --ICMS DEVOLUCAO 	" + Enter8
cSql8 += "		Z6_CTPISDV,  --PIS DEVOLUCAO 	" + Enter8
cSql8 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO " + Enter8
cSql8 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter8
cSql8 += "WHERE SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter8
cSql8 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter8
cSql8 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter8
cSql8 += "		SB1.B1_COD  	= '"+SD2->D2_COD+"'		AND	" + Enter8
cSql8 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter8
cSql8 += "		SB1.D_E_L_E_T_	= ''						" + Enter8
If chkfile("TRB8")
	DbSelectArea("TRB8")
	DbCloseArea("TRB8")
EndIf
TCQUERY cSql8 ALIAS "TRB8" NEW

cconta8 := TRB8->Z6_CTICMST

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
DbSelectArea("TRB8")
DbCloseArea("TRB8")

Return(cconta8)