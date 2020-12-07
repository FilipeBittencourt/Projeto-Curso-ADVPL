#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//ESTADOS DO MODELO
#DEFINE _UNCHANGED 0
#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3


Class TPDMCaracteristica From LongClassName

//Chave Unica
Data Filial			as String
Data Codigo			as String
Data Revisao		as String
Data Sequencia		as String

//Campos da Caracteristica
Data Ordem			as String
Data Nome			as String
Data Obrigatorio	as String
Data RequerAbrev	as String
Data NomeCompDesc	as String
Data Bloqueio		as String

//Relacionais
Data aValores		as Array init {}

//Controle
Data DbState as Integer

Method New() Constructor
Method Get(_cCodigo, _cRevisao, _cSequencia) Constructor

Method Existe(_cCodigo, _cRevisao, _cSequencia)
Method GetValor(_cItem)
Method ChkValor(_cDescricao)
Method AddValor(_cDescricao, _cAbreviatura, _cBloqueio)
Method ProxItem()
Method IsBloqueado()
Method IsObrigatorio()
Method RequerAbreviatura()

Method ListByPDM(_cCodigo, _cRevisao)
Method Populate(_cOrdem, _cNome, _cObrigatorio, _cRequerAbrev, _cNomeCompDesc)

Method CheckState()
Method Save()

EndClass


Method New() Class TPDMCaracteristica	

	::Filial			:= XFilial("ZD1")
	::Codigo 			:= ""
	::Revisao			:= "" 
	::Sequencia			:= ""

	::Ordem				:= ""
	::Nome				:= ""
	::Obrigatorio		:= ""
	::RequerAbrev		:= ""
	::NomeCompDesc		:= ""
	::Bloqueio			:= "2"

	::aValores			:= {}

	::DbState			:= _NEW

Return(Self)


Method Existe(_cCodigo, _cRevisao, _cSequencia) Class TPDMCaracteristica

	Local lRet := .F.

	lRet := !ZD1->(Eof()) .And. ( ZD1->(ZD1_FILIAL+ZD1_CODIGO+ZD1_REV+ZD1_SEQUEN) == (XFilial("ZD1")+_cCodigo+_cRevisao+_cSequencia) )

	If !lRet

		ZD1->(DbSetOrder(1))
		lRet :=  ZD1->(DbSeek(XFilial("ZD1")+_cCodigo+_cRevisao+_cSequencia))

	EndIf

Return(lRet)


Method Get(_cCodigo, _cRevisao, _cSequencia) Class TPDMCaracteristica

	If ::Existe(_cCodigo, _cRevisao, _cSequencia)

		oVal := TPDMValorCaracteristica():New()

		::Filial		:= ZD1->ZD1_FILIAL
		::Codigo		:= ZD1->ZD1_CODIGO
		::Revisao		:= ZD1->ZD1_REV
		::Sequencia		:= ZD1->ZD1_SEQUEN

		::Ordem			:= ZD1->ZD1_ORDEM
		::Nome			:= ZD1->ZD1_NOME
		::Obrigatorio	:= ZD1->ZD1_OBRIG
		::RequerAbrev	:= ZD1->ZD1_REQABR
		::NomeCompDesc	:= ZD1->ZD1_NCPDES
		::Bloqueio		:= ZD1->ZD1_MSBLQL

		::aValores		:= oVal:ListByCaracteristica(::Codigo, ::Revisao, ::Sequencia)

		::DbState 		:= _UPDATE

		oVal := Nil

	EndIf

Return(Self)


Method GetValor(_cItem) Class TPDMCaracteristica

	Local oValor := Nil
	Local n := AScan(::aValores, {|o| o:Item == _cItem})

	If ( n > 0 )
		oValor := ::aValores[n]
	EndIf

Return(oValor)


Method ChkValor(_cDescricao) Class TPDMCaracteristica

	Local n := AScan(::aValores, {|o| o:Descricao == _cDescricao})

Return n


Method AddValor(_cDescricao, _cAbreviatura, _cBloqueio) Class TPDMCaracteristica

	Local oValor

	Local nPos := ::ChkValor(_cDescricao)

	If (nPos > 0) 

		oValor := ::aValores[nPos]

		oValor:Populate(_cDescricao, _cAbreviatura, _cBloqueio)

	Else

		oValor := TPDMValorCaracteristica():New()
		oValor:Codigo 			:= ::Codigo
		oValor:Revisao			:= ::Revisao
		oValor:Sequencia		:= ::Sequencia
		oValor:Item				:= ::ProxItem()
		oValor:Descricao		:= _cDescricao
		oValor:Abreviatura		:= _cAbreviatura
		oValor:Bloqueio			:= _cBloqueio

		AAdd(::aValores, oValor)	

	EndIf

Return(oValor)


Method ProxItem() Class TPDMCaracteristica

	Local _cItem

	If Len(::aValores) > 0

		_cItem 		:= Soma1(::aValores[Len(::aValores)]:Item, TamSX3("ZD2_ITEM")[1])

	Else

		_cItem := StrZero(1, TamSX3("ZD2_ITEM")[1])

	EndIf

Return(_cItem)


Method ListByPDM(_cCodigo, _cRevisao) Class TPDMCaracteristica

	Local aCaracteristicas := {}
	Local _oCarac
	Local _cAliasTmp

	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp

		SELECT ZD1_SEQUEN FROM %Table:ZD1% where ZD1_FILIAL = %XFILIAL:ZD1% and ZD1_CODIGO = %Exp:_cCodigo% and ZD1_REV = %Exp:_cRevisao% and D_E_L_E_T_=' ' 
		ORDER BY ZD1_CODIGO, ZD1_REV, ZD1_SEQUEN 

	EndSql

	While !(_cAliasTmp)->(Eof())

		_oCarac := TPDMCaracteristica():Get(_cCodigo, _cRevisao, (_cAliasTmp)->ZD1_SEQUEN)

		AAdd(aCaracteristicas, _oCarac)

		(_cAliasTmp)->(DbSkip())
	EndDo

	(_cAliasTmp)->(DbCloseArea())

Return(aCaracteristicas)


Method Populate(_cOrdem, _cNome, _cObrigatorio, _cRequerAbrev, _cNomeCompDesc, _cBloqueio) Class TPDMCaracteristica

	::Ordem			:= _cOrdem
	::Nome			:= _cNome
	::Obrigatorio	:= _cObrigatorio 
	::RequerAbrev	:= _cRequerAbrev
	::NomeCompDesc	:= _cNomeCompDesc
	::Bloqueio		:= _cBloqueio

Return()


Method CheckState() Class TPDMCaracteristica

	If  (::DbState == _DELETE)
		Return
	EndIf
	
	ZD1->(DbSetOrder(1))
	If ZD1->(DbSeek(XFilial("ZD1")+::Codigo+::Revisao+::Sequencia))

		If (;
		::Ordem 		<> ZD1->ZD1_ORDEM .Or.;
		::Nome			<> ZD1->ZD1_NOME .Or.;
		::Obrigatorio	<> ZD1->ZD1_OBRIG .Or.;
		::RequerAbrev	<> ZD1->ZD1_REQABR .Or.;
		::NomeCompDesc	<> ZD1->ZD1_NCPDES .Or.;
		::Bloqueio		<> ZD1->ZD1_MSBLQL;
		)

			::DbState := _UPDATE

		Else

			::DbState := _UNCHANGED

		EndIf

	Else

		::DbState := _NEW

	EndIf

Return


Method IsBloqueado() Class TPDMCaracteristica
Return (::Bloqueio == "1")


Method IsObrigatorio() Class TPDMCaracteristica
Return (::Obrigatorio == "S")


Method RequerAbreviatura() Class TPDMCaracteristica
Return (::RequerAbrev == "S")


Method Save() Class TPDMCaracteristica

	Local nx

	::CheckState()

	If (::DbState == _NEW .Or. ::DbState == _UPDATE)

		If (::DbState == _UPDATE)

			RecLock("ZD1",.F.)

		Else

			RecLock("ZD1",.T.)
			ZD1->ZD1_FILIAL	:= XFilial("ZD1")
			ZD1->ZD1_CODIGO := ::Codigo
			ZD1->ZD1_REV	:= ::Revisao
			ZD1->ZD1_SEQUEN	:= ::Sequencia

		EndIf

		::Ordem	:=	PADL(Alltrim(::Ordem),2,"0")

		ZD1->ZD1_ORDEM	:= ::Ordem
		ZD1->ZD1_NOME	:= ::Nome
		ZD1->ZD1_OBRIG	:= ::Obrigatorio
		ZD1->ZD1_REQABR	:= ::RequerAbrev
		ZD1->ZD1_NCPDES	:= ::NomeCompDesc
		ZD1->ZD1_MSBLQL	:= ::Bloqueio

		ZD1->(MsUnlock())

	ElseIf( ::DbState == _DELETE )

		ZD1->(DbSetOrder(1))
		If ZD1->(DbSeek(XFilial("ZD1")+::Codigo+::Revisao+::Sequencia))

			RecLock("ZD1",.F.)
			ZD1->(DbDelete())
			ZD1->(MsUnlock())

			For nx := 1 To Len(::aValores)

				::aValores[nx]:DbState := _DELETE
				::aValores[nx]:Save()

			Next nx

		EndIf

	EndIf

Return