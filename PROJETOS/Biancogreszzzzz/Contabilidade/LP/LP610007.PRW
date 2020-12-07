#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function LP610007()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP610007  º Autor ³ Ranisses A. Corona º Data ³  30/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Contas de COFINS de Faturamento                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilizacao Faturamento                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private Enter7	:= CHR(13)+CHR(10)
Private cconta7	:= ""
Private cSql7	:= ""

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
cSql7 := ""
cSql7 += "SELECT	B1_COD, B1_YTPPROD, B1_GRUPO, " + Enter7
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
cSql7 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO	" + Enter7
cSql7 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter7
cSql7 += "WHERE	SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter7
cSql7 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter7
cSql7 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter7
cSql7 += "		SB1.B1_COD  	= '"+SD2->D2_COD+"'		AND	" + Enter7
cSql7 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter7
cSql7 += "		SB1.D_E_L_E_T_	= ''						" + Enter7
If chkfile("TRB7")
	DbSelectArea("TRB7")
	DbCloseArea("TRB7")
EndIf
TCQUERY cSql7 ALIAS "TRB7" NEW

cGrupo := Posicione("SB1", 1, xFilial("SB1") + SD2->D2_COD, "B1_GRUPO")

//Berger em 30.10.14 a pedido da OS Effetivo 1438-14
IF (SM0->M0_CODIGO == "13" .And. Alltrim(Substr(cGrupo,1,3)) == "216")
	cconta7 := "41601004"
ELSE
	//Berger em 20.11.14 a pedido da OS Effetivo 1609-14					//Berger em 11.09.15 OS 1897-15
	/*	IF  (SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(Substr(cGrupo,1,3)) $ "101/102/104/107") .or. (SM0->M0_CODIGO $ "01/05/14" .And. cGrupo >= '201 ' .And. cGrupo <= '222Z' )
	cconta7 := "41601004"
	*/
	//Berger em 20.11.14 a pedido da OS Effetivo 1609-14					//Berger em 11.09.15 OS 1897-15																				//OS 3343-15
	IF  (SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(Substr(cGrupo,1,3)) $ "101/102/104/107") .or. (SM0->M0_CODIGO $ "01/05/14" .And. cGrupo >= '201 ' .And. cGrupo <= '222Z' .And. cGrupo != '216B')
		cconta7 := "41601004"
	ELSE
		
		/*
		//OS 3343-15 - Venda de Paletes - Berger 25.01.16
		IF(SM0->M0_CODIGO $ "01/05/14" .And. cGrupo == '216B')
			cconta7 := "31701008"
		*/
		
		//Thiago Haagensen - Ticket 25770 - Tratativa na contabilização NF de venda de sucata para os produtos apontados pelo Sidiclei.
		//LP 610/ 007 - COFINS
		IF (SM0->M0_CODIGO $ "01") .AND. (ALLTRIM(SD2->D2_TES) $ '972/505/619') 
		cconta7 := "41601004"
			
		//|Pontin / Facile - Tratamento para vendas eventuais de conta 4 - Effetivo 1520-17 |
		ElseIf SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(SubStr(cGrupo,1,3)) $ "501" .And. SF4->F4_YCCONT == "530"
			cconta7 := "41601004" 
		
		//|Pontin / Facile - Tratamento para vendas de oleo - Effetivo 2042-17 |
		ElseIf SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(SD2->D2_COD) $ "5010020"	//|Tania pediu para amarrar diretamente ao produto 5010020 |
			cconta7 := "41601004" 
			
		// Marcelo Sousa / Facile - Tratamento empresa 06 filial 07 - OS 9190-18
		Elseif (SM0->M0_CODIGO == '06' .AND. ALLTRIM(SM0->M0_CODFIL) == '07')
			cconta7 := "41201040000005"
			
		ELSE
			IF (!SD2->D2_TES $ "619_576" .AND. SM0->M0_CODIGO == '01') .OR.;
				( SD2->D2_TES $ "576"     .AND. SD2->D2_TP == "PA" .AND. SM0->M0_CODIGO == '01') .OR.;   //Venda da Biancogres para LM
				(!SD2->D2_TES $ "589_5I9_676_6H6_604_6A4_619_6B9" .AND. SM0->M0_CODIGO == '05') .OR.;     	  	            //Remessa de Sucata, Óleo e Embalagem
				(SM0->M0_CODIGO $ '06_07_13_14') 																													//JK e LM e MUNDI(por Marcos Alberto em 30/03/12)
				cconta7 := TRB7->Z6_CTACOF
			ELSE
				IF (SD2->D2_TES == "619" .AND. SM0->M0_CODIGO == '01') .OR.;
					(SD2->D2_TES $ "589_5I9_676_6H6_604_6A4_619_6B9_660_6G0" .AND. SM0->M0_CODIGO == '05')
					cconta7 := "41601004" //OS 2485-15 cconta7 := "31701008"
				ELSE
					cconta7 := "31701003"
				ENDIF
			ENDIF
		ENDIF
	ENDIF
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
