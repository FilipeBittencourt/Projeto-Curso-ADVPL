#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 16/05/02
#Include "topconn.ch"
User Function BIA019()        // incluido pelo assistente de conversao do AP5 IDE em 16/05/02

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
	//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
	//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
	//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local i
	SetPrvt("WOPCAO,LVISUALIZAR,LINCLUIR,LALTERAR,LEXCLUIR,NOPCE")
	SetPrvt("NOPCG,COPCAO,NUSADO,AHEADER,ACOLS,I")
	SetPrvt("CTITULO,CALIASENCHOICE,CALIASGETD,CLINOK,CTUDOK,CFIELDOK")
	SetPrvt("ACPOENCHOICE,LRET,WP_EST,WP_CLASSE,WP_VALOR,wP_DTINI,_ACAMPOS")
	SetPrvt("_CTRAB,LSZ1,LSE1,")       

	/*/
	эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
	╠╠ЁFun┤фo    Ё BIA019   Ё Autor Ё MICROSIGA Vitoria     Ё Data Ё 28.05.99 Ё╠╠
	╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
	╠╠ЁDescri┤фo Ё Cadastro de Precos - atualizacao                           Ё╠╠
	╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
	╠╠Ё Uso      Ё RDMAKE                                                     Ё╠╠
	╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
	/*/
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Determina funcao selecionada                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wOpcao      := paramixb
	lVisualizar := .F.
	lIncluir    := .F.
	lAlterar    := .F.
	lExcluir    := .F.
	Do Case
		Case wOpcao == "V" ; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "I" ; lIncluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "INCLUIR" 
		Case wOpcao == "A" ; lAlterar    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "ALTERAR" 
		Case wOpcao == "E" ; lExcluir    := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "EXCLUIR" 
	EndCase
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria variaveis                                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RegToMemory("SZ2",(cOpcao=="INCLUIR"))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta aHeader                                                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SX3")
	dbSetOrder(2)
	nUsado  := 0
	aHeader := {}
	dbSeek("Z1_EST    ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("Z1_CLASSE ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("Z1_VALOR  ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("Z1_DTINIPR") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
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
		dbSelectArea("SZ1")
		dbSetOrder(2)
		dbSeek(xFilial("SZ1")+M->Z2_REFER+dtos(M->Z2_DTINIPR))
		While !eof() .and. SZ1->Z1_FILIAL  == xFilial("SZ1") ;
		.and. SZ1->Z1_REFER   == M->Z2_REFER ;
		.and. SZ1->Z1_DTINIPR   == M->Z2_DTINIPR 
			aadd(aCols,array(nUsado+1))
			For i := 1 to nUsado
				aCols[len(aCols),i]    := FieldGet(FieldPos(aHeader[i,2]))
			Next 
			aCols[len(aCols),nUsado+1] := .F.
			dbSkip()
		End
	End
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa variaveis                                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cTitulo        := "Cadastro de Precos"
	cAliasEnchoice := "SZ2"
	cAliasGetD     := "SZ1"
	//cLinOk         := "AllwaysTrue()"
	//cLinOk         := "Empty(aCols[n,1]).And.!Empty(aCols[n,2]).And.!Empty(aCols[n,3])"
	cLinOk         := 'EXECBLOCK("BIA311",.F.,.F.)'
	cTudOk         := 'EXECBLOCK("CVALIDAT",.F.,.F.)'
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {"Z2_REFER","Z1_DTINIPR","Z2_DTFIMPR"}
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Seleciona ordem                                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SZ1")
	dbSetOrder(1)
	dbSelectArea("SZ2")
	dbSetOrder(1)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Executa funcao modelo 3                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,300)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Executa processamento                                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  lRet
		fProcessa()
	End

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

// Substituido pelo assistente de conversao do AP5 IDE em 16/05/02 ==> Function fProcessa
Static Function fProcessa()
	local cSQL
	Local i
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Determina posicao dos campos no aCols                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wP_EST     := aScan(aHeader,{|x| x[2]=="Z1_EST    "})
	wP_CLASSE  := aScan(aHeader,{|x| x[2]=="Z1_CLASSE "})
	wP_VALOR   := aScan(aHeader,{|x| x[2]=="Z1_VALOR  "})
	wP_DTINI   := aScan(aHeader,{|x| x[2]=="Z1_DTINIPR"})


	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao do arquivo de trabalho                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_aCampos := { {"EST    ","C", 2,0},;
	{"CLASSE ","C", 1,0},;
	{"VALOR  ","N",14,2},;
	{"DataInicio ","D", 8,0}}
	_cTrab := CriaTrab(_aCampos)
	dbUseArea(.T.,,_cTrab,"_cTrab")
	dbCreateInd(_cTrab,"_cTrab",{||EST+CLASSE})
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta arquivo de trabalho                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("_cTrab")
	//cSQL := "Select * From " + RETSQLNAME("SZ1") + " "
	//cSQL += "where	Z1_REFER = '"+ M->Z2_REFER + "' AND "
	//cSQL += "	Z1_DTINIPR = '"+ dtos(M->Z2_DTINIPR) + "' " 
	//If chkfile("_cTrab")
	//	dbSelectArea("_cTrab")
	//	dbCloseArea()
	//End If
	//TCQUERY cSQL ALIAS "_cTrab" NEW
	For i := 1 to len(aCols)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o item foi deletado                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ! aCols[i,nUsado+1]
			RecLock("_cTrab",.T.)
			_cTrab->EST     := aCols[i,wP_EST    ]
			_cTrab->CLASSE  := aCols[i,wP_CLASSE ]
			_cTrab->VALOR   := aCols[i,wP_VALOR  ]
			_cTrab->DataInicio :=aCols[i,wP_DTINI  ]
			msUnLock()
		End
	Next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica funcao utilizada                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Do Case
		Case lIncluir
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Processa arquivo de trabalho                                     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("_cTrab")
		dbGoTop()
		lSZ1     := .F.
		While !eof()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava SZ1 -                                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("SZ1")
			RecLock("SZ1",.T.)
			SZ1->Z1_FILIAL  := xFilial("SZ1")
			SZ1->Z1_REFER   := M->Z2_REFER
			SZ1->Z1_CLASSE  := _cTrab->CLASSE
			SZ1->Z1_EST     := _cTrab->EST
			SZ1->Z1_VALOR   := _cTrab->VALOR
			SZ1->Z1_DTINIPR := M->Z2_DTINIPR
			msUnLock()
			lSE1 := .T.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acessa proximo registro                                       Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("_cTrab")
			dbSkip()
		End
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava SZ2                                                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  lSE1
			dbSelectArea("SZ2")
			RecLock("SZ2",.T.)
			SZ2->Z2_FILIAL  := xFilial("SZ2")
			SZ2->Z2_REFER   := M->Z2_REFER
			SZ2->Z2_DTINI   := M->Z2_DTINI
			SZ2->Z2_DTFIM   := M->Z2_DTFIM
			SZ2->Z2_COMISS  := M->Z2_COMISS
			SZ2->Z2_DTINIPR := M->Z2_DTINIPR
			SZ2->Z2_DTFIMPR := M->Z2_DTFIMPR
			msUnLock()
		End
		Case lAlterar
		dbSelectArea("SZ1")       //Z1_DTINIPR   dtos(ACols[n, aScan(aHeader,{|x| x[2]=="Z1_DTINIPR"})])
		dbSetOrder(2)
		dbSeek(xFilial("SZ1")+M->Z2_REFER+ dtos(M->Z2_DTINIPR) ) //dtos(ACols[n, aScan(aHeader,{|x| x[2]=="Z1_DTINIPR"})]) )//dtos(M->Z2_DTINIPR))
		While !eof() .and. SZ1->Z1_FILIAL == xFilial("SZ1") ;
		.and. SZ1->Z1_REFER  == M->Z2_REFER ;
		.and. SZ1->Z1_DTINIPR  == M->Z2_DTINIPR //ACols[n, aScan(aHeader,{|x| x[2]=="Z1_DTINIPR"})]  //M->Z2_DTINIPR 
			While ! RecLock("SZ1",.F.) ; End
			delete
			msUnLock()
			dbSkip()
		End

		dbSelectArea("_cTrab")
		dbGoTop()
		lSZ1     := .F.
		While ! Eof()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava SZ1 -                                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			RecLock("SZ1",.T.)
			SZ1->Z1_FILIAL  := xFilial("SZ2")
			SZ1->Z1_REFER   := M->Z2_REFER
			SZ1->Z1_CLASSE  := _cTrab->CLASSE
			SZ1->Z1_EST     := _cTrab->EST  
			SZ1->Z1_VALOR   := _cTrab->VALOR
			SZ1->Z1_DTINIPR := M->Z2_DTINIPR
			msUnLock()
			lSE1 := .T.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acessa proximo registro                                       Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("_cTrab")
			dbSkip()
		End
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava SZ2                                                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  lSE1
			dbSelectArea("SZ2")
			RecLock("SZ2",.F.)
			SZ2->Z2_REFER   := M->Z2_REFER
			SZ2->Z2_DTINI   := M->Z2_DTINI
			SZ2->Z2_DTFIM   := M->Z2_DTFIM
			SZ2->Z2_COMISS  := M->Z2_COMISS
			SZ2->Z2_DTINIPR	:= M->Z2_DTINIPR
			SZ2->Z2_DTFIMPR	:= M->Z2_DTFIMPR
			msUnLock()
		End
		Case lExcluir
		dbSelectArea("_cTrab")
		dbGoTop()
		lSZ1 := .F.
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Deleta SZ1                                                    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("SZ1")
		dbSetOrder(2)
		dbSeek(xFilial("SZ1")+M->Z2_REFER+dtos(M->Z2_DTINIPR))
		While !eof() .and. SZ1->Z1_FILIAL  == xFilial("SZ1") ;
		.and. SZ1->Z1_REFER   == M->Z2_REFER;
		.and. SZ1->Z1_DTINIPR  == M->Z2_DTINIPR    
			While ! RecLock("SZ1",.F.) ; End
			delete
			lSE1 := .T.
			msUnLock()
			dbSkip()
		End
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё DELETA SZ2                                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  lSE1
			dbSelectArea("SZ2")
			While ! RecLock("SZ2",.F.) ; End
			delete
			msUnLock()
		End
	EndCase
	dbCommitAll()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Apaga arquivo de trabalho                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("_cTrab")
	USE
	If  File(_cTrab+".DBF")
		Ferase(_cTrab+".DBF")
		Ferase(_cTrab+".NTX")
		Ferase(_cTrab+".CDX")
	End

Return

