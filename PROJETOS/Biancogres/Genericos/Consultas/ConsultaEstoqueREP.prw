#Include "RwMake.ch"
#Include "topconn.ch"

/*/{Protheus.doc} ConsRep
@description CONSULTA A POSICAO DO PRODUTO NO ESTOQUE PARA OS REPRESENTANTES
@author BRUNO MADALENO
@since 20/10/05 
@version 1.0
@version XX revisada em 21/12/2018 por Luana Marin Ribeiro fazendo alteracoes para projeto consolidação
@type function
/*/

User Function ConsRep()

	Private cProduto	:= Space(15)
	Private cFORMATO	:= Space(15)
	Private cLINHA		:= Space(15)
	Private cCLASSE		:= Space(15) 
	Private cAlmox		:= '02/04'
	Private cMarcaPro	:= Space(4)
	Private aCampos0
	Private cSql
	Private Enter		:= CHR(13) + CHR(10)
	Private cArq		:= ""
	Private cInd		:= 0
	Private cReg		:= 0
	Private AALOTE		:= Space(10)
	Private lPassou		:= .T.  

	//PROJETO RESERVA DE OP - FERNANDO/FACILE
	Private oWBrowse1
	Private aWBrowse1

	
	If !Empty(cRepAtu) .And. U_GETBIAPAR("REP_BLQF6",.F.)
		MsgInfo("Consulta temporariamente indisponível","CONSREP")
		Return
	EndIf

	cAlmox := U_MontaSQLIN(cAlmox,'/',2)    

	//Fernando/Facile em 03/09/2015 - OS 2318-15 - Pedidos de Amostra 
	If Type("M->C5_YSUBTP") <> "U" .And.  !Empty(M->C5_YSUBTP) .And. AllTrim(M->C5_YSUBTP) $ "A#M"
		cAlmox := "'05'"
	EndIf

	//Controla a abertura do programa
	cContador ++
	If cContador > 1
		Return
	EndIf

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	_aCampos :=	{	{"CAIXA"			,"N",03,0},;
	{"CONV"				,"N",05,2},;
	{"PRODUTO"			,"C",08,0},;
	{"DESCRICAO"		,"C",20,0},;
	{"LOTE"				,"C",07,0},;
	{"EMPRESA"			,"C",02,0},;
	{"LOTE_ORI"			,"C",10,0},; //UTILIZADO COM TAMANHO 10 PARA PREENCHER OS CAMPOS NA RESERVA E PEDIDO
	{"RUA"				,"C",08,0},;
	{"QUANT_PLT"		,"C",10,0},;
	{"PEDCART"			,"N",10,2},;
	{"DISPONIVEL"		,"N",10,2},;
	{"B1_COD"			,"C",15,0},; //UTILIZADO COM TAMANHO 15 PARA PREENCHER OS CAMPOS NA RESERVA E PEDIDO
	{"PESOBR"			,"C",07,4},;				
	{"PRIORIDADE"		,"C",03,0},;				
	{"ALMOX"			,"C",02,0}} 
	If chkfile("_trabalho")
		dbSelectArea("_trabalho")
		dbCloseArea()
	EndIf
	_trabalho := CriaTrab(_aCampos)
	dbUseArea(.T.,,_trabalho,"_trabalho",.t.)
	dbCreateInd(_trabalho,"PRODUTO+EMPRESA+LOTE",{||PRODUTO+EMPRESA+LOTE} )

	//Selecionando todos os produtos e suas quantidades em estoque
	SQL_FILTROS()
	If chkfile("c_CONS")
		dbSelectArea("c_CONS")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "c_CONS" NEW
	c_CONS->(DbGoTop())
	While !c_CONS->(EOF())

		// FUNCAO PARA TRAZER A QUANTIDADE DE PALETS
		QUANT_PALET := U_PALETES(  c_CONS->PRODUTO  ,  c_CONS->DISPONIVEL, c_CONS->LOTE_ORI)

		RecLock("_trabalho",.t.)
		_trabalho->CAIXA		:= c_CONS->CAIXA
		_trabalho->CONV			:= TRAN(c_CONS->CONV,"@E 99.99")
		_trabalho->PRODUTO		:= c_CONS->PRODUTO
		_trabalho->DESCRICAO	:= c_CONS->DESCRICAO
		_trabalho->LOTE			:= c_CONS->LOTE
		_trabalho->EMPRESA		:= c_CONS->EMPRESA
		_trabalho->LOTE_ORI		:= c_CONS->LOTE_ORI
		_trabalho->RUA			:= c_CONS->RUA
		_trabalho->QUANT_PLT	:= Alltrim(QUANT_PALET)
		_trabalho->PEDCART		:= TRAN(c_CONS->PEDCART,"@E 999,999.99")
		_trabalho->DISPONIVEL	:= TRAN(c_CONS->DISPONIVEL,"@E 999,999.99")
		_trabalho->B1_COD		:= c_CONS->B1_COD
		_trabalho->PESOBR		:= TRAN(c_CONS->PESOBR,"@E 99.9999")
		_trabalho->PRIORIDADE	:= c_CONS->PRIORIDADE
		_trabalho->ALMOX		:= c_CONS->ALMOX

		MsUnlock()
		c_CONS->(DbSkip())
	EndDo

	aCampos0 := {}
	AADD(aCampos0,{"CAIXA"			, "CX" 			,03})
	AADD(aCampos0,{"CONV"			, "CONV"		,07})
	AADD(aCampos0,{"PRODUTO"		, "PROD." 		,05})
	AADD(aCampos0,{"DESCRICAO"	    , "DESCRIÇÃO" 	,80})
	AADD(aCampos0,{"LOTE"			, "LOTE"		,10})
	AADD(aCampos0,{"EMPRESA"		, "EMPRESA"		,02})
	AADD(aCampos0,{"ALMOX"			, "ALMOX"		,02})
	AADD(aCampos0,{"DISPONIVEL"	    , "DISPON." 	,06})
	AADD(aCampos0,{"PEDCART"		, "PEDCART" 	,04})
	AADD(aCampos0,{"QUANT_PLT"    	, "QUANT. PLT"	,10})
	AADD(aCampos0,{"PESOBR"      	, "PESO B./M2"	,07})
	AADD(aCampos0,{"RUA"			, "RUA" 		,02})

	Markbrow()

	If cArq <> ""
		dbSelectArea(cArq)
		dbSetOrder(cInd)
		dbGoTo(cReg)
	EndIf

	//Controla a abertura do programa
	cContador := 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	MARKBROW    ³ Autor ³BRUNO MADALENO        ³ Data ³ 21/10/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MONTA O OBROWSE PARA LISTAS OS TITULOS BLOQUEADOS               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Markbrow()

	local oModel	:= FwModelActive()
	@ 10,10	 To 535,950 Dialog oDlg15 Title "Consulta Estoque"
	@ 05,06	 To 260,462
	@ 10,10	 SAY "CÓDIGO PRODUTO:"
	@ 18,10  Get cProduto PICTURE "@!" Size 50,10 Object oGet11 F3 "SB1"

	@ 10,62	 SAY "LOTE:"
	@ 18,62  Get AALOTE PICTURE "@!" Size 20,10 Object oGet11

	@ 16,80	 SAY "   OU   "

	@ 10,95 SAY "FORMATO: "
	@ 18,95 Get cFORMATO PICTURE "@!" Size 25,10 Object oGet11 F3 "ZZ6"

	@ 10,125 SAY "LINHA: "
	@ 18,125 Get cLINHA PICTURE "@!" Size 50,10 Object oGet11 F3 "ZZ7"

	@ 10,180 SAY "CLASSE: "
	@ 18,180 Get cCLASSE PICTURE "@!" Size 25,10 Object oGet11 F3 "ZZ8"

	@ 10,210 SAY "MARCA: "
	@ 18,210 Get cMarcaPro PICTURE "@!" Size 25,10 Object oGet11 F3 "Z37"

	@ 10,245 SAY "ALMOX: "
	@ 18,245 Get cAlmox PICTURE "@!" Size 50,10 Object oGet11

	@ 16,350 Button "Filtrar" Size 30,15 Action SQL_FILTROS()

	IF UPPER(ALLTRIM(FUNNAME())) == "MATA430"
		If Type("ALTERA") <> "U" .And. Type("ALTERA") <> "U"
			If ALTERA = .T. .OR. INCLUI = .T.
				@ 16,370	Button "Reserva" Size 30,15 Action Prenche_Re()
				IF Gdfieldget("C0_PRODUTO",n) <> ""
					cProduto := Gdfieldget("C0_PRODUTO",n)
				END IF
			END IF
		EndIf
	END IF

	IF UPPER(ALLTRIM(FUNNAME())) == "MATA410"
		If Type("ALTERA") <> "U" .And. Type("ALTERA") <> "U"
			IF ALTERA = .T. .OR. INCLUI = .T.
				@ 16,370	Button "Pedido" Size 30,15 Action Prenche_Re()
				IF ALLTRIM(ACOLS[N,2]) <> ""
					cProduto := ACOLS[N,2]
				END IF
			END IF
		EndIf
	END IF

	IF UPPER(ALLTRIM(FUNNAME())) == "MATA440"
		If Type("ALTERA") <> "U" .And. Type("ALTERA") <> "U"
			IF ALTERA = .T. .OR. INCLUI = .T.
				@ 16,370	BUTTON "Liberação" SIZE 35,15 ACTION PRENCHE_RE()
				IF ALLTRIM(ACOLS[N,2]) <> ""
					CPRODUTO := ALLTRIM(ACOLS[N,2])
				END IF		
			END IF
		EndIf
	END IF 

	IF UPPER(ALLTRIM(FUNNAME())) == "BFATTE01"
		IF ALLTRIM(ACOLS[N,2]) <> ""
			CPRODUTO := ALLTRIM(ACOLS[N,2])
		END IF
	END IF

	IF UPPER(ALLTRIM(FUNNAME())) == "BIA229"
		oModel	:= FwModelActive()
		If Type("oModel") <> "U"
			oModelDetalhe := oModel:GetModel('DETAIL')
			CPRODUTO	:= oModelDetalhe:GetValue('Z55_PROD')	
		ElseIf (Type("n") <> "U" .And. GdFieldGet("Z69_CODPRO", n) <> nil)
			CPRODUTO	:= GdFieldGet("Z69_CODPRO", n)
		EndIf	
	ENDIF

	@ 160,333	BmpButton Type 2 Action Close(oDlg15)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta MarkBrowse...                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//AJUSTE BROWSE DE SALDOS EM OP - PROJETO COMERCIAL/RESERVA DE OP - FERNANDO/FACILE - 28/04/2014
	oBrowse := IW_Browse(032,010,190,457,"_trabalho",,,aCampos0)  
	@ 192,010 SAY "PREVISÃO DE PRODUÇÃO:"
	fWBListaOP()

	ACTIVATE DIALOG oDlg15 ON INIT Eval({|| MsAguarde(), _trabalho->(DbGoTop()), oBrowse:oBrowse:Refresh(), }) Centered

Return

//BROWSE DE SALDOS EM OP - PROJETO COMERCIAL/RESERVA DE OP - FERNANDO/FACILE - 28/04/2014
Static Function fWBListaOP()

	aWBrowse1 := {}
	Aadd(aWBrowse1,{"","","","","",0})

	@ 200, 010 LISTBOX oWBrowse1 Fields HEADER "Produto","OP","Item","Seq","Dt.Dispo","Saldo" SIZE 447, 060 OF oDlg15 PIXEL ColSizes 50,50

	oWBrowse1:SetArray(aWBrowse1)
	oWBrowse1:bLine := {|| {;
	aWBrowse1[oWBrowse1:nAt,1],;
	aWBrowse1[oWBrowse1:nAt,2],;
	aWBrowse1[oWBrowse1:nAt,3],;
	aWBrowse1[oWBrowse1:nAt,4],;
	aWBrowse1[oWBrowse1:nAt,5],;
	aWBrowse1[oWBrowse1:nAt,6];
	}}

Return  

//BROWSE DE SALDOS EM OP - PROJETO COMERCIAL/RESERVA DE OP - FERNANDO/FACILE - 28/04/2014
Static Function PesqOPSld(cProduto,cFORMATO,cLINHA,cCLASSE,cEmpOut)

	Local _aListOP
	Local I
	Local _aAux    

	aWBrowse1 := {}

	If Substr(cProduto,1,2) <> "C1"
		_aListOP := U_FRRT04PO("", "",cProduto, 0, "S", , , AllTrim(cFORMATO), AllTrim(cLINHA), AllTrim(cCLASSE),cEmpOut)
	Else
		_aListOP := {}
	EndIf

	If Len(_aListOP) > 0

		FOR I := 1 To Len(_aListOP)

			_aAux := {}
			AAdd(_aAux,_aListOP[I][6])
			AAdd(_aAux,_aListOP[I][1])
			AAdd(_aAux,_aListOP[I][2])
			AAdd(_aAux,_aListOP[I][3])
			AAdd(_aAux,DTOC(_aListOP[I][4]))
			AAdd(_aAux,_aListOP[I][5])

			AAdd(aWBrowse1,_aAux)

		NEXT I     

		//Ticket 27254: Corrigir ordenação das OP's no F6
		aWBrowse1 := aSort(aWBrowse1,,,{|x,y| Ctod(x[5]) < Ctod(y[5])})
	Else

		Aadd(aWBrowse1,{"","","","","",0})

	EndIf   

	oWBrowse1:SetArray(aWBrowse1) 
	oWBrowse1:bLine := {|| {;
	aWBrowse1[oWBrowse1:nAt,1],;
	aWBrowse1[oWBrowse1:nAt,2],;
	aWBrowse1[oWBrowse1:nAt,3],;
	aWBrowse1[oWBrowse1:nAt,4],;
	aWBrowse1[oWBrowse1:nAt,5],;
	aWBrowse1[oWBrowse1:nAt,6];
	}}
	oWBrowse1:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ Prenche_Re   ³ Autor ³BRUNO MADALENO        ³ Data ³ 21/10/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ preenche o campo de produto na reserva        				  				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Prenche_Re()

	If cEmpAnt <> _trabalho->EMPRESA
		MsgBox("Este produto poderá ser utilizado apenas em sua EMPRESA de origem!","STOP")
		Return
	EndIf

	//Preenche a Reserva
	IF UPPER(ALLTRIM(FUNNAME())) == "MATA430"
		Gdfieldput("C0_PRODUTO",_trabalho->B1_COD,n)	
		Gdfieldput("C0_LOTECTL",_trabalho->LOTE_ORI,n)

		//Preenche o Pedido de Venda
	ELSEIF UPPER(ALLTRIM(FUNNAME())) == "MATA410"
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+_trabalho->B1_COD,.F.)

		Gdfieldput("C6_PRODUTO"	,_trabalho->B1_COD	,n)	
		Gdfieldput("C6_UM"		,SB1->B1_UM			,n)	
		Gdfieldput("C6_SEGUM"	,SB1->B1_SEGUM		,n)	
		Gdfieldput("C6_LOCAL"	,SB1->B1_LOCPAD		,n)	
		Gdfieldput("C6_LOTECTL"	,_trabalho->LOTE_ORI,n)	

		//Preenche a Liberacao de Pedido
	ELSEIF UPPER(ALLTRIM(FUNNAME())) == "MATA440"
		IF Alltrim(Gdfieldget("C6_PRODUTO",n)) == ALLTRIM(_trabalho->B1_COD)
			Gdfieldput("C6_PRODUTO"	,_trabalho->B1_COD		,n)	
			Gdfieldput("C6_LOTECTL"	,_trabalho->LOTE_ORI	,n)	
		ELSE
			MSGALERT("O produto consultado deve ser igual, ao produto do pedido!","Consulta Estoque")
			MSGALERT("Produto PEDIDO-> "+Alltrim(Gdfieldget("C6_PRODUTO",n))+" DIFERENTE do Produto CONSULTA->"+ALLTRIM(_TRABALHO->B1_COD),"Consulta Estoque" )
			RETURN
		END IF	
	END IF

	Close(oDlg15)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³AtualizaBrowse³ Autor ³BRUNO MADALENO        ³ Data ³ 21/10/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ ATUALIZA O BOWSE CONFOR O FILTRO SELECIONADO                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function AtualizaBrowse()
	If chkfile("_trabalho")
		dbSelectArea("_trabalho")
		dbCloseArea()
	EndIf

	_aCampos :=	{	{"CAIXA"			,"N",03,0},;
	{"CONV"			,"C",05,2},;
	{"PRODUTO"		,"C",08,0},;
	{"DESCRICAO"	,"C",20,0},;
	{"LOTE"			,"C",07,0},; 
	{"EMPRESA"		,"C",02,0},; 
	{"LOTE_ORI"		,"C",10,0},; //UTILIZADO COM TAMANHO 10 PARA PREENCHER OS CAMPOS NA RESERVA E PREDIDO
	{"RUA"			,"C",08,0},;
	{"QUANT_PLT"	,"C",10,2},;
	{"PEDCART"		,"C",10,2},;
	{"DISPONIVEL"	,"C",10,2},;
	{"B1_COD"		,"C",15,0},; //UTILIZADO COM TAMANHO 15 PARA PREENCHER OS CAMPOS NA RESERVA E PREDIDO   
	{"PESOBR"		,"C",07,4},;											
	{"PRIORIDADE"	,"C",03,0},;											
	{"ALMOX"	,"C",02,0}}

	_trabalho := CriaTrab(_aCampos)
	dbUseArea(.T.,,_trabalho,"_trabalho",.t.)
	dbCreateInd(_trabalho,"PRODUTO+EMPRESA+LOTE",{||PRODUTO+EMPRESA+LOTE})

	//Selecionando todos os produtos e suas quantidades em estoque
	If chkfile("c_CONS")
		dbSelectArea("c_CONS")
		dbCloseArea()
	EndIf

	lPassei := .F.
	TCQUERY cSql ALIAS "c_CONS" NEW
	c_CONS->(DbGoTop())
	While !c_CONS->(EOF())

		// FUNCAO PARA TRAZER A QUANTIDADE DE PALETS
		QUANT_PALET := U_PALETES(  c_CONS->B1_COD  ,  c_CONS->DISPONIVEL, c_CONS->LOTE_ORI)
		lPassei := .T.

		RecLock("_trabalho",.t.)
		_trabalho->CAIXA			:= c_CONS->CAIXA
		_trabalho->CONV 			:= TRAN(c_CONS->CONV,"@E 99.99")
		_trabalho->PRODUTO			:= c_CONS->PRODUTO
		_trabalho->DESCRICAO		:= c_CONS->DESCRICAO
		_trabalho->LOTE				:= c_CONS->LOTE
		_trabalho->EMPRESA			:= c_CONS->EMPRESA
		_trabalho->ALMOX			:= c_CONS->ALMOX
		_trabalho->LOTE_ORI			:= c_CONS->LOTE_ORI
		_trabalho->RUA				:= c_CONS->RUA
		_trabalho->QUANT_PLT 		:= Alltrim(QUANT_PALET)
		_trabalho->PEDCART			:= TRANS(c_CONS->PEDCART,			"@E 999,999.99")
		_trabalho->DISPONIVEL		:= TRANS(c_CONS->DISPONIVEL,	"@E 999,999.99")
		_trabalho->B1_COD 			:= c_CONS->B1_COD
		_trabalho->PESOBR			:= TRAN(c_CONS->PESOBR,"@E 99.9999")
		_trabalho->PRIORIDADE 		:= ALLTRIM(STR(c_CONS->PRIORIDADE))

		MsUnlock()
		c_CONS->(DbSkip())
	EndDo

	_trabalho->(DbGoTop())
	oBrowse:oBrowse:Refresh()

	IF !lPassei
		MSGBOX("Não existem dados para a consulta realizada","STOP")
	ENDIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ SQL_FILTROS  ³ Autor ³BRUNO MADALENO        ³ Data ³ 21/10/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ SELECIONANDO OSPRODUTOS DE ACORDOCOM O FILTRO 				   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SQL_FILTROS()
	Local cAlmLoc       

	//Verifica se alguma variavel esta preenchido com conteudo invalido
	cProduto	:= STRTRAN(cProduto,"'", "")
	cFORMATO	:= STRTRAN(cFORMATO,"'", "")
	cLINHA		:= STRTRAN(cLINHA  ,"'", "")
	cCLASSE		:= STRTRAN(cCLASSE ,"'", "")
	AALOTE		:= STRTRAN(AALOTE  ,"'", "")

	//Verifica se o conteudo da variavel está correta
	cAlmox		:= STRTRAN(cAlmox  ,"'", "")
	cAlmLoc		:= cAlmox
	cAlmox 		:= U_MontaSQLIN(cALmox,',',2)  

	IF EMPTY(cAlmox)
		cAlmox := '02/04/05'
		cAlmox := U_MontaSQLIN(cALmox,'/',2)   
	ENDIF

	cMarcaPro		:= STRTRAN(cMarcaPro  ,"'", "")

	cSQL := ""
	cSQL += "SELECT	PRIORIDADE, B1_COD, B1_COD AS PRODUTO,	CONV, DESCRICAO, LOTE, LOTE_ORI, RUA, EMPRESA, ALMOX, QUANTIDADE, EMPENHO, PEDCART, ISNULL(QUANTIDADE - EMPENHO,0) AS DISPONIVEL, CAIXA, PESOBR "  + Enter
	cSQL += "FROM  "  + Enter
	cSQL += "	(SELECT *, PEDCART = CASE WHEN PRIORIDADE = 1 THEN (SELECT dbo.FN_SALDOPEDIDOLOC(EMPRESA,B1_COD, '" + cAlmLoc + "')) ELSE 0 END"  + Enter
	cSQL += "	 FROM "  + Enter
	cSQL += "			(SELECT ROW_NUMBER() over (PARTITION BY B1_COD, EMPRESA ORDER BY B1_COD, EMPRESA DESC) AS PRIORIDADE, EMPRESA, "  + Enter
	cSQL += "			B1_COD, B1_CONV AS CONV,  "  + Enter
	cSQL += "			B1_DESC AS DESCRICAO,  "  + Enter
	cSQL += "			SUBSTRING(B1_COD,1,8) AS PRODUTO,  "  + Enter
	cSQL += "			LOTE = CASE WHEN ZZ9_RESTRI = '*' THEN RTRIM(BF_LOTECTL)+ZZ9_RESTRI ELSE RTRIM(BF_LOTECTL) END, "  + Enter
	cSQL += "			BF_LOTECTL AS LOTE_ORI,  "  + Enter
	cSQL += "			ISNULL(BF_LOCALIZ,'---') AS RUA,  "  + Enter
	cSQL += "			BF_LOCAL AS ALMOX,  "  + Enter
	cSQL += "			ISNULL(BF_QUANT,0) AS QUANTIDADE,  "  + Enter
	cSQL += "			ISNULL(BF_EMPENHO,0) AS EMPENHO,  "  + Enter
	cSQL += "			ZZ9.ZZ9_DIVPA AS CAIXA, B1_YFORMAT, B1_YFATOR, B1_YLINHA, B1_YCLASSE, ROUND(ZZ9_PESO+(ZZ9_PESEMB/B1_CONV),4) AS PESOBR "  + Enter
	cSQL += "	FROM     " + RETSQLNAME("SB1") + "  SB1, "+RetSqlName("ZZ6")+" ZZ6,	"+RetSqlName("ZZ7")+" ZZ7, "+RetSqlName("ZZ9")+" ZZ9, "  + Enter
	If cEmpAnt $ "01_05_07_14"
		cSQL += "			(SELECT '01' EMPRESA, * FROM SBF010 WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C') AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '' 	"  + Enter
		cSQL += "			UNION																																																							"  + Enter
		cSQL += "			SELECT '05' EMPRESA, * FROM SBF050 WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C')  AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = ''		"  + Enter
		cSQL += "			UNION																																																							"  + Enter
		cSQL += "			SELECT '13' EMPRESA, * FROM SBF130 WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C')  AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '' 	"  + Enter
		cSQL += "			UNION																																																							"  + Enter
		cSQL += "			SELECT '14' EMPRESA, * FROM SBF140 WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C')  AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '' 	"  + Enter
		cSQL += "			UNION																																																							"  + Enter
		cSQL += "			SELECT '"+cEmpAnt+"' EMPRESA, * FROM "+RetSqlName("SBF")+" WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C') AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '' ) SBF	"  + Enter
	Else
		cSQL += "		 (SELECT '"+cEmpAnt+"' EMPRESA, * FROM "+RetSqlName("SBF")+" WHERE BF_FILIAL = '01' AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '') SBF " + Enter
	EndIf
	cSQL += "	WHERE	SB1.B1_FILIAL		= '"+xFilial("SB1")+"'	AND "  + Enter
	cSQL += "				ZZ9.ZZ9_FILIAL	= '"+xFilial("ZZ9")+"'	AND "  + Enter
	cSQL += "				SBF.BF_FILIAL	= '01'	AND "  + Enter
	cSQL += "				SB1.B1_COD		= SBF.BF_PRODUTO	AND "  + Enter
	cSQL += "				SB1.B1_YFORMAT  = ZZ6.ZZ6_COD		AND "  + Enter
	cSQL += "				SB1.B1_YLINHA	= ZZ7.ZZ7_COD 		AND "  + Enter
	cSQL += "				SB1.B1_YLINSEQ  = ZZ7.ZZ7_LINSEQ 	AND "  + Enter
	cSQL += "				SBF.BF_PRODUTO  = ZZ9.ZZ9_PRODUT	AND "  + Enter
	cSQL += " 			    SBF.BF_LOTECTL  = ZZ9.ZZ9_LOTE		AND "  + Enter
	If !Empty(AllTrim(cMarcaPro))
		cSQL += " 			    ZZ7.ZZ7_EMP ='"+AllTrim(cMarcaPro)+"' 	AND "  + Enter
	EndIf
	cSQL += "				SBF.BF_LOCALIZ <> 'LM'				AND "  + Enter//Fernando em 24/04/15 - nao mostrar rua LM para representante

	cSQL += "				SUBSTRING(SBF.BF_LOCALIZ,1,8)	<> 'P. DEVOL' 	AND "  + Enter 
	cSQL += "				SUBSTRING(SBF.BF_LOCALIZ,1,3)	<> 'CLA' 	    AND "  + Enter
	cSQL += "				SUBSTRING(SBF.BF_LOCALIZ,1,3)	<> 'PAP' 	    AND "  + Enter
	cSQL += "				SUBSTRING(SBF.BF_LOCALIZ,1,4)	<> 'PMEC' 	    AND "  + Enter

	cSQL += "				SB1.D_E_L_E_T_	= '' 							AND "  + Enter
	cSQL += "				SBF.D_E_L_E_T_	= '' 							AND "  + Enter
	cSQL += "				ZZ6.D_E_L_E_T_  = ''   							AND "  + Enter
	cSQL += "				ZZ7.D_E_L_E_T_	= '' 							AND "  + Enter
	cSQL += "				ZZ9.D_E_L_E_T_	= '') AS TMP ) PROD		"  + Enter
	cSQL += "WHERE																				"  + Enter
	If lPassou
		cSQL += "       	B1_COD			= '555555555555555'	AND "  + Enter
	Else
		If AllTrim(cProduto) <> ""
			cSQL += "       	PROD.B1_COD   Like '" + AllTrim(cProduto) + "%' AND	" + Enter
		ELSE
			IF AllTrim(cFORMATO) <> ""
				cSQL += "       PROD.B1_YFORMAT   = '" + AllTrim(cFORMATO) + "' AND	"  + Enter
			END IF
			IF AllTrim(cLINHA) <> ""
				cSQL += "       PROD.B1_YLINHA   = '" + AllTrim(cLINHA) + "' AND	"  + Enter
			END IF
			IF AllTrim(cCLASSE) <> ""
				cSQL += "       PROD.B1_YCLASSE   = '" + AllTrim(cCLASSE) + "' AND "  + Enter
			END IF
		END IF
		IF ALLTRIM(AALOTE) <> ""
			cSQL += "       LOTE ='"+ALLTRIM(AALOTE)+"' 	AND "  + Enter
		END IF
	EndIf	
	cSQL += "		(PROD.QUANTIDADE > 0 OR PEDCART > 0) "  + Enter
	cSQL += "ORDER BY PROD.B1_COD, PROD.CAIXA  "  + Enter

	//Controla filtro na query
	If lPassou
		lPassou := .F.
	Else
		//Atualiza a tela da Consulta
		AtualizaBrowse()
	EndIf      

	cEmpOut := cEmpAnt

	//OS 3932-16 - Fernando/Facile - ajustado para nao usar o alias _AAUX que nao existe em algumas situacoes
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("01")+cProduto))
		If cEmpAnt == '01' .And. AllTrim(SB1->B1_YPCGMR3) == '8'
			cEmpOut := '05'
		EndIf
	EndIf


	//PROJETO RESERVA DE OP PREENCHER GRIP DE SALDOS DE OP
	If !Empty(cProduto) .Or. !Empty(cFORMATO) .Or. !Empty(cLINHA) .Or. !Empty(cCLASSE)
		PesqOPSld(cProduto,cFORMATO,cLINHA,cCLASSE,cEmpOut)
	EndIf

Return
