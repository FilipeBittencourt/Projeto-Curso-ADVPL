#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG118
@author Gabriel Rossi Mafioletti
@since 12/12/2019
@version 1.0 
@description Tela de Inconsistências de Pré-Requisição	
@type function
/*/

User Function BIAFG118()

	Local _oDlg
	Local _aSize    := MsAdvSize(.F.)
	Local _oLayer	:= FWLayer():New()
	Local _oWndTop	:= Nil
	Local _oWndMid1	:= Nil
	Local _oWndMid2	:= Nil
	Local _oWndBot	:= Nil
	Local oFont     := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _aTipos	:= {"1=Baixa Pré-Requisição", "2=Integração Bizagi", "3=Falha Gravação Protheus"}

	Private _aCols		:= {}
	Private _aColsDef	:= {}
	Private _aHeadDef	:= {}

	Private _aHeader	:= {}
	Private _aCSrv		:= {}
	Private _aHSrv		:= {}

	Private oMultiGet1
	Private cMultiGet1  := ""

	Private _aErros	    := {}
	Private _cCtipo	    := "1"

	fMontaHead()
	fMontaCols()



	Define MsDialog _oDlg Title "Inconsistências de Pré-Requisição" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel STYLE nOR( WS_VISIBLE, WS_POPUP )

	_oLayer:Init(_oDlg,.F.,.T.)

	_oLayer:AddLine("LIN_TOP", 15, .F.)
	_oLayer:AddLine("LIN_MID", 70, .F.)
	_oLayer:AddLine("LIN_BOT", 15, .F.)

	_oLayer:AddCollumn("COL_TOP", 100, .T., "LIN_TOP")

	_oLayer:AddWindow("COL_TOP", "WND_TOP", "Opções", 100, .F. ,.T.,, "LIN_TOP", { || })

	_oLayer:AddCollumn("COL_MID1", 60, .T., "LIN_MID")
	_oLayer:AddCollumn("COL_MID2", 40, .T., "LIN_MID")

	_oLayer:AddWindow("COL_MID1", "WND_MID1", "Pré-Requisições", 100, .F. ,.T.,, "LIN_MID", { || })

	_oLayer:AddWindow("COL_MID2", "WND_MID2", "Erros", 100, .F. ,.T.,, "LIN_MID", { || })

	_oWndTop	:=	_oLayer:getWinPanel("COL_TOP","WND_TOP","LIN_TOP")

	_oWndMid1	:=	_oLayer:getWinPanel("COL_MID1","WND_MID1","LIN_MID")

	_oWndMid2	:=	_oLayer:getWinPanel("COL_MID2","WND_MID2","LIN_MID")

	_oLayer:AddCollumn("COL_BOT", 100, .T., "LIN_BOT")

	_oLayer:AddWindow("COL_BOT", "WND_BOT", "Ações", 100, .F. ,.T.,, "LIN_BOT", { || })

	_oWndBot	:=	_oLayer:getWinPanel("COL_BOT","WND_BOT","LIN_BOT")

	@  010,  010 SAY "Tipo:" SIZE 55, 11 OF _oWndTop PIXEL FONT oFont
	@  010,  047 MsComboBox _oCGrupo Var _ccTipo Items _aTipos Size 90, 11 Of _oWndTop Colors 0, 16777215 Pixel ON CHANGE U_BFG118VL()

	_oGetDados := MsNewGetDados():New(0,0,0,0, 0,/*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999,  /*cFieldOK*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, _oWndMid1, _aHeader, _aCols,{ || fAtuErr() })

	_oGetDados:oBrowse:bLDblClick := {|| fUpdate()}

	_oGetDados:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT

	@ 024, 013 GET oMultiGet1 VAR cMultiGet1 OF _oWndMid2 MULTILINE SIZE 246, 113 COLORS 0, 16777215 HSCROLL PIXEL WHEN .F.

	oMultiGet1:Align	:=	CONTROL_ALIGN_ALLCLIENT

	oBtnBar := FwButtonBar():New()
	oBtnBar:Init(_oWndBot, 018, 018, CONTROL_ALIGN_BOTTOM, .T.)
	oBtnBar:AddBtnText('Sair'		, 'Fecha a tela.'									, {|| _oDlg:End() },,,CONTROL_ALIGN_RIGHT, .T.)


	_aColsDef	:= _oGetDados:aCols
	_aHeadDef	:= _oGetDados:aHeader

	ACTIVATE DIALOG _oDlg CENTERED

Return

Static Function fMontaHead()

	Aadd(_aHeader,{" "			  ,"STATUS"   ,"@BMP"             , 2    , 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(_aHeader,{"Doc."         ,"DOC"      ,"@!"               , 15   , 0,       ,      , "C",   , })      	// 1
	aAdd(_aHeader,{"Tipo"         ,"TIPO"     ,"@!"               , 2    , 0,       ,      , "C",   , })      	// 1
	aAdd(_aHeader,{"Emissão"      ,"EMISSAO"  ,"@!"               , 8    , 0,       ,      , "D",   , })      	// 1
	aAdd(_aHeader,{"Matric."      ,"MAT"      ,"@!"               , 8    , 0,       ,      , "C",   , })      	// 1
	aAdd(_aHeader,{"Nome"         ,"NOME"     ,"@!"               , 30   , 0,       ,      , "C",   , })      	// 1
	aAdd(_aHeader,{"Local"        ,"LOCAL"    ,"@!"               , 02   , 0,       ,      , "C",   , })      	// 1

Return

Static Function fMontaCols()

	Local _cAlias	:= GetNextAlias()
	Local _cDtRef	:= DtoS(GetMv("MV_YULMES"))
	Local _aRet	  := {}
	Local _cAux   := ""

	_aCols	:=	{}
	_aErros	:=	{}

	If _ccTipo	==	"1"

		BeginSql Alias _cAlias
			SELECT *
			FROM %TABLE:SZI%
			WHERE ZI_FILIAL = %XFILIAL:SZI%
			AND ZI_STTSREQ = 'E'
			AND D_E_L_E_T_ = ''
			AND ZI_BAIXA = 'N'
			AND ZI_EMISSAO > %Exp:_cDtRef%
		EndSql

		While (_cAlias)->(!EOF())

			(_cAlias)->(aAdd(_aCols,{"METAS_BAIXO_LEG", ZI_DOC, ZI_TIPO, Stod(ZI_EMISSAO), ZI_MATRIC, ZI_NOME, ZI_YLOCAL, .F.}))

			aAdd(_aErros,(_cAlias)->R_E_C_N_O_)

			(_cALias)->(DbSkip())

		EndDo

	ElseIf _ccTipo	==	"2"

		/*
		BeginSql Alias _cAlias

			%NoParser%
			SELECT ID 
			,DADOS_ENTRADA DADOS
			,PROCESSO_BIZAGI PROCBIZ
			,CONVERT(VARCHAR(8),CAST(DATA_INTEGRACAO_BIZAGI AS DATETIME), 112) DTBIZ
			FROM BZINTEGRACAO
			WHERE PROCESSO_NOME = 'PRQ'
			AND STATUS = 'ER'			

		EndSql
		*/

		BeginSql Alias _cAlias

			%NoParser%

			SELECT 
			 ID
			,BZNUMPROC AS PROCBIZ
			,TIPO
			,CONVERT(VARCHAR(8),CAST(BZDTINTEGRACAO AS DATETIME), 112) DTBIZ
			,MATRICULA
			,LOCAL

			FROM BZINTEGRACAO_PRE_REQUISICAO 	
						 
			WHERE STATUS = 'E'	

		  ORDER BY PROCBIZ

		EndSql

		While (_cAlias)->(!EOF())

			//_aRet	:=	fDados((_cAlias)->DADOS)

			aAdd(_aErros,(_cAlias)->ID)

			//DbSelectArea("ZZY")
			//DbSetOrder(3)
			//DbSeek(xFilial("ZZY")+(_cAlias)->LOCAL)

			If _cAux <> (_cAlias)->PROCBIZ
				(_cAlias)->(aAdd(_aCols,{"METAS_BAIXO_LEG", PROCBIZ, TIPO, Stod(DTBIZ), MATRICULA, Posicione("ZZY",3,xFilial("ZZY")+MATRICULA,"ZZY_NOME"), LOCAL, .F.}))
			EndIf

			_cAux := (_cAlias)->PROCBIZ

			(_cAlias)->(DbSkip())

		EndDo

	ElseIf _ccTipo	==	"3"

		BeginSql Alias _cAlias

			%NoParser%
			/*
			SELECT ID 			
			,DADOS_ENTRADA DADOS
			,PROCESSO_BIZAGI PROCBIZ
			,CONVERT(VARCHAR(8),CAST(DATA_INTEGRACAO_BIZAGI AS DATETIME), 112) DTBIZ
			FROM BZINTEGRACAO A
			LEFT JOIN %TABLE:SZI% B ON B.[ZI_DOC] = A.[DADOS_RETORNO]
			AND B.[D_E_L_E_T_] = ' '
			WHERE A.[PROCESSO_NOME] = 'PRQ'
			AND A.[DATA_INTEGRACAO_BIZAGI] >= '2019-12-27 00:00:00'
			AND B.[ZI_DOC] IS NULL
			AND A.[STATUS] = 'AP'
			*/

			SELECT
			ID
			,BZNUMPROC AS PROCBIZ
			,TIPO
			,CONVERT(VARCHAR(8),CAST(BZDTINTEGRACAO AS DATETIME), 112) DTBIZ
			,MATRICULA
			,LOCAL
			FROM BZINTEGRACAO_PRE_REQUISICAO A
			LEFT JOIN %TABLE:SZI% B ON B.[ZI_DOC] = A.[DOCUMENTO]
			AND B.[D_E_L_E_T_] = ' '
			WHERE A.[BZDTINTEGRACAO] >= '2019-12-27 00:00:00'
			AND B.[ZI_DOC] IS NULL
			AND A.[STATUS] = 'P'

			ORDER BY PROCBIZ

		EndSql

		While (_cAlias)->(!EOF())

			//	_aRet	:=	fDados((_cAlias)->DADOS)

			aAdd(_aErros,(_cAlias)->ID)

			If _cAux <> (_cAlias)->PROCBIZ
				(_cAlias)->(aAdd(_aCols,{"METAS_BAIXO_LEG", PROCBIZ, TIPO, Stod(DTBIZ), MATRICULA, Posicione("ZZY",3,xFilial("ZZY")+MATRICULA,"ZZY_NOME"), LOCAL, .F.}))
			EndIf

			_cAux := (_cAlias)->PROCBIZ

			(_cAlias)->(DbSkip())

		EndDo

	EndIf

	(_cAlias)->(DbCloseArea())



Return

Static Function fAtuErr()

	Local _aArea    := Nil
	Local _cAlias	  := Nil
	Local cPROCBIZ   := ""

	_aArea := SZI->(GetArea())
	_cAlias	:=	GetNextAlias()

	cMultiGet1	:=	""

	If Len(_aerros)  > 0

		If _ccTipo	==	"1"

			SZI->(DbGoTo(_aerros[_oGetDados:nAt]))

			If SZI->(!EOF())
				cMultiGet1	:=	SZI->ZI_ERROLOG
			EndIf

		ElseIf _ccTipo	==	"2"

			cPROCBIZ   :=  _oGetDados:Acols[_oGetDados:nAt,2]
			/*BeginSql Alias _cAlias
				SELECT LOG RET
				FROM BZINTEGRACAO_PRE_REQUISICAO 
				WHERE ID = %Exp:_aerros[_oGetDados:nAt]%
			EndSql*/
			
			BeginSql Alias _cAlias
				SELECT LOG RET
				FROM BZINTEGRACAO_PRE_REQUISICAO 
				WHERE BZNUMPROC = %Exp:cPROCBIZ%
			EndSql

			While (_cAlias)->(!EOF())

				cMultiGet1	+=	(_cAlias)->RET +CRLF
			  (_cAlias)->(DbSkip())

			EndDo

			(_cAlias)->(DbCloseArea())

		ElseIf _ccTipo	==	"3"

			cMultiGet1	:=	""

			If Len(_oGetDados:aCols) > 0

				If _oGetDados:aCols[_oGetDados:nAt,1] == "METAS_BAIXO_LEG"
					cMultiGet1	:=	"FALHA DE INTEGRACAO - ROLLBACK (REVERSAO) INADEQUADA"
				EndIf

			EndIf

		EndIf

	EndIf

	cMultiGet1 := StrTran( cMultiGet1, "<br>", "" )
	cMultiGet1 := StrTran( cMultiGet1, "<br/>", "" )
	cMultiGet1 := StrTran( cMultiGet1, "</b>", "" )
	cMultiGet1 := StrTran( cMultiGet1, "<b>", "" )

	oMultiGet1:Refresh()
	RestArea(_aArea)

Return()

Static Function fUpdate()

	Local _nAt	:=	_oGetDados:nAt
	Local _nCol	:=	_oGetDados:oBrowse:COLPOS
	Local _aArea	:= SZI->(GetArea())

	If _nCol == 1 .And. _oGetDados:aCols[_nAt,1] == "METAS_BAIXO_LEG"

		If _ccTipo	==	"1"

			SZI->(DbGoTo(_aerros[_oGetDados:nAt]))
			If SZI->(!EOF())
				If SZI->ZI_BAIXA <> "S" .And. SZI->ZI_BAIXA <> "X"
					Reclock("SZI",.F.)
					SZI->ZI_STTSREQ :=	"F"
					SZI->ZI_ERROLOG	:=	""
				Else
					MsgAlert("Registro já Baixado/Cancelado!")
				EndIf
				_oGetDados:aCols[_nAt,1] := "METAS_CIMA_LEG"
			EndIf

		Else

		//	_cSql	:=	"UPDATE BZINTEGRACAO_PRE_REQUISICAO SET STATUS = 'A' WHERE ID = " + Alltrim(Str(_aerros[_oGetDados:nAt]))

		_cSql	:=	"UPDATE BZINTEGRACAO_PRE_REQUISICAO SET STATUS = 'A' WHERE BZNUMPROC = '"+Alltrim(_oGetDados:Acols[_oGetDados:nAt,2])+"'"
		
			TcSqlExec(_cSql)
			_oGetDados:aCols[_nAt,1] := "METAS_CIMA_LEG"



		EndIf

	EndIf

	_oGetDados:Refresh()

	RestArea(_aArea)

Return

User Function BFG118VL()

	U_BIAMsgRun("Aguarde... Carregando dados",,{|| fRefresh() })

Return

Static Function fRefresh()

	cMultiGet1	:=	""

	fMontaCols()

	_oGetDados:aCols := _aCols

	If Len(_aCols) == 0

		_oGetDados:aHeader := _aHeadDef
		_oGetDados:aCols := _aColsDef // Array Default que precisa ter  o mesmo tamanho do array _aCols

	EndIf

	oMultiGet1:Refresh()
	_oGetDados:Refresh()

Return

Static Function fDados(_cDados)

	Local _aRet	:=	{;
		{},; //Cabeçalho
	{};  //Itens
	}

	Local _aDados	:=	{}
	Local _aItens	:=	{}

	Local _nI

	_aDados	:=	StrtoKArr(Alltrim(_cDados),";")

	DO CASE
	CASE Alltrim(_aDados[5]) $ "DU_DN_RE"
		aAdd(_aRet[1],_aDados[5])
	OTHERWISE
		aAdd(_aRet[1],"RE")
	ENDCASE

	aAdd(_aRet[1],_aDados[6]) //Classe de Valor
	aAdd(_aRet[1],_aDados[2]) //Matrícula

	If Len(_aDados) >= 11
		aAdd(_aRet[1],Iif(Alltrim(_aDados[10]) == 'null','',_aDados[10]))
		aAdd(_aRet[1],Iif(Alltrim(_aDados[11]) == 'null','',_aDados[11]))
	Else
		aAdd(_aRet[1],"")
		aAdd(_aRet[1],"")
	EndIf

	/*
	_aDados[9] - Itens
	1 - Código Produto
	2 - Quantidade
	3 - Local
	4 - Conta
	5 - Tag
	6 - Aplicação
	7 - Melhoria
	8 - Driver
	9 - Justificativa Driver
	10 - Parada
	*/

			_aItens	:=	StrToKArr(REPLACE(REPLACE(_aDados[9],"[",""),"]",""),"&")

			For _nI	:=	1 to Len(_aItens)
				aAdd(_aRet[2],StrToKarr(_aItens[_nI],"|"))
			Next

			Return _aRet
