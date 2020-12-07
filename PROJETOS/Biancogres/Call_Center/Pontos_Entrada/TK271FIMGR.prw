#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK271FIMGR ³ Autor ³ BRUNO MADALENO        ³ Data ³ 04/02/10   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ PONTO DE ENTRADA NA TELA DO CALL CENTER                       ³±±
±±³          ³ PONTO DE ENTRADA NO FIM DA GRAVACAO PARA COMPLEMENTO          ³±±
±±³          ³ DE DADOS ADICIONAIS                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELECOBRANCA                                                  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function TK271FIMGR()

	Local I

	PRIVATE CSQL 	:= ""
	PRIVATE ENTER	:= CHR(13)+CHR(10)

	IF ALLTRIM(cUserName) == "TATIANE"
		RETURN
	END IF

	FOR I := 1 TO LEN(ACOLS)

		// ATUALIZANDO O HISTORICO INFORMADO NO CALL CENTER PARA O TITULO 
		IF ACOLS[I][9] = "BI"
			CSQL := "UPDATE SE1010 SET E1_HIST = '"+ACOLS[I][22]+"' " + ENTER
			CSQL += "WHERE	E1_FILIAL = '"+XFILIAL("SE1")+"' AND " + ENTER
			CSQL += "		E1_PREFIXO = '"+ACOLS[I][2]+"' AND " + ENTER
			CSQL += "		E1_NUM = '"+ACOLS[I][1]+"' AND " + ENTER
			CSQL += "		E1_PARCELA = '"+ACOLS[I][3]+"' AND " + ENTER
			CSQL += "		E1_TIPO = '"+ACOLS[I][4]+"' AND " + ENTER
			CSQL += "		D_E_L_E_T_ = '' " + ENTER
		ELSEIF ACOLS[I][9] = "IN"
			CSQL := "UPDATE SE1050 SET E1_HIST = '"+ACOLS[I][22]+"' " + ENTER
			CSQL += "WHERE	E1_FILIAL = '"+XFILIAL("SE1")+"' AND " + ENTER
			CSQL += "		E1_PREFIXO = '"+ACOLS[I][2]+"' AND " + ENTER
			CSQL += "		E1_NUM = '"+ACOLS[I][1]+"' AND " + ENTER
			CSQL += "		E1_PARCELA = '"+ACOLS[I][3]+"' AND " + ENTER
			CSQL += "		E1_TIPO = '"+ACOLS[I][4]+"' AND " + ENTER
			CSQL += "		D_E_L_E_T_ = '' " + ENTER	
		ELSEIF ACOLS[I][9] = "LM"
			CSQL := "UPDATE SE1070 SET E1_HIST = '"+ACOLS[I][22]+"' " + ENTER
			CSQL += "WHERE	E1_FILIAL = '"+XFILIAL("SE1")+"' AND " + ENTER
			CSQL += "		E1_PREFIXO = '"+ACOLS[I][2]+"' AND " + ENTER
			CSQL += "		E1_NUM = '"+ACOLS[I][1]+"' AND " + ENTER
			CSQL += "		E1_PARCELA = '"+ACOLS[I][3]+"' AND " + ENTER
			CSQL += "		E1_TIPO = '"+ACOLS[I][4]+"' AND " + ENTER
			CSQL += "		D_E_L_E_T_ = '' " + ENTER	

			// Vitcer - OS: 2087-14 - Usuário: Clebes Jose Andre
		ELSEIF ACOLS[I][9] = "VC"
			CSQL := "UPDATE SE1140 SET E1_HIST = '"+ACOLS[I][22]+"' " + ENTER
			CSQL += "WHERE	E1_FILIAL = '"+XFILIAL("SE1")+"' AND " + ENTER
			CSQL += "		E1_PREFIXO = '"+ACOLS[I][2]+"' AND " + ENTER
			CSQL += "		E1_NUM = '"+ACOLS[I][1]+"' AND " + ENTER
			CSQL += "		E1_PARCELA = '"+ACOLS[I][3]+"' AND " + ENTER
			CSQL += "		E1_TIPO = '"+ACOLS[I][4]+"' AND " + ENTER
			CSQL += "		D_E_L_E_T_ = '' " + ENTER			
		END IF
		TCSQLEXEC(CSQL)
	NEXT

RETURN