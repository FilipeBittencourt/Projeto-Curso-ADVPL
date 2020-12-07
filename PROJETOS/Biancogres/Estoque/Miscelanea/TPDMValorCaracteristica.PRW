#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//ESTADOS DO MODELO
#DEFINE _UNCHANGED 0
#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3

Class TPDMValorCaracteristica From LongClassName

//Chave Unica
Data Filial			as String
Data Codigo			as String
Data Revisao		as String
Data Sequencia		as String
Data Item			as String

//Campos do Valor
Data Descricao		as String
Data Abreviatura	as String
Data Bloqueio		as String	

//Controle
Data DbState as Integer

Method New() Constructor
Method Get(_cCodigo, _cRevisao, _cSequencia, _cItem) Constructor

Method Existe(_cCodigo, _cRevisao, _cSequencia, _cItem)
Method ListByCaracteristica(_cCodigo, _cRevisao, _cSequencia)
Method Populate(_cDescricao, _cAbreviatura)
Method IsBloqueado()

Method CheckState()
Method Save()

EndClass


Method New() Class TPDMValorCaracteristica	

	::Filial			:= XFilial("ZD2")
	::Codigo 			:= ""
	::Revisao			:= "" 
	::Sequencia			:= ""
	::Item				:= ""

	::Descricao			:= ""
	::Abreviatura		:= ""
	::Bloqueio			:= "2"

	::DbState 			:= _NEW	

Return(Self)


Method Existe(_cCodigo, _cRevisao, _cSequencia, _cItem) Class TPDMValorCaracteristica

	Local lRet := .F.

	lRet := !ZD2->(Eof()) .And. ( ZD2->(ZD2_FILIAL+ZD2_CODIGO+ZD2_REV+ZD2_SEQUEN+ZD2_ITEM) == (XFilial("ZD2")+_cCodigo+_cRevisao+_cSequencia+_cItem) )

	If !lRet

		ZD2->(DbSetOrder(1))
		lRet :=  ZD2->(DbSeek(XFilial("ZD2")+_cCodigo+_cRevisao+_cSequencia+_cItem))

	EndIf

Return(lRet)


Method Get(_cCodigo, _cRevisao, _cSequencia, _cItem) Class TPDMValorCaracteristica

	If ::Existe(_cCodigo, _cRevisao, _cSequencia, _cItem)

		::Filial		:= ZD2->ZD2_FILIAL
		::Codigo		:= ZD2->ZD2_CODIGO
		::Revisao		:= ZD2->ZD2_REV
		::Sequencia		:= ZD2->ZD2_SEQUEN
		::Item			:= ZD2->ZD2_ITEM
		::Descricao		:= ZD2->ZD2_DESCR
		::Abreviatura	:= ZD2->ZD2_ABREV
		::Bloqueio		:= ZD2->ZD2_MSBLQL

		::DbState 		:= _UPDATE	

	EndIf

Return(Self)


Method ListByCaracteristica(_cCodigo, _cRevisao, _cSequencia) Class TPDMValorCaracteristica

	Local aValores := {}
	Local _oValor
	Local _cAliasTmp

	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp

		SELECT ZD2_ITEM FROM %Table:ZD2% where ZD2_FILIAL = %XFILIAL:ZD2% and ZD2_CODIGO = %Exp:_cCodigo% and ZD2_REV = %Exp:_cRevisao% and ZD2_SEQUEN = %Exp:_cSequencia% and D_E_L_E_T_=' '
		ORDER BY ZD2_CODIGO, ZD2_REV, ZD2_SEQUEN, ZD2_ITEM

	EndSql

	While !(_cAliasTmp)->(Eof())

		_oValor := TPDMValorCaracteristica():Get(_cCodigo, _cRevisao, _cSequencia, (_cAliasTmp)->ZD2_ITEM)

		AAdd(aValores, _oValor)

		(_cAliasTmp)->(DbSkip())
	EndDo

	(_cAliasTmp)->(DbCloseArea())

Return(aValores)


Method Populate(_cDescricao, _cAbreviatura, _cBloqueio) Class TPDMValorCaracteristica

	::Descricao 	:= _cDescricao
	::Abreviatura	:= _cAbreviatura
	::Bloqueio		:= _cBloqueio

Return()


Method CheckState() Class TPDMValorCaracteristica

	If  (::DbState == _DELETE)
		Return
	EndIf
	
	ZD2->(DbSetOrder(1))
	If ZD2->(DbSeek(XFilial("ZD1")+::Codigo+::Revisao+::Sequencia+::Item))

		If (;
		::Descricao 		<> ZD2->ZD2_DESCR .Or.;
		::Abreviatura		<> ZD2->ZD2_ABREV .Or.;
		::Bloqueio			<> ZD2->ZD2_MSBLQL;
		)

			::DbState := _UPDATE

		Else

			::DbState := _UNCHANGED

		EndIf

	Else

		::DbState := _NEW

	EndIf

Return


Method IsBloqueado() Class TPDMValorCaracteristica
Return (::Bloqueio == "1")


Method Save() Class TPDMValorCaracteristica

	::CheckState()

	If (::DbState == _NEW .Or. ::DbState == _UPDATE)

		If (::DbState == _UPDATE)

			RecLock("ZD2",.F.)

		Else

			RecLock("ZD2",.T.)		
			ZD2->ZD2_FILIAL	:= XFilial("ZD1")
			ZD2->ZD2_CODIGO := ::Codigo
			ZD2->ZD2_REV	:= ::Revisao
			ZD2->ZD2_SEQUEN	:= ::Sequencia
			ZD2->ZD2_ITEM	:= ::Item 		

		EndIf

		ZD2->ZD2_DESCR 	:= ::Descricao
		ZD2->ZD2_ABREV 	:= ::Abreviatura
		ZD2->ZD2_MSBLQL := ::Bloqueio

		ZD2->(MsUnlock())

	ElseIf( ::DbState == _DELETE )

		ZD2->(DbSetOrder(1))
		If ZD2->(DbSeek(XFilial("ZD2")+::Codigo+::Revisao+::Sequencia+::Item))

			RecLock("ZD2",.F.)
			ZD2->(DbDelete())
			ZD2->(MsUnlock())

		EndIf

	EndIf

Return