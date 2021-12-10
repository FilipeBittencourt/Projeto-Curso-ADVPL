#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} tBiaAmbientes
@author Gabriel Rossi Mafioletti
@since 27/10/2021
@version 1.0
@description Job de Integração YMS
@type function
/*/

User Function BIAG0003()

	Local _oWs	
	Local _nI
	Local _aErros	:=	{}
	Local nPeso
	
	RpcSetEnv('01','01')
	
	_oWs	:=	TBiaIntegracaoPesoYMS():New()
	
	_oWs:GetToken()

	If !_oWs:lErro
	
		_oWs:GetPontosControle()
		
		If !_oWs:lErro
		
			If Len(_oWs:aProcessos) > 0

				DbSelectArea("ZLO")
				ZLO->(DbSetOrder(1))
				DbSelectArea("ZLP")
				ZLP->(DbSetOrder(1))
				For _nI	:= 1 To Len(_oWs:aProcessos)
				
					If ZLO->(DbSeek(xFilial("ZLO")+PADR(_oWs:aProcessos[_nI,2],TAMSX3("ZLO_CODIGO")[1])))
					
						If !ZLP->(DbSeek(xFilial("ZLP")+PADR(_oWs:aProcessos[_nI,1],TAMSX3("ZLP_CODPAT")[1])+PADR(_oWs:aProcessos[_nI,2],TAMSX3("ZLP_PCONTR")[1])))
							Reclock("ZLP",.T.)
							ZLP->ZLP_FILIAL	:=	xFilial("ZLP")
							ZLP->ZLP_CODPAT	:=	_oWs:aProcessos[_nI,1]
							ZLP->ZLP_PCONTR	:=	_oWs:aProcessos[_nI,2]
							ZLP->ZLP_PLACA	:=	_oWs:aProcessos[_nI,3]
							ZLP->ZLP_DATA	:=	Date()
							ZLP->(MsUnlock())
						EndIf
						
						Do Case
							Case ZLO->ZLO_TIPO $ '1/2' //Balança Automatica de Entrada ou Saída
								//Busca a Pesagem na ZLW
								If fGetPeso(ZLO->ZLO_TIPO,ZLP->ZLP_PLACA,@nPeso)
									//Inicia a Pesagem
									If ZLP->ZLP_STINIC $ " /E"
										
										//Consome WS Inicio
										_oWs:IniciaBalancaAutomatica(ZLP->ZLP_CODPAT)
										If !_oWs:lErro
											Reclock("ZLP",.F.)
											ZLP->ZLP_DHINIC	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
											ZLP->ZLP_STINIC := "P"
											ZLP->ZLP_ENVINI := _oWs:cSend
											ZLP->ZLP_RETINI	:= _oWs:cRet
											ZLP->(MsUnlock())
										Else
											Reclock("ZLP",.F.)
											ZLP->ZLP_DHINIC	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
											ZLP->ZLP_STINIC := "E"
											ZLP->ZLP_ENVINI := _oWs:cSend
											ZLP->ZLP_RETINI	:= _oWs:cRet
											ZLP->ZLP_ERRO	:= _oWs:cErro
											If Empty(ZLP->ZLP_DATAWF) .Or. fElapMin(ZLP->ZLP_DATAWF,ZLP->ZLP_HRWF)
												ZLP->ZLP_DATAWF	:=	Date()
												ZLP->ZLP_HRWF	:=	Time()
												aAdd(_aErros,{ZLO->ZLO_DESCRI,ZLP->ZLP_PLACA,_oWs:cErro})
											EndIf
											ZLP->(MsUnlock())
										EndIf
									
									EndIf
									//Finaliza a Pesagem
									If ZLP->ZLP_STINIC == "P" .And. ZLP->ZLP_STFIM $ " /E"
										
										//Consome WS Fim
										_oWs:FinalizaBalancaAutomatica(ZLP->ZLP_CODPAT,nPeso)
										If !_oWs:lErro
											Reclock("ZLP",.F.)
											ZLP->ZLP_DHFIM	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
											ZLP->ZLP_STFIM := "P"
											ZLP->ZLP_ENVFIM := _oWs:cSend
											ZLP->ZLP_RETFIM	:= _oWs:cRet
											ZLP->(MsUnlock())
										Else
											Reclock("ZLP",.F.)
											ZLP->ZLP_DHFIM	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
											ZLP->ZLP_STFIM := "E"
											ZLP->ZLP_ENVFIM := _oWs:cSend
											ZLP->ZLP_RETFIM	:= _oWs:cRet
											ZLP->ZLP_ERRO	:= _oWs:cErro
											If Empty(ZLP->ZLP_DATAWF) .Or. fElapMin(ZLP->ZLP_DATAWF,ZLP->ZLP_HRWF)
												ZLP->ZLP_DATAWF	:=	Date()
												ZLP->ZLP_HRWF	:=	Time()
												aAdd(_aErros,{ZLO->ZLO_DESCRI,ZLP->ZLP_PLACA,_oWs:cErro})
											EndIf
											ZLP->(MsUnlock())

										EndIf
										
										
									EndIf
								Else
									Reclock("ZLP",.F.)
									ZLP->ZLP_ERRO	:= "Peso não encontrado!"	
									If Empty(ZLP->ZLP_DATAWF) .Or. fElapMin(ZLP->ZLP_DATAWF,ZLP->ZLP_HRWF)
										ZLP->ZLP_DATAWF	:=	Date()
										ZLP->ZLP_HRWF	:=	Time()
										aAdd(_aErros,{ZLO->ZLO_DESCRI, ZLP->ZLP_PLACA,"Peso não encontrado!"})
									EndIf
									ZLP->(MsUnlock())
								EndIf
						EndCase
						
					Else
						aAdd(_aErros,{Alltrim(_oWs:aProcessos[_nI,2]),_oWs:aProcessos[_nI,3],"Ponto de Controle Inexistente"} )
					EndIf
				Next
			EndIf
		
		EndIf
	
		_oWs:GetAguardandoSaida()
		
		If !_oWs:lErro
		
			If Len(_oWs:aProcessos) > 0
			
				For _nI	:= 1 To Len(_oWs:aProcessos)
			
					DbSelectArea("ZLP")
					ZLP->(DbSetOrder(1))
					If !ZLP->(DbSeek(xFilial("ZLP")+PADR(_oWs:aProcessos[_nI,1],TAMSX3("ZLP_CODPAT")[1])+PADR(_oWs:aProcessos[_nI,2],TAMSX3("ZLP_PCONTR")[1])))
						Reclock("ZLP",.T.)
						ZLP->ZLP_FILIAL	:=	xFilial("ZLP")
						ZLP->ZLP_CODPAT	:=	_oWs:aProcessos[_nI,1]
						ZLP->ZLP_PCONTR	:=	_oWs:aProcessos[_nI,2]
						ZLP->ZLP_PLACA	:=	_oWs:aProcessos[_nI,3]
						ZLP->ZLP_DATA	:=	Date()
						ZLP->(MsUnlock())
					EndIf

					If ZLP->ZLP_STINIC $ " /E"
					
						_oWs:IniciaPortariaSaida(ZLP->ZLP_CODPAT)

						If !_oWs:lErro
							_oWs:AutorizaPortariaSaida(ZLP->ZLP_CODPAT)
							If !_oWs:lErro
								Reclock("ZLP",.F.)
								ZLP->ZLP_DHINIC	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
								ZLP->ZLP_STINIC := "P"
								ZLP->ZLP_ENVINI := _oWs:cSend
								ZLP->ZLP_RETINI	:= _oWs:cRet
								ZLP->(MsUnlock())
							Else
								Reclock("ZLP",.F.)
								ZLP->ZLP_DHINIC	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
								ZLP->ZLP_STINIC := "E"
								ZLP->ZLP_ENVINI := _oWs:cSend
								ZLP->ZLP_RETINI	:= _oWs:cRet
								ZLP->ZLP_ERRO	:= _oWs:cErro
								If Empty(ZLP->ZLP_DATAWF) .Or. fElapMin(ZLP->ZLP_DATAWF,ZLP->ZLP_HRWF)
									ZLP->ZLP_DATAWF	:=	Date()
									ZLP->ZLP_HRWF	:=	Time()
									aAdd(_aErros,{"PORTARIA",ZLP->ZLP_PLACA,_oWs:cErro})
								EndIf
								ZLP->(MsUnlock())							
							EndIf
						Else
							Reclock("ZLP",.F.)
							ZLP->ZLP_DHINIC	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
							ZLP->ZLP_STINIC := "E"
							ZLP->ZLP_ENVINI := _oWs:cSend
							ZLP->ZLP_RETINI	:= _oWs:cRet
							ZLP->ZLP_ERRO	:= _oWs:cErro
							If Empty(ZLP->ZLP_DATAWF) .Or. fElapMin(ZLP->ZLP_DATAWF,ZLP->ZLP_HRWF)
								ZLP->ZLP_DATAWF	:=	Date()
								ZLP->ZLP_HRWF	:=	Time()
								aAdd(_aErros,{"PORTARIA",ZLP->ZLP_PLACA,_oWs:cErro})
							EndIf
							ZLP->(MsUnlock())
						EndIf
					
					EndIf
					If ZLP->ZLP_STINIC == "P" .And. ZLP->ZLP_STFIM $ " /E"
						
						//Consome WS Fim
						_oWs:FinalizaPortariaSaida(ZLP->ZLP_CODPAT)
						If !_oWs:lErro
							Reclock("ZLP",.F.)
							ZLP->ZLP_DHFIM	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
							ZLP->ZLP_STFIM := "P"
							ZLP->ZLP_ENVFIM := _oWs:cSend
							ZLP->ZLP_RETFIM	:= _oWs:cRet
							ZLP->(MsUnlock())
						Else
							Reclock("ZLP",.F.)
							ZLP->ZLP_DHFIM	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
							ZLP->ZLP_STFIM := "E"
							ZLP->ZLP_ENVFIM := _oWs:cSend
							ZLP->ZLP_RETFIM	:= _oWs:cRet
							ZLP->ZLP_ERRO	:= _oWs:cErro
							If Empty(ZLP->ZLP_DATAWF) .Or. fElapMin(ZLP->ZLP_DATAWF,ZLP->ZLP_HRWF)
								ZLP->ZLP_DATAWF	:=	Date()
								ZLP->ZLP_HRWF	:=	Time()
								aAdd(_aErros,{"PORTARIA",ZLP->ZLP_PLACA,_oWs:cErro})
							EndIf
							ZLP->(MsUnlock())
						EndIf
						
						
					EndIf
					
					
				Next
			EndIf
		EndIf
	EndIf
	
	If Len(_aErros) > 0
		fSendWf(_aErros)
	EndIf
	
	RpcClearEnv()
Return


Static Function fGetPeso(cTipo,cPlaca,nPeso)

	Local _cAlias	:=	GetNextAlias()
	
	Local _cDataAte	:=	Dtos(Date())
	Local _cDataDe	:=	DtoS(Date())
	
	Local _cTpOper	:=	Iif(cTipo == "1","2","3")
	
	Local _lFind	:=	.F.
	
	BeginSql Alias _cAlias
		SELECT TOP 1 ZLW_PESOCA PESO
		FROM %TABLE:ZLW%
		WHERE ZLW_PLACAV = %Exp:cPlaca%
			AND ZLW_TPOPER = %Exp:_cTpOper%
			AND ZLW_DATA BETWEEN %Exp:_cDataDe%
				AND %Exp:_cDataAte%
			AND %NotDel%
		ORDER BY ZLW_DATA DESC
	EndSql

	If (_cAlias)->(!EOF())
		nPeso	:=	(_cAlias)->PESO
		_lFind	:=	.T.
	Else
		nPeso	:=	0
	EndIf
	(_cAlias)->(DbCloseArea())

Return _lFind

Static Function fSendWf(_aErros)

	Local _cHtml	:=	MntHeadHtm()
	Local _nI

	For _nI	:=	1 to Len(_aErros)

		_cHtml	+=	'<tr>																												'
		_cHtml	+=	'	<td><div align="left">'	+	_aErros[_nI,1]						+ '</div></td>'
		_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,2]		+ '</div></td>'
		_cHtml	+=	'	<td><div align="left">'	+	_aErros[_nI,3]						+ '</div></td>'
		_cHtml	+=	'</tr>

	Next

	_cHtml	+=	'	 </table>          '
	_cHtml	+=	'	<p>by BIAG0003</p> '
	_cHtml	+=	'	</body>            '
	_cHtml	+=	'	</html>            '

	wfSend(_cHtml)
	

Return

static function wfSend(_cHtml)

	Local df_Dest := U_EmailWF('BIAG0003', cEmpAnt)
	Local df_Assu := "Log de Erros na Integração de Pesagem YMS"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!"

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)

return

Static Function fElapMin(dDtRef,cHrRef)

	Local _lSend	:=	.F.

	If dDtRef <> Date()
		_lSend	:=	.T.
	ElseIf Elaptime(cHrRef,Time()) > "01:00:00"
		_lSend	:=	.T.
	EndIf

Return _lSend

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
	_cHead	+=	'	<p>Erros Encontrados Durante a Integração de Pesagem YMS</p>														    '
	_cHead	+=	'	<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000" >										'
	_cHead	+=	'		<tr>																													'
	_cHead	+=	'			<th height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Ponto de Controle																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Placa																							'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Erro																								'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'		</tr> 																													'




return _cHead
