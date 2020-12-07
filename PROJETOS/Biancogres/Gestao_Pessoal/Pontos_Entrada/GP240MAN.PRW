#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#include "topconn.ch"

/*/{Protheus.doc} GP240MAN
@author Gabriel Rossi Mafioletti
@since 25/06/2018
@version 1.0
@description Ponto de Entrada após a gravação do Afastamento. Utilizado para enviar Workflow de Afastamento para superior
@type function
/*/

User Function GP240MAN()

	Local _cAlias	
	Local _cHtml	:=	""
	Local _aArea	:=	GetArea()
	
	If PARAMIXB[1] == 4
		
		_cAlias	:=	GetNextAlias()
		BeginSql Alias _cAlias
			SELECT RA_FILIAL
				,RA_MAT
				,RA_NOME
				,R8_DATAINI
				,R8_DATAFIM
				,R8_DURACAO
				,RA_YSEMAIL
				,RA_YMAILCO
				,SR8.R_E_C_N_O_ REG
			FROM %TABLE:SR8% SR8
			JOIN %TABLE:SRA% SRA ON SR8.R8_FILIAL = SRA.RA_FILIAL
				AND SR8.R8_MAT = SRA.RA_MAT
				AND SRA.RA_SITFOLH <> 'D'
				AND SRA.%NOTDEL%
			WHERE SR8.R8_TIPOAFA NOT IN ('001','002')
				AND SR8.R8_FILIAL = %XFILIAL:SR8%
				AND SR8.R8_MAT = %EXP:SR8->R8_MAT%
				AND SR8.R8_YWFSEND <> '1'
				AND SR8.%NOTDEL%
		EndSql

		While (_cAlias)->(!EOF())
			_cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		'
			_cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">																						'
			_cHtml += '<head>																															'
			_cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />															'
			_cHtml += '	<title>Untitled Document</title>																								'
			_cHtml += '	<style type="text/css">																											'
			_cHtml += '		<!--																														'
			_cHtml += '		.style1 {color: #000000; font: bold 20px Times New Roman; text-decoration: underline }									'
			_cHtml += '		.style2 {color: #000000; font: 16px Times New Roman;  text-align: justify; text-justify: inter-word; line-height: 1.5}	'
			_cHtml += '		-->																															'
			_cHtml += '	</style>																														'
			_cHtml += '</head>																															'
			_cHtml += '<body>																															'
			_cHtml += '<p align="center" class="style1">																								'
			_cHtml += '	COMUNICAÇÃO DE AFASTAMENTO																										'
			_cHtml += '</p>																															'
			_cHtml += '<p align="left" class="style2">																								'
			_cHtml += 'Email enviado automaticamente pelo PROTHEUS (Gestão de Pessoal) <br/><br/>																'
			_cHtml += 'Informamos que foi incluído no sistema ATESTADO MÉDICO do colaborador <b>'+Alltrim((_cAlias)->RA_MAT)+ ' - ' +Alltrim((_cAlias)->RA_NOME)+'</b> <br/><br/>			'
			_cHtml += 'Referente ao período de '+DtoC(Stod((_cALias)->R8_DATAINI))+' até '+DtoC(Stod((_cALias)->R8_DATAFIM))+' ('+Alltrim(Str((_cAlias)->R8_DURACAO))+') dia(s).<br/><br/>	'
			_cHtml += 'Empresa: '+Alltrim(FWFilRazSocial())+'. <br/><br/>																										'
			_cHtml += 'Lançador: '+Alltrim(UsrRetName(RetCodUsr()))+'. <br/><br/>
			_cHtml += 'Liderança: '+ Alltrim((_cAlias)->RA_YSEMAIL) +'<br/><br/>																				'
			_cHtml += 'Atenciosamente, <br/>																											'
			_cHtml += 'Setor de Pessoal/RH 	<br/><br/>																									'
			_cHtml += '</p>																															'
			_cHtml += '<p>by GP240MAN</p>																												'
			_cHtml += '</body>																															'
			_cHtml += '</html>		
			wfSend(_cHtml, Alltrim((_cAlias)->RA_YSEMAIL), Alltrim((_cAlias)->RA_YMAILCO))																													'
			SR8->(DbGoTo((_cAlias)->REG))
			Reclock("SR8",.F.)
			SR8->R8_YWFSEND	:=	"1"
			SR8->(MsUnlock())
			(_cAlias)->(DbSkip())
		EndDo
		(_cAlias)->(DbCloseArea())
		
	EndIf
	RestArea(_aArea)
Return

static function wfSend(_cHtml, _cMailSup,_cMailCo)

	Local df_Orig 
	Local df_Dest := Iif(!Empty(_cMailSup),_cMailSup+';','') + Iif(!Empty(_cMailCo),_cMailCo+';','') + U_EmailWF('GP240MAN', cEmpAnt)
	Local df_Assu := "Workflow de inclusão de atestado médico"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)
	
return