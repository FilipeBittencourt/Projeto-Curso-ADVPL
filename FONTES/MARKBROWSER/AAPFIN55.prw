#Include "protheus.ch"
#INCLUDE "FILEIO.CH" 
#Include "tbiconn.ch"
#Include "topconn.ch"

/*/{Protheus.doc} AAPFIN55
Rotina para geração de remessa para Integração com o Serasa.
@type Function
@author Pontin
@since 04/10/2016
@version 1.0
/*/

/*
PARAMETROS:

MV_YNREMES
Descrição: Controla Sequencial do Arquivo.

MV_YSVAMIN
Descrição: Valor Minimo de saldo dos títulos

MV_YSEDIAS
Descrição: Dias de Atraso mínimo dos títulos a serem enviados

MV_YLOGSER
Descrição: Código do Login no Serasa

MV_YDIRESE
Descrição: Diretório Destino do arquivo de remessa
*/

User function PCPTEST()

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
	
	
	 
	
	LjMsgRun("Carregando dados para seleção...",,{|| aAlias := fQryTrb() } )
	
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
		oMrkBrowse:oBrowse:SetUseFilter()    
		oMrkBrowse:oBrowse:SetFieldFilter(aFilter)
		oMrkBrowse:oBrowse:bOnStartFilter := Nil
		oMrkBrowse:SetLocate() 
		oMrkBrowse:SetWalkThru(.F.)
		oMrkBrowse:SetAmbiente(.F.)
		oMrkBrowse:Activate()
	Else
		Help(" ",1,"RECNO")
	EndIf
	
		
	If !Empty(cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbCloseArea()
		if file(cAliasMrk+GetDBExtension())
			Ferase(cAliasMrk+GetDBExtension())
		endif	
		if file(cAliasMrk+OrdBagExt())
			Ferase(cAliasMrk+OrdBagExt())
		endif
		if file(cIndMrk+OrdBagExt())
			Ferase(cIndMrk+OrdBagExt())
		endif
	Endif
	
	RestArea(aArea) 
	
Return




Static Function FIMenudef(cAliasMrk)

	Local aRotina := {} 
 
 aRotina := {;
	{"Remover"  , "U_BtnDel(cAliasMrk)", 0, 1},;	 
	{"Adicionar"    ,"U_BtnAdd(cAliasMrk)"  , 0, 2}}
 
 
Return(aRotina)


 

User Function BtnAdd(cAliasMrk)

	Local cMarca   := oMrkBrowse:Mark()
	Local lInverte := oMrkBrowse:IsInvert()
	Local nCt      := 0
	
	 
	oMrkBrowse:GoTop(.T.) 
	dbSelectArea(cAliasMrk) 
	(cAliasMrk)->(DbGoTop())
	While (cAliasMrk)->(!Eof())	 
		If oMrkBrowse:IsMark(cMarca)			 	
			Alert((cAliasMrk)->UD4_DOC)
			nCt++					
		EndIf
		(cAliasMrk)->(DbSkip())
	EndDo
	
	//Mostrando a mensagem de registros marcados
	MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' </b>.', "Atenção")
 	oMrkBrowse:Refresh(.T.)

Return .T.

User Function BtnDel(cAliasMrk)

	Local cMarca   := oMrkBrowse:Mark()
	Local lInverte := oMrkBrowse:IsInvert()
	Local nCt      := 0
	
	 
	oMrkBrowse:GoTop(.T.)	
	 
		dbSelectArea(cAliasMrk)
 
	
	While (cAliasMrk)->(!Eof())
		cAliasMrk->(DbGoTop())
		 
			If oMrkBrowse:IsMark(cMarca)			 	
				Alert(cAliasMrk->UD4_DOC)
				nCt++					
			EndIf
			cAliasMrk->(DbSkip())
		EndDo
	
	//Mostrando a mensagem de registros marcados
	MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' </b>.', "Atenção")
 	oMrkBrowse:Refresh(.T.)
	 
Return .T.


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
	Local cIndTRB1  := ''
	
	
	BeginSQL alias cAliasTrb   
		SELECT DISTINCT  UD4_DOC, UD4_DATA , UD4_YOK
		FROM %Table:UD4% (NOLOCK) WHERE UD4_STATUS  <= 3  
		AND  D_E_L_E_T_ = ''
		ORDER BY UD4_DATA desc	          
	EndSQL
	
	DbSelectArea(cAliasTrb)
	TcSetField(cAliasTrb,"UD4_DOC","C",18)
	aStruQry := (cAliasTrb)->(DbStruct()) 
	
	DbSelectArea("SX3")	
	SX3->(DbSetOrder(2)) 
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
	IndRegua(cTempTab,cIndTRB1,"UD4_DOC",,,"Criando Indice")
	dbClearIndex()
	dbSetIndex(cIndTRB1 + OrdBagExt())
	
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
			aColumns[Len(aColumns)]:SetPicture(PesqPict( iif( 'UD4_'$ aStruct[nX,1],'UD4','SA1') ,aStruct[nX,1])) 
			
			If Alltrim(aStruct[nX,2]) == 'N'
				aColumns[Len(aColumns)]:SetAlign("RIGHT") 
			elseif Alltrim(aStruct[nX,2]) == 'D' 
				aColumns[Len(aColumns)]:SetAlign("CENTER") 
			endif
	
			AAdd( aFilterX, { aStruct[nX,1], RetTitle(aStruct[nX,1]), aStruct[nX,2], aStruct[nX,3], aStruct[nX,4], PesqPict( iif( 'UD4_'$ aStruct[nX,1],'UD4','SA1') ,aStruct[nX,1]) } )
		endif
	Next nX 	 


	AAdd(aSeeks, {; 					 
					AllTrim(RetTitle(aStruct[1,1])),;
				 {;
				 	{'UD4',aStruct[1,2],aStruct[1,3],aStruct[1,4],AllTrim(RetTitle(aStruct[1,1])),Nil};								
				 }})
	
	RestArea(aArea)
	
Return({cTempTab,aColumns,cIndTRB1,aFilterX,aSeeks})

 


 Static Function fMark(cAliasTRB)
	
	Local lRet	:= .T.
	UD4->(dbGoto((cAliasTRB)->UD4_DOC))
	If UD4->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
		lRet := .t. 
	Else
		IW_MsgBox("Este registro esta sendo utilizado em outro terminal, nã podendo ser selecionado","Atenção","STOP")	
		lRet := .F.
	Endif
	
Return lRet


Static Function fInverte(cAliasTRB,lTudo)
	
	Local nReg 	  := (cAliasTRB)->(Recno())
	Local cMarca  := oMrkBrowse:cMark
	Default lTudo := .T.
	
	dbSelectArea(cAliasTRB)
	If lTudo
		(cAliasTRB)->(dbgotop()) 
		cMarca := oMrkBrowse:cMark
	Endif
	
	While (cAliasTRB)->(!Eof())
		UD4->(dbGoto((cAliasTRB)->UD4_DOC))
		If UD4->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
			IF (cAliasTRB)->UD4_YOK == cMarca
				(cAliasTRB)->UD4_YOK := "  "
				(cAliasTRB)->(MsUnlock())
				UD4->(MsUnlock())			
			Else
				(cAliasTRB)->UD4_YOK := cMarca
			Endif
			If !lTudo
				Exit
			Endif
		Endif
		(cAliasTRB)->(dbSkip())
	Enddo
	(cAliasTRB)->(dbGoto(nReg))
	oMrkBrowse:oBrowse:Refresh(.t.)
	
Return .T.