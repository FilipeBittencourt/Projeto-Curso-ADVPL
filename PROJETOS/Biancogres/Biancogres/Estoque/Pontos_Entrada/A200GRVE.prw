#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} A200GRVE
@author Marcos Alberto Soprani
@since 24/08/11
@version 1.0
@description Ponto de Entrada que permite validar a Inclusão / Alteração da
.            estrutura de Produto
@obs Em 11/02/09... primeira vez que foi usado este P.E.: por Bruno Madaleno
@type function
/*/

User Function A200GRVE()

	Local EXPN1 := PARAMIXB[1]
	Local xscData := dtos(dDatabase)

	//EXPN1	== 2 	// VISUALIZAR
	//EXPN1	== 3 	// INCLUSAO
	//EXPN1	== 4 	// ALTERACAO
	//EXPN1	== 5 	// EXCLUSAO

	If EXPN1 == 3 .or. EXPN1 == 4

		dbSelectArea("SB1")
		nRecSB1 := Recno()
		dbSeek(xFilial("SB1") + cProduto)

		If SB1->B1_TIPO == "PA"                  // Caso esteja posicionado sobre a estrutura do PA - Produto Acabado
			// Apresenta a soma de todos os PI'S do grupo 102
			cSql := " SELECT G1_COD, SUM(G1_QUANT) QUANTIDADE
			cSql += "   FROM " + RetSqlName("SG1") + " SG1 "
			cSql += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
			cSql += "    AND SG1.G1_COD = '"+cProduto+"'
			cSql += "    AND SUBSTRING(SG1.G1_COMP, 1, 3) = '102'
			cSql += "    AND '"+cRevisao+"' >= SG1.G1_REVINI
			cSql += "    AND '"+cRevisao+"' <= SG1.G1_REVFIM
			// Foi necessário retirar o filtro de data de validade, porque às vezes faz-se necessário analisar revisões anteriores
			//cSql += "    AND SG1.G1_INI <= '"+xscData+"'
			//cSql += "    AND SG1.G1_FIM >= '"+xscData+"'
			cSql += "    AND SG1.D_E_L_E_T_ = ''
			cSql += "  GROUP BY G1_COD
			TCQUERY cSql ALIAS "_SOMA" NEW
			dbSelectArea("_SOMA")
			dbGoTop()
			Aviso("A200GRVE(1)!!!", "Soma dos Componentes do Grupo 102: " + CHR(13) + CHR(13) + Alltrim(Str(_SOMA->QUANTIDADE)), {"Ok"} )
			_SOMA->(dbCloseArea())

		Else                                     // Caso esteja posicionado sobre a estrutura do PI - Produto Intermediario
			// Soma as quantidades dos componentes para veririficar se totaliza UMA UNIDADE
			cSql := " SELECT G1_COD, SUM(G1_QUANT) QUANTIDADE
			cSql += "   FROM " + RetSqlName("SG1") + " SG1 "
			cSql += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
			cSql += "    AND SG1.G1_COD = '"+cProduto+"'
			cSql += "    AND '"+cRevisao+"' >= SG1.G1_REVINI
			cSql += "    AND '"+cRevisao+"' <= SG1.G1_REVFIM
			// Foi necessário retirar o filtro de data de validade, porque às vezes faz-se necessário analisar revisões anteriores
			//cSql += "    AND SG1.G1_INI <= '"+xscData+"'
			//cSql += "    AND SG1.G1_FIM >= '"+xscData+"'
			cSql += "    AND SG1.D_E_L_E_T_ = ''
			cSql += "  GROUP BY G1_COD
			TCQUERY cSql ALIAS "_SOMA" NEW
			dbSelectArea("_SOMA")
			dbGoTop()
			If _SOMA->QUANTIDADE <> 1
				sfr_Mens := "O produto " + Alltrim(cProduto) + " tem a soma das quantidades dos componentes diferente de UMA UNIDADE: " + CHR(13) + CHR(13)
				sfr_Mens += Transform(_SOMA->QUANTIDADE,"@E 9,999,999.99999999")
				Aviso("A200GRVE(2)!!!", sfr_Mens, {"Ok"} )
			EndIf
			_SOMA->(dbCloseArea())

		EndIf

		dbSelectArea("SB1")
		dbGoTo(nRecSB1)

	EndIf

	If EXPN1 == 3


		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+ cProduto))
		Reclock("SB1",.F.)
		SB1->B1_REVATU	:=	cRevisao
		SB1->(MsUnlock())

	ElseIf EXPN1 == 4

		// Regras incluidas por Marcos Alberto em 25/08/11
		If !Empty(xc_NewRev)

		
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+ cProduto))
			Reclock("SB1",.F.)
			SB1->B1_REVATU	:=	cRevisao
			SB1->(MsUnlock())
			

			// Abre a Tela de Cadastro de Revisão, entretanto, não preenche nada: o usuário deverá clicar em incluir e efetuar o cadastro normalmente.
			aMata201  := {{'G5_PRODUTO'  ,cProduto                            ,NIL},;
			{              'G5_REVISAO'  ,xc_NewRev                           ,NIL},;
			{              'G5_DATAREV'  ,xc_NDtIni                           ,NIL} }
			MsExecAuto({|x| Mata201(x)}, aMata201, 3)

		EndIf

	EndIf

	// Worklow de manutenção de estruturas de produto
	If EXPN1 == 3 .Or. EXPN1 == 4 .Or. EXPN1 == 5
		U_BIAF006(EXPN1)
	EndIf

Return(.T.)
