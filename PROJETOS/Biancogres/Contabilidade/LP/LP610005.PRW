#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} LP610005
@author Ranisses A. Corona
@since 30/01/08
@version 1.0
@description Contas de ICMS de Faturamento
@type function
/*/

User Function LP610005()

	Local aAreaSB1	:= {}

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

	Private cArqSD2	:= ""
	Private cIndSD2	:= 0
	Private cRegSD2	:= 0

	Private msCLVL  := Posicione("SC5", 1, xFilial("SC5") + SD2->D2_PEDIDO, "C5_YCLVL" )

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
	cSql5 := ""
	cSql5 += "SELECT	B1_COD, B1_YTPPROD, B1_GRUPO, " + Enter5
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
	cSql5 += "		SB1.B1_COD  	= '"+SD2->D2_COD+"'		AND	" + Enter5
	cSql5 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter5
	cSql5 += "		SB1.D_E_L_E_T_	= ''						" + Enter5
	If chkfile("TRB5")
		DbSelectArea("TRB5")
		DbCloseArea("TRB5")
	EndIf
	TCQUERY cSql5 ALIAS "TRB5" NEW

	cGrupo := Posicione("SB1", 1, xFilial("SB1") + SD2->D2_COD, "B1_GRUPO")

	DO CASE
		// Por Marcos Alberto Soprani em 17/10/12 a pedido do Robert OS Effettivo - 2365-12
		//CASE SM0->M0_CODIGO == '07'
		//	cconta5 := TRB5->Z6_CTAICMS

		//Tiago/Berger em 31.10.14 a pedido da OS Effetivo 1438-14
		CASE SM0->M0_CODIGO == "13" .And. Alltrim(Substr(cGrupo,1,3)) == "216"
		cconta5 := "41601002"

		//Berger em 20.11.14 a pedido da OS Effetivo 1609-14				//Berger em 11.09.15 OS 1897-15
		/*	CASE SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(Substr(cGrupo,1,3)) $ "101/102/104/107".or. (SM0->M0_CODIGO $ "01/05/14" .And. cGrupo >= '201 ' .And. cGrupo <= '222Z' )
		cconta5 := "41601002"
		*/
		
		/*
		//DESFAZER REGRA
		//Berger em 20.11.14 a pedido da OS Effetivo 1609-14				//Berger em 11.09.15 OS 1897-15																					//OS 3343-15
		CASE SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(Substr(cGrupo,1,3)) $ "101/102/104/107" .or. (SM0->M0_CODIGO $ "01/05/14" .And. cGrupo >= '201 ' .And. cGrupo <= '222Z' .And. cGrupo != '216B')

		If SF4->F4_DUPLIC == "S"
			cconta5 := "41601002"
		Else
			If Substr(SD2->D2_CLVL,1,1) == "3" .or. Substr(msCLVL,1,1) == "3"
				cconta5 := "61601020"
			Else
				If cGrupo == "216C"
					cconta5 := "31406008"
				Else 
					cconta5 := "31701002"
				EndIf
			EndIf
		EndIf
		*/
		
		
			
		/*
		//OS 3343-15 - Venda de Paletes - Berger 25.01.16
		CASE (SM0->M0_CODIGO $ "01/05/14" .And. cGrupo == '216B') //.AND. ALLTRIM(SD2->D2_TES $ '972')
		cconta5 := "31701002"
		*/
		
		
		//Thiago Haagensen - Ticket 25770 - Tratativa na contabilização NF de venda de sucata para os produtos apontados pelo Sidiclei.
		//LP 610/ 005 - ICMS
		CASE (SM0->M0_CODIGO $ "01") .AND. (ALLTRIM(SD2->D2_TES) $ '972/505')
		cconta5 := "41601002"
		
		
		//|Pontin / Facile - Tratamento para vendas eventuais de conta 4 - Effetivo 1520-17 |
		CASE SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(SubStr(cGrupo,1,3)) $ "501" .And. SF4->F4_YCCONT == "530"
		If SF4->F4_DUPLIC == "S"
			cconta5 := "41601002"
		EndIf

		CASE (Alltrim(SD2->D2_CF) $ "5910_6910_5911_6911_5912_6912_5914_6914_6949_5949".AND. !SD2->D2_TES $ '650/651/550/968/5F0/6F0/6F1/9G8') .OR.;	//(Alltrim(SD2->D2_CF) $ "5910_6910_5911_6911_5912_6912_5914_6914_6949_5949") .OR.;    berger
		(Alltrim(SD2->D2_CF) $ "5102_6102" .AND. !SD2->D2_TES $ '515/5B5' .AND. !(AllTrim(SD2->D2_TP) $ 'PA_PR')) .OR.;
		(Alltrim(SD2->D2_TES) $ "660_699_920_897_744" .AND. SM0->M0_CODIGO == '01') .OR.;
		(Alltrim(SD2->D2_TES) $ "699_6J9_920_9C0_604_6A4_676_6H6_644_6E4_660_6G0" .AND. SM0->M0_CODIGO == '05')
		// Implementado por Marcos Alberto Soprani em 30/06/15 conforme solcitação da Tania, effettivo 2543-15
		If Substr(SD2->D2_CLVL,1,1) == "3" .or. Substr(msCLVL,1,1) == "3"
			cconta5 := "61601020"
		Else
			cconta5 := "31701002"
		EndIf

		//|Pontin / Facile - OS 1771-17 - Tratamento para contabilizar notas de garantia (RPV) |
		Case (cEmpAnt == "01" .And. AllTrim(SD2->D2_TES) $ "650/651/550/968") .Or.;	//|Biancogrês |
		(cEmpAnt $ "05/07" .And. AllTrim(SD2->D2_TES) $ "6F0/5F0/6F1/9G8")		//|Incesa e LM |

		If Substr(SD2->D2_CLVL,1,1) == "3" .or. Substr(msCLVL,1,1) == "3"
			cconta5 := "61601022"
		Else
			cconta5 := "31401019"
		EndIf

		OTHERWISE

		cconta5 := TRB5->Z6_CTAICMS

	ENDCASE
	
	//Marcelo - Facile - OS 11924-19
	//Caso o CFOP utilizado seja de Venda de Ativo Imobilizado, o sistema irá inserir a Conta Débito informada.
	IF ALLTRIM(SD2->D2_CF) $ "5551/6551"
		cconta5 := "42101005"
	ENDIF 
	
	//|Pontin / Facile - OS 2389-16 - Tratamento para contabilizar brindes e expositores |
	//|Caso seja grupo 216C ou 216D, ignora qualquer outra regra e busca a conta do produto |
	aAreaSB1	:= SB1->(GetArea())
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))

	If AllTrim(SB1->B1_GRUPO) == "216C" .Or. AllTrim(SB1->B1_GRUPO) == "216D"
		cconta5	:= SB1->B1_YCTRADM
	EndIf
	RestArea(aAreaSB1)

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
	DbSelectArea("TRB5")
	DbCloseArea("TRB5")

Return(cconta5)
