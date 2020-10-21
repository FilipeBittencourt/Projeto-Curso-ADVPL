#include "Protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*/{Protheus.doc} AAPCOM36
Rotina de central de compras
@author pontin
@since 23/07/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function AAPCOM36

	// Variaveis da janela
	SetPrvt("oDlg1","oCBox1","oLBox1","oRMenu1","oLBox3")

	Private cForn   := Space(TamSx3("A2_COD")[1])
	Private nRadGro
	Private nQtdOri := 0
	Private aLisFor := {}

	Private cGrup 	:= Space(TamSx3("BM_GRUPO")[1])
	Private nRadGro3
	Private aLisFor3 := {}

	Private cLocEsc := Space(TamSx3("BZ_YLOCALI")[1])
	Private nRadGro2
	Private aLisFor2 := {}

	Private LCHECK   := .T.
	Private ACPOTMP
	Private cArqTemp
	Private nRadOpcao  := 1
	Private lCarregou  := .F.
	Private lImpressao := .F.
	Private nTotalF    := 0
	Private aRadOpcao  := {OemToAnsi("Número  "),OemToAnsi("Cliente ")}
	Private oFont      := TFont():New("ARIAL",08,16)
	Private oFontN     := TFont():New("ARIAL",08,16,,.T.)
	Private aNotPeso   := {}
	Private lRedespacho
	Private lInverte	 := .F.
	Private cMark   := GetMark()

	Private cPerg := "AAPCOMPRT"
	//-- Carregar o grupo de perguntas da rotina
	COM13001(.F.)

	// - Define a janela
	oFont1     := TFont():New( "Courier New",0,-11,,.F.,0,,400,.F.,.F.,,,,,, )
	oDlg1      := MSDialog():New( 091,232,592,950," { MTA177Qry } Opcoes Extras 'ANTONIO AUTO PECAS' ",,,.F.,,,,,,.T.,,,.T. )


	//Filtro do local.
	oGet6      := TGet():New( 015,140,{|u| If(PCount()>0,cLocEsc:=u,cLocEsc)},oDlg1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.  ,"",,,.F.,.F.,,.F.,.F.,"","cLocEsc",,)
	oGet6:cF3  := "SBE"
	oBtn3      := TButton():New ( 030,140,"Adicionar",oDlg1,{|| AdiExc(3)},037,012,,,,.T.,,"",,,,.F. )
	oBtn4      := TButton():New ( 030,190,"Excluir",oDlg1,{|| AdiExc(4)},037,012,,,,.T.,,"",,,,.F. )
	oLBox2     := TListBox():New( 050,140,,,100,048,,oDlg1,,CLR_BLACK,CLR_WHITE,.T.,,,,"",,,,,,, )
	GoRMenu2   := TGroup():New  ( 005,135,130,244,"Selecao de Locais",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oRMenu2    := TRadMenu():New( 110,146,{"Considera locais selecionados.","Desconsidera locais selecionados."},{|u| If(PCount()>0,nRadGro2:=u,nRadGro2)},oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,108,20,,.F.,.F.,.T. )

	// Filtro do Grupo
	oGetA      := TGet():New    ( 015,250,{|u| If(PCount()>0,cGrup:=u,cGrup)},oDlg1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.  ,"",,,.F.,.F.,,.F.,.F.,"","cGrup",,)
	oGetA:cF3  := "SBM"
	oBtnA      := TButton():New ( 030,250,"Adicionar",oDlg1,{|| AdiExc(5)},037,012,,,,.T.,,"",,,,.F. )
	oBtnB      := TButton():New ( 030,300,"Excluir",oDlg1,{|| AdiExc(6)},037,012,,,,.T.,,"",,,,.F. )
	oLBox3     := TListBox():New( 050,250,,,100,048,,oDlg1,,CLR_BLACK,CLR_WHITE,.T.,,,,"",,,,,,, )
	GoRMenuA   := TGroup():New  ( 005,245,130,357,"Selecao de Grupos",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oRMenuA    := TRadMenu():New( 110,256,{"Considera grupos selecionados.","Desconsidera grupos selecionados."},{|u| If(PCount()>0,nRadGro3:=u,nRadGro3)},oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,108,20,,.F.,.F.,.T. )

	//Filtro do fabricante
	oSay7      := TSay():New     ( 140,012,{||"Filtro de Fabricantes."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
	oGet1      := TGet():New     ( 150,012,{|u| If(PCount()>0,cForn:=u,cForn)},oDlg1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.  ,"",,,.F.,.F.,,.F.,.F.,"","cForn",,)
	oGet1:cF3  := "ZSA2"
	oLBox1     := TListBox():New ( 150,080,,,260,048,,oDlg1,,CLR_BLACK,CLR_WHITE,.T.,,,,"",,,,,,, )
	oLBox1:OFONT:NAME := "Courier New"
	oBtn1      := TButton():New  ( 165,012,"Adicionar",oDlg1,{|| AdiExc(1)},037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New  ( 185,012,"Excluir",oDlg1,{|| AdiExc(2)},037,012,,,,.T.,,"",,,,.F. )
	GoRMenu1   := TGroup():New   ( 210,012,245,140,"Selecao de Fornecedores",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oRMenu1    := TRadMenu():New ( 220,018,{"Considera fornecedores selecionados.","Desconsidera fornecedores selecionados."},{|u| If(PCount()>0,nRadGro:=u,nRadGro)},oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,108,20,,.F.,.F.,.T. )

	//Selecao de filiais
	MontaTMP()
	oBrwParte  := MsSelect():New( "TRB","T_OK","",aCpoTMP,@lInverte,@cMark,{015,005,130,130},,, oDlg1 )
	oBrwParte:bMark := {|| DISP()}
	oBrwParte:oBrowse:bAllMark := {|| FILMARK()}
	oBrwParte:oBrowse:lCanAllMark:= .T.
	oBrwParte:oBrowse:lHasMark:= .T.
	oFont10    := TFont():New( "Courier New",0,-27,,.T.,0,,700,.F.,.F.,,,,,, )
	oSay2      := TSay():New( 230,150,{||"COMPRAS 2.0"},oDlg1,,oFont10,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,188,016)

	//Botoes
	oBtn2      := TButton():New( 230, 300,"CONFIRMAR" ,oDlg1,{|| Carreg(1)},037,012,,,,.T.,,"",,,,.F. )
	oBtn3      := TButton():New( 230, 250,"PARAMETROS",oDlg1,{|| COM13001(.T.)},037,012,,,,.T.,,"",,,,.F. )

	oSay1      := TSay():New( 007,020,{||"(Marcar / Desmarcar) Todos."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)

	oDlg1:Activate(,,,.T.)




Return

//Funcao executada ao Marcar/Desmarcar um registro.
Static Function Disp()

	RecLock("TRB",.F.)
	If Marked("T_OK")
		TRB->T_OK := cMark
	Else
		TRB->T_OK := ""
	Endif
	TRB->(MsUnlock())

	oBrwParte:oBrowse:Refresh()

Return


Static Function FILMARK()

	TRB->(dbGoTop())
	While TRB->(!EOF())
		RecLock("TRB",.F.)
		If Empty(TRB->T_OK)
			TRB->T_OK := cMark
		Else
			TRB->T_OK := Space(2)
		Endif
		MsUnLock()
		TRB->(dbSkip())
	EndDo

	TRB->(dbGoTop())
	oBrwParte:oBrowse:Refresh()

Return()



Static Function Marktod

	// Guarda posição do ponteiro atual
	Local nReg := TRB->(RECNO())
	Local cMar := "  "

	// Inicio do Arquivo
	TRB->(DBGOTOP())

	// Verifica controle de marcacao
	If lInverte
		cMar := cMark
		lInverte := .F.
	Else
		cMar := "  "
		lInverte := .T.
	EndIF

	// Percorre o TRB
	While !TRB->(EOF())
		// Atualiza a marcação
		RecLock("TRB",.F.)
		TRB->T_OK    := cMar
		MsUnlock("TRB")

		// Próximo registro
		TRB->(DBSKIP())

	EndDo

	TRB->(dbGoTo(nReg))

Return()



static function AdiExc(nAcao)

	IF nAcao == 1
		IF Empty(cForn)
			Return()
		EndIf
		AAdd( aLisFor , PADR(cForn, TamSx3("B1_PROC")[1], " ")   +"- " +Posicione("SA2", 1 , xFilial("SA2")+ALLTRIM(cForn), "A2_NOME" ))
		cForn  := Space(TamSx3("A2_COD")[1])
		oLBox1:SetArray(aLisFor)
	ElseIF nAcao == 2
		IF Empty(oLBox1:nAt)
			Return()
		EndIf
		ADel ( aLisFor , oLBox1:nAt)
		ASize( oLBox1:AITEMS , Len(aLisFor) -1  )
		oLBox1:SetArray(aLisFor)
	ElseIf nAcao == 3
		IF Empty(cLocEsc)
			Return()
		EndIf
		AAdd( aLisFor2 , cLocEsc )
		cLocEsc  := Space(TamSx3("BZ_YLOCALI")[1])
		oLBox2:SetArray(aLisFor2)
	ElseIf nAcao == 4
		IF Empty(oLBox2:nAt)
			Return()
		EndIf
		ADel ( aLisFor2 , oLBox2:nAt)
		ASize( oLBox2:AITEMS , Len(aLisFor2) -1  )
		oLBox2:SetArray(aLisFor2)
	ElseIf nAcao == 5
		IF Empty(cGrup)
			Return()
		EndIf

		dbSelectArea("SBM")
		SBM->(dbSetOrder(1))
		SBM->(DbSeek( xFilial("SBM") + cGrup ))

		AAdd( aLisFor3 , cGrup + "  - " +SubStr( SBM->BM_DESC , 1 , 15)  )
		cGrup  := Space(TamSx3("BM_GRUPO")[1])
		oLBox3:SetArray(aLisFor3)

	ElseIf nAcao == 6
		IF Empty(oLBox3:nAt)
			Return()
		EndIf
		ADel ( aLisFor3 , oLBox3:nAt)
		ASize( oLBox3:AITEMS , Len(aLisFor3) -1  )
		oLBox3:SetArray(aLisFor3)
	EndIf

	oLBox1:Refresh()
	oLBox2:Refresh()
	oLBox3:Refresh()

Return



Static Function COM13001(lPer)

	/*ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	º Criacao dos parametros de usuario.                                           º
	º                                                                             */
	&& cGrupo, cOrdem, CPERGunt, cPerSpa, cPerEng, cVar, cTipo ,nTamanho, nDecimal, nPresel, cGSC, cValid, cF3, cGrpSxg, cPyme, cVar01, cDef01, cDefSpa1, cDefEng1, cCnt01, cDef02, cDefSpa2, cDefEng2, cDef03, cDefSpa3, cDefEng3, cDef04, cDefSpa4, cDefEng4, cDef05, cDefSpa5, cDefEng5, aHelpPor, aHelpEng, aHelpSpa, cHelp

	PutSx1( cPerg, "01", "Gerar", "Compras", "Distribuicao", "MV_CH1", "C", 2, 0, 1, "S", "", "",,, "mv_par01", "Compras", "Compras", "Compras",, "Distribuicao", "Distribuicao", "Distribuicao", "", "", "", "", "", "", "", "", "",;
	{" 1- Compras ( Gera compras conforme a "    ,;
	"necessidade das filiais selecionadas )"    ,;
	"2- Distribuicao ( Gera pedido de vendas"   ,;
	"para as filiais conforme a necessidade "   ,;
	"das filiais selecionadas ) . "             ,;
												},{},{},"")

	PutSx1(cPerg, "02", "Numero de periodos?", "", "", "mv_ch2", "N", 03, 00, 00, "S", "", "", "", "", "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe o numero de dias que ira contar ",;
	",retrocedendo a data de hoje, para cal- ",;
	"cular a media diaria de venda do produto",;
	"                                        ",;
	"                                        "},{},{},"")

	PutSx1(cPerg, "03", "Periodos para projecao?", "", "", "mv_ch3", "N", 03, 00, 00, "S", "", "", "", "", "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a quantidade de dias que sera   ",;
	"abastecido a filial que houver necessi- ",;
	"dade.                                   ",;
	"                                        ",;
	"                                        "},{},{},"")

	PutSx1(cPerg, "04", "Fabricante de?         ", "", "", "mv_ch4", "C", TamSx3("A2_COD")[1], 00, 00, "S", "", "SA2", "", "", "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa inicial de fabricante   ",;
	"a ser considerado pela rotina.          ",;
	"                                        ",;
	"                                        ",;
	"                                        "},{},{},"")

	PutSx1(cPerg, "05", "Fabricante ate?        ", "", "", "mv_ch5", "C", TamSx3("A2_COD")[1], 00, 00, "S", "", "SA2", "", "", "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa final de fabricante     ",;
	"a ser considerado pela rotina.          ",;
	"                                        ",;
	"                                        ",;
	"                                        "},{},{},"")


	PutSx1( cPerg, "06", "Preco Compra", "Preco Compra", "Preco Compra", "MV_CH6", "C", 2, 0, 0, "S", "", "",,, "mv_par06", "Tipo1", "Tipo1", "Tipo1",, "Tipo2", "Tipo2", "Tipo2", "", "Tipo3", "Tipo3", "Tipo3", "", "", "", "", "",;
	{" Tipo 1. - Custo Standard             "    ,;
	"  Tipo 2. - Tabela de Preco.           "    ,;
	"                                       "   ,;
	"                                       "   ,;
	"                                       "   ,;
												},{},{},"")

	PutSx1(cPerg, "07", "Tabela de preco?       ", "", "", "mv_ch7", "C", 3, 00, 00, "S", "", "", "", "", "MV_PAR07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a tabela de preco caso tenha    ",;
	"escolhido o tipo 2 para preco de compra ",;
	"                                        ",;
	"                                        ",;
	"                                        "},{},{},"")

	PutSx1( cPerg, "08", "Estoque Maximo?", "Compras", "Distribuicao", "MV_CH8", "C", 2, 0, 2, "C", "", "",,, "mv_par08", "Sim", "Sim", "Sim",, "Nao", "Nao", "Nao", "", "", "", "", "", "", "", "", "",;
	{" 1- Sim. Considera estoque maximo.    "    ,;
	" 2- Nao. Nao considera estoque maximo  "    ,;
	"                                       "   ,;
	"                                       "   ,;
	"                             "             ,;
												},{},{},"")

	PutSx1(cPerg, "09", "Minimo Estoque Centr?  ", "", "", "mv_ch9", "N", 9, 00, 00, "G", "", "", "", "", "MV_PAR09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a quantidade minima de dias que ",;
	"o produto deve suprir a necessidade de  ",;
	"estoque da centralizadora ( nao podendo ",;
	"distribuir esta quantidade ou comprando ",;
	"a mais que a necessidade.  )            "},{},{},"")


	PutSx1(cPerg, "10", "Num Dias Min Abastec?  ", "", "", "mv_cha", "N", 3, 00, 00, "S", "", "", "", "", "MV_PAR10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe o numero minimo de dias para que",;
	"a filial deve ter estoque, caso nao     ",;
	"tenha estoque suficiente para esse nume-",;
	"ro de dias, ira receber o abastecimento ",;
	"ou entrara na media para compra. Caso   ",;
	"for valor 0 ira desconsiderar o parametr"},{},{},"")

	PutSx1(cPerg, "11", "Produtos com media de?  ", "", "", "mv_chb", "N", 8, 02, 00, "S", "", "", "", "", "MV_PAR11", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa inicial da media de ven-",;
	"da por dia para ser considerado na com- ",;
	"pra ou distribuicao.                    ",;
	"                                        ",;
	"                                        "},{},{},"")

	PutSx1(cPerg, "12", "Produtos com media ate?  ", "", "", "mv_chc", "N", 8, 02, 00, "S", "", "", "", "", "MV_PAR12", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa final da media de venda ",;
	"por dia para ser considerado na compra  ",;
	" ou distribuicao                        ",;
	"                                        ",;
	"                                        "},{},{},"")



	PutSx1( cPerg, "13", "Considera Embalagem?", "Compras", "Distribuicao", "MV_CHd", "C", 2, 0, 0, "C", "", "",,, "mv_par13", "Sim", "Sim", "Sim",, "Nao", "Nao", "Nao", "", "", "", "", "", "", "", "", "",;
	{" Sim. Considera a embalagem, arredondando",;
	"a compra para a quantidade da embalage,   ",;
	"  Nao. Nao considera a quantidade da emba-",;
	"lagem. ( Nao considera embalagem para dis-",;
	"tribuicao.                                ",;
												},{},{},"")

	PutSx1(cPerg, "14", "Filial Centralizadora?  ", "", "", "mv_che", "C", 8, 00, 00, "G", "", "", "", "", "MV_PAR14", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a filial centralizadora.        ",;
	"( a centralizadora nao pode ser selecio-",;
	"nada nas filiais para receber a distri- ",;
	"buicao).                                ",;
	"                                        "},{},{},"")


	PutSx1( cPerg, "15", "Considera Est. Minimo?", "Compras", "Distribuicao", "MV_CHf", "C", 2, 0, 0, "C", "", "",,, "mv_par15", "Sim", "Sim", "Sim",, "Nao", "Nao", "Nao", "", "", "", "", "", "", "", "", "",;
	{" Considera o estoque minimo SIM/NAO     ",;
	"Este parametro deve ser utilizado para que",;
	"compre ou distribua caso o estoque seja   ",;
	"menor que o estoque minimo                ",;
	"                                          ",;
												},{},{},"")


	PutSx1(cPerg, "16", "Vendedor?  ", "", "", "mv_chg", "C", 6, 00, 00, "S", "ExistCpo('SA3',PADL(AllTrim(M->MV_PAR16),6,'0'))", "SA3", "", "", "MV_PAR16", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe o Vendedor que está realizando  ",;
	"a distribuição.						",;
	"									",;
	"			                            ",;
	"                                        "},{},{},"")


	PutSx1(cPerg, "17", "Media 01 de?  ", "", "", "mv_chh", "N", 8, 02, 00, "G", "", "", "", "", "MV_PAR17", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa 01 inicial da media de ven-",;
	"da por dia para ser considerado na com- ",;
	"pra.                    ",;
	"                                        ",;
	"                                        "},{},{},"")

	PutSx1(cPerg, "18", "Media 01 ate?  ", "", "", "mv_chi", "N", 8, 02, 00, "G", "", "", "", "", "MV_PAR18", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa 01 final da media de venda ",;
	"por dia para ser considerado na compra  ",;
	"                         ",;
	"                                        ",;
	"                                        "},{},{},"")


	PutSx1(cPerg, "19", "Dias Projecao 01?", "", "", "mv_chj", "N", 03, 00, 00, "G", "", "", "", "", "MV_PAR19", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a quantidade de dias que sera   ",;
	"abastecido a filial que houver necessi- ",;
	"dade.                                   ",;
	"                                        ",;
	"                                        "},{},{},"")


	PutSx1(cPerg, "20", "Media 02 de?  ", "", "", "mv_chk", "N", 8, 02, 00, "G", "", "", "", "", "MV_PAR20", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa 02 inicial da media de ven-",;
	"da por dia para ser considerado na com- ",;
	"pra.                    ",;
	"                                        ",;
	"                                        "},{},{},"")

	PutSx1(cPerg, "21", "Media 02 ate?  ", "", "", "mv_chl", "N", 8, 02, 00, "G", "", "", "", "", "MV_PAR21", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa 02 final da media de venda ",;
	"por dia para ser considerado na compra  ",;
	"                         ",;
	"                                        ",;
	"                                        "},{},{},"")


	PutSx1(cPerg, "22", "Dias Projecao 02?", "", "", "mv_chm", "N", 03, 00, 00, "G", "", "", "", "", "MV_PAR22", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a quantidade de dias que sera   ",;
	"abastecido a filial que houver necessi- ",;
	"dade.                                   ",;
	"                                        ",;
	"                                        "},{},{},"")


	PutSx1(cPerg, "23", "Media 03 de?  ", "", "", "mv_chn", "N", 8, 02, 00, "G", "", "", "", "", "MV_PAR23", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa 03 inicial da media de ven-",;
	"da por dia para ser considerado na com- ",;
	"pra.                    ",;
	"                                        ",;
	"                                        "},{},{},"")

	PutSx1(cPerg, "24", "Media 03 ate?  ", "", "", "mv_cho", "N", 8, 02, 00, "G", "", "", "", "", "MV_PAR24", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a faixa 03 final da media de venda ",;
	"por dia para ser considerado na compra  ",;
	"                         ",;
	"                                        ",;
	"                                        "},{},{},"")


	PutSx1(cPerg, "25", "Dias Projecao 03?", "", "", "mv_chp", "N", 03, 00, 00, "G", "", "", "", "", "MV_PAR25", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a quantidade de dias que sera   ",;
	"abastecido a filial que houver necessi- ",;
	"dade.                                   ",;
	"                                        ",;
	"                                        "},{},{},"")

	//-- Carregar o grupo de perguntas da rotina
	Pergunte( cPerg, lPer )

Return


Static Function Com13002

	//- Variaves da query
	Local cQryEst := " " // Query da Qtd Estoque ( SALDO ATUAL    B2_QATU )
	Local cQryMed := " " // Query da media
	Local cQryMCe := " " // Query para media da centralizadoda de venda ( utilizado para distribuicao )
	Local cQryNes := " " // Query da necessidade
	Local cQryPri := " " // Query Principal
	Local cFilFil  := " " // Filtro das Filiais
	Local cFilRot := " "
	Local cExcFil := ""
	Local aFilCli := {}  // clientes que são filiais
	Local nI		:= 1
	Local nCont	:= 0
	Local cFilSel	:= ""
	Local aTam			:= {}
	Local aCampos		:= {}
	Local cNomeArq		:= ""
	Private oProcess 	:= Nil
	Private nComDis := 1  //1 = Compras / 2 = Distribuição

	//|Criar a tabela para a TRB_XX |
	aTam := TamSX3('ZZ_COD')		; aAdd(aCampos, {'XX_COD'		, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_CODITE')		; aAdd(aCampos, {'XX_CODITE'	, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_APLIC')		; aAdd(aCampos, {'XX_APLIC'		, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_NOMFAB')		; aAdd(aCampos, {'XX_NOMFAB'	, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('D1_QUANT')		; aAdd(aCampos, {'XX_NECREAL'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_CUSTO')		; aAdd(aCampos, {'XX_CUSTO'		, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_MEDMES')		; aAdd(aCampos, {'XX_MEDMES'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_QATU')		; aAdd(aCampos, {'XX_QTDFIL'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_QATU')		; aAdd(aCampos, {'XX_QTDCENT'	, 'N',aTam[1] ,aTam[2] })

	//|Verifica area aberta |
	If Select("TRB_XX") <> 0
		TRB_XX->(dbCloseArea())
	EndIf

	cNomeArq := CriaTrab(aCampos)
	dbUseArea(.T.,,cNomeArq,'TRB_XX',.F.,.F.)
	TRB_XX->(DBCreateInd( Left(cNomeArq,7)+"a.cdx", "XX_COD", {||XX_COD}))
	TRB_XX->(DBClearIndex())
	TRB_XX->(DBSetIndex( Left(cNomeArq,7)+"a.cdx" ))

	oProcess := MsNewProcess():New({|lEnd| SFP001()})
	oProcess:Activate()

	NewSource()

Return()

//*****************************
// FUNCAO PARA MONTAR O BROWSE com itens do pedido
//*****************************
Static Function MontaTMP()

	aCpoTMP := {}
	aArqTMP := {}

	// Campos do arquivo temporário e titulos

	// MARK
	Aadd(aArqTMP,{"T_OK","C",2,0})
	AADD(aArqTMP,{"T_FILIAL","C",9,0})
	AADD(aArqTMP,{"T_DESCRI","C",20,0})

	// estutura do acols
	aAdd(aCpoTMP,{"T_OK"     ,, "  "})
	aAdd(aCpoTMP,{"T_FILIAL",, "FILIAL"})
	aAdd(aCpoTMP,{"T_DESCRI",, "DESCRICAO"})

	// Verifica area aberta
	If Select("TRB") <> 0
		TRB->(DBCLOSEAREA())
	EndIF

	cnomearq := criatrab(aArqTMP)
	dbusearea(.T.,,cnomearq,"TRB",.f.,.f.)
	//indregua("TRB",cnomearq,"T_PARTE",,,"Selecionando Registros...")

	SM0->(dbGoTop())

	While !SM0->(EOF())
	If SM0->M0_CODIGO == "01" .And. SubStr(SM0->M0_CODFIL,1,3) $ "AAP/JPD"
			RecLock("TRB",.T.)
				TRB->T_OK	:= ""
				TRB->T_FILIAL	:= SM0->M0_CODFIL
				TRB->T_DESCRI	:= SM0->M0_FILIAL
			TRB->(MsUnLock())
		EndIf
		SM0->(dbSkip())
	EndDo

	TRB->(DbGoTop())

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AAPCOM13  ºAutor  ³Microsiga           º Data ³  01/14/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 	                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NewSource

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de cVariable dos componentes                                 ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
	Private aCoBrw1 := {}
	Private aHoBrw1 := {}
	Private noBrw1  := 0
	Private cEvent	:= ""
	Private nValTot := 0
	Private nQtdTot := 0

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oDlg2","oBrw1")

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oDlg2      := MSDialog():New( 056,096,600,1215,"Resultado do Calculo",,,.F.,,,,,,.T.,,,.T. )
	MHoBrw1()
	MCoBrw1()

	SetKey(VK_F6, {||Processa({|| SFP007()},"Excel", "Exportação para Excel, aguarde...")} )

	oBrw1      := MsNewGetDados():New(004,004,250,548,0,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlg2,aHoBrw1,aCoBrw1 )
	oBrw1:OBROWSE:BLDBLCLICK= {||AlterQtd()}

	oBtnConf   := TButton():New ( 255,490,"Confirmar",oDlg2,{|| Carreg(2)},037,012,,,,.T.,,"",,,,.F. )

	oSay11      := TSay():New     ( 255,030,{||	"Quantidade Total: " + Transform(nValTot,"@E 999,999,999")	},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
	oSay12      := TSay():New     ( 255,150,{|| "Valor Total:" + Transform(nQtdTot,"@E 999,999,999.99")  },oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)

	oDlg2:Activate(,,,.T.)

	//oDlg1:End()

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1() - Monta aHeader da MsNewGetDados para o Alias:
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1()

	DbSelectArea("SX3")
	DbSetOrder(1)

	//Filial
	DbSeek("B1_FILIAL")
	Aadd(aHoBrw1,{"FILIAL"	   , "Filial"	, SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )
	//Codigo
	DbSeek("B1_COD")
	Aadd(aHoBrw1,{"CODIGO"	   , "Codigo"	, SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )
	//Codigo
	DbSeek("B1_CODITE")
	Aadd(aHoBrw1,{"COD.FABRIC"	, "COD.FABRIC"	, SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )
	//Descricao
	DbSeek("B1_DESC")
	Aadd(aHoBrw1,{"DESCRICAO"  , "Descricao", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	// Fornecedor padrao
	DbSeek("B1_PROC")
	Aadd(aHoBrw1,{"Fabricante"  , "Fabricante", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	//BZ_CUSTD

	//Necessidade Real
	DbSeek("B2_QATU")
	Aadd(aHoBrw1,{"Neces. Real", "NG_Neces1", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	//Necessidade Real
	Aadd(aHoBrw1,{"Neces. Final", "NG_Neces2", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	// Preco unitario
	DbSeek("C7_PRECO")
	Aadd(aHoBrw1,{"Preco", "NG_Preco", "@E 99,999,999.99",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	// Valor total
	DbSeek("C7_PRECO")
	Aadd(aHoBrw1,{"Val Total", "NG_Valor", "@E 99,999,999.99",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	DbSeek("B2_QATU")
	//Estoque Maximo
	Aadd(aHoBrw1,{"Media  Vend", "NG_MedVen", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	//Quantidade Estoque
	Aadd(aHoBrw1,{"Quant. Esto", "NG_QtdEst", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	//Quantidade Estoque Centralizadora
	Aadd(aHoBrw1,{"Quant. Cent", "NG_QtdCen", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	//Estoque Maximo
	Aadd(aHoBrw1,{"Estoq. Maxi", "NG_EstMax", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )

	//Estoque Maximo
	Aadd(aHoBrw1,{"Embalagem"  , "NG_Embala", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )


	//Alteracoes
	DbSeek("B1_VM_PROC")
	Aadd(aHoBrw1,{"Alt", "Alt", SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )


Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1() - Monta aCols da MsNewGetDados para o Alias:
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1()

	Local nNecFin   := 0
	Local nContador := 0
	Local nQuanAux  := 0
	Local nQtdDisp  := 0
	Local cFiliCer  := ""
	Local nZ		:= 1

	//-----------------------------------------------------------
	// Adiciona os itens no aCols conforme as regras da antonio.
	//-----------------------------------------------------------
	TRB_XX->(dbGoTop())
	While !TRB_XX->(EoF())

		//--------------------------------
		// Apenas produtos com necessidade
		//--------------------------------
		If TRB_XX->XX_NECREAL > 0
		    //-----------------------
			//Variaveis auxiliares
			//-----------------------
			nNecFin		:= Abs(Round(TRB_XX->XX_NECREAL,2))     // Quantidade Final comeca com a quantidade real - sem as alteracoes.
			nQtdDisp	:= TRB_XX->XX_QTDCENT     				// Coloca o estoque que existe na centralizadora ( para distribuicao ).
			cEvent 		:= " " + CHR(10) + CHR(13)				// Zera a variavel de eventos ocorridos no produto
			cFiliCer	:= MV_PAR14 							// Preenche com a filial correta ( se for compra sera a centralizadora)

			//-------------------------------
			//Posiciona no indice do produto
			//-------------------------------
			dbSelectArea("SBZ")
			DbSetOrder(1)
			If SBZ->(dbSeek( ALLTRIM(cFiliCer) + TRB_XX->XX_COD )  )
				nBZ_EMAX		:= SBZ->BZ_EMAX
				nBZ_ESTSEG	:= SBZ->BZ_ESTSEG
			Else
				nBZ_EMAX		:= 0
				nBZ_ESTSEG	:= 0
			EndIf

			SB1->(dbSeek(xFilial("SB1")+TRB_XX->XX_COD))

			If SB1->B1_YBLQCOM == 'S'
				TRB_XX->(dbSkip())
				Loop
			EndIf

			//-------------------------------------------------------
			// Considera estoque maximo.
			//-------------------------------------------------------
			If mv_par08 = 1 .And. nBZ_EMAX <> 0
				nQtdMax := nBZ_EMAX - IIf(TRB_XX->XX_QTDCENT < 0,0,TRB_XX->XX_QTDCENT)
				If nQtdMax < 0
					nNecFin := 0
				EndIf

				IF nNecFin > nQtdMax .And. nNecFin > 0
					//Diminuiu o a quantidade devido ao estoque maximo.
					cEvent	+= + CHR(10) + CHR(13) + " Alterou a quantidade devido ao estoque maximo " +  CHR(10) + CHR(13)
					cEvent	+= " Valor de : "+ STR(nNecFin) + " Para : " + STR(nQtdMax)  + CHR(10) + CHR(13)
					nNecFin := nQtdMax
				EndIf
			EndIf

			//--------------------------------------------------------------------------------------
			// - Calcula o tanto a mais que deve ser comprado para que fique o estoque na centralizadora. ( o calculo
			// feito para distribuicao e diferente, feito no IF acima.
			// - Coloca no numero minimo da quantidade da embalagem apenas se for compras.
			//--------------------------------------------------------------------------------------
			nQuanEmb 		:= 1
			IF nComDis < 2
				// Verifica se foi adicionado produtos para ficar com minimo na centralizadora
				IF !Empty(MV_PAR09)
					cEvent	+= " Alterou a quantidade devido a quantidade que deve ficar na centralizadora " + CHR(10) + CHR(13)
					cEvent	+= " Valor de : "+ STR(nNecFin) + " Para : " + STR(nNecFin + (MV_PAR09 * (TRB_XX->XX_MEDMES/30)))
					nNecFin	:= nNecFin + (MV_PAR09 * (TRB_XX->XX_MEDMES/30))
				EndIf

				//Verifica se considera embalagem
				If MV_PAR13 = 1
					If SB1->B1_QE <> 0

						nQuanEmb 		:= SB1->B1_QE
						nBkpNecFin		:= nNecFin
						//|Verifica se está solicitando menos que a embalagem |
						If nBkpNecFin <= nQuanEmb
							nBkpNecFin := nQuanEmb
						Else
							If (nResto := nBkpNecFin % nQuanEmb) > 0
								nPercent := (nResto * 100) / nQuanEmb
								//|Verifica se arredonda pra cima ou pra baixo |
								If nPercent < 50	//|Arredonda pra baixo |
									nBkpNecFin -= nResto
								Else		//|Arredonda pra cima|
									nBkpNecFin += (nQuanEmb - nResto)
								EndIf
							EndIf
						EndIf

						//Verifica se foi alterado
						IF nNecFin <> nBkpNecFin
							//Diminuio o a quantidade devido ao estoque maximo.
							cEvent	+= + CHR(10) + CHR(13) + " Alterou a quantidade devido a embalagem " + CHR(10) + CHR(13)
							cEvent	+= " Valor de : "+ STR(nNecFin)  + " Para : " + STR(nBkpNecFin)
						EndIf

						nNecFin	:= nBkpNecFin

					EndIf
				EndIf

			EndIf

			// Arredonda a necessidade final para UM  a mais.
			IF nNecFin > INT(nNecFin)

				If (nResto := INT(nNecFin + 1) % nQuanEmb) > 0
					nNecFin := INT(nNecFin)
				Else
					//Arredondo a quantidade para cima.
					cEvent	+= + CHR(10) + CHR(13) + " Realizou o arredondamento para cima " + CHR(10) + CHR(13)
					cEvent	+= " Valor de : "+ STR(Round(nNecFin,2))  + " Para : " + STR(Round(nNecFin + 1 , 0 ))

					nNecFin := INT(nNecFin + 1)
				EndIf

			EndIf

			//-------------------------------------------------------
			// Considera estoque minimo.
			//-------------------------------------------------------
		 	If MV_PAR15 = 1 .AND.	nNecFin < nBZ_ESTSEG
				//Almentou a quantidade devido ao estoque minimo.
				cEvent	+= + CHR(10) + CHR(13) + " Alterou a quantidade devido ao estoque minimo " +  CHR(10) + CHR(13)
				cEvent	+= " Valor de : "+ STR(nNecFin) + " Para : " + STR(nBZ_ESTSEG)  + CHR(10) + CHR(13)
				nNecFin := nBZ_ESTSEG
		 	EndIf

			If nNecFin > 0

				If TRB_XX->XX_CUSTO > 0
					nVlrUni := TRB_XX->XX_CUSTO
				Else
					nVlrUni := 10
				EndIf

				//--------------------------------------------------------------------------------------
				// Adiciona no aCols. os itens que serão gerados Pedidos.
				//--------------------------------------------------------------------------------------
				AADD(aCoBrw1 , {MV_PAR14   					,;
								TRB_XX->XX_COD   			,;
								TRB_XX->XX_CODITE			,;
								TRB_XX->XX_APLIC 			,;
								TRB_XX->XX_NOMFAB 			,;
								TRB_XX->XX_NECREAL			,;
								nNecFin 		 			,;
								nVlrUni						,;
								(nVlrUni * nNecFin )		,;
								TRB_XX->XX_MEDMES			,;
								IIf(TRB_XX->XX_QTDFIL < 0,0,TRB_XX->XX_QTDFIL)			,;
								TRB_XX->XX_QTDCENT			,;
								nBZ_EMAX 					,;
								SB1->B1_QE					,;
								cEvent						,;
								.F.							})
				//Atualiza os totalizadores.
				nValTot += nNecFin
				nQtdTot += nVlrUni * nNecFin
	        	EndIF

		EndIf

		TRB_XX->(dbSkip())

	EndDo

	aSort(aCoBrw1,,,{ |x,y| x[5]+x[2] < y[5]+y[2] })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AAPCOM13  ºAutor  ³Microsiga           º Data ³  01/16/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AlterQtd

	Local nQtdAnt	:= oBrw1:ACOLS[oBrw1:nAt][7]
	Local lAumenta	:= .F.

	// Variaveis da tela
	SetPrvt("oFont1","oDlg1","oMGet","oGet4","oBtn1")

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("B2_QATU")

	//Definicao da janela
	oFont1     := TFont():New( "MS Sans Serif",0,-24,,.T.,0,,700,.F.,.F.,,,,,, )
	oDlg3      := MSDialog():New( 091,232,577,872,"oDlg3",,,.F.,,,,,,.T.,,,.T. )

	oMGet1     := TMultiGet():New( 008,012,{|u| If(PCount()>0,oBrw1:ACOLS[oBrw1:nAt][15]:=u,oBrw1:ACOLS[oBrw1:nAt][15])},oDlg3,288,160,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	oMGet1:Disable()

	oGetQtd    := TGet():New( 184,012,{|u| If(PCount()>0, oBrw1:ACOLS[oBrw1:nAt][7]:=u, oBrw1:ACOLS[oBrw1:nAt][7]   )} ,oDlg3,188,038,'@E 999,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","oBrw1:ACOLS[oBrw1:nAt][7]",,)
	//oGetQtd:GetFocus()
	oGetQtd:SetFocus()

	oBtn1      := TButton():New( 184,212,"CONFIRMAR",oDlg3,{|| oDlg3:End()},093,040,,,,.T.,,"",,,,.F. )

	oDlg3:Activate(,,,.T.)

	If oBrw1:ACOLS[oBrw1:nAt][7] <> nQtdAnt

		If nQtdAnt < oBrw1:ACOLS[oBrw1:nAt][7]
			nDiferenca 	:= oBrw1:ACOLS[oBrw1:nAt][7] - nQtdAnt
			nQtdTot 	+= oBrw1:ACOLS[oBrw1:nAt][8] * nDiferenca
			nValTot 	+= nDiferenca
		Else
			nDiferenca 	:= nQtdAnt - oBrw1:ACOLS[oBrw1:nAt][7]
			nQtdTot 	-= oBrw1:ACOLS[oBrw1:nAt][8] * nDiferenca
			nValTot 	-= nDiferenca
		EndIf

		oBrw1:ACOLS[oBrw1:nAt][9] := oBrw1:ACOLS[oBrw1:nAt][8] * oBrw1:ACOLS[oBrw1:nAt][7]
	EndIf

	oBrw1:Refresh()
	oSay11:Refresh()
	oSay12:Refresh()

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriPeCom  ºAutor  ³Fabrício            º Data ³  01/16/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ºAtualizacao - Alteracao_01 - Henrique - 06/08/2013 - Alteração na rotina º±±
±±º				para gerar o orçamento por fases ao invés de gerar o pedido de venda  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CriPeCom

	Local cForFil 	:= ""  // Auxiliar para gerar a compra por fornecedor ou por filial
	Local cFornec	:= "" // Codigo usado como fornecedor.
	Local cForCen   := ""  // Pega o Codigo da filial centralizadora como fornecedor
	Local cFilEntr  := ""  // Filial de entrega.
	Local _aCab		:={}
	Local _aItem	:={}
	Local cNumSC7	:= ""
	Local cNumSC5	:= ""
	Local nPosFor   := IIF( nComDis < 2 , 5 , 1)  // Se for DISTRIBUICAO ira pegar a filial como fornecedor se for COMPRAS pegara o FORNECEDOR.
	Local cCondPag	:= GetMv("AP_PAGCOM") // comentar no fonte, e verificar os parametros do outro fonte para colocar todos no padrão AP_
	Local nI		:= 0
	Local nCont	:= 0
	Local nLimite	:= SuperGetMV("MV_NUMITEN",.F.,200)
	Private cMensagem := ""
	Private cNumOrc	:= ""
	_aCab		:={}
	_aItem		:={}

	IF Len(oBrw1:aCols) < 2 .AND. EMPTY(oBrw1:aCols[1,1] )
		oDlg2:End()
		Return()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria os pedidos de venda.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF nComDis > 1

		cMensagem		:= ""
		dbSelectArea("AIB")
		dbSetOrder(2)
		// Abastece os arrays das rotinas automaticas.
		For nI:=1 To Len(oBrw1:aCols)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera numero do pedido de venda.                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	IF (nCont == nLimite .Or. cForFil <> oBrw1:aCols[nI,nPosFor]) .And. oBrw1:aCols[nI,7] > 0 // so ira distribuir se tiver itens a serem comprados
				// Zera cabecalho
				_aCab		:={}
				_aItem		:={}

				nCont := 0

				// gera um novo numero
				//cNumSC5 := Criavar("C5_NUM",.T.)

				//Busca o cliente ( que sera a filial de destino )
				dBSelectArea("SM0")
				dbSetOrder(1)
				IF SM0->(DBSeek(cEmpAnt + oBrw1:aCols[nI,1]  ))
					//Prepara fornecedor para buscar por CNPJ
					dbSelectArea("SA1")
					SA1->(dbSetOrder(3))
					IF SA1->(dbSeek(xFilial("SA1") + SM0->M0_CGC))
						cForCen := SA1->A1_COD
					Else
						Alert("{AAPCOM13} - Filial centralizadora nao cadastrada como fornecedor. CNPJ: " + SM0->M0_CGC)
						Return()
					EndIf
				Else
					// Este erro nao pode acontecer, verificar o sigamat.emp
					Alert("{AAPCOM13} - Nao foi possível posicionar na empresa. Contate o Administrador do sistema.")
					Return()
				EndIf

				cFilAntBkp 	:= cFilAnt
				cFilAnt		:= AllTrim(MV_PAR14)

				cNumOrc := GetMV("MV_YSEQTRA")

				If Empty(cNumOrc)
					MsgAlert("Nao foi possivel encontrar o numero sequencial do orçamento!","MV_YSEQTRA")
					Return
				Else
					cSeqOrc	:= StrZero(Val(cNumOrc) + 1 ,7)
					cNumOrc 	:= "T" + cSeqOrc
				EndIf

				PutMV("MV_YSEQTRA",cSeqOrc)
				cMensagem 	+= 'Filial: '+ AllTrim(MV_PAR14) + '     Orc. por Fase: '+ cValToChar(cNumOrc)	+ CHR(13)+CHR(10)

				cFilAnt		:= cFilAntBkp

				_aCab:=	{ 	{"VS1_FILIAL"	,AllTrim(MV_PAR14), Nil},;
							{"VS1_NUMORC"	,cNumOrc 		, Nil},;
							{"VS1_TIPORC"	,'3' 			, Nil},;//1=Orcamento Pecas;2=Orcamento Oficina;3=Transferencia
							{"VS1_CLIFAT"	, cForCen		, Nil},;
							{"VS1_LOJA"		,"01" 			, Nil},;
							{"VS1_NCLIFT"	, Posicione('SA1', 1, xFilial("SA1")+cForCen+"01", 'SA1->A1_NOME'),Nil},;
							{"VS1_DATORC"	, dDataBase		, Nil},;
							{"VS1_FORPAG"	, '021'			, Nil},;
							{"VS1_CFNF"		, '1'			, Nil},;
							{"VS1_CODVEN"	, PADL(AllTrim(MV_PAR16),6,'0')		, Nil},;
							{"VS1_STATUS"	, "0"			, Nil},;
							{"VS1_FILDES"	, oBrw1:aCols[nI,nPosFor],Nil},;
							{"VS1_ARMDES"	, "01"			, Nil},;
							{"VS1_TRANSP"	, SuperGetMv("MV_YTRTRAN",,,oBrw1:aCols[nI,1])			, Nil},;
							{"VS1_HORORC"	, val(left(time(),2)+substr(time(),4,2))			, Nil};
						}

		       	cForFil := oBrw1:aCols[nI,nPosFor]
			   	cIte	:= "001"

		    EndIf

		   	dBSelectArea("SBZ")
			SBZ->(dbSetOrder(1))
			If SBZ->(dbSeek(	MV_PAR14	+		oBrw1:aCols[nI,2]	))
				cBZ_TS		:= SBZ->BZ_TS
				cBZ_YLOCALI	:= SBZ->BZ_YLOCALI
			Else
				cBZ_TS		:= ""
				cBZ_YLOCALI	:= ""
			EndIf

			dBSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(	xFilial("SB1")	+	oBrw1:aCols[nI,2]	))

			// so ira distribuir se tiver itens a serem comprados
		    IF oBrw1:aCols[nI,7] > 0

		    		nCont++

				cCodTes := MaTesInt(02, '03', cForCen, '01', "C", oBrw1:aCols[nI,2]) //Obtem TES de Transferencia

				If AllTrim(cCodTes) == ''
					cCodTes := cBZ_TS
				EndIf

				If AIB->(dbSeek(xFilial("AIB")+SB1->(B1_PROC+B1_LOJPROC)+"001"+SB1->B1_COD))
					nVlrUni := AIB->AIB_PRCCOM
				Else
					nVlrUni := 10
				EndIf

				aAdd(_aItem,{	{"VS3_FILIAL" 	, AllTrim(MV_PAR14),Nil},;
								{"VS3_NUMORC"	, cNumOrc 		, Nil},;
								{"VS3_SEQUEN"	, cIte,Nil},;
								{"VS3_GRUITE" 	, POSICIONE('SB1', 1, xFilial('SB1')+oBrw1:aCols[nI,2],"SB1->B1_GRUPO" ),Nil},;
								{"VS3_CODITE" 	, POSICIONE('SB1', 1, xFilial('SB1')+oBrw1:aCols[nI,2],"SB1->B1_CODITE"),Nil},;
								{"VS3_YCOD" 	, oBrw1:aCols[nI,2]	,Nil},;
								{"VS3_QTDITE" 	, oBrw1:aCols[nI,7]	,Nil},;
								{"VS3_QTDINI"	, oBrw1:aCols[nI,7]	,Nil},;
								{"VS3_OPER" 	, "02"	,Nil},;
								{"VS3_CODTES" 	, cCodTes ,Nil},;
								{"VS3_LOCAL" 	, "01",Nil},;
								{"VS3_YLOCAL" 	, cBZ_YLOCALI,Nil},;
								{"VS3_VALPEC" 	, nVlrUni ,Nil},;
								{"VS3_VALLIQ" 	, nVlrUni ,Nil},;
								{"VS3_VALTOT" 	, nVlrUni*oBrw1:aCols[nI,7],Nil},;
								{"VS3_VALDES" 	, 0,Nil},;
								{"VS3_PERDES" 	, 0,Nil};
							})

				cIte := Soma1(cIte)

			EndIf

			IF Len(oBrw1:aCols) <> nI
				IF cForFil <> oBrw1:aCols[nI+1 , nPosFor]
					// Cria o ultimo pedido
					CriaPd( _aCab	,_aItem , 3 , 2)
				ElseIf nCont == nLimite
			 		CriaPd( _aCab	,_aItem , 3 , 2)
				EndIf
		  	Else
					CriaPd( _aCab	,_aItem , 3 , 2)
			EndIf

		Next nI

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria os pedidos de compra.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_aCab		:={}
	_aItem		:={}

	// Zera a variavel auxiliar para criar o pedido por fornecedor
	cForFil := ""

	dBSelectArea("SM0")
	dbSetOrder(1)
	IF SM0->(DBSeek("01" + ALLTRIM(MV_PAR14)  ))
		//Prepara fornecedor para buscar por CNPJ
		SA2->(dbSelectArea("SA2"))
		SA2->(dbSetOrder(3))
		IF SA2->(dbSeek(xFilial("SA2") + SM0->M0_CGC))
			cForCen := SA2->A2_COD
		Else
			Alert("{AAPCOM13} - Filial centralizadora nao cadastrada como fornecedor. CNPJ: " + SM0->M0_CGC)
			Return()
		EndIf
	Else
		// Este erro nao pode acontecer, verificar o sigamat.emp
		Alert("{AAPCOM13} - Nao conseguio posicionar na empresa. Contate o Administrador do sistema.")
		Return()
	EndIf

	IF nComDis == 1

		// Abastece os arrays das rotinas automaticas.
		For nI:=1 To Len(oBrw1:aCols)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera numero do pedido de compra                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	IF cForFil <> oBrw1:aCols[nI,nPosFor]

					_aCab		:={}
					_aItem		:={}
					//cNumSC7 := Criavar("C7_NUM",.T.)

					//|Busca o número do pedido de compra |
					cNumSC7	:= SFP003(AllTrim(oBrw1:aCols[nI,1])) //GetSXENum("SC7","C7_NUM")

					//Se for o processo de compras ira pegar o fabricante como fornecedor no pedido
					IF nComDis < 2
					 	cFornec	:= oBrw1:aCols[nI,5]
					 	cFornec	:= Posicione("SA2", 2, xFilial("SA2")+ALLTRIM(cFornec),"A2_COD")

					 	cFilEntr:= MV_PAR14
					Else // Se for o processo de distribuicao o peedido de compra sera feito contra a filial centralizadora.
						cFornec	:= cForCen
						cFilEntr:= oBrw1:aCols[nI,1]
					EndIf

					// Cabeçalho do pedido de compra
					_aCab:={	{"C7_FILIAL"	,oBrw1:aCols[nI,1] 			,NIL},;
							{"C7_NUM"		,cNumSC7		 	 			,NIL},;			// Data de Emissao
							{"C7_EMISSAO"	,dDataBase		 	 		,NIL},;			// Data de Emissao
							{"C7_FORNECE"	,cFornec						,NIL},;		   	// Fornecedor
							{"C7_LOJA"	,"01"						,NIL},;       	// Loja do Fornecedor
							{"C7_CONTATO"	,CriaVar("C7_CONTATO",.F.)		,NIL},;			// Contato
							{"C7_COND"	,cCondPag						,NIL},;        	// Condicao de Pagamento
							{"C7_FILENT"	,cFilEntr						,NIL},;  			// Filial de Entrega
							{"C7_FILCEN"	,cFilEntr						,NIL},;  			// Filial de Entrega
							{"C7_FRETE"	,CriaVar("C7_FRETE",.F.)		,NIL},;    		//Frete
							{"C7_DESPESA"	,CriaVar("C7_DESPESA",.F.)		,NIL},;			//Despesa
							{"C7_SEGURO"	,CriaVar("C7_SEGURO",.F.)		,NIL},;  			//Seguro
							{"C7_MSG"		,CriaVar("C7_MSG",.F.)			,NIL},;        	//Mensagem
							{"C7_REAJUST"	,CriaVar("C7_REAJUST",.F.)		,NIL}} 			//Reajuste
		           	cForFil := oBrw1:aCols[nI,nPosFor]
				   	cIte	:= "0001"

				   	cMensagem 	+= 'Filial: '+ oBrw1:aCols[nI,1] + '     Pedido de Compra: '+ cValToChar(cNumSC7)	+ CHR(13)+CHR(10)

				EndIf

			dBSelectArea("AIB")
			AIB->(dbSetOrder(2))

			dBSelectArea("SBZ")
			SBZ->(dbSetOrder(1))
			SBZ->(dbSeek(	MV_PAR14	+	oBrw1:aCols[nI,2]	))

			dBSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(	xFilial("SB1")	+	oBrw1:aCols[nI,2]	))

			If AIB->(dbSeek(xFilial("AIB")+SB1->(B1_PROC+B1_LOJPROC)+"001"+SB1->B1_COD))
				nVlrUni := AIB->AIB_PRCCOM
			Else
				nVlrUni := 10
			EndIf

			// so ira comprar se tiver itens a serem comprados
		    IF oBrw1:aCols[nI,7] > 0
				// Itens do pedido de compra.
				aAdd(_aItem,{		{"C7_ITEM"		,cIte					   			,NIL},; 		//Item
								{"C7_PRODUTO"	,oBrw1:aCols[nI,2]		   					,NIL},;   	//Produto
								{"C7_QUANT"	,oBrw1:aCols[nI,7] 		   				,NIL},;   	//Quantidade
								{"C7_PRECO"	,nVlrUni									,NIL},;    	//Preco unitario
								{"C7_TOTAL"	,(oBrw1:aCols[nI,7]* nVlrUni)				,NIL},;    	//Valor total
								{"C7_DESC"	,CriaVar("C7_DESC",.F.)					,Nil},;    	//Desconto
								{"C7_IPI"		,CriaVar("C7_IPI",.F.)						,NIL},;    	//IPI
								{"C7_IPIBRUT"	,'B'										,NIL},;    	//IPI Bruto
								{"C7_REAJUST"	,CriaVar("C7_REAJUST",.F.)					,NIL},;    	//Reajuste
								{"C7_FRETE"	,CriaVar("C7_FRETE",.F.)					,NIL},;    	//Frete
					 			{"C7_DATPRF"	,ddatabase								,NIL},;    	//Data de entrega
								{"C7_LOCAL"	,"01"									,NIL},;    	//Local
								{"C7_MSG"		,CriaVar("C7_MSG",.F.)						,NIL},;    	//Mensagem
						  		{"C7_TPFRETE"	,CriaVar("C7_TPFRETE",.F.)					,NIL},;    	//Tipo de frete
						 		{"C7_OBS"		,CriaVar("C7_OBS",.F.)						,NIL},;    	//Observacao
						 		{"C7_CONTA"	,CriaVar("C7_CONTA",.F.)					,NIL},;    	//Conta do produto
						 		{"C7_CC"		,CriaVar("C7_CC",.F.)						,NIL}}) 		//Centro de custo
			EndIf

			cIte := Soma1(cIte)
			IF Len(oBrw1:aCols) <> nI
				IF cForFil <> oBrw1:aCols[nI+1 , nPosFor]
					// Cria o ultimo pedido
					CriaPd( _aCab	,_aItem , 3 , 1)
				EndIf
		  	Else
					CriaPd( _aCab	,_aItem , 3 , 1)
			EndIf
		Next nI
	EndIf

	//|Verifica se há log para ser visualizado |
	If !Empty(cMensagem)
		//|Tela de log com resumo da operação |
		xLog()
	Endif

	MsgInfo("Pedidos gerados com sucesso.","Central de Compras")
	oDlg2:End()

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AAPCOM13  ºAutor  ³Microsiga           º Data ³  01/16/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                      //                  - Indica se e 1 - Compra , 2 - Venda
Static Function CriaPd(_aCab,_aItem,nAcao,nComVen)

	Local cFilAtu   	:= cFilAnt
	Private lMsErroAuto 	:= .F.


	// se for sem itens nao fazer o pedido
	IF Empty(_aItem)
		Return()
	EndIf

	// troca para filial que vai ser gerado o pedido
	cFilAnt	:= IIF ( nComVen == 1 , 	_aCab[1,2] , MV_PAR14 )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa rotina automatica para geracao do       ³
	//³ pedido de compra                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Controle de Transacao
	Begin Transaction

	IF nComVen == 1
		// Rotina automática para inclusão do pedido de compras
		MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,_aCab,_aItem,3)
	ElseIf nComVen == 2
		// Rotina automática para inclusão do pedido de vendas
		//MSExecAuto({|x,y,z|     Mata410(x,y,z)  },_aCab,_aItem,nAcao)
		//MSExecAuto({|x,y,z| OFIXX001(x,y,{{}},z)  },_aCab,_aItem,nAcao) - Não funcionou
		CriaVS1(_aCab,_aItem)

	EndIf

	ConfirmSx8()

	// Caso Ocorra algum erro
	If lMsErroAuto
		// Cncela transação
		DisarmTransaction()
		MsgAlert("Não foi Possível Gerar o pedido de compra.","[AAPCOM13] -Verificação geracao do pedido")

	//	 Mostra o erro para o usuário
		MostraErro()

		Return()
	EndIF

	// Grava transação
	End Transaction

	cFilAnt	:=	cFilAtu

//	//|Verifica se há log para ser visualizado |
//	If !Empty(cMensagem)
//		//|Tela de log com resumo da operação |
//		xLog()
//	Endif

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AAPCOM13  ºAutor  ³Microsiga           º Data ³  03/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Carreg(nRoti)

	IF nRoti == 1

		//|Força a atualização dos parametros |
		COM13001(.F.)
		MsgRun("O FILTRO ESTA SENDO PROCESSADO!","Processando",{|| Com13002() })

	ElseIf nRoti == 2
		MsgRun("OS PEDIDOS ESTÃO SENDO CRIADOS!","Processando",{|| CriPeCom()})

	EndIf



Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AAPCOM13  ºAutor  ³Henrique           º Data ³  06/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria o orçamento por fases de transferencia                º±±
±±ºAut       ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaVS1(aCab, aItem)
	Local nI := 1
	Local nX := 1

	Private bCampo    := {|nField| FieldName(nField) }

	//Grava os itens
	For nI := 1 To Len( aItem )
		RecLock("VS3",.T.)
		For nX := 1 To Len( aItem[nI] )
			FieldPut( FieldPos(rTrim( aItem[nI, nX, 1] )) ,aItem[nI, nX, 2] )
		Next nX

		VS3->(MsUnLock())
	Next nI

	// Grava o Cabeçalho
	dbSelectArea( 'VS1' )
	RecLock( 'VS1', .T. )
	For nX := 1 To Len(aCab)
		FieldPut( FieldPos(rTrim( aCab[nX, 1] )) ,aCab[nX, 2] )
	Next nX
	VS1->(MsUnLock())

Return


//------------------------------------------------------------------------------------------------
//Tela de resumo final da operação
Static Function xLog()

	Local oDlg
	Local oGet
	Private cTexto := ""
	Private cFileRem
	Private nHdl

	cTexto += 'Segue abaixo os registros gerados pela Central de Compras/Distribuição: ' +CHR(13)+CHR(10)
	cTexto += cMensagem

	DEFINE MSDIALOG oDlg Title "Resumo Central de Compras" From 000,000	To 350,400 Pixel

		@ 005,005 Get oGet VAR cTexto MEMO SIZE 150,150 Of oDlg Pixel
		oGet:bRClicked := {||AllwaysTrue()}

		DEFINE SBUTTON FROM 005,165 TYPE 13 ACTION {||xImp(),oDlg:End()} ENABLE OF	oDlg Pixel
		DEFINE SBUTTON FROM 020,165 TYPE 1  ACTION {||oDlg:End() 		} ENABLE OF	oDlg Pixel

	ACTIVATE MSDIALOG oDlg CENTER

Return

//-------------------------------------------------------------------------------------------------------
//Função para operação de salvar do log
Static Function xImp()

	cFileRem	:= cGetFile("Arquivos TXT|*.TXT",OemToAnsi("Salvar Arquivo..."),,'C:\',.F.)
	nHdl		:= fCreate(cFileRem+cValToChar(Year(ddatabase))+cValToChar(Month(ddatabase))+;
						cValToChar(Day(ddatabase))+'-'+Substr(Time(),1,2)+Substr(Time(),4,2)+'.txt')
	If nHdl == -1
		MsgAlert('Falha ao copiar arquivo para o servidor')
	Endif

	fWrite(nHdl,cTexto)
	fClose(nHdl)

Return


/*/{Protheus.doc} SFP001
Função para buscar as informaçoes necessarias de vendas e medias
@author pontin
@since 23/07/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function SFP001()

	Local aArea			:= GetArea()
	Local aAreaM0			:= SM0->(GetArea())
	Local cFilAutoGiro		:= SuperGetMV("MV_YFILGIR",.F.,"AAPES001")
	Local aCampos			:= {}
	Local aTam			:= {}
	Private cFilFornec		:= ""
	Private cFilLocal		:= ""
	Private cFilGrupo		:= ""

	//|TABELA PARA AUDITORIA DO CALCULO |
	aTam := TamSX3('ZZ_FILIAL')		; aAdd(aCampos, {'AUD_FILIAL'	, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_COD')		; aAdd(aCampos, {'AUD_COD'		, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_CODITE')		; aAdd(aCampos, {'AUD_CODITE'	, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_APLIC')		; aAdd(aCampos, {'AUD_APLIC'	, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_NOMFAB')		; aAdd(aCampos, {'AUD_NOMFAB'	, 'C',aTam[1] ,aTam[2] })
	aTam := TamSX3('D1_QUANT')		; aAdd(aCampos, {'AUD_PROJEC'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('D1_QUANT')		; aAdd(aCampos, {'AUD_NECREA'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('D1_QUANT')		; aAdd(aCampos, {'AUD_NECARR'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_CUSTO')		; aAdd(aCampos, {'AUD_CUSTO'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_MEDMES')		; aAdd(aCampos, {'AUD_MEDMES'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_QATU')		; aAdd(aCampos, {'AUD_QTDFIL'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_QTDPED')		; aAdd(aCampos, {'AUD_QTDPED'	, 'N',aTam[1] ,aTam[2] })
	aTam := TamSX3('ZZ_QTDTRAN')	; aAdd(aCampos, {'AUD_QTDTRA'	, 'N',aTam[1] ,aTam[2] })

	//|Verifica area aberta |
	If Select("AUDIT") <> 0
		AUDIT->(dbCloseArea())
	EndIf

	cNomeArq := CriaTrab(aCampos)
	dbUseArea(.T.,,cNomeArq,'AUDIT',.F.,.F.)

	//Adiciona no filtro os fornecedores.
	For nI:=1 To Len(aLisFor)
		IIf( nI = 1 , cFilFornec += " AND ( " ,  )
		lEntrou := .T.
		cFilFornec += " SZZ.ZZ_FABRIC "
		cFilFornec += IIf( nRadGro == 1 , " = " , " <> " )
		cFilFornec += "'"+SubStr(aLisFor[nI], 1 , TAMSX3("ZZ_FABRIC")[1]) +"'"
		IIf( nI <> Len(aLisFor) , IIf ( nRadGro == 1 , cFilFornec += " OR " ,cFilFornec += " AND " )  , cFilFornec += ")"  )
	Next nI

	//Adiciona no filtro de locais
	For nI:=1 To Len(aLisFor2)
		IIf( nI = 1 , cFilLocal += " AND ( " ,  )
		cFilLocal += " SZZ.ZZ_LOCALIZ "
		cFilLocal += IIf( nRadGro2 == 1 , " = " , " <> " )
		cFilLocal += "'"+aLisFor2[nI] +"'"
		IIf( nI <> Len(aLisFor2) , IIf ( nRadGro2 == 1 , cFilLocal += " OR " ,cFilLocal += " AND " )  , cFilLocal += ")"  )
	Next nI

	// Adiciona no filtro de grupos
	For nI:=1 To Len(aLisFor3)
		IIf( nI = 1 , cFilGrupo += " AND ( " ,  )
		cFilGrupo += " SZZ.ZZ_GRUPO "
		cFilGrupo += IIf( nRadGro3 == 1 , " = " , " <> " )
		cFilGrupo += "'"+SubStr(ALLTRIM(aLisFor3[nI]),1,4) +"'"
		IIf( nI <> Len(aLisFor3) , IIf ( nRadGro3 == 1 , cFilGrupo += " OR " ,cFilGrupo += " AND " )  , cFilGrupo += ")"  )
	Next nI

	oProcess:SetRegua1(30)

	//|Processa todas as filiais selecionadas |
	TRB->(dbGoTop())
	While !TRB->(EoF())

		If AllTrim(TRB->T_FILIAL) == AllTrim(MV_PAR14) .Or. Empty(TRB->T_OK)
			TRB->(dbSkip())
			Loop
		EndIf

		oProcess:IncRegua1("Processando Filial: " + TRB->T_FILIAL)
		//|Busca informações da filial posicionada |
		SFP002(TRB->T_FILIAL)

		TRB->(dbSkip())

	EndDo

	oProcess:IncRegua1("Processando Centralizadora: " + MV_PAR14)
	//|Busca informações da centralizadora; |
	SFP002(MV_PAR14,.T.)

	RestArea(aAreaM0)
	RestArea(aArea)

Return


/*/{Protheus.doc} SFP002
Função para carregar os dados de cada filial

@author pontin
@since 23/07/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function SFP002(cFilFil,lCentral)

	Local cQry			:= ""
	Local nNeces			:= 0
	Local nProjecao		:= 0

	Default lCentral	:= .F.

	If Select("__TRB") > 0
		__TRB->(dbCloseArea())
	EndIf
	cQry += " SELECT ZZ_COD,ZZ_QTDVEND,ZZ_MEDMES,ZZ_CUSTO,ZZ_FABRIC,ZZ_NOMFAB,ZZ_APLIC,ZZ_CODITE,ZZ_QATU,ZZ_MEDIA,ZZ_QTDPED,ZZ_QTDTRAN "
	cQry += " FROM " + RetSqlName("SZZ") + " SZZ (NOLOCK) "
	cQry += " WHERE ZZ_FILIAL = " + ValToSql(AllTrim(cFilFil))
	If !lCentral
		cQry += " 	AND ZZ_MEDMES BETWEEN " + ValToSql(MV_PAR17) + " AND " + ValToSql(MV_PAR24)
	EndIf
	cQry += cFilFornec
	cQry += cFilLocal
	cQry += cFilGrupo
	cQry += " 	ORDER BY ZZ_FILIAL,ZZ_FABRIC,ZZ_COD "
	TcQuery cQry New Alias "__TRB"

	__TRB->(dbGoTop())

	oProcess:SetRegua2(__TRB->(LastRec()))
	While !__TRB->(EoF())

		If __TRB->ZZ_MEDMES >= MV_PAR17 .And.  __TRB->ZZ_MEDMES <=  MV_PAR18		//|Projecao 01
			nProjecao		:= MV_PAR19
		ElseIf __TRB->ZZ_MEDMES >= MV_PAR20 .And.  __TRB->ZZ_MEDMES <=  MV_PAR21		//|Projecao 02
			nProjecao		:= MV_PAR22
		ElseIf __TRB->ZZ_MEDMES >= MV_PAR23 .And.  __TRB->ZZ_MEDMES <=  MV_PAR24		//|Projecao 03
			nProjecao		:= MV_PAR25
		Else
			nProjecao		:= 0
		EndIf

		nMedia	:= __TRB->ZZ_MEDIA

		nNeces	:= Ceiling(nMedia * nProjecao)

		nNeces	:= Ceiling(nNeces - IIf(__TRB->ZZ_QATU<0,0,__TRB->ZZ_QATU) - __TRB->ZZ_QTDPED - __TRB->ZZ_QTDTRAN)

		RecLock("AUDIT",.T.)
		AUDIT->AUD_FILIAL		:= AllTrim(cFilFil)
		AUDIT->AUD_COD			:= __TRB->ZZ_COD
		AUDIT->AUD_CODITE		:= __TRB->ZZ_CODITE
		AUDIT->AUD_APLIC		:= __TRB->ZZ_APLIC
		AUDIT->AUD_NOMFAB		:= __TRB->ZZ_NOMFAB
		AUDIT->AUD_PROJEC		:= nProjecao
		AUDIT->AUD_NECREA		:= nMedia * nProjecao
		AUDIT->AUD_NECARR		:= Ceiling(nMedia * nProjecao)
		AUDIT->AUD_CUSTO		:= __TRB->ZZ_CUSTO
		AUDIT->AUD_MEDMES		:= __TRB->ZZ_MEDMES
		AUDIT->AUD_QTDFIL		:= __TRB->ZZ_QATU
		AUDIT->AUD_QTDPED		:= __TRB->ZZ_QTDPED
		AUDIT->AUD_QTDTRA		:= __TRB->ZZ_QTDTRAN
		AUDIT->(MsUnLock())

		If nNeces < 0
			nNeces	:= 0
		EndIf

		If nNeces == 0 .And. !lCentral
			__TRB->(dbSkip())
			Loop
		EndIf

		oProcess:IncRegua2("Processando Fabricante: " + __TRB->ZZ_NOMFAB)

		If !lCentral	//|Indica que nao é filial centralizadora |

			If TRB_XX->(dbSeek(__TRB->ZZ_COD))
				RecLock("TRB_XX",.F.)
			 	TRB_XX->XX_NECREAL 	+= nNeces
			 	TRB_XX->XX_MEDMES	+= __TRB->ZZ_MEDMES
			 	TRB_XX->XX_QTDFIL	+= __TRB->ZZ_QATU
			 	TRB_XX->(MsUnLock())
			 Else
			 	RecLock("TRB_XX",.T.)
			 	TRB_XX->XX_COD 		:= __TRB->ZZ_COD
			 	TRB_XX->XX_CODITE	:= __TRB->ZZ_CODITE
			 	TRB_XX->XX_APLIC	:= __TRB->ZZ_APLIC
			 	TRB_XX->XX_NOMFAB	:= __TRB->ZZ_NOMFAB
			 	TRB_XX->XX_CUSTO	:= __TRB->ZZ_CUSTO
			 	TRB_XX->XX_NECREAL 	:= nNeces
			 	TRB_XX->XX_MEDMES	:= __TRB->ZZ_MEDMES
			 	TRB_XX->XX_QTDFIL	:= __TRB->ZZ_QATU
			 	TRB_XX->(MsUnLock())
			 EndIf

		Else

			If TRB_XX->(dbSeek(__TRB->ZZ_COD))

				nNeces	:= Ceiling((nMedia * nProjecao) + TRB_XX->XX_NECREAL) - IIf(__TRB->ZZ_QATU<0,0,__TRB->ZZ_QATU) - __TRB->ZZ_QTDPED - __TRB->ZZ_QTDTRAN

				If nNeces < 0
					nNeces	:= 0
				EndIf

				RecLock("TRB_XX",.F.)
			 	TRB_XX->XX_NECREAL := nNeces
			 	TRB_XX->XX_MEDMES	+= __TRB->ZZ_MEDMES
			 	TRB_XX->XX_QTDCENT	:= __TRB->ZZ_QATU
			 	TRB_XX->(MsUnLock())

			 ElseIf nNeces > 0

			 	RecLock("TRB_XX",.T.)
			 	TRB_XX->XX_COD 	:= __TRB->ZZ_COD
			 	TRB_XX->XX_CODITE	:= __TRB->ZZ_CODITE
			 	TRB_XX->XX_APLIC	:= __TRB->ZZ_APLIC
			 	TRB_XX->XX_NOMFAB	:= __TRB->ZZ_NOMFAB
			 	TRB_XX->XX_CUSTO	:= __TRB->ZZ_CUSTO
			 	TRB_XX->XX_NECREAL := nNeces
			 	TRB_XX->XX_MEDMES	:= __TRB->ZZ_MEDMES
			 	TRB_XX->XX_QTDCENT	:= __TRB->ZZ_QATU
			 	TRB_XX->XX_QTDFIL	:= 0
			 	TRB_XX->(MsUnLock())
			 EndIf

		EndIf

		__TRB->(dbSkip())

	EndDo

Return


Static Function SFP007()

	Local aStructPri 	:= AUDIT->(dbStruct())
	Local cDirDocs   	:= MsDocPath()
	Local cArquivo 	:= CriaTrab(,.F.)
	Local cCrLf 		:= Chr(13) + Chr(10)
	Local cPath		:= AllTrim(GetTempPath())

	ProcRegua(AUDIT->(RecCount()))

	nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".CSV",0)

	If nHandle > 0

		//|Grava o cabecalho do arquivo |
		IncProc("Aguarde! Gerando arquivo de integração com Excel...")
		aEval(aStructPri, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aStructPri), ";", "") ) } )
		fWrite(nHandle, cCrLf ) //|Pula linha |

		AUDIT->(dbGoTop())
		While !AUDIT->(EoF())

			IncProc("Aguarde! Gerando arquivo de integração com Excel...")

			fWrite(nHandle, AUDIT->AUD_FILIAL + ";" )
			fWrite(nHandle, AUDIT->AUD_COD + ";" )
			fWrite(nHandle, AUDIT->AUD_CODITE + ";" )
			fWrite(nHandle, AUDIT->AUD_APLIC + ";" )
			fWrite(nHandle, AUDIT->AUD_NOMFAB + ";" )
			fWrite(nHandle, Transform(AUDIT->AUD_PROJEC,"@E 999,999,999.99") + ";" )
			fWrite(nHandle, Transform(AUDIT->AUD_NECREAL,"@E 999,999,999.99") + ";" )
			fWrite(nHandle, Transform(AUDIT->AUD_NECARR,"@E 999,999,999.99") + ";" )
			fWrite(nHandle, Transform(AUDIT->AUD_CUSTO,"@E 999,999,999.99") + ";" )
			fWrite(nHandle, Transform(AUDIT->AUD_MEDMES,"@E 999,999,999.99") + ";" )
			fWrite(nHandle, Transform(AUDIT->AUD_QTDFIL,"@E 999,999,999.99") + ";" )
			fWrite(nHandle, Transform(AUDIT->AUD_QTDPED,"@E 999,999,999.99") + ";" )
			fWrite(nHandle, Transform(AUDIT->AUD_QTDTRA,"@E 999,999,999.99") + ";" )

			fWrite(nHandle, cCrLf ) //|Pula linha |

			AUDIT->( dbSkip() )

		EndDo

		IncProc("Aguarde! Abrindo o arquivo...")

		fClose(nHandle)
		CpyS2T( cDirDocs+"\"+cArquivo+".CSV" , cPath, .T. )

		If !ApOleClient( 'MsExcel' )
			MsgAlert("MsExcel nao instalado")
			Return
		EndIf

		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) //|Abre uma planilha |
		oExcelApp:SetVisible(.T.)
	Else
		MsgAlert("Falha na criação do arquivo")
	Endif

Return



Static Function SFP003(cFilSC7)

	Local cNum		:= ""
	Local cRet		:= ""
	Local cQuery	:= ""
	Local nCont		:= 0
	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())


	While .T.

		cNum	:= GetSXENum("SC7","C7_NUM")
		nCont++

		ConfirmSX8()

		cQuery := ""
		cQuery += " SELECT  COUNT(*) AS QUANT "
		cQuery += " FROM    " + RetSqlName("SC7") + " S "
		cQuery += " WHERE   S.C7_FILIAL = " + ValToSql(cFilSC7)
		cQuery += "         AND S.C7_NUM = " + ValToSql(cNum)
		cQuery += "         AND S.D_E_L_E_T_ = '' "

		If Select("__SC7") > 0
			__SC7->(dbCloseArea())
		EndIf

		TcQuery cQuery New Alias "__SC7"

		If __SC7->QUANT == 0

			cRet	:= cNum
			Exit

		EndIf

		//|Não encontrou numeração valida pelo GetSXENum após 5 tentativas |
		If nCont >= 5

			cQuery := ""
			cQuery += " SELECT  MAX(C7_NUM) AS MAX "
			cQuery += " FROM    " + RetSqlName("SC7") + " S "
			cQuery += " WHERE   S.C7_FILIAL = " + ValToSql(cFilSC7)
			cQuery += "         AND S.C7_NUM < '200000' "
			cQuery += "         AND S.D_E_L_E_T_ = '' "

			If Select("__SC7") > 0
				__SC7->(dbCloseArea())
			EndIf

			TcQuery cQuery New Alias "__SC7"

			cRet	:= Soma1(__SC7->MAX)
			Exit

		EndIf

	EndDo

	RestArea(aAreaSC7)
	RestArea(aArea)

Return cRet
