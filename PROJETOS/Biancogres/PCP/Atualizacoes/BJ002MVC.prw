#include "totvs.ch"
#include "fwmvcdef.ch"

#DEFINE STR0001 "Cadastro de Formato por Perda"
#DEFINE STR0002 "Formato por Perda"

class tBJ002MVC from FWRestModel

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

method new() class tBJ002MVC
    _Super:New()
    return

method Activate() class tBJ002MVC
    if (_Super:Activate())
        self:lActivate:=.T.
    endif
    return(self:lActivate)

method DeActivate() class tBJ002MVC
    return(_Super:DeActivate())

method OnError() class tBJ002MVC
    return(_Super:OnError())

method SetModel(oModel) class tBJ002MVC
    return(_Super:SetModel(@oModel))

method ClearModel() class tBJ002MVC
    return(_Super:ClearModel())

method SetName(cName) class tBJ002MVC
    return(_Super:SetName(@cName))

method GetName() class tBJ002MVC
    return(_Super:GetName())

method SetAsXml() class tBJ002MVC
    return(_Super:SetAsXml())

method SetAsJson() class tBJ002MVC
    return(_Super:SetAsJson())

method StartGetFormat(nTotal,nCount,nStartIndex) class tBJ002MVC
    return(_Super:StartGetFormat(@nTotal,@nCount,@nStartIndex))

method EscapeGetFormat() class tBJ002MVC
    return(_Super:EscapeGetFormat())

method EndGetFormat() class tBJ002MVC
    return(_Super:EndGetFormat())

method SetAlias(cAlias) class tBJ002MVC
    return(_Super:SetAlias(cAlias))

method GetAlias() class tBJ002MVC
    return(_Super:GetAlias())

method HasAlias() class tBJ002MVC
    return(_Super:HasAlias())

method Seek(cPK) class tBJ002MVC
    return(_Super:Seek(@cPK))

method Skip(nSkip) class tBJ002MVC
    return(_Super:Skip(@nSkip))

method Total() class tBJ002MVC
    return(_Super:Total())

method GetData(lFieldDetail,lFieldVirtual,lFieldEmpty,lFirstLevel,lInternalID) class tBJ002MVC
    return(_Super:GetData(@lFieldDetail,@lFieldVirtual,@lFieldEmpty,@lFirstLevel,@lInternalID))

method SaveData(cPK,cData,cError) class tBJ002MVC
    return(_Super:SaveData(@cPK,@cData,@cError))

method DelData(cPK,cError) class tBJ002MVC
    return(_Super:DelData(@cPK,@cError))

method SetFilter(cFilter) class tBJ002MVC
    return(_Super:SetFilter(cFilter))

method GetFilter() class tBJ002MVC
    return(_Super:GetFilter())

method ClearFilter() class tBJ002MVC
    return(_Super:ClearFilter())

method DecodePK() class tBJ002MVC
    return(_Super:DecodePK())

method ConvertPK(cPK) class tBJ002MVC
    return(_Super:ConvertPK(@cPK))

method GetStatusResponse() class tBJ002MVC
    return(_Super:GetStatusResponse())

method SetStatusResponse(nStatus,cStatus) class tBJ002MVC
    return(_Super:SetStatusResponse(@nStatus,@cStatus))

method SetQueryString(aQueryString) class tBJ002MVC
    return(_Super:SetQueryString(@aQueryString))

method GetQueryString() class tBJ002MVC
    return(_Super:GetQueryString())

method GetQSValue(cKey) class tBJ002MVC
    return(_Super:GetQSValue(@cKey))

method GetHttpHeader(cParam) class tBJ002MVC
    return(_Super:GetHttpHeader(@cParam))

method SetFields(aFields) class tBJ002MVC
    return(_Super:SetFields(@aFields))

method debuger(lDebug) class tBJ002MVC
    return(_Super:debuger(@lDebug))

static function MenuDef() as array

    local aRotina as array

    aRotina:=array(0)

    ADD OPTION aRotina TITLE "Pesquisar"        ACTION "PESQBRW"             OPERATION 1                      ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"       ACTION "VIEWDEF.BJ002MVC"   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Incluir"          ACTION "VIEWDEF.BJ002MVC"   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Alterar"          ACTION "VIEWDEF.BJ002MVC"   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Excluir"          ACTION "VIEWDEF.BJ002MVC"   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    //ADD OPTION aRotina TITLE "Processar"        ACTION "U_BIA636Proc"        OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRotina TITLE "Exportar Excel"   ACTION "U_BIA636Excel"       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

    return(aRotina)

static function ModelDef() as object

    local aPK           as array
    local aAux          as array
    local aRelation     as array
    local aFieldsDet    as array

    local bPost         as block
    local bCommit       as block
    local bEvalVC       as block
    local bHeader       as block
    local bDetail       as block 
    local bVldActivate  as block

    local cZRXOrder     as character
    local cFieldsDet    as character

    local nZRXOrder     as numeric

    local oModel        as object
    local oZRXHeader    as object
    local oZRXDetail    as object

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New("BJ002MVC",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription(STR0001)

    // Blocos de codigo do modelo.
    bEvalVC := {|oModel,lValid| BJ002TTS(oModel,lValid)}
    // Validação LINOK.
    bPost := {|oModel,nLine| fLPosGrid(oModel,nLine) }  

    cFieldsDet  := ZRXFldsDet()
    aFieldsDet  := StrToKArr2(cFieldsDet,",")
    bHeader     := {|cField|(cFieldsDet := Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField)) == cFieldsDet)}) == 0))}
    bDetail     := {|cField|(cFieldsDet := Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField)) == cFieldsDet)}) > 0))}

    // Cria a estrutura a ser usada no Modelo de Dados
    oZRXHeader := FWFormStruct(1,"ZRX",bHeader/*bAvalCampo*/,/*lViewUsado*/)
    //oZRXHeader:RemoveField('ZRX_PROCID')
    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields("BJ002MVC_HEADER",/*cOwner*/,oZRXHeader,/*bLOkVld*/,/*bTOkVld*/,/*bCarga*/)

    // Seta a Chave Primaria
    aPK := GetArrUniqe("ZRX")
    if (empty(aPK))
        //aPK := strTokArr2("ZRX_FILIAL+ZRX_PROCID+ZRX_FORMAT+DTOS(ZRX_INI)+DTOS(ZRX_FIM)","+")
        aPK := strTokArr2("ZRX_FILIAL+ZRX_FORMAT","+")
    endif
    oModel:GetModel("BJ002MVC_HEADER"):SetPrimaryKey(aPK)

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BJ002MVC_HEADER"):SetDescription(STR0001)

    // Cria a estrutura a ser usada no Modelo de Dados
    oZRXDetail := FWFormStruct(1,"ZRX",bDetail/*bAvalCampo*/,/*lViewUsado*/)
    // Gerar gatilho para preenchimento da DESCRICAO DO FORMATO da linha.
    //aAux := FwStruTrigger("ZRX_FORMAT","ZRX_DESC","u_fTrigZRX()",.F.,Nil,Nil,Nil)
    //oZRXDetail:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

    // Adiciona Grid no modelo
    oModel:AddGrid("BJ002MVC_DETAIL","BJ002MVC_HEADER",oZRXDetail, /*bLinePre*/, /*bLinePost*/bPost, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
    
    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BJ002MVC_DETAIL"):SetDescription(STR0002)

    // Faz o Relacionamento dos arquivos
    aRelation := array(0)

    aAdd(aRelation,{"ZRX_FILIAL","ZRX_FILIAL"})
    //aAdd(aRelation,{"ZRX_PROCID","ZRX_PROCID"})
    aAdd(aRelation,{"ZRX_FORMAT","ZRX_FORMAT"})

    cZRXOrder := "ZRX_FILIAL+ZRX_FORMAT+DTOS(ZRX_INI)"
    nZRXOrder := retOrder("ZRX",cZRXOrder)
    
    oModel:SetRelation("BJ002MVC_DETAIL",@aRelation,ZRX->(IndexKey(nZRXOrder)))

    // Liga o controle de nao repeticao de linha - LinOk
    oModel:GetModel("BJ002MVC_DETAIL"):SetUniqueLine({"ZRX_INI","ZRX_FIM"})

    //bVldActivate := oModel:bVldActivate
    //oModel:bVldActivate := {|oObj| EvalBlock(@bVldActivate,@oObj,.F.,"ERROR_ONACTIVATE","ERROR_ONACTIVATE"),.T.}

    return(oModel)

static function ViewDef() as object

    local aAux          as array
    local aFieldsDet    as array

    local bHeader       as block
    local bDetail       as block

    local cFieldsDet    as character

    local oView         as object
    local oModel        as object
    local oZRXHeader    as object
    local oZRXDetail    as object

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    oModel := FWLoadModel("BJ002MVC")

    // Cria o objeto de View
    oView := FWFormView():New()
    // Define qual o Modelo de dados sera utilizado
    oView:SetModel(oModel)

    cFieldsDet  := ZRXFldsDet()
    aFieldsDet  := StrToKArr2(cFieldsDet,",")
    bHeader     := {|cField|(cFieldsDet := Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)}) == 0))}
    bDetail     := {|cField|(cFieldsDet := Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField))==cFieldsDet)}) > 0))}

    // Cria a estrutura a ser usada na View
    oZRXHeader := FWFormStruct(2,"ZRX",bHeader/*bAvalCampo*/,/*lViewUsado*/)
    
    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField("VIEW_BJ002MVC_HEADER",oZRXHeader,"BJ002MVC_HEADER")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BJ002MVC_HEADER",25)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BJ002MVC_HEADER","FORMFIELD_VIEW_BJ002MVC_HEADER")

    // Cria a estrutura a ser usada na View
    oZRXDetail:=FWFormStruct(2,"ZRX",bDetail/*bAvalCampo*/,/*lViewUsado*/)
    //oZRXDetail:RemoveField('ZRX_PROCID')
    
    //Adiciona Grid na interface
    oView:AddGrid("VIEW_BJ002MVC_DETAIL",oZRXDetail,"BJ002MVC_DETAIL")

    //Define campo com incremento automatico por Linha
    //oView:AddIncrementField("VIEW_BJ002MVC_DETAIL","")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BJ002MVC_DETAIL",75)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BJ002MVC_DETAIL","FORMFIELD_VIEW_BJ002MVC_DETAIL")

    oView:EnableControlBar(.F.)
    oView:lForceSetOwner:=.T.

    return(oView)

static function BJ002TTS(oModel as object,lIsInValid as logical) as logical

    local aSaveRows     as array

    local lBJ002TTS    as logical

    local oSaveModel    as object

    aSaveRows := FWSaveRows()

    oSaveModel := FWModelActive(oModel)

    lBJ002TTS := FWFormCommit(oModel)

    FWModelActive(oSaveModel)

    FWRestRows(aSaveRows)

    return(lBJ002TTS)

function u_BJ002MVC()
    local aParameter    as array
    local xRet

    begin sequence
        if (!type("ParamIXB")=="A")
            break
        endif
        aParameter:=&("ParamIXB")
        xRet := BJ002MVC(aParameter)
    end sequence

    DEFAULT xRet:=.T.

    return(xRet)

static function BJ002MVC(aParameter as array)

    local cIdPonto      as character
    local cIdModel      as character

    local nOperation    as numeric

    local oObj          as object

    local xRet

    begin sequence

        oObj := aParameter[1]
        cIdPonto := aParameter[2]
        cIdModel := aParameter[3]

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

static function fLPosGrid(oModel as object,nLinGrd as numeric) as logical
    local lVldLin       as logical
    local aSaveRows     as array
    local oSaveModel    as object
    
    local oGrid         as object
    local nOperation    as numeric
    local nI            as numeric
    local dPerDe   		as date
    local dPerAte   	as date
    local dPerDeLin     as date
    local dPerAteLin    as date

    oAModel     := FwModelActive()
    oGrid    	:= oAModel:GetModel("BJ002MVC_DETAIL")
    nOperation  := oAModel:GetOperation()
    
    lVldLin     := .T.
    
    aSaveRows   := FWSaveRows()
    oSaveModel  := FWModelActive(oModel)

    oGrid:GoLine( nLinGrd )
    dPerDeLin   := oGrid:GetValue( 'ZRX_INI' )
    dPerAteLin  := oGrid:GetValue( 'ZRX_FIM' )
    For nI := 1 To oGrid:GetQtdLine()					
        If lVldLin
            oGrid:GoLine( nI )
            dPerDe   := oGrid:GetValue( 'ZRX_INI' )
            dPerAte  := oGrid:GetValue( 'ZRX_FIM' )
            If Empty(dPerDe) .AnD. !Empty(dPerAte)
                lVldLin  := .F.
                Help(,, 'HELP',, "Obrigatorio informar periodo DE/ATÉ.", 1, 0)		
            ElseIf !Empty(dPerDe) .AnD. !Empty(dPerAte)
                If ( dPerDeLin >= dPerDe ) .AnD. ( dPerDeLin <= dPerAte ) .AnD. ( nLinGrd <> nI )
                    lVldLin  := .F.
                    Help(,, 'HELP',, "Periodo ja cadastrado.", 1, 0)					
                ElseIf ( dPerAteLin >= dPerDe ) .AnD. ( dPerAteLin <= dPerAte ) .AnD. ( nLinGrd <> nI )
                    lVldLin  := .F.
                    Help(,, 'HELP',, "Periodo ja cadastrado.", 1, 0)					
                ElseIf ( dPerAteLin < dPerDeLin )
                    lVldLin  := .F.
                    Help(,, 'HELP',, "Periodo Até deve ser maior que Periodo De.", 1, 0)
                EndIf			
            EndIf
        EndIf
    Next nI

    FWModelActive(oSaveModel)
    FWRestRows(aSaveRows)

    return(lVldLin)

static function ZRXFldsDet() as character
    
    local cFields   as character

    cFields := "ZRX_INI,ZRX_FIM,ZRX_PERDA" // Campos a serem exibidos na GRID.

    return(cFields)

static procedure __Dummy()

    if (.F.)
        __Dummy()
        MODELDEF()
        VIEWDEF()
        MENUDEF()
    endif

    return