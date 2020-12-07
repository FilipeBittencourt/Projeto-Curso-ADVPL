#Include "Totvs.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"
#include "tbiconn.ch"

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Empresa: Facile Sistemas																			//
// Desenv.: Paulo Cesar Camata Jr																	//
// Dt Des.: 10/07/2013																				//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Objetivo do Programa																				//
// Mostrar na tela as placas para carregamento e descarregamento na empresa de acordo com os dados	//
// preenchidos pelo usuario e emitindo um som ao se atualizar alguma informacao na tela 			//
//////////////////////////////////////////////////////////////////////////////////////////////////////
User Function TelaTV()
	
	Local oDlg
	
	Local oFont1 := TFont():New("Lucida Console",,068,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("Arial Black",,032,,.T.,,,,,.F.,.F.)
	Local oFont3 := TFont():New("MS Sans Serif",,026,,.F.,,,,,.F.,.F.)
	Local oFont4 := TFont():New("Arial",,025,,.T.,,,,,.F.,.F.)
	
	Local aObj := {}
	
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
	
	Private nTxAtualiz := 10000 // Taxa de atualizacao da tela em milisegundos
	
	Private _cPlCar1 := AllTrim(GetMv("MV_YPLCAR1"))
	Private _cMtCar1 := fBusMotorista(_cPlCar1)
		
	Private _cPlCar2 := AllTrim(GetMv("MV_YPLCAR2"))
	Private _cMtCar2 := fBusMotorista(_cPlCar2)
		
	Private _cPlCar3 := AllTrim(GetMv("MV_YPLCAR3"))
	Private _cMtCar3 := fBusMotorista(_cPlCar3)
		
	Private	_cPlCar4 := AllTrim(GetMv("MV_YPLCAR4"))
	Private _cMtCar4 := fBusMotorista(_cPlCar4)
		
	Private _cPlCar5 := AllTrim(GetMv("MV_YPLCAR5"))
	Private _cMtCar5 := fBusMotorista(_cPlCar5)
		
	Private _cObsCarr := AllTrim(GetMv("MV_YOBSCAR"))

	Private _cPlDes1 := AllTrim(GetMv("MV_YPLDES1"))
	Private _cMtDes1 := AllTrim(GetMv("MV_YMTDES1"))
		
	Private _cPlDes2 := AllTrim(GetMv("MV_YPLDES2"))
	Private _cMtDes2 := AllTrim(GetMv("MV_YMTDES2"))
		
	Private _cPlDes3 := AllTrim(GetMv("MV_YPLDES3"))
	Private _cMtDes3 := AllTrim(GetMv("MV_YMTDES3"))
		
	Private _cPlDes4 := AllTrim(GetMv("MV_YPLDES4"))
	Private _cMtDes4 := AllTrim(GetMv("MV_YMTDES4"))
		
	Private _cPlDes5 := AllTrim(GetMv("MV_YPLDES5"))
	Private _cMtDes5 := AllTrim(GetMv("MV_YMTDES5"))
		
	Private _cObsDesc := AllTrim(GetMv("MV_YOBSDES"))
	
	aSize := MsAdvSize()
	AADD( aObj, { 100, 100, .T., .T. })

	// Cálculo automático da dimensões dos objetos (altura/largura) em pixel
	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPObj := MsObjSize( aInfo, aObj )
	
	// Cálculo automático de dimensões dos objetos MSGET
	aPGet := MsObjGetPos( (aSize[3] - aSize[1]), 315, { {004, 024, 240, 270} } )

  	DEFINE MSDIALOG oDlg TITLE "PLACAS PARA CARREGAMENTO/DESCARREGAMENTO" FROM aSize[7],aSize[1] To aSize[6],aSize[5] COLORS CLR_BLACK PIXEL
    
    //////////////////
    // CARREGAMENTO //
    //////////////////
    oPanel1 := TPanel():New(0, 0, , oDlg, , , , , , aSize[6]/2, aSize[5], , .T.) // Painel para separacao do Carregamento e Descarregamento
    
    // Calculo do posicionamento dos objetos sao efetuados de acordo com o tamanho total disponivel para a tela que esta na variavel aSize[6]
    @ 000, aSize[6]/8 + aSize[6]*0.05 SAY oSay1  PROMPT "CARREGAR" SIZE 117, 021 OF oPanel1 FONT oFont2 COLORS CLR_BLACK PIXEL
    
    @ 025, aSize[6]/8 SAY oSay2  PROMPT _cPlCar1 SIZE 198, 038 OF oPanel1 FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 050, aSize[6]/8 SAY oSay3  PROMPT _cMtCar1 SIZE 225, 017 OF oPanel1 FONT oFont3 COLORS CLR_BLACK PIXEL
    
    @ 070, aSize[6]/8 SAY oSay4  PROMPT _cPlCar2 SIZE 198, 038 OF oPanel1 FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 095, aSize[6]/8 SAY oSay5  PROMPT _cMtCar2 SIZE 225, 017 OF oPanel1 FONT oFont3 COLORS CLR_BLACK PIXEL
    
    @ 115, aSize[6]/8 SAY oSay6  PROMPT _cPlCar3 SIZE 198, 038 OF oPanel1 FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 140, aSize[6]/8 SAY oSay7  PROMPT _cMtCar3 SIZE 225, 017 OF oPanel1 FONT oFont3 COLORS CLR_BLACK PIXEL
    
    @ 160, aSize[6]/8 SAY oSay8  PROMPT _cPlCar4 SIZE 198, 038 OF oPanel1 FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 185, aSize[6]/8 SAY oSay9  PROMPT _cMtCar4 SIZE 225, 017 OF oPanel1 FONT oFont3 COLORS CLR_BLACK PIXEL
    
    @ 205, aSize[6]/8 SAY oSay10 PROMPT _cPlCar5 SIZE 198, 038 OF oPanel1 FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 230, aSize[6]/8 SAY oSay11 PROMPT _cMtCar5 SIZE 225, 017 OF oPanel1 FONT oFont3 COLORS CLR_BLACK PIXEL
    
    @ 245, 020 SAY oSay12 PROMPT "Obs.:"   SIZE 198, 038 OF oPanel1 FONT oFont2 COLORS CLR_BLACK PIXEL
    @ 260, 010 SAY oSay13 PROMPT _cObsCarr SIZE 280, 040 OF oPanel1 FONT oFont4 COLORS CLR_BLACK PIXEL
    
    /////////////////////
    // DESCARREGAMENTO //
    /////////////////////
    @ 000, 5*aSize[6]/8 + aSize[6]*0.03 SAY oSay14 PROMPT "DESCARREGAR" SIZE 141, 021 OF oDlg FONT oFont2 COLORS CLR_BLACK PIXEL
    
    @ 025, 5*aSize[6]/8 SAY oSay15 PROMPT _cPlDes1 SIZE 198, 038 OF oDlg FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 050, 5*aSize[6]/8 SAY oSay16 PROMPT _cMtDes1 SIZE 225, 017 OF oDlg FONT oFont3 PICTURE "@!" COLORS CLR_BLACK PIXEL
    
    @ 070, 385 SAY oSay17 PROMPT _cPlDes2 SIZE 198, 038 OF oDlg FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 095, 385 SAY oSay18 PROMPT _cMtDes2 SIZE 225, 017 OF oDlg FONT oFont3 PICTURE "@!" COLORS CLR_BLACK PIXEL
    
    @ 115, 5*aSize[6]/8 SAY oSay19 PROMPT _cPlDes3 SIZE 198, 038 OF oDlg FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 140, 5*aSize[6]/8 SAY oSay20 PROMPT _cMtDes3 SIZE 225, 017 OF oDlg FONT oFont3 PICTURE "@!" COLORS CLR_BLACK PIXEL
    
    @ 160, 5*aSize[6]/8 SAY oSay21 PROMPT _cPlDes4 SIZE 198, 038 OF oDlg FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 185, 5*aSize[6]/8 SAY oSay22 PROMPT _cMtDes4 SIZE 225, 017 OF oDlg FONT oFont3 PICTURE "@!" COLORS CLR_BLACK PIXEL
    
    @ 205, 5*aSize[6]/8 SAY oSay23 PROMPT _cPlDes5 SIZE 198, 038 OF oDlg FONT oFont1 PICTURE "@R AAA-9999" COLORS CLR_BLACK PIXEL
    @ 230, 5*aSize[6]/8 SAY oSay24 PROMPT _cMtDes5 SIZE 225, 017 OF oDlg FONT oFont3 PICTURE "@!" COLORS CLR_BLACK PIXEL
    
    @ 245, aSize[6]/2 + aSize[6]*0.02 SAY oSay25 PROMPT "Obs.:"   SIZE 198, 038 OF oDlg FONT oFont2 COLORS CLR_BLACK PIXEL
    @ 260, aSize[6]/2 + aSize[6]*0.02 SAY oSay26 PROMPT _cObsDesc SIZE 280, 040 OF oDlg FONT oFont4 PICTURE "@!" COLORS CLR_BLACK PIXEL
  	
  	// Componente de tempo para chamada da funcao de busca de atualizacao
  	oTimer := TTimer():New(nTxAtualiz, {|| AtuInform() }, oDlg )
  	oTimer:Activate()
  	
  	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////
// Funcao para atualizar as informacoes caso haja modificacao //
////////////////////////////////////////////////////////////////
Static Function AtuInform()
	Local _lSom := .F. // Variavel atualizada quando há modificacao para que o som seja reproduzido
	
	// Verificando se houve alteracao no Carregamento
	If 	AllTrim(_cPlCar1) <> AllTrim(GetMv("MV_YPLCAR1")) .Or. AllTrim(_cPlCar2) <> AllTrim(GetMv("MV_YPLCAR2")) .Or. ;
		AllTrim(_cPlCar3) <> AllTrim(GetMv("MV_YPLCAR3")) .Or. AllTrim(_cPlCar4) <> AllTrim(GetMv("MV_YPLCAR4")) .Or. ;
		AllTrim(_cPlCar5) <> AllTrim(GetMv("MV_YPLCAR5")) .Or. AllTrim(_cObsCarr) <> AllTrim(GetMv("MV_YOBSCAR"))
		
		_cPlCar1 := AllTrim(GetMv("MV_YPLCAR1"))
		_cMtCar1 := fBusMotorista(_cPlCar1)
		
		_cPlCar2 := AllTrim(GetMv("MV_YPLCAR2"))
		_cMtCar2 := fBusMotorista(_cPlCar2)
		
		_cPlCar3 := AllTrim(GetMv("MV_YPLCAR3"))
		_cMtCar3 := fBusMotorista(_cPlCar3)
		
		_cPlCar4 := AllTrim(GetMv("MV_YPLCAR4"))
		_cMtCar4 := fBusMotorista(_cPlCar4)
		
		_cPlCar5 := AllTrim(GetMv("MV_YPLCAR5"))
		_cMtCar5 := fBusMotorista(_cPlCar5)
		
		_cObsCarr := AllTrim(GetMv("MV_YOBSCAR"))
		
		_lSom := .T.
	EndIf
	
	// Verificando se houve alteracao no Descarregamento
	If 	AllTrim(_cPlDes1) <> AllTrim(GetMv("MV_YPLDES1")) .Or. AllTrim(_cPlDes2) <> AllTrim(GetMv("MV_YPLDES2")) .Or. ;
		AllTrim(_cPlDes3) <> AllTrim(GetMv("MV_YPLDES3")) .Or. AllTrim(_cPlDes4) <> AllTrim(GetMv("MV_YPLDES4")) .Or. ;
		AllTrim(_cPlDes5) <> AllTrim(GetMv("MV_YPLDES5")) .Or. AllTrim(_cMtDes1) <> AllTrim(GetMv("MV_YMTDES1")) .Or. ;
		AllTrim(_cMtDes2) <> AllTrim(GetMv("MV_YMTDES2")) .Or. AllTrim(_cMtDes3) <> AllTrim(GetMv("MV_YMTDES3")) .Or. ;
		AllTrim(_cMtDes4) <> AllTrim(GetMv("MV_YMTDES4")) .Or. AllTrim(_cMtDes5) <> AllTrim(GetMv("MV_YMTDES5")) .Or. ;
		AllTrim(_cObsDesc) <> AllTrim(GetMv("MV_YOBSDES"))
		
		_cPlDes1 := AllTrim(GetMv("MV_YPLDES1"))
		_cMtDes1 := AllTrim(GetMv("MV_YMTDES1"))
		
		_cPlDes2 := AllTrim(GetMv("MV_YPLDES2"))
		_cMtDes2 := AllTrim(GetMv("MV_YMTDES2"))
		
		_cPlDes3 := AllTrim(GetMv("MV_YPLDES3"))
		_cMtDes3 := AllTrim(GetMv("MV_YMTDES3"))
		
		_cPlDes4 := AllTrim(GetMv("MV_YPLDES4"))
		_cMtDes4 := AllTrim(GetMv("MV_YMTDES4"))
		
		_cPlDes5 := AllTrim(GetMv("MV_YPLDES5"))
		_cMtDes5 := AllTrim(GetMv("MV_YMTDES5"))
		
		_cObsDesc := AllTrim(GetMv("MV_YOBSDES"))
		
		_lSom := .T.
	EndIf
	
	If _lSom
		fAtuTela()
		fReproduzSom()
	EndIf
	
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////
// Funcao para buscar nome do motorista da placa passada como parametro //
//////////////////////////////////////////////////////////////////////////
Static Function fBusMotorista(_cPlaca)
	Local _cNomMotorista
	Local _cEoL := Chr(10) + Chr(13)
	
	// Comando SQL para buscar o Nome do motorista pela placa
	_cSelect := "SELECT Z11_MOTORI " + _cEoL
	_cSelect += "  FROM " + RetSqlName("Z11") + _cEoL
	_cSelect += " WHERE Z11_FILIAL = " + ValToSql(xFilial("Z11")) + _cEoL
	_cSelect += "   AND Z11_PESOIN = 0 " + _cEoL
	_cSelect += "   AND Z11_PESOSA = 0 " + _cEoL
	_cSelect += "   AND Z11_PCAVAL = " + ValToSql(_cPlaca) + _cEoL
	_cSelect += "   AND D_E_L_E_T_ = '' " + _cEoL
	
	TcQuery _cSelect New Alias "MOTORISTA"
	
	If !MOTORISTA->(EoF())
		_cNomMotorista := AllTrim(MOTORISTA->Z11_MOTORI)
	Else
		_cNomMotorista := ""
	EndIf
	MOTORISTA->(DbCloseArea())
	
Return _cNomMotorista
*-----------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para atualizar a tela de acordo com as variaveis utilizadas //
////////////////////////////////////////////////////////////////////////
Static Function fAtuTela()

	// SAY`S DE CARREGAMENTO
	oSay2:SetText(_cPlCar1)
	oSay3:SetText(_cMtCar1)
	oSay4:SetText(_cPlCar2)
	oSay5:SetText(_cMtCar2)
	oSay6:SetText(_cPlCar3)
	oSay7:SetText(_cMtCar3)
	oSay8:SetText(_cPlCar4)
	oSay9:SetText(_cMtCar4)
	oSay10:SetText(_cPlCar5)
	oSay11:SetText(_cMtCar5)
	oSay13:SetText(_cObsCarr)
	
	// SAY`S DE DESCARREGAMENTO
	oSay15:SetText(_cPlDes1)
	oSay16:SetText(_cMtDes1)
	oSay17:SetText(_cPlDes2)
	oSay18:SetText(_cMtDes2)
	oSay19:SetText(_cPlDes3)
	oSay20:SetText(_cMtDes3)
	oSay21:SetText(_cPlDes4)
	oSay22:SetText(_cMtDes4)
	oSay23:SetText(_cPlDes5)
	oSay24:SetText(_cMtDes5)
	oSay26:SetText(_cObsDesc)
	
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
// Funcao para reproduzir o som quando alguma informacao da tela é atualizada //
////////////////////////////////////////////////////////////////////////////////
Static Function fReproduzSom()
	Local cDirCli := GetClientDir()
	Local cDirSrv := '\Media\' // Caminho da pasta dentro do RootPath
	Local cSom    := 'sound1.wav' // Nome do Arquivo a ser executado (SOM)
	
	//Verifica a existencia dos arquivos necessário localmente para a reproducao do som
	If !File(cDirCli + 'wav.exe')
		
		//Tenta copiar do servidor
		CPYS2T(cDirSrv + 'wav.exe', cDirCli, .F.)
	EndIF
	
	If !File(cDirCli + 'RunProcess.exe')
		
		//Tenta copiar do servidor
		CPYS2T(cDirSrv + 'RunProcess.exe', cDirCli, .F.)
	EndIF
	
	//Verifica a existencia do som solicitado
	If !File(cDirCli + cSom)
		
		//Tenta copiar do servidor
		CPYS2T(cDirSrv + cSom, cDirCli, .F.)
	EndIF
	
	// Executando programa para reproducao do som
	WinExec(cDirCli + 'runprocess.exe /x wav.exe ' + cDirCli + cSom, 0)
	
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------