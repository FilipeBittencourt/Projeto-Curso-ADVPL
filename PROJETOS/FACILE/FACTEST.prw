#include "protheus.ch"
#include "tryexception.ch"

#Define cBR Chr(13)+Chr(10)

CLASS TWSessionCodeAuth From LongClassName

  Data cUName  // User Name
  Data cUEmail // User Email
  Data cUToken // User Token
  Data lAdmin  // .T. or .F.
  Data cEFName // first_name
  Data cELName // last_name
  Data cECGC   // branch_key
  Data cEKey   // company_key


  Method New() CONSTRUCTOR
ENDCLASS

METHOD NEW() CLASS TWSessionCodeAuth
Return self



//U_FACTEST
USER FUNCTION FACTEST()

  If Select("SX6") <= 0
    // MsgRun("Preparando AMBIENTE...", "Aguarde..." , {||RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})} )
    // FWMsgRun(, {||  RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"}) }, "Aguarde! Preparando AMBIENTE...", "Processando...")
    // FWMsgRun(, {||  PLOGIN() }, "Aguarde! Autenticando dados do cliente...", "Processando...")
  EndIf
  MsgRun("Autenticando dados do cliente..", "Aguarde..." , {|| PLOGIN() })

RETURN .T.


// POST  LOGIN
Static Function PLOGIN()

  Local aHeader   := {"Content-Type: application/json","Application-Keys:xmle"}
  Local cHostWS	  := ""
  Local cLogin	  := ""
  Local cPass	    := ""
  Local cCNPJCPF  := ""
  Local oJson     := JsonObject():New()
  Local oReturn   := Nil
  Local oRest     := Nil
  Local oUCoAuth  := TWSessionCodeAuth():New()

  cHostWS	  := AllTrim("codeauth.facilecloud.com.br") // Parametro
  cLogin	  := AllTrim("pontin@aap.com.br")           // Parametro
  cPass	    := AllTrim("jascsp@320")                  // Parametro
  cCNPJCPF  := AllTrim("27340074000123")              //SM0->M0_CGC

  oRest     := FWRest():New(cHostWS)
  oRest:nTimeOut := 1
  oJson['email']       := cLogin
  oJson['password']    := cPass
  oJson['branch_key']  := cCNPJCPF

  oRest:setPath("/sessions")

  oRest:SetPostParams(oJson:ToJson())
  If oRest:Post(aHeader ) .OR. !Empty( oRest:GetResult() )
    If (oRest:ORESPONSEH:CSTATUSCODE == "200")
      FWJsonDeserialize(oRest:GetResult(), @oReturn)
      Aadd(aHeader,"Authorization:bearer "+oReturn:token:token+"")
      oUCoAuth:cUName  := AllTrim(DecodeUTF8(oReturn:user:name, "WINDOWS-1252"))
      oUCoAuth:cUEmail := oReturn:user:email
      oUCoAuth:cUToken := "bearer "+oReturn:token:token+""
      oUCoAuth:lAdmin  := oReturn:user:is_admin
      oUCoAuth:cEFName := AllTrim(DecodeUTF8(oReturn:logged_branch:first_name, "WINDOWS-1252"))
      oUCoAuth:cELName := AllTrim(DecodeUTF8(oReturn:logged_branch:last_name, "WINDOWS-1252"))
      oUCoAuth:cECGC   := oReturn:logged_branch:branch_key
      oUCoAuth:cEKey   := oReturn:logged_branch:company_key
    else
      FWJsonDeserialize(oRest:GetResult(), @oReturn)
      MsgWS(oReturn,  cLogin, cPass, cCNPJCPF )
      oUCoAuth := Nil
    EndIf
  Else
    FWJsonDeserialize(oRest:GetResult(), @oReturn)
    MsgWS(oReturn,  cLogin, cPass, cCNPJCPF )
    conout(oRest:GetLastError())
    oUCoAuth := Nil
  Endif

Return oUCoAuth


Static Function MsgWS(oReturn,  cLogin, cPass, cCNPJCPF )

  Local cMsgTit  := ""
  Local cDetails := ""
  Local cDetComp := "<b><i>Caso precise, favor entrar em contato com o suporte técnico responsável.</i</b>"
  Local nW       := 0
  Local lRet     := .T.
  Local cExcept := ""
  Local bError   := ErrorBlock({|e| cExcept := "<h3>"+e:Description+"</h3>"+e:ERRORSTACK})


  BEGIN SEQUENCE
    cMsgTit :=  "Central Xml-e"
    If !Empty(oReturn)
      If oReturn:ERROR:CODE == "E_VALIDATION_FAILED"
        For nW := 1 To Len(oReturn:ERROR:validations)
          cDetails += "<B>"+cValToChar(nW)+"</B> - "+ MsgParse(oReturn:ERROR:validations[nW]:field,  cLogin, cPass, cCNPJCPF)
        Next nW
        cDetails += cDetComp+ CRLF+ CRLF
        FwAlertWarning(AllTrim(cValToChar(cDetails)),"Atenção: "+cMsgTit+"")
        lRet := .F.
      ElseIf Empty(cExcept)
        cMsg := AllTrim(DecodeUTF8(oReturn:ERROR:message, "WINDOWS-1252"))
        cMsg += cDetComp+ CRLF+ CRLF
        FwAlertError( cMsg,"Error: "+cMsgTit+"")
        lRet := .F.
      EndIf
    Else
      FwAlertWarning("O servidor de origem não está respondendo. Tente novamente mais tarde.","Atenção: "+cMsgTit+"")
    EndIf
  End SEQUENCE


  ErrorBlock(bError)
  If !Empty(cExcept)
    FwAlertError(cExcept , "Error exception: ")
    cExcept := ""
    lRet := .F.
  EndIf

Return  lRet

Static Function MsgParse(cField, cLogin, cPass, cCNPJCPF)

  Local aMGParse := {}
  Local nW := 0
  Local cMsg := ""

  Aadd(aMGParse,{"branch_key","O CNPJ/CPF <b>"+cCNPJCPF+"</b> não foi encontrado."})
  Aadd(aMGParse,{"email","O email informado <b>"+cLogin+"</b> não foi encontrado."})
  Aadd(aMGParse,{"password","A senha informado <b>"+cPass+"</b> não foi encontrada."})

  For nW := 1 To Len(aMGParse)
    If aMGParse[nW,1] == cField
      cMsg :=  aMGParse[nW,2] + CRLF+ CRLF
      exit
    EndIf
  Next nW
  //AllTrim(DecodeUTF8(oReturn:ERROR:validations[nW]:MESSAGE, "WINDOWS-1252")

Return cMsg
