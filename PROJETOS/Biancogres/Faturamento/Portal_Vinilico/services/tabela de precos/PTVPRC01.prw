#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVPRC01
Rotina responsável por padronizar a integração dos preços
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
User Function PTVPRC01(oSchd)

  Local oObj       := PTVinilicoTabelaPrecos():New()
  Local aArea      := GetArea()
  Local cQuery     := "" 
  Local cMsgLog    := ""
  Local lLog       := .F.

  Default oSchd    := Nil

  lLog  := Type("oSchd") != "U"
  
  //|Busca a query de preços |
  cQuery := fGetQuery()
  
  If Select("__DA1") > 0
    __DA1->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__DA1"

  __DA1->( dbGoTop() )

  While !__DA1->( EoF() )

    cMsgLog   := "Produto: " + AllTrim(__DA1->B1_COD) + " / " + AllTrim(__DA1->ESTCLIENTE) + " - Preço: " + cValToChar(__DA1->DA1_PRCVEN)

    oObj:cIdProd    := AllTrim(__DA1->B1_YIDVINI)
    oObj:cCodSB1    := __DA1->B1_COD
    oObj:cUfCliente := __DA1->ESTCLIENTE
    oObj:nPreco     := __DA1->DA1_PRCVEN
    oObj:cMsgErro   := ""
    
    oObj:Process()

    //|Erro no processamento? |
    If !Empty(oObj:cMsgErro)
      cMsgLog   += CRLF + oObj:cMsgErro
    Else
      cMsgLog   += CRLF + " -> Preço atualizado com sucesso."
    EndIf

    If lLog
      oSchd:LogMessage( cMsgLog + CRLF )
    EndIf

    ConOut(cMsgLog )

    __DA1->( dbSkip() )    

  EndDo

  //|Atualiza o Stamp |
  U_PTVSTAMP( "PUT", "DA1" )

  If lLog
    oSchd:LogMessage( "FINALIZADO TABELA DE PRECO" + CRLF )
  Else
    MsgInfo("Sincronização finalizada!")
  EndIf

  RestArea(aArea)

Return


/*/{Protheus.doc} fGetQuery
Monta a query para buscar o estoque
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 22/12/2020
@return character, query montada para filtro
/*/
Static Function fGetQuery()

  Local cQuery     := ""
  Local cEmp       := ""
  Local cFil       := ""
  Local cTabES     := SuperGetMV( "ZZ_VNTABES", .F., "141" )
  Local cTabSP     := SuperGetMV( "ZZ_VNTABSP", .F., "131" )
  Local cTab00     := SuperGetMV( "ZZ_VNTAB00", .F., "142" )
  Local cUltUpdate := U_PTVSTAMP( "GET", "DA1" )
  Local dEmissao   := dDataBase

  //|CLIENTE ES - EMPRESA 07 FILIAL 01 |
  cEmp  := IIf( cEmpAnt == "99", cEmpAnt, "07" )
  cFil  := "01"

  cQuery += " SELECT 'ES' AS ESTCLIENTE, "
  cQuery += "     SB1.B1_COD, "
  cQuery += "     SB1.B1_YIDVINI, "
  cQuery += "     DA1.DA1_PRCVEN "
  cQuery += " FROM DA1" + cEmp + "0 DA1 "
  cQuery += "     JOIN DA0" + cEmp + "0 DA0 "
  cQuery += "         ON DA0.DA0_FILIAL = DA1.DA1_FILIAL "
  cQuery += "           AND DA0.DA0_CODTAB = DA1.DA1_CODTAB "
  cQuery += "           AND DA0.D_E_L_E_T_ = '' "
  cQuery += "     JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery += "         ON SB1.B1_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "           AND SB1.B1_COD = DA1.DA1_CODPRO "
  cQuery += "           AND SB1.B1_YIDVINI <> '' "
  cQuery += "           AND SB1.D_E_L_E_T_ = '' "
  cQuery += " WHERE DA1.DA1_FILIAL = " + ValToSql( cFil )
  cQuery += "       AND DA1.DA1_CODTAB = " + ValToSql( cTabES )
  cQuery += "       AND " + ValToSql( dEmissao ) + " >= DA0.DA0_DATDE "
  cQuery += "       AND " + ValToSql( dEmissao ) + " <= DA0.DA0_DATATE "
  cQuery += "       AND ( DA1.DA1_YDELTB = '' OR CONVERT(VARCHAR(23), DA1.DA1_YDELTB, 21) >= " + ValToSql(cUltUpdate) + " ) "
  cQuery += "       AND DA1.D_E_L_E_T_ = '' "

  cQuery += "     UNION ALL

  //|CLIENTE SP - EMPRESA 07 FILIAL 05 |
  cEmp  := IIf( cEmpAnt == "99", cEmpAnt, "07" )
  cFil  := "05"

  cQuery += " SELECT 'SP' AS ESTCLIENTE, "
  cQuery += "     SB1.B1_COD, "
  cQuery += "     SB1.B1_YIDVINI, "
  cQuery += "     DA1.DA1_PRCVEN "
  cQuery += " FROM DA1" + cEmp + "0 DA1 "
  cQuery += "     JOIN DA0" + cEmp + "0 DA0 "
  cQuery += "         ON DA0.DA0_FILIAL = DA1.DA1_FILIAL "
  cQuery += "           AND DA0.DA0_CODTAB = DA1.DA1_CODTAB "
  cQuery += "           AND DA0.D_E_L_E_T_ = '' "
  cQuery += "     JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery += "         ON SB1.B1_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "           AND SB1.B1_COD = DA1.DA1_CODPRO "
  cQuery += "           AND SB1.B1_YIDVINI <> '' "
  cQuery += "           AND SB1.D_E_L_E_T_ = '' "
  cQuery += " WHERE DA1.DA1_FILIAL = " + ValToSql( cFil )
  cQuery += "       AND DA1.DA1_CODTAB = " + ValToSql( cTabSP )
  cQuery += "       AND " + ValToSql( dEmissao ) + " >= DA0.DA0_DATDE "
  cQuery += "       AND " + ValToSql( dEmissao ) + " <= DA0.DA0_DATATE "
  cQuery += "       AND ( DA1.DA1_YDELTB = '' OR CONVERT(VARCHAR(23), DA1.DA1_YDELTB, 21) >= " + ValToSql(cUltUpdate) + " ) "
  cQuery += "       AND DA1.D_E_L_E_T_ = '' "

  cQuery += "       UNION ALL

  //|CLIENTE OUTROS ESTADOS - EMPRESA 07 FILIAL 01 |
  cEmp  := IIf( cEmpAnt == "99", cEmpAnt, "07" )
  cFil  := "01"

  cQuery += " SELECT '' AS ESTCLIENTE, "
  cQuery += "     SB1.B1_COD, "
  cQuery += "     SB1.B1_YIDVINI, "
  cQuery += "     DA1.DA1_PRCVEN "
  cQuery += " FROM DA1" + cEmp + "0 DA1 "
  cQuery += "     JOIN DA0" + cEmp + "0 DA0 "
  cQuery += "         ON DA0.DA0_FILIAL = DA1.DA1_FILIAL "
  cQuery += "           AND DA0.DA0_CODTAB = DA1.DA1_CODTAB "
  cQuery += "           AND DA0.D_E_L_E_T_ = '' "
  cQuery += "     JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery += "         ON SB1.B1_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "           AND SB1.B1_COD = DA1.DA1_CODPRO "
  cQuery += "           AND SB1.B1_YIDVINI <> '' "
  cQuery += "           AND SB1.D_E_L_E_T_ = '' "
  cQuery += " WHERE DA1.DA1_FILIAL = " + ValToSql( cFil )
  cQuery += "       AND DA1.DA1_CODTAB = " + ValToSql( cTab00 )
  cQuery += "       AND " + ValToSql( dEmissao ) + " >= DA0.DA0_DATDE "
  cQuery += "       AND " + ValToSql( dEmissao ) + " <= DA0.DA0_DATATE "
  cQuery += "       AND ( DA1.DA1_YDELTB = '' OR CONVERT(VARCHAR(23), DA1.DA1_YDELTB, 21) >= " + ValToSql(cUltUpdate) + " ) "
  cQuery += "       AND DA1.D_E_L_E_T_ = '' "

Return cQuery
