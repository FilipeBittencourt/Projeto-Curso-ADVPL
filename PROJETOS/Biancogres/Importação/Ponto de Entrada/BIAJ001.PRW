#include "protheus.ch"
#include "topconn.ch"

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嚻o    � EICPO400  � Jussara Nobrega       � Data � 22.02.19 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri嚻o � Gravar Campo no Pedido de Compra ap髎 grava鏰o do PO       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � RDMAKE                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

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