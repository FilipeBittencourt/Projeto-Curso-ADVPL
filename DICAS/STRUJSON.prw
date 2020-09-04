#include "protheus.ch"


//U_STRUJSON
USER FUNCTION STRUJSON()

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
   oJSI:DelName("OtherInfo") // Para remover uma propriedade
   oJSI:ToJson() // Exibir ou retorna  estrutrura Json
   oJSI:FromJson("nom de sua varivel em formato string JSON") // Exibir ou retorna  estrutrura Json

   // Link Doc  - https://tdn.totvs.com.br/pages/viewpage.action?pageId=274315041
 
Return oJSI

