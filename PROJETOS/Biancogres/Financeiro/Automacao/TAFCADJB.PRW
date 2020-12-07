#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} TAFCADJB
@description Cadastro dos Processo de JOB - execucao automatica
@author Fernando Rocha
@since 19/02/2019
@version 1.0
@type function
/*/
User Function TAFCADJB

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZK5')
	oBrowse:SetDescription('Configuração Facile Auto JOB')
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Executar'   ACTION 'U_TAFEXEJB' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.TAFCADJB' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.TAFCADJB' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.TAFCADJB' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.TAFCADJB' OPERATION 5 ACCESS 0

Return aRotina


User Function TAFEXEJB

	If !MsgNoYes("Tem certeza que deseja executar a JOB: "+ZK5->ZK5_CODIGO+" agora?")
		Return
	EndIf

	StartJob( "U_TAFSTAJB", GetEnvServer(),.F.,ZK5->ZK5_CODIGO)

Return


User Function TAFSTAJB(_cCodZK5)

	RpcSetEnv("01", "01")
	
	ConOut("[THREAD: "+AllTrim(Str(ThreadId()))+"] TAFSTAJB -> Iniciando.")

	ZK5->(DbSetOrder(2))
	IF ZK5->(DbSeek(XFilial("ZK5")+_cCodZK5))

	oTask := TAFScheduleTask():New()	
	oTask:ExecJob(SubStr(Time(),1,5))
	
	ENDIF
	
	RpcClearEnv()

Return


Static Function ModelDef() 

	Local oModel 
	Local oStruMaster 	:= FWFormStruct(1,"ZK5") 
	Local oStruParam 	:= FWFormStruct(1,"ZK6")

	Local cTitle 		:= "Facile Auto JOB"

	oModel := MPFormModel():New(cTitle)
	oModel:SetDescription(cTitle)

	oModel:SetDescription("Facile Auto JOB")  

	oStruParam:RemoveField("ZK6_FILIAL")
	oStruParam:RemoveField("ZK6_CODIGO")

	oModel:addFields('MASTER',,oStruMaster)  
	oModel:addGrid('DETAIL_1','MASTER',oStruParam)

	oModel:SetPrimaryKey({"ZK5_FILIAL","ZK5_CODIGO"})

	oModel:SetOptional('DETAIL_1', .T.)

	oModel:SetRelation("DETAIL_1", {{"ZK6_FILIAL","ZK5_FILIAL"},{"ZK6_CODIGO","ZK5_CODIGO"}},ZK6->(IndexKey(1)))

Return oModel 


Static Function ViewDef() 

	Local oModel := FWLoadModel('TAFCADJB') 
	Local oView 
	Local oStrMas	:= FWFormStruct(2, 'ZK5')   
	Local oStrDet1	:= FWFormStruct(2, 'ZK6')

	oView := FWFormView():New()  
	oView:SetModel(oModel)   

	oStrDet1:RemoveField("ZK6_FILIAL")
	oStrDet1:RemoveField("ZK6_CODIGO")

	oView:AddField('FORM_MASTER' , oStrMas,'MASTER' )  
	oView:AddGrid('FORM_DETAIL_1' , oStrDet1,'DETAIL_1')  

	oView:CreateHorizontalBox( 'BOX_FORM_MASTER', 50)  

	oView:CreateHorizontalBox('BOX_FORM_DETAIL', 50)	
	oView:CreateFolder('DETAIL_FOLDER','BOX_FORM_DETAIL')

	oView:AddSheet('DETAIL_FOLDER','ABA1','Parametros')
	oView:CreateHorizontalBox('BOX_FORM_DETAIL_ABA1', 100,,,'DETAIL_FOLDER','ABA1')

	oView:SetOwnerView('FORM_MASTER','BOX_FORM_MASTER')  
	oView:SetOwnerView('FORM_DETAIL_1','BOX_FORM_DETAIL_ABA1')

	oView:EnableTitleView('FORM_MASTER' , "Facile Auto JOB" )
	oView:SetCloseOnOk({||.T.})

Return oView