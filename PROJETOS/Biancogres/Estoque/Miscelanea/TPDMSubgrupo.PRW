#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3

Class TPDMSubgrupo From LongClassName

//Chave Unica
Data Filial as String
Data Grupo as String
Data Subgrupo as String

//Ccampos do Cabecalho
Data Descricao as String

//Relacionais
Data aFamilias as Array Init {}

//Controle
Data DbState as Integer

Method New() Constructor
Method Get(_cGrupo, _cSubGrupo) Constructor

Method Existe(_cGrupo, _cSubGrupo)
Method ChkFamilia(_cFamilia)
Method AddFamilia(_cFamilia, _cDescricao)

Method ListByGrupo(_cGrupo)

EndClass


Method New() Class TPDMSubgrupo	

	::Filial		:= XFilial("ZD4")
	::Grupo 		:= ""
	::Subgrupo		:= ""
	::Descricao		:= "" 

	::aFamilias		:= {}

	::DbState		:= _NEW

Return(Self)


Method Existe(_cGrupo, _cSubGrupo) Class TPDMSubgrupo

	Local lRet := .F.

	lRet := !ZD4->(Eof()) .And. ( ZD4->(ZD4_FILIAL+ZD4_GRUPO+ZD4_SUBGRU) == (XFilial("ZD4")+_cGrupo+_cSubGrupo) )

	If !lRet

		ZD4->(DbSetOrder(1))
		lRet :=  ZD4->(DbSeek(XFilial("ZD4")+_cGrupo+_cSubGrupo))

	EndIf

Return(lRet)


Method Get(_cGrupo, _cSubGrupo) Class TPDMSubgrupo

	Local oFam

	If ::Existe(_cGrupo, _cSubGrupo)

		oFam 			:= TPDMFamilia():New()

		::Filial		:= ZD4->ZD4_FILIAL
		::Grupo 		:= ZD4->ZD4_GRUPO
		::Subgrupo		:= ZD4->ZD4_SUBGRU
		::Descricao		:= ZD4->ZD4_DESCR

		::aFamilias		:= oFam:ListBySubGrupo(_cGrupo, _cSubGrupo)

		::DbState		:= _UPDATE

		oFam			:= Nil

	EndIf

Return(Self)

Method ListByGrupo(_cGrupo) Class TPDMSubgrupo

	Local aSubGrupos := {}
	Local _oSubGrupo

	ZD4->(DbSetOrder(1))
	If ZD4->(DbSeek(XFilial("ZD4")+_cGrupo))

		While !ZD4->(Eof()) .And. ZD4->(ZD4_FILIAL+ZD4_GRUPO) == (XFilial("ZD4")+_cGrupo)

			_oSubGrupo := TPDMSubgrupo():Get(_cGrupo, ZD4->ZD4_SUBGRU)

			AAdd(aSubGrupos, _oSubGrupo)

			ZD4->(DbSkip())
		EndDo

	EndIf

Return(aSubGrupos)


Method ChkFamilia(_cFamilia) Class TPDMSubgrupo

	Local n := AScan(::aFamilias, {|o| o:Familia == _cFamilia})

Return n


Method AddFamilia(_cFamilia, _cDescricao) Class TPDMSubgrupo

	Local oFamilia

	Local nPos := ::ChkFamilia(_cFamilia)

	If (nPos > 0) 

		oFamilia := ::aFamilias[nPos]
		oFamilia:Descricao	:= _cDescricao
		oFamilia:DbState 	:= _UPDATE

	Else

		oFamilia := TPDMFamilia():New()
		oFamilia:Grupo 	:= ::Grupo
		oFamilia:Subgrupo	:= ::Subgrupo
		oFamilia:Familia	:= _cFamilia
		oFamilia:Descricao	:= _cDescricao	

		AAdd(::aFamilias, oFamilia)	

	EndIf

Return