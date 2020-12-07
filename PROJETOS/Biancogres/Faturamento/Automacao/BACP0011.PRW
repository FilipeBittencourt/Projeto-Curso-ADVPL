#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BACP0011
@author Gabriel Rossi Mafioletti
@since 03/09/2019
@version 1.0
@description Transmissão de DANFE
@type function
/*/

User Function BACP0011()

	Local xv_Emps
	Local _nJ
	Local nI

	RpcSetEnv('01','01')

	xv_Emps    := U_BAGtEmpr("01_05_07_13")

	RpcClearEnv()

	For nI := 1 to Len(xv_Emps)
	
		RpcSetType(3)
		RpcSetEnv(xv_Emps[nI,1], xv_Emps[nI,2])
		
		//Parametro para desligar os Jobs Automaticos em caso de Necessidade
		If (U_GETBIAPAR("BIA_FATAUTO", .T. , xv_Emps[nI,1], xv_Emps[nI,2]))
	
			
			If cEmpAnt == '07'
				For _nj	:=	1 to Len(xv_Emps)
					If xv_emps[_nJ,1] == "07"
						Loop
					EndIf
					ConOut('BACP0011::Iniciando... '+cEmpAnt+'/'+cFilAnt+' - Empresa: ' + xv_emps[_nJ,1] + " - " + Time())
					fProcessa(xv_emps[_nJ,1])
					ConOut('BACP0011::Finalizado... '+cEmpAnt+'/'+cFilAnt+' - Empresa: ' + xv_emps[_nJ,1] + " - " + Time())
				Next _nj
			Else
				ConOut('BACP0011::Iniciando '+cEmpAnt+'/'+cFilAnt+' - '+ Time())
				fProcessa()
				ConOut('BACP0011::Finalizado '+cEmpAnt+'/'+cFilAnt+' - '+ Time())
			EndIf
		
		Else
			ConOut("BACP0011 ==> Cancelado/Desligado[BIA_FATAUTO] - " + Time()+" => Empresa: "+xv_Emps[nI,1]+" Filial: "+xv_Emps[nI,2])
		EndIf
		
		RpcClearEnv()
		
	Next nI

Return

Static Function fProcessa(_cEmp)

	Local _cAlias	:=	GetNextAlias()
	Local _cError
	Local _cNotaDe	:=	""
	Local _cNotaAte	:=	""
	Local _cSerie	:=	""
	Local _cZZW		:=	""
	Local _cZZV		:=  ""

	Default _cEmp	:=	""

	Private cIdEnt	:=	GetCfgEntidade(@_cerror)

	If !Empty(_cError)
		ConOut('BACP0011::Erro ao recuperar a Entidade '+cEmpAnt+'/'+cFilAnt+' - '+ Time() + " - " + _cError)
		Return
	EndIf

	If cempAnt == '07'

		Do Case
			Case (_cEmp == '01')
			_cZZW		:=	"%ZZW010%"
			_cZZV		:=  "%ZZV010%"
			Case (_cEmp == '05')
			_cZZW		:=	"%ZZW050%"
			_cZZV		:=  "%ZZV050%"
			Case (_cEmp == '13')
			_cZZW		:=	"%ZZW130%"
			_cZZV		:=  "%ZZV130%"
			OtherWise
			ConOut('BACP0011::Empresa/Filial não Cadastrada... '+cEmpAnt+'/'+cFilAnt+' - '+ Time())
			Return
		EndCase

		BeginSql Alias _cAlias
			%NoParser%

			SELECT DISTINCT 
			SF2.F2_DOC DOCTO, 
			SF2.F2_SERIE SERIE

			FROM %TABLE:SF2% SF2(NOLOCK) 

			LEFT JOIN SPED050 SPED(NOLOCK) ON SPED.ID_ENT = %Exp:cIdEnt%
			AND SPED.NFE_ID = SF2.F2_SERIE + SF2.F2_DOC
			AND SPED.%NotDel%

			WHERE SF2.F2_FILIAL = %XFILIAL:SF2%
			AND SF2.F2_ESPECIE = 'SPED'
			AND SF2.F2_TIPO = 'N'
			AND SF2.F2_IDCLE <> ''
			AND SF2.%NotDel%
			
			AND ((SPED.NFE_ID IS NULL) OR (SPED.STATUS IN ('5')))  //Ticket 22368 - quando da erro na transmissao precisa tentar denovo
			
			AND EXISTS
			(
			SELECT 1 
			FROM %TABLE:SD2% SD2 (NOLOCK)

			JOIN %TABLE:SC6% SC6 (NOLOCK) ON SD2.D2_FILIAL = SC6.C6_FILIAL
			AND SD2.D2_PEDIDO = SC6.C6_NUM
			AND SD2.D2_ITEMPV = SC6.C6_ITEM
			//AND SC6.C6_BLQ <> 'R'  //TICKET 24831 - UMA NF FATURADA ESTAVA COM PEDIDO JA CANCELADO E NAO TRANSMITIA - ACHO QUE NAO PRECISA DESSE FILTRO
			AND SC6.%NotDel%

			JOIN %TABLE:SC5% SC5(NOLOCK) ON SC6.C6_FILIAL = SC5.C5_FILIAL
			AND SC6.C6_NUM = SC5.C5_NUM
			AND SC5.D_E_L_E_T_ = ''

			JOIN %Exp:_cZZW% ZZW (NOLOCK) ON SC6.C6_FILIAL = ZZW.ZZW_FILIAL
			AND SC5.C5_YPEDORI = ZZW.ZZW_PEDIDO
			AND SC6.C6_ITEM = ZZW.ZZW_ITEM			
			AND ZZW.%NotDel%

			JOIN %Exp:_cZZV% ZZV (NOLOCK) ON ZZV.ZZV_FILIAL = ZZW.ZZW_FILIAL
			AND ZZV.ZZV_CARGA = ZZW.ZZW_CARGA
			AND ZZV.ZZV_FIMP <> ''
			AND ZZV.D_E_L_E_T_=''

			JOIN %TABLE:SC9% SC9 (NOLOCK) ON SC9.C9_FILIAL = SC6.C6_FILIAL
			AND SC9.C9_PEDIDO = SC6.C6_NUM
			AND SC9.C9_AGREG = ZZW.ZZW_CARGA
			AND SC9.C9_ITEM = ZZW.ZZW_ITEM
			//AND SC9.C9_SEQUEN = ZZW.ZZW_SEQUEN  //TICKET 24831 - SEQUENCIA DE SC9 DA LM NAO OBRIGATORIAMENTE BATE COM A BIANCO E ESTAVA NAO TRANSMITINDO ALGUMAS NFS
			AND SC9.C9_BLCRED = '10'
			AND SC9.C9_BLEST = '10'
			AND SC9.%NotDel%

			JOIN  %TABLE:SB1% SB1 (NOLOCK) on B1_FILIAL = %XFILIAL:SB1% 
			AND SB1.B1_COD = SC6.C6_PRODUTO
			AND B1_TIPO = 'PA'
			AND SB1.%NotDel%

			WHERE SD2.D2_FILIAL = SF2.F2_FILIAL
			AND SD2.D2_DOC = SF2.F2_DOC
			AND SD2.D2_SERIE = SF2.F2_SERIE
			AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
			AND SD2.D2_LOJA = SF2.F2_LOJA
			AND SD2.%NotDel%
			)

			ORDER BY SF2.F2_SERIE,SF2.F2_DOC

		EndSql

	Else
		BeginSql Alias _cAlias
			%NoParser%
			SELECT DISTINCT SF2.F2_DOC DOCTO, SF2.F2_SERIE SERIE
			FROM %TABLE:SF2% SF2(NOLOCK) 

			LEFT JOIN SPED050 SPED(NOLOCK) 
			ON SPED.ID_ENT = %Exp:cIdEnt%
			AND SPED.NFE_ID = SF2.F2_SERIE + SF2.F2_DOC
			AND SPED.%NotDel%

			WHERE SF2.F2_FILIAL = %XFILIAL:SF2%
			AND SF2.F2_ESPECIE = 'SPED'
			AND SF2.F2_TIPO = 'N'
			AND SF2.F2_IDCLE <> ''
			AND SF2.%NotDel%
			
			AND ((SPED.NFE_ID IS NULL) OR (SPED.STATUS IN ('5'))) //Ticket 22368 - quando da erro na transmissao precisa tentar denovo

			AND EXISTS
			(
			SELECT 1 
			FROM %TABLE:SD2% SD2 (NOLOCK)

			JOIN %TABLE:SC6% SC6 (NOLOCK) ON SD2.D2_FILIAL = SC6.C6_FILIAL
			AND SD2.D2_PEDIDO = SC6.C6_NUM
			AND SD2.D2_ITEMPV = SC6.C6_ITEM
			AND SC6.C6_BLQ <> 'R'
			AND SC6.%NotDel%

			JOIN %TABLE:ZZW% ZZW (NOLOCK) ON SC6.C6_FILIAL = ZZW.ZZW_FILIAL
			AND SC6.C6_NUM = ZZW.ZZW_PEDIDO
			AND SC6.C6_ITEM = ZZW.ZZW_ITEM			
			AND ZZW.%NotDel%

			JOIN %TABLE:ZZV% ZZV (NOLOCK) ON ZZV.ZZV_FILIAL = ZZW.ZZW_FILIAL
			AND ZZV.ZZV_CARGA = ZZW.ZZW_CARGA
			AND ZZV.ZZV_FIMP <> ''
			AND ZZV.D_E_L_E_T_=''

			JOIN %TABLE:SC9% SC9 (NOLOCK) ON SC9.C9_FILIAL = SC6.C6_FILIAL
			AND SC9.C9_PEDIDO = SC6.C6_NUM
			AND SC9.C9_ITEM = ZZW.ZZW_ITEM
			AND SC9.C9_SEQUEN = ZZW.ZZW_SEQUEN
			AND SC9.C9_AGREG = ZZW.ZZW_CARGA			
			AND SC9.C9_BLCRED = '10'
			AND SC9.C9_BLEST = '10'
			AND SC9.%NotDel%

			WHERE SD2.D2_FILIAL = SF2.F2_FILIAL
			AND SD2.D2_DOC = SF2.F2_DOC
			AND SD2.D2_SERIE = SF2.F2_SERIE
			AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
			AND SD2.D2_LOJA = SF2.F2_LOJA
			AND SD2.%NotDel%
			)
			ORDER BY SF2.F2_SERIE,SF2.F2_DOC

		EndSql
	EndIf
	If (_cAlias)->(!EOF())

		While (_cAlias)->(!EOF())

			If !Empty(_cNotaDe) .And. ((_cAlias)->DOCTO <> SOMA1(_cNotaAte) .Or. (_cAlias)->SERIE <> _cSerie)
				fSendDanfe(_cNotaDe,_cNotaAte, _cSerie)
				_cNotaDe	:= ""
				_cSerie		:= ""	
			EndIf

			If Empty(_cNotaDe)
				_cNotaDe	:=	(_cAlias)->DOCTO
				_cSerie		:=	(_cAlias)->SERIE
			EndIf
			_cNotaAte	:=	(_cAlias)->DOCTO


			(_cAlias)->(DbSkip())

		EndDo

		If !Empty(_cNotaDe) 
			fSendDanfe(_cNotaDe,_cNotaAte,_cSerie)
			_cNotaDe	:=	""
			_cSerie		:=	""
		EndIf

	Else
		ConOut('BACP0011::Não existem Registros a serem processados '+cEmpAnt+'/'+cFilAnt+' - '+ Time())
	EndIf	

Return

Static Function fSendDanfe(_cNotaDe,_cNotaAte, _cSerie)

	Local lEnd	:=	.F.
	Local cUrl

	Local lOk
	Local cAmbiente
	Local cModalidade
	Local cVersao
	Local cRet

	Local oWs

	cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)

	//Busca o Ambiente
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nAmbiente  := 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	lOk			   := execWSRet( oWS, "CFGAMBIENTE")
	If lOk
		cAmbiente := oWS:cCfgAmbienteResult
		FreeOBj(oWs)
	Else
		ConOut('BACP0011::Erro ao Recuperar o Ambiente '+cEmpAnt+'/'+cFilAnt+' - '+ Time() + " - " + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
		FreeOBj(oWs)
		Return
	EndIf

	//Busca a Modalidade
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWs:cModelo	   := "55"
	lOk 		   := execWSRet( oWS, "CFGModalidade" )
	If lOk
		cModalidade:= oWS:cCfgModalidadeResult
		FreeOBj(oWs)
	Else
		ConOut('BACP0011::Erro ao Recuperar a Modalidade '+cEmpAnt+'/'+cFilAnt+' - '+ Time() + " - " + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
		FreeOBj(oWs)
		Return
	EndIf

	//Busca a Versão
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:cVersao    := "0.00"
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	lOk			   := execWSRet( oWs, "CFGVersao" )
	If lOk
		cVersao    := oWS:cCfgVersaoResult
		FreeOBj(oWs)
	Else
		ConOut('BACP0011::Erro ao Recuperar a Versao '+cEmpAnt+'/'+cFilAnt+' - '+ Time() + " - " + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
		FreeOBj(oWs)
		Return
	EndIf

	ConOut('BACP0011::Iniciando Transmissão das DANFES DE: '+_cNotaDe+' ATÉ: '+_cNotaAte+' '+cEmpAnt+'/'+cFilAnt+' - '+ Time())

	cRet	:=	SpedNFeTrf("SF2",_cSerie,_cNotaDe,_cNotaAte,cIDEnt,cAmbiente,cModalidade,cVersao,@lEnd,.F.,.T.)

	ConOut('BACP0011:: ' +cRet +' '+cEmpAnt+'/'+cFilAnt+' - '+ Time())

	ConOut('BACP0011::Finalizando Transmissão das DANFES DE: '+_cNotaDe+' ATÉ: '+_cNotaAte+' '+cEmpAnt+'/'+cFilAnt+' - '+ Time())

Return
