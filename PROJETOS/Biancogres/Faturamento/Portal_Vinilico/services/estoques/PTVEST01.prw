#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVEST01
Rotina responsável por padronizar a integração do estoque
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
User Function PTVEST01(oSchd)

  Local oEst       := PTVinilicoEstoques():New()
  Local aArea      := GetArea()
  Local cQuery     := "" 
  Local cMsgLog    := ""
  Local lLog       := .F.

  Default oSchd    := Nil

  lLog  := Type("oSchd") != "U"
  
  //|Busca a query de estoque |
  cQuery := fGetQuery()
  
  If Select("__SB2") > 0
    __SB2->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__SB2"

  __SB2->( dbGoTop() )

  While !__SB2->( EoF() )

    cMsgLog   := "Integrando Produto: " + __SB2->B1_COD + " - Local de estoque: " + AllTrim(__SB2->LOCEST)

    If lLog
      oSchd:LogMessage( cMsgLog + CRLF )
    EndIf

    ConOut(cMsgLog )

    oEst:cIdProd  := AllTrim(__SB2->B1_YIDVINI)
    oEst:cCodSB1  := __SB2->B1_COD
    oEst:cLocEst  := __SB2->LOCEST
    oEst:nSaldo   := IIf( __SB2->QUANT < 0, 0, __SB2->QUANT )
    
    oEst:Process()

    __SB2->( dbSkip() )    

  EndDo

  //|Atualiza o Stamp |
  U_PTVSTAMP( "PUT", "SB2" )

  If lLog
    oSchd:LogMessage( "FINALIZADO ESTOQUE" + CRLF )
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
@return character, query montada
/*/
Static Function fGetQuery()

  Local cQuery     := ""
  Local cEmp       := ""
  Local cArmazens  := "02/04"
  Local cUltUpdate := U_PTVSTAMP( "GET", "SB2" )

  cQuery += " SELECT  DT.LOCEST, "
  cQuery += "     DT.B1_COD, "
  cQuery += "     DT.B1_YIDVINI, "
  cQuery += "     ISNULL(ROUND(SUM(DT.B2_QATU - DT.B2_RESERVA), 2), 0) AS QUANT "
  cQuery += " FROM "

  //|ESTOQUE ES - EMPRESA 13 |
  cEmp  := IIf( cEmpAnt == "99", cEmpAnt, "13" )

  cQuery += " ( "
  cQuery += "     SELECT  'ES' AS LOCEST, "
  cQuery += "       SB1.B1_COD, "
  cQuery += "       SB1.B1_YIDVINI, "
  cQuery += "       SB2.B2_QATU, "
  cQuery += "       SB2.B2_RESERVA "
  cQuery += "     FROM SB2" + cEmp + "0 SB2 "
  cQuery += "   JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery += "     ON SB1.B1_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "     AND SB1.B1_COD = SB2.B2_COD "
  cQuery += "     AND SB1.B1_YIDVINI <> '' "
  cQuery += "     AND SB1.D_E_L_E_T_ = '' "
  cQuery += "     WHERE SB2.B2_LOCAL IN " + FormatIN(cArmazens, "/")
  cQuery += "           AND ( SB2.B2_YDELTBI = '' OR CONVERT(VARCHAR(23), SB2.B2_YDELTBI, 21) >= " + ValToSql(cUltUpdate) + " ) "
  cQuery += "           AND SB2.D_E_L_E_T_ = '' "

  cQuery += "     UNION ALL

  //|ESTOQUE ES - EMPRESA 14 |
  cEmp  := IIf( cEmpAnt == "99", cEmpAnt, "14" )

  cQuery += "     SELECT  'ES' AS LOCEST, "
  cQuery += "         SB1.B1_COD, "
  cQuery += "         SB1.B1_YIDVINI, "
  cQuery += "         SB2.B2_QATU, "
  cQuery += "         SB2.B2_RESERVA "
  cQuery += "       FROM SB2" + cEmp + "0 SB2 "
  cQuery += "     JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery += "       ON SB1.B1_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "       AND SB1.B1_COD = SB2.B2_COD "
  cQuery += "       AND SB1.B1_YIDVINI <> '' "
  cQuery += "       AND SB1.D_E_L_E_T_ = '' "
  cQuery += "       WHERE SB2.B2_LOCAL IN " + FormatIN(cArmazens, "/")
  cQuery += "           AND ( SB2.B2_YDELTBI = '' OR CONVERT(VARCHAR(23), SB2.B2_YDELTBI, 21) >= " + ValToSql(cUltUpdate) + " ) "
  cQuery += "           AND SB2.D_E_L_E_T_ = '' "

  cQuery += "       UNION ALL

  //|ESTOQUE SP - EMPRESA 07 Filial 05 |
  cEmp  := IIf( cEmpAnt == "99", cEmpAnt, "07" )

  cQuery += "       SELECT  'SP' AS LOCEST,  "
  cQuery += "         SB1.B1_COD, "
  cQuery += "         SB1.B1_YIDVINI, "
  cQuery += "         SB2.B2_QATU, "
  cQuery += "         SB2.B2_RESERVA "
  cQuery += "       FROM SB2" + cEmp + "0 SB2 "
  cQuery += "     JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery += "       ON SB1.B1_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "       AND SB1.B1_COD = SB2.B2_COD "
  cQuery += "       AND SB1.B1_YIDVINI <> '' "
  cQuery += "       AND SB1.D_E_L_E_T_ = '' "
  If cEmp == "99"
    cQuery += "       WHERE SB2.B2_FILIAL = '01' "
  Else
    cQuery += "       WHERE SB2.B2_FILIAL = '05' "
  EndIf
  cQuery += "         AND SB2.B2_LOCAL IN " + FormatIN(cArmazens, "/")
  cQuery += "             AND ( SB2.B2_YDELTBI = '' OR CONVERT(VARCHAR(23), SB2.B2_YDELTBI, 21) >= " + ValToSql(cUltUpdate) + " ) "
  cQuery += "             AND SB2.D_E_L_E_T_ = '' "
         
  cQuery += " ) AS DT "
  cQuery += " GROUP BY DT.LOCEST, DT.B1_COD, DT.B1_YIDVINI "

Return cQuery
