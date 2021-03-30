#include "protheus.ch"
#include "msmgadd.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH

/*/{Protheus.doc} BIA742
@description Aprovadores de descontos financeiro via limites estabelecidos.
@author Filipe Bittencourt
@since 19/03/2021
@version 1.0
@type function
/*/

Static cTitulo := "Aprovadores de descontos financeiro"

User Function BIA742()

  Local oBrowse
  //Local aArea := GetAera()
  Local cFunBkp := FunName()

  SetFunName("BIA742")

  oBrowse := FWMBrowse():New()
  oBrowse:SetAlias('ZDK')
  oBrowse:SetDescription(cTitulo)
  oBrowse:AddLegend("ZDK->ZDK_STATUS == 'A'" ,"GREEN","Ativo")
  oBrowse:AddLegend("ZDK->ZDK_STATUS == 'B'" ,"RED","Bloqueado")
  oBrowse:Activate()


Return

Static Function MenuDef()

  Local aRot := {}
  //ADD OPTION aRot Title 'Visualizar' Action 'VIEWDEF.BIA742' OPERATION 1 ACCESS 0
  ADD OPTION aRot Title 'Visualizar' Action 'VIEWDEF.BIA742' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2 OU  1
  ADD OPTION aRot Title 'Incluir'    Action 'VIEWDEF.BIA742' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
  ADD OPTION aRot Title 'Alterar'    Action 'VIEWDEF.BIA742' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
  ADD OPTION aRot Title 'Excluir'    Action 'VIEWDEF.BIA742' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
  ADD OPTION aRot Title 'Legenda'    Action 'U_ZDKLEG' OPERATION 6 ACCESS 0

Return(aRot)

Static Function ModelDef()

  Local oModel   := Nil
  Local aZDKRel  := {}
  Local oFormPai := FWFormStruct(1, 'ZDK', {|cCampo| AllTrim(cCampo) $ "ZDK_CLVLR|ZDK_CCONTA"}) // CABEÇALHO
  Local oFormFil := FWFormStruct(1, 'ZDK', {|cCampo| AllTrim(cCampo) $ "ZDK_APROV1|ZDK_APRON1|ZDK_VLAPIN|ZDK_VLAPFI|ZDK_APROVT|ZDK_APRONT|ZDK_DTATIN|ZDK_DTATFI|ZDK_STATUS"})// ITENS

  //Criando modelo de dados  //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
  oModel := MPFormModel():New("BIA742M",/*bPreValid*/,{|oModel| fTdOk(oModel)},/*<bCommit >*/,/*bCancel*/)

  oModel:AddFields("FORMPAI",/*cOwner*/,oFormPai)// Cabeçalho - PAI
  oModel:AddGrid('FORMFILH',"FORMPAI",oFormFil) // ITENS - FILHO

  If INCLUI
    oFormFil:SetProperty('ZDK_APRON1'	, MODEL_FIELD_INIT, {|oView| Space(TamSx3("ZDK_APRON1")[1]) })
    oFormFil:SetProperty('ZDK_APRONT'	, MODEL_FIELD_INIT, {|oView| Space(TamSx3("ZDK_APRONT")[1]) })
  Else
    oFormFil:SetProperty('ZDK_APRON1'	, MODEL_FIELD_INIT, {|oView| UsrFullName(ZDK->ZDK_APROV1) })
    oFormFil:SetProperty('ZDK_APRONT'	, MODEL_FIELD_INIT, {|oView| UsrFullName(ZDK->ZDK_APROVT) })
  EndIf

  oFormFil:AddTrigger("ZDK_APROV1",'ZDK_APRON1', {|| .T.}, {|oView| UsrFullName(M->ZDK_APROV1) })
  oFormFil:AddTrigger("ZDK_APROVT",'ZDK_APRONT', {|| .T.}, {|oView| UsrFullName(M->ZDK_APROVT) })

  //Criando o relacionamento FILHO e PAI
  aAdd(aZDKRel, {'ZDK_CLVLR',  'IIf(!INCLUI, ZDK->ZDK_CLVLR,  FWxFilial("ZDK"))'} )
  aAdd(aZDKRel, {'ZDK_CCONTA', 'IIf(!INCLUI, ZDK->ZDK_CCONTA, FWxFilial("ZDK"))'} )


  //Criando o relacionamento
  oModel:SetRelation('FORMFILH', aZDKRel, ZDK->(IndexKey(1)))

  //Setando o campo único da ITENS para não ter repetição
  //oModel:GetModel('FORMFILH'):SetUniqueLine({"ZDK_TRECHO"})

  //Setando outras informações do Modelo de Dados
  oModel:SetDescription(cTitulo)
  oModel:SetPrimaryKey({})

  oModel:GetModel("FORMPAI"):SetDescription(cTitulo)

Return oModel

Static Function ViewDef()

  Local oModel   := FWLoadModel("BIA742")
  Local oFormPai := FWFormStruct(2, 'ZDK', {|cCampo| AllTrim(cCampo) $ "ZDK_CLVLR|ZDK_CCONTA"}) // CABEÇALHO
  Local oFormFil := FWFormStruct(2, 'ZDK', {|cCampo| AllTrim(cCampo) $ "ZDK_APROV1|ZDK_APRON1|ZDK_VLAPIN|ZDK_VLAPFI|ZDK_APROVT|ZDK_APRONT|ZDK_DTATIN|ZDK_DTATFI|ZDK_STATUS"})// ITENS

  Local oView    := Nil

  oView := FWFormView():New()
  oView:SetModel(oModel)

  oView:AddField("VIEW_CAB"	, oFormPai	, "FORMPAI")
  oView:AddGrid('VIEW_FIL'	, oFormFil	, "FORMFILH")

  //Setando o dimensionamento de tamanho
  oView:CreateHorizontalBox('CABEC', 30)
  oView:CreateHorizontalBox('ITENS' , 70)

  //Amarrando a view com as box
  oView:SetOwnerView('VIEW_CAB','CABEC')
  oView:SetOwnerView('VIEW_FIL','ITENS')

  //Habilitando título
  //oView:EnableTitleView('VIEW_CAB', 'AAAAA')
  //oView:EnableTitleView('VIEW_FIL', 'BBBBB')

  //Tratativa padrão para fechar a tela
  oView:SetCloseOnOk({||.T.})

  //Remove os campos de Filial e Tabela da ITENS
	/*oStFilho:RemoveField('ZDK_CODIGO')*/

Return oView

User Function ZDKLEG()
  Local aLegenda := {}

  //Monta as cores
  AADD(aLegenda,{"GREEN",		"Ativo"  })
  AADD(aLegenda,{"RED",	"Bloqueado"})
  BrwLegenda(cTitulo, "Status", aLegenda)

Return


Static Function fTdOk(oModel)

  Local lRet    := .T.
  Local nX      := 1
  Local nY      := 1
  Local cQuery  := ""
  Local oCAB    := oModel:GetModel("FORMPAI")
  Local oITEM   := oModel:GetModel("FORMFILH","ZDK_APRON1")
  Local oAUX    := oITEM
  Local nOpc 		:= oModel:GetOperation()

  Local cCLVLR  := oCAB:GetValue('ZDK_CLVLR')
  Local cCCONTA := oCAB:GetValue('ZDK_CCONTA')
  Local cQry    := GetNextAlias()



  If (nOpc == MODEL_OPERATION_INSERT)

    cQuery += " select * from ZDK010 "  + CRLF
    cQuery += " WHERE D_E_L_E_T_ = '' "  + CRLF
    cQuery += " AND ZDK_CLVLR    = '"+AllTrim(cCLVLR)+"' "+ CRLF
    cQuery += " AND ZDK_CCONTA   = '"+AllTrim(cCCONTA)+"' "+ CRLF

    TcQuery cSQL New Alias (cQry)

    If !EMPTY((cQry)->ZDK_APROV1)
      Help(NIL, NIL, "Help", NIL, "Já existe dados cadastrados com essas informações.", 1, 0,,,,,,{""})
      Return .F.
    EndIf

  EndIf


  If oITEM:GetQtdLine() == 0

    Help(NIL, NIL, "Help", NIL, "Favor informar os dados de valores inicial e final.", 1, 0,,,,,,{""})
    Return .F.

  EndIf

  If (nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE) .and. oITEM:GetQtdLine() >= 2

    For nX := 1 TO oITEM:GetQtdLine()

      oITEM:GoLine(nX) // posiciona no primeiro item do grid
      If oITEM:IsDeleted(nX) == .F. // ignora linhas deletadas

        For nY := 1  TO oAUX:GetQtdLine()

          oAUX:GoLine(nY) // posiciona no ULTIMO item do grid
          If ( (oAUX:IsDeleted(nY) == .F.) .AND. (oITEM:GetValue('ZDK_APROV1', nX) == oAUX:GetValue('ZDK_APROV1',nY)) .AND. (nY != nX) )
            Help(,,'HELP',,"Não é permitido cadastrar o mesmo usuario  mais de uma vez na linha  <b>"+cValToChar(nY)+" - "+oITEM:GetValue('ZDK_APROV1')+"</b>", 1, 0,,,,,,{"Para auxiliar, ordene pela coluna usuário e altere um dos valores duplicados."})
            Return .F.
          EndIf

        Next nY

      EndIf

    Next nX

  EndIf

Return (lRet)




/*
Static Function fLinOK(oGrid,nLine)
  Local nOpc := oITEM:GetOperation()
  Local lRet := .T.
Return(lRet)

Static Function fPreValidCad(oModel)
  Local lRet :=.T.
  Local nOpc := oModel:getoperation()
Return(lRet)

Static Function fTudoOK(oModel)

  Local lRet		 := .T.
  Local nX   		 := 0
  Local nWhile       := 1
  Local nLinValid  := 0
  Local nOpc 		 := oModel:GetOperation()
  Local oField     := oModel:GetModel("FORMPAI")
  Local oGrid      := oModel:GetModel("FORMFILH","ZDK_TRECHO")

  Local cUsrAux := ""
  Local cPswAux := ""

  Local cUFOrig  := "" // estado de origem
  Local cCidOrig := "" // cidade de origem
  Local cUFDest  := "" // estado de Destino
  Local cCidDest := "" // cidade de Destino

  If !(RetCodUsr() $ cCodGestor)

    If nOpc == MODEL_OPERATION_DELETE .Or. nOpc == MODEL_OPERATION_UPDATE

      If !StaticCall(VIXA114, AnaliBloqueio, SC7->C7_NUM) // Ja liberado

        If Aviso("ATENCAO", "Pedido já esta liberado. Seu usuário não tem permissão para " + If(nOpc == MODEL_OPERATION_DELETE, " exclusão!", " alteração!") + CRLF, {"Autorização Gestor", "Cancela"}, 3) == 1

          If !U_VIXA259(@cUsrAux, @cPswAux)

            Return(.F.)

          EndIf

        Else

          Return(.F.)

        EndIf

      EndIf

    EndIf

  EndIf

  If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE



    //percorrendo  o ITENS
    For nX := 1 To oITEM:GetQtdLine()
      oITEM:GoLine(nX) // posiciona no primeiro item do ITENS
      If !oITEM:IsDeleted() // ignora linhas deletadas
        lRet := fLinOK(oGrid,nX)

        //Não permite cadastrar rotas iguais
        If((oITEM:GetValue('ZDK_UFORIG') == oITEM:GetValue('ZDK_UFDEST')) .AND.  (oITEM:GetValue('ZDK_CIDORI') == oITEM:GetValue('ZDK_CIDDES')))
          Help( ,, 'HELP',, "Não é permitido cadastrar rotas iguais, favor verificar", 1, 0)
          lRet := .F.
          Exit
        EndIf

        // começar a validar a partir da segunda linha caso exista. Onde o destino precisa ser a origem do trecho seguinte
        If nX > 1
          If(cUFDest != oITEM:GetValue('ZDK_UFORIG'))
            Help( ,, 'HELP',, "O estado da origem do próximo trecho precisa ser igual ao estado do destino anterior", 1, 0)
            lRet := .F.
            Exit
          EndIf

          If(cCidDest != oITEM:GetValue('ZDK_CIDORI'))
            Help( ,, 'HELP',, "A cidade da origem do próximo trecho precisa ser igual a cidade do destino anterior", 1, 0)
            lRet := .F.
            Exit
          EndIf
        EndIf
        cUFOrig := oITEM:GetValue('ZDK_UFORIG')
        cCidOrig := oITEM:GetValue('ZDK_CIDORI')
        cUFDest := oITEM:GetValue('ZDK_UFDEST')
        cCidDest := oITEM:GetValue('ZDK_CIDDES')

        // O ultimo destino destino precisa terminar na cidade em que a FILIA s encontra
        //		 If(nX == oITEM:GetQtdLine())
        //  If((oITEM:GetValue('ZDK_UFDEST') != SM0->M0_ESTCOB) .OR. (SubStr(SM0->M0_CODMUN,3) != oITEM:GetValue('ZDK_CIDDES')))
        //			 	Help( ,, 'HELP',, "O último trecho de destino precisa ser o da própria Filial: " + cValToChar(SM0->M0_CIDCOB)+" - "+ cValToChar(SM0->M0_ESTCOB), 1, 0)
        //				lRet := .F.
        //				Exit
        //  EndIf
        //EndIf


      EndIf
    Next nX

  EndIf

Return(lRet)

//Valida fornecedor para não permitir cadastrar uma rota para um que já tenha.
User Function VIX257PC()

  Local oModel	:= FWModelActive()
  Local nOpc 	:= oModel:GetOperation()
  Local lRet   := .T.

  If nOpc == MODEL_OPERATION_INSERT
    ZDK->(dbSetOrder(1)) // orderna sempre pelo indice nesse caso o 1   ZDK_FILIAL+ZDK_CODFOR+ZDK_LOJA+ZDK_CTRANS
    If (ZDK->(DBSEEK(xFilial("ZDK")+oModel:GetValue('FORMPAI','ZDK_NUM')))) // posiciona no primeiro registro da tabela em questão segundo a ordem do indice no  dbSetOrder(1)
      Help( ,, 'HELP',, "Este pedido já possui uma rota cadastrada, favor escolher outro. ", 1, 0)
      lRet :=  .F.
    EndIf
  EndIf

  SC7->(dbSetOrder(1)) // orderna sempre pelo indice nesse caso o 1   ZDK_FILIAL+ZDK_CODFOR+ZDK_LOJA+ZDK_CTRANS
  If !(SC7->(DBSEEK(xFilial("SC7")+oModel:GetValue('FORMPAI','ZDK_NUM')))) // posiciona no primeiro registro da tabela em questão segundo a ordem do indice no  dbSetOrder(1)
    Help( ,, 'HELP',, "Pedido inexistente, favor escolher outro. ", 1, 0)
    lRet :=  .F.
  EndIf

Return lRet

Static Function fCommit(oModel)

  Local lRet 		 := .T.
  Local oGrid		 := oModel:GetModel("FORMFILH")
  Local oForm		 := oModel:GetModel("FORMPAI")
  Local nX   		 := 0
  Local nY		 := 0
  Local nOpc 		 := oModel:GetOperation()
  Local aCposForm  := oForm:GetStruct():GetFields()
  Local aCposGrid  := oITEM:GetStruct():GetFields()

  If nOpc == MODEL_OPERATION_INSERT

    ConfirmSX8()

  EndIf

  For nX := 1 To oITEM:GetQtdLine()

    oITEM:GoLine(nX)

    ZDK->(dbGoTo(oITEM:GetDataID()))

    If nOpc == MODEL_OPERATION_DELETE

      //-- Deleta registro
      ZDK->(RecLock("ZDK",.F.))
      ZDK->(dbDelete())
      ZDK->(MsUnLock())

    Else

      //-- Grava inclusao/alteracao
      ZDK->(RecLock("ZDK", ZDK->(EOF())))

      If oITEM:IsDeleted()

        ZDK->(dbDelete())

      Else

        //-- Grava campos do cabecalho
        For nY := 1 To Len(aCposForm)

          If ZDK->(FieldPos(aCposForm[nY,3])) > 0

            ZDK->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])

          EndIf

        Next nY

        //-- Grava campos do ITENS
        For nY := 1 To Len(aCposGrid)

          If ZDK->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "ZDK_FILIAL"

            ZDK->&(aCposGrid[nY,3]) := oITEM:GetValue(aCposGrid[nY,3])

          EndIf

        Next nY

      EndIf

      ZDK->(MsUnLock())

      ZDK->(RecLock("ZDK",.F.))
      ZDK->ZDK_FILIAL := xFilial("ZDK")
      ZDK->(MsUnLock())

    EndIf

  Next nX

Return(lRet)

Static Function fCancel(oModel)

  Local lRet 		 := .T.
  Local oForm		 := oModel:GetModel("FORMPAI")
  Local oGrid		 := oModel:GetModel("FORMFILH")
  Local nOpc 		 := oModel:GetOperation()

  If nOpc == MODEL_OPERATION_INSERT

    RollBAckSx8()

  EndIf

Return(lRet)

User Function VIX257IG(cTab, nIndex, cConteudo, cCampoRet, lTrigger, aCampoDest)

  Local lRet 		:= .T.
  Local oModel	:= FWModelActive()
  Local oView		:= FwViewActive()
  Local cRetorno	:= ""

  Default cTab		:= ""
  Default lTrigger 	:= .F.
  Default aCampoDest	:= {}

  If (!oView:IsActive() .And. !INCLUI) .Or. lTrigger

    If ! Empty(cTab)

      cRetorno := PadL(Posicione(cTab, nIndex, xFilial(cTab) + cConteudo, cCampoRet), TamSx3(cCampoRet)[1])

    EndIf

  EndIf

Return(cRetorno)
 */