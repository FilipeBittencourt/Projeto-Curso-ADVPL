#include "PROTHEUS.CH"
#include "FWMBROWSE.CH"
#include "FWMVCDEF.CH"
#include "rwmake.ch"

/*/{Protheus.doc} BPOLTE03
@author Fernando Rocha
@since 20/07/2015
@version 1.0
@description Interface para manutencao da Politica Comercial
@obs MVC 
@type Function
/*/

/*/{Protheus.doc} BPOLTE03
@author Artur Antunes
@since 24/03/2017
@version 1.0
@description Inclusão de importação de dados por arquivo excel (BPTE03IP)
@obs OS 4704-16 
@type Function
/*/

#define STRU_CAB "CamposZA0"

User Function BPOLTE03()
	Local lRet := .T.
	Local aArea := ZA0->(GetArea())

	Private oMark
	Private cTitle := "Manutenção da Política Comercial"
	Private oPolitica 

	SetKey(VK_F11,{|| U_BPTE03FI() })  //Atalho para o filtro

	oMark:=FWMarkBrowse():NEW()		// Cria o objeto oMark - MarkBrowse   

	oMark:SetAlias("ZA0")			// Define a tabela do MarkBrowse
	oMark:SetDescription(cTitle)	// Define o titulo do MarkBrowse
	oMark:SetFieldMark("ZA0_OK")	// Define o campo utilizado para a marcacao
	oMark:SetFilterDefault()		// Define o filtro a ser aplicado no MarkBrowse  

	oMark:SetAllMark({|| AllMark()})

	oMark:Activate()  

	SetKey(VK_F11,{|| })  //Atalho para o filtro

	RestArea(aArea)
Return 


// Montar o menu Funcional
Static Function MenuDef()
	Local aRotina := {}

	//ADD OPTION aRotina TITLE "Pesquisar"  		ACTION 'PesqBrw' 	   	  	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 					ACTION "VIEWDEF.BPOLTE03" 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    					ACTION "VIEWDEF.BPOLTE03" 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    					ACTION "VIEWDEF.BPOLTE03" 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    					ACTION "VIEWDEF.BPOLTE03" 	OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE "Filtrar"    					ACTION "U_BPTE03FI" 		OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Aprovar"    					ACTION "U_BPTE03AP" 		OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Testar"    					ACTION "U_BPOLTST1(.F.)"	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Import. Excel"				ACTION "U_BPTE03IP"			OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar Dt. Virgência Fim"	ACTION "U_BPTE03DV"			OPERATION 8 ACCESS 0

Return aRotina


//Funcoes auxiliares para controle de filtro e marcacao
Static Function AllMark()

	oMark:GoTop()

	While (.T.)
		If !oMark:IsMark()
			oMark:MarkRec()
		EndIf

		oMark:GoDown()
		If ( oMark:At() == oMark:oBrowse:nLen ) 
			If !oMark:IsMark()
				oMark:MarkRec()
			EndIf
			Exit
		EndIf	
	EndDo

	oMark:GoTop()
	oMark:Refresh()

Return 


Static Function ClearMark()
	oMark:GoTop()

	While (.T.)
		If oMark:IsMark()
			oMark:MarkRec()
		EndIf

		oMark:GoDown()
		If ( oMark:At() == oMark:oBrowse:nLen ) 
			If !oMark:IsMark()
				oMark:MarkRec()
			EndIf
			Exit
		EndIf	
	EndDo

	oMark:GoTop()
	oMark:Refresh()

Return


//Perguntas para Filtro da Tela
User Function BPTE03FI

	Local aPergs := {}
	Local aRet := {1,Space(4),Space(6),Space(6),Space(1),Space(2),Space(15)}

	aAdd( aPergs ,{3,"Status: ",1,{"Aprovadas","Não Aprovadas","Todas"},300,Nil,.T.,Nil})
	aAdd( aPergs ,{3,"Vigência: ",1,{"Ativas","Expiradas","Futuras","Todas"},300,Nil,.T.,Nil})

	aAdd( aPergs ,{1,"Tipo: ",Space(4),"@!","","ZA1","",20,.F.})
	aAdd( aPergs ,{1,"Grupo Clientes: ",Space(6),"@!","","ACY","",20,.F.})
	aAdd( aPergs ,{1,"Cliente: ",Space(6),"@!","","SA1","",20,.F.})
	aAdd( aPergs ,{1,"Pacote: ",Space(1),"@!","","ZH","",20,.F.})
	aAdd( aPergs ,{1,"Formato: ",Space(2),"@!","","ZZ6","",20,.F.})
	aAdd( aPergs ,{1,"Produto: ",Space(15),"@!","","SB1","",70,.F.})

	If ParamBox(aPergs ,"Filtrar Política Comercial",aRet,,,,,,,,.F.,.F.)  
		U_BIAMsgRun("Filtrando...",,{|| FilProc(aRet)})
	EndIf   
Return


Static Function FilProc(aRet)

	Local _cFiltro := ""
	Local _bAnd := {|| IIf(!Empty(_cFiltro)," .And. ","") }

	ClearMark()         
	oMark:CleanFilter()   

	//STATUS                                   
	If ( aRet[1] == 1 )
		_cFiltro += " ZA0_STATUS == 'A' "
	ElseIf ( aRet[1] == 2 )                   
		_cFiltro += " ZA0_STATUS == 'N' "
	EndIf

	//VIGENCIA
	If ( aRet[2] == 1 ) //Ativas
		_cFiltro += Eval(_bAnd)+" DTOS(ZA0_VIGINI) <= '"+DTOS(dDataBase)+"' .AND. DTOS(ZA0_VIGFIM) >= '"+DTOS(dDataBase)+"' "
	ElseIf ( aRet[2] == 2 ) //Expiradas
		_cFiltro += Eval(_bAnd)+" DTOS(ZA0_VIGFIM) < '"+DTOS(dDataBase)+"' "
	ElseIf ( aRet[2] == 3 ) //Futuras                          
		_cFiltro += Eval(_bAnd)+" DTOS(ZA0_VIGINI) > '"+DTOS(dDataBase)+"' " 
	EndIf          

	If !Empty(aRet[3])                                           
		_cFiltro += Eval(_bAnd)+" ZA0_TIPO == '"+aRet[3]+"' "
	EndIf   

	If !Empty(aRet[4]) 
		_cFiltro += Eval(_bAnd)+" ZA0_GCLI == '"+aRet[4]+"' "
	EndIf

	If !Empty(aRet[5])
		_cFiltro += Eval(_bAnd)+" ZA0_CODCLI == '"+aRet[5]+"' "
	EndIf

	If !Empty(aRet[6])  
		_cFiltro += Eval(_bAnd)+" ZA0_PACOTE == '"+aRet[6]+"' "                      
	EndIf

	If !Empty(aRet[7])
		_cFiltro += Eval(_bAnd)+" ZA0_FORMAT == '"+aRet[7]+"' "
	EndIf

	If !Empty(aRet[8])
		_cFiltro += Eval(_bAnd)+" ZA0_CODPRO == '"+aRet[8]+"' "
	EndIf

	oMark:SetFilterDefault(_cFiltro)

Return


//Aprovacao 
User Function BPTE03AP()
	Local _oPolitica

	If !U_VALOPER("032",.F.) //Aprovadores da Politica de Desconto
		Msgbox("Usuário sem acesso a rotina de Aprovação!","OP 032 - BPOLTE03 - Aprovar","STOP")
		Return
	EndIf

	If !MsgNoYes("Tem certeza que deseja aprovar todas as Politicas marcadas?","BPOLTE03 - Aprovar")
		Return
	EndIf   

	ZA0->(DbSetOrder(0))
	ZA0->(DbGoTop())

	While !ZA0->(Eof())

		If ZA0->ZA0_OK == oMark:Mark()

			_oPolitica := TBiaPolitica():New(XFilial("ZA0"))
			_oPolitica:LoadFromRecno(ZA0->(RecNo()))
			_oPolitica:Aprovar()

			FreeObj(_oPolitica)
		EndIf

		ZA0->(DbSkip())
	EndDo

	oMark:GoTop()
	oMark:Refresh()

Return


User Function BPTE03DV()
	
	Local lRet			:= .F.
	Local cLoad			:= "BPTE03DV" + cEmpAnt
	Local cFileName		:= RetCodUsr() +"_"+ cLoad
	Local aPergs		:= {}
	
	dDtFim				:= cTod("")
	
	aAdd( aPergs ,{1,"Nova Data de Virgência Final"			, dDtFim	,"",,"",'.T.',50,.F.})
	
	If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
		Return()
	EndIf
	
	dDtFim := ParamLoad(cFileName,,1,dDtFim)
	
	If (!Empty(dDtFim))
		
		If (dDtFim < dDataBase)
			Help(,,"Validação",, "Não é possível alterar registro(s). O Campo Nova Data de Vigência Final não pode ser menor que HOJE.", 1, 0)
			Return	
		EndIf
		
	
		If !MsgNoYes("Tem certeza que deseja alterar as datas de virgências final de todas as Politicas marcadas?", "BPOLTE03 - Alterar Data Virgência")
			Return
		EndIf   
		
		Processa({ || AltDtVirFim() },"Aguarde...", "Atualizando registros...",.F.)
	
	EndIf
		
Return

Static Function AltDtVirFim()

	Local _oPolitica 	:= Nil
	
	ZA0->(DbSetOrder(0))
	ZA0->(DbGoTop())

	While !ZA0->(Eof())

		If ZA0->ZA0_OK == oMark:Mark()

			_oPolitica := TBiaPolitica():New(XFilial("ZA0"))
			_oPolitica:LoadFromRecno(ZA0->(RecNo()))
			_oPolitica:AltDataVirgencia(dDtFim)
			
			FreeObj(_oPolitica)
		EndIf

		ZA0->(DbSkip())
	EndDo

	oMark:GoTop()
	oMark:Refresh()
	MsgInfo("Registros atualizados com sucesso.", "Mensagem")
	
Return


//Definicoes da View
Static Function ViewDef()
	Local oView
	Local oModel	:= ModelDef()
	Local oStr1		:= FWFormStruct(2, 'ZA0')
	Local nOpc		:= oModel:GetOperation()

	// Cria o objeto de View
	oView := FWFormView():New()     

	oView:SetViewCanActivate({|oView| MVC001CA(oView)})

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1, STRU_CAB)

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , cTitle )
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return oView


//Definicoes do Model
Static Function ModelDef()
	Local oModel
	Local oStr1:= FWFormStruct( 1, 'ZA0', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados
	Local I
	Local _cCampo

	//Criar o objeto de controle das operacoes do modelo para isolar a interface da logica       
	oPolitica := TBiaPolitica():New(XFilial("ZA0"))

	//Cria o objeto do Modelo de Dados
	//Irie usar uma função MVC001V que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New(cTitle, /*bPreValid*/ , { | oModel | MVC001V( oModel ) } , { | oMdl | MVC001C( oModel ) } ,, /*bCancel*/ )
	oModel:SetDescription(cTitle)

	//Campos para nao incluir na View
	//oStr1:RemoveField("ZA0_FILIAL") 

	//Valid
	//oStr1:SetProperty(oPolitica:cmp_TIPO	,MODEL_FIELDFACILE_VALID,	{|oModel| oPolitica:ClearFields(oModel, STRU_CAB), EXISTCPO("ZA1",oModel:GetValue(oPolitica:cmp_TIPO),2) })

	//When
	oStr1:SetProperty(oPolitica:cmp_TIPO	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_TIPO	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_MARCA	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_MARCA	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_CAT		,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_CAT		, oModel) })
	oStr1:SetProperty(oPolitica:cmp_TPSEG	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_TPSEG	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_GCLI	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_GCLI	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_CODCLI	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_CODCLI	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_LOJCLI	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_LOJCLI	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_REDE	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_REDE	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_VEND  	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_VEND  	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_PACOTE	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_PACOTE	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_FORMAT	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_FORMAT	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_CODPRO	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_CODPRO	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_CLASSE	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_CLASSE	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_PDESC 	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_PDESC 	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_PVERBA	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_PVERBA	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_VIGINI	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_VIGINI	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_VIGFIM	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_VIGFIM	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_ESTCLI	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_ESTCLI	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_LOTE	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_LOTE	, oModel) })
	oStr1:SetProperty(oPolitica:cmp_ZONAFR	,MODEL_FIELD_WHEN,	{|oModel| oPolitica:FieldWhen(oPolitica:cmp_ZONAFR	, oModel) })


	//Trigger - limpar campos apos trocar TIPO                             
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_CAT		,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_TPSEG 	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_GCLI  	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_CODCLI	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_LOJCLI	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_REDE		,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_VEND  	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_PACOTE	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_FORMAT	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_CODPRO	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_CLASSE	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_PDESC 	,, {|| 0 })
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_PVERBA	,, {|| 0 })
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_ESTCLI	,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_LOTE		,, {|| ""})
	oStr1:AddTrigger(oPolitica:cmp_TIPO, oPolitica:cmp_ZONAFR	,, {|| ""})

	// Adiciona ao modelo uma estrutura de formulário de edição por campo - Enchoice
	oModel:addFields(STRU_CAB,,oStr1,{|oModel|MVC001T(oModel)},,)

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZA0_FILIAL', 'ZA0_TIPO'})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel(STRU_CAB):SetDescription(STRU_CAB)

Return oModel


//Esta função será executada no inicio do carregamento da tela
//Usada para criar o objeto oPolitica responsavel por todas as operacoes da interface
Static Function MVC001T( oModel )
	Local lRet      := .T.
Return(lRet)


//Validacao antes de entrar na tela de manutencao do registro
Static Function MVC001CA(oView)
	Local lRet      := .T.
	Local nOpc      := oView:GetOperation()
	Local aArea     := GetArea()  

	lRet := oPolitica:CanActivate(nOpc, ZA0->(RecNo()))

	RestArea(aArea)
Return lRet      


//Validacao apos salvar registro
Static Function MVC001V(oModel)
	Local lRet      := .T.
	Local oModel	:= oModel:GetModel( STRU_CAB )
	Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()

	oPolitica:LoadFromModel(oModel)

	If (nOpc == 3)
		lRet := oPolitica:ValidInsert()
	ElseIf (nOpc == 4)
		lRet := oPolitica:ValidAlter()

	ElseIf (nOpc == 5)
		//Implementar??
		//lRet := oPolitica:ValidDelete()
	EndIf

	RestArea(aArea)
Return lRet      


//Apos gravar registro
Static Function MVC001C(oModel)
	Local nOpc      := oModel:GetOperation()

	FWFormCommit(oModel)

	If (nOpc == 3)
		oPolitica:AfterInsert(ZA0->(RecNo()))
	EndIf

Return .T.


//Importar Excel
User Function BPTE03IP()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	private cArquivo	:= space(100)

	fPergunte()
	AADD(aSays, OemToAnsi("Rotina para importação de Politica Comercial, por arquivo excel!"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Politica Comercial'), aSays, aButtons ,,,500)

	if lConfirm 
		if !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		else
			MsgStop('Informe o arquivo valido para importação!')
		endif
	endif	
return


//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	local cLoad	    := 'BPTE03IP' + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	endif
return 


//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	local oArquivo 			:= nil
	local aArquivo 			:= {}
	local aWorksheet 		:= {}
	local aCampos			:= {}
	local cTemp 			:= ''
	local cTabImp			:= 'ZA0'
	local aItem 			:= {}
	local aLinha			:= {}
	local aErro				:= {}
	local cErro 			:= ''
	local nImport			:= 0
	local cConteudo			:= ''
	local nTotLin			:= 0
	local nErro, nx, ny
	Private lMsErroAuto 	:= .F.            
	Private lMSHelpAuto 	:= .T.
	Private lAutoErrNoFile  := .T. 
	Private aRotina 		:= FWLoadMenuDef("BPOLTE03")
	Private oxModel 		:= FWLoadModel("BPOLTE03")	

	ProcRegua(0) 

	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	if len(aArquivo) > 0 

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		BEGIN TRANSACTION   

			For nx := 1 to len(aWorksheet) 

				IncProc("Processando Linha: " + StrZero(nx,3) + "/" + StrZero(nTotLin,3) )	

				if nx == 1
					aCampos := aWorksheet[nx]
					For ny := 1 to len(aCampos)
						cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
						aCampos[ny] := cTemp
					next ny
				else
					aLinha    := aWorksheet[nx]
					aItem     := {}
					cConteudo := ''
					
					If Empty(AllTrim(aLinha[1]))
						loop
					EndIf

					SX3->(DbSetOrder(2))

					For ny := 1 to len(aLinha)
						if len(aCampos) >= ny 

							cConteudo := aLinha[ny]
							
							If (!Empty(cConteudo))
							
								If SX3->(DbSeek(aCampos[ny]))
									
									do case 
										case SX3->X3_TIPO == "D"
										cConteudo := SubStr(cConteudo,1,10)
										cConteudo := stod(StrTran(cConteudo, "-", ""))
										case SX3->X3_TIPO == "N"
										cConteudo := Val(cConteudo)
										case SX3->X3_TIPO == "C"
										cConteudo := Padr(cConteudo,TamSX3(aCampos[ny])[1])
									endcase
									
											
									AADD(aItem,{ aCampos[ny] , cConteudo , nil })
								EndIf
								
							EndIf	
						endif	
					next ny	

					if len(aItem) > 0

						MsErroAuto := .F.
						FWMVCRotAuto(oxModel,"ZA0",3,{{STRU_CAB,aItem}})

						If lMsErroAuto		
							aErro := GetAutoGRLog()
							For nErro := 1 To Len(aErro)
								cErro += aErro[nErro]+CRLF
							Next nErro
							DisarmTransaction()  
							RestArea(aArea)

							MsgStop("Erro na importação da linha: " + StrZero(nx,3) + CRLF + CRLF + cErro )
							Return
						Else  
							nImport++
						Endif
						MsUnlockAll() 
					endif
				endif
			next nx
		END TRANSACTION
	endif

	if nImport > 0 
		MsgInfo("Registros importados com sucesso")
	else
		MsgStop("Falha na importação dos registros")
	endif
	RestArea(aArea)
return