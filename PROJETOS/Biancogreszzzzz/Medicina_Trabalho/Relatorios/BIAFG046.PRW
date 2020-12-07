#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG046
@author Gabriel Rossi Mafioletti
@since 03/07/2018
@version 1.0
@description Workflow de Funcionários sem Riscos Cadastrados
@type function
/*/

User Function BIAFG046()


	Local _aEmps
	Local _nI
	
	RpcSetType(3)
	RpcSetEnv("01",'01')

	_aEmps	:=	fGetEmps()

	For _nI	:=	1 to Len(_aEmps)

		RpcSetEnv(_aEmps[_nI,1],"01")

		fGeraDados(_aEmps[_nI,2])

		RpcClearEnv()

	Next
	
	RpcClearEnv()
Return


Static Function fGetEmps()

	Local _aEmps	:=	{}
	Local _aArea	:=	GetArea()

	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(DbGoTop())

	While SM0->(!EOF())
		If AllTrim(SM0->M0_CODIGO) <> '02' .And. aScan(_aEmps,{|x| x[1] == Alltrim(SM0->M0_CODIGO)}) == 0
			If Alltrim(SM0->M0_CODIGO) == '01' .OR.  ( Dtos(Date()) >= '20180901') 
				aAdd(_aEmps,{Alltrim(SM0->M0_CODIGO),Alltrim(SM0->M0_NOME)})
			EndIf
		EndIf
		SM0->(DbSkip())
	EndDo

	RestArea(_aArea)

Return _aEmps

Static Function fGeraDados(_cDesEmp)

	Local _cHtml	
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
	%NoParser%
	
		SELECT *
		FROM (
			SELECT RA_FILIAL
				,RA_MAT
				,RA_NOME
				,RA_DEPTO
				,SQB.QB_DESCRIC
				,RA_CODFUNC
				,SRJ.RJ_DESC
				,(
					SELECT COUNT(*)
					FROM %TABLE:TN0% TN0
					WHERE (
							SRA.RA_CODFUNC = TN0.TN0_CODFUN
							OR TN0_CODFUN = '*'
							)
						AND (
							SRA.RA_DEPTO = TN0.TN0_DEPTO
							OR TN0.TN0_DEPTO = '*'
							)
						AND TN0.TN0_DTELIM = ''
						AND TN0.%NotDel%
					) QTD
			FROM %TABLE:SRA% SRA
			JOIN %TABLE:SRJ% SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC
				AND SRJ.%NotDel%
			JOIN SQB010 SQB ON SQB.QB_DEPTO = SRA.RA_DEPTO
				AND SQB.%NotDel%
			WHERE SRA.RA_DEMISSA = ''
				AND SRA.RA_PROCES = '00001'
				AND SRA.RA_MAT < '100000'
				AND SRA.%NotDel%
			) A
		WHERE QTD = 0
		ORDER BY RA_FILIAL, RA_MAT
	
	EndSql

	If (_cAlias)->(!EOF())
		_cHtml :=	fGeraCab(_cDesEmp)
		While (_cAlias)->(!EOF())
			_cHtml	+=	'<tr>																												'
			_cHtml	+=	'	<td><div align="center">'+	(_cAlias)->RA_FILIAL													+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'+	(_cAlias)->RA_MAT																+ '</div></td>'
			_cHtml	+=	'	<td><div align="left">'	+	(_cAlias)->RA_NOME															+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'+	(_cAlias)->RA_DEPTO															+ '</div></td>'
			_cHtml	+=	'	<td><div align="left">'	+	(_cAlias)->QB_DESCRIC															+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'+	(_cAlias)->RA_CODFUNC															+ '</div></td>'
			_cHtml	+=	'	<td><div align="left">'	+	(_cAlias)->RJ_DESC															+ '</div></td>'
						
			_cHtml	+=	'</tr>
			(_cAlias)->(DbSkip())
		EndDo
		_cHtml	+=	'	 </table>                                                                                                                     '
		_cHtml	+=	'	<p>by BIAFG046</p> '
		_cHtml	+=	'	</body>                                                                                                                       '
		_cHtml	+=	'	</html>  

	EndIf

	If !Empty(_cHtml)
		WfSend(_cHtml)
	EndIF

Return


Static Function fGeraCab(_cDesEmp)

Local _cHtml	:=	""

	_cHtml	+=	'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">	'
	_cHtml	+=	'<html xmlns="http://www.w3.org/1999/xhtml">																					'
	_cHtml	+=	'<head>																														'
	_cHtml	+=	'	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />													'
	_cHtml	+=	'	<title>Untitled Document</title>																						'
	_cHtml	+=	'	<style type="text/css">																									'
	_cHtml	+=	'		<!--																												'
	_cHtml	+=	'		.style1 {color: #000000; font: bold 20px Times New Roman; text-decoration: underline }								'
	_cHtml	+=	'		.style3 {color: #000000; }																							'
	_cHtml	+=	'		.style4 {color: #FFFFFF; background-color:#000066; }																'
	_cHtml	+=	'		.style5 {color: #FF0000; }																							'
	_cHtml	+=	'		-->																													'
	_cHtml	+=	'	</style>																												'
	_cHtml	+=	'</head>																														'
	_cHtml	+=	'<body>																														'
	_cHtml	+=	'	<p align="center" class="style1">Funcionários sem cadastro de Risco - ' + _cDesEmp + '</p>													'
	_cHtml	+=	'	<table width="1143" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000" align="center" >					'
	_cHtml	+=	'		<tr>																												'
	_cHtml	+=	'			<th width="100" height="21" scope="col">																		'
	_cHtml	+=	'				<div align="center" class="style4">																			'
	_cHtml	+=	'					Filial																									'
	_cHtml	+=	'				</div>																										'
	_cHtml	+=	'			</th>																											'
	_cHtml	+=	'			<th width="100" height="21" scope="col">																		'
	_cHtml	+=	'				<div align="center" class="style4">																			'
	_cHtml	+=	'					Matrícula																								'
	_cHtml	+=	'				</div>																										'
	_cHtml	+=	'			</th>																											'
	_cHtml	+=	'			<th width="110" height="21" scope="col">																		'
	_cHtml	+=	'				<div align="center" class="style4">																			'
	_cHtml	+=	'					Nome																									'
	_cHtml	+=	'				</div>																										'
	_cHtml	+=	'			</th>																											'
	_cHtml	+=	'			<th width="150" height="21"  scope="col">																		'
	_cHtml	+=	'				<div align="center" class="style4">																			'
	_cHtml	+=	'					Departamento																							'
	_cHtml	+=	'				</div>																										'
	_cHtml	+=	'			</th>																											'
	_cHtml	+=	'			<th width="100" height="21"  scope="col">																		'
	_cHtml	+=	'				<div align="center" class="style4">																			'
	_cHtml	+=	'					Descrição																								'
	_cHtml	+=	'				</div>																										'
	_cHtml	+=	'			</th>																											'
	_cHtml	+=	'			<th width="100" height="21"  scope="col">																		'
	_cHtml	+=	'				<div align="center" class="style4">																			'
	_cHtml	+=	'					Função																									'
	_cHtml	+=	'				</div>																										'
	_cHtml	+=	'			</th>																											'
	_cHtml	+=	'			<th width="100" height="21"  scope="col">																		'
	_cHtml	+=	'				<div align="center" class="style4">																			'
	_cHtml	+=	'					Descrição																								'
	_cHtml	+=	'				</div>																										'
	_cHtml	+=	'			</th>																											'
	_cHtml	+=	'		</tr> 																												'

Return _cHtml

static function wfSend(_cHtml)
	Local df_Dest := U_EmailWF('BIAFG046', cEmpAnt)
	Local df_Assu := "Workflow de Funcionários sem Riscos Cadastrados "
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)	
return