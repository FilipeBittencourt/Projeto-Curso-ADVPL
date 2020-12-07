#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "rwmake.ch" 
#Include "TopConn.ch"

/*/{Protheus.doc} BIA871
@author Ranisses A. Corona
@since 17/02/2017
@version 1.0
@description Cadastro de Rede de Compras
@type function
/*/
User Function BIA871()
	Local oBrowse := NIL

	DbSelectArea('Z79')
	DbSetOrder(1)
	//fAjustaHelp()

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('Z79')
	oBrowse:SetDescription('Cadastro de Rede de Compras')
	oBrowse:Activate()

Return 


Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar', 'VIEWDEF.BIA871', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.BIA871', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.BIA871', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.BIA871', 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.BIA871', 0, 8, 0, NIL } )
Return aRotina


Static Function ModelDef()
	Local oModel 	:= NIL
	Local oStruZ79	:= FWFormStruct(1,'Z79', {|cCampo|   AllTRim(cCampo) $ "Z79_REDE|Z79_DESCR|"})
	Local oStruGrid := FWFormStruct(1,'Z79', {|cCampo| !(AllTRim(cCampo) $ "Z79_REDE|Z79_DESCR|")})

	oModel	:= MPFormModel():New('Z79MVC',{|oModel| (.T.)},{|oModel| (.T.)},{|oModel| fCommit(oModel)})
	oModel:SetDescription("Cadastro de Rede de Compras")	
	oModel:AddFields('MdFieldZ79',,oStruZ79)
	oModel:SetPrimaryKey({"Z79_FILIAL","Z79_REDE"})
	oModel:GetModel('MdFieldZ79'):SetDescription('Cadastro de Rede de Compras')

	oModel:AddGrid('MdGridZ79','MdFieldZ79',oStruGrid,,{|oModel,nLine| fLinOK(oModel,nLine)},/*bPreGrid*/,/*bProsGrid*/)
	oModel:SetRelation('MdGridZ79',{ {'Z79_FILIAL','xFilial("Z79")'},{"Z79_REDE","Z79_REDE"}}, Z79->(IndexKey(1)) )
	oModel:GetModel('MdGridZ79'):SetDescription('Clientes e Grupos')	

	oModel:GetModel("MdGridZ79"):SetDelAllLine(.T.)
	oModel:GetModel('MdGridZ79'):SetOptional(.T.)	
	oModel:GetModel('MdGridZ79'):SetUniqueLine({"Z79_CODCLI","Z79_LOJCLI","Z79_CODGRP"})

Return oModel


Static Function ViewDef()
	Local oView		:= NIL
	Local oModel	:= FWLoadModel('BIA871') 
	Local oStruZ79	:= FWFormStruct(2,'Z79', {|cCampo| AllTRim(cCampo) $ "Z79_REDE|Z79_DESCR|"})
	Local oStruGrid := FWFormStruct(2,'Z79', {|cCampo| !(AllTRim(cCampo) $ "Z79_REDE|Z79_DESCR|")})

	oStruZ79:SetNoFolder()

	oView:= FWFormView():New() 
	oView:SetModel(oModel)              

	oView:AddField('VIEW_Z79', oStruZ79, 'MdFieldZ79')
	oView:AddGrid ('GRID_Z79', oStruGRID, 'MdGridZ79' )

	oView:CreateHorizontalBox("MAIN",35)
	oView:CreateHorizontalBox("GRID",65)

	oView:EnableTitleView('VIEW_Z79','Cabeçalho')
	oView:EnableTitleView('GRID_Z79','Clientes e Grupos')

	oView:SetOwnerView('VIEW_Z79','MAIN')
	oView:SetOwnerView('GRID_Z79','GRID')

Return oView


//Funcao de pos validacao da linha do objeto Grid
Static Function fLinOK(oGrid,nLine)
	local nOpc	:= oGrid:GetOperation()
	Local lRet	:= .T.
	Local nRede	:= Z79->Z79_REDE 

	DbSelectArea('Z79')

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
		oGrid:GoLine(nLine)
		If !oGrid:IsDeleted()		
			If lRet .And. !Empty(oGrid:GetValue('Z79_CODCLI')) .And. !Empty(oGrid:GetValue('Z79_CODGRP')) 
				lRet := .F.
				MsgBox("Não é permitido preencher os campos de Cliente e Grupo na mesma linha. Favor preencher somente um dos campos para cada linha digitada.","STOP")
			EndIf

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

		EndIf
	EndIf

	Z79->(DbSetOrder(1))

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
	Local oField    := oModel:GetModel("MdFieldZ79")
	Local oGrid     := oModel:GetModel("MdGridZ79")
	Local cUF		:= oField:GetValue('Z79_EST')
	Local cCodMun	:= oField:GetValue('Z79_CODMUN')
	Local cPercur	:= oField:GetValue('Z79_PERCUR')
	Local cRota		:= oField:GetValue('Z79_ROTA')
	Local nRecno	:= Z79->(Recno())

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE

		lRet := ExistCpo("ZMB",M->Z79_EST+M->Z79_CODMUN,2)                                                                                      

		// validação do grid
		if lRet 
			For nX := 1 To oGrid:GetQtdLine()
				oGrid:GoLine(nX)
				lRet := fLinOK(oGrid,nX)
				If !lRet
					Exit
				EndIf
				if lRet .and. !oGrid:IsDeleted()
					nLinValid++
				endif
			Next nX	
			if lRet .and. nLinValid == 0
				lRet := .F.
				Help(" ",1,"ELOMSA0604")
			endif	
		endif

		If nOpc == MODEL_OPERATION_INSERT

			Z79->(dbSetOrder(3))
			if lRet .and. Z79->(DbSeek(xFilial("Z79")+PADR(alltrim(cUF),TamSX3("Z79_EST")[1]) + PADR(alltrim(cCodMun),TamSX3("Z79_CODMUN")[1]) + PADR(alltrim(cPercur),TamSX3("Z79_PERCUR")[1]) + PADR(alltrim(cRota),TamSX3("Z79_ROTA")[1]) ))
				lRet := .F.
				Help(" ",1,"ELOMSA0601")
			endif
			Z79->(dbSetOrder(1))
			Z79->(DbGoTo(nRecno))
		endif
	endif
Return lRet


//Commit 
Static Function fCommit(oModel)
	Local lRet 		 := .T.
	Local oGrid		 := oModel:GetModel("MdGridZ79")
	Local oForm		 := oModel:GetModel("MdFieldZ79")
	Local nX   		 := 0
	Local nY		 := 0
	local nOpc 		 := oModel:GetOperation()
	Local aCposForm  := oForm:GetStruct():GetFields()
	Local aCposGrid  := oGrid:GetStruct():GetFields()

	Private INCLUI   := .F.
	Private ALTERA   := .F.

	For nX := 1 To oGrid:GetQtdLine()
		oGrid:GoLine(nX)
		Z79->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE
			//-- Deleta registro
			Z79->(RecLock("Z79",.F.))
			Z79->(dbDelete())
			Z79->(MsUnLock())
		Else

			//-- Grava inclusao/alteracao
			RecLock("Z79",Z79->(EOF()))
			If oGrid:IsDeleted()
				Z79->(dbDelete())
			Else
				Z79->Z79_FILIAL := xFilial("Z79")
				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)
					If Z79->(FieldPos(aCposForm[nY,3])) > 0 
						Z79->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
					EndIf
				Next nY
				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)
					If Z79->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "Z79_FILIAL"
						Z79->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])
					EndIf
				Next nY

			EndIf
			Z79->(MsUnLock())	

		EndIf
	Next nX

	If nOpc <> MODEL_OPERATION_VIEW	
		//Replica informação da Rede de Compras para o Cadastro de Clientes
		U_BIAMsgRun("Atualizando base de Clientes...",,{|| U_fUpdRedCom() })
	EndIf

	If nOpc == MODEL_OPERATION_UPDATE
		MsgInfo('Informações Gravadas com Sucesso!')
	EndIf

Return lRet

User Function fUpdRedCom() 
	Local aEmp := {"01","05","07","12","13","14"}
	Local cSql := ""
	Local cSA1 := GetNextAlias()
	Local cAccMod := ""
	Local x
	ConOut("HORA: "+TIME()+" - LINHA 261 - ROTINA fUpdRedCom")	
	For x := 1 to Len(aEmp)
		If Select(cSA1) > 0		
			(cSA1)->(DbCloseArea())		
		EndIf

		EmpOpenFile(cSA1, "SA1", 15, .T., aEmp[x], @cAccMod)

		cSql := "SELECT R_E_C_N_O_ REC FROM SA1"+aEmp[x]+"0 WITH(NOLOCK) WHERE A1_YREDCOM <> '' AND D_E_L_E_T_ = ''"
		If ChkFile("_cSql")
			DbSelectArea("_cSql")
			DbCloseArea()
		EndIf
		TcQuery cSql Alias "_cSql" New
		ConOut("HORA: "+TIME()+" - LINHA 275 - ROTINA fUpdRedCom")		
		While _cSql->(!EOF())
			(cSA1)->(DbGoTo(_cSql->REC))
			IF (cSA1)->(!EOF())
				While !Reclock(cSA1,.F.);EndDo
				(cSA1)->A1_YREDCOM := ""
				(cSA1)->A1_MSEXP := ""
				(cSA1)->(MsUnlock())			
			EndIf
			_cSql->(DbSkip())
		EndDo	
		ConOut("HORA: "+TIME()+" - LINHA 286 - ROTINA fUpdRedCom")			
		If Select(cSA1) > 0		
			(cSA1)->(DbCloseArea())
		EndIf


		//Limpa Cadastro de Clientes 
		//cSql := ("UPDATE SA1"+aEmp[x]+"0 SET A1_YREDCOM = '', A1_MSEXP = '' WHERE A1_YREDCOM <> '' AND D_E_L_E_T_ = '' ")	
		//TcSqlExec(cSql)
		ConOut("HORA: "+TIME()+" - LINHA 295 - ROTINA fUpdRedCom")	
		//Atualiza Rede de Compras para Clientes
		cSql := "UPDATE SA1"+aEmp[x]+"0 SET A1_YREDCOM = Z79_REDE, A1_MSEXP = '' "
		cSql += "FROM SA1"+aEmp[x]+"0 SA1 			" 
		cSql += "		INNER JOIN Z79010 Z79 ON 	" 
		cSql += " 		Z79_CODCLI = A1_COD AND 	"
		cSql += "		Z79_LOJCLI = A1_LOJA AND 	"
		cSql += "		Z79_CODCLI <> ''			"
		cSql += "WHERE SA1.D_E_L_E_T_ = '' AND Z79.D_E_L_E_T_ = '' "
		TcSqlExec(cSql)	
		ConOut("HORA: "+TIME()+" - LINHA 305 - ROTINA fUpdRedCom")	
		//Atualiza Rede de Compras para Clientes
		cSql := "UPDATE SA1"+aEmp[x]+"0 SET A1_YREDCOM = Z79_REDE, A1_MSEXP = '' "
		cSql += "FROM SA1"+aEmp[x]+"0 SA1 			" 
		cSql += "		INNER JOIN Z79010 Z79 ON 	" 
		cSql += " 		Z79_CODGRP = A1_GRPVEN  AND "
		cSql += " 		Z79_CODGRP <> ''			"
		cSql += "WHERE SA1.D_E_L_E_T_ = '' AND Z79.D_E_L_E_T_ = '' "
		TcSqlExec(cSql)	
		ConOut("HORA: "+TIME()+" - LINHA 314 - ROTINA fUpdRedCom")					
	Next	

	If Select(cSA1) > 0		
		(cSA1)->(DbCloseArea())
	EndIf
	ConOut("HORA: "+TIME()+" - LINHA 320 - ROTINA fUpdRedCom")	
Return

//Help customizado
Static Function fAjustaHelp()
	local aHlpP  := {}

	aHlpP  := {}
	aAdd(aHlpP, " Relacionamento Invalido! ")
	aAdd(aHlpP, " O relacionamento: " )
	aAdd(aHlpP, " UF + Municipio + Zona + Setor" )
	aAdd(aHlpP, " ja esta cadsatrado! " )
	PutHelp("PELOMSA0601", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd(aHlpP, " Informe outro relacionamento! " )
	PutHelp("SELOMSA0601", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, " Cadastro Invalido! ")
	aAdd(aHlpP, " Bairro não informado! ")
	PutHelp("PELOMSA0602", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd(aHlpP, " Informe o Bairro! " )
	PutHelp("SELOMSA0602", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, " Cadastro Invalido! ")
	aAdd(aHlpP, " Porte não informado! ")
	PutHelp("PELOMSA0603", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd(aHlpP, " Informe o Porte! " )
	PutHelp("SELOMSA0603", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, " Cadastro Invalido! ")
	PutHelp("PELOMSA0604", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd(aHlpP, " Informe pelo menos um Bairro e Porte! " )
	PutHelp("SELOMSA0604", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, " Cadastro Invalido! ")
	aAdd(aHlpP, " O Bairro não pertence a este municipio! ")
	PutHelp("PELOMSA0605", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd(aHlpP, " Informe um Bairro valido! " )
	PutHelp("SELOMSA0605", aHlpP, aHlpP, aHlpP, .T.)
return