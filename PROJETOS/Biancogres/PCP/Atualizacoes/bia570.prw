#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#Include "font.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "vkey.ch"
#include "TOTVS.ch"

/*/{Protheus.doc} BIA570
@author Marcos Alberto Soprani
@since 04/12/19
@version 1.0
@description Apontamento automático de Produção
.            Prg. (Ori):= BIA292
.            Progr.(2) := BIA742
.            Programa  := BIA570
.            Empresa   := Biancogres Cerâmica S/A
.            Data (Ori):= 13/04/12
.            Data (2)  := 29/11/13
.            Data      := 20/04/15
.            Uso       := PCP
.                         Aplicação := Apontamento automático de Produção de Cerâmica a partir do
.                         Sistema Ecosis  -  diasemana
.                          Criado novo fonte a partir do original BIA292 em 27/11/13 para
.                         a partir de 01/11/13 mudar o procedimento de importação de pro-
.                         conforme descritivos definido com a diretoria Geral e Industrial
.                          Criado novo fonte em 20/04/15 para permitir o apontamento de
.                         produção aglutinado.
@type function
/*/

User Function BIA570()

	Local   x
	Private zx_Ambi        := ""
	Private oButton1
	Private oButton2
	Private oButton3
	Private oDlg292
	Private oGroup1
	Private oNGDd1Ap
	Private aCpFs          := {}
	Private aCpAp          := {}
	Private zp_Tmp
	Private xwDados7       := {}
	Private fh_Esc         := .F.
	Private cj_Fecha       := .T.
	Private xyEmpr
	Private bbRetArq

	Private hhTmpINI      := ""
	Private hhTmpFIM      := ""

	Private _aTabImp 	   := {}
	Private _aTabDel	   := {}
	Private _cLogTxt	   := ""
	Private lAutoErrNoFile := .T.
	Private nxEtqt         := 0
	Private yyDtIni
	Private yyDtFim
	Private kt_BsDad       := ""
	Private XW009          := ""
	Private YD003          := ""	

	Public dDescrAdc       := ""
	Public dCodPAClass     := ""
	Public xDataPSaldo     := dDataBase
	Public lVerifEstNg
	Public lxPrdMaior
	Public kQtddPallet     := 0
	Public kQtddSupLat     := 0

	Public klCancCtrl      := .F.

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YBLQRCM")
		CriarSX6("MV_YBLQRCM", 'L', 'Controle de Bloqueio de Rotinas do RCM', ".F." )
	EndIf

	Aadd( aCpFs , {"ETIQUET"  ,"N",010,000} )
	Aadd( aCpFs , {"SEQUENC"  ,"N",010,000} )
	Aadd( aCpFs , {"DTMOV"    ,"D",008,000} )
	Aadd( aCpFs , {"HORA"     ,"C",005,000} )
	Aadd( aCpFs , {"NUMOP"    ,"C",013,000} )
	Aadd( aCpFs , {"D3COD"    ,"C",015,000} )
	Aadd( aCpFs , {"DESCRIC"  ,"C",035,000} )
	Aadd( aCpFs , {"PROD"     ,"C",015,000} )
	Aadd( aCpFs , {"REFER"    ,"C",020,000} )
	Aadd( aCpFs , {"LOTEPR"   ,"C",010,000} )
	Aadd( aCpFs , {"QTDM2"    ,"N",014,002} )
	Aadd( aCpFs , {"TRANSAC"  ,"N",010,000} )
	Aadd( aCpFs , {"ESCOLHA"  ,"N",010,000} )
	Aadd( aCpFs , {"CODEMP"   ,"C",015,000} )
	Aadd( aCpFs , {"LOTEEMP"  ,"C",010,000} )
	Aadd( aCpFs , {"REGSD4"   ,"N",010,000} )
	Aadd( aCpFs , {"QTDECX"   ,"N",005,000} )
	zp_Tmp := CriaTrab( aCpFs, .T. )
	Use (zp_Tmp) Alias TH01 New Exclusive

	//                                                          Produção
	//      Data(3)+Produto(8)+LotePR(10)+NumOP(5)+CodEmp(14)+LotEmp(15)
	********************************************************************
	thIndx := "dtos(DTMOV)+PROD+LOTEPR+NUMOP+CODEMP+LOTEEMP"
	TH02 := CriaTrab(aCpFs, .T.)
	dbUseArea( .T.,, TH02, "TH02", .F., .F. )
	dbCreateInd(TH02, thIndx,{ || thIndx })

	//                                                      Cancelamento
	//      Data(3)+Produto(8)+LotePR(10)+NumOP(5)+CodEmp(14)+LotEmp(15)
	********************************************************************
	thIndx := "dtos(DTMOV)+PROD+LOTEPR+NUMOP+CODEMP+LOTEEMP"
	TH03 := CriaTrab(aCpFs, .T.)
	dbUseArea( .T.,, TH03, "TH03", .F., .F. )
	dbCreateInd(TH03, thIndx,{ || thIndx })

	Aadd( aCpAp , {"MVTO"     ,"C",003,000} )
	Aadd( aCpAp , {"DTMOV"    ,"D",008,000} )
	Aadd( aCpAp , {"PROD"     ,"C",015,000} )
	Aadd( aCpAp , {"LOTEPR"   ,"C",010,000} )
	Aadd( aCpAp , {"QTDM2"    ,"N",014,002} )
	apIndx := "MVTO+dtos(DTMOV)+PROD+LOTEPR"
	TH04 := CriaTrab(aCpAp, .T.)
	dbUseArea( .T.,, TH04, "TH04", .F., .F. )
	dbCreateInd(TH04, apIndx,{ || apIndx })

	fPerg := "BIA570"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)

		TH01->(dbCloseArea())
		Ferase(zp_Tmp+GetDBExtension())
		Ferase(zp_Tmp+OrdBagExt())

		TH02->(dbCloseArea())
		Ferase(TH02+GetDBExtension())
		Ferase(TH02+OrdBagExt())

		TH03->(dbCloseArea())
		Ferase(TH03+GetDBExtension())
		Ferase(TH03+OrdBagExt())

		TH04->(dbCloseArea())
		Ferase(TH04+GetDBExtension())
		Ferase(TH04+OrdBagExt())

		Return

	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado, pois está contido num período fechado","Data de Verada!!!")
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_YULMES") .or. MV_PAR02 <= GetMV("MV_YULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado, pois está contido num período em processo de fechamento.","Data de Fechamento!!!")
		Return
	EndIf

	yyDtIni := MV_PAR01
	yyDtFim := MV_PAR02

	//           Cria arquivo semafaro para controle de acessos simultâneos
	***********************************************************************
	df_ArqEtq := GetSrvProfString("Startpath","")+"BIA570_" +cEmpAnt+".txt"
	bbRetArq  := .F.

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight
	zx_Ambi := "2"
	xyEmpr  := cEmpAnt

	/*====================================================================+
	|            *******  CHAMA ROTINA DE IMPORTAÇÃO  *******             |
	+====================================================================*/
	Processa({||fGrvProd()})

	/*====================================================================+
	|            *******  ZERA TABELAS TEMPORÁRIAS    *******             |
	+====================================================================*/
	TH01->(dbCloseArea())
	Ferase(zp_Tmp+GetDBExtension())
	Ferase(zp_Tmp+OrdBagExt())

	TH02->(dbCloseArea())
	Ferase(TH02+GetDBExtension())
	Ferase(TH02+OrdBagExt())

	TH03->(dbCloseArea())
	Ferase(TH03+GetDBExtension())
	Ferase(TH03+OrdBagExt())

	TH04->(dbCloseArea())
	Ferase(TH04+GetDBExtension())
	Ferase(TH04+OrdBagExt())

	//         Libera arquivo semafaro para controle de acessos simultâneos
	***********************************************************************
	If File(df_ArqEtq) .and. bbRetArq
		FERASE(df_ArqEtq)
	EndIf

	If cj_Fecha
		ExecBlock("BIA570",.F.,.F.)
	EndIf

	// Temporariamente iremos verificar ao final do processamento da impor-
	//taçao da produção se algum produto ficou negativo.
	// Esta ação deverá perdurar até que consigamos resolver a questão do
	//saldo negativo de estoque.
	// Implementado em 01/11/19 por Marcos Alberto Soprani.
	***********************************************************************
	U_BIA772()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrvProd ¦ Autor ¦ Marcos Alberto S.     ¦ Data ¦ 13.04.12 ¦¦¦
¦¦¦----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Faz a Leitura dos Dados do Ecosis para Apontamento Automá- ¦¦¦
¦¦¦          ¦tico e efetua o apontamento                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGrvProd()

	If xyEmpr == "01"
		kt_BsDad := "DADOSEOS"
	ElseIf xyEmpr == "05"
		kt_BsDad := "DADOS_05_EOS"
	Else
		MsgINFO("Empresa não configurada para apontamento automático de Cerâmica!!!")
		Return
	EndIf

	fgRfDtAn := Substr(dtos(MV_PAR01),1,4)+"-"+Substr(dtos(MV_PAR01),5,2)+"-"+Substr(dtos(MV_PAR01),7,2)
	fgRfDtDp := Substr(dtos(MV_PAR02+1),1,4)+"-"+Substr(dtos(MV_PAR02+1),5,2)+"-"+Substr(dtos(MV_PAR02+1),7,2)

	fTratEtqCanc()

	AT005 := " SELECT A.CE_NUMERO_DOCTO ETIQUET,
	AT005 += "        A.ID_MOV_PROD IDECO,
	AT005 += "        A.COD_TRANSACAO TRANSAC,
	AT005 += "        A.COD_PRODUTO PRODUT,
	AT005 += "        A.CE_LOTE LOTEPR,
	AT005 += "        A.CE_QTDADE QUANT,
	AT005 += "        SUBSTRING(CONVERT(VARCHAR(10), B.ETIQ_DATA, 112), 1, 10) DTREF,
	AT005 += "        SUBSTRING(CONVERT(VARCHAR(16), B.ETIQ_DATA, 120), 12, 5) HRREF,
	AT005 += "        CASE
	AT005 += " 	        WHEN A.COD_TRANSACAO IN('1','20') AND A.CE_DOCTO <> 'SA' THEN A.CE_FORNO
	AT005 += " 	        ELSE (SELECT CE_FORNO
	AT005 += "                  FROM " + kt_BsDad + "..CEP_MOVIMENTO_PRODUTO TRANS_ORI
	AT005 += "                 WHERE TRANS_ORI.CE_NUMERO_DOCTO = A.CE_NUMERO_DOCTO
	AT005 += "                   AND cod_transacao IN('1','20') AND CE_DOCTO <> 'SA')
	AT005 += "        END ESCOLHA,
	AT005 += " 	      ISNULL(D.cod_produto, (SELECT M.cod_produto
	AT005 += "                                 FROM " + kt_BsDad + "..cep_etiqueta_processa_itens Z
	AT005 += "                                INNER JOIN " + kt_BsDad + "..cep_etiqueta_processa M ON M.id_bordero = Z.id_bordero
	AT005 += "                                WHERE cod_etiqueta = B.etiq_original )) CODEMP,
	AT005 += "        ISNULL(D.brd_lote, (SELECT M.brd_lote
	AT005 += "                              FROM " + kt_BsDad + "..cep_etiqueta_processa_itens Z
	AT005 += "                             INNER JOIN " + kt_BsDad + "..cep_etiqueta_processa M ON M.id_bordero = Z.id_bordero
	AT005 += "                             WHERE cod_etiqueta = B.etiq_original )) LOTEEMP,
	AT005 += "        B.etiq_qtde_cx QTDECX
	AT005 += "   FROM " + kt_BsDad + "..CEP_MOVIMENTO_PRODUTO A
	AT005 += "  INNER JOIN " + kt_BsDad + "..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA
	AT005 += "                                        AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO
	AT005 += "   LEFT JOIN " + kt_BsDad + "..cep_etiqueta_processa_itens C ON C.cod_etiqueta = A.ce_numero_docto
	AT005 += "                                                    AND C.bri_modo = 'P'
	AT005 += "   LEFT JOIN " + kt_BsDad + "..cep_etiqueta_processa D ON D.id_bordero = C.id_bordero
	AT005 += "  WHERE A.ID_CIA = 1
	AT005 += "    AND ( ( A.COD_TRANSACAO IN('1','20') AND A.CE_DOCTO <> 'SA' ) OR ( A.COD_TRANSACAO = 64 AND A.CE_DOCTO = 'CP' ) )
	AT005 += "    AND B.ETIQ_TRANSITO_PRODUCAO = 0
	AT005 += "    AND A.CE_LOTE <> ' '
	AT005 += "    AND B.COD_ENDERECO NOT IN ( 'RETIDO' )
	AT005 += "    AND CONVERT(SMALLDATETIME, A.CE_DATA_MOVIMENTO, 120) >= CONVERT(SMALLDATETIME, CONVERT(VARCHAR(10), GETDATE()-45, 112)+' 06:00', 120)
	AT005 += "    AND CONVERT(SMALLDATETIME, A.CE_DATA_MOVIMENTO, 120) >= CONVERT(SMALLDATETIME, '20150101 06:00', 120)
	AT005 += "    AND ID_MOV_PROD NOT IN (SELECT D3_YIDECO
	AT005 += "                              FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	AT005 += "                             WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'
	AT005 += "                               AND SD3.D3_YIDECO <> ' '
	AT005 += "                               AND SD3.D3_YORIMOV = 'PR0'
	AT005 += "                               AND SD3.D3_ESTORNO = ' '
	AT005 += "                               AND SD3.D_E_L_E_T_ = ' '
	AT005 += "                             UNION ALL
	AT005 += "                            SELECT Z18_IDECO
	AT005 += "                              FROM " + RetSqlName("Z18") + " Z18 WITH (NOLOCK)
	AT005 += "                             WHERE Z18.Z18_FILIAL = '" + xFilial("Z18") + "'
	AT005 += "                               AND Z18.D_E_L_E_T_ = ' ')
	AT005 += "    AND A.CE_LOTE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'
	AT005 += "    AND B.ETIQ_DATA BETWEEN '" + fgRfDtAn + " 06:00:00' AND '" + fgRfDtDp + " 05:59:00'
	AT005 += "    AND A.COD_PRODUTO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'
	AT005 += "    AND A.CE_QTDADE > 0
	AT005 += "  ORDER BY B.ETIQ_DATA, A.ID_MOV_PROD
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,AT005),'XX05',.T.,.T.)
	aStruX := ("XX05")->(dbStruct())
	gh_IndX := "DTREF"
	If !chkfile("AT05")
		xsTrpm := {}
		aadd(xsTrpm, {"ETIQUET"    ,"N", 15, 2})
		aadd(xsTrpm, {"IDECO"      ,"N", 15, 0})
		aadd(xsTrpm, {"TRANSAC"    ,"N", 15, 8})
		aadd(xsTrpm, {"PRODUT"     ,"C", 10, 0})
		aadd(xsTrpm, {"LOTEPR"     ,"C", 10, 0})
		aadd(xsTrpm, {"QUANT"      ,"N", 15, 8})
		aadd(xsTrpm, {"DTREF"      ,"C", 10, 0})
		aadd(xsTrpm, {"HRREF"      ,"C", 05, 0})
		aadd(xsTrpm, {"ESCOLHA"    ,"N", 15, 8})
		Aadd(xsTrpm, {"CODEMP"     ,"C", 15, 0})
		Aadd(xsTrpm, {"LOTEEMP"    ,"C", 10, 0})
		Aadd(xsTrpm, {"REGSD4"     ,"N", 10, 0})
		Aadd(xsTrpm, {"QTDECX"     ,"N", 05, 0})
		AT05 := CriaTrab(xsTrpm, .T.)
		dbUseArea( .T.,, AT05, "AT05", .F., .F. )
		dbCreateInd(AT05, gh_IndX,{ || gh_IndX })
	EndIf

	APPEND FROM ("XX05")
	If Select("XX05") > 0
		XX05->(dbCloseArea())
		Ferase(cIndex+GetDBExtension())
		Ferase(cIndex+OrdBagExt())
	Endif

	dbSelectArea("AT05")
	dbGoTop()
	If zx_Ambi <> "1"
		ProcRegua(RecCount())
	EndIf
	While !Eof()

		If zx_Ambi <> "1"
			IncProc("Extraindo dados do ECOSIS!!!")
		EndIf

		xf_NumOP  := Space(6)
		xf_CodEmp := Space(15)
		xf_LotEmp := Space(10)
		xf_RegSd4 := 0

		//                                      TRATAMENTO PARA NUMERO DA OP
		********************************************************************
		MS004 := " SELECT C2_NUM+C2_ITEM+C2_SEQUEN NUMOP,
		MS004 += "        D4_COD,
		MS004 += "        D4_LOTECTL,
		MS004 += "        SD4.R_E_C_N_O_ REGSD4
		MS004 += "   FROM " + RetSqlName("SC2") + " SC2 WITH (NOLOCK)
		MS004 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
		MS004 += "                       AND B1_COD = C2_PRODUTO
		MS004 += "                       AND B1_YSTATUS = '1'
		MS004 += "                       AND SB1.D_E_L_E_T_ = ' '
		MS004 += "   LEFT JOIN " + RetSqlName("SD4") + " SD4 WITH (NOLOCK) ON D4_FILIAL = '"+xFilial("SD4")+"'
		MS004 += "                       AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN+'  '
		MS004 += "                       AND (SELECT COUNT(*)
		MS004 += "                              FROM " + RetSqlName("SB1") + " WITH (NOLOCK)
		MS004 += "                             WHERE B1_FILIAL = '"+xFilial("SB1")+"'
		MS004 += "                               AND B1_COD = D4_COD
		MS004 += "                               AND B1_TIPO IN('PS','PA')
		MS004 += "                               AND D_E_L_E_T_ = ' ') > 0
		MS004 += "                       AND SD4.D_E_L_E_T_ = ' '
		MS004 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
		MS004 += "    AND C2_PRODUTO = '"+AT05->PRODUT+"'
		MS004 += "    AND C2_DATRF = '        '
		MS004 += "    AND C2_YDTFIRM <> '        '
		MS004 += "    AND SC2.D_E_L_E_T_ = ' '
		MS004 += "    ORDER BY C2_YDTFIRM DESC
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.T.,.T.)
		dbSelectArea("MS04")
		dbGoTop()
		xf_NumOP  := MS04->NUMOP
		xf_CodEmp := MS04->D4_COD
		xf_LotEmp := MS04->D4_LOTECTL
		xf_RegSd4 := MS04->REGSD4
		MS04->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())
		//                               FIM DO TRATAMENTO PARA NUMERO DA OP
		********************************************************************

		//                  Tratamento para fechamento de turno que acontece
		//                                       às 06:00 do dia subsequente
		********************************************************************
		xf_dtEmis := stod(Alltrim(AT05->DTREF))
		If Alltrim(AT05->HRREF) < "06:00"
			xf_dtEmis -= 1
		EndIf
		xf_QtdPr := AT05->QUANT

		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2") + xf_NumOP))

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))
		xb_DPaOp := SB1->B1_DESC

		//                    Produto sem controle de LOCALIZAÇÃO cadastrado
		********************************************************************
		skChkLocaliz := Posicione("SBZ", 1, xFilial("SBZ") + SC2->C2_PRODUTO, "BZ_LOCALIZ" )
		If skChkLocaliz <> "S"
			xf_NumOP := "Err:_LOCALIZ"
		EndIf

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + AT05->PRODUT))
		xb_DEcos := SB1->B1_DESC

		mdpRet := .F.
		If Substr(Alltrim(AT05->PRODUT),1,2) $ "B9/BO/C6"
			mdpRet := .T.
		EndIf
		If SB1->B1_YTPPROD == 'RP'
			mdpRet := .T.
		EndIf

		dbSelectArea("TH01")
		RecLock("TH01",.T.)
		TH01->ETIQUET := AT05->ETIQUET
		TH01->SEQUENC := AT05->IDECO
		TH01->DTMOV   := xf_dtEmis
		TH01->HORA    := AT05->HRREF
		TH01->NUMOP   := xf_NumOP
		TH01->D3COD   := IIF(!Empty(xf_NumOP), SC2->C2_PRODUTO          , "")
		TH01->DESCRIC := IIF(!Empty(xf_NumOP), Substr(xb_DPaOp,1,45)    , "")
		TH01->PROD    := AT05->PRODUT
		TH01->REFER   := xb_DEcos
		TH01->LOTEPR  := AT05->LOTEPR
		TH01->QTDM2   := xf_QtdPr
		TH01->TRANSAC := AT05->TRANSAC
		TH01->ESCOLHA := AT05->ESCOLHA
		TH01->CODEMP  := IIF(Empty(AT05->CODEMP), xf_CodEmp, AT05->CODEMP)
		TH01->LOTEEMP := IIF(mdpRet, IIF(Empty(AT05->LOTEEMP), xf_LotEmp, AT05->LOTEEMP), "")   //xf_LotEmp // Retirado de uso em 25/01/16 Por Marcos Alberto Soprani conforme OS 0254-16
		TH01->REGSD4  := xf_RegSd4
		TH01->QTDECX  := AT05->QTDECX
		MsUnLock()

		dbSelectArea("AT05")
		dbSkip()
	End

	AT05->(dbCloseArea())
	Ferase(AT05+GetDBExtension())
	Ferase(AT05+OrdBagExt())

	Define FONT oFont   NAME "Arial"          SIZE 0,22 BOLD

	DEFINE MSDIALOG oDlg292 TITLE "Lista de Registro do Ecosis" FROM nLin*.000, nCol*.000  TO nLin*.850, nCol*.900 COLORS 0, 16777215 PIXEL

	@ nLin*.004, nCol*.005 GROUP oGroup1 TO nLin*.395, nCol*.447 OF oDlg292 COLOR 0, 16777215 PIXEL

	fNGDd1Ap()

	oSayA1 := tSay():New( nLin*.405, nCol*.050 ,{||         },oDlg292,,oFont,,,,.T.,,,270,20)
	oSayA1:SetText( "Etiquetas: " + Transform(nxEtqt, "99999") )

	@ nLin*.400, nCol*.198 BUTTON oButton3 PROMPT "Libera Semaforo"     SIZE nLin*.080, nCol*.010 OF oDlg292 ACTION Processa({|| ghLiberaSem() }) PIXEL
	@ nLin*.400, nCol*.240 BUTTON oButton3 PROMPT "Empenho x Estoque"   SIZE nLin*.080, nCol*.010 OF oDlg292 ACTION Processa({|| ghEmpEst(1) }) PIXEL
	@ nLin*.400, nCol*.282 BUTTON oButton3 PROMPT "Emp. x Est. Novo"    SIZE nLin*.080, nCol*.010 OF oDlg292 ACTION Processa({|| U_BIAFG020() }) PIXEL
	@ nLin*.400, nCol*.324 BUTTON oButton3 PROMPT "Excel"               SIZE nLin*.040, nCol*.010 OF oDlg292 ACTION Processa({|| gxGrExPr() }) PIXEL
	@ nLin*.400, nCol*.366 BUTTON oButton2 PROMPT "Apontar"             SIZE nLin*.040, nCol*.010 OF oDlg292 ACTION Processa({|| gxApAtPr( oNGDd1Ap:ACOLS ) }) PIXEL
	@ nLin*.400, nCol*.408 BUTTON oButton1 PROMPT "Fechar"              SIZE nLin*.040, nCol*.010 OF oDlg292 ACTION (cj_Fecha := .F., fh_Esc := .T., oDlg292:End()) PIXEL

	ACTIVATE MSDIALOG oDlg292 CENTERED VALID fh_Esc

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fNGDd1Ap ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 13.04.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fNGDd1Ap()

	Local nX
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"STATUS","ETIQUET","SEQUENC","DTMOV","HORA","NUMOP","D3COD","DESCRIC","PROD","REFER","LOTEPR","QTDM2","TRANSAC","ESCOLHA","CODEMP","LOTEEMP","REGSD4","QTDECX"}
	Local aAlterFields := {"NUMOP","D3COD","CODEMP","LOTEEMP"}

	dbSelectArea("SX3")
	dbSetOrder(2)
	Aadd(aHeaderEx,{" "			     ,"CSTATUS"  ,"@BMP"             , 2        ,0         , ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(aHeaderEx,{"NumEtiq"        ,"ETIQUET"  ,"9999999999"       ,10        ,0         ,,x3_usado,"N"    ,         ,          })
	aAdd(aHeaderEx,{"IdEco"          ,"SEQUENC"  ,"9999999999"       ,10        ,0         ,,x3_usado,"N"    ,         ,          })
	dbSeek("D3_EMISSAO")
	aAdd(aHeaderEx,{"DtMov"          ,"DTMOV"    ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("H6_HORA")
	aAdd(aHeaderEx,{"Hora"           ,"HORA"     ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_OP")
	aAdd(aHeaderEx,{"NumOP"          ,"NUMOP"    ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,x3_f3    ,x3_context})
	dbSeek("D3_COD")
	aAdd(aHeaderEx,{"Produto"        ,"D3COD"    ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,x3_f3    ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeaderEx,{"Descrição"      ,"DESCRIC"  ,x3_picture         ,35        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_COD")
	aAdd(aHeaderEx,{"Ecosis"         ,"PROD"     ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeaderEx,{"Ref"            ,"REFER"    ,x3_picture         ,20        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_LOTECTL")
	aAdd(aHeaderEx,{"LoteProd"       ,"LOTEPR"   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_QUANT")
	aAdd(aHeaderEx,{"QtdM2"          ,"QTDM2"    ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	aAdd(aHeaderEx,{"Transação"      ,"TRANSAC"  ,"9999999999"       ,10        ,0         ,,x3_usado,"N"    ,         ,          })
	aAdd(aHeaderEx,{"Escolha"        ,"ESCOLHA"  ,"9999999999"       ,10        ,0         ,,x3_usado,"N"    ,         ,          })
	dbSeek("D4_COD")
	aAdd(aHeaderEx,{"CodEmp"         ,"CODEMP"   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,x3_f3    ,x3_context})
	dbSeek("D4_LOTECTL")
	aAdd(aHeaderEx,{"LoteEmp"        ,"LOTEEMP"  ,x3_picture         ,x3_tamanho,x3_decimal,"",x3_usado,x3_tipo,x3_f3    ,x3_context})
	aAdd(aHeaderEx,{"RegSD4"         ,"REGSD4"   ,"9999999999"       ,10        ,0         ,,x3_usado,"N"    ,         ,          })
	aAdd(aHeaderEx,{"QtdeCX"         ,"QTDECX"   ,"99999"            ,05        ,0         ,,x3_usado,"N"    ,         ,          })

	dbSelectArea("TH01")
	dbGoTop()
	If zx_Ambi <> "1"
		ProcRegua(RecCount())
	EndIf
	While !Eof()

		If zx_Ambi <> "1"
			IncProc("Montando Grid de Dados!!!")
		EndIf

		nxEtqt ++

		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := "BR_VERDE"
		aColsEx[Len(aColsEx), 2] := TH01->ETIQUET
		aColsEx[Len(aColsEx), 3] := TH01->SEQUENC
		aColsEx[Len(aColsEx), 4] := TH01->DTMOV
		aColsEx[Len(aColsEx), 5] := TH01->HORA
		aColsEx[Len(aColsEx), 6] := TH01->NUMOP
		aColsEx[Len(aColsEx), 7] := TH01->D3COD
		aColsEx[Len(aColsEx), 8] := TH01->DESCRIC
		aColsEx[Len(aColsEx), 9] := TH01->PROD
		aColsEx[Len(aColsEx),10] := TH01->REFER
		aColsEx[Len(aColsEx),11] := TH01->LOTEPR
		aColsEx[Len(aColsEx),12] := TH01->QTDM2
		aColsEx[Len(aColsEx),13] := TH01->TRANSAC
		aColsEx[Len(aColsEx),14] := TH01->ESCOLHA
		aColsEx[Len(aColsEx),15] := TH01->CODEMP
		aColsEx[Len(aColsEx),16] := TH01->LOTEEMP
		aColsEx[Len(aColsEx),17] := TH01->REGSD4
		aColsEx[Len(aColsEx),18] := TH01->QTDECX
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.

		dbSelectArea("TH01")
		dbSkip()
	End

	If zx_Ambi <> "1"
		oNGDd1Ap := MsNewGetDados():New( nLin*.013, nCol*.010, nLin*.390, nCol*.441, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg292, aHeaderEx, aColsEx)
		oNGDd1Ap:oBrowse:bLDblClick	:=	{|| fDblClick()}
		Return
	Else
		Return( aColsEx )
	Endif

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gxApAtPr ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 13.04.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Apontamento Automático da Linha de Cerâmicas               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gxApAtPr( xRecbAcl )

	Local j
	Local sd

	_cLogTxt	   := ""

	//                             Cria arquivo semafaro para controle de acessos simultâneos
	*****************************************************************************************

	If GetMv("MV_YBLQRCM")
		MsgInfo("Rotina bloqueada para execução, pois o parâmetro do bloqueio para RCM está ativado!", "BIA570")
		Return
	EndIF	

	If File(df_ArqEtq)
		MsgALERT("Esta rotina já está em uso em outra estação de trabalho!!! Necessário aguardar.", "Atenção")
		Return
	Else
		nHandle   := FCREATE(df_ArqEtq, FC_NORMAL)
		FCLOSE(nHandle)
		bbRetArq  := .T.
	EndIf

	hhTmpINI      := TIME()

	//        Acumula os valores do vetor num ArqTmp para faciliar a tratativa de agrupamento
	*****************************************************************************************
	For sd := 1 To Len(xRecbAcl)
		If xRecbAcl[sd][1] == "BR_VERDE"
			If xRecbAcl[sd][13] == 1 .or. xRecbAcl[sd][13] == 20                  // Etiqueta BOA
				*********************************************************************************

				msRcnSD4 = xRecbAcl[sd][17]
				If Substr(xRecbAcl[sd][9],1,2) $ "B9/BO/C6"
					ZP001 := " SELECT SD4.R_E_C_N_O_ REGSD4 "
					ZP001 += "   FROM " + RetSqlName("SD4") + " SD4(NOLOCK)"
					ZP001 += "  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_COD = D4_COD "
					ZP001 += "                       AND B1_TIPO = 'PA' "
					ZP001 += "                       AND SB1.D_E_L_E_T_ = ' ' "
					ZP001 += "  WHERE D4_FILIAL = " + xFilial("SD4") + " "
					ZP001 += "    AND RTRIM(D4_OP) = '" + xRecbAcl[sd][6] + "' "
					ZP001 += "    AND SD4.D_E_L_E_T_ = ' ' "
					ZPcIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP001),'ZP01',.T.,.T.)
					dbSelectArea("ZP01")
					dbGoTop()
					msRcnSD4 := ZP01->REGSD4
					ZP01->(dbCloseArea())
					Ferase(ZPcIndex+GetDBExtension())
					Ferase(ZPcIndex+OrdBagExt())					
				Endif

				dbSelectArea("TH02")
				RecLock("TH02",.T.)
				TH02->ETIQUET := xRecbAcl[sd][2]
				TH02->SEQUENC := xRecbAcl[sd][3]
				TH02->DTMOV   := xRecbAcl[sd][4]
				TH02->HORA    := xRecbAcl[sd][5]
				TH02->NUMOP   := xRecbAcl[sd][6]
				TH02->D3COD   := xRecbAcl[sd][7]
				TH02->DESCRIC := xRecbAcl[sd][8]
				TH02->PROD    := xRecbAcl[sd][9]
				TH02->REFER   := xRecbAcl[sd][10]
				TH02->LOTEPR  := xRecbAcl[sd][11]
				TH02->QTDM2   := xRecbAcl[sd][12]
				TH02->TRANSAC := xRecbAcl[sd][13]
				TH02->ESCOLHA := xRecbAcl[sd][14]
				TH02->CODEMP  := xRecbAcl[sd][15]
				TH02->LOTEEMP := xRecbAcl[sd][16]
				TH02->REGSD4  := msRcnSD4
				TH02->QTDECX  := xRecbAcl[sd][18]
				MsUnLock()

			Else                                                            // Etiqueta Cancelada
				*********************************************************************************

				dbSelectArea("TH03")
				RecLock("TH03",.T.)
				TH03->ETIQUET := xRecbAcl[sd][2]
				TH03->SEQUENC := xRecbAcl[sd][3]
				TH03->DTMOV   := xRecbAcl[sd][4]
				TH03->HORA    := xRecbAcl[sd][5]
				TH03->NUMOP   := xRecbAcl[sd][6]
				TH03->D3COD   := xRecbAcl[sd][7]
				TH03->DESCRIC := xRecbAcl[sd][8]
				TH03->PROD    := xRecbAcl[sd][9]
				TH03->REFER   := xRecbAcl[sd][10]
				TH03->LOTEPR  := xRecbAcl[sd][11]
				TH03->QTDM2   := xRecbAcl[sd][12]
				TH03->TRANSAC := xRecbAcl[sd][13]
				TH03->ESCOLHA := xRecbAcl[sd][14]
				TH03->CODEMP  := xRecbAcl[sd][15]
				TH03->LOTEEMP := xRecbAcl[sd][16]
				TH03->REGSD4  := xRecbAcl[sd][17]
				TH03->QTDECX  := xRecbAcl[sd][18]
				MsUnLock()

			EndIf
		EndIf
	Next sd

	//                                                 Apontamento de Produção - Etiqueta BOA
	*****************************************************************************************
	dbSelectArea("TH02")
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		skDtProd := TH02->DTMOV
		skProdut := TH02->PROD
		skLotePR := TH02->LOTEPR
		skNumOPr := TH02->NUMOP
		skCompBx := TH02->CODEMP
		skLotEmp := TH02->LOTEEMP
		skQtdPrd := 0
		kQtddPallet := 0
		kQtddSupLat := 0

		skDocD3PP := ""
		skSeqD3PP := ""

		Begin Transaction
			mnApontOk := .F.

			dbSelectArea("TH02")
			While !Eof() .and. TH02->DTMOV == skDtProd .and. TH02->PROD == skProdut .and. TH02->LOTEPR == skLotePR .and. TH02->NUMOP == skNumOPr .and. TH02->CODEMP == skCompBx .and. TH02->LOTEEMP == skLotEmp

				nxEtqt --
				ObjectMethod(oSayA1,'SetText( "Etiquetas: " + Transform(nxEtqt, "99999") )')
				IncProc("Processando Etiqueta: " + Alltrim(Str(TH02->ETIQUET)) )

				dbSelectArea("Z18")
				RecLock("Z18",.T.)
				Z18->Z18_FILIAL := xFilial("Z18")
				Z18->Z18_IDECO  := TH02->SEQUENC
				Z18->Z18_COD    := TH02->PROD
				Z18->Z18_DATA   := TH02->DTMOV
				Z18->Z18_QUANT  := TH02->QTDM2
				Z18->Z18_NUMETQ := Alltrim(Str(TH02->ETIQUET))
				Z18->Z18_DOCSD3 := "XTEMPTRAN"
				Z18->Z18_NSQSD3 := "XTEMPT"
				Z18->Z18_DTCANC := Date()
				Z18->Z18_TM     := "PR0"
				MsUnLock()

				skQtdPrd += TH02->QTDM2
				kQtddPallet ++
				If TH02->QTDECX >= 6
					kQtddSupLat := kQtddSupLat + 2 
				EndIf

				hgjArea := GetArea()
				If TH02->REGSD4 <> 0
					dbSelectArea("SD4")
					dbGoTo(TH02->REGSD4)
					RecLock("SD4",.F.)
					SD4->D4_COD     := skCompBx
					SD4->D4_LOTECTL := skLotEmp
					SD4->D4_LOCAL   := "07"
					MsUnLock()
				EndIf
				RestArea(hgjArea)

				dbSelectArea("TH02")
				dbSkip()

			End

			If skQtdPrd > 0

				IncProc("Gravando em Bloco...")

				fmRetfc := .F.
				If Substr(Alltrim(skProdut),1,2) $ "B9/BO/C6"
					fmRetfc := .T.
				EndIf
				If Posicione("SB1", 1, xFilial("SB1") + skProdut, "B1_YTPPROD") == 'RP'
					fmRetfc := .T.
				EndIf

				//                                                                             PP
				*********************************************************************************
				gtNumOP_PA := skNumOPr
				srNumOP_PP := ""
				// backup da quantidade e do produto
				bkpProd    := skProdut
				bkpQtdPrd  := skQtdPrd
				If Substr(skProdut,1,2) $ "AU/BE/BD/BF/BM/BP"

					TY004 := " SELECT DISTINCT G1_COMP, G1_QUANT
					TY004 += "   FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
					TY004 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
					TY004 += "                       AND B1_COD = G1_COMP
					TY004 += "                       AND B1_TIPO = 'PP'
					TY004 += "                       AND SB1.D_E_L_E_T_ = ' '
					TY004 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
					TY004 += "    AND G1_COD = '"+skProdut+"'
					TY004 += "    AND SG1.D_E_L_E_T_ = ' '
					TYcIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,TY004),'TY04',.T.,.T.)
					dbSelectArea("TY04")
					dbGoTop()
					skProdut := TY04->G1_COMP
					skQtdPrd := Round(skQtdPrd * TY04->G1_QUANT,2)
					TY04->(dbCloseArea())
					Ferase(TYcIndex+GetDBExtension())
					Ferase(TYcIndex+OrdBagExt())

				EndIf
				LK004 := " SELECT C2_NUM+C2_ITEM+C2_SEQUEN NUM_OP
				LK004 += "   FROM " + RetSqlName("SC2") + " WITH (NOLOCK)
				LK004 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
				LK004 += "    AND C2_NUM = '"+Substr(gtNumOP_PA,1,6)+"'
				LK004 += "    AND C2_ITEM = '"+Substr(gtNumOP_PA,7,2)+"'
				LK004 += "    AND C2_PRODUTO = SUBSTRING('"+skProdut+"',1,7)
				LK004 += "    AND D_E_L_E_T_ = ' '
				LKcIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,LK004),'LK04',.T.,.T.)
				dbSelectArea("LK04")
				dbGoTop()
				srNumOP_PP := LK04->NUM_OP
				LK04->(dbCloseArea())
				Ferase(LKcIndex+GetDBExtension())
				Ferase(LKcIndex+OrdBagExt())

				SC2->(dbSetOrder(1))
				If SC2->(dbSeek(xFilial("SC2") + srNumOP_PP)) .or. fmRetfc

					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))

					qs_VetM250 :={ {  "D3_TM"       , "010"                          ,NIL},;
					{                 "D3_COD"      , SC2->C2_PRODUTO                ,NIL},;
					{                 "D3_OP"       , srNumOP_PP                     ,NIL},;
					{                 "D3_QUANT"    , skQtdPrd                       ,NIL},;
					{                 "D3_LOCAL"    , SC2->C2_LOCAL                  ,NIL},;
					{                 "D3_EMISSAO"  , skDtProd                       ,NIL},;
					{                 "D3_UM"       , SB1->B1_UM                     ,NIL},;
					{                 "D3_CC"       , "3000"                         ,NIL},;
					{                 "D3_PARCTOT"  , "P"                            ,NIL},;
					{                 "D3_YORIMOV"  , "LNH"                          ,NIL},;
					{                 "D3_YAPLIC"   , "1"                            ,NIL},;					
					{                 "D3_YDIMPOR"  , Date()                         ,NIL} }

					lMsErroAuto := .F.
					lVerifEstNg := .F.
					lxPrdMaior  := .F.
					If !fmRetfc
						msExecAuto({|x,Y| Mata250(x,Y)}, qs_VetM250, 3)
					EndIf

					// Restaura backup do produto e da quantidade
					skProdut   := bkpProd
					skQtdPrd   := bkpQtdPrd

					If lMsErroAuto

						_aAutoErro := GetAutoGrlog()
						_cLogTxt   += "Apontamento(PP), Emissao: "+dtoc(skDtProd)+" Produto: " + skProdut + ", Lote: "+Alltrim(skLotePR)+", Qtde.: " + Transform(skQtdPrd,"@E 999,999,999.99") + CRLF
						_cLogTxt   += xConvLog(_aAutoErro) + CRLF + CRLF

						DisarmTransaction()                              // Controle de Transação
						*************************************************************************

					Else

						If !fmRetfc
							skDocD3PP := az_NmDoc
							skSeqD3PP := az_NmSeq
						EndIf

						//                                                                     PA
						*************************************************************************
						sk_RuaZZ := "ZZZZ"
						If "RET" $ Alltrim(skLotePR) .or. ( Right(Alltrim(skLotePR),1) == "R" .and. Substr(skProdut,1,2) == "AT" )
							sk_RuaZZ := "PAP"
						EndIf

						SC2->(dbSetOrder(1))
						If SC2->(dbSeek(xFilial("SC2") + gtNumOP_PA))

							SB1->(dbSetOrder(1))
							SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))

							//                                   Cadastrar o lote automaticamente
							*********************************************************************
							SB1->(dbSetOrder(1))
							SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))

							ZZ9->(dbSetOrder(2))
							If !ZZ9->(dbSeek(xFilial("ZZ9") + SC2->C2_PRODUTO + Padr(skLotePR,10) ))

								If ( ( Right(Alltrim(SC2->C2_PRODUTO),1) == "1" .and. !Substr(Padr(skLotePR,10),1,1) $ "B/D" ) .or. ( Right(Alltrim(SC2->C2_PRODUTO),1) == "2" .and. Substr(Padr(skLotePR,10),1,1) == "B" ) .or. ( Right(Alltrim(SC2->C2_PRODUTO),1) == "3" .and. Substr(Padr(skLotePR,10),1,1) == "D" ) ) 
									RecLock("ZZ9",.T.)
									ZZ9->ZZ9_FILIAL		:= xFilial("ZZ9")
									ZZ9->ZZ9_LOTE 		:= skLotePR
									ZZ9->ZZ9_PRODUT 	:= SC2->C2_PRODUTO
									ZZ9->ZZ9_PESO  		:= SB1->B1_PESO
									ZZ9->ZZ9_PECA  		:= SB1->B1_YPECA
									ZZ9->ZZ9_DIVPA 		:= SB1->B1_YDIVPA
									ZZ9->ZZ9_PESEMB 	:= SB1->B1_YPESEMB
									ZZ9->ZZ9_MSBLQL 	:= '2'
									If !Empty(Substr(skLotePR, 1, 1)) .and. Substr(skLotePR, 1, 1) < "A"
										ZZ9->ZZ9_RESTRI     := "*"
										If cEmpAnt == "05"
											ZZ9->ZZ9_OBS := "NAO ENVIAR PARA AMOSTRA, CONSTRUTORA E HOME CENTER"
										EndIf
									EndIf
									ZZ9->(MsUnlock())

								Else

									_cLogTxt   += "Lote (PA), Produto: " + skProdut + ", Lote: "+Alltrim(skLotePR)+", Qtde.: " + Transform(skQtdPrd,"@E 999,999,999.99") + CRLF + CRLF

									DisarmTransaction()                      // Controle de Transação
									*****************************************************************

								EndIf

							EndIf

							qs_VetM250 :={ {  "D3_TM"       , "010"                          ,NIL},;
							{                 "D3_COD"      , SC2->C2_PRODUTO                ,NIL},;
							{                 "D3_OP"       , gtNumOP_PA                     ,NIL},;
							{                 "D3_LOTECTL"  , skLotePR                       ,NIL},;
							{                 "D3_QUANT"    , skQtdPrd                       ,NIL},;
							{                 "D3_EMISSAO"  , skDtProd                       ,NIL},;
							{                 "D3_LOCAL"    , SC2->C2_LOCAL                  ,NIL},;
							{                 "D3_UM"       , SB1->B1_UM                     ,NIL},;
							{                 "D3_CC"       , "3000"                         ,NIL},;
							{                 "D3_PARCTOT"  , "P"                            ,NIL},;
							{                 "D3_YORIMOV"  , "PR0"                          ,NIL},;
							{                 "D3_YAPLIC"  , "1"                             ,NIL},;
							{                 "D3_YDIMPOR"  , Date()                         ,NIL} }
							lMsErroAuto := .F.
							lVerifEstNg := .F.
							lxPrdMaior  := .F.
							msExecAuto({|x,Y| Mata250(x,Y)}, qs_VetM250, 3)
							If lMsErroAuto

								_aAutoErro := GetAutoGrlog()
								_cLogTxt   += "Apontamento(PA), Emissao: "+dtoc(skDtProd)+" Produto: " + skProdut + ", Lote: "+Alltrim(skLotePR)+", Qtde.: " + Transform(skQtdPrd,"@E 999,999,999.99") + CRLF
								_cLogTxt   += xConvLog(_aAutoErro) + CRLF + CRLF

								DisarmTransaction()                      // Controle de Transação
								*****************************************************************

							Else

								mnApontOk := .T.

								//                                       Acumulador para Workflow
								*****************************************************************
								dbSelectArea("TH04")
								dbSetOrder(1)
								If !dbSeek("PR0" + dtos(skDtProd) + SC2->C2_PRODUTO + skLotePR)
									RecLock("TH04",.T.)
									TH04->MVTO   := "PR0"
									TH04->DTMOV  := skDtProd
									TH04->PROD   := SC2->C2_PRODUTO
									TH04->LOTEPR := skLotePR
								Else
									RecLock("TH04",.F.)
								EndIf
								TH04->QTDM2  +=skQtdPrd
								MsUnLock()

								//                                                           Fim
								*****************************************************************

							EndIf

						Else

							_cLogTxt   += "Apontamento(PA), Emissao: "+dtoc(skDtProd)+" Produto: " + skProdut + ", Lote: "+Alltrim(skLotePR)+", Qtde.: " + Transform(skQtdPrd,"@E 999,999,999.99") + CRLF
							_cLogTxt   += "OP de PA inexistente ou com problemas..." + CRLF + CRLF

							DisarmTransaction()                          // Controle de Transação
							*********************************************************************

						EndIf

					EndIf

				Else

					_cLogTxt   += "Apontamento(PP), Emissao: "+dtoc(skDtProd)+" Produto: " + skProdut + ", Lote: "+Alltrim(skLotePR)+", Qtde.: " + Transform(skQtdPrd,"@E 999,999,999.99") + CRLF
					_cLogTxt   += "OP de PP inexistente ou com problemas..." + CRLF + CRLF

					DisarmTransaction()                                  // Controle de Transação
					*****************************************************************************

				EndIf

			Else

				_cLogTxt   += "Apontamento(PP), Emissao: "+dtoc(skDtProd)+" Produto: " + skProdut + ", Lote: "+Alltrim(skLotePR)+", Qtde.: " + Transform(skQtdPrd,"@E 999,999,999.99") + CRLF
				_cLogTxt   += "Acumulador de quantidade igual a ZERO " + CRLF + CRLF

				DisarmTransaction()                                      // Controle de Transação
				*********************************************************************************

			EndIf

			If mnApontOk

				UP002 := " SELECT R_E_C_N_O_ REG
				UP002 += "   FROM "+RetSqlName("Z18")+" Z18 WITH (NOLOCK)
				UP002 += "  WHERE Z18_FILIAL = '"+xFilial("Z18")+"'
				UP002 += "    AND Z18_DOCSD3 = 'XTEMPTRAN'
				UP002 += "    AND Z18_NSQSD3 = 'XTEMPT'
				UP002 += "    AND D_E_L_E_T_ = ' '
				MscIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,UP002),'UP02',.F.,.T.)
				dbSelectArea("UP02")
				dbGoTop()
				While UP02->(!EOF())
					Z18->(DbGoTo(UP02->REG))
					Reclock("Z18",.F.)
					Z18->Z18_DOCSD3	:=	az_NmDoc
					Z18->Z18_NSQSD3	:=	az_NmSeq
					Z18->Z18_DCD3PP	:=	skDocD3PP
					Z18->Z18_SQD3PP	:=	skSeqD3PP
					Z18->(MsUnlock())						
					UP02->(DbSkip())
				EndDo
				UP02->(dbCloseArea())
				Ferase(MscIndex+GetDBExtension())     //arquivo de trabalho
				Ferase(MscIndex+OrdBagExt())          //indice gerado

			EndIf

		End Transaction                                              // Controle de Transação
		*************************************************************************************

		dbSelectArea("TH02")

	End

	//                                           Apontamento de Produção - Etiqueta Cancelada
	*****************************************************************************************
	dbSelectArea("TH03")
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		fmCtrlGrv := .T.
		fmPassou  := .F.

		ZH007 := " WITH Z18PP AS (SELECT '2' TIPO, Z18_DATA DTREFPP, Z18_DCD3PP DOCSD3PP, Z18_SQD3PP NSQSD3PP
		ZH007 += "                  FROM "+RetSqlName("Z18")+" WITH (NOLOCK)
		ZH007 += "                 WHERE Z18_FILIAL = '"+xFilial("Z18")+"'
		ZH007 += "                   AND Z18_NUMETQ = " + Alltrim(Str(TH03->ETIQUET))
		ZH007 += "                   AND Z18_TM = 'PR0'
		ZH007 += "                   AND D_E_L_E_T_ = ' ')
		ZH007 += "    , Z18PA AS (SELECT '1' TIPO, Z18_DATA DTREF, Z18_DOCSD3 DOCSD3, Z18_NSQSD3 NSQSD3
		ZH007 += "                  FROM "+RetSqlName("Z18")+" WITH (NOLOCK)
		ZH007 += "                 WHERE Z18_FILIAL = '"+xFilial("Z18")+"'
		ZH007 += "                   AND Z18_NUMETQ = " + Alltrim(Str(TH03->ETIQUET))
		ZH007 += "                   AND Z18_TM = 'PR0'
		ZH007 += "                   AND D_E_L_E_T_ = ' ')
		ZH007 += " SELECT *
		ZH007 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
		ZH007 += "  INNER JOIN Z18PP ON DOCSD3PP = D3_DOC
		ZH007 += "                  AND NSQSD3PP = D3_NUMSEQ
		ZH007 += "                  AND DTREFPP = D3_EMISSAO
		ZH007 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		ZH007 += "    AND SD3.D_E_L_E_T_ = ' '
		ZH007 += "  UNION ALL
		ZH007 += " SELECT *
		ZH007 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
		ZH007 += "  INNER JOIN Z18PA ON DOCSD3 = D3_DOC
		ZH007 += "                  AND NSQSD3 = D3_NUMSEQ
		ZH007 += "                  AND DTREF = D3_EMISSAO
		ZH007 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		ZH007 += "    AND SD3.D_E_L_E_T_ = ' '
		ZH007 += "  ORDER BY TIPO, SD3.D3_NUMSEQ, SD3.D3_TM, SD3.R_E_C_N_O_
		ZHcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZH007),'ZH07',.T.,.T.)

		Begin Transaction
			skDocPPy := ""
			skSeqPPy := ""
			skDocPAz := ""
			skSeqPAz := ""

			dbSelectArea("ZH07")
			dbGoTop()
			While !Eof() .and. fmCtrlGrv

				fmPassou  := .T.

				fmRecno := ZH07->D3_NUMSEQ
				fmPerct := TH03->QTDM2 / ZH07->D3_QUANT
				dbSelectArea("ZH07")
				While !Eof() .and. fmCtrlGrv .and. ZH07->D3_NUMSEQ == fmRecno

					fmOldTM := ZH07->D3_TM
					fmOldCC := ZH07->D3_CC
					fmOldCV := ZH07->D3_CLVL
					fmOldDT := ZH07->D3_EMISSAO
					skPrdsInd := ""
					_atotitem := {}
					dbSelectArea("ZH07")
					While !Eof() .and. fmCtrlGrv .and. ZH07->D3_NUMSEQ == fmRecno .and. ZH07->D3_TM == fmOldTM

						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+ZH07->D3_COD))
						fmTpOld := SB1->B1_TIPO
						gtRetGrpB1 := SB1->B1_GRUPO

						//                                                      Preenche os Itens
						*************************************************************************
						sk_RuaZZ := ""
						If ZH07->TIPO == "1"
							sk_RuaZZ := "ZZZZ"
							If "RET" $ Alltrim(ZH07->D3_LOTECTL) .or. ( Right(Alltrim(ZH07->D3_LOTECTL),1) == "R" .and. Substr(ZH07->D3_COD,1,2) == "AT" )
								sk_RuaZZ := "PAP"
							EndIf
						EndIf

						skLocal   := ZH07->D3_LOCAL
						If skLocal == "99"
							skLocal := "01"
							skPrdsInd += ZH07->D3_COD+","
						EndIf

						skQtde := ZH07->D3_QUANT * fmPerct
						If gtRetGrpB1 == "104B" .or.gtRetGrpB1 == "104C" 
							skQtde := Round(skQtde, 0)
							If skQtde == 0
								skQtde := 1
							EndIf
						EndIf

						_aItem := {}
						aAdd(_aItem,{"D3_COD"	  	,ZH07->D3_COD	        		,NIL})
						aAdd(_aItem,{"D3_UM"	  	,SB1->B1_UM		     			,NIL})
						aAdd(_aItem,{"D3_QUANT"  	,skQtde                 		,NIL})
						aAdd(_aItem,{"D3_LOCAL"  	,skLocal  	     	    		,NIL})
						aAdd(_aItem,{"D3_CONTA" 	,ZH07->D3_CONTA		     		,NIL})
						aAdd(_aItem,{"D3_USUARIO"	,cUserName						,NIL})
						aAdd(_aItem,{"D3_CC"		,ZH07->D3_CC    		    	,NIL})
						aAdd(_aItem,{"D3_CLVL"		,ZH07->D3_CLVL  				,NIL})
						aAdd(_aItem,{"D3_SEGUM"  	,SB1->B1_SEGUM		    		,NIL})
						aAdd(_aItem,{"D3_LOCALIZ"  	,sk_RuaZZ                 		,NIL})
						aAdd(_aItem,{"D3_YAPLIC"  	,"1"                     		,NIL})
						aAdd(_aItem,{"D3_LOTECTL"  	,ZH07->D3_LOTECTL       		,NIL})
						If fmOldTM <> "010"
							If Empty(skSeqPPy)
								aAdd(_aItem,{"D3_YRFCUST"  	,skSeqPAz       				,NIL})
							Else
								aAdd(_aItem,{"D3_YRFCUST"  	,skSeqPPy       				,NIL})
							EndIf
						EndIf

						aAdd(_atotitem,_aitem)

						dbSelectArea("ZH07")
						dbSkip()

					End

					If fmOldTM == "010"
						fmD3Tm := "711"
					ElseIf fmOldTM == "999"
						fmD3Tm := "211"
					EndIf

					If cEmpAnt == "05"
						fmDocD3 := GetSx8Num("SD3","D3_DOC")
					Else
						fmDocD3 := UPPER( NextNumero("SD3", 2, "D3_DOC", .T.) )
					EndIf
					//                                                         Preenche Cabecalho
					*****************************************************************************
					_aCab1 :=	{	{"D3_DOC"     ,fmDocD3                , NIL},;
					{                "D3_TM"      ,fmD3Tm                 , NIL},;
					{                "D3_CC"      ,fmOldCC                , NIL},;
					{                "D3_CLVL"    ,fmOldCV                , NIL},;
					{                "D3_EMISSAO" ,stod(fmOldDT)          , NIL}}

					lMsHelpAuto	:= .T.
					lMsErroAuto	:= .F.
					_ExecAutoII	:= .T.
					klCancCtrl  := .T.
					MSExecAuto({|x,y,z| MATA241(x,y,z)}, _aCab1, _atotitem)
					If lMsErroAuto

						_aAutoErro := GetAutoGrlog()
						_cLogTxt   += "Estorno(PA), Emissao: "+dtoc(TH03->DTMOV)+" Produto: " + TH03->PROD + ", Lote: "+Alltrim(TH03->LOTEPR)+", Qtde.: " + Transform(TH03->QTDM2,"@E 999,999,999.99") + CRLF
						_cLogTxt   += xConvLog(_aAutoErro) + CRLF + CRLF

						fmCtrlGrv := .F.

						DisarmTransaction()                              // Controle de Transação
						*************************************************************************

					Else

						If fmOldTM == "010"
							If fmTpOld == "PP"
								skDocPPy := SD3->D3_DOC
								skSeqPPy := SD3->D3_NUMSEQ
							ElseIf fmTpOld == "PA"
								skDocPAz := SD3->D3_DOC
								skSeqPAz := SD3->D3_NUMSEQ
							EndIf
						EndIf

						UK055 := "	SELECT SD3.R_E_C_N_O_ as REG "
						UK055 += "   FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
						UK055 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON B1_COD = D3_COD
						UK055 += "                       AND B1_APROPRI = 'I'
						UK055 += "                       AND SB1.D_E_L_E_T_ = ' '
						UK055 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "'
						UK055 += "    AND D3_DOC = '" + fmDocD3 + "'
						UK055 += "    AND D3_EMISSAO = '" + fmOldDT + "'
						UK055 += "    AND D3_TM = '211'
						UK055 += "    AND SD3.D_E_L_E_T_ = ' '
						MscIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,UK055),'UK055',.F.,.T.)
						dbSelectArea("UK055")
						dbGoTop()

						While UK055->(!EOF())
							SD3->(DbGoTo(UK055->REG))
							Reclock("SD3",.F.)
							SD3->D3_LOCAL := '99'
							SD3->(MsUnlock())						
							UK055->(DbSkip())
						EndDo

						UK055->(dbCloseArea())

						Ferase(MscIndex+GetDBExtension())     //arquivo de trabalho
						Ferase(MscIndex+OrdBagExt())          //indice gerado

					EndIf

					dbSelectArea("ZH07")

				End

				dbSelectArea("ZH07")

			End

			ZH07->(dbCloseArea())
			Ferase(ZHcIndex+GetDBExtension())
			Ferase(ZHcIndex+OrdBagExt())

		End Transaction

		If !fmPassou

			fmCtrlGrv := .F.

			_cLogTxt   += "Estorno(PA), Emissao: "+dtoc(TH03->DTMOV)+" Produto: " + TH03->PROD + ", Lote: "+Alltrim(TH03->LOTEPR)+", Qtde.: " + Transform(TH03->QTDM2,"@E 999,999,999.99") + CRLF
			_cLogTxt   += "NAO ENCONTRADO APONTAMENTO DE PRODUCAO PARA ESTE CANCELAMENTO." + CRLF + CRLF

		EndIf

		If fmCtrlGrv

			//                                       Acumulador para Workflow

			*****************************************************************
			dbSelectArea("TH04")
			dbSetOrder(1)
			If !dbSeek("EST" + dtos(TH03->DTMOV) + TH03->PROD + TH03->LOTEPR)
				RecLock("TH04",.T.)
				TH04->MVTO   := "EST"
				TH04->DTMOV  := TH03->DTMOV
				TH04->PROD   := TH03->PROD
				TH04->LOTEPR := TH03->LOTEPR
			Else
				RecLock("TH04",.F.)
			EndIf
			TH04->QTDM2  += TH03->QTDM2
			MsUnLock()

			dbSelectArea("Z18")
			RecLock("Z18",.T.)
			Z18->Z18_FILIAL := xFilial("Z18")
			Z18->Z18_IDECO  := TH03->SEQUENC
			Z18->Z18_COD    := TH03->PROD
			Z18->Z18_DATA   := TH03->DTMOV
			Z18->Z18_QUANT  := TH03->QTDM2
			Z18->Z18_NUMETQ := Alltrim(Str(TH03->ETIQUET))
			Z18->Z18_DOCSD3 := skDocPAz
			Z18->Z18_NSQSD3 := skSeqPAz
			Z18->Z18_DTCANC := Date()
			Z18->Z18_TM     := "EST"
			Z18->Z18_DCD3PP := skDocPPy
			Z18->Z18_SQD3PP := skSeqPPy
			MsUnLock()

		EndIf

		dbSelectArea("TH03")
		dbSkip()

	End

	hhTmpFIM      := TIME()

	Processa({|| wpEnvMai() })

	fh_Esc := .T.
	oDlg292:End()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ghLiberaSem ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 08.09.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Libera Semaforo                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ghLiberaSem()

	If U_VALOPER("018",.F.)

		xtArqEtq := GetSrvProfString("Startpath","")+"BIA570_" +cEmpAnt+ ".txt"

		If File(xtArqEtq)
			fErase(xtArqEtq)
		EndIf

	Else

		Aviso('OP 018 - Valid Operação','Você não possui acesso a esta rotina.' + CHR(13) + CHR(13) +' Favor recorrer ao responsável do setor !',{'Ok'})

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gxGrExPr ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 13.04.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Exporta os dados do Grid para o Excel                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gxGrExPr()

	xwDados7 := {}

	dbSelectArea("TH01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Preparando dados para Excel!!!")

		Aadd(xwDados7, { TH01->ETIQUET,;
		TH01->SEQUENC,;
		TH01->DTMOV,;
		TH01->HORA,;
		TH01->NUMOP,;
		TH01->D3COD,;
		TH01->DESCRIC,;
		TH01->PROD,;
		TH01->REFER,;
		TH01->LOTEPR,;
		Transform(TH01->QTDM2,     "@E 999,999,999.99"),;
		TH01->TRANSAC,;
		TH01->ESCOLHA,;
		TH01->CODEMP,;
		TH01->LOTEEMP,;
		TH01->REGSD4,;
		TH01->QTDECX} )

		dbSelectArea("TH01")
		dbSkip()

	End

	U_BIAxExcel(xwDados7, aCpFs, "BIA570"+strzero(seconds()%3500,5) )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ghEmpEst ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 01.10.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Efetua verificação de Empenho versus Saldo em Estoque      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ghEmpEst(xOrigPrc)

	Local xRetEstNeg := .F.

	xzDados1 := {}

	fCampos := {}
	AADD(fCampos,{"DATPRD"    , "D", 08, 0})
	AADD(fCampos,{"NUMOP"     , "C", 13, 0})
	AADD(fCampos,{"PPNUMOP"   , "C", 13, 0})
	AADD(fCampos,{"QUANT"     , "N", 14, 2})
	cArqTrab := CriaTrab(fCampos, .T.)
	dbUseArea(.T.,,cArqTrab,"TMP1")
	dbCreateInd(cArqTrab,"DTOS(DATPRD)+NUMOP",{|| DTOS(DATPRD)+NUMOP })

	dbSelectArea("TH01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Preparando base (1)!!!")

		fgNova := .F.
		dbSelectarea("TMP1")
		If !dbSeek(dtos(TH01->DTMOV)+TH01->NUMOP)
			fgNova := .T.
			RecLock("TMP1",.T.)
			TMP1->DATPRD := TH01->DTMOV
			TMP1->NUMOP  := TH01->NUMOP
		Else
			RecLock("TMP1",.F.)
		EndIf
		TMP1->QUANT +=TH01->QTDM2
		MsUnLock()

		If fgNova                                                   // Tratamento para PP
			*****************************************************************************

			// Em 08/03/17... Por Marcos Alberto Soprani, conforme OS effettivo 0879-17
			mdpRet := .F.
			If Substr(Alltrim(TH01->PROD),1,2) $ "B9/BO/C6"
				mdpRet := .T.
			EndIf
			If Posicione("SB1", 1, xFilial("SB1") + TH01->PROD, "B1_YTPPROD") == 'RP'
				mdpRet := .T.
			EndIf

			srNumOP_PP := ""
			If ( !(TH01->ESCOLHA == 3 .or. TH01->ESCOLHA == 4) .or. 1 == 1 ) .and. !mdpRet

				LK004 := " SELECT C2_NUM+C2_ITEM+C2_SEQUEN NUM_OP
				LK004 += "   FROM " + RetSqlName("SC2") + " WITH (NOLOCK) "
				LK004 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
				LK004 += "    AND C2_NUM = '"+Substr(TH01->NUMOP,1,6)+"'
				LK004 += "    AND C2_ITEM = '"+Substr(TH01->NUMOP,7,2)+"'
				LK004 += "    AND C2_PRODUTO = SUBSTRING('"+TH01->PROD+"',1,7)
				LK004 += "    AND D_E_L_E_T_ = ' '
				LKcIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,LK004),'LK04',.T.,.T.)
				dbSelectArea("LK04")
				dbGoTop()
				srNumOP_PP := LK04->NUM_OP
				LK04->(dbCloseArea())
				Ferase(LKcIndex+GetDBExtension())
				Ferase(LKcIndex+OrdBagExt())

				dbSelectarea("TMP1")
				If dbSeek(dtos(TH01->DTMOV)+TH01->NUMOP)
					RecLock("TMP1",.F.)
					TMP1->PPNUMOP  := srNumOP_PP
					MsUnLock()
				EndIf

			EndIf

		EndIf

		dbSelectArea("TH01")
		dbSkip()

	End

	dbSelectArea("TMP1")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		dbSelectArea("TMP1")
		dbSkip()

	End

	dbSelectArea("TMP1")
	dbGoTop()
	While !Eof()

		IncProc("Preparando base (2)!!!")

		YK001 := " SELECT ' ' DATPRD,
		YK001 += "        ' ' PRODUTO,
		YK001 += "        ' ' DESCR_PA,
		YK001 += "        D4_OP,
		YK001 += "        (SELECT C2_QUANT
		YK001 += "           FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK)
		YK001 += "          WHERE C2_FILIAL = '"+xFilial("SC2")+"'
		YK001 += "            AND C2_NUM+C2_ITEM+C2_SEQUEN+'  ' = D4_OP
		YK001 += "            AND SC2.D_E_L_E_T_ = ' ') QTD_OP,
		YK001 += "        "+Alltrim(Str(TMP1->QUANT))+" M2BX,
		YK001 += "        D4_COD,
		YK001 += "        SUBSTRING(B1_DESC,1,50) DESCR,
		YK001 += "        B1_UM,
		YK001 += "        D4_LOCAL,
		YK001 += "		  0 CAMADA,
		YK001 += "        D4_QTDEORI,
		YK001 += "        0 SAL_ANT,
		YK001 += "        ISNULL((SELECT SUM(D3_QUANT)
		YK001 += "              FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
		YK001 += "             WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		YK001 += "               AND D3_COD = B1_COD
		YK001 += "               AND D3_EMISSAO = '"+dtos(TMP1->DATPRD)+"'
		YK001 += "               AND D3_TM <= '500'
		YK001 += "               AND D3_LOCAL = D4_LOCAL
		YK001 += "               AND D3_ESTORNO <> 'S'
		YK001 += "               AND SD3.D_E_L_E_T_ = ' '),
		YK001 += "            0) MI_ENT,
		YK001 += "        ISNULL((SELECT SUM(D3_QUANT)
		YK001 += "              FROM "+RetSqlName("SD3")+" SD3 WITH(NOLOCK)
		YK001 += "             WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		YK001 += "               AND D3_COD = B1_COD
		YK001 += "               AND D3_EMISSAO = '"+dtos(TMP1->DATPRD)+"'
		YK001 += "               AND D3_TM > '500'
		YK001 += "               AND D3_LOCAL = D4_LOCAL
		YK001 += "               AND D3_ESTORNO <> 'S'
		YK001 += "               AND SD3.D_E_L_E_T_ = ' '),
		YK001 += "            0) MI_SAI,
		YK001 += "        ISNULL((SELECT SUM(D1_QUANT)
		YK001 += "              FROM "+RetSqlName("SD1")+" SD1 WITH(NOLOCK)
		YK001 += "             INNER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'
		YK001 += "                                  AND F4_CODIGO = D1_TES
		YK001 += "                                  AND F4_ESTOQUE = 'S'
		YK001 += "                                  AND SF4.D_E_L_E_T_ = ' '
		YK001 += "             WHERE D1_FILIAL = '"+xFilial("SD1")+"'
		YK001 += "               AND D1_COD = B1_COD
		YK001 += "               AND D1_DTDIGIT = '"+dtos(TMP1->DATPRD)+"'
		YK001 += "               AND D1_LOCAL = D4_LOCAL
		YK001 += "               AND SD1.D_E_L_E_T_ = ' '),
		YK001 += "            0) NF_ENT,
		YK001 += "        ISNULL((SELECT SUM(D2_QUANT)
		YK001 += "              FROM "+RetSqlName("SD2")+" SD2 WITH(NOLOCK)
		YK001 += "             INNER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'
		YK001 += "                                  AND F4_CODIGO = D2_TES
		YK001 += "                                  AND F4_ESTOQUE = 'S'
		YK001 += "                                  AND SF4.D_E_L_E_T_ = ' '
		YK001 += "             WHERE D2_FILIAL = '"+xFilial("SD2")+"'
		YK001 += "               AND D2_COD = B1_COD
		YK001 += "               AND D2_EMISSAO = '"+dtos(TMP1->DATPRD)+"'
		YK001 += "               AND D2_LOCAL = D4_LOCAL
		YK001 += "               AND SD2.D_E_L_E_T_ = ' '),
		YK001 += "            0) NF_SAI,
		YK001 += "        0 QTD_BAIXA,
		YK001 += "        0 DISPONVEL,
		YK001 += "        (SELECT B2_QATU
		YK001 += "           FROM "+RetSqlName("SB2")+" SB2 WITH(NOLOCK)
		YK001 += "          WHERE B2_FILIAL = '"+xFilial("SB2")+"'
		YK001 += "            AND B2_COD = D4_COD
		YK001 += "            AND B2_LOCAL = D4_LOCAL
		YK001 += "            AND SB2.D_E_L_E_T_ = ' ') QATU,
		YK001 += "        (SELECT C2_QUANT
		YK001 += "           FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK)
		YK001 += "          WHERE C2_FILIAL = '"+xFilial("SC2")+"'
		YK001 += "            AND C2_NUM + C2_ITEM = SUBSTRING(D4_OP,1,8)
		YK001 += "            AND C2_SEQUEN = '001'
		YK001 += "            AND SC2.D_E_L_E_T_ = ' ') QTD_MAE
		YK001 += "   FROM "+RetSqlName("SD4")+" SD4 WITH(NOLOCK)
		YK001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
		YK001 += "                       AND B1_COD = D4_COD
		YK001 += "                       AND SB1.D_E_L_E_T_ = ' '
		YK001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
		YK001 += "    AND D4_OP IN('"+TMP1->NUMOP+"','"+TMP1->PPNUMOP+"')
		YK001 += "    AND SD4.D_E_L_E_T_ = ' '
		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,YK001),'YK01',.T.,.T.)
		aStruX1 := ("YK01")->(dbStruct())
		dbSelectArea("YK01")
		dbGoTop()
		While !Eof()

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + YK01->D4_COD ))
			s_B1TpIn := SB1->B1_TIPO
			s_B1GrIn := SB1->B1_GRUPO

			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2") + YK01->D4_OP ))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO ))
			s_B1TpPr := SB1->B1_TIPO

			aSaldos := CalcEst(YK01->D4_COD, YK01->D4_LOCAL, TMP1->DATPRD)
			EmpQuant := aSaldos[1]

			gQtdReq  := (YK01->M2BX * (YK01->QTD_OP/YK01->QTD_MAE)) / YK01->QTD_OP * YK01->D4_QTDEORI
			gSalDisp := EmpQuant + (YK01->MI_ENT+YK01->NF_ENT) - (YK01->MI_SAI+YK01->NF_SAI) - gQtdReq

			gM2BXAjt := YK01->M2BX * (YK01->QTD_OP/YK01->QTD_MAE)

			If s_B1TpPr $ "PA/PS/PP"

				If !(( s_B1TpIn == "MP" .and. s_B1GrIn $ "101 " ) )

					Aadd(xzDados1, { TMP1->DATPRD                        ,;
					SC2->C2_PRODUTO                                      ,;
					Substr(SB1->B1_DESC, 1, 50)                          ,;
					YK01->D4_OP                                          ,;
					Transform(YK01->QTD_OP,         "@E 999,999,999.99") ,;
					Transform(gM2BXAjt,             "@E 999,999,999.99") ,;
					YK01->D4_COD                                         ,;
					YK01->DESCR                                          ,;
					YK01->B1_UM                                          ,;
					YK01->D4_LOCAL                                       ,;
					Transform(gQtdReq/Iif(gQtdReq == 0, 0, gM2BXAjt), "@E 999.99999999"),;
					Transform(YK01->D4_QTDEORI,     "@E 999,999,999.99") ,;
					Transform(EmpQuant,             "@E 999,999,999.99") ,;
					Transform(YK01->MI_ENT,         "@E 999,999,999.99") ,;
					Transform(YK01->MI_SAI,         "@E 999,999,999.99") ,;
					Transform(YK01->NF_ENT,         "@E 999,999,999.99") ,;
					Transform(YK01->NF_SAI,         "@E 999,999,999.99") ,;
					Transform(gQtdReq,              "@E 999,999,999.99") ,;
					Transform(gSalDisp,             "@E 999,999,999.99") ,;
					Transform(YK01->QATU-gQtdReq,   "@E 999,999,999.99") ,;
					Transform(YK01->QTD_MAE,        "@E 999,999,999.99") })

					If EmpQuant < 0 .or. gSalDisp < 0
						xRetEstNeg := .T.
					EndIf
				EndIf

			EndIf

			dbSkip()

		End

		YK01->(dbCloseArea())
		Ferase(cIndex+OrdBagExt())

		dbSelectArea("TMP1")
		dbSkip()

	End

	TMP1->(dbCloseArea())
	Ferase(cArqTrab+GetDBExtension())
	Ferase(cArqTrab+OrdBagExt())

	If xOrigPrc == 1

		U_BIAxExcel(xzDados1, aStruX1, "BIA570"+strzero(seconds()%3500,5) )

	Else

		Return ( xRetEstNeg )

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xConvLog ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.04.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Converter log de Erro em texto simples                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xConvLog(aAutoErro)

	Local cRet := ""
	Local nX   := 1

	For nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX] + CRLF
	Next nX

Return cRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ wpEnvMai ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.04.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Monta Estrutra HTML para envio de E-mail                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function wpEnvMai()

	//==========================================================================+
	//  Apontamento realizado com sucesso...                                    |
	//==========================================================================+
	htHaveApont := .F.
	WF007 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> ' 
	WF007 += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	WF007 += ' <head> '
	WF007 += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	WF007 += ' <title>Untitled Document</title> '
	WF007 += ' <style type="text/css"> '
	WF007 += ' <!-- '
	WF007 += ' .style3 {color: #000000; } '
	WF007 += ' .style4 {color: #FFFFFF; } '
	WF007 += ' --> '
	WF007 += ' </style> '
	WF007 += ' </head> '
	WF007 += ' <body> '
	WF007 += ' <p>Log de Importação das etiquetas do sistema Ecosis para o sistema Protheus.</p> '
	WF007 += ' <p>Início do Processamento: '+hhTmpINI+'</p> '

	WF007 += ' <table width="1143" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000"> '
	WF007 += '   <tr> '
	WF007 += '     <th height="24" colspan="6" scope="col"><span class="style3">PRODUÇÃO</span></th> '
	WF007 += '   </tr> '
	WF007 += '   <tr> '
	WF007 += '     <th width="129" height="21" bgcolor="#0033FF" scope="col"><div align="center" class="style4">Data</div></th> '
	WF007 += '     <th width="157" bgcolor="#0033FF" scope="col"><div align="center" class="style4"> '
	WF007 += '       <div align="left">Produto</div> '
	WF007 += '     </div></th> '
	WF007 += '     <th width="430" bgcolor="#0033FF" scope="col"><div align="center" class="style4"> '
	WF007 += '       <div align="left">Descrição</div> '
	WF007 += '     </div></th> '
	WF007 += '     <th width="125" bgcolor="#0033FF" scope="col"><div align="center" class="style4">Lote</div></th> '
	WF007 += '     <th width="165" bgcolor="#0033FF" scope="col"><div align="right" class="style4"> '
	WF007 += '       <div align="right">Quantidade</div> '
	WF007 += '     </div></th> '
	WF007 += '     <th width="125" bgcolor="#0033FF" scope="col"><div align="center" class="style4"> '
	WF007 += '       <div align="left">Restrição</div> '
	WF007 += '     </div></th> '
	WF007 += '   </tr> '
	dbSelectArea("TH04")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek("PR0")

		While !Eof() .and. TH04->MVTO == "PR0"

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+TH04->PROD))
			ZZ9->(dbSetOrder(2))
			ZZ9->(dbSeek(xFilial("ZZ9") + TH04->PROD + TH04->LOTEPR ))

			htHaveApont := .T.
			htRestrLot := "Não"
			If ZZ9->ZZ9_RESTRI == "*"
				htRestrLot := "Sim"
			ElseIf ZZ9->ZZ9_RESTRI == "#"
				htRestrLot := "# Empenho"
			EndIf

			WF007 += '   <tr> '
			WF007 += '     <td><div align="center">' + dtoc(TH04->DTMOV) + '</div></td> '
			WF007 += '     <td><div align="left">' + Alltrim(TH04->PROD) + '</div></td> '
			WF007 += '     <td><div align="left">' + Alltrim(Substr(SB1->B1_DESC,1,50)) + '</div></td> '
			WF007 += '     <td><div align="center">' + Alltrim(TH04->LOTEPR) + '</div></td> '
			WF007 += '     <td><div align="right">' + Transform(TH04->QTDM2, "@E 999,999,999.99") + '</div></td> '
			WF007 += '     <td><div align="left">' + htRestrLot + '</div></td> '
			WF007 += '   </tr> '

			dbSelectArea("TH04")
			dbSkip()

		End

	EndIf
	WF007 += ' </table> '
	WF007 += ' <p>&nbsp;</p> '

	WF007 += ' <p>Fim do Processamento: '+hhTmpFIM+'</p> '
	WF007 += ' <p>Tempo Total de processamento: '+Alltrim(ElapTime(hhTmpINI, hhTmpFIM))+'</p> '
	WF007 += ' <p>by BIA570</p> '
	WF007 += ' <p>&nbsp;</p> '
	WF007 += ' </body> '
	WF007 += ' </html> '

	df_Dest := U_EmailWF('BIA570IND', xyEmpr )
	df_Dest += U_EmailWF('BIA570COM', xyEmpr )
	df_Assu := IIF(xyEmpr == "05", "INCESA - ", "BIANCOGRES - ") + "Apontamento de Produção(ECOSIS vs PROTHEUS) Realizado com Sucesso"
	df_Erro := df_Assu + " não enviado. Favor verificar!!!"
	If htHaveApont
		U_BIAEnvMail(, df_Dest, df_Assu, WF007, df_Erro)
	EndIf

	//==========================================================================+
	// Problemas com o Apontamento que impedem de ser realizado como sucesso... |
	//==========================================================================+
	htHaveError := .F.
	WF007 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	WF007 += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	WF007 += ' <head> '
	WF007 += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	WF007 += ' <title>Untitled Document</title> '
	WF007 += ' <style type="text/css"> '
	WF007 += ' <!-- '
	WF007 += ' .style3 {color: #000000; } '
	WF007 += ' .style4 {color: #FFFFFF; } '
	WF007 += ' --> '
	WF007 += ' </style> '
	WF007 += ' </head> '
	WF007 += ' <body> '
	WF007 += ' <p>Log de Importação das etiquetas do sistema Ecosis para o sistema Protheus.</p> '
	WF007 += ' <p>Início do Processamento: '+hhTmpINI+'</p> '

	WF007 += ' <table width="1143" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000"> '
	WF007 += '   <tr> '
	WF007 += '     <th height="25" colspan="6" scope="col"><span class="style3">ESTORNO</span></th> '
	WF007 += '   </tr> '
	WF007 += '   <tr> '
	WF007 += '     <th width="129" height="21" bgcolor="#0033FF" scope="col"><div align="center" class="style4">Data</div></th> '
	WF007 += '     <th width="157" bgcolor="#0033FF" scope="col"><div align="center" class="style4"> '
	WF007 += '       <div align="left">Produto</div> '
	WF007 += '     </div></th> '
	WF007 += '     <th width="430" bgcolor="#0033FF" scope="col"><div align="center" class="style4"> '
	WF007 += '       <div align="left">Descrição</div> '
	WF007 += '     </div></th> '
	WF007 += '     <th width="125" bgcolor="#0033FF" scope="col"><div align="center" class="style4">Lote</div></th> '
	WF007 += '     <th width="165" bgcolor="#0033FF" scope="col"><div align="right" class="style4"> '
	WF007 += '       <div align="right">Quantidade</div> '
	WF007 += '     </div></th> '
	WF007 += '     <th width="125" bgcolor="#0033FF" scope="col"><div align="center" class="style4"> '
	WF007 += '       <div align="left">Restrição</div> '
	WF007 += '     </div></th> '
	WF007 += '   </tr> '
	dbSelectArea("TH04")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek("EST")

		While !Eof() .and. TH04->MVTO == "EST"

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+TH04->PROD))
			ZZ9->(dbSetOrder(2))
			ZZ9->(dbSeek(xFilial("ZZ9") + TH04->PROD + TH04->LOTEPR ))

			htHaveError := .T.
			htRestrLot := "Não"
			If ZZ9->ZZ9_RESTRI == "*"
				htRestrLot := "Sim"
			ElseIf ZZ9->ZZ9_RESTRI == "#"
				htRestrLot := "# Empenho"
			EndIf

			WF007 += '   <tr> '
			WF007 += '     <td><div align="center">' + dtoc(TH04->DTMOV) + '</div></td> '
			WF007 += '     <td><div align="left">' + Alltrim(TH04->PROD) + '</div></td> '
			WF007 += '     <td><div align="left">' + Alltrim(Substr(SB1->B1_DESC,1,50)) + '</div></td> '
			WF007 += '     <td><div align="center">' + Alltrim(TH04->LOTEPR) + '</div></td> '
			WF007 += '     <td><div align="right">' + Transform(TH04->QTDM2, "@E 999,999,999.99") + '</div></td> '
			WF007 += '     <td><div align="left">' + htRestrLot + '</div></td> '
			WF007 += '   </tr> '

			dbSelectArea("TH04")
			dbSkip()

		End

	EndIf
	WF007 += ' </table> '
	WF007 += ' <p>&nbsp;</p> '

	WF007 += ' <p><strong>Problema com o processamento das etiquetas durante importação da Produção para o Protheus.</strong></p> '
	WF007 += ' <p><strong>Atenção: caso o problema esteja relacionado a estoque negativo, importante levar em consideração que o valor negativo projeta o SALDO EM ESTOQUE menos a QUANTIDADE A SER BAIXADA.</strong></p> '
	WF007 += ' <p>'+_cLogTxt+'</p> '
	WF007 += ' <p>&nbsp;</p> '
	WF007 += ' <p>Fim do Processamento: '+hhTmpFIM+'</p> '
	WF007 += ' <p>Tempo Total de processamento: '+Alltrim(ElapTime(hhTmpINI, hhTmpFIM))+'</p> '
	WF007 += ' <p>by BIA570</p> '
	WF007 += ' <p>&nbsp;</p> '
	WF007 += ' </body> '
	WF007 += ' </html> '

	If xyEmpr <> "05"
		df_Orig := "workflow@biancogres.com.br"
	Else
		df_Orig := "workflow@incesa.ind.br"
	EndIf

	df_Dest := U_EmailWF('BIA570IND', xyEmpr )
	df_Assu := IIF(xyEmpr == "05", "INCESA - ", "BIANCOGRES - ") + "Apontamento de Produção(ECOSIS vs PROTHEUS) com Problemas de Apontamento"
	df_Erro := df_Assu + " não enviado. Favor verificar!!!"
	If htHaveError .or. !Empty(_cLogTxt)
		U_BIAEnvMail(df_Orig, df_Dest, df_Assu, WF007, df_Erro)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 13/08/15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fTratEtqCanc()

	gtGtArea := GetArea()
	gtEtqCan := ""

	//   Listas as etiquetas canceladas no período... acumulando para apanhar os IDs referente produção para poterior
	// cancelamento no sistema Protheus.
	AT009 := " SELECT A.CE_NUMERO_DOCTO ETIQUET,
	AT009 += "        A.ID_MOV_PROD IDECO,
	AT009 += "        A.COD_TRANSACAO TRANSAC,
	AT009 += "        A.COD_PRODUTO PRODUT,
	AT009 += "        A.CE_QTDADE QUANT,
	AT009 += "        SUBSTRING(CONVERT(VARCHAR(10), B.ETIQ_DATA, 112), 1, 10) DTREF
	AT009 += "   FROM "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A
	AT009 += "   JOIN "+kt_BsDad+"..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA
	AT009 += "                                       AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO
	AT009 += "  WHERE A.ID_CIA = 1
	AT009 += "    AND ( A.COD_TRANSACAO = 64 AND A.CE_DOCTO = 'CP' )
	AT009 += "    AND B.ETIQ_TRANSITO_PRODUCAO = 0
	AT009 += "    AND A.CE_LOTE <> ' '
	AT009 += "    AND B.COD_ENDERECO NOT IN ( 'RETIDO' )
	AT009 += "    AND CONVERT(SMALLDATETIME, A.CE_DATA_MOVIMENTO, 120) >= CONVERT(SMALLDATETIME, CONVERT(VARCHAR(10), GETDATE()-60, 112)+' 06:00', 120)
	AT009 += "    AND CONVERT(SMALLDATETIME, A.CE_DATA_MOVIMENTO, 120) >= CONVERT(SMALLDATETIME, '20150101 06:00', 120)
	AT009 += "    AND ID_MOV_PROD NOT IN (SELECT D3_YIDECO
	AT009 += "                              FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	AT009 += "                             WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'
	AT009 += "                               AND SD3.D3_YIDECO <> ' '
	AT009 += "                               AND SD3.D3_YORIMOV = 'PR0'
	AT009 += "                               AND SD3.D3_ESTORNO = ' '
	AT009 += "                               AND SD3.D_E_L_E_T_ = ' '
	AT009 += "                             UNION ALL
	AT009 += "                            SELECT Z18_IDECO
	AT009 += "                              FROM "+RetSqlName("Z18")+" Z18 WITH (NOLOCK)
	AT009 += "                             WHERE Z18.Z18_FILIAL = '"+xFilial("Z18")+"'
	AT009 += "                               AND Z18.D_E_L_E_T_ = ' ')
	AT009 += "    AND A.CE_LOTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	AT009 += "    AND B.ETIQ_DATA BETWEEN '"+fgRfDtAn+" 06:00:00' AND '"+fgRfDtDp+" 05:59:00'
	AT009 += "    AND A.COD_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	AT009 += "    AND A.CE_QTDADE > 0
	AT009 += "  ORDER BY B.ETIQ_DATA, A.ID_MOV_PROD
	ATcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,AT009),'AT09',.T.,.T.)
	dbSelectArea("AT09")
	dbGoTop()
	While !Eof()

		//   Etiqueta boa. Caso ainda não tenha sido importada a etiqueta Boa e existindo a etiqueta cancelada (query acima), o sistema grava as
		// duas ocorrências na tabela auxiliar (Z18) impedindo que o estas movimentações
		AC007 := " SELECT A.CE_NUMERO_DOCTO ETIQUET,
		AC007 += "        A.ID_MOV_PROD IDECO,
		AC007 += "        A.COD_TRANSACAO TRANSAC,
		AC007 += "        A.COD_PRODUTO PRODUT,
		AC007 += "        A.CE_QTDADE QUANT,
		AC007 += "        SUBSTRING(CONVERT(VARCHAR(10), B.ETIQ_DATA, 112), 1, 10) DTREF
		AC007 += "   FROM "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A
		AC007 += "   JOIN "+kt_BsDad+"..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA
		AC007 += "                                       AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO
		AC007 += "  WHERE A.ID_CIA = 1
		AC007 += "    AND A.COD_TRANSACAO IN('1','20')
		AC007 += "    AND A.CE_DOCTO <> 'SA'
		AC007 += "    AND B.ETIQ_TRANSITO_PRODUCAO = 0
		AC007 += "    AND A.CE_LOTE <> ' '
		AC007 += "    AND B.COD_ENDERECO NOT IN ( 'RETIDO' )
		AC007 += "    AND CONVERT(SMALLDATETIME, A.CE_DATA_MOVIMENTO, 120) >= CONVERT(SMALLDATETIME, CONVERT(VARCHAR(10), GETDATE()-60, 112)+' 06:00', 120)
		AC007 += "    AND CONVERT(SMALLDATETIME, A.CE_DATA_MOVIMENTO, 120) >= CONVERT(SMALLDATETIME, '20150101 06:00', 120)
		AC007 += "    AND A.CE_NUMERO_DOCTO IN("+Alltrim(Str(AT09->ETIQUET))+")
		AC007 += "    AND ID_MOV_PROD NOT IN (SELECT D3_YIDECO
		AC007 += "                              FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
		AC007 += "                             WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'
		AC007 += "                               AND SD3.D3_YIDECO <> ' '
		AC007 += "                               AND SD3.D3_YORIMOV = 'PR0'
		AC007 += "                               AND SD3.D3_ESTORNO = ' '
		AC007 += "                               AND SD3.D_E_L_E_T_ = ' '
		AC007 += "                             UNION ALL
		AC007 += "                            SELECT Z18_IDECO
		AC007 += "                              FROM "+RetSqlName("Z18")+" Z18 WITH (NOLOCK)
		AC007 += "                             WHERE Z18.Z18_FILIAL = '"+xFilial("Z18")+"'
		AC007 += "                               AND Z18.D_E_L_E_T_ = ' ')
		AC007 += "    AND A.CE_LOTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
		AC007 += "    AND B.ETIQ_DATA BETWEEN '"+fgRfDtAn+" 06:00:00' AND '"+fgRfDtDp+" 05:59:00'
		AC007 += "    AND A.COD_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
		AC007 += "    AND A.CE_QTDADE > 0
		AC007 += "  ORDER BY B.ETIQ_DATA, A.ID_MOV_PROD
		ACcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,AC007),'AC07',.T.,.T.)
		dbSelectArea("AC07")
		dbGoTop()
		While !Eof()

			// ID Eco da Produção da Etiqueta
			dbSelectArea("Z18")
			RecLock("Z18",.T.)
			Z18->Z18_FILIAL := xFilial("Z18")
			Z18->Z18_IDECO  := AC07->IDECO
			Z18->Z18_COD    := AC07->PRODUT
			Z18->Z18_DATA   := stod(AC07->DTREF)
			Z18->Z18_QUANT  := AC07->QUANT
			Z18->Z18_NUMETQ := Alltrim(Str(AC07->ETIQUET))
			Z18->Z18_DOCSD3 := "XDOCECANC"
			Z18->Z18_NSQSD3 := "XDOCEC"
			Z18->Z18_DTCANC := Date()
			Z18->Z18_TM     := "PR0"
			MsUnLock()

			// ID Eco do Cancelamento da Etiqueta
			dbSelectArea("Z18")
			RecLock("Z18",.T.)
			Z18->Z18_FILIAL := xFilial("Z18")
			Z18->Z18_IDECO  := AT09->IDECO
			Z18->Z18_COD    := AT09->PRODUT
			Z18->Z18_DATA   := stod(AT09->DTREF)
			Z18->Z18_QUANT  := AT09->QUANT
			Z18->Z18_NUMETQ := Alltrim(Str(AT09->ETIQUET))
			Z18->Z18_DOCSD3 := "XDOCECANC"
			Z18->Z18_NSQSD3 := "XDOCEC"
			Z18->Z18_DTCANC := Date()
			Z18->Z18_TM     := "EST"
			MsUnLock()

			dbSelectArea("AC07")
			dbSkip()

		End

		AC07->(dbCloseArea())
		Ferase(ACcIndex+GetDBExtension())
		Ferase(ACcIndex+OrdBagExt())

		dbSelectArea("AT09")
		dbSkip()

	End
	AT09->(dbCloseArea())
	Ferase(ATcIndex+GetDBExtension())
	Ferase(ATcIndex+OrdBagExt())

	RestArea(gtGtArea)

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
	aAdd(aRegs,{cPerg,"03","De Produto           ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Ate Produto          ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","De Lote              ?","","","mv_ch5","C",10,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Ate Lote             ?","","","mv_ch6","C",10,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

Static Function fDblClick()

	If oNGDd1Ap:oBrowse:Colpos	== 1
		If oNGDd1Ap:aCols[oNGDd1Ap:nAt,1] == "BR_VERDE"
			oNGDd1Ap:aCols[oNGDd1Ap:nAt,1] := "BR_VERMELHO"
		Else
			oNGDd1Ap:aCols[oNGDd1Ap:nAt,1] := "BR_VERDE"
		EndIF 
	Else
		oNGDd1Ap:EditCell()
	EndIF

	oNGDd1Ap:Refresh()

Return
