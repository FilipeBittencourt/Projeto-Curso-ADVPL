#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BIAFPH06()
	
	Local aPergs		:= {}
	Local cRefPer	  	:= 'BIAFPH06' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer
	
	
	Private oReport		:= 	Nil
    
    Private aRetPerg   := {ctod(" "), ctod(" "), "", "" , "", ""}
    
    Private dDataDe		:= STOD('')
	Private dDataAte	:= STOD('')
	Private cTagDe		:= Space(TamSX3("ZLI_TAG")[1])
    Private cTagAte		:= REPLICATE("Z", TamSX3("ZLI_TAG")[1])
    Private cMatDe		:= Space(TamSX3("ZLI_MATRIC")[1])
    Private cMatAte		:= REPLICATE("Z", TamSX3("ZLI_MATRIC")[1])
    
    
    aAdd( aPergs ,{1,"Dt. Coleta de: " 				, dDataDe	,"","NAOVAZIO()",'','.T.',50,.T.})
    aAdd( aPergs ,{1,"Dt. Coleta até: " 			, dDataAte	,"","NAOVAZIO()",'','.T.',50,.T.})
    aAdd( aPergs ,{1,"Matricula de: "	   			, cMatDe  	,"", ,"ZZY",'.T.',50,.F.})
    aAdd( aPergs ,{1,"Matricula até: "	   			, cMatAte	,"", ,"ZZY",'.T.',50,.F.})
    aAdd( aPergs ,{1,"Tag de: " 					, cTagDe  	,"",,'SZC','.T.',50,.F.})
    aAdd( aPergs ,{1,"Tag até: "	 				, cTagAte	,"",,'SZC','.T.',50,.F.})
    
    If !ParamBox(aPergs ,"Filtro",aRetPerg,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf
	
	dDataDe			:= ParamLoad(cFileName,,1 	, dDataDe)
	dDataAte   		:= ParamLoad(cFileName,,2 	, dDataAte)
	cMatDe			:= ParamLoad(cFileName,,3	, cMatDe)
	cMatAte			:= ParamLoad(cFileName,,4	, cMatAte)
    cTagDe   		:= ParamLoad(cFileName,,5	, cTagDe)
	cTagAte			:= ParamLoad(cFileName,,6	, cTagAte)
	
    oReport:= ReportDef()
	oReport:PrintDialog()

Return


Static Function ReportDef()
	
	Local cTitulo 	:= "Controle Horimetro dos Veiculos"
	Local oSection1	:= Nil
	
	oReport:= TReport():New(cTitulo, "Controle Horimetro dos Veiculos - de "+ dToc(dDataDe)+ " até "+ dToc(dDataAte), , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de horimetro dos veiculos")	
	// Altera tipo de impressao para paisagem
	//oReport:SetLandScape(.T.)
	    
	oSection1 := TRSection():New(oReport, "Controle Horimetro dos Veiculos", )
	
	TRCell():New(oSection1,"ZLI_DATA"	, 	 	, "Data Dig."			,"@"				, TamSX3("ZLI_DATA")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"ZLI_DTCOL"	, 		, "Data Coleta"			,"@"				, TamSX3("ZLI_DTCOL")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)	
	TRCell():New(oSection1,"ZLI_TAG"	, 		, "Tag."				,"@"				, TamSX3("ZLI_TAG")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"ZLI_CONTAD"	,  		, "Contador"			,"@"				, TamSX3("ZLI_CONTAD")[1]+10,,,"CENTER",,"CENTER")	
	TRCell():New(oSection1,"CONT_DIFF"	,  		, "C. Atu. – C. Ant."	,"@"				, TamSX3("ZLI_CONTAD")[1]+20,,,"CENTER",,"CENTER")	
	TRCell():New(oSection1,"ZLI_UNIDAD"	, 		, "Unidade"				,"@"				, TamSX3("ZLI_UNIDAD")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"ZLI_MATRIC"	, 		, "Matricula"			,"@"				, TamSX3("ZLI_MATRIC")[1]+50,/*lPixel*/,/*{|| code-block de impressao }*/)
	
Return(oReport)


Static Function PrintReport(oReport)
	Local oSec1 		:= oReport:Section(1)
	Local cAliasTemp 	:= GetNextAlias()
	Local cQuery		:= ""
	Local nUltCont		:= 0
	Local cTag			:= ""
	
	cQuery := " select * from "+RetSqlName('ZLI')+" ZLI														"
	cQuery += " where ZLI.D_E_L_E_T_ = ''																	"
	cQuery += " AND ZLI_DTCOL BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"'							"
	cQuery += " AND ZLI_TAG BETWEEN '"+cTagDe+"' AND '"+cTagAte+"'											"
	cQuery += " AND ZLI_MATRIC BETWEEN '"+cMatDe+"' AND '"+cMatAte+"'										"
	cQuery += " ORDER BY ZLI_TAG, ZLI_DTCOL																	"
	
	TcQuery cQuery New Alias (cAliasTemp)
	
	oSec1:Init()
	
	While !oReport:Cancel() .And. (!(cAliasTemp)->(Eof()))
		
		
		If (Empty(cTag) .Or. cTag <> (cAliasTemp)->ZLI_TAG)
			
			If (!Empty(cTag))
				oReport:ThinLine()	
				oReport:SkipLine(1)		
			EndIf
		
			cTag := (cAliasTemp)->ZLI_TAG
			nUltCont := GetUltCont(cTag)
		
			
		EndIf
		
		oSec1:Cell("ZLI_DATA"		):SetValue(dToc(stod((cAliasTemp)->ZLI_DATA))		) 		
		oSec1:Cell("ZLI_DTCOL"		):SetValue(dToc(stod((cAliasTemp)->ZLI_DTCOL))			) 		
		oSec1:Cell("ZLI_TAG"		):SetValue((cAliasTemp)->ZLI_TAG				)	
		oSec1:Cell("ZLI_CONTAD"		):SetValue(Transform((cAliasTemp)->ZLI_CONTAD, "@E 999,999,999.99")				) 	
		oSec1:Cell("CONT_DIFF"		):SetValue(Transform((cAliasTemp)->ZLI_CONTAD - nUltCont, "@E 999,999,999.99")				) 		
		oSec1:Cell("ZLI_UNIDAD"		):SetValue((cAliasTemp)->ZLI_UNIDAD				) 		
		oSec1:Cell("ZLI_MATRIC"		):SetValue((cAliasTemp)->ZLI_MATRIC				) 
		
		nUltCont := (cAliasTemp)->ZLI_CONTAD
		
		oSec1:PrintLine()
		
		oReport:SkipLine(1)		
		
		(cAliasTemp)->(DbSkip())
	EndDo
	
	oSec1:Finish()
		
	(cAliasTemp)->(DbCloseArea())
Return

Static Function GetUltCont(cTag)
	
	Local cAliasTemp 	:= GetNextAlias()
	Local cQuery		:= ""
	Local nUltCont		:= 0
	
	cQuery := " select TOP 1 ZLI_CONTAD  from "+RetSqlName('ZLI')+" ZLI										"
	cQuery += " where ZLI.D_E_L_E_T_ = ''																	"
	cQuery += " AND ZLI_DTCOL < '"+DTOS(dDataDe)+"' 														"
	cQuery += " AND ZLI_TAG = '"+cTag+"' 																	"
	cQuery += " AND ZLI_MATRIC BETWEEN '"+cMatDe+"' AND '"+cMatAte+"'										"
	cQuery += " ORDER BY ZLI_DTCOL	DESC																	"
	
	TcQuery cQuery New Alias (cAliasTemp)
		
	If (!(cAliasTemp)->(Eof()))
		nUltCont := (cAliasTemp)->ZLI_CONTAD
	EndIf
	
	(cAliasTemp)->(DbCloseArea())

Return nUltCont