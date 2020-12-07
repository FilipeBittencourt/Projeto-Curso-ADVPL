#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"

User Function BACP0004()

	Local oBrowse		:= Nil	
	//Local aBkpaRot		:= aRotina
	Local cFunBkp		:= FunName()
	//aRotina 			:= {}
	
	Private cTitle		:= "Cadastro de Regras de Bloqueio"
	
	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()
	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZKI") 
	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cTitle)

	//Desliga a exibição dos detalhes
	oBrowse:DisableDetails()         

	//Ativamos a classe
	oBrowse:Activate()
	
	//aRotina := aBkpaRot
	SetFunName(cFunBkp)
Return


Static Function MenuDef()
	Local aRot := {}
	ADD OPTION aRot TITLE "Pesquisar"  					ACTION 'PesqBrw' 				OPERATION 1 ACCESS 0
	ADD OPTION aRot TITLE "Visualizar" 					ACTION "VIEWDEF.BACP0004" 		OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE "Incluir"    					ACTION "VIEWDEF.BACP0004" 		OPERATION 3 ACCESS 0
	ADD OPTION aRot TITLE "Alterar"						ACTION "VIEWDEF.BACP0004" 		OPERATION 4 ACCESS 0
	ADD OPTION aRot TITLE "Excluir"    					ACTION "VIEWDEF.BACP0004"		OPERATION 5 ACCESS 0
	ADD OPTION aRot TITLE "Aprovadores Temporários" 	ACTION "U_BACP0019"				OPERATION 6 ACCESS 0
Return aRot


User Function BACP00A4()

	Local aItems		:= {}
    Local cQuery		:= ""
    Local cAliasTemp	:= Nil
    Local cDescricao	:= ""
    Local cCodRegra		:= ""
    Local cTipo			:= ""

    If (!Empty(ZKI->ZKI_CODIGO))
    	
    	cCodRegra	:= ZKI->ZKI_CODIGO
    	cTipo 		:= ZKI->ZKI_TIPO
    	
    	
    	cAliasTemp	:= GetNextAlias()
		cQuery = " SELECT * FROM "+ RetSQLName("ZKI") + " ZKI 													"
		cQuery += " INNER JOIN "+ RetSQLName("ZKK") + " ZKK ON ZKI_CODIGO = ZKK_CODZKI AND ZKK.D_E_L_E_T_ = ''	"
		cQuery += " WHERE 																						"
		cQuery += " ZKI.D_E_L_E_T_		= ''																	"	
		cQuery += " AND ZKI.ZKI_CODIGO		= "+ZKI->ZKI_CODIGO+"												"	
		
		TcQuery cQuery New Alias (cAliasTemp)
	
		While !(cAliasTemp)->(Eof())
			
			If (AllTrim((cAliasTemp)->ZKI_TIPO) <> 'A')
				cDescricao := (cAliasTemp)->ZKK_CODIGO+"="+cvaltochar((cAliasTemp)->ZKK_VALIN)+" até "+cvaltochar((cAliasTemp)->ZKK_VALFI)
			EndIf
			
			Aadd(aItems, cDescricao)
			(cAliasTemp)->(DbSkip())
	
		EndDo()
		
	    (cAliasTemp)->(DbCloseArea())
	    
	    If (Len(aItems) > 1)//caso existir mais de 1 e porque do tipo regra D/M
	    
	    	DEFINE DIALOG oDlg TITLE "Seleção de Faixa" FROM 180,180 TO 280, 600 PIXEL
	    	
	    		oSay	:= TSay():New(2,2,{|| 'Faixa'},oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE, 200, 20)
	    	
	    		cCombo1	:= aItems[1]
	    		oCombo1	:= TComboBox():New(10, 02,{|u| If(PCount() >0, cCombo1:=u, cCombo1)}, aItems, 210, 20, oDlg,,{||} ,,,,.T.,,,,,,,,,'cCombo1')
	    	
	    		oTButton1 := TButton():New(35, 170, "OK",oDlg,{|| oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	    	
	    	ACTIVATE DIALOG oDlg CENTERED
	    	
	    	cCodRegra := cCombo1
	    	
	    EndIf	
	    
	    U_BACP0005(cCodRegra, cTipo)
	    
	    
    EndIf
            

Return


Static Function ModelDef()
	
	Local oModel	:= Nil
	
	Local oStr1	:= FWFormStruct( 1, 'ZKI', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados FWFORMMODELSTRUCT():New()
	Local oStr2	:= FWFormStruct( 1, 'ZKK', /*bAvalCampo*/,/*lViewUsado*/ )
	
	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("ZKIMODEL", { |oModel| MVCPREVALID(oModel) } , {|oModel| MVCTUDOOK(oModel) } , {|oModel| MVCCOMMIT(oModel) } , /*bCancel*/ )
	oModel:SetDescription(cTitle)
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('MASTER',,oStr1, {|oModel| MVC001T(oModel)},,)
	
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZKI_CODIGO'})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('MASTER'):SetDescription('Cabecalho')

	//ESTRUTURA DE DADOS DO GRID
	oStr2:RemoveField("ZKK_CODZKI")
	oModel:AddGrid('DETAIL','MASTER', oStr2,/*bLinePre*/, /*bLinePost*/,{|oModel| GridPre(oModel)}/*bPre - Grid Inteiro*/,{|oModel| GridPost(oModel)}/*bPos - Grid Inteiro*/,{|x| LoadZKK(x)})  //cOwner é para quem pertence
	
	oModel:getModel('DETAIL'):SetDescription('Detalhes')
		
Return oModel


Static Function ViewDef()
	
	Local oView		:= Nil
	Local oModel	:= ModelDef()
	
	Local oStr1		:= FWFormStruct(2, 'ZKI')
	Local oStr2		:= FWFormStruct(2, 'ZKK')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('Formulario' , oStr1, 'MASTER')
	
	
	oStr2:RemoveField("ZKK_CODZKI")
	oView:AddGrid('Detalhe', oStr2, 'DETAIL')
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'MASTER', 40)
	oView:CreateHorizontalBox( 'DETAIL', 60)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','MASTER')
	oView:SetOwnerView('Detalhe','DETAIL')

	oView:EnableTitleView('Formulario' , cTitle )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
Return oView



Static Function GridPost(oModel)

Return .T.

Static Function GridPre(oModel)

Return .T.


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
	
	Local oDetail 	:= oModel:GetModel('DETAIL')
			
Return .T.

//-------------------------------------------------------------------
// Gravacao de Dados
//-------------------------------------------------------------------
Static Function MVCCOMMIT(oModel)
	
	Processa( {|| fProcCommit(oModel) },"Aguarde...","Atualizando Registros...")
        
Return .T.


Static Function fProcCommit( oModel, cAno )
	
	Local aArea 		:= GetArea()
	Local oMaster		:= oModel:GetModel('MASTER')
	Local oDetail 		:= oModel:GetModel('DETAIL')
	Local nOper			:= oModel:GetOperation() 
	Local nI			:= 0

	BEGIN TRANSACTION
		
		//DELETE
		If ( nOper == 5 )
	
			DelZKI(oMaster)
			Return(.T.)	
			
		EndIf
		
		If ( nOper == 3 .Or. nOper == 4)
			
			DbSelectArea('ZKI')
			ZKI->(DbSetOrder(1))
			If ZKI->(DbSeek(XFilial("ZKI")+oMaster:GetValue("ZKI_CODIGO")))
				RecLock("ZKI",.F.)
			Else                  
				RecLock("ZKI",.T.)
			EndIf
			
			If (nOper == 3)
				ConfirmSX8()
			EndIf
					
			ZKI->ZKI_CODIGO	:= oMaster:GetValue("ZKI_CODIGO")
			ZKI->ZKI_TIPO  	:= oMaster:GetValue("ZKI_TIPO")  
			ZKI->ZKI_MARCA 	:= oMaster:GetValue("ZKI_MARCA") 
			ZKI->ZKI_REGRA	:= oMaster:GetValue("ZKI_REGRA")  
			ZKI->ZKI_DESC 	:= oMaster:GetValue("ZKI_DESC")  
			ZKI->ZKI_TPBLQ 	:= oMaster:GetValue("ZKI_TPBLQ")  
			ZKI->ZKI_DESBLQ := oMaster:GetValue("ZKI_DESBLQ")  	
			ZKI->ZKI_ORDEM	:= oMaster:GetValue("ZKI_ORDEM")
			ZKI->ZKI_PRIORI	:= oMaster:GetValue("ZKI_PRIORI")  
			
			ZKI->(MsUnlock())	
			
			For nI := 1 To oDetail:Length()
				
				oDetail:GoLine(nI)
				
				nValorIni	:= oDetail:GetValue("ZKK_VALIN", 	nI)
				nValorFin	:= oDetail:GetValue("ZKK_VALFI", 	nI)
				cCodigo		:= oDetail:GetValue("ZKK_CODIGO", 	nI)
				
				If !oDetail:IsDeleted()
					
					If (AllTrim(oMaster:GetValue("ZKI_TIPO")) <> 'A')
						
						DbSelectArea('ZKK')
						ZKK->(DbSetOrder(1))
					
						If (!Empty(cCodigo) .And. ZKK->(DbSeek(xFilial('ZKK')+cCodigo)) )
							
							Reclock("ZKK", .F.)
								ZKK->ZKK_VALIN	:= nValorIni
								ZKK->ZKK_VALFI	:= nValorFin
							ZKK->(MsUnlock())
						
						Else
							
							Reclock("ZKK", .T.)
								ZKK->ZKK_CODIGO	:= GETSX8NUM("ZKK","ZKK_CODIGO")
								ZKK->ZKK_VALIN	:= nValorIni
								ZKK->ZKK_VALFI	:= nValorFin
								ZKK->ZKK_CODZKI	:= oMaster:GetValue("ZKI_CODIGO")
							ZKK->(MsUnlock())
							
							ConfirmSX8()
						EndIf
					
					EndIf
					
				Else
					
					DbSelectArea('ZKK')
					ZKK->(DbSetOrder(1))
					
					If (!Empty(cCodigo) .And. ZKK->(DbSeek(xFilial('ZKK')+cCodigo)))
						
						Reclock("ZKK", .F.)
							ZKK->(dbDelete())
						ZKK->(MsUnlock())
					EndIf
					
					
				EndIf
				
				
			Next nI		
			
		
		EndIf
				
		
	END TRANSACTION

	RestArea(aArea)
Return(.T.)


Static Function DelZKI(oMaster)
	
	Local cCodZKI:= oMaster:GetValue("ZKI_CODIGO")
	
	DbSelectArea('ZKI')
	ZKI->(DbSetOrder(1))
	
	If ZKI->(DbSeek(XFilial("ZKI")+cCodZKI))
		
		RecLock("ZKI",.F.)
			ZKI->(DbDelete())
		ZKI->(MsUnlock())	
		
		//deleta aprovadores 
		DbSelectArea('ZKJ')
		ZKJ->(DbSetOrder(2))
		
		If(ZKJ->(DbSeek(xFilial('ZKJ')+cCodZKI)))
		
			While(!ZKJ->(Eof()) .And. ZKJ->ZKJ_CODZKI == cCodZKI)
				
				RecLock("ZKJ",.F.)
					ZKK->(DbDelete())
				ZKJ->(MsUnlock())	
			
				ZKJ->(DbSkip())
			EndDo
		
		EndIf
		
		//Deleta margens
		DbSelectArea('ZKK')
		ZKK->(DbSetOrder(2))
		
		If(ZKK->(DbSeek(xFilial('ZKK')+cCodZKI)))
		
			While(!ZKK->(Eof()) .And. ZKK->ZKK_CODZKI == cCodZKI)
			
				//deleta aprovadores 
				DbSelectArea('ZKJ')
				ZKJ->(DbSetOrder(3))
				
				If(ZKJ->(DbSeek(xFilial('ZKJ')+ZKK->ZKK_CODIGO)))
				
					While(!ZKJ->(Eof()) .And. ZKJ->ZKJ_CODZKK == ZKK->ZKK_CODIGO)
						
						RecLock("ZKJ",.F.)
							ZKK->(DbDelete())
						ZKJ->(MsUnlock())	
					
						ZKJ->(DbSkip())
					EndDo
				
				EndIf
				
				
				RecLock("ZKK",.F.)
					ZKK->(DbDelete())
				ZKK->(MsUnlock())	
		
				ZKK->(DbSkip())
			
			EndDo
		
		EndIf
		
		
	EndIf

	
Return

Static Function LoadZKK(oModel)
	Local aGridIni := {}
	
	U_BIAMsgRun("Aguarde... Carregando registros...",, {|| aGridIni := fProcLoadZKK(oModel) })

Return aGridIni



Static Function fProcLoadZKK(oModel)

	Local aArea			:= GetArea()
	Local aDados 		:= {}
	Local aLinha		:= {}
	
	DbSelectArea('ZKK')
	ZKK->(DbSetOrder(2))
	
	If (ZKK->(DbSeek(xFilial('ZKK')+ZKI->ZKI_CODIGO)))
		
		While(!ZKK->(Eof()) .And. ZKK->ZKK_CODZKI == ZKI->ZKI_CODIGO)
			
			aLinha := {"", "", 0, 0}
			
			aLinha[2]	:= ZKK->ZKK_CODIGO
			aLinha[3]	:= ZKK->ZKK_VALIN
			aLinha[4]	:= ZKK->ZKK_VALFI
			
			Aadd(aDados, {0, aLinha})
	
			ZKK->(DbSkip())
		EndDo
		
	EndIf
	
	RestArea(aArea)
	
Return(aDados)

Static Function LoadTelaAprov(oModel)

	Local oMaster	:= oModel:GetModel('MASTER')
	Local oDetail 	:= oModel:GetModel('DETAIL')
	Local nOper		:= oModel:GetOperation() 
	
	Local cTipo 	:= oMaster:GetValue("ZKI_TIPO")
	Local cCodigo 	:= ""
	Local nLine		:= 0
	
	If (nOper == 4)
	
		If (AllTrim(cTipo) == 'A')
	
			cCodigo := oMaster:GetValue("ZKI_CODIGO")
			
			If (!Empty(cCodigo))
				U_BACP0005(cCodigo, cTipo)
			Else
				Alert("Código Regra não preenchido.")
			EndIf
			
		Else
			
			If (oDetail:Length() > 0)
				
				nLine := oDetail:GetLine()
				
				If (nLine > 0 )
					
					oDetail:GoLine(nLine)
					cCodigo := oDetail:GetValue("ZKK_CODIGO", nLine)
					
					If (!Empty(cCodigo))
						U_BACP0005(cCodigo, cTipo)
					Else
						Alert("Código Margem não preenchido.")
					EndIf
					
				Else
					Alert("Favor selecionar um registro no grid para visualizar/edição os aprovadores.")
				EndIf
				
			EndIf
			
		EndIf
	
	EndIf
	
Return


User Function ZKIMODEL()

	Local aParam     	:= PARAMIXB
	Local xRet       	:= .T.
	Local oObj       	:= aParam[1] // este é o model carregado
	Local cIdPonto   	:= aParam[2] //Conjunto de string que identifica o momento que a rotina esta sendo chamada.
	Local cIdModel   	:= IIf( oObj<> NIL, oObj:GetId()		, aParam[3] )
	Local cClasse    	:= IIf( oObj<> NIL, oObj:ClassName()	, '' )

	Local oModelMaster	:= oObj:GetModel( 'MASTER' )
	Local oModelDetail	:= oObj:GetModel( 'DETAIL' )


	If cIdPonto ==  'MODELCOMMITTTS'

	ElseIf cIdPonto ==  'FORMLINEPRE'

	ElseIf cIdPonto ==  'MODELPRE'

	ElseIf cIdPonto ==  'FORMPRE'

	ElseIf cIdPonto ==  'MODELVLDACTIVE'

	ElseIf cIdPonto ==  'BUTTONBAR'

		xRet := { {'Aprovadores', 'APROVREGRA', { || LoadTelaAprov(oObj) }, 'Aprovadores' } }

	EndIf

Return xRet
