#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WFW120P   ³ Autor ³ WLADIMIR I. N. SANTANA³ Data ³ 09/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a inclusao de Pedidos de Compra                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGACOM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function WFW120P

SetPrvt("DDTEMISSAO, CCODFOR, CCOUNT, CQUERY, CQUERY1, CQUERY2, CQUERY3, CQUERY4, CQUERY5, CQUERY6, CQUERY7, CQUERY8, CQUERY9, CWHERE, NERRO, CANOPESQ, CMESPESQ, NMEDIACONC")
SetPrvt("WUSUARIO, ACONCENC, NCONCENC, CMSG, ACONCEITOS, DDTEMISSAO, NTOTREGS")

Private cNumPed         := CA120NUM
Private cEOL            := "CHR(13)+CHR(10)"
Private cCodFor         := ""
Private cPEDIDO         := ""
Private cLojaFor        := ""
PRIVATE EMAIL           := ""
PRIVATE cSQL            := ""
PRIVATE ccFLAG          := "SIM"
PRIVATE cRemet          := ""
Private cOBS            := ""
PRIVATE nTOTMERC        := 0
PRIVATE nTOTIPI         := 0
PRIVATE nTOTFRETE       := 0
PRIVATE aTOTDESC        := 0
PRIVATE nTotGer         := 0
PRIVATE SCONDPG         := ""
Private nARQUIVO        := ""
Private nLINHA_LOG      := ""
Private sTRANSP         := SPACE(6)
Private sTRA1           := SPACE(50)
Private wwUsuario1      := ""
PRIVATE wEMAIL          := ""
PRIVATE wwUsuario14     := ""
PRIVATE cLin            := ""
PRIVATE nQuant          := 0
PRIVATE nImp            := 0
Private cData           := DTOC(DDATABASE)
Private cTitulo         := ""
Private cMensagem       := ""
Private lResult         := .F.
Private lPassei         := .F.
Private	cEnvia      	:= ""
Private	cRecebe 	    := ""
Private	cRecebeCC	    := ""
Private	cRecebeCO	    := ""
Private	cAssunto    	:= ""
Private	cAnexos	     	:= ""
Private P               := 1

	If cEmpAnt $ ("01_05_06_07_12_13_14_16")
	
		dDtEmissao := dA120Emis
		cPedido := cA120Num
		cCodFor := AllTrim(cA120Forn)
		cLojaFor := AllTrim(cA120Loj)
		nErro := 0
			
		//Executa rotina para acerto de aprovador, na alteracao do Pedido
		AcertaAprovador()
		
		EMAIL_APRO()
	
		If ChkFile("cTrab")
		
			DbSelectAre("cTrab")
		
			cTrab->(DbCloseArea())
		
		EndIf
		
	EndIf
	
Return()


Static Function AcertaAprovador()
Local Enter1  := CHR(13)+CHR(10)
	DbSelectArea("SCR")
	DbSetOrder(1)
	If DbSeek(xFilial("SCR")+"PC"+cNumPed)
		While !SCR->(Eof()) .And. SCR->CR_FILIAL == cFilAnt .And. AllTrim(SCR->CR_NUM) == AllTrim(cNumPed)
			While !Reclock("SCR",.F.);EndDo
			SCR->CR_YDTINCL := dDataBase
			MsUnlock()
					
			SCR->(DbSkip())
		EndDo
	EndIf
	
	cQuery0 := "UPDATE " + RetSqlName("SC7") + Enter1
	cQuery0 += "SET C7_YAPLIC = C1_YAPLIC" + Enter1
	cQuery0 += "	, C7_YTAG = C1_YTAG" + Enter1
	cQuery0 += "	, C7_YMELHOR = C1_YMELHOR" + Enter1
	
	cQuery0 += "	, C7_YCONTR = C1_YCONTR" + Enter1
	cQuery0 += "	, C7_CLVL = C1_CLVL" + Enter1
	cQuery0 += "	, C7_ITEMCTA = C1_ITEMCTA" + Enter1
	cQuery0 += "	, C7_YSUBITE = C1_YSUBITE" + Enter1
		
	cQuery0 += "	, C7_YMAT = C1_YMAT" + Enter1
	cQuery0 += "	, C7_YSOLEMP = C1_YSOLEMP" + Enter1
	cQuery0 += "	, C7_YSI = C1_YSI" + Enter1
	cQuery0 += "	, C7_YOBS = C1_YOBS" + Enter1
	cQuery0 += "	, C7_YTOTEST = C1_YTOTEST" + Enter1
	cQuery0 += "	, C7_YDRIVER = C1_YDRIVER" + Enter1
	//cQuery0 += "	, C7_LOCAL = (CASE C1_LOCAL WHEN '' THEN C7_LOCAL ELSE C1_LOCAL END)" + Enter1
	cQuery0 += "FROM " + RetSqlName("SC7") + " SC7, " + RetSqlName("SC1") + " SC1" + Enter1
	cQuery0 += "WHERE SC7.C7_NUM = '" + cNumPed + "'" + Enter1
	cQuery0 += "	AND SC7.C7_NUMSC = SC1.C1_NUM" + Enter1	
	cQuery0 += "	AND SC7.C7_ITEMSC = SC1.C1_ITEM" + Enter1	
	cQuery0 += "	AND SC1.D_E_L_E_T_ = ''" + Enter1
	cQuery0 += "	AND SC7.D_E_L_E_T_ = ''" + Enter1
	TCSQLExec(cQuery0)
	
	// Tiago Rossini Coradini - 19/07/2017 - Aprovação automatica de pedidos de compra
	U_BIAF081(cNumPed)

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	EMAIL_APRO  ³ Autor ³HARLEY DIAS KOEHLER   ³ Data ³ 14/11/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ ENVIA PEDIDO DE COMPRA POR EMAIL PARA APROVACAO                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EMAIL_APRO()

psworder(1)
pswseek(__cUserID,.t.)
wUsuario := pswret(1)[1][1]
cRemet   := ALLTRIM(pswret(1)[1][14])

//VERIFICANDO SE O PEDIDO ESTA LIBERADO, BUSCA APROVADORES
cQuery7 := 	""
cQuery7 +=	"SELECT CR_STATUS, CR_USER, AK_APROSUP "
cQuery7 +=	"FROM " + RetSqlName("SCR") + " SCR "
cQuery7 +=  "	LEFT JOIN " + RetSqlName("SAK") + " SAK ON AK_COD = CR_APROV AND AK_FILIAL = CR_FILIAL AND SAK.D_E_L_E_T_ = '' "
cQuery7 +=	"WHERE SCR.D_E_L_E_T_ = '' AND "
cQuery7 +=	"	SCR.CR_NUM = '" + CA120NUM + "' AND "
cQuery7 +=	"	SCR.CR_FILIAL = '" + xFilial("SCR") + "' "
If chkfile("_SCR")
	dbSelectArea("_SCR")
	dbCloseArea()
EndIf
TCQuery cQuery7 Alias "_SCR" New

IF !Empty(_SCR->CR_USER)
	psworder(1)
	If pswseek(_SCR->CR_USER,.t.)
		wUsuario  := pswret(1)[1][2] //NOME DO USUARIO
		wEmail    :=  ALLTRIM(pswret(1)[1][14])
		
		//(19/05/15 -> ***B day*** - Thiago) - Enviar email para o aprovador temporário.
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbGotop()
		
		If !Empty(_SCR->AK_APROSUP)		
			cAprovTemp := AllTrim(Posicione("SAK",1,xFilial("SAK")+_SCR->AK_APROSUP,"AK_USER"))
				
			If !Empty(cAprovTemp)
				wEmail +=  '; '+Alltrim(UsrRetMail(cAprovTemp))
			EndIf
		EndIf
		
	Else
		wUsuario  := "Administrador"
		wEmail    := "wanisay.william@biancogres.com.br"
		lPassei   := .T.
	EndIf
ELSE
	wUsuario  := "Administrador"
	wEmail    := "wanisay.william@biancogres.com.br"
	lPassei   := .T.
ENDIF

//VERIFICANDO SE O USUARIO PERTENCE AO GRUPO DE COMPRADORES
cQuery8 := 	""
cQuery8 +=	"SELECT COUNT(Y1_USER) AS QUANT FROM SY1010 "
cQuery8 +=	"WHERE 	Y1_USER = '" + wUsuario + "' AND "
cQuery8 +=	"		Y1_FILIAL = '" + xFilial("SY1") + "' AND "
cQuery8 +=	"		D_E_L_E_T_ = '' "
If chkfile("_SY1")
	dbSelectArea("_SY1")
	dbCloseArea()
EndIf
TCQuery cQuery8 Alias "_SY1" New

sTRANSP := "999999"
IF alltrim(sTRANSP) <> ""
	sTRANSP := Posicione("SA4",1,xFilial("SA4")+sTRANSP,"A4_NOME")
	aARQUIVO_PC()
	IF EMPTY(EMAIL)
		MsgBox("EMAIL NÃO CADASTRADO","Alerta","STOP")
		RETURN
	ENDIF
	
	IF ccFLAG = "SIM"
		
		CRIA_EMAIL()
		
		// Tiago Rossini Coradini - 20/12/2016 - OS: 4533-16 - Claudia Carvalho
		If !IsInCallsTack("U_BIAFG030")
			MsgInfo("NÚMERO DO PEDIDO DE COMPRA IMPLANTADO: " + CA120NUM)
		EndIf		
		// Associa o transportador ao pedido de compra
		U_BIAF090(CA120NUM)

		// Avalia se envia e-mail automatico
		U_BIAF091(CA120NUM, "A")
						
	ELSE
		If !IsInCallsTack("U_BIAFG030")
			MsgBox("EMAIL NÃO ENVIADO. PEDIDO PARCIALMENTE ATENDIDO","Alerta","STOP")
		EndIf
	ENDIF
	
ELSE
	If !IsInCallsTack("U_BIAFG030")
		MsgBox("EMAIL NÃO ENVIADO","Alerta","STOP")
	EndIf
ENDIF

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
STATIC FUNCTION aARQUIVO_PC()
Local J        := 1
Local I        := 1
Local Enter2   := CHR(13)+CHR(10)
Local cArqTxt  := "\P10\relato\PC_APROVADORES\" 	+ cCodFor + "_PC.TXT"
Local nHdl_121 := fCreate(cArqTxt)

IF EMPTY(cEOL)
	cEOL := CHR(13)+CHR(10)
ELSE
	cEOL := TRIM(cEOL)
	cEOL := &cEOL
ENDIF

CSQL := "SELECT * FROM " + RETSQLNAME("SC7") + Enter2
CSQL += "WHERE 	C7_NUM = '" + cPEDIDO + "' AND  " + Enter2
CSQL += "		C7_FORNECE = '" + cCodFor + "' AND " + Enter2
CSQL += "		C7_FILIAL = '" + xFilial("SC7") + "' AND " + Enter2
CSQL += "		D_E_L_E_T_ = '' " + Enter2

TCQUERY CSQL ALIAS "ctrab" NEW
dbSelectArea("ctrab")
dbGotop()

//IF !ctrab->(EOF())
//	nHdl_121 := fCreate(cArqTxt)
//ENDIF

IF ctrab->C7_QUJE = 0
	ccFLAG = "SIM"
ELSE
	ccFLAG = "NAO"
ENDIF

WHILE !EOF()
	
	dbSelectArea("SA2")
	dbsetOrder(1)
	dbseek(xFilial("SA2")+cCodFor+cLojaFor)
	dbSelectArea("ctrab")
	
	//psworder(1)
	//pswseek(_SCR->CR_USER,.t.)
	//wUsuario  := pswret(1)[1][2] //NOME DO USUARIO
	//wEmail    :=  ALLTRIM(pswret(1)[1][14])
	
	//VERIFICANDO USUARIO QUE INCLUIU O PEDIDO
	cQuery9 := ""
	cQuery9 += "SELECT C7_USER, C7_NUM " + Enter2
	cQuery9 += "FROM " + RetSqlName("SC7") + Enter2 
	cQuery9 += "WHERE D_E_L_E_T_ 	= '' AND " + Enter2
	cQuery9 += "	C7_FILIAL = '" + xFilial("SC7") + "' AND " + Enter2
	cQuery9 += "	C7_NUM = '" + CA120NUM + "' "
	IF chkfile("_SC7")
		dbSelectArea("_SC7")
		dbCloseArea()
	ENDIF
	TCQuery cQuery9 Alias "_SC7" New
	
	IF !Empty(_SC7->C7_USER)
		psworder(1)
		pswseek(_SC7->C7_USER,.t.)
		wwUsuario   := pswret(1)[1][3]  //SENHA DO USUARIO
		wwUsuario1  := pswret(1)[1][4]  //NOME DO USUARIO
		wwUsuario14 := pswret(1)[1][14] //EMAIL DO USUARIO
		EMAIL       := wEmail
	ELSE
		lPassei     := .T.
		wwUsuario   := ''
		wwUsuario1  := 'Administrador'
		wwUsuario14 := 'wanisay.william@biancogres.com.br'
	ENDIF
	
	//************* IMPRIMINDO O CABECALHO   *****************
	cLin := PADL("EMISSAO: " + ALLTRIM(DTOC(STOD(ctrab->C7_EMISSAO))),126)
	fWrite(nHdl_121,cLin+cEOL)
	
	cLin := REPLICATE(" ",56) + "####################"
	fWrite(nHdl_121,cLin+cEOL)
	
	cLin := REPLICATE(" ",56) + "# PEDIDO DE COMPRA #" + REPLICATE(" ",10) + PADL(ctrab->C7_NUM,7)
	fWrite(nHdl_121,cLin+cEOL)
	
	cLin := REPLICATE(" ",56) + "####################"
	fWrite(nHdl_121,cLin+cEOL)
	
	cLin := "  " + REPLICATE("_",61) + "     " + REPLICATE("_",61)
	fWrite(nHdl_121,cLin+cEOL)
	
	cLin := " |" + REPLICATE(" ",60) + " |   |" + REPLICATE(" ",60) + " |"
	fWrite(nHdl_121,cLin+cEOL)
	
	If cempant = "01"
		cLin := PADR(" |BIANCOGRÊS CERÂMICA S/A ",62)									+ PADR(" |   |FORN..:" + SA2->A2_COD + " " 	+ SA2->A2_LOJA + " " + SA2->A2_NOME + " ",66) + " |"
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR(" |Av.Talma Rodrigues Ribeiro, 1145 Civit II ",62)					+ PADR(" |   |END...:" + SA2->A2_END,66)		+ " |"
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR(" |Cep: 29.168-080, Serra/ES ",62)									+ PADR(" |   |CIDADE:" + SA2->A2_MUN,30) 		+ PADR("UF..:" + SA2->A2_EST,18) + PADR("CEP:" + SA2->A2_CEP,18)+ " |"
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR(" |Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) 			+ PADR(" |   |C.G.C.:" + SA2->A2_CGC,30) 		+ PADR("I.E.:" + SA2->A2_INSCR,36) + " |"
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR(" |Fax: ",62)														+ PADR(" |   |TEL...:" + SA2->A2_TEL,30) 		+ PADR("FAX.:" + SA2->A2_FAX,36) + " |" //OS 1760-16 Cláudia Carvalho - Luana Marin Ribeiro
		//cLin := PADR(" |Fax: (27)3421-9040 ",62)										+ PADR(" |   |TEL...:" + SA2->A2_TEL,30) 		+ PADR("FAX.:" + SA2->A2_FAX,36) + " |"
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR(" |CNPJ: 02.077.546/0001-76 IE: 081936443 ",62)					+ PADR(" |   |CONT..:" + SA2->A2_CONTATO,66) 	+ " |"
		fWrite(nHdl_121,cLin+cEOL)
	ElseIf cempant = "05"
		cLin := PADR("INCESA REVESTIMENTO CERAMICO LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Rua 3, 648, Civit II                     ",62)  		+ PADR("END...:" + SA2->A2_END,50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Cep: 29.168-079, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Fax: ",62)										+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8) //OS 1760-16 Cláudia Carvalho - Luana Marin Ribeiro
		//cLin := PADR("Fax: (27)3421-9040 ",62)						+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("CNPJ: 04.917.232/0001-60 IE: 082.140.12-0 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
		fWrite(nHdl_121,cLin+cEOL)
	ElseIf cempant = "06"
		cLin := PADR("JK SERVIÇOS E ASSESSORIA LTDA. ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Rua Holdercim, 165, Lote 03 Quadra VI, Civit II ",62)  		+ PADR("END...:" + SA2->A2_END,50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Cep: 29.168-066, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Tel: (27)3421-9000 ",62) + PADR("C.G.C.:" 		+ SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Fax: ",62)										+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8) //OS 1760-16 Cláudia Carvalho - Luana Marin Ribeiro
		//cLin := PADR("Fax: (27)3421-9040 ",62)						+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("CNPJ: 04.548.187/0001-13 IE: 082.459.50-9 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
		fWrite(nHdl_121,cLin+cEOL)
	ElseIf cempant = "12"
		cLin := PADR("ST GESTAO DE NEGOCIOS LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Rua 2, 246, Civit II                     ",62)  		+ PADR("END...:" + SA2->A2_END,50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Cep: 29.168-081, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Fax: ",62)										+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8) //OS 1760-16 Cláudia Carvalho - Luana Marin Ribeiro
		//cLin := PADR("Fax: (27)3421-9040 ",62)						+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("CNPJ: 13.231.737/0001-67                  ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
		fWrite(nHdl_121,cLin+cEOL)
	ElseIf cempant == "13"
		cLin := PADR("MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Rua Holdercim, 165, Lote 03 Quadra VI, Civit II ",62)  		+ PADR("END...:" + SA2->A2_END,50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Cep: 29.168-066, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Tel: (27)3421-9122 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Fax: ",62)										+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8) //OS 1760-16 Cláudia Carvalho - Luana Marin Ribeiro
		//cLin := PADR("Fax: (27)3421-9040 ",62)						+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("CNPJ: 14.086.214/0001-37               ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
		fWrite(nHdl_121,cLin+cEOL)
	ElseIf cempant == "14"
		cLin := PADR("VITCER RETIFICA E COMPLEMENTOS CERAMICOS ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("R DOIS, SETOR 02, QD 06, LT 07, CIVIT II ",62)	+ PADR("END...:" + SA2->A2_END,50)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("Cep: 29.168-081, Serra/ES ",62)					+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
		fWrite(nHdl_121,cLin+cEOL)
		//cLin := PADR("Tel: (27)3218-6517 ",62) + PADR("C.G.C.:" 		+ SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
		cLin := PADR("Tel: (27)3421-9000 ",62) + PADR("C.G.C.:" 		+ SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
		fWrite(nHdl_121,cLin+cEOL)
		//cLin := PADR("Fax: (27)3218-6517 ",62)							+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
		cLin := PADR("Fax: (27)3421-9000 ",62)							+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
		fWrite(nHdl_121,cLin+cEOL)
		cLin := PADR("CNPJ: 08.930.868/0001-00               ",62)		+ PADR("CONT..:" + SA2->A2_CONTATO,20)
		fWrite(nHdl_121,cLin+cEOL)
	ELSE
		MSGALERT("EMPRESA NÃO CADASTRADA. FAVOR VERIFICAR COM A TI!!!!")
	END IF
	
	cLin := " |" + REPLICATE("_",61) + "|   |" + REPLICATE("_",61) + "|"
	fWrite(nHdl_121,cLin+cEOL)
	cLin := REPLICATE(" ",120)
	fWrite(nHdl_121,cLin+cEOL)
	
	cLin := " " + REPLICATE("-",129)
	fWrite(nHdl_121,cLin+cEOL)
	
	cLin := PADC(" TP",4)
	cLin += PADC("COD",9)
	cLin += PADR("DESCRICAO",34)
	cLin += PADC("UN",5)
	cLin += PADC("DT.SAI.",11)
	cLin += PADC("DT.CHE.",11) /// ALTERADO POR BRUNO
	cLin += PADC("TES",4)
	cLin += PADC("IMP.",4)
	cLin += PADL("QTD",15)
	cLin += PADL("P.UNIT",15)
	cLin += PADC("IPI",6)
	cLin += PADL("VAL.TOT",15)
	cLin += PADC("S.C",6)
	fWrite(nHdl_121,cLin+cEOL)
	
	cLin := " " + REPLICATE("-",129)
	fWrite(nHdl_121,cLin+cEOL)
	
	DbSelectArea("ctrab")
	DO WHILE !EOF() //.and. J<=60
		J ++
		I := 1
		nQUANT := 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLin := " " + PADR(POSICIONE("SB1",1,XFILIAL("SB1")+ctrab->C7_PRODUTO,"B1_TIPO"),3) //PADC(ctrab->C7_TIPO,3)
		cLin += PADC(ctrab->C7_PRODUTO,9)
		cLin += PADR(ctrab->C7_DESCRI,34)
		cLin += PADC(ctrab->C7_UM,5)
		cLin += PADC(ALLTRIM(DTOC(STOD(ctrab->C7_DATPRF))),11)
		cLin += PADC(ALLTRIM(DTOC(STOD(ctrab->C7_YDATCHE))),11) /// ALTERADO POR BRUNO
		cLin += PADC(ctrab->C7_TES,4)
		nIMP := IIf(ctrab->C7_YICMS = "S","M","") + IIf(ctrab->C7_YPIS = "S","P","")
		nIMP += IIf(ctrab->C7_YCOF = "S","M","C") + IIf(ctrab->C7_YIPI = "S","I","")
		cLin += PADC(nIMP,4)
		cLin += PADR(Transform(ctrab->C7_QUANT,    "@E 999,999,999.99"),15)
		cLin += PADR(Transform(ctrab->C7_PRECO,    "@E 99,999,999.999"),15)
		cLin += PADC(ctrab->C7_IPI,6)
		cLin += PADR(Transform(ctrab->C7_TOTAL,    "@E 999,999,999.99"),15)
		cLin += PADC(ctrab->C7_NUMSC,6)
		fWrite(nHdl_121,cLin+cEOL)
		
		nQUANT := LEN(ALLTRIM(ctrab->C7_DESCRI)) - 34
		I := 35
		DO WHILE nQUANT > 34
			cLin := REPLICATE(" ",13) + SUBSTRING(ALLTRIM(ctrab->C7_DESCRI), I ,34)
			fWrite(nHdl_121,cLin+cEOL)
			I := I + 34
			nQUANT := nQUANT - 34
		END DO
		IF nQUANT <> 0
			cLin := REPLICATE(" ",13) + SUBSTRING(ALLTRIM(ctrab->C7_DESCRI), I ,34)
			fWrite(nHdl_121,cLin+cEOL)
		END IF
		
		SCONDPG 	:= Posicione("SE4",1,xFilial("SE4")+ctrab->C7_COND,"E4_DESCRI")
		nTOTMERC 	+= ctrab->C7_TOTAL
		nTOTIPI 	+= round((( ctrab->C7_PRECO/100)* ctrab->C7_IPI) * ctrab->C7_QUANT,2)
		nTOTFRETE   += ctrab->C7_VALFRE
		aTOTDESC    += ctrab->C7_VLDESC
		IIF(EMPTY(COBS),COBS := ctrab->C7_VLDESC,"")
		DbSelectArea("ctrab")
		DbSkip()
	EndDo
EndDo
nTotGer := (nTOTMERC+nTOTIPI+nTOTFRETE) - aTOTDESC

cLin := " "
fWrite(nHdl_121,cLin+cEOL)
cLin := " "
fWrite(nHdl_121,cLin+cEOL)

cLin := "  " + REPLICATE("_",127)
fWrite(nHdl_121,cLin+cEOL)

cLin := " |" + REPLICATE(" ",38) + REPLICATE(" ",87) + " |"
fWrite(nHdl_121,cLin+cEOL)

cLin := PADR(" |TOTAL DAS MERCADORIAS.: ",25)	+	PADR(Transform(nTOTMERC,    "@E 999,999,999.99"),15)
cLin += PADR(" " ,87)  + " |"
fWrite(nHdl_121,cLin+cEOL)

cLin := PADR(" |VALOR IPI.............: ",25)	+	PADR(Transform(nTOTIPI,    "@E 999,999,999.99"),15)
cLin += PADR(" ",87)  + " |"
fWrite(nHdl_121,cLin+cEOL)

cLin := PADR(" |VALOR FRETE...........: ",25)	+	PADR(Transform(nTOTFRETE,    "@E 999,999,999.99"),15)
cLin += PADR("  ",87)  + " |"
fWrite(nHdl_121,cLin+cEOL)

cLin := PADR(" |DESCONTO..............: ",25)	+	PADR(Transform(aTOTDESC,    "@E 999,999,999.99"),15)
cLin += PADR(" ",87) + " |"
fWrite(nHdl_121,cLin+cEOL)

cLin := PADR(" |TOTAL GERAL...........: ",25)	+	PADR(Transform(nTOTGER,    "@E 999,999,999.99"),15)
cLin += PADR("",87) + " |"
fWrite(nHdl_121,cLin+cEOL)

cLin := PADR(" |COND. PAGAMENTO.......: ",25)	+	PADR(SCONDPG,15)
cLin += PADR(" ",87) + " |"
fWrite(nHdl_121,cLin+cEOL)

cLin := " |" + REPLICATE("_",39) + REPLICATE("_",87) + "|"
fWrite(nHdl_121,cLin+cEOL)

cLin := " "
fWrite(nHdl_121,cLin+cEOL)

fClose(nHdl_121)
DbSelectArea("ctrab")
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

cData     := DTOC(DDATABASE)
cTitulo   := "Pedido de compra "
cMensagem := "		Email enviado automaticamente pelo PROTHEUS (microsiga). " + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)

IF ALTERA
	cMensagem += "Informamos que foi alterado no sistema Microsiga o pedido de compra numero: "+cNumPed+ CHR(13)+CHR(10)
ENDIF

IF INCLUI
	cMensagem += "Informamos que foi incluido no sistema Microsiga o pedido de compra numero: "+cNumPed+ CHR(13)+CHR(10)
ENDIF

cMensagem += "As informações referentes a esse pedido encontra-se no arquivo anexo." + CHR(13)+CHR(10)
cMensagem += "Fineza efetivar aprovação."+CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += "Atenciosamente,"+CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += PADC(wwUsuario1,50)+CHR(13)+CHR(10)
cMensagem += PADC(" Setor de Compras",50)+CHR(13)+CHR(10)
cMensagem += PADC(" Biancogres Ceramica S/A",30)
cMensagem += CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)

ENV_EMAIL(cData,cTitulo,cMensagem)

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

cEnvia    	:= wwUsuario14
cRecebe 	:= EMAIL						// Email do(s) receptor(es)
cRecebeCC	:= ""							// Com Copia
cRecebeCO	:= ""							// Copia Oculta
cAssunto	:= cTitulo						// Assunto do Email
cAnexos		:= "\P10\relato\PC_APROVADORES\"+cCodFor+"_pc.txt"

lOk := U_BIAEnvMail(,cRecebe,cAssunto,cMensagem,,cAnexos)

If !IsInCallsTack("U_BIAFG030")
	IF lOk .AND. !lPassei
		CSTATUS := "OK"
		MsgBox("EMAIL ENVIADO COM SUCESSO PARA O APROVADOR","Alerta","INFO")
	ELSE
		CSTATUS := "N"
		MsgBox("ERRO AO ENVIAR O EMAIL","Alerta","STOP")
	ENDIF
EndIf

RETURN lOk
