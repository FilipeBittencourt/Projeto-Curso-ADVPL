#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIAFA006
@author Artur Antunes
@since 18/05/2017
@version 1.0
@description Cadastro Condições de Venda da BR
@obs 1683-17
@type function
/*/

User Function BIAFA006()
Local oBrowse := NIL

DbSelectArea('Z90')
fAjustaHelp()
oBrowse := FWmBrowse():New()
oBrowse:SetAlias('Z90')
oBrowse:SetDescription('Cadastro Condições de Venda da BR')
oBrowse:Activate()

Return 


Static Function MenuDef()
Local aRotina := {}
aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
aAdd( aRotina, { 'Visualizar', 'VIEWDEF.BIAFA006', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.BIAFA006', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.BIAFA006', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.BIAFA006', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.BIAFA006', 0, 8, 0, NIL } )
Return aRotina


Static Function ModelDef()
Local oModel 	:= NIL
Local oStruZ90	:= FWFormStruct(1,'Z90', {|cCampo| AllTRim(cCampo) $ "|Z90_FILIAL|Z90_CODIGO|Z90_DESCRI|"})
Local oStruGrid := FWFormStruct(1,'Z90', {|cCampo| !(AllTRim(cCampo) $ "|Z90_FILIAL|Z90_CODIGO|Z90_DESCRI|")})

oModel	:= MPFormModel():New('Z90MVC',{|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )
oModel:SetDescription("Condições de Venda da BR")	
oModel:AddFields('MdFieldZ90',,oStruZ90)
oModel:SetPrimaryKey({"Z90_FILIAL","Z90_DTDE","Z90_DTATE","Z90_CODIGO"})
oModel:GetModel('MdFieldZ90'):SetDescription('Condições de Venda da BR')

oModel:AddGrid('MdGridZ90','MdFieldZ90',oStruGrid,,{|oModel,nLine| fLinOK(oModel,nLine)})
oModel:SetRelation('MdGridZ90',{ {'Z90_FILIAL','xFilial("Z90")'},{"Z90_CODIGO","Z90_CODIGO"} }, Z90->(IndexKey(1)) )
oModel:GetModel('MdGridZ90'):SetDescription('Periodo')	

oModel:GetModel("MdGridZ90"):SetDelAllLine(.T.)
oModel:GetModel('MdGridZ90'):SetOptional(.T.)	
oModel:GetModel('MdGridZ90'):SetUniqueLine({"Z90_DTDE","Z90_DTATE"})

Return oModel


Static Function ViewDef()
Local oView		:= NIL
Local oModel	:= FWLoadModel('BIAFA006') 
Local oStruZ90	:= FWFormStruct(2,'Z90', {|cCampo| AllTRim(cCampo) $ "|Z90_FILIAL|Z90_CODIGO|Z90_DESCRI|"})
Local oStruGrid := FWFormStruct(2,'Z90', {|cCampo| !(AllTRim(cCampo) $ "|Z90_FILIAL|Z90_CODIGO|Z90_DESCRI|")})

oStruZ90:SetNoFolder()

oView:= FWFormView():New() 
oView:SetModel(oModel)              

oView:AddField('VIEW_Z90', oStruZ90, 'MdFieldZ90')
oView:AddGrid ('GRID_Z90', oStruGRID, 'MdGridZ90' )

oView:CreateHorizontalBox("MAIN",35)
oView:CreateHorizontalBox("GRID",65)

oView:EnableTitleView('VIEW_Z90','Condições de Venda da BR')
oView:EnableTitleView('GRID_Z90','Periodo')

oView:SetOwnerView('VIEW_Z90','MAIN')
oView:SetOwnerView('GRID_Z90','GRID')

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
Local oField    := oModel:GetModel("MdFieldZ90")
Local oGrid     := oModel:GetModel("MdGridZ90")
Local cCodigo	:= oField:GetValue('Z90_CODIGO')
Local dDtDe		:= stod('')
Local dDtAte	:= stod('')
Local nRecno	:= Z90->(Recno())

If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
	
	// validação do grid
	if lRet 
		For nX := 1 To oGrid:GetQtdLine()
			oGrid:GoLine(nX)
			dDtDe  := oGrid:GetValue('Z90_DTDE')
			dDtAte := oGrid:GetValue('Z90_DTATE')
			
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
			Help(" ",1,"BIAFA00602")
		endif	
	endif
	
	If nOpc == MODEL_OPERATION_INSERT
		Z90->(dbSetOrder(1))
		if lRet .and. Z90->(DbSeek(xFilial("Z90")+PADR(alltrim(cCodigo),TamSX3("Z90_CODIGO")[1]) ))
			lRet := .F.
			Help(" ",1,"BIAFA00601")
		endif
		Z90->(dbSetOrder(1))
		Z90->(DbGoTo(nRecno))
	endif
endif
Return lRet


//Commit 
Static Function fCommit(oModel)
Local lRet 		 := .T.
Local oGrid		 := oModel:GetModel("MdGridZ90")
Local oForm		 := oModel:GetModel("MdFieldZ90")
Local nX   		 := 0
Local nY		 := 0
local nOpc 		 := oModel:GetOperation()
Local aCposForm  := oForm:GetStruct():GetFields()
Local aCposGrid  := oGrid:GetStruct():GetFields()

If nOpc == MODEL_OPERATION_INSERT
	ConfirmSX8()
endif

For nX := 1 To oGrid:GetQtdLine()
	oGrid:GoLine(nX)
	Z90->(dbGoTo(oGrid:GetDataID()))
	
	If nOpc == MODEL_OPERATION_DELETE
		//-- Deleta registro
		Z90->(RecLock("Z90",.F.))
		Z90->(dbDelete())
		Z90->(MsUnLock())
	Else
		//-- Grava inclusao/alteracao
		Z90->(RecLock("Z90",Z90->(EOF())))
		If oGrid:IsDeleted()
			Z90->(dbDelete())
		Else
			//-- Grava campos do cabecalho
			For nY := 1 To Len(aCposForm)
				If Z90->(FieldPos(aCposForm[nY,3])) > 0 
					Z90->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
				EndIf
			Next nY
			//-- Grava campos do grid
			For nY := 1 To Len(aCposGrid)
				If Z90->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "Z90_FILIAL"
					Z90->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])
				EndIf
			Next nY			
		EndIf
		Z90->(MsUnLock())	
		Z90->(RecLock("Z90",.F.))
		Z90->Z90_FILIAL := xFilial("Z90")
		Z90->(MsUnLock())
	EndIf
Next nX

If nOpc == MODEL_OPERATION_UPDATE
	MsgInfo('Informações Gravadas com Sucesso!')
endif
Return lRet


//Cancelar 
Static Function fCancel(oModel)
Local lRet 		 := .T.
Local oForm		 := oModel:GetModel("MdFieldZ90")
Local oGrid		 := oModel:GetModel("MdGridZ90")
local nOpc 		 := oModel:GetOperation()
If nOpc == MODEL_OPERATION_INSERT
	RollBAckSx8()
endif
Return lRet


//Help customizado
Static Function fAjustaHelp()
local aHlpP  := {}

aHlpP  := {}
aAdd(aHlpP, " Codigo ja esta cadsatrado! ")
PutHelp("PBIAFA00601", aHlpP, aHlpP, aHlpP, .T.)
aHlpP  := {}
aAdd(aHlpP, " Informe outro codigo! " )
PutHelp("SBIAFA00601", aHlpP, aHlpP, aHlpP, .T.)

aHlpP  := {}
aAdd(aHlpP, " Cadastro Invalido! ")
PutHelp("PBIAFA00602", aHlpP, aHlpP, aHlpP, .T.)
aHlpP  := {}
aAdd(aHlpP, " Informe pelo menos uma condição! " )
PutHelp("SBIAFA00602", aHlpP, aHlpP, aHlpP, .T.)

return
