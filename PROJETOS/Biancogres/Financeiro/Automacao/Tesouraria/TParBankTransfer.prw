#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TParBankTransfer
@author Tiago Rossini Coradini
@since 15/07/2019
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina transferencia bancaria
@type function
/*/

STATIC _Self := Nil

Class TParBankTransfer From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cBanco // Numero do banco
	Data cAgencia // Agencia
	Data cConta // Conta corrente

	Data dData
	Data cBcoOri
	Data cAgOri
	Data cCcOri
	Data cNatOri	
	Data cBcoDes
	Data cAgDes
	Data cCcDes
	Data cNatDes
	Data cTipTra
	Data cNumChe
	Data nValor
	Data cHistorico
	Data cBenef
	
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()
	Method Validate()
	Method VldBank()
	Method RunTrigger()
	Method Clear()
	Method GetNumTrf()
	
EndClass


Method New() Class TParBankTransfer
	
	::cName := cEmpAnt + "_" + GetClassName(Self)
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.
	
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""

	::dData := dDataBase
	::cBcoOri := Space(TamSx3("E5_BANCO")[1])
	::cAgOri := Space(TamSx3("E5_AGENCIA")[1])
	::cCcOri := Space(TamSx3("E5_CONTA")[1])
	::cNatOri	:= Space(TamSx3("E5_NATUREZ")[1])
	::cBcoDes := Space(TamSx3("E5_BANCO")[1])
	::cAgDes := Space(TamSx3("E5_AGENCIA")[1])
	::cCcDes := Space(TamSx3("E5_CONTA")[1])
	::cNatDes := Space(TamSx3("E5_NATUREZ")[1])
	::cTipTra := "R$"
	::cNumChe := ::GetNumTrf()
	::nValor := 0
	::cHistorico := Space(TamSx3("E5_HISTOR")[1])
	::cBenef := SubStr(AllTrim(FWFilRazSocial()), 1, TamSx3("E5_BENEF")[1])
	
	_Self := Self	
		
Return()


Method Add() Class TParBankTransfer

	aAdd(::aParam, {1, "Data Transf.", ::dData, "@D", ".T.",,".F.", 50, .T.})
	aAdd(::aParam, {9, "|Origem " + Replicate("-", 67) + "|", 200,, .T.})
  aAdd(::aParam, {1, "Banco", ::cBcoOri, "@!", "ExistCpo('SA6', MV_PAR03) .And. U_BAF031B()", "SA6", ".T.",, .T.})
  aAdd(::aParam, {1, "Agência", ::cAgOri, "@!", ".T.",, ".T.",,.T.})		
  aAdd(::aParam, {1, "Conta", ::cCcOri, "@!", ".T.",, ".T.",,.T.})
	aAdd(::aParam, {1, "Natureza", ::cNatOri, "@!", "ExistCpo('SED', MV_PAR06) .And. U_BAF031B()", "SED", ".T.", 50, .T.})

	aAdd(::aParam, {9, "|Destino " + Replicate("-", 65) + "|", 200,, .T.})
  aAdd(::aParam, {1, "Banco", ::cBcoDes, "@!", "ExistCpo('SA6', MV_PAR08) .And. U_BAF031B()", "SA6", ".T.",, .T.})
  aAdd(::aParam, {1, "Agência", ::cAgDes, "@!", ".T.",, ".T.",,.T.})
  aAdd(::aParam, {1, "Conta", ::cCcDes, "@!", ".T.",, ".T.",,.T.})
	aAdd(::aParam, {1, "Natureza", ::cNatDes, "@!", "ExistCpo('SED', MV_PAR11) .And. U_BAF031B()", "SED", ".T.", 50, .T.})
	
	aAdd(::aParam, {9, "|Identificação " + Replicate("-", 60) + "|", 200,, .T.})
	aAdd(::aParam, {1, "Tipo Mov.", ::cTipTra, "@!", "ExistCpo('SX5', '14' + MV_PAR13)", "14", ".T.", 50, .T.})
	aAdd(::aParam, {1, "Numero Doc.", ::cNumChe, "@!", ".T.",,".F.", 50, .T.})	
	aAdd(::aParam, {1, "Valor", ::nValor, X3Picture("E5_VALOR"), ".T.",,".T.", 50, .T.})
	aAdd(::aParam, {1, "Historico", ::cHistorico, "@!", ".T.",,".T.", 100, .T.})
	aAdd(::aParam, {1, "Beneficiario", ::cBenef, "@!", ".T.",,".T.", 100, .T.})
		
Return()


Method Box() Class TParBankTransfer
Local lRet := .F.
Private cCadastro := "Transferência Bancária"
	
	::Add()
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Inclusão", ::aParRet, ::bConfirm,,,,,,::cName, .F., .F.)
		
		lRet := .T.
			
		::cBcoOri := ::aParRet[3]
		::cAgOri := ::aParRet[4]
		::cCcOri := ::aParRet[5]
		::cNatOri	:= ::aParRet[6]
		
		::cBcoDes := ::aParRet[8]
		::cAgDes := ::aParRet[9]
		::cCcDes := ::aParRet[10]
		::cNatDes := ::aParRet[11]
		
		::cTipTra := ::aParRet[13]
		::cNumChe := ::aParRet[14]
		::nValor := ::aParRet[15]
		::cHistorico := ::aParRet[16]
		::cBenef := ::aParRet[17]
				
	EndIf
	
Return(lRet)


Method Update() Class TParBankTransfer
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Validate() Class TParBankTransfer
Local lRet := .T.

	lRet := ::VldBank()

Return(lRet)


Method VldBank() Class TParBankTransfer
Local lRet := .T.

	If !(lRet := (::cBanco == MV_PAR03 .And. ::cAgencia == MV_PAR04 .And. ::cConta == MV_PAR05) .Or. (::cBanco == MV_PAR08 .And. ::cAgencia == MV_PAR09 .And. ::cConta == MV_PAR10))

		MsgStop("Atenção, o banco da conciliação não confere com os bancos de origem e/ou destino informados.")
	
	ElseIf !(lRet := !(MV_PAR03 == MV_PAR08 .And. MV_PAR04 == MV_PAR09 .And. MV_PAR05 == MV_PAR10))

		MsgStop("Atenção, os bancos de origem/destino são iguais.")
					
	EndIf

Return(lRet)


Method RunTrigger() Class TParBankTransfer
Local cNatOri := AllTrim(MV_PAR06)
Local cNatTrf := Upper(GetNewPar("MV_YNATTRF", "2904/1225"))
Local cNatRes := Upper(GetNewPar("MV_YNATRES", "2903"))

	::Clear()
	
	If !Empty(MV_PAR03) .And. !Empty(MV_PAR08) .And. (cNatOri $ cNatTrf .Or. cNatOri == cNatRes)
	
		MV_PAR16 := If (cNatOri $ cNatTrf, "TRANSFERENCIA", "RESGATE") + Space(1) + "BCO:" + Space(1) + MV_PAR03 + Space(1) + "X" + Space(1) + MV_PAR08
				
	EndIf
		
Return(.T.)


Method Clear() Class TParBankTransfer
	
	MV_PAR16 := ::cHistorico
					
Return()


Method Confirm() Class TParBankTransfer
Local lRet := .T.
		
	lRet := ::Validate()
		
Return(lRet)


Method GetNumTrf() Class TParBankTransfer
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(MAX(E5_NUMCHEQ), 'TRF000000') AS E5_NUMCHEQ "
	cSQL += " FROM " + RetSQLName("SE5")
	cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))	
	cSQL += " AND E5_TIPODOC = 'TR' "
	cSQL += " AND SUBSTRING(E5_NUMCHEQ, 1, 3) = 'TRF' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	cRet := Soma1(AllTrim((cQry)->E5_NUMCHEQ))
	
	(cQry)->(DbCloseArea())
		
	While !MayIUseCode(cEmpAnt + cFilAnt + cRet)
		
		cRet := Soma1(cRet)
		
	EndDo	
		
Return(cRet)


User Function BAF031B()
Local lRet := .T.
	
	lRet := _Self:RunTrigger()
	
Return(lRet)