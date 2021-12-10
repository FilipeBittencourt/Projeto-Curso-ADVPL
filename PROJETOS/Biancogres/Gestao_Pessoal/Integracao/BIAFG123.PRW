#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} BIAFG123
@description Rotina para Baixar EPI SENIOR
@author Gabriel Mafioletti
@since 23/04/2020
@version 1.0
@type Function
/*/

User Function BIAFG123()

	Local _cAlias

	RpcSetType(3)
	RpcSetEnv('01','01')

	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT SZI.ZI_DTBAIXA
		,SZI.ZI_MATRIC
		,SZJ.ZJ_COD
		,SZJ.ZJ_QUANT
		,SZJ.R_E_C_N_O_ RECZJ
		FROM %TABLE:SZI% SZI(NOLOCK)
		JOIN %TABLE:SZJ% SZJ (NOLOCK) ON SZI.ZI_FILIAL = SZJ.ZJ_FILIAL
		AND SZI.ZI_DOC = SZJ.ZJ_DOC
		AND SZJ.ZJ_INTSR <> 'S'
		AND SZJ.ZJ_INTSR <> 'E'
		AND SZJ.ZJ_MTNCONF = ''
		AND SZJ.%NotDel%
		WHERE ZI_STTSREQ = 'P'
		AND ZI_BAIXA = 'S'
		AND ZI_INTSR = '1'
		AND SZI.%Notdel%

		UNION ALL

		SELECT SZI.ZI_DTBAIXA
		,SZI.ZI_MATRIC
		,SZJ.ZJ_COD
		,SZJ.ZJ_QUANT
		,SZJ.R_E_C_N_O_ RECZJ
		FROM %TABLE:SZI% SZI(NOLOCK)
		JOIN %TABLE:SZJ% SZJ(NOLOCK) ON SZJ.ZJ_FILIAL = SZI.ZI_FILIAL
		AND SZI.ZI_DOC = SZJ.ZJ_DOC
		AND SZJ.ZJ_INTSR <> 'S'
		AND SZJ.ZJ_INTSR <> 'E'
		AND SZJ.ZJ_MTNCONF = ''
		AND SZJ.%NotDel%
		INNER JOIN SB1010 SB1(NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = SZJ.ZJ_COD
		AND SB1.B1_GRUPO = '212A'
		AND SB1.%NotDel%
		WHERE SZI.ZI_FILIAL = %xFilial:SZI%
		AND SZI.ZI_DTBAIXA >= '20200701'
		AND SZI.ZI_STTSREQ = 'P'
		AND SZI.ZI_BAIXA = 'S'
		AND SZI.ZI_MATRIC NOT LIKE 'XX%'
		AND SZI.ZI_INTSR <> '1'
		AND SZI.%Notdel%

	EndSql

	While (_cAlias)->(!EOF())
		SZJ->(DbGoto((_cAlias)->RECZJ))
		If SZJ->(!EOF())
			(_cAlias)->(fIntSr(ZI_DTBAIXA, ZI_MATRIC, ZJ_COD, ZJ_QUANT))
		EndIf
		(_cAlias)->(DbSkip())
	EndDo	
	(_cAlias)->(DbCloseArea())

	RpcClearEnv()

Return

Static Function fIntSr(cDtBaixa,cMatric,cCod,nQuant)

	Local oWsDl
	Local xRet

	// CRIA O OBJETO DA CLASSE TWSDLMANAGER
	oWsdl := TWsdlManager():New()

	// FAZ O PARSE DE UMA URL
	//xRet:= oWsdl:ParseURL( "http://poseidon:8080/g5-senior-services/sm_Synccom_senior_g5_rh_sm_distribuicaoEPI?wsdl" )
	xRet:= oWsdl:ParseURL( "http://poseidon:8080/g5-senior-services/sm_Synccom_senior_g5_rh_sm_custom_distribuicaoEpi?wsdl" )

	if xRet == .F.
		conout( "Erro: " + oWsdl:cError )
		Return
	endif

	//xRet := oWsdl:SetOperation( "Distribuir_2" )
	xRet := oWsdl:SetOperation( "Distribuir" )
	if !xRet
		conout( "Erro: " + oWsdl:cError )
		Return
	endif

	_cSoap	:=	'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.senior.com.br"> '
	_cSoap	+=	'   <soapenv:Header/>                                                                                                   '
	_cSoap	+=	'   <soapenv:Body>                                                                                                      '
	_cSoap	+=	'      <ser:Distribuir>                                                                                                 '
	_cSoap	+=	'         <user>wsprotheus</user>                                                                                       '
	_cSoap	+=	'         <password>OpFid9Ik@</password>                                                                                '
	_cSoap	+=	'         <encryption>0</encryption>                                                                                    '
	_cSoap	+=	'         <parameters>                                                                                                  '
	_cSoap	+=	'           <tipOpe>I</tipOpe>                                                                                          '
	_cSoap	+=	'           <numEmp>'+Substr(cMatric,1,2)+'</numEmp>                                                                                          '
	_cSoap	+=	'           <tipCol>1</tipCol>                                                                                          '
	_cSoap	+=	'           <numCad>' + Substr(cMatric,3) + '</numCad>                                                                  '
	_cSoap	+=	'           <codEpi>' + Alltrim(cCod) + '</codEpi>                                                                      '
	_cSoap	+=	'           <datEnt>' + DtoC(Stod(cDtBAixa)) + '</datEnt>                                                               '
	_cSoap	+=	'           <codOem></codOem>                                                                                           '
	_cSoap	+=	'           <medEpi></medEpi>                                                                                           '
	_cSoap	+=	'           <qtdEnt>' + Alltrim(Str(nQuant)) + '</qtdEnt>                                                                                           '
	_cSoap	+=	'           <datDev></datDev>                                                                                           '
	_cSoap	+=	'           <qtdDev></qtdDev>                                                                                           '
	_cSoap	+=	'           <qtdDan></qtdDan>                                                                                           '
	_cSoap	+=	'           <seqDie>1</seqDie>                                                                                          '
	_cSoap	+=	'           <insUso>S</insUso>                                                                                          '
	_cSoap	+=	'           <assPro>S</assPro>                                                                                          '
	_cSoap	+=	'           <codMtv>1</codMtv>                                                                                          '
	_cSoap	+=	'           <obsDis></obsDis>                                                                                           '
	_cSoap	+=	'           <autPrt>S</autPrt>                                                                                          '
	_cSoap	+=	'         </parameters>                                                                                                 '
	_cSoap	+=	'      </ser:Distribuir>                                                                                                '
	_cSoap	+=	'   </soapenv:Body>                                                                                                     '
	_cSoap	+=	'</soapenv:Envelope>						                                                                            '

	/*
	_cSoap	:=	'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.senior.com.br"> '
	_cSoap	+=	'   <soapenv:Header/>                                                                                                   '
	_cSoap	+=	'   <soapenv:Body>                                                                                                      '
	_cSoap	+=	'      <ser:Distribuir_2>                                                                                               '
	_cSoap	+=	'         <user>wsprotheus</user>                                                                                       '
	_cSoap	+=	'         <password>OpFid9Ik@</password>                                                                                '
	_cSoap	+=	'         <encryption>0</encryption>                                                                                    '
	_cSoap	+=	'         <parameters>                                                                                                  '
	_cSoap	+=	'            <assPro>S</assPro>                                                                                         '
	_cSoap	+=	'            <codEpi>'+Alltrim(cCod)+'</codEpi>                                                                         '
	_cSoap	+=	'            <codMtv>1</codMtv>                                                                                         '
	_cSoap	+=	'            <codOem></codOem>                                                                                          '
	_cSoap	+=	'            <datDev></datDev>                                                                                          '
	_cSoap	+=	'            <datEnt>'+DtoC(Stod(cDtBAixa))+'</datEnt>                                                                  '
	_cSoap	+=	'            <flowInstanceID></flowInstanceID>                                                                          '
	_cSoap	+=	'            <flowName></flowName>                                                                                      '
	_cSoap	+=	'            <insUso>S</insUso>                                                                                         '
	_cSoap	+=	'            <medEpi></medEpi>                                                                                          '
	_cSoap	+=	'            <numCad>'+ Substr(cMatric,3) +'</numCad>                                                                   '
	_cSoap	+=	'            <numEmp>1</numEmp>                                                                                         '
	_cSoap	+=	'            <obsDis></obsDis>                                                                                          '
	_cSoap	+=	'            <qtdEnt>'+Alltrim(Str(nQuant))+'</qtdEnt>                                                                  '
	_cSoap	+=	'            <seqDie>1</seqDie>                                                                                         '
	_cSoap	+=	'            <tipCol>1</tipCol>                                                                                         '
	_cSoap	+=	'            <tipOpe>1</tipOpe>                                                                                         '
	_cSoap	+=	'         </parameters>                                                                                                 '
	_cSoap	+=	'      </ser:Distribuir_2>                                                                                              '
	_cSoap	+=	'   </soapenv:Body>                                                                                                     '
	_cSoap	+=	'</soapenv:Envelope>						                                                                            '
	*/

	oWsdl:SendSoapMsg( _cSoap )

	_nCharDe	:= 	At("<erroExecucao>",oWsdl:GetSoapResponse())
	_nCharAte	:=	At("</erroExecucao>",oWsdl:GetSoapResponse())

	If _nCharDe == 0 .Or. _nCharAte == 0 

		If  At("<erroExecucao",oWsdl:GetSoapResponse()) > 0
			Reclock("SZJ",.F.)
			SZJ->ZJ_INTSR	:=	'S'
			SZJ->(MsUnlock())
		Else

			Reclock("SZJ",.F.)
			SZJ->ZJ_INTSR	:=	'E'
			SZJ->ZJ_ERRSR	:=	"Retorno Incorreto do WS" 
			SZJ->(MsUnlock())
		Endif
	Else

		_cErro	:=	SUBSTR(oWsdl:GetSoapResponse(),_nCharDe+14,_nCharAte-_nCharDe)

		If !Empty(_cerro)

			Reclock("SZJ",.F.)
			SZJ->ZJ_INTSR	:=	'E'
			SZJ->ZJ_ERRSR	:=	_cErro 
			SZJ->(MsUnlock())
		Endif 

	EndIf

Return

//=====================
// Testes Marcos.....
//=====================
User Function msWsEPIxxx()

	Local oWsDl
	Local xRet

	// CRIA O OBJETO DA CLASSE TWSDLMANAGER
	oWsdl := TWsdlManager():New()

	// FAZ O PARSE DE UMA URL
	xRet:= oWsdl:ParseURL( "http://talassa:8080/g5-senior-services/sm_Synccom_senior_g5_rh_sm_custom_distribuicaoEpi?wsdl" )

	if xRet == .F.
		conout( "Erro: " + oWsdl:cError )
		Return
	endif

	xRet := oWsdl:SetOperation( "Distribuir" )
	if !xRet
		conout( "Erro: " + oWsdl:cError )
		Return
	endif

	_cSoap	:=	'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.senior.com.br"> '
	_cSoap	+=	'   <soapenv:Header/>                                                                                                   '
	_cSoap	+=	'   <soapenv:Body>                                                                                                      '
	_cSoap	+=	'      <ser:Distribuir>                                                                                                 '
	_cSoap	+=	'         <user>wsprotheus</user>                                                                                       '
	_cSoap	+=	'         <password>OpFid9Ik@</password>                                                                                '
	_cSoap	+=	'         <encryption>0</encryption>                                                                                    '
	_cSoap	+=	'         <parameters>                                                                                                  '
	_cSoap	+=	'           <tipOpe>I</tipOpe>                                                                                          '
	_cSoap	+=	'           <numEmp>1</numEmp>                                                                                          '
	_cSoap	+=	'           <tipCol>1</tipCol>                                                                                          '
	_cSoap	+=	'           <numCad>1020</numCad>                                                                                       '
	_cSoap	+=	'           <codEpi>2120011</codEpi>                                                                                    '
	_cSoap	+=	'           <datEnt>15/09/20</datEnt>                                                                                   '
	_cSoap	+=	'           <codOem></codOem>                                                                                           '
	_cSoap	+=	'           <medEpi></medEpi>                                                                                           '
	_cSoap	+=	'           <qtdEnt>1</qtdEnt>                                                                                          '
	_cSoap	+=	'           <datDev></datDev>                                                                                           '
	_cSoap	+=	'           <qtdDev></qtdDev>                                                                                           '
	_cSoap	+=	'           <qtdDan></qtdDan>                                                                                           '
	_cSoap	+=	'           <seqDie>1</seqDie>                                                                                          '
	_cSoap	+=	'           <insUso>S</insUso>                                                                                          '
	_cSoap	+=	'           <assPro>S</assPro>                                                                                          '
	_cSoap	+=	'           <codMtv>1</codMtv>                                                                                          '
	_cSoap	+=	'           <obsDis></obsDis>                                                                                           '
	_cSoap	+=	'           <autPrt>S</autPrt>                                                                                          '
	_cSoap	+=	'         </parameters>                                                                                                 '
	_cSoap	+=	'      </ser:Distribuir>                                                                                                '
	_cSoap	+=	'   </soapenv:Body>                                                                                                     '
	_cSoap	+=	'</soapenv:Envelope>						                                                                            '

	oWsdl:SendSoapMsg( _cSoap )

	_nCharDe	:= 	At("<erroExecucao>",oWsdl:GetSoapResponse())
	_nCharAte	:=	At("</erroExecucao>",oWsdl:GetSoapResponse())

	If _nCharDe == 0 .Or. _nCharAte == 0 

		If  At("<erroExecucao",oWsdl:GetSoapResponse()) > 0

			MsgInfo("Deu certo", "Ok")

		Else

			MsgStop("Deu Erro", "Verificar")

		Endif

	Else

		_cErro	:=	SUBSTR(oWsdl:GetSoapResponse(),_nCharDe+14,_nCharAte-_nCharDe)

		If !Empty(_cerro)

			MsgALERT(_cErro, "Erro") 

		Endif 

	EndIf

Return
