#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.ch"
#INCLUDE "FWMVCDEF.CH"
/*
Projeto: INTEGRAÇÃO NEUROTECH
Cliente: UNIAO
Desnv: FACILE - ALFONSO
Data: 2018-12-11
---------
ROTINA PARA MONTAR A TELA DO LOG DE INTEGRAÇÃO NEUROTECH
TABELA ZZ8
---------
soemte para consulta, porque os dados sao atualizados pelas integrações

*/
/*
User Function AXCZZ8()

Private cCadastro:= "LOG Interg Neurotech"
private aRotina := {{"Pesquisar","AXPESQUI",0,1},{"Visualizar","AXVISUAL",0,2},{"Legenda","U_ADVLEG()",0,3}}
                     //{"Incluir","AXINCLUI",0,3},;
                     //{"Alterar","AXALTERA",0,4},;
                     //{"Excluir","AXDELETA",0,5},;
                     //{"Legenda","U_ADVLEG()",0,3}}
                        
                        
Private aCores :=  {{"!Empty(ZZ8->ZZ8_DTRESN)", "BR_VERDE"},{"Empty(ZZ8->ZZ8_DTRESNI)", "BR_VERMELHO"}}
					//{"ZZ4->ZZ4_STATUS ='2'", "BR_AZUL"},;
					//{"ZZ4->ZZ4_STATUS ='3'", "BR_AMARELO"},;
					//{"ZZ4->ZZ4_STATUS ='4'", "BR_PRETO"},;
					//{"Empty(ZZ8->ZZ8_DTENVI)", "BR_VERMELHO"}}

mBrowse(6,1,22,75,"ZZ8",,,,,,aCores)
				
Return

Function U_ADVLEG()

Local aLegenda := {{"BR_VERDE","Com retorno"},{"BR_VERMELHO","Aguardando Retorno"}}
				//{"BR_AZUL"," Atendimento"},;
				//{"BR_AMARELO","Cham aguardando USR"},;
				//{"BR_PRETO","Cham Encerrado"},;
				//{"BR_VERMELHO","Aguardando Retorno"}}
	
BrwLegenda(cCadastro,"Legenda",aLegenda)

Return()
*/

Static cCadastro := "LOG Interg Neurotech"

User Function VIXA267()

	Local aArea		:= GetArea()
	Local oBrw		:= FWMBrowse():New()
	Local cFunBkp	:= FunName()
	
	SetFunName("VIXA267")
	
	oBrw:SetDescription(cCadastro) 
	oBrw:SetAlias("ZZ8")	
	 
	 /* 
	 ZZ8_STATUS
	 1 - Pendente retorno - verde
     2 - Retorno com bloqueio - vermelho
     3 - Retonro liberado - azul
     4 - Retorno bloqueado,mas liberado manual -  amarelo
     5 - Vazio -  Erro 
	*/
	
	//oBrw:AddLegend( "!Empty(ZZ8->ZZ8_DTRESN)", "GREEN"  , "Com retorno" )
	//oBrw:AddLegend( "Empty(ZZ8->ZZ8_DTRESNI) ", "RED"   , "Aguardando Retorno" )

	// UTILIZANDO O STATUS AGORA
	oBrw:AddLegend( "ZZ8->ZZ8_STATUS ='1'", "BLUE"  , "Enviado" )
	oBrw:AddLegend( "ZZ8->ZZ8_STATUS ='2'", "RED"   , "Retorno C/Bloqueio" )
	oBrw:AddLegend( "ZZ8->ZZ8_STATUS ='3'", "GREEN"   , "Retorno Liberado" )
	oBrw:AddLegend( "ZZ8->ZZ8_STATUS ='4'", "YELLOW"   , "Retorno BLQ. Lib manual" )
	oBrw:AddLegend( "ZZ8->ZZ8_STATUS ='5'", "ORANGE"   , "Pendente" )
	oBrw:AddLegend( "ZZ8->ZZ8_STATUS ='6'", "GRAY"   , "Cancelado pela mesa" )
	oBrw:AddLegend( "Empty(ZZ8->ZZ8_STATUS)", "BLACK"   , "Erro" )
	oBrw:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea)

Return()
 
 
Static Function MenuDef()

	Local aRot := {}	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VIXA267' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	//ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VIXA267' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	//ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VIXA267' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	//ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VIXA267' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
   // ADD OPTION aRot TITLE 'Pesquisar'    ACTION 'VIEWDEF.VIXA267' OPERATION MODEL_OPERATION_AXPESQUI ACCESS 0 //OPERATION 5

Return aRot


Static Function ModelDef()

	Local oStruZZ8  := FwFormStruct(1,"ZZ8")// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel := MPFormModel():New("ZZ8MVC_M")// Cria o objeto do Modelo de Dados		
	
	oModel:AddFields("ZZ8MASTER",/*cOwner*/, oStruZZ8)// 01 - Adiciona ao modelo um componente de formulário
	oModel:SetPrimaryKey({'ZZ8_FILIAL','ZZ8_COD'})// 02 -Setando a chave primária da rotina ou campos do indice
	oModel:SetDescription(cCadastro)// 03 - Adiciona UM nome/descrição do Modelo de Dados 
	oModel:GetModel("ZZ8MASTER" ):SetDescription(cCadastro)// 04 Adiciona um nome/descrição do formulário QUE esse nome SERÁ USADO na VIEWDEF()
	
	// Retorna o Modelo de dados 
Return(oModel)


Static Function ViewDef()

	Local oModel   := FwLoadModel("VIXA267")// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado (nome do arquivo)
	Local oStruZZ8 := FwFormStruct(2,"ZZ8") // Cria a estrutura a ser usada na View
	Local oView // Interface de visualização construída
	
	oView := FWFormView():New() // Cria o objeto de View
	oView:SetModel(oModel)// Define qual o Modelo de dados será utilizado na View
	oView:AddField("VIEW_ZZ8",oStruZZ8,"ZZ8MASTER") // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice) 
	oView:CreateHorizontalBox("TELA",100) // Criar um "box" horizontal para receber algum elemento da view
	oView:SetOwnerView( 'VIEW_ZZ8', 'TELA' )// Relaciona o identificador (ID) da View com o "box" para exibição 

// Retorna o objeto de View criado
Return(oView)

// ALFONSO PARA VUSCAR NOME cliente
// campo ZZ8_NUMPED
User Function ZZ8NOMC(cNumped)
	// 2018DEZ17 ALFONSO ; PROJETO: NEUROTECH
    Local cNomCli :=''
    
    cNomCli := POSICIONE("SA1",1,XFILIAL("SA1")+(POSICIONE("SC5",1,XFILIAL("SC5") + cNumped,"C5_CLIENTE") + POSICIONE("SC5",1,XFILIAL("SC5") + cNumped,"C5_LOJACLI")),"A1_NOME")

Return (cNomCli)

// ALFONSO PARA VUSCAR CNPJ
// campo ZZ8_NUMPED
User Function ZZ8CGC(cNumped)
	// 2018DEZ17 ALFONSO ; PROJETO: NEUROTECH
    Local cCgc :=''
    
    cCgc := POSICIONE("SA1",1,XFILIAL("SA1")+(POSICIONE("SC5",1,XFILIAL("SC5") + cNumped,"C5_CLIENTE") + POSICIONE("SC5",1,XFILIAL("SC5") + cNumped,"C5_LOJACLI")),"A1_CGC")

Return (cCgc)