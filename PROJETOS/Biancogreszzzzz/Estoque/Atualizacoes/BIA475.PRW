#include "PROTHEUS.CH"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#include "RWMAKE.CH"
#INCLUDE "topconn.ch"
#include "TOTVS.CH"
#include "vkey.ch"

User Function BIA475()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥ BIA475     ≥ Autor ≥ FERNANDO ROCHA        ≥ Data ≥ 17/08/10 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÑo ≥ CONTROLE DE DEFEITOS									        ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥ Uso      ≥ BIANCOGRES                                                   ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
	/*/

	Local aCores    := {}
	Local aIndDAK   := {}
	Local cCondicao := ""

	Private cCadastro 	:= "CONTROLE DE DEFEITOS"
	private aRotina 	:= {	{"Pesquisa"  			,"AxPesqui" 		,0,1},;
	{"Visualizar"			,"U_B475MTEL('V')" 	,0,2},;
	{"Incluir"   			,"U_B475MTEL('I')"	,0,3},;
	{"Alterar"   			,"U_B475MTEL('A')"	,0,4},;
	{"Excluir"   			,"U_B475MTEL('E')"	,0,5},;
	{"Grafico"   			,"U_B475GRAF"		,0,4},;
	{"Cad.Defeitos"			,"U_B475CDEF"		,0,3}}
	DbSelectArea("ZZS")
	DbSetOrder(1)


	mBrowse(6,1,22,75,"ZZS",,,,,,/*acores*/)

return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ B475MTEL                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Funcao para Montar a tela MODELO 2                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function B475MTEL(wOpcao)

	Local aAreaZZS := ZZS->(GetArea())
	Local i
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Declaracao de variaveis utilizadas no programa atraves da funcao    ≥
	//≥ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ≥
	//≥ identificando as variaveis publicas do sistema utilizadas no codigo ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	SetPrvt("WOPCAO,LVISUALIZAR,LINCLUIR,LALTERAR,LEXCLUIR,NOPCE")
	SetPrvt("NOPCG,COPCAO,NUSADO,AHEADER")
	SetPrvt("ACOLS,I,ACGD,CLINHAOK,CTUDOOK,LRET,nOPC")

	Private VPDATA, VPPRODUT, VPSEQLIN, VPLINCOR, VPFORMAT, VPDESC  //VARIAVEIS PRIVATE PARA CABECALHO
	Private cCHAVE

	Do Case
		Case wOpcao == "V" ; lVisualizar := .T. ; nOPC := 1 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "I" ; lIncluir    := .T. ; nOPC := 3 ; cOpcao := "INCLUIR"
		Case wOpcao == "A" ; lAlterar    := .T. ; nOPC := 4 ; cOpcao := "ALTERAR"
		Case wOpcao == "E" ; lExcluir    := .T. ; nOPC := 5 ; cOpcao := "EXCLUIR"
	EndCase

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Monta aHeader                                                            ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("ZZS"))
	nUsado  := 0
	aHeader := {}
	aCols   := {}
	While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "ZZS"
		If  AllTrim(SX3->X3_CAMPO) $ "ZZS_LINHA/ZZS_TURNO/ZZS_EQUIPE/ZZS_CODDEF/ZZS_DESDEF/ZZS_QUANT"

			nUsado := nUsado + 1
			aadd(aHeader,{ trim(SX3->X3_TITULO),SX3->X3_CAMPO   , ;
			SX3->X3_PICTURE     ,SX3->X3_TAMANHO , ;
			SX3->X3_DECIMAL     ,"AllwaysTrue()" , ;
			SX3->X3_USADO       ,SX3->X3_TIPO    , ;
			SX3->X3_ARQUIVO     ,SX3->X3_CONTEXT } )

		EndIf
		SX3->(DbSkip())
	Enddo

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Cria variaveis M->????? da Enchoice                          ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	RegToMemory("ZZS",(cOpcao=="INCLUIR"))
	cTitulo   := "CONTROLE DE DEFEITOS"

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Monta aCols                                                              ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	ZZS->(DbSetOrder(1))
	If  lIncluir
		VPDATA := CTOD(" ")
		VPPRODUT := SPACE(TamSx3("B1_COD")[1])
		//VPLINCOR := SPACE(TamSx3("ZZ7_COD")[1])
		//VPSEQLIN := SPACE(2)
		//VPFORMAT := SPACE(TamSx3("ZZ6_COD")[1])
		VPDESC	 := SPACE(TamSx3("B1_DESC")[1])

		aCols             := {array(nUsado+1)}
		aCols[1,nUsado+1] := .F.
		For i := 1 to nUsado
			aCols[1,i] := CriaVar(aHeader[i,2])
		Next
	Else
		VPDATA 		:= ZZS->ZZS_DATA
		VPPRODUT 	:= ZZS->ZZS_PRODUT
		//VPLINCOR	:= SUBSTR(ZZS->ZZS_PRODUT,1,4)
		//VPSEQLIN    := SUBSTR(ZZS->ZZS_PRODUT,5,2)
		//VPFORMAT	:= SUBSTR(ZZS->ZZS_PRODUT,7,2)
		VPDESC		:= ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+VPPRODUT,"B1_DESC"))

		aCols:={}
		cCHAVE := (xFilial("ZZS")+DTOS(M->ZZS_DATA)+M->ZZS_LINHA+M->ZZS_TURNO+M->ZZS_EQUIPE+M->ZZS_PRODUT)
		IF ZZS->(DbSeek(cCHAVE))
			While !ZZS->(Eof()) .AND. ZZS->(ZZS_FILIAL+DTOS(ZZS_DATA)+ZZS_LINHA+ZZS_TURNO+ZZS_EQUIPE+ZZS_PRODUT) == (cCHAVE)

				aadd(aCols,array(nUsado+1))
				For i := 1 to nUsado
					IF AllTrim(aHeader[i,2]) == "ZZS_DESDEF"
						aCols[len(aCols),i]    := POSICIONE("SX5",1,XFILIAL("SX5")+"ZE"+ZZS->ZZS_CODDEF,"X5_DESCRI")
					ELSE
						aCols[len(aCols),i]    := ZZS->(FieldGet(FieldPos(aHeader[i,2])))
					ENDIF
				Next
				aCols[len(aCols),nUsado+1] := .F.

				ZZS->(DbSkip())
			Enddo
		ELSE
			Return
		ENDIF
	EndIf

	n := 1
	aC:={}
	AADD(aC,{ "VPDATA" 		,{018,003} , "Data		" , "" ,,,nOPC==3})
	AADD(aC,{ "VPPRODUT" 	,{018,080} , "Produto	" , "@!" ,"U_B475DPR()","SB1DEF",nOPC==3})
	//AADD(aC,{ "VPLINCOR" 	,{018,080} , "Linha/Cor	" , "@!" ,"U_B475DPR()","ZZ7",nOPC==3})
	//AADD(aC,{ "VPSEQLIN" 	,{018,140} , "Seq.	" 	  , "@!" ,,,.F.})
	//AADD(aC,{ "VPFORMAT" 	,{018,180} , "Formato	" , "@!" ,"U_B475DPR()","ZZ6",nOPC==3})
	AADD(aC,{ "VPDESC"	 	,{018,200} , "Descricao	" , "@S30" ,,,.F.})

	aR:={}
	aCGD:={070,5,138,315}

	cLinhaOk := ".T."
	cTudoOk := "U_B475VTEL()"

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Chamada da Modelo2                                           ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	lRet := Modelo2(cTitulo,aC,aR,aCGD,nOPC,cLinhaOk,cTudoOk)
	If  lRet
		fProcessa()
	End

	RestArea(aAreaZZS)
Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//VALIDAR CAMPO PRODUTO - BUSCAR DESCRICAO
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
User Function B475DPR

	VPDESC := POSICIONE("SB1",1,XFILIAL("SB1")+VPPRODUT,"B1_DESC")

Return(.T.)

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//VALIDAR TELA
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
User Function B475VTEL
	Local I

	IF lVisualizar
		Return(.T.)
	ENDIF

	IF lExcluir
		If MsgYesNo("TEM CERTEZA QUE DESEJA EXCLUIR TODOS OS LAN«AMENTOS SELECIONADOS?","CONTROLE DE DEFEITOS")
			Return(.T.)
		Else
			Return(.F.)
		EndIf
	ENDIF

	IF Empty(VPDATA) .OR. Empty(VPPRODUT)
		MsgAlert("DADOS INV¡LIDOS NO CABE«ALHO","CONTROLE DE DEFEITOS")
		Return(.F.)
	ENDIF

	IF LEN(ACOLS) <= 0
		MsgAlert("DEVE INCLUIR PELO MENOS UMA LINHA","CONTROLE DE DEFEITOS")
		Return(.F.)
	ELSE
		FOR I := 1 To Len(ACOLS)
			IF !GdDeleted(I)
				If Empty(ACOLS[I][4]) .Or. Empty(ACOLS[I][6])
					MsgAlert("CONTE⁄DO INV¡LIDO NAS LINHAS","CONTROLE DE DEFEITOS")
					Return(.F.)
				EndIf
			ENDIF
		NEXT I
	ENDIF

Return(.T.)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funá∆o    ≥ fProcessa                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriá∆o ≥ Processa confirmacao da tela                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function fProcessa()
	Local I

	Do Case
		//INCLUIR
		Case lIncluir
		For I := 1 to len(aCols)
			If  !aCols[I,nUsado+1]
				If RecLock("ZZS",.T.)
					ZZS->ZZS_FILIAL	:= xFilial("ZZS")
					ZZS->ZZS_CODIGO	:= GetSxeNum("ZZS","ZZS_CODIGO")
					ZZS->ZZS_PRODUT	:= VPPRODUT
					ZZS->ZZS_DATA	:= VPDATA
					ZZS->ZZS_LINHA	:= aCols[I][1]
					ZZS->ZZS_TURNO	:= aCols[I][2]
					ZZS->ZZS_EQUIPE	:= aCols[I][3]
					ZZS->ZZS_CODDEF	:= aCols[I][4]
					ZZS->ZZS_QUANT	:= aCols[I][6]
					ZZS->(MsUnlock())
					ZZS->(ConfirmSX8())
				EndIf
			EndIf
		Next I
		//ALTERAR
		Case lAlterar
		//ALTERAR - DELETA TODOS OS REGISTROS DO INDICE E CRIA NOVAMENTE
		ZZS->(DbSetOrder(1))
		IF ZZS->(DbSeek(cCHAVE))
			While .Not. ZZS->(Eof()) .And. ZZS->(ZZS_FILIAL+DTOS(ZZS_DATA)+ZZS_LINHA+ZZS_TURNO+ZZS_EQUIPE+ZZS_PRODUT) == (cCHAVE)
				RecLock("ZZS",.F.)
				ZZS->(DbDelete())
				ZZS->(MsUnlock())
				ZZS->(DbSkip())
			EndDo
		ENDIF

		For I := 1 to len(aCols)
			If  !aCols[I,nUsado+1]
				If RecLock("ZZS",.T.)
					ZZS->ZZS_FILIAL	:= xFilial("ZZS")
					ZZS->ZZS_CODIGO	:= GetSxeNum("ZZS","ZZS_CODIGO")
					ZZS->ZZS_PRODUT	:= VPPRODUT	//LINHA + SEQUENCIA + FORMATO
					ZZS->ZZS_DATA	:= VPDATA
					ZZS->ZZS_LINHA	:= aCols[I][1]
					ZZS->ZZS_TURNO	:= aCols[I][2]
					ZZS->ZZS_EQUIPE	:= aCols[I][3]
					ZZS->ZZS_CODDEF	:= aCols[I][4]
					ZZS->ZZS_QUANT	:= aCols[I][6]
					ZZS->(MsUnlock())
					ZZS->(ConfirmSX8())
				EndIf
			EndIf
		Next I
		//EXCLUIR
		Case lExcluir
		ZZS->(DbSetOrder(1))
		IF ZZS->(DbSeek(cCHAVE))
			While .Not. ZZS->(Eof()) .And. ZZS->(ZZS_FILIAL+DTOS(ZZS_DATA)+ZZS_LINHA+ZZS_TURNO+ZZS_EQUIPE+ZZS_PRODUT) == (cCHAVE)
				RecLock("ZZS",.F.)
				ZZS->(DbDelete())
				ZZS->(MsUnlock())
				ZZS->(DbSkip())
			EndDo
		ENDIF

	EndCase
	dbCommitAll()
Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funá∆o    ≥ B475GRAF		                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriá∆o ≥ Botao - Gerar o grafico de defeitos em Crystal             ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function B475GRAF()
	Local aArea     := GetArea()
	Local oBCancela
	Local oBConfirma
	Local oBGerExcel
	Local oCBInd
	Local oCBVal
	Local oFont1 := TFont():New("Courier New",,022,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("Courier New",,018,,.T.,,,,,.F.,.F.)
	Local oFont3 := TFont():New("Courier New",,016,,.F.,,,,,.F.,.F.)
	Local oGetPerFim
	Local dGetPerFim := dDataBase
	Local oGetPerIni
	Local dGetPerIni := STOD(STRZERO(Year(dDataBase),4)+STRZERO(Month(dDataBase),2)+"01")
	Local cGetProd := Space(200)
	Local oGetMaxIt
	Local nMaxIt   := 20
	Local oGroup1
	Local oGroup2
	Local oGroup3
	Local oGroup4
	Local oGroup5
	Local oRadEquipe
	Local nRadEquipe := 1
	Local oRadLinha
	Local nRadLinha := 1
	Local oRadTurno
	Local nRadTurno := 1
	Local oSay1
	Local oSay2
	Local oSay5
	Local oSay6
	Local lRet := .F.
	Local xl1Ret := .F.
	Local aIndItens  	:= {"TIPO DO DEFEITO","FORMATO","PRODUTO","LINHA","TURNO","EQUIPE"}
	Local aValItens		:= {"PERCENTAGEM","QUANTIDADE"}
	Local cCBInd		:= aIndItens[1]
	Local cCBVal 		:= aValItens[1]
	Local aLinha 		:= {"T","1","2","3","4"}
	Local aDLinha 		:= {"Todas","01","02","03","04"}
	Local aTurno 		:= {"T","1","2"}
	Local aDTurno 		:= {"Todos","DIA","NOITE"}
	Local aEquipe 		:= {"T","1","2","3","4"}
	Local aDEquipe 		:= {"Todas","01","02","03","04"}
	Local cSQL
	Local kf
	Static oDlgGDef

	DEFINE MSDIALOG oDlgGDef TITLE "" FROM 000, 000  TO 360, 400 COLORS 0, 16777215 PIXEL

	@ 000, 000 SAY oSay1 PROMPT "GR¡FICO DE DEFEITOS" SIZE 200, 013 OF oDlgGDef FONT oFont1 COLORS 16777215, 0 PIXEL
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.

	@ 013, 000 GROUP oGroup1 TO 051, 200 PROMPT "Tipo do Gr·fico" OF oDlgGDef COLOR 0, 16777215 PIXEL
	@ 051, 000 GROUP oGroup2 TO 164, 200 PROMPT "FILTROS" OF oDlgGDef COLOR 0, 16777215 PIXEL

	@ 022, 005 SAY oSay3 PROMPT "INDICADOR:" SIZE 044, 011 OF oDlgGDef FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 022, 055 MSCOMBOBOX oCBInd VAR cCBInd ITEMS aIndItens SIZE 098, 010 OF oDlgGDef COLORS 0, 16777215 PIXEL
	@ 037, 005 SAY oSay4 PROMPT "VALOR:" SIZE 044, 011 OF oDlgGDef FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 036, 055 MSCOMBOBOX oCBVal VAR cCBVal ITEMS aValItens SIZE 098, 010 OF oDlgGDef COLORS 0, 16777215 PIXEL
	@ 022, 155 SAY oSay3 PROMPT "MAXIMO:" SIZE 044, 011 OF oDlgGDef FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 022, 183 MSGET oGetMaxIt VAR nMaxIt SIZE 015, 010 OF oDlgGDef COLORS 0, 16777215 PIXEL

	@ 062, 005 SAY oSay2 PROMPT "PERIODO DE:" SIZE 048, 011 OF oDlgGDef FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 061, 055 MSGET oGetPerIni VAR dGetPerIni SIZE 040, 010 OF oDlgGDef COLORS 0, 16777215 PIXEL
	@ 062, 099 SAY oSay6 PROMPT "AT…:" SIZE 017, 011 OF oDlgGDef FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 062, 118 MSGET oGetPerFim VAR dGetPerFim SIZE 040, 010 OF oDlgGDef COLORS 0, 16777215 PIXEL
	@ 077, 005 SAY oSay4 PROMPT "PRODUTOS:" SIZE 053, 011 OF oDlgGDef FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 076, 055 MSGET oGetProd VAR cGetProd SIZE 136, 010 OF oDlgGDef COLORS 0, 16777215 F3 "SB1DEF" PIXEL
	@ 087, 055 SAY oSay5 PROMPT "CÛdigos Separados por barra '/'" SIZE 110, 007 OF oDlgGDef FONT oFont3 COLORS 0, 16777215 PIXEL

	@ 102, 098 GROUP oGroup5 TO 154, 145 PROMPT "EQUIPE" OF oDlgGDef COLOR 0, 16777215 PIXEL
	@ 101, 050 GROUP oGroup4 TO 154, 095 PROMPT "TURNO" OF oDlgGDef COLOR 0, 16777215 PIXEL
	@ 101, 009 GROUP oGroup3 TO 154, 046 PROMPT "LINHA" OF oDlgGDef COLOR 0, 16777215 PIXEL
	@ 109, 012 RADIO oRadLinha VAR nRadLinha ITEMS "Todas","01","02","03","04" SIZE 024, 042 OF oDlgGDef COLOR 0, 16777215 PIXEL
	@ 109, 103 RADIO oRadEquipe VAR nRadEquipe ITEMS "Todas","01","02","03","04" SIZE 029, 042 OF oDlgGDef COLOR 0, 16777215 PIXEL
	@ 109, 054 RADIO oRadTurno VAR nRadTurno ITEMS "Todos","DIA","NOITE" SIZE 033, 042 OF oDlgGDef COLOR 0, 16777215 PIXEL

	@ 165, 078 BUTTON oBGerExcel PROMPT "Excel"     SIZE 037, 012 OF oDlgGDef PIXEL ACTION(lRet:=.T., xl1Ret := .T., oDlgGDef:End())
	@ 165, 119 BUTTON oBConfirma PROMPT "CONFIRMAR" SIZE 037, 012 OF oDlgGDef PIXEL ACTION(lRet:=.T., oDlgGDef:End())
	@ 165, 160 BUTTON oBCancela  PROMPT "CANCELAR"  SIZE 037, 012 OF oDlgGDef PIXEL ACTION(lRet:=.F., oDlgGDef:End())

	// Don't change the Align Order
	oSay1:Align := CONTROL_ALIGN_TOP
	oGroup1:Align := CONTROL_ALIGN_TOP
	oGroup2:Align := CONTROL_ALIGN_TOP

	ACTIVATE MSDIALOG oDlgGDef CENTERED


	//EXECUTAR RELATORIO EM CRYSTAL
	IF lRet
		//ALTERAR VIEW PELOS PARAMETROS
		cSQL :=" ALTER VIEW PARETO_CONTROLE_DEFEITOS AS "+CRLF
		cSQL +=" SELECT TOP "+AllTrim(Str(nMaxIt))+" "+CRLF

		//INDICADOR
		IF cCBInd == aIndItens[1]
			cSQL +=" (SELECT X5_DESCRI FROM SX5010 WHERE X5_TABELA = 'ZE' AND X5_CHAVE = A.ZZS_CODDEF) IND "+CRLF
		ELSEIF cCBInd == aIndItens[2]
			//cSQL +=" SUBSTRING(A.ZZS_PRODUT,7,2) IND "+CRLF
			cSQL +=" (SELECT ZZ6_DESC FROM ZZ6010 ZZ6 WHERE ZZ6_COD = SUBSTRING(A.ZZS_PRODUT,1,2) AND ZZ6.D_E_L_E_T_=' ') IND "+CRLF
		ELSEIF cCBInd == aIndItens[3]
			//cSQL +=" SUBSTRING(A.ZZS_PRODUT,1,6) IND "+CRLF
			cSQL +=" ZZS_PRODUT IND "+CRLF
			//cSQL +=" (SELECT ZZ7_DESC FROM ZZ7010 ZZ7 WHERE ZZ7_COD+ZZ7_LINSEQ = SUBSTRING(A.ZZS_PRODUT,1,6) AND ZZ7.D_E_L_E_T_=' ') IND "+CRLF
		ELSEIF cCBInd == aIndItens[4]
			cSQL +=" 'LINHA '+A.ZZS_LINHA IND "+CRLF
		ELSEIF cCBInd == aIndItens[5]
			cSQL +=" CASE WHEN A.ZZS_TURNO = '1' THEN 'DIA' ELSE 'NOITE' END AS IND "+CRLF
		ELSEIF cCBInd == aIndItens[6]
			cSQL +=" 'EQUIPE '+A.ZZS_EQUIPE IND "+CRLF
		ENDIF

		IF cCBVal == aValItens[1]
			cSQL +=" ,CAST(((
			cSQL +=" (SELECT SUM(B.ZZS_QUANT)
			cSQL +=" FROM "+RetSqlName("ZZS")+" B
			cSQL +=" WHERE B.ZZS_FILIAL = '"+XFILIAL("ZZS")+"'

			IF cCBInd == aIndItens[1]
				cSQL +=" AND B.ZZS_CODDEF = A.ZZS_CODDEF "+CRLF
			ELSEIF cCBInd == aIndItens[2]
				cSQL +=" AND SUBSTRING(B.ZZS_PRODUT,1,2) = SUBSTRING(A.ZZS_PRODUT,1,2) "+CRLF
			ELSEIF cCBInd == aIndItens[3]
				cSQL +=" AND B.ZZS_PRODUT = A.ZZS_PRODUT "+CRLF
			ELSEIF cCBInd == aIndItens[4]
				cSQL +=" AND B.ZZS_LINHA = A.ZZS_LINHA "+CRLF
			ELSEIF cCBInd == aIndItens[5]
				cSQL +=" AND B.ZZS_TURNO = A.ZZS_TURNO "+CRLF
			ELSEIF cCBInd == aIndItens[6]
				cSQL +=" AND B.ZZS_EQUIPE = A.ZZS_EQUIPE "+CRLF
			ENDIF

			//FILTROS
			cSQL +=" AND B.ZZS_DATA BETWEEN '"+DTOS(dGetPerIni)+"' AND '"+DTOS(dGetPerFim)+"' "+CRLF
			IF !Empty(cGetProd)
				cSQL +=" AND B.ZZS_PRODUT IN ("+U_MontaSQLIN(cGetProd,"/",TamSX3("ZZS_PRODUT")[1])  +") "+CRLF
			ENDIF
			IF aLinha[nRadLinha] <> "T"
				cSQL +=" AND B.ZZS_LINHA = '"+aLinha[nRadLinha]+"' "+CRLF
			ENDIF
			IF aTurno[nRadTurno] <> "T"
				cSQL +=" AND B.ZZS_TURNO = '"+aTurno[nRadTurno]+"' "+CRLF
			ENDIF
			IF aEquipe[nRadEquipe] <> "T"
				cSQL +=" AND B.ZZS_EQUIPE = '"+aEquipe[nRadEquipe]+"' "+CRLF
			ENDIF

			cSQL +=" AND B.D_E_L_E_T_='') "+CRLF
			cSQL +=" 	/(SELECT SUM(B.ZZS_QUANT) "+CRLF
			cSQL +=" FROM "+RetSqlName("ZZS")+" B "+CRLF
			cSQL +=" WHERE B.ZZS_FILIAL = '01' "+CRLF

			//FILTROS
			cSQL +=" AND B.ZZS_DATA BETWEEN '"+DTOS(dGetPerIni)+"' AND '"+DTOS(dGetPerFim)+"' "+CRLF
			IF !Empty(cGetProd)
				cSQL +=" AND B.ZZS_PRODUT IN ("+U_MontaSQLIN(cGetProd,"/",TamSX3("ZZS_PRODUT")[1])  +") "+CRLF
			ENDIF
			IF aLinha[nRadLinha] <> "T"
				cSQL +=" AND B.ZZS_LINHA = '"+aLinha[nRadLinha]+"'  "+CRLF
			ENDIF
			IF aTurno[nRadTurno] <> "T"
				cSQL +=" AND B.ZZS_TURNO = '"+aTurno[nRadTurno]+"'  "+CRLF
			ENDIF
			IF aEquipe[nRadEquipe] <> "T"
				cSQL +=" AND B.ZZS_EQUIPE = '"+aEquipe[nRadEquipe]+"'  "+CRLF
			ENDIF

			cSQL +=" AND B.D_E_L_E_T_='') "+CRLF
			cSQL +=" )*100) AS NUMERIC(6,3)) AS PERC "+CRLF
		ELSE
			cSQL +=", SUM(A.ZZS_QUANT) AS PERC "+CRLF
		ENDIF


		cSQL +=" FROM "+RetSqlName("ZZS")+" A "+CRLF
		cSQL +=" WHERE "+CRLF
		cSQL +=" 	A.ZZS_FILIAL = '"+XFILIAL("ZZS")+"' "+CRLF

		//FILTROS
		cSQL +=" AND A.ZZS_DATA BETWEEN '"+DTOS(dGetPerIni)+"' AND '"+DTOS(dGetPerFim)+"' "+CRLF
		IF !Empty(cGetProd)
			cSQL +=" AND A.ZZS_PRODUT IN ("+U_MontaSQLIN(cGetProd,"/",TamSX3("ZZS_PRODUT")[1])  +") "+CRLF
		ENDIF
		IF aLinha[nRadLinha] <> "T"
			cSQL +=" AND A.ZZS_LINHA = '"+aLinha[nRadLinha]+"'  "+CRLF
		ENDIF
		IF aTurno[nRadTurno] <> "T"
			cSQL +=" AND A.ZZS_TURNO = '"+aTurno[nRadTurno]+"'  "+CRLF
		ENDIF
		IF aEquipe[nRadEquipe] <> "T"
			cSQL +=" AND A.ZZS_EQUIPE = '"+aEquipe[nRadEquipe]+"'  "+CRLF
		ENDIF

		cSQL +=" 	AND A.D_E_L_E_T_='' "+CRLF
		cSQL +=" GROUP BY "

		//INDICADOR
		IF cCBInd == aIndItens[1]
			cSQL +=" A.ZZS_CODDEF "+CRLF
		ELSEIF cCBInd == aIndItens[2]
			cSQL +=" SUBSTRING(A.ZZS_PRODUT,1,2) "+CRLF
		ELSEIF cCBInd == aIndItens[3]
			cSQL +=" A.ZZS_PRODUT "+CRLF
		ELSEIF cCBInd == aIndItens[4]
			cSQL +=" A.ZZS_LINHA "+CRLF
		ELSEIF cCBInd == aIndItens[5]
			cSQL +=" A.ZZS_TURNO "+CRLF
		ELSEIF cCBInd == aIndItens[6]
			cSQL +=" A.ZZS_EQUIPE "+CRLF
		ENDIF

		cSQL +="  ORDER BY PERC DESC  "+CRLF

		TCSQLExec(cSQL)

		If xl1Ret                                                                                 // Gera Excel
			*****************************************************************************************************
			xfVet := {}
			QX001 := " SELECT * FROM PARETO_CONTROLE_DEFEITOS "
			TcQuery QX001 ALIAS "QX01" NEW
			dbSelectArea("QX01")
			dbGoTop()
			aStru1 := ("QX01")->(dbStruct())
			While !Eof()

				Aadd(xfVet, Array( Len(aStru1) ) )
				For kf := 1 To Len(aStru1)
					If aStru1[kf,2] == "C"
						xfVet[Len(xfVet)][kf] := &("QX01->"+aStru1[kf,1])
					Else
						xfVet[Len(xfVet)][kf] := Transform(&("QX01->"+aStru1[kf,1]), "@E 999999999999.9999999")
					EndIf
				Next kf

				dbSelectArea("QX01")
				dbSkip()
			End
			QX01->(dbCloseArea())
			U_BIAxExcel(xfVet, aStru1, "BIA475"+strzero(seconds()%3500,5) )

		Else                                                                      //Parametros Crystal Em Disco
			*****************************************************************************************************
			cOpcao:="1;0;1;Apuracao"
			IF cCBVal == aValItens[1]
				_cRel := "REL_PARETO_CONTROLE_DEFEITOS"
			ELSE
				_cRel := "REL_PARETO_CONTROLE_DEFEITOS_NUM"
			ENDIF
			callcrys(_cRel, cEmpant+";"+DTOC(dGetPerIni)+";"+DTOC(dGetPerFim)+";"+cCBInd+";"+aDLinha[nRadLinha]+";"+aDTurno[nRadTurno]+;
			";"+aDEquipe[nRadEquipe]+";"+IIF(!Empty(cGetProd),AllTrim(cGetProd),"TODOS"),cOpcao)
		EndIf

	ENDIF

	RestArea(aArea)

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funá∆o    ≥ B475CDEF		                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriá∆o ≥ Cadastro de defeitos								          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function B475CDEF

	Local cAlias := "SX5"
	Local cTabela := "ZE"
	Private cCadastro := "Tabela de Codigos de Defeitos"

	PRIVATE aRotina := { { "Pesquisar"	,  "AxPesqui"  , 0 , 1},;  // "Pesquisar"
	{ "Visualizar" 	,  "C160Visual", 0 , 2},;  // "Visualizar"
	{ "Incluir"		,  "C160Inclui", 0 , 3},;  // "Incluir"
	{ "Alterar"		,  "C160Altera", 0 , 4},;  // "Alterar"
	{ "Excluir"		,  "C160Deleta", 0 , 5} }  // "Excluir"

	SX5->(DbSetOrder(1))
	SX5->(DbSeek(XFilial("SX5")+cTabela))

	C160Altera(cAlias,SX5->(RecNo()),3)

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//MONTAR CONDICAO PARA SQL COM IN
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
//FunÁ„o j· existente na USERLIBRARY.PRW
/*Static Function MontaSQLIN(cString,cChar,nTam)

Local I

aLista := STRTOKARR(Alltrim(cString),cChar)
cLista := ""
For I := 1 To Len(aLista)
if cLista <> ""
cLista +=","
endif
cLista += "'"+PADR(aLista[I],nTam)+"'"
Next I

return(cLista)*/

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//MONTAR DESCRICAO PARA BROWSE DO CADASTRO
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
User Function B475DDEF()

	Local cRet := POSICIONE("SB1",1,XFILIAL("SB1")+ZZS->ZZS_PRODUT,"B1_DESC")

Return cRet
