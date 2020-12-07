#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA682
Empresa   := Biancogres Cerâmica S/A
Data      := 24/05/16
Uso       := PCP - Suprimentos
Aplicação := Down Tracker de Pedido para Cotação
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA682()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA682"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Down Tracker de Pedido de Compras"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PEDIDO  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEM    "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NUMPED  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COMPRADOR"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TPROD   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "GRUPO   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DGRUPO  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "UM      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTRIND  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL    "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DPRODUTO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT   "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "COTACAO "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MOEDA   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TOTPED  "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TXMOEDA "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEMCOT "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SEQCOT  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QTDCOT  "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PRECO   "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TOTAL   "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "OBS     "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRAZO   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORNECE "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOJA    "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME    "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONDPAG "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTATO "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PERIODO "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ALIIPI  "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PICM    "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "VALFRE  "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DATPRF  "               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "MOTIVO  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "BASEICM "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "BASEIPI "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DESPESA "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "VALIPI  "               ,3,2)

	RV003 := " SELECT *, "
	RV003 += "        CASE
	RV003 += "          WHEN USUARIO = '000416' THEN 'CLAUDIA CARVALHO'
	RV003 += "          WHEN USUARIO = '000580' THEN 'FACILE'
	RV003 += "          WHEN USUARIO = '000593' THEN 'RODOLFO STANKE'
	RV003 += "          WHEN USUARIO = '000659' THEN 'GIOVANI VALIATTI GOMES'
	RV003 += "          WHEN USUARIO = '000683' THEN 'JESEBEL BRANDAO MOTA NUNES'
	RV003 += "          WHEN USUARIO = '000769' THEN 'ROSILENE DA SILVA MURRER'
	RV003 += "          WHEN USUARIO = '000803' THEN 'ANA PAULA GONCALVES'
	RV003 += "          WHEN USUARIO = '000858' THEN 'CARLOS'
	RV003 += "          WHEN USUARIO = '000867' THEN 'JACSON BRAGANCA FANTI'
	RV003 += "          WHEN USUARIO = '000927' THEN 'ARTHUR'
	RV003 += "          ELSE 'INDEFINIDO'
	RV003 += "        END COMPRADOR
	RV003 += "   FROM (SELECT C7_NUM PEDIDO, "
	RV003 += "                C7_ITEM ITEM, "
	RV003 += "                C8_NUMPED NUMPED, "
	RV003 += "                B1_TIPO TPROD, "
	RV003 += "                B1_GRUPO GRUPO, "
	RV003 += "                BM_DESC DGRUPO, "
	RV003 += "                B1_UM UM, "
	RV003 += "                B1_YCTRIND CTRIND, "
	RV003 += "                C7_CLVL CLVL, "
	RV003 += "                C7_PRODUTO PRODUTO, "
	RV003 += "                SUBSTRING(RTRIM(B1_DESC),1,150) DPRODUTO, "
	RV003 += "                C7_QUANT QUANT, "
	RV003 += "                C7_NUMCOT COTACAO, "
	RV003 += "                C7_MOEDA MOEDA, "
	RV003 += "                CASE "
	RV003 += "                  WHEN C7_TXMOEDA = 0 THEN 1 "
	RV003 += "                  ELSE C7_TXMOEDA "
	RV003 += "                END TXMOEDA, "
	RV003 += "                C7_TOTAL TOTPED, "
	RV003 += "                ISNULL(C8_ITEM, '') ITEMCOT, "
	RV003 += "                ISNULL(C8_NUMPRO, '') SEQCOT, "
	RV003 += "                ISNULL(C8_QUANT, 0) QTDCOT, "
	RV003 += "                ISNULL(C8_PRECO, 0) PRECO, "
	RV003 += "                ISNULL(C8_TOTAL, 0) TOTAL, "
	If Alltrim(GetSrvProfString("RpoVersion","")) == "120"
		RV003 += "                ISNULL(CAST(CAST(C8_OBS As VARBINARY) AS VARCHAR(MAX)),'') OBS, "
	Else
		RV003 += "                ISNULL(RTRIM(C8_OBS), '') OBS, "
	EndIf
	RV003 += "                ISNULL(C8_PRAZO, 0) PRAZO, "
	RV003 += "                ISNULL(C8_FORNECE, '') FORNECE, "
	RV003 += "                ISNULL(C8_LOJA, '') LOJA, "
	RV003 += "                ISNULL(RTRIM(A2_NOME), '') NOME, "
	RV003 += "                ISNULL(C8_COND, '') CONDPAG, "
	RV003 += "                ISNULL(C8_CONTATO, '') CONTATO, "
	RV003 += "                ISNULL(SUBSTRING(C8_EMISSAO,1,6), '') PERIODO, "
	RV003 += "                ISNULL(C8_ALIIPI, 0) ALIIPI, "
	RV003 += "                ISNULL(C8_PICM, 0) PICM, "
	RV003 += "                ISNULL(C8_VALFRE, 0) VALFRE, "
	RV003 += "                ISNULL(C7_DATPRF, '') DATPRF, "
	RV003 += "                ISNULL(C8_MOTIVO, '') MOTIVO, "
	RV003 += "                ISNULL(C8_BASEICM, 0) BASEICM, "
	RV003 += "                ISNULL(C8_BASEIPI, 0) BASEIPI, "
	RV003 += "                ISNULL(C8_DESPESA, 0) DESPESA, "
	RV003 += "                ISNULL(C8_VALIPI, 0) VALIPI, "
	RV003 += "                SUBSTRING(C7_USERLGI, 11, 1) + SUBSTRING(C7_USERLGI, 15, 1) + "
	RV003 += "                SUBSTRING(C7_USERLGI, 2, 1) + SUBSTRING(C7_USERLGI, 6, 1) + "
	RV003 += "                SUBSTRING(C7_USERLGI, 10, 1) + SUBSTRING(C7_USERLGI, 14, 1) + "
	RV003 += "                SUBSTRING(C7_USERLGI, 1, 1) + SUBSTRING(C7_USERLGI, 5, 1) + "
	RV003 += "                SUBSTRING(C7_USERLGI, 9, 1) + SUBSTRING(C7_USERLGI, 13, 1) + "
	RV003 += "                SUBSTRING(C7_USERLGI, 17, 1) + SUBSTRING(C7_USERLGI, 4, 1) + "
	RV003 += "                SUBSTRING(C7_USERLGI, 8, 1) USUARIO "
	RV003 += "           FROM "+RetSqlName("SC7")+" SC7 WITH (NOLOCK) "
	RV003 += "          INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' "
	RV003 += "                               AND B1_COD = C7_PRODUTO "
	RV003 += "                               AND SB1.D_E_L_E_T_ = ' ' "
	RV003 += "          INNER JOIN "+RetSqlName("SBM")+" SBM WITH (NOLOCK) ON BM_FILIAL = '"+xFilial("SBM")+"' "
	RV003 += "                               AND BM_GRUPO = B1_GRUPO "
	RV003 += "                               AND SBM.D_E_L_E_T_ = ' ' "
	RV003 += "           LEFT JOIN "+RetSqlName("SC8")+" SC8 WITH (NOLOCK) ON C8_FILIAL = '"+xFilial("SC8")+"' "
	RV003 += "                               AND C8_NUM = C7_NUMCOT "
	RV003 += "                               AND C8_IDENT = C7_ITEM "
	RV003 += "                               AND C8_PRODUTO = C7_PRODUTO "
	RV003 += "                               AND SC8.D_E_L_E_T_ = ' ' "
	RV003 += "           LEFT JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON A2_FILIAL = '"+xFilial("SA2")+"' "
	RV003 += "                               AND A2_COD = C8_FORNECE "
	RV003 += "                               AND A2_LOJA = C8_LOJA "
	RV003 += "                               AND SA2.D_E_L_E_T_ = ' ' "
	RV003 += "           LEFT JOIN "+RetSqlName("SED")+" SED WITH (NOLOCK) ON ED_FILIAL = '"+xFilial("SED")+"' "
	RV003 += "                               AND ED_COND = C8_COND "
	RV003 += "                               AND SED.D_E_L_E_T_ = ' ' "
	RV003 += "          WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
	RV003 += "            AND C7_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	RV003 += "            AND SC7.D_E_L_E_T_ = ' ' ) AS TABR "
	RV003 += "   WHERE PRECO <> 0 "
	RV003 += "     AND COTACAO + ITEM + PRODUTO + FORNECE + LOJA + CONVERT(VARCHAR, PRECO) IN(SELECT C8_NUM + C8_IDENT + C8_PRODUTO + C8_FORNECE + C8_LOJA + CONVERT(VARCHAR, MIN(C8_PRECO)) "
	RV003 += "                                                                                  FROM "+RetSqlName("SC8")+" SC8 WITH (NOLOCK) "
	RV003 += "                                                                                 WHERE C8_NUM = TABR.COTACAO "
	RV003 += "                                                                                   AND C8_IDENT = TABR.ITEM "
	RV003 += "                                                                                   AND C8_PRODUTO = TABR.PRODUTO "
	RV003 += "                                                                                   AND C8_FORNECE = TABR.FORNECE "
	RV003 += "                                                                                   AND C8_LOJA = TABR.LOJA "
	RV003 += "                                                                                   AND SC8.D_E_L_E_T_ = ' ' "
	RV003 += "                                                                                 GROUP BY C8_NUM + C8_IDENT + C8_PRODUTO + C8_FORNECE + C8_LOJA) "
	RVcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RV003),'RV03',.F.,.T.)
	dbSelectArea("RV03")
	dbGoTop()
	ProcRegua(RecCount())
	ckContad := 0
	While !Eof()

		ckContad ++
		IncProc("Processamento1: " + Alltrim(Str(ckContad)))

		oExcel:AddRow(nxPlan, nxTabl, { RV03->PEDIDO           ,;
		RV03->ITEM                                             ,;
		RV03->NUMPED                                           ,;
		RV03->COMPRADOR                                        ,;
		RV03->TPROD                                            ,;
		RV03->GRUPO                                            ,;
		RV03->DGRUPO                                           ,;
		RV03->UM                                               ,;
		RV03->CTRIND                                           ,;
		RV03->CLVL                                             ,;
		RV03->PRODUTO                                          ,;
		RV03->DPRODUTO                                         ,;
		RV03->QUANT                                            ,;
		RV03->COTACAO                                          ,;
		RV03->MOEDA                                            ,;
		RV03->TOTPED                                           ,;
		RV03->TXMOEDA                                          ,;
		RV03->ITEMCOT                                          ,;
		RV03->SEQCOT                                           ,;
		RV03->QTDCOT                                           ,;
		RV03->PRECO                                            ,;
		RV03->TOTAL                                            ,;
		RV03->OBS                                              ,;
		RV03->PRAZO                                            ,;
		RV03->FORNECE                                          ,;
		RV03->LOJA                                             ,;
		RV03->NOME                                             ,;
		RV03->CONDPAG                                          ,;
		RV03->CONTATO                                          ,;
		RV03->PERIODO                                          ,;
		RV03->ALIIPI                                           ,;
		RV03->PICM                                             ,;
		RV03->VALFRE                                           ,;
		stod(RV03->DATPRF)                                     ,;
		RV03->MOTIVO                                           ,;
		RV03->BASEICM                                          ,;
		RV03->BASEIPI                                          ,;
		RV03->DESPESA                                          ,;
		RV03->VALIPI                                           })

		dbSelectArea("RV03")
		dbSkip()

	End

	RV03->(dbCloseArea())
	Ferase(RVcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RVcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "downtracker - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
