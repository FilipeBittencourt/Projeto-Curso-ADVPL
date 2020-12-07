#INCLUDE "RWMAKE.CH"
//#include "PROTHEUS.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
²±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²
²±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±²
²±±ºPrograma  ³ GERA_FICHºAutor  ³ MADALENO           º Data ³  24/01/08   º±±²
²±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±²
²±±ºDesc.     ³ ROTINA PARA GERAR UMA ODOS OS ARQUIVOS TXT                 º±±²
²±±º          ³                                                            º±±²
²±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±²
²±±ºUso       ³ AP8 - CUSTOMIZACAO EM CLIENTE                              º±±²
²±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±²
²±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION GERA_TICK()
	LOCAL aLay := ARRAY(36)
	LOCAL nSALDO := 0
	lOCAL sBANCO := ""
	LOCAL nBANCO := 0
	Local nCntVias	:= 0		// Recebe o contador de vias
	Local nVias		:= 0  		// recebe o numero de vias que serão impressas
	Local aNF := {}
	PRIVATE lFin
	PRIVATE aRESULTADO
	PRIVATE wnrel
	Private cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Private cDesc2         := "de acordo com os parametros informados pelo usuario."
	Private cDesc3         := "Ticket de Pesagem Veicular"
	Private cPict          := ""
	Private titulo         := "Ticket de Pesagem Veicular"
	Private nLin           := 80
	Private Cabec1         := ""
	Private Cabec2         := ""
	Private imprime        := .T.
	Private aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "MOV580"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 2
	Private wnrel        := "MOV580"
	Private cString := "Z11" 

	//define que o campo de quantidade de vias (páginas) estará habilitado. Por default ele vem desabilitado.
	SetEnableVias(.T.)

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	// TESTE CHAMADO TUXNJ8
	nVias := GetNVias()

	/*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
	//³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
	//³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
	//³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
	//³                                                                     ³
	//³ dbSeek(xFilial())                                                   ³
	//³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*/

	For nCntVias := 1 To nVias
		Cabec("","","","GERA_TICK",tamanho,nTipo,,.F.)

		nLin	:=	PROW()+1

		aLay[01] :="+------------------------------------------------------------------------------+"
		IF CEMPANT == "05"
			ALAY[02] :="|                      INCESA REVESTIMENTO CERÂMICO LTDA                       |"
		ELSE
			ALAY[02] :="|                            BIANCOGRES CERÂMICA SA                            |"
		END IF

		aLay[03] :="+------------------------------------------------------------------------------+"
		aLay[04] :="|                                                                              |"
		aLay[05] :="+---------------------------+--------------------------------------------------+"
		aLay[06] :="|  Ticket de pesagem Nº     | ##########   SEQ: ##      ########    ########   |"
		aLay[07] :="+---------------------------+--------------------------------------------------+"
		aLay[08] :="|  Placa do Veiculo         | ##########                                       |"
		aLay[09] :="|  Emissão                  |                                                  |"

		aLay[10] :="+------------------------------------------------------------------------------+"
		aLay[11] :="|  Notas Fiscais                                                               |"
		aLay[12] :="+------------------------------------------------------------------------------+"
		aLay[13] :="|  ##########################################################################  |"
		aLay[14] :="|  ##########################################################################  |"
		aLay[15] :="|  ##########################################################################  |"
		aLay[16] :="+------------------------------------------------------------------------------+"	

		aLay[17] :="|  Motorista                |                                                  |"
		aLay[18] :="|  Transportador            | ################################################ |"
		aLay[19] :="|---------------------------+--------------------------------------------------|"
		aLay[20] :="|                                                                              |"
		aLay[21] :="|                                                                              |"
		aLay[22] :="| +--------------------------------------------------------------------------+ |"
		aLay[23] :="| |    PESO 1          ##############                 ########    ########   | |"
		aLay[24] :="| +--------------------------------------------------------------------------+ |"
		aLay[25] :="|                                                                              |"
		aLay[26] :="|                                                                              |"
		aLay[27] :="| +--------------------------------------------------------------------------+ |"
		aLay[28] :="| |    PESO 2          ##############                 ########    ########   | |"
		aLay[29] :="| +--------------------------------------------------------------------------+ |"
		aLay[30] :="|                                                                              |"
		aLay[31] :="|                                                                              |"
		aLay[32] :="| +--------------------------------------------------------------------------+ |"
		aLay[33] :="| |    LIQUIDO         ##############                                        | |"
		aLay[34] :="| +--------------------------------------------------------------------------+ |"
		aLay[35] :="|                                                                              |"
		aLay[36] :="+------------------------------------------------------------------------------+"

		FmtLin(,aLay[01],,,@nLin)
		FmtLin(,aLay[02],,,@nLin)
		FmtLin(,aLay[03],,,@nLin)
		FmtLin(,aLay[04],,,@nLin)
		FmtLin(,aLay[05],,,@nLin)
		FmtLin({ Z11->Z11_PESAGE , ALLTRIM(Z11->Z11_SEQB), dtoc(Z11->Z11_DATAIN),Substr(Z11->Z11_HORAIN,1,5) },aLay[06],,,@nLin)
		FmtLin(,aLay[07],,,@nLin)
		FmtLin({ Z11->Z11_PCAVAL },aLay[08],,,@nLin)
		FmtLin(,aLay[09],,,@nLin)

		FmtLin(,aLay[10],,,@nLin)
		FmtLin(,aLay[11],,,@nLin)
		FmtLin(,aLay[12],,,@nLin)

		aNF := fGetNF(Z11->Z11_PESAGE)

		FmtLin({aNF[1]}, aLay[13],,,@nLin)
		FmtLin({aNF[2]}, aLay[14],,,@nLin)
		FmtLin({aNF[3]}, aLay[15],,,@nLin)		

		FmtLin(,aLay[16],,,@nLin)	

		FmtLin(,aLay[17],,,@nLin)	
		FmtLin({Z11->Z11_CODTRA + " - " + ALLTRIM(Posicione("SA2",1,xFilial("SA2")+Z11->Z11_CODTRA,"A2_NOME"))},aLay[18],,,@nLin)

		FmtLin(,aLay[19],,,@nLin)
		FmtLin(,aLay[20],,,@nLin)
		FmtLin(,aLay[21],,,@nLin)
		FmtLin(,aLay[22],,,@nLin)
		FmtLin({ Transform(Z11->Z11_PESOIN,"@E 999,999,999") ,dtoc(Z11->Z11_DATAIN) , Substr(Z11->Z11_HORAIN,1,5) },aLay[23],,,@nLin)
		FmtLin(,aLay[24],,,@nLin)
		FmtLin(,aLay[25],,,@nLin)
		FmtLin(,aLay[26],,,@nLin)
		FmtLin(,aLay[27],,,@nLin)
		FmtLin({ Transform(Z11->Z11_PESOSA,"@E 999,999,999") , dtoc(Z11->Z11_DATASA) ,Substr(Z11->Z11_HORASA,1,5) },aLay[28],,,@nLin)
		FmtLin(,aLay[29],,,@nLin)
		FmtLin(,aLay[30],,,@nLin)
		FmtLin(,aLay[31],,,@nLin)
		FmtLin(,aLay[32],,,@nLin)
		FmtLin({ Transform(Z11->Z11_PESLIQ,"@E 999,999,999") },aLay[33],,,@nLin)
		FmtLin(,aLay[34],,,@nLin)
		FmtLin(,aLay[35],,,@nLin)
		FmtLin(,aLay[36],,,@nLin)

	Next nCntVias


	SET DEVICE TO SCREEN

	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif
	MS_FLUSH()

Return


Static Function fGetNF(cPesage)
	Local aRet := Array(3)
	Local cNF := ""
	Local nCount

	DbSelectArea("Z12")
	DbSetOrder(1)
	If Z12->(DbSeek(xFilial("Z12") + cPesage))

		While !Z12->(Eof()) .And. Z12->Z12_PESAGE == cPesage

			If !Empty(AllTrim(Z12->Z12_NFISC))

				cNF += AllTrim(Z12->Z12_NFISC) + "," + Space(1)

			EndIf

			Z12->(DbSkip())

		EndDo()

	EndIf

	If !Empty(cNF)

		cNF := SubStr(cNF, 1, Len(cNF) -2)

		nLine := MlCount(cNF, 75)

		For nCount := 1 To 3

			aRet[nCount] := Memoline(cNF, 75, nCount)

		Next

	EndIf

Return(aRet)