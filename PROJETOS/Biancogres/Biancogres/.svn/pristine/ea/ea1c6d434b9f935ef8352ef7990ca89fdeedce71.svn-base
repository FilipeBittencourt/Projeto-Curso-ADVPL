#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Gabriel Mafioletti
Programa  := MT094END
Empresa   := Facile Sistemas
Data      := 24/10/2017
Uso       := Aprovação de Docs - Envio de mensagem para solicitante de pedido de compra recusado
Aplicação := Irá enviar mensagem para a pessoa que solicitar uma compra, no caso, se compra for recusada
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function MT094END()

/*ParamIXB = {cDocto,cTipo,nOpc,cFilDoc} onde :

cDocto == Numero do Documento

cTipo == Tipo do Documento "PC" "AE" "CP"

Operação a ser executada (1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear)

cFilDoc == Filial do Documento*/

Local Enter  	:= CHR(13)+CHR(10)
Local cDocto    := PARAMIXB[1]
Local cTipoDoc  := PARAMIXB[2]
Local nOpcao    := PARAMIXB[3]
Local cFilDoc   := PARAMIXB[4]

//Local aUsu := ALLUSERS()
//matrícula fica na posição [n][1][22]: empresa (2) + filial (2) + matrícula (6)
//precisa de tudo isso para achar o email de quem fez o pedido

If nOpcao == 6 //Bloqueio
	PEMTU094 := "SELECT C7_NUM, C7_ITEM, C7_EMISSAO, C7_NUMSC, C7_ITEMSC, C7_YMAT, C7_YSOLEMP" + Enter
	PEMTU094 += "FROM  " + RetSqlName("SC7") + " SC7" + Enter
	PEMTU094 += "WHERE C7_FILIAL  = '" + xFilial("SC7") + "'" + Enter
	PEMTU094 += " AND   C7_NUM     = '" + cDocto + "'" + Enter
	PEMTU094 += " AND   D_E_L_E_T_ = ''"
	
	IF chkfile("PEMTU094")
		dbSelectArea("PEMTU094")
		dbCloseArea()
	ENDIF
	TCQuery PEMTU094 Alias "PEMTU094" New
	
	DbSelecTArea("PEMTU094")
	
	aUsu := ALLUSERS()
	nPos := AScan(aUsu, {|x|  AllTrim(x[1][22]) ==  PEMTU094->C7_YSOLEMP + "01" + PEMTU094->C7_YMAT })
	cEmailUsu := ""
	cNomeUsu := ""
	
	If (nPos > 0)
		cEmailUsu := aUsu[nPos][1][14] //email
		cNomeUsu := aUsu[nPos][1][2] //nome
		
		cHTMLUsuBloq := '<html xmlns="http://www.w3.org/1999/xhtml">'
		cHTMLUsuBloq += '    <head>'
		cHTMLUsuBloq += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
		cHTMLUsuBloq += '    <title>Pedido de Compras Recusado</title>'
		cHTMLUsuBloq += '    </head>'
		cHTMLUsuBloq += '    <body>'
		cHTMLUsuBloq += '         <p><label>PEDIDO DE COMPRAS RECUSADO</label><p>'
		cHTMLUsuBloq += '         <p>Sr.(a) ' + cNomeUsu + ', o seu pedido de compra ' + cDocto + ', referente à solicitação ' + PEMTU094->C7_NUMSC + ', foi recusado pelo gestor.</p>'
		cHTMLUsuBloq += '         <p>&nbsp;</p>'
		cHTMLUsuBloq += '         <p>by Protheus (MT094END)</p>'
		cHTMLUsuBloq += '    </body>'
		cHTMLUsuBloq += '</html>'
		
		df_Dest := cEmailUsu
		
		df_Assu := "Pedido de Compras Recusado"
		df_Erro := "Pedido de Compras Recusado. Favor verificar!"
		U_BIAEnvMail(, df_Dest, df_Assu, cHTMLUsuBloq, df_Erro)
	EndIf
	
	
	IF chkfile("PEMTU094")
		dbSelectArea("PEMTU094")
		dbCloseArea()
	ENDIF
EndIf

Return
