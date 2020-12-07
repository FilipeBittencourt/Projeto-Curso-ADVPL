#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "rwmake.ch" 
#Include "TopConn.ch"

/*/{Protheus.doc} BIA843
@author Ranisses A. Corona
@since 06/06/2017
@version 1.0
@description Cadastro de Excecoes de Vencimento 
@type function
/*/
User Function BIA843()
Local aArea   := GetArea()
Local oBrowse := NIL
Local cFunBkp := FunName()

SetFunName("BIA843")

//Atualiza Registros Blqueados/Desbloqueados
fAtuBlq()

oBrowse := FWmBrowse():New()
oBrowse:SetAlias('Z01')

oBrowse:AddLegend( "Z01->Z01_MSBLQL <> '1' ", "GREEN", "Ativo" )
oBrowse:AddLegend( "Z01->Z01_MSBLQL == '1' ", "RED"  , "Bloqueado" )

oBrowse:SetDescription('Cadastro de Excecoes de Vencimento')
oBrowse:SetFilterDefault("Z01->Z01_FLAG == 'X'")
oBrowse:Activate()

SetFunName(cFunBkp)
RestArea(aArea)

Return 


Static Function MenuDef()
Local aRotina := {}
aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
aAdd( aRotina, { 'Visualizar', 'VIEWDEF.BIA843', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.BIA843', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.BIA843', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.BIA843', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.BIA843', 0, 8, 0, NIL } )
Return aRotina


Static Function ModelDef()
Local oModel 	:= NIL
Local oStruZ01	:= FWFormStruct(1,'Z01', {|cCampo|   AllTRim(cCampo) $ "Z01_MARCA|Z01_REGRA|Z01_CNPJGR|Z01_NOMCNP|Z01_GRUPO|Z01_NOMGRP|Z01_CLIENT|Z01_LOJA|Z01_NOMCLI|Z01_VALDDE|Z01_VALDAT|"})
Local oStruGrid := FWFormStruct(1,'Z01', {|cCampo| !(AllTRim(cCampo) $ "Z01_MARCA|Z01_REGRA|Z01_CNPJGR|Z01_NOMCNP|Z01_GRUPO|Z01_NOMGRP|Z01_CLIENT|Z01_LOJA|Z01_NOMCLI|Z01_VALDDE|Z01_VALDAT|")})

oModel	:= MPFormModel():New('Z01MVC',{|oModel| (.T.)},{|oModel| (.T.)},{|oModel| fCommit(oModel)})
oModel:SetDescription("Cadastro de Excecoes de Vencimento")	
oModel:AddFields('MdFieldZ01',,oStruZ01)
oModel:SetPrimaryKey({"Z01_FILIAL","Z01_MARCA","Z01_REGRA","Z01_CNPJGR","Z01_GRUPO","Z01_CLIENT","Z01_LOJA","Z01_VALDDE","Z01_VALDAT"})
oModel:GetModel('MdFieldZ01'):SetDescription('Cadastro de Excecoes de Vencimento')

oModel:AddGrid('MdGridZ01','MdFieldZ01',oStruGrid,,{|oModel,nLine| fLinOK(oModel,nLine)},/*bPreGrid*/,/*bProsGrid*/)
oModel:SetRelation('MdGridZ01',{ {'Z01_FILIAL','xFilial("Z01")'},{"Z01_MARCA","Z01_MARCA"},{"Z01_REGRA","Z01_REGRA"},{"Z01_CNPJGR","Z01_CNPJGR"},{"Z01_GRUPO","Z01_GRUPO"},{"Z01_CLIENT","Z01_CLIENT"},{"Z01_LOJA","Z01_LOJA"},{"Z01_VALDDE","Z01_VALDDE"},{"Z01_VALDAT","Z01_VALDAT"}    }, Z01->(IndexKey(4)) )
oModel:GetModel('MdGridZ01'):SetDescription('Regras')	

oModel:GetModel('MdGridZ01'):SetDelAllLine(.T.)
oModel:GetModel('MdGridZ01'):SetOptional(.T.)	
oModel:GetModel('MdGridZ01'):SetUniqueLine({"Z01_TIPO","Z01_DIAS","Z01_DDD","Z01_FORMA","Z01_DVCINI","Z01_DVCFIM"})

Return oModel


Static Function ViewDef()
Local oView		:= NIL
Local oModel	:= FWLoadModel('BIA843') 
Local oStruZ01	:= FWFormStruct(2,'Z01', {|cCampo|   AllTRim(cCampo) $ "Z01_MARCA|Z01_REGRA|Z01_CNPJGR|Z01_NOMCNP|Z01_GRUPO|Z01_NOMGRP|Z01_CLIENT|Z01_LOJA|Z01_NOMCLI|Z01_VALDDE|Z01_VALDAT|"})
Local oStruGrid := FWFormStruct(2,'Z01', {|cCampo| !(AllTRim(cCampo) $ "Z01_MARCA|Z01_REGRA|Z01_CNPJGR|Z01_NOMCNP|Z01_GRUPO|Z01_NOMGRP|Z01_CLIENT|Z01_LOJA|Z01_NOMCLI|Z01_VALDDE|Z01_VALDAT|")})

oStruZ01:SetNoFolder()

oView:= FWFormView():New() 
oView:SetModel(oModel)              

oView:AddField('VIEW_Z01', oStruZ01, 'MdFieldZ01')
oView:AddGrid ('GRID_Z01', oStruGRID, 'MdGridZ01')

oStruGrid:RemoveField('Z01_MSBLQL' )
oStruGrid:RemoveField('Z01_FLAG' )

oView:CreateHorizontalBox("MAIN",35)
oView:CreateHorizontalBox("GRID",65)

oView:EnableTitleView('VIEW_Z01','Cabeçalho')
oView:EnableTitleView('GRID_Z01','Regras')

oView:SetOwnerView('VIEW_Z01','MAIN')
oView:SetOwnerView('GRID_Z01','GRID')

Return oView


//Funcao de pos validacao da linha do objeto Grid
Static Function fLinOK(oGrid,nLine)
local nOpc	:= oGrid:GetOperation()
Local lRet	:= .T.

DbSelectArea('Z01')

If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
	oGrid:GoLine(nLine)
	If !oGrid:IsDeleted()		
		If lRet .And. M->Z01_REGRA == "ST" .And. ( !Empty(oGrid:GetValue('Z01_DVCINI')) .Or. !Empty(oGrid:GetValue('Z01_DVCFIM')) ) 
			lRet := .F.
			MsgBox("Para regra de ST, os campo Dia De, Dia Ate e Dia Vencimento não podem ser preenchidos.","STOP")
		EndIf

		If lRet .And. M->Z01_REGRA == "NF" .And. (!Empty(oGrid:GetValue('Z01_TIPO')) .Or. !Empty(oGrid:GetValue('Z01_FORMA')) ) 
			lRet := .F.
			MsgBox("Para regra de NF, os campo Tipo Incremento, Dias, e Forma Pagamento não podem ser preenchidos.","STOP")
		EndIf
		
		/*
		Z79->(DbSetOrder(3))
		If lRet .And. !Empty(oGrid:GetValue('Z79_CODCLI')) .And. Z79->(DbSeek(xFilial("Z79")+Alltrim(oGrid:GetValue('Z79_CODCLI'))+oGrid:GetValue('Z79_LOJCLI') ))
			lRet := .F.
			MsgBox("Este Cliente já está em uso na Rede "+Z79->Z79_REDE+". Favor informar outro código ou deletar essa linha.","STOP")		
		EndIf

		Z79->(DbSetOrder(4))
		If lRet .And. !Empty(oGrid:GetValue('Z79_CODGRP')) .And. Z79->(DbSeek(xFilial("Z79")+Alltrim(oGrid:GetValue('Z79_CODGRP'))))
			lRet := .F.
			MsgBox("Este Grupo já está em uso na Rede "+Z79->Z79_REDE+". Favor informar outro código ou deletar essa linha.","STOP")		
		EndIf

		If lRet .And. !Empty(oGrid:GetValue('Z79_CODCLI')) .And. Empty(oGrid:GetValue('Z79_NOMCLI'))
			lRet := .F.
			MsgBox("O Cliente informado não existe. Favor informar outro código ou deletar essa linha.","STOP")		
		EndIf

		If lRet .And. !Empty(oGrid:GetValue('Z79_CODGRP')) .And. Empty(oGrid:GetValue('Z79_NOMGRP'))
			lRet := .F.
			MsgBox("O Grupo informado não existe. Favor informar outro código ou deletar essa linha.","STOP")		
		EndIf
				
		If lRet .And. !Empty(oGrid:GetValue('Z79_CODCLI')) .And. !Empty(Alltrim(POSICIONE("SA1",1,xFilial("SA1")+oGrid:GetValue('Z79_CODCLI')+oGrid:GetValue('Z79_LOJCLI'),"A1_GRPVEN")))
			lRet := .F.
			MsgBox("O Cliente informado pertence ao Grupo de Cliente "+SA1->A1_GRPVEN+". Nestes casos é necessário cadastrar o código do Grupo.","STOP")		
		EndIf
		*/

	EndIf
EndIf

Z01->(DbSetOrder(4))

Return lRet


//prevalidacao
Static Function fPreValidCad(oModel)
local lRet :=.T.
local nOpc :=oModel:getoperation()
Return lRet

//Commit 
Static Function fCommit(oModel)
Local lRet 		 := .T.
Local oGrid		 := oModel:GetModel("MdGridZ01")
Local oForm		 := oModel:GetModel("MdFieldZ01")
Local nX   		 := 0
Local nY		 := 0
local nOpc 		 := oModel:GetOperation()
Local aCposForm  := oForm:GetStruct():GetFields()
Local aCposGrid  := oGrid:GetStruct():GetFields()

Private INCLUI   := .F.
Private ALTERA   := .F.

For nX := 1 To oGrid:GetQtdLine()
	oGrid:GoLine(nX)
	Z01->(dbGoTo(oGrid:GetDataID()))
	
	If nOpc == MODEL_OPERATION_DELETE
		//-- Deleta registro
		Z01->(RecLock("Z01",.F.))
		Z01->(dbDelete())
		Z01->(MsUnLock())
	Else
		
		//-- Grava inclusao/alteracao
		RecLock("Z01",Z01->(EOF()))
		If oGrid:IsDeleted()
			Z01->(dbDelete())
		Else
			Z01->Z01_FILIAL := xFilial("Z01")
			//-- Grava campos do cabecalho
			For nY := 1 To Len(aCposForm)
				If Z01->(FieldPos(aCposForm[nY,3])) > 0 
					Z01->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
				EndIf
			Next nY
			//-- Grava campos do grid
			For nY := 1 To Len(aCposGrid)
				If Z01->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "Z01_FILIAL"
					Z01->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])
				EndIf				

				If aCposGrid[nY,3] == "Z01_FLAG"
					If nX == 1  
						Z01->&(aCposGrid[nY,3]) := "X"
					Else
						Z01->&(aCposGrid[nY,3]) := ""					
					EndIf
				EndIf

			Next nY

		EndIf
		Z01->(MsUnLock())	
		
	EndIf
Next nX

If nOpc == MODEL_OPERATION_UPDATE
	MsgInfo('Informações Gravadas com Sucesso!')
EndIf

//Atualiza Registros Blqueados/Desbloqueados
fAtuBlq()

Return lRet

//Atualiza registros Bloqueados/Desbloqueados 
Static Function fAtuBlq()
Local cSql := ""

cSql := "UPDATE Z01010 SET Z01_MSBLQL = '2' WHERE Z01_VALDDE <= '"+Dtos(dDatabase)+"' AND Z01_VALDAT >= '"+Dtos(dDatabase)+"' AND D_E_L_E_T_ = '' "
TCSQLExec(cSql)     

cSql := "UPDATE Z01010 SET Z01_MSBLQL = '1' WHERE Z01_VALDAT <= '"+Dtos(dDatabase)+"' AND D_E_L_E_T_ = '' 
TCSQLExec(cSql)
      
Return