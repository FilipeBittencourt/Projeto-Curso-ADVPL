#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia020()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CSTRING,CDESC1,CDESC2,CDESC3,TAMANHO,ARETURN")
SetPrvt("NOMEPROG,ALINHA,NLASTKEY,TITULO,CABEC1,CABEC2")
SetPrvt("CABEC3,NBEGIN,CDESCRI,CCANCEL,M_PAG,WNREL")
SetPrvt("LPRIM,LI,WTOT1,WTOT2,WTOT3,WTOT4")
SetPrvt("WQUANT,WQTDREG,WLOCALANT,WLOCALIZ,WALMOX,WPRODUTO")
SetPrvt("WDESCRI,WUM,WSEGUM,WCONV,WFATOR,WQUANTSEG")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ BIA020   ³ Autor ³ ALEXSANDRO DE OLIVEIA  ³ Data ³ 29/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Posicao Detalhada do Estoque                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString  := "SBE"
cDesc1   := "Este programa ira emitir a Posicao Detalhada do Estoque"
cDesc2   := "para a BincoGres conf. Parametros."
cDesc3   := ""
tamanho  := "P"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1,"",0 }
nomeprog := "BIA020"
aLinha   := {}
nLastKey := 0
titulo   := "Posicao Detalhada do Estoque"
cabec1   := "                                             Q U A N T I D A D E"
cabec2   := "PRODUTO  REFERENCIA                                 M2             CX"
cabec3   := ""
nBegin   := 0
cDescri  := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 1                                    // numero da pagina
wnrel    := "BIA020"                             // relatorio em disco
lprim    := .t.
li       := 80

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela padrao de relatorios                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrint(cString,wnrel,"BIA020",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)
If  nLastKey == 27
	Set Filter To
	Return
End
SetDefault(aReturn,cString)
If  nLastKey == 27
	Set Filter To
	Return
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza parametros                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("BIA020",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros        ³
//³ mv_par01  Da Localizacao                    ³
//³ mv_par02  Ate a Localizacao                 ³
//³ mv_par03  Do Produto                        ³
//³ mv_par04  Ate o Produto                     ³
//³ mv_par05  Imprime Saldo Zero                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| Imprime() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> RptStatus({|| Execute(Imprime) })
Roda(0,"","P")
EJECT
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera spool de impressao                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If  aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)    // Chamada do Spool de Impressao
End
MS_FLUSH()             // Libera fila de relatorios em spool

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Programa                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Imprime    ³ Impressao Relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Imprime
Static Function Imprime()

setprc(0,0)
li := 80
wTOT1 := 0
wTOT2 := 0
wTOT3 := 0
wTOT4 := 0
wQuant:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Montagem dos Dados                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SBE")
DbSetOrder(1)
DbSeek(xFilial("SBE")+'02'+MV_PAR01,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tamanho da regua                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wQtdReg := reccount()
SetRegua(wQtdReg)
wLOCALANT := SBE->BE_LOCALIZ+SBE->BE_LOCAL
While SBE->BE_LOCALIZ <= MV_PAR02 .AND. !EOF()
	IncRegua()
	DbSelectArea("SBF")
	DbSetOrder(1)
	DbSeek(xFilial("SBF")+SBE->BE_LOCAL+SBE->BE_LOCALIZ+MV_PAR03,.T.)
	
	If SBF->BF_LOCALIZ+SBF->BF_LOCAL <> SBE->BE_LOCALIZ+SBE->BE_LOCAL
		DbSelectArea("SBE")
		DbSetOrder(1)
		DbSkip()
		Loop
	Endif
	
	While SBF->BF_LOCALIZ+SBF->BF_LOCAL == SBE->BE_LOCALIZ+SBE->BE_LOCAL .and. !Eof()
		
		IF SBF->BF_PRODUTO < MV_PAR03 .OR. SBF->BF_PRODUTO > MV_PAR04
			DbSelectArea("SBF")
			DbSetOrder(1)
			DbSkip()
			Loop
		ENDIF
		
		IF MV_PAR05 == 2
			IF SBF->BF_QUANT == 0
				DbSelectArea("SBF")
				DbSetOrder(1)
				DbSkip()
				Loop
			ENDIF
		ENDIF

		wLOCALIZ  := SUBST(SBE->BE_LOCALIZ,1,7)
		wALMOX    := SBE->BE_LOCAL
		wPRODUTO  := SUBST(SBF->BF_PRODUTO,1,8)
		wQUANT    := SBF->BF_QUANT
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+wProduto)
		
		wDESCRI := Subs(SB1->B1_DESC,1,30)
		wUM     := SB1->B1_UM
		wSEGUM  := SB1->B1_SEGUM
		wCONV   := SB1->B1_CONV
		wFATOR  := SB1->B1_TIPCONV
		
		DO CASE
			CASE wFATOR == "M"
				wQUANTSEG := wQUANT * wCONV
			CASE wFATOR == "D"
				wQUANTSEG := wQUANT / wCONV
		ENDCASE
		
		
		IF SBE->BE_LOCALIZ+SBE->BE_LOCAL <> wLOCALANT .and. li <= 54
			li := li + 2
			@ li , 000 PSAY "LOCAL:"
			@ li , 007 PSAY wLOCALIZ
			@ li , 019 PSAY "ALMOXARIFADO:"
			@ li , 033 PSAY wALMOX
		EndIf
		
		IF li >= 56
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
			@ li , 000 PSAY "LOCAL:"
			@ li , 007 PSAY wLOCALIZ
			@ li , 019 PSAY "ALMOXARIFADO:"
			@ li , 033 PSAY wALMOX
		EndIf
		li := li + 1
		@ li , 000 PSAY wPRODUTO
		@ li , 009 PSAY wDESCRI
		@ li , 040 PSAY wQUANT PICTURE "@E 999,999,999.99"
		//    @ li , 053 PSAY wUM
		@ li , 055 PSAY wQUANTSEG PICTURE "@E 999,999,999.99"
		//    @ li , 069 PSAY wSEGUM
		@ li , 070 PSAY Replicate("_",10)
		
		wTOT1 := wTOT1 + wQUANTSEG
		wTOT2 := wTOT2 + wQUANT
		//wTOT3 := wTOT3 + wTOT1
		//wTOT4 := wTOT4 + wTOT2
		wTOT3 := wTOT3 + wQUANTSEG
		wTOT4 := wTOT4 + wQUANT
		wLOCALANT := SBE->BE_LOCALIZ+SBE->BE_LOCAL
		
		DbSelectArea("SBF")
		SBF->(DbSkip())
	End
	wLOCALANT := SBE->BE_LOCALIZ+SBE->BE_LOCAL
	If wTOT1 > 0 .OR. wTOT2 > 0
		IF li > 56
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
			@ li , 000 PSAY "LOCAL:"
			@ li , 007 PSAY wLOCALIZ
			@ li , 019 PSAY "ALMOXARIFADO:"
			@ li , 033 PSAY wALMOX
		ENDIF
		li := li + 1
		@ li , 000 PSAY "TOTAL LOCAL "+wLOCALIZ+"................."
		@ li , 040 PSAY wTOT2 PICTURE "@E 999,999,999.99"
		@ li , 055 PSAY wTOT1 PICTURE "@E 999,999,999.99"
	Endif
	wTOT1 := 0
	wTOT2 := 0
	
	DbSelectArea("SBE")
	DbSkip()
End
IF li > 56
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
	@ li , 000 PSAY "LOCAL:"
	@ li , 007 PSAY wLOCALIZ
	@ li , 019 PSAY "ALMOXARIFADO:"
	@ li , 033 PSAY wALMOX
ENDIF
li := li + 2
@ li , 000 PSAY "TOTAL GERAL"
@ li , 040 PSAY wTOT4 PICTURE "@E 999,999,999.99"
@ li , 055 PSAY wTOT3 PICTURE "@E 999,999,999.99"

wTOT3 := 0
wTOT4 := 0
Return

