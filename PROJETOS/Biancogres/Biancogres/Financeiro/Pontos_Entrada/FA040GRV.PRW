#include "rwMake.ch"
#include "Topconn.ch"
#include "ap5mail.ch"

/*/{Protheus.doc} FA040GRV
@author HARLEY DIAS KOEHLER
@since 14/08/07
@version 1.0
@description ENVIA EMAIL PARA O FATURAMENTO COMUNICANDO NOVO R.A. 
@type function
/*/

USER Function FA040GRV()

Local oContaCont := TContaContabil():New()

PRIVATE EMAIL		:= ""
PRIVATE NOME		:= ""
PRIVATE TIPO		:= ""
PRIVATE SSEMPRESA 	:= ""
PRIVATE CSQL		:= ""
PRIVATE Enter		:= CHR(13)+CHR(10)
PRIVATE Pref		:= "RA"
PRIVATE CSTATUS		:= ""
PRIVATE nARQUIVO 	:= ""
PRIVATE nLINHA_LOG	:= ""
PRIVATE iTemVend 	:= .T.

oContaCont:SetContContab("C", SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_TIPO)

//RANISSES EM 27/10/2016
If Alltrim(Upper(AllTrim(getenvserver()))) <> "PRODUCAO"
	Return (.T.) 
EndIf

DbSelectArea("SA1")
DbSetOrder(1)
IF !DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA))
	MsgBox("Cliente nใo encontrado. Favor entrar em contato com o depto de TI!","STOP")
ENDIF

DbSelectArea("SA3")
DbSetOrder(1)
IF !DbSeek(xFilial("SA3")+SE1->E1_VEND1)
	iTemVend := .F.
ENDIF

IF SE1->E1_TIPO <> "RA"
	Return
Endif

If ALLTRIM(cempant) = "01"
	SSEMPRESA		:= "BIANCOGRES CERAMICA S/A"
ElseIf ALLTRIM(cempant) = "05"
	SSEMPRESA		:= "INCESA REVESTIMENTO CERAMICO LTDA"
ElseIf ALLTRIM(cempant) = "07"
	SSEMPRESA		:= "LM COMERCIO LTDA"
EndIf

If ALLTRIM(cempant) $  "01_07" // Para Biancogres e LM
	EMAIL 	:= "ra.biancogres@biancogres.com.br" //Foi criado um grupo para controle dos usuarios - 28/06/2010
	If iTemVend == .T.
		EMAIL += ";" + SA3->A3_EMAIL //OS 2147-16 / CLAUDEIR FADINI / LUANA MARIN RIBEIRO / 31/05/2016
	EndIf
ElseIf ALLTRIM(cempant) == "05" // Para Incesa
	EMAIL 	:= "ra.incesa@incesa.ind.br"				 //Foi criado um grupo para controle dos usuarios - 28/06/2010
	If iTemVend == .T.
		EMAIL += ";" + SA3->A3_EMAIL //OS 2147-16 / CLAUDEIR FADINI / LUANA MARIN RIBEIRO / 31/05/2016
	EndIf
EndIf

NOME 	:= "Att. Faturamento"   //alltrim(_FORNCEDOR->A2_NOME)
TIPO 	:= "Prezados Colegas,"
CRIA_EMAL()

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CRIA_EMAIL     บAutor  ณBRUNO MADALENO      บ Data ณ  04/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณROTINA PARA CRIAR O EMAIL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function CRIA_EMAL()

cData     := DTOC(DDATABASE)
cTitulo   := "Lancamento de R.A. "
cMensagem := ""
cMensagem += " Serra, " + cData + CHR(13)+CHR(10)
cMensagem += " " + CHR(13)+CHR(10)
cMensagem += " " + CHR(13)+CHR(10)
cMensagem += " " + CHR(13)+CHR(10)
cMensagem += " " + CHR(13)+CHR(10)
//cMensagem += " ASSUNTO: Lancamento de R.A. " + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += TIPO + CHR(13)+CHR(10)
cMensagem += NOME + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)

If ALLTRIM(cempant) $ "01_07"
	cMensagem += "Servimo-nos da presente para informar a V. Sa. que nessa data, foi incluido no Sistema o seguinte R.A.: " + CHR(13)+CHR(10)
	cMensagem += "Numero: " +SE1->E1_NUM+ CHR(13)+CHR(10)
	cMensagem += "Cliente: " + SA1->A1_COD+" - "+ SA1->A1_NOME+CHR(13)+CHR(10)
	cMensagem += "Valor R$: " + Transform(SE1->E1_VALOR, "@E 999,999,999.99")+CHR(13)+CHR(10)
	cMensagem += "Representante: " + SA3->A3_COD+" - "+SA3->A3_NOME+CHR(13)+CHR(10)
	cMensagem += CHR(13)+CHR(10)
ElseIf ALLTRIM(cempant) $ "05"
	cMensagem += "Servimo-nos da presente para informar a V. Sa. que nessa data, foi incluido no Sistema o seguinte R.A.: " + CHR(13)+CHR(10)
	cMensagem += "Numero: " +SE1->E1_NUM+ CHR(13)+CHR(10)
	cMensagem += "Cliente: " + SA1->A1_COD+" - "+ SA1->A1_NOME+CHR(13)+CHR(10)
	cMensagem += "Valor R$: " + Transform(SE1->E1_VALOR, "@E 999,999,999.99")+CHR(13)+CHR(10)
	cMensagem += "Representante: " + SA3->A3_COD+" - "+SA3->A3_NOME+CHR(13)+CHR(10)
	cMensagem += CHR(13)+CHR(10)
EndIf


cMensagem += CHR(13)+CHR(10)
cMensagem += "  Atenciosamente," + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += SSEMPRESA + CHR(13)+CHR(10)
cMensagem += "Setor Financeiro " + CHR(13)+CHR(10)


ENV_EMAIL(cData,cTitulo,cMensagem)

RETURN
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ENV_EMAIL      บAutor  ณBRUNO MADALENO      บ Data ณ  04/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณROTINA PARA ENVIAR O EMAIL                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function ENV_EMAIL(cData,cTitulo,cMensagem)

Local lOk := U_BIAEnvMail(,EMAIL,cTitulo,cMensagem)

If lOk
	CSTATUS := "OK"
Else
	CSTATUS := "N"
Endif

Return lOk
