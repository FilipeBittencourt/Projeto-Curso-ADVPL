#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#define CRLF Chr(13) + Chr(10) 

//U_000TESTS
USer Function 000TESTS()    
 
 
 
  Local cCodUser :=  RetCodUsr()
  Local cNomUser :=  UsrRetName(cCodUser)
  Local cUsers   :=  "filipe;pontin"// SuperGetMv("MV_YUPQSAT",.F.,"")

  If Select("SX6") <= 0	
    RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})	
  EndIf	

 If LOWER(cNomUser) $ LOWER(cUsers)  /* YSTAZAP */
  alert("O "+cNomUser+" está contido em:"+cUsers+"")
 EndIf
  

Return .T.
