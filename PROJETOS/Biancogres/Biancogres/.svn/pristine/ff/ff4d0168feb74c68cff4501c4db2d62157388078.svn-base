#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := BRUNO MADALANO
Autor(Rev):= Marcos Alberto Soprani
Programa  := BUSC_PESO
Empresa   := Biancogres Cerâmica S/A
Data      := 22/12/08
Data(Rev) := 07/12/12
Uso       := Compras
Aplicação := BUSCA O PESO NA PESAGEM PARA PREENCHIMENTO NA NF DE ENTRADA
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

USER FUNCTION BUSC_PESO()

	Local aArea        := GetArea()
	Local msTtsCol     := .F.  // Tratamento para TotvsColaboração
	Local nX

	Private aDlPeso
	Private oGet1
	Private cGet1      := Space(45)
	Private oRadMenu1
	Private nRadMenu1  := 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx  := {}
	Private aColsEx    := {}
	Private aFieldFill := {}
	Private aFields    := {"BALANCA", "Z11_PCAVAL", "Z12_NFISC", "Z12_EMP", "Z11_DATAIN", "Z11_PESLIQ", "CONTAD"}
	Private oMPesoDd1
	Private xPesoRet   := 0
	Private zCol
	Private zLin

	PRIVATE ENTER	  := CHR(13)+CHR(10)
	PRIVATE CSQL 	  := ""
	PRIVATE RQUANT	  := 0
	PRIVATE PESOLIQUI := 0
	Private fh_Esc    := .F.  // Todos os pontos onde esta variável está referenciada foi incluído por Marcos Alberto em 27/12/11 para atender a importação XML

	//CONOUT('-> BUSC_PESO - '+ Alltrim(FunName()))

	//Projeto Portaria Fiscal - Execauto de classificacao
	If IsInCallStack("U_TACLNFJB") .Or. IsInCallStack("U_BACP0012") .Or. IsInCallStack("U_PNFM0002") .Or. IsInCallStack("U_PNFM0005")
		Return(0)
	EndIf

	If IsInCallStack("U_COPYDOCE") .And. IsBlind()

		Return(0)

	EndIf

	If IsInCallStack("U_JOBFATPARTE") .And. IsBlind()

		Return(0)

	EndIf

	If IsInCallStack("MATA140")
		zCol       := 1866
		zLin       := 903
		msTtsCol   := .T.
	EndIf

	// Em 26/01/17 para resolver problema de integração automática do totvs Colaboração
	If Alltrim(FunName()) $ "EICDI154/COMXCOL/SCHEDCOMCOL/MATA140I"
		zCol       := 1866
		zLin       := 903
		msTtsCol   := .T.
	ElseIf !IsBlind()
		zCol       := oMainWnd:nClientWidth
		zLin       := oMainWnd:nClientHeight
	EndIf

	If CA100FOR = "014458"
		Return(0)
	EndIf

	If Substr(Posicione("SB1",1,xFilial("SB1")+ Acols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'D1_COD'}) ] ,"B1_GRUPO"),1,3) <> "101"
		Return(0)
	EndIf

	// Implementado por Marcos Alberto Soprani em 07/12/12 em virtude de várias OS Effettivo.
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
		If Alltrim(aFields[nX]) == "BALANCA"
			Aadd(aHeaderEx, {"Balanca","BALANCA","@!",2,0,,,"C",,,,})
		EndIf
		If Alltrim(aFields[nX]) == "CONTAD"
			Aadd(aHeaderEx, {"Contad","CONTAD","999999",6,0,,,"N",,,,})
		EndIf
	Next nX

	xCPesage := 0
	A0001 := " SELECT 'BG' BALANCA,
	A0001 += "        Z11_PCAVAL,
	A0001 += "        Z12_NFISC,
	A0001 += "        Z12_EMP,
	A0001 += "        Z11_DATAIN,
	A0001 += "        SUM(Z11_PESLIQ) Z11_PESLIQ,
	A0001 += "        COUNT(*) CONTAD
	A0001 += "   FROM Z12010 Z12
	A0001 += "  INNER JOIN Z11010 Z11 ON Z11_FILIAL = '"+xFilial("Z11")+"'
	A0001 += "                       AND Z11_PESAGE = Z12_PESAGE
	A0001 += "                       AND Z11.D_E_L_E_T_ = ' '
	A0001 += "  WHERE Z12_FILIAL = '"+xFilial("Z12")+"'
	A0001 += "    AND Z12_NFISC = '"+cNFiscal+"'
	A0001 += "    AND Z12_EMP = '"+cEmpAnt+"'
	A0001 += "    AND Z11_DATAIN >= '"+dtos((Date() - 6))+"'
	A0001 += "    AND Z12.D_E_L_E_T_ = ' '
	A0001 += "  GROUP BY Z11_PCAVAL, Z12_NFISC, Z12_EMP, Z11_DATAIN
	A0001 += "  UNION ALL
	A0001 += " SELECT 'IN' BALANCA,
	A0001 += "        Z11_PCAVAL,
	A0001 += "        Z12_NFISC,
	A0001 += "        Z12_EMP EMP_NF,
	A0001 += "        Z11_DATAIN,
	A0001 += "        SUM(Z11_PESLIQ) Z11_PESLIQ,
	A0001 += "        COUNT(*) CONTAD
	A0001 += "   FROM Z12050 Z12
	A0001 += "  INNER JOIN Z11050 Z11 ON Z11_FILIAL = '"+xFilial("Z11")+"'
	A0001 += "                       AND Z11_PESAGE = Z12_PESAGE
	A0001 += "                       AND Z11.D_E_L_E_T_ = ' '
	A0001 += "  WHERE Z12_FILIAL = '"+xFilial("Z12")+"'
	A0001 += "    AND Z12_NFISC = '"+cNFiscal+"'
	A0001 += "    AND Z12_EMP = '"+cEmpAnt+"'
	A0001 += "    AND Z11_DATAIN >= '"+dtos((Date() - 6))+"'
	A0001 += "    AND Z12.D_E_L_E_T_ = ' '
	A0001 += "  GROUP BY Z11_PCAVAL, Z12_NFISC, Z12_EMP, Z11_DATAIN
	TcQuery A0001 Alias "A001" New
	A001->(dbGoTop())
	While !A001->(Eof())
		xCPesage ++
		Aadd(aFieldFill, {A001->BALANCA, A001->Z11_PCAVAL, A001->Z12_NFISC, A001->Z12_EMP, stod(A001->Z11_DATAIN), A001->Z11_PESLIQ/1000, A001->CONTAD, .F. })
		A001->(DbSkip())
	End
	A001->(dbCloseArea())

	If Len(aFieldFill) == 0
		Aadd(aFieldFill, { Space(2), Space(25), Space(9), Space(2), ctod("  /  /  "), 0, 0, .F. })
	EndIf
	aColsEx := aFieldFill

	If xCPesage == 0

		If !Alltrim(FunName()) $ "EICDI154/COMXCOL/SCHEDCOMCOL/MATA140I/" .And. !FwIsInCallStack('U_GATI001')
			Help(" ",1,"BUSC_PESO:",, "Nota sem pesagem!!!"+CHR(13)+CHR(13),1,0)
		EndIf

	ElseIf xCPesage == 1

		xPesoRet := aColsEx[1][6]

	ElseIf !msTtsCol

		DEFINE MSDIALOG aDlPeso TITLE "Selecionar Pesagem" FROM zLin*.000, zCol*.000  TO zLin*.600, zCol*.750 COLORS 0, 16777215 PIXEL
		oMPesoDd1 := MsNewGetDados():New( zLin*.005, zCol*.005, zLin*.225, zCol*.373, , , , , , , 999, , , , aDlPeso, aHeaderEx, aColsEx)
		@ zLin*.240, zCol*.350 BUTTON Retornar PROMPT "Retornar" SIZE zLin*.040, zCol*.020 OF aDlPeso ACTION( fGrPeso1(), aDlPeso:End() ) PIXEL
		ACTIVATE MSDIALOG aDlPeso
		n := 1

	EndIf

Return ( xPesoRet )


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ C_PLACAS       ºAUTOR  ³ MADALENO           º DATA ³  22/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ GERA UM BROWSE PARA A ESCOLHA DA PLACA NECESSARIA                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
STATIC FUNCTION C_PLACAS()

	PRIVATE ACAMPOS0
	PRIVATE CSQL
	PRIVATE CREPRESENTANTE := SPACE(6) //IIF(ALLTRIM(CREPATU) = "",SPACE(6),CREPATU)
	PRIVATE CNOMEUSUARIO
	PRIVATE CCODUSUARIO
	PRIVATE ENTER := CHR(13) + CHR(10)
	PRIVATE NRADIO:= 6
	PRIVATE NOVO_NRADIO := ""
	PRIVATE CDATADE, CDATAATE
	PRIVATE S_TOT_FILTRO := ""

	DEFINE MSDIALOG DLG_SOL FROM 0,0 TO 250,410 TITLE "PLACA DE PESAGEM" PIXEL

	// DEFININDO AS FONTES QUE SERÃO USADAS NA TELA
	DEFINE FONT OBOLD_8  	NAME "ARIAL" SIZE 0, -08 BOLD
	DEFINE FONT OBOLD_9  	NAME "ARIAL" SIZE 0, -09 BOLD
	DEFINE FONT OBOLD_10  	NAME "ARIAL" SIZE 0, -10 BOLD
	DEFINE FONT OBOLD_12 	NAME "ARIAL" SIZE 0, -12 BOLD
	DEFINE FONT OBOLD_16 	NAME "ARIAL" SIZE 0, -16 BOLD
	DEFINE FONT OBOL_TITULO NAME "ARIAL" SIZE 0, -20 BOLD

	/* CORES
	CLR_CYAN 	= VERDE
	CLR_WHITE 	= BRANCO     '
	CLR_RED		= VERMELHO
	CLR_BLUE	= AZUL
	CLR_GREEN 	= VERDE
	CLR_BLACK	= PRETO
	*/

	// CABECALHO
	@ 001,004 TO 030,202 LABEL "" OF DLG_SOL PIXEL // 1 FRAME DO TITULO
	@ 003,006 TO 027,200 LABEL "" OF DLG_SOL PIXEL // 2 FRAME DO TITULO
	@ 010,015  SAY "ESCOLHA A PLACA DA NOTA FISCAL"  COLOR CLR_BLUE FONT OBOL_TITULO PIXEL

	@ 110,015 BUTTON "CANCELAR" SIZE 70,14 OF DLG_SOL PIXEL ACTION (fh_Esc := .T., DLG_SOL:End()) //CLOSE(DLG_SOL)
	@ 110,120 BUTTON "CONFIRMAR" SIZE 70,14 OF DLG_SOL PIXEL ACTION SCONFIRNMA()

	// CRIANDO O BROWSE PRINCIPAL
	BROW_PRINCIPAL()
	oBrowse := IW_Browse(035,010,100,200,"_TRA_PRINCIPAL",,,ACAMPOS0)

	ACTIVATE MSDIALOG DLG_SOL VALID fh_Esc CENTERED   //ON INIT Eval( {||  MsAguarde(), _TRA_PRINCIPAL->(DbGoTop()), oBrowse:oBrowse:Refresh(), } )

RETURN

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³BROW_PRINCIPAL³ Autor ³BRUNO MADALENO        ³ Data ³ 11/05/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MONTA O OBROWSE PARA LISTAS OS TITULOS BLOQUEADOS               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function BROW_PRINCIPAL()

	_ACAMPOS :=	{	{"CCODIGO"		,"C",6,0},;
	{"DATA_IN"		,"D",08,0},;
	{"PLACA"		,"C",25,0},;
	{"PESO"			,"N",12,2}}

	IF CHKFILE("_TRA_PRINCIPAL")
		DBSELECTAREA("_TRA_PRINCIPAL")
		DBCLOSEAREA()
	ENDIF
	_TRA_PRINCIPAL := CRIATRAB(_ACAMPOS)
	DBUSEAREA(.T.,,_TRA_PRINCIPAL,"_TRA_PRINCIPAL",.T.)
	DBCREATEIND(_TRA_PRINCIPAL,"CCODIGO",{|| CCODIGO})

	//SELECIONANDO TODOS OS PRODUTOS E SUAS QUANTIDADES EM ESTOQUE
	CSQL	:= "SELECT * FROM   " + ENTER
	CSQL  += "		(SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE,Z11_PESAGE,Z11_PCAVAL,Z11_PESLIQ FROM Z11010 Z11, Z12010 Z12 WHERE  Z11.Z11_FILIAL = '"+xFilial("Z11")+"' AND Z12.Z12_FILIAL = '"+xFilial("Z12")+"' AND Z12_NFISC <> '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"' AND Z11.D_E_L_E_T_ = '' AND Z12.D_E_L_E_T_ = '' " + ENTER
	CSQL  += "		UNION  " + ENTER
	CSQL  += "		SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE,Z11_PESAGE,Z11_PCAVAL,Z11_PESLIQ FROM Z11050 Z11, Z12050 Z12 WHERE  Z11.Z11_FILIAL = '"+xFilial("Z11")+"' AND Z12.Z12_FILIAL = '"+xFilial("Z12")+"'  AND Z12_NFISC <> '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"' AND Z11.D_E_L_E_T_ = '' AND Z12.D_E_L_E_T_ = '' ) AS AB  " + ENTER
	CSQL	+= "WHERE	Z12_NFISC = '"+CNFISCAL+"' AND " + ENTER
	CSQL	+= "		Z11_DATAIN >= '"+DTOS((DATE() - 6))+"' " + ENTER

	IF CHKFILE("C_CONS")
		DBSELECTAREA("C_CONS")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "C_CONS" NEW
	C_CONS->(DBGOTOP())
	WHILE !C_CONS->(EOF())
		RECLOCK("_TRA_PRINCIPAL",.T.)

		_TRA_PRINCIPAL->CCODIGO		:= C_CONS->Z11_PESAGE
		_TRA_PRINCIPAL->DATA_IN		:= STOD(C_CONS->Z11_DATAIN)
		_TRA_PRINCIPAL->PLACA		:= C_CONS->Z11_PCAVAL
		_TRA_PRINCIPAL->PESO		:= C_CONS->Z11_PESLIQ
		MSUNLOCK()
		C_CONS->(DBSKIP())
	ENDDO

	ACAMPOS0 := {}
	AADD(ACAMPOS0,{"CCODIGO"	,	"CÓDIGO"		,08})
	AADD(ACAMPOS0,{"DATA_IN"	, 	"DATA" 			,18})
	AADD(ACAMPOS0,{"PLACA"		, 	"PLACA PESAGEM"	,18})

RETURN

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ SCONFIRNMA  ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
STATIC FUNCTION SCONFIRNMA()

	IF ACOLS[N, ASCAN(AHEADER, { |X| ALLTRIM(X[2]) == 'D1_UM'}) ] = "T " .OR. Acols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'D1_UM'}) ] = "M3"
		PESOLIQUI	:= (_TRA_PRINCIPAL->PESO/1000)
	ELSE
		PESOLIQUI	:= (_TRA_PRINCIPAL->PESO)
	END IF

	fh_Esc := .T.

	DLG_SOL:End()

RETURN

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrPeso1  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Retorna os dados para o grid de lançamento da Nota         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGrPeso1()

	If oMPesoDd1:ACOLS[oMPesoDd1:oBrowse:nAt][6] <> 0
		xPesoRet := oMPesoDd1:ACOLS[oMPesoDd1:oBrowse:nAt][6]
	EndIf

Return
