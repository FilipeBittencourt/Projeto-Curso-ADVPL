#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} FPVETE02
@description Cadastro de Faixas de Premiacao de Promotoras
@author Fernando Rocha
@since 19/01/2017
@version undefined
@type function
/*/
User Function FPVETE02()
	/*Declarando as variáveis que serão utilizadas*/
	Local lRet			:= .T.
	Local aArea			:= Z80->(GetArea())
	Private oBrowse
	Private cTitle 		:= "Faixas de Premiação de Promotores"
	
	Private aListFaixa	:= {}
	Private aFaixas		:= {}
	
	aFaixas		:= {90,100,110,120,130,140,150}
	aListFaixa	:= {;
					"90% a 99,9%",;
					"100% a 109,9%",;
					"110% a 119,9%",;
					"120% a 129,9%",;
					"130% a 139,9%",;
					"140% a 149,9%",;
					"Acima de 150%";
					}

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("Z80")          

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cTitle)

	//Desliga a exibição dos detalhes
	oBrowse:DisableDetails()         

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)
Return
//-------------------------------------------------------------------
// Montar o menu Funcional
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 		OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.FPVETE02" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.FPVETE02" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.FPVETE02" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.FPVETE02" OPERATION 5 ACCESS 0
Return aRotina


Static Function ViewDef()

	Local oView
	Local oModel		:= ModelDef()
	Local oStr1			:= FWFormStruct(2, 'Z80')
	Local oStr2			:= FWFormViewStruct():New()
	Local nI			:= 0
	Local cFaixa		:= ""
	Local cId			:= ""
	
	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oStr1:RemoveField("Z80_CODFUN")
	oStr1:RemoveField("Z80_DESFUN")
	
	oStr1:RemoveField("Z80_CODSTE")
	oStr1:RemoveField("Z80_DESSTE")
	
	oStr1:RemoveField("Z80_PERC")
	oStr1:RemoveField("Z80_PREMIO")

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1, 'MASTER')

	//Estrutura do GRID (VIEW)
	//FWFORMVIEWSTRUCT():AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL
	oStr2:AddField("CODFUN"		, "01", "Função", "Código da Função",, "C", "@!",,"SRJ")
	oStr2:AddField("DESFUN"		, "02", "Descrição", "Descrição da Função",, "C", "@!",,,.F.)
	
	oStr2:AddField("CODSTE"	, "03", "Step", "Código do Step",, "C", "@!",,"ZAE")
	oStr2:AddField("DESSTE"	, "04", "Descrição", "Descrição da Step",, "C", "@!",,,.F.)
	
	For nI := 1 To Len(aListFaixa)
		cFaixa	:= PADL(nI, 2, "0")
		cId		:= PADL(nI+4, 2, "0")
		
		oStr2:AddField("FAIXA_"+cFaixa, cId, aListFaixa[nI], "",, "N", "@E 999,999.99")
		
		//oStr2:AddField("FAIXA_01"	, "03", "100% a 109,9%", "",, "N", "@E 999,999.99")
		//oStr2:AddField("FAIXA_02"	, "04", "110% a 119,9%", "",, "N", "@E 999,999.99")
		//oStr2:AddField("FAIXA_03"	, "05", "120% a 129,9%", "",, "N", "@E 999,999.99")
		//oStr2:AddField("FAIXA_04"	, "06", "130% a 139,9%", "",, "N", "@E 999,999.99")
		//oStr2:AddField("FAIXA_05"	, "07", "Acima de 140%", "",, "N", "@E 999,999.99")
	Next nI
	

	oView:AddGrid('Detalhe',oStr2,'DETAIL')

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'MASTER', 20)
	oView:CreateHorizontalBox( 'DETAIL', 80)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','MASTER')
	oView:SetOwnerView('Detalhe','DETAIL')

	oView:EnableTitleView('Formulario' , cTitle )
	//oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return oView


Static Function ModelDef()

	Local oModel
	Local oStr1	:= FWFormStruct( 1, 'Z80', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados

	//Criar objeto da estrutura do grip
	Local oStr2 := FWFORMMODELSTRUCT():New()
	Local aRel 	:= {}

	Local cFaixa := ""
	Local nI	 := 0	
	
	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New(cTitle, { | oModel | MVCPREVALID( oModel ) } , { | oMdl | MVCTUDOOK( oModel ) } , { | oMdl | MVCCOMMIT( oModel ) } , /*bCancel*/ )
	oModel:SetDescription(cTitle)

	oStr1:RemoveField( 'Z80_FILIAL' )                       

	//Validacoes do Cabecalho
	//oStr1:SetProperty("Z80_VIGINI", MODEL_FIELD_VALID, {|a,b,c,d,e| ValidPer(a,b,c,d,e) } )

	//oStr1:SetProperty("Z80_CODFUN", MODEL_FIELD_OBRIGAT, {|| .F. } )
	//oStr1:SetProperty("Z80_PERC", MODEL_FIELD_OBRIGAT, {|| .F. } )
	//oStr1:SetProperty("Z80_PREMIO", MODEL_FIELD_OBRIGAT, {|| .F. } )

	//oStr1:SetProperty("Z80_VIGINI"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	//oStr1:SetProperty("Z80_VIGFIM"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('MASTER',,oStr1,{|oModel|MVC001T(oModel)},,)
	
	
	//Define a chave primaria utilizada pelo modelo
	//oModel:SetPrimaryKey({'Z80_FILIAL', 'Z80_CODFUN', 'Z80_PERC', 'Z80_VIGINI'})
	
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'Z80_FILIAL', 'Z80_CODFUN', 'Z80_CODSTE', 'Z80_PERC', 'Z80_VIGINI'})
	
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('MASTER'):SetDescription('Cabecalho')

	//ESTRUTURA DE DADOS DO GRID
	//FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
	oStr2:AddField("VIGINI"		, "VIGINI"				, "VIGINI"	, "D", 8, 0)
	oStr2:AddField("VIGFIM"		, "VIGFIM"				, "VIGFIM"	, "D", 8, 0)

	oStr2:AddField("Função"		, "Código da Função"	, "CODFUN"	, "C", 6, 0)
	oStr2:AddField("Descrição"	, "Descrição da Função"	, "DESFUN"	, "C", 30, 0)
	
	oStr2:AddField("Step"		, "Código da Step"	, "CODSTE"	, "C", TAMSX3("Z80_CODSTE")[1], 0)
	oStr2:AddField("Descrição"	, "Descrição da Step"	, "DESSTE"	, "C", TAMSX3("Z80_DESSTE")[1], 0)
	
	For nI := 1 To Len(aListFaixa)
		cFaixa	:= PADL(nI, 2, "0")
		oStr2:AddField("Faixa "+cvaltochar(nI)	, "Faixa "+cvaltochar(nI), "FAIXA_"+cFaixa, "N", 14, 2)
	Next nI
	
	/*oStr2:AddField("Faixa 1"	, "Faixa 1"				, "FAIXA_01", "N", 14, 2)
	oStr2:AddField("Faixa 2"	, "Faixa 2"				, "FAIXA_02", "N", 14, 2)
	oStr2:AddField("Faixa 3"	, "Faixa 3"				, "FAIXA_03", "N", 14, 2)
	oStr2:AddField("Faixa 4"	, "Faixa 4"				, "FAIXA_04", "N", 14, 2)
	oStr2:AddField("Faixa 5"	, "Faixa 5"				, "FAIXA_05", "N", 14, 2)
	*/
	
	oStr2:AddTrigger("CODFUN", "DESFUN"	, {|| .T.}, {|a| GetDDFun(a) })
	oStr2:AddTrigger("CODSTE", "DESSTE"	, {|| .T.}, {|a| GetDDStep(a) })
	
	oModel:AddGrid('DETAIL','MASTER',oStr2,/*bLinePre*/, /*bLinePost*/,{|oModel| GridPre(oModel)}/*bPre - Grid Inteiro*/,{|oModel| GridPost(oModel)}/*bPos - Grid Inteiro*/,{|x| LoadZ80(x)})  //cOwner é para quem pertence
	oModel:getModel('DETAIL'):SetDescription('Detalhes')

	aAdd(aRel, {'VIGINI', 'Z80_VIGINI'})
	aAdd(aRel, {'VIGFIM', 'Z80_VIGFIM'})
	oModel:SetRelation('DETAIL', aRel, "Z80_VIGINI")

Return oModel

Static Function GridPost(oModel)
Return .T.

Static Function GridPre(oModel)
Return .T.

Static Function GetDDFun(oModel)
	Local _cDes
	Local _cCod := oModel:GetValue("CODFUN")

	_cDes := FDESC('SRJ',_cCod,'RJ_DESC',TAMSX3('RJ_DESC'),XFILIAL("SRJ"))

Return(_cDes)


Static Function GetDDStep(oModel)
	Local _cDes
	Local _cCod := oModel:GetValue("CODSTE")

	_cDes := FDESC('ZAE',_cCod,'ZAE_DESC',TAMSX3('ZAE_DESC'), XFILIAL("ZAE"))

Return(_cDes)


//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function MVC001T( oModel )
	Local lRet      := .T.

Return(lRet)


//-------------------------------------------------------------------
// Carregar os dados customizados para a tela - tabela Z80
//-------------------------------------------------------------------
Static Function LoadZ80(oModel)

	Local aDados 		:= {}
	Local aLinha 		:= {}
	Local aLinhaAux 	:= {}
	Local I				:= 0
	Local nIndice		:= 0
	Local cAliasTmp 	:= Nil
	Local nTotalPerc	:= 0 

	Local dVigIni := oModel:getmodel():getmodel("MASTER"):getvalue("Z80_VIGINI")
	Local dVigFim := oModel:getmodel():getmodel("MASTER"):getvalue("Z80_VIGFIM")
	
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NoParser%

		select TOTAL=COUNT(*) from (
			select Z80_PERC from %Table:Z80% where Z80_VIGINI = %Exp:DTOS(dVigIni)% and D_E_L_E_T_ = '' 
			group by Z80_PERC
			) A

	EndSql 
	If !(cAliasTmp)->(Eof())
		nTotalPerc := (cAliasTmp)->TOTAL
	EndIf
	(cAliasTmp)->(DbCloseArea())
	
	
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NoParser%

		select * from %Table:Z80% where Z80_VIGINI = %Exp:DTOS(dVigIni)% and D_E_L_E_T_ = '' 
		order by Z80_CODFUN, Z80_CODSTE, Z80_PERC

	EndSql 
	

	If !(cAliasTmp)->(Eof())

		nNumLinAtu := 0

		While !(cAliasTmp)->(Eof()) 

			aLinha := {}
			aAdd(aLinha,dVigIni)
			aAdd(aLinha,dVigFim)

			aAdd(aLinha,(cAliasTmp)->Z80_CODFUN)			
			aAdd(aLinha,FDESC('SRJ',(cAliasTmp)->Z80_CODFUN,'RJ_DESC',TAMSX3('RJ_DESC'),XFILIAL("SRJ")))
			
			aAdd(aLinha,(cAliasTmp)->Z80_CODSTEP)			
			aAdd(aLinha,FDESC('ZAE',(cAliasTmp)->Z80_CODSTEP,'ZAE_DESC',TAMSX3('ZAE_DESC'),XFILIAL("ZAE")))
			
			aLinhaAux := Array(Len(aListFaixa))
			
			For I := 1 To Len(aListFaixa)
				aLinhaAux[I] := 0
			Next I
			
			For I := 1 To nTotalPerc
				
				nIndice	:= aScan(aFaixas,{|x| x == (cAliasTmp)->Z80_PERC})
				If (nIndice > 0)
					aLinhaAux[nIndice] := (cAliasTmp)->Z80_PREMIO
				EndIf
				
				(cAliasTmp)->(DbSkip())			
			Next I
			
			For I := 1 To Len(aListFaixa)
				aAdd(aLinha, aLinhaAux[I])
			Next I

			nNumLinAtu++
			aAdd(aDados, {0,aLinha})

		EndDo

	EndIf

Return(aDados)

//-------------------------------------------------------------------
// Validações ao alterar qualquer conteudo em qualquer modelo
//-------------------------------------------------------------------
Static Function MVCPREVALID( oModel )
Return .T.      


//-------------------------------------------------------------------
// Validações ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou não
//-------------------------------------------------------------------
Static Function MVCTUDOOK( oModel )
	Local lRet      := .T.

	Local oModel	:= oModel:GetModel('MASTER')
	Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()
	Local cAliasTmp

	//Capturar o conteudo dos campos
	Local dVigIni	:= oModel:GetValue('Z80_VIGINI')
	Local dVigFim	:= oModel:GetValue('Z80_VIGFIM')

	if nOpc <> 3 .And. nOpc <> 4
		Return(.T.)
	endif

	cAliasTmp := GetNextAlias()

	if nOpc == 3

		BeginSql Alias cAliasTmp
			%NoParser%

			SELECT * FROM %Table:Z80% WHERE Z80_FILIAL = %XFilial:Z80% 
			AND ( (Z80_VIGINI >= %Exp:DTOS(dVigIni)% AND Z80_VIGINI <= %Exp:DTOS(dVigFim)%) OR	
			(Z80_VIGFIM >= %Exp:DTOS(dVigIni)% AND Z80_VIGFIM <= %Exp:DTOS(dVigFim)%) OR
			(Z80_VIGINI > %Exp:DTOS(dVigIni)% AND Z80_VIGFIM < %Exp:DTOS(dVigFim)%) )
			AND %NotDel%

		EndSql 

		If !(cAliasTmp)->(Eof())

			(cAliasTmp)->(DbCloseArea())
			MsgInfo("Existe registro conflitante para esta STEP/PERÍODO.","Atenção! (FPVETE02)")
			lRet := .F.

		EndIf

	ElseIf nOpc == 4

		Return(.T.)

	Endif

	RestArea(aArea)
Return lRet      


//-------------------------------------------------------------------
// Gravacao de Dados
//-------------------------------------------------------------------
Static Function MVCCOMMIT( oModel )
	Local aArea 	:= GetArea()
	Local oMaster	:= oModel:GetModel('MASTER')
	Local oDetail 	:= oModel:GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 

	Local dVigIni	:= oMaster:GetValue("Z80_VIGINI")
	Local dVigFim	:= oMaster:GetValue("Z80_VIGFIM")

	Local cCodStep	:= ""
	Local nPerce	:= 0	

	Local I, J

	//DELETE
	If ( nOper == 5 )

		Z80->(DbSetOrder(2))
		If Z80->(DbSeek(XFilial("Z80")+DTOS(dVigIni)))
			While !Z80->(Eof()) .And. Z80->(Z80_FILIAL+DTOS(Z80_VIGINI)) == (XFilial("Z80")+DTOS(dVigIni))
				RecLock("Z80",.F.)
				Z80->(DbDelete())
				Z80->(MsUnlock())
				Z80->(DbSkip())
			EndDo	
		EndIf		

		Return(.T.)	
	EndIf


	BEGIN TRANSACTION

		For I := 1 To oDetail:Length()
		
			oDetail:GoLine(I)

			If ( nOper == 3 )

				If !oDetail:IsDeleted()

					For J := 1 To Len(aListFaixa)

						nPerce := aFaixas[J]
							
						RecLock("Z80",.T.)
							
						Z80->Z80_FILIAL		:= XFILIAL("Z80")
						Z80->Z80_CODFUN		:= oDetail:GetValue("CODFUN", I)
						Z80->Z80_CODSTE		:= oDetail:GetValue("CODSTE", I)
						Z80->Z80_PERC		:= nPerce 
						Z80->Z80_PREMIO		:= oDetail:GetValue("FAIXA_"+StrZero(J,2), I)
						Z80->Z80_VIGINI		:= dVigIni
						Z80->Z80_VIGFIM		:= dVigFim

						Z80->(MsUnlock())

					Next J

				EndIf

			ElseIf ( nOper == 4 )

				If !oDetail:IsDeleted()

					For J := 1 To Len(aListFaixa)
						
						nPerce := aFaixas[J]
						
						Z80->(DbSetOrder(3))
						If Z80->(DbSeek(XFilial("Z80")+DTOS(dVigIni)+Str(nPerce,6,2)+oDetail:GetValue("CODFUN", I)+oDetail:GetValue("CODSTE", I)))

							RecLock("Z80",.F.)
							Z80->Z80_PREMIO		:= oDetail:GetValue("FAIXA_"+StrZero(J,2), I)
							Z80->(MsUnlock())
							
						Else
						
							RecLock("Z80",.T.)
	
							Z80->Z80_FILIAL		:= XFILIAL("Z80")
							Z80->Z80_CODFUN		:= oDetail:GetValue("CODFUN", I)
							Z80->Z80_CODSTE		:= oDetail:GetValue("CODSTE", I)
							Z80->Z80_PERC		:= nPerce 
							Z80->Z80_PREMIO		:= oDetail:GetValue("FAIXA_"+StrZero(J,2), I)
							Z80->Z80_VIGINI		:= dVigIni
							Z80->Z80_VIGFIM		:= dVigFim
	
							Z80->(MsUnlock())
						EndIf
						
					Next J

				Else

					For J := 1 To Len(aListFaixa)

						nPerce := aFaixas[J]
						
						Z80->(DbSetOrder(3))
						If Z80->(DbSeek(XFilial("Z80")+DTOS(dVigIni)+Str(nPerce,6,2)+oDetail:GetValue("CODFUN", I)+oDetail:GetValue("CODSTE", I)))

							RecLock("Z80",.F.)
							Z80->(DbDelete())
							Z80->(MsUnlock())
							
						EndIf
						
					Next J

				EndIf

			EndIf

		Next I

	END TRANSACTION

	RestArea(aArea)
Return(.T.)