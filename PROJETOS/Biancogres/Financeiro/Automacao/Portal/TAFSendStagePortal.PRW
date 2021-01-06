#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TAFSendStagePortal
@description Classe para enviar para stage area do Portal de Cliente os Boletos a Receber
@author Fernando Rocha
@since 01/10/2019
@version 1.0
@type class
/*/

Class TAFSendStagePortal from LongClassName

	Data cCodEmp
	Data cCodFil
	Data cCNPJ

	Data oCedente
	Data oLote

	Method New(cCodEmp, cCodFil) Constructor

	Method SendStage()

EndClass


Method New(cCodEmp, cCodFil) Class TAFSendStagePortal

	::cCodEmp	:= cCodEmp
	::cCodFil	:= cCodFil

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))

	::cCNPJ := SM0->M0_CGC

	::oCedente	:= Nil
	::oLote		:= Nil

Return()


Method SendStage() Class TAFSendStagePortal

	Local nCount
	Local cDBSERVER := If(Upper(AllTrim(GetSrvProfString("DbAlias", ""))) == "PRODUCAO", GetNewPar("FA_BPDBSRV","HADES"), GetNewPar("FA_BPDBSRV","POTHOS")) // Ticket: 29154
	Local cDBSA 	:= GetNewPar("FA_BPDBASE","BPORTAL_SA")
	Local cSp := "Sp_BPortal_SetBoleto"
	Local cSql
	Local oBol
	Local cAliasTmp

	For nCount := 1 To Len(::oLote:Boletos)

		oBol := ::oLote:Boletos[nCount]

		cSql := "exec "+cDBSERVER+"."+cDBSA+".dbo."+cSp+" "

		cSql += "'TAFSendStagePortal'" + ", "
		cSql += ValToSql(::cCNPJ) + ", "
		cSql += ValToSql(oBol:CodBanco) + ", "
		cSql += ValToSql(::oCedente:CPFCNPJ) + ", "
		cSql += ValToSql(::oCedente:Codigo) + ", "
		cSql += ValToSql(oBol:Sacado:CPFCNPJ) + ", "
		cSql += ValToSql(oBol:NumDoc) + ", "
		cSql += ValToSql(oBol:ChaveUnica) + ", "
		cSql += ValToSql(oBol:NNumero) + ", "
		cSql += ValToSql(DTOS(oBol:DtEmissao)) + ", "
		cSql += ValToSql(DTOS(oBol:DtVenc)) + ", "
		cSql += ValToSql(oBol:Valor) + ", "
		cSql += ValToSql(oBol:Acrescimo) + ", "
		cSql += ValToSql(oBol:VlrDesc) + ", "
		cSql += ValToSql(oBol:PerJurDia) + ", "
		cSql += ValToSql(oBol:VlrJurDia) + ", "
		cSql += ValToSql(DecodeUTF8(oBol:MsgLiv1))+ ", "
		cSql += ValToSql(DecodeUTF8(oBol:MsgLiv2))+ ", "
		cSql += ValToSql(DecodeUTF8(oBol:MsgLiv3))


		cAliasTmp := GetNextAlias()
		TCQuery cSQL Alias (cAliasTmp) New

		(cAliasTmp)->(DbGoTop())
		If !(cAliasTmp)->(Eof())
		
			ConOut("TAF [SendStage "+CEMPANT+"] => DATE: "+DTOC(Date())+" TIME: "+Time())	
			ConOut("TAF [SendStage "+CEMPANT+"] => RETORNO: "+(cAliasTmp)->RESULT+" MSG: "+(cAliasTmp)->MENSAGEM)	

		EndIf
		(cAliasTmp)->(DbCloseArea())

	Next nCount

Return


User Function BFLSAX01()

	RPCSetEnv("01", "01")
		
	oObj := TAFRemessaReceber():New()
	oObj:Send()

	RPCClearEnv()
	RPCSetEnv("05", "01")

	oObj := TAFRemessaReceber():New()
	oObj:Send()

	RPCClearEnv()
	RPCSetEnv("07", "01")

	oObj := TAFRemessaReceber():New()
	oObj:Send()

	RPCClearEnv()

Return
