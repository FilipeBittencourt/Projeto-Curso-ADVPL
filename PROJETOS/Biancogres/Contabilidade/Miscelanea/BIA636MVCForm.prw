#include "totvs.ch"
#include "fwmvcdef.ch"

static function MenuDef() as array

    local aRotina as array

    aRotina:=array(0)

    ADD OPTION aRotina TITLE "Pesquisar"        ACTION "PESQBRW"                OPERATION 1                      ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"       ACTION "VIEWDEF.BIA636MVCFORM"  OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Incluir"          ACTION "VIEWDEF.BIA636MVCFORM"  OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Alterar"          ACTION "VIEWDEF.BIA636MVCFORM"  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Excluir"          ACTION "VIEWDEF.BIA636MVCFORM"  OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRotina TITLE "Processar"        ACTION "U_BIA636Proc"           OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Exportar Excel"   ACTION "U_BIA636Excel"          OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

    return(aRotina)

static function ModelDef() as object

    local aPK           as array

    local bPost         as block
    local bCommit       as block
    local bEvalVC       as block
    local bVldActivate  as block

    local oModel        as object
    local oZODHeader    as object

    // Cria o objeto do Modelo de Dados
    oModel:=MPFormModel():New("BIA636MVCFORM",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription("Consolidado - BP Real (MesRef)")

    // Blocos de codigo do modelo
    bEvalVC:={|oModel,lValid|BIA636TTS(oModel,lValid)}

    bPost:={|oModel|EvalBlock(bEvalVC,oModel,.T.)}
    oModel:bPost:=bPost

    bCommit:={|oModel|EvalBlock(bEvalVC,oModel,.F.)}
    oModel:bCommit:=bCommit

    // Cria a estrutura a ser usada no Modelo de Dados
    oZODHeader:=FWFormStruct(1,"ZOD",{||.T.}/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields("BIA636MVCFORM_HEADER",/*cOwner*/,oZODHeader,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)

    // Seta a Chave Primaria
    aPK:=GetArrUniqe("ZOD")
    if (empty(aPK))
        aPK:=strTokArr2("ZOD_FILIAL+ZOD_VERSAO+ZOD_REVISA+ZOD_ANOREF+ZOD_TIPO+DTOS(ZOD_DTREF)+ZOD_CONTA","+")
    endif
    oModel:GetModel("BIA636MVCFORM_HEADER"):SetPrimaryKey(aPK)

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA636MVCFORM_HEADER"):SetDescription("Consolidado - BP Real (MesRef)")

    bVldActivate:=oModel:bVldActivate
    oModel:bVldActivate:={|oObj|EvalBlock(@bVldActivate,@oObj,.F.,"ERROR_ONACTIVATE","ERROR_ONACTIVATE"),.T.}

    return(oModel)

static function ViewDef() as object

    local oView         as object
    local oModel        as object
    local oZODHeader    as object

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    oModel:=FWLoadModel("BIA636MVCFORM")

    // Cria o objeto de View
    oView:=FWFormView():New()
    // Define qual o Modelo de dados sera utilizado
    oView:SetModel(oModel)

    // Cria a estrutura a ser usada na View
    oZODHeader:=FWFormStruct(2,"ZOD",{||.T.}/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField("VIEW_BIA636MVCFORM_HEADER",oZODHeader,"BIA636MVCFORM_HEADER")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA636MVCFORM_HEADER",100)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA636MVCFORM_HEADER","FORMFIELD_VIEW_BIA636MVCFORM_HEADER")

    oView:EnableControlBar(.F.)
    oView:lForceSetOwner:=.T.

    return(oView)

static function BIA636TTS(oModel as object,lIsInValid as logical) as logical

    local aSaveRows     as array

    local lBIA636TTS    as logical

    local oSaveModel    as object

    aSaveRows:=FWSaveRows()

    oSaveModel:=FWModelActive(oModel)

    lBIA636TTS:=FWFormCommit(oModel)

    FWModelActive(oSaveModel)

    FWRestRows(aSaveRows)

    return(lBIA636TTS)

static function EvalBlock(bEval as block,xParameter,lShowHelp as logical,cHelp as character,cMsgHelp as character) as logical
    local lEvalBlock as logical
    DEFAULT lShowHelp:=.F.
    DEFAULT cHelp:=""
    DEFAULT cMsgHelp:=""
    lEvalBlock:=evalBlock():EvalBlock(@bEval,@xParameter,@lShowHelp,@cHelp,@cMsgHelp)
    return(lEvalBlock)

static procedure __Dummy()

    if (.F.)
        __Dummy()
        MODELDEF()
        VIEWDEF()
        MENUDEF()
    endif

    return
