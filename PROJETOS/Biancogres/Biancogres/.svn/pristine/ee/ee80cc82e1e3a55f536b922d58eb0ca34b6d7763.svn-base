#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"

/*/{Protheus.doc} MTA097
@author Tiago Rossini Coradini
@since 29/12/2017
@version 1.0
@description Ponto de entrada para envio de e-mail para o aprovador após a aprovação 
@obs Ticket: 1146 - Projeto Demandas Compras - Item 2 - Complemento 1
@type function
/*/

User Function MTA097()
Local aAreaSCR	:= SCR->(GetArea())
Local aAreaSC7	:= SC7->(GetArea())
Local cArq		:= ""
Local cInd		:= 0
Local cReg		:= 0

Private cNumPed
Private cDtIncl
Private cDtLibe
Private	wEmail1
Private	cRemet1
Private	wUsuario1
Private	wEmail2
Private	cRemet2
Private	wUsuario2

//Armazena area de Trabalho
cArq := Alias()
cInd := IndexOrd()
cReg := Recno()
ConOut("HORA: "+TIME()+" - LINHA 35 - ROTINA MT094LOKANALISE - MTA097")	
DbSelectArea("SCR")
cNumPed := SCR->CR_NUM
cDtIncl := SCR->CR_YDTINCL
cDtLibe := SCR->CR_DATALIB

lOk := .F.
	
EMAIL_APRO()
ConOut("HORA: "+TIME()+" - LINHA 44 - ROTINA MT094LOKANALISE - MTA097")	
// Avalia se envia e-mail automatico
U_BIAF091(AllTrim(cNumPed), "A")
ConOut("HORA: "+TIME()+" - LINHA 47 - ROTINA MT094LOKANALISE - MTA097")	
// Alteração automática das datas de entrega e de chegada apos aprovação do pedido
U_BIAF093(AllTrim(cNumPed), cDtIncl, cDtLibe)
ConOut("HORA: "+TIME()+" - LINHA 50 - ROTINA MT094LOKANALISE - MTA097")	
RestArea(aAreaSC7)
RestArea(aAreaSCR)
ConOut("HORA: "+TIME()+" - LINHA 53 - ROTINA MT094LOKANALISE - MTA097")	
//Volta area de Trabalho
DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(.T.)


// ENVIA PEDIDO DE COMPRA POR EMAIL PARA APROVACAO
Static Function EMAIL_APRO()
ConOut("HORA: "+TIME()+" - LINHA 64 - ROTINA MT094LOKANALISE - MTA097")
	//Bucar dados do Aprovador
	PswOrder(1)
	PswSeek(__cUserID, .T.)
	wUsuario2 := PswRet(1)[1][1]
	wNome2 := PswRet(1)[1][4]  
	wEmail2 := AllTrim(PswRet(1)[1][14])
	ConOut("HORA: "+TIME()+" - LINHA 71 - ROTINA MT094LOKANALISE - MTA097")	
	//Bucar dados do Comprador
	DbSelectArea("SC7")
	If !Empty(SC7->C7_USER)
		
		PswOrder(1)
		PswSeek(SC7->C7_USER, .T.)
		wUsuario1 := PswRet(1)[1][1]  
		wNome1 := PswRet(1)[1][4]  
		wEmail1 := AllTrim(PswRet(1)[1][14])
		
	Else
		
		wUsuario1 := "Administrador"
		wEmail1 := "wanisay.william@biancogres.com.br"
		
	EndIf
	ConOut("HORA: "+TIME()+" - LINHA 88 - ROTINA MT094LOKANALISE - MTA097")	
	CRIA_EMAIL()
    ConOut("HORA: "+TIME()+" - LINHA 90 - ROTINA MT094LOKANALISE - MTA097")	
Return()


// ROTINA PARA CRIAR O EMAIL
Static Function CRIA_EMAIL()
Local lOk
ConOut("HORA: "+TIME()+" - LINHA 97 - ROTINA MT094LOKANALISE - MTA097")	
	cData := DTOC(DDATABASE)
	cTitulo := "Pedido de compra "
	cMensagem := "Email enviado automaticamente pelo PROTHEUS. " + CHR(13)+CHR(10)
	cMensagem += "Informamos que foi liberado, no sistema Protheus, o pedido de compra numero: "+cNumPed+" pelo Sr(a). "+PADC(wNome2,50)+CHR(13)+CHR(10)
	cMensagem += "Atenciosamente,"+CHR(13)+CHR(10)
	cMensagem += CHR(13)+CHR(10)
	cMensagem += PADC(" Setor de Compras",50)+CHR(13)+CHR(10)
ConOut("HORA: "+TIME()+" - LINHA 105 - ROTINA MT094LOKANALISE - MTA097")		
	If SUBSTR(ALLTRIM(SM0->M0_NOMECOM),1,1) == 'B'
		cMensagem += "Biancogres Ceramica S/A"
	ElseIf SUBSTR(ALLTRIM(SM0->M0_NOMECOM),1,1) == 'I'
		cMensagem += "Incesa Revestimento Ceramico LTDA"
	ElseIF SUBSTR(ALLTRIM(SM0->M0_NOMECOM),1,1) == 'V'
		cMensagem += "Vitcer Retifica e Complementos Ceramicos LTDA"
	Else
		cMensagem += "Biancogres Ceramica S/A"	
	EndIf
	
	cMensagem += CHR(13)+CHR(10)
	cMensagem += CHR(13)+CHR(10)
	cMensagem += CHR(13)+CHR(10)
ConOut("HORA: "+TIME()+" - LINHA 119 - ROTINA MT094LOKANALISE - MTA097")	
	lOk := U_BIAEnvMail(,wEmail1, cTitulo, cMensagem) 
ConOut("HORA: "+TIME()+" - LINHA 121 - ROTINA MT094LOKANALISE - MTA097")	
	If !lOk
		MsgBox("Erro ao enviar o e-mail", "Alerta", "STOP")
	EndIf 

Return()