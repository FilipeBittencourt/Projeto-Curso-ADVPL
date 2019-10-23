#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TEZClienteDAO
@author  Filipe Vieira
@since 18/01/2019
@version 1.0
/*/

Class TEZClienteDAO From LongClassName

    Data oClienteM

    Method New() Constructor
	Method Get(cChave, nIndice)

EndClass

Method New() Class TEZClienteDAO

	::oClienteM := Nil

Return Self


Method Get(cChave, nIndice) Class TEZClienteDAO

	::oClienteM := TEZClienteModel():New()

	SA1->(DbSetOrder(nIndice))
	If SA1->(DbSeek(cChave))

	    ::oClienteM:cFilialx    	:= SA1->A1_FILIAL
		::oClienteM:cCodClient		:= SA1->A1_COD
		::oClienteM:cCodLoja		:= SA1->A1_LOJA
		::oClienteM:cRazClient		:= SA1->A1_NOME
		::oClienteM:cEstClient		:= SA1->A1_EST
		::oClienteM:cMunClient		:= IIf(Empty(SA1->A1_MUNE),SA1->A1_MUN,SA1->A1_MUNE)
		::oClienteM:cNome     		:= SA1->A1_NOME
		::oClienteM:cCGC      		:= SA1->A1_CGC
		::oClienteM:cCEP      		:= IIf(Empty(SA1->A1_CEPE),SA1->A1_CEP,SA1->A1_CEPE)
		::oClienteM:cEndereco  		:= IIf(Empty(SA1->A1_ENDENT),SA1->A1_END,SA1->A1_ENDENT)
		::oClienteM:cComplem  		:= SA1->A1_COMPLEM
		::oClienteM:cUF  			:= IIf(Empty(SA1->A1_ESTE),SA1->A1_EST,SA1->A1_ESTE)
		::oClienteM:cDDD  			:= AllTrim(SA1->A1_DDD)
		::oClienteM:cTelefone		:= StrTran(AllTrim(SA1->A1_TEL),"-","")


	EndIf

Return ::oClienteM
