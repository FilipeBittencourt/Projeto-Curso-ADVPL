#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP640003  º Autor ³ Ranisses A. Corona º Data ³  30/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Contas de ICMS de Faturamento                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilizacao Faturamento                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP640003()
Local clp := Paramixb

Private Enter5	:= CHR(13)+CHR(10)
Private cconta5	:= ""
Private cSql5	:= ""
Private xgrupo  := ""

//Armazena area de Trabalho
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSF4	:= ""
Private cIndSF4	:= 0
Private cRegSF4	:= 0

Private cArqSD1	:= ""
Private cIndSD1	:= 0
Private cRegSD1	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SF4")
cArqSF4 := Alias()
cIndSF4 := IndexOrd()
cRegSF4 := Recno()

DbSelectArea("SD1")
cArqSD1 := Alias()
cIndSD1 := IndexOrd()
cRegSD1 := Recno()

//Armazena o Grupo
SF4->(DbSetOrder(1))
SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
xGrupo := SF4->F4_YCCONT

//Busca Conta Contabil pelo Tipo de Produto
cSql5 := ""
cSql5 += "SELECT	B1_COD, B1_YTPPROD, " + Enter5
cSql5 += "		Z6_CTRSVDI,  --VENDA MERC. INTERNO " + Enter5
cSql5 += "		Z6_CTRSVDE,  --VENDA MERC. EXTERNO " + Enter5
cSql5 += "		Z6_CTASERV,  --LOCACAO DE BENS " + Enter5
cSql5 += "		Z6_CTARSDV,  --DEVOLUCAO VENDA " + Enter5
cSql5 += "		Z6_CTAIPI,	 --IPI " + Enter5
cSql5 += "		Z6_CTAICMS,	 --ICMS " + Enter5
cSql5 += "		Z6_CTAPIS,   --PIS " + Enter5
cSql5 += "		Z6_CTACOF,   --COFINS " + Enter5
cSql5 += "		Z6_CTDESIN,	 --DESCONTO INCONDICIONAL " + Enter5
cSql5 += "		Z6_CTICMST,	 --ICMS SUBST. TRIBUTARIA " + Enter5
cSql5 += "		Z6_CTIPIDV,  --IPI DEVOLUCAO 	" + Enter5
cSql5 += "		Z6_CTICMDV,	 --ICMS DEVOLUCAO 	" + Enter5
cSql5 += "		Z6_CTPISDV,  --PIS DEVOLUCAO 	" + Enter5
cSql5 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO	" + Enter5
cSql5 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter5
cSql5 += "WHERE	SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter5
cSql5 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter5
cSql5 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter5
cSql5 += "		SB1.B1_COD  	= '"+SD1->D1_COD+"'		AND	" + Enter5
cSql5 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter5
cSql5 += "		SB1.D_E_L_E_T_	= ''						" + Enter5
If chkfile("TRB5")
	DbSelectArea("TRB5")
	DbCloseArea("TRB5")
EndIf
TCQUERY cSql5 ALIAS "TRB5" NEW

IF xGrupo == '020'
	cconta5 := TRB5->Z6_CTICMDV
ENDIF

//Volta area de Trabalho
If cArqSF4 <> ""
	dbSelectArea(cArqSF4)
	dbSetOrder(cIndSF4)
	dbGoTo(cRegSF4)
	RetIndex("SF4")
EndIf

If cArqSD1 <> ""
	dbSelectArea(cArqSD1)
	dbSetOrder(cIndSD1)
	dbGoTo(cRegSD1)
	RetIndex("SD1")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

//Fecha area de trabalho temporaria
DbSelectArea("TRB5")
DbCloseArea("TRB5")

Return(cconta5)
