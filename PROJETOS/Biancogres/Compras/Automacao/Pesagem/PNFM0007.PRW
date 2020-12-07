#Include "Protheus.ch"
#Include "TOTVS.ch"

User Function PNFM0007(cPesage, cChave, aCTE, aNFS)
	
	Local aArea			:= GetArea()
	
	Private _cPesage	:= cPesage
	Private _cChave		:= cChave
	Private _aCTE		:= aCTE
	Private _aNFS		:= aNFS
	
	ProcDados() 
			
	RestArea(aArea)		
Return


Static Function ProcDados()
	
	Local cHtml			:= ""
	Private _EmailDest	:= ""
	
	DbSelectArea("SF1")
	SF1->(DbSetOrder(8))
		
	If SF1->(DbSeek(xFilial('SF1')+PADR(_cChave, TamSx3("F1_CHVNFE")[1])))
		
		//Nota de massa -> Caminhão -> apenas um produto
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		SD1->(DbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+ SF1->F1_FORNECE+SF1->F1_LOJA))
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial('SB1')+SD1->D1_COD))
		
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial('SA2')+SD1->D1_FORNECE+SD1->D1_LOJA))
		
		DbSelectArea("Z11")
		Z11->(DbSetOrder(1))
		Z11->(DbSeek(xFilial('Z11')+_cPesage))
		
		_EmailDest := AllTrim(SA2->A2_YENFEP)
		/*DbSelectArea("DA3")
		DA3->(DbSetOrder(3))
		DA3->(DbSeek(xFilial('DA3')+Z11->Z11_PCAVAL))
		
		DbSelectArea("DA4")
		DA4->(DbSetOrder(1))
		DA4->(DbSeek(xFilial('DA4')+DA3->DA3_MOTORI))
		
		DbSelectArea("SA4")
		SA4->(DbSetOrder(1))
		SA4->(DbSeek(xFilial('SA4')+DA3->DA3_YTRANS))
		*/
		
		//If (SA2->(FieldPos("A2_YENFEP")) > 0) .And. (!Empty(SA2->A2_YENFEP))
			cHtml := GetHeader()
			cHtml += GetMsgBody()
			cHtml += "<br/>"
			cHtml += GetFooter()
			SendMail(cHtml)
		//Else
		//	MsgAlert("O campo 'E-mail Ticket' no cadastro do fornecedor não preenchido.","")
		//EndIf
		
	EndIf

Return

Static Function SendMail(cHtml)
	
	Local _lRet  		:= .F.
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""
	
	if (!Empty(_EmailDest))
		_cSubject := "Informações de Entrega/Pesagem"
		
		_cTo := U_EmailWF('PNFM0007',cEmpAnt)
		_cTo += _EmailDest
		_cCC := ""
		
		_cBody := cHtml      
		
		Conout("PNFM0007 Enviando e-mail para: "+_cTo)
		_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)
	Else
		MsgAlert("O campo 'E-mail Ticket' no cadastro do fornecedor/transportadora não preenchido.","")
	EndIf
Return(_lRet)

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
	cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-center: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (PNFM0007).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"
	cHtml += "      </body>"
	cHtml += "   </html>"
	cHtml += "   </html>"

Return cHtml

Static Function GetMsgBody()
	Local cHtml := ""
	
	cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '            <tr>'
			cHtml += '               <th colspan="2" align="center" class="cabtab" width="100" scope="col"> Dados da Nota Fiscal </th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="30%" scope="col"> Chave NFe </th>'
			cHtml += '               <th align="center" class="style12" width="70%" scope="col"> '+SF1->F1_CHVNFE+'</th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Número/Série NFe </th>'
			cHtml += '               <th align="center" class="style12" width="100" scope="col"> '+SF1->F1_DOC+'/'+SF1->F1_SERIE+'</th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Fornecedor </th>'
			cHtml += '               <th align="center" class="style12" width="100" scope="col"> '+SA2->A2_COD+'-'+SA2->A2_NOME+'</th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Produto </th>'
			cHtml += '               <th align="center" class="style12" width="100" scope="col"> '+SB1->B1_COD+'-'+SB1->B1_DESC+'</th>'
		cHtml += '            </tr>'	
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Quantidade NF </th>'
			cHtml += '               <th align="center"  class="style12" width="100" scope="col"> '+TRANSFORM((SD1->D1_QUANT), '@E 99,999,999,999.99')+'</th>'
		cHtml += '            </tr>'
	
	cHtml += '</table>'
	
	cHtml += "<br/>"
	
	cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '            <tr>'
			cHtml += '               <th colspan="2" align="center" class="cabtab" width="100" scope="col"> Dados da Conhecimento(s) de Transporte </th>'
		cHtml += '            </tr>'
		cHtml += TableCTe()
	cHtml += '</table>'
	
	cHtml += "<br/>"
	cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '            <tr>'
			cHtml += '               <th colspan="2" align="center" class="cabtab" width="100" scope="col"> Dados da notas fiscais de serviço </th>'
		cHtml += '            </tr>'
		cHtml += TableNFS()
	cHtml += '</table>'
	
	
	cHtml += "<br/>"
	
	cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '            <tr>'
			cHtml += '               <th colspan="2" align="center" class="cabtab" width="100" scope="col"> Dados da Pesagem </th>'
		cHtml += '            </tr>'
		
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="30%" scope="col"> Data/Hora de Entrada </th>'
			cHtml += '               <th class="style12" width="70%" scope="col"> '+	dtoc(Z11->Z11_DATAIN)+' '+Z11->Z11_HORAIN+'</th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Peso de Entrada </th>'
			cHtml += '               <th align="center"  class="style12" width="100" scope="col"> '+TRANSFORM((Z11->Z11_PESOIN/1000), '@E 99,999,999,999.99')+'</th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Data/Hora de Saida </th>'
			cHtml += '               <th align="center" class="style12" width="100" scope="col"> '+dtoc(Z11->Z11_DATASA)+' '+Z11->Z11_HORASA+'</th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Peso de Saida </th>'
			cHtml += '               <th align="center"  class="style12" width="100" scope="col"> '+TRANSFORM((Z11->Z11_PESOSA/1000), '@E 99,999,999,999.99')+'</th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Peso Liquido: </th>'
			cHtml += '               <th align="center" class="style12" width="100" scope="col"> '+TRANSFORM((Z11->Z11_PESLIQ/1000), '@E 99,999,999,999.99')+'</th>'
		cHtml += '            </tr>'
		cHtml += '            <tr>'
			cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Dif. (Peso Liq. – Peso NF) </th>'
			cHtml += '               <th align="center"  class="style12" width="100" scope="col"> '+TRANSFORM((SD1->D1_YTICKET - SD1->D1_QUANT), '@E 99,999,999,999.99')+'</th>'
		cHtml += '            </tr>'
	cHtml += '</table>'
	

Return cHtml

Static Function TableNFS()
	
	Local cHtml	:= ""
	Local nI	:= 0
		
	If (Len(_aNFS) > 0)		
		
		For nI:= 1 to Len(_aNFS)
			If (_aNFS[nI, Len(_aNFS[nI])] == .F.)	
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Número </th>'
					cHtml += '               <th class="style12" width="100" scope="col"> '+_aNFS[nI][1]+'</th>'
				cHtml += '            </tr>'
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Fornecedor/Loja </th>'
					cHtml += '               <th class="style12" width="100" scope="col"> '+_aNFS[nI][2]+'/'+_aNFS[nI][3] +'</th>'
				cHtml += '            </tr>'
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Data Emissão </th>'
					cHtml += '               <th class="style12" width="100" scope="col"> '+dtoc(_aNFS[nI][4])+'</th>'
				cHtml += '            </tr>'
				
				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))
				SA2->(DbSeek(xFilial('SA2')+_aNFS[nI][2]+_aNFS[nI][3]))
				
				_EmailDest += IIF(!Empty(_EmailDest), ";", "")+AllTrim(SA2->A2_YENFEP)					
									
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="30%" scope="col"> Transportadora </th>'
					cHtml += '               <th align="center" class="style12" width="70%" scope="col"> '+SA2->A2_COD+' - '+SA2->A2_NOME+'</th>'
				cHtml += '            </tr>'
				
				
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Placa </th>'
					cHtml += '               <th align="center" class="style12" width="100" scope="col"> '+Z11->Z11_PCAVAL+'</th>'
				cHtml += '            </tr>'
				
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Motorista </th>'
					cHtml += '               <th align="center" class="style12" width="100" scope="col">'+IIF(!Empty(Z11->Z11_MOTORI),Z11->Z11_MOTORI, 'Sem motorista')+'</th>'
				cHtml += '            </tr>'
			
				
				
			EndIf
		Next nI
	
	EndIf
Return cHtml

Static Function TableCTe()
	
	Local cHtml	:= ""
	Local nI	:= 0
		
	If (Len(_aCTE) > 0)	
		
		For nI:= 1 to Len(_aCTE)
			If (_aCTE[nI, Len(_aCTE[nI])] == .F.)	
				
				DbSelectArea("SF1")
				SF1->(DbSetOrder(8))
				SF1->(DbSeek(xFilial('SF1')+PADR(_aCTE[nI][1], TamSx3("F1_CHVNFE")[1])))
				
				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))
				SA2->(DbSeek(xFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA))
				
				_EmailDest += IIF(!Empty(_EmailDest), ";", "")+AllTrim(SA2->A2_YENFEP)	
				
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Chave CTe </th>'
					cHtml += '               <th class="style12" width="100" scope="col"> '+_aCTE[nI][1]+'</th>'
				cHtml += '            </tr>'
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Número/Série CTe</th>'
					cHtml += '               <th class="style12" width="100" scope="col"> '+SF1->F1_DOC+'/'+SF1->F1_SERIE +'</th>'
				cHtml += '            </tr>'
				
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="30%" scope="col"> Transportadora </th>'
					cHtml += '               <th align="center" class="style12" width="70%" scope="col"> '+SA2->A2_COD+' - '+SA2->A2_NOME+'</th>'
				cHtml += '            </tr>'
				
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Placa </th>'
					cHtml += '               <th align="center" class="style12" width="100" scope="col"> '+Z11->Z11_PCAVAL+'</th>'
				cHtml += '            </tr>'
				
				cHtml += '            <tr>'
					cHtml += '               <th align="center" class="cabtab" width="100" scope="col"> Motorista </th>'
					cHtml += '               <th align="center" class="style12" width="100" scope="col">'+IIF(!Empty(Z11->Z11_MOTORI),Z11->Z11_MOTORI, 'Sem motorista')+'</th>'
				cHtml += '            </tr>'
						

			EndIf
		Next nI
				
	EndIf
	
Return cHtml