#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF008
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF008
@type function
/*/

Class TParBAF008 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data dEmissaoDe 
	Data dEmissaoAte 
	Data lReenvBord
	Data cBorDe
	Data cBorAte	
	Data cCliente
	Data cLoja
			
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF008
	
	::cName := "BAF008"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::dEmissaoDe := dDataBase
	::dEmissaoAte := dDataBase
	
	::lReenvBord := "2"
	::cBorDe := Space(TamSx3("E1_NUMBOR")[1])
	::cBorAte := Space(TamSx3("E1_NUMBOR")[1])
	::cCliente := Space(TamSx3("A1_COD")[1])
	::cLoja := Space(TamSx3("A1_LOJA")[1])
	
Return()


Method Add() Class TParBAF008
		
	::aParam := {}
	
	aAdd(::aParam, {1, "Data de Emissao de"	, ::dEmissaoDe	, "@D", ".T.",,".F.",,.F.})
	aAdd(::aParam, {1, "Data de Emissao ate"	, ::dEmissaoAte, "@D", ".T.",,".F.",,.F.})	
	aAdd(::aParam, {2, "Reenvio"				, ::lReenvBord	, {"1=Sim", "2=Nao"}, 50,".T.",.F.})	
	aAdd(::aParam, {1, "Bordero de"			, ::cBorDe		, "@!", ".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Bordero Ate"			, ::cBorAte		, "@!", ".T.",,".T.",,.F.})	
  	aAdd(::aParam, {1, "Cliente"				, ::cCliente	, "@!", ".T.","SA1",".T.",,.F.})	
  	aAdd(::aParam, {1, "Loja"					, ::cLoja		, "@!", ".T.",,".T.",,.F.})	
  
Return()


Method Box() Class TParBAF008
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	::Add()
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .F., .F.)
		
		lRet := .T.
			
		::dEmissaoDe := ::aParRet[1]
		::dEmissaoAte := ::aParRet[2]
		::lReenvBord := ::aParRet[3] == "1"
		::cBorDe := ::aParRet[4]
		::cBorAte := ::aParRet[5]
		::cCliente := ::aParRet[6]
		::cLoja := ::aParRet[7]
	
	EndIf
	
Return(lRet)


Method Update() Class TParBAF008
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF008
Local lRet := .T.

	If dDataBase > Date()
	
		Alert("A Database informada não pode ser maior que a data atual!")
		
		lRet := .F.
	
	EndIf
	
Return(lRet)