#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} function_method_class_name
//TODO Descrição auto-gerada.
@author Pedro H Costa
@since 26/08/2020
@version version
@example
(examples)
@see (links_or_references)
/*/


Class TCNPJPoliticaCredito From LongClassName
	
	Data cCodPro 
	Data cCNPJ
	
	Method New() Constructor
	Method CNPJExist()
	Method CNPJExistProc()
	Method Execute()
	Method AddCNPJ()

EndClass


Method New(_cCodPro, _cCNPJ) Class TCNPJPoliticaCredito
	::cCodPro	:=  _cCodPro
	::cCNPJ		:= _cCNPJ
Return()

Method Execute() Class TCNPJPoliticaCredito
	
	Local lRet 				:= .T.
	Local cMensagem 		:= ""
	Local oTStructCPCResult	:= Nil
	Local oTVariavelCliente	:= Nil
	
	If (::CNPJExist())//verifica cnpj existe ba base
		If (!::CNPJExistProc())//verifica cnpj não atrealado ao processo
		
			Begin Transaction
		
				::AddCNPJ()
		
			End Transaction
			
		Else
			lRet 		:= .F.
			cMensagem 	:=  'CNPJ já atrelado ao Processo!'
		EndIf
	Else
		lRet 		:= .F.
		cMensagem 	:=  'CNPJ não encontrado!'
	EndIf
	
	oTStructCPCResult := TStructCPCResult():New(lRet, cMensagem)

Return oTStructCPCResult


Method AddCNPJ()  Class TCNPJPoliticaCredito
	
	
	Local lRet 				:= .F.
	Local cQuery 			:= ""
	Local cAliasTemp 		:= GetNextAlias()
	Local oVariavel			:= TVariavelCliente():New()


	cQuery := " SELECT ZM0_CODIGO, ZM0_DATINI, ZM0_DATINI, ZM0_CLIENT, ZM0_LOJA, ZM0_GRUPO, ZM0_CNPJ, ZM0_VLSOL, ZM0_VLOBRA, ZM0_ORIGEM 	"
	cQuery += " FROM "+ RetSQLName("ZM0")+"																									"
	cQuery += " WHERE ZM0_FILIAL = "+ ValToSQL(xFilial("ZM0"))+"																			"		
	//cQuery += " AND ZM0_STATUS IN ('1', '2') 																								"
	cQuery += " AND D_E_L_E_T_ = '' 																										"
	cQuery += " AND ZM0_CODIGO = "+ ValToSQL(::cCodPro)+" 																					"

	TcQuery cQuery New Alias (cAliasTemp)
	
	If !(cAliasTemp)->(Eof())
		
		DbSelectArea('SA1')
		SA1->(DbSetOrder(3))
	
		::cCNPJ := PADR(::cCNPJ, TamSx3("A1_CGC")[1])
	
		If (SA1->(DbSeek(xFilial('SA1')+::cCNPJ)))
		
			oVariavel:cCodPro 		:= (cAliasTemp)->ZM0_CODIGO
			oVariavel:dData 		:= sToD((cAliasTemp)->ZM0_DATINI)
			oVariavel:cCliente 		:= SA1->A1_COD
			oVariavel:cLoja 		:= SA1->A1_LOJA
			oVariavel:cGrpVen 		:= ''
			oVariavel:cCnpj 		:= ::cCNPJ
			oVariavel:nLimCreSol 	:= (cAliasTemp)->ZM0_VLSOL
			oVariavel:nVlrObr 		:= (cAliasTemp)->ZM0_VLOBRA
			
			If (oVariavel:Exist()) //deve exitir processo com numero informado
				oVariavel:Add('R')
			EndIf
			
		EndIf
									
	EndIf

	(cAliasTemp)->(DbCloseArea())

Return()
	

Method CNPJExist() Class TCNPJPoliticaCredito
	
	Local lRet := .F.
	
	DbSelectArea('SA1')
	SA1->(DbSetOrder(3))
	
	::cCNPJ := PADR(::cCNPJ, TamSx3("A1_CGC")[1])
	
	If (SA1->(DbSeek(xFilial('SA1')+::cCNPJ)))
		lRet := .T.
	EndIf

Return(lRet)


Method CNPJExistProc() Class TCNPJPoliticaCredito
	
	Local lRet 			:= .F.
	Local cQuery 		:= ""
	Local cAliasTemp	:= GetNextAlias()

	cQuery := " SELECT *						 							"
	cQuery += " FROM "+ RetSQLName("ZM1")+"									"
	cQuery += " WHERE ZM1_FILIAL 	= "+ ValToSQL(xFilial("ZM1"))+"			"	
	cQuery += " AND ZM1_CODPRO 		= "+ ValToSQL(::cCodPro)+"				"
	cQuery += " AND ZM1_CNPJ 		= "+ ValToSQL(::cCNPJ)+"				"
	cQuery += " AND D_E_L_E_T_ 		= '' 									"

	TcQuery cQuery New Alias (cAliasTemp)
	
	If (!(cAliasTemp)->(Eof()))
		lRet := .T.
	EndIf
	
	(cAliasTemp)->(DbCloseArea())

Return(lRet)



Class TStructCPCResult From LongClassName
	
	Data lOk 
	Data cMensagem
	
	Method New() Constructor

EndClass

Method New(_lOk, _cMensagem) Class TStructCPCResult
	::lOk			:=  _lOk
	::cMensagem		:= _cMensagem
Return()