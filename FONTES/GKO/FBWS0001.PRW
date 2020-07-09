#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'


#Define cEOL Chr(13)+Chr(10)

WsRestFul escrituracao Description "Facile Sistemas Webservices - Intregra��o GKO"
  WsData name AS String
  WsMethod POST Description "Post method" WsSyntax "/FBWS0001/"
End WsRestFul

//----------------------------------------
// POST
//----------------------------------------
WSMETHOD POST WSSERVICE escrituracao

  Local oJson     := JsonObject():New()
  Local oBody     := JsonObject():New()
  Local cBody     := ::GetContent()
  Local aEmpFil   := {}
  Local cEmpBkp   := ""
  Local cFilBkp   := ""

  //|Defino que o retorno sera em JSON |
  ::SetContentType("application/json")
  // Registra no console a chamada do metodo
  conOut('escrituracao - POST METHOD')

  oBody:FromJson(cBody)

  If Empty(cBody)
    oJson['error'] := "� necess�rio informar os campos, para realizar essa a��o."
    ::SetStatus(400)
    ::SetResponse(oJson:ToJson())

  ElseIf Empty(oBody['empresa'])
    oJson['error'] := "� necess�rio informar o CNPJ da empresa."
    ::SetStatus(400)
    ::SetResponse(oJson:ToJson())
  Else

    aEmpFil := getFilial(oBody['empresa'])

    If Len( aEmpFil ) == 0

      oJson['error'] := "� necess�rio informar a Filial para preparar o ambiente."
      ::SetStatus(400)
      ::SetResponse(oJson:ToJson())

    Else

      cEmpBkp := cEmpAnt
      cFilBkp := cFilAnt

      RpcClearEnv()
      RPCSetEnv(aEmpFil[1], aEmpFil[2], NIL, NIL, "COM", NIL, {"SB1", "SB5"})

      oJson :=  InfoCTE(oBody)
      ::SetStatus(200)
      ::SetResponse(oJson:ToJson())

      RpcClearEnv()
      RPCSetEnv(cEmpBkp, cFilBkp, NIL, NIL, "COM", NIL, {"SB1", "SB5"})

    EndIf


  EndIf

Return .T.

Static Function InfoCTE(oBody)

  Local cTpCTE	    := SuperGetMV("MV_YTPCTE" , .F. , "N")        // Tipo de CTE F1_TPCTE
  Local cTipoCTE	  := SuperGetMV("MV_YTIPO" ,  .F. , "N")        // Tipo de CTE F1_TIPO
  Local cNature	    := SuperGetMV("MV_YNATCTE", .F. , "")         // Natureza E2_NATUREZ
  Local cCondPgto	  := SuperGetMV("MV_YPGTCTE", .F. , "")         // Condicao Pagamento - F1_COND
  Local cProduto    := SuperGetMV("MV_PRITDF",  .F. , "FRETE")    // Produto do CTE para entrada - D1_COD
  Local cCCusto     := SuperGetMV("MV_YCCCTE" , .F. , "1040109")  // Centro de Custo - D1_CC
  Local cTes        := ""                                         // TES de entrada CTE - D1_TES - SuperGetMV("MV_YTESCTE", .F. , "332")
  Local oJson       := JsonObject():New()
  Local oDados      := JsonObject():New()
  Local aDocs       := {}
  Local aCabNF      := {}
  Local aItem       := {}
  Local aNFVinc     := {}
  Local aTotItem    := {}
  Local aResp       := {}
  Local cDataAux    := ""
  Local dDtCte     	:= CtoD(" ")
  Local nI, nW      := 1
  Local cDocNum     := ""
  Local cDocSer	    := ""
  Local cCodForn    := ""
  Local cLJForn     := ""
  Local cCodTran    := ""
  Local cChvCte	    := ""
  Local cMsgErro    := ""
  Local cEspecie    := ""
  Local nVlrFrete	  := 0
  Local nBaseIcms	  := 0
  Local nAliqIcms	  := 0
  Local nVlrIcms	  := 0
  Local npos        := 0


  //|Monta cabecalho do CTE |

  For nI := 1 to Len(oBody['documentos'])

    cDocNum :=  StrZero( val(oBody['documentos'][nI]['numero']), 9,0)
    cDocSer :=  PadR(oBody['documentos'][nI]['serie'], TamSX3("F1_SERIE")[1] )

    cDataAux := SubStr( oBody['documentos'][nI]['dtemissao'], 9, 2 ) + "/"
    cDataAux += SubStr( oBody['documentos'][nI]['dtemissao'], 6, 2 ) + "/"
    cDataAux += SubStr( oBody['documentos'][nI]['dtemissao'], 1, 4 )
    dDtCte   := Ctod(cDataAux)

    nVlrIcms := oBody['documentos'][nI]['valoricms']
    cChvCte  := oBody['documentos'][nI]['chave']

    aResp    := SA2valid(oBody['documentos'][nI]['transportadora'])
    If(aResp[2])
      cCodForn := aResp[3]
      cLJForn  := aResp[4]
    Else
      cMsgErro += aResp[1] +" - "+ aResp[4] +" | "
    EndIf

    cCodTran := ""
    If oBody['documentos'][nI]['tipodoc'] == "57"
      cEspecie := "CTE"
      aResp    := SA4valid(oBody['documentos'][nI]['transportadora'])
      If(aResp[2])
        cCodTran := aResp[3]
      Else
        cMsgErro += aResp[1] +" - "+ aResp[4] +" | "
      EndIf
    Else
      cEspecie := "NFS"
    EndIf


    nVlrFrete := oBody['documentos'][nI]['valor']
    nBaseIcms := oBody['documentos'][nI]['basecalcicms']
    nAliqIcms := oBody['documentos'][nI]['aliqicms']

    // Validando a TES
    cTes :=  FGETTES(cEspecie, cCodForn, cLJForn, cProduto)
    If EMPTY( cTes )
      cMsgErro += " A TES nao foi encontrada no fonte U_VIXA103(especie, Fornece, loja, produto). | "
    EndIf

    //|Array cabe�alho do frete |
    aCabNF := {{"F1_TIPO"   , cTipoCTE  , NIL},;
      {"F1_FORMUL"          , ""        , NIL},;
      {"F1_ESPECIE"         , cEspecie  , NIL},;
      {"F1_DOC"             , cDocNum   , NIL},;
      {"F1_SERIE"           , cDocSer	  , NIL},;
      {"F1_FORNECE"         , cCodForn  , NIL},;
      {"F1_LOJA"            , cLJForn   , NIL},;
      {"F1_EMISSAO"         , dDtCte	  , NIL},;
      {"F1_DTDIGIT"         , dDataBase , NIL},;
      {"F1_VALICM"          , nVlrIcms  , NIL},;
      {"F1_CHVNFE"          , cChvCte   , NIL},;
      {"F1_TPCTE"           , cTpCTE    , NIL},;
      {"F1_TPFRETE"         , 'F'       , NIL},;
      {"F1_TRANSP"          , cCodTran  , NIL},;
      {"F1_VALBRUT"         , nVlrFrete , NIL},;
      {"F1_COND"            , cCondPgto , NIL},;
      {"E2_NATUREZ"         , cNature   , NIL}}

    //|Array com o item do frete |
    aItem := {{"D1_COD"   , cProduto	 , NIL},;
      {"D1_QUANT" 	      , 1          , NIL},;
      {"D1_VUNIT"    	    , nVlrFrete  , NIL},;
      {"D1_TOTAL"		      , nVlrFrete  , NIL},;
      {"D1_FORNECE"       , cCodForn   , NIL},;
      {"D1_LOJA"          , cLJForn    , NIL},;
      {"D1_DOC"           , cDocNum    , NIL},;
      {"D1_SERIE"         , cDocSer		 , NIL},;
      {"D1_TES"           , cTes       , NIL},;
      {"D1_LOCAL"         , "01"     	 , NIL},;
      {"D1_BASEICM"       , nBaseIcms  , NIL},;
      {"D1_PICM"          , nAliqIcms  , NIL},;
      {"D1_VALICM"  	    , nVlrIcms   , NIL},;
      {"D1_TIPO"          , cTipoCTE   , NIL},;
      {"D1_ITEM"          , "0001"     , Nil},;
      {"D1_CC"            , cCCusto    , Nil}}

    aAdd(aTotItem, aItem)

    //Notas Vinculadas
    aNFVinc := {}
    For nW := 1 to Len(oBody['documentos'][nI]['notasvinculadas'])
      aResp := SA1valid(oBody['documentos'][nI]['notasvinculadas'][nW]['cnpjdestinatario'])
      If(aResp[2])

        aAdd(aNFVinc,{{'NFDIFRE' , cDocNum},;
          {'SEDIFRE' , cDocSer},;
          {'DTDIGIT' , dDataBase},;
          {'TRANSP'  , cCodForn},;
          {'LOJTRAN' , cLJForn},;
          {'NFORIG'  , oBody['documentos'][nI]['notasvinculadas'][nW]['numero']},;
          {'SERORIG' , oBody['documentos'][nI]['notasvinculadas'][nW]['serie']},;
          {'CLIENTE' , aResp[3]},;
          {'CLILOJA' , aResp[4]};
          })
      Else
        cMsgErro += aResp[1] +" - "+ aResp[4] +" | "
      EndIf
    Next
    //Fim notas vinculadas


    aResp  := SF1valid(cDocNum,cDocSer,cCodForn,cLJForn,cTipoCTE)
    If(aResp[2] == .F.)
      cMsgErro += aResp[1] +" - "+ aResp[4]
    EndIf

    // Fun��o save via EXCAUTO
    If EMPTY(cMsgErro)
      aResp := SaveCTE(aCabNF, aTotItem, aNFVinc)
    Else
      aResp   := {"ERRO", cMsgErro}
    EndIf

    cMsgErro := ""
    aTotItem := {}

    //Return
    oDados              := JsonObject():New()
    aAdd( aDocs, oDados )
    npos                           :=  Len(aDocs)
    aDocs[npos,"numero"]           :=  cDocNum
    aDocs[npos,"serie"]            :=  cDocSer
    aDocs[npos,"transportadora"]   :=  oBody['documentos'][nI]['transportadora']
    aDocs[npos,"idtransportadora"] :=  oBody['documentos'][nI]['idtransportadora']
    aDocs[npos,"idnc"]             :=  oBody['documentos'][nI]['idnc']
    aDocs[npos,"dtemissao"]        :=  oBody['documentos'][nI]['dtemissao']
    aDocs[npos,"status"]           :=  aResp[1]
    aDocs[npos,"observacao"]       :=  aResp[2]

  Next

  oJson['empresa']    := oBody['empresa']
  oJson['documentos'] := aDocs

Return oJson


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

//|Gera o documento de entrada |
Static Function SaveCTE(aCabNF, aItem, aNFVinc)

  Local cMsg          := ""
  Local aResp         := {}
  Local nI            := 0
  Private lMsErroAuto := .F.

  Begin Transaction

    MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabNF,aItem,3,.F.)

    If lMsErroAuto
      DisarmTransaction()

      If (IsBlind()) // SEM INTERFACE GR�FICA

        cMsg := MostraErro("/dirdoc", "error.log")
        ConOut(PadC("Automatic routine ended with error", 80))
        ConOut("Error: "+ cMsg)

        aResp := {"ERRO",cMsg}
      EndIf

    else
      cMsg	:= "DOCUMENTO DE ENTRADA DO FRETE CRIADO COM SUCESSO."
      ConOut("Sucesso: "+ cMsg)
      aResp := {"OK",cMsg}

      For nI := 1 to Len(aNFVinc)
        //|Altera o status para classificado |
        Reclock('SZK',.T.)
        SZK->ZK_FILIAL  := xFilial('SZK')
        SZK->ZK_NFDIFRE := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'NFDIFRE' } ),2]
        SZK->ZK_SEDIFRE := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'SEDIFRE' } ),2]
        SZK->ZK_DTDIGIT := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'DTDIGIT' } ),2]
        SZK->ZK_TRANSP  := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'TRANSP'  } ),2]
        SZK->ZK_LOJTRAN := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'LOJTRAN' } ),2]
        SZK->ZK_NFORIG  := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'NFORIG'  } ),2]
        SZK->ZK_SERORIG := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'SERORIG' } ),2]
        SZK->ZK_CLIENTE := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'CLIENTE' } ),2]
        SZK->ZK_LOJA	  := aNFVinc[nI,aScan( aNFVinc[nI], { |x| x[1] == 'CLILOJA' } ),2]
        SZK->ZK_TIPO    := 'F'
        SZK->(MsUnlock())
      next

      //salvar
    EndIf

  End Transaction
  MsUnlockAll()

Return aResp


Static Function SF1valid(cDocNum,cDocSer,cCodForn,cLJForn,cTipoCTE)

  Local aRet := {}
  dbSelectArea("SF1")
  SF1->(dbSetOrder(1)) //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
  If SF1->(dbSeek(xFilial("SF1")+cDocNum+cDocSer+cCodForn+cLJForn+cTipoCTE))
    aRet :=  {"SF1", .F., "ERRO", "O Registro: "+cDocNum+"-"+cDocSer+ " para o fornecedor: "+cCodForn+"-"+cLJForn+" Ja foi cadastrado."}
  Else
    aRet :=  {"SF1", .T., ""}
  EndIf

Return aRet


Static Function SA1valid(cCNPJ)

  Local aRet := {}

  dbSelectArea("SA1")
  SA1->(dbSetOrder(3))   //A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_
  If SA1->(dbSeek(xFilial("SA1") + cCNPJ))
    aRet :=  {"SA1", .T., SA1->A1_COD, SA1->A1_LOJA}
  Else
    aRet :=  {"SA1", .F., "ERRO", "O Cliente com o CNPJ: "+cCNPJ+" Nao foi encontrado nas notas Vinculadas."}
  EndIf

Return aRet

Static Function SA2valid(cCNPJ)

  Local aRet := {}

  dbSelectArea("SA2")
  SA2->(dbSetOrder(3))   //A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_
  If SA2->(dbSeek(xFilial("SA2") + cCNPJ))
    aRet :=  {"SA2", .T., SA2->A2_COD, SA2->A2_LOJA}
  Else
    aRet :=  {"SA2", .F., "ERRO", "O Fornecedor com o CNPJ: "+cCNPJ+" Nao foi encontrado."}
  EndIf

Return aRet

Static Function SA4valid(cCNPJ)

  Local aRet := {}

  dbSelectArea("SA4")
  SA4->(dbSetOrder(3))   //A4_FILIAL, A4_CGC, R_E_C_N_O_, D_E_L_E_T_
  If SA4->(dbSeek(xFilial("SA4") + cCNPJ))
    aRet :=  {"SA4", .T., SA4->A4_COD, Nil}
  Else
    aRet :=  {"SA4", .F., "ERRO", "A Transportadora com o CNPJ: "+cCNPJ+" Nao foi encontrado."}
  EndIf

Return aRet

Static Function FGETTES(cEspecie, cFornece, cLoja, cProduto)

  Local aArea			:= GetArea()
  Local cCodTes		:= ""
  Local cOperNFSe		:= AllTrim(SuperGetMv("MV_YOPNFSE",.F.,"")) // documenta esse
  Local cOperFrVen	:= AllTrim(SuperGetMv("MV_YOPFRVE",.F.,""))

//Tratamento da TES automatica caso for FRETE
  If cEspecie == "CTE"

    cCodTes := U_VIXA103(1,cOperFrVen,cFornece,cLoja,"F",cProduto)

  EndIf

//Tratamento da TES automatica caso for FRETE
  If cEspecie == "NFS"

    cCodTes := U_VIXA103(1,cOperNFSe,cFornece,cLoja,"F",cProduto)

  EndIf


  RestArea(aArea)

Return cCodTes
