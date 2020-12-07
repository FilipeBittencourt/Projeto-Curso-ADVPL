#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TBIACep
@author Wlysses Cerqueira (Facile)
@since 29/11/2018
@project CEP
@version 1.0
@description Classe com as regras do CEP
@type class
/*/

Class TBIACep From LongClassName
	
	Data lEnabled
	Data lRetorno
		
	Data cCampo
	Data cTabela
	Data cCep
	Data cLogradouro
	Data cNumero
	Data cComplemento
	Data cBairro
	Data cUf
	Data cCodMun
	Data cCodUf
	Data cMunicipio
	
	Data aHeadStr
	Data cHeaderRet
	Data oRetorno
	Data cRespJSON
	Data cUrl
		
	Method New(cTabela, cCampo) Constructor
	Method Load(cTabela, cCampo)
	Method Get()
	Method Set()
	Method SetEndCli()
	Method SetEndCobCli()
	Method SetEndEntCli()
	Method InputNumCompl(lAtuCob, lAtuEnt)
	
	Method GetValues()
	Method GetCodMun(cUf, cMunicipio)
	Method GetNomMun(cUf, cCodMun)
	Method Assign()
	Method ExcelCepDivergentes()
	
EndClass

Method New(cTabela, cCampo) Class TBIACep

	Default cTabela	:= ""
	Default cCampo		:= ""
	
	::Load(cTabela, &cCampo, cCampo)
	
Return(Self)

Method Load(cTabela, cCep, cCampo) Class TBIACep
	
	::lEnabled		:= GetNewPar("MV_YVLDCEP", .T.) .And. !IsBlind()
	::cTabela 		:= cTabela
	::cCep 			:= cCep
	::cCampo		:= cCampo
	
	::cLogradouro 	:= ""
	::cComplemento := ""
	::cNumero		:= ""
	::cBairro 		:= ""
	::cUf 			:= ""
	::cCodMun 		:= ""
	::cCodUf 		:= ""
	::cMunicipio	:= ""
	
	::aHeadStr		:= {}
	::cHeaderRet	:= ""
	::cRespJSON		:= ""
	::cUrl			:= ""
	::oRetorno		:= Nil
	::lRetorno 		:= .T.
	
Return()

Method Get() Class TBIACep
	
	If ::lEnabled
	
		::cCep := AllTrim(Replace(::cCep, "-", ""))

		If Empty(::cCep)
	
			::lRetorno := .T.
		
		Else
	
			::cUrl := "http://iris:4902/Correios/Get?cep=" + ::cCep
		
			::cRespJSON := HTTPGet(::cUrl,,,::aHeadStr, @::cHeaderRet)
		
			If ::cRespJSON == Nil .Or. !("200 OK" $ ::cHeaderRet .or. "201 Created" $ ::cHeaderRet .or. "HTTP/1.1 200" $ ::cHeaderRet)
			
				::lRetorno := .F.
		
			Else
		
				If ::cRespJSON <> Nil
			
					FWJsonDeserialize(::cRespJSON, @::oRetorno)
				
				End
			
				If Empty(::oRetorno)
				
					::lRetorno := .F.
				
				ElseIf ::oRetorno:OK

					::lRetorno := .T.
								
					::GetValues()
					
				Else
				
					::lRetorno := .F.
				
				EndIf
			
			EndIf
		
		EndIf
	
	Else
	
		::lRetorno := .T.
		
	EndIf
	
Return(::lRetorno)

Method GetValues() Class TBIACep

	::cLogradouro	:= NoAcento(Upper(DecodeUTF8(::oRetorno:Logradouro)))
	::cComplemento	:= NoAcento(Upper(DecodeUTF8(::oRetorno:Complemento)))
	::cBairro		:= NoAcento(Upper(DecodeUTF8(::oRetorno:Bairro)))
	::cUf			:= NoAcento(Upper(DecodeUTF8(::oRetorno:UF)))
	::cMunicipio	:= NoAcento(Upper(DecodeUTF8(::oRetorno:Municipio)))
	::cCodMun		:= Upper(DecodeUTF8(::GetCodMun(::oRetorno:UF, ::cMunicipio)))
	
Return()


Method GetCodMun(cUf, cMunicipio) Class TBIACep
	
	Local cRetorno := ""
	Local aAreaCC2	:= CC2->(GetArea())
	
	Default cUf := ""
	Default cMunicipio := ""

	DBSelectArea("CC2")
	CC2->(DBSetOrder(4)) // CC2_FILIAL, CC2_EST, CC2_MUN, R_E_C_N_O_, D_E_L_E_T_
	
	If CC2->(DBSeek(xFilial("CC2") + cUf + cMunicipio))
	
		cRetorno := CC2->CC2_CODMUN

	EndIf
	
	RestArea(aAreaCC2)
	
Return(cRetorno)


Method GetNomMun(cUf, cCodMun) Class TBIACep
Local cRetorno := ""
Local aAreaCC2 := CC2->(GetArea())
	
	Default cUf := ""
	Default cCodMun := ""

	DBSelectArea("CC2")
	CC2->(DBSetOrder(1))
	
	If CC2->(DBSeek(xFilial("CC2") + cUf + cCodMun))
	
		cRetorno := CC2->CC2_MUN

	EndIf
	
	RestArea(aAreaCC2)
	
Return(cRetorno)


Method Set() Class TBIACep

	Local lAtuCob := .F.
	Local lAtuEnt := .F.
	
	If ::cTabela == "SA1"
	
		If ::cCampo == "M->A1_CEP"
			
			::SetEndCli()
			
			If M->A1_CEP == M->A1_CEPC .Or. Empty(M->A1_CEPC)
				
				lAtuCob := .T.
				
				::SetEndCobCli()
				
			Else
			
				If MsgYesNo("O Cep informado (" + Transform(M->A1_CEP, "@R 99999-999") + ") é diferente do Cep de cobrança (" + Transform(M->A1_CEPC, "@R 99999-999") + "). Deseja igualar?")
					
					lAtuCob := .T.
					
					::SetEndCobCli()
			
				EndIf
				
			EndIf
			
			//::SetEndEntCli()
			
			::InputNumCompl(lAtuCob, lAtuEnt)
		
		ElseIf ::cCampo == "M->A1_CEPC"

			::SetEndCobCli()

			::InputNumCompl(lAtuCob, lAtuEnt)
		
		ElseIf ::cCampo == "M->A1_CEPE"
		
			::SetEndEntCli()
							
			::InputNumCompl(lAtuCob, lAtuEnt)
			
		EndIf
		
	ElseIf ::cTabela == "SA2"
	
		
		
	EndIf

Return()

Method SetEndCli() Class TBIACep

	M->A1_CEP 		:= PADR(::cCep,	 		TamSX3("A1_CEP")[1], " ")
	M->A1_END 		:= PADR(::cLogradouro, 	TamSX3("A1_END")[1], " ")
	M->A1_COMPLEM 	:= PADR(::cComplemento,	TamSX3("A1_COMPLEM")[1], " ")
	M->A1_BAIRRO 	:= PADR(::cBairro, 		TamSX3("A1_BAIRRO")[1], " ")
	M->A1_EST 		:= PADR(::cUf, 			TamSX3("A1_EST")[1], " ")
	M->A1_COD_MUN 	:= PADR(::cCodMun, 		TamSX3("A1_COD_MUN")[1], " ")
	M->A1_MUN		:= PADR(::cMunicipio, 		TamSX3("A1_MUN")[1], " ")
	
Return()
			
Method SetEndCobCli() Class TBIACep

	M->A1_CEPC 		:= PADR(::cCep, 			TamSX3("A1_CEPC")[1], " ")
	M->A1_ENDCOB	:= PADR(::cLogradouro, 	TamSX3("A1_ENDCOB")[1], " ")
	M->A1_BAIRROC 	:= PADR(::cBairro, 		TamSX3("A1_BAIRROC")[1], " ")
	M->A1_ESTC 		:= PADR(::cUf, 			TamSX3("A1_ESTC")[1], " ")
	M->A1_YCODMUN	:= PADR(::cCodMun, 		TamSX3("A1_YCODMUN")[1], " ")
	M->A1_MUNC		:= PADR(::cMunicipio,		TamSX3("A1_MUNC")[1], " ")

Return()
	
Method SetEndEntCli() Class TBIACep

	M->A1_CEPE 		:= PADR(::cCep, 			TamSX3("A1_CEPE")[1], " ")
	M->A1_ENDENT	:= PADR(::cLogradouro, 	TamSX3("A1_ENDENT")[1], " ")
	M->A1_BAIRROE 	:= PADR(::cBairro, 		TamSX3("A1_BAIRROE")[1], " ")
	M->A1_ESTE 		:= PADR(::cUf, 			TamSX3("A1_ESTE")[1], " ")
	M->A1_CODMUNE	:= PADR(::cCodMun, 		TamSX3("A1_CODMUNE")[1], " ")
	M->A1_MUNE		:= PADR(::cMunicipio, 		TamSX3("A1_MUNE")[1], " ")

Return()


Method InputNumCompl(lAtuCob, lAtuEnt) Class TBIACep
	
	Local lRet	  := .T.
	Local aRet   := {Space(5), Space(TamSX3("A1_CEP")[1])}
	Local aPergs := {}
	Local nPosMun := 0
	Local nPosEnd := 0
	Local nPosBairro := 0
	Local nPosCompl := 0
	Local nPosNum := 0
	
	Default lAtuCob := .F.
	Default lAtuEnt := .F.
	
	If Empty(::cCodMun)

		aAdd( aPergs ,{1, "Cod. Município", Space(TamSX3("A1_COD_MUN")[1]), "@!", "ExistCpo('CC2',M->A1_EST + MV_PAR01)", "CC2SA1", ".T.", TamSX3("A1_COD_MUN")[1], .T.})
		
		nPosMun := Len(aPergs)
							
	EndIf
	
	If Empty(::cLogradouro)
	
		aAdd( aPergs ,{1, "Endereco", Space(TamSX3("A1_END")[1])	, , ".T.", ,".T.", TamSX3("A1_END")[1], .F.})
		
		nPosEnd := Len(aPergs)
		
	EndIf
	
	aAdd( aPergs ,{1, "Numero"	, Space(5), , ".T.", ,".T.", 5, .F.})
	
	nPosNum := Len(aPergs)
	
	If Empty(::cBairro)
	
		aAdd( aPergs ,{1, "Bairro"	, Space(TamSX3("A1_BAIRRO")[1]), , ".T.", ,".T.", TamSX3("A1_BAIRRO")[1], .F.})
		
		nPosBairro := Len(aPergs)
		
	EndIf
	
	If ::cCampo == "M->A1_CEP"
	
		aAdd( aPergs ,{1, "Complemento", Space(TamSX3("A1_COMPLEM")[1]), , ".T.", ,".T.", TamSX3("A1_COMPLEM")[1], .F.})
		
		nPosCompl := Len(aPergs)
		
	EndIf
	
	If ParamBox(aPergs, "Parâmetros", aRet, , , , , , , , .F., .F.)
		
		::cCodMun	:= UPPER(If(Empty(::cCodMun), AllTrim(aRet[nPosMun]), ::cCodMun))
		
		::cLogradouro	:= UPPER(If(Empty(::cLogradouro), AllTrim(aRet[nPosEnd]), ::cLogradouro))
		
		::cBairro := UPPER(If(Empty(::cBairro), AllTrim(aRet[nPosBairro]), ::cBairro))
		
		::cNumero := UPPER(If(Empty(::cNumero), AllTrim(aRet[nPosNum]), ::cNumero))
		
		::cComplemento	:= UPPER(If(Empty(::cComplemento) .And. nPosCompl > 0, AllTrim(aRet[nPosCompl]), ::cNumero))
		
		If ::cCampo == "M->A1_CEP"
		
			M->A1_COD_MUN := PADR(AllTrim(::cCodMun), TamSX3("A1_COD_MUN")[1], " ")
			
			M->A1_MUN	:= PADR(::GetNomMun(::cUf, ::cCodMun), TamSX3("A1_MUN")[1], " ")			
			
			M->A1_END	:= PADR(AllTrim(::cLogradouro) + If(Empty(::cNumero), "", ", " + AllTrim(::cNumero)), TamSX3("A1_END")[1], " ")
			
			M->A1_BAIRRO := PADR(AllTrim(::cBairro), TamSX3("A1_BAIRRO")[1], " ")
			
			M->A1_COMPLEM	:= PADR(AllTrim(::cComplemento), TamSX3("A1_COMPLEM")[1], " ")
			
		EndIf
		
		If ::cCampo == "M->A1_CEPC" .Or. lAtuCob
		
			M->A1_ENDCOB	:= PADR(AllTrim(::cLogradouro) + If(Empty(::cNumero), "", ", " + AllTrim(::cNumero)), TamSX3("A1_END")[1], " ")
			
			M->A1_BAIRROC	:= PADR(AllTrim(::cBairro), TamSX3("A1_BAIRRO")[1], " ")
		
		EndIf
		
		If ::cCampo == "M->A1_CEPE" .Or. lAtuEnt
		
			M->A1_ENDENT	:= PADR(AllTrim(::cLogradouro) + If(Empty(::cNumero), "", ", " + AllTrim(::cNumero)), TamSX3("A1_END")[1], " ")
			
			M->A1_BAIRROE	:= PADR(AllTrim(::cBairro), TamSX3("A1_BAIRRO")[1], " ")
			
		EndIf
				
	Else
	
		lRet := .F.
		
	EndIf

Return(lRet)


Method Assign() Class TBIACep
	
	If ::lEnabled
	
		If ::Get()
		
			::Set()
		
		EndIf
		
	EndIf
					
Return()

Method ExcelCepDivergentes() Class TBIACep

	Local aParam	:= {}
	Local aParRet	:= {}
	Local bConfirm	:= {|| .T.}
	Local nTotReg	:= 0
	
	Local cClienteDe	:= ""
	Local cLojaDe		:= ""
	Local cClienteAte	:= ""
	Local cLojaAte		:= ""
	Local cSQL			:= ""
	Local cQry			:= ""
	Local oFWExcel 	:= Nil
	Local oMsExcel 	:= Nil
	Local cDir 			:= GetSrvProfString("Startpath", "")
	Local cFile 		:= ""
	Local cWorkSheet 	:= ""
	Local cTable 		:= ""
	Local cDirTmp  	:= AllTrim(GetTempPath())
	
	cFile := "CEP-" + __cUserID + "-" + dToS(Date()) + "-" + StrTran(Time(), ":", "") + ".XML"
	
	cClienteDe	:= Space(TamSx3("A1_COD")[1])
	cLojaDe		:= Space(TamSx3("A1_LOJA")[1])
	cClienteAte	:= Space(TamSx3("A1_COD")[1])
	cLojaAte	:= Space(TamSx3("A1_LOJA")[1])
	
	aAdd(aParam, {1, "Cliente de"		, cClienteDe	, "@!", ".T.","SA1"	,".T.",,.F.})
	aAdd(aParam, {1, "Loja de"			, cLojaDe		, "@!", ".T.",			,".T.",,.F.})
	aAdd(aParam, {1, "Cliente ate"	, cClienteAte	, "@!", ".T.","SA1"	,".T.",,.F.})
	aAdd(aParam, {1, "Loja ate"		, cLojaAte		, "@!", ".T.",			,".T.",,.F.})
  
	If ParamBox(aParam, "Busca CEP", aParRet, bConfirm,,,,,,"BIACEPX", .T., .T.)
		
		cQry := GetNextAlias()
			
		lRet := .T.
		
		cClienteDe	:= aParRet[1]
		cLojaDe		:= aParRet[2]
		cClienteAte	:= aParRet[3]
		cLojaAte	:= aParRet[4]

		cWorkSheet := "CEP - Clientes"
		cTable := "CEP - Clientes"
	   
		oFWExcel := FWMsExcel():New()
	
		oFWExcel:AddWorkSheet(cWorkSheet)
		oFWExcel:AddTable(cWorkSheet, cTable)
		
		// 1, 1 Numero - 3, 2 Texto 			
		oFWExcel:AddColumn(cWorkSheet, cTable, "CODIGO"		, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "LOJA"		, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "NOME"		, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CEP"			, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "TIPO"		, 1)
		
		oFWExcel:AddColumn(cWorkSheet, cTable, "ENDEREÇO"	, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "BAIRRO"		, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "UF"			, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CODMUN"		, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "MUNICIPIO"	, 1)
		
		oFWExcel:AddColumn(cWorkSheet, cTable, "<>"			, 1)
		
		oFWExcel:AddColumn(cWorkSheet, cTable, "ENDEREÇO API"	, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "BAIRRO API"		, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "UF API"			, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CODMUN API"		, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "MUNICIPIO API"	, 1)
		
		cSQL := " SELECT  * "
		cSQL += " FROM " + RetSQLName("SA1") + " SA1 "
		cSQL += " WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
		cSQL += " AND A1_COD BETWEEN '" + cClienteDe + "' AND '" + cClienteAte + "' "
		cSQL += " AND A1_LOJA BETWEEN '" + cLojaDe + "' AND '" + cLojaAte + "' "
		cSQL += " AND SA1.D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)
		
		Count To nTotReg
		
		(cQry)->(DbGoTop())
		
		ProcRegua(nTotReg * 3)
	
		While !(cQry)->(Eof())
	
			IncProc("Buscando Cep: " + (cQry)->A1_CEP + "-" + AllTrim((cQry)->A1_NOME))
			
			//CEP Cliente
			::Load()
			
			::lEnabled := .T.
			
			::cCep := (cQry)->A1_CEP
			
			If ! Empty(::cCep)
			
				::Get()
		
				If;
						AllTrim(SubStr((cQry)->A1_END, 1, At(",", (cQry)->A1_END))) <> AllTrim(::cLogradouro) .Or.;
						AllTrim((cQry)->A1_BAIRRO 	) <> AllTrim(::cBairro) .Or.;
						AllTrim((cQry)->A1_EST 		) <> AllTrim(::cUf) .Or.;
						AllTrim((cQry)->A1_COD_MUN 	) <> AllTrim(::cCodMun) .Or.;
						AllTrim((cQry)->A1_MUN		) <> AllTrim(::cMunicipio)

					oFWExcel:AddRow(cWorkSheet, cTable, {(cQry)->A1_COD ,;
						(cQry)->A1_LOJA ,;
						(cQry)->A1_NOME ,;
						(cQry)->A1_CEP ,;
						"CEP PADRÃO" ,;
						(cQry)->A1_END ,;
						(cQry)->A1_BAIRRO ,;
						(cQry)->A1_EST ,;
						(cQry)->A1_COD_MUN ,;
						(cQry)->A1_MUN ,;
						"< == >",;
						::cLogradouro,;
						::cBairro ,;
						::cUf ,;
						::cCodMun ,;
						::cMunicipio})

				EndIf
			
			EndIf
			
			IncProc("Buscando Cep de cobrança: " + (cQry)->A1_CEPC + "-" + AllTrim((cQry)->A1_NOME))
			
			//CEP Cobranca
			::Load()
			
			::lEnabled := .T.
			
			::cCep := (cQry)->A1_CEPC
			
			If ! Empty(::cCep)
			
				::Get()
			
				If;
						AllTrim(SubStr((cQry)->A1_ENDCOB, 1, At(",", (cQry)->A1_ENDCOB))) <> AllTrim(::cLogradouro) .Or.;
						AllTrim((cQry)->A1_BAIRROC 	) <> AllTrim(::cBairro) .Or.;
						AllTrim((cQry)->A1_ESTC 	) <> AllTrim(::cUf) .Or.;
						AllTrim((cQry)->A1_YCODMUN	) <> AllTrim(::cCodMun) .Or.;
						AllTrim((cQry)->A1_MUNC		) <> AllTrim(::cMunicipio)

					oFWExcel:AddRow(cWorkSheet, cTable, {(cQry)->A1_COD ,;
						(cQry)->A1_LOJA ,;
						(cQry)->A1_NOME ,;
						(cQry)->A1_CEP ,;
						"CEP COBRANÇA" ,;
						(cQry)->A1_ENDCOB ,;
						(cQry)->A1_BAIRROC ,;
						(cQry)->A1_ESTC ,;
						(cQry)->A1_YCODMUN ,;
						(cQry)->A1_MUNC ,;
						"< == >",;
						::cLogradouro,;
						::cBairro ,;
						::cUf ,;
						::cCodMun ,;
						::cMunicipio})

				EndIf
			
			EndIf
			
			IncProc("Buscando Cep de entrega: " + (cQry)->A1_CEPE + "-" + AllTrim((cQry)->A1_NOME))
			
			//CEP Entrega
			::Load()
			
			::lEnabled := .T.
			
			::cCep := (cQry)->A1_CEPE
			
			If ! Empty(::cCep)
			
				::Get()
			
				If ;
						AllTrim(SubStr((cQry)->A1_ENDENT, 1, At(",", (cQry)->A1_ENDENT))) <> AllTrim(::cLogradouro) .Or.;
						AllTrim((cQry)->A1_BAIRROE ) <> AllTrim(::cBairro) .Or.;
						AllTrim((cQry)->A1_ESTE 	) <> AllTrim(::cUf) .Or.;
						AllTrim((cQry)->A1_CODMUNE	) <> AllTrim(::cCodMun) .Or.;
						AllTrim((cQry)->A1_MUNE		) <> AllTrim(::cMunicipio)

					oFWExcel:AddRow(cWorkSheet, cTable, {(cQry)->A1_COD ,;
						(cQry)->A1_LOJA ,;
						(cQry)->A1_NOME ,;
						(cQry)->A1_CEP ,;
						"CEP ENTREGA" ,;
						(cQry)->A1_ENDENT ,;
						(cQry)->A1_BAIRROE ,;
						(cQry)->A1_ESTE ,;
						(cQry)->A1_CODMUNE ,;
						(cQry)->A1_MUNE ,;
						"< == >",;
						::cLogradouro,;
						::cBairro ,;
						::cUf ,;
						::cCodMun ,;
						::cMunicipio})

				EndIf
			
			EndIf
			
			(cQry)->(DBSkip())
			
		EndDo
		
		(cQry)->(DbCloseArea())
		
		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cFile)
		oFWExcel:DeActivate()

		If Right(cDir,1) <> "\"
			
			cDir := cDir + "\"
			
		EndIf
			 	
		If CpyS2T(cDir + cFile, cDirTmp, .T.)
			
			If ApOleClient('MsExcel')
			
				oMSExcel := MsExcel():New()
				oMSExcel:WorkBooks:Close()
				oMSExcel:WorkBooks:Open(cDirTmp + cFile)
				oMSExcel:SetVisible(.T.)
				oMSExcel:Destroy()
				
			EndIf
	
		Else
		
			MsgInfo("Arquivo não copiado para a pasta temporária do usuário!")
		
		Endif
	
	EndIf

Return()


User Function BIACEP(lWhen, cTab, cCampo)
Local oObj := Nil
	
	Default lWhen	:= .F.
	Default cTab	:= ""
	Default cCampo	:= ""
		
	oObj := TBIACep():New(cTab, cCampo)
	
	If lWhen
		
		If M->A1_TIPO == "X"
		
			Return(.T.)
		
		Else
		
			Return(!oObj:lEnabled)
		
		EndIf
		
	Else // Gatilho ou Valid
		
		If M->A1_TIPO == "X"
		
			Return(.T.)
		
		EndIf
		
		If oObj:lEnabled
		
			U_BIAMsgRun("Buscando CEP...", "Aguarde!", {|| oObj:Assign() })
			
			If Empty(oObj:oRetorno)
					
				Aviso("WS CORREIOS", "Erro na API dos correios!", {"OK"}, 3)
			
			ElseIf !oObj:oRetorno:Ok
			
				Aviso("WS CORREIOS", "O CEP informado não foi encontrado!", {"OK"}, 3)
			
			EndIf

		EndIf
	
	EndIf
	
Return(oObj:lRetorno)


User Function BIACEPX()
Local oObj := Nil
Local lJob := !(Select("SX2") > 0)
	
	If lJob
	
		RpcSetEnv("01", "01")
		
	EndIf
	
	oObj := TBIACep():New()
	
	Processa({||oObj:ExcelCepDivergentes()})
	
	If lJob
	
		RpcClearEnv()
	
	EndIf
	
Return()