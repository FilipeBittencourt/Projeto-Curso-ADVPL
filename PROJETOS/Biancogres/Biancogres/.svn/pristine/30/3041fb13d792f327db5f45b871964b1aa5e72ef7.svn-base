#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BIA171    º Autor ³ Joao Carlos Andradeº Data ³  25/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Emissao da situacao da solicitacao de compras e nota fiscalº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Exclusivo - Biancogres                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA171

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aOrd 				:= {}
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "SITUACAO DA SOLICITACAO DE COMPRA"
Local cPict          := ""
Local titulo         := "SITUACAO DA SOLICITACAO DE COMPRA"
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Private wNumCot	    := ""
Private lPrim		:= .T.
Private cString
Private CbTxt        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "BIA171"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BIA170"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "BIA171"

//                   1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
//         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Cabec1 := "Nro SC   Matric  Funcionario                     C.Custo                                        | C O T A C A O  |      F O R N E C E D O R E S     |         P E D I D O S          |         N O T A   F I S C A L       "
Cabec2 := "It Produto Descricao                                     Quant  Emissao   Dt Prior   Status     |  Num Cot.      |Codigo  Lj  Nome                UF| No Ped  Emissao  Prev Ent  Frt |  Nr NF   Entrada             Quant  "

Private cString 		:= "SC1"

dbSelectArea("SC1")
dbSetOrder(1)

pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP5 IDE            º Data ³  25/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

DbSelectArea("SRA")
DbSetOrder(1)						// RA_FILIAL + RA_NUM
wFilSRA := xFilial("SRA")

DbSelectArea("CTH")
DbSetOrder(1)						// I3_FILIAL + I3_CUSTO
wFilCTH := xFilial("CTH")

DbSelectArea("SA2")
DbSetOrder(1)						// A2_FILIAL + A2_CODIGO + A2_LOJA
wFilSA2 := xFilial("SA2")

DbSelectArea("SC1")
DbSetOrder(1)						// C1_FILIAL + C1_NUM + C1_ITEM
wFilSC1 := xFilial("SC1")

DbSelectArea("SC8")
wFilSC8 := xFilial("SC8")
cTrab  := CriaTrab(NIL,.F.)
cChave := "C8_FILIAL+C8_NUMSC+C8_ITEMSC"
IndRegua("SC8",cTrab,cChave,,,"Criando indice temporario...")

DbSelectArea("SC7")
DbSetOrder(1)						// C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
wFilSC7 := xFilial("SC7")

DbSelectArea("SD1")
wFilSD1 := xFilial("SD1")
cTrab1  := CriaTrab(NIL,.F.)
cChave1 := "D1_FILIAL+D1_PEDIDO+D1_ITEMPC"
IndRegua("SD1",cTrab1,cChave1,,,"Criando indice temporario...")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Val(mv_par02) - Val(mv_par01) + 1)
DbSelectArea("SC1")
dbGoTop()
DbSeek(wFilSC1+mv_par01,.T.)
wNumSc := ""
While !EOF() .and. C1_FILIAL == wFilSC1 .and. C1_NUM <= mv_par02
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a Regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If wNumSc <> C1_NUM
		IncRegua()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Interrupcao(@lAbortPrint)
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		If File(cTrab+".IDX")
			FErase(cTrab+".IDX")
		Endif
		
		If File(cTrab1+".IDX")
			FErase(cTrab1+".IDX")
		Endif
		
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica parametros para impressao do Funcionario                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If C1_SOLICIT < mv_par04 .or. C1_SOLICIT > mv_par05
		DbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica parametros de Status da Solicitacao de Compra              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par08 < 5
		If mv_par08 == 1 .and. C1_YSTATUS <> "N"
			DbSkip()
			Loop
		Endif
		
		If mv_par08 == 2 .and. C1_YSTATUS <> "U"
			DbSkip()
			Loop
		Endif
		
		If mv_par08 == 3 .and. C1_YSTATUS <> "E"
			DbSkip()
			Loop
		Endif
		
		If mv_par08 == 4 .and. C1_YSTATUS <> "P"
			DbSkip()
			Loop
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ira imprimir somente os pedidos nao atendidos           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 1
		DbSelectArea("SC7")
		If !DbSeek(wFilSC7+SC1->C1_PEDIDO+SC1->C1_ITEMPED,.F.)
			DbSelectArea("SC1")
			DbSkip()
			Loop
		Endif
		
		If C7_QUJE >= C7_QUANT .or. C7_RESIDUO == "S"
			DbSelectArea("SC1")
			DbSkip()
			Loop
		Endif
	Endif
	
	DbSelectArea("SRA")
	If !Dbseek(wFilSRA+Alltrim(SC1->C1_SOLICIT),.F.)
		wFunc := IIF(!Empty(SC1->C1_SOLICIT),SC1->C1_SOLICIT,"S.C. sem solicitante")
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica parametros para impressao do Classe de Valor               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If RA_CLVL < mv_par06 .or. RA_CLVL > mv_par07
			DbSelectArea("SC1")
			DbSkip()
			Loop
		Endif
		
		DbSelectArea("CTH")
		If DbSeek(wFilCTH+SRA->RA_CLVL,.F.)
			wFunc := SRA->RA_MAT+"  "+SRA->RA_NOME+"   "+Alltrim(SRA->RA_CLVL)+" "+CTH->CTH_DESC01
		Endif
	Endif
	
	DbSelectArea("SC1")
	If Alltrim(wNumSc) <> Alltrim(C1_NUM)
		nLin := nLin + 2
		@ nLin,000 PSAY C1_NUM
		@ nLin,010 PSAY wFunc
		nLin := nLin + 1
		wNumSc := C1_NUM
	Endif
	@ nLin,000 PSAY C1_ITEM
	@ nLin,003 PSAY Alltrim(C1_PRODUTO)
	@ nLin,011 PSAY Subs(C1_DESCRI,1,38)
	@ nLin,051 PSAY C1_QUANT Picture "999,999.999"
	@ nLin,064 PSAY C1_EMISSAO
	@ nLin,074 PSAY C1_DATPRF
	wStatus := Space(10)
	If C1_YSTATUS == "N"
		wStatus := "Normal"
	Elseif C1_YSTATUS == "U"
		wStatus := "Urgente"
	Elseif C1_YSTATUS == "E"
		wStatus := "Emergencia"
	Elseif C1_YSTATUS == "P"
		wStatus := "Parada"
	Endif
	@ nLin,085 PSAY wStatus
	
	DbSelectArea("SC8")
	If !DbSeek(wFilSC8+SC1->C1_NUM+SC1->C1_ITEM,.F.)
		@ nLin,108 PSAY " "
		DbSelectArea("SC7")
		If !DbSeek(wFilSC7+SC1->C1_PEDIDO+SC1->C1_ITEMPED,.F.)
			@ nLin,114 PSAY " "
		Else
			DbSelectArea("SA2")
			If !DbSeek(wFilSA2+SC7->C7_FORNECE+SC7->C7_LOJA,.F.)
				@ nLin,114 PSAY "Fornecedor nao cadastrado"
			Else
				@ nLin,114 PSAY A2_COD
				@ nLin,121 PSAY A2_LOJA
				@ nLin,124 PSAY A2_NREDUZ
				@ nLin,146 PSAY A2_EST
			Endif
			@ nLin,150 PSAY SC7->C7_NUM
			@ nLin,158 PSAY SC7->C7_EMISSAO
			@ nLin,167 PSAY SC7->C7_DATPRF
			@ nLin,178 PSAY SC7->C7_TPFRETE
		Endif
		
		DbSelectArea("SD1")
		If !DbSeek(wFilSD1+SC7->C7_NUM+SC7->C7_ITEM,.F.)
			@ nLin,185 PSAY ""
		Else
			@ nLin,185 PSAY D1_DOC
			@ nLin,193 PSAY D1_DTDIGIT
			@ nLin,206 PSAY D1_QUANT Picture "999,999.999"
		Endif
		nLin := nLin + 1
	Else
		lExistSc7 := .F.
		wNumCot   := ""
		While !Eof() .and. C8_FILIAL == wFilSC8 .and. C8_NUMSC == SC1->C1_NUM  .and. C8_ITEMSC == SC1->C1_ITEM
			
			DbSelectArea("SC7") 
			If DbSeek(wFilSC7+SC8->C8_NUMPED+SC8->C8_ITEMPED,.F.)
				lExistSC7 := .T.
				wNumCot :=  SC8->C8_NUM
				@ nLin,099 PSAY SC8->C8_NUM
				
				DbSelectArea("SA2")
				If !DbSeek(wFilSA2+SC8->C8_FORNECE+SC8->C8_LOJA,.F.)
					@ nLin,114 PSAY "Fornecedor nao cadastrado"
				Else
					@ nLin,114 PSAY A2_COD
					@ nLin,121 PSAY A2_LOJA
					@ nLin,124 PSAY A2_NREDUZ
					@ nLin,146 PSAY A2_EST
				Endif
				
				@ nLin,150 PSAY SC7->C7_NUM
				@ nLin,158 PSAY SC7->C7_EMISSAO
				@ nLin,167 PSAY SC7->C7_DATPRF
				@ nLin,178 PSAY SC7->C7_TPFRETE
				
				DbSelectArea("SD1")
				If !DbSeek(wFilSD1+SC7->C7_NUM+SC7->C7_ITEM,.F.)
					@ nLin,185 PSAY ""
				Else
					@ nLin,185 PSAY D1_DOC
					@ nLin,193 PSAY D1_DTDIGIT
					@ nLin,206 PSAY D1_QUANT Picture "999,999.999"
				Endif
				nLin := nLin + 1
			Endif
			
			DbSelectArea("SC8")
			DbSkip()
		End
		If !lExistSc7
			@ nLin,099 PSAY wNumCot
			nLin := nLin + 1
		Endif
	Endif
	
	DbSelectArea("SC1")
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime rodape.																			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Roda(CbCont,Cbtxt,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

If File(cTrab+".IDX")
	FErase(cTrab+".IDX")
Endif

If File(cTrab1+".IDX")
	FErase(cTrab1+".IDX")
Endif

Return
