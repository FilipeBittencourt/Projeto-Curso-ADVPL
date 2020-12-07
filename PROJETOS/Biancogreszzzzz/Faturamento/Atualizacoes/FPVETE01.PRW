#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static lCopia 	:= .F.

/*/{Protheus.doc} FPVETE01
@description tela MVC para cadastro das metas mensais dos promotores de Venda
@author Fernando Rocha
@since 01/12/2016
@version 1.0
@type function
/*/

/*/{Protheus.doc} FPVETE01
@description Inclusão de Filtro interno para o usuario Loja/Promotor e ajuste na gravação dos dados
@obs OS: 1207-16  
@author Artur Antunes
@since 31/03/2017
@version 1.0
@type function
/*/
User Function FPVETE01()
	/*Declarando as variáveis que serão utilizadas*/
	Local lRet       := .T.
	Local aArea      := Z81->(GetArea())
	Private oBrowse  := nil
	Private cTitle   := "Cadastro de Metas de Promotores de Venda"
	Private lFiltro  := .F.
	Private aFiltro  := {}
	Private aGridOri := {}
	Private aGridIni := {}	

	//controles internos
	Private nNumLinAtu

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("Z81")         

	//Legenda
	oBrowse:AddLegend( "Z81_STATUS=='1'", "BR_BRANCO"	, "Nova" ) 
	oBrowse:AddLegend( "Z81_STATUS=='2'", "BR_AMARELO" 	, "Revisão" )  
	oBrowse:AddLegend( "Z81_STATUS=='3'", "BR_VERDE" 	, "Aprovada" )
	oBrowse:AddLegend( "Z81_STATUS=='4'", "BR_VERMELHO"	, "Cancelada" )

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
	ADD OPTION aRotina TITLE "Pesquisar"  		ACTION 'PesqBrw' 			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 		ACTION "VIEWDEF.FPVETE01" 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    		ACTION "VIEWDEF.FPVETE01" 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "U_FPV01Altera" 		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Revisar"			ACTION "U_FPV01Copia" 		OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE "Aprovar"    		ACTION "U_FPV01Aprova" 		OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Import.Excel"		ACTION "U_FPT01EXC" 		OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Legenda"    		ACTION "U_FPVT1Leg" 		OPERATION 6 ACCESS 0

Return aRotina

User Function FPVT1Leg()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_BRANCO"		, "Nova"  })
	AADD(aLegenda,{"BR_AMARELO"		, "Revisão"})
	AADD(aLegenda,{"BR_VERDE"		, "Aprovada"})
	AADD(aLegenda,{"BR_VERMELHO"	, "Cancelada"})

	BrwLegenda(cTitle, "Status", aLegenda)
Return

//-------------------------------------------------------------------
// BOTAO REVISAR
//-------------------------------------------------------------------
User Function FPV01Copia()

	Local cTitulo		:= "REVISAR"
	Local nOperation 	:= 9 // Define o modo de operacao como copia

	lCopia := .T.

	If !Z81->Z81_STATUS $ "3"
		MsgInfo("Status não permitido para revisão, somente permitido revisar metas aprovadas.","FPVETE01 - FPV01Copia")
		Return Nil
	EndIf	

	FWExecView(cTitulo,'VIEWDEF.FPVETE01',nOperation,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)

	lCopia := .F.

Return Nil

//-------------------------------------------------------------------
// BOTAO ALTERAR
//-------------------------------------------------------------------
User Function FPV01Altera()

	Local cTitulo		:= "ALTERAR"
	Local nOperation 	:= 4

	If !Z81->Z81_STATUS $ "1_2"
		MsgInfo("Status não permitido para alteração, favor usar o botão REVISAR","FPVETE01 - FPV01Altera")
		Return Nil
	EndIf	

	FWExecView(cTitulo,'VIEWDEF.FPVETE01',nOperation,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)

Return Nil

//-------------------------------------------------------------------
// BOTAO APROVAR
//-------------------------------------------------------------------
User Function FPV01Aprova

	If !Z81->Z81_STATUS $ "1_2"
		MsgInfo("Status não permitido para aprovação.","FPVETE01 - FPV01Aprova")
		Return Nil
	EndIf

	If !MsgNoYes("Tem certeza que deseja Aprovar a meta de promotores "+Z81->Z81_ANO+"/"+Z81->Z81_REVISA+" ?")
		Return Nil
	EndIf

	//Clicar Aprovar
	RecLock("Z81",.F.)
	Z81->Z81_STATUS := "3"
	Z81->Z81_APROV	:= cUserName
	Z81->Z81_DATAPR	:= dDataBase
	Z81->Z81_HORAPR	:= SubStr(Time(),1,5)
	Z81->(MsUnlock())

Return Nil

Static Function ViewDef()
	Local oView
	Local oModel	:= FWLoadModel('FPVETE01') 
	Local oStr1		:= FWFormStruct(2, 'Z81')
	Local oStr2		:= FWFormViewStruct():New()

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oStr1:RemoveField("Z81_DATCAD")
	oStr1:RemoveField("Z81_HORCAD")
	oStr1:RemoveField("Z81_STATUS")

	oStr1:SetProperty("Z81_ANO", MVC_VIEW_CANCHANGE, IIf(lCopia, .F., .T.) )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1, 'MASTER')

	//Estrutura do GRID (VIEW)
	//FWFORMVIEWSTRUCT():AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL
	oStr2:AddField("CODCLI"	, "01", "Cliente", "Código do Cliente",, "C", "@!",,"SA1Z31")
	oStr2:AddField("LOJCLI"	, "02", "Lj.Cli", "Loja do Cliente",, "C", "@!")
	oStr2:AddField("UF"		, "03", "UF", "UF",, "C", "@!",,,.F.)
	oStr2:AddField("NOMLOJ"	, "04", "Nome Loja", "Nome da Loja",, "C", "@!",,,.F.)
	oStr2:AddField("NOMFUN"	, "05", "Promotor", "Promotor de Vendas",, "C", "@!",,,.F.)

	oStr2:AddField("MES_01"	, "06", "Janeiro", "Janeiro",, "C", "@E 999,999,999")
	oStr2:AddField("MES_02"	, "07", "Fevereiro", "Fevereiro",, "C", "@E 999,999,999")
	oStr2:AddField("MES_03"	, "08", "Março", "Março",, "C", "@E 999,999,999")
	oStr2:AddField("MES_04"	, "09", "Abril", "Abril",, "C", "@E 999,999,999")
	oStr2:AddField("MES_05"	, "10", "Maio", "Maio",, "C", "@E 999,999,999")
	oStr2:AddField("MES_06"	, "11", "Junho", "Junho",, "C", "@E 999,999,999")
	oStr2:AddField("MES_07"	, "12", "Julho", "Julho",, "C", "@E 999,999,999")
	oStr2:AddField("MES_08"	, "13", "Agosto", "Agosto",, "C", "@E 999,999,999")
	oStr2:AddField("MES_09"	, "14", "Setembro", "Setembro",, "C", "@E 999,999,999")
	oStr2:AddField("MES_10"	, "15", "Outubro", "Outubro",, "C", "@E 999,999,999")
	oStr2:AddField("MES_11"	, "16", "Novembro", "Novembro",, "C", "@E 999,999,999")
	oStr2:AddField("MES_12"	, "17", "Dezembro", "Dezembro",, "C", "@E 999,999,999")

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

	//Cria Botões de usuarios dentro do formulario
	oView:AddUserButton( 'Filtrar Loja/Promotor' , 'FORM', {|oView| fFiltraGrid(oView)} ,'Filtrar por loja ou promotor',7,{MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} ) //"Filtrar"
	oView:AddUserButton( 'Remover Filtro'		 , 'FORM', {|oView| Processa( {|| fProcFil(oView,,,.T.) },"Aguarde...","Removendo Filtro...")  } ,'Remover Filtro',8,{MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} ) //"Filtrar"

Return oView

Static Function ModelDef()
	Local oModel
	Local oStr1	:= FWFormStruct( 1, 'Z81', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados

	//Criar objeto da estrutura do grip
	Local oStr2 := FWFORMMODELSTRUCT():New()
	Local aRel 	:= {}

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New(cTitle, { |oModel| MVCPREVALID(oModel) } , {|oModel| MVCTUDOOK(oModel) } , {|oModel| MVCCOMMIT(oModel) } , /*bCancel*/ )
	oModel:SetDescription(cTitle)

	oStr1:RemoveField( 'Z81_FILIAL' )                       

	//setar campos nao alteraveis
	oStr1:SetProperty("Z81_DATCAD"  , MODEL_FIELD_INIT,{|| dDataBase })
	oStr1:SetProperty("Z81_HORCAD"  , MODEL_FIELD_INIT,{|| SubStr(Time(),1,5) })

	//Validacoes do Cabecalho
	oStr1:SetProperty("Z81_ANO"  	, MODEL_FIELD_VALID, {|a,b,c,d,e| ValidAno(a,b,c,d,e) } )
	oStr1:SetProperty("Z81_ANO"  	, MODEL_FIELD_WHEN, {|a,b,c,d,e| WhenAno(a,b,c,d,e) } )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('MASTER',,oStr1,{|oModel|MVC001T(oModel)},,)

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'Z81_FILIAL', 'Z81_ANO', 'Z81_REVISA'})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('MASTER'):SetDescription('Cabecalho')

	//ESTRUTURA DE DADOS DO GRID
	//FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
	oStr2:AddField("Ano"		, "Ano"					, "ANO"		, "C", 4, 0)
	oStr2:AddField("Revisão"	, "Revisa"				, "REVISA"	, "C", 2, 0)
	oStr2:AddField("Cliente"	, "Código do Cliente"	, "CODCLI"	, "C", 6, 0)
	oStr2:AddField("Lj.Cli."	, "Loja do Cliente"		, "LOJCLI"	, "C", 2, 0)
	oStr2:AddField("UF"			, "UF"					, "UF"		, "C", 2, 0)
	oStr2:AddField("Nome Loja"	, "Nome de Loja"		, "NOMLOJ"	, "C", 50, 0)
	oStr2:AddField("Promotor"	, "Promotor"			, "NOMFUN"	, "C", 30, 0)
	oStr2:AddField("Janeiro"	, "Janeiro"				, "MES_01"	, "N", 14, 0)
	oStr2:AddField("Fevereiro"	, "Fevereiro"			, "MES_02"	, "N", 14, 0)
	oStr2:AddField("Março"		, "Março"				, "MES_03"	, "N", 14, 0)
	oStr2:AddField("Abril"		, "Abril"				, "MES_04"	, "N", 14, 0)
	oStr2:AddField("Maio"		, "Maio"				, "MES_05"	, "N", 14, 0)
	oStr2:AddField("Junho"		, "Junho"				, "MES_06"	, "N", 14, 0)
	oStr2:AddField("Julho"		, "Julho"				, "MES_07"	, "N", 14, 0)
	oStr2:AddField("Agosto"		, "Agosto"				, "MES_08"	, "N", 14, 0)
	oStr2:AddField("Setembro"	, "Setembro"			, "MES_09"	, "N", 14, 0)
	oStr2:AddField("Outubro"	, "Outubro"				, "MES_10"	, "N", 14, 0)
	oStr2:AddField("Novembro"	, "Novembro"			, "MES_11"	, "N", 14, 0)
	oStr2:AddField("Dezembro"	, "Dezembro"			, "MES_12"	, "N", 14, 0)

	oStr2:SetProperty("CODCLI"  , MODEL_FIELD_WHEN, {|a,b,c,d| GdGetWhen(a,b,c,d) } )
	oStr2:SetProperty("LOJCLI"  , MODEL_FIELD_WHEN, {|a,b,c,d| GdGetWhen(a,b,c,d) } )

	oStr2:SetProperty("CODCLI"  , MODEL_FIELD_VALID, {|a,b,c,d,e,f| GdValidCli(a,b,c,d,e,f) } )

	oStr2:AddTrigger("CODCLI", "LOJCLI"	, {|| .T.}, {|| "01" })
	oStr2:AddTrigger("CODCLI", "UF"		, {|| .T.}, {|a,b,c,d| GdTGetUf(a,b,c,d) })
	oStr2:AddTrigger("CODCLI", "NOMLOJ"	, {|| .T.}, {|a,b,c,d| GdTGetLoj(a,b,c,d) })
	oStr2:AddTrigger("CODCLI", "NOMFUN"	, {|| .T.}, {|a,b,c,d| GdTGetPro(a,b,c,d) })


	oModel:AddGrid('DETAIL','MASTER',oStr2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,{|x,y| iif(lFiltro,{},(aFiltro := {},aGridOri := {}, LoadZ82(x,y) )) })  //cOwner é para quem pertence
	oModel:getModel('DETAIL'):SetDescription('Detalhes')

	aAdd(aRel, {'ANO', 'ANO'})
	aAdd(aRel, {'REVISA', 'REVISA'}) 
	oModel:SetRelation('DETAIL', aRel, "ANO+REVISA+CODCLI")

Return oModel

//-------------------------------------------------------------------
// MODEL_FIELD_WHEN - Modo de edicao de campos
//-------------------------------------------------------------------
Static Function GdGetWhen(oModel,cCampo,cConteudo,nLinha)
	Local lRet 	:= .T.
	Local nOper	:= oModel:GetOperation()

	If (nOper == 4) .AND. !lFiltro
		If (AllTrim(cCampo) $ "CODCLI#LOJCLI")
			if ( nLinha <= nNumLinAtu )
				lRet := .F.
			endif
		EndIf
	EndIf

Return(lRet)

//-------------------------------------------------------------------
// Validar digitacao de cliente
//-------------------------------------------------------------------
Static Function GdValidCli(oModel,cCampo,uContAtu,nLinha,uContAnt)

	Local lRet := .T.
	Local oGrid 	:= oModel:GetModel():GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local I, J
	Local cCliDig	:= oGrid:GetValue("CODCLI", nLinha)

	For I := 1 To Len(oGrid:ACOLS)

		If ( nLinha <> I )	

			If ( oGrid:GetValue("CODCLI", I) == cCliDig )

				MsgAlert("Cliente já informado, não é possível duas linhas de metas para o mesmo cliente.","Metas de Promotores")
				lRet := .F.

			EndIf

		EndIf

	Next I	

Return(lRet)

//-------------------------------------------------------------------
// Gatilho ao digitar cliente
//-------------------------------------------------------------------
Static Function GdTGetUf(oModel,cCampo,uContAtu,nLinha)

	Local cRet		:= ""
	Local oGrid 	:= oModel:GetModel():GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local I, J
	Local cCliDig	:= oGrid:GetValue("CODCLI", nLinha)
	Local cLojDig	:= oGrid:GetValue("LOJCLI", nLinha)

	If ( nLinha > 0 )	

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(XFilial("SA1")+cCliDig+cLojDig))

		cRet :=  SA1->A1_EST		

	EndIf

Return(cRet)

//-------------------------------------------------------------------
// Gatilho ao digitar cliente
//-------------------------------------------------------------------
Static Function GdTGetPro(oModel,cCampo,uContAtu,nLinha)

	Local cRet		:= ""
	Local oGrid 	:= oModel:GetModel():GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local I, J
	Local cCliDig	:= oGrid:GetValue("CODCLI", nLinha)
	Local cLojDig	:= oGrid:GetValue("LOJCLI", nLinha)

	If ( nLinha > 0 )	

		cRet := GetPromotor(cCliDig, cLojDig)

	EndIf

Return(cRet)


//-------------------------------------------------------------------
// Gatilho ao digitar cliente
//-------------------------------------------------------------------
Static Function GdTGetLoj(oModel,cCampo,uContAtu,nLinha)

	Local aAreaA1	:= SA1->(GetArea())
	Local cRet		:= ""
	Local oGrid 	:= oModel:GetModel():GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local I, J
	Local cCliDig	:= oGrid:GetValue("CODCLI", nLinha)
	Local cLojDig	:= oGrid:GetValue("LOJCLI", nLinha)

	If ( nLinha > 0 )	

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(XFilial("SA1")+cCliDig+cLojDig))
			cRet := SA1->A1_YNLOJA
		EndIf

	EndIf

	RestArea(aAreaA1)

Return(cRet)

/*/{Protheus.doc} GetPromotor
@description Buscar o promotor atualmente associado ao cliente/empresa
@author Fernando Rocha
@since 16/01/2017
@version undefined
@param _cCodCli, , descricao
@param _cLojCli, , descricao
@type function
/*/
Static Function GetPromotor(_cCodCli, _cLojCli)

	Local cAliasTmp
	Local cRet := ""
	Local cArea := GetArea()

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp 
		%NoParser%

		select top 1 Z85_NOMFUN from %Table:Z85% (NOLOCK)
		where Z85_FILIAL = %XFilial:Z85%
		and Z85_CODCLI = %Exp:_cCodCli%
		and Z85_LOJCLI = %Exp:_cLojCli%
		and Z85_DTINIC <= %Exp:DTOS(dDataBase)%
		and Z85_DTFIM >= %Exp:DTOS(dDataBase)%
		and D_E_L_E_T_=''
		order by Z85_DTINIC desc

	EndSql

	If !(cAliasTmp)->(Eof())
		cRet := (cAliasTmp)->Z85_NOMFUN
	EndIf

	(cAliasTmp)->(DbCloseArea())
	RestArea(cArea)

Return(cRet)

//-------------------------------------------------------------------
// Validar digitacao do Ano
//-------------------------------------------------------------------
Static Function ValidAno(oModel,cCampo,uContAtu,uContAnt)

	Local lRet := .T.
	Local cAliasTmp

	If !lCopia

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NoParser%

			select 1 from %Table:Z81% (NOLOCK) where Z81_FILIAL = %XFILIAL:Z81% and Z81_ANO = %Exp:uContAtu% and %NotDel%

		EndSql

		If !(cAliasTmp)->(Eof())
			MsgAlert("Metas deste ano já cadastradas, favor revisar o cadastro existente.","Metas de Promotores")
			lRet := .F.
		EndIf
		(cAliasTmp)->(DbCloseArea())

	EndIf

Return(lRet)

//-------------------------------------------------------------------
// Bloquear digitacao do ANO na Revisao/Copia
//-------------------------------------------------------------------
Static Function WhenAno(oModel,cCampo,uContAtu,uContAnt)

	Local lRet 		:= .T.
	Local nOper		:= oModel:GetOperation()

	If (nOper == 4)
		lRet := .F.
	EndIf

Return(lRet)


//-------------------------------------------------------------------
// Carregar os dados customizados para a tela - tabela Z82
//-------------------------------------------------------------------
Static Function LoadZ82(oModel, lCopia)
	local aGridIni := {}
	U_BIAMsgRun("Aguarde... Carregando registros...",, {|| aGridIni := fProcLoadZ82(oModel,lCopia) })
return aGridIni

Static Function fProcLoadZ82(oModel, lCopia)

	Local aArea		:= GetArea()
	Local cAno 		:= oModel:getmodel():getmodel("MASTER"):getvalue("Z81_ANO")
	Local cRevisa 	:= oModel:getmodel():getmodel("MASTER"):getvalue("Z81_REVISA")
	Local aDados 	:= {}
	Local aLinha	:= {}
	Local I			:= 0
	Local cAliasTmp := ''

	//alteracao
	if (!lCopia)
		cAno := oModel:getmodel():getmodel("MASTER"):getvalue("Z81_ANO")
		cRevisa := oModel:getmodel():getmodel("MASTER"):getvalue("Z81_REVISA")
	else
		//copia
		cAno := Z81->Z81_ANO
		cRevisa := Z81->Z81_REVISA	

		oModel:GetModel("MASTER"):SetValue('MASTER', 'Z81_ANO', cAno )
		oModel:GetModel("MASTER"):SetValue('MASTER', 'Z81_REVISA', SOMA1(cRevisa,2) )
		oModel:GetModel("MASTER"):SetValue('MASTER', 'Z81_STATUS', "2")
		oModel:GetModel("MASTER"):SetValue('MASTER', 'Z81_APROV', "")
		oModel:GetModel("MASTER"):SetValue('MASTER', 'Z81_DATAPR', CTOD(" "))
		oModel:GetModel("MASTER"):SetValue('MASTER', 'Z81_HORAPR', "")
	Endif

	nNumLinAtu := 0
	cAliasTmp := GetTabGrid(cAno,cRevisa)
	While !(cAliasTmp)->(Eof()) 

		aLinha := {}
		aAdd(aLinha,(cAliasTmp)->Z82_ANO)
		aAdd(aLinha,(cAliasTmp)->Z82_REVISA)
		aAdd(aLinha,(cAliasTmp)->Z82_CODCLI)
		aAdd(aLinha,(cAliasTmp)->Z82_LOJCLI)
		aAdd(aLinha,(cAliasTmp)->A1_EST)
		aAdd(aLinha,(cAliasTmp)->A1_YNLOJA )  
		aAdd(aLinha,(cAliasTmp)->PROMOTOR )
		For I := 1 To 12
			aAdd(aLinha, (cAliasTmp)->&('MES_'+StrZero(I,2)) )
		Next I

		nNumLinAtu++
		aAdd(aDados, {0,aLinha})

		(cAliasTmp)->(DbSkip()) 
	End
	RestArea(aArea)
Return(aDados)


//-------------------------------------------------------------------
//Esta função será executada no inicio do carregamento da tela
//-------------------------------------------------------------------
Static Function MVC001T( oModel )
	Local lRet      := .T.
Return(lRet)

//-------------------------------------------------------------------
// Validações ao alterar qualquer conteudo em qualquer modelo
//-------------------------------------------------------------------
Static Function MVCPREVALID( oModel )
Return .T.      

//-------------------------------------------------------------------
// Validações ao salvar registro
//-------------------------------------------------------------------
Static Function MVCTUDOOK( oModel )
Return .T.

//-------------------------------------------------------------------
// Gravacao de Dados
//-------------------------------------------------------------------
Static Function MVCCOMMIT(oModel)
	Processa( {|| fProcCommit(oModel) },"Aguarde...","Atualizando Registros...")
return .t.

Static Function fProcCommit(oModel)

	Local aArea 	:= GetArea()
	Local oMaster	:= oModel:GetModel('MASTER')
	Local oGrid 	:= oModel:GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local cAno		:= oMaster:GetValue("Z81_ANO")
	Local cRevisa	:= oMaster:GetValue("Z81_REVISA")
	Local nLin		:= 0
	Local nLin2		:= 0
	Local nLinhas	:= 0
	Local aCposCab	:= {}
	Local aCposGrid	:= {}
	Local aValGrid	:= {}
	Local oEstrCab	:= nil
	Local oEstrGrid := nil	
	local nPos		:= 0
	Local cAnoAnt
	Local cRevAnt
	Local I, J

	ProcRegua(0)

	If ( nOper == 3 )
		If !lCopia
			oMaster:SetValue("Z81_STATUS","1")
		Else		
			oMaster:SetValue("Z81_STATUS","2")

			cAnoAnt := Z81->Z81_ANO
			cRevAnt := Z81->Z81_REVISA

		EndIf
	EndIf

	BEGIN TRANSACTION

		//COPIA - alterar campos na revisao anterior
		If ( nOper == 3 .And. lCopia )

			Z81->(DbSetOrder(1))
			If Z81->(DbSeek(XFilial("Z81")+cAnoAnt+cRevAnt))

				RecLock("Z81",.F.)
				Z81->Z81_STATUS := "4"
				Z81->(MsUnlock())

			EndIf

		EndIf

		//Cabeçalho
		if nOper == 3  
			oEstrCab := oMaster:GetStruct()
			aCposCab := oEstrCab:GetFields()

			Z81->(DbSetOrder(1))
			If Z81->(DbSeek(XFilial("Z81")+cAno+cRevisa))
				Z81->(RecLock("Z81",.F.))
			else
				Z81->(RecLock("Z81",.T.))
			EndIf
			For nLin := 1 To Len(aCposCab)
				&('Z81->'+aCposCab[nLin,3]) := oMaster:GetValue(aCposCab[nLin,3])
			Next nLin
			Z81->(MsUnlock())
		endif

		nLinhas 	:= oGrid:Length()
		oEstrGrid 	:= oGrid:GetStruct()
		aCposGrid 	:= oEstrGrid:GetFields()
		For nLin := 1 To nLinhas
			oGrid:GoLine(nLin)
			aValGrid := {}

			For nLin2 := 1 To Len(aCposGrid)
				Aadd(aValGrid,oGrid:GetValue(aCposGrid[nLin2,3]))
			Next nLin2
			AADD(aValGrid,oGrid:IsDeleted())

			if ( nPos := ASCAN(aGridOri,{|x| x[3]+x[4] == aValGrid[3]+aValGrid[4] }) ) == 0 
				AADD(aGridOri,aValGrid)
			else
				aGridOri[nPos] := aValGrid
			endif
		Next nLin

		ProcRegua(Len(aGridOri))

		For I := 1 To Len(aGridOri)

			If ( nOper == 3 )

				For J := 1 To 12

					Z82->(RecLock("Z82",.T.))

					Z82->Z82_FILIAL		:= XFILIAL("Z81")
					Z82->Z82_ANO		:= cAno
					Z82->Z82_REVISA		:= cRevisa
					Z82->Z82_MES		:= StrZero(J,2) 		
					Z82->Z82_CODCLI		:= aGridOri[I,3]
					Z82->Z82_LOJCLI		:= aGridOri[I,4]
					Z82->Z82_META		:= aGridOri[I,J+7]

					Z82->(MsUnlock())

				Next J		

			ElseIf ( nOper == 4 )

				Z82->(DbSetOrder(2))
				If Z82->(DbSeek(XFilial("Z82")+cAno+cRevisa+aGridOri[I,3]+aGridOri[I,4]))

					For J := 1 To 12

						If Z82->(DbSeek(XFilial("Z82")+cAno+cRevisa+aGridOri[I,3]+aGridOri[I,4]+StrZero(J,2)))

							if !aGridOri[I,len(aGridOri[I])]
								Z82->(RecLock("Z82",.F.))
								Z82->Z82_META	:= aGridOri[I,J+7]
								Z82->(MsUnlock())
							else
								Z82->(RecLock("Z82",.F.))
								Z82->(DbDelete())
								Z82->(MsUnlock())						
							endif	

						Else

							Z82->(RecLock("Z82",.T.))

							Z82->Z82_FILIAL		:= XFILIAL("Z81")
							Z82->Z82_ANO		:= cAno
							Z82->Z82_REVISA		:= cRevisa
							Z82->Z82_MES		:= StrZero(J,2) 		
							Z82->Z82_CODCLI		:= aGridOri[I,3]
							Z82->Z82_LOJCLI		:= aGridOri[I,4]
							Z82->Z82_META		:= aGridOri[I,J+7]

							Z82->(MsUnlock())

						EndIf

					Next J	

				Else

					For J := 1 To 12

						Z82->(RecLock("Z82",.T.))

						Z82->Z82_FILIAL		:= XFILIAL("Z81")
						Z82->Z82_ANO		:= cAno
						Z82->Z82_REVISA		:= cRevisa
						Z82->Z82_MES		:= StrZero(J,2) 		
						Z82->Z82_CODCLI		:= aGridOri[I,3]
						Z82->Z82_LOJCLI		:= aGridOri[I,4]
						Z82->Z82_META		:= aGridOri[I,J+7]

						Z82->(MsUnlock())

					Next J	


				EndIf

			EndIf

			IncProc("Processando Cliente: " + aGridOri[I,3] + '/' + aGridOri[I,4])	

		Next I

	END TRANSACTION

	RestArea(aArea)
Return(.T.)


//Filtra grid
Static Function fFiltraGrid(oView)

	Local aPergs 	:= {}
	local cLoad	    := 'FPVET1FL' + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local cNomeLoja	:= space(100) 
	local cPromotor	:= space(100) 
	Local lContinua	:= .T.

	aAdd( aPergs ,{1,"Loja"		,cNomeLoja  ,"@!",'.T.',"",'.T.',75,.F.})
	aAdd( aPergs ,{1,"Promotor"	,cPromotor  ,"@!",'.T.',"",'.T.',75,.F.})

	If ParamBox(aPergs ,"Filtrar",,,,,,,,cLoad,.T.,.T.)      
		cNomeLoja  := ParamLoad(cFileName,,1,cNomeLoja) 
		cPromotor  := ParamLoad(cFileName,,2,cPromotor) 

		if lContinua .and. Empty(cNomeLoja) .and. Empty(cPromotor)	
			lContinua := .F.
			MsgAlert("Informe pelo menos um campo para realizar o filtro!")
		endif	

		if lContinua .and. (!Empty(cNomeLoja) .or. !Empty(cPromotor))	

			if Len(Alltrim(cNomeLoja)) < 3 .and. Len(Alltrim(cPromotor)) < 3
				lContinua := .F.
			endif
			if ! lContinua 
				MsgAlert("Informe pelo menos 3 caracteres em um dos campos!")
			endif	
		endif

		if lContinua	
			Processa( {|| fProcFil(oView,cNomeLoja,cPromotor) },"Aguarde...","Filtrando registros...")
		endif
	endif	
return

static function fProcFil(oView,cNomeLoja,cPromotor,lRemoveFil)

	Local nLin			:= 0
	Local nLin2			:= 0
	Local nLinhas		:= 0
	Local aCposCab		:= {}
	Local aCposGrid		:= {}
	Local aValCab		:= {}
	Local aValGrid		:= {}
	Local oEstrCab		:= nil
	Local oEstrGrid 	:= nil
	Local oCab			:= nil
	Local oGrid			:= nil
	Local oModel		:= nil	
	local lContinua		:= .T.
	local nPos			:= 0
	default oView	  	:= nil
	default cNomeLoja  	:= ''
	default cPromotor  	:= ''
	default lRemoveFil 	:= .F.

	ProcRegua(0)

	lFiltro := .T.

	oCab  := oView:GetModel("MASTER")
	oGrid := oView:GetModel("DETAIL")

	nLinhas := oGrid:Length()
	If (nLinhas > 0 .AND. !lRemoveFil) .OR.(Len(aGridOri) > 0 .AND. lRemoveFil)  

		aFiltro := {}
		oEstrGrid := oGrid:GetStruct()
		aCposGrid := oEstrGrid:GetFields()
		For nLin := 1 To nLinhas
			oGrid:GoLine(nLin)
			aValGrid := {}

			For nLin2 := 1 To Len(aCposGrid)
				Aadd(aValGrid,oGrid:GetValue(aCposGrid[nLin2,3]))
			Next nLin2
			Aadd(aValGrid,oGrid:IsDeleted())

			if ( nPos := ASCAN(aGridOri,{|x| x[3]+x[4] == aValGrid[3]+aValGrid[4] }) ) == 0 
				AADD(aGridOri,aValGrid)
			else
				aGridOri[nPos] := aValGrid
			endif

		Next nLin

		For nLin := 1 To len(aGridOri)	

			__LLOJAOK := Empty(cNomeLoja) .Or. UPPER(Alltrim(cNomeLoja)) $ UPPER(Alltrim(aGridOri[nLin,6]))
			__LPROMOOK := Empty(cPromotor) .Or. UPPER(Alltrim(cPromotor)) $ UPPER(Alltrim(aGridOri[nLin,7]))

			If (__LLOJAOK .And. __LPROMOOK)

				if (nPos := ASCAN(aFiltro,{|x| x[3]+x[4] == aGridOri[nLin,3]+aGridOri[nLin,4] }) ) == 0 
					AADD(aFiltro,aGridOri[nLin])
				else
					aFiltro[nPos] := aGridOri[nLin]
				endif

			endif			
		Next nLin

		oGrid:GoLine(1)

		If (Len(aFiltro) == 0 .AND. !lRemoveFil) .OR.(Len(aGridOri) == 0 .AND. lRemoveFil)  
			lContinua := .F.
			if Len(aFiltro) == 0 .AND. !lRemoveFil
				MsgInfo('Filtro não localizado!') 
			endif
			if Len(aGridOri) == 0 .AND. lRemoveFil
				MsgInfo('Não foram localizados filtros para remoção!') 			
			endif
		endif

		aSort( aGridOri,,,{ |x,y| (x[3]) < (y[3]) } ) 
		aSort( aFiltro ,,,{ |x,y| (x[3]) < (y[3]) } ) 

		if lContinua
			/*
			For nLin := 1 To nLinhas
			oGrid:GoLine(nLin)
			oGrid:DeleteLine()
			Next nLin
			*/
			oEstrCab := oCab:GetStruct()
			aCposCab := oEstrCab:GetFields()
			aValCab := {}
			For nLin := 1 To Len(aCposCab)
				Aadd(aValCab,oCab:GetValue(aCposCab[nLin,3]))
			Next nLin

			oView:DeActivate()
			oView:Activate()

			For nLin := 1 To Len(aCposCab)
				oCab:LoadValue(aCposCab[nLin,3],aValCab[nLin])
			Next nLin

			if len(aFiltro) > 0 .and. !lRemoveFil

				nNumLinAtu := len(aFiltro)

				For nLin := 1 To len(aFiltro)

					nLinha := oGrid:AddLine()

					oGrid:GoLine( nLinha )

					For nLin2 := 1 To Len(aCposGrid)
						oGrid:SetValue( aCposGrid[nLin2,3] , aFiltro[nLin,nLin2] )
					Next nLin2
					if aFiltro[nLin,len(aFiltro[nLin])]
						oGrid:DeleteLine()
					endif	
				next nLin	
				oGrid:GoLine( 1 )
			elseif Len(aGridOri) > 0 .AND. lRemoveFil
				nNumLinAtu := len(aGridOri)

				For nLin := 1 To len(aGridOri)

					nLinha := oGrid:AddLine()

					oGrid:GoLine( nLinha )

					For nLin2 := 1 To Len(aCposGrid)
						oGrid:SetValue( aCposGrid[nLin2,3] , aGridOri[nLin,nLin2] )
					Next nLin2
					if aGridOri[nLin,len(aGridOri[nLin])]
						oGrid:DeleteLine()
					endif				
				next nLin	
				oGrid:GoLine( 1 )		
			endif	
		endif	
	endif
	//oGrid:SetNoInsertLine(.T.)
	//oGrid:SetNoDeleteLine(.T.)
	lFiltro := .F.

return 


Static Function GetTabGrid(_cAno, _cRevisa)

	Local cAliasTmp := GetNextAlias()

	BeginSql Alias cAliasTmp 
		%NoParser%

		SELECT X.*, 
		ISNULL(
		(SELECT TOP 1 Z85_NOMFUN 
		FROM %TABLE:Z85% (NOLOCK) Z85 
		WHERE Z85_FILIAL = %XFILIAL:Z85%
		AND Z85_CODCLI = X.Z82_CODCLI 
		AND Z85_LOJCLI = X.Z82_LOJCLI
		AND Z85_DTINIC <= %Exp:DTOS(dDataBase)%
		and Z85_DTFIM >= %Exp:DTOS(dDataBase)%
		and Z85.D_E_L_E_T_=''),'') PROMOTOR,
		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '01'
		AND Z82.D_E_L_E_T_='') MES_01,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '02'
		AND Z82.D_E_L_E_T_='') MES_02,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '03'
		AND Z82.D_E_L_E_T_='') MES_03,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '04'
		AND Z82.D_E_L_E_T_='') MES_04,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '05'
		AND Z82.D_E_L_E_T_='') MES_05,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '06'
		AND Z82.D_E_L_E_T_='') MES_06,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '07'
		AND Z82.D_E_L_E_T_='') MES_07,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '08'
		AND Z82.D_E_L_E_T_='') MES_08,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '09'
		AND Z82.D_E_L_E_T_='') MES_09,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '10'
		AND Z82.D_E_L_E_T_='') MES_10,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '11'
		AND Z82.D_E_L_E_T_='') MES_11,

		(SELECT TOP 1 Z82.Z82_META FROM %TABLE:Z82% (NOLOCK) Z82 
		WHERE Z82.Z82_ANO = X.Z82_ANO
		AND Z82.Z82_REVISA = X.Z82_REVISA 
		AND Z82.Z82_CODCLI = X.Z82_CODCLI 
		AND Z82.Z82_LOJCLI = X.Z82_LOJCLI
		AND Z82.Z82_MES = '12'
		AND Z82.D_E_L_E_T_='') MES_12

		FROM  ( 
		SELECT DISTINCT Z82_ANO, Z82_REVISA, Z82_CODCLI, Z82_LOJCLI, A.A1_EST, A.A1_YNLOJA 
		FROM %TABLE:Z82% (NOLOCK) Z
		LEFT JOIN %TABLE:SA1% (NOLOCK) A
		ON A.A1_FILIAL = %XFILIAL:SA1%
		AND A.A1_COD = Z.Z82_CODCLI 
		AND A.A1_LOJA = Z.Z82_LOJCLI
		AND A.D_E_L_E_T_ = ''
		WHERE Z.Z82_FILIAL = %XFILIAL:Z82%
		AND Z.Z82_ANO = %Exp:_cAno%
		AND Z.Z82_REVISA = %Exp:_cRevisa%
		AND Z.D_E_L_E_T_ = '' 
		) X 
		ORDER BY Z82_CODCLI, Z82_LOJCLI 

	EndSql

	(cAliasTmp)->(DbGoTop())

Return(cAliasTmp)


/*/{Protheus.doc} FPT01EXC
@description Funcao para importar planilha Excel para cadastro de Metas de Clientes
@author Fernando Rocha
@since 05/04/2018
@version undefined
@type function
/*/
User Function FPT01EXC

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Melhoria Promotores de Vendas de Clientes, por arquivo excel!"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Metas de Clientes'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'FPT01EXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'Z81'
	Local cTabImp2			:= 'Z82'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	local nRepeat			:= 0
	Local nErros			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local aAnoRev			:= {}
	Local ny, nx

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		BEGIN TRANSACTION   

			For nx := 1 to len(aWorksheet) 

				IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

				If nx == 1

					aCampos := aWorksheet[nx]
					For ny := 1 to len(aCampos)
						If (AT(cTabImp+'_',UPPER(aCampos[ny])) > 0)
							cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
							aCampos[ny] := cTemp
						ElseIf (AT(cTabImp2+'_',UPPER(aCampos[ny])) > 0)
							cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp2+'_',UPPER(aCampos[ny])),10)
							aCampos[ny] := cTemp
						EndIf
					Next ny

				Else

					aLinha    := aWorksheet[nx]
					aItem     := {}
					cConteudo := ''

					SX3->(DbSetOrder(2))

					For ny := 1 to Len(aLinha)

						If Len(aCampos) >= ny 

							cConteudo := aLinha[ny]

							If SX3->(DbSeek(Padr(aCampos[ny],10),.T.))

								Do Case

									case SX3->X3_TIPO == "D"
									cConteudo := SubStr(cConteudo,1,10)
									cConteudo := stod(StrTran(cConteudo, "-", ""))

									case SX3->X3_TIPO == "N"
									cConteudo := Val(cConteudo)

									case SX3->X3_TIPO == "C"
									cConteudo := Padr(cConteudo,TamSX3(aCampos[ny])[1])

								EndCase

								AADD(aItem,{ aCampos[ny] , cConteudo , nil })

							EndIf

						EndIf

					Next ny	

					If len(aItem) > 0

						__cAno := aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z81_ANO"})][2]
						__cRev := aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z81_REVISA"})][2]

						If !aScan(aAnoRev, {|x| x[1] == __cAno .And. x[2] == __cRev})
							AAdd(aAnoRev,{__cAno,__cRev})
						EndIf

						Z81->(DbSetOrder(1))
						If !Z81->(DbSeek(XFilial("Z81")+__cAno+__cRev))

							MsgAlert("Atenção, Meta para Ano: "+__cAno+" Revisao: "+__cRev+" Nao cadastrada, deve primeiro cadastro o ano/revisão antes de importar o Excel.")

						EndIf

						__cMes := aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z82_MES"})][2]
						__cCli := aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z82_CODCLI"})][2]+aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z82_LOJCLI"})][2]

						Z82->(DbSetOrder(1))
						//Z82_FILIAL, Z82_ANO, Z82_REVISA, Z82_MES, Z82_CODCLI, Z82_LOJCLI, R_E_C_N_O_, D_E_L_E_T_

						If Z82->(DbSeek(XFilial("Z82")+__cAno+__cRev+__cMes+__cCli))

							nRepeat++

							RecLock("Z82",.F.)
							Z82_META	:= aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z82_META"})][2]
							Z82->(MsUnlock())

						Else
							nImport++

							RecLock("Z82",.T.)
							Z82_FILIAL	:= XFilial("Z82")
							Z82_ANO		:= __cAno
							Z82_REVISA	:= __cRev
							Z82_MES		:= __cMes
							Z82_CODCLI	:= SubStr(__cCli,1,6)
							Z82_LOJCLI	:= SubStr(__cCli,7,2)
							Z82_META	:= aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z82_META"})][2]
							Z82->(MsUnlock())

						EndIf

					Else
						nErros++				
					EndIf

				EndIf

			Next nx

			//Gerando linhas zeradas no Z82

			__cFNCName := "% FNC_PVE_LISTA_METAS_ZERAR_"+Alltrim(CEMPANT)+" %"

			For  nx := 1 to Len(aAnoRev)

				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp
					%NoParser%
					select * from %Exp:__cFNCName%('  ',%Exp:aAnoRev[nx][1]%,%Exp:aAnoRev[nx][2]%)
				EndSql

				(cAliasTmp)->(DbGoTop())
				While !(cAliasTmp)->(Eof())

					RecLock("Z82",.T.)
					Z82_FILIAL	:= XFilial("Z82")
					Z82_ANO		:= aAnoRev[nx][1]
					Z82_REVISA	:= aAnoRev[nx][2]
					Z82_MES		:= (cAliasTmp)->Z82_MES
					Z82_CODCLI	:= (cAliasTmp)->Z82_CODCLI
					Z82_LOJCLI	:= (cAliasTmp)->Z82_LOJCLI
					Z82_META	:= 0
					Z82->(MsUnlock())

					(cAliasTmp)->(DbSkip())
				EndDo

			Next nx

		END TRANSACTION

	EndIf

	MsgInfo(Alltrim(Str(nImport))+" Registros NOVOS, importados com sucesso."+CRLF+;
	Alltrim(Str(nRepeat))+" Registros já existentes, ATUALIZADOS na base de dados."+;
	IIF(nErros>0,CRLF+Alltrim(Str(nErros))+" Registros com ERROS.",""))

	RestArea(aArea)

Return