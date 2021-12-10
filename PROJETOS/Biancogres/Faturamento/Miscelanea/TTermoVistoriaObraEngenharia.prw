#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TTermoVistoriaObraEngenharia
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe para controle do Termo de Aceite de Mercadorias de Vistorias em Obras de Engenharia 
@obs Ticket: 19122
@type class

Ticket 32630 - Layout de impressão do termo alterado conforme solicitação da diretoria em 02/06/2021.
/*/

Class TTermoVistoriaObraEngenharia From LongClassName	
	
	Data dEmiDe
	Data dEmiAte
	Data docto //caso queira gerar o termo de um documento especifico
	Data nobra
		
	Method New() Constructor
	Method Process()
	Method GetHeader(cDtVis, cCliente, cDescObr, cEndereco, cCidade, cUF, cVendedor)
	Method GetBody(cDoc, cSerie, cItem, cProduto, cLote, nQuant)	
	Method GetFooter()
	Method SaveHtmlFile(cDtVis, cCliente, cNumObr, cHtml)
	Method ConvertHtmlToPdf(cFile)

EndClass


Method New() Class TTermoVistoriaObraEngenharia

	::dEmiDe := dDataBase
	::dEmiAte := dDataBase
	::docto := ""
				
Return()


Method Process() Class TTermoVistoriaObraEngenharia
Local cSQL := ""
Local cQry := GetNextAlias()
Local cDtVis := ""
Local cCliente := ""
Local cNumObr := ""
Local cHtml := ""
Local cBody := ""

	cSQL := " SELECT ZKS_DATA, ZKS_DATPRE, ZKS_CLIENT, ZKS_LOJA, A1_NOME, ZKS_NUMOBR, 
	cSQL += " ISNULL(
	cSQL += " (
	cSQL += " 	SELECT ZZO_OBRA
	cSQL += " 	FROM "+ RetFullName("ZZO", "01")
	cSQL += " 	WHERE ZZO_FILIAL = " + ValToSQL(cFilAnt)
	cSQL += " 	AND ZZO_NUM = ZKS_NUMOBR
	cSQL += " 	AND D_E_L_E_T_ = ''	
	cSQL += " ), '') AS ZZO_OBRA,
	cSQL += " A1_END, A1_MUN, A1_EST, ZKS_VEND, A3_NOME, ZKS_DOC, ZKS_SERIE, ZKS_ITEM, ZKS_PRODUT, B1_DESC, ZKS_LOTE, ZKS_QUANT 
	cSQL += " FROM "+ RetSQLName("ZKS") + " AS ZKS
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " AS SA1
	cSQL += " ON ZKS_CLIENT = A1_COD
	cSQL += " AND ZKS_LOJA = A1_LOJA
	cSQL += " INNER JOIN "+ RetSQLName("SA3") + "  AS SA3
	cSQL += " ON ZKS_VEND = A3_COD
	cSQL += " INNER JOIN "+ RetSQLName("SB1") + "  AS SB1
	cSQL += " ON ZKS_PRODUT = B1_COD
	cSQL += " WHERE ZKS_FILIAL = " + ValToSQL(xFilial("ZKS"))
	
	//docto e nobra preenchidos apenas via tela de Vistorias. No Job é executado sempre o between de datas.
	if(Empty(::docto) .AND. Empty(::nobra))
		cSQL += " AND ZKS_DATA BETWEEN " + ValToSQL(::dEmiDe) + " AND " + ValToSQL(::dEmiAte)
	else
		if(!Empty(::nobra))
			cSQL += " AND ZKS.ZKS_NUMOBR = '" + ::nobra + "' "
		else
			cSQL += " AND RTRIM(ZKS.ZKS_DOC) + RTRIM(ZKS_SERIE) + RTRIM(ZKS_ITEM) = '" + ::docto + "' "
		endif	
	endif
	
	cSQL += " AND ZKS.D_E_L_E_T_ = '' 
	cSQL += " AND A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " AND SA1.D_E_L_E_T_ = '' 
	cSQL += " AND A3_FILIAL = " + ValToSQL(xFilial("SA3"))
	cSQL += " AND SA3.D_E_L_E_T_ = '' 
	cSQL += " AND B1_FILIAL = " + ValToSQL(xFilial("SB1"))
	cSQL += " AND SB1.D_E_L_E_T_ = ''
	cSQL += " ORDER BY ZKS_DATA, ZKS_DATPRE, ZKS_CLIENT, ZKS_LOJA, ZKS_NUMOBR, ZKS_DOC, ZKS_SERIE, ZKS_PRODUT, ZKS_ITEM, ZKS_LOTE, ZKS_QUANT
	
	TcQuery cSQL New Alias (cQry)		  			
		
	While !(cQry)->(Eof())

		cDtVis := (cQry)->ZKS_DATPRE
				
		cCliente := (cQry)->ZKS_CLIENT
		
		cNumObr := (cQry)->ZKS_NUMOBR

		cHtml	:= ::GetHeader((cQry)->ZKS_DATPRE, (cQry)->A1_NOME, (cQry)->ZZO_OBRA, (cQry)->A1_END, (cQry)->A1_MUN, (cQry)->A1_EST, (cQry)->A3_NOME)		

		While cDtVis == (cQry)->ZKS_DATPRE .And. cCliente == (cQry)->ZKS_CLIENT .And. cNumObr == (cQry)->ZKS_NUMOBR
														
			cBody	+= ::GetBody((cQry)->ZKS_DOC, (cQry)->ZKS_SERIE, (cQry)->ZKS_ITEM, AllTrim((cQry)->ZKS_PRODUT) + "-" + AllTrim((cQry)->B1_DESC), (cQry)->ZKS_LOTE, (cQry)->ZKS_QUANT)
						
			(cQry)->(DbSkip())
			
		EndDo()					
		
		cHtml	+= cBody
		cHtml	+= ::GetFooter()
			
		::SaveHtmlFile(cDtVis, cCliente, cNumObr, cHtml)
							
		cBody := ""
		
	EndDo()
	
	(cQry)->(DbCloseArea())

Return()


Method GetHeader(cDtVis, cCliente, cDescObr, cEndereco, cCidade, cUF, cVendedor) Class TTermoVistoriaObraEngenharia
Local cRet := ""

	cRet := '<html>
	cRet += '<head></head>
	cRet += '<style type="text/css">
	cRet += '    table.titulo {
	cRet += '        border: 1px solid;
	cRet += '        border-collapse: collapse;
	cRet += '        font-family: Arial, Helvetica, sans-serif;
	cRet += '        font-size:15px;
	cRet += '    }
	cRet += '    
	cRet += '    table.titulo th {
	cRet += '        border: 1px solid;
	cRet += '        font-size:15px;
	cRet += '    }
	cRet += '    
	cRet += '    table.titulo td {
	cRet += '        border: 1px solid;
	cRet += '        font-size:12px;
	cRet += '    }
	cRet += '    
	cRet += '    div.responsavel {
	cRet += '        border-bottom: 1px solid;
	cRet += '        width: 70%;
	cRet += '    }
	cRet += '    
	cRet += '    div.prod-obs {
	cRet += '        border-bottom: 1px solid;
	cRet += '        width: 90%;
	cRet += '    }
	cRet += '   
	cRet += '    div.instrucoes {
	cRet += '        width: 90%;
	cRet += '    }
	cRet += '</style>
	cRet += '<body>
	cRet += '    <table class="titulo" width="100%" border="0" cellspacing="0" cellpadding="4">
	cRet += '        <tr>
	cRet += '            <th colspan="3" width="81%">TERMO DE INSPEÇÃO PARA AUTORIZAÇÃO DE CONTINUIDADE DE ASSENTAMENTO</th>
	cRet += '            <th width="19%" rowspan="3" style="white-space:nowrap;">BG-FO-COM-045</th>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td width="54%" align="center">Data da Revisão: 21/08/2020</td>
	cRet += '            <td width="27%" align="center">Nº Revisão: 02</td>
	cRet += '        </tr>
	cRet += '    </table>

	cRet += '    <br/>
	
	cRet += '    <table border="0" cellspacing="0" cellpadding="4">
	cRet += '            <tr style="  text-align: justify; font-family: Arial, Helvetica, sans-serif;        font-size:12px;" valign="bottom">
	cRet += '                Para construções acima de 1.000 m² é obrigatório realizar o assentamento completo com rejuntamento em 01 (um) apartamento, casa ou cômodo para aprovação do produto. Caso seja recebido mais de um lote para uma mesma obra deve ser repetida a operação de assentamento de outro ambiente para aprovação. No caso de produtos retificados é fundamental o uso de niveladores e cunhas para um melhor resultado estético do material assentado.
	cRet += '            </tr>
	cRet += '    </table>
	cRet += '    <br>
	cRet += '    <table class="titulo" width="100%" border="0" cellspacing="0" cellpadding="4">
	cRet += '        <tr>
	cRet += '            <td width="27%">PRAZO VISTORIA: '+ dToC(sToD(cDtVis)) +'</td>
	cRet += '            <td colspan="3">CONSTRUTORA: '+ AllTrim(cCliente) +'</td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td width="30%" colspan="3">OBRA: '+ AllTrim(cDescObr) +'</td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td width="30%" colspan="3">ENDEREÇO: '+ AllTrim(cEndereco) +'</td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td width="70%" colspan="2">CIDADE: '+ AllTrim(cCidade) +'</td>
	cRet += '            <td width="30%">UF: '+ AllTrim(cUF) +'</td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td width="30%" colspan="3">RESPONSÁVEL PELA OBRA: </td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td width="30%" colspan="3">REPRESENTANTE: '+ AllTrim(cVendedor) +'</td>
	cRet += '        </tr>
	cRet += '    </table>
	
	cRet += '    <br/>

	cRet += '    <table class="titulo" width="100%" border="0" cellspacing="0" cellpadding="4">
	cRet += '        <tr>
	cRet += '            <th>NOTA </th>
	cRet += '            <th>SÉRIE </th>
	cRet += '            <th>ITEM </th>
	cRet += '            <th>PRODUTO </th>
	cRet += '            <th>LOTE </th>
	cRet += '            <th align="center" style="white-space: nowrap;">QTD. M2 </th>
	cRet += '            <th align="center">AMBIENTE INSPECIONADO</th>
	cRet += '            <th width="30%">OBS: </th>
	cRet += '        </tr>
	
Return(cRet)


Method GetBody(cDoc, cSerie, cItem, cProduto, cLote, nQuant) Class TTermoVistoriaObraEngenharia
Local cRet := ""
	
	cRet := '        <tr>
	cRet += '            <td>'+ AllTrim(cDoc) +'</td>
	cRet += '            <td>'+ AllTrim(cSerie) +'</td>
	cRet += '            <td>'+ AllTrim(cItem) +'</td>
	cRet += '            <td>'+ AllTrim(cProduto) +'</td>
	cRet += '            <td>'+ AllTrim(cLote) +'</td>
	cRet += '            <td align="right">'+ Transform(nQuant, X3Picture("ZKS_QUANT")) +'</td>
	cRet += '            <td align="center">       </td>
	cRet += '            <td align="center" valign="bottom">
	cRet += '                <div class="prod-obs"> </div>
	cRet += '            </td>
	cRet += '        </tr>
				
Return(cRet)

	
Method GetFooter() Class TTermoVistoriaObraEngenharia
Local cRet := ""

	cRet := '    </table>
		
	cRet += '    <br/>

	cRet += '       <table style="border: 1px solid; font-family: Arial, Helvetica, sans-serif; font-size:12px;" width="100%" border="0" cellspacing="2" cellpadding="4">
	cRet += '          <tr >
	cRet += '             <th colspan="4" align="left" style="padding-top:15px">Data da inspeção: ___/___/_______</th>
	cRet += '          </tr>
	cRet += '          <tr >
	cRet += '             <th colspan="4" align="left" >Parecer</th>
	cRet += '          </tr>
	cRet += '          <tr >
	cRet += '             <td >
	cRet += '                <input style="zoom: 1.5; vertical-align: middle;" type="checkbox" id="responsavel" name="responsavel" value="Bike">
	cRet += '                <label for="responsavel">Aprovado dar continuidade ao assentamento do(s) produto(s)</label>
	cRet += '             </td>
	cRet += '          </tr>
	cRet += '          <tr >
	cRet += '             <td >
	cRet += '                <input style="zoom: 1.5; vertical-align: middle;" type="checkbox" id="responsavel" name="responsavel" value="Bike">
	cRet += '                <label for="responsavel">Suspender o assentamento e entrar em contato com o SAC</label>
	cRet += '             </td>
	cRet += '          </tr>
	cRet += '              <tr>
	cRet += '                  <td>
	cRet += '                  </td>
	cRet += '              </tr>
	cRet += '              <tr >
	cRet += '              		<td style="padding-left:70px !important;padding-top:30px;text-decoration-line: overline;">Representante da Biancogres</td>
	cRet += '				</tr>
	cRet += '        		<br/>
	cRet += '        		<tr>
	cRet += '		            <td style="padding-left:70px !important;padding-top:20px;padding-bottom:20px;"> Nome: </td>
	cRet += '        		</tr>
	cRet += '       </table>
	cRet += '    <br/>
	cRet += '    <span style="font-family: Arial, Helvetica, sans-serif;">
	cRet += '          Confirmo a visita do representante comercial da Biancogres, que fez a inspeção dos materiais relacionados acima.<br><br>	
	cRet += '    </span>
	
	cRet += '    <br/>
	cRet += '    <br/>
	
	cRet += '    <table style="padding-left:20px;font-family: Arial, Helvetica, sans-serif;" width="100%" border="0" cellspacing="0" cellpadding="10">
	cRet += '        <tr>
	cRet += '        	<td style="text-decoration-line: overline;">Responsável pela Obra</td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td> Nome: </td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td> CPF: </td>
	cRet += '        </tr>
	cRet += '    </table>
	
	cRet += '</body>
	
	cRet += '</html>
				
Return(cRet)


Method SaveHtmlFile(cDtVis, cCliente, cNumObr, cHtml) Class TTermoVistoriaObraEngenharia
Local cFile := ""

	cIdName := ""

	If(!Empty(cNumObr))
		cIdName := "_" + cNumObr
	elseif !Empty(::docto)
		//esse caso só ocorre quando a geração do termo está ocorrendo via tela. 
		//Via schedule ele agrupa por numero de obra que, se for vazio, agrupa num só documento todos daquele cliente
		cIdName := "_" + ::docto
	Endif

	cFile := Lower("\p10\vistoria_obra\termo\termo_" + cEmpAnt + "_" + cDtVis + "_" + cCliente + cIdName + ".html")

	U_ChkDirVistoriaObra()

	If File(cFile)

		FErase(cFile)
		
	EndIf	
	
	fHandle := fCreate(cFile)
	FWrite(fHandle, cHtml)	
	fClose(fHandle)
	
	::ConvertHtmlToPdf(cFile)
	
	FErase(cFile)
				
Return()


Method ConvertHtmlToPdf(cFile) Class TTermoVistoriaObraEngenharia
Local cRootPath := GetPvProfString(GetEnvServer(), "RootPath", "", GetSrvIniName())
Local cCommand := ""
Local cPathCommand := "" 

	cCommand := "wkhtmltopdf.exe toc" + Space(1) + cRootPath + cFile + Space(1) + cRootPath + StrTran(cFile, ".html", ".pdf")
	cPathCommand := cRootPath + "\pdf_converter" 

	WaitRunSrv(cCommand, .T., cPathCommand)
				
Return()
