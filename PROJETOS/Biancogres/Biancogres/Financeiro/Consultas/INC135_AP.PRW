#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#Include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ INC135   ³ Autor ³ Gustav/Magnago        ³ Data ³ 22/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Duplicatas por Fatura                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ INC135                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Numero da Fatura                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function INC135(wNum,wPref,wParc,wsEmp,lShowPar)

Local oFont1 := TFont():New("Arial",,017,,.T.,,,,,.F.,.T.)
Local oGet1
Local oGet2
Local oGet3
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSButton1
Local oSButton2
Static wsFatura   := Space(9)
Static wsPrefixo  := Space(3)
Static wsParc	  := Space(1)
Static oDlg

SetPrvt("CQUERY,AHEADER")
SetPrvt("WSNOMECLI,WSCLIENTE,WTOTFATURA,WE1_VENCTO,WE1_VENCREA")
SetPrvt("WE1_EMISSAO,WE1_BAIXA,")

Default wsEmp		 := cEmpAnt		//DEFINE EMPRESA PARA ABERTURA DAS TABELAS
Default lShowPar := .T.				//SE EXIBE A TELA DE PARAMETROS

If lShowPar

	DEFINE MSDIALOG oDlg TITLE "Consulta Faturas" FROM 000, 000  TO 170, 230 COLORS 0, 16777215 PIXEL
	@ 005, 032 SAY oSay2 PROMPT "Consulta Faturas" SIZE 068, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 020, 039 MSGET oGet1 VAR wsPrefixo SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 034, 039 MSGET oGet2 VAR wsFatura SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 048, 039 MSGET oGet3 VAR wsParc SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 022, 012 SAY oSay1 PROMPT "Prefixo" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 048, 012 SAY oSay3 PROMPT "Parcela" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 035, 012 SAY oSay4 PROMPT "Numero" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	DEFINE SBUTTON oSButton1 FROM 064, 021 TYPE 01 OF oDlg ENABLE ACTION Carga(wsEmp,lShowPar)
	DEFINE SBUTTON oSButton2 FROM 064, 073 TYPE 02 OF oDlg ENABLE ACTION Close(oDlg)
	ACTIVATE MSDIALOG oDlg CENTERED

Else

	wsFatura   := wNum
	wsPrefixo  := wPref
	wsParc	   := wParc
	Carga(wsEmp,lShowPar)

EndIf
	
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader com campos do SX3                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Carga(wsEmp,lShowPar)
Local aHeader 	:= {}
Local oFont1 		:= TFont():New("Arial",,020,,.T.,,,,,.F.,.T.)
Local oFont2 		:= TFont():New("Courier New",,016,,.T.,,,,,.F.,.T.) //TFont():New("Arial",,016,,.T.,,,,,.F.,.T.)
Local aColsFat	:= {}
Local aColsDet	:= {}
Local oWBrowse1
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Static oDlg3

//Verifica se a fatura está preenchida
If Empty(wsFatura)
	Msgbox("Informe um Número de Fatura.","Aviso","INFO")
	Return
EndIf

wsFatura  := Alltrim(wsFatura)
wsPrefixo := Alltrim(wsPrefixo)
wsParc	  := Alltrim(wsParc)

//Determina a tabela de acordo com a Empresa
cSE1 := "%SE1"+wsEmp+"0%"			
cSA1 := "%SA1"+wsEmp+"0%"			

cAliasTmp3 := GetNextAlias()
BeginSql Alias cAliasTmp3
	SELECT E1_ORIGEM, E1_YCLASSE
	FROM %Exp:cSE1% 
	WHERE E1_NUM = %Exp:wsFatura% AND  E1_PREFIXO  = %Exp:wsPrefixo% AND E1_PARCELA  = %Exp:wsParc%	 AND E1_TIPO = 'FT' AND D_E_L_E_T_ = ' '
EndSql

If (cAliasTmp3)->(EOF())
	Msgbox("O Número selecionado não existe.","Aviso","INFO")
	Return
EndIf

//Busca Informacoes da Fatura
//Se a Fatura foi gerada pela rotina BIA507 filtra tambem a PARCELA
//If Alltrim((cAliasTmp3)->E1_ORIGEM) == "BIA507"
If Alltrim((cAliasTmp3)->E1_YCLASSE) == "5" //Titulos de fatura, gerados atraves da rotina automatica
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT A.E1_PREFIXO, A.E1_NUM, A.E1_PARCELA, A.E1_FATURA, A.E1_PORTADO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_EMISSAO),103) E1_EMISSAO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_BAIXA),103) 	 E1_BAIXA,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_VENCTO),103)  E1_VENCTO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_VENCREA),103)  E1_VENCREA,
		A.E1_VALOR, A.E1_ORIGEM, A.E1_TIPO, A.E1_CLIENTE, A.E1_LOJA, B.A1_NOME, B.A1_COD, B.A1_LOJA
		FROM %Exp:cSE1% A, %Exp:cSA1% B
		WHERE A.E1_NUM    = %Exp:wsFatura%	 	AND
		A.E1_PREFIXO  = %Exp:wsPrefixo% 	AND
		A.E1_PARCELA  = %Exp:wsParc%	 		AND
		A.E1_CLIENTE = B.A1_COD    	AND
		A.E1_LOJA    = B.A1_LOJA   	AND
		A.E1_TIPO    = 'FT'				  AND
		A.D_E_L_E_T_ = ' '					AND
		B.D_E_L_E_T_ = ' '
		ORDER BY E1_NUM, E1_FATURA
	EndSql
	
Else
	//Se a Fatura foi gerada pela rotina padrao nao filtra PARCELA
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT A.E1_PREFIXO, A.E1_NUM, A.E1_PARCELA, A.E1_FATURA, A.E1_PORTADO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_EMISSAO),103) E1_EMISSAO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_BAIXA),103) 	 E1_BAIXA,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_VENCTO),103)  E1_VENCTO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_VENCREA),103)  E1_VENCREA,
		A.E1_VALOR, A.E1_ORIGEM, A.E1_TIPO, A.E1_CLIENTE, A.E1_LOJA, B.A1_NOME, B.A1_COD, B.A1_LOJA
		FROM %Exp:cSE1% A, %Exp:cSA1% B
		WHERE A.E1_NUM    = %Exp:wsFatura%	 	AND
		A.E1_PREFIXO  = %Exp:wsPrefixo% 	AND
		A.E1_CLIENTE = B.A1_COD    	AND
		A.E1_LOJA    = B.A1_LOJA   	AND
		A.E1_TIPO    = 'FT'				  AND
		A.D_E_L_E_T_ = ' '					AND
		B.D_E_L_E_T_ = ' '
		ORDER BY E1_NUM, E1_FATURA
	EndSql
EndIf

//Verifica se a Fatura existe
If (cAliasTmp)->(EOF())
	Msgbox("O Número selecionado não existe.","Aviso","INFO")
	Return
EndIf

//Preenche o array com as informacoes da Fatura
While	!(cAliasTmp)->(EOF())
	If Alltrim( (cAliasTmp)->E1_BAIXA)=="01/01/1900"
	  nBaixa := "  /  /    "
	Else
	  nBaixa := (cAliasTmp)->E1_BAIXA
	EndIf
	Aadd(aColsFat,{(cAliasTmp)->E1_PREFIXO,(cAliasTmp)->E1_NUM,(cAliasTmp)->E1_PARCELA,(cAliasTmp)->E1_TIPO,(cAliasTmp)->E1_EMISSAO,(cAliasTmp)->E1_VENCTO,(cAliasTmp)->E1_VENCREA,nBaixa,Transform((cAliasTmp)->E1_VALOR, "@E 999,999,999.99")})
	(cAliasTmp)->(DBSKIP())
End

//Acessa SX3 e monta aHeader com campos do SX3
DbSelectArea("SX3")
DbSetOrder(2)

DbSeek("E1_PREFIXO") ; AADD(aHeader,{ "Prefixo"           , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E1_NUM")     ; AADD(aHeader,{ "Nr Titulo"         , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E1_PARCELA") ; AADD(aHeader,{ "Parcela"           , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E1_TIPO")	 ; AADD(aHeader,{ "Tipo"              , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E1_EMISSAO") ; AADD(aHeader,{ "Emissao"           , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E1_VENCTO")  ; AADD(aHeader,{ "Vencimento"        , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E1_VENCREA") ; AADD(aHeader,{ "Vencto Real"       , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E1_BAIXA")   ; AADD(aHeader,{ "Baixa"             , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("E1_VALOR")   ; AADD(aHeader,{ "Valor Titulo"      , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )



//If Alltrim((cAliasTmp3)->E1_ORIGEM) == "BIA507"
If Alltrim((cAliasTmp3)->E1_YCLASSE) == "5"

	//Busca informacoes dos Titulos que formaram a Fatura
	cAliasTmp2 := GetNextAlias()
	BeginSql Alias cAliasTmp2
		SELECT A.E1_PREFIXO, A.E1_NUM, A.E1_PARCELA, A.E1_FATURA, A.E1_PORTADO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_EMISSAO),103) E1_EMISSAO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_BAIXA),103) 	 E1_BAIXA,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_VENCTO),103)  E1_VENCTO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_VENCREA),103)  E1_VENCREA,
		A.E1_VALOR, A.E1_CLIENTE, A.E1_TIPO, A.E1_LOJA, B.A1_NOME, B.A1_COD, B.A1_LOJA
		FROM %Exp:cSE1% A, %Exp:cSA1% B
		WHERE A.E1_FATURA = %Exp:wsFatura%	 	AND
		A.E1_FATPREF  = %Exp:wsPrefixo% 	AND
		A.E1_YPARCFT  = %Exp:wsParc%	 		AND
		A.E1_CLIENTE = B.A1_COD    	AND
		A.E1_LOJA    = B.A1_LOJA   	AND
		A.D_E_L_E_T_ = ' '					AND
		B.D_E_L_E_T_ = ' '
		ORDER BY E1_NUM, E1_FATURA
	EndSql
	
Else
	
	//Busca informacoes dos Titulos que formaram a Fatura
	cAliasTmp2 := GetNextAlias()
	BeginSql Alias cAliasTmp2
		SELECT A.E1_PREFIXO, A.E1_NUM, A.E1_PARCELA, A.E1_FATURA, A.E1_PORTADO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_EMISSAO),103) E1_EMISSAO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_BAIXA),103) 	 E1_BAIXA,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_VENCTO),103)  E1_VENCTO,
		CONVERT(VARCHAR, CONVERT(DATETIME, A.E1_VENCREA),103)  E1_VENCREA,
		A.E1_VALOR, A.E1_CLIENTE, A.E1_TIPO, A.E1_LOJA, B.A1_NOME, B.A1_COD, B.A1_LOJA
		FROM %Exp:cSE1% A, %Exp:cSA1% B
		WHERE A.E1_FATURA = %Exp:wsFatura%	 	AND
		A.E1_FATPREF  = %Exp:wsPrefixo% 	AND
		A.E1_CLIENTE = B.A1_COD    	AND
		A.E1_LOJA    = B.A1_LOJA   	AND
		A.D_E_L_E_T_ = ' '					AND
		B.D_E_L_E_T_ = ' '
		ORDER BY E1_NUM, E1_FATURA
	EndSql
	
EndIf

If (cAliasTmp2)->(EOF())
	Msgbox("Ocorreu um erro na pesquisa da Fatura. Favor contactar o setor de TI.","Aviso","INFO")
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols - Linhas da Coluna                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wsNomeCli  := ""
wsCliente  := ""
wTotFatura := 0

DbSelectArea(cAliasTmp2)
DbGoTop()
wsNomeCli := AllTrim((cAliasTmp2)->A1_NOME)
wsCliente := AllTrim((cAliasTmp2)->A1_COD)
While !(cAliasTmp2)->(EOF())
	If Alltrim( (cAliasTmp)->E1_BAIXA)=="01/01/1900"
	  nBaixa := "  /  /    "
	Else
	  nBaixa := (cAliasTmp2)->E1_BAIXA
	EndIf
	Aadd(aColsDet,{(cAliasTmp2)->E1_PREFIXO,(cAliasTmp2)->E1_NUM,(cAliasTmp2)->E1_PARCELA,(cAliasTmp2)->E1_TIPO,(cAliasTmp2)->E1_EMISSAO,(cAliasTmp2)->E1_VENCTO,(cAliasTmp2)->E1_VENCREA,nBaixa,(Transform((cAliasTmp2)->E1_VALOR, "@E 999,999,999.99"))}) 
	wTotFatura:= wTotFatura + (cAliasTmp2)->E1_VALOR
	(cAliasTmp2)->(DBSKIP())
End

wTotFatura := Transform(wTotFatura	, "@E 999,999,999.99")

DEFINE MSDIALOG oDlg3 TITLE "" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL

@ 005, 167 SAY oSay1 PROMPT "Consulta Faturas" SIZE 069, 009 OF oDlg3 FONT oFont1 COLORS 0, 16777215 PIXEL
@ 039, 007 SAY oSay2 PROMPT "Fatura" 		SIZE 033, 008 OF oDlg3 FONT oFont1 COLORS 0, 16777215 PIXEL
@ 114, 007 SAY oSay3 PROMPT "Detalhe da Fatura" SIZE 074, 008 OF oDlg3 FONT oFont1 COLORS 0, 16777215 PIXEL
@ 020, 007 SAY oSay4 PROMPT "Cliente: "+wsCliente+" "+wsNomeCli SIZE 221, 008 OF oDlg3 FONT oFont1 COLORS 0, 16777215 PIXEL

@ 100, 300 SAY oSay5 PROMPT "Total da Fatura" SIZE 044, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 100, 350 SAY oSay6 PROMPT wTotFatura SIZE 041, 007 OF oDlg3 COLORS 0, 16777215 PIXEL

@ 208, 300 SAY oSay7 PROMPT "Total das Notas"		 	SIZE 045, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 208, 350 SAY oSay8 PROMPT wTotFatura 	SIZE 045, 007 OF oDlg3 COLORS 0, 16777215 PIXEL


oLbx:= TWBrowse():New(052,007,380,045,,{aHeader[1][1],aHeader[2][1],aHeader[3][1],aHeader[4][1],aHeader[5][1],aHeader[6][1],aHeader[7][1],aHeader[8][1],aHeader[9][1]}, ;
{aHeader[1][4],aHeader[2][4],aHeader[3][4],aHeader[4][4],aHeader[5][4],aHeader[6][4],aHeader[7][4],aHeader[8][4],aHeader[9][4]},oDlg3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx:SetArray(aColsFat)
oLbx:bLine := {|| aEval(aColsFat[oLbx:nAt],{|z,w| aColsFat[oLbx:nAt,w] } ) }

oLbx2:= TWBrowse():New(127,007,380,080,,{aHeader[1][1],aHeader[2][1],aHeader[3][1],aHeader[4][1],aHeader[5][1],aHeader[6][1],aHeader[7][1],aHeader[8][1],aHeader[9][1]}, ;
{aHeader[1][4],aHeader[2][4],aHeader[3][4],aHeader[4][4],aHeader[5][4],aHeader[6][4],aHeader[7][4],aHeader[8][4],aHeader[9][4]},oDlg3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx2:SetArray(aColsDet)
oLbx2:bLine := {|| aEval(aColsDet[oLbx2:nAt],{|z,w| aColsDet[oLbx2:nAt,w] } ) }

ACTIVATE MSDIALOG oDlg3 CENTERED

If lShowPar
	Close(oDlg)
EndIf

Return