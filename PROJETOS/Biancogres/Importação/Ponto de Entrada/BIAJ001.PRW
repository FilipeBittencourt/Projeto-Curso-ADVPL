#include "protheus.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ EICPO400  ³ Jussara Nobrega       ³ Data ³ 22.02.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Gravar Campo no Pedido de Compra após gravaçao do PO       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function EICPO400()

If ValType(ParamIXB) == "A"   
	cParam := ParamIXB[1]
Else   
	cParam := ParamIXB
Endif                           

If (cParam == "PO400GRAVAPC_CAPA")    

	aAdd(aCab,  {"C7_COND",M->W2_COND_PA, Nil})
				
Endif

If (cParam == "PO400GRAVAPC_ITEM")
   	
   	aAdd(aItensPo, 	{"C7_CLVL", M->W2_YCLVL, Nil})
   	aAdd(aItensPo,  {"C7_YAPLIC",'1', Nil})
	aAdd(aItensPo,  {"C7_YDATCHE", M->W2_DT_IMP, Nil})
	aAdd(aItensPo,  {"C7_YDTNECE", M->W2_DT_IMP, Nil})	
	aAdd(aItensPo, 	{"C7_COMPRA", M->W2_COMPRA, Nil})
	aAdd(aItensPo,  {"C7_PO_EIC",M->W2_PO_NUM, Nil})
//	aAdd(aItensPo,  {"C7_CODTAB",'   ', Nil})
//	aAdd(aItensPo,  {"C7_CONAPRO",'L', Nil})
//	aAdd(aItensPo,  {"C7_GRUPCOM",'000001', Nil})
  
		
EndIf



Return Nil