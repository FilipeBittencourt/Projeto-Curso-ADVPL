#INCLUDE "BIA845.CH"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#include "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA845   ³ Autor ³ Marco Bianchi            ³ Data ³ 23/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Comissoes.                                       ³±±
±±³          ³                                                               ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR540(void)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function BIA845()

Local oReport
Private cAliasQry := GetNextAlias()

#IFDEF TOP
	Private cAlias    := cAliasQry
#ELSE
	Private cAlias    := "SE3"
#ENDIF

Matr540R3()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR540R3³ Autor ³ Claudinei M. Benzi       ³ Data ³ 13.04.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Comissoes.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR540(void)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DATA   ³ BOPS ³Programad.³ALTERACAO                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³05.02.03³XXXXXX³Eduardo Ju³Inclusao de Queries para filtros em TOPCONNECT.³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Matr540R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local titulo    := STR0001  //"Relatorio de Comissoes"
Local cDesc1    := STR0002  //"Emissao do relatorio de Comissoes."
Local tamanho   := "G"
Local limite    := 220
Local cString   := "SE3"
Local cAliasAnt := Alias()
Local cOrdemAnt := IndexOrd()
Local nRegAnt   := Recno()
Local cDescVend := " "
Local cCodigo   := " "
Local cNome     := " "
Local cPrefixo  := " " 
Local cProccom  := " "
Local cEmp      := " " 
Local cEmpGMR   := " "

Private aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private nomeprog:= "BIA845"
Private aLinha  := { },nLastKey := 0
Private cPerg   := "BIA845"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("BIA845",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                          ³
//³ mv_par01         // Pela <E>missao,<B>aixa ou <A>mbos      	  ³
//³ mv_par02         // A partir da data                       	  ³
//³ mv_par03         // Ate a Data                             	  ³
//³ mv_par04 	    	 // Do Vendedor                            		³
//³ mv_par05	     	 // Ao Vendedor                            		³
//³ mv_par06	     	 // Quais (a Pagar/Pagas/Ambas)            		³
//³ mv_par07	     	 // Incluir Devolucao ?                    		³
//³ mv_par08	     	 // Qual moeda                             		³
//³ mv_par09	     	 // Comissao Zerada ?                      		³
//³ mv_par10	     	 // Abate IR Comiss                        		³
//³ mv_par11	     	 // Quebra pag.p/Vendedor                  		³
//³ mv_par12	     	 // Tipo de Relatorio (Analitico/Sintetico)		³
//³ mv_par13	     	 // Imprime detalhes origem                		³
//³ mv_par14         // Nome cliente							  							³
//³ mv_par15         // Detalha fatura?         	  							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "BIA845"
wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,"","",.F.,"",.F.,Tamanho)

If nLastKey==27
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey ==27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C540Imp(@lEnd,wnRel,cString)},Titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna para area anterior, indice anterior e registro ant.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(caliasAnt)
DbSetOrder(cOrdemAnt)
DbGoto(nRegAnt)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C540IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR540			                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C540Imp(lEnd,WnRel,cString)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbCont,cabec1,cabec2
Local tamanho  := "G"
Local limite   := 220
Local nomeprog := "BIA845"
Local imprime  := .T.
Local cPict    := ""
Local cTexto,j :=0,nTipo:=0
Local cCodAnt,nCol:=0
Local nAc1:=0,nAc2:=0,nAg1:=0,nAg2:=0,nAc3:=0,nAg3:=0,nAc4:=0,nAg4:=0,lFirstV:=.T.
Local nTregs,nMult,nAnt,nAtu,nCnt,cSav20,cSav7
Local lContinua:= .T.
Local cNFiscal :=""
Local aCampos  :={}
Local lImpDev  := .F.
Local cBase    := ""
Local cNomArq, cCondicao, cFilialSE1, cFilialSE3, cChave, cFiltroUsu
Local nDecs    := GetMv("MV_CENT"+(IIF(mv_par08 > 1 , STR(mv_par08,1),"")))
Local nBasePrt :=0, nComPrt:=0
Local aStru    := SE3->(dbStruct()), ni
Local nDecPorc := TamSX3("E3_PORC")[2]

Local cDocLiq   := ""
Local cTitulo  := ""
Local dEmissao := CTOD( "" )
Local nTotLiq  := 0
Local aLiquid  := {}
Local aValLiq  := {}
Local aLiqProp := {}
Local ny
Local aColuna := IIF(cPaisLoc <> "MEX",{15,19,42,46,83,95,107,119,130,137,153,169,176,195,203},{28,35,58,62,99,111,123,135,146,153,169,185,192,211,219})

Local nMsg		:= "" //

//Alteração Rescisão de Representante por Marca
Local dDtResc   := dDatabase	//Data Gravada Rescisão	         
Local nMCResc	:= ""			//Marca Gravada Rescisão 		
Local nMarca	:= ""			//Marca para chave de Pesquisa			

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

cPrefixo := U_MontaSQLIN(MV_PAR18,',',3)
cProccom := MV_PAR19

nTipo := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par12 == 1
	If mv_par01 == 1
		titulo := OemToAnsi(STR0005)+OemToAnsi(STR0006)+" ("+OemToAnsi(STR0019)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1)) //"RELATORIO DE COMISSOES "###"(PGTO PELA EMISSAO)"
	Elseif mv_par01 == 2
		titulo := OemToAnsi(STR0005)+OemToAnsi(STR0007)+" ("+OemToAnsi(STR0019)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES "###"(PGTO PELA BAIXA)"
	Else
		titulo := OemToAnsi(STR0008)+" ("+OemToAnsi(STR0019)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES"
	Endif
	
	cabec1:=OemToAnsi(STR0009)	//"PRF NUMERO   PARC. CODIGO DO              LJ  NOME                                 DT.BASE     DATA        DATA        DATA       NUMERO          VALOR           VALOR      %           VALOR    TIPO"
	cabec2:=OemToAnsi(STR0010)	//"    TITULO         CLIENTE                                                         COMISSAO    VENCTO      BAIXA       PAGTO      PEDIDO         TITULO            BASE               COMISSAO   COMISSAO"
	// XXX XXXXXXxxxxxx X XXXXXXxxxxxxxxxxxxxx   XX  012345678901234567890123456789012345 XX/XX/XXxx  XX/XX/XXxx  XX/XX/XXxx  XX/XX/XXxx XXXXXX 12345678901,23  12345678901,23  99.99  12345678901,23     X       AJUSTE
	// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
	// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	If cPaisLoc == "MEX"
		Cabec1 := Substr(Cabec1,1,10) + Space(16) + Substr(Cabec1,11)
		Cabec2 := Substr(Cabec2,1,10) + Space(16) + Substr(Cabec2,11)
	EndIf
Else
	If mv_par01 == 1
		titulo := OemToAnsi(STR0005)+OemToAnsi(STR0006)+" ("+OemToAnsi(STR0020)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1)) //"RELATORIO DE COMISSOES "###"(PGTO PELA EMISSAO)"
	Elseif mv_par01 == 2
		titulo := OemToAnsi(STR0005)+OemToAnsi(STR0007)+" ("+OemToAnsi(STR0020)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES "###"(PGTO PELA BAIXA)"
	Else
		titulo := OemToAnsi(STR0008)+" ("+OemToAnsi(STR0020)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES"
	Endif
	cabec1:=OemToAnsi(STR0021) //"CODIGO VENDEDOR                                           TOTAL            TOTAL      %            TOTAL           TOTAL           TOTAL"
	cabec2:=OemToAnsi(STR0022) //"                                                         TITULO             BASE                COMISSAO              IR          (-) IR"
	//"XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 123456789012,23  123456789012,23  99.99  123456789012,23 123456789012,23 123456789012,23
	//"0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
	//"0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta condicao para filtro do arquivo de trabalho            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SE3")	// Posiciona no arquivo de comissoes
DbSetOrder(2)			// Por Vendedor
cFilialSE3 := xFilial()
cNomArq :=CriaTrab("",.F.)

cCondicao := "SE3->E3_FILIAL=='" + cFilialSE3 + "'"
cCondicao += ".And.SE3->E3_VEND>='" + mv_par04 + "'"
cCondicao += ".And.SE3->E3_VEND<='" + mv_par05 + "'"
cCondicao += ".And.DtoS(SE3->E3_EMISSAO)>='" + DtoS(mv_par02) + "'"
cCondicao += ".And.DtoS(SE3->E3_EMISSAO)<='" + DtoS(mv_par03) + "'"

If mv_par01 == 1
	cCondicao += ".And.SE3->E3_BAIEMI!='B'"  // Baseado pela emissao da NF
Elseif mv_par01 == 2
	cCondicao += " .And.SE3->E3_BAIEMI=='B'"  // Baseado pela baixa do titulo
Endif

If mv_par06 == 1 		// Comissoes a pagar
	cCondicao += ".And.Dtos(SE3->E3_DATA)=='"+Dtos(Ctod(""))+"'"
ElseIf mv_par06 == 2 // Comissoes pagas
	cCondicao += ".And.Dtos(SE3->E3_DATA)!='"+Dtos(Ctod(""))+"'"
Endif

If mv_par09 == 1 		// Nao Inclui Comissoes Zeradas
	cCondicao += ".And.SE3->E3_COMIS<>0"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria expressao de filtro do usuario                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ! Empty(aReturn[7]) )
	cFiltroUsu := &("{ || " + aReturn[7] +  " }")
Else
	cFiltroUsu := { || .t. }
Endif

nAg1 := nAg2 := nAg3 := nAg4 := 0

#IFDEF TOP
If TcSrvType() != "AS/400"
	cOrder := SqlOrder(SE3->(IndexKey()))

	cQuery := "SELECT * "
	cQuery += "  FROM "+	RetSqlName("SE3") +" AS SE3, "+ RetSqlName("SA3")+" SA3 " 	//RANISSES
	cQuery += " WHERE E3_FILIAL = '" + xFilial("SE3") + "' AND "
	cQuery += "	E3_VEND  = A3_COD AND " 																							//RANISSES
	cQuery += "	E3_VEND >= '"  + mv_par04 + "' AND E3_VEND <= '"  + mv_par05 + "' AND "                         
    //cQuery += "E3_EMISSAO >= '" + Dtos(mv_par02) + "' AND E3_EMISSAO <= '"  + Dtos(mv_par03) + "' AND "			

	If mv_par01 == 1
		cQuery += "E3_BAIEMI <> 'B' AND "  //Baseado pela emissao da NF
	Elseif mv_par01 == 2
		cQuery += "E3_BAIEMI =  'B' AND "  //Baseado pela baixa do titulo
	EndIf

	If mv_par06 == 1 	 //Comissoes a pagar
		cQuery += "E3_DATA = '" + Dtos(Ctod("")) + "' AND "
     	cQuery += "E3_EMISSAO >= '" + Dtos(mv_par02) + "' AND E3_EMISSAO <= '"  + Dtos(mv_par03) + "' AND "		
	ElseIf mv_par06 == 2 //Comissoes pagas
		//cQuery += "E3_DATA <> '" + Dtos(Ctod("")) + "' AND "
		cQuery += "E3_DATA = '" + Dtos(mv_par21) + "' AND "
	ElseIf mv_par06 == 3 //Ambas
     	cQuery += "E3_EMISSAO >= '" + Dtos(mv_par02) + "' AND E3_EMISSAO <= '"  + Dtos(mv_par03) + "' AND "				
	Endif

	If mv_par09 == 1 		//Nao Inclui Comissoes Zeradas
		cQuery+= "E3_COMIS <> 0 AND "
	EndIf

	If !EMPTY(mv_par18) 		//Filtra Prefixos
	   cQuery+= "E3_PREFIXO IN (" + cPrefixo + ") AND "
	EndIf

	If !EMPTY(mv_par19) 		//Filtra Empresa para comissão variável
	   cQuery+= "E3_PROCCOM LIKE '%"+cProccom+"%' AND "
	EndIf
	
	// Filtra RA
	If !Empty(MV_PAR22) .And. MV_PAR22 == 2
	   cQuery+= " E3_TIPO <> 'RA' AND "
	EndIf	

	cQuery += " SE3.D_E_L_E_T_ <> '*' AND SA3.D_E_L_E_T_ <> '*'"   //RANISSES

	//cQuery += " ORDER BY "+ cOrder
	IF MV_PAR16 <> 1 .OR. MV_PAR17 == 2
		 cQuery += " ORDER BY  E3_FILIAL, A3_NOME, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_SEQ "
	ELSE
		 cQuery += " ORDER BY  E3_FILIAL, A3_COD,  E3_PREFIXO, E3_NUM, E3_PARCELA, E3_SEQ "	
	ENDIF

	cQuery := ChangeQuery(cQuery)

	dbSelectArea("SE3")	
	dbCloseArea()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE3', .F., .T.)

	For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE3', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
	Next
Else

#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave := IndexKey()
	cNomArq :=CriaTrab("",.F.)
	IndRegua("SE3",cNomArq,cChave,,cCondicao, OemToAnsi(STR0016)) //"Selecionando Registros..."
	nIndex := RetIndex("SE3")
	DbSelectArea("SE3")
#IFNDEF TOP
	DbSetIndex(cNomArq+OrdBagExT())
#ENDIF
	DbSetOrder(nIndex+1)
#IFDEF TOP
EndIf
#ENDIF

//Apaga a base de dados 
IF MV_PAR20 == 1
	A01 := "  UPDATE "+RetSqlName("ZZX")  "
	A01 += "  SET D_E_L_E_T_ = '*' "
	A01 += "  WHERE SUBSTRING(ZZX_DATA,1,6) = '"+SUBSTR(DTOS(MV_PAR02),1,6)+"' "
	A01 += "  AND ZZX_EMP    =  '"+cEmpAnt+cFilAnt+'N'+"'  "			
	A01 += "  AND D_E_L_E_T_ = '' "
	TCSQLExec(A01)
ENDIF

//Corrig regra de impressao
SE3->(DbGotop())
nTotRep := Contar("SE3","!Eof()")

SetRegua(nTotRep)	//Total de Elementos da regua

//DbGotop()
SE3->(DbGotop())

While !Eof()
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0011)  //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIF
	IncRegua()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa condicao do filtro do usuario                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Eval(cFiltroUsu)
		Dbskip()
		Loop
	Endif
	
	nAc1    := nAc2 := nAc3 := nAc4 := 0
	lFirstV := .T.    
	_CCHAVE := "" 

	dbSelectArea("SA3")
	dbSeek(xFilial("SA3")+SE3->E3_VEND)
	
	IF MV_PAR16 <> 1 .OR. MV_PAR17 == 2
		cVend  := SA3->A3_NOME 
		_CCHAVE := "SE3->A3_NOME"
	ELSE                           
		cVend  := SA3->A3_COD	       
		_CCHAVE := "SE3->A3_COD"
	ENDIF
	
	While !Eof() .AND. &(_CCHAVE) == cVend
	  
		IncRegua()
		cDocLiq:= ""
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa condicao do filtro do usuario                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Eval(cFiltroUsu)
			Dbskip()
			Loop
		Endif
		
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		
		//Define a Marca
		If cEmpAnt == "07"
			If Alltrim(SE3->E3_PREFIXO) $ "1"
				nMarca	:= "0101"
			ElseIf Alltrim(SE3->E3_PREFIXO) $ "2"
				nMarca	:= "0501"
			ElseIf Alltrim(SE3->E3_PREFIXO) $ "3"
				nMarca	:= "0599"
			ElseIf Alltrim(SE3->E3_PREFIXO) $ "4"								
				nMarca	:= "1399"
			ElseIf Alltrim(SE3->E3_PREFIXO) $ "6"								
				nMarca	:= "0199"
			ElseIf Alltrim(SE3->E3_PREFIXO) $ "7"								
				nMarca	:= "1302"		
			EndIf
		Else
			nMarca	:= ""				
		EndIf 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o Codigo do Vendedor e Imprime o seu Nome          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lFirstV
						
			//Busca Informações da Tabela de Rescisão
			If cEmpAnt == "07"
				Z78->(DbSetOrder(2))				
				If Z78->(DbSeek(xFilial("Z78")+SA3->A3_COD+nMarca))
					nResc	:= " - RESC: " + DTOC(Z78->Z78_DTRESC)
					nMcResc	:= Z78->Z78_MARCA
					dDtResc := Z78->Z78_DTRESC
				Else
					nResc	:= ""
					nMcResc	:= ""
					dDtResc := cToD("")			
				EndIf
			Else
				Z78->(DbSetOrder(1))	
				If Z78->(DbSeek(xFilial("Z78")+SA3->A3_COD))
					nResc	:= " - RESC: " + DTOC(Z78->Z78_DTRESC)
					nMcResc	:= ""
					dDtResc := Z78->Z78_DTRESC				
				Else
					nResc	:= ""
					nMcResc	:= ""
					dDtResc := cToD("")
				EndIf
			EndIf

			If mv_par12 == 1		
				cDescVend := SE3->E3_VEND + " " + SA3->A3_NOME + nResc	
				@li, 00 PSAY OemToAnsi(STR0012) + cDescVend 		    
				li+=2
			Else
				@li, 00 PSAY SE3->E3_VEND
				@li, 07 PSAY SE3->A3_NOME
			EndIf

			dbSelectArea("SE3")
			lFirstV := .F.
			cCodigo := SA3->A3_COD
			cNome   := SA3->A3_NOME
			cEmpGMR := SUBSTR(ALLTRIM(SA3->A3_YEMP),1,4)
		EndIf    
		
		IF EMPTY(cNome)
		   LSLPAS := .T.
		ENDIF
		
		If mv_par12 == 1
			@li, 00 PSAY SE3->E3_PREFIXO
			@li, 04 PSAY SE3->E3_NUM
			@li, aColuna[1] PSAY SE3->E3_PARCELA
			
			//BUSCAR O NOME DO CLIENTE ORIGINAL QUANDO TIVER - RANISSES
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				SELECT C5_YCLIORI, C5_YLOJORI FROM %Table:SC5% WHERE C5_NUM = %Exp:SE3->E3_PEDIDO% AND %NOTDEL%
			EndSql
			
			If Empty(Alltrim((cAliasTmp)->C5_YCLIORI))
				nCodCli :=	SE3->E3_CODCLI
				nLjCli  :=	SE3->E3_LOJA
				lFlag		:=  .F.
			Else
				nCodCli :=	(cAliasTmp)->C5_YCLIORI
				nLjCli  :=	(cAliasTmp)->C5_YLOJORI
				lFlag		:=  .T.
			EndIf
			(cAliasTmp)->(dbCloseArea())
			
			dbSelectArea("SA1")
			dbSeek(xFilial()+nCodCli+nLjCli)
			
			@li, aColuna[2] PSAY nCodCli+Iif(lFlag,"*","")	//SE3->E3_CODCLI
			@li, 35 PSAY SE3->E3_TIPO 											//RANISSES
			@li, aColuna[3] PSAY nLjCli											//SE3->E3_LOJA
			@li, aColuna[4] PSAY IF(mv_par14 == 1,Substr(SA1->A1_NREDUZ,1,35),Substr(SA1->A1_NOME,1,35))
			
			dbSelectArea("SE3")
			@li, aColuna[5] PSAY SE3->E3_EMISSAO
		EndIf
		
		// Tiago Rossini Coradini - 23/05/2017 - Ajuste para contemplar acerto manual - Solicitação enviada por e-mail pelo Ranisses
		If AllTrim(SE3->E3_TIPO) == "FT" .And. AllTrim(SE3->E3_PROCCOM) == "ACERTO EM 05/05/2017"
		
			DbSelectArea("SE1")
			DbSetOrder(2)
			DbSeek(xFilial("SE3") + SE3->(E3_CODCLI + E3_LOJA + E3_PREFIXO + E3_NUM))
			
			nRecNo := SE1->(RecNo())
			
			nVlrTitulo := 0
			
			While !SE1->(Eof()) .And. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == SE3->(E3_FILIAL + E3_CODCLI + E3_LOJA + E3_PREFIXO + E3_NUM)
			
				nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
						
				SE1->(DbSkip())
				
			EndDo()
			
			SE1->(DbGoTo(nRecNo))
			
		Else
		
			dbSelectArea("SE1")
			dbSetOrder(1)
			dbSeek(xFilial()+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO)
			
			nVlrTitulo := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
			
		EndIf						
		
		dVencto    := SE1->E1_VENCTO
		dEmissao   := SE1->E1_EMISSAO
		aLiquid	  := {}
		aValLiq		:= {}
		aLiqProp	  	:= {}
		nTotLiq		:= 0
		If mv_par13 == 1 .And. !Empty(SE1->E1_NUMLIQ) .And. FindFunction("FA440LIQSE1")
			cLiquid := SE1->E1_NUMLIQ
			cDocLiq := SE1->E1_NUMLIQ
			// Obtem os registros que deram origem ao titulo gerado pela liquidacao
			Fa440LiqSe1(SE1->E1_NUMLIQ,@aLiquid,@aValLiq)
			For ny := 1 to Len(aValLiq)
				nTotLiq += aValLiq[ny,2]
			Next
			For ny := 1 to Len(aValLiq)
				aAdd(aLiqProp,(nVlrTitulo/nTotLiq)*aValLiq[ny,2])
			Next
		Endif
		/*
		Nas comissoes geradas por baixa pego a data da emissao da comissao que eh igual a data da baixa do titulo.
		Isto somente dara diferenca nas baixas parciais
		*/
		
		If SE3->E3_BAIEMI == "B"
			dBaixa     := SE3->E3_EMISSAO
		Else
			dBaixa     := SE1->E1_BAIXA
		Endif
		
		If Eof()
			dbSelectArea("SF2")
			dbSetorder(1)
			dbSeek(xFilial()+SE3->E3_NUM+SE3->E3_PREFIXO)
			nVlrTitulo := Round(xMoeda(F2_VALFAT,SF2->F2_MOEDA,mv_par08,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),nDecs)
			
			dVencto    := " "
			dBaixa     := " "
			
			dEmissao   := SF2->F2_EMISSAO
			
			If Eof()
				nVlrTitulo := 0
				dbSelectArea("SE1")
				dbSetOrder(1)
				cFilialSE1 := xFilial()
				dbSeek(cFilialSE1+SE3->E3_PREFIXO+SE3->E3_NUM)
				While ( !Eof() .And. SE3->E3_PREFIXO == SE1->E1_PREFIXO .And.;
					SE3->E3_NUM == SE1->E1_NUM .And.;
					SE3->E3_FILIAL == cFilialSE1 )
					If ( SE1->E1_TIPO == SE3->E3_TIPO  .And. ;
						SE1->E1_CLIENTE == SE3->E3_CODCLI .And. ;
						SE1->E1_LOJA == SE3->E3_LOJA )
						nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
						dVencto    := " "
						dBaixa     := " "
						If Empty(dEmissao)
							dEmissao := SE1->E1_EMISSAO
						EndIf
					EndIf
					dbSelectArea("SE1")
					dbSkip()
				EndDo
			EndIf
		Endif
		
		
		If Empty(dEmissao)
			dEmissao := NIL
		EndIf
		
		//Preciso destes valores para pasar como parametro na funcao TM(), e como
		//usando a xmoeda direto na impressao afetaria a performance (deveria executar
		//duas vezes, uma para imprimir e outra para pasar para a picture), elas devem]
		//ser inicializadas aqui. Bruno.
		
		nBasePrt:=	Round(xMoeda(SE3->E3_BASE ,1,MV_PAR08,dEmissao,nDecs+1),nDecs)
		nComPrt :=	Round(xMoeda(SE3->E3_COMIS,1,MV_PAR08,dEmissao,nDecs+1),nDecs)
		
		If nBasePrt < 0 .And. nComPrt < 0
			nVlrTitulo := nVlrTitulo * -1
		Endif
		
		dbSelectArea("SE3")
		
		If mv_par12 == 1
			@ li,aColuna[6]  PSAY dVencto
			@ li,aColuna[7]  PSAY dBaixa
			@ li,aColuna[8]  PSAY SE3->E3_DATA
			@ li,aColuna[9]  PSAY SE3->E3_PEDIDO	Picture "@!"
			@ li,aColuna[10] PSAY nVlrTitulo		Picture tm(nVlrTitulo,14,nDecs)
			@ li,aColuna[11] PSAY nBasePrt 			Picture tm(nBasePrt,14,nDecs)
			If cPaisLoc<>"BRA"
				@ li,aColuna[12] PSAY SE3->E3_PORC		Picture tm(SE3->E3_PORC,6,nDecPorc)
			Else
				@ li,aColuna[12] PSAY SE3->E3_PORC		Picture tm(SE3->E3_PORC,6)
			Endif
			@ li,aColuna[13] PSAY nComPrt			Picture tm(nComPrt,14,nDecs)
			@ li,aColuna[14] PSAY SE3->E3_BAIEMI
			
			If ( SE3->E3_AJUSTE == "S" .And. MV_PAR07==1)
				@ li,aColuna[15] PSAY STR0018 //"AJUSTE "
			EndIf
			li++
			
			//Imprime detalhes da Fatura -- RANISSES 31/08/11
			If MV_PAR15 == 1
				If Empty(Alltrim(SE3->E3_PEDIDO))
					cAliasTmp := GetNextAlias()
					BeginSql Alias cAliasTmp
						SELECT 'Titulo->'+RTRIM(E1_PREFIXO)+'-'+RTRIM(E1_NUM)+'-'+RTRIM(E1_PARCELA)+' / Pedido->'+E1_PEDIDO AS INFO
						FROM %Table:SE1%
						WHERE E1_FATURA = %Exp:SE3->E3_NUM% AND E1_TIPO = 'NF' AND E1_YPARCFT = %Exp:SE3->E3_PARCELA% AND %NOTDEL%
					EndSql
					@ li,04  PSAY "Informações de origem da Fatura "+Alltrim(SE3->E3_PREFIXO)+"-"+Alltrim(SE3->E3_NUM)+"-"+Alltrim(SE3->E3_PARCELA)
					li++
					While  !(cAliasTmp)->(EOF())
						@ li,04  PSAY (cAliasTmp)->INFO
						li++
						(cAliasTmp)->(dbSkip())
					End
					(cAliasTmp)->(dbCloseArea())
				EndIf
			EndIf
			
			// Imprime titulos que deram origem ao titulo gerado por liquidacao
			If mv_par13 == 1
				For nI := 1 To Len(aLiquid)
					If li > 55
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
					EndIF
					If nI == 1
						@ ++li, 0 PSAY __PrtThinLine()
						@ ++li, 0 PSAY STR0023 +SE1->E1_NUMLIQ // "Detalhes : Titulos de origem da liquidação "
						@ ++li,10 PSAY STR0024 // "Prefixo    Numero          Parc    Tipo    Cliente   Loja    Nome                                       Valor Titulo      Data Liq.         Valor Liquidação      Valor Base Liq."
						//         Prefixo    Numero          Parc    Tipo    Cliente   Loja    Nome                                       Valor Titulo      Data Liq.         Valor Liquidação      Valor Base Liq.
						//         XXX        XXXXXXXXXXXX    XXX     XXXX    XXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999999999999     99/99/9999          999999999999999      999999999999999
						@ ++li, 0 PSAY __PrtThinLine()
						li++
					Endif
					cDocLiq  := SE1->E1_NUMLIQ
					SE1->(MsGoto(aLiquid[nI]))
					SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
					@li,  10 PSAY SE1->E1_PREFIXO
					@li,  21 PSAY SE1->E1_NUM
					@li,  37 PSAY SE1->E1_PARCELA
					@li,  45 PSAY SE1->E1_TIPO
					@li,  53 PSAY SE1->E1_CLIENTE
					@li,  64 PSAY SE1->E1_LOJA
					@li,  71 PSAY IF(mv_par14 == 1,Substr(SA1->A1_NREDUZ,1,35),Substr(SA1->A1_NOME,1,35))
					@li, 111 PSAY SE1->E1_VALOR PICTURE Tm(SE1->E1_VALOR,15,nDecs)
					@li, 132 PSAY aValLiq[nI,1]
					@li, 151 PSAY aValLiq[nI,2] PICTURE Tm(SE1->E1_VALOR,15,nDecs)
					@li, 172 PSAY aLiqProp[nI] PICTURE Tm(SE1->E1_VALOR,15,nDecs)
					li++
				Next
				// Imprime o separador da ultima linha
				If Len(aLiquid) >= 1
					@ li++, 0 PSAY __PrtThinLine()
				Endif
			Endif
		EndIf
		nAc1 += nBasePrt
		nAc2 += nComPrt
		If cTitulo <> SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO+SE3->E3_VEND+SE3->E3_CODCLI+SE3->E3_LOJA  .And. Empty(cDocLiq)
			nAc3   += nVlrTitulo
			cTitulo:= SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO+SE3->E3_VEND+SE3->E3_CODCLI+SE3->E3_LOJA
			cDocLiq:= ""
		EndIf                    
		
		dbSelectArea("SE3")
		dbSkip()
	EndDo
	
	If mv_par12 == 1
		li++
		
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		@ li, 00  PSAY OemToAnsi(STR0013)+cDescVend  //"TOTAL DO VENDEDOR --> "
		@ li,aColuna[10]-1  PSAY nAc3 	PicTure tm(nAc3,15,nDecs)
		@ li,aColuna[11]-1  PSAY nAc1 	PicTure tm(nAc1,15,nDecs)
		
		If nAc1 != 0
			If cPaisLoc=="BRA"
				@ li, aColuna[12] PSAY (nAc2/nAc1)*100   PicTure "999.99"
			Else
				@ li, aColuna[12] PSAY NoRound((nAc2/nAc1)*100)   PicTure "999.99"
			Endif
		Endif
		
		@ li, aColuna[13]-1  PSAY nAc2 PicTure tm(nAc2,15,nDecs)
		li++
		
		If mv_par10 > 0 .And. (nAc2 * mv_par10 / 100) > GetMV("MV_VLRETIR") //IR
			@ li, 00  PSAY OemToAnsi(STR0015)  //"TOTAL DO IR       --> "
			nAc4 += (nAc2 * mv_par10 / 100)
			@ li, aColuna[13]-1  PSAY nAc4 PicTure tm(nAc2 * mv_par10 / 100,15,nDecs)
			li ++
			@ li, 00  PSAY OemToAnsi(STR0017)  //"TOTAL (-) IR      --> "
			@ li, aColuna[13]-1 PSAY nAc2 - nAc4 PicTure tm(nAc2,15,nDecs)
			li ++
		EndIf
		
		@ li, 00 PSAY "Clientes com '*' são referentes a LM."
		li ++
		
		@ li, 00  PSAY __PrtThinLine()
		
		If mv_par11 == 1  // Quebra pagina por vendedor (padrao)
			li := 60
		Else
			li+= 2
		Endif
		
		/*Ticket 22879 - Pablo S. Nascimento e Ranisses Corona
			Inclusão de tratamento para prefixo 6 e 7 e ajuste na mensagem de tratamento. O sistema agora não gerará o relatório caso falte a classe de valor necessária.
		*/
		//Esta opção foi desenvolvida para gravar os valores de comissão mensal após fechamento para apuração do relatório que substitui a planilha em Excel utilizado pelo Roque.
		IF MV_PAR16 == 1
			
			DO CASE
				
				CASE cEmpAnt == '01'
				
					cEmp := '0101N'
					
					If '4' $ Alltrim(MV_PAR18)
						cClvl := '2106'
					Else
						IF cCodigo <> '200005'
							cClvl := '2100'
						ELSE
							cClvl := '2113'
						ENDIF
					EndIf      
			
				CASE cEmpAnt == '05'
					
					cEmp := '0501N'   
					
					DO CASE
						CASE '1' $ Alltrim(MV_PAR18)
							 cClvl := '2200'
						CASE '2' $ Alltrim(MV_PAR18)
							 cClvl := '2210'
						CASE '9' $ Alltrim(MV_PAR18)
						    DO CASE
							   CASE cProccom == '0501'
							        cClvl := '2200'							
							   CASE cProccom == '0599'
							        cClvl := '2210'   
							   CASE cProccom == '1399'
							        cClvl := '2250'   							   							          							
							ENDCASE		
						OTHERWISE
							MSGBOX("Este prefixo utilizado não está conforme com as regras de comissão do Representante: "+cCodigo + "."+ Chr(13) + Chr(13) + Chr(10) + "Comunique o administrador do sistema." + Chr(13) + Chr(13) + Chr(10) + "Este relatório será encerrado.","STOP")
							Return
							cClvl := 'NNNNN'
					ENDCASE       
				
				CASE cEmpAnt == '07'
					
					cEmp := cEmpAnt+cFilAnt+'N'
					
					DO CASE
						
						CASE '1' $ Alltrim(MV_PAR18)
							IF cCodigo <> '200005'
							   //cClvl := '2100'
							   cClvl := '2150'
							ELSE
							   cClvl := '2113'
							ENDIF
						CASE '01' $ Alltrim(MV_PAR18)
							IF cCodigo <> '200005'
							   //cClvl := '2100'
							   cClvl := '2150'
							ELSE
							   cClvl := '2113'
							ENDIF
						CASE '2' $ Alltrim(MV_PAR18)
							 //cClvl := '2200'
							 cClvl := '2250'
						CASE '3' $ Alltrim(MV_PAR18)
							 //cClvl := '2210'        
							 cClvl := '2251'        
						CASE '4' $ Alltrim(MV_PAR18)
							 cClvl := '2250'							 
						CASE '6' $ Alltrim(MV_PAR18)
							 cClvl := '2170'
						CASE '7' $ Alltrim(MV_PAR18)
							 cClvl := '2302'
						CASE '9' $ Alltrim(MV_PAR18)
							 cClvl := '2250'							 
						OTHERWISE
							MSGBOX("Este prefixo utilizado não está conforme com as regras de comissão do Representante: "+cCodigo + "." + Chr(13) + Chr(13) + Chr(10) + "Comunique o administrador do sistema!" + Chr(13) + Chr(13) + Chr(10) + "Este relatório será encerrado.","STOP")
							Return
							cClvl := '    '	
													
					ENDCASE       
									
				CASE cEmpAnt == '14'
					
					cEmp := '1401N'														
					cClvl := '3500'
				
				OTHERWISE
					
					MSGBOX("Esta empresa não possui cálculo de comissão." + Chr(13) + Chr(13) + Chr(10) + "Comunique o administrador do sistema!" + Chr(13) + Chr(13) + Chr(10) + "Este relatório será encerrado.","STOP")
					Return
					cClvl := '   '					
					cEmp := 'NNNNN'					
			
			ENDCASE
			
			//Busca valores de telefonia que devem ser descontados dos representantes
			A01 := "  SELECT E1_VALOR " 
	        A01 += "  FROM "+RetSqlName("SE1") +" SE1, "+ RetSqlName("SA1")+" SA1, "+ RetSqlName("SA3")+" SA3 "
	        A01 += "  WHERE SUBSTRING(E1_VENCTO,1,6) = '"+SUBSTR(DTOS(MV_PAR03+1),1,6)+"' "
	        A01 += "  AND E1_PREFIXO IN ('TL0','TEL')    "
	        A01 += "  AND E1_CLIENTE = A1_COD   "
	        A01 += "  AND E1_LOJA    = A1_LOJA  "
	        A01 += "  AND A1_CGC     = A3_CGC   "
			A01 += "  AND A3_COD     = '"+cCodigo+"' "
	        A01 += "  AND SE1.D_E_L_E_T_ = ''   "
	        A01 += "  AND SA1.D_E_L_E_T_ = ''   "
	        A01 += "  AND SA3.D_E_L_E_T_ = ''   "

			If chkfile("A01")
				DbSelectArea("A01")
				DbCloseArea()
			EndIf
			TcQuery A01 New Alias "A01"
			
			DbSelectArea("ZZX")
			DbSetOrder(1)
			//IF !DbSeek(xFilial("ZZX")+cCodigo+cClvl+SPACE(16)+DTOS(MV_PAR02)+cEmp)
			IF !DbSeek(xFilial("ZZX")+cCodigo+cClvl+SPACE(16)+DTOS(MV_PAR21)+cEmp)			
				RecLock("ZZX",.T.)
				ZZX->ZZX_FILIAL  := xFilial("ZZX")
				ZZX->ZZX_VEND    := cCodigo
				ZZX->ZZX_CLVL    := cClvl  				
				//ZZX->ZZX_DATA    := MV_PAR02				
				ZZX->ZZX_DATA    := MV_PAR21
				ZZX->ZZX_EMP     := cEmp				
				ZZX->ZZX_NOME    := cNome
				ZZX->ZZX_DTRESC  := dDtResc				
				ZZX->ZZX_MCRESC  := nMcResc
				ZZX->ZZX_BASE    := nAc1
				IF '9' $ Alltrim(MV_PAR18)
				   ZZX->ZZX_COMISV  := nAc2
				ELSE
				   ZZX->ZZX_COMIS   := nAc2				
				ENDIF
				ZZX->ZZX_PORC    := (nAc2/nAc1)*100
				ZZX->ZZX_IR      := MV_PAR10
				ZZX->ZZX_DESCON  := A01->E1_VALOR
				MsUnLock()
			ELSE                  
				RecLock("ZZX",.F.)			
				IF '9' $ Alltrim(MV_PAR18)
				   ZZX->ZZX_COMISV := ZZX->ZZX_COMISV + nAc2
				ELSE
				   ZZX->ZZX_COMIS  := ZZX->ZZX_COMIS + nAc2				
				ENDIF                   
				ZZX->ZZX_BASE    := ZZX->ZZX_BASE + nAc1           
				ZZX->ZZX_PORC    := ((ZZX->ZZX_COMIS + ZZX->ZZX_COMISV)/ZZX->ZZX_BASE)*100				
				MsUnLock()				
			ENDIF
		ENDIF
	Else
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		@ li,048  PSAY nAc3 	PicTure tm(nAc3,15,nDecs)
		@ li,065  PSAY nAc1 	PicTure tm(nAc1,15,nDecs)
		If nAc1 != 0
			If cPaisLoc=="BRA"
				@ li, 081 PSAY (nAc2/nAc1)*100   PicTure "999.99"
			Else
				@ li, 081 PSAY NoRound((nAc2/nAc1)*100)   PicTure "999.99"
			Endif
		Endif
		@ li, 089  PSAY nAc2 PicTure tm(nAc2,15,nDecs)
		If mv_par10 > 0 .And. (nAc2 * mv_par10 / 100) > GetMV("MV_VLRETIR") //IR
			nAc4 += (nAc2 * mv_par10 / 100)
			@ li, 105 PSAY nAc4 PicTure tm(nAc2 * mv_par10 / 100,15,nDecs)
			@ li, 121 PSAY nAc2 - nAc4 PicTure tm(nAc2,15,nDecs)
		EndIf
		li ++
	EndIf
	
	dbSelectArea("SE3")
	nAg1 += nAc1
	nAg2 += nAc2
	nAg3 += nAc3
	nAg4 += nAc4
EndDo

If (nAg1+nAg2+nAg3+nAg4) != 0
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	If mv_par12 == 1
		@li,  00 PSAY OemToAnsi(STR0014)  //"TOTAL  GERAL      --> "
		@li, aColuna[10]-1 PSAY nAg3	Picture tm(nAg3,15,nDecs)
		@li, aColuna[11]-1 PSAY nAg1	Picture tm(nAg1,15,nDecs)
		If cPaisLoc=="BRA"
			@li, aColuna[12] PSAY (nAg2/nAg1)*100 Picture "999.99"
		Else
			@li, aColuna[12] PSAY NoRound((nAg2/nAg1)*100) Picture "999.99"
		Endif
		@li, aColuna[13]-1 PSAY nAg2 Picture tm(nAg2,15,nDecs)
		If mv_par10 > 0 .And. (nAg2 * mv_par10 / 100) > GetMV("MV_VLRETIR")//IR
			li ++
			@ li, 00  PSAY OemToAnsi(STR0015)  //"TOTAL DO IR       --> "
			@ li, 175  PSAY nAg4 PicTure tm((nAg2 * mv_par10 / 100),15,nDecs)
			li ++
			@ li, 00  PSAY OemToAnsi(STR0017)  //"TOTAL (-) IR       --> "
			@ li, 175  PSAY nAg2 - nAg4 Picture tm(nAg2,15,nDecs)
		EndIf
	Else
		@li,000  PSAY __PrtThinLine()
		li ++
		@li,000 PSAY OemToAnsi(STR0014)  //"TOTAL  GERAL      --> "
		@li,048 PSAY nAg3	Picture tm(nAg3,15,nDecs)
		@li,065 PSAY nAg1	Picture tm(nAg1,15,nDecs)
		If cPaisLoc=="BRA"
			@li,081 PSAY (nAg2/nAg1)*100 Picture "999.99"
		Else
			@li,081 PSAY NoRound((nAg2/nAg1)*100) Picture "999.99"
		Endif
		@li,089 PSAY nAg2 Picture tm(nAg2,15,nDecs)
		If mv_par10 > 0 .And. (nAg2 * mv_par10 / 100) > GetMV("MV_VLRETIR")//IR
			@ li,105  PSAY nAg4 PicTure tm((nAg2 * mv_par10 / 100),15,nDecs)
			@ li,121  PSAY nAg2 - nAg4 Picture tm(nAg2,15,nDecs)
		EndIf
	EndIf
	roda(cbcont,cbtxt,"G")
EndIF

#IFDEF TOP
If TcSrvType() != "AS/400"
	dbSelectArea("SE3")
	DbCloseArea()
	chkfile("SE3")
Else
#ENDIF
	fErase(cNomArq+OrdBagExt())
#IFDEF TOP
Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE3")
RetIndex("SE3")
DbSetOrder(2)
dbClearFilter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()