#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA506()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA506
Empresa   := Biancogres Cerâmica S/A
Data      := 12/09/14
Uso       := Estoque e Custos
Aplicação := Confronto entre Saldo de Estoque do Ecosis Versus Protheus
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF
Local Enter := chr(13) + Chr(10)
If !ValidPerg()
	Return
EndIf

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Saldo em Estoque ( Ecosis x Protheus )"

IF MV_PAR01 == "2"
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Formato"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Produto"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Descrição"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Lote"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Almoxarifado"    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Restrição"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "UltData"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PriProd"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Ecosis"          ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "P.DEVOL"         ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "PAP"             ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "PMEC "           ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "ZZZZ"            ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Outros"          ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Diferença"       ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Classe"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Status"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Fator Conv"      ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CX. Pallet"      ,3,2)

Else

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Formato"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Produto"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Descrição"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Lote"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Almoxarifado"    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Restrição"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Ecosis"          ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Protheus"         ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Diferença"       ,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Classe"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Status"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Fator Conv"      ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CX. Pallet"      ,3,2)

EndIf

guTablEco := ""
guLocPadE := ""

If cEmpAnt == "01"
	guTablEco := "DADOSEOS"
	//guLocPadE := "02"
ElseIf cEmpAnt == "05"
	guTablEco := "DADOS_05_EOS"
	//guLocPadE := "04"
ElseIf cEmpAnt == "13"
	guTablEco := "DADOS_13_EOS"
	//guLocPadE := "02','04"
ElseIf cEmpAnt == "14"
	guTablEco := "DADOS_14_EOS"
// Else
// 	Aviso( 'BIA506', 'Empresa não configurada para o sistema Ecosis', {'Ok'} )
// 	Return
EndIf

If MV_PAR02 == "1"
	guLocPadE := "02'
ElseIf MV_PAR02 == "2"
	guLocPadE := "04"
ElseIf MV_PAR02 == "3"
	guLocPadE := "02','04"
EndIf

GU004 :=	""

IF MV_PAR01 == "2"
	
	GU004 += " SELECT PRODUT," + Enter
	GU004 += "        SUBSTRING(B1_DESC,1,75) DESCR," + Enter
	GU004 += "        LOTEPR," + Enter
	GU004 += "        (SELECT MAX(D3_EMISSAO)" + Enter
	GU004 += "           FROM " + RetSqlName("SD3") + " WITH (NOLOCK) " + Enter
	GU004 += "          WHERE D3_FILIAL 	= '"+xFilial("SD3")+"'" + Enter
	GU004 += "            AND D3_TM			= '010'	" + Enter
	GU004 += "            AND D3_COD 		= PRODUT" + Enter
	GU004 += "            AND D3_LOTECTL	= LOTEPR" + Enter
	GU004 += "            AND D_E_L_E_T_	= ' ') ULTDATA," + Enter
	GU004 += "        (SELECT MIN(D5_DATA)" + Enter
	GU004 += "           FROM " + RetSqlName("SD5") + " WITH (NOLOCK) " + Enter
	GU004 += "          WHERE D5_FILIAL = '"+xFilial("SD5")+"'" + Enter
	GU004 += "            AND ( D5_ORIGLAN = '010' OR (D5_CLIFOR = '003721' AND D5_ORIGLAN <= '498') )" + Enter
	GU004 += "            AND D5_PRODUTO = PRODUT" + Enter
	GU004 += "            AND D5_LOTECTL = LOTEPR" + Enter
	GU004 += "            AND D_E_L_E_T_ = ' ') PRIPROD," + Enter
	GU004 += "        SUM(QECOSIS) QECOSIS," + Enter
	GU004 += "        SUM(QPDEVOL) QPDEVOL," + Enter
	GU004 += "        SUM(QPAP) QPAP," + Enter
	GU004 += "        SUM(QPMEC) QPMEC," + Enter
	GU004 += "        SUM(QZZZZ) QZZZZ," + Enter
	GU004 += "        SUM(QOUTROS) QOUTROS," + Enter
	GU004 += "        ALMOX" + Enter
	GU004 += "   FROM (		" + Enter

	If cEmpAnt $ "01_05_13_14"
		GU004 += "   			  SELECT cep.cod_produto COLLATE LATIN1_GENERAL_BIN PRODUT," + Enter
		GU004 += "                cep.etiq_lote COLLATE LATIN1_GENERAL_BIN LOTEPR," + Enter	
		GU004 += "                CASE " + Enter
		GU004 += "                  WHEN end_local IN(7,8) THEN '04'" + Enter
		GU004 += "			        ELSE '02'" + Enter
		GU004 += "			      END ALMOX," + Enter
		GU004 += "                Sum(cep.etiq_qtde) QECOSIS," + Enter
		GU004 += "                0 QPDEVOL," + Enter
		GU004 += "                0 QPAP," + Enter
		GU004 += "                0 QPMEC," + Enter
		GU004 += "                0 QZZZZ," + Enter
		GU004 += "                0 QOUTROS" + Enter
		GU004 += "           FROM "+guTablEco+"..cep_etiqueta_pallet cep," + Enter
		GU004 += "                "+guTablEco+"..cad_produtos prod," + Enter
		GU004 += "                "+guTablEco+"..cad_ref_produtos ref," + Enter
		GU004 += "                "+guTablEco+"..cep_etiqueta_endereco d" + Enter
		
		GU004 += "          WHERE cep.cod_produto = prod.cod_produto" + Enter
		GU004 += "            AND cep.COD_ENDERECO = d.COD_ENDERECO" + Enter
		GU004 += "            AND prod.prd_referencia = ref.prd_referencia" + Enter
		GU004 += "            AND cep.id_cia = 1" + Enter
		GU004 += "            AND ref.ref_produto = 1" + Enter
		GU004 += "            AND cep.etiq_cancelada = 0" + Enter
		GU004 += "            AND Isnull(cep.nf_numero, '') = ''" + Enter
		GU004 += "          GROUP BY cep.cod_produto," + Enter
		GU004 += "                   cep.etiq_lote," + Enter
		GU004 += "                   CASE" + Enter 
		GU004 += " 				  	 	WHEN end_local IN(7,8) THEN '04'" + Enter
		GU004 += " 					 	ELSE '02'" + Enter
		GU004 += " 				  	 END" + Enter
		GU004 += "          UNION ALL" + Enter
	EndIF

	GU004 += "         SELECT BF_PRODUTO PRODUT," + Enter
	GU004 += "                BF_LOTECTL LOTEPR," + Enter
	GU004 += "                BF_LOCAL ALMOX," + Enter
	GU004 += "                0 QECOSIS," + Enter
	GU004 += "                SUM(BF_QUANT) QPDEVOL," + Enter
	GU004 += "                0 QPAP," + Enter
	GU004 += "                0 QPMEC," + Enter
	GU004 += "                0 QZZZZ," + Enter
	GU004 += "                0 QOUTROS" + Enter
	GU004 += "           FROM "+RetSqlName("SBF")+" WITH (NOLOCK)" + Enter
	GU004 += "          WHERE BF_FILIAL = '"+xFilial("SBF")+"'" + Enter
	GU004 += "            AND BF_LOCAL IN('"+guLocPadE+"')" + Enter
	GU004 += "            AND BF_LOTECTL <> '          '" + Enter
	GU004 += "            AND BF_QUANT <> 0" + Enter
	GU004 += "            AND BF_LOCALIZ = 'P. DEVOL       '" + Enter
	GU004 += "            AND D_E_L_E_T_ = ' '" + Enter
	GU004 += "          GROUP BY BF_PRODUTO, BF_LOTECTL,BF_LOCAL" + Enter

	GU004 += "          UNION ALL" + Enter
	GU004 += "         SELECT BF_PRODUTO PRODUT," + Enter
	GU004 += "                BF_LOTECTL LOTEPR," + Enter
	GU004 += "                BF_LOCAL ALMOX," + Enter
	GU004 += "                0 QECOSIS," + Enter
	GU004 += "                0 QPDEVOL," + Enter
	GU004 += "                SUM(BF_QUANT) QPAP," + Enter
	GU004 += "                0 QPMEC," + Enter
	GU004 += "                0 QZZZZ," + Enter
	GU004 += "                0 QOUTROS" + Enter
	GU004 += "           FROM "+RetSqlName("SBF")+" WITH (NOLOCK)" + Enter
	GU004 += "          WHERE BF_FILIAL = '"+xFilial("SBF")+"'" + Enter
	GU004 += "            AND BF_LOCAL IN('"+guLocPadE+"')" + Enter
	GU004 += "            AND BF_LOTECTL <> '          '" + Enter
	GU004 += "            AND BF_QUANT <> 0" + Enter
	GU004 += "            AND BF_LOCALIZ = 'PAP            '" + Enter
	GU004 += "            AND D_E_L_E_T_ = ' '" + Enter
	GU004 += "          GROUP BY BF_PRODUTO, BF_LOTECTL,BF_LOCAL" + Enter
	
	GU004 += "          UNION ALL" + Enter
	GU004 += "         SELECT BF_PRODUTO PRODUT," + Enter
	GU004 += "                BF_LOTECTL LOTEPR," + Enter
	GU004 += "                BF_LOCAL ALMOX," + Enter
	GU004 += "                0 QECOSIS," + Enter
	GU004 += "                0 QPDEVOL," + Enter
	GU004 += "                0 QPAP," + Enter
	GU004 += "                SUM(BF_QUANT) QPMEC," + Enter
	GU004 += "                0 QZZZZ," + Enter
	GU004 += "                0 QOUTROS" + Enter
	GU004 += "           FROM "+RetSqlName("SBF")+" WITH (NOLOCK)" + Enter
	GU004 += "          WHERE BF_FILIAL = '"+xFilial("SBF")+"'" + Enter
	GU004 += "            AND BF_LOCAL IN('"+guLocPadE+"')" + Enter
	GU004 += "            AND BF_LOTECTL <> '          '" + Enter
	GU004 += "            AND BF_QUANT <> 0" + Enter
	GU004 += "            AND BF_LOCALIZ = 'PMEC           '" + Enter
	GU004 += "            AND D_E_L_E_T_ = ' '" + Enter
	GU004 += "          GROUP BY BF_PRODUTO, BF_LOTECTL,BF_LOCAL" + Enter
	
	GU004 += "          UNION ALL" + Enter
	GU004 += "         SELECT BF_PRODUTO PRODUT," + Enter
	GU004 += "                BF_LOTECTL LOTEPR," + Enter
	GU004 += "                BF_LOCAL ALMOX," + Enter
	GU004 += "                0 QECOSIS," + Enter
	GU004 += "                0 QPDEVOL," + Enter
	GU004 += "                0 QPAP," + Enter
	GU004 += "                0 QPMEC," + Enter
	GU004 += "                SUM(BF_QUANT) QZZZZ," + Enter
	GU004 += "                0 QOUTROS" + Enter
	GU004 += "           FROM "+RetSqlName("SBF")+" WITH (NOLOCK)" + Enter
	GU004 += "          WHERE BF_FILIAL = '"+xFilial("SBF")+"'" + Enter
	GU004 += "            AND BF_LOCAL IN('"+guLocPadE+"')" + Enter
	GU004 += "            AND BF_LOTECTL <> '          '" + Enter
	GU004 += "            AND BF_QUANT <> 0" + Enter
	GU004 += "            AND BF_LOCALIZ = 'ZZZZ           '" + Enter
	GU004 += "            AND D_E_L_E_T_ = ' '" + Enter
	GU004 += "          GROUP BY BF_PRODUTO, BF_LOTECTL,BF_LOCAL" + Enter
	
	GU004 += "          UNION ALL" + Enter
	GU004 += "         SELECT BF_PRODUTO PRODUT," + Enter
	GU004 += "                BF_LOTECTL LOTEPR," + Enter
	GU004 += "                BF_LOCAL ALMOX," + Enter
	GU004 += "                0 QECOSIS," + Enter
	GU004 += "                0 QPDEVOL," + Enter
	GU004 += "                0 QPAP," + Enter
	GU004 += "                0 QPMEC," + Enter
	GU004 += "                0 QZZZZ," + Enter
	GU004 += "                SUM(BF_QUANT) QOUTROS" + Enter
	GU004 += "           FROM "+RetSqlName("SBF")+" WITH (NOLOCK)" + Enter
	GU004 += "          WHERE BF_FILIAL = '"+xFilial("SBF")+"'" + Enter
	GU004 += "            AND BF_LOCAL IN('"+guLocPadE+"')" + Enter
	GU004 += "            AND BF_LOTECTL <> '          '" + Enter
	GU004 += "            AND BF_QUANT <> 0" + Enter
	GU004 += "            AND BF_LOCALIZ NOT IN('P. DEVOL       ','PAP            ','PMEC           ','ZZZZ           ')" + Enter
	GU004 += "            AND D_E_L_E_T_ = ' '" + Enter
	GU004 += "          GROUP BY BF_PRODUTO, BF_LOTECTL,BF_LOCAL" + Enter
	GU004 += "         ) AS TABL" + Enter
ELSE
	
	GU004 += "	WITH SALDOESTAMT" + Enter
	GU004 += "	AS (" + Enter
	GU004 += "		SELECT cod_produto PROD" + Enter
	GU004 += "			,ce_lote LOTE" + Enter
	GU004 += "			,MAX(id_mov_prod) IDREF" + Enter
	GU004 += "		FROM "+guTablEco+"..cep_movimento_produto" + Enter
	GU004 += "		WHERE ce_lote = 'AMT'" + Enter
	GU004 += "		GROUP BY cod_produto" + Enter
	GU004 += "			,ce_lote" + Enter
	GU004 += "		)" + Enter
	GU004 += "	SELECT PRODUT" + Enter
	GU004 += "      ,SUBSTRING(B1_DESC,1,75) DESCR" + Enter
	GU004 += "		,LOTEPR" + Enter
	GU004 += "      ,ALMOX" + Enter
	GU004 += "		,SUM(QECOSIS) QECOSIS" + Enter
	GU004 += "		,SUM(QPROT) QPROT" + Enter
	GU004 += "	FROM (" + Enter
	GU004 += "		SELECT SUBSTRING(AMT.cod_produto, 1, 7) COLLATE LATIN1_GENERAL_BIN PRODUT" + Enter
	GU004 += "			,ce_lote COLLATE LATIN1_GENERAL_BIN LOTEPR" + Enter
	GU004 += "          ,CASE  COALESCE(d.end_local,0)" + Enter 
	GU004 += "		       WHEN 0 THEN '--'" + Enter
	GU004 += "			   ELSE REPLACE(STR(d.end_local, 2),' ','0')" + Enter
	GU004 += "		     END ALMOX" + Enter
	GU004 += "			,SUM(ce_saldo) QECOSIS" + Enter
	GU004 += "			,0 QPROT" + Enter
	GU004 += "		FROM "+guTablEco+"..cep_movimento_produto AMT" + Enter
	GU004 += "		INNER JOIN SALDOESTAMT REF ON REF.PROD = AMT.cod_produto" + Enter
	GU004 += "			AND REF.LOTE = AMT.ce_lote" + Enter
	GU004 += "			AND REF.IDREF = AMT.id_mov_prod" + Enter
	GU004 += "      FULL OUTER JOIN "+guTablEco+"..cep_etiqueta_pallet cep on  cep.cod_produto = AMT.cod_produto" + Enter
	GU004 += "	    FULL OUTER JOIN "+guTablEco+"..cep_etiqueta_endereco d on cep.COD_ENDERECO = d.COD_ENDERECO" + Enter 
	GU004 += "		WHERE ce_saldo <> 0" + Enter
	GU004 += "		GROUP BY SUBSTRING(AMT.cod_produto, 1, 7), ce_lote," + Enter
	GU004 += "		CASE  COALESCE(d.end_local,0)" + Enter 
	GU004 += "		     WHEN 0 THEN '--'" + Enter
	GU004 += "			 ELSE REPLACE(STR(d.end_local, 2),' ','0')" + Enter
	GU004 += "		END" + Enter
	GU004 += "		UNION ALL" + Enter
	GU004 += "		
	GU004 += "		SELECT SUBSTRING(SBF.BF_PRODUTO, 1, 7)" + Enter
	GU004 += "			,SBF.BF_LOTECTL" + Enter
	GU004 += "          ,BF_LOCAL ALMOX" + Enter 
	GU004 += "			,0" + Enter
	GU004 += "			,SUM(SBF.BF_QUANT) - SUM(SBF.BF_EMPENHO)" + Enter
	GU004 += "		FROM "+RetSqlName("SBF")+" SBF WITH (NOLOCK)" + Enter
	GU004 += "		WHERE BF_FILIAL = " + ValtoSql(xFilial("SBF")) + Enter
	GU004 += "			AND BF_LOCAL = '05'" + Enter
	GU004 += "			AND BF_QUANT <> 0" + Enter
	GU004 += "			AND SBF.D_E_L_E_T_ = ''" + Enter
	GU004 += "			AND BF_LOTECTL <> '          '" + Enter
	GU004 += "		GROUP BY SUBSTRING(SBF.BF_PRODUTO, 1, 7)" + Enter
	GU004 += "			,SBF.BF_LOTECTL, BF_LOCAL" + Enter
	GU004 += "		) TABL" + Enter

EndIf

GU004 += "   LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D_E_L_E_T_ = '"+xFilial("SB1")+"'" + Enter
GU004 += "                       AND B1_COD = PRODUT" + Enter
GU004 += "  GROUP BY PRODUT," + Enter
GU004 += "           SUBSTRING(B1_DESC,1,75)," + Enter
GU004 += "           LOTEPR, ALMOX
GUcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
dbSelectArea("GU04")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	ZZ6->(dbSetOrder(1))
	ZZ6->(dbSeek(xFilial("ZZ6") + Substr(GU04->PRODUT,1,2) ) )
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + GU04->PRODUT ))
	
	yhStatus := IIF(SB1->B1_YSTATUS == "1", "ATIVO", IIF(SB1->B1_YSTATUS == "2", "DESCONTINUADO", "OBSOLETO"))
	
	ZZ8->(dbSetOrder(1))
	ZZ8->(dbSeek(xFilial("ZZ8") + SB1->B1_YCLASSE ))

	ZZ9->(dbSetOrder(2))
	ZZ9->(dbSeek(xFilial("ZZ9") + GU04->PRODUT + GU04->LOTEPR ))
	
	If MV_PAR01 == "2"
	
		oExcel:AddRow(nxPlan, nxTabl, { ZZ6->ZZ6_DESC, GU04->PRODUT, GU04->DESCR, GU04->LOTEPR, GU04->ALMOX, ZZ9->ZZ9_RESTRI, dtoc(stod(GU04->ULTDATA)), dtoc(stod(GU04->PRIPROD)), GU04->QECOSIS, GU04->QPDEVOL, GU04->QPAP, GU04->QPMEC, GU04->QZZZZ, GU04->QOUTROS, Round(GU04->QECOSIS,2) - Round(GU04->QPDEVOL,2) - Round(GU04->QPAP,2) - Round(GU04->QPMEC,2) - Round(GU04->QZZZZ,2) - Round(GU04->QOUTROS,2), ZZ8->ZZ8_DESC, yhStatus, SB1->B1_CONV, ZZ9->ZZ9_DIVPA })
	
	Else
	
		oExcel:AddRow(nxPlan, nxTabl, { ZZ6->ZZ6_DESC, GU04->PRODUT, GU04->DESCR, GU04->LOTEPR, GU04->ALMOX, ZZ9->ZZ9_RESTRI, GU04->QECOSIS, GU04->QPROT, Round(GU04->QECOSIS,2) - Round(GU04->QPROT,2) , ZZ8->ZZ8_DESC, yhStatus, SB1->B1_CONV, ZZ9->ZZ9_DIVPA })
	
	EndIf
	dbSelectArea("GU04")
	dbSkip()
	
End

GU04->(dbCloseArea())
Ferase(GUcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(GUcIndex+OrdBagExt())          //indice gerado

cNewPath := "C:\Temp\"
If !lIsDir( cNewPath )
	MakeDir( cNewPath )
EndIf

xArqTemp := "saldoestoque - "+cEmpAnt

If File("C:\TEMP\"+xArqTemp+".xml")
	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf
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

Static Function ValidPerg()

	local cLoad	    := "BIA506" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local aOpcs 	:= {"1=Amostra","2=Produto Acabado"}
	local aAlmox    := {"1= Almox 02","2=Almox 04","3=Ambos"}
	local lRet		:= .F.
	Local aPergs	:= {}

	MV_PAR01 := "2"
	MV_PAR02 := "3"
	
	aAdd( aPergs ,{2,"Amostra" 	,MV_PAR01 ,aOpcs,60,'.T.',.F.})
	aAdd( aPergs ,{2,"Almoxarifado" ,MV_PAR02 ,aAlmox,60,'.T.',.F.})

	If ParamBox(aPergs ,"Saldo em Estoque ( Ecosis x Protheus )",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02) 

	EndIf

Return lRet
