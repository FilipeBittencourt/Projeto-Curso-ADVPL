#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} BIA296
@description Browser Principal para Rotina de Importação de XML 
@author Marcos Alberto Soprani
@since 08/05/2012
@version undefined
@history 18/05/2017, Ranisses A. Corona, Alteração na função da gravação da tabela SA5
@type function
/*/

User Function BIA296()

	Local lUsa 		:= GETMV("MV_YBIA296",.F.,.F.)
	Local aCores
	Private xImpDh := .F.
	Private vvvArea := GetArea()

	Public xtVetNfO := {}

	If !lUsa
		MsgSTOP("Este programa está desativado! Favor utilizar a rotina Totvs Colaboração.","Atenção")
		Return
	EndIf

	dbSelectArea("SDS")
	dbGoTop()
	aCores :=  { ;
	{" DS_STATUS <> 'P' "                          , "BR_VERDE"      },;
	{" DS_STATUS = 'P' "                           , "BR_VERMELHO"   } }

	n := 1
	cCadastro := " ....: Importação de XML :.... "

	If __cUserID $ "000553;000996"
		aRotina   := {  {"Pesquisar"     ,'AxPesqui'                                          ,0, 1},;
		{                "Processar"     ,'Execblock("BIA296B"    ,.F.,.F.,"P")'              ,0, 2},;
		{                "Schema"        ,'Execblock("BIA296D"    ,.F.,.F.,"D")'              ,0, 3},;
		{                "Falta XML"     ,'Execblock("BIA296F"    ,.F.,.F.,"F")'              ,0, 4},;
		{                "SDS vs SF1"    ,'Execblock("BIA296S"    ,.F.,.F.,"S")'              ,0, 5},;
		{                "Importar"      ,'Execblock("BIA295"     ,.F.,.F.,"I")'              ,0, 6},;
		{                "Grv Schma"     ,'Execblock("BIA296G"    ,.F.,.F.,"G")'              ,0, 7},;
		{                "Baixar Email"  ,'Execblock("WF_BIA290"  ,.F.,.F.,"'+cEmpAnt+'")'    ,0, 8},;
		{                "Legenda"       ,'Execblock("BIA296A"    ,.F.,.F.,"L")'              ,0, 9} }
	Else
		aRotina   := {  {"Pesquisar"     ,'AxPesqui'                                          ,0, 1},;
		{                "Processar"     ,'Execblock("BIA296B"    ,.F.,.F.,"P")'              ,0, 2},;
		{                "Schema"        ,'Execblock("BIA296D"    ,.F.,.F.,"D")'              ,0, 3},;
		{                "Falta XML"     ,'Execblock("BIA296F"    ,.F.,.F.,"F")'              ,0, 4},;
		{                "Importar"      ,'Execblock("BIA295"     ,.F.,.F.,"I")'              ,0, 6},;
		{                "Baixar Email"  ,'Execblock("WF_BIA290"  ,.F.,.F.,"'+cEmpAnt+'")'    ,0, 5},;
		{                "Legenda"       ,'Execblock("BIA296A"    ,.F.,.F.,"L")'              ,0, 6} }
	EndIf

	mBrowse(6,1,22,75, "SDS", , , , , ,aCores)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA296A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Funcao para apresenta a Cor na tela                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA296A()

	Brwlegenda(cCadastro, "Legenda",{{ "BR_VERDE"      ,"Documento não Gerado"         } ,;
	{                                  "BR_VERMELHO"   ,"Documento Gerado"             } })

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA296B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Processamento de Importação de XML                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA296B()

	Local I,J
	Local aSize := MsAdvSize()
	Local LRET  := .F.
	Local _CEMP := cEmpAnt+cFilAnt

	Private aButtons := {}
	Private oPanel1
	Private oPanel2
	Private oPanel3
	Private ARET
	Private oMSNewGe1
	Private oDlgNFE

	Private oFont1    := TFont():New("Verdana",,018,,.T.,,,,,.F.,.F.)
	Private _NFNUM    := ""
	Private _NFSERIE  := ""
	Private _NFEMIS   := CTOD(" ")
	Private _CNFEMIS  := ""
	Private _CCNPJFOR := ""
	Private _CCODFOR  := ""
	Private _CLOJFOR  := ""
	Private _CNOMEFOR := ""
	Private _CCHVNFE  := Space(44)
	Private aColsEx   := {}
	Private kxNfRet   := .F.
	Private __CCOND   := ""      // Incluido em 05/09/12
	Private __PLiqui  := 0       // Incluido em 05/09/12
	Private __Distri  := .F.     // Incluido em 05/09/12
	Private __LocDis  := "ZZZZ"  // Incluido em 05/09/12
	Private _xIntrGrV := .F.     // Incluído em 06/09/12 para possibilitar a soma de N dias às parcelas via P.E. A103CND2
	Private cEmp                 // Incluído em 06/09/12 para possibilitar a soma de N dias às parcelas via P.E. A103CND2
	Private xChqCfopC := .F.     // Incluído em 30/04/13 por Marcos Alberto Soprani para tratamento do CFOP de Retorno de Remessa para Conserto
	Private _xTipoNf  := ""      // Incluído em 13/08/13 por Marcos Alberto Soprani para tratamento de entrada das notas na Vitcer.

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	If Alltrim(SDS->DS_STATUS) == "P"
		MsgSTOP("XML já Importado!!!","Atenção")
		Return ( .T. )
	EndIf

	If Alltrim(SDS->DS_STATUS) == "C" // RETIRADO DE USO EM 23/09/14 POR MARCOS ALBERTO SOPRANI - TOTVS COLABORAÇÃO
		MsgSTOP("Nota Fiscal Cancelada pelo Fornecedor!!!","Atenção")
		Return ( .T. )
	EndIf

	//**************** Busca dados da NF para montagem de Tela ******************
	_NFNUM 	  := SDS->DS_DOC
	_NFSERIE  := SDS->DS_SERIE
	_NFEMIS   := SDS->DS_EMISSA
	_CNFEMIS  := dtoc(SDS->DS_EMISSA)
	_CCODFOR  := SDS->DS_FORNEC
	_CLOJFOR  := SDS->DS_LOJA
	_CCNPJFOR := SDS->DS_CNPJ
	_xTipoNf  := SDS->DS_TIPO
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(XFilial("SA2")+_CCNPJFOR))
		_CNOMEFOR := SA2->A2_NOME
	EndIf
	_CCHVNFE := SDS->DS_CHAVENF

	QT001 := " SELECT DT_ITEM,
	QT001 += "        DT_PRODFOR,
	QT001 += "        DT_COD,
	QT001 += "        DT_DESCFOR,
	QT001 += "        DT_QUANT,
	QT001 += "        DT_VUNIT,
	QT001 += "        DT_TOTAL,
	QT001 += "        DT_YCFOP,
	QT001 += "        DT_PEDIDO,
	QT001 += "        DT_ITEMPC,
	QT001 += "        DT_YUNID,
	QT001 += "        DT_YCLVL,
	QT001 += "        DT_YTES,
	QT001 += "        DT_YREGRA,
	QT001 += "        DT_YNFORI,
	QT001 += "        DT_YSRORI,
	QT001 += "        DT_YITORI,
	QT001 += "        DT_YIDTB6,
	QT001 += "        DT_DOC
	QT001 += "   FROM " + RetSqlName("SDT")
	QT001 += "  WHERE DT_FILIAL = '"+xFilial("SDT")+"'
	QT001 += "    AND DT_CNPJ = '"+SDS->DS_CNPJ+"'
	QT001 += "    AND DT_FORNEC = '"+SDS->DS_FORNEC+"'
	QT001 += "    AND DT_LOJA = '"+SDS->DS_LOJA+"'
	QT001 += "    AND DT_DOC = '"+SDS->DS_DOC+"'
	QT001 += "    AND DT_SERIE = '"+SDS->DS_SERIE+"'
	QT001 += "    AND D_E_L_E_T_ = ' '
	TcQuery QT001 ALIAS "QT01" NEW
	dbSelectArea("QT01")
	dbGoTop()
	While !Eof()

		kjCod   := QT01->DT_COD
		kjTES   := QT01->DT_YTES
		kjRegra := QT01->DT_YREGRA
		kjNfOri := QT01->DT_YNFORI
		kjSrOri := QT01->DT_YSRORI
		kjItOri := QT01->DT_YITORI
		kjIdtB6 := QT01->DT_YIDTB6
		kjPedid := QT01->DT_PEDIDO
		kjItPed := QT01->DT_ITEMPC
		kjFormt := Space(2)
		kjLoteC := Space(10)
		kjCodRf := Space(15)

		If Substr(QT01->DT_YCFOP,2,3) == "916"
			xChqCfopC := .T.
		EndIf

		If _CCODFOR == "003721"

			If dtos(dDataBase) <= "20131008"

				kjCod   := Alltrim(Substr(DT_DESCFOR,1,8))

				If Substr(QT01->DT_YCFOP,2,3) $ "902/903"

					If Substr(QT01->DT_YCFOP,2,3) $ "902"                            // Retorno de Remessa para Industrialização
						**********************************************************************************************************
						kxNfRet  := .T.
						kjPosIni := At("NF - ", QT01->DT_DESCFOR) + 5
						kjPosFim := At("-- ", Substr(QT01->DT_DESCFOR, kjPosIni, Len(Alltrim(QT01->DT_DESCFOR)) - kjPosIni + 1 ) )
						kjNfOri  := StrZero( Val(Substr(QT01->DT_DESCFOR, kjPosIni, kjPosFim-1)), 6)

						If kjNfOri == "000000"
							kjPosIni := At("NF - ", QT01->DT_DESCFOR) + 5
							kjPosFim := At(" PRI", Substr(QT01->DT_DESCFOR, kjPosIni, Len(Alltrim(QT01->DT_DESCFOR)) - kjPosIni + 1 ) )
							kjNfOri  := StrZero( Val(Substr(QT01->DT_DESCFOR, kjPosIni, kjPosFim-1)), 6)
						EndIf

						kjLotOri := Space(10)
						If Substr(kjCod,1,1) >= "A"
							kjPFmLot := At(" - ", QT01->DT_DESCFOR)
							kjLotOri := Alltrim(Substr(QT01->DT_DESCFOR, 9, kjPFmLot - 9))
						EndIf

						kjTES   := "057"
						kjRegra := "M "

						kjPosCIn := At(" PRI", QT01->DT_DESCFOR) + 4
						If kjPosCIn <> 0
							kjCodRf  := Alltrim(Substr(QT01->DT_DESCFOR, kjPosCIn, Len(Alltrim(QT01->DT_DESCFOR)) - kjPosCIn + 1 ))
						EndIf

					Else                                                          // RETORNO DE MERC. P/ INDUST. E NAO APLICADA
						*********************************************************************************************************

						//If Alltrim(QT01->DT_PRODFOR) <> kjCod .or. 1 == 1                                     // Atualiza Estoque ----- como tem dificuldade de saber se atualiza ou nao estoque????
						If Alltrim(QT01->DT_PRODFOR) <> kjCod .and. 1 == 2                                      // em 03/04/13 mudei para buscar por defaut a segunda opção porque é a que mais usa. Por Marcos Alberto Soprani.
							*******************************************************************************************************
							kxNfRet  := .T.
							kjPosIni := At("NF - ", QT01->DT_DESCFOR) + 5
							kjPosFim := At("-- ", Substr(QT01->DT_DESCFOR, kjPosIni, Len(Alltrim(QT01->DT_DESCFOR)) - kjPosIni + 1 ) )
							kjNfOri  := StrZero( Val(Substr(QT01->DT_DESCFOR, kjPosIni, kjPosFim-1)), 6)

							kjLotOri := Space(10)
							If Substr(kjCod,1,1) >= "A"
								kjPFmLot := At(" - ", QT01->DT_DESCFOR)
								kjLotOri := Alltrim(Substr(QT01->DT_DESCFOR, 9, kjPFmLot - 9))
							EndIf

							kjTES   := "175"
							kjRegra := "N "
							kjLoteC := kjLotOri

							kjPosCIn := At(" PRI", QT01->DT_DESCFOR) + 4
							If kjPosCIn <> 0
								kjCodRf  := Alltrim(Substr(QT01->DT_DESCFOR, kjPosCIn, Len(Alltrim(QT01->DT_DESCFOR)) - kjPosCIn + 1 ))
							EndIf

						Else                                                                              // Não Atualiza Estoque
							*******************************************************************************************************
							kxNfRet  := .T.
							kjPosIni := At("NF ", QT01->DT_DESCFOR) + 3
							kjNfOri  := StrZero( Val(Substr(QT01->DT_DESCFOR, kjPosIni, Len(Alltrim(QT01->DT_DESCFOR))-kjPosIni+1) ), 6)

							kjLotOri := Space(10)
							If Substr(kjCod,1,1) >= "A"
								kjPInLot := At(" - LOTE", QT01->DT_DESCFOR) + 8
								kjPFmLot := At(" - ", Substr(QT01->DT_DESCFOR, kjPInLot, Len(Alltrim(QT01->DT_DESCFOR)) - kjPInLot ) )
								kjLotOri := Substr(QT01->DT_DESCFOR, kjPInLot, kjPFmLot-1)
							EndIf

							kjTES   := "089"
							kjRegra := "M "
							kjLoteC := kjLotOri

							kjPosCIn := At(" PRI", QT01->DT_DESCFOR) + 4
							If kjPosCIn <> 0
								kjCodRf  := Alltrim(Substr(QT01->DT_DESCFOR, kjPosCIn, Len(Alltrim(QT01->DT_DESCFOR)) - kjPosCIn + 1 ))
							EndIf

						EndIf

						If kjNfOri == "000000"          // Foi necessário implementar esta regra porque a Vitcer mudou a forma de
							//                             nos enviar  a  descrição no XML, não nos comuniou e o Lançamento da nota
							//                             estava ficando cada vez mais prejudicado. Por Marcos Alberto em 14/09/12
							*******************************************************************************************************

							kxNfRet  := .T.
							kjPosIni := At("NF - ", QT01->DT_DESCFOR) + 5
							kjPosFim := Len(Alltrim(QT01->DT_DESCFOR)) - kjPosIni + 1
							kjNfOri  := StrZero( Val(Substr(QT01->DT_DESCFOR, kjPosIni, kjPosFim)), 6)

							kjLotOri := Space(10)
							If Substr(kjCod,1,1) >= "A"
								kjPFmLot := At(" - ", QT01->DT_DESCFOR)
								kjLotOri := Alltrim(Substr(QT01->DT_DESCFOR, 9, kjPFmLot - 9))
							EndIf
							kjLoteC := kjLotOri

						EndIf

					EndIf

					RT004 := " SELECT D2_DOC, D2_SERIE, D2_ITEM, D2_IDENTB6
					RT004 += "   FROM " + RetSqlName("SD2")
					RT004 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					RT004 += "    AND D2_DOC IN('"+kjNfOri+"','000"+kjNfOri+"')
					RT004 += "    AND D2_COD = '"+kjCod+"'
					RT004 += "    AND D2_LOTECTL = '"+kjLotOri+"'
					RT004 += "    AND D2_IDENTB6 IN(SELECT MIN(B6_IDENT)
					RT004 += "                        FROM " + RetSqlName("SB6")
					RT004 += "                       WHERE B6_FILIAL = '"+xFilial("SB6")+"'
					RT004 += "                         AND B6_DOC IN('"+kjNfOri+"','000"+kjNfOri+"')
					RT004 += "                         AND B6_PRODUTO = '"+kjCod+"'
					RT004 += "                         AND B6_PRUNIT BETWEEN "+Alltrim(Str(NoRound(QT01->DT_VUNIT,1)))+" AND "+Alltrim(Str(Round(QT01->DT_VUNIT+0.1,4)))
					RT004 += "                         AND B6_SALDO >= " + Alltrim(Str(QT01->DT_QUANT))
					RT004 += "                         AND D_E_L_E_T_ = ' ')
					RT004 += "    AND D_E_L_E_T_ = ' '
					TcQuery RT004 ALIAS "RT04" NEW
					dbSelectArea("RT04")
					dbGoTop()
					If !Empty(RT04->D2_DOC)
						kjNfOri := RT04->D2_DOC
					EndIf
					kjSrOri := RT04->D2_SERIE
					kjItOri := RT04->D2_ITEM
					kjIdtB6 := RT04->D2_IDENTB6
					RT04->(dbCloseArea())

					If Substr(QT01->DT_YCFOP,2,3) $ "902"
					Else
					EndIf

				ElseIf Substr(QT01->DT_YCFOP,2,3) == "124"                                            // INDUSTRIALIZAÇÃO
					*******************************************************************************************************

					kjLotInd := Space(10)
					If Substr(kjCod,1,1) >= "A"
						kjPInLot := At("TON.", Upper(QT01->DT_DESCFOR)) + 4
						kjPFimLt := At("-- ", Substr(QT01->DT_DESCFOR, kjPInLot, Len(Alltrim(QT01->DT_DESCFOR)) - kjPInLot + 1 ) )
						kjLotInd := Alltrim(Substr(QT01->DT_DESCFOR, kjPInLot, kjPFimLt - 1))
						If Empty(kjLotInd) .or. "STD" $ kjLotInd
							kjPInLot := At("STD", Upper(QT01->DT_DESCFOR))
							If kjPInLot > 0
								kjLotInd := "STD"
							EndIf
						EndIf
					EndIf

					RT004 := " SELECT TOP 1 *
					RT004 += "   FROM (SELECT TOP 1 C7_NUM, C7_ITEM
					RT004 += "           FROM " + RetSqlName("SC7")
					RT004 += "          WHERE C7_FILIAL = '01'
					RT004 += "            AND C7_FORNECE = '003721'
					RT004 += "            AND C7_PRODUTO = '"+kjCod+"'
					RT004 += "            AND C7_QUANT - C7_QUJE = " + Alltrim(Str(QT01->DT_QUANT))
					RT004 += "            AND C7_LOTECTL = '"+kjLotInd+"'
					RT004 += "            AND C7_CONAPRO IN('L',' ')
					RT004 += "            AND C7_RESIDUO = ' '
					RT004 += "            AND D_E_L_E_T_ = ' '
					RT004 += "         UNION
					RT004 += "         SELECT TOP 1 C7_NUM, C7_ITEM
					RT004 += "           FROM " + RetSqlName("SC7")
					RT004 += "          WHERE C7_FILIAL = '"+xFilial("SC7")+"'
					RT004 += "            AND C7_FORNECE = '003721'
					RT004 += "            AND C7_PRODUTO = '"+kjCod+"'
					RT004 += "            AND C7_QUANT - C7_QUJE = " + Alltrim(Str(QT01->DT_QUANT))
					RT004 += "            AND C7_CONAPRO IN('L',' ')
					RT004 += "            AND C7_RESIDUO = ' '
					RT004 += "            AND D_E_L_E_T_ = ' ') PEDIDOS
					TcQuery RT004 ALIAS "RT04" NEW
					dbSelectArea("RT04")
					dbGoTop()
					kjPedid := RT04->C7_NUM
					kjItPed := RT04->C7_ITEM
					RT04->(dbCloseArea())

					kjTES   := "178"
					kjRegra := "N "
					kjFormt := Substr(Right(Alltrim(QT01->DT_DESCFOR),8),1,2)
					kjLoteC := kjLotInd

				EndIf

			Else                                              // Tratamento a partir de 09/10/13
				*******************************************************************************************************************

				kjCod   := QT01->DT_PRODFOR

				If Substr(QT01->DT_YCFOP,2,3) $ "902/903"

					kxNfRet  := .T.

					// Busca os dados de lote na Vitcer
					zp_Empr := "14"

					BK005 := " SELECT D2_LOTECTL, D2_YCODREF, D2_NFORI
					BK005 += "   FROM SD2"+zp_Empr+"0
					BK005 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					BK005 += "    AND D2_DOC = '"+QT01->DT_DOC+"'
					BK005 += "    AND D2_ITEM = '"+Substr(QT01->DT_ITEM,3,2)+"'
					BK005 += "    AND D2_QUANT = "+Alltrim(Str(QT01->DT_QUANT))
					BK005 += "    AND D_E_L_E_T_ = ' '
					BKlIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,BK005),'BK05',.T.,.T.)
					dbSelectArea("BK05")
					dbGoTop()
					kjLotOri := BK05->D2_LOTECTL
					kjCodRf  := BK05->D2_YCODREF
					kjNfOri  := BK05->D2_NFORI
					BK05->(dbCloseArea())
					Ferase(BKlIndex+GetDBExtension())     //arquivo de trabalho
					Ferase(BKlIndex+OrdBagExt())          //indice gerado

					RT004 := " SELECT D2_DOC, D2_SERIE, D2_ITEM, D2_IDENTB6
					RT004 += "   FROM " + RetSqlName("SD2")
					RT004 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					RT004 += "    AND D2_DOC IN('"+kjNfOri+"','000"+kjNfOri+"')
					RT004 += "    AND D2_COD = '"+kjCod+"'
					RT004 += "    AND D2_LOTECTL = '"+kjLotOri+"'
					RT004 += "    AND D2_IDENTB6 IN(SELECT MIN(B6_IDENT)
					RT004 += "                        FROM " + RetSqlName("SB6")
					RT004 += "                       WHERE B6_FILIAL = '"+xFilial("SB6")+"'
					RT004 += "                         AND B6_DOC IN('"+kjNfOri+"','000"+kjNfOri+"')
					RT004 += "                         AND B6_PRODUTO = '"+kjCod+"'
					RT004 += "                         AND B6_PRUNIT BETWEEN "+Alltrim(Str(NoRound(QT01->DT_VUNIT,1)))+" AND "+Alltrim(Str(Round(QT01->DT_VUNIT+0.1,4)))
					RT004 += "                         AND B6_SALDO >= " + Alltrim(Str(QT01->DT_QUANT))
					RT004 += "                         AND D_E_L_E_T_ = ' ')
					RT004 += "    AND D_E_L_E_T_ = ' '
					TcQuery RT004 ALIAS "RT04" NEW
					dbSelectArea("RT04")
					dbGoTop()
					If !Empty(RT04->D2_DOC)
						kjNfOri := RT04->D2_DOC
					EndIf
					kjSrOri := RT04->D2_SERIE
					kjItOri := RT04->D2_ITEM
					kjIdtB6 := RT04->D2_IDENTB6
					RT04->(dbCloseArea())

					If Substr(QT01->DT_YCFOP,2,3) $ "902"                                    // Retorno de Industrialização
						***************************************************************************************************
						kjTES   := "057"
						kjRegra := "M "
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                             // Ret. Ind. - Quebra no Processo
						***************************************************************************************************
						kjTES   := "089"
						kjRegra := "M "
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                        // Ret. Ind. - Quebra Fora do Processo
						***************************************************************************************************
						kjTES   := ""
						kjRegra := ""
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                               // Retorno Sem Industrialização
						***************************************************************************************************
						kjTES   := "175"
						kjRegra := "N "
					EndIf

				ElseIf Substr(QT01->DT_YCFOP,2,3) == "124"                                              // INDUSTRIALIZAÇÃO
					*******************************************************************************************************

					// Busca os dados de lote na Vitcer
					zp_Empr := "14"

					BK005 := " SELECT D2_LOTECTL, D2_YCODREF
					BK005 += "   FROM SD2"+zp_Empr+"0
					BK005 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					BK005 += "    AND D2_DOC = '"+QT01->DT_DOC+"'
					BK005 += "    AND D2_ITEM = '"+Substr(QT01->DT_ITEM,3,2)+"'
					BK005 += "    AND D2_QUANT = "+Alltrim(Str(QT01->DT_QUANT))
					BK005 += "    AND D_E_L_E_T_ = ' '
					BKlIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,BK005),'BK05',.T.,.T.)
					dbSelectArea("BK05")
					dbGoTop()
					kjLotInd := BK05->D2_LOTECTL
					kjFormt  := BK05->D2_YCODREF
					BK05->(dbCloseArea())
					Ferase(BKlIndex+GetDBExtension())     //arquivo de trabalho
					Ferase(BKlIndex+OrdBagExt())          //indice gerado

					RT004 := " SELECT TOP 1 *
					RT004 += "   FROM (SELECT TOP 1 C7_NUM, C7_ITEM
					RT004 += "           FROM " + RetSqlName("SC7")
					RT004 += "          WHERE C7_FILIAL = '01'
					RT004 += "            AND C7_FORNECE = '003721'
					RT004 += "            AND C7_PRODUTO = '"+kjCod+"'
					RT004 += "            AND C7_QUANT - C7_QUJE = " + Alltrim(Str(QT01->DT_QUANT))
					RT004 += "            AND C7_LOTECTL = '"+kjLotInd+"'
					RT004 += "            AND C7_CONAPRO IN('L',' ')
					RT004 += "            AND C7_RESIDUO = ' '
					RT004 += "            AND D_E_L_E_T_ = ' '
					RT004 += "         UNION
					RT004 += "         SELECT TOP 1 C7_NUM, C7_ITEM
					RT004 += "           FROM " + RetSqlName("SC7")
					RT004 += "          WHERE C7_FILIAL = '"+xFilial("SC7")+"'
					RT004 += "            AND C7_FORNECE = '003721'
					RT004 += "            AND C7_PRODUTO = '"+kjCod+"'
					RT004 += "            AND C7_QUANT - C7_QUJE = " + Alltrim(Str(QT01->DT_QUANT))
					RT004 += "            AND C7_CONAPRO IN('L',' ')
					RT004 += "            AND C7_RESIDUO = ' '
					RT004 += "            AND D_E_L_E_T_ = ' ') PEDIDOS
					TcQuery RT004 ALIAS "RT04" NEW
					dbSelectArea("RT04")
					dbGoTop()
					kjPedid := RT04->C7_NUM
					kjItPed := RT04->C7_ITEM
					RT04->(dbCloseArea())

					kjTES   := "178"
					kjRegra := "N "
					kjLoteC := kjLotInd

				EndIf

			EndIf

		ElseIf _CCODFOR $ "007602/002912/000534/004695" .or. (cEmpAnt == "14" .and. _CCODFOR == "000481" .and. _xTipoNf == "B")

			// Fornecedor      IntraGrupo -- Mundi(004695) / Incesa(002912) / Biancogres(000534) / LM(007602) / VITCER (003721)
			*************************************************************************************************
			// Cliente         IntraGrupo -- Mundi(014395) / Incesa(004536) / Biancogres(000481) / LM(010064) / VITCER (008615)
			*************************************************************************************************

			kjCod := QT01->DT_PRODFOR
			kjPInLot := At("LOTE ", Upper(QT01->DT_DESCFOR)) + 5
			kjLotInd := Alltrim(Substr(QT01->DT_DESCFOR, kjPInLot, Len(Alltrim(QT01->DT_DESCFOR))-kjPInLot+1 ))
			kjLoteC := kjLotInd
			_xIntrGrV := .T.

			zp_Cli := Space(6)
			zp_Empr := Space(2)
			If cEmpAnt == "01"
				__Distri  := .T.
				__LocDis  := "ZZZZ"
				zp_Cli := "000481"
				If _CCODFOR == "XXXXXX"
					zp_Empr := "01"
				ElseIf _CCODFOR == "002912"
					zp_Empr := "05"
				ElseIf _CCODFOR == "007602"
					zp_Empr := "07"
				ElseIf _CCODFOR == "004695"
					zp_Empr := "13"
				EndIf

			ElseIf cEmpAnt == "05"
				__Distri  := .T.
				__LocDis  := "ZZZZ"
				zp_Cli := "004536"
				If _CCODFOR == "000534"
					zp_Empr := "01"
				ElseIf _CCODFOR == "XXXXXX"
					zp_Empr := "05"
				ElseIf _CCODFOR == "007602"
					zp_Empr := "07"
				ElseIf _CCODFOR == "004695"
					zp_Empr := "13"
				EndIf

			ElseIf cEmpAnt == "07"
				__Distri  := .T.
				__LocDis  := "LM"
				zp_Cli := "010064"
				If _CCODFOR == "000534"
					zp_Empr := "01"
				ElseIf _CCODFOR == "002912"
					zp_Empr := "05"
				ElseIf _CCODFOR == "XXXXXX"
					zp_Empr := "07"
				ElseIf _CCODFOR == "004695"
					zp_Empr := "13"
				EndIf

			ElseIf cEmpAnt == "13"
				__Distri  := .F.
				__LocDis  := "ZZZZ"
				zp_Cli := "014395"
				If _CCODFOR == "000534"
					zp_Empr := "01"
				ElseIf _CCODFOR == "002912"
					zp_Empr := "05"
				ElseIf _CCODFOR == "007602"
					zp_Empr := "07"
				ElseIf _CCODFOR == "XXXXXX"
					zp_Empr := "13"
				EndIf

			ElseIf cEmpAnt == "14"
				__Distri  := .T.
				__LocDis  := "ZZZZ"
				If _xTipoNf == "B"
					zp_Cli := "003721" // Remessa para Beneficiamento
					If _CCODFOR == "000481"
						zp_Empr  := "01"
					EndIf
				Else
					zp_Cli := "008615" // Vendas
					If _CCODFOR == "000534"
						zp_Empr  := "01"
					EndIf
					If _CCODFOR == "007602"
						zp_Empr  := "07"
					EndIf
				EndIf

			EndIf

			cEmp  := zp_Empr
			kjTES := "0A2"
			KR001 := " SELECT F2_YSUBTP, F2_COND, F2_PLIQUI
			KR001 += "   FROM SF2"+zp_Empr+"0 SF2
			KR001 += "  WHERE F2_FILIAL = '"+xFilial("SF2")+"'
			KR001 += "    AND F2_CLIENTE = '"+zp_Cli+"'
			KR001 += "    AND F2_DOC = '"+_NFNUM+"'
			KR001 += "    AND F2_SERIE = '"+_NFSERIE+"'
			KR001 += "    AND SF2.D_E_L_E_T_ = ' '
			KR001 := ChangeQuery(KR001)
			cIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,KR001),'KR01',.T.,.T.)
			dbSelectArea("KR01")
			dbGoTop()

			//Tratamento para Condição de Pagamento do Tipo 9 //OS 4134-15
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+KR01->F2_COND))	
			If Alltrim(SE4->E4_TIPO) <> '9'
				__CCOND  := KR01->F2_COND
			Else
				__CCOND  := "056"			
			EndIf

			__PLiqui := KR01->F2_PLIQUI
			If Alltrim(KR01->F2_YSUBTP) == 'B'
				kjTES := '0A5'
			Else
				If cEmpAnt == '14' .and. zp_Empr == '01'
					kjTES := '001'
				ElseIf zp_Empr == '01' .or. zp_Empr == '05'
					kjTES := '0A2'
				ElseIf zp_Empr == '13' .and. Alltrim(KR01->F2_YSUBTP) <> 'A'
					//kjTES := '0A3'
					kjTES := '0A4'
				ElseIf zp_Empr == '13' .and. Alltrim(KR01->F2_YSUBTP) == 'A'
					kjTES := '1C6'
				EndIf
			EndIf
			Ferase(cIndex+OrdBagExt())
			KR01->(dbCloseArea())

		EndIf

		AAux := {}
		AAdd(AAux, QT01->DT_ITEM)
		AAdd(AAux, QT01->DT_PRODFOR)
		AAdd(AAux, Alltrim(kjCod)+Space(15-Len(Alltrim(kjCod))) )
		AAdd(AAux, Substr(QT01->DT_DESCFOR, 1, 50))
		AAdd(AAux, QT01->DT_QUANT)
		//AAdd(AAux, QT01->DT_VUNIT)
		AAdd(AAux, Round(QT01->DT_TOTAL/QT01->DT_QUANT,4))
		AAdd(AAux, QT01->DT_TOTAL)
		AAdd(AAux, kjPedid)
		AAdd(AAux, kjItPed)
		AAdd(AAux, QT01->DT_YUNID)
		AAdd(AAux, QT01->DT_YCLVL)
		AAdd(AAux, kjTES)
		AAdd(AAux, kjRegra)
		AAdd(AAux, kjNfOri)
		AAdd(AAux, kjSrOri)
		AAdd(AAux, kjItOri)
		AAdd(AAux, kjIdtB6)
		AAdd(AAux, kjFormt)
		AAdd(AAux, kjLoteC)
		AAdd(AAux, kjCodRf)
		AAdd(AAux, 4)

		AAdd(AAux,.F.)
		AAdd(AColsEx,AAux)

		dbSelectArea("QT01")
		dbSkip()
	End
	QT01->(dbCloseArea())

	DEFINE MSDIALOG oDlgNFE TITLE "Importação de Nota Fiscal Eletrônica" FROM nLin*.000, nCol*.000  TO nLin*.800, nCol*.900 COLORS 0, 16777215 PIXEL

	@ 014, 000 MSPANEL oPanel1 SIZE 400, 236 OF oDlgNFE COLORS 0, 16777215 RAISED

	@ 000, 000 MSPANEL oPanel2                SIZE 399, 049 OF oPanel1 COLORS 0, 16777215 RAISED
	@ 007, 008 SAY oSay1 PROMPT "NOTA:"       SIZE 026, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 006, 038 MSGET oGetNFNUM VAR _NFNUM     SIZE 060, 010 OF oPanel2 COLORS 0, 16777215             PIXEL WHEN(.F.)
	@ 006, 105 SAY oSay2 PROMPT "SÉRIE:"      SIZE 026, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 006, 134 MSGET oGetNFSERIE VAR _NFSERIE SIZE 021, 010 OF oPanel2 COLORS 0, 16777215             PIXEL WHEN(.F.)
	@ 006, 161 SAY oSay3 PROMPT "EMISSÃO:"    SIZE 041, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 006, 204 MSGET oGetNFEMIS VAR _CNFEMIS  SIZE 060, 010 OF oPanel2 COLORS 0, 16777215             PIXEL WHEN(.F.)
	@ 023, 008 SAY oSay4 PROMPT "FORNECEDOR:" SIZE 057, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 022, 068 MSGET oGetFORN VAR _CCODFOR    SIZE 049, 010 OF oPanel2 COLORS 0, 16777215             PIXEL WHEN(.F.)
	@ 022, 121 MSGET oGetLOJA VAR _CLOJFOR    SIZE 016, 010 OF oPanel2 COLORS 0, 16777215             PIXEL WHEN(.F.)
	@ 022, 142 SAY oSay5 PROMPT "NOME:"       SIZE 027, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 022, 174 MSGET oGetNOME VAR _CNOMEFOR   SIZE 200, 010 OF oPanel2 COLORS 0, 16777215             PIXEL WHEN(.F.)
	@ 035, 068 MSGET oGetCHVNFE VAR _CCHVNFE  SIZE 307, 010 OF oPanel2 COLORS 0, 16777215             PIXEL WHEN(.F.)
	@ 036, 008 SAY oSay6 PROMPT "CHAVE NF-e:" SIZE 057, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL

	@ 041, 000 MSPANEL oPanel3 SIZE 399, 194 OF oPanel1 COLORS 0, 16777215 RAISED

	SetKey(VK_F9, {|| U_BIA296C() })
	If kxNfRet
		SetKey(VK_F8, {|| U_BIA296N() })
	EndIf

	fMSNewGe1()

	aAdd(aButtons, { "NOTE"   , {|| U_BIA296C() }, "Pedidos" } )
	If kxNfRet
		aAdd(aButtons, { "DEVOLNF", {|| U_BIA296N() }, "Nf_Devol"} )
	EndIf

	//EnchoiceBar(oDlgNFE, {|| LRET := xeSalvar(), oDlgNFE:End() }, {|| oDlgNFE:End()},,aButtons)

	// Don't change the Align Order
	oPanel2:Align := CONTROL_ALIGN_TOP
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	oMSNewGe1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgNFE CENTERED ON INIT ( EnchoiceBar(oDlgNFE, {|| LRET := xeSalvar(), oDlgNFE:End() }, {|| oDlgNFE:End()},,aButtons) )

	If lRet

		dbSelectArea("SDS")
		RecLock("SDS",.F.)
		SDS->DS_STATUS := "P"
		SDS->DS_USERPRE := __cUserID
		SDS->DS_DATAPRE := dDataBase
		SDS->DS_HORAPRE := Substr(Time(),1,5)
		MsUnlock()

		If __Distri //.and. 1 == 2
			HK007 := " SELECT D1_COD, D1_NUMSEQ, D1_QUANT
			HK007 += "   FROM " + RetSqlName("SD1")
			HK007 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
			HK007 += "    AND D1_FORNECE = '"+_CCODFOR+"'
			HK007 += "    AND D1_DOC = '"+_NFNUM+"'
			HK007 += "    AND D1_SERIE = '"+_NFSERIE+"'
			HK007 += "    AND D_E_L_E_T_ = '' "
			cIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,HK007),'HK07',.T.,.T.)
			dbSelectArea("HK07")
			dbGoTop()
			While !HK07->(Eof())

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+HK07->D1_COD))
				If SB1->B1_RASTRO == "L"

					aCabSDA    := {}
					aItSDB     := {}
					_aItensSDB := {}

					//Cabeçalho com a informação do item e NumSeq que sera endereçado.
					aCabSDA := {{"DA_PRODUTO" ,HK07->D1_COD             ,Nil},;
					{            "DA_NUMSEQ"  ,HK07->D1_NUMSEQ          ,Nil} }

					//Dados do item que será endereçado
					aItSDB := {{"DB_ITEM"	  ,"0001"	                ,Nil},;
					{           "DB_ESTORNO"  ," "	                    ,Nil},;
					{           "DB_LOCALIZ"  ,__LocDis                 ,Nil},;
					{           "DB_DATA"	  ,dDataBase                ,Nil},;
					{           "DB_QUANT"    ,HK07->D1_QUANT           ,Nil} }
					aadd(_aItensSDB,aitSDB)

					LMSERROAUTO := .F.
					lMsHelpAuto := .T.
					lAutoErrNoFile := .T.

					//Executa o endereçamento do item
					MATA265( aCabSDA, _aItensSDB, 3)
					If LMSERROAUTO
						MsgBox("Distribuição com erro de digitação. Entre em contato com o setor de TI!","STOP")
					EndIf
				EndIf

				HK07->(dbSkip())

			End

			Ferase(cIndex+OrdBagExt())
			HK07->(dbCloseArea())

			ZZ9->(dbGoTop())

		EndIf

	EndIf

	SetFunName("BIA296")

	RestArea(vvvArea)

Return(lRet)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fMSNewGe1   ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 12/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Montagem do Grid dos Itens                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fMSNewGe1()

	Local nX
	Local aHeaderEx := {}
	Local aFieldFill := {}
	Local aFields := {}
	Local aAlterFields := {"CODPRO", "PEDIDO", "ITEMPC", "CLVL", "TES", "REGRA", "CODREF", "ARREDU"}

	If xChqCfopC
		aAlterFields := {"CODPRO", "PEDIDO", "ITEMPC", "CLVL", "TES", "REGRA", "CODREF", "ARREDU", "NFORI", "SRORI", "ITORI"}
	EndIf

	aHeadEx := {}
	Aadd(aHeadEx,{"Item"         ,"ITEM"          ,"@!"                  ,04,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Prod.Fornece" ,"CODFOR"        ,"@!"                  ,20,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Prod.Interno" ,"CODPRO"        ,"@!"                  ,15,0 ,"","€€€€€€€€€€€€€€ ","C","SB1","R","",""})
	Aadd(aHeadEx,{"Descricao"    ,"DESPRO"        ,"@!"                  ,50,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Qtde"         ,"QTDE"          ,"@E 999,999.99"       ,10,0 ,"","€€€€€€€€€€€€€€ ","N","","R","",""})
	Aadd(aHeadEx,{"Vl.Unit"      ,"VALUNIT"       ,"@E 9,999,999.9999"   ,12,0 ,"","€€€€€€€€€€€€€€ ","N","","R","",""})
	Aadd(aHeadEx,{"Vl.Total"     ,"VALTOTAL"      ,"@E 999,999,999.99"   ,12,0 ,"","€€€€€€€€€€€€€€ ","N","","R","",""})
	Aadd(aHeadEx,{"Pedido"       ,"PEDIDO"        ,"@!"                  ,06,0 ,"","€€€€€€€€€€€€€€ ","C","SC7XML","R","",""})
	Aadd(aHeadEx,{"Item.PC"      ,"ITEMPC"        ,"@!"                  ,02,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Unid"         ,"UNID"          ,"@!"                  ,02,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Clvl"         ,"CLVL"          ,"@!"                  ,09,0 ,"","€€€€€€€€€€€€€€ ","C","CTH","R","",""})
	Aadd(aHeadEx,{"TES"          ,"TES"           ,"@!"                  ,03,0 ,"","€€€€€€€€€€€€€€ ","C","SF4","R","",""})
	Aadd(aHeadEx,{"Regra"        ,"REGRA"         ,"@!"                  ,02,0 ,"","€€€€€€€€€€€€€€ ","C","ZK","R","",""})
	Aadd(aHeadEx,{"NfOri"        ,"NFORI"         ,"@!"                  ,09,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"SrOri"        ,"SRORI"         ,"@!"                  ,03,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"ItOri"        ,"ITORI"         ,"@!"                  ,02,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"IdentB6"      ,"IDENTB6"       ,"@!"                  ,06,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Formato"      ,"FORMATO"       ,"@!"                  ,02,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"LoteCtl"      ,"LOTECTL"       ,"@!"                  ,10,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"C.Refer"      ,"CODREF"        ,"@!"                  ,15,0 ,"","€€€€€€€€€€€€€€ ","C","SB1","R","",""})
	Aadd(aHeadEx,{"ArredUnit"    ,"ARREDU"        ,"@E 99999"            ,05,0 ,"","€€€€€€€€€€€€€€ ","N","","R","",""})

	oMSNewGe1 := MsNewGetDados():New( 000, 000, 178, 398, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oPanel3, aHeadEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xeSalvar    ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Gravacao de dados e execauto de documentos de entrada      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xeSalvar()

	Local LRET := .F.

	If _CCODFOR <> "003721" // Específico Vitcer

		U_BIAMsgRun("Aguarde... Salvando Dados Amarracao Produto x Fornecedor (SA5)",, {|| exSavSA5() })

	EndIf

	U_BIAMsgRun("Processando entrada da nota fiscal",, {|| lRet := xeExcSF1() })

Return(LRET)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ exSavSA5    ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Processar e gravar SA5 para codigos internos nao encontr.  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static function exSavSA5()

	Local I
	Local aColsEx := AClone(oMSNewGe1:ACols)

	For I := 1 To Len(aColsEx)

		SA5->(dbSetOrder(1))
		If !Empty(aColsEx[I][3])

			U_fGrvPdFr(_CCODFOR, _CLOJFOR, aColsEx[I][3], aColsEx[I][2])

		EndIf

	Next I

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xeExcSF1    ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Processar e fazer o execauto do documento de entrada       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xeExcSF1()

	Local I
	Local ADADOS     := AClone(oMSNewGe1:ACols)
	Local _aAutoErro
	Local _cLogTxt   := ""

	Private LFXIMP         := .T.
	Private LMSERROAUTO    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private _CSA2SEGUM     := AllTrim(SuperGetMV("MV_YSA2SUM",.F.,"")) //Parametro para listar Fornecedores SA2 que utilizam 2a Unidade de medida

	SB1->(dbSetOrder(1))
	ACABS	 		:= {}

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(XFilial("SA2")+_CCODFOR+_CLOJFOR))

	If Empty(__CCOND)
		If !Empty(ADADOS[1][8])
			SC7->(dbSetOrder(1))
			If SC7->(dbSeek(XFilial("SC7")+ADADOS[1][8]))
				__CCOND := SC7->C7_COND
			EndIf
		Else
			__cAliasTmp := GetNextAlias()
			BeginSql Alias __cAliasTmp
				SELECT TOP 1 AIA_CONDPG COND
				FROM %TABLE:AIB% AIB
				JOIN %TABLE:AIA% AIA ON AIA_CODFOR = AIB_CODFOR AND AIA_LOJFOR = AIB_LOJFOR AND AIA_CODTAB = AIB_CODTAB AND AIA.D_E_L_E_T_=' '
				WHERE
				AIB_CODFOR = %EXP:_CCODFOR%
				AND AIB_LOJFOR = %EXP:_CLOJFOR%
				AND AIB_CODPRO = %EXP:ADADOS[1][3]%
				AND AIA_DATATE >= %EXP:DTOS(dDataBase)%
				AND AIB.D_E_L_E_T_=' '
			EndSql
			If !(__cAliasTmp)->(Eof())
				__CCOND := (__cAliasTmp)->COND
			EndIf
			(__cAliasTmp)->(DbCloseArea())
		EndIf
	EndIf

	ACABS:= { {'F1_TIPO   '	, _xTipoNf   	 				  , NIL},;
	{          'F1_DOC    '	, _NFNUM		 				  , NIL},;
	{          'F1_SERIE  '	, _NFSERIE						  , NIL},;
	{          'F1_EMISSAO'	, _NFEMIS						  , NIL},;
	{          'F1_FORNECE'	, _CCODFOR    					  , NIL},;
	{          'F1_LOJA   '	, _CLOJFOR 			     		  , NIL},;
	{          'F1_EST    '	, SA2->A2_EST	  				  , NIL},;
	{          'F1_DTDIGIT'	, dDataBase						  , NIL},;
	{          'F1_ESPECIE'	, 'SPED'						  , NIL},;
	{          'F1_FORMUL ' , 'N'             	  		      , NIL},;
	{          'F1_CHVNFE ' , _CCHVNFE        	  	          , NIL} }

	If !Empty(__CCOND)
		AADD(ACABS,	{'F1_COND ',__CCOND, NIL})
	EndIf

	AITENS := {}
	For I := 1 To Len(ADADOS)

		If Empty(ADADOS[I][3])
			loop
		EndIf

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(XFILIAL("SB1")+ADADOS[I][3]))

		SBZ->(dbSetOrder(1))
		SBZ->(dbSeek(XFILIAL("SB1")+ADADOS[I][3]))

		SC7->(dbSetOrder(1))
		SC7->(dbSeek(XFILIAL("SC7")+ADADOS[I][8]+ADADOS[I][9]))

		If !Empty(aDados[I][8])
			If Alltrim(SB1->B1_UM) <> aDados[I][10]
				MsgSTOP("A unidade de medida do produto no arquivo XML é: " + aDados[I][10] + ". "+CHR(13)+CHR(13)+"No cadastro de produto está cadastrado como: " + Alltrim(SB1->B1_UM) )
			EndIf
		EndIf

		_AAUX := {}
		AADD(_AAUX, {'D1_DOC    ', _NFNUM						  	           , NIL})
		AADD(_AAUX, {'D1_SERIE  ', _NFSERIE						               , NIL})
		AADD(_AAUX, {'D1_FORNECE', _CCODFOR							           , NIL})
		AADD(_AAUX, {'D1_LOJA   ', _CLOJFOR					                   , NIL})
		AADD(_AAUX, {'D1_UM     ', SB1->B1_UM						           , NIL})
		AADD(_AAUX, {'D1_COD    ', SB1->B1_COD					               , NIL})
		If !Empty(ADADOS[I][13])
			AADD(_AAUX, {'D1_YREGRA ', ADADOS[I][13]				           , NIL})
		EndIf

		// Local pre-definido para tratamento de recebimento de poder de terceiros é o "07". Por Marcos Alberto Soprani, em 16/08/13
		// Como estava apresentando problema com a validação do campo, forcei retorno ".T."
		If _xTipoNf == "B"
			AADD(_AAUX, {'D1_LOCAL  ', "07"                                    , ".T."})
		Else
			If cEmpAnt == "14" .and. ADADOS[I][12] == "004" .and. _CCODFOR $ "000534/007602"  // Tratamento implementado em 15/05/14 por Marcos Alberto Soprani para atender ao emquadramento de almoxarifados da Vitcer
				AADD(_AAUX, {'D1_LOCAL  ', "01"                                    , NIL})
			Else
				AADD(_AAUX, {'D1_LOCAL  ', SB1->B1_LOCPAD                          , NIL})
			EndIf
		EndIf

		If !Empty(aDados[I][8])
			AADD(_AAUX, {'D1_PEDIDO ', ADADOS[I][8]					           , NIL})
			AADD(_AAUX, {'D1_ITEMPC ', ADADOS[I][9]					           , NIL})
		EndIf

		// Adiciona a QTDE da segunda unidade de medida caso Fornecedor configurado
		// Em 25/02/13 incluido o tratamento de filtro -- .and. !(cEmpAnt == "05" .and. ADADOS[I][12] == "4I4") conforme solicitação do Marcio nesta mesma data. Por Marcos Alberto Soprani.
		IF !Empty(_CSA2SEGUM) .and. (_CCODFOR+_CLOJFOR) $ _CSA2SEGUM .and. !(cEmpAnt == "05" .and. ADADOS[I][12] == "4I4")
			AADD(_AAUX, {'D1_QTDSEUM', ADADOS[I][5]				, NIL})

		ELSE

			AADD(_AAUX, {'D1_QUANT  ', ADADOS[I][5]			              					, NIL})

			If ( SC7->C7_MOEDA <> 0 .or. SC7->C7_MOEDA <> 1 ) .and. 1 == 2
				vxUnit := ADADOS[I][7]/ADADOS[I][5] / SC7->C7_TXMOEDA
				vxTota := ADADOS[I][7] / SC7->C7_TXMOEDA
				AADD(_AAUX, {'D1_VUNIT  ', Round(vxUnit,2)		                        		, NIL})
				AADD(_AAUX, {'D1_TOTAL  ', vxTota                    							, NIL})
			Else
				//AADD(_AAUX, {'D1_TOTAL  ', ADADOS[I][7]	              							, NIL}) //Retirado por Marcos Alberto em 03/04/12 porque estava gerando problema de arredondamento do valor unitário pela quantidade do pedido.
				//AADD(_AAUX, {'D1_VUNIT  ', Round(ADADOS[I][7]/ADADOS[I][5], ADADOS[I][21])	    , NIL}) //Retirado por Marcos Alberto em 30/03/12 porque dispara gatilhos que diferem do valor do pedido
				AADD(_AAUX, {'D1_TOTAL  ', ADADOS[I][7]	              							, NIL}) //Retirado por Marcos Alberto em 03/04/12 porque estava gerando problema de arredondamento do valor unitário pela quantidade do pedido.
				AADD(_AAUX, {'D1_VUNIT  ', ADADOS[I][6]                                  	    , NIL}) //Retirado por Marcos Alberto em 30/03/12 porque dispara gatilhos que diferem do valor do pedido
			EndIf
		ENDIF

		jfTES := Space(3)
		If !Empty(ADADOS[I][12])
			AADD(_AAUX, {'D1_TES    ', ADADOS[I][12]			, NIL})
			jfTES := ADADOS[I][12]
		ElseIf !Empty(SC7->C7_TES) .and. fRetSF4(SC7->C7_TES)
			AADD(_AAUX, {'D1_TES    ', SC7->C7_TES 				, NIL})
			jfTES := SC7->C7_TES
		ElseIf !Empty(SBZ->BZ_TE) .and. fRetSF4(SBZ->BZ_TE)
			AADD(_AAUX, {'D1_TES    ', SBZ->BZ_TE 				, NIL})
			jfTES := SBZ->BZ_TE
		ElseIf !Empty(SB1->B1_TE) .and. fRetSF4(SB1->B1_TE)
			AADD(_AAUX, {'D1_TES    ', SB1->B1_TE 				, NIL})
			jfTES := SB1->B1_TE
		Else
			A0001 := " SELECT MIN(F4_CODIGO) TES
			A0001 += "   FROM " + RetSqlName("SF4")
			A0001 += "  WHERE F4_FILIAL = '"+xFilial("SF4")+"'
			A0001 += "    AND F4_MSBLQL <> '1'
			A0001 += "    AND D_E_L_E_T_ = ' '
			TCQUERY A0001 New Alias "A001"
			dbSelectArea("A001")
			dbGoTop()
			AADD(_AAUX, {'D1_TES    ', A001->TES 					, NIL})
			jfTES := A001->TES
			A001->(dbCloseArea())
		EndIf
		If !Empty(ADADOS[I][11])
			AADD(_AAUX, {'D1_CLVL   ', ADADOS[I][11]				, NIL})
		EndIf

		If !Empty(ADADOS[I][14])
			AADD(_AAUX, {'D1_NFORI  ', ADADOS[I][14]				, NIL})
		EndIf
		If !Empty(ADADOS[I][15])
			AADD(_AAUX, {'D1_SERIORI', ADADOS[I][15]				, NIL})
		EndIf
		If !Empty(ADADOS[I][16])
			AADD(_AAUX, {'D1_ITEMORI', ADADOS[I][16]				, NIL})
		EndIf
		If !Empty(ADADOS[I][17])
			AADD(_AAUX, {'D1_IDENTB6', ADADOS[I][17]				, NIL})
		EndIf

		If !Empty(ADADOS[I][18])
			AADD(_AAUX, {'D1_YFORIND', ADADOS[I][18]				, NIL})
		EndIf

		If __PLiqui <> 0
			AADD(_AAUX, {'F1_PESOL  ', __PLiqui			            , NIL})
		EndIf

		If Alltrim(GetMv("MV_RASTRO")) == "S"
			If SB1->B1_RASTRO == "L"
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4")+jfTES))
				If SF4->F4_ESTOQUE == "S"
					//If ADADOS[I][12] $ "175/178/126/082/310/0A2/0A3/0A5/1C6"
					If !Empty(ADADOS[I][19])
						AADD(_AAUX, {'D1_LOTECTL', ADADOS[I][19]				, NIL})
					EndIf
					//EndIf
				EndIf
			EndIf
		EndIf

		// Implementado em 26/02/13 por Marcos Alberto Soprani
		If !Empty(ADADOS[I][20])
			AADD(_AAUX, {'D1_YCODREF', ADADOS[I][20]				, NIL})
		EndIf

		AADD(AITENS,_AAUX)

	Next I

	LmsErroAuto := .F.
	lMsHelpAuto := .T.
	lAutoErrNoFile := .T.

	SetKey(VK_F9,{||})
	If kxNfRet
		SetKey(VK_F8,{||})
	EndIf

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(XFilial("SA2")+_CCODFOR+_CLOJFOR))

	MSExecAuto({|x,y,z,w| Mata103(x,y,z,w)},ACABS,AITENS,3,.T.)

	If LmsErroAuto
		_aAutoErro := GetAutoGrLog()
		_cLogTxt += xConvLog(_aAutoErro)
		MsgAlert(_cLogTxt,"Log de Importação")
	EndIf

	SF1->(dbSetOrder(1))
	If !SF1->(dbSeek(xFilial("SF1")+Padr(_NFNUM,TamSX3("F1_DOC")[1])+Padr(_NFSERIE,TamSX3("F1_SERIE")[1])+Padr(_CCODFOR,TamSX3("F1_FORNECE")[1])+Padr(_CLOJFOR,TamSX3("F1_LOJA")[1])+_xTipoNf))
		Return(.F.)
	EndIf

	SetKey(VK_F9, {|| U_BIA296C()})

Return(.T.)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xConvLog    ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Converter log de erro para texto simples                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xConvLog(aAutoErro)

	Local cRet := ""
	Local nX := 1

	For nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+" - "
	Next nX

Return cRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA296C   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Pesquisa Pedidos em aberto para associação a NF            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA296C()

	Local aArea        := GetArea()
	Private aDlgPed
	Private oGet1
	Private cGet1      := Space(45)
	Private oRadMenu1
	Private nRadMenu1  := 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx  := {}
	Private aColsEx    := {}
	Private aFieldFill := {}
	Private aFields    := {"C7_NUM", "C7_ITEM", "C7_PRODUTO", "C7_LOCAL", "C7_EMISSAO", "C7_PRECO", "C7_QUANT", "C7_DESCRI"}
	Private oMGetDd1
	Public hk_Retur1
	Public hk_Retur2

	DEFINE MSDIALOG aDlgPed TITLE "Selecionar Pedidos de Compras" FROM nLin*.000, nCol*.000  TO nLin*.600, nCol*.750 COLORS 0, 16777215 PIXEL
	fMgDado1()
	@ nLin*.240, nCol*.350 BUTTON Retornar PROMPT "Retornar" SIZE nLin*.040, nCol*.020 OF aDlgPed ACTION( fGrDads1(), aDlgPed:End() ) PIXEL
	ACTIVATE MSDIALOG aDlgPed

	n := 1

Return .T.

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fMgDado1  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 23/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fMgDado1()

	Local nX

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	If Empty(oMSNewGe1:ACols[oMSNewGe1:nAt][3])

		// Monta Arquivo de Trabalho
		_cAliasTmp := GetNextAlias()
		Beginsql Alias _cAliasTmp
			SELECT DISTINCT C7_NUM, C7_ITEM, C7_PRODUTO, C7_LOCAL, C7_EMISSAO, C7_PRECO, C7_QUANT - C7_QUJE C7QUANT, C7_DESCRI
			FROM %TABLE:SC7% SC7
			WHERE C7_FILENT = %XFILIAL:SC7%
			AND C7_FORNECE = %EXP:_CCODFOR%
			AND C7_LOJA = %EXP:_CLOJFOR%
			AND (C7_QUANT-C7_QUJE-C7_QTDACLA) > 0
			AND C7_RESIDUO = ' '
			AND C7_TPOP <> 'P'
			AND C7_CONAPRO <> 'B'
			AND SC7.%NotDel%
		EndSql

	Else

		// Monta Arquivo de Trabalho
		_cAliasTmp := GetNextAlias()
		Beginsql Alias _cAliasTmp
			SELECT DISTINCT C7_NUM, C7_ITEM, C7_PRODUTO, C7_LOCAL, C7_EMISSAO, C7_PRECO, C7_QUANT - C7_QUJE C7QUANT, C7_DESCRI
			FROM %TABLE:SC7% SC7
			WHERE C7_FILENT = %XFILIAL:SC7%
			AND C7_FORNECE = %EXP:_CCODFOR%
			AND C7_LOJA = %EXP:_CLOJFOR%
			AND (C7_QUANT-C7_QUJE-C7_QTDACLA) > 0
			AND C7_RESIDUO = ' '
			AND C7_TPOP <> 'P'
			AND C7_CONAPRO <> 'B'
			AND C7_PRODUTO = %EXP:oMSNewGe1:ACols[oMSNewGe1:nAt][3]%
			AND SC7.%NotDel%
		EndSql
	EndIf

	(_cAliasTmp)->(DbGoTop())
	While .Not. (_cAliasTmp)->(Eof())
		Aadd(aFieldFill, {(_cAliasTmp)->C7_NUM, (_cAliasTmp)->C7_ITEM, (_cAliasTmp)->C7_PRODUTO, (_cAliasTmp)->C7_LOCAL, STOD((_cAliasTmp)->C7_EMISSAO), (_cAliasTmp)->C7_PRECO, (_cAliasTmp)->C7QUANT, (_cAliasTmp)->C7_DESCRI, .F. })
		(_cAliasTmp)->(DbSkip())
	EndDo
	(_cAliasTmp)->(dbCloseArea())

	If Len(aFieldFill) == 0
		Aadd(aFieldFill, { Space(6), Space(4), Space(15), Space(2), ctod("  /  /  "), 0, 0, Space(50), .F. })
	EndIf
	aColsEx := aFieldFill

	oMGetDd1 := MsNewGetDados():New( nLin*.005, nCol*.005, nLin*.225, nCol*.373, , , , , , , 999, , , , aDlgPed, aHeaderEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrDads1  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Retorna os dados para o grid de lançamento da Nota         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGrDads1()

	If !Empty(oMGetDd1:ACOLS[oMGetDd1:oBrowse:nAt][1])
		oMSNewGe1:ACols[oMSNewGe1:nAt][3] := oMGetDd1:ACOLS[oMGetDd1:oBrowse:nAt][3]
		oMSNewGe1:ACols[oMSNewGe1:nAt][8] := oMGetDd1:ACOLS[oMGetDd1:oBrowse:nAt][1]
		oMSNewGe1:ACols[oMSNewGe1:nAt][9] := oMGetDd1:ACOLS[oMGetDd1:oBrowse:nAt][2]
	EndIf

	ObjectMethod(oDlgNFE,"Refresh()")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA296N   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 16/08/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Pesquisa Nota Fiscal de Origem para Retorno                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA296N()

	Local rt
	Local hgContin := .F.
	Local zaArea        := GetArea()
	Private zaDlgNot
	Private zoGet1
	Private zcGet1      := Space(45)
	Private zoRadMe1
	Private znRadMe1    := 1
	Private zPesqur
	Private zRetor
	Private znX
	Private zaHeadEx    := {}
	Private zaColsEx    := {}
	Private zaFieldF    := {}
	Private zaFields    := {"D2_LOTECTL", "D2_DOC", "D2_SERIE", "D2_ITEM", "D2_IDENTB6", "B6_SALDO"}
	Private zoMGtDd1

	If Empty(oMSNewGe1:ACols[oMSNewGe1:nAt][17])
		hgContin := .T.
	Else //Ascan(oMSNewGe1:ACols,{|x| x[17] == oMSNewGe1:ACols[oMSNewGe1:nAt][17] }) <> oMSNewGe1:nAt
		ct_Conta := 0
		For rt := 1 to Len(oMSNewGe1:ACols)
			If oMSNewGe1:ACols[rt][17] == oMSNewGe1:ACols[oMSNewGe1:nAt][17]
				ct_Conta ++
			EndIf
		Next rt
		If ct_Conta > 1
			hgContin := .T.
		EndIf
	EndIf

	If hgContin //Empty(oMSNewGe1:ACols[oMSNewGe1:nAt][17])

		DEFINE MSDIALOG zaDlgNot TITLE "Selecionar Notas de Origem para Retorno" FROM nLin*.000, nCol*.000  TO nLin*.600, nCol*.365 COLORS 0, 16777215 PIXEL
		fGrNots1()
		@ nLin*.240, nCol*.160 BUTTON Retornar PROMPT "Retornar" SIZE nLin*.040, nCol*.020 OF zaDlgNot ACTION( fRtDads1(), zaDlgNot:End() ) PIXEL
		ACTIVATE MSDIALOG zaDlgNot

	Else

		MsgINFO("Não é necessário possível trocar o identificador de poder de terceiro, pois ele já consta no grid - IdentB6 ")

	EndIf

	n := 1

Return .T.

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrNots1  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 16/08/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGrNots1()

	Local nX

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(zaFields)
		If SX3->(dbSeek(zaFields[nX]))
			Aadd(zaHeadEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	YX001 := " SELECT D2_LOTECTL,
	YX001 += "        D2_DOC,
	YX001 += "        D2_SERIE,
	YX001 += "        D2_ITEM,
	YX001 += "        D2_IDENTB6,
	YX001 += "        (SELECT B6_SALDO
	YX001 += "           FROM " + RetSqlName("SB6")
	YX001 += "          WHERE B6_FILIAL = '"+xFilial("SB6")+"'
	YX001 += "            AND B6_DOC = D2_DOC
	YX001 += "            AND B6_SERIE = D2_SERIE
	YX001 += "            AND B6_CLIFOR = D2_CLIENTE
	YX001 += "            AND B6_LOJA = D2_LOJA
	YX001 += "            AND B6_PRODUTO = D2_COD
	YX001 += "            AND B6_IDENT = D2_IDENTB6
	YX001 += "            AND D_E_L_E_T_ = ' ') B6_SALDO
	YX001 += "   FROM " + RetSqlName("SD2")
	YX001 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	YX001 += "    AND D2_DOC IN('"+oMSNewGe1:ACols[oMSNewGe1:nAt][14]+"','000"+oMSNewGe1:ACols[oMSNewGe1:nAt][14]+"')
	YX001 += "    AND D2_COD = '"+oMSNewGe1:ACols[oMSNewGe1:nAt][3]+"'
	YX001 += "    AND D2_IDENTB6 IN(SELECT B6_IDENT
	YX001 += "                        FROM " + RetSqlName("SB6")
	YX001 += "                       WHERE B6_FILIAL = '"+xFilial("SB6")+"'
	YX001 += "                         AND B6_DOC IN('"+oMSNewGe1:ACols[oMSNewGe1:nAt][14]+"','000"+oMSNewGe1:ACols[oMSNewGe1:nAt][14]+"')
	YX001 += "                         AND B6_PRODUTO = '"+oMSNewGe1:ACols[oMSNewGe1:nAt][3]+"'
	YX001 += "                         AND B6_SALDO >= '"+Alltrim(Str(oMSNewGe1:ACols[oMSNewGe1:nAt][5]))+"'
	YX001 += "                         AND D_E_L_E_T_ = ' ')
	YX001 += "    AND D_E_L_E_T_ = ' '
	TcQuery YX001 ALIAS "YX01" NEW
	dbSelectArea("YX01")
	dbGoTop()
	While !Eof()
		Aadd(zaFieldF, { YX01->D2_LOTECTL, YX01->D2_DOC, YX01->D2_SERIE, YX01->D2_ITEM, YX01->D2_IDENTB6, YX01->B6_SALDO, .F. })
		dbSelectArea("YX01")
		dbSkip()
	End
	YX01->(dbCloseArea())

	If Len(zaFieldF) == 0
		Aadd(zaFieldF, { Space(10), Space(6), Space(3), Space(2), Space(6), 0, .F. })
	EndIf
	zaColsEx := zaFieldF

	zoMGtDd1 := MsNewGetDados():New( nLin*.005, nCol*.005, nLin*.225, nCol*.180, , , , , , , 999, , , , zaDlgNot, zaHeadEx, zaColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fRtDads1  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 16/08/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Retorna os dados para o grid de lançamento da Nota         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fRtDads1()

	//If !Empty(zoMGtDd1:ACOLS[zoMGtDd1:oBrowse:nAt][1])
	oMSNewGe1:ACols[oMSNewGe1:nAt][14] := zoMGtDd1:ACOLS[zoMGtDd1:oBrowse:nAt][2]
	oMSNewGe1:ACols[oMSNewGe1:nAt][15] := zoMGtDd1:ACOLS[zoMGtDd1:oBrowse:nAt][3]
	oMSNewGe1:ACols[oMSNewGe1:nAt][16] := zoMGtDd1:ACOLS[zoMGtDd1:oBrowse:nAt][4]
	oMSNewGe1:ACols[oMSNewGe1:nAt][17] := zoMGtDd1:ACOLS[zoMGtDd1:oBrowse:nAt][5]
	oMSNewGe1:ACols[oMSNewGe1:nAt][19] := zoMGtDd1:ACOLS[zoMGtDd1:oBrowse:nAt][1]
	//EndIf

	ObjectMethod(oDlgNFE,"Refresh()")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fRetSF4   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Valida digitação do TES                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fRetSF4(wfTES)

	Local xRtTES := .F.

	SF4->(dbSetOrder(1))
	If SF4->(dbSeek(xFilial("SF4")+wfTES))
		If SF4->F4_MSBLQL <> "1"
			xRtTES := .T.
		EndIf
	EndIf

Return ( xRtTES )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA296D   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 09/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Apresenta arquivo XML                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA296D()

	Local oDlgXML
	Local oButton1
	Local oMultiGet1
	Local cMultiGet1 := Alltrim(SDS->DS_YSCHEMA)
	Local cError     := ""
	Local cWarning   := ""
	Local cvRetOk    := .T.
	//Local cPathXML   := "\P10\XML_NFE\" + cEmpAnt+cFilAnt + "\IMPORTADOS\"+Alltrim(SDS->DS_ARQUIVO) // Substituida função em 21/08/12
	Local j_oXML

	//j_oXML := XmlParserFile(cPathXML, "_", @cError, @cWarning )
	//If ValType(j_oXML) != "O"
	//	cvRetOk  := .F.
	//Endif

	//If cvRetOk
	If !Empty(cMultiGet1)

		//SAVE j_oXML XMLSTRING cMultiGet1

		DEFINE MSDIALOG oDlgXML TITLE "Schema XML" FROM 000, 000  TO 400, 700 COLORS 0, 16777215 PIXEL

		@ 007, 006 GET oMultiGet1 VAR cMultiGet1 OF oDlgXML MULTILINE SIZE 338, 168 COLORS 0, 16777215 READONLY HSCROLL PIXEL
		@ 179, 306 BUTTON oButton1 PROMPT "Fechar" SIZE 037, 012 OF oDlgXML ACTION oDlgXML:End() PIXEL
		ACTIVATE MSDIALOG oDlgXML

	Else

		MsgINFO("Problema ao tentar ler o arquivo XML. Favor verificar!!!")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA296G   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 16/08/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Grava Schema no banco de dados                             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA296G()

	MsgINFO("Rotina obsoleta")

	Return

	#IFDEF WINDOWS
	Processa({|| RptzDetl()})
Return
Static Function RptzDetl()
	#ENDIF

	Local  cError   := ""
	Local  cWarning := ""
	Local  cvRetOk  := .T.
	Local cPathXML  := ""
	Local pMGetXML  := ""
	Local  _oXML   := NIL

	dbSelectArea("SDS")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc(SDS->DS_DOC)
		If Empty(SDS->DS_YSCHEMA)
			cPathXML  := "\P10\XML_NFE\" + cEmpAnt+cFilAnt + "\IMPORTADOS\"+Alltrim(SDS->DS_ARQUIVO)
			_oXML := XmlParserFile(cPathXML, "_", @cError, @cWarning )
			If ValType(_oXML) == "O"
				SAVE _oXML XMLSTRING pMGetXML
				RecLock("SDS",.F.)
				SDS->DS_YSCHEMA := Alltrim(pMGetXML)
				MsUnLock()
			Endif
		EndIf
		dbSelectArea("SDS")
		dbSkip()

	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA296F   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 14/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Gera lista em Excel das notas SPEP que estão sem arquivo   ¦¦¦
¦¦¦          ¦XML                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA296F()

	#IFDEF WINDOWS
	Processa({|| RptBIA296F()})
Return
Static Function RptBIA296F()
	#ENDIF

	Local xwDados7 := {}

	// Necessário para que as notas que são lançadas antes do xml seja amarradas aos mesmos caso estes cheguem até o servidor de xml a qualquer tempo - 13/12/12
	U_BIA296S()

	xAccount 			:= "nf-e.biancogres@biancogres.com.br"
	If cEmpAnt == "01"                                       // Biancogres
		xAccount 			:= "nf-e.biancogres@biancogres.com.br"
	ElseIf cEmpAnt == "05"                                   // Incesa
		xAccount 			:= "nf-e.incesa@incesa.ind.br"
	ElseIf cEmpAnt == "12"                                   // St Gestão
		xAccount 			:= "nf-e.stgestao@biancogres.com.br"
	ElseIf cEmpAnt == "13"                                   // Mundi
		xAccount 			:= "nf-e.mundi@biancogres.com.br"
	ElseIf cEmpAnt == "14"                                   // Vitcer
		xAccount 			:= "nf-e.vitcer@vitcer.com.br"
	EndIf

	fPerg := "BIA296F"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	TR007 := " SELECT F1_ESPECIE ESPECIE,
	TR007 += "        F1_FORNECE FORNECE,
	TR007 += "        F1_LOJA LOJA,
	TR007 += "        F1_DOC DOC,
	TR007 += "        F1_SERIE SERIE,
	TR007 += "        F1_EMISSAO EMISSAO,
	TR007 += "        A2_EST EST,
	TR007 += "        A2_NOME NOME,
	TR007 += "        A2_CGC CGC,
	TR007 += "        A2_TEL TEL,
	TR007 += "        A2_EMAIL EMAIL,
	TR007 += "        F1_CHVNFE CHVNFE
	TR007 += "   FROM "+RetSqlName("SF1")+" SF1
	TR007 += "  INNER JOIN "+RetSqlName("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"'
	TR007 += "                       AND A2_COD = F1_FORNECE
	TR007 += "                       AND A2_LOJA = F1_LOJA
	TR007 += "                       AND A2_COD <> 'INVEST'
	TR007 += "                       AND SA2.D_E_L_E_T_ = ' '
	TR007 += "  INNER JOIN "+RetSqlName("SD1")+" SD1 ON D1_FILIAL = '"+xFilial("SD1")+"'
	TR007 += "                       AND D1_DOC = F1_DOC
	TR007 += "                       AND D1_SERIE = F1_SERIE
	TR007 += "                       AND D1_FORNECE = F1_FORNECE
	TR007 += "                       AND D1_LOJA = F1_LOJA
	TR007 += "                       AND SUBSTRING(D1_COD, 1, 3) <> '306'
	TR007 += "                       AND SD1.D_E_L_E_T_ = ' '
	TR007 += "  WHERE F1_FILIAL = '"+xFilial("SF1")+"'
	TR007 += "    AND F1_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TR007 += "    AND F1_FORNECE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	TR007 += "    AND F1_YIMPXML = ' '
	TR007 += "    AND F1_ESPECIE IN('SPED','CTE')
	TR007 += "    AND F1_FORMUL <> 'S'
	TR007 += "    AND F1_TIPO <> 'D'
	TR007 += "    AND SF1.D_E_L_E_T_ = ' '
	TR007 += "  GROUP BY F1_ESPECIE,
	TR007 += "           F1_FORNECE,
	TR007 += "           F1_LOJA,
	TR007 += "           F1_DOC,
	TR007 += "           F1_SERIE,
	TR007 += "           F1_EMISSAO,
	TR007 += "           A2_EST,
	TR007 += "           A2_CGC,
	TR007 += "           A2_TEL,
	TR007 += "           A2_NOME,
	TR007 += "           A2_EMAIL,
	TR007 += "           F1_CHVNFE
	TR007 += "  ORDER BY F1_FORNECE,
	TR007 += "           F1_LOJA
	TcQuery TR007 ALIAS "TR07" NEW
	dbSelectArea("TR07")
	dbGoTop()
	ProcRegua(RecCount())
	If MV_PAR05 == 1
		While !Eof()

			IncProc("Preparando dados para Excel!!!")

			Aadd(xwDados7, { TR07->ESPECIE,;
			TR07->FORNECE,;
			TR07->LOJA,;
			TR07->DOC,;
			TR07->SERIE,;
			dtoc(stod(TR07->EMISSAO)),;
			TR07->EST,;
			TR07->NOME,;
			Transform(TR07->CGC, "@R 999.999.999/9999-99"),;
			TR07->TEL,;
			StrTran(Alltrim(TR07->EMAIL), ";", " # ") ,;
			"'"+TR07->CHVNFE })

			dbSelectArea("TR07")
			dbSkip()
		End
		aStru1 := ("TR07")->(dbStruct())
		TR07->(dbCloseArea())

		U_BIAxExcel(xwDados7, aStru1, "BIA296F"+strzero(seconds()%3500,5) )

	Else

		While !Eof()

			xdForn  := TR07->FORNECE
			xdLoja  := TR07->LOJA
			xdNome  := TR07->NOME
			//xdEmail := IIF(!Empty(TR07->EMAIL), TR07->EMAIL, "claudia.carvalho@biancogres.com.br")
			xdEmail := IIF(!Empty(TR07->EMAIL), TR07->EMAIL, "jacson.fanti@biancogres.com.br") // Solicitado pela Claudia - (OS 0933-14) 

			WL001 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			WL001 += ' <html xmlns="http://www.w3.org/1999/xhtml">
			WL001 += ' <head>
			WL001 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			WL001 += ' <title>Untitled Document</title>
			WL001 += ' </head>
			WL001 += ' <body>
			WL001 += ' <p>Prezado Fornecedor:</p>
			WL001 += ' <p>                  '+Alltrim(xdNome)+'</p>
			WL001 += ' <p>Não identificamos em nossos controles o arquivo XML das notas fiscais abaixo:</p>
			WL001 += ' <table width="385" border="1" cellspacing="0" bordercolor="#000000">
			WL001 += '   <tr>
			WL001 += '     <td width="73" bgcolor="#66CCFF" scope="col"><div align="center"><strong>Serie</strong></div></td>
			WL001 += '     <td width="112" bgcolor="#66CCFF" scope="col"><div align="center"><strong>Nota Fiscal</strong></div></td>
			WL001 += '     <td width="178" bgcolor="#66CCFF" scope="col"><div align="center"><strong>Emissão</strong></div></td>
			WL001 += '   </tr>

			While !Eof() .and. xdForn+xdLoja == TR07->FORNECE+TR07->LOJA

				IncProc("Enviando Email!!!")

				WL001 += '   <tr>
				WL001 += '     <td><div align="center">'+Alltrim(TR07->SERIE)+'</div></td>
				WL001 += '     <td><div align="center">'+Alltrim(TR07->DOC)+'</div></td>
				WL001 += '     <td><div align="center">'+dtoc(stod(TR07->EMISSAO))+'</div></td>
				WL001 += '   </tr>

				dbSelectArea("TR07")
				dbSkip()
			End

			xfPosTel := At("27",SM0->M0_TEL)

			WL001 += ' </table>
			WL001 += ' <p>Peçamos a gentileza de encaminhar os arquivos correspondentes para o endereço abaixo:</p>
			WL001 += ' <p>&nbsp;</p>
			WL001 += ' <p><a href="mailto:'+xAccount+'">'+xAccount+'</a></p>
			WL001 += ' <p>&nbsp;</p>
			WL001 += ' <p>Em caso de dúvidas, favor entrar em contato pelo telefone: '+Substr(SM0->M0_TEL, xfPosTel, Len(SM0->M0_TEL)-xfPosTel)+' e falar com Setor de Compras.</p>
			WL001 += ' <p>&nbsp;</p>
			WL001 += ' <p>Desde já agradecemos pela colaboração.</p>
			WL001 += ' <p>&nbsp;</p>
			WL001 += ' <p>Atenciosamente,</p>
			WL001 += ' <p>&nbsp;</p>
			WL001 += ' <p>'+Alltrim(SM0->M0_NOMECOM)+'</p>
			WL001 += ' </body>
			WL001 += ' </html>

			//If cEmpAnt <> "05"
			//	df_Orig := "workflow@biancogres.com.br"
			//Else
			//	df_Orig := "workflow@incesa.ind.br"
			//EndIf
			df_Orig := xAccount
			df_Dest := Alltrim(xdEmail)
			df_Assu := "Aviso de Falta de arquivo XML"
			df_Erro := "Aviso de Falta de arquivo XML não enviado. Favor Verificar!!!"
			U_BIAEnvMail(df_Orig, df_Dest, df_Assu, WL001, df_Erro)

			dbSelectArea("TR07")
		End
		TR07->(dbCloseArea())

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA296S   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 04/07/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Efetua a amarração entre as tabelas SDS e SF1 para os casos¦¦¦
¦¦¦          ¦em que a nota é lançada no sistema antes da chegada do ar-  ¦¦¦
¦¦¦          ¦XML                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA296S()

	XK001 := " UPDATE "+RetSqlName("SDS")+" SET DS_STATUS = 'P', DS_USERPRE = '"+__cUserID+"', DS_DATAPRE = '"+dtos(dDataBase)+"', DS_HORAPRE = '"+Substr(Time(),1,5)+"'
	XK001 += "  WHERE DS_FILIAL = '"+xFilial("SDS")+"'
	XK001 += "    AND DS_STATUS = ' '
	XK001 += "    AND (SELECT COUNT(*)
	XK001 += "           FROM " + RetSqlName("SF1")
	XK001 += "          WHERE F1_FILIAL = '"+xFilial("SF1")+"'
	XK001 += "            AND ( F1_DOC = DS_DOC OR SUBSTRING(F1_DOC,4,6)+'   ' = DS_DOC OR SUBSTRING(F1_DOC,1,6) = SUBSTRING(DS_DOC,4,6) )
	XK001 += "            AND F1_FORNECE = DS_FORNEC
	XK001 += "            AND F1_LOJA = DS_LOJA
	XK001 += "            AND F1_EMISSAO = DS_EMISSA
	XK001 += "            AND D_E_L_E_T_ = ' ') > 0
	XK001 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(XK001)

	XK002 := " UPDATE "+RetSqlName("SF1")+" SET F1_YIMPXML = 'S'
	XK002 += "  WHERE F1_FILIAL = '"+xFilial("SF1")+"'
	XK002 += "    AND F1_YIMPXML = ' '
	XK002 += "    AND (SELECT COUNT(*)
	XK002 += "           FROM " + RetSqlName("SDS")
	XK002 += "          WHERE DS_FILIAL = '"+xFilial("SDS")+"'
	XK002 += "            AND ( DS_DOC = F1_DOC OR DS_DOC = SUBSTRING(F1_DOC,4,6)+'   ' OR SUBSTRING(DS_DOC,4,6) = SUBSTRING(F1_DOC,1,6) )
	XK002 += "            AND DS_FORNEC = F1_FORNECE
	XK002 += "            AND DS_LOJA = F1_LOJA
	XK002 += "            AND DS_EMISSA = F1_EMISSAO
	XK002 += "            AND D_E_L_E_T_ = ' ') > 0
	XK002 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(XK002)

	MsgINFO(".......: Processamento efetuado - Notas fiscais amarradas a seus respectivos arquivos XML:.......")

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
	aAdd(aRegs,{cPerg,"03","De Fornecedor        ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
	aAdd(aRegs,{cPerg,"04","Ate Fornecedor       ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
	aAdd(aRegs,{cPerg,"05","Processamento        ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Planilha Excel","","","","","FollowUp Email","","","","","","","","","","","","","","","","","","","SA2"})
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
