#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function REPR0001()

	Local aPergs		:= {}
	Local cRefPer	  	:= 'REPR0001' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer

	Private oExcel		:= Nil
	Private cArqXML    	:= "Pre_Requisicoes_" + ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	Private cFonte2	 	:= 'Calibri'
	Private nTamFont2	:= 12
	Private cCorFont2  	:= '#FFFFFF'
	Private cCorFun2	:= '#3333FF'

	Private cFonte3	 	:= 'Calibri'
	Private nTamFont3	:= 8
	Private cCorFont3  	:= '#000000'
	Private cCorFun3	:= '#FFFFFF'
	Private cWhite		:= '#FFFFFF'

	Private aRetPerg   := {ctod(" "), ctod(" "), "", "" , "", ""}

	Private dDataDe		:= STOD('')
	Private dDataAte	:= STOD('')
	Private cDocDe		:= Space(TamSX3("ZI_DOC")[1])
	Private cDocAte		:= REPLICATE("Z", TamSX3("ZI_DOC")[1])
	Private cMatDe		:= Space(TamSX3("ZI_MATRIC")[1])
	Private cMatAte		:= REPLICATE("Z", TamSX3("ZI_MATRIC")[1])
	Private cDirDest	:= Space(200)

	aAdd( aPergs ,{1,"Data de: " 					, dDataDe	,"","NAOVAZIO()",''   ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Data até: " 					, dDataAte	,"","NAOVAZIO()",''   ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Documento de: " 				, cDocDe  	,"",""          ,''   ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Documento até: " 				, cDocAte	,"",""          ,''   ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matricula de: "	   			, cMatDe  	,"",            ,"ZZY",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matricula até: "	   			, cMatAte	,"",            ,"ZZY",'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino: " 	,cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )

	If !ParamBox(aPergs ,"Pre-Requisição",aRetPerg,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	dDataDe			:= ParamLoad(cFileName,,1 	, dDataDe)
	dDataAte   		:= ParamLoad(cFileName,,2 	, dDataAte)
	cDocDe   		:= ParamLoad(cFileName,,3	, cDocDe)
	cDocAte			:= ParamLoad(cFileName,,4	, cDocAte)
	cMatDe			:= ParamLoad(cFileName,,5	, cMatDe)
	cMatAte			:= ParamLoad(cFileName,,6	, cMatAte)
	cDirDest		:= ParamLoad(cFileName,,7	, cDirDest)

	oProcess := MsNewProcess():New( {|lEnd| fImprime(@lEnd)},"Por favor aguarde, processando...","Carregando Informações",.T.)
	oProcess:Activate()

Return

Static Function fImprime()

	oExcel := ARSexcel():New()

	If Empty(cDirDest) .Or. !ExistDir(cDirDest)
		cDirDest := Alltrim(GetTempPath())
	EndIf

	MontaCabecalho()
	MontaLinhas()

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

Return

Static Function MontaCabecalho()

	Local aColLen := {;
	50, 60, 50, 50, 100, 50,50,;
	50, 100, 50, 50,  50, 50, 50,;
	60, 60, 70, 70 ,70,70;
	}

	oExcel:AddPlanilha('Pre_Requisicao', aColLen)
	oExcel:AddLinha(12)
	oExcel:AddCelula("DATA"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("REQUISIÇÃO"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CV"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("MATRICULA" 		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("SOLICITANTE"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("TIPO MOV"   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("BAIXA?"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CODIGO"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DESCRIÇÃO"	   	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("ALMOXARIFADO"	   	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("UM"	   	    	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("QUANT."	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("VALOR"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("APLICAÇÃO"	   	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("TAG"	   	    	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CL_ITEM"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("PARADA?"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DRIVER"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("MOTIVO"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("ATENDENTE"   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)

Return


Static Function MontaLinhas()

	Local cCorF			:= cWhite
	Local cQuery		:= ""
	Local cAliasTemp	:= GetNextAlias()

	cQuery += " SELECT ZI.*,
	//cQuery += " ISNULL((SELECT  NOMFUN   FROM VETORH..VW_BG_COLABORADOR WHERE CAST(NUMFIS AS VARCHAR(30)) = ZI.ZI_RFIDCAL),'') AS ATENDENTE, "
	cQuery += " ISNULL((SELECT  NOMFUN   FROM VW_BG_COLABORADOR WHERE NUMFIS = CAST(CASE WHEN IsNumeric(ZI.ZI_RFIDCAL) = 1 THEN ZI.ZI_RFIDCAL ELSE NULL END AS bigint)),'') AS ATENDENTE, "
	cQuery += "        ZJ.*
	cQuery += " FROM " + RetSqlName('SZI') + " ZI "
	cQuery += "      INNER JOIN " + RetSqlName('SZJ') + " ZJ ON ZI.ZI_DOC = ZJ.ZJ_DOC "
	cQuery += "                              AND ZJ.D_E_L_E_T_ = ' ' "
	cQuery += "      LEFT JOIN CONTROLE_ACESSO..Usuario USU ON USU.ID = ZI.ZI_USRCONF
	cQuery += " WHERE ZI.D_E_L_E_T_ = ' ' "
	cQuery += "       AND ZI_EMISSAO BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cQuery += "       AND ZI_DOC BETWEEN '" + cDocDe + "' AND '" + cDocAte + "' "
	cQuery += "       AND ZI_MATRIC BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' "
	cQuery += "       AND (LEN(ZI.ZI_RFIDCAL) < 15)	"
	cQuery += " ORDER BY ZI_EMISSAO "

	TcQuery cQuery New Alias (cAliasTemp)

	While (!(cAliasTemp)->(Eof()))

		oExcel:AddLinha(12)
		oExcel:AddCelula(dToc(stod((cAliasTemp)->ZI_EMISSAO))							,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZI_DOC											,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZI_CLVL											,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZI_MATRIC										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZI_NOME											,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(AllTrim(NGRetSX3Box("ZI_TIPO", (cAliasTemp)->ZI_TIPO	))		,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZI_BAIXA											,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_COD											,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(StrTran((cAliasTemp)->ZJ_DESCRI, "Ø", "")						,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_LOCAL											,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_UM											,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_QUANT											,2,'R',cFonte3,nTamFont3,cCorFont3,   ,   ,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_VLRTOT										,2,'R',cFonte3,nTamFont3,cCorFont3,   ,   ,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(AllTrim(NGRetSX3Box("ZJ_APLIC", (cAliasTemp)->ZJ_APLIC))	    ,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_TAG											,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZI_ITEMCTA										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_YPARADA										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_YDRIVER										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ZJ_YJTDRV										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTemp)->ATENDENTE         								,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)

		(cAliasTemp)->(DbSkip())

	EndDo

	oExcel:AddLinha(12)

	(cAliasTemp)->(DbCloseArea())

Return
