#include "rwmake.ch"
#include "Protheus.ch"
/*/{Protheus.doc} MT241TOK
@author Nilton Cesar
@since 03.03.03
@version 1.0
@description Validar C.Custo e Aplicacao obrigatorio no mov. Interno II
.            MATA241 - Estoque
@type function
/*/

User Function MT241TOK()

	Local aArea 		:= GetArea()
	Local lret 			:= .T.
	Local cProduto	:= SPACE(15)
	Local nClasse		:= "0"
	Local lConta		:= .F.
	Local xxn
	Local n

	Local _nQuant			:= 0
	Local _cProd			:= ""
	Local _cLocalOri		:= ""
	Local _oObj				:= Nil
	Local _lValida			:= .T.
	Local _nSaldo			:= 0
	Local _nEmpenhoBizagi	:= 0

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
	If Type("_ExecAutoII") <> "U"
		Return(.T.)
	EndIf

	If Empty(Alltrim(aCV[1][2]))
		MsgBox("Classe de Valor em branco, favor preencher o mesmo para continuar!","Atencao","ALERT")
		lret := .F.
		RestArea(aArea)
		Return(lret)
	Else
		for xxn := 1 to Len(aCols)
			Gdfieldput("D3_CLVL",aCV[1][2],xxn)
			If SB1->(DbSeek(xFilial("SB1")+GdFieldGet("D3_COD",xxn)))
				If SB1->B1_GRUPO == '107A' .Or. SB1->B1_GRUPO == '107E' 
					If Alltrim(aCV[1][2]) == "3117" .Or. Alltrim(aCV[1][2]) == "3135" .Or. Alltrim(aCV[1][2]) == "3217"
						Gdfieldput("D3_CONTA","61110006",xxn)
					ElseIf Alltrim(aCV[1][2]) == "3136" 
						Gdfieldput("D3_CONTA","61110001",xxn)
					EndIf
				EndIf
			EndIf
		next
	EndIf

	//Passa todas as linhas
	For n := 1 to Len(acols)

		//Verifica se a Aplicacao esta em branco
		If CTM $ "003_005_502_506"
			If !GDDeleted()
				If Empty(Gdfieldget("D3_YAPLIC",n))
					MsgBox("Aplicacao em branco, favor preencher o mesmo para continuar!!","Atencao","ALERT")
					lret := .F.
					RestArea(aArea)
					Return(lret)
				EndIf
			EndIf
		EndIf

		//Verifica se o campo Serie+NF esta em Branco
		If CTM $ "509"
			If !GDDeleted()
				If Empty(Gdfieldget("D3_YSERIE",n)) .or. Empty(Gdfieldget("D3_YNF",n))
					MsgBox("Serie+NF em branco, favor preencher o mesmo para continuar!!","Atencao","ALERT")
					lret := .F.
					RestArea(aArea)
					Return(lret)
				EndIf
			EndIf
		EndIf

		If CTM $ "500"
			If !GDDeleted()
				nClasse		:= Posicione("SB1",1,xFilial("SB1")+Gdfieldget("D3_COD",n),"B1_YCLASSE")
				nEstrut  	:= Posicione("SB1",1,xFilial("SB1")+SUBSTR(Gdfieldget("D3_COD",n),1,7),"B1_YESTROK")
				If nClasse <> "5"
					DbSelectArea("SG1")
					DbSetOrder(1)
					DbSeek(xFilial("SG1")+SUBSTR(Gdfieldget("D3_COD",n),1,7),.T.)
					If SUBSTR(Gdfieldget("D3_COD",n),1,7) <> SUBSTR(SG1->G1_COD,1,7)
						MsgBox("Estrutura nao cadastrada para este produto: "+SUBSTR(Gdfieldget("D3_COD",n),1,7),"Atencao","ALERT")
						lret := .F.
						RestArea(aArea)
						Return(lret)
					EndIf
				EndIf
				If nEstrut <> "S"
					MsgBox("Produto com Estrutura bloqueada: "+SUBSTR(Gdfieldget("D3_COD",n),1,7),"Atencao","ALERT")
					lret := .F.
					RestArea(aArea)
					Return(lret)
				EndIf
			EndIf
		EndIf

		//Verifica digitacao do Almoxarifado
		nEmpr		:= Gdfieldget("D3_YEMPR",n)

		If !GDDeleted()

			nClVl 		:= Gdfieldget("D3_CLVL",n)
			nItemCta	:= Gdfieldget("D3_ITEMCTA",n)
			cSubitem	:= Gdfieldget("D3_YSUBITE",n)
			nSI     	:= Gdfieldget("D3_YSI",n)
			lConta 	:= .F.
			If Substr(Gdfieldget("D3_CONTA",n),1,5) == '31401' .OR. Substr(Gdfieldget("D3_CONTA",n),1,5) == '31406'
				IF ALLTRIM(Gdfieldget("D3_CONTA",n)) <> '31401017'
					lConta 	:= .T.
				ENDIF
			EndIf

			If lConta .And. ( Empty(nItemCta) .Or. Empty(nSI) )
				MsgBox("Para contas do Marketing (31401/31406), é obrigatório informar o Item Contábil e Cliente da AI","Atencao","ALERT")
				lRet := .F.
				RestArea(aArea)
				Return(lret)
			EndIf

			//Funcao para Validar o Item Contabil
			lret := U_fValItemCta("XX",lConta,nClVl,nItemCta, cSubitem)
			IF lRet == .F.
				RestArea(aArea)
				Return(lret)
			ENDIF

			IF SUBSTR(ALLTRIM(nItemCta),1,1) == 'I' .AND. EMPTY(nSI)
				MsgBox("Favor informar o cliente para este Item Contábil","Atencao","ALERT")
				lRet := .F.
				RestArea(aArea)
				Return(lret)
			ENDIF

		EndIf

		// Inserido por Marcos Alberto em 21/12/11 para atender a necessidade de baixas de insumos adicionais e/ou complementares para uma determinada OP
		If !GDDeleted() .and. Upper(Alltrim(FunName())) == "BIA257"

			If Alltrim(Gdfieldget("D3_OP",n)) <> Alltrim(kt_NUmOP)
				MsgSTOP("Esta funcionalidade do sistema exige que seja informado uma OP marcada na Tela de Montagem de Carga!!!", "MT241TOK[1]")
				lret := .F.
				RestArea(aArea)
				Return(lret)
			EndIf

		EndIf

		// Inserido por Marcos Alberto Soprani em 22/08/13 para atender a OS effettivo 1274-13
		If !GDDeleted() .and. CTM $ "120"

			If Posicione("SB1", 1, xFilial("SB1")+Gdfieldget("D3_COD",n), "B1_TIPO") <> "PI"
				MsgSTOP("A utilização da TM 120 somente está disponível para produtos TIPO = PI. Favor verificar!!!", "MT241TOK[2]")
				lret := .F.
				RestArea(aArea)
				Return(lret)
			EndIf

		EndIf

		//Fernando/Facile em 30/12/2015 - validar as tags com relacao a classe de valor
		If !GDDeleted() .And. !Empty(Gdfieldget("D3_YTAG",n))

			SZC->(DbSetOrder(1))
			SZC->(DbSeek(XFilial("SZC")+Gdfieldget("D3_YTAG",n)))
			If !SZC->ZC_VLDTAG $ " /N"
				If Alltrim(aCV[1][2]) <> AllTrim(SZC->ZC_CLVL)
					MsgAlert("TAG com classe de valor diferente do cabeçalho. Verificar a(s) TAG(s) ou informar a Classe: "+SZC->ZC_CLVL,"MT241TOK")
					lret := .F.
					RestArea(aArea)
					Return(lret)
				EndIf
			EndIf	

		EndIf 

		// Em 03/02/17... Por Marcos Alberto Soprani... ref OS 3513-16
		If !GDDeleted() .And. Empty(Gdfieldget("D3_YMATRIC",n))
			MsgAlert("É necessário informar o matricula que está efetuando a requisição/devolução para todas as linhas do documento antes de continuar!!!","MT241TOK")
			lret := .F.
			RestArea(aArea)
			Return(lret)
		EndIf

		If U_BFG81VCL(Alltrim(aCV[1][2])) .And. U_BFG81VCO(GdFieldGet("D3_CONTA",n))
			If Empty(GdFieldGet("D3_YDRIVER",n))
				MsgStop("A conta e a classe de valor(Crédito) selecionadas exigem que o driver seja informado!", "MT241TOK[3]")
				lRet	:=	.F.
				RestArea(aArea)
				Return(lret)
			EndIF
		EndIf

		if !GDDeleted() .and. Alltrim(GdFieldGet("D3_CONTA",n)) <> "41301001" //.And. !Empty(GdFieldGet("D3_CONTA",n)) .And. Substr(GdFieldGet("D3_CONTA",n),1,1) == '6' .And. !Empty(Alltrim(aCV[1][2])) 
			CTH->(DbSetOrder(1))
			If CTH->(DbSeek(xFilial("CTH")+PADR(aCV[1][2],TAMSX3("D3_CLVL")[1]))) .And. CTH->CTH_YATRIB == 'C' .And. GdFieldGet("D3_YAPLIC",n) $ ' _0'
				MsgStop("A Conta e a Classe de valor exigem que a Aplicação seja Informada e diferente de zero!", "MT241TOK[4]")
				lRet	:=	.F.
			endif
		endif

		// Para atender ao controle de Aplicação - Ticket 14649
		If !GDDeleted() .and. Substr(Gdfieldget("D3_CLVL",n),1,1) == "3"		
			If Empty(Gdfieldget("D3_YAPLIC",n))
				MsgBox("Campo aplicacao em branco, favor preencher o mesmo para continuar!!","Atencao","ALERT")
				lret := .F.
				RestArea(aArea)
				Return(lret)
			EndIf		
		EndIf
		
		// Valida Subitem de projeto
		If !GDDeleted() .And. !U_BIAF160(nClVl, nItemCta, cSubitem)
		
			MsgBox("A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!", "MT241TOK", "STOP")
			
			lRet := .F.
						
		EndIf
		

		wCod 		:= Gdfieldget('D3_COD',n)
		cAlmVend	:= Gdfieldget('D3_LOCAL',n)

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
		
		/*--Valida empenho bizagi--*/
		If !GDDeleted()
			If (CTM > '500' .And. !(SB1->B1_TIPO $ "PA#PP"))
				_cProd		:= Gdfieldget('D3_COD',	n)
				_cLocalOri	:= Gdfieldget('D3_LOCAL',	n)
				_nQuant 	:= Gdfieldget('D3_QUANT', n)
				
				
				_oObj		:= TValidaSaldo():New(_cProd, _cLocalOri, _nQuant)
				_lValida	:= _oObj:Check()
				
				_nSaldo			:= _oObj:nSaldo
				_nEmpenhoBizagi	:= _oObj:nEmpenhoBizagi
				lRet			:= _lValida
				
				If (IsBlind())
					If (!_lValida)
						Conout("Impossível prosseguir, Produto: "+cvalTochar(_cProd)+", quantidade da movimentação superior a disponivel no estoque."+CRLF+CRLF+" Saldo: "+cvalTochar(_nSaldo)+""+CRLF+" Empenho Bizagi: "+cvalTochar(_nEmpenhoBizagi)+""+CRLF+" Saldo Disp. Movimentação: "+cvalTochar((_nSaldo - _nEmpenhoBizagi))+" => MT241TOK")
					EndIf
				Else	
					If (!_lValida)
						MsgSTOP("Impossível prosseguir, Produto: "+cvalTochar(_cProd)+", quantidade da movimentação superior a disponivel no estoque."+CRLF+CRLF+" Saldo: "+cvalTochar(_nSaldo)+""+CRLF+" Empenho Bizagi: "+cvalTochar(_nEmpenhoBizagi)+""+CRLF+" Saldo Disp. Movimentação: "+cvalTochar((_nSaldo - _nEmpenhoBizagi))+"","MT241TOK")
					EndIf		
				EndIf
			EndIf
		EndIf
		/*--Fim valida empenho bizagi--*/
		

		If cArqSB1 <> ""
			dbSelectArea(cArqSB1)
			dbSetOrder(cIndSB1)
			dbGoTo(cRegSB1)
			RetIndex("SB1")
		EndIf
		
		
		

	Next n

	n := 1

	IF DA241DATA <> DDATABASE

		lRet := .F.
		MsgBox("Favor informar data correta","MT241TOK","STOP")

	ENDIF

	//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
	// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
	If dDataBase <= GetMv("MV_YULMES")

		MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MT241TOK[5]")
		lRet := .F.

	EndIf

	RestArea(aArea)

Return(lret)
