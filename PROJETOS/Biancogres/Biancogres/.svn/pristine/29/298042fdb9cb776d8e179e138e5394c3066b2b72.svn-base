#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBIA1006R  บ Autor ณ Nilton Cesar       บ Data ณ  17/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP7 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Mapa Sugestao de Compras                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BIA1006R()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatorio de Limite de Credito"
	Local cPict          := ""
	Local titulo         := "Relatorio de Limite de Credito"
	Local nLin           := 80
	Local Cabec1         := "                Codigo   Razao Social                                                  Limite de         Limite           Limite   "
	Local Cabec2         := "Representante                                                                           Credito          Tomado          Disponivel"
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "BIA1006R"
	Private nTipo        := 15
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "BIALIM"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "BIA1006R"
	Private cString      := ""
	Private cRepreDe	 := ""
	Private cRepreAte	 := ""
	Private CSQL		 := ""

	U_LOG_USO("BIA1006R")

	dbSelectArea("SA1")
	dbSetOrder(1)

	//ValidPerg()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta a interface padrao com o usuario...                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If GetRemoteType() == 5 .Or. __cUserID="000996"
		If !Pergunte(cPerg,.T.)
			Return
		EndIf

		RptStatus({|| U_BIATRep() })
		Return()
	Else
		pergunte(cPerg,.F.)

		IF EMPTY(CREPATU)
			wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)
		ELSE
			wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)
		END IF 

		If nLastKey == 27
			Return
		Endif
		SetDefault(aReturn,cString)
		If nLastKey == 27
			Return
		Endif
		nTipo := If(aReturn[4]==1,15,18)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  02/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Enter := chr(13) + Chr(10)
	IF EMPTY(CREPATU) //SE REPRESENTANTE (VARIAVEL PRG BIA125)
		cRepre := MV_PAR01
	ELSE
		cRepre := cRepAtu
	ENDIF

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+cRepre)

	//CSQL  := ""
	//CSQL  := "SELECT	ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC, '' A1_COD, '' A1_LOJA, '' A1_NOME,							" + ENTER
	//CSQL  += "		MAX(A1_LC) LC, SUM(PEDIDO) PEDIDO, SUM(TITULO) TITULO, (MAX(A1_LC)-SUM(PEDIDO)-SUM(TITULO)) SALDO	" + ENTER
	//CSQL  += "FROM (SELECT	ACY_GRPVEN = CASE																			" + ENTER
	//CSQL  += "								WHEN SA1_1.A1_GRPVEN <> '' AND SA1_1.A1_YTIPOLC = 'G' THEN ACY_GRPVEN+' - '+ACY_DESCRI		" + ENTER
	//CSQL  += "								ELSE SA1_1.A1_COD+' - '+SA1_1.A1_NOME														" + ENTER
	//CSQL  += "							END,																							" + ENTER
	//CSQL  += "				SA1_1.A1_GRPVEN, SA1_1.A1_YTIPOLC, SA1_1.A1_COD, SA1_1.A1_LOJA, SA1_1.A1_VEND, SA1_1.A1_YVENDI, SA1_1.A1_YVENBE1, SA1_1.A1_YVENVT1, SA1_1.A1_YVENML1, SA1_1.A1_NOME, SA1_1.A1_LC,   " + ENTER
	//CSQL  += "				ISNULL(PED.SALDO,0) PEDIDO, ISNULL(TIT.SALDO,0) TITULO, 						" + ENTER
	//CSQL  += "				ROUND((SA1_1.A1_LC-(ISNULL(PED.SALDO,0)+ISNULL(TIT.SALDO,0))),2) AS SALDO   	" + ENTER
	//CSQL  += "		FROM SA1010 SA1_1 , SA1050 SA1_5, ACY010 ACY, VW_SALDOPEDIDO PED, VW_SALDOTITULO TIT 	" + ENTER
	//CSQL  += "		WHERE	SA1_1.A1_COD	= SA1_5.A1_COD		AND   					   					" + ENTER
	//CSQL  += "				SA1_1.A1_LOJA	= SA1_5.A1_LOJA		AND 										" + ENTER

	////Biancogres
	//IF ALLTRIM(SA3->A3_YEMP) $ '0101'
	//	CSQL += "	(SA1_1.A1_VEND  = '"+cRepre+"' OR SA1_1.A1_YVENDB2 = '"+cRepre+"' OR  SA1_1.A1_YVENDB3 = '"+cRepre+"')  AND " + ENTER
	//ENDIF

	////Incesa
	//IF ALLTRIM(SA3->A3_YEMP) $ '0501'
	//	CSQL += "	(SA1_1.A1_YVENDI = '"+cRepre+"' OR SA1_1.A1_YVENDI2 = '"+cRepre+"' OR  SA1_1.A1_YVENDI3 = '"+cRepre+"') AND 	" + ENTER
	//ENDIF

	////Bellacasa
	//IF ALLTRIM(SA3->A3_YEMP) $ '0599'
	//	CSQL += "	(SA1_1.A1_YVENBE1 = '"+cRepre+"' OR SA1_1.A1_YVENBE2 = '"+cRepre+"' OR  SA1_1.A1_YVENBE3 = '"+cRepre+"') AND 	" + ENTER
	//ENDIF

	////Mundialli
	//IF ALLTRIM(SA3->A3_YEMP) $ '1399'
	//	CSQL += "	(SA1_1.A1_YVENML1 = '"+cRepre+"' OR SA1_1.A1_YVENML2 = '"+cRepre+"' OR  SA1_1.A1_YVENML3 = '"+cRepre+"') AND 	" + ENTER
	//ENDIF

	////Vitcer
	//IF ALLTRIM(SA3->A3_YEMP) $ '1401'
	//	CSQL += "	(SA1_1.A1_YVENVT1 = '"+cRepre+"' OR SA1_1.A1_YVENVT2 = '"+cRepre+"' OR  SA1_1.A1_YVENVT3 = '"+cRepre+"') AND 	" + ENTER
	//ENDIF

	//CSQL  += "				SA1_1.A1_GRPVEN *= ACY_GRPVEN		AND		" + ENTER
	//CSQL  += "				SA1_1.A1_COD	*= PED.C5_CLIENTE	AND 	" + ENTER
	//CSQL  += "				SA1_1.A1_LOJA	*= PED.C5_LOJACLI	AND 	" + ENTER
	//CSQL  += "				SA1_1.A1_COD	*= TIT.E1_CLIENTE	AND 	" + ENTER
	//CSQL  += "				SA1_1.A1_LOJA	*= TIT.E1_LOJA		AND 	" + ENTER
	//CSQL  += "				SA1_1.D_E_L_E_T_ = ''				AND  	" + ENTER
	//CSQL  += "				SA1_5.D_E_L_E_T_ = ''				AND		" + ENTER
	//CSQL  += "				ACY.D_E_L_E_T_	 = '') LIM					" + ENTER
	//CSQL  += "GROUP BY ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC				" + ENTER
	//CSQL  += "UNION														" + ENTER
	//CSQL  += "SELECT	ACY_GRPVEN = CASE								" + ENTER
	//CSQL  += "						WHEN SA1_1.A1_GRPVEN <> '' AND SA1_1.A1_YTIPOLC = 'G' THEN ACY_GRPVEN+' - '+ACY_DESCRI	" + ENTER
	//CSQL  += "						ELSE SA1_1.A1_COD+' - '+SA1_1.A1_NOME													" + ENTER
	//CSQL  += "					END,																						" + ENTER
	//CSQL  += "		SA1_1.A1_GRPVEN, SA1_1.A1_YTIPOLC, SA1_1.A1_COD, SA1_1.A1_LOJA, SA1_1.A1_NOME, 0, 0, 0, 0				" + ENTER
	//CSQL  += "FROM SA1010 SA1_1 , SA1050 SA1_5, ACY010 ACY		" + ENTER
	//CSQL  += "WHERE	SA1_1.A1_COD	 = SA1_5.A1_COD		AND   	" + ENTER
	//CSQL  += "		SA1_1.A1_LOJA	 = SA1_5.A1_LOJA	AND		" + ENTER
	//CSQL  += "		SA1_1.A1_GRPVEN	 <> ''				AND 	" + ENTER
	//CSQL  += "		SA1_1.A1_YTIPOLC = 'G'				AND		" + ENTER

	//IF ALLTRIM(SA3->A3_YEMP) $ '0101'
	//	CSQL += "	(SA1_1.A1_VEND  = '"+cRepre+"' OR SA1_1.A1_YVENDB2 = '"+cRepre+"' OR  SA1_1.A1_YVENDB3 = '"+cRepre+"')  AND " + ENTER
	//ENDIF

	//IF ALLTRIM(SA3->A3_YEMP) $ '0501'
	//	CSQL += "	(SA1_1.A1_YVENDI = '"+cRepre+"' OR SA1_1.A1_YVENDI2 = '"+cRepre+"' OR  SA1_1.A1_YVENDI3 = '"+cRepre+"') AND 	" + ENTER
	//ENDIF

	//IF ALLTRIM(SA3->A3_YEMP) $ '0599'
	//	CSQL += "	(SA1_1.A1_YVENBE1 = '"+cRepre+"' OR SA1_1.A1_YVENBE2 = '"+cRepre+"' OR  SA1_1.A1_YVENBE3 = '"+cRepre+"') AND 	" + ENTER
	//ENDIF

	////Mundialli
	//IF ALLTRIM(SA3->A3_YEMP) $ '1399'
	//	CSQL += "	(SA1_1.A1_YVENML1 = '"+cRepre+"' OR SA1_1.A1_YVENML2 = '"+cRepre+"' OR  SA1_1.A1_YVENML3 = '"+cRepre+"') AND 	" + ENTER
	//ENDIF

	//IF ALLTRIM(SA3->A3_YEMP) $ '1401'
	//	CSQL += "	(SA1_1.A1_YVENVT1 = '"+cRepre+"' OR SA1_1.A1_YVENVT2 = '"+cRepre+"' OR  SA1_1.A1_YVENVT3 = '"+cRepre+"') AND 	" + ENTER
	//ENDIF

	//CSQL  += "		SA1_1.A1_GRPVEN *= ACY_GRPVEN		AND		" + ENTER
	//CSQL  += "		SA1_1.D_E_L_E_T_ = ''				AND  	" + ENTER
	//CSQL  += "		SA1_5.D_E_L_E_T_ = ''				AND		" + ENTER
	//CSQL  += "		ACY.D_E_L_E_T_	 = ''						" + ENTER
	//CSQL  += "ORDER BY A1_GRPVEN								" + ENTER





	//ATUALIZAวรO QUERY - SQL ATUAL - 14/10/2015
	CSQL := ""
	CSQL := "SELECT	ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC, '' A1_COD, '' A1_LOJA, '' A1_NOME, " + ENTER
	CSQL += "		MAX(A1_LC) LC, SUM(PEDIDO) PEDIDO, SUM(TITULO) TITULO, (MAX(A1_LC)-SUM(PEDIDO)-SUM(TITULO)) SALDO " + ENTER
	CSQL += "FROM (SELECT	ACY_GRPVEN = CASE " + ENTER
	CSQL += "								WHEN SA1_1.A1_GRPVEN <> '' AND SA1_1.A1_YTIPOLC = 'G' THEN ACY_GRPVEN+' - '+ACY_DESCRI " + ENTER
	CSQL += "								ELSE SA1_1.A1_COD+' - '+SA1_1.A1_NOME " + ENTER
	CSQL += "							END, " + ENTER
	CSQL += "				SA1_1.A1_GRPVEN, SA1_1.A1_YTIPOLC, SA1_1.A1_COD, SA1_1.A1_LOJA, SA1_1.A1_VEND, SA1_1.A1_YVENDI, SA1_1.A1_YVENBE1, SA1_1.A1_YVENVT1, SA1_1.A1_YVENML1, SA1_1.A1_YVENPEG, SA1_1.A1_YVENVI1, SA1_1.A1_NOME, SA1_1.A1_LC, " + ENTER
	CSQL += "				ISNULL(PED.SALDO,0) PEDIDO, ISNULL(TIT.SALDO,0) TITULO, " + ENTER
	CSQL += "				ROUND((SA1_1.A1_LC-(ISNULL(PED.SALDO,0)+ISNULL(TIT.SALDO,0))),2) AS SALDO " + ENTER
	CSQL += "		FROM SA1010 SA1_1 " + ENTER
	CSQL += "			INNER JOIN SA1050 SA1_5 " + ENTER
	CSQL += "				ON SA1_1.A1_COD	= SA1_5.A1_COD " + ENTER
	CSQL += "					AND SA1_1.A1_LOJA = SA1_5.A1_LOJA " + ENTER
	CSQL += "					AND SA1_5.D_E_L_E_T_ = '' " + ENTER
	CSQL += "			LEFT JOIN ACY010 ACY " + ENTER
	CSQL += "				ON SA1_1.A1_GRPVEN = ACY_GRPVEN " + ENTER
	CSQL += "					AND ACY.D_E_L_E_T_ = '' " + ENTER
	CSQL += "			LEFT JOIN VW_SALDOPEDIDO PED " + ENTER
	CSQL += "				ON SA1_1.A1_COD = PED.C5_CLIENTE " + ENTER
	CSQL += "					AND SA1_1.A1_LOJA = PED.C5_LOJACLI " + ENTER
	CSQL += "			LEFT JOIN VW_SALDOTITULO TIT " + ENTER
	CSQL += "				ON SA1_1.A1_COD = TIT.E1_CLIENTE " + ENTER
	CSQL += "					AND SA1_1.A1_LOJA = TIT.E1_LOJA " + ENTER
	CSQL += "		WHERE " + ENTER

	//Biancogres
	IF ALLTRIM(SA3->A3_YEMP) $ '0101'
		CSQL += "	(SA1_1.A1_VEND  = '"+cRepre+"' OR SA1_1.A1_YVENDB2 = '"+cRepre+"' OR  SA1_1.A1_YVENDB3 = '"+cRepre+"')  AND " + ENTER
	ENDIF

	//Incesa
	IF ALLTRIM(SA3->A3_YEMP) $ '0501'
		CSQL += "	(SA1_1.A1_YVENDI = '"+cRepre+"' OR SA1_1.A1_YVENDI2 = '"+cRepre+"' OR  SA1_1.A1_YVENDI3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	//Bellacasa
	IF ALLTRIM(SA3->A3_YEMP) $ '0599'
		CSQL += "	(SA1_1.A1_YVENBE1 = '"+cRepre+"' OR SA1_1.A1_YVENBE2 = '"+cRepre+"' OR  SA1_1.A1_YVENBE3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	//Mundialli
	IF ALLTRIM(SA3->A3_YEMP) $ '1399'
		CSQL += "	(SA1_1.A1_YVENML1 = '"+cRepre+"' OR SA1_1.A1_YVENML2 = '"+cRepre+"' OR  SA1_1.A1_YVENML3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	//Vitcer
	IF ALLTRIM(SA3->A3_YEMP) $ '1401'
		CSQL += "	(SA1_1.A1_YVENVT1 = '"+cRepre+"' OR SA1_1.A1_YVENVT2 = '"+cRepre+"' OR  SA1_1.A1_YVENVT3 = '"+cRepre+"') AND " + ENTER
	ENDIF
	
	//Pegasus
	IF ALLTRIM(SA3->A3_YEMP) $ '0199'
		CSQL += "	(SA1_1.A1_YVENPEG = '"+cRepre+"' ) AND " + ENTER
	ENDIF
	
	//Vinilico
	IF ALLTRIM(SA3->A3_YEMP) $ '1302'
		CSQL += "	(SA1_1.A1_YVENVI1 = '"+cRepre+"' ) AND " + ENTER
	ENDIF	
	
	CSQL += "				SA1_1.D_E_L_E_T_ = '') LIM " + ENTER
	CSQL += "GROUP BY ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC " + ENTER
	CSQL += "UNION " + ENTER
	CSQL += "SELECT	ACY_GRPVEN = CASE " + ENTER
	CSQL += "						WHEN SA1_1.A1_GRPVEN <> '' AND SA1_1.A1_YTIPOLC = 'G' THEN ACY_GRPVEN+' - '+ACY_DESCRI " + ENTER
	CSQL += "						ELSE SA1_1.A1_COD+' - '+SA1_1.A1_NOME " + ENTER
	CSQL += "					END, " + ENTER
	CSQL += "		SA1_1.A1_GRPVEN, SA1_1.A1_YTIPOLC, SA1_1.A1_COD, SA1_1.A1_LOJA, SA1_1.A1_NOME, 0, 0, 0, 0 " + ENTER
	CSQL += "FROM SA1010 SA1_1 " + ENTER
	CSQL += "	INNER JOIN SA1050 SA1_5 " + ENTER
	CSQL += "		ON SA1_1.A1_COD = SA1_5.A1_COD " + ENTER
	CSQL += "			AND SA1_1.A1_LOJA = SA1_5.A1_LOJA " + ENTER
	CSQL += "			AND SA1_5.D_E_L_E_T_ = '' " + ENTER
	CSQL += "	LEFT JOIN ACY010 ACY " + ENTER
	CSQL += "		ON SA1_1.A1_GRPVEN = ACY_GRPVEN " + ENTER
	CSQL += "			AND ACY.D_E_L_E_T_ = '' " + ENTER
	CSQL += "WHERE SA1_1.A1_GRPVEN	 <> ''				AND " + ENTER
	CSQL += "		SA1_1.A1_YTIPOLC = 'G'				AND " + ENTER

	IF ALLTRIM(SA3->A3_YEMP) $ '0101'
		CSQL += "	(SA1_1.A1_VEND  = '"+cRepre+"' OR SA1_1.A1_YVENDB2 = '"+cRepre+"' OR  SA1_1.A1_YVENDB3 = '"+cRepre+"')  AND " + ENTER
	ENDIF

	IF ALLTRIM(SA3->A3_YEMP) $ '0501'
		CSQL += "	(SA1_1.A1_YVENDI = '"+cRepre+"' OR SA1_1.A1_YVENDI2 = '"+cRepre+"' OR  SA1_1.A1_YVENDI3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	IF ALLTRIM(SA3->A3_YEMP) $ '0599'
		CSQL += "	(SA1_1.A1_YVENBE1 = '"+cRepre+"' OR SA1_1.A1_YVENBE2 = '"+cRepre+"' OR  SA1_1.A1_YVENBE3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	//Mundialli
	IF ALLTRIM(SA3->A3_YEMP) $ '1399'
		CSQL += "	(SA1_1.A1_YVENML1 = '"+cRepre+"' OR SA1_1.A1_YVENML2 = '"+cRepre+"' OR  SA1_1.A1_YVENML3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	IF ALLTRIM(SA3->A3_YEMP) $ '1401'
		CSQL += "	(SA1_1.A1_YVENVT1 = '"+cRepre+"' OR SA1_1.A1_YVENVT2 = '"+cRepre+"' OR  SA1_1.A1_YVENVT3 = '"+cRepre+"') AND " + ENTER
	ENDIF
	
	//Pegasus
	IF ALLTRIM(SA3->A3_YEMP) $ '0199'
		CSQL += "	(SA1_1.A1_YVENPEG = '"+cRepre+"' ) AND " + ENTER
	ENDIF
	
	//Vinilico
	IF ALLTRIM(SA3->A3_YEMP) $ '1302'
		CSQL += "	(SA1_1.A1_YVENVI1 = '"+cRepre+"' ) AND " + ENTER
	ENDIF	
		

	CSQL += "		SA1_1.D_E_L_E_T_ = '' " + ENTER								
	CSQL += "ORDER BY A1_GRPVEN " + ENTER


	TCQUERY CSQL ALIAS "ctrabalho" NEW
	dbSelectArea("ctrabalho")
	dbGotop()
	SetRegua(RecCount())
	SCLI := "N"
	SGRU := "N"
	_GRUPO := ""
	While !EOF()
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

		dbSelectArea("SA3")
		dbsetOrder(1)
		dbseek(xFilial("SA3")+cRepreDe)

		dbSelectArea("ctrabalho")
		@ Prow()+1,10 Psay SA3->A3_NOME

		IF SCLI = "N"
			@ Prow()+1,15      Psay REPLICATE("-",110)
			@ Prow()+1,15      Psay "*********************************************** CLIENTE *******************************************"
			@ Prow()+1,15      Psay REPLICATE("-",110)
			SCLI := "S"
		END IF

		Do while !eof() .and. Prow()<=60
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica o cancelamento pelo usuario...                             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			IF A1_YTIPOLC == "C"
				@ Prow()+1,15      Psay ctrabalho->ACY_GRPVEN
				//@ Prow(),Pcol()+3  Psay ctrabalho->A1_NOME
				@ Prow(),Pcol()+3  Psay " "
				@ Prow(),Pcol()+3  Psay Transform(ctrabalho->LC,    "@E 999,999,999.99")
				@ Prow(),Pcol()+3  Psay Transform(ctrabalho->PEDIDO+ctrabalho->TITULO,"@E 999,999,999.99")
				@ Prow(),Pcol()+3  Psay Transform(ctrabalho->SALDO,"@E 999,999,999.99")
			ELSE
				IF _GRUPO = ""
					IF SGRU = "N"
						@ Prow()+2,15      Psay REPLICATE("-",110)
						@ Prow()+1,15      Psay "***********************************************  GRUPO  *******************************************"
						@ Prow()+1,15      Psay REPLICATE("-",110)
						SGRU := "S"
					END IF
				END IF
				IF _GRUPO = ctrabalho->ACY_GRPVEN
					@ Prow()+1,15      Psay ctrabalho->A1_COD
					@ Prow(),Pcol()+3  Psay ctrabalho->A1_NOME
					@ Prow(),Pcol()+3  Psay " "
					//@ Prow(),Pcol()+3  Psay Transform(ctrabalho->LC,    "@E 999,999,999.99")
					//@ Prow(),Pcol()+3  Psay Transform(ctrabalho->PEDIDO+ctrabalho->TITULO,"@E 999,999,999.99")
					//@ Prow(),Pcol()+3  Psay Transform(ctrabalho->SALDO,"@E 999,999,999.99")
				ELSE
					@ Prow()+1,15      Psay REPLICATE("-",110)
					@ Prow()+1,15      Psay ctrabalho->ACY_GRPVEN
					@ Prow(),Pcol()+3  Psay " "
					@ Prow(),Pcol()+3  Psay Transform(ctrabalho->LC,    "@E 999,999,999.99")
					@ Prow(),Pcol()+3  Psay Transform(ctrabalho->PEDIDO+ctrabalho->TITULO,"@E 999,999,999.99")
					@ Prow(),Pcol()+3  Psay Transform(ctrabalho->SALDO,"@E 999,999,999.99")
					_GRUPO := ctrabalho->ACY_GRPVEN
				END IF
			END IF

			DbSkip()
		EndDo
	EndDo
	SET DEVICE TO SCREEN
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
	DbSelectArea("ctrabalho")
	DbCloseArea()
Return

/*
##############################################################################################################
# PROGRAMA...: BIATRep         
# AUTOR......: LUANA MARIN RIBEIRO
# DATA.......: 23/10/2015                      
# DESCRICAO..: FAZER O RELATำRIO COM TREPORT
##############################################################################################################
*/
User Function BIATRep()

	Local oReport

	oReport:= RDef()
	oReport:PrintDialog()

Return NIL   

//COM SEวรO POR ZONA
Static Function RDef()
	Local oReport
	Local oSection1
	Local Enter := chr(13) + Chr(10)
	Local cTitle    := "Relatorio de Limite de Credito"
	Local cQryRel   := ""


	oReport:= TReport():New("BIA1006R",cTitle,, {|oReport| RPt(oReport)},cTitle,,,.T.)
	//oReport:SetLandscape() 			//Define a orientacao de pagina do relatorio como paisagem.
	Pergunte(oReport:GetParam(),.F.)	

	oSecRep := TRSection():New(oReport, "Rep", {"CTRAB"})
	//apresenta em linha, nใo em colunas.    
	oSecRep:SetLineStyle(.T.)
	TRCell():New(oSecRep,'A3_NOME',,'',,25,,,"LEFT",,"LEFT")

	oSecCli := TRSection():New(oReport, "Cliente", {"CTRAB"},,,,,,,,,,10)
	oSecCli:SetHeaderPage() 
	//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	TRCell():New(oSecCli,'A1_COD',,'Codigo - Razao Social',,50,,,"LEFT",,"LEFT")
	TRCell():New(oSecCli,'LC',,'Limite de' + Enter + 'Credito',"@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecCli,'PEDIDO',,'Limite' + Enter + 'Tomado',"@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecCli,'SALDO',,'Limite' + Enter + 'Disponivel',"@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")

Return(oReport)                                      

Static Function RPt(oReport)

	Local oSecRep := oReport:Section(1)
	Local oSecCli := oReport:Section(2)
	Local printLin := 0

	Enter := chr(13) + Chr(10)
	IF EMPTY(CREPATU) //SE REPRESENTANTE (VARIAVEL PRG BIA125)
		cRepre := MV_PAR01
	ELSE
		cRepre := cRepAtu
	ENDIF

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+cRepre)

	CSQL := ""
	CSQL := "SELECT	ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC, '' A1_COD, '' A1_LOJA, '' A1_NOME, " + ENTER
	CSQL += "		MAX(A1_LC) LC, SUM(PEDIDO) PEDIDO, SUM(TITULO) TITULO, (MAX(A1_LC)-SUM(PEDIDO)-SUM(TITULO)) SALDO " + ENTER
	CSQL += "FROM (SELECT	ACY_GRPVEN = CASE " + ENTER
	CSQL += "								WHEN SA1_1.A1_GRPVEN <> '' AND SA1_1.A1_YTIPOLC = 'G' THEN ACY_GRPVEN+' - '+ACY_DESCRI " + ENTER
	CSQL += "								ELSE SA1_1.A1_COD+' - '+SA1_1.A1_NOME " + ENTER
	CSQL += "							END, " + ENTER
	CSQL += "				SA1_1.A1_GRPVEN, SA1_1.A1_YTIPOLC, SA1_1.A1_COD, SA1_1.A1_LOJA, SA1_1.A1_VEND, SA1_1.A1_YVENDI, SA1_1.A1_YVENBE1, SA1_1.A1_YVENVT1, SA1_1.A1_YVENML1, SA1_1.A1_NOME, SA1_1.A1_LC, " + ENTER
	CSQL += "				ISNULL(PED.SALDO,0) PEDIDO, ISNULL(TIT.SALDO,0) TITULO, " + ENTER
	CSQL += "				ROUND((SA1_1.A1_LC-(ISNULL(PED.SALDO,0)+ISNULL(TIT.SALDO,0))),2) AS SALDO " + ENTER
	CSQL += "		FROM SA1010 SA1_1 " + ENTER
	CSQL += "			INNER JOIN SA1050 SA1_5 " + ENTER
	CSQL += "				ON SA1_1.A1_COD	= SA1_5.A1_COD " + ENTER
	CSQL += "					AND SA1_1.A1_LOJA = SA1_5.A1_LOJA " + ENTER
	CSQL += "					AND SA1_5.D_E_L_E_T_ = '' " + ENTER
	CSQL += "			LEFT JOIN ACY010 ACY " + ENTER
	CSQL += "				ON SA1_1.A1_GRPVEN = ACY_GRPVEN " + ENTER
	CSQL += "					AND ACY.D_E_L_E_T_ = '' " + ENTER
	CSQL += "			LEFT JOIN VW_SALDOPEDIDO PED " + ENTER
	CSQL += "				ON SA1_1.A1_COD = PED.C5_CLIENTE " + ENTER
	CSQL += "					AND SA1_1.A1_LOJA = PED.C5_LOJACLI " + ENTER
	CSQL += "			LEFT JOIN VW_SALDOTITULO TIT " + ENTER
	CSQL += "				ON SA1_1.A1_COD = TIT.E1_CLIENTE " + ENTER
	CSQL += "					AND SA1_1.A1_LOJA = TIT.E1_LOJA " + ENTER
	CSQL += "		WHERE " + ENTER

	//Biancogres
	IF ALLTRIM(SA3->A3_YEMP) $ '0101'
		CSQL += "	(SA1_1.A1_VEND  = '"+cRepre+"' OR SA1_1.A1_YVENDB2 = '"+cRepre+"' OR  SA1_1.A1_YVENDB3 = '"+cRepre+"')  AND " + ENTER
	ENDIF

	//Incesa
	IF ALLTRIM(SA3->A3_YEMP) $ '0501'
		CSQL += "	(SA1_1.A1_YVENDI = '"+cRepre+"' OR SA1_1.A1_YVENDI2 = '"+cRepre+"' OR  SA1_1.A1_YVENDI3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	//Bellacasa
	IF ALLTRIM(SA3->A3_YEMP) $ '0599'
		CSQL += "	(SA1_1.A1_YVENBE1 = '"+cRepre+"' OR SA1_1.A1_YVENBE2 = '"+cRepre+"' OR  SA1_1.A1_YVENBE3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	//Mundialli
	IF ALLTRIM(SA3->A3_YEMP) $ '1399'
		CSQL += "	(SA1_1.A1_YVENML1 = '"+cRepre+"' OR SA1_1.A1_YVENML2 = '"+cRepre+"' OR  SA1_1.A1_YVENML3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	//Vitcer
	IF ALLTRIM(SA3->A3_YEMP) $ '1401'
		CSQL += "	(SA1_1.A1_YVENVT1 = '"+cRepre+"' OR SA1_1.A1_YVENVT2 = '"+cRepre+"' OR  SA1_1.A1_YVENVT3 = '"+cRepre+"') AND " + ENTER
	ENDIF
	CSQL += "				SA1_1.D_E_L_E_T_ = '') LIM " + ENTER
	CSQL += "GROUP BY ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC " + ENTER
	CSQL += "UNION " + ENTER
	CSQL += "SELECT	ACY_GRPVEN = CASE " + ENTER
	CSQL += "						WHEN SA1_1.A1_GRPVEN <> '' AND SA1_1.A1_YTIPOLC = 'G' THEN ACY_GRPVEN+' - '+ACY_DESCRI " + ENTER
	CSQL += "						ELSE SA1_1.A1_COD+' - '+SA1_1.A1_NOME " + ENTER
	CSQL += "					END, " + ENTER
	CSQL += "		SA1_1.A1_GRPVEN, SA1_1.A1_YTIPOLC, SA1_1.A1_COD, SA1_1.A1_LOJA, SA1_1.A1_NOME, 0, 0, 0, 0 " + ENTER
	CSQL += "FROM SA1010 SA1_1 " + ENTER
	CSQL += "	INNER JOIN SA1050 SA1_5 " + ENTER
	CSQL += "		ON SA1_1.A1_COD = SA1_5.A1_COD " + ENTER
	CSQL += "			AND SA1_1.A1_LOJA = SA1_5.A1_LOJA " + ENTER
	CSQL += "			AND SA1_5.D_E_L_E_T_ = '' " + ENTER
	CSQL += "	LEFT JOIN ACY010 ACY " + ENTER
	CSQL += "		ON SA1_1.A1_GRPVEN = ACY_GRPVEN " + ENTER
	CSQL += "			AND ACY.D_E_L_E_T_ = '' " + ENTER
	CSQL += "WHERE SA1_1.A1_GRPVEN	 <> ''				AND " + ENTER
	CSQL += "		SA1_1.A1_YTIPOLC = 'G'				AND " + ENTER

	IF ALLTRIM(SA3->A3_YEMP) $ '0101'
		CSQL += "	(SA1_1.A1_VEND  = '"+cRepre+"' OR SA1_1.A1_YVENDB2 = '"+cRepre+"' OR  SA1_1.A1_YVENDB3 = '"+cRepre+"')  AND " + ENTER
	ENDIF

	IF ALLTRIM(SA3->A3_YEMP) $ '0501'
		CSQL += "	(SA1_1.A1_YVENDI = '"+cRepre+"' OR SA1_1.A1_YVENDI2 = '"+cRepre+"' OR  SA1_1.A1_YVENDI3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	IF ALLTRIM(SA3->A3_YEMP) $ '0599'
		CSQL += "	(SA1_1.A1_YVENBE1 = '"+cRepre+"' OR SA1_1.A1_YVENBE2 = '"+cRepre+"' OR  SA1_1.A1_YVENBE3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	//Mundialli
	IF ALLTRIM(SA3->A3_YEMP) $ '1399'
		CSQL += "	(SA1_1.A1_YVENML1 = '"+cRepre+"' OR SA1_1.A1_YVENML2 = '"+cRepre+"' OR  SA1_1.A1_YVENML3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	IF ALLTRIM(SA3->A3_YEMP) $ '1401'
		CSQL += "	(SA1_1.A1_YVENVT1 = '"+cRepre+"' OR SA1_1.A1_YVENVT2 = '"+cRepre+"' OR  SA1_1.A1_YVENVT3 = '"+cRepre+"') AND " + ENTER
	ENDIF

	CSQL += "		SA1_1.D_E_L_E_T_ = '' " + ENTER								
	CSQL += "ORDER BY A1_GRPVEN " + ENTER


	TCQUERY CSQL ALIAS "ctrabalho" NEW
	dbSelectArea("ctrabalho")
	dbGotop()
	SetRegua(RecCount())

	SCLI := "N"
	SGRU := "N"
	_GRUPO := ""

	While !EOF()

		dbSelectArea("SA3")
		dbsetOrder(1)
		dbseek(xFilial("SA3")+cRepreDe)

		dbSelectArea("ctrabalho")

		oSecRep:SetHeaderSection(.T.)
		oSecRep:Init()

		oSecRep:Cell("A3_NOME"):SetValue(SA3->A3_NOME)
		oSecRep:PrintLine()

		IF SCLI = "N"		
			oReport:SkipLine(1)
			oReport:FatLine()		
			oReport:SkipLine(1)
			oReport:PrtCenter("*********************************************** CLIENTE *******************************************")
			oReport:SkipLine(2)
			oReport:FatLine()
			oReport:SkipLine(1)

			SCLI := "S"
		END IF

		Do while !eof() .and. Prow()<=60
			oSecCli:Init()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica o cancelamento pelo usuario...                             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lAbortPrint
				oReport:SkipLine(1)
				oReport:PrtCenter("*** CANCELADO PELO OPERADOR ***")
				oReport:SkipLine(1)
				Exit
			Endif
			IF A1_YTIPOLC == "C" 

				//oSecCli:SetHeaderSection(.T.)
				oSecCli:Cell("A1_COD"):SetValue(ctrabalho->ACY_GRPVEN)
				oSecCli:Cell("LC"):SetValue(ctrabalho->LC)	
				oSecCli:Cell("PEDIDO"):SetValue(ctrabalho->PEDIDO+ctrabalho->TITULO)
				oSecCli:Cell("SALDO"):SetValue(ctrabalho->SALDO)
				oSecCli:PrintLine()
			ELSE
				IF _GRUPO = ""
					IF SGRU = "N"
						printLin := 0
						oReport:SkipLine(1)
						oReport:FatLine()		
						oReport:SkipLine(1)
						oReport:PrtCenter("*********************************************** GRUPO *******************************************")
						oReport:SkipLine(2)
						oReport:FatLine()
						oReport:SkipLine(1)
						SGRU := "S"
					END IF
				END IF
				IF _GRUPO = ctrabalho->ACY_GRPVEN
					oSecCli:SetHeaderSection(.T.)
					oSecCli:Cell("A1_COD"):SetValue(ctrabalho->A1_COD + " - " + ctrabalho->A1_NOME)
					oSecCli:PrintLine()
				ELSE
					If printLin > 1 
						oReport:SkipLine(1)
						oReport:FatLine()		
						oReport:SkipLine(1)
					EndIf

					oSecCli:Cell("A1_COD"):SetValue(ctrabalho->ACY_GRPVEN)
					oSecCli:Cell("LC"):SetValue(ctrabalho->LC)	
					oSecCli:Cell("PEDIDO"):SetValue(ctrabalho->PEDIDO+ctrabalho->TITULO)
					oSecCli:Cell("SALDO"):SetValue(ctrabalho->SALDO)
					oSecCli:PrintLine()

					_GRUPO := ctrabalho->ACY_GRPVEN
				END IF
			END IF

			DbSkip()

			printLin := printLin + 1
		EndDo 
		oSecCli:Finish()
	EndDo
	oSecRep:Finish()

	DbSelectArea("ctrabalho")
	DbCloseArea()
Return










/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	 ณValidPerg    ณ Autor ณ Bruno Madaleno                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Cria as perguntas no SX1                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg()

	Local i
	dbSelectArea("SX1")
	dbSetOrder(1)

	aRegs := {}

	aadd(aRegs,{cPerg,"01" ,"Vendedor De         ","mv_ch1","C"  ,6     ,0      ,"G",""                                       ,"mv_par01","SA3",""   ,""   })
	//aadd(aRegs,{cPerg,"01" ,"Vebndedor Ate       ","mv_ch2","C"  ,6     ,0      ,"G",""                                       ,"mv_par02","SA3",""   ,""   })
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza SX1                                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If  ! dbSeek(aRegs[1,1])
		For i := 1 to len(aRegs)
			RecLock("SX1",.T.)
			SX1->X1_GRUPO   := aRegs[i,1]
			SX1->X1_ORDEM   := aRegs[i,2]
			SX1->X1_PERGUNT := aRegs[i,3]
			SX1->X1_VARIAVL := aRegs[i,4]
			SX1->X1_TIPO    := aRegs[i,5]
			SX1->X1_TAMANHO := aRegs[i,6]
			SX1->X1_DECIMAL := aRegs[i,7]
			SX1->X1_GSC     := aRegs[i,8]
			SX1->X1_VALID   := aRegs[i,9]
			SX1->X1_VAR01   := aRegs[i,10]
			SX1->X1_F3      := aRegs[i,11]
			SX1->X1_DEF01   := aRegs[i,12]
			SX1->X1_DEF02   := aRegs[i,13]
			msUnlock()
		Next
		dbCommit()
	Endif

Return()
