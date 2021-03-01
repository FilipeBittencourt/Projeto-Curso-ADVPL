#include "totvs.ch"
#include "fwmvcdef.ch"

static function MenuDef() as array

    local aRotina as array

    aRotina:=array(0)

    ADD OPTION aRotina TITLE "Pesquisar"        ACTION "PESQBRW"                OPERATION 1                      ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"       ACTION "VIEWDEF.BIA636MVCGRID"  OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Incluir"          ACTION "VIEWDEF.BIA636MVCGRID"  OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Alterar"          ACTION "VIEWDEF.BIA636MVCGRID"  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Excluir"          ACTION "VIEWDEF.BIA636MVCGRID"  OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRotina TITLE "Processar"        ACTION "U_BIA636Proc"           OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Exportar Excel"   ACTION "U_BIA636Excel"          OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

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

    local cZODOrder     as character
    local cFieldsDet    as character

    local nZODOrder     as numeric

    local oModel        as object
    local oZODHeader    as object
    local oZODDetail    as object

    // Cria o objeto do Modelo de Dados
    oModel:=MPFormModel():New("BIA636MVCGRID",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription("Consolidado - BP Real (MesRef)")

    // Blocos de codigo do modelo
    bEvalVC:={|oModel,lValid|BIA636TTS(oModel,lValid)}

    bPost:={|oModel|EvalBlock(bEvalVC,oModel,.T.)}
    oModel:bPost:=bPost

    bCommit:={|oModel|EvalBlock(bEvalVC,oModel,.F.)}
    oModel:bCommit:=bCommit

    cFieldsDet:=ZODFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada no Modelo de Dados
    oZODHeader:=FWFormStruct(1,"ZOD",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields("BIA636MVCGRID_HEADER",/*cOwner*/,oZODHeader,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)

    // Seta a Chave Primaria
    aPK:=GetArrUniqe("ZOD")
    if (empty(aPK))
        aPK:=strTokArr2("ZOD_FILIAL+ZOD_VERSAO+ZOD_REVISA+ZOD_ANOREF+ZOD_TIPO+DTOS(ZOD_DTREF)+ZOD_CONTA","+")
    endif
    oModel:GetModel("BIA636MVCGRID_HEADER"):SetPrimaryKey(aPK)

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA636MVCGRID_HEADER"):SetDescription("Cabecalho :: Consolidado - BP Real (MesRef)")

    // Cria a estrutura a ser usada no Modelo de Dados
    oZODDetail:=FWFormStruct(1,"ZOD",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona Grid no modelo
    oModel:AddGrid("BIA636MVCGRID_DETAIL","BIA636MVCGRID_HEADER",oZODDetail,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)
*TODO: Implementar o uso de aCols e aHeader no Grid
*    oModel:GetModel("BIA636MVCGRID_DETAIL"):SetUseOldGrid()

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA636MVCGRID_DETAIL"):SetDescription("Itens :: Consolidado - BP Real (MesRef)")

    // Faz o Relacionamento dos arquivos
    aRelation:=array(0)

    aAdd(aRelation,{"ZOD_FILIAL","ZOD_FILIAL"})
    aAdd(aRelation,{"ZOD_VERSAO","ZOD_VERSAO"})
    aAdd(aRelation,{"ZOD_REVISA","ZOD_REVISA"})
    aAdd(aRelation,{"ZOD_ANOREF","ZOD_ANOREF"})
    aAdd(aRelation,{"ZOD_TIPO","'2'"})

    cZODOrder:="ZOD_FILIAL+ZOD_VERSAO+ZOD_REVISA+ZOD_ANOREF+ZOD_TIPO+DTOS(ZOD_DTREF)+ZOD_CONTA"
    nZODOrder:=retOrder("ZOD",cZODOrder)
    
    oModel:SetRelation("BIA636MVCGRID_DETAIL",@aRelation,ZOD->(IndexKey(nZODOrder)))

    // Liga o controle de nao repeticao de linha - LinOk
    oModel:GetModel("BIA636MVCGRID_DETAIL"):SetUniqueLine({"ZOD_CONTA"})

    bVldActivate:=oModel:bVldActivate
    oModel:bVldActivate:={|oObj|EvalBlock(@bVldActivate,@oObj,.F.,"ERROR_ONACTIVATE","ERROR_ONACTIVATE"),.T.}

    return(oModel)

static function ViewDef() as object

    local aFieldsDet    as array

    local bHeader       as block
    local bDetail       as block

    local cFieldsDet    as character

    local oView         as object
    local oModel        as object
    local oZODHeader    as object
    local oZODDetail    as object

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    oModel:=FWLoadModel("BIA636MVCGRID")

    // Cria o objeto de View
    oView:=FWFormView():New()
    // Define qual o Modelo de dados sera utilizado
    oView:SetModel(oModel)

    cFieldsDet:=ZODFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada na View
    oZODHeader:=FWFormStruct(2,"ZOD",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField("VIEW_BIA636MVCGRID_HEADER",oZODHeader,"BIA636MVCGRID_HEADER")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA636MVCGRID_HEADER",30)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA636MVCGRID_HEADER","FORMFIELD_VIEW_BIA636MVCGRID_HEADER")

    // Cria a estrutura a ser usada na View
    oZODDetail:=FWFormStruct(2,"ZOD",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona Grid na interface
    oView:AddGrid("VIEW_BIA636MVCGRID_DETAIL",oZODDetail,"BIA636MVCGRID_DETAIL")

    //Define campo com incremento automatico por Linha
*    oView:AddIncrementField("VIEW_BIA636MVCGRID_DETAIL","")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA636MVCGRID_DETAIL",70)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA636MVCGRID_DETAIL","FORMFIELD_VIEW_BIA636MVCGRID_DETAIL")

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

static function ZODFldsDet() as character
    
    local cFields   as character

    cFields:="ZOD_CONTA,ZOD_SALCTA"

    return(cFields)

static procedure __Dummy()

    if (.F.)
        __Dummy()
        MODELDEF()
        VIEWDEF()
        MENUDEF()
    endif

    return
