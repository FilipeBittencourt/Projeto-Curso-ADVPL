#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/
{Protheus.doc} BIAFS002
Relatório de Apuração Pis Cofins
@author Emerson Salvador
@since 16/07/2021
@version 1.0
@type function
/*/																								

User Function BIAFS002()

	Local 	dPerIni 	:= Ctod("//")
	Local 	dPerFim 	:= Ctod("//")
	Local   cTipoNF		:= "1"
	Private cEnter 		:= CHR(13)+CHR(10)
	Private aPergs 		:= {}	
	Private aParamBox  	:= {}
	
	aAdd(aParamBox, {1, "Data de",  	  dPerIni,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aParamBox, {1, "Data até", 	  dPerFim,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aParamBox, {2, 'Considera NF´s', cTipoNF,{"1=Somente c/ PIS/Cofins",  "2=Todas"},     122, ".T.", .F.})

	If !ParamBox(aParamBox,'Apuração Pis Cofins')
		Return
	EndIf

	dPerIni := MV_PAR01
	dPerFim := MV_PAR02
	cTipoNF := MV_PAR03		
	
	FWMsgRun(, {|| ProcRel(dPerIni, dPerFim, cTipoNF)}, "Processando", "Relatório Apuração Pis Cofins","Processando dados...")
	
Return

/*/
{Protheus.doc} ProcRel
Processa relatório
@author Emerson Salvador
@since 16/07/2021
@version undefined
@type function
/*/
Static Function ProcRel(dPerIni, dPerFim, cTipoNF)

	Local oExcel 	
	Local _AbaPlan 	:= ""
	Local _TitPlan 	:= ""
	Local cArqTemp	:= GetTempPath()+'biafs002.xml'
	Local cQry		:= ""
	Local Qry 	 
	Local aAlter	:= {}

	oExcel := FWMSEXCELEX():New()

	oExcel:SetFont("Arial")
	oExcel:SetFontSize(10)

	/* ---- Monta Aba 1 - Resumo Entradas ----- */		
	_AbaPlan := "Resumo Entradas"
	_TitPlan := "Resumo NF´s Entradas de " + cValToChar(dPerIni) + " até " + cValToChar(dPerFim)
		
	oExcel:AddworkSheet(_AbaPlan)
	oExcel:AddTable(_AbaPlan, _TitPlan)

	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cred.PIS/COF"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cód.Base"			,1,1)   // Código Base
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cód.Fiscal"		,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Contábil"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base PIS"			,3,2,.F.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base COFINS"		,3,2,.F.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor PIS" 		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor COFINS"		,3,2,.F.)

	// Processa consulta
	Qry := GetNextAlias()
	fConsultaSQL("RES_ENT", cTipoNF, dPerIni, dPerFim, Qry)

	If !(Qry)->(Eof())

		nTotVlrCont := 0
		nTotBasPIS	:= 0		
		nTotBasCOF 	:= 0
		nTotVlPIS	:= 0
		nTotVlCOF	:= 0
		aAlter 		:= {}

		While !(Qry)->(Eof())

			// Gera linha com Total por Situacao ou CFOP 														
			If (Qry)->TIPO == "0" .Or. (Qry)->TIPO == "1"
				oExcel:SetCelFont('Arial')				
				oExcel:SetCelSizeFont(11)
				oExcel:SetCelBold(.T.)
				If (Qry)->TIPO == "1" 
					oExcel:SetCelBgColor("#4682B4")
				Else										
					oExcel:SetCelBgColor("#0070C0")
				Endif	
				aAlter := {1,2,3,4,5,6,7,8}
			Else				
				oExcel:SetCelFont('Arial')				
				oExcel:SetCelSizeFont(10)
				oExcel:SetCelBold(.F.)	
				oExcel:SetCelBgColor("#B0C4DE")		 	 // Cor de fundo da Celula por CST
				aAlter := {1,2,3,4,5,6,7,8}
			Endif

			oExcel:AddRow(_AbaPlan, _TitPlan, { IIf((Qry)->TIPO == "0", (Qry)->DESCPISCRED, ""),;
												IIf((Qry)->TIPO == "1", (Qry)->CST, ""),;
												IIf((Qry)->TIPO == "2", (Qry)->CFOP, ""),; 												
												(Qry)->VLR_CONTABIL,;
												(Qry)->BASE_PIS,;
												(Qry)->BASE_COF,;
												(Qry)->VAL_PIS,;
												(Qry)->VAL_COF },;
												aAlter )

			// Totalizadores - Rodape - Tipo de situação
			If (Qry)->TIPO == "0" 
				nTotVlrCont += (Qry)->VLR_CONTABIL
				nTotBasPIS	+= (Qry)->BASE_PIS		
				nTotBasCOF 	+= (Qry)->BASE_COF
				nTotVlPIS	+= (Qry)->VAL_PIS
				nTotVlCOF	+= (Qry)->VAL_COF
			Endif

			(Qry)->(DbSkip())
		Enddo

		// Imprime Total Geral 
		If (nTotVlrCont+nTotBasPIS+nTotBasCOF+nTotVlPIS+nTotVlCOF) <> 0 			

			oExcel:SetCelFont('Arial')				
			oExcel:SetCelSizeFont(11)
			oExcel:SetCelBold(.T.)
			oExcel:SetCelBgColor("#4682B4")   // Cor de fundo da Celula quando for linha Totalizadora do resumo

			aAlter := {1,2,3,4,5,6,7,8}

			oExcel:AddRow(_AbaPlan, _TitPlan, { "Total Geral",;
												"",; 
												"",;
												nTotVlrCont,;
												nTotBasPIS,;
												nTotBasCOF,;
												nTotVlPIS,;
												nTotVlCOF },;
												aAlter )
		Endif										
	Else
		oExcel:AddRow(_AbaPlan, _TitPlan, {  "",;
											 "",;
											 "",; 												
											 0,;
											 0,;
											 0,;
											 0,;
											 0 })
	Endif						

	(Qry)->(dbCloseArea())

	/* ---- Monta Aba 2 - Entradas ----- */		
	_AbaPlan := "Entradas"
	_TitPlan := "NF´s Entradas de " + cValToChar(dPerIni) + " até " + cValToChar(dPerFim) //+ " - Filial " + cFilAnt
		
	oExcel:AddworkSheet(_AbaPlan)
	oExcel:AddTable(_AbaPlan, _TitPlan)

	oExcel:AddColumn(_AbaPlan, _TitPlan, "Filial"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cód.Fiscal"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "PIS/COFINS"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cred.PIS/COF"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Sit.Trib.PIS"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Sit.Trib.COF"		,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cód.Base"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Produto"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Regra"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Contábil"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Total"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Tipo Entrada"		,1,1)		
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Aliq.IPI"			,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.IPI"			,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Aliq.ICMS"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.ICMS"			,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base ICMS"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Base IPI"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Centro Custo"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cód.Cl.Val"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "CContábil"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "N.F.Original"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Nome Forn/Cliente",1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Forn/Cliente"		,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Documento"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "DT.Emissão"		,1,4)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "DT.Digitaçaõ"		,1,4)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Grupo"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Devol."		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "ICMSSolid."		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Desconto"			,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.I.I."			,2,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "TEC/NCM/QUAL"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base Imp. 5"		,3,2,.T.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base Imp. 6"		,3,2,.T.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Imp. 5" 	,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Imp. 6"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Aliq. Imp. 5"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Aliq. Imp. 6"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Despesa" 		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Seguro" 		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Frete" 		,3,2,.T.)

	// Processa consulta
	Qry := GetNextAlias()
	fConsultaSQL("ENT", cTipoNF, dPerIni, dPerFim, Qry)

	If !(Qry)->(Eof())
		While !(Qry)->(Eof())

			oExcel:AddRow(_AbaPlan, _TitPlan, { (Qry)->D1_FILIAL,;
												(Qry)->D1_CF,;
												(Qry)->F4_PISCOF,;
												(Qry)->F4_PISCRED,;
												(Qry)->F4_CSTPIS,; 
												(Qry)->F4_CSTCOF,;
												(Qry)->F4_CODBCC,;
												(Qry)->D1_COD,;
												(Qry)->D1_YREGRA,;
												(Qry)->VLR_CONTABIL,;
												(Qry)->D1_TOTAL,;
												(Qry)->D1_TES,;												
												(Qry)->D1_IPI,;
												(Qry)->D1_VALIPI,;
												(Qry)->D1_PICM,;
												(Qry)->D1_VALICM,;
												(Qry)->D1_BASEICM,;
												(Qry)->D1_BASEIPI,;
												(Qry)->D1_CC,;
												(Qry)->D1_CLVL,;
												(Qry)->D1_CONTA,;
												(Qry)->D1_NFORI,;
												(Qry)->NOME_CLI,;
												(Qry)->D1_FORNECE,;												
												(Qry)->D1_DOC,;
												STOD((Qry)->D1_EMISSAO),; 
												STOD((Qry)->D1_DTDIGIT),;
												(Qry)->D1_GRUPO,;
												(Qry)->D1_VALDEV,;
												(Qry)->D1_ICMSRET,;
												(Qry)->D1_VALDESC,;
												(Qry)->D1_II,;
												(Qry)->D1_TEC,;
												(Qry)->D1_BASIMP5,;
												(Qry)->D1_BASIMP6,;
												(Qry)->D1_VALIMP5,;
												(Qry)->D1_VALIMP6,;
												(Qry)->D1_ALQIMP5,;
												(Qry)->D1_ALQIMP6,;
												(Qry)->D1_DESPESA,;
												(Qry)->D1_SEGURO,;
												(Qry)->D1_VALFRE } ) 
		
			(Qry)->(DbSkip())
		Enddo
	Else
		oExcel:AddRow(_AbaPlan, _TitPlan, { "",;
											"",;	
											"",;
											"",;
											"",;
											"",;
											"",;
											"",;
											"",;
											0,;
											0,;
											"",;
											0,;	
											0,;	
											0,;	
											0,;	
											0,;	
											0,;	
											"",;
											"",;
											"",;
											"",;
											"",;
											"",;
											"",;
											"",;
											"",;
											"",;
											"",;
											0,;
											0,;
											0,;
											0,;
											0,;
											0,;
											0,;
											0,;
											0,;
											0,;
											0,;
											0,;
											0 } ) 
	
	Endif
	(Qry)->(dbCloseArea())

	/* ---- Monta Aba 3 - Resumo Saídas ----- */
	_AbaPlan := "Resumo Saídas"
	_TitPlan := "Resumo Saídas de " + cValToChar(dPerIni) + " até " + cValToChar(dPerFim)
		
	oExcel:AddworkSheet(_AbaPlan)
	oExcel:AddTable(_AbaPlan, _TitPlan)

	oExcel:AddColumn(_AbaPlan, _TitPlan, "CST"				,1,1)   
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cód.Fiscal"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Contábil"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base PIS"			,3,2,.F.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base COFINS"		,3,2,.F.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor PIS" 		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor COFINS"		,3,2,.F.)

	// Processa consulta
	Qry := GetNextAlias()
	fConsultaSQL("RES_SAI", cTipoNF, dPerIni, dPerFim, Qry)

	If !(Qry)->(Eof())

		nTotVlrCont := 0
		nTotBasPIS	:= 0		
		nTotBasCOF 	:= 0
		nTotVlPIS	:= 0
		nTotVlCOF	:= 0
		aAlter 		:= {}

		While !(Qry)->(Eof())

			// Gera linha com Total por CFOP
			If (Qry)->TIPO == "0"
				oExcel:SetCelFont('Arial')				
				oExcel:SetCelSizeFont(11)
				oExcel:SetCelBold(.T.)
				oExcel:SetCelBgColor("#4682B4")
				aAlter := {1,2,3,4,5,6,7}
			Else				
				oExcel:SetCelFont('Arial')				
				oExcel:SetCelSizeFont(10)
				oExcel:SetCelBold(.F.)	
				oExcel:SetCelBgColor("#B0C4DE")		 	 // Cor de fundo da Celula por CST
				aAlter := {1,2,3,4,5,6,7}		
				//aAlter := {}	
			Endif
			
			oExcel:AddRow(_AbaPlan, _TitPlan, { IIf((Qry)->TIPO == "0", (Qry)->CST, ""),;
												IIf((Qry)->TIPO == "1", (Qry)->CFOP, ""),; 												
												(Qry)->VLR_CONTABIL,;
												(Qry)->BASE_PIS,;
												(Qry)->BASE_COF,;
												(Qry)->VAL_PIS,;
												(Qry)->VAL_COF },;
												aAlter )

			// Totalizadores - Rodape - Tipo por CFOP
			If (Qry)->TIPO == "0" 
				nTotVlrCont += (Qry)->VLR_CONTABIL
				nTotBasPIS	+= (Qry)->BASE_PIS		
				nTotBasCOF 	+= (Qry)->BASE_COF
				nTotVlPIS	+= (Qry)->VAL_PIS
				nTotVlCOF	+= (Qry)->VAL_COF
			Endif

			(Qry)->(DbSkip())
		Enddo

		// Imprime Total Geral 
		If (nTotVlrCont+nTotBasPIS+nTotBasCOF+nTotVlPIS+nTotVlCOF) <> 0 			

			oExcel:SetCelFont('Arial')				
			oExcel:SetCelSizeFont(11)
			oExcel:SetCelBold(.T.)
			oExcel:SetCelBgColor("#4682B4")

			aAlter := {1,2,3,4,5,6,7}

			oExcel:AddRow(_AbaPlan, _TitPlan, { "Total Geral",;
												"",; 
												nTotVlrCont,;
												nTotBasPIS,;
												nTotBasCOF,;
												nTotVlPIS,;
												nTotVlCOF },;
												aAlter )
		Endif										
	Else
			oExcel:AddRow(_AbaPlan, _TitPlan, { "",;
												"",; 												
												0,;
												0,;
												0,;
												0,;
												0 } )
												
	Endif						

	(Qry)->(dbCloseArea())

	/* ---- Monta Aba 4 - Saídas ----- */
	
	_AbaPlan := "Saídas"
	_TitPlan := "NF´s Saídas de " + cValToChar(dPerIni) + " até " + cValToChar(dPerFim) //+ " - Filial " + cFilAnt
		
	oExcel:AddworkSheet(_AbaPlan)
	oExcel:AddTable(_AbaPlan, _TitPlan)

	oExcel:AddColumn(_AbaPlan, _TitPlan, "Filial"			,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Produto"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Desc. Prod."		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Contábil"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Total"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.IPI"			,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.ICMS"			,3,2,.T.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Tipo Saida"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Sit.Trib Pis"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Sit.Trib Cofins"	,1,1)										
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cod. Fiscal"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Aliq. IPI"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Aliq. ICMS"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "C Contabil"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Nome Cliente"		,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cliente"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Num. da Nota"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Emissão"			,1,4)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Almoxarifado"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Tipo Produto"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Grupo"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Estado Dest."		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Desconto"			,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "N.F.Original"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Devol."		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Ret. ICMS"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base ICMS"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "ICMS Solid."		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Desc.Z.Franc"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Sit.Tribut."		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base Imp. 5"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base Imp. 6"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Imp. 5"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Imp. 6"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Centro Custo"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cod Cl Val"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr. Despesa"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr. Seguro"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr. Frete"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Aliq. Imp. 5"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Aliq. Imp. 6" 	,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Bruto" 		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Data Digit." 		,1,4)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Val.Pis.ZFM" 		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Val.Cof.ZFM" 		,3,2,.T.)

	// Processa consulta
	Qry := GetNextAlias()
	fConsultaSQL("SAI", cTipoNF, dPerIni, dPerFim, Qry)

	If !(Qry)->(Eof())
		While !(Qry)->(Eof())
			oExcel:AddRow(_AbaPlan, _TitPlan, { (Qry)->D2_FILIAL,;
												(Qry)->D2_COD,;
												(Qry)->B1_DESC,;
												(Qry)->VLR_CONTABIL,;
												(Qry)->D2_TOTAL,;
												(Qry)->D2_VALIPI,;
												(Qry)->D2_VALICM,;
												(Qry)->D2_TES,;
												(Qry)->F4_CSTPIS,;
												(Qry)->F4_CSTCOF,;										
												(Qry)->D2_CF,;
												(Qry)->D2_IPI,;
												(Qry)->D2_PICM,;
												(Qry)->D2_CONTA,;
												(Qry)->NOMECLIFOR,;   //(Qry)->A1_NOME,;
												(Qry)->D2_CLIENTE,; 												
												(Qry)->D2_DOC,;
												Stod((Qry)->D2_EMISSAO),;
												(Qry)->D2_LOCAL,;
												(Qry)->D2_TP,;
												(Qry)->D2_GRUPO,;
												(Qry)->D2_EST,;
												(Qry)->D2_DESC,;
												(Qry)->D2_NFORI,;
												(Qry)->D2_VALDEV,;
												(Qry)->D2_BRICMS,;
												(Qry)->D2_BASEICM,;
												(Qry)->D2_ICMSRET,;
												(Qry)->D2_DESCZFR,;
												(Qry)->D2_CLASFIS,;
												(Qry)->D2_BASIMP5,;
												(Qry)->D2_BASIMP6,;
												(Qry)->D2_VALIMP5,;
												(Qry)->D2_VALIMP6,;
												(Qry)->D2_CCUSTO,;
												(Qry)->D2_CLVL,;
												(Qry)->D2_DESPESA,;
												(Qry)->D2_SEGURO,;
												(Qry)->D2_VALFRE,;
												(Qry)->D2_ALQIMP5,;
												(Qry)->D2_ALQIMP6,;
												(Qry)->D2_VALBRUT,;
												Stod((Qry)->D2_DTDIGIT),;
												(Qry)->D2_DESCZFP,;
												(Qry)->D2_DESCZFC } ) 
		
			(Qry)->(DbSkip())
		Enddo
	Else
			oExcel:AddRow(_AbaPlan, _TitPlan, { "",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;										
												"",;
												0,;
												0,;
												"",;
												"",;
												"",; 												
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												0,;
												0,;
												0,;
												0,;
												0,;
												"",;
												0,;
												0,;
												0,;
												0,;
												"",;
												"",;
												0,;
												0,;
												0,;
												0,;
												0,;
												0,;
												"",;
												0,;
												0 } ) 
	Endif						
	(Qry)->(dbCloseArea())

	/* ---- Monta Aba 5 - Resumo Devoluções ----- */
	_AbaPlan := "Resumo Devoluções"
	_TitPlan := "Resumo Devoluções de " + cValToChar(dPerIni) + " até " + cValToChar(dPerFim)
		
	oExcel:AddworkSheet(_AbaPlan)
	oExcel:AddTable(_AbaPlan, _TitPlan)

	oExcel:AddColumn(_AbaPlan, _TitPlan, "CST"				,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cód.Fiscal"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Contábil"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base PIS"			,3,2,.F.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base COFINS"		,3,2,.F.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor PIS" 		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor COFINS"		,3,2,.F.)

	// Processa consulta
	Qry := GetNextAlias()
	fConsultaSQL("RES_DEV", cTipoNF, dPerIni, dPerFim, Qry)

	If !(Qry)->(Eof())

		nTotVlrCont := 0
		nTotBasPIS	:= 0		
		nTotBasCOF 	:= 0
		nTotVlPIS	:= 0
		nTotVlCOF	:= 0
		aAlter 		:= {}

		While !(Qry)->(Eof())

			// Gera linha com Total por CFOP
			If (Qry)->TIPO == "0"  //.Or. (Qry)->TIPO == "1"
				oExcel:SetCelFont('Arial')				
				oExcel:SetCelSizeFont(11)
				oExcel:SetCelBold(.T.)
				oExcel:SetCelBgColor("#4682B4")				
				aAlter := {1,2,3,4,5,6,7}
			Else				
				oExcel:SetCelFont('Arial')				
				oExcel:SetCelSizeFont(10)
				oExcel:SetCelBold(.F.)	
				oExcel:SetCelBgColor("#B0C4DE")		 	 // Cor de fundo da Celula por CST
				aAlter := {1,2,3,4,5,6,7}			
			Endif

			//IIf((Qry)->TIPO == "0", (Qry)->DESCPISCRED, ""),;
			oExcel:AddRow(_AbaPlan, _TitPlan, { IIf((Qry)->TIPO == "0", (Qry)->CST, ""),;
												IIf((Qry)->TIPO == "1", (Qry)->CFOP, ""),; 												
												(Qry)->VLR_CONTABIL,;
												(Qry)->BASE_PIS,;
												(Qry)->BASE_COF,;
												(Qry)->VAL_PIS,;
												(Qry)->VAL_COF },;
												aAlter )

			// Totalizadores - Rodape - Tipo por CFOP
			If (Qry)->TIPO == "0" 
				nTotVlrCont += (Qry)->VLR_CONTABIL
				nTotBasPIS	+= (Qry)->BASE_PIS		
				nTotBasCOF 	+= (Qry)->BASE_COF
				nTotVlPIS	+= (Qry)->VAL_PIS
				nTotVlCOF	+= (Qry)->VAL_COF
			Endif

			(Qry)->(DbSkip())
		Enddo

		// Imprime Total Geral 
		If (nTotVlrCont+nTotBasPIS+nTotBasCOF+nTotVlPIS+nTotVlCOF) <> 0 			

			oExcel:SetCelFont('Arial')				
			oExcel:SetCelSizeFont(11)
			oExcel:SetCelBold(.T.)
			oExcel:SetCelBgColor("#4682B4")

			aAlter := {1,2,3,4,5,6,7}

			oExcel:AddRow(_AbaPlan, _TitPlan, { "Total Geral",;
												"",; 
												nTotVlrCont,;
												nTotBasPIS,;
												nTotBasCOF,;
												nTotVlPIS,;
												nTotVlCOF },;
												aAlter )
		Endif										
	Else
			oExcel:AddRow(_AbaPlan, _TitPlan, { "",;
												"",; 												
												0,;
												0,;
												0,;
												0,;
												0 } )
												
	Endif						

	(Qry)->(dbCloseArea())

	/* ---- Monta Aba 6 - Devoluções ----- */
	
	_AbaPlan := "Devoluções"
	_TitPlan := "NF´s Devoluções de " + cValToChar(dPerIni) + " até " + cValToChar(dPerFim) //+ " - Filial " + cFilAnt
		
	oExcel:AddworkSheet(_AbaPlan)
	oExcel:AddTable(_AbaPlan, _TitPlan)
		
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Filial"			,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Produto"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Desc. Prod."		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Contábil"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Total"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.IPI"			,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.ICMS"			,3,2,.T.)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Tipo Saida"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Sit.Trib Pis"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Sit.Trib Cofins"	,1,1)										
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cod. Fiscal"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Desc.Item"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "C Contabil"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Nome Cliente"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cliente"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Loja"				,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Num. da Nota"		,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Série"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Emissão"			,1,4)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "N.F.Original"		,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Série Orig."		,1,1)		
	oExcel:AddColumn(_AbaPlan, _TitPlan, "ICMS Solid."		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base Imp. 5"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Base Imp. 6"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Imp. 5"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Imp. 6"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr. Despesa"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr. Seguro"		,3,2,.T.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr. Frete"		,3,2,.T.)

	// Processa consulta
	Qry  := GetNextAlias()
	cQry := fConsultaSQL("DEV", cTipoNF, dPerIni, dPerFim, Qry)
						
	If !(Qry)->(Eof())
		While !(Qry)->(Eof())
			oExcel:AddRow(_AbaPlan, _TitPlan, { (Qry)->D2_FILIAL,;
												(Qry)->D2_COD,;
												(Qry)->B1_DESC,;
												(Qry)->VLR_CONTABIL,;
												(Qry)->D2_TOTAL,;
												(Qry)->D2_VALIPI,;
												(Qry)->D2_VALICM,;
												(Qry)->D2_TES,;
												(Qry)->F4_CSTPIS,;
												(Qry)->F4_CSTCOF,;										
												(Qry)->D2_CF,;
												(Qry)->D2_DESC,;
												(Qry)->D2_CONTA,;
												(Qry)->A1_NOME,;
												(Qry)->D2_CLIENTE,;
												(Qry)->D2_LOJA,;												
												(Qry)->D2_DOC,;
												(Qry)->D2_SERIE,;
												Stod((Qry)->D2_EMISSAO),;
												(Qry)->D2_NFORI,;
												(Qry)->D2_SERIORI,;
												(Qry)->D2_ICMSRET,;
												(Qry)->D2_BASIMP5,;
												(Qry)->D2_BASIMP6,;
												(Qry)->D2_VALIMP5,;
												(Qry)->D2_VALIMP6,;
												(Qry)->D2_DESPESA,;
												(Qry)->D2_SEGURO,;
												(Qry)->D2_VALFRE } ) 
		
			(Qry)->(DbSkip())
		Enddo
	Else
			oExcel:AddRow(_AbaPlan, _TitPlan, { "",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;										
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;												
												"",;
												"",;
												"",;
												"",;
												"",;
												0,;
												0,;
												0,;
												0,;
												0,;
												0,;
												0,;
												0 } ) 
	
	Endif						
	(Qry)->(dbCloseArea())

	// Gera o Arquivo em Excel
	If File(cArqTemp)
		If fErase(cArqTemp) == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + cArqTemp + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf
		
	oExcel:Activate()
	oExcel:GetXMLFile(cArqTemp)
		
	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+cArqTemp )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( cArqTemp ) // Abre uma planilha
		oExcel:SetVisible(.T.)
		oExcel:Destroy()
	EndIf
Return


/*/
{Protheus.doc} fConsultaSQL
Gera string da Query para consulta 
@author Emerson Salvador
@since 16/07/2021
@version undefined
@type function
/*/
Static Function fConsultaSQL(cABA, cTipoNF, dPerIni, dPerFim, Qry)
		
	Local cExpNF := "% 1 = 1 %"

	If cABA == "RES_ENT"  // Resumo Entradas

		If cTipoNF = "1"  // Somente NF PIS Cofins
			cExpNF := "% (D1_VALIMP5 > 0 OR D1_VALIMP6 > 0) %"	
		Endif	

		BeginSql Alias Qry   

			%NOPARSER%

			SELECT		
				DESCPISCRED, 
				TIPO, 
				PISCRED,				
				CST,	
				CFOP,									
				VLR_CONTABIL, 
				BASE_PIS,
				BASE_COF,				
				VAL_PIS,
				VAL_COF

				FROM (

					//----- POR TIPO DE SITUAÇÃO
					SELECT				
						DESCPISCRED  = CASE WHEN  F4_PISCRED = '1' THEN 'Credita' 
											WHEN  F4_PISCRED = '2' THEN 'Debita' 	  
											WHEN  F4_PISCRED = '3' THEN 'Não Calcula' 
											WHEN  F4_PISCRED = '4' THEN 'Calcula' 
											WHEN  F4_PISCRED = '5' THEN 'Exclusão de Base' ELSE '' END, 
						TIPO = '0',
						PISCRED = F4_PISCRED,					
						CST = '',
						CFOP = '',											
						VLR_CONTABIL = SUM((D1_TOTAL + D1_VALIPI + D1_ICMSRET + D1_DESPESA + D1_SEGURO + D1_VALFRE) - D1_VALDESC),
						BASE_PIS = SUM(D1_BASIMP6),
						BASE_COF = SUM(D1_BASIMP5),				
						VAL_PIS = SUM(D1_VALIMP6),
						VAL_COF = SUM(D1_VALIMP5)

					FROM %TABLE:SD1% D1 (NOLOCK)
						INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES AND F4.%notDel%
						INNER JOIN %TABLE:SF1% F1 (NOLOCK) ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1.%notDel%

					WHERE 	
						D1_DTDIGIT >= %Exp:DTOS(dPerIni)% AND D1_DTDIGIT <= %Exp:DTOS(dPerFim)%
							AND %Exp:cExpNF%
					  		AND D1.%notDel%

						GROUP BY F4_PISCRED				

		 		UNION ALL
		 
					//---- POR TIPO DE SITUAÇÃO + CF
					SELECT				
						DESCPISCRED  = CASE WHEN  F4_PISCRED = '1' THEN 'Credita' 
											WHEN  F4_PISCRED = '2' THEN 'Debita' 	  
											WHEN  F4_PISCRED = '3' THEN 'Não Calcula' 
											WHEN  F4_PISCRED = '4' THEN 'Calcula' 
											WHEN  F4_PISCRED = '5' THEN 'Exclusão de Base' ELSE '' END, 
						TIPO = '1',
						PISCRED = F4_PISCRED,					
						CST = F4_CODBCC,
						CFOP = '',						
						VLR_CONTABIL = SUM((D1_TOTAL + D1_VALIPI + D1_ICMSRET + D1_DESPESA + D1_SEGURO + D1_VALFRE) - D1_VALDESC),
						BASE_PIS = SUM(D1_BASIMP6),
						BASE_COF = SUM(D1_BASIMP5),				
						VAL_PIS = SUM(D1_VALIMP6),
						VAL_COF = SUM(D1_VALIMP5)

					FROM %TABLE:SD1% D1 (NOLOCK)
						INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES AND F4.%notDel%
						INNER JOIN %TABLE:SF1% F1 (NOLOCK) ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1.%notDel%

					WHERE 	
						D1_DTDIGIT >= %Exp:DTOS(dPerIni)% AND D1_DTDIGIT <= %Exp:DTOS(dPerFim)%
							AND %Exp:cExpNF%
					  		AND D1.%notDel%

						GROUP BY F4_PISCRED, F4_CODBCC
						
				UNION ALL
		
					// -- POR TIPO DE SITUAÇÃO + CF + CST (CODBASE)
					SELECT				
						DESCPISCRED  = CASE WHEN  F4_PISCRED = '1' THEN 'Credita' 
											WHEN  F4_PISCRED = '2' THEN 'Debita' 	  
											WHEN  F4_PISCRED = '3' THEN 'Não Calcula' 
											WHEN  F4_PISCRED = '4' THEN 'Calcula' 
											WHEN  F4_PISCRED = '5' THEN 'Exclusão de Base' ELSE '' END, 
						TIPO = '2',
						PISCRED = F4_PISCRED,											
						CST = F4_CODBCC,
						CFOP = D1_CF,					
						VLR_CONTABIL = SUM((D1_TOTAL + D1_VALIPI + D1_ICMSRET + D1_DESPESA + D1_SEGURO + D1_VALFRE) - D1_VALDESC),
						BASE_PIS = SUM(D1_BASIMP6),
						BASE_COF = SUM(D1_BASIMP5),				
						VAL_PIS = SUM(D1_VALIMP6),
						VAL_COF = SUM(D1_VALIMP5)

					FROM %TABLE:SD1% D1 (NOLOCK)
						INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES AND F4.%notDel%
						INNER JOIN %TABLE:SF1% F1 (NOLOCK) ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1.%notDel%

					WHERE 	
						D1_DTDIGIT >= %Exp:DTOS(dPerIni)% AND D1_DTDIGIT <= %Exp:DTOS(dPerFim)%
							AND %Exp:cExpNF%
					  		AND D1.%notDel%

						GROUP BY F4_PISCRED, F4_CODBCC, D1_CF

					) AS RES_ENT
					ORDER BY DESCPISCRED, CST, TIPO, CFOP

		EndSql

	Elseif cABA == "ENT"  // Entradas

		If cTipoNF = "1"  // Somente NF PIS Cofins
			cExpNF := "% (D1_VALIMP5 > 0 OR D1_VALIMP6 > 0) %"	
		Endif

		BeginSql Alias Qry   

			%NOPARSER%

			SELECT
				D1_FILIAL,
				D1_CF, 
				F4_PISCOF   = CASE 	WHEN  F4_PISCOF = '1' THEN 'PIS' 
									WHEN  F4_PISCOF = '2' THEN 'COFINS' 	  
									WHEN  F4_PISCOF = '3' THEN 'Ambos' 
									WHEN  F4_PISCOF = '4' THEN 'Não Considera' ELSE '' END, 
				F4_PISCRED   = CASE WHEN  F4_PISCRED = '1' THEN 'Credita' 
									WHEN  F4_PISCRED = '2' THEN 'Debita' 	  
									WHEN  F4_PISCRED = '3' THEN 'Não Calcula' 
									WHEN  F4_PISCRED = '4' THEN 'Calcula' 
									WHEN  F4_PISCRED = '5' THEN 'Exclusão de Base' ELSE '' END, 
				F4_CSTPIS, 
				F4_CSTCOF,
				F4_CODBCC,
				D1_COD,
				D1_YREGRA,
				VLR_CONTABIL = (D1_TOTAL + D1_VALIPI + D1_ICMSRET + D1_DESPESA + D1_SEGURO + D1_VALFRE) - D1_VALDESC,
				D1_TOTAL,
				D1_TES,
				D1_CF,
				D1_IPI,
				D1_VALIPI,
				D1_PICM,
				D1_VALICM,
				D1_BASEICM,
				D1_BASEIPI,
				D1_CC,
				D1_CLVL,
				D1_CONTA,
				D1_NFORI,
				NOME_CLI = CASE WHEN  F1_TIPO IN ('D') THEN ISNULL(A1_NOME, '') ELSE ISNULL(A2_NOME, '') END,				
				D1_FORNECE,
				D1_DOC,
				D1_EMISSAO, 
				D1_DTDIGIT,
				D1_GRUPO,
				D1_VALDEV,
				D1_ICMSRET,
				D1_VALDESC,
				D1_II,
				D1_TEC,
				D1_BASIMP5,
				D1_BASIMP6,
				D1_VALIMP5,
				D1_VALIMP6,
				D1_ALQIMP5,
				D1_ALQIMP6,
				D1_DESPESA,
				D1_SEGURO,
				D1_VALFRE

			FROM %TABLE:SD1% D1 (NOLOCK)
				INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES AND F4.%notDel%
				INNER JOIN %TABLE:SF1% F1 (NOLOCK) ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1.%notDel%
				LEFT JOIN %TABLE:SA1% A1 (NOLOCK) ON A1_FILIAL = %xfilial:SA1% AND A1_COD = F1_FORNECE AND A1_LOJA = F1_LOJA AND F1_TIPO IN ('D') AND A1.%notDel%
				LEFT JOIN %TABLE:SA2% A2 (NOLOCK) ON A2_FILIAL = %xfilial:SA2% AND A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA AND F1_TIPO NOT IN ('D') AND A2.%notDel%

				WHERE D1_DTDIGIT >= %Exp:DTOS(dPerIni)% AND D1_DTDIGIT <= %Exp:DTOS(dPerFim)%
						AND %Exp:cExpNF%
					  	AND D1.%notDel% 
				ORDER BY D1_FILIAL,D1_DOC, D1_DTDIGIT 
		EndSql

	ElseIf cABA == "RES_SAI"    // Resumo SAIDAS

		If cTipoNF = "1"  // Somente NF PIS Cofins
			cExpNF := "% (D2_VALIMP5 > 0 OR D2_VALIMP6 > 0) %"	
		Endif	

		BeginSql Alias Qry   

			%NOPARSER%

			SELECT						
				TIPO, 
				CST,
				CFOP,									
				VLR_CONTABIL, 
				BASE_PIS,
				BASE_COF,				
				VAL_PIS,
				VAL_COF

			FROM (
					SELECT     // Por CFOP
						TIPO = '0',
						CST  = F4_CSTPIS,
						CFOP = '',						
						VLR_CONTABIL = SUM((D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_DESPESA + D2_SEGURO + D2_VALFRE) - D2_DESC),
						BASE_PIS = SUM(D2_BASIMP6),
						BASE_COF = SUM(D2_BASIMP5),				
						VAL_PIS = SUM(D2_VALIMP6),
						VAL_COF = SUM(D2_VALIMP5)

					FROM %TABLE:SD2% D2 (NOLOCK)
						INNER JOIN %TABLE:SB1% B1 (NOLOCK) ON B1_FILIAL = %xfilial:SB1% AND B1_COD = D2_COD AND B1.%notDel% 
						INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4.%notDel%

					WHERE D2_EMISSAO BETWEEN %Exp:DTOS(dPerIni)% AND %Exp:DTOS(dPerFim)%
							AND %Exp:cExpNF%
							AND D2.%notDel% 
					GROUP BY F4_CSTPIS

			UNION ALL

					SELECT     // Por CFOP + CST
						TIPO = '1',
						CST  = F4_CSTPIS,
						CFOP = D2_CF,						
						VLR_CONTABIL = SUM((D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_DESPESA + D2_SEGURO + D2_VALFRE) - D2_DESC),
						BASE_PIS = SUM(D2_BASIMP6),
						BASE_COF = SUM(D2_BASIMP5),				
						VAL_PIS = SUM(D2_VALIMP6),
						VAL_COF = SUM(D2_VALIMP5)

					FROM %TABLE:SD2% D2 (NOLOCK)
						INNER JOIN %TABLE:SB1% B1 (NOLOCK) ON B1_FILIAL = %xfilial:SB1% AND B1_COD = D2_COD AND B1.%notDel% 
						INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4.%notDel%

					WHERE D2_EMISSAO BETWEEN %Exp:DTOS(dPerIni)% AND %Exp:DTOS(dPerFim)%
							AND %Exp:cExpNF%
							AND D2.%notDel% 
					GROUP BY F4_CSTPIS, D2_CF

			) AS RES_SAI								
			ORDER BY CST, TIPO, CFOP
	
		EndSql 

	Elseif cABA == "SAI"   // Saídas

		If cTipoNF = "1"  // Somente NF PIS Cofins
			cExpNF := "% (D2_VALIMP5 > 0 OR D2_VALIMP6 > 0) %"	
		Endif

		BeginSql Alias Qry   

			%NOPARSER%

			SELECT 
				D2_FILIAL,
				D2_COD,
				B1_DESC,
				VLR_CONTABIL = (D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_DESPESA + D2_SEGURO + D2_VALFRE) - D2_DESC,
				D2_TOTAL,
				D2_VALIPI,
				D2_VALICM,
				D2_TES,
				D2_CF,
				D2_IPI,
				D2_PICM,
				D2_CONTA,
				NOMECLIFOR = IIF(D2_TIPO = 'D', A2_NOME, A1_NOME),
				D2_CLIENTE, 				
				D2_DOC,
				D2_EMISSAO,
				D2_LOCAL,
				D2_TP,
				D2_GRUPO,
				D2_EST,
				D2_DESC,
				D2_NFORI,
				D2_VALDEV,
				D2_BRICMS,
				D2_BASEICM,
				D2_ICMSRET,;
				D2_DESCZFR,
				D2_CLASFIS,
				D2_BASIMP5,
				D2_BASIMP6,
				D2_VALIMP5,
				D2_VALIMP6,
				D2_CCUSTO,
				D2_CLVL,
				D2_DESPESA,
				D2_SEGURO,
				D2_VALFRE,
				D2_ALQIMP5,
				D2_ALQIMP6,
				D2_VALBRUT,
				D2_DTDIGIT,
				D2_DESCZFP,
				D2_DESCZFC,
				F4_CSTCOF, 
				F4_CSTPIS

			FROM %TABLE:SD2% D2 (NOLOCK)
				INNER JOIN %TABLE:SB1% B1 (NOLOCK) ON B1_FILIAL = %xfilial:SB1% AND B1_COD = D2_COD AND B1.%notDel% 
				LEFT  JOIN %TABLE:SA1% A1 (NOLOCK) ON D2_TIPO <> 'D' AND A1_FILIAL = %xfilial:SA1% AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1.%notDel%
				LEFT  JOIN %TABLE:SA2% A2 (NOLOCK) ON D2_TIPO = 'D' AND A2_FILIAL = %xfilial:SA2% AND A2_COD = D2_CLIENTE AND A2_LOJA = D2_LOJA AND A2.%notDel%
				INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4.%notDel%

			WHERE D2_EMISSAO BETWEEN %Exp:DTOS(dPerIni)% AND %Exp:DTOS(dPerFim)%
					AND %Exp:cExpNF%
					AND D2.%notDel% 
			ORDER BY D2_FILIAL,D2_DOC, D2_EMISSAO	

		EndSql

	ElseIf cABA == "RES_DEV"    // Resumo Devoluções

		If cTipoNF = "1"  // Somente NF PIS Cofins
			cExpNF := "% (D2_VALIMP5 > 0 OR D2_VALIMP6 > 0) %"	
		Endif	

		BeginSql Alias Qry   

			%NOPARSER%

			SELECT						
				TIPO, 
				CST,
				CFOP,					
				VLR_CONTABIL, 
				BASE_PIS,
				BASE_COF,				
				VAL_PIS,
				VAL_COF

			FROM (
					SELECT     // Por CFOP
						TIPO = '0',
						CST  = F4_CSTPIS,   
						CFOP = '',					
						VLR_CONTABIL = SUM((D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_DESPESA + D2_SEGURO + D2_VALFRE) - D2_DESC),
						BASE_PIS = SUM(D2_BASIMP6),
						BASE_COF = SUM(D2_BASIMP5),				
						VAL_PIS = SUM(D2_VALIMP6),
						VAL_COF = SUM(D2_VALIMP5)

					FROM %TABLE:SD2% D2 (NOLOCK)
						INNER JOIN %TABLE:SB1% B1 (NOLOCK) ON B1_FILIAL = %xfilial:SB1% AND B1_COD = D2_COD AND B1.%notDel% 
						INNER JOIN %TABLE:SA1% A1 (NOLOCK) ON A1_FILIAL = %xfilial:SA1% AND A1_COD = D2_CLIENTE /*AND A1_LOJA = D2_LOJA*/ AND A1.%notDel% //AJUSTADO PROJETO PIS/COFINS
						INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4.%notDel%

					WHERE D2_EMISSAO BETWEEN %Exp:DTOS(dPerIni)% AND %Exp:DTOS(dPerFim)%
							AND D2_TIPO IN ('D') 
							AND D2_NFORI <> ''
							AND %Exp:cExpNF%
							AND D2.%notDel% 
					GROUP BY F4_CSTPIS

			UNION ALL

					SELECT     // Por CFOP + CST
						TIPO = '1',
						CST  = F4_CSTPIS,
						CFOP = D2_CF,						
						VLR_CONTABIL = SUM((D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_DESPESA + D2_SEGURO + D2_VALFRE) - D2_DESC),
						BASE_PIS = SUM(D2_BASIMP6),
						BASE_COF = SUM(D2_BASIMP5),				
						VAL_PIS = SUM(D2_VALIMP6),
						VAL_COF = SUM(D2_VALIMP5)

					FROM %TABLE:SD2% D2 (NOLOCK)
						INNER JOIN %TABLE:SB1% B1 (NOLOCK) ON B1_FILIAL = %xfilial:SB1% AND B1_COD = D2_COD AND B1.%notDel% 
						INNER JOIN %TABLE:SA1% A1 (NOLOCK) ON A1_FILIAL = %xfilial:SA1% AND A1_COD = D2_CLIENTE /*AND A1_LOJA = D2_LOJA*/ AND A1.%notDel% //AJUSTADO PROJETO PIS/COFINS
						INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4.%notDel%

					WHERE D2_EMISSAO BETWEEN %Exp:DTOS(dPerIni)% AND %Exp:DTOS(dPerFim)%
							AND D2_TIPO IN ('D') 
							AND D2_NFORI <> ''
							AND %Exp:cExpNF%
							AND D2.%notDel% 
					GROUP BY F4_CSTPIS, D2_CF

			) AS RES_DEV								
			ORDER BY CST, TIPO, CFOP
	
		EndSql 

	Elseif cABA == "DEV"
		
		If cTipoNF = "1"  // Somente NF PIS Cofins
			cExpNF := "% (D2_VALIMP5 > 0 OR D2_VALIMP6 > 0) %"	
		Endif

		BeginSql Alias Qry   

			%NOPARSER%

			SELECT 
				D2_FILIAL,
				D2_COD,
				B1_DESC,
				VLR_CONTABIL = (D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_DESPESA + D2_SEGURO + D2_VALFRE) - D2_DESC,
				D2_TOTAL,
				D2_VALIPI,
				D2_VALICM,
				D2_TES,
				D2_CF,
				D2_IPI,
				D2_DESC,
				D2_CONTA,
				A1_NOME,
				D2_CLIENTE,				
				D2_LOJA,
				D2_DOC,
				D2_SERIE,
				D2_EMISSAO,
				D2_NFORI,
				D2_SERIORI,
				D2_ICMSRET,
				D2_BASIMP5,
				D2_BASIMP6,
				D2_VALIMP5,
				D2_VALIMP6,
				D2_DESPESA,
				D2_SEGURO,
				D2_VALFRE,
				F4_CSTCOF, 
				F4_CSTPIS


			FROM %TABLE:SD2% D2 (NOLOCK)
				INNER JOIN %TABLE:SB1% B1 (NOLOCK) ON B1_FILIAL = %xfilial:SB1% AND B1_COD = D2_COD AND B1.%notDel% 
				//INNER JOIN %TABLE:SA1% A1 (NOLOCK) ON A1_FILIAL = %xfilial:SA1% AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1.%notDel%
				INNER JOIN %TABLE:SA1% A1 (NOLOCK) ON A1_FILIAL = %xfilial:SA1% AND A1_COD = D2_CLIENTE AND A1.%notDel%
				INNER JOIN %TABLE:SF4% F4 (NOLOCK) ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4.%notDel%

			WHERE D2_EMISSAO BETWEEN %Exp:DTOS(dPerIni)% AND %Exp:DTOS(dPerFim)%
					AND D2_TIPO IN ('D') 
					AND D2_NFORI <> ''
					AND %Exp:cExpNF%
					AND D2.%notDel% 
					AND F4_CSTCOF <> '99'
					AND F4_CSTPIS <> '99'
					AND D2_VALIMP5 <> 0
					AND D2_VALIMP6 <> 0
			ORDER BY D2_FILIAL,D2_DOC, D2_EMISSAO	

		EndSql 

	Endif

Return
