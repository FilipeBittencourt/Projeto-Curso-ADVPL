#include "totvs.ch"
#include "fwmvcdef.ch"

#DEFINE STR0001 "Cadastro de Negativados"
#DEFINE STR0002 "Cadastro PF - CPFs bloqueados"
#DEFINE STR0003 "Sócios por CPF"

class tBJ001MVC from FWRestModel

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

method new() class tBJ001MVC
    _Super:New()
    return

method Activate() class tBJ001MVC
    if (_Super:Activate())
        self:lActivate:=.T.
    endif
    return(self:lActivate)

method DeActivate() class tBJ001MVC
    return(_Super:DeActivate())

method OnError() class tBJ001MVC
    return(_Super:OnError())

method SetModel(oModel) class tBJ001MVC
    return(_Super:SetModel(@oModel))

method ClearModel() class tBJ001MVC
    return(_Super:ClearModel())

method SetName(cName) class tBJ001MVC
    return(_Super:SetName(@cName))

method GetName() class tBJ001MVC
    return(_Super:GetName())

method SetAsXml() class tBJ001MVC
    return(_Super:SetAsXml())

method SetAsJson() class tBJ001MVC
    return(_Super:SetAsJson())

method StartGetFormat(nTotal,nCount,nStartIndex) class tBJ001MVC
    return(_Super:StartGetFormat(@nTotal,@nCount,@nStartIndex))

method EscapeGetFormat() class tBJ001MVC
    return(_Super:EscapeGetFormat())

method EndGetFormat() class tBJ001MVC
    return(_Super:EndGetFormat())

method SetAlias(cAlias) class tBJ001MVC
    return(_Super:SetAlias(cAlias))

method GetAlias() class tBJ001MVC
    return(_Super:GetAlias())

method HasAlias() class tBJ001MVC
    return(_Super:HasAlias())

method Seek(cPK) class tBJ001MVC
    return(_Super:Seek(@cPK))

method Skip(nSkip) class tBJ001MVC
    return(_Super:Skip(@nSkip))

method Total() class tBJ001MVC
    return(_Super:Total())

method GetData(lFieldDetail,lFieldVirtual,lFieldEmpty,lFirstLevel,lInternalID) class tBJ001MVC
    return(_Super:GetData(@lFieldDetail,@lFieldVirtual,@lFieldEmpty,@lFirstLevel,@lInternalID))

method SaveData(cPK,cData,cError) class tBJ001MVC
    return(_Super:SaveData(@cPK,@cData,@cError))

method DelData(cPK,cError) class tBJ001MVC
    return(_Super:DelData(@cPK,@cError))

method SetFilter(cFilter) class tBJ001MVC
    return(_Super:SetFilter(cFilter))

method GetFilter() class tBJ001MVC
    return(_Super:GetFilter())

method ClearFilter() class tBJ001MVC
    return(_Super:ClearFilter())

method DecodePK() class tBJ001MVC
    return(_Super:DecodePK())

method ConvertPK(cPK) class tBJ001MVC
    return(_Super:ConvertPK(@cPK))

method GetStatusResponse() class tBJ001MVC
    return(_Super:GetStatusResponse())

method SetStatusResponse(nStatus,cStatus) class tBJ001MVC
    return(_Super:SetStatusResponse(@nStatus,@cStatus))

method SetQueryString(aQueryString) class tBJ001MVC
    return(_Super:SetQueryString(@aQueryString))

method GetQueryString() class tBJ001MVC
    return(_Super:GetQueryString())

method GetQSValue(cKey) class tBJ001MVC
    return(_Super:GetQSValue(@cKey))

method GetHttpHeader(cParam) class tBJ001MVC
    return(_Super:GetHttpHeader(@cParam))

method SetFields(aFields) class tBJ001MVC
    return(_Super:SetFields(@aFields))

method debuger(lDebug) class tBJ001MVC
    return(_Super:debuger(@lDebug))

static function MenuDef() as array

    local aRotina as array

    aRotina := array(0)

    ADD OPTION aRotina TITLE "Pesquisar"        ACTION "PESQBRW"            OPERATION 1                      ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"       ACTION "VIEWDEF.BJ001MVC"   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
    ADD OPTION aRotina TITLE "Incluir"          ACTION "VIEWDEF.BJ001MVC"   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Alterar"          ACTION "VIEWDEF.BJ001MVC"   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Exportar Excel"   ACTION "U_BIAJ01Excel"      OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

    return(aRotina)

static function ModelDef() as object

    local aPK           as array
    local aRelation     as array
    local aFieldsDet    as array
    local aAux          as array

    local bPost         as block
    local bCommit       as block
    local bEvalVC       as block
    local bHeader       as block
    local bDetail       as block 
    local bVldActivate  as block
    local bLoad         as block

    local cDetOrder     as character
    local cFieldsDet    as character

    local nDetOrder     as numeric

    local oModel        as object
    local oZRYHeader    as object
    local oZRZDetail    as object

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New("BJ001MVC",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription(STR0001)

    // Blocos de codigo do modelo
    bEvalVC := {|oModel,lValid| BIAFJ001TTS(oModel,lValid)}

    cFieldsDet  := ZRZFldsDet(oModel)
    aFieldsDet  := StrToKArr2(cFieldsDet, ",")
    bDetail     := {|cField|( cFieldsDet := Upper(allTrim(cField)),(aScan(aFieldsDet, {|cField|(Upper(allTrim(cField)) == cFieldsDet)}) > 0) )}

    bHeader := {|cField| .T.}
    bDetail := {|cField| .T.}

    // Cria a estrutura a ser usada no Modelo de Dados
    oZRYHeader := FWFormStruct(1,"ZRY",/*bHeader/*bAvalCampo*/,/*lViewUsado*/)
    // Gerar gatilho para preenchimento do CNPJ da linha.
    aAux := FwStruTrigger("ZRY_CNPJ","ZRZ_CNPJ","u_fTrigZRZ()",.F.,Nil,Nil,Nil)
    oZRYHeader:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields("BJ001MVC_HEADER",/*cOwner*/,oZRYHeader,/*bLOkVld*/,/*bTOkVld*/,bLoad/*bCarga*/)

    // Seta a Chave Primaria
    aPK := GetArrUniqe("ZRY")
    if (Empty(aPK))
        aPK := StrTokArr2("ZRY_FILIAL+ZRY_CNPJ","+")
    endif
    oModel:GetModel("BJ001MVC_HEADER"):SetPrimaryKey(aPK)

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BJ001MVC_HEADER"):SetDescription(STR0002)

    // Cria a estrutura a ser usada no Modelo de Dados
    oZRZDetail := FWFormStruct(1,"ZRZ",bDetail/*bAvalCampo*/,/*lViewUsado*/)
    
    // Gerar gatilho para preenchimento do CNPJ da linha.
    aAux := FwStruTrigger("ZRZ_CGC","ZRZ_CNPJ","u_fTrigZRZ()",.F.,Nil,Nil,Nil)
    oZRZDetail:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
    
    // Adiciona Grid no modelo
    oModel:AddGrid("BJ001MVC_DETAIL","BJ001MVC_HEADER",oZRZDetail, /*bLinePre*/, ,/*bPreGrid*/,/*bProsGrid*/)
    
    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("BJ001MVC_DETAIL"):SetDescription(STR0003)

    // Faz o Relacionamento dos arquivos
    aRelation := Array(0)

    aAdd(aRelation,{"ZRZ_FILIAL",'xFilial("ZRY")'})
    aAdd(aRelation,{"ZRZ_CNPJ"  ,"ZRY_CNPJ"})
    
    cDetOrder := "ZRZ_FILIAL+ZRZ_CNPJ"//"ZRZ_FILIAL+ZRZ_CNPJ+ZRZ_CGC"
    nDetOrder := RetOrder("ZRZ",cDetOrder)
    
    oModel:SetRelation("BJ001MVC_DETAIL", @aRelation, ZRZ->(IndexKey(nDetOrder)), .T.)

    return(oModel)

static function ViewDef() as object

    local aFieldsDet    as array

    local bHeader       as block
    local bDetail       as block

    local cFieldsDet    as character

    local oView         as object
    local oModel        as object
    local oZRYHeader    as object
    local oZRZDetail    as object

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    oModel := FWLoadModel("BJ001MVC")
    // Cria o objeto de View
    oView := FWFormView():New()
    // Define qual o Modelo de dados sera utilizado
    oView:SetModel(oModel)

    cFieldsDet  := ZRZFldsDet(oModel)
    aFieldsDet  := StrToKArr2(cFieldsDet,",")
    bDetail     := {|cField| (cFieldsDet := Upper(allTrim(cField)),(aScan(aFieldsDet,{|cField|(Upper(allTrim(cField)) == cFieldsDet)}) > 0))}

    bHeader := {|cField| .T.}
    //bDetail:={|cField| .T.}

    // Cria a estrutura a ser usada na View
    oZRYHeader := FWFormStruct(2,"ZRY", /*bHeader/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField("VIEW_BJ001MVC_HEADER", oZRYHeader, "BJ001MVC_HEADER")

    // Cria a estrutura a ser usada na View
    oZRZDetail := FWFormStruct(2, "ZRZ", bDetail/*bAvalCampo*/,/*lViewUsado*/)

    //Adiciona Grid na interface
    oView:AddGrid("VIEW_BJ001MVC_DETAIL", oZRZDetail, "BJ001MVC_DETAIL",, /*{|oGrid| fLinOK(oGrid)}*/)

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BJ001MVC_HEADER",65)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BJ001MVC_HEADER","FORMFIELD_VIEW_BJ001MVC_HEADER")

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("FORMFIELD_VIEW_BJ001MVC_DETAIL",35)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView("VIEW_BJ001MVC_DETAIL","FORMFIELD_VIEW_BJ001MVC_DETAIL")

    oView:EnableControlBar(.F.)
    oView:lForceSetOwner:=.T.

    return(oView)

static function BIAFJ001TTS(oModel as object,lIsInValid as logical) as logical

    local aSaveRows     as array

    local lBIAFJ001TTS    as logical

    local oSaveModel    as object

    aSaveRows := FWSaveRows()

    oSaveModel := FWModelActive(oModel)

    lBIAFJ001TTS := FWFormCommit(oModel)

    FWModelActive(oSaveModel)

    FWRestRows(aSaveRows)

    return(lBIAFJ001TTS)

/*User Function ZRY2ZRZ()
Local oGrid := Nil 
Local oViewAtivo := Nil
Local nTotLin := 0
Local nLine := 0
Local nTotFDGM := 0
Local oModel := Nil
    
    oModel      := FWModelActive() 
    nTotFDGM    := 0
    oGrid       := oModel:GetModel("BJ001MVC_DETAIL") 
    nTotLin     := oGrid:Length( .F. )// Retorna o total de linhas incluindo as deletadas. 
    oViewAtivo  := FWViewActive() 
    oEnc        := oModel:GetModel("BJ001MVC_HEADER") 
    
    For nLine := 1 To nTotLin // Força o posicionamento na linha do grid 
        oGrid:SetLine( nLine ) // Faz o cálculo apenas para as linhas não deletadas 
        If ! oGrid:IsDeleted( nLine )

            // Chama a rotina que vai atualizar os campos da linha do grid 
            //nTotFDGM += AtuaLinha( oGrid, nLine, oGrid:GetValue( "ZB6_DOSE", nLine ) )
            oGrid:SetValue('ZRZ_CNPJ', oEnc:GetValue("ZRY_CNPJ"))
        EndIf
        
    Next // Força o posicionamento na primeira linha do grid oGrid:SetLine( 1 ) FwFldPut( 'ZB5_TOTFDG', nTotFDGM )

    // Atualiza a tela inteira 
    oViewAtivo:Refresh() 

Return( "" )*/

user function fTrigZRZ()
Local nX      := 0
Local nTotLin := 0
Local oModel  := FWModelActive()
Local oView	  := FWViewActive()
Local cCNPJ   := ""
Local oDetail := Nil
Local nOper   := oModel:GetOperation()

    oEnch   := oModel:GetModel("BJ001MVC_HEADER")
    cCNPJ   := oEnch:GetValue('ZRY_CNPJ')
    
    oDetail := oModel:GetModel("BJ001MVC_DETAIL") 
    nTotLin := oDetail:Length( .F. )// Retorna o total de linhas incluindo as deletadas. 
    
    If (nOper == MODEL_OPERATION_INSERT)
        For nX := 1 To nTotLin
            oDetail:GoLine(nX)
            If !(oDetail:IsDeleted())
                If !Empty(oDetail:GetValue('ZRZ_CNPJ'))
                    // Atualizar a informação do CNPJ.
                    oDetail:SetValue('ZRZ_CNPJ', cCNPJ)
                EndIf
            Endif
        Next    
        // Atualiza a GRID.
        oView:Refresh("BJ001MVC_DETAIL")
        // Força o posicionamento na primeira linha do grid.
        oDetail:SetLine(1)
    EndIf

Return(cCNPJ)

static function EvalBlock(bEval as block,xParameter,lShowHelp as logical,cHelp as character,cMsgHelp as character) as logical
    local lEvalBlock as logical
    DEFAULT lShowHelp:=.F.
    DEFAULT cHelp:=""
    DEFAULT cMsgHelp:=""
    lEvalBlock:=evalBlock():EvalBlock(@bEval,@xParameter,@lShowHelp,@cHelp,@cMsgHelp)
    return(lEvalBlock)

static function ZRZFldsDet(oModel as object) as character
    
    local cFields   as character
    local cFldIIObg as character
    local aFldIICpo as array

    If ( oModel:GetOperation() == 1 .Or. oModel:GetOperation() == 3)
        aFldIICpo := {}
        cFldIIObg := ""
        
        cFldIIObg += AllTrim("ZRZ_CNPJ, ZRZ_CGC, ZRZ_NOME")

        If SubStr(cFldIIObg, Len(cFldIIObg), 1) == ","
            cFldIIObg := SubStr(cFldIIObg, 1, Len(cFldIIObg) - 1)
        EndIf
        cFields := cFldIIObg
    EndIf

    return(cFields)

static function ExistZRY()

    local cDetOrder as caracter
    local nDetOrder as integer

    cDetOrder := "ZRY_FILIAL+ZRY_CNPJ"
    nDetOrder := RetOrder("ZRY",cDetOrder)

    ZRY->(dbSetOrder(nDetOrder))
    If (ZRY->(!DbSeek(ZRY->ZRY_FILIAL+ZRY->ZRY_CNPJ,.F.)))
        PutFileInEoF("ZRY")
    Endif

    return(.T.)


static procedure __Dummy()

    if (.F.)
        __Dummy()
        MODELDEF()
        VIEWDEF()
        MENUDEF()
    endif

    return