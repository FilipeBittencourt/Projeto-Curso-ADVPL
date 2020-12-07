#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//ESTADOS DO MODELO
#DEFINE _UNCHANGED 0
#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3

/*/{Protheus.doc} TPDMProdutoMarca
@description Classe para controle da tabela ZD6 - relacao produto x marca
@author Fernando Rocha
@since 27/08/2018
@version 1.0
@return ${return}, ${return_description}
@type class
/*/
Class TPDMProdutoMarca From LongClassName

//Chave Unica
Data Filial 	as String
Data Produto 	as String
Data CodMarca 	as String
Data Marca 		as String

//Campos
Data Referencia as String
Data InfAdicional as String

//Controle
Data DbState as Integer

Method New() Constructor
Method Get(_cProduto, _cCodMarca, _cRefer) Constructor
Method Existe(_cProduto, _cCodMarca, _cRefer)
Method CheckState()
Method Save()

EndClass


Method New() Class TPDMProdutoMarca	

	::Filial		:= XFilial("ZD6")
	::Produto 		:= ""
	::CodMarca		:= ""
	::Marca			:= "" 
	::Referencia	:= ""
	::InfAdicional	:= ""

	::DbState		:= _NEW

Return(Self)


Method Existe(_cProduto, _cCodMarca, _cRefer) Class TPDMProdutoMarca

	Local lRet := .F.

	lRet := !ZD6->(Eof()) .And. ( ZD6->(ZD6_FILIAL+ZD6_COD+ZD6_CODMAR+ZD6_REFER) == (XFilial("ZD6")+_cProduto+_cCodMarca+_cRefer) )

	If !lRet

		ZD6->(DbSetOrder(1))
		lRet :=  ZD6->(DbSeek(XFilial("ZD6")+_cProduto+_cCodMarca+_cRefer))

	EndIf

Return(lRet)


Method Get(_cProduto, _cCodMarca, _cRefer) Class TPDMProdutoMarca

	If ::Existe(_cProduto, _cCodMarca, _cRefer)

		::Filial		:= ZD6->ZD6_FILIAL
		::Produto 		:= ZD6->ZD6_COD
		::CodMarca		:= ZD6->ZD6_CODMAR
		::Marca			:= ZD6->ZD6_MARCA	
		::Referencia	:= ZD6->ZD6_REFER
		::InfAdicional	:= ZD6->ZD6_INFADI
		::DbState		:= _UPDATE

	EndIf

Return(Self)


Method CheckState() Class TPDMProdutoMarca

	If  (::DbState == _DELETE)
		Return
	EndIf

	If ::Existe(::Produto, ::CodMarca, ::Referencia)

		If (;
		AllTrim(::InfAdicional) <> AllTrim(ZD6->ZD6_INFADI);
		)

			::DbState := _UPDATE

		Else

			::DbState := _UNCHANGED

		EndIf

	Else

		::DbState := _NEW

	EndIf

Return


Method Save() Class TPDMProdutoMarca

	::CheckState()

	If (::DbState == _NEW .Or. ::DbState == _UPDATE)

		If (::DbState == _UPDATE)

			RecLock("ZD6",.F.)

		Else

			RecLock("ZD6",.T.)		
			ZD6->ZD6_FILIAL		:= XFilial("ZD6")
			ZD6->ZD6_COD		:= ::Produto
			ZD6->ZD6_CODMAR		:= ::CodMarca
			ZD6->ZD6_MARCA		:= Posicione("ZD8",1,XFilial("ZD8")+::CodMarca,"ZD8_DESCR")
			ZD6->ZD6_REFER		:= ::Referencia

		EndIf

		ZD6->ZD6_INFADI		:= ::InfAdicional

		ZD6->(MsUnlock())

	ElseIf( ::DbState == _DELETE )

		ZD6->(DbSetOrder(1))
		If ZD6->(DbSeek(XFilial("ZD6")+::Produto+::CodMarca))

			RecLock("ZD6",.F.)
			ZD6->(DbDelete())
			ZD6->(MsUnlock())

		EndIf

	EndIf

Return