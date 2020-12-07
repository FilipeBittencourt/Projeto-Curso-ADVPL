#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#include "topconn.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UPDCFO    ³ Autor ³ Nereu Humberto Junior ³ Data ³04/12/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de CFOP.                           ³±±
±±³          ³ Atualiza SF4/SC6/SCK                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao do SIGAFIS                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UpdCFO2()

LOCAL nOpca	   :=	0
LOCAL aSays	   :=	{}
LOCAL aButtons :=	{}

AADD(aSays,"Esta rotina ira fazer o De/Para de CFOP")

AADD(aButtons,{ 1,.T.,{|o| nOpca:= 1, o:oWnd:End() }} )
AADD(aButtons,{ 2,.T.,{|o| o:oWnd:End() }} )

FormBatch("De/Para de CFOP",aSays,aButtons,,150,350 ) //190/395
	
IF nOpcA == 1
//	Processa({||FisProcCfo()},,"Atualizando CFOP no cadastro de TES")
	Processa({||AtuCfoP()},,"Atualizando CFOP nos itens do pedido de venda")
Endif	

Aviso("Atencao !!", "Processamento Efetuado com Sucesso !!", {" Ok "})

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtuCfoP  ³ Autor ³ Nereu Humberto Jr.    ³ Data ³05/12/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de De/Para de CFOP na tabela SC6                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FisProcCfo()

dbSelectArea("SF4")
ProcRegua(RecCount())
dbSeek(xFilial("SF4"),.T.)
While !Eof() .And. xFilial("SF4") == SF4->F4_FILIAL
	IncProc("Efetuando De/Para CFOP: "+F4_CF)
	If !Empty(F4_CFNOVO)
		Begin Transaction
		RecLock("SF4",.F.)
		SF4->F4_CF := SF4->F4_CFNOVO
		MsUnlock()
		End Transaction
	EndIf
	dbSkip()
EndDo

Return
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtuCfoP  ³ Autor ³ Nereu Humberto Jr.    ³ Data ³05/12/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de De/Para de CFOP na tabela SC6                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuCfoP()

Local cQuery    := ""
Local cFiltro   := ""
Local cIndex    := ""
Local nIndex
Local cAliasSC6 := ""
Local aArea := GetArea()

dbSelectArea("SC6")
ProcRegua(RecCount())

/*
#IFDEF TOP
	cAliasSC6 := "AliasSC6"
	cQuery    := "SELECT R_E_C_N_O_ AS RECSC6, C6_TES "
	cQuery    += "FROM "+RetSqlName("SC6")+" SC6 "
	cQuery    += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
	cQuery    += "C6_QTDVEN > C6_QTDENT AND "
	cQuery    += "C6_BLQ <> 'R ' AND "
	cQuery    += "SC6.D_E_L_E_T_=' ' "
	
    cQuery    := ChangeQuery(cQuery)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC6,.T.,.T.)
		
	While !Eof()
		IncProc("Atualizando CFOP's dos Pedidos...")
		SC6->(MsGoTo( (cAliasSC6)->RECSC6))
		If SF4->(dbSeek(xFilial("SF4")+(cAliasSC6)->C6_TES)) .And. !Empty(SF4->F4_CFNOVO)
			Begin Transaction
				dbSelectArea("SC6")
				RecLock("SC6",.F.)
				SC6->C6_CF := Left(SC6->C6_CF,1)+Substr(SF4->F4_CF,2,3)
				MsUnlock()
			End Transaction
		Endif
		dbSelectArea(cAliasSC6)
		dbSkip()
	EndDo
	(cAliasSC6)->(dbCloseArea())
#ELSE*/
	cIndex := CriaTrab(,.F.)
	cFiltro := "C6_FILIAL=='"+xFilial("SC6")+"' "
	cFiltro += ".And.C6_QTDVEN > C6_QTDENT "
	cFiltro += ".And.C6_BLQ <> 'R ' "
	cFiltro += ".And. len(Alltrim(C6_CF)) == '3' "
		
	IndRegua("SC6",cIndex,SC6->(IndexKey()),,cFiltro,"Selecionando Registros")
	nIndex := RetIndex("SC6")
		
	dbSelectArea("SC6")
	dbSetIndex(cIndex+OrdBagExt())
	DbSetOrder(nIndex+1)
	DbGoTop()
	While !Eof()
		IncProc("Atualizando CFOP's dos Pedidos...")
		If SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES)) .And. !Empty(SF4->F4_CFNOVO)
			Begin Transaction
				dbSelectArea("SC6")
				Reclock("SC6",.F.)
				SC6->C6_CF := Left(SC6->C6_CF,1)+Substr(SF4->F4_CF,2,3)
				MsUnlock()
			End Transaction
		Endif
		dbSelectArea("SC6")
		dbSkip()
	EndDo
	
	dbSelectArea("SC6")
	Set Filter To
	RetIndex("SC6")
	Ferase(cIndex+OrdBagExt())
//#ENDIF
	
RestArea(aArea)
	
Return