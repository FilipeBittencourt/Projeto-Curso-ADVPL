#Include 'Protheus.ch'
#Include 'Report.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} BFATRE04
Relatório de Notas Fiscais não classificadas

@author Filipe Bittencourt
@since 30.01.15
@version 1.00
/*/

User Function BFATRE04()

  Local oReport
  Local cPerg	:= "BFATRE04"

  Pergunte(cPerg, .F.)
  oReport := ReportDef()
  oReport:SetLandscape()
  oReport:PrintDialog()

Return()


Static Function ReportDef()
  Local oReport
  Local oSecCE

  oReport := TReport():New("BFATRE04","Relatório de Notas Fiscais não classificadas","BFATRE04",{|oReport| PrintReport(oReport)},"Relatório de Notas Fiscais não classificadas")

  oSecCE := TRSection():New(oReport,"CE","ZZA")

  TRCell():New(oSecCE,"ZAA_FILIAL","ZZA","Filial",, 10)
  TRCell():New(oSecCE,"ZAA_TIPO","ZZA",,, 10)
  TRCell():New(oSecCE,"ZAA_DOC","ZZA")
  TRCell():New(oSecCE,"ZAA_SERIE","ZZA",,,7)
  TRCell():New(oSecCE,"NATUREZA",,"Nat.Operacao",,30)
  TRCell():New(oSecCE,"ZAA_SIT","ZZA",,,20)
  TRCell():New(oSecCE,"ZAA_DTEMIS","ZZA",,,15)
  TRCell():New(oSecCE,"ZAA_CGCEMI","ZZA",,,16)
  TRCell():New(oSecCE,"A2_NOME","ZZA")
  TRCell():New(oSecCE,"ZAA_CHAVE","ZZA")
  TRCell():New(oSecCE,"ZAA_TOTVAL","ZZA")

  TRFunction():New(oSecCE:Cell("ZAA_TOTVAL"),NIL,"SUM",,NIL,NIL,NIL,.F.,.T.)
  TRFunction():New(oSecCE:Cell("ZAA_DOC"),NIL,"COUNT",,NIL,NIL,NIL,.F.,.T.)

Return oReport

Static Function PrintReport(oReport)

  Local oSecCE 	:= oReport:Section(1)

  oSecCE:BeginQuery()
  Painel()
  oSecCE:EndQuery()

  __TRB->(DbGoTop())

  oSecCE:Init()

  dbSelectArea("ZZA")
  ZZA->( dbSetOrder(1) )

  While !oReport:Cancel() .And. !__TRB->(EoF())

    oReport:IncMeter()

    If oReport:Cancel()
      Exit
    EndIf

    ZZA->( dbGoTo(__TRB->RECNO) )

    //|Busca a natureza da operacao |
    cNatureza   := "000001"//StaticCall(PTXR003,fGetNat, ZZA->ZZA_XML)

    oSecCE:Cell("ZAA_FILIAL"):SetValue(__TRB->ZAA_FILIAL)
    oSecCE:Cell("ZAA_TIPO"):SetValue(IIf(__TRB->ZAA_TIPO=="1","NF-e","CT-e"))
    oSecCE:Cell("ZAA_DOC"):SetValue(__TRB->ZAA_DOC)
    oSecCE:Cell("ZAA_SERIE"):SetValue(__TRB->ZAA_SERIE)
    oSecCE:Cell("NATUREZA"):SetValue(__TRB->ZAA_NATOP)
    oSecCE:Cell("ZAA_SIT"):SetValue(X3Combo("ZAA_SIT", __TRB->ZAA_SIT))
    oSecCE:Cell("ZAA_DTEMIS"):SetValue(StoD(__TRB->ZAA_DTEMIS))
    oSecCE:Cell("ZAA_CGCEMI"):SetValue(__TRB->ZAA_CGCEMI)
    oSecCE:Cell("A2_NOME"):SetValue(__TRB->A2_NOME)
    oSecCE:Cell("ZAA_CHAVE"):SetValue(__TRB->ZAA_CHAVE)
    oSecCE:Cell("ZAA_TOTVAL"):SetValue(__TRB->ZAA_TOTVAL)
    oSecCE:PrintLine()

    __TRB->(dbSkip())

  EndDo

  oSecCE:Finish()

Return


Static Function Painel()

  Local cQuery	  := ""

  cQuery 	:= ""
  cQuery	+= "  SELECT   "  + CRLF
  cQuery	+= "   ZZA.ZAA_FILIAL "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_DOC  "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_SERIE  "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_TIPO  "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_DTEMIS  "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_CGCEMI  "  + CRLF
  cQuery	+= "  ,SA2.A2_NOME  "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_CHAVE  "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_TOTVAL  "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_SIT  "  + CRLF
  cQuery	+= "  ,ZZA.ZAA_NATOP  "  + CRLF

  cQuery	+= " FROM ZAA010 ZZA  "  + CRLF
  cQuery	+= " INNER JOIN SA2010 SA2 ON SA2.A2_CGC = ZZA.ZAA_CGCEMI AND SA2.D_E_L_E_T_    = ''  "  + CRLF
  cQuery	+= " WHERE 0=0  "  + CRLF
  cQuery	+= " AND ZZA.ZAA_DTEMIS   BETWEEN " + ValToSql(mv_par01) + " AND " + ValToSql(mv_par02)  + CRLF
  cQuery	+= " AND ZZA.ZAA_CGCEMI   BETWEEN " + ValToSql(mv_par03) + " AND " + ValToSql(mv_par04)  + CRLF
  cQuery	+= " AND ZZA.ZAA_CHAVE    BETWEEN " + ValToSql(mv_par05) + " AND " + ValToSql(mv_par06)  + CRLF
  cQuery	+= " AND ZZA.ZAA_FILIAL   BETWEEN " + ValToSql(mv_par07) + " AND " + ValToSql(mv_par08)  + CRLF
  cQuery	+= " AND ZZA.ZAA_DOC      BETWEEN " + ValToSql(mv_par09) + " AND " + ValToSql(mv_par10)  + CRLF
  cQuery	+= " AND ZZA.ZAA_SERIE    BETWEEN " + ValToSql(mv_par11) + " AND " + ValToSql(mv_par12)  + CRLF

  cQuery	+= " AND ZZA.ZAA_SIT = '1' "   + CRLF //1=Normal;2=Importado;3=Com erro;4=Doc. de Entrada ainda nao existe;5=Cancelado;6=Bloqueado;7=Autorizar

  cQuery	+= " AND ZAA_TIPO   IN ('1','2') "   + CRLF //1=NFe Entrada;2=CTe;3=CCe;4=NFSe;5=Cancelamento

  cQuery	+= " AND ZZA.D_E_L_E_T_    = '' "  + CRLF

  cQuery	+= "  AND NOT EXISTS (	SELECT 0 "  + CRLF
  cQuery	+= "  FROM SF1010 SF1 "  + CRLF
  cQuery	+= "  WHERE F1_FILIAL = ZZA.ZAA_FILIAL "  + CRLF
  cQuery	+= "  AND F1_CHVNFE   = ZZA.ZAA_CHAVE "  + CRLF
  cQuery	+= "  AND F1_STATUS <> ''  "  + CRLF
  cQuery	+= "  AND SF1.D_E_L_E_T_ = ' '	) "  + CRLF
  cQuery	+= "  ORDER BY ZAA_FILIAL,ZAA_DTEMIS,ZAA_CGCEMI "  + CRLF


  If Select("__TRB") > 0
    __TRB->(dbCloseArea())
  EndIf

  cQuery := ChangeQuery(cQuery)
  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"__TRB",.T.,.T.)

Return
