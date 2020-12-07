#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP610004  º Autor ³ Ranisses A. Corona º Data ³  30/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Contas de IPI de faturamento                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilizacao Faturamento                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP610004()
Private Enter4	:= CHR(13)+CHR(10)
Private cconta4	:= ""
Private cSql4	:= ""
Private xgrupo  := ""

//Armazena area de Trabalho
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0 

Private cArqSF4	:= ""
Private cIndSF4	:= 0
Private cRegSF4	:= 0 

Private cArqSD2	:= ""
Private cIndSD2	:= 0
Private cRegSD2	:= 0 

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SF4")
cArqSF4 := Alias()
cIndSF4 := IndexOrd()
cRegSF4 := Recno()
                   
DbSelectArea("SD2")
cArqSD2 := Alias()
cIndSD2 := IndexOrd()
cRegSD2 := Recno()

//Armazena o Grupo
SF4->(DbSetOrder(1))
SF4->(DbSeek(xFilial("SD2")+SD2->D2_TES))
xGrupo := SF4->F4_YCCONT

//Busca Conta Contabil pelo Tipo de Produto 
cSql4 := ""
cSql4 += "SELECT	B1_COD, B1_YTPPROD, " + Enter4
cSql4 += "		Z6_CTRSVDI,  --VENDA MERC. INTERNO " + Enter4
cSql4 += "		Z6_CTRSVDE,  --VENDA MERC. EXTERNO " + Enter4
cSql4 += "		Z6_CTASERV,  --LOCACAO DE BENS " + Enter4
cSql4 += "		Z6_CTARSDV,  --DEVOLUCAO VENDA " + Enter4
cSql4 += "		Z6_CTAIPI,	 --IPI " + Enter4
cSql4 += "		Z6_CTAICMS,	 --ICMS " + Enter4
cSql4 += "		Z6_CTAPIS,   --PIS " + Enter4
cSql4 += "		Z6_CTACOF,   --COFINS " + Enter4
cSql4 += "		Z6_CTDESIN,	 --DESCONTO INCONDICIONAL " + Enter4
cSql4 += "		Z6_CTICMST,	 --ICMS SUBST. TRIBUTARIA " + Enter4
cSql4 += "		Z6_CTIPIDV,  --IPI DEVOLUCAO	" + Enter4
cSql4 += "		Z6_CTICMDV,	 --ICMS DEVOLUCAO	" + Enter4
cSql4 += "		Z6_CTPISDV,  --PIS DEVOLUCAO	" + Enter4
cSql4 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO	" + Enter4
cSql4 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter4
cSql4 += "WHERE	SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter4
cSql4 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter4
cSql4 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter4
cSql4 += "		SB1.B1_COD  	= '"+SD2->D2_COD+"'		AND	" + Enter4
cSql4 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter4
cSql4 += "		SB1.D_E_L_E_T_	= ''						" + Enter4
If chkfile("TRB4")
	DbSelectArea("TRB4")
	DbCloseArea("TRB4")
EndIf
TCQUERY cSql4 ALIAS "TRB4" NEW

DO CASE
	CASE (Alltrim(SD2->D2_CF) $ "5102_6102_5910_6910_5911_6911_5912_6912_5914_6914" .AND. !SD2->D2_TES $ '515_5B5_671_6H1_672_6H2') .OR.;
        (Alltrim(SD2->D2_TES) $ "660_699_920_897_744" .AND. SM0->M0_CODIGO == '01') .OR.; 
        (Alltrim(SD2->D2_TES) $ "920_9C0_604_6A4_676_6H6_644_6E4" .AND. SM0->M0_CODIGO == '05')
	    cconta4 := "31701003"                                                                                                      
	CASE  (Alltrim(SD2->D2_TES) $ "650_651" .AND. SM0->M0_CODIGO == '01') .OR.; 
        (Alltrim(SD2->D2_TES) $ "650_6F0" .AND. SM0->M0_CODIGO == '05')   
	    cconta4 := "31601004"            
 	OTHERWISE	    
		cconta4 := TRB4->Z6_CTAIPI	    
ENDCASE

//Volta area de Trabalho
If cArqSF4 <> ""
	dbSelectArea(cArqSF4)
	dbSetOrder(cIndSF4)
	dbGoTo(cRegSF4)
	RetIndex("SF4")
EndIf

If cArqSD2 <> ""
	dbSelectArea(cArqSD2)
	dbSetOrder(cIndSD2)
	dbGoTo(cRegSD2)
	RetIndex("SD2")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

//Fecha area de trabalho temporaria
DbSelectArea("TRB4")
DbCloseArea("TRB4")

Return(cconta4)