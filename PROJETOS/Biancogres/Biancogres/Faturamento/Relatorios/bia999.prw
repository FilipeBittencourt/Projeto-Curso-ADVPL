#INCLUDE "PROTHEUS.CH"  
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BIA999
@author Tiago Rossini Coradini
@since 16/11/2016
@version 2.1
@description Alteração para extrair informação pelo código do produto e não pela linha/cor.  
@obs OS: 4093-16 - Claudeir Fadini
@obs OS: 0222-17 - Raul Viana
@obs Ticket 801/3031 - Revisado por Fernando Rocha para usar a função CALC_SALDO_OP
@obs Ticket 23523 - Revisado por Thiago Haagensen. Criado function FNC_MEDIA_ENTRADA_PEDIDO_03_MESES e a view VW_DISPONIBILIDADE_PRODUTO_EMP_NEW substituindo as usadas no última revisão BIA999.
/*/

User Function BIA999()
	Local oReport
	Local cLoad				:= "BIA999" + cEmpAnt
	Local cFileName			:= RetCodUsr() +"_"+ cLoad
	
	Private cPergunta := "BIA999"
	Private lRepre := !EMPTY(CREPATU)
	
	
	If !Alltrim(cEmpAnt) $ "01_05"
		MsgAlert('Este relatório somente poderá ser emitido nas empresas Biancogres e Incesa')
		Return
	EndIf

	
	If !Empty(cRepAtu) .And. U_GETBIAPAR("REP_BLQRDISP",.F.)
		MsgInfo("Consulta temporariamente indisponível","BIA999")
		Return
	EndIf


	//Pergunte(cPergunta,.T.)
	
	aPergs := {}
	MV_PAR01 := SPACE(1)
	aMarca	:= {'1=Biancogres', '2=Incesa', '3=Bellacasa', '4=Incesa/Bellacasa', '5=Pegasus', '6=Vinilico', '7=Todas'}
	aAdd( aPergs ,{2,"Marca"				, MV_PAR01, aMarca, 50, ".T.",.F.})
	
	If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
		Return()
	EndIf
	
	MV_PAR01 := Val(ParamLoad(cFileName,,1,MV_PAR01))
	
	oReport:= ReportDef()
	oReport:PrintDialog()

Return


Static Function ReportDef()
	Local cQry := GetNextAlias()

	oReport:= TReport():New("Disponibilidade", "Disponibilidade de produtos",, {|oReport| PrintReport(oReport, cQry)}, "Disponibilidade de produtos")

	// Altera tipo de impressao para paisagem
	oReport:SetLandScape(.T.)

	oReport:SetTotalInLine(.F.)

	oSection1 := TRSection():New(oReport,"Produtos", {cQry})    
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"DESCR_FORMATO",, "Formato",,15)
	TRCell():New(oSection1,"B1_COD",,,,20)
	TRCell():New(oSection1,"B1_DESC",,,,50)
	TRCell():New(oSection1,"COB_DIA",, "Cob. Dia",,20)
	TRCell():New(oSection1,"DISP",, "Disp.",,20)
	TRCell():New(oSection1,"DATAOP",, "Dt 1ª OP"	,,20)	//Renomeado e alterado posição	                                                                                               
	TRCell():New(oSection1,"SALDOOP",, "Sld 1ª OP",,20)		//Renomeado e alterado posição
	TRCell():New(oSection1,"DATAOP_2",, "Dt OP Pen",,20)	                                                                                               
	TRCell():New(oSection1,"SALDOOP_2",, "Sld OP Pen",,20)
	TRCell():New(oSection1,"OBS",, "Observacao",,50)

	If !lRepre

		TRCell():New(oSection1,"QUANT",, "Quant.",,20)
		TRCell():New(oSection1,"EMPENHO",, "Empenho",,20)
		TRCell():New(oSection1,"SALDO",, "Saldo",,20)
		TRCell():New(oSection1,"MED_VEN",, "Med. Venda",,20)		

	EndIf

Return oReport


Static Function PrintReport(oReport, cQry)
	Local cEmpMar	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	Local cSQL		:= ""		
	Local cAliasOP	:= GetNextAlias()
	Local cQueryOP	:= ""

	Do Case
		Case MV_PAR01 == 1 	//BIANCOGRES
			cEmpMar	:= "0101"
		Case MV_PAR01 == 2 	//INCESA
			cEmpMar	:= "0501"
		Case MV_PAR01 == 3 	//BELLACASA
			cEmpMar	:= "0599"
		Case MV_PAR01 == 4	//INCESA/BELLACASA
			cEmpMar	:= "0501/0599"
		Case MV_PAR01 == 5	//PEGASUS
			cEmpMar	:= "0199"
		Case MV_PAR01 == 6	//VINILICO
			cEmpMar	:= "1302"	
		Case MV_PAR01 == 7	//TODAS
			cEmpMar	:= "0101/0501/0599/0599/0199/1302"		
	EndCase  
	
	cSQL := " SELECT D.*, '' AS OBS, '' AS DISP,  " + Enter
	cSQL += " ISNULL(ROUND(FNC.MEDIA, 2), 0) AS MED_VEN, " + Enter
	cSQL += " ISNULL(ROUND((D.SALDO / FNC.MEDIA) * 30, 2), 0) AS COB_DIA " + Enter
	cSQL += " FROM VW_DISPONIBILIDADE_PRODUTO_EMP_NEW D " + Enter                                                                                                                                       
	cSQL += " LEFT JOIN FNC_MEDIA_ENTRADA_PEDIDO_03_MESES("+ ValToSQL(cEmpMar) +") FNC ON FNC.PRODUTO = D.COD_PROD " + Enter		
	cSQL += " WHERE EMP IN " + FormatIn(cEmpMar, "/") + Enter
	cSQL += " ORDER BY D.COD_PROD, D.DESCR_FORMATO, D.DESC_PROD	" + Enter
	
	TcQuery cSQL New Alias (cQry)


	oReport:SetMeter(100)

	oSection1 := oReport:Section(1)
	
	While (cQry)->(!Eof()) .And. !oReport:Cancel()

		oReport:IncMeter()

		oSection1:Init()

		
		oSection1:Cell("DESCR_FORMATO"):SetValue((cQry)->DESCR_FORMATO)
		oSection1:Cell("DESCR_FORMATO"):SetAlign("LEFT")

		oSection1:Cell("B1_COD"):SetValue((cQry)->COD_PROD)
		oSection1:Cell("B1_COD"):SetAlign("LEFT")

		oSection1:Cell("B1_DESC"):SetValue((cQry)->DESC_PROD)
		oSection1:Cell("B1_DESC"):SetAlign("LEFT")		

		oSection1:Cell("COB_DIA"):SetValue(TRANSFORM((cQry)->COB_DIA,"@E 999,999,999.99"))
		oSection1:Cell("COB_DIA"):SetAlign("CENTER")			

		oSection1:Cell("DISP"):SetValue(fGetDisp((cQry)->MED_VEN, (cQry)->COB_DIA))
		oSection1:Cell("DISP"):SetAlign("CENTER")

		// Quando CONSULTA e NAO: apresentar maior data de OP disponível
		// Quando o saldo da OP for inferior a 300 informar a mensagem "SEM OP DISPONÍVEL"

		If AllTrim(fGetDisp((cQry)->MED_VEN, (cQry)->COB_DIA)) != 'SIM'

			oSection1:Cell("DATAOP"):SetValue(StoD((cQry)->DTDISPOP))

			If ((cQry)->SALDOOP+(cQry)->SALDOOP_2) >= 300

				oSection1:Cell("SALDOOP"):SetValue(TRANSFORM((cQry)->SALDOOP,"@E 999,999,999.99"))								

				If (cQry)->SALDOOP_2 > 0

					oSection1:Cell("DATAOP_2"):SetValue(StoD((cQry)->DTDISPOP_2))
					oSection1:Cell("SALDOOP_2"):SetValue(TRANSFORM((cQry)->SALDOOP_2,"@E 999,999,999.99"))

				Else

					oSection1:Cell("DATAOP_2"):SetValue('')
					oSection1:Cell("SALDOOP_2"):SetValue(Transform(0, "@E 999,999,999.99"))

				EndIf

				oSection1:Cell("OBS"):SetValue(AllTrim((cQry)->OBS))

			Else
				cObs := AllTrim((cQry)->OBS) 
				cQueryOP := "SELECT TOP 2 SALDO, DATADISP, SEQ FROM  [FNC_ROP_PESQUISA_OP_EMP]('01','','','','', '"+AllTrim((cQry)->COD_PROD)+"','',0,'S','','','') WHERE SALDO > 300" 
				 
				TcQuery cQueryOP New Alias (cAliasOP)
				If (cAliasOP)->(!Eof())
				
					oSection1:Cell("DATAOP"):SetValue(StoD((cAliasOP)->DATADISP))
					oSection1:Cell("SALDOOP"):SetValue(Transform((cAliasOP)->SALDO, "@E 999,999,999.99"))
					
					(cAliasOP)->(DbSkip())
					If (cAliasOP)->(!Eof())
						oSection1:Cell("DATAOP_2"):SetValue(StoD((cAliasOP)->DATADISP))
						oSection1:Cell("SALDOOP_2"):SetValue(Transform((cAliasOP)->SALDO, "@E 999,999,999.99"))
					Else
						oSection1:Cell("DATAOP_2"):SetValue('')
						oSection1:Cell("SALDOOP_2"):SetValue(Transform(0, "@E 999,999,999.99"))
					EndIf
					
				Else
					
					cObs := IIF(Empty(cObs),'SEM OP DISPONÍVEL', cObs + ' - SEM OP DISPONÍVEL'  )				

				
					oSection1:Cell("DATAOP"):SetValue('')
					oSection1:Cell("SALDOOP"):SetValue(Transform(0, "@E 999,999,999.99"))
					
					oSection1:Cell("DATAOP_2"):SetValue('')
					oSection1:Cell("SALDOOP_2"):SetValue(Transform(0, "@E 999,999,999.99"))
					
				EndIf
				
				oSection1:Cell("OBS"):SetValue(cObs)
				(cAliasOP)->(DbCloseArea())
			EndIf

		Else

			oSection1:Cell("DATAOP"):SetValue('')
			oSection1:Cell("SALDOOP"):SetValue(Transform(0, "@E 999,999,999.99"))
			oSection1:Cell("DATAOP_2"):SetValue('')
			oSection1:Cell("SALDOOP_2"):SetValue(Transform(0, "@E 999,999,999.99"))									
			oSection1:Cell("OBS"):SetValue(AllTrim((cQry)->OBS))

		EndIf

		
		oSection1:Cell("DATAOP"):SetAlign("CENTER")
		oSection1:Cell("SALDOOP"):SetAlign("CENTER")        
		oSection1:Cell("DATAOP_2"):SetAlign("CENTER")
		oSection1:Cell("SALDOOP_2"):SetAlign("CENTER")		
		oSection1:Cell("OBS"):SetAlign("LEFT")

		If !lRepre

			oSection1:Cell("QUANT"):SetValue(TRANSFORM((cQry)->QUANT,"@E 999,999,999.99"))
			oSection1:Cell("QUANT"):SetAlign("CENTER")			
			oSection1:Cell("EMPENHO"):SetValue(TRANSFORM((cQry)->EMPENHO,"@E 999,999,999.99"))
			oSection1:Cell("EMPENHO"):SetAlign("CENTER")
			oSection1:Cell("SALDO"):SetValue(TRANSFORM((cQry)->SALDO,"@E 999,999,999.99"))
			oSection1:Cell("SALDO"):SetAlign("CENTER")			
			oSection1:Cell("MED_VEN"):SetValue(TRANSFORM((cQry)->MED_VEN,"@E 999,999,999.99"))
			oSection1:Cell("MED_VEN"):SetAlign("CENTER")			

		EndIf
		
		oSection1:PrintLine()	

		(cQry)->(DbSkip())

	EndDo()

	oSection1:Finish()

	(cQry)->(DbCloseArea())

Return                                                                       


Static Function fGetDisp(nMedVen, nCobDia)
	Local cRet := "-"

	If nMedVen > 0

		If nCobDia >= 12

			cRet := "SIM"

		ElseIf nCobDia >= 1 .And. nCobDia <= 11.99 

			cRet := "CONSULTA"

		ElseIf nCobDia < 1

			cRet := "NÃO"

		EndIf

	Else

		cRet := "CONSULTA"

	EndIf

Return(cRet)