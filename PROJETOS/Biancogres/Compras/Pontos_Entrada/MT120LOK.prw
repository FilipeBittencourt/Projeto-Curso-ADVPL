#include "rwmake.ch"
#include "topconn.ch"

User Function MT120LOK()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ MT120LOK ³ Autor ³ Ranisses A. Corona    ³ Data ³ 21.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Validar C.Custo No Pedido Compra para Produto Tipo MD      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local lret     := .T.
LOCAL CSQL     := ""
LOCAL sPOS     := ""
LOCAL sPRODUTO := ""
LOCAL nPRECO1  := 0
LOCAL nPRECO2  := 0
LOCAL sPosEmp  := 0
LOCAL nEmpr    := 0
LOCAL wContrat := ""
Local wItemCta := ""
Local wSI      := ""
Local lConta	 := .F.
Local wProd		 := ""
Local wLocal	 := ""
Local oVldPedCom := TVldPedCom():New()

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSB1	:= ""
Private cIndSB1	:= 0
Private cRegSB1	:= 0

Private cArqSBZ	:= ""
Private cIndSBZ	:= 0
Private cRegSBZ	:= 0

Private cArqSBM	:= ""
Private cIndSBM	:= 0
Private cRegSBM	:= 0

Private cArqSF4	:= ""
Private cIndSF4	:= 0
Private cRegSF4	:= 0
Private cCtrBloq := 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()
wAlias  := Alias()

//Acerta Campo Rateio
GDFieldPut('C7_RATEIO','2', n)

//Armazena as variaveis / conteudo de cada linha
wPROD		:= Gdfieldget("C7_PRODUTO",n)
wLocal		:= Gdfieldget("C7_LOCAL",n)
wCLVL		:= Gdfieldget("C7_CLVL",n)
wConta   	:= Gdfieldget("C7_CONTA",n)
wItemCta	:= Gdfieldget("C7_ITEMCTA",n)
wSI   		:= Gdfieldget("C7_YSI",n)
cTes		:= Gdfieldget("C7_TES",n)
wContrat	:= Gdfieldget("C7_YCONTR",n)
wNumSC 		:= Gdfieldget("C7_NUMSC",n)
wBlq   		:= Gdfieldget("C7_CONAPRO",n) 
dEmissao	:= Gdfieldget("C7_EMISSAO",n)
dDatPrf	  	:= Gdfieldget("C7_DATPRF",n)
dDatChe   	:= Gdfieldget("C7_YDATCHE",n)
dDatEma   	:= Gdfieldget("C7_YDATEMA",n)
cSubitem   	:= Gdfieldget("C7_YSUBITE",n)

DbSelectArea("SB1")
cArqSB1 := Alias()
cIndSB1 := IndexOrd()
cRegSB1 := Recno()
DbSetOrder(1)
DbSeek(xFilial("SB1")+wPROD)

DbSelectArea("SBZ")
cArqSBZ := Alias()
cIndSBZ := IndexOrd()
cRegSBZ := Recno()
DbSetOrder(1)
DbSeek(xFilial("SBZ")+wPROD)

// Incluído por Marcos Alberto Soprani em 19/08/15 para atender ao novo controle de CLVL por empresa
If !ExecBlock("BIA555", .F., .F., "SC7LOK1")
	Return( .F. )
EndIf

// Empresa14 - Tratamento efetuado em 16/08/13 por Marcos Alberto Soprani
If cEmpAnt $ "14"
	Return( .T. )
EndIf

//Verifica se o produto possui conta de Investimento (31401)
If Substr(wConta,1,5) == "31401" .OR. Substr(wConta,1,5) == "31406"
	IF ALLTRIM(wConta) <> '31401017'
		lConta := .T.
	ENDIF
Else
	If (Substr(SB1->B1_CONTA,1,5) == "31401" .Or. ;
		Substr(SB1->B1_CONTA,1,5)   == "31406" .Or. ;
		Substr(SB1->B1_YCTARES,1,5) == "31401" .Or. ;
		Substr(SB1->B1_YCTARES,1,5) == "31406" .Or. ;
		Substr(SB1->B1_YCTRIND,1,5) == "31401" .Or. ;
		Substr(SB1->B1_YCTRIND,1,5) == "31406" .Or. ;
		Substr(SB1->B1_YCTRADM,1,5) == "31401" .Or. ;
		Substr(SB1->B1_YCTRADM,1,5) == "31406") .And. !lConta
		IF ALLTRIM(SB1->B1_CONTA) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTARES) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTRIND) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTRADM) <> '31401017'
			lConta := .T.
		ENDIF
	EndIf
EndIf

DbSelectArea("SBM")
cArqSBM := Alias()
cIndSBM := IndexOrd()
cRegSBM := Recno()
DbSetOrder(1)
DbSeek(xFilial("SBM")+SB1->B1_GRUPO)

DbSelectArea("SF4")
cArqSF4 := Alias()
cIndSF4 := IndexOrd()
cRegSF4 := Recno()
DbSetOrder(1)
DbSeek(xFilial("SF4")+cTes)

//Verifica se a linha esta deletada
If !GdDeleted(n)
	//Bloqueia entrada de produtos Comum na Incesa

	//Fernando/Facile em 03/12/2015 -> acabar com o armazem de produto comum - cada empresa passa a comprar seu produto (Comentado o bloco acima)
	//Comentado o Bloco Abaixo para liberar entrada na Incesa no Almoxarifado 01

	/*If cEmpAnt == "05" .And. SBZ->BZ_YCOMUM == "S"
		MsgBox("Não é permitida a inclusão de Pedido de Compras para Produto Comum na empresa Incesa. Favor verificar procedimento com Almoxarifado!","MT120LOK","ALERT")
		lret := .F.
		Return(lret)
	EndIf*/
	
	IF !EMPTY(dEmissao) .AND. !EMPTY(dDatPrf) .AND. dDatPrf < dEmissao
		MsgBox("Não é permitida a digitação da data de entrega inferior a data de emissão do pedido de compra!","MT120LOK","ALERT")
		lret := .F.
		Return(lret)
	ENDIF
	
	IF !EMPTY(dEmissao) .AND. !EMPTY(dDatChe) .AND. dDatChe < dEmissao
		MsgBox("Não é permitida a digitação da data de chegada inferior a data de emissão do pedido de compra!","MT120LOK","ALERT")
		lret := .F.
		Return(lret)
	ENDIF
	
	// Tiago Rossini Coradini - Facile - OS: 1777-15 - Jesebel Brandao
	IF !Alltrim(FunName()) $ "EICPO400" //Carlos Junqueira - SIGAEIC 20150904
		IF !Empty(dDatPrf) .And. !Empty(dDatChe) .And. dDatChe < dDatPrf
			MsgBox("Não é permitida a digitação da data de chegada inferior a data de entrega do pedido de compra!","MT120LOK","ALERT")
			lRet := .F.
			Return(lRet)
		ENDIF
	EndIf
	
	IF !EMPTY(dEmissao) .AND. !EMPTY(dDatEma) .AND. dDatEma < dEmissao
		MsgBox("Não é permitida a digitação da data de follow-up inferior a data de emissão do pedido de compra!","MT120LOK","ALERT")
		lret := .F.
		Return(lret)
	ENDIF
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa validacao referente Almoxarifado Comum ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Executa funcao de validacao com retorno imediato
If !GdDeleted(n)
	If !U_fValProdComum(wProd,wLocal,"MT120LOK","C") //Paramentros da Funcao Produto/Almoxarifado/NomeProgroma/TipoMovimento(C=Compra/T=Transferencia)
		lRet := .F.
		Return(lRet)
	EndIf
EndIf

//Verifica se o Produto e do Tipo MD
If Alltrim(SB1->B1_TIPO) == "MD"
	IF SBM->BM_YCON_MD = "N"
		//Verifica se a Classe de Valor esta em branco
		If Empty(wCLVL)
			MsgBox("Classe de Valor em branco para produto MD, favor preencher o mesmo para continuar!!","MT120LOK","ALERT")
			lret := .F.
			Return(lret)
		EndIf
	ELSE
		If cempant == "01"
			If Alltrim(SF4->F4_ESTOQUE) == "N"
				MsgBox("TES QUE NAO ATUALIZA ESTOQUE NÃO PODE SER USADA NESTA CONDIÇÃO!!","MT120LOK","ALERT")
				lret := .F.
				Return(lret)
			END IF
		END IF
	END IF
EndIf

//Alterado por Wanisay conforme OS 4066-15
//IF SUBSTR(SB1->B1_GRUPO,1,1) = "1" .OR. (CA120FORN == '003721' .AND. SUBSTR(SB1->B1_GRUPO,1,3) <> "306") //.OR.SUBSTR(SB1->B1_GRUPO,1,3)$"401_405"
IF SUBSTR(SB1->B1_GRUPO,1,1) = "1" .OR. SB1->B1_YTABELA == 'S'
	//IF CA120FORN == '003721' .AND. !SUBSTR(SB1->B1_GRUPO,1,3) $ '104/107/306'
		//Analisa Preco de compra amarrado ao fornecedor
		//sPOS     := aScan(aHeader,{|x| x[2]=="C7_PRODUTO"})
		//sPRODUTO := ACOLS[N,sPOS]
		//sPOS     := aScan(aHeader,{|x| x[2]=="C7_PRECO  "})
		//nPRECO1  := ACOLS[N,sPOS]
		//nPRECO2  := ACOLS[N,sPOS]
		
		sPRODUTO	:= wPROD
		nPRECO1		:= Gdfieldget("C7_PRECO",n)
		nPRECO2		:= Gdfieldget("C7_PRECO",n)
		
		// Tiago Rossini Coradini - 21-09-2015 - Atualiza tabela de preços de compra
		fUpdTabPrc(CA120FORN, CA120LOJ, sPRODUTO)
		
		CSQL := "SELECT A5_YPRECO, A5_MOE_US FROM SA5010 "
		CSQL += "WHERE 	A5_FORNECE = '"+CA120FORN+"'  AND "
		CSQL += "		A5_LOJA = '"+CA120LOJ+"' AND "
		CSQL += "		A5_PRODUTO = '"+sPRODUTO+"' AND "
		CSQL += "		D_E_L_E_T_ = '' "
		If chkfile("c_PRO_FORN")
			dbSelectArea("c_PRO_FORN")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "c_PRO_FORN" NEW
		
		IF ! c_PRO_FORN->(EOF())
			IF c_PRO_FORN->A5_YPRECO <> 0
				IF c_PRO_FORN->A5_MOE_US = "US$"
					nPRECO2 := xMoeda(c_PRO_FORN->A5_YPRECO,2,1,ddatabase)
				ELSE
					nPRECO2 := c_PRO_FORN->A5_YPRECO
				ENDIF
			ELSE
				nPRECO2 := 0
			ENDIF
		ELSE
			nPRECO2 := 0
		ENDIF
		
		//Retirar a validação abaixo para entrada do pedido do fornecedor 009303
		IF nPreco1 > nPreco2
			If cEmpAnt == "01" .and. CA120FORN == "002912"
				Return( .T. )
			ElseIf cEmpAnt == "05" .and. CA120FORN == "000534"
				Return( .T. )
			EndIf
			MsgBox("Preco informado maior do que a amarracao Produto x Fornecedor. ","MT120LOK")
			lRet := .F.
			Return(lret)
		ENDIF
	//ENDIF
ELSE
	
	// Alteração Facile - Tiago Rossini Coradini - 28/07/15 - Não validar tipo de frete quando a origem é o SIGAEIC
	If FunName() = 'EICPO400' .And. SubStr(cTpFrete, 1, 1) <> "F"
		cTpFrete := "F-FOB"
	Else
		
		If !SubStr(cTpFrete, 1, 1) $ "C/F/T/S"
			MsgInfo("Atenção, tipo de frete não informado, favor verificar a aba 'Frete/Despesas'!")
			Return(.F.)
		EndIf
		
	EndIf
	
	//Bloqueio para permitir que sejam implantados pedidos sem SC 
	IF !Alltrim(FunName()) $ "EICPO400" //Carlos Junqueira - SIGAEIC 20150909
		IF EMPTY(wNumSC)  .And. INCLUI
			MsgAlert("A Solicitação de Compra devera ser preenchida para este pedido de compra.")
			lRet := .F.
			Return(lret)
		ENDIF
	ENDIF
	
ENDIF

//Verifica digitacao do Almoxarifado
//sPosEmp	:= aScan(aHeader,{|x| x[2]=="C7_YEMPR  "})
//nEmpr	:= Acols[N,sPosEmp]

//Validação retirada pelo Wanisay no dia 06/05/16
//nEmpr		:= Gdfieldget("C7_YEMPR",n)
//If Alltrim(SB1->B1_YALMINC) == "03" .And. Alltrim(nEmpr) == "" .And. Alltrim(cempant) == "01"
//If Alltrim(nEmpr) == "" .And. Alltrim(cempant) == "01"
//	MsgBox("Favor confirmar a digitacao do Almoxarifado, informando a Empresa! ","STOP")
//	lRet := .F.
//	Return(lret)
//EndIf

//Verifica se o Produto esta com Bloqueio de Movimentacao
If SBZ->BZ_YBLSCPC == '1'
	MsgBox("O produto "+Alltrim(SB1->B1_COD)+" está bloqueado para uso em Solicitações e Pedidos. Favor verificar com o Almoxarifado.","Atenção","INFO")
	lRet := .F.
	Return(lret)
EndIf

// Verifica se o Pedido está bloqueado, validação não será executada quando o pedido é gerado pelo SIGAEIC 
// Tiago Rossini Coradini - 09/05/2017 - OS: 2278-16 - Rodolfo Stanke
If wBlq == 'B' .And. !FunName() = 'EICPO400'
	MsgBox("Este pedido foi bloqueado pelo Aprovador.","Atenção","INFO")
	lRet := .F.
	Return(lret)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa validacao do Item Contabil de Marketing ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SUBSTR(ALLTRIM(wItemCta),1,1) == 'I' .AND. EMPTY(wSI)
	MsgBox("Favor informar o cliente para este Item Contábil","Atencao","ALERT")
	lRet := .F.
	Return(lret)
ENDIF
lRet := U_fValItemCta("XX", lConta, wCLVL, wItemCta, cSubitem)
IF lRet == .F.
	Return(lret)
ENDIF

If FunName() == "EICPO400" .AND. EMPTY(wContrat)
    
	__aArea := GetArea()
	
	DbSelectArea("SW3")
	DbSetOrder(1)
	If SW3->(DbSeek(xFilial("SW3") + SW2->W2_PO_NUM)) 
		wContrat := SW3->W3_YCONTR
	EndIf
	
	RestArea(__aArea)

EndIf
    

IF (SUBSTR(wCLVL,1,1) == '8' .OR. ALLTRIM(wCLVL) == '2130' .OR. ALLTRIM(wCLVL) == '1045' .OR. ALLTRIM(wCLVL) == '3145' .OR. ALLTRIM(wCLVL) == '3184' .OR. ALLTRIM(wCLVL) == '3185') .AND. EMPTY(wContrat)
	//MsgAlert("O campo Contrato devera ser preenchido quando a Classe de Valor iniciar com 8.")
	MsgAlert("O campo Contrato devera ser preenchido quando a Classe de Valor for '" + Alltrim(wCLVL) + "'.")
	lRet := .F.
	Return(lret)
ENDIF
	
	// Origem SIGAEIC 
	If FunName() <> 'EICPO400' 
	
		// Valida Subitem de projeto
		If !U_BIAF160(wCLVL, wItemCta, cSubitem)
		
			MsgBox("A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!", "MT100LOK", "STOP")
			
			AutoGrLog("MT120LOK ==> A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!")
			
			lRet := .F.
						
		EndIf
		
	EndIf


IF !EMPTY(wContrat)
	DbSelectArea("SC3")
	DbSetOrder(1)
	DbSeek(xFilial("SC3")+wContrat)
	lPassei := .F.
	
	WHILE !EOF() .AND. SC3->C3_NUM == wContrat
		IF ALLTRIM(wCLVL) == ALLTRIM(SC3->C3_YCLVL)
			lPassei := .T.
			IF SC3->C3_MSBLQL == '1' .and. cCtrBloq <> 2 
				cCtrBloq := 1
			ELSE
				cCtrBloq := 2
			ENDIF
		ENDIF
		
		DbSelectArea("SC3")
		DbSkip()
	END
	
	IF cCtrBloq == 1
	   MsgAlert("[MT120LOK] Este contrato está bloqueado.")
	   cCtrBloq := 0
	   lRet := .F.
	   Return(lret)	   
	ENDIF
	
	IF !lPassei
		MsgAlert("A Classe de Valor deste PC deverá ser igual a Classe de Valor do Contrato informado.")
		lRet := .F.
		Return(lret)
	ENDIF
ENDIF


// Classe para validação do pedido de compra
If !oVldPedCom:ValidLine()
	Return(.F.)
EndIf

//Grava cotação da moeda em dólar=2 ou euro=5 no pedido de venda.
//O padrão do Protheus é gravar a moeda de acordo com a data base informada no sistema e não utiliza a data de emissão do pedido.
IF nMoedaped = 2 .OR. nMoedaped = 5
	//Busca a taxa pela data de emissão
	nTxmoeda := 1 * RECMOEDA(dA120emis, nMoedaped )
	IF nTxmoeda == 0
		//Busca a taxa pela data anterior a emissão
		//Se for Sábado ou Domingo, a taxa destes dias deverá ser cadastrada com a taxa de sexta-feira
		nTxmoeda := 1 * RECMOEDA(dA120emis-1, nMoedaped )
	ENDIF
ENDIF

If cArqSB1 <> ""
	dbSelectArea(cArqSB1)
	dbSetOrder(cIndSB1)
	dbGoTo(cRegSB1)
	RetIndex("SB1")
EndIf

If cArqSBZ <> ""
	dbSelectArea(cArqSBZ)
	dbSetOrder(cIndSBZ)
	dbGoTo(cRegSBZ)
	RetIndex("SBZ")
EndIf

If cArqSBM <> ""
	dbSelectArea(cArqSBM)
	dbSetOrder(cIndSBM)
	dbGoTo(cRegSBM)
	RetIndex("SBM")
EndIf

If cArqSF4 <> ""
	dbSelectArea(cArqSF4)
	dbSetOrder(cIndSF4)
	dbGoTo(cRegSF4)
	RetIndex("SF4")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(lret)


Static Function fUpdTabPrc(cCodFor, cLojFor, cCodPrd)
Local aArea := GetArea()
Local cSQL := ""
Local cQrySA5 := GetNextAlias()
Local cSA5 := RetSQLName("SA5")
Local cQryAIB := GetNextAlias()
Local cAIB := RetSQLName("AIB")

If !Empty(cCodFor) .And. !Empty(cLojFor) .And. !Empty(cCodPrd)
	
	cSQL := " SELECT TOP 1 AIB_CODTAB, AIB_PRCCOM "
	cSQL += " FROM " + cAIB
	cSQL += " WHERE AIB_CODFOR = " + ValToSQL(cCodFor)
	cSQL += " AND AIB_LOJFOR = " + ValToSQL(cLojFor)
	cSQL += " AND AIB_CODPRO = " + ValToSQL(cCodPrd)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY AIB_DATVIG DESC "
	
	TcQuery cSQL New Alias (cQryAIB)
	
	If !Empty((cQryAIB)->AIB_CODTAB) .And. (cQryAIB)->AIB_PRCCOM > 0
		dbSelectArea("SA5")
		dbSetOrder(1)
		If dbSeek(xFilial("SA5")+cCodFor+cLojFor+cCodPrd)
			While (!SA5->(Eof()).And. (cCodPrd == SA5->A5_PRODUTO .And. cCodFor == SA5->A5_FORNECE .And. cLojFor == SA5->A5_LOJA))
				RecLock("SA5",.F.)
				SA5->A5_CODTAB 	:= (cQryAIB)->AIB_CODTAB
				SA5->A5_YPRECO	:= (cQryAIB)->AIB_PRCCOM
				MsUnlock()
				
				dbSelectArea("SA5")
				SA5->(dbSkip())
			EndDo
		EndIf
		SA5->(dbCloseArea())
	EndIf
	
	(cQryAIB)->(DbCloseArea())
	
EndIf

RestArea(aArea)

Return()