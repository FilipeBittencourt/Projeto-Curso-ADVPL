#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA642
@author Marcos Alberto Soprani
@since 28/09/17
@version 1.0
@description Tela para cadastro de Flutuação de Quantidade e Preço 
@type function
/*/

User Function BIA642()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBI") + SPACE(TAMSX3("ZBI_VERSAO")[1]) + SPACE(TAMSX3("ZBI_REVISA")[1]) + SPACE(TAMSX3("ZBI_ANOREF")[1])
	Local bWhile	    := {|| ZBI_FILIAL + ZBI_VERSAO + ZBI_REVISA + ZBI_ANOREF + ZBI_MARCA }   

	Local aNoFields     := {"ZBI_VERSAO", "ZBI_REVISA", "ZBI_ANOREF", "ZBI_MARCA"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBI_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBI_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBI_ANOREF")[1])
	Private _oGAnoRef
	Private _cCodMarc	:= SPACE(TAMSX3("ZBI_MARCA")[1])
	Private _oGCodMarca
	Private _mNomeMarc   := SPACE(50) 

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel"   ,"Exporta p/Excel"})
	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B642IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBI",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Flutuação de Quantidade e Preço" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA642A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA642B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA642C()

	@ 050,310 SAY "MARCA:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodMarca VAR _cCodMarc F3("Z37") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA642D()
	@ 050,410 SAY _mNomeMarc SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, "U_B642TOK" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B642FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B642DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA642A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA642D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA642B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA642D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA642C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA642D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA642D()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local ifg, _msc
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef) .or. Empty(_cCodMarc)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	_mNomeMarc := Posicione("Z37", 1, xFilial("Z37") + _cCodMarc, "Z37_DESCR")

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RECEITA" + msrhEnter
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
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RECEITA'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	// Verifica se todos os itens de chave necessárias existem na tabela correlata e se não existir, cria.
	msTpFlut := {'1','2'}
	For ifg := 1 to Len(msTpFlut)
		RG003 := " SELECT '" + msTpFlut[ifg] + "' TPFLUT, ZBH.ZBH_PCTGMR, ZBH.ZBH_FORMAT "
		RG003 += "   FROM " + RetSqlName("ZBH") + " ZBH "
		RG003 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
		RG003 += "    AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
		RG003 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
		RG003 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
		RG003 += "    AND ZBH.ZBH_MARCA = '" + _cCodMarc + "' "
		RG003 += "    AND ZBH.ZBH_PERIOD = '00' "
		RG003 += "    AND ZBH.ZBH_ORIGF = '1' "
		RG003 += "    AND ZBH.ZBH_PCTGMR + ZBH.ZBH_FORMAT NOT IN(SELECT XZBI.ZBI_PCTGMR + XZBI.ZBI_FORMAT "
		RG003 += "                                                 FROM " + RetSqlName("ZBI") + " XZBI "
		RG003 += "                                                WHERE XZBI.ZBI_FILIAL = ZBH.ZBH_FILIAL "
		RG003 += "                                                  AND XZBI.ZBI_VERSAO = ZBH.ZBH_VERSAO "
		RG003 += "                                                  AND XZBI.ZBI_REVISA = ZBH.ZBH_REVISA "
		RG003 += "                                                  AND XZBI.ZBI_ANOREF = ZBH.ZBH_ANOREF "
		RG003 += "                                                  AND XZBI.ZBI_MARCA = ZBH.ZBH_MARCA "
		RG003 += "                                                  AND XZBI.ZBI_TPFLUT = '" + msTpFlut[ifg] + "' "
		RG003 += "                                                  AND XZBI.D_E_L_E_T_ = ' ' ) "
		RG003 += "    AND ZBH.D_E_L_E_T_ = ' ' "
		RG003 += "  GROUP BY ZBH.ZBH_PCTGMR, ZBH.ZBH_FORMAT "
		RG003 += "  ORDER BY ZBH.ZBH_PCTGMR, ZBH.ZBH_FORMAT "
		RGIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RG003),'RG03',.T.,.T.)
		dbSelectArea("RG03")
		RG03->(dbGoTop())

		If RG03->(!Eof())

			While RG03->(!Eof())

				Reclock("ZBI",.T.)
				ZBI->ZBI_FILIAL  := xFilial("ZBH")
				ZBI->ZBI_VERSAO  := _cVersao
				ZBI->ZBI_REVISA  := _cRevisa
				ZBI->ZBI_ANOREF  := _cAnoRef
				ZBI->ZBI_MARCA   := _cCodMarc
				ZBI->ZBI_TPFLUT  := RG03->TPFLUT
				ZBI->ZBI_PCTGMR  := RG03->ZBH_PCTGMR
				ZBI->ZBI_FORMAT  := RG03->ZBH_FORMAT
				ZBI->(MsUnlock())

				RG03->(dbSkip())

			End

		EndIf

		RG03->(dbCloseArea())
		Ferase(RGIndex+GetDBExtension())
		Ferase(RGIndex+OrdBagExt())

	Next ifg

	BeginSql Alias _cAlias

		SELECT *, ZBI_M01 + ZBI_M02 + ZBI_M03, + ZBI_M04 + ZBI_M05 + ZBI_M06 + ZBI_M07 + ZBI_M08 + ZBI_M09 + ZBI_M10 + ZBI_M11 + ZBI_M12 ZBI_TOTAL
		FROM %TABLE:ZBI% ZBI
		WHERE ZBI_FILIAL = %xFilial:ZBI%
		AND ZBI_VERSAO = %Exp:_cVersao%
		AND ZBI_REVISA = %Exp:_cRevisa%
		AND ZBI_ANOREF = %Exp:_cAnoRef%
		AND ZBI_MARCA = %Exp:_cCodMarc%
		AND ZBI.%NotDel%
		ORDER BY ZBI_TPFLUT, ZBI_PCTGMR, ZBI_FORMAT
	EndSql

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBI_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBI"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBI_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBI_DPCTGM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SX5", 1, xFilial("SX5") + "ZH" + (_cAlias)->ZBI_PCTGMR, "X5_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBI_DFORMT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZZ6", 1, xFilial("ZZ6") + (_cAlias)->ZBI_FORMAT, "ZZ6_DESC")

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI, _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBI_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZBI')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZBI->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZBI",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZBI->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				ZBI->(DbDelete())

			EndIf

			ZBI->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZBI",.T.)

				ZBI->ZBI_FILIAL  := xFilial("ZBI")
				ZBI->ZBI_VERSAO  := _cVersao
				ZBI->ZBI_REVISA  := _cRevisa
				ZBI->ZBI_ANOREF  := _cAnoRef
				ZBI->ZBI_MARCA   := _cCodMarc
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZBI->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

				ZBI->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao        := SPACE(TAMSX3("ZBI_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBI_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBI_ANOREF")[1])
	_cCodMarc       := SPACE(TAMSX3("ZBI_MARCA")[1])
	_mNomeMarc      := SPACE(50)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B642FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _zpTPFLUT := ""
	Local _zpPCTGMR := ""
	Local _zpFORMAT  := ""

	Do Case

		Case Alltrim(cMenVar) == "M->ZBI_TPFLUT"
		_zpTPFLUT   := M->ZBI_TPFLUT
		_zpPCTGMR   := GdFieldGet("ZBI_PCTGMR",_nAt)
		_zpFORMAT   := GdFieldGet("ZBI_FORMAT",_nAt)

		Case Alltrim(cMenVar) == "M->ZBI_PCTGMR"
		_zpTPFLUT   := GdFieldGet("ZBI_TPFLUT",_nAt)
		_zpPCTGMR   := M->ZBI_PCTGMR
		_zpFORMAT   := GdFieldGet("ZBI_FORMAT",_nAt)
		GdFieldPut("ZBI_DPCTGM"   , Posicione("SX5", 1, xFilial("SX5") + "ZH" + _zpPCTGMR, "X5_DESCRI") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBI_FORMAT"
		_zpTPFLUT   := GdFieldGet("ZBI_TPFLUT",_nAt)
		_zpPCTGMR   := GdFieldGet("ZBI_PCTGMR",_nAt)
		_zpFORMAT   := M->ZBI_FORMAT
		GdFieldPut("ZBI_DFORMT"   , Posicione("ZZ6", 1, xFilial("ZZ6") + _zpFORMAT, "ZZ6_DESC") , _nAt)

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_zpTPFLUT) .and. _zpTPFLUT == GdFieldGet("ZBI_TPFLUT",_nI)

				If !Empty(_zpPCTGMR) .and. _zpPCTGMR == GdFieldGet("ZBI_PCTGMR",_nI)

					If !Empty(_zpFORMAT) .and. _zpFORMAT == GdFieldGet("ZBI_FORMAT",_nI)

						MsgInfo("A chave composta de Tipo Flutuação / Pacote GMR / Formato só pode existir uma única vez. Na linha: " + Alltrim(Str(_nI)) + " já existe esta chave informada!!!")
						Return .F.

					EndIf

				EndIf

			EndIf

		EndIf

	Next


Return .T.

User Function B642DOK()

	Local _lRet	:=	.T.

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B642IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Comissãos REC.I ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B642IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos percentuais de Flutuação para Orçamento RECEITA."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação dos percentuais...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B642IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZBI'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBI_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZBI_REC_WT"})

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


/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦  TudoOk                                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B642TOK()

	Local _lRet	:=	.T.
	Local _nI

	nPosTPFLUT  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBI_TPFLUT"})
	nPosPCTGMR  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBI_PCTGMR"})
	nPosFORMAT  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBI_FORMAT"})

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If !GDdeleted(_nI)

			nTPFLUTLin  := _oGetDados:aCols[_nI][nPosTPFLUT]
			nPCTGMRLin  := _oGetDados:aCols[_nI][nPosPCTGMR]
			nFORMATLin  := _oGetDados:aCols[_nI][nPosFORMAT]

			xkPosRec := aScan(_oGetDados:aCols,{|x| Alltrim(x[nPosTPFLUT]) == Alltrim(nTPFLUTLin) .and. Alltrim(x[nPosPCTGMR]) == Alltrim(nPCTGMRLin) .and. Alltrim(x[nPosFORMAT]) == Alltrim(nFORMATLin) })

			If xkPosRec <> _nI

				MsgInfo("A chave composta de Vendedor / Pacote GMR / Categoria só pode existir uma única vez. Na linha: " + Alltrim(Str(xkPosRec)) + " já existe esta chave informada!!!")
				Return .F.

			EndIf

		EndIf

	Next _nI

Return _lRet
