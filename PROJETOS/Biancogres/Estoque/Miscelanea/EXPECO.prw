#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} EXPECO
@author Rubens Junior (FACILE SISTEMAS)
@since 08/10/13
@version 1.0
@description Rotina para exportacao de dados do produto para o Ecosis. Chamado no cadastro de novos produtos
@type function
/*/

Static ENTER := CHR(13)+CHR(10)  

User Function EXPECO(gtOrigProc) 

	Local aArea := GetArea()
	Local _aBaseEco	:=	{}
	Local _nI

	PRIVATE cBaseEco     
	PRIVATE cQry
	PRIVATE cLinha
	PRIVATE cDescTamProd 
	PRIVATE cDescTamPallets
	PRIVATE cRef_produtos
	PRIVATE cLog := ""

	//Pergunta para filtro do browse
	If gtOrigProc == 1

		If !ValidPerg()
			Return
		EndIf

	Else

		MV_PAR01 := "4"

	EndIf

	If MV_PAR01 == "1"
		_aBaseEco := {"DADOSEOS"}

	ElseIf MV_PAR01 == "2"
		_aBaseEco := {"DADOS_05_EOS"}

	ElseIf MV_PAR01 == "3"
		_aBaseEco := {"DADOS_13_EOS"}

	ElseIf MV_PAR01 == "4"
		_aBaseEco := {"DADOSEOS","DADOS_05_EOS","DADOS_13_EOS","DADOS_14_EOS"}

	ElseIf MV_PAR01 == "5"
		_aBaseEco := {"DADOS_14_EOS"}

	EndIf     

	For _nI := 1 to Len(_aBaseEco)

		cBaseEco	:=	_aBaseEco[_nI]

		//VALIDACAO FEITA TANTO PARA FAMILIA QUANTO PARA ITENS DA FAMILIA
		If ((Len(Alltrim(SB1->B1_COD)) == 7) .Or. (Len(Alltrim(SB1->B1_COD)) == 8)) .And. (Substr(Alltrim(SB1->B1_COD),4,4) == SB1->B1_YLINHA)

			//FAMILIA JA CADASTRADA NO ECOSIS? 
			cQry := " SELECT * "          
			cQry += "   FROM " +cBaseEco+ "..cad_prod_familia "
			cQry += "  WHERE cod_familia = '"+Substr(Alltrim(SB1->B1_COD),1,7)+"' "
			TCQUERY cQry ALIAS "QRY" NEW   
			If ( QRY->(EOF()) )	
				EXPECO1("int_prod_familia")	//int_prod_familia	
			EndIf                               
			QRY->(DbCloseArea()) 

			//CONSULTAR CADASTRO DE LINHA ZZ7  - B1_YLINHA (CHAVE ESTRANGEIRA)
			dbSelectArea("ZZ7")
			dbSetOrder(1)
			dbSeek(xFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ)

			cQry := " SELECT * "          
			cQry += "   FROM " +cBaseEco+ "..cad_linha_produtos "
			cQry += "  WHERE dsc_linha_produtos = '"+Alltrim(ZZ7->ZZ7_DESC)+"' "
			TCQUERY cQry ALIAS "QRY" NEW   
			If ( QRY->(EOF()) )
				EXPECO1("int_linha_produtos")
			Else
				cLinha := cValToChar(QRY->id_linha_produtos) //JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             
			EndIf                               
			QRY->(DbCloseArea())

			//CONSULTAR CADASTRO DE CLASSE/REFERENCIA ZZ8  - B1_YCLASSE (CHAVE ESTRANGEIRA) 
			If (!Empty(SB1->B1_YCLASSE))	                                 

				dbSelectArea("ZZ8")
				dbSetOrder(1)
				dbSeek(xFilial("ZZ8") + SB1->B1_YCLASSE)

				cQry := " SELECT * "          
				cQry += "   FROM " +cBaseEco+ "..cad_ref_produtos "
				cQry += "  WHERE prd_referencia = '"+Alltrim(ZZ8->ZZ8_DESC)+"' "
				TCQUERY cQry ALIAS "QRY" NEW   
				If(QRY->(EOF())) 
					EXPECO1("int_ref_produtos")
				Else
					cRef_produtos := Alltrim(ZZ8->ZZ8_DESC)		//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             
				EndIf
				QRY->(DbCloseArea())                  

			EndIf	 

			//CONSULTAR CADASTRO DE FORMATO-ZZ6 = TAMANHO (CHAVE ESTRANGEIRA) 
			//CONSULTAR CADASTRO DE PALLETES  (CHAVE ESTRANGEIRA) 
			If (!Empty(SB1->B1_YFORMAT))        

				dbSelectArea("ZZ6")
				dbSetOrder(1)
				dbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)

				//FORMATO-ZZ6 = TAMANHO
				cQry := " SELECT *" 
				cQry += "   FROM " +cBaseEco+ "..cad_tamanho_produtos "
				cQry += "  WHERE dsc_tamanho_produtos = '"+Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)+"' "
				TCQUERY cQry ALIAS "QRY" NEW   
				If(QRY->(EOF()))
					EXPECO1("int_tamanho_produtos")
				Else
					cDescTamProd := Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)	//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             
				EndIf                               
				QRY->(DbCloseArea())  

				//PALLETS		
				cQry := " SELECT *" 
				cQry += "   FROM " +cBaseEco+ "..cad_tamanho_pallets "
				cQry += "  WHERE dsc_tamanho_produtos = '"+Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)+"' "
				TCQUERY cQry ALIAS "QRY" NEW   
				If(QRY->(EOF()))
					EXPECO1("int_tamanho_pallets")
				Else
					cDescTamPallets := Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)	//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             
				EndIf  
				QRY->(DbCloseArea())                

			EndIf

		EndIf

		//ITENS DA FAMILIA E PRODUTO CADASTRADOS NO ECOSIS?  
		If (Len(Alltrim(SB1->B1_COD)) == 8) .And. (Substr(Alltrim(SB1->B1_COD),4,4) == SB1->B1_YLINHA)	

			//	- int_itens_prod_familia: Itens da Família de Produtos    
			cQry := " SELECT * "          
			cQry += "   FROM " +cBaseEco+ "..cad_itens_prod_familia "
			cQry += "  WHERE cod_produto = '"+Alltrim(SB1->B1_COD)+"' "
			TCQUERY cQry ALIAS "QRY" NEW   
			If(QRY->(EOF())) 
				EXPECO1("int_itens_prod_familia")		
			EndIf                               
			QRY->(DbCloseArea()) 

			//    - int_cad_produtos: Cadastro de Produtos
			cQry := " SELECT * "          
			cQry += "   FROM " +cBaseEco+ "..cad_produtos "
			cQry += "  WHERE cod_produto = '"+Alltrim(SB1->B1_COD)+"' "
			TCQUERY cQry ALIAS "QRY" NEW   
			If(QRY->(EOF()))
				EXPECO1("int_produtos")		
			EndIf                               
			QRY->(DbCloseArea())

			//Retirado Por Gabriel Rossi Mafioletti pois as amostras não estão integrando e impedindo os produtos de integrarem
			//Realizei uma alteração para inserir itens_prod_familia e funcionou para amostras

			If (AllTrim(cBaseEco) <> "DADOS_13_EOS")

				//    - Em 15/02/18... Por Marcos Alberto Soprani
				//    - Cadastra Produto AMOSTRA
				cQry := " SELECT * "          
				cQry += "   FROM " +cBaseEco+ "..cad_produtos "
				cQry += "  WHERE cod_produto = '" + Substr(SB1->B1_COD,1,7) + "9" + "' "
				TCQUERY cQry ALIAS "QRY" NEW   
				If(QRY->(EOF()))
					EXPECO1("int_AMT_PRODUTO")		
				EndIf                               
				QRY->(DbCloseArea())

				// Em 24/05/17... Por Marcos Alberto Soprani...
				IF Type("_ExecPEmt010at") <> "U"
					EXPECO1("int_produtos")		
				EndIf		 

			EndIf

		EndIf          

	Next

	//SALVAR LOG DE INTEGRACAO
	If Empty(cLog)

		MemoWrite(GetSrvProfString ("STARTPATH","")+"\INTEGRACAO_ECOSIS.TXT","NAO HOUVE INSERCAO NA BASE DE DADOS DO ECOSIS PARA ESSE CADASTRO")

	Else

		MemoWrite(GetSrvProfString ("STARTPATH","")+"\INTEGRACAO_ECOSIS.TXT",cLog)

	EndIf

	RestArea(aArea)

Return     

/*
##############################################################################################################
# PROGRAMA...: EXPECO1         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/10/2013                      
# DESCRICAO..: FUNCAO PARA EXECUTAR O UPDATE NAS TABELAS TANQUE DO ECOSIS
# 	 				 
##############################################################################################################
*/
Static Function EXPECO1(cTabEcosis)   

	Local cInsert   := ""
	Local cSelect
	Local nId
	Local cMarca 	:= '1'
	Local cUm  		:= '1'
	Local nStatus 
	//Local cLinha

	Do Case

		Case cTabEcosis == "int_prod_familia"
		If TABTANQUE()
			cInsert := ""
			cInsert += "INSERT INTO " +cBaseEco+".."+cTabEcosis+ " (cod_familia,dsc_familia) VALUES " +ENTER
			cInsert += " ('"+SUBSTR(Alltrim(SB1->B1_COD),1,7)+"','"+Substr(Alltrim(ZZ7->ZZ7_DESC)+" "+Alltrim(ZZ6->ZZ6_DESC),1,55)+"')"			
		EndIf

		Case cTabEcosis == "int_linha_produtos" 	//CHAVE ESTRANGEIRA LINHA DE PRODUTOS

		If TABTANQUE()
			//BUSCAR ULTIMO REGISTRO INSERIDO POIS PRIMARY KEY EH SEQUENCIAL
			cSelect := ""
			cSelect += "SELECT MAX(id_linha_produtos) AS IDMAX FROM " +cBaseEco+ "..cad_linha_produtos"   

			TCQUERY cSelect ALIAS "QRY2" NEW   		

			nId := QRY2->IDMAX + 1
			cLinha := cValToChar(nId) //JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             

			QRY2->(DbCloseArea())

			cInsert := ""
			cInsert += "INSERT INTO " +cBaseEco+".."+cTabEcosis+ " (id_linha_produtos,dsc_linha_produtos,clp_tipo_produto) VALUES " +ENTER
			cInsert += " ("+cValToChar(nId)+",'"+Substr(Alltrim(ZZ7->ZZ7_DESC),1,40)+"',1)" 

		Else

			cSelect := ""
			cSelect += "SELECT MAX(id_linha_produtos) AS IDMAX FROM " +cBaseEco+ "..cad_linha_produtos"   

			TCQUERY cSelect ALIAS "QRY2" NEW   		

			nId := QRY2->IDMAX + 1
			cLinha := cValToChar(nId) //JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             

			QRY2->(DbCloseArea())

		EndIf     

		Case cTabEcosis == "int_ref_produtos"		//CHAVE ESTRANGEIRA CLASSE = REFERENCIA DE PRODUTOS
		If TABTANQUE()
			cInsert := ""
			cInsert += "INSERT INTO " +cBaseEco+".."+cTabEcosis+ " (prd_referencia,dsc_referencia,ref_produto) VALUES " +ENTER
			cInsert += " ('"+Alltrim(ZZ8->ZZ8_DESC)+"','"+Alltrim(ZZ8->ZZ8_DESC)+"','1')" 

			cRef_produtos := Alltrim(ZZ8->ZZ8_DESC)		//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             

		Else

			cRef_produtos := Alltrim(ZZ8->ZZ8_DESC)		//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             

		EndIf		

		Case cTabEcosis == "int_tamanho_produtos"
		If TABTANQUE()
			cInsert := ""
			cInsert += "INSERT INTO " +cBaseEco+".."+cTabEcosis+ " (dsc_tamanho_produtos,ctp_ativo) VALUES " +ENTER
			cInsert += " ('"+Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)+"',1)" 

			cDescTamProd := Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)	//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             

		Else

			cDescTamProd := Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)	//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             

		EndIf

		Case cTabEcosis == "int_tamanho_pallets"		
		If TABTANQUE()
			cInsert := ""
			cInsert += "INSERT INTO " +cBaseEco+".."+cTabEcosis+ " (dsc_tamanho_produtos,ctp_caixa_pallet,ctp_peso_pallet,ctp_peso_pallet_exp,"  +ENTER
			cInsert += " ctp_default_mi,ctp_default_me) VALUES " +ENTER
			cInsert += " ('"+Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)+"',"+cValtoChar(SB1->B1_YDIVPA)+",20,20,1,1)" 

			cDescTamPallets := Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)	//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             

		Else

			cDescTamPallets := Alltrim(SB1->B1_YFORMAT)+" - "+Alltrim(ZZ6->ZZ6_DESC)	//JA ARMAZENA VARIAVEL QUE SERA INSERIDA NO CADASTRO DO PRODUTO             

		EndIf					

		Case cTabEcosis == "int_itens_prod_familia"
		If TABTANQUE()
			cInsert := ""
			cInsert += "INSERT INTO " +cBaseEco+".."+cTabEcosis+ " (cod_familia,cod_produto) VALUES "+ENTER
			cInsert += " ('"+Substr(Alltrim(SB1->B1_COD),1,Len(Alltrim(SB1->B1_COD))-1)+"','"+Alltrim(SB1->B1_COD)+"')" 
		EndIf			             

		Case cTabEcosis == "int_produtos"
		If TABTANQUE()

			//MARCA	 
			If Alltrim(cBaseEco) == "DADOSEOS"
				cMarca := '1'
			EndIf    

			If Alltrim(cBaseEco) == "DADOS_13_EOS"
				cMarca := '2'
			EndIf  

			If Alltrim(cBaseEco) == "DADOS_05_EOS"
				If(ZZ7->ZZ7_EMP == '0101')	//BIANCOGRES
					cMarca := '3'
				EndIf                                   
				If(ZZ7->ZZ7_EMP == '0501')	//INCESA
					cMarca := '1'
				EndIf  
				If(ZZ7->ZZ7_EMP == '0599')	//INCESA
					cMarca := '4'
				EndIf  
			EndIf

			If Alltrim(cBaseEco) == "DADOS_14_EOS"
				cMarca := '1' //VINILICO
			EndIf  

			//UNIDADE DE MEDIDA
			If(Alltrim(SB1->B1_UM) =='M2')
				cUm := '1'
			EndIf	                     
			If(Alltrim(SB1->B1_UM) =='CX')
				cUm := '4'
			EndIf  

			//CLASSE - REFERENCIA	 
			DbSelectArea("ZZ6")
			DbSetOrder(1)
			DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)		     

			cInsert := ""
			cInsert += "INSERT INTO " + cBaseEco + ".." + cTabEcosis + " (cod_produto, id_marca, id_un_medidas, id_linha_produtos, prd_referencia, dsc_tamanho_produtos, " +ENTER
			cInsert += " cod_familia, dsc_produto, dsc_abreviado, prd_ativo, prd_prod_propria, prd_cia, prd_peso_bruto, prd_m2_caixa, prd_pecas_caixa, prd_integra) " +ENTER
			cInsert += " VALUES "+ENTER
			cInsert += " ('" + Alltrim(SB1->B1_COD) + "'," + cMarca + "," + cUm + "," + cLinha + ",'" + cRef_produtos + "','" + cDescTamProd + "', "
			cInsert += " '" + Alltrim(Substr(SB1->B1_COD,1,7)) + "','" + Substr(Alltrim(SB1->B1_DESC),1,55) + "','" + Substr(Alltrim(ZZ7->ZZ7_DESC),1,20) + "', 1, 1, 1,"
			cInsert += " " + cValtoChar(SB1->B1_PESO) + "," + cValtoChar(SB1->B1_CONV) + "," + cValtoChar(SB1->B1_YPECA) + ", 1)"  

			ZZ6->(DbCloseArea())

		EndIf

		Case cTabEcosis == "int_AMT_PRODUTO"

		cTabEcosis := "int_produtos"
		If TABTANQUE()

			//MARCA	 
			If Alltrim(cBaseEco) == "DADOSEOS"
				cMarca := '1'
			EndIf        

			If Alltrim(cBaseEco) == "DADOS_13_EOS"
				cMarca := '2'
			EndIf        

			If Alltrim(cBaseEco) == "DADOS_05_EOS"
				If(ZZ7->ZZ7_EMP == '0101')	//BIANCOGRES
					cMarca := '3'
				EndIf                                   
				If(ZZ7->ZZ7_EMP == '0501')	//INCESA
					cMarca := '1'
				EndIf  
				If(ZZ7->ZZ7_EMP == '0599')	//INCESA
					cMarca := '4'
				EndIf  
			EndIf

			If Alltrim(cBaseEco) == "DADOS_14_EOS"
				cMarca := '1'
			EndIf        

			//UNIDADE DE MEDIDA - PC
			cUm := '2'

			//CLASSE - REFERENCIA	 
			dbSelectArea("ZZ6")
			dbSetOrder(1)
			dbSeek(xFilial("ZZ6") + SB1->B1_YFORMAT)

			cfDescr := Substr(Alltrim(Posicione("SB1", 1, xFilial("SB1") + Substr(SB1->B1_COD,1,7), "B1_DESC")) + " - AMT", 1, 55)		     

			cInsert := "INSERT INTO " +cBaseEco+".."+cTabEcosis+ " (cod_produto, id_marca, id_un_medidas, id_linha_produtos, prd_referencia, dsc_tamanho_produtos, " + ENTER
			cInsert += " cod_familia, dsc_produto, dsc_abreviado, prd_ativo, prd_prod_propria, prd_cia, prd_peso_bruto, prd_m2_caixa, prd_pecas_caixa, prd_integra) " + ENTER
			cInsert += " VALUES " + ENTER
			cInsert += " ('" + Substr(SB1->B1_COD,1,7) + "9" + "'," + cMarca + "," + cUm + "," + cLinha + ",'" + cRef_produtos + "','" + cDescTamProd + "', "
			cInsert += " '" + Substr(SB1->B1_COD,1,7) + "','" + cfDescr + "','" + Substr(Alltrim(ZZ7->ZZ7_DESC),1,20) + "', 1, 1, 1, "
			cInsert += " " + cValtoChar(SB1->B1_PESO) + "," + cValtoChar(SB1->B1_CONV) + ", 1, 1)"  

			ZZ6->(DbCloseArea())

		EndIf

	End Case  

	If !Empty(cInsert)

		cLog += cInsert +ENTER+ENTER+ENTER
		TCSQLExec(cInsert)   

		//EXECUTAR STORED PROCEDURE     
		nStatus := TCSQLExec(cBaseEco+".."+"ep_integra_produto")
		cLog += "########## EXECUTADO STORED PROCEDURE "+cBaseEco+".."+"ep_integra_produto"+" ##########" +ENTER+ENTER

	EndIf	

Return         

/*
##############################################################################################################
# PROGRAMA...: TABTANQUE         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/10/2013                      
# DESCRICAO..: FUNCAO EXECUTADA PARA VALIDAR SE O REGISTRO JA ESTA NAS TABELAS TANQUE
# 			SE JA EXISTIR NA TABELA TANQUE, RETORNA FALSO 				 
##############################################################################################################
*/
Static Function TABTANQUE()

	Local lRet := .F.
	Local cQuery := cQry
	Local nPos

	nPos := AT("cad_", cQuery )
	//ABRE CONSULTA QUE ESTA EM MEMORIA (cQry) E SUBSTITUI PELA CONSULTA NA TABELA TANQUE 
	cQuery := Substr(cQuery,1,nPos-1)+"int_"+Substr(cQuery,nPos+4,Len(cQuery))   

	TCQUERY cQuery ALIAS "QRY_TANQUE" NEW   

	If(QRY_TANQUE->(EOF()))
		lRet := .T.
	EndIf

	QRY_TANQUE->(DbCloseArea()) 

Return lRet 

User Function UpProdEco(cCodProd, cSitBloq, cCodBar, nPesoFat)

	Local aBasesEco := {"DADOSEOS", "DADOS_05_EOS", "DADOS_13_EOS", "DADOS_14_EOS"}
	Local i :=0

	cUpECO := ""

	For i := 1 to Len(aBasesEco)

		cUpECO := " UPDATE ECO SET PRD_ATIVO = " + IIF(cSitBloq == "1","0","1")  + ",           " + ENTER
		cUpECO += "                PRD_CBARRA = '" + cCodBar +"'                    ,           " + ENTER
		cUpECO += "                prd_peso_bruto = '" + Alltrim(Str(nPesoFat)) +"'             " + ENTER
		cUpECO += "  FROM " + aBasesEco[i] + ".dbo.CAD_PRODUTOS ECO                             " + ENTER
		cUpECO += "  WHERE COD_PRODUTO = '" +cCodProd +"'                                       " + ENTER
		TCSQLExec(cUpECO)

		cUpECO := "UPDATE ECO SET COD_PRODUTO_ORIGEM = SUBSTRING(G1_COMP, 1, 7),  " + ENTER
		cUpECO += "               PRD_REBARBA = G1_QUANT " + ENTER
		cUpECO += "  FROM " + aBasesEco[i] + ".DBO.CAD_PRODUTOS ECO " + ENTER
		cUpECO += " INNER JOIN " + RetSQLName("SG1") + " SG1 " + ENTER
		cUpECO += "    ON (G1_COD = COD_PRODUTO COLLATE Latin1_General_BIN " + ENTER
		cUpECO += "   AND SUBSTRING(G1_COMP, 1, 2) IN('C1')" + ENTER
		cUpECO += "   AND (SUBSTRING(G1_COMP, 1, 7) <> COD_PRODUTO_ORIGEM COLLATE Latin1_General_BIN OR " + ENTER
		cUpECO += "        COD_PRODUTO_ORIGEM IS NULL)" + ENTER
		cUpECO += "   AND SG1.D_E_L_E_T_ = ' ')" + ENTER
		cUpECO += " WHERE SUBSTRING(COD_PRODUTO, 1, 2) IN('B9', 'BO', 'C6')" + ENTER
		TCSQLExec(cUpECO)

	Next

Return

Static Function ValidPerg()

	local cLoad	    := "EXPECO" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := "1"

	aAdd( aPergs ,{2,"Integracao do Cadastro Ecosis" 	   		,MV_PAR01 ,{"1=Biancogres","2=Incesa","3=Mundi","4=Bianco/Incesa","5=B.Vinílico"},50,"NAOVAZIO()",.T.})	

	If ParamBox(aPergs ,"Integracao do Cadastro Ecosis ",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet
