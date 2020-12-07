#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFacINProdutoDao
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/


Class TFacINProdutoDao From LongClassName

	Data oClient
	Data oConn
	Method New() Constructor
	Method ListarFacIN(paramAux)
	Method CriarFacIN()
	Method EditarFacIN()

EndClass

Method New() Class TFacINProdutoDao

	::oClient   := ""
	::oConn     := TFacINConexao():New()

Return Self



Method ListarFacIN(paramAux) Class TFacINProdutoDao

	Local oJsonOBJ  := Nil
	Local oRequest  := Nil

	If !Empty(::oConn:OUSERM)

		oRequest  := FWRest():New(::oConn:cHostWS)

		if !Empty(paramAux)
			oRequest:setPath("/api/produto"+paramAux+"")
		Else
			oRequest:setPath("/api/produto")
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


Method CriarFacIN() Class TFacINProdutoDao/// DO PROTHEUS  para o  FACIN

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
			oRequest:setPath("/api/produto")
			oRequest:SetPostParams(cBody)	// Body
			oRequest:Post(::oConn:aHeader)	// Chama a API0

			If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
				If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
					conout(oRequest:CRESULT)

					//|Grava o ID do cliente no FacIN |
					oJson := JSonObject():New()
					cErr  := oJSon:fromJson(oRequest:CRESULT)

					If !Empty(cErr)
						MsgStop(cErr,"JSON PARSE ERROR")
						Loop
					Endif

					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek( xFilial("SB1") + aObjPTH[nW]:cCodSB1 ))
						RecLock("SB1",.F.)
						SB1->B1_YFACIN	:= cValToChar(oJson:GetJSonObject('Id'))
						SB1->(MsUnLock())
					EndIf

					FreeObj(oJson)

				Else
					cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
					cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
					U_EmailFac("Erro em POST Produto - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
				Endif
			Endif

			cMsgErro := ""

		Next nW

		//|Atualiza data da ultima inclusão de produtos |
		PutMV("ZF_UPDSB1", DtoS(dDataBase))

	EndIf

Return cBody

Method EditarFacIN() Class TFacINProdutoDao

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
			oOBJ  := ::ListarFacIN("?CodigoLegado="+AllTrim(aObjPTH[nW]:cCodigo)+"")
			If !Empty(oOBJ)
				cBody := FactoryJS(aObjPTH[nW], oOBJ:RESPONSE[1])
				oRequest:setPath("/api/produto/"+cValToChar(oOBJ:RESPONSE[1]:ID)+"")
				oRequest:Put(::oConn:aHeader, cBody)	// Chama a API

				If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
					If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
						conout(oRequest:CRESULT)
					Else
						cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
						cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
						U_EmailFac("Erro em PUT Produto - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
					Endif
				Endif

			EndIf

			cMsgErro := ""

		Next nW

		//|Atualiza data da ultima inclusão de produtos |
		PutMV("ZF_UPDSB1", DtoS(dDataBase))

	Endif

Return cBody

Static Function FactoryJS(oPTH, oFacIN)

	Local cJS     := ''
	Local cAux     := ''
	Local oUMDao  := TFacINUnidadeMedidaDAO():New()
	Local oPGDao  := TFacINProdutoGrupoDao():New()
	Local oResp   := ''

	If !Empty(oPTH)
		cJS  += '{'

		If !Empty(oFacIN)
			If !Empty(oFacIN:Id)
				cJS += '"Id":'+cValToChar(oFacIN:Id)+','
			EndIF
		EndIF

		cJS += '"CodigoLegado": "'+AllTrim(oPTH:cCodigo)+'",'
		cJS += '"Descricao": "'+AllTrim(oPTH:cDescri)+'",'
		cJS += '"Fabricante": "'+AllTrim(oPTH:cFabric)+'",'
		cJS += '"PrecoVenda": '+cValToChar(oPTH:nPreVen)+','
		cJS += '"PesoBruto": '+cValToChar(oPTH:nPesBru)+','
		cJS += '"PesoLiquido": '+cValToChar(oPTH:nPesLiq)+','
		cJS += '"SaldoEstoque": '+cValToChar(oPTH:nSalEst)+','

		oResp := oUMDao:ListarFacIN("?CodigoLegado="+AllTrim(oPTH:cUM)+"")
		If !Empty(oResp) .AND. oResp:SIZE > 0
			cJS += '"UnidadeMedidaId": '+cValToChar(oResp:RESPONSE[1]:ID)+','
		Else
			cJS += '"UnidadeMedidaId": 0 ,'
		EndIf

		cAux := '"ProdutoGrupoId": 0 ,'
		If !Empty(AllTrim(oPTH:cProdGru))
			oResp := oPGDao:ListarFacIN("?CodigoLegado="+AllTrim(oPTH:cProdGru)+"")
			If !Empty(oResp) .AND. oResp:SIZE > 0
				cJS += '"ProdutoGrupoId": '+cValToChar(oResp:RESPONSE[1]:ID)+','
			EndIf
		EndIf
		cJS	+= cAux

		If !Empty(oPTH:cStatus) .AND. oPTH:cStatus == "1"
			cJS += '"Status": "inativo",
		Else
			cJS += '"Status": "ativo",
		EndIf

		If Empty(oPTH:cDeleted)
			cJS += '"Deleted":0'
		Else
			cJS += '"Deleted":1'
		EndIf

		cJS += '}'
	EndIF

Return cJS



Static Function FactoryOBJ(VERBO, FILTRO)

	Local cSQL    	:= ""
	Local cLastUpd	:= SuperGetMV("ZF_UPDSB1",.F.,"")
	Local aOBJ    	:= {}
	Local oModel  	:= Nil

	cSQL +=" SELECT *  "
	cSQL +=" FROM [dbo].[facin_Produtos] "

	If !Empty(FILTRO)
		cSQL +=" "+FILTRO+" "
	EndIf

	If !Empty(cLastUpd)

		cLastUpd	:= DtoS( DaySub( StoD(cLastUpd) , 1 ) )

		cSQL +=" AND  ( "
		cSQL +=" 	 CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(SB1.B1_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(SB1.B1_USERLGI,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" OR  CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(SB1.B1_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(SB1.B1_USERLGA,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" OR  CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(SB2.B2_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(SB2.B2_USERLGI,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" OR  CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(SB2.B2_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(SB2.B2_USERLGA,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" ) "

	EndIf

	TcQuery cSQL new alias "OBJ"

	OBJ->(DBGotop())
	While !OBJ->(EOF()) //Enquando nao for fim de arquivo

		oModel          	:= TFacINProdutoModel():New()
		oModel:cCodigo 		:= AllTrim(OBJ->CODIGO)
		oModel:cDescri 		:= U_LFLimpa(AllTrim(OBJ->DESCRIC))
		oModel:nPreVen 		:= OBJ->PRCVENDA
		oModel:nPesBru 		:= OBJ->PESBRUTO
		oModel:nPesLiq 		:= OBJ->PESO
		oModel:nSalEst 		:= OBJ->SALDO
		oModel:cUM     		:= AllTrim(OBJ->UNIDMED)
		oModel:cProdGru 	:= AllTrim(OBJ->GRUPO)
		oModel:cFabric 		:= U_LFLimpa(AllTrim(OBJ->FABRIC))

		oModel:cStatus		:= AllTrim(OBJ->BLOQUEADO)
		oModel:cDeleted 	:= AllTrim(OBJ->DELETED)

		oModel:cCodSB1 		:= OBJ->B1_COD

		AADD(aOBJ, oModel)

		OBJ->(dbSkip())

	EndDo
	OBJ->(dbCloseArea())

Return aOBJ