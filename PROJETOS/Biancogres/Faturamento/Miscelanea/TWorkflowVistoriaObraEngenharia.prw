#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWorkflowVistoriaObraEngenharia
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe para controle do Workflow de Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type class
/*/

Class TWorkflowVistoriaObraEngenharia From LongClassName 
	
	Data dEmiDe
	Data dEmiAte
		
	Method New() Constructor
	Method Process()
	Method GetMessage(cDtVis, cNomCli, cDescObr)
	Method GetMail(cMail_2)	
	Method SendWorkFlow(cDtVis, cCliente, cNomCli, cNumObr, cDescObr, cMail)
	
EndClass


Method New() Class TWorkflowVistoriaObraEngenharia

	::dEmiDe := dDataBase
	::dEmiAte := dDataBase
				
Return()


Method Process() Class TWorkflowVistoriaObraEngenharia
Local cSQL := ""
Local cQry := GetNextAlias()
Local cDtVis := ""
Local cCliente := ""
Local cNomCli := ""
Local cNumObr := ""
Local cDescObr := ""
Local cMail := ""
//Local cMail_1 := ""
Local cMail_2 := ""

	cSQL := " SELECT ZKS_DATPRE, ZKS_CLIENT, ZKS_LOJA, A1_NOME, ZKS_NUMOBR, 
	cSQL += " ISNULL(
	cSQL += " (
	cSQL += " 	SELECT ZZO_OBRA
	cSQL += " 	FROM "+ RetFullName("ZZO", "01")
	cSQL += " 	WHERE ZZO_FILIAL = " + ValToSQL(cFilAnt)
	cSQL += " 	AND ZZO_NUM = ZKS_NUMOBR
	cSQL += " 	AND D_E_L_E_T_ = ''	
	cSQL += " ), '') AS ZZO_OBRA, 
	cSQL += " ZKS_VEND, A3_NOME, A3_YEMAIL, A3_EMAIL
	cSQL += " FROM "+ RetSQLName("ZKS") + " AS ZKS
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " AS SA1
	cSQL += " ON ZKS_CLIENT = A1_COD
	cSQL += " AND ZKS_LOJA = A1_LOJA
	cSQL += " INNER JOIN "+ RetSQLName("SA3") + "  AS SA3
	cSQL += " ON ZKS_VEND = A3_COD
	cSQL += " WHERE ZKS_FILIAL = " + ValToSQL(xFilial("ZKS"))
	cSQL += " AND ZKS_DATA BETWEEN " + ValToSQL(::dEmiDe) + " AND " + ValToSQL(::dEmiAte)
	cSQL += " AND ZKS.D_E_L_E_T_ = '' 
	cSQL += " AND A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " AND SA1.D_E_L_E_T_ = '' 
	cSQL += " AND A3_FILIAL = " + ValToSQL(xFilial("SA3"))
	cSQL += " AND SA3.D_E_L_E_T_ = '' 
	cSQL += " GROUP BY ZKS_DATPRE, ZKS_CLIENT, ZKS_LOJA, A1_NOME, ZKS_NUMOBR, ZKS_VEND, A3_NOME, A3_YEMAIL, A3_EMAIL
	cSQL += " ORDER BY ZKS_DATPRE, ZKS_CLIENT, ZKS_NUMOBR
	
	TcQuery cSQL New Alias (cQry)
		
	While !(cQry)->(Eof())

		cDtVis := (cQry)->ZKS_DATPRE
				
		cCliente := (cQry)->ZKS_CLIENT
		
		cNumObr := (cQry)->ZKS_NUMOBR
		
		cDescObr := (cQry)->ZZO_OBRA

		cNomCli	:= (cQry)->A1_NOME
		
		//cMail_1 := (cQry)->A3_YEMAIL
		
		cMail_2 := (cQry)->A3_EMAIL		

		While cDtVis == (cQry)->ZKS_DATPRE .And. cCliente == (cQry)->ZKS_CLIENT .And. cNumObr == (cQry)->ZKS_NUMOBR
														
			(cQry)->(DbSkip())
			
		EndDo()
		
		If !Empty(cMail := ::GetMail(cMail_2))
		
			::SendWorkFlow(cDtVis, cCliente, cNomCli, cNumObr, cDescObr, cMail)
			
		EndIf

	EndDo()
	
	(cQry)->(DbCloseArea())

Return()


Method GetMail(cMail_2) Class TWorkflowVistoriaObraEngenharia
Local cRet := ""

	If !Empty(AllTrim(cMail_2))
		cRet := AllTrim(cMail_2)

/* pzzn
	ElseIf !Empty(AllTrim(cMail_1))
	
		cRet := AllTrim(cMail_1)
*/	
	EndIf
	
Return(cRet)



Method GetMessage(cDtVis, cNomCli, cDescObr) Class TWorkflowVistoriaObraEngenharia
Local cRet := ""

	cRet := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cRet += '    <title>Workflow</title>
	cRet += '    <style type="text/css">
	cRet += '        body {
	cRet += '            font-family: tahoma;
	cRet += '            font-size: 15px;
	cRet += '        }
	cRet += '    </style>
	cRet += '</head>
	cRet += '<body>
	cRet += '    <p><span>Prezado Representante,</span></p>
	cRet += '    <p><span>Conforme definido no Procedimento de Orientação do canal engenharia, segue em anexo o documento - <span style="font-weight:bold;">Termo de Aceite de Mercadorias</span> - com a data prevista para realização da vistoria do apto/casa, para dia <span style="font-weight:bold;">'+ dToC(sToD(cDtVis)) +'</span>.</span></p>
	cRet += '    <p><span>Construtora: <span style="font-weight:bold;">'+ Capital(AllTrim(cNomCli)) +'</span>.</span></p>
	
	If !Empty(cDescObr)
		
		cRet += '    <p><span>Obra: <span style="font-weight:bold;">'+ Capital(AllTrim(cDescObr)) +'</span>.</span></p>
		
	EndIf
	
	cRet += '	<p><span>Caso o prazo não atenda a necessidade da obra, sendo necessária postergação desta data, favor informar à atendente comercial qual será a data que será realizada a vistoria para ajuste no sistema.</span></p>	
	cRet += '	<p><span>Atenciosamente,</span></p>
	cRet += '    <p><span style="font-weight:bold;">GRUPO BIANCOGRES</span></p>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Method SendWorkFlow(cDtVis, cCliente, cNomCli, cNumObr, cDescObr, cMail) Class TWorkflowVistoriaObraEngenharia
Local cFile := ""
Local oMail := TAFMail():New()

	cFile := Lower("\P10\vistoria_obra\termo\termo_" + cEmpAnt + "_" + cDtVis + "_" + cCliente + If (!Empty(cNumObr), "_" + cNumObr, "") + ".pdf")
			
	oMail:cTo := cMail
	oMail:cSubject := "BIANCOGRES | Termo de Aceite de Mercadorias"	
	oMail:cBody := ::GetMessage(cDtVis, cNomCli, cDescObr)
	oMail:cAttachFile := cFile

	oMail:Send()
	
Return()
