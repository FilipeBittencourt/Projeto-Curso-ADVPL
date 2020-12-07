#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFC003
@description Nova Tela de Cadastro do Fator Multiplicador
@author Fernando Rocha
@since 17/05/2017
@version undefined
@type function
/*/

User Function BIAFC003()

	Local aArea       := GetArea()
	Local aCores	  := {}
	Local cRefPer	   := 'BIAFC03' + cEmpAnt
	Local cFileName    := __cUserID +"_"+ cRefPer


	Private cCadastro := "Fator Multiplicador"
	Private aRotina   := {}
	Private aIndSZY   := {}
	Private cAtivo	  := "1"

	Private oGetDad1
	Private _cChvCab

	AADD(aRotina,{"Visualizar"	,"U_BFC03MNT(2)" ,0,2})
	AADD(aRotina,{"Incluir"		,"U_BFC03MNT(3)" ,0,3})
	AADD(aRotina,{"Alterar"		,"U_BFC03MNT(4)" ,0,4})
	AADD(aRotina,{"Legenda"		,"U_FBFC03LG" ,0,6})

	AADD(aCores,{"STATUS == '0'" ,"BR_VERMELHO"  })
	AADD(aCores,{"STATUS == '1'" ,"BR_VERDE" 	 })
	AADD(aCores,{"STATUS == '2'" ,"BR_AZUL"		 })


	aPergs := {}
	aAdd( aPergs ,{2,"Somente Ativos",cAtivo , {"1=Sim", "2=Nao"},60,".T.",.F.})

	If ParamBox(aPergs ,"Cadastro de Fator Multiplicador",,,,,,,,cRefPer,.T.,.T.) 
		cAtivo   := Alltrim(ParamLoad(cFileName,,1 , cAtivo))
	Else
		Return
	EndIf

	If U_FBFC003T(cAtivo=="1")

		MBrowse(,,,,"TRBZ65",{;
		{"Filial" 					,"Z65_FILIAL"	,"C",02,00,"@!"    },;
		{"Numero" 					,"Z65_NUM"		,"C",06,00,"@!"    },;
		{"Descrição"				,"Z65_DESCR"	,"C",60,00,"@!"    },;
		{"Tp.Venda" 				,"Z65_TIPVEN"	,"C",02,00,"@!"    },;
		{"UF" 						,"Z65_UF"		,"C",02,00,"@!"    },;
		{"Zona Franca?"				,"Z65_ZONAFR" 	,"C",01,00,"@!"    },;
		{"Tipo Cliente"				,"Z65_TIPO"		,"C",01,00,"@!"    },;
		{"Contribuinte?"			,"Z65_CONTRI"	,"C",01,00,"@D"    },;
		{"Data Inicio"				,"Z65_VALINI"	,"D",08,00,"@D"    },;
		{"Data Fim"					,"Z65_VALFIM"	,"D",08,00,"@!"    }   },,,,,aCores)

	EndIf

	aEval(aIndSZY,{|x| Ferase(x[1]+OrdBagExt())})

	TRBZ65->(DbCloseArea())
	RestArea(aArea)

Return()

//LEGENDA
User Function FBFC03LG()

	Local aLegenda := {}

	AADD(aLegenda,{"BR_VERMELHO"  	,"Regra Vencida"  			})
	AADD(aLegenda,{"BR_VERDE" 	 	,"Regra Ativa"  			})
	AADD(aLegenda,{"BR_AZUL" 		,"Regra Futura" 			})

	BrwLegenda(cCadastro, "Legenda - Orçamento", aLegenda)

Return Nil

//ATUALIZA TELA.
User Function FBFC003T(lAtivos)
	Local lRet := .F.

	U_BIAMsgRun("Atualizando Dados...","Aguarde", {|| lRet := FQuery(lAtivos)})

Return(lRet)


Static Function FQuery(lAtivos)

	Local cSQL := ""
	Local cQryAlias := GetNextAlias()

	cSQL += " select "+CRLF
	cSQL += " distinct "+CRLF
	cSQL += " STATUS = case when Z65_VALFIM < '"+DTOS(dDataBase)+"' then '0' when Z65_VALINI <= '"+DTOS(dDataBase)+"' then '1' else '2' end, "+CRLF
	cSQL += " Z65_NUM, "+CRLF
	cSQL += " Z65_FILIAL, "+CRLF
	cSQL += " Z65_DESCR, "+CRLF
	cSQL += " Z65_TIPVEN, "+CRLF
	cSQL += " Z65_UF, "+CRLF
	cSQL += " Z65_ZONAFR, "+CRLF
	cSQL += " Z65_TIPO, "+CRLF
	cSQL += " Z65_CONTRI, "+CRLF
	cSQL += " Z65_VALINI, "+CRLF
	cSQL += " Z65_VALFIM "+CRLF
	cSQL += " from "+RetSQLName("Z65")+"  "+CRLF
	cSQL += " where D_E_L_E_T_='' "+CRLF
	cSQL += " and Z65_FILIAL = '"+XFILIAL("Z65")+"' "+CRLF

	If (lAtivos)
		cSQL += " and  Z65_VALINI <= '"+DTOS(dDataBase)+"' and Z65_VALFIM >= '"+DTOS(dDataBase)+"' "+CRLF
	EndIf

	TcQuery cSQL new Alias (cQryAlias)

	TCSetField(cQryAlias, "Z65_VALINI" , "D", 10, 0 )
	TCSetField(cQryAlias, "Z65_VALFIM" , "D", 10, 0 )

	(cQryAlias)->(DbGoTop())

	aCampo := {}
	AADD(aCampo,{ "STATUS"		, "C", 01, 0 })
	AADD(aCampo,{ "Z65_NUM"		, "C", 06, 0 })
	AADD(aCampo,{ "Z65_FILIAL"	, "C", 02, 0 })
	AADD(aCampo,{ "Z65_DESCR"	, "C", 60, 0 })
	AADD(aCampo,{ "Z65_TIPVEN"  , "C", 02, 0 })
	AADD(aCampo,{ "Z65_UF"		, "C", 02, 0 })
	AADD(aCampo,{ "Z65_ZONAFR" 	, "C", 01, 0 })
	AADD(aCampo,{ "Z65_TIPO"	, "C", 01, 0 })
	AADD(aCampo,{ "Z65_CONTRI"	, "C", 01, 0 })
	AADD(aCampo,{ "Z65_VALINI"	, "D", 08, 0 })
	AADD(aCampo,{ "Z65_VALFIM"	, "D", 08, 0 })

	If Select("TRBZ65") > 0
		TRBZ65->(DbCloseArea())
	EndIf

	_cTrb := CRIATRAB(aCampo, .T.)
	DBUSEAREA(.T.,,_cTrb,"TRBZ65")

	DbSelectArea("TRBZ65")
	Append from (cQryAlias)

	(cQryAlias)->(DbCloseArea())

	DBCREATEINDEX(_cTrb,"Z65_FILIAL+Z65_NUM",{|| Z65_FILIAL+Z65_NUM } )

	DBSelectArea("TRBZ65")
	TRBZ65->(DBGotop())

	FilBrowse("TRBZ65",{},/* Filtro */)

Return(.T.)


/*/{Protheus.doc} BFC03MNT
@description Funcao de Manutencao do Z65
@author Fernando Rocha
@since 17/05/2017
@version undefined
@type function
/*/
User Function BFC03MNT(_nOp)
	Static oDlg

	Local aSize  := MsAdvSize( .T. )
	Local nOpcao := 0

	Private _nOpca := _nOp

	DEFINE MSDIALOG oDlg TITLE "Fator Multiplicador"  FROM aSize[7], 000 TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL

	_cChvCab	:= TRBZ65->(Z65_FILIAL+Z65_NUM)

	Z65->(DbSetOrder(5))
	Z65->(DbSeek(_cChvCab))

	RegToMemory("Z65", INCLUI )
	fEnchoic1()

	fMSNewGe1()

	// Don't change the Align Order 
	oEnchoic1:oBox:Align := CONTROL_ALIGN_TOP
	oGetDad1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, {|| IIF(Gravar(),oDlg:End(),)}, {|| oDlg:End() },, ))

	U_FBFC003T(cAtivo=="1")

Return


Static Function fMSNewGe1()

	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"Z65_ITEM","Z65_MARCA","Z65_ICMSOR","Z65_ICMSDE","Z65_FRTAUT","Z65_PRDOUT","Z65_FATMUL","Z65_FATIMP"}
	Local aAlterFields := {"Z65_MARCA","Z65_ICMSOR","Z65_ICMSDE","Z65_FRTAUT","Z65_PRDOUT","Z65_FATMUL","Z65_FATIMP"}
	Local nGDOp	:= GD_INSERT+GD_DELETE+GD_UPDATE

	If _nOpca == 2
		aAlterFields := {}
		nGDOp := 0
	EndIf

	//Campos do Grid
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX


	If INCLUI

		For nX := 1 to Len(aFields)
			If DbSeek(aFields[nX])
				If AllTrim(SX3->X3_CAMPO) == "Z65_ITEM"
					Aadd(aFieldFill, "001")
				Else			
					Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
				EndIf
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)

	ELSE

		//Z65_FILIAL, Z65_TIPVEN, Z65_UF, Z65_ZONAFR, Z65_TIPO, Z65_CONTRI, Z65_VALINI, Z65_VALFIM, R_E_C_N_O_, D_E_L_E_T_
		Z65->(DbSetOrder(5))
		If Z65->(DbSeek(_cChvCab))

			While !Z65->(Eof()) .And. Z65->(Z65_FILIAL+Z65_NUM) == _cChvCab

				aFieldFill := {}
				For nX := 1 to Len(aFields)
					Aadd(aFieldFill, &("Z65->"+aFields[nX]) )						
				Next nX
				Aadd(aFieldFill, .F.)
				Aadd(aColsEx, aFieldFill)

				Z65->(DbSkip())			
			EndDo 

		EndIf

	ENDIF

	oGetDad1 := MsNewGetDados():New( 075, 000, 250, 250, nGDOp, "AllwaysTrue", "AllwaysTrue", "+Z65_ITEM", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

Static Function fEnchoic1()

	Local aFields := {"Z65_NUM","Z65_DESCR","Z65_TIPVEN","Z65_UF","Z65_ZONAFR","Z65_TIPO","Z65_CONTRI","Z65_VALINI","Z65_VALFIM","NOUSER"}
	Local aAlterFields := {}
	Static oEnchoic1

	If _nOpca == 3
		aAlterFields := {"Z65_DESCR","Z65_TIPVEN","Z65_UF","Z65_ZONAFR","Z65_TIPO","Z65_CONTRI","Z65_VALINI","Z65_VALFIM"}
	EndIf

	If _nOpca == 4
		aAlterFields := {"Z65_DESCR","Z65_VALFIM"}
	EndIf

	oEnchoic1 := MsMGet():New("Z65",0,_nOpca,,,,aFields,{0,0,100,400},aAlterFields,,,,,oDlg,,.T.)

Return


Static Function Gravar()

	Local aCols := AClone(oGetDad1:ACols) //"Z65_MARCA","Z65_GRTRIB","Z65_ICMSOR","Z65_ICMSDE","Z65_FRTAUT","Z65_FATMUL"
	Local I
	Local cAliasTmp

	IF ALTERA .Or. INCLUI

		If Empty(M->Z65_DESCR) .Or. Empty(M->Z65_VALINI) .Or. Empty(M->Z65_VALFIM)
			MsgAlert("Campos obrigatórios não preenchidos.","BIAFC003")
			Return(.F.)
		EndIf

		If M->Z65_VALINI > M->Z65_VALFIM
			MsgAlert("Datas Inválidas.","BIAFC003")
			Return(.F.)
		EndIf

		IF ALTERA .And. Empty(M->Z65_NUM)
			MsgAlert("Número da regra não informado.","BIAFC003")
			Return(.F.)
		ENDIF

	ENDIF

	//ALTERACAO
	IF ALTERA

		IF M->Z65_VALFIM < dDataBase
			MsgAlert("Não pode reduzir a validade abaixo da data do dia atual.","BIAFC003")
			Return(.F.)
		ENDIF

		//Deletar registros que tenham sido deletados do Grid
		For I := 1 To Len(aCols)
			If aCols[I][Len(aCols[I])]
				Z65->(DbSetOrder(5))
				If Z65->(DbSeek(XFilial("Z65")+M->Z65_NUM+aCols[I][1]))

					RecLock("Z65",.F.)
					Z65->(DbDelete())
					Z65->(MsUnlock())

				EndIf
			EndIf
		Next I

		For I := 1 To Len(aCols)

			If aCols[I][Len(aCols[I])]
				loop
			EndIf

			Z65->(DbSetOrder(5))
			If Z65->(DbSeek(XFilial("Z65")+M->Z65_NUM+aCols[I][1]))

				RecLock("Z65",.F.)
				Z65->Z65_DESCR	:= M->Z65_DESCR
				Z65->Z65_VALFIM := M->Z65_VALFIM

				Z65->Z65_MARCA	:= aCols[I][2]
				Z65->Z65_ICMSOR := aCols[I][3]
				Z65->Z65_ICMSDE := aCols[I][4]
				Z65->Z65_FRTAUT := aCols[I][5]
				Z65->Z65_PRDOUT	:= aCols[I][6]
				Z65->Z65_FATMUL := aCols[I][7]
				Z65->Z65_FATIMP := aCols[I][8]

				Z65->(MsUnlock())

			Else

				RecLock("Z65",.T.)

				Z65->Z65_FILIAL := XFilial("Z65")
				Z65->Z65_NUM	:= M->Z65_NUM
				Z65->Z65_DESCR	:= M->Z65_DESCR
				Z65->Z65_TIPVEN := M->Z65_TIPVEN
				Z65->Z65_UF		:= M->Z65_UF
				Z65->Z65_ZONAFR	:= M->Z65_ZONAFR
				Z65->Z65_TIPO	:= M->Z65_TIPO
				Z65->Z65_CONTRI	:= M->Z65_CONTRI
				Z65->Z65_VALINI	:= M->Z65_VALINI
				Z65->Z65_VALFIM	:= M->Z65_VALFIM

				Z65->Z65_ITEM	:= aCols[I][1]
				Z65->Z65_MARCA	:= aCols[I][2]
				Z65->Z65_ICMSOR := aCols[I][3]
				Z65->Z65_ICMSDE := aCols[I][4]
				Z65->Z65_FRTAUT := aCols[I][5]
				Z65->Z65_PRDOUT	:= aCols[I][6]
				Z65->Z65_FATMUL := aCols[I][7]
				Z65->Z65_FATIMP := aCols[I][8]

				Z65->(MsUnlock())

			EndIf

		Next I

		//INCLUSAO
	ELSEIF INCLUI

		For I := 1 To Len(aCols)

			If aCols[I][Len(aCols[I])]
				loop
			EndIf

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
			%NoParser%

			select REC = R_E_C_N_O_
			from %Table:Z65%
			where 
			Z65_FILIAL	= %Exp:XFilial("Z65")%
			AND Z65_TIPVEN	= %Exp:M->Z65_TIPVEN%
			AND Z65_UF		= %Exp:M->Z65_UF%
			AND Z65_ZONAFR	= %Exp:M->Z65_ZONAFR%
			AND Z65_TIPO	= %Exp:M->Z65_TIPO%
			AND Z65_CONTRI	= %Exp:M->Z65_CONTRI%
			and Z65_MARCA 	= %Exp:aCols[I][2]%
			and Z65_ICMSOR 	= %Exp:aCols[I][3]%
			and Z65_ICMSDE 	= %Exp:aCols[I][4]%
			and Z65_FRTAUT 	= %Exp:aCols[I][5]%
			and Z65_PRDOUT 	= %Exp:aCols[I][6]%

			AND (( %Exp:DTOS(M->Z65_VALINI)% >= Z65_VALINI AND %Exp:DTOS(M->Z65_VALINI)% <= Z65_VALFIM ) OR  		
			( %Exp:DTOS(M->Z65_VALFIM)% >= Z65_VALINI AND %Exp:DTOS(M->Z65_VALFIM)% <= Z65_VALFIM ) OR  		
			( %Exp:DTOS(M->Z65_VALINI)% < Z65_VALINI AND %Exp:DTOS(M->Z65_VALFIM)% > Z65_VALFIM ))

			AND %NotDel%

			EndSql

			//Chave existente
			If !(cAliasTmp)->(Eof())

				MsgAlert("Chave já existente ou períodos de validade conflitante! (Linha:"+AllTrim(Str(I))+")","BIAFC003")
				Return(.F.)

			EndIf

		Next I


		__CNUMERO := ""

		_cQryTmp := GetNextAlias()
		BeginSql Alias _cQryTmp
		%NoParser%

		select NUM = RIGHT('000000' + cast(isnull((select max(convert(int,Z65_NUM)) from %Table:Z65% where Z65_FILIAL = %XFILIAL:Z65%),0)+1 as varchar(6)),6)

		EndSql

		If !(_cQryTmp)->(Eof())
			__CNUMERO := (_cQryTmp)->NUM
		EndIf

		if Empty(__CNUMERO)
			MsgAlert("Não foi possivel gerar numero sequencial para esta regra.","BIAFC003")
			Return(.F.)
		endif

		For I := 1 To Len(aCols)

			If aCols[I][Len(aCols[I])]
				loop
			EndIf


			RecLock("Z65",.T.)

			Z65->Z65_FILIAL := XFilial("Z65")
			Z65->Z65_NUM	:= __CNUMERO
			Z65->Z65_DESCR	:= M->Z65_DESCR
			Z65->Z65_TIPVEN := M->Z65_TIPVEN
			Z65->Z65_UF		:= M->Z65_UF
			Z65->Z65_ZONAFR	:= M->Z65_ZONAFR
			Z65->Z65_TIPO	:= M->Z65_TIPO
			Z65->Z65_CONTRI	:= M->Z65_CONTRI
			Z65->Z65_VALINI	:= M->Z65_VALINI
			Z65->Z65_VALFIM	:= M->Z65_VALFIM
			Z65->Z65_ITEM	:= aCols[I][1]
			Z65->Z65_MARCA	:= aCols[I][2]
			Z65->Z65_ICMSOR := aCols[I][3]
			Z65->Z65_ICMSDE := aCols[I][4]
			Z65->Z65_FRTAUT := aCols[I][5]
			Z65->Z65_PRDOUT := aCols[I][6]
			Z65->Z65_FATMUL := aCols[I][7]
			Z65->Z65_FATIMP := aCols[I][8]

			Z65->(MsUnlock())

		Next I

		ConfirmSX8()

	ENDIF

Return(.T.)
