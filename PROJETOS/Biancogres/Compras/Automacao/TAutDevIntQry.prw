#include "totvs.ch"
#include "parmtype.ch"

/*/{Protheus.doc} TAutDevIntQry
@author Marinaldo de Jesus (Facile)
@since 12/03/2021
@project Automação Entrada
@version 1.0
@description 
@type Class
/*/

class TAutDevIntQry
    static method GetDocOri(cDoc as character,cSerie as character,cCliente as character,cLoja as character,cCodFor as character,cLojaFor as character) as character
    static method ProcessaDevolucao(cCodigosCli as character) as character
end class

static method GetDocOri(cDoc,cSerie,cCliente,cLoja,cCodFor,cLojaFor) class TAutDevIntQry

    local cQuery    as character

    local cDSSize   as character

    local cSC9Table as character
    local cSD1Table as character
    local cSD2Table as character

    local cSC9Filial as character
    local cSD1Filial as character
    local cSD2Filial as character

    local nDSSize as numeric

    paramtype cDoc as character
    paramtype cSerie as character
    paramtype cCliente as character
    paramtype cLoja as character
    paramtype cCodFor as character
    paramtype cLojaFor as character

    cSC9Table:=retSQLName("SC9")
    cSC9Table:="%"+cSC9Table+"%"

    cSD1Table:=retSQLName("SD1")
    cSD1Table:="%"+cSD1Table+"%"

    cSD2Table:=retSQLName("SD2")
    cSD2Table:="%"+cSD2Table+"%"

    cSC9Filial:=xFilial("SC9")
    cSD1Filial:=xFilial("SD1")
    cSD2Filial:=xFilial("SD2")

    nDSSize:=getSX3Cache("D1_DOC","X3_TAMANHO")
    nDSSize+=getSX3Cache("D1_SERIE","X3_TAMANHO")
    cDSSize:=cValToChar(nDSSize)
    cDSSize:="%"+cDSSize+"%"

    cQuery:=""

    beginContent var cQuery

        SELECT SD1_O.R_E_C_N_O_ SD1RECNO
        FROM %exp:cSD2Table% SD2
        JOIN %exp:cSD1Table% SD1 ON (
                                        SD1.D_E_L_E_T_=''
                                    AND SD2.D_E_L_E_T_=''
                                    AND SD1.D1_FILIAL=SD2.D2_FILIAL
                                    AND SD1.D1_NFORI=SD2.D2_DOC
                                    AND SD1.D1_SERIORI=SD2.D2_SERIE
                                    AND SD1.D1_FORNECE=SD2.D2_CLIENTE
                                    AND SD1.D1_LOJA=SD2.D2_LOJA
        )
        JOIN %exp:cSC9Table% SC9 ON (
                                    SC9.D_E_L_E_T_=''
                                AND SC9.C9_FILIAL=SD2.D2_FILIAL
                                AND SC9.C9_NFISCAL=SD2.D2_DOC
                                AND SC9.C9_SERIENF=SD2.D2_SERIE
                                AND SC9.C9_CLIENTE=SD2.D2_CLIENTE
                                AND SC9.C9_LOJA=SD2.D2_LOJA
                                AND SC9.C9_PRODUTO=SD2.D2_COD
                                AND SC9.C9_PEDIDO=SD2.D2_PEDIDO
        )
        JOIN %exp:cSD1Table% SD1_O ON (
                                        SD1_O.D_E_L_E_T_=''
                                    AND SC9.D_E_L_E_T_=''
                                    AND SC9.C9_FILIAL=SD1_O.D1_FILIAL
                                    AND SUBSTRING(C9_BLINF,3,%exp:cDSSize%)+%exp:cCodFor%+%exp:cLojaFor%=SD1_O.D1_DOC+SD1_O.D1_SERIE+SD1_O.D1_FORNECE+SD1_O.D1_LOJA
            )
        WHERE (1=1)
        AND SC9.D_E_L_E_T_=''
        AND SD1.D_E_L_E_T_=''
        AND SD1_O.D_E_L_E_T_=''
        AND SD2.D_E_L_E_T_=''
        AND SC9.C9_FILIAL=%exp:cSC9Filial%
        AND SD1.D1_FILIAL=%exp:cSD1Filial%
        AND SD1_O.D1_FILIAL=%exp:cSD1Filial%
        AND SD2.D2_FILIAL=%exp:cSD2Filial%
        AND SD1.D1_DOC=%exp:cDoc%
        AND SD1.D1_SERIE=%exp:cSerie%
        AND SD1.D1_FORNECE=%exp:cCliente%
        AND SD1.D1_LOJA=%exp:cLoja%
        AND EXISTS (
                            SELECT 1
                            FROM %exp:cSD1Table% SD1_P
                            WHERE (1=1)
                            AND SD1_P.D_E_L_E_T_=' '
                            AND SD1_P.D1_FILIAL=SD2.D2_FILIAL
                            AND SD1_P.D1_NFORI=SD2.D2_DOC
                            AND SD1_P.D1_SERIORI=SD2.D2_SERIE
                            AND SD1_P.D1_FORNECE=SD2.D2_CLIENTE
                            AND SD1_P.D1_LOJA=SD2.D2_LOJA
            )

    endContent

    cQuery:=strTran(cQuery,"%exp:cDoc%",valToSQL(cDoc))
    cQuery:=strTran(cQuery,"%exp:cSerie%",valToSQL(cSerie))
    cQuery:=strTran(cQuery,"%exp:cCliente%",valToSQL(cCliente))
    cQuery:=strTran(cQuery,"%exp:cLoja%",valToSQL(cLoja))

    cQuery:=strTran(cQuery,"%exp:cSC9Filial%",valToSQL(cSC9Filial))
    cQuery:=strTran(cQuery,"%exp:cSD1Filial%",valToSQL(cSD1Filial))
    cQuery:=strTran(cQuery,"%exp:cSD2Filial%",valToSQL(cSD2Filial))

    cQuery:=strTran(cQuery,"%exp:cSC9Table%",strTran(cSC9Table,"%",""))
    cQuery:=strTran(cQuery,"%exp:cSD1Table%",strTran(cSD1Table,"%",""))
    cQuery:=strTran(cQuery,"%exp:cSD2Table%",strTran(cSD2Table,"%",""))

    cQuery:=strTran(cQuery,"%exp:cDSSize%",strTran(cDSSize,"%",""))

    cQuery:=strTran(cQuery,"%exp:cCodFor%",valToSQL(cCodFor))
    cQuery:=strTran(cQuery,"%exp:cLojaFor%",valToSQL(cLojaFor))

    return(cQuery)

static method ProcessaDevolucao(cCodigosCli) class TAutDevIntQry

    local cSQL  as character

    paramtype cCodigosCli as character

	cSQL := ""
    
    cSQL += " SELECT D1_FILIAL, D1_LOCAL, F1_COND, F1_FORMUL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_COD, D1_QUANT, "
	cSQL += " 		 D1_TES, D1_ITEM, D1_VUNIT, D1_TOTAL, D1_LOTECTL, D1_DTVALID, D1_PEDIDO, D1_ITEMPV, D2_LOTECTL, C5_YEMPPED, C5_YPEDORI, C6_LOCAL, C6_ITEM "
	cSQL += " FROM " + RetSQLName("SF1") + " SF1 ( NOLOCK ) "

	cSQL += " JOIN " + RetSQLName("SD1") + " SD1 (NOLOCK) ON "
	cSQL += " ( "
	cSQL += " 	SD1.D1_FILIAL 		= SF1.F1_FILIAL "
	cSQL += " 	AND SD1.D1_DOC 		= SF1.F1_DOC "
	cSQL += " 	AND SD1.D1_SERIE 	= SF1.F1_SERIE "
	cSQL += " 	AND SD1.D1_FORNECE 	= SF1.F1_FORNECE "
	cSQL += " 	AND SD1.D1_LOJA 	= SF1.F1_LOJA "
	cSQL += " 	AND SD1.D_E_L_E_T_	= '' "
	cSQL += " ) "

	cSQL += " JOIN " + RetSQLName("SD2") + " SD2 (NOLOCK) ON "
	cSQL += " ( "
	cSQL += " 	SD1.D1_FILIAL 		= SD2.D2_FILIAL "
	cSQL += " 	AND SD1.D1_NFORI	= SD2.D2_DOC "
	cSQL += " 	AND SD1.D1_SERIORI 	= SD2.D2_SERIE "
	cSQL += " 	AND SD1.D1_FORNECE 	= SD2.D2_CLIENTE "
	cSQL += " 	AND SD1.D1_LOJA 	= SD2.D2_LOJA "
	cSQL += " 	AND SD1.D1_ITEMORI 	= SD2.D2_ITEM "
	cSQL += " 	AND SD2.D_E_L_E_T_	= '' "
	cSQL += " ) "

	cSQL += " JOIN " + RetSQLName("SC5") + " SC5 (NOLOCK) ON "
	cSQL += " ( "
	cSQL += " 	SC5.C5_FILIAL 		= SD2.D2_FILIAL "
	cSQL += " 	AND SC5.C5_NUM 		= SD2.D2_PEDIDO "
	cSQL += " 	AND SC5.D_E_L_E_T_	= '' "
	cSQL += " ) "

	cSQL += " JOIN " + RetSQLName("SC6") + " SC6 (NOLOCK) ON "
	cSQL += " ( "
	cSQL += " 	SC6.C6_FILIAL 		= SD2.D2_FILIAL "
	cSQL += " 	AND SC6.C6_NUM 		= SD2.D2_PEDIDO "
	cSQL += " 	AND SC6.C6_ITEM		= SD2.D2_ITEMPV "
	cSQL += " 	AND SC6.D_E_L_E_T_	= '' "
	cSQL += " ) "

	cSQL += " WHERE SF1.F1_FILIAL 	= " + ValToSql(xFilial("SF1"))
	cSQL += " AND F1_TIPO   	    = 'D' "
	cSQL += " AND C5_YEMPPED        <> '' "
	cSQL += " AND D1_EMISSAO        >= '"+DtoS(getNewPar("BIA_DTIICP",CToD("07/01/2021")))+"' " // TO DO: COLOCAR DATA PARA SUBIDA.
	cSQL += " AND D1_FORNECE    NOT IN " + FormatIn(cCodigosCli, "/")

	cSQL += " AND NOT EXISTS "
	cSQL += " ( "
	cSQL += "   SELECT NULL "
	cSQL += "   FROM " + RetSQLName("ZL9") + " ZL9 (NOLOCK) "
	cSQL += "   WHERE ZL9.ZL9_FILIAL    = " + ValToSql(xFilial("ZL9"))
	cSQL += "   AND ZL9.ZL9_CODEMP 	    = " + ValToSql(cEmpAnt)
	cSQL += "   AND ZL9.ZL9_CODFIL 	    = " + ValToSql(cFilAnt)
	cSQL += "   AND ZL9.ZL9_DOCDEV 	    = SF1.F1_DOC "
	cSQL += "   AND ZL9.ZL9_SERDEV 	    = SF1.F1_SERIE "
	cSQL += "   AND ZL9.ZL9_CLIDEV      = SF1.F1_FORNECE "
	cSQL += "   AND ZL9.ZL9_LOJDEV 	    = SF1.F1_LOJA "
	cSQL += "   AND ZL9.ZL9_STATUS IN ('4','F') "
	cSQL += "   AND ZL9.D_E_L_E_T_	    = '' "
	cSQL += " ) "

	cSQL += " AND SF1.D_E_L_E_T_ = '' "

    return(cSQL)
