#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch" 
#INCLUDE "FONT.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³REL_ARE   ºAutor  ³    MADALENO        º Data ³  27/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATORIO DE RESUMO DA AREA NO FATURAMENTO                 º±±
±±º          ³                                                         	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FATURAMENTO ( RELATORIO DE RESUMO DA AREA )                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                      
User Function REL_ARE()
	PRIVATE CSQL  := ""
	PRIVATE ENTER := chr(13) + Chr(10)

	U_LOG_USO("REL_ARE")

	cDesc1   := "Este programa tem como objetivo emitir um relat¢rio dos" 
	cDesc2   := "produtos vendidos por Vendedor"                
	cDesc3   := ""
	tamanho  := "M"
	limite   := 132 
	cString  := "SA3"
	aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog := "REL_AR"
	aLinha   := { }
	titulo   := "Posicao de Vendas p/ Vendedor"
	nLastKey := 0
	cPerg    := "REL_AR"
	wnrel    := "REL_AR"
	wNumber  := 0
	wTotGcx  := 0         
	wTotGm2  := 0         
	wTotGpt  := 0
	wPrazo   := 0
	Cabec1   := "" //PRODUTO                                   PRECO               MEDIA               M2              CAIXAS                    PRECO" 
	Cabec2   := ""//                                          UNIT.               PRAZO                                                         TOTAL"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria parametros se nao existir e chama os parametros na tela           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ValidPerg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	c15      := 15
	cbtxt    := space(10)
	cbcont   := 0
	li       := 01
	wColuna  := 00
	m_pag    := 1

	If !GetRemoteType() == 5 .And. !__cUserID="000996"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia controle para a funcao SETPRINT                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)
		pergunte("REL_AR",.F.)
		If nLastKey == 27
			Return
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Posicao do Formulario na Impressora                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetDefault(aReturn,cString)
		If nLastKey == 27
			Return
		End
	Else
		If !Pergunte(cPerg,.T.)
			Return
		EndIf
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta as view para o relatorio                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! empty(CREPATU)
		_VEND_DE := MV_PAR03
		_VEND_AT := MV_PAR04
		MV_PAR03 := CREPATU
		MV_PAR04 := CREPATU
	END IF

	Processa( {|| fMonta_view() } )

	//******************INICIO
	If GetRemoteType() == 5 .Or. __cUserID="000996"
		RptStatus({|| U_BIAREL_ARETR() })

	Else
		Processa( {|| fImpressao() } )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera impressao                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  aReturn[5] == 1
		Set Printer To
		Ourspool(wnrel)
	End
	MS_FLUSH()

RETURN


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ fMonta_view                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Monta arquivo de trabalho                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fMonta_view()

	////VIEW RESPONSAVEL PELO CABCALHO DO RELATORIO
	////CSQL  := "ALTER VIEW RES_ARE_CABEC AS " + ENTER
	//CSQL  := "SELECT 	SA1B.A1_COD, SA1B.A1_NOME, SA1B.A1_VEND, SA1B.A1_MUN, SA1B.A1_EST, SA3.A3_NOME, SA1B.A1_LC,  " + ENTER
	//CSQL  += "	( ISNULL(SA1I.A1_SALDUP,0) + ISNULL(PED_PENI.VALOR_PED,0) + ISNULL(SA1B.A1_SALDUP,0) + ISNULL(PED_PEN.VALOR_PED,0)  ) AS LIMITE_TOMADO,   " + ENTER
	//CSQL  += "	( SA1B.A1_LC - (ISNULL(SA1I.A1_SALDUP,0) + ISNULL(PED_PENI.VALOR_PED,0) + ISNULL(SA1B.A1_SALDUP,0) + ISNULL(PED_PEN.VALOR_PED,0)) ) AS SALDO  " + ENTER
	//CSQL  += "FROM	SA1010 SA1B, SA1050 SA1I, SA3010 SA3,  " + ENTER
	//CSQL  += "	(     " + ENTER
	//CSQL  += "	--************ PEDIDO PENDENTES ********************  " + ENTER
	//CSQL  += "	SELECT C5_CLIENTE, SUM(C6_VALOR) VALOR_PED  " + ENTER
	//CSQL  += "	FROM SC5010 SC5, SC6010 SC6, SF4010 SF4, SB1010 SB1  " + ENTER
	//CSQL  += "	WHERE	C5_NUM = C6_NUM AND  " + ENTER
	//CSQL  += "		C5_CLIENTE = C6_CLI AND  " + ENTER
	//CSQL  += "		C5_LOJACLI = C6_LOJA AND  " + ENTER
	//CSQL  += "		C6_PRODUTO = B1_COD AND   " + ENTER
	//CSQL  += "		C6_TES = F4_CODIGO AND  " + ENTER
	//CSQL  += "		F4_DUPLIC = 'S' AND   " + ENTER
	//CSQL  += "		B1_GRUPO = 'PA' AND  " + ENTER
	//CSQL  += "		C6_QTDVEN - C6_QTDENT > 0 AND  " + ENTER
	//CSQL  += "		SC5.D_E_L_E_T_ = '' AND  " + ENTER
	//CSQL  += "		SC6.D_E_L_E_T_ = '' AND  " + ENTER
	//CSQL  += "		SB1.D_E_L_E_T_ = '' AND  " + ENTER
	//CSQL  += "		SF4.D_E_L_E_T_ = ''   " + ENTER
	//CSQL  += "	GROUP BY C5_CLIENTE) AS PED_PEN, " + ENTER
	//CSQL  += " " + ENTER
	//CSQL  += "	(     " + ENTER
	//CSQL  += "	--************ PEDIDO PENDENTES ********************  " + ENTER
	//CSQL  += "	SELECT C5_CLIENTE, SUM(C6_VALOR) VALOR_PED  " + ENTER
	//CSQL  += "	FROM SC5050 SC5, SC6050 SC6, SF4050 SF4, SB1010 SB1  " + ENTER
	//CSQL  += "	WHERE	C5_NUM = C6_NUM AND  " + ENTER
	//CSQL  += "		C5_CLIENTE = C6_CLI AND  " + ENTER
	//CSQL  += "		C5_LOJACLI = C6_LOJA AND  " + ENTER
	//CSQL  += "		C6_PRODUTO = B1_COD AND   " + ENTER
	//CSQL  += "		C6_TES = F4_CODIGO AND  " + ENTER
	//CSQL  += "		F4_DUPLIC = 'S' AND   " + ENTER
	//CSQL  += "		B1_GRUPO = 'PA' AND  " + ENTER
	//CSQL  += "		C6_QTDVEN - C6_QTDENT > 0 AND  " + ENTER
	//CSQL  += "		SC5.D_E_L_E_T_ = '' AND  " + ENTER
	//CSQL  += "		SC6.D_E_L_E_T_ = '' AND  " + ENTER
	//CSQL  += "		SB1.D_E_L_E_T_ = '' AND  " + ENTER
	//CSQL  += "		SF4.D_E_L_E_T_ = ''   " + ENTER
	//CSQL  += "	GROUP BY C5_CLIENTE) AS PED_PENI " + ENTER
	//CSQL  += "WHERE 	SA1B.A1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND  " + ENTER
	//if empty(CREPATU) 
	//	IF ALLTRIM(cempant) = "05"
	//		CSQL  += "			SA1B.A1_YVENDI BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
	//	ELSE
	//		CSQL  += "			SA1B.A1_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
	//	END IF
	//ELSE

	//	IF SUBSTRING(cRepAtu,1,1) = "1"
	//		IF CEMPANT == "01"
	//			CSQL  += "			SA1B.A1_VEND BETWEEN '"+_VEND_DE+"' AND '"+_VEND_AT+"' AND " + ENTER
	//			CSQL += "			(SA1B.A1_YVENDB2 = '"+cRepAtu+"' OR  SA1B.A1_YVENDB3 = '"+cRepAtu+"') AND " + Enter
	//		ELSE
	//			CSQL  += "			SA1B.A1_YVENDI BETWEEN '"+_VEND_DE+"' AND '"+_VEND_AT+"' AND " + ENTER
	//			CSQL += "			(SA1B.A1_YVENDI2 = '"+cRepAtu+"' OR  SA1B.A1_YVENDI3 = '"+cRepAtu+"') AND " + Enter		
	//		END IF
	//	ELSE
	//		IF ALLTRIM(cempant) = "05"
	//			CSQL  += "			SA1B.A1_YVENDI BETWEEN '"+CREPATU+"' AND '"+CREPATU+"' AND " + ENTER
	//		ELSE
	//			CSQL  += "			SA1B.A1_VEND BETWEEN '"+CREPATU+"' AND '"+CREPATU+"' AND " + ENTER
	//		END IF
	//	END IF

	//END IF

	//CSQL  += "	SA1B.A1_COD = SA1I.A1_COD AND         " + ENTER
	//CSQL  += "	SA3.A3_COD = SA1B.A1_VEND AND  " + ENTER
	//CSQL  += "	PED_PEN.C5_CLIENTE =* SA1B.A1_COD AND  " + ENTER
	//CSQL  += "	PED_PENI.C5_CLIENTE =* SA1I.A1_COD AND " + ENTER
	//CSQL  += "	SA1I.D_E_L_E_T_ = ''  AND  " + ENTER
	//CSQL  += "	SA1B.D_E_L_E_T_ = ''  AND  " + ENTER
	//CSQL  += "	SA1B.A1_ULTCOM >= CONVERT(VARCHAR(8),DATEADD(day,-60,GETDATE()),112)   " + ENTER
	//CSQL  += "	ORDER BY  SA1B.A1_NOME    " + ENTER



	//ATUALIZAÇÃO QUERY - SQL ATUAL - 19/01/2016
	//VIEW RESPONSAVEL PELO CABCALHO DO RELATORIO
	//CSQL  := "ALTER VIEW RES_ARE_CABEC AS " + ENTER
	CSQL  := "SELECT 	SA1B.A1_COD, SA1B.A1_NOME, SA1B.A1_VEND, SA1B.A1_MUN, SA1B.A1_EST, SA3.A3_NOME, SA1B.A1_LC,  " + ENTER
	CSQL  += "	( ISNULL(SA1I.A1_SALDUP,0) + ISNULL(PED_PENI.VALOR_PED,0) + ISNULL(SA1B.A1_SALDUP,0) + ISNULL(PED_PEN.VALOR_PED,0)  ) AS LIMITE_TOMADO,   " + ENTER
	CSQL  += "	( SA1B.A1_LC - (ISNULL(SA1I.A1_SALDUP,0) + ISNULL(PED_PENI.VALOR_PED,0) + ISNULL(SA1B.A1_SALDUP,0) + ISNULL(PED_PEN.VALOR_PED,0)) ) AS SALDO  " + ENTER
	CSQL  += "FROM	SA1010 SA1B
	CSQL  += "	INNER JOIN SA1050 SA1I
	CSQL  += "		ON SA1B.A1_COD = SA1I.A1_COD
	CSQL  += "			AND SA1I.D_E_L_E_T_ = ''
	CSQL  += "	INNER JOIN SA3010 SA3
	CSQL  += "		ON SA3.A3_COD = SA1B.A1_VEND
	CSQL  += "	LEFT JOIN (     
	CSQL  += "				--************ PEDIDO PENDENTES ********************  
	CSQL  += "				SELECT C5_CLIENTE, SUM(C6_VALOR) VALOR_PED  
	CSQL  += "				FROM SC5010 SC5, SC6010 SC6, SF4010 SF4, SB1010 SB1  
	CSQL  += "				WHERE	C5_NUM = C6_NUM AND  
	CSQL  += "					C5_CLIENTE = C6_CLI AND  
	CSQL  += "					C5_LOJACLI = C6_LOJA AND  
	CSQL  += "					C6_PRODUTO = B1_COD AND   
	CSQL  += "					C6_TES = F4_CODIGO AND  
	CSQL  += "					F4_DUPLIC = 'S' AND   
	CSQL  += "					B1_GRUPO = 'PA' AND  
	CSQL  += "					C6_QTDVEN - C6_QTDENT > 0 AND  
	CSQL  += "					SC5.D_E_L_E_T_ = '' AND  
	CSQL  += "					SC6.D_E_L_E_T_ = '' AND  
	CSQL  += "					SB1.D_E_L_E_T_ = '' AND  
	CSQL  += "					SF4.D_E_L_E_T_ = ''   
	CSQL  += "				GROUP BY C5_CLIENTE) AS PED_PEN
	CSQL  += "		ON SA1B.A1_COD = PED_PEN.C5_CLIENTE
	CSQL  += "	LEFT JOIN (     
	CSQL  += "				--************ PEDIDO PENDENTES ********************  
	CSQL  += "				SELECT C5_CLIENTE, SUM(C6_VALOR) VALOR_PED  
	CSQL  += "				FROM SC5050 SC5, SC6050 SC6, SF4050 SF4, SB1010 SB1  
	CSQL  += "				WHERE	C5_NUM = C6_NUM AND  
	CSQL  += "					C5_CLIENTE = C6_CLI AND  
	CSQL  += "					C5_LOJACLI = C6_LOJA AND  
	CSQL  += "					C6_PRODUTO = B1_COD AND   
	CSQL  += "					C6_TES = F4_CODIGO AND  
	CSQL  += "					F4_DUPLIC = 'S' AND   
	CSQL  += "					B1_GRUPO = 'PA' AND  
	CSQL  += "					C6_QTDVEN - C6_QTDENT > 0 AND  
	CSQL  += "					SC5.D_E_L_E_T_ = '' AND  
	CSQL  += "					SC6.D_E_L_E_T_ = '' AND  
	CSQL  += "					SB1.D_E_L_E_T_ = '' AND  
	CSQL  += "					SF4.D_E_L_E_T_ = ''   
	CSQL  += "				GROUP BY C5_CLIENTE) AS PED_PENI
	CSQL  += "		ON SA1I.A1_COD = PED_PENI.C5_CLIENTE
	CSQL  += "WHERE 	SA1B.A1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND  
	if empty(CREPATU) 
		IF ALLTRIM(cempant) = "05"
			CSQL  += "			SA1B.A1_YVENDI BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND 
		ELSE
			CSQL  += "			SA1B.A1_VEND BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND 
		END IF
	ELSE

		IF SUBSTRING(cRepAtu,1,1) = "1"
			IF CEMPANT == "01"
				CSQL  += "		SA1B.A1_VEND BETWEEN '" + _VEND_DE + "' AND '" + _VEND_AT + "' AND 
				CSQL  += "		(SA1B.A1_YVENDB2 = '" + cRepAtu + "' OR  SA1B.A1_YVENDB3 = '" + cRepAtu + "') AND 
			ELSE
				CSQL  += "		SA1B.A1_YVENDI BETWEEN '" + _VEND_DE + "' AND '" + _VEND_AT + "' AND 
				CSQL  += "		(SA1B.A1_YVENDI2 = '" + cRepAtu + "' OR  SA1B.A1_YVENDI3 = '" + cRepAtu + "') AND 		
			END IF
		ELSE
			IF ALLTRIM(cempant) = "05"
				CSQL  += "		SA1B.A1_YVENDI BETWEEN '" + CREPATU + "' AND '" + CREPATU + "' AND 
			ELSE
				CSQL  += "		SA1B.A1_VEND BETWEEN '" + CREPATU + "' AND '" + CREPATU + "' AND 
			END IF
		END IF
	END IF
	CSQL  += "	SA1B.D_E_L_E_T_ = ''  AND  
	CSQL  += "	SA1B.A1_ULTCOM >= CONVERT(VARCHAR(8),DATEADD(day,-60,GETDATE()),112)   
	CSQL  += "ORDER BY  SA1B.A1_NOME



	//TCSQLExec(CSQL)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ fMonta_view                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Monta arquivo de trabalho                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImpressao()
	LOCAL wCodVend := ""
	LOCAL wCodClie := ""
	LOCAL CLINHA := ""
	LOCAL wTotal_A := 0
	LOCAL wTotal_B := 0
	LOCAL wTotal_C := 0
	LOCAL wTotal_C_Q := 0

	//CSQL := "SELECT * FROM RES_ARE_CABEC "
	If chkfile("_cTrab")
		dbSelectArea("_cTrab")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_cTrab" NEW                                           


	//************************************************************************
	//************************************************************************
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ LOOP PARA RODOR TODOS OS CLIENTES E FORNECEDORES                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//************************************************************************
	//************************************************************************

	li := 100
	While ! _cTrab->(eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa regua                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProc()
		If li >= 55
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			li := 05
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quebra do Vendedor                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _cTrab->A1_VEND <> wCodVend
			wCodVend := _cTrab->A1_VEND
			@ li,002 PSAY " "
			li ++
			@ li,002 PSAY "VENDEDOR: " + _cTrab->A1_VEND + " - " + _cTrab->A3_NOME
			li ++
			@ li,002 PSAY " "
			li ++
		end if

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quebra do CLIENTE                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _cTrab->A1_COD <> wCodClie
			wCodClie := _cTrab->A1_COD
			@ li,003 PSAY REPLICATE("=", 121)
			li ++
			@ li,003 PSAY " "
			li ++
			@ li,010 PSAY PADL("CLIENTE: " + _cTrab->A1_COD + " - " + _cTrab->A1_NOME,70) + PADL("CIDADE: " + ALLTRIM(_cTrab->A1_MUN) + " - ESTADO: " + ALLTRIM(_cTrab->A1_EST),40)
			li ++
			@ li,010 PSAY " "
			li ++
			@ li,015 PSAY PADL("LIMITE DE CREDITO",20) + PADL("LIMITE TOMADO",20) + PADL("SALDO",20)
			li ++    //  
			@ li,021 PSAY A1_LC Picture "@E 999,999,999.99"
			@ li,041 PSAY LIMITE_TOMADO Picture "@E 999,999,999.99"
			@ li,061 PSAY SALDO Picture "@E 999,999,999.99"	
			li ++
		end if



		//*************************************************************************
		//*************************************************************************
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IMPRIMINDO OS TITULOS VENCIDO NOS PROXIMOS 7 DIAS                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//*************************************************************************
		//*************************************************************************
		//  VIEW RESPONSAVEL PELO QUADO A
		// TITULOS VENCIDO OU A VENCER NOS PROXIMOS 7 DIAS

		//CSQL  := "ALTER VIEW RES_ARE_A AS  " + ENTER
		CSQL  := "SELECT 	E1_CLIENTE, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_VALOR, " + ENTER
		CSQL  += "	CONVERT(VARCHAR(8), DATEDIFF(DAY,SE1.E1_VENCTO,GETDATE()),112) AS ATRASO    " + ENTER
		CSQL  += "FROM "+RETSQLNAME("SE1")+" SE1 " + ENTER
		CSQL  += "WHERE E1_VENCTO <= CONVERT(VARCHAR(8),   DATEADD(day,7,GETDATE())  ,112) AND " + ENTER
		CSQL  += "		E1_CLIENTE BETWEEN '"+_cTrab->A1_COD+"' AND '"+_cTrab->A1_COD+"' AND  " + ENTER
		//CSQL  += "	E1_VEND1 BETWEEN '"+_cTrab->A1_VEND+"' AND '"+_cTrab->A1_VEND+"' AND " + ENTER
		CSQL  += "		E1_SALDO > 0 AND " + ENTER
		CSQL  += "		E1_TIPO <> 'RA'  AND " + ENTER 
		CSQL  += "		D_E_L_E_T_ = '' " + ENTER
		CSQL  += "		ORDER BY SE1.E1_VENCTO " + ENTER
		//-TCSQLExec(CSQL)

		//CSQL := "SELECT * FROM RES_ARE_A "
		If chkfile("_A")
			dbSelectArea("_A")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_A" NEW	

		IF ! _A->(eof())       
			If li >= 55
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				li := 05
			Endif
			li++
			li++
			@ li,010 PSay "a) TITULOS VENCIDOS OU A VENCER NOS PRÓXIMOS 7 DIAS
			li++			
			@ li,010 PSay " " + REPLICATE("_", 92)
			li++
			@ li,010 PSAY "|" + REPLICATE(" ",10) + "|" + REPLICATE(" ",10) + "|" + REPLICATE(" ",10) + "|" + REPLICATE(" ",10) + "|" + REPLICATE(" ",10) + "|" + REPLICATE(" ",10) + "|" + REPLICATE(" ",15) + "|" + REPLICATE(" ",10) + "|" 
			li++
			@ li,010 PSAY "|" + PADC("SERIE",10) + "|" + PADC("TITULO",10) + "|" + PADC("PARCELA",10) + "|" + PADC("TIPO",10) + "|" + PADC("EMISSÃO",10) + "|" + PADC("VENCIMENTO",10) + "|" + PADC("VALOR",15) + "|" + PADC("ATRASO",10) + "|" 
			li++
			@ li,010 PSay "|" + REPLICATE("_",10) + "|" + REPLICATE("_",10) + "|" + REPLICATE("_",10) + "|" + REPLICATE("_",10) + "|" + REPLICATE("_",10) + "|" + REPLICATE("_",10) + "|" + REPLICATE("_",15) + "|" + REPLICATE("_",10) + "|" 
			li++
		END IF
		wTotal_A := 0
		DO WHILE ! _A->(eof())
			If li >= 63
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				li := 05
			Endif
			CLINHA := PADC(_A->E1_PREFIXO,12)
			CLINHA += PADC(_A->E1_NUM,11)
			CLINHA += PADC(_A->E1_PARCELA,11)
			CLINHA += PADC(_A->E1_TIPO,11)
			CLINHA += PADC(STOD(_A->E1_EMISSAO),11)
			CLINHA += PADC(STOD(_A->E1_VENCTO),11)
			CLINHA += PADC(_A->E1_VALOR,16)
			CLINHA += PADC(ALLTRIM(_A->ATRASO),11)
			@ li,010 PSAY CLINHA
			li++
			wTotal_A += _A->E1_VALOR
			_A->(DBSKIP())
		End Do
		IF wTotal_A <> 0
			@ li,041 PSAY "TOTAL"
			@ li,074 PSAY wTotal_A Picture "@E 999,999,999.99"
			li++
		END IF



		//*************************************************************************
		//*************************************************************************
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IMPRIMINDO OS PEDIDOS EM CARTEIRA                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//*************************************************************************
		//*************************************************************************
		//  VIEW RESPONSAVEL PELO DO QUADO B
		// PEDIDOS EM CARTEIRA 

		//CSQL  := "ALTER VIEW RES_ARE_B AS  " + ENTER
		CSQL  := "SELECT 	C5_VEND1, C5_CLIENTE, C5_NUM, C5_EMISSAO,  " + ENTER
		CSQL  += "	SUM(C6_QTDVEN) QUANT, SUM(C6_QTDENT) FATURADO, SUM(C6_QTDVEN-C6_QTDENT) SALDO,  " + ENTER
		CSQL  += "       	DATEDIFF(day, C5_EMISSAO, GETDATE()) DIAS, MAX(F4_TEXTO) AS CFOP " + ENTER
		CSQL  += "FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SF4")+" SF4 " + ENTER
		CSQL  += "WHERE C5_NUM = C6_NUM AND " + ENTER
		CSQL  += "      C5_CLIENTE = C6_CLI AND " + ENTER
		CSQL  += "      C6_TES = F4_CODIGO  AND " + ENTER
		CSQL  += "      C6_QTDVEN - C6_QTDENT > 0 AND " + ENTER
		CSQL  += "      C5_VEND1 BETWEEN '"+_cTrab->A1_VEND+"' AND '"+_cTrab->A1_VEND+"' AND  " + ENTER
		CSQL  += "      C5_CLIENTE BETWEEN '"+_cTrab->A1_COD+"' AND '"+_cTrab->A1_COD+"' AND  " + ENTER
		CSQL  += "      SC5.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SC6.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SF4.D_E_L_E_T_ = ''  " + ENTER
		CSQL  += "GROUP BY C5_NUM, C5_EMISSAO, C5_VEND1, C5_CLIENTE " + ENTER
		//TCSQLExec(CSQL)

		//CSQL := "SELECT * FROM RES_ARE_B "
		If chkfile("_B")
			dbSelectArea("_B")                                    
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_B" NEW	

		IF ! _B->(eof())       
			If li >= 55
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				li := 05
			Endif
			li++
			li++
			@ li,010 PSay "b) PEDIDOS EM CARTEIRA:"
			li++			
			@ li,010 PSay " " + REPLICATE("_", 120)
			li++
			@ li,010 PSAY "|" + REPLICATE(" ",10) + "|" + REPLICATE(" ",10) + "|" + REPLICATE(" ",20) + "|" + REPLICATE(" ",17) + "|" + REPLICATE(" ",15) + "|" + REPLICATE(" ",20) + "|" + REPLICATE(" ",22) + "|" 
			li++
			@ li,010 PSAY "|" + PADC("NUMERO",10) + "|" + PADC("EMISSAO",10) + "|" + PADC("QTD.PEDIDO (M2)",20) + "|" + PADC("QTD.FAT (M2)",17) + "|" + PADC("SALDO (M2)",15) + "|" + PADC("DIAS EM CARTEIRA",20) + "|" + PADC("NATUREZA F. OPER",22) + "|" 
			li++
			@ li,010 PSay "|" + REPLICATE("_",10) + "|" + REPLICATE("_",10) + "|" + REPLICATE("_",20) + "|" + REPLICATE("_",17) + "|" + REPLICATE("_",15) + "|" + REPLICATE("_",20) + "|" + REPLICATE("_",22) + "|" 
			li++
		END IF
		wTotal_B := 0
		DO WHILE ! _B->(eof())
			If li >= 55
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				li := 05
			Endif
			CLINHA := PADC(_B->C5_NUM,12)
			CLINHA += PADC(STOD(_B->C5_EMISSAO),11)
			CLINHA += PADC(Transform(_B->QUANT,"@E 999,999,999.99"),21) 
			CLINHA += PADC(Transform(_B->FATURADO,"@E 999,999,999.99"),17)
			CLINHA += PADC(Transform(_B->SALDO,"@E 999,999,999.99"),16)
			CLINHA += PADC(_B->DIAS,22)
			CLINHA += PADL(_B->CFOP,22)
			@ li,010 PSAY CLINHA
			li++
			wTotal_B += _B->SALDO
			_B->(DBSKIP())
		End Do
		IF wTotal_B <> 0
			@ li,041 PSAY "TOTAL"
			@ li,072 PSAY wTotal_B Picture "@E 999,999,999.99"
			li++
		END IF













		//*************************************************************************
		//*************************************************************************
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IMPRIMINDO FATURAMENTO NOS ULTIMOS 5 DIAS                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//*************************************************************************
		//*************************************************************************
		//VIEW RESPONSAVEL PELA VIEW DO QUADO C
		// FATURAMENTO DOS ULTIMOS 5 DIAS
		//CSQL  := "ALTER VIEW RES_ARE_C AS  " + ENTER
		CSQL  := "SELECT F2_CLIENTE, F2_DOC, F2_SERIE, MAX(F2_EMISSAO) EMISSAO, MAX(D2_PEDIDO) PEDIDO, SUM(D2_QUANT) QUANT, SUM(D2_TOTAL) TOTAL, " + ENTER
		CSQL  += "       MAX(E4_DESCRI) COND_PAG, MAX(A4_NOME) TRANSPORTADORA, MAX(F4_TEXTO) NAT_FIS_OPER " + ENTER
		CSQL  += "FROM "+RETSQLNAME("SF2")+" AS SF2,  " + ENTER
		CSQL  += "     "+RETSQLNAME("SD2")+" AS SD2,  " + ENTER
		CSQL  += "     "+RETSQLNAME("SF4")+" AS SF4,  " + ENTER
		CSQL  += "     "+RETSQLNAME("SA4")+" AS SA4, " + ENTER
		CSQL  += "     "+RETSQLNAME("SE4")+" AS SE4  " + ENTER
		CSQL  += "WHERE F2_DOC = D2_DOC AND " + ENTER
		CSQL  += "      F2_CLIENTE = F2_CLIENTE AND " + ENTER
		CSQL  += "      F2_SERIE = D2_SERIE AND " + ENTER
		CSQL  += "      SF2.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SD2.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SF4.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SA4.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SE4.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      D2_TES = F4_CODIGO AND " + ENTER
		CSQL  += "      F2_TRANSP = A4_COD AND " + ENTER
		CSQL  += "      F2_COND = E4_CODIGO AND " + ENTER
		CSQL  += "      F2_VEND1 BETWEEN '"+_cTrab->A1_VEND+"' AND '"+_cTrab->A1_VEND+"' AND " + ENTER
		CSQL  += "      F2_CLIENTE BETWEEN '"+_cTrab->A1_COD+"' AND '"+_cTrab->A1_COD+"' AND " + ENTER
		CSQL  += "      DATEDIFF(day, F2_EMISSAO, GETDATE()) <= 5 " + ENTER
		CSQL  += "GROUP BY F2_DOC, F2_SERIE, F2_CLIENTE, F2_CLIENTE " + ENTER
		TCSQLExec(CSQL)


		//CSQL := "SELECT * FROM RES_ARE_C "
		If chkfile("_C")
			dbSelectArea("_C")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_C" NEW	

		IF ! _C->(eof())       
			If li >= 55
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				li := 05
			Endif
			li++
			li++
			@ li,010 PSay "c) FATURAMENTO NOS ULTIMOS 5 DIAS"
			li++			
			@ li,010 PSay " " + REPLICATE("_", 120)
			li++
			@ li,010 PSAY "|" + PADC(" ",08) + "|" + PADC(" ",06) + "|" + PADC(" ",12) + "|" + PADC(" ",10) + "|" + PADC(" ",11) + "|" + PADC(" ",11) + "|" + PADC(" ",17) + "|" + PADC(" ",20) + "|" + PADC(" ",17) + "|"
			li++
			@ li,010 PSAY "|" + PADC("NF",08) + "|" + PADC("SERIE",06) + "|" + PADC("EMISSAO",12) + "|" + PADC("PEDIDO",10) + "|" + PADC("QTD (M2)",11) + "|" + PADC("VALOR NF",11) + "|" + PADC("COND. PAG",17) + "|" + PADC("TRANSPORTADORA",20) + "|" + PADC("NATUREZA F. OPER",17) + "|"
			li++
			@ li,010 PSay "|" + REPLICATE("_",08) + "|" + REPLICATE("_",06) + "|" + REPLICATE("_",12) + "|" + REPLICATE("_",10) + "|" + REPLICATE("_",11) + "|" + REPLICATE("_",11) + "|" + REPLICATE("_",17) + "|" + REPLICATE("_",20) + "|"+ REPLICATE("_",17) + "|"
			li++
		END IF
		wTotal_C := 0
		wTotal_C_Q := 0
		DO WHILE ! _C->(eof())
			If li >= 55
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				li := 05
			Endif
			CLINHA := PADC(_C->F2_DOC,10)
			CLINHA += PADC(ALLTRIM(_C->F2_SERIE),07)
			CLINHA += PADC(STOD(_C->EMISSAO),13)
			CLINHA += PADC(_C->PEDIDO,11)
			CLINHA += PADC(Transform(_C->QUANT,"@E 999,999.99"),12)
			CLINHA += PADC(Transform(_C->TOTAL,"@E 999,999.99"),12)
			CLINHA += PADC(ALLTRIM(_C->COND_PAG),18)
			CLINHA += PADC(ALLTRIM(_C->TRANSPORTADORA),20) + " "
			CLINHA += PADC(ALLTRIM(_C->NAT_FIS_OPER),19)
			@ li,010 PSAY CLINHA
			li++
			wTotal_C   += _C->TOTAL
			wTotal_C_Q += _C->QUANT
			_C->(DBSKIP())
		End Do
		IF wTotal_C <> 0
			@ li,041 PSAY "TOTAL"                             
			@ li,052 PSAY wTotal_C_Q Picture "@E 999,999.99"
			@ li,065 PSAY wTotal_C   Picture "@E 999,999.99"
			li++
		END IF


		_cTrab->(DBSKIP())
	End Do

Return

/*/                                                                                                

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ValidPerg    ³ Autor ³ MAGNAGO                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas no SX1                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
	Local _j, _i
	Private _aPerguntas := {}

	AAdd(_aPerguntas,{cPerg,"01","Cliente de?         ","","","mv_ch01","C",06,0,0,"G","","mv_par01",""   ,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"02","Cliente Ate?        ","","","mv_ch02","C",06,0,0,"G","","mv_par02",""   ,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	AAdd(_aPerguntas,{cPerg,"03","Representante De?   ","","","mv_ch03","C",06,0,0,"G","","mv_par03",""   ,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"04","Representante Ate?  ","","","mv_ch04","C",06,0,0,"G","","mv_par04",""   ,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})


	DbSelectArea("SX1")
	For _i:= 1 to Len(_aPerguntas)
		If !DbSeek( cPerg + StrZero(_i,2) )
			RecLock("SX1",.T.)
			For _j:= 1 to FCount()
				FieldPut(_j,_aPerguntas[_i,_j])
			Next _j
			MsUnLock()
		Endif
	Next _i
Return 

//----------------------------------------------------------------------------------
// Versão do relatório em TReport.
//----------------------------------------------------------------------------------
User Function BIAREL_ARETR()
	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return

//----------------------------------------------------------------------------------
Static Function ReportDef()
	Local cNomeRep		:= "REL_AR"
	Local cTituloRep 	:= "Posicao de Vendas p/ Vendedor"
	Local cDescRep		:= "Este programa tem como objetivo emitir um relatório dos produtos vendidos por Vendedor"
	Local oBrNF
	Local oBrCli 
	Local oBrVend
	Local Enter := chr(13) + Chr(10)

	oReport:= TReport():New(cNomeRep,cTituloRep,cNomeRep, {|oReport| PrintReport(oReport)},cDescRep)
	Pergunte(oReport:GetParam(),.F.)

	oReport:SetTotalInLine(.F.)
	oReport:lParamPage 		:=.F.
	oReport:lPrtParamPage   :=.F.
	oReport:lXlsParam		:=.F.

	//REPRESENTANTE
	oSecRep := TRSection():New(oReport,OemToAnsi("Repres"),)
	oSecRep:SetLineStyle(.T.)

	TRCell():New(oSecRep,"VEND",,"VENDEDOR",,60,,,"LEFT",,"LEFT")

	//CLIENTE
	//
	oSecCli := TRSection():New(oSecRep,OemToAnsi("Cliente"),,,,,,,,,,,10)
	oSecCli:SetLineStyle(.T.)

	TRCell():New(oSecCli,"CLI",,"CLIENTE",,40,,,"LEFT",,"LEFT")
	TRCell():New(oSecCli,"CID",,"CIDADE",,30,,,"LEFT",,"LEFT")
	TRCell():New(oSecCli,"EST",,"ESTADO",,4,,,"LEFT",,"LEFT")

	//LIMITES E SALDO
	oSecLim := TRSection():New(oSecRep,OemToAnsi("Limites"),,,,,,,,,,,20)
	oSecLim:SetLineStyle(.F.)

	TRCell():New(oSecLim,"LIM_CRED",,"LIMITE CREDITO","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecLim,"LIM_TOMA",,"LIMITE TOMADO","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecLim,"SALDO",,"SALDO","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT") 
	//oSecLim:Cell("LIM_CRED"):SetBorder("ALL",1,,.T.) 
	//oSecLim:Cell("LIM_TOMA"):SetBorder("ALL",1,,.T.) 
	//oSecLim:Cell("SALDO"):SetBorder("ALL",1,,.T.)

	//LINHA A
	oSecLiA := TRSection():New(oSecCli,OemToAnsi("Linha A"),,,,,,,,,,,10)
	oSecLiA:SetLineStyle(.T.)

	TRCell():New(oSecLiA,"LINHAA",,"a) TITULOS VENCIDOS OU A VENCER NOS PRÓXIMOS 7 DIAS",,60,,,"LEFT",,"LEFT")

	//CAMPOS LINHA A
	oSecDdA := TRSection():New(oSecLiA,OemToAnsi("Dados A"),,,,,,,,,,,10)
	oSecDdA:SetLineStyle(.F.)

	TRCell():New(oSecDdA,"SERIE",,"SERIE",,6,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdA,"TITULO",,"TITULO",,11,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdA,"PARCELA",,"PARCELA",,9,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdA,"TIPO",,"TIPO",,6,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdA,"EMISSAO",,"EMISSAO","@D",11,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdA,"VENCTO",,"VENCIMENTO","@D",11,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdA,"VALOR",,"VALOR","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecDdA,"ATRASO",,"ATRASO",,8,,,"RIGHT",,"RIGHT") 
	oSecDdA:Cell("SERIE"):SetBorder("ALL",1,,.T.) 
	oSecDdA:Cell("TITULO"):SetBorder("ALL",1,,.T.) 
	oSecDdA:Cell("PARCELA"):SetBorder("ALL",1,,.T.)
	oSecDdA:Cell("TIPO"):SetBorder("ALL",1,,.T.) 
	oSecDdA:Cell("EMISSAO"):SetBorder("ALL",1,,.T.) 
	oSecDdA:Cell("VENCTO"):SetBorder("ALL",1,,.T.) 
	oSecDdA:Cell("VALOR"):SetBorder("ALL",1,,.T.) 
	oSecDdA:Cell("ATRASO"):SetBorder("ALL",1,,.T.)

	//TOTAL LINHA A
	oSecTlA := TRSection():New(oSecLiA,OemToAnsi("Total A"),,,,,,,,,,,10)
	oSecTlA:SetLineStyle(.F.)

	TRCell():New(oSecTlA,"SERIE",,"",,49,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlA,"TITULO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlA,"PARCELA",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlA,"TIPO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlA,"EMISSAO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlA,"VENCTO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlA,"VALOR",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTlA,"ATRASO",,"",,8,,,"RIGHT",,"RIGHT") 

	//LINHA B
	oSecLiB := TRSection():New(oSecCli,OemToAnsi("Linha B"),,,,,,,,,,,10)
	oSecLiB:SetLineStyle(.T.)

	TRCell():New(oSecLiB,"LINHAB",,"b) PEDIDOS EM CARTEIRA",,60,,,"LEFT",,"LEFT")

	//CAMPOS LINHA B
	oSecDdB := TRSection():New(oSecLiB,OemToAnsi("Dados B"),,,,,,,,,,,10)
	oSecDdB:SetLineStyle(.F.)

	TRCell():New(oSecDdB,"NUMERO",,"NUMERO",,8,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdB,"EMISSAO",,"EMISSAO","@D",11,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdB,"QTDPED",,"QTD. PEDIDO (M2)","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecDdB,"QTDFAT",,"QTD. FAT (M2)","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecDdB,"SALDO",,"SALDO (M2)","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecDdB,"DIASCART",,"DIAS EM CARTEIRA",,18,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecDdB,"NATFOPER",,"NATUREZA F. OPER",,22,,,"LEFT",,"LEFT") 
	oSecDdB:Cell("NUMERO"):SetBorder("ALL",1,,.T.) 
	oSecDdB:Cell("EMISSAO"):SetBorder("ALL",1,,.T.) 
	oSecDdB:Cell("QTDPED"):SetBorder("ALL",1,,.T.) 
	oSecDdB:Cell("QTDFAT"):SetBorder("ALL",1,,.T.) 
	oSecDdB:Cell("SALDO"):SetBorder("ALL",1,,.T.) 
	oSecDdB:Cell("DIASCART"):SetBorder("ALL",1,,.T.) 
	oSecDdB:Cell("NATFOPER"):SetBorder("ALL",1,,.T.)

	//TOTAL LINHA B
	oSecTlB := TRSection():New(oSecLiB,OemToAnsi("Total B"),,,,,,,,,,,10)
	oSecTlB:SetLineStyle(.F.)

	TRCell():New(oSecTlB,"NUMERO",,"",,48,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlB,"EMISSAO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlB,"QTDPED",,"",,1,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTlB,"QTDFAT",,"",,1,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTlB,"SALDO",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTlB,"DIASCART",,"",,18,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTlB,"NATFOPER",,"",,22,,,"LEFT",,"LEFT")

	//LINHA C
	oSecLiC := TRSection():New(oSecCli,OemToAnsi("Linha C"),,,,,,,,,,,10)
	oSecLiC:SetLineStyle(.T.)

	TRCell():New(oSecLiC,"LINHAC",,"c) FATURAMENTO NOS ULTIMOS 5 DIAS",,60,,,"LEFT",,"LEFT")

	//CAMPOS LINHA C
	oSecDdC := TRSection():New(oSecLiC,OemToAnsi("Dados C"),,,,,,,,,,,10)
	oSecDdC:SetLineStyle(.F.)

	TRCell():New(oSecDdC,"NF",,"NF",,8,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdC,"SERIE",,"SERIE",,6,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdC,"EMISSAO",,"EMISSAO","@D",11,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdC,"PEDIDO",,"PEDIDO","@!",8,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdC,"QTD",,"QTD (M2)","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecDdC,"VALORNF",,"VALOR NF","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecDdC,"CONDPAG",,"COND. PAG",,11,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdC,"TRANSP",,"TRANSPORTADORA",,16,,,"LEFT",,"LEFT")
	TRCell():New(oSecDdC,"NATFOPER",,"NATUREZA F. OPER",,22,,,"LEFT",,"LEFT") 
	oSecDdC:Cell("NF"):SetBorder("ALL",1,,.T.) 
	oSecDdC:Cell("SERIE"):SetBorder("ALL",1,,.T.) 
	oSecDdC:Cell("EMISSAO"):SetBorder("ALL",1,,.T.) 
	oSecDdC:Cell("PEDIDO"):SetBorder("ALL",1,,.T.) 
	oSecDdC:Cell("QTD"):SetBorder("ALL",1,,.T.) 
	oSecDdC:Cell("VALORNF"):SetBorder("ALL",1,,.T.) 
	oSecDdC:Cell("CONDPAG"):SetBorder("ALL",1,,.T.) 
	oSecDdC:Cell("TRANSP"):SetBorder("ALL",1,,.T.) 
	oSecDdC:Cell("NATFOPER"):SetBorder("ALL",1,,.T.)

	//TOTAL LINHA C
	oSecTlC := TRSection():New(oSecLiC,OemToAnsi("Total C"),,,,,,,,,,,10)
	oSecTlC:SetLineStyle(.F.)

	TRCell():New(oSecTlC,"NF",,"",,30,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlC,"SERIE",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlC,"EMISSAO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlC,"PEDIDO",,"",,1,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlC,"QTD",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTlC,"VALORNF",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTlC,"CONDPAG",,"",,11,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlC,"TRANSP",,"",,16,,,"LEFT",,"LEFT")
	TRCell():New(oSecTlC,"NATFOPER",,"",,22,,,"LEFT",,"LEFT") 

Return oReport

//----------------------------------------------------------------------------------
Static Function PrintReport(oReport)

	Local oSecRep := oReport:Section(1) //Representante - seção do "relatório"
	Local oSecCli := oReport:Section(1):Section(1) //Cliente - seção de representante
	Local oSecLim := oReport:Section(1):Section(2) //Limites e saldo - seção de representante
	Local oSecLiA := oReport:Section(1):Section(1):Section(1) //Linha A - seção de cliente
	Local oSecDdA := oReport:Section(1):Section(1):Section(1):Section(1) //Campos linha A - seção de linha A
	Local oSecTlA := oReport:Section(1):Section(1):Section(1):Section(2) //Totais linha A - seção de linha A
	Local oSecLiB := oReport:Section(1):Section(1):Section(2) //Linha B - seção de cliente
	Local oSecDdB := oReport:Section(1):Section(1):Section(2):Section(1) //Campos linha B - seção de linha B
	Local oSecTlB := oReport:Section(1):Section(1):Section(2):Section(2) //Totais linha B - seção de linha B
	Local oSecLiC := oReport:Section(1):Section(1):Section(3) //Linha C - seção de cliente
	Local oSecDdC := oReport:Section(1):Section(1):Section(3):Section(1) //Campos linha C - selção de linha C
	Local oSecTlC := oReport:Section(1):Section(1):Section(3):Section(2) //Totais linha C - selção de linha C

	LOCAL wCodVend := ""
	LOCAL wCodClie := ""
	LOCAL CLINHA := ""
	LOCAL wTotal_A := 0
	LOCAL wTotal_B := 0
	LOCAL wTotal_C := 0
	LOCAL wTotal_C_Q := 0

	If chkfile("_cTrab")
		dbSelectArea("_cTrab")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_cTrab" NEW                                           


	//LOOP PARA RODOR TODOS OS CLIENTES E FORNECEDORES
	While ! _cTrab->(eof())

		//Quebra do Vendedor
		If _cTrab->A1_VEND <> wCodVend
			wCodVend := _cTrab->A1_VEND

			oSecRep:Init()

			oSecRep:Cell("VEND"):SetValue(_cTrab->A1_VEND + " - " + _cTrab->A3_NOME)
			oSecRep:PrintLine()
		EndIf

		//Quebra do CLIENTE
		If _cTrab->A1_COD <> wCodClie
			wCodClie := _cTrab->A1_COD

			oReport:SkipLine(1)
			oReport:FatLine()

			oSecCli:Init()

			oSecCli:Cell("CLI"):SetValue(_cTrab->A1_COD + " - " + _cTrab->A1_NOME)
			oSecCli:Cell("CID"):SetValue(ALLTRIM(_cTrab->A1_MUN))
			oSecCli:Cell("EST"):SetValue(ALLTRIM(_cTrab->A1_EST))
			oSecCli:PrintLine()

			//LIMITES E SALDO
			oSecLim:Init()

			oSecLim:Cell("LIM_CRED"):SetValue(_cTrab->A1_LC)
			oSecLim:Cell("LIM_TOMA"):SetValue(_cTrab->LIMITE_TOMADO)
			oSecLim:Cell("SALDO"):SetValue(_cTrab->SALDO)
			oSecLim:PrintLine()
			oSecLim:Finish()
		EndIf

		// TITULOS VENCIDOS OU A VENCER NOS PROXIMOS 7 DIAS
		CSQL  := "SELECT 	E1_CLIENTE, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_VALOR, " + ENTER
		CSQL  += "	CONVERT(VARCHAR(8), DATEDIFF(DAY,SE1.E1_VENCTO,GETDATE()),112) AS ATRASO    " + ENTER
		CSQL  += "FROM "+RETSQLNAME("SE1")+" SE1 " + ENTER
		CSQL  += "WHERE E1_VENCTO <= CONVERT(VARCHAR(8),   DATEADD(day,7,GETDATE())  ,112) AND " + ENTER
		CSQL  += "		E1_CLIENTE BETWEEN '"+_cTrab->A1_COD+"' AND '"+_cTrab->A1_COD+"' AND  " + ENTER
		CSQL  += "		E1_SALDO > 0 AND " + ENTER
		CSQL  += "		E1_TIPO <> 'RA'  AND " + ENTER 
		CSQL  += "		D_E_L_E_T_ = '' " + ENTER
		CSQL  += "		ORDER BY SE1.E1_VENCTO " + ENTER

		If chkfile("_A")
			dbSelectArea("_A")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_A" NEW	

		IF ! _A->(eof())
			//LINHA A
			oSecLiA:Init()

			oSecLiA:Cell("LINHAA"):SetValue(" ")
			oSecLiA:PrintLine()
		EndIf

		wTotal_A := 0

		Do While ! _A->(eof())
			//DADOS LINHA A
			oSecDdA:Init()

			oSecDdA:Cell("SERIE"):SetValue(_A->E1_PREFIXO)
			oSecDdA:Cell("TITULO"):SetValue(_A->E1_NUM)
			oSecDdA:Cell("PARCELA"):SetValue(_A->E1_PARCELA)
			oSecDdA:Cell("TIPO"):SetValue(_A->E1_TIPO)
			oSecDdA:Cell("EMISSAO"):SetValue(DTOC(STOD(_A->E1_EMISSAO)))
			oSecDdA:Cell("VENCTO"):SetValue(DTOC(STOD(_A->E1_VENCTO)))
			oSecDdA:Cell("VALOR"):SetValue(_A->E1_VALOR)
			oSecDdA:Cell("ATRASO"):SetValue(_A->ATRASO)
			oSecDdA:PrintLine()

			wTotal_A += _A->E1_VALOR
			_A->(DBSKIP())
		EndDo

		If wTotal_A <> 0
			oSecTlA:Init()

			oSecTlA:Cell("SERIE"):SetValue("TOTAL")
			oSecTlA:Cell("VALOR"):SetValue(wTotal_A)
			oSecTlA:PrintLine()
		EndIf
		oSecTlA:Finish()
		oSecDdA:Finish()
		oSecLiA:Finish()



		// PEDIDOS EM CARTEIRA 
		CSQL  := "SELECT 	C5_VEND1, C5_CLIENTE, C5_NUM, C5_EMISSAO,  " + ENTER
		CSQL  += "	SUM(C6_QTDVEN) QUANT, SUM(C6_QTDENT) FATURADO, SUM(C6_QTDVEN-C6_QTDENT) SALDO,  " + ENTER
		CSQL  += "       	DATEDIFF(day, C5_EMISSAO, GETDATE()) DIAS, MAX(F4_TEXTO) AS CFOP " + ENTER
		CSQL  += "FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SF4")+" SF4 " + ENTER
		CSQL  += "WHERE C5_NUM = C6_NUM AND " + ENTER
		CSQL  += "      C5_CLIENTE = C6_CLI AND " + ENTER
		CSQL  += "      C6_TES = F4_CODIGO  AND " + ENTER
		CSQL  += "      C6_QTDVEN - C6_QTDENT > 0 AND " + ENTER
		CSQL  += "      C5_VEND1 BETWEEN '"+_cTrab->A1_VEND+"' AND '"+_cTrab->A1_VEND+"' AND  " + ENTER
		CSQL  += "      C5_CLIENTE BETWEEN '"+_cTrab->A1_COD+"' AND '"+_cTrab->A1_COD+"' AND  " + ENTER
		CSQL  += "      SC5.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SC6.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SF4.D_E_L_E_T_ = ''  " + ENTER
		CSQL  += "GROUP BY C5_NUM, C5_EMISSAO, C5_VEND1, C5_CLIENTE " + ENTER

		If chkfile("_B")
			dbSelectArea("_B")                                    
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_B" NEW	

		If ! _B->(eof())
			//LINHA B
			oSecLiB:Init()

			oSecLiB:Cell("LINHAB"):SetValue(" ")
			oSecLiB:PrintLine()
		EndIf

		wTotal_B := 0

		Do While ! _B->(eof())
			//DADOS LINHA B
			oSecDdB:Init()

			oSecDdB:Cell("NUMERO"):SetValue(_B->C5_NUM)
			oSecDdB:Cell("EMISSAO"):SetValue(DTOC(STOD(_B->C5_EMISSAO)))
			oSecDdB:Cell("QTDPED"):SetValue(_B->QUANT)
			oSecDdB:Cell("QTDFAT"):SetValue(_B->FATURADO)
			oSecDdB:Cell("SALDO"):SetValue(_B->SALDO)
			oSecDdB:Cell("DIASCART"):SetValue(_B->DIAS)
			oSecDdB:Cell("NATFOPER"):SetValue(_B->CFOP)
			oSecDdB:PrintLine()

			wTotal_B += _B->SALDO
			_B->(DBSKIP())
		EndDo

		If wTotal_B <> 0
			//@ li,041 PSAY "TOTAL"
			//@ li,072 PSAY wTotal_B Picture "@E 999,999,999.99"
			//li++
			oSecTlB:Init()

			oSecTlB:Cell("NUMERO"):SetValue("TOTAL")
			oSecTlB:Cell("SALDO"):SetValue(wTotal_B)
			oSecTlB:PrintLine()
		EndIf
		oSecTlB:Finish()
		oSecDdB:Finish()
		oSecLiB:Finish()

		// FATURAMENTO DOS ULTIMOS 5 DIAS
		CSQL  := "SELECT F2_CLIENTE, F2_DOC, F2_SERIE, MAX(F2_EMISSAO) EMISSAO, MAX(D2_PEDIDO) PEDIDO, SUM(D2_QUANT) QUANT, SUM(D2_TOTAL) TOTAL, " + ENTER
		CSQL  += "       MAX(E4_DESCRI) COND_PAG, MAX(A4_NOME) TRANSPORTADORA, MAX(F4_TEXTO) NAT_FIS_OPER " + ENTER
		CSQL  += "FROM "+RETSQLNAME("SF2")+" AS SF2,  " + ENTER
		CSQL  += "     "+RETSQLNAME("SD2")+" AS SD2,  " + ENTER
		CSQL  += "     "+RETSQLNAME("SF4")+" AS SF4,  " + ENTER
		CSQL  += "     "+RETSQLNAME("SA4")+" AS SA4, " + ENTER
		CSQL  += "     "+RETSQLNAME("SE4")+" AS SE4  " + ENTER
		CSQL  += "WHERE F2_DOC = D2_DOC AND " + ENTER
		CSQL  += "      F2_CLIENTE = F2_CLIENTE AND " + ENTER
		CSQL  += "      F2_SERIE = D2_SERIE AND " + ENTER
		CSQL  += "      SF2.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SD2.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SF4.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SA4.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      SE4.D_E_L_E_T_ = '' AND " + ENTER
		CSQL  += "      D2_TES = F4_CODIGO AND " + ENTER
		CSQL  += "      F2_TRANSP = A4_COD AND " + ENTER
		CSQL  += "      F2_COND = E4_CODIGO AND " + ENTER
		CSQL  += "      F2_VEND1 BETWEEN '"+_cTrab->A1_VEND+"' AND '"+_cTrab->A1_VEND+"' AND " + ENTER
		CSQL  += "      F2_CLIENTE BETWEEN '"+_cTrab->A1_COD+"' AND '"+_cTrab->A1_COD+"' AND " + ENTER
		CSQL  += "      DATEDIFF(day, F2_EMISSAO, GETDATE()) <= 5 " + ENTER
		CSQL  += "GROUP BY F2_DOC, F2_SERIE, F2_CLIENTE, F2_CLIENTE " + ENTER
		TCSQLExec(CSQL)

		If chkfile("_C")
			dbSelectArea("_C")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_C" NEW	

		If ! _C->(eof())
			//LINHA C
			//oSecLiC:SetHeaderSection(.T.)
			oSecLiC:Init()

			oSecLiC:Cell("LINHAC"):SetValue(" ")
			oSecLiC:PrintLine()
		EndIf

		wTotal_C := 0
		wTotal_C_Q := 0

		Do While ! _C->(eof())
			//DADOS LINHA C
			//oSecDdC:SetHeaderSection(.T.)
			oSecDdC:Init()

			oSecDdC:Cell("NF"):SetValue(_C->F2_DOC)
			oSecDdC:Cell("SERIE"):SetValue(_C->F2_SERIE)
			oSecDdC:Cell("EMISSAO"):SetValue(DTOC(STOD(_C->EMISSAO)))
			oSecDdC:Cell("PEDIDO"):SetValue(_C->PEDIDO)
			oSecDdC:Cell("QTD"):SetValue(_C->QUANT)
			oSecDdC:Cell("VALORNF"):SetValue(_C->TOTAL)
			oSecDdC:Cell("CONDPAG"):SetValue(_C->COND_PAG)
			oSecDdC:Cell("TRANSP"):SetValue(_C->TRANSPORTADORA)
			oSecDdC:Cell("NATFOPER"):SetValue(_C->NAT_FIS_OPER)
			oSecDdC:PrintLine()

			wTotal_C   += _C->TOTAL
			wTotal_C_Q += _C->QUANT
			_C->(DBSKIP())
		EndDo

		If wTotal_C <> 0
			oSecTlC:Init()

			oSecTlC:Cell("NF"):SetValue("TOTAL")
			oSecTlC:Cell("QTD"):SetValue(wTotal_C_Q)
			oSecTlC:Cell("VALORNF"):SetValue(wTotal_C)
			oSecTlC:PrintLine()
		EndIf
		oSecTlC:Finish()
		oSecDdC:Finish()
		oSecLiC:Finish()	

		_cTrab->(DBSKIP())

		If _cTrab->A1_VEND <> wCodVend			
			oSecCli:Finish()
			oSecRep:Finish()
		ElseIf _cTrab->A1_COD <> wCodClie
			oSecCli:Finish()
		EndIf

		oReport:SkipLine(1)

	EndDo
	oSecCli:Finish()
	oSecRep:Finish()
Return
