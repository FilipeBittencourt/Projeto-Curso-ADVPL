#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG100
@author Gabriel Rossi Mafioletti
@since 11/07/2019
@version 1.0
@description Rotina para Manutenção do OBZ
@type function
/*/

#DEFINE OPC_VISUAL 0
#DEFINE OPC_MANUT GD_INSERT+GD_DELETE+GD_UPDATE

#DEFINE VISUAL 1
#DEFINE MANUT 2
#DEFINE IMPORTA 3
#DEFINE EXPORTA 4

User Function BIAFG100()

	Local _oDlgGer
	Local oLayer
	Local _oPanel
	Local _cTexto1
	Local _cTexto2
	Local _cTexto3
	Local _cTexto4
	Local oFont

	Private _oAcessos	:=	tAcessosOrcamento():New()

	Define FONT oFont  NAME "Arial" SIZE 0,14 BOLD

	Define MsDialog _oDlgGer Title "OBZ Integration" From 0,0 To 230,500 Of oMainWnd Pixel

	oLayer := FWLayer():New()
	oLayer:Init(_oDlgGer, .F., .T.)

	// Adiciona linha ao Layer
	oLayer:AddLine("LIN1", 20, .F.)
	oLayer:AddLine("LIN2", 20, .F.)
	oLayer:AddLine("LIN3", 20, .F.)
	oLayer:AddLine("LIN4", 20, .F.)
	oLayer:AddLine("LIN5", 20, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn("COL1", 30, .T., "LIN1")
	oLayer:AddCollumn("COL2", 70, .T., "LIN1")

	oLayer:AddCollumn("COL1", 30, .T., "LIN2")
	oLayer:AddCollumn("COL2", 70, .T., "LIN2")

	oLayer:AddCollumn("COL1", 30, .T., "LIN3")
	oLayer:AddCollumn("COL2", 70, .T., "LIN3")

	oLayer:AddCollumn("COL1", 30, .T., "LIN4")
	oLayer:AddCollumn("COL2", 70, .T., "LIN4")

	oLayer:AddCollumn("COL1", 30, .T., "LIN5")
	oLayer:AddCollumn("COL2", 70, .T., "LIN5")

	//Visualiza
	_oPanel	:=	oLayer:getColPanel( "COL1", "LIN1" )
	oBtVisual := TButton():New( 10, 10, "Visualiza", _oPanel,{||fTelaObz(OPC_VISUAL,VISUAL)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	_cTexto1	:=	"Visualiza OBZ já gravado"
	_oPanel	:=	oLayer:getColPanel( "COL2", "LIN1" )
	_oSay1	:=	tSay():New(010,010,{|| _cTexto1  },_oPanel,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,10)

	//Manutencao
	_oPanel	:=	oLayer:getColPanel( "COL1", "LIN2" )  
	oBtManut := TButton():New( 10, 10, "Manutenção", _oPanel,{||fTelaObz(OPC_MANUT,MANUT)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	_cTexto2	:=	"Inclui/Altera OBZ Manualmente"
	_oPanel	:=	oLayer:getColPanel( "COL2", "LIN2" )
	_oSay2	:=	tSay():New(010,010,{|| _cTexto2  },_oPanel,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,10)	

	//Importar
	_oPanel	:=	oLayer:getColPanel( "COL1", "LIN3" )
	oBtImport := TButton():New( 10, 10, "Importar", _oPanel,{||fTelaObz(OPC_VISUAL,IMPORTA)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	_cTexto3	:=	"Importa OBZ de um arquivo Excel padronizado" 	
	_oPanel	:=	oLayer:getColPanel( "COL2", "LIN3" )
	_oSay3	:=	tSay():New(010,010,{|| _cTexto3  },_oPanel,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,10)

	//Exportar
	_oPanel	:=	oLayer:getColPanel( "COL1", "LIN4" )
	oBtExport := TButton():New( 10, 10, "Exportar", _oPanel,{||fTelaObz(OPC_VISUAL,EXPORTA)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	_cTexto4	:=	"Exporta dados para um arquivo excel"
	_oPanel	:=	oLayer:getColPanel( "COL2", "LIN4" )
	_oSay4	:=	tSay():New(010,010,{|| _cTexto4  },_oPanel,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,10)

	ACTIVATE DIALOG _oDlgGer CENTERED

Return

Static Function ValidPerg(_nModo)

	local cLoad	    := "BIAFG100" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(TAMSX3("Z98_VERSAO")[1])
	MV_PAR02 := SPACE(TAMSX3("Z98_REVISA")[1])
	MV_PAR03 := SPACE(TAMSX3("Z98_ANOREF")[1])
	MV_PAR04 := SPACE(TAMSX3("Z98_CLVL")[1])
	MV_PAR05 := SPACE(TAMSX3("Z98_CLVL")[1])
	MV_PAR06 := SPACE(TAMSX3("Z98_CONTA")[1])
	MV_PAR07 := SPACE(TAMSX3("Z98_CONTA")[1])

	aAdd( aPergs ,{1,"Versão " 	   		,MV_PAR01 ,""  ,"",'ZB5'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Revisão " 	   	,MV_PAR02 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"AnoRef " 	   		,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Cl. Valor De " 	   		,MV_PAR04 ,""  ,"",'CTH'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cl. Valor Até " 	   		,MV_PAR05 ,""  ,"NAOVAZIO()",'CTH'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Conta De " 	   		,MV_PAR06 ,""  ,"",'CT1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Conta Até " 	   		,MV_PAR07 ,""  ,"NAOVAZIO()",'CT1'  ,'.T.',50,.F.})		

	If ParamBox(aPergs ,"Alteração de quantidade de componentes de acordo com formato",,{|| U_BFG100VR(_nModo)},,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)

	EndIf

Return lRet

Static Function fTelaObz(_nOpc,_nModo)

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}
	Local _oDlg
	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local aNoFields     := {"Z98_VERSAO", "Z98_REVISA", "Z98_ANOREF", "Z98_ANO", "Z98_FILEIN", "Z98_IDDRV", "Z98_DIDDRV"}

	Local cSeek	        := xFilial("Z98") + SPACE(TAMSX3("Z98_VERSAO")[1]) + SPACE(TAMSX3("Z98_REVISA")[1]) + SPACE(TAMSX3("Z98_ANOREF")[1])
	Local bWhile	    := {|| Z98_FILIAL + Z98_VERSAO + Z98_REVISA + Z98_ANOREF }  

	Local _aCols	:=	{}
	Local _aHeader	:=	{}

	Local _aButtons	:=	{}

	Private _oGetDados

	Private _nAtPesq	:=	0
	Private _nColInd	:=	0
	Private _lAscend	:=	.F.

	Private cArquivo   := space(100)

	Private _cPesq	:=	SPACE(100)

	If _nModo == VISUAL
		aNoFields     := {"Z98_VERSAO", "Z98_REVISA", "Z98_ANOREF", "Z98_ANO", "Z98_FILEIN"}
	EndIf

	If !ValidPerg(_nModo)
		Return
	EndIf

	_oAcessos:GetAcessos(MV_PAR01,MV_PAR02,MV_PAR03,"OBZ",__cUserId)

	If Len(_oAcessos:aAcessos) == 0
		MsgAlert("Usuário sem acesso ao OBZ para o período em questão")
		Return
	EndIf

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )	

	FillGetDados(4,"Z98",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)

	_aColsBkp	:=	aClone(_aCols)

	If _nModo <> EXPORTA .And. _nModo <> IMPORTA

		_aCols	:=	fMontaCols(_aHeader,_nOpc)

	EndIf

	Define MsDialog _oDlg Title "OBZ Integration" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR MV_PAR01 Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL WHEN .F.

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR MV_PAR02  SIZE 50, 11 OF _oDlg PIXEL WHEN .F.

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR MV_PAR03  SIZE 50, 11 OF _oDlg PIXEL WHEN .F.

	@ 050,300 SAY "Pesquisa:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,360 MSGET _oGPesq VAR _cPesq  SIZE 100, 11 OF _oDlg PIXEL VALID fGetPesq()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], _nOpc, /*[ cLinhaOk]*/, "U_BG100TOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_BG100FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,/*"U_BG100DOK()"*/ /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	_oGetDados:oBrowse:lUseDefaultColors := .F.
	_oGetDados:oBrowse:SetBlkBackColor({|| fCorPesq(_oGetDados:aCols,_oGetDados:nAt,_oGetDados:aHeader)})
	//		_oGetDados:oBrowse:bHeaderClick	:= {|| fIndice()}
	If _nModo == IMPORTA
		U_BG100IMP()
	EndIf

	Do Case
		Case _nModo == IMPORTA
		ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(_oDlg),_nOpcA := 0)}, {|| _oDlg:End()},,)	
		Case _nModo == MANUT
		ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(_oDlg),_nOpcA := 0)}, {|| _oDlg:End()},,)
		CASE _nModo == VISUAL
		aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("R")}, "Relatório Integração" , "Relatório Integração"})
		ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(_oDlg),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons)
		OtherWise
		U_BIA393("E")
		FreeObj(_oDlg)
	EndCase

Return


User Function BFG100VR(_nModo)

	Local _cAlias      := GetNextAlias()
	Local _lret		:=	.T.

	IF EMPTY(MV_PAR02) .Or. Empty(MV_PAR03)
		ZB5->(DbSetOrder(1))
		ZB5->(DbSeek(xFilial("ZB5")+MV_PAR01))
		MV_PAR02	:=	ZB5->ZB5_REVISA
		MV_PAR03	:=	ZB5->ZB5_ANOREF
	EndIF

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual OBZ" + CRLF
	xfMensCompl += "Status igual Aberto" + CRLF
	xfMensCompl += "Data Digitação diferente de branco e anterior à data do dia" + CRLF
	xfMensCompl += "Data Conciliação igual branco" + CRLF
	xfMensCompl += "Data Encerramento igual branco"

	BeginSql Alias _cAlias
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:MV_PAR01%
		AND ZB5.ZB5_REVISA = %Exp:MV_PAR02%
		AND ZB5.ZB5_ANOREF = %Exp:MV_PAR03%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'OBZ'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(_cAlias)->(dbGoTop())
	If (_cAlias)->CONTAD <> 1 .And. _nModo <> VISUAL
		MsgALERT("A versão informada não está ativa para execução deste processo." + CRLF + CRLF + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + CRLF + CRLF + xfMensCompl + CRLF + CRLF + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		_lret	:=	.F.
	Else

	EndIf	

	(_cAlias)->(dbCloseArea())

Return _lRet

Static Function fMontaCols(_aHeader,_nOpc)

	Local _aCols	:=	{}
	Local _cAlias	:=	GetnextAlias()
	Local _cClVlIn	:=	""
	Local _nTotReg	:=	0
	Local _cCodEnt	:= ""
	Local _cCodPct	:=	""
	Local _nI		:=	0

	For _nI := 1 to Len(_oAcessos:aAcessos)
		If _nOpc == OPC_MANUT .And. _oAcessos:aAcessos[_nI,3]
			_cClvlIn	+= "'" + _oAcessos:aAcessos[_nI,1] + "'" + Iif(_nI <> Len(_oAcessos:aAcessos),",","")
		Else
			_cClvlIn	+= "'" + _oAcessos:aAcessos[_nI,1] + "'" + Iif(_nI <> Len(_oAcessos:aAcessos),",","")
		EndIf	
	Next
	If Empty(_cClVlIn)
		_cClVlIn	:=	"''"
	EndIf

	_cClvlIn := "%(" + _cClvlIn + ")%"	

	BeginSql Alias _cAlias

		SELECT *,
		ISNULL(CONVERT( VARCHAR(8000), CONVERT(VARBINARY(8000), Z98_JSTMEM)), '') AS JSTMEM, 
		(SELECT COUNT(*)
		FROM %TABLE:Z98% Z98
		WHERE Z98_FILIAL = %xFilial:Z98%
		AND Z98_VERSAO = %Exp:MV_PAR01%
		AND Z98_REVISA = %Exp:MV_PAR02%
		AND Z98_ANOREF = %Exp:MV_PAR03%
		AND Z98_CLVL IN %Exp:_cClvlIn%
		AND Z98_CLVL BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
		AND Z98_CONTA BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
		AND Z98_EMPR = %Exp:cEmpAnt%
		AND Z98_FIL = %Exp:cFilAnt%
		AND Z98.%NotDel%
		) NUMREG
		FROM %TABLE:Z98% Z98
		WHERE Z98_FILIAL = %xFilial:Z98%
		AND Z98_VERSAO = %Exp:MV_PAR01%
		AND Z98_REVISA = %Exp:MV_PAR02%
		AND Z98_ANOREF = %Exp:MV_PAR03%
		AND Z98_CLVL IN %Exp:_cClvlIn%
		AND Z98_CLVL BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
		AND Z98_CONTA BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
		AND Z98_EMPR = %Exp:cEmpAnt%
		AND Z98_FIL = %Exp:cFilAnt%
		AND Z98.%NotDel%
		ORDER BY Z98_VERSAO, Z98_REVISA, Z98_ANOREF
	EndSql

	_nTotReg :=  (_cAlias)->(NUMREG)
	ProcRegua(_nTotReg)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(_nTotReg)))

			AADD(_aCols, Array(Len(_aHeader)+1) )

			For _nI := 1 to Len(_aHeader)

				If Alltrim(_aHeader[_nI][2]) == "Z98_ALI_WT"
					_aCols[Len(_aCols), _nI] := "Z98"

				ElseIf Alltrim(_aHeader[_nI][2]) == "Z98_REC_WT"
					_aCols[Len(_aCols), _nI] := R_E_C_N_O_

				ElseIf Alltrim(_aHeader[_nI][2]) == "Z98_DCLVL"
					_aCols[Len(_aCols), _nI] := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->Z98_CLVL, "CTH_DESC01")

				ElseIf Alltrim(_aHeader[_nI][2]) == "Z98_ENTID"
					_cCodEnt := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->Z98_CLVL, "CTH_YENTID")
					_aCols[Len(_aCols), _nI] := Posicione("ZCA", 1, xFilial("ZCA") + _cCodEnt, "ZCA_DESCRI")

				ElseIf Alltrim(_aHeader[_nI][2]) == "Z98_DCONTA"
					_aCols[Len(_aCols), _nI] := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->Z98_CONTA, "CT1_DESC01")

				ElseIf Alltrim(_aHeader[_nI][2]) == "Z98_PACOTE"
					_cCodPct := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->Z98_CONTA, "CT1_YPCT20")
					_aCols[Len(_aCols), _nI] := Posicione("ZC8", 1, xFilial("ZC8") + _cCodPct, "ZC8_DESCRI")

				ElseIf Alltrim(_aHeader[_nI][2]) == "Z98_JSTMEM"
					_aCols[Len(_aCols), _nI] := (_cAlias)->JSTMEM

				ElseIf Alltrim(_aHeader[_nI][2]) == "Z98_INIDPR"
					_aCols[Len(_aCols), _nI] := ctod((_cAlias)->Z98_INIDPR)

				ElseIf Alltrim(_aHeader[_nI][2]) == "Z98_DIDDRV"
					_aCols[Len(_aCols), _nI] := Posicione("ZBE", 1, xFilial("ZBE") + MV_PAR01 + MV_PAR02 + MV_PAR03 + (_cAlias)->Z98_IDDRV, "ZBE_DESCRI")

				Else
					_aCols[Len(_aCols), _nI] := &(Alltrim(_aHeader[_nI][2]))

				EndIf			

			Next _nI

			_aCols[Len(_aCols), _nI] := .F.	

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	EndIf	

Return _aCols

Static Function fGetPesq()

	Local _nI
	Local _nJ

	_nAtPesq	:=	0

	If !Empty(_cPesq)

		For _nI	:= 1 to Len(_oGetDados:Acols)
			If _nAtPesq <> 0
				Exit
			EndIF
			For _nJ	:= 1 To Len(_oGetDados:aHeader)

				If ALLTRIM(UPPER(_cPesq)) $ Alltrim(cValToChar(_oGetDados:aCols[_nI,_nJ]))
					_nAtPesq	:=	_nI
					MsgInfo("A Pesquisa realizada encontrou resultado no campo " + _oGetDados:aHeader[_nJ,1])
					Exit
				EndIF

			Next

		Next

		If _nAtPesq > 0
			_oGetDados:Goto(_nAtPesq)
			_oGetDados:Refresh()
		Else
			MsgInfo("A Pesquisa realizada não encontrou resultados")
		EndIf
	EndIf

Return .T.

Static Function fCorPesq(aLinha,nLinha,aHeader)

	Local _nPosDel	:=	Len(aHeader) + 1
	Local nRet

	If _oGetDados:aCols[nLinha,_nPosDel]
		nRet	:=	12632256
	ElseIf _nAtPesq == nLinha
		nRet	:= 16777113
	Else
		nRet	:=	16777215
	EndIF

Return nRet

User Function BG100FOK()

	Local _cCampo	:=	ReadVar()
	Local _cTpClvl	:=	""
	Local _lret		:=	.T.
	Local _cNome	:=	""
	Local _nPos

	Local _nTotal	:=	0
	Local _nTotalQt	:=	0

	Local _nMes

	Local _nI

	If Alltrim(_cCampo) == "M->Z98_CONTA"
		If SUBSTRING(M->Z98_CONTA,1,1) $ "6/3/4" 
			IF !SUBSTRING(M->Z98_CONTA,1,3) $ "311/315/612/615/611" .Or. Alltrim(M->Z98_CONTA) $ "31104004/61204004/61108001/61108002/61108003/31104008/31104006/61103002/31103003/61103003/61109001/61203003/61204008/31104010/61105004/61301006"
				DbSelectArea("CT1")
				CT1->(DbSetOrder(1))
				If CT1->(DbSeek(xFilial("CT1")+M->Z98_CONTA))

					_cNome	:=	CT1->CT1_DESC01

					_cTpClvl	:=	U_B478RTCC(GdFieldGet("Z98_CLVL",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols))[2]

					If Substring(M->Z98_CONTA,1,1) == "6" .And. _cTpClvl <> "C"
						MsgInfo("Conta não pode estar associada a essa classe de valor!","BIAFG100")
						_lRet	:=	.F.
					ElseIf Substring(M->Z98_CONTA,1,1) == "3" .And. _cTpClvl <> "D"
						MsgInfo("Conta não pode estar associada a essa classe de valor!","BIAFG100")
						_lRet	:=	.F.		
					EndIf
				Else
					MsgInfo("Não Existe Cadastro para a Conta Informada!","BIAFG100")
					_lRet	:=	.F.
				EndIf

				If _lRet
					GdFieldPut("Z98_DCONTA",_cNome,_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)
				EndIf
			Else
				MsgInfo("Contas iniciadas em 311,315,612,615 e 611 não são admissíveis no cadastro do OBZ!","BIAFG100")
				_lret	:=	.F.
			EndIf
		Else
			MsgInfo("Somente contas iniciadas em 6,3 e 4 são admissíveis no cadastro do OBZ!","BIAFG100")
			_lret	:=	.F.

		EndIf

	ElseIf Alltrim(_cCampo) == "M->Z98_CLVL"

		_npos	:=	aScan(_oAcessos:aAcessos,{|x| Alltrim(x[1]) == Alltrim(M->Z98_CLVL) .And. x[3]})

		If _npos	== 0
			_lRet	:=	.F.
			MsgInfo("Usuário não possui acesso para manutenção na classe de valor informada","BIAFG100")
		EndIf

		If _lRet
			DbSelectArea("CTH")
			CTH->(DbSetOrder(1))
			If CTH->(DbSeek(xFilial("CTH")+M->Z98_CLVL))
				_cNome	:=	CTH->CTH_DESC01

				_cTpClvl	:=	U_B478RTCC(M->Z98_CLVL)[2]

				If Substring(GdFieldGet("Z98_CONTA",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols),1,1) == "6" .And. _cTpClvl <> "C"
					MsgInfo("Conta não pode estar associada a essa classe de valor!","BIAFG100")
					_lRet	:=	.F.
				ElseIf Substring(GdFieldGet("Z98_CONTA",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols),1,1) == "3" .And. _cTpClvl <> "D"
					MsgInfo("Conta não pode estar associada a essa classe de valor!","BIAFG100")
					_lRet	:=	.F.		
				EndIf
			Else
				MsgInfo("Não Existe Cadastro para a Classe de Valor Informada!","BIAFG100")
				_lRet	:=	.F.
			EndIf

			If _lRet
				GdFieldPut("Z98_DCLVL",_cNome,_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)
			EndIf
		EndIf

	ElseIf Alltrim(_cCampo) >= "M->Z98_VLM01" .And. Alltrim(_cCampo) <= "M->Z98_VLM12" 

		_nTotal		:=	0
		_ntotalQt	:=	0

		_nMes	:=	Val(RIGHT(Alltrim(_cCampo),2))

		For _nI	:=	1 to 12

			If _nI == _nMes
				_nTotal	+=	&(_cCampo) * GdFieldGet("Z98_QTM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols)

				GdFieldPut("Z98_M" + RIGHT(Alltrim(_cCampo),2) ,&(_cCampo) * GdFieldGet("Z98_QTM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols),_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)

			Else
				_nTotal	+= GdFieldGet("Z98_VLM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) * GdFieldGet("Z98_QTM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols)
			EndIf

		Next

		GdFieldPut("Z98_TOTAL",_nTotal ,_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)

	ElseIf Alltrim(_cCampo) >= "M->Z98_QTM01" .And. Alltrim(_cCampo) <= "M->Z98_QTM12" 

		_nTotal		:=	0
		_ntotalQt	:=	0

		_nMes	:=	Val(RIGHT(Alltrim(_cCampo),2))

		For _nI	:=	1 to 12

			If _nI == _nMes
				_nTotal	+=	&(_cCampo) * GdFieldGet("Z98_VLM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols)

				GdFieldPut("Z98_M" + RIGHT(Alltrim(_cCampo),2) ,&(_cCampo) * GdFieldGet("Z98_VLM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols),_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)

				_nTotalQt += &(_cCampo)
			Else
				_nTotal	+= GdFieldGet("Z98_VLM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) * GdFieldGet("Z98_QTM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols)
				_ntotalQt	+= GdFieldGet("Z98_QTM" + PADL(Alltrim(Str(_nI)),2,'0'),_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols)
			EndIf

		Next

		GdFieldPut("Z98_TOTAL",_nTotal ,_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)


		GdFieldPut("Z98_QTTOT",_ntotalQt,_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)

	EndIf

Return _lRet

User Function BG100TOK()

	Local msEnter  := Chr(13) + Chr(10)
	Local _lRet	   := .T.
	Local _nI	   := 0
	Local msAreaT  := GetArea()

	Local msChkApl := Upper("0=Nenhum;1=Producao;2=Manutencao;3=Melhoria_M;4=Seguranca;5=Calibracao;6=Melhoria_Prod;7=Administrativo;8=Fiscal;9=Patrimonial;")

	Local _nPosClVl   := 0
	Local _nPosAplic  := 0
	Local _nPosEmpr	  := 0
	Local _nPosFil	  := 0

	_nPosClVl	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "Z98_CLVL"})
	_nPosAplic	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "Z98_APLIC"})
	_nPosEmpr	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "Z98_EMPR"})
	_nPosFil	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "Z98_FIL"})

	For _nI	:=	1 to Len(_oGetdados:aCols)

		msAplCor := Alltrim(UPPER(_oGetDados:aCols[_nI,_nPosAplic])) + ";"

		If !msAplCor $ msChkApl

			MsgSTOP("Encontrada inconsistência no preenchimento com campo Z98_APLIC da linha " + Alltrim(Str(_nI))+ "." + msEnter  + msEnter + "Favor informar um valor válido: " + msEnter + msEnter + msChkApl , "BIAFG100(1)")
			_lRet	:=	.F.
			Exit

		EndIf

		msClvlEmp := Substr(Posicione("CTH", 1, xFilial("CTH") + _oGetDados:aCols[_nI,_nPosClVl], "CTH_YEFORC"),1,2)
		If _oGetDados:aCols[_nI,_nPosEmpr] <> msClvlEmp

			_oGetDados:aCols[_nI,_nPosEmpr] := msClvlEmp

		EndIf 

		Z35->(dbSetOrder(1))
		Z35->(dbSeek(xFilial("Z35") + _oGetDados:aCols[_nI,_nPosEmpr] + _oGetDados:aCols[_nI,_nPosFil]))
		msValidFil := Z35->Z35_EMP + Z35->Z35_FIL
		If _oGetDados:aCols[_nI,_nPosEmpr] + _oGetDados:aCols[_nI,_nPosFil] <> msValidFil

			MsgSTOP("Encontrada inconsistência no preenchimento com campo Z98_FIL da linha " + Alltrim(Str(_nI))+ "." + msEnter  + msEnter + "Favor informar um valor válido, conforme cadastro de empresas" , "BIAFG100(3)")
			_lRet	:=	.F.
			Exit

		EndIf 

	Next

	RestArea(msAreaT)

Return _lret

Static Function fGrvDados(_oDlg)

	Local _nI
	Local _msc
	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z98_REC_WT"})
	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1

	dbSelectArea('Z98')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		nPosCONTA := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z98_CONTA" })

		If _oGetDados:aCols[_nI,nPosRec] > 0

			Z98->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("Z98",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("Z98->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				Z98->(DbDelete())

			EndIf

			Z98->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("Z98",.T.)

				Z98->Z98_FILIAL  := xFilial("Z98")
				Z98->Z98_VERSAO  := MV_PAR01
				Z98->Z98_REVISA  := MV_PAR02
				Z98->Z98_ANOREF  := MV_PAR03
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("Z98->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc
				Z98->Z98_USER   := cUserName
				Z98->Z98_DTPROC := Date()
				Z98->Z98_HRPROC := Time()
				Z98->Z98_LINHAA := _nI
				Z98->Z98_USRRSP := __cUserId
				Z98->Z98_USRRS2 := __cUserId

				Z98->(MsUnlock())

			EndIf

		EndIf

	Next

	_oDlg:End()

	MsgInfo("Manutenção realizada com Sucesso!")

Return

Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIAFG100ARQ' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	Local _cBKPMV	:=	MV_PAR01
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo    ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo    := ParamLoad(cFileName,,1,cArquivo)

	Endif

	MV_PAR01	:=	_cBKPMV

Return 

User Function BG100IMP()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos dados da planilha OBZ Integration!!!"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'Z98'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z98_REC_WT"})
	Local vtRecGrd := {}
	Local _nPos

	Local _aLogErro	:=	{}
	Local _lErroLin	:=	.F.

	Local _aCabErro	:=	{}

	Local _cTpClvl, vnb, ny, _msc, nx

	aAdd(_aCabErro,{"LINHA","C",15,0})
	aAdd(_aCabErro,{"ERRO","C",3,0})

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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "Z98_REC_WT"})
				nPosClvl  := aScan(aCampos,{|x| AllTrim(x) == "Z98_CLVL"})
				nPosConta := aScan(aCampos,{|x| AllTrim(x) == "Z98_CONTA"})

				If nPosRec <> 0 .And. nPosClvl <> 0 .And. nPosConta <> 0

					_npos	:=	aScan(_oAcessos:aAcessos,{|x| Alltrim(x[1]) == Alltrim(aLinha[nPosClvl]) .And. x[3]})

					If _npos	== 0
						_lErroLin	:=	.T.
						aAdd(_aLogErro,{Alltrim(Str(nx)),"Usuário não possui acesso para manutenção na classe de valor informada"})
					EndIf

					DbSelectArea("CTH")
					CTH->(DbSetOrder(1))
					If !CTH->(DbSeek(xFilial("CTH")+PADR(Alltrim(aLinha[nPosClvl]),TAMSX3("Z98_CLVL")[1])))
						_lErroLin	:=	.T.
						aAdd(_aLogErro,{Alltrim(Str(nx)),"Classe de Valor Não Encontrada"})
					EndIf

					DbSelectArea("CT1")
					CT1->(DbSetOrder(1))
					If !CT1->(DbSeek(xFilial("CT1")+PADR(Alltrim(aLinha[nPosConta]),TAMSX3("Z98_CONTA")[1])))
						_lErroLin	:=	.T.
						aAdd(_aLogErro,{Alltrim(Str(nx)),"Conta Não Encontrada"})
					EndIf

					_cTpClvl	:=	U_B478RTCC(PADR(Alltrim(aLinha[nPosClVl]),TAMSX3("Z98_CLVL")[1]))[2]

					If Substring(PADR(Alltrim(aLinha[nPosConta]),TAMSX3("Z98_CONTA")[1]),1,1) == "6" .And. _cTpClvl <> "C"
						aAdd(_aLogErro,{Alltrim(Str(nx)),"Conta não pode estar associada a essa classe de valor!"})
						_lErroLin	:=	.T.
					ElseIf Substring(PADR(Alltrim(aLinha[nPosConta]),TAMSX3("Z98_CONTA")[1]),1,1) == "3" .And. _cTpClvl <> "D"
						aAdd(_aLogErro,{Alltrim(Str(nx)),"Conta não pode estar associada a essa classe de valor!"})
						_lErroLin	:=	.T.		
					EndIf

					If !Substring(PADR(Alltrim(aLinha[nPosConta]),TAMSX3("Z98_CONTA")[1]),1,1) $ "6/3/4"
						aAdd(_aLogErro,{Alltrim(Str(nx)),"Somente contas iniciadas em 6,3 e 4 são admissíveis no cadastro do OBZ!"})
						_lErroLin	:=	.T.					
					EndIf 					

					IF Substring(PADR(Alltrim(aLinha[nPosConta]),TAMSX3("Z98_CONTA")[1]),1,3) $ "311/315/612/615/611" .And. !Alltrim(aLinha[nPosConta]) $ "31104004/61204004/61108001/61108002/61108003/31104008/31104006/61103002/31103003/61103003/61109001/61203003/61204008/31104010/61105004/61301006"
						aAdd(_aLogErro,{Alltrim(Str(nx)),"Contas iniciadas em 311,315,612,615 e 611 não são admissíveis no cadastro do OBZ!"})
						_lErroLin	:=	.T.						
					EndIf

					If _lErroLin
						Loop
					EndIf

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
							ELSEIf _oGetDados:aHeader[xkPosCampo][8] == "D"
								_oGetDados:aCols[nLinReg, xkPosCampo] := ctod((Alltrim(aLinha[_msc])))
							Else
								msLinTxt := FwNoAccent(UPPER(aLinha[_msc]))
								msLinTxt := StrTran( msLinTxt, "A¡", "A" )
								msLinTxt := StrTran( msLinTxt, "A£", "A" )
								msLinTxt := StrTran( msLinTxt, "Aª", "E" )
								msLinTxt := StrTran( msLinTxt, "A©", "E" )
								msLinTxt := StrTran( msLinTxt, "A‰", "E" )
								msLinTxt := StrTran( msLinTxt, "A³", "O" )
								msLinTxt := StrTran( msLinTxt, "Aµ", "O" )
								msLinTxt := StrTran( msLinTxt, "A´", "O" )
								msLinTxt := StrTran( msLinTxt, "Aº", "U" )
								msLinTxt := StrTran( msLinTxt, "A§", "C" )
								msLinTxt := StrTran( msLinTxt, "&#10;", ". " )
								msLinTxt := StrTran( msLinTxt, "A‡Aƒ", "CA" )
								msLinTxt := StrTran( msLinTxt, "A­", "I" )
								msLinTxt := StrTran( msLinTxt, "A‡", "C" )
								msLinTxt := StrTran( msLinTxt, "Aƒ", "A" )
								msLinTxt := StrTran( msLinTxt, "A“", "O" )
								msLinTxt := StrTran( msLinTxt, "A€", "A" )
								msLinTxt := StrTran( msLinTxt, "A¢", "A" )
								_oGetDados:aCols[nLinReg, xkPosCampo] := msLinTxt
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

	If nImport > 0 .And. Len(_aLogErro) == 0

		fCalcTot()

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")
		U_BIAXEXCEL(_aLogErro,_aCaberro)
		_oGetDados:aCols	:=	_aColsBkp
	EndIf

	RestArea(aArea)

Return

Static Function fCalcTot()

	Local _nI
	Local _nJ

	Local _ntotal	:=	0
	Local _nTotalQt	:=	0
	Local _cMes

	For _nJ := 1 to Len(_oGetDados:aCols)

		_ntotal	:=	0
		_ntotalQt := 0

		For _nI	:=	1 to 12
			_cMes	:=	PADL(Alltrim(Str(_nI)),2,'0')
			GdFieldPut("Z98_M" + _cMes , GdFieldGet("Z98_VLM" + _cMes ,_nJ,,_oGetDados:aHeader,_oGetDados:aCols) * GdFieldGet("Z98_QTM" + _cMes ,_nJ,,_oGetDados:aHeader,_oGetDados:aCols),_nJ,_oGetDados:aHeader,_oGetDados:aCols)

			_nTotal	+=	GdFieldGet("Z98_VLM" + _cMes ,_nJ,,_oGetDados:aHeader,_oGetDados:aCols) * GdFieldGet("Z98_QTM" + _cMes ,_nJ,,_oGetDados:aHeader,_oGetDados:aCols) 

			_ntotalQt +=	GdFieldGet("Z98_QTM" + _cMes ,_nJ,,_oGetDados:aHeader,_oGetDados:aCols)

		Next

		GdFieldPut("Z98_TOTAL",_nTotal,_nJ,_oGetDados:aHeader,_oGetDados:aCols)
		GdFieldPut("Z98_QTTOT",_nTotalQt,_nJ,_oGetDados:aHeader,_oGetDados:aCols)
	Next

Return
