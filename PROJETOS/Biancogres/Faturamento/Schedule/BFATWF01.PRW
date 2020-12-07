#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} BFATWF01
@description Workflow de aprovacao de proposta de engenharia	
@author Fernando Rocha
@since 14/03/2014
@version 1.0
@type function
/*/
User Function BFATWF01()

	Local cAliasTmp  
	Local nValTot
	Local nQtdTot
	Local nFreTot

	Private cHtml := ''
	Private _cAteMail := ""    
	Private _cAprMail := ""

	Private _nFrtTon
	Private _nFrtItem := ""
	Private _nPesoItem := ""
	Private _nPesoTot := ""
	Private _nFrtUni:= ""

	SA3->(DbSetOrder(1))
	SA3->(DbSeek(XFilial("SA3")+Z68->Z68_CODVEN))

	ZZO->(DbSetOrder(1))
	ZZO->(DbSeek(XFilial("ZZO")+Z68->Z68_NUMZZO))

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(XFilial("SA3")+Z68->Z68_CODCLI+Z68->Z68_LOJCLI))

	GetHeader()
	GetColumnH()

	nValTot := 0
	nQtdTot := 0
	nFreTot := 0
	_nPesoTot := 0

	_nFrtTon := Z68->Z68_FRTUNI

	Z69->(DbSetOrder(1))
	If Z69->(DbSeek(XFilial("Z69")+Z68->Z68_NUM+Z68->Z68_REV))

		While !Z69->(Eof()) .And. Z69->(Z69_FILIAL+Z69_NUM+Z69_REV) == (xFilial("Z69")+Z68->Z68_NUM+Z68->Z68_REV)

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(XFilial("SB1")+Z69->Z69_CODPRO))

			If Empty(_cAteMail)

				ZZ7->(DbSetOrder(1))
				If ZZ7->(DbSeek(XFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ))

					cAliasTmp := GetNextAlias()			
					BeginSql Alias cAliasTmp
						%NOPARSER%
						SELECT TOP 1 ZZI_ATENDE FROM VW_SAP_ZZI WHERE MARCA = %EXP:ZZ7->ZZ7_EMP% AND ZZI_VEND = %EXP:Z68->Z68_CODVEN% and ZZI_TPSEG = %EXP:"E"%
					EndSql 

					If !(cAliasTmp)->(Eof())

						PswOrder(1)
						If (PswSeek((cAliasTmp)->ZZI_ATENDE, .T.))
							aUser := Pswret(1)  
							_cAteMail := AllTrim(aUser[1][14])
						EndIf

					EndIf
					(cAliasTmp)->(DbCloseArea())

				EndIf

			EndIf

			nValTot 	+= Z69->Z69_VALOR
			nQtdTot 	+= Z69->Z69_QTDVEN

			_nFrtItem 	:= (( SB1->B1_PESO * Z69->Z69_QTDVEN )/1000) * _nFrtTon 
			nFreTot 	+= _nFrtItem

			_nPesoItem 	:= ROUND((SB1->B1_PESO * Z69->Z69_QTDVEN )/1000,2)
			_nPesoTot 	+= _nPesoItem
			
			_nFrtUni	:= ROUND((_nFrtTon * ((SB1->B1_PESO * Z69->Z69_QTDVEN)/1000))/Z69->Z69_QTDVEN,2)

			GetItems()

			Z69->(DbSkip())
		EndDo

		//Linha de Total
		cHtml += " 			<tr align=center>"                                                      
		cHtml += "          	<td class='cabtab' width='20'scope='col'>Total</td>"
		cHtml += "          	<td class='cabtab' width='100'scope='col'></td>"
		cHtml += "          	<td class='cabtab' width='20'scope='col'>"+ Transform(nQtdTot,"@E 999,999.99") +"</td>"
		cHtml += "          	<td class='cabtab' width='20'scope='col'></td>"
		cHtml += "          	<td class='cabtab' width='20'scope='col'></td>"
		cHtml += "          	<td class='cabtab' width='20'scope='col'>"+ Transform(nValTot,"@E 999,999.99") +"</td>"
		cHtml += "          	<td class='cabtab' width='20'scope='col'>"+ Transform(_nPesoTot,"@E 999,999.99") +"</td>"
		cHtml += "          	<td class='cabtab' width='20'scope='col'>"+ Transform(nFreTot,"@E 999,999.99") +"</td>"
		cHtml += "          	<td class='cabtab' width='20'scope='col'></td>"
		cHtml += "          </tr>

	EndIf  

	GetObs()

	cHtml += ' </table>'
	GetFooter()             

	If ( AllTrim(Z68->Z68_USUAPR) <> "AUTO" )
		PswOrder(2)
		If (PswSeek(Z68->Z68_USUAPR, .T.))
			aUser := Pswret(1)  
			_cAprMail := AllTrim(aUser[1][14])
		EndIf
	EndIf

	If SendMail()   
		MsgInfo("Email enviado com sucesso.","BFATTE01")
		Return(.T.)
	Else 
		MsgAlert("Atenção! Falha ao enviar e-mail para o representante.","BFATTE01")	
	EndIf

Return(.F.)

Static Function GetHeader()

	cHtml := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	cHtml += '   <html xmlns="http://www.w3.org/1999/xhtml"> '
	cHtml += '      <head> '
	cHtml += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	cHtml += '         <title>cabtitpag</title> '
	cHtml += '         <style type="text/css"> '
	cHtml += '			<!-- '
	cHtml += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif} '
	cHtml += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif} '
	cHtml += '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;} '
	cHtml += '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif} '
	cHtml += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif} '
	cHtml += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;} '
	cHtml += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif} '
	cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif } '
	cHtml += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif } '
	cHtml += '			--> '
	cHtml += '         </style> '
	cHtml += '      </head> '
	cHtml += '      <body> '

Return()

Static Function GetColumnH()

	Local _cTxtStatus := IIF(Z68->Z68_STATUS=="2","APROVADA","REJEITADA")

	cHtml += '         <p><div class = "headTexto">PREZADO REPRESENTANTE: '+AllTrim(SA3->A3_NOME)+'</div></p> '
	cHtml += '         <p/> '
	cHtml += '         <p><div class = "headTexto1">A proposta número: '+Z68->Z68_NUM+'/'+Z68->Z68_REV+' foi '+_cTxtStatus+IIF(Z68->Z68_TIPAPR == "2"," - COM ALTERAÇÃO","")+'</div></p> '
	cHtml += '         <p/> '
	cHtml += '         <p><div class = "headTexto1">Obra: '+ZZO->ZZO_OBRA+'</div></p> '
	cHtml += '         <p/> '
	cHtml += '         <p><div class = "headTexto1">Cliente: '+SA1->A1_NOME+'</div></p> '
	cHtml += '         <p/> '
	cHtml += '         <p><div class = "headTexto1">Condição de Pagamento: '+Z68->Z68_COND+'-'+Posicione("SE4",1,XFilial("SE4")+Z68->Z68_COND,"E4_DESCRI")+'</div></p> '
	cHtml += '         <p/> '
	cHtml += '         <p><div class = "headTexto1">Data de Validade: '+DTOC(Z68->Z68_DTVALI)+'</div></p> '
	cHtml += '         <p/> '
	cHtml += '         <p/> '
	cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1"> '
	cHtml += '            <tr align=center> '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Item </th> '
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Produto </th> '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Qtde </th> '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Dt.Necessidade </th> '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Pr.Unitário </th> '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Valor </th> '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Peso(T) </th> '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Frete Est. </th> '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Frete/m2 </th> '
	cHtml += '            </tr> '

Return()


Static Function GetItems()

	cHtml += " 			<tr align=center> "                                                      
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Z69->Z69_ITEM +"</td> "
	cHtml += "          	<td class='style12' width='100'scope='col'>"+ AllTrim(SB1->B1_DESC) +"</td> "
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(Z69->Z69_QTDVEN,"@E 999,999.99") +"</td> "
	cHtml += "              <td class='style12' width='40'scope='col'>"+ DTOC(Z69->Z69_DTNECE) +"</td> "
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(Z69->Z69_PRCVEN,"@E 999,999.99") +"</td> "
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(Z69->Z69_VALOR,"@E 999,999.99") +"</td> "
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(_nPesoItem,"@E 999,999.99") +"</td> "
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(_nFrtItem,"@E 999,999.99") +"</td> "
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(_nFrtUni,"@E 999,999.99") +"</td> "
	cHtml += "          </tr> "

Return() 

Static Function GetObs()

	Local cObs := AllTrim(Z68->Z68_OBSAPR)

	If _nFrtTon > 0

		cObs += CRLF + "Valores de Frete FOB, estimados para a região."

	EndIF

	cHtml += " 			<tr align=center> "                                                      
	cHtml += "          	<td class='cabtab' width='50' scope='col'>Observação do Aprovador:</td> "
	cHtml += "          	<td class='style12' width='100%' scope='col' colspan=8>"+cObs+"</td> "
	cHtml += "          </tr> "

Return()


Static Function GetFooter()

	cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'> "
	cHtml += "          <tr> "
	cHtml += "            <th class = 'tottab' width='100%' scope='col'>A data de disponibilidade dos produtos será confirmada no momento da implantação do pedido no sistema.</th> "
	cHtml += "			</tr> "
	cHtml += "          <tr> "
	cHtml += "            <th class = 'tottab' width='100%' scope='col'>E-mail enviado automaticamente pelo sistema Protheus (BFATWF01).</th> "
	cHtml += "			</tr> "
	cHtml += "		</table> "
	cHtml += "      </body> "
	cHtml += "   </html> "

Return()

Static Function SendMail()
	Local _lRet  
	Local _cFrom := ""
	Local _cTo := ""
	Local _cSubject := ""
	Local _cBody := ""
	Local _cCC := ""  

	Local _cTxtStatus := IIF(Z68->Z68_STATUS=="2","Aprovação","Rejeição")

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))
	_cSubject := _cTxtStatus+" da Proposta - "+ AllTrim(Z68->Z68_NUM) + IIF(Z68->Z68_TIPAPR == "2"," - COM ALTERAÇÃO","")

	If Upper(AllTrim(getenvserver())) $ "PRODUCAO###REMOTO###SCHEDULE"
		If !Empty(SA3->A3_EMAIL)
			_cTo := AllTrim(SA3->A3_EMAIL) 
			If !Empty(_cAteMail)
				_cTo += ";"+_cAteMail
			EndIf
		Else
			_cTo := _cAteMail
			_cSubject := "Email Representante não cadastrado! "+_cSubject
		EndIf 

		_cCC := U_EmailWF("BFATWF01",CEMPANT)
	Else
		_cSubject += " [TESTE]"
		_cTo := "fernando@facilesistemas.com.br"

		If !("FERNANDO" $ Upper(AllTrim(getenvserver())))
			If !Empty(_cAteMail)
				_cTo += ";"+_cAteMail
			EndIf
		EndIf 

		_cCC := U_EmailWF("BFATWF01",CEMPANT)
	EndIf      

	If !Empty(_cCC)
		_cCC += ";"
	EndIf
	_cCC += _cAprMail

	_cBody := cHtml      

	If !Empty(_cTo)
		_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)
	Else 
		_lRet := .F.
	EndIf

Return(_lRet)