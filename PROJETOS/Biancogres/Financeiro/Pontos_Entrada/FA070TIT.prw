#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FA070TIT ³ Autor ³ MADALENO              ³ Data ³ 26/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ FUNCAO VALIDAR A DATA DA BAIXA COM O PARAMETRO MV_DATAFIM  ³±±
±±³          ³ NO MOMENTO DA BAIXA DO CONTAS A RECEBER                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FA070TIT()

	Local lRet := .T.
	Local oObjDepId := TAFProrrogacaoBoletoReceber():New(.F.)

	Private lDebug := .F.

	If DBAIXA <= GETMV("MV_DATAFIN")
	
		MsgBox("Nao É permitida baixa, com data anterior a "+Dtoc(GetMv("MV_DATAFIN"))+". ","DATA INVALIDA","INFO")
		lRet := .F.
		
	EndIf

	//IF CMOTBX = "DESCONTO" -- TROCAR O TIPO DA BAIXA PELO VALOR DO DESCONTO ACIMA DO PARAMETRO.
	If NDESCONT > GetMV('MV_MAXDESC') .AND. CEMPANT <> "02"
	
		Private cCodApr := Space(100)
		
		SetPrvt("oDlg1","oGet1")
	
		If !IsBlind()
	
			oDlg1      := MSDialog():New( 103,235,233,614,"Código de Autorização",,,.F.,,,,,,.T.,,,.T. )
			oGet1      := TGet():New( 004,004,{|u| If(PCount()>0,cCodApr:=u,cCodApr)},oDlg1,176,034,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCodApr",,)
			oBtn1      := TButton():New( 044,144,"CONFIRMA",oDlg1,{|| oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )
			oDlg1:Activate(,,,.T.)
	
		EndIf
	
		If SE1->E1_YBLQ <> ALLTRIM(cCodApr) .And. !IsBlind()
		
			//ATUALIZANDO O CAMPO PARA BLOQUEAR O TITULO
			nRegSE1 := ALLTRIM(STR( SE1->(RecNo()) ))
			CSQL := " UPDATE "+RETSQLNAME("SE1")+" SET E1_YBLQ = '02', E1_YVLDESC = "+cValToChar(NDESCONT)+" WHERE R_E_C_N_O_ = '"+nRegSE1+"' "
			
			TCSQLExec(CSQL)
			
			ALERT("TITULO BLOQUEADO. FAVOR SOLICITAR AO GERENTE FINANCEIRO A LIBERAÇÃO DO TITULO")
			lRet := .F.
	
			GeraHtml()
	
		EndIf
	
	EndIf

	IF NDESCONT > GetMV('MV_MAXDESC') .AND. CEMPANT <> "02" .AND. SE1->E1_YBLQ == ALLTRIM(cCodApr)
	
		//ATUALIZANDO O CAMPO PARA BAIXAR O TITULO
		nRegSE1 := ALLTRIM(STR( SE1->(RecNo()) ))
		CSQL := " UPDATE "+RETSQLNAME("SE1")+" SET E1_YBLQ = 'XX' WHERE R_E_C_N_O_ = '"+nRegSE1+"' "
		
		TCSQLExec(CSQL)
		
	ENDIF

	/*
	IF CEMPANT <> "02"
		// BLOQUEANDO A BAIXA DO TITULO QUANDO REPRESENTANTE COM RESCISAO JA CRIADA E COM COMISSAO ZERADA.
		IF ALLTRIM(SE1->E1_VEND1) <> '' .OR. ALLTRIM(SE1->E1_VEND2) <> '' .OR. ALLTRIM(SE1->E1_VEND3) <> '' .OR. ALLTRIM(SE1->E1_VEND4) <> '' .OR. ALLTRIM(SE1->E1_VEND5) <> ''
			CSQL := " SELECT A3_YDTRESC FROM SA3010 WHERE	A3_COD = '"+SE1->E1_YVENDRC+"' AND D_E_L_E_T_ = '' "
			IF CHKFILE("_TRAB")
				DBSELECTAREA("_TRAB")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_TRAB" NEW
			IF ALLTRIM(_TRAB->A3_YDTRESC) <> ""
				ALERT("VENDEDOR COM RESCISÃO JÁ REALIZADA E COM VALOR DE COMISSAO PREENCHIDO")
				RETURN(.F.)
			ENDIF
		ENDIF
	ENDIF
	*/

	//Fernando/Facile em 28/07/2016 - projeto contratos de verba - para desconto de contrato tem que informar o numero para a contabilizacao
	If ( lRet .And. !IsBlind())

		While !InfDados()
		EndDo

	EndIf

	If lRet

		lRet := oObjDepId:VldDepAntJR() 

	EndIf

Return(lRet)


Static Function InfDados()

	Local aPergs := {}
	Local cItemCt := Space(9)
	Local cContrato := Space(6)
	Local aRet := {"",""}
	Local aMVBkp := {}
	Local lRet := .T.

	IF NDESCONT > GetMV('MV_MAXDESC') .AND. CEMPANT <> "02"

		AAdd(aMVBkp, MV_PAR01)
		AAdd(aMVBkp, MV_PAR02)

		aAdd( aPergs ,{1,"Item Contábil"		,cItemCt,"@!",'.T.',"CTD",'.T.',10,.F.})
		aAdd( aPergs ,{1,"No.Contrato Verba"	,cContrato,"@!",'.T.',"CTVBF3",'.T.',10,.F.})
	
		If ParamBox(aPergs ,"Baixa de duplicata com desconto",aRet)
	
			If ( AllTrim(aRet[1]) == "I0202")
		
				If Empty(aRet[2])
					MsgAlert("Obrigatório informar número do Contrato para descontos de verba contratual.","F070ACONT")
					lRet := .F.
				EndIf
			
				public __F70TITITEMD := aRet[1]
				public __F70TITCTRVER := aRet[2]
						
			EndIf
	
		Else
			lRet := .F.
		EndIf
	
		MV_PAR01 := aMVBkp[1]
		MV_PAR02 := aMVBkp[2]

	ENDIF

Return(lRet)

Static Function GeraHtml()

	// ENVIANCO EMAIL PARA OS RESPONSAVEIS PELO FINANCEIRO
	If Upper(AllTrim(getenvserver())) == "PRODUCAO"
		C_TITULO 	:= "Titulo do Contas a Receber Bloqueado"
	Else
		C_TITULO 	:= "AMBIENTE DE TESTE - FAVOR DESCONSIDERAR / Titulo do Contas a Receber Bloqueado"
	EndIf
	
	//C_DESTI		:= "enelcio.araujo@biancogres.com.br"
	//C_DESTI		:= "wanisay.william@biancogres.com.br"
	C_DESTI		:= "gardenia.stelzer@biancogres.com.br"
	
	If lDebug
		C_DESTI	:= "wlysses@facilesistemas.com.br"
	EndIf

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
	//C_HTML += '<table width="900" border="0" > '
	C_HTML += '  <tr> '
	C_HTML += '<font color="white"> '
	
	DO CASE
	CASE cEmpAnt = "01"
		C_HTML += '  <th scope="col"> TITULO BLOQUEADO NA EMPRESA BIANCOGRES <br>'
	CASE cEmpAnt = "05"
		C_HTML += '  <th scope="col"> TITULO BLOQUEADO NA EMPRESA INCESA <br>'
	OTHERWISE
		C_HTML += '  <th scope="col"> TITULO BLOQUEADO <br>'
	ENDCASE

	C_HTML += '</font>'
	C_HTML += '</tr> '
	C_HTML += '</table> '

	//DADOS 
	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" bgcolor="#7A67EE"> '
	//C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" bgcolor="#6495ED"> '
	C_HTML += '<font color="white"> '
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col"> DADOS DO TITULO:  </th> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2"> '
	C_HTML += '<font color="black" size="2"> '

	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> NÚMERO DO TITULO: <b>'+SE1->E1_NUM+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> CÓDIGO DO CLIENTE: <b>'+Alltrim(SA1->A1_COD)+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> NOME DO CLIENTE: <b>'+Alltrim(SE1->E1_NOMCLI)+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> VALOR DO DESCONTO: <b>'+Transform(NDESCONT,    "@E 999,999,999.99")+'</b></td> '
	C_HTML += '  </tr> '

	C_HTML += '</font>'
	C_HTML += '</table> '

	C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '
	C_HTML += '<p>&nbsp;	</p> '
	C_HTML += '</body> '
	C_HTML += '</html> '

	U_BIAEnvMail(,C_DESTI,C_TITULO,C_HTML)

Return()