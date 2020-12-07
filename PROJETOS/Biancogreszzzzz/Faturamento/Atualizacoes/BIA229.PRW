#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//------------------------------------------------------------------------------------------
// Autor: Thiago Dantas
// Desc	: Cadastro de Obras Novo -  Especificado
// Data : 09/12/2014	
//------------------------------------------------------------------------------------------

User Function BIA229()
	Local oBrowse
	Private dOdT 		:= dDataBase
	Private lCargaModel := .T.
	Private lEhRep 		:= .F.
	Private _UsuarAt
	Public __SC6_Filter := .T.

	If !cEmpAnt $ "01|05"
		MsgBox("Cadastro indisponível para empresa logada!","STOP")

		Return()
	EndIf

	DbSelectArea("ZZO")

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZO')
	oBrowse:SetDescription('Obras')
	oBrowse:SetMenuDef('BIA229')
	oBrowse:SetFilterDefault( FilDef() )

	oBrowse:AddLegend("ZZO_STATUS=='1'", "GREEN", "Em Especificação")
	oBrowse:AddLegend("ZZO_STATUS=='2'", "RED", "Fechado")
	oBrowse:AddLegend("ZZO_STATUS=='3'", "BLACK", "Perdido")
	oBrowse:AddLegend("ZZO_STATUS=='4'", "YELLOW", "Adiado")

	oBrowse:Activate()

Return()


Static Function FilDef()
	Local cFiltro 	:= ""
	Local _nomeuser := cUserName
	Local _daduser

	psworder(2)                          // Pesquisa por Nome

	If  pswseek(_nomeuser,.t.)           // Nome do usuario, Pesquisa usuarios
		_daduser  := pswret(1)            // Numero do registro
		_UsuarAt  := _daduser[1,1]
	EndIf

	If !Empty(AllTrim(cRepAtu))
		cFiltro += "ZZO_VEND = '"+Upper(AllTrim(cRepAtu))+"' "
	Else
		If Alltrim(Upper(_daduser[1,12])) == "ESPECIFICADORES" .And. Substr(Alltrim(_daduser[1,2]),1,1) = "A"
			cFiltro += "ZZO_VEND $ '"+Alltrim(Upper(_daduser[1,13]))+"' "
		EndIf
	EndIf

Return cFiltro


Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.BIA229' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.BIA229' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar' ACTION 'VIEWDEF.BIA229' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir' ACTION 'VIEWDEF.BIA229' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir' ACTION 'U_BIA564' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar' ACTION 'VIEWDEF.BIA229' OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Propostas' ACTION 'U_BFATTE01(.T.)' OPERATION 10 ACCESS 0

Return aRotina


Static Function ModelDef()
	Local oModel
	Local oStrObra := FWFormStruct(1,'ZZO')
	Local oStrEsp := FWFormStruct(1,'Z55')
	Local oStrZ61 := FWFormStruct(1, 'Z61')
	Local aRelacZ61 := {}
	Local bPre := {|oFieldModel, cAction, cIDField, xValue| BIA229PRE(oFieldModel, cAction, cIDField, xValue)}
	Local bPos := {|oFieldModel| BIA229POS(oFieldModel)}

	oModel := MPFormModel():New('BIA229M')

	oModel:addFields('MASTER',/**/, oStrObra, bPre, bPos)
	oModel:AddGrid('DETAIL', 'MASTER', oStrEsp)	

	oModel:SetDescription('Cadastro de Obras')
	oModel:GetModel('MASTER'):SetDescription('Dados da Obra')
	oModel:GetModel('DETAIL'):SetDescription('Especificação')	

	oModel:SetRelation('DETAIL', {{'Z55_FILIAL', 'xFilial("Z55")'}, {'Z55_OBRA', 'ZZO_NUM'}})
	oModel:SetPrimaryKey({'ZZO_NUM', 'Z55_PROD'})
	oModel:GetModel('DETAIL'):SetOptional(.T.)	


	// Tiago Rossini Coradini - OS: XXXX-XX - Aline Ribeiro - Pedidos de Venda da Obra

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	// Relacionamento da tabela de Pedidos da obra com a Obra e Produtos da Obra
	oModel:AddGrid('Z61DETAIL', 'MASTER', oStrZ61) //, { |oModelGrid,  nLine, cAction,cField| FNELINPRE(oModelGrid,cAction) }, { |oModelGrid| FNELINPOS(oModelGrid) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	aRelacZ61 := {}

	aAdd(aRelacZ61, {'Z61_FILIAL', 'xFilial("Z61")'})
	aAdd(aRelacZ61, {'Z61_OBRA', 'ZZO_NUM'})

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation('Z61DETAIL', aRelacZ61, Z61->(IndexKey(1)))

	// Deixa o prrenchimento das tabelas opcional
	oModel:GetModel('Z61DETAIL'):SetOptional(.T.)

	// Liga o controle de nao repeticao de linha
	oModel:GetModel('Z61DETAIL'):SetUniqueLine({'Z61_NUMPED', 'Z61_ITEM'})

	// Adiciona a descricao do Modelo de Dados
	oModel:GetModel('Z61DETAIL'):SetDescription("Pedidos")

	oModel:SetVldActivate( {|oModel| VldAtvMod(oModel) } )	

	CarPermis(oModel:GetModel('MASTER'))

Return(oModel)


Static Function ViewDef()
	Local oVwObra := FWFormStruct(2, 'ZZO')
	Local oVwEsp := FWFormStruct(2, 'Z55', {|x| AllTrim(x) $ 'Z55_PROD, Z55_QUANT'})
	Local oVwZ61 := FWFormStruct(2, 'Z61')
	Local oModel := FWLoadModel('BIA229')
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)		

	oView:AddField('VW_ZZO', oVwObra, 'MASTER')
	oView:AddGrid('VW_Z55', oVwEsp, 'DETAIL')	

	// Tiago Rossini Coradini - OS: XXXX-XX - Aline Ribeiro - Pedidos de Venda da Obra		

	// Remove campos da estrutura para nao aparecer na grid	
	oVwZ61:RemoveField('Z61_FILIAL')
	oVwZ61:RemoveField('Z61_OBRA')	

	oView:AddGrid('VW_Z61', oVwZ61, 'Z61DETAIL')

	oView:CreateHorizontalBox('SUPERIOR', 70)
	oView:CreateHorizontalBox('INFERIOR', 30)	

	// Cria Folder na view
	oView:CreateFolder('PASTA_INFERIOR', 'INFERIOR')

	// Cria pastas nas folders
	oView:AddSheet('PASTA_INFERIOR', 'ABA_PRODUTO', "Produtos")
	oView:AddSheet('PASTA_INFERIOR', 'ABA_PEDIDO', "Pedidos")

	// Criar "box" horizontal para receber algum elemento da view	
	oView:CreateHorizontalBox('BOX_PRODUTO', 100,,, 'PASTA_INFERIOR', 'ABA_PRODUTO')
	oView:CreateHorizontalBox('BOX_PEDIDO', 100,,, 'PASTA_INFERIOR', 'ABA_PEDIDO')	

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VW_ZZO', 'SUPERIOR')
	//oView:SetOwnerView('VW_Z55', 'INFERIOR')
	oView:SetOwnerView('VW_Z55', 'BOX_PRODUTO')
	oView:SetOwnerView('VW_Z61', 'BOX_PEDIDO')

	// Liga a identificacao do componente
	//oView:EnableTitle('VW_Z55', 'Produtos')
	//oView:EnableTitle('VIEW_Z61', 'Pedidos')

Return(oView)


Static Function BIA229PRE(oFieldModel, cAction, cIDField, xValue)
	Local lRet := .T.
	Local oModel := FWModelActive()
	Local oView := FWViewActive()
	Local nOperation := oModel:GetOperation()
	Local lAtualiza := .F.

	If oModel <> NIL

		nOperation := oModel:GetOperation()
		oModelMestre := oModel:GetModel('MASTER')
		oModelDetalhe := oModel:GetModel('DETAIL')

		//COMENTADO - Fernando/Facile - Projeto engenharia Fase 2 - o controle de status passa a ser pelas Propostas incluidas na Obra
		/*If AllTrim(cIDField) == 'ZZO_STATUS'

		cStatus := AllTrim(oModelMestre:GetValue(cIDField))

		If cAction == 'SETVALUE'

		If cStatus == 'F' .And. xValue != cStatus
		//Help( ,, 'HELP',, 'Não possível alterar o campo Status.', 1, 0)   
		//lRet := .F.
		Else
		If xValue != cStatus
		oModelMestre:SetValue('ZZO_ALTSTA',dDataBase)

		If xValue == 'F'
		oModelMestre:SetValue('ZZO_DTFECH', dDataBase)
		Else
		oModelMestre:SetValue('ZZO_DTFECH', sToD('  /  /  ') )							
		EndIf
		EndIf
		EndIf
		EndIf
		EndIf*/
	EndIf

Return(lRet)


Static Function BIA229POS(oFieldModel) //TUDO OK!
	Local lRet := .T.
	Local nOperation := 0
	Local oModel := FWModelActive()

	If oModel <> NIL

		nOperation := oModel:GetOperation()
		oModelMestre := oModel:GetModel('MASTER')
		oModelDetalhe := oModel:GetModel('DETAIL')

		///cStatus := oModel:GetValue('MASTER', 'ZZO_STATUS')
		cRedeObra := oModel:GetValue('MASTER', 'ZZO_REDEOB')

		//COMENTADO - Fernando/Facile - Projeto engenharia Fase 2 - o controle de status passa a ser pelas Propostas incluidas na Obra
		/*If cStatus == 'G' //Perdido.

		cDescPerd := oModel:GetValue('MASTER', 'ZZO_PERD')
		cMotPerd := oModel:GetValue('MASTER', 'ZZO_YMOTIV')

		If Empty(cDescPerd)
		Help( ,, 'HELP',, 'Favor informar o campo PERDIDO P/', 1, 0)   	
		lRet := .F.	
		EndIf

		If Empty(cMotPerd) .And. lRet
		Help( ,, 'HELP',, 'Favor informar o campo MOTIVO PERDA', 1, 0)
		lRet := .F.
		EndIf

		EndIf*/


		If lRet .And. Empty(cRedeObra)
			Help( ,, 'HELP',, 'Favor informar o campo ITC', 1, 0)
			lRet := .F.	
		EndIf


		//COMENTADO - Fernando/Facile - Projeto engenharia Fase 2 - o controle de status passa a ser pelas Propostas incluidas na Obra
		//A=Agendado Contato;B=Apres. produtos;C=Tentando especificar;D=Especificado;E=Adiado;F=Fechado;G=Perdido;H=Apres. Proposta;I=Fechado Parcial
		/*If lRet .And. cStatus $ "D_F_I"

		nI := 1

		// Valida Produtos
		While nI <= oModelDetalhe:Length() .And. lRet

		oModelDetalhe:GoLine(nI)

		cProduto := oModelDetalhe:GetValue('Z55_PROD')
		nQuant := oModelDetalhe:GetValue('Z55_QUANT')

		DbSelectArea("SB1")
		DbSetOrder(1)

		If Empty(AllTrim(cProduto))
		Help( ,, 'HELP',, 'Favor informar o PRODUTO a ser Especificado', 1, 0)
		lRet := .F.
		ElseIf !(dbSeek(xFilial("SB1")+cProduto))
		Help( ,, 'HELP',, 'Favor informar um PRODUTO válido', 1, 0)   	
		lRet := .F.	
		ElseIf nQuant == 0
		Help( ,, 'HELP',, 'Favor informar a QUANTIDADE do Produto Especificado', 1, 0)
		lRet := .F.
		EndIf

		nI++

		EndDo


		// Valida Pedidos
		If lRet .And. cStatus $ "F_I"

		oModelZ61 := oModel:GetModel('Z61DETAIL')

		nI := 1

		While nI <= oModelZ61:Length() .And. lRet

		cNumPed := ""
		cItem := ""
		cProd := ""

		oModelZ61:GoLine(nI)

		If !oModelZ61:IsDeleted()

		cNumPed := oModelZ61:GetValue('Z61_NUMPED')
		cItem := oModelZ61:GetValue('Z61_ITEM')
		cProd := oModelZ61:GetValue('Z61_PROD')
		cObra := oModel:GetValue('MASTER', 'ZZO_NUM')

		If Empty(AllTrim(cNumPed))
		Help( ,, 'HELP',, 'Favor informar o Número do Pedido Venda', 1, 0)
		lRet := .F.
		EndIf															

		If lRet .And. Empty(AllTrim(cItem))
		Help( ,, 'HELP',, 'Favor informar o Item do Pedido: '+ cNumPed +", utilize a busca via F3." , 1, 0)
		lRet := .F.
		EndIf


		If lRet

		DbSelectArea("SC6")
		DbSetOrder(1)
		If !SC6->(DbSeek(xFilial("SC6") + cNumPed + cItem + cProd ))

		Help(,, "HELP",, "Atenção, o pedido: "+ cNumPed + " item: "+ cItem +" não é valido.", 1, 0)
		lRet := .F.	

		Else

		lAchou := .F.
		nAux := 1

		While nAux <= oModelDetalhe:Length() .And. !lAchou

		oModelDetalhe:GoLine(nAux)

		If !oModelZ61:IsDeleted() .And. AllTrim(cProd) == AllTrim(oModelDetalhe:GetValue('Z55_PROD'))
		lAchou := .T.
		EndIf

		nAux++

		EndDo

		If !lAchou								 
		Help(,, "HELP",, "Atenção, o produto: "+ AllTrim(cProd) + " do pedido: "+ cNumPed + " item: "+ cItem +" não é valido, pois o mesmo não está assoicado aos produtos da obra.", 1, 0)
		lRet := .F.										
		EndIf

		EndIf

		EndIf

		EndIf

		nI++

		EndDo

		EndIf

		EndIf*/

	EndIf

Return(lRet)


Static Function EhRep(aGrupo)
	Local lRet := .F.
	Local nI := 0

	For nI:= 1 to Len(aGrupo)
		If AllTrim(GrpRetName(aGrupo[nI])) == 'REPOBRA'
			lRet := .T.
		EndIf
	Next	

Return(lRet)


Static Function CarPermis(oModelMestre)
	Local aGrp := UsrRetGrp(cUserName)
	//Local aCNoAlt := {'ZZO_NUM', 'ZZO_EMIS', 'ZZO_VEND', 'ZZO_NOMEV', 'ZZO_ESTV', 'ZZO_NROTOR', 'ZZO_NROAPT', 'ZZO_QTDPIS', 'ZZO_QTDREV', 'ZZO_QTDPOR', 'ZZO_QTDACE', 'ZZO_QTDTOT'}
	Local aCNoAlt := {'ZZO_NUM', 'ZZO_EMIS', 'ZZO_VEND', 'ZZO_NOMEV', 'ZZO_ESTV'}
	Local nI

	If oModelMestre <> NIL

		lEhRep := EhRep(aGrp)

		If lEhRep

			nI := 0

			For nI := 1 to Len(aCNoAlt)
				oStrObra := oModelMestre:GetStruct()
				oStrObra:SetProperty(aCNoAlt[nI], MODEL_FIELD_NOUPD, .T. )
			Next

		EndIf

	EndIf

Return()


User Function BIA229ATV(cField)
	Local lRet := .F.
	Local aGrp := UsrRetGrp(cUserName)

	If cField $ 'ZZO_STATUS_Z55_PROD_Z55_QUANT'
		lRet := ZZO->ZZO_STATUS <> '2' .Or. !EhRep(aGrp)
	EndIf 

Return lRet


User Function BIA229M()
	Local aParam := ParamIxb
	Local oModel := FWModelActive()
	Local xRet := .T.
	Local oObj := ''
	Local cIdPonto := ''
	Local cIdModel := ''
	Local lIsGrid := .F.
	Local nLinha := 0
	Local nQtdLinhas:= 0
	Local cMsg := ''
	Local cPedido

	If oModel <> NIL

		nOperation := oModel:GetOperation()
		oModelMestre := oModel:GetModel('MASTER')
		oModelDetalhe := oModel:GetModel('DETAIL')

	EndIf

Return(xRet)


// Tiago Rossini Coradini - OS: 2681-15 - Aline Ribeiro Lacerda
// Validação da ativação do modelo
Static Function VldAtvMod(oModel)
	Local lRet := .T.


Return(lRet)


// Tiago Rossini Coradini - OS: 2681-15 - Aline Ribeiro Lacerda
// Filtro dinamico nos pedidos de venda 
User Function __SC6_Filter()
	Local aArea := GetArea()
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSC5 := RetSQLName("SC5")
	Local cSC6 := RetSQLName("SC6")
	Local cFilter := ""
	Local cNumPed := ""	
	Local cDepar := Upper(AllTrim(PswRet()[1][12])) // Departamento
	Local cRepEsp := AllTrim(PswRet()[1][13]) // Cargo - Contem o codigo dos representantes do especificador

	// Efetua filtro caso o usuario seja representante ou espeficicador
	If !Empty(cRepAtu) .Or. (cDepar == "ESPECIFICADORES" .And. !Empty(cRepEsp))

		cSQL += " SELECT C5_NUM "
		cSQL += " FROM " + cSC5
		cSQL += " WHERE C5_FILIAL = "+ ValToSQL(xFilial("SC5"))

		// Tiago Rossini Coradini - OS: 4174-15 - Aline Ribeiro - Alteração no periodo para filtros de Pedidos da Obra
		cSQL += " AND C5_EMISSAO BETWEEN "+ ValToSQL(FirstDate(MonthSub(dDataBase, 1))) +" AND "+ ValToSQL(LastDate(dDataBase))
		cSQL += " AND C5_VEND1 IN ("+ fGetCodRep(cDepar, cRepEsp) +")"
		cSQL += " AND D_E_L_E_T_= '' "

		TcQuery cSQL New Alias (cQry)


		If (cQry)->(!Eof())

			cNumPed := ""

			While !(cQry)->(Eof())

				If !Empty(cNumPed)
					cNumPed += "/"
				EndIf

				cNumPed += PadR((cQry)->C5_NUM, TamSx3("C5_NUM")[1])

				(cQry)->(DbSkip())

			EndDo

			If !Empty(cNumPed)
				cNumPed := "C6_NUM $ '" + cNumPed + "'"
			EndIf

			cFilter	+= "@#"
			cFilter	+= "SC6->("
			cFilter	+= "C6_FILIAL=='"+xFilial("SC6")+"'"
			cFilter	+= ".AND."
			cFilter	+= "("+cNumPed+")"
			cFilter	+= ")"
			cFilter	+= "@#"

		Else
			cFilter	:= "@#0=1@#"
		EndIf

		(cQry)->(DbCloseArea())

	Else
		cFilter	:= "@#@#"
	EndIf

	RestArea(aArea)

Return(cFilter)


Static Function fGetCodRep(cDepar, cRepEsp)
	Local cRet := ""
	Local nCount := 0

	// Avalia se o usuario é um especificador, caso seja, retorna os codigos dos representantes
	If cDepar == "ESPECIFICADORES" .And. !Empty(cRepEsp)

		cRepEsp := StrTran(cRepEsp, "/")

		For nCount := 1 To Len(cRepEsp) Step 6

			cRet += "'" + SubStr(cRepEsp, nCount, 6) + "'"

			If nCount + 6 <= Len(cRepEsp)
				cRet += ","
			EndIf

		Next

	Else		   
		cRet += "'" + cRepAtu + "'"
	EndIf		

Return(cRet)

User Function BZZODCLI()
	Local _aAreaA1 := SA1->(GetArea())

	If ( M->ZZO_CLICAD == "S" ) 

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(XFilial("SA1")+M->ZZO_CODCLI+M->ZZO_LOJCLI))

			oModel := FwModelActive()      
			oModel:SetValue('MASTER','ZZO_NOMCLI',SubStr(SA1->A1_NOME,1,30))		
			oModel:SetValue('MASTER','ZZO_CNPJ',SA1->A1_CGC)
			oModel:SetValue('MASTER','ZZO_ENDCLI',Left(SA1->A1_END,TamSX3("ZZO_ENDCLI")[1]))
			oModel:SetValue('MASTER','ZZO_COMPLC',Left(SA1->A1_COMPLEM,TamSX3("ZZO_COMPLC")[1]))
			oModel:SetValue('MASTER','ZZO_BAIRRC',Left(SA1->A1_BAIRRO,TamSX3("ZZO_BAIRRC")[1]))
			oModel:SetValue('MASTER','ZZO_ESTCLI',SA1->A1_EST)
			oModel:SetValue('MASTER','ZZO_CODMC',SA1->A1_COD_MUN)
			oModel:SetValue('MASTER','ZZO_MUNC',SA1->A1_MUN)
			oModel:SetValue('MASTER','ZZO_TEL',SA1->A1_TEL)

			oView		:= FwViewActive()
			oView:Refresh()

			Return(M->ZZO_CODCLI)

		Else                     

			Alert("Cliente nï¿½o localizado!")
			Return("")

		EndIf 

	EndIf

	RestArea(_aAreaA1)
Return(M->ZZO_CODCLI)


User Function B229VLMP()

	If M->ZZO_YMOTIV == "5"
		MsgAlert("Favor informar o motivo da perda no campo Observação,","IMPORTANTE!")
	EndIf

Return(.T.)