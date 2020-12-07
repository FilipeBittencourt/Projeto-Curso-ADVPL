#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIAFA005
@author Artur Antunes
@since 18/05/2017
@version 1.0
@description Cadastro de Metas de Consumo de Gas 
@obs 1683-17
@type function
/*/

User Function BIAFA005()
Local oBrowse := NIL

DbSelectArea('Z88')
fAjustaHelp()
oBrowse := FWmBrowse():New()
oBrowse:SetAlias('Z88')
oBrowse:SetDescription('Cadastro de Metas de Consumo de Gas ')
oBrowse:Activate()

Return 


Static Function MenuDef()
Local aRotina := {}
aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
aAdd( aRotina, { 'Visualizar', 'VIEWDEF.BIAFA005', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.BIAFA005', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.BIAFA005', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.BIAFA005', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.BIAFA005', 0, 8, 0, NIL } )
Return aRotina


Static Function ModelDef()
Local oModel 	:= NIL
Local oStruZ88	:= FWFormStruct(1,'Z88', {|cCampo| AllTRim(cCampo) $ "|Z88_FILIAL|Z88_FORMAT|Z88_FORDES|Z88_RECURS|Z88_RECDES|"})
Local oStruGrid := FWFormStruct(1,'Z88', {|cCampo| !(AllTRim(cCampo) $ "|Z88_FILIAL|Z88_FORMAT|Z88_FORDES|Z88_RECURS|Z88_RECDES|")})

oModel	:= MPFormModel():New('Z88MVC',{|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)})
oModel:SetDescription("Metas de Consumo")	
oModel:AddFields('MdFieldZ88',,oStruZ88)
oModel:SetPrimaryKey({"Z88_FILIAL","Z88_DTDE","Z88_DTATE","Z88_FORMAT","Z88_RECURS"})
oModel:GetModel('MdFieldZ88'):SetDescription('Metas de Consumo')

oModel:AddGrid('MdGridZ88','MdFieldZ88',oStruGrid,,{|oModel,nLine| fLinOK(oModel,nLine)})
oModel:SetRelation('MdGridZ88',{ {'Z88_FILIAL','xFilial("Z88")'},{"Z88_FORMAT","Z88_FORMAT"},{"Z88_RECURS","Z88_RECURS"} }, Z88->(IndexKey(2)) )
oModel:GetModel('MdGridZ88'):SetDescription('Periodo')	

oModel:GetModel("MdGridZ88"):SetDelAllLine(.T.)
oModel:GetModel('MdGridZ88'):SetOptional(.T.)	
oModel:GetModel('MdGridZ88'):SetUniqueLine({"Z88_DTDE","Z88_DTATE"})

Return oModel


Static Function ViewDef()
Local oView		:= NIL
Local oModel	:= FWLoadModel('BIAFA005') 
Local oStruZ88	:= FWFormStruct(2,'Z88', {|cCampo| AllTRim(cCampo) $ "|Z88_FILIAL|Z88_FORMAT|Z88_FORDES|Z88_RECURS|Z88_RECDES|"})
Local oStruGrid := FWFormStruct(2,'Z88', {|cCampo| !(AllTRim(cCampo) $ "|Z88_FILIAL|Z88_FORMAT|Z88_FORDES|Z88_RECURS|Z88_RECDES|")})

oStruZ88:SetNoFolder()

oView:= FWFormView():New() 
oView:SetModel(oModel)              

oView:AddField('VIEW_Z88', oStruZ88, 'MdFieldZ88')
oView:AddGrid ('GRID_Z88', oStruGRID, 'MdGridZ88' )

oView:CreateHorizontalBox("MAIN",35)
oView:CreateHorizontalBox("GRID",65)

oView:EnableTitleView('VIEW_Z88','Metas de Consumo')
oView:EnableTitleView('GRID_Z88','Periodo')

oView:SetOwnerView('VIEW_Z88','MAIN')
oView:SetOwnerView('GRID_Z88','GRID')

Return oView


//Funcao de pos validacao da linha do objeto Grid
Static Function fLinOK(oGrid,nLine)
local nOpc 	  := oGrid:GetOperation()
Local lRet    := .T.
Return lRet


//prevalidacao
Static Function fPreValidCad(oModel)
local lRet :=.T.
local nOpc :=oModel:getoperation()
Return lRet


//Pos-validacao
Static Function fTudoOK(oModel)
Local lRet		:= .T.
Local nX   		:= 0
local nLinValid := 0
local nOpc 		:= oModel:GetOperation()
Local oField    := oModel:GetModel("MdFieldZ88")
Local oGrid     := oModel:GetModel("MdGridZ88")
Local cFormato	:= oField:GetValue('Z88_FORMAT')
Local cRecurso	:= oField:GetValue('Z88_RECURS')
Local dDtDe		:= stod('')
Local dDtAte	:= stod('')
Local nRecno	:= Z88->(Recno())

If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
	
	lRet := ExistCpo("SH1",PADR(alltrim(cRecurso),TamSX3("Z88_RECURS")[1]) )                                                                                      
		
	// validação do grid
	if lRet 
		For nX := 1 To oGrid:GetQtdLine()
			
			oGrid:GoLine(nX)
			dDtDe  := oGrid:GetValue('Z88_DTDE')
			dDtAte := oGrid:GetValue('Z88_DTATE')
			
			if !oGrid:IsDeleted()
				lRet := fLinOK(oGrid,nX)
			endif	
			If !lRet
				Exit
			EndIf
			if lRet .and. !oGrid:IsDeleted() .and. !empty(dDtDe)
				nLinValid++
			endif
		Next nX	
		if lRet .and. nLinValid == 0
			lRet := .F.
			Help(" ",1,"BIAFA00502")
		endif	
	endif
	
	If nOpc == MODEL_OPERATION_INSERT
		Z88->(dbSetOrder(2))
		if lRet .and. Z88->(DbSeek(xFilial("Z88")+PADR(alltrim(cFormato),TamSX3("Z88_FORMAT")[1]) + PADR(alltrim(cRecurso),TamSX3("Z88_RECURS")[1]) ))
			lRet := .F.
			Help(" ",1,"BIAFA00501")
		endif
		Z88->(dbSetOrder(1))
		Z88->(DbGoTo(nRecno))
	endif
endif
Return lRet


//Commit 
Static Function fCommit(oModel)
Local lRet 		 := .T.
Local oGrid		 := oModel:GetModel("MdGridZ88")
Local oForm		 := oModel:GetModel("MdFieldZ88")
Local nX   		 := 0
Local nY		 := 0
local nOpc 		 := oModel:GetOperation()
Local aCposForm  := oForm:GetStruct():GetFields()
Local aCposGrid  := oGrid:GetStruct():GetFields()

For nX := 1 To oGrid:GetQtdLine()
	oGrid:GoLine(nX)
	Z88->(dbGoTo(oGrid:GetDataID()))
	
	If nOpc == MODEL_OPERATION_DELETE
		//-- Deleta registro
		Z88->(RecLock("Z88",.F.))
		Z88->(dbDelete())
		Z88->(MsUnLock())
	Else
		//-- Grava inclusao/alteracao
		Z88->(RecLock("Z88",Z88->(EOF())))
		If oGrid:IsDeleted()
			Z88->(dbDelete())
		Else
			//-- Grava campos do cabecalho
			For nY := 1 To Len(aCposForm)
				If Z88->(FieldPos(aCposForm[nY,3])) > 0 
					Z88->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
				EndIf
			Next nY
			//-- Grava campos do grid
			For nY := 1 To Len(aCposGrid)
				If Z88->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "Z88_FILIAL"
					Z88->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])
				EndIf
			Next nY			
		EndIf
		Z88->(MsUnLock())	
		Z88->(RecLock("Z88",.F.))
		Z88->Z88_FILIAL := xFilial("Z88")
		Z88->(MsUnLock())
	EndIf
Next nX

If nOpc == MODEL_OPERATION_UPDATE
	MsgInfo('Informações Gravadas com Sucesso!')
endif
Return lRet


//Help customizado
Static Function fAjustaHelp()
local aHlpP  := {}

aHlpP  := {}
aAdd(aHlpP, " Relacionamento Invalido! ")
aAdd(aHlpP, " O relacionamento: " )
aAdd(aHlpP, " Formato + Recurso " )
aAdd(aHlpP, " ja esta cadsatrado! " )
PutHelp("PBIAFA00501", aHlpP, aHlpP, aHlpP, .T.)
aHlpP  := {}
aAdd(aHlpP, " Informe outro relacionamento! " )
PutHelp("SBIAFA00501", aHlpP, aHlpP, aHlpP, .T.)

aHlpP  := {}
aAdd(aHlpP, " Cadastro Invalido! ")
PutHelp("PBIAFA00502", aHlpP, aHlpP, aHlpP, .T.)
aHlpP  := {}
aAdd(aHlpP, " Informe pelo menos uma meta! " )
PutHelp("SBIAFA00502", aHlpP, aHlpP, aHlpP, .T.)

return
