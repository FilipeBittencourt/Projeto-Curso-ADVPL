#include "protheus.ch"
#include "msmgadd.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH

Static cTitulo := "Cadastro Fornecedor x Rota/Trecho"
Static cCodGestor := GetNewPar('MV_YAPROV','001656_000606')

User Function VIXA256()

	Local aArea       := GetArea()
	Local oBrowse     := nil

	//Private cCodGestor := GetNewPar('MV_YAPROV','001656_000606')
	private aRotina   := MenuDef()	

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZ0')
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetFilterDefault("ZZ0->ZZ0_CODFOR == SA2->A2_COD  .And.  ZZ0->ZZ0_LOJA == SA2->A2_LOJA")
	//oBrowse:SetFilterDefault("ZZ0->ZZ0_CODIGO == '000001'")	
	//oBrowse:AddLegend("ZZ0_STATUS = 'N'", "GREEN", "Novo") 
	//oBrowse:AddLegend("ZZ0_STATUS = 'A'", "RED"  , "Aprovado")
	oBrowse:Activate()
	RestArea(aArea)

Return


Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VIXA256' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VIXA256' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VIXA256' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VIXA256' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()

	Local oModel   := Nil
	Local oFormPai := FWFormStruct(1, 'ZZ0', {|cCampo| AllTrim(cCampo) $ "ZZ0_CODIGO|ZZ0_CODFOR|ZZ0_LOJA|ZZ0_CTRANS|ZZ0_DESCTR|"}) // exibe campos na parte de cima do GRID
	Local oFormFil := FWFormStruct(1, 'ZZ0', {|cCampo| AllTrim(cCampo) $ "ZZ0_TRECHO|ZZ0_UFORIG|ZZ0_CIDORI|ZZ0_DESCIO|ZZ0_UFDEST|ZZ0_CIDDES|ZZ0_DESCID|ZZ0_MODALI|"})// exibe campos na GRID
	Local aZZ0Rel  := {}

   oFormPai:SetProperty('ZZ0_DESCTR', MODEL_FIELD_INIT, {|oView| U_VIX256IG("SA4", 1, ZZ0->ZZ0_CTRANS, "A4_NOME")})	
   oFormPai:SetProperty('ZZ0_CODFOR', MODEL_FIELD_INIT, {|oView| SA2->A2_COD })   
   oFormPai:SetProperty('ZZ0_LOJA', MODEL_FIELD_INIT, {|oView| SA2->A2_LOJA })
 
	
	//Gatilhos para preencher campos com consultas padrão
	oFormPai:AddTrigger("ZZ0_CTRANS", "ZZ0_DESCTR", {|| .T.}, {|oView| U_VIX256IG("SA4", 1, oView:GetValue('ZZ0_CTRANS'), "A4_NOME", .T.)})		
	oFormPai:AddTrigger("ZZ0_CODFOR", "ZZ0_LOJA", 	{|| .T.}, {|oView| U_VIX256IG("SA2", 1, oView:GetValue('ZZ0_CODFOR'), "A2_LOJA", .T.)})
	oFormFil:AddTrigger("ZZ0_CIDORI", "ZZ0_DESCIO", {|| .T.}, {|oView| U_VIX256IG("CC2", 1, oView:GetValue('ZZ0_UFORIG') + oView:GetValue('ZZ0_CIDORI'), "CC2_MUN", .T.)})
	oFormFil:AddTrigger("ZZ0_CIDDES", "ZZ0_DESCID", {|| .T.}, {|oView| U_VIX256IG("CC2", 1, oView:GetValue('ZZ0_UFDEST') + oView:GetValue('ZZ0_CIDDES'), "CC2_MUN", .T.)})



    // TRIGGER  para apagar o nome quando o estado sofrer alteração    
	oFormFil:AddTrigger("ZZ0_UFORIG", "ZZ0_CIDORI", {|| .T.}, {|oView| Space(TamSx3("ZZ0_CIDORI")[1]) })
	oFormFil:AddTrigger("ZZ0_UFORIG", "ZZ0_DESCIO", {|| .T.}, {|oView| Space(TamSx3("ZZ0_DESCIO")[1]) })
	oFormFil:AddTrigger("ZZ0_UFDEST", "ZZ0_CIDDES", {|| .T.}, {|oView| Space(TamSx3("ZZ0_CIDDES")[1]) })
	oFormFil:AddTrigger("ZZ0_UFDEST", "ZZ0_DESCID", {|| .T.}, {|oView| Space(TamSx3("ZZ0_DESCID")[1]) })
		
	//Criando modelo de dados
	oModel := MPFormModel():New('VIXA256M', {|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )
	oModel:AddFields("FORMPAI",/*cOwner*/,oFormPai)// Cabeçalho - PAI
	oModel:AddGrid('FORMGRID',"FORMPAI",oFormFil) // Grid - FILHO


	//Criando o relacionamento FILHO e PAI 
	aAdd(aZZ0Rel, {'ZZ0_CODIGO', 'IIf(!INCLUI, ZZ0->ZZ0_CODIGO, FWxFilial("ZZ0"))'} )
	// aAdd(aZZ0Rel, {'ZZ0_TRECHO', 'IIf(!INCLUI, ZZ0->ZZ0_TRECHO, "")'} )

	//Criando o relacionamento
	oModel:SetRelation('FORMGRID', aZZ0Rel, ZZ0->(IndexKey(1)))

	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('FORMGRID'):SetUniqueLine({"ZZ0_TRECHO"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMPAI"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("VIXA256")
	Local oFormPai := FWFormStruct(2, 'ZZ0', {|cCampo| AllTrim(cCampo) $ "ZZ0_CODIGO|ZZ0_CODFOR|ZZ0_LOJA|ZZ0_CTRANS|ZZ0_DESCTR|"}) // exibe campos na parte de cima do GRID
	Local oFormFil := FWFormStruct(2, 'ZZ0', {|cCampo| AllTrim(cCampo) $ "ZZ0_TRECHO|ZZ0_UFORIG|ZZ0_CIDORI|ZZ0_DESCIO|ZZ0_UFDEST|ZZ0_CIDDES|ZZ0_DESCID|ZZ0_MODALI"})// exibe campos na GRID
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB"	, oFormPai	, "FORMPAI")
	oView:AddGrid ('VIEW_ZZ0'	, oFormFil	, "FORMGRID")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 30)
	oView:CreateHorizontalBox('GRID' , 70)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZZ0','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', 'Fornecedor e Transportadora')
	oView:EnableTitleView('VIEW_ZZ0', 'Rotas - Trechos')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

	oView:addIncrementField("FORMGRID", "ZZ0_TRECHO")

	//Remove os campos de Filial e Tabela da Grid
	/*oStFilho:RemoveField('ZZ0_CODIGO')*/

Return oView

Static Function fLinOK(oGrid,nLine)
	Local nOpc := oGrid:GetOperation()
	Local lRet := .T.
Return(lRet)

Static Function fPreValidCad(oModel)
	Local lRet :=.T.
	Local nOpc := oModel:getoperation()
Return(lRet)

Static Function fTudoOK(oModel)

	Local lRet		 := .T.
	Local nX   		 := 0
	Local nWhile       := 1
	Local nLinValid  := 0
	Local nOpc 		 := oModel:GetOperation()
	Local oField     := oModel:GetModel("FORMPAI")
	Local oGrid      := oModel:GetModel("FORMGRID","ZZ0_TRECHO")

	Local cUsrAux := ""
	Local cPswAux := ""

	Local cUFOrig  := "" // estado de origem
	Local cCidOrig := "" // cidade de origem
	Local cUFDest  := "" // estado de Destino
	Local cCidDest := "" // cidade de Destino

	If !(RetCodUsr() $ cCodGestor)

		If nOpc == MODEL_OPERATION_DELETE .Or. nOpc == MODEL_OPERATION_UPDATE

			If Aviso("ATENCAO", "Seu usuário não tem permissão para " + If(nOpc == MODEL_OPERATION_DELETE, " exclusão!", " alteração!") + CRLF, {"Autorização Gestor", "Cancela"}, 3) == 1

				If !U_VIXA259(@cUsrAux, @cPswAux)

					Return(.F.)

				EndIf

			Else

				Return(.F.)

			EndIf

		EndIf

	EndIf

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
	
			

			//percorrendo  o grid
		For nX := 1 To oGrid:GetQtdLine()
			oGrid:GoLine(nX) // posiciona no primeiro item do grid
			If !oGrid:IsDeleted() // ignora linhas deletadas
				lRet := fLinOK(oGrid,nX)

					//Não permite cadastrar rotas iguais
				If((oGrid:GetValue('ZZ0_UFORIG') == oGrid:GetValue('ZZ0_UFDEST')) .AND.  (oGrid:GetValue('ZZ0_CIDORI') == oGrid:GetValue('ZZ0_CIDDES')))
					Help( ,, 'HELP',, "Não é permitido cadastrar rotas iguais, favor verificar", 1, 0)
									
					lRet := .F.
					Exit
				EndIf
					
					// começar a validar a partir da segunda linha caso exista. Onde o destino precisa ser a origem do trecho seguinte 
				If nX > 1
					If(cUFDest != oGrid:GetValue('ZZ0_UFORIG'))
						Help( ,, 'HELP',, "O estado da origem do próximo trecho precisa ser igual ao estado do destino anterior", 1, 0)
						lRet := .F.
						Exit
					EndIf

					If(cCidDest != oGrid:GetValue('ZZ0_CIDORI'))
						Help( ,, 'HELP',, "A cidade da origem do próximo trecho precisa ser igual a cidade do destino anterior", 1, 0)
						lRet := .F.
						Exit
					EndIf
				EndIf
				cUFOrig := oGrid:GetValue('ZZ0_UFORIG')
				cCidOrig := oGrid:GetValue('ZZ0_CIDORI')
				cUFDest := oGrid:GetValue('ZZ0_UFDEST')
				cCidDest := oGrid:GetValue('ZZ0_CIDDES')
					
				   // O ultimo destino destino precisa terminar na cidade em que a FILIA s encontra 					 		 
					/*If(nX == oGrid:GetQtdLine())  							 
					    If((oGrid:GetValue('ZZ0_UFDEST') != SM0->M0_ESTCOB) .OR. (SubStr(SM0->M0_CODMUN,3) != oGrid:GetValue('ZZ0_CIDDES')))
						 	Help( ,, 'HELP',, "O último trecho de destino precisa ser o da própria Filial: " + cValToChar(SM0->M0_CIDCOB)+" - "+ cValToChar(SM0->M0_ESTCOB), 1, 0)
							lRet := .F.
							Exit
						EndIf
					EndIf*/


			EndIf
		Next nX

	EndIf
		
Return(lRet)



//Valida fornecedor para não permitir cadastrar uma rota para um que já tenha.
User Function VIX256FO()	

	Local oModel	:= FWModelActive()
	Local nOpc 	:= oModel:GetOperation()
	 
		
	 
		ZZ0->(dbSetOrder(1)) // orderna sempre pelo indice nesse caso o 1   ZZ0_FILIAL+ZZ0_CODFOR+ZZ0_LOJA+ZZ0_CTRANS
		If ( (ZZ0->(DBSEEK(xFilial("ZZ0")+oModel:GetValue('FORMPAI','ZZ0_CODFOR')))) .AND. nOpc == MODEL_OPERATION_INSERT) // posiciona no primeiro registro da tabela em questão segundo a ordem do indice no  dbSetOrder(1)			
			Help( ,, 'HELP',, 'Este fornecedor já possui uma rota cadastrada, favor escolher outro.', 1, 0)
		    	
		   Return	.F.
	   EndIF
	 	
		If (!ExistCpo("SA2", oModel:GetValue('FORMPAI','ZZ0_CODFOR') , 1) .AND. (nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE) )    				 
			Help( ,, 'HELP',, "Fornecedor inexistente, favor escolher outro. ", 1, 0)    
		   Return	.F.
	 	EndIf
	 	 
 Return .T.

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

		ZZ0->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE

			//-- Deleta registro
			ZZ0->(RecLock("ZZ0",.F.))
			ZZ0->(dbDelete())
			ZZ0->(MsUnLock())

		Else

			//-- Grava inclusao/alteracao
			ZZ0->(RecLock("ZZ0", ZZ0->(EOF())))

			If oGrid:IsDeleted()

				ZZ0->(dbDelete())

			Else

				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)

					If ZZ0->(FieldPos(aCposForm[nY,3])) > 0

						ZZ0->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])

					EndIf

				Next nY

				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)

					If ZZ0->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "ZZ0_FILIAL"

						ZZ0->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])

					EndIf

				Next nY

			EndIf

			ZZ0->(MsUnLock())

			ZZ0->(RecLock("ZZ0",.F.))
			ZZ0->ZZ0_FILIAL := xFilial("ZZ0")
			ZZ0->(MsUnLock())

		EndIf

	Next nX
	/*
	If nOpc == MODEL_OPERATION_UPDATE

	MsgInfo('Informações Gravadas com Sucesso!')

	EndIf
	*/
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

User Function VIX256IG(cTab, nIndex, cConteudo, cCampoRet, lTrigger, aCampoDest)

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

Return(cRetorno)

User Function VIX256E()

	DBSelectArea("ZZ0")
	ZZ0->(DBSetOrder(1)) // ZZ0_FILIAL, ZZ0_CODFOR, ZZ0_LOJA, ZZ0_CTRANS, R_E_C_N_O_, D_E_L_E_T_
	
	If ZZ0->(DBSeek(xFilial("ZZ0") + SA2->(A2_COD + A2_LOJA)))
	
		While ZZ0->(!EOF()) .And. ZZ0->(ZZ0_FILIAL + ZZ0_CODFOR + ZZ0_LOJA) == xFilial("ZZ0") + SA2->(A2_COD + A2_LOJA)

			ZZ0->(RecLock("ZZ0", .F.))
			ZZ0->(DBDelete())
			ZZ0->(MsUnLock())
			
			ZZ0->(DBSkip())
		
		EndDo
	
	EndIf
		
Return()