#include "totvs.ch"
#include "fwmvcdef.ch"
class tBIA662MVC from FWRestModel

    method new() constructor

    method Activate()
    method DeActivate()
    method OnError()

    method SetModel()
    method ClearModel()
    method SetName()
    method GetName()
    method SetAsXml()
    method SetAsJson()

    method StartGetFormat()
    method EscapeGetFormat()
    method EndGetFormat()

    method SetAlias()
    method GetAlias()
    method HasAlias()
    method Seek()
    method Skip()
    method Total()
    method GetData()
    method SaveData()
    method DelData()

    method SetFilter()
    method GetFilter()
    method ClearFilter()
    method DecodePK()
    method ConvertPK()

    method GetStatusResponse()
    method SetStatusResponse()

    method SetQueryString()
    method GetQueryString()
    method GetQSValue()
    method GetHttpHeader()
    method SetFields()
    method debuger()

endclass

method new() class tBIA662MVC
    _Super:New()
    return

method Activate() class tBIA662MVC
    if (_Super:Activate())
        self:lActivate:=.T.
    endif
    return(self:lActivate)

method DeActivate() class tBIA662MVC
    return(_Super:DeActivate())

method OnError() class tBIA662MVC
    return(_Super:OnError())

method SetModel(oModel) class tBIA662MVC
    return(_Super:SetModel(@oModel))

method ClearModel() class tBIA662MVC
    return(_Super:ClearModel())

method SetName(cName) class tBIA662MVC
    return(_Super:SetName(@cName))

method GetName() class tBIA662MVC
    return(_Super:GetName())

method SetAsXml() class tBIA662MVC
    return(_Super:SetAsXml())

method SetAsJson() class tBIA662MVC
    return(_Super:SetAsJson())

method StartGetFormat(nTotal,nCount,nStartIndex) class tBIA662MVC
    return(_Super:StartGetFormat(@nTotal,@nCount,@nStartIndex))

method EscapeGetFormat() class tBIA662MVC
    return(_Super:EscapeGetFormat())

method EndGetFormat() class tBIA662MVC
    return(_Super:EndGetFormat())

method SetAlias(cAlias) class tBIA662MVC
    return(_Super:SetAlias(cAlias))

method GetAlias() class tBIA662MVC
    return(_Super:GetAlias())

method HasAlias() class tBIA662MVC
    return(_Super:HasAlias())

method Seek(cPK) class tBIA662MVC
    return(_Super:Seek(@cPK))

method Skip(nSkip) class tBIA662MVC
    return(_Super:Skip(@nSkip))

method Total() class tBIA662MVC
    return(_Super:Total())

method GetData(lFieldDetail,lFieldVirtual,lFieldEmpty,lFirstLevel,lInternalID) class tBIA662MVC
    return(_Super:GetData(@lFieldDetail,@lFieldVirtual,@lFieldEmpty,@lFirstLevel,@lInternalID))

method SaveData(cPK,cData,cError) class tBIA662MVC
    return(_Super:SaveData(@cPK,@cData,@cError))

method DelData(cPK,cError) class tBIA662MVC
    return(_Super:DelData(@cPK,@cError))

method SetFilter(cFilter) class tBIA662MVC
    return(_Super:SetFilter(cFilter))

method GetFilter() class tBIA662MVC
    return(_Super:GetFilter())

method ClearFilter() class tBIA662MVC
    return(_Super:ClearFilter())

method DecodePK() class tBIA662MVC
    return(_Super:DecodePK())

method ConvertPK(cPK) class tBIA662MVC
    return(_Super:ConvertPK(@cPK))

method GetStatusResponse() class tBIA662MVC
    return(_Super:GetStatusResponse())

method SetStatusResponse(nStatus,cStatus) class tBIA662MVC
    return(_Super:SetStatusResponse(@nStatus,@cStatus))

method SetQueryString(aQueryString) class tBIA662MVC
    return(_Super:SetQueryString(@aQueryString))

method GetQueryString() class tBIA662MVC
    return(_Super:GetQueryString())

method GetQSValue(cKey) class tBIA662MVC
    return(_Super:GetQSValue(@cKey))

method GetHttpHeader(cParam) class tBIA662MVC
    return(_Super:GetHttpHeader(@cParam))

method SetFields(aFields) class tBIA662MVC
    return(_Super:SetFields(@aFields))

method debuger(lDebug) class tBIA662MVC
    return(_Super:debuger(@lDebug))

static function MenuDef() as array

    local aRotina as array

    aRotina:=array(0)

    ADD OPTION aRotina TITLE "Pesquisar"            ACTION "PESQBRW"             OPERATION 1                      ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"           ACTION "VIEWDEF.BIA662MVC"   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Incluir"              ACTION "VIEWDEF.BIA662MVC"   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.BIA662MVC"   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.BIA662MVC"   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRotina TITLE "Carregar Rubricas"    ACTION "U_BIA662Load"        OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Exportar Excel"       ACTION "U_BIA662Excel"       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Processar Calculo"    ACTION "U_BIA663Calc"        OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Consultar Calculo"    ACTION "U_BIA663"            OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

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

    local cZOGOrder     as character
    local cFieldsDet    as character

    local nZOGOrder     as numeric

    local oModel        as object
    local oZOGHeader    as object
    local oZOGDetail    as object

    // Cria o objeto do Modelo de Dados
    oModel:=MPFormModel():New("BIA662MVC",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription("BP - Regra de Cálculo")

    // Blocos de codigo do modelo
    bEvalVC:={|oModel,lValid|BIA662TTS(oModel,lValid)}

    bPost:={|oModel|EvalBlock(bEvalVC,oModel,.T.)}
    oModel:bPost:=bPost

    bCommit:={|oModel|EvalBlock(bEvalVC,oModel,.F.)}
    oModel:bCommit:=bCommit

    cFieldsDet:=ZOGFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada no Modelo de Dados
    oZOGHeader:=FWFormStruct(1,"ZOG",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields("BIA662MVC_HEADER",/*cOwner*/,oZOGHeader,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)

    // Seta a Chave Primaria
    aPK:=GetArrUniqe("ZOG")
    if (empty(aPK))
        aPK:=strTokArr2("ZOG_FILIAL+ZOG_VERSAO+ZOG_REVISA+ZOG_ANOREF+ZOG_CONTA+ZOG_MNEMON","+")
    endif
    oModel:GetModel("BIA662MVC_HEADER"):SetPrimaryKey(aPK)

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA662MVC_HEADER"):SetDescription("Cabecalho :: BP - Regra de Cálculo")

    // Cria a estrutura a ser usada no Modelo de Dados
    oZOGDetail:=FWFormStruct(1,"ZOG",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    // Adiciona Grid no modelo
    oModel:AddGrid("BIA662MVC_DETAIL","BIA662MVC_HEADER",oZOGDetail,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)
*TODO: Implementar o uso de aCols e aHeader no Grid
*    oModel:GetModel("BIA662MVC_DETAIL"):SetUseOldGrid()
     // Desabilita a Inserção de Linhas na Grid
     oModel:GetModel("BIA662MVC_DETAIL"):SetNoInsertLine()
     // Desabilita a Deleção de Linhas na Grid
     oModel:GetModel("BIA662MVC_DETAIL"):SetNoDeleteLine()

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BIA662MVC_DETAIL"):SetDescription("Itens :: BP - Regra de Cálculo")

    // Faz o Relacionamento dos arquivos
    aRelation:=array(0)

    aAdd(aRelation,{"ZOG_FILIAL","ZOG_FILIAL"})
    aAdd(aRelation,{"ZOG_VERSAO","ZOG_VERSAO"})
    aAdd(aRelation,{"ZOG_REVISA","ZOG_REVISA"})
    aAdd(aRelation,{"ZOG_ANOREF","ZOG_ANOREF"})
    aAdd(aRelation,{"ZOG_CONTA","ZOG_CONTA"})
    aAdd(aRelation,{"ZOG_MNEMON","ZOG_MNEMON"})

    cZOGOrder:="ZOG_FILIAL+ZOG_VERSAO+ZOG_REVISA+ZOG_ANOREF+ZOG_CONTA+ZOG_MNEMON"
    nZOGOrder:=retOrder("ZOG",cZOGOrder)
    
    oModel:SetRelation("BIA662MVC_DETAIL",@aRelation,ZOG->(IndexKey(nZOGOrder)))

    // Liga o controle de nao repeticao de linha - LinOk
*    oModel:GetModel("BIA662MVC_DETAIL"):SetUniqueLine({""})

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
    local oZOGHeader    as object
    local oZOGDetail    as object

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    oModel:=FWLoadModel("BIA662MVC")

    // Cria o objeto de View
    oView:=FWFormView():New()
    // Define qual o Modelo de dados sera utilizado
    oView:SetModel(oModel)

    cFieldsDet:=ZOGFldsDet()
    aFieldsDet:=StrToKArr2(cFieldsDet,",")
    bHeader:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})==0))}
    bDetail:={|cField|(cFieldsDet:=Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)})>0))}

    // Cria a estrutura a ser usada na View
    oZOGHeader:=FWFormStruct(2,"ZOG",bHeader/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField("VIEW_BIA662MVC_HEADER",oZOGHeader,"BIA662MVC_HEADER")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA662MVC_HEADER",40)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA662MVC_HEADER","FORMFIELD_VIEW_BIA662MVC_HEADER")

    // Cria a estrutura a ser usada na View
    oZOGDetail:=FWFormStruct(2,"ZOG",bDetail/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona Grid na interface
    oView:AddGrid("VIEW_BIA662MVC_DETAIL",oZOGDetail,"BIA662MVC_DETAIL")

    //Define campo com incremento automatico por Linha
*    oView:AddIncrementField("VIEW_BIA662MVC_DETAIL","")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BIA662MVC_DETAIL",60)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BIA662MVC_DETAIL","FORMFIELD_VIEW_BIA662MVC_DETAIL")

    oView:EnableControlBar(.F.)
    oView:lForceSetOwner:=.T.

    return(oView)

static function BIA662TTS(oModel as object,lIsInValid as logical) as logical

    local aSaveRows     as array

    local lBIA662TTS    as logical

    local oSaveModel    as object

    aSaveRows:=FWSaveRows()

    oSaveModel:=FWModelActive(oModel)

    lBIA662TTS:=FWFormCommit(oModel)

    FWModelActive(oSaveModel)

    FWRestRows(aSaveRows)

    return(lBIA662TTS)

function u_BIA662MVC()
    local aParameter    as array
    local xRet
    begin sequence
        if (!type("ParamIXB")=="A")
            break
        endif
        aParameter:=&("ParamIXB")
        xRet:=BIA662MVC(aParameter)
    end sequence
    DEFAULT xRet:=.T.
    return(xRet)

static function BIA662MVC(aParameter as array)

    local cIdPonto      as character
    local cIdModel      as character

    local nOperation    as numeric

    local oObj          as object

    local xRet

    begin sequence

        oObj:=aParameter[1]
        cIdPonto:=aParameter[2]
        cIdModel:=aParameter[3]

        if (cIdPonto=="MODELPOS")
            nOperation:=oObj:GetOperation()
            if (nOperation==5)
                break
            endif
            xRet:=.T.
            break
        endif

        if (cIdPonto=="FORMPOS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="FORMLINEPRE")
            if ((len(aParameter)>=5).and.(aParameter[5]=="DELETE"))
                xRet:=.T.
            endif
            break
        endif

        if (cIdPonto=="FORMLINEPOS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="MODELCOMMITTTS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="MODELCOMMITNTTS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="FORMCOMMITTTSPRE")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="FORMCOMMITTTSPOS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="MODELCANCEL")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="BUTTONBAR")
            xRet:=array(0)
            break
        endif

    end sequence

    return(xRet)

static function EvalBlock(bEval as block,xParameter,lShowHelp as logical,cHelp as character,cMsgHelp as character) as logical
    local lEvalBlock as logical
    DEFAULT lShowHelp:=.F.
    DEFAULT cHelp:=""
    DEFAULT cMsgHelp:=""
    lEvalBlock:=evalBlock():EvalBlock(@bEval,@xParameter,@lShowHelp,@cHelp,@cMsgHelp)
    return(lEvalBlock)

static function ZOGFldsDet() as character
    
    local cFields   as character

    local nField    as numeric

    cFields:="ZOG_TOTAL,"
    for nField:=1 to 12
        cFields+="ZOG_MES"+strZero(nField,2)
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
