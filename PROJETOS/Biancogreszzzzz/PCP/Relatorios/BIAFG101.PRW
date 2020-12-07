#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG101
@author Gabriel Rossi Mafioletti
@since 31/07/2019
@version 1.0
@description Workflow de paradas por recurso
@type function
/*/

User Function BIAFG101()

	Local xv_Emps	:=	U_BAGtEmpr("01")
	Local _nI

	for	_nI	:=	1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[_nI,1], xv_Emps[_nI,2])
		
		ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFG101 " + xv_Emps[_nI,1])
		
		Processa({|| BIAFG101Pr()})
		
		ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFG101 " + xv_Emps[_nI,1])
		
		//Finaliza o ambiente criado
		RpcClearEnv()
	
	next 
	
Return


Static function BIAFG101Pr()

	Local _cAlias	:=	GetNextAlias()
	Local _cHtml	:=	""		
	
	Local _cHora	:=	Time()
	
	Private _cData	
	
	
	
	Private _nTurno
	
	If _cHora >= '06:00:00' .And. _cHora < '14:00:00'
		_cData	:=	Dtos(Date()-1)
		_nTurno	:=	3
	ElseIf _cHora >= '14:00:00' .And. _cHora < '22:00:00'
		_cData	:=	DtoS(Date())
		_nTurno	:=	1
	ElseIf _cHora >= "00:00:00" .And. _cHora < "06:00:00"
		_cData	:=	Dtos(Date()-1)
		_nTurno	:=	2
	Else
		_cData	:=	DtoS(Date())
		_nTurno	:=	2
	EndIF	
	

	BeginSql Alias _cAlias
		%noParser%
		SELECT CASE 
					WHEN A.RECURSO = 'L1CF01' 
						THEN	'Forno 01'
					WHEN A.RECURSO = 'L2CF01' 
						THEN	'Forno 02'
					WHEN A.RECURSO = 'L3CF01' 
						THEN	'Forno 03'
					WHEN A.RECURSO = 'L4CF01' 
						THEN	'Forno 04'
					WHEN A.RECURSO = 'L5CF01' 
						THEN	'Forno 05'	
					ELSE
						A.RECURSO
				END AS RECURSO
			,A.Ocorrencias PARADA
			,CAST(CAST(DateAdd(ms, Tempo, CAST('' AS DATETIME)) AS TIME(0)) AS VARCHAR(30)) TMPPAR
		FROM (
			SELECT RECURSO
				,COUNT(*) Ocorrencias
				,SUM(DateDiff(ms, '00:00:00.000', Cast(tempo AS TIME))) Tempo
			FROM PCF4..VW_BG_StatusRecurso
			WHERE STATUS <> '1401'
				AND Recurso IN (
					'L1CF01'
					,'L2CF01'
					,'L3CF01'
					,'L4CF01'
					,'L5CF01'
					)
				AND DtProd = Cast(%Exp:_cData% as DATETIME)
				AND Turno = %Exp:_nTurno%
			GROUP BY RECURSO
			) A
		ORDER BY 1
	EndSql
	
	
	If (_cAlias)->(!EOF())
		_cHtml		:=	MntHeadHtm()
		While (_cALias)->(!EOF())

			_cHtml	+=	"<tr align='center'>																												"
			_cHtml	+=	'	<td>'	+	(_cAlias)->RECURSO	+ '</td>'
			_cHtml	+=	'	<td>'	+	Alltrim(Str((_cAlias)->PARADA))	+ '</td>'
			_cHtml	+=	'	<td>'	+	(_cAlias)->TMPPAR	+ '</td>'
			_cHtml	+=	'</tr>			
		
			(_cAlias)->(DbSkip())
		EndDo
		_cHtml	+=	'	 </table>                                                                                                                     '
		_cHtml 	+= "		<table align='center' width='500' border='1' cellspacing='0' cellpadding='1'>"
		_cHtml 	+= "          	<tr>"
		_cHtml 	+= "            	<th class = 'tottab' width='500' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BIAFG101).</th>"
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
	_cHead	+=	'    <p align="center">Paradas por Recurso - Dia: '+DtoC(Stod(_cData))+' - Turno: '+Iif(_nTurno==1,"Dia",Iif(_nTurno==2,"Tarde","Noite"))+' </p>                                                              '
	_cHead 	+= 	'         <table align="center" width="500" border="1" cellspacing="0" cellpadding="1">'
	_cHead	+=	'        <tr>                                                                                                               '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Recurso				 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Qtd. de Paradas		 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Tempo Parado			 </th>        '
	_cHead	+=	'        </tr>																												'																												'

return _cHead

static function wfSend(_cHtml)

	Local df_Dest := U_EmailWF('BIAFG101', cEmpAnt)
	Local df_Assu := "Workflow de paradas por recurso"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)
	
return