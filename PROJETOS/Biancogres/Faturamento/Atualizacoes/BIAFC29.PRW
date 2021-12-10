#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc}   
@description Percentual de Venda Galleria - PROJETO C29
@author FILIPE BITTENCOURT -  FACILE
@since 11/08/2021
@version 1.0
/*/

//Variáveis Estáticas
Static cTitulo  := "Percentual de Venda Galleria"

User Function BIAFC29()

  Local aArea   := GetArea()
  Local oBrowse
  Local cFunBkp := FunName()

  SetFunName("BIAFC29")

  //Instânciando FWMBrowse - Somente com dicionário de dados
  oBrowse := FWMBrowse():New()
  //Setando a tabela de cadastro
  oBrowse:SetAlias("ZNB")

  //Setando a descrição da rotina
  oBrowse:SetDescription(cTitulo)

  //Ativa a Browse
  oBrowse:Activate()

  SetFunName(cFunBkp)
  RestArea(aArea)
Return Nil



Static Function MenuDef()

  Local aRot := {}

  //Adicionando opções
  ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BIAFC29' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
  ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BIAFC29' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
  ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BIAFC29' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
  ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BIAFC29' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()

  //Criação do objeto do modelo de dados

  Local oModel  := Nil

  //Criação da estrutura de dados utilizada na interface
  Local oStZNB := NIL

  oStZNB := FWFormStruct(1, "ZNB", { |x| AllTrim(x) $ "ZNB_MARCA|ZNB_DTINI|ZNB_DTFIM|ZNB_CLIENT|ZNB_LOJA|ZNB_GRUPO|ZNB_REDE|ZNB_PERC"})

  //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
  oModel := MPFormModel():New("BIAFC29M",{|oModel| ZNBbPre(oModel)},{|oModel| fTdOk(oModel)},/*<bCommit >*/,/*bCancel*/)


  //Atribuindo formulários para o modelo
  oModel:AddFields("FORMZNB",/*cOwner*/,oStZNB)

  //Setando a chave primária da rotina
  oModel:SetPrimaryKey({'ZNB_FILIAL','ZNB_MARCA'})

  //Adicionando descrição ao modelo
  oModel:SetDescription(cTitulo)

  //Setando a descrição do formulário
  oModel:GetModel("FORMZNB"):SetDescription(cTitulo)



Return oModel


 /*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Filipe Bittencourt - Facile                                  |
 | Data:  11/08/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
	Local aStruZNB	:= ZNB->(DbStruct())
	
	//Criação do objeto do modelo de dados da Interface do Cadastro
	Local oModel := FWLoadModel("BIAFC29")

	//Criando oView como nulo
	Local oView := Nil

  	//Criação da estrutura de dados utilizada na interface do cadastro
	oStZNB := FWFormStruct(2, "ZNB", { |x| AllTrim(x) $ "ZNB_MARCA|ZNB_DTINI|ZNB_DTFIM|ZNB_CLIENT|ZNB_LOJA|ZNB_GRUPO|ZNB_REDE|ZNB_PERC"})
	

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZNB", oStZNB, "FORMZNB")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	//oView:EnableTitleView('VIEW_ZNB', 'Dados - '+cTitulo )  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZNB","TELA")
Return oView


Static Function ZNBbPre(oModel)
   
  Local lRet       := .T.

  oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_CLIENT',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   ".T."))
  oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_LOJA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".T."))
  oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_GRUPO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".T."))
  oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_REDE',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".T."))

  If !EMPTY(oModel:GetModel('FORMZNB'):GetValue('ZNB_CLIENT')) .OR. !EMPTY(oModel:GetModel('FORMZNB'):GetValue('ZNB_LOJA'))

    oModel:GetModel('FORMZNB'):GetValue('ZNB_GRUPO')   := ""
    oModel:GetModel('FORMZNB'):GetValue('ZNB_REDE')   := ""
    oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_GRUPO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))
    oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_REDE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))

  ElseIf !EMPTY(oModel:GetModel('FORMZNB'):GetValue('ZNB_GRUPO'))

    oModel:GetModel('FORMZNB'):GetValue('ZNB_CLIENT') := ""
    oModel:GetModel('FORMZNB'):GetValue('ZNB_LOJA')   := ""
    oModel:GetModel('FORMZNB'):GetValue('ZNB_REDE')   := ""
    oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_CLIENT',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))
    oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_LOJA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".F."))
    oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_REDE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".F."))

  ElseIf !EMPTY(oModel:GetModel('FORMZNB'):GetValue('ZNB_REDE'))

    oModel:GetModel('FORMZNB'):GetValue('ZNB_CLIENT') := ""
    oModel:GetModel('FORMZNB'):GetValue('ZNB_LOJA')   := ""
    oModel:GetModel('FORMZNB'):GetValue('ZNB_GRUPO')   := ""
    oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_CLIENT',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))
    oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_LOJA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".F."))
    oModel:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_GRUPO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".F."))


  EndIf


Return lRet



Static Function fTdOk(oModel)

  Local lRet   := .T.
  Local lVerify := .F.
  Local cVerify := "Favor informar o cliente , ou grupo , ou a rede."
  Local cQuery := ""
  Local nOpc 	 := oModel:GetOperation()
  Local cMARCA := oModel:GetModel("FORMZNB"):GetValue('ZNB_MARCA')
  Local dDTINI := oModel:GetModel("FORMZNB"):GetValue('ZNB_DTINI')
  Local dDTFIM := oModel:GetModel("FORMZNB"):GetValue('ZNB_DTFIM')
  Local cClient := oModel:GetModel("FORMZNB"):GetValue('ZNB_CLIENT')
  Local cLoja   := oModel:GetModel("FORMZNB"):GetValue('ZNB_LOJA')
  Local cGRupo   := oModel:GetModel("FORMZNB"):GetValue('ZNB_GRUPO')
  Local cRede   := oModel:GetModel("FORMZNB"):GetValue('ZNB_REDE')
  Local cQry   := GetNextAlias()
  
  
  If nOpc != MODEL_OPERATION_DELETE

    If  EMPTY(dDTINI) .OR.EMPTY(dDTFIM)
      Help(,,"Help",,"Favor informar as datas de inicio e fim.", 1, 0,,,,,,{" "})
      RETURN .F.    
    EndIf

    If dDTINI >= dDTFIM
      Help(,,"Help",,"A data inicio deve ser menor ou igual a data fim.", 1, 0,,,,,,{" "})
      RETURN .F.    
    EndIf

    IF !ExistCpo("Z37", cMARCA)
        Help(,,"Help",,"O codigo marca não é válido", 1, 0,,,,,,{" "})
        RETURN .F. 
    EndIf

    If !EMPTY(cClient)
      IF ExistCpo("SA1", cClient + cLoja)
        lVerify := .T. 
      Else
        Help(,,"Help",,"O codigo ou a loja do cliente não são válido.", 1, 0,,,,,,{" "})
        RETURN .F. 
      EndIf
    EndIf


    If !EMPTY(cGRupo) .and. lVerify == .F.
      IF ExistCpo("ACY", cGRupo)
        lVerify := .T. 
      Else
        Help(,,"Help",,"O codigo do grupo não é válido.", 1, 0,,,,,,{" "})
        RETURN .F. 
      EndIf
    EndIf

    If !EMPTY(cRede) .and. lVerify == .F.
      IF ExistCpo("Z79", cRede)
        lVerify := .T. 
      Else
        Help(,,"Help",,"O codigo da rede não é válido.", 1, 0,,,,,,{" "})
        RETURN .F. 
      EndIf
    EndIf

    If !lVerify
      Help(,,"Help",,cVerify, 1, 0,,,,,,{" "})
      RETURN .F. 
    EndIf
  

    cQuery += " select * , R_E_C_N_O_ as RECNO from "+RetSqlName("ZNB")+ " "+  CRLF
    cQuery += " WHERE D_E_L_E_T_ = '' "  + CRLF  
    cQuery += " AND "+ValToSql(dDTINI)+" BETWEEN  ZNB_DTINI AND ZNB_DTFIM " + CRLF
    cQuery += " AND ZNB_MARCA = "+ValToSql(cMARCA)+ " "+ CRLF 
    
    If !Empty(cClient)
      cQuery += " AND ZNB_CLIENT = "+ValToSql(cClient)+ " "+ CRLF
      cQuery += " AND ZNB_LOJA   = "+ValToSql(cLoja)+ " "+ CRLF
    ElseIf !Empty(cGRupo)
      cQuery += " AND ZNB_GRUPO   = "+ValToSql(cGRupo)+ " "+ CRLF
    Else
      cQuery += " AND ZNB_REDE   = "+ValToSql(cRede)+ " "+ CRLF
    EndIf

    If nOpc == MODEL_OPERATION_UPDATE
     cQuery += " AND R_E_C_N_O_  <> "+cValToChar(ZNB->(Recno()))+ CRLF
    EndIf

    TcQuery cQuery New Alias (cQry)

    If !EMPTY((cQry)->ZNB_MARCA)
      lRet := .F.
      Help(NIL, NIL, "Help", NIL, "Já existe dados cadastrados com essas informações.", 1, 0,,,,,,{"Mude as datas de inicio e fim, para prosseguir."})
    EndIf

  EndIf

Return (lRet)
