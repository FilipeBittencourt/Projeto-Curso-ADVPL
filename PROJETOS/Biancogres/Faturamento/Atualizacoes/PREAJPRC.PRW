#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} TPedidoVendaReajustePreco
@description Rotinas para reajuste de preço de venda de pedidos de venda
@author Fernando Rocha
@since 01/09/2020
@version 1.0
@type function
/*/
Class TPedidoVendaReajustePreco From LongClassName

    Data cTabAtu
    Data aEmpsOri

    Method New() Constructor
    Method ShowReajuste()
    Method GetTabAtual()
    Method GetPrecoAtual()
    Method ValidaItem(_nAT, lShow)
    Method GravaLogTok()
    Method AltPrcOrigem()
    Method GetPrcOrigem(_nPrcLM)
    Method CheckLibAgreg()

EndClass


Method New() Class TPedidoVendaReajustePreco

    ::cTabAtu := ""
    ::aEmpsOri := {}

Return


Method ShowReajuste() Class TPedidoVendaReajustePreco

    If (SC5->C5_CLIENTE == "010064")

        MsgAlert("PEDIDO LM => O Reajuste de preço deve ser feito no pedido da LM para o cliente final.","REAJUSTE DE PREÇO")
        Return

    EndIf

    If !(Alltrim(SC5->C5_YSUBTP) $ "N#E#")

        MsgAlert("TIPO DE PEDIDO => Não pode fazer reajuste de preço neste pedido.","REAJUSTE DE PREÇO")
        Return

    EndIf

    If (U_fValidaRA(SC5->C5_CONDPAG))

        MsgAlert("RECEBIMENTO ANTECIPADO => Não pode fazer reajuste de preço neste pedido.","REAJUSTE DE PREÇO")
        Return

    EndIf

    A410Altera("SC5", SC5->(RecNo()), 4)

Return

Method GetTabAtual() Class TPedidoVendaReajustePreco

    Local cTab
    Local aArea := GetArea()

    cTab    := U_BIA827()

    ::cTabAtu := cTab

    RestArea(aArea)

Return

Method GetPrecoAtual(_nAT) Class TPedidoVendaReajustePreco

    Local aArea         := GetArea()
    Local aArea1        := SA1->(GetArea())
    Local aArea2        := SC6->(GetArea())
    Local aArea3        := SB1->(GetArea())

    Local nPosProd	    := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRODUTO'})
    Local nPosTes		:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_TES'})
    Local nPosEmpPed	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YEMPPED'})

    Local nPosOldPr	    := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YPRCTAB'})
    Local nPosNewPr	    := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YPRTBAT'})
    Local nPosDfTab	    := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YDIFTAB'})

    Local wProduto	:= aCols[_nAT,nPosProd]
    Local cTES		:= aCols[_nAT,nPosTes]
    Local wEmpPed	:= aCols[_nAT,nPosEmpPed]
    Local aImp

    Local nOldPrc
    Local nNewPreco
    Local nPerc
    Local wC5YMAXCND

    If !::ValidaItem(_nAT)
        Return
    EndIf

    aImp    := U_fItImpos(_nAT,{"IT_ALIQICM","IT_ALIQCMP","IT_ALFCCMP"}) //Icms Origem / Icms Destino / Aliq. Fundo Pobreza

    nNewPreco	:= U_fBuscaPreco(M->C5_YLINHA,::cTabAtu,wProduto,Dtos(dDataBase),M->C5_CLIENTE,M->C5_LOJACLI,M->C5_YSUBTP,aImp[1],aImp[2],aImp[3],cTES,,M->C5_TRANSP, wEmpPed)

    //Multiplica preco da tabela * fator financeiro
    wC5YMAXCND := M->C5_YMAXCND
    If wC5YMAXCND > 0
        nNewPreco := nNewPreco * wC5YMAXCND
    EndIf

    //Diferença entre Tabelas
    nOldPrc := aCols[_nAT,nPosOldPr]
    nPerc := ((nNewPreco/nOldPrc)-1)*100

    ACOLS[_nAT][nPosNewPr] := nNewPreco
    ACOLS[_nAT][nPosDfTab] := nPerc

    RestArea(aArea)
    RestArea(aArea1)
    RestArea(aArea2)
    RestArea(aArea3)

Return


Method ValidaItem(_nAT, lShow) Class TPedidoVendaReajustePreco

    Local nPosItem	    := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_ITEM'})
    Local nPosReajOk    := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YREAJOK'})

    Local nQtdEnt
    Local cBlq
    Local cTES
    Local aAreaC6 := SC6->(GetArea())
    Local aAreaF4 := SF4->(GetArea())
    Local lRet := .T.

    Default lShow := .F.

    SC6->(DbSetOrder(1))
    If SC6->(DbSeek(XFilial("SC6")+M->C5_NUM+aCols[_nAT,nPosItem]))

        nQtdEnt	:= SC6->C6_QTDENT
        cBlq  	:= SC6->C6_BLQ
        cTES  	:= SC6->C6_TES

        If (lRet .And. nQtdEnt > 0)

            if (lShow)
                MsgAlert("Item já faturado - não pode reajustar preço", "REAJUSTE DE PREÇO")
            endif

            lRet := .F.

        EndIf

        If (lRet .And. cBlq == "R")

            if (lShow)
                MsgAlert("Item eliminado resíduo - não pode reajustar preço", "REAJUSTE DE PREÇO")
            endif

            lRet := .F.

        EndIf

        SF4->(DbSetOrder(1))
        If lRet .And. SF4->(DbSeek(XFilial("SF4")+cTES)) .And. SF4->F4_DUPLIC <> "S"

            if (lShow)
                MsgAlert("TES não gera financeiro - não pode reajustar preço", "REAJUSTE DE PREÇO")
            endif

            lRet := .F.

        EndIf

        If (!::CheckLibAgreg())
            If (lShow)
                MsgAlert("O Produto/Lote/Item "+SC6->C6_PRODUTO+'/'+SC6->C6_LOTECTL+'/'+SC6->C6_ITEM+" do pedido origem já esta em carga.", "REAJUSTE DE PREÇO")
            Endif

            lRet := .F.

        EndIf

    EndIf

    RestArea(aAreaC6)
    RestArea(aAreaF4)

    If ( lRet .And. lShow )

        aCols[_nAT,nPosReajOk] := "S"

    EndIf

Return(lRet)


Method CheckLibAgreg() Class TPedidoVendaReajustePreco
    Local _lOk		:= .T.

    Local _cEmpOri	:= IIF(Empty(SC5->C5_YEMPPED), cEmpAnt, SC5->C5_YEMPPED)
    Local _cPedOri	:= IIF(Empty(SC5->C5_YPEDORI), SC5->C5_NUM, SC5->C5_YPEDORI)
    Local _cItem	:= SC6->C6_ITEM
    Local _cSC9Ori	:= "% SC9"+SubString(_cEmpOri,1,2)+"0 %"
    Local cAliasEmp := GetNextAlias()

    BeginSql Alias cAliasEmp

        Select * From %Exp:_cSC9Ori% 
        Where 
        C9_FILIAL 		= %xFilial:SC9%
        AND C9_PEDIDO 	= %Exp:_cPedOri%  
        AND C9_ITEM  	= %Exp:_cItem%        
        
        AND %NotDel%

    EndSql

    While !(cAliasEmp)->(Eof())
        If (!Empty((cAliasEmp)->C9_AGREG))
            _lOk := .F.
        EndIf
        (cAliasEmp)->(DbSkip())
    EndDo
    (cAliasEmp)->(DbCloseArea())


Return  _lOk

Method AltPrcOrigem(cNumPed) Class TPedidoVendaReajustePreco

    Local aCabPV
    Local aItemPV
    Local cAliasTmp
    Local cAliasIOri
    Local cAliasEmp
    Local _nRetPrc
    Local cEmpOri
    Local cPedOri
    Local cSC6Ori
    Local cSC9Ori
    Local aAux
    Local aAuxEmp
    Local cSQLFields := ""
    Local aSQLFields := {}
    Local nX

    cEmpOri := SC5->C5_YEMPPED
    cPedOri := SC5->C5_YPEDORI

    aCabPV:={}
    aItemPV := {}

    cSC6Ori := "% SC6"+SubString(cEmpOri,1,2)+"0 %"
    cSC9Ori := "% SC9"+SubString(cEmpOri,1,2)+"0 %"

    ::aEmpsOri := {}


    //Buscando Empenhos do pedido origem para armazenar e refazer apos alteracao do pedido
    cAliasEmp := GetNextAlias()
    BeginSql Alias cAliasEmp

        select C9_ITEM, C9_QTDLIB, C9_LOTECTL, C9_DATALIB from %Exp:cSC9Ori% 
        where C9_PEDIDO = %Exp:cPedOri%        
        and C9_BLEST = '  '
        and C9_BLCRED = '  '
        and %NotDel%

    EndSql

    (cAliasEmp)->(DbGoTop())
    While !(cAliasEmp)->(Eof())

        aAuxEmp := {}
        AAdd(aAuxEmp, cPedOri )
        AAdd(aAuxEmp, (cAliasEmp)->C9_ITEM )
        AAdd(aAuxEmp, (cAliasEmp)->C9_QTDLIB )
        AAdd(aAuxEmp, (cAliasEmp)->C9_LOTECTL )
        AAdd(aAuxEmp, STOD((cAliasEmp)->C9_DATALIB) )

        AAdd(::aEmpsOri, aAuxEmp)

        (cAliasEmp)->(DbSkip())
    EndDo
    (cAliasEmp)->(DbCloseArea())

    //Preparando vetores para alteracao do pedido origem
    aAdd(aCabPV,  {"C5_NUM", cPedOri, Nil}) // Numero do pedido



    //Campos Customizados do SC6 na origem - o execauto está limpando todos eles
    SX3->(DbSetOrder(1))
    SX3->(DbSeek("SC6"))
    While !SX3->(eof()) .And. SX3->X3_ARQUIVO == "SC6"
        If  X3USO(SX3->X3_USADO) .And. SX3->X3_TIPO <> "M" .And. SX3->X3_CONTEXT <> "V" .And. SX3->X3_PROPRI == "U"

            cSQLFields += IIF(!Empty(cSQLFields),", ","")
            cSQLFields += AllTrim(SX3->X3_CAMPO)
            aAdd(aSQLFields,AllTrim(SX3->X3_CAMPO))

        EndIf
        SX3->(DbSkip())
    EndDo




    //Buscando campos obrigatorios que tem que ser exatamente igual o original
    cSQLFields := "% "+cSQLFields+" %"
    cAliasIOri := GetNextAlias()
    BeginSql Alias cAliasIOri
        %NOPARSER%

        select C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_PRCVEN, C6_PRUNIT, C6_TES, C6_ENTREG, C6_BLQ, %EXP:cSQLFields%
        from %Exp:cSC6Ori% where C6_NUM = %Exp:cPedOri% and %NotDel% order by 1

    EndSql

    (cAliasIOri)->(DbGoTop())
    While !(cAliasIOri)->(Eof())

        cAliasTmp := GetNextAlias()
        BeginSql Alias cAliasTmp

            select ZM9_ITEM, ZM9_PRCNEW from %Table:ZM9% where R_E_C_N_O_ in 
            (select REC from (select ZM9_ITEM, REC = MAX(R_E_C_N_O_) from %Table:ZM9% where ZM9_FILIAL = %XFilial:ZM9% and ZM9_PEDIDO = %Exp:cNumPed% and ZM9_REPLIC <> 'S' and D_E_L_E_T_ = '' group by ZM9_ITEM) tab)
            and ZM9_ITEM = %Exp:(cAliasIOri)->C6_ITEM%
            order by ZM9_ITEM

        EndSql

        (cAliasTmp)->(DbGoTop())
        If !(cAliasTmp)->(Eof())

            //Calculando preço da Origem/Fabrica para montar vetor para execauto de alteracao
            _nRetPrc := ::GetPrcOrigem((cAliasTmp)->ZM9_PRCNEW)

            aAux := {}
            aadd(aAux,{"AUTDELETA","N",Nil})
            aAdd(aAux,{"C6_NUM"		,cPedOri								,Nil})
            aAdd(aAux,{"C6_ITEM"	,(cAliasIOri)->C6_ITEM					,Nil})
            aAdd(aAux,{"C6_PRODUTO"	,(cAliasIOri)->C6_PRODUTO				,Nil})
            aAdd(aAux,{"C6_QTDVEN"	,(cAliasIOri)->C6_QTDVEN				,Nil})
            aAdd(aAux,{"C6_PRCVEN"	,_nRetPrc	                        	,Nil})
            aAdd(aAux,{"C6_PRUNIT"	,_nRetPrc	                        	,Nil})
            aAdd(aAux,{"C6_TES"	    ,(cAliasIOri)->C6_TES				    ,Nil})
            aAdd(aAux,{"C6_ENTREG"  ,STOD((cAliasIOri)->C6_ENTREG)		    ,Nil})

        Else

            aAux := {}
            aadd(aAux,{"AUTDELETA","N",Nil})
            aAdd(aAux,{"C6_NUM"		,cPedOri								,Nil})
            aAdd(aAux,{"C6_ITEM"	,(cAliasIOri)->C6_ITEM					,Nil})
            aAdd(aAux,{"C6_PRODUTO"	,(cAliasIOri)->C6_PRODUTO				,Nil})
            aAdd(aAux,{"C6_QTDVEN"	,(cAliasIOri)->C6_QTDVEN				,Nil})
            aAdd(aAux,{"C6_PRCVEN"	,(cAliasIOri)->C6_PRCVEN               	,Nil})
            aAdd(aAux,{"C6_PRUNIT"	,(cAliasIOri)->C6_PRUNIT               	,Nil})
            aAdd(aAux,{"C6_TES"	    ,(cAliasIOri)->C6_TES				    ,Nil})
            aAdd(aAux,{"C6_ENTREG"  ,STOD((cAliasIOri)->C6_ENTREG)		    ,Nil})

            If !Empty((cAliasIOri)->C6_BLQ)
                aAdd(aAux,{"C6_BLQ"	    ,(cAliasIOri)->C6_BLQ			        ,Nil})
            EndIf

        EndIf

        For nX := 1 To Len(aSQLFields)

            If !EMPTY( &("(cAliasIOri)->"+AllTrim(aSQLFields[nX])) )

                SX3->(DbSetOrder(1))
                If SX3->(DbSeek("SC6"+aSQLFields[nX])) .And. SX3->X3_TIPO == "D"

                    aAdd(aAux,{AllTrim(aSQLFields[nX])  ,STOD(&("(cAliasIOri)->"+AllTrim(aSQLFields[nX])))   ,Nil})

                Else

                    aAdd(aAux,{AllTrim(aSQLFields[nX])  ,&("(cAliasIOri)->"+AllTrim(aSQLFields[nX]))   ,Nil})

                EndIf

            EndIf

        Next nX

        Aadd(aItemPV,AClone(aAux))

        (cAliasTmp)->(DbCloseArea())

        (cAliasIOri)->(DbSkip())
    EndDo
    (cAliasIOri)->(DbCloseArea())


Return({aCabPV, aItemPV, ::aEmpsOri})


Method GravaLogTok() Class TPedidoVendaReajustePreco

    Local I
    Local  _cProd
    Local  _cItem
    Local  _nTabNew := 0
    Local  _nPrcNew := 0
    Local  _nPerc   := 0
    Local  _nTabOld := 0
    Local  _nPrcOld := 0
    Local cAliasEmp
    Local aAuxEmp

    Public __REAJEMPSORI


    //Buscando Empenhos no pedido alterado e armazenar para refazer depois da gravacao - Empresa 01
    ::aEmpsOri := {}

    IF AllTrim(CEMPANT) <> "07"

        cAliasEmp := GetNextAlias()
        BeginSql Alias cAliasEmp

        select C9_ITEM, C9_QTDLIB, C9_LOTECTL, C9_DATALIB from %Table:SC9% 
        where C9_PEDIDO = %Exp:M->C5_NUM%
        and C9_BLEST = '  '
        and C9_BLCRED = '  '
        and %NotDel%

        EndSql

        (cAliasEmp)->(DbGoTop())
        While !(cAliasEmp)->(Eof())

            aAuxEmp := {}
            AAdd(aAuxEmp, M->C5_NUM )
            AAdd(aAuxEmp, (cAliasEmp)->C9_ITEM )
            AAdd(aAuxEmp, (cAliasEmp)->C9_QTDLIB )
            AAdd(aAuxEmp, (cAliasEmp)->C9_LOTECTL )
            AAdd(aAuxEmp, STOD((cAliasEmp)->C9_DATALIB) )

            AAdd(::aEmpsOri, aAuxEmp)

            (cAliasEmp)->(DbSkip())
        EndDo
        (cAliasEmp)->(DbCloseArea())

    ENDIF

    //Gravando Log de alteracao de preço
    For I := 1 To Len(aCols)

        If !aCols[I][Len(aHeader)+1]

            _cOk    := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YREAJOK"})]

            If ( _cOk == "S" )

                _cProd 	    := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
                _cItem 	    := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})]
                _nTabNew    := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YPRTBAT"})]
                _nPrcNew    := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})]
                _nPerc      := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YPREAJU"})]

                SC6->(DbSetOrder(1))
                If SC6->(DbSeek(XFilial("SC6")+M->C5_NUM+_cItem))

                    _nTabOld := SC6->C6_YPRCTAB
                    _nPrcOld := SC6->C6_PRCVEN

                EndIf

                RecLock("ZM9",.T.)

                ZM9->ZM9_FILIAL     := XFilial("ZM9")
                ZM9->ZM9_PEDIDO     := M->C5_NUM
                ZM9->ZM9_ITEM       := _cItem
                ZM9->ZM9_PRODUTO    := _cProd
                ZM9->ZM9_TABOLD     := _nTabOld
                ZM9->ZM9_TABNEW     := _nTabNew
                ZM9->ZM9_PRCOLD     := _nPrcOld
                ZM9->ZM9_PRCNEW     := _nPrcNew
                ZM9->ZM9_PERC       := _nPerc
                ZM9->ZM9_REPLIC     := "N"

                ZM9->ZM9_USER := CUSERNAME
                ZM9->ZM9_DATA := dDataBase
                ZM9->ZM9_HORA := Time()

                ZM9->(MsUnlock())

            EndIf

        EndIf

    Next I

    __REAJEMPSORI := AClone(::aEmpsOri)

Return


Method GetPrcOrigem(_nPrcLM) Class TPedidoVendaReajustePreco

    //Programa Transcrito da Replicao LM -> considerando somente produtos normais com fator redutor
    Local _nC6_YFATRED
    Local _nC6_YPRCNEW

    _nC6_YFATRED	:= U_LMFatRed(SM0->M0_ESTCOB)
    _nC6_YPRCNEW	:= Round(_nPrcLM * _nC6_YFATRED, 2)

Return(_nC6_YPRCNEW)


User Function M410RPRC()

    Local oObj := TPedidoVendaReajustePreco():New()
    oObj:ShowReajuste()

Return Nil


User Function PREAVL01()

    Local oObj := TPedidoVendaReajustePreco():New()
    Local lRet
    lRet := oObj:ValidaItem(N,.T.)

Return lRet


User Function REAJREPL(cPedido, lJob)

    Local aArea
    Local aRet
    Local cEmpDest := ""
    Local bProcessa
    Local cPedOri	:= ""
    Local lOk := .T.
    Local cErro := ""

    Default lJob := .F.

    aArea := GetArea()

    SC5->(DbSetOrder(1))
    If SC5->(DbSeek(XFilial("SC5")+cPedido))

        cPedOri := SC5->C5_YPEDORI

        SC6->(DbSetOrder(1))
        If SC6->(DbSeek(XFilial("SC6")+cPedido))

            If !Empty(SC6->C6_YEMPPED)

                cEmpDest := SC6->C6_YEMPPED+"01"

            Else

                SB1->(DbSetOrder(1))
                IF SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO))

                    cEmpDest := SB1->B1_YEMPEST

                ENDIF

            EndIf
        EndIf

        If !Empty(cEmpDest)

            _oObj := TPedidoVendaReajustePreco():New()
            _aData := _oObj:AltPrcOrigem(cPedido)

            //Execucao via JOB em outra empresa do EXECAUTO da replicacao do pedido LM
            bProcessa := {|| aRet := U_FROPCPRO(SubStr(cEmpDest,1,2),SubStr(cEmpDest,3,2),"U_REAJRXPR", _aData, cPedido)  }

            If !lJob
                U_BIAMsgRun("Aguarde... Replicando REAJUSTE para EMPRESA: "+cEmpDest,,bProcessa)
            Else
                eval(bProcessa)
            EndIf

            If ValType(aRet) == "A"

                lOk := aRet[1]
                cErro := aRet[2]

                If !lJob
                    If !lOk
                        U_FROPMSG("REAJUSTE DE PREÇO", "Informe a TI erro com o REAJUSTE DE PREÇO na empresa de fabricação: "+cEmpDest+CRLF+CRLF+cErro,,,"ERRO na replicação do REAJUSTE DE PREÇO: "+cPedido)
                    Else
                        U_FROPMSG("REAJUSTE DE PREÇO", "Finalizado com Sucesso, REAJUSTE DE PREÇO DO PEDIDO: "+cPedOri+" na empresa: "+SubStr(cEmpDest,1,2),,,"REAJUSTE DE PREÇO LM - "+cPedido)
                    EndIf
                EndIf

            Else

                U_FROPMSG("REAJUSTE DE PREÇO", "Informe a TI erro desconhecido com o REAJUSTE DE PREÇO na empresa de fabricação: "+cEmpDest,,,"ERRO na replicação do REAJUSTE DE PREÇO: "+cPedido)

            EndIf

        Else
            If !lJob
                U_FROPMSG("REAJUSTE DE PREÇO", "EMPRESA PARA REPLICAÇÃO NÃO CONFIGURADA - ENTRAR EM CONTATO COM O COMERCIAL!",,,"ERRO na replicação do  REAJUSTE DE PREÇO -> Pedido: "+cPedido)
            EndIf
        EndIf

    EndIf

    RestArea(aArea)

Return(lOk)


User Function REAJRXPR(_aData, _cPedLM)

    Local aCabPv    := _aData[1]
    Local aItemPV   := _aData[2]
    Local aEmps     := _aData[3]
    Local nX
    Local _aRetEmp
    Local CSQL

    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.

    Public __RJDTEPORI  := Nil

    BEGIN TRANSACTION

        MsExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,4)

        If lMsErroAuto

            DisarmTransaction()

            //Grava log de erro para consulta posterior
            aAutoErro := GETAUTOGRLOG()
            _cLogTxt := XCONVERRLOG(aAutoErro)
            return({.F.,_cLogTxt})

        Else

            //Marcar status do log de replicação
            CSQL := "update ZM9070 set ZM9_REPLIC = 'S' where ZM9_FILIAL = '01' and ZM9_PEDIDO = '"+_cPedLM+"' and ZM9_REPLIC <> 'S' and D_E_L_E_T_ = ''"
            TCSQLEXEC(CSQL)

            //Refazer Empenhos do Pedido Origem
            For nX := 1 To Len(aEmps)

                __RJDTEPORI := aEmps[nX][5]

                _aRetEmp := EmpenharItem(aEmps[nX][1], aEmps[nX][2], aEmps[nX][3], aEmps[nX][4])

                __RJDTEPORI := Nil

                If !_aRetEmp[1]

                    DisarmTransaction()

                    _cLogTxt := _aRetEmp[2]
                    return({.F.,_cLogTxt})

                EndIf

            Next nX

        EndIf

    END TRANSACTION

return({.T., ""})


STATIC FUNCTION XCONVERRLOG(aAutoErro)
    LOCAL cRet := ""
    LOCAL nX := 1
    FOR nX := 1 to Len(aAutoErro)
        cRet += aAutoErro[nX]+CRLF
    NEXT nX
RETURN cRet


Static Function EmpenharItem(_cPedido, _cItem, _nQtde, _cLote)

    Local lCredito 	:= .T.
    Local lEstoque	:= .T.
    Local lAvalCred := .F.
    Local _QtdALib2
    Local _QtdLib
    Local aAreaC6 := SC6->(GetArea())
    Local aAreaC5 := SC5->(GetArea())

    SC5->(DbSetOrder(1))
    SC6->(DbSetOrder(1))
    If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItem))

        If SC5->(DbSeek(XFilial("SC5")+_cPedido)) .And. SC5->C5_LIBEROK <> "S"

            RecLock("SC5",.F.)
            SC5->C5_LIBEROK := "S"
            SC5->(MsUnlock())

        EndIf

        If !Empty(_cLote)
            RecLock("SC6",.F.)
            SC6->C6_LOTECTL := _cLote
            SC6->(MsUnlock())
        EndIf

        _QtdALib2   := ConvUM(SC6->C6_PRODUTO, _nQtde, 0, 2)

        _QtdLib	    := MaLibDoFat(SC6->(RecNo()),_nQtde,@lCredito,@lEstoque,lAvalCred,.T.,.F.,.F.,NIL,NIL,NIL,NIL,NIL,NIL,_QtdALib2)

        If ( _QtdLib <> _nQtde .Or. !lEstoque )

            Return {.F.,"Erro na liberação de estoque, verificar estoque e empenhos."}

        EndIf

    Else

        Return {.F.,"Item Nao Encontrado"}

    EndIf

    RestArea(aAreaC6)
    RestArea(aAreaC5)

Return {.T.,""}


User Function RECXEMPS()

    Local bProcessa := {|| XEMPSPRC()  }

    Public __RJDTEPORI  := Nil

    U_BIAMsgRun("Aguarde... Refazendo Empenhos",,bProcessa)

Return

Static Function XEMPSPRC()

    Local nX
    Local aEmps

    If Type("__REAJEMPSORI") <> "U" .And. !Empty(__REAJEMPSORI)

        aEmps := __REAJEMPSORI

        For nX := 1 To Len(aEmps)

            __RJDTEPORI := aEmps[nX][5]

            _aRetEmp := EmpenharItem(aEmps[nX][1], aEmps[nX][2], aEmps[nX][3], aEmps[nX][4])

            __RJDTEPORI := Nil

            If !_aRetEmp[1]

                _cLogTxt := _aRetEmp[2]
                U_FROPMSG("ATENÇÃO!!!!  REAJUSTE DE PREÇO", "Ocorreu erro ao tentar refazer empenhos deste pedido: "+CRLF+CRLF+_cLogTxt,,,"ERRO na replicação do REAJUSTE DE PREÇO")

            EndIf

        Next nX

    EndIf

Return


