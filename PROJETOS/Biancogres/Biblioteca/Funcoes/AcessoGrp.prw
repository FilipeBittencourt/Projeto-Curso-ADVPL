#include 'Protheus.ch'
#Include 'TOTVS.ch'

#define ENTER chr(13)+chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACESSOGROUPºAutor  ³Kanaãm L. R. R.     º Data ³  11/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o acesso dos Grupos do sistema.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º11/06/12  ³Kanaãm LRR³ Desenvolvimento da Rotina                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º26/02/13  ³Kanaãm LRR³ adição de tela de filtro                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*------------------------*
USER Function AcessoGROUP()
   *------------------------*
   Local   oDlg,;
      oReport,;
      bOk        := {|| oDlg:End()},;
      bCancel    := {|| oDlg:End()},;
      aTb_Campos := {},;
      aButtons   := {{"MDISPOOL",;
      {|| Processa({|| oReport := ReportDef(),oReport:PrintDialog()},'Imprimindo Dados...')},;
      "Imprimir",;
      "Imprimir"}}

   Private oTableUser   := Nil
   Private oTableModule := Nil
   Private oTableAccess := Nil

   CriaWork()

   Private aGroups     := {},;
      aUsers     := {},;
      aModulos   := {},;
      oMarkGROUP,;
      oMarkUSER,;
      oMarkModulo,;
      oMarkAcesso,;
      cMarca     := GetMark(),;
      lInverte   := .F.
   lPrintUsr	:= .F.

   Private lMarca    := .T.,;
      lRetrato  := .T.,;
      cModDe    := Space(2),;
      cModAte   := "99",;
      cGrpDe   := Space(6),;
      cGrpAte  := "999999",;
      cRotDe    := Space(12),;
      cRotAte   := "ZZZZZZZZZZZZ",;
      aColPrint := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}   // variáveis de filtro


// botão para consultar usuarios
   Aadd(aButtons,{"BPM_ICO_USUARIOS",;
      {|| Processa({|| ExpUser()},'Exportando Usuarios...')},;
      "Exp. Usuarios",;
      "Exp. Usuarios"})

   If !Filtro()
      Return
   Else
      cModDe    := StrZero(Val(cModDe),2)
      cModAte   := StrZero(Val(cModAte),2)
      cGrpDe   := StrZero(Val(cGrpDe),6)
      cGrpAte  := StrZero(Val(cGrpAte),6)
   EndIf

   Processa({|| aGroups := AllGroups(),;
      aModulos := retModName(),;
      aAdd(aModulos,{99,"SIGACFG","Configurador",.T.,"CFGIMG",99}),;
      PreencheWk()},;
      'Preparando Ambiente...')

   WKGROUPS->(dbGoTop())
   WKMODULOS->(dbGoTop())
   WKACESSO->(dbGoTop())
   WKUSERS->(dbGoTop())

   oMainWnd:ReadClientCoords()
   Define MsDialog oDlg Title "Acesso de Grupos" From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 Of oMainWnd Pixel

   aPos := {oMainWnd:nTop+12,oMainWnd:nLeft,290,110}
   aTb_Campos      := CriaTbCpos("GROUPS")
   oMarkGROUP       := MsSelect():New("WKGROUPS","_WKMARCA",,aTb_Campos,.F.,@cMarca,aPos)
   oMarkGROUP:bAval := {|| MarcaCpo(.F.,"WKGROUPS")}
   oMarkGROUP:oBrowse:lCanAllMark := .T.
   oMarkGROUP:oBrowse:lHasMark    := .T.
   oMarkGROUP:oBrowse:bAllMark := {|| MarcaCpo(.T.,"WKGROUPS")}
   oMarkGROUP:oBrowse:bChange := {||oMarkModulo:oBrowse:SetFilter("CODGROUP",WKGROUPS->CODGROUP,WKGROUPS->CODGROUP),;
      oMarkModulo:oBrowse:Refresh(),;
      oMarkAcesso:oBrowse:SetFilter("CODUSMOD",WKMODULOS->(CODGROUP+CODMODULO),WKMODULOS->(CODGROUP+CODMODULO)),;
      oMarkAcesso:oBrowse:Refresh()}
//
   aPos := {oMainWnd:nTop+12,111,290,210}
   aTb_Campos        := CriaTbCpos("MODULOS")
   oMarkModulo       := MsSelect():New("WKMODULOS","_WKMARCA",,aTb_Campos,.F.,@cMarca,aPos)
   oMarkModulo:bAval := {|| MarcaCpo(.F.,"WKMODULOS")}
   oMarkModulo:oBrowse:lCanAllMark := .T.
   oMarkModulo:oBrowse:lHasMark    := .T.
   oMarkModulo:oBrowse:bAllMark := {|| MarcaCpo(.T.,"WKMODULOS")}
   oMarkModulo:oBrowse:SetFilter("CODGROUP",WKGROUPS->CODGROUP,WKGROUPS->CODGROUP)
   oMarkModulo:oBrowse:bChange := {||oMarkAcesso:oBrowse:SetFilter("CODUSMOD",WKMODULOS->(CODGROUP+CODMODULO),WKMODULOS->(CODGROUP+CODMODULO)),;
      oMarkAcesso:oBrowse:Refresh()}

//
   aPos := {oMainWnd:nTop+12,211,290,650}
   aTb_Campos        := CriaTbCpos("ACESSO")
   oMarkAcesso       := MsSelect():New("WKACESSO","_WKMARCA",,aTb_Campos,.F.,@cMarca,aPos)
   oMarkAcesso:bAval := {|| MarcaCpo(.F.,"WKACESSO")}
   oMarkAcesso:oBrowse:lCanAllMark := .T.
   oMarkAcesso:oBrowse:lHasMark    := .T.
   oMarkAcesso:oBrowse:bAllMark := {|| MarcaCpo(.T.,"WKACESSO")}
   oMarkAcesso:oBrowse:SetFilter("CODUSMOD",WKMODULOS->(CODGROUP+CODMODULO),WKMODULOS->(CODGROUP+CODMODULO))

//
   if  lPrintUsr
      aPos :={oMainWnd:nTop+12,651,290,770}   //  {oMainWnd:nTop+12,651,290,110}
      aTb_Campos      := CriaTbCpos("USERS")
      oMarkUSER      := MsSelect():New("WKUSERS",,,aTb_Campos,.F.,,aPos)
   Endif

   Activate MsDialog oDlg On Init ( EnchoiceBar(oDlg,bOk,bCancel,,aButtons), ,, )   //
//
   WKGROUPS->(dbCloseArea())
   WKMODULOS->(dbCloseArea())
   WKACESSO->(dbCloseArea())
   WKUSERS->(dbCloseArea())

   oTableUser:Delete()
   oTableModule:Delete()
   oTableAccess:Delete()

//
Return

/*
Funcao      : Filtro
Objetivos   : Filtra os dados que serão buscados
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 26/02/2013
*/
   *----------------------*
Static Function Filtro()
   *----------------------*
   Local lOk     := .F.
   Local bOk     := {|| lOk := .T., oDlg:End()}
   Local bCancel := {|| lOk := .F., oDlg:End()}
   Local nLin    := 15
   Local nCol    := 15
   Local lChk1   := lChk2 := lChk3 := lChk4 := lChk5 := lChk6 := lChk7 := lChk8 := lChk9 := lChk10 := .T.
   Local lChk11  := .F.
   Local oDlg, oChkBox1, oChkBox2, oChkBox3, oChkBox4, oChkBox5, oChkBox6, oChkBox7,oChkBox11, oChkBox8, oPanel,;
      oModDe, oModAte, oGROUPDe, oGROUPAte, oRotDe, oRotAte

   oMainWnd:ReadClientCoords()
   Define MsDialog oDlg Title "Acesso de Grupos" From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 Of oMainWnd Pixel
   *
   oPanel = TPanel():New(nLin,nCol-5,"Colunas a serem impressas",oDlg,,.F.,,,,175,45,.F.,.T.)
   nLin += 15
   @ nLin,nCol     CheckBox oChkBox1 Var lChk1 Prompt "Grupo"    On Click ( aColPrint[1] := !aColPrint[1] ) Size 130,9 Of oDlg Pixel
   @ nLin,nCol+40  CheckBox oChkBox2 Var lChk2 Prompt "Módulo"     On Click ( aColPrint[2] := !aColPrint[2] ) Size 130,9 Of oDlg Pixel
   @ nLin,nCol+80  CheckBox oChkBox3 Var lChk3 Prompt "Menu"       On Click ( aColPrint[3] := !aColPrint[3] ) Size 130,9 Of oDlg Pixel
   @ nLin,nCol+120 CheckBox oChkBox4 Var lChk4 Prompt "Sub-Menu"   On Click ( aColPrint[4] := !aColPrint[4] ) Size 130,9 Of oDlg Pixel
   nLin += 15
   @ nLin,nCol     CheckBox oChkBox5 Var lChk5 Prompt "Rotina"     On Click ( aColPrint[5] := !aColPrint[5] ) Size 130,9 Of oDlg Pixel
   @ nLin,nCol+40  CheckBox oChkBox6 Var lChk6 Prompt "Acesso"     On Click ( aColPrint[6] := !aColPrint[6] ) Size 130,9 Of oDlg Pixel
   @ nLin,nCol+80  CheckBox oChkBox7 Var lChk7 Prompt "Função"     On Click ( aColPrint[7] := !aColPrint[7] ) Size 130,9 Of oDlg Pixel
   @ nLin,nCol+120 CheckBox oChkBox8 Var lChk8 Prompt "Menu(.xnu)" On Click ( aColPrint[8] := !aColPrint[8] ) Size 130,9 Of oDlg Pixel
   *
   nLin += 30
   *
   @ nLin,nCol     CheckBox oChkBox9 Var lChk9 Prompt "Marcado/Desmarcado?" On Click ( lMarca := !lMarca ) Size 130,9 Of oDlg Pixel
   nLin += 15
   @ nLin,nCol     CheckBox oChkBox10 Var lChk10 Prompt "Retrato/Paisagem" On Click ( lRetrato := !lRetrato ) Size 130,9 Of oDlg Pixel
   *
   nLin += 30
   @ nLin,nCol    Say  'Módulo De: '                                                         Of oDlg Pixel
   @ nLin,nCol+45 MsGet oModDe  Var cModDe  VALID (Vazio() .OR. cModDe >="01")   Size 60,09  Of oDlg Pixel
   nLin += 15
   @ nLin,nCol    Say  'Módulo Até: '                                                         Of oDlg Pixel
   @ nLin,nCol+45 MsGet oModAte Var cModAte VALID (!Vazio() .AND. cModAte <="99") Size 60,09  Of oDlg Pixel
   nLin += 30
   @ nLin,nCol    Say  'Grupo De: '                                                               Of oDlg Pixel
   @ nLin,nCol+45 MsGet oGROUPDe  Var cGrpDe  VALID (Vazio() .OR. cGrpDe >="000001")   Size 60,09  Of oDlg Pixel
   nLin += 15
   @ nLin,nCol    Say  'Grupo Até: '                                                               Of oDlg Pixel
   @ nLin,nCol+45 MsGet oGROUPAte Var cGrpAte VALID (!Vazio() .AND. cGrpAte <="999999") Size 60,09  Of oDlg Pixel
   nLin += 30
   @ nLin,nCol    Say  'Rotina De: '                                                                    Of oDlg Pixel
   @ nLin,nCol+45 MsGet oRotDe  Var cRotDe Picture "@!"                                     Size 60,09  Of oDlg Pixel
   nLin += 15
   @ nLin,nCol    Say  'Rotina Até: '                                                                                Of oDlg Pixel
   @ nLin,nCol+45 MsGet oRotAte Var cRotAte Picture "@!" VALID (!Vazio() .AND. cRotAte <="ZZZZZZZZZZZZ") Size 60,09  Of oDlg Pixel
   *
   nLin += 15
   @ nLin,nCol     CheckBox oChkBox11 Var lChk11 Prompt "Lista Usuarios?" On Click ( lPrintUsr := !lPrintUsr ) Size 130,9 Of oDlg Pixel

   Activate MsDialog oDlg On Init ( EnchoiceBar(oDlg,bOk,bCancel,,), ,, )

Return lOk

/*
Funcao      : CriaWork
Objetivos   : Cria Works para criação dos msselects
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/

Static Function CriaWork()

   Local aSemSx3 := {}

   oTableUser := FWTemporaryTable():New("WKUSERS", /*aFields*/)

   aAdd(aSemSx3,{"_WKMARCA","C",02,0})
   aAdd(aSemSx3,{"_CODUSER","C",06,0})
   aAdd(aSemSx3,{"_USER"   ,"C",30,0})

   oTableUser:SetFields(aSemSx3)

   oTableUser:AddIndex("01", {"_CODUSER"})

   oTableUser:Create()

   aSemSx3 := {}

   oTableModule := FWTemporaryTable():New("WKMODULOS", /*aFields*/)

   aAdd(aSemSx3,{"_WKMARCA"  ,"C",02,0})
   aAdd(aSemSx3,{"_CODUSER"  ,"C",06,0})
   aAdd(aSemSx3,{"CODMODULO","C",02,0})
   aAdd(aSemSx3,{"MODULO"   ,"C",30,0})

   oTableModule:SetFields(aSemSx3)

   oTableModule:AddIndex("01", {"_CODUSER", "CODMODULO"})

   oTableModule:Create()

   aSemSx3 := {}

   oTableAccess := FWTemporaryTable():New("WKACESSO", /*aFields*/)

   aAdd(aSemSx3,{"_WKMARCA"  ,"C",02,0})
   aAdd(aSemSx3,{"CODUSMOD" ,"C",08,0})
   aAdd(aSemSx3,{"_USER"     ,"C",30,0})
   aAdd(aSemSx3,{"MODULO"   ,"C",30,0})
   aAdd(aSemSx3,{"MENU"     ,"C",12,0})
   aAdd(aSemSx3,{"SUBMENU"  ,"C",25,0})
   aAdd(aSemSx3,{"ROTINA"   ,"C",25,0})
   aAdd(aSemSx3,{"FUNCAO"   ,"C",25,0})
   aAdd(aSemSx3,{"XNU"      ,"C",40,0})
   aAdd(aSemSx3,{"ACESSO"   ,"C",10,0})

   oTableAccess:SetFields(aSemSx3)

   oTableAccess:AddIndex("01", {"CODUSMOD"})

   oTableAccess:Create()

Return()

/*
Funcao      : CriaTbCpos
Objetivos   : Cria tbCampos para os msSelects
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/

Static Function CriaTbCpos(cTipo)

   Local aTbCpos := {}
//

   If cTipo <> "USERS"
      aAdd(aTbCpos,{"_WKMARCA",,""       ,""} )
   Endif
//
   If cTipo == "GROUPS"
//
      aAdd(aTbCpos,{"GROUP"   ,,"Grupo",""} )
//
   ElseIf cTipo == "MODULOS"
//
      aAdd(aTbCpos,{"MODULO" ,,"Módulo",""} )
//
   ElseIf cTipo == "ACESSO"
//
      aAdd(aTbCpos,{"MENU"   ,,"Menu"    ,""} )
      aAdd(aTbCpos,{"SUBMENU",,"Sub-Menu",""} )
      aAdd(aTbCpos,{"ROTINA" ,,"Rotina"  ,""} )
      aAdd(aTbCpos,{"ACESSO" ,,"Acesso"  ,""} )

   ElseIf cTipo == "USERS"
//
      aAdd(aTbCpos,{"_USER"   ,,"Usuario",""} )
//
   EndIf
//
Return aTbCpos

/*
Funcao      : PreencheWk
Objetivos   : Preenche works com dados de Grupos, módulos e menus.
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/

Static Function PreencheWk()

   Local   nTamMod  := 0   // ref 26/02/13 - adicionadas as 2 variáveis de controle para melhoria de performance.
   Local   nTamGROUP := Len(aGroups)
   Local i        := 2    // começa em 2 para pular o adm que tem acesso full
   Local j        := 1

   Private lAppGROUP := .F.
   Private lAppMod  := .F.

   ProcRegua(nTamGROUP-1)
// Loop nos Grupos
   For i := 2 To nTamGROUP
      IncProc("Carregando Grupo "+AllTrim(Str(i-1))+" de "+AllTrim(Str(nTamGROUP-1)))
// se GROUP estiver inativo ou fora do range de filtro passa direto
      //If !aGroups[i][1][17] .AND. cGrpDe <= aGroups[i][1][1] .AND. cGrpAte >= aGroups[i][1][1]
         lAppGROUP := .F.
         nTamMod := Len(aGroups[i][2])
// Loop nós módulos
         For j:=1 To nTamMod
// Verifica se o Grupo tem acesso a esse módulo e o módulo está no ragen do filtro
            If SubStr(aGroups[i][2][j],3,1) != "X" .AND. cModDe <= SubStr(aGroups[i][2][j],1,2) .AND. cModAte >= SubStr(aGroups[i][2][j],1,2)
               lAppMod := .F.
// preenche work de acesso passando o nome do xnu
               preencMenu(SubStr(aGroups[i][2][j],4,Len(aGroups[i][2][j])-3), i, j)
               If lAppMod
// preenche work de módulos
                  WKMODULOS->(dbAppend())
                  WKMODULOS->_WKMARCA   := If(lMarca,cMarca,"")
                  WKMODULOS->CODGROUP   := aGroups[i][1][1]    // Código do GROUP
                  WKMODULOS->CODMODULO := SubStr(aGroups[i][2][j],1,2)    // Código do módulo
                  WKMODULOS->MODULO    := retModulo(Val(WKMODULOS->CODMODULO))    // função que retorna a descrição do módulo de acordo com o código passado.
                  lAppGROUP := .T.
               EndIf
            EndIf
         Next j
         If lAppGROUP
// preenche work de Grupos
            WKGROUPS->(dbAppend())
            WKGROUPS->_WKMARCA := If(lMarca,cMarca,"")
            WKGROUPS->GROUP    := aGroups[i][1][2]    // Nome do GROUP
            WKGROUPS->CODGROUP := aGroups[i][1][1]    // Código do GROUP
         EndIf
      //EndIf
   Next i

// preenche tabela de usuarios
   If lPrintUsr
      UsuGroup()
   Endif

Return

/*
Funcao      : retModulo
Objetivos   : retorna a descrição do módulo de acordo com o código passado.
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/

Static Function retModulo(nModulo)

   Local nPos     := 0
//
   nPos := aScan(aModulos, {|x| x[1]==nModulo})
//
Return If(nPos>0,aModulos[nPos][3],"Indefinido")


/*
Funcao      : preencMenu
Objetivos   : preenche as informações de acesso de acordo com o xnu
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/

Static Function preencMenu(cFile, i, j)

   Local nHandle  := -1
   Local lMenu    := .F.
   Local lSubMenu := .F.
   Local lAppMenu := .T.
   Local lAppSub  := .T.
   Local cMenu    := ""
   Local cSubMenu := ""
   Local cRotina  := ""
   Local cAcesso  := ""
   Local cFuncao  := ""
   Local cVisual  := "xx"+Space(3)+"xxxxx/xx"+Space(4)+"xxxx/xx"+Space(5)+"xxx/xx"+Space(6)+"xx/xx"+Space(7)+"x/xx"+Space(8)

// abre o arquivo xnu
   nHandle := Ft_FUse(cFile)
// se for -1 ocorreu erro na abertura
   If nHandle != -1
      Ft_FGoTop()
      While !Ft_FEof()
//
         cAux := Ft_FReadLn()
// fechando alguma tag, se for menu ou sub-menu muda a flag
         If "</MENU>" $ Upper(cAux)
            If lSubMenu
               lSubMenu := .F.
               lAppSub  := .T.
            ElseIf lMenu
               lMenu    := .F.
               lAppMenu := .T.
            EndIf
// encontrou tag menu (serve para menu e sub-menu) e não é fechamento
         ElseIf "MENU " $ Upper(cAux)   // o espaço depois de "MENU " é para definir a abertura NÃO REMOVER
// verifica flag de abertura e fechamento de menu/sub-menu
            If !lMenu
               lMenu := .T.
            ElseIf !lSubMenu
               lSubMenu := .T.
            EndIf
            If "HIDDEN" $ Upper(cAux) .OR. "DISABLE" $ Upper(cAux)
               If lMenu .AND. !lSubMenu
                  lAppMenu := .F.
               ElseIf lSubMenu
                  lAppSub  := .F.
               EndIf
            EndIf
            Ft_FSkip()
            cAux := Ft_FReadLn()
// captura o que está entre as tags
            cAux := retTag(cAux)
            If lMenu .AND. !lSubMenu
               cMenu := StrTran(cAux,"&","")
            ElseIf lSubMenu
               cSubMenu := StrTran(cAux,"&","")
            EndIf
// Faz o tratamento das rotinas de menu e appenda a work
         ElseIf "MENUITEM " $ Upper(cAux)
            If "HIDDEN" $ Upper(cAux) .OR. "DISABLE" $ Upper(cAux) .OR. !lAppSub .OR. !lAppMenu
               cAcesso := "Sem Acesso"
               Ft_FSkip()
               cAux := Ft_FReadLn()
               nIni := At(">", cAux)+1
               nFim := Rat("<",cAux)
// captura o que está entre as tags
               cRotina := RetTag(cAux)
// captura o nome da função
               While !("FUNCTION" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
                  Ft_FSkip()
               EndDo
               cAux := Ft_FReadLn()
               cFuncao := RetTag(cAux)
            Else
               Ft_FSkip()
               cAux := Ft_FReadLn()
// captura o que está entre as tags
               cRotina := RetTag(cAux)
// captura o nome da função
               While !("FUNCTION" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
                  Ft_FSkip()
               EndDo
               cAux := Ft_FReadLn()
               cFuncao := RetTag(cAux)
// captura o acesso da rotina
               While !("ACCESS" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
                  Ft_FSkip()
               EndDo
               cAux := Ft_FReadLn()
               cAux := RetTag(cAux)
               If cAux == "xxxxxxxxxx"
                  cAcesso := "Manutenção"
               ElseIf cAux $ cVisual
                  cAcesso := "Visualizar"
               Else
                  cAcesso := "Sem Acesso"
               EndIf
            EndIf
            If AllTrim(cRotDe) <= AllTrim(cFuncao) .AND. AllTrim(cRotAte) >= AllTrim(cFuncao)
               WKACESSO->(dbAppend())
               WKACESSO->_WKMARCA   := If(lMarca,cMarca,"")
               WKACESSO->CODUSMOD  := aGroups[i][1][1]+SubStr(aGroups[i][2][j],1,2)    // Código do GROUP + Código do módulo
               WKACESSO->GROUP      := aGroups[i][1][2]    // Nome do GROUP
               WKACESSO->MODULO    := retModulo(Val(SubStr(aGroups[i][2][j],1,2)))    // Nome do Módulo
               WKACESSO->MENU      := cMenu
               WKACESSO->SUBMENU   := cSubMenu
               WKACESSO->ROTINA    := cRotina
               WKACESSO->ACESSO    := cAcesso
               WKACESSO->FUNCAO    := cFuncao
               WKACESSO->XNU       := cFile
               lAppMod := .T.
            EndIf
         EndIf
         Ft_FSkip()
      EndDo
      Ft_Fuse()
   EndIf

Return

/*
Funcao      : RetTag
Objetivos   : Retorna o conteúdo das tags da linha passada EX:<Title lang="pt">TESTE</Title> o retorno será "TESTE"
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 07/11/2012
*/
   *----------------------------*
Static Function RetTag(cLinha)
   *----------------------------*
   Local nIni := At(">", cLinha)+1
   Local nFim := Rat("<",cLinha)
//
Return (SubStr(cLinha,nIni,(nFim-nIni)))


/*
Funcao      : MarcaCpo
Objetivos   : Marca/Desmarca Campos
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 13/06/2012
*/
   *------------------------------*
Static Function MarcaCpo(lTodos, cAlias)
   *------------------------------*
   Local nRegGROUP  := WKGROUPS->(RecNo())
   Local nRegMod   := WKMODULOS->(RecNo())
   Local nRegAcess := WKACESSO->(RecNo())
   Local cMark     := If(Empty((cAlias)->_WKMARCA),cMarca,"")
   Local cChave    := ""
//
   If lTodos
      If cAlias == "WKGROUPS"
         WKGROUPS->(dbGoTop())
         While WKGROUPS->(!Eof())
            RecLock("WKGROUPS",.F.)
            WKGROUPS->_WKMARCA := cMark
            WKGROUPS->(MsUnlock())
            WKGROUPS->(dbSkip())
         EndDo
         WKMODULOS->(dbGoTop())
         While WKMODULOS->(!Eof())
            RecLock("WKMODULOS",.F.)
            WKMODULOS->_WKMARCA := cMark
            WKMODULOS->(MsUnlock())
            WKMODULOS->(dbSkip())
         EndDo
         WKACESSO->(dbGoTop())
         While WKACESSO->(!Eof())
            RecLock("WKACESSO",.F.)
            WKACESSO->_WKMARCA := cMark
            WKACESSO->(MsUnlock())
            WKACESSO->(dbSkip())
         EndDo
      ElseIf cAlias == "WKMODULOS"
         WKMODULOS->(dbGoTop())
         WKMODULOS->(dbSeek(WKGROUPS->CODGROUP))
         While WKMODULOS->(!Eof()) .AND. WKMODULOS->CODGROUP == WKGROUPS->CODGROUP
            RecLock("WKMODULOS",.F.)
            WKMODULOS->_WKMARCA := cMark
            WKMODULOS->(MsUnlock())
            WKACESSO->(dbSeek(WKMODULOS->(CODGROUP+CODMODULO)))
            While WKACESSO->(!Eof()) .AND. WKACESSO->CODUSMOD == WKMODULOS->(CODGROUP+CODMODULO)
               RecLock("WKACESSO",.F.)
               WKACESSO->_WKMARCA := cMark
               WKACESSO->(MsUnlock())
               WKACESSO->(dbSkip())
            EndDo
            WKMODULOS->(dbSkip())
         EndDo
         RecLock("WKGROUPS",.F.)
         WKGROUPS->_WKMARCA := cMark
         WKGROUPS->(MsUnlock())
      ElseIf cAlias == "WKACESSO"
         WKACESSO->(dbGoTop())
         WKACESSO->(dbSeek(WKMODULOS->(CODGROUP+CODMODULO)))
         While WKACESSO->(!Eof()) .AND. WKACESSO->CODUSMOD == WKMODULOS->(CODGROUP+CODMODULO)
            RecLock("WKACESSO",.F.)
            WKACESSO->_WKMARCA := cMark
            WKACESSO->(MsUnlock())
            WKACESSO->(dbSkip())
         EndDo
         If !Empty(cMark)
            RecLock("WKGROUPS",.F.)
            WKGROUPS->_WKMARCA := cMark
            WKGROUPS->(MsUnlock())
         EndIf
         RecLock("WKMODULOS",.F.)
         WKMODULOS->_WKMARCA := cMark
         WKMODULOS->(MsUnlock())
      EndIf
   Else
      RecLock(cAlias,.F.)
      (cAlias)->_WKMARCA := cMark
      (cAlias)->(MsUnlock())
      If Empty(cMark) .AND. cAlias == "WKGROUPS"
         WKMODULOS->(dbSeek(WKGROUPS->CODGROUP))
         While WKMODULOS->CODGROUP == WKGROUPS->CODGROUP .AND. WKMODULOS->(!Eof())
            RecLock("WKMODULOS",.F.)
            WKMODULOS->_WKMARCA := cMark
            WKMODULOS->(MsUnlock())
            WKACESSO->(dbSeek(WKMODULOS->(CODGROUP+CODMODULO)))
            While WKACESSO->CODUSMOD == WKMODULOS->(CODGROUP+CODMODULO) .AND. WKACESSO->(!Eof())
               RecLock("WKACESSO",.F.)
               WKACESSO->_WKMARCA := cMark
               WKACESSO->(MsUnlock())
               WKACESSO->(dbSkip())
            EndDo
            WKMODULOS->(dbSkip())
         EndDo
      ElseIf Empty(cMark) .AND. cAlias == "WKMODULOS"
         WKACESSO->(dbSeek(WKMODULOS->(CODGROUP+CODMODULO)))
         While WKACESSO->CODUSMOD == WKMODULOS->(CODGROUP+CODMODULO) .AND. WKACESSO->(!Eof())
            RecLock("WKACESSO",.F.)
            WKACESSO->_WKMARCA := cMark
            WKACESSO->(MsUnlock())
            WKACESSO->(dbSkip())
         EndDo
      ElseIf !Empty(cMark) .AND. cAlias == "WKACESSO"
         RecLock("WKMODULOS",.F.)
         WKMODULOS->_WKMARCA := cMark
         WKMODULOS->(MsUnlock())
         RecLock("WKGROUPS",.F.)
         WKGROUPS->_WKMARCA := cMark
         WKGROUPS->(MsUnlock())
      ElseIf !Empty(cMark) .AND. cAlias == "WKMODULOS"
         RecLock("WKGROUPS",.F.)
         WKGROUPS->_WKMARCA := cMark
         WKGROUPS->(MsUnlock())
      EndIf
   EndIf
//
   WKGROUPS->(dbGoTo(nRegGROUP))
   WKMODULOS->(dbGoTo(nRegMod))
   WKACESSO->(dbGoTo(nRegAcess))
   oMarkGROUP:oBrowse:Refresh()
   oMarkModulo:oBrowse:Refresh()
   oMarkAcesso:oBrowse:Refresh()
// oMarkUSER:oBrowse:Refresh()
//
Return


/*
Funcao      : ReportDef
Objetivos   : Define estrutura de impressão
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 13/06/2012
*/

Static Function ReportDef()

//
   oReport := TReport():New("RELACESSO","Relatório de Acesso de Grupos","",;
      {|oReport| ReportPrint(oReport)},"Este relatorio irá Imprimir o Relatório de Acesso de Grupos")

// Inicia o relatório como retrato
   If lRetrato
      oReport:oPage:lLandScape := .F.
      oReport:oPage:lPortRait := .T.
   Else
      oReport:oPage:lLandScape := .T.
      oReport:oPage:lPortRait := .F.
   EndIf

// Define o objeto com a seção do relatório
   oSecao  := TRSection():New(oReport,"LOG","WKACESSO",{})
//
   If aColPrint[1]
      TRCell():New(oSecao,"GROUP"   ,"WKACESSO","Grupo"         ,""            ,30,,,"LEFT")
   EndIf
//
   If aColPrint[2]
      TRCell():New(oSecao,"MODULO" ,"WKACESSO","Módulo"          ,""            ,30,,,"LEFT")
   EndIf
//
   If aColPrint[3]
      TRCell():New(oSecao,"MENU"   ,"WKACESSO","Menu"            ,""            ,12,,,"LEFT")
   EndIf
//
   If aColPrint[4]
      TRCell():New(oSecao,"SUBMENU","WKACESSO","Sub-Menu"        ,""            ,25,,,"LEFT")
   EndIf
//
   If aColPrint[5]
      TRCell():New(oSecao,"ROTINA" ,"WKACESSO","Rotina"          ,""            ,25,,,"LEFT")
   EndIf
//
   If aColPrint[6]
      TRCell():New(oSecao,"ACESSO" ,"WKACESSO","Acesso"          ,""            ,10,,,"LEFT")
   EndIf
//
   If aColPrint[7]
      TRCell():New(oSecao,"FUNCAO" ,"WKACESSO","Função"          ,""            ,15,,,"LEFT")
   EndIf
//
   If aColPrint[8]
      TRCell():New(oSecao,"XNU"    ,"WKACESSO","XNU"             ,""            ,40,,,"LEFT")
   EndIf
//
Return oReport


/*
Funcao      : ReportPrint
Objetivos   : Imprime os dados filtrados
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 05/06/2012
*/
   
Static Function ReportPrint(oReport)
   
// Inicio da impressão da seção.
   oReport:Section("LOG"):Init()
   oReport:SetMeter(WKACESSO->(RecCount()))

   WKACESSO->(dbGoTop())
   oReport:SkipLine(2)
   Do While WKACESSO->(!EoF()) .And. !oReport:Cancel()
      If !Empty(WKACESSO->_WKMARCA)
         oReport:Section("LOG"):PrintLine()    // Impressão da linha
         oReport:IncMeter()                    // Incrementa a barra de progresso
      EndIf
      WKACESSO->( dbSkip() )
   EndDo

// Fim da impressão da seção
   oReport:Section("LOG"):Finish()
   WKACESSO->(dbSeek(WKMODULOS->(CODGROUP+CODMODULO)))
   oMarkAcesso:oBrowse:Refresh()
Return .T.


/*
Funcao      : usuGroup
Objetivos   : Especifica os usuarios do Grupos 
Autor       : Guilherme Medeiro Barrozo 
Data/Hora   : 12/12/2013
*/

   
Static Function UsuGroup()
   

   Local 	aUsers:= AllUsers()
   Local   nTamMod  := 0    // ref 26/02/13 - adicionadas as 2 variáveis de controle para melhoria de performance.
   Local   nTamUser := Len(aUsers)
   Local i        := 2    // começa em 2 para pular o adm que tem acesso full
   Local j        := 1

   Private lAppUser := .F.
   Private lAppMod  := .F.


   ProcRegua(nTamUser-1)
// Loop nos usuários
   For i := 2 To nTamUser
      WKGROUPS->(dbGoTop())
      IncProc("Carregando Usuário "+AllTrim(Str(i-1))+" de "+AllTrim(Str(nTamUser-1)))
      lAppUser := .F.
// Loop nos Grupos
   /*   While !WKGROUPS->(Eof()) .AND. !lAppUser

// loop nos grupos do usuário
         For j:=1 To Len(aUsers[i][1][10])

            If  !aUsers[i][1][17] .AND. alltrim(WKGROUPS->CODGROUP) = (aUsers[i][1][10][j])
// Possui Acesso
               lAppUser:=.T.
               Exit
            Endif

         Next j

         WKGROUPS-> (DbSkip())
      Enddo*/
      //If lAppUser
// preenche work de usuários
         WKUSERS->(dbAppend())
         WKUSERS->_WKMARCA := If(lMarca,cMarca,"")
         WKUSERS->_USER    := aUsers[i][1][2]    // Nome do _USER
         WKUSERS->_CODUSER := aUsers[i][1][1]    // Código do _USER
      //EndIf
   Next i

Return


/*
Funcao      : ExpUser
Objetivos   : Exporta os usuarios do Grupos 
Autor       : Guilherme Medeiro Barrozo 
Data/Hora   : 12/12/2013
*/

   
Static Function ExpUser()
   
   Local aHeader := {}, aItens := {}

   AADD(aHeader, {"Usuario", "C"})
   AADD(aHeader, {"Nome", "C"})

   WKUSERS->(dbGoTop())

   While !Eof()
      AADD(aItens, {WKUSERS->_USER,UsrFullName (WKUSERS->_CODUSER)})
      WKUSERS->(dbSkip())
   End

   U_DadExcel(aHeader,aItens)

   WKUSERS->(dbGoTop())

Return