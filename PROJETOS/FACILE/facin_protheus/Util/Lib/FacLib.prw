#include "tbiconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} LFParam
Criação dos parametros da rotina
@type Function
@author Pontin
@since 09.01.2020
@version 1.0
/*/
User Function LFParam()

  If !ExisteSX6("ZF_UPDSB1")
    CriarSX6("ZF_UPDSB1", "C", "Data da ultima atualizacao dos produtos FacIN", "")
  EndIf

  If !ExisteSX6("ZF_UPDSA1")
    CriarSX6("ZF_UPDSA1", "C", "Data da ultima atualizacao dos clientes FacIN", "")
  EndIf

  If !ExisteSX6("ZF_UPDSAH")
    CriarSX6("ZF_UPDSAH", "C", "Data da ultima atualizacao das unidades de medida FacIN", "")
  EndIf

  If !ExisteSX6("ZF_UPDSE4")
    CriarSX6("ZF_UPDSE4", "C", "Data da ultima atualizacao das condicoes de pagamento FacIN", "")
  EndIf

  If !ExisteSX6("ZF_UPDSBM")
    CriarSX6("ZF_UPDSBM", "C", "Data da ultima atualizacao dos grupos de produtos FacIN", "")
  EndIf

Return


/*/{Protheus.doc} LFParam
Criação dos parametros da rotina
@type Function
@author Pontin
@since 09.01.2020
@version 1.0
/*/
User Function LFLimpa(cConteudo)

  cConteudo := FwNoAccent(cConteudo)
  cConteudo := AnsiToOem(cConteudo)

  //Retirando caracteres
  cConteudo := StrTran(cConteudo, "'", "")
  cConteudo := StrTran(cConteudo, "#", "")
  cConteudo := StrTran(cConteudo, "%", "")
  cConteudo := StrTran(cConteudo, "*", "")
  cConteudo := StrTran(cConteudo, "§", "")
  cConteudo := StrTran(cConteudo, "&", "E")
  cConteudo := StrTran(cConteudo, ">", "")
  cConteudo := StrTran(cConteudo, "<", "")
  cConteudo := StrTran(cConteudo, "!", "")
  cConteudo := StrTran(cConteudo, "@", "")
  cConteudo := StrTran(cConteudo, "$", "")
  cConteudo := StrTran(cConteudo, "(", "")
  cConteudo := StrTran(cConteudo, ")", "")
  cConteudo := StrTran(cConteudo, "_", "")
  cConteudo := StrTran(cConteudo, "=", "")
  cConteudo := StrTran(cConteudo, "+", "")
  cConteudo := StrTran(cConteudo, "{", "")
  cConteudo := StrTran(cConteudo, "}", "")
  cConteudo := StrTran(cConteudo, "[", "")
  cConteudo := StrTran(cConteudo, "]", "")
  cConteudo := StrTran(cConteudo, "/", "")
  cConteudo := StrTran(cConteudo, "?", "")
  cConteudo := StrTran(cConteudo, ".", "")
  cConteudo := StrTran(cConteudo, "\", "")
  cConteudo := StrTran(cConteudo, "|", "")
  cConteudo := StrTran(cConteudo, ":", "")
  cConteudo := StrTran(cConteudo, ";", "")
  cConteudo := StrTran(cConteudo, '"', '')
  cConteudo := StrTran(cConteudo, '°', '')
  cConteudo := StrTran(cConteudo, 'ª', '')
  cConteudo := StrTran(cConteudo, '¹', '')
  cConteudo := StrTran(cConteudo, '²', '')
  cConteudo := StrTran(cConteudo, '³', '')
  cConteudo := StrTran(cConteudo, 'º', '')
  cConteudo := StrTran(cConteudo, 'ª', '')
  cConteudo := StrTran(cConteudo, 'º', '')
  cConteudo := StrTran(cConteudo, '-', '')
  cConteudo := StrTran(cConteudo, '’', '')
  cConteudo := StrTran(cConteudo, '¦', '')
  cConteudo := StrTran(cConteudo, '|', '')
  cConteudo := StrTran(cConteudo, '¿', '')
  cConteudo := StrTran(cConteudo, CHR(167), '')
  cConteudo := StrTran(cConteudo, CHR(186), '')
  cConteudo := StrTran(cConteudo, CHR(170), '')
  cConteudo := StrTran(cConteudo, CHR(174), '')

Return cConteudo