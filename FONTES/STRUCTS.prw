#include "protheus.ch"

//U_TESTS
USER FUNCTION STRUCTS()
  Local oObj   := CLIENTE():New()
  Local oObj2   := CLIENTECONTA():New()
  Local aObj2   := {}

  oObj2:cBANK := "NuBank"
  oObj2:cCC   := "123456"
  AADD(aObj2,oObj2)

  oObj2   := CLIENTECONTA():New()
  oObj2:cBANK := "Inter"
  oObj2:cCC   := "69874"
  AADD(aObj2,oObj2)

  oObj:cNome    := "Filipe"
  oObj:aContas := aObj2

  //oObj:SayHello(oObj)
Return

  CLASS CLIENTE From LongClassName
    Data cNome   as  String
    Data aContas as CLIENTECONTA
    Method New() CONSTRUCTOR
  ENDCLASS

METHOD NEW() CLASS CLIENTE
Return self

  CLASS CLIENTECONTA From LongClassName
    Data cBANK
    Data cCC
    Method New() CONSTRUCTOR
  ENDCLASS

METHOD NEW() CLASS CLIENTECONTA
Return self
/*
METHOD SAYHELLO() CLASS APHELLO
  MsgInfo(self:cMsg)
Return .T.
*/





  //Local cTimeIni := IncTime(Time(), 0, 0, 10)
  //Local aResult  := {}
  //Local cCount   := 0


  //While  cTimeIni >= Time()

  //  If cCount == 0
  //    MsgRun("Autenticando dados do cliente..", "Aguarde..." , {|| aResult := PLOGIN() })
  //    cCount := 1
  //  EndIf

  //  If Len(aResult) > 0
  //    alert("TimeOut")
  //  EndIf

  //EndDo
