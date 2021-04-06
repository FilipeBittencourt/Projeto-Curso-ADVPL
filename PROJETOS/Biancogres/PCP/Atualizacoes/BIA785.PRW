#DEFINE __INICIO   1
#DEFINE __PRIOR    2
#DEFINE __PRODUTO  3
#DEFINE __DESCRIC  4
#DEFINE __QUANT    5
#DEFINE __MOINHO   6
#DEFINE __NUMOP    7
#DEFINE __ITEM     8
#DEFINE __SEQUEN   9
#DEFINE __ENTREG  10

#DEFINE IMP_SPOOL 2

#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   010                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2 044                                                // Máximo de produtos para a pagina 2 (caso nao utilize a opção de impressao em verso)
#DEFINE MAXITEMP3 015                                                // Máximo de produtos para a pagina 2 (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMP4 022                                                // Máximo de produtos para a pagina 2 (caso contenha main info cpl que suporta a primeira pagina)
#DEFINE MAXITEMC  012                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN 110                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG    006                                                // Máximo de dados adicionais na primeira página
#DEFINE MAXMSG2   019                                                // Máximo de dados adicionais na segunda página
#DEFINE MAXBOXH   800                                                // Tamanho maximo do box Horizontal
#DEFINE MAXBOXV   600
#DEFINE INIBOXH   -10
#DEFINE MAXMENL   080                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXVALORC 008                                                // Máximo de caracteres por linha de valores numéricos

#Include "Protheus.ch"
#include "topconn.ch"
#include "TOTVS.CH"
#include "rwmake.ch"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} BIA785
@author Marcos Alberto Soprani
@since 26/07/11
@version 1.0
@description Montagem de Carga para separação ou preparação para Moagem.
@type function
/*/

User Function BIA785()

	Local zpArea     := GetArea()
	Private cfValid  := .T.
	Private cj_Fecha := .T.
	Private fh_Esc   := .F.
	Private cObs1    := ""
	Private oObs1
	Private zoNwDad1
	Private rjNwDad1
	Private zoNwRec2
	Private zoNwApro1
	Private zoNwAdic1
	Private cf_C2OP
	Private nRadMenu1f := 0 // Usado para identificar o que fazer com a fatoração das cargas
	Private cTM := "010"
	Private xk_ArrSp
	Private xk_ArSim
	Private INCLUI     := .T.

	Private bErro := ErrorBlock( { |oErr|  MsgAlert(oErr:Description) })

	Private _cEmpSeq	

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YBLQRCM")
		CriarSX6("MV_YBLQRCM", 'L', 'Controle de Bloqueio de Rotinas do CMV', ".F." )
	EndIf

	fPerg := "BIA785"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cEmpSeq	:=	Iif(MV_PAR10 == 1,'1','2')

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	xf_IndSel := "por "
	If MV_PAR11 == 1
		xf_IndSel := "(Data / Cod.Esmalte)"
	ElseIf MV_PAR11 == 2
		xf_IndSel := "(Data / Prod. Pai)"
	ElseIf MV_PAR11 == 3
		xf_IndSel := "(Cod.Esmalte / Data)"
	ElseIf MV_PAR11 == 4
		xf_IndSel := "(Prod. Pai / Data)"
	EndIf

	// Tratamento para não permitir que o usuário da pesagem escolha alguma carga diferente da que se destina a pesagem
	If __cUserID $ GetMv("MV_YUSRPES") .and. !__cUserID $ GetMv("MV_YUSRTOT")
		MV_PAR05 := "PI02"
		MV_PAR06 := 3
		MV_PAR11 := 1
	EndIf

	oFont1     := TFont():New( "Arial Black",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont2     := TFont():New( "Courier New",0,-10,,.T.,0,,700,.F.,.F.,,,,,, )
	oDlg1      := MSDialog():New( nLin*.001, nCol*.001, nLin*.88, nCol*.975, "Montagem de Carga - " + xf_IndSel,,,.F.,,,,,,.T.,,,.T. )

	cMarca := GetMark()
	vt_TotVlr := Transform(0,"@E 99,999,999.99")
	oTbl1()
	dbSelectArea("MARK")
	ky_Vet := {{"OK"     ,"" ,"Ok"          ,"@!"},;
	{           "DTPRI"  ,"" ,"DtPri"       ,"@!"},;
	{           "DIASEM" ,"" ,"DiaSem"      ,"@!"},;
	{           "PRDPAI" ,"" ,"ProdPai"     ,"@!"},;
	{           "QTDPAI" ,"" ,"QtdPai"      ,"@E 999,999.99"},;
	{           "ESMALT" ,"" ,"PI"          ,"@!"},;
	{           "NECESS" ,"" ,"Necess"      ,"@E 999,999.99"},;
	{           "MOINHO" ,"" ,"Moinho"      ,"@!"},;
	{           "NUMOP"  ,"" ,"OP"          ,"@!"},;
	{           "ITEM"   ,"" ,"It"          ,"@!"},;
	{           "SEQUEN" ,"" ,"Seq"         ,"@!"},;
	{           "CODESM" ,"" ,"Cod PI"      ,"@!"},;
	{           "REVISA" ,"" ,"Revisao"     ,"@!"},;
	{           "STAREV" ,"" ,"Status Rev"  ,"@!"},;
	{           "STAOPR" ,"" ,"Status OP"   ,"@!"} }

	aCores := {}
	aAdd(aCores,{"MARK->STAOPR == ' '" , "BR_VERDE"	   })
	aAdd(aCores,{"MARK->STAOPR == '1'" , "BR_LARANJA"  })
	aAdd(aCores,{"MARK->STAOPR == '2'" , "BR_AZUL"     })
	aAdd(aCores,{"MARK->STAOPR == '3'" , "BR_BRANCO"   })
	aAdd(aCores,{"MARK->STAOPR == '5'" , "BR_AMARELO"  })
	aAdd(aCores,{"MARK->STAOPR == '4'" , "BR_VERMELHO" })

	oBrw1      := MsSelect():New( "MARK","OK","",ky_Vet ,.F.      ,@cMarca,{nLin*.008,nCol*.005,nLin*.330,nCol*.485},,, oDlg1 ,,aCores )
	oBrw1:bMark := {| | gTotVlr()}
	oBtn1      := TButton()  :New( nLin*.392,nCol*.460,"Fechar"       ,oDlg1,{|| cj_Fecha := .F., fh_Esc := .T., oDlg1:End()     },nLin*.040,nCol*.020,,,,.T.,,"",,,,.F. )

	// _________________: Tratamento de visualização para os Botoes :_________________
	xl_Tudo := .F.
	If __cUserID $ GetMv("MV_YUSRTOT") 

		xl_Tudo := .T.

		oBrw1:oBrowse:bChange :=  { || fxObser() }

		oBtn2      := TButton()  :New( nLin*.392,nCol*.420,"Carga"       ,oDlg1,{|| fh_Esc := .T., ExecBlock("BCAR785"   ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. ) // Monta a Carga
		oBtn11     := TButton()  :New( nLin*.417,nCol*.420,"Baixar"      ,oDlg1,{|| fh_Esc := .T., ExecBlock("BBXA785"   ,.F.,.F.)     },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. ) // Baixa a Carga

		oBtn3      := TButton()  :New( nLin*.392,nCol*.380,"Sequenciar"  ,oDlg1,{|| fh_Esc := .T., ExecBlock("BSEQ785"   ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. ) // Monta a sequencia de separação das Cargas
		oBtn4      := TButton()  :New( nLin*.417,nCol*.380,"<< Pesar"    ,oDlg1,{|| fh_Esc := .T., ExecBlock("BFIR785"   ,.F.,.F.,"2") },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. ) // Transfere o status da OP para Pesagem

		oBtn5      := TButton()  :New( nLin*.392,nCol*.340,"Composição"  ,oDlg1,{|| fh_Esc := .T., ExecBlock("BIASP785"  ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. ) // Lista a composição da formula gravada no Empenho
		oBtn6      := TButton()  :New( nLin*.417,nCol*.340,"<< Separar"  ,oDlg1,{|| fh_Esc := .T., ExecBlock("BFIR785"   ,.F.,.F.,"3") },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. ) // Transfere o status da OP para Separadas

		oBt11      := TButton()  :New( nLin*.392,nCol*.300,"Pesar"       ,oDlg1,{|| fh_Esc := .T., ExecBlock("BPESAX785" ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. ) // Só gera a formulação em .pdf
		oBtn8      := TButton()  :New( nLin*.417,nCol*.300,"Finalizar"   ,oDlg1,{|| fh_Esc := .T., ExecBlock("BFIR785"   ,.F.,.F.,"4") },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. ) // Dá baixa nas OPs que não serão produzidas

		oBt10      := TButton()  :New( nLin*.392,nCol*.260,"Aproveitar"  ,oDlg1,{|| fh_Esc := .T., ExecBlock("B785APRO"  ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. )
		oBtn17     := TButton()  :New( nLin*.392,nCol*.220,"Adicionar"   ,oDlg1,{|| fh_Esc := .T., ExecBlock("B785ADIC"  ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. )
		oBtn9      := TButton()  :New( nLin*.392,nCol*.140,"Ajustar"     ,oDlg1,{|| fh_Esc := .T., ExecBlock("BSCOR785"  ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. )

		oBt15      := TButton()  :New( nLin*.392,nCol*.100,"Legenda"     ,oDlg1,{|| ExecBlock("BIA785K",.F.,.F.)                       },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. )

		oObs1      := TMultiget():New( nLin*.335,nCol*.005,{|u|if(Pcount()>0,cObs1:=u,cObs1)}, oDlg1, nCol*.480, 30, oFont2, .T., , , , .T., , , , , , .T., , , , .F., .T.)

	EndIf

	// _________________: Tratamento de visualização para os Botoes :_________________
	If __cUserID $ GetMv("MV_YUSRPES") .and. !xl_Tudo

		oBtn6      := TButton()  :New( nLin*.392,nCol*.320,"Baixar /\"   ,oDlg1,{|| fh_Esc := .T., ExecBlock("BFIR785"   ,.F.,.F.,"3") },nLin*.050,nCol*.020,,,,.T.,,"",,,,.F. ) // Transfere o status da OP para Separadas
		oBt11      := TButton()  :New( nLin*.392,nCol*.200,"Pesar"       ,oDlg1,{|| fh_Esc := .T., ExecBlock("BPESAX785" ,.F.,.F.)     },nLin*.040,nCol*.020,,,,.T.,,"",,,,.F. ) // Só gera a formulação em .pdf

	EndIf

	// _________________: Tratamento de visualização para os Botoes :_________________
	If __cUserID $ GetMv("MV_YUSRCOR") .and. !xl_Tudo
		oBtn2      := TButton()  :New( nLin*.392,nCol*.420,"Carga"       ,oDlg1,{|| fh_Esc := .T., ExecBlock("BCAR785"   ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. ) // Monta a Carga
		oBtn6      := TButton()  :New( nLin*.417,nCol*.340,"<< Separar"  ,oDlg1,{|| fh_Esc := .T., ExecBlock("BFIR785"   ,.F.,.F.,"3") },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. ) // Transfere o status da OP para Separadas
		oBtn5      := TButton()  :New( nLin*.392,nCol*.340,"Composição"  ,oDlg1,{|| fh_Esc := .T., ExecBlock("BIASP785"  ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. ) // Lista a composição da formula gravada no Empenho
		//adição do botão Aproveitar: ticket 30651
		oBt10      := TButton()  :New( nLin*.392,nCol*.260,"Aproveitar"  ,oDlg1,{|| fh_Esc := .T., ExecBlock("B785APRO"  ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. )
		oBtn17     := TButton()  :New( nLin*.392,nCol*.220,"Adicionar"   ,oDlg1,{|| fh_Esc := .T., ExecBlock("B785ADIC"  ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. )
		oBtn9      := TButton()  :New( nLin*.392,nCol*.140,"Ajustar"     ,oDlg1,{|| fh_Esc := .T., ExecBlock("BSCOR785"  ,.F.,.F.)     },nLin*.040,nCol*.010,,,,.T.,,"",,,,.F. )
	EndIf

	oSay1      := TSay()     :New( nLin*.395,nCol*.005,{|| vt_TotVlr },oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,072,020)

	ACTIVATE MSDIALOG oDlg1 CENTERED VALID fh_Esc

	MARK->(dbCloseArea())

	RestArea(zpArea)

	If cj_Fecha
		ExecBlock("BIA785",.F.,.F.)
	EndIf

Return(cfValid)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA785K  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 10.09.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao para apresenta a Cor na tela  - LEGENDA             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA785K()

	Private xcTitulo := "Montagem da Carga"

	Brwlegenda(xcTitulo, "Legenda",{{ "BR_VERDE"      ,"Totalmente em Aberto"}          ,;
	{                                 "BR_LARANJA"    ,"Em Carga"}                      ,;
	{                                 "BR_AZUL"       ,"Sequenciadas"}                  ,;
	{                                 "BR_BRANCO"     ,"Separadas"}                     ,;
	{                                 "BR_AMARELA"    ,"Adicionais"}                    ,;
	{                                 "BR_VERMELHO"   ,"Baixadas"}                      })

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ oTbl1    ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21.10.09 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Cria temporario para o Alias: MARK                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function oTbl1()

	Local aFds := {}
	Local cTmp

	Aadd( aFds , {"OK"      ,"C",002,000} )
	Aadd( aFds , {"DTPRI"   ,"D",008,000} )
	Aadd( aFds , {"DIASEM"  ,"C",010,000} )
	Aadd( aFds , {"PRDPAI"  ,"C",040,000} )
	Aadd( aFds , {"QTDPAI"  ,"N",010,002} )
	Aadd( aFds , {"ESMALT"  ,"C",040,000} )
	Aadd( aFds , {"NECESS"  ,"N",010,002} )
	Aadd( aFds , {"MOINHO"  ,"C",003,000} )
	Aadd( aFds , {"NUMOP"   ,"C",006,000} )
	Aadd( aFds , {"ITEM"    ,"C",002,000} )
	Aadd( aFds , {"SEQUEN"  ,"C",003,000} )
	Aadd( aFds , {"CODESM"  ,"C",015,000} )
	Aadd( aFds , {"REVISA"  ,"C",003,000} )
	Aadd( aFds , {"STAREV"  ,"C",015,000} )
	Aadd( aFds , {"STAOPR"  ,"C",001,000} )

	cTmp := CriaTrab( aFds, .T. )
	Use (cTmp) Alias MARK New Exclusive

	A0001 := " SELECT C2_DATPRI,
	A0001 += "        C2_LINHA,
	A0001 += "        C2_NUM,
	A0001 += "        C2_ITEM,
	A0001 += "        C2_SEQUEN,
	A0001 += "        C2_YMOINHO,
	A0001 += "        (SELECT XC2.C2_PRODUTO
	A0001 += "           FROM "+RetSqlName("SC2")+" XC2  WITH(NOLOCK) "
	A0001 += "          WHERE XC2.C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "            AND XC2.C2_NUM = SC2.C2_NUM
	A0001 += "            AND XC2.C2_ITEM = SC2.C2_ITEM
	A0001 += "            AND XC2.C2_SEQUEN = '001'
	A0001 += "            AND XC2.D_E_L_E_T_ = ' ')PRODPAI,
	A0001 += "        (SELECT XC2.C2_QUANT
	A0001 += "           FROM "+RetSqlName("SC2")+" XC2  WITH(NOLOCK) "
	A0001 += "          WHERE XC2.C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "            AND XC2.C2_NUM = SC2.C2_NUM
	A0001 += "            AND XC2.C2_ITEM = SC2.C2_ITEM
	A0001 += "            AND XC2.C2_SEQUEN = '001'
	A0001 += "            AND XC2.D_E_L_E_T_ = ' ')QTDPAI,
	A0001 += "        SUBSTRING(B1_DESC,1,40) B1_DESC,
	A0001 += "        C2_QUANT - C2_QUJE C2_QUANT,
	A0001 += "        C2_PRODUTO,
	A0001 += "        C2_REVISAO,
	A0001 += "        (SELECT COUNT(*)
	A0001 += "           FROM " + RETSQLNAME("SG1") + " WITH(NOLOCK) "
	A0001 += "          WHERE G1_FILIAL = '"+xFilial("SG1")+"'
	A0001 += "            AND G1_COD = C2_PRODUTO
	A0001 += "            AND G1_REVINI <= C2_REVISAO
	A0001 += "            AND G1_REVFIM >= C2_REVISAO
	A0001 += "            AND G1_INI <= '"+dtos(dDataBase)+"'
	A0001 += "            AND G1_FIM >= '"+dtos(dDataBase)+"'
	A0001 += "            AND D_E_L_E_T_ = ' ') CONTAD,
	A0001 += "        C2_YSTAOPR
	A0001 += "   FROM "+RetSqlName("SC2")+" SC2  WITH(NOLOCK) "
	A0001 += "  INNER JOIN " + RETSQLNAME("SB1") + " SB1 WITH(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                       AND B1_COD = C2_PRODUTO
	A0001 += "                       AND B1_GRUPO = '"+MV_PAR05+"'
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
	A0001 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "    AND C2_DATPRI BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "    AND C2_LINHA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	A0001 += "    AND C2_YSTAOPR <> '4'
	//.....................................Tratamento paara as Ordens de Produção
	If MV_PAR06 == 1                       // Em Abertas
		A0001 += "    AND C2_YSTAOPR = ' '
	ElseIf MV_PAR06 == 2                   // Em Carga
		A0001 += "    AND C2_YSTAOPR = '1'
	ElseIf MV_PAR06 == 3                   // Sequenciadas
		A0001 += "    AND C2_YSTAOPR = '2'
	ElseIf MV_PAR06 == 4                   // Separadas / Adicionais
		A0001 += "    AND C2_YSTAOPR IN('3','5')
	EndIf
	A0001 += "    AND SC2.D_E_L_E_T_ = ' '
	If MV_PAR11 == 1
		A0001 += "  ORDER BY C2_DATPRI, C2_PRODUTO
	ElseIf MV_PAR11 == 2
		A0001 += "  ORDER BY C2_DATPRI, PRODPAI
	ElseIf MV_PAR11 == 3
		A0001 += "  ORDER BY C2_PRODUTO, C2_DATPRI
	ElseIf MV_PAR11 == 4
		A0001 += "  ORDER BY PRODPAI, C2_DATPRI
	EndIf
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGotop()
	While !Eof()
		dbSelectArea("MARK")
		RecLock("MARK",.T.)
		MARK->DTPRI   := stod(A001->C2_DATPRI)
		MARK->DIASEM  := Alltrim(diasemana(stod(A001->C2_DATPRI)))
		MARK->PRDPAI  := Substr(Posicione("SB1",1,xFilial("SB1")+A001->PRODPAI,"B1_DESC"),1,40)
		MARK->QTDPAI  := A001->QTDPAI
		MARK->ESMALT  := A001->B1_DESC
		MARK->NECESS  := A001->C2_QUANT
		MARK->MOINHO  := A001->C2_YMOINHO
		MARK->NUMOP   := A001->C2_NUM
		MARK->ITEM    := A001->C2_ITEM
		MARK->SEQUEN  := A001->C2_SEQUEN
		MARK->CODESM  := A001->C2_PRODUTO
		MARK->REVISA  := A001->C2_REVISAO
		MARK->STAREV  := IIF(A001->CONTAD > 0, "EM LINHA", "VENCIDA")
		MARK->STAOPR  := A001->C2_YSTAOPR
		MsUnLock()
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())

	dbSelectArea("MARK")
	dbGoTop()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fxObser  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 26.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fxObser()

	cObs1 := ""
	p_Ini := 1
	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2") + MARK->NUMOP + MARK->ITEM + MARK->SEQUEN))
	kl_OpQRf := SC2->C2_YOPQREF
	kl_ImpCol := 0
	While !Empty(Substr(kl_OpQRf, p_Ini, 27))
		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2") + Substr(kl_OpQRf, p_Ini, 08) + "001" ))
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO ))
		cObs1 += Substr(kl_OpQRf, p_Ini, 13)+dtoc(SC2->C2_DATPRI)+" Qtd.: "+Substr(kl_OpQRf, p_Ini+13, 14)+"   "+Substr(SB1->B1_DESC,1,40)
		If kl_ImpCol = 0
			cObs1 += Space(05)
			kl_ImpCol := 1
		Else
			cObs1 += CHR(13)+CHR(10)
			kl_ImpCol := 0
		EndIf
		p_Ini += 27
	End
	oObs1:Refresh()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BCAR785  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 26.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Executa acao após click no botao OK                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BCAR785()

	Local oButton1g
	Local oFont1 := TFont():New("Arial",,022,,.F.,,,,,.F.,.F.)
	Local oGet1q
	Local oSay1q
	Local oGet2q
	Local oSay2q
	Local oGet3q
	Local oSay3q
	Local oGet4q
	Local oSay4q

	Local _cLocal	:=	""

	Private oDlgMoi
	Private nGet1q := 0
	Private nGetQRf := 0
	Private nGet2q := 1
	Private nGet3q := Space(3)
	Private nGet4q := Space(3)
	Private fh_Vlr := 0
	Private fh_Produt := ""
	Private fh_Revisa := ""
	Private fh_OpQRef := ""
	Private lMsErroAuto := .F.
	Private fh_CodEsm := ""
	Private fh_VldCEs := .F.
	Private fh_ValidMk := .F.
	Private fh_MenorDt := dDataBase+1000
	Private fh_MaiorDt := dDataBase-1000
	Private fh_Pos
	sd_ValidOp := .F.

	BEGIN SEQUENCE

		If !fCriaSem("CARGA - INICIO")

			Return

		EndIF

		dbSelectArea("MARK")
		dbGoTop()
		While !Eof()
			If MARK->OK == cMarca .and. MARK->NECESS <> 0
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2") + MARK->NUMOP + MARK->ITEM + MARK->SEQUEN))
				nGet4q := SC2->C2_LINHA

				// Implementado em 03/07/12 a pedido do Joan
				If SC2->C2_YSTAOPR > "1"
					MsgINFO("Encontrada OP que já está em processo de carga: "+MARK->NUMOP + MARK->ITEM + MARK->SEQUEN + Chr(13) + Chr(13) + " Favor verificar!!!")
					dbSelectArea("MARK")
					dbSkip()
					Loop
				EndIf

				If SC2->C2_YSTAOPR == "4"
					MsgINFO("Encontrada OP já baixada: "+MARK->NUMOP + MARK->ITEM + MARK->SEQUEN)
					fh_Esc := .F.
					oBrw1:oBrowse:Refresh()
					oBrw1:oBrowse:SetFocus()
					dbSelectArea("MARK")
					dbGoTop()
					Return
				EndIf

				fh_OpQRef += Alltrim(SC2->C2_YOPQREF)
				fh_Vlr    += MARK->NECESS
				fh_Produt := MARK->CODESM
				fh_Revisa := MARK->REVISA
				fh_OpQRef += MARK->NUMOP+MARK->ITEM+MARK->SEQUEN+"  "+Transform(MARK->NECESS,"@E 999,999,999.99")
				If Empty(fh_CodEsm)
					fh_CodEsm := MARK->CODESM
				Else
					If fh_CodEsm <> MARK->CODESM
						fh_VldCEs := .T.
					EndIf
				EndIf
				fh_ValidMk := .T.
				If MARK->DTPRI < fh_MenorDt
					fh_MenorDt := MARK->DTPRI
				EndIf
				If MARK->DTPRI > fh_MaiorDt
					fh_MaiorDt := MARK->DTPRI
				EndIf
				fh_Pos := MARK->(Recno())
			EndIf
			dbSelectArea("MARK")
			dbSkip()
		End

		// Implementado em 03/07/12. Acompanha regra acima para que não prossiga o processamento caso todas as OPs solecionadas já estejam em processo de carga.
		If Empty(fh_OpQRef)
			MsgALERT("Nenhum registro válido para processamento!!!")
			fh_Esc := .F.
			oBrw1:oBrowse:Refresh()
			oBrw1:oBrowse:SetFocus()
			dbSelectArea("MARK")
			dbGoTop()
			Return
		EndIf

		If fh_VldCEs
			MsgALERT("Foram selecionados produtos diferentes para a montagem de carga."+CHR(13)+CHR(13)+"Isto poderia gerar problema no momento da geração da Carga. Favor verificar!!!")
			fh_Esc := .F.
			oBrw1:oBrowse:Refresh()
			oBrw1:oBrowse:SetFocus()
			dbSelectArea("MARK")
			dbGoTop()
			Return
		EndIf

		If !fh_ValidMk
			MsgALERT("Nenhuma OP primária foi marcada. Impossível continuar!!!")
			fh_Esc := .F.
			oBrw1:oBrowse:Refresh()
			oBrw1:oBrowse:SetFocus()
			dbSelectArea("MARK")
			dbGoTop()
			Return
		EndIf

		nGet3q := Posicione("SB1", 1, xFilial("SB1") + fh_Produt, "B1_REVATU")

		cfValid := .F.
		DEFINE MSDIALOG oDlgMoi TITLE "Montagem de Carga" FROM 000, 000  TO 200, 560 COLORS 0, 16777215 PIXEL

		@ 014, 008 SAY oSay1q PROMPT "Informe a Capacidade do Moinho:" SIZE 152, 014 OF oDlgMoi FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 013, 164 MSGET oGet1q VAR nGet1q SIZE 060, 012 OF oDlgMoi PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
		@ 013, 236 BUTTON oButton1g PROMPT "Gerar" SIZE 037, 015 OF oDlgMoi ACTION gGrvCar() PIXEL

		@ 030, 008 SAY oSay2q PROMPT "Limitar a geração de cargas a:" SIZE 152, 014 OF oDlgMoi FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 030, 164 MSGET oGet2q VAR nGet2q SIZE 060, 012 OF oDlgMoi PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
		@ 030, 236 BUTTON oButton1g PROMPT "Fechar" SIZE 037, 015 OF oDlgMoi ACTION (cfValid := .F., oDlgMoi:End()) PIXEL

		@ 047, 008 SAY oSay3q PROMPT "Confirmar a revisão do Produto para OP:" SIZE 152, 014 OF oDlgMoi FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 047, 164 MSGET oGet3q VAR nGet3q SIZE 020, 012 OF oDlgMoi PICTURE "@!" COLORS 0, 16777215 PIXEL

		@ 063, 008 SAY oSay4q PROMPT "Confirmar a LINHA preferencia de USO:" SIZE 152, 014 OF oDlgMoi FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 063, 164 MSGET oGet4q VAR nGet4q SIZE 020, 012 OF oDlgMoi PICTURE "@!" COLORS 0, 16777215 PIXEL

		ACTIVATE MSDIALOG oDlgMoi CENTERED

		If cfValid

			ni_Resto := fh_Vlr
			ni_CtaCrg := 0
			ni_ChNOp := {}
			While .T.
				cNumOp := GetNumSc2()
				ni_CtaCrg ++
				// Tratamento feito para situações é gerada um OP com o saldo
				If ni_Resto-nGet1q <= 0 .and. nRadMenu1f == 3
					fh_MenorDt := fh_MaiorDt
				EndIf
				If fh_MenorDt < dDataBase
					fh_MenorDt := dDataBase
				EndIf
				If nGet1q > 0
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+fh_Produt))

					U_BFG73LIN(nGet4q, fh_Produt, @_cLocal,.F.)

					aMata650  := {{'C2_NUM'      ,cNumOp                                             ,NIL},;
					{              'C2_ITEM'     ,"01"                                               ,NIL},;
					{              'C2_SEQUEN'   ,"001"                                              ,NIL},;
					{              'C2_LINHA'    ,nGet4q                                             ,NIL},;
					{              'C2_PRODUTO'  ,fh_Produt                                          ,NIL},;
					{              'C2_QUANT'    ,nGet1q                                             ,NIL},;
					{              'C2_QTSEGUM'  ,ConvUm(fh_Produt,nGet1q,0,2)                       ,NIL},;
					{              'C2_UM'       ,SB1->B1_UM                                         ,NIL},;
					{              'C2_CC'       ,SB1->B1_CC                                         ,NIL},;
					{              'C2_SEGUM'    ,SB1->B1_SEGUM                                      ,NIL},;
					{              'C2_DATPRI'   ,fh_MenorDt                                         ,NIL},;
					{              'C2_DATPRF'   ,fh_MenorDt                                         ,NIL},;
					{              'C2_REVISAO'  ,nGet3q                                             ,NIL},;
					{              'C2_TPOP'     ,"F"                                                ,NIL},;
					{              'C2_EMISSAO'  ,dDataBase                                          ,NIL},;
					{              'C2_ROTEIRO'  ,SB1->B1_OPERPAD                                    ,NIL},;
					{              'C2_OPC'      ,""                                                 ,NIL},;
					{              'C2_YOPQREF'  ,fh_OpQRef                                          ,NIL},;
					{              'C2_YSTAOPR'  ,IIF(ni_Resto-nGet1q >= 0, "1", " ")                ,NIL},;
					{              'AUTEXPLODE'  ,'S'                                                ,NIL} }
					MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
					If lMsErroAuto
						Mostraerro()
						DisarmTransaction()
						Break
						lMostraErro:= .F.
					Else
						Aadd( ni_ChNOp , {SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN} )
					EndIf
					ni_Resto -= nGet1q
					If ni_Resto > 0
						If ni_CtaCrg < nGet2q
							If ni_Resto < nGet1q
								nGet1q := ni_Resto
							EndIf
						Else
							nGet1q := ni_Resto
						EndIf
					Else
						Exit
					EndIf
				Else
					Exit
				EndIf
			End

			dbSelectArea("MARK")
			dbGoTop()
			While !Eof()
				If MARK->OK == cMarca
					dbSelectArea("SC2")
					dbSetOrder(1)
					If dbSeek(xFilial("SC2")+MARK->NUMOP+MARK->ITEM+MARK->SEQUEN)
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
						aArrayOp  := {{'C2_NUM'      ,SC2->C2_NUM                        ,NIL},;
						{              'C2_ITEM'     ,SC2->C2_ITEM                       ,NIL},;
						{              'C2_SEQUEN'   ,SC2->C2_SEQUEN                     ,NIL},;
						{              'C2_LINHA'    ,SC2->C2_LINHA                      ,NIL},;
						{              'C2_PRODUTO'  ,SC2->C2_PRODUTO                    ,NIL},;
						{              'C2_LOCAL'    ,SC2->C2_LOCAL                      ,NIL},;
						{              'C2_QUANT'    ,SC2->C2_QUANT                      ,NIL},;
						{              'C2_QTSEGUM'  ,SC2->C2_QTSEGUM                    ,NIL},;
						{              'C2_UM'       ,SC2->C2_UM                         ,NIL},;
						{              'C2_CC'       ,SC2->C2_CC                         ,NIL},;
						{              'C2_SEGUM'    ,SC2->C2_SEGUM                      ,NIL},;
						{              'C2_DATPRI'   ,SC2->C2_DATPRI                     ,NIL},;
						{              'C2_REVISAO'  ,SC2->C2_REVISAO                    ,NIL},;
						{              'C2_TPOP'     ,SC2->C2_TPOP                       ,NIL},;
						{              'C2_ROTEIRO'  ,SC2->C2_ROTEIRO                    ,NIL} }
						MsExecAuto({|x,Y| Mata650(x,Y)},aArrayOp,5)
						If lMsErroAuto
							Mostraerro()
							DisarmTransaction()
							Break
							lMostraErro:= .F.
						EndIf

					EndIf
				EndIf
				dbSelectArea("MARK")
				dbSkip()
			End

			// Busca Simulações de Cor (principalmente) para ver se será necessário efetuar ajuste de empenho para preparação do Esmalte e baixa automática
			If Len(ni_ChNOp) > 0
				ftAdcSCr()
			EndIf

			oDlg1:End()
		Else
			fh_Esc := .F.
		EndIf

		oBrw1:oBrowse:Refresh()
		oBrw1:oBrowse:SetFocus()

		dbSelectArea("MARK")
		dbGoTo(fh_Pos)


	END SEQUENCE


	ErrorBlock( bErro )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gTotVlr  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Apura saldo de estoque                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gTotVlr()

	fs_Vlr := 0
	fh_CodEsm := ""
	fh_EsmRev := ""

	dbSelectArea("MARK")
	dj_Recno := Recno()
	dbGoTop()
	While !Eof()
		If MARK->OK == cMarca
			fs_Vlr += MARK->NECESS
		EndIf
		dbSelectArea("MARK")
		dbSkip()
	End
	vt_TotVlr := Transform(fs_Vlr,"@E 99,999,999.99")
	oSay1:Refresh()
	oDlg1:Refresh()
	dbGoTo(dj_Recno)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gGrvCar  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Rotina Responsável pela Geração da Carga                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gGrvCar()

	Local oButton1f
	Local oFont1f := TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
	Local oRadMenu1f
	Local oSay1f
	Local oSay3f
	Local oDlgFatr

	AW004 := " SELECT G1_INI, G1_FIM
	AW004 += "   FROM " + RETSQLNAME("SG1") + " WITH (NOLOCK) "
	AW004 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
	AW004 += "    AND G1_COD = '"+fh_Produt+"'
	AW004 += "    AND G1_REVINI >= '"+nGet3q+"'
	AW004 += "    AND G1_REVFIM <= '"+nGet3q+"'
	AW004 += "    AND D_E_L_E_T_ = ' '
	TCQUERY AW004 New Alias "AW04"
	dbSelectArea("AW04")
	dbGotop()
	If dtos(dDataBase) < AW04->G1_INI .or. dtos(dDataBase) > AW04->G1_FIM
		MsgALERT("Não é possível gerar OP para a revisão selecionada porque ela está fora da vigência: "+dtoc(stod(AW04->G1_INI))+"  "+dtoc(stod(AW04->G1_FIM)) )
		cfValid := .F.
		AW04->(dbCloseArea())
		Return
	Else
		AW04->(dbCloseArea())
	EndIf

	oDlgMoi:End()

	cfValid := .T.
	If fh_Vlr < nGet1q
		cfValid := MsgYESNO("A quantidade selecionada é MENOR."+CHR(13)+CHR(13)+"Deseja prosseguir???")
	EndIf
	If nGet1q == 0
		cfValid := .F.
		MsgSTOP("Impossível prosseguir sem informar a capacidade do Moinho!!!")
	EndIf

	nGetQRf := nGet1q
	// Usado para ajustar a carga conforme QUANTIDADE EM PARTES
	AK007 := " SELECT G1_YQTDREF
	AK007 += "   FROM " + RetSqlName("SG1") + " WITH(NOLOCK) "
	AK007 += "  WHERE G1_FILIAL = '" + xFilial("SG1") + "'
	AK007 += "    AND G1_COD = '" + fh_Produt + "'
	AK007 += "    AND G1_REVINI IN(SELECT B1_REVATU
	AK007 += "                       FROM " + RetSqlName("SB1") + " WITH(NOLOCK) "
	AK007 += "                      WHERE B1_FILIAL = '" + xFilial("SB1") + "'
	AK007 += "                        AND B1_COD = G1_COD
	AK007 += "                        AND D_E_L_E_T_ = ' ')
	AK007 += "    AND G1_YQTDREF > 0
	AK007 += "    AND G1_YQTDREF <> 100
	AK007 += "    AND D_E_L_E_T_ = ' '
	AK007 += "  GROUP BY G1_YQTDREF
	TCQUERY AK007 New Alias "AK07"
	dbSelectArea("AK07")
	dbGotop()
	If G1_YQTDREF > 0
		nGetQRf := nGet1q
		nGet1q := nGet1q * G1_YQTDREF / 100
		MsgINFO("O sistema identificou uma QUANTIDADE EM PARTES e aumentou a CARGA para "+Alltrim(Transform(nGet1q,"999,999.99"))+" a fim de facilitar a separação dos materiais!!!")
	EndIf
	AK07->(dbCloseArea())

	If cfValid
		cd_QtdMoi := fh_Vlr / nGet1q
		cd_QRsMoi := cd_QtdMoi - Int(cd_QtdMoi)
		If cd_QRsMoi <> 0

			DEFINE MSDIALOG oDlgFatr TITLE "Fatoração" FROM 000, 000  TO 170, 630 COLORS 0, 16777215 PIXEL
			@ 014, 010 SAY oSay1f PROMPT "A quantidade selecionada dividida pela Capacidade informada do Moinho não é exata." SIZE 253, 009 OF oDlgFatr FONT oFont1f COLORS 32768, 16777215 PIXEL
			@ 024, 010 SAY oSay3f PROMPT "O que deseja fazer?" SIZE 253, 009 OF oDlgFatr FONT oFont1f COLORS 32768, 16777215 PIXEL
			@ 041, 010 RADIO oRadMenu1f VAR nRadMenu1f ITEMS "Arredondar para Cima;","Gerar multiplo para Baixo;","Manter quantidade, criando a ultima Carga parcial;","Limitar a N Cargas;" SIZE 253, 026 OF oDlgFatr COLOR 32768, 16777215 PIXEL
			@ 012, 268 BUTTON oButton1f PROMPT "Confirmar" SIZE 037, 057 OF oDlgFatr ACTION oDlgFatr:End() PIXEL
			ACTIVATE MSDIALOG oDlgFatr CENTERED

			If nRadMenu1f == 1
				cd_QRsMoi := Int(cd_QtdMoi) + 1
				fh_Vlr := cd_QRsMoi * nGet1q
			ElseIf nRadMenu1f == 2
				cd_QRsMoi := Int(cd_QtdMoi)
				fh_Vlr := cd_QRsMoi * nGet1q
			ElseIf nRadMenu1f == 3
				cd_QRsMoi := cd_QtdMoi
				fh_Vlr := cd_QRsMoi * nGet1q
				If fh_Vlr < nGet1q
					nGet1q := fh_Vlr
				EndIf
			EndIf
			If nRadMenu1f <> 4
				// Isto é necessário para somente gerar quantidades específicas de Ordens de Produção quando assim for definido nesta tela.
				nGet2q := 1
			EndIf

		EndIf

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ftAdcSCr ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Grava Empenho Adicional para Esmalte Tinta e Coloração     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ftAdcSCr()

	Local aCpFs := {}
	Local zp_Tmp
	Local zp_CtReg := .F.
	Private sc_Esc := .F.
	Private qDlgSC

	Aadd( aCpFs , {"OK"       ,"C",002,000} )
	Aadd( aCpFs , {"DTREG"    ,"D",008,000} )
	Aadd( aCpFs , {"SEQ"      ,"C",003,000} )
	Aadd( aCpFs , {"CODMP"    ,"C",015,000} )
	Aadd( aCpFs , {"DESCRIC"  ,"C",050,000} )
	Aadd( aCpFs , {"QTDBASE"  ,"N",010,002} )
	Aadd( aCpFs , {"MISTURA"  ,"N",012,004} )
	Aadd( aCpFs , {"AJUSTE"   ,"N",014,006} )
	Aadd( aCpFs , {"TPCALC"   ,"C",001,000} )
	Aadd( aCpFs , {"QTDAJST"  ,"N",014,006} )
	Aadd( aCpFs , {"QUANTID"  ,"N",014,006} )
	zp_Tmp := CriaTrab( aCpFs, .T. )
	Use (zp_Tmp) Alias T001 New Exclusive

	// Prepara arquivo temporário para gravação e recuperação das Simulções
	cNomBat   := "TESTCOR"+cEmpAnt+"0.DBF"
	lMade     := .F.
	cNomInd   := "TESTCOR"+cEmpAnt+"0.CDX"
	lFim := .F.
	If File(cNomBat)
		While !lFim
			USE &cNomBAT Alias TCOR SHARED NEW VIA __LocalDriver
			lFIm := !NetERR()
		End
		If !File(cNomInd)
			INDEX ON CODPI+REV+SEQ+CODMP TO &cNomInd
			dbCommitAll()
		EndIf
		dbClearIndex()
		dbSetIndex(cNomInd)
		dbSetOrder(1)
		dbSelectArea("TCOR")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(fh_Produt)
		While !Eof() .and. TCOR->CODPI == fh_Produt
			zp_CtReg := .T.
			dbSelectArea("T001")
			RecLock("T001",.T.)
			T001->DTREG    := TCOR->DTREG
			T001->SEQ      := TCOR->SEQ
			T001->CODMP    := TCOR->CODMP
			T001->QTDBASE  := TCOR->QTDBASE
			T001->MISTURA  := TCOR->MISTURA
			T001->AJUSTE   := TCOR->AJUSTE
			T001->TPCALC   := TCOR->TPCALC
			T001->QTDAJST  := TCOR->QTDAJST
			T001->QUANTID  := TCOR->QUANTID
			T001->DESCRIC  := Substr(Posicione("SB1", 1, xFilial("SB1")+TCOR->CODMP, "B1_DESC"),1,50)
			MsUnLock()
			dbSelectArea("TCOR")
			dbSkip()
		End
		TCOR->(dbCloseArea())

		dbSelectArea("T001")
		dbGoTop()
		If zp_CtReg
			qFont1     := TFont():New( "Arial Black",0,19,,.T.,0,,700,.F.,.F.,,,,,, )
			qDlgSC     := MSDialog():New( nLin*.001, nCol*.001, nLin*.810, nCol*.925, "...: Seleção de Simulação de Cor :...",,,.F.,,,,,,.T.,,,.T. )
			cMarca := GetMark()
			dbSelectArea("T001")
			ky_VetSC := {{"OK"      ,"" ,"Ok"             ,"@!"},;
			{             "DTREG"   ,"" ,"Dt Reg"         ,"@!"},;
			{             "SEQ"     ,"" ,"Seq"            ,"@!"},;
			{             "CODMP"   ,"" ,"Componente"     ,"@!"},;
			{             "DESCRIC" ,"" ,"Descrição"      ,"@!"},;
			{             "QTDBASE" ,"" ,"Qtd Base"       ,"@E 9999.99"},;
			{             "MISTURA" ,"" ,"Mistura"        ,"@E 9999.9999"},;
			{             "AJUSTE"  ,"" ,"Per.Ajuste"     ,"@E 9999.999999"},;
			{             "TPCALC"  ,"" ,"Tip.Calc"       ,"@!"},;
			{             "QTDAJST" ,"" ,"Kg Ajuste"      ,"@E 9999.999999"},;
			{             "QUANTID" ,"" ,"Kg Total"       ,"@E 9999.999999"} }
			oBrw1SC    := MsSelect():New( "T001","OK","",ky_VetSC,.F.,@cMarca,{nLin*.008, nCol*.005, nLin*.370, nCol*.460},,, qDlgSC )
			oBrw1SC:bMark := {| | rMrkSim()}
			oBtn1SC    := TButton()  :New( nLin*.375,nCol*.430,"FECHAR"      ,qDlgSC,{|| ExecBlock("BSIMC785",.F.,.F.,"F")   },nLin*.040,nCol*.012,,,,.T.,,"",,,,.F. )
			oBtn2SC    := TButton()  :New( nLin*.375,nCol*.395,"ADICIONAR"   ,qDlgSC,{|| ExecBlock("BSIMC785",.F.,.F.,"A")   },nLin*.040,nCol*.012,,,,.T.,,"",,,,.F. )
			ACTIVATE MSDIALOG qDlgSC CENTERED VALID sc_Esc
		EndIf
	EndIf

	T001->(dbCloseArea())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ rMrkSim  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Responsável por Marcar a Simulação Desejada                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function rMrkSim()

	dbSelectArea("T001")
	ff_Recno := Recno()
	ff_SeqMk := T001->SEQ
	ff_OkMk  := T001->OK
	dbGoTop()
	While !Eof()
		If ff_SeqMk == T001->SEQ
			RecLock("T001",.F.,.F.)
			T001->OK := ff_OkMk
			MsUnLock()
		EndIf
		dbSelectArea("T001")
		dbSkip()
	End

	dbSelectArea("T001")
	dbGoTo(ff_Recno)

	oBrw1SC:oBrowse:Refresh()
	oBrw1SC:oBrowse:SetFocus()
	qDlgSC:Refresh()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BSIMC785 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Responsável pela gravação dos Ajustes de Empenho           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BSIMC785()

	Local sw_Acao := ParamIXB
	Local sw_RetT := .F.
	Local h, _p
	Local _nAux	:=	0
	Local _cAux	:=	0

	If sw_Acao == "F"
		sw_RetT := MsgNOYES("Tem certeza que deseja cancelar o ajuste de Empenho?")

	Else
		If sw_RetT := MsgNOYES("Está certo de ter selecionado a sequencia correta para atualização dos Empenhos?")
			xc_QtdAdi := {}
			dbSelectArea("T001")
			dbGoTop()
			While !Eof()
				If T001->OK == cMarca
					// Vetor contendo número da(s) Ordem(ns) de Produção. ni_ChNOp
					For h := 1 To Len(ni_ChNOp)
						xs_QtdRf := 100
						dbSelectArea("SD4")
						dbSetOrder(1)
						If dbSeek(xFilial("SD4") + T001->CODMP + ni_ChNOp[h][1])

							dbSelectArea("SC2")
							dbSetOrder(1)
							dbSeek(xFilial("SC2") + SD4->D4_OP)

							xs_QtOp  := 0
							xs_G1Qt  := 0
							AZ001 := " SELECT G1_YQTDREF, G1_QUANT, C2_QUANT
							AZ001 += "   FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) "
							AZ001 += "  INNER JOIN "+RetSqlName("SG1")+" SG1 WITH(NOLOCK) ON G1_FILIAL = '"+xFilial("SG1")+"'
							AZ001 += "                       AND G1_COD = C2_PRODUTO
							AZ001 += "                       AND G1_COMP = '"+SD4->D4_COD+"'
							AZ001 += "                       AND C2_REVISAO >= G1_REVINI
							AZ001 += "                       AND C2_REVISAO <= G1_REVFIM
							AZ001 += "                       AND SG1.D_E_L_E_T_ = ' '
							AZ001 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
							AZ001 += "    AND C2_NUM+C2_ITEM+C2_SEQUEN+'  ' = '"+SD4->D4_OP+"'
							AZ001 += "    AND SC2.D_E_L_E_T_ = ' '
							TCQUERY AZ001 New Alias "AZ01"
							dbSelectArea("AZ01")
							dbGotop()
							xs_QtOp := AZ01->C2_QUANT
							xs_G1Qt := AZ01->G1_QUANT
							If AZ01->G1_YQTDREF <> 0
								xs_QtdRf := AZ01->G1_YQTDREF
							EndIf
							AZ01->(dbCloseArea())

							If T001->TPCALC == "1"                                                                        // Soma //Aplicada mudança a base de referencia em virtude de eventuais misturas em partes. Por Marcos Alberto em 08/03/12
								_nAux	:=	ConvUM(SD4->D4_COD, SC2->C2_QUANT, 0, 2) * (T001->AJUSTE/xs_QtdRf)
								RecLock("SD4",.F.)
								SD4->D4_YQTDFLX += xs_QtOp * xs_G1Qt
								SD4->D4_QTDEORI += SC2->C2_QUANT * (T001->AJUSTE/xs_QtdRf)
								SD4->D4_QUANT   += SC2->C2_QUANT * (T001->AJUSTE/xs_QtdRf)
								SD4->D4_QTSEGUM += _nAux
								SD4->D4_YQTDFLX += SC2->C2_QUANT * (T001->AJUSTE/xs_QtdRf)
								MsUnLock()
								Aadd( xc_QtdAdi , {SD4->D4_OP, SC2->C2_QUANT * (T001->AJUSTE/xs_QtdRf) } )
							ElseIf T001->TPCALC == "2"                                                                    // Multiplica
								RecLock("SD4",.F.)
								SD4->D4_YQTDFLX += xs_QtOp * xs_G1Qt
								SD4->D4_QTDEORI += SD4->D4_QTDEORI * T001->AJUSTE / 100
								SD4->D4_QUANT   += SD4->D4_QUANT   * T001->AJUSTE / 100
								SD4->D4_QTSEGUM += SD4->D4_QTSEGUM * T001->AJUSTE / 100
								SD4->D4_YQTDFLX += SD4->D4_YQTDFLX * T001->AJUSTE / 100
								MsUnLock()
								Aadd( xc_QtdAdi , {SD4->D4_OP, (xs_QtOp * xs_G1Qt) * T001->AJUSTE / 100 } )
							EndIf

						Else
							// Tratamento específico para os casos em que o um item a mais foi incluído na simulação
							If T001->AJUSTE <> 0
								_nAux	:=	ConvUm(T001->CODMP, SD4->D4_QTDEORI,0,2)
								_cAux	:=	Posicione("ZCN", 1,  xFilial("ZCN")+T001->CODMP+_cEmpSeq, "ZCN_LOCAL")
								RecLock("SD4",.T.)
								SD4->D4_FILIAL   := xFilial("SD4")
								SD4->D4_COD      := T001->CODMP
								SD4->D4_LOCAL    := _cAux
								SD4->D4_OP       := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
								SD4->D4_DATA     := SC2->C2_DATPRF
								SD4->D4_QTDEORI  := nGetQRf * (T001->AJUSTE/xs_QtdRf)
								SD4->D4_QTSEGUM  := _nAux
								MsUnLock()
								Aadd( xc_QtdAdi , {SD4->D4_OP, nGetQRf * (T001->AJUSTE/xs_QtdRf) } )
							EndIf
						EndIf
					Next h

				EndIf

				dbSelectArea("T001")
				dbSkip()
			End

			If Len(xc_QtdAdi) > 0
				For _p := 1 To Len(xc_QtdAdi)
					dbSelectArea("SC2")
					dbSetOrder(1)
					If dbSeek(xFilial("SC2") + xc_QtdAdi[_p][1])
						_nAux	:=	ConvUM(SC2->C2_PRODUTO, SC2->C2_QUANT, 0, 2)
						RecLock("SC2",.F.)
						SC2->C2_QUANT   += xc_QtdAdi[_p][2]
						SC2->C2_QTSEGUM := _nAux
						MsUnLock()
					EndIf
				Next _p
			EndIf

		EndIf

	EndIf

	If sw_RetT
		sc_Esc := .T.
		qDlgSC:End()
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BSEQ785  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Monta Sequenciamento para os Itens de Carga                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BSEQ785()

	Private aHeader   := {}
	Private aCols     := {}
	Private aRotina   := {{"Pesquisar", "AxPesqui", 0, 1}, {"Visualizar", "AxVisual", 0, 2},{"Incluir", "AxInclui", 0, 3},{"Alterar", "AxAltera", 0, 4},{"Excluit", "AxDeleta", 0, 5}}
	Private fh_Pos

	BEGIN SEQUENCE

		fCriaSem("SEQ - INICIO")

		fh_InSeq := .F.
		fh_Marcad := .F.

		cf_Like := "'"
		dbSelectArea("MARK")
		dbGoTop()
		While !Eof()
			If MARK->OK == cMarca
				cf_Like += MARK->NUMOP+MARK->ITEM+MARK->SEQUEN
				fh_Pos := MARK->(Recno())
				fh_Marcad := .T.
			EndIf
			dbSelectArea("MARK")
			dbSkip()
			If !Eof()
				cf_Like += "','"
			EndIf
		End
		cf_Like += "'"

		If !fh_Marcad
			MsgALERT("Nenhuma OP primária foi marcada. Impossível continuar!!!")
			fh_Esc := .F.
			oBrw1:oBrowse:Refresh()
			oBrw1:oBrowse:SetFocus()
			dbSelectArea("MARK")
			dbGoTop()
			Return
		EndIf

		aCols := {}
		A0002 := " SELECT C2_NUM,
		A0002 += "        C2_ITEM,
		A0002 += "        C2_SEQUEN,
		A0002 += "        C2_PRODUTO,
		A0002 += "        C2_YMOINHO,
		A0002 += "        SUBSTRING(B1_DESC,1,50) B1_DESC,
		A0002 += "        ROUND(C2_QUANT, 0) C2_QUANT,
		A0002 += "        C2_DATPRI,
		A0002 += "        C2_DATPRF,
		A0002 += "        C2_PRIOR
		A0002 += "   FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) "
		A0002 += "  INNER JOIN " + RETSQLNAME("SB1") + " SB1 WITH(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
		A0002 += "                       AND B1_COD = C2_PRODUTO
		A0002 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0002 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
		A0002 += "    AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN IN("+cf_Like+")
		A0002 += "    AND SC2.D_E_L_E_T_ = ' '
		A0002 += "  ORDER BY C2_DATPRI, C2_DATPRF, C2_PRIOR
		TcQuery A0002 New Alias "A002"
		dbSelectArea("A002")
		dbGoTop()
		ProcRegua(RecCount())
		df_seq := 0
		While !Eof()
			df_seq ++
			aAdd(aCols, {stod(A002->C2_DATPRI),;
			StrZero(df_seq,3),;
			A002->C2_PRODUTO,;
			A002->B1_DESC,;
			A002->C2_QUANT,;
			A002->C2_YMOINHO,;
			A002->C2_NUM,;
			A002->C2_ITEM,;
			A002->C2_SEQUEN,;
			stod(A002->C2_DATPRF),;
			.F.})
			dbSelectArea("A002")
			dbSkip()
		End
		A002->(dbCloseArea())

		Define FONT oFont   NAME "Arial"          SIZE 0,14 BOLD
		Define FONT oFont2  NAME "Lucida Console" SIZE 0,14 BOLD
		CursorWait()

		oDlgSC2 := MSDialog():New(nLin*.001, nCol*.001, nLin*.70, nCol*.805,"Informar Sequenciamento",,,.F.,,,,,,.T.,,,.T. )

		fHeader(aHeader)

		aEdits := {"C2_DATPRI","C2_DATPRF","C2_PRIOR","C2_YMOINHO"}
		oGetDados :=   MsGetDados():New(nLin*.019, nCol*.005, nLin*.34, nCol*.400, 4       ,             ,          ,          , .F.,aEdits      ,    , .F.,9999,'U_BIA785A()',             , ,          ,oDlgSC2)

		oDlgSC2:bInit := {||EnchoiceBar(oDlgSC2, {|| U_BIA785B(), oDlgSC2:End() }, {|| U_BIA785C() }, , {{'DBG06',{|| ExecBlock("BFIR785",.F.,.F.,"2") },'<<'}} )}

		ACTIVATE MSDIALOG oDlgSC2 CENTERED VALID fh_InSeq

		oBrw1:oBrowse:Refresh()
		oBrw1:oBrowse:SetFocus()

		dbSelectArea("MARK")
		dbGoTo(fh_Pos)

	END SEQUENCE


	ErrorBlock( bErro )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BFIR785  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 22.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Responsável por confirmar Algumas ações sobre a OP         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BFIR785()

	BEGIN SEQUENCE

		If !fCriaSem("PESAR - INICIO")

			Return

		EndIF


		dbSelectArea("MARK")
		dj_Recno := Recno()
		dbGoTop()
		While !Eof()
			If MARK->OK == cMarca
				dbSelectArea("SC2")
				dbSetOrder(1)
				If dbSeek(xFilial("SC2")+MARK->NUMOP+MARK->ITEM+MARK->SEQUEN)

					RecLock("SC2",.F.)
					SC2->C2_YSTAOPR := PARAMIXB
					MsUnLock()

					If PARAMIXB == "4"
						wt_NumOp := MARK->NUMOP+MARK->ITEM+MARK->SEQUEN+"  "
						U_BIABxEmp(wt_NumOp, 'PI')
					EndIf

				EndIf
			EndIf
			dbSelectArea("MARK")
			dbSkip()
		End
		dbGoTo(dj_Recno)

		oDlg1:End()

	END SEQUENCE


	ErrorBlock( bErro )

Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | fHeader  | Autor | Marcos Alberto        | Data | 17/08/11  |
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Monta o Header da tela para SEQUENCIAMENTO                  |
|          |                                                             |
+----------+------------------------------------------------------------*/
Static Function fHeader(aHeader)

	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("C2_DATPRI")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_PRIOR")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_PRODUTO")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,50        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_QUANT")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,"@E 9999,999,999"  ,x3_tamanho,0         ,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_YMOINHO")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_NUM")
	aAdd(aHeader,{"NumOp"          ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_ITEM")
	aAdd(aHeader,{"It"             ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_SEQUEN")
	aAdd(aHeader,{"Seq"            ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_DATPRF")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA785A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Atualização da sequencia de prioridade das OP's            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA785A()

	Local n_op, nOrd, nPasso, nX, r
	gk_Retn := .T.

	If Alltrim(__readvar) == "M->C2_PRIOR"
		cOld := n
		cNew := Val(M->C2_PRIOR)
		If cNew < 1 .or. cNew > Len(aCols)
			Return .F.
		EndIf
		n_op := Val(RetAsc(cOld,3,.F.))
		nOrd := Val(RetAsc(cNew,3,.F.))
		nPasso := Iif(nOrd > n_op, 1, -1)
		aColsOld := aClone(aCols[n_op])

		FOR nX := n_op TO nOrd STEP nPasso
			cNewOrder := RetAsc(Str(nX),3,.T.)
			If nX == nOrd
				aCols[nX]   := aClone(aColsOld)
				aCols[nX,__PRIOR] := cNewOrder
			Else
				aCols[nX] := aClone(aCols[nX+nPasso])
				aCols[nX,__PRIOR] := cNewOrder
			EndIf
			If nX == n_op
				GdFieldPut("C2_PRIOR",cNewOrder,nX)
				M->C2_PRIOR := cNewOrder
			EndIf
		Next nX
		aCols2 := aSort(aCols,,,{|x,y| x[__PRIOR] < y[__PRIOR] })
		aCols := {}
		aCols := aCols2

	ElseIf Alltrim(__readvar) == "M->C2_DATPRF"
		If M->C2_DATPRF < dDataBase .or. M->C2_DATPRF < GdFieldGet("C2_DATPRI",n)
			gk_Retn := .F.
		Else
			If MsgNOYES("Deseja replicar a data informada para os registros que seguem?")
				For r := n to Len(aCols)
					GdFieldPut("C2_DATPRF",M->C2_DATPRF,r)
				Next r
			EndIf
		EndIf

	ElseIf Alltrim(__readvar) == "M->C2_DATPRI"
		If M->C2_DATPRI < dDataBase
			gk_Retn := .F.
		Else
			If MsgNOYES("Deseja replicar a data informada para os registros que seguem?")
				For r := n to Len(aCols)
					GdFieldPut("C2_DATPRI",M->C2_DATPRI,r)
					GdFieldPut("C2_DATPRF",M->C2_DATPRI,r)
				Next r
			EndIf
		EndIf

	EndIf

Return (gk_Retn)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA785B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Confirmação da Tela de Sequenciamento                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA785B()

	Local k
	fh_InSeq := .T.

	If MsgNOYES("Confirma gravação dos dados ajustados???")
		dbSelectArea("SC2")
		ProcRegua(RecCount())
		For k := 1 to Len(aCols)

			IncProc("Atualizando.... "+aCols[k,__NUMOP]+aCols[k,__ITEM]+aCols[k,__SEQUEN])

			/*----- Atualiza informações das Ordens de Produção -----*/
			dbSelectArea("SC2")
			dbSetOrder(1)
			If dbSeek(xFilial("SC2")+aCols[k,__NUMOP]+aCols[k,__ITEM]+aCols[k,__SEQUEN])
				RecLock("SC2",.F.)
				SC2->C2_DATPRI  := aCols[k,__INICIO]
				SC2->C2_DATPRF  := aCols[k,__ENTREG]
				SC2->C2_PRIOR   := aCols[k,__PRIOR]
				SC2->C2_YMOINHO := aCols[k,__MOINHO]
				MsUnLock()
			EndIf

			/*----- Atualiza empenhos a partir dos ajustes efetuados nas OP's -----*/
			dbSelectArea("SD4")
			dbSetOrder(2)
			dbSeek(xFilial("SD4")+aCols[k,__NUMOP]+aCols[k,__ITEM]+aCols[k,__SEQUEN])
			While !Eof() .and. SD4->D4_FILIAL == xFilial("SD4") .and. SD4->D4_OP == aCols[k,__NUMOP]+aCols[k,__ITEM]+aCols[k,__SEQUEN]
				RecLock("SD4",.F.)
				SD4->D4_DATA := aCols[k,__INICIO]
				MsUnLock()
				dbSelectArea("SD4")
				dbSkip()
			End

			oDlg1:End()

		Next k
	Else
		fh_Esc := .F.
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA785C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Cancelamento da Tela de Sequenciamento - antes de confimar ¦¦¦
¦¦¦          ¦o fechamento da tela                                        +¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA785C()

	If MsgNOYES("Está prestes a perder as atualizações que foram feitas. Deseja proceguir???")
		fh_Esc := .F.
		fh_InSeq := .T.
		oDlgSC2:End()
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIASP785 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Apresenta tela contendo itens que deverão ser separados    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIASP785()

	Private aHeader   := {}
	Private aCols     := {}
	Private aRotina   := {{"Pesquisar", "AxPesqui", 0, 1}, {"Visualizar", "AxVisual", 0, 2},{"Incluir", "AxInclui", 0, 3},{"Alterar", "AxAltera", 0, 4},{"Excluit", "AxDeleta", 0, 5}}
	Private fh_Pos
	fh_InSeqx := .F.
	fh_Marcad := .F.

	BEGIN SEQUENCE

		If !fCriaSem("COMPOSICAO - INICIO")

			Return

		EndIF

		cf_D4OP := ""
		cf_Unica := .T.
		dbSelectArea("MARK")
		dbGoTop()
		While !Eof()
			If MARK->OK == cMarca
				If cf_Unica
					cf_Unica := .F.
				Else
					MsgINFO("Apenas uma fórmula de cada vez poderá ser apresentada!!!")
					Exit
				EndIf
				cf_D4OP := MARK->NUMOP+MARK->ITEM+MARK->SEQUEN+"  "
				fh_Pos := MARK->(Recno())
				fh_Marcad := .T.
			EndIf
			dbSelectArea("MARK")
			dbSkip()
		End

		If !fh_Marcad
			MsgALERT("Nenhuma OP primária foi marcada. Impossível continuar!!!")
			fh_Esc := .F.
			oBrw1:oBrowse:Refresh()
			oBrw1:oBrowse:SetFocus()
			dbSelectArea("MARK")
			dbGoTop()
			Return
		EndIf

		kf_ProdOp := Space(15)
		kf_DescPd := Space(50)
		kf_QtdPrd := Space(10)
		kf_RevPrd := Space(100)

		aCols := {}
		A0002 := " SELECT D4_OP,
		A0002 += "        D4_COD,
		A0002 += "        SUBSTRING(SB1.B1_DESC,1,50) B1_DESC,
		A0002 += "        SB1.B1_UM,
		A0002 += "        C2_PRODUTO,
		A0002 += "        SUBSTRING(XB1.B1_DESC,1,50) C2DESC,
		A0002 += "        C2_QUANT,
		A0002 += "        C2_REVISAO,
		A0002 += "        D4_QTDEORI,
		A0002 += "        D4_YQTDFLX,
		A0002 += "        D4_TRT,
		A0002 += "        G1_INI,
		A0002 += "        G1_FIM,
		A0002 += "        G1_YMISTUR,
		A0002 += "        G1_QUANT
		A0002 += "   FROM "+RetSqlName("SD4")+" SD4 WITH(NOLOCK) "
		A0002 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
		A0002 += "                       AND SB1.B1_COD = D4_COD
		A0002 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0002 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"'
		A0002 += "                       AND C2_NUM+C2_ITEM+C2_SEQUEN+'  ' = D4_OP
		A0002 += "                       AND SC2.D_E_L_E_T_ = ' '
		A0002 += "   LEFT JOIN "+RetSqlName("SG1")+" SG1 WITH(NOLOCK) ON G1_FILIAL = '"+xFilial("SG1")+"'
		A0002 += "                       AND G1_COD = C2_PRODUTO
		A0002 += "                       AND G1_COMP = D4_COD
		A0002 += "                       AND G1_TRT = D4_TRT
		A0002 += "                       AND G1_REVINI = C2_REVISAO
		A0002 += "                       AND SG1.D_E_L_E_T_ = ' '
		A0002 += "  INNER JOIN "+RetSqlName("SB1")+" XB1 WITH(NOLOCK) ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
		A0002 += "                       AND XB1.B1_COD = C2_PRODUTO
		A0002 += "                       AND XB1.D_E_L_E_T_ = ' '
		A0002 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
		A0002 += "    AND D4_OP = '"+cf_D4OP+"'
		A0002 += "    AND SD4.D_E_L_E_T_ = ' '
		A0002 += "  ORDER BY D4_OP, D4_TRT, D4_COD
		TcQuery A0002 New Alias "A002"
		dbSelectArea("A002")
		dbGoTop()
		ProcRegua(RecCount())
		df_seq := 0
		While !Eof()
			kf_ProdOp := A002->C2_PRODUTO
			kf_DescPd := A002->C2DESC
			kf_QtdPrd := "Qtd: " + Alltrim(Transform(A002->C2_QUANT,"@E 999,999.99"))
			kf_RevPrd := "Rev.: " + A002->C2_REVISAO + "           Validade de:  " + dtoc(stod(A002->G1_INI)) + "  até  " + dtoc(stod(A002->G1_FIM))

			aAdd(aCols, {A002->D4_COD,;
			A002->B1_DESC,;
			A002->B1_UM,;
			A002->G1_YMISTUR,;
			IIF(A002->D4_YQTDFLX <> 0, A002->D4_YQTDFLX, A002->D4_QTDEORI),;
			A002->D4_OP,;
			A002->D4_TRT,;
			stod(A002->G1_INI),;
			stod(A002->G1_FIM),;
			.F.})

			dbSelectArea("A002")
			dbSkip()
		End
		A002->(dbCloseArea())
		xk_ArrSp := aCols

		Define FONT oFontx1   NAME "Arial"          SIZE 0,30 BOLD
		Define FONT oFontx2   NAME "Arial"          SIZE 0,42 BOLD
		Define FONT oFontx3   NAME "Arial"          SIZE 0,24 BOLD

		CursorWait()

		oDlgSC2x := MSDialog():New(nLin*.001, nCol*.001, nLin-40/* *.75*/, nCol-40/* *.870*/,"FORMULAÇÃO",,,.F.,,,,,,.T.,,,.T. )

		fMntHder(aHeader)

		aEdits := {}
		oGetDados :=   MsGetDados():New(nLin*.080, nCol*.005, nLin*.34, nCol*.430, 2       ,             ,          ,          , .F.,aEdits      ,    , .F.,9999,             ,             , ,          ,oDlgSC2x)

		oSayx1      := TSay()     :New( nLin*.03,nCol*.010, {|| kf_ProdOp }, oDlgSC2x, , oFontx1, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 050, 035)
		oSayx2      := TSay()     :New( nLin*.03,nCol*.075, {|| kf_DescPd }, oDlgSC2x, , oFontx2, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 200, 035)
		oSayx3      := TSay()     :New( nLin*.03,nCol*.300, {|| kf_QtdPrd }, oDlgSC2x, , oFontx2, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 200, 035)
		oSayx4      := TSay()     :New( nLin*.06,nCol*.010, {|| kf_RevPrd }, oDlgSC2x, , oFontx3, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 300, 035)

		oDlgSC2x:bInit := {||EnchoiceBar(oDlgSC2x, {|| fh_InSeqx := .T., oDlgSC2x:End() }, {|| fh_InSeqx := .T., oDlgSC2x:End() }, .F., {{'S4WB010N',{|| ExecBlock("BIMPS785",.F.,.F.) },'Imprimir'}}  )}

		ACTIVATE MSDIALOG oDlgSC2x CENTERED VALID fh_InSeqx

		oBrw1:oBrowse:Refresh()
		oBrw1:oBrowse:SetFocus()

		dbSelectArea("MARK")
		dbGoTo(fh_Pos)

	END SEQUENCE


	ErrorBlock( bErro )

Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | fMntHder | Autor | Marcos Alberto        | Data | 22/08/11  |
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Monta o Header da tela para FORMULAÇÃO                      |
|          |                                                             |
+----------+------------------------------------------------------------*/
Static Function fMntHder(aHeader)

	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("D4_COD")
	aAdd(aHeader,{"Insumos"        ,x3_campo   ,x3_picture          ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeader,{"Matéria-Prima"  ,x3_campo   ,x3_picture          ,50        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_UM")
	aAdd(aHeader,{"U.M."           ,x3_campo   ,x3_picture          ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_YMISTUR")
	aAdd(aHeader,{"Percentual"     ,x3_campo   ,x3_picture          ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D4_QTDEORI")
	aAdd(aHeader,{"Quantidade"     ,x3_campo   ,"@E 99,999,999.999" ,14        ,3         ,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D4_OP")
	aAdd(aHeader,{"NumOp"          ,x3_campo   ,x3_picture          ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D4_TRT")
	aAdd(aHeader,{"Revisão"        ,x3_campo   ,x3_picture          ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_INI")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture          ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_FIM")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture          ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BPESAx785 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 19.03.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Apresenta tela contendo itens que deverão ser separados    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BPESAx785()

	Local zpArea    := GetArea()
	Local cError    := ""
	Local cWarning  := ""
	Local cvRetOk   := .T.

	Local kLp
	Local aArea           := GetArea()
	Local lExistNfe       := .F.
	Local lAdjustToLegacy := .T.  // Usado para montar o Objeto Printer
	Local lDisableSetup   := .T.  // Usado para montar o Objeto Printer

	Local hl

	Private nHPage
	Private nVPage
	Private nLine
	Private nBaseTxt
	Private nBaseCol

	Private oxCCE
	Private oSetup
	Private nConsNeg   := 0.40 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex   := 0.38 // Constante para concertar o cálculo retornado pelo GetTextWidth.

	Private _oXML   := NIL

	BEGIN SEQUENCE

		If !fCriaSem("PESAR - INICIO")

			Return

		EndIF



		nCol := oMainWnd:nClientWidth
		nLin := oMainWnd:nClientHeight

		oFont1     := TFont():New( "Arial Black",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )

		cf_D4OP := ""
		cf_Unica := .T.
		fh_Marcad := .F.

		dbSelectArea("MARK")
		dbGoTop()
		While !Eof()
			If MARK->OK == cMarca
				If cf_Unica
					cf_Unica := .F.
				Else
					MsgINFO("Apenas uma fórmula de cada vez poderá ser apresentada!!!")
					Exit
				EndIf
				cf_D4OP := MARK->NUMOP+MARK->ITEM+MARK->SEQUEN+"  "
				fh_Pos := MARK->(Recno())
				fh_Marcad := .T.
			EndIf
			dbSelectArea("MARK")
			dbSkip()
		End

		If !fh_Marcad
			MsgALERT("Nenhuma OP primária foi marcada. Impossível continuar!!!")
			fh_Esc := .F.
			oBrw1:oBrowse:Refresh()
			oBrw1:oBrowse:SetFocus()
			dbSelectArea("MARK")
			dbGoTop()
			Return
		EndIf

		kf_ProdOp := Space(15)
		kf_DescPd := Space(50)
		kf_QtdPrd := Space(10)
		kf_RevPrd := Space(100)

		aCols := {}
		A0002 := " SELECT D4_OP,
		A0002 += "        D4_COD,
		A0002 += "        SUBSTRING(SB1.B1_DESC,1,50) B1_DESC,
		A0002 += "        SB1.B1_UM,
		A0002 += "        C2_PRODUTO,
		A0002 += "        SUBSTRING(XB1.B1_DESC,1,50) C2DESC,
		A0002 += "        C2_QUANT,
		A0002 += "        C2_REVISAO,
		A0002 += "        D4_QTDEORI,
		A0002 += "        D4_YQTDFLX,
		A0002 += "        D4_TRT,
		A0002 += "        G1_INI,
		A0002 += "        G1_FIM,
		A0002 += "        G1_YMISTUR,
		A0002 += "        G1_QUANT
		A0002 += "   FROM "+RetSqlName("SD4")+" SD4 WITH(NOLOCK)
		A0002 += "  INNER JOIN "+RetSqlName("SB1")+" SB1  WITH(NOLOCK) ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
		A0002 += "                       AND SB1.B1_COD = D4_COD
		A0002 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0002 += "  INNER JOIN "+RetSqlName("SC2")+" SC2  WITH(NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"'
		A0002 += "                       AND C2_NUM+C2_ITEM+C2_SEQUEN+'  ' = D4_OP
		A0002 += "                       AND SC2.D_E_L_E_T_ = ' '
		A0002 += "   LEFT JOIN "+RetSqlName("SG1")+" SG1  WITH(NOLOCK) ON G1_FILIAL = '"+xFilial("SG1")+"'
		A0002 += "                       AND G1_COD = C2_PRODUTO
		A0002 += "                       AND G1_COMP = D4_COD
		A0002 += "                       AND G1_TRT = D4_TRT
		A0002 += "                       AND G1_REVINI = C2_REVISAO
		A0002 += "                       AND SG1.D_E_L_E_T_ = ' '
		A0002 += "  INNER JOIN "+RetSqlName("SB1")+" XB1  WITH(NOLOCK) ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
		A0002 += "                       AND XB1.B1_COD = C2_PRODUTO
		A0002 += "                       AND XB1.D_E_L_E_T_ = ' '
		A0002 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
		A0002 += "    AND D4_OP = '"+cf_D4OP+"'
		A0002 += "    AND SD4.D_E_L_E_T_ = ' '
		A0002 += "  ORDER BY D4_QTDEORI DESC
		TcQuery A0002 New Alias "A002"
		dbSelectArea("A002")
		dbGoTop()
		ProcRegua(RecCount())
		df_seq := 0
		While !Eof()
			kf_ProdOp := A002->C2_PRODUTO
			kf_DescPd := A002->C2DESC
			kf_QtdPrd := "Qtd: " + Alltrim(Transform(A002->C2_QUANT,"@E 999,999.99"))
			kf_RevPrd := "Rev.: " + A002->C2_REVISAO + "           Validade de:  " + dtoc(stod(A002->G1_INI)) + "  até  " + dtoc(stod(A002->G1_FIM))

			aAdd(aCols, {A002->B1_DESC,;
			A002->G1_YMISTUR,;
			IIF(A002->D4_YQTDFLX <> 0, A002->D4_YQTDFLX, A002->D4_QTDEORI),;
			A002->B1_UM})

			dbSelectArea("A002")
			dbSkip()
		End
		A002->(dbCloseArea())

		fErase("c:\temp\"+Alltrim(kf_ProdOp)+".pdf")
		oxCCE      := FWMSPrinter():New(Alltrim(kf_ProdOp), IMP_PDF , lAdjustToLegacy, , lDisableSetup)

		oFont24n   := TFontEx():New(oxCCE,"Arial",24,24,.T.,.T.,.F.)
		oFont24    := TFontEx():New(oxCCE,"Arial",24,24,.F.,.T.,.F.)
		oFont20n   := TFontEx():New(oxCCE,"Arial",20,20,.T.,.T.,.F.)
		oFont20    := TFontEx():New(oxCCE,"Arial",20,20,.F.,.T.,.F.)
		oFont18n   := TFontEx():New(oxCCE,"Arial",18,18,.T.,.T.,.F.)
		oFont18    := TFontEx():New(oxCCE,"Arial",18,18,.F.,.T.,.F.)
		oFt23Luc   := TFontEx():New(oxCCE,"Lucida Console",24,24,.T.,.T.,.F.)
		oFont10n   := TFontEx():New(oxCCE,"Arial",10,10,.T.,.T.,.F.)
		oFont10    := TFontEx():New(oxCCE,"Arial",10,10,.F.,.T.,.F.)

		PixelX     := oxCCE:nLogPixelX()
		PixelY     := oxCCE:nLogPixelY()

		oBrush     := TBrush():New( , CLR_BLACK )

		If !oxCCE:Canceled()

			// Ordem obrigátoria de configuração do relatório
			oxCCE:SetResolution(72)
			oxCCE:SetLandscape()
			oxCCE:SetPaperSize(DMPAPER_A4)
			oxCCE:SetMargin(30,60,30,60) // nEsquerda, nSuperior, nDireita, nInferior
			oxCCE:cPathPDF := "c:\temp\" // Caso seja utilizada impressão em IMP_PDF

			xPrntPdf := .T.
			If Alltrim(oxCCE:cPrinter) <> "PDF" .or. Len(Alltrim(oxCCE:cPrinter)) > 3
				xPrntPdf := .F.
			EndIf

			oxCCE:StartPage()
			nHPage := oxCCE:nHorzRes()
			nHPage *= (300/PixelX)
			nHPage -= HMARGEM
			nVPage := oxCCE:nVertRes()
			nVPage *= (300/PixelY)
			nVPage -= VBOX
			nLine  := 0
			nLine  += IIF(xPrntPdf, 220, 220)
			nBaseTxt := 50
			nBaseCol := 50

			// O limite da Margem é nHPage - 270
			oxCCE:Box(nLine+000, nBaseCol, nLine+100, nHPage - 150, "-4")
			oxCCE:Say(nLine+055, nBaseTxt+10, dtoc(dDataBase) +"  "+ Substr(Time(),1,5) , oFont10:oFont)
			oxCCE:Say(nLine+070, nBaseTxt   , Padc("FORMULAÇÃO",189)       , oFont20n:oFont)

			nLine += 150
			oxCCE:Say(nLine+045, nBaseTxt+050, Alltrim(kf_ProdOp) + " - " + Alltrim(kf_DescPd) + Space(30) + kf_QtdPrd , oFont24n:oFont)
			oxCCE:Say(nLine+145, nBaseTxt+050, kf_RevPrd                                                               , oFont18n:oFont)

			nLine += 230
			xf_Titu := +;
			Padr("Componete"        ,50)+" "+;
			Padl("% Mistura"        ,09)+" "+;
			Padl("Quantidade"       ,14)+" "+;
			Padl("Unid"             ,04)
			oxCCE:Say(nLine+045, nBaseTxt, xf_Titu                                                                     , oFt23Luc:oFont)
			oxCCE:Line(nLine+065, nBaseCol, nLine+065, nHPage - 150)

			xt_Mist := 0
			xt_Qtda := 0
			For hl := 1 To Len(aCols)
				nLine += 120
				cItemXk := +;
				Padr(aCols[hl][1]                                    ,50)+" "+;
				Padl(Transform(aCols[hl][2], "@E 99,999.99")         ,09)+" "+;
				Padl(Transform(aCols[hl][3], "@E 999,999,999.99")    ,14)+" "+;
				Padl(aCols[hl][4]                                    ,04)
				oxCCE:Say(nLine+045, nBaseTxt, cItemXk                                                                     , oFt23Luc:oFont)
				xt_Mist += aCols[hl][2]
				xt_Qtda += aCols[hl][3]
			Next hl

			oxCCE:Line(nLine+065, nBaseCol, nLine+065, nHPage - 150)
			nLine += 100
			cTotlXk := +;
			Padr("Totais"                                        ,50)+" "+;
			Padl(Transform(xt_Mist, "@E 99,999.99")              ,09)+" "+;
			Padl(Transform(xt_Qtda, "@E 999,999,999.99")         ,14)+" "+;
			Padl(""                                              ,04)
			oxCCE:Say(nLine+045, nBaseTxt, cTotlXk                                                                     , oFt23Luc:oFont)

			oxCCE:EndPage()
			oxCCE:Preview() //Visualiza antes de imprimir

		EndIf

		FreeObj(oxCCE)
		oxCCE := Nil

	END SEQUENCE


	ErrorBlock( bErro )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BMOE785  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Apresenta dados dos Ensaios para o processo de Moagem      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BMOE785()

	Private aHeader   := {}
	Private aCols     := {}
	Private aRotina   := {{"Pesquisar", "AxPesqui", 0, 1}, {"Visualizar", "AxVisual", 0, 2},{"Incluir", "AxInclui", 0, 3},{"Alterar", "AxAltera", 0, 4},{"Excluit", "AxDeleta", 0, 5}}
	Private fh_Pos
	me_EnsSeqx := .F.
	fh_Marcad := .F.

	cf_D4OP := ""
	cf_CodP := ""
	cf_QtdP := 0
	cf_Unica := .T.
	dbSelectArea("MARK")
	dbGoTop()
	While !Eof()
		If MARK->OK == cMarca
			If cf_Unica
				cf_Unica := .F.
			Else
				MsgINFO("Apenas uma Carga de cada vez poderá ser apresentada!!!")
				Exit
			EndIf
			cf_D4OP := MARK->NUMOP+MARK->ITEM+MARK->SEQUEN+"  "
			cf_CodP := MARK->CODESM
			cf_QtdP := MARK->NECESS
			fh_Pos := MARK->(Recno())
			fh_Marcad := .T.
		EndIf
		dbSelectArea("MARK")
		dbSkip()
	End

	If !fh_Marcad
		MsgALERT("Nenhuma OP primária foi marcada. Impossível continuar!!!")
		fh_Esc := .F.
		oBrw1:oBrowse:Refresh()
		oBrw1:oBrowse:SetFocus()
		dbSelectArea("MARK")
		dbGoTop()
		Return
	EndIf

	kf_ProdOp := cf_CodP
	kf_DescPd := Space(50)
	kf_QtdPrd := Space(10)
	kf_RevPrd := Space(100)

	AT001 := " SELECT Z03_REVSAO,
	AT001 += "        Z03_DTINI,
	AT001 += "        Z03_DTFIM,
	AT001 += "        Z03_TIPO,
	AT001 += "        X5_DESCRI,
	AT001 += "        Z03_INTRDE,
	AT001 += "        Z03_INTRAT,
	AT001 += "        Z03_MEDIDA
	AT001 += "   FROM " + RETSQLNAME("Z03") + " Z03 WITH(NOLOCK) "
	AT001 += "  INNER JOIN " + RETSQLNAME("SX5") + " SX5 WITH(NOLOCK) ON X5_FILIAL = '"+xFilial("SX5")+"'
	AT001 += "                       AND X5_TABELA = 'ZL'
	AT001 += "                       AND X5_CHAVE = Z03_TIPO
	AT001 += "                       AND SX5.D_E_L_E_T_ = ' '
	AT001 += "  WHERE Z03_FILIAL = '"+xFilial("Z03")+"'
	AT001 += "    AND Z03_PRODUT = '"+kf_ProdOp+"'
	AT001 += "    AND Z03_REVSAO IN(SELECT MAX(Z03_REVSAO)
	AT001 += "                        FROM " + RETSQLNAME("Z03") + " WITH(NOLOCK) "
	AT001 += "                       WHERE Z03_FILIAL = '"+xFilial("Z03")+"'
	AT001 += "                         AND Z03_PRODUT = '"+kf_ProdOp+"'
	AT001 += "                         AND D_E_L_E_T_ = ' ' )
	AT001 += "    AND Z03.D_E_L_E_T_ = ' '
	AT001 += "  ORDER BY Z03_TIPO
	TcQuery AT001 New Alias "AT01"
	dbSelectArea("AT01")
	dbGoTop()
	ProcRegua(RecCount())
	df_seq := 0
	While !Eof()

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+kf_ProdOp))
		kf_DescPd := Substr(SB1->B1_DESC,1,50)
		kf_RevPrd := "Rev.: " + AT01->Z03_REVSAO + "           Validade de:  " + dtoc(stod(AT01->Z03_DTINI)) + "  até  " + dtoc(stod(AT01->Z03_DTFIM))

		sk_Refxz := ""
		If AT01->Z03_TIPO == "05" // Agua
			sk_Refxz := Transform(cf_QtdP * ((AT01->Z03_INTRDE+AT01->Z03_INTRAT)/2) / 100, "@E 999,999,999.9999")
		EndIf

		aAdd(aCols, {AT01->Z03_REVSAO,;
		AT01->Z03_TIPO,;
		AT01->X5_DESCRI,;
		AT01->Z03_INTRDE,;
		AT01->Z03_INTRAT,;
		AT01->Z03_MEDIDA,;
		sk_Refxz,;
		.F.})

		dbSelectArea("AT01")
		dbSkip()
	End
	AT01->(dbCloseArea())

	Define FONT oFontx1   NAME "Arial"          SIZE 0,30 BOLD
	Define FONT oFontx2   NAME "Arial"          SIZE 0,42 BOLD
	Define FONT oFontx3   NAME "Arial"          SIZE 0,24 BOLD
	CursorWait()

	ensDlgSC2 := MSDialog():New(nLin*.001, nCol*.001, nLin*.70, nCol*.870,"Ensaios e Orientações",,,.F.,,,,,,.T.,,,.T. )

	fEnsHder(aHeader)

	aEdits := {}
	oGetDados :=   MsGetDados():New(nLin*.080, nCol*.005, nLin*.34, nCol*.430, 2       ,             ,          ,          , .F.,aEdits      ,    , .F.,9999, "",             , ,          ,ensDlgSC2)

	oSayx1      := TSay()     :New( nLin*.03,nCol*.010, {|| kf_ProdOp }, ensDlgSC2, , oFontx1, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 050, 035)
	oSayx2      := TSay()     :New( nLin*.03,nCol*.075, {|| kf_DescPd }, ensDlgSC2, , oFontx2, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 200, 035)
	oSayx3      := TSay()     :New( nLin*.06,nCol*.010, {|| kf_RevPrd }, ensDlgSC2, , oFontx3, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 300, 035)

	ensDlgSC2:bInit := {||EnchoiceBar(ensDlgSC2, {|| me_EnsSeqx := .T., ensDlgSC2:End() }, {|| me_EnsSeqx := .T., ensDlgSC2:End() }, , )}

	ACTIVATE MSDIALOG ensDlgSC2 CENTERED VALID me_EnsSeqx

	oBrw1:oBrowse:Refresh()
	oBrw1:oBrowse:SetFocus()

	dbSelectArea("MARK")
	dbGoTo(fh_Pos)

Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | fMntHder | Autor | Marcos Alberto        | Data | 26/08/11  |
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Monta o Header da tela para Ensaios e Orientações           |
|          |                                                             |
+----------+------------------------------------------------------------*/
Static Function fEnsHder(aHeader)

	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("Z03_REVSAO")
	aAdd(aHeader,{"Revisão"        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("Z03_TIPO")
	aAdd(aHeader,{"Cod.Ensaio"     ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeader,{"Ensaio"         ,x3_campo   ,x3_picture         ,30        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("Z03_INTRDE")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("Z03_INTRAT")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("Z03_MEDIDA")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("Z03_MEDIDA")
	aAdd(aHeader,{"Referencia"     ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BBXA785  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 24.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Responsável pelo apontamento da produção de Esmalte inti-  ¦¦¦
¦¦¦          ¦tulado BAIXA                                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BBXA785()

	BEGIN SEQUENCE

		If !fCriaSem("BAIXAR - INICIO")

			Return

		EndIF

		cf_C2OP := ""
		cfStatus := ""
		cf_Unica := .T.
		dbSelectArea("MARK")
		dbGoTop()
		While !Eof()
			If MARK->OK == cMarca
				If cf_Unica
					cf_Unica := .F.
				Else
					MsgINFO("Apenas uma fórmula de cada vez poderá ser apresentada!!!")
					Exit
				EndIf
				cf_C2OP  := MARK->NUMOP+MARK->ITEM+MARK->SEQUEN+"   "
				cfStatus := MARK->STAOPR
			EndIf
			dbSelectArea("MARK")
			dbSkip()
		End

		If cfStatus <> "5"

			If !Empty(cf_C2OP)
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2") + cf_C2OP))
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))

				kjQuant := U_BIA686()

				If kjQuant <= 0
					MsgSTOP("Necessário verificar com a TI um processo de investigação porque a quantidade deste apontamento está retornando ZERO.")
					Return
				EndIf

				If SC2->C2_YSTAOPR <> "4"
					vs_VetM250 :={ {  "D3_TM"       , "010"              ,NIL},;
					{                 "D3_COD"      , SC2->C2_PRODUTO    ,NIL},;
					{                 "D3_UM"       , SB1->B1_UM         ,NIL},;
					{                 "D3_QUANT"    , kjQuant            ,NIL},;
					{                 "D3_OP"       , cf_C2OP            ,NIL},;
					{                 "D3_LOCAL"    , SC2->C2_LOCAL      ,NIL},;
					{                 "D3_EMISSAO"  , dDataBase          ,NIL},;
					{                 "D3_CONTA"    , SB1->B1_CONTA      ,NIL},;
					{                 "D3_CC"       , "3000"             ,NIL},;
					{                 "D3_YAPLIC"       , "1"             ,NIL},;
					{                 "D3_YQTUMID"  , SC2->C2_QUANT      ,NIL} }
					//,;
					//{                 "D3_PARCTOT"  , "T"                ,NIL} }
					lMsErroAuto := .f.
					msExecAuto({|x,Y| Mata250(x,Y)}, vs_VetM250, 3)
					If lMsErroAuto

						MostraErro()

					Else

						SC2->(dbSetOrder(1))
						SC2->(dbSeek(xFilial("SC2") + cf_C2OP))
						RecLock("SC2",.F.)
						SC2->C2_YSTAOPR := "4"
						SC2->C2_DATRF   := dDataBase
						MsUnLock()

						//VJ008 := " UPDATE "+RetSqlName("SB2")+" SET B2_QEMP = B2_QEMP - D4_QUANT, B2_QEMP2 = B2_QEMP2 - D4_QTSEGUM "
						VJ008 := "	SELECT SB2.R_E_C_N_O_ as REG, SD4.D4_QUANT, SD4.D4_QTSEGUM
						VJ008 += "   FROM "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) "
						VJ008 += "  INNER JOIN "+RetSqlName("SD4")+" SD4 WITH(NOLOCK) ON D4_FILIAL = '"+xFilial("SD4")+"' "
						VJ008 += "                       AND D4_OP  = '"+cf_C2OP+"' "
						VJ008 += "                       AND D4_COD = B2_COD "
						VJ008 += "                       AND D4_LOCAL = B2_LOCAL "
						VJ008 += "                       AND SD4.D_E_L_E_T_ = ' ' "
						VJ008 += "  WHERE B2_FILIAL = '"+xFilial("SB2")+"' "
						VJ008 += "    AND SB2.D_E_L_E_T_ = ' ' "
						//					TcSQLExec(VJ008) Transformado em Select para depois utilizar seek + reclock
						MscIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,VJ008),'VJ08',.F.,.T.)
						dbSelectArea("VJ08")
						dbGoTop()
						While VJ08->(!EOF())
							SB2->(DbGoTo(VJ08->REG))
							Reclock("SB2",.F.)
							SB2->B2_QEMP 	:= SB2->B2_QEMP - VJ08->D4_QUANT
							SB2->B2_QEMP2	:= SB2->B2_QEMP2 - VJ08->D4_QTSEGUM
							SB2->(MsUnlock())
							VJ08->(DbSkip())
						End
						VJ08->(dbCloseArea())
						Ferase(MscIndex+GetDBExtension())     //arquivo de trabalho
						Ferase(MscIndex+OrdBagExt())          //indice gerado

						//					VJ009 := " UPDATE "+RetSqlName("SD4")+" SET D4_QUANT = 0, D4_QTSEGUM = 0 "
						VJ009 := " SELECT R_E_C_N_O_ REG
						VJ009 += "   FROM "+RetSqlName("SD4")+" WITH(NOLOCK) "
						VJ009 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' "
						VJ009 += "    AND D4_OP  = '"+cf_C2OP+"' "
						VJ009 += "    AND D_E_L_E_T_ = ' ' "
						MscIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,VJ009),'VJ09',.F.,.T.)
						dbSelectArea("VJ09")
						dbGoTop()
						While VJ09->(!EOF())
							SD4->(DbGoTo(VJ09->REG))
							Reclock("SD4",.F.)
							SD4->D4_QUANT 	:= 0
							SD4->D4_QTSEGUM	:= 0
							SD4->(MsUnlock())
							VJ09->(DbSkip())
						End
						VJ09->(dbCloseArea())
						Ferase(MscIndex+GetDBExtension())     //arquivo de trabalho
						Ferase(MscIndex+OrdBagExt())          //indice gerado

					EndIf

				Else

					MsgINFO("Ordem de Produção já Baixada: "+cf_C2OP)

				EndIf

			Else

				MsgINFO("Nenhuma OP foi selecionada. Favor Verficar!!!")

			EndIf

		Else

			drGrav := .F.
			hTransf := {}
			dbSelectArea("SD3")
			// ****** Adiciona cabecalho com numero do documento e data da transferencia modelo II *****
			If cEmpAnt == "01"
				aadd ( hTransf, { UPPER( NextNumero("SD3", 2, "D3_DOC", .t.) ), dDataBase } )
			Else
				aadd ( hTransf, { GetSXENum("SD3","D3_DOC"), dDataBase } )
			EndIf

			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2") + cf_C2OP))

			dbSelectArea("SD4")
			dbSetOrder(2)
			dbGoTop()
			dbSeek(xFilial("SD4") + cf_C2OP)
			While !Eof() .and. SD4->D4_OP == cf_C2OP

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD))
				fDescOri := Substr(SB1->B1_DESC,30)
				fUmOri   := SB1->B1_UM
				ZCN->(DbSetOrder(1))
				If ZCN->(DbSeek(xFilial("ZCN")+SD4->D4_COD+_cEmpSeq))
					fLocPOri := ZCN->ZCN_LOCAL
				Else
					fLocPOri := ""
				EndIf

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
				fDescDes := Substr(SB1->B1_DESC,1,30)
				fUmDes   := SB1->B1_UM
				ZCN->(DbSetOrder(1))
				If ZCN->(DbSeek(xFilial("ZCN")+SC2->C2_PRODUTO+_cEmpSeq))
					fLocPDes := ZCN->ZCN_LOCAL
				Else
					fLocPDes := ""
				EndIf


				drGrav := .T.
				// ********************** Adiciona itens da transferencia modelo II ************************
				aadd ( hTransf,	{ SD4->D4_COD                                     ,;
				fDescOri                                                          ,;
				fUmOri                                                            ,;
				fLocPOri                                                          ,;
				""                                                                ,;
				SC2->C2_PRODUTO                                                   ,;
				fDescDes                                                          ,;
				fUmDes                                                            ,;
				fLocPDes                                                          ,;
				""                                                                ,;
				"                    "                                            ,;
				""                                                                ,;
				"      "                                                          ,;
				ctod("  /  /  ")                                                  ,;
				0.00                                                              ,;
				SD4->D4_QUANT                                                     ,;
				ConvUM(SD4->D4_COD, SD4->D4_QUANT, 0, 2)                          ,;
				CriaVar("D3_ESTORNO")                                             ,;
				CriaVar("D3_NUMSEQ")                                              ,;
				""                                                                ,;
				ctod("  /  /  ")                                                  ,;
				CriaVar("D3_ITEMGRD")                                             ,;
				CriaVar("D3_OBSERVA")                                             })

				dbSelectArea("SD4")
				dbSkip()

			End

			If drGrav

				lMsErroAuto := .f.
				MSExecAuto({|x,y| mata261(x,y)},hTransf,3)
				//MSExecAuto({|x| MATA261(x)}, hTransf)
				If lMsErroAuto

					Mostraerro()
					lMostraErro:= .F.

				Else

					SC2->(dbSetOrder(1))
					SC2->(dbSeek(xFilial("SC2") + cf_C2OP))
					RecLock("SC2",.F.)
					SC2->C2_DATRF = dDataBase
					SC2->C2_YSTAOPR := "4"
					MsUnLock()

					dbSelectarea("SD4")
					dbSetOrder(2)
					If dbSeek(xFilial("SD4") + cf_C2OP)

						While !Eof() .and. Alltrim(SD4->D4_OP) == Alltrim(cf_C2OP)

							dbSelectArea("SB2")
							dbSetOrder(1)
							If dbSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL)
								RecLock("SB2",.F.)
								SB2->B2_QEMP   -= SD4->D4_QUANT
								SB2->B2_QEMP2  -= SD4->D4_QTSEGUM
								MsUnLock()
							EndIf

							dbSelectArea("SD4")
							RecLock("SD4",.F.)
							SD4->D4_QUANT   := 0
							SD4->D4_QTSEGUM := 0
							MsUnLock()

							dbSelectArea("SD4")
							dbSkip()

						End

					EndIf

					Aviso('Adicionais','Movimentação efetuado com sucesso!',{'Ok'})

				EndIf

			EndIf

		EndIf

		oDlg1:End()

	END SEQUENCE

	ErrorBlock( bErro )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BSCOR785 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Monta Tela para simulação de COR de Esmalte                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BSCOR785()

	Private oDlgSimul
	Private zoButton1
	Private zoButton2
	Private zoFont1 := TFont():New("Arial Black",,014,,.T.,,,,,.F.,.F.)
	Private zoGet1
	Private noGet1 := 0
	Private zoGroup1
	Private zoGroup2
	Private zoGroup3
	Private zoSay1
	Private zoSay2
	Private zoSay3
	Private zDescEsm := Alltrim(MARK->ESMALT)+" ("+Alltrim(MARK->CODESM)+")"
	Private zCodiEsm := MARK->CODESM
	Private zReviEsm := MARK->REVISA
	Private ws_Seq := "000"
	Private zz_Esc := .F.

	BEGIN SEQUENCE

		If !fCriaSem("AJUSTAR - INICIO")

			Return

		EndIF

		// Prepara arquivo temporário para gravação e recuperação das Simulções
		aStru     := {}
		cNomBat   := "TESTCOR"+cEmpAnt+"0.DBF"
		cAlias    := Alias()
		lMade     := .F.
		cNomInd   := "TESTCOR"+cEmpAnt+"0.CDX"
		aEstruTRB := {}
		If !File(cNomBat)
			AADD(aEstruTRB,{"CODPI"    ,"C",15,0})
			AADD(aEstruTRB,{"REV"      ,"C",03,0})
			AADD(aEstruTRB,{"SEQ"      ,"C",03,0})
			AADD(aEstruTRB,{"CODMP"    ,"C",15,0})
			AADD(aEstruTRB,{"QTDBASE"  ,"N",14,6})
			AADD(aEstruTRB,{"MISTURA"  ,"N",12,4})
			AADD(aEstruTRB,{"AJUSTE"   ,"N",14,6})
			AADD(aEstruTRB,{"TPCALC"   ,"C",01,0})
			AADD(aEstruTRB,{"QTDAJST"  ,"N",14,6})
			AADD(aEstruTRB,{"QUANTID"  ,"N",14,6})
			AADD(aEstruTRB,{"DTREG"    ,"D",08,0})
			dbCreate(cNomBat,aEstruTRB,__LocalDriver)
			lMade := .T.
		EndIf
		lFim := .F.
		While !lFim
			USE &cNomBAT Alias TCOR SHARED NEW VIA __LocalDriver
			lFIm := !NetERR()
		End
		If lMade
			INDEX ON CODPI+REV+SEQ+CODMP TO &cNomInd
			dbClearIndex()
			dbSetIndex(cNomInd)
			dbSetOrder(1)
		Else
			If !File(cNomInd)
				INDEX ON CODPI+REV+SEQ+CODMP TO &cNomInd
				dbCommitAll()
			EndIf
			dbClearIndex()
			dbSetIndex(cNomInd)
			dbSetOrder(1)
		EndIf

		DEFINE MSDIALOG oDlgSimul TITLE "Simulador para Cor" FROM nLin*.001, nCol*.001  TO nLin*.830, nCol*.975 COLORS 0, 16777215 PIXEL

		@ nLin*.008, nCol*.006 GROUP zoGroup1 TO nLin*.061, nCol*.483 PROMPT " Referência " OF oDlgSimul COLOR 0, 16777215 PIXEL
		@ nLin*.071, nCol*.006 GROUP zoGroup2 TO nLin*.180, nCol*.483 PROMPT " Cálculo " OF oDlgSimul COLOR 0, 16777215 PIXEL
		@ nLin*.185, nCol*.006 GROUP zoGroup3 TO nLin*.410, nCol*.483 PROMPT " Recuperado " OF oDlgSimul COLOR 0, 16777215 PIXEL
		@ nLin*.039, nCol*.009 SAY zoSay1 PROMPT "Quantidade base para simulação da cor:" SIZE nLin*.200, nCol*.011 OF oDlgSimul FONT zoFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.036, nCol*.165 MSGET zoGet1 VAR noGet1 SIZE nLin*.060, nCol*.008 OF oDlgSimul PICTURE "@E 999,999,999.99" VALID fRatMist() COLORS 0, 16777215 PIXEL
		@ nLin*.020, nCol*.009 SAY zoSay2 PROMPT zDescEsm SIZE nLin*.246, nCol*.011 OF oDlgSimul FONT zoFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.020, nCol*.263 SAY zoSay3 PROMPT "Revisão: "+MARK->REVISA SIZE nLin*.070, nCol*.011 OF oDlgSimul FONT zoFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.043, nCol*.210 SAY zoSay1 PROMPT "EM GRAMAS" SIZE nLin*.200, nCol*.011 OF oDlgSimul FONT zoFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.063, nCol*.253 SAY zoSay1 PROMPT "Tip.Calc --> 1=Soma; 2=Multiplicação" SIZE nLin*.300, nCol*.011 OF oDlgSimul FONT zoFont1 COLORS 0, 16777215 PIXEL
		foNwDad1()
		@ nLin*.017, nCol*.390 BUTTON zoButton1 PROMPT "Gravar"   SIZE nLin*.037, nCol*.010 OF oDlgSimul ACTION xc_GrvSim() PIXEL
		@ nLin*.040, nCol*.390 BUTTON zoButton2 PROMPT "Fechar"   SIZE nLin*.037, nCol*.010 OF oDlgSimul ACTION (zz_Esc := .T., oDlgSimul:End()) PIXEL
		@ nLin*.017, nCol*.420 BUTTON zoButton2 PROMPT "Imprimir" SIZE nLin*.037, nCol*.021 OF oDlgSimul ACTION xc_ImpSim(1) PIXEL
		foNwRec2()

		ACTIVATE MSDIALOG oDlgSimul VALID zz_Esc

		TCOR->(dbCloseArea())

	END SEQUENCE


	ErrorBlock( bErro )	

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ foNwDad1 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function foNwDad1()

	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"SEQ","COMP","DESCRIC","MISTURA","AJUSTE","TPCALC1","QTDAJST","QUANTID","REGISTR"}
	Local aAlterFields := {"SEQ","COMP","AJUSTE","TPCALC1"} //{"AJUSTE","TPCALC1"}

	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("G1_TRT")
	aAdd(aHeaderEx,{"Seq"            ,"SEQ"      ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_COMP")
	aAdd(aHeaderEx,{"Componente"     ,"COMP"     ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,"SB1"    ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeaderEx,{x3_titulo        ,"DESCRIC"  ,x3_picture           ,50        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Mistura"        ,"MISTURA"  ,"@E 999,999.9999"    ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Per.Ajuste"     ,"AJUSTE"   ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_YSTATUS")
	aAdd(aHeaderEx,{"Tip.Calc"       ,"TPCALC1"  ,"@E"                 ,1         ,0         ,,x3_usado,"C"    ,         ,          })
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Gr Ajuste"      ,"QTDAJST"  ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Gr Total"       ,"QUANTID"  ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Registro"       ,"REGISTR"  ,"@E 99999999"        ,8         ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

	dbSelectArea("TCOR")
	dbSetOrder(1)
	If dbSeek(MARK->CODESM)
		While !Eof() .and. TCOR->CODPI == MARK->CODESM
			ws_Seq := TCOR->SEQ
			dbSelectArea("TCOR")
			dbSkip()
		End
	EndIf

	AV001 := " SELECT '"+Soma1(ws_Seq)+"' SEQ,
	AV001 += "        G1_COMP COMP,
	AV001 += "        SUBSTRING(B1_DESC,1,50) DESCRIC,
	AV001 += "        G1_YMISTUR MISTURA,
	AV001 += "        0 AJUSTE,
	AV001 += "        0 QTDAJST,
	AV001 += "        '1' TPCALC1,
	AV001 += "        0 QUANT
	AV001 += "   FROM " + RETSQLNAME("SG1") + " SG1 WITH(NOLOCK) "
	AV001 += "  INNER JOIN " + RETSQLNAME("SB1") + " SB1 WITH(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	AV001 += "                       AND B1_COD = G1_COMP
	AV001 += "                       AND SB1.D_E_L_E_T_ = ' '
	AV001 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
	AV001 += "    AND G1_COD = '"+MARK->CODESM+"'
	AV001 += "    AND '"+MARK->REVISA+"' >= G1_REVINI
	AV001 += "    AND '"+MARK->REVISA+"' <= G1_REVFIM
	AV001 += "    AND SG1.D_E_L_E_T_ = ' '
	TcQuery AV001 ALIAS "AV01" NEW
	dbSelectArea("AV01")
	dbGoTop()
	While !Eof()
		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := AV01->SEQ
		aColsEx[Len(aColsEx), 2] := AV01->COMP
		aColsEx[Len(aColsEx), 3] := AV01->DESCRIC
		aColsEx[Len(aColsEx), 4] := AV01->MISTURA
		aColsEx[Len(aColsEx), 5] := AV01->AJUSTE
		aColsEx[Len(aColsEx), 6] := AV01->TPCALC1
		aColsEx[Len(aColsEx), 7] := AV01->QTDAJST
		aColsEx[Len(aColsEx), 8] := AV01->QUANT
		aColsEx[Len(aColsEx), 9] := 1
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.
		dbSelectArea("AV01")
		dbSkip()
	End
	AV01->(dbCloseArea())

	zoNwDad1 := MsNewGetDados():New( nLin*.082, nCol*.010, nLin*.175, nCol*.478, GD_INSERT+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, 'U_BIA785H()', "", "AllwaysTrue", oDlgSimul, aHeaderEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ fRatMist ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.11.11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Efetua raterio da quantidade referência sobre os Percen-   ¦¦¦
¦¦¦          ¦ tuais da Mistura do itens da fórmula                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fRatMist()

	Local gk_Retn := .T.
	Local j

	If Len(zoNwDad1:ACOLS) > 0
		For j := 1 To Len(zoNwDad1:ACOLS)
			If zoNwDad1:ACOLS[j][6] == "1"
				kk_Formu := zoNwDad1:ACOLS[j][4]
				kk_Ajust := zoNwDad1:ACOLS[j][5]
				zoNwDad1:ACOLS[j][7] := ( noGet1 * kk_Ajust ) / 100
				zoNwDad1:ACOLS[j][8] := ( noGet1 * ( kk_Formu + kk_Ajust )) / 100

			ElseIf zoNwDad1:ACOLS[j][6] == "2"
				kk_Formu := zoNwDad1:ACOLS[j][4]
				kk_Ajust := zoNwDad1:ACOLS[j][5]
				zoNwDad1:ACOLS[j][7] := (noGet1 * ((kk_Formu*kk_Ajust)/100)) / 100
				zoNwDad1:ACOLS[j][8] := (noGet1 * (kk_Formu+((kk_Formu*kk_Ajust)/100))) / 100

			ElseIf zoNwDad1:ACOLS[j][6] == "3"
				kk_Formu := zoNwDad1:ACOLS[j][4]
				kk_Ajust := zoNwDad1:ACOLS[j][5]
				zoNwDad1:ACOLS[j][7] := (noGet1 * (kk_Ajust/(100-kk_Ajust)))
				zoNwDad1:ACOLS[j][8] := (zoNwDad1:ACOLS[j][7]) + ((noGet1 * kk_Formu) / 100)

			EndIf
		Next j
		zoNwDad1:oBrowse:Refresh()
	Else
		If cGet1 <= 0
			gk_Retn := .F.
		EndIf
	EndIf

Return ( gk_Retn )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA785H  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.11.11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validação da Digitação por Linha do Grid Referência        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA785H()

	Local gk_Retn := .T.
	Local sf_CalcAj := 0, sf_CalcQt := 0
	Local i, j

	If Alltrim(__readvar) == "M->COMP"
		If GdFieldGet("REGISTR",n) == 1
			MsgALERT("Não é possível alterar registros contidos no formula.")
			gk_Retn := .F.
			M->COMP := GdFieldGet("COMP",n)
			zoNwDad1:Refresh()
		Else
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+M->COMP))
				If SB1->B1_MSBLQL == "1"
					MsgALERT("Produto Bloqueado. Favor verificar!!!")
					gk_Retn := .F.
					M->COMP := Space(15)
				Else
					GdFieldPut("DESCRIC", SB1->B1_DESC, n)
				EndIf
			Else
				MsgALERT("Produto Inexistente!!!")
				gk_Retn := .F.
				M->COMP := Space(15)
			EndIf
		EndIf

	ElseIf Alltrim(__readvar) == "M->AJUSTE"
		If GdFieldGet("TPCALC1",n) == "1"                       // Soma
			If M->AJUSTE > 0
				kk_Formu := GdFieldGet("MISTURA",n)
				kk_Ajust := M->AJUSTE
				sf_CalcAj := ( noGet1 * kk_Ajust ) / 100
				sf_CalcQt := ( noGet1 * ( kk_Formu + kk_Ajust )) / 100
				GdFieldPut("QTDAJST", sf_CalcAj, n)
				GdFieldPut("QUANTID", sf_CalcQt, n)
			Else
				GdFieldPut("QTDAJST", 0, n)
				GdFieldPut("QUANTID", 0, n)				
			EndIf
		ElseIf GdFieldGet("TPCALC1",n) == "2"                   // Multiplicação
			If M->AJUSTE > 0
				kk_Formu := GdFieldGet("MISTURA",n)
				kk_Ajust := M->AJUSTE
				sf_CalcAj := (noGet1 * ((kk_Formu*kk_Ajust)/100)) / 100
				sf_CalcQt := (noGet1 * (kk_Formu+((kk_Formu*kk_Ajust)/100))) / 100
				GdFieldPut("QTDAJST", sf_CalcAj, n)
				GdFieldPut("QUANTID", sf_CalcQt, n)
			Else
				GdFieldPut("QTDAJST", 0, n)
				GdFieldPut("QUANTID", 0, n)
			End
		EndIf

	ElseIf Alltrim(__readvar) == "M->TPCALC1"
		If !M->TPCALC1 $ "1/2"
			MsgALERT("Favor preencher com 1=Soma; 2=Multicação")
			gk_Retn := .F.
			M->TPCALC1 := GdFieldGet("TPCALC1",n)
			zoNwDad1:Refresh()
		Else
			If GdFieldGet("AJUSTE",n) > 0
				If M->TPCALC1 == "1"                           // Soma
					kk_Formu := GdFieldGet("MISTURA",n)
					kk_Ajust := GdFieldGet("AJUSTE",n)
					sf_CalcAj := ( noGet1 * kk_Ajust ) / 100
					sf_CalcQt := ( noGet1 * ( kk_Formu + kk_Ajust )) / 100
					GdFieldPut("QTDAJST", sf_CalcAj, n)
					GdFieldPut("QUANTID", sf_CalcQt, n)
				ElseIf M->TPCALC1 == "2"                       // Multiplicação
					kk_Formu := GdFieldGet("MISTURA",n)
					kk_Ajust := GdFieldGet("AJUSTE",n)
					sf_CalcAj := (noGet1 * ((kk_Formu*kk_Ajust)/100)) / 100
					sf_CalcQt := (noGet1 * (kk_Formu+((kk_Formu*kk_Ajust)/100))) / 100
					GdFieldPut("QTDAJST", sf_CalcAj, n)
					GdFieldPut("QUANTID", sf_CalcQt, n)
				EndIf
			Else
				GdFieldPut("QTDAJST", 0, n)
				GdFieldPut("QUANTID", 0, n)			
			EndIf
		EndIf
	EndIf

Return( gk_Retn )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA785H  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.11.11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validação da Digitação por Linha do Grid Referência        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA785X()

	Local gk_Retn := .T.
	Local sf_CalcAj := 0, sf_CalcQt := 0

	If Alltrim(__readvar) == "M->COMP"

		If GdFieldGet("REGISTR",n) == 1
			MsgALERT("Não é possível alterar registros contidos no formula.")
			gk_Retn := .F.
			M->COMP := GdFieldGet("COMP",n)
			zoNwDad1:Refresh()
		Else
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+M->COMP))
				If SB1->B1_MSBLQL == "1"
					MsgALERT("Produto Bloqueado. Favor verificar!!!")
					gk_Retn := .F.
					M->COMP := Space(15)
				Else
					GdFieldPut("DESCRIC", SB1->B1_DESC, n)
				EndIf
			Else
				MsgALERT("Produto Inexistente!!!")
				gk_Retn := .F.
				M->COMP := Space(15)
			EndIf
		EndIf

		GdFieldPut("SEQ", "000", n)

	EndIf

Return( gk_Retn )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA785T  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.01.14 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validação da Digitação por Linha do Grid Referência        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA785T()

	Local gk_Retn := .T.
	Local sf_CalcAj := 0, sf_CalcQt := 0
	Local i, j

	If Alltrim(__readvar) == "M->COMP"

		If GdFieldGet("REGISTR",n) > 0
			MsgALERT("Não é possível alterar registros contidos no formula.")
			gk_Retn := .F.
			M->COMP := GdFieldGet("COMP",n)
			rjNwDad1:Refresh()
		Else
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+M->COMP))
				If SB1->B1_MSBLQL == "1"
					MsgALERT("Produto Bloqueado. Favor verificar!!!")
					gk_Retn := .F.
					M->COMP := Space(15)
				Else
					GdFieldPut("DESCRIC", SB1->B1_DESC, n)
				EndIf
			Else
				MsgALERT("Produto Inexistente!!!")
				gk_Retn := .F.
				M->COMP := Space(15)
			EndIf
		EndIf

	ElseIf Alltrim(__readvar) == "M->QTDAJST"

		kk_QtdOr := GdFieldGet("QUANTID",n)
		kk_NvQtd := kk_QtdOr + M->QTDAJST
		GdFieldPut("QUANTID", kk_NvQtd, n)

	EndIf

Return( gk_Retn )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ foNwRec2 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function foNwRec2()

	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"DTREG","SEQ","COMP","DESCRIC","QTDBASE","MISTURA","AJUSTE","TPCALC2","QTDAJST","QUANTID","REGISTR"}
	Local aAlterFields := {}

	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("G1_REV")
	aAdd(aHeaderEx,{"DtReg"          ,"DTREG"    ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_TRT")
	aAdd(aHeaderEx,{"Seq"            ,"SEQ"      ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_COMP")
	aAdd(aHeaderEx,{"Componente"     ,"COMP"     ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeaderEx,{x3_titulo        ,"DESCRIC"  ,x3_picture           ,50        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"QtdBase"        ,"QTDBASE"  ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Mistura"        ,"MISTURA"  ,"@E 999,999.9999"    ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Per.Ajuste"     ,"AJUSTE"   ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_YSTATUS")
	aAdd(aHeaderEx,{"Tip.Calc"       ,"TPCALC2"  ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,"C"    ,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Gr Ajuste"      ,"QTDAJST"  ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Gr Total"       ,"QUANTID"  ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Registro"       ,"REGISTR"  ,"@E 99999999"        ,8         ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

	dbSelectArea("TCOR")
	dbSetOrder(1)
	If dbSeek(MARK->CODESM)
		While !Eof() .and. TCOR->CODPI == MARK->CODESM
			ws_Seq := TCOR->SEQ
			AADD(aColsEx, Array(Len(aFields)+1) )
			aColsEx[Len(aColsEx), 1] := TCOR->DTREG
			aColsEx[Len(aColsEx), 2] := TCOR->SEQ
			aColsEx[Len(aColsEx), 3] := TCOR->CODMP
			aColsEx[Len(aColsEx), 4] := Substr(Posicione("SB1", 1, xFilial("SB1")+TCOR->CODMP, "B1_DESC"),1,50)
			aColsEx[Len(aColsEx), 5] := TCOR->QTDBASE
			aColsEx[Len(aColsEx), 6] := TCOR->MISTURA
			aColsEx[Len(aColsEx), 7] := TCOR->AJUSTE
			aColsEx[Len(aColsEx), 8] := TCOR->TPCALC
			aColsEx[Len(aColsEx), 9] := TCOR->QTDAJST
			aColsEx[Len(aColsEx),10] := TCOR->QUANTID
			aColsEx[Len(aColsEx),11] := Recno()
			aColsEx[Len(aColsEx), Len(aFields)+1] := .F.
			dbSelectArea("TCOR")
			dbSkip()
		End
	Else
		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := ctod("  /  /  ")
		aColsEx[Len(aColsEx), 2] := ""
		aColsEx[Len(aColsEx), 3] := ""
		aColsEx[Len(aColsEx), 4] := ""
		aColsEx[Len(aColsEx), 5] := 0
		aColsEx[Len(aColsEx), 6] := 0
		aColsEx[Len(aColsEx), 7] := 0
		aColsEx[Len(aColsEx), 8] := ""
		aColsEx[Len(aColsEx), 9] := 0
		aColsEx[Len(aColsEx),10] := 0
		aColsEx[Len(aColsEx),11] := 0
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.
	EndIf

	xk_ArSim := aColsEx

	zoNwRec2 := MsNewGetDados():New( nLin*.200, nCol*.010, nLin*.405, nCol*.478, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgSimul, aHeaderEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ xc_GrvSim  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 09.11.11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Grava Simulação de Cor                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xc_GrvSim()

	Local j

	If zoNwRec2:ACOLS[1][11] <> 0
		If MsgNoYes("Deseja efetuar a limpeza das simulações já gravadas?")
			If zoNwRec2:ACOLS[1][11] <> 0
				For j := 1 To Len(zoNwRec2:ACOLS)
					dbSelectArea("TCOR")
					dbGoTo(zoNwRec2:ACOLS[j][11])
					RecLock("TCOR",.F.)
					Delete
					MsUnLock()
				Next j
			EndIf
		EndIf
	EndIf

	If Len(zoNwDad1:ACOLS) > 0
		For j := 1 To Len(zoNwDad1:ACOLS)
			dbSelectArea("TCOR")
			dbSetOrder(1)
			RecLock("TCOR",.T.)
			Replace CODPI    with MARK->CODESM
			Replace REV      with MARK->REVISA
			Replace SEQ      with zoNwDad1:ACOLS[j][1]
			Replace CODMP    with zoNwDad1:ACOLS[j][2]
			Replace QTDBASE  with noGet1
			Replace MISTURA  with zoNwDad1:ACOLS[j][4]
			Replace AJUSTE   with zoNwDad1:ACOLS[j][5]
			Replace TPCALC   with zoNwDad1:ACOLS[j][6]
			Replace QTDAJST  with zoNwDad1:ACOLS[j][7]
			Replace QUANTID  with zoNwDad1:ACOLS[j][8]
			Replace DTREG    with dDataBase
			MsUnLock()
		Next j
	EndIf

	zz_Esc := .T.
	oDlgSimul:End()

Return

//***************************************************************************
//**                     INICIO  -    Aproveitamento                       **
//***************************************************************************
/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ B785APRO ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09.04.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Monta Tela para Aproveitamento de PI                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B785APRO()

	Private ap_Esc   := .F.
	Private oDlgApro
	Private toButton1
	Private toButton2
	Private toFont1  := TFont():New("Arial Black",,014,,.T.,,,,,.F.,.F.)
	Private toGet1
	Private toGet2
	Private noGet1   := 0
	Private coGet2   := SPACE(3)
	Private toGroup1
	Private toGroup2
	Private toGroup3
	Private toSay1
	Private toSay2
	Private toSay3
	Private toSay4
	Private tDescEsm := Alltrim(MARK->ESMALT)+" ("+Alltrim(MARK->CODESM)+")"
	Private tCodiEsm := MARK->CODESM
	Private tReviEsm := MARK->REVISA
	Private ts_Seq   := "000"

	BEGIN SEQUENCE

		If !fCriaSem("APROVEITAR - INICIO")

			Return

		EndIF


		DEFINE MSDIALOG oDlgApro TITLE "Aproveitamento de PI" FROM nLin*.001, nCol*.001  TO nLin*.830, nCol*.975 COLORS 0, 16777215 PIXEL

		@ nLin*.008, nCol*.006 GROUP toGroup1 TO nLin*.061, nCol*.483 PROMPT " Referência "                       OF oDlgApro COLOR 0, 16777215 PIXEL
		@ nLin*.071, nCol*.006 GROUP toGroup2 TO nLin*.410, nCol*.483 PROMPT " Cálculo "                          OF oDlgApro COLOR 0, 16777215 PIXEL
		@ nLin*.039, nCol*.009 SAY toSay1 PROMPT "Quantidade base para Aproveitamento:" SIZE nLin*.200, nCol*.011 OF oDlgApro FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.036, nCol*.165 MSGET toGet1 VAR noGet1 SIZE nLin*.060, nCol*.008                                  OF oDlgApro VALID u_t_CalcQtd(1) PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
		@ nLin*.020, nCol*.009 SAY toSay2 PROMPT tDescEsm SIZE nLin*.246, nCol*.011                               OF oDlgApro FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.020, nCol*.263 SAY toSay3 PROMPT "Revisão: "+MARK->REVISA SIZE nLin*.070, nCol*.011               OF oDlgApro FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.039, nCol*.210 SAY toSay1 PROMPT "Em Quilogramas" SIZE nLin*.200, nCol*.011                       OF oDlgApro FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.039, nCol*.250 SAY toSay4 PROMPT "Linha:" SIZE nLin*.200, nCol*.011                       OF oDlgApro FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.036, nCol*.300 MSGET toGet2 VAR coGet2 SIZE nLin*.060, nCol*.008                                  OF oDlgApro PICTURE "@!" COLORS 0, 16777215 F3 "ZCO" PIXEL
		fAproDet1()
		@ nLin*.017, nCol*.390 BUTTON toButton1 PROMPT "Gravar"   SIZE nLin*.037, nCol*.008                       OF oDlgApro ACTION t_GrvApro() PIXEL
		@ nLin*.040, nCol*.390 BUTTON toButton2 PROMPT "Fechar"   SIZE nLin*.037, nCol*.008                       OF oDlgApro ACTION (ap_Esc := .T., oDlgApro:End()) PIXEL

		ACTIVATE MSDIALOG oDlgApro VALID ap_Esc

	END SEQUENCE


	ErrorBlock( bErro )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fAproDet1 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 09.04.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fAproDet1()

	Local nX
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"SEQ","COMP","DESCRIC","MISTURA","AJUSTE","QUANTID","REGISTR"}
	Local aAlterFields := {"COMP","AJUSTE","QUANTID"}

	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("G1_TRT")
	aAdd(aHeaderEx,{"Seq"            ,"SEQ"      ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_COMP")
	aAdd(aHeaderEx,{"Componente"     ,"COMP"     ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,"SB1"    ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeaderEx,{x3_titulo        ,"DESCRIC"  ,x3_picture           ,50        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"% Mistura"      ,"MISTURA"	 ,"@E 999,999.9999"    ,x3_tamanho,x3_decimal, , x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Per.Ajuste"     ,"AJUSTE"   ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal, "u_t_CalcQtd(2)",x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Quantidade"     ,"QUANTID"  ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Registro"       ,"REGISTR"  ,"@E 99999999"        ,8         ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

	AV001 := " SELECT 
	AV001 += "        '000' SEQ,
	AV001 += "        G1_COMP COMP,
	AV001 += "        SUBSTRING(B1_DESC,1,50) DESCRIC,
	AV001 += "        G1_YMISTUR MISTURA,
	AV001 += "        0 AJUSTE, 
	AV001 += "        0 QUANT
	AV001 += " FROM "+RetSqlName("SG1")+" SG1 WITH(NOLOCK)
	AV001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON 
	AV001 += "                       	 B1_FILIAL = '"+ xFilial("SB1") +"'
	AV001 += "                       AND B1_COD = G1_COMP
	AV001 += "                       AND SB1.D_E_L_E_T_ = ' '
	AV001 += "  WHERE 
	AV001 += "    	  G1_FILIAL = '"+ xFilial("SG1") +"'
	AV001 += "    AND G1_COD = '"+ MARK->CODESM +"'
	AV001 += "    AND '"+ MARK->REVISA +"' >= G1_REVINI
	AV001 += "    AND '"+ MARK->REVISA +"' <= G1_REVFIM
	AV001 += "    AND SG1.D_E_L_E_T_ = ' '
	TcQuery AV001 ALIAS "AV01" NEW
	dbSelectArea("AV01")
	dbGoTop()
	While !Eof()
		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := AV01->SEQ
		aColsEx[Len(aColsEx), 2] := AV01->COMP
		aColsEx[Len(aColsEx), 3] := AV01->DESCRIC
		aColsEx[Len(aColsEx), 4] := AV01->MISTURA
		aColsEx[Len(aColsEx), 5] := AV01->AJUSTE
		aColsEx[Len(aColsEx), 6] := AV01->QUANT
		aColsEx[Len(aColsEx), 7] := 1
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.
		dbSelectArea("AV01")
		dbSkip()
	End
	AV01->(dbCloseArea())

	zoNwApro1 := MsNewGetDados():New( nLin*.082, nCol*.010, nLin*.405, nCol*.478, GD_INSERT+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, 'U_BIA785X()', "", "AllwaysTrue", oDlgApro, aHeaderEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ t_CalcQtd  ¦ Autor ¦ FACILE Sistemas     ¦ Data ¦ 22.03.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Calcular a quantidade, para a grid, com base na quantidade ¦¦¦
¦¦¦          ¦ base para aproveitamento.                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Parametro ¦ nRefOper                                                   ¦¦¦
¦¦¦          ¦ 1 - Execução a partir do preenchimento do Cpo. na Enchoice ¦¦¦
¦¦¦          ¦ 2 - Execução a partir do preenchimento na Grid Cpo. Mistura¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function t_CalcQtd(nRefOper)
	Local _kf 		:= 0
	Local whQtdApr	:= 0
	Local nPGrdMst	:= 0
	Local nPGrdQtd	:= 0
	Local nPGrdAju	:= 0
	Local cReadVar	:= ""
	Local cConteudo := ""

	Default nRefOper := 1

	whQtdApr := noGet1													// Quantidade digitada (ench.).
	If ( Valtype(zoNwApro1) == "O" )
		nPGrdMst := aScan(zoNwApro1:aHeader, {|x| x[2] == "MISTURA" })	// Coluna Grid : % Mistura
		nPGrdAju := aScan(zoNwApro1:aHeader, {|x| x[2] == "AJUSTE" })	// Coluna Grid : % Ajuste
		nPGrdQtd := aScan(zoNwApro1:aHeader, {|x| x[2] == "QUANTID" })	// Coluna Grid : Quantidade 
	EndIf
	// Percorrer as linhas da GRID:
	// Executar a regra : Assim que um número for inserido, deverá multiplicar este valor pela informação contida no GET "Quantidade base para Aproveitamento" e gravar na linha do acols correspondente coluna "Quantidade". (Exemplo: 1000(Get) * 10/100)
	// Preencher a informação para quantidade.
	If ( (nPGrdAju > 0) .AnD. (nPGrdQtd > 0) )
		If ( nRefOper == 1 )
			For _kf := 1 To Len(zoNwApro1:ACOLS)
				If ( whQtdApr <> 0 )
					If ( zoNwApro1:ACOLS[_kf][nPGrdAju] <> 0 )
						zoNwApro1:ACOLS[_kf][nPGrdQtd] := ( noGet1 * (zoNwApro1:ACOLS[_kf][nPGrdAju] / 100) )
					EndIf
				ElseIf ( whQtdApr == 0 )
					zoNwApro1:ACOLS[_kf][nPGrdQtd] := 0
				EndIf
			Next _kf
		Else
			If ( whQtdApr <> 0 )
				// Capturar o conteúdo do campo.
				cReadVar := ReadVar()
				If ( Alltrim(cReadVar) == AllTrim("M->AJUSTE") )
					cConteudo := &cReadVar
				Else
					cConteudo := GdFieldGet("AJUSTE", zoNwApro1:nAt)
				Endif
				If ( cConteudo <> 0 )
					GdFieldPut("QUANTID", noGet1 * (cConteudo / 100), zoNwApro1:nAt)
				EndIf
			ElseIf ( whQtdApr == 0 )
				GdFieldPut("QUANTID", 0, zoNwApro1:nAt)
			EndIf
		EndIf
		// Atualizar a GRID para exibir os novos valores.
		zoNwApro1:Refresh()
	EndIf


Return(.T.)


/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ t_GrvApro  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 11.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Grava Order de Produção de Aproveitamento ajustando o Empe-¦¦¦
¦¦¦          ¦ nho p/ apenas os itens possuirem quantidade maior que zero ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function t_GrvApro()

	Local _kf, _bj
	Local xpNumOp 	:= GetNumSc2()
	Local _nAux		:=	0
	Local _cAux		:=	0
	Local _cLocal	:=	""
	Local nPGrdQtd	:= 0
	Local nPGrdSKU	:= 0
	Local nPGrdSeq	:= 0

	If ( Valtype(zoNwApro1) == "O" )
		nPGrdSeq := aScan(zoNwApro1:aHeader, {|x| x[2] == "SEQ" })		// Coluna Grid : Sequencia
		nPGrdSKU := aScan(zoNwApro1:aHeader, {|x| x[2] == "COMP" })		// Coluna Grid : Componente
		nPGrdQtd := aScan(zoNwApro1:aHeader, {|x| x[2] == "QUANTID" })	// Coluna Grid : Quantidade 
	EndIf

	whQtdApr := 0
	For _kf := 1 To Len(zoNwApro1:ACOLS)
		If zoNwApro1:ACOLS[_kf][nPGrdQtd] <> 0
			whQtdApr += zoNwApro1:ACOLS[_kf][nPGrdQtd]
		EndIf
	Next _kf

	If ( whQtdApr <> noGet1 )
		Aviso('Aproveitamento','O aproveitamento será realizado. Porém atente-se para que a quantidade a ser gerada para esta ordem de produção de aproveitamento é diferente da soma das quantidade dos seus componentes: '+Alltrim(Str(whQtdApr))+'. Diferença: '+Alltrim(Str(whQtdApr-noGet1))+'.',{'Ok'})
		//Return
	EndIf

	gg_ChNOp := ""
	If ( whQtdApr > 0 )
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+tCodiEsm))

		aMata650  := {{'C2_NUM'      ,xpNumOp                             ,NIL},;
		{              'C2_ITEM'     ,"01"                                ,NIL},;
		{              'C2_SEQUEN'   ,"001"                               ,NIL},;
		{              'C2_LINHA'    ,coGet2                              ,NIL},;
		{              'C2_PRODUTO'  ,tCodiEsm                            ,NIL},;
		{              'C2_QUANT'    ,whQtdApr                            ,NIL},;
		{              'C2_QTSEGUM'  ,ConvUm(tCodiEsm,whQtdApr,0,2)       ,NIL},;
		{              'C2_UM'       ,SB1->B1_UM                          ,NIL},;
		{              'C2_CC'       ,SB1->B1_CC                          ,NIL},;
		{              'C2_SEGUM'    ,SB1->B1_SEGUM                       ,NIL},;
		{              'C2_DATPRI'   ,dDataBase                           ,NIL},;
		{              'C2_DATPRF'   ,dDataBase                           ,NIL},;
		{              'C2_REVISAO'  ,tReviEsm                            ,NIL},;
		{              'C2_TPOP'     ,"F"                                 ,NIL},;
		{              'C2_EMISSAO'  ,dDataBase                           ,NIL},;
		{              'C2_ROTEIRO'  ,SB1->B1_OPERPAD                     ,NIL},;
		{              'C2_OPC'      ,""                                  ,NIL},;
		{              'C2_YSTAOPR'  ,"3"                                 ,NIL},;
		{              'AUTEXPLODE'  ,'N'                                 ,NIL} }
		lMsErroAuto := .f.
		MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
		If lMsErroAuto
			Mostraerro()
			DisarmTransaction()
			Break
			lMostraErro:= .F.
		Else
			RecLock("SC2",.F.)
			SC2->C2_BATCH := "S"
			SC2->(MsUnlock())
		EndIf
		gg_ChNOp := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
	EndIf

	xk_ArSim := {}
	aColsEx  := {}
	If !Empty(gg_ChNOp)

		For _bj := 1 To Len(zoNwApro1:ACOLS)

			If ( zoNwApro1:ACOLS[_bj][nPGrdQtd] <> 0 )

				U_BFG73LIN(coGet2,zoNwApro1:ACOLS[_bj][nPGrdSKU],@_cAux,.F.)

				_nAux := ConvUm(zoNwApro1:ACOLS[_bj][nPGrdSKU], SD4->D4_QTDEORI,0,2)
				dbSelectArea("SD4")
				dbSetOrder(1)
				// Tratamento específico para os casos em que o um item a mais foi incluído na correção
				RecLock("SD4",.T.)
				SD4->D4_FILIAL   := xFilial("SD4")
				SD4->D4_COD      := zoNwApro1:ACOLS[_bj][nPGrdSKU]
				SD4->D4_LOCAL    := _cAux
				SD4->D4_OP       := gg_ChNOp
				SD4->D4_DATA     := dDataBase
				SD4->D4_QTDEORI  := zoNwApro1:ACOLS[_bj][nPGrdQtd]
				SD4->D4_QUANT    := zoNwApro1:ACOLS[_bj][nPGrdQtd]
				SD4->D4_YQTDFLX  := zoNwApro1:ACOLS[_bj][nPGrdQtd]
				SD4->D4_QTSEGUM  := _nAux
				MsUnLock()

				AADD(aColsEx, Array(12) )
				aColsEx[Len(aColsEx), 1] := dDataBase
				aColsEx[Len(aColsEx), 2] := zoNwApro1:ACOLS[_bj][nPGrdSeq]
				aColsEx[Len(aColsEx), 3] := zoNwApro1:ACOLS[_bj][nPGrdSKU]
				aColsEx[Len(aColsEx), 4] := Substr(Posicione("SB1", 1, xFilial("SB1")+zoNwApro1:ACOLS[_bj][nPGrdSKU], "B1_DESC"),1,50)
				aColsEx[Len(aColsEx), 5] := zoNwApro1:ACOLS[_bj][nPGrdQtd]
				aColsEx[Len(aColsEx), 6] := 0
				aColsEx[Len(aColsEx), 7] := 0
				aColsEx[Len(aColsEx), 8] := "1" // Soma
				aColsEx[Len(aColsEx), 9] := zoNwApro1:ACOLS[_bj][nPGrdQtd]
				aColsEx[Len(aColsEx),10] := noGet1
				aColsEx[Len(aColsEx),11] := 0
				aColsEx[Len(aColsEx),12] := .F.

			EndIf

		Next _bj

	EndIf

	xk_ArSim := aColsEx
	If Len(xk_ArSim) > 0
		xc_ImpSim(3)
	EndIf

	ap_Esc := .T.
	oDlgApro:End()

	fh_Esc := .T.
	oDlg1:End()

Return

//***************************************************************************
//**                       FIM   -    Aproveitamento                       **
//***************************************************************************

//***************************************************************************
//**                     INICIO  -    Adicionais                           **
//***************************************************************************
/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ B785ADIC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 10.05.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Monta Tela para Adicionais de PI                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B785ADIC()

	Private oDlgAdic
	Private toButton1
	Private toButton2
	Private toFont1  := TFont():New("Arial Black",,014,,.T.,,,,,.F.,.F.)
	Private toGet1
	Private noGet1   := 0
	Private toGet2
	Private coGet2  := SPACE(3)
	Private toGroup1
	Private toGroup2
	Private toGroup3
	Private toSay1
	Private toSay2
	Private toSay3
	Private tDescEsm := Alltrim(MARK->ESMALT)+" ("+Alltrim(MARK->CODESM)+")"
	Private tCodiEsm := MARK->CODESM
	Private tReviEsm := MARK->REVISA
	Private ts_Seq   := "000"
	Private cd_Esc   := .F.

	BEGIN SEQUENCE

		If !fCriaSem("ADICIONAR - INICIO")

			Return

		EndIF



		DEFINE MSDIALOG oDlgAdic TITLE "Adicionais de PI" FROM nLin*.001, nCol*.001  TO nLin*.830, nCol*.975 COLORS 0, 16777215 PIXEL

		@ nLin*.008, nCol*.006 GROUP toGroup1 TO nLin*.061, nCol*.483 PROMPT " Referência "                       OF oDlgAdic COLOR 0, 16777215 PIXEL
		@ nLin*.071, nCol*.006 GROUP toGroup2 TO nLin*.410, nCol*.483 PROMPT " Cálculo "                          OF oDlgAdic COLOR 0, 16777215 PIXEL
		@ nLin*.039, nCol*.009 SAY toSay1 PROMPT "Quantidade base para Adicionar:" SIZE nLin*.200, nCol*.011 OF oDlgAdic FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.036, nCol*.165 MSGET toGet1 VAR noGet1 SIZE nLin*.060, nCol*.008                                  OF oDlgAdic PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
		@ nLin*.020, nCol*.009 SAY toSay2 PROMPT tDescEsm SIZE nLin*.246, nCol*.011                               OF oDlgAdic FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.020, nCol*.263 SAY toSay3 PROMPT "Revisão: "+MARK->REVISA SIZE nLin*.070, nCol*.011               OF oDlgAdic FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.043, nCol*.210 SAY toSay1 PROMPT "Em Quilogramas" SIZE nLin*.200, nCol*.011                       OF oDlgAdic FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.063, nCol*.253 SAY toSay1 PROMPT "Tip.Calc --> 1=Soma; 2=Multiplicação" SIZE nLin*.300, nCol*.011 OF oDlgAdic FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.039, nCol*.250 SAY toSay4 PROMPT "Linha:" SIZE nLin*.200, nCol*.011                       OF oDlgAdic FONT toFont1 COLORS 0, 16777215 PIXEL
		@ nLin*.036, nCol*.300 MSGET toGet2 VAR coGet2 SIZE nLin*.060, nCol*.008                                  OF oDlgAdic PICTURE "@!" COLORS 0, 16777215 F3 "ZCO" PIXEL

		foCrDad1()
		@ nLin*.017, nCol*.390 BUTTON toButton1 PROMPT "Gravar"   SIZE nLin*.037, nCol*.008                       OF oDlgAdic ACTION t_GrvAdic() PIXEL
		@ nLin*.040, nCol*.390 BUTTON toButton2 PROMPT "Fechar"   SIZE nLin*.037, nCol*.008                       OF oDlgAdic ACTION (cd_Esc := .T., oDlgAdic:End()) PIXEL

		ACTIVATE MSDIALOG oDlgAdic VALID cd_Esc


	END SEQUENCE


	ErrorBlock( bErro )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ foNwDad1 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 10.05.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function foCrDad1()

	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"SEQ","COMP","DESCRIC","MISTURA","AJUSTE","TPCALC1","QTDAJST","QUANTID","REGISTR"}
	Local aAlterFields := {"SEQ","COMP","AJUSTE","TPCALC1"}

	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("G1_TRT")
	aAdd(aHeaderEx,{"Seq"            ,"SEQ"      ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_COMP")
	aAdd(aHeaderEx,{"Componente"     ,"COMP"     ,x3_picture           ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,"SB1"    ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeaderEx,{x3_titulo        ,"DESCRIC"  ,x3_picture           ,50        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Mistura"        ,"MISTURA"  ,"@E 999,999.9999"    ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Per.Ajuste"     ,"AJUSTE"   ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_YSTATUS")
	aAdd(aHeaderEx,{"Tip.Calc"       ,"TPCALC1"  ,"@E"                 ,1         ,0         ,,x3_usado,"C"    ,         ,          })
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Gr Ajuste"      ,"QTDAJST"  ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Gr Total"       ,"QUANTID"  ,"@E 999,999.999999"  ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("G1_QUANT")
	aAdd(aHeaderEx,{"Registro"       ,"REGISTR"  ,"@E 99999999"        ,8         ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

	AV001 := " SELECT '000' SEQ,
	AV001 += "        G1_COMP COMP,
	AV001 += "        SUBSTRING(B1_DESC,1,50) DESCRIC,
	AV001 += "        G1_YMISTUR MISTURA,
	AV001 += "        0 AJUSTE,
	AV001 += "        0 QTDAJST,
	AV001 += "        '1' TPCALC1,
	AV001 += "        0 QUANT
	AV001 += "   FROM "+RetSqlName("SG1")+" SG1  WITH(NOLOCK)
	AV001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1  WITH(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	AV001 += "                       AND B1_COD = G1_COMP
	AV001 += "                       AND SB1.D_E_L_E_T_ = ' '
	AV001 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
	AV001 += "    AND G1_COD = '"+MARK->CODESM+"'
	AV001 += "    AND '"+MARK->REVISA+"' >= G1_REVINI
	AV001 += "    AND '"+MARK->REVISA+"' <= G1_REVFIM
	AV001 += "    AND SG1.D_E_L_E_T_ = ' '
	TcQuery AV001 ALIAS "AV01" NEW
	dbSelectArea("AV01")
	dbGoTop()
	While !Eof()
		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := AV01->SEQ
		aColsEx[Len(aColsEx), 2] := AV01->COMP
		aColsEx[Len(aColsEx), 3] := AV01->DESCRIC
		aColsEx[Len(aColsEx), 4] := AV01->MISTURA
		aColsEx[Len(aColsEx), 5] := AV01->AJUSTE
		aColsEx[Len(aColsEx), 6] := AV01->TPCALC1
		aColsEx[Len(aColsEx), 7] := AV01->QTDAJST
		aColsEx[Len(aColsEx), 8] := AV01->QUANT
		aColsEx[Len(aColsEx), 9] := 1
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.
		dbSelectArea("AV01")
		dbSkip()
	End
	AV01->(dbCloseArea())

	zoNwAdic1 := MsNewGetDados():New( nLin*.082, nCol*.010, nLin*.405, nCol*.478, GD_INSERT+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, 'U_BIA785H()', "", "AllwaysTrue", oDlgAdic, aHeaderEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ t_GrvAdic  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 11.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Grava Order de Produção de Correção ajustando o Empenho p/ ¦¦¦
¦¦¦          ¦ apenas os itens possuirem ajuste maior que zero            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function t_GrvAdic()

	Local _kf, _bj
	Local xpNumOp := GetNumSc2()
	Local _cLocal	:=	""
	Local _cAlias

	If Empty(coGet2)
		MsgINFO("Favor preencher o campo Linha antes de prosseguir", "Atenção")
		Return	
	EndIf

	whQtdAdic := 0
	For _kf := 1 To Len(zoNwAdic1:ACOLS)
		If zoNwAdic1:ACOLS[_kf][7] <> 0
			whQtdAdic += zoNwAdic1:ACOLS[_kf][7]
		EndIf
	Next _kf

	gg_ChNOp := ""
	If whQtdAdic > 0
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+tCodiEsm))	

		aMata650  := {{'C2_NUM'      ,xpNumOp                             ,NIL},;
		{              'C2_ITEM'     ,"01"                                ,NIL},;
		{              'C2_SEQUEN'   ,"001"                               ,NIL},;
		{              'C2_LINHA'    ,coGet2                              ,NIL},;
		{              'C2_PRODUTO'  ,tCodiEsm                            ,NIL},;
		{              'C2_QUANT'    ,whQtdAdic                           ,NIL},;
		{              'C2_QTSEGUM'  ,ConvUm(tCodiEsm,whQtdAdic,0,2)      ,NIL},;
		{              'C2_UM'       ,SB1->B1_UM                          ,NIL},;
		{              'C2_CC'       ,SB1->B1_CC                          ,NIL},;
		{              'C2_SEGUM'    ,SB1->B1_SEGUM                       ,NIL},;
		{              'C2_DATPRI'   ,dDataBase                           ,NIL},;
		{              'C2_DATPRF'   ,dDataBase                           ,NIL},;
		{              'C2_REVISAO'  ,tReviEsm                            ,NIL},;
		{              'C2_TPOP'     ,"F"                                 ,NIL},;
		{              'C2_EMISSAO'  ,dDataBase                           ,NIL},;
		{              'C2_ROTEIRO'  ,SB1->B1_OPERPAD                     ,NIL},;
		{              'C2_OPC'      ,""                                  ,NIL},;
		{              'C2_YSTAOPR'  ,"5"                                 ,NIL},;
		{              'AUTEXPLODE'  ,'N'                                 ,NIL} }
		lMsErroAuto := .f.
		MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
		If lMsErroAuto
			Mostraerro()
			Return
		Else
			RecLock("SC2",.F.)
			SC2->C2_BATCH := "S"
			SC2->(MsUnlock())
		EndIf
		gg_ChNOp := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
	EndIf

	xk_ArSim := {}
	aColsEx  := {}
	If !Empty(gg_ChNOp)

		For _bj := 1 To Len(zoNwAdic1:ACOLS)

			If zoNwAdic1:ACOLS[_bj][7] <> 0

				dbSelectArea("SD4")
				dbSetOrder(1)
				// Tratamento específico para os casos em que o um item a mais foi incluído na correção
				_cAux	:=	Posicione("ZCN", 1,  xFilial("ZCN")+zoNwAdic1:ACOLS[_bj][2]+_cEmpSeq, "ZCN_LOCAL")
				_nAux	:=	ConvUm(zoNwAdic1:ACOLS[_bj][2], SD4->D4_QTDEORI,0,2)
				RecLock("SD4",.T.)
				SD4->D4_FILIAL   := xFilial("SD4")
				SD4->D4_COD      := zoNwAdic1:ACOLS[_bj][2]
				SD4->D4_LOCAL    := _cAux
				SD4->D4_OP       := gg_ChNOp
				SD4->D4_DATA     := dDataBase
				SD4->D4_QTDEORI  := zoNwAdic1:ACOLS[_bj][7]
				SD4->D4_QUANT    := zoNwAdic1:ACOLS[_bj][7]
				SD4->D4_YQTDFLX  := zoNwAdic1:ACOLS[_bj][7]
				SD4->D4_QTSEGUM  := _nAux
				MsUnLock()

				AADD(aColsEx, Array(12) )
				aColsEx[Len(aColsEx), 1] := dDataBase
				aColsEx[Len(aColsEx), 2] := zoNwAdic1:ACOLS[_bj][1]
				aColsEx[Len(aColsEx), 3] := zoNwAdic1:ACOLS[_bj][2]
				aColsEx[Len(aColsEx), 4] := Substr(Posicione("SB1", 1, xFilial("SB1")+zoNwAdic1:ACOLS[_bj][2], "B1_DESC"),1,50)
				aColsEx[Len(aColsEx), 5] := zoNwAdic1:ACOLS[_bj][7]
				aColsEx[Len(aColsEx), 6] := 0
				aColsEx[Len(aColsEx), 7] := 0
				aColsEx[Len(aColsEx), 8] := "1" // Soma
				aColsEx[Len(aColsEx), 9] := zoNwAdic1:ACOLS[_bj][7]
				aColsEx[Len(aColsEx),10] := noGet1
				aColsEx[Len(aColsEx),11] := 0
				aColsEx[Len(aColsEx),12] := .F.

			EndIf

		Next _bj

	EndIf

	xk_ArSim := aColsEx
	If Len(xk_ArSim) > 0
		xc_ImpSim(2)
	EndIf

	cd_Esc := .T.
	oDlgAdic:End()

	fh_Esc := .T.
	oDlg1:End()

Return

//***************************************************************************
//**                       FIM   -    Adicionais                           **
//***************************************************************************

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIMPS785 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 03.01.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Imprime ficha de separação de Carga                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIMPS785()

	Local i

	cHInicio := Time()
	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
	fCabec   := "Carga para Separação " + Alltrim(xk_ArrSp[1][6])
	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont32  := TFont():New("Lucida Console"    ,9,32,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Armazenando....   Tempo: "+cTempo)

	fImpCabec()
	kc_First := .T.
	kc_MisTl := 0
	kc_QtdTt := 0
	For i := 1 To Len(xk_ArrSp)
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		If kc_First
			oPrint:Say  (nRow1, 0100, "Ref.Sistema: " + kf_ProdOp                                                                           , oFont14)
			cft_Rvs := Alltrim(xk_ArrSp[i][7])
			If Empty(cft_Rvs)
				cft_Rvs := "000"
			EndIf
			dfr_RefRev := "Revisão: " + cft_Rvs + "     Validade: "+dtoc(xk_ArrSp[i][8])+ " até: "+dtoc(xk_ArrSp[i][9])
			oPrint:Say  (nRow1, 1800, dfr_RefRev                                                                                            , oFont14)
			nRow1 += 075
			dvf_Descri := Alltrim(Posicione("SB1",1,xFilial("SB1")+kf_ProdOp,"B1_DESC"))
			oPrint:Say  (nRow1, 0100, dvf_Descri                                                             , oFont32)
			nRow1 += 150
			xf_Titu := +;
			Padr("Código"                                                                   ,15)+" "+;
			Padr("Componente"                                                               ,50)+" "+;
			Padc("UM"                                                                       ,02)+" "+;
			Padl("% Mistura"                                                                ,15)+" "+;
			Padl("Quantidade"                                                               ,15)
			oPrint:Say  (nRow1 ,0050 ,xf_Titu                               ,oFont10)
			oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
			nRow1 += 075
			kc_First := .F.
		EndIf

		xf_Item := +;
		Padr(xk_ArrSp[i][1]                                                             ,15)+" "+;
		Padr(xk_ArrSp[i][2]                                                             ,50)+" "+;
		Padc(xk_ArrSp[i][3]                                                             ,02)+" "+;
		Padl(Transform(xk_ArrSp[i][4], "@E 9999.99999")                                 ,15)+" "+;
		Padl(Transform(xk_ArrSp[i][5], "@E 999,999,999.999")                            ,15)
		oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont10)
		oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
		nRow1 += 075
		kc_MisTl += xk_ArrSp[i][4]
		kc_QtdTt += xk_ArrSp[i][5]
	Next i

	xf_Totl := +;
	Padr("Totais........."                                                          ,15)+" "+;
	Padr(""                                                                         ,50)+" "+;
	Padc(""                                                                         ,02)+" "+;
	Padl(Transform(kc_MisTl, "@E 9999.99999")                                       ,15)+" "+;
	Padl(Transform(kc_QtdTt, "@E 999,999,999.999")                                  ,15)
	oPrint:Say  (nRow1 ,0050 ,xf_Totl                               ,oFont10)
	nRow1 += 075

	fImpRoda()

	oPrint:EndPage()
	oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ xc_ImpSim  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 03.01.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imprime Simulação de Cor                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xc_ImpSim(cfOrig)

	Local i
	Private sxTela
	Private sxBoton
	Private sxSeq
	Private xcGet
	Private ccGet := Space(3)

	If cfOrig == 1

		fCabec   := "Simulação de Coloração"
		If Empty(xk_ArSim[1][2])
			MsgINFO("Não existe simulação gravada!!!")
			Return
		EndIf
		DEFINE MSDIALOG sxTela FROM 000, 000  TO 100, 350 COLORS 0, 16777215 PIXEL
		@ 011, 010 SAY sxSeq PROMPT "Informe o número a sequencia que deseja imprimir:" SIZE 125, 008 OF sxTela COLORS 0, 16777215 PIXEL
		@ 010, 136 MSGET xcGet VAR ccGet SIZE 027, 010 OF sxTela COLORS 0, 16777215 PIXEL
		@ 026, 009 BUTTON sxBoton PROMPT "Confirma" SIZE 155, 012 OF sxTela ACTION sxTela:End() PIXEL
		ACTIVATE MSDIALOG sxTela
		xf_Titu := +;
		Padr("DtReg"                                                                    ,08)+" "+;
		Padr("Seq"                                                                      ,03)+" "+;
		Padr("Componente"                                                               ,15)+" "+;
		Padr("Descrição"                                                                ,50)+" "+;
		Padc("UM"                                                                       ,02)+" "+;
		Padl("Qtd Grama"                                                                ,15)+" "+;
		Padl("Mistura"                                                                  ,15)+" "+;
		Padl("% Ajuste"                                                                 ,15)+" "+;
		Padr("Tipo Calc"                                                                ,15)+" "+;
		Padl("Gr Ajuste"                                                                ,15)+" "+;
		Padl("Gr Total"                                                                 ,15)

	ElseIf cfOrig == 2

		fCabec   := "Adicionais de PI"
		ccGet    := "000"
		zCodiEsm := tCodiEsm
		zReviEsm := tReviEsm
		If !MsgNOYES("Deseja imprimir a Adicionais de PI?","Confirmação de Impressão")
			Return
		EndIf

		xf_Titu := +;
		Padr("DtReg"                                                                    ,08)+" "+;
		Padr("Seq"                                                                      ,03)+" "+;
		Padr("Componente"                                                               ,15)+" "+;
		Padr("Descrição"                                                                ,50)+" "+;
		Padc("UM"                                                                       ,02)+" "+;
		Padl("Quantidade"                                                               ,15)+" "+;
		Padl("Mistura"                                                                  ,15)+" "+;
		Padl("% Ajuste"                                                                 ,15)+" "+;
		Padr("Tipo Calc"                                                                ,15)+" "+;
		Padl("Qtd Ajuste"                                                               ,15)+" "+;
		Padl("Qtd Tanque"                                                               ,15)

	ElseIf cfOrig == 3

		fCabec   := "Aproveitamento de PI"
		ccGet    := "000"
		zCodiEsm := tCodiEsm
		zReviEsm := tReviEsm
		If !MsgNOYES("Deseja imprimir Aproveitamento de PI?","Confirmação de Impressão")
			Return
		EndIf

		xf_Titu := +;
		Padr("DtReg"                                                                    ,08)+" "+;
		Padr("Seq"                                                                      ,03)+" "+;
		Padr("Componente"                                                               ,15)+" "+;
		Padr("Descrição"                                                                ,50)+" "+;
		Padc("UM"                                                                       ,02)+" "+;
		Padl("Quantidade"                                                               ,15)+" "+;
		Padl("Mistura"                                                                  ,15)+" "+;
		Padl("% Ajuste"                                                                 ,15)+" "+;
		Padr("Tipo Calc"                                                                ,15)+" "+;
		Padl("Qtd Ajuste"                                                               ,15)+" "+;
		Padl("Qtd Tanque"                                                               ,15)

	EndIf

	cHInicio := Time()
	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"

	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont32  := TFont():New("Lucida Console"    ,9,32,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Armazenando....   Tempo: "+cTempo)

	fImpCabec()
	kc_First := .T.
	kc_MisTl := 0
	kc_QtdTt := 0
	For i := 1 To Len(xk_ArSim)
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		If kc_First

			oPrint:Say  (nRow1, 0100, "Ref.Sistema: " + zCodiEsm                                             , oFont14)
			cft_Rvs := zReviEsm
			If Empty(cft_Rvs)
				cft_Rvs := "000"
			EndIf
			dfr_RefRev := "Revisão: " + cft_Rvs
			oPrint:Say  (nRow1, 1800, dfr_RefRev                                                             , oFont14)
			nRow1 += 075
			dvf_Descri := Alltrim(Posicione("SB1",1,xFilial("SB1")+zCodiEsm,"B1_DESC"))
			oPrint:Say  (nRow1, 0100, dvf_Descri                                                             , oFont32)
			nRow1 += 150
			oPrint:Say  (nRow1 ,0050 ,xf_Titu                               ,oFont10)
			oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
			nRow1 += 075
			kc_First := .F.

		EndIf

		xf_TipoC := IIF(xk_ArSim[i][8] == "1", "Soma", "Multiplicação")
		xf_Item := +;
		Padr(dtoc(xk_ArSim[i][1])                                                       ,08)+" "+;
		Padr(xk_ArSim[i][2]                                                             ,03)+" "+;
		Padr(xk_ArSim[i][3]                                                             ,15)+" "+;
		Padr(xk_ArSim[i][4]                                                             ,50)+" "+;
		Padc(Posicione("SB1",1,xFilial("SB1")+xk_ArSim[i][3],"B1_UM")                   ,02)+" "+;
		Padl(Transform(xk_ArSim[i][5], "@E 999,999,999.999")                            ,15)+" "+;
		Padl(Transform(xk_ArSim[i][6], "@E 999,999,999.999")                            ,15)+" "+;
		Padl(Transform(xk_ArSim[i][7], "@E 999,999,999.999")                            ,15)+" "+;
		Padr(xf_TipoC                                                                   ,15)+" "+;
		Padl(Transform(xk_ArSim[i][9], "@E 999,999,999.999")                            ,15)+" "+;
		Padl(Transform(xk_ArSim[i][10], "@E 999,999,999.999")                           ,15)
		oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont10)
		oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
		nRow1 += 075

	Next i

	fImpRoda()

	oPrint:EndPage()
	oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025

	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
	oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)

	nRow1 += 175
	oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 050, 2300, 3350)
	oPrint:Say  (2300+30 , 050,"Prog.: " + fPerg                                      ,oFont7)
	oPrint:Say  (2300+30 ,2850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data              ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Linha             ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate Linha            ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Grupo de Produto     ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"06","Status das Ord.Produç?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Em Abertas","","","","","Em Carga","","","","","Sequenciadas","","","","","Separadas","","","","","Todas","","","",""})
	aAdd(aRegs,{cPerg,"07","Aplicação            ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Producao","","","","","Manutencao","","","","","Melhoria","","","","","Seguranca","","","","","Calibracao","","","",""})
	aAdd(aRegs,{cPerg,"08","TAG                  ?","","","mv_ch8","C",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Matricula            ?","","","mv_ch9","C",08,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","ZZY"})
	aAdd(aRegs,{cPerg,"10","Empresa              ?","","","mv_cha","N",01,0,0,"C","","mv_par10","Biancogres","","","","","Incesa","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Ordem de Apresentação?","","","mv_chb","N",01,0,0,"C","","mv_par11","Data/CodEsm","","","","","Data/ProdPai","","","","","CodEsm/Data","","","","","ProdPai/Data","","","","","","","","",""})
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

Static Function fCriaSem(_cLocal)

	Local _lRet	:=	.T.
	Local _cSql	:=	""

	Default _cLocal	:= ""

	If GetMv("MV_YBLQRCM")
		MsgInfo("Rotina bloqueada para execução pois o parâmetro do bloqueio para CMV está ativado!","BIA785")
		Return .F.
	EndIF		


Return _lRet