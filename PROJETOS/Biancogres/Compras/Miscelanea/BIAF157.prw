#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF157
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Esta rotina possibilita a inclusão, alteração ou exclusão de qualquer produto no Cadastro de Produtos 
@obs Ticket: 23756
@type function
/*/

User Function BIAF157(nOpc)
Private cCodigo

	If cEmpAnt == "02"
		
		Return()
		
	EndIf

	If nOpc == 3
	
		cCodigo := M->B1_COD
		cGrTrib := SPACE(3)

		//Retira caracteres especiais - Problema na NF 4.0
		M->B1_DESC	:= U_fDelTab(M->B1_DESC)	

		DO CASE
			CASE SUBSTRING(M->B1_COD,1,1) == '0' .AND. M->B1_TIPO == 'PA'
			cGrTrib := '000'
			CASE SUBSTRING(M->B1_COD,8,1) == '5' .AND. M->B1_TIPO == 'PA'
			cGrTrib := '002'
			CASE SUBSTRING(M->B1_YFORMAT,1,1) == 'I' .AND. M->B1_TIPO == 'PA'
			cGrTrib := '003'
			CASE M->B1_YFORMAT == 'AC'
			cGrTrib := '004'
			CASE SUBSTRING(M->B1_COD,1,1) <> '0' .AND. M->B1_TIPO == 'PA'
			cGrTrib := '001'
			CASE Substr(M->B1_GRUPO,1,3) == '103'
			cGrTrib := '103'
			CASE Substr(M->B1_GRUPO,1,3) == '102'
			cGrTrib := '102'
			CASE Substr(M->B1_GRUPO,1,3) == '104'
			cGrTrib := '104'
			CASE Alltrim(M->B1_COD) == '1010147'	//OS 3992-16 - Tania
			cGrTrib	:= '101'			
			CASE Alltrim(M->B1_COD) == '2018318' .Or. Alltrim(M->B1_COD) == '2018319' //OS 3417-16 - Tania
			cGrTrib := '201'
			CASE Substr(M->B1_GRUPO,1,3) == '214'
			cGrTrib := '214'
			CASE Substr(M->B1_GRUPO,1,3) == '212' // TICKET 3799 
			cGrTrib := '212'
			CASE Substr(M->B1_GRUPO,1,3) == '215'
			cGrTrib := '215'
			CASE Substr(M->B1_GRUPO,1,3) == '216'
			cGrTrib := '216'

			CASE Alltrim(M->B1_COD) $ '2170266/2170294/2171120/2171510/2173256/2173296/2173479/2174242/2175638' //OS 4277-16 - Tania
			cGrTrib := '217'

			CASE Substr(M->B1_GRUPO,1,3) == '218'
			cGrTrib := '218'

			//OS 1832-14 - PARA ATENDER PRODUTO VITCER EM 23/09/14
			CASE Substr(SB1->B1_GRUPO,1,3) == '220'
			cGrTrib := '220'

			CASE Substr(M->B1_GRUPO,1,3) == '401'	
			cGrTrib := '401'

			CASE Substr(SB1->B1_GRUPO,1,3) == '403'
			cGrTrib := '403'		

			//OS 3013-16	
			CASE Substr(M->B1_GRUPO,1,3) == '405'	
			cGrTrib := '405'

			CASE SUBSTRING(M->B1_COD,1,1) == '5' .And. Alltrim(M->B1_COD) <> '5010070'
			cGrTrib := '501'

			//ESPECIFICO PARA ATENDER SITUAÇÃO TANIA/NILMARA
			CASE Alltrim(M->B1_COD) == '5010070'
			cGrTrib := '012'

			CASE Alltrim(M->B1_GRUPO) == 'PR' //Ticket 4624
			cGrTrib := 'PR'

		ENDCASE
		
		//Vinilico
		If (AllTrim(M->B1_YPCGMR3) == 'J' .And. M->B1_TIPO == 'PA')
			cGrTrib 		:= '003' 
			M->B1_ORIGEM	:= '1'
			M->B1_CEST 		:= '1000700'
		EndIf
		
		M->B1_GRTRIB := cGrTrib
		
		M->B1_ATIVO  := 'S'
		IF SUBSTR(M->B1_COD,8,1) == '5' .OR. SUBSTR(M->B1_DESC,1,4) == 'CACO'
			M->B1_CLASFIS := 'D'
			M->B1_POSIPI  := '25309090'
		ENDIF

		IF SUBSTR(M->B1_COD,1,3) == '306'
			M->B1_POSIPI  := '00000000'
		ENDIF

		IF M->B1_TIPO == 'PA'
			M->B1_RASTRO  := 'L'
			DbSelectArea("ZZ6")
			DbSetOrder(1)
			DbSeek(xFilial("ZZ6")+M->B1_YFORMAT)
			IF ZZ6->ZZ6_EMP = 'B' .OR. ZZ6->ZZ6_EMP = 'A'
				//M->B1_PICMRET := 35.33 //ALTERADO EM 01/09/09
				//M->B1_PICMRET := 39.00 //ALTERADO EM 01/03/10
				M->B1_PICMRET := 45.00 //ALTERADO EM 01/03/13
			ENDIF
		ENDIF

		IF SB1->B1_TIPO == 'PA'
			DbSelectArea("ZZ9")
			DbSetOrder(1)
			IF !DbSeek(xFilial("ZZ9")+SPACE(10)+M->B1_COD)
				RecLock("ZZ9",.T.)
				ZZ9->ZZ9_FILIAL := xFilial("ZZ9")
				ZZ9->ZZ9_LOTE   := SPACE(10)
				ZZ9->ZZ9_PRODUT := cCodigo
				ZZ9->ZZ9_PESEMB := M->B1_YPESEMB
				ZZ9->ZZ9_DIVPA  := M->B1_YDIVPA
				ZZ9->ZZ9_PESO   := M->B1_PESO
				ZZ9->ZZ9_PECA   := M->B1_YPECA
				ZZ9->ZZ9_MSBLQL := M->B1_MSBLQL
				MsUnLock("ZZ9")
			ELSE
				RecLock("ZZ9",.F.)
				ZZ9->ZZ9_PESEMB := M->B1_YPESEMB
				ZZ9->ZZ9_DIVPA  := M->B1_YDIVPA
				ZZ9->ZZ9_PESO   := M->B1_PESO
				ZZ9->ZZ9_PECA   := M->B1_YPECA
				MsUnLock("ZZ9")
			ENDIF
		ENDIF

		DbSelectArea("ZZ6")
		DbSetOrder(1)
		IF DbSeek(xFilial("ZZ6")+M->B1_YFORMAT)
			M->B1_YCF := ZZ6->ZZ6_CF
		ENDIF

		incluiSBZ()

	ElseIf nOpc == 4

		cGrTrib := SPACE(3)
		cCodigo := SB1->B1_COD

		//Retira caracteres especiais - Problema na NF 4.0
		M->B1_DESC	:= U_fDelTab(M->B1_DESC)		

		DO CASE
			CASE SUBSTRING(SB1->B1_COD,1,1) == '0' .AND. SB1->B1_TIPO == 'PA'
			cGrTrib := '000'
			CASE SUBSTRING(SB1->B1_COD,8,1) == '5' .AND. SB1->B1_TIPO == 'PA'
			cGrTrib := '002'
			CASE SUBSTRING(SB1->B1_YFORMAT,1,1) == 'I' .AND. SB1->B1_TIPO == 'PA'
			cGrTrib := '003'
			CASE SB1->B1_YFORMAT == 'AC'
			cGrTrib := '004'
			CASE SUBSTRING(SB1->B1_COD,1,1) <> '0' .AND. SB1->B1_TIPO == 'PA'
			cGrTrib := '001'
			CASE Substr(SB1->B1_GRUPO,1,3) == '103'
			cGrTrib := '103'
			CASE Substr(SB1->B1_GRUPO,1,3) == '102'
			cGrTrib := '102'
			CASE Substr(SB1->B1_GRUPO,1,3) == '104'
			cGrTrib := '104'
			CASE Alltrim(M->B1_COD) == '1010147'	//OS 3992-16 - Tania
			cGrTrib	:= '101'			
			CASE Alltrim(SB1->B1_COD) == '2018318' .Or. Alltrim(SB1->B1_COD) == '2018319' //OS 3417-16 - Tania
			cGrTrib := '201'
			CASE Substr(M->B1_GRUPO,1,3) == '212' // TICKET 3799 
			cGrTrib := '212'
			CASE Substr(SB1->B1_GRUPO,1,3) == '214'
			cGrTrib := '214'
			CASE Substr(SB1->B1_GRUPO,1,3) == '216'
			cGrTrib := '216'

			CASE Alltrim(SB1->B1_COD) $ '2170266/2170294/2171120/2171510/2173256/2173296/2173479/2174242/2175638' //OS 4277-16 - Tania
			cGrTrib := '217'

			CASE Substr(SB1->B1_GRUPO,1,3) == '218'
			cGrTrib := '218'
			CASE Substr(SB1->B1_GRUPO,1,3) == '401'
			cGrTrib := '401'

			CASE Substr(SB1->B1_GRUPO,1,3) == '403'
			cGrTrib := '403'

			//OS 3013-16	
			CASE Substr(M->B1_GRUPO,1,3) == '405'	
			cGrTrib := '405'			

			//OS 1832-14 - PARA ATENDER PRODUTO VITCER EM 23/09/14
			CASE Substr(SB1->B1_GRUPO,1,3) == '220'
			cGrTrib := '220'

			CASE SUBSTRING(SB1->B1_COD,1,1) == '5' .And. Alltrim(SB1->B1_COD) <> '5010070'
			cGrTrib := '501'

			//ESPECIFICO PARA ATENDER SITUAÇÃO TANIA/NILMARA
			CASE Alltrim(SB1->B1_COD) == '5010070'
			cGrTrib := '012'

			CASE Alltrim(SB1->B1_GRUPO) == 'PR' //Ticket 4624
			cGrTrib := 'PR'

		ENDCASE
		
		//Vinilico
		If (AllTrim(M->B1_YPCGMR3) == 'J' .And. M->B1_TIPO == 'PA')
			cGrTrib 		:= '003' 
			M->B1_ORIGEM	:= '1' 
			M->B1_CEST 		:= '1000700'
		EndIf

		M->B1_GRTRIB := cGrTrib

		IF SB1->B1_TIPO == 'PA'
			DbSelectArea("ZZ6")
			DbSetOrder(1)
			DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)
			IF ZZ6->ZZ6_EMP = 'B' .OR. ZZ6->ZZ6_EMP = 'A'
				//M->B1_PICMRET := 35.33 //ALTERADO EM 01/09/09
				//M->B1_PICMRET := 39.00 //ALTERADO EM 01/03/10
				M->B1_PICMRET := 45.00 //ALTERADO EM 01/03/13
				//Apenas na exclusao
				//SB1->B1_PICMRET := 35
			ENDIF
		ENDIF

		IF SB1->B1_TIPO == 'PA'
			DbSelectArea("ZZ9")
			DbSetOrder(1)
			IF !DbSeek(xFilial("ZZ9")+SPACE(10)+SB1->B1_COD)
				RecLock("ZZ9",.T.)
				ZZ9->ZZ9_FILIAL := xFilial("ZZ9")
				ZZ9->ZZ9_LOTE   := SPACE(10)
				ZZ9->ZZ9_PRODUT := cCodigo
				ZZ9->ZZ9_PESEMB := SB1->B1_YPESEMB
				ZZ9->ZZ9_DIVPA  := SB1->B1_YDIVPA
				ZZ9->ZZ9_PESO   := SB1->B1_PESO
				ZZ9->ZZ9_PECA   := SB1->B1_YPECA
				ZZ9->ZZ9_MSBLQL := SB1->B1_MSBLQL
				MsUnLock("ZZ9")
			ELSE
				RecLock("ZZ9",.F.)
				ZZ9->ZZ9_PESEMB := SB1->B1_YPESEMB
				ZZ9->ZZ9_DIVPA  := SB1->B1_YDIVPA
				ZZ9->ZZ9_PESO   := SB1->B1_PESO
				ZZ9->ZZ9_PECA   := SB1->B1_YPECA
				MsUnLock("ZZ9")
			ENDIF
		ENDIF

		DbSelectArea("ZZ6")
		DbSetOrder(1)
		IF DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)
			M->B1_YCF := ZZ6->ZZ6_CF
		ENDIF

		DbSelectArea("SBZ")
		DbSetOrder(1)
		IF DbSeek(xFilial("SBZ")+SB1->B1_COD)
			RecLock("SBZ",.F.)
			DO CASE
				CASE cEmpAnt == '01'
				SBZ->BZ_YLOCAL  := M->B1_YLOCALI
				CASE cEmpAnt == '05'
				SBZ->BZ_YLOCAL  := M->B1_YLOCINC
				CASE cEmpAnt == '14'
				SBZ->BZ_YLOCAL  := M->B1_YLOCVIT
			ENDCASE
			//Retirado por Wanisay em 28/03/16 conforme OS 1036-16
			//SBZ->BZ_YATIVO  := M->B1_ATIVO

			SBZ->BZ_YBLSCPC	:= M->B1_YBLSCPC

			// Incluido por Ranisses Antonio Corona em 19/02/13, para gravar o Grupo Tributação também no cadadastro de Indicador
			// A Totvs passou a considerar este campo a partir de OUT/13 no fonte FISXFUN - função AliqIcms
			// Tratamento do Chamado TIHXAR/0223-14
			SBZ->BZ_GRTRIB := M->B1_GRTRIB
			
			//Vinilico
			If (AllTrim(M->B1_YPCGMR3) == 'J' .And. M->B1_TIPO == 'PA')
				SBZ->BZ_GRTRIB := '003' 
				SBZ->BZ_ORIGEM := '2'
				
				
				If (AllTrim(cEmpAnt) == '13')
					SBZ->BZ_ORIGEM := '1'
				EndIf
			EndIf

			SBZ->BZ_YDESC   := U_fDelTab(M->B1_DESC) 
			SBZ->BZ_LOCALIZ := M->B1_LOCALIZ

			MsUnLock()

		ELSE

			//Abrir pergunte para solicitar se o produto e MD e COMUM
			//If isInCallStack("MATA010") .or. funname() == "MATA010"
			//   PERGUNTE("MATA010",.F.)
			//Endif
			RecLock("SBZ",.T.)
			SBZ->BZ_FILIAL  := xFilial("SBZ")
			SBZ->BZ_COD     := M->B1_COD
			SBZ->BZ_YDESC   := U_fDelTab(M->B1_DESC)

			//Gabriel Mafioletti - 10/07/2018 Ticket - 4054
			If M->B1_TIPO $ "#PA#PP#"
				Do Case
					Case SUBSTR(cEmpAnt,1,2) == "01"
					SBZ->BZ_LOCPAD := "02"
					Case SUBSTR(cEmpAnt,1,2) == "05"
					SBZ->BZ_LOCPAD := "04"
					OtherWise
					SBZ->BZ_LOCPAD  := M->B1_LOCPAD
				EndCase
			Else
				SBZ->BZ_LOCPAD  := M->B1_LOCPAD
			EndIf

			SBZ->BZ_YPOLIT  := M->B1_YPOLIT
			DO CASE
				CASE cEmpAnt == '01'
				SBZ->BZ_YLOCAL  := M->B1_YLOCALI
				CASE cEmpAnt == '05'
				SBZ->BZ_YLOCAL  := M->B1_YLOCINC
				CASE cEmpAnt == '14'
				SBZ->BZ_YLOCAL  := M->B1_YLOCVIT
			ENDCASE     
			//Retirado por Wanisay em 28/03/16 conforme OS 1036-16
			//SBZ->BZ_YATIVO  := M->B1_ATIVO
			SBZ->BZ_YBLSCPC := M->B1_YBLSCPC
			SBZ->BZ_YSOLIC  := M->B1_YSOLIC
			SBZ->BZ_EMIN    := M->B1_EMIN
			SBZ->BZ_UCOM    := M->B1_UCOM
			SBZ->BZ_CUSTD   := M->B1_CUSTD
			SBZ->BZ_ORIGEM  := M->B1_ORIGEM
			//SBZ->BZ_YCOMUM  := MV_PAR01
			//SBZ->BZ_YMD     := MV_PAR02

			// Incluído por Marcos Alberto Soprani em 24/04/13 para dar segurança os usuários que efetuam o cadastro a ffin de não permitir o cadastramento errado por esquecimento da regra.
			// inicialmente usado para os produtos iniciados com: ADI_,POL_,IMP_,IND_,CMS_,EMB_,ENE_,ADT_,RET_,GAS_
			If Substr(M->B1_COD,4,1) $ "_"
				SBZ->BZ_FANTASM := 'S'
			EndIf

			// Incluido por Ranisses Antonio Corona em 19/02/13, para gravar o Grupo Tributação também no cadadastro de Indicador
			// A Totvs passou a considerar este campo a partir de OUT/13 no fonte FISXFUN - função AliqIcms
			// Tratamento do Chamado TIHXAR/0223-14
			SBZ->BZ_GRTRIB := M->B1_GRTRIB
			
			//Vinilico
			If (AllTrim(M->B1_YPCGMR3) == 'J' .And. M->B1_TIPO == 'PA')
				SBZ->BZ_GRTRIB := '003' 
				SBZ->BZ_ORIGEM := '2'
				
				If (AllTrim(cEmpAnt) == '13')
					SBZ->BZ_ORIGEM := '1'
				EndIf
			EndIf

			SBZ->BZ_YATIVO  := "S" 
			SBZ->BZ_LOCALIZ := M->B1_LOCALIZ

			// Incluído por Rodrigo Ribeiro em 23/01/2018
			SBZ->BZ_YMD  := "N"
			SBZ->BZ_YEMPENH  := "S"

			MsUnLock()

		ENDIF

		// Melhoria para atender a OS 3615-15, implementada por Marcos Alberto Soprani em 14/01/16
		If M->B1_TIPO == "PA" .and. M->B1_YCLASSE $ "2/3"

			DG001 := " UPDATE "+RetSqlName("ZZ9")+" SET ZZ9_PESO = " + Alltrim(Str(M->B1_PESO))
			DG001 += "  WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
			DG001 += "    AND ZZ9_PRODUT = '"+M->B1_COD+"'
			DG001 += "    AND ZZ9_LOTE <> '          '
			DG001 += "    AND D_E_L_E_T_ = ' '
			TCSQLExec(DG001)

		EndIf

	ENDIF

	//  Incluido por Marcos Alberto Soprani em 15/01/13 para tratamento de Rastro e Endereçamento para Produto Acabado sem CLASSIFICAÇÃO.
	// O que motivou esta implementação foi a necessidade de otimizar processamento de importação da produção. Uma vez que, não é necessário criar lote e endereçar, o processamento ficará mais rápido.
	If INCLUI

		If M->B1_TIPO == "PA" .and. Empty(M->B1_YCLASSE) .and. Substr(M->B1_COD,4,3) <> "000"
			M->B1_RASTRO  := "N"
			M->B1_LOCALIZ := "N"
		EndIf
		// Ajustado programa em 25/04/13 por Marcos Alberto Soprani, pois quando o usuário utiliza a opção "copiar" a partir do produto sem classificação, ele não estava observando a regra de Localização e Rastro.
		If M->B1_TIPO == "PA" .and. !Empty(M->B1_YCLASSE) .and. Substr(M->B1_COD,4,3) == "000"
			M->B1_RASTRO  := "L"
			M->B1_LOCALIZ := "S"
		EndIf

	ElseIf ALTERA

		If SB1->B1_TIPO == "PA" .and. Empty(SB1->B1_YCLASSE) .and. Substr(SB1->B1_COD,4,3) <> "000"
			M->B1_RASTRO  := "N"
			M->B1_LOCALIZ := "N"
		EndIf
		// Ajustado programa em 25/04/13 por Marcos Alberto Soprani, pois quando o usuário utiliza a opção "copiar" a partir do produto sem classificação, ele não estava observando a regra de Localização e Rastro.
		If SB1->B1_TIPO == "PA" .and. !Empty(SB1->B1_YCLASSE) .and. Substr(SB1->B1_COD,4,3) == "000"
			M->B1_RASTRO  := "L"
			M->B1_LOCALIZ := "S"
		EndIf

	EndIf

	If Inclui
		cTipo := "I"
		cCod	:= M->B1_COD
	ElseIf Altera
		cTipo := "A"
		cCod	:= SB1->B1_COD
	ElseIf IsInCallStack("A010DELETA")
		cTipo := "E"
		cCod	:= SB1->B1_COD
	EndIf

	If Inclui
		IF SUBSTR(M->B1_COD,1,1) == 'I' .AND. M->B1_ORIGEM <> '1'
			MSGBOX("Este produto de importação deverá ter o campo ORIGEM preenchido corretamente. Favor entrar em contato com o setor contábil!","STOP")
		ENDIF
	Endif

	If Altera
		IF SUBSTR(SB1->B1_COD,1,1) == 'I' .AND. M->B1_ORIGEM <> '1'
			MSGBOX("Este produto de importação deverá ter o campo ORIGEM preenchido corretamente. Favor entrar em contato com o setor contábil!","STOP")
		ENDIF
	Endif

	If Inclui .or. Altera .or. IsInCallStack("A010DELETA")
		//Replica Cadastro de Indicador
		If cEmpAnt $ "01_05_06_07_12_13_14"
			If cEmpAnt == "01"
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "05"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "06"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "07"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "12"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "13"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "14"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "16"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "17"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			EndIf

		EndIf

	EndIf


Return

//****************************************************************************************************
//**                                                                                                **
//****************************************************************************************************
static function incluiSBZ(pcAplicDireta,pcComum)

	//Inserir FUNNAME e abrir e cadastrar SBZ para as duas empresas.
	//Se não for pelo portal, abrir pergunte para solicitar se o produto e MD e COMUM
	If isInCallStack("MATA010") .or. funname() == "MATA010"
		PERGUNTE("MATA010",.T.)
	Endif

	DbSelectArea("SBZ")
	DbSetOrder(1)
	IF !DbSeek(xFilial("SBZ")+M->B1_COD)

		RecLock("SBZ",.T.)
		SBZ->BZ_FILIAL  := xFilial("SBZ")
		SBZ->BZ_COD     := M->B1_COD
		SBZ->BZ_YDESC   := U_fDelTab(M->B1_DESC)

		//Gabriel Mafioletti - 10/07/2018 Ticket - 4054
		If M->B1_TIPO $ "#PA#PP#"
			Do Case
				Case SUBSTR(cEmpAnt,1,2) == "01"
				SBZ->BZ_LOCPAD := "02"
				Case SUBSTR(cEmpAnt,1,2) == "05"
				SBZ->BZ_LOCPAD := "04"
				OtherWise
				SBZ->BZ_LOCPAD  := M->B1_LOCPAD
			EndCase
		Else
			SBZ->BZ_LOCPAD  := M->B1_LOCPAD
		EndIf

		SBZ->BZ_YPOLIT  := M->B1_YPOLIT

		DO CASE
			CASE cEmpAnt == '01'
			SBZ->BZ_YLOCAL  := M->B1_YLOCALI
			CASE cEmpAnt == '05'
			SBZ->BZ_YLOCAL  := M->B1_YLOCINC
			CASE cEmpAnt == '14'
			SBZ->BZ_YLOCAL  := M->B1_YLOCVIT
		ENDCASE

		//Retirado por Wanisay em 28/03/16 conforme OS 1036-16
		//SBZ->BZ_YATIVO  := M->B1_ATIVO
		SBZ->BZ_YBLSCPC := M->B1_YBLSCPC
		SBZ->BZ_YSOLIC  := M->B1_YSOLIC
		SBZ->BZ_EMIN    := M->B1_EMIN
		SBZ->BZ_UCOM    := M->B1_UCOM
		SBZ->BZ_CUSTD   := M->B1_CUSTD
		SBZ->BZ_ORIGEM  := M->B1_ORIGEM
		
		if substr(M->B1_GRUPO,1,3) == '102' .and. M->B1_YPOLIT == '2' 
			SBZ->BZ_YTMPFAB := 5
			SBZ->BZ_YTMPIND := 2
		else
			SBZ->BZ_YTMPFAB := 0
			SBZ->BZ_YTMPIND := 0
		endif
		
		//Alterado pelo Wanisay em 19/10/12
		If isInCallStack("MATA010") .or. funname() == "MATA010"

			IF MV_PAR01 == 1
				SBZ->BZ_YCOMUM  := 'S'
			ELSE
				SBZ->BZ_YCOMUM  := 'N'
			ENDIF
			IF MV_PAR02 == 1
				SBZ->BZ_YMD     := 'S'
			ELSE
				SBZ->BZ_YMD     := 'N'
			ENDIF

		ELSE

			If funname() == "WFPREPENV" //BIZAGI
				If !Empty(pcAplicDireta)
					SBZ->BZ_YMD     := pcAplicDireta
				Else
					SBZ->BZ_YMD     := 'S'
				EndIf
				If !Empty(pcComum)
					SBZ->BZ_YCOMUM  := pcComum
				Else
					SBZ->BZ_YCOMUM  := 'N'
				EndIf
			Else

				SBZ->BZ_YCOMUM  := M->BZ_YCOMUM
				SBZ->BZ_YMD     := M->BZ_YMD

			EndIf

		ENDIF

		// Incluído por Marcos Alberto Soprani em 24/04/13 para dar segurança os usuários que efetuam o cadastro a ffin de não permitir o cadastramento errado por esquecimento da regra.
		// inicialmente usado para os produtos iniciados com: ADI_,POL_,IMP_,IND_,CMS_,EMB_,ENE_,ADT_,RET_,GAS_
		If Substr(M->B1_COD,4,1) $ "_"
			SBZ->BZ_FANTASM := 'S'
		EndIf

		// Incluido por Ranisses Antonio Corona em 19/02/13, para gravar o Grupo Tributação também no cadadastro de Indicador
		// A Totvs passou a considerar este campo a partir de OUT/13 no fonte FISXFUN - função AliqIcms
		// Tratamento do Chamado TIHXAR/0223-14
		SBZ->BZ_GRTRIB := M->B1_GRTRIB
		
		//Vinilico
		If (AllTrim(M->B1_YPCGMR3) == 'J' .And. M->B1_TIPO == 'PA')
			SBZ->BZ_GRTRIB := '003' 
			SBZ->BZ_ORIGEM := '2'
				
			If (AllTrim(cEmpAnt) == '13')
				SBZ->BZ_ORIGEM := '1'
			EndIf
		EndIf

		SBZ->BZ_YATIVO  := "S"		
		SBZ->BZ_LOCALIZ := M->B1_LOCALIZ

		// Incluído por Rodrigo Ribeiro em 23/01/2018 
		//SBZ->BZ_YMD  := "N"
		SBZ->BZ_YEMPENH  := "S"

		MsUnLock()

	ENDIF

Return()