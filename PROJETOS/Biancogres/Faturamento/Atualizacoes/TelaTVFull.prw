#Include "Totvs.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"
#include "TbiConn.ch"

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Empresa: Facile Sistemas																			//
// Desenv.: Paulo Cesar Camata Jr																	//
// Dt Des.: 10.07.2013																				//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Objetivo do Programa																				//
// Mostrar na tela as placas para carregamento e descarregamento na empresa de acordo com os dados	//
// preenchidos pelo usuario e emitindo um som ao se atualizar alguma informacao na tela 			//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Alteracao: 16.09.2013																			//
// Desenv.: Paulo Cesar Camata Junior																//
// Efetuando alteracao para que sejam mostrados apenas carregamentos de 2 empresas (Emp. Esquerda e	//
// e Emp. Direita) que são informados nas variáveis cEmpEsq e cEmpDir								//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Alteracao: 14.01.2014																			//
// Desenv.: Paulo Cesar Camata Junior																//
// Alterando forma de busca de dados devido a problemas com o Prepare Environment. Foi alterado para//
// que os dados sejam gravados na tabela PZ1 de cada empresa, sendo possivel a busca da mesma.		//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Alteracao: 04/08/2014
// Desenv.: Paulo Cesar Camata Junior
// Alterando a tela da TV pois será colocado mais uma TV, e nao sendo necessário mais a apresentaçao//
// do nome do motorista, e as empresas Biancogres e Incesa serão separadas por televisao			//
// Foi criado um parametro para controle de qual numeracao da tv esta sendo utilizada, com isso sera//
// Buscados as informacoes de cada empresa. Foi criado mais um campo na tabela para que seja informa//
// do a empresa que esta sendo apresentada na tela.													//
//////////////////////////////////////////////////////////////////////////////////////////////////////
*-----------------------------------------------------------------------------------------------------------------------------------
/////////////////////////////////////
// Funcao para chamada por empresa //
/////////////////////////////////////
User Function TVEmp01()
	TelaTVFull(1)
Return Nil

User Function TVEmp05()
	TelaTVFull(2)
	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////
// Funcao para desenhar tela / Foi necessario para diferenciar as chamadas das empresas //
//////////////////////////////////////////////////////////////////////////////////////////
Static Function TelaTVFull(_nOpc)

	Local oFont1 := TFont():New("Arial Black", , 090, , .T., , , , , .F., .F.)
	Local oFont2 := TFont():New("Arial"      , , 080, , .T., , , , , .F., .F.)
	Local oFont3 := TFont():New("Arial"      , , 050, , .T., , , , , .F., .F.)
	Local aObj   := {}
	Local i

	////////////////////////////////////////////////////////////////////////
	// Variaveis privadas pois serao alteradas pela funcao de atualizacao //
	////////////////////////////////////////////////////////////////////////
	Private oSay1
	Private oSay2
	Private oSay3
	Private oSay4
	Private oSay5
	Private oSay6
	Private oSay7
	Private oSay8
	Private oSay9
	Private oSay10
	Private oSay11
	Private oSay12
	Private oSay13
	Private oSay14
	Private oSay15
	Private oSay16
	Private oSay17
	Private oSay18
	Private oSay19
	Private oSay20
	Private oSay21
	Private oSay22
	Private oSay23
	Private oSay24
	Private oSay25
	Private oSay26

	//Private _cBitMap := fBitMap(_cCodEmp)   // Logo da Empresa Esquerda
	Private _nQtdPlc := 12
	Private _aPlacas := Array(_nQtdPlc) // Variavel com as placas (12)
	Private _aLocais := Array(_nQtdPlc) // Variavel com os Locais de Carregamento (12)
	Private _cObserv := ""
	Private nTxAtualiz := 10000 // Taxa de atualizacao da tela em milisegundos utilizado pela funcao TTimer
	Private _cEoL := Chr(13) + Chr(10)
	Private oDlg

	Default _nOpc := 1

	// BIANCOGRES
	If _nOpc == 1
		_cCodEmp := "01"
	ElseIf _nOpc == 2 // INCESA
		_cCodEmp := "05"
	Else
		MsgStop("Parametro de Chamada da Função não suportado. Verifique com a TI.", "TelaTVFull")
		Return Nil
	EndIf

	// Iniciando Vetor com String Nula
	For i := 1 To Len(_aPlacas)
		_aPlacas[i] := ""
		_aLocais[i] := ""
	Next i

	// Conectando na Empresa sem consumir licenca
	RpcSetType(3)
	Prepare Environment Empresa _cCodEmp Filial "01"

	aScreenRes := GetScreenRes() // Busca resolucao da tela para que a tela principal seja desenhada conforme resolucao
	//aScreenRes := {1920, 1080} // Efetuando teste com Full HD

	Define MsDialog oDlg Title "PLACAS PARA CARREGAMENTO" From 0, 0 To aScreenRes[2], aScreenRes[1] Colors CLR_BLACK Pixel

	///////////////
	// 1a COLUNA //
	///////////////
	nTam  := aScreenRes[1]/4
	nLin  := 10
	nCol  := 0
	nCol1 := nCol + 40
	nCol2 := nCol + 240

	oPanel2 := TPanel():New(0, 0, , oDlg, , , , , , aScreenRes[1], nLin+45, , .T.) // Painel para separacao do cabecalho
	oPanel1 := TPanel():New(nLin+45, 0, , oDlg, , , , , , nTam, aScreenRes[2]/2 - 80, , .T.) // Painel para separacao do Carregamento e Descarregamento
	oPanel3 := TPanel():New(aScreenRes[2]/2 - 80, 0, , oDlg, , , , , , aScreenRes[1], 65, .T., .T.) // Painel para separacao do cabecalho

	// Retirando a Logo pois sera colocando a placa na TV
	//@ -012, aScreenRes[2]/8 BITMAP oBitmap1 SIZE 300, 074 Of oPanel1 FILENAME _cBitMap NOBORDER ADJUST Pixel CENTERED

	// Descricao das Colunas
	@ nLin, nCol1+10 Say oSay00  PROMPT "PLACA" Size 200, 045 Of oPanel2 FONT oFont1 COLORS CLR_BLACK Pixel
	@ nLin, nCol2+10 Say oSay00  PROMPT "LOCAL" Size 200, 045 Of oPanel2 FONT oFont1 COLORS CLR_BLACK Pixel

	nLin := 10
	@ nLin, nCol  Say oSay10 PROMPT "1."        Size nTam, 045 Of oPanel1 FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay11 PROMPT _aPlacas[1] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG01") COLORS CLR_BLACK Pixel 
	@ nLin, nCol2 Say oSay21 PROMPT _aLocais[1] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG01") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "2."        Size nTam, 045 Of oPanel1 FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay12 PROMPT _aPlacas[2] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG02") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay22 PROMPT _aLocais[2] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG02") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "3."        Size nTam, 045 Of oPanel1 FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay13 PROMPT _aPlacas[3] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG03") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay23 PROMPT _aLocais[3] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG03") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "4."        Size nTam, 045 Of oPanel1 FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay14 PROMPT _aPlacas[4] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG04") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay24 PROMPT _aLocais[4] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG04") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "5."        Size nTam, 045 Of oPanel1 FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay15 PROMPT _aPlacas[5] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG05") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay25 PROMPT _aLocais[5] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG05") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "6."        Size nTam, 045 Of oPanel1 FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay16 PROMPT _aPlacas[6] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG06") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay26 PROMPT _aLocais[6] Size nTam, 045 Of oPanel1 FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG06") COLORS CLR_BLACK Pixel

	////////////////
	// OBSERVACAO //
	////////////////
	nLin := 5
	@ nLin, nCol+10 Say oSayOb PROMPT "OBS.:  " + _cObserv Size aScreenRes[2] - nCol1 - 100, 250 Of oPanel3 FONT oFont3 COLORS CLR_BLACK Pixel

	///////////////
	// 2a COLUNA //
	///////////////
	nCol  := aScreenRes[1]/4 + 5
	nCol1 := nCol + 50
	nCol2 := nCol + 250
	nLin  := 10

	// Retirando a Logo pois sera colocando a placa na TV
	//@ -012, nCol+150 BITMAP oBitmap1 Size 300, 074 Of oDlg FILENAME _cBitMap NOBORDER ADJUST Pixel CENTERED

	// Descricao das Colunas
	@ nLin, nCol1+10 Say oSay00  PROMPT "PLACA" Size nTam, 045 Of oPanel2 FONT oFont1 COLORS CLR_BLACK Pixel
	@ nLin, nCol2+10 Say oSay00  PROMPT "LOCAL" Size nTam, 045 Of oPanel2 FONT oFont1 COLORS CLR_BLACK Pixel

	nLin += 55
	@ nLin, nCol  Say oSay10 PROMPT "7."          Size nTam, 045 Of oDlg FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay17  PROMPT _aPlacas[07] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG07") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay27  PROMPT _aLocais[07] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG07") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "8."          Size nTam, 045 Of oDlg FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay18  PROMPT _aPlacas[08] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG08") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay28  PROMPT _aLocais[08] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG08") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "9."          Size nTam, 045 Of oDlg FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay19  PROMPT _aPlacas[09] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG09") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay29  PROMPT _aLocais[09] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG09") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "10."         Size nTam, 045 Of oDlg FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay110 PROMPT _aPlacas[10] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG10") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay210 PROMPT _aLocais[10] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG10") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "11."         Size nTam, 045 Of oDlg FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay111 PROMPT _aPlacas[11] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG11") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay211 PROMPT _aLocais[11] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG11") COLORS CLR_BLACK Pixel

	nLin += 70
	@ nLin, nCol  Say oSay10 PROMPT "12."         Size nTam, 045 Of oDlg FONT oFont2 COLORS CLR_BLACK Pixel
	@ nLin, nCol1 Say oSay112 PROMPT _aPlacas[12] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_PLCG12") COLORS CLR_BLACK Pixel
	@ nLin, nCol2 Say oSay212 PROMPT _aLocais[12] Size nTam, 045 Of oDlg FONT oFont2 Picture PesqPict("PZ1", "PZ1_LCCG12") COLORS CLR_BLACK Pixel

	// Atualizar Informacoes da tela na primeira entrada da tela
	AtuInform(.T.)

	// Componente de tempo para chamada da funcao de busca de atualizacao
	oTimer := TTimer():New(nTxAtualiz, {|| AtuInform(.F.)}, oDlg)
	oTimer:Activate()

	Activate MsDialog oDlg Centered

	Reset Environment

	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////
// Funcao para atualizar as informacoes caso haja modificacao //
////////////////////////////////////////////////////////////////
Static Function AtuInform(_lPrimeiro)
	Local _lSom := .F. // Variavel atualizada quando há modificacao para que o som seja reproduzido
	Local _aPlaAux := {}
	Local i

	Default _lPrimeiro := .F. // Variavel utilizada para identificar se foi a primeira chamada da funcao ao abrir a tela

	PZ1->(DbGoTop())

	// Buscando Placas com Status de Alterado = "A"
	If Posicione("PZ1", 1, xFilial("PZ1"), "FOUND()")

		If _lPrimeiro .Or. PZ1->PZ1_STATUS == "A"

			// Apenas Placas que nao foram pesadas
			For i := 1 To _nQtdPlc
				If U_VldPlaca(&("PZ1->PZ1_PLCG" + StrZero(i, 2)), .F.)
					aAdd(_aPlaAux, {&("PZ1->PZ1_PLCG" + StrZero(i, 2)), &("PZ1->PZ1_LCCG" + StrZero(i, 2))})
				EndIf
			Next i

			For i := 1 To Len(_aPlaAux)
				_aPlacas[i] := _aPlaAux[i, 1]
				_aLocais[i] := _aPlaAux[i, 2]
			Next i

			For i := Len(_aPlaAux) + 1 To Len(_aPlacas)
				_aPlacas[i] := ""
				_aLocais[i] := ""
			Next

			_cObserv := PZ1->PZ1_OBSCAR

			RecLock("PZ1", .F.)
			PZ1->PZ1_STATUS := "M"
			PZ1->(MsUnlock())

			_lSom := .T.
		EndIf
	EndIf

	If _lSom
		fAtuTela()
		fReproduzSom()
	EndIf

	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para atualizar a tela de acordo com as variaveis utilizadas //
////////////////////////////////////////////////////////////////////////
Static Function fAtuTela()
	Local i
	For i := 1 To Len(_aPlacas)
		&("oSay1" + AllTrim(Str(i))):SetText(_aPlacas[i])
		&("oSay2" + AllTrim(Str(i))):SetText(_aLocais[i])
	Next i

	oSayOb:SetText("OBS.:  " + _cObserv)

	oDlg:Refresh()
	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
// Funcao para reproduzir o som quando alguma informacao da tela é atualizada //
////////////////////////////////////////////////////////////////////////////////
Static Function fReproduzSom()
	Local cDirCli := "C:\TEMP\"   // GetClientDir()
	Local cDirSrv := "\Media\"    // Caminho da pasta dentro do RootPath
	Local cSom    := "sound1.wav" // Nome do Arquivo a ser executado (SOM)

	//Verifica a existencia dos arquivos necessário localmente para a reproducao do som
	If !File(cDirCli + "wav.exe")
		//Tenta copiar do servidor
		CPYS2T(cDirSrv + "wav.exe", cDirCli, .F.)
	EndIf

	If !File(cDirCli + "RunProcess.exe")
		//Tenta copiar do servidor
		CPYS2T(cDirSrv + "RunProcess.exe", cDirCli, .F.)
	EndIf

	//Verifica a existencia do som solicitado
	If !File(cDirCli + cSom)
		//Tenta copiar do servidor
		CPYS2T(cDirSrv + cSom, cDirCli, .F.)
	EndIf

	// Executando programa para reproducao do som
	WinExec(cDirCli + "runprocess.exe /x wav.exe " + cDirCli + cSom, 0)

	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////
// Funcao geral para buscar o nome do arquivo da logo da empresa//
// Esse arquivo devera estar na pasta RootPath do protheus		//
//////////////////////////////////////////////////////////////////
/*
Static Function fBitMap(cEmpresa)
cLogo := "\sigaadv\"

If AllTrim(cEmpresa) == "01"
cLogo += "logomarca_biancogres.jpg"
ElseIf AllTrim(cEmpresa) == "05"
cLogo += "logomarca_incesa.jpg"
ElseIf AllTrim(cEmpresa) == "99"
cLogo += "logomarca_teste.jpg"
Else
cLogo := ""
EndIf

Return cLogo
*-----------------------------------------------------------------------------------------------------------------------------------
*/