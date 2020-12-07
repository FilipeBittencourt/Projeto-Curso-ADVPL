#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP610002  º Autor ³ Ranisses A. Corona º Data ³  30/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Contabilizacao do Desconto Incondiocional                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilizacao Faturamento                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP610002()
Private Enter2	:= CHR(13)+CHR(10)
Private cconta2	:= ""
Private cSql2	:= ""

//Armazena area de Trabalho
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0 

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()
         
cSql2 := ""
cSql2 += "SELECT	B1_COD, B1_YTPPROD, " + Enter2
cSql2 += "		Z6_CTRSVDI,  --VENDA MERC. INTERNO " + Enter2 
cSql2 += "		Z6_CTRSVDE,  --VENDA MERC. EXTERNO " + Enter2 
cSql2 += "		Z6_CTASERV,  --LOCACAO DE BENS " + Enter2 
cSql2 += "		Z6_CTARSDV,  --DEVOLUCAO VENDA " + Enter2
cSql2 += "		Z6_CTAIPI,	 --IPI " + Enter2
cSql2 += "		Z6_CTAICMS,	 --ICMS " + Enter2
cSql2 += "		Z6_CTAPIS,   --PIS " + Enter2
cSql2 += "		Z6_CTACOF,   --COFINS " + Enter2
cSql2 += "		Z6_CTDESIN,	 --DESCONTO INCONDICIONAL " + Enter2
cSql2 += "		Z6_CTICMST,	 --ICMS SUBST. TRIBUTARIA " + Enter2
cSql2 += "		Z6_CTIPIDV,  --IPI DEVOLUCAO 	" + Enter2
cSql2 += "		Z6_CTICMDV,	 --ICMS DEVOLUCAO 	" + Enter2
cSql2 += "		Z6_CTPISDV,  --PIS DEVOLUCAO 	" + Enter2
cSql2 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO " + Enter2
cSql2 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter2
cSql2 += "WHERE	SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter2
cSql2 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter2
cSql2 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter2
cSql2 += "		SB1.B1_COD  	= '"+SD2->D2_COD+"'		AND	" + Enter2
cSql2 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter2
cSql2 += "		SB1.D_E_L_E_T_	= ''						" + Enter2
If chkfile("TRB2")
	DbSelectArea("TRB2")
	DbCloseArea("TRB2")
EndIf
TCQUERY cSql2 ALIAS "TRB2" NEW

cconta2 := TRB2->Z6_CTDESIN

//Volta area de Trabalho
DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

//Fecha area de trabalho temporaria
DbSelectArea("TRB2")
DbCloseArea("TRB2")

Return(cconta2)