#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//ESTADOS DO MODELO
#DEFINE _UNCHANGED 0
#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3


Class TPDMModelo From LongClassName

//Chave Unica
Data Filial 	as String
Data Codigo 	as String
Data Revisao 	as String

//Campos do Cabecalho
Data Grupo		as String
Data Subgrupo	as String
Data Familia	as String

Data DescGrupo		as String
Data DescSubgrupo	as String
Data DescFamilia	as String

//Relacionais
Data aCaracteristicas as Array init {}

//Campos do PDM
Data Status			as String
Data DataInclusao	as Date
Data HoraInclusao	as String
Data Usuario		as String

//Controle
Data DbState as Integer

Method New() Constructor
Method Get(_cCodigo, _cRevisao) Constructor
Method GetByCab(_cGrupo, _cSubgrupo, _cFamilia)

Method SetGrupo()
Method SetSubgrupo()
Method SetFamilia()

Method Existe(_cCodigo, _cRevisao)
Method ExisteCab()

Method GetCaracteristica(_cCodigo, _cRevisao, _cSequencia)
Method ChkCaracteristica(_cNome)
Method AddCaracteristica(_cOrdem, _cNome, _cObrigatorio, _cRequerAbrev, _cNomeCompDesc, _cBloqueio)
Method ProxSequencia()

Method CheckState()
Method Save()

EndClass


Method New() Class TPDMModelo	

	::Filial			:= XFilial("ZD0")
	::Codigo 			:= Space(TamSX3("ZD0_CODIGO")[1])
	::Revisao			:= Space(TamSX3("ZD0_REV")[1]) 

	::Grupo				:= Space(TamSX3("ZD0_GRUPO")[1])
	::Subgrupo			:= Space(TamSX3("ZD0_SUBGRU")[1])
	::Familia			:= Space(TamSX3("ZD0_FAMILI")[1])

	::DescGrupo			:= Space(TamSX3("ZD0_NGRU")[1])
	::DescSubgrupo		:= Space(TamSX3("ZD0_NSUBGR")[1])
	::DescFamilia		:= Space(TamSX3("ZD0_NFAMIL")[1])

	::Status			:= ""
	::DataInclusao		:= CTOD(" ")
	::HoraInclusao		:= ""
	::Usuario			:= ""

	::aCaracteristicas	:= {}

	::DbState			:= _NEW

Return(Self)


Method Existe(_cCodigo, _cRevisao) Class TPDMModelo

	Local lRet := .F.
	Local cAliasTmp

	Default _cRevisao := ""

	If !Empty(_cRevisao)

		lRet := !ZD0->(Eof()) .And. ( ZD0->(ZD0_FILIAL+ZD0_CODIGO+ZD0_REV) == (XFilial("ZD0")+_cCodigo+_cRevisao) )

		If !lRet

			ZD0->(DbSetOrder(1))
			lRet :=  ZD0->(DbSeek(XFilial("ZD0")+_cCodigo+_cRevisao))

		EndIf

	Else

		//buscar ultima revisao
		ZD0->(DbSetOrder(1))
		If ZD0->(DbSeek(XFilial("ZD0")+_cCodigo))

			ZD0->(DbSeek(XFilial("ZD0")+_cCodigo+"999"))
			ZD0->(DbSkip(-1))

			lRet := !ZD0->(Eof()) .And. ( ZD0->(ZD0_FILIAL+ZD0_CODIGO) == (XFilial("ZD0")+_cCodigo) )

		EndIf

	EndIf

Return(lRet)


Method Get(_cCodigo, _cRevisao) Class TPDMModelo

	Default _cRevisao := ""

	If ::Existe(_cCodigo, _cRevisao)

		oCarac := TPDMCaracteristica():New()

		::Filial			:= ZD0->ZD0_FILIAL
		::Codigo			:= ZD0->ZD0_CODIGO
		::Revisao			:= ZD0->ZD0_REV

		::SetGrupo(ZD0->ZD0_GRUPO)
		::SetSubgrupo(ZD0->ZD0_SUBGRU) 
		::SetFamilia(ZD0->ZD0_FAMILI)

		::Status			:= ZD0->ZD0_STATUS
		::DataInclusao		:= ZD0->ZD0_DATINC
		::HoraInclusao		:= ZD0->ZD0_HORINC
		::Usuario			:= ZD0->ZD0_USUCAD

		::aCaracteristicas	:= oCarac:ListByPDM(::Codigo, ::Revisao)

		::DbState 			:= _UPDATE

		oCarac := Nil

	EndIf

Return(Self)


Method GetByCab(_cGrupo, _cSubgrupo, _cFamilia) Class TPDMModelo

	Local cAliasTmp

	Default _cGrupo 	:= ::Grupo
	Default _cSubgrupo 	:= ::Subgrupo
	Default _cFamilia 	:= ::Familia

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp

		select ZD0_CODIGO, ZD0_REV from %Table:ZD0% where ZD0_FILIAL = %XFILIAL:ZD0% and ZD0_GRUPO = %Exp:_cGrupo% and ZD0_SUBGRU = %Exp:_cSubgrupo% and ZD0_FAMILI = %Exp:_cFamilia% and ZD0_STATUS = 'S' and %NotDel%

	EndSql

	If !(cAliasTmp)->(Eof())

		::Get((cAliasTmp)->ZD0_CODIGO, (cAliasTmp)->ZD0_REV)  

	EndIf

	(cAliasTmp)->(DbCloseArea())

Return()


Method SetGrupo(_cConteudo) Class TPDMModelo

	::Grupo			:= _cConteudo

	If !Empty(::Grupo)
		::DescGrupo		:= POSICIONE("ZD3",1,XFILIAL("ZD3")+::Grupo,"ZD3_DESCR")
	Else
		::DescGrupo		:= Space(TamSX3("ZD3_DESCR")[1])
	EndIf

	::SetSubgrupo(Space(TamSX3("ZD0_SUBGRU")[1]))	

Return


Method SetSubgrupo(_cConteudo) Class TPDMModelo

	::Subgrupo		:= _cConteudo

	If !Empty(::Subgrupo)
		::DescSubgrupo	:= POSICIONE("ZD4",1,XFILIAL("ZD4")+::Grupo+::Subgrupo,"ZD4_DESCR") 
	Else
		::DescSubgrupo	:= Space(TamSX3("ZD4_DESCR")[1])
	EndIf

	::SetFamilia(Space(TamSX3("ZD0_FAMILI")[1]))

Return


Method SetFamilia(_cConteudo) Class TPDMModelo

	::Familia		:= _cConteudo 

	If !Empty(::Familia)
		::DescFamilia	:= POSICIONE("ZD5",1,XFILIAL("ZD5")+::Grupo+::Subgrupo+::Familia,"ZD5_DESCR")
	Else
		::DescFamilia	:= Space(TamSX3("ZD5_DESCR")[1])
	EndIf

Return


Method GetCaracteristica(_cSequencia) Class TPDMModelo

	Local oCarac := Nil
	Local n := AScan(::aCaracteristicas, {|o| o:Sequencia == _cSequencia})

	If ( n > 0 )
		oCarac := ::aCaracteristicas[n]
	EndIf

Return(oCarac)


Method ChkCaracteristica(_cNome) Class TPDMModelo

	Local n := AScan(::aCaracteristicas, {|o| o:Nome == _cNome})

Return n


Method AddCaracteristica(_cOrdem, _cNome, _cObrigatorio, _cRequerAbrev, _cNomeCompDesc, _cBloqueio) Class TPDMModelo

	Local oCarac

	Local nPos := ::ChkCaracteristica(_cNome)

	If (nPos > 0) 

		oCarac := ::aCaracteristicas[nPos]

		oCarac:Populate(_cOrdem, _cNome, _cObrigatorio, _cRequerAbrev, _cNomeCompDesc, _cBloqueio)

	Else

		oCarac := TPDMCaracteristica():New()
		oCarac:Codigo 		:= ::Codigo
		oCarac:Revisao		:= ::Revisao
		oCarac:Sequencia	:= ::ProxSequencia()
		oCarac:Ordem		:= _cOrdem
		oCarac:Nome			:= _cNome
		oCarac:Obrigatorio	:= _cObrigatorio 
		oCarac:RequerAbrev	:= _cRequerAbrev
		oCarac:NomeCompDesc	:= _cNomeCompDesc
		oCarac:Bloqueio		:= _cBloqueio

		AAdd(::aCaracteristicas, oCarac)	

	EndIf

Return(oCarac)


Method ProxSequencia() Class TPDMModelo

	Local _cSequencia

	If Len(::aCaracteristicas) > 0

		_cSequencia := Soma1(::aCaracteristicas[Len(::aCaracteristicas)]:Sequencia, TamSX3("ZD1_SEQUEN")[1])

	Else

		_cSequencia := StrZero(1, TamSX3("ZD1_SEQUEN")[1])

	EndIf

Return(_cSequencia)


Method CheckState() Class TPDMModelo

	If  (::DbState == _DELETE)
		Return
	EndIf

	ZD0->(DbSetOrder(1))
	If ZD0->(DbSeek(XFilial("ZD0")+::Codigo+::Revisao))

		If (;
		::Grupo		<> ZD0->ZD0_GRUPO .Or.;
		::Subgrupo	<> ZD0->ZD0_SUBGRU .Or.;
		::Familia	<> ZD0->ZD0_FAMILI;
		)

			::DbState := _UPDATE

		Else

			::DbState := _UNCHANGED

		EndIf

	Else

		::DbState := _NEW

	EndIf

Return


Method Save() Class TPDMModelo

	Local nx, ny

	Begin Transaction

		::CheckState()

		If (::DbState == _NEW .Or. ::DbState == _UPDATE)

			If ( ::DbState == _UPDATE )

				RecLock("ZD0",.F.)

			Else

				RecLock("ZD0",.T.)
				ZD0->ZD0_FILIAL	:= XFilial("ZD0")
				ZD0->ZD0_CODIGO := ::Codigo
				ZD0->ZD0_REV	:= ::Revisao

				ZD0->ZD0_STATUS := "S"
				ZD0->ZD0_DATINC := dDataBase
				ZD0->ZD0_HORINC	:= SubStr(Time(),1,5)
				ZD0->ZD0_USUCAD	:= CUSERNAME

			EndIf

			ZD0->ZD0_GRUPO		:= ::Grupo
			ZD0->ZD0_SUBGRU		:= ::Subgrupo
			ZD0->ZD0_FAMILI		:= ::Familia

			ZD0->(MsUnlock())
			
		ElseIf ::DbState == _DELETE
		
			RecLock("ZD0",.F.)
			ZD0->(DbDelete())
			ZD0->(MsUnlock())
			
		EndIf

		For nx := 1 To Len(::aCaracteristicas)

			::aCaracteristicas[nx]:Save()

			If ( ::aCaracteristicas[nx]:DbState <> _DELETE )			

				For ny := 1 To Len(::aCaracteristicas[nx]:aValores)

					::aCaracteristicas[nx]:aValores[ny]:Save()

				Next ny

			EndIf

		Next nx


	End Transaction

Return


Method ExisteCab() Class TPDMModelo

	Local lRet
	Local oPDM := TPDMModelo():New()

	oPDM:GetByCab(::Grupo, ::Subgrupo, ::Familia)

	lRet :=  !Empty(oPDM:Codigo)

	oPDM := Nil
	
Return(lRet)