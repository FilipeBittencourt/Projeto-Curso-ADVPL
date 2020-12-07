#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFacINNFeDAO
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/ 

Class TFacINNFeDAO From LongClassName

	Data oConn
	Method New() Constructor
	Method EditarFacIN()
	Method ListarFacIN(paramAux)

EndClass

Method New() Class TFacINNFeDAO

	::oConn := TFacINConexao():New()

Return Self



Method ListarFacIN(paramAux) Class TFacINNFeDAO


	Local oJsonOBJ  := Nil
	Local oRequest  := Nil


	If !Empty(::oConn:OUSERM)

		oRequest  := FWRest():New(::oConn:cHostWS)
		oRequest:setPath("/api/PedidoVendaPTH"+paramAux+"")

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

Method EditarFacIN() Class TFacINNFeDAO


	Local aObjPTH   := {}
	Local oOBJ      := ""
	Local oRequest  := ""
	Local cBody     := ""
	Local cMsgErro	:= ""
	Local nW				:= 0

	If !Empty(::oConn:OUSERM)

		aObjPTH   := FactoryOBJ()
		oRequest  := FWRest():New(::oConn:cHostWS)

		For nW := 1 To Len(aObjPTH)
			//FWJsonDeserialize(aOBJ[nW], @body)
			oOBJ  := ::ListarFacIN("?status=finalizado&codigolegado="+AllTrim(aObjPTH[nW]:cNumPed)+"")
			If !Empty(oOBJ)
				cBody := FactoryJS(aObjPTH[nW], oOBJ:RESPONSE[1])
				oRequest:setPath("/api/pedidovendaPTH/"+cValToChar(oOBJ:RESPONSE[1]:ID)+"")
				oRequest:Put(::oConn:aHeader, cBody)	// Chama a API

				If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
					If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
						conout(oRequest:CRESULT)
						dbSelectArea("SC5")
						SC5->(dbSetOrder(3)) //C5_FILIAL, C5_CLIENTE, C5_LOJACLI, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
						If SC5->(dbSeek(xFilial("SC5")+aObjPTH[nW]:cCodCli+aObjPTH[nW]:cLojaCli+aObjPTH[nW]:cNumPed))
							RecLock("SC5",.F.)
							SC5->C5_YFASYNC		:= "S"
							SC5->(MsUnLock())
						EndIf
						SC5->(dbCloseArea())
					Else
						cMsgErro += " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
						cMsgErro += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
						U_EmailFac("Erro em PUT Produto - Protheus >> FacIN", cMsgErro, oRequest:CPATH, cBody)
					Endif
				Endif

			EndIf
			cMsgErro := ""
		Next nW

	Endif

Return cBody

Static Function FactoryJS(oPTH, oFacIN)

	Local cJS     := ''

	If !Empty(oPTH)
		cJS  += '{'

		If !Empty(oFacIN)
			If !Empty(oFacIN:Id)
				cJS += '"Id":'+cValToChar(oFacIN:Id)+','
			EndIF
		EndIF

		cJS += '"CodigoLegado": "'+AllTrim(oPTH:cNumPed)+'",'
		cJS += '"Status": "'+AllTrim(oPTH:cStatus)+'"'

		cJS += '}'
	EndIF

Return cJS



Static Function FactoryOBJ()

	Local cSQL    := ""
	Local aOBJ    := {}
	Local oDAO    := TFacINNFeDAO():New()
	Local oModel  := Nil

	cSQL +=" SELECT "

	CSQL +="  SD2.D2_DOC "
	CSQL +=" ,SC5.C5_NUM "
	cSQL +=" ,SC5.C5_NOTA "
	cSQL  +=" ,SC5.C5_YFACIN "
	cSQL +=" ,SC5.C5_YFASYNC "
	cSQL +=" ,SC5.C5_CLIENTE "
	cSQL +=" ,SC5.C5_LOJACLI "

	cSQL +=" FROM "+RetSQLName("SC5")+" SC5 WITH (NOLOCK) "
	cSQL +=" INNER JOIN  "+RetSQLName("SD2")+" SD2 WITH (NOLOCK)  ON SC5.C5_NUM = SD2.D2_PEDIDO  "
	cSQL +=" AND  SD2.D2_FILIAL = "+ValToSql(xFilial("SD2"))+" AND  SD2.D_E_L_E_T_ = ''  "

	cSQL +=" WHERE SC5.C5_NOTA != ''   "
	cSQL +=" AND  SC5.C5_FILIAL = "+ValToSql(xFilial("SD2"))
	cSQL +=" AND  SC5.D_E_L_E_T_ = ''                                      "
	cSQL +=" AND  SC5.C5_YFACIN != 0                                       "
	cSQL +=" AND  SC5.C5_YFASYNC = 'N'                                     "

	TcQuery cSQL new alias "OBJ"

	OBJ->(DBGotop())
	While !OBJ->(EOF()) //Enquando nao for fim de arquivo

		oModel          := TFacINNFeModel():New()

		oModel:nIdFacIN  := OBJ->C5_YFACIN
		oModel:cNFeDoc   := AllTrim(OBJ->D2_DOC)
		oModel:cNumPed   := AllTrim(OBJ->C5_NUM)
		oModel:cSync     := AllTrim(OBJ->C5_YFASYNC)
		oModel:cCodCli     := AllTrim(OBJ->C5_CLIENTE)
		oModel:cLojaCli     := AllTrim(OBJ->C5_LOJACLI)
		oModel:cStatus   := "faturado"
		oModel:cDeleted  := 0

		AADD(aOBJ, oModel)

		OBJ->(dbSkip())

	EndDo
	OBJ->(dbCloseArea())

Return aOBJ