#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoBizagi
@description Classe Para tratar concorrência entre rotinas
@author Gabriel Mafioletti
@since 04/11/2019
@version 1.0
@type class
/*/

Class tBiaServidor from LongClassName

	Data cIp
	Data nPorta
	Data cAmbiente
	Data lOnline

	Method New() Constructor

EndClass

Method New() Class tBiaServidor

	::cIp		:=	""
	::nPorta	:=	0
	::cAmbiente	:=	""
	::lOnline	:=	.F.
	

Return

