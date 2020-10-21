#Include 'TOTVS.CH'

User Function AAAAA(cNumTeste)

  Local nI       := 0
  Local aFatura  := {}
  Local aResp    := {}
  Local aDocs    := {}
  Local oJson    := JsonObject():New()
  Local oDados   := JsonObject():New()
  Local cFilOrig := "32"
  Local cPrefixo := "1"
  Local cNum 	   :=  cNumTeste //"000000123"
  Local cParcela := "1"
  Local cTipo	   := "FT" //SuperGetMV("MV_YTIPGKO", .F. , "FT")         // Natureza E2_NATUREZ
  Local cFornece := "002527"
  Local cLJForn  := "01"
  Local cNomFor  := "RODONAVES"
  Local cNaturez := "21301" //SuperGetMV("MV_YNATGKO", .F. , "21301")         // 21301 Natureza E2_NATUREZ
  Local cHist	   := "Incluido via integracao..."
  Local nValor   := 100
  Local nSaldo   := 100
  Local nJuros   := 0
  Local nMulta   := 0
  Local nDescont := 0
  Local dVencto  := CtoD("20/05/20")
  Local dEmissao := CtoD("15/05/20")
  Local dVencrea := CtoD("20/05/20")
  Local cMsgErro := ""
  Local npos     := 0

  Local   cMsg        := ""
  Private lMsErroAuto := .F.


  conOut("INICIO                                     , em "+cValToChar(DATE())+" - "+cValToChar(time()))
  RPCSetEnv("11", "32", NIL, NIL, "COM", NIL, {"SB1", "SB5"})
  conOut("RPCSetEnv                                  , em "+cValToChar(DATE())+" - "+cValToChar(time()))


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



Return aResp



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
    conOut("MsExecAuto FINA050 DOC: "+cValToChar(aFatura[3,2])+" , em "+cValToChar(DATE())+" - "+cValToChar(time()))
    MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aFatura,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

    If lMsErroAuto
      DisarmTransaction()



      cMsg := MostraErro("/dirdoc", "error.log")
      ConOut(PadC("Automatic routine ended with error", 80))
      ConOut("Error: "+ cMsg)

      aResp := {"ERRO",cMsg}


    else
      cMsg	:= "FATURA CRIADA COM SUCESSO."
      ConOut("Sucesso: "+ cMsg)
      aResp := {"OK",cMsg}

    EndIf

  End Transaction
  MsUnlockAll()

  conOut("MsExecAuto FINALIZADO - DOC: "+cValToChar(aFatura[3,2])+" , em "+cValToChar(DATE())+" - "+cValToChar(time()))
Return aResp
