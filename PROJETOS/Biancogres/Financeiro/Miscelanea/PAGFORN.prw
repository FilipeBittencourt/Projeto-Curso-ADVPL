#include "rwMake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PAGFORN        ºAutor  ³BRUNO MADALENO      º Data ³  22/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LANCAMENTOS PADRAO PARA PAGAMENTO DE FORNECEDORES 530 001        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    

User Function PAGFORN()
LOCAL MENSAGENS := ""

//COMO ESTAVA ANTES
// IIF(SE2->E2_PREFIXO=="COM","COMISSAO S/VENDAS RECEBIDAS","VR PGTO S/"+ALLTRIM(SE2->E2_TIPO)+" "+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +LEFT(SA2->A2_NREDUZ,16))                        

IF SE2->E2_NATUREZ = "PIS" .AND. ALLTRIM(SE2->E2_ORIGEM) <> 'FISA001' //NAO PODE SER APURACAO //Thiago Haagensen - Ticket 26730
	MENSAGENS := "VLR PAGO DE CSRF" // + " " + ALLTRIM(SE2->E2_NUM)

ELSEIF SE2->E2_NATUREZ = "PIS" .AND. SE2->E2_ORIGEM = 'FISA001' //APURACAO //Thiago Haagensen - Ticket 26730
	MENSAGENS := "VLR PAGTO PIS APURADO EM MÊS ANTERIOR" // + " " + ALLTRIM(SE2->E2_NUM)  	

ELSEIF SE2->E2_NATUREZ = "COFINS" .AND. ALLTRIM(SE2->E2_ORIGEM) <> 'FISA001' //NAO PODE SER APURACAO //Thiago Haagensen - Ticket 26730
	MENSAGENS := "VLR PAGO DE CSRF" //+ " " + ALLTRIM(SE2->E2_NUM)
	
	ELSEIF SE2->E2_NATUREZ = "COFINS" .AND. SE2->E2_ORIGEM = 'FISA001' //APURACAO //Thiago Haagensen - Ticket 26730
	MENSAGENS := "VLR PAGTO COFINS APURADO EM MÊS ANTERIOR" // + " " + ALLTRIM(SE2->E2_NUM)  
	
ELSEIF SE2->E2_NATUREZ = "CSLL" //Thiago Haagensen - Ticket 26730
	MENSAGENS := "VLR PAGO DE CSRF" // + " " + ALLTRIM(SE2->E2_NUM)	

ELSEIF SE2->E2_NATUREZ = "2802"
	MENSAGENS := "VALOR PGTO ISS RETIDO"	

ELSEIF SE2->E2_NATUREZ = "2801"
	MENSAGENS := "VALOR PGTO IRRF"	

ELSEIF SE2->E2_NATUREZ = "2603"
	MENSAGENS := "VALOR PGTO FGTS"	

ELSEIF SE2->E2_NATUREZ = "2804"
	MENSAGENS := "VALOR PGTO CONT.SINDICAL"	

ELSEIF SE2->E2_NATUREZ = "2805"
	MENSAGENS := "VALOR PGTO ICMS FRETE"

ELSEIF SE2->E2_NATUREZ = "ICMS"
	MENSAGENS := "VALOR PGTO ICMS REF"

ELSEIF SE2->E2_NATUREZ = "ICMSDIF"
	MENSAGENS := "VALOR PGTO ICMS DIF.ALIQ."
	
ELSEIF SE2->E2_NATUREZ = "ICMSDIF"
	MENSAGENS := "VALOR PGTO ICMS DIF.ALIQ."

ELSEIF	SE2->E2_NATUREZ = "2602" .AND. SE2->E2_FORNECE = "INSS"
	MENSAGENS := "VALOR PGTO INSS"

ELSEIF	SE2->E2_NATUREZ = "2602" .AND. SE2->E2_FORNECE = "INPS"
	MENSAGENS := "VALOR PGTO INSS TERCEIROS"

ELSEIF SE2->E2_PREFIXO ="COM"
	MENSAGENS := "COMISSAO S/VENDAS RECEBIDAS"

//|Pontin - 18.07.18 - OS 6885 |
ElseIf SE2->E2_PREFIXO == "GPE"
	MENSAGENS := "VR PGTO " + ALLTRIM(SE2->E2_TIPO) + " " + ALLTRIM(SE2->E2_NUM)+" "+AllTrim(LEFT(SA2->A2_NREDUZ,16)) + " " + SE2->E2_HIST

//Thiago Haagensen - Ticket 26075
 		MENSAGENS := "DIVID. ANTEC. P/ " + " " + ALLTRIM(SA2->A2_NOME)

ELSE
	MENSAGENS := "VR PGTO " + ALLTRIM(SE2->E2_TIPO) + " " + ALLTRIM(SE2->E2_NUM)+" "+LEFT(SA2->A2_NREDUZ,16)
END IF
	
RETURN(MENSAGENS)


//Thiago Haagensen - Ticket 26730 - Tratar os cancelamentos
USER FUNCTION CANCFOR()

LOCAL CMENSAGENS :=""

IF	ALLTRIM(SE2->E2_NATUREZ) == "2994" .AND. ALLTRIM(SE2->E2_FORNECE) $ "003198/000524/002575/003187/004926/004680/000534/002912/005137/005096/005135/005138/005136"
 		CMENSAGENS := "CNC DE DIVID. ANTEC. P/ " + " " + ALLTRIM(SA2->A2_NOME) //Ticket 26788

ELSEIF ALLTRIM(SE2->E2_NATUREZ) $ "PIS/COFINS" .AND. SE2->E2_ORIGEM = "FISA001"
	CMENSAGENS := "CNC DE BAIXA DE APUR. EM MES ANT." // + " " + ALLTRIM(SE2->E2_TIPO)+" "+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +SUBSTR(SE2->E2_NOMFOR,1,14)

ELSEIF 	ALLTRIM(SE2->E2_NATUREZ) $ "PIS/COFINS/CSLL" .AND. SE2->E2_ORIGEM <> "FISA001"
	CMENSAGENS:= "CNC DE VLR PAGO DE CSRF" //+ SE2->E2_PREFIXO + " " + ALLTRIM(SE2->E2_TIPO) + " " + ALLTRIM(SE2->E2_NUM) + " " + ALLTRIM(SE2->E2_PARCELA) + "  " + SUBSTR(SE2->E2_NOMFOR,1,14)

ELSE
	CMENSAGENS := "CNC VR PGTO S/"+ALLTRIM(SE2->E2_TIPO) +" "+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +;
	SUBSTR(SE2->E2_NOMFOR,1,14)

ENDIF

RETURN (CMENSAGENS)
