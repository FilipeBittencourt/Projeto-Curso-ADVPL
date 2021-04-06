#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} M410LIOK
@description PE validacao de linha no pedido de venda
@author Desconhecido
@since 31/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
@version 12 revisado por Fernando Rocha
/*/
USER FUNCTION M410LIOK()
    
    local lRet      as logical

    lRet:=M410LIOK()

    return(lRet)

static function M410LIOK()

	//Local aArea := GetArea()
	Local lRetorno 	:= .T.
	LOCAL cTOTAL 	:= 0
	Local nUF		:= ""
	Local nEmp		:= ""
	Local nEmpZZ7	:= ""
	Local cEmpZZ7	:= ""

	Local cArq    	:= ""
	Local cInd    	:= 0
	Local cReg	    := 0

	Local cArqSF4	:= ""
	Local cIndSF4	:= 0
	Local cRegSF4	:= 0

	Local cArqSB1	:= ""
	Local cIndSB1	:= 0
	Local cRegSB1	:= 0

	Local cArqSBZ	:= ""
	Local cIndSBZ	:= 0
	Local cRegSBZ	:= 0

	Local cArqSE4	:= ""
	Local cIndSE4	:= 0
	Local cRegSE4	:= 0

	Local lConta	:= .F.
	Local nI

	Local lUsaCarga	:=	GetNewPar("MV_YUSACAR",.F.)  //Define se utiliza a rotina de carga  

	//Parametro para Filtrar tipo de pedido que nao gera reserva - projeto reserva Estoque/OP
	Local _cTpNRes := GetNewPar("FA_TPNRES","A #RI#F #")    


	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
		Return(.T.)
	EndIf

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SF4")
	cArqSF4 := Alias()
	cIndSF4 := IndexOrd()
	cRegSF4 := Recno()

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()

	DbSelectArea("SBZ")
	cArqSBZ := Alias()
	cIndSBZ := IndexOrd()
	cRegSBZ := Recno()

	DbSelectArea("SE4")
	cArqSE4 := Alias()
	cIndSE4 := IndexOrd()
	cRegSE4 := Recno()

	//Se a linha estiver deletada, não realiza validação
	If GdDeleted(n)
		U_FRRT02EX(M->C5_NUM,Gdfieldget("C6_ITEM",n),Nil,"LDE")
		Return(.T.)
	EndIf

	//Armazena Valores da Linha
	nPrcVen		:= Gdfieldget("C6_PRCVEN",n)		//Preco Venda
	nPrcUni 	:= Gdfieldget("C6_PRUNIT",n) 		//Preco Unitario
	nDescInc	:= Gdfieldget("C6_VALDESC",n)		//Desconto Incondicional
	nProd		:= Gdfieldget("C6_PRODUTO",n)
	nLote		:= Gdfieldget("C6_LOTECTL",n)
	nTes		:= Gdfieldget("C6_TES",n)
	nCFOP		:= Gdfieldget("C6_CF",n)
	dEntrega	:= Gdfieldget("C6_ENTREG",n)
	nItem		:= Gdfieldget("C6_ITEM",n)
	cRegraDesc	:= Gdfieldget("C6_YREGRA",n)
	nI			:= 0
	nDsIncon	:= 0
	lDescInc	:= .F.

	//Procura o Produto
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+nProd,.T.)

	//Procura o Indicador de Produto
	DbSelectArea("SBZ")
	DbSetOrder(1)
	DbSeek(xFilial("SBZ")+nProd,.T.)

	//Procura a TES
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+nTes,.T.)

	//Procura o Cliente
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.T.)

	//Checa se o TES utilizado é o mesmo da 1ª Linha
	If !(Alltrim(M->C5_YSUBTP) == "N" .and. M->C5_CLIENTE == "004536") // Por Marcos em 16/01/18 para atender venda Fábrica vs Fábrica
		If nTes <> Gdfieldget("C6_TES",1)
			Msgbox("Sempre deve ser utilizado um unico TES para o Pedido de Venda. Favor verificar o TES "+nTes+", pois está diferente do TES "+Gdfieldget("C6_TES",1)+", já utilizado.","M410LIOK","STOP")
			Return(.F.)
		EndIf
	EndIf

	//Permite o uso do Pedido Original uma UNICA VEZ para a chave PEDIDO ORIGINAL + EMPRESA PEDIDO //RANISSES EM 10/09/2015  
	If cEmpAnt == "07" .And. !Empty(Alltrim(M->C5_YPEDORI))

		cSql := "SELECT COUNT(*) QUANT FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = "+xFilial("SC5")+" AND C5_YPEDORI = '"+M->C5_YPEDORI+"' AND C5_YEMPPED = '"+M->C5_YEMPPED+"' AND D_E_L_E_T_ = '' "
		If Select("_RAC") > 0
			_RAC->(DbCloseArea())
		EndIf
		TCQUERY cSql ALIAS "_RAC" NEW

		If _RAC->QUANT > 1
			nEmpPed := Iif(M->C5_YEMPPED=="01","Biancogres","Incesa")	
			Msgbox("O Pedido Origem "+M->C5_YPEDORI+" já foi utilizado na empresa "+nEmpPed+". Favor verificar antes de continuar.","M410LIOK","STOP")
			Return(.F.)
		EndIf

		_RAC->(DbCloseArea())

	EndIf

	If cEmpAnt <> "02"

		//Posiciona na Empresa, que esta definada na Linha do Produto corrente
		cEmpZZ7 := Posicione("ZZ7",1,xFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ,"ZZ7_EMP")

		//Regra ativada em 25/04/13 para evitar faturamentos da Incesa para Biancogres
		//If Alltrim(M->C5_TIPO) == "N" .And. SB1->B1_YLINHA <> "0000" .And. SB1->B1_YLINHA <> "000C" .And. Alltrim(SB1->B1_TIPO) == "PA"
		If Alltrim(M->C5_TIPO) == "N" .And. Alltrim(M->C5_YSUBTP) == "N" .And. SB1->B1_YLINHA <> "0000" .And. SB1->B1_YLINHA <> "000C" .And. Alltrim(SB1->B1_TIPO) == "PA"

			//Comentado por Fernando/Facile em 09/03/2017 - para abrir venda de produtos para a Biancogres produzir Rodape
			/*If Alltrim(cEmpAnt) == "05" .And. Alltrim(M->C5_CLIENTE) == "000481"
			Msgbox("Não é permitido realizar a operação de venda da empresa Incesa para a Biancogres.","M410LIOK","STOP")
			Return(.F.)
			EndIf*/

			If Alltrim(cEmpAnt) == "05" .And. !(Alltrim(M->C5_CLIENTE) $ "010064_000481") .And. Substr(cEmpZZ7,1,2) <> "05" .And. AllTrim(cEmpZZ7) <> '0199'
				Msgbox("Não é permitido realizar a operação de venda de produtos OUTSOURCING ENTRADA para outros Cliente, somente para LM.","M410LIOK","STOP")
				Return(.F.)
			EndIf
		EndIf

	EndIf

	//Verifica se existe MVA para este NCM/UF/GRP/IPI. TRIBUTACAO
	If !(Alltrim(M->C5_TIPO)) $ "D_B" .And. Alltrim(M->C5_TIPOCLI) == "S" .And. Alltrim(SB1->B1_GRUPO) == "PA" 
		If !U_fBuscaMVA(SB1->B1_POSIPI,SA1->A1_EST,SB1->B1_GRTRIB,dDataBase)[1] 
			Return(.F.)
		EndIf
	EndIf

	//Testa produtos liberados, sem informar o Lote
	If Gdfieldget("C6_QTDLIB",n) <> 0 .And. Empty(Alltrim(Gdfieldget("C6_LOTECTL",n))) .And. Alltrim(SF4->F4_ESTOQUE) == "S" .And. Substr(Alltrim(nProd),1,1) >= "A" .And. SB1->B1_RASTRO == "L"
		MsgAlert("Antes de realizar a liberação deste item, é obrigatório o preenchimento do campo Lote","Quantidade Liberada")
		Return(.F.)
	EndIf

	//Ticket 30997 - Valida se cliente for segmento engenharia obrigar preenchimento de Data Necessidade Real C6_YDTNERE
	
	If Alltrim(SA1->A1_YTPSEG) == "E" .And. Empty(DTOS(Gdfieldget("C6_YDTNERE",n))) 
		MsgAlert("Antes de realizar a liberação deste item, é obrigatório o preenchimento do campo Dt.Nec.Real.", "Data de Necessidade Real")
		Return(.F.)
	EndIf

	//Valida Desconto Incondicional com os campo C6_PRCVEN e C6_PRUNIT                 
	//Fernando em 01/10 - adicionado o tipo B - estava dando problema nos pedidos da Fabiana Corona
	If !(M->C5_TIPO) $ "C_I_P_D_B_" .And. ( ALLTRIM(SB1->B1_TIPO) $ 'PA#PR' ) //Compl. Preço, Compl. ICMS, Compl. IPI e Devolução

		If ( M->C5_CLIENTE == "010064" .And. M->C5_CONDPAG == "142" )

			__DataLib := GetNewPar("FA_DALTPPD",STOD("20151231"))

			if !(Date() > __DataLib)  //provisorio liberar alteracao de produtos - solicitacao do Claudeir em 25/11
				Return(.T.)
			Endif

		EndIf    

		If nDescInc > 0 .And. nPrcUni == nPrcVen
			MsgAlert("O Desconto Incondicional está inconsistente. Favor verificar os campos Preço Venda e Unitário e contactar o setor de TI!","Desconto Incondicional")
			Return(.F.)
		EndIf

		If nDescInc == 0 .And. nPrcUni <> nPrcVen
			MsgAlert("O Desconto Incondicional está inconsistente. Favor verificar os campos Preço Venda e Unitário e contactar o setor de TI!","Desconto Incondicional")
			Return(.F.)
		EndIf
	EndIf

	//Valida se o Formato esta cadastrado na tabela Margem por Formato - ZZT
	If Substr(Alltrim(nProd),1,1) >= "A" .And. Alltrim(M->C5_TIPO) == 'N'
		//Definicao de Empresa
		If M->C5_YLINHA == "1"
			nEmp := "0101"
		ElseIf M->C5_YLINHA == "2"
			nEmp := "0501"
		ElseIf M->C5_YLINHA == "3"
			nEmp := "0599"
		ElseIf M->C5_YLINHA == "4"
			nEmp := "1399"
		ElseIf M->C5_YLINHA == "5"
			nEmp := "0199"
		EndIf


		/*cSql := "SELECT COUNT(*) AS QUANT FROM "+RetSqlName("ZZT")+" WHERE ZZT_FORMAT = '"+Substr(nProd,1,2)+"' AND ZZT_DTINI <= '"+Dtos(dDataBase)+"' AND ZZT_DTFIM >= '"+Dtos(dDataBase)+"' AND ZZT_EMP = '"+nEmp+"' AND D_E_L_E_T_ = '' "
		//cSql := "SELECT COUNT(*) AS QUANT FROM "+RetSqlName("ZZT")+" WHERE ZZT_FORMAT = '"+Substr(nProd,1,2)+"' AND ZZT_DTINI <= '"+Dtos(dDataBase)+"' AND ZZT_DTFIM >= '"+Dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
		If CHKFILE("_ZZT")
		dbSelectArea("_ZZT")
		dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "_ZZT" NEW
		//If _ZZT->QUANT <> 1
		If _ZZT->QUANT == 0
		Msgbox("O Formato "+Substr(nProd,1,2)+" não está cadastrado na tabela de MARGEM POR FORMATO - ZZT. Favor contactar o Gerente Comerical!","M410LIOK","STOP")
		Return(.F.)
		EndIf*/

	EndIf

	//Valida o campo Tipo de Pedido na Empresa MUNDI 13
	If cEmpAnt == "13" .And. !(Alltrim(M->C5_TIPO)) $ "D_B" .And. !Alltrim(M->C5_YSUBTP) $ "G_A_B_IM_F" //Amostra, Bonificacao e Importado
		MsgAlert("Favor verificar o campo Tipo de Pedido, pois está incorreto, para operações na Empresa Mundi!","Tipo de Pedido")
		Return(.F.)
	EndIf

	//Grava o Campo C6_CLASFIS
	SBZ->(DbSetOrder(1))
	If SBZ->(DbSeek(XFilial("SBZ")+nProd))
		Gdfieldput("C6_CLASFIS",SBZ->BZ_ORIGEM+SF4->F4_SITTRIB,n)
	Else
		Gdfieldput("C6_CLASFIS",SB1->B1_ORIGEM+SF4->F4_SITTRIB,n)
	EndIf	

	//Empresa Mundi so pode vender para produtos com Origem = 1 (Estrangeira)
	If cEmpAnt == "13" .And. !(Alltrim(M->C5_TIPO)) $ "D_B" .And. Substr(Gdfieldget("C6_CLASFIS",n),1,1) <> "1" .And. Alltrim(SB1->B1_GRUPO) == "PA" // 22/07/14
		MsgAlert("Favor verificar o campo Origem do produto "+nProd+", pois está incorreto, para operações na Empresa Mundi!","Origem do Produto")
		Return(.F.)
	EndIf

	//Valida a data de emissao e data de entrega do pedido
	IF INCLUI .And. !GdDeleted(n)
		IF M->C5_EMISSAO < dDatabase
			Alert("A Data de Emissao do pedido não pode ser menor do que a data base do sistema!")
			Return(.F.)
		ENDIF

		IF dEntrega < dDatabase
			Alert("A Data de Entrega do item pedido não pode ser menor do que a Data de Emissao do pedido!")
			Return(.F.)
		ENDIF
	ENDIF

	IF dEntrega < M->C5_EMISSAO .And. !GdDeleted(n)
		Alert("A Data de Entrega do item pedido não pode ser menor do que a Data de Emissao do pedido!")
		Return(.F.)
	ENDIF

	// Tratamento implementado para envio de PS junto com pallet no mesmo pedido de remessa. Por Marcos Alberto Soprani - 26/03/14
	If cEmpAnt == "01" .and. M->C5_TIPO == "B" .and. M->C5_CLIENTE == "003721" .and. C5_YSUBTP == "RI"

		// Não verificar tratamento de linha/cor nem mesma classificação do produto para o mesmo pedido

	Else

		//Armazena a Empresa e Classe do Produto, do Primeiro Registro
		// Tratamento para Empresa14. Primeiros passos. Por Marcos Alberto Soprani em 18/09/13
		If !(Alltrim(M->C5_YSUBTP) == "N" .and. M->C5_CLIENTE == "004536") // Por Marcos em 16/01/18

			If cEmpAnt <> "02" .and. cEmpAnt <> "14"

				If Empty(Alltrim(nEmpZZ7))
					cAliasTmp := GetNextAlias()
					BeginSql Alias cAliasTmp
						SELECT B1_COD, B1_YLINHA, B1_YLINSEQ, B1_YCLASSE FROM %Table:SB1% WHERE B1_COD = %EXP:Gdfieldget("C6_PRODUTO",1)% AND %NotDel%
					EndSql
					nEmpZZ7 	:= Posicione("ZZ7",1,xFilial("ZZ7")+(cAliasTmp)->B1_YLINHA+(cAliasTmp)->B1_YLINSEQ,"ZZ7_EMP")
					nClasOld	:= (cAliasTmp)->B1_YCLASSE
					(cAliasTmp)->(dbCloseArea())
				EndIf

				//O sistema deve aceitar pedidos de produtos da mesma Emprsa
				If nEmpZZ7 <> cEmpZZ7
					MsgAlert("Favor verificar o campo Empresa, no cadastro de Linha/Cor - ZZ7, pois não é possível utilizar produtos de Empresas diferentes.","Atenção (M410LIOK)")
					Return(.F.)
				EndIf

				//O sistema nao permite produtos de Classes diferentes em um mesmo pedido.
				If nClasOld == "1" .And. SB1->B1_YCLASSE <> "1"
					MsgAlert("Não é permitido incluir Produtos de Classes diferentes.","Atenção")
					Return(.F.)
				ElseIf nClasOld $ "2_4" .And. !SB1->B1_YCLASSE $ "2_4"
					MsgAlert("Não é permitido incluir Produtos de Classes diferentes.","Atenção")
					Return(.F.)
				ElseIf nClasOld $ "3_5" .And. !SB1->B1_YCLASSE $ "3_5"
					MsgAlert("Não é permitido incluir Produtos de Classes diferentes.","Atenção")
					Return(.F.)
				EndIf

			EndIf

		EndIf

	EndIf

	If cEmpAnt == "01" .And. SB1->B1_YFORMAT == "BA" .And. !Alltrim(M->C5_YSUBTP) $ "I/A/B/G"
		Alert("Favor acertar a o tipo/linha, para produtos 37X37, no cabeçalho do Pedido!")
		Return(.F.)
	EndIf

	//Valida o tipo do pedido para venda de produtos importados
	If (cEmpAnt == "01" .OR. cEmpAnt == "07") .AND. M->C5_YLINHA == '1' .AND. (SB1->B1_YFORMAT == "BA" .OR. SB1->B1_YFORMAT == "AQ") .And. Alltrim(M->C5_YSUBTP) == "N"
		Alert("Não é permitido a inclusão de pedidos deste formato na empresa Biancogres e na LM para a linha 1!")
		Return(.F.)
	EndIf

	//Valida o tipo do pedido para venda de produtos importados
	If cEmpAnt == "01" .AND. M->C5_YLINHA == '1' .AND. SUBSTR(SB1->B1_YFORMAT,1,1) == "I" .And. Alltrim(M->C5_YSUBTP) == "N"
		Alert("Favor acertar a o tipo do pedido para produtos importados no cabeçalho do Pedido!")
		Return(.F.)
	EndIf

	//VERIFICA SE O PRODUTO ESTA COM O CAMPO DE CODIGO DE BARRAS PREENCHIDO.
	If cEmpAnt <> "14" //não verificar codigo de barras para Vitcer
		//BIANCOGRES - 78967825 (ativo)
		//INCESA	 - 78985522 (antigo)
		//INCESA	 - 78994535 (ativo)    
		//MUNDI  	 - 78997765 (ativo)
		//If !Substr(Alltrim(SB1->B1_CODBAR),1,8) $  "78985522_78967825_78994535_78997765" .And. Alltrim(SB1->B1_GRUPO)=="PA"
		If !Substr(Alltrim(SB1->B1_CODBAR),1,8) $ GETMV("MV_YCODBAR") .And. Alltrim(SB1->B1_GRUPO)=="PA" .And. Substr(SB1->B1_CODGTIN,1,14) <> "00000000000000"
			Msgbox("Favor preencher o Código de Barras do Produto ou o Cód. GTIN com '00000000000000' para 'SEM GTIN'. Cód. Barras: " + Alltrim(SB1->B1_CODBAR) + "/Cód. GTIN: " + Alltrim(SB1->B1_CODGTIN),"M410LIOK","STOP")
			Return(.F.)
		END IF
	EndIf

	// MADALENO NAO PERMITIR LANCAR PEDIDO QUANDO O PRODUTO ESTIVER BLOQUEADO.
	DbSelectArea("SBZ")
	DbSetOrder(1)
	DbSeek(xFilial("SBZ")+SB1->B1_COD)

	IF SBZ->BZ_YBLSCPC = "1"
		Msgbox("Produto Bloqueado no cadastro de produto. Campo BZ_YBLSCPC.","M410LIOK","STOP")
		Return(.F.)
	ENDIF

	//Somente para Biancogres e Incesa, E TAMBEM LM A PARTIR DE 21/03/12
	If cEmpAnt $ ("01_05_07") .And. SB1->B1_YCLASSE <> "5" .And. Alltrim(M->C5_YSUBTP) <> "A" .And. Alltrim(M->C5_YSUBTP) <> "B" .And. M->C5_YLINHA <> '6'//RETIRADO VALIDAÇÃO DOS PEDIDOS DE AMOSTRA OS 3227-15

		//Define qual empresa será verificado o Custo Padrão. O custo deverá ser definido de acordo com o estoque do Produto.
		nEmp := cEmpAnt
		If cEmpAnt == "07"
			nEmp := Gdfieldget("C6_YEMPPED",n)
			If Empty(Alltrim(nEmp))
				nEmp := Substr(SB1->B1_YEMPEST,1,2)
			EndIf
			If nEmp == "13" //Ticket 13955
				nEmp := "01"
			EndIf
			
			If (cEmpAnt == '07' .And. cFilAnt == '05' .And. M->C5_YLINHA == '6')
				nEmp := "01"
			Endif
			 
		EndIf
		
		If Upper(AllTrim(getenvserver())) == "PRODUCAO" .OR. Upper(AllTrim(getenvserver())) == "REMOTO" .OR. Upper(AllTrim(getenvserver())) == "SCHEDULE"

			//MADALENO NAO PERMITE LANCAR O PRODUTO COM O CUSTO ZERO 2010 06 17
			If !Alltrim(SB1->B1_YFORMAT) $ "AC" .AND. Alltrim(SB1->B1_TIPO) $ 'PA' .AND. Substr(SB1->B1_COD,4,4) <> '0000' .AND. Alltrim(SB1->B1_YTPPROD) <> 'RP' 
				
				
				CSQL := "SELECT dbo.FN_CP_BI30('"+nEmp+"','"+Alltrim(SB1->B1_COD)+"','"+DTOS(M->C5_EMISSAO)+"','"+DTOS(M->C5_EMISSAO)+"') AS CP "   //FUNCAO PARA CUSTO PADRAO - TIPO 3
				If Select("QRY") > 0
					QRY->(DbCloseArea())
				EndIf
				TCQUERY CSQL ALIAS "QRY" NEW
	
				If (QRY->CP == 0)
					Msgbox("O Produto "+Alltrim(SB1->B1_COD)+" esta com o Custo Padrão zerado. Favor entrar em contato com o setor de Custo","M410LIOK","ALERT")
					QRY->(DbCloseArea())
					Return(.F.)
				EndIf
	
				QRY->(DbCloseArea())
	
			EndIf
	
		EndIf
		
		

	EndIf

	If Alltrim(M->C5_YRECR) == "S"
		Alert("Não é permitido inclusão de pedidos para Clientes Distribuidores. Favor verificar!")
		lRetorno := .F.
		Return(lRetorno)
	EndIf

	//Permite digitacao de desconto de ate 30% do valor do item
	nQtd		:= Gdfieldget("C6_QTDVEN",n)
	nLote		:= Gdfieldget("C6_LOTECTL",n)

	cTOTAL := nQtd * nPrcUni
	cTOTAL := ((cTOTAL /100)*30) 

	If cTOTAL < nDescInc  .And. Alltrim(SB1->B1_GRUPO) <> "216A"
		Alert("Valor do Desconto informado e maior que o permitido - 30%. Favor verificar.")
		lRetorno := .F.
		Return(lRetorno)
	EndIf

	IF cEmpAnt == '05'
		If Alltrim(nCFOP) $ "6403/5107" .or. Len(Alltrim(nCFOP)) <> 4
			Alert("O CFOP informado esta errado. Favor verificar procedimento com Setor Fiscal.")
			lRetorno := .F.
			Return(lRetorno)
		EndIf
	ENDIF

	//Verifica qual UF do Cliente / Fornecedor para validar o CFOP (Ranisses em 27/08/09)
	If Alltrim(M->C5_TIPO) $ "B_D"
		nUF	:= SA2->A2_EST
	Else
		nUF	:= SA1->A1_EST
	EndIf

	SM0->(DbSeek(CEMPANT+CFILANT))
	_cESTFIL := SM0->M0_ESTCOB

	//Verifica se o CFOP esta de acordo com UF do Cliente/Fornecedor (Ranisses em 27/08/09)
	If nUF == _cESTFIL .And. Subst(Alltrim(nCFOP),1,1) <> "5"
		Alert("O CFOP "+Alltrim(nCFOP)+" informado não é valido para esta UF "+nUF+". Favor verificar procedimento com Setor Fiscal ou Informatica.")
		lRetorno := .F.
		Return(lRetorno)
	ElseIf nUF == "EX" .And. Subst(Alltrim(nCFOP),1,1) <> "7"
		Alert("O CFOP "+Alltrim(nCFOP)+" informado não é valido para esta UF "+nUF+". Favor verificar procedimento com Setor Fiscal ou Informatica.")
		lRetorno := .F.
		Return(lRetorno)
	ElseIf !nUF $ _cESTFIL+"_EX" .And. Subst(Alltrim(nCFOP),1,1) <> "6"
		Alert("O CFOP "+Alltrim(nCFOP)+" informado não é valido para esta UF "+nUF+". Favor verificar procedimento com Setor Fiscal ou Informatica.")
		lRetorno := .F.
		Return(lRetorno)
	EndIf

	IF !EMPTY(M->C5_YCC)
		DbSelectArea("CTT")
		DbSetOrder(1)
		DbSeek(xFilial("CTT")+M->C5_YCC)
		IF CTT->CTT_BLOQ == '1'
			Alert("Este Centro de Custo está bloqueado. Favor entrar em contato com o Setor Contabil.")
			lRetorno := .F.
			Return(lRetorno)
		ENDIF
	ENDIF

	If cEmpAnt <> "02" //Nao executa esta regra para Ceramica Incesa RACCLVL
		IF !EMPTY(M->C5_YCLVL)
			DbSelectArea("CTH")
			DbSetOrder(1)
			DbSeek(xFilial("CTH")+M->C5_YCLVL)
			IF CTH->CTH_BLOQ == '1'
				Alert("Esta Classe de Valor está bloqueada. Favor entrar em contato com o Setor Contabil.")
				lRetorno := .F.
				Return(lRetorno)
			ENDIF
		ENDIF
	EndIf

	//Verifica se algum item possui Desconto Incondicional
	For nI := 1 To Len(aCols)
		If !lDescInc
			nDsIncon := Gdfieldget("C6_VALDESC",nI)
			If nDsIncon > 0
				lDescInc := .T.
			EndIf
		EndIf
	Next

	//Executa validacao do Item Contabil de Marketing
	lConta 	:= .F.

	//Valida Conta de Marketing conforme regra contabil que existe no CT5, LP '610' e Sequencia '011'
	IF ((nTes $ "604/6G0" .AND. cEmpAnt == '05' .AND. ALLTRIM(SB1->B1_GRTRIB) == '216') .OR. (nTes $ "660" .AND. cEmpAnt == '01') .OR. nDsIncon > 0) .AND. !lConta
		lConta := .T.
	ENDIF

	//Valida a Digitacao do Item Contabil
	IF SUBSTR(ALLTRIM(M->C5_YITEMCT),1,1) == 'I' .AND. EMPTY(M->C5_YSI) .AND. !(AllTrim(M->C5_YSUBTP) $ "A#M")  //fernando em 04/11 - nao fazer para amostra - solicitacao da Fabiana M.
		MsgBox("Favor informar o cliente para este Item Contábil","Atencao","ALERT")
		lRetorno := .F.
		Return(lRetorno)
	ENDIF

	//RUBENS JUNIOR - LIBERAR ITEM CONTABIL VAZIO PARA AMOSTRA DE PEDIDOS ENTRE EMPRESAS DO GRUPO (Biancogres, LM, Mundi e Incesa)
	If (Alltrim(M->C5_YSUBTP) == "A" .And. U_PedIntraGrupo(M->C5_CLIENTE) .And.  Empty(M->C5_YITEMCT))

		// Liberar classe de valor e item contabil vazios para a empresa JK - OS: 1883-14 
	ElseIf U_BIAF003(M->C5_YCLVL, M->C5_YITEMCT, M->C5_CLIENTE)

	Else
		lRetorno := U_fValItemCta(Alltrim(M->C5_YSUBTP),lConta,M->C5_YCLVL,M->C5_YITEMCT)	
	EndIf                                                                                   

	//Valida CST - Ranisses
	nClasFis	:= Gdfieldget("C6_CLASFIS",n)
	If Len(Alltrim(nClasFis)) <> 3
		Alert("A Classificação Fiscal está incorreta. Favor verificar o campo 'Origem' no cadastro de Produto, e o campo 'Sit.Trib.ICM' no cadastro de TES.")
		lRetorno := .F.
		Return(lRetorno)
	EndIf

	//VALIDAR SE O PEDIDO POSSUI CARGA EM ABERTO E NAO DEIXAR ALTERAR LINHA - FERNANDO
	If lUsaCarga .And. !(IsInCallStack("U_M410RPRC"))

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp

			SELECT COUNT(ZZW_PEDIDO) CONT
			FROM %Table:ZZW% ZZW
			JOIN %Table:SC9% SC9 ON ZZW_FILIAL = C9_FILIAL AND ZZW_PEDIDO = C9_PEDIDO AND ZZW_ITEM = C9_ITEM AND ZZW_SEQUEN = C9_SEQUEN AND SC9.%NotDel%
			WHERE
			ZZW.ZZW_PEDIDO 	 = %EXP:M->C5_NUM%
			AND ZZW.ZZW_ITEM = %EXP:nItem%
			AND ZZW.ZZW_STATUS <> 'X'
			AND SC9.C9_NFISCAL = ' '
			AND ZZW.%NotDel%

		EndSql

		IF (cAliasTmp)->CONT > 0
			MsgAlert("ESTE ITEM DO PEDIDO POSSUI CARGAS EM ABERTO!"+CRLF+"NÃO É POSSÍVEL A ALTERAÇÃO.","CONTROLE DE CARGAS")
			lRetorno := .F.
			Return(lRetorno)
		ENDIF

	ENDIF

	// Valida pedido de rodape
	If !U_BIAF103()

		Alert("Atenção, não é permitido adicionar produtos de pacotes distintos junto com os de rodapé")

		lRetorno := .F.

		Return(lRetorno)				

	EndIf

	If cArqSE4 <> ""
		dbSelectArea(cArqSE4)
		dbSetOrder(cIndSE4)
		dbGoTo(cRegSE4)
		RetIndex("SE4")
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	If cArqSBZ <> ""
		dbSelectArea(cArqSBZ)
		dbSetOrder(cIndSBZ)
		dbGoTo(cRegSBZ)
		RetIndex("SBZ")
	EndIf

	If cArqSF4 <> ""
		dbSelectArea(cArqSF4)
		dbSetOrder(cIndSF4)
		dbGoTo(cRegSF4)
		RetIndex("SF4")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

	//PROJETO CONSOLIDACAO - NOVAS REGRAS DE VALIDACAO DE PEDIDO
	_oRegra := TPedidoVendaRegras():New()
	_oRegra:LoadSC5Mem()
	_oRegra:lValLinha := .T.
	lRetorno := _oRegra:Validar()

	//------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 24/02/2014 - validar e gerar reservas de estoque ou OP para os itens do pedido
	//ATENCAO - MATER SEMPRE POR ULTIMO NO PONTO DE ENTRADA PORQUE ALTERA DADOS
	//------------------------------------------------------------------------------------------------
	If lRetorno .And. M->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14"))) .And. M->C5_YLINHA <> "4" .And. !(IsInCallStack("U_M410RPRC"))

		Private __cPed		:= M->C5_NUM
		Private __nItem		:= Gdfieldget("C6_ITEM",n)
		Private __nProd		:= Gdfieldget("C6_PRODUTO",n)
		Private __nLocal	:= Gdfieldget("C6_LOCAL",n)
		Private __nLoteSel	:= Gdfieldget("C6_LOTECTL",n) 
		Private __nQuant	:= Gdfieldget("C6_QTDVEN",n)
		Private __nEmpEst	:= Gdfieldget("C6_YEMPPED",n) 
		Private __cTpEst	:= Gdfieldget("C6_YTPEST", n)

		Private __cVendPed	:= M->C5_VEND1
		Private __aRetRes	:= {0,{}} 
		Private __nPLOTE	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL"})  
		Private __nPMOTFR	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YMOTFRA"})
		Private __nPBLQLOT	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YBLQLOT"})  
		Private __nPTPRES	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})  
		Private __cDTNECE	:= Gdfieldget("C6_YDTNECE",n)
		Private __cSEGMENTO := ""
		Private __cCATEGORIA:= ""
		Private __cNRESER	:= Gdfieldget("C6_YNRESER", n)
		
		Private _cItPedBas
		Private _cEmpOriPB

		Private __lProdPR	:= .F.

		// If (AllTrim(CEMPANT) == "14") .And. !U_CHKRODA(__nProd)
		// 	lRetorno := .T.
		// 	Return(lRetorno)
		// EndIf

		SA1->(DbSetOrder(1))
		__cChvCli := ""           
		If Empty(M->C5_YCLIORI)
			__cChvCli := M->C5_CLIENTE+M->C5_LOJACLI
		Else
			__cChvCli := M->C5_YCLIORI+M->C5_YLOJORI
		EndIf 

		If SA1->(DbSeek(xFilial("SA1")+__cChvCli))
			__cSEGMENTO 	:= SA1->A1_YTPSEG
			__cCATEGORIA	:= SA1->A1_YCAT
		EndIf


		//Reservas do pedido BASE para produtos rodape da Vitcer
		/*If (AllTrim(CEMPANT) == "14")

			_cItPedBas	:= Gdfieldget("C6_YPITCHA",n)
			_cEmpOriPB	:= Gdfieldget("C6_YEORICH",n)

			//Pedido de rodape VITCER - reservar produto base para posterior inclusao do pedido na origem
			If !Empty(_cItPedBas) .And. !Empty(_cEmpOriPB)


				ZA6->(DbSetOrder(2))
				If ZA6->(DbSeek(XFilial("ZA6")+__nProd))

					__nProd		:= ZA6->ZA6_BASE
					__nLocal	:= Posicione("SB1",1,XFILIAL("SB1")+ZA6->ZA6_BASE,"B1_LOCPAD")
					__nLoteSel	:= Gdfieldget("C6_YLOTBAS",n) 
					__nQuant	:= (__nQuant / ZA6->ZA6_CONV)

				EndIf

			Else

				aCols[N][__nPTPRES] := "V"

			EndIf

		EndIf*/

		SB1->(DbSetOrder(1))

		IF (M->C5_YSUBTP $ _cTpNRes)

			lRetorno := .T.                                                     

		ELSEIF Empty(__nProd)

			lRetorno := .T.	

		ELSEIF SB1->(DbSeek(XFilial("SB1")+__nProd)) .And. !(SB1->B1_TIPO $ "PA#PR")

			lRetorno := .T.

			//Tratamento produtos classe B/Cliente Livre revestimetos - nao fazer tratamento de lote/reserva - Fernando em 17/08/15 - OS 2831-15 
		ELSEIF SB1->(DbSeek(XFilial("SB1")+__nProd)) .And. AllTrim(SB1->B1_YCLASSE) == "2" .And. (M->C5_CLIENTE == "006338") ;
		.And. __cTpEst <> "E"

			lRetorno := .T.

		ELSEIF INCLUI .OR. (ALTERA .And. Len(U_FRTE02LO("", __cPed, __nItem, "", "")) > 0 .And. U_FRRT03V2(__cPed,__nItem,__nQuant, __nLoteSel))

			__lProdPR := (SB1->B1_TIPO == "PR")
			
			/*If !(AllTrim(M->C5_YSUBTP) $ "A#M#F") .And. __cSEGMENTO == "R" .And. AllTrim(__cCATEGORIA) == "SILVER" .And. !Empty(__cNRESER)
				If (ZZ6->ZZ6_VMRSIL != 0 .And. (CalcPalete(__nQuant)[1] <= ZZ6->ZZ6_VMRSIL))
					__cNRESER := __cNRESER
				Else
					__cNRESER := ""
				EndIf
			Else
				__cNRESER := ""
			EndIf*/
			//quando executar novamente voltar reserva?
			If (Type("__cResSilver") <> "U" .And. !__cResSilver)
				__cNRESER := ""
			EndIf
			
			
			//GERAR RESERVA PARA ITENS ESTOQUE IMEDIATO - SC0
			If Gdfieldget("C6_YTPEST",n) == "E"                                                                               
				//fernando/facile em 30/03/2016 - adicionado o parametro Subtp para reservas de amostra - OS 4467-15
				__aRetRes := U_FROPRT02(__cPed, __nItem, __nProd, __nLocal, __nQuant, __cVendPed, __nLoteSel, ALTERA,, M->C5_YSUBTP, __nEmpEst, __cNRESER)
				If __aRetRes[1] > 0 .Or. ( Len(__aRetRes[2]) <= 0 .And. !__lProdPR)

					U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não foi possível criar reserva para o item."+CRLF+"Verifique a quantidade e saldo disponível")
					aCols[N][__nPTPRES] := "N"
					lRetorno := .F.

				Else

					//reserva efetiva com sucesso - verificar o Lote selecionado - preecher e fazer bloqueio
					If len(__aRetRes[2]) == 1

						aCols[N][__nPLOTE] := __aRetRes[2][1]

					EndIf				

				EndIf
				//GERAR RESERVA PARA OP
			ElseIf Gdfieldget("C6_YTPEST",n) == "R"

				__aRet := U_FROPRT04(__cPed, __nItem, __nProd, __nQuant,__cSEGMENTO,__cDTNECE,,__nEmpEst)
				If !__aRet[1]

					U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não foi possível criar reserva de OP para o item."+CRLF+"ERRO: "+CRLF+__aRet[2])

					lRetorno := .F.

				EndIf

			ElseIf Gdfieldget("C6_YTPEST",n) == "V"

				//Engenharia - OP Futura - deixa passar
				lRetorno := .T.

			Else

				U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não foi criada reserva de Estoque ou Produção para o item."+CRLF+"Não é possível prosseguir com o pedido.")
				lRetorno := .F.

			EndIf

			IF INCLUI .And. lRetorno .And. Gdfieldget("C6_YTPEST",n) <> "V"

				_cUserName := CUSERNAME
				If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES)
					_cUserName := _FROPCHVTEMPRES
				EndIf

				If Len(U_FRTE02LT(__nProd, __nItem, _cUserName, __nEmpEst)) <= 0
					U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP",;
					"Problema na inclusão da RESERVA do item "+Gdfieldget('C6_ITEM',n)+"."+CRLF+;
					"Verifique a quantidade e saldo disponível; Tente novamente ou entre em contato com o depto. Comercial.",;
					,,"ATENÇÃO! Itens NÃO RESERVADOS.")

					lRetorno := .F.
				EndIf

			ENDIF

		ENDIF

	EndIf

Return(lRetorno)
