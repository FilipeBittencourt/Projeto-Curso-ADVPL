#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFMovimentoRemessaReceber
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe para tratar os titulos a receber que serao integrados com a API
@type class
/*/

#DEFINE _POS 1
#DEFINE _DATA 15
#DEFINE _POSHORA 5
#DEFINE _POSDATA 6

Class TAFMovimentoRemessaReceber From TAFAbstractClass

Data dEmissaoDe // Data de emissao
Data dEmissaoAte // Data de emissao
Data nDia // Dias a considerar no vencimento
Data lReenvBord // Identifica Reenvio do Bordero
Data cBorDe // Numero do Bordero De
Data cBorAte // Numero do Bordero Ate
Data cCliente // Cliente
Data cLoja // Loja
Data cCliExc
Data cPedido // Pedido de venda, utilizado para filtro de RA
Data cIDProc // Identificar do processo
Data lReproc // Reprocessamento	
Data oFat // Fatura a receber
Data oRcb // Objeto de regras de comunicacao bancaria
Data oBor // Objeto de regras de bordero de recebimento
Data lFIDC // FIDC	
Data cCliFiltro

Method New() Constructor
Method Get()
Method SetSend(nRecno, nTarAcrec)
Method GetAcre(cGNRE, cClasse, cEmpTit, cUFCli)
Method GetFatura(cPrefixo, cNumero, cParcela)
Method FilterValid()
Method IsGreater24Hour(cPrefixo, cNumero, cCliFor, cLoja, cParcela)
Method ValidFatura(cPrefixo, cNumero, cParcela, cCliFor, cLoja)

EndClass


Method New() Class TAFMovimentoRemessaReceber

	_Super:New()

	::dEmissaoDe 	:= STOD("20181217")
	::dEmissaoAte	:= dDataBase - 2
	::nDia 			:= 10
	::lReenvBord	:= .F.
	::cBorDe 		:= ""
	::cBorAte 		:= ""
	::cCliente 		:= ""
	::cLoja 		:= ""
	::cCliExc 		:= GetNewPar("MV_YAPICEX", "000481|005885|999999|022551|026423|026308|007871|004536|010083|008615|010064|025633|025634|025704|018410|014395|001042")
	::cPedido 		:= ""
	::cIDProc 		:= ""
	::lReproc 		:= .F.	
	::oFat 			:= TAFFaturaReceber():New()
	::oRcb 			:= TAFRegraComunicacaoBancaria():New()
	::oBor 			:= TAFBorderoReceber():New()
	::lFIDC			:= .F.
	::cCliFiltro	:= ""

Return()


Method Get() Class TAFMovimentoRemessaReceber
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local oObj := Nil

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_SEL_TIT"

	::oLog:Insert()

	// Bloco comentado, pois a classe devera tratar liquidacao de titulos ao invez de faturas
	//::oFat:dEmissao := ::dEmissao
	//::oFat:Create()

	// Utiliza a rotina customizada para geracao de faturas
	If !::lReproc

		If Empty(::cPedido)

			U_BIA507(.T., ::dEmissaoDe, ::dEmissaoAte)

		EndIf

	EndIf
	
	If (::lFIDC)
	
		//SEGUNDA: Filtrar os títulos com emissão menor que a QUINTA anterior (anterior a 4 dias)
		//TERÇA: Filtrar os títulos com emissão menor que a SEXTA anterior (anterior a 4 dias)
		//QUARTA: Filtrar os títulos com emissão menor a SEGUNDA (anterior a 2 dias)
		//QUINTA: Filtrar os títulos com emissão menor a TERÇA (anterior a 2 dias)
		//SEXTA: Filtrar os títulos com emissão menor a QUARTA (anterior a 2 dias)
		
		If (DOW(dDataBase) == 2 .Or. DOW(dDataBase) == 3) // segunda
			::dEmissaoAte	:= dDataBase - 4
		Else
			::dEmissaoAte	:= dDataBase - 2
		EndIf
		
	EndIf
	

	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR, E1_SALDO, E1_DECRESC, E1_PORCJUR, E1_EMISSAO, E1_VENCTO, E1_VENCREA, "
	cSQL += " E1_NUMBOR, E1_NUMBCO, E1_IDCNAB, E1_PEDIDO, E1_PORTADO, E1_AGEDEP, E1_CONTA, E1_SITUACA, E1_YCDGREG, E1_YCLASSE, E1_YEMP, E1_YUFCLI, SE1.R_E_C_N_O_ AS SE1_RECNO, "
	cSQL += " A1_YCDGREG, A1_YDTPRO, A1_YTFGNRE, A1_YEMABOL, E1_NATUREZ "

	//Inclui a Chave da NF
	if (FIDC():isFIDCEnabled())

		cSQL += " ,IsNull((SELECT DISTINCT (CASE SE1.E1_TIPO WHEN 'FT' THEN ("
		cSQL += "	SELECT  CAST("
		cSQL += "					STUFF("
		cSQL += "								(SELECT CHAR(59)+CONVERT(NVARCHAR(1024),ISNULL(SF2CHVNFE.F2_CHVNFE,''))"
		cSQL += "								FROM ("
		cSQL += "												SELECT DISTINCT SF2.F2_CHVNFE AS F2_CHVNFE"
		cSQL += "													FROM "+RetSQLName("SF2")+" SF2 (NOLOCK)"
		cSQL += "													JOIN "+RetSQLName("SE1")+" SE1FAT (NOLOCK)"
		cSQL += "													  ON SF2.D_E_L_E_T_=''"
		cSQL += "													 AND SE1FAT.D_E_L_E_T_=SF2.D_E_L_E_T_"
		cSQL += "													 AND SF2.F2_FILIAL=SE1FAT.E1_FILIAL"
		cSQL += "													 AND SF2.F2_DOC=SE1FAT.E1_NUM"
		cSQL += "													 AND SF2.F2_SERIE=SE1FAT.E1_SERIE"
		cSQL += "													 AND SF2.F2_CLIENT=SE1FAT.E1_CLIENTE"
		cSQL += "													 AND SF2.F2_LOJA=SE1FAT.E1_LOJA"
		cSQL += "													 AND SF2.F2_EMISSAO=SE1FAT.E1_EMISSAO"
		cSQL += "													 AND SE1FAT.E1_FILIAL=SE1.E1_FILIAL"
		cSQL += "													 AND SE1FAT.E1_CLIENTE=SE1.E1_CLIENTE"
		cSQL += "													 AND SE1FAT.E1_LOJA=SE1.E1_LOJA"
		cSQL += "													 AND SE1FAT.E1_FATURA=SE1.E1_NUM"
		cSQL += "								) SF2CHVNFE"
		cSQL += "								FOR XML PATH('')"
		cSQL += "								)"
		cSQL += "								,1"
		cSQL += "								,1"
		cSQL += "								,''"
		cSQL += "							)"
		cSQL += "						AS VARCHAR(1024))"
		cSQL += "					)"
		cSQL += "ELSE"
		cSQL += "(SELECT DISTINCT (SELECT SF2.F2_CHVNFE"
		cSQL += "					 FROM "+RetSQLName("SF2")+" SF2 (NOLOCK)"
		cSQL += "		            WHERE SF2.D_E_L_E_T_=''"
		cSQL += "		              AND SF2.F2_FILIAL=SE1.E1_FILIAL"
		cSQL += "		              AND SF2.F2_DOC=SE1.E1_NUM"
		cSQL += "		              AND SF2.F2_SERIE=SE1.E1_SERIE"
		cSQL += "		              AND SF2.F2_CLIENT=SE1.E1_CLIENTE"
		cSQL += "		              AND SF2.F2_LOJA=SE1.E1_LOJA"
		cSQL += "		              AND SF2.F2_EMISSAO=SE1.E1_EMISSAO)"
		cSQL += ") END ) AS F2_CHVNFE),'') AS F2_CHVNFE"

	endif

	
	cSQL += " FROM "+ RetSQLName("SE1") + " SE1 (NOLOCK) "
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " SA1 (NOLOCK) "
	cSQL += " ON A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
	cSQL += " AND E1_CLIENTE = A1_COD "
	cSQL += " AND E1_LOJA = A1_LOJA "
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_TIPO IN ('NF', 'FT', 'BOL', 'ST') "

	
	If (Empty(::cCliFiltro))
	
		// Tratmento para enviar titulos Provisorios (PR/CT) no mesmo dia, quando os mesmos tem erro de regra
		cSQL += " AND ( ( E1_EMISSAO BETWEEN " + ValToSQL(::dEmissaoDe) + " AND " + ValToSQL(dDataBase) + " AND E1_TIPO = 'BOL' AND SUBSTRING(E1_PREFIXO, 1, 2) IN ('PR', 'CT') AND E1_PEDIDO <> '' )
		cSQL += " OR "
		cSQL += " 	   ( E1_EMISSAO BETWEEN " + ValToSQL(::dEmissaoDe) + " AND " + ValToSQL(::dEmissaoAte) + " ) "
		cSQL += " OR "
		cSQL += " 	   ( E1_TIPO = 'FT' AND E1_EMISSAO BETWEEN " + ValToSQL(::dEmissaoDe) + " AND " + ValToSQL(dDataBase) + " ) ) "
	
		cSQL += " AND E1_YFORMA NOT IN ('3', '4') " // Não processa esses titulos
	
		If ::lReproc
	
			cSQL += " AND E1_NUMBOR <> '' "
			cSQL += " AND E1_YSITAPI NOT IN ('2', '') "
			cSQL += " AND E1_VENCREA >= " + ValToSQL(::dEmissaoAte)
	
		Else
	
			If !Empty(::cCliExc)
	
				cSQL += " AND E1_CLIENTE NOT IN " + FormatIn(::cCliExc, "|")
	
			EndIf
	
			If !Empty(::cCliente) .And. !Empty(::cLoja)
	
				cSQL += " AND E1_CLIENTE = " + ValToSQL(::cCliente) + " AND E1_LOJA = " + ValToSQL(::cLoja)
	
			EndIf
	
			If ::lReenvBord
	
				cSQL += " AND E1_NUMBOR BETWEEN " + ValToSQL(::cBorDe) + " AND " + ValToSQL(::cBorAte)
	
			Else
	
				cSQL += " AND E1_NUMBOR = '' "
	
			EndIf
	
			If !Empty(::cPedido)
	
				cSQL += " AND E1_PEDIDO = " + ValToSQL(::cPedido)
	
			EndIf
	
		EndIf
		
		cSQL += " AND SE1.E1_YSITAPI <> '4' "
		cSQL += " AND SE1.E1_SALDO > 0 "
		cSQL += " AND SE1.D_E_L_E_T_ = '' "
		cSQL += " AND SA1.D_E_L_E_T_ = '' "
	
	Else
		cSQL += " AND exists (select 1 from TBLSE1 T where T.R_E_C_N_O_ = SE1.R_E_C_N_O_ )  "
		cSQL += " AND E1_YSITAPI NOT IN ('2', '') 											"
		cSQL += " AND SE1.E1_SALDO > 0 														"
		cSQL += " AND SE1.D_E_L_E_T_ = '' 													"
		cSQL += " AND SA1.D_E_L_E_T_ = '' 													"
	Endif
	
	
	cSQL += " AND											"
	cSQL += " (												"
	cSQL += " select top 1 A6_YTPINTB from "+ RetSQLName("ZK0") + " ZK0				"
	cSQL += " join "+ RetSQLName("ZK1") + " ZK1 on 							"
	cSQL += " 	ZK0_FILIAL			= ZK1_FILIAL			"
	cSQL += " 	AND  ZK0_CODREG		= ZK1_CODREG 			"
	cSQL += " 	AND ZK1.D_E_L_E_T_	= ''					"
	cSQL += " join "+ RetSQLName("SA6") + "  SA6 on 		"
	cSQL += " 	A6_FILIAL			= ZK1_FILIAL 			"
	cSQL += " 	AND A6_COD			= ZK1_BANCO 			"
	cSQL += " 	AND A6_AGENCIA		= ZK1_AGENCI 			"
	cSQL += " 	AND A6_NUMCON		= ZK1_CONTA 			"
	cSQL += " 	AND SA6.D_E_L_E_T_	= ''					"
	cSQL += " where ZK0_CODGRU = A1_YCDGREG					"
	cSQL += " AND ZK0_FILIAL = ''							"
	cSQL += " AND ZK0.D_E_L_E_T_ = ''						"
	cSQL += " )	= "+IIf(::lFIDC, '1', "''")+"				"
	
	//cSQL += " AND NOT (E1_TIPO = 'FT' AND A1_YCDGREG = '000029')"
	/*
	cSQL += " AND											"
	cSQL += " NOT ((										"
	cSQL += " select top 1 A6_YTPINTB from "+ RetSQLName("ZK0") + " ZK0				"
	cSQL += " join "+ RetSQLName("ZK1") + "  ZK1 on 							"
	cSQL += " 	ZK0_FILIAL			= ZK1_FILIAL			"
	cSQL += " 	AND  ZK0_CODREG		= ZK1_CODREG 			"
	cSQL += " 	AND ZK1.D_E_L_E_T_	= ''					"
	cSQL += " join "+ RetSQLName("SA6") + " SA6 on 			"
	cSQL += " 	A6_FILIAL			= ZK1_FILIAL 			"
	cSQL += " 	AND A6_COD			= ZK1_BANCO 			"
	cSQL += " 	AND A6_AGENCIA		= ZK1_AGENCI 			"
	cSQL += " 	AND A6_NUMCON		= ZK1_CONTA 			"
	cSQL += " 	AND SA6.D_E_L_E_T_	= ''					"
	cSQL += " where ZK0_CODGRU = A1_YCDGREG					"
	cSQL += " AND ZK0_FILIAL = ''							"
	cSQL += " AND ZK0.D_E_L_E_T_ = ''						"
	cSQL += " )	= '1' AND E1_NATUREZ = '1230'	)			"	
	*/
	
	cSQL += " ORDER BY E1_CLIENTE, A1_YCDGREG "
	
	
	TcQuery cSQL New Alias (cQry)

	While (cQry)->(!Eof())

		oObj := TIAFMovimentoFinanceiro():New()

		oObj:cPrefixo := (cQry)->E1_PREFIXO
		oObj:cNumero := (cQry)->E1_NUM
		oObj:cParcela := (cQry)->E1_PARCELA
		oObj:cTipo := (cQry)->E1_TIPO
		oObj:cCliFor := (cQry)->E1_CLIENTE
		oObj:cLoja := (cQry)->E1_LOJA
		oObj:cEmail := (cQry)->A1_YEMABOL
		oObj:nValor := (cQry)->E1_VALOR
		oObj:nSaldo := (cQry)->E1_SALDO
		oObj:nAbat := SomaAbat((cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, "R", 1,, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA)
		oObj:nDesc := (cQry)->E1_DECRESC
		oObj:nAcre := ::GetAcre((cQry)->A1_YTFGNRE, (cQry)->E1_YCLASSE, AllTrim((cQry)->E1_YEMP), AllTrim((cQry)->E1_YUFCLI))
		oObj:nPerJur := (cQry)->E1_PORCJUR
		oObj:dEmissao := sToD((cQry)->E1_EMISSAO)
		oObj:dVencto := If (sToD((cQry)->E1_VENCTO) < dDataBase, dDataBase, sToD((cQry)->E1_VENCTO))
		oObj:dVencRea := sToD((cQry)->E1_VENCREA)
		oObj:cNumBor := (cQry)->E1_NUMBOR
		oObj:cNumBco := (cQry)->E1_NUMBCO
		oObj:cIDCnab := (cQry)->E1_IDCNAB
		oObj:cPedido := (cQry)->E1_PEDIDO
		oObj:lRecAnt := If (oObj:cTipo == "BOL" .And. SubStr(oObj:cPrefixo, 1, 2) $ "PR/CT" .And. !Empty(oObj:cPedido), .T., .F.)
		oObj:nRecNo := (cQry)->SE1_RECNO

		oObj:cBanco := (cQry)->E1_PORTADO
		oObj:cAgencia := (cQry)->E1_AGEDEP
		oObj:cConta := (cQry)->E1_CONTA
		oObj:cSubCta := ""
		oObj:cSituacao := "1"
		oObj:cEspecie := ""

		// Tratamento de juros diarios
		oObj:nJurosDia := (oObj:nPerJur / 100) * oObj:nSaldo + oObj:nJuros - oObj:nAbat

		// Tratamento de protesto
		oObj:nCodProt := If ((cQry)->A1_YDTPRO >= 6, 1, 2)
		oObj:nDiaProt := (cQry)->A1_YDTPRO

		// Calculo do valor total do boleto
		oObj:nValorBol := oObj:nSaldo + oObj:nJuros - oObj:nAbat //(oObj:nAbat + oObj:nDesc) + oObj:nAcre

		/*
		// Tratamento de mensagens livres
		oObj:cMsgLiv1 := If(Empty(oObj:cMsgLiv1), oObj:cMsgLiv1, oObj:cMsgLiv1 + " ") + "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA " + dToC(oObj:dVencto)

		/*If oObj:nDiaProt > 0

			oObj:cMsgLiv1 := If(Empty(oObj:cMsgLiv1), oObj:cMsgLiv1, oObj:cMsgLiv1 + " ") + "PROTESTAR APOS " + cValToChar(oObj:nDiaProt) + " DIAS ÚTEIS "

		EndIf
		*/

		If oObj:nJurosDia > 0

			oObj:cMsgLiv1 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "JUROS POR DIA DE ATRASO: R$ " + Alltrim(Transform(oObj:nJurosDia, "@E 99,999,999.99"))
			//oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "JUROS POR DIA DE ATRASO: R$ " + Alltrim(Transform(oObj:nJurosDia, "@E 99,999,999.99"))

		EndIf

		If oObj:lRecAnt

			oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "BOLETO REFERENTE AO PEDIDO DE VENDA: " + Upper(oObj:cPedido)

		EndIf

		If (oObj:nAcre > 0 .And. AllTrim((cQry)->E1_NATUREZ) == "1230")

			oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "TARIFA GNRE ELETRONICA: R$  " + Alltrim(Transform(oObj:nAcre, "@E 99,999,999.99"))

		EndIf


		If oObj:nDesc > 0

			oObj:cMsgLiv3 := If(Empty(oObj:cMsgLiv3), oObj:cMsgLiv3, oObj:cMsgLiv3 + " ") + "DESCONTO CONCEDIDO: R$ " + Alltrim(Transform(oObj:nDesc, "@E 99,999,999.99"))

		EndIf

		/*
		If oObj:nAcre > 0

		oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "GNRE " + Alltrim(Transform(oObj:nAcre, "@E 99,999,999.99"))

		EndIf
		*/

		If AllTrim(oObj:cTipo) == "FT"

			oObj:cMsgLiv3 := If(Empty(oObj:cMsgLiv3), oObj:cMsgLiv3, oObj:cMsgLiv3 + " ") + ::GetFatura(oObj:cPrefixo, oObj:cNumero, oObj:cParcela)

		EndIf

		oObj:cGRCB := (cQry)->A1_YCDGREG
		oObj:cRCB := (cQry)->E1_YCDGREG
		oObj:lMRCB := .F.

		//Inclui a Chave da NF
		if (FIDC():isFIDCEnabled())
			oObj:cCHVNFE:=(cQry)->F2_CHVNFE
		endif
		
		//TODO FIDC INICIO - Provisório
		
		//FIDC - tratamento de recebimento antecipado 
		If (AllTrim((cQry)->E1_YUFCLI) == 'ES' .And. AllTrim((cQry)->A1_YCDGREG) == '000029' .And. SubStr(oObj:cPrefixo, 1, 2) $ 'PR')
			oObj:cGRCB := '000028'
		EndIf
		
		//FIDC - tratamento de fatura
		If (AllTrim((cQry)->E1_YUFCLI) == 'ES' .And. AllTrim((cQry)->A1_YCDGREG) == '000029' .And. AllTrim(oObj:cTipo) == 'FT')
			oObj:cGRCB := '000028'
		EndIf
		// FIDC FIM - Provisório

		::oLst:Add(oObj)

		ConOut("TAF => BAF003 - [Processa Remessa de titulos a Receber] " + cEmpAnt + cFilAnt + " - TAFMovimentoRemessaReceber - " + oObj:cPrefixo + "-" + oObj:cNumero + "-" + oObj:cParcela + "-" + oObj:cTipo + " - DATE: "+DTOC(Date())+" TIME: "+Time())

		/*
		// Se for titulo de recebimento antecipado (Provisorio=PR, CT=Contrato), não avalia periodo de transmissao
		If oObj:lRecAnt

		::oLst:Add(oObj)

		EndIf

		// Se for fatura, valida se todos os titulos da fatura foram transmitidos a mais de 24 horas
		ElseIf AllTrim(oObj:cTipo) == "FT"

		If ::ValidFatura(oObj:cPrefixo, oObj:cNumero, oObj:cParcela, oObj:cCliFor, oObj:cLoja)

		::oLst:Add(oObj)

		EndIf

		// Valida o titulo foi transmitido a mais de 24 horas
		ElseIf ::IsGreater24Hour(oObj:cPrefixo, oObj:cNumero, oObj:cCliFor, oObj:cLoja, oObj:cParcela)

		::oLst:Add(oObj)

		EndIf
		*/

		::oLog:cIDProc := ::cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "S_SEL_TIT"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:nIDTab := oObj:nRecNo
		::oLog:cHrFin := Time()

		::SetSend((cQry)->SE1_RECNO, oObj:nAcre)

		::oLog:Insert()

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	If ::oLst:GetCount() > 0

		// Define regras de comunicacao bancaria
		::oRcb:cTipo := "R"
		::oRcb:cOpc := "E"
		::oRcb:oLst := ::oLst
		::oRcb:cIDProc := ::cIDProc

		::oRcb:Set()

	EndIf

	::FilterValid()

	If ::oLst:GetCount() > 0

		// Cria borderos
		::oBor:oLst := ::oLst
		::oBor:cIDProc := ::cIDProc

		::oBor:Create()

	Else

		// Registra dia sem movimento bancario 
		::oLog:cIDProc := ::cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "N_SEL_TIT"
		::oLog:cHrFin := Time()
		::oLog:cEnvWF := "N"

		::oLog:Insert()

	EndIf

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_SEL_TIT"
	::oLog:cHrFin := Time()

	::oLog:Insert()

Return(::oLst)


Method FilterValid() Class TAFMovimentoRemessaReceber
	Local oObj := ArrayList():New()
	Local nW

	For nW := 1 To ::oLst:GetCount()

		If ::oLst:GetItem(nW):lValid .And. !Empty(::oLst:GetItem(nW):cBanco)

			oObj:Add(::oLst:GetItem(nW))

		EndIf

	Next nW

	::oLst := oObj

Return(::oLst)


Method SetSend(nRecno, nTarAcrec) Class TAFMovimentoRemessaReceber

	Local aArea := SE1->(GetArea())

	SE1->(DbSetOrder(0))
	SE1->(DbGoTo(nRecno))

	If SE1->(!Eof())

		if SE1->(RecLock("SE1", .F.))

			SE1->E1_YSITAPI := "1" // 0=Pendente; 1=Enviado; 2=Retorno com Sucesso; 3=Retorno com Erro
			SE1->E1_YTXCOBR := nTarAcrec

			SE1->(MSUnlock())
		
		endif

	EndIf

	RestArea(aArea)

Return()


Method GetAcre(cGNRE, cClasse, cEmpTit, cUFCli) Class TAFMovimentoRemessaReceber
	Local nRet := 0

	If cGNRE == "S" .And. !::lFIDC

		If cClasse == "1"

			If cEmpAnt == "07" .And. cEmpTit == "0599" .And. cUFCli $ "SP_MG"

				If Dtos(SE1->E1_EMISSAO) >= "20150903"

					oTafNFRE	:= TAFTarifaGNRE():New()
					nRet 		:= oTafNFRE:TarifaPorEstado(cUFCli)

					/*If cUFCli == "MG"

					nRet := GetMv("MV_YVLBLMG")

					ElseIf cUFCli == "SP"

					nRet := GetMv("MV_YVLBLSP")

					EndIf*/

				Else

					nRet := 0

				EndIf

			Else

				oTafNFRE	:= TAFTarifaGNRE():New()
				nRet 		:= oTafNFRE:TarifaPorEstado(cUFCli)

				/*If cUFCli == "MG"

				nRet := GetMv("MV_YVLBLMG")

				ElseIf cUFCli == "ES"

				nRet:= GetMv("MV_YVLBLES")

				ElseIf cUFCli == "SP"

				nRet:= GetMv("MV_YVLBLSP")

				ElseIf cUFCli == "BA"

				nRet := GetMv("MV_YVLBLBA")

				ElseIf cUFCli == "RJ"

				nRet := GetMv("MV_YVLBLRJ")

				ElseIf cUFCli == "AL"

				nRet := GetMv("MV_YVLBLAL")

				ElseIf cUFCli == "RS"

				nRet := GetMv("MV_YVLBLRS")

				ElseIf cUFCli == "PR"

				nRet := GetMv("MV_YVLBLPR")

				ElseIf cUFCli == "SC"

				nRet := GetMv("MV_YVLBLSC")

				ElseIf cUFCli == "AP"

				nRet := GetMv("MV_YVLBLAP")

				ElseIf cUFCli == "PE"

				nRet := GetMv("MV_YVLBLPE")

				Else

				nRet	:= 0

				EndIf
				*/

			EndIf

		EndIf

	EndIf

Return(nRet)


Method GetFatura(cPrefixo, cNumero, cParcela) Class TAFMovimentoRemessaReceber
	Local cRet := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT DISTINCT E1_NUM, E1_PARCELA "
	cSQL += " FROM " + RetSqlName("SE1")
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_FATPREF = "+ ValToSQL(cPrefixo)
	cSQL += " AND E1_FATURA = "+ ValToSQL(cNumero)
	cSQL += " AND E1_YPARCFT = "+ ValToSQL(cParcela)
	cSQL += " AND E1_TIPOFAT = 'FT' "
	cSQL += " AND E1_FLAGFAT = 'S' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While (cQry)->(!Eof())

		If Empty(cRet)

			cRet := "Fatura Ref NF/Parcela:"

		EndIf

		cRet += AllTrim((cQry)->E1_NUM) + '/' + AllTrim((cQry)->E1_PARCELA) + Space(1)

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(cRet)


Method IsGreater24Hour(cPrefixo, cNumero, cCliFor, cLoja, cParcela) Class TAFMovimentoRemessaReceber
	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cIdEnt := GetCfgEntidade()
	Local cSpedUrl := GetNewPar("MV_SPEDURL","")
	Local cAviso := ""
	Local aRetorno := {}
	Local nRet := 0
	Local dDateIni := Date()
	Local cHoraIni := Time()
	Local dDateFim := Date()
	Local cHoraFim := Time()

	aRetorno := ProcMonitorDoc(cIdEnt, cSpedUrl, {cPrefixo, cNumero, cNumero, cCliFor, cLoja}, 1, "", .F., @cAviso)

	If Len(aRetorno) > 0

		dDateIni := aRetorno[_POS][_DATA][_POSDATA]

		cHoraIni := SubStr(aRetorno[_POS][_DATA][_POSHORA], 1, 8)

		If aRetorno[1, 5] $ "100"

			cSQL := " SELECT CONVERT(FLOAT, DATEDIFF(MINUTE, '" + DTOS(dDateIni) + " " + cHoraIni + "', '" + DTOS(dDateFim) + " " + cHoraFim + "') ) / 60.0 HORAS "

			TcQuery cSQL New Alias (cQry)

			nRet := (cQry)->HORAS

			lRet := nRet >= 24

			(cQry)->(DbCloseArea())

		EndIf

	EndIf

	Conout("TAFMovimentoRemessaReceber:IsGreater24Hour() - NF: " + cNumero + "/" + cPrefixo + "/" + cParcela + " Filial: " + cEmpAnt + cFilAnt + " Retorno: " + If(nRet > 0, aRetorno[1, 5], "Vazio") + " [" + cValToChar(If(nRet > 0, nRet, 0)) + " horas]")

Return(lRet)


Method ValidFatura(cPrefixo, cNumero, cParcela, cCliFor, cLoja) Class TAFMovimentoRemessaReceber
	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT DISTINCT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA "
	cSQL += " FROM " + RetSqlName("SE1")
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_FATPREF = "+ ValToSQL(cPrefixo)
	cSQL += " AND E1_FATURA = "+ ValToSQL(cNumero)
	cSQL += " AND E1_YPARCFT = "+ ValToSQL(cParcela)
	cSQL += " AND E1_CLIENTE = "+ ValToSQL(cCliFor)
	cSQL += " AND E1_LOJA = "+ ValToSQL(cLoja)
	cSQL += " AND E1_TIPOFAT = 'FT' "
	cSQL += " AND E1_FLAGFAT = 'S' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While lRet .and. (cQry)->(!Eof())

		lRet := ::IsGreater24Hour((cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA, (cQry)->E1_PARCELA)

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(lRet)
