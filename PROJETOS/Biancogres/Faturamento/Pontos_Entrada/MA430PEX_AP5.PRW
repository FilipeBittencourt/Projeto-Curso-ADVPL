#include "rwmake.ch"
#INCLUDE "ACESSOS.CH"
#Include "FWMVCDEF.CH"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao	 � MA430PEX� Autor � WLADIMIR I. N. SANTANNA � Data � 09/12/01 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao � Permite a exclusao de empenhos de exportacao somente para...潮�
北�			 � usuario liberados.									       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se a localizacao atual e uma localizacao de exportacao. Se sim..�
//� verifica se o usuario possui o direito de excluir reservas para export.  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
			msg += "N鉶 � poss韛el excluir reservas autom醫icas de pedido por esta tela."+chr(13)+chr(13)
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
			msg += "N鉶 � poss韛el excluir reservas autom醫icas de pedido por esta tela."+chr(13)+chr(13)
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