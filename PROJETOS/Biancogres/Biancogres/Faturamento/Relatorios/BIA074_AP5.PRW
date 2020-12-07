#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#include "TOPCONN.ch" 
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function Bia074()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
	SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,WNUMBER,CBCONT")
	SetPrvt("CABEC1,CABEC2,C15,CBTXT,LI,M_PAG")
	SetPrvt("WPEDIDE,WPEDIATE,WVENDDE,WVENDATE,WENTRDE,WENTRATE")
	SetPrvt("ACAMPO,_cTrb,WOLDDATA,WINCREGUA,WPRODUTO,WFORMATO")
	SetPrvt("WTIPO,WSALPRO,WCTRANSP,WTRANSP,WATZSUPRIS,WLIMCRED")
	SetPrvt("WSALOK,WSALDUP,WOBSERV,WRISCO,TOTPEDIDO,TOTCLIENTE")
	SetPrvt("TOTREPRESE,TOTGERAL,MEDIAS,OLDVEND,OLDCLI,OLDPED")
	SetPrvt("WPRIMVEZ,WLINDEIMP,")
	Private csituaca,csitutmp,limprime
	Private nDiasVenc  //ALTERADO PELO BRUNO 31 05 06
	//Programa	: BIA074
	//Autor		: _cTrb
	//Data		: 02.12.1999
	//Descricao : Mapa de pedidos nao atendidos - Por Vendedor
	//Ordem		: Representante+Pedido+produto
	//Uso 		: SIGAFAT

	//Inicializa variaveis
	cDesc1			:= "Este programa tem como objetivo emitir um mapa de Pedidos"
	cDesc2			:= "nao atendidos por vendedor.             "
	cDesc3			:= ""
	tamanho			:= "G"
	limite			:= 220
	cString			:= "SC5"
	titulo			:= "MAPA DE PEDIDO NAO ATENDIDOS"
	aReturn			:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	NomeProg 		:= "BIA074_NOV"
	nLastKey 		:= wNumber := cbcont := 0
	Cabec1			:= "CODIGO  DATA DE   CODIGO DO  DESCRICAO DO                       PRECO      _________VOLUME(M2)__________        PESO                                                                                        PRAZO "
	Cabec2			:= "PEDIDO  EMISSAO   PRODUTO    PRODUTO                            MEDIO      PEDIDO    ATENDIDO      SALDO       BRUTO  OBSERVACAO                        TRANSPORTADORA       ENTREGA        COND.PAG        MEDIO "
	C15				:= 15                                                                                                                                                                                                               
	cbtxt 			:= space(10)
	li 				:= 80
	m_pag 			:= 1

	//Envia controle para a funcao SETPRINT
	NomeProg := SetPrint(cString,NomeProg,NomeProg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

	IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	ENDIF

	//Verifica Posicao do Formulario na Impressora
	SetDefault(aReturn,cString)

	PERGUNTE( NomeProg, .F. )
	csituaca := mv_par07

	IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	ENDIF

	wPediDe	  := mv_par01 // pedido de
	wPediAte  := mv_par02 // pedido ate
	wVendDe	  := mv_par03 // vendedor de
	wVendAte  := mv_par04 // vendedor ate
	wEntrDe	  := mv_par05 // emissao do pedido de
	wEntrAte  := mv_par06 // emissao do pedido ate

	IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	ENDIF

	fCriaArq()

	RptStatus({|| fMapAtePed() })  // Fun‡Æo Mapa de Atendimento de Pedidos// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	RptStatus({|| Execute(fMapAtePed) })  // Fun‡Æo Mapa de Atendimento de Pedidos

	DBSELECTAREA("_cTrb")
	DBCLOSEAREA("_cTrb")

	FERASE(_cTrb+".DBF")
	FERASE(_cTrb+".*")

	//Libera impressao
	IF aReturn[5] == 1
		Set Printer To
		Ourspool(NomeProg)
	ENDIF

	MS_FLUSH()

	//Fim do programa

RETURN


// CRIA ARQUIVO TEMPORARIO
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCriaArq
Static FUNCTION fCriaArq()

	aCampo := {}
	AADD(aCampo,{ "PRODUTO ", "C", 15, 0 })
	AADD(aCampo,{ "CLIENTE ", "C", 50, 0 })
	AADD(aCampo,{ "CIDADE"  , "C", 40, 0 })
	AADD(aCampo,{ "VENDEDOR", "C", 50, 0 })
	AADD(aCampo,{ "CONDPAG" , "C", 20, 0 })
	AADD(aCampo,{ "PEDIDO  ", "C", 06, 0 })
	AADD(aCampo,{ "ITEM    ", "C", 02, 0 })
	AADD(aCampo,{ "EMISSAO" , "D", 08, 0 })
	AADD(aCampo,{ "ENTREGA" , "D", 08, 0 })
	AADD(aCampo,{ "DESC    ", "C", 30, 0 })
	AADD(aCampo,{ "PRCUNI  ", "N", 12, 2 })
	AADD(aCampo,{ "QTDPED  ", "N", 12, 2 })
	AADD(aCampo,{ "QTDJENT ", "N", 12, 2 })
	AADD(aCampo,{ "SALDO   ", "N", 12, 2 })
	AADD(aCampo,{ "PBRUTO  ", "N", 12, 2 })
	AADD(aCampo,{ "OBS     ", "C", 30, 0 })
	AADD(aCampo,{ "TRANSP  ", "C", 15, 0 })
	AADD(aCampo,{ "YRECR   ", "C",  1, 0 })
	AADD(aCampo,{ "YMEDIA  ", "N",  3, 0 })
	AADD(aCampo,{ "DIASVENC", "N",  4, 0 })


	_cTrb := CRIATRAB(aCampo, .T.)
	DBUSEAREA(.T.,,_cTrb,"_cTrb")

	DBCREATEINDEX(_cTrb,"VENDEDOR+CLIENTE+PEDIDO",{|| VENDEDOR+CLIENTE+PEDIDO} )

RETURN


// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fMapAtePed
Static FUNCTION fMapAtePed()

	Local x

	DBSELECTAREA("SC5")
	DBSETORDER(2)

	//	DBSEEK(xFILIAL("SC5")+DTOS(wEntrDe)+wPediDe, .T.)
	DBSEEK(xFILIAL("SC5")+DTOS(wEntrDe), .T.)

	SETREGUA( wEntrAte - wEntrDe )
	wOldData := CTOD("")

	WHILE !EOF() .AND. ( SC5->C5_EMISSAO <= wEntrAte ) //Alterado por Ranisses


		// VALIDA: SE FOI INCREMENTADA A DATA
		IF wOldData == CTOD("") .OR. wOldData < SC5->C5_EMISSAO
			wIncRegua := IIF( wOldData == CTOD(""), 1, SC5->C5_EMISSAO - wOldData )
			wOldData  := SC5->C5_EMISSAO
		ENDIF

		// VALIDA: SE FOI INCREMENTADA A REGUA
		IF wIncRegua > 0
			INCREGUA( wIncRegua )
			wIncRegua := 0
		ENDIF

		// VALIDA: SE FOI PRESSIONADO [ESC]
		IF ( LASTKEY() == 27 )
			EXIT
		ENDIF

		// VALIDA: SE O CODIGO DO PEDIDO ESTA NO INTERVALO DOS PARAMETROS
		IF ( SC5->C5_NUM < wPediDe ) .or. ( SC5->C5_NUM > wPediAte )
			DBSELECTAREA("SC5")
			DBSKIP()
			LOOP
		ENDIF

		IF SC5->C5_TIPO <> "N"
			DBSELECTAREA("SC5")
			DBSKIP()
			LOOP
		ENDIF

		// VALIDA: SE CODIGO DO VENDEDOR ESTA NO INTERVALO DOS PARAMETROS
		IF ( SC5->C5_VEND1 < wVendDe ) .or. ( SC5->C5_VEND1 > wVendAte )
			DBSELECTAREA("SC5")
			DBSKIP()
			LOOP
		ENDIF

		DBSELECTAREA("SC6")
		DBSETORDER(1)
		IF !DBSEEK( xFILIAL("SC6") + SC5->C5_NUM, .T.)
			//ALERT( "ITENS DO PEDIDO " + SC5->C5_NUM + " NAO ENCONTRADO" )
			DBSELECTAREA("SC5")
			DBSKIP()
			LOOP
		ENDIF
		WHILE !EOF() .AND. ( SC6->C6_NUM == SC5->C5_NUM )
			//VALIDA: SE O ITEM DO PEDIDO AINDA NAO FOI ATENDIDO
			IF ( SC6->C6_QTDVEN - SC6->C6_QTDENT == 0 )
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF
			//BUSCA: CLIENTE NO CADASTRO DE CLIENTE
			DBSELECTAREA("SA1")
			DBSETORDER(1)
			IF ! DBSEEK ( xFILIAL("SA1")+SC5->C5_CLIENTE,.T. )
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF
			DBSELECTAREA("SB1")
			DBSETORDER(1)
			// PESQUISA: SE PRODUTO EXISTE NO CADASTRO DE PRODUTOS
			wProduto := AllTrim(SC6->C6_PRODUTO)
			IF !DBSEEK( xFilial("SB1")+wProduto,.T. )
				//ALERT( "PRODUTO " + wProduto + " NAO ENCONTRADO" )
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF

			/*aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
			DbSelectArea("ZZ9")
			DbSetOrder(1)
			IF !DbSeek(xFilial("ZZ9")+ aCODPRODUTO + SD2->D2_LOTECTL )
			sPESEMB := ZZ9->ZZ9_PESEMB
			sPESO	:= ZZ9->ZZ9_PESO
			sDIVPA	:= ZZ9->ZZ9_DIVPA
			END IF		*/
			aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
			cSQLL := ""							
			cSQLL := "SELECT * FROM ZZ9010 "
			cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
			cSQLL += "		ZZ9_LOTE = '" +SD2->D2_LOTECTL+ "' AND "
			cSQLL += "		D_E_L_E_T_ = '' "
			IF chkfile("_ZZ9")
				dbSelectArea("_ZZ9")
				dbCloseArea()
			ENDIF
			TCQuery cSQLL Alias "_ZZ9" New							
			IF ! _ZZ9->(EOF())
				sPESEMB := _ZZ9->ZZ9_PESEMB
				sPESO	:= _ZZ9->ZZ9_PESO
				sDIVPA	:= _ZZ9->ZZ9_DIVPA
			END IF															


			IF SUBST(SB1->B1_TIPO,1,2) <> "PA"
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o produto e um piso.								         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			wFormato := Left(wProduto,1)
			wTipo 	:= SubStr(wProduto,6,1)


			/*DBSELECTAREA("SB2")
			DBSETORDER(1)
			IF !DBSEEK(XFILIAL("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)
			wSalPro := 0
			ELSE
			wSalPro := SB2->B2_QATU
			ENDIF*/

			wSalPro := 0

			DBSELECTAREA("SBF")
			DBSETORDER(2)
			DBSEEK(xFilial("SBF")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.)
			WHILE !EOF() .and. SC6->C6_PRODUTO+SC6->C6_LOCAL == BF_PRODUTO+BF_LOCAL .AND. XFILIAL("SBF") == BF_FILIAL
				wSalPro := wSalPro + SBF->BF_QUANT - SBF->BF_EMPENHO
				DBSKIP()
			ENDDO

			DBSELECTAREA("SA4")
			DBSETORDER(1)

			wcTransp := SPACE(6)
			IF Empty(SC5->C5_TRANSP)
				wcTransp := "999999"
			ELSE
				wcTransp := SC5->C5_TRANSP
			ENDIF

			// PESQUISA: SE A TRANSPORTADORA EXISTE
			IF !DBSEEK( xFilial("SA4")+wcTransp,.T. )
				//ALERT( "TRANSPORTADORA " + wcTransp + " NAO ENCONTRADA" )
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ELSEIF ( wcTransp == "999999" )
				wTransp := "CLIENTE RETIRA"
			ELSE
				wTransp := SA4->A4_NREDUZ
			ENDIF

			DBSELECTAREA("SA3")
			DBSETORDER(1)

			// PESQUISA: CADASTRO DE VENDEDORES
			IF !DBSEEK( xFilial("SA3")+SC5->C5_VEND1,.T. )
				//ALERT( "VENDEDOR " + SC5->C5_VEND1 + " NAO ENCONTRADO" )
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF

			DBSELECTAREA("SE4")
			DBSETORDER(1)

			// PESQUISA: CADASTRO DE CONDICOES DE PAGAMENTO
			IF !DBSEEK( xFilial("SE4")+SC5->C5_CONDPAG,.T. )
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF                      

			csitutmp := ""
			cDiasVenc := 0  //ALTERADO PELO BRUNO 31 05 06
			fGerObs()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se as opcoes escolhidas fazer parte da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			limprime := .f.
			For x:=1 to Len(Alltrim(csituaca))
				If Subs(csituaca,x,1) $ csitutmp
					limprime := .T.
				EndIf
			Next
			If !limprime
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSkip()
				Loop
			EndIf		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gravar arquivo temporario                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fGrava()
			DBSELECTAREA("SC6")
			DBSETORDER(1)
			DBSKIP()
		ENDDO

		DBSELECTAREA("SC5")
		DBSETORDER(2)
		DBSKIP()
	ENDDO

	fImprime()

RETURN( NIL )


// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGerObs
Static FUNCTION fGerObs()

	//VERIFICA INADIMPLENCIA ( TITULOS EM ATRAZO A MAIS DE 12 DIAS )
	DBSELECTAREA("SE1")
	DBSETORDER(2)
	DBSEEK(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA,.F.)

	wAtzSupRis := wLimCred := wSalOk := .F.
	wSalDup	  := 0
	wObserv	  := ""
	//wRisco	  := If(ALLTRIM(SA1->A1_RISCO)=="E",0,GETMV("MV_RISCO"+ALLTRIM(SA1->A1_RISCO))) Alterado por Ranisses

	//Alterado por Ranisses 
	if ALLTRIM(SA1->A1_RISCO) == "E" 
		wRisco := 0
	elseif ALLTRIM(SA1->A1_RISCO) == "A"  
		wRisco := 999999
	else
		wRisco := GETMV("MV_RISCO"+ALLTRIM(SA1->A1_RISCO))
	endif


	//************************* BRUNO MADALENO ********************************
	//********************* AVALIACAO CREDITO NOVO ****************************
	ENTER := CHR(13) + CHR(10)
	CSQL := "SELECT SE1.*, SA1.A1_LC " + ENTER
	CSQL += "FROM SE1010 SE1, SA1010 SA1 " + ENTER
	CSQL += "WHERE	SE1.E1_SALDO > 0 AND " + ENTER
	CSQL += "		SE1.E1_CLIENTE = A1_COD AND " + ENTER
	CSQL += "		SE1.E1_LOJA = A1_LOJA AND " + ENTER
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
	ELSE
		CSQL += "		SA1.A1_COD = '"+SA1->A1_COD+"' AND  " + ENTER
	END IF
	CSQL += "		SE1.D_E_L_E_T_ = '' AND " + ENTER
	CSQL += "		SA1.D_E_L_E_T_ = '' " + ENTER
	IF CHKFILE("_SE1")
		DBSELECTAREA("_SE1")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_SE1" NEW


	//PROCURA: DUPLICATAS COM MAIS DE 12 DIAS DE ATRAZO
	//WHILE !EOF().and. SA1->A1_COD+SA1->A1_LOJA == E1_CLIENTE+E1_LOJA .AND. XFILIAL("SE1") == E1_FILIAL
	WHILE ! _SE1->(EOF())

		IF _SE1->E1_SALDO <= 0
			DBSKIP()
			LOOP
		ENDIF

		If cDiasVenc < dDataBase - STOD(_SE1->E1_VENCTO )        //ALTERADO PELO BRUNO 31 05 06
			cDiasVenc := (dDataBase - STOD(_SE1->E1_VENCTO ))   //ALTERADO PELO BRUNO 31 05 06
		End if                                           //ALTERADO PELO BRUNO 31 05 06

		IF ( dDataBase - STOD(_SE1->E1_VENCTO ) ) > wRisco
			wAtzSupRis := .T.
		ENDIF

		wSalDup := wSalDup + _SE1->E1_SALDO

		IF wAtzSupRis .AND. wSalDup > _SE1->A1_LC
			EXIT
		ENDIF

		_SE1->(DBSKIP())
	ENDDO


	DbSelectArea("SC9")     
	DbSetOrder(12)               // Alterado por Luana em 24/11/04.
	//cfiltro := "C9_NFISCAL == ''" 
	//Set filter to cfiltro
	Set filter to Empty(SC9->C9_NFISCAL)
	If DbSeek(xFilial("SC9")+SC6->C6_PRODUTO+SC6->C6_NUM)
		DbSelectArea("SZ9")
		DbSetOrder(7)
		If DbSeek( xFILIAL("SZ9") + SC6->C6_PRODUTO+SC6->C6_LOCAL+SC6->C6_NUM+SC9->C9_AGREG, .T.)
			If Empty(SC9->C9_NFISCAL)
				wObserv := wObserv + "1-EM ROMANEIO "
				csitutmp+="1"
			EndIf
		EndIf
	Else
		//VERIFICA SALDO EM ESTOQUE
		If wSalPro < ( SC6->C6_QTDVEN - SC6->C6_QTDENT )
			wObserv := wObserv + "2-SEM ESTOQUE "
			csitutmp+="2"
		EndIf
	EndIf
	DbSelectArea("SZ9")
	//VERIFICA LIMITE DE CREDITO
	IF SA1->A1_LC < ( wSalDup+SC6->C6_VALOR )
		wObserv := wObserv + "3-CRED.ESGOTADO "
		csitutmp+="3"
	ENDIF

	//DEFINE: OBSERVACAO PARA CLIENTES SEM CREDITO
	IF wAtzSupRis
		wObserv := wObserv + "4-ATZ > "+ Alltrim(STR(wRisco))+space(1)
		csitutmp+="4"
	ENDIF

	//Checar se o pedido esta liberado
	SC9->(DbSetOrder(11))                  //Alterado por Luana em 24/11/04.
	If !SC9->(DbSeek(xFilial("SC9")+SC6->C6_PRODUTO+SC6->C6_NUM))
		If Empty(wObserv)
			wObserv := wObserv + "5-NORMAL"
			csitutmp+="5"
		EndIf
	Else
		If SC9->C9_BLEST == "02"
			wObserv := wObserv + "2-SEM ESTOQUE "
			csitutmp+="2"   	
		EndIf
		If SC9->C9_BLCRED == "01"
			wObserv := wObserv + "3-CRED.ESGOTADO "
			csitutmp+="3"
		EndIf
		If Empty(wObserv)
			wObserv := wObserv + "5-NORMAL"//"6-LIBERADO PARA ROMANEIO"
			csitutmp+="5"//"6"
		EndIf
	EndIf



RETURN( NIL )



//GRAVA: DADOS MONTADOS APARTIR DO SIGA EM TABELA TEMPORARIA
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGrava
Static FUNCTION fGrava()



	DBSELECTAREA("_cTrb")

	WHILE !RECLOCK( "_cTrb",.T.); ENDDO

	nPesoCaixas   := 0
	_cTrb->VENDEDOR := SC5->C5_VEND1+"-"+SA3->A3_NOME
	_cTrb->CLIENTE  := SA1->A1_COD+"-"+SA1->A1_NOME 					
	_cTrb->CIDADE   := ALLTRIM(SA1->A1_MUN)+"/"+ALLTRIM(SA1->A1_EST)
	_cTrb->PEDIDO   := SC5->C5_NUM
	_cTrb->ITEM	    := SC6->C6_ITEM
	_cTrb->PRODUTO  := SC6->C6_PRODUTO
	_cTrb->DESC	    := SB1->B1_YREF
	_cTrb->EMISSAO  := SC5->C5_EMISSAO
	_cTrb->CONDPAG  := SE4->E4_DESCRI
	_cTrb->ENTREGA  := SC6->C6_ENTREG
	_cTrb->PRCUNI   := SC6->C6_PRCVEN
	_cTrb->QTDPED   := SC6->C6_QTDVEN
	_cTrb->QTDJENT  := SC6->C6_QTDENT
	_cTrb->SALDO    := SC6->C6_QTDVEN - SC6->C6_QTDENT
	//nPesoCaixas     := IF(SB1->B1_TIPCONV=="D",(_cTrb->SALDO/SB1->B1_CONV)*SB1->B1_YPESEMB,(_cTrb->SALDO*SB1->B1_CONV)*SB1->B1_YPESEMB)
	nPesoCaixas     := IF(SB1->B1_TIPCONV=="D",(_cTrb->SALDO/SB1->B1_CONV)*sPESEMB,(_cTrb->SALDO*SB1->B1_CONV)*sPESEMB)
	//_cTrb->PBRUTO   := IF(SB1->B1_TIPCONV=="D",_cTrb->SALDO*SB1->B1_PESO,_cTrb->SALDO/SB1->B1_PESO)
	_cTrb->PBRUTO   := IF(SB1->B1_TIPCONV=="D",_cTrb->SALDO*sPESO,_cTrb->SALDO/sPESO)
	_cTrb->PBRUTO   := _cTrb->PBRUTO + nPesoCaixas
	_cTrb->OBS 	    := wObserv
	_cTrb->TRANSP   := wTransp      
	_cTrb->YRECR    := SC5->C5_YRECR 
	_cTrb->YMEDIA   := SE4->E4_YMEDIA
	_cTrb->DIASVENC := cDiasVenc   //ALTERADO PELO BRUNO 31 05 06

	MSUNLOCK()

RETURN


//IMPRIME: OS DADOS DA TABELA TEMPORµRIA
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()
	Private ltotal := .f.                                           

	Private npf_pedq:=0,npf_gerq:=0,npf_cliq:=0,npfsemv:=0,npf_semq:=0
	Private npf_vdq:=0, npf_comv:=0,npf_comq:=0
	Private npf_fim1q:=npf_fim2q:=npf_fim3q:=npf_fim4q:=npf_fim5q:=npf_fim6q:=0
	Private npf_pedvl:=0,npf_clivl:=0,npf_repvl:=0,npf_totvl:=0,npf_totgeral:=0
	Private totGerCli:=0,totGerRep:=0,TotalGer:=0,nPrazo:=0

	DBSELECTAREA("_cTrb")
	DBGOTOP()

	SETREGUA( _cTrb->( LASTREC() ) )

	// SE€ÇO PARA INICIALIZA€ÇO DAS VARIµVEIS DE TRABALHO

	totPedido  := { 0, 0, 0, 0, 0 }
	totCliente := { 0, 0, 0, 0, 0 }
	totReprese := { 0, 0, 0, 0, 0 }
	totGeral   := { 0, 0, 0, 0, 0 }
	ntot1      := { 0, 0, 0, 0, 0, 0 }
	ntot2      := { 0, 0, 0, 0, 0, 0 }
	ntot3      := { 0, 0, 0, 0, 0, 0 }
	ntot4      := { 0, 0, 0, 0, 0, 0 }
	ntot5      := { 0, 0, 0, 0, 0, 0 }
	ntot6      := { 0, 0, 0, 0, 0, 0 }

	OldVend	  := _cTrb->VENDEDOR
	OldCli	  := _cTrb->CLIENTE
	OldPed	  := _cTrb->PEDIDO

	wPrimVez   := .T.

	// SE€ÇO IMPRESSAO
	WHILE ! _cTrb->( EOF() )
		ltotal := .t.

		INCREGUA()

		// IMPRIME CABE€ALHO
		IF li >= 56
			li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 2
		ENDIF

		IF wPrimVez
			@ li, 000 PSAY REPL("-",limite)
			li := li + 1
			@ li, 000 PSAY "VENDEDOR: " + _cTrb->VENDEDOR
			li := li + 2
			@ li, 000 PSAY "CLIENTE: " + _cTrb->CLIENTE + " CIDADE/ESTADO: " + _cTrb->CIDADE
			li := li + 2
			wPrimVez := .F.
		ENDIF

		//Imprime Total do Pedido
		IF ( OldPed #_cTrb->PEDIDO ) .OR. ( OldCli # _cTrb->CLIENTE ) .OR. ( OldVend # _cTrb->VENDEDOR )

			wLinDeImp := "Total do pedido    " + SPACE(44)
			wLinDeImp := wLinDeImp + TRANS(npf_pedvl/totPedido[2],"@E 999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totPedido[2],"@E 999,999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totPedido[3],"@E 999,999.99") + SPACE( 01 )
			wLinDeImp := wLinDeImp + TRANS(totPedido[4],"@E 999,999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totPedido[5],"@E 999,999.99") + SPACE( 87 )
			wLinDeImp := wLinDeImp + TRANS((npf_pedvl * nPrazo) / npf_pedvl ,"@E 9999")

			@ li, 000 PSAY wLinDeImp

			@ li, 207 Psay Transform(Round(npf_pedq / totPedido[2] + 200,2),"@E 999,999.99") 
			//@ li, 202 Psay Transform(((npf_pedvl * nPrazo) / npf_pedvl ),"@E 9999")  
			//@ li, 202 Psay _Trb->prcuni
			npf_pedq := 0
			npf_pedvl:= 0
			li := li + 2

			totPedido[1] := totPedido[2] := totPedido[3] := totPedido[4] := totPedido[5] := 0
			OldPed		 := _cTrb->PEDIDO
		ENDIF

		//Imprime Total do Cliente	
		IF ( OldCli #_cTrb->CLIENTE ) .OR. ( OldVend # _cTrb->VENDEDOR )

			wLinDeImp := "Total do Cliente   "  + SPACE(44)
			wLinDeImp := wLinDeImp + TRANS(npf_clivl/totCliente[2],"@E 999.99")+ SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totCliente[2],"@E 999,999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totCliente[3],"@E 999,999.99") + SPACE( 01 )
			wLinDeImp := wLinDeImp + TRANS(totCliente[4],"@E 999,999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totCliente[5],"@E 999,999.99") + SPACE( 88 )
			wLinDeImp := wLinDeImp + TRANS((npf_clivl*nPrazo) / npf_clivl ,"@E 999") 	
			@ li, 000 PSAY wLinDeImp
			@ li, 207 Psay Transform(Round(npf_cliq / totCliente[2] + 200,2),"@E 999,999.99")
			npf_cliq  := 0
			npf_clivl := 0  
			//totGerCli := 0

			li := li + 1
			totCliente[1]:= totCliente[2]:= totCliente[3]:= totCliente[4]:= totCliente[5]:= 0
			//cesar		totReprese[1]:= totReprese[2]:= totReprese[3]:= totReprese[4]:= 0
		ENDIF

		//Imprime Total do Vendedor	
		IF ( OldVend #_cTrb->VENDEDOR )
			wLinDeImp := "TOTAL DO VENDEDOR  "  + SPACE(44)
			wLinDeImp := wLinDeImp + TRANS(npf_repvl/totReprese[2],"@E 999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totReprese[2],"@E 999,999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totReprese[3],"@E 999,999.99") + SPACE( 01 )
			wLinDeImp := wLinDeImp + TRANS(totReprese[4],"@E 999,999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totReprese[5],"@E 999,999.99") + SPACE( 88 ) 
			wLinDeImp := wLinDeImp + TRANS(totGerRep / npf_repvl ,"@E 999")
			//	wLinDeImp := wLinDeImp + TRANS((npf_repvl * nPrazo) / npf_repvl ,"@E 999") 
			li := li + 1
			@ li, 000 PSAY REPL("-",limite)
			li := li + 1
			@ li, 000 PSAY wLinDeImp
			@ li, 207 Psay Transform(Round(npf_vdq / totReprese[2] + 200,2),"@E 999,999.99")
			npf_vdq   := 0	
			npf_repvl := 0
			totGerRep := 0                    

			li := li + 1
			@ li, 000 PSAY REPL("-",limite)
			li := li + 1

			totReprese[1]:= totReprese[2]:= totReprese[3]:= totReprese[4]:= totReprese[5]:= 0
		ENDIF

		IF ( OldVend #_cTrb->VENDEDOR )
			@ li, 000 PSAY "VENDEDOR: " + _cTrb->VENDEDOR
			li := li + 2
			@ li, 000 PSAY "CLIENTE: " + _cTrb->CLIENTE + " CIDADE/ESTADO: " + _cTrb->CIDADE
			li := li + 2
			OldVend := _cTrb->VENDEDOR

		ELSEIF ( OldCli #_cTrb->CLIENTE )
			li := li + 1
			@ li, 000 PSAY "CLIENTE: " + _cTrb->CLIENTE + " CIDADE/ESTADO: " + _cTrb->CIDADE
			li := li + 2
			OldCli := _cTrb->CLIENTE
		ENDIF

		wLinDeImp := _cTrb->PEDIDO + SPACE( 2 )
		wLinDeImp := wLinDeImp + DTOS(_cTrb->EMISSAO) + SPACE( 2 )
		wLinDeImp := wLinDeImp + SUBS(_cTrb->PRODUTO,1,9) + SPACE( 2 )
		wLinDeImp := wLinDeImp + SUBS(_cTrb->DESC,1,30)	+ SPACE( 4 )
		wLinDeImp := wLinDeImp + TRANS(_cTrb->PRCUNI, "@E 999.99") + SPACE(2)
		wLinDeImp := wLinDeImp + TRANS(_cTrb->QTDPED, "@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(_cTrb->QTDJENT,"@E 999,999.99") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS(_cTrb->SALDO,  "@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(_cTrb->PBRUTO, "@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + _cTrb->OBS + SPACE( 4 )
		wLinDeImp := wLinDeImp + _cTrb->TRANSP+SPACE(6)
		wLinDeImp := wLinDeImp + TRANS(_cTrb->ENTREGA, "@D")+SPACE(7)
		wLinDeImp := wLinDeImp + _cTrb->CONDPAG

		@ li, 000 PSAY wLinDeImp

		nPrazo    := _cTrb->YMEDIA 
		totGerCli += totGerCli + (npf_clivl * nPrazo)
		totGerRep += _cTrb->QTDPED * _cTrb->PRCUNI * nPrazo
		totalGer  += _cTrb->QTDPED * _cTrb->PRCUNI * nPrazo

		npf_pedvl += _cTrb->QTDPED * _cTrb->PRCUNI
		npf_clivl += _cTrb->QTDPED * _cTrb->PRCUNI
		npf_repvl += _cTrb->QTDPED * _cTrb->PRCUNI
		npf_totvl += _cTrb->QTDPED * _cTrb->PRCUNI

		If _cTrb->YRECR == "S"
			npf_pedq += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			npf_cliq += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			npf_vdq  += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			npf_gerq += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
		Else    
			npf_pedq += _cTrb->QTDPED * _cTrb->PRCUNI
			npf_cliq += _cTrb->QTDPED * _cTrb->PRCUNI
			npf_vdq  += _cTrb->QTDPED * _cTrb->PRCUNI
			npf_gerq += _cTrb->QTDPED * _cTrb->PRCUNI
		EndIf


		li := li + 1                    


		OldPed  := _cTrb->PEDIDO
		OldCli  := _cTrb->CLIENTE
		OldVend := _cTrb->VENDEDOR

		totPedido[2]  := totPedido[2] + _cTrb->QTDPED
		totPedido[3]  := totPedido[3] + _cTrb->QTDJENT
		totPedido[4]  := totPedido[4] + _cTrb->SALDO
		totPedido[5]  := totPedido[5] + _cTrb->PBRUTO

		totCliente[2] := totCliente[2] + _cTrb->QTDPED
		totCliente[3] := totCliente[3] + _cTrb->QTDJENT
		totCliente[4] := totCliente[4] + _cTrb->SALDO
		totCliente[5] := totCliente[5] + _cTrb->PBRUTO

		totReprese[2] := totReprese[2] + _cTrb->QTDPED
		totReprese[3] := totReprese[3] + _cTrb->QTDJENT
		totReprese[4] := totReprese[4] + _cTrb->SALDO
		totReprese[5] := totReprese[5] + _cTrb->PBRUTO

		totGeral[2]   := totGeral[2]	 + _cTrb->QTDPED
		totGeral[3]   := totGeral[3]	 + _cTrb->QTDJENT
		totGeral[4]   := totGeral[4]	 + _cTrb->SALDO
		totGeral[5]   := totGeral[5]	 + _cTrb->PBRUTO

		If Left(_cTrb->OBS,1) == "1"
			ntot1[1] += _cTrb->QTDPED
			ntot1[2] += _cTrb->QTDJENT
			ntot1[3] += _cTrb->SALDO
			ntot1[4] += _cTrb->PBRUTO    
			ntot1[5] += _cTrb->QTDPED * _cTrb->PRCUNI
			ntot1[6] +=	_cTrb->PRCUNI
			If _cTrb->YRECR == "S"
				npf_fim1q += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			Else	
				npf_fim1q  += _cTrb->QTDPED * _cTrb->PRCUNI
			EndIf	
		ElseIf Left(_cTrb->OBS,1) == "2"
			ntot2[1] += _cTrb->QTDPED
			ntot2[2] += _cTrb->QTDJENT
			ntot2[3] += _cTrb->SALDO
			ntot2[4] += _cTrb->PBRUTO
			ntot2[5] += _cTrb->QTDPED * _cTrb->PRCUNI
			ntot2[6] +=	_cTrb->PRCUNI
			If _cTrb->YRECR == "S"
				npf_fim2q += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			Else	
				npf_fim2q  += _cTrb->QTDPED * _cTrb->PRCUNI
			EndIf	
		ElseIf Left(_cTrb->OBS,1) == "3"
			ntot3[1] += _cTrb->QTDPED
			ntot3[2] += _cTrb->QTDJENT
			ntot3[3] += _cTrb->SALDO
			ntot3[4] += _cTrb->PBRUTO
			ntot3[5] += _cTrb->QTDPED * _cTrb->PRCUNI
			ntot3[6] +=	_cTrb->PRCUNI
			If _cTrb->YRECR == "S"
				npf_fim3q += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			Else	
				npf_fim3q  += _cTrb->QTDPED * _cTrb->PRCUNI
			EndIf	
		ElseIf Left(_cTrb->OBS,1) == "4"
			ntot4[1] += _cTrb->QTDPED
			ntot4[2] += _cTrb->QTDJENT
			ntot4[3] += _cTrb->SALDO
			ntot4[4] += _cTrb->PBRUTO
			ntot4[5] += _cTrb->QTDPED * _cTrb->PRCUNI
			ntot4[6] +=	_cTrb->PRCUNI
			If _cTrb->YRECR == "S"
				npf_fim4q += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			Else	
				npf_fim4q  += _cTrb->QTDPED * _cTrb->PRCUNI
			EndIf	
		ElseIf Left(_cTrb->OBS,1) == "5"
			ntot5[1] += _cTrb->QTDPED
			ntot5[2] += _cTrb->QTDJENT
			ntot5[3] += _cTrb->SALDO
			ntot5[4] += _cTrb->PBRUTO
			ntot5[5] += _cTrb->QTDPED * _cTrb->PRCUNI
			ntot5[6] +=	_cTrb->PRCUNI
			If _cTrb->YRECR == "S"
				npf_fim5q += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			Else	
				npf_fim5q  += _cTrb->QTDPED * _cTrb->PRCUNI
			EndIf	
		ElseIf Left(_cTrb->OBS,1) == "6"
			ntot6[1] += _cTrb->QTDPED
			ntot6[2] += _cTrb->QTDJENT
			ntot6[3] += _cTrb->SALDO
			ntot6[4] += _cTrb->PBRUTO
			ntot6[5] += _cTrb->QTDPED * _cTrb->PRCUNI
			ntot6[6] +=	_cTrb->PRCUNI
			If _cTrb->YRECR == "S"
				npf_fim6q += _cTrb->QTDPED * Round(_cTrb->PRCUNI / 0.64516,2)
			Else	
				npf_fim6q  += _cTrb->QTDPED * _cTrb->PRCUNI
			EndIf	
		EndIf	
		DBSELECTAREA("_cTrb")
		DBSKIP()
	ENDDO

	//Imprime Total do Pedido se for final do Arquivo
	IF _cTrb->(EOF())
		wLinDeImp := "Total do pedido    " + SPACE(44)
		wLinDeImp := wLinDeImp + TRANS(npf_pedvl/totPedido[2],"@E 999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totPedido[2],"@E 999,999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totPedido[3],"@E 999,999.99") + SPACE( 01 )
		wLinDeImp := wLinDeImp + TRANS(totPedido[4],"@E 999,999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totPedido[5],"@E 999,999.99") + SPACE( 88 )
		wLinDeImp := wLinDeImp + TRANS((npf_pedvl * nPrazo) / npf_pedvl ,"@E 999") 

		@ li, 000 PSAY wLinDeImp
		@ li, 207 Psay Transform(Round(npf_pedq / totPedido[2] + 200,2),"@E 999,999.99")
		npf_pedq := 0
		npf_pedvl:= 0
		li := li + 2

		totPedido[1] := totPedido[2] := totPedido[3] := totPedido[4] := totPedido[5] := 0
		OldPed		 := _cTrb->PEDIDO
	ENDIF

	//Apos processar arquivo de trabalho
	If ltotal
		wLinDeImp := "Total do Cliente   "  + SPACE(44)
		wLinDeImp := wLinDeImp + TRANS(npf_clivl/totCliente[2],"@E 999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totCliente[2],"@E 999,999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totCliente[3],"@E 999,999.99") + SPACE( 01 )
		wLinDeImp := wLinDeImp + TRANS(totCliente[4],"@E 999,999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totCliente[5],"@E 999,999.99") + SPACE( 87 )
		wLinDeImp := wLinDeImp + TRANS((npf_clivl * nPrazo) / npf_clivl ,"@E 9999") 

		li := li + 1
		@ li, 000 PSAY wLinDeImp
		@ li, 207 Psay Transform(Round(npf_cliq / totCliente[2] + 200,2),"@E 999,999.99")

		npf_cliq  := 0
		npf_clivl := 0


		li := li + 1

		wLinDeImp := "TOTAL DO VENDEDOR  "  + SPACE(44)
		wLinDeImp := wLinDeImp + TRANS(npf_repvl/totReprese[2],"@E 999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totReprese[2],"@E 999,999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totReprese[3],"@E 999,999.99") + SPACE( 01 )
		wLinDeImp := wLinDeImp + TRANS(totReprese[4],"@E 999,999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totReprese[5],"@E 999,999.99") + SPACE( 88 )
		wLinDeImp := wLinDeImp + TRANS(totGerRep / npf_repvl ,"@E 999")	

		li := li + 1
		@ li, 000 PSAY REPL("-",limite)
		li := li + 1
		@ li, 000 PSAY wLinDeImp
		@ li, 207 Psay Transform(Round(npf_vdq / totReprese[2] + 200,2),"@E 999,999.99")
		npf_vdq   := 0
		npf_repvl := 0


		li := li + 1
		@ li, 000 PSAY REPL("-",limite)
		li := li + 1

		wLinDeImp := "TOTAL GERAL        " + SPACE(44)
		wLinDeImp := wLinDeImp + TRANS(npf_totvl/totGeral[2],"@E 999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totGeral[2],"@E 999,999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totGeral[3],"@E 999,999.99") + SPACE( 01 )
		wLinDeImp := wLinDeImp + TRANS(totGeral[4],"@E 999,999.99") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(totGeral[5],"@E 999,999.99") + SPACE( 88 )
		wLinDeImp := wLinDeImp + TRANS(totalGer / npf_totvl ,"@E 999") 		                           


		@ li, 000 PSAY wLinDeImp
		@ li, 207 Psay Transform(Round(npf_gerq / totGeral[2] + 200,2),"@E 999,999.99")
		npf_gerq := 0
		npf_totvl:= 0
		totalGer := 0

		li := li + 1           

		If li >= 50
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Else
			@ Prow()+1,0 psay ""	
		EndIf                                         

		If ntot1[1]+ntot1[2]+ntot1[3]+ntot1[4] > 0
			@ prow()+1,01 Psay "Total em Romaneio"
			@ Prow(),63       Psay Transform(ntot1[5]/ntot1[1],"@E 999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot1[1],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot1[2],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(ntot1[3],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot1[4],"@E 999,999.99")
			@ Prow(), 207 Psay Transform(Round(npf_fim1q / ntot1[1] + 200,2),"@E 999,999.99")
			npf_fim1q := 0
		EndIf	
		If ntot2[1]+ntot2[2]+ntot2[3]+ntot2[4] > 0
			@ prow()+1,01 Psay "Total sem Estoque"
			@ Prow(),63       Psay Transform(ntot2[5]/ntot2[1],"@E 999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot2[1],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot2[2],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(ntot2[3],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot2[4],"@E 999,999.99")
			@ Prow(), 207 Psay Transform(Round(npf_fim2q / ntot2[1] + 200,2),"@E 999,999.99")
			npf_fim2q := 0
		EndIf	
		If ntot3[1]+ntot3[2]+ntot3[3]+ntot3[4] > 0
			@ prow()+1,01 Psay "Total com credito esgotado"
			@ Prow(),63       Psay Transform(ntot3[5]/ntot3[1],"@E 999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot3[1],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot3[2],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(ntot3[3],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot3[4],"@E 999,999.99")
			@ Prow(), 207 Psay Transform(Round(npf_fim3q / ntot3[1] + 200,2),"@E 999,999.99")
			npf_fim3q := 0
		EndIf	
		If ntot4[1]+ntot4[2]+ntot4[3]+ntot4[4] > 0
			@ prow()+1,01 Psay "Total em Atraso"
			@ Prow(),63       Psay Transform(ntot4[5]/ntot4[1],"@E 999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot4[1],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot4[2],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(ntot4[3],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot4[4],"@E 999,999.99")
			@ Prow(), 207 Psay Transform(Round(npf_fim4q / ntot4[1] + 200,2),"@E 999,999.99")
			npf_fim4q := 0
		EndIf	
		If ntot5[1]+ntot5[2]+ntot5[3]+ntot5[4] > 0
			@ prow()+1,01 Psay "Total normal"
			@ Prow(),63       Psay Transform(ntot5[5]/ntot5[1],"@E 999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot5[1],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot5[2],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(ntot5[3],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot5[4],"@E 999,999.99")
			@ Prow(), 207 Psay Transform(Round(npf_fim5q / ntot5[1] + 200,2),"@E 999,999.99")
			npf_fim5q := 0
		EndIf	
		If ntot6[1]+ntot6[2]+ntot6[3]+ntot6[4] > 0
			@ prow()+1,01 Psay "Total liberado para romaneio"
			@ Prow(),63       Psay Transform(ntot6[5]/ntot6[1],"@E 999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot6[1],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot6[2],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(ntot6[3],"@E 999,999.99")
			@ Prow(),Pcol()+2 Psay Transform(ntot6[4],"@E 999,999.99")
			@ Prow(), 207 Psay Transform(Round(npf_fim6q / ntot6[1] + 200,2),"@E 999,999.99")
			npf_fim6q := 0
		EndIf	


		//RODAPE
		Roda(cbcont,cbtxt,tamanho)
	EndIf

RETURN( NIL )

