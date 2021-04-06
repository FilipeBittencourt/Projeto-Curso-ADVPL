#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAATGMR
@author Pedro
@since 26/06/20
@version 1.0
@description Rotina para desativação / ativação de sequencia denro de um ano orçamentário 
@type function
/*/

User Function BIAATGMR()

	Private cVersao		:= SPACE(TAMSX3("ZBM_VERSAO")[1]) 
	Private cRevisa		:= SPACE(TAMSX3("ZBM_REVISA")[1])
	Private cAno		:= SPACE(TAMSX3("ZBM_ANOREF")[1]) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private idVersao    := SPACE(TAMSX3("ZBM_VERSAO")[1])
	Private idRevisa    := SPACE(TAMSX3("ZBM_REVISA")[1])
	Private idAnoRef	:= SPACE(TAMSX3("ZBM_ANOREF")[1])
	Private idSequen   	:= SPACE(TAMSX3("ZBM_SEQUEN")[1])

	Filtrar()

Return 

Static Function Filtrar()

	Local nPos				:= 0

	Private aPergs			:= {}
	Private cRefPer		  	:= 'BIAATGMR' + cEmpAnt
	Private cFileName    	:= __cUserID +"_"+ cRefPer

	Private aRetPerg		:= {"","",""}

	aAdd( aPergs ,{1, "Versão:"					,cVersao  ,"","NAOVAZIO()","ZB5",'.T.',50,.T.})
	aAdd( aPergs ,{1, "Revisao:"				,cRevisa  ,"","NAOVAZIO()",""   ,'.T.',50,.T.})
	aAdd( aPergs ,{1, "Ano:"					,cAno     ,"","NAOVAZIO()",""   ,'.T.',50,.T.})

	If !ParamBox(aPergs ,"Filtro -  Habilitar meta GMR", aRetPerg,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	nPos	:= 1
	cVersao				:= ParamLoad(cFileName,,nPos++ 	, cVersao)
	cRevisa				:= ParamLoad(cFileName,,nPos++ 	, cRevisa)
	cAno				:= ParamLoad(cFileName,,nPos++ 	, cAno)

	VerifDados()

Return 

Static Function VerifDados()

	Local cAliasTmp		:= GetNextAlias()
	Local cQuery		:= ""

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 

	AADD(aSays, OemToAnsi( "ATENÇÃO: foram identificadas as seguintes Revisão e Sequência ativas:" ))   
	AADD(aSays, OemToAnsi( "" ))   

	cQuery := " SELECT ZBM_REVISA, "
	cQuery += "        ZBM_SEQUEN, "
	cQuery += "        COUNT(*) CONTAD "
	cQuery += "   FROM " + RetSqlName("ZBM") + " "
	cQuery += "  WHERE ZBM_FILIAL = '" + xFilial('ZBM') + "' "
	cQuery += "    AND ZBM_VERSAO = '" + cVersao + "' "
	cQuery += "    AND ZBM_ANOREF = '" + cAno + "' "
	cQuery += "    AND ZBM_ATIVO = 'S' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery += "  GROUP BY ZBM_REVISA,
	cQuery += "           ZBM_SEQUEN "
	TcQuery cQuery New Alias (cAliasTmp)

	(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())

		AADD(aSays, OemToAnsi( (cAliasTmp)->(ZBM_REVISA) + " / " + (cAliasTmp)->(ZBM_SEQUEN) + "   -   Registros: " + Alltrim(Str((cAliasTmp)->(CONTAD))) ))   

		(cAliasTmp)->(dbSkip())

	End
	(cAliasTmp)->(dbCloseArea())

	AADD(aSays, OemToAnsi( "" ))   
	AADD(aSays, OemToAnsi( "Antes de continuar, REVALIDE os parâmetros, repita o tempo orçamentário e preencha a" ))   
	AADD(aSays, OemToAnsi( "sequência que ficará ATIVA. Deseja Continuar?" ))   

	AADD(aButtons, { 5,.T.,{|| fbRevAtv() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração RECEITA com GMR'), aSays, aButtons ,,,500)

	If lConfirm

		If cVersao + cRevisa + cAno == idVersao + idRevisa + idAnoRef

			ProcDados()

		Else

			MsgALERT("Parâmetros não confere. Favor verificar!!!")

		EndIf

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parametros                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fbRevAtv()

	Local aPergs 	:= {}
	Local cLoad	    := 'fbRevAtv' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := cVersao
	idRevisa        := cRevisa 
	idAnoRef		:= cAno 
	idSequen   		:= space(003) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.T.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.T.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.T.})	
	aAdd( aPergs ,{1,"Sequência para Ativação:"     ,idSequen    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.T.})	

	If ParamBox(aPergs ,"Ativação de Sequencia para GMR",,,,,,,,cLoad,.T.,.T.)      
		idVersao    := ParamLoad(cFileName,,1,idVersao) 
		idRevisa    := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef    := ParamLoad(cFileName,,3,idAnoRef) 
		idSequen    := ParamLoad(cFileName,,4,idSequen) 
	Endif

Return 

Static Function ProcDados()

	Local cQuery			:= ""
	Local msStaExcQy		:= 0
	Local lOk				:= .T.

	Begin Transaction

		cQuery := " UPDATE " + RetSqlName("ZBM") + " "
		cQuery += "    SET ZBM_ATIVO = 'N' "
		cQuery += "  WHERE ZBM_FILIAL = '" + xFilial('ZBM') + "' "
		cQuery += "    AND ZBM_VERSAO = '" + idVersao + "' "
		cQuery += "    AND ZBM_ANOREF = '" + idAnoRef + "' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		msStaExcQy := TcSQLExec(cQuery)
		If msStaExcQy < 0
			Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + TCSQLError() + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )
			lOk := .F.
		EndIf

		If lOk

			cQuery := " UPDATE " + RetSqlName("ZBM") + " "
			cQuery += "    SET ZBM_ATIVO = 'S' "
			cQuery += "  WHERE ZBM_FILIAL = '" + xFilial('ZBM') + "' "
			cQuery += "    AND ZBM_VERSAO = '" + idVersao + "' "
			cQuery += "    AND ZBM_REVISA = '" + idRevisa + "' "
			cQuery += "    AND ZBM_ANOREF = '" + idAnoRef + "' "
			cQuery += "    AND ZBM_SEQUEN = '" + idSequen + "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			msStaExcQy := TcSQLExec(cQuery)
			If msStaExcQy < 0
				Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + TCSQLError() + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )
				lOk := .F.
			EndIf

		EndIf

		If lOk

			MsgINFO("Sequência " + idSequen + " habilitada com sucesso.", "BIAATGMR")

		Else

			DisarmTransaction()
			MsgSTOP("Erro: Nova sequência não habilitada.", "BIAATGMR")

		EndIf

	End Transaction 	

Return
