#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'DBTREE.CH'
#INCLUDE 'APWIZARD.CH'

/*/{Protheus.doc} BIAFA004
@author Artur Antunes
@since 11/05/2017
@version 1.0
@description Rotina customizada de Pre-estruturas (MATA202)
@type function
/*/

#define STR0001 "Pre-Estruturas" 
#define STR0002 "Pesquisar"
#define STR0003 "Visualizar"
#define STR0004 "Incluir"
#define STR0005 "Alterar"
#define STR0006 "Excluir"
#define STR0007 "Selecionando Registros..." 
#define STR0008 "Componente"
#define STR0009 "Alteraçäo" 
#define STR0010 "Inclusäo" 
#define STR0011 "Exclusäo" 
#define STR0012 "Visualizaçäo" 
#define STR0013 "Código:"
#define STR0014 "Unidade:"
#define STR0015 "Pre-Estrutura Similar:" 
#define STR0016 "Pesquisar..."
#define STR0017 "Descricao" 
#define STR0018 "Comparar"
#define STR0019 "Comparador de Pre-Estruturas"
#define STR0020 "Dados Originais"
#define STR0021 "Dados para Comparacao" 
#define STR0022 "Produto"
#define STR0023 "Data Referencia" 
#define STR0024 "Opcionais"
#define STR0025 "Desce" 
#define STR0026 "Sobe"
#define STR0027 "COMPONENTE FORA DAS DATAS INICIO / FIM" 
#define STR0028 "COMPONENTE FORA DOS GRUPOS DE OPCIONAIS"
#define STR0029 "COMPONENTE OK" 
#define STR0030 "COMPONENTE NAO EXISTENTE" 
#define STR0031 "Legenda"
#define STR0032 "Substituicao de Componentes" 
#define STR0033 "Componente Original"
#define STR0034 "Novo Componente"
#define STR0035 "Substituir"
#define STR0036 "Atencao" 
#define STR0037 "Para utilizacao dessa opcao deve ser criado o campo GG_OK semelhante ao campo C9_OK." 
#define STR0038 "Aprovar Pre-Estrutura" 
#define STR0039 "Rejeitar Pre-Estrutura"
#define STR0040 "Aprovar/Rejeitar" 
#define STR0041 "Criar Estrutura"
#define STR0042 "Estrutura nao esta em criacao. Nao pode ser manipulada." 
#define STR0043 "Usuario  nao pode aprovar / rejeitar pre-estrutura." 
#define STR0044 "Usuario nao pode criar estrutura." 
#define STR0045 "Aprovacao" 
#define STR0046 "Os niveis da Pre-estrutura que serao aprovados:"
#define STR0047 "Todos"
#define STR0048 "1o. Nivel"
#define STR0049 "Nenhum"
#define STR0050 "Rejeicao"
#define STR0051 "Os niveis da Pre-estrutura que serao rejeitados:" 
#define STR0052 "Em criacao" 
#define STR0053 "Pre Estrutura Aprovada" 
#define STR0054 "Pre Estrutura Rejeitada"
#define STR0055 "Estrutura criada"
#define STR0056 "Criacao de Estrutura" 
#define STR0057 "Este assistente permite o preenchimento das informacoes para criacao de estruturas com base nas pre-estruturas." 
#define STR0058 "Parametros para leitura" 
#define STR0059 "Informe parametros relacionados a leitura dos dados:" 
#define STR0060 "Parametros para gravacao" 
#define STR0061 "Informe parametros relacionados a gravacao dos dados:" 
#define STR0062 "Considera niveis" 
#define STR0063 "Considera status" 
#define STR0064 "Aprovados"
#define STR0065 "Rejeitados"
#define STR0066 "Todos"
#define STR0067 "Considera componentes"
#define STR0068 "Qualquer data"
#define STR0069 "Data valida" 
#define STR0070 "Data de/ate" 
#define STR0071 "Data de" 
#define STR0072 "Data Ate" 
#define STR0073 "Estruturas ja existentes" 
#define STR0074 "Sobrescreve"
#define STR0075 "Mantem" 
#define STR0076 "Pre-Estrutura gravada" 
#define STR0077 "Apaga"
#define STR0078 "Mantem" 
#define STR0079 "Altera codigo do produto pai" 
#define STR0080 "Ja existe estrutura para este produto" 
#define STR0081 "Estrutura Similar:"
#define STR0082 "Atualizar SIGACUSB.PRX !!!" 
#define STR0083 "Submetida à aprovação"
#define STR0084 "A pré-estrutura foi submetida à aprovação e portando não poderá ser alterada."
#define STR0085 "A estrutura não poderá ser criada pois a pré-estrutura ainda não foi aprovada."
#define STR0087 "Essa pré-estrutura já foi encaminhada para aprovação."
#define STR0088 "Enc. Aprovação"
#define STR0089 "Não existe log de aprovação para este componente."
#define STR0090 "Usuário" 
#define STR0091 "Nível"
#define STR0092 "Engenharia"
#define STR0093 "Somente o 1º nível"
#define STR0094 "Todos os níveis"
#define STR0095 "Pre-estrutura já foi encaminhada e aprovada pelo grupo de aprovação" 
#define STR0096 "Enc. Aprovação"
#define STR0097 "Log. Aprovação"
#define STR0098 "Aprovador"
#define STR0100 "Tp. Aprovação"
#define STR0101 "Status" 
#define STR0102 "Dt. Liberação"
#define STR0103 "Observação"
#define STR0104 "Log. de Aprovação: Cód. "
#define STR0105 "Acesso Restrito"
#define STR0106 "A realização desta ação é restrita aos usuários de um grupo de engenharia específico." 
#define STR0107 "Aguardando outros níveis" 
#define STR0108 "Aguardando liberação"
#define STR0109 "Liberado"
#define STR0110 "Rejeitado"
#define STR0111 "Aprovado por outro usuário" 
#define STR0112 "Rejeitado por outro usuário" 
#define STR0113 "Bloqueado"
#define STR0114 "Bloqueado por outro usuário" 
#define STR0115 "O acesso e a utilização desta rotina é destinada apenas aos usuários cadastrados como engenheiros." 
#define STR0116 "A realização desta ação é restrita aos usuários de um grupo de engenharia específico." 
#define STR0117 "Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR)."
#define STR0118 "QTDE:"
#define STR0119 "Data Ref:"

User Function BIAFA004()

	Local aAreaAnt  := GetArea()
	Local lArqRev   := .F.
	Local cFiltra   := ""
	Local lContinua := .T.
	Local aCorUsr   := {}
	Local nCnt      := 0
	Local aCores 	:= {{"GG_STATUS=='1'",'BR_AMARELO'},;
	{ "GG_STATUS=='2'",'BR_VERDE'},;
	{ "GG_STATUS=='3'",'BR_VERMELHO'},;
	{ "GG_STATUS=='4'",'BR_AZUL'},;
	{ "GG_STATUS=='5'",'BR_LARANJA'}}
	Private oTree
	Private cCadastro  	:= OemToAnsi(STR0001)
	Private cCodAtual  	:= Replicate('ú', Len(SGG->GG_COD))
	Private cValComp  	:= Replicate('ú', Len(SGG->GG_COD)) + 'ú'
	Private ldbTree    	:= .F.
	Private cInd5      	:= ''
	Private nNAlias    	:= 0
	Private lRestEst   	:= SuperGetMv("MV_APRESTR",.F.,.F.)
	Private aRotina 	:= MenuDef(lRestEst)
	private _dDataRef 	:= stod('')
	private _cModExib 	:= "1"

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YLIBSGG")
		CriarSX6("MV_YLIBSGG", 'L', 'Indica se a alteração das estruturas do SGG estão liberadas', ".F." )
	EndIf

	If ExistBlock("MT202LEG")
		aCorUsr := ExecBlock("MT202LEG",.F.,.F., { 1 })
		If ValType(aCorUsr) <> "A"
			aCorUsr := {}
		EndIf
		For nCnt := 1 To Len(aCorUsr)
			Aadd( aCores , { aCorUsr[nCnt,1],aCorUsr[nCnt,2] } )
		Next nCnt
	EndIf

	dbSelectArea("SGG")
	dbSetOrder(1)

	If lContinua

		Pergunte('MTA202', .F.)
		SetKey( VK_F12, { || Pergunte('MTA202', .T.) } )

		mBrowse( 6, 1,22,75,'SGG',,,,,,aCores)
		Set Key VK_F12 To

		//³ Recalcula os Niveis                                          ³
		If GetMv('MV_NIVALTP') == 'S'
			MA320Nivel(NIL,NIL,NIL,NIL,.T.)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return Nil


// Programa de Processamento da Pre-Estrutura   
User Function BIAFA4PR(cAlias,nRecno,nOpcX)

	Local oDlg
	Local oUm
	local oDtRef
	Local oQtdBase
	Local oButPosic
	Local cTitulo	 := STR0001 + ' - '
	Local cProduto   := CriaVar('GG_COD')
	Local cCodSim    := CriaVar('GG_COD')
	Local cUm        := CriaVar('B1_UM')
	Local nQtdBase   := CriaVar('B1_QB')
	Local lRet       := .T.
	Local lConfirma  := .F.
	Local lAbandona  := .F.
	Local lChkRej	 := .F.
	Local lChkApr	 := .T.
	Local aAreaAnt   := GetArea()
	Local aUndo      := {}
	Local lMudou     := .F.
	Local aAltEstru  := {}
	Local aObjects	 := {}
	Local aPosObj 	 := {}
	Local aInfo	 	 := {}
	Local aSize	 	 := {}
	Local aVldEng    := {3,4,5,8,10}

	Local oPanel1
	Local oPanel2
	Local oPanel3
	Local oPanelLeft
	Local oPanelRight
	Local oPanelB1
	Local oPanelB2
	Local oPanelB3
	Local oPanelB4
	Local oPanelB5
	Local oPanelB6
	Local oPanelB7
	Local oChkRejei
	Local oChkAprov
	Local oButton2
	Local oButton3
	Local oButton4
	Local oButton6
	Local oButton7
	Local oGroup
	Local nValPre  	:= 1 // APROVAR -> 1 REJEITAR -> 2
	Local cUsuario 	:= RetCodUsr()
	Local lPyme		:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)
	local dDtBk 	:= dDataBase
	Private lCriaEstru	:=	SubStr( cAcesso,132,1 ) == "S"
	Private lAprova   	:=	SubStr( cAcesso,131,1 ) == "S"

	if nOpcx == 4 .or. nOpcx == 2
		If !fPergunte()
			dDataBase := dDtBk
			Return
		endif	
	endif

	//³ Desativa tecla que aciona pergunta            ³
	Set Key VK_F12 To

	//³ Definicao dos status da pre-estrutura para controle de alcada
	//³ ------------- Status da pre-estrutura sao: -------------     
	//³ 1 - Em criacao					                             
	//³ 2 - Pre-estrutura aprovada                                   
	//³ 3 - Pre-estrutura rejeitada			                         
	//³ 4 - Estrutura criada							             
	//³ 5 - Submetida a aprovacao                                    

	If !lRestEst
		If nOpcx == 4 .And. SGG->GG_STATUS # "1"
			Aviso(OemToAnsi(STR0036),OemToAnsi(STR0042),{"Ok"})
			dDataBase := dDtBk
			RETURN
		EndIf
		//³ Indica que usuario pode aprovar / rejeitar pre estrutura.    ³
		If nOpcx == 8 .And. !lAprova
			Aviso(OemToAnsi(STR0036),OemToAnsi(STR0043),{"Ok"})
			dDataBase := dDtBk
			RETURN
		EndIf
		//³ Indica que usuario pode criar estrutura com base na pre-estrutura.³
		If nOpcx == 9 .And. !lCriaEstru
			Aviso(OemToAnsi(STR0036),OemToAnsi(STR0044),{"Ok"})
			dDataBase := dDtBk
			RETURN
		ElseIf nOpcx == 10 .And. !lCriaEstru
			Aviso(OemToAnsi(STR0036),OemToAnsi(STR0044),{"Ok"})
			dDataBase := dDtBk
			RETURN
		EndIf
	Else
		If aScan(aVldEng, {|x| x == nOpcx}) > 0 .And. Empty(UsrGrEng(cUsuario))
			Aviso(OemToAnsi("Acesso Restrito"),"O acesso e a utilização desta rotina é destinada apenas aos usuários cadastrados como engenheiros.",{"Ok"})
			dDataBase := dDtBk
			RETURN
		ElseIf nOpcX # 3 .And. aScan(aVldEng, {|x| x == nOpcx}) > 0 .And. !(GrpEng(cUsuario,SGG->GG_USUARIO))
			Aviso(OemToAnsi("Acesso Restrito"),"A realização desta ação é restrita aos usuários de um grupo de engenharia específico.",{"Ok"})
			dDataBase := dDtBk
			RETURN
		EndIf
		If nOpcx == 10 .And. SGG->GG_STATUS != "2"
			Aviso(OemToAnsi(STR0036),OemToAnsi(STR0085),{"Ok"})
			dDataBase := dDtBk
			RETURN
		ElseIf nOpcx == 4 .And. SGG->GG_STATUS == "5"
			Aviso(OemToAnsi(STR0036),OemToAnsi(STR0084),{"Ok"})
			dDataBase := dDtBk
			RETURN
		ElseIf nOpcx == 8 .And. SGG->GG_STATUS == "5"
			Aviso(OemToAnsi(STR0036),OemToAnsi(STR0087),{"Ok"})
			dDataBase := dDtBk
			RETURN
		ElseIf nOpcx == 8 .And. SGG->GG_STATUS == "2"
			Aviso(OemToAnsi(STR0036),OemToAnsi(STR0095),{"Ok"})
			dDataBase := dDtBk
			RETURN
		EndIf
	EndIf

	Private nIndex := 1
	If nOpcX == 2
		cTitulo += OemToAnsi(STR0012)
	ElseIf nOpcX == 3
		cTitulo += OemToAnsi(STR0010)
	ElseIf nOpcX == 4
		ldbTree := .T.
		cTitulo += OemToAnsi(STR0009)
	ElseIf nOpcX == 5
		ldbTree := .T.
		cTitulo += OemToAnsi(STR0011)
	ElseIf nOpcX == 8
		ldbTree := .T.
		cTitulo += IIF(!lRestEst,OemToAnsi(STR0040),OemToAnsi(STR0088))
	ElseIf nOpcX == 9 .Or. nOpcX == 10
		ldbTree := .T.
		cTitulo += OemToAnsi(STR0041)
	EndIf

	If nOpcX == 3
		cUm        := ''
		cProduto   := Space(Len(SGG->GG_COD))
		cCodAtual  := Replicate('ú', Len(SGG->GG_COD))
		cValComp   := Replicate('ú', Len(SGG->GG_COD)) + 'ú'
	Else
		SB1->(dbSetOrder(1))
		If !SB1->(dbSeek(xFilial('SB1') + SGG->GG_COD, .F.))
			Help('  ', 1, 'NOFOUNDSB1')
			lRet := .F.
		EndIf
		cUm         := SB1->B1_UM
		nQtdBase	:= If(SB1->(FieldPos("B1_QBP"))>0,RetFldProd(SB1->B1_COD,"B1_QBP"),1)
		cProduto    := SGG->GG_COD
		cCodAtual   := SGG->GG_COD
		cValComp    := SGG->GG_COD + 'ú'
	EndIf

	If lRet .And. SB5->(FieldPos("B5_PROTOTI")) > 0 .And. (nOpcX == 4 .Or. nOpcX == 5) .And. FindFunction('IsProdProt') .And.;
	IsProdProt(cProduto) .And. !IsInCallStack("DPRA340INT")
		Aviso(STR0036,STR0117,{"OK"}) //-- Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR).
		dDataBase := dDtBk
		RETURN
	EndIf

	aSize := MsAdvSize()
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	AADD(aObjects,{100,30,.T.,.F.})
	AADD(aObjects,{100,100,.T.,.T.})
	aPosObj := MsObjSize(aInfo, aObjects)

	DEFINE MSDIALOG oDlg FROM  aSize[7],0 TO aSize[6],aSize[5]  TITLE cTitulo PIXEL
	oDlg:lMaximized := .T.

	@ 000,000 MSPANEL oPanel1 OF oDlg

	@ 001,005 GROUP oGroup TO 40,aPosObj[2,4] OF oPanel1  PIXEL
	oGroup:Align := CONTROL_ALIGN_ALLCLIENT
	@ 008, 038 SAY   OemToAnsi(STR0013) SIZE 037, 007 OF oPanel1 PIXEL
	@ 006, 060 MSGET cProduto           SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SGG','GG_COD') ;
	WHEN (!ldbTree .And. nOpcX==3) VALID A202Codigo(cProduto, @cUm,oUm,oDlg) F3 'SB1'

	@ 008, 290 SAY OemToAnsi(STR0119) SIZE 040, 007 OF oPanel1 PIXEL
	@ 006, 318 MSGET oDtRef Var _dDataRef SIZE 070, 010 OF oPanel1 PIXEL WHEN .F.	

	@ 008, 180 SAY   OemToAnsi(STR0014) SIZE 040, 007 OF oPanel1 PIXEL
	@ 006, 205 MSGET oUm Var cUm        SIZE 013, 010 OF oPanel1 PIXEL WHEN .F.

	@ 022, 007 SAY IIF(MV_PAR01 == 1,OemToAnsi(STR0015),OemToAnsi(STR0081)) SIZE 054, 007 OF oPanel1 PIXEL
	@ 020, 060 MSGET cCodSim            SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SGG','GG_COD') ;
	WHEN !ldbTree VALID A202CodSim(cProduto, cCodSim, @aUndo,nOpcx,oDlg,oTree,@nQtdBase) F3 IIF(MV_PAR01 == 1,'SGG','SG1')

	//--Valida existencia do campo B1_QBP
	If SB1->(FieldPos("B1_QBP")) == 0
		@ 022, 180 SAY  RetTitle("B1_QB")+": 1"  SIZE 053,007 Of oPanel1 PIXEL
	Else
		@ 022, 180 SAY  RetTitle("B1_QBP")SIZE 053,007 Of oPanel1 PIXEL
		@ 020, 215 MSGET oQtdBase Var nQtdBase SIZE 050, 010 OF oPanel1 PIXEL PICTURE PesqPictQt("B1_QBP",20);
		VALID A202QBase(nQtdBase,nOpcX,cProduto,cCodSim,oTree,oDlg) WHEN µ(nOpcx <> 2 .And. nOpcx <> 5 .And. nOpcx <> 6)
	EndIf


	@ 000,000 MSPANEL oPanel2 OF oDlg
	oTree := DbTree():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-25,aPosObj[2,4], oPanel2,,,.T.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	@ 000,000 MSPANEL oPanel3 OF oDlg

	@ 000,000 MSPANEL oPanelLeft SIZE __DlgWidth(oMainWnd)/2,0 OF oPanel3
	oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

	If !lPyme .and. nOpcx == 8
		@ 000,000 MSPANEL oPanelB1 SIZE 140,40 OF oPanelLeft
		lChkRej := (nValPre==2)
		lChkApr := !lChkRej

		IF !lRestEst
			oChkRejei :=TCheckBox():New( 000, 000, STR0039, {|| lChkRej}, oPanelB1, 70,15, ,{|| nValPre := 2,lChkRej := .T.,lChkApr := .F.,oChkAprov:Refresh()})
			oChkRejei:Align := CONTROL_ALIGN_RIGHT

			oChkAprov :=TCheckBox():New( 000, 000, STR0038, {|| lChkApr}, oPanelB1, 70,15, ,{|| nValPre := 1,lChkRej := .F.,lChkApr := .T.,oChkRejei:Refresh()})
			oChkAprov:Align := CONTROL_ALIGN_RIGHT
		Else
			oChkRejei :=TCheckBox():New( 000, 000, STR0093, {|| lChkRej}, oPanelB1, 70,15, ,{|| nValPre := 2,lChkRej := .T.,lChkApr := .F.,oChkAprov:Refresh()})
			oChkRejei:Align := CONTROL_ALIGN_RIGHT

			oChkAprov :=TCheckBox():New( 000, 000, STR0094, {|| lChkApr}, oPanelB1, 70,15, ,{|| nValPre := 1,lChkRej := .F.,lChkApr := .T.,oChkRejei:Refresh()})
			oChkAprov:Align := CONTROL_ALIGN_RIGHT
		EndIf
		oPanelB1:Align := CONTROL_ALIGN_RIGHT
	Endif

	@ 000,000 MSPANEL oPanelRight SIZE __DlgWidth(oMainWnd)/2,0 OF oPanel3
	oPanelRight:Align := CONTROL_ALIGN_RIGHT

	//³ Definição dos Bot”es Utilizados                                        ³
	//-- Inclusão
	@ 000,000 MSPANEL oPanelB2 SIZE 30,40 OF oPanelRight
	If nOpcX == 2 .Or. nOpcX == 5 .Or. nOpcx == 8 .Or. IIF(!lRestEst, nOpcx == 9, nOpcx == 10)
		DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 DISABLE OF oPanelB2 //-- Desabilita Inlus„o
	Else
		DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 ENABLE OF oPanelB2 ;
		ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma202Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru))
	EndIf

	@ 000,000 MSPANEL oPanelB3 SIZE 30,40 OF oPanelRight
	//-- Altera‡„o
	DEFINE SBUTTON oButton3 FROM 000,000 TYPE 11 ENABLE OF oPanelB3 ;
	ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma202Edita(nOpcX, oTree:GetCargo(), oTree, 4, @aUndo, @lMudou, @aAltEstru))

	@ 000,000 MSPANEL oPanelB4 SIZE 30,40 OF oPanelRight
	//-- Exclus„o
	If nOpcX == 2 .Or. nOpcX == 5 .Or. nOpcx == 8 .Or. IIF(!lRestEst, nOpcx == 9, nOpcx == 10)
		DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 DISABLE OF oPanelB4 //-- Desabilita Exclus„o
	Else
		DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 ENABLE OF oPanelB4 ;
		ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma202Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru))
	EndIf

	@ 000,000 MSPANEL oPanelB5 SIZE 30,40 OF oPanelRight
	//-- Pesquisa e Posiciona
	DEFINE SBUTTON oButPosic FROM 000,000 TYPE 15 ENABLE OF oPanelB5 ;
	ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma202Posic(nOpcX, oTree:GetCargo(), oTree))
	oButPosic:cToolTip:=OemToAnsi(STR0016)
	oButPosic:cTitle := OemToAnsi(STR0002) // 'Pesquisar'

	@ 000,000 MSPANEL oPanelB6 SIZE 30,40 OF oPanelRight
	//-- Confirma
	If nOpcX == 5
		DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
		ACTION (lConfirma:=.T., Ma202Del(cCodAtual), Ma202Fecha(oDlg, oTree, nOpcX, .T., cUm, cProduto,.T., aAltEstru,nValPre,nQtdBase))
	Else
		DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
		ACTION (lConfirma:=.T., If(Btn202Ok(aUndo, cProduto) .And. ldbTree, (Ma202Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, .T., aAltEstru,nValPre,nQtdBase),IIF(SuperGetMv("MV_APRESTR",.F.,.F.),A202DelSGN(cCodAtual),"")), .T.))
	EndIf

	@ 000,000 MSPANEL oPanelB7 SIZE 30,40 OF oPanelRight

	//-- Abandona
	DEFINE SBUTTON oButton7 FROM 000,000  TYPE 2 ENABLE OF oPanelB7 ;
	ACTION (lAbandona := .T., Ma202Undo(aUndo), Ma202Fecha(oDlg, oTree, nOpcX, .F., cUm, cProduto, .F., aAltEstru,nValPre,nQtdBase))

	oPanelB2:Align := CONTROL_ALIGN_RIGHT
	oPanelB3:Align := CONTROL_ALIGN_RIGHT
	oPanelB4:Align := CONTROL_ALIGN_RIGHT
	oPanelB5:Align := CONTROL_ALIGN_RIGHT
	oPanelB6:Align := CONTROL_ALIGN_RIGHT
	oPanelB7:Align := CONTROL_ALIGN_RIGHT

	oButton2:Align := CONTROL_ALIGN_RIGHT
	oButton3:Align := CONTROL_ALIGN_RIGHT
	oButton4:Align := CONTROL_ALIGN_RIGHT
	oButPosic:Align := CONTROL_ALIGN_RIGHT
	oButton6:Align := CONTROL_ALIGN_RIGHT
	oButton7:Align := CONTROL_ALIGN_RIGHT

	ACTIVATE MSDIALOG oDlg ON INIT ( Ma202Monta(oTree, oDlg, cCodAtual, cCodSim,nOpcX),;
	AlignObject(oDlg,{oPanel1,oPanel2,oPanel3},1,2,{070,,020})) ;
	VALID If(nOpcX>2.And.nOpcX<=5.And.!(lConfirma.Or.lAbandona), (Ma202Undo(aUndo), Ma202Fecha(,, nOpcX, .F., cUm, cProduto, .F., aAltEstru,nValPre,nQtdBase)), .T.)

	//-- Reinicializa Variaveis
	cInd5     := ''
	ldbTree   := .F.
	cValComp  := Replicate('ú', Len(SGG->GG_COD)) + 'ú'
	cCodAtual := Replicate('ú', Len(SGG->GG_COD))

	RestArea(aAreaAnt)

	//³ Ativa tecla que aciona pergunta.              ³
	SetKey( VK_F12, { || Pergunte('MTA202', .T.) } )

	dDataBase := dDtBk
Return .T.


// Montagem do Arquivo Temporario para o Tree(Func.Recurssiva) 
Static Function Ma202Monta(oTree, oDlg, cProduto, cCodSim,nOpcX, cCargo, cTRTPai)

	Local nRecAnt    := 0
	Local cComp      := ''
	Local cPrompt    := ''
	Local cFolderA   := 'FOLDER5'
	Local cFolderB   := 'FOLDER6'
	Local nRecCargo  := 0
	Local dValIni    := CtoD('  /  /  ')
	Local dValFim    := CtoD('  /  /  ')
	Local nQuant     := 0

	Static nNivelTr  := 0

	nNivelTr += 1

	nOpcX := If(nOpcX==Nil,0,nOpcX)

	If !ldbTree .And. nOpcX < 4
		if nOpcx == 2
			ldbTree   := .T.
			Ma202Monta(oTree, oDlg, cProduto, '',nOpcX)
			Return .T.
		Else
			oDlg:SetFocus()
			Return .F.
		EndIf
	EndIf

	//-- Posiciona no SB1
	cPrompt := cProduto + Space(200)
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
		cPrompt := AllTrim(cProduto) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(cProduto))+Space(200)
	EndIf

	SGG->(dbSetOrder(1))
	If nOpcX == 3 .And. cProduto # Replicate('ú', Len(SGG->GG_COD)) .And. Empty(cCodSim)

		//-- Cria‡„o de uma nova pre-estrutura
		DBADDTREE oTree PROMPT A202Prompt(cPrompt, "") OPENED RESOURCE cFolderA, cFolderB CARGO cProduto + Space(3) + cProduto + '000000000' + '000000000' + 'NOVO'
		DBENDTREE oTree
		oTree:Refresh()
		oTree:SetFocus()
		Return .T.

	ElseIf !SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
		If ldbTree
			oTree:Refresh()
			oTree:SetFocus()
		Else
			oDlg:SetFocus()
		EndIf
		Return .F.
	EndIf

	cTRTPai := If(cTRTPai==Nil,SGG->GG_TRT,cTRTPai)

	dValIni := SGG->GG_INI
	dValFim := SGG->GG_FIM
	If cCargo == Nil
		cCargo := SGG->GG_COD + cTRTPai + SGG->GG_COMP + StrZero(SGG->(Recno()), 9) + StrZero(nIndex ++, 9) + 'CODI'
	ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP) + 1, 9))) > 0
		nRecAnt := SGG->(Recno())
		SGG->(dbGoto(nRecCargo))
		dValIni := SGG->GG_INI
		dValFim := SGG->GG_FIM
		nQuant  := SGG->GG_QUANT
		SGG->(dbGoto(nRecAnt))
	EndIf

	//-- Define as Pastas a serem usadas
	cFolderA := 'FOLDER5'
	cFolderB := 'FOLDER6'
	If Right(cCargo, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
		cFolderA := 'FOLDER7'
		cFolderB := 'FOLDER8'
	EndIf

	if ! (_cModExib == '1' .and. Right(cCargo, 4) == 'COMP' .And. (_dDataRef  < dValIni .Or. _dDataRef  > dValFim))

		//-- Adiciona o Pai na Pre-Estrutura
		DBADDTREE oTree PROMPT A202Prompt(cPrompt, cCargo, nQuant) OPENED RESOURCE cFolderA, cFolderB CARGO cCargo

		Do While !SGG->(Eof()) .And. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cProduto

			nRecAnt := SGG->(Recno())
			cComp   := SGG->GG_COMP
			nQuant  := SGG->GG_QUANT
			cCargo  := SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP + StrZero(SGG->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'

			//-- Define as Pastas a serem usadas
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If dDataBase < SGG->GG_INI .Or. dDataBase > SGG->GG_FIM
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			if _cModExib == '1' .and. (_dDataRef  < SGG->GG_INI .Or. _dDataRef  > SGG->GG_FIM)
				SGG->(dbGoto(nRecAnt))
				SGG->(dbSkip())	
				loop	
			endif

			//-- Posiciona no SB1
			cPrompt := cComp + Space(200)
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
				cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(cComp))+Space(200)
			EndIf
			If SGG->(dbSeek(xFilial('SGG') + SGG->GG_COMP, .F.))
				//-- Adiciona um Nivel a Pre-Estrutura
				Ma202Monta(oTree, oDlg, SGG->GG_COD, '',If(nOpcX==3,0,nOpcX), cCargo, cTRTPai)
			Else
				//-- Adiciona um Componente a Pre-Estrutura
				DBADDITEM oTree PROMPT A202Prompt(cPrompt, cCargo, nQuant) RESOURCE cFolderA CARGO cCargo
			EndIf

			SGG->(dbGoto(nRecAnt))
			SGG->(dbSkip())
		EndDo

		DBENDTREE oTree
	endif

	If ldbTree
		If nNivelTr == 1
			oTree:TreeSeek(oTree:GetCargo())
			oTree:Refresh()
			oTree:SetFocus()
		EndIf
	Else
		oDlg:SetFocus()
	EndIf

	nNivelTr -= 1

Return .T.


// Descri‡„o ³ Adiciona Componentes ao Tree existente (Func.Recurssiva)   
Static Function Ma202ATree(oTree, cProduto, cCargo, cTRTPai)

	Local aAreaAnt   := GetArea()
	Local nRecAnt    := 0
	Local cComp      := ''
	Local cPrompt    := ''
	Local cFolderA   := 'FOLDER5'
	Local cFolderB   := 'FOLDER6'
	Local dValIni    := CtoD('  /  /  ')
	Local dValFim    := CtoD('  /  /  ')
	Local nRecCargo  := 0
	Local cCargoPai  := ''
	Local nQuant     := 0
	cTRTPai := If(cTRTPai==Nil,SGG->GG_TRT,cTRTPai)

	dValIni := SGG->GG_INI
	dValFim := SGG->GG_FIM
	nQuant  := SGG->GG_QUANT
	If cCargo == Nil
		cCargo := SGG->GG_COD + cTRTPai + SGG->GG_COMP + StrZero(SGG->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
	ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP) + 1, 9))) > 0
		nRecAnt := SGG->(Recno())
		SGG->(dbGoto(nRecCargo))
		dValIni := SGG->GG_INI
		dValFim := SGG->GG_FIM
		nQuant  := SGG->GG_QUANT
		SGG->(dbGoto(nRecAnt))
	EndIf

	//-- Define as Pastas a serem usadas
	cFolderA := 'FOLDER5'
	cFolderB := 'FOLDER6'
	If Right(cCargo, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
		cFolderA := 'FOLDER7'
		cFolderB := 'FOLDER8'
	EndIf

	//-- Posiciona no SB1
	cPrompt := cProduto + Space(33)
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
		cPrompt := AllTrim(cProduto) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(cProduto))
	EndIf
	//-- Adiciona o Componente na Pre-Estrutura
	oTree:AddItem(A202Prompt(cPrompt, cCargo,nQuant), cCargo, cFolderA, cFolderB,,, 2)
	oTree:TreeSeek(cCargo)
	cCargoPai := cCargo

	//-- Se o Componente for Pai, Adiciona sua Pre-Estrutura
	SGG->(dbSetOrder(1))
	If SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
		Do While !SGG->(Eof()) .And. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cProduto
			nRecAnt := SGG->(Recno())
			cComp   := SGG->GG_COMP
			cCargo  := SGG->GG_COD + cTRTPai + SGG->GG_COMP + StrZero(SGG->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
			nQuant  := SGG->GG_QUANT
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If dDataBase < SGG->GG_INI .Or. dDataBase > SGG->GG_FIM
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			//-- Posiciona no SB1
			cPrompt := cComp + Space(33)
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
				cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(cComp))
			EndIf
			If SGG->(dbSeek(xFilial('SGG') + SGG->GG_COMP, .F.))
				//-- Adiciona um Nivel a Pre-Estrutura
				Ma202ATree(oTree, SGG->GG_COD, cCargo, cTRTPai)
				oTree:TreeSeek(cCargoPai)
			Else
				//-- Adiciona um Componente a Pre-Estrutura
				oTree:AddItem(A202Prompt(cPrompt, cCargo, nQuant), cCargo, cFolderA, cFolderB,,, 2)
			EndIf

			SGG->(dbGoto(nRecAnt))
			SGG->(dbSkip())
		EndDo
	EndIf

	oTree:Refresh()
	oTree:SetFocus()

	RestArea(aAreaAnt)

Return .T.


// Edição dos Itens da Pre-Estrutura      
Static Function Ma202Edita(nOpcX, cCargo, oTree, nOpcY, aUndo, lMudou, aAltEstru)

	Local aAreaAnt   := GetArea()
	Local aCampos    := {}
	Local aAreaSGG   := SGG->(GetArea())
	Local nRecno	 := 0
	Local nPos       := 0
	Local nX         := 0
	Local lInclui    := (nOpcY==3 .And. nOpcX#2)
	Local lAltera    := (nOpcY==4 .And. nOpcX#2)
	Local lExclui    := (nOpcY==5 .And. nOpcX#2)
	Local lRet       := .T.
	Local cTipo      := ''
	Local nUndoRecno := 0
	Local cFolderA   := 'FOLDER5'
	Local cFolderB   := 'FOLDER6'
	Local aDescend   := {}
	Local cCargoPai  := ''
	Local cPrompt    := ""
	Local cProdNAlt	 := ""
	Local aTamQtde   := TamSX3("G1_QUANT")

	//-- Variaveis utilizadas nos Ax's
	Private aAlter     := {}
	Private aAcho      := {}
	Private cDelFunc   := 'a202TudoOk("E")'
	Private lDelFunc   := .T.
	Private cCodPai    := ''
	Private aEndEstrut := {}

	aUndo := If(aUndo==Nil,{},aUndo)

	//-- Variaveis do Componente Tree referentes ao registro Atual
	nRecno := Val(SubStr(cCargo,Len(SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP) + 1, 9))
	cTipo  := Right(cCargo,4)

	//³ Deleta do Array aAcho os campos que n„o devem aparecer       ³
	a202Fields(@aAcho)
	If (nPos := aScan(aAcho, {|x| 'GG_FILIAL' $ Upper(x)})) > 0
		aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
	If (nPos := aScan(aAcho, {|x| 'GG_COD'    $ Upper(x)})) > 0
		aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
	If (nPos := aScan(aAcho, {|x| 'GG_NIV'    $ Upper(x)})) > 0
		aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
	If (nPos := aScan(aAcho, {|x| 'GG_NIVINV' $ Upper(x)})) > 0
		aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
	If (nPos := aScan(aAcho, {|x| 'GG_OK' $ Upper(x)})) > 0
		aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
	If (nPos := aScan(aAcho, {|x| 'GG_STATUS' $ Upper(x)})) > 0
		aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
	If (nPos := aScan(aAcho, {|x| 'GG_USUARIO' $ Upper(x)})) > 0
		aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
	If !lInclui
		If (nPos := aScan(aAcho, {|x| 'GG_DESC' $ Upper(x)})) > 0
			aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
		EndIf
	EndIf

	//³ Deleta do Array aAlter os campos que n„o devem ser alterados ³
	aAlter := aClone(aAcho)
	If lAltera .And. (nPos := aScan(aAlter, {|x| 'GG_COMP' $ Upper(x)})) > 0
		aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
	EndIf

	//³Posiciona o SGG no registro a ser editado                               ³
	If cTipo # 'NOVO' .And. nRecno <= 0
		Help(' ', 1, 'CODNEXIST')
		RestArea(aAreaAnt)
		Return .F.
	EndIf

	dbSelectArea('SGG')
	dbSetOrder(1)
	dbGoto(If(nRecno>0,nRecno,aAreaSGG[3]))

	//³Não edita o Pai                                                         ³
	If !lInclui .And. (cTipo == 'CODI' .Or. cTipo == 'NOVO')
		Help(' ',1,'REGNOIS') //-- Help NAO PODE EDITAR O PAI
		RestArea(aAreaAnt)
		Return .F.
	EndIf

	cCodPai   := If(nRecno>0,If(cTipo=='CODI',SGG->GG_COD,SGG->GG_COMP),cCodAtual)
	cCargoPai := oTree:GetCargo()

	If nOpcX == 3 .Or. nOpcX == 4	//-- Inclui ou Altera
		aDescend := {}
		a202Descen(@cValComp, @aDescend, oTree)
		If lInclui
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			SetStartMod(.T.)
			If AxInclui(Alias(), Recno(), 3, aAcho,, aAlter, 'a202TudoOK("I")') == 1
				aAdd(aDescend, GG_COMP)
				lMudou := .T.
				Begin Transaction
					//³ Definicao dos status da pre-estrutura para controle de alcada³
					//³ ------------- Status da pre-estrutura sao: -------------     ³
					//³ 1 - Em criacao					                             ³
					//³ 2 - Pre-estrutura aprovada                                   ³
					//³ 3 - Pre-estrutura rejeitada			                         ³
					//³ 4 - Estrutura criada							             ³
					//³ 5 - Submetida a aprovacao                                    ³
					RecLock('SGG', .F.)
					Replace GG_COD     With cCodPai
					Replace GG_STATUS  With "1"
					Replace GG_USUARIO With IIF(!lRestEst,Subs(cUsuario,7,6),RetCodUsr())
					MsUnlock()
				End Transaction
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf
				//-- Alimenta Array com a Descendˆncia dos Produtos Incluidos
				If Len(aDescend) > 0
					For nX := 1 to Len(aDescend)
						If aScan(aAltEstru, aDescend[nX]) == 0
							aAdd(aAltEstru, aDescend[nX])
						EndIf
					Next nX
				EndIf
				If cTipo == 'NOVO'
					oTree:DelItem()
					Ma202ATree(oTree, SGG->GG_COD, SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP + StrZero(SGG->(Recno()),9) + StrZero(nIndex ++, 9) + 'CODI')
				Else
					Ma202ATree(oTree, SGG->GG_COMP, SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP + StrZero(SGG->(Recno()),9) + StrZero(nIndex ++, 9) + 'COMP')
				EndIf
				oTree:TreeSeek(cCargoPai)
			EndIf
		ElseIf lAltera
			//³ Guarda o Status inicial do Registro ³
			aCampos := {}
			If aScan(aUndo, {|x| x[1]==Recno()}) == 0
				For nX := 1 To FCount()
					aAdd(aCampos, FieldGet(nX))
				Next nX
			EndIf
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			SetStartMod(.T.)
			If AxAltera(Alias(), Recno(), 4, aAcho, aAlter,,, 'a202TudoOk("A")') == 1

				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf

				//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
				If Len(aDescend) > 0
					For nX := 1 to Len(aDescend)
						If aScan(aAltEstru, aDescend[nX]) == 0
							aAdd(aAltEstru, aDescend[nX])
						EndIf
					Next nX
				EndIf

				//-- Remonta o Prompt do Tree
				SB1->(dbSeek(xFilial("SB1")+SGG->GG_COMP))
				dbSelectArea(oTree:cArqTree)
				RecLock((oTree:cArqTree), .F.)
				Replace T_CARGO With (SGG->GG_COD+SGG->GG_TRT+SGG->GG_COMP+StrZero(SGG->(Recno()),9)+StrZero(nIndex ++, 9)+'COMP')
				MsUnlock()
				cCargo  := T_CARGO
				cPrompt := AllTrim(SGG->GG_COMP) + " - " + AllTrim(SB1->B1_DESC)
				cPrompt := AllTrim(A202Prompt(cPrompt,cCargo, SGG->GG_QUANT))
				oTree:ChangePrompt(cPrompt, cCargo)

				//-- Define as Pastas a serem usadas
				cFolderA := 'FOLDER5'
				cFolderB := 'FOLDER6'
				If Right(oTree:GetCargo(), 4) == 'COMP' .And. ;
				(dDataBase < SGG->GG_INI .Or. dDataBase > SGG->GG_FIM)
					cFolderA := 'FOLDER7'
					cFolderB := 'FOLDER8'
				EndIf
				oTree:ChangeBMP(cFolderA, cFolderB)

				//-- Retorna status para Em Criacao
				If SuperGetMV("MV_APRESTR",.F.,.F.)
					nRecno := SGG->(Recno())
					cProdNAlt := SGG->GG_COD
					SGG->(dbSetOrder(1))
					SGG->(dbSeek(xFilial("SGG")+cProdNAlt))
					While !SGG->(EOF()) .And. SGG->(GG_FILIAL+GG_COD) == xFilial("SGG")+cProdNAlt
						RecLock("SGG",.F.)
						SGG->GG_STATUS := '1'
						SGG->(MsUnLock())
						If aScan(aUndo, {|x| x[1] == Recno()}) == 0
							aAdd(aUndo,{Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
						EndIf
						SGG->(dbSkip())
					End
					SGG->(dbGoTo(nRecno))
				EndIf
			EndIf
		ElseIf lExclui
			a202Desc(SGG->GG_COMP)
			nUndoRecno := Recno()
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			SetStartMod(.T.)
			If AxDeleta(Alias(), Recno(), 5) == 2
				If lDelFunc
					lMudou := .T.
					nPos:=aScan(aUndo, {|x| x[1]==nUndoRecno})
					If nPos == 0
						aAdd(aUndo, {nUndoRecno, 2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
						//Else
						//	aUndo[nPos,2]:=2
					EndIf
					//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
					If Len(aDescend) > 0
						For nX := 1 to Len(aDescend)
							If aScan(aAltEstru, aDescend[nX]) == 0
								aAdd(aAltEstru, aDescend[nX])
							EndIf
						Next nX
					EndIf
					oTree:DelItem()
					oTree:Refresh()
					oTree:SetFocus()
				EndIf
			EndIf
		EndIf

	ElseIf nOpcX == 2 .Or. nOpcX == 5 .Or. nOpcx == 8 .Or. IIF(!lRestEst, nOpcx == 9, nOpcx == 10)//-- Visualiza ou Exclui
		AxVisual(Alias(), Recno(), 2, aAcho)
	EndIf

	//³ Efetua o EndEstrut2 apos o End Transaction                          ³
	If Len(aEndEstrut) > 0
		For nX := 1 to Len(aEndEstrut)
			FimEstrut2(aEndEstrut[nX,1],aEndEstrut[nX,2])
		Next nX
		aEndEstrut := {}
	EndIf
	//³ Restaura Area de trabalho.                                   ³
	RestArea(aAreaAnt)
Return .T.


// Valida‡„o do C¢digo do Produto na Pre-Estrutura    
Static Function A202Codigo(cProduto, cUm,oUm,oDlg)

	Local aAreaAnt   := GetArea()
	Local aAreaSB1   := SB1->(GetArea())
	Local aAreaSGG   := SGG->(GetArea())
	Local cSeek      := ''
	Local lRet       := .T.

	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
		Help(' ',1, 'NOFOUNDSB1')
		lRet := .F.
	Else
		cUm:= SB1->B1_UM
		If oUm # Nil
			oUm:Refresh()
		EndIf
	EndIf

	If lRet .And. !ldbTree
		If oDlg # Nil
			oDlg:Refresh()
		EndIf
		SGG->(dbSetOrder(1))
		If SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
			Help(' ',1, 'CODEXIST')
			lRet := .F.
		EndIf
		SGG->(dbSetOrder(2))
		If lRet .And. SGG->(dbSeek(cSeek := xFilial('SGG') + cProduto, .F.))
			Do While !SGG->(Eof()) .And. SGG->GG_FILIAL + SGG->GG_COMP == cSeek
				If SGG->GG_QUANT < 0 .And. !GetMV('MV_NEGESTR')
					Help(' ',1,'A202NAOINC')
					lRet := .F.
					Exit
				EndIf
				SGG->(dbSkip())
			EndDo
		EndIf
		If lRet
			If ExistBlock("MT202PAI")
				lRet:=ExecBlock("MT202PAI",.F.,.F.,cProduto)
			EndIf
		EndIf
	EndIf

	If lRet .And. SB5->(FieldPos("B5_PROTOTI")) > 0 .And. FindFunction('IsProdProt') .And. IsProdProt(cProduto) .And. !IsInCallStack("DPRA340INT")
		Aviso(STR0036,STR0117,{"OK"}) //-- Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR).
		lRet := .F.
	EndIf

	//³ Restaura Area de trabalho.                                   ³
	RestArea(aAreaSGG)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)
Return lRet


// Valida Pre-Estrutura Similar                              
Static Function A202CodSim(cProduto, cCodSim, aUndo,nOpcx,oDlg,oTree,nQtdBase)

	Local aAreaAnt   := GetArea()
	Local aAreaSB1   := SB1->(GetArea())
	Local aAreaSGG   := SGG->(GetArea())
	Local aAreaSG1   := SG1->(GetArea())
	Local cNomeArq   := ''
	Local cAliasSTRU := IIF(MV_PAR01 ==1 ,"SGG","SG1")
	Private nEstru     := 0

	If !Empty(cCodSim) .And. nOpcx == 3
		SB1->(dbSetOrder(1))
		If !SB1->(dbSeek(xFilial('SB1') + cCodSim))
			Help(' ',1,'NOFOUNDSB1')
			//³ Restaura Area de trabalho.                                   ³
			RestArea(aAreaSGG)
			RestArea(aAreaSB1)
			RestArea(aAreaAnt)
			Return .F.
		ElseIf lRestEst
			nQtdBase := RetFldProd(cCodSim,If(MV_PAR01 == 1,"B1_QBP","B1_QB"))
		EndIf
		(cAliasSTRU)->(dbSetOrder(1))
		If !(cAliasSTRU)->((dbSeek(xFilial(cAliasSTRU) + cCodSim)))
			Help(' ',1,'ESTNEXIST')
			//³ Restaura Area de trabalho.                                   ³
			RestArea(aAreaSGG)
			RestArea(aAreaSG1)
			RestArea(aAreaSB1)
			RestArea(aAreaAnt)
			Return .F.
		EndIf
		//³ Verifica se o produto similar n„o contem o      ³
		//³ produto principal em sua Pre-estrutura.         ³
		cNomeArq := Estrut2(cCodSim,NIL,NIL,NIL,NIL,IIF(MV_PAR01 == 1,.T.,.F.))
		dbSelectArea('ESTRUT')
		ESTRUT->(dbGotop())
		Do While !ESTRUT->(Eof())
			If ESTRUT->COMP == cProduto
				Help(' ',1,'SIMINVALID')
				//³ Restaura Area de trabalho.                                   ³
				RestArea(aAreaSGG)
				RestArea(aAreaSG1)
				RestArea(aAreaSB1)
				RestArea(aAreaAnt)
				Return .F.
			EndIf
			ESTRUT->(dbSkip())
		EndDo
		FimEstrut2(Nil,cNomeArq)
		//³ Gera Registros da Pre-Estrutura Similar                      ³
		Ma202GrSim(cProduto, cCodSim, @aUndo)
		//³ Ponto de Entrada para alteracao da Pre-Estrutura Similar     ³
		If ExistBlock('MT202CSI')
			//-- Sao passados os seguintes parametros:
			//-- aParamIXB[1] = Codigo do Produto
			//-- aParamIXB[2] = Codigo do Produto Similar
			ExecBlock('MT202CSI', .F., .F., {cProduto, cCodSim})
		EndIf
	EndIf
	If SB1->(FieldPos("B1_QBP")) == 0
		A202QBase(1,nOpcX,cProduto,cCodSim,oTree,oDlg)
	EndIf
	//³ Restaura Area de trabalho.                                   ³
	RestArea(aAreaSGG)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)
Return .T.


// Valida o c¢digo do componente na Pre-Estrutura     
Static Function a202Comp()

	Local lRet := .T.

	lRet := A202ChkNod(M->GG_COMP, cValComp)
	If lRet
		lRet := A202Codigo(M->GG_COMP, '')
		If lRet
			lRet := A202OutPai(M->GG_COMP, cValComp)
		EndIf
	EndIf

	If lRet .And. SB5->(FieldPos("B5_PROTOTI")) > 0 .And. FindFunction('IsProdProt') .And. ;
	IsProdProt(M->GG_COMP) .And. !IsInCallStack("DPRA340INT")
		Aviso(STR0036,STR0117,{"OK"}) //-- Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR).
		lRet := .F.
	EndIf

Return lRet


// Verifica existencia de um mesmo c¢digo em um n¢ da estrutura
Static Function A202ChkNod(cProduto, cLista)

	Local aAreaAnt := GetArea()
	Local aAreaSGG := SGG->(GetArea())
	Local cNomeArq := ''
	Local cNomeAli := ''
	Local lRet     := .T.

	Private nEstru     := 0

	If cProduto $(cLista)
		Help(' ',1,'A202NODES')
		lRet := .F.
	EndIf

	//-- Verifica se o Produto possui Pre-Estrutura
	If lRet
		dbSelectArea('SGG')
		dbSetorder(1)
		If dbSeek(xFilial('SGG') + cProduto, .F.)
			nNAlias ++
			cNomeAli := "ES"+StrZero(nNAlias,3)
			cNomeArq := Estrut2(cProduto, 1,cNomeAli,NIL,NIL,.T.)
			dbSelectArea(cNomeAli)
			dbGoTop()
			Do While !Eof() .And. lRet
				If COMP $(cLista)
					Help(' ',1,'A202NODES')
					lRet := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
			If Type('aEndEstrut') == 'A'
				aAdd(aEndEstrut,{cNomeAli,cNomeArq})
			Else
				FimEstrut2(Nil, cNomeArq)
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSGG)
	RestArea(aAreaAnt)

Return lRet


// Verifica a existencia de uma mesmo c¢digo em um n¢ da estrua
Static Function A202OutPai(cProduto, cLista)

	Local cPai   := Substr(cLista,1,15)
	Local nRecno := Recno()
	Local nOrdem := IndexOrd()
	Local lRet   := .T.

	SGG->(dbSetOrder(2))
	SGG->(dbSeek(xFilial('SGG')+cPai))
	Do While !SGG->(Eof()) .And. SGG->GG_FILIAL == xFilial("SGG")
		If SGG->GG_COD == cProduto
			Help(' ',1,'A202NODES2',,cProduto,2,26)
			lRet := .F.
			Exit
		EndIf
		SGG->(dbSeek(xFilial('SGG')+SGG->GG_COD))
	EndDo
	dbSetOrder(1)

	dbSetOrder(nOrdem)
	dbGoto(nRecno)

Return lRet


// False caso encontre um c¢digo repetido e True em C.C.   
Static Function A202Desc(cCod)

	Local aAreaAnt := GetArea()
	Local lRet     := .T.

	cCod := If(cCod==Nil,M->GG_COMP,cCod)

	//³ Posiciona no produto desejado e preenche descricao      ³
	If SB1->(dbSeek(xFilial('SB1')+cCod, .F.))
		M->GG_DESC := SB1->B1_DESC
	Else
		Help(' ', 1, 'NOFOUNDSB1')
		lRet := .F.
	EndIf

	RestArea(aAreaAnt)

Return lRet


// Validação da quantidade do Produto na Pre-Estrutura  
Static Function MA202Quant(nQuant,cCod)

	Local nVar       := 0
	Local lRet       := .T.
	Local cAlias     := ''
	Local nRecno     := 0
	Local nOrder     := 0

	nVar := If(nQuant==Nil,&(ReadVar()),nQuant)

	If IsProdMod(cCod) .And. GetMV('MV_TPHR') == 'N'
		nVar := nVar - Int(nVar)
		If nVar > .5999999999
			HELP(' ',1,'NAOMINUTO')
			lRet := .F.
		EndIf
	ElseIf QtdComp(nVar) < QtdComp(0) .And. !GetMV('MV_NEGESTR')
		Help(' ',1,'A202NAONEG')
		lRet := .F.
	EndIf

Return lRet


// Retorna a Integridade do Sistema apos a finalização    
Static Function Ma202Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, lConfirma, aAltEstru,nValPre,nQtdBase)
	Local nOkAceRj   := 3
	Local lRet       := .T.
	Local cArqTrab   := ''
	Local nRecno	 := 0
	Local cProdInt	 := ''
	Local lAchou 	 := .F.
	Local cUsuario	 := ''
	LOCAL oWizard,oUsado,oUsado2,oUsado3,oUsado4,oUsado5
	LOCAL oGet1,oGet2,oChk1
	LOCAL nTipoItens := 3
	LOCAL nNivelCal  := 1
	LOCAL nTipodata  := 2
	LOCAL dDataIni   := ddatabase
	LOCAL dDataFim   := ddatabase
	LOCAL nTipoSobre := 1
	LOCAL nTipoApaga := 1
	LOCAL lMudaNome  := .F.
	LOCAL cNomePai   := Criavar("B1_COD",.F.)
	Local cAliasB1BZ := If(SuperGetMv('MV_ARQPROD',.F.,"SB1")=="SBZ","SBZ","SB1")
	Local aDocto	 := {}
	Local cProdCtrl  := ""

	If lConfirma
		//³ Aprovacao / Rejeicao                                      ³
		If nOpcx == 8
			If !lRestEst
				//³ Carrega dados da Pre-estrutura para aceitar / rejeitar³
				// Aprovou
				If nValPre == 1
					nOkAceRj:=Aviso(OemToAnsi(STR0045),OemToAnsi(STR0046),{OemToAnsi(STR0047),OemToAnsi(STR0048),OemToAnsi(STR0049)})
					// Rejeitou
				ElseIf nValPre == 2
					nOkAceRj:=Aviso(OemToAnsi(STR0050),OemtoAnsi(STR0051),{OemToAnsi(STR0047),OemToAnsi(STR0048),OemToAnsi(STR0049)})
				EndIf
				If nOkAceRj # 3
					Processa({|| A202Aprova(cProduto,nOkAceRj,nValPre) })
				Else
					lRet:=.F.
				EndIf
			Else
				SGG->(dbSetOrder(1))
				If SuperGetMv('MV_APRESTR',.F.,.F.)
					A202CriSGN(cProduto,RetCodUsr(),UsrGrEng(RetCodUsr()),nValPre==1)
				EndIf
			Endif
			//³ Criacao de Pre-estrutura                                  ³
		ElseIf IIF(!lRestEst, nOpcx == 9, nOpcx == 10)
			DEFINE WIZARD oWizard TITLE OemToAnsi(STR0041) HEADER OemToAnsi(STR0056) MESSAGE " " TEXT OemtoAnsi(STR0057) PANEL NEXT {|| .T.} FINISH {|| .T.}
			// Painel 2
			CREATE PANEL oWizard HEADER OemToAnsi(STR0058)  MESSAGE OemToAnsi(STR0059) PANEL BACK {|| .T.} NEXT {|| .T.  } FINISH {|| .T.} EXEC {|| .T.}
			// Painel 3
			CREATE PANEL oWizard HEADER OemToAnsi(STR0060) MESSAGE OemToAnsi(STR0061) PANEL BACK {|| .T.} NEXT {|| .F.  } FINISH {|| A202PrG1(cProduto,nNivelCal,nTipoItens,nTipoData,dDataIni,dDataFim,nTipoSobre,nTipoApaga,lMudaNome,cNomePai) } EXEC {|| .F.}
			// Objetos do Painel 2
			@ 04,22 TO 50,80 LABEL OemToAnsi(STR0062) OF oWizard:oMPanel[2] PIXEL
			@ 14,27 RADIO oUsado VAR nNivelCal 3D SIZE 40,15 PROMPT OemToAnsi(STR0047),OemToAnsi(STR0048) OF oWizard:oMPanel[2] PIXEL

			If !lRestEst
				@ 60,22 TO 125,80 LABEL OemToAnsi(STR0063) OF oWizard:oMPanel[2] PIXEL
				@ 70,27 RADIO oUsado2 VAR nTipoItens 3D SIZE 50,15 PROMPT STR0064,STR0065,STR0066 OF oWizard:oMPanel[2] PIXEL
			EndIf

			@ 04,90 TO 125,260 LABEL OemToAnsi(STR0067) OF oWizard:oMPanel[2] PIXEL

			@ 14,95 RADIO oUsado3 VAR nTipodata 3D SIZE 45,15 PROMPT STR0068,STR0069,STR0070 OF oWizard:oMPanel[2] PIXEL
			oUsado3:bChange := { || IIF(nTipoData=3,(oGet1:Enable(),oGet2:Enable()),(oGet1:Disable(),oGet2:Disable())) }

			@ 65,120 Say OemToAnsi(STR0071) SIZE 30,10 OF oWizard:oMPanel[2] PIXEL
			@ 65,150 MSGET oGet1 VAR dDataIni When IIF(nTipoData=3,.T.,.F.) Valid dDataFim >= dDataIni SIZE 48,10 OF oWizard:oMPanel[2] PIXEL
			@ 80,120 Say OemToAnsi(STR0072) SIZE 30,10 OF oWizard:oMPanel[2] PIXEL
			@ 80,150 MSGET oGet2 VAR dDataFim When IIF(nTipoData=3,.T.,.F.) Valid dDataFim >= dDataIni SIZE 48,10 OF oWizard:oMPanel[2] PIXEL

			// Objetos do Painel 3
			@ 004,22 TO 50,200 LABEL OemToAnsi(STR0073) OF oWizard:oMPanel[3] PIXEL
			@ 014,27 RADIO oUsado4 VAR nTipoSobre 3D SIZE 60,15 PROMPT STR0074,STR0075 OF oWizard:oMPanel[3] PIXEL

			@ 60,22 TO 100,200 LABEL OemToAnsi(STR0076) OF oWizard:oMPanel[3] PIXEL
			@ 70,27 RADIO oUsado5 VAR nTipoApaga 3D SIZE 50,15 PROMPT STR0077,STR0078 OF oWizard:oMPanel[3] PIXEL

			@ 110,22 CHECKBOX oChk1 VAR lMudaNome PROMPT OemToAnsi(STR0079) SIZE 80, 10 OF oWizard:oMPanel[3] PIXEL ;oChk1:oFont := oDlg:oFont
			ochk1:bChange := { || IIF(lMudaNome,oGet3:Enable(),oGet3:Disable()) }
			@ 110,110 MSGET oGet3 VAR cNomePai F3 "SB1" When lMudaNome Valid A202CodDes(cNomePai) SIZE 80,10 OF oWizard:oMPanel[3] PIXEL

			ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }
		Else
			//³ Altera o STATUS para em criacao quando o parametro MV_APRESTR estiver habilitado³
			If (lMudou .And. lRestEst) .And. nOpcx == 4
				nRecno := SGG->(Recno())
				SGG->(dbSetOrder(1))
				If SGG->(dbSeek(xFilial("SGG")+cProduto))
					SGN->(dbSeek(xFilial("SGN")+"SGG"+cProduto))
					While !SGN->(EOF())
						RecLock("SGN",.F.)
						SGN->(dbDelete())
						SGN->(MsUnLock())
						SGN->(dbSkip())
					End
					SGG->(dbSetOrder(1))
					While !SGG->(Eof()) .And. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cProduto
						RecLock('SGG', .F.,.T.)
						Replace GG_STATUS With "1"
						MsUnlock()
						SGG->(dbSkip())
					EndDo
				EndIf
				SGG->(dbGoto(nRecno))
			EndIf
			If lMudou .And. (nOpcX > 2 .And. nOpcX <= 5)
				a202NivAlt()
			EndIf
			//--Atualiza a quantidade base
			dbSelectArea(cAliasB1BZ)
			dbSetOrder(1)
			dbSeek(xFilial(cAliasB1BZ)+cProduto)
			If cAliasB1BZ == "SBZ" .And. Found() .And. (cAliasB1BZ)->(FieldPos("BZ_QBP")) > 0
				RecLock("SBZ",.F.)
				Replace BZ_QBP With nQtdBase
				MsUnLock()
			ElseIf ("SB1")->(FieldPos("B1_QBP")) > 0
				SB1->(dbSeek(xFilial("SB1")+cProduto))
				RecLock("SB1",.F.)
				Replace B1_QBP With nQtdBase
				MsUnLock()
			EndIf
			//³ Seta o parametro MV_NIVALT                                ³
			If lMudou .And. (nOpcX > 2 .And. nOpcX <= 5)
				a202NivAlt()
			EndIf
			//³ Executa Ponto de Entrada na Grava‡„o da Pre-Estrutura     ³
			If ExistBlock('A202GrvE')
				Execblock('A202GrvE',.F.,.F.)
			EndIf
		EndIf
	EndIf

	If lRet
		//³ Deleta o 5o Indice de Trabalho do arquivo dbTree                    ³
		If !Empty(cInd5) .And. File(cInd5+OrdBagExt())
			cArqTrab := oTree:cArqTree
			dbSelectArea(cArqTrab)
			dbClearIndex()
			fErase(cInd5+OrdBagExt())
			cInd5 := ''
			dbSetIndex(SubStr(cArqTrab,2)+'A'+OrdBagExt())
			dbSetIndex(SubStr(cArqTrab,2)+'B'+OrdBagExt())
			dbSetIndex(SubStr(cArqTrab,2)+'C'+OrdBagExt())
			dbSetIndex(SubStr(cArqTrab,2)+'D'+OrdBagExt())
			dbSetOrder(1)
		EndIf

		If oDlg # Nil .And. oTree # Nil
			Release Object oTree
			oDlg:End()
		Endif
	EndIf
Return lRet


// Deleta a Pre-Estrutura Atual                               
Static Function Ma202Del(cProduto)

	Local aAreaAnt   := GetArea()
	Local cSeek      := xFilial('SGG')+cProduto
	Local aDelet     := {}
	Local nX         := 0
	Local lRet       := .T.

	dbSelectArea('SGG')
	dbSetOrder(1)
	If !(lRet:=dbSeek(cSeek, .F.))
		Help(' ', 1, 'REGNOIS')
	Else
		Do While !Eof() .And. GG_FILIAL+GG_COD == cSeek
			aAdd(aDelet, Recno())
			dbSkip()
		EndDo
		Begin Transaction
			For nX := 1 to Len(aDelet)
				dbGoto(aDelet[nX])
				RecLock('SGG', .F., .T.)
				dbDelete()
				MsUnlock()
			Next nX
			IF lRestEst
				SGN->(dbSetOrder(1))
				If SGN->(dbSeek(xFilial("SGN")+"SGG"+cProduto))
					Do While SGN->(!Eof()) .And. SGN->GN_FILIAL+SGN->GN_TIPO+SGN->GN_NUM == xFilial("SGN")+"SGG"+cProduto
						RecLock("SGN", .F., .T.)
						dbDelete()
						MsUnlock()
						SGN->(dbSkip())
					EndDo
				EndIf
			EndIf
		End Transaction
	EndIf

	RestArea(aAreaAnt)

Return lRet


// Desfaz as Inclus”es/Exclus”es/Alteracoes                   
Static Function Ma202Undo(aUndo)

	Local lRet       := .T.
	Local nX         := 0
	Local nY         := 0
	Local aAreaAnt   := GetArea()

	Begin Transaction

		dbSelectArea('SGG')
		For nX := 1 to Len(aUndo)
			If aUndo[nX,1] > 0 .And. aUndo[nX,1] <= LastRec()
				dbGoto(aUndo[nX,1])
				If (lRet:=RecLock('SGG', .F.))
					If aUndo[nX, 2] == 1 //-- O Registro foi Incluido
						//-- Deleta o Registro
						If !Deleted()
							dbDelete()
						EndIf
					ElseIf aUndo[nX, 2] == 2 //-- O Registro foi Excluido
						//-- Restaura O REGISTRO
						If Deleted()
							dbRecall()
						EndIf
					ElseIf aUndo[nX, 2] == 3 //-- O Registro foi Alterado
						//-- Restaura OS DADOS do Registro
						For nY := 1 to Len(aUndo[nX, 3])
							FieldPut(nY, aUndo[nX, 3, nY])
						Next nY
					EndIf
					MsUnlock()
				Else
					Exit
				EndIf
			EndIf

		Next nX

		If ExistBlock("A202UNDO")
			//--- Parametros passados para PARAMIXB:
			//--- PARAMIXB[nX,1] = Nro. do Registro
			//--- PARAMIXB[nX,2] = Tipo - 1. Inclusao/2. Exclusao/3. Alteracao
			//--- PARAMIXB[nX,3,nY] = Campos Alterados do componente
			ExecBlock("A202UNDO",.F.,.F.,aUndo)
		EndIf

	End Transaction

	RestArea(aAreaAnt)

Return lRet


// Preenche a Variavel cValComp com a Descendencia do Produto 
Static Function A202Descen(cValComp, aDescend, oTree)

	Local aAreaAnt   := GetArea()
	Local aAreaTRE   := {}
	Local cPai       := ''
	Local cCod       := ''
	Local lRet       := .T.
	Local nX		 := 0

	cValComp := ''
	aDescend := {}

	dbSelectArea(oTree:cArqTree)
	aAreaTRE := GetArea()
	cPai     := T_IDTREE
	cCod     := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SGG->GG_COD) + Len(SGG->GG_TRT) + 1, Len(SGG->GG_COD) ),Left(T_CARGO, Len(SGG->GG_COD)))
	aAdd(aDescend, cCod)

	Do While .T.
		dbSetOrder(3) //-- Ordem de T_IDCODE (Filho)
		If Val(cPai) # 0 .And. dbSeek(cPai, .F.)
			cCod   := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SGG->GG_COD) + Len(SGG->GG_TRT) + 1, Len(SGG->GG_COD) ),Left(T_CARGO, Len(SGG->GG_COD)))
			aAdd(aDescend, cCod)
			cPai := T_IDTREE
			Loop
		Else
			Exit
		EndIf
	EndDo

	If Len(aDescend) > 0
		For nX := Len(aDescend) to 1 Step -1
			cValComp += aDescend[nX] + 'ú'
		Next nX
	EndIf

	//-- Restaura a Area de Trabalho
	dbSetOrder(aAreaTRE[2])
	dbGoto(aAreaTRE[3])
	RestArea(aAreaAnt)

Return lRet


// Valida‡„o Final da Inclus„o/Altera‡„o                     
Static Function A202TudoOk(cOpc)

	Local aAreaAnt   := GetArea()
	Local aAreaTRE   := {}
	Local aAreaSGG   := {}
	Local cSeek      := ''
	Local lRet       := .T.
	Local lRetPE     := .T.
	Local nRecno     := 0

	cOpc := If(cOpc==Nil,Space(1),cOpc) //-- "I" = Inclus„o / "A" = Altera‡„o / "E" = Exclus„o

	If !(cOpc=='E')
		//³ Valida grupo de opcionais e item de opcionais   ³
		If (!Empty(M->GG_GROPC).And.Empty(M->GG_OPC)) .Or. (!Empty(M->GG_OPC).And.Empty(M->GG_GROPC))
			Help(' ',1,'A202OPCOBR')
			lRet := .F.
		EndIf

		//³ Valida a Existencia de Similaridade na Pre-Estrutura Atual (DBTree)³
		If lRet
			dbSelectArea(oTree:cArqTree)
			aAreaTRE := GetArea()
			dbSetOrder(4)
			nRecno := Recno()
			dbSeek(cSeek := cCodPai + M->GG_TRT + M->GG_COMP, .T.)
			If ! Eof()
				Do While !Eof() .And. cSeek == Left(T_CARGO, Len(cSeek))
					If !(nRecno==Recno()) .And. !(Right(T_CARGO,4)$'CODIúNOVO')
						Help(' ',1,'MESMASEQ')
						lRet := .F.
						Exit
					EndIf
					dbSkip()
				EndDo
			EndIf
			dbSetOrder(aAreaTRE[2])
			dbGoto(aAreaTRE[3])
		EndIf
		//³ Valida a Existencia de Similaridade na Pre-Estrutura Gravada (SGG) ³
		If lRet
			dbSelectArea('SGG')
			aAreaSGG := GetArea()
			dbSetOrder(1)
			If dbSeek(xFilial('SGG')+cCodPai+M->GG_COMP+M->GG_TRT, .F.)
				Help(' ',1,'MESMASEQ')
				lRet := .F.
			EndIf
			RestArea(aAreaSGG)
		EndIf

	EndIf

	//³ Execblock MTA202 ap¢s Conf.da InclusÆo/Altera‡„o/Dele‡„o          ³
	If lRet
		If ExistBlock('MTA202')
			lRet := If(ValType(lRetPE:=ExecBlock('MTA202',.F.,.F.,cOpc))=='L',lRetPE,.T.)
		EndIf
	EndIf

	If cOpc == 'E' .And. Type('lDelFunc') == 'L'
		lDelFunc := lRet
	EndIf

	RestArea(aAreaAnt)
Return lRet


// Gravação das Pre-Estruturas Similares                      
Static Function Ma202GrSim(cProduto, cCodSim, aUndo)
	Local lRet       := .T.
	Local aAreaAnt   := GetArea()
	Local aAreaTRE   := {}
	Local aRecnos    := {}
	Local nAcho      := 0
	Local nX         := 0
	Local i          := 0
	Local aCampos    := {}

	If Empty(cCodSim)
		Return lRet
	EndIf
	If MV_PAR01 == 1
		dbSelectArea('SGG')
		dbSetOrder(1)
		If dbSeek(xFilial('SGG') + cCodSim, .F.)
			Do While !Eof() .And. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cCodSim
				aAdd(aRecnos, Recno())
				dbSkip()
			EndDo
		EndIf
	Else
		dbSelectArea('SG1')
		dbSetOrder(1)
		If dbSeek(xFilial('SG1') + cCodSim, .F.)
			Do While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodSim
				If lRestEst .And. SB1->(dbSeek(xFilial("SB1")+cCodSim))
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1") + cCodSim))
					If SG1->G1_REVINI <= SB1->B1_REVATU .And. SG1->G1_REVFIM >= SB1->B1_REVATU
						aAdd(aRecnos, Recno())
					EndIf
				Else
					aAdd(aRecnos, Recno())
				EndIf
				dbSkip()
			EndDo
		EndIf
	EndIf
	If Len(aRecnos) > 0
		For nX := 1 to Len(aRecnos)
			If MV_PAR01 == 1
				dbSelectArea('SGG')
			Else
				dbSelectArea('SG1')
			EndIf
			dbGoto(aRecnos[nX])
			//-- Grava o Campo Atual
			aCampos := {}
			For i := 1 To FCount()
				aAdd(aCampos,{FieldGet(i),"GG"+Substr(FieldName(i),3)})
			Next i
			//-- Cria o Novo Registro
			Begin Transaction
				RecLock('SGG', .T.)
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf
				For i:=1 To FCount()
					nAcho:=aScan(aCampos,{|x| x[2] == FieldName(i)})
					If nAcho > 0
						FieldPut(i,aCampos[nAcho,1])
					EndIf
				Next 1
				Replace GG_FILIAL  With xFilial("SGG")
				Replace GG_COD     With cProduto
				Replace GG_STATUS  With "1"
				Replace GG_USUARIO With IIF(!lRestEst,Subs(cUsuario,7,6),RetCodUsr())
				MsUnlock()
			End Transaction
		Next nX
	EndIf
	//-- Restaura a Area de Trabalho
	RestArea(aAreaAnt)
Return lRet


// Seta o Parametro MV_NIVALT para 'S'                       
Static Function a202NivAlt()

	Local aAreaAnt   := GetArea()
	Local lRet       := .F.

	//-- Seta o Parametro para Altera‡Æo de Niveis
	If !(GetMV('MV_NIVALTP')=='S')
		lRet := .T.
		PutMV('MV_NIVALTP','S')
	EndIf

	RestArea(aAreaAnt)

Return lRet


// Cria um Array com os Campos do SGG                         
Static Function A202Fields(aAcho)

	Local aAreaAnt   := GetArea()
	Local aAreaSX3   := {}
	Local lRet       := .T.

	dbSelectArea('SX3')
	aAreaSX3 := GetArea()
	dbSetOrder(1)
	If dbSeek('SGG' + '01', .F.)
		aAcho := {}
		Do While !Eof() .And. X3_ARQUIVO == 'SGG'
			If ! __lPyme .Or. (__lPyme .And. X3_PYME <> "N")
				aAdd(aAcho, X3_CAMPO)
			EndIf
			dbSkip()
		EndDo
	Else
		aAcho := Array(SGG->(fCount()))
		SGG->(aFields(aAcho))
	EndIf

	RestArea(aAreaSX3)
	RestArea(aAreaAnt)

Return lRet


// Faz a explosao de uma Pre-estrutura                        
Static Function Explode(cProduto, aExplode,nCount, oTree)

	Local aAreaAnt   := GetArea()
	Local aAreaSGG   := SGG->(GetArea())
	Local aAreaTRE   := {}
	Local cCod       := cProduto
	Local cSeq       := ''
	Local cComp      := ''
	Local nRecno     := 0
	Local cFilSGG    := xFilial('SGG')

	nCount++
	SGG->(dbSetOrder(1))

	dbSelectArea(oTree:cArqTree)
	aAreaTRE := GetArea()
	dbSetOrder(1)
	dbGoTop()

	Do While !Eof()
		cCod   := Left(T_CARGO, Len(SGG->GG_COD))
		cSeq   := SubStr(T_CARGO, Len(SGG->GG_COD) + 1, Len(SGG->GG_TRT))
		cComp  := SubStr(T_CARGO, Len(SGG->GG_COD + SGG->GG_TRT) + 1, Len(SGG->GG_COMP))
		nRecno := Val(SubStr(T_CARGO,Len(SGG->GG_COD + SGG->GG_TRT + SGG->GG_COMP) + 1, 9))

		If cCod # cProduto
			dbSkip()
			Loop
		EndIf

		If nRecno > 0
			SGG->(dbGoto(nRecno))
		Else
			Exit
		EndIf
		If cCod # cComp
			nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
			If nPos == 0 .And. dDataBase >= SGG->GG_INI .And. dDataBase <= SGG->GG_FIM
				aAdd(aExplode,{nCount, cCod, cComp, SGG->GG_QUANT, cSeq})
			EndIf

			//³ Verifica se existe sub-estrutura                ³
			nRecno := SGG->(Recno())
			If SGG->(dbSeek(cFilSGG+cComp, .F.))
				Explode( SGG->GG_COD, @aExplode, @nCount, oTree)
				nCount --
			Else
				SGG->(dbGoto(nRecno))
				nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
				If nPos == 0 .And. dDataBase >= SGG->GG_INI .And. dDataBase <= SGG->GG_FIM
					aAdd(aExplode,{nCount, cCod, cComp, SGG->GG_QUANT, cSeq})
				EndIf
			Endif
		EndIf
		dbSkip()
	Enddo

	RestArea(aAreaTRE)
	RestArea(aAreaSGG)
	RestArea(aAreaAnt)
Return Nil


// Posiciona sobre o Item desejado na Pre-Estrutura. Esta fun‡„o  cria o  5o  indice  do dbTree , atualizando  a 
// variavel cInd5. Para  tal  assume-se  como  nomes para os 4 primeiros
Static Function Ma202Posic(nOpcX, cCargo, oTree)

	//³ Inicializa Variaveis Locais                                         ³
	Local aAreaAnt   := GetArea()
	Local aAreaTRB   := ''
	Local cComp      := Space(Min(TamSX3('GG_COMP')[1],15))
	Local cOrdem     := ''
	Local cTarget    := ''
	Local cArqTrab   := oTree:cArqTree
	Local nRecno     := 0

	Private cA202ICod := AllTrim(Str(Len(SGG->GG_COD+SGG->GG_TRT)+1))
	Private cA202TCod := AllTrim(Str(Len(SGG->GG_COMP)))

	If Ma202Pesq(@cComp)
		If !Empty(cComp)
			dbSelectArea(cArqTrab)
			aAreaTRB  := GetArea()
			cOrdem    := T_IDCODE
			nRecno    := Recno()
			If cComp==cCodAtual
				dbGoto(1)
				cTarget := T_CARGO
			Else
				//³ Cria o 5o Indice de Trabalho do arquivo dbTree                      ³
				If Empty(cInd5) .Or. !File(cInd5+OrdBagExt())
					cInd5 := CriaTrab('', .F.)
					IndRegua(Alias(),cInd5,'Subs(T_CARGO,'+cA202ICOD+', '+cA202TCOD+')',,,STR0007)
					dbClearIndex()
					dbSetIndex(SubStr(cArqTrab,2)+'A'+OrdBagExt())
					dbSetIndex(SubStr(cArqTrab,2)+'B'+OrdBagExt())
					dbSetIndex(SubStr(cArqTrab,2)+'C'+OrdBagExt())
					dbSetIndex(SubStr(cArqTrab,2)+'D'+OrdBagExt())
					dbSetIndex(cInd5+OrdBagExt())
				EndIf
				dbSetOrder(5)
				dbGoto(nRecno)
				If dbSeek(cComp, .F.)

					//-- Desconsidera a linha do Produto Pai
					If !(Right(T_CARGO,4)=='COMP')
						Do While !Eof() .And. Subs(T_CARGO,Len(SGG->GG_COD+SGG->GG_TRT)+1,Len(SGG->GG_COMP)) == cComp
							If	Right(T_CARGO,4)=='COMP'
								cTarget := T_CARGO
								Exit
							EndIf
							dbSkip()
						EndDo
					Else
						cTarget := T_CARGO
					EndIf

					//-- Caso J  esteja posicionado procura a Pr¢xima ocorrˆncia
					If !Empty(cTarget) .And. T_IDCODE <= cOrdem
						Do While !Eof() .And. Subs(T_CARGO,Len(SGG->GG_COD+SGG->GG_TRT)+1,Len(SGG->GG_COMP)) == cComp
							If Right(T_CARGO,4) == 'COMP' .And. T_IDCODE > cOrdem
								cTarget := T_CARGO
								Exit
							EndIf
							dbSkip()
						EndDo
					EndIf

				EndIf
			EndIf
			//³ Retorna Integridade do Sistema                                      ³
			RestArea(aAreaTRB)
			RestArea(aAreaAnt)

			//-- Posiciona o dbTree sobre o Componente Encontrado
			If !Empty(cTarget)
				oTree:TreeSeek(cTarget)
			Else
				Help(' ',1, 'REGNOIS')
			EndIf
		EndIf
	EndIf

Return .T.



// Pesquisa o codigo e o nome do compnente no Tree            
Static Function Ma202Pesq(cComp)
	Local oDlg
	Local oCbx
	Local oGet
	Local cOrd  := STR0008
	Local aOrd  := {STR0008,STR0017}
	Local lRet  := .F.
	Local lSB1  := .F.
	Local aArea := SB1->(GetArea())

	SB1->(dbSetOrder(3))

	Define MsDialog oDlg From 0,0 To 100,490 Pixel Title OemToAnsi(STR0002)
	@  5, 5 ComboBox oCbx Var cOrd  Items aOrd Size 206,36 Pixel Of oDlg FONT oDlg:oFont Valid ( If(cOrd==STR0017,cComp:=Space(Len(SB1->B1_DESC)),Space(Len(cComp))) )
	@ 22, 5 MsGet    oGet Var cComp Size 206,10 Pixel Valid( Ma202Descr(cOrd,@cComp,@lSB1),If(lSB1,(lRet:=.T.,oDlg:End()),.T.) )
	Define SButton From  5,215 Type 1 Of oDlg Enable Action (lRet:=.T.,oDlg:End())
	Define SButton From 20,215 Type 2 Of oDlg Enable Action oDlg:End()
	Activate MsDialog oDlg Centered

	cComp := If(lRet.And.lSB1,SB1->B1_COD,cComp)

	RestArea(aArea)
Return(lRet)


// Pesquisa a descricao no SB1                                
Static Function Ma202Descr(cOrd,cComp,lSB1)
	Local aAreaAnt := GetArea()
	Local lRet     := .T.
	If cOrd == STR0017
		If !SB1->(dbSeek(xFilial("SB1")+cComp,.T.))
			lSB1  := lRet := ConPad1(,,,"SB1",,, .F.)
			cComp := SB1->B1_DESC
		Else
			lSB1  := .T.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return(lRet)


// FUNCAO ACIONADA NO BOTAO DE CONFIRMACAO DA PRE-ESTRUTURA   
Static Function Btn202Ok(aUndo, c202Cod)
	Local lRet := .T.
	Local aArea := {SGG->(IndexOrd()), SGG->(RecNo()), Alias()}
	If ExistBlock('A202BOK')
		lRet := If(ValType(lRet:=ExecBlock('A202BOK',.F.,.F.,{aUndo, c202Cod}))=='L',lRet,.T.)
		SGG->(dbSetOrder(aArea[1]))
		SGG->(dbGoto(aArea[2]))
		dbSelectArea(aArea[3])
	EndIf
Return(lRet)


// Acrescenta TRT ao prompt do dbtree baseado no conteudo da propriedade cargo 
Static Function A202Prompt(cPrompt, cCargo, nQuant)
	Local cTRT     := Space(Len(SGG->GG_TRT)+3)
	Local cQuant   := " "
	Local aTamQtde := TamSX3("GG_QUANT")
	Default nQuant := 0

	If ! (cCargo == Nil .Or. Empty(cCargo) .Or. Right(cCargo, 4) $ "CODI,NOVO")
		If ! Empty(cTRT := SubStr(cCargo, Len(SGG->GG_COD)+1,Len(SGG->GG_TRT)))
			cTRT := " - " + cTRT
		Endif
		cQuant := " / " + STR0118 + Str(nQuant,aTamQtde[1],aTamQtde[2])
	Endif
Return(Pad(AllTrim(cPrompt) + cTRT + cQuant, Len(cPrompt+cTRT+cQuant)))


// Validacao para digitar a potencia do Lote corretamente      
Static Function A202Potenc()
	LOCAL lRet      := .T.
	LOCAL cCod		:= M->GG_COMP
	LOCAL nPotencia := &(ReadVar())
	If !Rastro(cCod)
		Help(" ",1,"NAORASTRO")
		lRet:=.F.
	Else
		If !PotencLote(cCod)
			Help(" ",1,"NAOCPOTENC")
			lRet:=.F.
		EndIf
	EndIf
Return lRet


// Comparacao de Pre-estruturas                               
User Function BIAFA4EST(cAlias,nRecno,nOpcX)
	Local aArea:=GetArea()
	Local cCodOrig:=Criavar("GG_COMP",.F.),cCodDest:=Criavar("GG_COMP",.F.)
	Local cDescOrig:=Criavar("B1_DESC",.F.),cDescDest:=Criavar("B1_DESC",.F.)
	Local cOpcOrig:=Criavar("C2_OPC",.F.),cOpcDest:=Criavar("C2_OPC",.F.)
	Local dDtRefOrig:=dDataBase,dDtRefDest:=dDataBase
	Local oSay,oSay2
	Local lOk:=.F.

	//³ Funcao utilizada para verificar a ultima versao do fonte		
	//³ SIGACUSB.PRX aplicado no rpo do cliente, assim verificando		
	//| a necessidade de uma atualizacao neste fonte. NAO REMOVER !!!	
	If !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20090204)
		Final(STR0082)	//"Atualizar SIGACUSB.PRX !!!"
	EndIf

	DEFINE MSDIALOG oDlg FROM  140,000 TO 350,670 TITLE OemToAnsi(STR0019) PIXEL
	DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg

	@ 026,006 TO 056,330 LABEL OemToAnsi(STR0020) OF oDlg PIXEL
	@ 062,006 TO 092,330 LABEL OemToAnsi(STR0021) OF oDlg PIXEL

	@ 038,030 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) SIZE 105,09 OF oDlg PIXEL
	@ 038,175 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefOrig) SIZE 40,09 OF oDlg PIXEL
	@ 038,249 MSGET cOpcOrig   When .F. SIZE 65,09 OF oDlg PIXEL
	@ 038,317 BUTTON "?" SIZE 09,11 Action (cOpcOrig:=SeleOpc(4,"BIAFA004",cCodOrig,,,,,,1,dDtRefOrig)) OF oDlg FONT oDlg:oFont PIXEL

	@ 074,030 MSGET cCodDest   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest) SIZE 105,9 OF oDlg PIXEL
	@ 074,175 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefDest) SIZE 40,09 OF oDlg PIXEL
	@ 074,249 MSGET cOpcDest   When .F. SIZE 65,09 OF oDlg PIXEL
	@ 074,317 BUTTON "?" SIZE 09,11 Action (cOpcDest:=SeleOpc(4,"BIAFA004",cCodDest,,,,,,1,dDtRefDest)) OF oDlg FONT oDlg:oFont PIXEL

	@ 048,030 SAY oSay Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
	@ 084,030 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL

	@ 040,009 SAY OemtoAnsi(STR0022) SIZE 24,7  OF oDlg PIXEL
	@ 035,145 SAY OemToAnsi(STR0023) SIZE 35,15 OF oDlg PIXEL
	@ 040,223 SAY OemtoAnsi(STR0024) SIZE 24,7  OF oDlg PIXEL

	@ 075,009 SAY OemToAnsi(STR0022) SIZE 24,7  OF oDlg PIXEL
	@ 072,145 SAY OemToAnsi(STR0023) SIZE 35,15 OF oDlg PIXEL
	@ 075,223 SAY OemtoAnsi(STR0024) SIZE 24,7  OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If(A202COk(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest),(lOk:=.T.,oDlg:End()),lOk:=.F.) },{||(lOk:=.F.,oDlg:End())})

	// Processa comparacao das Pre-estruturas
	If lOk
		Processa({|| A202PrCom(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest) })
	EndIf
	RestArea(aArea)
RETURN


// Valida se pode efetuar a comparacao das pre-estruturas    
Static Function A202COk(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest)
	Local lRet:=.T.
	Local aEstruOrig:={},aEstruDest:={}
	Private nEstru:=0
	// Verifica se todas as informacoes estao iguais
	If cCodOrig+DTOS(dDtRefOrig)+cOpcOrig == cCodDest+DTOS(dDtRefDest)+cOpcDest
		Help('  ',1,'A202COMPIG')
		lRet:=.F.
	EndIf
	If lRet .And. cCodOrig <> cCodDest
		// Verifica se existe item dentro da outra pre-estrutura - NAO PERMITE COMPARAR PARA EVITAR RECURSIVIDADE
		nEstru:=0;aEstruOrig:=Estrut(cCodOrig,1,NIL,.T.)
		nEstru:=0;aEstruDest:=Estrut(cCodDest,1,NIL,.T.)
		If (aScan(aEstruOrig,{|x| x[3] == cCodDest}) > 0) .Or. (aScan(aEstruDest,{|x| x[3] == cCodOrig}) > 0)
			Help('  ',1,'A202COMPES')
			lRet:=.F.
		EndIf
		// Avisa ao usuario sobre produtos diferentes
		If lRet
			Help('  ',1,'A202COMPDF')
		EndIf
	EndIf
Return lRet


// Efetua a comparacao das pre-estruturas                     
Static Function A202PrCom(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest)
	Local aEstruOri:={}
	Local aEstruDest:={}
	Local aSize    := MsAdvSize(.T.)
	Local oDlg,oTree,oTree2,aObjects:={},aInfo:={},aPosObj:={},aButtons:={}

	//³Monta a  tela com o tree da versao base e com o tree da versao³
	//³resultado da comparacao.                                      ³
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
	aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )

	//³Monta array com os conteudos dos tree                                ³
	SGG->(dbSeek(xFilial("SGG")+cCodOrig))
	M202Expl(cCodOrig,dDtRefOrig,cOpcOrig,1,aEstruOri,0)
	SGG->(dbSeek(xFilial("SGG")+cCodDest))
	M202Expl(cCodDest,dDtRefDest,cOpcDest,1,aEstruDest,0)
	//³Iguala os arrays de origem e destino da comparacao                   ³
	Mt202CpAr(aEstruOri,aEstruDest,cCodOrig,cCodDest)

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0019) FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	oTree:= dbTree():New(aPosObj[1,1], aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], oDlg,,,.T.)
	oTree:lShowHint := .F.
	A202TreeCm(oTree,aEstruOri,NIL,NIL)
	oTree2:=dbTree():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], oDlg,,,.T.)
	oTree:lShowHint := .F.
	A202TreeCm(oTree2,aEstruDest,NIL,NIL)
	AAdd( aButtons, { "PMSSETADOWN", { || Mt202Nav(1,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi(STR0025)} ) //"Desce"
	AAdd( aButtons, { "PMSSETAUP"  , { || Mt202Nav(2,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi(STR0026)} ) //"Desce"
	AAdd( aButtons, { "DBG09"      , { || Mt202Inf() }, STR0031 } )
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()} ,{||oDlg:End()},,aButtons)
Return Nil


// Faz a explosao de uma pre-estrutura para comparacao        ³±±
Static Function M202Expl(cProduto,dDataRef,cOpcionais,nQuantPai,aEstru,nNivelEstr)
	LOCAL nReg:=0,nQuantItem:=0,nHistorico:=4

	// Estrutura do array
	// [1] Produto PAI
	// [2] Componente
	// [3] TRT
	// [4] Quantidade
	// [5] Historico
	// [6] Nivel
	// [7] Cargo = [6]+[2]+[3]

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSelectArea("SGG")
	dbSetOrder(1)
	While !Eof() .And. GG_FILIAL+GG_COD == xFilial("SGG")+cProduto
		nReg := Recno()                                                    "
		//³ Calcula a qtd dos componentes                   ³
		nHistorico := 4
		nQuantItem := ExplEstr(nQuantPai,dDataRef,cOpcionais,NIL,@nHistorico,.T.)
		dbSelectArea("SGG")
		SB1->(dbSeek(xFilial("SB1")+SGG->GG_COMP))
		If QtdComp(nQuantItem) < QtdComp(0)
			nQuantItem:=If(QtdComp(RetFldProd(SB1->B1_COD,"B1_QB"))>0,RetFldProd(SB1->B1_COD,"B1_QB"),1)
		EndIf
		AADD(aEstru,{SGG->GG_COD,SGG->GG_COMP,SGG->GG_TRT,nQuantItem,nHistorico,nNivelEstr,StrZero(nNivelEstr,5,0)+SGG->GG_COMP+SGG->GG_TRT})
		//³ Verifica se existe sub-estrutura                ³
		dbSelectArea("SGG")
		If dbSeek(xFilial("SGG")+SGG->GG_COMP)
			nNivelEstr++
			M202Expl(SGG->GG_COD,dDataRef,cOpcionais,nQuantItem,aEstru,nNivelEstr)
			nNivelEstr--
		EndIf
		dbGoto(nReg)
		dbSkip()
	EndDo
Return(.T.)


// Compara e ajusta os arrays de origem e destino     
Static Function Mt202CpAr(aEstruOri,aEstruDest,cCodOrig,cCoddest)
	Local nz:=0,nw:=0,nAcho:=0
	Local cProcura:="",lFirstLevel:=.F.

	// Estrutura do array
	// [1] Produto PAI
	// [2] Componente
	// [3] TRT
	// [4] Quantidade
	// [5] Historico
	// [6] Nivel
	// [7] Cargo = [6]+[2]+[3]

	// Compara os elementos em comum do array
	// Adiciona no array origem os componentes do array destino diferentes
	For nz:=1 To Len(aEstruDest)
		// Verifica se esta no primeiro nivel
		If aEstruDest[nz,6]==0
			lFirstLevel:=.T.
		Else
			lFirstLevel:=.F.
		EndIf
		// Nao procura o produto pai junto
		If lFirstLevel
			cProcura:=aEstruDest[nz,2]+aEstruDest[nz,3]
			// Procura o produto pai junto
		Else
			cProcura:=aEstruDest[nz,1]+aEstruDest[nz,2]+aEstruDest[nz,3]
		EndIf
		// Efetua procura no array origem
		nAcho:=ASCAN(aEstruOri,{|x| x[6] == aEstruDest[nz,6] .And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura)})
		// Caso nao achou soma componentes no array origem com a pre-estrutura do item
		If nAcho == 0
			For nw:=nz to Len(aEstruDest)
				AADD(aEstruOri,{If(lFirstLevel,If(Len(aEstruOri)> 0,aEstruOri[1,1],cCodOrig),aEstruDest[nw,1]),aEstruDest[nw,2],aEstruDest[nw,3],aEstruDest[nw,4],5,aEstruDest[nw,6],aEstruDest[nw,7]})
				// Desliga flag de primeiro nivel
				If lFirstLevel
					lFirstLevel:=.F.
				EndIf
				If nw == Len(aEstruDest) .Or. (aEstruDest[nz,6] == aEstruDest[nw+1,6])
					nz:=nw
					Exit
				EndIf
			Next nw
		EndIf
	Next nz

	// Adiciona no array destino os componentes do array origem diferentes
	For nz:=1 To Len(aEstruOri)
		// Verifica se esta no primeiro nivel
		If aEstruOri[nz,6]==0
			lFirstLevel:=.T.
		Else
			lFirstLevel:=.F.
		EndIf
		// Nao procura o produto pai junto
		If lFirstLevel
			cProcura:=aEstruOri[nz,2]+aEstruOri[nz,3]
			// Procura o produto pai junto
		Else
			cProcura:=aEstruOri[nz,1]+aEstruOri[nz,2]+aEstruOri[nz,3]
		EndIf
		// Efetua procura no array origem
		nAcho:=ASCAN(aEstruDest,{|x| x[6] == aEstruOri[nz,6] .And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura)})
		// Caso nao achou soma componentes no array origem com a pre-estrutura do item
		If nAcho == 0
			For nw:=nz to Len(aEstruOri)
				AADD(aEstruDest,{If(lFirstLevel,If(Len(aEstruDest)> 0,aEstruDest[1,1],cCodDest),aEstruOri[nw,1]),aEstruOri[nw,2],aEstruOri[nw,3],aEstruOri[nw,4],5,aEstruOri[nw,6],aEstruOri[nw,7]})
				// Desliga flag de primeiro nivel
				If lFirstLevel
					lFirstLevel:=.F.
				EndIf
				If nw == Len(aEstruOri) .Or. (aEstruOri[nz,6] == aEstruOri[nw+1,6])
					nz:=nw
					Exit
				EndIf
			Next nw
		EndIf
	Next nz

	// Ordena arrays por nivel
	ASORT(aEstruOri,,,{|x,y| x[7] < y[7] })
	ASORT(aEstruDest,,,{|x,y| x[7] < y[7] })
RETURN(.T.)


// Monta o objeto TREE - FUNCAO RECURSIVA                        
Static Function A202TreeCm(oObjTree,aEstru,cProduto,nz)
	Local nAcho:=0
	Local aOcorrencia :={}
	Local cTexto:=""
	Local cCargoVazio:=Space(5+Len(SGG->GG_COMP+SGG->GG_TRT))
	Default nz:=1
	Default cProduto:=""

	// Ordem de pesquisa por codigo
	SB1->(dbSetOrder(1))

	// Array com as ocorrencias cadastradas
	AADD(aOcorrencia,"PMSTASK4") //"Componente fora das datas inicio / fim"
	AADD(aOcorrencia,"PMSTASK5") //"Componente fora dos grupos de opcionais"
	AADD(aOcorrencia,NIL) //"Componente fora das revisoes" - Nao existe na pre-estrutura
	AADD(aOcorrencia,"PMSTASK6") //"Componente ok"
	AADD(aOcorrencia,"PMSTASK1") //"Componente nao existente"

	// Monta tree na primeira vez
	If Empty(cProduto) .And. Len(aEstru) > 0
		cProduto:=aEstru[1,1]
		oObjTree:BeginUpdate()
		oObjTree:Reset()
		oObjTree:EndUpdate()
		// Coloca titulo no TREE
		SB1->(dbSeek(xFilial("SB1")+aEstru[1,1]))
		oObjTree:AddTree(AllTrim(aEstru[1,1])+" - "+Alltrim(Substr(SB1->B1_DESC,1,30))+Space(40),.T.,,,aOcorrencia[4],aOcorrencia[4],cCargoVazio)
	EndIf

	While nz <= Len(aEstru)
		// Verifica se componente tem pre-estrutura
		nAcho:=ASCAN(aEstru,{|x| x[1] == aEstru[nz,2]})
		// Monta Texto
		SB1->(dbSeek(xFilial("SB1")+aEstru[nz,2]))
		cTexto:=Alltrim(aEstru[nz,2])+" - "+Alltrim(Substr(SB1->B1_DESC,1,30))+Space(40)
		If nAcho > 0
			// Coloca titulo no TREE
			oObjTree:AddTree(cTexto,.T.,,,aOcorrencia[aEstru[nz,5]],aOcorrencia[aEstru[nz,5]],aEstru[nz,7])
			// Chama funcao recursiva
			A202TreeCm(oObjTree,aEstru,aEstru[nz,2],nAcho)
			// Encerra TREE
			oObjTree:EndTree()
		ElseIf aEstru[nz,1] == cProduto
			// Adiciona item no tree
			oObjTree:AddTreeItem(cTexto,aOcorrencia[aEstru[nz,5]],aOcorrencia[aEstru[nz,5]],aEstru[nz,7])
		EndIf
		nz++
	End
RETURN(.T.)


// Mantem o posicionamento das duas pre-estruturas     
Static Function Mt202Nav(nTipo,oTree,oTree2,aEstruOri,aEstruDest)
	Local cCargoAtu  :=oTree2:GetCargo()
	Local cCargoVazio:=Space(5+Len(SGG->GG_COMP+SGG->GG_TRT))
	Local nPos       :=Ascan(aEstruDest,{|x| x[7] == cCargoAtu})

	//³Posiciona o tree na linha de baixo
	If nTipo == 1 .And. nPos < Len(aEstruDest)
		oTree:TreeSeek(aEstruOri[nPos+1,7])
		oTree2:TreeSeek(aEstruDest[nPos+1,7])
		oTree:Refresh()
		oTree2:Refresh()
	ElseIf nTipo == 2 .And. nPos >= 1
		oTree :TreeSeek(If(nPos-1<=0,cCargoVazio,aEstruOri[nPos-1,7]))
		oTree2:TreeSeek(If(nPos-1<=0,cCargoVazio,aEstruDest[nPos-1,7]))
		oTree:Refresh()
		oTree2:Refresh()
	Else
		oTree:TreeSeek(If(nPos>0,aEstruOri[nPos,7],cCargoVazio))
		oTree2:TreeSeek(If(nPos>0,aEstruDest[nPos,7],cCargoVazio))
		oTree:Refresh()
		oTree2:Refresh()
	EndIf
Return(.T.)


// Mt202Inf  ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 05/11/2003 
Static Function Mt202Inf()
	Local oDlg,oBmp1,oBmp2,oBmp3,oBmp4,oBmp5
	Local oBut1
	DEFINE MSDIALOG oDlg TITLE STR0031 OF oMainWnd PIXEL FROM 0,0 TO 202,550
	@ 2,3 TO 080,273 LABEL STR0031 PIXEL //"Legenda"
	@ 18,10 BITMAP oBmp1 RESNAME "PMSTASK1" SIZE 16,16 NOBORDER PIXEL
	@ 18,20 SAY OemToAnsi(STR0030) OF oDlg PIXEL
	@ 18,150 BITMAP oBmp2 RESNAME "PMSTASK6" SIZE 16,16 NOBORDER PIXEL
	@ 18,160 SAY OemToAnsi(STR0029) OF oDlg PIXEL
	@ 30,10 BITMAP oBmp4 RESNAME "PMSTASK5" SIZE 16,16 NOBORDER PIXEL
	@ 30,20 SAY OemToAnsi(STR0028) OF oDlg PIXEL
	@ 42,10 BITMAP oBmp5 RESNAME "PMSTASK4" SIZE 16,16 NOBORDER PIXEL
	@ 42,20 SAY OemToAnsi(STR0027) OF oDlg PIXEL
	DEFINE SBUTTON oBut1 FROM 085,244 TYPE 1  ACTION (oDlg:End())  ENABLE of oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
Return(.T.)


// Substituicao de componentes na Estrutura       
User Function BIAFA4SUB(cAlias,nRecno,nOpcX)
	Local aArea:=GetArea()
	Local cCodOrig:=Criavar("GG_COMP",.F.),cCodDest:=Criavar("GG_COMP",.F.)
	Local cGrpOrig:=Criavar("GG_GROPC",.F.),cGrpDest:=Criavar("GG_GROPC",.F.)
	Local cDescOrig:=Criavar("B1_DESC",.F.),cDescDest:=Criavar("B1_DESC",.F.)
	Local cOpcOrig:=Criavar("GG_OPC",.F.),cOpcDest:=Criavar("GG_OPC",.F.)
	Local oSay,oSay2
	Local lOk:=.F.
	Local aAreaSX3:=SX3->(GetArea())
	//³ Variavel lPyme utilizada para Tratamento do Siga PyME        ³
	Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("GG_OK")
		dbSelectArea("SX3")//manter provisoriamente por causa da mark browse
		dbSetOrder(1) //voltar para indice 1 do sx3
		dbSelectArea("SGG")
		DEFINE MSDIALOG oDlg FROM  140,000 TO 350,670 TITLE OemToAnsi(STR0032) PIXEL
		DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg
		@ 026,006 TO 056,320 LABEL OemToAnsi(STR0033) OF oDlg PIXEL
		@ 062,006 TO 092,320 LABEL OemToAnsi(STR0034) OF oDlg PIXEL
		@ 038,035 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) SIZE 105,09 OF oDlg PIXEL

		If !lPyme
			@ 038,195 MSGET cGrpOrig   F3 "SGA" Picture PesqPict("SGG","GG_GROPC") Valid Vazio(cGrpOrig) .Or. ExistCpo("SGA",cGrpOrig) SIZE 15,09 OF oDlg PIXEL
			@ 038,275 MSGET cOpcOrig   Picture PesqPict("SGG","GG_OPC") Valid IF(!Empty(cGrpOrig),NaoVazio(cOpcOrig).And.ExistCpo("SGA",cGrpOrig+cOpcOrig),Vazio(cOpcOrig)) SIZE 15,09 OF oDlg PIXEL
		EndIf

		@ 074,035 MSGET cCodDest   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest) SIZE 105,9 OF oDlg PIXEL

		If !lPyme
			@ 074,195 MSGET cGrpDest   F3 "SGA" Picture PesqPict("SGG","GG_GROPC") Valid Vazio(cGrpDest) .Or. ExistCpo("SGA",cGrpDest) SIZE 15,09 OF oDlg PIXEL
			@ 074,275 MSGET cOpcDest   Picture PesqPict("SGG","GG_OPC") Valid IF(!Empty(cGrpDest),NaoVazio(cOpcDest).And.ExistCpo("SGA",cGrpDest+cOpcDest),Vazio(cOpcDest)) SIZE 15,09 OF oDlg PIXEL
		EndIf

		@ 048,030 SAY oSay Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
		@ 084,030 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL
		@ 040,013 SAY OemtoAnsi(STR0022)   SIZE 24,7  OF oDlg PIXEL

		If !lPyme
			@ 040,160 SAY RetTitle("GG_GROPC") SIZE 42,13 OF oDlg PIXEL
			@ 040,240 SAY RetTitle("GG_OPC")   SIZE 30,7  OF oDlg PIXEL
		EndIf

		@ 076,013 SAY OemToAnsi(STR0022)   SIZE 24,7  OF oDlg PIXEL

		If !lPyme
			@ 076,160 SAY RetTitle("GG_GROPC") SIZE 42,13 OF oDlg PIXEL
			@ 076,240 SAY RetTitle("GG_OPC")   SIZE 30,7  OF oDlg PIXEL
		EndIf

		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||(lOk:=.T.,oDlg:End())},{||(lOk:=.F.,oDlg:End())})
		// Processa substituicao dos componentes
		If lOk
			Processa({|| A202PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest) })
		EndIf
	Else
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0037),{"Ok"})
	EndIf
	SX3->(RestArea(aAreaSX3))
	RestArea(aArea)
RETURN


// Monta markbowse para selecao e substituicao dos componentes
Static Function A202PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
	Local cFilSGG     := ""
	Local cQrySGG     := ""
	Local aIndexSGG   := {}
	Local aBackRotina := ACLONE(aRotina)
	Local lRet        := .T.
	//³ Variavel lPyme utilizada para Tratamento do Siga PyME        ³
	Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

	PRIVATE aDadosDest:= {cCodDest,cGrpDest,cOpcDest}
	PRIVATE cMarca202 := ThisMark()
	PRIVATE bFiltraBrw
	PRIVATE cCadastro := OemToAnsi(STR0032)
	PRIVATE aRotina   := {  {STR0035,"A202DoSub", 0 , 1}}

	If (Empty(cCodOrig) .Or. Empty(cCodDest))
		Help(" ",1,"A202OBRIG")
		lRet:=.F.
	EndIF

	If lRet
		cFilSGG := "GG_FILIAL='"+xFilial("SGG")+"'"
		cFilSGG += ".And.GG_COMP=='"+cCodOrig+"'"

		If lRestEst
			cFilSGG += ".And.GG_STATUS <> '5'"
			cFilSGG += ".And.GrpEng('" +RetCodUsr() +"',SGG->GG_USUARIO)"
		EndIf

		If !lPyme
			cFilSGG += ".And.GG_GROPC=='"+cGrpOrig+"'"
			cFilSGG += ".And.GG_OPC=='"+cOpcOrig+"'"
		EndIf

		If SB5->(FieldPos("B5_PROTOTI")) > 0
			If(FindFunction('IsProdProt'))
				If !IsProdProt(cCodOrig) .And. !IsProdProt(cCodDest)
					cFilSGG += " .And. .T. "
				Else
					cFilSGG += " .And. .F. "
				Endif
			Else
				cFilSGG += " .And. .T. "
			Endif			
		EndIf

		cQrySGG := "SGG.GG_FILIAL='"+xFilial("SGG")+"'"
		cQrySGG += " AND SGG.GG_COMP='"+cCodOrig+"'"
		If lRestEst
			cQrySGG += " AND GG_STATUS<>'5'"
		EndIf

		If !lPyme
			cQrySGG += " AND SGG.GG_GROPC='"+cGrpOrig+"'"
			cQrySGG += " AND SGG.GG_OPC='"+cOpcOrig+"'"
		EndIf

		If SB5->(FieldPos("B5_PROTOTI")) > 0
			cQrySGG += " AND (SELECT COUNT(SB5.*) FROM " +RetSQLName("SB5") +" SB5 WHERE SB5.D_E_L_E_T_ <> '*' AND "
			cQrySGG += "SB5.B5_FILIAL = '" +xFilial("SB5") +"' AND B5_COD = SGG.GG_COD AND SB5.B5_PROTOTI = 'F') = 0"
		EndIf

		//³Realiza a Filtragem                                                     ³
		dbSelectArea("SGG")
		dbSetOrder(1)
		bFiltraBrw := {|x| If(x==Nil,FilBrowse("SGG",@aIndexSGG,@cFilSGG),{cFilSGG,cQrySGG,"","",aIndexSGG}) }
		Eval(bFiltraBrw)

		dbSelectArea("SGG")
		If !MsSeek(xFilial("SGG"))
			HELP(" ",1,"RECNO")
		Else
			//³Monta o browse para a selecao                                           ³
			MarkBrow("SGG","GG_OK")
		EndIf

		//³Restaura condicao original                                              ³
		dbSelectArea("SGG")
		RetIndex("SGG")
		dbClearFilter()
		aEval(aIndexSGG,{|x| Ferase(x[1]+OrdBagExt())})
		aRotina:=ACLONE(aBackRotina)
	EndIf
Return Nil


// A202DoSub   ³ Autor ³Rodrigo de A Sartorio³ Data ³23.07.2004
Static Function A202DoSub(cAlias,cCampo,nOpc,cMarca202,lInverte)
	Local aRecnosSGG:={}
	Local nz:=0
	dbSelectArea("SGG")
	dbSeek(xFilial("SGG"))
	While !Eof() .And. GG_FILIAL == xFilial("SGG")
		// Verifica os registros marcados para substituicao
		If IsMark("GG_OK",cMarca202,lInverte)
			AADD(aRecnosSGG,Recno())
		EndIf
		dbSkip()
	End
	// Grava a substituicao de componentes
	#IFDEF TOP
	If !("DB2" $ TCGetDB())
		cQuery := "UPDATE "
		cQuery += RetSqlName("SGG")+" "
		cQuery += "SET GG_COMP = '"+aDadosDest[1]+"' , GG_GROPC = '"+aDadosDest[2]+"' , GG_OPC = '"+aDadosDest[3]+"'"
		cQuery += " WHERE GG_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ IN ("
		For nz:=1 to Len(aRecnosSGG)
			If nz > 1
				cQuery+= ","
			EndIf
			cQuery+= "'"+Str(aRecnosSGG[nz],10,0)+"'"
		Next nz
		cQuery += ")"
		TcSqlExec(cQuery)
	Else
		#ENDIF

		For nz:=1 to Len(aRecnosSGG)
			dbGoto(aRecnosSGG[NZ])
			Reclock("SGG",.F.)
			Replace GG_COMP  With aDadosDest[1]
			Replace GG_GROPC  With aDadosDest[2]
			Replace GG_OPC    With aDadosDest[3]
			Replace GG_STATUS With '1'
			MsUnlock()
		Next nz

		#IFDEF TOP
	EndIf
	#ENDIF

	#IFDEF TOP
	If lRestEst
		For nz:=1 to Len(aRecnosSGG)
			SGG->(dbGoto(aRecnosSGG[NZ]))
			Reclock("SGG",.F.)
			Replace GG_STATUS With '1'
			MsUnlock()
		Next nz
	EndIf
	#ENDIF

	// Altera conteudo do parametro de niveis
	If Len(aRecnosSGG) > 0
		a202NivAlt()
	EndIf
RETURN


// Demonstra a legenda das cores da mbrowse                     
User Function BIAFA4LEG()

	Local aCores := {}
	Local aLegUsr  := {}
	Local nCnt     := 0

	aAdd(aCores,{"BR_AMARELO"	,STR0052})
	aAdd(aCores,{"BR_VERDE"		,STR0053})
	aAdd(aCores,{"BR_VERMELHO"  ,STR0054})
	aAdd(aCores,{"BR_AZUl"		,STR0055})
	If(SuperGetMv('MV_APRESTR',.F.,.F.),aAdd(aCores,{"BR_LARANJA"	,STR0083}),"")

	//³ Ponto de Entrada para adicionar legendas na Dialog           ³
	If ExistBlock("MT202LEG")
		aLegUsr := ExecBlock("MT202LEG",.F.,.F., { 2 })
		If ValType(aLegUsr) <> "A"
			aLegUsr := {}
		EndIf
		For nCnt := 1 To Len(aLegUsr)
			Aadd( aCores , { aLegUsr[nCnt,1],aLegUsr[nCnt,2] } )
		Next nCnt
	EndIf

	BrwLegenda(cCadastro,STR0031,aCores)

Return (.T.)


// Grava o status de aprovacao / rejeicao nos itens da pre-estr 
Static Function A202Aprova(cProduto,nOkAceRj,nValPre)
	Local cAlias  := Alias()
	Local cNomeArq   := ""
	Private	nEstru:=0
	cNomeArq := Estrut2(cProduto,NIL,NIL,NIL,NIL,.T.)
	dbSelectArea('ESTRUT')
	ESTRUT->(dbGotop())
	ProcRegua(Lastrec())
	Do While !ESTRUT->(Eof())
		IncProc()
		// Caso tenha aceitado somente primeiro nivel valida
		If nOkAceRj == 2 .And. Val(ESTRUT->NIVEL) > 1
			ESTRUT->(dbSkip())
			Loop
		EndIf
		SGG->(dbGoto(ESTRUT->REGISTRO))
		Reclock("SGG",.F.)
		//³ Definicao dos status da pre-estrutura para controle de alcada³
		//³ ------------- Status da pre-estrutura sao: -------------     ³
		//³ 1 - Em criacao					                             ³
		//³ 2 - Pre-estrutura aprovada                                   ³
		//³ 3 - Pre-estrutura rejeitada			                         ³
		//³ 4 - Estrutura criada							             ³
		//³ 5 - Submetida a aprovacao                                    ³
		If nValPre == 1
			Replace GG_STATUS With "2"
			// Grava rejeicao
		ElseIf nValPre == 2
			Replace GG_STATUS With "3"
		EndIf
		Replace GG_USUARIO With IIF(!lRestEst,Subs(cUsuario,7,6),RetCodUsr())
		MsUnlock()
		ESTRUT->(dbSkip())
	EndDo
	FimEstrut2(Nil,cNomeArq)
	dbSelectArea(cAlias)

	If nValPre == 1
		If ExistBlock ("MTA202APROV")
			ExecBlock ("MTA202APROV",.F.,.F.,{cProduto})
		Endif
	EndIf

RETURN


// Valida o codigo destino da estrutura                         
Static Function A202CodDes(cNomePai)
	Local lRet:=ExistCpo("SB1",cNomePai)
	SG1->(dbSetOrder(1))
	If lRet
		If SG1->(dbSeek(xFilial("SG1")+cNomePai))
			Aviso(OemToAnsi(STR0036),STR0080,{"Ok"})
		EndIf
	EndIf
Return lRet


// Chama a funcao de gravacao atraves da processa para regua    
Static Function A202PrG1(cProduto,nNivelCal,nTipoItens,nTipoData,dDataIni,dDataFim,nTipoSobre,nTipoApaga,lMudaNome,cNomePai)
	Processa({|| A202GravG1(cProduto,nNivelCal,nTipoItens,nTipoData,dDataIni,dDataFim,nTipoSobre,nTipoApaga,lMudaNome,cNomePai) })
Return .T.


// Grava preestrutura como estrutura                            
Static Function A202GravG1(cProduto,nNivelCal,nTipoItens,nTipoData,dDataIni,dDataFim,nTipoSobre,nTipoApaga,lMudaNome,cNomePai)
	Local cAlias   := Alias()
	Local cNomeArq := ""
	Local lAchouCod:= .F.
	Local cCodiSeek:= ""
	Local nx       :=0
	Local nISGG    :=0
	Local cNomeCamp:=0
	Local nPosicao :=0
	Local aCodiSeek:={}
	Local aNomePos :={}
	Local aRegsSGG :={}
	Local lIntSFC	 := FindFunction('IntegraSFC') .And. IntegraSFC()
	Local lGravouSG1:=.F.
	Local lQBase   :=.T.
	Local cAliasB1BZ := If(GetMv('MV_ARQPROD')=="SBZ","SBZ","SB1")
	Local aAliasAnt := {}
	Local cCpoDest := If(cAliasB1BZ=="SBZ" .And. SBZ->(FieldPos("BZ_QB"))>0,"BZ_QB","B1_QB")
	Local lRevAut  := SuperGetMv("MV_REVAUT",.F.,.F.)
	Local lArqRev  := .F.
	Local cRevIni  := CriaVar("G1_REVINI")
	Local cRevFim  := CriaVar("G1_REVFIM")
	Local cProPai  := ""

	Private	nEstru := 0

	//³Carrega perguntas do MTA200 e MATA202                                   ³
	Pergunte("MTA200", .F.)
	lArqRev := MV_PAR02 == 1
	Pergunte('MTA202', .F.)

	// Muda ordem Codigo + Componente
	SG1->(dbSetOrder(1))
	// Cria arquivo de trabalho com a estrutura completa
	cNomeArq := Estrut2(cProduto,NIL,NIL,NIL,NIL,.T.)
	// Percorre arquivo para atualizar estrutura
	dbSelectArea('ESTRUT')
	ESTRUT->(dbGotop())
	ProcRegua(Lastrec())
	Begin Transaction
		Do While !ESTRUT->(Eof())
			IncProc()
			// Caso tenha aceitado somente primeiro nivel valida
			If nNivelCal == 2 .And. Val(ESTRUT->NIVEL) > 1
				ESTRUT->(dbSkip())
				Loop
			EndIf
			SGG->(dbGoto(ESTRUT->REGISTRO))
			/* Caso o paramento MV_APRESTR esteja habilitado somente devera ser gerado a estrutura para aquelas que foram
			aprovadas pelo grupo de aprovavao do controle de alcada */
			If (lRestEst .And. SGG->GG_STATUS <> "2")
				ESTRUT->(dbSkip())
				Loop
			EndIf
			// Verifica o tipo de item a ser considerado
			If (nTipoItens == 1 .And. SGG->GG_STATUS <> "2") .Or. (nTipoItens == 2 .And. SGG->GG_STATUS <> "3")
				dbSkip()
				Loop
			EndIf
			// Valida data com database
			If nTipodata == 2 .And. ((dDataBase < SGG->GG_INI)  .Or. (dDataBase > SGG->GG_FIM))
				dbSkip()
				Loop
			EndIf
			// Valida data com data de parametros
			If nTipodata == 3 .And. ((SGG->GG_INI < dDataIni)  .Or. (SGG->GG_INI > dDataFim))
				dbSkip()
				Loop
			EndIf
			dbSelectArea("SG1")
			// Verifica qual o nome a ser alterado
			If lMudaNome .And. !Empty(cNomePai) .And. Val(ESTRUT->NIVEL) == 1
				cCodiSeek:=cNomePai
			Else
				cCodiSeek:=SGG->GG_COD
			EndIf
			lAchouCod:=dbSeek(xFilial("SG1")+cCodiSeek)
			// Processa gravacao se nao achou codigo ou se permite sobreposicao
			If nTipoSobre == 1 .Or. (nTipoSobre == 2 .And. !lAchouCod)
				lGravouSG1:=.T.
				// Sobrepoe estrutura caso necessario
				If lAchouCod .And. !(lRevAut .And. lArqRev)
					While !EOF() .And. 	xFilial("SG1")+cCodiSeek == G1_FILIAL+G1_COD
						Reclock("SG1",.F.)
						dbDelete()
						MsUnlock()
						dbSkip()
					End
				EndIf
				// Array com caracteristicas de campo
				// Criado para acelerar o processo evitando fieldpos e fieldname a todo momento
				If Len(aNomePos) == 0
					For nx:=1 to SGG->(FCount())
						cNomeCamp:="G1_"+Substr(SGG->(FieldName(nx)),4)
						nPosicao :=SG1->(FieldPos(cNomeCamp))
						// Grava todos os campos de SGG (mesmo nao existindo em SG1)
						// Array com
						// 1 Nome do campo no SG1
						// 2 Posicao do campo no SG1
						// 3 Posicao do campo no SGG
						Aadd(aNomePos,{cNomecamp,nPosicao,nx})
					Next nx
				EndIf
				//³ Carrega as informacoes do registro SGG 				            ³
				nISGG++
				Aadd(aCodiSeek,cCodiSeek)
				Aadd(aRegsSGG,Array(SGG->(FCount())))
				For nx:=1 to SGG->(FCount())
					aRegsSGG[nISGG,nx] := SGG->(FieldGet(nx))
				Next
				// Grava status atualizado
				Reclock("SGG",.F.)
				If lMudaNome .And. !Empty(cNomePai) .And. Val(ESTRUT->NIVEL) == 1
					// Novo codigo do produto
					Replace GG_COD With cNomePai
				EndIf
				Replace GG_STATUS With "4"
				Replace GG_USUARIO With IIF(!lRestEst,Subs(cUsuario,7,6),RetCodUsr())
				If nTipoApaga == 1
					dbDelete()
				EndIf
				MsUnlock()
				// Grava qtd base no SB1
				If Val(ESTRUT->NIVEL) == 1 .And. lQBase
					aAliasAnt := GetArea()
					dbSelectArea(cAliasB1BZ)
					(cAliasB1BZ)->(dbSetOrder(1))
					If (cAliasB1BZ)->(dbSeek(xFilial(cAliasB1BZ)+SGG->GG_COD))
						If Substr(cCpoDest,1,2) == "B1"
							SB1->(dbSeek(xFilial("SB1")+SGG->GG_COD))
						EndIf
						Reclock(If(cCpoDest=="BZ_QB","SBZ","SB1"),.F.)
						If cAliasB1BZ == "SBZ"
							Replace &(cCpoDest) With If(SBZ->(FieldPos("BZ_QBP"))>0,SBZ->BZ_QBP,1)
						Else
							Replace &(cCpoDest) With If(SB1->(FieldPos("B1_QBP"))>0,SB1->B1_QBP,1)
						EndIf
						MsUnlock()
					Else
						SB1->(dbSeek(xFilial("SB1")+SGG->GG_COD))
						RecLock("SB1",.F.)
						If FieldPos("B1_QBP") > 0
							Replace SB1->B1_QB With SB1->B1_QBP
						Else
							Replace SB1->B1_QB With 1
						EndIf
						MsUnLock()
					EndIf
					lQBase:=.F.
					RestArea(aAliasAnt)
				EndIf
			EndIf
			dbSelectArea('ESTRUT')
			dbSkip()
		EndDo
		If lGravouSG1
			//³ Le as informacoes dos registros de SGG contidas no array e      ³
			//³ grava as mesmas no arquivo SG1                                  ³
			For nISGG:=1 to Len(aRegsSGG)
				IF (lRevAut .And. lArqRev)
					IF cProPai <> 	aCodiSeek[nISGG]
						cRevFim  := A200Revis(aCodiSeek[nISGG],.F.)
						cRevIni  := cRevFim
					EndIf
					cProPai := aCodiSeek[nISGG]
				EndIf
				dbSelectArea("SG1")
				cCodiSeek := aCodiSeek[nISGG]
				Begin Transaction
					If !dbSeek(xFilial("SG1")+cCodiSeek+aRegsSGG[nISGG,3]+aRegsSGG[nISGG,4])
						Reclock("SG1",.T.)
						For nx:=1 to Len(aNomePos)
							If aNomePos[nx,2] > 0  // Verifica se campo existe em SG1
								FieldPut(aNomePos[nx,2],aRegsSGG[nISGG,nx])
							EndIf
						Next nx
						// Grava informacoes especificas
						// Filial
						G1_FILIAL := xFilial("SG1")
						G1_COD	  := cCodiSeek		//Incluido para nao gerar erro se o codigo do pai for alterado
						Replace G1_REVINI With cRevIni
						Replace G1_REVFIM With cRevFim
					Else
						Reclock("SG1",.F.)
						Replace G1_REVFIM With cRevFim
						If lRestEst
							Replace G1_QUANT With aRegsSGG[nISGG,5]
						EndIf
					EndIf
					MsUnlock()
					If lIntSFC
						A200IntSFC(aCodiSeek[nISGG],'2')
					EndIf
				End Transaction
			Next
			// Atualiza parametro para recalcular nivel das estruturas
			a200NivAlt()
		EndIf
	End Transaction
	FimEstrut2(Nil,cNomeArq)
	dbSelectArea(cAlias)

	If ExistBlock ("MTA202CRIA")
		ExecBlock ("MTA202CRIA",.F.,.F.,{cProduto,cNomePai})
	Endif

RETURN .T.


// Utilizacao de menu Funcional                               
Static Function MenuDef(lRestEst)

	Private aRotina	 := {}
	Default lRestEst := .F.

	aAdd(aRotina, { OemToAnsi("Pesquisar")             , 'AxPesqui' 	, 0, 1, 0, .F.})   
	aAdd(aRotina, { OemToAnsi("Visualizar")            , 'U_BIAFA4PR' 	, 0, 2, 0, nil})    
	aAdd(aRotina, { OemToAnsi("Incluir")    	       , 'U_BIAFA4PR' 	, 0, 3, 0, nil})    
	aAdd(aRotina, { OemToAnsi("Alterar")		       , 'U_BIAFA4PR' 	, 0, 4, 0, nil})    
	aAdd(aRotina, { OemToAnsi("Excluir")		       , 'U_BIAFA4PR' 	, 0, 5, 0, nil})    
	aAdd(aRotina, { OemToAnsi("Ajt Qtd Variáveis")     , 'U_BIAFA4InV'  , 0, 6, 0, nil})  
	aAdd(aRotina, { OemToAnsi("Ajt Qtd p/ Componente") , 'U_BIA750'     , 0, 7, 0, nil})  
	aAdd(aRotina, { OemToAnsi("Legenda")	           , 'U_BIAFA4LEG'  , 0, 8, 0, .F.})    

	If ExistBlock ("MTA202MNU")
		ExecBlock ("MTA202MNU",.F.,.F.)
	Endif

Return (aRotina)

// Consiste a Quantidade Basica da Estrutura                  
Static Function A202QBase(nQtdBase, nOpcX, cProduto, cCodSim, oTree, oDlg)

	Local lRet := .T.
	If QtdComp(nQtdBase) < QtdComp(0) .And. !GetMV('MV_NEGESTR')
		Help(' ',1,'MA200QBNEG')
		lRet := .F.
	EndIf

	If lRet
		nQtdBasePai := M->G1_QUANT := nQtdBase

		If !ldbTree
			ldbTree := .T.
			If nOpcX < 5
				cCodAtual := cProduto
				Ma202Monta(oTree, oDlg, cCodAtual, cCodSim,nOpcX)
				oTree:TreeSeek(oTree:GetCargo())
			EndIf
		EndIf
	EndIf

Return lRet

// Programa de visualiza‡ao da pre-estrutura				  
User Function A202Log(cAlias,nRecno)

	Local aAreaAnt  := GetArea()
	Local aHeadCols := {STR0098,STR0091,STR0100,STR0101,STR0102,STR0103}
	Local aHeadSize := {30,20,40,100,38,100}
	Local cTitle    := STR0104 +AllTrim(SGG->GG_COD)
	Local cTipoLib  := ""
	Local cStatus	:= ""
	Local aBrowse   := {}
	Local lRet		:= .F.

	If !(GrpEng(RetCodUsr(),SGG->GG_USUARIO))
		Aviso(OemToAnsi(STR0105),STR0106,{"Ok"})
		RETURN
	EndIf

	SGG->(dbSetOrder(1))
	SGG->(dbGoto(nRecno))

	dbSelectArea("SGN")
	dbSetOrder(1)
	If dbSeek(xFilial("SGN")+"SGG"+SGG->GG_COD)
		Do While !SGN->(Eof()) .And. SGN->GN_FILIAL+SGN->GN_TIPO+SGN->GN_NUM == xFilial("SGN")+"SGG"+	SGG->GG_COD
			Do Case
				Case SGN->GN_TIPOLIB == 'U'
				cTipoLib := STR0090
				Case SGN->GN_TIPOLIB == 'N'
				cTipoLib := STR0091
				Case SGN->GN_TIPOLIB == 'E'
				cTipoLib := STR0092
			EndCase

			Do Case
				Case SGN->GN_STATUS = '01'
				cStatus = STR0107
				Case SGN->GN_STATUS = '02'
				cStatus = STR0108
				Case SGN->GN_STATUS = '03'
				cStatus = STR0109
				Case SGN->GN_STATUS = '04'
				cStatus = STR0110
				Case SGN->GN_STATUS = '05'
				cStatus = STR0111
				Case SGN->GN_STATUS = '06'
				cStatus = STR0112
				Case SGN->GN_STATUS = '07'
				cStatus = STR0113
				Case SGN->GN_STATUS = '08'
				cStatus = STR0114
			EndCase
			aAdd(aBrowse, {UsrRetName(SGN->GN_USER),SGN->GN_NIVEL,cTipoLib,cStatus,SGN->GN_DATALIB,SGN->GN_OBS})
			SGN->(dbSkip())
		EndDo
	Else
		Aviso(OemToAnsi(STR0036),OemToAnsi(STR0089),{"Ok"})
		lRet := .T.
	EndIf

	If !lRet
		DEFINE MSDIALOG oDialog FROM 000,000 TO 300,980 TITLE cTitle OF oMainWnd PIXEL

		oBrowse := TWBrowse():New(01,01,500,150,,aHeadCols,aHeadSize,oDialog,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.F.,.T.)
		oBrowse:SetArray(aBrowse)
		oBrowse:bLine := { || aBrowse[oBrowse:nAT] }

		ACTIVATE MSDIALOG oDialog CENTERED
	EndIf
	RestArea(aAreaAnt)

Return

Static Function A202CriSGN(cProduto,cUsuario,cGrupoEng,lTodosNiv)

	Local aArea    := GetArea()
	Local aAreaSGG := SGG->(GetArea())

	//-- Deleta aprovacao anterior caso rejeitada
	A202DelSGN(cProduto,.T.)

	//-- Gera registro p/ aprovacao e chama recursivo para outros niveis
	If SGG->(dbSeek(xFilial("SGG")+cProduto))
		MaAlcEng({PADR(cProduto,30),"SGG",cUsuario,cGrupoEng,""},,1)
		While !SGG->(EOF()) .And. SGG->(GG_FILIAL+GG_COD) == xFilial("SGG")+cProduto
			//Atualiza status
			RecLock('SGG',.F.)
			Replace GG_STATUS With "5"
			MsUnlock()

			If lTodosNiv
				A202CriSGN(SGG->GG_COMP,cUsuario,cGrupoEng)
			EndIf

			SGG->(dbSkip())
		End
	EndIf

	RestArea(aAreaSGG)
	RestArea(aArea)

Return


// Funcao recursiva para exluir as pre-estruturas que foram rejeitadas.
Static Function A202DelSGN(cChave,lSubmit)

	Local aArea   := GetArea()
	Local aAreaSGG := SGG->(GetArea())

	Default cChave  := SGG->GG_COD
	Default lSubmit := .F.

	If SGG->(dbSeek(xFilial("SGG")+cChave)) .And. SGG->GG_STATUS <> If(lSubmit,'2','3')
		SGN->(dbSetOrder(1))
		SGN->(dbSeek(xFilial("SGN")+"SGG"+cChave))
		While !SGN->(EOF()) .And. SGN->(GN_FILIAL+GN_TIPO+GN_NUM) == xFilial("SGN")+"SGG"+cChave
			If SGN->GN_STATUS == '04' .Or. SGG->GG_STATUS == '1'
				SGN->(dbSeek(xFilial("SGN")+"SGG"+cChave))
				While !SGN->(EOF()) .And. SGN->(GN_FILIAL+GN_TIPO+GN_NUM) == xFilial("SGN")+"SGG"+cChave
					Reclock("SGN",.F.)
					SGN->(dbDelete())
					SGN->(MsUnlock())
					SGN->(dbSkip())
				End
				Exit
			EndIf
			SGN->(dbSkip())
		End
	EndIf

	RestArea(aAreaSGG)
	RestArea(aArea)

Return

//Perguntas
Static Function fPergunte()

	local cLoad	    	:= "BIAFA004" + cEmpAnt
	local cFileName 	:= RetCodUsr() +"_"+ cLoad
	local lRet			:= .F.
	local aTipos 		:= {"1=Por Data", "2=Todos"} 
	local aPergs		:= {}
	_dDataRef 			:= stod('')
	_cModExib 			:= "1"

	aAdd( aPergs ,{1,"Data de Referência? " ,_dDataRef ,'','.T.','','.T.',60,.F.})	
	aAdd( aPergs ,{2,"Modo de Exibição?" 	,_cModExib ,aTipos,60,'.T.',.F.})

	If ParamBox(aPergs ,"Parâmetros",,,,,,,,cLoad,.T.,.T.)  

		lRet := .T.
		_dDataRef := ParamLoad(cFileName,,1,_dDataRef) 
		_cModExib := ParamLoad(cFileName,,2,_cModExib) 

		if empty(_dDataRef) 
			_dDataRef := dDataBase
		endif  

		dDataBase := _dDataRef		
	endif

	If INCLUI .OR. Altera
		lRet := fValOrca(_dDataRef) 
		If lRet 
			If Substr(DtoS(_dDataRef),1,6) < Substr(DtoS(Date()),1,6)   
				MsgInfo("Não será permitida a alteração de estruturas orçamentárias cuja data seja menor ou igual ao mês corrente!")
				lRet	:= .F.
			EndIf
		EndIf
	EndIF

	If lRet
		Pergunte('MTA202', .F.)
	EndIf
return lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidIEPerg ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 19/05/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidIEPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Ano Orçamentário         ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIAFA4InV    ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 11/10/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAFA4InV(cAlias, nRecno, nOpcX)

	Local _dhs
	Local iaEnter := CHR(13) + CHR(10)
	Local M001      := GetNextAlias()
	Local M002      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIAFA4INV"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidInVPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco e menor ou igual a DataBase" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
	SELECT COUNT(*) CONTAD
	FROM %TABLE:ZB5% ZB5
	WHERE ZB5_FILIAL = %xFilial:ZB5%
	AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
	AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
	AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
	AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
	AND ZB5.ZB5_STATUS = 'A'
	AND ZB5.ZB5_DTDIGT <> ''
	AND ZB5.ZB5_DTCONS <> ''
	AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
	AND ZB5.ZB5_DTENCR = ''
	AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())	

	BeginSql Alias M002
	SELECT *
	FROM %TABLE:ZBR% ZBR
	WHERE ZBR_FILIAL = %xFilial:ZBR%
	AND ZBR.ZBR_VERSAO = %Exp:_cVersao%
	AND ZBR.ZBR_REVISA = %Exp:_cRevisa%
	AND ZBR.ZBR_ANOREF = %Exp:_cAnoRef%
	AND ZBR.%NotDel%
	ORDER BY ZBR_VERSAO, ZBR_REVISA, ZBR_ANOREF, ZBR_COD, ZBR_COMP
	EndSql
	(M002)->(dbGoTop())

	If (M002)->(!Eof())

		While (M002)->(!Eof())

			fgCodigo := (M002)->ZBR_COD

			UP003 := " DELETE " + RetSqlName("SGG") + " "
			UP003 += "  WHERE GG_FILIAL = '" + xFilial("SGG") + "' "
			UP003 += "    AND GG_COD = '" + (M002)->ZBR_COD + "' "
			//UP003 += "    AND GG_COMP = '" + (M002)->ZBR_COMP + "' "
			UP003 += "    AND '" + _cAnoRef + "0131' <= GG_INI "
			UP003 += "    AND '" + _cAnoRef + "1231' >= GG_FIM "
			UP003 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros... ",,{|| TcSqlExec(UP003) })

			While (M002)->(!Eof()) .and. fgCodigo == (M002)->ZBR_COD

				For _dhs := 1 to 12

					If (M002)->&("ZBR_M" + StrZero(_dhs,2)) <> 0

						msDiaMes := stod(_cAnoRef + StrZero(_dhs,2) + "01")
						msDiaMes := Ultimodia(msDiaMes) 
						msObserv  := "Data Ajt Ind: " + dtoc(dDataBase) + ", Data Strut: " + dtoc(msDiaMes)

						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1") + (M002)->ZBR_COD))
						Reclock("SGG",.T.)
						SGG->GG_FILIAL  := xFilial("SGG")
						SGG->GG_COD     := (M002)->ZBR_COD
						SGG->GG_COMP    := (M002)->ZBR_COMP
						SGG->GG_TRT     := (M002)->ZBR_TRT
						SGG->GG_QUANT   := (M002)->&("ZBR_M" + StrZero(_dhs,2))
						SGG->GG_PERDA   := (M002)->&("ZBR_P" + StrZero(_dhs,2))
						SGG->GG_INI     := msDiaMes
						SGG->GG_FIM     := msDiaMes
						SGG->GG_OBSERV  := msObserv
						SGG->GG_FIXVAR  := 'V'
						SGG->GG_GROPC   := ''
						SGG->GG_OPC     := ''
						SGG->GG_NIV     := ''
						SGG->GG_NIVINV  := ''
						SGG->GG_POTENCI := 0
						SGG->GG_OK      := ''
						SGG->GG_STATUS  := '1'
						SGG->GG_USUARIO := Substr(cUserName,1,6)
						SGG->GG_REVINI  := (M002)->ZBR_REVINI
						SGG->GG_REVFIM  := (M002)->ZBR_REVFIM
						SGG->GG_TIPVEC  := ''
						SGG->GG_VECTOR  := ''
						If SB1->B1_TIPO = 'PI'
							SGG->GG_YMISTUR := (M002)->&("ZBR_M" + StrZero(_dhs,2)) * 100
						EndIf
						SGG->(MsUnlock())

					EndIf

				Next _dhs

				(M002)->(dbSkip())

			End

		End

	EndIf

	(M002)->(dbCloseArea())

	MsgINFO("Fim do Processamento...")	

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidInVPerg ¦ Autor ¦ Marcos Alberto S ¦ Data ¦ 11/10/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidInVPerg()

	local i,j
	_sAlias := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária      ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa            ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência        ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	RestArea(_sAlias)

	Return

	Static Functio fValOrca(_dDataRef)

	Local _cAlias	:=	GetNextAlias()
	Local _cAnoRef	:=	Substr(DtoS(_dDataRef),1,4)
	Local _lRet	:=	.T.


	BeginSql Alias _cAlias
	SELECT COUNT(*) QTD
	FROM %TABLE:ZB5% ZB5
	WHERE ZB5.ZB5_FILIAL = %XFILIAL:ZB5%
	AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
	AND ZB5.ZB5_STATUS = 'A'
	AND ZB5.ZB5_TPORCT = 'C.VARIAVEL'
	AND ZB5.ZB5_REVISA = (SELECT MAX(ZB5_REVISA)
	FROM %TABLE:ZB5% ZB5REV
	WHERE ZB5REV.ZB5_FILIAL = %XFILIAL:ZB5%
	AND ZB5REV.ZB5_ANOREF = %Exp:_cAnoRef%
	AND ZB5REV.ZB5_TPORCT = 'C.VARIAVEL'
	AND ZB5REV.%NotDel%)
	AND ZB5.%NotDel%
	EndSql

	_lRet	:=	(_cAlias)->QTD > 0

	If  !GETMV("MV_YLIBSGG")
		If !_lRet
			MsgInfo("Não existe orçamento em aberto para o período informado!")
		EndIf
	Else
		_lret	:=	.T.
	EndIf


	(_cAlias)->(DbCloseArea())

Return _lRet