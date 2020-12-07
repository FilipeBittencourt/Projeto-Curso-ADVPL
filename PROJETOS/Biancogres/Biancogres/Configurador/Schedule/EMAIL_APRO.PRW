#include "rwMake.ch"
#include "Topconn.ch"
#include "ap5mail.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funcao   ณ 	EMAIL_APRO  ณ Autor ณHARLEY DIAS KOEHLER   ณ Data ณ 14/11/07   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ ENVIA PEDIDO DE COMPRA POR EMAIL PARA APROVACAO                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER Function EMAIL_APRO()
Private cEOL    := "CHR(13)+CHR(10)"
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
PRIVATE aTOTAL_DESC := 0
PRIVATE EMAIL := ""
PRIVATE SCONDPG := ""
PRIVATE wUsuario
Private nARQUIVO := ""
Private nLINHA_LOG := ""
Private sTRANSPORTADORA := SPACE(6)
Private sTRA1 := SPACE(50)
Private cNumPed := CA120NUM
Private wwUsuario1:= ""
PRIVATE wEMAIL := ""
PRIVATE wwUsuario14:=""

psworder(1)
pswseek(__cUserID,.t.)
wUsuario := pswret(1)[1][1]
CREMETENTE := ALLTRIM(pswret(1)[1][14])

//VERIFICANDO SE O PEDIDOESTA LIBERADO
cQuery := 	""
cQuery +=	"SELECT CR_STATUS, CR_USER				"
cQuery +=	"FROM "+RetSqlName("SCR")+" SCR			"
cQuery7 +=  "LEFT JOIN "+RetSqlName("SAK")+" SAK ON AK_COD = CR_APROV AND AK_FILIAL = CR_FILIAL AND SAK.D_E_L_E_T_ = ''  "
cQuery +=	"WHERE SCR.D_E_L_E_T_ 	= '' AND			"
cQuery +=	"      SCR.CR_NUM		= '"+CA120NUM+"' 	"
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

sTRANSPORTADORA:="999999"
IF alltrim(sTRANSPORTADORA) <> ""
	sTRANSPORTADORA := Posicione("SA4",1,xFilial("SA4")+sTRANSPORTADORA,"A4_NOME")
	aARQUIVO_PC()
	IF EMPTY(EMAIL)
		MsgBox("EMAIL NรO CADASTRADO","Alerta","STOP")
		RETURN
	END IF
	IF ccFLAG = "SIM"
		
		CRIA_EMAIL()
	ELSE
		MsgBox("EMAIL NรO ENVIADO. PEDIDO PARCIALMENTE ATENDIDO","Alerta","STOP")
	END IF
else
	MsgBox("EMAIL NรO ENVIADO","Alerta","STOP")
end if

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออออัอออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ ARQUIVO_PC           บAutor  ณBRUNO MADALENO บ Data ณ 04/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออออฯอออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณROTINA PARA GERAR E CRIAR O PEDIDO DE COMPRA                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION aARQUIVO_PC()
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

cArqTxt := "\P10\relato\PC_APROVADORES\" 	+ cFORNECEDOR + "_PC.TXT"

CSQL := "SELECT * FROM "+ RETSQLNAME("SC7")+" " + Enter
CSQL += "WHERE 	C7_NUM = '"+cPEDIDO+"' AND  " + Enter
CSQL += "		C7_FORNECE = '"+cFORNECEDOR+"' AND " + Enter
CSQL += "		D_E_L_E_T_ = '' " + Enter

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


While !EOF()
	
	dbSelectArea("SA2")
	dbsetOrder(1)
	dbseek(xFilial("SA2")+cFORNECEDOR+CLOJA)
	dbSelectArea("ctrabalho")
	
	psworder(1)
	pswseek(_SCR->CR_USER,.t.)
	wUsuario := pswret(1)[1][2] //NOME DO USUARIO
	wEmail :=  ALLTRIM(pswret(1)[1][14])
	
	//(19/05/15 -> ***B day*** - Thiago) - Enviar email para o aprovador temporแrio.
	dbSelectArea("SAK")
	dbSetOrder(1)
	dbGotop()
	
	If !Empty(_SCR->AK_APROSUP)		
		cAprovTemp := AllTrim(Posicione("SAK",1,xFilial("SAK")+_SCR->AK_APROSUP,"AK_USER"))
			
		If !Empty(cAprovTemp)
			wEmail +=  '; '+Alltrim(UsrRetMail(cAprovTemp))
		EndIf
	EndIf

	//VERIFICANDO USUARIO QUE INCLUIU O PEDIDO
	cQuery := 	""
	cQuery +=	"SELECT C7_USER, C7_NUM				"
	cQuery +=	"FROM "+RetSqlName("SC7")+" 			"
	cQuery +=	"WHERE D_E_L_E_T_ 	= '' AND			"
	cQuery +=	"      C7_NUM		= '"+CA120NUM+"' 	"
	If chkfile("_SC7")
		dbSelectArea("_SC7")
		dbCloseArea()
	EndIf
	TCQuery cQuery Alias "_SC7" New
	
	psworder(1)
	pswseek(_SC7->C7_USER,.t.)
	wwUsuario := pswret(1)[1][3] //NOME DO USUARIO
	wwUsuario1 := pswret(1)[1][4]
	wwUsuario14 := pswret(1)[1][14]
	//EMAIL := "ranisses.corona@biancogres.com.br"
	EMAIL := wEmail
	
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
	
	If cempant = "01"
		cLin := PADR(" |BIANCOGRสS CERยMICA S/A ",62)									+ PADR(" |   |FORN..:" + SA2->A2_COD + " " 	+ SA2->A2_LOJA + " " + SA2->A2_NOME + " ",66) + " |"
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR(" |Av.Talma Rodrigues Ribeiro, 1145 Civit II ",62)					+ PADR(" |   |END...:" + SA2->A2_END,66)		+ " |"
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR(" |Cep: 29.168-080, Serra/ES ",62)									+ PADR(" |   |CIDADE:" + SA2->A2_MUN,30) 		+ PADR("UF..:" + SA2->A2_EST,18) + PADR("CEP:" + SA2->A2_CEP,18)+ " |"
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR(" |Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) 			+ PADR(" |   |C.G.C.:" + SA2->A2_CGC,30) 		+ PADR("I.E.:" + SA2->A2_INSCR,36) + " |"
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR(" |Fax: ",62)														+ PADR(" |   |TEL...:" + SA2->A2_TEL,30) 		+ PADR("FAX.:" + SA2->A2_FAX,36) + " |" //OS 1760-16 Clแudia Carvalho - Luana Marin Ribeiro
		//cLin := PADR(" |Fax: (27)3421-9040 ",62)										+ PADR(" |   |TEL...:" + SA2->A2_TEL,30) 		+ PADR("FAX.:" + SA2->A2_FAX,36) + " |"
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR(" |CGC: 02.077.546/0001-76  IE: 081936443 ",62)					+ PADR(" |   |CONT..:" + SA2->A2_CONTATO,66) 	+ " |"
		fWrite(nHdl,cLin+cEOL)
	ELSE
		cLin := PADR("INCESA REVESTIMENTO CERAMICO LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR("Rua 3, 648, Civit II                     ",62)  		+ PADR("END...:" + SA2->A2_END,50)
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR("Cep: 29.168-079, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR("Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR("Fax: (27)3421-9040 ",62)							+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8) //OS 1760-16 Clแudia Carvalho - Luana Marin Ribeiro
		//cLin := PADR("Fax: (27)3421-9040 ",62)						+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
		fWrite(nHdl,cLin+cEOL)
		cLin := PADR("CGC: 04.917.232/0001-60  IE: 082.140.12-0 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
		fWrite(nHdl,cLin+cEOL)
	END IF
	
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
	cLin += PADC("DT.CHE.",11) /// ALTERADO POR BRUNO
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
	
	DbSelectArea("ctrabalho")	
	Do while !eof()
		J ++
		I := 1
		nQUANT := 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica o cancelamento pelo usuario...                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cLin := " " + PADR(POSICIONE("SB1",1,XFILIAL("SB1")+ctrabalho->C7_PRODUTO,"B1_TIPO"),3) //PADC(ctrabalho->C7_TIPO,3)
		cLin += PADC(ctrabalho->C7_PRODUTO,9)
		cLin += PADR(ctrabalho->C7_DESCRI,34)
		cLin += PADC(ctrabalho->C7_UM,5)
		cLin += PADC(ALLTRIM(DTOC(STOD(ctrabalho->C7_DATPRF))),11)
		cLin += PADC(ALLTRIM(DTOC(STOD(ctrabalho->C7_YDATCHE))),11) /// ALTERADO POR BRUNO
		cLin += PADC(ctrabalho->C7_TES,4)
		IMPOSTOS := IIf(ctrabalho->C7_YICMS = "S","M","") + IIf(ctrabalho->C7_YPIS = "S","P","")
		IMPOSTOS += IIf(ctrabalho->C7_YCOF = "S","M","C") + IIf(ctrabalho->C7_YIPI = "S","I","")
		cLin += PADC(IMPOSTOS,4)
		cLin += PADR(Transform(ctrabalho->C7_QUANT,    "@E 999,999,999.99"),15)
		cLin += PADR(Transform(ctrabalho->C7_PRECO,    "@E 99,999,999.999"),15)
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
		
		SCONDPG 	:= Posicione("SE4",1,xFilial("SE4")+ctrabalho->C7_COND,"E4_DESCRI")
		TOTAL_MERC 	+= ctrabalho->C7_TOTAL
		TOTAL_IPI 	+= round((( ctrabalho->C7_PRECO/100)* ctrabalho->C7_IPI) * ctrabalho->C7_QUANT,2)
		TOTAL_FRETE += ctrabalho->C7_VALFRE
		aTOTAL_DESC += ctrabalho->C7_VLDESC
		IIF(EMPTY(COBS),COBS := ctrabalho->C7_VLDESC,"")
	    DbSelectArea("ctrabalho")		
		DbSkip()
	EndDo
EndDo
NTOTALGERAL := (TOTAL_MERC+TOTAL_IPI+TOTAL_FRETE) - aTOTAL_DESC

cLin := " "
fWrite(nHdl,cLin+cEOL)
cLin := " "
fWrite(nHdl,cLin+cEOL)

cLin := "  " + REPLICATE("_",127)
fWrite(nHdl,cLin+cEOL)

cLin := " |" + REPLICATE(" ",38) + REPLICATE(" ",87) + " |"
fWrite(nHdl,cLin+cEOL)

cLin := PADR(" |TOTAL DAS MERCADORIAS.: ",25)	+	PADR(Transform(TOTAL_MERC,    "@E 999,999,999.99"),15) // + " |"
cLin += PADR(" " ,87)  + " |"
fWrite(nHdl,cLin+cEOL)

cLin := PADR(" |VALOR IPI.............: ",25)	+	PADR(Transform(TOTAL_IPI,    "@E 999,999,999.99"),15) 	//+ " |"
cLin += PADR(" ",87)  + " |"
fWrite(nHdl,cLin+cEOL)

cLin := PADR(" |VALOR FRETE...........: ",25)	+	PADR(Transform(TOTAL_FRETE,    "@E 999,999,999.99"),15)	//+ " |"
cLin += PADR("  ",87)  + " |"
fWrite(nHdl,cLin+cEOL)

cLin := PADR(" |DESCONTO..............: ",25)	+	PADR(Transform(aTOTAL_DESC,    "@E 999,999,999.99"),15) //	+ " |"
cLin += PADR(" ",87) + " |"
fWrite(nHdl,cLin+cEOL)

cLin := PADR(" |TOTAL GERAL...........: ",25)	+	PADR(Transform(NTOTALGERAL,    "@E 999,999,999.99"),15)//+ " |"
cLin += PADR("",87) + " |"
fWrite(nHdl,cLin+cEOL)

cLin := PADR(" |COND. PAGAMENTO.......: ",25)	+	PADR(SCONDPG,15)										//+ " |"
cLin += PADR(" ",87) + " |"
fWrite(nHdl,cLin+cEOL)

cLin := " |" + REPLICATE("_",39) + REPLICATE("_",87) + "|"
fWrite(nHdl,cLin+cEOL)

cLin := " "
fWrite(nHdl,cLin+cEOL)

fClose(nHdl)
DbSelectArea("ctrabalho")
DbCloseArea()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CRIA_EMAIL     บAutor  ณBRUNO MADALENO      บ Data ณ  04/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณROTINA PARA CRIAR O EMAIL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function CRIA_EMAIL()

cData     := DTOC(DDATABASE)
cTitulo   := "Pedido de compra "

cMensagem := "		Email enviado automaticamente pelo PROTHEUS 8.11 (microsiga). " + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)



If ALTERA
	cMensagem += "Informamos que foi alterado no sistema Microsiga o pedido de compra numero: "+cNumPed+ CHR(13)+CHR(10)
Endif

If INCLUI
	cMensagem += "Informamos que foi incluido no sistema Microsiga o pedido de compra numero: "+cNumPed+ CHR(13)+CHR(10)
endif

cMensagem += "As informa็๕es referentes a esse pedido encontra-se no arquivo anexo." + CHR(13)+CHR(10)
cMensagem += "Fineza efetivar aprova็ใo."+CHR(13)+CHR(10)
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ENV_EMAIL      บAutor  ณBRUNO MADALENO      บ Data ณ  04/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณROTINA PARA ENVIAR O EMAIL                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function ENV_EMAIL(cData,cTitulo,cMensagem)
//nInd    := 0
lResult := .F.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tenta conexao com o servidor de E-Mail ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CONNECT SMTP                         ;
SERVER   GetMV("MV_RELSERV");	// Nome do servidor de e-mail = smtp.bra.terra.com.br
ACCOUNT  GetMV("MV_RELACNT");	// Nome da conta a ser usada no e-mail = fulano
PASSWORD GetMV("MV_RELPSW") ;	// Senha = senha
RESULT   lResult				// Resultado da tentativa de conexใo

If !lResult
	MsgAlert(OemToAnsi("Erro de conexao com o servidor"))
Else
	//	 cEnvia 	:= CREMETENTE //"fabiola@biancogres.com.br"	// Email do Emissor
	
	cEnvia 	:=	 wwUsuario14
	
	//cEnvia 	:= "madaleno@biancogres.com.br"	// Email do Emissor
	cRecebe 	:= EMAIL						// Email do(s) receptor(es)
	cRecebeCC	:= ""							// Com Copia
	cRecebeCO	:= ""							// Copia Oculta
	cAssunto	:= cTitulo						// Assunto do Email
	
	cAnexos		:= "\P10\relato\PC_APROVADORES\"+cFORNECEDOR+"_pc.txt"
	
	Send Mail From cEnvia ;        // Email do Emissor
	To cRecebe ;                   // Email do(s) receptor(es)
	Subject cAssunto ;             // Assunto do Email
	Body cMensagem ;               // Mensagem
	Attachment cAnexos ;           // Anexa arquivos
	RESULT lOk                   // Verdadeiro se enviou,falso se nao
	
	If lOk
		//MSGBOX("Todos os Emails Enviado com Sucesso!!!","Email","INFO")
		CSTATUS := "OK"
		MsgBox("EMAIL ENVIADO COM SUCESSO PARA O APROVADOR","Alerta","INFO")
	Else
		//GET MAIL ERROR cSmtpError
		//MsgSTop( "Erro de envio : " + cSmtpError)
		CSTATUS := "N"
		MsgBox("ERRO AO ENVIAR O EMAIL","Alerta","STOP")
	Endif
	
	// Desconecta do Servidor
	//DISCONNECT SMTP SERVER
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza conexao com o servidor de E-Mail ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DISCONNECT SMTP SERVER
Return lResult
