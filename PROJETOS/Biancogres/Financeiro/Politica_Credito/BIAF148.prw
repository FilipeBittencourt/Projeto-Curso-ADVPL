#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF148
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para chamada da (Tela) Painel de Política de Crédito
@type class
/*/

User Function BIAF148(cCliente, cLoja)
Local aCores := {}
Local cFilter := ""
Local cTipoLC := ""
Local cGrpVen := ""
Private aRotina := {}
Private cCadastro := "Painel de Política de Crédito"
Private cAlias := "ZM0"

	Default cCliente := ""
	Default cLoja := ""

	aAdd(aCores, {"ZM0_STATUS == '1'", "BR_VERDE"})
	aAdd(aCores, {"ZM0_STATUS == '2'", "BR_AMARELO"})
	aAdd(aCores, {"ZM0_STATUS == '3'", "BR_VERMELHO"})
	aAdd(aCores, {"ZM0_STATUS == '4'", "BR_AZUL"})	

	aAdd(aRotina, {"Pesquisar" , "PesqBrw", 0, 1})
	aAdd(aRotina, {"Visualizar", "U_BIAF148A", 0, 2})
	
	If Empty(cCliente)

		aAdd(aRotina, {"Incluir", "U_BIAF148B", 0, 3})
		aAdd(aRotina, {"Atualizar", "U_BIAF148C", 0, 7})
		
	Else
		
		cTipoLC := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_YTIPOLC")
		
		cGrpVen := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_GRPVEN")
		
		If cTipoLC == "C"

			cFilter := " ZM0_CNPJ IN "
			cFilter += " (
			cFilter += " SELECT A1_CGC "
			cFilter += " FROM "
			cFilter += " ( "
			cFilter += " 	SELECT A1_CGC "
			cFilter += " 	FROM " + RetFullName("SA1", "01")
			cFilter += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
			cFilter += " 	AND A1_COD = " + ValToSQL(cCliente)
			cFilter += " 	AND A1_LOJA = " + ValToSQL(cLoja)
			cFilter += " 	AND A1_YTIPOLC = " + ValToSQL(cTipoLC)
			cFilter += " 	AND SUBSTRING(A1_CGC, 1, 8) NOT IN ('', '02077546', '04917232', '04548187', '10524837', '13231737', '14086214', '08930868') "
			cFilter += " 	AND D_E_L_E_T_ = '' "
			
			cFilter += "	UNION "
	
			cFilter += "	SELECT A1_CGC "
			cFilter += " 	FROM " + RetFullName("SA1", "05")
			cFilter += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
			cFilter += " 	AND A1_COD = " + ValToSQL(cCliente)
			cFilter += " 	AND A1_LOJA = " + ValToSQL(cLoja)
			cFilter += " 	AND A1_YTIPOLC = " + ValToSQL(cTipoLC)
			cFilter += "	AND SUBSTRING(A1_CGC, 1, 8) NOT IN ('', '02077546', '04917232', '04548187', '10524837', '13231737', '14086214', '08930868') "
			cFilter += "	AND D_E_L_E_T_ = '' "
	
			cFilter += "	UNION "
	
			cFilter += "	SELECT A1_CGC "
			cFilter += " 	FROM " + RetFullName("SA1", "07")
			cFilter += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
			cFilter += " 	AND A1_COD = " + ValToSQL(cCliente)
			cFilter += " 	AND A1_LOJA = " + ValToSQL(cLoja)
			cFilter += " 	AND A1_YTIPOLC = " + ValToSQL(cTipoLC)
			cFilter += "	AND SUBSTRING(A1_CGC, 1, 8) NOT IN ('', '02077546', '04917232', '04548187', '10524837', '13231737', '14086214', '08930868') "
			cFilter += "	AND D_E_L_E_T_ = '' "
	
			cFilter += ") AS _SA1 "
			cFilter += "GROUP BY A1_CGC "
			cFilter += " ) "
			
		Else
		
			cFilter := " SUBSTRING(ZM0_CNPJ, 1, 8) IN "
			cFilter += " (
			cFilter += " SELECT A1_CGC "
			cFilter += " FROM "
			cFilter += " ( "
			cFilter += " 	SELECT SUBSTRING(A1_CGC, 1, 8) AS A1_CGC "
			cFilter += " 	FROM " + RetFullName("SA1", "01")
			cFilter += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
			cFilter += " 	AND A1_GRPVEN = " + ValToSQL(cGrpVen)
			cFilter += " 	AND A1_YTIPOLC = " + ValToSQL(cTipoLC)
			cFilter += " 	AND SUBSTRING(A1_CGC, 1, 8) NOT IN ('', '02077546', '04917232', '04548187', '10524837', '13231737', '14086214', '08930868') "
			cFilter += " 	AND D_E_L_E_T_ = '' "
			cFilter += " 	GROUP BY SUBSTRING(A1_CGC, 1, 8) "
			
			cFilter += "	UNION "
	
			cFilter += "	SELECT SUBSTRING(A1_CGC, 1, 8) AS A1_CGC "
			cFilter += " 	FROM " + RetFullName("SA1", "05")
			cFilter += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
			cFilter += " 	AND A1_GRPVEN = " + ValToSQL(cGrpVen)
			cFilter += " 	AND A1_YTIPOLC = " + ValToSQL(cTipoLC)
			cFilter += "	AND SUBSTRING(A1_CGC, 1, 8) NOT IN ('', '02077546', '04917232', '04548187', '10524837', '13231737', '14086214', '08930868') "
			cFilter += "	AND D_E_L_E_T_ = '' "
			cFilter += " 	GROUP BY SUBSTRING(A1_CGC, 1, 8) "
	
			cFilter += "	UNION "
	
			cFilter += "	SELECT SUBSTRING(A1_CGC, 1, 8) AS A1_CGC "
			cFilter += " 	FROM " + RetFullName("SA1", "07")
			cFilter += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
			cFilter += " 	AND A1_GRPVEN = " + ValToSQL(cGrpVen)
			cFilter += " 	AND A1_YTIPOLC = " + ValToSQL(cTipoLC)
			cFilter += "	AND SUBSTRING(A1_CGC, 1, 8) NOT IN ('', '02077546', '04917232', '04548187', '10524837', '13231737', '14086214', '08930868') "
			cFilter += "	AND D_E_L_E_T_ = '' "
			cFilter += " 	GROUP BY SUBSTRING(A1_CGC, 1, 8) "
	
			cFilter += ") AS _SA1 "
			cFilter += "GROUP BY A1_CGC "
			cFilter += " ) "
			
		EndIf
		
		
	EndIf
	
	aAdd(aRotina, {"Legenda", "U_BIAF148D", 0, 7})
	                                               
	DbSelectArea(cAlias)
	DbSetOrder(1)

	If Empty(cCliente)
	
		mBrowse(,,,,cAlias,,,,,,aCores)
	
	Else	
		
		mBrowse(,,,,cAlias,,,,,,aCores,,,,,,,,cFilter)
		
	EndIf
	
Return()


User Function BIAF148A(cAlias, nRecno, nOpc)
Local oObj := Nil
	
	oObj := TWPainelPoliticaCredito():New()

	oObj:lF10 := Type("cCliente") <> "U"
	
	oObj:Activate()
	
	FreeObj(oObj)
													
Return()


User Function BIAF148B(cAlias, nRecno, nOpc)
Local aParam := {}

	aAdd(aParam,  {|| .T.})
	aAdd(aParam,  {|| fValidateInsert() })
	aAdd(aParam,  {|| .T.})
	aAdd(aParam,  {|| .T.})
					
	AxInclui(cAlias, nRecno, nOpc,,,,, .F.,,, aParam,,,.T.,,,,,)
														
Return()


Static Function fValidateInsert()
Local lRet := .T.
	
	If !U_BIAF149(M->ZM0_DATINI, M->ZM0_CLIENT, M->ZM0_LOJA, M->ZM0_GRUPO, M->ZM0_CNPJ, M->ZM0_ORIGEM, .F.)
	
		lRet := .F.
	
		MsgStop("Atenção, já existe uma solcititação de crédito em processamento para esse cliente ou grupo de clientes.")
	
	EndIf

	If U_fValFunc(Alltrim(M->ZM0_CNPJ))

		lRet := .F.
	
		MsgStop("Atenção, não é permitido incluir consultas para CPFs de Funcionários.")

	EndIf
	
Return(lRet)


User Function BIAF148C()
Local _oSemaforo	:=	tBiaSemaforo():New()

	_oSemaforo:cGrupo	:=	"BIAF147"

	If _oSemaforo:GeraSemaforo("JOB - BIAF147")		
	
		U_BIAMsgRun("Atualizando status das solicitações de crédito...", "Aguarde!", {|| U_BIAF147A() })

		_oSemaforo:LiberaSemaforo()
	
	EndIf

Return()


User Function BIAF148D()
Local aLeg := {}

	aAdd(aLeg, {"BR_VERDE", "Em Aberto"})
	aAdd(aLeg, {"BR_AMARELO", "Em Análise"})	
	aAdd(aLeg, {"BR_VERMELHO", "Finalizado"})
	aAdd(aLeg, {"BR_AZUL", "Erro no Processamento"})	
	
	BrwLegenda(cCadastro, "Legenda", aLeg)

Return()
