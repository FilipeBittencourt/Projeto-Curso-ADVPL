#include "rwMake.ch"
#include "Topconn.ch"
#include "ap5mail.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	ENV_PC      ³ Autor ³BRUNO MADALENO        ³ Data ³ 18/08/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ ENVIA PEDIDO DE COMPRA POR EMAIL                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER Function ENV_PC()
	Private cEOL := "CHR(13)+CHR(10)"
	Private cFORNECEDOR := ""
	Private cPEDIDO := ""
	Private cLOJA := ""
	PRIVATE EMAIL := ""
	PRIVATE CSQL := ""
	PRIVATE nTotRegs
	PRIVATE ccFLAG := "SIM"
	PRIVATE CREMETENTE := ""
	Private cArqTxt
	Private nHdl
	Private cEOL    := "CHR(13)+CHR(10)"
	Private COBS := ""
	PRIVATE TOTAL_MERC := 0
	PRIVATE TOTAL_IPI := 0
	PRIVATE TOTAL_FRETE := 0
	PRIVATE TOTAL_DESC := 0
	PRIVATE EMAIL := ""
	PRIVATE SCONDPG := ""

	PRIVATE wUsuario

	Private nARQUIVO := ""
	Private nLINHA_LOG := ""

	Private sTRANSPORTADORA := SPACE(6)
	Private sTRA1 := SPACE(50)

	IF ALTERA .OR. INCLUI
		MsgBox("SO É PERMITIDO ENVIAR EMAIL QUANDO ESTIVER VIZUALIZANDO O PEDIDO","Alerta","STOP")
		RETURN()
	END IF


	If !fPedLib(SC7->C7_NUM, SC7->C7_FORNECE)

		MsgBox("Não é permitido o envio do pedido, pois o mesmo não possui saldo em estoque ou foi eliminado por residuo/encerrado.", "Alerta", "STOP")

		Return()

	EndIf


//pswseek(__cUserID,.t.)
//wUsuario := pswret(1)[1][1]
	wUsuario := RetCodUsr()
	CREMETENTE := ALLTRIM(UsrRetMail(wUsuario))
//CREMETENTE := ALLTRIM(pswret(1)[1][14])


	IF TYPE ("CA120NUM") == "U"
		CA120NUM := SC7->C7_NUM
	endif
	IF TYPE ("CA120FORN") == "U"
		CA120FORN := SC7->C7_FORNECE
	endif
	IF TYPE ("CA120LOJ") == "U"
		CA120LOJ := SC7->C7_LOJA
	endif

//VERIFICANDO SE O PEDIDOESTA LIBERADO
	cQuery := 	""
	cQuery +=	"SELECT CR_STATUS 						"
	cQuery +=	"FROM "+RetSqlName("SCR")+" 			"
	cQuery +=	"WHERE D_E_L_E_T_ 	= '' AND			"
	cQuery +=	"      CR_NUM		= '"+CA120NUM+"' 	"
	If chkfile("_SCR")
		dbSelectArea("_SCR")
		dbCloseArea()
	EndIf
	TCQuery cQuery Alias "_SCR" New

//VERIFICANDO SE O USUARIO PERTENCE AO GRUPO DE COMPRADORES
	cQuery := 	""
	cQuery +=	"SELECT COUNT(Y1_USER) AS QUANT FROM SY1010 "
	cQuery +=	"WHERE 	Y1_USER = '"+wUsuario+"' AND "
	cQuery +=	"		D_E_L_E_T_ = '' "
	If chkfile("_SY1")
		dbSelectArea("_SY1")
		dbCloseArea()
	EndIf
	TCQuery cQuery Alias "_SY1" New

	If _SCR->CR_STATUS <> "02"

		If _SY1->QUANT > 0


			@ 96,42 TO 280,360 DIALOG oEntra TITLE "INFORME A TRANSPORTADORA ENVIAR O EMAIL"
			@ 8,12 TO 84,150
			@ 17,40 SAY "Informe o codigo da transportadora : "
			@ 28,70 Get sTRANSPORTADORA Object oGet F3 "SA4"
			@ 55,50 BUTTON "_Submeter" SIZE 30,15 ACTION Close(oEntra)
			ACTIVATE DIALOG oEntra CENTERED


			If Alltrim(sTRANSPORTADORA) <> ""

				cCodTransp := sTRANSPORTADORA
				sTRANSPORTADORA := Posicione("SA4",1,xFilial("SA4")+sTRANSPORTADORA,"A4_NOME")

				ARQUIVO_PC()

				If EMPTY(EMAIL)

					MsgBox("EMAIL NÃO CADASTRADO","Alerta","STOP")

					Return()

				EndIf

				If ccFLAG = "SIM"

					CRIA_EMAIL()

					cQuery := " UPDATE "+RETSQLNAME("SC7")+" SET C7_YEMAIL = 'S', C7_YTRANSP = '"+cCodTransp+"', "
					cQuery += " C7_YDTENV = " + ValToSQL(dDataBase) + ", C7_YHRENV = " + ValToSQL(SubStr(Time(), 1, 5))
					cQuery += " WHERE C7_NUM = '"+CA120NUM+"' AND "
					cQuery += "	D_E_L_E_T_ = '' AND C7_FILIAL = '"+xFilial("SC7")+"' "
					TcSQLExec(cQuery)

					ENVIA_TRANSP()

				ELSE

					MsgBox("EMAIL NÃO ENVIADO. PEDIDO PARCIALMENTE ATENDIDO","Alerta","STOP")

				EndIf

			Else

				MsgBox("EMAIL NÃO ENVIADO","Alerta","STOP")

			EndIf

		Else

			MsgBox("USUARIO NÃO AUTORIZADO","Alerta","STOP")

		EndIf

	Else

		MsgBox("PEDIDO BLOQUEADO","Alerta","STOP")

	EndIf

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ARQUIVO_PC           ºAutor  ³BRUNO MADALENO º Data ³ 04/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ROTINA PARA GERAR E CRIAR O PEDIDO DE COMPRA                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION ARQUIVO_PC()
	Local J := 1

	Enter := chr(13) + Chr(10)

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	cFORNECEDOR  :=  CA120FORN
	cPEDIDO :=CA120NUM
	cLOJA := CA120LOJ

	cArqTxt := "\P10\relato\PC\" 	+ cFORNECEDOR + "_PC.TXT"

	CSQL := " SELECT * "
	CSQL += " FROM "+ RetSQLName("SC7")
	CSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	CSQL += "	AND C7_NUM = " + ValToSQL(cPEDIDO)
	CSQL += "	AND C7_FORNECE = " + ValToSQL(cFORNECEDOR)
	CSQL += "	AND C7_RESIDUO = '' "
	CSQL += "	AND C7_ENCER = '' "
	CSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	CSQL += "	AND D_E_L_E_T_ = '' "

	If chkfile("ctrabalho")
		DbSelectArea("ctrabalho")
		DbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "ctrabalho" NEW

	dbSelectArea("ctrabalho")
	dbGotop()

	IF !ctrabalho->(EOF())
		nHdl    := fCreate(cArqTxt)
	END IF

	IF ctrabalho->C7_QUJE = 0
		ccFLAG = "SIM"
	ELSE
		ccFLAG = "NAO"
	END IF

	it_Serv := .F.

	While !EOF()

		dbSelectArea("SA2")
		dbsetOrder(1)
		dbseek(xFilial("SA2")+cFORNECEDOR+CLOJA)
		dbSelectArea("ctrabalho")

		EMAIL := ALLTRIM(SA2->A2_EMAIL)

		//************* IMPRIMINDO O CABECALHO   *****************
		cLin := PADL("EMISSAO: " + ALLTRIM(DTOC(STOD(ctrabalho->C7_EMISSAO))),126)
		fWrite(nHdl,cLin+cEOL)


		cLin := REPLICATE(" ",56) + "####################"
		fWrite(nHdl,cLin+cEOL)

		cLin := REPLICATE(" ",56) + "# PEDIDO DE COMPRA #" + REPLICATE(" ",10) + PADL(ctrabalho->C7_NUM,7)
		fWrite(nHdl,cLin+cEOL)

		cLin := REPLICATE(" ",56) + "####################"
		fWrite(nHdl,cLin+cEOL)


		cLin := "  " + REPLICATE("_",61) + "     " + REPLICATE("_",61)
		fWrite(nHdl,cLin+cEOL)

		cLin := " |" + REPLICATE(" ",60) + " |   |" + REPLICATE(" ",60) + " |"
		fWrite(nHdl,cLin+cEOL)

		DO CASE
		CASE cempant = "01"
			cLin := PADR(" |BIANCOGRÊS CERÂMICA S/A ",62)									+ PADR(" |   |FORN..:" + SA2->A2_COD + " " 	+ SA2->A2_LOJA + " " + SA2->A2_NOME + " ",66) + " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |Av.Talma Rodrigues Ribeiro, 1145 Civit II ",62)    			    + PADR(" |   |END...:" + SA2->A2_END,66)		+ " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |Cep: 29.168-080, Serra/ES ",62)									+ PADR(" |   |CIDADE:" + SA2->A2_MUN,30) 		+ PADR("UF..:" + SA2->A2_EST,18) + PADR("CEP:" + SA2->A2_CEP,18)+ " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) 			+ PADR(" |   |C.G.C.:" + SA2->A2_CGC,30) 		+ PADR("I.E.:" + SA2->A2_INSCR,36) + " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |Fax: ",62)														+ PADR(" |   |TEL...:" + SA2->A2_TEL,30) 		+ PADR("FAX.:" + SA2->A2_FAX,36) + " |" //OS 1760-16 Cláudia Carvalho - Luana Marin Ribeiro
			//cLin := PADR(" |Fax: (27)3421-9040 ",62)										+ PADR(" |   |TEL...:" + SA2->A2_TEL,30) 		+ PADR("FAX.:" + SA2->A2_FAX,36) + " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |CGC: 02.077.546/0001-76  IE: 081936443 ",62)					+ PADR(" |   |CONT..:" + SA2->A2_CONTATO,66) 	+ " |"
			fWrite(nHdl,cLin+cEOL)
		CASE cempant = "05"
			cLin := PADR("INCESA REVESTIMENTO CERAMICO LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua 3, 648, Civit II                     ",62)  		+ PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-079, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: ",62)										+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8) //OS 1760-16 Cláudia Carvalho - Luana Marin Ribeiro
			//cLin := PADR("Fax: (27)3421-9040 ",62)						+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 04.917.232/0001-60  IE: 082.140.12-0 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
		CASE cempant = "07"
			cLin := PADR("LM COMERCIO LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua Dois, Lote 07 Quadra VI - Civit II",62)  		+ PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-081, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Tel: (27)3421-9001 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: (27)3421-9039 ",62)						+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 10.524.837/0001-93  IE: 082.591.70-9 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
		CASE cempant = "12"
			cLin := PADR("ST GESTAO DE NEGOCIOS LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua Dois, 246, Quadra VI, Lote 07, SL 04, Civit II",62) + PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-081, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Tel: (27)3421-9100 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: (27)3421-9039 ",62) + PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 13.231.737/0001-67 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
		CASE cempant = "13"
			cLin := PADR("MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA ",62) + PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua Holdercim, 165, Lote 03, Quadra VI, Civit II ",62) + PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-066, Serra/ES ",62)	+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Tel: (27)3421-9000 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: (27)3421-9039 ",62) + PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 14.086.214/0001-37  IE: 082.819.61-0 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
		CASE cempant = "14"
			cLin := PADR("VITCER RETIFICA E COMPLEMENTOS CERAMICOS LTDA ",62) + PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua Dois, Lote 07, Quadra VI, Civit II ",62) + PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-081, Serra/ES ",62)	+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			//3421-9000
			//cLin := PADR("Tel: (27)3218-6517 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			cLin := PADR("Tel: (27)3421-9000 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			//cLin := PADR("Fax: (27)3218-6517 ",62) + PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			cLin := PADR("Fax: (27)3421-9000 ",62) + PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 08.930.868/0001-00  IE: 082.468.96-6 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
		ENDCASE

		cLin := " |" + REPLICATE("_",61) + "|   |" + REPLICATE("_",61) + "|"
		fWrite(nHdl,cLin+cEOL)
		cLin := REPLICATE(" ",120)
		fWrite(nHdl,cLin+cEOL)

		cLin := " " + REPLICATE("-",129)
		fWrite(nHdl,cLin+cEOL)

		cLin := PADC(" TP",4)
		cLin += PADC("COD",9)
		cLin += PADR("DESCRICAO",34)
		cLin += PADC("UN",5)
		cLin += PADC("DT.SAI.",11)
		//cLin += PADC("DT.CHE.",11) /// ALTERADO POR BRUNO
		cLin += PADC("TES",4)
		cLin += PADC("IMP.",4)
		cLin += PADL("QTD",15)
		cLin += PADL("P.UNIT",15)
		cLin += PADC("IPI",6)
		cLin += PADL("VAL.TOT",15)
		cLin += PADC("S.C",6)
		fWrite(nHdl,cLin+cEOL)

		cLin := " " + REPLICATE("-",129)
		fWrite(nHdl,cLin+cEOL)

		Do while !eof() //.and. J<=60

			// Implementado em 30/11/11 por Marcos Alberto para atender a OS Effettivo 0373-11.
			If Substr(ctrabalho->C7_PRODUTO,1,3) == "306"
				it_Serv := .T.
			EndIf

			J ++
			I := 1
			nQUANT := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLin := " " + PADR(POSICIONE("SB1",1,XFILIAL("SB1")+ctrabalho->C7_PRODUTO,"B1_TIPO"),3) //PADC(ctrabalho->C7_TIPO,3)
			cLin += PADC(ctrabalho->C7_PRODUTO,9)
			cLin += PADR(ctrabalho->C7_DESCRI,34)
			cLin += PADC(ctrabalho->C7_UM,5)
			cLin += PADC(ALLTRIM(DTOC(STOD(ctrabalho->C7_DATPRF))),11)
			//cLin += PADC(ALLTRIM(DTOC(STOD(ctrabalho->C7_YDATCHE))),11) /// ALTERADO POR BRUNO
			cLin += PADC(ctrabalho->C7_TES,4)
			IMPOSTOS := IIf(ctrabalho->C7_YICMS = "S","M","") + IIf(ctrabalho->C7_YPIS = "S","P","")
			IMPOSTOS += IIf(ctrabalho->C7_YCOF = "S","M","C") + IIf(ctrabalho->C7_YIPI = "S","I","")
			cLin += PADC(IMPOSTOS,4)
			cLin += PADR(Transform(ctrabalho->C7_QUANT,    "@E 999,999,999.99"),15)
			cLin += PADR(Transform(ctrabalho->C7_PRECO,    "@E 99,999,999.9999"),15)
			cLin += PADC(ctrabalho->C7_IPI,6)
			cLin += PADR(Transform(ctrabalho->C7_TOTAL,    "@E 999,999,999.99"),15)
			cLin += PADC(ctrabalho->C7_NUMSC,6)
			fWrite(nHdl,cLin+cEOL)


			nQUANT := LEN(ALLTRIM(ctrabalho->C7_DESCRI)) - 34
			I := 35
			DO WHILE nQUANT > 34
				cLin := REPLICATE(" ",13) + SUBSTRING(ALLTRIM(ctrabalho->C7_DESCRI), I ,34)
				fWrite(nHdl,cLin+cEOL)
				I := I + 34
				nQUANT := nQUANT - 34
			END DO
			IF nQUANT <> 0
				cLin := REPLICATE(" ",13) + SUBSTRING(ALLTRIM(ctrabalho->C7_DESCRI), I ,34)
				fWrite(nHdl,cLin+cEOL)
			END IF

			//OBSERVACAO
			cLin := ALLTRIM("  OBSERVAÇÃO: " + ALLTRIM(ctrabalho->C7_OBS))
			IF cLin <> ""
				fWrite(nHdl,cLin+cEOL)
			END IF

			SCONDPG 	:= Posicione("SE4",1,xFilial("SE4")+ctrabalho->C7_COND,"E4_DESCRI")
			TOTAL_MERC 	+= ctrabalho->C7_TOTAL
			TOTAL_IPI 	+= round((( ctrabalho->C7_PRECO/100)* ctrabalho->C7_IPI) * ctrabalho->C7_QUANT,2)
			TOTAL_FRETE += ctrabalho->C7_VALFRE
			TOTAL_DESC 	+= ctrabalho->C7_VLDESC
			IIF(EMPTY(COBS),COBS := ctrabalho->C7_VLDESC,"")

			DbSkip()
		EndDo
	EndDo
	NTOTALGERAL := (TOTAL_MERC+TOTAL_IPI+TOTAL_FRETE) - TOTAL_DESC

	cLin := " "
	fWrite(nHdl,cLin+cEOL)
	cLin := " "
	fWrite(nHdl,cLin+cEOL)

	cLin := "  " + REPLICATE("_",127)
	fWrite(nHdl,cLin+cEOL)

	cLin := " |" + REPLICATE(" ",38) + " |" + REPLICATE(" ",86) + " |"
	fWrite(nHdl,cLin+cEOL)

	cLin := PADR(" |TOTAL DAS MERCADORIAS.: ",25)	+	PADR(Transform(TOTAL_MERC,    "@E 999,999,999.99"),15) + " |"
	cLin += PADR(" Transportadora : " + sTRANSPORTADORA ,86)  + " |"
	fWrite(nHdl,cLin+cEOL)

	cLin := PADR(" |VALOR IPI.............: ",25)	+	PADR(Transform(TOTAL_IPI,    "@E 999,999,999.99"),15) 	+ " |"
	cLin += PADR(" " + Replicate("-",84) +" " ,86)  + " |"
	fWrite(nHdl,cLin+cEOL)

	cLin := PADR(" |VALOR FRETE...........: ",25)	+	PADR(Transform(TOTAL_FRETE,    "@E 999,999,999.99"),15)	+ " |"
	cLin += PADR("  OBSERVAÇOES",86)  + " |"
	fWrite(nHdl,cLin+cEOL)

	cLin := PADR(" |DESCONTO..............: ",25)	+	PADR(Transform(TOTAL_DESC,    "@E 999,999,999.99"),15)	+ " |"
	cLin += PADR(" 1. Os pagamentos referentes a esse pedido de compras somente serão feitos",86) + " |"
	fWrite(nHdl,cLin+cEOL)

	cLin := PADR(" |TOTAL GERAL...........: ",25)	+	PADR(Transform(NTOTALGERAL,    "@E 999,999,999.99"),15)+ " |"
	cLin += PADR("    preferencialmente através de emissao de boletos bancários.",86) + " |"
	fWrite(nHdl,cLin+cEOL)

	cLin := PADR(" |COND. PAGAMENTO.......: ",25)	+	PADR(SCONDPG,15)										+ " |"
	cLin += PADR(" 2. Nao será permitido o desconto de títulos com bancos, empresas de factoring",86) + " |"
	fWrite(nHdl,cLin+cEOL)

	cLin := PADR(" |",40) + " |"
	cLin += PADR("    e/ou repasse de direitos a favor de terceiros.",86) + " |"
	fWrite(nHdl,cLin+cEOL)

	cLin := " |" + REPLICATE(" ",38) + " |" + REPLICATE(" ",86) + " |"
	fWrite(nHdl,cLin+cEOL)

//IMPRIMINDO A OBSERVACAO EM 2 LINHAS
	I := 0
	nQUANT := LEN(ALLTRIM(COBS))
	DO WHILE nQUANT > 80
		cLin := " |" + REPLICATE(" ",38) + " |" 	+ SUBSTRING(ALLTRIM(COBS), I ,87)  + " |"
		fWrite(nHdl,cLin+cEOL)
		I := I + 80
		nQUANT := nQUANT - 80
	END DO
	IF nQUANT <> 0
		cLin := " |" + REPLICATE(" ",38) + " |" 	+ SUBSTRING(ALLTRIM(COBS), I ,87)  + " |"
		fWrite(nHdl,cLin+cEOL)
	END IF

	cLin := " |" + REPLICATE("_",39) + "|" + REPLICATE("_",87) + "|"
	fWrite(nHdl,cLin+cEOL)

	cLin := " "
	fWrite(nHdl,cLin+cEOL)

	cLin := " INFORMAÇÃO OBRIGATÓRIA: "
	fWrite(nHdl,cLin+cEOL)
//cLin := "   					1 - Informar na nota fiscal o número deste pedido de compra. "
	cLin := "   					1 - Informar o número do pedido de compra no XML da NF-e na TAG ESPECÍFCA - Favor não "
	fWrite(nHdl,cLin+cEOL)
	cLin := "   						informá-lo em OBSERVAÇÃO."
	fWrite(nHdl,cLin+cEOL)
	cLin := "   					2 - Discriminar a classificação fiscal do produto conforme tabela do IPI, caso não haja "
	fWrite(nHdl,cLin+cEOL)
	cLin := "   					    campo específico na nota fiscal informar uma relação em anexo. "
	fWrite(nHdl,cLin+cEOL)
	cLin := "   					3 - Empresa autorizada a emissão de Nota Fiscal Eletrônica deverá enviar o arquivo XML,"
	fWrite(nHdl,cLin+cEOL)

// Implementado por Marcos Alberto Soprani em 29/03/12 atendendo a implemetação do projeto de importação de arquivo XML
	If cEmpAnt == "01"
		cLin := "   					    para o endereço eletrônico: nf-e.biancogres@biancogres.com.br "
	ElseIf cEmpAnt == "05"
		cLin := "   					    para o endereço eletrônico: nf-e.incesa@incesa.ind.br "
	ElseIf cEmpAnt == "07"
		cLin := "   					    para o endereço eletrônico: nf-e.lmcomercio@biancogres.com.br "
	ElseIf cEmpAnt == "12"
		cLin := "   					    para o endereço eletrônico: nf-e.stgestao@biancogres.com.br "
	ElseIf cEmpAnt == "13"
		cLin := "   					    para o endereço eletrônico: nf-e.mundi@biancogres.com.br "
	Else
		cLin := "   					    para o endereço eletrônico: nf-e.biancogres@biancogres.com.br "
	EndIf

	fWrite(nHdl,cLin+cEOL)

	cLin := "   						4 - Conferir se os dados cadastrais que constam no pedido estão de acordo com emissão da NF.  "
	fWrite(nHdl,cLin+cEOL)

	If it_Serv
		cLin := "   					5 - Caso seja optante pelo SIMPLES NACIONAL, favor encaminhar juntamente com a Nota Fiscal a  "
		fWrite(nHdl,cLin+cEOL)
		cLin := "   					    DECLARAÇÃO DO SIMPLES devidamente assinada. "
		fWrite(nHdl,cLin+cEOL)

		cLin := "   					6 - Notas Fiscais de Serviço (DANFE) não podem ser emitidas entre o dia 25 e 31. Deverão ser  "
		fWrite(nHdl,cLin+cEOL)
		cLin := "   					    entregues fisicamente no almoxarifado, e/ou ter o de acordo do setor de Compras referente "
		fWrite(nHdl,cLin+cEOL)
		cLin := "   					    ao recebimento no e-mail. "
		fWrite(nHdl,cLin+cEOL)

	EndIf

	fClose(nHdl)
	DbSelectArea("ctrabalho")
	DbCloseArea()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CRIA_EMAIL     ºAutor  ³BRUNO MADALENO      º Data ³  04/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ROTINA PARA CRIAR O EMAIL                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function CRIA_EMAIL()
	Local cContato := ""
	Local cMailContato := ""
	Local nCount := 1
	Local cMailNfe := ''
	Local cTelContato := ''
	Local lServico := .F.

	Enter := chr(13) + Chr(10)
	cFORNECEDOR  :=  CA120FORN
	cPEDIDO :=CA120NUM
	cLOJA := CA120LOJ

	cData     := DTOC(DDATABASE)

	CSQL := " SELECT * "
	CSQL += " FROM "+ RetSQLName("SC7")
	CSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	CSQL += "	AND C7_NUM = " + ValToSQL(cPEDIDO)
	CSQL += "	AND C7_FORNECE = " + ValToSQL(cFORNECEDOR)
	CSQL += "	AND C7_RESIDUO = '' "
	CSQL += "	AND C7_ENCER = '' "
	CSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	CSQL += "	AND D_E_L_E_T_ = '' "

	If chkfile("QRY")
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf

	TCQUERY CSQL ALIAS "QRY" NEW

	If !QRY->(EOF())

		cContato := QRY->C7_USER

		cMailContato :=	UPPER(UsrRetMail(cContato))

		PswOrder(1)

		IF (!Empty( cContato ) .and. PswSeek( cContato ))

			cContato	:= PswRet(1)[1][4]
		EndIf

		cTitulo   := 'Pedido de Compra Num: '+(QRY->C7_NUM)

		C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
		C_HTML += '<head> '
		C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		C_HTML += '<title>Untitled Document</title> '
		C_HTML += '<style type="text/css"> '
		C_HTML += '<!-- '
		C_HTML += '.style12 {font-size: 9px; } '
		C_HTML += '.style21 {color: #FFFFFF; font-size: 9px; } '
		C_HTML += '--> '
		C_HTML += '</style> '
		C_HTML += '</head> '
		C_HTML += ' '
		C_HTML += '<body> '

		//CABECALHO
		C_HTML += '<table width="900" border="0" bgcolor="black"> '
		C_HTML += '  <tr> '
		C_HTML += '<font color="white"> '
		C_HTML += '    <th width="450" scope="col"> '+UPPER(Alltrim(SM0->M0_NOMECOM))+' </th> '
		C_HTML += '    <th width="450" scope="col"> PEDIDO DE COMPRA - '+(QRY->C7_NUM)+' </th> '
		C_HTML += '  </tr> '

		C_HTML += '</font>'
		C_HTML += '</tr> '
		C_HTML += '</table> '

		C_HTML += '<table width="900" border="0" bgcolor="#00FA9A"> '
		C_HTML += '<font color="black"> '
		C_HTML += '<tr> '
		C_HTML += '    <th width="450" scope="col"> DADOS DO COMPRADOR </th> '
		C_HTML += '    <th width="450" scope="col"> DADOS DO FORNECEDOR </th> '
		C_HTML += '    <td>&nbsp;</td> '
		C_HTML += '  </tr> '
		C_HTML += '</font>'
		C_HTML += '</table> '

		C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2"> '
		C_HTML += '<font color="black" size="2"> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> Razão Social do Comprador: <b>'+ UPPER(SM0->M0_NOMECOM) +'</b></td> '
		C_HTML += '    <td><div align="left"> Razão Social do Fornecedor: <b>'+ Alltrim(SA2->A2_NOME) +'<b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> CNPJ: <b>' + TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") +'<b></td> '
		If(Alltrim(SA2->A2_TIPO)=='J')
			C_HTML += '    <td><div align="left"> CNPJ: <b>' + TRANSFORM(SA2->A2_CGC,"@R 99.999.999/9999-99") +'<b></td> '
		Else
			C_HTML += '    <td><div align="left"> CPF: <b>' + TRANSFORM(SA2->A2_CGC,"@R 999.999.999-99") +'<b></td> '
		EndIf
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> Endereço: <b>' + SM0->M0_ENDCOB +'</b></td> '
		C_HTML += '    <td><div align="left"> Endereço: <b>' + Alltrim(SA2->A2_END) +'<b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> Município: <b>' + SM0->M0_CIDCOB +'</b></td> '
		C_HTML += '    <td><div align="left"> Município: <b>' + SA2->A2_MUN +'<b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> Estado: <b>' + SM0->M0_ESTCOB +'</b></td> '
		C_HTML += '    <td><div align="left"> Estado: <b>' + SA2->A2_EST +'<b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> CEP: <b>' + TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999") +'</b></td> '
		C_HTML += '    <td><div align="left"> CEP: <b>' + TRANSFORM(SA2->A2_CEP,"@R 99999-999") +'<b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> País: <b>BRASIL</b></td> '
		C_HTML += '    <td><div align="left"> País: <b>' + IIF(Alltrim(SA2->A2_EST)=='EX',"Exterior","BRASIL") +'<b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> Nome do Contato: <b>'+cContato+'</b></td> '
		C_HTML += '    <td><div align="left"> Nome do Contato: <b>' + Alltrim(SA2->A2_CONTATO) +'<b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> E-mail do Contato: <b>'+cMailContato+'</b></td> '
		C_HTML += '    <td><div align="left"> E-mail do Contato: <b>' + UPPER(Alltrim(SA2->A2_EMAIL))+'<b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		//C_HTML += '    <td><div align="left"> Telefone de Contato: <b>'+SM0->M0_TEL+'</b></td> '
//PARA GIOVANNI E CLAUDIA O WF VAI COM O TELEFONE DELES 	
		Do Case
		Case	"CLAUDIA" $ UPPER(cContato)
			cTelContato := "(27) 3421-9113"
		Case	"GEOVANI" $ UPPER(cContato)
			cTelContato := "(27) 3421-9116"
		Otherwise
			cTelContato := SM0->M0_TEL
		EndCase

		C_HTML += '    <td><div align="left"> Telefone de Contato: <b>'+cTelContato+'</b></td> '
		C_HTML += '    <td><div align="left"> Telefone de Contato: <b>' + Alltrim(SA2->A2_TEL)+'<b></td> '
		C_HTML += '  </tr> '

		C_HTML += '</font>'
		C_HTML += '</table> '


		//C_HTML += '<BR><BR><BR><BR>'
		C_HTML += '<BR>'

		//CABECALHO DOS ITENS DO PEDIDO
		C_HTML += '<table width="900" border="0" bgcolor="black"> '
		C_HTML += '  <tr> '
		C_HTML += '<font color="white"> '
		C_HTML += '</font>'
		C_HTML += '</tr> '
		C_HTML += '</table> '

		C_HTML += '<table width="900" border="0" bgcolor="#00FA9A"> '
		C_HTML += '<font color="black"> '
		C_HTML += '<tr> '
		C_HTML += '    <th width="900" scope="col">ITENS DO PEDIDO DE COMPRA </th> '
		C_HTML += '  </tr> '
		C_HTML += '</font>'
		C_HTML += '</table> '
		//CABECALHO COLUNAS - ITENS
		C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2"> '
		C_HTML += '<font color="black" size="2"> '
		C_HTML += '<tr> '
		C_HTML += '    <th width="20" scope="col"> ITEM </span></th> '
		C_HTML += '    <th width="20" scope="col"> TP </span></th> '
		C_HTML += '    <th width="40" scope="col"> CODIGO </span></th> '
		C_HTML += '    <th width="100" scope="col"> DESCRIÇÃO </span></th> '
		C_HTML += '    <th width="20" scope="col"> UN </span></th> '
		C_HTML += '    <th width="30" scope="col"> SAIDA </span></th> '
		//C_HTML += '    <th width="30" scope="col"> CHEGADA </span></th> '
		C_HTML += '    <th width="20" scope="col"> IMP </span></th> '
		C_HTML += '    <th width="30" scope="col"> QUANTIDADE </span></th> '
		C_HTML += '    <th width="40" scope="col"> PREÇO </span></th> '
		C_HTML += '    <th width="40" scope="col"> IPI </span></th> '
		C_HTML += '    <th width="50" scope="col"> TOTAL </span></th> '
		C_HTML += '    <th width="50" scope="col"> S.C </span></th> '
		C_HTML += '    <th width="120" scope="col"> MOEDA </span></th> '
		C_HTML += '    <th width="150" scope="col"> OBSERVAÇÃO </span></th> '
		C_HTML += '  </tr> '


		TOTAL_MERC 	:= 0
		TOTAL_IPI 	:= 0
		TOTAL_FRETE := 0
		TOTAL_DESC 	:= 0
		it_Serv := .F.
		//ITENS
		WHILE !QRY->(EOF())

			C_HTML += '  <tr>
			C_HTML += '    <td class="style12">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> '
			C_HTML += '    <td class="style12">'+ POSICIONE("SB1",1,XFILIAL("SB1")+QRY->C7_PRODUTO,"B1_TIPO") +'</td> '
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->C7_PRODUTO) +'</td> '
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->C7_DESCRI) +'</td> '
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->C7_UM) +'</td> '
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->C7_DATPRF,7,2)+"/"+SUBSTR(QRY->C7_DATPRF,5,2)+"/"+SUBSTR(QRY->C7_DATPRF,1,4) +'</td> '
			//C_HTML += '    <td class="style12">'+ SUBSTR(QRY->C7_YDATCHE,7,2)+"/"+SUBSTR(QRY->C7_YDATCHE,5,2)+"/"+SUBSTR(QRY->C7_YDATCHE,1,4) +'</td> '

			IMPOSTOS := IIf(QRY->C7_YICMS = "S","M","") + IIf(QRY->C7_YPIS = "S","P","")
			IMPOSTOS += IIf(QRY->C7_YCOF = "S","M","C") + IIf(QRY->C7_YIPI = "S","I","")

			C_HTML += '    <td class="style12">'+ Alltrim(IMPOSTOS) +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->C7_QUANT	,"@E 999,999,999.99") +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->C7_PRECO	,"@E 999,999,999.9999") +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->C7_IPI	,"@E 999,999,999.99") +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->C7_TOTAL	,"@E 999,999,999.99") +'</td> '
			C_HTML += '    <td class="style12">'+ (QRY->C7_NUMSC) +'</td> '
			C_HTML += '    <td class="style12">'+Alltrim(GetMv("MV_MOEDA"+Alltrim(Str(QRY->C7_MOEDA))))+'</td> '
			C_HTML += '    <td class="style12">'+ ALLTRIM(QRY->C7_OBS) +'</td> '

			SCONDPG 	:= Posicione("SE4",1,xFilial("SE4")+QRY->C7_COND,"E4_DESCRI")
			TOTAL_MERC 	+= QRY->C7_TOTAL
			TOTAL_IPI 	+= round((( QRY->C7_PRECO/100)* QRY->C7_IPI) * QRY->C7_QUANT,2)
			TOTAL_FRETE += QRY->C7_VALFRE
			TOTAL_DESC 	+= QRY->C7_VLDESC
			IIF(EMPTY(COBS),COBS := QRY->C7_VLDESC,"")

			If Substr(QRY->C7_PRODUTO,1,3) == "306"
				it_Serv := .T.
			EndIf

			QRY->(DBSKIP())
			nCount ++
		EndDo

		C_HTML += '	<tr> '
		C_HTML += '</table> '

		NTOTALGERAL := (TOTAL_MERC+TOTAL_IPI+TOTAL_FRETE) - TOTAL_DESC

//RODAPÉ                       
		C_HTML += '<BR>'
		C_HTML += '<table width="900" border="0" bgcolor="black"> '
		C_HTML += '  <tr> '
		C_HTML += '<font color="white"> '

		C_HTML += '</font>'
		C_HTML += '</tr> '
		C_HTML += '</table> '

		C_HTML += '<table width="900" border="0" bgcolor="#00FA9A"> '
		C_HTML += '<font color="black"> '
		C_HTML += '<tr> '
		C_HTML += '    <th width="300" scope="col"> TOTAIS </th> '
		C_HTML += '    <th width="50" scope="col">&nbsp; </th> '
		C_HTML += '    <th width="550" scope="col"> DADOS DA TRANSPORTADORA </th> '
		C_HTML += '    <td>&nbsp;</td> '
		C_HTML += '  </tr> '
		C_HTML += '</font>'
		C_HTML += '</table> '


		C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2"> '
		C_HTML += '<font color="black" size="2"> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> TOTAL DAS MERCADORIAS: </td> '
		C_HTML += '    <td><div align="right"> <b>'+Transform(TOTAL_MERC,"@E 999,999,999.99") +'</b></td> '
		C_HTML += '    <td><div align="left"> TRANSPORTADORA: <b>'+ Alltrim(sTRANSPORTADORA) +'</b></td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> VALOR IPI: </td> '
		C_HTML += '    <td><div align="right"> <b>' + Transform(TOTAL_IPI,"@E 999,999,999.99") +'</b></td> '
		//C_HTML += '    <td><div align="left"> OBSERVAÇÕES:</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> VALOR FRETE: </td> '
		C_HTML += '    <td><div align="right"> <b>'+Transform(TOTAL_FRETE,"@E 999,999,999.99") +'</b></td> '
		//C_HTML += '    <td><div align="left"> 1. Os pagamentos referentes a esse pedido de compras somente serão feitos </td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> DESCONTO: </td> '
		C_HTML += '    <td><div align="right"> <b>'+Transform(TOTAL_DESC,"@E 999,999,999.99") +'</b></td> '
		//C_HTML += '    <td><div align="left">  &nbsp; preferencialmente através de emissao de boletos bancários. </td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> TOTAL GERAL: </td> '
		C_HTML += '    <td><div align="right"> <b>'+Transform(NTOTALGERAL,"@E 999,999,999.99") +'</b></td> '
		//C_HTML += '    <td><div align="left"> 2. Nao será permitido o desconto de títulos com bancos, empresas de factoring  </td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> COND. PAGAMENTO: </td> '
		C_HTML += '    <td><div align="right"> <b>'+Alltrim(SCONDPG) +'</b></td> '
		//C_HTML += '    <td><div align="left">  &nbsp; e/ou repasse de direitos a favor de terceiros.  </td> '
		C_HTML += '  </tr> '

		C_HTML += '</font>'
		C_HTML += '</table> '

//INFORMACOES OBRIGATORIAS	
		C_HTML += '<br> '

		C_HTML += '<BR>'
		C_HTML += '<table width="900" border="0" bgcolor="black"> '
		C_HTML += '  <tr> '
		C_HTML += '<font color="white"> '

		C_HTML += '</font>'
		C_HTML += '</tr> '
		C_HTML += '</table> '

		C_HTML += '<table width="900" border="0" bgcolor="#00FA9A"> '
		C_HTML += '<font color="black"> '
		C_HTML += '<tr> '
		C_HTML += '    <th width="900" scope="col"> INFORMAÇÃO OBRIGATÓRIA:  </th> '
		C_HTML += '    <td>&nbsp;</td> '
		C_HTML += '  </tr> '
		C_HTML += '</font>'
		C_HTML += '</table> '

		C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2"> '
		C_HTML += '<font color="black" size="2"> '
		C_HTML += '<tr> '
		//C_HTML += '    <td><div align="left"> 1 - Informar na nota fiscal o número deste pedido de compra. </td> '
		//C_HTML += '    <td><div align="left"> 1 - Informar o número do pedido de compra no XML da NF-e na TAG ESPECÍFCA - Favor não informá-lo em OBSERVAÇÃO. </td> '
		C_HTML += '    <td><div align="left"> 1 - Informar o número do pedido de compra no XML da NF-e na TAG ESPECÍFCA, bem como no campo de OBSERVAÇÃO do DANFE. </td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 2 - Discriminar a classificação fiscal do produto conforme tabela do IPI, caso não haja campo específico na nota fiscal informar uma relação em anexo.</td> '
		C_HTML += '  </tr> '

		If cEmpAnt == "01"
			cMailNfe := 'nf-e.biancogres@biancogres.com.br'
		ElseIf cEmpAnt == "05"
			cMailNfe := 'nf-e.incesa@incesa.ind.br '
		ElseIf cEmpAnt == "07"
			cMailNfe := 'nf-e.lmcomercio@biancogres.com.br'
		ElseIf cEmpAnt == "12"
			cMailNfe := 'nf-e.stgestao@biancogres.com.br'
		ElseIf cEmpAnt == "13"
			cMailNfe := 'nf-e.mundi@biancogres.com.br'
		ElseIf cEmpAnt == "14"
			cMailNfe := 'nf-e.vinilico@biancogres.com.br'
		Else
			cMailNfe := 'nf-e.biancogres@biancogres.com.br'
		EndIf

		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 3 - Empresa autorizada a emissão de Nota Fiscal Eletrônica deverá enviar o arquivo XML, para o endereço eletrônico: '+cMailNfe + ' </td> '
		C_HTML += '  </tr> '

		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 4 - Conferir se os dados cadastrais que constam no pedido estão de acordo com emissão da NF.  </td> '
		C_HTML += '  </tr> '

		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 5 - Os pagamentos referentes a esse pedido de compras somente serão feitos através de emissão de boletos bancários registrados.  </td> '
		C_HTML += '  </tr> '

		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 6 - Não será permitido o desconto de títulos com bancos, empresas de factoring e/ou repasse de direitos a favor de terceiros. </td> '
		C_HTML += '  </tr> '

		If it_Serv
			C_HTML += '<tr> '
			C_HTML += '    <td><div align="left"> 7 - Caso seja optante pelo SIMPLES NACIONAL, favor encaminhar juntamente com a Nota Fiscal a DECLARAÇÃO DO SIMPLES devidamente assinada.</td> '
			C_HTML += '  </tr> '

			C_HTML += '<tr> '
			C_HTML += '    <td><div align="left"> 8 - Notas Fiscais de Serviço não podem ser emitidas entre o dia 25 e 31.</td> '
			C_HTML += '  </tr> '

			C_HTML += '<tr> '
			C_HTML += '    <td><div align="left"> 9 - Somenete serão aceitas as NFs(DANFE) entregues em mãos ao Setor de Compras.</td> '
			C_HTML += '  </tr> '

		EndIf

		C_HTML += '</font>'
		C_HTML += '</table> '

		C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '
		C_HTML += '<p>&nbsp;	</p> '
		C_HTML += '</body> '
		C_HTML += '</html> '

		ENV_EMAIL(cData,cTitulo,C_HTML)
		//ENV_EMAIL(cData,cTitulo,cMensagem)

	EndIf

	QRY->(DbCloseArea())

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ENV_EMAIL      ºAutor  ³BRUNO MADALENO      º Data ³  04/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ROTINA PARA ENVIAR O EMAIL                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function ENV_EMAIL(cData,cTitulo,cMensagem)

	Local lOk

//cAnexos		:= "\P10\relato\pc\"+cFORNECEDOR+"_pc.txt"                       

	lOk := U_BIAEnvMail(,EMAIL,cTitulo,cMensagem,'',"\P10\relato\pc\"+cFORNECEDOR+"_pc.txt")

	If lOk
		CSTATUS := "OK"
		MsgBox("EMAIL ENVIADO COM SUCESSO","Alerta","INFO")
	Else
		CSTATUS := "N"
		MsgBox("ERRO AO ENVIAR O EMAIL","Alerta","STOP")
	Endif

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ENVIA_TRANSP   ºAutor  ³BRUNO MADALENO      º Data ³  22/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ENVIA O EMAIL PARA AS TRANSPORTADORAS                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION ENVIA_TRANSP()
	PRIVATE CHTML := ""
	PRIVATE TOT_PEDCOMPRA := 0

	Enter := chr(13) + Chr(10)

	CSQL := " SELECT C7_NUM, C7_PRODUTO, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL, C7_QUJE, C7_DATPRF, C7_YDATCHE, C7_EMISSAO, C7_TIPO, "
	CSQL += " C7_UM, C7_TES, C7_YICMS, C7_YPIS, C7_YCOF, C7_YIPI, C7_IPI, C7_NUMSC, C7_COND, C7_VALFRE, C7_VLDESC, C7_OBS "
	CSQL += " FROM "+ RetSQLName("SC7")
	CSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	CSQL += "	AND C7_NUM = " + ValToSQL(cPEDIDO)
	CSQL += "	AND C7_FORNECE = " + ValToSQL(cFORNECEDOR)
	CSQL += "	AND C7_RESIDUO = '' "
	CSQL += "	AND C7_ENCER = '' "
	CSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	CSQL += "	AND D_E_L_E_T_ = '' "

	TCQUERY CSQL ALIAS "ctrabalho" NEW
	dbSelectArea("ctrabalho")
	dbGotop()

	IF ! ctrabalho->(EOF())

		IF !PADR(POSICIONE("SB1",1,XFILIAL("SB1")+ctrabalho->C7_PRODUTO,"B1_GRUPO"),3) $ "101/102"
			RETURN
		END IF

		CHTML := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		CHTML += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
		CHTML += ' <head> '
		CHTML += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		CHTML += ' <title>Untitled Document</title> '
		CHTML += ' <style type="text/css"> '
		CHTML += ' <!-- '
		CHTML += ' .style12 {font-size: 9px; } '
		CHTML += ' .style18 {font-size: 10} '
		CHTML += ' .style21 {color: #FFFFFF; font-size: 9px; } '
		CHTML += ' .style22 { '
		CHTML += ' 	font-size: 10pt; '
		CHTML += ' 	font-weight: bold; '
		CHTML += ' } '
		CHTML += ' .style35 {font-size: 10pt; } '
		CHTML += ' .style36 {font-size: 9pt; } '
		CHTML += ' .style39 {font-size: 12pt; } '
		CHTML += ' .style41 { '
		CHTML += ' 	font-size: 12px; '
		CHTML += ' 	font-weight: bold; '
		CHTML += ' } '
		CHTML += ' .style42 {font-size: 12px; } '
		CHTML += '  '
		CHTML += ' --> '
		CHTML += ' </style> '
		CHTML += ' </head> '
		CHTML += '  '
		CHTML += ' <body> '
		CHTML += ' <table width="956" border="1"> '
		CHTML += '   <tr> '
		CHTML += '     <th width="751" rowspan="3" scope="col">ROMANEIOS REALIZADOS NO DIA </th> '
		CHTML += '     <td width="189" class="style12"><div align="right"> DATA EMISSÃO: '+ dtoC(DDATABASE) +' </div></td> '
		CHTML += '   </tr> '
		CHTML += '   <tr> '
		CHTML += '     <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+SUBS(TIME(),1,8)+' </div></td> '
		CHTML += '   </tr> '
		CHTML += '   <tr> '
		DO CASE
		CASE CEMPANT = "01"
			CHTML += '    <td><div align="center" class="style41"> BIANCOGRES CERÂMICA SA </div></td> '
		CASE CEMPANT = "05"
			CHTML += '    <td><div align="center" class="style41"> INCESA CERAMICA LTDA </div></td> '
		CASE CEMPANT = "07"
			CHTML += '    <td><div align="center" class="style41"> LM COMERCIO LTDA </div></td> '
		CASE CEMPANT = "12"
			CHTML += '    <td><div align="center" class="style41"> ST GESTAO DE NEGOCIOS LTDA </div></td> '
		CASE CEMPANT = "13"
			CHTML += '    <td><div align="center" class="style41"> MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA </div></td> '
		ENDCASE

		CHTML += '   </tr> '
		CHTML += ' </table> '
		CHTML += '  '
		CHTML += ' <table width="956" border="1"> '

		CHTML += '   <tr bgcolor="#FFFFFF"> '
		CHTML += '     <th colspan="5" scope="col"><div align="left" class="style42"> TRANSPORTADORA: '+SA4->A4_COD+' - '+ SA4->A4_NOME +' </div></th> '
		CHTML += '   </tr> '

		CHTML += '   <tr bgcolor="#FFFFFF"> '
		CHTML += '     <th colspan="5" scope="col"><div align="left" class="style42">FORNECEDOR: '+SA2->A2_COD+' - '+SA2->A2_NOME+' </div></th> '
		CHTML += '   </tr> '

		CHTML += '   <tr bgcolor="#0066CC"> '
		CHTML += '     <th width="223"	scope="col"><span class="style21"> Produto  </span></th> '
		CHTML += '     <th width="380" scope="col"><span class="style21"> Descrição </span></th> '
		CHTML += '     <th width="132" 	scope="col"><span class="style21"> Quantidade </span></th> '
		CHTML += '     <th width="100" scope="col"><span class="style21"> Data Entrega </span></th> '
		CHTML += '   </tr> '
		CHTML += '    '
		CHTML += '   <tr bgcolor="#FFFFFF"> '
		CHTML += '     <th colspan="5" scope="col"><div align="left" class="style42">Pedido N&ordm; '+cPEDIDO+' </div></th> '
		CHTML += '   </tr> '

		CHTML += '    '
		CHTML += '    '

		TOT_PEDCOMPRA := 0
		DO WHILE ! ctrabalho->(EOF())
			CHTML += '   <tr> '
			CHTML += '     <td class="style12"> '+ctrabalho->C7_PRODUTO+' </td> '
			CHTML += '     <td class="style12"> '+ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+ctrabalho->C7_PRODUTO,"B1_DESC"))+' </td> '
			CHTML += '     <td class="style12"> '+PADR(Transform((ctrabalho->C7_QUANT - ctrabalho->C7_QUJE),    "@E 999,999,999.99"),15)+' </td> '
			CHTML += '     <td class="style12"> '+PADC(ALLTRIM(DTOC(STOD(ctrabalho->C7_DATPRF))),11)+' </td> '
			CHTML += '   </tr> '
			TOT_PEDCOMPRA += (ctrabalho->C7_QUANT - ctrabalho->C7_QUJE)
			ctrabalho->(DBSKIP())
		END DO

		CHTML += '    '
		CHTML += '   <tr bordercolor="#FFFFFF"> '
		CHTML += '     <td colspan="5">&nbsp;</td> '
		CHTML += '   </tr> '
		CHTML += '  '

		CHTML += '	  <tr>
		CHTML += '	    <td colspan="2" class="style18"><span class="style22">Total do Pedido :  </span></td>
		CHTML += '	    <td class="style12"> '+ALLTRIM(STR(TOT_PEDCOMPRA))+' </div></td>
		CHTML += '	 	 <td class="style12">  </div></td>
		CHTML += '	  	 <td class="style12">  </div></td>
		CHTML += '	  </tr>

		CHTML += '  <tr bordercolor="#FFFFFF" class="style18"> '
		CHTML += '    <td colspan="5" class="style36">&nbsp;</td> '
		CHTML += '  </tr> '
		CHTML += '</table> '
		CHTML += 'Esta é uma mensagem automática, favor não responde-la. '
		CHTML += '</body> '
		CHTML += '</html> '

	END IF

	IF ALLTRIM(SA4->A4_EMAIL) = ""
		cRecebe   := "vagner.salles@biancogres.com.br"
		cAssunto	:= "PEDIDOS PARA TRANSPORTADORAS EMAIL NÃO CADASTRADO"
		U_BIAEnvMail(,cRecebe,cAssunto,CHTML)
	ELSE
		cRecebe   := ALLTRIM(SA4->A4_EMAIL)
		cRecebeCC	:= "vagner.salles@biancogres.com.br"
		cAssunto	:= "PEDIDOS PARA TRANSPORTADORAS"
		U_BIAEnvMail(,cRecebe,cAssunto,CHTML,,,,cRecebeCC)
	ENDIF

RETURN


Static Function fPedLib(cNumPed, cCodFor)
	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(C7_NUM) AS COUNT "
	cSQL += " FROM "+ RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += "	AND C7_NUM = " + ValToSQL(cNumPed)
	cSQL += "	AND C7_FORNECE = " + ValToSQL(cCodFor)
	cSQL += "	AND C7_RESIDUO = '' "
	cSQL += "	AND C7_ENCER = '' "
	cSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	cSQL += "	AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If (cQry)->COUNT > 0

		lRet := .T.

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)