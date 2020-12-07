#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFacINCondicaoPagamentoDAO
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/


Class TFacINCondicaoPagamentoDAO From LongClassName

	Data oModel
	Data oConn
	Method New() Constructor
	Method ListarFacIN(paramAux)
	Method CriarFacIN()
	Method CriarPTH()
	Method EditarFacIN()

EndClass

Method New() Class TFacINCondicaoPagamentoDAO

	::oModel   := ""
	::oConn    := TFacINConexao():New()

Return Self



Method ListarFacIN(paramAux) Class TFacINCondicaoPagamentoDAO



	Local oJsonOBJ  := Nil
	Local oRequest  := Nil


	If !Empty(::oConn:OUSERM)

		oRequest  := FWRest():New(::oConn:cHostWS)

		if !Empty(paramAux)
			oRequest:setPath("/api/condicaopagamento"+paramAux+"")
		Else
			oRequest:setPath("/api/condicaopagamento")
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


Method CriarFacIN() Class TFacINCondicaoPagamentoDAO/// DO PROTHEUS  para o  FACIN

	Local aObjPTH   := {}
	Local oOBJ      := ""
	Local oRequest  := ""
	Local cBody     := ""
	Local cMsgErro	:= ""
	Local nW				:= 0

	If !Empty(::oConn:OUSERM)

		aObjPTH   := FactoryOBJ("POST","")
		oRequest  := FWRest():New(::oConn:cHostWS)

		For nW := 1 To Len(aObjPTH)

			oOBJ  := ::ListarFacIN("?CodigoLegado="+AllTrim(aObjPTH[nW]:cE4CODIGO)+"")
			If Empty(oOBJ)
				cBody := FactoryJS(aObjPTH[nW], Nil)
				oRequest:setPath("/api/condicaopagamento")
				oRequest:SetPostParams(cBody)	// Body
				oRequest:Post(::oConn:aHeader)	// Chama a API

				If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
					If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
						conout("Criado NO PROTHEUS  para o  FACIN")
						conout(oRequest:CRESULT)
					ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
						cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
						cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
						U_EmailFac("Erro em POST Condicao Pagamento - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
					Endif
				Endif

				cMsgErro := ""
			EndIf

		Next nW

		//|Atualiza data da ultima inclusão de clientes |
		PutMV("ZF_UPDSE4", DtoS(dDataBase))

	EndIf

Return cBody

Method EditarFacIN() Class TFacINCondicaoPagamentoDAO // Dados do PROTHEUS  para o FACIN


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
			oOBJ  := ::ListarFacIN("?CodigoLegado="+AllTrim(aObjPTH[nW]:cE4CODIGO)+"")
			If !Empty(oOBJ)
				cBody := FactoryJS(aObjPTH[nW], oOBJ:RESPONSE[1])
				oRequest:setPath("/api/condicaopagamento/"+cValToChar(oOBJ:RESPONSE[1]:ID)+"")
				oRequest:Put(::oConn:aHeader, cBody)	// Chama a API

				If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
					If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
						conout("Edicao NO PROTHEUS do Condicao Pagamento  para o  FACIN")
						conout(oRequest:CRESULT)
					ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
						cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
						cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
						U_EmailFac("Erro em PUT Condicao Pagamento - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
					Endif
				Endif

			EndIf
			cMsgErro := ""
		Next nW

		//|Atualiza data da ultima inclusão de clientes |
		PutMV("ZF_UPDSE4", DtoS(dDataBase))

	EndIf

Return cBody

Static Function FactoryJS(oPTH, oFacIN)

	Local cJS  := ''

	cJS  += '{'

	If !Empty(oFacIN)
		If !Empty(oFacIN:ID)
			cJS += '"Id":'+cValToChar(oFacIN:ID)+','
		EndIF
	EndIF

	cJS += '"CodigoLegado":"'+AllTrim(oPTH:cE4CODIGO)+'",'
	cJS += '"Regra":"'+StrTran(AllTrim(oPTH:cE4COND),"/","")+'",'
	cJS += '"Descricao":"'+StrTran(AllTrim(oPTH:cE4DESCRI),"/"," ")+'",'
	cJS += '"MinimoParcela":'+cValToChar(oPTH:cE4SUPER)+','
	cJS += '"Fator":"dia",'


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

Static Function FactoryOBJ(VERBO, FILTRO)

	Local cSQL   		:= ""
	Local cLastUpd	:= SuperGetMV("ZF_UPDSE4",.F.,"")
	Local aOBJ   		:= {}
	Local oModel 		:= Nil


	cSQL +="  SELECT       "
	cSQL +="    E4_CODIGO    "
	cSQL +="   ,E4_TIPO    "
	cSQL +="   ,E4_COND    "
	cSQL +="   ,E4_DESCRI  "
	cSQL +="   ,E4_MSBLQL  "
	cSQL +="   ,E4_SUPER  "
	cSQL +="   ,D_E_L_E_T_  AS DELETED "

	cSQL +="      FROM     "
	cSQL +="  "+RetSQLName("SE4")+" WITH (NOLOCK)  "
	cSQL +="   WHERE   E4_FILIAL = " + ValToSql(xFilial("SE4"))
	// cSQL +="   AND  D_E_L_E_T_  = '' "

	If !Empty(FILTRO)
		cSQL +=" "+FILTRO+" "
	EndIf

	If !Empty(cLastUpd)

		cLastUpd	:= DtoS( DaySub( StoD(cLastUpd) , 1 ) )

		cSQL +=" AND  ( "
		cSQL +=" 	 CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(E4_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(E4_USERLGI,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" OR  CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(E4_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(E4_USERLGA,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" ) "

	EndIf

	TcQuery cSQL new alias "OBJ"

	OBJ->(DBGotop())
	While !OBJ->(EOF()) //Enquando nao for fim de arquivo

		oModel            := TFacINCondicaoPagamentoModel():New()
		oModel:cE4CODIGO  := AllTrim(OBJ->E4_CODIGO)
		oModel:cE4TIPO    := AllTrim(OBJ->E4_TIPO)
		oModel:cE4COND    := AllTrim(OBJ->E4_COND)
		oModel:cE4DESCRI  := AllTrim(OBJ->E4_DESCRI)
		oModel:cE4SUPER   := OBJ->E4_SUPER

		oModel:cStatus    := OBJ->E4_MSBLQL
		oModel:cDeleted   := AllTrim(OBJ->DELETED)

		AADD(aOBJ, oModel)

		OBJ->(dbSkip())

	EndDo
	OBJ->(dbCloseArea())

Return aOBJ

////////----------------- DO FACIN para o PROTHEUS -----------------------------------------

Method CriarPTH() Class TFacINCondicaoPagamentoDAO

	Local aOFacIN     := {}
	Local cExecError  := ""
	Local aDados      := {}
	Local lOK         := .T.
	Local dData2      := Dtos(Date())
	Local nW					:= 0
	//Local cError      := ""
	//Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
	Private lMsErroAuto := .F.

	//aOFacIN := ::ListarFacIN("")
	dData2 := SUBSTR(dData2, 0, 4)+"-"+SUBSTR(dData2, 5, 2)+"-"+SUBSTR(dData2, 7, 2)
	aOFacIN := ::ListarFacIN("?dateRange=DataAlteracao$"+AllTrim(dData2)+"$"+AllTrim(dData2)+"")


	If !Empty(aOFacIN)
		conout("Criado NO FACIN   para o  PROTHEUS")
		For nW := 1 To Len(aOFacIN:RESPONSE)

			AADD(aDados, {'E4_COND', GETSXENUM('SE4','E4_COD'), nil})
			//AADD(aDados, {'E4_CODIGO', PadL(nW, 3, '0'), nil})
			AADD(aDados, {'E4_TIPO', '1', nil})
			AADD(aDados, {'E4_COND', StrTran(AllTrim(aOFacIN:RESPONSE[nW]:REGRA),"/",""), nil})
			AADD(aDados, {'E4_DESCRI', StrTran(AllTrim(aOFacIN:RESPONSE[nW]:Descricao),"/"," "), nil})
			AADD(aDados, {'E4_SUPER', aOFacIN:RESPONSE[nW]:MinimoParcela, nil})

			If AllTrim(aOFacIN:RESPONSE[nW]:STATUS) == "ativo"
				AADD(aDados, {'E4_MSBLQL' , '2' , nil})
			Else
				AADD(aDados, {'E4_MSBLQL' , '1' , nil})
			EndIf

			MSExecAuto({|x,y| MATA360(x,y)},aDados,3)  //Funcao para inserir
			If lMsErroAuto
				lOK := .F.
				cExecError := MostraErro()
				ConOut(cExecError) // captura erro e imprime no console do servidor
				//ErrorBlock(oLastError)
				U_EmailFac("Erro em POST Condicao Pagamento - FacIN  >> Protheus", cExecError, "", "")
				RollbackSx8()
			Else
				ConfirmSX8()
			EndIf
			aDados     := {}
		Next nW
	EndIf


Return
