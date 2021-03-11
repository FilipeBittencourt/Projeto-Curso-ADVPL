#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA194         
# AUTOR......: Rubens Junior 
# DATA.......: 25/08/2014
# DESCRICAO..: Validacao do campo C5_YPRZINC e C5_YDTINC
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function BIA194()

Local lRet := .T.    
Local aArea := GetArea()
Local cGrupo := "" 
Local cSQL

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
	Return(.T.)
EndIf

If(M->C5_YPRZINC < 0)                                            
	MSGSTOP("Não Permitido Valor Menor que 0","BIA194")
	lRet := .F.
EndIf

If lRet
//BUSCA GRUPO DO CLIENTE ORIGINAL CASO A VENDA NAO SEJA DIRETA PARA O CLIENTE	
	If ((cEmpAnt == "01") .Or. (cEmpAnt == "05")) .And. (M->C5_CLIENTE == "010064") 
	
		cSQL := " SELECT A1_GRPVEN FROM " +RetSqlName("SA1")+ " SA1 WHERE A1_COD = '"+M->C5_YCLIORI+"' AND A1_LOJA = '"+M->C5_YLOJORI+"' AND D_E_L_E_T_ = '' "

		If chkfile("QRY")                               
			QRY->(dbCloseArea())
		EndIf
		TCQUERY cSQL ALIAS "QRY" NEW  
		
		IF !QRY->(EOF())
			cGrupo := QRY->A1_GRPVEN
		EndIf
		//cGrupo := Posicione("SA1",1,xFilial("SA1")+M->C5_YCLIORI+M->C5_YLOJORI,"A1_GRPVEN")	
	Else
		cGrupo := SA1->A1_GRPVEN
	EndIf                                                                                  
	
	If(cGrupo == '000010') 		//GRUPO C&C		
		If(M->C5_YPRZINC > 220)
			MSGSTOP("Não Permitido Valor Maior que 220 dias","BIA194")
			lRet := .F.
		EndIf
	Else
		//ticket 30743 - parâmetro criado devido a alterações comuns no valor.
		limMax := GetMV("MV_YMAXINC")
		IF(M->C5_YPRZINC > limMax)
			MSGSTOP("Não Permitido Valor Maior que " + Alltrim(STR(limMax)) + " dias","BIA194")
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet


User Function BIA194_2()

Local lRet := .T.

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
	Return(.T.)
EndIf

//IF(M->C5_YDTINC - M->C5_EMISSAO >60)
IF (M->C5_YDTINC - M->C5_EMISSAO > 90)	//ALTERADO PARA 90 DIAS CONFORME SOLICITAÇÃO DO VALMIR - 28/10/15
	If Dtos(M->C5_YDTINC) >= "20190102"	//Permitido utilizar a database até 01/01/19, conforme solicitação do Valmir - ticket 7011 
		MSGSTOP("Não Permitido Valor Maior que 90 dias da Emissão do Pedido","BIA194_2")
		lRet := .F.
	EndIf
EndIf

Return lRet