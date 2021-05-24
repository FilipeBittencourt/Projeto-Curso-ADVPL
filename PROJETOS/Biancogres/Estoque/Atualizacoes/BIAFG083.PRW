#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG083
@author Gabriel Rossi Mafioletti
@since 03/05/2019
@version 1.0
@description Baixa de Pre-Requisição	
@type function
/*/

User Function BIAFG083()

	Local _cAlias
	Local _cDoc		:=	""
	Local _aCab		:=	{}
	Local _aItens	:= {}
	Local _aLinha	:=	{}
	Local cTm
	Local cConta
	Local cSql
	Local _cObs	:=	""
	Local msRetGrv	:=	.T.

	RpcSetType(3)
	RpcSetEnv("01","01")

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YBLQRCM")
		CriarSX6("MV_YBLQRCM", 'L', 'Controle de Bloqueio de Rotinas do CMV', ".F." )
	EndIf

	If GetMv("MV_YBLQRCM")
		MsgInfo("Rotina bloqueada para execução pois o parâmetro do bloqueio para CMV está ativado!","BIAFG083")
		Return
	EndIF	

	nHandle := fCreate('BIAFG083.$$$')

	If(nHandle == -1)

		ConOut('BIAFG083::há outro processo em execução. Finalizando este.')
		Return

	Endif 

	Private _ExecAutoII	:= .T.

	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT *,SZI.R_E_C_N_O_ RECSZI, SZJ.R_E_C_N_O_ RECSZJ
		FROM %TABLE:SZI% SZI
		JOIN %TABLE:SZJ% SZJ ON SZI.ZI_FILIAL = SZJ.ZJ_FILIAL
		AND SZI.ZI_DOC = SZJ.ZJ_DOC
		AND SZJ.ZJ_MTNCONF = ''
		AND SZJ.%NotDel%
		JOIN %TABLE:SB1% SB1 ON SB1.B1_COD = SZJ.ZJ_COD
		AND SB1.%NotDel%
		WHERE SZI.ZI_BAIXA NOT IN ('S', 'X')
		AND SZI.ZI_TIPO <> 'TR'
		AND SZI.ZI_STTSREQ = 'F'
		AND SZI.%NotDel%
		ORDER BY ZI_DOC

	EndSql

	BEGIN TRANSACTION

		If (_cAlias)->(!EOF())

			While (_cAlias)->(!EOF())

				If _cDoc <> (_cAlias)->ZI_DOC

					If !Empty(_cDoc)

						//Baixa de consumo interno na mesma empresa
						If Len(_aItens) > 0

							//Baixa Requisicao conforme empresa
							msRetGrv := GravaSD3(_aCab,_aItens)

						EndIf

					EndIf

					If Alltrim((_cAlias)->ZI_TIPO) == "RE"

						cTm := "502"

					Else

						If Alltrim((_cAlias)->ZI_TIPO) == "DN"

							cTm := "005"

						Else

							cTm := "006"

						EndIf

					EndIf

					cTempo      := Time()
					dDataEmis   := Iif(cTempo >= '00:00:00' .And. cTempo <= '05:59:59', DaySub(dDatabase,1), dDataBase)
					cDataHora	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"

					_aCab :=	{	{"D3_DOC"     ,(_cAlias)->ZI_DOC		, NIL},;
					{                "D3_TM"      ,cTM			            , NIL},;
					{                "D3_CC"      ,(_cAlias)->ZI_CC			, NIL},;
					{                "D3_CLVL"    ,(_cAlias)->ZI_CLVL 		, NIL},;
					{                "D3_EMISSAO" ,dDataEmis	            , NIL}}

					_cDoc	:=	(_cAlias)->ZI_DOC
					_aItens	:=	{}

				EndIf

				//Validação de Conta contábil
				cConta	:= "" 
				If U_B478RTCC((_cAlias)->ZI_CLVL)[2] == "D"
					cConta	:= (_cAlias)->B1_YCTRADM

				ElseIf U_B478RTCC((_calias)->ZI_CLVL)[2] == "C"
					cConta  := (_cAlias)->B1_YCTRIND

				ElseIf U_B478RTCC((_calias)->ZI_CLVL)[2] $ "A/I"
					cConta  := "16503" + Substr( (_calias)->ZI_CLVL, 2, 8)

				EndIf

				IF (_cAlias)->ZJ_APLIC == '4' .AND. !EMPTY((_cAlias)->ZJ_YMELHOR) .AND. Subs((_cAlias)->ZI_CLVL,1,1) == "3"
					cConta := '61301010'
				ENDIF

				If (_cAlias)->B1_GRUPO == '107A' .Or. (_cAlias)->B1_GRUPO == '107E' 
					If Alltrim((_cAlias)->ZI_CLVL) == "3117" .Or. Alltrim((_cAlias)->ZI_CLVL) == "3135" .Or. Alltrim((_cAlias)->ZI_CLVL) == "3217"
						cConta :=	"61110006" 
					ElseIf Alltrim((_cAlias)->ZI_CLVL) == "3136" 
						cConta	:=	"61110001"
					EndIf
				EndIf				

				_aLinha	:=	{}
				aAdd(_aLinha,{"D3_COD"	  	,(_cAlias)->ZJ_COD		    ,NIL})
				aAdd(_aLinha,{"D3_UM"	  	,(_cAlias)->B1_UM		    ,NIL})
				aAdd(_aLinha,{"D3_QUANT"  	,(_cAlias)->ZJ_QUANT    	,NIL})
				aAdd(_aLinha,{"D3_LOCAL"  	,(_cAlias)->ZJ_LOCAL		,NIL})

				If Alltrim((_cAlias)->ZI_TIPO) == "DU"
					aAdd(_aLinha,{"D3_CUSTO1" 	,0.01					,NIL})
				EndIf

				_cObs	:=	"BX PREREQ REG - SZI: "+Alltrim(Str((_cAlias)->RECSZI))+", REG SZJ: "+Alltrim(Str((_cAlias)->RECSZJ))

				aAdd(_aLinha,{"D3_CONTA" 	,cConta						,NIL})
				aAdd(_aLinha,{"D3_CC"		,(_cAlias)->ZI_CC  			,NIL})
				aAdd(_aLinha,{"D3_CLVL"		,(_cAlias)->ZI_CLVL			,NIL})
				aAdd(_aLinha,{"D3_YMATRIC"	,(_cAlias)->ZI_MATRIC		,NIL})
				aAdd(_aLinha,{"D3_YMATORI"	,(_cAlias)->ZJ_YMATORI		,NIL})
				aAdd(_aLinha,{"D3_ITEMCTA"	,(_cAlias)->ZI_ITEMCTA		,NIL})
				aAdd(_aLinha,{"D3_SEGUM"  	,(_cAlias)->B1_SEGUM		,NIL})
				aAdd(_aLinha,{"D3_YTAG"  	,(_cAlias)->ZJ_TAG		    ,NIL})
				aAdd(_aLinha,{"D3_YMELHOR"	,(_cAlias)->ZJ_YMELHOR	    ,NIL})
				aAdd(_aLinha,{"D3_YAPLIC" 	,(_cAlias)->ZJ_APLIC		,NIL})
				aAdd(_aLinha,{"D3_YDRIVER" 	,(_cAlias)->ZJ_YDRIVER	    ,NIL})
				aAdd(_aLinha,{"D3_YROM"  	,"N"						,NIL})
				aAdd(_aLinha,{"D3_YCHAVE"	,""							,NIL})
				aAdd(_aLinha,{"D3_YPARADA"	,(_cAlias)->ZJ_YPARADA 	    ,NIL})
				aAdd(_aLinha,{"D3_YDHMOV"	,cDataHora           	    ,NIL})
				aAdd(_aLinha,{"D3_YOBS"		,_cObs           	    	,NIL})
				aAdd(_aLinha,{"D3_YSUBITE"		,(_cAlias)->ZI_YSUBITE          	    	,NIL})
				aAdd(_aLinha,{"D3_USUARIO"	,"PREREQ"          	    	,NIL})

				aAdd(_aItens,_aLinha)

				If Alltrim((_cAlias)->ZI_TIPO) == "RE"

					cSql := "UPDATE " + RetSqlName("SB2") + " SET B2_RESERVA = B2_RESERVA - " + Alltrim(Str((_cAlias)->ZJ_QTAPROV)) + " WHERE B2_COD = '" + (_cAlias)->ZJ_COD + "' AND B2_LOCAL = '" + (_cAlias)->ZJ_LOCAL + "' AND D_E_L_E_T_ = ' ' "
					TcSQLExec(cSQL)

				EndIf

				(_cAlias)->(DbSkip())

			EndDo

			//Baixa de consumo interno na mesma empresa
			If Len(_aItens) > 0

				//Baixa Requisicao conforme empresa
				msRetGrv := GravaSD3(_aCab,_aItens)

			EndIf

		EndIf

		(_cAlias)->(DbCloseArea())

		// Caso tenha ocorrido algum problema na baixa, desarma a transação
		If msRetGrv == .F.
			DisarmTransaction()
		EndIf

	END TRANSACTION

	fClose(nHandle)

	RpcClearEnv()

Return

Static Function GravaSD3(aCab, aItem)

	Local msRet := .T.
	Local cSql	:=	""

	Local _aAutoErro

	Private lMsHelpAuto	:= .T.
	Private lMsErroAuto	:= .F.
	Private lAutoErrNoFile := .T.
	Private _cLogTxt 		:= ""
	Private _ExecAutoII	:= .T. //Variavel para desativar Execblock velhos

	MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItem)

	If lMsErroAuto

		_aAutoErro := GETAUTOGRLOG()
		_cLogTxt += U_XCONVELOG(_aAutoErro)

		cSql := "UPDATE " + RetSqlName("SZI") + " SET ZI_BAIXA = 'N', ZI_STTSREQ = 'E', ZI_ERROLOG = '" + _cLogTxt + "' WHERE ZI_DOC = '" + aCab[1][2] + "' AND D_E_L_E_T_ = ' ' "
		TcSQLExec(cSQL)

		msRet := .F.

	Else

		cSql := "UPDATE " + RetSqlName("SZI") + " SET ZI_BAIXA = 'S', ZI_STTSREQ = 'P', ZI_ERROLOG = '" + _cLogTxt + "', ZI_DTBAIXA = " + ValtoSql(Date()) + ", ZI_HRBAIXA = " + ValtoSql(SUBSTR(Time(),1,5)) + " WHERE ZI_DOC = '" + aCab[1][2] + "' AND D_E_L_E_T_ = ' ' "
		TcSQLExec(cSQL)

	EndIf

Return( msRet )
