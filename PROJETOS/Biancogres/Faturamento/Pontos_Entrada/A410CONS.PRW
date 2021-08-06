#Include "RwMake.ch"
#Include "TOPCONN.CH"   
#include "vkey.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±?Funcao   ?	A410CONS    ?Autor ≥BRUNO MADALENO        ?Data ?03/11/05   ≥±?
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ?CRIANDO UM BOTAO NA TELA DE PEDIDOS DE VENDA PARA CHAMAR        ≥±?
±±?		 		 ?A ROTINA DE CONSULTA ESTOQUE							   ≥±?
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ?MP8 - Exportacao                                                ∫±?
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function A410CONS()
	Local aButton := {}  
	Local cEmpNPOL := AllTrim(GetNewPar("FA_EMPNPOL","14#"))
	Local I

	AADD(aButton,{ "PEDIDO"  , { || U_TOT_NOTA() },"Frete Autonomo" })
	//If ALLTRIM(UPPER(CUSERNAME)) $ "ADMINISTRADOR/RANISSES/WANISAY"
	If U_VALOPER("003",.F.) //Apenas para Diretores e Gerentes
		//AADD(aButton,{ "PEDIDO"  , { || U_CalcMargem(SC5->C5_NUM,"3") },"Margem" })
		//AADD(aButton,{ "PEDIDO"  , { || U_fMargem2(SC5->C5_NUM,"3") },"Margem2" })
		AADD(aButton,{ "PEDIDO"  , { || U_fMargem3(M->C5_NUM,"3") },"Margem Operacional" })
	EndIf

	If (Type("CREPATU") == "U" .Or. EMPTY(CREPATU)) .And. ALTERA
		AADD(aButton,{ "PEDIDO"  , {|| U_FR03ITEX() },"Cancelar Reserva" })
		AADD(aButton,{ "PEDIDO"  , {|| U_FR03ITRE() },"Res.Estoque Manual" })
		AADD(aButton,{ "PEDIDO"  , {|| U_FR03ITRO() },"Res.OP Manual" })
	EndIf

	If Upper(AllTrim(FunName())) == "BIA485"
		AADD(aButton,{ "PEDIDO"  , {|| U_BIAFR006() },"Imprimir Pedido" })
	EndIf

	//If (Inclui .Or. Altera)
	AADD(aButton,{ "PEDIDO"  , {|| U_BIAF022() },"Parcela Contrato" })
	//EndIf
	AADD(aButton,{ "PEDIDO"  , {|| U_BIA584() },"Total Quant." })

	// Tiago Rossini Coradini - 24/04/2017 - OS: 0274-17 - Camila Brandemburg 	
	aAdd(aButton, {"PEDIDO", {|| U_BIAF073() },  "Proposta Engenharia"})

	If Upper(AllTrim(getenvserver())) $ "COMP-FERNANDO###"
		AADD(aButton,{ "PEDIDO"  , {|| U_BPRECZA4(M->C5_NUM)},"Reproc.Polit.ZA4." })
	EndIf

	//Tecla de atalho para consultar a composicao do desconto
	If !(AllTrim(cEmpAnt) $ cEmpNPOL)
		SetKey(K_CTRL_F5,{|| U_POLCDESC(Inclui) })
	EndIf

Return(aButton)


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ?
//≥Calcula Total ICMS Frete Autonome?
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ?
User Function TOT_NOTA()

	Local Enter 		:= CHR(13)+CHR(10)
	Local nBase			:= 0
	Local nIcmsFre		:= 0
	Local aVlr			:= {}
	Local cMUN			:= ""
	Local cEST			:= ""
	Local cTpTrans		:= Posicione("SA4",1,xFilial("SA4")+M->C5_TRANSP,"A4_YTIPO")
	Local cUFTrans		:= SA4->A4_EST
	Local I

	If Alltrim(M->C5_YFLAG) == "2"	//Busca UF e MUN do Local de Entrega
		cEST	:= M->C5_YEST
		cMUN	:= M->C5_YCODMUN	//M->C5_YMUN
	Else
		IF !(M->C5_TIPO $ "DB")
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.T.)
				cEST	:= SA1->A1_EST
				cMUN	:= SA1->A1_COD_MUN //SA1->A1_MUN
			EndIf
		ELSE
			DbSelectArea("SA2")
			DbSetOrder(1)
			If DbSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI,.T.)
				cEST	:= SA2->A2_EST
				cMUN	:= SA2->A2_COD_MUN //SA2->A2_MUN
			EndIf
		ENDIF
	EndIf

	//Se o Transportador for do Tipo 1 Autonomo ou Tipo 2 Transportadora de fora do estado - OS 3724-16 
	If (cTpTrans == "1") .Or. (cTpTrans == "2" .And. !cUFTrans == "ES")
		For I := 1 To Len(ACOLS)
			nProduto	:= Gdfieldget("C6_PRODUTO",I)
			nLote		:= Gdfieldget("C6_LOTECTL",I)
			nQuant 	 	:= Gdfieldget("C6_QTDVEN",I)             
			aVlr 		:= U_fCalcFreteAut(cEst,cMun,nProduto,nLote,nQuant)
			nBase		+= aVlr[1]
			nIcmsFre	+= aVlr[2]
		Next	
	EndIf

	cMsn := "Valor Base Frete Autonomo"	+ REPLICATE(".",02) + Transform(nBase, 		 "@E 999,999,999.99") + Enter
	cMsn += "Valor ICMS Frete Autonomo"	+ REPLICATE(".",02) + Transform(nIcmsFre,	 "@E 999,999,999.99")
	MsgBox(cMsn ,"INFO","INFO")

Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹?
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
//Fernando/Facile em 25/08/2015 - validar e chamar funcao de composicao desconto
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ?
User Function POLCDESC(_lInclui)
	Local aArea := GetArea() 

	If (Type("N") <> "U") .And. (N > 0) .And. (Len(aCols) >= N)

		U_BPOLTST1(.T., _lInclui)

	EndIf

	RestArea(aArea)
Return
