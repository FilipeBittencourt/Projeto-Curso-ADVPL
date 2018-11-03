#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} VIXA258
CLASSE COM AS REGRAS DE NEGOCIO REFERENTE AS TRAVAS DO PROJETO VALIDACAO DE XML - NF-e/ CT-e
@type function
@author WLYSSES CERQUEIRA / FILIPE VIEIRA (FACILE)
@since 19/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Class VIXA258 From LongClassName 

	Data lRetorno
	Data cXml
	Data lIsXmlColab
	
	Method New() Constructor
	Method Validate() // Metodo principal que chama todos os outros metodos de validacao
	
	Method ValidRotaTpFrete()
	Method ValidCondPag()
	Method ValidCobertura()
	
	Method IsXmlColaboracao()
	Method RegistraTrava()
	Method WorkFlow()
	
EndClass

Method New() Class VIXA258
	
	::lRetorno		:= .T.
	::lIsXmlColab	:= ::IsXmlColaboracao()
	::cXml			:= ""
	
Return()

Method Validate() Class VIXA258

	If !::ValidRotaTpFrete()
		
		::lRetorno := .F.
		
	EndIf
	
	If !::ValidCondPag()
		
		::lRetorno := .F.
		
	EndIf
	
	If !::ValidCobertura()
		
		::lRetorno := .F.
		
	EndIf
	
Return(::lRetorno)

Method IsXmlColaboracao() Class VIXA258
	
	DBSelectArea("SDS")
	SDS->(DBSetOrder(1)) // DS_FILIAL, DS_DOC, DS_SERIE, DS_FORNEC, DS_LOJA, R_E_C_N_O_, D_E_L_E_T_
	
	DBSelectArea("SA2")
	SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("CKO")
	CKO->(DBSetOrder(1)) // CKO_ARQUIV, R_E_C_N_O_, D_E_L_E_T_
		
	If SDS->(DBSeek(xFilial("SDS") + cNFiscal + cSerie + cA100For + cLoja))
		
		If CKO->(DBSeek(xFilial("CKO") + SDS->DS_ARQUIVO))
		
			::cXml := CKO->CKO_ARQUIV
			
		ElseIf ! Empty(SDS->DS_YXML)
		
			::cXml := SDS->DS_YXML
		
		EndIf
		
		If SA2->(DBSeek(xFilial("SA2") + cA100For + cLoja))
		
			
		
		EndIf
		
	EndIf
		
Return(!Empty(::cXml))

Method ValidRotaTpFrete() Class VIXA258
	
	Local lRet := .T.
	
	If ::lIsXmlColab
	
		DBSelectArea("ZZ0")
		ZZ0->(DBSetOrder(1))
		
		If .T. // verificar a tag das rotas e o tipo de frete de cada rota bate com o cadastro
		
		Else
		
			lRet := .F.
		
		EndIf
	
	EndIf

Return(lRet)

Method ValidCondPag() Class VIXA258
	
	Local lRet := .T.
	
	If ::lIsXmlColab
	
		
	
	EndIf
	
Return(lRet)

Method ValidCobertura() Class VIXA258

	Local lRet := .T.

Return(lRet)

Method RegistraTrava() Class VIXA258

	Local lRet := .T.

Return(lRet)

Method WorkFlow() Class VIXA258

	Local cMensagem  := ""
	Local cLinkImg	 := "https://fortbras.com.br/imagens/logo-fortbras.png"
	Local cNomeEmp	 := SM0->M0_NOMFIL
	Local cLinkSit 	 := "https://fortbras.com.br/"
	Local cContrato_ := ""
	
	cMensagem :=cMensagem+'	<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word"'
	cMensagem :=cMensagem+'	xmlns="http://www.w3.org/TR/REC-html40">'
	cMensagem :=cMensagem+'	<head>'
	cMensagem :=cMensagem+'	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
	cMensagem :=cMensagem+'		<title>Comunicado Orçamento '+SM0->M0_FILIAL+'</title>'
	cMensagem :=cMensagem+'      <style type="text/css">'
	cMensagem :=cMensagem+'<!--'
	cMensagem :=cMensagem+'.style6 {font-size: 12px; font-weight: bold; }'
	cMensagem :=cMensagem+'.style7 {font-size: 12px}'
	cMensagem :=cMensagem+'-->'
	cMensagem :=cMensagem+'        </style>'
	cMensagem :=cMensagem+'</head>'
	cMensagem :=cMensagem+'	<body>'
	cMensagem :=cMensagem+'<div class="gs">'
	cMensagem :=cMensagem+'<div class="gE iv gt"></div>'
	cMensagem :=cMensagem+'<div class="utdU2e"></div><div class="tx78Ic"></div><div class="QqXVeb"></div><div id=":10g" tabindex="-1"></div><div id=":118" class="ii gt adP adO"><div id=":119"><u></u>'
	cMensagem :=cMensagem+'	<div style="padding:0;margin:0;background:#eaeaea">'
	cMensagem :=cMensagem+'		<table style="background:#eaeaea;font-family:Lucida grande,Sans-Serif;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="100%">'
	cMensagem :=cMensagem+'			<tbody><tr>'
	cMensagem :=cMensagem+'				<td style="padding:25px 0 55px" align="center">'
	cMensagem :=cMensagem+'					<table style="padding:0 50px;text-align:left;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="800">'
	cMensagem :=cMensagem+'		    <tbody><tr>'
	cMensagem :=cMensagem+'							<td style="padding-bottom:10px">'
	cMensagem :=cMensagem+'								<img src="'+cLinkImg+'">							</td>'
	cMensagem :=cMensagem+'						</tr>'
	cMensagem :=cMensagem+'						<tr>'
	cMensagem :=cMensagem+'							<td height="400" style="font-size:13px;color:#888;padding:30px 40px;border:1px solid #b8b8b8;background-color:#fff">'
	cMensagem :=cMensagem+'								<p style="color:black;margin:0">Você acaba de receber um informativo da '+Capital(SM0->M0_FILIAL)+'.</p>'
	cMensagem :=cMensagem+'				  <div style="background-color:#e3e3e3;padding:20px;color:black;margin:30px 0">'
	cMensagem :=cMensagem+'									<span style="font-weight:bold;font-size:14px;margin:0">'+If(lTesEsp_, "Emissão de NF. Triangulação Especial", "Processo de Triangulação com Armazenagem interna")+'</span>'
	cMensagem :=cMensagem+'			                        <hr style="margin:15px 0">'
	cMensagem :=cMensagem+'									<p style="margin:0"></p>'
	
	cMensagem :=cMensagem+'									<table width="674" border="0">'

	cMensagem :=cMensagem+'                                      <tr>'
	cMensagem :=cMensagem+'                                        <td width="117"><span class="style6">Contrato</span></td>'
	cMensagem :=cMensagem+'                                       <td width="547"><span class="style4 style7">'+cContrato_+'</span></td>'
	cMensagem :=cMensagem+'                                      </tr>'
	
	cMensagem :=cMensagem+'                                      <tr>'
	cMensagem :=cMensagem+'                                        <td width="117"><span class="style6">Pedido Origem</span></td>'
	cMensagem :=cMensagem+'                                       <td width="547"><span class="style4 style7">'+cPedido_+'</span></td>'
	cMensagem :=cMensagem+'                                      </tr>'
	
	cMensagem :=cMensagem+'                                      <tr>'
	cMensagem :=cMensagem+'                                        <td width="117"><span class="style6">Nota Fiscal</span></td>'
	cMensagem :=cMensagem+'                                       <td width="547"><span class="style4 style7">'+cNfOri_+'</span></td>'
	cMensagem :=cMensagem+'                                      </tr>'

	cMensagem :=cMensagem+'                                      <tr>'
	cMensagem :=cMensagem+'                                        <td><span class="style6">Emissao Nf</span></td>'
	cMensagem :=cMensagem+'                                        <td><span class="style4 style7">'+cEmisOri_+'</span></td>'
	cMensagem :=cMensagem+'                                      </tr>'
		
	cMensagem :=cMensagem+'                                      <tr>'
	cMensagem :=cMensagem+'                                        <td><span class="style6">Constante da Carga</span></td>'
	cMensagem :=cMensagem+'                                        <td><span class="style4 style7">'+cCarga_+'</span></td>'
	cMensagem :=cMensagem+'                                      </tr>'
	
	If lTesEsp_
	
		cMensagem :=cMensagem+'                                      <tr>'
		cMensagem :=cMensagem+'                                        <td><span class="style6">Observacoes</span></td>'
		cMensagem :=cMensagem+'                                        <td><span class="style4 style7">Providenciar emissão da nota fiscal de remessa de triangulação especial para o Pedido de Remessa nº: '+cPedFil_+'</span></td>'
		cMensagem :=cMensagem+'                                      </tr>'
	
	Else
	
		cMensagem :=cMensagem+'                                      <tr>'
		cMensagem :=cMensagem+'                                        <td><span class="style6">Observacoes</span></td>'
		cMensagem :=cMensagem+'                                        <td><span class="style4 style7">Seus produtos deverão ser armazenados internamente no Armazém ' + ::BRA_ARMTRI + ', até nosso cliente enviar a nota fiscal de triangulação para efetuarmos a Remessa. Pedido que será utilizado para a remessa: '+cPedFil_+'</span></td>'
		cMensagem :=cMensagem+'                                      </tr>'
	
	EndIf
	
	cMensagem :=cMensagem+'                                    </table>'
	cMensagem :=cMensagem+'                                    <br>'	
	
	cMensagem :=cMensagem+'					          </div>'
	cMensagem :=cMensagem+'						  <p>Esta notificação foi enviada por um email configurado para não receber resposta.<br>'
	cMensagem :=cMensagem+'									Por favor, não responda esta mensagem.							  </p>'
	cMensagem :=cMensagem+'						  </td>'
	cMensagem :=cMensagem+'						</tr>'
	cMensagem :=cMensagem+'					</tbody></table>'
	
	cMensagem :=cMensagem+'	    <p align="center" style="width:640px;padding:10px 20px;font-size:10px;color:#888;line-height:14px">'
	cMensagem :=cMensagem+'						Para acessar o site da '+cNomeEmp+','
	cMensagem :=cMensagem+'						<a href="'+cLinkSit+'" style="color:#666;text-decoration:underline" target="_blank">clique aqui.</a>					</p>'
	cMensagem :=cMensagem+'			  </td>'
	cMensagem :=cMensagem+'			</tr>'
	cMensagem :=cMensagem+'		</tbody></table><div class="yj6qo"></div><div class="adL">'
	cMensagem :=cMensagem+'	</div></div><div class="adL">'
	cMensagem :=cMensagem+'</div></div></div><div id=":104" class="ii gt" style="display:none"><div id=":103"></div></div><div class="hi"></div></div>'
	cMensagem :=cMensagem+'		</body>'
	cMensagem :=cMensagem+'	</html>'

Return()