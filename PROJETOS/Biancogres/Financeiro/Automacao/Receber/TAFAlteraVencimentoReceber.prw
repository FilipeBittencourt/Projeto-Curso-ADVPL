#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFAlteraVencimentoReceber
@author Fernando Rocha
@since 04/03/2020
@project Automação Financeira
@version 1.0
@description Classe para tratar os titulos a receber que serao integrados com a API
@type class
/*/

#DEFINE _POS 1
#DEFINE _DATA 15
#DEFINE _POSHORA 5
#DEFINE _POSDATA 6

Class TAFAlteraVencimentoReceber From TAFAbstractClass

    Data dEmissaoDe // Data de emissao
    Data dEmissaoAte // Data de emissao
    Data nDia // Dias a considerar no vencimento
    Data lReenvBord // Identifica Reenvio do Bordero
    Data cBorDe // Numero do Bordero De
    Data cBorAte // Numero do Bordero Ate
    Data cCliente // Cliente
    Data cLoja // Loja
    Data cPedido // Pedido de venda, utilizado para filtro de RA
    Data cIDProc // Identificar do processo
    Data lReproc // Reprocessamento
    
    Data oRcb // Objeto de regras de comunicacao bancaria
	Data oApi // Objeto de integracao com a API 

    Method New() Constructor
    Method Get()
    Method SetSend(nRecno, nTarAcrec)
    Method Send()

EndClass


Method New() Class TAFAlteraVencimentoReceber

    _Super:New()

    ::dEmissaoDe := STOD("20181217")
    ::dEmissaoAte := dDataBase - 2
    ::nDia := 10
    ::lReenvBord := .F.
    ::cBorDe := ""
    ::cBorAte := ""
    ::cCliente := ""
    ::cLoja := ""
     ::cPedido := ""
    ::cIDProc := ""
    ::lReproc := .F.
    ::oRcb := TAFRegraComunicacaoBancaria():New()
	
	::oApi := TAFIntegracaoApi():New()

Return()


Method Get() Class TAFAlteraVencimentoReceber
    Local cSQL := ""
    Local cQry := GetNextAlias()
    Local oObj := Nil
    Local oObjRem := TAFMovimentoRemessaReceber():New()

    ::oLog:cIDProc := ::cIDProc
    ::oLog:cOperac := "R"
    ::oLog:cMetodo := "I_ALTV_TIT"
    ::oLog:Insert()

    cSQL := " SELECT ZKC.R_E_C_N_O_ AS ZKC_RECNO, SE1.R_E_C_N_O_ AS SE1_RECNO, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR, E1_SALDO, E1_DECRESC, E1_PORCJUR, E1_EMISSAO, E1_VENCTO, E1_VENCREA, "+CRLF
    cSQL += " E1_NUMBOR, E1_NUMBCO, E1_IDCNAB, E1_PEDIDO, E1_PORTADO, E1_AGEDEP, E1_CONTA, E1_SITUACA, E1_YCDGREG, E1_YCLASSE, E1_YEMP, E1_YUFCLI,  "+CRLF
    cSQL += " A1_YCDGREG, A1_YDTPRO, A1_YTFGNRE, A1_YEMABOL, E1_NATUREZ  "+CRLF
    cSQL += " from " + RetSqlName("ZKC") + " ZKC (nolock) "+CRLF
    cSQL += " join " + RetSqlName("ZK8") + " ZK8 (nolock) on ZK8_FILIAL = ZKC_FILIAL and ZK8_NUMERO = ZKC_NUMERO "+CRLF
    cSQL += " join " + RetSqlName("SE1") + " SE1 (nolock) on E1_FILIAL = ZKC_FILIAL and E1_PREFIXO = ZKC_PREFIX and E1_NUM = ZKC_NUM and E1_PARCELA = ZKC_PARCEL and E1_TIPO = ZKC_TIPO "+CRLF
    cSQL += " join " + RetSqlName("SA1") + " SA1 (nolock) on A1_FILIAL = '  ' and A1_COD = E1_CLIENTE and A1_LOJA = E1_LOJA "+CRLF
    cSQL += " where ZKC_FILIAL = '01' "+CRLF
    cSQL += " and ZKC_STATUS = 'A' "+CRLF
    cSQL += " AND SE1.E1_SALDO > 0 "+CRLF
    cSQL += " AND E1_PORTADO <> '' "+CRLF
    
    cSQL += " AND "
    cSQL += " ( "
    cSQL += "   ( "
    cSQL += "       ZK8_STATUS = 'B' " // Baixados
    cSQL += "       AND EXISTS ( "
    cSQL += "       				SELECT NULL "
    cSQL += "       				FROM   " + RetSQLName("ZKC") + " A (NOLOCK) "
    cSQL += "       				WHERE  A.ZKC_FILIAL  = ZKC.ZKC_FILIAL "
    cSQL += "       				AND  A.ZKC_NUMERO 	 = ZKC.ZKC_NUMERO "
    cSQL += "       				AND  A.ZKC_STATUS 	 = 'J' "
    cSQL += "                       AND EXISTS ( "
    cSQL += "                     	    	    SELECT NULL "
    cSQL += "                     	    	    FROM   " + RetSQLName("SE1") + " B (NOLOCK) "
    cSQL += "                     	    	    WHERE  B.E1_FILIAL = A.ZKC_FILIAL "
    cSQL += "                     	    	    AND  B.E1_NUM      = A.ZKC_NUM "
    cSQL += "                     	    	    AND  B.E1_PREFIXO  = A.ZKC_PREFIX "
    cSQL += "                     	    	    AND  B.E1_PARCELA  = A.ZKC_PARCEL "
    cSQL += "                     	    	    AND  B.E1_CLIENTE  = A.ZKC_CLIFOR "
    cSQL += "                     	    	    AND  B.E1_LOJA     = A.ZKC_LOJA "
    cSQL += "                                   AND  B.E1_SALDO    = 0 "
    cSQL += "                                   AND  B.E1_BAIXA    <= " + ValToSql(dDataBase - 1)
    cSQL += "                     	    		AND  B.D_E_L_E_T_  = '' "
    cSQL += "                     			) "
    cSQL += "       				AND  A.D_E_L_E_T_  = '' "
    cSQL += "       			) "
    cSQL += "     ) "
    cSQL += "     OR "
    cSQL += "     ( "
    cSQL += "        ZK8_STATUS = 'A' " // Nao tem titulo de juros a receber apenas alterar as datas mesmo
    cSQL += "        AND NOT EXISTS ( "
    cSQL += "        				SELECT NULL "
    cSQL += "        				FROM   " + RetSQLName("ZKC") + " A (NOLOCK) "
    cSQL += "        				WHERE  A.ZKC_FILIAL  = ZKC.ZKC_FILIAL "
    cSQL += "        				AND  A.ZKC_NUMERO 	 = ZKC.ZKC_NUMERO "
    cSQL += "        				AND  A.ZKC_STATUS 	 = 'J' "
    cSQL += "        				AND  A.D_E_L_E_T_  = '' "
    cSQL += "        			) "
    cSQL += "     ) "
    cSQL += " ) "

    cSQL += " and ZKC.D_E_L_E_T_ = '' "+CRLF
    cSQL += " and ZK8.D_E_L_E_T_ = '' "+CRLF
    cSQL += " and SE1.D_E_L_E_T_ = '' "+CRLF
    cSQL += " and SA1.D_E_L_E_T_ = '' "+CRLF

    TcQuery cSQL New Alias (cQry)

    While !(cQry)->(Eof())

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
        oObj:nAcre := oObjRem:GetAcre((cQry)->A1_YTFGNRE, (cQry)->E1_YCLASSE, AllTrim((cQry)->E1_YEMP), AllTrim((cQry)->E1_YUFCLI))
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

        // Tratamento de mensagens livres
        oObj:cMsgLiv1 := If(Empty(oObj:cMsgLiv1), oObj:cMsgLiv1, oObj:cMsgLiv1 + " ") + "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA " + dToC(oObj:dVencto)

        If oObj:nDiaProt > 0

            oObj:cMsgLiv1 := If(Empty(oObj:cMsgLiv1), oObj:cMsgLiv1, oObj:cMsgLiv1 + " ") + "PROTESTAR APOS " + cValToChar(oObj:nDiaProt) + " DIAS ÚTEIS "

        EndIf

        If oObj:nJurosDia > 0

            oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "JUROS POR DIA: R$ " + Alltrim(Transform(oObj:nJurosDia, "@E 99,999,999.99"))

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

        If AllTrim(oObj:cTipo) == "FT"

            oObj:cMsgLiv3 := If(Empty(oObj:cMsgLiv3), oObj:cMsgLiv3, oObj:cMsgLiv3 + " ") + oObjRem:GetFatura(oObj:cPrefixo, oObj:cNumero, oObj:cParcela)

        EndIf

        oObj:cGRCB := (cQry)->A1_YCDGREG
        oObj:cRCB := (cQry)->E1_YCDGREG
        oObj:lMRCB := .F.

        ::oLst:Add(oObj)

        ConOut("TAF => BAF045 - [Processa Remessa de titulos a Receber] " + cEmpAnt + cFilAnt + " - TAFAlteraVencimentoReceber - " + oObj:cPrefixo + "-" + oObj:cNumero + "-" + oObj:cParcela + "-" + oObj:cTipo + " - DATE: "+DTOC(Date())+" TIME: "+Time())

        ::oLog:cIDProc := ::cIDProc
        ::oLog:cOperac := "R"
        ::oLog:cMetodo := "S_ALTV_TIT"
        ::oLog:cTabela := RetSQLName("SE1")
        ::oLog:nIDTab := oObj:nRecNo
        ::oLog:cHrFin := Time()

        ::SetSend((cQry)->ZKC_RECNO)

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

    ::oLog:cIDProc := ::cIDProc
    ::oLog:cOperac := "R"
    ::oLog:cMetodo := "F_SEL_TIT"
    ::oLog:cHrFin := Time()

    ::oLog:Insert()

Return(::oLst)


Method SetSend(nRecno) Class TAFAlteraVencimentoReceber

	Local aArea := ZKC->(GetArea())

	ZKC->(DbSetOrder(0))
	ZKC->(DbGoTo(nRecno))

	If !ZKC->(Eof())

		RecLock("ZKC", .F.)
		ZKC->ZKC_STATUS := "F"
		ZKC->(MSUnlock())

	EndIf

	RestArea(aArea)

Return()


Method Send() Class TAFAlteraVencimentoReceber
	
	::oPro:Start()
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_ALTV_LOT"	
	::oLog:Insert()
		
	::cIDProc := ::oPro:cIDProc
	
	::Get()
	
	If !Empty(::oLst)

		::oApi:cTipo    := "R"
		::oApi:cOpcEnv  := "L"
        ::oApi:GArqRem  := "S"
        ::oApi:CMovRem  := "06"
		::oApi:oLst := ::oLst
		::oApi:cIDProc := ::oPro:cIDProc
		
		::oApi:Send()
	
	EndIf
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"	
	::oLog:cMetodo := "F_ALTV_LOT"
	::oLog:cHrFin := Time()	
	::oLog:Insert()
	
	::oPro:Finish()
		 	
Return()

