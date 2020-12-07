#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//ESTADOS DO MODELO
#DEFINE _UNCHANGED 0
#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3

/*/{Protheus.doc} TPDMMArca
@description Classe para controle da tabela ZD8 - cadastro de Marcas
@author Fernando Rocha
@since 27/08/2018
@version 1.0
@return ${return}, ${return_description}
@type class
/*/
Class TPDMMArca From LongClassName

//Chave Unica
Data Filial 	as String
Data Codigo 	as String
Data Descricao	as String

//Controle
Data DbState as Integer

Method New() Constructor
Method Get(_cCodigo, _cDescricao) Constructor
Method Existe(_cCodigo)
Method CheckState()
Method Save()

EndClass


Method New() Class TPDMMArca	

	::Filial		:= XFilial("ZD8")
	::Codigo 		:= ""
	::Descricao		:= ""

	::DbState		:= _NEW

Return(Self)


Method Existe(_cCodigo, _cDescricao) Class TPDMMArca

	Local lRet := .F.

	Default _cDescricao := ""

	lRet := !Empty(_cCodigo) .And. !ZD8->(Eof()) .And. ( ZD8->(ZD8_FILIAL+ZD8_CODIGO) == (XFilial("ZD8")+_cCodigo) )

	If !lRet

		If !Empty(_cCodigo) 

			ZD8->(DbSetOrder(1))
			lRet :=  ZD8->(DbSeek(XFilial("ZD8")+_cCodigo))

		ElseIf !Empty(_cDescricao)

			ZD8->(DbSetOrder(2))
			lRet :=  ZD8->(DbSeek(XFilial("ZD8")+_cDescricao))

		EndIf

	EndIf

Return(lRet)


Method Get(_cCodigo, _cDescricao) Class TPDMMArca

	Default _cDescricao := ""

	If ::Existe(_cCodigo, _cDescricao)

		::Filial		:= ZD8->ZD8_FILIAL
		::Codigo		:= ZD8->ZD8_CODIGO
		::Descricao		:= ZD8->ZD8_DESCR	

		::DbState		:= _UPDATE

	EndIf

Return(Self)


Method CheckState() Class TPDMMArca

	If  (::DbState == _DELETE)
		Return
	EndIf

	If ::Existe(::Codigo)

		If (;
		::Descricao <> ZD8->ZD8_DESCR;
		)

			::DbState := _UPDATE

		Else

			::DbState := _UNCHANGED

		EndIf

	Else

		::DbState := _NEW

	EndIf

Return


Method Save() Class TPDMMArca

	::CheckState()

	If (::DbState == _NEW .Or. ::DbState == _UPDATE)

		If (::DbState == _UPDATE)

			RecLock("ZD8",.F.)

		Else

			RecLock("ZD8",.T.)		
			ZD8->ZD8_FILIAL		:= XFilial("ZD8")
			
			If Empty(::Codigo)
				::Codigo := GetSxeNum("ZD8","ZD8_CODIGO")
			EndIf
			
			ZD8->ZD8_CODIGO		:= ::Codigo

		EndIf

		ZD8->ZD8_DESCR	:= ::Descricao

		ZD8->(MsUnlock())

	ElseIf( ::DbState == _DELETE )

		ZD8->(DbSetOrder(1))
		If ZD8->(DbSeek(XFilial("ZD8")+::Codigo))

			RecLock("ZD8",.F.)
			ZD8->(DbDelete())
			ZD8->(MsUnlock())

		EndIf

	EndIf

Return