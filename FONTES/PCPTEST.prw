#Include "protheus.ch"
#INCLUDE "FILEIO.CH" 
#Include "tbiconn.ch"
#Include "topconn.ch"


//Constantes
#Define STR_PULA	Chr(13)+Chr(10)

/*/{Protheus.doc} AAPFIN55
Rotina para geração dados para popular a ZD6 , PARA RATEIO NO PEDIDO DE COMPRA
@type Function
@author Filipe
@since 02/10/2019
@version 1.0
/*/

User function PCPTEST()	
	
	LoadBrowse()
	
Return

Static Function LoadBrowse()

	Local aArea       := GetArea()
	Local aAlias	  	:= {}								
	Local aColumns	:= {}											
	Local oDlgMrk 	:= Nil
	Local cIndMrk	  	:= ''
	Local aFilter	  	:= {}
	Local aSeeks		:= {}	
	Private aRotina	:= {} 
	Private cAliasMrk	:= ''
	Private oMrkBrowse := Nil

	If Type("oMrkBrowse") == "O"
        oMrkBrowse:DeActivate()
        oMrkBrowse:Destroy()
    EndIf


 FWMsgRun(, {|| aAlias := fQryTrb() }, "Aguarde!", "Atualizando as listas...")
	
	//LjMsgRun("Carregando dados para seleção...",,{|| aAlias := fQryTrb() } )
	
	cAliasMrk := aAlias[1]
	aColumns  := aAlias[2]
	cIndMrk   := aAlias[3]
	aFilter	  := aAlias[4] 
	aSeeks	  := aAlias[5] 
	aRotina	  := FIMenudef(cAliasMrk)
	
	If !(cAliasMrk)->(Eof())
		oMrkBrowse:= FWMarkBrowse():New()
		oMrkBrowse:SetFieldMark("UD4_YOK")
		oMrkBrowse:SetOwner(oDlgMrk)
		oMrkBrowse:SetDataQuery(.F.)
		oMrkBrowse:SetDataTable(.T.)
		oMrkBrowse:SetSeek(.T.,aSeeks)
		oMrkBrowse:SetAlias(cAliasMrk)
		//oMrkBrowse:bMark    := {|| fMark(cAliasMrk)}
		//oMrkBrowse:bAllMark := {|| fInverte(cAliasMrk,.T.) }
		oMrkBrowse:SetDescription("Lista de OPS")
		oMrkBrowse:SetColumns(aColumns)
		oMrkBrowse:oBrowse:SetDBFFilter(.T.) 
		oMrkBrowse:oBrowse:SetUseFilter(.F.)    
		oMrkBrowse:oBrowse:SetFieldFilter(aFilter)
		oMrkBrowse:oBrowse:bOnStartFilter := Nil
		oMrkBrowse:SetLocate() 
		oMrkBrowse:SetWalkThru(.F.)
		oMrkBrowse:SetAmbiente(.F.)
		oMrkBrowse:Activate()
	Else
		Help(" ",1,"RECNO")
	EndIf

	RestArea(aArea) 

Return .T.


Static Function FIMenudef(cAliasMrk)

	Local aRotina := {} 
	AADD(aRotina, {"Adicionar" , "U_BtnAdd(cAliasMrk)"  , 0, 2}) 
	AADD(aRotina, {"Remover"   , "U_BtnDel(cAliasMrk)", 0, 2})	
	AADD(aRotina, {"Desmarc. Todos" , "U_DMarkPCP(cAliasMrk)"  , 0, 2}) 
	
	
 
Return(aRotina)

// CRIA TABELA DINAMICA
Static Function fQryTrb()

	Local aArea		:= GetArea()			
	Local aStruQry	:= {}	
	Local aStruct	:= {}	
	Local aColumns	:= {}					
	Local nX		:= 0					
	Local cTempTab	:= ""					
	Local cAliasTrb	:= GetNextAlias()
	Local aFilterX  := {}
	Local aSeeks	:= {}
	Local cEFilial  := FWxFilial('UD4')
	
	
	BeginSQL alias cAliasTrb   
		SELECT DISTINCT 
		 CASE WHEN UD4.UD4_DOC = ZD6.ZD6_LISTID THEN 'IMPORTADO' ELSE '' END  AS STATUS  
		,UD4.UD4_DOC
		,ZD6.ZD6_CP_ID
		,UD4.UD4_YOK
		FROM %Table:UD4% UD4 (NOLOCK) 
		LEFT JOIN %Table:ZD6% ZD6 (NOLOCK) ON UD4.UD4_DOC = ZD6.ZD6_LISTID  AND  ZD6.D_E_L_E_T_  = ''
		INNER JOIN %Table:SD4% SD4 ON UD4.UD4_DOC = SD4.D4_UD4DOC  AND SD4.D_E_L_E_T_ = '' AND SD4.D4_FILIAL = %exp:cEFilial%
		INNER JOIN %Table:SC2% SC2 (NOLOCK) ON SD4.D4_OP   = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN AND SC2.D_E_L_E_T_ = '' AND SC2.C2_FILIAL = %exp:cEFilial% 
		WHERE  UD4.UD4_STATUS <= 3 
		AND UD4.D_E_L_E_T_ = '' 
		AND UD4.UD4_FILIAL =  %exp:cEFilial% 
		AND SC2.C2_DATRF = '' 
		ORDER BY  UD4.UD4_DOC DESC

          
	EndSQL
	
	DbSelectArea(cAliasTrb)
	TcSetField(cAliasTrb,"UD4_DOC","C",18)
	aStruQry := (cAliasTrb)->(DbStruct()) 
	
	DbSelectArea("SX3")	
	SX3->(DbSetOrder(2)) 
	AADD(aStruct,{"STATUS" ,"C",0010,0})
	
	for nx := 1 to len(aStruQry) 
		if SX3->(DbSeek(PADR(alltrim(aStruQry[nx,1]),10)))
			AADD(aStruct,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL} )
		endif
	next nx	

	
	cTempTab := CriaTrab( aStruct,.T. )
	
	DbSelectArea(cAliasTrb)
	if (cAliasTrb)->(!EOF())
		COPY TO &cTempTab
	endif
		
	If ( Select( cAliasTrb ) > 0 )
		(cAliasTrb)->(DbCloseArea())
	EndIf
	
	DbUseArea( .T.,,cTempTab,cTempTab, .T., .F. )  
	
	cIndTRB1 := CriaTrab(Nil, .F.)
	cIndTRB2 := CriaTrab(Nil, .F.)

	IndRegua(cTempTab,cIndTRB1,"UD4_DOC",,,"Criando Indice")
	IndRegua(cTempTab,cIndTRB2,"ZD6_CP_ID",,,"Criando Indice")
	dbClearIndex()
	dbSetIndex(cIndTRB1 + OrdBagExt())
	dbSetIndex(cIndTRB2 + OrdBagExt())
	
	For nX := 1 To Len(aStruct)
		If	!Alltrim(aStruct[nX,1]) $ "UD4_YOK"
		
			AAdd(aColumns,FWBrwColumn():New())
			If Alltrim(aStruct[nX,2]) == 'D'
				aColumns[Len(aColumns)]:SetData( &("{|| SToD("+aStruct[nX,1]+") }") )
			Else
				aColumns[Len(aColumns)]:SetData( &("{|| "+aStruct[nX,1]+"}") )
			EndIf	
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nX,1])) 
			aColumns[Len(aColumns)]:SetType(aStruct[nX,2])
			aColumns[Len(aColumns)]:SetSize(aStruct[nX,3]) 
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nX,4])	

			
	
			If(Alltrim(aStruct[nX,1]) == 'STATUS') 
			    aColumns[Len(aColumns)]:ctitle	:= aStruct[nX,1]
			    aColumns[Len(aColumns)]:SetPicture('@!') 
			    AAdd( aFilterX, { aStruct[nX,1], RetTitle(aStruct[nX,1]), aStruct[nX,2], aStruct[nX,3], aStruct[nX,4], '@!' } )
			Else
			   aColumns[Len(aColumns)]:SetPicture(PesqPict( iif( 'UD4_'$ aStruct[nX,1],'UD4','SA1') ,aStruct[nX,1])) 
				AAdd( aFilterX, { aStruct[nX,1], RetTitle(aStruct[nX,1]), aStruct[nX,2], aStruct[nX,3], aStruct[nX,4], PesqPict( iif( 'UD4_'$ aStruct[nX,1],'UD4','SA1') ,aStruct[nX,1]) } )
			endif

		   If Alltrim(aStruct[nX,2]) == 'N'
				aColumns[Len(aColumns)]:SetAlign("RIGHT") 
			elseif Alltrim(aStruct[nX,2]) == 'D' 
				aColumns[Len(aColumns)]:SetAlign("CENTER") 
			endif

		endif
	Next nX 	 


	AAdd(aSeeks, {; 					 
					AllTrim(RetTitle(aStruct[2,1])),;			 
				 {;
				 	{'UD4',aStruct[2,2],aStruct[2,3],aStruct[2,4],AllTrim(RetTitle(aStruct[2,1])),Nil};	
				 }})
	
	AAdd(aSeeks, {; 					 
					 AllTrim(RetTitle(aStruct[3,1])),;					 
				 {;								
					{'UD4',aStruct[3,2],aStruct[3,3],aStruct[3,4],AllTrim(RetTitle(aStruct[3,1])),Nil};	
				 }})
	RestArea(aArea)
	
Return({cTempTab,aColumns,{cIndTRB1,cIndTRB2},aFilterX,aSeeks}) 



User Function BtnDel(cAliasMrk)

	Local cMarca   := oMrkBrowse:Mark()
	Local lInverte := oMrkBrowse:IsInvert()	 
	Local cMens    := "Você selecionou a(s) lista(s): " +STR_PULA+STR_PULA
	Local cMenDel  := "A(s) lista(s) abaixo será/serão deletada(s): "+STR_PULA+STR_PULA
	Local cMenAdd  := "A(s) lista(s) abaixo <b>NÃO</b> será/serão deletada(s), pois já está/estão em pedido de compra. "+STR_PULA+STR_PULA
	Local aListId  := {}
	 
 
	dbSelectArea(cAliasMrk) 
	dbSelectArea("ZD6")
	(cAliasMrk)->(DbGoTop())	
	ZD6->(dbSetOrder(1))//ZD6_FILIAL, ZD6_LISTID, R_E_C_N_O_, D_E_L_E_T_
	ZD6->(DbGoTop())
	While (cAliasMrk)->(!Eof())	 
		If oMrkBrowse:IsMark(cMarca)
			If ZD6->(dbSeek(FWxFilial('UD4')+(cAliasMrk)->UD4_DOC))
				AADD(aListId, (cAliasMrk)->UD4_DOC)	
				If Empty(ZD6->ZD6_STATUS)
					cMenDel += " <b>"+cValTochar((cAliasMrk)->UD4_DOC)+STR_PULA+"</b> "							
				Else
					cMenAdd += " <b>"+cValTochar((cAliasMrk)->UD4_DOC)+STR_PULA+"</b> "
				EndIf				
			EndIf		 				
		EndIf
		(cAliasMrk)->(DbSkip())
	EndDo

	cMens += cMenDel
	cMens += STR_PULA+cMenAdd


	cMens += STR_PULA+"  Deseja prosseguir ?"

	
	If Len(aListId) > 0
		If MsgYesNo(cMens,"ATENÇÃO","YESNO")
			(cAliasMrk)->(DbGoTop())
			ZD6->(DbGoTop())
			While (cAliasMrk)->(!Eof())	 
				If oMrkBrowse:IsMark(cMarca)
					If ZD6->(dbSeek(FWxFilial('UD4')+(cAliasMrk)->UD4_DOC))
						If Empty(ZD6->ZD6_STATUS)
							RecLock( "ZD6", .F.)
								ZD6->(dbdelete())
							ZD6->(MsUnLock())					 
						EndIf				
					EndIf		 				
				EndIf
				(cAliasMrk)->(DbSkip())
			EndDo
			ZD6->(dbCloseArea())
			(cAliasMrk)->(dbCloseArea())
			LoadBrowse()
		Else
			MsgInfo('Nenhuma Lista foi processada', "Atenção")
		EndIf
	Else
		MsgInfo('É preciso selecionar uma Lista com o SATUS <b>IMPORTADO</b> para continuar.', "Atenção")
	EndIf

	
	
	 	 
Return .T.

User Function DMarkPCP(cAliasMrk)	
	dbSelectArea(cAliasMrk) 
	(cAliasMrk)->(DbGoTop())
	While (cAliasMrk)->(!Eof())	 	
		If RecLock( (cAliasMrk), .F. )
			(cAliasMrk)->UD4_YOK  := " "
			msUnLock()         				
		EndIf
		(cAliasMrk)->(DbSkip())
	EndDo 
	oMrkBrowse:oBrowse:Refresh()
	oMrkBrowse:oBrowse:Refresh(.T.)
Return


User Function BtnAdd(cAliasMrk)

	Local cMarca   := oMrkBrowse:Mark()
	Local lInverte := oMrkBrowse:IsInvert()
	Local aListId  := {}
	Local cMens   := "Você selecionou as lista(s): " + STR_PULA+STR_PULA
	Local nCt     := 0	 
 
	dbSelectArea(cAliasMrk) 
	(cAliasMrk)->(DbGoTop())
	While (cAliasMrk)->(!Eof())	 
		If oMrkBrowse:IsMark(cMarca)			 	
			//Alert((cAliasMrk)->UD4_DOC)
			cMens += "<b>"+cValTochar((cAliasMrk)->UD4_DOC)+"</b> " +STR_PULA
			AADD(aListId, (cAliasMrk)->UD4_DOC)		
			nCt++					
		EndIf
		(cAliasMrk)->(DbSkip())
	EndDo

	cMens +=  STR_PULA	+"  E será/serão processada(s). Tem certeza ?"

	If Len(aListId) > 0
		If MsgYesNo(cMens,"ATENÇÃO","YESNO")
			FWMsgRun(, {|| Salvar(aListId) }, "Aguarde!", "Reunindo as OPs da(s) lista(s) selecionadas e salvando na ZD6 ...")
			//Desmarc(cAliasMrk)				
		Else
			MsgInfo('Nenhuma Lista foi processada', "Atenção")
		EndIf
	EndIf	

Return .T.


Static Function ValidRep(aListId)
	

	Local cQuery	:= ""
	Local cINQuery	:= ""
	Local cValidRep	:= "" 
	 
	For nX := 1 To Len(aListId)
		cINQuery += aListId[nX]+","
	Next nX 

	cINQuery := SUBSTR(cINQuery, 0, (LEN(cINQuery)-1))

	cQuery += " SELECT DISTINCT ZD6_LISTID "
	cQuery += " FROM "+RetSQLName("ZD6")+"  "
	cQuery += " WHERE ZD6_LISTID IN " + FormatIn(cINQuery,",")
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " AND ZD6_FILIAL = '"+FWxFilial('SD4')+"' "
	

	TcQuery cQuery new alias "ZD6K"  
	ZD6K->(DBGotop())  
	While !ZD6K->(EOF()) //Enquando não for fim de arquivo
	 
		 cValidRep += " <b>" +cValToChar( AllTrim(ZD6K->ZD6_LISTID)) +"</b> " +STR_PULA
	ZD6K->(dbSkip())
	EndDo  
	ZD6K->(dbCloseArea())

Return cValidRep


//SALVA NA ZD6 COM A LISTA E SUAS OPS
Static Function Salvar(aListId)

	Local cQuery	:= ""
	Local cINQuery	:= ""
	Local cValidRep	:= ValidRep(aListId)
	Local cValidSC3	:= SC3f3()
	Local nOPTotZD6	:= 0
	Local nOPTotal	:= 0
	 

 	If  !Empty(cValidRep)		
		MsgInfo('Nenhuma Lista foi processada, pois existem listas ja processadas: '+STR_PULA+cValidRep+' ', "Atenção")
		Return .F.
	EndIf

	If  Empty(cValidSC3)
		cValidRep := SUBSTR(cValidRep, 0, (LEN(cValidRep)-1))
		MsgInfo('O contrato de parceria precisa ser informado '+cValidRep+STR_PULA+'. ', "Atenção")
		Return .F.
	EndIf
 



	// soma todos os pesos já selecionados com o contrato informado na ZD6
	cQuery := "	SELECT SUM ((SC2.C2_QUANT * SB1.B1_PESO)) AS PESO_TOTAL_OP FROM "+RetSQLName("ZD6")+"  ZD6 "
	cQuery += " INNER JOIN "+RetSQLName("SC2")+" SC2 (NOLOCK) ON ZD6.ZD6_OP_ID  = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN  AND   SC2.D_E_L_E_T_ = ''  AND SC2.C2_DATRF = '' AND SC2.C2_FILIAL =  " + ValToSql(FWxFilial('SC2')) 
	cQuery += " INNER JOIN "+RetSQLName("SB1")+" SB1 (NOLOCK) ON SB1.B1_COD  = SC2.C2_PRODUTO AND   SB1.D_E_L_E_T_ = ''   "	
	cQuery += "  WHERE ZD6.ZD6_CP_ID = " + ValToSql(cValidSC3) 
	cQuery += "  AND ZD6.D_E_L_E_T_ = '' "
	
	TcQuery cQuery new alias "ZD6N" 	
	If !Empty(ZD6N->PESO_TOTAL_OP)
		nOPTotZD6 := ZD6N->PESO_TOTAL_OP
	EndIf
	ZD6N->(dbCloseArea())

 
	For nX := 1 To Len(aListId)
		cINQuery += aListId[nX]+" ,"
	Next nX 
	cINQuery := SUBSTR(cINQuery, 0, (LEN(cINQuery)-1))
	cQuery := " 	SELECT DISTINCT " + STR_PULA
	cQuery += " 		SD4.D4_UD4DOC AS LISTID " + STR_PULA
	cQuery += " 		,SC2.C2_NUM + C2_ITEM + C2_SEQUEN AS OP  "	 + STR_PULA
	cQuery += " 		,SC2.C2_QUANT as C2QUANT " + STR_PULA
	cQuery += " 		,SB1.B1_PESO as B1PESO " + STR_PULA
	cQuery += " 		,(SC2.C2_QUANT * SB1.B1_PESO) PESO_TOTAL_OP " + STR_PULA
	cQuery += " 		,SC2.C2_YPRJODM AS PRJODM  " + STR_PULA
	cQuery += " 		,(SELECT SUM(C3_QUANT) - SUM(C3_QUJE) AS SALDO FROM "+RetSQLName("SC3")+" WHERE C3_NUM = " + ValToSql(cValidSC3)+ "  AND D_E_L_E_T_ = '' AND C3_FILIAL = "+ ValToSql(FWxFilial('SC2'))+" )  as TOTAL_CP " + STR_PULA
	cQuery += " 	FROM "+RetSQLName("SC2")+" SC2 (NOLOCK) " + STR_PULA
	cQuery += " 		INNER JOIN "+RetSQLName("SB1")+" SB1 (NOLOCK) ON SB1.B1_COD  = SC2.C2_PRODUTO AND   SB1.D_E_L_E_T_ = '' " + STR_PULA
	cQuery += " 		INNER JOIN "+RetSQLName("SD4")+" SD4  (NOLOCK) ON SD4.D4_OP   = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN AND SD4.D_E_L_E_T_ = ''  " + STR_PULA
	cQuery += " 	WHERE SC2.D_E_L_E_T_ = '' " + STR_PULA
	cQuery += " 	AND SD4.D4_UD4DOC IN " + FormatIn(cINQuery,",") + STR_PULA
	cQuery += "     AND SC2.C2_FILIAL = "+ ValToSql(FWxFilial('SC2'))
	cQuery += " 	AND SC2.C2_DATRF = ''  "
	
	TcQuery cQuery new alias "ZD6X" 		
	ZD6X->(DBGotop())

	If Empty(ZD6X->TOTAL_CP)		 
		MsgInfo("Não existem OPs válidas na SC2 para a(s) lista(s): <b>"+cINQuery+"</b>  ", "AVISO")
		ZD6X->(dbCloseArea())
		Return .F.
	EndIf
	
	While !ZD6X->(EOF())
		nOPTotal += ZD6X->PESO_TOTAL_OP
		ZD6X->(dbSkip())
	EndDo

   
	ZD6X->(dbGoTop())
	If (ZD6X->TOTAL_CP > 0  .AND.  ZD6X->TOTAL_CP >=  (nOPTotal + nOPTotZD6))
		
		While !ZD6X->(EOF()) //Enquando não for fim de arquivo

			RecLock( "ZD6", .T.)

			ZD6->ZD6_FILIAL  := FWxFilial('SD4')
			ZD6->ZD6_LISTID  := AllTrim(ZD6X->LISTID)
			ZD6->ZD6_OP_ID   := AllTrim(ZD6X->OP)
			ZD6->ZD6_ODM_ID  := AllTrim(ZD6X->PRJODM)
			ZD6->ZD6_CP_ID   := AllTrim(cValidSC3)
			ZD6->ZD6_STATUS  := ''
			
			msUnLock() 	
			ZD6X->(dbSkip())
		EndDo

		FwAlertSuccess("A(s) lista(s): <b>"+STR_PULA+STR_PULA+cINQuery+STR_PULA+STR_PULA+"</b>  foi/foram salva(s) com sucesso. ")
		ZD6X->(dbCloseArea())		
		LoadBrowse()

	Else

		MsgInfo("Existem divergências de valores do contrato de parceria <b>"+cValToChar(cValidSC3)+"</b>. " +STR_PULA+STR_PULA+;
		"<b>Total das OPs Informadas: </b>"+cValToChar(nOPTotal)+STR_PULA + ;
		"<b>Total das OPs já cadastradas (ZD6): </b>"+cValToChar(nOPTotZD6)+STR_PULA + ;    
		"<b>Saldo total do CP</b>: "+cValToChar(ZD6X->TOTAL_CP)+"", "AVISO")

	EndIf 

	ZD6X->(dbCloseArea())		 
 
Return



Static Function SC3f3()

	Local cNroContr := Space(TamSX3("C3_NUM")[1])

	DEFINE MSDIALOG oDlg TITLE " Contrao de parceria " FROM 0,0 TO 150, 300 OF oMainWnd PIXEL Style DS_MODALFRAME
	@ 010,020 SAY "Número: " SIZE 200,10 PIXEL OF oDlg
	@ 020,020 MSGET cNroContr F3 "SC3" SIZE 110, 10 PIXEL OF oDlg
	@ 040,080 BUTTON "Confirma " SIZE 50,12 PIXEL OF oDlg ACTION (oDlg:end())
	ACTIVATE MSDIALOG oDlg CENTER	

Return cNroContr




////////////////////////// FUNÇÕES QUE AUXILIAM A CRIAÇÃO DO PEDIDO DE COMPRA COM BASE NOS ITENS DAS OPS DA ZD6  //////////////////////////

