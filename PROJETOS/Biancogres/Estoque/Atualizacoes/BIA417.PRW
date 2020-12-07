#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} BIA417
@author WANISAY WILLIAM
@since 24/03/08
@description AXCADASTRO CADASTRO DE LOTES
@type function
/*/

User Function BIA417()

	AxCadastro("ZZ9","CADASTRO DE LOTES DO PRODUTO",,"U_B417ALT()")

Return

User Function B417Alt()

	Local xpRetn

	xpRetn := .T.

	If INCLUI 

		If M->ZZ9_RESTRI == "#"
			M->ZZ9_EMPBLQ	:=	Date()
		ElseIf M->ZZ9_RESTRI <> "#"
			M->ZZ9_EMPLIB	:=	Date()
			fUpdSd3(.T.)
		EndIf

	ElseIf ALTERA

		If M->ZZ9_RESTRI == "#" .AND. ZZ9->ZZ9_RESTRI <> "#"
			M->ZZ9_EMPBLQ	:=	Date()
			M->ZZ9_EMPLIB	:=	Stod('')
			fUpdSd3(.F.)
		ElseIf M->ZZ9_RESTRI <> "#" .And. M->ZZ9_RESTRI <> ZZ9->ZZ9_RESTRI
			M->ZZ9_EMPLIB	:=	Date()
			fUpdSd3(.T.)
		EndIf

	EndIf

	If M->ZZ9_RESTRI == "*"

		If Substr(M->ZZ9_LOTE, 1, 1) >= "A"

			If Empty(M->ZZ9_MOTIVO)
				xpRetn := .F.
				MsgAlert("Necessário informar o Motivo da restrição.", "BIA417")
			EndIf

		EndIf

	EndIf 

Return ( xpRetn )

Static function fUpdSd3(_lLibera)

	Local _cAlias	:=	GetNextAlias()
	Local _mAlias	:=	GetNextAlias()
	Local _cEmissao	:=	DToS(GetMV("MV_ULMES"))

	//**************************************************************
	BeginSql Alias _cAlias

		SELECT R_E_C_N_O_ as REGSD3 
		FROM %TABLE:SD3% SD3
		WHERE D3_FILIAL = %XFILIAL:SD3%
		AND D3_COD = %EXP:M->ZZ9_PRODUT%
		AND D3_LOTECTL = %EXP:M->ZZ9_LOTE%
		AND D3_EMISSAO > %Exp:_cEmissao%
		AND SD3.%NotDel% 
	EndSql

	While (_cAlias)->(!EOF())

		SD3->(DbGoTo((_cAlias)->REGSD3))
		Reclock("SD3",.F.)
		SD3->D3_YEMPLIB	:=	Iif(_lLibera, M->ZZ9_EMPLIB, StoD(""))
		SD3->(MsUnlock())
		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

	//**************************************************************
	BeginSql Alias _mAlias

		SELECT R_E_C_N_O_ as REGZ18
		FROM Z18010 Z18
		WHERE Z18_FILIAL = %XFILIAL:Z18%
		AND Z18_COD = %EXP:M->ZZ9_PRODUT%
		AND Z18_DATA > %Exp:_cEmissao%
		AND Z18_DOCSD3 IN(SELECT D3_DOC
		FROM %TABLE:SD3% SD3
		WHERE D3_FILIAL = %XFILIAL:SD3%
		AND D3_COD = %EXP:M->ZZ9_PRODUT%
		AND D3_LOTECTL = %EXP:M->ZZ9_LOTE%
		AND D3_EMISSAO > %Exp:_cEmissao%
		AND SD3.D_E_L_E_T_ = ' ')
		AND Z18.D_E_L_E_T_ = ' '
	EndSql

	While (_mAlias)->(!EOF())

		Z18->(dbGoTo((_mAlias)->REGZ18))
		Reclock("Z18",.F.)
		Z18->Z18_YEMPLI	:=	Iif(_lLibera, M->ZZ9_EMPLIB, StoD(""))
		Z18->(MsUnlock())
		(_mAlias)->(dbSkip())

	EndDo

	(_mAlias)->(dbCloseArea())

Return
