#Include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

User Function BPOLTE05()

	Local lRet 		:= .T.
	Local aArea 	:= ZF3->(GetArea())
	
	Private oBrowse	:= Nil
	Private cTitle	:= "Verbas Permitidas"
	
	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()
	
	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZF3")          
	
	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cTitle)
	
	//Desliga a exibição dos detalhes
	oBrowse:DisableDetails()         
	
	//Ativamos a classe
	oBrowse:Activate()
	
	RestArea(aArea)

Return


Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.BPOLTE05"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.BPOLTE05"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.BPOLTE05"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.BPOLTE05"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Aprovar"    	ACTION "U_BPTE05AP()" 		OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Reprovar"    	ACTION "U_BPTE05RE()" 		OPERATION 7 ACCESS 0
	
Return aRotina

Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= ModelDef()
	Local oStr1		:= FWFormStruct(2, 'ZF3')
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1, 'CamposZF3')
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , cTitle )
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return oView


Static Function ModelDef()
	
	Local oModel
	Local oStr1	:= FWFormStruct( 1, 'ZF3', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados
	
	oModel := MPFormModel():New(cTitle, /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , { | oMdl | MVC001C( oModel ) } ,, /*bCancel*/ )
	oModel:SetDescription(cTitle)
	
	oStr1:RemoveField( 'ZF3_FILIAL' )                       
	
	//setar campos nao alteraveis
	oStr1:SetProperty("ZF3_CADUSU", MODEL_FIELD_WHEN,{|oModel| .F. })
	oStr1:SetProperty("ZF3_CADDAT", MODEL_FIELD_WHEN,{|oModel| .F. })
	oStr1:SetProperty("ZF3_CADHOR", MODEL_FIELD_WHEN,{|oModel| .F. })
	oStr1:SetProperty("ZF3_APRDAT", MODEL_FIELD_WHEN,{|oModel| .F. })
	oStr1:SetProperty("ZF3_APRHOR", MODEL_FIELD_WHEN,{|oModel| .F. })
	oStr1:SetProperty("ZF3_APRUSU", MODEL_FIELD_WHEN,{|oModel| .F. })
	oStr1:SetProperty("ZF3_STATUS", MODEL_FIELD_WHEN,{|oModel| .F. })
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('CamposZF3', ,oStr1, {|oModel|MVC001T(oModel)}, , )
		
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZF3_FILIAL', 'ZF3_MARCA', 'ZF3_CATEGO'})
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel('CamposZF3'):SetDescription('CamposZF3')

Return oModel


//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function MVC001T( oModel )
	
	Local lRet      := .T.

Return(lRet)

// Validações ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou não
Static Function MVC001V( oModel )
	
	Local lRet      := .T.
	Local oModel	:= oModel:GetModel( 'CamposZF3' )
	Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()
	Local dDtIni	:= oModel:GetValue('ZF3_DATINI')
	Local dDtFim	:= oModel:GetValue('ZF3_DATFIM')
	Local lStatus	:= (oModel:GetValue('ZF3_STATUS') == 'A')
	
	If (dDtFim < dDtIni)
		MsgAlert("O campo 'Dt. Final' deve ser maior que 'Dt. Inicio'.","Alerta")
		lRet := .F.	
	EndIf
	
	If (lRet)
		If nOpc == 4
		
			If (dDtIni <= dDataBase .And. dDtIni <> ZF3->ZF3_DATINI .And. lStatus)
				MsgAlert("Não é possivel alterar a 'Dt. Inicio' pois a mesma já estar em vigor.","Alerta")
				lRet := .F.	
			EndIf
		
		EndIf
	EndIf
	
	RestArea(aArea)

Return lRet      

Static Function MVC001C( oModel )

	Local nOpc      := oModel:GetOperation()
	
	FWFormCommit( oModel ) 
	
	If (nOpc == 3)
		
		RecLock("ZF3",.F.)
		ZF3->ZF3_CADUSU := cUserName
		ZF3->ZF3_CADDAT := dDataBase
		ZF3->ZF3_CADHOR := SubStr(Time(),1,5)
		ZF3->(MsUnlock())	
		
	EndIf

Return .T.   
            
User Function BPTE05AP()
	
	Local aArea		:= GetArea()
	Local cAliasTmp := Nil
	Local cMsg		:= ""
	Local cId		:= ZF3->(Recno())
	
	If (Empty(ZF3->ZF3_STATUS))
	
		If !MsgNoYes("Tem certeza que deseja aprovar o registro?","BPOLTE05 - Aprovar")
			Return
		EndIf   
		
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			
			SELECT * FROM %Table:ZF3%
				WHERE 
				ZF3_MARCA		= %Exp:ZF3->ZF3_MARCA%	AND
				ZF3_CATEGO		= %Exp:ZF3->ZF3_CATEGO%	AND
				ZF3_STATUS		= 'A'			AND
				D_E_L_E_T_		= ''			AND
				(
					CONVERT(date, %Exp:ZF3->ZF3_DATINI%) BETWEEN CONVERT(date, ZF3_DATINI) AND CONVERT(date, ZF3_DATFIM)
					OR
					CONVERT(date, %Exp:ZF3->ZF3_DATFIM%) BETWEEN CONVERT(date, ZF3_DATINI) AND CONVERT(date, ZF3_DATFIM)	
				)
				AND R_E_C_N_O_ <> %Exp:cId%
		EndSql
		
		If ((cAliasTmp)->(EOF()))
			
			RecLock("ZF3",.F.)
				ZF3->ZF3_APRUSU := cUserName
				ZF3->ZF3_APRDAT := dDataBase
				ZF3->ZF3_APRHOR := SubStr(Time(),1,5)
				ZF3->ZF3_STATUS := "A"
			ZF3->(MsUnlock())
			
			MsgAlert("Registro aprovado com sucesso.","Alerta")
		
		Else
		
			cMsg := dtoc(stod((cAliasTmp)->ZF3_DATINI))+" - "+dtoc(stod((cAliasTmp)->ZF3_DATFIM))
			MsgAlert("Registro Marca/Categoria ["+cMsg+"] está ativo no periodo.","Alerta")
		
		EndIf
	
		(cAliasTmp)->(DbCloseArea())
	
	Else
		MsgAlert("Registro já está ativo.","Alerta")
	EndIf
		
	RestArea(aArea)
Return

User Function BPTE05RE()
	
	Local aArea	:= GetArea()
	Local cMsg 	:= ZF3->ZF3_MARCA+"/"+ZF3->ZF3_CATEGO+"/"+dtoc(ZF3->ZF3_DATINI)+" - "+dtoc(ZF3->ZF3_DATFIM)
	
	If (ZF3->ZF3_STATUS <> 'B')
		
		If !MsgNoYes("Tem certeza que deseja reprovar o registro ["+cMsg+"] ?","BPOLTE05 - Aprovar")
			Return
		EndIf   
		
		RecLock("ZF3",.F.)
			//ZF3->ZF3_REPUSU := cUserName
			//ZF3->ZF3_REPDAT := dDataBase
			//ZF3->ZF3_REPHOR := SubStr(Time(),1,5)
			ZF3->ZF3_STATUS := "B"
		ZF3->(MsUnlock())
				
	Else
		MsgAlert("Registro já está reprovado.","Alerta")
	EndIf
	
	RestArea(aArea)
Return