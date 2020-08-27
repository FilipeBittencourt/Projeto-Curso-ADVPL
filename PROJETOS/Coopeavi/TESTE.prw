#include "TOTVS.CH"
#include "XMLXFUN.CH"

Static Function LJ7030()

  Local nI          := 0
  Local nTamHeader  := Len(aHeader)

  nTotQtde          := 0
  nTotDescon        := 0
  nTotComiss        := 0
  nTotST            := 0
  nTotVenda         := M->ZW1_DESACE + M->ZW1_VALFRE

  For nI := 1 To Len(oGetDados:aCols)

    //|Ignora deletados |
    If oGetDados:aCols[nI,nTamHeader+1]
      Loop
    EndIf

    nTotQtde    += oGetDados:aCols[nI,GdFieldPos("ZW3_QTDITE")]
    nTotDescon  += oGetDados:aCols[nI,GdFieldPos("ZW3_VALDES")]
    nTotST      += oGetDados:aCols[nI,GdFieldPos("ZW3_ICMRET")]
    nTotVenda   += oGetDados:aCols[nI,GdFieldPos("ZW3_VALTOT")]

  Next nI

  //|Adiciona a ST ao total da venda |
  nTotVenda     += nTotST

  SA3->(dbSetOrder(1))
  SA3->( dbSeek( xFilial("SA3") + M->ZW1_CODVEN ) )
  nTotComiss    := Round((nTotVenda * SA3->A3_COMIS) / 100,2)

  //|Atualiza objetos de tela |
  oSayQtde:Refresh()
  oSayDesc:Refresh()
  oSayComis:Refresh()
  oSayST:Refresh()
  oSayTotal:Refresh()

Return