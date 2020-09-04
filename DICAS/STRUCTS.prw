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

    
    /*//OU
    AADD(aZZZA,   JsonObject():New())
    aZZZA[nI]["ZZZ_NOEMIT"] := 1
    aZZZA[nI]["ZZZ_CNPJ"]   := 2
    aZZZA[nI]["A2_COD"]     := 3
    aZZZA[nI]["A2_LOJA"]    := 4
    aZZZA[nI]["ZZZ_DOC"]    := 5
    aZZZA[nI]["ZZZ_SERIE"]  := 6
    aZZZA[nI]["ZZZ_CHAVE"]  := 7
    aZZZA[nI]["ZZZ_EMISNF"] := 8
    aZZZA[nI]["ZZZ_VLDOC"]  := 9
    aZZZA[nI]["ZZZ_PEDCHK"] := 10
    aZZZA[nI]["ZZZ_ECKDOC"] := 11
    aZZZA[nI]["R_E_C_N_O_"] := 12
    aZZZA[nI]["ZZZ_OK"]     := 13
    aZZZA[nI]["ZZZ_TIPO"]   := 14
    aZZZA[nI]["ZZZ_SITDOC"] := 15  
    */

    nI++
  EndDo

Return aZZZA


//U_STRUCTS3
USER FUNCTION STRUCTS3()

  Local oJSI     := JsonObject():New()
  Local oJSII    := JsonObject():New()
  Local oObjAux  := Nil
  Local aObjAux  := {}
  Local nI       := 1
  

  /*
  oJSII["Id"] := 1
  oJSII["FirstName"] := "Admin"  
  oJSI["User"] := oJSII
  */

  oJSII["Id"] := 1
  oJSII["FirstName"] := "Admin"
  oJSII["LastName"] := "Admin"
  oJSII["Email"] := "admin@admin.com.br"
  oJSII["Password"] := "bzAvbWE*&$#"

  For nI := 1 To 2   

    AADD(aObjAux,   JsonObject():New())
    aObjAux[nI]["Id"] := nI
    aObjAux[nI]["Nome"] := "Empresa "+cValTochar(nI)
    aObjAux[nI]["NomeFantasia"] := "Fantasia "+cValTochar(nI)
    aObjAux[nI]["CpfCnpj"] := "9999999999999"+cValTochar(nI)

  Next nI
  oJSII["ListEmpresa"] := aObjAux   
  oJSI["User"] := oJSII

 
  oJSII   := JsonObject():New()
  oJSII["Info01"] := "Info01"
  oJSII["Info02"] := "Info02"
  oJSII["Info03"] := "Info03"
 
  oJSI["OtherInfo"] := oJSII
  
 
 
Return oJSI




//U_STRUCTS4
USER FUNCTION STRUCTS4()

  Local oJSI     := JsonObject():New()  
  Local aObjAux  := {}
  Local nI       := 1  

  oJSI["User"] := JsonObject():New()
  oJSI["User"]["Id"] := 1
  oJSI["User"]["LastName"] := "Admin"
  oJSI["User"]["Email"] := "admin@admin.com.br"
  oJSI["User"]["Password"] := "bzAvbWE*&$#"

  
  For nI := 1 To 2   

    AADD(aObjAux,   JsonObject():New())
    aObjAux[nI]["Id"] := nI
    aObjAux[nI]["Nome"] := "Empresa "+cValTochar(nI)
    aObjAux[nI]["NomeFantasia"] := "Fantasia "+cValTochar(nI)
    aObjAux[nI]["CpfCnpj"] := "9999999999999"+cValTochar(nI)

  Next nI
  oJSI["User"]["ListEmpresa"] := aObjAux

  oJSI["OtherInfo"] := JsonObject():New() 
  oJSI["OtherInfo"]["Info01"]  := "AAAAAAAAAAAAAAA"
  oJSI["OtherInfo"]["Info02"]  := "BBBBBBBBBBBBBBB"
  oJSI["OtherInfo"]["Info03"]  := "CCCCCCCCCCCCCCC"
  oJSI["OtherInfo"]["SubInfo"] := JsonObject():New() 
  oJSI["OtherInfo"]["SubInfo"]["Info01"] := "SUB-A"
  oJSI["OtherInfo"]["SubInfo"]["Info02"] := "SUB-B"
  oJSI["OtherInfo"]["SubInfo"]["Info03"] := "SUB-C"


   oJSI["OtherInfo"] := Nil
 
Return oJSI

