#include "rwmake.ch"
#include "topconn.ch"

User Function Mata103()

Return()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("WALIAS,WDOC,WSERIE,WFORNECE,WLOJA,WEMISSAO")
SetPrvt("WVLRISS,WVLRIRF,WVLRINSS,WVALOR,WTOTAL,WISS")
SetPrvt("WIRF,WINSS,WDTISS,WDTIRF,WDTINSS,WDIAISS")
SetPrvt("CARQSB1,CARQSX6,CARQSE2,CARQSD1,CINDSD1,CREGSD1")
SetPrvt("LERRO,CINDSX6,CREGSX6,WNUMSE2,WVENCIRF,CINDSE2")
SetPrvt("CREGSE2,WVENCREA,WVENCTO,WDIA,WMES,WANO")
SetPrvt("WDIAS,WGRAVAISS,WGRAVAIRF,WGRAVAINSS,WALIAS1,AHEADER")
SetPrvt("ACOLS,XACHOU,_XREG,WPREFMARC,WNUMEMARC,WPARCMARC")
SetPrvt("WULTPREF,WULTNUM,WULTPARC,WULTVENC,DDTVLD,_DATA")
SetPrvt("MES,DIA,ANO,NOVADATA,WSERORI,WNUMORI,WFORORI,WLOJORI")
Private wPerl1 := 0, wPerl2 := 0
/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 � MATA100	  � Autor � MICROSIGA VITORIA     � Data � 09/04/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Entrada de Mercadorias e Servicos. Calculo ISS, IRF e INSS   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � Interpretador x Base 										낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
_PROV()
wAlias := Alias()
If Inclui
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Define Variaveis  												   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	wDoc    := SF1->F1_DOC		  // Numero da Nota Fiscal
	wSerie  := SF1->F1_SERIE	  // Serie da Nota Fiscal
	wFornece:= SF1->F1_FORNECE   // Fornecedor da Nota Fiscal
	wLoja   := SF1->F1_LOJA 	  // Loja do Fornecedor
	wNumOri := SF1->F1_DOC		  // Numero da Nota Fiscal
	wSerOri := SF1->F1_SERIE	  // Serie da Nota Fiscal
	wForOri := SF1->F1_FORNECE   // Fornecedor da Nota Fiscal
	wLojOri := SF1->F1_LOJA 	  // Loja do Fornecedor
	wEmissao:= ddatabase 		  // Emissao
	wVlrISS := 0					  // Valor Apurado do ISS
	wVlrIRF := 0					  // Valor Apurado do IRF
	wVlrINSS:= 0					  // Valor Apurado do INSS
	wValor  := 0					  // Valor Total da Nota Fiscal
	wTotal  := 0					  // Valor Total da Nota Fiscal menos os impostos
	wISS	:= ""                // Natureza de ISS
	wIRF	:= ""                // Natureza de IRF
	wINSS   := ""                // Natureza de INSS
	wDtISS  := CtoD("  /  /  ")  // Data Pagamento do ISS
	wDtIRF  := CtoD("  /  /  ")  // Data Pagamento do IRF
	wDtINSS := CtoD("  /  /  ")  // Data Pagamento do INSS
	wDIAISS := ""                // Dia do Pagamento do ISS
	cArqSB1 := ""
	cArqSX6 := ""
	cArqSE2 := ""
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Calcula valores de ISS, IRF e INSS 						           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SD1")
	cArqSD1 := Alias()
	cIndSD1 := IndexOrd()
	cRegSD1 := Recno()
	DbSetOrder(1)
	If DbSeek(xFilial("SD1")+wDoc+wSerie+wFornece+wLoja,.t.)
		Do While ! Eof() .And. SD1->D1_DOC		== wDoc		.And. ;
			SD1->D1_SERIE	== wSerie	.And. ;
			SD1->D1_FORNECE == wFornece .And. ;
			SD1->D1_LOJA 	== wLoja
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Acumula ISS										             �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If SD1->D1_YISS <> 0
				wVlrISS := wVlrISS + Round(((SD1->D1_YISS/100) * SD1->D1_TOTAL),2)
			End
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Acumula IRF													 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If SD1->D1_YIRF <> 0
				wVlrIRF := wVlrIRF + Round(((SD1->D1_YIRF/100) * SD1->D1_TOTAL),2)
			End
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Acumula INSS												 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If SD1->D1_YINSS <> 0
				wVlrINSS := wVlrINSS + Round(((SD1->D1_YINSS/100) * SD1->D1_TOTAL),2)
			End
			wValor := wValor + SD1->D1_TOTAL
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Proximo registro 											 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			DbSelectArea("SD1")
			DbSetOrder(1)
			dbSkip()
		EndDo
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Naturezas, valores e datas de vencimento 						   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	//If wVlrISS + wVlrIRF + wVlrINSS > 0
	lErro := .f.
	DbSelectArea("SX6")
	cArqSX6 := Alias()
	cIndSX6 := IndexOrd()
	cRegSX6 := Recno()
	DbSetOrder(1)
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Numero dos documentos a serem gravados no SE2                   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	wNumSE2 :=  GetMv("MV_YNUMSE2")
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Dia Vencimento ISS									            �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If DbSeek(xFilial("SX6")+"MV_DIAISS ",.t.)       // Dia pagamento ISS
		wDIAISS := Strzero(Val(Alltrim(SX6->X6_CONTEUD)),2,0)
		//alert("wDIAISS "+wDIAISS)
	Else
		MsgBox("Parametro MV_DIAISS nao encontrado","Parametro nao encontrado","STOP")
		lErro := .t.
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Se o IRF sera gerado pela (E)missao, (V)encto ou (C)ontabil.	�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//If ! DbSeek(xFilial("SX6")+"MV_VENCIRF ",.t.)   // Vencimento IRF
	//   wVENCIRF := Alltrim(SX6->X6_CONTEUD)
	//Else
	//   MsgBox("Parametro MV_VENCIRF nao encontrado","Parametro nao encontrado","STOP")
	//   lErro := .t.
	//EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Naturezas													    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If DbSeek(xFilial("SX6")+"MV_ISS    ",.t.)       // Natureza ISS
		wISS := Alltrim(SX6->X6_CONTEUD)
	Else
		MsgBox("Parametro MV_ISS nao encontrado","Parametro nao encontrado","STOP")
		lErro := .t.
	EndIf
	If DbSeek(xFilial("SX6")+"MV_IRF    ",.t.)       // Natureza IRF
		wIRF := Alltrim(SX6->X6_CONTEUD)
	Else
		MsgBox("Parametro MV_IRF nao encontrado","Parametro nao encontrado","STOP")
		lErro := .t.
	EndIf
	If DbSeek(xFilial("SX6")+"MV_INSS   ",.t.)       // Natureza INSS
		wINSS := Alltrim(SX6->X6_CONTEUD)
	Else
		MsgBox("Parametro MV_INSS nao encontrado","Parametro nao encontrado","STOP")
		lErro:= .t.
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Vencimento do ISS, IRF e INSS								    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If ! lErro
		DbSelectArea("SE2")
		cArqSE2 := Alias()
		cIndSE2 := IndexOrd()
		cRegSE2 := Recno()
		DbSetOrder(6)
		If  DbSeek(xFilial("SE2")+wFornece+wLoja+wSerie+wDoc,.t.)
			wperl1 := SE2->E2_YPLIN1
			wperl2 := SE2->E2_YPLIN2
			wVencrea:= dtos(SE2->E2_VENCREA)
			wVencto := SE2->E2_VENCREA
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Vencimento do ISS										 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			//If wVlrISS > 0
			wDia 	:= Val(Subs(wVencrea,7,2))
			wMes 	:= Val(Subs(wVencrea,5,2))
			wAno 	:= Val(Subs(wVencrea,3,2))
			If wDia > 5
				wMes := wMes + 1
				If wMes > 12
					wMes := 1
					wAno := wAno + 1
				EndIf
			EndIf
			wDtISS := CtoD("05/"+Strzero(wMes,2,0)+"/"+Strzero(wAno,2,0))
			//alert("wDtISS "+dtoc(wDtISS))
			//EndIf
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Vencimento do IRF										 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			//If wVlrIRF	> 0
			//alert(str(dow(wVencto),2,0))
			wDias	 := 11 - dow(wVencto)									  // Quarta-feira da semana subsequente
			wDtIRF	 := wVencto + wDias
			//alert("wDtIRF "+dtoc(wDtIRF))
			//EndIf
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Vencimento do INSS 										 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			//If wVlrINSS > 0
			wDia 	:= Val(Subs(wVencrea,7,2))
			wMes 	:= Val(Subs(wVencrea,5,2))
			wAno 	:= Val(Subs(wVencrea,3,2))
			If wDia > 2
				wMes := wMes + 1
				If wMes > 12
					wMes := 1
					wAno := wAno + 1
				EndIf
			EndIf
			wDtINSS := CtoD("02/"+Strzero(wMes,2,0)+"/"+Strzero(wAno,2,0))
			//EndIf
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Mostra a tela para iteracao do usuario					 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			@ 96,42 TO 300,505 DIALOG oDlg1 TITLE "Impostos sobre Servico"
			//@ 8,10 TO 84,222
			@ 03,14 SAY "Nota Fiscal: "+wDoc+" Serie: "+wSerie+" Fornecedor: "+wFornece+"-"+wLoja
			@ 23,14 SAY "Valor da Nota Fiscal "
			@ 43,14 SAY "Total do ISS         "
			@ 53,14 SAY "Total do IRF         "
			@ 63,14 SAY "Total do INSS        "
			@ 83,14 SAY "Total da Nota Fiscal "
			@ 23,070 GET wValor 		Picture "@E 999,999,999.99" Size 60,100 When wValor == 0
			@ 43,070 GET wVlrISS		Picture "@E 999,999,999.99" Size 60,100 Valid Ac_Valor()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 					 @ 43,070 GET wVlrISS		Picture "@E 999,999,999.99" Valid Execute(Ac_Valor)
			@ 43,145 GET wDtISS Size 60,100
			@ 53,070 GET wVlrIRF		Picture "@E 999,999,999.99" Size 60,100  Valid Ac_Valor()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 					 @ 53,070 GET wVlrIRF		Picture "@E 999,999,999.99" Valid Execute(Ac_Valor)
			@ 53,145 GET wDtIRF Size 60,100
			@ 63,070 GET wVlrINSS		Picture "@E 999,999,999.99" Size 60,100 Valid Ac_Valor()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 					 @ 63,070 GET wVlrINSS		Picture "@E 999,999,999.99" Valid Execute(Ac_Valor)
			@ 63,145 GET wDtINSS Size 60,100
			@ 43,182 GET wISS	Size 60,100 		When	  wISS	 <> ""
			@ 53,182 GET wIRF	Size 60,100 		When	  wIRF	 <> ""
			@ 63,182 GET wINSS	Size 60,100 		When	  wINSS	 <> ""
			
			wTotal := wValor-wVlrISS-wVlrIRF-wVlrINSS
			
			@ 83,070 GET wTotal Size 60,100 		Picture "@E 999,999,999.99" When wTotal == 0
			@ 83,170 BMPBUTTON TYPE 1 ACTION FGrava()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 					 @ 83,170 BMPBUTTON TYPE 1 ACTION Execute(FGrava)
			@ 83,200 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
			ACTIVATE DIALOG oDlg1 CENTERED
		Else
			MsgBox("Nota Fiscal nao gerou financeiro","Financeiro nao gerado","ALERT")
		EndIf
	EndIf
	//EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica se e uma Nota Fiscal de Devolucao, se a NF original nao ..�
	//� foi embarcada e deleta os romaneios.                               �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if SF1->F1_TIPO == "D"
		DbSelectArea("SF2")
		DbSetOrder(1)
		if DBSeek(xFilial("SF2")+SF1->F1_NFORI+SF1->F1_SERIORI)
			if Empty(SF2->F2_YDES)
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//� Deleta os Romaneios.                                                �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				cQuery := ""
				cQuery += "UPDATE SZ9010                          "
				cQuery += "SET D_E_L_E_T_ = '*'                   "
				cQuery += "WHERE Z9_NUMERO = '"+SF2->F2_YAGREG+"'"
				TCSQLEXEC(cQuery)
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//� Deleta os Romaneios.                                                �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				cQuery := ""
				cQuery += "UPDATE SZ7010                         "
				cQuery += "SET D_E_L_E_T_ = '*'                  "
				cQuery += "WHERE Z7_ROMAN = '"+SF2->F2_YAGREG+"'"
				TCSQLEXEC(cQuery)
			endif
		endif
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Finalizacao do programa											   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	dbSelectArea(wAlias)
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Fechamento do SB1												   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If alltrim(cArqSB1) <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Fechamento do SX6												   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If alltrim(cArqSX6) <> ""
		dbSelectArea(cArqSX6)
		dbSetOrder(cIndSX6)
		dbGoTo(cRegSX6)
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Fechamento do SE2												   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If alltrim(cArqSE2) <> ""
		dbSelectArea(cArqSE2)
		dbSetOrder(cIndSE2)
		dbGoTo(cRegSE2)
	EndIf
EndIf

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 � FGrava	� Autor � MICROSIGA VITORIA	    � Data � 09/04/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Grava SE2												  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � Generico RDMAKE											  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function FGrava
Static Function FGrava()
wGravaISS  := "N"
wGravaIRF  := "N"
wGravaINSS := "N"
AcertaSE2()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Grava titulo ISS 											          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If wVlrISS	> 0
	wGravaISS  := "S"
	GravaSE2()
	wGravaISS  := "N"
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Grava titulo IRF 													  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If wVlrIRF	> 0
	wGravaIRF  := "S"
	GravaSE2()
	wGravaIRF  := "N"
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Grava titulo INSS													  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If wVlrINSS > 0
	wGravaINSS := "S"
	GravaSE2()
	wGravaINSS := "N"
EndIf

Close(oDlg1)

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 � AcertaSE2� Autor � MICROSIGA VITORIA	    � Data � 09/04/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Acerta SE2 original										  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � Generico RDMAKE											  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function AcertaSE2
Static Function AcertaSE2()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Atualizar SE2													     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("SE2")
cArqSE2 := Alias()
cIndSE2 := IndexOrd()
cRegSE2 := Recno()
DbSetOrder(6)
//alert(wFornece+wLoja+wSerie+wDoc)
If DbSeek(xFilial("SE2")+wFornece+wLoja+wSerie+wDoc,.t.)
	Reclock("SE2",.f.)
	SE2->E2_VALOR   := SE2->E2_VALOR  - wVlrISS - wVlrIRF - wVlrINSS
	SE2->E2_SALDO   := SE2->E2_SALDO  - wVlrISS - wVlrIRF - wVlrINSS
	SE2->E2_VLCRUZ  := SE2->E2_VLCRUZ - wVlrISS - wVlrIRF - wVlrINSS
	SE2->E2_ISS	    := IIF(wVlrISS>0,wVlrISS,0)
	SE2->E2_IRRF    := IIF(wVlrIRF>0,wVlrIRF,0)
	SE2->E2_INSS    := IIF(wVlrINSS>0,wVlrINSS,0)
	SE2->E2_PARCIR  := IIF(wVlrIRF>0,"1"," ")
	SE2->E2_PARCISS := IIF(wVlrISS>0,"1"," ")
	MsUnlock()
Else
	msgbox("Nao achou SE2")
EndIf
Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 � GravaSE2 � Autor � MICROSIGA VITORIA     � Data � 09/04/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Grava Titulos no SE2 de ISS, IRF e INSS                    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � Generico RDMAKE										              낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function GravaSE2
Static Function GravaSE2()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Grava os dados no SE2.												             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Reclock("SE2",.t.)
SE2->E2_FILIAL  := xFilial("SE2")
SE2->E2_PREFIXO := wSerie
SE2->E2_NUM     := StrZero(wNumSE2,6,0)
//SE2->E2_PARCELA := IIF(wGravaIRF=="S"," "," ")
SE2->E2_PARCELA := " "
SE2->E2_TIPO	:= IIF(wGravaISS=="S","ISS"   ,IIF(wGravaIRF=="S","TX "   ,"INS"   ))
SE2->E2_NATUREZ := IIF(wGravaISS=="S","2802"  ,IIF(wGravaIRF=="S","2801"  ,"2602"  ))
SE2->E2_FORNECE := IIF(wGravaISS=="S","MUNIC ",IIF(wGravaIRF=="S","UNIAO ","INPS  "))
SE2->E2_LOJA	  := "00"
SE2->E2_NOMFOR  := IIF(wGravaISS=="S","MUNICIPIO",IIF(wGravaIRF=="S","UNIAO    ","INPS     "))
SE2->E2_EMISSAO := wEmissao
SE2->E2_VENCTO  := IIF(wGravaISS=="S",wDtISS,IIF(wGravaIRF=="S",wDtIRF,wDtINSS))
SE2->E2_VENCREA := IIF(wGravaISS=="S",datavalida(wDtISS),IIF(wGravaIRF=="S",datavalida(wDtIRF),datavalida(wDtINSS)))
SE2->E2_VALOR   := IIF(wGravaISS=="S",wVlrISS,IIF(wGravaIRF=="S",wVlrIRF,wVlrINSS))
SE2->E2_EMIS1   := wEmissao
SE2->E2_SALDO   := IIF(wGravaISS=="S",wVlrISS,IIF(wGravaIRF=="S",wVlrIRF,wVlrINSS))
SE2->E2_VENCORI := IIF(wGravaISS=="S",wDtISS,IIF(wGravaIRF=="S",wDtIRF,wDtINSS))
SE2->E2_MOEDA   := 1
SE2->E2_VLCRUZ  := IIF(wGravaISS=="S",wVlrISS,IIF(wGravaIRF=="S",wVlrIRF,wVlrINSS))
SE2->E2_ORIGEM  := "MATA100"
SE2->E2_YPREORI := wSerOri
SE2->E2_YNUMORI := wNumOri
SE2->E2_YFORORI := wForOri
SE2->E2_YLOJORI := wLojOri
SE2->E2_YPLIN1  := wperl1
SE2->E2_YPLIN2  := wperl2
SE2->E2_FILORIG  := xFilial("SE2")
MsUnlock()
wNumSE2 := wNumSE2 + 1
DbSelectArea("SX6")
If DbSeek(xFilial("SX6")+"MV_YNUMSE2",.F.)
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := StrZero(wNumSE2,6,0)
	MsUnLock()
Endif
DbSelectArea("SE2")
Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 � Ac_valor � Autor � MICROSIGA VITORIA	    � Data � 09/04/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Total final do titulo descontando-se ISS, IRF e INSS		  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � Generico RDMAKE										      낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Ac_valor
Static Function Ac_valor()
wTotal := wValor - wVlrISS - wVlrIRF - wVlrINSS
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function _PROV
Static Function _PROV()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Salva dados de entrada 												     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wAlias1 := alias()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta aHeader - Cabecalho do MultiLine									 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aHeader := {}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Acessa SX3 																 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("SX3")
DbSetOrder(2)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta aHeader com campos do SX3 										 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSeek("E2_PREFIXO") ; AADD(aHeader,{ AllTrim(X3_TITULO) , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E2_NUM")     ; AADD(aHeader,{ AllTrim(X3_TITULO) , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E2_PARCELA") ; AADD(aHeader,{ AllTrim(X3_TITULO) , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E2_VENCTO")  ; AADD(aHeader,{ AllTrim(X3_TITULO) , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E2_HIST")    ; AADD(aHeader,{ AllTrim(X3_TITULO) , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E2_VALOR")   ; AADD(aHeader,{ AllTrim(X3_TITULO) , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta aCols - Linhas da Coluna											 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aCols  := {}
xAchou := .F.
DbSelectArea("SE2")
_xreg  := RECNO()
DbSetOrder(6)
DbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA)
While SE2->E2_FORNECE+SE2->E2_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA
	
	IF SE2->E2_TIPO <> "PR"
		DbSelectArea("SE2")
		DbSkip()
		Loop
	ENDIF
	
	IF SE2->E2_SALDO <> SE2->E2_VALOR
		DbSelectArea("SE2")
		DbSkip()
		Loop
	ENDIF
	
	xAchou := .T.
	Aadd(aCols,{SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_VENCTO,SE2->E2_HIST,SE2->E2_VALOR})
	
	DbSelectArea("SE2")
	DbSkip()
END
If ! xAchou
	DbSelectArea(wAlias1)
	DbSelectArea("SX3")
	DbSetOrder(1)
	Go _xreg
	Return
EndIf
aCols := Asort(aCols,,, { |x, y| x[4] < y[4] })

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Monta Dialogo 													    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
@ 038,000 to 324,500 Dialog oDlg1 Title "Alteracao de Titulos Provisorios"
@ 010,010 Say "No Quadro Abaixo Estao os Titulos Provisorios Encontrados Para"
@ 020,010 Say "Este Fornecedor. Caso Queira Redefinir a Data de Vencimento do"
@ 030,010 Say "Titulo  Provisorio,  Posicione o Cursor na Linha do  Titulo  e"
@ 040,010 Say "Pressione Ok. Se Nao For Alterar Nada, Pressione Cancelar."

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Executa o MultiLine 												�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
@ 055,010 TO 100,220 MULTILINE

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Monta Botoes														�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
@ 120,150 BmpButton Type 1 Action fAltera()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> @ 120,150 BmpButton Type 1 Action Execute(fAltera)
@ 120,180 BmpButton Type 2 Action Close(oDlg1)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Ativa o dialogo														�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Activate Dialog oDlg1
DbSelectArea("SE2")
Go _xreg
Return

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Funcao fAltera													    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fAltera
Static Function fAltera()

wPrefMarc := ACOLS[N,1]
wNumeMarc := ACOLS[N,2]
wParcMarc := ACOLS[N,3]

wUltPref := ACOLS[N,1]
wUltNum	:= ACOLS[N,2]
wUltParc := ACOLS[N,3]
wUltVenc := ACOLS[N,4]
Somames()
DbSelectArea("SE2")
DbSetOrder(1)
IF DbSeek(xFilial("SE2")+wPrefMarc+wNumeMarc+wParcMarc+"PR "+SF1->F1_FORNECE+SF1->F1_LOJA)
	While ! Reclock("SE2",.F.) ; End
	SE2->E2_VENCTO := novadata
	dDtVld := DataValida(SE2->E2_VENCTO)
	SE2->E2_VENCREA := dDtVld
	Msunlock()
ELSE
	MsgBox("Titulo nao encontrado : "+wPrefMarc+wNumeMarc+wParcMarc,"Alert")
ENDIF
Close(oDlg1)
DbSelectArea("SX3")
DbSetOrder(1)
DbSelectArea(wAlias1)
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function somames
Static Function somames()
wDia := subs(dtos(wUltVenc),7,2)
wMes := subs(dtos(wUltVenc),5,2)
wAno := subs(dtos(wUltVenc),1,4)
_data := Ctod(wDia+"/"+wMes+"/"+wAno)
mes := Month(_data) + 3
dia := Day(_data)
ano := Year(_data)
Do while mes > 12
	mes := mes - 12
	ano := ano + 1
EndDo
novadata := Ctod(Str(dia,2)+"/"+Str(mes,2)+"/"+Str(ano,4))
If empty(novadata)
	novadata := Ctod("30"+"/"+Str(mes,2)+"/"+Str(ano,4))
EndIf
If empty(novadata)
	novadata := Ctod("29"+"/"+Str(mes,2)+"/"+Str(ano,4))
EndIf
If empty(novadata)
	novadata := Ctod("28"+"/"+Str(mes,2)+"/"+Str(ano,4))
EndIf
DbSelectArea(wAlias1)
Return
