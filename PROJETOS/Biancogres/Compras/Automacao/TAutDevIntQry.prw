#include "totvs.ch"
#include "parmtype.ch"

static __cCRLF  as character

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
    static method DocOriCmpAut(nZL9RecNo) as character
    static method ProcessaSaida() as character
    static method fDistribui(cDoc,cSerie,cCliente,cLoja) as character
    static method FaturarPedido() as character
    static method GetEndereco(cCodCli,cLojaCli,cDoc,cSerie) as character
    static method GetProcDev(nZL9RecNo) as character
end class

static method GetDocOri(cDoc,cSerie,cCliente,cLoja,cCodFor,cLojaFor) class TAutDevIntQry

    local cSQL    as character

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

    beginContent var cSQL

        SELECT DISTINCT SD1_O.R_E_C_N_O_ SD1RECNO
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

    cSQL:=strTran(cSQL,"%exp:cDoc%",valToSQL(cDoc))
    cSQL:=strTran(cSQL,"%exp:cSerie%",valToSQL(cSerie))
    cSQL:=strTran(cSQL,"%exp:cCliente%",valToSQL(cCliente))
    cSQL:=strTran(cSQL,"%exp:cLoja%",valToSQL(cLoja))

    cSQL:=strTran(cSQL,"%exp:cSC9Filial%",valToSQL(cSC9Filial))
    cSQL:=strTran(cSQL,"%exp:cSD1Filial%",valToSQL(cSD1Filial))
    cSQL:=strTran(cSQL,"%exp:cSD2Filial%",valToSQL(cSD2Filial))

    cSQL:=strTran(cSQL,"%exp:cSC9Table%",strTran(cSC9Table,"%",""))
    cSQL:=strTran(cSQL,"%exp:cSD1Table%",strTran(cSD1Table,"%",""))
    cSQL:=strTran(cSQL,"%exp:cSD2Table%",strTran(cSD2Table,"%",""))

    cSQL:=strTran(cSQL,"%exp:cDSSize%",strTran(cDSSize,"%",""))

    cSQL:=strTran(cSQL,"%exp:cCodFor%",valToSQL(cCodFor))
    cSQL:=strTran(cSQL,"%exp:cLojaFor%",valToSQL(cLojaFor))

    return(cSQL)

static method ProcessaDevolucao(cCodigosCli) class TAutDevIntQry

    local cSQL  as character
    local cCRLF as character

    paramtype cCodigosCli as character

	cSQL:= ""

    DEFAULT __cCRLF:=CRLF    
    cCRLF:=__cCRLF
    
    cSQL+=" SELECT D1_FILIAL"+cCRLF
    cSQL+=" 	    ,D1_LOCAL"+cCRLF
    cSQL+=" 	    ,F1_COND"+cCRLF
    cSQL+=" 		,F1_FORMUL"+cCRLF
    cSQL+=" 		,D1_DOC"+cCRLF
    cSQL+=" 		,D1_SERIE"+cCRLF
    cSQL+=" 		,D1_FORNECE"+cCRLF
    cSQL+=" 		,D1_LOJA"+cCRLF
    cSQL+=" 		,D1_EMISSAO"+cCRLF
    cSQL+=" 		,D1_COD"+cCRLF
    cSQL+=" 		,D1_QUANT"+cCRLF
	cSQL+=" 		,D1_TES"+cCRLF
    cSQL+=" 		,D1_ITEM"+cCRLF
    cSQL+=" 		,D1_VUNIT"+cCRLF
    cSQL+=" 		,D1_TOTAL"+cCRLF
    cSQL+=" 		,D1_LOTECTL"+cCRLF
    cSQL+=" 		,D1_DTVALID"+cCRLF
    cSQL+=" 		,D1_PEDIDO"+cCRLF
    cSQL+=" 		,D1_ITEMPV"+cCRLF
    cSQL+=" 		,D2_LOTECTL"+cCRLF
    cSQL+=" 		,C5_YEMPPED"+cCRLF
    cSQL+=" 		,C5_YPEDORI"+cCRLF
    cSQL+=" 		,C6_LOCAL"+cCRLF
    cSQL+=" 		,C6_ITEM"+cCRLF
	cSQL+=" FROM "+RetSQLName("SF1")+" SF1 ( NOLOCK )"+cCRLF

	cSQL+=" JOIN "+RetSQLName("SD1")+" SD1 (NOLOCK) ON"+cCRLF
	cSQL+=" ( "+cCRLF
	cSQL+=" 	SD1.D1_FILIAL=SF1.F1_FILIAL"+cCRLF
	cSQL+=" 	AND SD1.D1_DOC=SF1.F1_DOC"+cCRLF
	cSQL+=" 	AND SD1.D1_SERIE=SF1.F1_SERIE"+cCRLF
	cSQL+=" 	AND SD1.D1_FORNECE=SF1.F1_FORNECE"+cCRLF
	cSQL+=" 	AND SD1.D1_LOJA=SF1.F1_LOJA"+cCRLF
	cSQL+=" 	AND SD1.D_E_L_E_T_=''"+cCRLF
	cSQL+=" ) "+cCRLF

	cSQL+=" JOIN "+RetSQLName("SD2")+" SD2 (NOLOCK) ON"+cCRLF
	cSQL+=" ( "+cCRLF
	cSQL+=" 	SD1.D1_FILIAL=SD2.D2_FILIAL"+cCRLF
	cSQL+=" 	AND SD1.D1_NFORI=SD2.D2_DOC"+cCRLF
	cSQL+=" 	AND SD1.D1_SERIORI=SD2.D2_SERIE"+cCRLF
	cSQL+=" 	AND SD1.D1_FORNECE=SD2.D2_CLIENTE"+cCRLF
	cSQL+=" 	AND SD1.D1_LOJA=SD2.D2_LOJA"+cCRLF
	cSQL+=" 	AND SD1.D1_ITEMORI=SD2.D2_ITEM"+cCRLF
	cSQL+=" 	AND SD2.D_E_L_E_T_=''"+cCRLF
	cSQL+=" ) "+cCRLF

	cSQL+=" JOIN "+RetSQLName("SC5")+" SC5 (NOLOCK) ON"+cCRLF
	cSQL+=" ( "+cCRLF
	cSQL+=" 	SC5.C5_FILIAL=SD2.D2_FILIAL"+cCRLF
	cSQL+=" 	AND SC5.C5_NUM=SD2.D2_PEDIDO"+cCRLF
	cSQL+=" 	AND SC5.D_E_L_E_T_= '' "+cCRLF
	cSQL+=" ) "+cCRLF

	cSQL+=" JOIN "+RetSQLName("SC6")+" SC6 (NOLOCK) ON "+cCRLF
	cSQL+=" ( "+cCRLF
	cSQL+=" 	SC6.C6_FILIAL=SD2.D2_FILIAL"+cCRLF
	cSQL+=" 	AND SC6.C6_NUM=SD2.D2_PEDIDO"+cCRLF
	cSQL+=" 	AND SC6.C6_ITEM=SD2.D2_ITEMPV"+cCRLF
	cSQL+=" 	AND SC6.D_E_L_E_T_=''"+cCRLF
	cSQL+=" ) "+cCRLF

	cSQL+=" WHERE SF1.F1_FILIAL=" + ValToSql(xFilial("SF1"))+cCRLF
	cSQL+="   AND F1_TIPO='D'"+cCRLF
	cSQL+="   AND C5_YEMPPED<>'' "+cCRLF
	cSQL+="   AND D1_EMISSAO>='"+DtoS(getNewPar("BIA_DTIICP",CToD("07/01/2021")))+"' "+cCRLF // TO DO: COLOCAR DATA PARA SUBIDA.
	cSQL+="   AND D1_FORNECE NOT IN " + FormatIn(cCodigosCli, "/")+cCRLF

	cSQL+=" AND NOT EXISTS"+cCRLF
	cSQL+=" ( "+cCRLF
	cSQL+="   SELECT NULL"+cCRLF
	cSQL+="    FROM "+RetSQLName("ZL9")+" ZL9 (NOLOCK) "+cCRLF
	cSQL+="   WHERE ZL9.ZL9_FILIAL="+ValToSql(xFilial("ZL9"))+cCRLF
	cSQL+="     AND ZL9.ZL9_CODEMP="+ValToSql(cEmpAnt)+cCRLF
	cSQL+="     AND ZL9.ZL9_CODFIL="+ValToSql(cFilAnt)+cCRLF
	cSQL+="     AND ZL9.ZL9_DOCDEV=SF1.F1_DOC"+cCRLF
	cSQL+="     AND ZL9.ZL9_SERDEV=SF1.F1_SERIE"+cCRLF
	cSQL+="     AND ZL9.ZL9_CLIDEV=SF1.F1_FORNECE"+cCRLF
	cSQL+="     AND ZL9.ZL9_LOJDEV=SF1.F1_LOJA"+cCRLF
	cSQL+="     AND ZL9.ZL9_STATUS IN ('4','F') "+cCRLF
	cSQL+="     AND ZL9.D_E_L_E_T_='' "+cCRLF
	cSQL+=" ) "+cCRLF

	cSQL+=" AND SF1.D_E_L_E_T_ = '' "+cCRLF

    cSQL+="ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,C5_YEMPPED,D1_ITEM"+cCRLF

    return(cSQL)

static method DocOriCmpAut(nZL9RecNo) class TAutDevIntQry

    static oDocOriCmpAut as object

    local aTipos    as array

    local cSQL      as character

    paramtype nZL9RecNo as numeric optional DEFAULT ZL9->(RecNo())

    if (!(valtype(oDocOriCmpAut)=="O"))
        
        beginContent var cSQL
            SELECT R_E_C_N_O_ SE2RECNO
              FROM [?] SE2 WITH (NOLOCK)
             WHERE (
                    ((SE2.E2_NUM=?) AND (SE2.E2_PREFIXO=?) AND (SE2.E2_TIPO='NF ') AND (SE2.E2_BAIXA=' ') AND (SE2.E2_SALDO>0))
                    OR
                    ((SE2.E2_NUM=?) AND (SE2.E2_PREFIXO=?) AND (SE2.E2_TIPO='NDF') AND (SE2.E2_BAIXA=' '))
              )
               AND (SE2.D_E_L_E_T_=' ')
               AND (SE2.E2_FORNECE=?)
               AND (SE2.E2_LOJA=?)
               AND (SE2.E2_TIPO IN (?))
               AND (SE2.E2_FILIAL=(?))
        endContent

        oDocOriCmpAut:=FWPreparedStatement():New(cSQL)

    endif

    ZL9->(MsGoTo(nZL9RecNo))

    oDocOriCmpAut:setString(1,retSQLName("SE2"))
    
    oDocOriCmpAut:setString(2,ZL9->ZL9_DOCORI)
    oDocOriCmpAut:setString(3,ZL9->ZL9_SERORI)

    oDocOriCmpAut:setString(4,ZL9->ZL9_DOCDEV)
    oDocOriCmpAut:setString(5,ZL9->ZL9_SERDEV)

    oDocOriCmpAut:setString(6,ZL9->ZL9_FORNEC)
    oDocOriCmpAut:setString(7,ZL9->ZL9_LOJFOR)
    
    aTipos:={"NF "/*,"PA "*/,"NDF"}
    oDocOriCmpAut:SetIn(8,aTipos)

    oDocOriCmpAut:setString(9,xFilial("SE2"))

    cSQL:=oDocOriCmpAut:GetFixQuery()
    
    cSQL:=strTran(cSQL,"['","[")
    cSQL:=strTran(cSQL,"']","]")

    return(cSQL)

static method ProcessaSaida() class TAutDevIntQry

    local cSQL

    DEFAULT __cCRLF:=CRLF

    cSQL:=" SELECT ZL9.R_E_C_N_O_ ZL9RECNO "+__cCRLF
    cSQL+="   FROM "+RetSQLName("ZL9")+" ZL9 ( NOLOCK )"+__cCRLF
    cSQL+="  WHERE ZL9.ZL9_FILIAL ="+ValToSql(xFilial("ZL9"))+__cCRLF
    cSQL+="    AND ZL9.ZL9_CODEMP ="+ValToSql(cEmpAnt)+__cCRLF
    cSQL+="    AND ZL9.ZL9_CODFIL ="+ValToSql(cFilAnt)+__cCRLF
    cSQL+="    AND ( "+__cCRLF
    cSQL+="           ( ZL9.ZL9_STADOC NOT IN ( '5','8' ) ) "+__cCRLF // 1=Emitida;2=Transmitida;3=Autorizada;4=Rejeitada;5=Cancelada;6=PDF criado;7=PDF enviado;8=Finalizado
    cSQL+=" 		    OR "+__cCRLF
    cSQL+=" 			( "+__cCRLF
    cSQL+=" 				ZL9.ZL9_STADOC <> '5' AND "+__cCRLF
    cSQL+=" 				ZL9.ZL9_DOC <> '' AND "+__cCRLF
    cSQL+=" 				NOT EXISTS "+__cCRLF
    cSQL+=" 				( "+__cCRLF
    cSQL+=" 					SELECT NULL "+__cCRLF
    cSQL+=" 					FROM "+RetSQLName("SF2")+" SF2 "+__cCRLF
    cSQL+=" 					WHERE SF2.F2_FILIAL ="+ValToSql(xFilial("SF2"))+__cCRLF
    cSQL+=" 					AND SF2.F2_DOC 		=ZL9.ZL9_DOC "+__cCRLF
    cSQL+=" 					AND SF2.F2_SERIE 	=ZL9.ZL9_SERIE "+__cCRLF
    cSQL+=" 					AND SF2.D_E_L_E_T_ 	=''"+__cCRLF
    cSQL+=" 				) "+__cCRLF
    cSQL+=" 			) "+__cCRLF
    cSQL+="	 ) "+__cCRLF
    cSQL+="    AND ZL9.D_E_L_E_T_ ='' "+__cCRLF

    return(cSQL)

static method fDistribui(cDoc,cSerie,cCliente,cLoja) class TAutDevIntQry

    local cSQL  as character

    DEFAULT __cCRLF:=CRLF

    cSQL:=" SELECT SDA.R_E_C_N_O_ SDARECNO "+__cCRLF
    cSQL+="   FROM "+RetSQLName("SDA")+" SDA ( NOLOCK ) "+__cCRLF
    cSQL+="  WHERE SDA.DA_FILIAL 	="+ValToSql(xFilial("SDA"))+__cCRLF
    cSQL+="    AND SDA.DA_TIPONF	='D' "+__cCRLF
    cSQL+="    AND SDA.DA_ORIGEM 	='SD1' "+__cCRLF
    cSQL+="    AND SDA.DA_DOC 	="+ValToSql(cDoc)+__cCRLF
    cSQL+="    AND SDA.DA_SERIE   ="+ValToSql(cSerie)+__cCRLF
    cSQL+="    AND SDA.DA_CLIFOR 	="+ValToSql(cCliente)+__cCRLF
    cSQL+="    AND SDA.DA_LOJA 	="+ValToSql(cLoja)+__cCRLF
    cSQL+="    AND SDA.D_E_L_E_T_ ='' "+__cCRLF

    return(cSQL)

static method FaturarPedido() class TAutDevIntQry

    local cSQL as character

    DEFAULT __cCRLF:=CRLF

    cSQL:=" SELECT * "+__cCRLF
    cSQL+=" FROM "+RetSQLName("ZL9")+" ZL9 ( NOLOCK ) "+__cCRLF
    cSQL+=" WHERE ZL9.ZL9_FILIAL 	="+ValToSql(xFilial("ZL9"))+__cCRLF
    cSQL+=" AND ZL9.ZL9_CODEMP    ="+ValToSql(cEmpAnt)+__cCRLF
    cSQL+=" AND ZL9.ZL9_CODFIL    ="+ValToSql(cFilAnt)+__cCRLF
    cSQL+=" AND ZL9.ZL9_STATUS    ='3' " +__cCRLF// Devolucao Intercompany - Pedido Gerado
    cSQL+=" AND ZL9.ZL9_STAERR   <> 'E' "+__cCRLF
    cSQL+=" AND ZL9.ZL9_MSBLQL   <> '1' "+__cCRLF
    cSQL+=" AND ZL9.ZL9_DOC       ='' "+__cCRLF
    cSQL+=" AND ZL9.D_E_L_E_T_    ='' "+__cCRLF

    return(cSQL)

static method GetEndereco(cCodCli,cLojaCli,cDoc,cSerie,cItem) class TAutDevIntQry

    static oGetEndereco as object

    local cSQL as character

    paramtype nZL9RecNo as numeric optional DEFAULT ZL9->(RecNo())

    if (!(valtype(oGetEndereco)=="O"))

        beginContent var cSQL

              SELECT 
            DISTINCT Z25.R_E_C_N_O_ Z25RECNO
                  ,Z26.R_E_C_N_O_   Z26RECNO
              FROM [?] Z25
              JOIN [?] Z26 ON(
                    Z25.Z25_FILIAL=Z26.Z26_FILIAL
                AND Z25.Z25_NUM=Z26.Z26_NUMPRC
            )
              JOIN [?] SD1 ON(
                 SD1.D1_FILIAL=Z26.Z26_FILIAL
             AND SD1.D1_NFORI=Z26.Z26_NFISC
             AND SD1.D1_SERIORI=Z26.Z26_SERIE
             AND SD1.D1_ITEMORI=Z26.Z26_ITEMNF
             AND SD1.D1_COD=Z26.Z26_PROD
             AND SD1.D1_QUANT=Z26.Z26_QTDORI
            )
              JOIN [?] SF1 ON(
                    SF1.F1_FILIAL=SD1.D1_FILIAL
                AND SF1.F1_DOC=SD1.D1_DOC
                AND SF1.F1_SERIE=SD1.D1_SERIE
                AND SF1.F1_FORNECE=SD1.D1_FORNECE
                AND SF1.F1_LOJA=SD1.D1_LOJA
            )
            LEFT JOIN [?] ZL9 ON (
                    ZL9.ZL9_FILIAL=' '
                AND ZL9.ZL9_FILORI=SF1.F1_FILIAL
                AND ZL9.ZL9_DOCDEV=SF1.F1_DOC
                AND ZL9.ZL9_SERDEV=SF1.F1_SERIE
                AND ZL9.ZL9_CLIDEV=SF1.F1_FORNECE
                AND ZL9.ZL9_LOJDEV=SF1.F1_LOJA
                AND ZL9.ZL9_PRCDEV=Z25.Z25_NUM
            )
            WHERE Z25.D_E_L_E_T_=' '
              AND Z26.D_E_L_E_T_=' '
              AND SF1.D_E_L_E_T_=' '
              AND SD1.D_E_L_E_T_=' '
              AND Z25.Z25_CODCLI=?
              AND Z25.Z25_LOJCLI=?
              AND Z26.Z26_NFISC=?
              AND Z26.Z26_SERIE=?
              AND Z26.Z26_ITEMNF=?
              AND ( 
                        ( 
                                ZL9.D_E_L_E_T_=' ' 
                            AND ZL9.ZL9_PRCDEV=Z25.Z25_NUM 
                            AND ZL9.ZL9_CODEMP=?
                            AND ZL9.ZL9_CODFIL=?
                        )
                        OR NOT EXISTS(
                                SELECT DISTINCT 1 
                                  FROM [?] ZL9_t
                                 WHERE ZL9_t.D_E_L_E_T_=' '
                                   AND ZL9_t.ZL9_FILIAL=' '
                                   AND ZL9_t.ZL9_CODEMP=?
                                   AND ZL9_t.ZL9_CODFIL=?
                                   AND ZL9_t.ZL9_PRCDEV=Z25.Z25_NUM
                                )
              )
              AND Z26.Z26_ITEMNF<>'XX'

        endContent

        oGetEndereco:=FWPreparedStatement():New(cSQL)

    endif

    oGetEndereco:setString(1,retSQLName("Z25"))
    oGetEndereco:setString(2,retSQLName("Z26"))
    oGetEndereco:setString(3,retSQLName("SD1"))
    oGetEndereco:setString(4,retSQLName("SF1"))
    oGetEndereco:setString(5,retSQLName("ZL9"))

    oGetEndereco:setString(6,cCodCli)
    oGetEndereco:setString(7,cLojaCli)
    oGetEndereco:setString(8,cDoc)
    oGetEndereco:setString(9,cSerie)
    oGetEndereco:setString(10,cItem)

    oGetEndereco:setString(11,&("cEmpAnt"))
    oGetEndereco:setString(12,&("cFilAnt"))

    oGetEndereco:setString(13,retSQLName("ZL9"))
    
    oGetEndereco:setString(14,&("cEmpAnt"))
    oGetEndereco:setString(15,&("cFilAnt"))

    cSQL:=oGetEndereco:GetFixQuery()
    
    cSQL:=strTran(cSQL,"['","[")
    cSQL:=strTran(cSQL,"']","]")

    return(cSQL)

static method GetProcDev(nZL9RecNo) class TAutDevIntQry

    static oGetProcDev as object

    local cSQL as character

    paramtype nZL9RecNo as numeric optional DEFAULT ZL9->(RecNo())

    if (!(valtype(oGetProcDev)=="O"))

        beginContent var cSQL

              SELECT 
            DISTINCT Z25.R_E_C_N_O_ Z25RECNO
                    ,Z26.R_E_C_N_O_ Z26RECNO
                FROM [?] Z25
                JOIN [?] Z26 ON(
                    Z25.Z25_FILIAL=Z26.Z26_FILIAL
                AND Z25.Z25_NUM=Z26.Z26_NUMPRC
                )
                JOIN [?] SD1 ON(
                    SD1.D1_FILIAL=Z26.Z26_FILIAL
                AND SD1.D1_NFORI=Z26.Z26_NFISC
                AND SD1.D1_SERIORI=Z26.Z26_SERIE
                AND SD1.D1_ITEMORI=Z26.Z26_ITEMNF
                AND SD1.D1_COD=Z26.Z26_PROD
                AND SD1.D1_QUANT=Z26.Z26_QTDORI
                )
                JOIN [?] SF1 ON(
                    SF1.F1_FILIAL=SD1.D1_FILIAL
                AND SF1.F1_DOC=SD1.D1_DOC
                AND SF1.F1_SERIE=SD1.D1_SERIE
                AND SF1.F1_FORNECE=SD1.D1_FORNECE
                AND SF1.F1_LOJA=SD1.D1_LOJA
                )
                JOIN [?] ZL9 ON (
                    ZL9.ZL9_FILIAL=' '
                AND ZL9.ZL9_FILORI=SF1.F1_FILIAL
                AND ZL9.ZL9_DOCDEV=SF1.F1_DOC
                AND ZL9.ZL9_SERDEV=SF1.F1_SERIE
                AND ZL9.ZL9_CLIDEV=SF1.F1_FORNECE
                AND ZL9.ZL9_LOJDEV=SF1.F1_LOJA
                AND ZL9.R_E_C_N_O_=?
                )
                WHERE Z25.D_E_L_E_T_=' '
                  AND Z26.D_E_L_E_T_=' '
                  AND SF1.D_E_L_E_T_=' '
                  AND SD1.D_E_L_E_T_=' '
                  AND ZL9.D_E_L_E_T_=' '
                  AND Z26.Z26_ITEMNF<>'XX'
                  AND ZL9.ZL9_CODEMP=?
                  AND ZL9.ZL9_CODFIL=?
                  AND NOT EXISTS(
                    SELECT DISTINCT 1 
                      FROM [?] ZL9_t
                     WHERE ZL9_t.D_E_L_E_T_=' '
                       AND ZL9_t.ZL9_FILIAL=' '
                       AND ZL9_t.ZL9_CODEMP=?
                       AND ZL9_t.ZL9_CODFIL=?
                       AND ZL9_t.ZL9_PRCDEV=Z25.Z25_NUM
                       AND ZL9_t.R_E_C_N_O_<>ZL9.R_E_C_N_O_
                    )

        endContent

        oGetProcDev:=FWPreparedStatement():New(cSQL)

    endif

    ZL9->(MsGoTo(nZL9RecNo))

    oGetProcDev:setString(1,retSQLName("Z25"))
    oGetProcDev:setString(2,retSQLName("Z26"))
    oGetProcDev:setString(3,retSQLName("SD1"))
    oGetProcDev:setString(4,retSQLName("SF1"))
    oGetProcDev:setString(5,retSQLName("ZL9"))
    
    oGetProcDev:setNumeric(6,nZL9RecNo)

    oGetProcDev:setString(7,&("cEmpAnt"))
    oGetProcDev:setString(8,&("cFilAnt"))

    oGetProcDev:setString(9,retSQLName("ZL9"))
    
    oGetProcDev:setString(10,&("cEmpAnt"))
    oGetProcDev:setString(11,&("cFilAnt"))

    cSQL:=oGetProcDev:GetFixQuery()
    
    cSQL:=strTran(cSQL,"['","[")
    cSQL:=strTran(cSQL,"']","]")

    return(cSQL)
