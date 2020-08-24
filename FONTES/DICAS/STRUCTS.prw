#include "protheus.ch"

//U_TESTS
USER FUNCTION STRUCTS1()
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

//U_STRUCTS2
USER FUNCTION STRUCTS2()

  Local oJSZZZA := JsonObject():New()
  Local aZZZA   := {}
  Local nI   := 1


  While nI <= 10
    oJSZZZA := JsonObject():New()
    oJSZZZA["ZZZ_NOEMIT"] := 1
    oJSZZZA["ZZZ_CNPJ"]   := 2
    oJSZZZA["A2_COD"]     := 3
    oJSZZZA["A2_LOJA"]    := 4
    oJSZZZA["ZZZ_DOC"]    := 5
    oJSZZZA["ZZZ_SERIE"]  := 6
    oJSZZZA["ZZZ_CHAVE"]  := 7
    oJSZZZA["ZZZ_EMISNF"] := 8
    oJSZZZA["ZZZ_VLDOC"]  := 9
    oJSZZZA["ZZZ_PEDCHK"] := 10
    oJSZZZA["ZZZ_ECKDOC"] := 11
    oJSZZZA["R_E_C_N_O_"] := 12
    oJSZZZA["ZZZ_OK"]     := 13
    oJSZZZA["ZZZ_TIPO"]   := 14
    oJSZZZA["ZZZ_SITDOC"] := 15
    aAdd(aZZZA, oJSZZZA)

    nI++
  EndDo

Return aZZZA


