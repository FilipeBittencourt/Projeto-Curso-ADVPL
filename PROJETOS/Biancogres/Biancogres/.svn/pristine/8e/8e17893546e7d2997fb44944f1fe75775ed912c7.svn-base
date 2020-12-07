#include "rwmake.ch"
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤фo    Ё BIANCO2  Ё Autor Ё Nilton Cesar          Ё Data Ё 21.02.03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤фo Ё Itens da transf. de empenho                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё RDMAKE                                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function BIANCO2()

	Local i
	SetPrvt("WOPCAO,LVISUALIZAR,LINCLUIR,LALTERAR,LEXCLUIR,NOPCE")
	SetPrvt("NOPCG,COPCAO,NUSADO,AHEADER,ACOLS,I")
	SetPrvt("WFILIAL,CTITULO,CALIASENCHOICE,CALIASGETD")
	SetPrvt("CLINOK,CTUDOK,CFIELDOK,ACPOENCHOICE,LRET,NZ9QTDLIB,NPESO")
	Private nprox := 0   
	Private _aSize := MSADVSIZE()


	MsgSTOP("NecessАrio informar Ю TI que este programa estА sendo executado para entendermos a finalidade - programa BIANCO2")

	Return

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Determina funcao selecionada                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wOpcao      := paramixb
	lVisualizar := .F.
	lIncluir    := .F.
	lExcluir    := .F.
	Do Case
		Case wOpcao == "V" ; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "I" ; lIncluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "INCLUIR"
		Case wOpcao == "E" ; lExcluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "EXCLUIR"
	EndCase
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria variaveis                                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RegToMemory("SZF",(cOpcao=="INCLUIR"))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta aHeader                                                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SZG")
	nUsado  := 0
	aHeader := {}
	While !eof() .and. SX3->X3_ARQUIVO == "SZG"
		If  X3USO(SX3->X3_USADO) .and. SX3->X3_NIVEL <= cNivel
			nUsado := nUsado + 1
			aadd(aHeader,{ trim(SX3->X3_TITULO),SX3->X3_CAMPO   , ;
			SX3->X3_PICTURE     ,SX3->X3_TAMANHO , ;
			SX3->X3_DECIMAL     ,"AllwaysTrue()" , ;
			SX3->X3_USADO       ,SX3->X3_TIPO    , ;
			SX3->X3_ARQUIVO     ,SX3->X3_CONTEXT } )
		End
		dbSkip()
	End
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta aCols                                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  lIncluir
		aCols             := {array(nUsado+1)}
		aCols[1,nUsado+1] := .F.
		For i := 1 to nUsado
			aCols[1,i] := CriaVar(aHeader[i,2])
		Next
	Else
		aCols:={}
		DbSelectArea("SZG")
		DbSetOrder(1)
		DbSeek(xFilial("SZG")+M->ZF_DOC)
		While !eof() .and. SZG->ZG_FILIAL   == xFilial("SZG") ;
		.and. SZG->ZG_DOC      == M->ZF_DOC
			aadd(aCols,array(nUsado+1))
			For i := 1 to nUsado
				aCols[len(aCols),i]    := FieldGet(FieldPos(aHeader[i,2]))
			Next
			aCols[len(aCols),nUsado+1] := .F.
			dbSkip()
		End
	End
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa variaveis                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cTitulo        := "Transferencia de Produtos em  Reserva/Empenho"
	cAliasEnchoice := "SZF"
	cAliasGetD     := "SZG"
	cLinOk         := 'execblock("BIANCO2L",.F.,.F.,)'
	cTudOk         := 'execblock("BIANCO2T",.F.,.F.,)'
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {"ZF_DOC","ZF_EMISSAO"}
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Executa funcao modelo 3                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                      

	//Parametros da funcao modelo 3
	//lRet = Retorno .T. Confirma / .F. Abandona
	//cTitulo = Titulo da Janela
	//cAlias1 = Alias da Enchoice
	//cAlias2 = Alias da GetDados
	//aMyEncho = Array com campos da Enchoice
	//cLinOk = LinOk
	//cTudOk = TudOk
	//nOpcE = nOpc da Enchoice
	//nOpcG = nOpc da GetDados
	//cFieldOk = validacao para todos os campos da GetDados
	//lVirtual = Permite visualizar campos virtuais na enchoice
	//nLinhas = Numero Maximo de linhas na getdados
	//aAltEnchoice= Array com campos da Enchoice Alteraveis
	//nFreeze = Congelamento das colunas
	//aButtons = array com botУes de usuАrio na enchoicebar
	//aCordW = coordenadas da janela
	//nSizeHeader = altura da enchoice

	lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,,,,{0,0,_aSize[6],_aSize[5]},50)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Executa processamento                                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  lRet
		fProcessa()
		ConfirmSX8()
	Else
		RollBackSX8()
	End
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Recuperar ordem do SBe                                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SBE")
	DbSetOrder(1)
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFun┤фo    Ё fProcessa                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescri┤фo Ё Processa confirmacao da tela                               Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fProcessa()
	Local i
	Private norder,lchangeDoc:=.f.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Determina posicao dos campos no aCols                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_nITEM    := aScan(aHeader,{|x| x[2]=="ZG_ITEM   "})
	_nPRODUTO := aScan(aHeader,{|x| x[2]=="ZG_PRODUTO"})
	_nDESC    := aScan(aHeader,{|x| x[2]=="ZG_DESC   "})
	_nLote    := aScan(aHeader,{|x| x[2]=="ZG_LOTECTL"})
	_nUNIDADE := aScan(aHeader,{|x| x[2]=="ZG_UNIDADE"})
	_nLOCAL   := aScan(aHeader,{|x| x[2]=="ZG_LOCAL  "})
	_nORIGEM  := aScan(aHeader,{|x| x[2]=="ZG_ORIGEM "})
	_nQTD     := aScan(aHeader,{|x| x[2]=="ZG_QTD    "})
	_nDESTINO := aScan(aHeader,{|x| x[2]=="ZG_DESTINO"})
	_nQTD2    := aScan(aHeader,{|x| x[2]=="ZG_QTD2   "})
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica funcao utilizada                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Do Case
		Case lIncluir
		Begin transaction
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁVerifica se durante a digitacao nao foi incluido um documento com o mesmo nr. por outro utuarioЁ
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("SD3")
			nOrder:=IndexOrd()
			DbSetOrder(2)
			If dbSeek(xFilial("SD3")+M->ZF_DOC)
				M->ZF_DOC := UPPER( NextNumero("SD3",2,"D3_DOC",.T.) )
				lChangeDoc := .T.
			EndIf
			dbSetOrder(nOrder)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava SZG - ITENS TRANSFERENCIA DE PRODUTOS                      Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("SZG")
			lSZG  := .F.
			For i := 1 to len(aCols)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se o item foi deletado                              Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If  ! aCols[i,nUsado+1]
					DbSelectArea("SZG")
					RecLock("SZG",.T.)
					SZG->ZG_FILIAL  := xFilial("SZG")
					SZG->ZG_DOC     := M->ZF_DOC
					SZG->ZG_ITEM    := aCols[i,_nITEM]
					SZG->ZG_PRODUTO := aCols[i,_nPRODUTO]
					SZG->ZG_DESC    := aCols[i,_nDESC]
					SZG->ZG_LOTECTL := aCols[i,_nLOTE]
					SZG->ZG_UNIDADE := aCols[i,_nUNIDADE]
					SZG->ZG_LOCAL   := aCols[i,_nLOCAL]
					SZG->ZG_ORIGEM  := aCols[i,_nORIGEM]
					SZG->ZG_QTD     := aCols[i,_nQTD]
					SZG->ZG_DESTINO := aCols[i,_nDESTINO]
					SZG->ZG_QTD2    := aCols[i,_nQTD2]
					msUnLock()
					lSZG := .T.
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Chamar a funcao para cada item gravado do transf. de empenho     Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					fgrava()
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Gravar o sequencial no item da transferencia de empenho          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					DbSelectArea("SZG")
					If RecLock("SZG",.f.)
						SZG->ZG_NUMSEQ    :=  nprox
					EndIf

				End
			Next
			If  lSZG
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Grava SZF - Cabecalho Transferencia                              Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				dbSelectArea("SZF")
				RecLock("SZF",.T.)
				SZF->ZF_FILIAL   := xFilial("SZF")
				SZF->ZF_DOC      := M->ZF_DOC
				SZF->ZF_EMISSAO  := M->ZF_EMISSAO
				msUnLock()
			EndIf
		End Transaction
		If lChangeDoc
			Help("",1,"A240DOC",,SZF->ZF_DOC,4,30)
		Endif
		Case lExcluir
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Exclui SZG - Itens da transferencia                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("SZG")
		dbSetOrder(1)
		dbSeek(xFilial("SZG")+M->ZF_DOC)
		While !eof() .and. SZG->ZG_FILIAL    == xFilial("SZG") ;
		.and.  SZG->ZG_DOC       == M->ZF_DOC
			While ! RecLock("SZG",.F.) ; End
			DbSelectArea("SZG")
			delete
			msUnLock()
			dbSkip()
		End
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Exclui SZF - Cabecalho transferencia                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("SZF")
		While ! RecLock("SZF",.F.) ; End
		delete
		msUnLock()
	EndCase
	dbCommitAll()
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤фo    Ё fgrava   Ё Autor Ё Nilton Cesar          Ё Data Ё 21.02.03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤фo Ё Gravar as movimentacoes da transf. de empenho              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё RDMAKE                                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static function fgrava()
	Local x
	Private nqtemov := 0, nregaux, aPedido:={},aItem:={},aQuant:={}, aOrigem:={} , nqteaux := 0, aSeq:= {}, aTrt := {}
	Private solaux, valaux, emiaux
	Private aNum:={},asolic:={},aquantr:={},avalida:={},aemissao:={}, aSZ9:={}, aDocres := {}
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava SBF - Saldo por localizacao - origem                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SBF")
	DbSetOrder(1)
	If DbSeek(xFilial("SBF")+SZG->ZG_LOCAL+SZG->ZG_ORIGEM+SZG->ZG_PRODUTO+SPACE(20)+SZG->ZG_LOTECTL)
		If Reclock("SBF",.f.)
			SBF->BF_EMPENHO := SBF->BF_EMPENHO - SZG->ZG_QTD
			SBF->BF_EMPEN2  := SBF->BF_EMPEN2  - SZG->ZG_QTD2
			SBF->BF_QUANT   := SBF->BF_QUANT   - SZG->ZG_QTD
			SBF->BF_QTSEGUM := SBF->BF_QTSEGUM - SZG->ZG_QTD2
			If SBF->BF_QUANT == 0 .and. SBF->BF_EMPENHO == 0
				Delete
			EndIf
			MsUnlock()
		EndIf
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava SBF - Saldo por localizacao - Destino                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SBF")
	DbSetOrder(1)
	If dbSeek(xFilial("SBF")+SZG->ZG_LOCAL+SZG->ZG_DESTINO+SZG->ZG_PRODUTO+SPACE(20)+SZG->ZG_LOTECTL)
		While !Reclock("SBF",.f.);EndDo
	Else
		While !Reclock("SBF",.t.);EndDo
		SBF->BF_FILIAL  := xFilial("SBF")
		SBF->BF_PRODUTO := SZG->ZG_PRODUTO
		SBF->BF_LOCAL   := SZG->ZG_LOCAL
		SBF->BF_PRIOR   := "ZZZ"
		SBF->BF_LOCALIZ := SZG->ZG_DESTINO
		SBF->BF_LOTECTL := SZG->ZG_LOTECTL
	EndIf
	SBF->BF_EMPENHO := SBF->BF_EMPENHO + SZG->ZG_QTD
	SBF->BF_EMPEN2  := SBF->BF_EMPEN2  + SZG->ZG_QTD2
	SBF->BF_QUANT   := SBF->BF_QUANT   + SZG->ZG_QTD
	SBF->BF_QTSEGUM := SBF->BF_QTSEGUM + SZG->ZG_QTD2
	MsUnlock()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava SD3 - Requisicao                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SB1->(DbsetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+SZG->ZG_PRODUTO))
	DbSelectArea("SD3")
	DbSetOrder(1)
	While !Reclock("SD3",.t.);EndDo
	SD3->D3_FILIAL   := xFilial("SD3")
	SD3->D3_TM       := "999"
	SD3->D3_COD      := SZG->ZG_PRODUTO
	SD3->D3_UM       := SB1->B1_UM
	SD3->D3_QUANT    := SZG->ZG_QTD
	SD3->D3_CF       := "RE4"
	SD3->D3_QTSEGUM  := SZG->ZG_QTD2
	SD3->D3_CONTA    := SB1->B1_CONTA
	SD3->D3_LOCAL    := SZG->ZG_LOCAL
	SD3->D3_DOC      := M->ZF_DOC
	SD3->D3_EMISSAO  := M->ZF_EMISSAO
	SD3->D3_GRUPO    := SB1->B1_GRUPO
	SD3->D3_NUMSEQ   := PROXNUM()
	SD3->D3_SEGUM    := SB1->B1_SEGUM
	SD3->D3_TIPO     := SB1->B1_TIPO
	SD3->D3_CHAVE    := "E0"
	SD3->D3_LOCALIZ  := SZG->ZG_ORIGEM
	SD3->D3_LOTECTL  := SZG->ZG_LOTECTL
	SD3->D3_USUARIO  := cUserName
	MsUnlock()
	nprox := SD3->D3_NUMSEQ
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava SD3 - Devolucao                                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SD3")
	DbSetOrder(1)
	While !Reclock("SD3",.t.);EndDo
	SD3->D3_FILIAL   := xFilial("SD3")
	SD3->D3_TM       := "499"
	SD3->D3_COD      := SZG->ZG_PRODUTO
	SD3->D3_UM       := SB1->B1_UM
	SD3->D3_QUANT    := SZG->ZG_QTD
	SD3->D3_CF       := "DE4"
	SD3->D3_QTSEGUM  := SZG->ZG_QTD2
	SD3->D3_CONTA    := SB1->B1_CONTA
	SD3->D3_LOCAL    := SZG->ZG_LOCAL
	SD3->D3_DOC      := M->ZF_DOC
	SD3->D3_EMISSAO  := M->ZF_EMISSAO
	SD3->D3_GRUPO    := SB1->B1_GRUPO
	SD3->D3_NUMSEQ   := nprox
	SD3->D3_SEGUM    := SB1->B1_SEGUM
	SD3->D3_TIPO     := SB1->B1_TIPO
	SD3->D3_CHAVE    := "E9"
	SD3->D3_LOCALIZ  := SZG->ZG_DESTINO
	SD3->D3_LOTECTL  := SZG->ZG_LOTECTL
	SD3->D3_USUARIO  := cUserName
	MsUnlock()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava SDB - Requisicao no arq. distribuicao                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SDB")
	DbSetOrder(1)
	While !Reclock("SDB",.t.);EndDo
	SDB->DB_FILIAL   := xFilial("SD3")
	SDB->DB_PRODUTO  := SZG->ZG_PRODUTO
	SDB->DB_LOCAL    := SZG->ZG_LOCAL
	SDB->DB_LOCALIZ  := SZG->ZG_ORIGEM
	SDB->DB_LOTECTL  := SZG->ZG_LOTECTL
	SDB->DB_DOC      := M->ZF_DOC
	SDB->DB_ITEM     := "0001"
	SDB->DB_TM       := "999"
	SDB->DB_ORIGEM   := "SD3"
	SDB->DB_QUANT    := SZG->ZG_QTD
	SDB->DB_DATA     := M->ZF_EMISSAO
	SDB->DB_NUMSEQ   := nprox
	SDB->DB_TIPO     := "M"
	SDB->DB_QTSEGUM  := SZG->ZG_QTD2
	MsUnlock()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava SD5 - Requisicao no arq. de mov. por lote                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/*DbSelectArea("SD5")
	DbSetOrder(1)
	While !Reclock("SD5",.t.);EndDo
	SD5->D5_FILIAL   := xFilial("SD5")
	SD5->D5_PRODUTO  := SZG->ZG_PRODUTO
	SD5->D5_LOCAL    := SZG->ZG_LOCAL
	SD5->D5_DOC      := M->ZF_DOC
	SD5->D5_DATA     := M->ZF_EMISSAO
	SD5->D5_ORIGLAN  := "999"
	SD5->D5_NUMSEQ   := nprox
	SD5->D5_QUANT    := SZG->ZG_QTD
	SD5->D5_LOTECTL  := SZG->ZG_LOTECTL
	SD5->D5_NUMLOTE  := SPACE(6)
	SD5->D5_DTVALID  := M->ZF_EMISSAO
	SD5->D5_QTSEGUM  := SZG->ZG_QTD2
	MsUnlock()*/

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava SDB - Devolucao no arq. distribuicao                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SDB")
	DbSetOrder(1)
	While !Reclock("SDB",.t.);EndDo
	SDB->DB_FILIAL   := xFilial("SD3")
	SDB->DB_PRODUTO  := SZG->ZG_PRODUTO
	SDB->DB_LOCAL    := SZG->ZG_LOCAL
	SDB->DB_LOCALIZ  := SZG->ZG_DESTINO
	SDB->DB_LOTECTL  := SZG->ZG_LOTECTL
	SDB->DB_DOC      := M->ZF_DOC
	SDB->DB_ITEM     := "0001"
	SDB->DB_TM       := "499"
	SDB->DB_ORIGEM   := "SD3"
	SDB->DB_QUANT    := SZG->ZG_QTD
	SDB->DB_DATA     := M->ZF_EMISSAO
	SDB->DB_NUMSEQ   := nprox
	SDB->DB_TIPO     := "M"
	SDB->DB_QTSEGUM  := SZG->ZG_QTD2
	MsUnlock()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava SD5 - Devolucao no arq. de mov. por lote                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/*DbSelectArea("SD5")
	DbSetOrder(1)
	While !Reclock("SD5",.t.);EndDo
	SD5->D5_FILIAL   := xFilial("SD5")
	SD5->D5_PRODUTO  := SZG->ZG_PRODUTO
	SD5->D5_LOCAL    := SZG->ZG_LOCAL
	SD5->D5_DOC      := M->ZF_DOC
	SD5->D5_DATA     := M->ZF_EMISSAO
	SD5->D5_ORIGLAN  := "499"
	SD5->D5_NUMSEQ   := nprox
	SD5->D5_QUANT    := SZG->ZG_QTD
	SD5->D5_LOTECTL  := SZG->ZG_LOTECTL
	SD5->D5_NUMLOTE  := SPACE(6)
	SD5->D5_DTVALID  := M->ZF_EMISSAO
	SD5->D5_QTSEGUM  := SZG->ZG_QTD2
	MsUnlock()*/

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tratar a origem do empenho                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nqtemov   := SZG->ZG_QTD
	nZ9QTDLIB := 0
	DbSelectArea("SDC")
	DbSetOrder(3)
	//DbSetOrder(5)
	//DbSeek(xFilial("SDC")+SZG->ZG_PRODUTO+SZG->ZG_LOCAL+SZG->ZG_ORIGEM)
	DbSeek(xFilial("SDC")+SZG->ZG_PRODUTO+SZG->ZG_LOCAL+SZG->ZG_LOTECTL+SPACE(6)+SZG->ZG_ORIGEM+SPACE(20))
	Do while .not. eof() .and. nqtemov > 0

		If SDC->DC_ORIGEM == "SC0"
			DbSelectArea("SC0")
			DbSetOrder(4)
			If DbSeek(xFilial("SC0")+SDC->DC_PEDIDO+SZG->ZG_PRODUTO+SZG->ZG_LOCAL+SZG->ZG_ORIGEM+SZG->ZG_LOTECTL)
				If SDC->DC_QUANT <> SC0->C0_QUANT
					MsgAlert("Quantidade da Reserva nЦo confere com o Empenho. Reserva N╨ "+Alltrim(SDC->DC_PEDIDO) + " Produto: " +Alltrim(SDC->DC_PRODUTO)+ ". Contate o setor de TI - Urgente")
				EndIf
			Else
				MsgAlert("NЦo encontrou a Reserva N╨ "+Alltrim(SDC->DC_PEDIDO) + " Produto: " +Alltrim(SDC->DC_PRODUTO)+ ". Contate o setor de TI - Urgente")
			EndIf
		ElseIf SDC->DC_ORIGEM == "SC6"
			DbSelectArea("SZ9")
			DbSetOrder(6)    
			If DbSeek(xFilial("SZ9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_LOTECTL)
				nZ9QTDLIB := 0
				Do while .not. eof() .and. Z9_FILIAL == xFilial("SZ9") .and. SZ9->Z9_PEDIDO+SZ9->Z9_ITEM+SZ9->Z9_SEQUEN+SZ9->Z9_PRODUTO+SZ9->Z9_LOCAL+SZ9->Z9_LOCALIZ+SZ9->Z9_LOTECTL == SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_LOTECTL
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verificar se o item do romaneio existe no SC9 ativo              Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					DbSelectArea("SC9")
					DbSetOrder(11)
					If !DbSeek(xFilial("SC9")+SZ9->Z9_AGREG+SZ9->Z9_PEDIDO+SZ9->Z9_ITEM)
						DbSelectArea("SZ9")
						DbSkip()
						Loop
					EndIf
					nZ9QTDLIB := nZ9QTDLIB + SZ9->Z9_QTDLIB
					DbSelectArea("SZ9")
					DbSkip()
				End

				DbSelectArea("SZ9")
				If SDC->DC_QUANT <> nZ9QTDLIB
					MsgAlert("Quantidade do Pedido nЦo confere com o Empenho. Pedido N╨ "+Alltrim(SDC->DC_PEDIDO) + " Produto: " +Alltrim(SDC->DC_PRODUTO)+ ". Contate o setor de TI - Urgente")
				EndIf
			Else
				DbSelectArea("SC9")
				DbSetOrder(1)
				If DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO)
					IF EMPTY(SC9->C9_NFISCAL) .AND. !EMPTY(SC9->C9_AGREG) 
						MsgAlert("NЦo encontrou o Pedido N╨ "+Alltrim(SDC->DC_PEDIDO) + " Produto: " +Alltrim(SDC->DC_PRODUTO)+ ". Contate o setor de TI - Urgente")
					Endif
				Endif			
			EndIf
		Else        
			MsgAlert("NЦo encontrou o Pedido / Reserva N╨ "+Alltrim(SDC->DC_PEDIDO) + " Produto: " +Alltrim(SDC->DC_PRODUTO)+ ". Contate o setor de TI - Urgente")
		EndIf

		If SDC->DC_QUANT > nqtemov  //Se a quantidade for suficiente
			while !Reclock("SDC",.f.);EndDo
			Aadd(aOrigem ,SDC->DC_ORIGEM)
			Aadd(aPedido ,SDC->DC_PEDIDO)
			Aadd(aItem   ,SDC->DC_ITEM)
			Aadd(aSeq    ,SDC->DC_SEQ)
			Aadd(aTrt    ,SDC->DC_TRT)
			Aadd(aQuant  ,nqtemov)
			nqteaux := SDC->DC_QUANT
			SDC->DC_QUANT   := SDC->DC_QUANT   - nqtemov
			SDC->DC_QTDORIG := SDC->DC_QUANT //SDC->DC_QTDORIG - nqtemov //RANISSES
			SDC->DC_QTSEGUM := ConvUM(SZG->ZG_PRODUTO,SDC->DC_QUANT,0,2)
			SDC->DC_YALTERA := 'BIANCO2-1'
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acertar o arquivo de reserva do faturamento                      Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If SDC->DC_ORIGEM == "SC0"
				DbSelectArea("SC0")
				DbSetOrder(4)
				If DbSeek(xFilial("SC0")+SDC->DC_PEDIDO+SZG->ZG_PRODUTO+SZG->ZG_LOCAL+SZG->ZG_ORIGEM+SZG->ZG_LOTECTL)
					If SDC->DC_QUANT == 0
						Aadd(aNum  ,   SC0->C0_NUM)
						Aadd(aSolic,   SC0->C0_SOLICIT)
						Aadd(aDocres,  SC0->C0_DOCRES)
						Aadd(aQuantr,  nqteaux)
						Aadd(aValida,  SC0->C0_VALIDA)
						Aadd(aEmissao, SC0->C0_EMISSAO)
						while !Reclock("SC0",.f.);EndDo
						Delete
						MsUnlock()
					Else
						Aadd(aNum  ,   SC0->C0_NUM)
						Aadd(aSolic,   SC0->C0_SOLICIT)
						Aadd(aDocres,  SC0->C0_DOCRES)
						Aadd(aQuantr,  nqtemov)
						Aadd(aValida,  SC0->C0_VALIDA)
						Aadd(aEmissao, SC0->C0_EMISSAO)
						while !Reclock("SC0",.f.);EndDo
						SC0->C0_QUANT   := SC0->C0_QUANT - nqtemov
						SC0->C0_QTDORIG := SC0->C0_QUANT
						If  SC0->C0_QUANT  == 0
							Delete
						EndIf
						MsUnlock()
					EndIf
				EndIf        	
				nqtemov -= nqteaux       
			EndIf       

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acertar o arquivo de romaneio (SZ9)                              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If SDC->DC_ORIGEM == "SC6"
				DbSelectArea("SZ9")
				DbSetOrder(6)
				If DbSeek(xFilial("SZ9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_LOTECTL)
					Do while .not. eof() .and. Z9_FILIAL == xFilial("SZ9") .and. ;
					SZ9->Z9_PEDIDO+SZ9->Z9_ITEM+SZ9->Z9_SEQUEN+SZ9->Z9_PRODUTO+SZ9->Z9_LOCAL+SZ9->Z9_LOCALIZ+SZ9->Z9_LOTECTL == ;
					SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_LOTECTL

						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verificar se o item do romaneio existe no SC9 ativo              Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						aSZ9 := {}					
						DbSelectArea("SC9")
						DbSetOrder(11)
						If !DbSeek(xFilial("SC9")+SZ9->Z9_AGREG+SZ9->Z9_PEDIDO+SZ9->Z9_ITEM)
							DbSelectArea("SZ9")
							DbSkip()
							Loop
						EndIf
						DbSelectArea("SZ9")
						nRegSZ9 := RECNO()
						Aadd(aSZ9,Z9_NUMERO)
						Aadd(aSZ9,Z9_AGREG)
						Aadd(aSZ9,Z9_PEDIDO)
						Aadd(aSZ9,Z9_ITEM)
						Aadd(aSZ9,Z9_SEQUEN)
						Aadd(aSZ9,Z9_PRODUTO)
						Aadd(aSZ9,Z9_DESCRIC)
						Aadd(aSZ9,Z9_QTDLIB) 
						Aadd(aSZ9,Z9_QTDLIB2)	
						Aadd(aSZ9,Z9_QTDORI)	
						Aadd(aSZ9,Z9_LOCALIZ)
						Aadd(aSZ9,Z9_LOTECTL)
						Aadd(aSZ9,Z9_EMISSAO)
						Aadd(aSZ9,Z9_LOCAL)
						Aadd(aSZ9,Z9_NUMSEQ)
						Aadd(aSZ9,Z9_MOTOR)
						Aadd(aSZ9,Z9_PLACA)
						Aadd(aSZ9,Z9_UF)
						Aadd(aSZ9,Z9_PESOBR)	
						Aadd(aSZ9,Z9_DES)

						nPeso := SZ9->Z9_PESOBR / SZ9->Z9_QTDLIB

						nSaldo := nqtemov
						If SDC->DC_QUANT > 0
							IF nqtemov < SZ9->Z9_QTDLIB
								while !reclock("SZ9",.f.);EndDo
								SZ9->Z9_QTDLIB  := SZ9->Z9_QTDLIB - nqtemov
								SZ9->Z9_QTDLIB2 := ConvUM(SZG->ZG_PRODUTO,SZ9->Z9_QTDLIB,0,2)
								SZ9->Z9_QTDORI  := SZ9->Z9_QTDLIB
								SZ9->Z9_PESOBR  := nPeso * SZ9->Z9_QTDLIB
							ELSE
								while !reclock("SZ9",.f.);EndDo
								nSaldo := SZ9->Z9_QTDLIB
								Delete
							ENDIF
							MsUnlock()
						Else
							while !reclock("SZ9",.f.);EndDo
							Delete
							MsUnlock()
						EndIf

						DbSelectArea("SZ9")
						If !DbSeek(xFilial("SZ9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO+SDC->DC_LOCAL+SZG->ZG_DESTINO+SDC->DC_LOTECTL)
							while !reclock("SZ9",.t.);EndDo
							SZ9->Z9_FILIAL   :=xFilial("SZ9")
							SZ9->Z9_NUMERO   :=aSZ9[1]
							SZ9->Z9_AGREG    :=aSZ9[2]
							SZ9->Z9_PEDIDO   :=aSZ9[3]
							SZ9->Z9_ITEM     :=aSZ9[4]
							SZ9->Z9_SEQUEN   :=aSZ9[5]
							SZ9->Z9_PRODUTO  :=aSZ9[6]
							SZ9->Z9_DESCRIC  :=aSZ9[7]
							SZ9->Z9_QTDLIB   :=nSaldo
							SZ9->Z9_QTDLIB2  :=ConvUM(SZG->ZG_PRODUTO,nSaldo,0,2)
							SZ9->Z9_QTDORI   :=nSaldo
							SZ9->Z9_LOCALIZ  :=SZG->ZG_DESTINO
							SZ9->Z9_LOTECTL  :=aSZ9[12]
							SZ9->Z9_EMISSAO  :=aSZ9[13]
							SZ9->Z9_LOCAL    :=aSZ9[14]
							SZ9->Z9_NUMSEQ   :=aSZ9[15]
							SZ9->Z9_ORIGEM   := "S"
							SZ9->Z9_MOTOR    :=aSZ9[16]
							SZ9->Z9_PLACA    :=aSZ9[17]
							SZ9->Z9_UF       :=aSZ9[18]
							SZ9->Z9_PESOBR   :=nPeso * nSaldo
							SZ9->Z9_DES      :=aSZ9[20]
						ELSE
							while !reclock("SZ9",.f.);EndDo
							SZ9->Z9_QTDLIB  := SZ9->Z9_QTDLIB + nSaldo
							SZ9->Z9_QTDLIB2 := ConvUM(SZG->ZG_PRODUTO,SZ9->Z9_QTDLIB,0,2)
							SZ9->Z9_QTDORI  := SZ9->Z9_QTDLIB
							SZ9->Z9_PESOBR  := nPeso * SZ9->Z9_QTDLIB						
						ENDIF
						MsUnlock()

						nqtemov := nqtemov - nSaldo
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Forcar a saida do WHILE .....                                    Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						IF nqtemov <= 0
							Exit
						ENDIF
						DbSelectArea("SZ9")
						DbSetOrder(6)
						DbGoTo(nRegSZ9)
						DbSkip()
					EndDo
				Else
					//Caso nЦo encontre ROMANEIO, o sistema ira acertar a variavel nqtemov
					nqtemov -= nqteaux       
				EndIf
			EndIf

			DbSelectArea("SDC")
			If SDC->DC_QUANT == 0 //Se ficar zero excluo o item
				Delete
			EndIf
			MsUnlock()
		Else
			DbSelectArea("SDC")
			while !Reclock("SDC",.f.);EndDo
			Aadd(aOrigem ,SDC->DC_ORIGEM)
			Aadd(aPedido ,SDC->DC_PEDIDO)
			Aadd(aItem   ,SDC->DC_ITEM)
			Aadd(aSeq    ,SDC->DC_SEQ)
			Aadd(aTrt    ,SDC->DC_TRT)
			Aadd(aQuant  ,SDC->DC_QUANT)
			nqtemov  -= SDC->DC_QUANT
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acertar o arquivo de reserva do faturamento                      Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If SDC->DC_ORIGEM == "SC0"
				DbSelectArea("SC0")
				DbSetOrder(1)
				If DbSeek(xFilial("SC0")+SDC->DC_PEDIDO+SZG->ZG_PRODUTO+SZG->ZG_LOCAL)
					Aadd(aNum  ,   SC0->C0_NUM)
					Aadd(aSolic,   SC0->C0_SOLICIT)
					Aadd(aDocres,  SC0->C0_DOCRES)
					Aadd(aQuantr,  SC0->C0_QUANT)
					Aadd(aValida,  SC0->C0_VALIDA)
					Aadd(aEmissao, SC0->C0_EMISSAO)
					while !Reclock("SC0",.f.);EndDo
					Delete
					MsUnlock()
				EndIf
			EndIf

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acertar o arquivo de romaneio (SZ9)                              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If SDC->DC_ORIGEM == "SC6"
				nQtdSDC := SDC->DC_QUANT
				DbSelectArea("SZ9")
				DbSetOrder(6)
				If DbSeek(xFilial("SZ9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_LOTECTL)
					Do while .not. eof() .and. Z9_FILIAL == xFilial("SZ9") .and. ;
					SZ9->Z9_PEDIDO+SZ9->Z9_ITEM+SZ9->Z9_SEQUEN+SZ9->Z9_PRODUTO+SZ9->Z9_LOCAL+SZ9->Z9_LOCALIZ+SZ9->Z9_LOTECTL == ;
					SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_LOTECTL

						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verificar se o item do romaneio existe no SC9 ativo              Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						aSZ9 := {}
						DbSelectArea("SC9")
						DbSetOrder(11)
						If !DbSeek(xFilial("SC9")+SZ9->Z9_AGREG+SZ9->Z9_PEDIDO+SZ9->Z9_ITEM)
							DbSelectArea("SZ9")
							DbSkip()
							Loop
						EndIf
						DbSelectArea("SZ9")
						nRegSZ9 := RECNO()

						Aadd(aSZ9,Z9_NUMERO)
						Aadd(aSZ9,Z9_AGREG)
						Aadd(aSZ9,Z9_PEDIDO)
						Aadd(aSZ9,Z9_ITEM)
						Aadd(aSZ9,Z9_SEQUEN)
						Aadd(aSZ9,Z9_PRODUTO)
						Aadd(aSZ9,Z9_DESCRIC)
						Aadd(aSZ9,Z9_QTDLIB)
						Aadd(aSZ9,Z9_QTDLIB2)
						Aadd(aSZ9,Z9_QTDORI)
						Aadd(aSZ9,Z9_LOCALIZ)
						Aadd(aSZ9,Z9_LOTECTL)
						Aadd(aSZ9,Z9_EMISSAO)
						Aadd(aSZ9,Z9_LOCAL)
						Aadd(aSZ9,Z9_NUMSEQ)
						Aadd(aSZ9,Z9_MOTOR)
						Aadd(aSZ9,Z9_PLACA)
						Aadd(aSZ9,Z9_UF)
						Aadd(aSZ9,Z9_PESOBR)
						Aadd(aSZ9,Z9_DES)
						while !Reclock("SZ9",.f.);EndDo
						Delete
						MsUnlock()

						nPeso := SZ9->Z9_PESOBR / SZ9->Z9_QTDLIB

						If !DbSeek(xFilial("SZ9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO+SDC->DC_LOCAL+SZG->ZG_DESTINO+SDC->DC_LOTECTL)
							while !Reclock("SZ9",.t.);EndDo
							SZ9->Z9_FILIAL   :=xFilial("SZ9")
							SZ9->Z9_NUMERO   :=aSZ9[1]
							SZ9->Z9_AGREG    :=aSZ9[2]
							SZ9->Z9_PEDIDO   :=aSZ9[3]
							SZ9->Z9_ITEM     :=aSZ9[4]
							SZ9->Z9_SEQUEN   :=aSZ9[5]
							SZ9->Z9_PRODUTO  :=aSZ9[6]
							SZ9->Z9_DESCRIC  :=aSZ9[7]
							SZ9->Z9_QTDLIB   :=aSZ9[8]
							SZ9->Z9_QTDLIB2  :=aSZ9[9]
							SZ9->Z9_QTDORI   :=aSZ9[10]
							SZ9->Z9_LOCALIZ  :=SZG->ZG_DESTINO
							SZ9->Z9_LOTECTL  :=aSZ9[12]
							SZ9->Z9_EMISSAO  :=aSZ9[13]
							SZ9->Z9_LOCAL    :=aSZ9[14]
							SZ9->Z9_NUMSEQ   :=aSZ9[15]
							SZ9->Z9_ORIGEM   := "S"
							SZ9->Z9_MOTOR    :=aSZ9[16]
							SZ9->Z9_PLACA    :=aSZ9[17]
							SZ9->Z9_UF       :=aSZ9[18]
							SZ9->Z9_PESOBR   :=nPeso * aSZ9[8] 
							SZ9->Z9_DES      :=aSZ9[20]
						ELSE
							while !reclock("SZ9",.f.);EndDo
							SZ9->Z9_QTDLIB  := SZ9->Z9_QTDLIB + aSZ9[8]
							SZ9->Z9_QTDLIB2 := ConvUM(SZG->ZG_PRODUTO,SZ9->Z9_QTDLIB,0,2)
							SZ9->Z9_QTDORI  := SZ9->Z9_QTDLIB
							SZ9->Z9_PESOBR  := nPeso * SZ9->Z9_QTDLIB						
						ENDIF
						MsUnlock()

						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Forcar a saida do WHILE                                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nQtdSDC := nQtdSDC - aSZ9[8]
						IF nQtdSDC <= 0
							Exit         
						ENDIF

						DbSelectArea("SZ9")
						DbSetOrder(6)
						DbGoTo(nRegSZ9)
						DbSkip()
					EndDo
				EndIf
			EndIf
			DbSelectArea("SDC")
			SDC->DC_YEXCLUI := 'BIANCO2-1'
			Delete
			MsUnlock()
		EndIf
		DbSelectArea("SDC")
		DbSkip()
	EndDo
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gravar novo empenho                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For x:=1 to Len(aOrigem)
		DbSelectArea("SDC")
		//DbSetOrder(5)
		DbSetOrder(1)
		If aOrigem[x] == "SC6"
			If DbSeek(xFilial("SDC")+SZG->ZG_PRODUTO+SZG->ZG_LOCAL+aOrigem[x]+aPedido[x]+aItem[x]+aSeq[x]+SZG->ZG_LOTECTL+SPACE(6)+SZG->ZG_DESTINO+SPACE(20))
				while !Reclock("SDC",.f.);EndDo
				SDC->DC_YALTERA := 'BIANCO2-2'
			Else
				while !Reclock("SDC",.T.);EndDo
				SDC->DC_FILIAL    := xFilial("SDC")
				SDC->DC_PRODUTO   := SZG->ZG_PRODUTO
				SDC->DC_ORIGEM    := aOrigem[x]
				SDC->DC_LOCAL     := SZG->ZG_LOCAL
				SDC->DC_LOCALIZ   := SZG->ZG_DESTINO
				SDC->DC_LOTECTL   := SZG->ZG_LOTECTL
				SDC->DC_TRT       := aTrt[x]
				SDC->DC_PEDIDO    := aPedido[x]
				SDC->DC_ITEM      := aItem[x]
				SDC->DC_SEQ       := aSeq[x]
				SDC->DC_YINCLUI   := 'BIANCO2-1'
			EndIf
			SDC->DC_QUANT     := SDC->DC_QUANT + aQuant[X]
			SDC->DC_QTDORIG   := SDC->DC_QUANT
			SDC->DC_QTSEGUM   := ConvUM(SZG->ZG_PRODUTO,SDC->DC_QUANT,0,2)
			MsUnlock()
		ElseIf	aOrigem[x] == "SC0"
			while !Reclock("SDC",.T.);EndDo
			SDC->DC_FILIAL    := xFilial("SDC")
			SDC->DC_PRODUTO   := SZG->ZG_PRODUTO
			SDC->DC_ORIGEM    := aOrigem[x]
			SDC->DC_LOCAL     := SZG->ZG_LOCAL
			SDC->DC_LOCALIZ   := SZG->ZG_DESTINO
			SDC->DC_LOTECTL   := SZG->ZG_LOTECTL
			SDC->DC_TRT       := aTrt[x]
			SDC->DC_PEDIDO    := GetSX8Num("SC0","C0_NUM") //aPedido[x]
			SDC->DC_YINCLUI   := 'BIANCO2-2'
			ConfirmSX8()
			If Ascan(aNum,aPedido[x]) <> 0
				aNum[Ascan(aNum,aPedido[x])] := SDC->DC_PEDIDO
			EndIf
			SDC->DC_ITEM      := aItem[x]
			SDC->DC_SEQ       := aSeq[x]
			SDC->DC_QUANT     := SDC->DC_QUANT + aQuant[X]
			SDC->DC_QTDORIG   := SDC->DC_QUANT
			SDC->DC_QTSEGUM   := ConvUM(SZG->ZG_PRODUTO,SDC->DC_QUANT,0,2)
			MsUnlock()
		EndIf
	Next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gravar o arquivo de reserva do faturamento                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For x:=1 to Len(aNum)
		DbSelectArea("SC0")
		DbSetOrder(7)
		If DbSeek(xFilial("SC0")+aNum[x]+SZG->ZG_PRODUTO+SZG->ZG_LOCAL+SZG->ZG_DESTINO+SZG->ZG_LOTECTL)
			while !Reclock("SC0",.f.);EndDo
		Else
			while !Reclock("SC0",.T.);EndDo
			SC0->C0_FILIAL    := xFilial("SC0")
			SC0->C0_NUM       := aNum[x]
			SC0->C0_TIPO	  := "VD"
			SC0->C0_SOLICIT   := aSolic[x]
			SC0->C0_DOCRES    := aDocres[x]
			SC0->C0_FILRES    := xFilial("SC0")
			SC0->C0_PRODUTO   := SZG->ZG_PRODUTO
			SC0->C0_LOCAL     := SZG->ZG_LOCAL
			SC0->C0_VALIDA    := aValida[x]
			SC0->C0_EMISSAO   := aEmissao[x]
			SC0->C0_LOCALIZ   := SZG->ZG_DESTINO
			SC0->C0_LOTECTL   := SZG->ZG_LOTECTL
		EndIf
		SC0->C0_QUANT     := SC0->C0_QUANT + aQuantr[x]
		SC0->C0_QTDORIG   := SC0->C0_QUANT
		MsUnlock()
	Next
Return
