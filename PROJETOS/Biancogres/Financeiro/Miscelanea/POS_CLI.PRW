#include "rwmake.ch"
#Include "TopConn.ch"
#Include "Colors.ch"
#Include "Protheus.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³POS_CLI   ºAutor  ³ MADALENO           º Data ³  24/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CONSULTA A POSICAO  DO CLIENTE NAS EMPRESAS BIANCO E   	  º±±
±±º          ³ COMERCIAL MOENDAS E LM                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP7 - FINANCEIRO                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function POS_CLI()

	Private cCliente	:= SPACE(6)
	Private cLoja		:= SPACE(2)
	PRIVATE aAreaAnt	:= {}

	Private nTmpSF2G := ""
	Private nTmpSF2C := ""
	Private nTmpSE1G := ""
	Private nTmpSE1C := ""
	Private nTmpSA1  := ""

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	Private cArqSA1	:= ""
	Private cIndSA1	:= 0
	Private cRegSA1	:= 0

	Private nLastCol := 0

	Private aTmpIdx := {}
	Private aFldOrd := {}

	Private oTableMain := Nil
	Private cAliasTrab := GetNextAlias()

	//Controla a abertura do programa
	cContador ++
	If cContador > 1
		Return
	EndIf

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SA1")
	cArqSA1 := Alias()
	cIndSA1 := IndexOrd()
	cRegSA1 := Recno()

	aAreaAnt := GetArea()

	If Alltrim(Funname()) == "MATA450"
		DBSELECTAREA("SA1")
		DBSETORDER(1)
		DBSEEK(XFILIAL("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA)
		cCliente	:= SC9->C9_CLIENTE//SA1->A1_COD
		cLoja 		:= SC9->C9_LOJA //SA1->A1_LOJA
		U_POS_CLIENTE()
	ElseIf Alltrim(Funname()) == "FINC010"
		cCliente	:= SA1->A1_COD
		cLoja 		:= SA1->A1_LOJA
		U_POS_CLIENTE()
	ElseIf Alltrim(Funname()) == "TMKA271"   // Incluido por Marcos Alberto em 06/12/11 em atendimento a OS Effettivo 0412-11
		cCliente	:= ACF->ACF_CLIENT
		cLoja 		:= ACF->ACF_LOJA
		U_POS_CLIENTE()
	ElseIf Alltrim(Funname()) == "MATA416" .And. IsInCallStack("A415Baixa")
		Msgbox("Esta rotina não poderá ser utilizada nesta tela!","POS_CLI","STOP")
		cContador := 0
		Return

	ElseIf Alltrim(Funname()) == "MATA030" .And. (IsInCallStack("A030INCLUI") .Or. IsInCallStack("A030ALTERA"))
		Msgbox("Esta rotina não pode ser utilizada na tela de clientes em modo de INCLUSÃO/ALTERAÇÃO!", "POS_CLI", "STOP")
		cContador := 0
		Return
	Else
		@ 096,042 TO 280,360 DIALOG oEntra00 TITLE "PARAMETRO PARA CONSULTA DA POSIÇÃO DO CLIENTE"
		@ 008,012 TO 84,150 COLOR CLR_BLACK PIXEL OF oEntra00
		@ 023,021 SAY "CÓDIGO DO CLIENTE : " COLOR CLR_BLACK PIXEL OF oEntra00

		//@ 023,088 GET cCliente 		Size 50,20 F3  "SA1"
		//@ 023,088 GET cCliente 		Size 50,20 F3  "SA1RAC" Valid fVldCli()
		//@ 023,088 GET cCliente 		Size 50,20 F3  "SA1SC5" Valid fVldCli()
		@ 023,088 GET cCliente 		Size 50,20 F3  "SA1REP" Valid fVldCli()

		@ 036,021 SAY "LOJA DO CLIENTE"		COLOR CLR_BLACK PIXEL OF oEntra00
		@ 036,088 GET cLoja 		Size 50, 8 COLOR CLR_BLACK PIXEL OF oEntra00

		@ 055,050 BUTTON "SUBMETER" SIZE 30,15 PIXEL OF oEntra00 ACTION U_POS_CLIENTE() // Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 55,20 BUTTON "_Submeter" SIZE 30,15 ACTION Execute(fSubmit)
		@ 055,090 BUTTON "ABORTAR"  SIZE 30,15 PIXEL OF oEntra00 ACTION Close(oEntra00) // Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 55,60 BUTTON "_Abortar"  SIZE 30,15 ACTION Execute(fAborta)
		ACTIVATE DIALOG oEntra00 CENTERED
	EndIf

	If chkfile(cAliasTrab)
		dbSelectArea(cAliasTrab)
		dbCloseArea()
		oTableMain:Delete()
	EndIf

	If chkfile("c_CONS")
		dbSelectArea("c_CONS")
		dbCloseArea()
	EndIf

	If chkfile("VENDB")
		dbSelectArea("VENDB")
		dbCloseArea()
	EndIf

	If chkfile("VENDI")
		dbSelectArea("VENDI")
		dbCloseArea()
	EndIf

	If chkfile("_TITABERTO")
		dbSelectArea("_TITABERTO")
		dbCloseArea()
	EndIf

	If chkfile("TRB")
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	If chkfile("_TITRECEBIDO")
		dbSelectArea("_TITRECEBIDO")
		dbCloseArea()
	EndIf

	If chkfile("_PEDIDOS")
		DBSELECTAREA("_PEDIDOS")
		DBCLOSEAREA("_PEDIDOS")
	EndIf

	RestArea(aAreaAnt)

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
	EndIf

	If cArq <> ""
		DbSelectArea(cArq)
		DbSetOrder(cInd)
		DbGoTo(cReg)
	EndIf

	//Controla a abertura do programa
	cContador := 0

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³POS_CLIENTE ºAutor  ³ MADALENO           º Data ³  24/05/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ TELA ONDE SERA EXIBIDA AS INFORMACOES DOS CLIENTES NAS 2   º±±
±±º          ³ EMPRESAS BIANCO E COMERCIAL MOENDAS                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function POS_CLIENTE()

	Local oAceTela 	:= TAcessoTelemarketing():New()

	Private cPerg	:= "FIC010"
	Private cSQL	:= ""
	Private aCampos
	Private lop,cnum,ocheck,cmarkbr
	Private I 		:= 1
	Private Enter	:= CHR(13)+CHR(10)
	Private lGrp	:= .F.
	Private _aRet	:= {}

	//Private nTmpSF2G := "##POSCLISF2G"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	//Private nTmpSF2C := "##POSCLISF2C"+cEmpAnt+__cUserID+strzero(seconds()*3780,10)
	//Private nTmpSE1G := "##POSCLISE1G"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	//Private nTmpSE1C := "##POSCLISE1C"+cEmpAnt+__cUserID+strzero(seconds()*3670,10)
	//Private nTmpSA1  := "##POSCLISA1"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)

	//Private nTmpSF2G := "TMPRAC_POSCLISF2G"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	//Private nTmpSF2C := "TMPRAC_POSCLISF2C"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	//Private nTmpSE1G := "TMPRAC_POSCLISE1G"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	//Private nTmpSE1C := "TMPRAC_POSCLISE1C"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	//Private nTmpSA1  := "TMPRAC_POSCLISA1"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)

	If cCliente = "" .OR. CLOJA = ""
		Alert("INFORMAÇÕES INVÁLIDAS")
		Return
	EndIf

	If (oAceTela:UserTelemaketing())
		If (!oAceTela:CheckSA1Repre(cCliente))
			MsgStop("Cliente NÃO permitido para o Atendente (Telemaketing) !", "")
			Return
		EndIf
	EndIf

	DBSELECTAREA("SA1")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SA1")+cCliente+cLoja)

	_aCampos :=	{				{"CODIGO"			,"N",02,0},;
		{"DESCRICAO"		,"C",15,0},;
		{"VALOR"			,"C",15,0},;
		{"ESPACO"			,"C",03,0},;
		{"DESCRICAO2"		,"C",20,0},;
		{"CONSULTACL"		,"C",12,0},;
		{"CONSULTAGR"		,"C",12,0}}

	If chkfile(cAliasTrab)

		dbSelectArea(cAliasTrab)
		dbCloseArea()

		oTableMain:Delete()

	EndIf

	oTableMain := FWTemporaryTable():New(cAliasTrab, /*aFields*/)

	oTableMain:SetFields(_aCampos)

	oTableMain:AddIndex("01", {"CODIGO"})

	oTableMain:Create()

	//Montagem base de Clientes
	//TESTE1
	//aResult := TcSQLExec("EXEC SP_POSCLI_SA1 "+nTmpSA1+",'"+cCliente+"','"+cLoja+"','"+SA1->A1_GRPVEN+"','"+SA1->A1_YTIPOLC+"' ")
	//If aResult <> 0
	//   MsgStop('Falha na inclusão dos registros  ('+str(aResult,4)+') : '+TcSqlError())
	//EndIf

	//TESTE2
	//cSql := "EXEC SP_POSCLI_SA1 "+nTmpSA1+",'"+cCliente+"','"+cLoja+"','"+SA1->A1_GRPVEN+"','"+SA1->A1_YTIPOLC+"' "
	//U_BIAMsgRun("Aguarde... Gerando Base... Cadastro Cliente...",,{|| TcSQLExec(cSQL)})

	//TESTE3
	U_BIAMsgRun("Aguarde... Gerando Base... Cadastro Cliente...",,{|| _aRet := TCSPEXEC("SP_POSCLI_SA1_2",cCliente,cLoja,SA1->A1_GRPVEN,SA1->A1_YTIPOLC) })

	If Type("_aRet") == "A" .And. Len(_aRet) > 0
		If _aRet[1] == 0
			MsgStop("Ocorreu problema na geração da Base de Clientes. Tente novamente.","Posição Cliente")
			Return
		EndIf
	EndIf

	nTmpSA1 := _aRet[2]

	//TESTE4
	//cSQL := "SELECT * INTO "+nTmpSA1+"	"
	//cSQL += "FROM  						"
	//cSQL += "(SELECT '01' AS EMP, A1_FILIAL, A1_GRPVEN,A1_YTIPOLC, A1_COD, A1_LOJA, A1_NOME, A1_LC, A1_SALDUP, A1_MATR, A1_METR, A1_VENCLC, A1_RISCO, A1_PRICOM, A1_MCOMPRA, A1_ULTCOM, A1_MSALDO, D_E_L_E_T_ 	"
	//cSQL += "FROM SA1010  WITH (NOLOCK)	"
	//cSQL += "WHERE A1_COD = '008811' AND A1_LOJA = '01' AND D_E_L_E_T_ = ''	"
	//cSQL += "UNION ALL 					"
	//cSQL += "SELECT '05' AS EMP, A1_FILIAL, A1_GRPVEN,A1_YTIPOLC, A1_COD, A1_LOJA, A1_NOME, A1_LC, A1_SALDUP, A1_MATR, A1_METR, A1_VENCLC, A1_RISCO, A1_PRICOM, A1_MCOMPRA, A1_ULTCOM, A1_MSALDO, D_E_L_E_T_  	"
	//cSQL += "FROM SA1050  WITH (NOLOCK)	"
	//cSQL += "WHERE A1_COD = '008811' AND A1_LOJA = '01' AND D_E_L_E_T_ = ''	"
	//cSQL += "UNION ALL 					"
	//cSQL += "SELECT '07' AS EMP, A1_FILIAL, A1_GRPVEN,A1_YTIPOLC, A1_COD, A1_LOJA, A1_NOME, A1_LC, A1_SALDUP, A1_MATR, A1_METR, A1_VENCLC, A1_RISCO, A1_PRICOM, A1_MCOMPRA, A1_ULTCOM, A1_MSALDO, D_E_L_E_T_  	"
	//cSQL += "FROM SA1070  WITH (NOLOCK)	"
	//cSQL += "WHERE A1_COD = '008811' AND A1_LOJA = '01' AND D_E_L_E_T_ = '') TMP	"
	//U_BIAMsgRun("Aguarde... Gerando Base... Cadastro Cliente...",,{|| TcSQLExec(cSQL)})

	//Criando tabelas temporaria SF2, SE1 e SA1  - 08/03/13
	If Alltrim(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"

		/*cSQL := "SELECT F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_EMISSAO,F2_VALBRUT INTO "+nTmpSF2G+" "
		cSQL += "FROM VW_SF2 WITH (NOLOCK), "+nTmpSA1+" SA1     "
		cSQL += "WHERE 	F2_FILIAL 	= '"+xFilial("SF2")+"' 	AND "
		cSQL += "		A1_FILIAL   = '"+xFilial("SA1")+"'  AND "
		cSQL += "		F2_CLIENTE	= A1_COD 				AND "
		cSQL += "		F2_LOJA  	= A1_LOJA				AND "
		cSQL += "		A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'  AND "
		cSQL += "		A1_YTIPOLC  = 'G' 					AND "
		cSQL += "		EMP      	= '01'                  AND "
		cSQL += "		SA1.D_E_L_E_T_  = '' 					" 
		U_BIAMsgRun("Aguarde... Gerando Base... NFs por Grupo...",,{|| TcSQLExec(cSQL)})*/

		_aRet	:= {}
		
		U_BIAMsgRun("Aguarde... Gerando Base... NFs por Grupo...",,{|| _aRet := TCSPEXEC("SP_POSCLI_SF2",nTmpSA1,'','',SA1->A1_GRPVEN,SA1->A1_YTIPOLC, '', '', '') })	      
		
		If Type("_aRet") == "A" .And. Len(_aRet) > 0
			If _aRet[1] == 0
			MsgStop("Ocorreu problema na geração das NFs por Grupo. Tente novamente.","Posição Cliente")		
			Return
			EndIf
		EndIf
		
		nTmpSF2G := _aRet[2]
		
		/*cSQL := "SELECT E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_TIPO, E1_BAIXA, E1_VENCTO, E1_FATURA, E1.D_E_L_E_T_ INTO "+nTmpSE1G+" "
		cSQL += "FROM VW_SE1 E1 WITH (NOLOCK), "+nTmpSA1+" SA1	"
		cSQL += "WHERE 	E1_FILIAL 	= '"+xFilial("SE1")+"' 	AND "
		cSQL += "		A1_FILIAL   = '"+xFilial("SA1")+"'  AND "
		cSQL += "		E1_CLIENTE	= A1_COD 				AND "
		cSQL += "		E1_LOJA  	= A1_LOJA				AND "
		cSQL += "		A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'  AND "
		cSQL += "		A1_YTIPOLC  = 'G' 					AND "
		cSQL += "		EMP      	= '01'                  AND "
		cSQL += "		SA1.D_E_L_E_T_  = '' 					" 
		U_BIAMsgRun("Aguarde... Gerando Base... Titulos por Grupo...",,{|| TcSQLExec(cSQL)})*/
		
		_aRet	:= {}

		U_BIAMsgRun("Aguarde... Gerando Base... Titulos por Grupo...",,{|| _aRet := TCSPEXEC("SP_POSCLI_SE1",nTmpSA1,'','',SA1->A1_GRPVEN,SA1->A1_YTIPOLC, '', '', '') })	      
		
		If Type("_aRet") == "A" .And. Len(_aRet) > 0
			If _aRet[1] == 0
			MsgStop("Ocorreu problema na geração dos Titulos por Grupo. Tente novamente.","Posição Cliente")		
			Return
			EndIf
		EndIf
		
		nTmpSE1G := _aRet[2]

	EndIf

	/*cSQL := "SELECT F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_EMISSAO,F2_VALBRUT INTO "+nTmpSF2C+" "
	cSQL += "FROM VW_SF2 WITH (NOLOCK), "+nTmpSA1+" SA1     "
	cSQL += "WHERE 	F2_FILIAL 	= '"+xFilial("SF2")+"' 	AND "
	cSQL += "		A1_FILIAL   = '"+xFilial("SA1")+"'  AND "
	cSQL += "		F2_CLIENTE	= A1_COD 				AND "
	cSQL += "		F2_LOJA  	= A1_LOJA				AND "
	cSQL += "		A1_COD 		= '"+cCliente+"' 		AND "
	cSQL += "		A1_LOJA 	= '"+cLoja+"' 			AND "
	cSQL += "		EMP      	= '01'                  AND "
	cSQL += "		SA1.D_E_L_E_T_  = '' 					" 
	U_BIAMsgRun("Aguarde... Gerando Base.. NFs por Cliente...",,{|| TcSQLExec(cSQL)})*/
	
	_aRet	:= {}

	U_BIAMsgRun("Aguarde... Gerando Base... NFs por Cliente...",,{|| _aRet := TCSPEXEC("SP_POSCLI_SF2",nTmpSA1,cCliente,cLoja,'', '', '', '', '') })
	
	If Type("_aRet") == "A" .And. Len(_aRet) > 0
		If _aRet[1] == 0
		MsgStop("Ocorreu problema na geração das NFs por Cliente. Tente novamente.","Posição Cliente")		
		Return
		EndIf
	EndIf
	
	nTmpSF2C := _aRet[2]

	/*cSQL := "SELECT E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_TIPO, E1_BAIXA, E1_VENCTO, E1_FATURA, E1.D_E_L_E_T_ INTO "+nTmpSE1C+" "
	cSQL += "FROM VW_SE1 E1 WITH (NOLOCK), "+nTmpSA1+" SA1	"
	cSQL += "WHERE 	E1_FILIAL 	= '"+xFilial("SE1")+"' 	AND "
	cSQL += "		A1_FILIAL   = '"+xFilial("SA1")+"'  AND "
	cSQL += "		E1_CLIENTE	= A1_COD 				AND "
	cSQL += "		E1_LOJA  	= A1_LOJA				AND "
	cSQL += "		A1_COD 		= '"+cCliente+"' 		AND "
	cSQL += "		A1_LOJA 	= '"+cLoja+"' 			AND " 
	cSQL += "		EMP      	= '01'                  AND "
	cSQL += "		SA1.D_E_L_E_T_  = '' 					" 
	U_BIAMsgRun("Aguarde... Gerando Base... Titulos por Cliente...",,{|| TcSQLExec(cSQL)})*/
	
	_aRet	:= {}

	U_BIAMsgRun("Aguarde... Gerando Base... Titulos por Cliente...",,{|| _aRet := TCSPEXEC("SP_POSCLI_SE1",nTmpSA1,cCliente,cLoja,'','', '', '', '') })	      
	
	If Type("_aRet") == "A" .And. Len(_aRet) > 0
		If _aRet[1] == 0
		MsgStop("Ocorreu problema na geração dos Titulos por Cliente. Tente novamente.","Posição Cliente")		
		Return
		EndIf
	EndIf
	
	nTmpSE1C := _aRet[2]

	//Apura informaacoes por CLIENTE ou GRUPO CLIENTE (GRUPO OU CLIENTE QUADRO 1) - (GRUPO QUADRO 3)
	cSQL := ""
	cSQL += "SELECT									"  + Enter
	cSQL += "		MAX(A1_LC)AS A1_LC, 			"  + Enter
	cSQL += "		SUM(A1_SALDUP) AS A1_SALDUP,	"  + Enter
	cSQL += "		MAX(A1_MATR) AS A1_MATR, 		"  + Enter
	cSQL += "		MAX(A1_METR) AS A1_METR, 		"  + Enter
	cSQL += "		MAX(A1_VENCLC) AS A1_VENCLC, 	"  + Enter
	cSQL += "		MAX(A1_RISCO) AS A1_RISCO, 		"  + Enter
	//cSQL += "		A1_PRICOM = CASE WHEN MIN(PRICOM) = 'XXXXXX' THEN '' Else MIN(PRICOM) END,				"  + Enter
	cSQL += "		MIN(PRIMCOMPRA.F2_EMISSAO)   AS A1_PRICOM,			"  + Enter
	cSQL += "		MAX(MAIORCOMPRA.F2_EMISSAO)  AS DATAMAIORCOMPRA,	"  + Enter
	cSQL += "		MAX(MAIORCOMPRA.F2_VALBRUT)  AS A1_MCOMPRA,			"  + Enter
	cSQL += "		MAX(ULTIMACOMPRA.F2_EMISSAO) AS A1_ULTCOM,			"  + Enter
	cSQL += "		MAX(ULTIMACOMPRA.F2_VALBRUT) AS VALORULTIMACOMPRA,	"  + Enter
	cSQL += "		SUM(A1_MSALDO) AS A1_MSALDO,	"  + Enter
	
	If Alltrim(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		cSQL += "		(SELECT MAX(DATEDIFF(D,E1_VENCTO,E1_BAIXA)) MAIOR_ATZ FROM "+nTmpSE1G+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE+E1_LOJA IN (SELECT A1_COD+A1_LOJA FROM "+nTmpSA1+" WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND D_E_L_E_T_ = '') AND E1_TIPO IN ('NF','FT','CH','ST','TEL') AND  E1_BAIXA <> '' AND E1_FATURA IN ('','NOTFAT') AND D_E_L_E_T_ = '')  AS MAIOR_ATR, "  + Enter
		cSQL += "		(SELECT ROUND(AVG(CONVERT(FLOAT,DATEDIFF(D,E1_VENCTO,E1_BAIXA))),2) MEDIA_ATZ FROM "+nTmpSE1G+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE+E1_LOJA IN (SELECT A1_COD+A1_LOJA FROM "+nTmpSA1+" WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND D_E_L_E_T_ = '') AND E1_TIPO IN ('NF','FT','CH','ST','TEL') AND  E1_BAIXA <> '' AND E1_FATURA IN ('','NOTFAT') AND D_E_L_E_T_ = '')  AS MEDIA_ATR  "  + Enter
		cSQL += "FROM 																														"  + Enter
		cSQL += "		"+nTmpSA1+" AS A1 LEFT JOIN 	"  + Enter
		cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2G+" ORDER BY F2_VALBRUT DESC) AS MAIORCOMPRA  ON A1_COD = MAIORCOMPRA.F2_CLIENTE  AND A1_LOJA = MAIORCOMPRA.F2_LOJA  LEFT JOIN "  + Enter
		cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2G+" ORDER BY F2_EMISSAO ASC)  AS PRIMCOMPRA   ON A1_COD = PRIMCOMPRA.F2_CLIENTE   AND A1_LOJA = PRIMCOMPRA.F2_LOJA   LEFT JOIN "  + Enter
		cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2G+" ORDER BY F2_EMISSAO DESC) AS ULTIMACOMPRA ON A1_COD = ULTIMACOMPRA.F2_CLIENTE AND A1_LOJA = ULTIMACOMPRA.F2_LOJA  "  + Enter									
		CSQL += "	WHERE A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' " + ENTER
		lGrp := .T.
	Else
		cSQL += "		(SELECT MAX(DATEDIFF(D,E1_VENCTO,E1_BAIXA)) MAIOR_ATZ FROM "+nTmpSE1C+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE+E1_LOJA IN (SELECT A1_COD+A1_LOJA FROM "+nTmpSA1+" WHERE  A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+cCliente+"' AND A1_LOJA = '"+cLoja+"' AND D_E_L_E_T_ = '') AND E1_TIPO IN ('NF','FT','CH','ST','TEL') AND  E1_BAIXA <> '' AND E1_FATURA IN ('','NOTFAT') AND D_E_L_E_T_ = '')  AS MAIOR_ATR, "  + Enter
		cSQL += "		(SELECT ROUND(AVG(CONVERT(FLOAT,DATEDIFF(D,E1_VENCTO,E1_BAIXA))),2) MEDIA_ATZ FROM "+nTmpSE1C+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE+E1_LOJA IN (SELECT A1_COD+A1_LOJA FROM "+nTmpSA1+" WHERE  A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+cCliente+"' AND A1_LOJA = '"+cLoja+"' AND D_E_L_E_T_ = '') AND E1_TIPO IN ('NF','FT','CH','ST','TEL') AND  E1_BAIXA <> '' AND E1_FATURA IN ('','NOTFAT') AND D_E_L_E_T_ = '')  AS MEDIA_ATR  "  + Enter
		cSQL += "FROM 																														"  + Enter
		cSQL += "		"+nTmpSA1+" AS A1 LEFT JOIN 	"  + Enter
		cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2C+" ORDER BY F2_VALBRUT DESC) AS MAIORCOMPRA  ON A1_COD = MAIORCOMPRA.F2_CLIENTE  AND A1_LOJA = MAIORCOMPRA.F2_LOJA  LEFT JOIN "  + Enter
		cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2C+" ORDER BY F2_EMISSAO ASC)  AS PRIMCOMPRA   ON A1_COD = PRIMCOMPRA.F2_CLIENTE   AND A1_LOJA = PRIMCOMPRA.F2_LOJA   LEFT JOIN "  + Enter
		cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2C+" ORDER BY F2_EMISSAO DESC) AS ULTIMACOMPRA ON A1_COD = ULTIMACOMPRA.F2_CLIENTE AND A1_LOJA = ULTIMACOMPRA.F2_LOJA  "  + Enter									
		CSQL += "	WHERE A1_COD = '"+cCliente+"' AND A1_LOJA = '"+cLoja+"' " + ENTER
	EndIf

	If chkfile("c_CONS")
		dbSelectArea("c_CONS")
		dbCloseArea()                                        
	EndIf

	TCQUERY cSQL ALIAS "c_CONS" NEW

	//Apura informaacoes por Cliente (CLIENTE QUADRO 2)
	cSQL := ""
	cSQL += "SELECT									"  + Enter
	cSQL += "		MAX(A1_LC)AS A1_LC, 			"  + Enter
	cSQL += "		SUM(A1_SALDUP) AS A1_SALDUP,	"  + Enter
	cSQL += "		MAX(A1_MATR) AS A1_MATR, 		"  + Enter
	cSQL += "		MAX(A1_METR) AS A1_METR, 		"  + Enter
	cSQL += "		MAX(A1_VENCLC) AS A1_VENCLC, 	"  + Enter
	cSQL += "		MAX(A1_RISCO) AS A1_RISCO, 		"  + Enter
	//cSQL += "		A1_PRICOM = CASE WHEN MIN(PRICOM) = 'XXXXXX' THEN '' Else MIN(PRICOM) END,				"  + Enter
	cSQL += "		MIN(PRIMCOMPRA.F2_EMISSAO)   AS A1_PRICOM,			"  + Enter
	cSQL += "		MAX(MAIORCOMPRA.F2_EMISSAO)  AS DATAMAIORCOMPRA,	"  + Enter
	cSQL += "		MAX(MAIORCOMPRA.F2_VALBRUT)  AS A1_MCOMPRA,			"  + Enter
	cSQL += "		MAX(ULTIMACOMPRA.F2_EMISSAO) AS A1_ULTCOM,			"  + Enter
	cSQL += "		MAX(ULTIMACOMPRA.F2_VALBRUT) AS VALORULTIMACOMPRA,	"  + Enter
	cSQL += "		SUM(A1_MSALDO) AS A1_MSALDO,						"  + Enter
	cSQL += "		(SELECT MAX(DATEDIFF(D,E1_VENCTO,E1_BAIXA)) MAIOR_ATZ FROM "+nTmpSE1C+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE+E1_LOJA IN (SELECT A1_COD+A1_LOJA FROM "+nTmpSA1+" WHERE  A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+cCliente+"' AND A1_LOJA = '"+cLoja+"' AND D_E_L_E_T_ = '') AND E1_TIPO IN ('NF','FT','CH','ST','TEL') AND E1_BAIXA <> '' AND E1_FATURA IN ('','NOTFAT') AND D_E_L_E_T_ = '')  AS MAIOR_ATR, "  + Enter
	cSQL += "		(SELECT ROUND(AVG(CONVERT(FLOAT,DATEDIFF(D,E1_VENCTO,E1_BAIXA))),2) MEDIA_ATZ FROM "+nTmpSE1C+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE+E1_LOJA IN (SELECT A1_COD+A1_LOJA FROM "+nTmpSA1+" WHERE  A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+cCliente+"' AND A1_LOJA = '"+cLoja+"' AND D_E_L_E_T_ = '') AND E1_TIPO IN ('NF','FT','CH','ST','TEL') AND E1_BAIXA <> '' AND E1_FATURA IN ('','NOTFAT') AND D_E_L_E_T_ = '')  AS MEDIA_ATR  "  + Enter
	cSQL += "FROM 														"  + Enter
	cSQL += "		"+nTmpSA1+" AS A1 LEFT JOIN 						"  + Enter
	cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2C+" ORDER BY F2_VALBRUT DESC) AS MAIORCOMPRA  ON A1_COD = MAIORCOMPRA.F2_CLIENTE  AND A1_LOJA = MAIORCOMPRA.F2_LOJA  LEFT JOIN "  + Enter
	cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2C+" ORDER BY F2_EMISSAO ASC)  AS PRIMCOMPRA   ON A1_COD = PRIMCOMPRA.F2_CLIENTE   AND A1_LOJA = PRIMCOMPRA.F2_LOJA   LEFT JOIN "  + Enter
	cSQL += "		(SELECT TOP 1 F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT FROM "+nTmpSF2C+" ORDER BY F2_EMISSAO DESC) AS ULTIMACOMPRA ON A1_COD = ULTIMACOMPRA.F2_CLIENTE AND A1_LOJA = ULTIMACOMPRA.F2_LOJA  "  + Enter									
	CSQL += "WHERE A1_COD = '"+cCliente+"' AND A1_LOJA = '"+cLoja+"' 	" + ENTER
	
	If chkfile("TRBCLI")
		dbSelectArea("TRBCLI")
		dbCloseArea()                                        
	EndIf

	TCQUERY cSQL ALIAS "TRBCLI" NEW

	c_CONS->(DbGoTop())
	
	While !c_CONS->(EOF())
	
		RecLock(cAliasTrab,.t.)

		If I = 1
			(cAliasTrab)->CODIGO  		:= I
			(cAliasTrab)->DESCRICAO	:= "Limite Crédito"
			(cAliasTrab)->VALOR		:= TRANS(c_CONS->A1_LC,"@E 9,999,999.99")
			(cAliasTrab)->ESPACO		:= ""
			(cAliasTrab)->DESCRICAO2	:= "Primeira Compra"
			(cAliasTrab)->CONSULTACL	:= SUBSTR(TRBCLI->A1_PRICOM,7,2)+"/" + SUBSTR(TRBCLI->A1_PRICOM,5,2) + "/" + SUBSTR(TRBCLI->A1_PRICOM,1,4)
			(cAliasTrab)->CONSULTAGR	:= Iif(lGrp,SUBSTR(c_CONS->A1_PRICOM,7,2)+"/" + SUBSTR(c_CONS->A1_PRICOM,5,2) + "/" + SUBSTR(c_CONS->A1_PRICOM,1,4),"  /  /  ")
		ElseIf I = 2
			(cAliasTrab)->CODIGO  			:= I
			(cAliasTrab)->DESCRICAO		:= "Saldo Duplicatas"
			//(cAliasTrab)->VALOR				:= TRANS(c_CONS->A1_SALDUP,"@E 9,999,999.99")
			(cAliasTrab)->VALOR				:= TRANS(U_LoadTitAber(.T., "", .T.),"@E 9,999,999.99")
			(cAliasTrab)->ESPACO				:= ""
			(cAliasTrab)->DESCRICAO2		:= "Maior Compra"
			(cAliasTrab)->CONSULTACL	:= TRANS(TRBCLI->A1_MCOMPRA,"@E 9,999,999.99")
			(cAliasTrab)->CONSULTAGR	:= Iif(lGrp,TRANS(c_CONS->A1_MCOMPRA,"@E 9,999,999.99"),TRANS(0,"@E 9,999,999.99"))
		ElseIf I = 3
			(cAliasTrab)->CODIGO  			:= I
			(cAliasTrab)->DESCRICAO		:= "Maior Atraso"
			(cAliasTrab)->VALOR				:= TRANS(c_CONS->MAIOR_ATR,"@E 9,999,999.99")
			(cAliasTrab)->ESPACO				:= ""
			(cAliasTrab)->DESCRICAO2		:= "Data Maior Compra"
			(cAliasTrab)->CONSULTACL	:= SUBSTR(TRBCLI->DATAMAIORCOMPRA,7,2)+"/" + SUBSTR(TRBCLI->DATAMAIORCOMPRA,5,2) + "/" + SUBSTR(TRBCLI->DATAMAIORCOMPRA,1,4)
			(cAliasTrab)->CONSULTAGR	:= Iif(lGrp,SUBSTR(c_CONS->DATAMAIORCOMPRA,7,2)+"/" + SUBSTR(c_CONS->DATAMAIORCOMPRA,5,2) + "/" + SUBSTR(c_CONS->DATAMAIORCOMPRA,1,4),"  /  /  ")
		ElseIf I = 4
			(cAliasTrab)->CODIGO  			:= I
			(cAliasTrab)->DESCRICAO		:= "Médio Atraso"
			(cAliasTrab)->VALOR				:= TRANS(c_CONS->MEDIA_ATR,"@E 9,999,999.99")
			(cAliasTrab)->ESPACO				:= ""
			(cAliasTrab)->DESCRICAO2		:= "Ultima Compra"
			(cAliasTrab)->CONSULTACL	:= TRANS(TRBCLI->VALORULTIMACOMPRA,"@E 9,999,999.99")
			(cAliasTrab)->CONSULTAGR	:= Iif(lGrp,TRANS(c_CONS->VALORULTIMACOMPRA,"@E 9,999,999.99"),TRANS(0,"@E 9,999,999.99") )
		ElseIf I = 5
			(cAliasTrab)->CODIGO  			:= I
			(cAliasTrab)->DESCRICAO		:= "Venc. Limite Crédito"
			(cAliasTrab)->VALOR				:= SUBSTR(c_CONS->A1_VENCLC,7,2)+"/" + SUBSTR(c_CONS->A1_VENCLC,5,2) + "/" + SUBSTR(c_CONS->A1_VENCLC,1,4)
			(cAliasTrab)->ESPACO				:= ""
			(cAliasTrab)->DESCRICAO2		:= "Data Ultima Compra"
			(cAliasTrab)->CONSULTACL	:= SUBSTR(TRBCLI->A1_ULTCOM,7,2)+"/" + SUBSTR(TRBCLI->A1_ULTCOM,5,2) + "/" + SUBSTR(TRBCLI->A1_ULTCOM,1,4)
			(cAliasTrab)->CONSULTAGR	:= Iif(lGrp,SUBSTR(c_CONS->A1_ULTCOM,7,2)+"/" + SUBSTR(c_CONS->A1_ULTCOM,5,2) + "/" + SUBSTR(c_CONS->A1_ULTCOM,1,4),"  /  /  ")
		ElseIf I = 6
			(cAliasTrab)->CODIGO  			:= I
			(cAliasTrab)->DESCRICAO		:= "Grau de Risco"
			(cAliasTrab)->VALOR				:= c_CONS->A1_RISCO
			(cAliasTrab)->ESPACO				:= ""
			(cAliasTrab)->DESCRICAO2		:= "Maior Saldo"
			(cAliasTrab)->CONSULTACL	:= TRANS(TRBCLI->A1_MSALDO,"@E 9,999,999.99")
			(cAliasTrab)->CONSULTAGR	:= Iif(lGrp,TRANS(c_CONS->A1_MSALDO,"@E 9,999,999.99"),TRANS(0,"@E 9,999,999.99"))
			/*ElseIf I = 7
			(cAliasTrab)->CODIGO  			:= I
			(cAliasTrab)->DESCRICAO		:= "Bloqueio"
			(cAliasTrab)->VALOR				:= SA1->A1_YCADEXP
			(cAliasTrab)->ESPACO				:= ""
			(cAliasTrab)->DESCRICAO2		:= "Cadastro Expresso"
			(cAliasTrab)->CONSULTACLI	:= SA1->A1_YCADRL
			(cAliasTrab)->CONSULTAGRU	:= SA1->A1_YCADRL*/
		EndIf

		MsUnlock()

		If I > 5
			c_CONS->(DbSkip())
		EndIf
	
		I ++

	EndDo

	aCampos := {}

	AADD(aCampos,{"DESCRICAO"	, "DESCRIÇÃO" 			,02})
	AADD(aCampos,{"VALOR"		, "VALOR" 				,05})
	AADD(aCampos,{"ESPACO"		, " " 					,03})
	AADD(aCampos,{"DESCRICAO2"	, "DESCRIÇÃO" 			,04})
	AADD(aCampos,{"CONSULTACL"	, "POSIÇÃO CLIENTE" 	,04})
	AADD(aCampos,{"CONSULTAGR"	, "POSIÇÃO GRUPO"   	,04})

	Markbrow()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	MARKBROW    ³ Autor ³BRUNO MADALENO        ³ Data ³ 21/10/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MONTA O OBROWSE PARA LISTAS OS TITULOS                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Markbrow()

	//VARIAVEIS RESPONSAVEIS PELOS PRIMEIROS CAMPOS
	Private sCodigo		:= cCliente //SPACE(20)
	Private sLoja 		:= cLoja //SPACE(15)
	Private sNome 		:= SA1->A1_NOME //SPACE(255)
	//VARIAVEIS RESPONSAVEIS PELOS SEGUNDOS CAMPOS
	Private sCGD_CPF	:= SA1->A1_CGC //SPACE(20)
	Private sTelefone	:= SA1->A1_TEL //SPACE(15)
	Private sVend_Ince	:= SPACE(100)
	Private sVend_Bian	:= SPACE(100)

	//SELECIONANDO OS VENDEDORES DA BIANCOGRES, INCESA E BELLACASA
	cSQL := "SELECT A3_NOME FROM SA3010 WHERE A3_COD = '"+SA1->A1_VEND+"' AND D_E_L_E_T_ = ''  "
	If chkfile("VENDB")
		dbSelectArea("VENDB")   ; dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "VENDB" NEW
	cSQL := "SELECT A3_NOME FROM SA3010 WHERE A3_COD = '"+SA1->A1_YVENDI+"' AND D_E_L_E_T_ = '' "
	If chkfile("VENDI")
		dbSelectArea("VENDI")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "VENDI" NEW
	cSQL := "SELECT A3_NOME FROM SA3010 WHERE A3_COD = '"+SA1->A1_YVENBE1+"' AND D_E_L_E_T_ = '' "
	If chkfile("VENBE")
		dbSelectArea("VENBE")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "VENBE" NEW

	sVend_Ince := ALLTRIM(VENDI->A3_NOME)
	sVend_Bian := ALLTRIM(VENDB->A3_NOME)
	sVend_Bela := ALLTRIM(VENBE->A3_NOME)

	@ 96,42 TO 440,850 DIALOG oEntra66 TITLE "CONSULTA POSIÇÃO DE CLIENTE" //FRMULARIO
	@ 02,03 TO 60 ,343  COLOR CLR_BLACK PIXEL OF oEntra66  // PRIMEIRO FRAME FRAME

	//*************** PRIMEIROS CAMPOS ******************
	@ 010,007 SAY "Código"   			COLOR CLR_BLACK PIXEL ; @ 019,006 GET sCodigo 		Size 25,8 COLOR CLR_BLACK PIXEL
	@ 010,040 SAY "Loja"     			COLOR CLR_BLACK PIXEL ; @ 019,039 GET sLoja			Size 10,8 COLOR CLR_BLACK PIXEL
	@ 010,065 SAY "Nome"     			COLOR CLR_BLACK PIXEL ; @ 019,064 GET sNome   		Size 100,8 COLOR CLR_BLACK PIXEL
	@ 010,170 SAY "CNPJ/CPF"  			COLOR CLR_BLACK PIXEL ; @ 019,169 GET sCGD_CPF 		Size 72,8 COLOR CLR_BLACK PIXEL
	@ 010,250 SAY "Telefone" 			COLOR CLR_BLACK PIXEL ; @ 019,249 GET sTelefone		Size 40,8 COLOR CLR_BLACK PIXEL

	//*************** SEGUNDOS CAMPOS *******************
	@ 032,007 SAY "Vendedor Biancogres" COLOR CLR_BLACK PIXEL; @ 041,006 GET sVend_Bian  	Size 100,8 COLOR CLR_BLACK PIXEL
	@ 032,125 SAY "Vendedor Incesa"     COLOR CLR_BLACK PIXEL; @ 041,124 GET sVend_Ince  	Size 100,8 COLOR CLR_BLACK PIXEL
	@ 032,241 SAY "Vendedor Bellacasa"  COLOR CLR_BLACK PIXEL; @ 041,240 GET sVend_Bela  	Size 100,8 COLOR CLR_BLACK PIXEL

	//*************** CRIANDO BOTOES *******************
	@ 003,347 BUTTON "Tit. Aberto" 			SIZE 55,12 PIXEL ACTION U_LoadTitAber()//U_BIAMsgRun("Títulos em Aberto...",,{|| U_LoadTitAber() })
	@ 018,347 BUTTON "Tit. Recebidos"  		SIZE 55,12 PIXEL ACTION U_BIAMsgRun("Títulos Recebidos...",,{|| LoadTitRec() })
	@ 033,347 BUTTON "Pedidos" 				SIZE 55,12 PIXEL ACTION U_BIAMsgRun("Pedidos...",,{|| LoadPedidos() })
	@ 048,347 BUTTON "Resumo"				SIZE 55,12 PIXEL ACTION U_BIAMsgRun("Resumo Financeiro...",,{|| U_SIT_FIN(sCodigo, sLoja) })
	@ 063,347 BUTTON "Relatório"		SIZE 55,12 PIXEL ACTION U_BIAFR007(sCodigo, sLoja, nTmpSA1)

	// Tiago Rossini Coradini - 02/05/16 - OS: 4647-15 - Vagner Amaro - Consulta CCB
	@ 078,347 BUTTON "Consulta CCB"		SIZE 55,12 PIXEL ACTION U_BIAF033(sCodigo, sLoja)

	@ 57,03	To 165 ,343  COLOR CLR_BLACK PIXEL  // SEGUNDO FRAME FRAME

	@ 64,140 SAY "INFORMAÇÕES GERAIS" COLOR CLR_BLACK PIXEL

	@ 152,345 BUTTON "Sair"  			SIZE 55,12 PIXEL ACTION Close(oEntra66)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta MarkBrowse...                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oBrowse := IW_Browse(75,09,155,335,cAliasTrab,,,acampos)
	ACTIVATE DIALOG oEntra66 ON INIT Eval({|| MsAguarde(), (cAliasTrab)->(DbGoTop()), oBrowse:oBrowse:Refresh(), }) Centered

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VALIDA CODIGO DO CLIENTE
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fVldCli()

	Local lRet := .T.

	If !Empty(Alltrim(cRepAtu))
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+cCliente))
			If !(SA1->A1_VEND    == cRepAtu .Or. A1_YVENDB2 == cRepAtu .Or. A1_YVENDB3 == cRepAtu .Or. ;
					SA1->A1_YVENDI  == cRepAtu .Or. A1_YVENDI2 == cRepAtu .Or. A1_YVENDI3 == cRepAtu .Or. ;
					SA1->A1_YVENBE1 == cRepAtu .Or. A1_YVENBE2 == cRepAtu .Or. A1_YVENBE3 == cRepAtu .Or. ;
					SA1->A1_YVENML1 == cRepAtu .Or. A1_YVENML2 == cRepAtu .Or. A1_YVENML3 == cRepAtu .Or. ;
					SA1->A1_YVENVT1 == cRepAtu .Or. A1_YVENVT2 == cRepAtu .Or. A1_YVENVT3 == cRepAtu .Or. ;
					SA1->A1_YVENVI1 == cRepAtu .Or. A1_YVENPEG == cRepAtu )
				MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
				lRet := .F.
			EndIf
		Else
			MsgStop("Cliente não cadastrado!","Valida Cliente")
			lRet := .F.
		EndIf
	EndIf

Return(lRet)

Static Function fHeaderClick(oBrw, nCol)

	local nCount := 0
	Local aField := {}
	Local nTabOrd := 0
	Static nColClick := 0

	DbSelectArea(oBrw:cAlias)

	aField := (oBrw:cAlias)->(Dbstruct())

	For nCount := 1 To Len(aField)

		If nCount = nCol

			nPos := aScan(aFldOrd, {|x| x[1] == aField[nCount][1]})

			If nCol <> nColClick

				nTabOrd := aFldOrd[nPos, 2]

				nColClick := nCol

				oBrw:SetHeaderImage(nCount, "COLDOWN")

			Else

				nTabOrd := aFldOrd[nPos, 3]

				nColClick := 0

				oBrw:SetHeaderImage(nCount, "COLRIGHT")

			EndIf

			(oBrw:cAlias)->(DbSetOrder(nTabOrd))
			(oBrw:cAlias)->(DbGoTop())

			oBrw:SetFocus()
			oBrw:Refresh()
			oBrw:GoColumn(nCol)

		Else

			oBrw:SetHeaderImage(nCount, "")

		EndIf

	Next

Return()

/*Inicio Pedidos*/

Static Function fRetEmp(cEmp)

	Local cRet := ""

	If cEmp == "BG"

		cRet := "01"

	ElseIf cEmp == "IN"

		cRet := "05"

	ElseIf cEmp == "LM"

		cRet := "07"

	ElseIf cEmp == "VC"

		cRet := "14"

	EndIf

Return(cRet)

Static Function fExecute(nLinha)

	Local aArea := GetArea()
	Local lOpen := .F.

	Local nPosEmp 	:= aScan(_aFieldsPedido,{|x| Alltrim(x[2]) == 'EMP'})
	Local nPosNum	:= aScan(_aFieldsPedido,{|x| Alltrim(x[2]) == 'C5_NUM'})


	Local cEmpPed	:= fRetEmp(oBrowsePed:ACols[nLinha][nPosEmp])
	Local cPedVen	:= oBrowsePed:ACols[nLinha][nPosNum]


	lOpen := cEmpPed <> cEmpAnt

	If lOpen

		EmpChangeTable("SC5", cEmpPed, cEmpAnt, 1)
		EmpChangeTable("Z60", cEmpPed, cEmpAnt, 1)

	EndIf

	DbSelectArea("SC5")
	DbSetOrder(1)
	If SC5->(DbSeek(xFilial("SC5") + cPedVen))

		U_BIAFR006(cEmpPed)

	EndIf

	If lOpen

		EmpChangeTable("SC5", cEmpAnt, cEmpPed, 1)
		EmpChangeTable("Z60", cEmpAnt, cEmpPed, 1)

	EndIf

	RestArea(aArea)

Return()

Static Function LoadPedidos()

	Local 	cSql 		:= ""
	Private cAliasTemp 	:= GetNextAlias()

	DBSELECTAREA("SA1")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SA1")+cCliente+cLoja)


	cSQL := ""
	cSQL += "SELECT * 	" + Enter
	cSQL += "FROM  		" + Enter
	cSQL += "(SELECT A1_COD + ' - ' + A1_NOME AS CLIENTE, 'BG' AS EMP, C5_FILIAL, C5_NUM, C5_YLINHA,C5_CLIENTE, C5_LOJACLI,  MAX(C5_EMISSAO) C5_EMISSAO, " + Enter
	cSQL += "		AVG(C5_YVLTOTP) TOTPEDIDO,  " + Enter
	cSQL += "		SUM(ROUND((ROUND(C6_VALOR-(C6_QTDENT*C6_PRCVEN),2)/C6_VALOR*100)*C6_YVLIMP/100,2)) SALDO  " + Enter
	cSQL += "FROM SC5010 SC5  WITH (NOLOCK), SC6010 SC6  WITH (NOLOCK), SF4010 SF4  WITH (NOLOCK), SA1010 SA1 WITH (NOLOCK) " + Enter
	//ticket 27424 - não restringir por filial logada
	CSQL += "WHERE	1=1 AND
	CSQL += "		SC5.C5_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('01')) AND " + Enter
	CSQL += "		SC6.C6_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('01')) AND " + Enter
	CSQL += "		SF4.F4_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('01')) AND " + Enter
	cSQL += "		SA1.A1_FILIAL	= '"+xFilial("SA1")+"' AND " + Enter
	
	cSQL += "		SC5.C5_NUM		= SC6.C6_NUM AND  " + Enter
	cSQL += "  		SC5.C5_CLIENTE	= SC6.C6_CLI AND  " + Enter
	cSQL += "		SC5.C5_LOJACLI	= SC6.C6_LOJA AND " + Enter
	cSQL += "		SC5.C5_CLIENTE	= SA1.A1_COD AND " + Enter
	cSQL += "		SC5.C5_LOJACLI	= SA1.A1_LOJA AND " + Enter
	cSQL += "		SC6.C6_TES		= SF4.F4_CODIGO AND  " + Enter
	cSQL += "		SC6.C6_VALOR	> 0				AND  " + Enter
	cSQL += "		SC6.C6_BLQ		<>	'R' AND  " + Enter
	//RUBENS JUNIOR - NAO TRAZER PEDIDOS JA FATURADOS
	cSQL += "		(SC6.C6_QTDVEN - SC6.C6_QTDENT <> 0) AND  " + Enter
	cSQL += "		SF4.F4_DUPLIC	=	'S' AND  " + Enter

	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "		A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND " + ENTER
	Else
		CSQL += "		A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	AND " + ENTER
	EndIf

	cSQL += "		SC5.D_E_L_E_T_  = '' AND  " + Enter
	cSQL += "		SC6.D_E_L_E_T_  = '' AND  " + Enter
	cSQL += "		SF4.D_E_L_E_T_  = '' AND " + Enter
	cSQL += "		SA1.D_E_L_E_T_  = '' " + Enter
	cSQL += "GROUP BY  C5_FILIAL, C5_NUM, C5_YLINHA,C5_CLIENTE, C5_LOJACLI, A1_COD, A1_NOME  " + Enter
	cSQL += "UNION  " + Enter
	cSQL += "SELECT A1_COD + ' - ' + A1_NOME AS CLIENTE, 'IN' AS EMP,  C5_FILIAL, C5_NUM, C5_YLINHA,C5_CLIENTE, C5_LOJACLI,  MAX(C5_EMISSAO) C5_EMISSAO, " + Enter
	cSQL += "		AVG(C5_YVLTOTP) TOTPEDIDO,  " + Enter
	cSQL += "		SUM(ROUND((ROUND(C6_VALOR-(C6_QTDENT*C6_PRCVEN),2)/C6_VALOR*100)*C6_YVLIMP/100,2)) SALDO  " + Enter
	cSQL += "FROM SC5050 SC5  WITH (NOLOCK), SC6050 SC6  WITH (NOLOCK), SF4050 SF4  WITH (NOLOCK), SA1050 SA1 WITH (NOLOCK)  " + Enter
	CSQL += "WHERE	1=1 AND
	CSQL += "		SC5.C5_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('05')) AND " + Enter
	CSQL += "		SC6.C6_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('05')) AND " + Enter
	CSQL += "		SF4.F4_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('05')) AND " + Enter
	cSQL += "		SA1.A1_FILIAL	= '"+xFilial("SA1")+"' AND " + Enter
	cSQL += "		SC5.C5_NUM		= SC6.C6_NUM AND  " + Enter
	cSQL += "  		SC5.C5_CLIENTE	= SC6.C6_CLI AND  " + Enter
	cSQL += "		SC5.C5_LOJACLI	= SC6.C6_LOJA AND  " + Enter
	cSQL += "		SC5.C5_CLIENTE	= SA1.A1_COD AND " + Enter
	cSQL += "		SC5.C5_LOJACLI	= SA1.A1_LOJA AND " + Enter
	cSQL += "		SC6.C6_TES		= SF4.F4_CODIGO AND  " + Enter
	cSQL += "		SC6.C6_VALOR	> 0				AND  " + Enter
	cSQL += "		SC6.C6_BLQ		<>	'R' AND  " + Enter
	//RUBENS JUNIOR - NAO TRAZER PEDIDOS JA FATURADOS
	cSQL += "		(SC6.C6_QTDVEN - SC6.C6_QTDENT <> 0) AND  " + Enter
	cSQL += "		SF4.F4_DUPLIC	=	'S' AND  " + Enter

	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "		A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND " + ENTER
	Else
		CSQL += "		A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	AND " + ENTER
	EndIf

	cSQL += "		SC5.D_E_L_E_T_  = '' AND  " + Enter
	cSQL += "		SC6.D_E_L_E_T_  = '' AND  " + Enter
	cSQL += "		SF4.D_E_L_E_T_  = '' AND " + Enter
	cSQL += "		SA1.D_E_L_E_T_  = ''      " + Enter
	cSQL += "GROUP BY  C5_FILIAL, C5_NUM, C5_YLINHA,C5_CLIENTE, C5_LOJACLI, A1_COD, A1_NOME " + Enter
	cSQL += "UNION  " + Enter
	cSQL += "SELECT A1_COD + ' - ' + A1_NOME AS CLIENTE, 'LM' AS EMP,  C5_FILIAL, C5_NUM, C5_YLINHA,C5_CLIENTE, C5_LOJACLI,  MAX(C5_EMISSAO) C5_EMISSAO,  " + Enter
	cSQL += "		AVG(C5_YVLTOTP) TOTPEDIDO,  " + Enter
	cSQL += "		SUM(ROUND((ROUND(C6_VALOR-(C6_QTDENT*C6_PRCVEN),2)/C6_VALOR*100)*C6_YVLIMP/100,2)) SALDO  " + Enter
	cSQL += "FROM SC5070 SC5 WITH (NOLOCK), SC6070 SC6 WITH (NOLOCK), SF4070 SF4 WITH (NOLOCK), SA1070 SA1 WITH (NOLOCK) " + Enter
	CSQL += "WHERE	1=1 AND
	CSQL += "		SC5.C5_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('07')) AND " + Enter
	CSQL += "		SC6.C6_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('07')) AND " + Enter
	CSQL += "		SF4.F4_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('07')) AND " + Enter
	cSQL += "		SA1.A1_FILIAL	= '"+xFilial("SA1")+"' AND " + Enter
	cSQL += "		SC5.C5_NUM		= SC6.C6_NUM AND  " + Enter
	cSQL += "  	SC5.C5_CLIENTE	= SC6.C6_CLI AND  " + Enter
	cSQL += "		SC5.C5_LOJACLI	= SC6.C6_LOJA AND  " + Enter
	cSQL += "		SC5.C5_CLIENTE	= SA1.A1_COD AND " + Enter
	cSQL += "		SC5.C5_LOJACLI	= SA1.A1_LOJA AND " + Enter
	cSQL += "		SC6.C6_TES		= SF4.F4_CODIGO AND  " + Enter
	cSQL += "		SC6.C6_VALOR	> 0				AND  " + Enter
	cSQL += "		SC6.C6_BLQ		<>	'R' AND  " + Enter
	//RUBENS JUNIOR - NAO TRAZER PEDIDOS JA FATURADOS
	cSQL += "		(SC6.C6_QTDVEN - SC6.C6_QTDENT <> 0) AND  " + Enter
	cSQL += "		SF4.F4_DUPLIC	=	'S' AND  " + Enter

	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "		A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND " + ENTER
	Else
		CSQL += "		A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	AND " + ENTER
	EndIf

	cSQL += "		SC5.D_E_L_E_T_  = '' AND  " + Enter
	cSQL += "		SC6.D_E_L_E_T_  = '' AND  " + Enter
	cSQL += "		SF4.D_E_L_E_T_  = '' AND " + Enter
	cSQL += "		SA1.D_E_L_E_T_  = ''      " + Enter
	cSQL += "GROUP BY  C5_FILIAL, C5_NUM, C5_YLINHA,C5_CLIENTE, C5_LOJACLI, A1_COD, A1_NOME " + Enter

	// Vitcer - OS: 2087-14 - Usuário: Clebes Jose Andre
	cSQL += "UNION  " + Enter
	cSQL += "SELECT A1_COD + ' - ' + A1_NOME AS CLIENTE, 'VC' AS EMP,  C5_FILIAL, C5_NUM, C5_YLINHA,C5_CLIENTE, C5_LOJACLI,  MAX(C5_EMISSAO) C5_EMISSAO,  " + Enter
	cSQL += "		AVG(C5_YVLTOTP) TOTPEDIDO,  " + Enter
	cSQL += "		SUM(ROUND((ROUND(C6_VALOR-(C6_QTDENT*C6_PRCVEN),2)/C6_VALOR*100)*C6_YVLIMP/100,2)) SALDO  " + Enter
	cSQL += "FROM SC5140 SC5 WITH (NOLOCK), SC6140 SC6 WITH (NOLOCK), SF4140 SF4 WITH (NOLOCK), SA1140 SA1 WITH (NOLOCK) " + Enter
	CSQL += "WHERE	1=1 AND
	CSQL += "		SC5.C5_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('14')) AND " + Enter
	CSQL += "		SC6.C6_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('14')) AND " + Enter
	CSQL += "		SF4.F4_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('14')) AND " + Enter
	cSQL += "		SA1.A1_FILIAL	= '"+xFilial("SA1")+"' AND " + Enter
	cSQL += "		SC5.C5_NUM		= SC6.C6_NUM AND  " + Enter
	cSQL += "  	SC5.C5_CLIENTE	= SC6.C6_CLI AND  " + Enter
	cSQL += "		SC5.C5_LOJACLI	= SC6.C6_LOJA AND  " + Enter
	cSQL += "		SC5.C5_CLIENTE	= SA1.A1_COD AND " + Enter
	cSQL += "		SC5.C5_LOJACLI	= SA1.A1_LOJA AND " + Enter
	cSQL += "		SC6.C6_TES		= SF4.F4_CODIGO AND  " + Enter
	cSQL += "		SC6.C6_VALOR	> 0				AND  " + Enter
	cSQL += "		SC6.C6_BLQ		<>	'R' AND  " + Enter
	//RUBENS JUNIOR - NAO TRAZER PEDIDOS JA FATURADOS
	cSQL += "		(SC6.C6_QTDVEN - SC6.C6_QTDENT <> 0) AND  " + Enter
	cSQL += "		SF4.F4_DUPLIC	=	'S' AND  " + Enter

	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "		A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND " + ENTER
	Else
		CSQL += "		A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	AND " + ENTER
	EndIf

	cSQL += "		SC5.D_E_L_E_T_  = '' AND  " + Enter
	cSQL += "		SC6.D_E_L_E_T_  = '' AND  " + Enter
	cSQL += "		SF4.D_E_L_E_T_  = '' AND " + Enter
	cSQL += "		SA1.D_E_L_E_T_  = ''      " + Enter
	cSQL += "GROUP BY  C5_FILIAL, C5_NUM, C5_YLINHA,C5_CLIENTE, C5_LOJACLI, A1_COD, A1_NOME) PEDIDO  " + Enter
	cSQL += "WHERE SALDO > 0  " + Enter

	TcQuery cSql New Alias (cAliasTemp)

	If (cAliasTemp)->(EOF())
		MsgAlert("Cliente não possui Pedidos em carteira.")
		(cAliasTemp)->(DbCloseArea())
		Return
	Else
		GridPedidos()
		(cAliasTemp)->(DbCloseArea())
	EndIf

Return()

Static Function GridPedidos()

	Private _aFieldsPed	:= {}
	Private _aDadosPed	:= {}

	//Totais
	PRIVATE NQTDPED		:= 0
	PRIVATE NTOTLIBER 	:= 0
	PRIVATE NTOTPED 	:= 0
	PRIVATE NTOTSALDO 	:= 0

	Private _oField		:= TGDField():New()

	_aDadosPedido 	:= DataPedido()
	_aFieldsPedido	:= FieldPedido()


	@ 96,42 TO 750,1000 DIALOG oEntra03 TITLE "PEDIDOS - CONSULTAR" //FRMULARIO
	@ 02,03 TO 50 ,475  COLOR CLR_BLACK PIXEL // PRIMEIRO FRAME FRAME

	oEntra03:lEscClose := .T.

	If Alltrim(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		@ 010,007 SAY "Grupo "   			COLOR CLR_BLACK PIXEL; @ 025,007 SAY Alltrim(SA1->A1_GRPVEN) COLOR CLR_BLACK PIXEL
		@ 010,083 SAY "Loja"     			COLOR CLR_BLACK PIXEL; @ 025,083 SAY cLoja COLOR CLR_BLACK PIXEL
		@ 010,136 SAY "Nome"     			COLOR CLR_BLACK PIXEL; @ 025,136 SAY Alltrim(Posicione("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI")) COLOR CLR_BLACK PIXEL
	Else
		@ 010,007 SAY "Código"   			COLOR CLR_BLACK PIXEL; @ 025,007 SAY cCliente COLOR CLR_BLACK PIXEL
		@ 010,083 SAY "Loja"     			COLOR CLR_BLACK PIXEL; @ 025,083 SAY cLoja COLOR CLR_BLACK PIXEL
		@ 010,136 SAY "Nome"     			COLOR CLR_BLACK PIXEL; @ 025,136 SAY SA1->A1_NOME COLOR CLR_BLACK PIXEL
	End

	@ 47,03	To 270 ,475  COLOR CLR_BLACK PIXEL  // SEGUNDO FRAME FRAME
	@ 56,190 SAY "INFORMAÇÕES DE PEDIDOS PENDENTES" COLOR CLR_BLACK PIXEL

	//*************** TOTAIS 1 coluna ******************
	@ 267,03  To 325 ,475  COLOR CLR_BLACK PIXEL  // TERCEIRO FRAME FRAME
	@ 277,007 SAY "Qtd. Pedido"  		COLOR CLR_BLACK PIXEL; @ 277,090 SAY TRANS(NQTDPED,"@E 999,999,999") COLOR CLR_BLACK PIXEL
	//@ 287,007 SAY "Valor Liberado" 		; @ 287,090 SAY TRANS(NTOTLIBER,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL

	//*************** TOTAIS 2 coluna******************
	@ 277,200 SAY "Valor Total+Impostos" COLOR CLR_BLACK PIXEL; @ 277,290 SAY TRANS(NTOTPED,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL
	@ 287,200 SAY "Saldo a Liberar"		COLOR CLR_BLACK PIXEL ; @ 287,290 SAY TRANS(NTOTSALDO,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL


	oBrowsePed := MsNewGetDados():New(70,09,260,470, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {},,, "AllwaysTrue",.T., .T., oEntra03, _aFieldsPedido, _aDadosPedido, {|| })
	//oBrowse:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oBrowsePed:oBrowse:BLDBLCLICK := {|| U_BIAMsgRun("Imprimindo pedido de venda...", "Aguarde!", {|| fExecute(oBrowsePed:nAt) }) }

	oBrowsePed:oBrowse:bHeaderClick := {|oBrw, nCol| Sort(nCol, _oField, oBrowsePed, 0) }
	oBrowsePed:oBrowse:lVScroll := .T.
	oBrowsePed:oBrowse:lHScroll := .T.

	__nPosAnt	:= 0
	oBrowsePed:oBrowse:bChange      := {|| __nPosAnt := oBrowsePed:oBrowse:nAt, oBrowsePed:Refresh(), .T.}
	oBrowsePed:oBrowse:SetBlkBackColor({|| IIF(oBrowsePed:oBrowse:nAt == __nPosAnt, RGB(28, 157, 189) , CLR_WHITE) })

	oBrowsePed:Refresh()


	oBrowsePed:oWND:LESCCLOSE := .T.

	//oBrowsePed:oWND:BKEYDOWN := {|| Close(oEntra03)}


	ACTIVATE DIALOG oEntra03 ON INIT Eval({|| MsAguarde(), oBrowsePed:Refresh(), }) Centered

Return()

Static Function FieldPedido()

	Local aRet := {}

	_oField:Clear()

	// Adciona coluna para tratamento de marcacao no grid
	_oField:AddField("EMP")
	_oField:FieldName("EMP"):cTitle := "Empresa"

	_oField:AddField("C5_FILIAL")
	_oField:AddField("C5_NUM")

	//_oField:AddField("C5_YLINHA")
	_oField:AddField("MARCA")
	_oField:FieldName("MARCA"):cTitle := "Marca"
	_oField:FieldName("MARCA"):nSize	:= 20

	_oField:AddField("C5_EMISSAO")

	_oField:AddField("TOTPEDIDO")
	_oField:FieldName("TOTPEDIDO"):cTitle := "Total Pedido+Imp."

	_oField:AddField("SALDO")
	_oField:FieldName("SALDO"):cTitle := "Saldo"
	_oField:FieldName("SALDO"):nSize	:= 15

	_oField:AddField("CLIENTE")
	_oField:FieldName("CLIENTE"):cTitle	:= "Cliente"
	_oField:FieldName("CLIENTE"):nSize	:= 50

	aRet := _oField:GetHeader()

Return(aRet)

Static Function DataPedido()

	Local aDados		:= {}
	Local cLinha		:= ""

	While !(cAliasTemp)->(Eof())

		Do Case
		Case  Alltrim((cAliasTemp)->C5_YLINHA) == "1"
			cLinha		:= "Biancogres"
		Case  Alltrim((cAliasTemp)->C5_YLINHA) == "2"
			cLinha		:= "Incesa"
		Case  Alltrim((cAliasTemp)->C5_YLINHA) == "3"
			cLinha		:= "BellaCasa"
		Case  Alltrim((cAliasTemp)->C5_YLINHA) == "4"
			cLinha		:= "Mundialli"
		EndCase

		aAdd(aDados, {(cAliasTemp)->EMP,  (cAliasTemp)->C5_FILIAL, (cAliasTemp)->C5_NUM, cLinha, ;
			CTOD(SUBSTR((cAliasTemp)->C5_EMISSAO,7,2)+"/" + SUBSTR((cAliasTemp)->C5_EMISSAO,5,2) + "/" + SUBSTR((cAliasTemp)->C5_EMISSAO,1,4)),;
			TRANS((cAliasTemp)->TOTPEDIDO,"@E 999,999,999.99"),;
			TRANS((cAliasTemp)->SALDO,"@E 999,999,999.99"),;
			AllTrim((cAliasTemp)->CLIENTE),  .F.})


		NQTDPED		+= 1
		NTOTPED 	+= (cAliasTemp)->TOTPEDIDO
		NTOTSALDO 	+= (cAliasTemp)->SALDO
		//NTOTLIBER 	+= (cAliasTemp)->LIBERADO

		(cAliasTemp)->(DbSkip())

	EndDo()

Return(aDados)

/*Fim Pedidos*/

/*Titulor a Recebe*/

Static Function LoadTitRec()

	Local 	cSql 		:= ""
	Private cAliasTemp 	:= GetNextAlias()

	DBSELECTAREA("SA1")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SA1")+cCliente+cLoja)


	cSql := "EXEC SP_POSCLI_TITREC '"+cCliente+"','"+cLoja+"','"+SA1->A1_GRPVEN+"','"+SA1->A1_YTIPOLC+"'

	TcQuery cSql New Alias (cAliasTemp)

	If (cAliasTemp)->(EOF())
		MsgAlert("Cliente não possui Recebimentos.")
		(cAliasTemp)->(DbCloseArea())
		Return
	Else
		GridTitRec()
		(cAliasTemp)->(DbCloseArea())
	EndIf

Return()

Static Function GridTitRec()

	Private _aFieldsTitRec	:= {}
	Private _aDadosTitRec	:= {}

	//Totais
	Private NQTDPAGA	:= 0
	Private NVALORPAGA 	:= 0
	Private NPRINCIPAL 	:= 0

	Private _oField		:= TGDField():New()

	_aDadosTitRec 	:= DataTitRec()
	_aFieldsTitRec	:= FieldTitRec()


	@ 96,42 TO 750,1000 DIALOG oEntra02 TITLE "TITULOS RECEBIDOS" //FRMULARIO
	@ 02,03 TO 50 ,475  COLOR CLR_BLACK PIXEL // PRIMEIRO FRAME FRAME

	If Alltrim(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		@ 010,007 SAY "Grupo "   			COLOR CLR_BLACK PIXEL; @ 025,007 SAY Alltrim(SA1->A1_GRPVEN) COLOR CLR_BLACK PIXEL
		@ 010,083 SAY "Loja"     			COLOR CLR_BLACK PIXEL; @ 025,083 SAY cLoja COLOR CLR_BLACK PIXEL
		@ 010,136 SAY "Nome"     			COLOR CLR_BLACK PIXEL; @ 025,136 SAY Alltrim(Posicione("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI")) COLOR CLR_BLACK PIXEL
	Else
		@ 010,007 SAY "Código"   			COLOR CLR_BLACK PIXEL; @ 025,007 SAY cCliente COLOR CLR_BLACK PIXEL
		@ 010,083 SAY "Loja"     			COLOR CLR_BLACK PIXEL; @ 025,083 SAY cLoja COLOR CLR_BLACK PIXEL
		@ 010,136 SAY "Nome"     			COLOR CLR_BLACK PIXEL; @ 025,136 SAY SA1->A1_NOME COLOR CLR_BLACK PIXEL
	End

	@ 47,03	To 270 ,475   COLOR CLR_BLACK PIXEL // SEGUNDO FRAME FRAME
	@ 56,190 SAY "INFORMAÇÕES DOS TITULOS RECEBIDOS" COLOR CLR_BLACK PIXEL

	//*************** TOTAIS 1 coluna ******************
	@ 267,03  To 325 ,475   COLOR CLR_BLACK PIXEL // TERCEIRO FRAME FRAME
	@ 277,007 SAY "Qtd. Pag. "  		COLOR CLR_BLACK PIXEL; @ 277,090 SAY TRANS(NQTDPAGA,  "@E 999,999,999") COLOR CLR_BLACK PIXEL
	@ 287,007 SAY "Valor Pag."     		COLOR CLR_BLACK PIXEL; @ 287,090 SAY TRANS(NVALORPAGA,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL

	//*************** TOTAIS 2 coluna******************
	@ 277,200 SAY "Principal"   		COLOR CLR_BLACK PIXEL; @ 277,290 SAY TRANS(NPRINCIPAL,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL


	oBrowseRec := MsNewGetDados():New(70,09,260,470, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {},,, "AllwaysTrue",.T., .T., oEntra02, _aFieldsTitRec, _aDadosTitRec)
	//oBrowse:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseRec:oBrowse:bHeaderClick := {|oBrw, nCol| Sort(nCol, _oField, oBrowseRec, 0) }
	oBrowseRec:oBrowse:lVScroll := .T.
	oBrowseRec:oBrowse:lHScroll := .T.

	__nPosAnt	:= 0
	oBrowseRec:oBrowse:bChange      := {|| __nPosAnt := oBrowseRec:oBrowse:nAt, oBrowseRec:Refresh(), .T.}
	oBrowseRec:oBrowse:SetBlkBackColor({|| IIF(oBrowseRec:oBrowse:nAt == __nPosAnt, RGB(28, 157, 189) , CLR_WHITE) })


	oBrowseRec:Refresh()
	oBrowseRec:oWND:LESCCLOSE := .T.


	//ordenação inicial
	_nPosVenc	:= aScan(_aFieldsTitRec,{|x| Alltrim(x[2]) == 'E1_VENCTO'})
	Sort(_nPosVenc, _oField, oBrowseRec, 1)


	ACTIVATE DIALOG oEntra02 ON INIT Eval({|| MsAguarde(), oBrowseRec:Refresh(), }) Centered

Return()

Static Function FieldTitRec()

	Local aRet := {}

	_oField:Clear()

	//“Tít. Aberto” e “Tít. Recebidos”: Empresa, Prefixo, Nº do título, Parcela, Tipo, Dt. Emissão, Vencimento, Valor, Atraso, Histórico, Cliente, Portador e Nº no banco.

	// Adciona coluna para tratamento de marcacao no grid
	_oField:AddField("EMP")
	_oField:FieldName("EMP"):cTitle := "Empresa"

	_oField:AddField("E1_FILIAL")
	_oField:AddField("E1_PREFIXO")
	_oField:AddField("E1_NUM")
	_oField:AddField("E1_PARCELA")
	_oField:AddField("E1_TIPO")
	_oField:AddField("E1_EMISSAO")
	_oField:AddField("E1_VENCTO")
	_oField:AddField("E1_VALOR")

	_oField:AddField("ATRASO")
	_oField:FieldName("ATRASO"):cTitle := "Atraso"
	_oField:FieldName("ATRASO"):cPict := "@E 999,999.99"

	_oField:AddField("E1_HIST")

	_oField:AddField("CLIENTE")
	_oField:FieldName("CLIENTE"):cTitle	:= "Cliente"
	_oField:FieldName("CLIENTE"):nSize	:= 50

	_oField:AddField("E1_PORTADO")
	_oField:AddField("E1_NUMBCO")


	aRet := _oField:GetHeader()

Return(aRet)

Static Function DataTitRec()

	Local aDados		:= {}

	While !(cAliasTemp)->(Eof())

		aAdd(aDados, {(cAliasTemp)->EMP, (cAliasTemp)->E1_FILIAL, (cAliasTemp)->E1_PREFIXO, (cAliasTemp)->E1_NUM, (cAliasTemp)->E1_PARCELA, (cAliasTemp)->E1_TIPO, ;
			CTOD(SUBSTR((cAliasTemp)->E1_EMISSAO,7,2)+"/" + SUBSTR((cAliasTemp)->E1_EMISSAO,5,2) + "/" + SUBSTR((cAliasTemp)->E1_EMISSAO,1,4)),;
			CTOD(SUBSTR((cAliasTemp)->E1_VENCTO,7,2)+"/"  + SUBSTR((cAliasTemp)->E1_VENCTO,5,2)  + "/" + SUBSTR((cAliasTemp)->E1_VENCTO,1,4)),;
			((cAliasTemp)->E1_VALOR - (cAliasTemp)->E1_SALDO),(cAliasTemp)->ATRASO, (cAliasTemp)->E1_HIST,;
			AllTrim((cAliasTemp)->CLIENTE), (cAliasTemp)->E1_PORTADO, (cAliasTemp)->E1_NUMBCO, ;
			.F.})


		NQTDPAGA	+= 1
		NVALORPAGA 	+= ((cAliasTemp)->E1_VALOR - (cAliasTemp)->E1_SALDO)
		NPRINCIPAL 	+= (cAliasTemp)->E1_VALOR

		(cAliasTemp)->(DbSkip())

	EndDo()

Return(aDados)

/**/

/*Titulo Abertos*/

User Function LoadTitAber(lReport, cCodVen, lSaldo)

	Local cSQL			:= ""
	Local nSaldoTot	:= 0
	Default lSaldo	:= .F.

	Private cAliasTemp 	:= GetNextAlias()
	Private Enter 		:= CHR(13)+CHR(10)

	DBSELECTAREA("SA1")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SA1")+cCliente+cLoja)

	// Identifica se a função esta sendo chamada pelo relatorio, caso esteja, não exibe a tela e efetua o somatorio dos valores
	If ValType(lReport) <> "U" .And. lReport

		cSQL += " SELECT SUM(E1_VALOR) AS E1_VALOR, SUM(E1_SALDO) AS E1_SALDO, SUM(E1_ACRESC) AS E1_ACRESC, SUM(E1_JUROS) AS E1_JUROS, SUM(E1_DECRESC) AS E1_DECRESC "
		cSQL += " FROM ( "

	EndIf

	cSQL += "SELECT 	A1_COD + ' - ' + A1_NOME AS CLIENTE,'BG' AS EMP, LEGENDA = CASE  "  + Enter

	cSQL += "		 	WHEN CONVERT(date, GETDATE()) > CONVERT(date, E1_VENCTO)  THEN 'VENCIDO'  "  + Enter

	cSQL += "		 	WHEN E1_SALDO = E1_VALOR THEN 'SEM BAIXA'  "  + Enter

	cSQL += "		 	Else 'BAIXA PARCIAL'  "  + Enter
	cSQL += "		END,  "  + Enter
	cSQL += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_SALDO, E1_ACRESC, E1_JUROS, E1_DECRESC,  "  + Enter
	cSQL += "	E1_VENCTO, E1_VALOR, E1_PORTADO, E1_NUMBCO, E1_HIST, E1_FATURA, E1_FATPREF, E1_YPARCFT, DATEDIFF(D,E1_VENCTO,GETDATE()) ATRASO, E1_VEND1 "  + Enter
	cSQL += "FROM SE1010 SE1 WITH (NOLOCK), "+nTmpSA1+" SA1 "  + Enter

	cSQL += " WHERE E1_FILIAL IN (SELECT FILIAL FROM FNC_FILIAL('01')) " + ENTER

	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += " AND A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND " + ENTER
	Else
		CSQL += " AND A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	AND " + ENTER
	EndIf

	cSQL += "		E1_CLIENTE 	= A1_COD AND E1_LOJA = A1_LOJA AND			"  + Enter
	cSQL += "		E1_SALDO 	> 0		AND  								"  + Enter
	cSQL += "		EMP      	= '01'	AND  								"  + Enter
	cSQL += "		E1_TIPO IN ('NF','FT','RA','CH','ST','NCC','NDC','BOL','TEL') 	AND	"  + Enter // Carlos Junqueira
	//cSQL += "		E1_TIPO IN ('NF','FT','RA','CH','ST')  	AND	"  + Enter
	cSQL += "		SE1.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = ''		"  + Enter
	cSQL += "UNION ALL  "  + Enter
	cSQL += "SELECT 	A1_COD + ' - ' + A1_NOME AS CLIENTE, 'IN' AS EMP, LEGENDA = CASE  "  + Enter

	cSQL += "		 	WHEN CONVERT(date, GETDATE()) > CONVERT(date, E1_VENCTO)  THEN 'VENCIDO'  "  + Enter

	cSQL += "		 	WHEN E1_SALDO = E1_VALOR THEN 'SEM BAIXA'  "  + Enter

	cSQL += "		 	Else 'BAIXA PARCIAL'  "  + Enter
	cSQL += "		END,  "  + Enter
	cSQL += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_SALDO, E1_ACRESC, E1_JUROS, E1_DECRESC,  "  + Enter
	cSQL += "	E1_VENCTO, E1_VALOR, E1_PORTADO, E1_NUMBCO, E1_HIST, E1_FATURA, E1_FATPREF, E1_YPARCFT, DATEDIFF(D,E1_VENCTO,GETDATE()) ATRASO, E1_VEND1 "  + Enter
	cSQL += "FROM SE1050 SE1 WITH (NOLOCK), "+nTmpSA1+" SA1 "  + Enter

	cSQL += " WHERE E1_FILIAL IN (SELECT FILIAL FROM FNC_FILIAL('05')) " + ENTER

	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += " AND A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND " + ENTER
	Else
		CSQL += " AND A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	AND " + ENTER
	EndIf

	cSQL += "		E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND			"  + Enter
	cSQL += "		E1_SALDO 	> 0		AND  								"  + Enter
	cSQL += "		EMP      	= '05'	AND  								"  + Enter
	cSQL += "		E1_TIPO IN ('NF','FT','RA','CH','ST','NCC','NDC','BOL','TEL') 	AND	"  + Enter // Carlos Junqueira
	//cSQL += "		E1_TIPO IN ('NF','FT','RA','CH','ST')  	AND	"  + Enter
	cSQL += "		SE1.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' 	"  + Enter
	cSQL += "UNION ALL "  + Enter
	cSQL += "SELECT 	A1_COD + ' - ' + A1_NOME AS CLIENTE, 'LM' AS EMP, LEGENDA = CASE  "  + Enter

	cSQL += "		 	WHEN CONVERT(date, GETDATE()) > CONVERT(date, E1_VENCTO)  THEN 'VENCIDO'  "  + Enter

	cSQL += "		 	WHEN E1_SALDO = E1_VALOR THEN 'SEM BAIXA'  "  + Enter

	cSQL += "		 	Else 'BAIXA PARCIAL'  "  + Enter
	cSQL += "		END,  "  + Enter
	cSQL += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_SALDO, E1_ACRESC, E1_JUROS, E1_DECRESC,  "  + Enter
	cSQL += "	E1_VENCTO, E1_VALOR, E1_PORTADO, E1_NUMBCO, E1_HIST, E1_FATURA, E1_FATPREF, E1_YPARCFT, DATEDIFF(D,E1_VENCTO,GETDATE()) ATRASO, E1_VEND1 "  + Enter
	cSQL += "FROM SE1070 SE1 WITH (NOLOCK), "+nTmpSA1+" SA1 "  + Enter

	cSQL += " WHERE E1_FILIAL IN (SELECT FILIAL FROM FNC_FILIAL('07')) " + ENTER

	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += " AND A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND " + ENTER
	Else
		CSQL += " AND A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	AND " + ENTER
	EndIf

	cSQL += "		E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND "  + Enter
	cSQL += "		E1_SALDO > 0		AND  "  + Enter
	cSQL += "		EMP      = '07'		AND  "  + Enter
	cSQL += "		E1_TIPO IN ('NF','FT','RA','CH','ST','NCC','NDC','BOL','TEL') 	AND	"  + Enter // Carlos Junqueira
	//cSQL += "		E1_TIPO IN ('NF','FT','RA','CH','ST')  	AND  "  + Enter
	cSQL += "		SE1.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' "  + Enter

	// Vitcer - OS: 2087-14 - Usuário: Clebes Jose Andre
	cSQL += "UNION ALL "  + Enter
	cSQL += "SELECT 	A1_COD + ' - ' + A1_NOME AS CLIENTE, 'VC' AS EMP, LEGENDA = CASE  "  + Enter

	cSQL += "		 	WHEN CONVERT(date, GETDATE()) > CONVERT(date, E1_VENCTO)  THEN 'VENCIDO'  "  + Enter

	cSQL += "		 	WHEN E1_SALDO = E1_VALOR THEN 'SEM BAIXA'  "  + Enter

	cSQL += "		 	Else 'BAIXA PARCIAL'  "  + Enter
	cSQL += "		END,  "  + Enter
	cSQL += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_SALDO, E1_ACRESC, E1_JUROS, E1_DECRESC,  "  + Enter
	cSQL += "	E1_VENCTO, E1_VALOR, E1_PORTADO, E1_NUMBCO, E1_HIST, E1_FATURA, E1_FATPREF, E1_YPARCFT, DATEDIFF(D,E1_VENCTO,GETDATE()) ATRASO, E1_VEND1 "  + Enter
	cSQL += "FROM SE1140 SE1 WITH (NOLOCK), "+nTmpSA1+" SA1 "  + Enter

	cSQL += " WHERE E1_FILIAL IN (SELECT FILIAL FROM FNC_FILIAL('14')) " + ENTER

	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += " AND A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND " + ENTER
	Else
		CSQL += " AND A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	AND " + ENTER
	EndIf

	cSQL += "		E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND "  + Enter
	cSQL += "		E1_SALDO > 0		AND  "  + Enter
	cSQL += "		EMP      = '14'		AND  "  + Enter
	cSQL += "		E1_TIPO IN ('NF','FT','RA','CH','ST','NCC','NDC','BOL','TEL') 	AND	"  + Enter // Carlos Junqueira
	//cSQL += "		E1_TIPO IN ('NF','FT','RA','CH','ST')  	AND  "  + Enter
	cSQL += "		SE1.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' "  + Enter


	If ValType(lReport) <> "U" .And. lReport

		cSQL += " ) TITREC "

		If !lSaldo
			cSQL += " WHERE E1_VEND1 IN ('999999', "+ ValToSQL(cCodVen) + ")"
		EndIf

		cSQL += " GROUP BY E1_VEND1 "

	EndIf

	TcQuery cSql New Alias (cAliasTemp)

	If (cAliasTemp)->(EOF())

		nTitAbe := 0

		If ValType(lReport) <> "U" .And. lReport
			nTitAbe := 0
		Else
			MsgAlert("Cliente não possui títulos em aberto.")
		EndIf

		(cAliasTemp)->(DbCloseArea())

		Return(nTitAbe)

	EndIf

	If lSaldo

		While (cAliasTemp)->(!EOF())

			nSaldoTot += (cAliasTemp)->E1_SALDO

			(cAliasTemp)->(DBSkip())

		EndDo

		Return(nSaldoTot)

	Else

		If ValType(lReport) <> "U" .And. lReport

			nTitAbe := (cAliasTemp)->E1_SALDO

		Else

			GridTitAber()

		EndIf

	EndIf

	(cAliasTemp)->(DbCloseArea())

Return()

Static Function FatTitAber(nLinha)

	Local nPosEmp 	:= aScan(_aFieldsTitAber,{|x| Alltrim(x[2]) == 'EMP'})
	Local nPosTipo	:= aScan(_aFieldsTitAber,{|x| Alltrim(x[2]) == 'E1_TIPO'})
	Local nPosNum	:= aScan(_aFieldsTitAber,{|x| Alltrim(x[2]) == 'E1_NUM'})
	Local nPosPre	:= aScan(_aFieldsTitAber,{|x| Alltrim(x[2]) == 'E1_PREFIXO'})
	Local nPosYPar	:= aScan(_aFieldsTitAber,{|x| Alltrim(x[2]) == 'E1_YPARCFT'})

	Local _cEmp		:= oBrowsePedAber:ACols[nLinha][nPosEmp]
	Local _cTipo	:= oBrowsePedAber:ACols[nLinha][nPosTipo]
	Local _cNum		:= oBrowsePedAber:ACols[nLinha][nPosNum]
	Local _cPre		:= oBrowsePedAber:ACols[nLinha][nPosPre]
	Local _cYpar	:= oBrowsePedAber:ACols[nLinha][nPosYPar]

	//Verifica se o Titulo e uma Fatura
	If ALLTRIM(_cTipo) <> "FT"
		Alert("Selecione um Número de Fatura!")
		Return
	EndIf

	//Determina a Empresa
	If ALLTRIM(_cEmp) == "BG"
		_cEmp := "01"
	ElseIf ALLTRIM(_cEmp) == "IN"
		_cEmp := "05"
	ElseIf ALLTRIM(_cEmp) == "LM"
		_cEmp := "07"
	ElseIf ALLTRIM(_cEmp) == "VC"
		_cEmp := "14"
	Else
		_cEmp := cEmpAnt
	EndIf

	//Chama tela de Consulta Fatura
	U_INC135(_cNum, _cPre, _cYpar, _cEmp, .F.)

Return()

Static Function GridTitAber()

	Private _aFieldsTitAber	:= {}
	Private _aDadosTitAber	:= {}

	//Totais
	Private NQTDTIT 	:= 0
	Private NSALDO		:= 0
	Private NACRESCIMO	:= 0
	Private NABATIMEN	:= 0
	Private NPRINCIPAL	:= 0
	Private NJUROS 		:= 0
	Private NDECRES 	:= 0
	Private NTOTALG		:= 0

	Private _oField		:= TGDField():New()

	_aDadosTitAber 	:= DataTitAber()
	_aFieldsTitAber	:= FieldTitAber(.T.)

	@ 96,42 TO 750,1000 DIALOG oEntra01 TITLE "TITULOS EM ABERTO" //FRMULARIO
	@ 02,03 TO 50 ,475  COLOR CLR_BLACK PIXEL // PRIMEIRO FRAME FRAME

	If Alltrim(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		@ 010,007 SAY "Grupo "   			COLOR CLR_BLACK PIXEL; @ 025,007 SAY Alltrim(SA1->A1_GRPVEN) COLOR CLR_BLACK PIXEL
		@ 010,083 SAY "Loja"     			COLOR CLR_BLACK PIXEL; @ 025,083 SAY cLoja COLOR CLR_BLACK PIXEL
		@ 010,136 SAY "Nome"     			COLOR CLR_BLACK PIXEL ; @ 025,136 SAY Alltrim(Posicione("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI")) COLOR CLR_BLACK PIXEL
	Else
		@ 010,007 SAY "Código"   			COLOR CLR_BLACK PIXEL; @ 025,007 SAY cCliente COLOR CLR_BLACK PIXEL
		@ 010,083 SAY "Loja"     			COLOR CLR_BLACK PIXEL; @ 025,083 SAY cLoja COLOR CLR_BLACK PIXEL
		@ 010,136 SAY "Nome"     			COLOR CLR_BLACK PIXEL; @ 025,136 SAY SA1->A1_NOME COLOR CLR_BLACK PIXEL
	End

	@ 47,03	To 270 ,475   COLOR CLR_BLACK PIXEL // SEGUNDO FRAME FRAME
	@ 52, 10 BITMAP oBMAP1 RESNAME "BR_VERDE" SIZE 16,16 NOBORDER PIXEL
	@ 52, 18 SAY "SEM BAIXA" COLOR CLR_BLACK PIXEL

	@ 52, 60 BITMAP oBMAP1 RESNAME "BR_VERMELHO" SIZE 16,16 NOBORDER PIXEL
	@ 52, 68 SAY "VENCIDO" COLOR CLR_BLACK PIXEL


	@ 60, 10 BITMAP oBMAP2 RESNAME "BR_AMARELO" SIZE 16,16 NOBORDER PIXEL
	@ 60, 18 SAY "BAIXA PARCIAL" COLOR CLR_BLACK PIXEL

	@ 56,190 SAY "INFORMAÇÕES DOS TITULOS EM ABERTO" COLOR CLR_BLACK PIXEL

	//*************** TOTAIS 1 coluna ******************
	@ 267,03  To 325 ,475  COLOR CLR_BLACK PIXEL  // TERCEIRO FRAME FRAME
	@ 277,007 SAY "Qtd. Titulos "  		COLOR CLR_BLACK PIXEL; @ 277,090 SAY TRANS(NQTDTIT,"@E 999,999,999") COLOR CLR_BLACK PIXEL
	@ 287,007 SAY "Saldo "     			COLOR CLR_BLACK PIXEL; @ 287,090 SAY TRANS(NSALDO,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL
	@ 297,007 SAY "Acrescimo "   		COLOR CLR_BLACK PIXEL; @ 297,090 SAY TRANS(NACRESCIMO,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL
	@ 307,007 SAY "Abatimentos "     	COLOR CLR_BLACK PIXEL; @ 307,090 SAY TRANS(NABATIMEN,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL

	//*************** TOTAIS 2 coluna******************
	@ 277,200 SAY "Principal"   		COLOR CLR_BLACK PIXEL; @ 277,290 SAY TRANS(NPRINCIPAL,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL
	@ 287,200 SAY "Juros"     			COLOR CLR_BLACK PIXEL; @ 287,290 SAY TRANS(NJUROS,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL
	@ 297,200 SAY "Decrescimo"   		COLOR CLR_BLACK PIXEL; @ 297,290 SAY TRANS(NDECRES,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL
	@ 307,200 SAY "Tot. Geral"       	COLOR CLR_BLACK PIXEL ; @ 307,290 SAY TRANS(NTOTALG,"@E 999,999,999.99") COLOR CLR_BLACK PIXEL

	_aFieldsNovo :=  FieldTitAber(.F.)

	oBrowsePedAber := MsNewGetDados():New(70,09,260,470, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {},,, "AllwaysTrue",.T., .T., oEntra01, _aFieldsNovo, _aDadosTitAber)
	//oBrowse:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowsePedAber:oBrowse:bLDblClick := {|| FatTitAber(oBrowsePedAber:nAt) }
	oBrowsePedAber:oBrowse:bHeaderClick := {|oBrw, nCol| Sort(nCol, _oField, oBrowsePedAber, 0) }
	oBrowsePedAber:oBrowse:lVScroll := .T.
	oBrowsePedAber:oBrowse:lHScroll := .T.

	__nPosAnt	:= 0
	oBrowsePedAber:oBrowse:bChange      := {|| __nPosAnt := oBrowsePedAber:oBrowse:nAt, oBrowsePedAber:Refresh(), .T.}
	oBrowsePedAber:oBrowse:SetBlkBackColor({|| IIF(oBrowsePedAber:oBrowse:nAt == __nPosAnt, RGB(28, 157, 189) , CLR_WHITE) })

	oBrowsePedAber:Refresh()
	oBrowsePedAber:oWND:LESCCLOSE := .T.

	//ordenação inicial
	_nPosVenc	:= aScan(_aFieldsNovo,{|x| Alltrim(x[2]) == 'E1_VENCTO'})
	Sort(_nPosVenc, _oField, oBrowsePedAber, 2)

	ACTIVATE DIALOG oEntra01 ON INIT Eval({|| MsAguarde(), oBrowsePedAber:Refresh(), }) Centered

Return()

Static Function FieldTitAber(lOpc)

	Local aRet := {}

	_oField:Clear()

	// Adciona coluna para tratamento de marcacao no grid
	_oField:AddField("LEGENDA")
	_oField:FieldName("LEGENDA"):cTitle := "Legenda"
	_oField:FieldName("LEGENDA"):cPict := "@BMP"


	_oField:AddField("EMP")
	_oField:FieldName("EMP"):cTitle := "Empresa"

	_oField:AddField("E1_FILIAL")
	_oField:AddField("E1_PREFIXO")
	_oField:AddField("E1_NUM")
	_oField:AddField("E1_PARCELA")
	_oField:AddField("E1_TIPO")
	_oField:AddField("E1_EMISSAO")
	_oField:AddField("E1_VENCTO")
	_oField:AddField("E1_VALOR")
	_oField:AddField("E1_SALDO")

	_oField:AddField("ATRASO")
	_oField:FieldName("ATRASO"):cTitle := "Atraso"
	_oField:FieldName("ATRASO"):cPict := "@E 999,999.99"

	_oField:AddField("E1_HIST")

	_oField:AddField("CLIENTE")
	_oField:FieldName("CLIENTE"):cTitle	:= "Cliente"
	_oField:FieldName("CLIENTE"):nSize	:= 50

	_oField:AddField("E1_PORTADO")
	_oField:AddField("E1_NUMBCO")

	If (lOpc)

		_oField:AddField("E1_FATURA")
		//_oField:FieldName("E1_FATURA"):cVisual := 'V'

		_oField:AddField("E1_FATPREF")
		//_oField:FieldName("E1_FATPREF"):cVisual := 'V'

		_oField:AddField("E1_YPARCFT")
		//_oField:FieldName("E1_YPARCFT"):cVisual := 'V'

	EndIf

	aRet := _oField:GetHeader()

Return(aRet)

Static Function DataTitAber()

	Local aDados		:= {}
	Local cLegenda		:= ""

	While !(cAliasTemp)->(Eof())

		If (AllTrim((cAliasTemp)->LEGENDA) == 'SEM BAIXA')
			cLegenda := 'BR_VERDE'
		Else
			cLegenda := 'BR_AMARELO'
		EndIf

		If (AllTrim((cAliasTemp)->LEGENDA) == 'VENCIDO')
			cLegenda := 'BR_VERMELHO'
		EndIf

		//

		aAdd(aDados, { cLegenda, (cAliasTemp)->EMP, (cAliasTemp)->E1_FILIAL, (cAliasTemp)->E1_PREFIXO, (cAliasTemp)->E1_NUM, (cAliasTemp)->E1_PARCELA, (cAliasTemp)->E1_TIPO,;
			CTOD(SUBSTR((cAliasTemp)->E1_EMISSAO,7,2)+"/" + SUBSTR((cAliasTemp)->E1_EMISSAO,5,2) + "/" + SUBSTR((cAliasTemp)->E1_EMISSAO,1,4)),;
			CTOD(SUBSTR((cAliasTemp)->E1_VENCTO,7,2)+"/"  + SUBSTR((cAliasTemp)->E1_VENCTO,5,2)  + "/" + SUBSTR((cAliasTemp)->E1_VENCTO,1,4)),;
			(cAliasTemp)->E1_VALOR, (cAliasTemp)->E1_SALDO, (cAliasTemp)->ATRASO, (cAliasTemp)->E1_HIST, AllTrim((cAliasTemp)->CLIENTE), (cAliasTemp)->E1_PORTADO, (cAliasTemp)->E1_NUMBCO, ;
			(cAliasTemp)->E1_FATURA, (cAliasTemp)->E1_FATPREF, (cAliasTemp)->E1_PARCELA, .F.})


		NQTDTIT 	+= 1
		NSALDO		+= (cAliasTemp)->E1_SALDO
		NACRESCIMO	+= (cAliasTemp)->E1_ACRESC
		NABATIMEN	:= 0
		NPRINCIPAL	:= NPRINCIPAL + (cAliasTemp)->E1_VALOR
		NJUROS 		:= (cAliasTemp)->E1_JUROS
		NDECRES 	:= (cAliasTemp)->E1_DECRESC
		NTOTALG 	:= ((NPRINCIPAL + NJUROS) - NDECRES )

		(cAliasTemp)->(DbSkip())

	EndDo()

Return(aDados)

/*Titulo Fim Titulos Abertos*/

/*Ordenação*/

Static Function Sort(nCol, oField, oBrw, nSortDefault)

	Local nSort 			:= 0
	Local nCount 			:= 0

	For nCount := 1 To oField:Fields:GetCount()

		If nCount <> nCol

			oField:Fields:GetValue(nCount):nSort := 0

			oBrw:oBrowse:SetHeaderImage(nCount, "")

		EndIf

	Next

	If (nSortDefault > 0  .And. nSortDefault == 1)

		nSort := 2
		aSort(oBrw:aCols,,, {|x,y| (x[nCol]) > (y[nCol])})

	ElseIf (nSortDefault > 0  .And. nSortDefault == 2)

		nSort := 1
		aSort(oBrw:aCols,,, {|x,y| (x[nCol]) < (y[nCol])})

	Else

		If oField:Fields:GetValue(nCol):nSort == 1

			nSort := 2

			aSort(oBrw:aCols,,, {|x,y| (x[nCol]) > (y[nCol])})

		Else

			nSort := 1

			aSort(oBrw:aCols,,, {|x,y| (x[nCol]) < (y[nCol])})

		EndIf

	EndIf

	oField:Fields:GetValue(nCol):nSort := nSort

	oBrw:oBrowse:SetHeaderImage(nCol, If (nSort == 1, "COLDOWN", "COLRIGHT"))

	oBrw:Refresh()

Return()
