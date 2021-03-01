#include "totvs.ch"
#include "fwmvcdef.ch"

static function MenuDef() as array

    local aRotina as array

    aRotina:=array(0)

    ADD OPTION aRotina TITLE "Pesquisar"            ACTION "PESQBRW"             OPERATION 1                      ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"           ACTION "VIEWDEF.BIA663MVC"   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Incluir"              ACTION "VIEWDEF.BIA663MVC"   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.BIA663MVC"   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.BIA663MVC"   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRotina TITLE "Processar Calculo"    ACTION "U_BIA663Calc"        OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Exportar Excel"       ACTION "U_BIA663Excel"       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

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

    local cZOHOrder     as character
    local cFieldsDet    as character

    local nZOHOrder     as numeric

    local oModel        as object
    local oZOHHeader    as object
    local oZOHDetail    as object

    // Cria o objeto do Modelo de Dados
    oModel:=MPFormModel():New("BIA663MVC",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription("BP - Cálculo Rubricas")

    // Blocos de codigo do modelo
    bEvalVC:={|oModel,lValid|BIA663TTS(oModel,lValid)}

    bPost:={|oModel|EvalBlock(bEvalVC,oModel,.T.)}
    oModel:bPost:=bPost

    bCommit:={|oModel|EvalBlock(bEvalVC,oModel,.F.)}
    oModel:bCommit:=bCommit

    cFieldsDet:=ZOHFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada no Modelo de Dados
    oZOHHeader:=FWFormStruct(1,"ZOH",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields("BIA663MVC_HEADER",/*cOwner*/,oZOHHeader,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)

    // Seta a Chave Primaria
    aPK:=GetArrUniqe("ZOH")
    if (empty(aPK))
        aPK:=strTokArr2("ZOH_FILIAL+ZOH_VERSAO+ZOH_REVISA+ZOH_ANOREF+ZOH_CONTA","+")
    endif
    oModel:GetModel("BIA663MVC_HEADER"):SetPrimaryKey(aPK)

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA663MVC_HEADER"):SetDescription("Cabecalho :: BP - Cálculo Rubricas")

    // Cria a estrutura a ser usada no Modelo de Dados
    oZOHDetail:=FWFormStruct(1,"ZOH",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona Grid no modelo
    oModel:AddGrid("BIA663MVC_DETAIL","BIA663MVC_HEADER",oZOHDetail,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)
*TODO: Implementar o uso de aCols e aHeader no Grid
*    oModel:GetModel("BIA663MVC_DETAIL"):SetUseOldGrid()
     // Desabilita a Inserção de Linhas na Grid
     oModel:GetModel("BIA663MVC_DETAIL"):SetNoInsertLine()
     // Desabilita a Deleção de Linhas na Grid
     oModel:GetModel("BIA663MVC_DETAIL"):SetNoDeleteLine()

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA663MVC_DETAIL"):SetDescription("Itens :: BP - Cálculo Rubricas")

    // Faz o Relacionamento dos arquivos
    aRelation:=array(0)

    aAdd(aRelation,{"ZOH_FILIAL","ZOH_FILIAL"})
    aAdd(aRelation,{"ZOH_VERSAO","ZOH_VERSAO"})
    aAdd(aRelation,{"ZOH_REVISA","ZOH_REVISA"})
    aAdd(aRelation,{"ZOH_ANOREF","ZOH_ANOREF"})

    cZOHOrder:="ZOH_FILIAL+ZOH_VERSAO+ZOH_REVISA+ZOH_ANOREF+ZOH_CONTA"
    nZOHOrder:=retOrder("ZOH",cZOHOrder)
    
    oModel:SetRelation("BIA663MVC_DETAIL",@aRelation,ZOH->(IndexKey(nZOHOrder)))

    // Liga o controle de nao repeticao de linha - LinOk
    oModel:GetModel("BIA663MVC_DETAIL"):SetUniqueLine({"ZOH_CONTA"})

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
    local oZOHHeader    as object
    local oZOHDetail    as object

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    oModel:=FWLoadModel("BIA663MVC")

    // Cria o objeto de View
    oView:=FWFormView():New()
    // Define qual o Modelo de dados sera utilizado
    oView:SetModel(oModel)

    cFieldsDet:=ZOHFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada na View
    oZOHHeader:=FWFormStruct(2,"ZOH",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField("VIEW_BIA663MVC_HEADER",oZOHHeader,"BIA663MVC_HEADER")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA663MVC_HEADER",20)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA663MVC_HEADER","FORMFIELD_VIEW_BIA663MVC_HEADER")

    // Cria a estrutura a ser usada na View
    oZOHDetail:=FWFormStruct(2,"ZOH",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona Grid na interface
    oView:AddGrid("VIEW_BIA663MVC_DETAIL",oZOHDetail,"BIA663MVC_DETAIL")

    //Define campo com incremento automatico por Linha
*    oView:AddIncrementField("VIEW_BIA663MVC_DETAIL","")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA663MVC_DETAIL",80)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA663MVC_DETAIL","FORMFIELD_VIEW_BIA663MVC_DETAIL")

    oView:EnableControlBar(.F.)
    oView:lForceSetOwner:=.T.

    return(oView)

static function BIA663TTS(oModel as object,lIsInValid as logical) as logical

    local aSaveRows     as array

    local lBIA663TTS    as logical

    local oSaveModel    as object

    aSaveRows:=FWSaveRows()

    oSaveModel:=FWModelActive(oModel)

    lBIA663TTS:=FWFormCommit(oModel)

    FWModelActive(oSaveModel)

    FWRestRows(aSaveRows)

    return(lBIA663TTS)

static function EvalBlock(bEval as block,xParameter,lShowHelp as logical,cHelp as character,cMsgHelp as character) as logical
    local lEvalBlock as logical
    DEFAULT lShowHelp:=.F.
    DEFAULT cHelp:=""
    DEFAULT cMsgHelp:=""
    lEvalBlock:=evalBlock():EvalBlock(@bEval,@xParameter,@lShowHelp,@cHelp,@cMsgHelp)
    return(lEvalBlock)

static function ZOHFldsDet() as character
    
    local cFields   as character

    local nField    as numeric

    cFields:="ZOH_CONTA,"
    cFields+="ZOH_DESC,"
    cFields+="ZOH_TOTAL,"
    for nField:=1 to 12
        cFields+="ZOH_MES"+strZero(nField,2)
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
