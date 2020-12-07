#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#include "topconn.ch"

/*/{Protheus.doc} GPEA040
@author Luana Marin Ribeiro
@since 16/07/2019
@version 1.0
@description O ponto de entrada GPEA040 é executado na validação do plano de contas
@obs Criado inicialmente para controlar a inclusão/alteração de Contas Contábeis de Custo e Despesa sem Pacote GMCD
@type function
/*/

User Function GPEA040() //GPEA040_VERBA
	Local oModel := FWModelActive()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	
	if oModel <> NIL
		nOperation 	:= oModel:GetOperation() //1 - View //3 - Insert //4 - Update //5 - Delete //6 - only Update
	EndIf

	If aParam <> NIL
		
		oObj := aParam[1]
	  	cIdPonto := aParam[2]
	   	cIdModel := aParam[3]
		
		If cIdPonto == 'MODELCOMMITNTTS' .And. nOperation == 3
			Processa({||fProcessa(M->RV_COD,M->RV_DESC,M->RV_LCTOP)})
		EndIf		
	EndIf
	
Return(xRet)

Static Function fProcessa(_cCodVer, _cDscVer, _cLP)

	Local _cAlias	:=	GetNextAlias()
	Local _cHtml	:=	""
	
	BeginSql Alias _cAlias
	SELECT CT5.CT5_SEQUEN AS SEQ
		, CT5.CT5_DESC AS DSC
	FROM %TABLE:CT5% CT5
	WHERE CT5.CT5_FILIAL = %XFILIAL:CT5%
		AND CT5.CT5_STATUS = '1'
		AND CT5.CT5_LANPAD = %Exp:_cLP%
		AND CT5.%NotDel%
	
	EndSql
	
	If (_cAlias)->(!EOF())
		_cHtml		:=	MntHeadHtm(_cCodVer, _cDscVer)
		While (_cALias)->(!EOF())

			_cHtml	+=	"<tr align='center'>																												"
			_cHtml	+=	'	<td>'	+	(_cAlias)->SEQ	+ '</td>'
			_cHtml	+=	'	<td>'	+	(_cAlias)->DSC	+ '</td>'
			_cHtml	+=	'</tr>			
		
			(_cAlias)->(DbSkip())
		EndDo
		_cHtml	+=	'	 </table>                                                                                                                     '
		_cHtml 	+= "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>"
		_cHtml 	+= "          	<tr>"
		_cHtml 	+= "            	<th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (GPEA040).</th>"
		_cHtml 	+= "			</tr>"
		_cHtml 	+= "		</table>"
		_cHtml 	+= "      </body>"
		_cHtml 	+= "   </html>" 

	EndIf
	
	(_cAlias)->(DbCloseArea())
	If !Empty(_cHtml)
		WfSend(_cHtml)
	EndIf
Return

static function MntHeadHtm(_cCodVer, _cDscVer)

Local _cHead	:=	""

	_cHead	:=	'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">	'
	_cHead	+=	'<html xmlns="http://www.w3.org/1999/xhtml">                                                                                '
	_cHead	+=	'<head>                                                                                                                     '
	_cHead	+=	'    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />                                                  '
	_cHead	+=	'    <title>Untitled Document</title>                                                                                       '
	_cHead	+=	'    <style type="text/css">                                                                                                '
	_cHead 	+= '			<!--
	_cHead 	+= '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	_cHead 	+= '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	_cHead 	+= '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
	_cHead 	+= '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
	_cHead 	+= '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	_cHead 	+= '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	_cHead 	+= '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	_cHead 	+= '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	_cHead 	+= '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }
	_cHead 	+= '			-->
	_cHead	+= '    </style>                                                                                                               '
	_cHead	+= '</head>                                                                                                                    '
	_cHead	+= '<body>                                                                                                                     '
	_cHead	+= '    <p>Inclusão de nova VERBA: ' + _cCodVer + ' - ' + _cDscVer + ' </p>                                                              '
	_cHead 	+= '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
	_cHead	+= '        <tr>                                                                                                               '
	_cHead	+= '            <th class = "cabtab" scope="col"> Sequência				 </th>        '
	_cHead	+= '            <th class = "cabtab" scope="col"> Descrição				 </th>        '
	_cHead	+= '        </tr>																												'																												'

return _cHead

static function wfSend(_cHtml)
	Local df_Dest := U_EmailWF('GPEA040_VERBA', cEmpAnt)
	Local df_Assu := "Workflow de inclusão de nova VERBA"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)
	
return