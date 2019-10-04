//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'

/*/{Protheus.doc} zMkMVC
MarkBrow em MVC da tabela de Artistas
@author Atilio
@since 03/10/2019
@version 1.0
@obs Criar a coluna ZD6_OK com o tamanho 2 no Configurador e deixar como não usado
/*/

User Function PCPTEST2()
	
	Local aArea  := GetArea()
	Private oMark
	
	//Criando o MarkBrow
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('ZD6')
	
	//Setando semáforo, descrição e campo de mark
	//oMark:SetSemaphore(.T.)
	oMark:SetDescription('Seleção ')
	oMark:SetFieldMark( 'ZD6_OK' )
	
	//Setando Legenda
	oMark:AddLegend( " ZD6->ZD6_STATUS == ' '  "  , "GREEN", "Não processado" )
	oMark:AddLegend( " ZD6->ZD6_STATUS == '1' "  , "RED",	  "Já processado" )
	
	
	//Ativando a janela
	oMark:Activate()
	RestArea(aArea)

Return ()

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Facile - Filipe                                              |
 | Data:  03/10/2019                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
	Local aRotina := {}	
	//Criação das opções
	ADD OPTION aRotina TITLE 'Processar'  ACTION 'u_PListZD6'     OPERATION 2 ACCESS 0		
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_ZD6LEG'     OPERATION 9 ACCESS 0
Return aRotina

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Facile - Filipe                                              |
 | Data:  03/10/2019                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
Return FWLoadModel('zPCPTEST2')

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Facile - Filipe                                              |
 | Data:  03/10/2019                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
Return FWLoadView('zPCPTEST2')

/*/{Protheus.doc} PCPTEST2
Rotina para processamento e verificação de quantos registros estão marcados
@author Atilio
@since 03/10/2019
@version 1.0
/*/

User Function PListZD6()

	Local aArea    := GetArea()
	Local cMarca   := oMark:Mark()	 
	Local aListId  := {}
	Local cMens   := "Você selecionou a(s) OP(s): "
	Local nCt      := 0

	//Percorrendo os registros da ZD6
	ZD6->(DbGoTop())
	While !ZD6->(EoF())
		//Caso esteja marcado, aumenta o contador
		If oMark:IsMark(cMarca)
			nCt++
			cMens += "<b>"+cValTochar(ZD6->ZD6_OP_ID)+"</b> - "	
			AADD(aListId, {ZD6->ZD6_LISTID,ZD6->ZD6_OP_ID, ZD6->ZD6_CP_ID})	
			//Limpando a marca
			RecLock('ZD6', .F.)
				ZD6->ZD6_OK := ''
			ZD6->(MsUnlock())
		EndIf		
		//Pulando registro
		ZD6->(DbSkip())
	EndDo
	
	cMens += "  E será/serão processada(s). Tem certeza ?"

    If Len(aListId) > 0
		If MsgYesNo(cMens,"ATENÇÃO","YESNO")	
		    //aListId[1,1]		
			FWMsgRun(, {|| Salvar(aListId) }, "Aguarde!", " Processando sua requisição")
		Else
			MsgInfo('Nenhuma Lista foi processada', "Atenção")
		EndIf
	EndIf 

		
Return

User Function ZD6LEG()
	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",	"Não processado"  })
	AADD(aLegenda,{"BR_VERMELHO",	"Já processado"})
	
	BrwLegenda("Legenda", "Status", aLegenda)
Return


Static Function Salvar(aListId)
	
	MsgInfo('Lista recebida', "Atenção")
 
Return NIL


