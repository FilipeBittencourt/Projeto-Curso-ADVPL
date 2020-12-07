#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static lCopia 	:= .F.

/*/{Protheus.doc} FPVETE03
@description tela MVC para cadastro do SELLOUT dos clientes
@author Fernando Rocha
@since 01/12/2016
@version 1.0
@type function
/*/
User Function FPVETE03()
	/*Declarando as variáveis que serão utilizadas*/
	Local lRet 		:= .T.
	Local aArea 	:= Z84->(GetArea())
	Private oBrowse
	Private cTitle
	Private lFiltro  := .F.
	Private aFiltro  := {}
	Private aGridOri := {}
	Private aGridIni := {}

	cTitle := "SELLOUT de Clientes"

	//controles internos
	Private nNumLinAtu

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("Z84")         

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
	ADD OPTION aRotina TITLE "Visualizar" 		ACTION "VIEWDEF.FPVETE03" 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    		ACTION "VIEWDEF.FPVETE03" 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.FPVETE03"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    		ACTION "VIEWDEF.FPVETE03" 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar"			ACTION "U_FPV03Copia" 		OPERATION 7 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
// BOTAO COPIAT
//-------------------------------------------------------------------
User Function FPV03Copia()

	Local cTitulo		:= "COPIAR"
	Local nOperation 	:= 9 // Define o modo de operacao como copia

	lCopia := .T.

	FWExecView(cTitulo,'VIEWDEF.FPVETE03',nOperation,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)

	lCopia := .F.

Return Nil


Static Function ViewDef()
	Local oView
	Local oModel	:= ModelDef()
	Local oStr1		:= FWFormStruct(2, 'Z84')
	Local oStr2		:= FWFormViewStruct():New()

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oStr1:RemoveField("Z84_CODCLI")
	oStr1:RemoveField("Z84_LOJCLI")
	oStr1:RemoveField("Z84_QTDE")
	oStr1:RemoveField("Z84_VALOR")

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1, 'MASTER')

	//Estrutura do GRID (VIEW)
	//FWFORMVIEWSTRUCT():AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL
	oStr2:AddField("CODCLI"		, "01", "Cliente", "Código do Cliente",, "C", "@!",,"SA1")
	oStr2:AddField("LOJCLI"		, "02", "Lj.Cli.", "Loja do Cliente",, "C", "@!")
	oStr2:AddField("UF"			, "03", "UF", "UF",, "C", "@!",,,.F.)
	oStr2:AddField("NOMLOJ"		, "04", "Nome Loja", "Nome da Loja",, "C", "@!",,,.F.)
	oStr2:AddField("NOMFUN"		, "05", "Promotor(a)", "Promotor(a)",, "C", "@!",,,.F.)
	oStr2:AddField("META_QTDE"	, "06", "Real (m2)", "Real (m2)",, "C", "@E 999,999,999.99")
	oStr2:AddField("META_VALOR"	, "07", "Real (R$)", "Real (R$)",, "C", "@E 999,999,999.99")

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
	Local oStr1	:= FWFormStruct( 1, 'Z84', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados

	//Criar objeto da estrutura do grip
	Local oStr2 := FWFORMMODELSTRUCT():New()
	Local aRel 	:= {}

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New(cTitle, { | oModel | MVCPREVALID( oModel ) } , { | oMdl | MVCTUDOOK( oModel ) } , { | oMdl | MVCCOMMIT( oModel ) } , /*bCancel*/ )
	oModel:SetDescription(cTitle)

	oStr1:RemoveField( 'Z84_FILIAL' )                       

	//setar campos nao alteraveis
	//oStr1:SetProperty("Z84_DATCAD"  , MODEL_FIELD_INIT,{|| dDataBase })
	//oStr1:SetProperty("Z84_HORCAD"  , MODEL_FIELD_INIT,{|| SubStr(Time(),1,5) })

	//Validacoes do Cabecalho
	oStr1:SetProperty("Z84_ANO"  	, MODEL_FIELD_VALID, {|a,b,c,d,e| ValidAno(a,b,c,d,e) } )
	oStr1:SetProperty("Z84_MES"  	, MODEL_FIELD_VALID, {|a,b,c,d,e| ValidAno(a,b,c,d,e) } )

	oStr1:SetProperty("Z84_ANO"  	, MODEL_FIELD_WHEN, {|a,b,c,d,e| WhenAno(a,b,c,d,e) } )
	oStr1:SetProperty("Z84_MES"  	, MODEL_FIELD_WHEN, {|a,b,c,d,e| WhenAno(a,b,c,d,e) } )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('MASTER',,oStr1,{|oModel|MVC001T(oModel)},,)

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'Z84_FILIAL', 'Z84_ANO', 'Z84_MES', 'Z84_CODCLI', 'Z84_LOJCLI'})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('MASTER'):SetDescription('Cabecalho')

	//ESTRUTURA DE DADOS DO GRID
	//FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
	oStr2:AddField("Ano"		, "Ano"					, "ANO"		, "C", 4, 0)
	oStr2:AddField("Mês"		, "Mês"					, "MES"		, "C", 2, 0)

	oStr2:AddField("Cliente"	, "Código do Cliente"	, "CODCLI"	, "C", 6, 0)
	oStr2:AddField("Lj.Cli."	, "Loja do Cliente"		, "LOJCLI"	, "C", 2, 0)
	oStr2:AddField("UF"			, "UF"					, "UF"		, "C", 2, 0)
	oStr2:AddField("Nome Loja"	, "Nome da Loja"		, "NOMLOJ"	, "C", 40, 0)
	oStr2:AddField("Promotor(a)", "Promotor(a)"			, "NOMFUN"	, "C", 40, 0)
	oStr2:AddField("Real(m2)"	, "Real(m2)"			, "META_QTDE"	, "N", 14, 2)
	oStr2:AddField("Real(R$)"	, "Real(R$)"			, "META_VALOR"	, "N", 14, 2)

	oStr2:SetProperty("CODCLI"  , MODEL_FIELD_WHEN, {|a,b,c,d| GdGetWhen(a,b,c,d) } )
	oStr2:SetProperty("LOJCLI"  , MODEL_FIELD_WHEN, {|a,b,c,d| GdGetWhen(a,b,c,d) } )

	oStr2:SetProperty("CODCLI"  , MODEL_FIELD_VALID, {|a,b,c,d,e,f| GdValidCli(a,b,c,d,e,f) } )

	oStr2:AddTrigger("CODCLI", "LOJCLI"	, {|| .T.}, {|| "01" })
	oStr2:AddTrigger("CODCLI", "UF"		, {|| .T.}, {|a,b,c,d| GdTGetUf(a,b,c,d) })
	oStr2:AddTrigger("CODCLI", "NOMLOJ"	, {|| .T.}, {|a,b,c,d| GdTGetLoj(a,b,c,d) })
	oStr2:AddTrigger("LOJCLI", "NOMLOJ"	, {|| .T.}, {|a,b,c,d| GdTGetLoj(a,b,c,d) })
	oStr2:AddTrigger("CODCLI", "NOMFUN"	, {|| .T.}, {|a,b,c,d| GdTGetPro(a,b,c,d) })

	oModel:AddGrid('DETAIL','MASTER',oStr2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,{|x,y| iif(lFiltro,{},(aFiltro := {},aGridOri := {}, LoadZ84(x,y) )) })  //cOwner é para quem pertence
	oModel:getModel('DETAIL'):SetDescription('Detalhes')

	aAdd(aRel, {'ANO', 'ANO'})
	aAdd(aRel, {'MES', 'MES'})

	oModel:SetRelation('DETAIL', aRel, "ANO+MES+CODCLI")

Return oModel


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

	select top 1 Z85_NOMFUN from %Table:Z85%
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
// Gatilho ao digitar cliente
//-------------------------------------------------------------------
Static Function GdTGetLoj(oModel,cCampo,uContAtu,nLinha)

	Local aAreaA1	:= SA1->(GetArea())
	Local cRet		:= ""
	Local oDetail 	:= oModel:GetModel():GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local I, J
	Local cCliDig	:= oDetail:GetValue("CODCLI", nLinha)
	Local cLojDig	:= oDetail:GetValue("LOJCLI", nLinha)

	If ( nLinha > 0 )	

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(XFilial("SA1")+cCliDig+cLojDig))
			cRet :=  SA1->A1_YNLOJA
		EndIf

	EndIf

	RestArea(aAreaA1)

Return(cRet)

//-------------------------------------------------------------------
// Validar digitacao de cliente
//-------------------------------------------------------------------
Static Function GdValidCli(oModel,cCampo,uContAtu,nLinha,uContAnt)

	Local lRet := .T.
	Local oDetail 	:= oModel:GetModel():GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local I, J
	Local cCliDig	:= oDetail:GetValue("CODCLI", nLinha)

	For I := 1 To Len(oDetail:ACOLS)

		If ( nLinha <> I )	

			If ( oDetail:GetValue("CODCLI", I) == cCliDig )

				MsgAlert("Cliente já informado, não é possível duas linhas de Sell Out para o mesmo cliente.","Sell Out de Clientes")
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
	Local oDetail 	:= oModel:GetModel():GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local I, J
	Local cCliDig	:= oDetail:GetValue("CODCLI", nLinha)
	Local cLojDig	:= oDetail:GetValue("LOJCLI", nLinha)

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
	Local oDetail 	:= oModel:GetModel():GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local I, J
	Local cCliDig	:= oDetail:GetValue("CODCLI", nLinha)
	Local cLojDig	:= oDetail:GetValue("LOJCLI", nLinha)

	If ( nLinha > 0 )	

		cRet := GetPromotor(cCliDig, cLojDig)

	EndIf

Return(cRet)


//-------------------------------------------------------------------
// Validar digitacao do Ano
//-------------------------------------------------------------------
Static Function ValidAno(oModel,cCampo,uContAtu,uContAnt)

	Local lRet := .T.
	Local cAliasTmp
	Local cAno := oModel:getmodel():getmodel("MASTER"):getvalue("Z84_ANO")
	Local cMes := oModel:getmodel():getmodel("MASTER"):getvalue("Z84_MES")
	Local nOper		:= oModel:GetOperation()

	If lCopia .Or. nOper == 3

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
		%NoParser%

		select 1 from %Table:Z84% where Z84_FILIAL = '  ' and Z84_ANO = %Exp:cAno% and Z84_MES = %Exp:cMes% and %NotDel%

		EndSql

		If !(cAliasTmp)->(Eof())
			MsgAlert("Sell Out deste ano/mês já cadastrado, favor alterar o cadastro existente.","Sell Out de Clientes")
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
// Carregar os dados customizados para a tela - tabela Z84
//-------------------------------------------------------------------
Static Function LoadZ84(oModel, lCopia)
	local aGridIni := {}
	U_BIAMsgRun("Aguarde... Carregando registros...",, {|| aGridIni := fProcLoadZ84(oModel, lCopia) })
return aGridIni

Static Function fProcLoadZ84(oModel, lCopia)

	Local cAno := oModel:getmodel():getmodel("MASTER"):getvalue("Z84_ANO")
	Local cMes := oModel:getmodel():getmodel("MASTER"):getvalue("Z84_MES")
	Local aDados := {}
	Local aLinha
	Local I
	Local cAliasTmp

	If lCopia

		cAno := Z84->Z84_ANO
		cMes := Z84->Z84_MES

		oModel:getmodel():getmodel("MASTER"):setvalue("Z84_ANO",Space(4))
		oModel:getmodel():getmodel("MASTER"):setvalue("Z84_MES",Space(2))	

	EndIf

	nNumLinAtu := 0
	Z84->(DbSetOrder(1))
	If Z84->(DbSeek(XFilial("Z84")+cAno))

		While !Z84->(Eof()) .And. Z84->(Z84_FILIAL+Z84_ANO) == (XFilial("Z84")+cAno) 

			If (Z84->Z84_MES <> cMes)  //provisorio - criar indice pelo MES
				Z84->(DbSkip())
				loop
			EndIf

			aLinha := {}
			aAdd(aLinha,cAno)
			aAdd(aLinha,cMes)
			aAdd(aLinha,Z84->Z84_CODCLI)
			aAdd(aLinha,Z84->Z84_LOJCLI)

			SA1->(DbSetOrder(1))
			SA1->(DbSeek(XFilial("SA1")+Z84->Z84_CODCLI+Z84->Z84_LOJCLI))

			aAdd(aLinha, SA1->A1_EST)
			aAdd(aLinha, SA1->A1_YNLOJA)
			aAdd(aLinha, GetPromotor(Z84->Z84_CODCLI, Z84->Z84_LOJCLI) )

			If lCopia
				aAdd(aLinha, 0)
				aAdd(aLinha, 0)
			Else
				aAdd(aLinha, Z84->Z84_QTDE)
				aAdd(aLinha, Z84->Z84_VALOR)
			EndIF

			nNumLinAtu++
			aAdd(aDados, {0,aLinha})

			Z84->(DbSkip())
		EndDo

	EndIf

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

	Local lRet := .T.
	Local oDetail 	:= oModel:GetModel('DETAIL')
	Local I
	Local cAno := oModel:getmodel():getmodel("MASTER"):getvalue("Z84_ANO")
	Local cMes := oModel:getmodel():getmodel("MASTER"):getvalue("Z84_MES")

	If Empty(cAno) .Or. Empty(cMes)
		MsgAlert("Ano/Mês não informado","ATENÇÃO!")
		lRet := .F.
	EndIf

	If lRet

		For I := 1 To Len(oDetail:ACOLS)
			If !( oDetail:ACOLS[I][Len(oDetail:AHEADER)+1] )
				If Empty(oDetail:GetValue("CODCLI", I)) .Or. Empty(oDetail:GetValue("LOJCLI", I))
					MsgAlert("Linha com cliente não informado","ATENÇÃO!")
					lRet := .F.
					exit
				EndIf
			EndIf
		Next I

	EndIf

Return(lRet)

//-------------------------------------------------------------------
// Gravacao de Dados
//-------------------------------------------------------------------
Static Function MVCCOMMIT(oModel)
	Processa( {|| fProcCommit(oModel) },"Aguarde...","Atualizando Registros...")
return .t.

Static Function fProcCommit(oModel)

	Local aArea 	:= GetArea()
	Local oMaster	:= oModel:GetModel('MASTER')
	Local oDetail 	:= oModel:GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	Local cAno		:= oMaster:GetValue("Z84_ANO")
	Local cMes		:= oMaster:GetValue("Z84_MES")
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


	//DELETE
	If ( nOper == 5 )

		For I := 1 To Len(oDetail:ACOLS)

			Z84->(DbSetOrder(1))
			If Z84->(DbSeek(XFilial("Z84")+cAno+oDetail:GetValue("CODCLI", I)+oDetail:GetValue("LOJCLI", I)+cMes))

				RecLock("Z84",.F.)
				Z84->(DbDelete())
				Z84->(MsUnlock())

			EndIf

		Next I

		Return(.T.)	
	EndIf


	BEGIN TRANSACTION

	nLinhas 	:= oDetail:Length()
	oEstrGrid 	:= oDetail:GetStruct()
	aCposGrid 	:= oEstrGrid:GetFields()
	For nLin := 1 To nLinhas
		oDetail:GoLine(nLin)
		aValGrid := {}

		For nLin2 := 1 To Len(aCposGrid)
			Aadd(aValGrid,oDetail:GetValue(aCposGrid[nLin2,3]))
		Next nLin2
		AADD(aValGrid,oDetail:IsDeleted())

		if ( nPos := ASCAN(aGridOri,{|x| x[3]+x[4] == aValGrid[3]+aValGrid[4] }) ) == 0 
			AADD(aGridOri,aValGrid)
		else
			aGridOri[nPos] := aValGrid
		endif
	Next nLin

	ProcRegua(Len(aGridOri))

	//For I := 1 To Len(oDetail:ACOLS)
	For I := 1 To Len(aGridOri)

		if aGridOri[I,len(aGridOri[I])]

			Z84->(DbSetOrder(1))
			If Z84->(DbSeek(XFilial("Z84")+cAno+aGridOri[I][3]+aGridOri[I][4]+cMes))

				RecLock("Z84",.F.)
				Z84->(DbDelete())
				Z84->(MsUnlock())

			EndIf		

			loop
		EndIf	

		If ( nOper == 3 )

			RecLock("Z84",.T.)

			Z84->Z84_FILIAL		:= XFILIAL("Z84")
			Z84->Z84_ANO		:= cAno
			Z84->Z84_MES		:= cMes 		
			Z84->Z84_CODCLI		:= aGridOri[I][3]
			Z84->Z84_LOJCLI		:= aGridOri[I][4]
			Z84->Z84_QTDE		:= aGridOri[I][8]
			Z84->Z84_VALOR		:= aGridOri[I][9]

			Z84->(MsUnlock())

		ElseIf ( nOper == 4 )

			Z84->(DbSetOrder(1))
			If Z84->(DbSeek(XFilial("Z84")+cAno+aGridOri[I][3]+aGridOri[I][4]+cMes))

				RecLock("Z84",.F.)

				Z84->Z84_QTDE	:= aGridOri[I][8]
				Z84->Z84_VALOR	:= aGridOri[I][9]

				Z84->(MsUnlock())

			Else

				RecLock("Z84",.T.)

				Z84->Z84_FILIAL		:= XFILIAL("Z84")
				Z84->Z84_ANO		:= cAno
				Z84->Z84_MES		:= cMes 		
				Z84->Z84_CODCLI		:= aGridOri[I][3]
				Z84->Z84_LOJCLI		:= aGridOri[I][4]
				Z84->Z84_QTDE		:= aGridOri[I][8]
				Z84->Z84_VALOR		:= aGridOri[I][9]

				Z84->(MsUnlock())

			EndIf

		EndIf

	Next I

	END TRANSACTION

	RestArea(aArea)
Return(.T.)


//Filtra grid
Static Function fFiltraGrid(oView)

	Local aPergs 	:= {}
	local cLoad	    := 'FPVET3FL' + cEmpAnt
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
			if UPPER(Alltrim(cNomeLoja)) $ UPPER(Alltrim(aGridOri[nLin,6])) .or. UPPER(Alltrim(cPromotor)) $ UPPER(Alltrim(aGridOri[nLin,7]))
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