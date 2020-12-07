#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG062
@author Gabriel Rossi Mafioletti
@since 04/09/2018
@version 1.0
@description Manutenção - Custo Unitário Orçamento
@type function
/*/

USER FUNCTION BIAFG062()

	If !Validperg()
		Return
	EndIf


	DbSelectArea('ZCH')

	Set filter to ZCH_VERSAO == MV_PAR01 .And. ZCH_REVISA == MV_PAR02 .And. ZCH_ANOREF == MV_PAR03

	AxCadastro("ZCH","Custo Uniário Orçamento", , "U_BFG062IN()")

Return

User Function BFG062IN()

	Local _lRet	:=	.T.
	Local _cAlias	:=	GetNextAlias()

	If INCLUI

		BeginSql Alias _cAlias

			SELECT COUNT(*) QTD 
			FROM %TABLE:ZCH% ZCH
			WHERE ZCH_FILIAL = %XFILIAL:ZCH%
			AND ZCH_VERSAO = %Exp:M->ZCH_VERSAO%
			AND ZCH_REVISA = %Exp:M->ZCH_REVISA%
			AND ZCH_ANOREF = %Exp:M->ZCH_ANOREF%
			AND ZCH_CODPRO = %Exp:M->ZCH_CODPRO%
			AND %NOTDEL%

		EndSql

		If (_cAlias)->QTD > 0
			MsgInfo("O Produto já se encontra cadastrado no orçamento atual.")
			_lret	:=	 .F.
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	If _lRet .And. ALTERA .And. ZCH->ZCH_CUSMAN <> M->ZCH_CUSMAN
		M->ZCH_HISTOR	:= Alltrim(M->ZCH_HISTOR) + DtoC(Date()) + "-" + cUserName + "-R$" + ALLTRIM(STR(ZCH->ZCH_CUSMAN)) + "-R$" + ALLTRIM(STR(M->ZCH_CUSMAN)) + "-" + Alltrim(M->ZCH_OBSERV) + CHR(13)+CHR(10)
	EndIF

Return _lRet

Static Function ValidPerg()

	local cLoad	    := "BIAFG062" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(10)
	MV_PAR02 := SPACE(3)
	MV_PAR03 := SPACE(4)

	aAdd( aPergs ,{1,"Orçamento " 		  	,MV_PAR01 ,""  ,"EXISTCPO('ZB5')",'ZB5'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Revisão " 		  	,MV_PAR02 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Ano Ref. " 		  	,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})

	If ParamBox(aPergs ,"Custo Unitário Orçamento",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)

	EndIf

Return lRet
