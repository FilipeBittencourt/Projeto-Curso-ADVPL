#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/
#include "topconn.ch"

user function BIA167()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao basica.                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,CQUERY,CWHERE")
SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP,CTIPO")
SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT")
SetPrvt("ARETURN,ACAMPOS")
SetPrvt("NCRCCONTROL,NL,NTOTREGS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao particular.                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("CCLI,CPROD,CPERGUNTA,CCLIENTES")
SetPrvt("ACLIENTES")
SetPrvt("NQTDM2,NTOTVEND,NQTDM2CLI,NTOTVENDCLI,NQTDM2GER,NTOTVENDGER,NI")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA167   ³ Autor ³ Cesar Magnago         ³ Data ³ 06/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Pedidos de Compras (Em Aberto)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Compras                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDesc1     := "Este programa ira emitir um Relatorio de Pedidos de Compras em "
cDesc2     := "aberto conforme parametros solicitados."
cDesc3     := ""
cTamanho   := "G"
cAlias     := "SC7"
aReturn    := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cNomeprog  := "BIA167"
nCbCont    := 0
cCbTxt     := space(10)
m_pag      := 1
aOrd       := { }
lGravParam := .F.
lPodeComp  := .T.
lTemDic    := .F.
lGravParam := .F.
nL         := 80
nLimite    := 132
nLastKey   := 0
lRodape    := .F.
lContinua  := .T.
cTitulo    := "Relatorio de Pedidos de Compras (Em Aberto) da Entrega de "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela padrao de relatorios                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho)
if lastkey()==27 .OR. nLastKey==27
	Return
endif

Pergunte(cNomeProg,lGravParam)
SetDefault(aReturn, cAlias)
if lastkey()==27 .OR. nLastKey==27
	Return
endif

nCrcControl := IIF(aReturn[4]==1,15,18)
cCabec1     := "PEDIDO  ITEM  DESCRICAO PRODUTO               C.CUSTO       FORNECEDOR                         EMISSAO     ENTREGA    COND.PAGTO       FRETE  FLUXO  TES            TOTAL"
cCabec2     := ""
cTitulo     := cTitulo+Padr(Dtoc(MV_PAR01),10)+" ate "+Padr(Dtoc(MV_PAR02),10)
//              XXXXXX   XX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXX   XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXX  XX/XX/XXXX  XX/XX/XXXX  XXXXXXXXXXXXXXX   XXX     X    XXX   XXX.XXX.XXX,XX
//              0        10   15                                49     56     63                         70          82          93                111     119  124   130

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aceita parƒmetros e faz ajustes necess rios.                           ³
//ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ mv_par01 ³ Da  Entrega                                                 ³
//³ mv_par02 ³ Ate Entrega                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Processa({|| Imprime() })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao.												                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if aReturn[5] == 1 .and. nTotRegs > 0
	set printer to
	OurSpool(cNomeArq)
endif
Ft_PFlush()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³ Imprime    ³ Imprime o relatorio                                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imprime()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa a existencia e quantidade de dados na condicao estabelecida pelo...³
//³ usuario.                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cWhere := ""
cQuery += "SELECT COUNT(SC7.C7_NUM) AS TOTREGS "
cWhere += "FROM "+RetSqlName("SC7")+" SC7, "+RetSqlName("SA2")+" SA2,"+RetSqlName("SE4")+" SE4 "
cWhere += "WHERE "
cWhere += "SC7.C7_FILIAL  = '"+xFilial("SC7")+"'                                	AND "
cWhere += "SC7.C7_DATPRF  BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'	AND "
cWhere += "SC7.C7_ENCER   = ''                                                  	AND "
cWhere += "SC7.C7_RESIDUO = ''                                                  	AND "
cWhere += "SC7.C7_QUANT   - SC7.C7_QUJE > 0                                     	AND "
cWhere += "SA2.A2_COD     = SC7.C7_FORNECE                                      	AND "
cWhere += "SE4.E4_CODIGO  = SC7.C7_COND                                         	AND "
cWhere += "SA2.D_E_L_E_T_ = ''                                               		AND "
cWhere += "SE4.D_E_L_E_T_ = ''                                               		AND "
cWhere += "SC7.D_E_L_E_T_ = '' "
cQuery := cQuery + cWhere
TcQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

if nTotRegs > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre a query com os campos selecionado abaixo.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "SC7.C7_ITEM, "
	cQuery  += "SC7.C7_DESCRI, "
	cQuery  += "SC7.C7_TOTAL, "
	cQuery  += "SC7.C7_DATPRF, "
	cQuery  += "SC7.C7_FORNECE, "
	cQuery  += "SC7.C7_CLVL, "
	cQuery  += "SC7.C7_EMISSAO, "
	cQuery  += "SC7.C7_NUM, "
	cQuery  += "SC7.C7_QUJE, "
	cQuery  += "SC7.C7_TPFRETE, "
	cQuery  += "SC7.C7_ENCER, "
	cQuery  += "SC7.C7_FLUXO, "
	cQuery  += "SC7.C7_TES, "
	cQuery  += "SA2.A2_NOME, "
	cQuery  += "SE4.E4_DESCRI, "
	cQuery  += "SC7.D_E_L_E_T_, "
	cQuery  += "SA2.D_E_L_E_T_, "
	cQuery  += "SE4.D_E_L_E_T_ "
	cQuery  += "FROM "+RetSqlName("SC7")+" SC7, "+RetSqlName("SA2")+" SA2, "+RetSqlName("SE4")+" SE4 "
	cQuery  += "WHERE "
	cQuery  += "SC7.C7_FILIAL  = '"+xFilial("SC7")+"'                                	AND "
	cQuery  += "SC7.C7_DATPRF  BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'	AND "
	cQuery  += "SC7.C7_ENCER   = ''                                                  	AND "
	cQuery  += "SC7.C7_RESIDUO = ''                                                  	AND "
	cQuery  += "SC7.C7_QUANT - SC7.C7_QUJE > 0                                       	AND "
	cQuery  += "SA2.A2_COD     = SC7.C7_FORNECE                                      	AND "
	cQuery  += "SE4.E4_CODIGO  = SC7.C7_COND                                         	AND "
	cQuery  += "SA2.D_E_L_E_T_ = ''                                               		AND "
	cQuery  += "SE4.D_E_L_E_T_ = ''                                               		AND "
	cQuery  += "SC7.D_E_L_E_T_ = '' "
	cQuery  += "ORDER BY "
	cQuery  += "SC7.C7_DATPRF, "
	cQuery  += "SC7.C7_NUM, SC7.C7_ITEM "
	TcQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs)
	
	Do while !QRY->(EOF())
		
		Incproc("Imprimindo Pedidos de Compras...")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento da impressao pelo usuario.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lAbortPrint)
			Return
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime parametros.                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if m_pag == 1
			cOldAlias := Alias()
			DBSelectArea("SX1")
			DBSetOrder(1)
			
			if SX1->(DBSeek(cNomeProg+"01"))
				do while SX1->X1_GRUPO == cNomeProg
					if nL >= 65
						nL := Cabec("Parametros - "+cTitulo,"","",cNomeProg,cTamanho,nCrcControl) + 2
					endif
					
					cPergunta := ""
					do case
						case SX1->X1_GSC == "C"
							do case
								case SX1->X1_PRESEL == 1; cPergunta := SX1->X1_DEF01
								case SX1->X1_PRESEL == 2; cPergunta := SX1->X1_DEF02
								case SX1->X1_PRESEL == 3; cPergunta := SX1->X1_DEF03
								case SX1->X1_PRESEL == 4; cPergunta := SX1->X1_DEF04
								case SX1->X1_PRESEL == 5; cPergunta := SX1->X1_DEF05
							endcase
							
						case SX1->X1_GSC == "G"; cPergunta := SX1->X1_CNT01
					endcase
					
					cLinDeImp := ""
					cLinDeImp += "Pergunta "+SX1->X1_ORDEM+": "+SX1->X1_PERGUNT+"  "+cPergunta
					@ nL,000 PSay cLinDeImp
					nL+=2
					
					SX1->(DBSkip())
				enddo
			endif
			DBSelectArea(cOldAlias)
			nL := 99
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho.												              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if nL >= 65
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
		endif
		
		cDados := ""
		cDados += QRY->C7_NUM                            	+ Space(03)
		cDados += QRY->C7_ITEM                           	+ Space(03)
		cDados += Subs(QRY->C7_DESCRI,1,30)              	+ Space(04)
		cDados += QRY->C7_CLVL                           	+ Space(03)
		cDados += QRY->C7_FORNECE                        	+ "-"
		cDados += Subs(QRY->A2_NOME,1,25)                	+ Space(02)
		cDados += Padr(Dtoc(u_stod(QRY->C7_EMISSAO)),10)	+ Space(02)
		cDados += Padr(Dtoc(u_stod(QRY->C7_DATPRF)),10) 	+ Space(02)
		cDados += Subs(QRY->E4_DESCRI,1,15)              	+ Space(03)
		cDados += If(QRY->C7_TPFRETE=="C","CIF","FOB")   	+ Space(05)
		cDados += QRY->C7_FLUXO                          	+ Space(04)
		cDados += QRY->C7_TES                            	+ Space(03)
		cDados += u_rtoc(QRY->C7_TOTAL,"@E 999,999,999.99")
		@nL,000 PSay cDados
		nL++
		
		QRY->(dbSkip())
	Enddo
	
	QRY->(DbCloseArea())
	
Endif
Return

