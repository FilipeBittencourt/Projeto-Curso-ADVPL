#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG098
@author Gabriel Rossi Mafioletti
@since 04/07/2019
@version 1.0
@description Workflow de integração das tabelas cTblQuantidade e cTblStatus
@type function
/*/

User Function BIAFG098()

	Local xv_Emps	:=	U_BAGtEmpr("01")
	Local _nI

	for	_nI	:=	1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[_nI,1], xv_Emps[_nI,2])
		
		ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFG098 " + xv_Emps[_nI,1])
		
		Processa({|| BIAFG098Pr()})

		
		ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFG098 " + xv_Emps[_nI,1])
		
		//Finaliza o ambiente criado
		RpcClearEnv()
	
	next 

Return

Static function BIAFG098Pr()

	Local _cAlias	:=	GetNextAlias()
	Local _cHtml	:=	""		
		
	
	Local _cHora	:=	Time()
	
	
	
	Local _aTotais	:=	{}
	Local _nPos
	Local _nI
	
	
	Private _cData
	Private _cTurno
	

	If _cHora >= '06:00:00' .And. _cHora < '14:00:00'
		_cData	:=	Dtos(Date()-1)
		_cTurno	:=	"N"
	ElseIf _cHora >= '14:00:00' .And. _cHora < '22:00:00'
		_cData	:=	DtoS(Date())
		_cTurno	:=	"D"
	ElseIf _cHora >= "00:00:00" .And. _cHora < "06:00:00"
		_cData	:=	Dtos(Date()-1)
		_cTurno	:=	"T"	
	Else
		_cData	:=	DtoS(Date())
		_cTurno	:=	"T"	
	EndIF

	
	BeginSql Alias _cAlias
		%noParser%
	
		Exec SP_INTEGRACAO_PCF4_QUANTIDADE %Exp:_cData%,%Exp:_cTurno%
	
	EndSql
	
	
	If (_cAlias)->(!EOF())
		_cHtml		:=	MntHeadHtm()
		While (_cALias)->(!EOF())

			_nPos	:=	aScan(_atotais,{|x| Alltrim(x[1]) == Alltrim((_cAlias)->COD)})

			If _nPos == 0
				(_cAlias)->(aAdd(_atotais,{COD,NOME,0,0,0,0,0,0,0,0}))
				_nPos	:=	Len(_aTotais)
			EndIf

			Do Case
				CASE Substr((_cAlias)->ORIGEM,1,1) == "1"
					_aTotais[_nPos,3]	:=	(_cAlias)->QTD
				CASE Substr((_cAlias)->ORIGEM,1,1) == "2"
					_aTotais[_nPos,4]	:=	(_cAlias)->QTD
				CASE Substr((_cAlias)->ORIGEM,1,1) == "3"
					_aTotais[_nPos,5]	:=	(_cAlias)->QTD
				CASE Substr((_cAlias)->ORIGEM,1,1) == "4"
					_aTotais[_nPos,6]	:=	(_cAlias)->QTD
				CASE Substr((_cAlias)->ORIGEM,1,1) == "5"
					_aTotais[_nPos,7]	:=	(_cAlias)->QTD
				CASE Substr((_cAlias)->ORIGEM,1,1) == "6"
					_aTotais[_nPos,8]	:=	(_cAlias)->QTD
				CASE Substr((_cAlias)->ORIGEM,1,1) == "7"
					_aTotais[_nPos,9]	:=	(_cAlias)->QTD			
				CASE Substr((_cAlias)->ORIGEM,1,1) == "8"
					_aTotais[_nPos,10]	:=	(_cAlias)->QTD															
			EndCase
			(_cAlias)->(DbSkip())
		EndDo
	
			For _nI	:= 1 to Len(_aTotais)
				_cHtml	+=	"<tr align='center'>																												"
				_cHtml	+=	'	<td>'	+	_atotais[_nI,1]		+ '</td>'
				_cHtml	+=	'	<td>'	+	_atotais[_nI,2]		+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,3],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,4],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,5],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,6],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,7],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,8],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,3]+_atotais[_nI,4]+_atotais[_nI,5]+_atotais[_nI,6]+_atotais[_nI,7]+_atotais[_nI,8],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,9],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'	<td align="right">'	+	Transform(_atotais[_nI,10],"@E 999,999.99")	+ '</td>'
				_cHtml	+=	'</tr>			
			Next

		_cHtml	+=	'	 </table>                                                                                                                     '
		_cHtml 	+= "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>"
		_cHtml 	+= "          	<tr>"
		_cHtml 	+= "            	<th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BIAFG098).</th>"
		_cHtml 	+= "			</tr>"
		_cHtml 	+= "		</table>"
		_cHtml 	+= "      </body>"
		_cHtml 	+= "   </html>" 

	EndIf
	
	(_cAlias)->(DbCloseArea())
	If !Empty(_cHtml)
		WfSend(_cHtml,.F.)
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
	_cHead	+=	'    <p>Data: '+DtoC(Stod(_cData))+' - Turno: '+Iif(_cTurno == "D","Dia",IIF(_cTurno == "T","Tarde", "Noite"))+' </p>                                                              '
	_cHead 	+= 	'         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
	_cHead	+=	'        <tr>                                                                                                               '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Código				 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Nome					 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> 1 Auto-Good [=T]	 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> 2 Auto-Good [-G]				 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> 3 Good	 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> 4 Auto-Scrap	 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> 5 Scrap			 </th>    '
	_cHead	+=	'            <th class = "cabtab" scope="col"> 6 Auto-NoIng				 </th>    '
	_cHead	+=	'            <th class = "cabtab" scope="col"> Total				 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> IntegratedQuantidade	 </th>        '
	_cHead	+=	'            <th class = "cabtab" scope="col"> IntegratedStatus				 </th>        '
	_cHead	+=	'        </tr>																												'																												'

return _cHead

static function wfSend(_cHtml,lHomolog)
	Local df_Dest := U_EmailWF('BIAFG098', cEmpAnt)
	Local df_Assu := "Workflow de integração das tabelas cTblQuantidade e cTblStatus"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	If lHomolog
		df_Assu	:=	"!HOMOLOGAÇÃO! - " + df_Assu
	EndIf

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)
	
return
