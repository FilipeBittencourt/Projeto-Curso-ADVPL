#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TINAWorkFlow
@description Classe para envio de email
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/

Class TINAWorkFlow From LongClassName

	Data cAssunto
	Data cEmail    // separados por  (;)  ponto e virgula   -  abc@abc.com;efg@efg.com.br 
	Data cBody // trecho em HTML, somente com as informações
	Data cTitBody // titulo do corpo do email

	Method New() Constructor
	Method WFMail()

EndClass

Method New() Class TINAWorkFlow

	::cAssunto := ""
	::cEmail := ""
	::cBody := ""
	::cTitBody := ""

Return Self


Method WFMail() Class TINAWorkFlow

	Local cScryptHtml 	:= ""
	Local cLinkImg	 	:= "http://www.grupouniaosa.com.br/wp-content/themes/grupouniao/images/logo.png"
	Local cNomeEmp	 	:= AllTrim(SM0->M0_NOME) + "-" + AllTrim(SM0->M0_FILIAL)
	Local cLinkSit 	:= "http://www.grupouniaosa.com.br/"	 
	Local aAreaSA2		:= SA2->(GetArea())
	
	cScryptHtml := '	<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word"'
	cScryptHtml += '	xmlns="http://www.w3.org/TR/REC-html40">'
	cScryptHtml += '	<head>'
	cScryptHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
	cScryptHtml += '		<title>Comunicado Orçamento '+SM0->M0_FILIAL+'</title>'

	cScryptHtml += '</head>'
	cScryptHtml += '	<body>'
	cScryptHtml += '<div class="gs">'
	cScryptHtml += '<div class="gE iv gt"></div>'
	cScryptHtml += '<div class="utdU2e"></div><div class="tx78Ic"></div><div class="QqXVeb"></div><div id=":10g" tabindex="-1"></div><div id=":118" class="ii gt adP adO"><div id=":119"><u></u>'
	cScryptHtml += '	<div style="padding:0;margin:0;background:#eaeaea">'
	cScryptHtml += '		<table style="background:#eaeaea;font-family:Lucida grande,Sans-SerIf;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="100%">'
	cScryptHtml += '			<tbody><tr>'
	cScryptHtml += '				<td style="padding:25px 0 55px" align="center">'
	cScryptHtml += '					<table style="padding:0 50px;text-align:left;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="800">'
	cScryptHtml += '		    <tbody><tr>'
	cScryptHtml += '							<td style="padding-bottom:10px">'
	cScryptHtml += '								<img src="'+cLinkImg+'">							</td>'
	cScryptHtml += '						</tr>'
	cScryptHtml += '						<tr>'
	cScryptHtml += '							<td height="400" style="font-size:13px;color:#888;padding:30px 40px;border:1px solid #b8b8b8;background-color:#fff">'
	cScryptHtml += '								<p style="color:black;margin:0">Você acaba de receber um informativo de ' + cNomeEmp +'.</p>'
	cScryptHtml += '				  <div style="background-color:#e3e3e3;padding:20px;color:black;margin:30px 0">'
	cScryptHtml += '									<span style="font-weight:bold;font-size:14px;margin:0">'+::cTitBody+'</span>'
	
	
 	cScryptHtml += '			                        <hr style="margin:15px 0">'
	cScryptHtml += '									<p style="margin:0"></p>'
	
	cScryptHtml += '								<table width="674" border="0">'
	cScryptHtml += '                                      <tr>'
	cScryptHtml += '                                       		<td colspan="3" width="547" style="border 1px black" >' + ::cBody + '</td>'
	cScryptHtml += '                                      </tr>'
	cScryptHtml += '                                 </table>'
	cScryptHtml += '                            <br>'
	
	cScryptHtml += '					          </div>'
	cScryptHtml += '						  <p>Esta notificação foi enviada por um email configurado para não receber resposta.<br>'
	cScryptHtml += '									Por favor, não responda esta mensagem.							  </p>'
	cScryptHtml += '						  </td>'
	cScryptHtml += '						</tr>'
	cScryptHtml += '					</tbody></table>'
	
	cScryptHtml += '	    <p align="center" style="width:640px;padding:10px 20px;font-size:10px;color:#888;line-height:14px">'
	cScryptHtml += '						Para acessar o site da '+cNomeEmp+','
	cScryptHtml += '						<a href="'+cLinkSit+'" style="color:#666;text-decoration:underline" target="_blank">clique aqui.</a>					</p>'
	cScryptHtml += '			  </td>'
	cScryptHtml += '			</tr>'
	cScryptHtml += '		</tbody></table><div class="yj6qo"></div><div class="adL">'
	cScryptHtml += '	</div></div><div class="adL">'
	cScryptHtml += '</div></div></div><div id=":104" class="ii gt" style="display:none"><div id=":103"></div></div><div class="hi"></div></div>'
	cScryptHtml += '		</body>'
	cScryptHtml += '	</html>'
	


	u_EnvEmail(::cEmail, ::cAssunto, cScryptHtml)
	
	RestArea(aAreaSA2)

Return .T.

