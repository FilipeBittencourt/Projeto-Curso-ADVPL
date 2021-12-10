#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"  


/*/{Protheus.doc} BFATRE03
//TODO Descrição auto-gerada.
@author Pedro Henrique
@since 20/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function BFATRE03

	Local lEnd			:= .F.
	Local aPergs		:= {}
	Local cRefPer	  	:= 'BFATRE03' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer

	Private oExcel
	Private cArqXML    	:= "RELATORIO_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	Private cTitulo		:= "Relatório"

	Private cEmpresa   	:= StrTran(AllTrim(CapitalAce(SM0->M0_NOMECOM)),"S.a.","S.A.") 

	Private cFonte1	 	:= 'Calibri'
	Private nTamFont1	:= 12   
	Private cCorFont1  	:= '#FFFFFF'
	Private cCorFun1	:= '#000066'

	Private cFonte2	 	:= 'Calibri' 
	Private nTamFont2	:= 12   
	Private cCorFont2  	:= '#FFFFFF'
	Private cCorFun2	:= '#3333FF'

	Private cFonte3	 	:= 'Calibri'
	Private nTamFont3	:= 8   
	Private cCorFont3  	:= '#000000'
	Private cCorFun3	:= '#FFFFFF'

	Private cWhite		:= '#FFFFFF'
	Private cLGray		:= '#9494E7'

	Private aColsAnt	:= {}
	Private aColsProx	:= {}

	//Privates para ParamBox
	Private aRetPerg   := {ctod(" "), ctod(" "), "", "", "", "", "", "", "", "", ""}
	
	Private cDataIni	:= STOD('')                                  
	Private cDataFim	:= STOD('')   
	Private cCliIni		:= Space(6)                                  
	Private cCliFim		:= Space(6)                                  
	Private cProdIni	:= Space(15)                                  
	Private cProdFim	:= Space(15)   
	Private cPedIni		:= Space(6)                                  
	Private cPedFim		:= Space(6)  
	Private cMarcaIni	:= Space(11)
	Private cMarcaFim	:= Space(11) 
	Private cDirDest	:= Space(200)
	
	
	Private aMarca		:= {Space(11), 'Biancogres','Incesa','Bellacasa','Mundi','Vinilico', 'ZZZZZZZZZZZ'}

	Private aCodMarca	:= {Space(4), '0101','0501','0599','1399','1302', 'ZZZZ'}                                      
		
	aAdd( aPergs ,{1,"Date de:"					, cDataIni  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Date até:"				, cDataFim  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cliente de:"				, cCliIni  ,"",,"SA1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cliente até:"				, cCliFim  ,"",,"SA1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto de:"				, cProdIni  ,"",,"SB1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produdo até:"				, cProdFim  ,"",,"SB1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Pedido de:"				, cPedIni  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Pedido até:"				, cPedFim  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Marca de:"				, cMarcaIni, aMarca, 100, ".T.",.F.})
	aAdd( aPergs ,{2,"Marca Ate:"				, cMarcaFim, aMarca, 100, ".T.",.F.})
	aAdd( aPergs ,{6,"Pasta Destino: " 			,cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )


	If !ParamBox(aPergs ,"", aRetPerg,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	cDataIni			:= DTOS(ParamLoad(cFileName,,1 	, cDataIni)) 
	cDataFim   			:= DTOS(ParamLoad(cFileName,,2 	, cDataFim)) 
	cCliIni   			:= ParamLoad(cFileName,,3	, cCliIni)
	cCliFim				:= ParamLoad(cFileName,,4	, cCliFim)
	cProdIni			:= ParamLoad(cFileName,,5	, cProdIni)
	cProdFim			:= ParamLoad(cFileName,,6	, cProdFim)
	cPedIni				:= ParamLoad(cFileName,,7	, cPedIni)
	cPedFim				:= ParamLoad(cFileName,,8	, cPedFim)
	cMarcaIni  			:= aCodMarca[aScan(aMarca, {|x| AllTrim(x) == AllTrim(ParamLoad(cFileName,,9 , Space(30))) })]
	cMarcaFim  			:= aCodMarca[aScan(aMarca, {|x| AllTrim(x) == AllTrim(ParamLoad(cFileName,,10 , Space(30))) })]
	cDirDest			:= ParamLoad(cFileName,, 11	, cDirDest)

	oProcess := MsNewProcess():New( {|lEnd| fImprime(@lEnd)},"Por favor aguarde, processando...","Carregando Informações",.T.)
	oProcess:Activate()

Return


Static Function fImprime(lEnd)

	oExcel := ARSexcel():New()

	if empty(cDirDest) .or. !ExistDir(cDirDest)	
		cDirDest := Alltrim(GetTempPath()) 
	endif

	MontaCabecalho()
	MontaLinhas()
	MontaAbaPar()

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

Return


Static Function MontaCabecalho()

	Local aColLen := {100, 100, 100, 200, 100, 200, 100, 50, 100, 200, 100, 100, 50, 100,100, 100, 100, 100, 50, 100, 100, 100, 100, 100}
	Local cDescTi := ""
	
	oExcel:AddPlanilha('Relatorio',aColLen)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,Len(aColLen)-1) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,1,Len(aColLen)-1) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,Len(aColLen)-1)  

	oExcel:AddLinha(30)
	oExcel:AddLinha(12) 

	oExcel:AddCelula("Empresa"					,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Marca"					,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Cod. Cliente"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Nome Cliente" 	 		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Cod. Vendedor"			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Nome Vendedor" 	 		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("NF"				   		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Item NF"   		   		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Cod. Produto"	   	   		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Desc. Produto"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Quant."		   	   		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Pedido"		   	    	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Item Ped."	   	    	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Emissão NF"		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Data Ped."		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Data Ent."		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Data Nece."		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Data Emp."		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Dentro Prazo"		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Formato"			   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Segmento"			   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Categoria"		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Forno"			   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Classe"			   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 

Return


Static Function MontaLinhas()

	Local cAliasTrab	:= GetNextAlias()
	Local cCorF 		:= cWhite
	Local cQuery		:= MontaQuery()
	
	TCQUERY cQuery NEW ALIAS cAliasTrab	
	
	While !(cAliasTrab->(Eof()))

		oExcel:AddLinha(12)
		
	
		oExcel:AddCelula(cAliasTrab->EMP											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(cAliasTrab->MARCA											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->CLIENTE										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->NOMECLIENTE									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->VENDEDOR										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->NOMEVENDEDOR									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->NF												,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->ITEMNF											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->PRODUTO										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->NOMEPRODUTO									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->QUANTNF										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->PEDIDO											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->ITEMPV											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
	
		oExcel:AddCelula(cAliasTrab->EMISSAONF										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->DTPEDIDO										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->DTENTREGA										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->DTNECESENG										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->DTEMPENHO										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
	
		oExcel:AddCelula(cAliasTrab->DENTROPRAZO									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->FORMATO										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->TPSEG											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->CATEGORIA										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->FORNO											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->CLASSE											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		

		cAliasTrab->(DbSkip())
	EndDo
	cAliasTrab->(DbCloseArea())

Return

Static Function MontaQuery()
	
	Local cQuery		:= ""
	Local Enter			:= CHR(13)+CHR(10)
	Local cNBFATRE03	:= "##BFATRE03"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	
	
	cQuery += " SELECT *"+ Enter 
	cQuery += " INTO "+cNBFATRE03+" "+ Enter 
	cQuery += " FROM "+ Enter 
	cQuery += " (SELECT '01' EMP, C6_NUM, C6_PRODUTO, C6_ITEM, C6_ENTREG, C6_YDTNECE, C6_YEMISSA, ISNULL(C9_PEDIDO,'') AS C9_PEDIDO, ISNULL(C9_ITEM,'') AS C9_ITEM, ISNULL(C9_SEQUEN,'') AS C9_SEQUEN, ISNULL(C9_DATALIB,'') AS C9_DATALIB, ISNULL(C9_NFISCAL,'') AS C9_NFISCAL, ISNULL(C9_SERIENF,'') AS C9_SERIENF"+ Enter 
	cQuery += " FROM SC6010 SC6 WITH (NOLOCK)"+ Enter 
	cQuery += " 	LEFT JOIN SC9010 SC9 WITH (NOLOCK) ON"+ Enter 
	cQuery += " 		C9_PEDIDO	= C6_NUM AND"+ Enter 
	cQuery += " 		C9_CLIENTE	= C6_CLI AND "+ Enter 
	cQuery += " 		C9_PRODUTO	= C6_PRODUTO AND"+ Enter 
	cQuery += " 		C9_ITEM		= C6_ITEM AND "+ Enter 
	cQuery += " 		SC9.D_E_L_E_T_ = ''	"+ Enter 
	cQuery += " WHERE SC6.C6_YEMISSA >= '20150101' AND SC6.D_E_L_E_T_ = '' "+ Enter 
	cQuery += " UNION ALL "+ Enter 
	cQuery += " SELECT '05' EMP, C6_NUM, C6_PRODUTO, C6_ITEM, C6_ENTREG, C6_YDTNECE, C6_YEMISSA, ISNULL(C9_PEDIDO,'') AS C9_PEDIDO, ISNULL(C9_ITEM,'') AS C9_ITEM, ISNULL(C9_SEQUEN,'') AS C9_SEQUEN, ISNULL(C9_DATALIB,'') AS C9_DATALIB, ISNULL(C9_NFISCAL,'') AS C9_NFISCAL, ISNULL(C9_SERIENF,'') AS C9_SERIENF"+ Enter 
	cQuery += " FROM SC6050 SC6 WITH (NOLOCK)"+ Enter 
	cQuery += " 	LEFT JOIN SC9050 SC9 WITH (NOLOCK) ON"+ Enter 
	cQuery += " 		C9_PEDIDO	= C6_NUM AND"+ Enter 
	cQuery += " 		C9_CLIENTE	= C6_CLI AND "+ Enter 
	cQuery += " 		C9_PRODUTO	= C6_PRODUTO AND"+ Enter 
	cQuery += " 		C9_ITEM		= C6_ITEM AND "+ Enter 
	cQuery += " 		SC9.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " WHERE SC6.C6_YEMISSA >= '20150101' AND SC6.D_E_L_E_T_ = '' "+ Enter 
	cQuery += " UNION ALL"+ Enter 
	cQuery += " SELECT '14' EMP, C6_NUM, C6_PRODUTO, C6_ITEM, C6_ENTREG, C6_YDTNECE, C6_YEMISSA, ISNULL(C9_PEDIDO,'') AS C9_PEDIDO, ISNULL(C9_ITEM,'') AS C9_ITEM, ISNULL(C9_SEQUEN,'') AS C9_SEQUEN, ISNULL(C9_DATALIB,'') AS C9_DATALIB, ISNULL(C9_NFISCAL,'') AS C9_NFISCAL, ISNULL(C9_SERIENF,'') AS C9_SERIENF"+ Enter 
	cQuery += " FROM SC6140 SC6 WITH (NOLOCK)"+ Enter 
	cQuery += " 	LEFT JOIN SC9140 SC9 WITH (NOLOCK) ON"+ Enter 
	cQuery += " 		C9_PEDIDO	= C6_NUM AND"+ Enter 
	cQuery += " 		C9_CLIENTE	= C6_CLI AND "+ Enter 
	cQuery += " 		C9_PRODUTO	= C6_PRODUTO AND"+ Enter 
	cQuery += " 		C9_ITEM		= C6_ITEM AND "+ Enter 
	cQuery += " 		SC9.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " WHERE SC6.C6_YEMISSA >= '20150101' AND SC6.D_E_L_E_T_ = '' "+ Enter 
	cQuery += " UNION ALL"+ Enter 
	cQuery += " SELECT '13' EMP, C6_NUM, C6_PRODUTO, C6_ITEM, C6_ENTREG, C6_YDTNECE, C6_YEMISSA, ISNULL(C9_PEDIDO,'') AS C9_PEDIDO, ISNULL(C9_ITEM,'') AS C9_ITEM, ISNULL(C9_SEQUEN,'') AS C9_SEQUEN, ISNULL(C9_DATALIB,'') AS C9_DATALIB, ISNULL(C9_NFISCAL,'') AS C9_NFISCAL, ISNULL(C9_SERIENF,'') AS C9_SERIENF"+ Enter 
	cQuery += " FROM SC6130 SC6 WITH (NOLOCK)"+ Enter 
	cQuery += " 	LEFT JOIN SC9130 SC9 WITH (NOLOCK) ON"+ Enter 
	cQuery += " 		C9_PEDIDO	= C6_NUM AND"+ Enter 
	cQuery += " 		C9_CLIENTE	= C6_CLI AND "+ Enter 
	cQuery += " 		C9_PRODUTO	= C6_PRODUTO AND"+ Enter 
	cQuery += " 		C9_ITEM		= C6_ITEM AND "+ Enter 
	cQuery += " 		SC9.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " WHERE SC6.C6_YEMISSA >= '20150101' AND SC6.D_E_L_E_T_ = '' ) TMP"+ Enter 
	cQuery += " "+ Enter 
	
	TcSQLExec(cQuery)
	
	cQuery := " SELECT *"+ Enter 
	cQuery += " FROM "+ Enter 
	cQuery += " ("+ Enter 
	cQuery += " SELECT '01' AS EMP, D2_YEMP AS MARCA, 	"+ Enter 
	cQuery += " 	   D2_CLIENTE AS CLIENTE, "+ Enter 
	cQuery += "        A1_NOME AS NOMECLIENTE, "+ Enter 
	cQuery += " 	   F2_VEND1 AS VENDEDOR, "+ Enter 
	cQuery += " 	   A3_NOME AS NOMEVENDEDOR, "+ Enter 
	cQuery += " 	   D2_DOC AS NF, "+ Enter 
	cQuery += " 	   D2_ITEM AS ITEMNF,"+ Enter 
	cQuery += " 	   D2_COD AS PRODUTO,"+ Enter 
	cQuery += " 	   B1_DESC AS NOMEPRODUTO, "+ Enter 
	cQuery += " 	   D2_QUANT AS QUANTNF, "+ Enter 
	cQuery += " 	   D2_PEDIDO AS PEDIDO,"+ Enter 
	cQuery += " 	   D2_ITEMPV AS ITEMPV,"+ Enter 
	cQuery += " 	   'EMISSAONF'	= CASE WHEN D2_EMISSAO	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,D2_EMISSAO),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTPEDIDO'	= CASE WHEN C6_YEMISSA	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_YEMISSA),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTENTREGA'	= CASE WHEN C6_ENTREG	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_ENTREG),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTNECESENG'	= CASE WHEN C6_YDTNECE	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_YDTNECE),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTEMPENHO'	= CASE WHEN C9_DATALIB	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C9_DATALIB),103) ELSE '' END, "+ Enter 
	cQuery += " 	   (SELECT dbo.FN_PRAZODISP('01',D2_SERIE,D2_DOC,D2_NUMSEQ,D2_PEDIDO,D2_ITEMPV)) DENTROPRAZO,"+ Enter 
	cQuery += " 	   B1_YFORMAT AS FORMATO,"+ Enter 
	cQuery += " 	   A1_YTPSEG  AS TPSEG,"+ Enter 
	cQuery += " 	   A1_YCAT    AS CATEGORIA,"+ Enter 
	cQuery += " 	   ZZ6_FORNOP AS FORNO,"+ Enter 
	cQuery += " 	   B1_YCLASSE AS CLASSE,"+ Enter 
	cQuery += " 	   D2_EMISSAO AS EMISSAO		"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " FROM SD2010 SD2 WITH (NOLOCK)"+ Enter 
	cQuery += " 	INNER JOIN SF4010 SF4 ON"+ Enter 
	cQuery += " 		D2_TES = F4_CODIGO AND "+ Enter 
	cQuery += " 		SF4.D_E_L_E_T_ = '' "+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	INNER JOIN SC9010 SC9 WITH (NOLOCK) ON		"+ Enter 
	cQuery += " 		D2_DOC		= C9_NFISCAL AND "+ Enter 
	cQuery += " 		D2_SERIE	= C9_SERIENF AND  "+ Enter 
	cQuery += " 		D2_CLIENTE	= C9_CLIENTE AND "+ Enter 
	cQuery += " 		D2_PEDIDO	= C9_PEDIDO AND"+ Enter 
	cQuery += " 		D2_COD		= C9_PRODUTO AND "+ Enter 
	cQuery += " 		D2_ITEMPV	= C9_ITEM AND "+ Enter 
	cQuery += " 		D2_NUMSEQ	= C9_NUMSEQ AND "+ Enter 
	cQuery += " 		SC9.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	INNER JOIN SC6010 SC6 WITH (NOLOCK) ON"+ Enter 
	cQuery += " 		C9_PEDIDO	= C6_NUM AND"+ Enter 
	cQuery += " 		C9_PRODUTO	= C6_PRODUTO AND"+ Enter 
	cQuery += " 		C9_ITEM		= C6_ITEM AND "+ Enter 
	cQuery += " 		SC6.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	INNER JOIN SF2010 WITH (NOLOCK) ON D2_SERIE   = F2_SERIE AND D2_DOC  = F2_DOC  AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SF2010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SA1010 ON D2_CLIENTE = A1_COD   AND D2_LOJA = A1_LOJA AND SA1010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SA3010 ON F2_VEND1   = A3_COD   AND SA3010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SB1010 ON D2_COD     = B1_COD   AND SB1010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN ZZ6010 ON B1_YFORMAT = ZZ6_COD  AND ZZ6010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " WHERE D2_FILIAL = '01' 				"+ Enter 
	cQuery += " 	AND SF4.F4_DUPLIC = 'S' 		"+ Enter 
	cQuery += " 	AND SD2.D2_YRESULT = 'S'		"+ Enter 
	cQuery += " 	AND SD2.D2_YRESUL2 = 'S'		"+ Enter 
	cQuery += " 	AND D2_CLIENTE <> '010064'		"+ Enter 
	cQuery += " 	AND SD2.D2_COD >= 'A' 			"+ Enter 
	cQuery += " 	AND SD2.D_E_L_E_T_ = ''			"+ Enter 
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND D2_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 					"+ Enter
	EndIf
	
	If (!Empty(cProdIni) .And. !Empty(cProdFim))
		cQuery += "	AND D2_COD BETWEEN  '"+cProdIni+"' AND '"+cProdIni+"' 						"+ Enter
	EndIf
	
	If (!Empty(cCliIni) .And. !Empty(cCliFim))
		cQuery += "	AND D2_CLIENTE BETWEEN  '"+cCliIni+"' AND '"+cCliFim+"'						"+ Enter
	EndIf
	
	If (!Empty(cPedIni) .And. !Empty(cPedFim))
		cQuery += "	AND D2_PEDIDO BETWEEN  '"+cPedIni+"' AND '"+cPedFim+"' 						"+ Enter
	EndIf
	
	If (!Empty(cMarcaIni) .And. !Empty(cMarcaFim))
		cQuery += "	AND D2_YEMP BETWEEN  '"+cMarcaIni+"' AND '"+cMarcaIni+"'					"+ Enter
	EndIf
	
	
	cQuery += " "+ Enter 
	
	cQuery += " UNION ALL "+ Enter 
	
	cQuery += " "+ Enter 
	cQuery += " SELECT '05' AS EMP, D2_YEMP AS MARCA, 	"+ Enter 
	cQuery += " 	   D2_CLIENTE AS CLIENTE, "+ Enter 
	cQuery += "        A1_NOME AS NOMECLIENTE, "+ Enter 
	cQuery += " 	   F2_VEND1 AS VENDEDOR, "+ Enter 
	cQuery += " 	   A3_NOME AS NOMEVENDEDOR, "+ Enter 
	cQuery += " 	   D2_DOC AS NF, "+ Enter 
	cQuery += " 	   D2_ITEM AS ITEMNF,"+ Enter 
	cQuery += " 	   D2_COD AS PRODUTO,"+ Enter 
	cQuery += " 	   B1_DESC AS NOMEPRODUTO, "+ Enter 
	cQuery += " 	   D2_QUANT AS QUANTNF, "+ Enter 
	cQuery += " 	   D2_PEDIDO AS PEDIDO,"+ Enter 
	cQuery += " 	   D2_ITEMPV AS ITEMPV,"+ Enter 
	cQuery += " 	   'EMISSAONF'	= CASE WHEN D2_EMISSAO	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,D2_EMISSAO),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTPEDIDO'	= CASE WHEN C6_YEMISSA	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_YEMISSA),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTENTREGA'	= CASE WHEN C6_ENTREG	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_ENTREG),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTNECESENG'	= CASE WHEN C6_YDTNECE	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_YDTNECE),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTEMPENHO'	= CASE WHEN C9_DATALIB	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C9_DATALIB),103) ELSE '' END, "+ Enter 
	cQuery += " 	   (SELECT dbo.FN_PRAZODISP('05',D2_SERIE,D2_DOC,D2_NUMSEQ,D2_PEDIDO,D2_ITEMPV)) DENTROPRAZO,"+ Enter 
	cQuery += " 	   B1_YFORMAT AS FORMATO,"+ Enter 
	cQuery += " 	   A1_YTPSEG  AS TPSEG,"+ Enter 
	cQuery += " 	   A1_YCAT    AS CATEGORIA,"+ Enter 
	cQuery += " 	   ZZ6_FORNOP AS FORNO,"+ Enter 
	cQuery += " 	   B1_YCLASSE AS CLASSE,"+ Enter 
	cQuery += " 	   D2_EMISSAO AS EMISSAO "+ Enter 
	cQuery += " "+ Enter 
	cQuery += " FROM SD2050 SD2 WITH (NOLOCK)"+ Enter 
	cQuery += " 	INNER JOIN SF4050 SF4 ON"+ Enter 
	cQuery += " 		D2_TES = F4_CODIGO AND "+ Enter 
	cQuery += " 		SF4.D_E_L_E_T_ = '' "+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	INNER JOIN SC9050 SC9 WITH (NOLOCK) ON		"+ Enter 
	cQuery += " 		D2_DOC		= C9_NFISCAL AND "+ Enter 
	cQuery += " 		D2_SERIE	= C9_SERIENF AND  "+ Enter 
	cQuery += " 		D2_CLIENTE	= C9_CLIENTE AND "+ Enter 
	cQuery += " 		D2_PEDIDO	= C9_PEDIDO AND"+ Enter 
	cQuery += " 		D2_COD		= C9_PRODUTO AND "+ Enter 
	cQuery += " 		D2_ITEMPV	= C9_ITEM AND "+ Enter 
	cQuery += " 		D2_NUMSEQ	= C9_NUMSEQ AND "+ Enter 
	cQuery += " 		SC9.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	INNER JOIN SC6050 SC6 WITH (NOLOCK) ON"+ Enter 
	cQuery += " 		C9_PEDIDO	= C6_NUM AND"+ Enter 
	cQuery += " 		C9_PRODUTO	= C6_PRODUTO AND"+ Enter 
	cQuery += " 		C9_ITEM		= C6_ITEM AND "+ Enter 
	cQuery += " 		SC6.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	INNER JOIN SF2050 WITH (NOLOCK) ON D2_SERIE   = F2_SERIE AND D2_DOC  = F2_DOC  AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SF2050.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SA1050 ON D2_CLIENTE = A1_COD   AND D2_LOJA = A1_LOJA AND SA1050.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SA3010 ON F2_VEND1   = A3_COD   AND SA3010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SB1010 ON D2_COD     = B1_COD   AND SB1010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN ZZ6010 ON B1_YFORMAT = ZZ6_COD  AND ZZ6010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " WHERE D2_FILIAL = '01' 				"+ Enter 
	cQuery += " 	AND SF4.F4_DUPLIC = 'S' 		"+ Enter 
	cQuery += " 	AND SD2.D2_YRESULT = 'S'		"+ Enter 
	cQuery += " 	AND SD2.D2_YRESUL2 = 'S'		"+ Enter 
	cQuery += " 	AND D2_CLIENTE <> '010064'		"+ Enter 
	cQuery += " 	AND SD2.D2_COD >= 'A' 			"+ Enter 
	cQuery += " 	AND SD2.D_E_L_E_T_ = ''			"+ Enter 
	
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND D2_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 					"+ Enter
	EndIf
	
	If (!Empty(cProdIni) .And. !Empty(cProdFim))
		cQuery += "	AND D2_COD BETWEEN  '"+cProdIni+"' AND '"+cProdIni+"' 						"+ Enter
	EndIf
	
	If (!Empty(cCliIni) .And. !Empty(cCliFim))
		cQuery += "	AND D2_CLIENTE BETWEEN  '"+cCliIni+"' AND '"+cCliFim+"'						"+ Enter
	EndIf
	
	If (!Empty(cPedIni) .And. !Empty(cPedFim))
		cQuery += "	AND D2_PEDIDO BETWEEN  '"+cPedIni+"' AND '"+cPedFim+"' 						"+ Enter
	EndIf
	
	If (!Empty(cMarcaIni) .And. !Empty(cMarcaFim))
		cQuery += "	AND D2_YEMP BETWEEN  '"+cMarcaIni+"' AND '"+cMarcaIni+"'					"+ Enter
	EndIf
	
	cQuery += " "+ Enter 
	
	cQuery += " UNION ALL "+ Enter 
	
	cQuery += " "+ Enter 
	cQuery += " SELECT '14' AS EMP, D2_YEMP AS MARCA, 	"+ Enter 
	cQuery += " 	   D2_CLIENTE AS CLIENTE, "+ Enter 
	cQuery += "        A1_NOME AS NOMECLIENTE, "+ Enter 
	cQuery += " 	   F2_VEND1 AS VENDEDOR, "+ Enter 
	cQuery += " 	   A3_NOME AS NOMEVENDEDOR, "+ Enter 
	cQuery += " 	   D2_DOC AS NF, "+ Enter 
	cQuery += " 	   D2_ITEM AS ITEMNF,"+ Enter 
	cQuery += " 	   D2_COD AS PRODUTO,"+ Enter 
	cQuery += " 	   B1_DESC AS NOMEPRODUTO, "+ Enter 
	cQuery += " 	   D2_QUANT AS QUANTNF, "+ Enter 
	cQuery += " 	   D2_PEDIDO AS PEDIDO,"+ Enter 
	cQuery += " 	   D2_ITEMPV AS ITEMPV,"+ Enter 
	cQuery += " 	   'EMISSAONF'	= CASE WHEN D2_EMISSAO	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,D2_EMISSAO),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTPEDIDO'	= CASE WHEN C6_YEMISSA	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_YEMISSA),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTENTREGA'	= CASE WHEN C6_ENTREG	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_ENTREG),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTNECESENG'	= CASE WHEN C6_YDTNECE	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_YDTNECE),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTEMPENHO'	= CASE WHEN C9_DATALIB	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,C9_DATALIB),103) ELSE '' END, "+ Enter 
	cQuery += " 	   (SELECT dbo.FN_PRAZODISP('14',D2_SERIE,D2_DOC,D2_NUMSEQ,D2_PEDIDO,D2_ITEMPV)) DENTROPRAZO,"+ Enter 
	cQuery += " 	   B1_YFORMAT AS FORMATO,"+ Enter 
	cQuery += " 	   A1_YTPSEG  AS TPSEG,"+ Enter 
	cQuery += " 	   A1_YCAT    AS CATEGORIA,"+ Enter 
	cQuery += " 	   ZZ6_FORNOP AS FORNO,"+ Enter 
	cQuery += " 	   B1_YCLASSE AS CLASSE,"+ Enter 
	cQuery += " 	   D2_EMISSAO AS EMISSAO "+ Enter 
	cQuery += " "+ Enter 
	cQuery += " FROM SD2140 SD2 WITH (NOLOCK)"+ Enter 
	cQuery += " 	INNER JOIN SF4140 SF4 ON"+ Enter 
	cQuery += " 		D2_TES = F4_CODIGO AND "+ Enter 
	cQuery += " 		SF4.D_E_L_E_T_ = '' "+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	INNER JOIN SC9140 SC9 WITH (NOLOCK) ON		"+ Enter 
	cQuery += " 		D2_DOC		= C9_NFISCAL AND "+ Enter 
	cQuery += " 		D2_SERIE	= C9_SERIENF AND  "+ Enter 
	cQuery += " 		D2_CLIENTE	= C9_CLIENTE AND "+ Enter 
	cQuery += " 		D2_PEDIDO	= C9_PEDIDO AND"+ Enter 
	cQuery += " 		D2_COD		= C9_PRODUTO AND "+ Enter 
	cQuery += " 		D2_ITEMPV	= C9_ITEM AND "+ Enter 
	cQuery += " 		D2_NUMSEQ	= C9_NUMSEQ AND "+ Enter 
	cQuery += " 		SC9.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	INNER JOIN SC6140 SC6 WITH (NOLOCK) ON"+ Enter 
	cQuery += " 		C9_PEDIDO	= C6_NUM AND"+ Enter 
	cQuery += " 		C9_PRODUTO	= C6_PRODUTO AND"+ Enter 
	cQuery += " 		C9_ITEM		= C6_ITEM AND "+ Enter 
	cQuery += " 		SC6.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	INNER JOIN SF2140 WITH (NOLOCK) ON D2_SERIE   = F2_SERIE AND D2_DOC  = F2_DOC  AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SF2140.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SA1010 ON D2_CLIENTE = A1_COD   AND D2_LOJA = A1_LOJA AND SA1010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SA3010 ON F2_VEND1   = A3_COD   AND SA3010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SB1010 ON D2_COD     = B1_COD   AND SB1010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN ZZ6010 ON B1_YFORMAT = ZZ6_COD  AND ZZ6010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " WHERE D2_FILIAL = '01' 				"+ Enter 
	cQuery += " 	AND SF4.F4_DUPLIC = 'S' 		"+ Enter 
	cQuery += " 	AND SD2.D2_YRESULT = 'S'		"+ Enter 
	cQuery += " 	AND SD2.D2_YRESUL2 = 'S'		"+ Enter 
	cQuery += " 	AND D2_CLIENTE <> '010064'		"+ Enter 
	cQuery += " 	AND SD2.D2_COD >= 'A' 			"+ Enter 
	cQuery += " 	AND SD2.D_E_L_E_T_ = ''			"+ Enter 
	
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND D2_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 					"+ Enter
	EndIf
	
	If (!Empty(cProdIni) .And. !Empty(cProdFim))
		cQuery += "	AND D2_COD BETWEEN  '"+cProdIni+"' AND '"+cProdIni+"' 						"+ Enter
	EndIf
	
	If (!Empty(cCliIni) .And. !Empty(cCliFim))
		cQuery += "	AND D2_CLIENTE BETWEEN  '"+cCliIni+"' AND '"+cCliFim+"'						"+ Enter
	EndIf
	
	If (!Empty(cPedIni) .And. !Empty(cPedFim))
		cQuery += "	AND D2_PEDIDO BETWEEN  '"+cPedIni+"' AND '"+cPedFim+"' 						"+ Enter
	EndIf
	
	If (!Empty(cMarcaIni) .And. !Empty(cMarcaFim))
		cQuery += "	AND D2_YEMP BETWEEN  '"+cMarcaIni+"' AND '"+cMarcaIni+"'					"+ Enter
	EndIf

	cQuery += " "+ Enter 
	
	cQuery += " UNION ALL"+ Enter 
	
	cQuery += " "+ Enter 
	cQuery += " SELECT *"+ Enter 
	cQuery += " FROM"+ Enter 
	cQuery += " ("+ Enter 
	cQuery += " SELECT '07' AS EMP, D2_YEMP AS MARCA, 	"+ Enter 
	cQuery += " 	   D2_CLIENTE AS CLIENTE, "+ Enter 
	cQuery += "        A1_NOME AS NOMECLIENTE, "+ Enter 
	cQuery += " 	   F2_VEND1 AS VENDEDOR, "+ Enter 
	cQuery += " 	   A3_NOME AS NOMEVENDEDOR, "+ Enter 
	cQuery += " 	   D2_DOC AS NF, "+ Enter 
	cQuery += " 	   D2_ITEM AS ITEMNF,"+ Enter 
	cQuery += " 	   D2_COD AS PRODUTO,"+ Enter 
	cQuery += " 	   B1_DESC AS NOMEPRODUTO, "+ Enter 
	cQuery += " 	   D2_QUANT AS QUANTNF, "+ Enter 
	cQuery += " 	   D2_PEDIDO AS PEDIDO,"+ Enter 
	cQuery += " 	   D2_ITEMPV AS ITEMPV,"+ Enter 
	cQuery += " 	   'EMISSAONF'	= CASE WHEN D2_EMISSAO	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,D2_EMISSAO),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTPEDIDO'	= CASE WHEN PED.C6_YEMISSA	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,PED.C6_YEMISSA),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTENTREGA'	= CASE WHEN PED.C6_ENTREG	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,PED.C6_ENTREG),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTNECESENG'	= CASE WHEN PED.C6_YDTNECE	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,PED.C6_YDTNECE),103) ELSE '' END,"+ Enter 
	cQuery += " 	   'DTEMPENHO'	= CASE WHEN PED.C9_DATALIB	<> '' THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,PED.C9_DATALIB),103) ELSE '' END, "+ Enter 
	cQuery += " 	   (SELECT dbo.FN_PRAZODISP('07',D2_SERIE,D2_DOC,D2_NUMSEQ,D2_PEDIDO,D2_ITEMPV)) DENTROPRAZO,"+ Enter 
	cQuery += " 	   B1_YFORMAT AS FORMATO,"+ Enter 
	cQuery += " 	   A1_YTPSEG  AS TPSEG,"+ Enter 
	cQuery += " 	   A1_YCAT    AS CATEGORIA,"+ Enter 
	cQuery += " 	   ZZ6_FORNOP AS FORNO,"+ Enter 
	cQuery += " 	   B1_YCLASSE AS CLASSE,	   "+ Enter 
	cQuery += " 	   D2_EMISSAO AS EMISSAO"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " FROM SD2070 SD2 WITH (NOLOCK)"+ Enter 
	cQuery += " 	INNER JOIN SF4070 SF4 ON"+ Enter 
	cQuery += " 		D2_TES = F4_CODIGO AND "+ Enter 
	cQuery += " 		SF4.D_E_L_E_T_ = '' "+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	INNER JOIN SC9070 SC9 WITH (NOLOCK) ON		"+ Enter 
	cQuery += " 		D2_DOC		= C9_NFISCAL AND "+ Enter 
	cQuery += " 		D2_SERIE	= C9_SERIENF AND  "+ Enter 
	cQuery += " 		D2_CLIENTE	= C9_CLIENTE AND "+ Enter 
	cQuery += " 		D2_PEDIDO	= C9_PEDIDO AND"+ Enter 
	cQuery += " 		D2_COD		= C9_PRODUTO AND "+ Enter 
	cQuery += " 		D2_ITEMPV	= C9_ITEM AND "+ Enter 
	cQuery += " 		D2_NUMSEQ	= C9_NUMSEQ AND "+ Enter 
	cQuery += " 		SC9.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	INNER JOIN SC6070 SC6 WITH (NOLOCK) ON"+ Enter 
	cQuery += " 		C9_PEDIDO	= C6_NUM AND"+ Enter 
	cQuery += " 		C9_PRODUTO	= C6_PRODUTO AND"+ Enter 
	cQuery += " 		C9_ITEM		= C6_ITEM AND "+ Enter 
	cQuery += " 		SC6.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " 	LEFT JOIN "+cNBFATRE03+" PED ON"+ Enter 
	cQuery += " 		PED.EMP			= SUBSTRING(SC9.C9_BLINF,01,2) AND"+ Enter 
	cQuery += " 		PED.C9_NFISCAL	= SUBSTRING(SC9.C9_BLINF,03,9) AND"+ Enter 
	cQuery += " 		PED.C9_SERIENF	= SUBSTRING(SC9.C9_BLINF,12,3) AND"+ Enter 
	cQuery += " 		PED.C9_PEDIDO	= SUBSTRING(SC9.C9_BLINF,15,6) AND"+ Enter 
	cQuery += " 		PED.C9_ITEM		= SUBSTRING(SC9.C9_BLINF,21,2) AND"+ Enter 
	cQuery += " 		PED.C9_SEQUEN	= SUBSTRING(SC9.C9_BLINF,23,2) "+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	INNER JOIN SF2070 WITH (NOLOCK) ON D2_SERIE   = F2_SERIE AND D2_DOC  = F2_DOC  AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SF2070.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN (SELECT '01' EMP, A1_COD, A1_LOJA, A1_YCAT, A1_YTPSEG, A1_NOME FROM SA1010 WHERE D_E_L_E_T_ = '' UNION ALL "+ Enter 
	cQuery += " 				SELECT '05' EMP, A1_COD, A1_LOJA, A1_YCAT, A1_YTPSEG, A1_NOME FROM SA1010 WHERE D_E_L_E_T_ = '' UNION ALL "+ Enter 
	cQuery += " 				SELECT '13' EMP, A1_COD, A1_LOJA, A1_YCAT, A1_YTPSEG, A1_NOME FROM SA1010 WHERE D_E_L_E_T_ = '' UNION ALL "+ Enter 	
	cQuery += " 				SELECT '14' EMP, A1_COD, A1_LOJA, A1_YCAT, A1_YTPSEG, A1_NOME FROM SA1010 WHERE D_E_L_E_T_ = '' ) SA1 ON SA1.EMP = PED.EMP AND SA1.A1_COD = D2_CLIENTE AND SA1.A1_LOJA = D2_LOJA"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	INNER JOIN SA3010 ON F2_VEND1   = A3_COD   AND SA3010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN SB1010 ON D2_COD     = B1_COD   AND SB1010.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	INNER JOIN ZZ6010 ON B1_YFORMAT = ZZ6_COD  AND ZZ6010.D_E_L_E_T_ = ''	"+ Enter 
	cQuery += " 	"+ Enter 
	cQuery += " WHERE D2_FILIAL = '01' 			"+ Enter 
	cQuery += " 	AND SF4.F4_DUPLIC = 'S' 	"+ Enter 
	cQuery += " 	AND SD2.D2_YRESULT = 'S'	"+ Enter 
	cQuery += " 	AND SD2.D2_YRESUL2 = 'S'	"+ Enter 
	cQuery += " 	AND SD2.D2_COD >= 'A' 		"+ Enter 
	cQuery += " 	AND SD2.D_E_L_E_T_ = '' 	"+ Enter 
	
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND D2_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 					"+ Enter
	EndIf
	
	
	If (!Empty(cProdIni) .And. !Empty(cProdFim))
		cQuery += "	AND D2_COD BETWEEN  '"+cProdIni+"' AND '"+cProdIni+"' 						"+ Enter
	EndIf
	
	If (!Empty(cCliIni) .And. !Empty(cCliFim))
		cQuery += "	AND D2_CLIENTE BETWEEN  '"+cCliIni+"' AND '"+cCliFim+"'						"+ Enter
	EndIf
	
	If (!Empty(cPedIni) .And. !Empty(cPedFim))
		cQuery += "	AND D2_PEDIDO BETWEEN  '"+cPedIni+"' AND '"+cPedFim+"' 						"+ Enter
	EndIf
	
	If (!Empty(cMarcaIni) .And. !Empty(cMarcaFim))
		cQuery += "	AND D2_YEMP BETWEEN  '"+cMarcaIni+"' AND '"+cMarcaIni+"'					"+ Enter
	EndIf

	cQuery += " ) TMP"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " WHERE DTENTREGA IS NOT NULL"+ Enter 
	cQuery += " "+ Enter 
	cQuery += " ) TMP"+ Enter 
	cQuery += " "
			
	MemoWrite("\BFATRE03.TXT", cQuery) 		
Return cQuery


Static Function MontaAbaPar()

	oExcel:AddPlanilha('Parametros',{100})
	oExcel:AddLinha(12)

	oExcel:AddCelula("Data de: "+DTOC(STOD(cDataIni)))
	oExcel:AddLinha(12)		
	oExcel:AddCelula("Data até: "+DTOC(STOD(cDataFim)))
	oExcel:AddLinha(12)	
	oExcel:AddCelula("Cliente de: "+cCliIni)
	oExcel:AddLinha(12)   		
	oExcel:AddCelula("Cliente até: "+cCliFim)
	oExcel:AddLinha(12)		
	oExcel:AddCelula("Produto de: "+cProdIni)
	oExcel:AddLinha(12)		
	oExcel:AddCelula("Produto até: "+cProdFim)
	oExcel:AddLinha(12)	
	oExcel:AddCelula("Pedido de: "+cPedIni)
	oExcel:AddLinha(12)	
	oExcel:AddCelula("Pedido até: "+cPedFim)
	oExcel:AddLinha(12)
	oExcel:AddCelula("Marca de: "+cMarcaIni)
	oExcel:AddLinha(12) 		
	oExcel:AddCelula("Marca até: "+cMarcaFim)
	oExcel:AddLinha(12) 			
	oExcel:AddCelula("Pasta Destino: "+cDirDest)
	oExcel:AddLinha(12)	

Return
