#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


Class TPDMProduto From LongClassName

Data oPDM
Data Tipo

Data lPDMOk
Data lCaracOk
Data cErro

Data aLstValCar  //Lista de valores selecionados por caracteristica

Data cCodAnt
Data cNewCod
Data cDescCompl
Data cDescAbrev
Data cNCM
Data cGrupoSBM
Data cUM

Data aLstMarcas //Listas de marcas do produto

Data nTamDesc
Data nTamAbrev

Method New() Constructor

Method SetPDM(_cGrupo, _cSubgrupo, _cFamilia)
Method Valid()
Method ChkDuplicidade()
Method GeraDescricao()
Method SetPrdMemoria()
Method SetPrdPosicionado()
Method Salvar()
Method IncluiZD7()
Method SetWSPDM()
Method SalvarMarcas()
Method NovoCodigo()
Method CopiarSBZ()
Method ReplicaSBZ()

EndClass


Method New() Class TPDMProduto

	::oPDM := TPDMModelo():New()

	::Tipo		:= Space(TamSX3("B1_TIPO")[1])

	::lPDMOk	:= .F.
	::lCaracOk	:= .F.
	::cErro

	::aLstValCar := {}

	::cCodAnt		:= ""
	::cNewCod		:= ""
	::cDescCompl 	:= ""
	::cDescAbrev 	:= ""
	::cNCM			:= ""
	::cGrupoSBM		:= ""
	::cUM			:= ""

	::aLstMarcas 	:= {}

	::nTamDesc		:= TamSX3("B1_DESC")[1]
	::nTamAbrev		:= TamSX3("B1_DESBSE3")[1]

Return


Method SetPDM(_cGrupo, _cSubgrupo, _cFamilia) Class TPDMProduto

	Local lRet := .T.

	Default _cGrupo		:= Nil
	Default _cSubgrupo	:= Nil
	Default _cFamilia	:= Nil

	::oPDM:GetByCab(_cGrupo, _cSubgrupo, _cFamilia)

	If Empty(::oPDM:Codigo)

		lRet := .F.

	Else

		::lPDMOk := .T.

	EndIf

Return(lRet)


Method Valid() Class TPDMProduto

	Local nx
	Local lRet	:= ::lPDMOk
	Local _nPosIt
	Local _cItem
	Local _aPrdDupl := {.F., .F., "", .F.}
	Local _oCarac
	Local _oValor

	::cErro := ""

	For nx := 1 To Len(::aLstValCar)

		_oCarac := TPDMCaracteristica():Get(::oPDM:Codigo, ::oPDM:Revisao, ::aLstValCar[nx][1])

		If Empty(_oCarac:Codigo)

			::cErro += "Lista de Características => Linha: "+AllTrim(Str(nx))+" - Característica("+::aLstValCar[nx][1]+") não encontrada/inválida."+CRLF

		ElseIf _oCarac:IsBloqueado()

			::cErro += "Lista de Características => Linha: "+AllTrim(Str(nx))+" - Característica("+::aLstValCar[nx][1]+") BLOQUEADA."+CRLF

		EndIf

		_oValor := TPDMValorCaracteristica():Get(::oPDM:Codigo, ::oPDM:Revisao, ::aLstValCar[nx][1], ::aLstValCar[nx][2])

		If Empty(_oValor:Codigo)

			::cErro += "Lista de Características => Linha: "+AllTrim(Str(nx))+" - Característica("+::aLstValCar[nx][1]+")/Valor("+::aLstValCar[nx][2]+") não encontrado/inválido."+CRLF

		ElseIf _oValor:IsBloqueado()

			::cErro += "Lista de Características => Linha: "+AllTrim(Str(nx))+" - Característica("+::aLstValCar[nx][1]+")/Valor("+::aLstValCar[nx][2]+") BLOQUEADO."+CRLF

		EndIf

		_oCarac := Nil
		_oValor := Nil

	Next nx

	If ( lRet := Empty(::cErro) )

		//verificando caracteristicas obrigatorias
		ZD1->(DbSetOrder(1)) //ZD1_FILIAL, ZD1_CODIGO, ZD1_REV, ZD1_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
		If ZD1->(DbSeek(XFilial("ZD1")+::oPDM:Codigo+::oPDM:Revisao))

			While !ZD1->(Eof()) .And. ZD1->(ZD1_FILIAL+ZD1_CODIGO+ZD1_REV) == (XFilial("ZD1")+::oPDM:Codigo+::oPDM:Revisao)

				_nPosIt := aScan(::aLstValCar,{|x| x[1] == ZD1->ZD1_SEQUEN})

				_oCarac := TPDMCaracteristica():Get(::oPDM:Codigo, ::oPDM:Revisao, ZD1->ZD1_SEQUEN)

				If !_oCarac:IsBloqueado()

					If _oCarac:IsObrigatorio() .And.  _nPosIt <= 0

						::cErro += "Característica: "+AllTrim(ZD1->ZD1_SEQUEN)+"-"+AllTrim(ZD1->ZD1_NOME)+" - Característica obrigatória não informada."+CRLF

					Else

						If _nPosIt > 0

							_cItem := ::aLstValCar[_nPosIt][2]

							_oValor := TPDMValorCaracteristica():Get(::oPDM:Codigo, ::oPDM:Revisao, ZD1->ZD1_SEQUEN, _cItem)

							If _oCarac:RequerAbreviatura() .And. Empty(_oValor:Abreviatura)

								::cErro += "Característica: "+AllTrim(ZD1->ZD1_SEQUEN)+"-"+AllTrim(ZD1->ZD1_NOME)+" - Abreviatura obrigatória, valor sem abreviatura."+CRLF

							EndIf

						EndIf

					EndIf

				EndIf

				ZD1->(DbSkip())
			EndDo

		EndIf

	EndIf

	If ( lRet := Empty(::cErro) )

		::GeraDescricao()

		If Len(AllTrim(::cDescCompl)) > ::nTamDesc

			::cErro += "PDM gerando descrição maior que "+AllTrim(Str(::nTamDesc))+" caracteres (total: "+AllTrim(Str(Len(AllTrim(::cDescCompl))))+" caracteres), favor revisar."+CRLF

		EndIf

		If Len(AllTrim(::cDescAbrev)) > ::nTamAbrev

			::cErro += "PDM gerando descrição abreviada maior que "+AllTrim(Str(::nTamAbrev))+" caracteres (total: "+AllTrim(Str(Len(AllTrim(::cDescAbrev))))+" caracteres), favor revisar."+CRLF

		EndIf

	EndIf	

	lRet := lRet .And. Empty(::cErro)

	If lRet

		_aPrdDupl := ::ChkDuplicidade()

		If _aPrdDupl[1]

			::cErro += "Produto já existe com o mesmo PDM / Características." + CRLF + _aPrdDupl[3]

			lRet := .F.

		ElseIf _aPrdDupl[2]

			_aPrdDupl[3] := "Produto já existe com o mesmo PDM / Características." + CRLF + _aPrdDupl[3]

			::cErro += _aPrdDupl[3]

			lRet := .F.

		EndIf	

	EndIf

Return({lRet, _aPrdDupl[3], _aPrdDupl[4]})


Method ChkDuplicidade() Class TPDMProduto

	Local cAliasTmp
	Local cSQL
	Local nx
	Local cReturn := ""
	Local _oCarac
	Local _lDupl := .F.
	Local _lDuplMarca := .F.
	Local oMarca
	Local aMarca := {}
	Local lMarPtNum := .F.
	Local I

	cAliasTmp := GetNextAlias()

	cSQL := ""

	cSQL += "select B1_COD "+CRLF
	cSQL += "from "+RetSQLName("SB1")+" SB1 (nolock) "+CRLF
	cSQL += "where B1_FILIAL = '"+XFilial("SB1")+"' "+CRLF
	cSQL += "and B1_TIPO = '"+::Tipo+"' "+CRLF 
	cSQL += "and B1_YGRPPDM = '"+::oPDM:Grupo+"' "+CRLF 
	cSQL += "and B1_YSUBPDM = '"+::oPDM:Subgrupo+"' "+CRLF 
	cSQL += "and B1_YFAMPDM = '"+::oPDM:Familia+"' "+CRLF

	//cSQL += "and (select count(1) from "+RetSQLName("ZD7")+" ZD7 (nolock) where ZD7_FILIAL = B1_FILIAL and ZD7_PDM = substring(B1_YPDM,1,9) and ZD7_REV = substring(B1_YPDM,10,3) and ZD7_PRODUT = B1_COD and ZD7.D_E_L_E_T_='') = "+AllTrim(Str(Len(::aLstValCar)))+" "+CRLF

	For nx := 1 To Len(::aLstValCar)

		_oCarac := TPDMCaracteristica():Get(::oPDM:Codigo, ::oPDM:Revisao, ::aLstValCar[nx][1])
		If _oCarac:IsObrigatorio()

			cSQL += "and exists (select 1 from "+RetSQLName("ZD7")+" ZD7 (nolock) where ZD7_FILIAL = B1_FILIAL and ZD7_PDM = substring(B1_YPDM,1,9) and ZD7_REV = substring(B1_YPDM,10,3) and ZD7_PRODUT = B1_COD and ZD7_SEQUEN = '"+::aLstValCar[nx][1]+"' and ZD7_ITEM = '"+::aLstValCar[nx][2]+"' and ZD7.D_E_L_E_T_='') "+CRLF

		EndIf

	Next nx

	cSQL += "and SB1.D_E_L_E_T_='' "+CRLF

	TCQuery cSQL Alias (cAliasTmp) New

	While !(cAliasTmp)->(Eof())

		If Len(::aLstMarcas) > 0

			For I := 1 To Len(::aLstMarcas)

				oMarca := Nil
				oMarca := TPDMMarca():Get(AllTrim(::aLstMarcas[I][1]), AllTrim(::aLstMarcas[I][2]))

				aAdd(::aLstMarcas[I], oMarca)

			Next I

			For I := 1 To Len(::aLstMarcas)

				If !Empty(::aLstMarcas[I][5]) .And. !Empty(::aLstMarcas[I][5]:Codigo)

					ZD6->(DbSetOrder(1)) // ZD6_FILIAL, ZD6_COD, ZD6_CODMAR, ZD6_REFER, R_E_C_N_O_, D_E_L_E_T_
					ZD6->(DBGoTop())

					If ZD6->(DbSeek(XFilial("ZD6") + PADR((cAliasTmp)->B1_COD, TamSX3("ZD6_COD")[1]) + PADR(::aLstMarcas[I][5]:Codigo,TamSX3("ZD6_CODMAR")[1]) + PADR(::aLstMarcas[I][3],TamSX3("ZD6_REFER")[1])))

						//While ZD6->(!EOF()) .And. ZD6->(ZD6_FILIAL + ZD6_COD + ZD6_CODMAR + ZD6_REFER) == XFilial("ZD6") + PADR((cAliasTmp)->B1_COD, TamSX3("ZD6_COD")[1])

						_lDuplMarca := .T.

						If aScan(aMarca, {|x| x[1] + x[2] + x[3] + x[4] == ZD6->(ZD6_COD + ZD6_CODMAR + ZD6_MARCA + ZD6_REFER)}) == 0

							aAdd(aMarca, {ZD6->ZD6_COD, ZD6->ZD6_CODMAR, ZD6->ZD6_MARCA, ZD6->ZD6_REFER, If(ZD6->(ZD6_CODMAR + ZD6_REFER) == ::aLstMarcas[I][1] + ::aLstMarcas[I][3], .T., .F.)})

						EndIf

						//ZD6->(DbSkip())

						//EndDo

					EndIf

				EndIf

			Next I		

		Else

			_lDupl := .T.

			cReturn := (cAliasTmp)->B1_COD

		EndIf	

		(cAliasTmp)->(DbSkip())

	EndDo

	For nx := 1 To Len(aMarca)

		cReturn += "Produto: " 			+ AllTrim(aMarca[nx][1]) +;
		" - Cod.Marca: " 	+ AllTrim(aMarca[nx][2]) + "-" + AllTrim(aMarca[nx][3]) +;
		" - Ref.Part/Num: " 	+ AllTrim(aMarca[nx][4]) + AllTrim(aMarca[nx][5]) +;
		If(aMarca[nx][5], " (Duplicidade)", "") + CRLF

		If ! lMarPtNum

			If aMarca[nx][5]

				lMarPtNum := .T.

			EndIf

		EndIf

	Next nx

	oMarca := Nil
	(cAliasTmp)->(DbCloseArea())

Return({_lDupl, _lDuplMarca, cReturn, lMarPtNum})


Method GeraDescricao()  Class TPDMProduto

	Local nx
	Local _nPosIt
	Local _cItem
	Local _oCarac
	Local _oValor

	::cDescCompl := ""
	::cDescAbrev := ""

	_aCaracOrd := aSort(::oPDM:aCaracteristicas,,,{|x,y| x:Ordem < y:Ordem }) 

	For nx := 1 To Len(_aCaracOrd)

		_oCarac := _aCaracOrd[nx]

		_nPosIt := aScan(::aLstValCar,{|x| x[1] == _oCarac:Sequencia})

		If _nPosIt > 0

			_cItem := ::aLstValCar[_nPosIt][2]

			_oValor := TPDMValorCaracteristica():Get(::oPDM:Codigo, ::oPDM:Revisao, _oCarac:Sequencia, _cItem)

			If !Empty(_oValor:Codigo)

				If !Empty(::cDescCompl)

					::cDescCompl += " "

				EndIf

				If !Empty(_oValor:Abreviatura) .And. !Empty(::cDescAbrev)

					::cDescAbrev += " "

				EndIf

				If _oCarac:NomeCompDesc == "S"

					::cDescCompl += AllTrim(_oCarac:Nome) + " "

				EndIf

				::cDescCompl += AllTrim(_oValor:Descricao)

				If !Empty(_oValor:Abreviatura)

					::cDescAbrev += AllTrim(_oValor:Abreviatura)

				EndIf

			EndIf

		EndIf

	Next nx

Return


Method SetPrdMemoria() Class TPDMProduto

	M->B1_TIPO		:= ::Tipo
	M->B1_DESC		:= ::cDescCompl
	M->B1_DESBSE3 	:= ::cDescAbrev  //campo padrao nao usado
	M->B1_YPDM		:= ::oPDM:Codigo+::oPDM:Revisao
	M->B1_YGRPPDM	:= ::oPDM:Grupo
	M->B1_YSUBPDM	:= ::oPDM:Subgrupo
	M->B1_YFAMPDM	:= ::oPDM:Familia		

Return


Method SetPrdPosicionado() Class TPDMProduto

	RecLock("SB1",.F.)

	SB1->B1_DESC	:= ::cDescCompl
	SB1->B1_DESBSE3 := ::cDescAbrev  //campo padrao nao usado
	SB1->B1_YPDM	:= ::oPDM:Codigo+::oPDM:Revisao
	SB1->B1_YGRPPDM	:= ::oPDM:Grupo
	SB1->B1_YSUBPDM	:= ::oPDM:Subgrupo
	SB1->B1_YFAMPDM	:= ::oPDM:Familia

	SB1->(MsUnlock())	

Return


Method Salvar(_lMemory) Class TPDMProduto

	Default _lMemory := .F.

	If ( _lMemory )

		::SetPrdMemoria()

	Else

		::SetPrdPosicionado()

	EndIf

	If Type("__MEMPDM_ALST") <> "U"
		__MEMPDM_ALST := Nil
	EndIf

	Public __MEMPDM_ALST := ::aLstValCar  //Para usar no ponto de entrada MT010INC para salvar o ZD7

Return


Method IncluiZD7(_cProduto) Class TPDMProduto

	Local nx

	Begin Transaction

		ZD7->(DbSetOrder(1))  //ZD7_FILIAL, ZD7_PDM, ZD7_REV, ZD7_PRODUT, ZD7_SEQUEN, ZD7_ITEM, R_E_C_N_O_, D_E_L_E_T_
		If ZD7->(DbSeek(XFilial("ZD7")+::oPDM:Codigo+::oPDM:Revisao+_cProduto))

			While !ZD7->(Eof()) .And. ZD7->(ZD7_FILIAL+ZD7_PDM+ZD7_REV+ZD7_PRODUT) == (XFilial("ZD7")+::oPDM:Codigo+::oPDM:Revisao+_cProduto)

				RecLock("ZD7",.F.)
				ZD7->(DbDelete())
				ZD7->(MsUnlock())

				ZD7->(DbSkip())
			EndDo 

		EndIf

		For nx := 1 To Len(::aLstValCar)

			RecLock("ZD7",.T.)

			ZD7->ZD7_FILIAL 	:= XFilial("ZD7")
			ZD7->ZD7_PDM		:= ::oPDM:Codigo
			ZD7->ZD7_REV		:= ::oPDM:Revisao
			ZD7->ZD7_PRODUT		:= _cProduto
			ZD7->ZD7_SEQUEN		:= ::aLstValCar[nx][1]
			ZD7->ZD7_ITEM		:= ::aLstValCar[nx][2]

			ZD7->(MsUnlock())

		Next nx

	End Transaction

Return


Method SetWSPDM(cCodigo, oWsProduto) Class TPDMProduto

	Local nx
	Local aAux
	Local aRet := {.T.,""}

	If Empty(oWsProduto:Tipo) .Or. Empty(oWsProduto:GrupoPDM) .Or. Empty(oWsProduto:SubgrupoPDM) .Or. Empty(oWsProduto:FamiliaPDM)

		aRet[1] := .F.
		aRet[2] := "PDM - Parametros obrigatorios não informados - Tipo/Grupo/Subgrupo/Familia."

	EndIf

	If aRet[1]

		::Tipo 			:= oWsProduto:Tipo
		::oPDM:Grupo 	:= oWsProduto:GrupoPDM
		::oPDM:Subgrupo	:= oWsProduto:SubgrupoPDM
		::oPDM:Familia 	:= oWsProduto:FamiliaPDM

		If ( ::SetPDM() )

			//adicionando caracteristicas/valores
			For nx := 1 To Len(oWsProduto:aPDMCaracteristicas)

				aAux := {}
				aAdd(aAux, oWsProduto:aPDMCaracteristicas[nx]:Sequencia)
				aAdd(aAux, oWsProduto:aPDMCaracteristicas[nx]:Item)

				aAdd(::aLstValCar, aAux)

			Next nx

			//adicionando marcas
			For nx := 1 To len(oWsProduto:aPDMMarcas)

				aAux := {}
				aAdd(aAux, oWsProduto:aPDMMarcas[nx]:Marca) 		//WS Codigo da marca
				aAdd(aAux, "")										//Descricao
				aAdd(aAux, oWsProduto:aPDMMarcas[nx]:Referencia)	//WS Referencia
				aAdd(aAux, oWsProduto:aPDMMarcas[nx]:InfAdicional)	//WS InfAd

				aAdd(::aLstMarcas, aAux)

			Next nx			

			If !( ::Valid() )

				aRet[1] := .F.
				aRet[2] := ::cErro

			EndIf

			If ( aRet[1] )

				::Salvar()
				::IncluiZD7(cCodigo)
				::SalvarMarcas(cCodigo)

			EndIf
		Else

			aRet[1] := .F.
			aRet[2] := "PDM - não localizado ou não está ativo."

		EndIf

	EndIf

Return( aRet )


Method SalvarMarcas(cCodigo) Class TPDMProduto

	Local nx
	Local oMarcaProd
	Local oMarca

	For nx := 1 To Len(::aLstMarcas)


		oMarca := TPDMMarca():Get(AllTrim(::aLstMarcas[nx][1]), AllTrim(::aLstMarcas[nx][2]))

		If Empty(oMarca:Codigo)

			oMarca := TPDMMarca():New()
			oMarca:Filial			:= XFilial("ZD8")
			oMarca:Codigo			:= ::aLstMarcas[nx][1]
			oMarca:Descricao		:= ::aLstMarcas[nx][2]
			oMarca:Save()

		EndIf

		oMarcaProd := TPDMProdutoMarca():Get(cCodigo, oMarca:Codigo, ::aLstMarcas[nx][3])

		If Empty(oMarcaProd:Produto)

			oMarcaProd := TPDMProdutoMarca():New()

			oMarcaProd:Filial 	:= XFilial("ZD6")
			oMarcaProd:Produto 	:= cCodigo
			oMarcaProd:CodMarca	:= oMarca:Codigo
			oMarcaProd:Marca	:= oMarca:Descricao
			oMarcaProd:Referencia 	:= ::aLstMarcas[nx][3]

		EndIf

		oMarcaProd:InfAdicional := ::aLstMarcas[nx][4]

		oMarcaProd:Save()

		oMarcaProd := Nil

	Next nx

Return


Method NovoCodigo() Class TPDMProduto

	Local _aRet
	Local aVetor := {}
	Local CodRet := ""
	Local DscRet := ""
	Local cAliasTmp
	Local cCodAnt := ::cCodAnt
	Local cPolit
	//
	Local _cError
	Local _cLogTxt
	//
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T. 

	BEGIN TRANSACTION

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(XFilial("SB1")+::cCodAnt))

		cPolit := SB1->B1_YPOLIT
		If ( SB1->B1_YPOLIT == "1")
			cPolit := "8"
		EndIf

		aVetor:= {;
		{"B1_FILIAL"	, XFILIAL("SB1")	, Nil},;
		{"B1_GRUPO"		, ::cGrupoSBM		, Nil},;
		{"B1_TIPO"		, ::Tipo			, Nil},;
		{"B1_YPOLIT"	, cPolit			, Nil},;
		{"B1_DESC"		, ::cDescCompl		, Nil},;
		{"B1_UM"		, ::CUM				, Nil},;
		{"B1_LOCPAD"	, SB1->B1_LOCPAD	, Nil},;
		{"B1_CONV"		, SB1->B1_CONV		, Nil},;
		{"B1_LOCALIZ"	, SB1->B1_LOCALIZ	, Nil},;
		{"B1_POSIPI"	, ::cNCM			, Nil},;
		{"B1_YPECA"		, SB1->B1_YPECA		, Nil},;
		{"B1_YDIVPA"	, SB1->B1_YDIVPA	, Nil},;
		{"B1_ORIGEM"	, SB1->B1_ORIGEM	, Nil},;
		{"B1_CLASFIS"	, SB1->B1_CLASFIS	, Nil},;
		{"B1_YTIPO"		, SB1->B1_YTIPO		, Nil},;
		{"B1_TIPCONV"	, SB1->B1_TIPCONV	, Nil},;
		{"B1_EMIN"		, SB1->B1_EMIN		, Nil},;
		{"B1_ESTSEG"	, SB1->B1_ESTSEG	, Nil},;
		{"B1_LE"		, SB1->B1_LE		, Nil},;
		{"B1_LM"		, SB1->B1_LM		, Nil},;
		{"B1_EMAX"		, SB1->B1_EMAX		, Nil},;
		{"B1_YUSER"		, "PDMXLS"			, Nil},;
		{"B1_YLOCALI"	, SB1->B1_YLOCALI	, Nil},;
		{"B1_YLOCINC"	, SB1->B1_YLOCINC	, Nil},;		
		{"B1_YLOCUSO"	, SB1->B1_YLOCUSO	, Nil},;
		{"B1_CODANT"	, ::cCodAnt			, Nil}}


		// EXECUTA EXECAUTO PARA INCLUSAO DE NOVO PRODUTO
		lMsErroAuto := .F.
		_cLogTxt := ""
		MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)

		// VERIFICA ERRO NA EXECUCAO DO 'MSExecAuto'
		If lMsErroAuto                   		

			aAutoErro := GETAUTOGRLOG()
			_cLogTxt += XCONVERRLOG(aAutoErro)

			CodRet 	:= 9
			DscRet	:= "TPDMProduto:NovoCodigo(): "+CRLF+_cLogTxt

			DisarmTransaction()

		Else

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp

				select top 1 B1_COD from %Table:SB1% where B1_FILIAL = %XFilial:SB1% and B1_CODANT = %Exp:cCodAnt% and %NotDel%

			EndSql

			If !(cAliasTmp)->(Eof())

				::cNewCod := (cAliasTmp)->B1_COD

			EndIf
			(cAliasTmp)->(DbCloseArea())


			If !Empty(::cNewCod)

				CodRet := 0
				DscRet	:= "Produto '" + ALLTRIM(::cNewCod) + "' inserido com sucesso!"				

				//INCLUI INDICADORES DE PRODUTO - Tabela SBZ.
				::CopiarSBZ()

			Else	

				CodRet := 9
				DscRet	:= "TPDMProduto:NovoCodigo() : Produto '" + ::cNewCod + "' não encontrado no Banco de Dados."
				DisarmTransaction()	

			EndIf

		EndIf

		_aRet	:=	{CodRet,DscRet}		

	END TRANSACTION

Return(_aRet)


Method CopiarSBZ() Class TPDMProduto

	Local cLstEmp := "01_05_07_12_13_14_16_17"
	Local aLstEmp
	Local nx
	Local _cSql	:=	""
	Local _lZCNINC	:=	.F.
	Local x

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1") + ::cNewCod))

		SBZ->(DbSetOrder(1))
		IF !SBZ->(DbSeek(xFilial("SBZ") + ::cNewCod))

			cIndex  := ""
			cArq    := ""
			cInd    := ""

			cArq:="SBZ"+AllTrim(CEMPANT)+"0"
			DbSelectArea("SIX")
			DbSetOrder(1)
			DbSeek("SBZ")
			Do while .not. eof() .and. INDICE=="SBZ"
				cIndex+=cArq+SIX->ORDEM
				DbSkip()
			EndDo
			If chkfile("_SBZ")
				DbSelectArea("_SBZ")
				DbCloseArea()
			EndIf
			Use &cArq Alias "_SBZ" Shared New Via "TopConn"
			For x:=1 to 4 step 7
				cInd := Subs(cIndex,x,7)
				DbSetIndex(cInd)
			Next

			_SBZ->(dbSetOrder(1))
			If _SBZ->(dbSeek(xFilial("SBZ")+::cCodAnt,.F.))

				RecLock("SBZ",.T.)
				SBZ->BZ_FILIAL 	:= _SBZ->BZ_FILIAL 	
				SBZ->BZ_COD 	:= ::cNewCod	
				SBZ->BZ_YDESC 	:= SB1->B1_DESC	
				SBZ->BZ_LOCPAD 	:= _SBZ->BZ_LOCPAD 	
				SBZ->BZ_YBLSCPC := _SBZ->BZ_YBLSCPC 
				SBZ->BZ_YSOLIC  := _SBZ->BZ_YSOLIC  
				SBZ->BZ_LM		:= _SBZ->BZ_LM		
				SBZ->BZ_EMAX	:= _SBZ->BZ_EMAX	
				SBZ->BZ_UCOM    := _SBZ->BZ_UCOM    
				SBZ->BZ_CUSTD   := _SBZ->BZ_CUSTD   
				SBZ->BZ_ORIGEM  := _SBZ->BZ_ORIGEM  
				SBZ->BZ_YATIVO	:= _SBZ->BZ_YATIVO	
				SBZ->BZ_YEMPENH := _SBZ->BZ_YEMPENH 
				SBZ->BZ_GRTRIB 	:= _SBZ->BZ_GRTRIB 	
				SBZ->BZ_YATIVO  := _SBZ->BZ_YATIVO  
				SBZ->BZ_LOCALIZ := _SBZ->BZ_LOCALIZ 								

				SBZ->(MsUnLock())

				DbSelectArea("ZCN")
				ZCN->(DbSetOrder(1))
				If ZCN->(DbSeek(xFilial("ZCN")+::cCodAnt+'1')) .And. !ZCN->(DbSeek(xFilial("ZCN")+::cNewCod+'1')) 
					//Inserir sempre na Bianco
					_cSql	:=	" INSERT INTO ZCN010 "  //Inserir sempre na Bianco
					_cSql	+=	" SELECT ZCN_FILIAL, '" + ::cNewCod + "'," + "ZCN_SEQUEN,ZCN_LOCAL,ZCN_ESTSEG,ZCN_PONPED,ZCN_LE,ZCN_LOCALI,''," 
					_cSql	+=	" 		(SELECT MAX(R_E_C_N_O_) + 1 FROM ZCN010),0,ZCN_PORTAR,ZCN_POLIT,ZCN_MD,ZCN_COMUM,ZCN_OBSOLE,ZCN_SOLIC" 
					_cSql	+=	" FROM ZCN010 " 
					_cSql	+=	" WHERE ZCN_FILIAL = '01' " 
					_cSql	+=	" 	AND ZCN_COD = " + ValtoSql(::cCodAnt) + " " 
					_cSql	+=	" 	AND ZCN_SEQUEN = '1' "
					_cSql	+=	" 	AND D_E_L_E_T_  = '' "
					TcSqlExec(_cSql)
				EndIf
				If ZCN->(DbSeek(xFilial("ZCN")+::cCodAnt+'2')) .And. !ZCN->(DbSeek(xFilial("ZCN")+::cNewCod+'2'))
					//Inserir sempre na Bianco
					_cSql	:=	" INSERT INTO ZCN010 " 
					_cSql	+=	" SELECT ZCN_FILIAL, '" + ::cNewCod + "'," + "ZCN_SEQUEN,ZCN_LOCAL,ZCN_ESTSEG,ZCN_PONPED,ZCN_LE,ZCN_LOCALI,''," 
					_cSql	+=	" 		(SELECT MAX(R_E_C_N_O_) + 1 FROM ZCN010),0,ZCN_PORTAR,ZCN_POLIT,ZCN_MD,ZCN_COMUM,ZCN_OBSOLE,ZCN_SOLIC" 
					_cSql	+=	" FROM ZCN010 " 
					_cSql	+=	" WHERE ZCN_FILIAL = '01' " 
					_cSql	+=	" 	AND ZCN_COD = " + ValtoSql(::cCodAnt) + " " 
					_cSql	+=	" 	AND ZCN_SEQUEN = '2' "
					_cSql	+=	" 	AND D_E_L_E_T_  = '' "
					TcSqlExec(_cSql)
				EndIf
				//Verificar se existe na bianco o produto antigo para a INCESA na ZCN

				//Copiar indicador para demais empresas
				If AllTrim(CEMPANT) $ cLstEmp

					aLstEmp := StrToKArr(cLstEmp,"_")

					For nx := 1 To Len(aLstEmp)

						If !Empty(aLstEmp[nx]) .And. aLstEmp[nx] <> AllTrim(CEMPANT)

							::ReplicaSBZ(AllTrim(aLstEmp[nx])+"0", "I") // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

						EndIf

					Next nx

				EndIf

			EndIf

		EndIf

	EndIf

Return


Method ReplicaSBZ(__EMPRESA,cTipo) Class TPDMProduto

	Local x

	cIndex  := ""
	cArq    := ""
	cInd    := ""

	//Arquivo do Codigo Anterior na empresa Destino
	cArq:="SBZ"+__EMPRESA
	DbSelectArea("SIX")
	DbSetOrder(1)
	DbSeek("SBZ")
	Do while .not. eof() .and. INDICE=="SBZ"
		cIndex+=cArq+SIX->ORDEM
		DbSkip()
	EndDo
	If chkfile("_SBZ")
		DbSelectArea("_SBZ")
		DbCloseArea()
	EndIf
	Use &cArq Alias "_SBZ" Shared New Via "TopConn"
	For x:=1 to 4 step 7
		cInd := Subs(cIndex,x,7)
		DbSetIndex(cInd)
	Next

	//Arquivo do Codigo NOVO na empresa Destino
	cArq:="SBZ"+__EMPRESA
	DbSelectArea("SIX")
	DbSetOrder(1)
	DbSeek("SBZ")
	Do while .not. eof() .and. INDICE=="SBZ"
		cIndex+=cArq+SIX->ORDEM
		DbSkip()
	EndDo
	If chkfile("_SBZNEW")
		DbSelectArea("_SBZNEW")
		DbCloseArea()
	EndIf
	Use &cArq Alias "_SBZNEW" Shared New Via "TopConn"
	For x:=1 to 4 step 7
		cInd := Subs(cIndex,x,7)
		DbSetIndex(cInd)
	Next

	_SBZNEW->(DbSetOrder(1))
	IF !_SBZNEW->(DbSeek(xFilial("SBZ") + ::cNewCod))

		//Verificando se vai incluir ou alterar
		If cTipo == "I" //Incluir

			_SBZ->(dbSetOrder(1))
			If _SBZ->(dbSeek(xFilial("SBZ")+::cCodAnt,.F.))

				RecLock("_SBZNEW",.T.)

				_SBZNEW->BZ_FILIAL		:= _SBZ->BZ_FILIAL	
				_SBZNEW->BZ_COD			:= ::cNewCod
				_SBZNEW->BZ_LOCPAD 		:= _SBZ->BZ_LOCPAD
				_SBZNEW->BZ_TE			:= _SBZ->BZ_TE
				_SBZNEW->BZ_TS			:= _SBZ->BZ_TS
				_SBZNEW->BZ_QE			:= _SBZ->BZ_QE
				_SBZNEW->BZ_CUSTD		:= _SBZ->BZ_CUSTD
				_SBZNEW->BZ_UCALSTD		:= _SBZ->BZ_UCALSTD
				_SBZNEW->BZ_MCUSTD		:= _SBZ->BZ_MCUSTD
				_SBZNEW->BZ_UCOM		:= _SBZ->BZ_UCOM
				_SBZNEW->BZ_ESTFOR		:= _SBZ->BZ_ESTFOR
				_SBZNEW->BZ_FORPRZ		:= _SBZ->BZ_FORPRZ
				_SBZNEW->BZ_PE			:= _SBZ->BZ_PE
				_SBZNEW->BZ_TIPE		:= _SBZ->BZ_TIPE
				_SBZNEW->BZ_LM			:= _SBZ->BZ_LM
				_SBZNEW->BZ_TOLER		:= _SBZ->BZ_TOLER
				_SBZNEW->BZ_CONINI		:= _SBZ->BZ_CONINI
				_SBZNEW->BZ_DATREF		:= _SBZ->BZ_DATREF
				_SBZNEW->BZ_EMAX		:= _SBZ->BZ_EMAX
				_SBZNEW->BZ_YSOLIC		:= _SBZ->BZ_YSOLIC
				_SBZNEW->BZ_YBLSCPC		:= _SBZ->BZ_YBLSCPC
				_SBZNEW->BZ_YCOMUM		:= _SBZ->BZ_YCOMUM
				_SBZNEW->BZ_YOBS		:= _SBZ->BZ_YOBS
				_SBZNEW->BZ_YAREA		:= _SBZ->BZ_YAREA
				_SBZNEW->BZ_YDESC		:= _SBZ->BZ_YDESC
				_SBZNEW->BZ_UPRC		:= _SBZ->BZ_UPRC
				_SBZNEW->BZ_TIPOCQ		:= _SBZ->BZ_TIPOCQ
				_SBZNEW->BZ_QB			:= _SBZ->BZ_QB
				_SBZNEW->BZ_PICM		:= _SBZ->BZ_PICM
				_SBZNEW->BZ_VLR_ICM		:= _SBZ->BZ_VLR_ICM
				_SBZNEW->BZ_INT_ICM		:= _SBZ->BZ_INT_ICM
				_SBZNEW->BZ_PICMRET		:= _SBZ->BZ_PICMRET
				_SBZNEW->BZ_PICMENT		:= _SBZ->BZ_PICMENT
				_SBZNEW->BZ_IPI			:= _SBZ->BZ_IPI
				_SBZNEW->BZ_VLR_IPI		:= _SBZ->BZ_VLR_IPI
				_SBZNEW->BZ_REDPIS		:= _SBZ->BZ_REDPIS
				_SBZNEW->BZ_REDCOF		:= _SBZ->BZ_REDCOF
				_SBZNEW->BZ_IRRF		:= _SBZ->BZ_IRRF
				_SBZNEW->BZ_ORIGEM		:= _SBZ->BZ_ORIGEM
				_SBZNEW->BZ_GRTRIB		:= _SBZ->BZ_GRTRIB
				_SBZNEW->BZ_YMANUAL		:= _SBZ->BZ_YMANUAL
				_SBZNEW->BZ_YCUSANT		:= _SBZ->BZ_YCUSANT
				_SBZNEW->BZ_YDTANT		:= _SBZ->BZ_YDTANT
				_SBZNEW->BZ_CODISS		:= _SBZ->BZ_CODISS
				_SBZNEW->BZ_MARKUP		:= _SBZ->BZ_MARKUP
				_SBZNEW->BZ_FECP		:= _SBZ->BZ_FECP
				_SBZNEW->BZ_YTMPFAB		:= _SBZ->BZ_YTMPFAB
				_SBZNEW->BZ_YTMPIND		:= _SBZ->BZ_YTMPIND				

				_SBZNEW->(MsUnlock())

			Endif
		EndIf

		dbSelectArea("_SBZ")
		dbCloseArea()
		dbSelectArea("_SBZNEW")
		dbCloseArea()

	EndIf

Return

/*/{Protheus.doc} XCONVERRLOG
//TODO Descrição auto-gerada.
@author FERNANDO ROCHA
@description CONVERTER LOG DE ERRO PARA TEXTO SIMPLES
@since 06/07/2017
@version 1.0
@param aAutoErro, array, descricao
@type function
/*/
Static Function XCONVERRLOG(aAutoErro)
	Local cRet := ""
	Local nX := 1

	for nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX] + CRLF
	Next nX
Return cRet