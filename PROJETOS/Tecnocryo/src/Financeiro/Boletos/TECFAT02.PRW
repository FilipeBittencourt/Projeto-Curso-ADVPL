#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOBJECT.CH"
#include "TOTVS.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH"
//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : TECFAT02                                               								|
//                                                      	                                            |
// Data      : 08/09/16                                                                     		|
//                                                                                                  |
// Autor	 : Jessé Augusto                                                                        |
//__________________________________________________________________________________________________|
//                                                                                                 	|
// Descrição : Gerencia o processo de Reenvio de boletos aos clientes								|
//__________________________________________________________________________________________________|

User Function TECFAT02()

	Local oDlgBol

	Local oGrpFil
	Local oGrpAcao
	Local oGrpPick
	Local oGrpMarck
	Local oGrpChecados
	Local oGrpDetalhe
	Local oGrpAcao

	Local aCabec   := {}
	Local aButtons := {}
	Local nP12     := 30

	//______________________________________
	//                                      |
	// Campos que representam os filtros    |
	//______________________________________|

	Private oDataDe
	Private dDataDe   := CTOD("")

	Private oDataAte
	Private dDataAte  := CTOD("")

	Private oPrefDe
	Private cPrefDe   := Space(TAMSX3("E1_PREFIXO")[1])

	Private oPrefAte
	Private cPrefAte  := Space(TAMSX3("E1_PREFIXO")[1])

	Private oCliDe
	Private cCliDe    := Space(TAMSX3("A1_COD")[1])

	Private oCliAte
	Private cCliAte   := Space(TAMSX3("A1_COD")[1])

	Private oVenctoDe
	Private dVenctoDe := CTOD("")

	Private oVenctoAte
	Private dVenctoAte := CTOD("")

	Private oMsgTit
	Private aHeader   := {}
	Private aCols 	  := {}
	Private aDplaCols := {}

	Private oOK       := LoadBitmap(GetResources(),'CHECKED')
	Private oNO 	  := LoadBitmap(GetResources(),'UNCHECKED')

	Private oBtnBuscar
	Private oBtnWF

	//================================================
	//Campos da parte infererior da tela
	//================================================
	Private oFilDetl
	Private cFilDetl

	Private oPedDetl
	Private cPedDetl   := Space(TAMSX3("C5_NUM")[1])

	Private oCliDetl
	Private cCliDetl   := Space(TAMSX3("A1_NOME")[1])

	Private oSayTotReg := Nil
	Private nTotReg    := 0

	Private oSayChk    := Nil
	Private nTotChk    := 0
	Private oGetDados  := Nil

	Define FONT oFont NAME "Arial" Size 0,-13 BOLD

	//__________________________________________________|
	//                                                  |
	//Campos que formam o cabeçalho da MsNewGetDados    |
	//__________________________________________________|

	Aadd(aCabec,{"E1_EMISSAO", .F. })
	Aadd(aCabec,{"E1_NUM"	 , .F. })
	Aadd(aCabec,{"E1_CLIENTE", .F. })
	Aadd(aCabec,{"E1_LOJA"	 , .F. })
	Aadd(aCabec,{"E1_NOMCLI" , .F. })
	Aadd(aCabec,{"E1_VENCREA", .F. })
	Aadd(aCabec,{"A1_EMAIL" , .F. })

	oGetDados := TGetDados():New(.T., aCabec, .T., 0,.F.)

	oGetDados:nQuantCores := 1

	//____________________________________________________________________________
	//                                                                            |
	// Determina as codições de exibição da legenda correspondente a cada coluna  |
	//____________________________________________________________________________|

	aHeader  := oGetDados:aDicionario

	DEFINE MSDIALOG oDlgBol TITLE "Reenvio de Boleto" FROM 000,000 TO 520,850 PIXEL  //STYLE FRAME 128

	oGrpFil    	 := TGroup():New( 001 + nP12, 003, 040 + nP12, 388, 'Filtro' 				,  oDlgBol,,, .T.)
	oGrpAcao   	 := TGroup():New( 001 + nP12, 390, 040 + nP12, 425, 'Ação'	 			,  oDlgBol,,, .T.)
	oGrpPick   	 := TGroup():New( 045 + nP12, 003, 200, 425 ,'Títulos'				,  oDlgBol,,, .T.)

	oGrpMarck    := TGroup():New(  205 , 003, 245,143, 'Total de Títulos'	, oDlgBol,,, .T.)
	oGrpChecados := TGroup():New(  205 , 148, 245,288, 'Títulos Selecionados', oDlgBol,,, .T.)
	oGrpAcao     := TGroup():New(  205 ,  293, 245 ,425 ,'Ação'			  	, oDlgBol,,, .T.)

	@ 015 + nP12, 008 SAY "Emissão De"  SIZE  040,009  	OF  oDlgBol PIXEL
	@ 024 + nP12, 008 MSGET oDataDe   	 VAR   dDataDe  	Picture "@!" When .T.  SIZE  50,009  OF oDlgBol PIXEL HASBUTTON

	@ 015 + nP12, 063 SAY "Emissão Até" SIZE  040,009 	OF  oDlgBol PIXEL
	@ 024 + nP12, 063 MSGET oDataAte  	 VAR   dDataAte 			Picture "@!" When .T.  SIZE  050,009  OF oDlgBol PIXEL HASBUTTON

	@ 015 + nP12, 118 SAY "Prefixo De"  SIZE  040,009 	OF  oDlgBol PIXEL
	@ 024 + nP12, 118 MSGET oPrefDe  	 VAR   cPrefDe  Picture "@!" When .T.  SIZE  020,009  OF oDlgBol PIXEL HASBUTTON

	@ 015 + nP12, 148 SAY "Prefixo Até" SIZE  040,009 	OF  oDlgBol PIXEL
	@ 024 + nP12, 148 MSGET oPrefAte  	 VAR   cPrefAte  Picture "@!" When .T.  SIZE  020,009  OF oDlgBol PIXEL HASBUTTON

	@ 015 + nP12, 183 SAY "Cliente De"  SIZE  040,009 	OF  	 oDlgBol PIXEL
	@ 024 + nP12, 183 MSGET oCliDe  	 VAR   cCliDe   F3 "SA1" Picture "@!" When .T.  SIZE  035,009  OF oDlgBol PIXEL HASBUTTON

	oCliDe:bLostFocus := {|| cCliAte := Space(TAMSX3("A1_COD")[1]) }

	@ 015 + nP12, 233 SAY "Cliente Ate" SIZE  040,009 OF  oDlgBol PIXEL
	@ 024 + nP12, 233 MSGET oCliAte  	 VAR   cCliAte  F3 "SA1" Picture "@!" When .T.  SIZE  035,009  OF oDlgBol PIXEL HASBUTTON

	@ 015 + nP12, 283 SAY "Vencimento De"  SIZE  040,009 OF  oDlgBol PIXEL
	@ 024 + nP12, 283 MSGET oVenctoDe      VAR   dVenctoDe  Picture "@!" When .T.  SIZE  045,009  OF oDlgBol PIXEL HASBUTTON

	@ 015 + nP12, 333 SAY "Vencimento Até" SIZE  040,009 OF  oDlgBol PIXEL
	@ 024 + nP12, 333 MSGET oVenctoAte     VAR   dVenctoAte  Picture "@!" When .T.  SIZE  045,009  OF oDlgBol PIXEL HASBUTTON

	@ 024 + nP12,395 Button oBtnBuscar PROMPT 'Buscar'	Size 025,010 Action GetTitulos() Of oDlgBol Pixel

	oSayTotReg := TSay():Create(oGrpMarck,{|| nTotReg },225,070,,oFont,,,,.T.,CLR_RED,CLR_HRED,150,20)

	oSayChk := TSay():Create(oGrpChecados,{|| nTotChk },225,218,,oFont,,,,.T.,CLR_RED,CLR_RED,150,20)

	oMsgTit := MSNewGetDados():New(055 + nP12, 009, 195, 420, 0,'AlwaysTrue()','AlwaysTrue()','',{},,9999,,,,oDlgBol ,aHeader,aCols,{||})

	//_____________________________________________________________________________________
	//                                                                                     |
	// Ação relacionada no momento do Clique soble uma determinada linha da MsNewGetDados  |
	//_____________________________________________________________________________________|
	oMsgTit:oBrowse:bLDblClick   := {|| FlagTitulo() }

	oMsgTit:oBrowse:bHeaderClick := {|| FlagRegs()   }

	oGetDados:GetDadosVazio(oMsgTit)

	//_____________________________________________________________________________________
	//                                                                                     |
	// Aciona o envio de Workflow para os clientes                                         |
	//_____________________________________________________________________________________|

	@ 217 ,341 BUTTON  oBtnWF PROMPT "Enviar" SIZE 040,20  ACTION  AgendaWF()  OF oGrpAcao PIXEL
	oBtnWF:Disable()

	oDlgBol:lMaximized := .F.

	//__________________________________________________________________________________________
	//                                                                                     		|
	// O menu apenas estará disponível caso a quantidade de registro seja maior ou igual a zero |                                         										   |
	//__________________________________________________________________________________________|

	//Aadd( aButtons, {"HISTORIC", {|| Exportar()} ,"","Exportar"		  	  , {|| .T.}} )
	Aadd( aButtons, {"HISTORIC", {|| ImpBol(1) } ,"","Imprimir Boleto"	  , {|| .T.}} )

	Aadd( aButtons, {"HISTORIC", {|| ImpBol(3) } ,"","Impressão NF-DEB" , {|| .T.}} )

	If  Alltrim(__cUserID) == "000000"

		Aadd( aButtons, {"HISTORIC", {|| ImpBol(2) } ,"","Impressão de DANFE" , {|| .T.}} )
	Endif

	Aadd( aButtons, {"HISTORIC", {|| EnvDeb(.F.) } ,"","Enviar NF DEB" , {|| .T.}} )
	Aadd( aButtons, {"HISTORIC", {|| EnvDeb(.T.) } ,"","Enviar NF DEB/Boleto" , {|| .T.}} )

	ACTIVATE MSDIALOG oDlgBol ON INIT ( EnchoiceBar(oDlgBol, {|| oDlgBol:End() }, {|| oDlgBol:End()},,@aButtons))

Return(Nil)
/*
*/
Static Function EnvDeb(lBoleto)
	Local x, y
	Local aArea    := GetArea()
	Local aAreaSF2 := SF2->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())
	Local aRecSE1  := {}

	For x := 1 To Len(oGetDados:objMain:aCols)
		If oGetDados:objMain:aCols[x, 10]
			aAdd(aRecSE1, oGetDados:objMain:aCols[x, 9])
		EndIf
	Next x

	If Len(aRecSE1) > 0
		//SF29901	nonclustered located on PRIMARY	F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_

		DbSelectArea("SF2")
		DbSetOrder(1)

		For y := 1 To Len(aRecSE1)
			SE1->( DbGoTo( aRecSE1[y] ) )

			If SF2->( DbSeek( xFilial("SF2") + SE1->( E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA )  ) )
				RecLock("SF2", .F.)
				SF2->F2_YSCHDEB := "S"
				SF2->F2_YDEBENV := "N"

				If lBoleto
					SF2->F2_YSCHBOL := "S"
					SF2->F2_YBOLENV := "N"
				EndIf
				SF2->(MsUnlock())
			EndIf
		Next y

		RestArea(aAreaSE1)
		RestArea(aAreaSF2)
		RestArea(aArea)

		Aviso("Enviar NF DEB", "Nota(s) DEB agendadas com sucesso!", {"Ok"}, 1)
	EndIf
Return (.T.)

//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : GetTitulos                                               							|
//                                                                                                  |
// Data      : 08/09/16                                                                     		|
//__________________________________________________________________________________________________|
//                                                                                                 	|
// Descrição : Resgata os Título conforme os filtros determinados pelo usuário						|
//__________________________________________________________________________________________________|

Static Function GetTitulos()
	Local cQuery := ""
	Local cWhere := ""
	Local cQuebra := Chr(13) + Chr(10)

	cQuery := "SELECT E1_EMISSAO, E1_NUM, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VENCREA, A1_EMAIL, SE1.R_E_C_N_O_ SE1REC " + cQuebra
	cQuery += "  FROM " + RetSqlName("SE1") +" SE1 (NOLOCK) " + cQuebra
	cQuery += "  JOIN " + RetSqlName("SA1") +" SA1 (NOLOCK) ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + cQuebra
	cQuery += "                          AND SA1.A1_COD = SE1.E1_CLIENTE " + cQuebra
	cQuery += "				          AND SA1.A1_LOJA = SE1.E1_LOJA " + cQuebra
	cQuery += "				          AND SA1.D_E_L_E_T_ != '*' " + cQuebra
	cQuery += "  JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL = SE1.E1_FILIAL " + cQuebra
	cQuery += "                          AND SF2.F2_CLIENTE = SE1.E1_CLIENTE " + cQuebra
	cQuery += "						  AND SF2.F2_LOJA = SE1.E1_LOJA " + cQuebra
	cQuery += "						  AND SF2.F2_DOC = SE1.E1_NUM " + cQuebra
	cQuery += "						  AND SF2.F2_SERIE = SE1.E1_SERIE " + cQuebra
	cQuery += "						  AND SF2.F2_PREFIXO = SE1.E1_PREFIXO " + cQuebra
	cQuery += "						  AND SF2.D_E_L_E_T_ != '*' " + cQuebra
	cQuery += " WHERE SE1.E1_FILIAL = '" +xFilial("SE1") + "' " + cQuebra

	//____________________________________________________________________________________________________________

	If !Empty(DTOS(dDataAte))
		oGetDados:cWhere += "   AND E1_EMISSAO BETWEEN  '"+ DTOS(dDataDe) +"' AND '" + DTOS(dDataAte) + "' " + cQuebra
	Endif

	//____________________________________________________________________________________________________________

	If !Empty(cPrefAte)
		oGetDados:cWhere += "   AND E1_PREFIXO BETWEEN  '"+ cPrefDe +"' AND '" + cPrefAte + "' " + cQuebra
	Endif

	//____________________________________________________________________________________________________________
	If !Empty(cCliAte)
		oGetDados:cWhere += "   AND E1_CLIENTE BETWEEN  '"+ cCliDe +"' AND '" + cCliAte + "' " + cQuebra
	Endif

	//____________________________________________________________________________________________________________
	If !Empty(DTOS(dVenctoAte))
		oGetDados:cWhere += "   AND E1_VENCREA BETWEEN  '"+ DTOS(dVenctoDe) +"' AND '" + DTOS(dVenctoAte) + "' " + cQuebra
	Endif

	oGetDados:cWhere += "   AND SE1.D_E_L_E_T_ != '*'" + cQuebra


	//____________________________________________________________________________________________________________
	//
	// Define a figura a ser utilizada na coluna lateral do aCols
	//____________________________________________________________________________________________________________
	oGetDados:cBitmap := LoadBitmap(GetResources(),'UNCHECKED')

	oGetDados:cChamadaOrigem := "TECFAT02"

	Processa({|| oGetDados:GerenciaConsultaSQL(oMsgTit, cQuery) }, "Busca", "Selecionando os dados. Aguarde...")

	nTotReg  	  	:= iif( !Empty(oMsgTit:aCols[1][GDFieldPos('E1_NUM')]), Len(oMsgTit:aCols) , 0)
	nTotChk  	  	:= 0

	oSayChk:CtrlRefresh()
Return Nil


//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : FlagTitulo                                               							|
//                                                                                                  |
// Data      : 08/09/16                                                                     		|
//__________________________________________________________________________________________________|
//                                                                                                 	|
// Descrição : Marca, individualmente, os Títulos disponíveis										|
//__________________________________________________________________________________________________|

Static Function FlagTitulo()

	Local nLinha    := oMsgTit:oBrowse:nAt
	Local nPosFlag  := Len(oMsgTit:aHeader) + 1
	Local nPosMck   := aScan(oMsgTit:aHeader,{|x| Alltrim(x[2])=="OK"})
	Local nPosTit	:= aScan(oMsgTit:aHeader,{|x| Alltrim(x[2])=="E1_NUM"})
	Local lMarc	    := .F.
	Local aArea		:= GetArea()

	//_________________________________________________________________________
	//                                                                         |
	// A marcação apenas é realizada quando a coluna posicionada é a primeira. |
	//_________________________________________________________________________|

	If !Empty(oMsgTit:aCols[1][nPosTit])

		If oMsgTit:oBrowse:nColPos == nPosMck

			oMsgTit:aCols[nLinha][nPosFlag] :=  !oMsgTit:aCols[nLinha][nPosFlag]
			lMarc 							 :=  oMsgTit:aCols[nLinha][nPosFlag]
			oMsgTit:aCols[nLinha][nPosMck]  :=  Iif( lMarc, LoadBitmap(GetResources(),'CHECKED'),LoadBitmap(GetResources(),'UNCHECKED'))
			oMsgTit:oBrowse:Refresh()
		Endif


	Else
		Aviso("Operação inválida","Impossível realizar esta operação" ,{"OK"},1)
	Endif

	nTotChk         := 0

	aEval(oMsgTit:aCols, {|x| iif( x[nPosFlag], nTotChk++, ) } )

	oMsgTit:oBrowse:Refresh()

	oBtnWF:lActive  := nTotChk > 0

	oSayChk:CtrlRefresh()

	RestArea(aArea)
Return

//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : FlagRegs                                               								|
//                                                                                                  |
// Data      : 08/09/16                                                                     		|
//__________________________________________________________________________________________________|
//                                                                                                 	|
// Descrição : Marca/Desmarca todos os Títulos disponíveis											|
//__________________________________________________________________________________________________|

Static Function FlagRegs()

	Local nPosFlag := Len(oMsgTit:aHeader) + 1
	Local nPosMck  := aScan(oMsgTit:aHeader,{|x| Alltrim(x[2])=="OK"})

	Local lAchou   := .F.
	Local bVal     := {||}
	Local bBitmap  := {||}

	Local nLinha   := oMsgTit:oBrowse:nAt
	Local nX	   := 0
	Local nQuant   := 0

	Local aArea	   := GetArea()

	//_________________________________________________________
	//                                                         |
	// Verifica se exite algum registro selecionado.           |
	//_________________________________________________________|

	lAchou :=  aScan(oMsgTit:aCols,{|x| x[nPosFlag] }) > 0

	bVal    := {|x| x[nPosFlag] := !lAchou }
	bBitmap := {|x| x[nPosMck] := iif( x[nPosFlag], LoadBitmap(GetResources(),'CHECKED'), LoadBitmap(GetResources(),'UNCHECKED')) }

	//_________________________________________________________________________________
	//                                                                                 |
	// Atribui o valor a coluna de marcação de acordo com o resultado de busca         |
	//                                                                                 |
	//_________________________________________________________________________________|

	If oMsgTit:oBrowse:nColPos == nPosMck

		If !Empty(oMsgTit:aCols[1][GDFieldPos('E1_NUM')])

			aEval(oMsgTit:aCols, bVal)
			aEval(oMsgTit:aCols, bBitmap)
		Else
			Aviso("Atenção","Operação inválida",{"OK"},1)
		Endif
	Else

		oGetDados:objMain 			:= oMsgTit
		oGetDados:nIndiceOrdenacao := oMsgTit:oBrowse:nColPos

		oGetDados:OrdenaDados()

		oMsgTit 					:= oGetDados:objMain

	Endif

	nTotChk  := 0

	aEval(oMsgTit:aCols, {|x| iif( x[nPosFlag], nTotChk++, ) } )

	RestArea(aArea)

	oBtnWF:lActive  := nTotChk > 0

	oMsgTit:oBrowse:Refresh()
	oSayChk:CtrlRefresh()

Return (nQuant)

//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : AgendaWF                                               								|
//                                                                                                  |
// Data      : 08/09/16                                                                     		|
//__________________________________________________________________________________________________|
//                                                                                                 	|
// Descrição : Agenda o envio de boletos, via Workflow, para os clientes vinculados aos Títulos     |
//__________________________________________________________________________________________________|

Static Function AgendaWF()

	Local nK   := 0
	Local oSay := Nil

	If Aviso("Confirmar","Desejar confirmar o Agendamento de Envio de Boleto para o(s) cliente(s) selecionado(s) ?",{"SIM","NÃO"},2) == 1

		SF2->(dbSetOrder(2))

		For nK := 1 To Len(oMsgTit:aCols)

			If oMsgTit:aCols[nK][Len(oMsgTit:aHeader)+1]

				//__________________________________________________________________________________________
				//                                                                                          |
				// Verifica a consistência do Título gerado                                                 |
				//__________________________________________________________________________________________|

				If  SF2->(dbSeek( xFilial("SF2") + Alltrim(oMsgTit:aCols[nK][GDFieldPos('E1_CLIENTE')]) +;
				Alltrim(oMsgTit:aCols[nK][GDFieldPos('E1_LOJA')])    +;
				Alltrim(oMsgTit:aCols[nK][GDFieldPos('E1_NUM')]) ))

					FWMsgRun(, {|oSay|  },,"Aguarde...Agendando Workflow para o cliente: '"+ oMsgTit:aCols[nK][GDFieldPos('E1_NOMCLI')]+"'")

					oMsgTit:aCols[nK][Len(oMsgTit:aHeader)+1]   := .F.
					oMsgTit:aCols[nK][GDFieldPos('OK')] 		 := LoadBitmap(GetResources(),'UNCHECKED')

					//__________________________________________________________________________________________
					//                                                                                          |
					// Inicia uma nova transação no Banco de Dados                                              |
					//__________________________________________________________________________________________|
					Begin Transaction

						SF2->(RecLock("SF2", .F.))

						SF2->F2_YSCHBOL := "S"
						SF2->F2_YBOLENV := "N"

						SF2->(MSUnLock())

					End Transaction
				Endif
			Endif
		Next nK

		oMsgTit:oBrowse:Refresh()

		nTotChk  		 := 0
		oBtnWF:lActive  := nTotChk > 0

		oSayChk:CtrlRefresh()
	Endif
Return


//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : AgendaWF                                               								|
//                                                                                                  |
// Data      : 09/09/16                                                                     		|
//__________________________________________________________________________________________________|
//                                                                                                 	|
// Descrição : Permite exportar os dados para a planilha excel     									|
//__________________________________________________________________________________________________|
Static Function Exportar()

	If Empty(oMsgTit:aCols[1][GDFieldPos('E1_NUM')])

		Aviso("Operação inválida","Não há dados a serem exportados" ,{"OK"},1)
	Else

		oGetDados:cPlanilha    := "TÍTULOS"
		oGetDados:cTitPlanilha := "TÍTULOS A RECEBER"

		oGetDados:Exportar()

	Endif
Return


Static Function ImpBol(nOpcao)

	Local cIdcliente        := ""
	Local cDir				:= ""

	Local nQuant    		:= 0
	Local nVlrTot			:= 0
	Local nW	    		:= 0
//	Local nFlags    		:= 0
	Local nK	    		:= 0

	Local lAdjustToLegacy 	:= .F.
	Local nFlags 			:= PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN

	Local aTitulos  		:= {}
	Local aFin      		:= {}
	Local aArea	    		:= GetArea()

	Local oDanfe  			:= Nil
	Local oSetup  			:= Nil
	Local oFormDEB			:= Nil

	Local aPergs   := {}
	Local aRet     := {}
	Local x


	If (nOpcao == 1) .And. Empty(oMsgTit:aCols[1][GDFieldPos('E1_NUM')])

		Aviso("Operação inválida","Operação inválida" ,{"OK"},1)


		//____________________________________________________________________________________________
		//                                                                                            |
		// Considera as regras a serem utilizadas na impressão do formulário                          |
		//____________________________________________________________________________________________|

	Elseif (nOpcao == 3)

		cDir := cGetFile( "*.*", "Salvar em ", 1,, .F., nOR( GETF_LOCALHARD,GETF_RETDIRECTORY ), .F. )
//			    cGetFile( "Arquivo NFe (*.xml) | *.xml","Selecione o Arquivo de Nota Fiscal XML",,::cDrive + ::cDir,.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.F.)


		If !Empty(cDir)

			//________________________________________________________________________________________________
			//
			//
			//________________________________________________________________________________________________

			aAdd(aPergs,{1,"Data De"  , dDataBase ,"", "", "", "", 50,.F.})
			aAdd(aPergs,{1,"Data Até" , dDataBase ,"", "", "", "", 50,.F.})

			aAdd(aPergs,{1,"Cliente De"  , Space(TamSX3("A1_COD")[1]) ,"", "", "SA1", "", 0,.F.})
			aAdd(aPergs,{1,"Cliente Até" , Space(TamSX3("A1_COD")[1]) ,"", "", "SA1", "", 0,.F.})

			aAdd(aPergs,{1,"NF De" 	  	 , Space(TamSX3("F2_DOC")[1]) ,"", "", "NFDEB", "", 0,.F.})
			aAdd(aPergs,{1,"NF Até"	  	 , Space(TamSX3("F2_DOC")[1]) ,"", "", "NFDEB", "", 0,.F.})

			//If ParamBox(aPergs ,"",aRet)    //COMENTAR ESSA PORRA

			oFormDEB :=  TWFormularioDEB():New()

			/*
			oFormDEB:dDataDe  	 := DTOS(MV_PAR01)
			oFormDEB:dDataAte 	 := DTOS(MV_PAR02)
			oFormDEB:cClieteDe   := MV_PAR03
			oFormDEB:cClienteAte := MV_PAR04
			oFormDEB:cNFDe    	 := MV_PAR05
			oFormDEB:cNFAte   	 := MV_PAR06


			oFormDEB:ObtemDadosNF()
			*/

			//______________________________________________________________________
			//                                                                      |
			// Define a nomeclatura do arquivo a ser  geerado                       |
			//______________________________________________________________________|

			For x := 1 To Len(oGetDados:objMain:aCols)
				If oGetDados:objMain:aCols[x, 10]
					aAdd(oFormDEB:aRecSE1, oGetDados:objMain:aCols[x, 9])
				EndIf
			Next x

			If !Empty(oFormDEB:aRecSE1)
				oFormDEB:PopDest()
			EndIf

			If !Empty(oFormDEB:aDestinatario)
				//oFormDEB:PopDest()

				oFormDEB:oPrint := FWMSPrinter():New ( "FORMULARIO" + oFormDEB:aDestinatario[1][2],	IMP_PDF,.F.,,.T.,,,,.T.,,,)

				oFormDEB:oPrint:SetPortrait()   												// ou SetLandscape()
				oFormDEB:oPrint:SetDevice(IMP_PDF)

				oFormDEB:oPrint:cPathPDF := cDir
			Else

				Aviso("Operação inválida","Não há histórico de infromações para os Documentos informados" ,{"OK"},1)

				Return

			End If

			Processa({||  }, "Impressão", "Gerando Formulário...")


			For nW := 1 To Len(oFormDEB:aDestinatario)

				IncProc()

				oFormDEB:nAnt		 := nW
				cIdcliente 		 := Posicione("SA1",1, xFilial("SA1") + oFormDEB:aDestinatario[nW][1] , "A1_EST")
				oFormDEB:cDocumento := oFormDEB:aDestinatario[nW][2]

				aEval(oFormDEB:aDestinatario[nW][3],{|x| nVlrTot := nVlrTot + x[5] })

				oFormDEB:nValorTotal := nVlrTot
				nVlrTot 			  := 0

				oFormDEB:ConfigLayoutCabecalho()

				oFormDEB:ImprimeItens()

				If oFormDEB:lLimitePorPagina
					oFormDEB:ImprimeProdutosPendentes()
					oFormDEB:lLimitePorPagina := .F.
				End If

			Next nW
			oFormDEB:AcionaImpressao()
			//End If
		End If


	Else
		aEval(oMsgTit:aCols,{|x| if(x[Len(oMsgTit:aHeader)+1], nQuant++, )})

		If nQuant > 0

			If nOpcao == 1
				//________________________________________________________________________
				//                                                                        |
				// Aciona a janela de Pergunta com informações bancárias a serem gravadas |
				//________________________________________________________________________|

				aFin := U_TECFAT03()

				If !Empty(aFin)

					If  Aviso("Confirmar","Deseja confirmar a impressão para o(s) Título(s) selecionado(s) ?",{"SIM","NÃO"},2) == 1

						For nK := 1 To Len( oMsgTit:aCols)

							If oMsgTit:aCols[nK][Len(oMsgTit:aHeader)+1]

								aAdd(aTitulos,{ 											 					  ;
								oMsgTit:aCols[nK][GDFieldPos('E1_NUM')]					     ,;
								oMsgTit:aCols[nK][aScan(oMsgTit:aHeader,{|x| x[2]=="SE1REC"})] ;
								})
							Endif
							//__________________________________________________________________
							//                                                                  |
							// Remove a Flag de marcação do(s) Título(s) selecionado(s)         |
							//__________________________________________________________________|
							oMsgTit:aCols[nK][Len(oMsgTit:aHeader)+1] := .F.

						Next nK

						//__________________________________________________________________
						//                                                                  |
						// Inclui os dados Bancários                                        |
						//__________________________________________________________________|
						aAdd(aTitulos,{ aFin[1][1], aFin[1][2], aFin[1][3] })


						oMsgTit:oBrowse:Refresh()


						U_TECRE001(aTitulos)

						RestArea(aArea)
					Endif
				Else
					Aviso("Atenção","É obrigatória a seleção do Banco a fim de prosseguir com a operação.",{"OK"},1)
				Endif
				/*
				Else


				//oFormDEB:Preview()

				//________________________________________________________________________
				//                                                                        |
				// Gerencia o processo de criação da DANFE dentro                         |
				//________________________________________________________________________|
				/*
				oSetup := FWPrintSetup():New(nFlags, "DANFE")

				cFilePrint := "DANFE_000001" +Dtos(MSDate())+StrTran(Time(),":","")

				// ----------------------------------------------
				// Define saida
				// ----------------------------------------------
				oSetup:SetPropert(PD_PRINTTYPE   , 6	 		 )
				oSetup:SetPropert(PD_ORIENTATION , 1	 		 )
				oSetup:SetPropert(PD_DESTINATION , 1	 		 )
				oSetup:SetPropert(PD_MARGIN      , {60,60,60,60} )
				oSetup:SetPropert(PD_PAPERSIZE   , 2			 )

				oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy,  , .F.)

				oSetup:AOPTIONS[6] := oDanfe:cPathPDF

				oDanfe:setDevice(IMP_PDF)

				U_PrtNfeSef("000001",,,oDanfe, oSetup, cFilePrint,.T. )
				//PrtNfeSef(cIdEnt	 ,cVal1,cVal2,oDanfe,oSetup,cFilePrint,,)

				oDanfe := Nil
				oSetup := Nil
				*/
			Endif

		Else
			Aviso("Atenção","Selecione, no mínimo um Título, para realizar a impressão ",{"OK"},1)
		Endif
	Endif


Return