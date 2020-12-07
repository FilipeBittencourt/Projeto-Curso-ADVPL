#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia073()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ")
SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP")
SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP")
SetPrvt("ARETURN,ACAMPOS,AORD")
SetPrvt("NLIN,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ BIA073	³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³22/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de vendas por Representante dos ultimos 6 meses. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFAT													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis.													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDesc1			:= "Este programa tem como objetivo emitir um relatorio do total de vendas de cada "
cDesc2			:= "cliente nos ultimos 6 meses organizado por representante, onde o total e igual "
cDesc3			:= "ou maior que o valor especificado no parametro.                                "
cTamanho	    := "G"
cAlias 			:= "SC6"
cTitulo			:= "VENDAS POR REPRESENTANTE NOS ULTIMOS 6 MESES"
aReturn			:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cNomeProg 		:= "BIA073"
nCbcont			:= 0
cCbtxt 			:= space(10)
m_pag 			:= 1
aOrd			:= { }
lGravParam 	    := .F.
cCabec1			:= "CODIGO   REPRESENTANTE                            CIDADE           UF  TELEFONE        --------------------------------QUANTIDADE FATURADA NESTE MES E NOS ULTIMO 5 MESES------------------------------------          TOTAL"
cCabec2			:= "         CLIENTE                                                                                  "+fMesAno(0)+space(13)+fMesAno(-1)+space(13)+fMesAno(-2)+space(13)+fMesAno(-3)+space(13)+fMesAno(-4)+space(13)+fMesAno(-5)
lPodeComp       := .T.
lTemDic	        := .F.
lGravParam      := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									 ³
//³ Verifica Posicao do Formulario na Impressora.							 ³
//³                                          								 ³
//³ Pega os valores passados como parametro: 								 ³
//³ MV_PAR01 -> Quantidade minima ?          								 ³
//³ MV_PAR02 -> Do representante  ?          								 ³
//³ MV_PAR03 -> Ate o representante ?        								 ³
//³ MV_PAR04 -> Somente venda dos ultimo 6 meses?                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho)
Pergunte(cNomeProg,lGravParam)
if lastkey()==27
	Return
endif
SetDefault(aReturn, cAlias)

cTitulo := cTitulo + " IGUAL OU MAIOR QUE "+AllTrim(u_rtoc(MV_PAR01))+" M2"

Processa({|| fCriaTemp() })
Processa({|| fAcumula()  })
Processa({|| fImprime()  })
Processa({|| fApagaTemp()})
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fCriaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria, abre e indexa uma tabela temporaria por codigo	...   ³±±
±±³			 ³ do Representante, Cidade do Cliente e Codigo do Cliente.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION fCriaTemp()
aCampos := {}
AADD(aCampos,{ "CODREP" , "C", 06, 0 })
AADD(aCampos,{ "NOMREP" , "C", 40, 0 })
AADD(aCampos,{ "CODCLI" , "C", 06, 0 })
AADD(aCampos,{ "NOMCLI" , "C", 39, 0 })
AADD(aCampos,{ "TELCLI" , "C", 15, 0 })
AADD(aCampos,{ "CIDCLI" , "C", 15, 0 })
AADD(aCampos,{ "UFCLI " , "C", 02, 0 })
AADD(aCampos,{ "VENDA0" , "N", 15, 2 })
AADD(aCampos,{ "VENDA1" , "N", 15, 2 })
AADD(aCampos,{ "VENDA2" , "N", 15, 2 })
AADD(aCampos,{ "VENDA3" , "N", 15, 2 })
AADD(aCampos,{ "VENDA4" , "N", 15, 2 })
AADD(aCampos,{ "VENDA5" , "N", 15, 2 })
AADD(aCampos,{ "VENDAS" , "N", 15, 2 })
cArqTemp := CriaTrab(aCampos, .T.)
DbUseArea(.T.,, cArqTemp, "REL")
DbCreateInd(cArqTemp+".001","CODREP+str(VENDAS)+CODCLI", {||CODREP+str(VENDAS)+CODCLI})
DbCreateInd(cArqTemp+".002","CODREP+CODCLI", {||CODREP+CODCLI})
OrdListClear()
OrdListAdd(cArqTemp+".001")
OrdListAdd(cArqTemp+".002")
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fProcessa³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona os pedidos dos ultimos 6 meses iguais ou 	....  ³±±
±±³			 ³ ou maiores do que o especificado no parametro.			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function fAcumula()
Enter := chr(13) + Chr(10)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reconfigura os indices das tabelas necessarias.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SC5->(DbSetOrder(1))
SA1->(DbSetOrder(1))
SA3->(DbSetOrder(1))

REL->(DBCloseArea())
DbUseArea(.T.,,cArqTemp,"REL")
REL->(DbCreateInd(cArqTemp+".002","CODREP+CODCLI", {||CODREP+CODCLI}))

If MV_PAR04 = 1
	GeraDuplicata := "S"
elseIf MV_PAR04 = 2
	GeraDuplicata := "N"
else
	GeraDuplicata := "A"	
end if

If MV_PAR05 = 1
	AtualizaEstoque := "S"
elseIf MV_PAR05 = 2
	AtualizaEstoque := "N"
else
	AtualizaEstoque := "A"	
end if


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina a data limite para o ultimo dia do 5o mes anterior ao mes    ³
//³ atual.                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDataLimite := ctod("01/"+fMesAno(-5))

cQuery  := ""
cQuery  := cQuery + "SELECT COUNT(C6_NUM) AS TOTREGS " + Enter
cQuery  := cQuery + "FROM "+RetSqlName("SC6")+" SC6, "+RetSqlName("SF4")+"  SF4 " + Enter
cQuery  := cQuery + " WHERE " + Enter

cQuery  := cQuery + "SF4.F4_CODIGO = SC6.C6_TES AND " + Enter
IF GeraDuplicata <> "A"
	cQuery  := cQuery + "SF4.F4_DUPLIC = '"+ GeraDuplicata +"' AND	 " + Enter
END IF
IF AtualizaEstoque <> "A"
	cQuery  := cQuery + "SF4.F4_ESTOQUE = '"+ AtualizaEstoque +"' AND " + Enter
END IF
cQuery  := cQuery + "C6_SERIE BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"'	AND " + Enter

cQuery  := cQuery + "      (SC6.C6_FILIAL    = '"+xFilial("SC6")+"'   ) AND " + Enter
cQuery  := cQuery + "      (SC6.C6_DATFAT   >= '"+dtos(dDataLimite)+"') AND "   + Enter
cQuery  := cQuery + "      (RTRIM(C6_UM) = 'M2'                    ) AND "   + Enter
cQuery  := cQuery + "" + Enter
cQuery  := cQuery + "      (SC6.C6_NUM IN "                                      + Enter
cQuery  := cQuery + "      (SELECT SC5.C5_NUM " + Enter
cQuery  := cQuery + "       FROM "+RetSqlName("SC5")+" SC5 " + Enter
cQuery  := cQuery + "       WHERE " + Enter
cQuery  := cQuery + "             (SC5.C5_NUM = SC6.C6_NUM) AND " + Enter
cQuery  := cQuery + "             (SC5.D_E_L_E_T_ <> '*') " + Enter
cQuery  := cQuery + "      )) AND " + Enter
cQuery  := cQuery + "" + Enter
cQuery  := cQuery + "      (SC6.C6_NUM IN "                                      + Enter
cQuery  := cQuery + "      (SELECT SC5.C5_NUM " + Enter
cQuery  := cQuery + "       FROM "+RetSqlName("SC5")+" SC5 " + Enter
cQuery  := cQuery + "       WHERE " + Enter
cQuery  := cQuery + "             (SC5.C5_VEND1 >= RTRIM('"+MV_PAR02+"')) AND " + Enter
cQuery  := cQuery + "             (SC5.C5_VEND1 <= RTRIM('"+MV_PAR03+"')) AND " + Enter
cQuery  := cQuery + "             (SC5.D_E_L_E_T_ <> '*') " + Enter
cQuery  := cQuery + "      )) AND " + Enter
cQuery  := cQuery + "" + Enter
cQuery  := cQuery + "      (SC6.C6_PRODUTO IN "                                  + Enter
cQuery  := cQuery + "      (SELECT B1_COD " + Enter
cQuery  := cQuery + "       FROM "+RetSqlName("SB1")+" SB1 " + Enter
cQuery  := cQuery + "       WHERE " + Enter
cQuery  := cQuery + "             (SB1.B1_COD         = SC6.C6_PRODUTO) AND " + Enter
cQuery  := cQuery + "             (RTRIM(SB1.B1_TIPO) = 'PA'      ) AND " + Enter
cQuery  := cQuery + "             (D_E_L_E_T_ <> '*') " + Enter
cQuery  := cQuery + "      )) AND " + Enter
cQuery  := cQuery + "" + Enter
cQuery  := cQuery + "      (SC6.D_E_L_E_T_ <> '*')" + Enter
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

if nTotRegs > 0
	cQuery  := ""
	cQuery  := cQuery + "SELECT " + Enter
	cQuery  := cQuery + "       SC6.C6_NUM,    " + Enter
	cQuery  := cQuery + "       SC6.C6_DATFAT, " + Enter
	cQuery  := cQuery + "       SC6.C6_QTDVEN  " + Enter
	cQuery  := cQuery + "FROM "+RetSqlName("SC6")+" SC6, "+RetSqlName("SF4")+"  SF4 " + Enter
	cQuery  := cQuery + "WHERE " + Enter
   //BRUNO MADALENO
	cQuery  := cQuery + "SF4.F4_CODIGO = SC6.C6_TES AND " + Enter
	IF GeraDuplicata <> "A"
		cQuery  := cQuery + "SF4.F4_DUPLIC = '"+ GeraDuplicata +"' AND	 " + Enter
	END IF
	IF AtualizaEstoque <> "A"
		cQuery  := cQuery + "SF4.F4_ESTOQUE = '"+ AtualizaEstoque +"' AND " + Enter
	END IF
	cQuery  := cQuery + "C6_SERIE BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"'	AND " + Enter
	//FIM BRUNO MADALENO	
	cQuery  := cQuery + "      (SC6.C6_FILIAL    = '"+xFilial("SC6")+"'   ) AND " + Enter
	cQuery  := cQuery + "      (SC6.C6_DATFAT   >= '"+dtos(dDataLimite)+"') AND "  + Enter     && Somente produtos faturados nos ultimos 6 meses.
	cQuery  := cQuery + "      (RTRIM(SC6.C6_UM) = 'M2'                    ) AND "   + Enter    && Somente se a unidade de medida for m2.
	cQuery  := cQuery + "" + Enter
	cQuery  := cQuery + "      (SC6.C6_NUM IN "  + Enter                                        && Somente se o pedido existe.
	cQuery  := cQuery + "      (SELECT SC5.C5_NUM " + Enter
	cQuery  := cQuery + "       FROM "+RetSqlName("SC5")+" SC5 " + Enter
	cQuery  := cQuery + "       WHERE " + Enter
	cQuery  := cQuery + "             (SC5.C5_NUM = SC6.C6_NUM) AND " + Enter
	cQuery  := cQuery + "             (SC5.D_E_L_E_T_ <> '*') " + Enter
	cQuery  := cQuery + "      )) AND " + Enter
	cQuery  := cQuery + "" + Enter
	cQuery  := cQuery + "      (SC6.C6_NUM IN "    + Enter                                      && Somente os representantes especificados nos parametros.
	cQuery  := cQuery + "      (SELECT SC5.C5_NUM " + Enter
	cQuery  := cQuery + "       FROM "+RetSqlName("SC5")+" SC5 " + Enter
	cQuery  := cQuery + "       WHERE " + Enter
	cQuery  := cQuery + "             (SC5.C5_VEND1 >= RTRIM('"+MV_PAR02+"')) AND " + Enter
	cQuery  := cQuery + "             (SC5.C5_VEND1 <= RTRIM('"+MV_PAR03+"')) AND " + Enter
	cQuery  := cQuery + "             (SC5.D_E_L_E_T_ <> '*') " + Enter
	cQuery  := cQuery + "      )) AND " + Enter
	cQuery  := cQuery + "" + Enter
	cQuery  := cQuery + "      (SC6.C6_PRODUTO IN "   + Enter                                   && Somente produto acabado.
	cQuery  := cQuery + "      (SELECT SB1.B1_COD " + Enter
	cQuery  := cQuery + "       FROM "+RetSqlName("SB1")+" SB1 " + Enter
	cQuery  := cQuery + "       WHERE " + Enter
	cQuery  := cQuery + "             (SB1.B1_COD         = SC6.C6_PRODUTO) AND " + Enter
	cQuery  := cQuery + "             (RTRIM(SB1.B1_TIPO) = 'PA'      ) AND " + Enter
	cQuery  := cQuery + "             (SB1.D_E_L_E_T_ <> '*') " + Enter
	cQuery  := cQuery + "      )) AND " + Enter
	cQuery  := cQuery + "" + Enter
	cQuery  := cQuery + "      (SC6.D_E_L_E_T_ <> '*')" + Enter
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs)
	do while QRY->(!EOF())
		
		IncProc("Processando...")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Localiza o cabecalho do item de pedido atual.            				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC5->(DBSeek(xFilial("SC5")+QRY->C6_NUM))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Localiza o nome do representante.                        				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNomeRep := "REP. INEXISTENTE!"
		if SA3->(DBSeek(xFilial("SA3")+SC5->C5_VEND1))
			cNomeRep := SA3->A3_NOME
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Localiza o nome do cliente.                        					     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNomeCli := "CLI. INEXISTENTE!"
		if SA1->(DBSeek(xFilial("SA1")+SC5->C5_CLIENTE))
			cNomeCli := SA1->A1_NOME
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava os dados obtidos, na tabela temporaria.						     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMesAnoVenda := substr(QRY->C6_DATFAT,5,2)+"/"+substr(QRY->C6_DATFAT,1,4)
		
		if !REL->(DBSeek(SC5->C5_VEND1+SC5->C5_CLIENTE))
			RecLock("REL", .T.)
			REL->CODREP := SC5->C5_VEND1
			REL->CODCLI := SC5->C5_CLIENTE
			REL->NOMREP := cNomeRep			
			REL->NOMCLI := cNomeCli
			REL->TELCLI := SA1->A1_TEL
			REL->CIDCLI := SA1->A1_MUN
			REL->UFCLI  := SA1->A1_EST
		else
			RecLock("REL", .F.)
		endif
		
		do case
			case cMesAnoVenda == fMesAno(0) ; REL->VENDA0 += QRY->C6_QTDVEN
			case cMesAnoVenda == fMesAno(-1); REL->VENDA1 += QRY->C6_QTDVEN
			case cMesAnoVenda == fMesAno(-2); REL->VENDA2 += QRY->C6_QTDVEN
			case cMesAnoVenda == fMesAno(-3); REL->VENDA3 += QRY->C6_QTDVEN
			case cMesAnoVenda == fMesAno(-4); REL->VENDA4 += QRY->C6_QTDVEN
			case cMesAnoVenda == fMesAno(-5); REL->VENDA5 += QRY->C6_QTDVEN
		endcase
		REL->VENDAS += QRY->C6_QTDVEN
		REL->(DbUnlock())
		
		QRY->(DbSkip())
	enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui do relatorio todos os cliente onde a quantidade vendida e menor ..³
	//³ do que a quantidade passada como parametro.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	REL->(DbGoTop())
	ProcRegua(REL->(LastRec()))
	do while REL->(!EOF())
		IncProc("Filtrando os dados processados ...")		
		if REL->VENDAS < MV_PAR01			
		    do while !RecLock("REL", .F.); enddo
			REL->(DBDelete())			
			REL->(DBUnlock())
		endif		
		REL->(DbSkip())
	enddo
else
	alert("Nao ha dados para serem processados!")
endif

return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fImprime  ³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime os dados da tabela temporaria. 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION fImprime()
LOCAL TOTAL1 := 0
LOCAL TOTAL2 := 0
LOCAL TOTAL3 := 0
LOCAL TOTAL4 := 0
LOCAL TOTAL5 := 0
LOCAL TOTAL6 := 0
LOCAL V_TOTAL1 := 0
LOCAL V_TOTAL2 := 0
LOCAL V_TOTAL3 := 0
LOCAL V_TOTAL4 := 0
LOCAL V_TOTAL5 := 0
LOCAL V_TOTAL6 := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a tabela temporaria.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodRep := "XX"
nLi     := 80

REL->(DBCloseArea())
DbUseArea(.T.,,cArqTemp,"REL")
REL->(DbCreateInd(cArqTemp+".001","CODREP+str(VENDAS)+CODCLI", {||CODREP+str(VENDAS)+CODCLI}))
REL->(DbGoTop())
ProcRegua(REL->(LastRec()))
do while REL->(!EOF())
	
	Incproc("Imprimindo...")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho.												     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nLi >= 60
		nLi := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime a linha de dados do relatorio.									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if cCodRep <> REL->CODREP		
		@ nLi, 000 pSay Replicate("-",132)
	    nLi++ 
	    if cCodRep <> "XX"
	    	cDados := "TOTAL DO VENDEDDOR -- " +  padr(REL->NOMREP,40)  + space(29)
			cDados += u_rtoc(TOTAL1) + space(06)
			cDados += u_rtoc(TOTAL2) + space(06)
			cDados += u_rtoc(TOTAL3) + space(06)
			cDados += u_rtoc(TOTAL4) + space(06)
			cDados += u_rtoc(TOTAL5) + space(06)
			cDados += u_rtoc(TOTAL6) + space(01)
			@ nLi,000 PSay cDados
			TOTAL1 :=  0
			TOTAL2 :=  0
			TOTAL3 :=  0
			TOTAL4 :=  0
			TOTAL5 :=  0
			TOTAL6 :=  0
			nLi++
			@ nLi, 000 pSay Replicate("-",132)
	       	nLi += 2
	    endif   
		cDados := ""
		cDados += REL->CODREP + " - "
		cDados += padr(REL->NOMREP,40)
		@ nLi,000 PSay cDados
		nLi     += 2
		IF cCodRep <> "XX" 

		END IF
		cCodRep := REL->CODREP
	endif
	
	cDados := ""
	cDados += REL->CODCLI		     + space(03)
	cDados += padr(REL->NOMCLI,39) + space(02)
	cDados += padr(REL->CIDCLI,15) + space(02)
	cDados += padr(REL->UFCLI,2)   + space(02)
	cDados += padr(REL->TELCLI,15) + space(05)
	cDados += u_rtoc(REL->VENDA0)  + space(06)
	cDados += u_rtoc(REL->VENDA1)  + space(06)
	cDados += u_rtoc(REL->VENDA2)  + space(06)
	cDados += u_rtoc(REL->VENDA3)  + space(06)
	cDados += u_rtoc(REL->VENDA4)  + space(06)
	cDados += u_rtoc(REL->VENDA5)  + space(01)
	cDados += u_rtoc(REL->VENDAS)
	TOTAL1 += REL->VENDA0
	TOTAL2 += REL->VENDA1
	TOTAL3 += REL->VENDA2
	TOTAL4 += REL->VENDA3
	TOTAL5 += REL->VENDA4
	TOTAL6 += REL->VENDA5

	// TOTAL GERAL 
	V_TOTAL1 += REL->VENDA0
	V_TOTAL2 += REL->VENDA1
	V_TOTAL3 += REL->VENDA2
	V_TOTAL4 += REL->VENDA3
	V_TOTAL5 += REL->VENDA4
	V_TOTAL6 += REL->VENDA5
	
	@ nLi, 000 PSay cDados
	nLi++
	
	REL->(DbSkip())
enddo

if REL->(LastRec()) > 0
		nLi++	
    	cDados := "TOTAL DO VENDEDDOR -- " +  padr(REL->NOMREP,40)  + space(29)
		cDados += u_rtoc(TOTAL1) + space(06)
		cDados += u_rtoc(TOTAL2) + space(06)
		cDados += u_rtoc(TOTAL3) + space(06)
		cDados += u_rtoc(TOTAL4) + space(06)
		cDados += u_rtoc(TOTAL5) + space(06)
		cDados += u_rtoc(TOTAL6) + space(01)
		@ nLi,000 PSay cDados
	
	nLi++
	nLi++
	@ nLi, 000 pSay Replicate("-",132)
	nLi++
   	cDados := "TOTAL GERAL " +  padr("--",40)  + space(39)
	cDados += u_rtoc(V_TOTAL1) + space(06)
	cDados += u_rtoc(V_TOTAL2) + space(06)
	cDados += u_rtoc(V_TOTAL3) + space(06)
	cDados += u_rtoc(V_TOTAL4) + space(06)
	cDados += u_rtoc(V_TOTAL5) + space(06)
	cDados += u_rtoc(V_TOTAL6) + space(01)
	@ nLi, 000 PSay cDados
	nLi++
	@ nLi, 000 pSay Replicate("-",132)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime rodape.													 	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Roda(nCbCont, cCbtxt, cTamanho)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera impressao.												         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if aReturn[5] == 1
		set printer to
		OurSpool(cNomeArq)
	endif
	
	Ft_PFlush()
endif
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fApagaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui a tabela temporaria.							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fApagaTemp
Static function fApagaTemp()
If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
//QRY->(DbCloseArea())
REL->(DbCloseArea("REL")); FErase(cArqTemp+".*")
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fMesAno   ³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o numero do mes.     						      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function fMesAno(nCont)
local nMes, nAno, nX

nMes := month(date())
nAno := year(date())

for nX := 1 to abs(nCont)
	nMes += iif(nCont>0,1,-1)
	if nMes == 0
		nMes := 12
		nAno--
	else
		if nMes == 13
			nMes := 1
			nAno++
		endif
	endif
next

return(strzero(nMes,02)+"/"+strzero(nAno,04))
