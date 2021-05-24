#include 'totvs.ch'
#include 'topconn.ch'


Class PTVinilicoAbstractAPI From LongClassName

  Data cToken
  Data lBlind
  Data oTelegram
  Data oLst       // Objeto com a lista titulos a Processar

  Method New() Constructor

  Method Comunica()
  Method ErroConvert()
  Method DecodeConvert()
  Method AdjustLog()
  Method Format()
  Method GetUF()

EndClass


Method New() Class PTVinilicoAbstractAPI

  ::cToken          := ""
  ::lBlind          := IsBlind()

  ::oTelegram       := PTVinilicoTelegramAPI():New()

  ::oLst            := ArrayList():New()

Return Self


Method Comunica(cMsg, lNotifica) Class PTVinilicoAbstractAPI

  Local cTitulo     := "Biancogres Vinilico "
  Local cPreMsg     := DtoC( Date() ) + " - " + Time() + ' #PTVinilicoAbstractAPI - ' + cEmpAnt + '/' + cFilAnt + ' - '

  Default lNotifica  := .F.

  If ::lBlind
    FwLogMsg( "INFO", /*cTransactionId*/, cTitulo, FunName(), "", "01", cPreMsg + Upper(cMsg), 0, 0, {} )
    ConOut( cTitulo + cPreMsg + Upper(cMsg) )
  Else
    MsgInfo( cMsg, cTitulo )
  EndIf

  //|Envia notificação no Telegram da Facile |
  If lNotifica

    ::oTelegram:SendMessage( "[VINILICO] " + AllTrim(SM0->M0_NOME) + " - " + AllTrim(SM0->M0_CGC) )
    ::oTelegram:SendMessage( cPreMsg + Upper(cMsg) )

  EndIf

Return



Method ErroConvert( cErro )  Class PTVinilicoAbstractAPI

  Local cRetorno    := cErro
  Local cCampo      := ""
  Local cMsg        := ""
  Local jValid      := JsonObject():New()
  Local nI          := 0

  Private jTemp     := JsonObject():New()

  //|Ajusta codificação do erro |
  cErro   := ::DecodeConvert(cErro)

  jTemp:FromJson( cErro )

  //|Erros de validação |
  If Type( 'jTemp["validations"]' ) == "A"

    cRetorno  := jTemp["message"] + CRLF + CRLF

    For nI := 1 To Len( jTemp["validations"] )

      jValid    := jTemp["validations"][nI]

      //|Tratamento de campos |
      If ValType( jValid["field"] ) == "C"
        cCampo  := jValid["field"]
      ElseIf ValType( jValid["campo"] ) == "C"
        cCampo  := jValid["campo"]
      Else
        cCampo  := ""
      EndIf

      //|Tratamento de mensagens |
      If ValType( jValid["message"] ) == "C"
        cMsg    := jValid["message"]
      ElseIf ValType( jValid["mensagem"] ) == "C"
        cMsg    := jValid["mensagem"]
      Else
        cMsg    := ""
      EndIf

      cRetorno  += "CAMPO: " + cCampo + CRLF
      cRetorno  += "MENSAGEM DO BACKEND: " + cMsg + CRLF

      If ValType( jValid["valor"] ) != "U"
        cRetorno  += "VALOR: " + cValToChar(jValid["valor"]) + CRLF
      EndIf

      cRetorno  += Replicate( "-", 25 ) + CRLF + CRLF

    Next nI

  ElseIf Type( 'jTemp["error"]["message"]' ) == "C"

    cRetorno  := "CODIGO DO ERRO: " + jTemp["error"]["code"] + CRLF
    cRetorno  += "MENSAGEM DO BACKEND: " + jTemp["error"]["message"] + CRLF

  ElseIf Type( 'jTemp["message"]' ) == "C"

    cRetorno  := "CODIGO DO ERRO: " + jTemp["code"] + CRLF
    cRetorno  += "MENSAGEM DO BACKEND: " + jTemp["message"] + CRLF

  EndIf

Return cRetorno



Method DecodeConvert( cTexto )  Class PTVinilicoAbstractAPI

  Local cRetorno    := DecodeUTF8( cTexto )

  If ValType(cRetorno) == "U"
    cRetorno  := cTexto
  EndIf

Return cRetorno


Method AdjustLog( cMsg ) Class PTVinilicoAbstractAPI

  Local cLogAdjusted    := ""
  Local cPreMsg         := DtoC( Date() ) + " - " + Time() + " - " + cUserName

  If !Empty(cMsg)

    If !Empty( SE1->E1_YCFMENS )
      cLogAdjusted    := SE1->E1_YCFMENS + CRLF
      cLogAdjusted    += Replicate( "-", 20 ) //|Não mudar essa quantidade |
      cLogAdjusted    += CRLF + CRLF
    EndIf

    cLogAdjusted      += cPreMsg + CRLF
    cLogAdjusted      += cMsg

  EndIf

Return cLogAdjusted


Method Format(xValor) Class PTVinilicoAbstractAPI

  Local cType   := ValType(xValor)
  Local cDia    := ""
  Local cMes    := ""
  Local cAno    := ""

  If cType == "C"

    xValor  := AllTrim(xValor)

  ElseIf cType == "D"

    cAno    := Year2Str( xValor )
    cMes    := Month2Str( xValor )
    cDia    := Day2Str( xValor )

    xValor  := cAno + "-" + cMes + "-" + cDia + "T10:00:00-03:00"

  ElseIf cType == "N"

    xValor  := xValor

  ElseIf cType == "L"

    xValor  := xValor

  ElseIf cType == "O"

    xValor  := xValor

  Else

    xValor  := ""

  EndIf

Return xValor

Return


Method GetUF( cEst ) Class PTVinilicoAbstractAPI

  Local cCodUF  := ""
  Local nPos    := 0
  Local aUF     := {}

  //|Região Norte |
  aAdd(aUF,{"RO","11"})
  aAdd(aUF,{"AC","12"})
  aAdd(aUF,{"AM","13"})
  aAdd(aUF,{"RR","14"})
  aAdd(aUF,{"PA","15"})
  aAdd(aUF,{"AP","16"})
  aAdd(aUF,{"TO","17"})

  //|Região Nordeste |
  aAdd(aUF,{"MA","21"})
  aAdd(aUF,{"PI","22"})
  aAdd(aUF,{"CE","23"})
  aAdd(aUF,{"RN","24"})
  aAdd(aUF,{"PB","25"})
  aAdd(aUF,{"PE","26"})
  aAdd(aUF,{"AL","27"})
  aAdd(aUF,{"SE","28"})
  aAdd(aUF,{"BA","29"})

  //|Região Sudeste |
  aAdd(aUF,{"MG","31"})
  aAdd(aUF,{"ES","32"})
  aAdd(aUF,{"RJ","33"})
  aAdd(aUF,{"SP","35"})

  //|Região Sul |
  aAdd(aUF,{"PR","41"})
  aAdd(aUF,{"SC","42"})
  aAdd(aUF,{"RS","43"})

  //|Região Centro-Oeste |
  aAdd(aUF,{"MS","50"})
  aAdd(aUF,{"MT","51"})
  aAdd(aUF,{"GO","52"})
  aAdd(aUF,{"DF","53"})

  //|Busca UF |
  If ( nPos := aScan( aUF, { |x| x[1] == cEst } ) ) > 0
    cCodUF	:= aUF[nPos,2]
  EndIf

Return cCodUF
