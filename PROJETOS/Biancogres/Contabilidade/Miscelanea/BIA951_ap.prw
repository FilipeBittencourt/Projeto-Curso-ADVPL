#include "protheus.ch"         // incluido pelo assistente de conversao do AP6 IDE em 31/05/05

User Function BIA951()        // incluido pelo assistente de conversao do AP6 IDE em 31/05/05

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
	//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
	//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
	//Ё Incluido pelo assistente de conversao do AP6 IDE                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local i

	/*/
	эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
	╠╠ЁFun┤фo    Ё BIA951   Ё Autor Ё Ranisses A. Corona    Ё Data Ё 31.05.05 Ё╠╠
	╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
	╠╠ЁDescri┤фo Ё Cadastro de Contratos - atualizacao                        Ё╠╠
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
	RegToMemory("SZM",(cOpcao=="INCLUIR"))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta aHeader                                                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SX3")
	dbSetOrder(2)
	nUsado  := 0
	aHeader := {}
	//dbSeek("ZN_COD    ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})
	dbSeek("ZN_CONTA  ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})
	dbSeek("ZN_DC     ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta aCols                                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lMovimentado := .F.
	If  lIncluir
		aCols             := {array(nUsado+1)}
		aCols[1,nUsado+1] := .F.
		For i := 1 to nUsado
			aCols[1,i] := CriaVar(aHeader[i,2])
		Next
	Else
		aCols:={}
		dbSelectArea("SZN")
		dbSetOrder(1)
		dbSeek(xFilial("SZN")+M->ZM_COD)
		While !eof() .and. SZN->ZN_FILIAL  == xFilial("SZM") ;
		.and. SZN->ZN_COD     == M->ZM_COD
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
	cTitulo        := "Gerenciamento de Relatorios Contabeis"
	cAliasEnchoice := "SZM"
	cAliasGetD     := "SZN"
	cLinOk         := "AllwaysTrue()"
	cTudOk         := "AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {"ZN_COD"}
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Seleciona ordem                                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SZM")
	dbSetOrder(1)
	dbSelectArea("SZN")
	dbSetOrder(1)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Executa funcao modelo 3                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,300,,,,{0,0,MSADVSIZE()[6],MSADVSIZE()[5]})
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

// Substituido pelo assistente de conversao do AP6 IDE em 31/05/05 ==> Function fProcessa
Static Function fProcessa()

	Local i 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Determina posicao dos campos no aCols                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wP_COD     := aScan(aHeader,{|x| x[2]=="ZN_COD    "})
	wP_CONTA   := aScan(aHeader,{|x| x[2]=="ZN_CONTA  "})
	wP_DC      := aScan(aHeader,{|x| x[2]=="ZN_DC     "})

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao do arquivo de trabalho                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_aCampos := { {"CONTA  ","C",15,0},;
	{"DC     ","C", 1,0} }
	_cTrab := CriaTrab(_aCampos)
	dbUseArea(.T.,,_cTrab,"_cTrab")
	dbCreateInd(_cTrab,"_cTrab",{||CONTA})
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta arquivo de trabalho                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("_cTrab")
	For i := 1 to len(aCols)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o item foi deletado                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ! aCols[i,nUsado+1]
			RecLock("_cTrab",.T.)
			_cTrab->CONTA   := aCols[i,wP_CONTA  ]
			_cTrab->DC      := aCols[i,wP_DC     ]
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
		lSZN     := .F.
		While !eof()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava SZN -                                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("SZN")
			RecLock("SZN",.T.)
			SZN->ZN_FILIAL  := xFilial("SZN")
			SZN->ZN_COD     := M->ZM_COD
			SZN->ZN_CONTA   := _cTrab->CONTA
			SZN->ZN_DC      := _cTrab->DC
			msUnLock()
			lSE2 := .T.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acessa proximo registro                                       Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("_cTrab")
			dbSkip()
		End
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava SZM                                                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  lSE2
			dbSelectArea("SZM")
			RecLock("SZM",.T.)
			SZM->ZM_FILIAL  := xFilial("SZM")
			SZM->ZM_COD     := M->ZM_COD
			SZM->ZM_DESCRI  := M->ZM_DESCRI
			SZM->ZM_SING    := M->ZM_SING
			msUnLock()
		End
		Case lAlterar

		dbSelectArea("SZN")
		dbSetOrder(1)
		dbSeek(xFilial("SZN")+M->ZM_COD)
		While !eof() .and. SZN->ZN_FILIAL  == xFilial("SZN") ;
		.and. SZN->ZN_COD     == M->ZM_COD      
			While ! RecLock("SZN",.F.) ; End
			delete
			msUnLock()
			dbSkip()
		End

		dbSelectArea("_cTrab")
		dbGoTop()
		lSZN     := .F.
		While ! Eof()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava SZN -                                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			RecLock("SZN",.T.)
			SZN->ZN_FILIAL  := xFilial("SZN")
			SZN->ZN_COD     := M->ZM_COD
			SZN->ZN_CONTA   := _cTrab->CONTA
			SZN->ZN_DC      := _cTrab->DC
			msUnLock()
			lSE2 := .T.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acessa proximo registro                                       Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("_cTrab")
			dbSkip()
		End
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava SZM                                                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  lSE2
			dbSelectArea("SZM")
			RecLock("SZM",.F.)
			SZM->ZM_DESCRI  := M->ZM_DESCRI
			SZM->ZM_SING    := M->ZM_SING
			msUnLock()
		End
		Case lExcluir
		dbSelectArea("_cTrab")
		dbGoTop()
		lSZN := .F.
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Deleta SZN                                                    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("SZN")
		dbSetOrder(1)
		dbSeek(xFilial("SZN")+M->ZM_COD)
		While !eof() .and. SZN->ZN_FILIAL  == xFilial("SZN") ;
		.and. SZN->ZN_COD     == M->ZM_COD      
			While ! RecLock("SZN",.F.) ; End
			delete
			lSE2 := .T.
			msUnLock()
			dbSkip()
		End
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё DELETA SZM                                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  lSE2
			dbSelectArea("SZM")
			While ! RecLock("SZM",.F.) ; End
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
