#include "totvs.ch"
#include "fwmvcdef.ch"

static function MenuDef() as array

    local aRotina as array

    aRotina:=array(0)

    ADD OPTION aRotina TITLE "Pesquisar"        ACTION "PESQBRW"                OPERATION 1                      ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"       ACTION "VIEWDEF.BIA664MVCGRID"  OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Incluir"          ACTION "VIEWDEF.BIA664MVCGRID"  OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Alterar"          ACTION "VIEWDEF.BIA664MVCGRID"  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Excluir"          ACTION "VIEWDEF.BIA664MVCGRID"  OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRotina TITLE "Processar"        ACTION "U_BIA664Proc"           OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Exportar Excel"   ACTION "U_BIA664Excel"          OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

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

    local cLote         as character
    local cSBLote       as character
    local cOriPrc       as character

    local cZBZOrder     as character
    local cFieldsDet    as character

    local nZBZOrder     as numeric

    local oModel        as object
    local oZBZHeader    as object
    local oZBZDetail    as object

    // Cria o objeto do Modelo de Dados
    oModel:=MPFormModel():New("BIA664MVCGRID",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription("BP Consolidado - Atualização Movimentos do Mês")

    // Blocos de codigo do modelo
    bEvalVC:={|oModel,lValid|BIA664TTS(oModel,lValid)}

    bPost:={|oModel|EvalBlock(bEvalVC,oModel,.T.)}
    oModel:bPost:=bPost

    bCommit:={|oModel|EvalBlock(bEvalVC,oModel,.F.)}
    oModel:bCommit:=bCommit

    cFieldsDet:=ZBZFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada no Modelo de Dados
    oZBZHeader:=FWFormStruct(1,"ZBZ",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields("BIA664MVCGRID_HEADER",/*cOwner*/,oZBZHeader,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)

    // Seta a Chave Primaria
    aPK:=GetArrUniqe("ZBZ")
    if (empty(aPK))
        aPK:=strTokArr2("ZBZ_FILIAL+ZBZ_VERSAO+ZBZ_REVISA+ZBZ_ANOREF+ZBZ_ORIPRC","+")
    endif
    oModel:GetModel("BIA664MVCGRID_HEADER"):SetPrimaryKey(aPK)

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA664MVCGRID_HEADER"):SetDescription("Cabecalho :: BP Consolidado - Atualização Movimentos do Mês")

    // Cria a estrutura a ser usada no Modelo de Dados
    oZBZDetail:=FWFormStruct(1,"ZBZ",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona Grid no modelo
    oModel:AddGrid("BIA664MVCGRID_DETAIL","BIA664MVCGRID_HEADER",oZBZDetail,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)
*TODO: Implementar o uso de aCols e aHeader no Grid
*    oModel:GetModel("BIA664MVCGRID_DETAIL"):SetUseOldGrid()

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA664MVCGRID_DETAIL"):SetDescription("Itens :: BP Consolidado - Atualização Movimentos do Mês")

    // Faz o Relacionamento dos arquivos
    aRelation:=array(0)

    cLote:=PadR(left("008000",getSX3Cache("ZBZ_LOTE","X3_TAMANHO")),getSX3Cache("ZBZ_LOTE","X3_TAMANHO"))
    cSBLote:=PadR(left("001",getSX3Cache("ZBZ_SBLOTE","X3_TAMANHO")),getSX3Cache("ZBZ_SBLOTE","X3_TAMANHO"))
    cOriPrc:=PadR(left("MOV.BP",getSX3Cache("ZBZ_ORIPRC","X3_TAMANHO")),getSX3Cache("ZBZ_ORIPRC","X3_TAMANHO"))

    aAdd(aRelation,{"ZBZ_FILIAL","ZBZ_FILIAL"})
    aAdd(aRelation,{"ZBZ_VERSAO","ZBZ_VERSAO"})
    aAdd(aRelation,{"ZBZ_REVISA","ZBZ_REVISA"})
    aAdd(aRelation,{"ZBZ_ANOREF","ZBZ_ANOREF"})
    aAdd(aRelation,{"ZBZ_ORIPRC","'"+cOriPrc+"'"})
    aAdd(aRelation,{"ZBZ_LOTE","'"+cLote+"'"})
    aAdd(aRelation,{"ZBZ_SBLOTE","'"+cSBLote+"'"})

    cZBZOrder:="ZBZ_FILIAL+ZBZ_VERSAO+ZBZ_REVISA+ZBZ_ANOREF+ZBZ_ORIPRC"
    nZBZOrder:=retOrder("ZBZ",cZBZOrder)
    
    oModel:SetRelation("BIA664MVCGRID_DETAIL",@aRelation,ZBZ->(IndexKey(nZBZOrder)))

    // Liga o controle de nao repeticao de linha - LinOk
*    oModel:GetModel("BIA664MVCGRID_DETAIL"):SetUniqueLine({"ZBZ_DOC,ZBZ_LINHA,ZBZ_DC"})

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
    local oZBZHeader    as object
    local oZBZDetail    as object

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    oModel:=FWLoadModel("BIA664MVCGRID")

    // Cria o objeto de View
    oView:=FWFormView():New()
    // Define qual o Modelo de dados sera utilizado
    oView:SetModel(oModel)

    cFieldsDet:=ZBZFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada na View
    oZBZHeader:=FWFormStruct(2,"ZBZ",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField("VIEW_BIA664MVCGRID_HEADER",oZBZHeader,"BIA664MVCGRID_HEADER")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA664MVCGRID_HEADER",30)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA664MVCGRID_HEADER","FORMFIELD_VIEW_BIA664MVCGRID_HEADER")

    // Cria a estrutura a ser usada na View
    oZBZDetail:=FWFormStruct(2,"ZBZ",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona Grid na interface
    oView:AddGrid("VIEW_BIA664MVCGRID_DETAIL",oZBZDetail,"BIA664MVCGRID_DETAIL")

    //Define campo com incremento automatico por Linha
*    oView:AddIncrementField("VIEW_BIA664MVCGRID_DETAIL","")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA664MVCGRID_DETAIL",70)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA664MVCGRID_DETAIL","FORMFIELD_VIEW_BIA664MVCGRID_DETAIL")

    oView:EnableControlBar(.F.)
    oView:lForceSetOwner:=.T.

    return(oView)

static function BIA664TTS(oModel as object,lIsInValid as logical) as logical

    local aSaveRows     as array

    local lBIA664TTS    as logical

    local oSaveModel    as object

    aSaveRows:=FWSaveRows()

    oSaveModel:=FWModelActive(oModel)

    lBIA664TTS:=FWFormCommit(oModel)

    FWModelActive(oSaveModel)

    FWRestRows(aSaveRows)

    return(lBIA664TTS)

static function EvalBlock(bEval as block,xParameter,lShowHelp as logical,cHelp as character,cMsgHelp as character) as logical
    local lEvalBlock as logical
    DEFAULT lShowHelp:=.F.
    DEFAULT cHelp:=""
    DEFAULT cMsgHelp:=""
    lEvalBlock:=evalBlock():EvalBlock(@bEval,@xParameter,@lShowHelp,@cHelp,@cMsgHelp)
    return(lEvalBlock)

static function ZBZFldsDet() as character
    
    local cFields   as character

    cFields:="ZBZ_DOC,ZBZ_LINHA,ZBZ_ORGLAN,ZBZ_DC,ZBZ_DEBITO,ZBZ_CREDIT,ZBZ_CLVLDB,ZBZ_CLVLCR,ZBZ_ITEMD,ZBZ_ITEMC,ZBZ_VALOR,ZBZ_SI,ZBZ_YDELTA,ZBZ_APLIC,ZBZ_DRVDB,ZBZ_DRVCR"

    return(cFields)

static procedure __Dummy()

    if (.F.)
        __Dummy()
        MODELDEF()
        VIEWDEF()
        MENUDEF()
    endif

    return
