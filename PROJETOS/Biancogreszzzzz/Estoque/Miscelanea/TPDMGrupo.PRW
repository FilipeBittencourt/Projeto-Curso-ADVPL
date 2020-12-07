#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3

Class TPDMGrupo From LongClassName

//Chave Unica
Data Filial as String
Data Grupo as String

//Campos do Cabecalho
Data Descricao as String

//Relacionais
Data aSubgrupos as Array init {}

//Controle
Data DbState as Integer

Method New() Constructor
Method Get(_cGrupo) Constructor

Method Existe(_cGrupo)
Method ChkSubgrupo(_cSubgrupo)
Method AddSubgrupo(_cSubgrupo, _cDescricao)

Method Save()

EndClass


Method New() Class TPDMGrupo	

	::Filial		:= XFilial("ZD3")
	::Grupo 		:= ""
	::Descricao		:= "" 
	::aSubgrupos	:= {}

	::DbState		:= _NEW

Return(Self)

Method Existe(_cGrupo) Class TPDMGrupo

	Local lRet := .F.

	lRet := !ZD3->(Eof()) .And. ( ZD3->(ZD3_FILIAL+ZD3_GRUPO) == (XFilial("ZD3")+_cGrupo) )

	If !lRet

		ZD3->(DbSetOrder(1))
		lRet :=  ZD3->(DbSeek(XFilial("ZD3")+_cGrupo))

	EndIf

Return(lRet)

Method Get(_cGrupo) Class TPDMGrupo

	Local oSubG

	If ::Existe(_cGrupo)

		oSubG := TPDMSubgrupo():New()

		::Filial		:= ZD3->ZD3_FILIAL
		::Grupo 		:= ZD3->ZD3_GRUPO
		::Descricao		:= ZD3->ZD3_DESCR		

		::aSubgrupos 	:= oSubG:ListByGrupo(_cGrupo)

		::DbState		:= _UPDATE	

		oSubG 			:= Nil	

	EndIf

Return(Self)


Method ChkSubgrupo(_cSubgrupo) Class TPDMGrupo

	Local n := AScan(::aSubgrupos, {|o| o:Subgrupo == _cSubgrupo})

Return n


Method AddSubgrupo(_cSubgrupo, _cDescricao) Class TPDMGrupo

	Local oSubgrupo

	Local nPos := ::ChkSubgrupo(_cSubgrupo)

	If (nPos > 0) 

		oSubgrupo := ::aSubgrupos[nPos]
		oSubgrupo:Descricao := _cDescricao
		oSubgrupo:DbState	:= _UPDATE

	Else

		oSubgrupo := TPDMSubgrupo():New()
		oSubgrupo:Grupo 	:= ::Grupo
		oSubgrupo:Subgrupo	:= _cSubgrupo
		oSubgrupo:Descricao	:= _cDescricao	

		AAdd(::aSubgrupos, oSubgrupo)	

	EndIf

Return(oSubgrupo)


Method Save() Class TPDMGrupo

	Local nx, ny

	Begin Transaction

		ZD3->(DbSetOrder(1))
		If ZD3->(DbSeek(XFilial("ZD3")+::Grupo))

			RecLock("ZD3",.F.)

		Else

			RecLock("ZD3",.T.)
			ZD3->ZD3_FILIAL := XFilial("ZD3")
			ZD3->ZD3_GRUPO := ::Grupo

		EndIf

		ZD3->ZD3_DESCR := ::Descricao
		ZD3->(MsUnlock())

		For nx := 1 To Len(::aSubgrupos)

			ZD4->(DbSetOrder(1))
			If ZD4->(DbSeek(XFilial("ZD4")+::Grupo+::aSubgrupos[nx]:Subgrupo))

				RecLock("ZD4",.F.)

			Else

				RecLock("ZD4",.T.)
				ZD4->ZD4_FILIAL	:= XFilial("ZD4")
				ZD4->ZD4_GRUPO 	:= ::Grupo
				ZD4->ZD4_SUBGRU := ::aSubgrupos[nx]:Subgrupo

			EndIf

			ZD4->ZD4_DESCR := ::aSubgrupos[nx]:Descricao
			ZD4->(MsUnlock())

			For ny := 1 To Len(::aSubgrupos[nx]:aFamilias)

				ZD5->(DbSetOrder(1))
				If ZD5->(DbSeek(XFilial("ZD5")+::Grupo+::aSubgrupos[nx]:Subgrupo+::aSubgrupos[nx]:aFamilias[ny]:Familia))

					RecLock("ZD5",.F.)

				Else

					RecLock("ZD5",.T.)
					ZD5->ZD5_FILIAL	:= XFilial("ZD5")
					ZD5->ZD5_GRUPO 	:= ::Grupo
					ZD5->ZD5_SUBGRU := ::aSubgrupos[nx]:Subgrupo
					ZD5->ZD5_FAMILI	:= ::aSubgrupos[nx]:aFamilias[ny]:Familia

				EndIf

				ZD5->ZD5_DESCR := ::aSubgrupos[nx]:aFamilias[ny]:Descricao
				ZD5->(MsUnlock())

			Next ny

		Next nx


	End Transaction

Return