#include "rwmake.ch"
#include "topconn.ch"
#include "Protheus.ch"

/*/{Protheus.doc} MT240TOK
@author Nilton Cesar
@since 03.03.03
@version 1.0
@description Valida o preenchimento do data de emissao
.            MATA240 - Estoque
@type function
/*/

User Function MT240TOK()

	Local _aArea	:=	GetArea()

	Local _nQuant			:= 0
	Local _cProd			:= ""
	Local _cLocalOri		:= ""
	Local _oObj				:= Nil
	Local _lValida			:= .T.
	Local _nSaldo			:= 0
	Local _nEmpenhoBizagi	:= 0
	

	Private lRet 	:= .T.
	Private lConta 	:= .F.
	
	
	

	IF Type("_IViaEAuto") <> "U"
		Return(.T.)
	ENDIF

	IF Type("_ExecAutoII") <> "U"
		Return(.T.)
	ENDIF

	//Por Marcos Alberto Soprani em 25/05/12 para atender a integração com o programa BIA292 quando executado via Schedule
	If Type("_ExcAut292") <> "U"
		Return(.T.)
	EndIf

	If Upper(Alltrim(FunName())) $ "BIA271/BIA292/BIA294/BIA701/BIA742/BIA785/BIA570" .Or. IsInCallsTack("U_BIAFG120") // retirado por Marcos Alberto em 07/05/12
		If dDataBase < GetMv("MV_ULMES")
			lRet := .F.
			MsgBox("Favor informar data correta(1)", "MT240TOK", "STOP")
		EndIf
		Return(lRet)
	ElseIf M->D3_EMISSAO <> DDATABASE
		lRet := .F.
		MsgBox("Favor informar data correta(2)", "MT240TOK", "STOP")
		Return(lRet)
	EndIf

	If Substr(M->D3_CONTA,1,5) == '31401' .OR. Substr(M->D3_CONTA,1,5) == '31404'
		IF ALLTRIM(M->D3_CONTA) <> '31401017'
			lConta 	:= .T.
		ENDIF
	EndIf

	//Funcao para Validar o Item Contabil
	lRet := U_fValItemCta("XX",lConta,M->D3_CLVL,M->D3_ITEMCTA, M->D3_YSUBITE)
	IF lRet == .F.
		Return(lRet)
	ENDIF

	IF SUBSTR(ALLTRIM(M->D3_ITEMCTA),1,1) == 'I' .AND. EMPTY(M->D3_YSI)
		MsgBox("Favor informar o cliente para este Item Contábil","Atencao","ALERT")
		lRet := .F.
		Return(lRet)
	ENDIF

	// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
	//IF M->D3_TM == "500"
	IF M->D3_TM <= '500' .and. M->D3_YORIMOV == "PR0"
		DbSelectArea("SG1")
		DbSeek(xFilial("SG1")+M->D3_COD)
		IF SG1->G1_COD <> M->D3_COD
			MsgBox("Este produto que está sendo produzido não contém estrutura cadastrada! ","STOP")
			lRet := .F.
			Return(lRet)
		ENDIF
	ENDIF

	// Inserido por Marcos Alberto Soprani em 22/08/13 para atender a OS effettivo 1274-13
	If M->D3_TM $ "120"
		If Posicione("SB1", 1, xFilial("SB1")+M->D3_COD, "B1_TIPO") <> "PI"
			MsgSTOP("A utilização da TM 120 somente está disponível para produtos TIPO = PI. Favor verificar!!!")
			lRet := .F.
			Return(lRet)
		EndIf
	EndIf

	//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
	// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
	If M->D3_EMISSAO <= GetMv("MV_YULMES")
		MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MT240TOK")
		lRet := .F.
	EndIf

	If SB1->(DbSeek(xFilial("SB1")+M->D3_COD))
		If SB1->B1_GRUPO == '107A' .Or. SB1->B1_GRUPO == '107E' 
			If Alltrim(M->D3_CLVL) == "3117" .Or. Alltrim(M->D3_CLVL) == "3135" .Or. Alltrim(M->D3_CLVL) == "3217"
				M->D3_CONTA := "61110006"
			ElseIf Alltrim(M->D3_CLVL) == "3136" 
				M->D3_CONTA	:=	"61110001"
			EndIf
		EndIf
	EndIf

	//Validação referente ao Driver
	If U_BFG81VCL(M->D3_CLVL) .And. U_BFG81VCO(M->D3_CONTA)
		If Empty(M->D3_YDRIVER)
			MsgStop("A conta e a classe de valor(Crédito) selecionadas exigem que o driver seja informado!")
			RestArea(_aArea())
			lRet	:=	.F.
		EndIF
	EndIf

	If !Empty(M->D3_CONTA) .And. Alltrim(M->D3_CONTA) <> "41301001"  //Substr(M->D3_CONTA,1,1) == '6' .And. !Empty(M->D3_CLVL) 
		CTH->(DbSetOrder(1))
		If CTH->(DbSeek(xFilial("CTH")+M->D3_CLVL)) .And. CTH->CTH_YATRIB == 'C' .And. M->D3_YAPLIC $ ' _0'
			MsgStop("A Conta e a Classe de valor exigem que a Aplicação seja Informada e diferente de zero!")
			lRet	:=	.F.
		endif
	Endif

	// Para atender ao controle de Aplicação - Ticket 14649
	If Substr(M->D3_CLVL,1,1) == "3"		
		If Empty(M->D3_YAPLIC)
			MsgBox("Campo aplicacao em branco, favor preencher o mesmo para continuar!!","Atencao","ALERT")
			lret := .F.
		EndIf		
	EndIf	
	
	wCod 		:= M->D3_COD
	cAlmVend	:= M->D3_LOCAL
	
	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+wCod,.F.)
	
	If !(SB1->B1_TIPO $ "PA#PP") .And. cAlmVend $ "02#04"
		MsgBox("Almoxarifado destino incorreto: " + cAlmVend,"MT240TOK","STOP")
		zlRet := .F.			
	EndIf
	
	/*--Valida empenho bizagi--*/
	If (M->D3_TM > '500' .And. !(SB1->B1_TIPO $ "PA#PP"))
		
		_nQuant 	:= M->D3_QUANT
		_cProd		:= M->D3_COD
		_cLocalOri	:= M->D3_LOCAL
		
		_oObj		:= TValidaSaldo():New(_cProd, _cLocalOri, _nQuant)
		_lValida	:= _oObj:Check()
		
		_nSaldo			:= _oObj:nSaldo
		_nEmpenhoBizagi	:= _oObj:nEmpenhoBizagi
		lRet			:= _lValida
		
		If (IsBlind())
			If (!_lValida)
				Conout("Impossível prosseguir, quantidade da movimentação superior a disponivel no estoque."+CRLF+CRLF+" Saldo: "+cvalTochar(_nSaldo)+""+CRLF+" Empenho Bizagi: "+cvalTochar(_nEmpenhoBizagi)+""+CRLF+" Saldo Disp. Movimentação: "+cvalTochar((_nSaldo - _nEmpenhoBizagi))+" => MT240TOK")
			EndIf
		Else	
			If (!_lValida)
				MsgSTOP("Impossível prosseguir, quantidade da movimentação superior a disponivel no estoque."+CRLF+CRLF+" Saldo: "+cvalTochar(_nSaldo)+""+CRLF+" Empenho Bizagi: "+cvalTochar(_nEmpenhoBizagi)+""+CRLF+" Saldo Disp. Movimentação: "+cvalTochar((_nSaldo - _nEmpenhoBizagi))+"","MT240TOK")
			EndIf		
		EndIf
	
	EndIf
	/*--Fim valida empenho bizagi--*/

	// Valida Subitem de projeto
	If !U_BIAF160(M->D3_CLVL, M->D3_ITEMCTA, M->D3_YSUBITE)
	
		MsgBox("A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!", "MT240TOK", "STOP")
		
		lRet := .F.
					
	EndIf
	
	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf
	
	

	RestArea(_aArea)

Return(lRet)
