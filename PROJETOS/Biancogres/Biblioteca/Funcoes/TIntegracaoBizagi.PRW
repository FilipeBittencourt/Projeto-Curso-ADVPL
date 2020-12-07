#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoBizagi
@description Classe para leitura e gravacao da tabela de integracao BIZAGI
@author Fernando Rocha
@since 12/06/2019
@version 1.0
@type class
/*/

#DEFINE PROC_CLASS_NFE "NFE"
#DEFINE PROC_CLASS_NFS "NFS"
#DEFINE PROC_CLASS_PV "PV"


#DEFINE _ST_ERP_OK "1" 
#DEFINE _ST_ERP_ERRO "2" 

Class TIntegracaoBizagi From LongClassName

Public Data Empresa
Public Data Filial
Public Data Processo
Public Data Status
Public Data StatusERP
Public Data oItens

//Processo de Integracao
Public Data ProcBZ

Public Data ST_ERP_OK
Public Data ST_ERP_ERRO

Public Method New() Constructor
Public Method SetProcesso()
Public Method Get()

EndClass


Method New() Class TIntegracaoBizagi

	::Empresa	:= ""
	::Filial	:= ""
	::Processo	:= ""
	::Status	:= ""	
	::StatusERP	:= ""
	::ProcBZ 	:= ""

	::oItens := ArrayList():New()

	::ST_ERP_OK 	:= _ST_ERP_OK
	::ST_ERP_ERRO 	:= _ST_ERP_ERRO

Return


Method SetProcesso(_cProc) Class TIntegracaoBizagi

	If ( _cProc == PROC_CLASS_NFE )

		::Processo 	:= "RM"
		::Status	:= "IB"

	ElseIf (_cProc == PROC_CLASS_NFS)

		::Processo 	:= "ASP"
		::Status	:= "IB"

	ElseIf (_cProc == PROC_CLASS_PV)

		::Processo 	:= "SNF"
		::Status	:= "IB"

	EndIf

Return


Method Get() Class TIntegracaoBizagi

	Local cAliasTmp
	Local cSQL
	Local _oItem

	cAliasTmp := GetNextAlias()

	cSQL := "select "+CRLF
	cSQL += "ID, "+CRLF
	cSQL += "EMPRESA, "+CRLF
	cSQL += "FILIAL, "+CRLF
	cSQL += "PROCESSO = PROCESSO_NOME, "+CRLF
	cSQL += "STATUS, "+CRLF
	cSQL += "PROCESSO_BIZAGI, "+CRLF
	cSQL += "DADOS = DADOS_ENTRADA "+CRLF

	cSQL += "from BZINTEGRACAO "+CRLF

	cSQL += "where "+CRLF
	cSQL += "1 = 1 "+CRLF

	If !Empty(::Empresa)
		cSQL += "and EMPRESA = '"+::Empresa+"' "+CRLF
	EndIf

	If !Empty(::Filial)
		cSQL += "and FILIAL = '"+::Filial+"' "+CRLF
	EndIf

	cSQL += "and PROCESSO_NOME = '"+::Processo+"' "+CRLF
	cSQL += "and STATUS = '"+::Status+"' "+CRLF
	cSQL += "and (STATUS_ERP is null OR STATUS_ERP = '' OR STATUS_ERP = '0') "+CRLF

	TCQUERY cSQL ALIAS (cAliasTmp) NEW


	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		_oItem := TIntegracaoBizagiItem():New()
		_oItem:Set((cAliasTmp)->EMPRESA, (cAliasTmp)->FILIAL, (cAliasTmp)->PROCESSO, (cAliasTmp)->STATUS, (cAliasTmp)->ID, (cAliasTmp)->DADOS, (cAliasTmp)->PROCESSO_BIZAGI)

		::oItens:Add(_oItem)

		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())

Return