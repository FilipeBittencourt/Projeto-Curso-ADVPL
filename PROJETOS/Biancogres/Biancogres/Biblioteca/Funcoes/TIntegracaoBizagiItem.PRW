#include "TOTVS.CH"

/*/{Protheus.doc} TIntegracaoBizagi
@description Classe para leitura e gravacao da tabela de integracao BIZAGI
@author Fernando Rocha
@since 12/06/2019
@version 1.0
@type class
/*/

#DEFINE _ST_ERP_OK "1" 
#DEFINE _ST_ERP_ERRO "2"

Class TIntegracaoBizagiItem From LongClassName

	Public Data Empresa
	Public Data Filial
	Public Data Processo
	Public Data Status
	Public Data ID
	Public Data Dados
	Public Data ProcBizagi
	
	Public Data lDadosOk
	Public Data lDocOk
	Public Data lConferido

	Public Data StatusERP
	Public Data MsgRet
	Public Data DtIntERP

	Public Method New() Constructor
	Public Method Set(_cEmpresa, _cFilial, _cProcesso, _cStatus, _nID, _Dados, _ProcBizagi)
	Public Method SetStatus(_cOk, _cMensagem)
	Public Method Update()
	Public Method UpdateBizagi()

EndClass


Method New() Class TIntegracaoBizagiItem

	::Empresa		:= ""
	::Filial		:= ""
	::Processo		:= ""
	::Status		:= ""
	::ID			:= 0
	::Dados			:= ""
	::ProcBizagi	:= ""
	
	::lDadosOk		:= .F.
	::lDocOk		:= .F.
	::lConferido	:= .F.

	::StatusERP	:= ""
	::MsgRet	:= ""
	::DtIntERP	:= CTOD(" ")

Return


Method Set(_cEmpresa, _cFilial, _cProcesso, _cStatus, _nID, _Dados, _ProcBizagi) Class TIntegracaoBizagiItem

	::Empresa 		:= _cEmpresa
	::Filial		:= _cFilial	
	::Processo		:= _cProcesso
	::Status		:= _cStatus
	::ID			:= _nID	
	::Dados			:= _Dados
	::ProcBizagi	:= _ProcBizagi

Return


Method SetStatus(_lOk, _cMensagem) Class TIntegracaoBizagiItem

	::StatusERP	:= IIf(_lOk, _ST_ERP_OK, _ST_ERP_ERRO)
	::MsgRet	:= _cMensagem
	::DtIntERP	:= Date()

Return

Method Update() Class TIntegracaoBizagiItem

	Local cSQL		:= ""
	Local lRet 		:= .T.
	Local cStatus	:= IIF(::StatusERP == _ST_ERP_ERRO, "", " STATUS='AP', ")

	cSQL := "update BZINTEGRACAO set "+cStatus+"  STATUS_ERP = '"+::StatusERP+"', RET_ERP = '"+::MsgRet+"', DATA_INTEGRACAO_PROTHEUS = '"+DTOS(::DtIntERP) +" "+Time()+"' where ID = "+AllTrim(Str(::ID))+""
	If (TCSQLExec(cSQL) < 0)

		lRet := .F.

	EndIf

Return(lRet)


Method UpdateBizagi(cDados, cRecnos) Class TIntegracaoBizagiItem

	Local cSQL
	Local lRet := .T.
	
	cSQL := "UPDATE BZINTEGRACAO SET DADOS_RETORNO = '"+cDados+"', RECNO_RETORNO = '"+cRecnos+"' WHERE ID = "+AllTrim(Str(::ID))+""
	If (TCSQLExec(cSQL) < 0)

		lRet := .F.

	EndIf

Return(lRet)
