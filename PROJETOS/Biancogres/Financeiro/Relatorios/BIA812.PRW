#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BIA812()

	Local cLoad				:= "BIA812" + cEmpAnt
	Local cFileName			:= RetCodUsr() +"_"+ cLoad
	
	Private cCodMarca	:= ""	
	Private oReport		:= 	Nil
    
   
	MV_PAR01 := STOD("") 	
	MV_PAR02 := STOD("")    
	MV_PAR03 := SPACE(1)
	MV_PAR04 := SPACE(1)	
	
	aMarca		:= {'1=Biancogres', '2=Incesa', '3=Bellacasa', '4=Incesa/Bellacasa', '5=Pegasus','6=Vinilico', '7=Mundi', '8=Mundialli', '9=Todas'}
	aPergs		:= {}
	

	aAdd( aPergs ,{1,"Emissao De"		, MV_PAR01	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Emissao Ate"		, MV_PAR02	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Marca"			, MV_PAR03, aMarca, 50, ".T.",.F.})
	aAdd( aPergs ,{2,"Tipo"				, MV_PAR04, {'1=Analitico', '2=Sintetico'}, 50, ".T.",.F.})
	
	
	If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
		Return()
	EndIf
			
	MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
	MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
	MV_PAR03 := Val(ParamLoad(cFileName,,3,MV_PAR03))	
	MV_PAR04 := Val(ParamLoad(cFileName,,4,MV_PAR04))		
	
	Do Case
		Case MV_PAR03 == 1 	//BIANCOGRES
			cCodMarca	:= "'0101'"
		Case MV_PAR03 == 2 	//INCESA
			cCodMarca	:= "'0501'"
		Case MV_PAR03 == 3 	//BELLACASA
			cCodMarca	:= "'0599'"
		Case MV_PAR03 == 4	//INCESA/BELLACASA
			cCodMarca	:= "'0501','0599'"
		Case MV_PAR03 == 5	//Pegasus
			cCodMarca	:= "'0199'"
		Case MV_PAR03 == 6	//VINILICO
			cCodMarca	:= "'1302'"
		Case MV_PAR03 == 7	//Mundi
			cCodMarca	:= "'1301'"	
		Case MV_PAR03 == 8	//Mundialli
			cCodMarca	:= "'1399'"	
		Case MV_PAR03 == 9	//TODAS
			cCodMarca	:= "'0101', '0501', '0599', '0199', '1301', '1302', '1399'"
	EndCase
    
    oReport:= ReportDef()
	oReport:PrintDialog()

Return


Static Function ReportDef()
	
	Local cTitulo 	:= "Prazo Médio Ponderado"
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	
	oReport:= TReport():New(cTitulo, "Prazo Médio Ponderado - de "+ dToc(MV_PAR01)+ " até "+ dToc(MV_PAR02), , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de prazo médio ponderado")	
	    
	oSection1 := TRSection():New(oReport, "Prazo Médio Ponderado", )
	
	TRCell():New(oSection1,"NOMECLI"	, 		, "Cod./Loja/Cliente"	,"@"				, 130,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"PRENUMPAR"	, 		, "Prf/Num/Parc"		,"@"				, 30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"EMISSAO"	, 		, "Emissão"				,"@"				, 25,/*lPixel*/,/*{|| code-block de impressao }*/)	
	TRCell():New(oSection1,"VENCTO"		, 	 	, "Vencimento"			,"@"				, 25,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"VALOR"		,  		, "Valor"				,"@"				, 26,,,"RIGHT",,"RIGHT")	
	TRCell():New(oSection1,"PRAZO"		, 		, "Prazo"				,"@"				, 26,,,"RIGHT",,"RIGHT")
	TRCell():New(oSection1,"TOTAL"		, 		, "Valor x Prazo"		,"@"				, 30,,,"RIGHT",,"RIGHT")	
	
	oSection2 := TRSection():New(oReport, "Mensagem", )
	oSection2:SetHeaderSection(.F.)
	TRCell():New(oSection2, "MENSAGEM"	, 		, "Mensagem"				,"@"				, 130,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	
Return(oReport)


Static Function PrintReport(oReport)
	
	Local cAliasTemp 	:= GetNextAlias()
	Local cQuery		:= ""
	Local Enter 		:= CHR(13)+CHR(10)
		
	cQuery += " SELECT E1_CLIENTE, E1_LOJA, A1_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_VALOR, 				" + Enter
	cQuery += "		ISNULL((SELECT dbo.FN_PRAZOMEDIO_VENCATU_V2(E1_YEMPORI,E1_FILIAL, E1_PREFIXO,E1_NUM,E1_PARCELA,E1_YEMP,E1_CLIENTE,E1_LOJA)),0) PRAZO 	" + Enter
	cQuery += " FROM	VW_SE1 SE1																									" + Enter
	cQuery += " JOIN	SA1010 SA1 ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ''				" + Enter
	cQuery += " WHERE		SE1.E1_YEMP			IN ("+cCodMarca+")			AND														" + Enter
	cQuery += "				SE1.E1_NATUREZ	<> '1230'			AND -- NAO CONSIDERA TITULOS ST										" + Enter
	cQuery += "				SE1.E1_TIPO			=  'NF'			AND																	" + Enter
	cQuery += "				SE1.E1_EMISSAO	>= '"+DTOS(MV_PAR01)+"'	 	AND															" + Enter
	cQuery += "				SE1.E1_EMISSAO	<= '"+DTOS(MV_PAR02)+"' 	AND															" + Enter      
	cQuery += "				SE1.E1_YTPPD    =  'PA'	              																	" + Enter   
	cQuery += "				ORDER BY E1_NOMCLI		              																	" + Enter   					
						
	TcQuery cQuery New Alias (cAliasTemp)
	
	If (MV_PAR04 == 1)
		PrintAnalitico(oReport, cAliasTemp)
	Else
		PrintSintentico(oReport, cAliasTemp)
	EndIf
	
	(cAliasTemp)->(DbCloseArea())
Return


Static Function PrintAnalitico(oReport, cAliasTemp)

	Local oSec1 		:= oReport:Section(1)
	Local oSec2 		:= oReport:Section(2)
	Local cCliente		:= ""
	Local nSomaValor	:= 0
	Local nSomaTotal	:= 0
	Local nAcumValor	:= 0
	Local nAcumTotal	:= 0
	Local nTotal		:= 0
	
	oSec1:Init()
	
	While !oReport:Cancel() .And. (!(cAliasTemp)->(Eof()))
		
		//oSec1:Cell("NOMECLI"	):lBold := .T.
		oSec1:Cell("NOMECLI"	):SetValue((cAliasTemp)->E1_CLIENTE+' - '+(cAliasTemp)->E1_LOJA+' - '+(cAliasTemp)->A1_NOME) 		
		
		oSec1:Cell("PRENUMPAR"	):SetValue(SPACE(10)) 		
		oSec1:Cell("EMISSAO"	):SetValue(SPACE(10))	
		oSec1:Cell("VENCTO"		):SetValue(SPACE(10)) 	
		oSec1:Cell("VALOR"		):SetValue(SPACE(10)) 		
		oSec1:Cell("PRAZO"		):SetValue(SPACE(10)) 		
		oSec1:Cell("TOTAL"		):SetValue(SPACE(10)) 
		
		
		oSec1:PrintLine()
		oReport:SkipLine(1)		
		
		cCliente 	:= (cAliasTemp)->E1_CLIENTE
		nSomaValor	:= 0
		nSomaTotal	:= 0
		
		
		While (!oReport:Cancel() .And. !(cAliasTemp)->(Eof())) .And. AllTrim(cCliente) == AllTrim((cAliasTemp)->E1_CLIENTE)
				
			
			nTotal := ((cAliasTemp)->E1_VALOR * (cAliasTemp)->PRAZO)
			
			//oSec1:Cell("VALOR"	):lBold := .F.
			//oSec1:Cell("PRAZO"	):lBold := .F.
			//oSec1:Cell("TOTAL"	):lBold := .F.
				
			oSec1:Cell("NOMECLI"	):SetValue(SPACE(30)) 		
			oSec1:Cell("PRENUMPAR"	):SetValue((cAliasTemp)->E1_PREFIXO+' '+E1_NUM+' '+E1_PARCELA) 		
			oSec1:Cell("EMISSAO"	):SetValue(dToc(stod((cAliasTemp)->E1_EMISSAO)))	
			oSec1:Cell("VENCTO"		):SetValue(dToc(stod((cAliasTemp)->E1_VENCTO))) 	
			oSec1:Cell("VALOR"		):SetValue(Transform((cAliasTemp)->E1_VALOR, "@E 999,999,999.99")) 		
			oSec1:Cell("PRAZO"		):SetValue(cValTochar((cAliasTemp)->PRAZO)) 		
			oSec1:Cell("TOTAL"		):SetValue(Transform(nTotal, "@E 999,999,999.99")) 
			
			
			
			nSomaValor += (cAliasTemp)->E1_VALOR
			nSomaTotal += nTotal
			
			oSec1:PrintLine()
			(cAliasTemp)->(DbSkip())
		EndDo
		
		
		
		//oSec1:Cell("VALOR"	):lBold := .T.
		//oSec1:Cell("PRAZO"	):lBold := .T.
		//oSec1:Cell("TOTAL"	):lBold := .T.
		oReport:SkipLine(1)	
		oSec1:Cell("NOMECLI"	):SetValue(SPACE(30)) 
		oSec1:Cell("PRENUMPAR"	):SetValue(SPACE(10)) 		
		oSec1:Cell("EMISSAO"	):SetValue(SPACE(10))	
		oSec1:Cell("VENCTO"		):SetValue(SPACE(10)) 	
		oSec1:Cell("VALOR"		):SetValue(Transform(nSomaValor, "@E 999,999,999.99")) 		
		oSec1:Cell("PRAZO"		):SetValue(cValTochar(Round(nSomaTotal/nSomaValor, 0))) 		
		oSec1:Cell("TOTAL"		):SetValue(Transform(nSomaTotal, "@E 999,999,999.99")) 
		oSec1:PrintLine()
		
		oReport:ThinLine()
		
		oReport:SkipLine(1)	
		
		
		
		nAcumValor	+= nSomaValor
		nAcumTotal	+= nSomaTotal
		
	EndDo
	
	oReport:ThinLine()
	oReport:SkipLine(1)	
	
	oSec1:Cell("VALOR"	):lBold := .T.
	oSec1:Cell("PRAZO"	):lBold := .T.
	oSec1:Cell("TOTAL"	):lBold := .T.
		
	oSec1:Cell("NOMECLI"	):SetValue("Total") 
	oSec1:Cell("PRENUMPAR"	):SetValue(SPACE(10)) 		
	oSec1:Cell("EMISSAO"	):SetValue(SPACE(10))	
	oSec1:Cell("VENCTO"		):SetValue(SPACE(10)) 	
	oSec1:Cell("VALOR"		):SetValue(Transform(nAcumValor, "@E 999,999,999.99")) 		
	oSec1:Cell("PRAZO"		):SetValue(cValTochar(Round(nAcumTotal/nAcumValor, 0))) 		
	oSec1:Cell("TOTAL"		):SetValue(Transform(nAcumTotal, "@E 999,999,999.99")) 
	oSec1:PrintLine()

	oSec1:Cell("VALOR"	):lBold := .F.
	oSec1:Cell("PRAZO"	):lBold := .F.
	oSec1:Cell("TOTAL"	):lBold := .F.
	
	oSec1:Finish()
	
	oReport:SkipLine(1)	
	oSec2:Init()
	oSec2:Cell("MENSAGEM"	):SetValue("Não considera títulos de Substituição Tributária (Natureza = 1230)") 
	oSec2:PrintLine()
	oSec2:Cell("MENSAGEM"	):SetValue("Também desconsidera vendas dos formatos AB, AC, AD, AE e AF (peças)") 
	oSec2:PrintLine()
	oSec2:Finish()
	
	
Return


Static Function PrintSintentico(oReport, cAliasTemp)

	Local oSec1 		:= oReport:Section(1)
	Local oSec2 		:= oReport:Section(2)
	Local cCliente		:= ""
	Local nSomaValor	:= 0
	Local nSomaTotal	:= 0
	Local nAcumValor	:= 0
	Local nAcumTotal	:= 0
	Local nTotal		:= 0
	
	oSec1:Init()
	
	While !oReport:Cancel() .And. (!(cAliasTemp)->(Eof()))
		
		cCliente 	:= (cAliasTemp)->E1_CLIENTE
		nSomaValor	:= 0
		nSomaTotal	:= 0
		
		While (!oReport:Cancel() .And. !(cAliasTemp)->(Eof())) .And. AllTrim(cCliente) == AllTrim((cAliasTemp)->E1_CLIENTE)
			
			nTotal 		:= ((cAliasTemp)->E1_VALOR * (cAliasTemp)->PRAZO)
			nSomaValor	+= (cAliasTemp)->E1_VALOR
			nSomaTotal	+= nTotal
			
			(cAliasTemp)->(DbSkip())
		EndDo
		
		oSec1:Cell("NOMECLI"	):SetValue((cAliasTemp)->E1_CLIENTE+' - '+(cAliasTemp)->E1_LOJA+' - '+(cAliasTemp)->A1_NOME) 		
		oSec1:Cell("PRENUMPAR"	):SetValue(SPACE(10)) 		
		oSec1:Cell("EMISSAO"	):SetValue(SPACE(10))	
		oSec1:Cell("VENCTO"		):SetValue(SPACE(10)) 	
		oSec1:Cell("VALOR"		):SetValue(Transform(nSomaValor, "@E 999,999,999.99")) 		
		oSec1:Cell("PRAZO"		):SetValue(cValTochar(Round(nSomaTotal/nSomaValor, 0))) 		
		oSec1:Cell("TOTAL"		):SetValue(Transform(nSomaTotal, "@E 999,999,999.99")) 
		oSec1:PrintLine()
		
		nAcumValor	+= nSomaValor
		nAcumTotal	+= nSomaTotal
		
	EndDo
	
	oReport:ThinLine()
	oReport:SkipLine(1)	
	
	oSec1:Cell("VALOR"	):lBold := .T.
	oSec1:Cell("PRAZO"	):lBold := .T.
	oSec1:Cell("TOTAL"	):lBold := .T.
		
	oSec1:Cell("NOMECLI"	):SetValue("Total") 
	oSec1:Cell("PRENUMPAR"	):SetValue(SPACE(10)) 		
	oSec1:Cell("EMISSAO"	):SetValue(SPACE(10))	
	oSec1:Cell("VENCTO"		):SetValue(SPACE(10)) 	
	oSec1:Cell("VALOR"		):SetValue(Transform(nAcumValor, "@E 999,999,999.99")) 		
	oSec1:Cell("PRAZO"		):SetValue(cValTochar(Round(nAcumTotal/nAcumValor, 0))) 		
	oSec1:Cell("TOTAL"		):SetValue(Transform(nAcumTotal, "@E 999,999,999.99")) 
	oSec1:PrintLine()

	oSec1:Cell("VALOR"	):lBold := .F.
	oSec1:Cell("PRAZO"	):lBold := .F.
	oSec1:Cell("TOTAL"	):lBold := .F.
	
	oSec1:Finish()	
	
	oReport:SkipLine(1)	
	oSec2:Init()
	oSec2:Cell("MENSAGEM"	):SetValue("Não considera títulos de Substituição Tributária (Natureza = 1230)") 
	oSec2:PrintLine()
	oSec2:Cell("MENSAGEM"	):SetValue("Também desconsidera vendas dos formatos AB, AC, AD, AE e AF (peças)") 
	oSec2:PrintLine()
	oSec2:Finish()
	
Return

