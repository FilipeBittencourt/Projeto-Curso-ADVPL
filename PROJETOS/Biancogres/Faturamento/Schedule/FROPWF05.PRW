#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} FROPWF05
//TODO Descrição auto-gerada.
@author Fernando
@since 10/10/2020
@version 1.0
/*/

User Function FROPWF05()

    Local aArea  := GetArea()
    Local xv_Emps    := U_BAGtEmpr("01_07")
    Local nI

    If (Upper(AllTrim(getenvserver())) == "SCHEDULE")
        lManual := .F.
    Else
        lManual := .T.
    EndIf

    Conout("FROPWF05 Inicio")

    For nI := 1 to Len(xv_Emps)
        //Inicializa o ambiente
        RPCSetType(3)
        WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])

        Processa({ || ProcDados() },"Aguarde...","Processando as informações para envio do e-mail...",.F.)

        RpcClearEnv()
    Next nI

    Conout("FROPWF05 Fim")

    RestArea(aArea)
Return


Static Function ProcDados()

    Local cAliasReps
    Local cAliasTrab
    Local cQryReps      
    Local cQuery
    Local cHtml			:= ""
    Local cMailRep      := ""
    Local cMailAte      := ""
    Local cMailGer      := ""
    Local dDataEnv

    //Data de processamento
    If DOW(dDataBase) == 2
        dDataEnv := dDataBase-3
    Else
        dDataEnv := dDataBase-1
    EndIf

    //Loop - Diferentes Representantes
    cQryReps      := MQryReps(dDataEnv)

    cAliasReps	:= GetNextAlias()
    TCQuery cQryReps New Alias cAliasReps
    While !cAliasReps->(EoF())

        cHtml := ""
        cHtml := GetHeader()
        cHtml += GetMsgBody(cAliasReps->REP)
        cHtml += GetOTable()

        cQuery		:= MontaQuery(cAliasReps->REP, dDataEnv)
        cAliasTrab	:= GetNextAlias()
        TCQuery cQuery New Alias cAliasTrab

        If !cAliasTrab->(EoF())

            cMailRep    := cAliasTrab->A3_EMAIL
            cMailAte    := U_FMAILATE(cAliasTrab->C5_NUM)
            cMailGer    := U_FMAILGER(cAliasTrab->C5_NUM)

            While !cAliasTrab->(EoF())

                cHtml += GetRow()

                cAliasTrab->(DbSkip())
            EndDo

            cAliasTrab->(DbCloseArea())

            cHtml += GetCTable()
            cHtml += GetFooter()

            //enviar e-mail
            SendMail(cHtml, cMailRep, cMailAte, cMailGer)

        EndIf

        cAliasReps->(DbSkip())
    EndDo
    cAliasReps->(DbCloseArea())

Return


Static Function GetHeader()

    Local cHtml := ""

    cHtml := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    cHtml += '   <html xmlns="http://www.w3.org/1999/xhtml">
    cHtml += '      <head>
    cHtml += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    cHtml += '         <title>cabtitpag</title>
    cHtml += '         <style type="text/css">
    cHtml += '			<!--
    cHtml += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
    cHtml += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
    cHtml += '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
    cHtml += '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
    cHtml += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
    cHtml += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
    cHtml += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
    cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
    cHtml += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }
    cHtml += '			-->
    cHtml += '         </style>
    cHtml += '      </head>
    cHtml += '      <body>

Return cHtml

Static Function GetFooter()

    Local cHtml := ""

    cHtml := "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>"
    cHtml += "          <tr>"
    cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FROPWF05).</th>"
    cHtml += "			</tr>"
    cHtml += "		</table>"
    cHtml += "      </body>"
    cHtml += "   </html>"
    cHtml += "   </html>"

Return cHtml

Static Function GetMsgBody(cCodRep)
    Local cHtml := ""

    SA3->(DbSetOrder(1))
    SA3->(DbSeek(XFilial("SA3")+cCodRep))

    cHtml := '<p><div class = "headTexto1">Sr. Representante '+AllTrim(SA3->A3_NREDUZ)+', seguem reajustes de preços efetuados em: '+DTOC(dDataBase-1)+'</div></p>'
    cHtml += '<br/>'

Return cHtml

Static Function GetOTable()

    Local cHtml := ""

    cHtml := '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
    cHtml += '            <tr align=center>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Cliente </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Nome </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Pedido </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Dt.Emissão </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Dt.Reajuste </th>'
    cHtml += '               <th class = "cabtab" width="10" scope="col"> Item </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Produto </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Descrição </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Qtde </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Preço Ant. </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> Preço Novo </th>'
    cHtml += '               <th class = "cabtab" width="20" scope="col"> % Reajuste </th>'
    cHtml += '               <th class = "cabtab" width="10" scope="col"> Ordem Compra </th>'
    cHtml += '            </tr>

Return cHtml

Static Function GetCTable()
    Local cHtml := ""

    cHtml += '</table>'
Return cHtml

Static Function GetRow()

    Local cHtml 		:= ""

    cHtml := " 			<tr align=center>
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->A1_COD +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->A1_NOME +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->C5_NUM +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ DTOC(STOD(cAliasTrab->C5_EMISSAO)) +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ DTOC(STOD(cAliasTrab->ZM9_DATA)) +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->ZM9_ITEM +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->B1_COD +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->B1_DESC +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->C6_QTDVEN,"@E 999,999.99") +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->ZM9_PRCOLD,"@E 999,999.99") +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->ZM9_PRCNEW,"@E 999,999.99") +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->ZM9_PERC,"@E 999.99") +"</td>"
    cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->C5_YPC +"</td>"
    cHtml += "          </tr>"

Return cHtml

Static Function SendMail(cHtml, cMailRep, cMailAte, cMailGer)

    Local _lRet  		:= .F.
    Local _cTo 			:= ""
    Local _cSubject		:= ""
    Local _cBody 		:= ""
    Local _cCC 			:= cMailAte
    Local _CCO

    _cSubject := "Pedidos com reajuste de preço efetuados"

    _cTo := cMailRep

    _CCO := "claudeir.fadini@biancogres.com.br;ranisses.corona@biancogres.com.br"

    If !Empty(_cCC) .And. !Empty(cMailGer)
        _cCC := _cCC + ";"+cMailGer
    EndIf

    _cBody := cHtml

    Conout("FROPWF03 Enviando e-mail para: "+_cTo)
    _lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC, _CCO)

Return(_lRet)


Static Function MQryReps(dDataEnv)

    Local cQuery	:= ""

    cQuery += " select "+CRLF
    cQuery += " distinct REP = C5_VEND1 "+CRLF
    cQuery += " from "+RetSqlName("ZM9")+" ZM9 (nolock) "+CRLF
    cQuery += " join "+RetSqlName("SC5")+" SC5 (nolock) on C5_FILIAL = ZM9_FILIAL and C5_NUM = ZM9_PEDIDO "+CRLF
    cQuery += " where "+CRLF
    cQuery += " ZM9_DATA = '"+DTOS(dDataEnv)+"' "+CRLF
    cQuery += " and ZM9.D_E_L_E_T_ = '' "+CRLF
    cQuery += " and SC5.D_E_L_E_T_ = '' "+CRLF

Return cQuery


Static Function MontaQuery(_cCodRep, dDataEnv)

    Local cQuery	:= ""

    cQuery += " select "+CRLF
    cQuery += " A3_COD, "+CRLF
    cQuery += " A3_EMAIL, "+CRLF
    cQuery += " A1_COD, "+CRLF
    cQuery += " A1_NOME, "+CRLF
    cQuery += " C5_NUM, "+CRLF
    cQuery += " C5_EMISSAO, "+CRLF
    cQuery += " ZM9_DATA, "+CRLF
    cQuery += " ZM9_ITEM, "+CRLF
    cQuery += " B1_COD, "+CRLF
    cQuery += " B1_DESC, "+CRLF
    cQuery += " C6_QTDVEN, "+CRLF
    cQuery += " ZM9_PRCOLD, "+CRLF
    cQuery += " ZM9_PRCNEW, "+CRLF
    cQuery += " ZM9_PERC, "+CRLF
    cQuery += " C5_YPC "+CRLF
    cQuery += " from "+RetSqlName("ZM9")+" ZM9 (nolock) "+CRLF
    cQuery += " join "+RetSqlName("SB1")+" SB1 (nolock) on B1_FILIAL = '  ' and B1_COD = ZM9_PRODUT "+CRLF
    cQuery += " join "+RetSqlName("SC6")+" SC6 (nolock) on C6_FILIAL = ZM9_FILIAL and C6_NUM = ZM9_PEDIDO and C6_ITEM = ZM9_ITEM "+CRLF
    cQuery += " join "+RetSqlName("SC5")+" SC5 (nolock) on C5_FILIAL = ZM9_FILIAL and C5_NUM = ZM9_PEDIDO "+CRLF
    cQuery += " join "+RetSqlName("SA3")+" SA3 (nolock) on A3_FILIAL = '  ' and A3_COD = C5_VEND1 "+CRLF
    cQuery += " join "+RetSqlName("SA1")+" SA1 (nolock) on A1_FILIAL = '  ' and A1_COD = C5_CLIENTE and A1_LOJA = C5_LOJACLI "+CRLF
    cQuery += " where "+CRLF
    cQuery += " ZM9_DATA <= '"+DTOS(dDataBase-1)+"' "+CRLF
    cQuery += " and C5_VEND1 = '"+_cCodRep+"' "+CRLF
    cQuery += " and ZM9.D_E_L_E_T_ = '' "+CRLF
    cQuery += " and SB1.D_E_L_E_T_ = '' "+CRLF
    cQuery += " and SC6.D_E_L_E_T_ = '' "+CRLF
    cQuery += " and SC5.D_E_L_E_T_ = '' "+CRLF
    cQuery += " and SA3.D_E_L_E_T_ = '' "+CRLF
    cQuery += " and SA1.D_E_L_E_T_ = '' "+CRLF
    cQuery += " and ZM9.R_E_C_N_O_ in ( "+CRLF
    cQuery += " select REC from ( "+CRLF
    cQuery += " select ZM9_PEDIDO, ZM9_ITEM, REC = MAX(R_E_C_N_O_) from "+RetSqlName("ZM9")+" "+CRLF
    cQuery += " where ZM9_FILIAL = '"+XFilial("ZM9")+"' "+CRLF
    cQuery += " and ZM9_DATA = '"+DTOS(dDataEnv)+"' "+CRLF
    cQuery += " and D_E_L_E_T_ = '' "+CRLF
    cQuery += " group by ZM9_PEDIDO,ZM9_ITEM "+CRLF
    cQuery += " ) tab "+CRLF
    cQuery += " ) "+CRLF
    cQuery += " order by ZM9_DATA, C5_NUM, C6_ITEM "+CRLF

Return cQuery
