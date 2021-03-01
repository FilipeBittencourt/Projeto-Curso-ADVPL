#include "totvs.ch"
#include "fwmvcdef.ch"

static function MenuDef() as array

    local aRotina as array

    aRotina:=array(0)

    ADD OPTION aRotina TITLE "Pesquisar"        ACTION "PESQBRW"             OPERATION 1                      ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"       ACTION "VIEWDEF.BIA661MVC"   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Incluir"          ACTION "VIEWDEF.BIA661MVC"   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Alterar"          ACTION "VIEWDEF.BIA661MVC"   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Excluir"          ACTION "VIEWDEF.BIA661MVC"   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRotina TITLE "Processar"        ACTION "U_BIA661Proc"        OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Exportar Excel"   ACTION "U_BIA661Excel"       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

    return(aRotina)

static function ModelDef() as object

    local aPK           as array
    local aRelation     as array
    local aFieldsDet    as array

    local bPost         as block
    local bCommit       as block
    local bEvalVC       as block
    local bHeader       as block
    local bDetail       as block 
    local bVldActivate  as block

    local cZOFOrder     as character
    local cFieldsDet    as character

    local nZOFOrder     as numeric

    local oModel        as object
    local oZOFHeader    as object
    local oZOFDetail    as object

    // Cria o objeto do Modelo de Dados
    oModel:=MPFormModel():New("BIA661MVC",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription("Consolidado - Previsão de contas a receber")

    // Blocos de codigo do modelo
    bEvalVC:={|oModel,lValid|BIA661TTS(oModel,lValid)}

    bPost:={|oModel|EvalBlock(bEvalVC,oModel,.T.)}
    oModel:bPost:=bPost

    bCommit:={|oModel|EvalBlock(bEvalVC,oModel,.F.)}
    oModel:bCommit:=bCommit

    cFieldsDet:=ZOFFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada no Modelo de Dados
    oZOFHeader:=FWFormStruct(1,"ZOF",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields("BIA661MVC_HEADER",/*cOwner*/,oZOFHeader,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)

    // Seta a Chave Primaria
    aPK:=GetArrUniqe("ZOF")
    if (empty(aPK))
        aPK:=strTokArr2("ZOF_FILIAL+ZOF_VERSAO+ZOF_REVISA+ZOF_ANOREF+ZOF_TIPO+ZOF_INDICA","+")
    endif
    oModel:GetModel("BIA661MVC_HEADER"):SetPrimaryKey(aPK)

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA661MVC_HEADER"):SetDescription("Cabecalho :: Consolidado - Previsão de contas a receber")

    // Cria a estrutura a ser usada no Modelo de Dados
    oZOFDetail:=FWFormStruct(1,"ZOF",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona Grid no modelo
    oModel:AddGrid("BIA661MVC_DETAIL","BIA661MVC_HEADER",oZOFDetail,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)
*TODO: Implementar o uso de aCols e aHeader no Grid
*    oModel:GetModel("BIA661MVC_DETAIL"):SetUseOldGrid()

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA661MVC_DETAIL"):SetDescription("Itens :: Consolidado - Previsão de contas a receber")

    // Faz o Relacionamento dos arquivos
    aRelation:=array(0)

    aAdd(aRelation,{"ZOF_FILIAL","ZOF_FILIAL"})
    aAdd(aRelation,{"ZOF_VERSAO","ZOF_VERSAO"})
    aAdd(aRelation,{"ZOF_REVISA","ZOF_REVISA"})
    aAdd(aRelation,{"ZOF_ANOREF","ZOF_ANOREF"})
    aAdd(aRelation,{"ZOF_TIPO","ZOF_TIPO"})

    cZOFOrder:="ZOF_FILIAL+ZOF_VERSAO+ZOF_REVISA+ZOF_ANOREF+ZOF_TIPO+ZOF_INDICA"
    nZOFOrder:=retOrder("ZOF",cZOFOrder)
    
    oModel:SetRelation("BIA661MVC_DETAIL",@aRelation,ZOF->(IndexKey(nZOFOrder)))

    // Liga o controle de nao repeticao de linha - LinOk
    oModel:GetModel("BIA661MVC_DETAIL"):SetUniqueLine({"ZOF_INDICA"})

    bVldActivate:=oModel:bVldActivate
    oModel:bVldActivate:={|oObj|EvalBlock(@bVldActivate,@oObj,.F.,"ERROR_ONACTIVATE","ERROR_ONACTIVATE"),.T.}

    return(oModel)

static function ViewDef() as object

    local aFieldsDet    as array

    local bHeader       as block
    local bDetail       as block

    local cFieldsDet     as character

    local oView         as object
    local oModel        as object
    local oZOFHeader    as object
    local oZOFDetail    as object

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    oModel:=FWLoadModel("BIA661MVC")

    // Cria o objeto de View
    oView:=FWFormView():New()
    // Define qual o Modelo de dados sera utilizado
    oView:SetModel(oModel)

    cFieldsDet:=ZOFFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada na View
    oZOFHeader:=FWFormStruct(2,"ZOF",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField("VIEW_BIA661MVC_HEADER",oZOFHeader,"BIA661MVC_HEADER")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA661MVC_HEADER",20)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA661MVC_HEADER","FORMFIELD_VIEW_BIA661MVC_HEADER")

    // Cria a estrutura a ser usada na View
    oZOFDetail:=FWFormStruct(2,"ZOF",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona Grid na interface
    oView:AddGrid("VIEW_BIA661MVC_DETAIL",oZOFDetail,"BIA661MVC_DETAIL")

    //Define campo com incremento automatico por Linha
*    oView:AddIncrementField("VIEW_BIA661MVC_DETAIL","")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA661MVC_DETAIL",80)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA661MVC_DETAIL","FORMFIELD_VIEW_BIA661MVC_DETAIL")

    oView:EnableControlBar(.F.)
    oView:lForceSetOwner:=.T.

    return(oView)

static function BIA661TTS(oModel as object,lIsInValid as logical) as logical

    local aSaveRows     as array

    local lBIA661TTS     as logical

    local oSaveModel    as object

    aSaveRows:=FWSaveRows()

    oSaveModel:=FWModelActive(oModel)

    lBIA661TTS:=FWFormCommit(oModel)

    FWModelActive(oSaveModel)

    FWRestRows(aSaveRows)

    return(lBIA661TTS)


static function EvalBlock(bEval as block,xParameter,lShowHelp as logical,cHelp as character,cMsgHelp as character) as logical
    local lEvalBlock as logical
    DEFAULT lShowHelp:=.F.
    DEFAULT cHelp:=""
    DEFAULT cMsgHelp:=""
    lEvalBlock:=evalBlock():EvalBlock(@bEval,@xParameter,@lShowHelp,@cHelp,@cMsgHelp)
    return(lEvalBlock)

static function ZOFFldsDet() as character
    
    local cFields   as character

    local nField    as numeric

    cFields:="ZOF_INDICA,"
    for nField:=1 to 12
        cFields+="ZOF_MES"+strZero(nField,2)
        cFields+=","
    next nField

    cFields:=subStr(cFields,1,len(cFields)-1)

    return(cFields)

static procedure __Dummy()

    if (.F.)
        __Dummy()
        MODELDEF()
        VIEWDEF()
        MENUDEF()
    endif

    return
