#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF014
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF008
@type function
/*/

Class TParBAF014 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data dVencReDe
	//Data dVencReAte
	//Data cNum
	//Data cPrefixo
	//Data cTipo
	//Data cParcela
	Data cForneceDe	
	Data cLojaDe
	Data cForneceAte	
	Data cLojaAte
		
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF014
	
	::cName := "BAF014"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::dVencReDe := dDataBase
	//::dVencReAte := dDataBase
	//::cNum := Space(TamSx3("E2_NUM")[1])
	//::cPrefixo := Space(TamSx3("E2_PREFIXO")[1])
	//::cTipo := Space(TamSx3("E2_TIPO")[1])
	//::cParcela := Space(TamSx3("E2_PARCELA")[1])
	::cForneceDe := Space(TamSx3("E2_FORNECE")[1])
	::cLojaDe := Space(TamSx3("E2_LOJA")[1])
	::cForneceAte := Space(TamSx3("E2_FORNECE")[1])
	::cLojaAte := Space(TamSx3("E2_LOJA")[1])
	
	::Add()
	
Return()


Method Add() Class TParBAF014

	aAdd(::aParam, {1, "Venc. Real" , ::dVencReDe , "@D", ".T.",,".T.",,.F.})
	//aAdd(::aParam, {1, "Venc. Real ate", ::dVencReAte, "@D", ".T.",,".T.",,.F.})
	//aAdd(::aParam, {1, "Qtd.Dias.Subseq.", ::nDia, "99", ".T.",,".T.",,.F.})	
	//aAdd(::aParam, {2, "Reenvio", ::lReenvBord, {"1=Sim", "2=Nao"}, 50,".T.",.F.})
	//aAdd(::aParam, {1, "Bordero de", ::cBorDe, "@!", ".T.",,".T.",,.F.})	
	//aAdd(::aParam, {1, "Bordero Ate", ::cBorAte, "@!", ".T.",,".T.",,.F.})	
	//aAdd(::aParam, {1, "Num. Titulo", ::cNum, "@!", ".T.",,".T.",,.F.})	
	//aAdd(::aParam, {1, "Prefixo", ::cPrefixo, "@!", ".T.",,".T.",,.F.})	
	//aAdd(::aParam, {1, "Tipo", ::cTipo, "@!", ".T.",,".T.",,.F.})	
	//aAdd(::aParam, {1, "Parcela", ::cParcela, "@!", ".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Fornecedor de", ::cForneceDe, "@!", ".T.","SA2",".T.",,.F.})	
	aAdd(::aParam, {1, "Fornecedor ate", ::cForneceAte, "@!", ".T.","SA2",".T.",,.F.})	
	aAdd(::aParam, {1, "Loja de", ::cLojaDe, "@!", ".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Loja ate", ::cLojaAte, "@!", ".T.",,".T.",,.F.})	
	  
Return()


Method Box() Class TParBAF014
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
	
		::dVencReDe := ::aParRet[1]
		//::dVencReAte := ::aParRet[2]
		//::cNum := ::aParRet[3]
		//::cPrefixo := ::aParRet[4]
		//::cTipo := ::aParRet[5]
		//::cParcela := ::aParRet[6]
		::cForneceDe := ::aParRet[2]
		::cForneceAte := ::aParRet[3]
		::cLojaDe := ::aParRet[4]
		::cLojaAte := ::aParRet[5]
				
	EndIf
	
	/*
	If ::dDataBase <> dDataBase
	
		Alert("Data base do sistema deve ser a mesma do parametro!", "STOP")
		
		lRet := .F.
	
	EndIf
	*/
	
Return(lRet)


Method Update() Class TParBAF014
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF014
Local lRet := .T.
	
Return(lRet)