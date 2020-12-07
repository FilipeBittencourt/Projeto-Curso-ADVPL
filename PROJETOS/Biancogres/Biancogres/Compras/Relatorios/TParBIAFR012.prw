#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAFR012
@author Tiago Rossini Coradini
@since 10/01/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAFR012 
@obs Ticket: 1446 - Projeto Demandas Compras - Item 2 - Complemento 4
@type Class
/*/

Class TParBIAFR012 From LongClassName

	Data cName
	Data aParam
	
	Data cPedDe // Pedido de
	Data cPedAte // Pedido ate
	Data cTpConf // Tipo de confirmacao 1=Automatica; 2-Manual; 3=Ambas
	Data dDtEnvDe // Data de envio de
	Data dDtEnvAte // Data de envio ate
	Data cComDe // Comprador de
	Data cComAte // Comprador Ate
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAFR012
	
	::cName := "BIAFR012"
	
	::aParam := {}

	::cPedDe := Space(6)
	::cPedAte := Replicate("Z", 6)
	::cTpConf := "1=Automatica"
	::dDtEnvDe := dDataBase
	::dDtEnvAte := dDataBase
	::cComDe := Space(6)
	::cComAte := Replicate("Z", 6)

	::Add()		
	
Return()


Method Add() Class TParBIAFR012
		
	aAdd(::aParam, {1, "Pedido De", ::cPedDe, "@!", ".T.", "", ".T.",,.F.})
	aAdd(::aParam, {1, "Pedido Ate", ::cPedAte, "@!", ".T.", "", ".T.",,.F.})
	aAdd(::aParam, {2, "Tipo Confirmação", ::cTpConf, {"1-Automatica", "2-Manual", "3-Ambas"}, 60, ".T.", .F.})
	aAdd(::aParam, {1, "Dt Envio De", ::dDtEnvDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt Envio Ate", ::dDtEnvAte, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Comprador De", ::cComDe, "@!", ".T.", "USR", ".T.",,.F.})
	aAdd(::aParam, {1, "Comprador Ate", ::cComAte, "@!", ".T.", "USR", ".T.",,.F.})

Return()


Method Box() Class TParBIAFR012
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cPedDe := aRet[1]
		::cPedAte := aRet[2]
		::cTpConf := aRet[3]
		::dDtEnvDe := aRet[4]
		::dDtEnvAte := aRet[5]
		::cComDe := aRet[6]
		::cComAte := aRet[7]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR012
	
	::aParam := {}	
	
	::Add()
	
Return()