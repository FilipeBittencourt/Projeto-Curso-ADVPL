#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3

Class TPDMFamilia From LongClassName

//Chave Unica
Data Filial as String
Data Grupo as String
Data Subgrupo as String
Data Familia as String

//Ccampos do Cabecalho
Data Descricao as String

//Controle
Data DbState as Integer

Method New() Constructor
Method Get(_cGrupo, _cSubGrupo, _cFamilia) Constructor

Method Existe(_cGrupo, _cSubGrupo, _cFamilia)

Method ListBySubGrupo(_cGrupo, _cSubGrupo)

EndClass


Method New() Class TPDMFamilia	

	::Filial		:= XFilial("ZD5")
	::Grupo 		:= ""
	::Subgrupo		:= ""
	::Familia		:= ""
	::Descricao		:= ""
	::DbState		:= _NEW

Return(Self)


Method Existe(_cGrupo, _cSubGrupo, _cFamilia) Class TPDMFamilia

	Local lRet := .F.

	lRet := !ZD5->(Eof()) .And. ( ZD5->(ZD5_FILIAL+ZD5_GRUPO+ZD5_SUBGRU+ZD5_FAMILI) == (XFilial("ZD4")+_cGrupo+_cSubGrupo+_cFamilia) )

	If !lRet

		ZD5->(DbSetOrder(1))
		lRet :=  ZD5->(DbSeek(XFilial("ZD5")+_cGrupo+_cSubGrupo+_cFamilia))

	EndIf

Return(lRet)


Method Get(_cGrupo, _cSubGrupo, _cFamilia) Class TPDMFamilia

	If ::Existe(_cGrupo, _cSubGrupo, _cFamilia)

		::Filial		:= ZD5->ZD5_FILIAL
		::Grupo 		:= ZD5->ZD5_GRUPO
		::Subgrupo		:= ZD5->ZD5_SUBGRU
		::Familia		:= ZD5->ZD5_FAMILI
		::Descricao		:= ZD5->ZD5_DESCR
		
		::DbState		:= _UPDATE

	Else

		Self := Nil

	EndIf

Return(Self)

Method ListBySubGrupo(_cGrupo, _cSubGrupo) Class TPDMFamilia

	Local aFamilias := {}
	Local _oFamilia

	ZD5->(DbSetOrder(1))
	If ZD5->(DbSeek(XFilial("ZD5")+_cGrupo+_cSubGrupo))

		While !ZD5->(Eof()) .And. ZD5->(ZD5_FILIAL+ZD5_GRUPO+ZD5_SUBGRU) == (XFilial("ZD5")+_cGrupo+_cSubGrupo)

			_oFamilia := TPDMFamilia():Get(_cGrupo, _cSubGrupo, ZD5->ZD5_FAMILI)

			AAdd(aFamilias, _oFamilia)

			ZD5->(DbSkip())
		EndDo

	EndIf

Return(aFamilias)

