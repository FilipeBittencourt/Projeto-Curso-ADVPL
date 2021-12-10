#INCLUDE "rwmake.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Ranisses Antonio Corona
Programa  := BIA854
Empresa   := Biancogres Cerêmicas S/A
Data      := 21/05/13
Uso       := Faturamento
Aplicação := Permite alteração de campos no SC5, sem necessidade de liberacao
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA854()
Private cCadastro 	:= OemToAnsi("Alteração de Pedido Especial")
Private cDelFunc 	:= ".T."
Private cString 	:= "SC5"
Private aRotina 	:= { { "Pesquisar"	, "AxPesqui" 	, 0 , 1 } ,;
						{ "" 			, "" 			, 0 , 2 } ,;
						{ "Alterar" 	, "U_AltFT46" 	, 0 , 4 } ,;
						{ "Visualizar" 	, "U_VisFT46" 	, 0 , 2 } ,;
						{ "" 			, "" 			, 0 , 4 } ,;
						{ "" 			, "" 			, 0 , 2 } }
Private aCores := {{"Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' },;		//Pedido em Aberto
			{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" ,'DISABLE'},;		   	//Pedido Encerrado
			{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)",'BR_AMARELO'},;
			{ "C5_BLQ == '1'",'BR_AZUL'},;	//Pedido Bloquedo por regra
			{ "C5_BLQ == '2'",'BR_LARANJA'}}	//Pedido Bloquedo por verba

dbSelectArea("SC5")
dbSetOrder(1)
dbSelectArea(cString)
mBrowse( 005, 005,093,180,cString,,,,,, aCores )

Return

//---------------------------
User Function AltFT46()
Local aAlias := SC5->(GetArea())
Local aAlter := {"C5_YPC","C5_MENPAD","C5_MENNOTA","C5_YOBS","C5_YTPTRAN","C5_YPGTO","C5_YTIPOCO","C5_OBRA","C5_YCLVL","C5_YITEMCT","C5_YPEDPAI","C5_YCLIORI","C5_YLOJORI","C5_YSI"}// campo travado a edição
Local nRet

nRet := AxAltera("SC5", SC5->(RecNo()), 4,,aAlter,,,"U_cTudoOk()",,,,,,.T.)

If nRet == 1
	SC5->(DbGoTop())
Else
	RestArea(aAlias)
EndIf

Return

//---------------------------
User Function VisFT46()
Local aAlias := SC5->(GetArea())
Local nRet

nRet := AxVisual("SC5", SC5->(RecNo()), 4,,,,,/*cTudOk*/,,,,,,.T.)

If nRet == 1
	SC5->(DbGoTop())
Else
	RestArea(aAlias)
EndIf

Return

//------------------------------
User Function cTudoOk
Local lRet := .T.
Local cAliasTmp 

If !cEmpAnt $ "02_13" //Nao executa esta regra para Ceramica Incesa e Mundi
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			SELECT COUNT(*) QUANT 
			FROM  %Table:SC6% 
			WHERE C6_NUM = %Exp:M->C5_NUM% AND ( C6_CF IN ('5910','5911','5912','5914','5949','6910','6911','6912','6914','6949') OR  C6_PRODUTO < 'A' OR C6_VALDESC > 0 ) AND %NOTDEL%
		EndSql	 	
		If (cAliasTmp)->QUANT > 0 .AND. EMPTY(M->C5_YCLVL)

		Alert("A Classe de Valor devera ser informada. Favor verificar procedimento com Setor Contabil.")
		lRet := .F.
		Return(lRet)
	EndIf
EndIf

If cEmpAnt <> "02" //Nao executa esta regra para Ceramica Incesa 
	IF !EMPTY(M->C5_YCLVL)
		DbSelectArea("CTH")
		DbSetOrder(1)
		DbSeek(xFilial("CTH")+M->C5_YCLVL)
		IF CTH->CTH_BLOQ == '1'
			Alert("Esta Classe de Valor está bloqueada. Favor entrar em contato com o Setor Contabil.")
			lRet := .F.
			Return(lRet)
		ENDIF
	ENDIF
EndIf

IF M->C5_YSUBTP $ "R2/R3"
	IF ALLTRIM(M->C5_YPEDPAI) == ""
		MsgBox("Atenção, o campo Pedido Pai não foi preenchido. Favor verificar!","MTA410","STOP")
		Return(.F.)
	END IF
END IF

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Obriga digitacao dos campos Cliente/Loja Origem para vendas LM
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
If cEmpAnt $ ("01_05_14") .And. Alltrim(M->C5_CLIENTE) == "010064" .And. Alltrim(M->C5_TIPO) == "N" .And. (Empty(Alltrim(M->C5_YCLIORI)) .Or. Empty(Alltrim(M->C5_YLOJORI)))
	Msgbox("Vendas para empresa LM, é necessário informar os campos Cliente/Loja Origem!","MTA410","STOP")
	Return(.F.)
EndIf
If cEmpAnt $ ("01_05_14") .And. Alltrim(M->C5_CLIENTE) <> "010064" .And. Alltrim(M->C5_TIPO) == "N" .And. (!Empty(Alltrim(M->C5_YCLIORI)) .Or. !Empty(Alltrim(M->C5_YLOJORI)))
	Msgbox("Os campos Cliente/Loja Origem devem ser preenchidos apenas para vendas para a empresa LM!","MTA410","STOP")
	Return(.F.)
EndIf

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Obriga digitacao dos campos Cliente/Loja Origem ne Empresa Mundi
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
If cEmpAnt == "13" .And. Alltrim(M->C5_TIPO) == "N" .And. (Empty(Alltrim(M->C5_YCLIORI)) .Or. Empty(Alltrim(M->C5_YLOJORI)))
	Msgbox("Os campos Cliente/Loja Origem devem ser preenchidos!","MTA410","STOP")
	Return(.F.)
EndIf

lConta := .T.
//Valida a Digitacao do Item Contabil
IF SUBSTR(ALLTRIM(M->C5_YITEMCT),1,1) == 'I' .AND. EMPTY(M->C5_YSI)
	MsgBox("Favor informar o cliente para este Item Contábil","Atencao","ALERT")
	lRet := .F.
	Return(lRet)
ENDIF
lRet := U_fValItemCta(Alltrim(M->C5_YSUBTP),lConta,M->C5_YCLVL,M->C5_YITEMCT)

Return(lRet)

//------------------------------
User Function FlpQuatro()
	Alert("FlpQuatro")
Return

//------------------------------
User Function FlpCinco()
	Alert("FlpCinco")
Return

/*
Local oBrowse
 
oBrowse:= FWmBrowse():New()
oBrowse:SetAlias('SC5')
oBrowse:SetDescription('Teste MVC')
oBrowse:Activate()
 
Return nil

//----------------------------
Static Function MenuDef()
 
Local aRotina := {}
 
ADD OPTION aRotina Title 'Pesquisa'     Action 'PesqBrw'            OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'   Action 'VIEWDEF.BIA854'     OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Alterar'      Action 'VIEWDEF.BIA854'     OPERATION 4 ACCESS 0
 
Return aRotina

//---------------------------- 
Static Function ModelDef()
 
Local oStruC5 := FWFormStruct(1,'SC5')
Local oModel
 
oModel := MPFormModel():New('TES_001M')*/
 
//oModel:AddFields('SC5MASTER',/*cOwner*/,oStruC5)

/* 
oModel:SetPrimaryKey({'C5_FILIAL','C5_NUM','C5_EMISSAO','C5_TIPO','C5_TRANSP'})
 
oModel:SetDescription('Teste de MVC')
 
oModel:GetModel('SC5MASTER'):SetDescription('Testes de AdvPl e MVC')
 
Return oModel 

//----------------------------
Static Function ViewDef()
 
Local oModel := FWLoadModel('BIA854')
 
Local oStruC5:= FWFormStruct(2,'SC5')
 
Local oViewDef:=FWFormView():New()
 

oViewDef:SetModel(oModel)
 
oViewDef:AddField('VIEW_SC5',oStruC5,'SC5MASTER')
 
oViewDef:CreateHorixontalBox('TELA',100)
 
oViewDef:SetOwnerView('VIEW_SC5','TELA')
 
Return oViewDef*/
