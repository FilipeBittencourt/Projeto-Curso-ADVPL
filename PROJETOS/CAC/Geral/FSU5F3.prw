#INCLUDE "PROTHEUS.CH"

User Function FSU5F3(_cEntidade,_cVarCodEnt)

Local aArea		:= GetArea()
Local cQuery	:= ""
Local cEntidade	:= ""
Local cCodEnt	:= ""
Local lRet		:= .F.
Local cAliTmp	:= "SU5TMP" 
Local cPesq	 	:= Space(50) 
Local nRecno	:= 0 
Local nSizeEnt	:= 0   
Local oDlg		:= Nil
Local oLstBx	:= Nil
Local aContato	:= {}
Local bRet		:= {|| If(!Empty(aTail(oLstBx:aArray[oLstBx:nAt])),(lRet := .T.,nRecno := IIf(Len(oLstBx:aArray)>=oLstBx:nAt,aTail(oLstBx:aArray[oLstBx:nAt]),0),oDlg:End()),(lRet := .F.,MsgInfo("Nenhum Contato Selecionado!")))}
Local bVisual	:= {|| If(!Empty(aTail(oLstBx:aArray[oLstBx:nAt])),(nRecno := IIf(Len(oLstBx:aArray)>=oLstBx:nAt,aTail(oLstBx:aArray[oLstBx:nAt]),0),ALTERA := .F.,SU5->(DbGoTo(nRecno),A70Visual("SU5",nRecno,2))),Nil)}
Local oPesq
                                                   
cEntidade := _cEntidade
cCodEnt	:= &(_cVarCodEnt) 

If Empty(cEntidade)
	MsgInfo("Nenhuma entidade foi selecionada")
	RestArea(aArea)
	Return lRet
EndIf


#IFDEF TOP

	cQuery	:= "SELECT U5_CODCONT,U5_CONTAT,SU5.R_E_C_N_O_ AS RECN FROM " + RetSqlName("SU5") + " SU5 "
	cQuery	+= "INNER JOIN " + RetSqlName("AC8") + " AC8 ON AC8_FILIAL = '"+xFilial("AC8")+"' AND AC8_FILENT = '"+xFilial(cEntidade)+"' "
	cQuery	+= "AND AC8_ENTIDA = '"+cEntidade+"' AND AC8_CODENT = '"+cCodEnt+"' AND AC8_CODCON = U5_CODCONT " 
	cQuery	+= "AND AC8.D_E_L_E_T_ = '' "
	cQuery	+= "WHERE SU5.D_E_L_E_T_ = ''"
	
	cQuery	:= ChangeQuery(cQuery)
	
	If Select(cAliTmp) > 0
		(cAliTmp)->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp,.T.,.T.)
	dbGoTop()
	
	While !(cAliTmp)->(Eof())
		AAdd(aContato,{(cAliTmp)->U5_CODCONT,(cAliTmp)->U5_CONTAT,(cAliTmp)->RECN})
		(cAliTmp)->(DbSkip())
	End
	
	(cAliTmp)->(DbCloseArea())

#ELSE
	    
	nSizeEnt := Len(cCodEnt)
	
	DbSelectArea("SU5")
	DbSetOrder(1)
		
	DbSelectArea("AC8")
	DbSetOrder(2) //AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
	DbSeek(xFilial("AC8")+cEntidade+xFilial(cEntidade)+cCodEnt)
	
	While !AC8->(Eof()) .AND. AC8->AC8_FILIAL == xFilial("AC8") .AND.;
		AC8->AC8_ENTIDA == cEntidade .AND. AC8->AC8_FILENT == xFilial(cEntidade) .AND.;
		Left(AC8->AC8_CODENT,nSizeEnt) == cCodEnt
		
		If SU5->(DbSeek(xFilial("SU5")+AC8->AC8_CODCON))
			AAdd(aContato, { SU5->U5_CODCONT, SU5->U5_CONTAT, SU5->(RECNO()) })
		EndIf
		
		AC8->(DbSkip())

	End
		
#ENDIF


If Len(aContato) == 0
	 aAdd(aContato,{Nil,Nil,Nil})
EndIf

DEFINE MSDIALOG oDlg TITLE "Consulta" FROM 268,260 TO 630,796 PIXEL
    
	//Texto de pesquisa
	@ 003,002 MsGet oPesq Var cPesq Size 219,009 COLOR CLR_BLACK PIXEL OF oDlg

	//Interface para selecao de indice e filtro
	@ 003,228 Button "Pesquisar" Size 037,012 PIXEL OF oDlg	 ACTION IF(!Empty(aTail(oLstBx:aArray[oLstBx:nAt])),FtLbxSk(oLstBx,cPesq),Nil)
							
	//ListBox      
	@ 20,03 LISTBOX oLstBx FIELDS HEADER "Código","Nome" SIZE 264,139 OF oDlg PIXEL
	oLstBx:bLDblClick := bRet
	
	//Botoes inferiores
	DEFINE SBUTTON FROM 162,002 TYPE 1	ENABLE OF oDlg Action(Eval(bRet)) //OK
	DEFINE SBUTTON FROM 162,035 TYPE 2	ENABLE OF oDlg Action(oDlg:End()) //Cancelar 
	DEFINE SBUTTON FROM 162,068 TYPE 4	ENABLE OF oDlg Action IncContato(cEntidade,cCodEnt,oLstBx) //Incluir
	DEFINE SBUTTON FROM 162,102 TYPE 15	ENABLE OF oDlg Action(Eval(bVisual)) //Visualizar
	
	
	//Metodos da ListBox
	oLstBx:SetArray(aContato)
	oLstBx:bLine 	:= {|| {aContato[oLstBx:nAt,1],;
		   					aContato[oLstBx:nAt,2],;
							aContato[oLstBx:nAt,3]}}

ACTIVATE MSDIALOG oDlg CENTERED 

If lRet
	DbSelectArea("SU5")
	DbGoTo(nRecno)
EndIf

If aArea[1] <> "SU5"
	RestArea(aArea)
EndIf

Return lRet


Static Function IncContato(cEntidade,cCodEnt,oLstBx)

Local aAreaSU5  := SU5->(GetArea())		// Guarda area atual
Local aAreaAC8  := AC8->(GetArea())		// Guarda area atual
Local cCodCont  := ""          				// Codigo do Contato
Local cContato  := ""						// Nome do Contato                   
Local nOpcA	    := 0                   		// Confirmou a Inclusao (1=Sim, 2=Nao) 


INCLUI := .T. 

nOpcA 	  := A70INCLUI("SU5",0,3) 
cCodCont  := SU5->U5_CODCONT
cContato  := Alltrim(SU5->U5_CONTAT)
cRecNo	  := SU5->(RECNO())


If nOpcA == 1
	
	DbSelectArea("AC8")
	DbSetOrder(1)
	
	//AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
	If !DbSeek(xFilial("AC8")+cCodCont+cEntidade+xFilial(cEntidade)+cCodEnt)
		RecLock("AC8",.T.)
		REPLACE AC8_FILIAL With xFilial("AC8")
		REPLACE AC8_FILENT With xFilial(cEntidade)
		REPLACE AC8_ENTIDA With cEntidade
		REPLACE AC8_CODENT With cCodEnt
		REPLACE AC8_CODCON With cCodCont
		MsUnLock()
		
		lRet := .T.
		
	EndIf
	
	If Empty(oLstBx:aArray[1][1])
		aDel(oLstBx:aArray,1)
		aSize(oLstBx:aArray,0)
	EndIf 
	
	aAdd(oLstBx:aArray,{cCodCont,cContato,cRecNo})
	oLstBx:Refresh()
	
EndIf

RestArea(aAreaSU5)
RestArea(aAreaAC8)  

Return( .T. )