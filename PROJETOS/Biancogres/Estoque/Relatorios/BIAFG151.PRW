#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG151
@author Gabriel Rossi Mafioletti
@since 10/09/2021
@version 1.0
@description Workflow de Produtos em Estoque MD com política diferente em outro almoxarifado
@type function
/*/

User Function BIAFG151()

	Local xv_Emps	:=	U_BAGtEmpr("01")
	Local _nI

	for	_nI	:=	1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[_nI,1], xv_Emps[_nI,2])
		
		ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFG151 " + xv_Emps[_nI,1])
		
		Processa({|| BIAFG151Pr()})
		
		ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFG151 " + xv_Emps[_nI,1])
		
		//Finaliza o ambiente criado
		RpcClearEnv()
	
	next 




Return

Static function BIAFG151Pr()

	Local _cAlias	:=	GetNextAlias()
	Local _cHtml	:=	""		
	Local _cEmpFil	:=	cEmpAnt+cFilAnt

	BeginSql Alias _cAlias
		%noParser%
		SELECT EMPRESA
			,SOLICITANTE
			,NOME
			,CODPRO
			,DESCRI
			,ALMOX
			,SALDO
		FROM VW_BZ_SALDO_MD A
		JOIN %TABLE:ZCN% ZCN(NOLOCK) ON ZCN.ZCN_FILIAL = %XFILIAL:ZCN%
			AND ZCN.ZCN_COD = A.CODPRO
			AND ZCN.ZCN_LOCAL = A.ALMOX
			AND SUBSTRING(ZCN.ZCN_COD,1,1) IN ('2','4')
			AND ZCN.ZCN_POLIT = '4'
			AND ZCN.%NotDel%
		WHERE EMPRESA = %Exp:_cEmpFil%
			AND EXISTS (
				SELECT 1
				FROM %TABLE:ZCN% ZCNFIL(NOLOCK)
				WHERE ZCNFIL.ZCN_FILIAL = ZCN.ZCN_FILIAL
					AND ZCNFIL.ZCN_COD = ZCN.ZCN_COD
					AND ZCNFIL.ZCN_LOCAL <> ZCN.ZCN_LOCAL
					AND NOT (
						AND SUBSTRING(ZCNFIL.ZCN_COD,1,1) IN ('2','4')
						AND ZCNFIL.ZCN_POLIT = '4'
						)
					AND ZCNFIL.%NotDel%
				)
		ORDER BY SOLICITANTE

	EndSql
	
	
	If (_cAlias)->(!EOF())
		_cHtml		:=	MntHeadHtm()
		While (_cALias)->(!EOF())

			_cHtml	+=	"<tr align='center'>																												"
			_cHtml	+=	'	<td>'	+	(_cAlias)->SOLICITANTE	+ '</td>'
			_cHtml	+=	'	<td>'	+	(_cAlias)->NOME	+ '</td>'
			_cHtml	+=	'	<td>'	+	(_cAlias)->CODPRO	+ '</td>'
			_cHtml	+=	'	<td>'	+	(_cAlias)->DESCRI	+ '</td>'
			_cHtml	+=	'	<td>'	+	(_cAlias)->ALMOX	+ '</td>'
			_cHtml	+=	'	<td>'	+	TRANSFORM((_cAlias)->SALDO, "@E 999,999,999.9999")	+ '</td>'
			_cHtml	+=	'</tr>			
		
			(_cAlias)->(DbSkip())
		EndDo
		_cHtml	+=	'	 </table>                                                                                                                     '
		_cHtml 	+= "		<table align='center' width='100%' border='1' cellspacing='0' cellpadding='1'>"
		_cHtml 	+= "          	<tr>"
		_cHtml 	+= "            	<th class = 'tottab' width='100%' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BIAFG151).</th>"
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

static function MntHeadHtm()

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
	_cHead	+=	'    </style>                                                                                                               '
	_cHead	+=	'</head>                                                                                                                    '
	_cHead	+=	'<body>                                                                                                                     '
	_cHead	+=	'    <p align="center"> Divergencia de Politica de MD </p>                                                              '
	_cHead 	+= 	'         <table align="center" width="100%" border="1" cellspacing="0" cellpadding="1">'
	_cHead	+=	'        <tr>                                                                                                               '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Solicitante				 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Nome		 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Cod. Prod.			 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Descrição			 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Almox.			 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Saldo			 </th>        '
	_cHead	+=	'        </tr>																												'																												'

return _cHead

static function wfSend(_cHtml)

	Local df_Dest := U_EmailWF('BIAFG151', cEmpAnt)
	Local df_Assu := "Workflow de Divergência de Política de MD - Empresa "+ cEmpAnt
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)
	
return