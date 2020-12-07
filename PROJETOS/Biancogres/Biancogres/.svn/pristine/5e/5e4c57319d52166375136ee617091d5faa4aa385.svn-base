#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} THistoricoClassificacaoCliente
@author Tiago Rossini Coradini
@since 20/05/2019
@version 1.0
@description Classe para tratamento de Historico de Classificacao de Cliente
@type class
/*/

Class TIClassificacaoCliente From LongClassName

	Data cTipo
	Data cCliente
	Data cLoja
	Data dData
	Data cSitAtu // 1=Normal; 2=Perda; 3=Perda / Cobranca Terceirizada; 4=Perda / Juridico
	Data cSitAnt // 1=Normal; 2=Perda; 3=Perda / Cobranca Terceirizada; 4=Perda / Juridico
	Data nSaldo	
	
	Method New() Constructor

EndClass


Method New() Class TIClassificacaoCliente

	::cTipo := "N"
	::cCliente := ""
	::cLoja := ""
	::dData := dDataBase
	::cSitAtu := "1"
	::cSitAnt := "2"
	::nSaldo := 0

Return()



Class THistoricoClassificacaoCliente From LongClassName
	
	Data oLst // Lista de objetos
		
	Method New() Constructor
	Method Process()
	Method Rating()
	Method AddHistory(nPos)
	Method UpdateSituation(nPos)
	Method SendWorkFlow()
	Method GetWFHeader()
	Method GetWFBody(nPos)
	Method GetWFFooter()
	
EndClass


Method New() Class THistoricoClassificacaoCliente	

	::oLst := ArrayList():New()
								
Return()


Method Process() Class THistoricoClassificacaoCliente	
Local nCount := 1

	::Rating()
	
	If ::oLst:GetCount() > 0

		While nCount <= ::oLst:GetCount()
		
			::AddHistory(nCount)
			
			::UpdateSituation(nCount)
			
			nCount++

		EndDo()
		
	EndIf

	::SendWorkFlow()
								
Return()


Method Rating() Class THistoricoClassificacaoCliente
Local cSQL := ""
Local cQry := GetNextAlias()
Local oObj := Nil

	cSQL := " EXEC SP_CLASSIFICACAO_CLIENTE "
			
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		oObj := TIClassificacaoCliente():New()

		oObj:cTipo := (cQry)->TIPO
		oObj:cCliente := (cQry)->A1_COD
		oObj:cLoja := (cQry)->A1_LOJA
		oObj:dData := dDataBase
		oObj:cSitAtu := If ((cQry)->TIPO == "N", "1", "2")
		oObj:cSitAnt := If ((cQry)->TIPO == "N", "2", "1")
		oObj:nSaldo := (cQry)->E1_SALDO
		
		::oLst:Add(oObj)
		
		(cQry)->(DbSkip())
								
	EndDo()
		
	(cQry)->(DbCloseArea())
		
Return()


Method AddHistory(nPos) Class THistoricoClassificacaoCliente
Local lInsert := .T.
	
	DbSelectArea("ZAJ")
	ZAJ->(DbSetOrder(1))

	lInsert := !ZAJ->(DbSeek(xFilial("ZAJ") + ::oLst:GetItem(nPos):cCliente + ::oLst:GetItem(nPos):cLoja + dToS(::oLst:GetItem(nPos):dData)))
	
	RecLock("ZAJ", lInsert)
	
		ZAJ->ZAJ_FILIAL := xFilial("ZAJ")
		ZAJ->ZAJ_CLIENT := ::oLst:GetItem(nPos):cCliente
		ZAJ->ZAJ_LOJA := ::oLst:GetItem(nPos):cLoja
		ZAJ->ZAJ_DATA := ::oLst:GetItem(nPos):dData
		ZAJ->ZAJ_SITATU := ::oLst:GetItem(nPos):cSitAtu
		ZAJ->ZAJ_SITANT := ::oLst:GetItem(nPos):cSitAnt
		ZAJ->ZAJ_SALDO := ::oLst:GetItem(nPos):nSaldo
					
	ZAJ->(MsUnLock())
			
Return()


Method UpdateSituation(nPos) Class THistoricoClassificacaoCliente	
Local cSQL := ""
	
	cSQL := " UPDATE " + RetFullName("SA1", "01")
	cSQL += " SET A1_YSITGRP = " + ValToSQL(::oLst:GetItem(nPos):cSitAtu)
	cSQL += " WHERE A1_COD = " + ValToSQL(::oLst:GetItem(nPos):cCliente)
	cSQL += " AND A1_LOJA = " + ValToSQL(::oLst:GetItem(nPos):cLoja)
	cSQL += " AND D_E_L_E_T_ = ''

	TcSQLExec(cSQL)
	
	cSQL := " UPDATE " + RetFullName("SA1", "05")
	cSQL += " SET A1_YSITGRP = " + ValToSQL(::oLst:GetItem(nPos):cSitAtu)
	cSQL += " WHERE A1_COD = " + ValToSQL(::oLst:GetItem(nPos):cCliente)
	cSQL += " AND A1_LOJA = " + ValToSQL(::oLst:GetItem(nPos):cLoja)
	cSQL += " AND D_E_L_E_T_ = ''

	TcSQLExec(cSQL)	
	
	cSQL := " UPDATE " + RetFullName("SA1", "07")
	cSQL += " SET A1_YSITGRP = " + ValToSQL(::oLst:GetItem(nPos):cSitAtu)
	cSQL += " WHERE A1_COD = " + ValToSQL(::oLst:GetItem(nPos):cCliente)
	cSQL += " AND A1_LOJA = " + ValToSQL(::oLst:GetItem(nPos):cLoja)
	cSQL += " AND D_E_L_E_T_ = ''

	TcSQLExec(cSQL)
	
Return()


Method SendWorkFlow() Class THistoricoClassificacaoCliente	
Local nCount := 1
Local cHtml := ""
Local cBody := ""
Local oMail := TAFMail():New()
	
	If ::oLst:GetCount() > 0

		While nCount <= ::oLst:GetCount()
			
			cBody	+= ::GetWFBody(nCount)
						
			nCount++

		EndDo()
		
		cHtml	:= ::GetWFHeader()
		cHtml	+= cBody
		cHtml	+= ::GetWFFooter()
		
		oMail:cTo := U_EmailWF("BIAF128")		
		oMail:cSubject := "Classificação automática de clientes"
		oMail:cBody := cHtml
	
		oMail:Send()
				
	EndIf
	
Return()


Method GetWFHeader() Class THistoricoClassificacaoCliente
Local cRet := ""

	cRet := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cRet += '    <title>Workflow</title>
	cRet += '    <style type="text/css">
	cRet += '        <!-- 
	cRet += '		.styleTable{
	cRet += '			border:0;
	cRet += '			cellpadding:3;
	cRet += '			cellspacing:2;
	cRet += '			width:100%;
	cRet += '		}
	cRet += '		.styleTableCabecalho{
	cRet += '            background: #fff;
	cRet += '            color: #ffffff;
	cRet += '            font: 14px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '		}
	cRet += '        .styleCabecalho{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '		.styleLinha{
	cRet += '            background: #f6f6f6;
	cRet += '            color: #747474;
	cRet += '            font: 11px Arial, Helvetica, sans-serif;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '        .styleHeader{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 14px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			text-align: center;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '        .styleRodape{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			text-align: center;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '		.styleLabel{
	cRet += '			color:#0c2c65;
	cRet += '		}
	cRet += '		.styleValor{
	cRet += '			color:#747474;
	cRet += '		}
	cRet += '        -->
	cRet += '    </style>
	cRet += '</head>
	cRet += '<body>
	cRet += '    <table class="styleTable" align="center">	
	cRet += '        <tr>
	cRet += '        		 <td class="styleHeader" width="60" scope="col" colspan="7">Classificação automática de clientes</td>
	cRet += '        </tr>         			
	cRet += '        <tr align=center>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Cliente </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Loja </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Nome </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Data </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Sit. Atual </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Sit. Anterior </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Saldo </th>
	cRet += '        </tr>
			
Return(cRet)


Method GetWFBody(nPos) Class THistoricoClassificacaoCliente
Local cRet := ""
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + ::oLst:GetItem(nPos):cCliente +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + ::oLst:GetItem(nPos):cLoja +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> ' + AllTrim(Posicione("SA1", 1, xFilial("SA1") + ::oLst:GetItem(nPos):cCliente + ::oLst:GetItem(nPos):cLoja, "A1_NOME")) +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + dToC(::oLst:GetItem(nPos):dData) +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + If (::oLst:GetItem(nPos):cSitAtu == "1", "Normal", "Perda") +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + If (::oLst:GetItem(nPos):cSitAnt == "1", "Normal", "Perda") +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + Transform(::oLst:GetItem(nPos):nSaldo, "@E 999,999,999.99") +' </th>
	cRet += '        </tr>
		
Return(cRet)


Method GetWFFooter() Class THistoricoClassificacaoCliente
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="7">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF128)
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)