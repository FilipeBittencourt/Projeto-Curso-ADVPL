#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA391
@author Marcos Alberto Soprani
@since 21/09/17
@version 1.0
@description Tela para Fotografia dos dados para Orçamento de RH  
@type function
/*/

User Function BIA391()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBA") + SPACE(TAMSX3("ZBA_VERSAO")[1]) + SPACE(TAMSX3("ZBA_REVISA")[1]) + SPACE(TAMSX3("ZBA_ANOREF")[1])
	Local bWhile	    := {|| ZBA_FILIAL + ZBA_VERSAO + ZBA_REVISA + ZBA_ANOREF }                    
	Local aNoFields     := {"ZBA_VERSAO", "ZBA_REVISA", "ZBA_ANOREF", "ZBA_PERIOD"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	:=	{}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBA_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBA_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBA_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	If U_ValOper("OR1", .T.)
		aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração"      , "Layout Integração"})
		aAdd(_aButtons,{"PEDIDO"  ,{|| U_B391IEXC() }, "Importa Arquivo"        , "Importa Arquivo"})
	EndIf
	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel"        , "Exporta p/Excel"})
	aAdd(_aButtons,{"AUTOM"   ,{|| U_B391NEW1() }, "NOVO Func fora quadro"  , "NOVO Func fora quadro"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBA",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Orçamento de RH" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA391A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA391B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA391C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_INSERT + GD_UPDATE + GD_UPDATE, /*[ cLinhaOk]*/, "U_B391TOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999 /*[ nMax]*/, "U_B391FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B391DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA391A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA391C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA391B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA391C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA391C()

	Local _msc
	Local M001       := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)	

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e menor ou igual a DataBase" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:Date()%
		AND ZB5.ZB5_DTCONS = '' 
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		_msCtrlAlt := .F.
		_oGetDados:lInsert := .F.
		_oGetDados:lUpdate := .F.
	Else
		_msCtrlAlt := .T.
		_oGetDados:lInsert := .T.
		_oGetDados:lUpdate := .T.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	M0007 := " WITH LIBCLVL AS (SELECT ZB9.ZB9_CLVL, "
	M0007 += "                         " + IIF(_msCtrlAlt, "ZB9.ZB9_DIGIT", "'2'") + " ZB9_DIGIT, "
	M0007 += "                         " + IIF(_msCtrlAlt, "ZB9.ZB9_VISUAL", "'2'") + " ZB9_VISUAL "
	M0007 += "                    FROM " + RetSqlName("ZB9") + " ZB9 "
	M0007 += "                   WHERE ZB9.ZB9_FILIAL = '" + xFilial("ZB9") + "' "
	M0007 += "                     AND ZB9.ZB9_VERSAO = '" + _cVersao + "' "
	M0007 += "                     AND ZB9.ZB9_REVISA = '" + _cRevisa + "' "
	M0007 += "                     AND ZB9.ZB9_ANOREF = '" + _cAnoRef + "' "
	M0007 += "                     AND ZB9.ZB9_USER = '" + __cUserID + "' "
	M0007 += "                     AND ZB9.ZB9_TPORCT = 'RH' "
	M0007 += "                     AND ( ZB9.ZB9_DIGIT = '1' OR ZB9.ZB9_VISUAL = '1' ) "
	M0007 += "                     AND ZB9.D_E_L_E_T_ = ' ') "
	M0007 += " SELECT ZB9.ZB9_DIGIT ZBA_DIGIT, "
	M0007 += "        ZB9.ZB9_VISUAL ZBA_VISUAL, "
	M0007 += "        ZBA.*, "
	M0007 += "        (SELECT COUNT(*) "
	M0007 += "           FROM " + RetSqlName("ZBA") + " XZBA "
	M0007 += "          INNER JOIN LIBCLVL ZB9 ON ZB9.ZB9_CLVL = XZBA.ZBA_CLVL "
	M0007 += "          WHERE XZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
	M0007 += "            AND XZBA.ZBA_VERSAO = '" + _cVersao + "' "
	M0007 += "            AND XZBA.ZBA_REVISA = '" + _cRevisa + "' "
	M0007 += "            AND XZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
	M0007 += "            AND XZBA.ZBA_PERIOD = '00' "
	M0007 += "            AND XZBA.D_E_L_E_T_ = ' ') NREGS "
	M0007 += "   FROM " + RetSqlName("ZBA") + " ZBA "
	M0007 += "  INNER JOIN LIBCLVL ZB9 ON ZB9.ZB9_CLVL = ZBA.ZBA_CLVL "
	M0007 += "  WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
	M0007 += "    AND ZBA.ZBA_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBA.ZBA_PERIOD = '00' "
	M0007 += "    AND ZBA.D_E_L_E_T_ = ' ' "
	M0007 += "  ORDER BY ZBA.ZBA_CLVL, ZBA.ZBA_MATR "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")

	xtrTot := M007->(NREGS)
	ProcRegua(xtrTot)

	M007->(dbGoTop())

	If M007->(!Eof())

		While M007->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str(M007->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBA"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DFUNC"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SRJ", 1, xFilial("SRJ") + M007->ZBA_FUNCAO, "RJ_DESC")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DCTGFU"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZB4", 1, xFilial("ZB4") + M007->ZBA_CATGFU, "ZB4_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DCLVL"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + M007->ZBA_CLVL, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DTINIF"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := stod(&(Alltrim(_oGetDados:aHeader[_msc][2])))

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			M007->(dbSkip())

		EndDo

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI, _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_REC_WT"})
	Local nDigtOk := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_DIGIT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZBA')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nDigtOk] == "1"

				If _oGetDados:aCols[_nI,nPosRec] > 0

					ZBA->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
					Reclock("ZBA",.F.)
					If !_oGetDados:aCols[_nI,nPosDel]

						For _msc := 1 to Len(_oGetDados:aHeader)

							If _oGetDados:aHeader[_msc][10] == "R"

								nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
								&("ZBA->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

							EndIf

						Next _msc

					Else

						ZBA->(DbDelete())

					EndIf

					ZBA->(MsUnlock())

				Else

					If !_oGetDados:aCols[_nI,nPosDel]

						Reclock("ZBA",.T.)

						ZBA->ZBA_FILIAL  := xFilial("ZBA")
						ZBA->ZBA_VERSAO  := _cVersao
						ZBA->ZBA_REVISA  := _cRevisa
						ZBA->ZBA_ANOREF  := _cAnoRef
						ZBA->ZBA_PERIOD  := "00"
						For _msc := 1 to Len(_oGetDados:aHeader)

							If _oGetDados:aHeader[_msc][10] == "R"

								nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
								&("ZBA->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

							EndIf

						Next _msc

						ZBA->(MsUnlock())

					EndIf

				EndIf

			Else

				_msCtrlAlt := .F.

			EndIf

		Next

	EndIf

	_cVersao        := SPACE(TAMSX3("ZBA_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBA_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBA_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	If _msCtrlAlt

		MsgInfo("Registro Incluído com Sucesso!")

	Else

		MsgALERT("Nenhum registro foi atualizado!")

	EndIf

Return

User Function B391FOK()

	Local cMenVar   := ReadVar()
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _zpCLVL   := GdFieldGet("ZBA_CLVL",_nAt)
	Local _RegZBA   := GdFieldGet("ZBA_REC_WT",_nAt)
	Local _Matricul := ""
	Local _Semelhan := ""
	Local _PosMatr  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_MATR"})
	Local _CtrlDigt := GdFieldGet("ZBA_DIGIT",_nAt)
	Local _msc

	If _CtrlDigt $ " /1"

		If _RegZBA == 0 .or. Alltrim(cMenVar) $ "M->ZBA_MADMNW/M->ZBA_MESDEM/M->ZBA_DMTDAA/M->ZBA_PREMPR" .or. "NOVO" $ GdFieldGet("ZBA_MATR",_nAt)

			Do Case

				Case Alltrim(cMenVar) == "M->ZBA_MATR"
				_Matricul := M->ZBA_MATR
				_Semelhan := GdFieldGet("ZBA_SEMELH",_nAt)
				If Substr(_Matricul,1,4) <> "NOVO"
					MsgInfo("Necessário verificar, pois somente Matriculas iniciadas com as letras NOVO pode ser incluída aqui!!!")
					Return .F.
				EndIf

				Case Alltrim(cMenVar) == "M->ZBA_SEMELH"
				_Matricul := GdFieldGet("ZBA_MATR",_nAt)
				_Semelhan := M->ZBA_SEMELH

				nPos := aScan(_oGetDados:aCols,{|x| x[_PosMatr] == _Semelhan })
				If nPos == 0
					MsgInfo("A matricula informa que servirá de base para cópia dos valores não foi encontrada na lista. Favor informa uma matricula que conste na lista!!!")
					Return .F.
				EndIf

				For _msc := 1 to Len(_oGetDados:aHeader)

					If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_ALI_WT"
						_oGetDados:aCols[_nAt, _msc] := "ZBA"

					ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DFUNC"
						_oGetDados:aCols[_nAt, _msc] := Posicione("SRJ", 1, xFilial("SRJ") + GdFieldGet("ZBA_FUNCAO", nPos), "RJ_DESC")

					ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DCTGFU"
						_oGetDados:aCols[_nAt, _msc] := Posicione("ZB4", 1, xFilial("ZB4") + GdFieldGet("ZBA_CATGFU", nPos) , "ZB4_DESCRI")

					ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) $ "ZBA_DMTDAA"
						If "NOVO" $ GdFieldGet("ZBA_MATR",_nAt)
							_oGetDados:aCols[_nAt, _msc] := " "
						EndIf

					ElseIf !Alltrim(_oGetDados:aHeader[_msc][2]) $ "ZBA_MATR/ZBA_NOME/ZBA_SEMELH/ZBA_IDADET/ZBA_MESANI/ZBA_MESADM/ZBA_REC_WT/ZBA_MESDEM"
						_oGetDados:aCols[_nAt, _msc] := _oGetDados:aCols[nPos, _msc]

					EndIf			

				Next _msc

				Case Alltrim(cMenVar) == "M->ZBA_DMTDAA"
				_Matricul := GdFieldGet("ZBA_MATR",_nAt)
				_Semelhan := GdFieldGet("ZBA_SEMELH",_nAt)
				If Substr(_Matricul,1,4) == "NOVO"
					MsgInfo("Este campo somente deverá ser preenchido para funcionários já registrados na empresa!!!")
					Return .F.
				EndIf

				Case Alltrim(cMenVar) == "M->ZBA_MADMNW"
				_Matricul := GdFieldGet("ZBA_MATR",_nAt)
				_Semelhan := GdFieldGet("ZBA_SEMELH",_nAt)
				If Substr(_Matricul,1,4) <> "NOVO"
					MsgInfo("Este campo somente deverá ser preenchido para funcionários novos!!!")
					Return .F.
				EndIf

				Case Alltrim(cMenVar) == "M->ZBA_MESDEM"
				_Matricul := GdFieldGet("ZBA_MATR",_nAt)
				_Semelhan := GdFieldGet("ZBA_SEMELH",_nAt)
				If Substr(_Matricul,1,4) == "NOVO"
					MsgInfo("Este campo somente deverá ser preenchido para funcionários já registrados na empresa!!!")
					Return .F.
				EndIf

			EndCase

			For _nI	:=	1 to Len(_oGetDados:aCols)

				If _nI <> _nAt .and. !GDdeleted(_nI)

					If !Empty(_Matricul) .and. _Matricul == GdFieldGet("ZBA_MATR",_nI) .and. _zpCLVL == GdFieldGet("ZBA_CLVL",_nI) 

						MsgInfo("Não poderá haver a mesma Categoria Func mais de uma vez na lista. Na linha: " + Alltrim(Str(_nI)) + " já existe a Categoria Func informada!!!")
						Return .F.

					EndIf

				EndIf

			Next

		ElseIf Alltrim(cMenVar) == "M->ZBA_VVLTRT"
			
			If !Alltrim(GdFieldGet("ZBA_CATGFU",_nAt)) == '035'
			
				MsgInfo("Não é possível realizar alteração nesse campo quando a categoria do funcionário for 035!!")
				Return .F.
				
			EndIf
		
		
		Else
	 
			MsgInfo("Para funcionários previamente registrados na empresa somente é permitido alterar, quando necessário, o MÊS de demissão!!!")
			Return .F.

		EndIf

	Else

		MsgInfo("Você não ter permissão para dar manutenção nos registros apresentados. Sua permissão é apenas para VISUALIZAÇÃO!!!")
		Return .F.

	EndIf

Return .T.

User Function B391DOK()

	Local _lRet    := .T.
	Local posMATR  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_MATR"})
	Local posCLVL  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_CLVL"})
	Local posDigit := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_DIGIT"})

	Local posnAt   := _oGetDados:nAt
	Local mxMATR   := _oGetDados:aCols[posnAt][posMATR]
	Local mxCLVL   := _oGetDados:aCols[posnAt][posCLVL]
	Local mxDIGIT  := _oGetDados:aCols[posnAt][posDigit]

	If mxDIGIT == "1"

		If Substr(mxMATR,1,4) == "NOVO" 

			XP002 := " SELECT ZB8.*, ZB8.R_E_C_N_O_ REGZB8 "
			XP002 += "   FROM " + RetSqlName("ZB8") + " ZB8 "
			XP002 += "  WHERE ZB8.ZB8_FILIAL = '" + xFilial("ZB8") + "' "
			XP002 += "    AND ZB8.ZB8_VERSAO = '" + _cVersao + "' "
			XP002 += "    AND ZB8.ZB8_REVISA = '" + _cRevisa + "' "
			XP002 += "    AND ZB8.ZB8_ANOREF = '" + _cAnoRef + "' "
			XP002 += "    AND ZB8.ZB8_MATR = '" + mxMATR + "' "
			XP002 += "    AND ZB8.ZB8_CLVL = '" + mxCLVL + "' "
			XP002 += "    AND ZB8.D_E_L_E_T_ = ' ' "
			XPIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP002),'XP02',.T.,.T.)
			dbSelectArea("XP02")
			XP02->(dbGoTop())

			If XP02->(!Eof()) .and. XP02->(ZB8_M12) <> 0

				_lRet    := .F.  
				MsgINFO("Na tela de Rubricas Eventuais foram registrados valores para esta matrícula/CLVL. Para que seja possível deletar este registro é necessário ZERAR os valores da tabela de RUBRICAS EVENTUAIS!!!")

			Else

				If XP02->REGZB8 <> 0

					ZB8->(dbGoTo(XP02->REGZB8))
					Reclock("ZB8",.F.)
					ZB8->(DbDelete())
					ZB8->(MsUnlock())

				EndIf

			EndIf

			XP02->(dbCloseArea())
			Ferase(XPIndex+GetDBExtension())
			Ferase(XPIndex+OrdBagExt())

		Else

			_lRet    := .F.
			MsgINFO("Não é permitido deletar registros oriundos da fotografia. Se desejar eliminar o registro para o orçamento, favor informar o mês de demissão igual a 01!!!")

		EndIf

	Else

		_lRet    := .F.
		MsgINFO("Você está sem permissão para efetuar qualquer manutenção neste registro. Favor verificar com o responsável pelo orçamento!!!")

	EndIf

Return _lRet

User Function B391TOK()

	Local _lRet	:=	.T.
	Local _gj
	Local nPosDel  := Len(_oGetDados:aHeader) + 1	
	Local nPsMatr  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_MATR"})
	Local nPsAdmNw := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_MADMNW"})

	For _gj	:=	1 to Len(_oGetDados:aCols)

		If !_oGetDados:aCols[_gj, nPosDel]

			If Substr(_oGetDados:aCols[_gj, nPsMatr], 1, 4) == "NOVO"

				If Empty(_oGetDados:aCols[_gj, nPsAdmNw])

					MsgInfo("Não poderá haver NOVO funcionário SEM >> Mês Adm.Novo << informado. Na linha: " + Alltrim(Str(_gj)) + " está faltando informar o mês de admissão do novo funcionário!!!")
					Return .F.

				EndIf

			EndIf

		EndIf

	Next _gj

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B391NEW1 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 28/09/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atribui registro NOVO para func fora do quadro             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B391NEW1()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para atribuição de funcionário NOVO que não tenha semelhante presente."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração do NOVO funcionário...'), aSays, aButtons ,,,500)

	If lConfirm

		Processa({ || fProcImport() },"Aguarde...","Carregando dados...",.F.)

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B391IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	MV_PAR01 := Space(06)
	MV_PAR02 := Space(06)
	MV_PAR03 := Space(06)
	MV_PAR04 := Space(09)

	aAdd( aPergs ,{1,"Código NOVO:"	   		,MV_PAR01 ,""  ,"NAOVAZIO()",''    ,'.T.',50,.T.})	
	aAdd( aPergs ,{1,"Semelhante:" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''    ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Função:" 	   			,MV_PAR03 ,""  ,"NAOVAZIO()",''    ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Classe Valor:"   		,MV_PAR04 ,""  ,"NAOVAZIO()",'CTH' ,'.T.',50,.T.})

	If ParamBox(aPergs ,"Alteração de Linha",,,,,,,,cLoad,.T.,.T.)

		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)

	EndIf

Return 

//Processa importação
Static Function fProcImport()

	Local nPsMatr  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_MATR"})
	Local _nAt     := _oGetDados:nAt
	Local _msc

	If !Empty(_oGetDados:aCols[_nAt, nPsMatr]) .and. Substr(_oGetDados:aCols[_nAt, nPsMatr],1,4) <> "NOVO"
		MsgInfo("Necessário estar posicionado em um linha VAZIA para poder incluir um NOVO funcionário!!!")
		Return .F.
	EndIf
	If _oGetDados:aCols[_nAt, nPsMatr] <> MV_PAR01

		MsgInfo("A referência para NOVO funcionário está diferente daquela digitada na tela " + Alltrim(Str(_nAt)) + ". Favor informar outra referência!!!")
		Return .F.

	EndIf

	MP007 := " WITH LIBCLVL AS (SELECT ZB9.ZB9_CLVL, "
	MP007 += "                         " + IIF(_msCtrlAlt, "ZB9.ZB9_DIGIT", "'2'") + " ZB9_DIGIT, "
	MP007 += "                         " + IIF(_msCtrlAlt, "ZB9.ZB9_VISUAL", "'2'") + " ZB9_VISUAL "
	MP007 += "                    FROM " + RetSqlName("ZB9") + " ZB9 "
	MP007 += "                   WHERE ZB9.ZB9_FILIAL = '" + xFilial("ZB9") + "' "
	MP007 += "                     AND ZB9.ZB9_VERSAO = '" + _cVersao + "' "
	MP007 += "                     AND ZB9.ZB9_REVISA = '" + _cRevisa + "' "
	MP007 += "                     AND ZB9.ZB9_ANOREF = '" + _cAnoRef + "' "
	MP007 += "                     AND ZB9.ZB9_USER = '" + __cUserID + "' "
	MP007 += "                     AND ZB9.ZB9_TPORCT = 'RH' "
	MP007 += "                     AND ( ZB9.ZB9_DIGIT = '1' OR ZB9.ZB9_VISUAL = '1' ) "
	MP007 += "                     AND ZB9.D_E_L_E_T_ = ' ') "
	MP007 += " SELECT ZB9.ZB9_DIGIT ZBA_DIGIT, "
	MP007 += "        ZB9.ZB9_VISUAL ZBA_VISUAL, "
	MP007 += "        ZBA.* "
	MP007 += "   FROM " + RetSqlName("ZBA") + " ZBA "
	MP007 += "  INNER JOIN LIBCLVL ZB9 ON ZB9.ZB9_CLVL = '" + MV_PAR04 + "' "
	MP007 += "  WHERE ZBA_VERSAO = '" + _cVersao + "' "
	MP007 += "    AND ZBA_REVISA = '" + _cRevisa + "' "
	MP007 += "    AND ZBA_ANOREF = '" + _cAnoRef + "' "
	MP007 += "    AND ZBA_MATR = '" + MV_PAR02 + "' "
	MP007 += "    AND ZBA.D_E_L_E_T_ = ' ' "
	MPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,MP007),'MP07',.T.,.T.)
	dbSelectArea("MP07")
	MP07->(dbGoTop())
	If MP07->(!Eof())

		For _msc := 1 to Len(_oGetDados:aHeader)

			If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_ALI_WT"
				_oGetDados:aCols[_nAt, _msc] := "ZBA"

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) $ "ZBA_MATR"
				_oGetDados:aCols[_nAt, _msc] := MV_PAR01

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) $ "ZBA_SEMELH"
				_oGetDados:aCols[_nAt, _msc] := MV_PAR02

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) $ "ZBA_CLVL"
				_oGetDados:aCols[_nAt, _msc] := MV_PAR04

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DCLVL"
				_oGetDados:aCols[_nAt, _msc] := Posicione("CTH", 1, xFilial("CTH") + MV_PAR04, "CTH_DESC01")

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) $ "ZBA_FUNCAO"
				_oGetDados:aCols[_nAt, _msc] := MV_PAR03

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DFUNC"
				_oGetDados:aCols[_nAt, _msc] := Posicione("SRJ", 1, xFilial("SRJ") + MV_PAR03, "RJ_DESC")

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DCTGFU"
				_oGetDados:aCols[_nAt, _msc] := Posicione("ZB4", 1, xFilial("ZB4") + MP07->ZBA_CATGFU, "ZB4_DESCRI")

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DTINIF"
				_oGetDados:aCols[_nAt, _msc] := stod(MP07->ZBA_DTINIF)

			ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DMTDAA"
				_oGetDados:aCols[_nAt, _msc] := " "

			ElseIf !Alltrim(_oGetDados:aHeader[_msc][2]) $ "ZBA_MATR/ZBA_NOME/ZBA_SEMELH/ZBA_IDADET/ZBA_MESANI/ZBA_MESADM/ZBA_REC_WT/ZBA_MESDEM"
				_oGetDados:aCols[_nAt, _msc] := &(_oGetDados:aHeader[_msc][2])

			EndIf			

		Next _msc

		MP07->(dbSkip())

	EndIf
	MP07->(dbCloseArea())
	Ferase(MPIndex+GetDBExtension())
	Ferase(MPIndex+OrdBagExt())

	_oGetDados:Refresh()
	_oDlg:Refresh()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B391IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B391IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fxPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Funcionários NOVOS que não possuem nenhum semenlhante"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fxPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fPrcImprtExc() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fxPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B391IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fPrcImprtExc()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZBA'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBA_REC_WT"})
	Local vtRecGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtRecGrd, _ImpaColsBkp[vnb][nPosRec])	
	Next vnb

	If Len(vtRecGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosRec]
		If nPrimeralin == 0
			_oGetDados:aCols := {}
		EndIf
	EndIf

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		For nx := 1 to len(aWorksheet) 

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			If nx == 1

				aCampos := aWorksheet[nx]
				For ny := 1 to len(aCampos)
					cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
					aCampos[ny] := cTemp
				Next ny

			Else

				aLinha    := aWorksheet[nx]
				aItem     := {}
				cConteudo := ''

				nLinReg   := 0
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZBA_REC_WT"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
						nLinReg := Len(_oGetDados:aCols)

					EndIf				

					For _msc := 1 to Len(aCampos)

						xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
						If xkPosCampo <> 0
							If _oGetDados:aHeader[xkPosCampo][8] == "N"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Val(Alltrim(aLinha[_msc]))
							ElseIf _oGetDados:aHeader[xkPosCampo][8] == "D"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Stod(Alltrim(aLinha[_msc]))
							Else
								_oGetDados:aCols[nLinReg, xkPosCampo] := aLinha[_msc]
							EndIf
						EndIf

					Next _msc

					_oGetDados:aCols[nLinReg, Len(_oGetDados:aHeader)+1] := .F.	
					nImport ++

				Else

					MsgALERT("Erro no Layout do Arquivo de Importação!!!")
					nImport := 0
					Exit

				EndIf

			EndIf

		Next nx

	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")
		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return
