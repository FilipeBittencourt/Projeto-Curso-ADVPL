#include "protheus.ch"
#include "msmgadd.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH

/*
Projeto: INTEGRAÇÃO NEUROTECH
Cliente: UNIAO
Desnv: FACILE - ALFONSO
Data: 2018-12-11
---------
ROTINA PARA cadastro de grupos economicos
---------
soemte para consulta, porque os dados sao atualizados pelas integrações

*/

Static cTitulo := "Cadastro Grupo Economico"
// Static cCodGestor := GetNewPar('MV_YAPROV','001656_000606')

// U_VIXA266
User Function VIXA266()

	Local aArea       := GetArea()
	Local oBrowse     := nil

	//Private cCodGestor := GetNewPar('MV_YAPROV','001656_000606')
	private aRotina   := MenuDef()	

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SZ9')
	oBrowse:SetDescription(cTitulo)
//	oBrowse:SetFilterDefault("SZ9->SZ9_CODFOR == SA2->A2_COD  .And.  SZ9->SZ9_LOJA == SA2->A2_LOJA")

	oBrowse:Activate()
	RestArea(aArea)

Return


Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VIXA266' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VIXA266' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VIXA266' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	// ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.INTE02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

// ALFONSO
Static Function ModelDef()

	Local oModel   := Nil
	Local oFormPai := FWFormStruct(1, 'SZ9', {|cCampo| AllTrim(cCampo) $ "Z9_CODIGO|Z9_DESC|Z9_LCGRUPO|"}) // exibe campos na parte de cima do GRID
	//Local oFormFil := FWFormStruct(1, 'SZ9', {|cCampo| AllTrim(cCampo) $ "Z9_CODCLI|Z9_LOJA|Z9_NOMECLI|Z9_CNPJ|Z9_LIMITE|Z9_ORIGEM|"})// exibe campos na GRID
	Local oFormFil := FWFormStruct(1, 'SZ9', {|cCampo| AllTrim(cCampo) $ "Z9_CODCLI|Z9_LOJA|Z9_NOMECLI|Z9_CNPJ|Z9_LIMITE|"})// exibe campos na GRID
	
	//Local oFormFil := FWFormStruct(1, 'SZ9', {|cCampo| AllTrim(cCampo) $ "Z9_CODCLI|Z9_LOJA|Z9_NOMECLI|Z9_CNPJ|Z9_ORIGEM|"})// exibe campos na GRID
	
	Local aSZ9Rel  := {}
	Local bLinePost  := {|oFormFil| LinePos(oFormFil)}	
	Local bLinePre  := {|oFormFil| LinePre(oFormFil)} //http://tdn.totvs.com/display/framework/MPFormModel
	Local bLinePrev  := {|oFormFil| LinePrev(oFormFil)}

	oFormFil:SetProperty('Z9_NOMECLI',  MODEL_FIELD_INIT, {|| IIF(INCLUI,'', U_INTE02IG("SA1", 1, SZ9->Z9_CODCLI + SZ9->Z9_LOJA, "A1_NOME", .F.))})
	oFormFil:SetProperty('Z9_CNPJ',  MODEL_FIELD_INIT, {|| IIF(INCLUI,'', U_INTE02IG("SA1", 1, SZ9->Z9_CODCLI + SZ9->Z9_LOJA, "A1_CGC", .F.))})
	oFormFil:SetProperty('Z9_LIMITE',  MODEL_FIELD_INIT, {|| IIF(INCLUI,'', VAL(U_INTE02IG("SA1", 1, SZ9->Z9_CODCLI + SZ9->Z9_LOJA, "A1_LC", .F.)))})
	oFormFil:SetProperty('Z9_LOJA',  MODEL_FIELD_INIT, {|| IIF(INCLUI,'', VAL(U_INTE02IG("SA1", 1, SZ9->Z9_CODCLI + SZ9->Z9_LOJA, "A1_LOJA", .F.)))})
	

    
    oFormFil:AddTrigger("Z9_LOJA", "Z9_NOMECLI", {|| .T.}, {|oView| U_INTE02IG("SA1", 1, oView:GetValue('Z9_CODCLI') + oView:GetValue('Z9_LOJA'), "A1_NOME", .T.)})
	oFormFil:AddTrigger("Z9_LOJA", "Z9_CNPJ", {|| .T.}, {|oView| U_INTE02IG("SA1", 1, oView:GetValue('Z9_CODCLI') + oView:GetValue('Z9_LOJA'), "A1_CGC", .T.)})
	oFormFil:AddTrigger("Z9_LOJA", "Z9_LIMITE", {|| .T.}, {|oView| VAL(U_INTE02IG("SA1", 1, oView:GetValue('Z9_CODCLI') + oView:GetValue('Z9_LOJA'), "A1_LC", .T.))})
	oFormFil:AddTrigger("Z9_LIMITE", "Z9_LIMITE", {|| .T.}, {|oView| VAL(U_INTE02IG("SA1", 1, oView:GetValue('Z9_CODCLI') + oView:GetValue('Z9_LOJA'), "A1_LC", .T.))})
	
 
	//Criando modelo de dados

	oModel := MPFormModel():New('VIXA266M',{|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )
	oModel:AddFields("FORMPAI",/*cOwner*/,oFormPai)// Cabeçalho - PAI
	oModel:AddGrid('FORMGRID', "FORMPAI", oFormFil, /*bLinePre*/, /*bLinePost*/ ,/* bLinePrev */ , /*bLoad*/)// Grid - FILHO

 
	

	//Criando o relacionamento FILHO e PAI 
	aAdd(aSZ9Rel, {'Z9_CODIGO', 'IIf(!INCLUI, SZ9->Z9_CODIGO, FWxFilial("SZ9"))'} )
	
	//Criando o relacionamento
	oModel:SetRelation('FORMGRID', aSZ9Rel, SZ9->(IndexKey(1)))

	//Setando o campo único da grid para não ter repetição
	//oModel:GetModel('FORMGRID'):SetUniqueLine({"Z9_CODCLI", "Z9_LOJA"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMPAI"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel


// ALFONSO
Static Function ViewDef()

	Local oModel   := FWLoadModel("VIXA266")
	Local oFormPai := FWFormStruct(2, 'SZ9', {|cCampo| AllTrim(cCampo) $ "Z9_CODIGO|Z9_DESC|Z9_LCGRUPO|"}) // exibe campos na parte de cima do GRID
	//Local oFormFil := FWFormStruct(2, 'SZ9', {|cCampo| AllTrim(cCampo) $ "Z9_CODCLI|Z9_LOJA|Z9_NOMECLI|Z9_CNPJ|Z9_LIMITE|Z9_ORIGEM|"})// exibe campos na GRID
	Local oFormFil := FWFormStruct(2, 'SZ9', {|cCampo| AllTrim(cCampo) $ "Z9_CODCLI|Z9_LOJA|Z9_NOMECLI|Z9_CNPJ|Z9_LIMITE|"})// exibe campos na GRID
	
	//Local oFormFil := FWFormStruct(2, 'SZ9', {|cCampo| AllTrim(cCampo) $ "Z9_CODCLI|Z9_LOJA|Z9_NOMECLI|Z9_CNPJ|Z9_ORIGEM|"})// exibe campos na GRID
	
	Local oView    := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB"	, oFormPai	, "FORMPAI")
	oView:AddGrid ('VIEW_SZ9'	, oFormFil	, "FORMGRID")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_SZ9','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', 'Grupo Economico')
	oView:EnableTitleView('VIEW_SZ9', 'Clientes do Gr. economico')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

Return oView
 

Static Function fLinOK(oGrid,nLine)
	Local nOpc := oGrid:GetOperation()
	Local lRet := .T.
	Help( ,, 'FWMODELPOS',, "fLinOK", 1, 0) // alfonso
	
Return(lRet)

Static Function fPreValidCad(oModel)
	Local lRet :=.T.
	Local nOpc := oModel:getoperation()
	Help( ,, 'FWMODELPOS',, "fPreValidCad", 1, 0) // alfonso
Return(lRet)


//Valida linha duplicada Cliente Loja
Static Function VLDCLILJ(cCodCli, cCodLoja, cCod)
	
	Local cNextAlias  	:= GetNextAlias()
	Local cQuery		:= ""
	Local lRet			:= .F.
	
	cQuery := " SELECT TOTAL=COUNT(*) "
	cQuery += "  FROM " + RetSqlName("SZ9") + " SZ9 " 
	cQuery += " WHERE "
	cQuery += " SZ9.Z9_CODCLI = '"+cCodCli+"' "
	cQuery += " AND SZ9.Z9_LOJA = '"+cCodLoja+"' "
	cQuery += " AND SZ9.Z9_CODIGO <> '"+cCod+"' "
	cQuery += " AND SZ9.D_E_L_E_T_ = '' "
 
	TCQuery cQuery New Alias cNextAlias
  
	If (!cNextAlias->(EoF())) 
		If (cNextAlias->TOTAL > 0)
			lRet := .T.
		EndIf
	EndIf
 
	cNextAlias->(DbCloseArea())
	
Return lRet


	
Static Function fTudoOK(oModel)

	Local lRet		 	:= .T.
	Local lRetValida	:= .F.
	Local nX   		 	:= 0
	Local nZ   		 	:= 0
	Local nCount   		:= 0
	Local cCodCli   	:= ""
	Local nOpc			:= oModel:GetOperation()
	Local oPai			:= oModel:GetModel("FORMPAI")
	Local oGrid      	:= oModel:GetModel("FORMGRID")
	
	Local nSoma			:= 0

	

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
		//percorrendo  o grid
		For nX := 1 To oGrid:GetQtdLine()
			oGrid:GoLine(nX) // posiciona no primeiro item do grid
			If !oGrid:IsDeleted() // ignora linhas deletadas
								
				lRetValida := VLDCLILJ(oGrid:GetValue('Z9_CODCLI'), oGrid:GetValue('Z9_LOJA'), oPai:GetValue('Z9_CODIGO'))
				nSoma += oGrid:GetValue('Z9_LIMITE')	
				If (lRetValida) 					
					Help( ,, 'HELP',, "O Cliente "+cvaltochar(oGrid:GetValue('Z9_CODCLI'))+"  já foi cadastrado em outro grupo economico. " , 1, 0)
					lRet := .F.
					Exit
				Else

					cCodCli := oGrid:GetValue('Z9_CODCLI')
					nCount := 0
					For nZ := 1 To oGrid:GetQtdLine()
						oGrid:GoLine(nZ)
						If !oGrid:IsDeleted()
							If oGrid:GetValue('Z9_CODCLI') == cCodCli
								nCount++																
							EndIf
						EndIf
					Next nZ

					If nCount > 1						
						Help( ,, 'HELP',, "O Cliente "+cvaltochar(cCodCli)+"  está duplicado. " , 1, 0)
						lRet := .F.
						Exit								
					EndIf

				EndIf				

			EndIf
		Next nX


		oPai:SetValue("Z9_LCGRUPO", nSoma)
		
	EndIf
	

		
Return(lRet)



Static Function fCommit(oModel)

	Local lRet 		 := .T.
	Local oGrid		 := oModel:GetModel("FORMGRID")
	Local oForm		 := oModel:GetModel("FORMPAI")
	Local nX   		 := 0
	Local nY		 := 0
	Local nOpc 		 := oModel:GetOperation()
	Local aCposForm  := oForm:GetStruct():GetFields()
	Local aCposGrid  := oGrid:GetStruct():GetFields()

	If nOpc == MODEL_OPERATION_INSERT

		ConfirmSX8()

	EndIf

	For nX := 1 To oGrid:GetQtdLine()

		oGrid:GoLine(nX)

		SZ9->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE

			//-- Deleta registro
			SZ9->(RecLock("SZ9",.F.))
				SZ9->(dbDelete())
			SZ9->(MsUnLock())

		Else

			//-- Grava inclusao/alteracao
			SZ9->(RecLock("SZ9", SZ9->(EOF())))

			If oGrid:IsDeleted()

				SZ9->(dbDelete())

			Else

				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)

					If SZ9->(FieldPos(aCposForm[nY,3])) > 0

						SZ9->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])

					EndIf

				Next nY

				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)

					If SZ9->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "Z9_FILIAL"

						SZ9->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])

					EndIf

				Next nY

			EndIf

			SZ9->(MsUnLock())

			SZ9->(RecLock("SZ9",.F.))
			SZ9->Z9_FILIAL := xFilial("SZ9")
			SZ9->(MsUnLock())

		EndIf

	Next nX
	
Return(lRet)

Static Function fCancel(oModel)

	Local lRet 		 := .T.
	Local oForm		 := oModel:GetModel("FORMPAI")
	Local oGrid		 := oModel:GetModel("FORMGRID")
	Local nOpc 		 := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT

		RollBAckSx8()

	EndIf

Return(lRet)


// GATILLOS
User Function INTE02IG(cTab, nIndex, cConteudo, cCampoRet, lTrigger, aCampoDest)

	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oView		:= FwViewActive()
	Local cRetorno	:= ""
	
	Default cTab		:= ""
	Default lTrigger 	:= .F.
	Default aCampoDest	:= {}

	If (!oView:IsActive() .And. !INCLUI) .Or. lTrigger
		
		If ! Empty(cTab)

			cRetorno := PadL(Posicione(cTab, nIndex, xFilial(cTab) + cConteudo, cCampoRet), TamSx3(cCampoRet)[1])

		EndIf		

	EndIf	

	If ! Empty(oModel)

		AtuLCreG(oModel)// atualiza LIMITE DE CREDITO DO GRUPO ALFONSO	
		
	EndIf

	
Return(cRetorno)



//Atualiza limite credido Grupo
Static Function AtuLCreG(oModel)
	
	Local oPai			:= oModel:GetModel("FORMPAI")
	Local oGrid      	:= oModel:GetModel("FORMGRID")
	Local nX   		 	:= 0
	Local nSoma			:= 0
	
	For nX := 1 To oGrid:GetQtdLine()
		oGrid:GoLine(nX) // posiciona no primeiro item do grid
		If oGrid:IsDeleted() == .F. // ignora linhas deletadas
			nSoma += oGrid:GetValue('Z9_LIMITE')
		EndIf
		 
	Next nX		

	oPai:SetValue("Z9_LCGRUPO", nSoma)
 
	
Return 


Static Function LinePre(oModelGrid)
	
	Local oModel	:= FWModelActive() 
	
	If ! Empty(oModelGrid)

		AtuLCreG(oModel)// atualiza LIMITE DE CREDITO DO GRUPO ALFONSO	
		
	EndIf
 
Return

Static Function LinePrev(oModelGrid)
	
	Local oModel	:= FWModelActive() 
	
	If ! Empty(oModelGrid)

		AtuLCreG(oModel)// atualiza LIMITE DE CREDITO DO GRUPO ALFONSO	
		
	EndIf
 
Return


 
