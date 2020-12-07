#include "TOTVS.CH"

/*Fernando/Facile em 17/12/2015 - validacao do campo D3_CLVL com relacao a regra de TAG*/
User function BED3CLVL()

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
If Type("_ExecAutoII") <> "U"
	Return(.T.)
EndIf

If AllTrim(FunName()) <> "MATA240"
	Return(.T.)
EndIf

IF ALLTRIM(__READVAR) = 'M->D3_YTAG'
	
	If Empty(M->D3_CLVL)
		MsgAlert("Favor informar primeiro a Classe de Valor!","BESTVLXX")
		Return(.F.)
	EndIf
	
	SZC->(DbSetOrder(1))
	If SZC->(DbSeek(XFilial("SZC")+M->D3_YTAG)) .And. ( M->D3_CLVL <> SZC->ZC_CLVL )
		MsgAlert("TAG com classe de valor diferente. Para usar essa TAG informar a classe de valor: "+SZC->ZC_CLVL,"BESTVLXX")
		Return(.F.)
	EndIf
	
ELSEIF ALLTRIM(__READVAR) = 'M->D3_CLVL'
	
	SZC->(DbSetOrder(1))
	If !Empty(M->D3_YTAG) .And. SZC->(DbSeek(XFilial("SZC")+M->D3_YTAG)) .And. ( M->D3_CLVL <> SZC->ZC_CLVL )
		MsgAlert("TAG com classe de valor diferente. Para usar essa TAG informar a classe de valor: "+SZC->ZC_CLVL,"BESTVLXX")
		Return(.F.)
	EndIf
	
ENDIF

Return(.T.)
