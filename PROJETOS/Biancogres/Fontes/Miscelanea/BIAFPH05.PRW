#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"

User Function BIAFPH05()

	Local oBrowse		:= Nil	
	//Local aBkpaRot		:= aRotina
	Local cFunBkp		:= FunName()
	//aRotina 			:= {}
	
	Private cTitle		:= "Controle Horimetro dos Veiculos"
	
	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()
	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZLI") 
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
	ADD OPTION aRot TITLE "Visualizar" 					ACTION "VIEWDEF.BIAFPH05" 		OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE "Incluir"    					ACTION "VIEWDEF.BIAFPH05" 		OPERATION 3 ACCESS 0
	ADD OPTION aRot TITLE "Alterar"						ACTION "VIEWDEF.BIAFPH05" 		OPERATION 4 ACCESS 0
	ADD OPTION aRot TITLE "Excluir"    					ACTION "VIEWDEF.BIAFPH05"		OPERATION 5 ACCESS 0
	ADD OPTION aRot TITLE "Relatório"    				ACTION "U_BIAFPH06"				OPERATION 7 ACCESS 0
Return aRot


Static Function ModelDef()
	
	Local oModel	:= Nil
	
	Local oStr1	:= FWFormStruct( 1, 'ZLI', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados FWFORMMODELSTRUCT():New()
	
	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("ZLIMODEL", { |oModel| MVCPREVALID(oModel) } , {|oModel| MVCTUDOOK(oModel) } , {|oModel| MVCCOMMIT(oModel) } , /*bCancel*/ )
	oModel:SetDescription(cTitle)
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('MASTER',,oStr1, {|oModel| MVC001T(oModel)},,)
	
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZLI_MATRIC', 'ZLI_TAG', 'ZLI_DTCOL'})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('MASTER'):SetDescription('Cabecalho')
		
Return oModel


Static Function ViewDef()
	
	Local oView		:= Nil
	Local oModel	:= ModelDef()
	
	Local oStr1		:= FWFormStruct(2, 'ZLI')
	
	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('Formulario' , oStr1, 'MASTER')
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'MASTER', 100)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','MASTER')

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
	
	Local oMaster 	:= oModel:GetModel('MASTER')
	Local nOper			:= oModel:GetOperation() 
	Local cChave		:= ""
	Local cMat 			:= ""
	Local cTag 			:= ""
	Local cData 		:= ""
	
	Local cAliasTrab	:= Nil
	Local cQuery		:= ""	
	Local nUltCont		:= 0
	Local nMinUltCont	:= 0
	Local nAutCont		:= 0
	
	If (nOper == 3 .Or. nOper == 4)
		
		cChave := xFilial("ZLI")
		cChave += oMaster:GetValue("ZLI_MATRIC")
		cChave += oMaster:GetValue("ZLI_TAG")
		cChave += dtos(oMaster:GetValue("ZLI_DTCOL"))
	
		DbSelectArea('ZLI')
		ZLI->(DbSetOrder(1))
		
		cMat 	:= oMaster:GetValue("ZLI_MATRIC")
		cTag	:= oMaster:GetValue("ZLI_TAG")
		cData	:= cValToChar(oMaster:GetValue("ZLI_DTCOL"))
		
		
		If ZLI->(DbSeek(cChave))
			
			If (nOper == 3) 
				MsgInfo("Já existe um registro cadastro com chave informada (Matricula, Tag, Data): ("+cMat+", "+cTag+", "+cData+") .","Controle Horimetro dos Veiculos")
				
				Return .F.
			Else
				
				If (ZLI->(RECNO()) != M->(RECNO()))
					
					MsgInfo("Já existe um registro cadastro com chave informada (Matricula, Tag, Data): ("+cMat+", "+cTag+", "+cData+") .","Controle Horimetro dos Veiculos")
				
					Return .F.
				
				EndIf 
			
			EndIf	
			
		EndIf
		
		nAutCont	:= oMaster:GetValue("ZLI_CONTAD")
		cData 		:= dtos(oMaster:GetValue("ZLI_DTCOL"))
		
		cQuery := " SELECT ZLI_CONTAD=MAX(ZLI_CONTAD)								"
		cQuery += "   FROM " + RetSqlName("ZLI")    	        	    			"
		cQuery += "  WHERE ZLI_FILIAL	= '"+xFilial("ZLI")+"'       				"
		cQuery += "    AND ZLI_TAG 		= '"+cTag+"'                				"
		cQuery += "    AND ZLI_DTCOL 	< '"+cData+"'								"
		cQuery += "    AND D_E_L_E_T_ 	= ''      	                  				"
		cQuery += "    AND R_E_C_N_O_ 	<> '"+cValtoChar(M->(RECNO()))+"'			"	
		cQuery += "    GROUP BY ZLI_TAG												"
		
			
		cAliasTrab := GetNextAlias()
		TCQUERY cQuery ALIAS (cAliasTrab) NEW
		
		If !(cAliasTrab)->(EOF())
			nUltCont := (cAliasTrab)->ZLI_CONTAD
			If (nAutCont <= nUltCont)
				MsgInfo("O Contador da Tag: "+cTag+" deve maior que o ultimo: "+cvalTochar(nUltCont)+" .","Controle Horimetro dos Veiculos")
				Return .F.
			EndIf
		EndIf
		(cAliasTrab)->(dbCloseArea())
		
		
		cQuery := " SELECT ZLI_CONTAD=MIN(ZLI_CONTAD)								"
		cQuery += "   FROM " + RetSqlName("ZLI")    	        	    			"
		cQuery += "  WHERE ZLI_FILIAL	= '"+xFilial("ZLI")+"'       				"
		cQuery += "    AND ZLI_TAG 		= '"+cTag+"'                				"
		cQuery += "    AND ZLI_DTCOL 	> '"+cData+"'								"
		cQuery += "    AND D_E_L_E_T_ 	= ''      	                  				"
		cQuery += "    AND R_E_C_N_O_ 	<> '"+cValtoChar(M->(RECNO()))+"'			"	
		cQuery += "    GROUP BY ZLI_TAG												"
		
			
		cAliasTrab := GetNextAlias()
		TCQUERY cQuery ALIAS (cAliasTrab) NEW
		
		If !(cAliasTrab)->(EOF())
			nUltCont := (cAliasTrab)->ZLI_CONTAD
			If (nAutCont >= nUltCont)
				MsgInfo("O Contador da Tag: "+cTag+" deve menor que o ultimo superior: "+cvalTochar(nUltCont)+" .","Controle Horimetro dos Veiculos")
				Return .F.
			EndIf
		EndIf
		(cAliasTrab)->(dbCloseArea())
		
		
	EndIf
		
			
Return .T.

//-------------------------------------------------------------------
// Gravacao de Dados
//-------------------------------------------------------------------
Static Function MVCCOMMIT(oModel)
	
	Processa( {|| fProcCommit(oModel) },"Aguarde...","Atualizando Registros...")
        
Return .T.


Static Function fProcCommit( oModel )
	
	Local aArea 		:= GetArea()
	Local oMaster		:= oModel:GetModel('MASTER')
	Local nOper			:= oModel:GetOperation() 
	Local cChave		:= ""

	//DELETE
	If ( nOper == 5 )

		cChave := xFilial("ZLI")
		cChave += oMaster:GetValue("ZLI_MATRIC")
		cChave += oMaster:GetValue("ZLI_TAG")
		cChave += dtos(oMaster:GetValue("ZLI_DTCOL"))
		
		DbSelectArea('ZLI')
		ZLI->(DbSetOrder(1))
		
		If ZLI->(DbSeek(cChave))
			RecLock("ZLI",.F.)
				ZLI->(DbDelete())
			ZLI->(MsUnlock())	
		EndIf
			
	ElseIf ( nOper == 3 .Or. nOper == 4)
		
		DbSelectArea('ZLI')
		ZLI->(DbSetOrder(1))
		
		cChave := XFilial("ZLI")
		cChave += oMaster:GetValue("ZLI_MATRIC")
		cChave += oMaster:GetValue("ZLI_TAG")
		cChave += dtos(oMaster:GetValue("ZLI_DTCOL"))
			
			
		If ZLI->(DbSeek(cChave))
			RecLock("ZLI",.F.)
		Else                  
			RecLock("ZLI",.T.)
		EndIf
		
		//ZLI_MATRIC, ZLI_TAG, ZLI_DTCOL, ZLI_DATA, ZLI_SETOR, ZLI_KMH, ZLI_CONTAD, ZLI_UNIDAD
		
				
		ZLI->ZLI_MATRIC	:= oMaster:GetValue("ZLI_MATRIC")
		ZLI->ZLI_TAG  	:= oMaster:GetValue("ZLI_TAG")  
		ZLI->ZLI_DTCOL 	:= oMaster:GetValue("ZLI_DTCOL") 
		ZLI->ZLI_DATA	:= oMaster:GetValue("ZLI_DATA")  
		ZLI->ZLI_SETOR 	:= oMaster:GetValue("ZLI_SETOR")  
		ZLI->ZLI_KMH 	:= oMaster:GetValue("ZLI_KMH")  
		ZLI->ZLI_CONTAD := oMaster:GetValue("ZLI_CONTAD")  	
		ZLI->ZLI_UNIDAD	:= oMaster:GetValue("ZLI_UNIDAD")
		
		ZLI->(MsUnlock())	
	
	EndIf
				
	RestArea(aArea)
Return(.T.)

User Function ZLIMODEL()

	Local aParam     	:= PARAMIXB
	Local xRet       	:= .T.
	Local oObj       	:= aParam[1] // este é o model carregado
	Local cIdPonto   	:= aParam[2] //Conjunto de string que identifica o momento que a rotina esta sendo chamada.
	Local cIdModel   	:= IIf( oObj<> NIL, oObj:GetId()		, aParam[3] )
	Local cClasse    	:= IIf( oObj<> NIL, oObj:ClassName()	, '' )

	Local oModelMaster	:= oObj:GetModel( 'MASTER' )

	If cIdPonto ==  'MODELCOMMITTTS'

	ElseIf cIdPonto ==  'FORMLINEPRE'

	ElseIf cIdPonto ==  'MODELPRE'

	ElseIf cIdPonto ==  'FORMPRE'

	ElseIf cIdPonto ==  'MODELVLDACTIVE'

	ElseIf cIdPonto ==  'BUTTONBAR'

	
	EndIf

Return xRet
