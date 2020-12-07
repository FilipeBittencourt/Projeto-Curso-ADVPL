#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#Include "RWMAKE.CH"

/*/{Protheus.doc} TFacINClienteDAO
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINClienteDAO From LongClassName

	Data oClient
	Data oConn
	Method New() Constructor
	Method ListarFacIN(paramAux)
	Method CriarFacIN()
	Method CriarPTH()
	Method EditarFacIN()

EndClass

Method New() Class TFacINClienteDAO

	::oClient   := ""
	::oConn     := TFacINConexao():New()

Return Self



Method ListarFacIN(paramAux) Class TFacINClienteDAO

	Local oJsonOBJ  := Nil
	Local oRequest  := Nil


	If !Empty(::oConn:OUSERM)

		oRequest  := FWRest():New(::oConn:cHostWS)

		if !Empty(paramAux)
			oRequest:setPath("/api/cliente"+paramAux+"")
		Else
			oRequest:setPath("/api/cliente")
		EndIf

		oRequest:Get(::oConn:aHeader)	  // chama a API
		If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
			FWJsonDeserialize(oRequest:CRESULT, @oJsonOBJ)
			//conout(oRequest:CRESULT)
		ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
			conout("CodeHTTP: ",  VAL(oRequest:ORESPONSEH:CSTATUSCODE))
			conout(oRequest:CRESULT)
		Else
			conout(oRequest:GetLastError())
		Endif
	Endif

Return oJsonOBJ


Method CriarFacIN() Class TFacINClienteDAO	// DO PROTHEUS  para o  FACIN


	Local aObjPTH   := {}
	Local oOBJ      := ""
	Local oRequest  := ""
	Local cBody     := ""
	Local cMsgErro	:= ""
	Local cDateTime	:= ""
	Local cErr			:= ""
	Local nW				:= 0
	Local oJson

	If !Empty(::oConn:OUSERM)

		aObjPTH   := FactoryOBJ("POST","")
		oRequest  := FWRest():New(::oConn:cHostWS)

		For nW := 1 To Len(aObjPTH)

			nRecno	:= 0

			oOBJ  := ::ListarFacIN("?CodigoLegado="+AllTrim(aObjPTH[nW]:cCodigo)+"")
			If Empty(oOBJ)

				cDateTime	:= DTOC(Date()) + " - " + Time()
				ConOut(cDateTime + ' #CriarFacIN - Enviando ' + AllTrim(aObjPTH[nW]:cCodigo) + ' - ' + AllTrim(aObjPTH[nW]:cNome) + '#')

				cBody := FactoryJS(aObjPTH[nW], Nil)

				oRequest:setPath("/api/cliente")
				oRequest:SetPostParams(cBody)	// Body
				oRequest:Post(::oConn:aHeader)	// Chama a API

				If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
					If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
						conout("Criado NO PROTHEUS  para o  FACIN")
						conout(oRequest:CRESULT)

						//|Grava o ID do cliente no FacIN |
						oJson := JSonObject():New()
						cErr  := oJSon:fromJson(oRequest:CRESULT)

						If !Empty(cErr)
							MsgStop(cErr,"JSON PARSE ERROR")
							Loop
						Endif

						dbSelectArea("SA1")
						SA1->(dbSetOrder(1))
						If SA1->(dbSeek( xFilial("SA1") + aObjPTH[nW]:cCodSA1 + aObjPTH[nW]:cLojaSA1 ))
							RecLock("SA1",.F.)
							SA1->A1_YFACIN	:= cValToChar(oJson:GetJSonObject('Id'))
							SA1->(MsUnLock())

						EndIf

						FreeObj(oJson)

					ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
						cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
						cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
						U_EmailFac("Erro em POST Cliente - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
					Endif
				Endif

				cMsgErro := ""
			EndIf

		Next nW

		//|Atualiza data da ultima inclusão de clientes |
		PutMV("ZF_UPDSA1", DtoS(dDataBase))

	Else
		MsgStop("## ERROR: FALHA AO SE CONECTAR A API DO FACIN ##")
	EndIf

Return cBody

Method EditarFacIN() Class TFacINClienteDAO // Dados do PROTHEUS  para o FACIN


	Local aObjPTH   := {}
	Local oOBJ      := ""
	Local oRequest  := ""
	Local cBody     := ""
	Local cMsgErro	:= ""
	Local nW				:= 0

	If !Empty(::oConn:OUSERM)

		aObjPTH   := FactoryOBJ("PUT","")
		oRequest  := FWRest():New(::oConn:cHostWS)

		For nW := 1 To Len(aObjPTH)
			//FWJsonDeserialize(aOBJ[nW], @body)
			oOBJ  := ::ListarFacIN("?CpfCnpj="+AllTrim(aObjPTH[nW]:cCGC)+"")
			If !Empty(oOBJ)
				cBody := FactoryJS(aObjPTH[nW], oOBJ:RESPONSE[1])
				oRequest:setPath("/api/cliente/"+cValToChar(oOBJ:RESPONSE[1]:ID)+"")
				oRequest:Put(::oConn:aHeader, cBody)	// Chama a API

				If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
					If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
						conout("Edicao NO PROTHEUS  para o  FACIN")
						conout(oRequest:CRESULT)
					ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
						cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
						cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
						U_EmailFac("Erro em PUT Cliente - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
					Endif
				Endif

			EndIf
			cMsgErro := ""
		Next nW

		//|Atualiza data da ultima inclusão de clientes |
		PutMV("ZF_UPDSA1", DtoS(dDataBase))

	EndIf

Return cBody

Static Function FactoryJS(oPTH, oFacIN)

	Local cJS       := ''

	cJS  += '{'

	If !Empty(oFacIN)
		If !Empty(oFacIN:ID)
			cJS += '"Id":'+cValToChar(oFacIN:ID)+','
		EndIF
	EndIF

	cJS += '"CodigoLegado":"'+AllTrim(oPTH:cCodigo)+'",'
	cJS += '"Nome":"'+AllTrim(oPTH:cNome)+'",'
	cJS += '"NomeFantasia":"'+AllTrim(oPTH:cNomeFan)+'",'
	cJS += '"TipoPessoa":"'+ AllTrim(oPTH:cPessoa)+'",'
	cJS += '"CpfCnpj":"'+AllTrim(oPTH:cCGC)+'",'
	cJS += '"Cep":"'+AllTrim(oPTH:cCEP)+'",'
	cJS += '"Endereco":"'+AllTrim(oPTH:cEnderec)+'",'
	cJS += '"Email":"'+ IIF(Empty(AllTrim(oPTH:cEmail)) == .T. , "aaa@aaa.com.br" , AllTrim(oPTH:cEmail))+'",'
	cJS += '"Numero":"'+ IIF(Empty(AllTrim(oPTH:cNumero)) == .T. , "." , AllTrim(oPTH:cNumero))+'",'
	cJS += '"Complemento":"'+ StrTran(AllTrim(oPTH:cComplem),"/","")+'",'
	cJS += '"Bairro":"'+ AllTrim(oPTH:cBairro)+'",'
	cJS += '"InscricaoEstadual":"'+AllTrim(oPTH:cInscES)+'",'

	cJS += '"DDD1":"'+ IIF(Empty(AllTrim(oPTH:cDDD1)) == .T. , "00" , AllTrim(oPTH:cDDD1))+'",'
	cJS += '"DDD2":"'+IIF(Empty(AllTrim(oPTH:cDDD2)) == .T. , "00" , AllTrim(oPTH:cDDD2))+'",'
	cJS += '"Telefone1":"'+IIF(Empty(AllTrim(oPTH:cTel1)) == .T. , "00000000" , AllTrim(oPTH:cTel1))+'",'
	cJS += '"Telefone2":"'+ AllTrim(oPTH:cTel2)+'",'
	cJS += '"MunicipioId":"'+ AllTrim(oPTH:cCodMun)+'",'
	cJS += '"LimiteCredito":'+cValToChar(oPTH:nLimCred)+','

	If !Empty(AllTrim(oPTH:dVenCred))
		cJS += '"VencimentoLimiteCredito":"'+ SUBSTR(AllTrim(oPTH:dVenCred), 0, 4)+"-"+SUBSTR(AllTrim(oPTH:dVenCred), 5, 2)+"-"+SUBSTR(AllTrim(oPTH:dVenCred), 7, 2)+" 23:59:59" +'",'
	Else
		dData2 := Dtos(Date()-1)
		dData2 := SUBSTR(dData2, 0, 4)+"-"+SUBSTR(dData2, 5, 2)+"-"+SUBSTR(dData2, 7, 2)+" 23:59:59"
		cJS += '"VencimentoLimiteCredito":"'+AllTrim(dData2)+'",'
	EndIf

	If !Empty(AllTrim(oPTH:cVend1Id))
		cJS += '"CodigoVendedor1":"'+ AllTrim(oPTH:cVend1Id)+'",'
	Else
		cJS += '"CodigoVendedor1":"0001",'
	EndIf


	//cJS += '"CodigoVendedor2":"2",'

	If VAL(oPTH:cStatus) == 2
		cJS += '"Status":"ativo",'
	Else
		cJS += '"Status":"inativo",'
	EndIf

	If Empty(oPTH:cDeleted)
		cJS += '"Deleted":0'
	Else
		cJS += '"Deleted":1'
	EndIf

	cJS += '}'

Return cJS

Static Function Estado(UF)

	Local aUF	 := {}

	//|Regiao Norte |
	aAdd(aUF,{"RO","11"})
	aAdd(aUF,{"AC","12"})
	aAdd(aUF,{"AM","13"})
	aAdd(aUF,{"RR","14"})
	aAdd(aUF,{"PA","15"})
	aAdd(aUF,{"AP","16"})
	aAdd(aUF,{"TO","17"})

	//|Regiao Nordeste |
	aAdd(aUF,{"MA","21"})
	aAdd(aUF,{"PI","22"})
	aAdd(aUF,{"CE","23"})
	aAdd(aUF,{"RN","24"})
	aAdd(aUF,{"PB","25"})
	aAdd(aUF,{"PE","26"})
	aAdd(aUF,{"AL","27"})
	aAdd(aUF,{"SE","28"})
	aAdd(aUF,{"BA","29"})

	//|Regiao Sudeste |
	aAdd(aUF,{"MG","31"})
	aAdd(aUF,{"ES","32"})
	aAdd(aUF,{"RJ","33"})
	aAdd(aUF,{"SP","35"})

	//|Regiao Sul |
	aAdd(aUF,{"PR","41"})
	aAdd(aUF,{"SC","42"})
	aAdd(aUF,{"RS","43"})

	//|Regiao Centro-Oeste |
	aAdd(aUF,{"MS","50"})
	aAdd(aUF,{"MT","51"})
	aAdd(aUF,{"GO","52"})
	aAdd(aUF,{"DF","53"})

	nPos := aScan(aUF, {|x| x[1] == cValToChar(UF)})

	If nPos <= 0
		nPos := aScan(aUF, {|x| x[1] == cValToChar(SM0->M0_ESTCOB)})
	Else
		nPos	:= 18
	EndIf

Return aUF[nPos]


Static Function FactoryOBJ(VERBO, FILTRO)

	Local cSQL      := ""
	Local cLastUpd	:= SuperGetMV("ZF_UPDSA1",.F.,"")
	Local aOBJ  		:= {}
	Local oCliMod   := Nil

	cSQL +=" SELECT *  "
	cSQL +=" FROM facin_Clientes "
	cSQL +=" WHERE 1 = 1 "

	// cSQL +=" AND CODIGO = '764193-01' "

	If !Empty(FILTRO)
		cSQL +=" "+FILTRO+" "
	EndIf

	If !Empty(cLastUpd)

		cLastUpd	:= DtoS( DaySub( StoD(cLastUpd) , 1 ) )

		cSQL +=" AND  ( "
		cSQL +=" 	 CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(A1_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(A1_USERLGI,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" OR  CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(A1_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(A1_USERLGA,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" ) "

	EndIf

	TcQuery cSQL New Alias "CLI"

	CLI->(DBGotop())
	While !CLI->(EoF()) //Enquando nAo for fim de arquivo

		oCliMod           := TFacINClienteModel():New()
		oCliMod:cCodigo   := AllTrim(CLI->CODIGO)
		oCliMod:cNome	  	:= U_LFLimpa(AllTrim(CLI->RAZAOSOCIA))
		oCliMod:cNomeFan  := U_LFLimpa(AllTrim(CLI->FANTASIA))
		oCliMod:cPessoa   := AllTrim(CLI->PESSOA)
		oCliMod:cCGC      := AllTrim(CLI->CPFCNPJ)
		oCliMod:cCEP      := AllTrim(CLI->CEP)
		oCliMod:cEnderec  := U_LFLimpa(AllTrim(CLI->ENDEREC))
		oCliMod:cEmail    := IIF(IsEmail(AllTrim(CLI->EMAIL)) , LOWER(AllTrim(CLI->EMAIL)), "aaa@aaa.com.br" )
		oCliMod:cNumero   := IIF(Empty(CLI->NUMERO) , "." , AllTrim(CLI->NUMERO))
		oCliMod:cComplem  := U_LFLimpa(StrTran(AllTrim(CLI->COMPLEM),"/",""))

		oCliMod:cBairro   := U_LFLimpa(AllTrim(CLI->BAIRRO))
		oCliMod:cInscES   := AllTrim(CLI->INSCESTAD)
		oCliMod:cDDD1     := AllTrim(CLI->DDD)
		oCliMod:cDDD2     := AllTrim(CLI->DDD)
		oCliMod:cTel1     := U_LFLimpa(AllTrim(CLI->TELEFONE))
		oCliMod:cTel2     := U_LFLimpa(AllTrim(CLI->FAX))
		oCliMod:cCodMun   := AllTrim(Estado(CLI->UF)[2])+AllTrim(CLI->CODMUNIC)
		oCliMod:cUF       := AllTrim(CLI->UF)
		oCliMod:cVend1Id  := U_LFLimpa(AllTrim(CLI->VENDEDOR))

		oCliMod:nLimCred  := CLI->LIMCRED
		If !Empty(CLI->VENCCREDIT)
			oCliMod:dVenCred  := AllTrim(CLI->VENCCREDIT)
		Else
			dData2 := DtoS(Date()-1)
			oCliMod:dVenCred  := dData2
		EndIf

		oCliMod:cStatus  	:= CLI->BLOQUEADO
		oCliMod:cDeleted 	:= AllTrim(CLI->DELETED)
		oCliMod:cCodSA1		:= CLI->A1_COD
		oCliMod:cLojaSA1	:= CLI->A1_LOJA

		AADD(aOBJ, oCliMod)

		CLI->(dbSkip())

	EndDo
	CLI->(dbCloseArea())

Return aOBJ

////////----------------- DO FACIN para o PROTHEUS -----------------------------------------

Method CriarPTH() Class TFacINClienteDAO

	Local aOFacIN     := {}
	Local cExecError  := ""
	Local aDados     	:= {}
	Local lOK        	:= .T.
	Local nW					:= 0
	//Local dData2 := Dtos(Date())
	//Local cError      := ""
	//Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
	Private lMsErroAuto := .F.

	aOFacIN := ::ListarFacIN("?CodigoLegado=prospect")
	//aOFacIN := ::ListarFacIN("")

	If !Empty(aOFacIN)
		conout("Criado NO FACIN   para o  PROTHEUS")
		For nW := 1 To Len(aOFacIN:RESPONSE)

			AADD(aDados, {'A1_COD'  , GETSXENUM('SA1','A1_COD'), nil})
			//AADD(aDados, {'A1_COD' , PadL(nW, 6, '0'), nil})
			AADD(aDados, {'A1_LOJA' , '01', nil})
			AADD(aDados, {'A1_NOME' , AllTrim(aOFacIN:RESPONSE[nW]:NOME), nil})
			AADD(aDados, {'A1_PESSOA' , AllTrim(aOFacIN:RESPONSE[nW]:TIPOPESSOA), nil})
			AADD(aDados, {'A1_NREDUZ'  , AllTrim(aOFacIN:RESPONSE[nW]:NOMEFANTASIA), nil})
			AADD(aDados, {'A1_END'   , AllTrim(aOFacIN:RESPONSE[nW]:ENDERECO), nil})
			AADD(aDados, {'A1_BAIRRO'  , AllTrim(aOFacIN:RESPONSE[nW]:BAIRRO), nil})
			AADD(aDados, {'A1_TIPO' , 'F', nil})
			AADD(aDados, {'A1_EST'     , AllTrim(aOFacIN:RESPONSE[nW]:MUNICIPIO:UF), nil})
			AADD(aDados, {'A1_CEP'   , AllTrim(aOFacIN:RESPONSE[nW]:CEP), nil})
			AADD(aDados, {'A1_COD_MUN' , SUBSTR(AllTrim(aOFacIN:RESPONSE[nW]:MUNICIPIO:CODIGOCIDADEIBGE),3,6) , nil})
			AADD(aDados, {'A1_MUN'     , AllTrim(aOFacIN:RESPONSE[nW]:MUNICIPIO:NOMECIDADE), nil})
			AADD(aDados, {'A1_DDD'    , AllTrim(aOFacIN:RESPONSE[nW]:DDD1), nil})
			AADD(aDados, {'A1_TEL'    , AllTrim(aOFacIN:RESPONSE[nW]:TELEFONE1), nil})
			AADD(aDados, {'A1_FAX'    , AllTrim(aOFacIN:RESPONSE[nW]:TELEFONE2), nil})
			AADD(aDados, {'A1_CGC'   , AllTrim(aOFacIN:RESPONSE[nW]:CPFCNPJ), nil})
			AADD(aDados, {'A1_EMAIL' , AllTrim(aOFacIN:RESPONSE[nW]:EMAIL), nil})
			AADD(aDados, {'A1_INSCR'  , AllTrim(aOFacIN:RESPONSE[nW]:INSCRICAOESTADUAL), nil})
			AADD(aDados, {'A1_COMPLEM' , AllTrim(aOFacIN:RESPONSE[nW]:COMPLEMENTO), nil})
			AADD(aDados, {'A1_NUMRA' , AllTrim(aOFacIN:RESPONSE[nW]:NUMERO), nil})
			AADD(aDados, {'A1_LC'     , aOFacIN:RESPONSE[nW]:LIMITECREDITO, nil})

			If AllTrim(aOFacIN:RESPONSE[nW]:STATUS) == "ativo"
				AADD(aDados, {'A1_MSBLQL' , '2' , nil})
			Else
				AADD(aDados, {'A1_MSBLQL' , '1' , nil})
			EndIf

			MSExecAuto({|x,y| mata030(x,y)},aDados,3)  //Fun��o para inserir
			If lMsErroAuto
				lOK := .F.
				cExecError := MostraErro()
				ConOut(cExecError) // captura erro e imprime no console do servidor
				//ErrorBlock(oLastError)
				U_EmailFac("Erro em POST Cliente - FacIN  >> Protheus", cExecError, "", "")
				RollbackSx8()
			Else
				ConfirmSX8()
			EndIf
			aDados     := {}
		Next nW
	EndIf


Return
