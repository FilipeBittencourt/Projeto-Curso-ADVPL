#include "protheus.ch"
#include "msmgadd.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH

Static cTitulo := "Cadastro PC x Rota/Trecho"
Static cCodGestor := GetNewPar('MV_YAPROV','001656_000606')

User Function zModel2()

	Local aArea       := GetArea()
	Local oBrowse     := nil

	Private aRotina   := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZE')
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetFilterDefault("ZZE->ZZE_NUM == SC7->C7_NUM")
	//oBrowse:AddLegend("ZZE_STATUS = 'N'", "GREEN", "Novo")
	//oBrowse:AddLegend("ZZE_STATUS = 'A'", "RED"  , "Aprovado")
	oBrowse:Activate()
	RestArea(aArea)

Return


Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	//ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	//ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()

	Local oModel   := Nil
	Local oFormPai := FWFormStruct(1, 'ZZE', {|cCampo| AllTrim(cCampo) $ "ZZE_CODIGO|ZZE_NUM|ZZE_CODFOR|ZZE_LOJA|ZZE_CTRANS|ZZE_DESCTR|"}) // exibe campos na parte de cima do GRID
	Local oFormFil := FWFormStruct(1, 'ZZE', {|cCampo| AllTrim(cCampo) $ "ZZE_TRECHO|ZZE_UFORIG|ZZE_CIDORI|ZZE_DESCIO|ZZE_UFDEST|ZZE_CIDDES|ZZE_DESCID|ZZE_MODALI|"})// exibe campos na GRID
	Local aZZERel  := {}

	oFormPai:SetProperty('ZZE_NUM'	, MODEL_FIELD_INIT, {|oView| SC7->C7_NUM })
	oFormPai:SetProperty('ZZE_DESCTR'	, MODEL_FIELD_INIT, {|oView| U_VIX257IG("SA4", 1, ZZE->ZZE_CTRANS	, "A4_NOME")})
	oFormPai:SetProperty('ZZE_CODFOR'	, MODEL_FIELD_INIT, {|oView| U_VIX257IG("SC7", 1, SC7->C7_NUM		, "C7_FORNECE")})
	oFormPai:SetProperty('ZZE_LOJA'	, MODEL_FIELD_INIT, {|oView| U_VIX257IG("SC7", 1, SC7->C7_NUM		, "C7_LOJA")})

	//Gatilhos para preencher campos com consultas padr�o
	oFormPai:AddTrigger("ZZE_CTRANS", "ZZE_DESCTR"	, {|| .T.}, {|oView| U_VIX257IG("SA4", 1, oView:GetValue('ZZE_CTRANS')	, "A4_NOME", .T.)})
	oFormPai:AddTrigger("ZZE_NUM"	, "ZZE_CODFOR"	, {|| .T.}, {|oView| U_VIX257IG("SC7", 1, oView:GetValue('ZZE_NUM')		, "C7_FORNECE", .T.)})
	oFormPai:AddTrigger("ZZE_NUM"	, "ZZE_LOJA"	, {|| .T.}, {|oView| U_VIX257IG("SC7", 1, oView:GetValue('ZZE_NUM')		, "C7_LOJA", .T.)})

	oFormFil:AddTrigger("ZZE_CIDORI", "ZZE_DESCIO", {|| .T.}, {|oView| U_VIX257IG("CC2", 1, oView:GetValue('ZZE_UFORIG') + oView:GetValue('ZZE_CIDORI'), "CC2_MUN", .T.)})
	oFormFil:AddTrigger("ZZE_CIDDES", "ZZE_DESCID", {|| .T.}, {|oView| U_VIX257IG("CC2", 1, oView:GetValue('ZZE_UFDEST') + oView:GetValue('ZZE_CIDDES'), "CC2_MUN", .T.)})

	// TRIGGER  para apagar o nome quando o estado sofrer altera��o
	oFormFil:AddTrigger("ZZE_UFORIG", "ZZE_CIDORI", {|| .T.}, {|oView| Space(TamSx3("ZZE_CIDORI")[1]) })
	oFormFil:AddTrigger("ZZE_UFORIG", "ZZE_DESCIO", {|| .T.}, {|oView| Space(TamSx3("ZZE_DESCIO")[1]) })
	oFormFil:AddTrigger("ZZE_UFDEST", "ZZE_CIDDES", {|| .T.}, {|oView| Space(TamSx3("ZZE_CIDDES")[1]) })
	oFormFil:AddTrigger("ZZE_UFDEST", "ZZE_DESCID", {|| .T.}, {|oView| Space(TamSx3("ZZE_DESCID")[1]) })

	//Criando modelo de dados
	oModel := MPFormModel():New('VIXA257M', {|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )
	oModel:AddFields("FORMPAI",/*cOwner*/,oFormPai)// Cabe�alho - PAI
	oModel:AddGrid('FORMGRID',"FORMPAI",oFormFil) // Grid - FILHO

	//Criando o relacionamento FILHO e PAI
	aAdd(aZZERel, {'ZZE_CODIGO', 'IIf(!INCLUI, ZZE->ZZE_CODIGO, FWxFilial("ZZE"))'} )
	// aAdd(aZZERel, {'ZZE_TRECHO', 'IIf(!INCLUI, ZZE->ZZE_TRECHO, "")'} )

	//Criando o relacionamento
	oModel:SetRelation('FORMGRID', aZZERel, ZZE->(IndexKey(1)))

	//Setando o campo �nico da grid para n�o ter repeti��o
	oModel:GetModel('FORMGRID'):SetUniqueLine({"ZZE_TRECHO"})

	//Setando outras informa��es do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMPAI"):SetDescription("Formul�rio do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("zModel2")
	Local oFormPai := FWFormStruct(2, 'ZZE', {|cCampo| AllTrim(cCampo) $ "ZZE_CODIGO|ZZE_NUM|ZZE_CODFOR|ZZE_LOJA|ZZE_CTRANS|ZZE_DESCTR|"}) // exibe campos na parte de cima do GRID
	Local oFormFil := FWFormStruct(2, 'ZZE', {|cCampo| AllTrim(cCampo) $ "ZZE_TRECHO|ZZE_UFORIG|ZZE_CIDORI|ZZE_DESCIO|ZZE_UFDEST|ZZE_CIDDES|ZZE_DESCID|ZZE_MODALI"})// exibe campos na GRID
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB"	, oFormPai	, "FORMPAI")
	oView:AddGrid ('VIEW_ZZE'	, oFormFil	, "FORMGRID")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 30)
	oView:CreateHorizontalBox('GRID' , 70)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZZE','GRID')

	//Habilitando t�tulo
	oView:EnableTitleView('VIEW_CAB', 'PC e Transportadora')
	oView:EnableTitleView('VIEW_ZZE', 'Rotas - Trechos')

	//Tratativa padr�o para fechar a tela
	oView:SetCloseOnOk({||.T.})

	oView:addIncrementField("FORMGRID", "ZZE_TRECHO")

	//Remove os campos de Filial e Tabela da Grid
	/*oStFilho:RemoveField('ZZE_CODIGO')*/

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
	Local oGrid      := oModel:GetModel("FORMGRID","ZZE_TRECHO")

	Local cUsrAux := ""
	Local cPswAux := ""

	Local cUFOrig  := "" // estado de origem
	Local cCidOrig := "" // cidade de origem
	Local cUFDest  := "" // estado de Destino
	Local cCidDest := "" // cidade de Destino

	If !(RetCodUsr() $ cCodGestor)

		If nOpc == MODEL_OPERATION_DELETE .Or. nOpc == MODEL_OPERATION_UPDATE

			If !StaticCall(VIXA114, AnaliBloqueio, SC7->C7_NUM) // Ja liberado

				If Aviso("ATENCAO", "Pedido j� esta liberado. Seu usu�rio n�o tem permiss�o para " + If(nOpc == MODEL_OPERATION_DELETE, " exclus�o!", " altera��o!") + CRLF, {"Autoriza��o Gestor", "Cancela"}, 3) == 1

					If !U_VIXA259(@cUsrAux, @cPswAux)

						Return(.F.)

					EndIf

				Else

					Return(.F.)

				EndIf

			EndIf

		EndIf

	EndIf

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE



		//percorrendo  o grid
		For nX := 1 To oGrid:GetQtdLine()
			oGrid:GoLine(nX) // posiciona no primeiro item do grid
			If !oGrid:IsDeleted() // ignora linhas deletadas
				lRet := fLinOK(oGrid,nX)

				//N�o permite cadastrar rotas iguais
				If((oGrid:GetValue('ZZE_UFORIG') == oGrid:GetValue('ZZE_UFDEST')) .AND.  (oGrid:GetValue('ZZE_CIDORI') == oGrid:GetValue('ZZE_CIDDES')))
					Help( ,, 'HELP',, "N�o � permitido cadastrar rotas iguais, favor verificar", 1, 0)
					lRet := .F.
					Exit
				EndIf

				// come�ar a validar a partir da segunda linha caso exista. Onde o destino precisa ser a origem do trecho seguinte
				If nX > 1
					If(cUFDest != oGrid:GetValue('ZZE_UFORIG'))
						Help( ,, 'HELP',, "O estado da origem do pr�ximo trecho precisa ser igual ao estado do destino anterior", 1, 0)
						lRet := .F.
						Exit
					EndIf

					If(cCidDest != oGrid:GetValue('ZZE_CIDORI'))
						Help( ,, 'HELP',, "A cidade da origem do pr�ximo trecho precisa ser igual a cidade do destino anterior", 1, 0)
						lRet := .F.
						Exit
					EndIf
				EndIf
				cUFOrig := oGrid:GetValue('ZZE_UFORIG')
				cCidOrig := oGrid:GetValue('ZZE_CIDORI')
				cUFDest := oGrid:GetValue('ZZE_UFDEST')
				cCidDest := oGrid:GetValue('ZZE_CIDDES')

				// O ultimo destino destino precisa terminar na cidade em que a FILIA s encontra
					/*If(nX == oGrid:GetQtdLine())  							 
				If((oGrid:GetValue('ZZE_UFDEST') != SM0->M0_ESTCOB) .OR. (SubStr(SM0->M0_CODMUN,3) != oGrid:GetValue('ZZE_CIDDES')))
						 	Help( ,, 'HELP',, "O �ltimo trecho de destino precisa ser o da pr�pria Filial: " + cValToChar(SM0->M0_CIDCOB)+" - "+ cValToChar(SM0->M0_ESTCOB), 1, 0)
							lRet := .F.
							Exit
				EndIf
			EndIf*/


		EndIf
	Next nX

EndIf
		
Return(lRet)

//Valida fornecedor para n�o permitir cadastrar uma rota para um que j� tenha.
User Function VIX257PC()
		
	Local oModel	:= FWModelActive()
	Local nOpc 	:= oModel:GetOperation()
	Local lRet   := .T.
		
	If nOpc == MODEL_OPERATION_INSERT
		ZZE->(dbSetOrder(1)) // orderna sempre pelo indice nesse caso o 1   ZZE_FILIAL+ZZE_CODFOR+ZZE_LOJA+ZZE_CTRANS
		If (ZZE->(DBSEEK(xFilial("ZZE")+oModel:GetValue('FORMPAI','ZZE_NUM')))) // posiciona no primeiro registro da tabela em quest�o segundo a ordem do indice no  dbSetOrder(1)
			Help( ,, 'HELP',, "Este pedido j� possui uma rota cadastrada, favor escolher outro. ", 1, 0)
			lRet :=  .F.
		EndIf
	EndIf
	
	SC7->(dbSetOrder(1)) // orderna sempre pelo indice nesse caso o 1   ZZE_FILIAL+ZZE_CODFOR+ZZE_LOJA+ZZE_CTRANS
	If !(SC7->(DBSEEK(xFilial("SC7")+oModel:GetValue('FORMPAI','ZZE_NUM')))) // posiciona no primeiro registro da tabela em quest�o segundo a ordem do indice no  dbSetOrder(1)
		Help( ,, 'HELP',, "Pedido inexistente, favor escolher outro. ", 1, 0)
		lRet :=  .F.
	EndIf
			
Return lRet

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

		ZZE->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE

			//-- Deleta registro
			ZZE->(RecLock("ZZE",.F.))
			ZZE->(dbDelete())
			ZZE->(MsUnLock())

		Else

			//-- Grava inclusao/alteracao
			ZZE->(RecLock("ZZE", ZZE->(EOF())))

			If oGrid:IsDeleted()

				ZZE->(dbDelete())

			Else

				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)

					If ZZE->(FieldPos(aCposForm[nY,3])) > 0

						ZZE->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])

					EndIf

				Next nY

				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)

					If ZZE->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "ZZE_FILIAL"

						ZZE->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])

					EndIf

				Next nY

			EndIf

			ZZE->(MsUnLock())

			ZZE->(RecLock("ZZE",.F.))
			ZZE->ZZE_FILIAL := xFilial("ZZE")
			ZZE->(MsUnLock())

		EndIf

	Next nX
	/*
	If nOpc == MODEL_OPERATION_UPDATE

	MsgInfo('Informa��es Gravadas com Sucesso!')

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

User Function VIX257IG(cTab, nIndex, cConteudo, cCampoRet, lTrigger, aCampoDest)

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

User Function VIX257()

Return()