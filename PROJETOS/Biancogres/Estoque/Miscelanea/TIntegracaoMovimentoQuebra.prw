#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoMovimentoQuebra
@author Wlysses Cerqueira (Facile)
@since 30/06/2020  
@project C-15
@version 1.0
@description 
@type function
/*/

User Function PROCQUEB()

    Local oObj := Nil

   // RpcSetEnv("01", "01")

    oObj := TIntegracaoMovimentoQuebra():New()

    oObj:Processa()


Return()

User Function PROCQBIT(cEmp, cFil, cRec)

    Local oObj := Nil

    RpcSetEnv(cEmp, cFil)

	    oObj := TIntegracaoMovimentoQuebra():New()
	
	    oObj:Processa(cRec)

    RpcClearEnv()

Return()

Class TIntegracaoMovimentoQuebra From LongClassName

    Data lErro
    Data aErro
    Data lFound
    Data cEmail

    Public Method New() Constructor
    Public Method Processa()

    Public Method ProcSBF(cQry)
    Public Method ProcSC0(cQry)
    Public Method ProcSC9(cQry)
    Public Method GetQtdPallet(cProduto)
    Public Method GravaLog()
    Public Method Workflow()
    Public Method ErroWorkflow()
    
    Public Method Log(cTab, cQry, cLog, cStatus)

EndClass

Method New(lJob) Class TIntegracaoMovimentoQuebra

    ::lErro := .F.

    ::aErro := {}

    ::lFound := .F.

    ::cEmail := U_EmailWF('INTMOVQB', cEmpAnt)//U_GetBiaPar("MV_EMAILINTMOVQUEB", "wlysses@facilesistemas.com.br")

Return(Self)

Method Processa(cRec) Class TIntegracaoMovimentoQuebra

    Local cQry 		:= GetNextAlias()
    Local cSQL 		:= ""
    Default cRec	:= ""

    DBSelectArea("ZL8")

    cSQL := " SELECT  * "
    cSQL += " FROM " + RetSqlName("ZL8") + " A "
    cSQL += " WHERE A.ZL8_CODEMP = " + ValToSql(cEmpAnt)
    cSQL += " AND A.ZL8_CODFIL   = " + ValToSql(cFilAnt)
    
    If (!Empty(cRec))
    	cSQL += " AND A.ZL8_STATUS   IN ('A', 'E') " // A=Aguard. Processamento;P=Processado;B=Bloqueado;E=Erro
    	cSQL += " AND A.R_E_C_N_O_   = '"+cValToChar(cRec)+"' " 
    Else
    	cSQL += " AND A.ZL8_STATUS   = 'A' " // A=Aguard. Processamento;P=Processado;B=Bloqueado;E=Erro
    	cSQL += " AND A.ZL8_DATA >= '20210301' "
    EndIf
    
    // 
    
    cSQL += " ORDER BY ZL8_CODEMP, ZL8_CODFIL, ZL8_ETIQUE "
    
    ConOut(::cEmail)
    
    TcQuery cSQL New Alias (cQry)

    While !(cQry)->(EOF())

        Begin Transaction

            ::aErro := {}

            ::lErro := .F.

            ::lFound := .F.

            If !::lFound .And. !::lErro

                ::ProcSBF(cQry) // Tentativa por saldo por endereço

            EndIf

            If !::lFound .And. !::lErro

                ::ProcSC0(cQry) // Tentativa por saldo por reserva SC0

            EndIf

            If !::lFound .And. !::lErro

                // C5_TIPOCLI -> F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacao/Importacao
                // C5_YFORMA  -> 1=Banco;2=Cheque;3=OP;4=CT
                // C5_YSUBTP  -> Lista

                ::ProcSC9(cQry, {|| AllTrim((cQrySC9)->C5_TIPOCLI) $ "R|S" .And. AllTrim((cQrySC9)->C5_YSUBTP) $ "E|N" .And. AllTrim((cQrySC9)->C5_YFORMA) == "A" .And. SC9->C9_QTDLIB > ::GetQtdPallet(SC9->C9_PRODUTO)}) // Tentativa por saldo por reserva SC9

            EndIf

            If !::lFound .And. !::lErro

                ::ProcSC9(cQry, {|| AllTrim((cQrySC9)->C5_TIPOCLI) $ "F" .And. AllTrim((cQrySC9)->C5_YSUBTP) $ "E|N" .And. AllTrim((cQrySC9)->C5_YFORMA) == "A" .And. Len(AllTrim((cQrySC9)->A1_CGC)) <> 11 .And. SC9->C9_QTDLIB > ::GetQtdPallet(SC9->C9_PRODUTO)}) // Tentativa por saldo por reserva SC9

            EndIf

            If !::lFound .And. !::lErro

                ::ProcSC9(cQry) // Tentativa por saldo por reserva SC9

            EndIf

            If !::lFound .And. !::lErro

                ::Log("SBF", cQry, "Não foi encontrado saldo suficiente", "E")
                
                
            EndIf

            If ::lErro

                DisarmTransaction()

            EndIf

        End Transaction

        ::GravaLog() // Apos Commit/Rollback

        (cQry)->(DbSkip())

    EndDo

    (cQry)->(DbCloseArea())

Return()

Method ProcSBF(cQry) Class TIntegracaoMovimentoQuebra

    Local oItem 	:= Nil
    Local _cCLVL	:= "2120"
    Local _CC		:= "2000"
    Local _cDoc		:= ""

    DBSelectArea("SBF")
    SBF->(dbSetOrder(2)) // BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOTECTL, BF_NUMLOTE, BF_PRIOR, BF_LOCALIZ, BF_NUMSERI, R_E_C_N_O_, D_E_L_E_T_

    If SBF->(DBSeek(xFilial("SBF") + (cQry)->ZL8_PRODUT))

        While !SBF->(EOF()) .And. SBF->(BF_FILIAL + BF_PRODUTO) == xFilial("SBF") + (cQry)->ZL8_PRODUT

            If SBF->BF_QUANT - SBF->BF_EMPENHO >= (cQry)->ZL8_QUANT .And. SBF->BF_LOTECTL == (cQry)->ZL8_LOTECT

                //New(nOpcao, cProd, cLocal, nQuant, cClasseVr, cTipoMov, dDataEmis, nIdEco, cLocaliza, cOriMov, cTag, cAplica, cMatric)
                If (!Empty((cQry)->ZL8_CLVL))
                	_cCLVL := (cQry)->ZL8_CLVL
                EndIf
                
                If (SUBSTR(_cCLVL, 1, 1) == '2')
                	_CC := '2000'
                ElseIf (SUBSTR(_cCLVL, 1, 1) == '3')
                	_CC := '3000'
                ElseIf (SUBSTR(_cCLVL, 1, 1) == '4')
                	_CC := '4000'	
                EndIf
                
                oItem := TMovimentacaoInterna():New(3, (cQry)->ZL8_PRODUT, SBF->BF_LOCAL, (cQry)->ZL8_QUANT, _cCLVL, "503", STOD((cQry)->ZL8_DATA) , 0, SBF->BF_LOCALIZ, "", "", "2", "", _CC, (cQry)->ZL8_LOTECT)
                
                oItem:Executar()
                
                _cDoc 	:= oItem:cDocumento
                
                ::lErro := !oItem:lOk

                ::lFound := .T.

                If ::lErro

                    ::Log("SBF", cQry, oItem:cLog, "E")
                    
                Else

                    ::Log("SBF", cQry, "Baixa efetuada", "P", _cDoc)

                EndIf

                Exit

            EndIf

            SBF->(DbSkip())

        EndDo

    Else

        ::lErro := .T.
        ::lFound := .F.

        ::Log("SBF", cQry, "Não encontrado saldo em endereço!", "E")
    
    EndIf

Return()

Method ProcSC0(cQry) Class TIntegracaoMovimentoQuebra

    Local cSQL      := ""
    Local cQrySC0   := GetNextAlias()
    Local aAreaSC0  := SC0->(GetArea())

    cSQL := " SELECT SC0.* "
    cSQL += " FROM " + RetSQLName("SC0") + " SC0 "
    cSQL += " WHERE SC0.C0_FILIAL   = " + ValToSQL(xFilial("SC0"))
    cSQL += " AND SC0.C0_PRODUTO    = " + ValToSQL((cQry)->ZL8_PRODUT)
    cSQL += " AND C0_LOTECTL        = " + ValToSQL((cQry)->ZL8_LOTECT)
    cSQL += " AND C0_YPEDIDO        = '' "
    cSQL += " AND SC0.D_E_L_E_T_    = '' "

    TcQuery cSQL New Alias (cQrySC0)

    DBSelectArea("SC0")

    While !(cQrySC0)->(Eof())

        If (cQrySC0)->C0_QUANT >= (cQry)->ZL8_QUANT // Caso o empenho na SC0 sera maior ou igual a qtd requerida

            ::lErro := !a430Reserv({3,"VD","",(cQry)->ZL8_USER,XFilial("SC0")},; // A funcao estorna tudo
            (cQrySC0)->C0_NUM,;
                (cQrySC0)->C0_PRODUTO,;
                (cQrySC0)->C0_LOCAL,;
                (cQrySC0)->C0_QUANT,;
                {	SC0->C0_NUMLOTE,;
                (cQrySC0)->C0_LOTECTL,;
                (cQrySC0)->C0_LOCALIZ,;
                (cQrySC0)->C0_NUMSERI})

            ::lFound := .T.

            If ::lErro

                ::Log("SC0", cQry, "Achou saldo na SC0, mas não conseguiu estornar", "E")
             
            Else  // Significa que estornou a SC0, e o empenho foi retirado da SBF, portanto faz a baixa

                ::ProcSBF(cQry)

            EndIf

            If !::lErro .And. (cQrySC0)->C0_QUANT <> (cQry)->ZL8_QUANT // Significa que foi estornado parte da SC0, e pre

                cNumero := GetSx8Num("SC0","C0_NUM") //Gerando a nova reserva total do mesmo lote
                ConfirmSx8()

                ::lErro := !a430Reserva({1,"VD","",cUserName,XFilial("SC0")},;
                    cNumero,;
                    (cQrySC0)->C0_PRODUTO,;
                    (cQrySC0)->C0_LOCAL,;
                    ((cQrySC0)->C0_QUANT - (cQry)->ZL8_QUANT),;
                    {"", (cQrySC0)->C0_LOTECTL, (cQrySC0)->C0_LOCALIZ, (cQrySC0)->C0_NUMSERI})

                	SC0->(DbSetOrder(1))
					If SC0->(DbSeek(XFilial("SC0")+cNumero+(cQrySC0)->C0_PRODUTO))
						RecLock("SC0",.F.)
						SC0->C0_VALIDA		:= stod((cQrySC0)->C0_VALIDA)
						SC0->C0_YPRASOL		:= stod((cQrySC0)->C0_YPRASOL)
						SC0->C0_DOCRES		:= (cQrySC0)->C0_DOCRES
						SC0->C0_SOLICIT		:= (cQrySC0)->C0_SOLICIT
						SC0->(MsUnlock())
					EndIf    

                If ::lErro

                    ::Log("SC0", cQry, "Achou saldo na SC0 (Saldo: " + cValToChar((cQrySC0)->C0_QUANT) + " Qtd. Requerida: " + cValToChar((cQry)->ZL8_QUANT) + "), ao refazer a reserva do saldo não conseguiu reservar", "E")
                    
                EndIf

            EndIf

            Exit

        EndIf

        (cQrySC0)->(DbSkip())

    EndDo

    (cQrySC0)->(DbCloseArea())

    RestArea(aAreaSC0)

Return()

Method ProcSC9(cQry, bValid) Class TIntegracaoMovimentoQuebra

    Local cSQL          := ""
    Local cQrySC9       := GetNextAlias()
    Local aAreaSC9      := SC9->(GetArea())

    Local nQtdLib   := 0
    Local nQtdReq   := 0
    
    Local nQtd2     := 0
    Local nSaldo    := 0

    Local lCredito 	:= .T.
    Local lEstoque	:= .T.
    Local lAvalCred	:= .T.

    Default bValid := {|| .T.}

    cSQL := " SELECT C5_VEND1, C5_TIPOCLI, A1_CGC, A1_NOME, A1_COD, A1_LOJA, C5_YFORMA, C5_YSUBTP, SC9.C9_ITEM, SC9.C9_PEDIDO, SC9.C9_PRODUTO, SC9.R_E_C_N_O_ RECNO_SC9 "
    cSQL += " FROM " + RetSQLName("SC9") + " SC9 (NOLOCK) "

    cSQL += " JOIN " + RetSQLName("SC5") + " SC5 (NOLOCK) ON "
    cSQL += " ( "
    cSQL += "   SC5.C5_FILIAL      = " + ValToSQL(xFilial("SC5"))
    cSQL += "   AND SC5.C5_NUM     = SC9.C9_PEDIDO "
    cSQL += "   AND SC5.D_E_L_E_T_ = '' "
    cSQL += " ) "

    cSQL += " JOIN " + RetSQLName("SA1") + " SA1 (NOLOCK) ON "
    cSQL += " ( "
    cSQL += "   SA1.A1_FILIAL   = " + ValToSQL(xFilial("SA1"))
    cSQL += "   AND SA1.A1_COD      = SC5.C5_CLIENTE "
    cSQL += "   AND SA1.A1_LOJA     = SC5.C5_LOJACLI "
    cSQL += "   AND SA1.D_E_L_E_T_ = '' "
    cSQL += " ) "

    cSQL += " WHERE SC9.C9_FILIAL   = " + ValToSQL(xFilial("SC9"))
    cSQL += " AND SC9.C9_PRODUTO    = " + ValToSQL((cQry)->ZL8_PRODUT)
    cSQL += " AND SC9.C9_LOTECTL    = " + ValToSQL((cQry)->ZL8_LOTECT)
    cSQL += " AND SC9.C9_BLCRED     = '' "
    cSQL += " AND SC9.C9_BLEST      = '' "

    cSQL += " AND NOT EXISTS "
    cSQL += " ( "
    cSQL += "     SELECT * "
    cSQL += "     FROM " + RetSQLName("ZZW") + " ZZW (NOLOCK) "
    cSQL += "     WHERE ZZW.D_E_L_E_T_ = '' "
    cSQL += "     AND ZZW.ZZW_FILIAL = " + ValToSQL(xFilial("ZZW"))
    cSQL += "     AND ZZW.ZZW_PEDIDO = SC9.C9_PEDIDO "
    cSQL += "     AND ZZW.ZZW_ITEM   = SC9.C9_ITEM "
    cSQL += "     AND ZZW.ZZW_SEQUEN = SC9.C9_SEQUEN "
    cSQL += "     AND ZZW.ZZW_CCLI   = SC9.C9_CLIENTE "
    cSQL += "     AND ZZW.ZZW_LCLI   = SC9.C9_LOJA "
    cSQL += " ) "

    cSQL += " AND SC9.D_E_L_E_T_    = '' "

    TcQuery cSQL New Alias (cQrySC9)

    DBSelectArea("SC9")

    DbSelectArea("SC6")
    SC6->(DbSetOrder(1)) // C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_

    While !(cQrySC9)->(Eof())

        SC9->(DBGoTo((cQrySC9)->RECNO_SC9))

        If !SC9->(EOF())

            nQtdReq := (cQry)->ZL8_QUANT

            nQtdLib := SC9->C9_QTDLIB

            If nQtdLib >= nQtdReq .And. Eval(bValid) // Caso o empenho na SC9 seja maior ou igual a qtd requerida

                ::lErro := !SC9->(a460Estorna()) // Rotina de estorno

                ::lFound := .T.

                If ::lErro

                    ::Log("SC9", cQry, "Achou saldo na SC9, mas não conseguiu estornar", "E")

                Else  // Significa que estornou a SC9, e o empenho foi retirado da SBF, portanto faz a baixa

                    ::ProcSBF(cQry)

                EndIf

                If !::lErro .And. nQtdLib <> nQtdReq // Significa que foi estornado parte da SC9, e pre

                    // Rotina de empenho
                    If SC6->(DbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM))

                        nSaldo := nQtdLib - nQtdReq

                        nQtd2 := ConvUM(SC6->C6_PRODUTO, nSaldo, 0, 2)

                        nQtdLib := MaLibDoFat(SC6->(RecNo()),nSaldo,@lCredito,@lEstoque,lAvalCred,.T.,.F.,.F.,NIL,NIL,NIL,NIL,NIL,NIL,nQtd2)

                        If nQtdLib <> nSaldo

                            ::lErro := .T.

                            ::Log("SC9", cQry, "Achou saldo na SC9 (Saldo: " + cValToChar(nQtdLib) + " Qtd. Requerida: " + cValToChar(nQtdReq) + "), ao refazer a reserva do saldo não conseguiu reservar", "E")

                        Else

                            ::Workflow(cQrySC9, cQry)

                        EndIf

                    Else

                        ::Log("SC9", cQry, "Item não encontrado na SC6", "E")

                        ::lErro := .T.

                    EndIf

                EndIf

                Exit

            EndIf

        EndIf

        (cQrySC9)->(DbSkip())

    EndDo

    (cQrySC9)->(DbCloseArea())

    RestArea(aAreaSC9)

Return()

Method GetQtdPallet(cProduto, cLote) Class TIntegracaoMovimentoQuebra

    Local nQtdPallet := 0

    Default cProduto := ""
    Default cLote := ""

    DBSelectArea("ZZ9")
    ZZ9->(DBSetOrder(2)) // ZZ9_FILIAL, ZZ9_PRODUT, ZZ9_LOTE, R_E_C_N_O_, D_E_L_E_T_

    DBSelectArea("SB1")
    SB1->(DBSetOrder(1)) // B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_

    If ZZ9->(DBSeek(xFilial("ZZ9") + cProduto + cLote))

        If SB1->(DBSeek(xFilial("SB1") + cProduto))

            nQtdPallet := ( ZZ9->ZZ9_DIVPA * SB1->B1_CONV )

        EndIf

    EndIf

Return(nQtdPallet)

Method Log(cTab, cQry, cLog, cStatus, cDoc) Class TIntegracaoMovimentoQuebra

    Default cTab 	:= ""
    Default cLog 	:= ""
    Default cDoc	:= ""

    aAdd(::aErro, {(cQry)->R_E_C_N_O_, cTab, cLog, cStatus, cDoc})

Return()

Method GravaLog() Class TIntegracaoMovimentoQuebra

    Local nW 		:= 0
    Local cErro		:= ""
    Local cLote		:= ""
    Local cProduto	:= ""
    Local cEtiqueta	:= ""
    Local cQuantidade:= ""
    
    DBSelectArea("ZL8")

    For nW := 1 To Len(::aErro)

        ZL8->(DBGoTo(::aErro[nW][1]))

        RecLock("ZL8", .F.)

        If ::aErro[nW][2] == "SBF"

            ZL8->ZL8_LOGSBF := ::aErro[nW][3]

        ElseIf ::aErro[nW][2] == "SC0"

            ZL8->ZL8_LOGSC0 := ::aErro[nW][3]

        ElseIf ::aErro[nW][2] == "SC9"

            ZL8->ZL8_LOGSC9 := ::aErro[nW][3]

        Else

            ZL8->ZL8_LOG := ::aErro[nW][3]

        EndIf
        
        cEtiqueta	:= cValTochar(ZL8->ZL8_ETIQUE)
	    cProduto	:= ZL8->ZL8_PRODUT
	    cLote		:= ZL8->ZL8_LOTECT
	    cQuantidade	:= cValTochar(ZL8->ZL8_QUANT)
	    
        
        ZL8->ZL8_STATUS := ::aErro[nW][4]
        ZL8->ZL8_DOC 	:= ::aErro[nW][5]
        ZL8->(MSUnLock())
        
        ::ErroWorkflow(cEtiqueta, cProduto, cLote, cQuantidade, ::aErro[nW][3])
        
    Next nW
    
Return()

Method Workflow(cQrySC9, cQry) Class TIntegracaoMovimentoQuebra
	
	Local aArea	:= GetArea()
    Local cHtml := ""
    Local oMail := TAFMail():New()
    
    Local cAliasTemp	:= GetNextAlias()
	Local cQuery		:= ""
	
	Local cCliente		:= (cQrySC9)->A1_COD
	Local cLoja			:= (cQrySC9)->A1_LOJA
	Local cNome			:= (cQrySC9)->A1_NOME
	Local cVendedor		:= (cQrySC9)->C5_VEND1
	Local cMarca		:= ""
	Local cEst			:= ""
	Local cCat			:= ""	 
	Local cGrupo		:= ""
	Local cSeg			:= "" 
	
	Local nQtdReq 		:= cValToChar((cQry)->ZL8_QUANT)
    Local nQtdLib 		:= cValToChar(SC9->C9_QTDLIB)
	
	
	
	DbSelectArea('SC5')
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial('SC5')+(cQrySC9)->C9_PEDIDO))
	cMarca := SC5->C5_YEMP
	
	If (SC5->C5_CLIENTE == '010064')
		
		cQuery := "select * from SC5070 where C5_YPEDORI = '"+(cQrySC9)->C9_PEDIDO+"' AND C5_FILIAL = '"+xFilial('SC5')+"' AND D_E_L_E_T_ = ''"
		TcQuery cQuery New Alias (cAliasTemp)
		
		If (!(cAliasTemp)->(Eof()))
			cMarca 		:= (cAliasTemp)->C5_YEMP
			cCliente	:= (cAliasTemp)->C5_CLIENTE
			cLoja		:= (cAliasTemp)->C5_LOJACLI
			cVendedor	:= (cAliasTemp)->C5_VEND1
			
			DbSelectArea('SA1')
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial('SA1')+cCliente+cLoja))
			
			cNome 	:= SA1->A1_NOME	
			cEst	:= SA1->A1_EST
			cCat	:= SA1->A1_YCAT	 
			cGrupo	:= SA1->A1_GRPVEN
			cSeg	:= SA1->A1_YTPSEG  
							
		EndIf
		(cAliasTemp)->(DbCloseArea())
	Else
		
		DbSelectArea('SA1')
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial('SA1')+cCliente+cLoja))
		
		cNome 	:= SA1->A1_NOME	
		cEst	:= SA1->A1_EST
		cCat	:= SA1->A1_YCAT	 
		cGrupo	:= SA1->A1_GRPVEN
		cSeg	:= SA1->A1_YTPSEG 
				
	EndIf
	
	cAliasTemp	:= GetNextAlias()
	cQuery := "SELECT EMAILATEN FROM [dbo].[GET_ZKP] ('"+cSeg+"', '"+cMarca+"', '"+cEst+"', '"+cVendedor+"', '"+cCat+"', '"+cGrupo+"')"
	TcQuery cQuery New Alias (cAliasTemp)
	
	If (!(cAliasTemp)->(Eof()))
		::cEmail += (cAliasTemp)->EMAILATEN
	EndIf
	(cAliasTemp)->(DbCloseArea())	
	

    cHtml += '</tbody>'
    cHtml += '</table>'

    cHtml += '<style type="text/css">'
    cHtml += '.tg  {border-collapse:collapse;border-color:#aaa;border-spacing:0;}'
    cHtml += '.tg td{background-color:#fff;border-color:#aaa;border-style:solid;border-width:1px;color:#333;'
    cHtml += '  font-family:Arial, sans-serIf;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}'
    cHtml += '.tg th{background-color:#f38630;border-color:#aaa;border-style:solid;border-width:1px;color:#fff;'
    cHtml += '  font-family:Arial, sans-serIf;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}'
    cHtml += '.tg .tg-zw5y{border-color:inherit;text-align:center;text-decoration:underline;vertical-align:top}'
    cHtml += '.tg .tg-0lax{text-align:left;vertical-align:top}'
    cHtml += '</style>'

    cHtml += '<table class="tg" width="100%">'
    cHtml += '   <thead>'
    cHtml += '      <tr>'
    cHtml += '         <th class="tg-zw5y" colspan="3" style="width: 99.8856%;">'
    cHtml += '            <div style="text-align: center;">' + cEmpAnt + cFilAnt + ' - PROCESSO QUEBRA</div>'
    cHtml += '         </th>'
    cHtml += '      </tr>'
    cHtml += '   </thead>'
    cHtml += '   <tbody>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Cliente</strong></td>'
    cHtml += '         <td colspan="2">' + cCliente + "-" + cLoja + "-" + cNome + '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Pedido</strong></td>'
    cHtml += '         <td colspan="2">' + (cQrySC9)->C9_PEDIDO + '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Item</strong></td>'
    cHtml += '         <td colspan="2">' + (cQrySC9)->C9_ITEM + '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Produto</strong></td>'
    cHtml += '         <td colspan="2">' + (cQrySC9)->C9_PRODUTO + '</td>'
    cHtml += '      </tr>'
    
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Qtd. Liberação</strong></td>'
    cHtml += '         <td colspan="2">' + nQtdLib + '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Qtd. Requerida</strong></td>'
    cHtml += '         <td colspan="2">' + nQtdReq + '</td>'
    cHtml += '      </tr>'
    
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Processo</strong></td>'
    cHtml += '         <td colspan="2">Quebra</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Observa&ccedil;&atilde;o</strong></td>'
    cHtml += '         <td colspan="2">Consulte o estoque do pedido</td>'
    cHtml += '      </tr>'
    cHtml += '   </tbody>'
    cHtml += '</table>'

    oMail:cTo := ::cEmail
    oMail:cSubject := "Integracao Movimento Quebra - Informativo"
    oMail:cBody := cHtml

    oMail:Send()
    
    RestArea(aArea)
Return()


Method ErroWorkflow(cEtiqueta, cProduto, cLote, cQuantidade, cErro) Class TIntegracaoMovimentoQuebra
	
	Local aArea	:= GetArea()
    Local cHtml := ""
    Local oMail := TAFMail():New()
    
    cHtml += '</tbody>'
    cHtml += '</table>'

    cHtml += '<style type="text/css">'
    cHtml += '.tg  {border-collapse:collapse;border-color:#aaa;border-spacing:0;}'
    cHtml += '.tg td{background-color:#fff;border-color:#aaa;border-style:solid;border-width:1px;color:#333;'
    cHtml += '  font-family:Arial, sans-serIf;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}'
    cHtml += '.tg th{background-color:#f38630;border-color:#aaa;border-style:solid;border-width:1px;color:#fff;'
    cHtml += '  font-family:Arial, sans-serIf;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}'
    cHtml += '.tg .tg-zw5y{border-color:inherit;text-align:center;text-decoration:underline;vertical-align:top}'
    cHtml += '.tg .tg-0lax{text-align:left;vertical-align:top}'
    cHtml += '</style>'

    cHtml += '<table class="tg" width="100%">'
    cHtml += '   <thead>'
    cHtml += '      <tr>'
    cHtml += '         <th class="tg-zw5y" colspan="3" style="width: 99.8856%;">'
    cHtml += '            <div style="text-align: center;">ERRO - PROCESSO QUEBRA</div>'
    cHtml += '         </th>'
    cHtml += '      </tr>'
    cHtml += '   </thead>'
    cHtml += '   <tbody>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Etiqueta</strong></td>'
    cHtml += '         <td colspan="2">' + cEtiqueta + '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Produto</strong></td>'
    cHtml += '         <td colspan="2">' + cProduto + '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Item</strong></td>'
    cHtml += '         <td colspan="2">' + cLote + '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Quantidade</strong></td>'
    cHtml += '         <td colspan="2">' + cQuantidade + '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Erro</strong></td>'
    cHtml += '         <td colspan="2">' + cErro + '</td>'
    cHtml += '      </tr>'
    cHtml += '   </tbody>'
    cHtml += '</table>'

    oMail:cTo := U_EmailWF('EINMOVQB', cEmpAnt)
    
    Conout(oMail:cTo)
    oMail:cSubject := "Erro ao baixar registro - Integracao Movimento Quebra"
    oMail:cBody := cHtml

    oMail:Send()
    
    RestArea(aArea)
Return()