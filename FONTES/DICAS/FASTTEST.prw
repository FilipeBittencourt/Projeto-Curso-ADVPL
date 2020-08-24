#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#define CRLF Chr(13) + Chr(10)


//U_FASTTEST
User Function FASTTEST()

  Local  cText1 := "35,60"
  Local  cText2 := "35,60"

  Local  cText3 := "35.60"
  Local  cText4 := "35,60"

Return

//U_FASTTEST 


Static Function FASTTEST()

  Local oJson  := JsonObject():New()
  Local cEmail := "pontin@facilesistemas.com.br;fsbvieira@gmail.com;filipe.bittencourt@facilesistemas.com.br"
  Local aEmailA := {}
  Local aEmailB := {}
  Local nI      := 0

  If ";" $ cEmail
    aEmailA := StrTokArr( cEmail, ";" )
    For nI := 1 To Len(aEmailA)
      Aadd(aEmailB,JsonObject():new())
      aEmailB[nI]['email' ] := aEmailA[nI]
    Next nI
    oJson['to'] := aEmailB
  else
    oJson['to'] := cEmail
  EndIf
  oJson['html']     :=  ""
  oJson['from']     := "xmle@facilesistemas.com.br"
  oJson['subject']  := "Divergência Central XML-e"
  U_Exemplo()
Return



Static Function Exemplo()

  Local cTexto := ""
  Local cEncodeUTF8 := ""
  Local cDecodeUTF8 := ""
  Local cMensagem := ""

  cTexto := "à noite, vovô kowalsky vê o ímã cair no pé do pingüim "
  cTexto += "queixoso e vovó põe açúcar no chá de tâmaras do jabuti feliz."
  cEncodeUTF8 := EncodeUTF8(cTexto, "cp1252")
  cDecodeUTF8 := DecodeUTF8(cEncodeUTF8, "cp1252")
  cMensagem := "Pangrama origem: [" + cTexto + "]"
  cMensagem += CRLF + "Texto -> UTF8: [" + cEncodeUTF8 + "]"
  cMensagem += CRLF + "UTF8 -> Texto: [" + cDecodeUTF8 + "]"
  MsgInfo(cMensagem, "Exemplo")

  // Brasil em Russo
  cTexto := chr(193)+chr(240)+chr(224)+chr(231)+chr(232)+chr(235)+chr(201)+chr(235)+chr(255)
  cEncodeUTF8 := EncodeUTF8(cTexto, "cp1251")
  cDecodeUTF8 := DecodeUTF8(cEncodeUTF8, "cp1251")
  cMensagem := "Pangrama origem: [" + cTexto + "]"
  cMensagem += CRLF + "Texto -> UTF8: [" + cEncodeUTF8 + "]"
  cMensagem += CRLF + "UTF8 -> Texto: [" + cDecodeUTF8 + "]"
  MsgInfo(cMensagem, "Exemplo")

Return
