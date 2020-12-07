#include "rwmake.ch"

/*/{Protheus.doc} FA60BDE
@author Tiago Rossini Coradini
@since 13/02/2017
@version 1.0
@description Atualiza instrucoes bancarias do Bordero de Cobranca.
@obs Também gera e grava o NossoNumero
@history 06/10/1999, Cesar Magnago, Inclusão do P.E. para atualizar instrucoes bancarias.
@history 25/02/2010, Ranisses A. Corona, Gerar e gravar NossoNumero.
@history 21/11/2018, Ranisses A. Corona, Ajustes na gravaca do NossoNumero para titulos de ICMS ST para dentro do ES.
@type function
/*/

User Function FA60BDE()
Local aArea := GetArea()
	
	If SE1->E1_PORTADO == "001" //Banco do Brasil
		RecLock("SE1", .F.)
		SE1->E1_OCORREN	:= "01"
		SE1->E1_INSTR1	:= "01"
		SE1->E1_INSTR2	:= "07"
		SE1->E1_YPRZPTO	:= "00"
		SE1->(MsUnLock())	
	ElseIf SE1->E1_PORTADO == "021" //Banestes	
		RecLock("SE1", .F.)	
		SE1->E1_OCORREN	:= "01"
		SE1->E1_INSTR1	:=  "00"
		SE1->E1_INSTR2	:= "00"
		SE1->E1_YPRZPTO	:= "00"	
		SE1->(MsUnLock())
	ElseIf SE1->E1_PORTADO == "291" //BCN	
		RecLock("SE1", .F.)		
		SE1->E1_OCORREN	:= "01"
		SE1->E1_INSTR1	:= "90"
		SE1->E1_INSTR2	:= "00"
		SE1->E1_YPRZPTO	:= "00"		
		SE1->(MsUnLock())			
	EndIf
	
	// Funcao para Geracao do NossoNumero 1-ST 2-BOL 3-NF
	If Alltrim(SE1->E1_PORTADO) $ "001/021" .and. Alltrim(SE1->E1_NUMBCO) == "" .And. Alltrim(SE1->E1_YFORMA) == "1" .And. !Alltrim(E1_YCLASSE) $ '1_2'		
		If Alltrim(SE1->E1_TIPO) $ ("NF_FT")				
			RecLock("SE1", .F.)
			SE1->E1_NUMBCO := U_fGeraNossoNumero("3")			
			SE1->(MsUnLock())			
		EndIf		
	EndIf

	// Regrava Nosso Numero para a ST e BOL
	If (Alltrim(SE1->E1_NATUREZ) == "1230" .Or. Alltrim(SE1->E1_TIPO) $ "ST/BOL") .And. Empty(Alltrim(SE1->E1_NUMBCO)) .And. !Empty(Alltrim(SE1->E1_YNUMBCO)) .And. Alltrim(SE1->E1_YCLASSE) <> "4"  		
		RecLock("SE1", .F.)		
		SE1->E1_NUMBCO := SE1->E1_YNUMBCO	
		SE1->(MsUnLock())		
	EndIf

	RestArea(aArea)
	
Return()