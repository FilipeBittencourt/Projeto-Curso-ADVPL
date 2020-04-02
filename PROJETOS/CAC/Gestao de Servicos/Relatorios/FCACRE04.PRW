#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"   


#Define CRLF chr(13)+chr(10)

/*
##############################################################################################################
# PROGRAMA...: FCACRE04         
# AUTOR......: Luiz Guilherme Barcellos (FACILE SISTEMAS)
# DATA.......: 17/06/2015                      
# DESCRICAO..: Relatório de Itens Empenhados
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/
User Function FCACRE04()                

	Private _cNomRel := "FCACRE04"
	Private _cTitRel := "Relatório de Itens Empenhados"
	
	AjustaSX1(_cNomRel)
	oReport := ReportDef()
	oReport :PrintDialog()

Return


Static Function ReportDef()
	
	oReport := TReport():New(_cNomRel, _cTitRel, _cNomRel, {|oReport| ReportPrint(oReport)}, _cTitRel)
	oReport:SetPortrait() // Retrato 
	//oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:SetLineHeight(40)
	oReport:SetColSpace(1)
	oReport:SetLeftMargin(1)
	oReport:oPage:SetPageNumber(1)
	oReport:nFontBody := 8 // Tamanho Fonte
	oReport:lBold := .T.
	oReport:lUnderLine := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .F.

	Pergunte(_cNomRel, .F.)
	
	oSection1 := TRSection():New(oReport, "Equipamentos", {}) 
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1, "CODCLI"  ,	, "Cod. Cliente",,         20, .F.)
	TRCell():New(oSection1, "NOMCLI"  ,	, "Nome Cliente",,         40, .F.)
	TRCell():New(oSection1, "CODEQUIP", , "Cod. Equip."	,,         18, .F.)
	TRCell():New(oSection1, "NOMEQUIP", , "Nome Equip."	,,         40, .F.)
	TRCell():New(oSection1, "NUMSER"  ,	, "Núm. Série"	,,         20, .F.)
    
	oSection2 := TRSection():New(oSection1, "Atendimentos", {}) 
	oSection2:SetTotalInLine(.F.)	
	TRCell():New(oSection2, "OS"		, , "O.S."		 ,,12, .F.) 
	TRCell():New(oSection2, "PEDIDO"	, , "Pedido"	 ,,12, .F.)
	TRCell():New(oSection2, "EMISSAO"	, , "Data"		 ,,18, .F.)
	TRCell():New(oSection2, "ATENDENTE"	, , "Responsável",,30, .F.)
	
	oSection3 := TRSection():New(oSection2, "Itens", {}) 
	oSection3:SetTotalInLine(.F.)
	
	TRCell():New(oSection3, "CODITEM" 	, , "Código"	 ,,20, .F.)
	TRCell():New(oSection3, "NOMEITEM"	, , "Descrição" ,,50, .F.)
	TRCell():New(oSection3, "QUANT"		, , "Quantidade" 	 ,,15, .F.)
	TRCell():New(oSection3, "VALOR"		, , "Vlr. Unit." ,"@E 999,999.99",15,,,,,"RIGHT")
	TRCell():New(oSection3, "TOTAL"		, , "Total"		 ,"@E 999,999.99",15,,,,,"RIGHT")

Return(oReport)


Static Function ReportPrint(oReport)
	Local _cSerAnt := "" 
	lOCAL _cCliente	:= ""
	Local _cOsAnt := ""
	Local _nTotCli := 0.00
	Local _nTotal := 0.00
	Local lImpApont := .t.

	oSection1 := oReport:Section(1)
	oSection2 := oReport:Section(1):Section(1)
	oSection3 := oReport:Section(1):Section(1):Section(1)
	
	_cSql:= "SELECT C5_CLIENTE, C5_LOJACLI, A1_NOME, AB8_CODPRD, B1_DESC, AB8_NUMSER, AB8_NUMOS, C5_NUM, C5_EMISSAO, AB6_ATEND,"
	_cSql:= _cSql+CRLF+"	AB8_CODPRO, AB8_DESPRO, AB8_VUNIT, AB8_QUANT, AB8_TOTAL"
	_cSql:= _cSql+CRLF+"FROM "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) "
	_cSql:= _cSql+CRLF+"	INNER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"	INNER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SC5.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"	INNER JOIN "+RetSqlName("AB8")+" AB8 WITH(NOLOCK) ON AB8.AB8_NUMOS+AB8.AB8_ITEM+AB8.AB8_SUBITE = SC6.C6_NUMOS AND AB8.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"	INNER JOIN "+RetSqlName("AB6")+" AB6 WITH(NOLOCK) ON AB6.AB6_NUMOS = AB8.AB8_NUMOS AND AB6.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"	INNER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SB1.B1_COD = AB8.AB8_CODPRD AND SB1.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"WHERE SC5.C5_LIBEROK='S' AND SC6.C6_NOTA='' AND C6_BLQ = ''"
	_cSql:= _cSql+CRLF+"	AND C5_CLIENTE+C5_LOJACLI BETWEEN '"+MV_PAR01+MV_PAR02+"' AND '"+MV_PAR03+MV_PAR04+"'"
	_cSql:= _cSql+CRLF+"	AND C5_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"'"
	_cSql:= _cSql+CRLF+"	AND SC5.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"ORDER BY C5_CLIENTE, C5_LOJACLI, AB8_CODPRD, AB8_NUMSER, AB8_NUMOS"
	
	If select("TRB")>0
		TRB->(DbCloseArea())
	Endif
	
	TCQUERY _cSql NEW ALIAS "TRB"
                         
	While TRB->(!EOF())	    
	    IF TRB->AB8_NUMSER <> _cSerAnt
			oSection1:Finish()
		    oSection2:Finish()		    				    			
			If !empty(_cCliente) .AND. _cCliente <> TRB->(C5_CLIENTE+C5_LOJACLI)
				oReport:skipline()
				oReport:printtext("TOTAL CLIENTE : R$" + TRANSFORM(_nTotCli,"@E 999,999.99"))				
				_nTotCli := 0.00
				oReport:EndPage()
			Endif
			oReport:nFontBody := 10			
			oSection1:Init()
			oSection1:Cell("CODEQUIP"):SetValue(TRB->AB8_CODPRD)
			oSection1:Cell("NOMEQUIP"):SetValue(TRB->B1_DESC)
			oSection1:Cell("NUMSER"):SetValue(TRB->AB8_NUMSER)
			
			oSection1:Cell("CODCLI"):SetValue(TRB->C5_CLIENTE+"/"+TRB->C5_LOJACLI)
			oSection1:Cell("NOMCLI"):SetValue(TRB->A1_NOME)
		    oSection1:PrintLine() 
		    oReport:nFontBody := 8
		    
		    oSection2:Init()
		    
	    EndIf 
	    
	    IF TRB->AB8_NUMOS <> _cOsAnt
	    	oSection2:Finish()
	    	oSection2:Init()
	    	
	    	oSection2:Cell("OS"):SetValue(TRB->AB8_NUMOS) 
			oSection2:Cell("PEDIDO"):SetValue(TRB->C5_NUM)
			oSection2:Cell("EMISSAO"):SetValue(DTOC(STOD(TRB->C5_EMISSAO))) 
			oSection2:Cell("ATENDENTE"):SetValue(Alltrim(TRB->AB6_ATEND))
	    	oSection2:PrintLine()
	    	
	    	oSection3:Finish()
	    	oSection3:Init()
	    Endif 		 
		
		oSection3:Cell("CODITEM"):SetValue(TRB->AB8_CODPRO)
		oSection3:Cell("NOMEITEM"):SetValue(TRB->AB8_DESPRO)		
		oSection3:Cell("QUANT"):SetValue(ALLTRIM(STR(TRB->AB8_QUANT)))
		oSection3:Cell("VALOR"):SetValue(TRB->AB8_VUNIT)
		oSection3:Cell("TOTAL"):SetValue(TRB->AB8_TOTAL)
		oSection3:PrintLine() 
	    
	    _cCliente	:= TRB->(C5_CLIENTE+C5_LOJACLI)
	    _cSerAnt	:= TRB->AB8_NUMSER
	    _cOsAnt		:= TRB->AB8_NUMOS
	    
	    _nTotCli	+= TRB->AB8_TOTAL
	    _nTotal		+= TRB->AB8_TOTAL
		
		TRB->(DbSkip())
	EndDo
	
	oReport:skipline()
	oReport:printtext("TOTAL CLIENTE : R$" + TRANSFORM(_nTotCli,"@E 999,999.99"))
	
	oReport:FatLine()

	oReport:skipline()
	oReport:printtext("TOTAL GERAL   : R$" + TRANSFORM(_nTotal ,"@E 999,999.99"))

    oSection2:Finish()
	oSection1:Finish()
	
	TRB->(DbCloseArea())

Return Nil

*-----------------------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para Ajustar as Perguntas conforme necessidade do Relatorio //
////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
	
	PutSx1(cPerg, "01", "Cliente de:              ", "", "", "mv_ch1", "C", 06, 00, 0, "G",""            ,"SA1"  ,"", " ", "MV_PAR01", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "02", "Loja de:                 ", "", "", "mv_ch2", "C", 02, 00, 0, "G",""            ,""     ,"", " ", "MV_PAR02", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "03", "Cliente até:             ", "", "", "mv_ch3", "C", 06, 00, 0, "G","NaoVazio()"  ,"SA1"  ,"", " ", "MV_PAR03", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "04", "Loja até:                ", "", "", "mv_ch4", "C", 02, 00, 0, "G","NaoVazio()"  ,""     ,"", " ", "MV_PAR04", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")	
	
	PutSx1(cPerg, "05", "Emissão De  :    ", "", "", "mv_ch5", "D", 08, 00, 0, "G","NaoVazio()"  , ""    ,"", " ", "MV_PAR05", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "06", "Emissão Até :    ", "", "", "mv_ch6", "D", 08, 00, 0, "G","NaoVazio()"  , ""    ,"", " ", "MV_PAR06", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------------------  