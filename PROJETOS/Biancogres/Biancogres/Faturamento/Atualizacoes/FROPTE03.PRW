#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ FROPTE03 ³ Autor ³ FERNANDO ROCHA        ³ Data ³02/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ REPROGRACAO DE RESERVAS DE OP                   		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ BIANCOGRES                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

User Function FROPTE03(_cOPDoc)
	Local oButCanc
	Local oButOk
	Local oFont1 := TFont():New("Verdana",,018,,.F.,,,,,.F.,.F.)
	Local oSay1
	Local oSBPOp    


	Default _cOPDoc = ""

	Private aSize := MsAdvSize(,.F.)                                     
	Private oGetOP
	Private cGetOP := IIf(Empty(_cOPDoc),Space(11),_cOPDoc)
	Private oGetSld
	Private nGetSld := 0
	Private oGetSldNew
	Private nGetSldNew := 0
	Private oPanelOP
	Private oPanelP
	Private oPanelRes
	Private oPanelRod
	Private oPanelTop
	Private oDlgROP
	Private oListRes
	Private oListOP 
	Private oSaySRES
	Private oSaySOP

	Private aListRes := {}
	Private _lMarcado := .F.
	Private aListOP := {}
	Private	oOk	 		:= LoadBitmap(GetResources(),'LBOK')
	Private	oNo	 		:= LoadBitmap(GetResources(),'LBNO')

	DEFINE MSDIALOG oDlgROP TITLE "Reprogramação de Reservas de OP" FROM aSize[7],000 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL

	@ 000, 000 MSPANEL oPanelTop SIZE 400, 024 OF oDlgROP COLORS 0, 16777215 RAISED
	@ 007, 004 SAY oSay1 PROMPT "Reservas da OP:" SIZE 060, 009 OF oPanelTop FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 006, 063 MSGET oGetOP VAR cGetOP SIZE 054, 010 OF oPanelTop PICTURE "@!" COLORS 0, 16777215 F3 "SC2" PIXEL WHEN (Empty(_cOPDoc))
	DEFINE SBUTTON oSBPOp FROM 006, 122 TYPE 01 OF oPanelTop ENABLE ACTION ( PesqOP(cGetOP) )

	@ 007, 155 SAY oSaySRES PROMPT "Saldo Selecionado:" SIZE 068, 009 OF oPanelTop FONT oFont1 COLORS 0, 16777215 PIXEL
	//@ 007, 293 SAY oSaySOP PROMPT "Saldo Nova OP:" SIZE 059, 009 OF oPanelTop FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 006, 226 MSGET oGetSld VAR nGetSld SIZE 041, 010 OF oPanelTop COLORS 0, 16777215 READONLY PIXEL PICTURE "@E 999,999.99"
	//@ 006, 353 MSGET oGetSldNew VAR nGetSldNew SIZE 041, 010 OF oPanelTop COLORS 0, 16777215 READONLY PIXEL PICTURE "@E 999,999.99"

	@ 024, 000 MSPANEL oPanelP SIZE 400, 205 OF oDlgROP COLORS 0, 16777215 RAISED
	@ 000, 249 MSPANEL oPanelOP SIZE 150, 204 OF oPanelP COLORS 0, 16777215 RAISED
	fListOP()
	@ 000, 000 MSPANEL oPanelRes SIZE 269, 204 OF oPanelP COLORS 0, 16777215 RAISED
	fListRes()
	@ 229, 000 MSPANEL oPanelRod SIZE 400, 020 OF oDlgROP COLORS 0, 16777215 RAISED
	@ 000, 342 BUTTON oButOk PROMPT "REPROGRAMAR" SIZE 057, 019 OF oPanelRod FONT oFont1 ACTION ( IIf(Salvar(),oDlgROP:End(),) ) PIXEL
	@ 000, 284 BUTTON oButCanc PROMPT "CANCELAR" SIZE 057, 019 OF oPanelRod FONT oFont1 PIXEL ACTION ( oDlgROP:End() )

	// Don't change the Align Order
	oPanelTop:Align := CONTROL_ALIGN_TOP
	oPanelRod:Align := CONTROL_ALIGN_BOTTOM
	oPanelP:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelOP:Align := CONTROL_ALIGN_RIGHT
	oPanelRes:Align := CONTROL_ALIGN_ALLCLIENT
	oListRes:Align := CONTROL_ALIGN_ALLCLIENT
	oListOP:Align := CONTROL_ALIGN_ALLCLIENT
	oButOk:Align := CONTROL_ALIGN_RIGHT
	oButCanc:Align := CONTROL_ALIGN_RIGHT

	ACTIVATE MSDIALOG oDlgROP CENTERED ON INIT ( IIf(!Empty(cGetOP), PesqOP(cGetOP), ) )

Return

//------------------------------------------------
Static Function fListOP()
	//------------------------------------------------

	aListOP := {}
	Aadd(aListOP,{.F.,"",ctod(" "),0})

	@ 000, 000 LISTBOX oListOP Fields HEADER "","OP","Dt.Dispo.","Saldo" SIZE 129, 203 OF oPanelOP PIXEL ColSizes 50,50

	fLOPLoad()

	// DoubleClick event
	oListOP:bLDblClick := {|| fLOPMark(oListOP:nAt) }

Return    

Static Function fLOPMark(nPos) 
	Local I

	aListOP[nPos,1] := !aListOP[nPos,1]

	For I := 1 To Len(aListOP)
		If I <> nPos	
			aListOP[I,1] := .F.	
		EndIf 	
	Next I

	oListOP:DrawSelect()
	oListOP:Refresh()
	oDlgROP:Refresh()

Return

Static Function fLOPLoad()

	If Len(aListOP) > 0 .And. Len(aListOP[1]) == 4

		oListOP:SetArray(aListOP)
		oListOP:bLine := {|| {;
		IIf(aListOP[oListOP:nAt,1],oOk,oNo),;
		aListOP[oListOP:nAt,2],;
		aListOP[oListOP:nAt,3],;
		aListOP[oListOP:nAt,4];
		}}

	EndIf

Return

//------------------------------------------------
Static Function fListRes()
	//------------------------------------------------

	aListRes := {}
	Aadd(aListRes,{.F.,ctod(" "),"","","",0,ctod(" "),"",ctod(""),"","","", "", "", ""})

	@ 000, 000 LISTBOX oListRes Fields HEADER "","Emissão","Pedido","Item","Produto","Qtde","Dt.Dispo.","Solicitante","Dt.Sol.","Hr.Sol.","Cliente","Nome","Tp. Seg.", "Categoria", "Cod. Vend." SIZE 268, 250 OF oPanelRes PIXEL ColSizes 10,30,30,20,30,20,30,30,30,20,30,150

	fLResLoad()

	// DoubleClick event
	oListRes:bLDblClick := {|| fLResMark(oListRes:nAt) }

	//Marcar todos
	oListRes:bHeaderClick := { |oObj,nCol| iif( nCol == 1, Eval({|| MarcTudo()}),) }

Return

Static Function fLResMark(nPos)
	Local I 
	Local _nTot := 0

	aListRes[nPos,1] := !aListRes[nPos,1]

	For I := 1 To Len(aListRes)
		If aListRes[I,1]
			_nTot += aListRes[I,6]
		EndIf 	
	Next I

	nGetSld := _nTot
	oGetSld:Refresh()

	oListRes:DrawSelect()
	oListRes:Refresh()
	oDlgROP:Refresh()

	PesqNewOP(aListRes[nPos,5], _nTot)

Return

Static Function MarcTudo()

	Local I
	Local _nTot := 0
	Local _cProd

	_lMarcado := !_lMarcado

	For I := 1 to len(aListRes)         
		aListRes[I][01] := _lMarcado

		If _lMarcado
			_nTot += aListRes[I,6]
			_cProd := aListRes[I,5]
		EndIf

	Next I

	nGetSld := _nTot
	oGetSld:Refresh()

	oListRes:DrawSelect()
	oListRes:Refresh()
	oDlgROP:Refresh()

	If _lMarcado
		PesqNewOP(_cProd, _nTot)
	EndIf

Return


Static Function fLResLoad()

	If Len(aListRes) <= 0
		aListRes := {}
		Aadd(aListRes,{.F.,ctod(" "),"","","",0,ctod(" "),"",ctod(""),"","","", "", "", ""})
	EndIf

	If Len(aListRes) > 0 .And. Len(aListRes[1]) == 15

		oListRes:SetArray(aListRes)
		oListRes:bLine := {|| {;
		IIf(aListRes[oListRes:nAt,1],oOk,oNo),;
		aListRes[oListRes:nAt,2],;
		aListRes[oListRes:nAt,3],;
		aListRes[oListRes:nAt,4],;
		aListRes[oListRes:nAt,5],;
		aListRes[oListRes:nAt,6],;
		aListRes[oListRes:nAt,7],;
		aListRes[oListRes:nAt,8],;
		aListRes[oListRes:nAt,9],;
		aListRes[oListRes:nAt,10],;
		aListRes[oListRes:nAt,11],;
		aListRes[oListRes:nAt,12],;
		aListRes[oListRes:nAt,13],;
		aListRes[oListRes:nAt,14],;
		aListRes[oListRes:nAt,15],;
		}}
		oListRes:Refresh()

	EndIf

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//CARREGAR DADOS DA LISTBOX DE SELECAO DAS RESERVAS
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function PesqOP(_cOpDoc)
	Local _aListRet
	Local I
	Local _aAux

	aListRes := {}
	_aListRet := U_FRTE02LO("", "", "", _cOpDoc, "R")

	If Len(_aListRet) > 0

		FOR I := 1 To Len(_aListRet)

			_aAux := {}
			AAdd(_aAux,.F.)

			SC5->(DbSetOrder(1))
			IF !Empty(_aListRet[I][3]) .And. SC5->(DbSeek(XFilial("SC5")+_aListRet[I][3]))            
				AAdd(_aAux,DTOC(SC5->C5_EMISSAO))
			ELSE
				AAdd(_aAux,DTOC(STOD(_aListRet[I][9])))
			ENDIF				

			AAdd(_aAux,_aListRet[I][3])
			AAdd(_aAux,_aListRet[I][4])
			AAdd(_aAux,_aListRet[I][5])
			AAdd(_aAux,_aListRet[I][6])
			AAdd(_aAux,DTOC(STOD(_aListRet[I][7])))
			AAdd(_aAux,_aListRet[I][8])
			AAdd(_aAux,DTOC(STOD(_aListRet[I][9])))
			AAdd(_aAux,_aListRet[I][10]) 

			__cCli		:= ""
			__cNome		:= ""
			__cTpSeg	:= ""
			__cCateg	:= ""
			__cCodVed	:= ""

			IF !Empty(_aListRet[I][3]) .And. SC5->(DbSeek(XFilial("SC5")+_aListRet[I][3]))
				SA1->(DbSetOrder(1))
				If (SC5->C5_CLIENTE <> "010064" .And. SA1->(DbSeek(XFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)))	.Or. (SC5->C5_CLIENTE == "010064" .And. SA1->(DbSeek(XFilial("SA1")+SC5->C5_YCLIORI+SC5->C5_YLOJORI)))
					__cCli 		:= SA1->A1_COD
					__cNome 	:= SA1->A1_NOME
					__cTpSeg	:= SA1->A1_YTPSEG
					__cCateg	:= SA1->A1_YCAT
					__cCodVed	:= GetVendedor()
				EndIf
			ENDIF

			AAdd(_aAux,__cCli)
			AAdd(_aAux,__cNome)
			AAdd(_aAux,__cTpSeg)
			AAdd(_aAux,__cCateg)
			AAdd(_aAux,__cCodVed)
			

			AAdd(aListRes,_aAux)

		NEXT I

	Else

		aListOP := {}
		Aadd(aListOP,{.F.,"",ctod(" "),ctod(""),0})
		aListRes := {}
		Aadd(aListRes,{.F.,ctod(" "),"","","",0,ctod(" "),"",ctod(""),"","","", "", "", ""})

	EndIf 

	aListRes := ASort(aListRes,,,{|x,y| CTOD(x[2]) < CTOD(y[2]) })

	fLResLoad()

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//CARREGAR DADOS DA LISTBOX DE SELECAO DAS OPS DESTINO
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function PesqNewOP(_cProduto, _nQuant)
	Local _aListOP
	Local _cProduto
	Local I
	Local _aAux

	aListOP := {}
	_aListOP := U_FRRT04PO("", "", _cProduto, _nQuant, "S")

	If Len(_aListOP) > 0

		FOR I := 1 To Len(_aListOP)

			If (AllTrim(cGetOP) <> AllTrim(_aListOP[I][1]+_aListOP[I][2]+_aListOP[I][3]))

				_aAux := {}
				AAdd(_aAux,.F.)
				AAdd(_aAux,_aListOP[I][1]+_aListOP[I][2]+_aListOP[I][3])
				AAdd(_aAux,_aListOP[I][4])
				AAdd(_aAux,_aListOP[I][5])

				AAdd(aListOP,_aAux)

			EndIf

		NEXT I   
		
		aListOP := aSort(aListOP,,,{|x,y| CTOD( DTOC(x[3])) < CTOD( DTOC(y[3]))})  

		If Len(aListOP) <= 0          
			Aadd(aListOP,{.F.,"",ctod(""),0})
		EndIf

	Else

		aListOP := {}
		Aadd(aListOP,{.F.,"",ctod(""),0})

	EndIf

	fLOPLoad()
	oListOP:Refresh()
	oDlgROP:Refresh()

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//SALVAR - MODIFICAR A OP DAS RESERVAS SELECIONADAS
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function Salvar()
	Local I  
	Local nRet
	Local cPedido
	Local cItem
	Local cDocDest
	Local aAreaC6 := SC6->(GetArea())
	Local aAreaC2 := SC2->(GetArea())

	If (aScan(aListRes, {|x| x[1]}) <= 0 .Or. aScan(aListOP, {|x| x[1]}) <=  0)
		U_FROPMSG(TIT_MSG, 	"Selecione as RESERVAS origem e a OP destino para continuar.",,,"Reprogramação de Reservas de OP")
		Return(.F.)
	EndIf

	nRet := U_FROPMSG(TIT_MSG, 	"Tem certeza que deseja REPROGRAMAR as Reservas da OP selecionada?",{"Não","Sim"},,"Confirme:")

	If nRet == 1
		Return(.F.)
	EndIf

	For I := 1 To Len(aListRes) 

		If aListRes[I,1]   

			cPedido := PADR(aListRes[I,3],TamSx3("C6_NUM")[1])
			cItem	:= PADR(aListRes[I,4],TamSx3("C6_ITEM")[1])  

			cDocDest := aListOP[aScan(aListOP, {|x| x[1]})][2]

			PZ0->(DbSetOrder(2))    
			SC2->(DbSetOrder(1))
			If PZ0->(DbSeek(XFilial("PZ0")+cPedido+cItem)) .And. SC2->(DbSeek(XFilial("SC2")+cDocDest))

				Begin Transaction

					U_GravaPZ2(PZ0->(RecNo()),"PZ0",PZ0->(PZ0_FILIAL+PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ),"REPROG",AllTrim(FunName()),"REP", CUSERNAME)

					RecLock("PZ0",.F.)
					PZ0->PZ0_OPNUM 		:= SubStr(cDocDest,1,6) 
					PZ0->PZ0_OPITEM 	:= SubStr(cDocDest,7,2)
					PZ0->PZ0_OPSEQ 		:= SubStr(cDocDest,9,3)
					PZ0->PZ0_DATENT 	:= SC2->C2_YDTDISP
					PZ0->(MsUnlock())

					SC6->(DbSetOrder(1))
					If SC6->(DbSeek(XFilial("SC6")+PZ0->(PZ0_PEDIDO+PZ0_ITEMPV))) 
						RecLock("SC6",.F.)
						SC6->C6_YDTDISP := SC2->C2_YDTDISP
						SC6->(MsUnlock())
					EndIf

				End Transaction

			EndIf		

		EndIf 	

	Next I

	RestArea(aAreaC6)
	RestArea(aAreaC2)
Return(.T.)


Static Function GetVendedor()

	Local cLinha :=  SC5->C5_YLINHA
	
	If Alltrim(cLinha) == "1" //BIANCOGRES
		
		If (!Empty(SA1->A1_VEND))
			Return SA1->A1_VEND
		EndIf
		If (!Empty(SA1->A1_YVENDB2))
			Return SA1->A1_YVENDB2
		EndIf
		If (!Empty(SA1->A1_YVENDB3))
			Return SA1->A1_YVENDB3
		EndIf
		
	ElseIf Alltrim(cLinha) == "2" //INCESA
		
		If (!Empty(SA1->A1_YVENDI))
			Return SA1->A1_YVENDI
		EndIf
		If (!Empty(SA1->A1_YVENDI2))
			Return SA1->A1_YVENDI2
		EndIf
		If (!Empty(SA1->A1_YVENDI3))
			Return SA1->A1_YVENDI3
		EndIf
		
	ElseIf Alltrim(cLinha) == "3" //BELLACASA
		
		If (!Empty(SA1->A1_YVENBE1))
			Return SA1->A1_YVENBE1
		EndIf
		If (!Empty(SA1->A1_YVENBE2))
			Return SA1->A1_YVENBE2
		EndIf
		If (!Empty(SA1->A1_YVENBE3))
			Return SA1->A1_YVENBE3
		EndIf
		
	ElseIf Alltrim(cLinha) == "4" //MUNDIALLI
		
		If (!Empty(SA1->A1_YVENML1))
			Return SA1->A1_YVENML1
		EndIf
		If (!Empty(SA1->A1_YVENML2))
			Return SA1->A1_YVENML2
		EndIf
		If (!Empty(SA1->A1_YVENML3))
			Return SA1->A1_YVENML3
		EndIf
		
	EndIf
	
Return ""
