#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 17/09/01

User Function BIA745()        // incluido pelo assistente de conversao do AP5 IDE em 17/09/01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	local i 
	SetPrvt("NOPCE,NOPCG,ACAMPOS,I,COPCAO,AHEADER")
	SetPrvt("NUSADO,ACOLS,_PROXITEM,_NUMANT,_CLIENTE,_LOJA,_DTEMB,_TRANSP")
	SetPrvt("VTOTREC,VSALDO")
	SetPrvt("VTOTDESP,WTOTPLQ,WTOTPBR,WTOTFOB,WTOTNF,WTOTFRE")
	SetPrvt("WTOTINV,WTOTPAL,WTOTQTD,M->C5_FILIAL,M->C5_CLIENTE")
	SetPrvt("M->C5_LOJACLI,M->C5_NUM,M->C5_EMISSAO,M->C5_TRANSP")
	SetPrvt("CTITULO,CALIASENCHOICE,CALIASGETD,CLINOK")
	SetPrvt("CTUDOK,CFIELDOK,ACPOENCHOICE,LRETMOD3,WITEM,_ITEM")
	SetPrvt("_VLRUNIT,_VLRTOT,LSC6,LSZD,N")

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ BIA745   ³ Autor ³ Adam Del Fiume Silva  ³ Data ³ 26/11/02 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Pedido de Venda - Alterar                                  ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	MSGALERT("Esta rotina se destina a realizar alteracao no codigo do produto, para informacao de nova tonalidade. Demais alteracoes deverao ser realizadas atraves da rotina padrao.")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcao de acesso para o Modelo 3                                          ³
	//³ 3, 4 Permitem alterar getdados e incluir linhas                          ³
	//³ 6 So permite alterar getdados e nao incluir linhas                       ³
	//³ Qualquer outro numero so visualiza                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcE := 4
	nOpcG := 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabecalho do Modelo 3                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOpcao := "ALTERAR"
	RegToMemory("SC5",(cOpcao=="ALTERAR"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader; estrutura do arquivo                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	nUsado  := 0

	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("ZD_ITEM")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_PRODUTO")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_UM")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_QTDVEN")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_PRCVEN")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_VALOR")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_QTDLIB")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_TES")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_CF")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1

	dbSeek("ZD_LOCAL")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1


	dbSeek("ZD_NUM")
	aadd(aHeader,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	nUsado := nUsado + 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acessa SC6 - Itens do Pedido                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := {array(nUsado+1)}
	aCols[1,nUsado+1] := .F.
	//For i := 1 to nUsado
	//    aCols[1,i] := CriaVar(aHeader[i,2])
	//next

	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6")+SC5->C5_NUM)

	While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") ;
	.and. SC6->C6_NUM    == SC5->C5_NUM   

		DbSelectArea("SZD")
		RecLock("SZD",.T.)
		SZD->ZD_FILIAL  := xFilial("SZD")
		SZD->ZD_ITEM    := SC6->C6_ITEM
		SZD->ZD_PRODUTO := SC6->C6_PRODUTO
		SZD->ZD_UM      := SC6->C6_UM
		SZD->ZD_QTDVEN  := SC6->C6_QTDVEN
		SZD->ZD_PRCVEN  := SC6->C6_PRCVEN
		SZD->ZD_VALOR   := SC6->C6_VALOR
		SZD->ZD_QTDLIB  := SC6->C6_QTDLIB
		SZD->ZD_TES     := SC6->C6_TES
		SZD->ZD_CF      := SC6->C6_CF
		SZD->ZD_LOCAL   := SC6->C6_LOCAL
		SZD->ZD_NUM     := SC6->C6_NUM
		MSUNLOCK()

		dbSelectArea("SC6")
		dbSkip()
	End

	dbSelectArea("SZD")
	dbSetOrder(1)
	dbSeek(xFilial("SZD")+SC5->C5_NUM)

	While !eof() .and. SZD->ZD_FILIAL == xFilial("SZD") ;
	.and. SZD->ZD_NUM    == SC5->C5_NUM   

		aadd(aCols,{SZD->ZD_ITEM,SZD->ZD_PRODUTO,SZD->ZD_UM,SZD->ZD_QTDVEN, ;
		SZD->ZD_PRCVEN,SZD->ZD_VALOR,SZD->ZD_QTDLIB,SZD->ZD_TES, ;
		SZD->ZD_CF,SZD->ZD_LOCAL,SZD->ZD_NUM,.F.})
		dbSkip()
	End

	_ProxItem     := val(aCols[len(aCols),1]) + 1
	_Numant       := SC5->C5_NUM
	_Cliente      := SC5->C5_CLIENTE 
	_Loja         := SC5->C5_LOJACLI   /////ALTERADO ATE ESTE PONTO 12:21
	_Dtemb        := SC5->C5_EMISSAO 
	_Transp       := SC5->C5_TRANSP  

	M->C5_FILIAL   := SC5->C5_FILIAL
	M->C5_CLIENTE  := SC5->C5_CLIENTE
	M->C5_LOJACLI  := SC5->C5_LOJACLI
	M->C5_NUM      := SC5->C5_NUM   
	M->C5_EMISSAO  := SC5->C5_EMISSAO
	M->C5_TRANSP   := SC5->C5_TRANSP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do Modelo 3                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo        := "PV"
	cAliasEnchoice := "SC5"
	cAliasGetD     := "SZD"
	cLinOk         := "AllwaysTrue()"
	cTudOk         := "AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()" 
	aCpoEnchoice   := {"C5_NUM"}
	lRetMod3       := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza arquivos                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lRetMod3

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Determina posicao dos campos no aCols                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_Item    := aScan(aHeader,{|x| x[2]=="ZD_ITEM   "})
		_Produto := aScan(aHeader,{|x| x[2]=="ZD_PRODUTO"})
		_Um      := aScan(aHeader,{|x| x[2]=="ZD_UM     "})
		_Qtdven  := aScan(aHeader,{|x| x[2]=="ZD_QTDVEN "})
		_Prcven  := aScan(aHeader,{|x| x[2]=="ZD_PRCVEN "})
		_Valor   := aScan(aHeader,{|x| x[2]=="ZD_VALOR  "})
		_Qtdlib  := aScan(aHeader,{|x| x[2]=="ZD_QTDLIB "})
		_Tes     := aScan(aHeader,{|x| x[2]=="ZD_TES    "})
		_Cf      := aScan(aHeader,{|x| x[2]=="ZD_CF     "})
		_Local   := aScan(aHeader,{|x| x[2]=="ZD_LOCAL  "})
		_Num     := aScan(aHeader,{|x| x[2]=="ZD_NUM    "})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava SZF - Itens NET                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lSZD  := .F.
		wItem := 0

		For i := 1 to len(aCols)
			wItem := wItem + 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o item foi deletado                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  aCols[i,nUsado+1]
				DbSelectArea("SZD")
				DbSetOrder(1)
				If  DbSeek(xFilial("SZD")+M->C5_NUM   +aCols[i,_Item])
					While ! RecLock("SZD",.F.) ; End
					Delete
					msUnLock()
				End
				DbSelectArea("SC6")
				DbSetOrder(1)
				If  DbSeek(xFilial("SC6")+M->C5_NUM   +aCols[i,_Item])
					While ! RecLock("SC6",.F.) ; End
					Delete
					msUnLock()
				End
			Else     
				DbSelectArea("SZD")
				DbSetOrder(1)
				If  DbSeek(xFilial("SZD")+M->C5_NUM   +aCols[i,_Item])
					While ! RecLock("SZD",.F.) ; End
					SZD->ZD_ITEM    := strzero(wItem,2)
					SZD->ZD_PRODUTO := aCols[i,_Produto]
					SZD->ZD_UM      := aCols[i,_Um]
					SZD->ZD_QTDVEN  := aCols[i,_Qtdven]
					SZD->ZD_PRCVEN  := aCols[i,_Prcven]
					SZD->ZD_VALOR   := aCols[i,_Valor]
					SZD->ZD_QTDLIB  := aCols[i,_Qtdlib]
					SZD->ZD_TES     := aCols[i,_Tes]
					SZD->ZD_CF      := aCols[i,_Cf]
					SZD->ZD_LOCAL   := aCols[i,_Local]
					SZD->ZD_NUM     := aCols[i,_Num]
					MsUnLock()
				ELSE
					RecLock("SZD",.T.)
					_ProxItem := _ProxItem + 1

					SZD->ZD_FILIAL  := xFilial("SZD")
					SZD->ZD_ITEM    := strzero(wItem,2)
					SZD->ZD_PRODUTO := aCols[i,_Produto]
					SZD->ZD_UM      := aCols[i,_Um]
					SZD->ZD_QTDVEN  := aCols[i,_Qtdven]
					SZD->ZD_PRCVEN  := aCols[i,_Prcven]
					SZD->ZD_VALOR   := aCols[i,_Valor]
					SZD->ZD_QTDLIB  := aCols[i,_Qtdlib]
					SZD->ZD_TES     := aCols[i,_Tes]
					SZD->ZD_CF      := aCols[i,_Cf]
					SZD->ZD_LOCAL   := aCols[i,_Local]
					SZD->ZD_NUM     := aCols[i,_Num]
					MsUnLock()
				ENDIF

				DbSelectArea("SC6")
				DbSetOrder(1)
				If  DbSeek(xFilial("SC6")+M->C5_NUM   +aCols[i,_Item])
					While ! RecLock("SC6",.F.) ; End
					SC6->C6_ITEM    := strzero(wItem,2)
					SC6->C6_PRODUTO := aCols[i,_Produto]
					SC6->C6_UM      := aCols[i,_Um]
					SC6->C6_QTDVEN  := aCols[i,_Qtdven]
					SC6->C6_PRCVEN  := aCols[i,_Prcven]
					SC6->C6_VALOR   := aCols[i,_Valor]
					SC6->C6_QTDLIB  := aCols[i,_Qtdlib]
					SC6->C6_TES     := aCols[i,_Tes]
					SC6->C6_CF      := aCols[i,_Cf]
					SC6->C6_LOCAL   := aCols[i,_Local]
					SC6->C6_NUM     := aCols[i,_Num]
					MsUnLock()
				ELSE
					RecLock("SC6",.T.)
					_ProxItem := _ProxItem + 1

					SC6->C6_FILIAL  := xFilial("SC6")
					SC6->C6_ITEM    := strzero(wItem,2)
					SC6->C6_PRODUTO := aCols[i,_Produto]
					SC6->C6_UM      := aCols[i,_Um]
					SC6->C6_QTDVEN  := aCols[i,_Qtdven]
					SC6->C6_PRCVEN  := aCols[i,_Prcven]
					SC6->C6_VALOR   := aCols[i,_Valor]
					SC6->C6_QTDLIB  := aCols[i,_Qtdlib]
					SC6->C6_TES     := aCols[i,_Tes]
					SC6->C6_CF      := aCols[i,_Cf]
					SC6->C6_LOCAL   := aCols[i,_Local]
					SC6->C6_NUM     := aCols[i,_Num]
					MsUnLock()
				ENDIF
				//MsUnLock()
				lSZD := .T.
			End
		Next
		dbCommitAll()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava SC5 - Cabecalho Pedido de venda                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SC5")
		DbSetOrder(1)
		If  DbSeek(xFilial("SC5")+M->C5_NUM   )
			While ! RecLock("SC5",.F.) ; End
			If  lSC6
				SC5->C5_FILIAL := xFilial("SC5")
				SC5->C5_CLIENTE:= M->C5_CLIENTE
				SC5->C5_LOJACLI:= M->C5_LOJACLI  
				SC5->C5_NUM    := M->C5_NUM
				SC5->C5_EMISSAO:= M->C5_EMISSAO
				SC5->C5_TRANSP := M->C5_TRANSP
				msUnLock()
			End
		Else
			//        MsgBox("Codigo da NET (SZ2) nao encontrado.","Aten‡Æo","STOP")
		End
		dbCommitAll()
	End
	dbCommitAll()
	n := 1

Return
