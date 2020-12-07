#include "rwmake.ch"
#INCLUDE "ACESSOS.CH"
#Include "FWMVCDEF.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ MA430PEX³ Autor ³ WLADIMIR I. N. SANTANNA ³ Data ³ 09/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Permite a exclusao de empenhos de exportacao somente para...³±±
±±³			 ³ usuario liberados.									       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function Ma430pex()

Local lStatus   := .T.
Local oModelAux := FWModelActive()
Local CEXCREXP 	:= ""
Local MSG 		:= ""

//TRATA MVC NA TELA DE RESERVA
Local lMVC 		:= .F.
If Upper(Alltrim(FunName())) == "MATA430"
	lMVC := U_BIAChkMVC()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a localizacao atual e uma localizacao de exportacao. Se sim..³
//³ verifica se o usuario possui o direito de excluir reservas para export.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if upper(SubStr(SC0->C0_LOCALIZ,4,2))=="EX"
	lStatus	:= .F.
	cEXCREXP := substr(cUsuario,AC_EXCREXP,1)
	if cEXCREXP == "S"
		lStatus	:= .T.
	else
		msg := ""
		msg := msg + "EXCLUSAO NAO PERMITIDA!"+chr(13)+chr(13)
		msg := msg + "O Usuario atual nao possui o direito de excluir Reservas para Exportacao."
		msgbox(msg)
	endif
endif

//Fernando/Facile em 20/01 - nao permitir excluir reserva de pedido automatica
If !lMVC
	
	if paramixb[1] == 2 .And. lStatus
		
		if (!Empty(SC0->C0_YPEDIDO) .And. !Empty(SC0->C0_YITEMPV) .And. !Empty(SC0->C0_YHORA) .And. (SC0->C0_YTEMP <> "S"))
			
			msg := ""
			msg += "EXCLUSAO NAO PERMITIDA!"+chr(13)+chr(13)
			msg += "Não é possível excluir reservas automáticas de pedido por esta tela."+chr(13)+chr(13)
			msg += "Favor usar a tela do Pedido de Vendas."+chr(13)+chr(13)
			msgbox(msg)
			
			lStatus := .F.
			
		endif
		
	endif
	
Else
	
	if  oModelAux:GetOperation() == MODEL_OPERATION_DELETE .And. lStatus
		
		if (!Empty(SC0->C0_YPEDIDO) .And. !Empty(SC0->C0_YITEMPV) .And. !Empty(SC0->C0_YHORA) .And. (SC0->C0_YTEMP <> "S"))
			
			msg := ""
			msg += "EXCLUSAO NAO PERMITIDA!"+chr(13)+chr(13)
			msg += "Não é possível excluir reservas automáticas de pedido por esta tela."+chr(13)+chr(13)
			msg += "Favor usar a tela do Pedido de Vendas."+chr(13)+chr(13)
			msgbox(msg)
			
			lStatus := .F.
			
		endif
		
	endif
	
	
EndIf

	If lStatus
	
		fAddHis(SC0->C0_NUM)
	
	EndIf

Return(lStatus)


// Adiciona historico de alteracoes de reserva
Static Function fAddHis(cNumRes)
Local aArea := GetArea()
	
	DbSelectArea("SC0")
	SC0->(DbSetOrder(1))
	If SC0->(MsSeek(xFilial("SC0") + cNumRes))
		
		While !SC0->(Eof()) .And. SC0->C0_FILIAL == xFilial("SC0") .And. SC0->C0_NUM == cNumRes
			
			If SC0->C0_YHIST == "S"
				
				RecLock("ZCD", .T.)
				
					ZCD->ZCD_FILIAL := xFilial("ZCD")
					ZCD->ZCD_CODIGO := GetSxEnum("ZCD", "ZCD_CODIGO")
					ZCD->ZCD_TIPO := "C"
					ZCD->ZCD_DATA := dDataBase
					ZCD->ZCD_HORA := Time()
					ZCD->ZCD_PRODUT := SC0->C0_PRODUTO
					ZCD->ZCD_LOCAL := SC0->C0_LOCAL
					ZCD->ZCD_QTD := SC0->C0_QUANT
					ZCD->ZCD_LOTE := SC0->C0_LOTECTL
					ZCD->ZCD_USR := cUserName
			
				ZCD->(MsUnLock())
				
			EndIf
			
			SC0->(DbSkip())
			
		EndDo()
		
	EndIf
	
	RestArea(aArea)
	
Return()