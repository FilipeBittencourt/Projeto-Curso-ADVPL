#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOBJECT.CH"
#include "TOTVS.CH"
//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : TECFAT04                                               								|                        
//                                                                                                  | 
// Data      : 08/09/16                                                                     		| 
//                                                                                                  | 
// Autor	 : Jessé Augusto                                                                        |
//__________________________________________________________________________________________________| 
//                                                                                                 	| 
// Descrição : Gerencia o processo de geração de boletos aos clientes								| 
//__________________________________________________________________________________________________|    


User Function TECFAT04()

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


  //__________________________________________________
  //                                                  |
  // Restringe o acesso apenas à  OXITRYO             |
  //__________________________________________________|

//  	If FWFilName(cEmpAnt,cFilAnt) $ "TECNOCRYO"
//		
//		 Aviso("Atenção","Rotina desabilitada para a Filial  "+ Alltrim(FWFilName(cEmpAnt,cFilAnt))+"" ,{"OK"},1) 
//		
//		 Return
//	Endif 

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

  oGetDados := TGetDados():New(.T., aCabec, .T., 1, .F.)

  oGetDados:nQuantCores := 1

  //____________________________________________________________________________
  //                                                                            |
  // Determina as codições de exibição da legenda correspondente a cada coluna  |
  //____________________________________________________________________________|

  aHeader  := oGetDados:aDicionario

  DEFINE MSDIALOG oDlgBol TITLE "Gerarção de Boleto" FROM 000,000 TO 520,850 PIXEL  //STYLE FRAME 128

  oGrpFil    	 := TGroup():New( 001, 003, 040, 388, 'Filtro' 				,  oDlgBol,,, .T.)
  oGrpAcao   	 := TGroup():New( 001, 390, 040, 425, 'Ação'	 			,  oDlgBol,,, .T.)
  oGrpPick   	 := TGroup():New( 045, 003, 200, 425 ,'Títulos'				,  oDlgBol,,, .T.)

  oGrpMarck    := TGroup():New(  205, 003, 245,143, 'Total de Títulos'	, oDlgBol,,, .T.)
  oGrpChecados := TGroup():New(  205, 148, 245,288, 'Títulos Selecionados', oDlgBol,,, .T.)
  oGrpAcao     := TGroup():New(  205,  293, 245,425 ,'Ação'			  	, oDlgBol,,, .T.)

  @ 015, 008 SAY "Emissão De"  SIZE  040,009  	OF  oDlgBol PIXEL
  @ 024, 008 MSGET oDataDe   	 VAR   dDataDe  	Picture "@!" When .T.  SIZE  50,009  OF oDlgBol PIXEL HASBUTTON

  @ 015, 063 SAY "Emissão Até" SIZE  040,009 	OF  oDlgBol PIXEL
  @ 024, 063 MSGET oDataAte  	 VAR   dDataAte 			Picture "@!" When .T.  SIZE  050,009  OF oDlgBol PIXEL HASBUTTON

  @ 015, 118 SAY "Prefixo De"  SIZE  040,009 	OF  oDlgBol PIXEL
  @ 024, 118 MSGET oPrefDe  	 VAR   cPrefDe  Picture "@!" When .T.  SIZE  020,009  OF oDlgBol PIXEL HASBUTTON

  @ 015, 148 SAY "Prefixo Até" SIZE  040,009 	OF  oDlgBol PIXEL
  @ 024, 148 MSGET oPrefAte  	 VAR   cPrefAte  Picture "@!" When .T.  SIZE  020,009  OF oDlgBol PIXEL HASBUTTON

  @ 015, 183 SAY "Cliente De"  SIZE  040,009 	OF  	 oDlgBol PIXEL
  @ 024, 183 MSGET oCliDe  	 VAR   cCliDe   F3 "SA1" Picture "@!" When .T.  SIZE  035,009  OF oDlgBol PIXEL HASBUTTON

  oCliDe:bLostFocus := {|| cCliAte := Space(TAMSX3("A1_COD")[1]) }

  @ 015, 233 SAY "Cliente Ate" SIZE  040,009 OF  oDlgBol PIXEL
  @ 024, 233 MSGET oCliAte  	 VAR   cCliAte  F3 "SA1" Picture "@!" When .T.  SIZE  035,009  OF oDlgBol PIXEL HASBUTTON

  @ 015, 283 SAY "Vencimento De"  SIZE  040,009 OF  oDlgBol PIXEL
  @ 024, 283 MSGET oVenctoDe      VAR   dVenctoDe  Picture "@!" When .T.  SIZE  045,009  OF oDlgBol PIXEL HASBUTTON

  @ 015, 333 SAY "Vencimento Até" SIZE  040,009 OF  oDlgBol PIXEL
  @ 024, 333 MSGET oVenctoAte     VAR   dVenctoAte  Picture "@!" When .T.  SIZE  045,009  OF oDlgBol PIXEL HASBUTTON

  @ 024,395 Button oBtnBuscar PROMPT 'Buscar'	Size 025,010 Action GetTitulos() Of oDlgBol Pixel

  oSayTotReg := TSay():Create(oGrpMarck,{|| nTotReg },225,070,,oFont,,,,.T.,CLR_RED,CLR_HRED,150,20)

  oSayChk := TSay():Create(oGrpChecados,{|| nTotChk },225,218,,oFont,,,,.T.,CLR_RED,CLR_RED,150,20)

  oMsgTit := MSNewGetDados():New(055, 009, 195, 420, 0,'AlwaysTrue()','AlwaysTrue()','',{},,9999,,,,oDlgBol ,aHeader,aCols,{||})

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

  @ 217,341 BUTTON  oBtnWF PROMPT "Gerar Boleto" SIZE 040,20  ACTION  GerarBol()  OF oGrpAcao PIXEL
  oBtnWF:Disable()

  oDlgBol:lMaximized := .F.


  ACTIVATE MSDIALOG oDlgBol

Return(Nil)

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

  Local cQuery  := ""
  Local cWhere  := ""

  cQuery :=" SELECT 		  							    "
  cQuery +=" E1_EMISSAO								 ,  "
  cQuery +=" E1_NUM									 ,  "
  cQuery +=" E1_CLIENTE								 ,  "
  cQuery +=" E1_LOJA								 	 ,  "
  cQuery +=" E1_NOMCLI								 ,  "
  cQuery +=" E1_VENCREA	  							 ,	"
  cQuery +=" SE1.R_E_C_N_O_ SE1REC	  					"
  cQuery +=" FROM " + RetSqlName("SE1") +" AS SE1 		"
  cQuery +=" WHERE SE1.D_E_L_E_T_ = ' ' 					"
  cQuery +=" AND   SE1.E1_FILIAL  ='" + xFilial("SE1")+ "' "

  //____________________________________________________________________________________________________________

  If !Empty(DTOS(dDataAte))
    cQuery += " AND E1_EMISSAO BETWEEN  '"+ DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
  Endif

  //____________________________________________________________________________________________________________

  If !Empty(cPrefAte)
    cQuery += " AND E1_PREFIXO BETWEEN  '"+ cPrefDe +"' AND '" + cPrefAte + "' "
  Endif

  //____________________________________________________________________________________________________________
  If !Empty(cCliAte)
    cQuery += " AND E1_CLIENTE BETWEEN  '"+ cCliDe +"' AND '" + cCliAte + "' "
  Endif

  //____________________________________________________________________________________________________________
  If !Empty(DTOS(dVenctoAte))
    cQuery += " AND E1_VENCREA BETWEEN  '"+ DTOS(dVenctoDe) +"' AND '" + DTOS(dVenctoAte) + "' "
  Endif

  cQuery += " AND E1_SALDO > 0  "

  //____________________________________________________________________________________________________________
  //
  // Define a figura a ser utilizada na coluna lateral do aCols
  //____________________________________________________________________________________________________________
  oGetDados:cBitmap := LoadBitmap(GetResources(),'UNCHECKED')

  oGetDados:GerenciaConsultaSQL( oMsgTit, cQuery)

  nTotReg  	  	:= iif( !Empty(oMsgTit:aCols[1][GDFieldPos('E1_NUM')]), Len(oMsgTit:aCols) , 0)
  nTotChk  	  	:= 0

  oBtnWF:lActive	:= .F.

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

Static Function GerarBol()

  Local oBol 	  := Nil
  Local oSay 	  := Nil
  Local cTitulo := "Selecione o diretório onde desejar salvar"

  Local cDir	:= ""

  Local nK   	:= 0

  Local aArea	:= {}

  cDir := cGetFile( "*.*", cTitulo, 1,, /*.F.*/.T., nOR( GETF_LOCALHARD,GETF_RETDIRECTORY ), .F., .T. )

  If !Empty(cDir)

    //________________________________________________________________________________________________
    //                                                                                                |
    // Percorre toda a String a fim de verificar se a mesma possui um caractér específico             |
    //________________________________________________________________________________________________|

    For nK := 1 To Len(cDir)

      nPesq := iif( SubStr(cDir,nK,1) == "\", nK  , 0)
    Next nK

    //________________________________________________________________________________________________
    //                                                                                                |
    // Verifica se o nome do arquivo foi digitado                                                     |
    //________________________________________________________________________________________________|
    If Len(cDir) == nPesq

      If Aviso("Confirmar","Desejar confirmar a geração do(s) Boleto(s) para o(s) cliente(s) selecionado(s) ?",{"SIM","NÃO"},2) == 1

        SF2->(dbSetOrder(2))

        For nK := 1 To Len(oMsgTit:aCols)


          //__________________________________________________________________________________________
          //                                                                                          |
          // A operação apenas será efetivada caso haja, ao menos um, registro selecionado			  |
          //__________________________________________________________________________________________|

          If oMsgTit:aCols[nK][Len(oMsgTit:aHeader)+1]

            //__________________________________________________________________________________________
            //                                                                                          |
            // Verifica a consistência do Título gerado                                                 |
            //__________________________________________________________________________________________|

            SE1->(dbGoto(oMsgTit:aCols[nK][Len(oMsgTit:aHeader)]) )

            FWMsgRun(, {|oSay|  },,"Aguarde...Gerando Boleto para o cliente: '"+ oMsgTit:aCols[nK][GDFieldPos('E1_NOMCLI')]+"'")

            aArea := GetArea()

            oBol := TWBolSantan():New()

            //___________________________________________________________________________________
            //                                                                                   |
            //                                                                                   |
            //___________________________________________________________________________________|

            If oBol:CartValida()

              oBol:Preparar()
              oBol:Montar()
              //oBol:VerPDF()
              //oBol:SalvarPDF()
              oBol:oPrint:cPathPDF := SubStr(cDir,1,Len(cDir))  // Obtém o caminho no qual o arquivo será gravado
              oBol:oPrint:SetPortrait()     					  // ou SetLandscape()
              oBol:oPrint:SetViewPDF(.F.)   					  // Determina se o arquivo será aberto ao final do processo
              oBol:oPrint:Print()           					  // Imprime

            EndIf

            FreeObj(oBol)
            RestArea(aArea)

          Endif

          oMsgTit:aCols[nK][Len(oMsgTit:aHeader)+1] := .F.
          oMsgTit:aCols[nK][GDFieldPos('OK')] 		:= LoadBitmap(GetResources(),'UNCHECKED')

        Next nK
      Endif
    Else

      Aviso("Confirmar","Selecione o local onde deseja gerar o(s) Boleto(s)",{"SIM","NÃO"},2)
    Endif admin
  Endif

  oMsgTit:oBrowse:Refresh()
  oMsgTit:oBrowse:SetFocus()

  nTotChk  		:= 0
  oBtnWF:lActive  := nTotChk > 0

  oSayChk:CtrlRefresh()

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


Static Function ImpBol()

  Local nQuant    := 0
  Local nK	    := 0
  Local aTitulos  := {}
  Local aFin      := {}

  Local aArea	    := GetArea()

  If Empty(oMsgTit:aCols[1][GDFieldPos('E1_NUM')])

    Aviso("Operação inválida","Não há dados a serem exportados" ,{"OK"},1)
  Else
    aEval(oMsgTit:aCols,{|x| if(x[Len(oMsgTit:aHeader)+1], nQuant++, )})

    If nQuant > 0


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
    Else
      Aviso("Atenção","Selecione, no mínimo um Título, para realizar a impressão ",{"OK"},1)
    Endif


  Endif

Return
