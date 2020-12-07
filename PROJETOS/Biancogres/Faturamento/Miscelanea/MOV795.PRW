#INCLUDE "RWMAKE.CH"
#INCLUDE "FIVEWIN.CH"
#include "Fileio.ch"
#INCLUDE "TOTVS.CH"

#DEFINE OneStopBit   '0'
#DEFINE OneStopBits  '1'
#DEFINE TwoStopBits  '2'
#DEFINE NoParity 	 '0'
#DEFINE OddParity    '1'
#DEFINE EvenParity   '2'
#DEFINE MarkParity   '3'
#DEFINE SpaceParity  '4'

/*/{Protheus.doc} MOV795
@author Marcos Alberto Soprani
@since 13/06/07
@version 1.0
@description Leitura do Serial da Balança
@obs Em 19/01/17, foi implementada a funcionalidade de leitura de REDE
@type function
/*/

User Function MOV795()

	Local   oDlg,oFont
	Private oBruto,oLiq,oTara
	Private nBruto
	Private nTara
	Private nLiq

	_peso   := 0
	_oF     := oSend(TFont(),"New","Verdana",0,14,,.t.)
	aButton := Array(2)

	Define MSDIALOG _blc FROM 345,402 To 444,621 Title OemToAnsi("Confirma Peso") Pixel
	@ 001,002 To 26,102 Title OemToAnsi("Leitura da Balança")
	@ 011,007 Get _peso Picture "@E 999999999.99" When .F. Size 90,10 Object _ogpeso
	_ogpeso:ofont:=_oF

	@ 030,002 Button aButton[1] Prompt OemToAnsi("Lê Balança")  Action (CarregaPeso())      Size 45,16 of _blc Pixel
	@ 030,057 Button aButton[2] Prompt OemToAnsi("Confirma")    Action (_blc:End())         Size 45,16 of _blc Pixel

	Activate Dialog _blc Centered //on Init CarregaPeso()

Return(_peso)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ CarregaPeso ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 19.06.07 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsavel pela leitura do Sinal da Balanc                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function CarregaPeso()

	If 1 == 2

		Processa({|| RptDetCom1()})                         // Leitura Serial
		//*******************************************************************

	Else		

		// em 20/01/17 por Marcos Alberto Soprani

		Processa({|| RptDetRede()})                       // Leitura via Rede
		//*******************************************************************

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ RptDetCom1  ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 19.06.07 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsavel pela leitura do Sinal da Balanc  - SERIAL      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function RptDetCom1()

	local _x

	if cempant = "05"
		cPorta   := "COM1"
		cBaudRate:= "9600"
		cParity  := "2"
		cData    := "8"
		cStop    := "2"
		cTimeOut := "00500"
	else
		cPorta   := "COM1"
		cBaudRate:= "9600"
		cParity  := "2"
		cData    := "8"
		cStop    := "2"
		cTimeOut := "00500"
	end if
	cSettings:= cBaudRate+','+cParity+','+cData+','+cStop+','+cTimeOut

	nH       := fOpenPort(cPorta,cSettings,0)
	/*----- Desabilita os Botoes -----*/
	AButton(.F.)

	If nH == -1
		MSGSTOP( "Erro: Não abriu a porta "+cPorta+":"+cSettings )
		_blc:End()
		Return(.T.)
	EndIf

	**-------+----+----+-----+-----+-----+----+-----+-----+-----+-----**
	**-------| 1  | 2  |  3  |  4  |  5  |  6 |  7  |  8  |  9  |  0  ** equivalencia do que vem da porta
	**-------+----+----+-----+-----+-----+----+-----+-----+-----+-----**
	_chr=CHR(177)+CHR(178)+CHR(179)+CHR(180)+CHR(181)+CHR(182)+CHR(183)+CHR(184)+CHR(185)+CHR(186)

	dbSelectArea("SB1")
	While .T.
		_in := Space(28)
		ProcRegua(RecCount())
		While .T.
			IncProc("Estabilizando...."+_in)
			sleep(5000)
			nbytes:=fread(nH,@_in ,28)
			_in := Alltrim(_in)
			For _x = 1 to Len( _chr )
				If At( Substr( _chr , _x , 1 ) , _in  ) > 0
					_in = StrTran( _in , Substr( _chr , _x , 1 ) , Str( _x , 1 ) )
				EndIf
			Next
			If ( Substr(right(_in,3),1,1) == ":" .and. Substr(right(_in,10),1,1) == "/" .and. Substr(right(_in,13),1,1) == "/" ) .or. ;
			( Substr(right(_in,4),1,1) == ":" .and. Substr(right(_in,11),1,1) == "/" .and. Substr(right(_in,14),1,1) == "/" )
				Exit
			Else
				fclose(nH)
				sleep(5000)
				nH := fOpenPort(cPorta,cSettings,0)
				Exit
			EndIf
		End

		Exit

	End

	/*----- Habilita os Botoes -----*/
	AButton(.T.)

	If cEmpAnt == "01" //Biancogres
		_peso := Alltrim(Substr(Alltrim(_in),3,6))
	Else							//Incesa
		_peso := Substr(Alltrim(_in),1,7)
	EndIf

	_peso := Val( _peso )
	_ogpeso:Refresh()
	_blc:Refresh()
	_ogpeso:Refresh()

	fclose(nH)

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ AButton ³ Autores ³ Marcos Alberto S       ³ Data ³19/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Habilita e Dasabilita os Botoes                              ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function AButton(lAction)

	aEval(aButton, If(lAction, {|_1| _1:Enable()}, {|_1| _1:Disable()}))

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ RptDetRede  ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 19.06.07 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsavel pela leitura do Sinal da Balanc - REDE         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function RptDetRede()

	Local _nMsCont      := 0
	Local oObjBalJund
	Local nMsCont

	Private zpRetSocket := {}

	Private nMsPorta
	Private cMsIP   

	If cEmpAnt == "05"
		nMsPorta  := 6000
		cMsIP     := "192.168.51.99"
	Else
		MsgINFO("Favor verificar a empresa!!!")
	EndIf

	ProcRegua(50)
	msLoop := 0
	While msLoop <= 50
		msLoop ++
		IncProc("Conectando (.........)")
		IncProc("Conectando (x........)")
		IncProc("Conectando (.x.......)")
		IncProc("Conectando (..x......)")
		IncProc("Conectando (...x.....)")
		IncProc("Conectando (....x....)")
		IncProc("Conectando (.....x...)")
		IncProc("Conectando (......x..)")
		IncProc("Conectando (.......x.)")
		IncProc("Conectando (........x)")
		IncProc("Conectando (.........)")
	End

	BEGIN SEQUENCE

		/* Pesagem via TCP/IP */
		oObjBalJund := tSocketClient():New()

		For _nMsCont := 1 to 10 

			IncProc("Conectando")

			nMsResp := oObjBalJund:Connect( nMsPorta, cMsIP, 10000 )

			Sleep(2000) 

			If (nMsResp == 0 )
				Exit
			Else
				Sleep(2000) 
			Endif

		Next

		While .T. 

			IncProc("Estabilizando (1)")

			cBuffer := ""
			nQtdnew = oObjBalJund:Receive( cBuffer, 100 )
			If( nQtdnew >= 0 )
				zpRetSocket := StrTokArr(cBuffer,"    ")
				Exit				
			EndIf

		End

		oObjBalJund:CloseConnection()
		FreeObj(oObjBalJund)

	END SEQUENCE

	If Len(zpRetSocket) > 0

		_MsCnt := 0 
		_peso  := Substr(zpRetSocket[1],1,7)
		For nMsCont := 1 to Len(zpRetSocket)

			IncProc("Estabilizando .... (2)")

			If Substr(zpRetSocket[1],1,7) == _peso
				_MsCnt ++
				If _MsCnt >= 10 
					Exit
				EndIf
			EndIf

		Next

		_peso := Val( _peso )
		_ogpeso:Refresh()
		_blc:Refresh()
		_ogpeso:Refresh()

	Else

		MsgSTOP("Favor efetuar o processo de <Lê Balança> novamente!!!")

		_peso := 0
		_ogpeso:Refresh()
		_blc:Refresh()
		_ogpeso:Refresh()

	EndIf

Return
