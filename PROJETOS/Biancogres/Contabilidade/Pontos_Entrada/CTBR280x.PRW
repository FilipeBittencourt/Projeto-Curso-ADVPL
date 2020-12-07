#Include "ctbr280X.Ch"
#Include "FIVEWIN.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Ctbr280  ³ Autor ³ Claudio Donizete      ³ Data ³ 20.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rela‡ao de Movimentos Acumulados p/ CV Extra               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctbr280()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CtbR280x()
Local Wnrel
LOCAL cString:="CT1"
LOCAL cDesc1:= OemToAnsi(STR0001)                                             //"Este programa ir  imprimir a rela‡„o de Movimentos "
LOCAL cDesc2:= OemToAnsi(STR0002)+RetTitle("CTI_CLVL",15)+OemToAnsi(STR0010)  //"Acumulados por "###" Extra Cont bil das con-"
LOCAL cDesc3:= OemToAnsi(STR0003)  //"tas determinadas pelo usu rio."
LOCAL tamanho:="G"
Local titulo :=OemToAnsi(STR0006)  //"Relacao de Movimentos Acumulados para CV Extra - Exercicio "
Local aSetOfBook

PRIVATE aReturn := { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog:="CTBR280"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="CTR280"

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

/*
aPergs := { {	"Comparar ?","¨Comparar ?","Compare ?",;
				"mv_chh","N",1,0,2,"C","","mv_par17","Mov. Periodo","Mov. Periodo","Period Mov.","","",;
				"Saldo Acumulado","Saldo Acumulado","Accumulated Balance","","","","","","","","","","",;
				"","","","","","","","","S",;
				"" } }
AjustaSx1("CTR280", aPergs)
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("CTR280",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                       ³
//³ mv_par01            // Data inicial                        ³
//³ mv_par02            // Data Final                          ³
//³ mv_par03            // da Classe de Valor                  ³
//³ mv_par04            // at‚ o Classe de Valor               ³
//³ mv_par05            // da Conta                            ³
//³ mv_par06            // at‚ a Conta                         ³
//³ mv_par07            // moeda                               ³
//³ mv_par08            // Pagina inicial                      ³
//³ mv_par09   			// Saldos? Reais / Orcados/Gerenciais      ³
//³ mv_par10            // Set of books                        ³
//³ mv_par11			// Saldos Zerados?			     	               ³
//³ mv_par12			// Filtra Segmento?				              	   ³
//³ mv_par13			// Conteudo Inicial Segmento?		             ³
//³ mv_par14			// Conteudo Final Segmento?		               ³
//³ mv_par15 			// Codigo da Conta (Reduzido/Normal)         ³
//³ mv_par16			// Codigo do CV (Reduzido/Normal)            ³
//³ mv_par17			// Tipo de Comparativo?(Movimento/Acumulado) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="CTBR280X"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par10)
	Set Filter To
	Return
EndIf
aSetOfBook := CTBSetOf(mv_par10)

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| Ct280Imp(@lEnd,wnRel,cString,Tamanho,Titulo,aSetOfBook)})

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao    ³ Ct280Imp ³ Autor ³ Claudio Donizete      ³ Data ³ 20/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao Relacao Movimento Mensal                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Ct280Imp(lEnd,wnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd    - Acao do Codeblock                                ³±±
±±³           ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³           ³ cString - Mensagem                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct280Imp(lEnd,WnRel,cString,Tamanho,Titulo, aSetOfBook)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbTxt
LOCAL Cbcont
LOCAL limite := 220
Local lImpCV := .T., lImpConta := .T.
Local nDecimais := 2
Local cabec1 := OemToAnsi(STR0014)
Local cabec2 := OemToAnsi(STR0015)

Local cCth_Clvl
Local aCtbMoeda := {}
Local aPeriodos
Local aSaldos
Local cMascConta
Local cMascCus
Local cSepConta := ""
Local cSepCus   := ""
Local cPicture
Local nX
Local aTotalCV
Local nCol
Local nTotais
Local cCodRes
Local cCodResCV
Local cChave
Local nRecCV := 0
Local cAliasAnt := ""
Local lFirst	:= .T.
Local cMensagem	:= ""
Local aMeses	:= {}
Local nCont		:= 1
Local nMeses	:= 0
Local nPos		:= 0
Local nDigitos	:= 0
Local lComSaldo	:= .F.

#IFDEF TOP
	Local lAs400	:= Upper(TcGetDb()) == "AS/400"
#ENDIF

nDecimais 	:= DecimalCTB(aSetOfBook,mv_par07)

If Empty(aSetOfBook[2])
	cMascConta := GetMv("MV_MASCARA")
	cMascCus	  := GetMv("MV_MASCCUS")
Else
	cMascConta := RetMasCtb(aSetOfBook[2],@cSepConta)
	cMascCus   := RetMasCtb(aSetofBook[6],@cSepCus)
EndIf
cPicture 	:= aSetOfBook[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := MV_PAR08

//	Se nenhuma moeda foi escolhida, sai do programa
aCtbMoeda  	:= CtbMoeda(mv_par07)
If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
	Set Filter To
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localiza classe de valor inicial                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CTH")
dbSetOrder(1)
dbSeek( xFilial("CTH")+mv_par03,.T. )
SetRegua(Reccount())

// Localiza o periodo contabil para os calendarios da moeda 
aPeriodos := ctbPeriodos(mv_par07, mv_par01, mv_par02, .T., .F.)
If Empty(aPeriodos[1][1])
 	 cMensagem	:= STR0017
	 cMensagem	+= STR0018
   MsgInfo(cMensagem)
   Return
EndIf

For nCont := 1 to len(aPeriodos)       
	//Se a Data do periodo eh maior ou igual a data inicial solicitada no relatorio.
	If aPeriodos[nCont][1] >= mv_par01 .And. aPeriodos[nCont][2] <= mv_par02 
		AADD(aMeses,{StrZero(nMeses,2),aPeriodos[nCont][1],aPeriodos[nCont][2]})	
		nMeses += 1           					
	Else
		AADD(aMeses,{"  ",ctod("  /  /  "),ctod("  /  /  ")})
	EndIf
Next     

aTotalCV  := Array(Len(aPeriodos))
Titulo += " " + aPeriodos[1][3] // Adiciona o exercicio ao titulo

Titulo += " ("+ DTOC(mv_par01)+" - "+DTOC(mv_par02) +") "
If mv_par17 == 2
	Titulo += " - "+STR0019
Endif

For nX := 1 To Len(aPeriodos)           
	//If nX >= 9
	//	Cabec2 += Padl("Ate " + Dtoc(aPeriodos[nX][2]),17) + "  "
	//Else	
		Cabec1 += Padl("Ate " + Dtoc(aPeriodos[nX][2]),13) + "  "
	//Endif	
Next

If !Empty(mv_par12)			//// FILTRA O SEGMENTO Nº
	If Empty(mv_par10)		//// VALIDA SE O CÓDIGO DE CONFIGURAÇÃO DE LIVROS ESTÁ CONFIGURADO
		help("",1,"CTN_CODIGO")
		Return
	Else
		If !Empty(aSetOfBook[5])
			MsgInfo("O plano gerencial ainda não está disponível para este relatório."+CHR(10)+"Altere a configuração de livros...","Config. de Livros...")
			Return
		Endif
	Endif
	dbSelectArea("CTM")
	dbSetOrder(1)
//	If MsSeek(xFilial()+aSetOfBook[7])
	If MsSeek(xFilial()+aSetOfBook[2])
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == aSetOfBook[2]
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == strzero(val(mv_par12),2)
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	Else
		help("",1,"CTM_CODIGO")
		Return
	EndIf
EndIf 

cAliasCT1 := "CT1"
cAliasCTH := "CTH"

#IFDEF TOP
	If !lAs400
		MsAguarde({|| yCTR280Qry(aMeses,mv_par07,mv_par09,mv_par05,mv_par06,mv_par03,mv_par04,aSetOfBook,mv_par11 == 1,cString,aReturn[7],.F./*lImpAntLP*/,/*dDataLP*/) }, STR0006 )
		cAliasCT1 := "TRBTMP"
		cAliasCTH := "TRBTMP"
	Else
		// Processa o arquivo de centro de custos, dentro dos parametros do usuario
		dbSelectArea(cAliasCTH)
		dbSetOrder(1)
	Endif
#ELSE
	// Processa o arquivo de centro de custos, dentro dos parametros do usuario
	dbSelectArea(cAliasCTH)
	dbSetOrder(1)
#ENDIF                    
While (cAliasCTH)->(!Eof()) .And. (cAliasCTH)->CTH_FILIAL==xFilial("CTH") .And. (cAliasCTH)->CTH_CLVL <= mv_par04
	
	IncRegua()	
	// Guarda o centro de custo para ser utilizado na quebra	
	cCth_CLVL  	:= (cAliasCTH)->CTH_CLVL
	cCodResCV	:= (cAliasCTH)->CTH_RES
	lImpCV     	:= .T.
	aFill(aTotalCV,0) 			// Zera o totalizador por periodo
	

	************************* ROTINA DE IMPRESSAO *************************
								
	#IFNDEF TOP
		If (cAliasCTH)->CTH_CLASSE == "1"		// Sintetica
			(cAliasCTH)->(DbSkip())
			Loop
		Endif
	
		// Localiza os saldos do classe de valor
		dbSelectArea(cAliasCT1)
		dbSetOrder(1)			 	// Filial+Custo+Conta+Moeda
		dbSeek(xFilial("CT1")+mv_par05, .T.)
	
	#ELSE
		If lAs400
			If (cAliasCTH)->CTH_CLASSE == "1"		// Sintetica
				(cAliasCTH)->(DbSkip())
				Loop
			Endif

			// Localiza os saldos do classe de valor
			dbSelectArea(cAliasCT1)
			dbSetOrder(1)			 	// Filial+Custo+Conta+Moeda
			dbSeek(xFilial("CT1")+mv_par05, .T.)
		Endif
	#ENDIF
		
	// Obtem os saldos do classe de valor
	While !Eof() .And. (cAliasCT1)->CT1_FILIAL == xFilial("CT1") .And. (cAliasCTH)->CTH_CLVL == cCth_CLVL  .And. (cAliasCT1)->CT1_CONTA <= mv_par06
		lImpConta 	:= .T.
		cCtI_Conta  := (cAliasCT1)->CT1_CONTA //CTI->CTI_CONTA
		nCol 	  	:= 1 
		aSaldos 	:= {}
		nTotais 	:= 0
		
		/*IF ALLTRIM(cCtI_Conta) == "31101010"
		 	msgalert(cCtI_Conta)
		End If*/		
		
		#IFDEF TOP    
			If !lAs400
				For nX := 1 To Len(aPeriodos)
					If aPeriodos[nX][1] >= mv_par01 .And. aPeriodos[nX][2] <= mv_par02                   
						If mv_par17 == 2 
							aAdd(aSaldos,{ &("(cAliasCT1)->COLUNA"+alltrim(str(nX)))+nTotais,0,0,0,0,0} )/// ACUMULA MOVIMENTO
						Else 
							aAdd(aSaldos,{ &("(cAliasCT1)->COLUNA"+alltrim(str(nX)))        ,0,0,0,0,0} )/// POR PERIODO (SEM ACUMULAR)
						EndIf
						if nTotais = 0 
							nTotais := aSaldos[nX][1]
						End if
					Else
						Aadd(	aSaldos, {0,0,0,0,0,0})
					Endif
				Next
			Else
		#ENDIF
 
			If (cAliasCT1)->CT1_CLASSE = "1"		// Sintetica
				(cAliasCT1)->(DbSkip())
				Loop
			Endif
	
			For nX := 1 To Len(aPeriodos)
				//	Obtem o saldo acumulado ate o ultimo dia do periodo
				// da moeda escolhida.
				If aPeriodos[nX][2] >= mv_par01 .And. aPeriodos[nX][2] <= mv_par02
					If mv_par17 == 2 // ACUMULA MOVIMENTO
						Aadd(aSaldos,SaldoCtI((cAliasCT1)->CT1_CONTA,cCth_CLVL ,aPeriodos[nX][2],mv_par07,MV_PAR09))			
					Else  // POR PERIODO (SEM ACUMULAR)
						Aadd(aSaldos,SaldoCtI((cAliasCT1)->CT1_CONTA,cCth_CLVL ,aPeriodos[nX][2],mv_par07,MV_PAR09))			
						aSaldos[nX][1] -= nTotais
					EndIf
					nTotais += aSaldos[nX][1]
				Else
					Aadd(	aSaldos, {0,0,0,0,0,0})						
				EndIf
			Next
  		#IFDEF TOP    
  			Endif
  		#ENDIF
  		
		//Caso faca filtragem por segmento de item,verifico se esta dentro 
		//da solicitacao feita pelo usuario. 
		If !Empty(mv_par12)
			If !Empty(mv_par13) .Or. !Empty(mv_par14)
				If Substr((cAliasCT1)->CT1_CONTA,nPos,nDigitos) < Alltrim(mv_par13) .Or. Substr((cAliasCT1)->CT1_CONTA,nPos,nDigitos) > Alltrim(mv_par14)
					(cAliasCT1)->(dbSkip())
					Loop
				EndIf	
			Endif
		EndIf	                                         		

		lComSaldo	:= .F.  		
  		For nX := 1 To Len(aPeriodos)
  		    If aSaldos[nX][1]  <> 0 
  		    	lComSaldo	:= .T.
				Exit  		    	
  		    EndIf  		
  		Next

		// Se imprime saldos zerados ou 
		// se nao imprime saldos zerados e houver valor,
		// imprime os saldos
		If mv_par11 == 1 .OR. (mv_par11 == 2 .AND. nTotais != 0)
			For nX := 1 To Len(aSaldos)
				IF lEnd
					@Prow()+1,0 PSAY OemToAnsi(STR0009)  //"***** CANCELADO PELO OPERADOR *****"
					Exit
				EndIf
				// quebra de linha a cada 8 periodos
				//If nX % 9 == 0
				//	Li++
				//	nCol := 1
				//EndIf

				// Inicio da impressao
				If li+If(lImpCV .and. lImpConta,3,If(lImpCV,2,If(lImpConta,1,0))) > 57
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
					li--
					If lImpCV
						Li--
					Endif	
					
					//If nX % 9 == 0 .And. ( !lImpCV .And. !lImpConta )
					//	li++
					//EndIf   
					
					lFirst	:= .F.
				EndIf
		
				// Imprime o Classe de Valor 
				If lImpCV
					li += 2                                                    
					If mv_par18 ==1 //Imprime Cod. CV Normal  // madaleno mudou a pergunta de 16 para 18
						EntidadeCtb(cCth_CLVL ,li,00,15,.f.,cMascCus,cSepCus)
					Else							
						// Imprime codigo reduzido
						EntidadeCtb(cCodResCV,li,00,15,.f.,cMascCus,cSepCus)
					Endif
					@ li, PCOL() + 1 PSAY CtbDescMoeda("(cAliasCTH)->CTH_DESC"+MV_PAR07)
					lImpCV := .F.
					li++
				Endif
				// Imprime a Conta
				If lImpConta
					cCodRes := (cAliasCT1)->CT1_RES
					If mv_par17 ==1 //Imprime Cod. Conta Normal   // madaleno mudou a pergunta de 15 para 17
						EntidadeCTB(&("(cAliasCT1)->CT1_CONTA"),++li,00,20,.F.,cMascConta,cSepConta)
					Else 
						EntidadeCTB(cCodRes,++li,00,20,.F.,cMascConta,cSepConta)
					Endif
					@ li, PCOL() + 1 PSAY Subs(CtbDescMoeda("(cAliasCT1)->CT1_DESC" + MV_PAR07),1,20)
					lImpConta := .F.
				EndIf
				// Imprime o valor
				//ValorCTB(aSaldos[nX][1],li,48+(nCol++*19),17,nDecimais,.T.,cPicture)
				//ValorCTB(aSaldos[nX][1],li,48+(nCol++*15),13,nDecimais,.T.,cPicture)
				ValorCTB(aSaldos[nX][1],li,25+(nCol++*15),13,nDecimais,.T.,cPicture)				
				aTotalCV[nX] += aSaldos[nX][1]
			Next
		Endif	
		
		// Vai para a proxima conta
		dbSelectArea(cAliasCT1)
		(cAliasCT1)->(DbSkip())		
	EndDo
	
	If !lFirst		
		// Quebrou o Classe de Valor
		If !lImpCV
			li+=2
			@ li,00 PSAY Replicate("-",Limite)			
			li++
			@ li,000 PSay OemToAnsi(STR0012)+RetTitle("CTH_CLVL",7)+": "
			If mv_par18 ==1 //Imprime Cod. CV Normal  // madaleno mudou a pergunta de 16 para 18
				EntidadeCtb(cCth_CLVL ,li,PCOL(),15,.F.,cMascCus,cSepCus)
			Else 
				EntidadeCtb(cCodResCV,li,PCOL(),15,.F.,cMascCus,cSepCus)
			Endif

			// Imprime o totalizador por periodo
			nCol := 1

			Aeval( aTotalCV, { |e,nX| , ValorCTB(e,li,26+(nCol++*15),13,nDecimais,.T.,cPicture) } )
			//Aeval( aTotalCV, { |e,nX| , ValorCTB(e,li,48+(nCol++*15),13,nDecimais,.T.,cPicture) } )
			//Aeval( aTotalCV, { |e,nX| If(nX%9==0,(nCol := 1, Li++),NIL),;
			//							  ValorCTB(e,li,48+(nCol++*15),13,nDecimais,.T.,cPicture) } )
										  //ValorCTB(e,li,48+(nCol++*19),17,nDecimais,.T.,cPicture) } )
			li++
			@ li,00 PSAY Replicate("-",Limite)						
		EndIf
	EndIf
	dbSelectArea(cAliasCTH)
	#IFNDEF TOP
		dbSetOrder(1)
		(cAliasCTH)->(dbSkip())
	#ELSE
	 	If lAs400
 			dbSetOrder(1)
			(cAliasCTH)->(dbSkip())
	 	Endif
	#ENDIF       
Enddo
	
#IFNDEF TOP
	dbsetOrder(1)
	Set Filter To
#ELSE
	If lAs400
		dbsetOrder(1)
		Set Filter To
	Endif
#ENDIF

If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBR280   ºAutor  ³Marcos S. Lobo      º Data ³  02/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a query para o relatorio Mov.Acum. CVxContaxMeses     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                 
Static Function yCTR280Qry(aPeriodos,cMoeda,cTpSaldo,cContaIni,cContaFim,cCustoIni,cCustoFim,aSetOfBook,lVlrZerado,cString,cFILUSU,lImpAntLP,dDataLP)

Local aSaveArea	:= GetArea()
Local cQuery	:= ""
Local nColunas	:= 0
Local aTamVlr	:= TAMSX3("CTI_DEBITO")
Local nStr		:= 1
Local l1St 		:= .T.

DEFAULT lVlrZerado	:= .F.
DEFAULT lImpAntLP   := .F.
DEFAULT cFilUSU		:= ""
DEFAULT cString		:= "CTH"
DEFAULT aSetOfBook  := {""}

MsProcTxt("Montando consulta...")

cQuery := " SELECT CT1_FILIAL CT1_FILIAL, CT1_CONTA CT1_CONTA,CT1_NORMAL CT1_NORMAL, CT1_RES CT1_RES, CT1_DESC"+cMoeda+" CT1_DESC"+cMoeda+", "
cQuery += " 	CT1_CLASSE CT1_CLASSE, CT1_GRUPO CT1_GRUPO, CT1_CTASUP CT1_CTASUP, "
cQuery += " 	CTH_FILIAL CTH_FILIAL, CTH_CLVL CTH_CLVL, CTH_DESC"+cMoeda+" CTH_DESC"+cMoeda+", CTH_CLASSE CTH_CLASSE, CTH_RES CTH_RES, CTH_CLSUP CTH_CLSUP, "

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////
      
For nColunas := 1 to Len(aPeriodos)
	If !Empty(aPeriodos[nColunas][1])	
		cQuery += " 	(SELECT SUM(CTI_CREDIT) - SUM(CTI_DEBITO) "
		cQuery += "			 	FROM "+RetSqlName("CTI")+" CTI "
		cQuery += " 			WHERE CTI.CTI_FILIAL = '"+xFilial("CTI")+"' "
		cQuery += " 			AND CTI_MOEDA = '"+cMoeda+"' "
		cQuery += " 			AND CTI_TPSALD = '"+cTpSaldo+"' "
		cQuery += " 			AND CTI_CONTA	= ARQ.CT1_CONTA "
		cQuery += " 			AND CTI_CLVL	= ARQ2.CTH_CLVL  "
		//If l1St
		//	cQuery += " 			AND CTI_DATA <= '"+DTOS(aPeriodos[nColunas][3])+"' "
		//	l1St := .F.
		//Else
			cQuery += " 			AND CTI_DATA BETWEEN '"+DTOS(aPeriodos[nColunas][2])+"' AND '"+DTOS(aPeriodos[nColunas][3])+"' "
		//Endif
		If lImpAntLP .and. dDataLP >= aPeriodos[nColunas][2]
			cQuery += " AND CTI_LP <> 'Z' "
		Endif                          
		cQuery += " 			AND CTI.D_E_L_E_T_ <> '*') COLUNA"+Str(nColunas,Iif(nColunas>9,2,1))+" "
	Else
		cQuery += " 0 COLUNA"+Str(nColunas,Iif(nColunas>9,2,1))+" "
	Endif
	
	If nColunas <> Len(aPeriodos)
		cQuery += ", "
	EndIf		
Next	
	
cQuery += " 	FROM "+RetSqlName("CT1")+" ARQ, "+RetSqlName("CTH")+" ARQ2 "
cQuery += " 	WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery += " 	AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' "
cQuery += " 	AND ARQ.CT1_CLASSE = '2' "
If !Empty(aSetOfBook[1])										//// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS     
	cQuery += " 	AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "    //// FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
Endif	
cQuery += " 	AND ARQ.D_E_L_E_T_ <> '*' "

cQuery += " 	AND ARQ2.CTH_FILIAL = '"+xFilial("CTH")+"' "
cQuery += " 	AND ARQ2.CTH_CLVL  BETWEEN '"+cCustoIni+"' AND '"+cCustoFim+"' "
cQuery += " 	AND ARQ2.CTH_CLASSE = '2' "
If !Empty(aSetOfBook[1])										//// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " 	AND ARQ2.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%' "    //// FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
Endif	
cQuery += " 	AND ARQ2.D_E_L_E_T_ <> '*' "

l1St := .T.
 
If !lVlrZerado
	cQuery += " 	AND ( "
	For nColunas := 1 to Len(aPeriodos)
		If !Empty(aPeriodos[nColunas][1])
//			If nColunas <> 1
			If !l1St
				cQuery += " 	OR "
			EndIf          
			
			cQuery += "	(SELECT SUM(CTI_CREDIT) - SUM(CTI_DEBITO) "
			cQuery += " FROM "+RetSqlName("CTI")+" CTI "
			cQuery += " WHERE CTI.CTI_FILIAL	= '"+xFilial("CTI")+"' "
			cQuery += " AND CTI_MOEDA = '"+cMoeda+"' "
			cQuery += " AND CTI_TPSALD = '"+cTpSaldo+"' "
			cQuery += " AND CTI_CONTA	= ARQ.CT1_CONTA "
			cQuery += " AND CTI_CLVL	= ARQ2.CTH_CLVL  "
			If l1St
				cQuery += " AND CTI_DATA <= '"+DTOS(aPeriodos[nColunas][3])+"' "
				l1St := .F.
			Else
				cQuery += " AND CTI_DATA BETWEEN '"+DTOS(aPeriodos[nColunas][2])+"' AND '"+DTOS(aPeriodos[nColunas][3])+"' "
			Endif
			If lImpAntLP .and. dDataLP >= aPeriodos[nColunas][2]
				cQuery += " AND CTI_LP <> 'Z' "
			Endif
			cQuery += " 	AND CTI.D_E_L_E_T_ <> '*') <> 0 "
		Endif
	Next	
	
	cQuery += " ) "
	
Endif
cQuery += " ORDER BY CTH_CLVL,CT1_CONTA "

cQuery := ChangeQuery(cQuery)		   

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()                                 
Endif	

MsProcTxt("Executando consulta...")
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
For nColunas := 1 to Len(aPeriodos)
	TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
Next

RestArea(aSaveArea)

Return
