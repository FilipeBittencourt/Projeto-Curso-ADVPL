#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIA487
@author Marcos Alberto Soprani
@since 25/09/17
@version 1.0
@description Listagem das informações de Umidade Padrão das Materias Primas Massa e Esmalte
@type function
/*/

User Function BIA487()


	Processa({ || cMsg := Rpt487Detail() }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function Rpt487Detail()

	Local _cAlias   := GetNextAlias()
	Local nRegAtu   := 0
	Local _daduser
	Local _mNomeUsr

	Local msVetDados := {}
	Local msVetColun := 5
	Local msVetPlan  := {}
	Local msNomeFunc := "Umidade Padrão"
	Local zpM, pmZ

	local cCab1Fon   := 'Calibri' 
	local cCab1TamF  := 8   
	local cCab1CorF  := '#FFFFFF'
	local cCab1Fun   := '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML    := UPPER(Alltrim(FunName())) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	private cDirDest := "c:\temp\"

	oExcel := ARSexcel():New()

	ProcRegua(0)

	oExcel:AddPlanilha("Relatorio", {20, 45, 110, 20, 20, 65}, 5)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + (msVetColun) + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + (msVetColun) + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(msNomeFunc, 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + (msVetColun) + 1) - 3 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Produto"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Descrição"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Tipo"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Unid.Med."       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Umidade"         , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	BeginSql Alias _cAlias

		SELECT BZ_COD PRODUTO, 
		RTRIM(B1_DESC) DESCR, 
		B1_TIPO TIPO, 
		B1_UM UM,  
		BZ_YUMIDAD UMIDADE
		FROM %TABLE:SBZ% SBZ
		INNER JOIN %TABLE:SB1% SB1 ON B1_COD = BZ_COD
		AND SB1.%NotDel%
		WHERE BZ_YUMIDAD <> 0
		AND SBZ.%NotDel%

	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))))

			nRegAtu++
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif

			oExcel:AddLinha(14) 
			oExcel:AddCelula()
			oExcel:AddCelula( (_cAlias)->PRODUTO                             , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->DESCR                               , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->TIPO                                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->UM                                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->UMIDADE                             , 4 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	EndIf

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return
