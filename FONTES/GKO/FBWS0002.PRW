#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#include "topconn.ch"


#Define cEOL Chr(13)+Chr(10)

WsRestFul fatura Description "Facile Sistemas Webservices - Intregração GKO"
  WsMethod POST Description "Post method" WsSyntax "/FBWS0002/"
End WsRestFul

//----------------------------------------
// POST
//----------------------------------------
WSMETHOD POST WSSERVICE fatura

  Local oJson     := JsonObject():New()
  Local oBody     := JsonObject():New()
  Local cBody     := ::GetContent()
  Local aEmpFil   := {}
  Local cEmpBkp   := ""
  Local cFilBkp   := ""

  //|Defino que o retorno sera em JSON |
  ::SetContentType("application/json")
  // Registra no console a chamada do metodo
  conOut('fatura - POST METHOD')

  oBody:FromJson(cBody)

  If Empty(cBody)
    oJson['error'] := "É necessário informar os campos, para realizar essa ação."
    ::SetStatus(400)
    ::SetResponse(oJson:ToJson())

  ElseIf Empty(oBody['empresa'])
    oJson['error'] := "É necessário informar o CNPJ da empresa."
    ::SetStatus(400)
    ::SetResponse(oJson:ToJson())
  Else

    aEmpFil := getFilial(oBody['empresa'])

    If Len( aEmpFil ) == 0

      oJson['error'] := "É necessário informar a Filial para preparar o ambiente."
      ::SetStatus(400)
      ::SetResponse(oJson:ToJson())

    Else

      cEmpBkp := cEmpAnt
      cFilBkp := cFilAnt

      RpcClearEnv()
      RPCSetEnv(aEmpFil[1], aEmpFil[2], NIL, NIL, "FIN", NIL, {"SB1", "SE2"})

      oJson :=  Fatura(oBody)
      ::SetStatus(200)
      ::SetResponse(oJson:ToJson())

      RpcClearEnv()
      RPCSetEnv(cEmpBkp, cFilBkp, NIL, NIL, "FIN", NIL, {"SB1", "SE2"})

      /*oJson :=  Fatura(oBody)
      ::SetStatus(200)
      ::SetResponse(oJson:ToJson())*/

    EndIf

  EndIf

Return .T.

Static Function getFilial(cCNPJ)

  Local aRet      := {}
  Local aAreaSM0	:= SM0->(GetArea())

  dbSelectArea("SM0")
  SM0->(dbSetOrder(1))
  SM0->(dbGoTop())
  While !SM0->(EoF())
    If AllTrim(SM0->M0_CGC) == AllTrim(cCNPJ)
      aAdd( aRet, SM0->M0_CODIGO )
      aAdd( aRet, SM0->M0_CODFIL )
      Exit
    EndIf
    SM0->(dbSkip())
  EndDo
  RestArea(aAreaSM0)

Return aRet

Static Function Fatura(oBody)

  Local nI       := 0
  Local aFatura  := {}
  Local aResp    := {}
  Local aDocs    := {}
  Local oJson    := JsonObject():New()
  Local oDados   := JsonObject():New()
  Local cFilOrig := ""
  Local cPrefixo := ""
  Local cNum 	   := ""
  Local cParcela := ""
  Local cTipo	   := SuperGetMV("MV_YTIPGKO", .F. , "FT")         // Natureza E2_NATUREZ
  Local cFornece := ""
  Local cLJForn  := ""
  Local cNaturez := SuperGetMV("MV_YNATGKO", .F. , "21301")         // 21301 Natureza E2_NATUREZ
  Local cHist	   := ""
  Local nValor   := 0
  Local nSaldo   := 0
  Local nJuros   := 0
  Local nMulta   := 0
  Local nDescont := 0
  Local dVencto  := CtoD(" ")
  Local dEmissao := CtoD(" ")
  Local dVencrea := CtoD(" ")
  Local cNomFor  := ""
  Local cOrigem  := "GKO"
  Local cMsgErro := ""
  Local npos     := 0

  For nI := 1 to Len(oBody['faturas'])

    cFilOrig := xFilial("SE2")
    cPrefixo := PadR(oBody['faturas'][nI]['serie'],TamSX3("E2_PREFIXO")[1])
    cNum     := oBody['faturas'][nI]['fatura']
    cParcela := "1"

    aResp    := SA2valid(oBody['faturas'][nI]['fornecedor'])
    If(aResp[2])
      cFornece := aResp[3]
      cLJForn  := aResp[4]
      cNomFor  := aResp[5]
    Else
      cMsgErro += aResp[1] +" - "+ aResp[4] +" | "
    EndIf

    cHist     := oBody['faturas'][nI]['observacao']
    nValor    := oBody['faturas'][nI]['valorapagar']
    nSaldo    := oBody['faturas'][nI]['valorapagar']
    nDescont  := oBody['faturas'][nI]['desconto']

    dEmissao  := SubStr( oBody['faturas'][nI]['dtemissao'], 9, 2 ) + "/"
    dEmissao  += SubStr( oBody['faturas'][nI]['dtemissao'], 6, 2 ) + "/"
    dEmissao  += SubStr( oBody['faturas'][nI]['dtemissao'], 1, 4 )
    dEmissao  := Ctod(dEmissao)

    dVencto   := SubStr( oBody['faturas'][nI]['dtvencimento'], 9, 2 ) + "/"
    dVencto   += SubStr( oBody['faturas'][nI]['dtvencimento'], 6, 2 ) + "/"
    dVencto   += SubStr( oBody['faturas'][nI]['dtvencimento'], 1, 4 )
    dVencto   := Ctod(dVencto)

    dVencrea  := DATAVALIDA(dVencto)


    aFatura := {;
      {"E2_FILIAL"   , cFilOrig  , NIL},;
      {"E2_PREFIXO"  , cPrefixo  , NIL},;
      {"E2_NUM"      , cNum 	   , NIL},;
      {"E2_PARCELA"  , cParcela  , NIL},;
      {"E2_TIPO"     , cTipo	   , NIL},;
      {"E2_FORNECE"  , cFornece  , NIL},;
      {"E2_LOJA"     , cLJForn   , NIL},;
      {"E2_NATUREZ"  , cNaturez  , NIL},;
      {"E2_HIST"     , cHist	   , NIL},;
      {"E2_VALOR"    , nValor    , NIL},;
      {"E2_SALDO"    , nSaldo    , NIL},;
      {"E2_JUROS"    , nJuros    , NIL},;
      {"E2_MULTA"    , nMulta    , NIL},;
      {"E2_DESCONT"  , nDescont  , NIL},;
      {"E2_EMISSAO"  , dEmissao  , NIL},;
      {"E2_VENCTO"   , dVencto   , NIL},;
      {"E2_ORIGEM"   , cOrigem   , NIL},;      
      {"E2_NOMFOR"   , cNomFor   , NIL};
      }

    aResp  := SE2valid(cPrefixo,cNum,cParcela,cTipo,cFornece,cLJForn)
    If(aResp[2] == .F.)
      cMsgErro += aResp[1] +" - "+ aResp[4]
    EndIf

    // Função save via EXCAUTO
    If EMPTY(cMsgErro)
      aResp  := SaveFAT(aFatura)
    Else
      aResp  := {"ERRO", cMsgErro}
    EndIf
    aFatura  := {}
    cMsgErro := ""


    //Return
    oDados           := JsonObject():New()
    aAdd( aDocs, oDados )
    npos                              :=  Len(aDocs)
    aDocs[npos,"serie"]               :=  cPrefixo
    aDocs[npos,"fatura"]              :=  cNum
    aDocs[npos,"fornecedor"]          :=  oBody['faturas'][nI]['fornecedor']
    aDocs[npos,"idfatura"]            :=  oBody['faturas'][nI]['idfatura']
    aDocs[npos,"idtransportadora"]    :=  oBody['faturas'][nI]['idtransportadora']
    aDocs[npos,"idpartransportadora"] :=  oBody['faturas'][nI]['idpartransportadora']
    aDocs[npos,"nocontrole"]          :=  oBody['faturas'][nI]['nocontrole']
    aDocs[npos,"status"]              :=  aResp[1]
    aDocs[npos,"observacao"]          :=  aResp[2]

  Next
  //SetFunName( cFunName )
  oJson['empresa'] := oBody['empresa']
  oJson['faturas'] := aDocs


Return oJson

Static Function SA2valid(cCNPJ)

  Local aRet := {}

  dbSelectArea("SA2")
  SA2->(dbSetOrder(3))   //A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_
  If SA2->(dbSeek(xFilial("SA2") + cCNPJ))
    aRet :=  {"SA2", .T., SA2->A2_COD, SA2->A2_LOJA, SA2->A2_NREDUZ}
  Else
    aRet :=  {"SA2", .F., "ERRO", "O Fornecedor com o CNPJ: "+cCNPJ+" Nao foi encontrado.", ""}
  EndIf

Return aRet


Static Function SE2valid(cPrefixo,cNum,cParcela,cTipo,cFornece,cLJForn)

  Local aRet   := {}
  Local cAlias := GetNextAlias()

  If Select(cAlias) > 0
    dbSelectArea(cAlias)
    (cAlias)->(dbCloseArea())
  EndIf

  BeginSql Alias cAlias
    SELECT R_E_C_N_O_ AS REC
    FROM   %Table:SE2% SE2
    WHERE   E2_FILIAL = %xFilial:SE2%
    AND E2_PREFIXO = %Exp:cPrefixo%
    AND E2_NUM = %Exp:cNum%
    AND E2_PARCELA = %Exp:cParcela%
    AND E2_TIPO = %Exp:cTipo%
    AND E2_FORNECE =  %Exp:cFornece%
    AND E2_LOJA = %Exp:cLJForn%
  EndSql

  (cAlias)->(dbGoTop())
  If (cAlias)->(EoF())
    aRet :=  {" SE2", .T., ""}
  else
    aRet :=  {" SE2", .F., "ERRO", "O Registro: "+cNum+" com o tipo: "+cTipo+ " para o fornecedor: "+cFornece+"-"+cLJForn+" Ja foi cadastrado."}
  EndIf
  (cAlias)->(dbCloseArea())

Return aRet



Static Function SaveFAT(aFatura)

  Local cMsg          := ""
  Local aResp         := {}
  Local nI            := 0
  Private lMsErroAuto := .F.

  Begin Transaction

    nModulo := 6
    conOut("MsExecAuto FINA050 - DOC: "+cValToChar(aFatura[3,2])+" , em "+cValToChar(DATE())+" - "+cValToChar(time()))
    MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aFatura,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

    If lMsErroAuto
      DisarmTransaction()

      If (IsBlind()) // SEM INTERFACE GRÁFICA

        cMsg := MostraErro("/dirdoc", "error.log")
        ConOut(PadC("Automatic routine ended with error", 80))
        ConOut("Error: "+ cMsg)

        aResp := {"ERRO",cMsg}
      EndIf

    else
      cMsg	:= "FATURA CRIADA COM SUCESSO."
      ConOut("Sucesso: "+ cMsg)
      aResp := {"OK",cMsg}

    EndIf

  End Transaction
  MsUnlockAll()

Return aResp
