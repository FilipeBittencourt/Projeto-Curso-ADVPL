#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia093()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("TAMANHO,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("ARETURN,ALINHA,NOMEPROG,NLASTKEY,AORD,CBTXT")
SetPrvt("CBCONT,CABEC1,CABEC2,CABEC3,LI")
SetPrvt("M_PAG,WNREL,LEND,WVENINI,WVENFIM")
SetPrvt("WMES,WANO,WPERC,WMOEDA,WCLIINI,WCLIFIM")
SetPrvt("WDTEMISINI,WDTEMISFIM,WDTINI,WDTFIM,ACAMPOS,CARQTEMP")
SetPrvt("BCHAVESE1,WSSNUM,WCOMIS,WVALCOM,CALIAS")
SetPrvt("WQTDITEM,WVALOR,WBASE,WCOMISSAO,TVALOR,TBASE")
SetPrvt("TCOMISSAO,WVENDEDOR,WNOMVEND,WCODVEND,VEND,PREFIXO")
SetPrvt("NUM,PARCELA,CLIENTE,LOJA,NOMCLI,EMISSAO")
SetPrvt("VENCTO,PEDIDO,VALOR,WSIPI,CQUERY,NTOTREGS,CDADOS,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ BIA093	  ³ Autor ³ CESAR MAGNAGO		  ³ Data ³ 11/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Extrato de Comissoes a Pagar   			   	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Interpretador xBase											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
tamanho	 := "M"
titulo	 := "Extrato de Comissoes a Pagar"
cDesc1	 := "Emite a relacao de comissoes a pagar em um periodo qualquer."
cDesc2	 := " "
cDesc3	 := " "
aReturn	 :=  { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
aLinha	 := { }
nomeprog := "BIA093"
nLastKey := 0
aOrd	 := {"Por Vendedor"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt 	    := SPACE(10)
cbcont	    := 0
cabec1	    := "             ---------- Cliente -----------                                         Valor           Valor     %              Valor"
cabec2	    := "Prf Titulo P Codigo Lj Nome                 Emissao      Vencto    Pedido           Titulo           Base    Comis         Comissao"
cabec3	    := " "
cAlias	    := "SE1"
li 		    := 80
m_pag 	    := 1
cNomeProg   := "BIA093"   // nome default do relatorio em disco
cNomeArq    := cNomeProg
lEnd		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajuste dos parƒmetros da impress„o via fun‡„o SETPRINT       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cNomeProg,.F.)
if (nLastKey==27) .OR. (LastKey()==27)
	Return
endif
cNomeArq := SetPrint(cAlias,cNomeProg,cNomeProg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,"M")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aceita parƒmetros e faz ajustes necess rios 		        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cAlias)
wVenIni	   := mv_par01
wVenFim	   := mv_par02
wMes	   := substr(M->mv_par03,1,2)
wAno	   := subst(M->mv_par03,4,4)
wPerc 	   := mv_par04 / 100
wMoeda	   := mv_par05
wCliIni	   := mv_par06
wCliFim	   := mv_par07
wDtEmisIni := mv_par08
wDtEmisFim := mv_par09
wDtIni	   := mv_par10
wDtFim	   := mv_par11

if mv_par12 == 1
	titulo := titulo + " (titulos em aberto)"
endif

Processa({|| fCriaTemp()})
Processa({|| fAcumula() })
if nTotRegs > 0
	Processa({|| fImprime()})
endif
Processa({|| fApagaTemp()  })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a impress„o for em Disco, chama SPOOL 			      			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if aReturn[5]==1
	Set Printer to
	Commit
	OurSpool(cNomeArq)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera relatorio para Spool da Rede								       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ft_PFlush()
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fCriaTemp³ Autor ³ WLADIMIR ILLIUSHENKO	   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria uma tabela temporaria para preparacao do relatorio.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA093													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fCriaTemp()
aCampos := {}
AADD(aCampos,{"VEND",    "C",  6, 0})
AADD(aCampos,{"PREFIXO", "C",  3, 0})
AADD(aCampos,{"NUM",     "C",  6, 0})
AADD(aCampos,{"PARCELA", "C",  1, 0})
AADD(aCampos,{"CLIENTE", "C",  6, 0})
AADD(aCampos,{"LOJA",    "C",  2, 0})
AADD(aCampos,{"NOMCLI",  "C", 20, 0})
AADD(aCampos,{"EMISSAO", "D",  8, 0})
AADD(aCampos,{"VENCTO",  "D",  8, 0})
AADD(aCampos,{"PEDIDO",  "C",  6, 0})
AADD(aCampos,{"VALOR",   "N", 11, 2})
AADD(aCampos,{"BASCOM",  "N", 11, 2})
AADD(aCampos,{"COMIS",   "N",  8, 4})
AADD(aCampos,{"VALCOM",  "N", 11, 2})

cArqTemp := CriaTrab(aCampos, .T.)
dbUseArea(.T.,,cArqTemp,"REL")
DbCreateInd(cArqTemp+".001","VEND+NUM+PARCELA+DTOS(VENCTO)",{||VEND+NUM+PARCELA+DTOS(VENCTO)})
DbCreateInd(cArqTemp+".002","PREFIXO+NUM+PARCELA",{||PREFIXO+NUM+PARCELA})
OrdListClear()
OrdListAdd(cArqTemp+".001")
OrdListAdd(cArqTemp+".002")
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fAcumula ³ Autor ³ WLADIMIR ILLIUSHENKO	   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acumula os dados para serem impressos no relatorio.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA093													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fAcumula()
cQuery  := ""
cQuery  := cQuery + "SELECT COUNT(SE1.E1_NUM) AS TOTREGS "
cQuery  := cQuery + "FROM "+RetSqlName("SE1")+" SE1 "
cQuery  := cQuery + "WHERE (SE1.E1_VEND1   >= '"+MV_PAR01+"'         ) AND "
cQuery  := cQuery + "      (SE1.E1_VEND1   <= '"+MV_PAR02+"'         ) AND "
cQuery  := cQuery + "      (SE1.E1_EMISSAO >= '"+dtos(MV_PAR08)+"'  ) AND "
cQuery  := cQuery + "      (SE1.E1_EMISSAO <= '"+dtos(MV_PAR09)+"'  ) AND "
cQuery  := cQuery + "      (SE1.E1_VENCREA >= '"+dtos(MV_PAR10)+"'  ) AND "
cQuery  := cQuery + "      (SE1.E1_VENCREA <= '"+dtos(MV_PAR11)+"'  ) AND "
cQuery  := cQuery + "      (SE1.E1_CLIENTE >= '"+MV_PAR06+"'         ) AND "
cQuery  := cQuery + "      (SE1.E1_CLIENTE <= '"+MV_PAR07+"'         ) AND "
cQuery  := cQuery + iif(MV_PAR12 == 1,"(SE1.E1_SALDO > 0) AND ","")
cQuery  := cQuery + "      (SUBSTRING(SE1.E1_NATUREZ,1,4) <> '1131'  ) AND "
cQuery  := cQuery + "      (SE1.E1_VENCTO  <> '"+dtos(MV_PAR09)+"'  ) AND "
cQuery  := cQuery + "      (SE1.D_E_L_E_T_ <> '*')"
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
lOk      := (nTotRegs > 0)
X->(DbCloseArea())

if nTotRegs > 0
	DbSelectArea("SF4")
	DbSetOrder(1)
	
	DbSelectArea("SA3")
	DbSetOrder(1)
	
	cQuery  := ""
	cQuery  := cQuery + "SELECT "
	cQuery  := cQuery + "       SE1.E1_VEND1,    "
	cQuery  := cQuery + "       SE1.E1_TIPO,     "
	cQuery  := cQuery + "       SE1.E1_PREFIXO,  "
	cQuery  := cQuery + "       SE1.E1_NUM,      "
	cQuery  := cQuery + "       SE1.E1_PARCELA,  "
	cQuery  := cQuery + "       SE1.E1_NATUREZ,  "
	cQuery  := cQuery + "       SE1.E1_CLIENTE,  "
	cQuery  := cQuery + "       SE1.E1_LOJA,     "
	cQuery  := cQuery + "       SE1.E1_NOMCLI,   "
	cQuery  := cQuery + "       SE1.E1_VENCTO,   "
	cQuery  := cQuery + "       SE1.E1_PEDIDO,   "
	cQuery  := cQuery + "       SE1.E1_VALOR,    "
	cQuery  := cQuery + "       SE1.E1_SALDO,    "
	cQuery  := cQuery + "       SE1.E1_EMISSAO,  "
	cQuery  := cQuery + "       SE1.E1_BAIXA,    "
	cQuery  := cQuery + "       SE1.E1_BASCOM1   "
	cQuery  := cQuery + "FROM "+RetSqlName("SE1")+" SE1 "
	cQuery  := cQuery + "WHERE (SE1.E1_VEND1   >= '"+MV_PAR01+"'         ) AND "
	cQuery  := cQuery + "      (SE1.E1_VEND1   <= '"+MV_PAR02+"'         ) AND "
	cQuery  := cQuery + "      (SE1.E1_EMISSAO >= '"+dtos(MV_PAR08)+"'  ) AND "
	cQuery  := cQuery + "      (SE1.E1_EMISSAO <= '"+dtos(MV_PAR09)+"'  ) AND "
	cQuery  := cQuery + "      (SE1.E1_VENCREA >= '"+dtos(MV_PAR10)+"'  ) AND "
	cQuery  := cQuery + "      (SE1.E1_VENCREA <= '"+dtos(MV_PAR11)+"'  ) AND "
	cQuery  := cQuery + "      (SE1.E1_CLIENTE >= '"+MV_PAR06+"'         ) AND "
	cQuery  := cQuery + "      (SE1.E1_CLIENTE <= '"+MV_PAR07+"'         ) AND "
	cQuery  := cQuery + iif(MV_PAR12 == 1,"(SE1.E1_SALDO > 0) AND ","")
	cQuery  := cQuery + "      (SUBSTRING(SE1.E1_NATUREZ,1,4) <> '1131'  ) AND "
	cQuery  := cQuery + "      (SE1.E1_VENCTO  <> '"+dtos(MV_PAR09)+"'  ) AND "
	cQuery  := cQuery + "      (SE1.D_E_L_E_T_ <> '*')"
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs)
	
	do while !QRY->(EOF())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta o cursor da regua			     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProc("Analisando contas a receber ...")
		
		If (Alltrim(QRY->E1_VEND1) == "") .AND.;
			(QRY->E1_TIPO # "AB-")
			QRY->(dbSkip())
			Loop
		End
		
		if SUBS(QRY->E1_TIPO,1,2) # "NF"
			if QRY->E1_TIPO == "AB-"
				REL->(DBSetOrder(2))
				if REL->(DBSEEK(QRY->E1_PREFIXO+QRY->E1_NUM+QRY->E1_PARCELA,.F.))
					RECLOCK("REL",.F.)
					REL->(DBDELETE())
					REL->(DBUNLOCK())
				endif
				REL->(DBSetOrder(1))
			endif
			QRY->(dbSkip())
			Loop
		endif
		
		If QRY->E1_SALDO == 0
			wsSNum := SaldoTit(QRY->E1_PREFIXO,QRY->E1_NUM,QRY->E1_PARCELA,QRY->E1_TIPO,QRY->E1_NATUREZ,"R",QRY->E1_CLIENTE,1,,U_StoD(QRY->E1_BAIXA),QRY->E1_LOJA)
		Else
			wsSNum := QRY->E1_SALDO
		EndIf
		
		If INT(wsSNum) <= 0
			QRY->(DbSkip())
			Loop
		EndIf
		
		SA3->(DbSeek(xFilial("SA3")+QRY->E1_VEND1,.T.))
		
		cQuery  := ""
		cQuery  := cQuery + "SELECT "
		cQuery  := cQuery + "       SD2.D2_TES,    "
		cQuery  := cQuery + "       SD2.D2_COMIS1  "
		cQuery  := cQuery + "FROM "+RetSqlName("SD2")+" SD2 "
		cQuery  := cQuery + "WHERE "
		cQuery  := cQuery + "       (SD2.D2_DOC   = '"+QRY->E1_NUM+"'    ) AND "
		cQuery  := cQuery + "       (SD2.D2_SERIE = '"+QRY->E1_PREFIXO+"') AND "
		cQuery  := cQuery + "       (SUBSTRING(SD2.D2_GRUPO,1,2) = 'PA'   ) AND "
		cQuery  := cQuery + "       (SD2.D2_QUANT > 0                     ) AND "
		cQuery  := cQuery + "       (SD2.D2_TES NOT IN ('995','996','997')) AND "
		cQuery  := cQuery + "       (SD2.D2_CF IN ('5101','6101','7101','511','611','711')  ) AND "
		cQuery  := cQuery + "       (SD2.D2_TIPO = 'N'                    ) AND "
		cQuery  := cQuery + "       (SD2.D_E_L_E_T_ <> '*')"
		TCQuery cQuery Alias "QRY2" New
		
		wComis   := 0
		wValcom  := 0
		wQtditem := 0
		
		do while !QRY2->(EOF())
			if SF4->(DbSeek( xFilial("SF4")+QRY2->D2_TES, .T. ))
				If (SF4->F4_DUPLIC == "S" ) .AND. ( SF4->F4_ESTOQUE == "S" )
					wComis	 := wComis + QRY2->D2_COMIS1
					wQtditem := wQtditem + 1
				endif
			endif
			QRY2->(DbSkip())
		enddo
		QRY2->(DbCloseArea())    		
		
		SC5->(DbSetOrder(1))     
		IF SC5->(DbSeek(XFilial("SC5")+QRY->E1_PEDIDO)) .AND. (!Empty(SC5->C5_YCLIORI))  
			_COD_CLI := SC5->C5_YCLIORI
			_LOJ_CLI := SC5->C5_YLOJORI
			_NOM_CLI := POSICIONE("SA1",1,XFILIAL("SA1")+_COD_CLI+_LOJ_CLI,"A1_NOME")
		ELSE
			_COD_CLI := QRY->E1_CLIENTE
			_LOJ_CLI := QRY->E1_LOJA
			_NOM_CLI := QRY->E1_NOMCLI
		ENDIF
		
		RecLock("REL", .T.)
		
		REL->VEND	  := QRY->E1_VEND1
		REL->PREFIXO  := QRY->E1_PREFIXO
		REL->NUM	  := QRY->E1_NUM
		REL->PARCELA  := QRY->E1_PARCELA
		REL->CLIENTE  := _COD_CLI
		REL->LOJA	  := _LOJ_CLI
		REL->NOMCLI   := _NOM_CLI
		REL->EMISSAO  := U_STOD(QRY->E1_EMISSAO)
		REL->VENCTO   := U_STOD(QRY->E1_VENCTO)
		REL->PEDIDO   := QRY->E1_PEDIDO
		REL->VALOR    := xMoeda(QRY->E1_VALOR,1,wMoeda,U_STOD(QRY->E1_VENCTO))
		
		if QRY->E1_VALOR >= wsSNum
			wsSNum := QRY->E1_BASCOM1
		else
			wsIpi  := 0
			wsIpi  := wsSNum * 0.05
			wsSNum := wsSNum - wsIpi
		endif
		
		if SA3->A3_ALBAIXA <> 100
			if SF4->F4_IPI == "N"
				REL->BASCOM := xMoeda(wsSNum,1,wMoeda,U_STOD(QRY->E1_VENCTO))
			else
				REL->BASCOM := Round(xMoeda(wsSNum / 1.05,1,wMoeda,U_STOD(QRY->E1_VENCTO)),2)
			endif
		else
			REL->BASCOM := xMoeda(wsSNum,1,wMoeda,U_STOD(QRY->E1_VENCTO))
		endif
		
		if QRY->E1_VEND1 == "999999" 
			if SF4->F4_IPI == "S"
				REL->COMIS := 0
				REL->BASCOM := ROUND(xMoeda(wsSNum / 1.05,1,wMoeda,U_STOD(QRY->E1_VENCTO)),2)
			else
				REL->COMIS := 0
				REL->BASCOM := xMoeda(wsSNum,1,wMoeda,U_STOD(QRY->E1_VENCTO))
			endIf
		else
			REL->COMIS := wComis / wQtditem
		endif
		
		If QRY->E1_NUM == "004744"
			REL->BASCOM := 0
		EndIf
		
		REL->VALCOM := xMoeda((REL->BASCOM * REL->COMIS) / 100,wMoeda,wMoeda,U_STOD(QRY->E1_VENCTO))
		REL->(DbUnlock())
		
		QRY->(DbSkip())
	EndDo
	QRY->(DbCloseArea())
else
	alert("Nao foram encontrados dados que satisfacam os parametros informados!")
endif
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fImprime ³ Autor ³ WLADIMIR ILLIUSHENKO	   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do relatorio.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA093													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImprime()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia o procedimento de impressao dos valores obtidos				      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("REL")
dbGotop()
ProcRegua(REL->(LastRec()))

wValor	 := 0
wBase 	 := 0
wComissao := 0
tValor	 := 0
tBase 	 := 0
tComissao := 0
wVendedor := REL->VEND

do while !REL->(EOF())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta o cursor da regua 			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc("Imprimindo ...")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa se houve quebra de vendedor 								       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  REL->VEND <> wVendedor
		li := li + 1
		
		cDados := ""
		cDados := cDados + "Total do Vendedor -> IRRF:"                               + space(01)
		cDados := cDados + Transform(Round(wComissao * wPerc,2),"@E 999,999.99")    + space(40)
		cDados := cDados + Transform(wValor,"@E 999,999,999.99")                     + space(01)
		cDados := cDados + Transform(wBase,"@E 999,999,999.99")                      + space(03)
		cDados := cDados + Transform((wComissao/wBase) * 100,"@E 999.99")           + space(03)
		cDados := cDados + Transform(wComissao	,"@E 999,999,999.99")
		@Li,0 PSay cDados
		li := li + 1
		
		@Li,0 PSAY "------------------------------------------------------------------------------------------------------------------------------------"
		li := li + 2
		
		if (li < 78) .AND. (REL->VEND == wVendedor)
			if !SA3->(DbSeek(xFilial()+REL->VEND))
				alert("Vendedor nao cadastrado. Codigo: "+REL->VEND)
				wNomVend := " "
			else
				wNomVend := SA3->A3_NOME
			endif
			
			cDados := ""
			cDados := cDados + "Vendedor: " + space(01)
			cDados := cDados + wNomVend
			@li,0 PSay cDados
			li := li + 2
		End
		wValor	 := 0
		wBase 	 := 0
		wComissao := 0
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa se houve quebra de pagina										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF  li >= 65 .OR. REL->VEND <> wVendedor
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		If  !SA3->(DbSeek(xFilial()+REL->VEND))
			alert("Vendedor nao cadastrado. Codigo: "+REL->VEND)
			wNomVend := " "
		Else
			wNomVend := SA3->A3_NOME
			wCodVend := SA3->A3_COD
		End
		cDados := ""
		cDados := cDados + "Vendedor: " + space(01)
		cDados := cDados + wCodVend     + space(02)
		cDados := cDados + wNomVend     + space(02)
		@li,0 PSay cDados
		li := li + 2
	End
	
	cDados := ""
	cDados := cDados + REL->PREFIXO + space(01)
	cDados := cDados + REL->NUM     + space(01)
	cDados := cDados + REL->PARCELA + space(01)
	cDados := cDados + REL->CLIENTE + space(01)
	cDados := cDados + REL->LOJA    + space(01)
	cDados := cDados + REL->NOMCLI  + space(01)
	cDados := cDados + Transform(REL->EMISSAO,"@D")  + space(05)
	cDados := cDados + Transform(REL->VENCTO,"@D")   + space(02)
	cDados := cDados + Transform(REL->PEDIDO,"@!")   + space(03)
	cDados := cDados + Transform(REL->VALOR,"@E 999,999,999.99")  + space(01)
	cDados := cDados + Transform(REL->BASCOM,"@E 999,999,999.99") + space(01)
	cDados := cDados + Transform(REL->COMIS,"@E 9,999.99")        + space(03)
	cDados := cDados + Transform(REL->VALCOM,"@E 999,999,999.99")
	@li,0 PSay cDados
	li:=li+1
	
	wValor	  := wValor 	+ REL->VALOR
	wBase	  := wBase		+ REL->BASCOM
	wComissao := wComissao + REL->VALCOM
	tValor	  := tValor 	+ REL->VALOR
	tBase	  := tBase		+ REL->BASCOM
	tComissao := tComissao + REL->VALCOM
	wVendedor := REL->VEND
	
	REL->(DbSkip())
Enddo

cDados := ""
cDados := cDados + "Total do Vendedor -> IRRF:"                               + space(01)
cDados := cDados + Transform(Round(wComissao * wPerc,2),"@E 999,999.99")    + space(39)
cDados := cDados + Transform(wValor,"@E 999,999,999.99")                     + space(01)
cDados := cDados + Transform(wBase,"@E 999,999,999.99")                      + space(03)
cDados := cDados + Transform((wComissao/wBase) * 100,"@E 999.99")           + space(03)
cDados := cDados + Transform(wComissao	,"@E 999,999,999.99")
@Li,0 PSay cDados
li := li + 1

@li,0 PSay "------------------------------------------------------------------------------------------------------------------------------------"
li := li + 2

cDados := ""
cDados := cDados + "Total Geral       -> IRRF:"                               + space(01)
cDados := cDados + Transform(Round(tComissao * wPerc,2),"@E 999,999.99")    + space(40)
cDados := cDados + Transform(tValor,"@E 999,999,999.99")                     + space(01)
cDados := cDados + Transform(tBase,"@E 999,999,999.99")                      + space(01)
cDados := cDados + Transform((tComissao/tBase) * 100,"@E 999.99")           + space(01)
cDados := cDados + Transform(tComissao	,"@E 999,999,999.99")
@Li,0 PSay cDados
li := li + 2

@li,0 PSAY "------------------------------------------------------------------------------------------------------------------------------------"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impress„o do rodap‚ 													  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if  li != 65
	//	roda(cbcont,cbtxt,"M")
End
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fApagaTemp ³ Autor ³ WLADIMIR ILLIUSHENKO 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apaga as tabelas temporarias.    					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA093											      	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fApagaTemp
Static Function fApagaTemp()
REL->(DbCloseArea())
Ferase(cArqTemp+".DBF")
Ferase(cArqTemp+".001")
Ferase(cArqTemp+".002")
Return
