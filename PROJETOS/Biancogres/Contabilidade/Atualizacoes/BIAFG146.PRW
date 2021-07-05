#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG146
@author Marcos Alberto Soprani
@since 04/05/2020
@version 1.0
@description Integração entre as tabelas CLK e SYD   
@type function
/*/


User Function BIAFG146()

	PRIVATE _nTamDesc	:=	TamSx3("YD_DESC_P")[1]

U_BIAMsgRun("Aguarde... Alterando os NCM's",,{|| fAltNCM() })
U_BIAMsgRun("Aguarde... Incluindo novos NCM's",,{|| fIncNCM()})

Return


Static Function fAltNCM()

	Local _cAlias	:=	GetNextAlias()
	Local _nReg		:=	0

	BeginSql Alias _cAlias
		%NoParser%
		SELECT UPPER(SUBSTRING(REPLACE(CLK.CLK_DESCR, '"', ''), 1, %Exp:_nTamDesc%)) DESCRI
			,SYD.R_E_C_N_O_ REGID
		FROM %TABLE:CLK% CLK WITH (NOLOCK)
		JOIN %TABLE:SYD% SYD WITH (NOLOCK) ON CLK.CLK_CODNCM = SYD.YD_TEC
		WHERE UPPER(SUBSTRING(REPLACE(CLK.CLK_DESCR, '"', ''), 1, %Exp:_nTamDesc%)) <> UPPER(SUBSTRING(SYD.YD_DESC_P, 1, %Exp:_nTamDesc%))
			AND CLK.CLK_EX = ''
			AND CLK_CODNCM <> ''
			AND CLK_CODNBS = ''
			AND CLK.%NotDel%
			AND SYD.%NotDel%
	
	EndSql

	While (_cAlias)->(!EOF())
		SYD->(DbgoTo((_cAlias)->REGID))
		IF SYD->(!EOF())
			Reclock("SYD",.F.)
			SYD->YD_DESC_P	:=	(_cAlias)->DESCRI
			SYD->YD_GRVUSER	:=	'ALTJOB'
			SYD->YD_GRVDATA	:=	Date()
			SYD->YD_GRVHORA	:=	Time()
			SYD->(MsUnlock())
			
			_nReg++
		EndIf
		(_cAlias)->(DbSkip())
	EndDo

	MsgInfo("Foram Alterados " + Alltrim(Str(_nReg)) + ' registros')

	(_cAlias)->(DbCloseArea())
Return

Static Function fIncNCM()

	Local _cAlias	:=	GetNextAlias()
	Local _nReg		:=	0

	BeginSql Alias _cAlias
		%Noparser%
		SELECT *,UPPER(SUBSTRING(REPLACE(CLK.CLK_DESCR, '"', ''), 1, %Exp:_nTamDesc%)) DESCRI
		FROM %TABLE:CLK% CLK WITH (NOLOCK)
		WHERE NOT EXISTS (
				SELECT 1
				FROM %TABLE:SYD% SYD WITH (NOLOCK)
				WHERE CLK.CLK_CODNCM = SYD.YD_TEC
					AND SYD.%NotDel%
				)
			AND CLK_EX = ''
			AND CLK_CODNCM <> ''
			AND CLK_CODNBS = ''	
			AND CLK.%NotDel%
	
	EndSql

	While (_cAlias)->(!EOF())
		Reclock("SYD",.T.)
			SYD->YD_FILIAL	:=	xFilial("SYD")
			SYD->YD_TEC		:=	(_cAlias)->CLK_CODNCM
			SYD->YD_DESC_P	:=	(_cAlias)->DESCRI
			SYD->YD_GRVUSER	:=	'INCJOB'
			SYD->YD_GRVDATA	:=	Date()
			SYD->YD_GRVHORA	:=	Time()
			SYD->YD_MSBLQL	:=	'1'
		SYD->(MsUnlock())
		_nReg++
		(_cAlias)->(DbSkip())
	EndDo
	
	MsgInfo("Foram Inseridos " + Alltrim(Str(_nReg)) + ' registros')
		
	(_cAlias)->(DbCloseArea())
Return