#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA870
@author Ranisses Antonio Corona
@since 01/03/2017
@version 1.0
@description Validar digita��o do Codigo de Barra com somente 12 caracteres 
@type function
/*/

User Function BIA870()
Local lRet := .T.

If Len(Alltrim(M->B1_CODBAR)) <> 12 .And. Substr(M->B1_CODGTIN,1,14) <> "00000000000000"
	MsgBox("Favor preencher os 12 primeiros caracteres do C�digo de Barras do sistema EAN13, o digito verificador ser� calculado e gravado no sistema automaticamente, ou '00000000000000' no campo C�d. GTIN para 'SEM GTIN'.","BIA870","STOP")
	lRet := .F.
EndIf

Return(lRet)