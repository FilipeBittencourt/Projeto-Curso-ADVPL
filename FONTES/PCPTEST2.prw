//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include "topconn.ch"
//Constantes
#Define STR_PULA	Chr(13)+Chr(10)

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
	oMark:SetDescription('Seleção das OPs para criação do Pedido de Compra')
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
	ADD OPTION aRotina TITLE 'Processar'       ACTION   'u_PListZD6'     OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Desmarc. Todos'  ACTION   'u_DMarkZD6'     OPERATION 2 ACCESS 0		
	ADD OPTION aRotina TITLE 'Excluir'         ACTION   'u_DListZD6'     OPERATION 5 ACCESS 0	
	ADD OPTION aRotina TITLE 'Legenda'         ACTION   'u_ZD6LEG'       OPERATION 9 ACCESS 0
	
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
	Local cMens   := "Você selecionou a(s) OP(s): " + STR_PULA+STR_PULA
	Local nCt      := 0
	//Local aDados  := ModZD601()


	//Percorrendo os registros da ZD6
	ZD6->(DbGoTop())
	While !ZD6->(EoF())
		//Caso esteja marcado, aumenta o contador
		If oMark:IsMark(cMarca)
			nCt++
			cMens += "<b>"+cValTochar(ZD6->ZD6_OP_ID)+"</b> " +STR_PULA
			AADD(aListId, ZD6->ZD6_OP_ID)	
			//Limpando a marca
			RecLock('ZD6', .F.)
				ZD6->ZD6_OK := ''
			ZD6->(MsUnlock())
		EndIf		
		//Pulando registro
		ZD6->(DbSkip())
	EndDo
	
	cMens +=  STR_PULA	+"  E será/serão processada(s). Tem certeza ?"

    If Len(aListId) > 0
		If ValidRep(aListId)
			If MsgYesNo(cMens,"ATENÇÃO","YESNO")	
				//aListId[1,1]		
				FWMsgRun(, {|| Salvar(aListId) }, "Aguarde!", " Processando sua requisição")
				oMark:oBrowse:Refresh()
				oMark:oBrowse:Refresh(.T.)
			Else
				MsgInfo('Nenhuma OP foi processada', "Atenção")
			EndIf
		EndIf
	Else
		MsgInfo('Selecione uma OP que não foi processada.', "Atenção")
	EndIf 

Return


User Function DListZD6()

	Local aArea    := GetArea()
	Local cMarca   := oMark:Mark()	 
	Local aListOP  := {} 
	Local aListID  := {} 
	Local lContro := .T. 
	Local nI  := 1
	Local cQuery := ""
	Local cINQuery := ""	
	Local cMens   := "Você selecionou a(s) OP(s): " + STR_PULA+STR_PULA
	 

	//Percorrendo os registros da ZD6
	ZD6->(DbGoTop())
	While !ZD6->(EoF())
		//Caso esteja marcado, aumenta o contador
		If oMark:IsMark(cMarca)
			cMens += "<b>"+cValTochar(ZD6->ZD6_OP_ID)+"</b> " +STR_PULA	
			if !Empty(ZD6->ZD6_STATUS)
				lContro := .F.
			EndIf
			AADD(aListOP, ZD6->ZD6_OP_ID)
			AADD(aListID, ZD6->ZD6_LISTID)	
								
		EndIf		
		//Pulando registro
		ZD6->(DbSkip())
	EndDo
	
	cMens +=  STR_PULA	+"  E será/serão <b> DELETADA(S) </b>. Tem certeza ? "

    If Len(aListOP) > 0 .AND. lContro

		For nI := 1 To Len(aListID)
			cINQuery += aListID[nI]+","
		Next nI

		cQuery += " SELECT count(ZD6_LISTID) as NumListID  "
		cQuery += " FROM "+RetSQLName("ZD6")+""  
		cQuery += " WHERE ZD6_FILIAL = "+ ValToSql(FWxFilial('ZD6'))
		cQuery += " AND D_E_L_E_T_ = '' "	 
		cQuery += " AND ZD6_LISTID IN " + FormatIn(cINQuery,",") + " "

		
		TcQuery cQuery new alias "ZD6F"
		If ZD6F->NumListID > Len(aListOP)
			MsgInfo('Por favor, selecione todas as OPs da lista para prosseguir.', "Atenção")
			ZD6F->(dbCloseArea())
			Return .F.
		EndIf
		ZD6F->(dbCloseArea())

	 
		If MsgYesNo(cMens,"ATENÇÃO","YESNO")		
		
			ZD6->(DbSetOrder(2))  // ZD6_FILIAL, ZD6_OP_ID, R_E_C_N_O_, D_E_L_E_T_
			for nI := 1 to Len(aListOP)	
				if ZD6->(DbSeek(FWxFilial('ZD6')+AllTrim(aListOP[nI])))
					
					If Empty(ZD6->ZD6_STATUS)
						RecLock( "ZD6", .F.)
							ZD6->(dbdelete())
						ZD6->(MsUnLock())					 
					EndIf	

				EndIf
			Next nI
			FwAlertSuccess('Requisição concluída com sucesso.')
			oMark:oBrowse:Refresh()
			oMark:oBrowse:Refresh(.T.)
		Else
			MsgInfo('Nenhuma OP foi processada', "Atenção")
		EndIf	 
	Else
		MsgInfo('Selecione somente as OPs que não foram processadas', "Atenção")
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
	
	Local aArea  := GetArea()
	Local aCab   := {}
	Local aItem  := {}	 
	Local aOPCad   := {}
	Local aNumItem := {}
	Local cQuery   := ""
	Local cNumPC := ""
	Local cINQuery := ""
	Local nI     := 1
    Local nOpc      := 3 //inclusao   1 - C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_

	Private lMsErroAuto := .F.

	

		For nI := 1 To Len(aListId)
			cINQuery += aListId[nI]+","
		Next nI 

		cQuery := " SELECT DISTINCT   "+STR_PULA
		cQuery += "  SC2.C2_NUM + C2_ITEM + C2_SEQUEN AS OP   "+STR_PULA
		cQuery += " ,SB1.B1_COD as B1COD   "+STR_PULA	
		cQuery += " ,SB1.B1_DESC as B1DESC  "+STR_PULA 
		cQuery += " ,SC2.C2_QUANT as C2QUANT "+STR_PULA   	
		cQuery += " ,SB1.B1_PESO as B1PESO   "+STR_PULA
		cQuery += " ,SB1.B1_UM as B1UM   "+STR_PULA
		cQuery += " ,SB1.B1_CONTA as B1CONTA   "+STR_PULA
		cQuery += " ,SB1.B1_CC as B1CC   "+STR_PULA
		cQuery += " ,(SC2.C2_QUANT * SB1.B1_PESO) TOTAL_OP"+STR_PULA   
		cQuery += " ,SC2.C2_YPRJODM AS PRJODM   "+STR_PULA
		cQuery += " ,ZD6.ZD6_CP_ID "+STR_PULA
		cQuery += " ,SC3.C3_NUM AS C3NUM "+STR_PULA
		cQuery += " ,SC3.C3_PRODUTO AS  C3PRODUTO "+STR_PULA
		cQuery += " ,(SELECT B1_DESC FROM  SB1010 WHERE B1_COD = SC3.C3_PRODUTO) AS C3PRODDESC "+STR_PULA
		cQuery += " ,SC3.C3_FORNECE   AS C3FORNECE "+STR_PULA
		cQuery += " ,SC3.C3_LOJA AS C3LOJA "+STR_PULA
		cQuery += " ,SC3.C3_PRECO AS C3PRECO "+STR_PULA
		cQuery += " ,SC3.C3_COND AS C3COND "+STR_PULA 
        cQuery += " ,SC3.C3_CC AS C3CC "+STR_PULA
		cQuery += " ,SC3.C3_OBS AS C3OBS "+STR_PULA
		cQuery += " ,SC3.C3_CONTATO AS C3CONTATO "+STR_PULA
		
		cQuery += " FROM "+RetSQLName("ZD6")+" ZD6 (NOLOCK)   "+STR_PULA
		cQuery += "  	INNER JOIN "+RetSQLName("SC3")+" SC3  (NOLOCK) ON SC3.C3_NUM = ZD6.ZD6_CP_ID  AND SC3.D_E_L_E_T_ = '' AND SC3.C3_FILIAL =  '"+FWxFilial('SC3')+"' " +STR_PULA
		cQuery += "  	INNER JOIN "+RetSQLName("SC2")+" SC2  (NOLOCK) ON ZD6.ZD6_OP_ID  = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN  AND ZD6.D_E_L_E_T_ = ''  AND ZD6.ZD6_FILIAL = '"+FWxFilial('SC3')+"'   "+STR_PULA
		cQuery += " 	INNER JOIN "+RetSQLName("SB1")+" SB1  (NOLOCK) ON SB1.B1_COD  = SC2.C2_PRODUTO AND   SB1.D_E_L_E_T_ = '' "+STR_PULA	

		cQuery += " WHERE SC2.D_E_L_E_T_ = ''  "+STR_PULA
		cQuery += " AND ZD6.ZD6_OP_ID IN " + FormatIn(cINQuery,",")+STR_PULA
		cQuery += " AND SC2.C2_DATRF = ''   "+STR_PULA
		cQuery += " AND ZD6.ZD6_FILIAL =  '"+FWxFilial('ZD6')+"'  "+STR_PULA
		cQuery += " AND ZD6.D_E_L_E_T_ =  '' " +STR_PULA
		cQuery += " ORDER BY OP DESC   " 
		

		TcQuery cQuery new alias "ZD6PZ"  
	
		ZD6PZ->(DBGotop()) 

		cNumPC := GetNumSC7() //GetSXENum("SC7","C7_NUM")

			aAdd( aCab,	{"C7_FILIAL"    ,FWxFilial('ZD6'), NIL} )		
			aAdd( aCab,	{"C7_NUM"       ,cNumPC ,   Nil } ) // Numero do Pedido				
			aAdd( aCab,	{"C7_EMISSAO"   ,dDataBase, NIL } ) // Data de Emissao
			aAdd( aCab,	{"C7_FORNECE"   ,ZD6PZ->C3FORNECE,NIL} ) // Fornecedor
			aAdd( aCab,	{"C7_LOJA"      ,ZD6PZ->C3LOJA,NIL} ) // Loja do Fornecedor
			aAdd( aCab,	{"C7_CONTATO"	,ZD6PZ->C3CONTATO ,NIL})			// Contato
			aAdd( aCab,	{"C7_COND"      ,ZD6PZ->C3COND ,NIL} ) // Condicao de Pagamento  - 001	- A VISTA    			  
			aAdd( aCab,	{"C7_FILENT"    ,FWxFilial('ZD6'),NIL} ) // Filial de Entrega
			aAdd( aCab,	{"C7_FILCEN"    ,FWxFilial('ZD6'),NIL} ) // Filial de Entrega
			aAdd( aCab,	{"C7_FRETE"	    ,CriaVar("C7_FRETE",.F.)		,NIL})    		//Frete
			aAdd( aCab,	{"C7_DESPESA"	,CriaVar("C7_DESPESA",.F.)		,NIL})		//Despesa
			aAdd( aCab,	{"C7_SEGURO"	,CriaVar("C7_SEGURO",.F.)		,NIL}) 		//Seguro
			aAdd( aCab,	{"C7_MSG"		,CriaVar("C7_MSG",.F.)			,NIL})        	//Mensagem
			aAdd( aCab,	{"C7_REAJUST"	,CriaVar("C7_REAJUST",.F.)		,NIL}) 			//Reajuste
		nI := 1
		
		Begin Transaction

			While !ZD6PZ->(EOF()) //Enquando não for fim de arquivo

				aAdd( aItem, {"C7_ITEM"     ,StrZero(nI, 4),NIL} )
				aAdd( aItem, {"C7_PRODUTO"  ,AllTrim(ZD6PZ->C3PRODUTO),NIL } )		
				aAdd( aItem, {"C7_QUANT"    ,ZD6PZ->TOTAL_OP,NIL } )
				aAdd( aItem, {"C7_PRECO"    ,ZD6PZ->C3PRECO,NIL } )
				aAdd( aItem, {"C7_TOTAL"    ,(ZD6PZ->TOTAL_OP*ZD6PZ->C3PRECO),NIL } ) 
				aAdd( aItem, {"C7_DESC"	    ,CriaVar("C7_DESC",.F.)	,Nil})    	//Desconto
				aAdd( aItem, {"C7_IPI"		,CriaVar("C7_IPI",.F.)						,NIL})    	//IPI
				aAdd( aItem, {"C7_IPIBRUT"	,'B'										,NIL})    	//IPI Bruto
				aAdd( aItem, {"C7_REAJUST"	,CriaVar("C7_REAJUST",.F.)					,NIL})    	//Reajuste
				aAdd( aItem, {"C7_FRETE"	,CriaVar("C7_FRETE",.F.)				,NIL})    	//Frete
				aAdd( aItem, {"C7_DATPRF"   ,Date()+2,NIL } )  //Data de entrega
				aAdd( aItem, {"C7_LOCAL"	, "01"									,NIL})    	//Local
				aAdd( aItem, {"C7_TPFRETE"	,CriaVar("C7_TPFRETE",.F.)					,NIL})    	//Tipo de frete
				aAdd( aItem, {"C7_OBS"		,ZD6PZ->C3OBS		,NIL})    	//Observacao
				aAdd( aItem, {"C7_CONTA"  	,CriaVar("C7_CONTA",.F.)					,NIL})    	//Conta do produto
				aAdd( aItem, {"C7_CC"       ,ZD6PZ->C3CC           ,NIL} ) // VENDA MERCADO INTERNO	//Centro de custo
				aAdd( aItem, {"C7_YTPJNC","CTN",NIL} )    // TP JUST COMP - JUSTIFICATIVA DA COMPRA
				aAdd( aItem, {"C7_OP",AllTrim(ZD6PZ->OP),NIL} )
				aAdd( aItem, {"C7_YOP",AllTrim(ZD6PZ->OP),NIL} )
				aAdd( aItem, {"C7_TIPO"      ,2                , NIL} )	
								
					
				If  nOpc == 3
					MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCab,{aItem},nOpc) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão				
				Else
					MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCab,{aItem}, nOpc ) // alteração
				EndIf

				If !lMsErroAuto
					ConOut("Incluido com sucesso! " + cNumPC)
					If nOpc == 3
						ConfirmSX8()
					EndIf	
					nOpc := 4	
					AADD(aOPCad, AllTrim(ZD6PZ->OP))	
					AADD(aNumItem, {cNumPC, StrZero(nI, 4)})		
					 	 
				Else
					RollbackSx8()				 
					cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
					ConOut(PadC("Automatic routine ended with error", 80))
					ConOut("Error: "+ cError)
					MsgInfo("Nenhum pedido foi processado!"+STR_PULA+STR_PULA +cValToChar(cError)+"", "Error")
					ZD6PZ->(dbCloseArea())
					Return .F.
				EndIf		
				
				aItem := {} 
				nI++ 		 
				ZD6PZ->(dbSkip())
			EndDo  

		End Transaction

		ZD6->(DbSetOrder(2))  // ZD6_FILIAL, ZD6_OP_ID, R_E_C_N_O_, D_E_L_E_T_ 	 
		If Len(aOPCad) > 0
			For nI := 1 To Len(aOPCad)
				if ZD6->(DbSeek(FWxFilial('ZD6')+AllTrim(aOPCad[nI])))
					RecLock( "ZD6", .F.)	
						ZD6->ZD6_STATUS  := '1'	 // Processado
						ZD6->ZD6_OK  := ''
					msUnLock()
				EndIf
			Next nI
			
			DbSelectArea("SC7")   			 	 
			SC7->(DbSetOrder(1))  //1 - C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_		 
			For nI := 1 To Len(aNumItem)
				if SC7->(DbSeek(FWxFilial('ZD6')+AllTrim(aNumItem[nI,1])+AllTrim(aNumItem[nI,2])))
					RecLock("SC7", .F.)	
						SC7->C7_TIPO  := 2	 // AUTORIZAÇÃO DE ENTREGA						 
					msUnLock()
				EndIf
			Next nI
			SC7->(dbCloseArea())
			 
			FwAlertSuccess("Pedido de compra / Autorização de entrega criado com sucesso! "+STR_PULA+STR_PULA+" Código: <b>"+cNumPC+"</b>")
			oMark:oBrowse:Refresh()
			oMark:oBrowse:Refresh(.T.)
		EndIf	 
		ZD6PZ->(dbCloseArea())	  
 
Return .T.

User Function DMarkZD6()	
	 
	Local cMarca   := oMark:Mark()	 
	//Percorrendo os registros da ZD6
	ZD6->(DbGoTop())
	While !ZD6->(EoF())
		//Caso esteja marcado, aumenta o contador
		If oMark:IsMark(cMarca)
			RecLock( "ZD6", .F.)
				ZD6->ZD6_OK = ''
			ZD6->(MsUnLock())			 	
		EndIf		
		//Pulando registro
		ZD6->(DbSkip())
	EndDo 
	oMark:oBrowse:Refresh()
	oMark:oBrowse:Refresh(.T.)
Return

Static Function ValidRep(aListId)
	

	Local cQuery	:= ""
	Local cINQuery	:= ""
	Local lRet  	:= .T.
	Local cMens     := "A(s) OP(s) abaixo já foram processadas: " + STR_PULA+STR_PULA
	 
	For nX := 1 To Len(aListId)
		cINQuery += aListId[nX]+","
	Next nX 

	cINQuery := SUBSTR(cINQuery, 0, (LEN(cINQuery)-1))

	cQuery += " SELECT DISTINCT ZD6_OP_ID "
	cQuery += " FROM "+RetSQLName("ZD6")+"  "
	cQuery += " WHERE ZD6_OP_ID IN " + FormatIn(cINQuery,",")
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " AND ZD6_STATUS = '1' "
	cQuery += " AND ZD6_FILIAL = '"+FWxFilial('ZD6')+"' "	

	TcQuery cQuery new alias "ZD6K"  
	ZD6K->(DBGotop())  
	While !ZD6K->(EOF()) //Enquando não for fim de arquivo
	 	  lRet  	:= .F.
		  cMens += "<b>"+cValTochar(ZD6K->ZD6_OP_ID)+"</b> " +STR_PULA
	ZD6K->(dbSkip())
	EndDo  
	cMens +=  STR_PULA	+"  Por favor selecione as não processadas."
	ZD6K->(dbCloseArea())

	if lRet == .F.
		MsgInfo(cMens, "Atenção")
	EndIf

Return lRet


Static Function ModZD601()

	Local cCCusto := Space(TamSX3("CTT_CUSTO")[1]) 
	Local cCodPgto := Space(TamSX3("E4_CODIGO")[1])
	Local cOBS := Space(TamSX3("C7_OBS")[1])

	DEFINE MSDIALOG oDlg TITLE " Observação " FROM 0,0 TO 150, 350 OF oMainWnd PIXEL Style DS_MODALFRAME
	//@ 010,020 SAY "Obs: " SIZE 200,10 PIXEL OF oDlg
	@ 010,030 GET cOBS MEMO SIZE 110, 025 PIXEL OF oDlg MULTILINE 
	@ 050,080 BUTTON "Confirma " SIZE 50,12 PIXEL OF oDlg ACTION (oDlg:end())
	ACTIVATE MSDIALOG oDlg CENTER
	
/*
	DEFINE MSDIALOG oDlg TITLE " Contrao de parceria " FROM 0,0 TO 170, 400 OF oMainWnd PIXEL Style DS_MODALFRAME
	
	@ 010,020 SAY "CC: " SIZE 50,10 PIXEL OF oDlg
	@ 025,020 MSGET cCCusto F3 "CTT" SIZE 50, 10 PIXEL OF oDlg

	@ 040,020 SAY "Cond. Pgto: " SIZE 50,10 PIXEL OF oDlg
	@ 055,020 MSGET cCodPgto F3 "SE4" SIZE 50, 10 PIXEL OF oDlg
 
	@ 070,020 SAY "Obs: " SIZE 50,10 PIXEL OF oDlg
	@ 085,020 GET cOBS MEMO SIZE 110, 020 PIXEL OF oDlg MULTILINE 
 

	@ 100,080 BUTTON "Confirma " SIZE 50,12 PIXEL OF oDlg ACTION (oDlg:end())
	ACTIVATE MSDIALOG oDlg CENTER	
*/
Return {cCCusto, cCodPgto, cOBS}