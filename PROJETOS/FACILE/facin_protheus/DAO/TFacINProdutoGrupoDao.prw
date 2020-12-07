#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFacINProdutoGrupoDao
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/


Class TFacINProdutoGrupoDao From LongClassName

	Data oClient
	Data oConn
	Method New() Constructor
	Method ListarFacIN(paramAux)
	Method CriarFacIN()
	Method EditarFacIN()

EndClass

Method New() Class TFacINProdutoGrupoDao

	::oClient   := ""
	::oConn     := TFacINConexao():New()

Return Self



Method ListarFacIN(paramAux) Class TFacINProdutoGrupoDao


	Local oJsonOBJ  := Nil
	Local oRequest  := Nil


	If !Empty(::oConn:OUSERM)

		oRequest  := FWRest():New(::oConn:cHostWS)

		if !Empty(paramAux)
			oRequest:setPath("/api/produtogrupo"+paramAux+"")
		Else
			oRequest:setPath("/api/produtogrupo")
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


Method CriarFacIN() Class TFacINProdutoGrupoDao/// DO PROTHEUS  para o  FACIN


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
			oRequest:setPath("/api/produtogrupo")
			oRequest:SetPostParams(cBody)	// Body
			oRequest:Post(::oConn:aHeader)	// Chama a API0

			If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
				If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
					conout(oRequest:CRESULT)
				Else
					cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
					cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
					U_EmailFac("Erro em POST Produto Grupo - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
				Endif
			Endif

			cMsgErro := ""

		Next nW

		//|Atualiza data da ultima inclusão de clientes |
		PutMV("ZF_UPDSBM", DtoS(dDataBase))

	Endif


Return cBody

Method EditarFacIN() Class TFacINProdutoGrupoDao


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

			oOBJ  := ::ListarFacIN("?CodigoLegado="+AllTrim(aObjPTH[nW]:cCodGrp)+"")
			If !Empty(oOBJ)
				cBody := FactoryJS(aObjPTH[nW], oOBJ:RESPONSE[1])
				oRequest:setPath("/api/produtogrupo/"+cValToChar(oOBJ:RESPONSE[1]:ID)+"")
				oRequest:Put(::oConn:aHeader, cBody)	// Chama a API

				If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
					If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
						conout(oRequest:CRESULT)
					Else
						cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
						cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
						U_EmailFac("Erro em PUT GRUPO Produto - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
					Endif
				Endif

			EndIf
			cMsgErro := ""
		Next nW

		//|Atualiza data da ultima inclusão de clientes |
		PutMV("ZF_UPDSBM", DtoS(dDataBase))

	EndIf

Return cBody

Static Function FactoryJS(oPTH, oFacIN)

	Local cJS  := ''

	If !Empty(oPTH)
		cJS  += '{'

		If !Empty(oFacIN)
			If !Empty(oFacIN:Id)
				cJS += '"Id":'+cValToChar(oFacIN:Id)+','
			EndIF
		EndIF

		cJS += '"Descricao": "'+AllTrim(oPTH:cDescri)+'",'
		cJS += '"CodigoLegado":"'+AllTrim(oPTH:cCodGrp)+'",'
		cJS += '"Status": "ativo",

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
	Local cLastUpd	:= SuperGetMV("ZF_UPDSBM",.F.,"")
	Local aOBJ    	:= {}
	Local oModel  	:= Nil

	cSQL +="  SELECT BM_GRUPO, BM_DESC,  D_E_L_E_T_  AS DELETED  "

	cSQL +="      FROM     "
	cSQL +="  "+RetSQLName("SBM")+" WITH (NOLOCK)  "
	cSQL +="   WHERE   0 = 0 "

	If !Empty(FILTRO)
		cSQL +=" "+FILTRO+" "
	EndIf

	If !Empty(cLastUpd)

		cLastUpd	:= DtoS( DaySub( StoD(cLastUpd) , 1 ) )

		cSQL +=" AND  ( "
		cSQL +=" 	 CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(BM_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(BM_USERLGI,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" OR  CONVERT(VARCHAR, DATEADD(DAY,((ASCII(SUBSTRING(BM_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(BM_USERLGA,16,1)) - 50)),'19960101'),112) >= " + ValToSql(cLastUpd)
		cSQL +=" ) "

	EndIf

	TcQuery cSQL new alias "OBJ"

	OBJ->(DBGotop())
	While !OBJ->(EOF()) //Enquando nao for fim de arquivo

		oModel          := TFacINProdutoGrupoModel():New()
		oModel:cCodGrp  := AllTrim(OBJ->BM_GRUPO)
		oModel:cDescri  := U_LFLimpa(AllTrim(OBJ->BM_DESC))
		oModel:cStatus	:= 'ativo'
		oModel:cDeleted := AllTrim(OBJ->DELETED)

		AADD(aOBJ, oModel)

		OBJ->(dbSkip())

	EndDo

	OBJ->(dbCloseArea())

Return aOBJ