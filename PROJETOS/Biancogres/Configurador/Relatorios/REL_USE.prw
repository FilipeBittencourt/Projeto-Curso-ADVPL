#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³REL_USE   º Autor ³ MADALENO           º Data ³  04/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATORIO PARA IMPRIMIR OS USUARIOS DO SIGA                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function REL_USE()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aOrd := {}
Local cDesc1		 := "Este programa tem como objetivo emitir um mapa de Pedidos"
Local cDesc2		 := "nao atendidos por vendedor.             "
Local cDesc3         := ""
Local cPict          := ""
Local titulo		 := "LISTA DE USUARIO DOS REPRESENTANTES"
//Local Cabec1		 := PADR("ID",8) + PADR("CODIGO",15) + PADR("NOME",30) + PADR("DATA VALIDADE",16) + PADR("SEN.EXP",15) + PADR("DEPARTAMENTO",30) + PADR("EMPRESA QUE ACESSA",30) + PADR("RELATO",25) + PADR("BLOQUEADO",9)
Local Cabec1		 := PADR("ID",8) + PADR("CODIGO",15) + PADR("NOME",30) + PADR("DATA VALIDADE",16) + PADR("SEN.EXP",15) + PADR("EMPRESA QUE ACESSA",30) + PADR("RELATO",25) + PADR("BLOQUEADO",9)  + PADR("EMAIL",90)
Local Cabec2		 := "" //"PEDIDO  EMISSAO   PRODUTO    PRODUTO                            MEDIO      PEDIDO    ATENDIDO      SALDO       BRUTO         OBSERVACAO                               TRANSPORTADORA                 ENTREGA        COND.PAG"
Local imprime        := .T.
Private nLin         := 80
Private cString		 := "SC5"
Private CbTxt        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220 //132
Private tamanho      := "G"
Private nomeprog     := "USER"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := ""
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "USER"


Private cString := "SA1"

dbSelectArea("SA1")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  05/10/06   º±±
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
Local aUsuario	:= AllUsers()
Local nOrdem
LOCAL X
LOCAL c_EMPRESSAS := ""
LOCAL I

For X := 1 To Len(aUsuario)
	c_EMPRESSAS := ""
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	//IF AllTrim(aUsuario[X][01][12]) = "REPRESENTANTE"
	IF AllTrim(aUsuario[X][01][02]) <= "999999" // FILTRA PELO CODIGO DOS REPRESENTANTES
		cLINHA := PADR(AllTrim(aUsuario[X][01][01]),08) + " " 	// ID
		cLINHA += PADR(AllTrim(aUsuario[X][01][02]),15)+ " " 	// CODIGO
		cLINHA += PADR(AllTrim(aUsuario[X][01][04]),30)+ " "	// NOME
		cLINHA += PADR(IIF(ALLTRIM(DTOC(aUsuario[X][01][06]))="","  ",ALLTRIM(DTOC(aUsuario[X][01][06]))),16) 	// DATA VALIDADE
		//cLINHA += IIF(aUsuario[X][01][07] = 0 .OR. EMPTY(aUsuario[X][01][07]),"00 DIAS    ", ALLTRIM(STR(aUsuario[X][01][07])) + " DIAS    ") //SENHA EXPIRA AUTOMATICAMENTE		
		cLINHA += PADR(ALLTRIM(STR(aUsuario[X][01][07])) + " DIAS",15)
		FOR I := 1 TO LEN(aUsuario[X][02][06]) //BUSCANDOP TODAS AS EMPRESAS QUE O USUARIO TEM ACESSO
			IF aUsuario[X][02][06][I] = "@@@@"   // aUsuario[X][02][06][1]
				c_EMPRESSAS := "TODAS EMPRESAS" // MAXIMO 6 EMPRESAS
			ELSE
				c_EMPRESSAS += SUBSTR(AllTrim(aUsuario[X][02][06][I]),1,2) + ","	// EMPRESA QUE ACESSA
			END IF
		NEXT
		//cLINHA += PADR(AllTrim(aUsuario[X][01][12]),30)+ " "		// DEPARTAMENTO
		cLINHA += PADR(c_EMPRESSAS,30)
		cLINHA += PADR(AllTrim(aUsuario[X][02][03]),30)+ " "			// RELATO 
		cLINHA += PADR(iif(aUsuario[X][01][17]= .T.,"SIM","NÃO"),9)+ " "// BLOQUEADO
		cLINHA += PADR(AllTrim(aUsuario[X][01][15]),05)+"  "			// NUMERO DE ACESSOS
		cLINHA += PADR(AllTrim(aUsuario[X][01][14]),90)					// E-MAIL
		@nLin,00 PSAY cLINHA
		nLin := nLin + 1
	END IF
NEXT

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return
