#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#define CRLF Chr(13) + Chr(10) 


Static Function SFP002()

	Private aRotina := {}
	Private aRotSub := {}

	/*aRotina   := {;
		{ "Pesquisar"							, "PesqBrw"												,0,1,0,nil},;
		{ "Gerar Entrada"				, "U_PTX0007()"											,0,2,0,nil},;
		{ "Cad. Fornecedor"			, "U_PTX0022()"											,0,3,0,nil},;
		{ "Classificar NF-e"		,	"U_PTX0008"												,0,2,0,nil},;
		{ "Reprocessar Sefaz"		,	"U_PTX0045"												,0,2,0,nil},;
		{ "NFe - Imprimir DANFE", "U_PTX0013"												,0,2,0,nil},;
		{ "NFe - Buscar Sefaz"	,	"U_SincSefaz()"										,0,2,0,nil},;
		{ "NFe - Chave Avulsa"	, "U_PTX0028"												,0,2,0,nil},;
		{ "NFe - Manifestar"		,	"U_PTX0002(.T.)"									,0,2,0,nil},;
		{ "NFe - Monitorar"			, "U_PTX0003"												,0,2,0,nil},;
		{ "NFe - Manifest. em Lote", "U_PTX0039"										,0,2,0,nil},;
		{ "NFe - Devolução Venda", "U_PTX0044"											,0,2,0,nil},;
		{ "CTe - Buscar Sefaz"	,	"StaticCall(PTX0001, fBuscaCTE)"	,0,2,0,nil},;
		{ "CTe - Consultar Status", "StaticCall(PTX0001, fUpdCTE)"	,0,2,0,nil},;
		{ "CTe - Manif. Desacordo", "U_PTX0041"											,0,2,0,nil},;
		{ "CTe - Monitorar"			, "U_fMonitDesac"										,0,2,0,nil},;
		{ "CTe - Imprimir DACTE", "U_PTXR004"												,0,2,0,nil},;
		{ "Buscar Xml E-mail"		, "U_PTX0021(.F.)"									,0,2,0,nil},;
		{ "Exportar XML"				,	"U_PTX0004"												,0,2,0,nil},;
		{ "CheckDoc"						,	"U_PTX0032"												,0,2,0,nil},;
		{ "Visualizar Registro"	,"AxVisual"													,0,2,0,nil},;
		{ "Wiz.Config."					, "U_PTX0016"												,0,4,0,nil},;
		{ "Entrada em Lote"			, "U_PTX0035"												,0,2,0,nil},;
		{ "Legenda"							, "U_SFLegenda"											,0,4,0,nil}}*/


  
		Aadd(aRotina,{ "Pesquisar"            , "PesqBrw"											     ,0,1,0,nil})
		Aadd(aRotina,{ "Gerar Entrada"				, "U_PTX0007()"									     ,0,2,0,nil})
		Aadd(aRotina,{ "Cad. Fornecedor"			, "U_PTX0022()"									     ,0,3,0,nil})		
		Aadd(aRotina,{ "Reprocessar Sefaz"		,	"U_PTX0045"										     ,0,2,0,nil})
	
	  
		aRotSub := {}//BLOCO MENU NF-e
		Aadd(aRotSub,{ "Classificar NF-e"		  , "U_PTX0008"      									 ,0,2,0,nil})
		Aadd(aRotSub,{"Imprimir DANFE"        , "U_PTX0013"							           ,0,2,0,nil})
		Aadd(aRotSub,{ "Buscar Sefaz"	        , "U_SincSefaz()"							       ,0,2,0,nil})
		Aadd(aRotSub,{ "Chave Avulsa"	        , "U_PTX0028"									       ,0,2,0,nil})
		Aadd(aRotSub,{ "Manifestar"		        , "U_PTX0002(.T.)"					         ,0,2,0,nil})
		Aadd(aRotSub,{ "Monitorar"			      , "U_PTX0003"									       ,0,2,0,nil})
		Aadd(aRotSub,{ "Manifest. em Lote"    , "U_PTX0039"									       ,0,2,0,nil})
		Aadd(aRotSub,{ "Devolução Venda"      , "U_PTX0044"									       ,0,2,0,nil})		
		Aadd(aRotina,{ "NFe"                  ,  aRotSub             				       ,0,2,0,nil})
	
	 
		aRotSub := {}//BLOCO MENU CT-e
		Aadd(aRotSub,{ "Buscar Sefaz"	        , "StaticCall(PTX0001, fBuscaCTE)"   ,0,2,0,nil})
		Aadd(aRotSub,{ "Consultar Status"     , "StaticCall(PTX0001, fUpdCTE)"	   ,0,2,0,nil})
		Aadd(aRotSub,{ "Manif. Desacordo"     , "U_PTX0041"											   ,0,2,0,nil})
		Aadd(aRotSub,{ "Monitorar"			      , "U_fMonitDesac"										 ,0,2,0,nil})
		Aadd(aRotSub,{ "Imprimir DACTE"       , "U_PTXR004"												 ,0,2,0,nil})
		Aadd(aRotina,{ "CTe"		              , aRotSub	                         	 ,0,2,0,nil})

		Aadd(aRotina,{ "Buscar Xml E-mail"		, "U_PTX0021(.F.)"									 ,0,2,0,nil})
		Aadd(aRotina,{ "Exportar XML"				  ,	"U_PTX0004"											   ,0,2,0,nil})
		Aadd(aRotina,{ "CheckDoc"						  ,	"U_PTX0032"												 ,0,2,0,nil})
		Aadd(aRotina,{ "Visualizar Registro"	, "AxVisual"												 ,0,2,0,nil})
		Aadd(aRotina,{ "Wiz.Config."					, "U_PTX0016"												 ,0,4,0,nil})
		Aadd(aRotina,{ "Entrada em Lote"			, "U_PTX0035"												 ,0,2,0,nil})
		Aadd(aRotina,{ "Legenda"							, "U_SFLegenda"											 ,0,4,0,nil})
		
	aButtonUsr := {}
	If ExistBlock("PTX0001MNU",,.T.)
		aButtonUsr := ExecBlock("PTX0001MNU",.F.,.F.)
	EndIf

	If ValType(aButtonUsr) == "A"
		If Len(aButtonUsr) > 0
			aAdd(aRotina,aClone(aButtonUsr))
		EndIf
	EndIf

Return aRotina
