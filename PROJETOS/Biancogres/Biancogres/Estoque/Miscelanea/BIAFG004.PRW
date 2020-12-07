#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} BIAFG004
@author Gabriel Rossi Mafioletti
@since 05/06/2017
@version 1.0
@description Workflow de Produtos importados e ainda não 
				disponibilizados para distribuição há mais de 1 dia
@type function
/*/


User function BIAFG004()

	Local xv_Emps	:=	U_BAGtEmpr("01_05")
	Local _nI

	for	_nI	:=	1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[_nI,1], xv_Emps[_nI,2])
		
		ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFG004 " + xv_Emps[_nI,1])
		
		Processa({|| BIAFG004Pr()})
		
		ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFG004 " + xv_Emps[_nI,1])
		
		//Finaliza o ambiente criado
		RpcClearEnv()
	
	next 
	
return

Static function BIAFG004Pr()

	Local _cAlias	:=	GetNextAlias()
	Local _cHtml	:=	""		
	
	BeginSql Alias _cAlias
		%noParser%
	
		WITH    LOTRESTRIT
	          AS ( SELECT   ZZ9_PRODUT ,
	                        ZZ9_LOTE ,
	                        ZZ9_RESTRI,
	                        ZZ9_OBS
	               FROM     %TABLE:ZZ9%
	               WHERE    ZZ9_FILIAL = %xFilial:ZZ9%
	                        AND ZZ9_RESTRI = '#'
	                        AND %NotDel%
	             )
	    SELECT  DA_DATA ,
	            DA_DOC ,
	            DA_PRODUTO ,
	            DA_LOTECTL ,
	            ZZ9_RESTRI ,
	            ZZ9_OBS,
	            DA_QTDORI ,
	            DA_SALDO,
	            DATEDIFF(dd,DA_DATA,GETDATE()) DIAS
	    FROM    %TABLE:SDA% SDA
	            INNER JOIN LOTRESTRIT LRT ON ZZ9_PRODUT = DA_PRODUTO
	                                         AND ZZ9_LOTE = DA_LOTECTL
	    WHERE   DA_FILIAL = %xFilial:SDA%
	            AND DA_SALDO <> 0
	            AND DATEDIFF(dd,DA_DATA,GETDATE()) > 1
	            AND SDA.%NotDel%
	
	EndSql

	if (_cAlias)->(!EOF())
		_cHtml		:=	MntHeadHtm()
		while (_cAlias)->(!EOF())
			_cHtml	+=	'<tr>																												'
			_cHtml	+=	'	<td><div align="center">'	+	DtoC(Stod((_cAlias)->DA_DATA))													+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->DA_DOC																+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->DA_PRODUTO															+ '</div></td>'
			_cHtml	+=	'	<td><div align="left">	'	+	Alltrim(POSICIONE("SB1",1,xFilial("SB1")+ (_cAlias)->DA_PRODUTO,"B1_DESC"))		+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->DA_LOTECTL															+ '</div></td>'
			_cHtml	+=	'	<td><div align="right">'	+	Alltrim(Transform((_cAlias)->DA_QTDORI,"@E 999,999,999.99"))					+ '</div></td>'
			_cHtml	+=	'	<td><div align="right">'	+	Alltrim(Transform((_cAlias)->DA_SALDO,"@E 999,999,999.99"))						+ '</div></td>'
			_cHtml	+=	'	<td><div align="right">'	+	Alltrim(Transform((_cAlias)->DIAS,"@E 999,999"))						+ '</div></td>'			
			_cHtml	+=	'	<td><div align="left">	'	+	(_cAlias)->ZZ9_OBS		+ '</div></td>'
			_cHtml	+=	'</tr>																												'
			(_cAlias)->(DbSkip())
		enddo
		_cHtml	+=	'	 </table>                                                                                                                     '
		_cHtml	+=	'	<p>by BIAFG004</p> '
		_cHtml	+=	'	</body>                                                                                                                       '
		_cHtml	+=	'	</html>                                                                                                                       '
	endif
	(_cAlias)->(DbCloseArea())
	If !Empty(_cHtml)
		WfSend(_cHtml)
	EndIf
return

static function MntHeadHtm()

Local _cHead	:=	""

	_cHead	+=	'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		'
	_cHead	+=	'<html xmlns="http://www.w3.org/1999/xhtml">																					'
	_cHead	+=	'<head>																															'
	_cHead	+=	'	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />														'
	_cHead	+=	'	<title>Untitled Document</title>																							'
	_cHead	+=	'	<style type="text/css">																										'
	_cHead	+=	'		<!--																													'
	_cHead	+=	'		.style3 {color: #000000; }																								'
	_cHead	+=	'		.style4 {color: #FFFFFF; }																								'
	_cHead	+=	'		.style5 {color: #FF0000; }																								'
	_cHead	+=	'		-->																														'
	_cHead	+=	'	</style>																													'
	_cHead	+=	'</head>																														'
	_cHead	+=	'<body>																															'
	_cHead	+=	'	<p>Produtos importados e ainda não disponibilizados para distribuição há mais de 1 dia</p>									'
	_cHead	+=	'	<table width="1143" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000" >										'
	_cHead	+=	'		<tr>																													'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Data																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Doc																											'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Cod. Produto																								'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Desc. Produto																								'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Lote																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Qtd.																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Saldo																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Dias																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Obs.																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>			
	_cHead	+=	'		</tr> 																													'

return _cHead


static function wfSend(_cHtml)

	Local df_Dest := U_EmailWF('BIAFG004ALT', cEmpAnt)
	Local df_Assu := "Log de Produtos importados e ainda não disponibilizados para distribuição há mais de 1 dia"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)
	
return