#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} BIAFG044
@author Gabriel Rossi Mafioletti
@since 28/05/2018
@version 1.0
@description Workflow de Componentes que Possuem Custo Manual com Nota de Entrada
@type function
/*/


User function BIAFG044()

	Local xv_Emps	:=	U_BAGtEmpr("01_05")
	Local _nI

	for	_nI	:=	1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[_nI,1], xv_Emps[_nI,2])
		
		ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFG044 " + xv_Emps[_nI,1])
		
		Processa({|| BIAFG044Pr()})
		
		ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFG004 " + xv_Emps[_nI,1])
		
		//Finaliza o ambiente criado
		RpcClearEnv()
	
	next 
	
return

Static function BIAFG044Pr()

	Local _cAlias	:=	GetNextAlias()
	Local _cHtml	:=	""		
	Local cNoCfCust := AllTrim(GetNewPar("MV_YCUSCFN","1911,2911,1910,2910")) 

	cNoCfCust := StrTran(cNoCfCust,"/",",") 
	cNoCfCust := StrTran(cNoCfCust,"\",",") 
	cNoCfCust := StrTran(cNoCfCust,"|",",") 
	cNoCfCust := StrTran(cNoCfCust,";",",") 
	
	cNoCfCust := '%' + FormatIn(cNoCfCust,",") + '%'
	
	BeginSql Alias _cAlias
		%noParser%
	
		SELECT PRODS.B1_COD
			,PRODS.B1_DESC
			,PRODS.BZ_YCTREF
			,SD1.D1_VUNIT
			,SD1.D1_DOC
			,SD1.D1_SERIE
			,SD1.D1_DTDIGIT
		FROM (
			SELECT SB1.B1_COD
				,SB1.B1_DESC
				,SBZ.BZ_YCTREF
			FROM %TABLE:SBZ% SBZ
			JOIN %TABLE:SB1% SB1 ON SB1.B1_FILIAL = %XFILIAL:SB1%
				AND SBZ.BZ_FILIAL = %XFILIAL:SBZ%
				AND SB1.B1_COD = SBZ.BZ_COD
				AND SB1.%NotDel%
				AND SB1.B1_MSBLQL <> '1'
			WHERE SBZ.BZ_YCTREF <> 0
				AND EXISTS (
					SELECT 1
					FROM %TABLE:SG1% SG1
					WHERE SG1.G1_FILIAL = %XFILIAL:SG1%
						AND SG1.G1_COMP = SB1.B1_COD
						AND SG1.%NotDel%
					)
				AND SBZ.%NotDel%
			) PRODS
		JOIN %TABLE:SD1% SD1 ON SD1.R_E_C_N_O_ = (
				SELECT TOP 1 SD1.R_E_C_N_O_
				FROM %TABLE:SD1% SD1
				JOIN SF4010 SF4 ON SF4.F4_FILIAL = SD1.D1_FILIAL
					AND SF4.F4_CODIGO = SD1.D1_TES
					AND SF4.%NotDel%
					AND SF4.F4_ESTOQUE = 'S'
				WHERE SD1.D1_FILIAL = %XFILIAL:SD1%
					AND SD1.D1_TP <> 'PI'
					AND SD1.D1_TES NOT IN (
						'397'
						,'3I7'
						)
					AND SD1.D1_CF NOT IN %Exp:cNoCfCust%
					AND SD1.D1_TIPO = 'N'
					AND SD1.D1_QUANT <> 0
					AND SD1.D1_LOCAL = '01'
					AND SD1.D1_DTDIGIT >= '20180101'
					AND SD1.%NotDel%
					AND SD1.D1_COD = PRODS.B1_COD
				ORDER BY D1_DTDIGIT
				)
	
	
	EndSql

	if (_cAlias)->(!EOF())
		_cHtml		:=	MntHeadHtm()
		while (_cAlias)->(!EOF())
			_cHtml	+=	'<tr>																												'
			_cHtml	+=	'	<td><div align="left">'	+	(_cAlias)->B1_COD													+ '</div></td>'
			_cHtml	+=	'	<td><div align="left">'	+	(_cAlias)->B1_DESC													+ '</div></td>'
			_cHtml	+=	'	<td><div align="right">'	+	Alltrim(Transform((_cAlias)->BZ_YCTREF,"@E 999,999,999.99"))		+ '</div></td>'
			_cHtml	+=	'	<td><div align="right">	'	+	Alltrim(Transform((_cAlias)->D1_VUNIT,"@E 999,999,999.99"))		+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->D1_DOC												+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->D1_SERIE					+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'	+	DtoC(SToD((_cAlias)->D1_DTDIGIT))						+ '</div></td>'
			_cHtml	+=	'</tr>																												'
			(_cAlias)->(DbSkip())
		enddo
		_cHtml	+=	'	 </table>                                                                                                                     '
		_cHtml	+=	'	<p>by BIAFG044</p> '
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
	_cHead	+=	'	<p>Componentes que Possuem Custo Manual com Nota de Entrada</p>									'
	_cHead	+=	'	<table width="1143" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000" >										'
	_cHead	+=	'		<tr>																													'
	_cHead	+=	'			<th width="110" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Cod. Produto																								'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="150" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Desc. Produto																								'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="50" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Custo Manual																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="50" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Valor NF																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="100" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Última NF																									'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="30" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Série NF																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="100" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Data NF																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>	
	_cHead	+=	'		</tr> 																													'

return _cHead


static function wfSend(_cHtml)

	Local df_Dest := U_EmailWF('BIAFG044', cEmpAnt)
	Local df_Assu := "Log de Componentes que Possuem Custo Manual com Nota de Entrada"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)
	
return