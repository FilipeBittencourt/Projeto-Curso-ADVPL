#include "protheus.ch"
#include "msmgadd.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFF001 - TELA MVC MOD 2 - TABELA ZDK  - TICKET 26221
@description Aprovadores de descontos financeiro via limites estabelecidos.
@author Filipe Bittencourt
@since 19/03/2021
@version 1.0
@type function

ZDK_CLVLR  -> Consulta Padrão CTH CLASSE VALOR 
ZDK_CCONTA -> Consulta Padrão CT1
ZDK_APROVA -> Consulta Padrão USR
/*/

Static cTitulo := "Aprovadores de descontos financeiro"

User Function BIAFF001()

  Local oBrowse
  //Local aArea := GetAera()
  Local cFunBkp := FunName()

  SetFunName("BIAFF001")

  oBrowse := FWMBrowse():New()
  oBrowse:SetAlias('ZDK')
  oBrowse:SetDescription(cTitulo)
  oBrowse:AddLegend("ZDK->ZDK_STATUS == 'A'" ,"GREEN","Ativo")
  oBrowse:AddLegend("ZDK->ZDK_STATUS == 'I'" ,"RED","Inativo")
  oBrowse:Activate()


Return

Static Function MenuDef()

  Local aRot := {}
  //ADD OPTION aRot Title 'Visualizar' Action 'VIEWDEF.BIAFF001' OPERATION 1 ACCESS 0
  ADD OPTION aRot Title 'Visualizar' Action 'VIEWDEF.BIAFF001' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2 OU  1
  ADD OPTION aRot Title 'Incluir'    Action 'VIEWDEF.BIAFF001' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
  ADD OPTION aRot Title 'Alterar'    Action 'VIEWDEF.BIAFF001' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
  ADD OPTION aRot Title 'Excluir'    Action 'VIEWDEF.BIAFF001' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
  ADD OPTION aRot Title 'Legenda'    Action 'U_FF001LEG' OPERATION 6 ACCESS 0

Return(aRot)

Static Function ModelDef()

  Local oModel   := Nil
  Local aZDKRel  := {}
  Local oCAB := FWFormStruct(1, 'ZDK', {|cCampo| AllTrim(cCampo)  $ "ZDK_CLVLR|ZDK_CCONTA"}) // CABEÇALHO
  Local oITEN := FWFormStruct(1, 'ZDK', {|cCampo| AllTrim(cCampo) $ "ZDK_STATUS|ZDK_APROVA|ZDK_VLAPIN|ZDK_VLAPFI|ZDK_APROVT|ZDK_DTAPTI|ZDK_DTAPTF"})// ITENS
  Local aZDKRel  := {}
  //Criando modelo de dados  //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
  oModel := MPFormModel():New("BIAFF01M",/*bPreValid*/,{|oModel| fTdOk(oModel)},/*<bCommit >*/,/*bCancel*/)

  oModel:AddFields("CAB",/*cOwner*/,oCAB)// Cabeçalho - PAI
  oModel:AddGrid('ITEN',"CAB",oITEN) // ITENS - FILHO


  //Criando o relacionamento FILHO e PAI
  //aAdd(aZDKRel, {'ZDK_CLVLR', 'IIf(!INCLUI, ZDK->ZDK_CLVLR, FWxFilial("ZDK"))'} )

  aAdd(aZDKRel, {'ZDK_FILIAL', 'ZDK->ZDK_FILIAL'} )
  aAdd(aZDKRel, {'ZDK_CLVLR', 'ZDK->ZDK_CLVLR'} )
  aAdd(aZDKRel, {'ZDK_CCONTA', 'ZDK->ZDK_CCONTA'} )


  //Criando o relacionamento
  oModel:SetRelation('ITEN', aZDKRel, ZDK->(IndexKey(1))) //  ZDK_FILIAL, ZDK_CLVLR, ZDK_CCONTA, R_E_C_N_O_, D_E_L_E_T_

  /*
  If INCLUI
    oITEN:SetProperty('ZDK_APROVA'	, MODEL_FIELD_INIT, {|oView| Space(TamSx3("ZDK_APROVA")[1]) })
    oITEN:SetProperty('ZDK_APRONT'	, MODEL_FIELD_INIT, {|oView| Space(TamSx3("ZDK_APRONT")[1]) })
  Else
    oITEN:SetProperty('ZDK_APROVA'	, MODEL_FIELD_INIT, {|oView| UsrFullName(ZDK->ZDK_APROVA) })
    oITEN:SetProperty('ZDK_APRONT'	, MODEL_FIELD_INIT, {|oView| UsrFullName(ZDK->ZDK_APROVT) })
  EndIf
  */

  //oITEN:AddTrigger("ZDK_APROVA",'ZDK_APROVA', {|| .T.}, {|oView| UsrFullName(M->ZDK_APROVA) })
  //oITEN:AddTrigger("ZDK_APROVT",'ZDK_APRONT', {|| .T.}, {|oView| UsrFullName(M->ZDK_APROVT) })

  //Setando outras informações do Modelo de Dados
  oModel:SetDescription(cTitulo)
  oModel:SetPrimaryKey({})

  oModel:GetModel("CAB"):SetDescription(cTitulo)

Return oModel

Static Function ViewDef()

  Local oModel   := FWLoadModel("BIAFF001")
  Local oCAB := FWFormStruct(2, 'ZDK', {|cCampo| AllTrim(cCampo)  $ "ZDK_CLVLR|ZDK_CCONTA"}) // CABEÇALHO
  Local oITEN := FWFormStruct(2, 'ZDK', {|cCampo| AllTrim(cCampo) $ "ZDK_STATUS|ZDK_APROVA|ZDK_VLAPIN|ZDK_VLAPFI|ZDK_APROVT|ZDK_DTAPTI|ZDK_DTAPTF"})// ITENS

  Local oView    := Nil

  oView := FWFormView():New()
  oView:SetModel(oModel)

  oView:AddField("VIEW_CAB"	, oCAB	, "CAB") // Cabeçalho - PAI
  oView:AddGrid('VIEW_ITE'	, oITEN	, "ITEN") // ITENS - FILHO





  //Setando o dimensionamento de tamanho
  oView:CreateHorizontalBox('CABEC', 20)
  oView:CreateHorizontalBox('ITENS' , 80)

  //Amarrando a view com as box
  oView:SetOwnerView('VIEW_CAB','CABEC')
  oView:SetOwnerView('VIEW_ITE','ITENS')

  //Habilitando título
  oView:EnableTitleView('VIEW_CAB', 'Informações do cabeçalho')
  oView:EnableTitleView('VIEW_ITE', 'Informações dos itens')

  //Tratativa padrão para fechar a tela
  oView:SetCloseOnOk({||.T.})

  //Remove os campos de Filial e Tabela da ITENS
	/*oStFilho:RemoveField('ZDK_CODIGO')*/

Return oView

User Function FF001LEG()
  Local aLegenda := {}

  //Monta as cores
  AADD(aLegenda,{"GREEN",		"Ativo"  })
  AADD(aLegenda,{"RED",	"Inativo"})
  BrwLegenda(cTitulo, "Status", aLegenda)

Return


Static Function fTdOk(oModel)

  Local lRet    := .T.
  Local nX      := 1
  Local nY      := 1
  Local cQuery  := ""
  Local oCAB    := oModel:GetModel("CAB")
  Local oITEM   := oModel:GetModel("ITEN","ZDK_APROVA")
  Local oAUX    := oITEM
  Local nOpc 		:= oModel:GetOperation()

  Local cCLVLR  := oCAB:GetValue('ZDK_CLVLR')
  Local cCCONTA := oCAB:GetValue('ZDK_CCONTA')
  Local cQry    := GetNextAlias()





  If (nOpc == MODEL_OPERATION_INSERT)

    cQuery += " select ZDK.* from "+RetSQLName("ZDK")+"  ZDK " + CRLF
    cQuery += " WHERE ZDK.D_E_L_E_T_ = '' "  + CRLF
    cQuery += " AND ZDK.ZDK_CLVLR    = '"+AllTrim(cCLVLR)+"' "+ CRLF
    cQuery += " AND ZDK.ZDK_CCONTA   = '"+AllTrim(cCCONTA)+"' "+ CRLF

    TcQuery cQuery New Alias (cQry)

    If !EMPTY((cQry)->ZDK_APROVA)
      Help(NIL, NIL, "Help", NIL, "Já existem dados cadastrados para a classe de valor. <b>"+cCLVLR+"</b> com a conta <b>"+IIf(EMPTY(cCCONTA), "Não Informada.", cCCONTA)+"</b>", 1, 0,,,,,,{""})
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
          If ( (oAUX:IsDeleted(nY) == .F.) .AND. (oITEM:GetValue('ZDK_APROVA', nX) == oAUX:GetValue('ZDK_APROVA',nY)) .AND. (nY != nX) )
            Help(,,'HELP',,"Não é permitido cadastrar o mesmo usuario  mais de uma vez na linha  <b>"+cValToChar(nY)+" - "+oITEM:GetValue('ZDK_APROVA')+"</b>", 1, 0,,,,,,{"Para auxiliar, ordene pela coluna usuário e altere um dos valores duplicados."})
            Return .F.
          EndIf

        Next nY

      EndIf

    Next nX

  EndIf

Return (lRet)
