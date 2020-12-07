#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA031R()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A := " "
B := " "
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("ARETURN,ALINHA,NOMEPROG,NLASTKEY,AORD,CSAVSCR1")
SetPrvt("CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1,CBTXT,CBCONT")
SetPrvt("CABEC1,CABEC2,CABEC3,CSTRING,LI,M_PAG")
SetPrvt("WNREL,LABORTPRINT,LEND,WVENINI,WVENFIM,WMES")
SetPrvt("WANO,WPERC,_ACAMPOS,_CTRAB,WCOMIS,WVALCOM")
SetPrvt("WQTDITEM,WVALOR,WBASE,WCOMISSAO,TVALOR,TBASE")
SetPrvt("TCOMISSAO,WVENDEDOR,WNOMVEND,WCODVEND,VEND,PREFIXO")
SetPrvt("NUM,PARCELA,CLIENTE,LOJA,NOMCLI,EMISSAO")
SetPrvt("VENCTO,PEDIDO,VALOR,BASCOM,COMIS,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	   ³ BIA031	  	³ Autor ³ CESAR MAGNAGO	     ³ Data ³ 11/02/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de comissoes sobre o faturamento    			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ Interpretador xBase										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
tamanho	:= "M"
limite	:= 132
titulo	:= "Comissoes sobre o Faturamento"
cDesc1	:= "Emite a relacao de comissoes sobre o faturamento do mes."
cDesc2	:= " "
cDesc3	:= " "
aReturn	:=  { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
aLinha	:= { }
cPerg 	:= "BIA031"
nomeprog := "BIA031"
nLastKey := 0
aOrd		:= {"Por Vendedor"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt 	:= SPACE(10)
cbcont	:= 0
cabec1	:= "             ---------- Cliente -----------                                         Valor           Valor     %              Valor"
cabec2	:= "Prf Titulo P Codigo Lj Nome                 Emissao      Vencto    Pedido           Titulo           Base    Comis         Comissao"
cabec3	:= " "
cString	:= "SE1"
li 		:= 80
m_pag 	:= 1
wnrel 	:= "BIA031"   // nome default do relatorio em disco
lAbortPrint := .F.
lEnd			:= .F.

If !GetRemoteType() == 5 .And. !__cUserID="000996"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajuste dos parƒmetros da impress„o via fun‡„o SETPRINT		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,wnrel,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,"M")
	If LastKey() == 27 .Or. nLastKey == 27
		Return
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aceita parƒmetros e faz ajustes necess rios 					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetDefault(aReturn,cString)
	If LastKey() == 27 .or. nLastKey == 27
		Return
	End
	
	Pergunte("BIA031",.F.)
Else
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
EndIf


wVenIni := CREPATU //mv_par01
wVenFim := CREPATU //mv_par02
wMes	  := substr(M->mv_par03,1,2)
wAno	  := substr(M->mv_par03,4,4)
wPerc   := mv_par04 / 100

//Define a Empresa
If cEmpAnt == "01"
	Do Case
	   Case MV_PAR07 == 1 	//BIANCOGRES
	        nEmp	:= "0101"
	EndCase
Else
	Do Case
	   Case MV_PAR07 == 1 	//INCESA
	        nEmp	:= "0501"
	   Case MV_PAR07 == 2 	//BELLACASA
	        nEmp	:= "0599"
	   Case MV_PAR07 == 3		//INCESA/BELLACASA
	        nEmp	:= "05"
	EndCase
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do arquivo de trabalho										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aCampos := {	 {"VEND",    "C",  6, 0},;
{"PREFIXO", "C",  3, 0},;
{"NUM",     "C",  6, 0},;
{"PARCELA", "C",  1, 0},;
{"CLIENTE", "C",  6, 0},;
{"LOJA",    "C",  2, 0},;
{"NOMCLI",  "C", 20, 0},;
{"EMISSAO", "D",  8, 0},;
{"VENCTO",  "D",  8, 0},;
{"PEDIDO",  "C",  6, 0},;
{"VALOR",   "N", 11, 2},;
{"BASCOM",  "N", 11, 2},;
{"COMIS",   "N",  8, 4},;
{"VALCOM",  "N", 11, 2} }
_cTrab := CriaTrab(_aCampos,.T.)
dbUseArea(.T.,,_cTrab,"_cTrab")
dbCreateInd(_cTrab,"VEND+PREFIXO+NUM+PARCELA",{||VEND+PREFIXO+NUM+PARCELA})

//******************INICIO
If GetRemoteType() == 5 .Or. __cUserID="000996"
	RptStatus({|| U_BIA031TR() })
	
Else
	RptStatus( {||RptDetail()} )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	RptStatus( {||Execute(RptDetail)} )
EndIf


If lAbortPrint .Or. lEnd
	fFinaliza()
Endif

Return( Nil )


// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Function RptDetail
Static Function RptDetail()

//******************FIM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o arquivo de trabalho - SE1 -> Contas a Receber							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SE1" )
DbSetOrder(11)
dbSeek(xFilial("SE1")+wAno+wMes+"01",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a linha da regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SETREGUA( LastRec() )

While !Eof() .and. SE1->E1_FILIAL== XFILIAL("SE1");
	.And. dtos(E1_EMISSAO) <= wAno+wMes+"31"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta o cursor da regua 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	INCREGUA()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TRATAMENTO DE TECLAS WINDOWS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lAbortPrint .OR. lEnd
		Return
	ENDIF
	
	// VERIFICANDO SE E O GERENTE // BRUNO MADALENO 
	IF ! EMPTY(CREPATU) .AND. SUBSTRING(CREPATU,1,1) = "1"
        
		IF ! SA1->(DBSEEK ( xFILIAL("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
			SE1->(DBSKIP())
			LOOP
		ENDIF
        
	
	    IF CEMPANT == "01"
			IF (SA1->A1_YVENDB2 <> CREPATU .AND. SA1->A1_YVENDB3 <> CREPATU) 
				SE1->(DBSKIP())
				LOOP
			END IF
		ELSE
			IF (SA1->A1_YVENDI2 <> CREPATU .AND. SA1->A1_YVENDI3 <> CREPATU) 
				SE1->(DBSKIP())
				LOOP
			END IF		
		END IF	

		If  dtos(E1_EMISSAO) < wAno+wMes+"01" .or. ;
			SE1->E1_VEND1 < mv_par01 .or. ;
			SE1->E1_VEND1 > mv_par02
			dbSelectArea( "SE1" )
			dbSkip()
			Loop
		End


	ELSE			
		If  dtos(E1_EMISSAO) < wAno+wMes+"01" .or. ;
			SE1->E1_VEND1 < wVenIni .or. ;
			SE1->E1_VEND1 > wVenFim
			dbSelectArea( "SE1" )
			dbSkip()
			Loop
		End
	end if
	
		
	If  SE1->E1_VEND1 == "      "
		dbSelectArea( "SE1" )
		dbSkip()
		Loop
	End
	
	If  SUBS(SE1->E1_TIPO,1,2) == "RA"
		dbSelectArea( "SE1" )
		dbSkip()
		Loop
	End

	//Filtra Empresa
	If Len(Alltrim(nEmp)) == 4
		If  !SE1->E1_YEMP == nEmp
			dbSelectArea( "SE1" )
			dbSkip()
			Loop
		End
	EndIf
	
	dbSelectArea( "SA3" )
	DbSetOrder(1)
	dbSeek(xFilial("SA3")+SE1->E1_VEND1)
	
	dbSelectArea( "SD2" )
	DbSetOrder(3)
	dbSeek(xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA)
	
	wComis   := 0
	wValcom  := 0
	wQtditem := 0
	
	While !Eof() .AND. SD2->D2_FILIAL == XFILIAL("SD2");
		.And. SD2->D2_DOC   == SE1->E1_NUM;
		.And. SD2->D2_SERIE == SE1->E1_PREFIXO;
		.AND. SD2->D2_CLIENTE == SE1->E1_CLIENTE;
		.AND. SD2->D2_LOJA == SE1->E1_LOJA
		
		If SD2->D2_TIPO <> "N"
			DbSelectArea("SD2")
			DbSkip()
			Loop
		EndIf
		
		If SUBST(SD2->D2_GRUPO,1,2) <> "PA"
			DbSelectArea("SD2")
			DbSkip()
			Loop
		Endif
		
		DbSelectArea("SF2")
		DbSetOrder(1)
		DBSEEK(XFILIAL("SF2")+SD2->D2_DOC+SD2->D2_SERIE)
		
		DbSelectArea("SE4")
		DbSetOrder(1)
		DBSEEK(XFILIAL("SE4")+SF2->F2_COND)
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		DBSEEK(XFILIAL("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		
		DbSelectArea("SF4")
		DbSetOrder(1)
		
		If DbSeek(xFilial("SF4")+SD2->D2_TES)
			
			If ( SF4->F4_DUPLIC == "S" ) .and. ( SF4->F4_ESTOQUE == "S" )
				
				//IF SA1->A1_TIPO == "S"
				  //	IF SE1->E1_PARCELA # "A"
					//	IF SE4->E4_SOLID # "S"
					  //		wComis	:= wComis + SD2->D2_COMIS1
						//	wQtditem := wQtditem + 1
						//ENDIF
					//ENDIF
				//ELSE
					wComis	:= wComis + SD2->D2_COMIS1
					wQtditem := wQtditem + 1
				//ENDIF
				
			EndIf
			
		EndIf
		
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSkip()
		
	EndDo

	// FILTRANDO O SEGMENTO
	IF ( SA1->A1_SATIV1 < MV_PAR05 ) .OR. ( SA1->A1_SATIV1 > MV_PAR06 )
		SE1->(DBSKIP())
		LOOP
	ENDIF

	
	fGrava()
	
	dbSelectArea( "SE1" )
	DbSetOrder(11)
	dbSkip()
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia o procedimento de impressao dos valores obtidos							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("_cTrab")
dbGotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a linha da regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SETREGUA( LastRec() )

wValor	 := 0
wBase 	 := 0
wComissao := 0
tValor	 := 0
tBase 	 := 0
tComissao := 0
wVendedor := _cTrab->VEND

While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta o cursor da regua 				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	INCREGUA()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TRATAMENTO DE TECLAS WINDOWS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lAbortPrint .OR. lEnd
		Return
	ENDIF
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa se houve quebra de vendedor 												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  _cTrab->VEND <> wVendedor
		li := li + 1
		@ li,   0 PSAY "Total do Vendedor -> IRRF:"
		@ li,  27 PSAY Round(wComissao * wPerc,2) PICTURE "@E 999,999.99"
		@ li,	76 PSAY wValor 						  PICTURE "@E 999,999,999.99"
		@ li,	91 PSAY wBase							  PICTURE "@E 999,999,999.99"
		@ li, 106 PSAY (wComissao/wBase) * 100	  PICTURE "@E 999.9999"
		@ li, 117 PSAY wComissao 					  PICTURE "@E 999,999,999.99"
		li := li + 1
		@ li,   0 PSAY "------------------------------------------------------------------------------------------------------------------------------------"
		li := li + 2
		If  li < 58  .AND. _cTrab->VEND == wVendedor
			DbSelectArea("SA3")
			DbSetOrder(1)
			If  !DbSeek(xFilial("SA3")+_cTrab->VEND)
				alert("Vendedor nao cadastrado. Codigo: "+_cTrab->VEND)
				wNomVend := " "
			Else
				wNomVend := SA3->A3_NOME
			End
			@ li,  0 PSAY "Vendedor: "
			@ li, 10 PSAY wNomVend
			li := li + 2
		End
		wValor	 := 0
		wBase 	 := 0
		wComissao := 0
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa se houve quebra de pagina													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF  li >= 60 .OR. _cTrab->VEND <> wVendedor
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		DbSelectArea("SA3")
		DbSetOrder(1)
		If  !DbSeek(xFilial("SA3")+_cTrab->VEND)
			alert("Vendedor nao cadastrado. Codigo: "+_cTrab->VEND)
			wNomVend := " "
		Else
			wNomVend := SA3->A3_NOME
			wCodVend := SA3->A3_COD
		End
		@ li,  0 PSAY "Vendedor: "
		@ li, 10 PSAY wCodVend
		@ li, 17 PSAY wNomVend
		li := li + 2
	End
	
	@ li,	0 PSAY _cTrab->PREFIXO
	@ li,	4 PSAY _cTrab->NUM
	@ li,  11 PSAY _cTrab->PARCELA
	@ li,  13 PSAY _cTrab->CLIENTE
	@ li,  20 PSAY _cTrab->LOJA
	@ li,  23 PSAY _cTrab->NOMCLI
	@ li,  44 PSAY _cTrab->EMISSAO  PICTURE "@D"
	@ li,  56 PSAY _cTrab->VENCTO   PICTURE "@D"
	@ li,  68 PSAY _cTrab->PEDIDO   PICTURE "@!"
	@ li,  76 PSAY _cTrab->VALOR	  PICTURE "@E 999,999,999.99"
	@ li,  91 PSAY _cTrab->BASCOM   PICTURE "@E 999,999,999.99"
	@ li, 106 PSAY _cTrab->COMIS	  PICTURE "@E 999.9999"
	@ li, 117 PSAY _cTrab->VALCOM   PICTURE "@E 999,999,999.99"
	
	wValor	  := wValor 	+ _cTrab->VALOR
	wBase	  := wBase		+ _cTrab->BASCOM
	wComissao := wComissao + _cTrab->VALCOM
	tValor	  := tValor 	+ _cTrab->VALOR
	tBase	  := tBase		+ _cTrab->BASCOM
	tComissao := tComissao + _cTrab->VALCOM
	wVendedor := _cTrab->VEND
	
	li:=li+1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca proximo item a imprimir										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("_cTrab")
	dbSkip()
	
End

//If	wComissao > 0 .and. wBase > 0
li := li + 1
@ li,	0 PSAY "Total do Vendedor -> IRRF:"
@ li,  27 PSAY Round(wComissao * wPerc,2)	  PICTURE "@E 999,999.99"
@ li,  76 PSAY wValor								  PICTURE "@E 999,999,999.99"
@ li,  91 PSAY wBase								  PICTURE "@E 999,999,999.99"
@ li, 106 PSAY Round(wComissao/wBase,4) * 100 PICTURE "@E 999.9999"
@ li, 117 PSAY wComissao							  PICTURE "@E 999,999,999.99"
li := li + 1
@ li,	0 PSAY "------------------------------------------------------------------------------------------------------------------------------------"

li := li + 2
@ li,	0 PSAY "Total Geral       -> IRRF:"
@ li,  27 PSAY Round(tComissao * wPerc,2)	  PICTURE "@E 999,999.99"
@ li,  76 PSAY tValor								  PICTURE "@E 999,999,999.99"
@ li,  91 PSAY tBase								  PICTURE "@E 999,999,999.99"
@ li, 106 PSAY Round(tComissao/tBase,4) * 100 PICTURE "@E 999.9999"
@ li, 117 PSAY tComissao							  PICTURE "@E 999,999,999.99"
li := li + 2
@ li,	0 PSAY "------------------------------------------------------------------------------------------------------------------------------------"
//End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impress„o do rodap‚ 																		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF  li != 80
	roda(cbcont,cbtxt,"M")
End

fFinaliza()

Return

//****************** finaliza
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fFinaliza
Static FUNCTION fFinaliza()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Tela e Set's                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Device To Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impress„o em Disco, chama SPOOL													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1 .AND. !lAbortPrint   // disco
	Set Printer TO
	Commit					 //grava em disco
	ourspool(wnrel)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga os arquivos temporarios						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("_cTrab")
Use
//If File(_cTrab+".DBF")
//	Ferase(_cTrab+".DBF")
//	Ferase(_cTrab+".NTX")
//End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera relat¢rio para Spool da Rede					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_PFLUSH()

Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fGrava
Static Function fGrava()

DbSelectArea("_cTrab")

RecLock("_cTrab", .T.)

_cTrab->VEND		:= SE1->E1_VEND1
_cTrab->PREFIXO 	:= SE1->E1_PREFIXO
_cTrab->NUM 	 	:= SE1->E1_NUM
_cTrab->PARCELA 	:= SE1->E1_PARCELA
_cTrab->CLIENTE 	:= SE1->E1_CLIENTE
_cTrab->LOJA	 	:= SE1->E1_LOJA
_cTrab->NOMCLI  	:= SE1->E1_NOMCLI
_cTrab->EMISSAO 	:= SE1->E1_EMISSAO
_cTrab->VENCTO  	:= SE1->E1_VENCTO
_cTrab->PEDIDO  	:= SE1->E1_PEDIDO
_cTrab->VALOR	 	:= SE1->E1_VALOR

If SA3->A3_ALBAIXA <> 100
	If SF4->F4_IPI == "N"
		_cTrab->BASCOM  := SE1->E1_BASCOM1
	Else
		If SE1->E1_EMISSAO >= Ctod("08/02/2006")
			_cTrab->BASCOM  := ROUND(SE1->E1_VALOR / 1.05,2)
		Else
			_cTrab->BASCOM  := ROUND(SE1->E1_VALOR / 1.10,2)		
		EndIf
	EndIF
Else
	_cTrab->BASCOM  := SE1->E1_BASCOM1
EndIF

If SE1->E1_VEND1 == "999999"
	If SF4->F4_IPI == "S"
		If SE1->E1_EMISSAO >= Ctod("08/02/2006")
			_cTrab->BASCOM  := ROUND(SE1->E1_VALOR / 1.05,2)
		Else
			_cTrab->BASCOM  := ROUND(SE1->E1_VALOR / 1.10,2)		
		EndIf
	Else
		_cTrab->BASCOM := SE1->E1_VALOR
	EndIf
	_cTrab->COMIS  := 0
Else
	_cTrab->COMIS  := (wComis / wQtditem)
EndIF

//If SE1->E1_NUM == "004744"
//	_cTrab->BASCOM  := 0
//EndIf

_cTrab->VALCOM := (_cTrab->BASCOM * _cTrab->COMIS) / 100
Return

//----------------------------------------------------------------------------------
// Versão do relatório em TReport.
//----------------------------------------------------------------------------------
User Function BIA031TR()
	Local oReport
	
	oReport:= ReportDef()
	oReport:PrintDialog()

Return
//----------------------------------------------------------------------------------
Static Function ReportDef()
	Local cNomeRep		:= "BIA031TR"
	Local cTituloRep 	:= "Comissoes sobre o Faturamento"
	Local cDescRep		:= "Emite a relacao de comissoes sobre o faturamento do mes."
	Local oBrNF
	Local oBrCli 
	Local oBrVend
	Local Enter := chr(13) + Chr(10)
	
	oReport:= TReport():New(cNomeRep,cTituloRep,cNomeRep, {|oReport| PrintReport(oReport)},cDescRep)
	Pergunte(oReport:GetParam(),.F.)
	
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage 		:=.F.
	oReport:lPrtParamPage   :=.F.
	oReport:lXlsParam		:=.F.
	
	oSecRep := TRSection():New(oReport,OemToAnsi("Repres"),)    
	oSecRep:SetTotalInLine(.F.)
	oSecRep:SetLineStyle(.T.)
	
	oSecTit := TRSection():New(oReport,OemToAnsi("Titulo"),)
	oSecTit:SetHeaderPage()
	
	oSTot := TRSection():New(oReport,OemToAnsi("Totais"),)
		
	//cria as células do relatório...
	
	TRCell():New(oSecRep,"A3_COD",,"Vendedor",,60,,,"LEFT",,"LEFT")
	
	//cabec1	:= "             ---------- Cliente -----------                                         Valor           Valor     %              Valor"
	//cabec2	:= "Prf Titulo P Codigo Lj Nome                 Emissao      Vencto    Pedido           Titulo           Base    Comis         Comissao"
	TRCell():New(oSecTit,"PREFIXO",,Enter + "Prf",,4,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"NUM",,Enter + "Titulo",,7,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"PARCELA",,Enter + "P",,2,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"CLIENTE",,"--------" + Enter + "Código",,8,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"LOJA",,"--" + Enter + "Lj",,3,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"NOMCLI",,"Cliente ------------" + Enter + "Nome",,23,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"EMISSAO",,Enter + "Emissao","@D",11,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"VENCTO",,Enter + "Vencto","@D",11,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"PEDIDO",,Enter + "Pedido","@!",8,,,"LEFT",,"LEFT")
	TRCell():New(oSecTit,"VALOR",,"Valor" + Enter + "Titulo","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTit,"BASCOM",,"Valor" + Enter + "Base","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTit,"COMIS",,"%" + Enter + "Comis","@E 999.9999",10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTit,"VALCOM",,"Valor" + Enter + "Comissao","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	
	TRCell():New(oSTot,"PREFIXO",,"",,69,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"NUM",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"PARCELA",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"CLIENTE",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"LOJA",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"NOMCLI",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"EMISSAO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"VENCTO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"PEDIDO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSTot,"VALOR",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSTot,"BASCOM",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSTot,"COMIS",,"","@E 999.9999",10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSTot,"VALCOM",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
    
    //New(oParent,uBreak,uTitle,lTotalInLine,cName,lPageBreak)
	oBreak := TRBreak():New(oSecRep,oSecRep:Cell("A3_COD"), "Total Geral",,,.T.)
Return oReport


//----------------------------------------------------------------------------------
Static Function PrintReport(oReport)

	fMontaArquivo()
	fImprime(oReport)
	fFinaliza()

Return

Static Function fMontaArquivo()
	//Monta o arquivo de trabalho - SE1 -> Contas a Receber
	dbSelectArea( "SE1" )
	DbSetOrder(11)
	dbSeek(xFilial("SE1")+wAno+wMes+"01",.T.)
	
	//Monta a linha da regua
	SETREGUA( LastRec() )
	
	While !Eof() .and. SE1->E1_FILIAL== XFILIAL("SE1");
		.And. dtos(E1_EMISSAO) <= wAno+wMes+"31"
		
		//Movimenta o cursor da regua
		INCREGUA()
		
		//TRATAMENTO DE TECLAS WINDOWS
		IF lAbortPrint .OR. lEnd
			Return
		ENDIF
		
		// VERIFICANDO SE E O GERENTE // BRUNO MADALENO 
		IF ! EMPTY(CREPATU) .AND. SUBSTRING(CREPATU,1,1) = "1"
	        
			IF ! SA1->(DBSEEK ( xFILIAL("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
				SE1->(DBSKIP())
				LOOP
			ENDIF
	        
		
		    IF CEMPANT == "01"
				IF (SA1->A1_YVENDB2 <> CREPATU .AND. SA1->A1_YVENDB3 <> CREPATU) 
					SE1->(DBSKIP())
					LOOP
				END IF
			ELSE
				IF (SA1->A1_YVENDI2 <> CREPATU .AND. SA1->A1_YVENDI3 <> CREPATU) 
					SE1->(DBSKIP())
					LOOP
				END IF		
			END IF	
	
			If  dtos(E1_EMISSAO) < wAno+wMes+"01" .or. ;
				SE1->E1_VEND1 < mv_par01 .or. ;
				SE1->E1_VEND1 > mv_par02
				dbSelectArea( "SE1" )
				dbSkip()
				Loop
			End
	
	
		ELSE			
			If  dtos(E1_EMISSAO) < wAno+wMes+"01" .or. ;
				SE1->E1_VEND1 < wVenIni .or. ;
				SE1->E1_VEND1 > wVenFim
				dbSelectArea( "SE1" )
				dbSkip()
				Loop
			End
		end if
		
			
		If  SE1->E1_VEND1 == "      "
			dbSelectArea( "SE1" )
			dbSkip()
			Loop
		End
		
		If  SUBS(SE1->E1_TIPO,1,2) == "RA"
			dbSelectArea( "SE1" )
			dbSkip()
			Loop
		End
	
		//Filtra Empresa
		If Len(Alltrim(nEmp)) == 4
			If  !SE1->E1_YEMP == nEmp
				dbSelectArea( "SE1" )
				dbSkip()
				Loop
			End
		EndIf
		
		dbSelectArea( "SA3" )
		DbSetOrder(1)
		dbSeek(xFilial("SA3")+SE1->E1_VEND1)
		
		dbSelectArea( "SD2" )
		DbSetOrder(3)
		dbSeek(xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA)
		
		wComis   := 0
		wValcom  := 0
		wQtditem := 0
		
		While !Eof() .AND. SD2->D2_FILIAL == XFILIAL("SD2");
			.And. SD2->D2_DOC   == SE1->E1_NUM;
			.And. SD2->D2_SERIE == SE1->E1_PREFIXO;
			.AND. SD2->D2_CLIENTE == SE1->E1_CLIENTE;
			.AND. SD2->D2_LOJA == SE1->E1_LOJA
			
			If SD2->D2_TIPO <> "N"
				DbSelectArea("SD2")
				DbSkip()
				Loop
			EndIf
			
			If SUBST(SD2->D2_GRUPO,1,2) <> "PA"
				DbSelectArea("SD2")
				DbSkip()
				Loop
			Endif
			
			DbSelectArea("SF2")
			DbSetOrder(1)
			DBSEEK(XFILIAL("SF2")+SD2->D2_DOC+SD2->D2_SERIE)
			
			DbSelectArea("SE4")
			DbSetOrder(1)
			DBSEEK(XFILIAL("SE4")+SF2->F2_COND)
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DBSEEK(XFILIAL("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			
			DbSelectArea("SF4")
			DbSetOrder(1)
			
			If DbSeek(xFilial("SF4")+SD2->D2_TES)
				
				If ( SF4->F4_DUPLIC == "S" ) .and. ( SF4->F4_ESTOQUE == "S" )
					
					wComis	:= wComis + SD2->D2_COMIS1
					wQtditem := wQtditem + 1
					
				EndIf
				
			EndIf
			
			DbSelectArea("SD2")
			DbSetOrder(3)
			DbSkip()
			
		EndDo
	
		// FILTRANDO O SEGMENTO
		IF ( SA1->A1_SATIV1 < MV_PAR05 ) .OR. ( SA1->A1_SATIV1 > MV_PAR06 )
			SE1->(DBSKIP())
			LOOP
		ENDIF
	
		
		fGrava()
		
		dbSelectArea( "SE1" )
		DbSetOrder(11)
		dbSkip()
		
	EndDo
Return

Static Function fImprime(oReport)
	Local oSecRep := oReport:Section(1) //Representante
	Local oSecTit := oReport:Section(2) //Titulo
	Local oSTot := oReport:Section(3) //Total
	Local iPrimPass := 0

	//Inicia o procedimento de impressao dos valores obtidos
	dbSelectArea("_cTrab")
	dbGotop()
	
	//Monta a linha da regua
	SETREGUA( LastRec() )
	
	wValor	 := 0
	wBase 	 := 0
	wComissao := 0
	tValor	 := 0
	tBase 	 := 0
	tComissao := 0
	wVendedor := _cTrab->VEND
	
	While !oReport:Cancel() .And. !Eof()
		//Movimenta o cursor da regua
		INCREGUA()
		
		//TRATAMENTO DE TECLAS WINDOWS
		IF lAbortPrint .OR. lEnd
			Return
		ENDIF
		
		DbSelectArea("SA3")
		DbSetOrder(1)
		If  !DbSeek(xFilial("SA3")+_cTrab->VEND)
			alert("Vendedor nao cadastrado. Codigo: "+_cTrab->VEND)
			wNomVend := " "
		Else
			wNomVend := SA3->A3_NOME
		End
		
		wVendedor := _cTrab->VEND
		
		If iPrimPass == 0
			iPrimPass := 1
		Else
			oSecRep:Finish()
		EndIf

		oSecRep:SetHeaderSection(.T.)
		oSecRep:Init()
		
		oSecRep:Cell("A3_COD"):SetValue(Alltrim(wVendedor) + " " + Alltrim(wNomVend))
		oSecRep:PrintLine()
	
		While wVendedor == _cTrab->VEND .And. !Eof()
			oSecTit:Init()
			
			oSecTit:Cell("PREFIXO"):SetValue(_cTrab->PREFIXO)
			oSecTit:Cell("NUM"):SetValue(_cTrab->NUM)
			oSecTit:Cell("PARCELA"):SetValue(_cTrab->PARCELA)
			oSecTit:Cell("CLIENTE"):SetValue(_cTrab->CLIENTE)
			oSecTit:Cell("LOJA"):SetValue(_cTrab->LOJA)
			oSecTit:Cell("NOMCLI"):SetValue(_cTrab->NOMCLI)
			oSecTit:Cell("EMISSAO"):SetValue(_cTrab->EMISSAO)
			oSecTit:Cell("VENCTO"):SetValue(_cTrab->VENCTO)
			oSecTit:Cell("PEDIDO"):SetValue(_cTrab->PEDIDO)
			oSecTit:Cell("VALOR"):SetValue(_cTrab->VALOR)
			oSecTit:Cell("BASCOM"):SetValue(_cTrab->BASCOM)
			oSecTit:Cell("COMIS"):SetValue(_cTrab->COMIS)
			oSecTit:Cell("VALCOM"):SetValue(_cTrab->VALCOM)
			oSecTit:PrintLine()
			
			wValor	  := wValor 	+ _cTrab->VALOR
			wBase	  := wBase		+ _cTrab->BASCOM
			wComissao := wComissao + _cTrab->VALCOM
			tValor	  := tValor 	+ _cTrab->VALOR
			tBase	  := tBase		+ _cTrab->BASCOM
			tComissao := tComissao + _cTrab->VALCOM
			wVendedor := _cTrab->VEND
			
			//Busca proximo item a imprimir
			dbSelectArea("_cTrab")
			dbSkip()
		End
		
		oSecTit:Finish()
		
		//total de vendedor aqui!!!! :)
		oSTot:Init()
		
		oSTot:Cell("PREFIXO"):SetValue("Total do Vendedor -> IRRF: " + Transform(Round(wComissao * wPerc,2), "@E 999,999.99"))
		oSTot:Cell("VALOR"):SetValue(wValor)
		oSTot:Cell("BASCOM"):SetValue(wBase)
		oSTot:Cell("COMIS"):SetValue((wComissao/wBase) * 100)
		oSTot:Cell("VALCOM"):SetValue(wComissao)
		oSTot:PrintLine()
		
		oSTot:Finish()
		
		wValor	 := 0
		wBase 	 := 0
		wComissao := 0		
	End
	
	//total geral
	oSTot:Init()
	
	oSTot:Cell("PREFIXO"):SetValue("Total Geral -> IRRF: " + Transform(Round(tComissao * wPerc,2), "@E 999,999.99"))
	oSTot:Cell("VALOR"):SetValue(tValor)
	oSTot:Cell("BASCOM"):SetValue(tBase)
	oSTot:Cell("COMIS"):SetValue(Round(tComissao/tBase,4) * 100)
	oSTot:Cell("VALCOM"):SetValue(tComissao)
	oSTot:PrintLine()
	oSTot:Finish()
		
	oSecRep:Finish()
	
Return
