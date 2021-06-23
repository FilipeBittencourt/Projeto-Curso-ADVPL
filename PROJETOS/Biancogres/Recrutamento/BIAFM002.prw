/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |BIAFM002   | Autor | Marcelo Sousa        | Data | 31.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |GRID PARA ESCOLHA DE QUAIS ACESSOS SERÃO NECESSÁRIOS          |
|          |NO CADASTRAMENTO DA VAGA.									  |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEÇÃO                                        |
+----------+-------------------------------------------------------------*/
#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"



User Function BIAFM002()
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Local nI
	Private lRefresh := .T.
	Private _aCols := {}
	Private nMax 			:= 999
	Private oGetD
	Private oDlg
	_aCols := {}
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Verificando se há algum acesso na vaga, caso seja edição                ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	dbSelectArea("ZR1")
	dbSetOrder(1)
	dbSeek(xFilial("ZR1")+SQS->QS_VAGA)
	
	While !eof() .and. ZR1->ZR1_VAGA == SQS->QS_VAGA
		
		AADD(_aCols,{ZR1_ITEM,ZR1_TIPO,ZR1_DESC,ZR1_OBS,.F.})
		
		dbSkip()
	
	Enddo
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Montando o GRID com os dados.                                           ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oDlg := MSDIALOG():New(0,0,300,1200, "Acessos para a Vaga",,,,,,,,,.T.)
	oGetD:= MsNewGetDados():New( 053, 078, 415, 775,GD_INSERT+GD_DELETE+GD_UPDATE,,,, {"ZR1_TIPO","ZR1_DESC","ZR1_OBS"}, , nMax,,,, oDLG, GetFieldProperty(), _aCols)
	oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	EnchoiceBar(oDlg, {|| fGrava(),oDlg:END() }, {|| oDlg:END() },,)
	
	ACTIVATE MSDIALOG oDlg CENTERED
	

	
Return                                                                                 

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Funcao que busca a propriedade dos campos para montagem do grid.        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static function GetFieldProperty() 

	oField := TGDField():New()

	oField:Clear()

	// Adciona coluna para tratamento de marcacao no grid
	oField:AddField("ZR1_ITEM") 	
	
	oField:AddField("ZR1_TIPO")
	
	oField:AddField("ZR1_DESC")
	
	oField:AddField("ZR1_OBS")
	
Return(oField:GetHeader())

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Funcao que grava os dados de acesso na tabela ZR1                       ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fGrava()

	Local n := 0
	Local cCont	:= 0
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Buscando os dados para refazer a tabela.                                ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	For n := 1 to Len(oGetD:aCols)
	
		dbSelectArea("ZR1")
		dbSetOrder(1)
		dbSeek(xFilial("ZR1")+SQS->QS_VAGA)
			
		IF !eof() .and. ZR1->ZR1_VAGA == SQS->QS_VAGA
			
			Reclock("ZR1",.F.)
			ZR1->(DBDELETE())
			ZR1->(MsUnlock())
		
		ENDIF 
	
	NEXT
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Gravando os dados atualizados na tabela.                                ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/	
	For n := 1 to Len(oGetD:aCols)
		
		dbSelectArea("ZR1")
		dbSetOrder(1)
		dbSeek(xFilial("ZR1")+M->QS_VAGA)
		
		
		
		Reclock("ZR1",.T.)
		
		ZR1->ZR1_VAGA := M->QS_VAGA 
		ZR1->ZR1_ITEM := strzero(n,3)  
		ZR1->ZR1_TIPO := GDFIELDGET("ZR1_TIPO",n,,oGetD:aheader,oGetD:aCols)
		ZR1->ZR1_DESC := GDFIELDGET("ZR1_DESC",n,,oGetD:aheader,oGetD:aCols)
		ZR1->ZR1_OBS  := GDFIELDGET("ZR1_OBS",n,,oGetD:aheader,oGetD:aCols)
		
		ZR1->(MsUnlock())
			
		ZR1->(DBCLOSEAREA())
		
	Next


Return