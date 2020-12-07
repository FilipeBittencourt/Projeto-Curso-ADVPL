#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ FROPTE09 ³ Autor ³ FERNANDO ROCHA        ³ Data ³10/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ MANUTENCAO DE RESERVAS DE OP							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ BIANCOGRES                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FROPTE09
Local aArea 	:= GetArea()

//Variaveis Private da Rotina
Private	cCadastro     := "Manutenção de Reservas de OP" //Define Nome da Tela

PZ0->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define procedures para cada botao                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina   := { 	{"Pesquisar"    	,"AxPesqui"      		,0,1},;
				{"Visualizar"     	,"AxVisual"		      	,0,2},;
				{"Incluir"     		,"U_FRPT9INC"    	  	,0,3},;
				{"Alterar"      	,"U_FRPT9ALT"      		,0,4},;
				{"Excluir"      	,"U_FRPT9DEL"      		,0,5}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela de browse e executra mBrowse                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PZ0->(MBrowse(6,1,22,75,"PZ0",,,,,,/*aCores*/))

//Recupera area de trabalho
RestArea(aArea)
Return  

User Function FRPT9INC(cAlias, nReg, nOpc)
Local bCampo
Local lDeleta := .T.
Local oDlg
Local nCont
Local nOpca

Private aTELA[0][0],aGETS[0]

dbSelectArea( cAlias )
RegToMemory( cAlias, .T. )
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
EnChoice( cAlias, nReg, nOpc,,,,{"PZ0_OPNUM","PZ0_OPITEM","PZ0_OPSEQ","PZ0_CODPRO","PZ0_PEDIDO","PZ0_ITEMPV","PZ0_QUANT","PZ0_DATENT","NOUSER"},)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
DbSelectArea(cAlias)
IF nOpcA == 2

	If !Empty(M->PZ0_OPNUM) .And. !Empty(M->PZ0_OPITEM) .And. !Empty(M->PZ0_OPSEQ) .And. !Empty(M->PZ0_CODPRO) .And. !Empty(M->PZ0_QUANT)
	
		RecLock("PZ0",.T.) 
		PZ0->PZ0_FILIAL 	:= XFilial("PZ0")
		PZ0->PZ0_OPNUM 		:= M->PZ0_OPNUM
		PZ0->PZ0_OPITEM 	:= M->PZ0_OPITEM
		PZ0->PZ0_OPSEQ 		:= M->PZ0_OPSEQ
		PZ0->PZ0_CODPRO 	:= M->PZ0_CODPRO
		PZ0->PZ0_PEDIDO 	:= M->PZ0_PEDIDO
		PZ0->PZ0_ITEMPV 	:= M->PZ0_ITEMPV
		PZ0->PZ0_QUANT 		:= M->PZ0_QUANT
		PZ0->PZ0_DATENT 	:= M->PZ0_DATENT
		
		PZ0->PZ0_STATUS 	:= "M"
		PZ0->PZ0_DATINC 	:= dDataBase
		PZ0->PZ0_HORINC 	:= SubStr(Time(),1,5)
		PZ0->PZ0_USUINC 	:= CUSERNAME
		
		PZ0->(MsUnlock())
		
		MsgInfo("Inclusão realizada com sucesso!") 
	
	Else                                        
	
		MsgAlert("Campos obrigatórios não preenchidos: OP, produto, quantidade.","Atenção") 
	
	EndIf
      
ENDIF

Return


User Function FRPT9ALT(cAlias, nReg, nOpc)
Local nOpcao 
Local aPergs := {}
Local cCodMot := space(03)
Local aRet := {""}
Local lRet

aAdd( aPergs ,{1,"Código do Motivo: ",cCodMot,"@!", "U_BIAF096(MV_PAR01)", "ZZ",".T.",10,.T.})

If ParamBox(aPergs ,"Motivo de Alteracao da Reserva",aRet,,,,,,,,.F.,.F.)
	cCodMot := aRet[1]
Else
	Return
EndIf

BEGIN TRANSACTION

GravPZ3(.T.,cCodMot)

nOpcao := AxAltera(cAlias,nReg,nOpc) 

If nOpcao == 1                                 
	MsgInfo("Alteração realizada com sucesso!") 
Else
	DisarmTransaction()
EndIf

END TRANSACTION

Return

User Function FRPT9DEL(cAlias, nReg, nOpc)
Local nOpcao
Local aPergs := {}
Local cCodMot := space(03)
Local aRet := {""}
Local lRet

aAdd( aPergs ,{1,"Código do Motivo: ",cCodMot,"@!", "U_BIAF096(MV_PAR01)", "ZZ", ".T.",10,.T.})

If ParamBox(aPergs ,"Motivo de Exclusao da Reserva",aRet,,,,,,,,.F.,.F.)
	cCodMot := aRet[1]
Else
	Return
EndIf

BEGIN TRANSACTION

GravPZ3(.F.,cCodMot)

nOpcao := AxDeleta(cAlias,nReg,nOpc) 

If nOpcao == 2
	MsgInfo("Exclusao realizada com sucesso!") 
Else
	DisarmTransaction()
EndIf

END TRANSACTION

Return

Static Function GravPZ3(lAlt,cCodMot)

RecLock("PZ2",.T.)  
PZ2->PZ2_FILIAL 	:= PZ0->PZ0_FILIAL 
PZ2->PZ2_ID			:= AllTrim(Str(PZ0->(RecNo())))
PZ2->PZ2_CODENT		:= "PZ0"
PZ2->PZ2_CHVENT		:= ""
PZ2->PZ2_CAMPO		:= IIf(lAlt,"PZ0ALT","PZ0EXC")
PZ2->PZ2_CONT		:= ""
PZ2->PZ2_DATA		:= dDataBase
PZ2->PZ2_HORA		:= SubStr(Time(),1,5)
PZ2->PZ2_CODMOT 	:= cCodMot
PZ2->PZ2_USURES 	:= CUSERNAME
PZ2->(MsUnlock())

RecLock("PZ3",.T.)
PZ3->PZ3_FILIAL 	:= PZ0->PZ0_FILIAL
PZ3->PZ3_ID 		:= AllTrim(Str(PZ0->(RecNo())))
PZ3->PZ3_OPNUM 		:= PZ0->PZ0_OPNUM
PZ3->PZ3_OPITEM 	:= PZ0->PZ0_OPITEM
PZ3->PZ3_OPSEQ 		:= PZ0->PZ0_OPSEQ
PZ3->PZ3_CODPRO 	:= PZ0->PZ0_CODPRO
PZ3->PZ3_PEDIDO 	:= PZ0->PZ0_PEDIDO
PZ3->PZ3_ITEMPV 	:= PZ0->PZ0_ITEMPV
PZ3->PZ3_QUANT 		:= PZ0->PZ0_QUANT
PZ3->PZ3_DATINC 	:= PZ0->PZ0_DATINC
PZ3->PZ3_HORINC 	:= PZ0->PZ0_HORINC
PZ3->PZ3_DATENT 	:= PZ0->PZ0_DATENT
PZ3->PZ3_DATEXC 	:= dDataBase
PZ3->PZ3_HOREXC 	:= SubStr(Time(),1,5)
PZ3->(MsUnlock())

Return