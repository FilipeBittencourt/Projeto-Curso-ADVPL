#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA641
@author Marcos Alberto Soprani
@since 28/09/17
@version 1.0
@description Tela para cadastro de Comissões para o processo Orçamentário de RECEITA 
@type function
/*/

User Function BIA641()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBH") + SPACE(TAMSX3("ZBH_VERSAO")[1]) + SPACE(TAMSX3("ZBH_REVISA")[1]) + SPACE(TAMSX3("ZBH_ANOREF")[1]) + SPACE(TAMSX3("ZBH_MARCA")[1])
	Local bWhile	    := {|| ZBH_FILIAL + ZBH_VERSAO + ZBH_REVISA + ZBH_ANOREF + ZBH_MARCA }   

	Local aNoFields     := {"ZBH_VERSAO", "ZBH_REVISA", "ZBH_ANOREF", "ZBH_MARCA",;
	"ZBH_PERIOD", "ZBH_CANALD", "ZBH_GRPCLI", "ZBH_TPSEG", "ZBH_ESTADO", "ZBH_FORMAT", "ZBH_DFORMT", "ZBH_DGRPCI", "ZBH_QUANT",;
	"ZBH_VALOR", "ZBH_TOTAL", "ZBH_USER", "ZBH_DTPROC", "ZBH_HRPROC", "ZBH_VCOMIS", "ZBH_PICMS", "ZBH_VICMS", "ZBH_PPIS",;
	"ZBH_VPIS", "ZBH_PCOF", "ZBH_VCOF", "ZBH_PST", "ZBH_VST", "ZBH_PDIFAL", "ZBH_VDIFAL", "ZBH_ORIGF", "ZBH_FILEIN",;
	"ZBH_LINHAA","ZBH_CLASSE","ZBH_CLASSE",;
	"ZBH_PRZMET","ZBH_METVER","ZBH_PERVER","ZBH_PERBON","ZBH_VALVER","ZBH_VALBON","ZBH_PERCPV","ZBH_VALCPV","ZBH_PICMBO","ZBH_VICMBO"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBH_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBH_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBH_ANOREF")[1])
	Private _oGAnoRef
	Private _cCodMarc	:= SPACE(TAMSX3("ZBH_MARCA")[1])
	Private _oGCodMarca
	Private _mNomeMarc   := SPACE(50)
	Private _msCtrlAlt := .T. 

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel"   , "Exporta p/Excel"})
	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B641IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBH",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Comissões para Orçamento de Receita" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA641A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA641B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA641C()

	@ 050,310 SAY "MARCA:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodMarca VAR _cCodMarc F3("Z37") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA641D()
	@ 050,410 SAY _mNomeMarc SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, "U_B641TOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B641FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B641DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA641A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA641D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA641B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA641D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA641C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA641D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA641D()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()

	Local _msc

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
		_msCtrlAlt := .F.
		_oGetDados:lInsert := .F.
		_oGetDados:lUpdate := .F.
		_oGetDados:lDelete := .F.
	Else
		_msCtrlAlt := .T.
		_oGetDados:lInsert := .T.
		_oGetDados:lUpdate := .T.
		_oGetDados:lDelete := .T.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	// Confirma e gera registros na tabela de Verbas Eventuais para os casos em que os registros não foram incluídos
	RG003 := " SELECT ZBH.ZBH_VEND, ZBH.ZBH_PCTGMR, ZBH.ZBH_CATEG "
	RG003 += "   FROM " + RetSqlName("ZBH") + " ZBH "
	RG003 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
	RG003 += "    AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
	RG003 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
	RG003 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
	RG003 += "    AND ZBH.ZBH_MARCA = '" + _cCodMarc + "' "
	RG003 += "    AND ZBH.ZBH_PERIOD = '00' "
	RG003 += "    AND ZBH.ZBH_ORIGF = '1' "
	RG003 += "    AND ZBH.ZBH_VEND + ZBH.ZBH_PCTGMR + ZBH.ZBH_CATEG NOT IN(SELECT XZBH.ZBH_VEND + XZBH.ZBH_PCTGMR + XZBH.ZBH_CATEG "
	RG003 += "                                                               FROM " + RetSqlName("ZBH") + " XZBH "
	RG003 += "                                                              WHERE XZBH.ZBH_FILIAL = ZBH.ZBH_FILIAL "
	RG003 += "                                                                AND XZBH.ZBH_VERSAO = ZBH.ZBH_VERSAO "
	RG003 += "                                                                AND XZBH.ZBH_REVISA = ZBH.ZBH_REVISA "
	RG003 += "                                                                AND XZBH.ZBH_ANOREF = ZBH.ZBH_ANOREF "
	RG003 += "                                                                AND XZBH.ZBH_MARCA = ZBH.ZBH_MARCA "
	RG003 += "                                                                AND XZBH.ZBH_PERIOD = ZBH.ZBH_PERIOD "
	RG003 += "                                                                AND XZBH.ZBH_ORIGF = '2' "
	RG003 += "                                                                AND XZBH.D_E_L_E_T_ = ' ' ) "
	RG003 += "    AND ZBH.D_E_L_E_T_ = ' ' "
	RG003 += "  GROUP BY ZBH.ZBH_VEND, ZBH.ZBH_PCTGMR, ZBH.ZBH_CATEG "
	RG003 += "  ORDER BY ZBH.ZBH_VEND, ZBH.ZBH_PCTGMR, ZBH.ZBH_CATEG "
	RGIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RG003),'RG03',.T.,.T.)
	dbSelectArea("RG03")
	RG03->(dbGoTop())

	If RG03->(!Eof())

		While RG03->(!Eof())

			Reclock("ZBH",.T.)
			ZBH->ZBH_FILIAL  := xFilial("ZBH")
			ZBH->ZBH_VERSAO  := _cVersao
			ZBH->ZBH_REVISA  := _cRevisa
			ZBH->ZBH_ANOREF  := _cAnoRef
			ZBH->ZBH_MARCA   := _cCodMarc
			ZBH->ZBH_PERIOD  := "00"
			ZBH->ZBH_ORIGF   := "2"
			ZBH->ZBH_VEND    := RG03->ZBH_VEND
			ZBH->ZBH_PCTGMR  := RG03->ZBH_PCTGMR
			ZBH->ZBH_CATEG   := RG03->ZBH_CATEG
			ZBH->(MsUnlock())

			RG03->(dbSkip())

		End

	EndIf

	RG03->(dbCloseArea())
	Ferase(RGIndex+GetDBExtension())
	Ferase(RGIndex+OrdBagExt())

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZBH% ZBH
		WHERE ZBH_FILIAL = %xFilial:ZBH%
		AND ZBH_VERSAO = %Exp:_cVersao%
		AND ZBH_REVISA = %Exp:_cRevisa%
		AND ZBH_ANOREF = %Exp:_cAnoRef%
		AND ZBH_MARCA = %Exp:_cCodMarc%
		AND ZBH_PERIOD = '00'
		AND ZBH_ORIGF = '2'
		AND ZBH.%NotDel%
		ORDER BY ZBH_VEND, ZBH_PCTGMR, ZBH_CATEG
	EndSql

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBH"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_NOMEVE"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SA3", 1, xFilial("SA3") + (_cAlias)->ZBH_VEND, "A3_NOME")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_DPCTGM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SX5", 1, xFilial("SX5") + "ZH" + (_cAlias)->ZBH_PCTGMR, "X5_DESCRI")

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

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZBH')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZBH->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZBH",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBH->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

				Else

					ZBH->(DbDelete())

				EndIf

				ZBH->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZBH",.T.)

					ZBH->ZBH_FILIAL  := xFilial("ZBH")
					ZBH->ZBH_VERSAO  := _cVersao
					ZBH->ZBH_REVISA  := _cRevisa
					ZBH->ZBH_ANOREF  := _cAnoRef
					ZBH->ZBH_PERIOD  := "00"
					ZBH->ZBH_MARCA   := _cCodMarc
					ZBH->ZBH_ORIGF   := "2"
					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBH->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

					ZBH->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao        := SPACE(TAMSX3("ZBH_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBH_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBH_ANOREF")[1])
	_cCodMarc       := SPACE(TAMSX3("ZBH_MARCA")[1])
	_mNomeMarc      := SPACE(50)
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

User Function B641FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _zpVEND   := ""
	Local _zpPCTGMR := ""
	Local _zpCATEG  := ""

	Do Case

		Case Alltrim(cMenVar) == "M->ZBH_VEND"
		_zpVEND   := M->ZBH_VEND
		_zpPCTGMR := GdFieldGet("ZBH_PCTGMR",_nAt)
		_zpCATEG  := GdFieldGet("ZBH_CATEG",_nAt)
		GdFieldPut("ZBH_NOMEVE"   , Posicione("SA3", 1, xFilial("SA3") + _zpVEND, "A3_NOME") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBH_PCTGMR"
		_zpVEND   := GdFieldGet("ZBH_VEND",_nAt)
		_zpPCTGMR := M->ZBH_PCTGMR
		_zpCATEG  := GdFieldGet("ZBH_CATEG",_nAt)
		GdFieldPut("ZBH_DPCTGM"   , Posicione("SX5", 1, xFilial("SX5") + "ZH" + _zpPCTGMR, "X5_DESCRI") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBH_CATEG"
		_zpVEND   := GdFieldGet("ZBH_VEND",_nAt)
		_zpPCTGMR := GdFieldGet("ZBH_PCTGMR",_nAt)
		_zpCATEG  := M->ZBH_CATEG

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_zpVEND) .and. _zpVEND == GdFieldGet("ZBH_VEND",_nI)

				If !Empty(_zpPCTGMR) .and. _zpPCTGMR == GdFieldGet("ZBH_PCTGMR",_nI)

					If !Empty(_zpCATEG) .and. _zpCATEG == GdFieldGet("ZBH_CATEG",_nI)

						MsgInfo("A chave composta de Vendedor / Pacote GMR / Categoria só pode existir uma única vez. Na linha: " + Alltrim(Str(_nI)) + " já existe esta chave informada!!!")
						Return .F.

					EndIf

				EndIf

			EndIf

		EndIf

	Next

Return .T.

User Function B641DOK()

	Local _lRet	:=	.T.

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B641IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Comissãos REC.I ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B641IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos percentuais de Comissão para Orçamento RECEITA."))   
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
	Local cLoad	    := 'B641IEXC' + cEmpAnt
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
	Local cTabImp			:= 'ZBH'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZBH_REC_WT"})

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

User Function B641TOK()

	Local _lRet	:=	.T.
	Local _nI

	nPosVEND    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_VEND"})
	nPosPCTGMR  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_PCTGMR"})
	nPosCATEG   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_CATEG"})

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If !GDdeleted(_nI)

			nVENDLin    := _oGetDados:aCols[_nI][nPosVEND]
			nPCTGMRLin  := _oGetDados:aCols[_nI][nPosPCTGMR]
			nCATEGLin   := _oGetDados:aCols[_nI][nPosCATEG]

			xkPosRec := aScan(_oGetDados:aCols,{|x| Alltrim(x[nPosVEND]) == Alltrim(nVENDLin) .and. Alltrim(x[nPosPCTGMR]) == Alltrim(nPCTGMRLin) .and. Alltrim(x[nPosCATEG]) == Alltrim(nCATEGLin) })

			If xkPosRec <> _nI

				MsgInfo("A chave composta de Vendedor / Pacote GMR / Categoria só pode existir uma única vez. Na linha: " + Alltrim(Str(xkPosRec)) + " já existe esta chave informada!!!")
				Return .F.

			EndIf

		EndIf

	Next _nI

Return _lRet
