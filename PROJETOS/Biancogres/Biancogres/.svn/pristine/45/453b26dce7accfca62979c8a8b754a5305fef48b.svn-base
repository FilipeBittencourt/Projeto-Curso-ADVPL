#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"

User Function BIA618()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Marcos Alberto Soprani
	Programa  := BIA618
	Empresa   := Biancogres Cerâmica S/A
	Data      := 15/01/16
	Uso       := Financeiro / Contabilização
	Aplicação := Geração da conta de débito para o Lançamento Padrão 532-001
	.
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
	
	//Thiago Haagensen - Ticket 25773 - Adicionado a regra as condições: E2_TIPO "FT" e E2_ORIGEM "FISA001".
	//Local rtConta := IIF(Alltrim(SE2->E2_TIPO) $ "TX/FT" .and. Alltrim(SE2->E2_NATUREZ) $ "PIS_COFINS_CSLL" .and. Alltrim(SE2->E2_ORIGEM) <> "FISA001", "21103013",SA2->A2_CONTA)
	Local rtConta := SA2->A2_CONTA
	Local rtAreaO := GetArea()
	Local I
	
	//Thiago Haagensen - Ticket 26075
	//IF rtConta == ""
	IF (Alltrim(SE2->E2_TIPO) $ "TX/FT" .and. Alltrim(SE2->E2_NATUREZ) $ "PIS_COFINS_CSLL" .and. Alltrim(SE2->E2_ORIGEM) <> "FISA001")
		rtConta := "21103013"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ) == "2994" .AND. ALLTRIM(SE2->E2_FORNECE) $ "003198/000524/002575/003187/004926/004680/000534/002912/005137/005096/005135/005138/005136"
		rtConta := "11205030"
	ENDIF
	
	//Thiago Haagensen - Ticket 26169 - Tratativa feita substituindo  a regra abaixo (LP 531/002) mantendo a lógica anterior
	//IIF(SE2->E2_PREFIXO == "COM",'21102003',IIF(SE2->E2_FORNECE=="000426".AND.ALLTRIM(SE2->E2_TIPO)<>"PA",'11202001',IF(ALLTRIM(SE2->E2_NATUREZ)=="2805","21103003",POSICIONE("SA2",1,XFILIAL("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_CONTA"))))                                                               
	IF EMPTY(SE2->E2_BAIXA) //QUER DIZER QUE ESTA CANCELANDO BAIXA - 531-002
		IF ALLTRIM(SE2->E2_PREFIXO) == "COM"
			rtConta :=  '21102003'
		ENDIF
		
		IF SE2->E2_FORNECE=="000426" .AND. ALLTRIM(SE2->E2_TIPO)<>"PA"
			rtConta := '11202001'
		ENDIF
		
		IF ALLTRIM(SE2->E2_NATUREZ)=="2805"
			rtConta := '21103003'
		ENDIF 
		
		//Thiago Haagensen - Ticket 26075
		IF ALLTRIM(SE2->E2_NATUREZ) == "2994" .AND. ALLTRIM(SE2->E2_FORNECE) $ "003198/000524/002575/003187/004926/004680/000534/002912/005137/005096/005135/005138/005136"
			rtConta:="11205030"
		ENDIF
	ENDIF                                                         
	                                                              
	/*
	Local rtConta := IIF(Alltrim(SE2->E2_TIPO) == "TX" .and. (Alltrim(SE2->E2_NATUREZ)) $ "PIS_COFINS_CSLL", "21103013", SA2->A2_CONTA)
	Local rtAreaO := GetArea()
	Local I
	*/
	If Alltrim(SE2->E2_PREFIXO) == "ICM" .and. Alltrim(SE2->E2_TIPO) == "TX"

		//RT007 := " SELECT COUNT(*) CONTAD "
		RT007 := " SELECT * "
		RT007 += "   FROM "+RetSqlName("SE2")+" SE2 "
		RT007 += "  INNER JOIN "+RetSqlName("SF6")+" SF6 ON F6_FILIAL = '"+xFilial("SF6")+"' "
		RT007 += "                       AND F6_NUMERO = E2_PREFIXO+E2_NUM "
		//RT007 += "                       AND F6_CODREC IN('100080','100102','100129') "
		RT007 += "                       AND SF6.D_E_L_E_T_ = ' ' "
		RT007 += "  WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
		RT007 += "    AND E2_PREFIXO = 'ICM' "
		RT007 += "    AND E2_NUM = '"+SE2->E2_NUM+"' "
		RT007 += "    AND E2_PARCELA = '"+SE2->E2_PARCELA+"' "
		RT007 += "    AND E2_TIPO = 'TX ' "
		RT007 += "    AND E2_FORNECE = '"+SE2->E2_FORNECE+"' "
		RT007 += "    AND E2_LOJA = '"+SE2->E2_LOJA+"' "
		RT007 += "    AND SE2.D_E_L_E_T_ = ' ' "
		RTIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT007),'RT07',.T.,.T.)
		dbSelectArea("RT07")
		dbGoTop()
		//If RT07->CONTAD >= 1
		//	rtConta := "21103018"
		//EndIf
		If !RT07->(Eof())
			If RT07->F6_TIPOIMP == "B"		//DIFAL
				rtConta := "21103018"
			ElseIf RT07->F6_TIPOIMP == "3"	//ICMS ST
				rtConta := "21103015"
			//Thiago Haagensen - Ticket 26549
			ELSEIF CEMPANT == "07" .AND. SE2->E2_FILIAL == "05" .AND. ALLTRIM(SE2->E2_PREFIXO) == "ICM" .AND. ALLTRIM(SE2->E2_TIPO) == "TX" .AND. ALLTRIM(SE2->E2_NATUREZ) == "2831" .AND. ALLTRIM(SE2->E2_ORIGEM) == "MATA953"
				rtConta:="21103001"
				
		    //Thiago Haagensen - Ticket 24151 (Contabilização do pagamento de Diferencial de alíquota usando F6_CODREC)
		    //129-5 ICMS - Diferencial Aliquota da Industria/ 128-7 ICMS - Diferencial Aliquota do Comercio
			Elseif (ALLTRIM(RT07->F6_CODREC) == '129-5' .or. ALLTRIM(RT07->F6_CODREC) == '128-7') .and. alltrim(RT07->E2_ORIGEM) == 'MATA953' //ICMS DIFERENCIAL																				
				rtConta	:='21103002'
				
			Endif
		EndIf
		RT07->(dbCloseArea())  
		Ferase(RTIndex+GetDBExtension())
		Ferase(RTIndex+OrdBagExt())

		// OS 7226 - Marcelo Sousa Correa - Acerto para contemplar conta de pagamento para Dividendos. 	
		// OS 11599 - Marcelo Sousa Correa - Acerto para contemplar pagamento de dividendos em outras empresas. 
	ELSEIF Alltrim(SE2->E2_NATUREZ) $ "2998/2997" 

		IF Alltrim(SE2->E2_NATUREZ) == "2998"

			aForn := {}

			aAdd(aForn,{"EMA","CASOTTI FIL","CAMERINO","DARKS","KELMER","DANIKEN","TERLAGO","TRENTINI","SP300","DNK","ADIGE"})
			aAdd(aForn,{"21109001000006","21109001000004","21109001000001","21109001000002","21109001000003","21109001000005","21109001000010",;
			"21109001000011","21109001000012","21109001000013","21109001000014"})

			FOR I := 1 TO LEN(aForn[1])

				IF aForn[1,I] $ Alltrim(SE2->E2_NOMFOR) 

					rtConta := aForn[2,I]

				ENDIF 

			NEXT 
			// OS 9277 - Marcelo Sousa Correa - Acerto para contemplar juros na contabilização das baixas.
			// OS 11599 - Marcelo Sousa Correa - Acerto para contemplar pagamento de juros em outras empresas.
		ELSEIF Alltrim(SE2->E2_NATUREZ) == "2997"

			aForn := {}

			aAdd(aForn,{"EMA","CASOTTI FIL","CAMERINO","DARKS","KELMER","DANIKEN","TERLAGO","TRENTINI","SP300","DNK","ADIGE"})
			aAdd(aForn,{"21105001000001","21105001000005","21105001000002","21105001000003","21105001000004","21105001000006","21105001000007",;
			"21105001000008","21105001000009","21105001000011","21105001000010"})

			FOR I := 1 TO LEN(aForn[1])

				IF aForn[1,I] $ Alltrim(SE2->E2_NOMFOR) 

					rtConta := aForn[2,I]

				ENDIF 

			NEXT 

		ENDIF

	ELSEIF Alltrim(SE2->E2_PREFIXO) = "GPE"

		IF SE2->E2_NOMFOR $ "SENAI" 

			rtConta := "21104010"

		ELSEIF SE2->E2_NOMFOR $ "SESI"

			rtConta := "21104012"

		ENDIF
	
	//Thiago Haagensen - Ticket 25770 - Acerto de contabilização para conta 21103006, 21103005 e 21103013. Tratativa pela natureza e prefixo.
	//Conforme Sidiclei, não há necessidade de controlar por empresa e cód. retenção, devido as variações existentes.
	ELSEIF ALLTRIM(SE2->E2_PREFIXO) == "COF" .AND. ALLTRIM(SE2->E2_NATUREZ) == "COFINS" .AND. ALLTRIM(SE2->E2_ORIGEM) == "FISA001" //(.AND. CEMPANT == "06" .AND. ALLTRIM(SE2->E2_CODRET) == "2172")
	 	rtConta:="21103006"
	 	
	ELSEIF ALLTRIM(SE2->E2_PREFIXO) == "PIS" .AND. ALLTRIM(SE2->E2_NATUREZ) == "PIS" .AND. ALLTRIM(SE2->E2_ORIGEM) == "FISA001" //(.AND. CEMPANT == "06" .AND. ALLTRIM(SE2->E2_CODRET) == "8109")
	 	rtConta:="21103005"
	/*
	//Regra adicionada logo acima
	ELSEIF ALLTRIM(SE2->E2_NATUREZ) == "PIS/COFINS/CSLL" .AND. ALLTRIM(SE2->E2_ORIGEM) == "FINA290" .AND. ALLTRIM(SE2->E2_TIPO) == "FT/TX" //(.AND. CEMPANT == "06" .AND. ALLTRIM(SE2->E2_CODRET) == "")
	 	rtConta:="21103013"
	*/
	
	ENDIF

	RestArea(rtAreaO)

Return ( rtConta )


//Thiago Haagensen - Ticket 26075 - Tratar os lançamentos da conta de débito para o LP 532-001
//IIF(SE2->E2_PREFIXO=="COM","COMISSAO S/VENDAS RECEBIDAS","VR PGTO "+ALLTRIM(SE2->E2_TIPO)+" "+ALLTRIM(SE2->E2_NUM)+" "+LEFT(SA2->A2_NREDUZ,16))
USER FUNCTION LP532001()

LOCAL CMENSAGENS := ""

IF	ALLTRIM(SE2->E2_NATUREZ) == "2994" .AND. ALLTRIM(SE2->E2_PREFIXO) <> "COM" .AND. ALLTRIM(SE2->E2_FORNECE) $ "003198/000524/002575/003187/004926/004680/000534/002912/005137/005096/005135/005138/005136"
 		CMENSAGENS := "DIVID. ANTEC. P/ " + " " + ALLTRIM(SA2->A2_NOME)											

ELSEIF 	ALLTRIM(SE2->E2_PREFIXO) == "COM"
			CMENSAGENS := "COMISSAO S/VENDAS RECEBIDAS"
ELSE
	CMENSAGENS := "VR PGTO " + ALLTRIM(SE2->E2_TIPO) + " " + ALLTRIM(SE2->E2_NUM) + " " + LEFT(SA2->A2_NREDUZ,16)
ENDIF

RETURN (CMENSAGENS)

//Thiago Haagensen - Ticket 26788
//Os fornecedores foram fixados a pedido do cliente, já que apenas estes casos necessitam de tratativa para Item de Conta.
USER FUNCTION ITEMCD()

LOCAL CITEMCONTACD := ""
	IF ALLTRIM(SE2->E2_NATUREZ) == "2994"
		IF ALLTRIM(SE2->E2_FORNECE) == "003198" 
			CITEMCONTACD := "DIVPF0001"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "000524" 
			CITEMCONTACD := "DIVPF0003"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "002575" 
			CITEMCONTACD := "DIVPF0004"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "003187" 
			CITEMCONTACD := "DIVPF0005"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "004926" 
			CITEMCONTACD := "DIVPF0002"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "004680" 
			CITEMCONTACD := "DIVPF0006"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "000534" 
			CITEMCONTACD := "DIV000001"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "002912" 
			CITEMCONTACD := "DIV000005"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "005137" 
			CITEMCONTACD := "DIV000008"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "005096" 
			CITEMCONTACD := "DIV000009"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "005135" 
			CITEMCONTACD := "DIV000003"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "005138" 
			CITEMCONTACD := "DIV000011"
		
		ELSEIF ALLTRIM(SE2->E2_FORNECE) == "005136" 
			CITEMCONTACD := "DIV000010"
		ENDIF
	ENDIF

RETURN(CITEMCONTACD)
