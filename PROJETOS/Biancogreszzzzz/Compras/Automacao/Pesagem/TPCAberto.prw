#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "topconn.ch"

Class TPCAberto from LongClassName
	
	Public Data oPCAResultStruct
	
	Public Method New() Constructor

	Public Method GetPorForProd()
		
EndClass


Method New() Class TPCAberto
	::oPCAResultStruct := TPCAbertoResultStruct():New()
Return

Method GetPorForProd(cFornecedor, cLoja, cProd, nQuant) Class TPCAberto
	
	Local oPCAStruct		:= TPCAbertoStruct():New()
	Local oPCAResultStruct 	:= TPCAbertoResultStruct():New()
	Local lOk				:= .T.
	Local cLogMsg			:= ""
	Local cQuery			:= ""
	Local cAliasTemp		:= GetNextAlias()
	
	Default nQuant 			:= 0
	
	
	cQuery	+= " SELECT	TOP 1																		"
	cQuery	+= " *                                                                              	"
	cQuery	+= " FROM	"+RetSQLName("SC7")+" SC7                                               	"
	cQuery	+= " WHERE	SC7.C7_FILIAL		= '01'                                              	"
	cQuery	+= " 	AND SC7.C7_ENCER		= ''                                                	"
	cQuery	+= " 	AND SC7.C7_RESIDUO		<> 'S'                                              	"
	cQuery	+= " 	AND SC7.C7_PRODUTO		= '"+cProd+"' 		                                	"
	cQuery	+= " 	AND SC7.C7_FORNECE		= '"+cFornecedor+"'                                 	"
	cQuery	+= " 	AND SC7.C7_LOJA			= '"+cLoja+"'                                       	"
	cQuery	+= " 	AND SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA > 0                             	"
	cQuery	+= " 	AND SC7.D_E_L_E_T_		= ''                                                	"
	
	If (nQuant > 0)
		cQuery	+= " 	AND (SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA) >= "+cValToChar(nQuant)+"    	"
	EndIf
	
	cQuery	+= " 	ORDER BY C7_EMISSAO                                                         	"
	
	TcQuery cQuery New Alias (cAliasTemp)
	
	If (!(cAliasTemp)->(EoF()))
		oPCAStruct:cNumero		:= (cAliasTemp)->C7_NUM
		oPCAStruct:cItem		:= (cAliasTemp)->C7_ITEM
		oPCAStruct:cLocal		:= (cAliasTemp)->C7_LOCAL
	Else
		lOk			:= .F.
		cLogMsg 	:= "[Fornecedor: "+cFornecedor+", Loja: "+cLoja+", Produto: "+cProd+", Quantidade: "+cValToChar(nQuant)+"] => não encontrado pedido de compra."
	EndIf
	(cAliasTemp)->(DbCloseArea())
	
	If (lOk)
		oPCAResultStruct:Add(lOk, cLogMsg, oPCAStruct)
	Else
		oPCAResultStruct:Add(lOk, cLogMsg, Nil)
	EndIf
	
	::oPCAResultStruct := oPCAResultStruct

Return(oPCAResultStruct)



Class TPCAbertoStruct from LongClassName

	Data cNumero
	Data cItem
	Data cLocal
	
	Method New() Constructor

EndClass

Method New() Class TPCAbertoStruct

	::cNumero				:= ""
	::cItem					:= ""
	::cLocal				:= ""
	
Return()



Class TPCAbertoResultStruct From LongClassName

	Public Data lOk			as logical
	Public Data cMensagem	as character
	Public Data oResult	

	Public Method New() Constructor
	Public Method Add()

EndClass

Method New() Class TPCAbertoResultStruct

	::lOk		:= .T.
	::cMensagem	:= ""
	::oResult	:= Nil
	
Return()

Method Add(lOk, cMensagem, oResult) Class TPCAbertoResultStruct

	::lOk		:= lOk
	::cMensagem	+= cMensagem
	::oResult	:= oResult

Return()
