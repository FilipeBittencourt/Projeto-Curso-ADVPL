#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BAFMAILCLI()

	Local cSQL 	:= ""
	Local cQry 	:= ""
	Local oMail	:= Nil
	Local nTotReg := 0
	
	RpcSetEnv("01", "01")
	
	cQry := GetNextAlias()
	
	oMail := TAFMail():New()
	
	cSQL := "SELECT DISTINCT A.*, B.A1_NOME, B.A1_EMAIL FROM ( "
	cSQL += "SELECT DISTINCT  C5_CLIENTE, C5_LOJACLI FROM SC5010 WHERE C5_YSUBTP IN ('N','E') AND D_E_L_E_T_='' AND C5_EMISSAO >= '20180101' "
	cSQL += "UNION ALL "
	cSQL += "SELECT DISTINCT  C5_CLIENTE, C5_LOJACLI FROM SC5050 WHERE C5_YSUBTP IN ('N','E') AND D_E_L_E_T_='' AND C5_EMISSAO >= '20180101' "
	cSQL += "UNION ALL "
	cSQL += "SELECT DISTINCT  C5_CLIENTE,C5_LOJACLI FROM SC5070 WHERE C5_YSUBTP IN ('N','E') AND D_E_L_E_T_='' AND C5_EMISSAO >= '20180101' "
	cSQL += ") A "
	cSQL += "JOIN dbo.SA1010 B (NOLOCK) ON (B.A1_FILIAL = '' AND B.A1_COD = A.C5_CLIENTE AND A.C5_LOJACLI = B.A1_LOJA AND B.D_E_L_E_T_ = '') "
	cSql += "WHERE B.A1_EMAIL <> '' "
	
	TcQuery cSQL New Alias (cQry)
	
	Count To nTotReg
		
	(cQry)->(DbGoTop())
		
	While !(cQry)->(Eof())
		
		Conout("Enviando email cliente [" + cValToChar(nTotReg--) + "] - " + (cQry)->A1_NOME)
		
		//oMail:cTo 	:= AllTrim((cQry)->A1_EMAIL)   <<<====== DESCOMENTAR PARA ENVIO AOS CLIENES
		oMail:cTo 		:= "" //<<<====== COLOQUE SEU EMAIL PARA TESTE
		oMail:cSubject	:= "Informativo"
		oMail:cBody		:= GetHtml()
		
		oMail:Send()
	
		(cQry)->(DbSkip())
			
	EndDo
	
	RpcClearEnv()

Return()

Static Function GetHtml()

	Local cHtml := ""
	
	cHtml += '<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:p="urn:schemas-microsoft-com:office:powerpoint" xmlns:a="urn:schemas-microsoft-com:office:access" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:rs="urn:schemas-microsoft-com:rowset" xmlns:z="#RowsetSchema" xmlns:b="urn:schemas-microsoft-com:office:publisher" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:c="urn:schemas-microsoft-com:office:component:spreadsheet" xmlns:odc="urn:schemas-microsoft-com:office:odc" xmlns:oa="urn:schemas-microsoft-com:office:activation" xmlns:html="http://www.w3.org/TR/REC-html40" xmlns:q="http://schemas.xmlsoap.org/soap/envelope/" xmlns:rtc="http://microsoft.com/officenet/conferencing" xmlns:D="DAV:" xmlns:Repl="http://schemas.microsoft.com/repl/" xmlns:mt="http://schemas.microsoft.com/sharepoint/soap/meetings/" xmlns:x2="http://schemas.microsoft.com/office/excel/2003/xml" xmlns:ppda="http://www.passport.com/NameSpace.xsd" xmlns:ois="http://schemas.microsoft.com/sharepoint/soap/ois/" xmlns:dir="http://schemas.microsoft.com/sharepoint/soap/directory/" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:dsp="http://schemas.microsoft.com/sharepoint/dsp" xmlns:udc="http://schemas.microsoft.com/data/udc" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sub="http://schemas.microsoft.com/sharepoint/soap/2002/1/alerts/" xmlns:ec="http://www.w3.org/2001/04/xmlenc#" xmlns:sp="http://schemas.microsoft.com/sharepoint/" xmlns:sps="http://schemas.microsoft.com/sharepoint/soap/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:udcs="http://schemas.microsoft.com/data/udc/soap" xmlns:udcxf="http://schemas.microsoft.com/data/udc/xmlfile" xmlns:udcp2p="http://schemas.microsoft.com/data/udc/parttopart" xmlns:wf="http://schemas.microsoft.com/sharepoint/soap/workflow/" xmlns:dsss="http://schemas.microsoft.com/office/2006/digsig-setup" xmlns:dssi="http://schemas.microsoft.com/office/2006/digsig" xmlns:mdssi="http://schemas.openxmlformats.org/package/2006/digital-signature" xmlns:mver="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns:mrels="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:spwp="http://microsoft.com/sharepoint/webpartpages" xmlns:ex12t="http://schemas.microsoft.com/exchange/services/2006/types" xmlns:ex12m="http://schemas.microsoft.com/exchange/services/2006/messages" xmlns:pptsl="http://schemas.microsoft.com/sharepoint/soap/SlideLibrary/" xmlns:spsl="http://microsoft.com/webservices/SharePointPortalServer/PublishedLinksService" xmlns:Z="urn:schemas-microsoft-com:" xmlns:st="&#1;" xmlns="http://www.w3.org/TR/REC-html40"> '
	cHtml += '<head> '
	cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> '
	cHtml += '<meta name="Generator" content="Microsoft Word 12 (filtered medium)"> '
	cHtml += '<!--[if !mso]> '
	cHtml += '<style> '
	cHtml += 'v\:* {behavior:url(#default#VML);} '
	cHtml += 'o\:* {behavior:url(#default#VML);} '
	cHtml += 'w\:* {behavior:url(#default#VML);} '
	cHtml += '.shape {behavior:url(#default#VML);} '
	cHtml += '</style> '
	cHtml += '<![endif]--><style> '
	cHtml += '<!-- '
	cHtml += ' /* Font Definitions */ '
	cHtml += ' @font-face '
	cHtml += '	{font-family:"Cambria Math"; '
	cHtml += '	panose-1:2 4 5 3 5 4 6 3 2 4;} '
	cHtml += '@font-face '
	cHtml += '	{font-family:Calibri; '
	cHtml += '	panose-1:2 15 5 2 2 2 4 3 2 4;} '
	cHtml += '@font-face '
	cHtml += '	{font-family:Tahoma; '
	cHtml += '	panose-1:2 11 6 4 3 5 4 4 2 4;} '
	cHtml += '@font-face '
	cHtml += '	{font-family:"Arial Narrow"; '
	cHtml += '	panose-1:2 11 6 6 2 2 2 3 2 4;} '
	cHtml += ' /* Style Definitions */ '
	cHtml += ' p.MsoNormal, li.MsoNormal, div.MsoNormal '
	cHtml += '	{margin:0cm; '
	cHtml += '	margin-bottom:.0001pt; '
	cHtml += '	font-size:11.0pt; '
	cHtml += '	font-family:"Calibri","sans-serif";} '
	cHtml += 'a:link, span.MsoHyperlink '
	cHtml += '	{mso-style-priority:99; '
	cHtml += '	color:blue; '
	cHtml += '	text-decoration:underline;} '
	cHtml += 'a:visited, span.MsoHyperlinkFollowed '
	cHtml += '	{mso-style-priority:99; '
	cHtml += '	color:purple; '
	cHtml += '	text-decoration:underline;} '
	cHtml += 'p.MsoAcetate, li.MsoAcetate, div.MsoAcetate '
	cHtml += '	{mso-style-priority:99; '
	cHtml += '	mso-style-link:"Texto de balão Char"; '
	cHtml += '	margin:0cm; '
	cHtml += '	margin-bottom:.0001pt; '
	cHtml += '	font-size:8.0pt; '
	cHtml += '	font-family:"Tahoma","sans-serif";} '
	cHtml += 'span.TextodebaloChar '
	cHtml += '	{mso-style-name:"Texto de balão Char"; '
	cHtml += '	mso-style-priority:99; '
	cHtml += '	mso-style-link:"Texto de balão"; '
	cHtml += '	font-family:"Tahoma","sans-serif";} '
	cHtml += 'span.EstiloDeEmail19 '
	cHtml += '	{mso-style-type:personal; '
	cHtml += '	font-family:"Calibri","sans-serif"; '
	cHtml += '	color:windowtext;} '
	cHtml += 'span.EstiloDeEmail20 '
	cHtml += '	{mso-style-type:personal-reply; '
	cHtml += '	font-family:"Calibri","sans-serif"; '
	cHtml += '	color:windowtext;} '
	cHtml += '.MsoChpDefault '
	cHtml += '	{mso-style-type:export-only; '
	cHtml += '	font-size:10.0pt;} '
	cHtml += '@page Section1 '
	cHtml += '	{size:612.0pt 792.0pt; '
	cHtml += '	margin:70.85pt 3.0cm 70.85pt 3.0cm;} '
	cHtml += 'div.Section1 '
	cHtml += '	{page:Section1;} '
	cHtml += ' /* List Definitions */ '
	cHtml += ' @list l0 '
	cHtml += '	{mso-list-id:412239841; '
	cHtml += '	mso-list-template-ids:2123366580;} '
	cHtml += '@list l0:level1 '
	cHtml += '	{mso-level-number-format:bullet; '
	cHtml += '	mso-level-text:•; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += '@list l0:level2 '
	cHtml += '	{mso-level-start-at:0; '
	cHtml += '	mso-level-text:""; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += '@list l0:level3 '
	cHtml += '	{mso-level-start-at:0; '
	cHtml += '	mso-level-text:""; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += '@list l0:level4 '
	cHtml += '	{mso-level-start-at:0; '
	cHtml += '	mso-level-text:""; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += '@list l0:level5 '
	cHtml += '	{mso-level-start-at:0; '
	cHtml += '	mso-level-text:""; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += '@list l0:level6 '
	cHtml += '	{mso-level-start-at:0; '
	cHtml += '	mso-level-text:""; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += '@list l0:level7 '
	cHtml += '	{mso-level-start-at:0; '
	cHtml += '	mso-level-text:""; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += '@list l0:level8 '
	cHtml += '	{mso-level-start-at:0; '
	cHtml += '	mso-level-text:""; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += '@list l0:level9 '
	cHtml += '	{mso-level-start-at:0; '
	cHtml += '	mso-level-text:""; '
	cHtml += '	mso-level-tab-stop:none; '
	cHtml += '	mso-level-number-position:left; '
	cHtml += '	margin-left:0cm; '
	cHtml += '	text-indent:0cm;} '
	cHtml += 'ol '
	cHtml += '	{margin-bottom:0cm;} '
	cHtml += 'ul '
	cHtml += '	{margin-bottom:0cm;} '
	cHtml += '--> '
	cHtml += '</style><!--[if gte mso 9]><xml> '
	cHtml += ' <o:shapedefaults v:ext="edit" spidmax="1026" /> '
	cHtml += '</xml><![endif]--><!--[if gte mso 9]><xml> '
	cHtml += ' <o:shapelayout v:ext="edit"> '
	cHtml += '  <o:idmap v:ext="edit" data="1" /> '
	cHtml += ' </o:shapelayout></xml><![endif]--> '
	cHtml += '</head> '
	cHtml += '<body lang="PT-BR" link="blue" vlink="purple"> '
	cHtml += '<div class="Section1"> '
	//cHtml += "<b><span style='font-family:"+'"Arial"' + ",sans-serif;color:#7F7F7F;mso-style-textfill-fill-color:#7F7F7F;mso-style-textfill-fill-alpha:100.0%'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Grupo<br>&nbsp;&nbsp;Biancogres</span></b>"
	cHtml += '<p class="MsoNormal"><img width="106" height="118" id="Imagem_x0020_1" src="https://uploaddeimagens.com.br/images/001/779/152/full/LOGO_GRUPO_BIANCOGRES.PNG" alt="Imagem1 - FUNDO TRANSPARENTE.png"><o:p></o:p></p> '
	cHtml += '<p class="MsoNormal" align="right" style="text-align:right"><span style="font-size: '
	cHtml += '12.0pt;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545">Serra, ES. 13 de Dezembro de 2018.<o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal"><b><u><span style="font-size:12.0pt;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;">Grupo Biancogres'
	cHtml += '<o:p></o:p></span></u></b></p>'
	cHtml += '<p class="MsoNormal"><span style="font-size:12.0pt;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal"><span style="font-size:12.0pt;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545">Ref.: '
	cHtml += '<u>Atualização de cadastro</u>.<o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal"><span style="font-size:12.0pt;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal"><span style="font-size:12.0pt;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify;line-height:115%"><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545">Implementaremos a partir de 17/12/18 um novo sistema que proporcionará praticidade, comodidade '
	cHtml += ' e segurança aos nossos clientes e parceiros comerciais no processo de envio automático de boleto bancário de cobrança.<o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify;line-height:115%"><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify;line-height:115%"><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545">Para que possamos disponibilizar essa nova funcionalidade, a primeira etapa é a atualização '
	cHtml += ' do cadastro. <o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify;line-height:115%"><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify;line-height:115%"><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545">Assim sendo, solicitamos com a maior brevidade o fornecimento dos dados enumerados a seguir:<o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify;line-height:115%"><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="margin-left:18.0pt;text-align:justify;text-indent: '
	cHtml += '-18.0pt;line-height:115%;mso-list:l0 level1 lfo2"> '
	cHtml += '<![if !supportLists]><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><span style="mso-list:Ignore">•<span style="font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '
	cHtml += '</span></span></span><![endif]><span style="font-size:12.0pt;line-height:115%; '
	cHtml += 'font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545">Nome do responsável pelo departamento financeiro e/ou contas a pagar;<o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="margin-left:18.0pt;text-align:justify;text-indent: '
	cHtml += '-18.0pt;line-height:115%;mso-list:l0 level1 lfo2"> '
	cHtml += '<![if !supportLists]><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><span style="mso-list:Ignore">•<span style="font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '
	cHtml += '</span></span></span><![endif]><span style="font-size:12.0pt;line-height:115%; '
	cHtml += 'font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545">E-mail e telefone de contato.<o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify;line-height:115%"><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify;line-height:115%"><span style="font-size:12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545">Dessa forma, solicitamos a gentileza que as informações sejam enviadas por e-mail para o '
	cHtml += ' endereço eletrônico</span><span style="font-size: '
	cHtml += '12.0pt;line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#0563C1"> '
	cHtml += '<u>nadine.araujo@biancogres.com.br</u></span><span style="font-size:12.0pt; '
	cHtml += 'line-height:115%;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545"><o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify"><span style="font-size:12.0pt; '
	cHtml += 'font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify"><span style="font-size:12.0pt; '
	cHtml += 'font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545">Mais informações poderão ser obtidas pelo telefone (27) 3421-9054/9014.<o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify"><span style="font-size:12.0pt; '
	cHtml += 'font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify"><span style="font-size:12.0pt; '
	cHtml += 'font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545">Atenciosamente.<o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify"><span style="font-size:12.0pt; '
	cHtml += 'font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545"><o:p>&nbsp;</o:p></span></p> '
	cHtml += '<p class="MsoNormal" style="text-align:justify"><span style="font-size:12.0pt; '
	cHtml += 'font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;;color:#2E3545">Departamento Crédito/Cobrança</span><span style="font-size:8.0pt;font-family:&quot;Arial Narrow&quot;,&quot;sans-serif&quot;; '
	cHtml += 'color:#2E3545"><o:p></o:p></span></p> '
	cHtml += '<p class="MsoNormal"><o:p>&nbsp;</o:p></p> '
	cHtml += '</div> '
	cHtml += '</body> '
	cHtml += '</html> '

Return(cHtml)