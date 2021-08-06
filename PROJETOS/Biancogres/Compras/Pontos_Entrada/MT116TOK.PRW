#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MT116TOK
@author Desconhecido
@since 31/01/17
@version 1.0
@description Ponto de entrada da validação da gração da nota fiscal de entrada
@type function
/*/

User Function MT116TOK()

	Local xfRet := .T.
	Local I

	//Variável para controlar o RPV
	PUBLIC c_cNumRpv	:=	""

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0
	Private cArqSX6	:= ""
	Private cIndSX6	:= 0
	Private cRegSX6	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SX6")
	DbSeek(xFilial("SX6")+"MV_YNFORI")
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	MsUnLock()

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

	IF SM0->M0_CODIGO <> '02'

		nSitNat := Alltrim(SED->ED_MSBLQL) //Posicione("SED",1,xFilial("SED")+CNATUREZA,"ED_MSBLQL")
		If nSitNat == "1"
			MsgBox("Natureza Financeira "+Alltrim(SED->ED_CODIGO)+" está bloqueada para uso!", "MT116TOK", "STOP")
			Return(.F.)
		EndIf

	Endif

	For I := 1 To Len(aCols)
		wCod 		:= Gdfieldget('D1_COD',I)
		cAlmVend	:= Gdfieldget('D1_LOCAL',I)

		DbSelectArea("SB1")
		cArqSB1 := Alias()
		cIndSB1 := IndexOrd()
		cRegSB1 := Recno()
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+wCod,.F.)

		If !(SB1->B1_TIPO $ "PA#PP") .And. cAlmVend $ "02#04"
			MsgBox("Almoxarifado informado incorreto: " + cAlmVend,"MT116TOK","STOP")
			lRet := .F.			
		EndIf

		If cArqSB1 <> ""
			dbSelectArea(cArqSB1)
			dbSetOrder(cIndSB1)
			dbGoTo(cRegSB1)
			RetIndex("SB1")
		EndIf
	Next

	// Por Marcos Alberto Soprani em 19/07/12 conforme OS Effettivo 1327-12.
	// Esta regra deve andar em conjunto com o ponto de entrada MT100TOK
	//If Alltrim(cEspecie) $ "SPED/CTE/CTEOS" .and. Empty(M->F1_CHVNFE) .and. Empty(aNFEDanfe[13])
	xfChvNfe := M->F1_CHVNFE
	If Empty(xfChvNfe)
		xfChvNfe := aNFEDanfe[13]
	EndIf

	If Alltrim(cEspecie) $ "SPED/CTE/CTEOS" .and. Empty(xfChvNfe)

		MsgBox("Se a ESPECIE for SPED,CTE ou CTEOS a chave deverá ser informada.", "MT116TOK", "STOP")
		xfRet := .F.

	Else

		If Alltrim(cEspecie) $ "SPED/CTE/CTEOS" .and. INCLUI
			TX001 := " SELECT COUNT(*) CONTAD
			TX001 += "   FROM " + RetSqlName("SF1")
			TX001 += "  WHERE F1_FILIAL = '"+xFilial("SF1")+"'
			TX001 += "    AND F1_CHVNFE = '"+xfChvNfe+"'
			TX001 += "    AND D_E_L_E_T_ = ' '
			TCQUERY TX001 ALIAS "TX01" NEW
			dbSelectArea("TX01")
			If TX01->CONTAD > 0
				MsgBox("Chave eletrônica duplicada. Será necessário filtrar, na tabela SF1, quais notas estão associadas com a chave acima e efetuar o devido acerto.","MT116TOK", "STOP")
				xfRet := .F.
			EndIf
			TX01->(dbCloseArea())
			If cFormul == "N"
				xfCnpj := IIF(cTipo $ "D", SA1->A1_CGC, SA2->A2_CGC)
				If cTipo $ "D/B"
					SA1->(dbSetOrder(1))
					SA1->(dbSeek(xFilial("SA1") + ca100For + cLoja))
					xfCnpj := SA1->A1_CGC
				Else
					SA2->(dbSetOrder(1))
					SA2->(dbSeek(xFilial("SA2") + ca100For + cLoja))
					xfCnpj := SA2->A2_CGC
				EndIf
				If Substr(xfChvNfe,7,14) <> xfCnpj
					MsgBox("A chave eletrônica desta nota não pertence ao fornecedor corrente. Favor verificar!","MT116TOK", "STOP")
					xfRet := .F.
				EndIf
			EndIf
		EndIf
		// Implementado em 19/07/12 por Marcos Alberto Soprani ni intuito de diminuir um pouco a quantidade de erro de usuário
		If !Empty(xfChvNfe) .and. !Alltrim(cEspecie) $ "SPED/CTE/CTEOS"
			MsgBox("O Campo Chave Eletrônica foi informado portanto é necessário informar o ESPECIE como SPED,CTE ou CTEOS","MT116TOK", "STOP")
			xfRet := .F.
		EndIf

	EndIf

	//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam 
	// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
	If dDataBase <= GetMv("MV_YULMES")
		MsgBox("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MT116TOK", "STOP")
		xfRet := .F.
	EndIf

	If (!IsInCallStack("U_PNFM0003")) 
		U_BIAF101()
	EndIf

Return(xfRet)
