#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFacINUnidadeMedidaDAO
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/


Class TFacINUnidadeMedidaDAO From LongClassName

	Data oClient
	Data oConn
	Method New() Constructor
	Method ListarFacIN(paramAux)
	Method CriarFacIN()
	Method EditarFacIN()

EndClass

Method New() Class TFacINUnidadeMedidaDAO

	::oClient   := ""
	::oConn     := TFacINConexao():New()

Return Self



Method ListarFacIN(paramAux) Class TFacINUnidadeMedidaDAO

	Local oJsonOBJ  := Nil
	Local oRequest  := Nil


	If !Empty(::oConn:OUSERM)

		oRequest  := FWRest():New(::oConn:cHostWS)

		if !Empty(paramAux)
			oRequest:setPath("/api/unidademedida"+paramAux+"")
		Else
			oRequest:setPath("/api/unidademedida")
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


Method CriarFacIN() Class TFacINUnidadeMedidaDAO/// DO PROTHEUS  para o  FACIN


	Local aObjPTH   := {}
	Local oRequest  := ""
	Local cBody     := ""
	Local cMsgErro	:= ""
	Local nW				:= 0

	If !Empty(::oConn:OUSERM)

		aObjPTH   := FactoryOBJ("POST","")
		oRequest  := FWRest():New(::oConn:cHostWS)

		For nW := 1 To Len(aObjPTH)

			cBody := FactoryJS(aObjPTH[nW], Nil)
			oRequest:setPath("/api/unidademedida")
			oRequest:SetPostParams(cBody)	// Body
			oRequest:Post(::oConn:aHeader)	// Chama a API
			If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
				If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
					conout("Edicao NO PROTHEUS  para o  FACIN")
					conout(oRequest:CRESULT)
				ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
					cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
					cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
					U_EmailFac("Erro em POST Unidade de Medida - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
				Endif
			Endif
			cMsgErro := ""
		Next nW

		//|Atualiza data da ultima inclusão de clientes |
		PutMV("ZF_UPDSAH", DtoS(dDataBase))

	Endif

Return cBody

Method EditarFacIN() Class TFacINUnidadeMedidaDAO

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

			oOBJ  := ::ListarFacIN("?CodigoLegado="+AllTrim(aObjPTH[nW]:cCodigo)+"")
			If !Empty(oOBJ)
				cBody := FactoryJS(aObjPTH[nW], oOBJ:RESPONSE[1])
				oRequest:setPath("/api/unidademedida/"+cValToChar(oOBJ:RESPONSE[1]:ID)+"")
				oRequest:Put(::oConn:aHeader, cBody)	// Chama a API

				If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
					If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
						conout("Edicao NO PROTHEUS  para o  FACIN")
						conout(oRequest:CRESULT)
					ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
						cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
						cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
						U_EmailFac("Erro em PUT Unidade de Medida - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
					Endif
				Endif


			EndIf
			cMsgErro := ""
		Next nW

		//|Atualiza data da ultima inclusão de clientes |
		PutMV("ZF_UPDSAH", DtoS(dDataBase))

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
	cJS += '"Sigla":"'+AllTrim(oPTH:cCodigo)+'",'
	cJS += '"Descricao":"'+AllTrim(oPTH:cDescri)+'",'
	cJS += '"Status":"ativo",'

	If Empty(oPTH:cDeleted)
		cJS += '"Deleted":0'
	Else
		cJS += '"Deleted":1'
	EndIf

	cJS += '}'

Return cJS


Static Function FactoryOBJ(VERBO, FILTRO)

	Local cSQL        := ""
	Local cLastUpd		:= SuperGetMV("ZF_UPDSAH",.F.,"")
	Local aOBJ        := {}
	Local oObjModel   := Nil

	cSQL +="  SELECT       "
	cSQL +="    AH_UNIMED  "
	cSQL +="   ,AH_UMRES    "
	cSQL +="   ,AH_DESCPO  "
	cSQL +="   ,D_E_L_E_T_  AS DELETED "

	cSQL +="      FROM     "
	cSQL +="  "+RetSQLName("SAH")+" WITH (NOLOCK)  "
	cSQL +="   WHERE   0 = 0 "

	If !Empty(FILTRO)
		cSQL +=" "+FILTRO+" "
	EndIf

	If !Empty(cLastUpd)

		cLastUpd	:= DtoS( DaySub( StoD(cLastUpd) , 1 ) )

		cSQL +=" AND  ( "
		cSQL +=" 	 CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(AH_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(AH_USERLGI,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" OR  CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(AH_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(AH_USERLGA,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" ) "

	EndIf

	TcQuery cSQL new alias "OBJ"

	OBJ->(DBGotop())

	While !OBJ->(EoF()) //Enquando nao for fim de arquivo

		oObjModel           := TFacINunidademedidaModel():New()
		oObjModel:cCodigo   := AllTrim(OBJ->AH_UNIMED)
		oObjModel:cSigla		:= AllTrim(OBJ->AH_UMRES)
		oObjModel:cDescri   := U_LFLimpa(AllTrim(OBJ->AH_DESCPO))
		oObjModel:cDeleted  := U_LFLimpa(AllTrim(OBJ->DELETED))
		AADD(aOBJ, oObjModel)

		OBJ->(dbSkip())

	EndDo

	OBJ->(dbCloseArea())

Return aOBJ