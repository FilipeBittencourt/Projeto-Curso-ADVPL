#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF037
@author Tiago Rossini Coradini
@since 04/07/2016
@version 1.0
@description Workflow de alteração de data de necessidade de engenharia, alteração maior que 10 dias
@obs OS: 4060-15 - Claudeir Fadini
@type function
/*/


// Indices do array de itens
#DEFINE IDX_ITEM 1
#DEFINE IDX_PRODUTO 2
#DEFINE IDX_QTD 3
#DEFINE IDX_DTOLD 4
#DEFINE IDX_DTNEW 5


User Function BIAF037()
Local nLine := 0
Local cItem := ""
Local cCodPrd := ""
Local nQtdVen := 0
Local nQtdEnt := 0
Local dDtOld := Nil
Local dDtNew := Nil
Private aItemPed := {}
Private cHTML := ""
	
	If Type("Altera") <> "U" .And. Altera .And. U_FSEGORI(M->C5_NUM) == "E"
		
		For nLine := 1 To Len(aCols)
		
			If !GdDeleted(nLine)
			
				cItem := GdFieldGet("C6_ITEM", nLine)
				cCodPrd := GdFieldGet("C6_PRODUTO", nLine)
				nQtdVen := GdFieldGet("C6_QTDVEN", nLine)
				nQtdEnt := Posicione("SC6", 1, xFilial("SC6") + M->C5_NUM + cItem, "C6_QTDENT")
				dDtOld := Posicione("SC6", 1, xFilial("SC6") + M->C5_NUM + cItem, "C6_YDTNECE")
				dDtNew := GdFieldGet("C6_YDTNECE", nLine)
		    
		    If !Empty(dDtOld) .And. !Empty(dDtNew) .And. DateDiffDay(dDtOld, dDtNew) > 10 .And. nQtdVen - nQtdEnt > 500 
		    
		    	aAdd(aItemPed, {cItem, cCodPrd, nQtdVen, dDtOld, dDtNew})
		    				    
		    EndIf
		    
		  EndIf
			
		Next
		
		
		If !Empty(aItemPed)
		
			cHTML := fGetCab()
			
			For nLine := 1 To Len(aItemPed)
			
				cHTML	+= fGetItem(nLine)
			
			Next
			
			cHTML	+= fGetRod()
			
			fSendMail(cHTML)
		
		EndIf			
			
	EndIf

Return()


Static Function fGetCab()
Local cRet := ""
Local cCodCli := ""
Local cLojCli := ""

	If !Empty(M->C5_YCLIORI)
		
		cCodCli := M->C5_YCLIORI
		cLojCli := M->C5_YLOJORI
		
	Else
	
		cCodCli := M->C5_CLIENTE
		cLojCli := M->C5_LOJACLI
	
	EndIf	

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
	cRet += '			<td colspan="6">
	cRet += '				<table width="100%" cellpadding="10" cellspacing="0">
	cRet += '					<tr class="styleTableCabecalho">
	cRet += '						<td width="33%">
	cRet += '							<span class="styleLabel">Empresa: </span>
	cRet += '							<span class="styleValor">'+ Capital(FWEmpName(cEmpAnt)) +'</span>
	cRet += '						</td>
	cRet += '						<td width="33%">
	cRet += '							<span class="styleLabel">Pedido: </span>
	cRet += '							<span class="styleValor">'+ M->C5_NUM +'</span>
	cRet += '						</td>
	cRet += '						<td width="33%">
	cRet += '							<span class="styleLabel">Cliente: </span>
	cRet += '							<span class="styleValor">'+ cCodCli +'-'+ cLojCli +' - '+ AllTrim(Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLojCli, "A1_NOME")) +'</span>
	cRet += '						</td>
	cRet += '					</tr>				
	cRet += '				</table>
	cRet += '			</td>
	cRet += '        </tr>

	cRet += '        <tr align=center>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Item </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Produto </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Descrição </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Quantidade </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Data Antiga </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Data Nova </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Usuário Alt. </th>	
	cRet += '        </tr>	
	
Return(cRet)


Static Function fGetItem(nLine)
Local cRet := ""
	
	cRet += '        <tr align=center>
	cRet += '            <td class="styleLinha" width="60" scope="col">'+ aItemPed[nLine, IDX_ITEM] +'</td>
	cRet += '            <td class="styleLinha" width="60" scope="col">'+ AllTrim(aItemPed[nLine, IDX_PRODUTO]) +'</td>
	cRet += '            <td class="styleLinha" width="200" scope="col">'+ AllTrim(Posicione("SB1", 1, xFilial("SB1") + aItemPed[nLine, IDX_PRODUTO], "B1_DESC")) +'</td>
	cRet += '            <td class="styleLinha" width="60" scope="col">'+ cValToChar(aItemPed[nLine, IDX_QTD]) +'</td>
	cRet += '            <td class="styleLinha" width="60" scope="col">'+ dToC(aItemPed[nLine, IDX_DTOLD]) +'</td>
	cRet += '            <td class="styleLinha" width="60" scope="col">'+ dToC(aItemPed[nLine, IDX_DTNEW]) +'</td>
	cRet += '            <td class="styleLinha" width="80" scope="col">'+ __cUserId + "-" + AllTrim(cUserName) +'</td>
	cRet += '        </tr>
	
Return(cRet)


Static Function fGetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="7">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF037).
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


/*Static Function fSendMail(cHTML)
Local cMail := ""
	
	If M->C5_YLINHA == "1"
		cMail := "claudeir.fadini@biancogres.com.br;raul.grossi@biancogres.com.br"
	Else
		cMail := "mateus.fadini@bellacasaceramica.com.br"
	EndIf
	
	U_BIAEnvMail(,cMail, "Alteração de Data de Necessidade de Engenharia", cHTML)
		
Return()*/

Static Function fSendMail(cHTML)
Local cMail := AllTrim(U_EmailWF('BIAF037', cEmpAnt))
	
	U_BIAEnvMail(,cMail, "Alteração de Data de Necessidade de Engenharia", cHTML)
	
Return()