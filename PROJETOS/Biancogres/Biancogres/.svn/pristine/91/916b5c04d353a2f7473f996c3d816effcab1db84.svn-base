#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := SPDPIS09
Empresa   := Biancogres Cerâmica S/A
Data      := 18/06/12
Uso       := Livros Fiscais
Aplicação := Ponto de entrada executada no final de rotina de geração do ar-
.           quivo de Sped Pis/Cofins para complemento de informações para os
.           Blocos F100, 0150, 0500
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function SPDPIS09()

	Local 	aRetF100 	:= 	{}
	Local	Enter 		:= CHR(13)+CHR(10)

	If cFilAnt == "01"

		RY001 := " SELECT '2' TPOPER,	" + Enter
		RY001 += "        CT1_DTEXIS,	" + Enter
		RY001 += "        CT1_GRUPO,	" + Enter
		RY001 += "        TIPO,			" + Enter
		RY001 += "        NIVEL,		" + Enter
		RY001 += "        CT1_CONTA,	" + Enter
		RY001 += "        CT1_DESC01,	" + Enter
		RY001 += "        CTAREF,		" + Enter
		RY001 += "        SUM(SALDO) MOVIMENT,	" + Enter
		RY001 += "        CASE	" + Enter
		RY001 += "          WHEN SUBSTRING(CT1_CONTA, 1, 3) = '414' THEN	" + Enter
		RY001 += "            '06'	" + Enter
		RY001 += "          ELSE	" + Enter
		RY001 += "            '07'	" + Enter
		RY001 += "        END CSTMOV	" + Enter
		RY001 += "   FROM (SELECT CT1_DTEXIS,	" + Enter
		RY001 += "                CT1_GRUPO,	" + Enter
		RY001 += "                'A' TIPO,	" + Enter
		RY001 += "                '5' NIVEL,	" + Enter
		RY001 += "                CT1_CONTA,	" + Enter
		RY001 += "                CT1_DESC01,	" + Enter
		RY001 += "                (SELECT CVD_CTAREF	" + Enter
		RY001 += "                   FROM " + RetSqlName("CVD")+"	" + Enter
		RY001 += "                  WHERE CVD_FILIAL = '"+xFilial("CVD")+"'	" + Enter
		RY001 += "                    AND CVD_CONTA = CT1_CONTA	" + Enter       
		RY001 += "                    AND CVD_CODPLA = '002'	" + Enter // ALTERADO POR CARLOS JUNQUEIRA - OS 2409-15 SPED CONTABIL
		RY001 += "                    AND D_E_L_E_T_ = ' ') CTAREF, " + Enter
		RY001 += "                SALDO	" + Enter
		RY001 += "           FROM (SELECT CQ1_CONTA, " + Enter
		RY001 += "                        SUM(CQ1_DEBITO - CQ1_CREDIT) * ( -1 ) SALDO " + Enter
		RY001 += "                   FROM "+RetSqlName("CQ1")+" CQ1 " + Enter
		//|OS 0914-17 - Tania informou que para a empresa 06 (JK) deve considerar todas as filiais |
		If cEmpAnt == "06"
			RY001 += "                  WHERE CQ1_FILIAL > '' " + Enter
		Else
			RY001 += "                  WHERE CQ1_FILIAL = '"+xFilial("CQ1")+"' " + Enter
		EndIf
		RY001 += "                    AND CQ1_DATA BETWEEN '"+dtos(ParamIXB[2])+"' AND '"+dtos(ParamIXB[3])+"' " + Enter
		If cEmpAnt <> "02"
			RY001 += "                    AND SUBSTRING(CQ1_CONTA, 1, 3) IN( '414', '415' ) " + Enter
			RY001 += "                    AND CQ1_CONTA NOT IN('41501001') " + Enter
		Else
			RY001 += "                    AND SUBSTRING(CQ1_CONTA, 1, 3) IN( '341' ) " + Enter
		EndIf
		RY001 += "                    AND CQ1.D_E_L_E_T_ = ' ' " + Enter
		RY001 += "                  GROUP BY CQ1_CONTA) AS VALORES " + Enter
		RY001 += "          INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"' " + Enter
		RY001 += "                               AND CT1_CONTA = CQ1_CONTA " + Enter
		RY001 += "                               AND D_E_L_E_T_ = ' ') AS OUTROS " + Enter
		RY001 += "  GROUP BY CT1_DTEXIS, " + Enter
		RY001 += "           CT1_GRUPO, " + Enter
		RY001 += "           TIPO, " + Enter
		RY001 += "           NIVEL, " + Enter
		RY001 += "           CT1_CONTA, " + Enter
		RY001 += "           CT1_DESC01, " + Enter
		RY001 += "           CTAREF " + Enter
		RY001 += "  ORDER BY CT1_DTEXIS, " + Enter
		RY001 += "           CT1_GRUPO, " + Enter
		RY001 += "           TIPO, " + Enter
		RY001 += "           NIVEL, " + Enter
		RY001 += "           CT1_CONTA, " + Enter
		RY001 += "           CT1_DESC01, " + Enter
		RY001 += "           CTAREF " + Enter
		TcQuery RY001 ALIAS "RY01" NEW
		dbSelectArea("RY01")
		dbGoTop()
		While !Eof()

			yk_TpOper := RY01->TPOPER
			yk_CstMov := RY01->CSTMOV
			yk_BaseIp := 0
			yk_PerPIS := 0
			yk_ValPIS := 0
			yk_PerCOF := 0
			yk_ValCOF := 0
			If cEmpAnt == "13" .and. Alltrim(RY01->CT1_CONTA) == "41501010"
				yk_TpOper := "1"
				yk_CstMov := "01"
				yk_BaseIp := RY01->MOVIMENT
				yk_PerPIS := 1.65
				yk_ValPIS := RY01->MOVIMENT * 1.65 / 100
				yk_PerCOF := 7.60
				yk_ValCOF := RY01->MOVIMENT * 7.60 / 100
			EndIf

			If Alltrim(UPPER(FunName())) <> "FISA001"

				Aadd( aRetF100, {	'F100'	    	,;      // F100 - 01 - REG
				yk_TpOper                       	,;   	// F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
				' '	      	                    	,;      // F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
				''	  	                        	,;  	// F100 - 04 - COD_ITEM
				ParamIXB[3]                     	,;     	// F100 - 05 - DT_OPER
				RY01->MOVIMENT                  	,;      // F100 - 06 - VL_OPER
				yk_CstMov                       	,;     	// F100 - 07 - CST_PIS
				yk_BaseIp  		                	,;      // F100 - 08 - VL_BC_PIS
				yk_PerPIS  		                	,;      // F100 - 09 - ALIQ_PIS
				yk_ValPIS                       	,;      // F100 - 10 - VL_PIS
				yk_CstMov                       	,;     	// F100 - 11 - CST_COFINS
				yk_BaseIp	              	    	,;     	// F100 - 12 - VL_BC_COFINS
				yk_PerCOF  	            	    	,;      // F100 - 13 - ALIQ_COFINS
				yk_ValCOF              	    		,;     	// F100 - 14 - VL_COFINS
				''	                   		    	,;     	// F100 - 15 - NAT_BC_CRED
				''			                    	,;      // F100 - 16 - IND_ORIG_CRED
				RY01->CT1_CONTA                 	,;      // F100 - 17 - COD_CTA
				''			                    	,;      // F100 - 18 - COD_CCUS
				RY01->CT1_DESC01                	,;  	// F100 - 19 - DESC_DOC_OPER
				''			                    	,;      // F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
				''			                    	,;      // F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
				''		                        	,;      // 0150 - 02 - COD_PART
				''                   	        	,;   	// 0150 - 03 - NOME
				''      	              	    	,;      // 0150 - 04 - COD_PAIS
				''	                            	,;  	// 0150 - 05 - CNPJ
				''		     	                	,;     	// 0150 - 06 - CPF
				''    		                    	,;      // 0150 - 07 - IE
				''      		                	,;      // 0150 - 08 - COD_MUN
				''	                     	    	,;      // 0150 - 09 - SUFRAMA
				''                    		    	,;      // 0150 - 10 - END
				''		                  	    	,;      // 0150 - 11 - NUM
				''	                     	    	,;     	// 0150 - 12 - COMPL
				''                    	        	,;     	// 0150 - 13 - BAIRRO
				stod(RY01->CT1_DTEXIS) 	         	,;		// 0500 - 02 - DT_ALT
				StrZero(Val(RY01->CT1_GRUPO),2)     ,;		// 0500 - 03 - COD_NAT_CC
				RY01->TIPO                      	,;		// 0500 - 04 - IND_CTA
				RY01->NIVEL	                   		,;		// 0500 - 05 - NIVEL
				RY01->CT1_CONTA                 	,;		// 0500 - 06 - COD_CTA
				RY01->CT1_DESC01              		,;		// 0500 - 07 - NOME_CTA
				RY01->CTAREF          		      	,;		// 0500 - 08 - COD_CTA_REF
				''                      	        })		// 0500 - 09 - CNPJ_EST

			Else

				Aadd( aRetF100, {	'F100'	    	,;      // F100 - 01 - REG
				yk_TpOper                       	,;   	// F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
				' '	      	                    	,;      // F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
				''	  	                        	,;  	// F100 - 04 - COD_ITEM
				ParamIXB[3]                     	,;     	// F100 - 05 - DT_OPER
				RY01->MOVIMENT                  	,;      // F100 - 06 - VL_OPER
				yk_CstMov                       	,;     	// F100 - 07 - CST_PIS
				yk_BaseIp  		                	,;      // F100 - 08 - VL_BC_PIS
				yk_PerPIS  		                	,;      // F100 - 09 - ALIQ_PIS
				yk_ValPIS                       	,;      // F100 - 10 - VL_PIS
				yk_CstMov                       	,;     	// F100 - 11 - CST_COFINS
				yk_BaseIp	              	    	,;     	// F100 - 12 - VL_BC_COFINS
				yk_PerCOF  	            	    	,;      // F100 - 13 - ALIQ_COFINS
				yk_ValCOF              	    		,;     	// F100 - 14 - VL_COFINS
				''	                   		    	,;     	// F100 - 15 - NAT_BC_CRED
				''			                    	,;      // F100 - 16 - IND_ORIG_CRED
				RY01->CT1_CONTA                 	,;      // F100 - 17 - COD_CTA
				''			                    	,;      // F100 - 18 - COD_CCUS
				RY01->CT1_DESC01                	,;  	// F100 - 19 - DESC_DOC_OPER
				''			                    	,;      // F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
				''			                    	,;      // F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
				''		                        	,;      // 0150 - 02 - COD_PART
				''                   	        	,;   	// 0150 - 03 - NOME
				''      	              	    	,;      // 0150 - 04 - COD_PAIS
				''	                            	,;  	// 0150 - 05 - CNPJ
				''		     	                	,;     	// 0150 - 06 - CPF
				''    		                    	,;      // 0150 - 07 - IE
				''      		                	,;      // 0150 - 08 - COD_MUN
				''	                     	    	,;      // 0150 - 09 - SUFRAMA
				''                    		    	,;      // 0150 - 10 - END
				''		                  	    	,;      // 0150 - 11 - NUM
				''	                     	    	,;     	// 0150 - 12 - COMPL
				''                    	        	,;     	// 0150 - 13 - BAIRRO
				stod(RY01->CT1_DTEXIS) 	         	,;		// 0500 - 02 - DT_ALT **stod(RY01->CT1_DTEXIS)
				StrZero(Val(RY01->CT1_GRUPO),2)     ,;		// 0500 - 03 - COD_NAT_CC
				RY01->TIPO                      	,;		// 0500 - 04 - IND_CTA
				RY01->NIVEL	                   		,;		// 0500 - 05 - NIVEL
				RY01->CT1_CONTA                 	,;		// 0500 - 06 - COD_CTA
				RY01->CT1_DESC01              		,;		// 0500 - 07 - NOME_CTA
				RY01->CTAREF          		      	,;		// 0500 - 08 - COD_CTA_REF
				''                      	        ,;		// 0500 - 09 - CNPJ_EST
				''                                  ,; //Codigo da tabela da Natureza da Receita. ********* Deste ponto para baixa implentado em 02/09/16
				''                                  ,; //Codigo da Natureza da Receita
				''                                  ,; //Grupo da Natureza da Receita
				ctod("//")                          ,; //Dt.Fim Natureza da Receita
				ctod("//")                          ,; // 0600 - 02 - DT_ALT ** padrão 01102012
				''                                  ,; // 0600 - 03 - COD_CCUS ** padrão 11111
				''                                  ,; // 0600 - 04 - CCUS ** padrão CENTRO DE CUSTO
				'SA1'                               }) // SA1 para considerar cadastro de cliente, ou SA2 para considerar cadastro de Fornecedor

			EndIf

			dbSelectArea("RY01")
			dbSkip()

		End
		RY01->(dbCloseArea())

	EndIf

	aRetF100 	:= 	{}

Return ( aRetF100 )
