#include "topconn.ch"
#include "ap5mail.ch"
#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} BIAFG038
@author Gabriel Rossi Mafioletti
@since 17/04/2018
@version 1.0
@description Informações de Pedidos
@type function
/*/

// IDENTIFICADORES DE LINHA
#DEFINE LIN "LIN"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN 100

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND "WND"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Envio de e-mail solicitando informações"


User Function BIAFG038()

Private _cRemet	:=	UsrRetMail(__cUserId)
Private _cValue	:=	fGetSolM()
Private _cDesc	:=	PADR("Mensagem a Ser Enviada",300)


If !ValidPerg()
	Return
EndIf

Private cArqTxt	:=	"\P10\BIAFG038\" + SC7->C7_NUM + DTOS(Date()) + REPLACE(TIME(),":","") + ".TXT"
Private cEOL            := "CHR(13)+CHR(10)"


fGeraArq()

CRIA_EMAIL()

Return




STATIC FUNCTION fGeraArq()
Local J        := 1
Local I        := 1
Local Enter2   := CHR(13)+CHR(10)
Local nHdl_121 := fCreate(cArqTxt)
Local cLin

Local nTOTMERC	:=	0
Local nTOTIPI	:=	0
Local nTOTFRETE	:=	0
Local nTotGer	:=	0
Local nTotDesc	:=	0

IF EMPTY(cEOL)
	cEOL := CHR(13)+CHR(10)
ELSE
	cEOL := TRIM(cEOL)
	cEOL := &cEOL
ENDIF

CSQL := "SELECT * FROM "+ RETSQLNAME("SC7")+" " + Enter2
CSQL += "WHERE 	C7_NUM = '"+SC7->C7_NUM+"' AND  " + Enter2
CSQL += "		C7_FORNECE = '"+SC7->C7_FORNECE+"' AND " + Enter2
CSQL += "		D_E_L_E_T_ = '' " + Enter2

TCQUERY CSQL ALIAS "ctrab" NEW
dbSelectArea("ctrab")
dbGotop()


IF ctrab->C7_QUJE = 0
	ccFLAG = "SIM"
ELSE
	ccFLAG = "NAO"
ENDIF

WHILE !EOF()
	
	dbSelectArea("SA2")
	dbsetOrder(1)
	dbseek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
	dbSelectArea("ctrab")

	
	//VERIFICANDO USUARIO QUE INCLUIU O PEDIDO
	cQuery9 := 	""
	cQuery9 +=	"SELECT C7_USER, C7_NUM				"
	cQuery9 +=	"FROM "+RetSqlName("SC7")+" 			"
	cQuery9 +=	"WHERE D_E_L_E_T_ 	= '' AND			"
	cQuery9 +=	"      C7_NUM		= '"+SC7->C7_NUM+"' 	"
	IF chkfile("_SC7")
		dbSelectArea("_SC7")
		dbCloseArea()
	ENDIF
	TCQuery cQuery9 Alias "_SC7" New
	
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
		nTOTDESC    += ctrab->C7_VLDESC
		DbSelectArea("ctrab")
		DbSkip()
	EndDo
EndDo
nTotGer := (nTOTMERC+nTOTIPI+nTOTFRETE) - nTOTDESC

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

cLin := PADR(" |DESCONTO..............: ",25)	+	PADR(Transform(nTOTDESC,    "@E 999,999,999.99"),15)
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

STATIC Function CRIA_EMAIL()

cData     := DTOC(DDATABASE)
cTitulo   := "Pedido de compra - Solicitação de Informações"
cMensagem := _cDesc
cMensagem += CHR(13)+CHR(10)


ENV_EMAIL(cData,cTitulo,cMensagem)

RETURN

STATIC Function ENV_EMAIL(cData,cTitulo,cMensagem)

Local lOk

cRecebe 	:= _cValue						// Email do(s) receptor(es)
cRecebeCC	:= _cRemet							// Com Copia
cRecebeCO	:= ""							// Copia Oculta
cAssunto	:= cTitulo						// Assunto do Email
cAnexos		:= cArqTxt

lOk := U_BIAEnvMail(,cRecebe,cAssunto,cMensagem,,cAnexos,,cRecebeCC)

IF lOk 
	CSTATUS := "OK"
	MsgInfo("EMAIL ENVIADO COM SUCESSO PARA O(S) DESTINATÁRIOS")
ELSE
	CSTATUS := "N"
	MsgInfo("ERRO AO ENVIAR O EMAIL")
ENDIF

RETURN


Static Function ValidPerg()

	Local oWindow	:=	Nil
	Local oDlg		:=	Nil	
	
	Local lRet		:=	.F.
	Local oFntBold	:=	TFont():New("MS Sans Serif",,18,,.T.)
	
	
	If !Empty(_cRemet)
		
		// Cria Dialog padrão
		oDlg := MsDialog():New(0, 0, 220, 420, TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
		oDlg:cName := "oDlg"
		oDlg:lCentered := .T.
		oDlg:lEscClose := .F.
		oDlg:bValid := {|| .F. }
		
		// Barra de botoes
		oBtnBar := FWButtonBar():New()
		oBtnBar:Init(oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
		oBtnBar:AddBtnText("OK", "OK", {|| oDlg:End(), lRet := .T. },,,CONTROL_ALIGN_LEFT,.T.)	
		oBtnBar:AddBtnText("Cancelar", "Cancelar", {|| oDlg:End(), lRet	:=	.F. },,,CONTROL_ALIGN_LEFT,.T.)
		
		// Layer
		oLayer := FWLayer():New()
		oLayer:Init(oDlg, .F., .T.)
		
		// Adiciona linha ao Layer
		oLayer:AddLine(LIN, 100, .F.)
		// Adiciona coluna ao Layer
		oLayer:AddCollumn(COL, PER_COL, .T., LIN)
		// Adiciona janela ao Layer
		oLayer:AddWindow(COL, WND, _cRemet , 100, .F. ,.T.,, LIN, { || })
		
		oLayer:SetWinTitle(COL, WND, "De: " + _cRemet , LIN)
		  
		// Muda fonte do Layes
		oLayer:GetWindow(COL, WND, @oWindow, LIN)			
		oWindow:oTitleBar:oFont := oFntBold //TFont():New("MS Sans Serif",,18,,.T.)
		
		// Retorna paimel da janela do Layer
		oPnl := oLayer:GetWinPanel(COL, WND, LIN)
				
		oSayValue := TSay():Create(oPnl)
		oSayValue:cName := "oSayValue"
		oSayValue:cCaption := "Para:"
		oSayValue:nLeft := 06
		oSayValue:nTop := 06
		oSayValue:nWidth := 60
		oSayValue:nHeight := 20
		//oSayValue:nClrText := CLR_HBLUE
		oSayValue:oFont := oFntBold
		oSayValue:cToolTip := "Conteúdo do Parâmetro"	
		
		oGetValue := TGet():Create(oPnl)
		oGetValue:cName := "oGetValue"
		oGetValue:nLeft := 06
		oGetValue:nTop := 22
		oGetValue:nWidth := 300 
		oGetValue:nHeight := 20
		oGetValue:cVariable := "_cValue"
		oGetValue:bSetGet := bSetGet(_cValue)
		//oGetValue:bValid := {|| ::Validate() }
		oGetValue:Picture := "@!"
		oGetValue:cToolTip := "Conteúdo do Parâmetro"
		oGetValue:cF3	:=	"USREMA"
	
		oMDesc := TMultiGET():Create(oPnl)
		oMDesc:cName := "oMDesc"
		oMDesc:nLeft := 06
		oMDesc:nTop := 48
		oMDesc:nWidth := 390
		oMDesc:nHeight := 80
		oMDesc:lShowHint := .F.
		oMDesc:lReadOnly := .F.
		oMDesc:cVariable := "_cDesc"
		oMDesc:bSetGet := bSetGet(_cDesc)
		oMDesc:EnableVScroll(.T.)
					
		oDlg:Activate()
	
	Else
		MsgInfo("Email não cadastrado para o usuário. Não será possível prosseguir!")
		lRet	:=	.F.
	EndIf

Return lRet


Static Function fGetSolM()

	Local _cEmail	:=	SPACE(200)
	Local _cAlias	
	Local _cEmpFil	:=	cEmpAnt+cFilAnt
	
	If !Empty(SC7->C7_NUMSC)
		_cAlias	:=	GetNextAlias()
		BeginSql Alias _cAlias
			SELECT MAX(EMAIL) EMAIL
			FROM ZEUS.BIZAGIPRD.dbo.[BZ_DADOS_SC]
			WHERE PROTHEUS = %EXP:SC7->C7_NUMSC%
				AND EMPRESA = %Exp:_cEmpFil%
		EndSql
		
		_cEmail	:=	PADR(((_cAlias)->EMAIL),200)
		(_cAlias)->(DbCloseArea())
	EndIf
Return _cEmAil