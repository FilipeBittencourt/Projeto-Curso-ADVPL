#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"


#DEFINE REPRESENTANTE 1
#DEFINE ATENDENTE 2
#DEFINE CLIENTE 3

/*/{Protheus.doc} BIA190
@description Workflow para envio de produtos empenhados
@author Rubens Junior (FACILE)
@since 13/08/2013 
@version 1.0
@version Revisado por Fernando em 25/04/2018
/*/
User Function BIA190()

	Local nI

	Private ENTER		:= CHR(13)+CHR(10)
	Private C_HTML  	:= ""
	Private CSQL 		:= ""  
	Private nOpc                  

	Private xViaSched 	:= (Select("SX6")== 0)
	Private xv_Emps 	:= {} 

	xv_Emps := U_BAGtEmpr("01_05")


	For nI := 1 to Len(xv_Emps)
		ConOut("HORA: "+TIME()+" - Iniciando Processo BIA190 " + xv_Emps[nI,1])
		If xViaSched
			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		EndIf

		nOpc :=  REPRESENTANTE            
		MontaQry()
		TCQUERY CSQL ALIAS "QRY" NEW 	
		GeraHtml()        	
		QRY->(DbCloseArea())         

		//enviar email para os atendentes
		nOpc := ATENDENTE
		MontaQry()
		TCQUERY CSQL ALIAS "QRY" NEW 
		GeraHtml()        
		QRY->(DbCloseArea())         

		/*	
		//enviar email para os clientes
		nOpc := CLIENTE
		MontaQry()
		TCQUERY CSQL ALIAS "QRY" NEW 
		GeraHtml()        
		QRY->(DbCloseArea())  
		*/

		ConOut("HORA: "+TIME()+" - Finalizando Processo BIA190 " + xv_Emps[nI,1])
		If xViaSched	
			//Finaliza o ambiente criado
			RpcClearEnv()    
		EndIf       

	Next nI 

Return                

/*/{Protheus.doc} GeraHtml
@description GERAR HTML PARA ENVIAR O EMAIL
/*/
Static Function GeraHtml()

	Local cAtendeRep := ''
	Local cSituaca	:= ''

	Private cAuxRepAtu := ''
	Private cAuxAteAtu := ''
	Private cAuxRep := ''
	Private cEmp 	:=  ''
	Private	cPedido := 	''
	Private	cCodCli :=  ''
	Private	cLojaCli:=  ''

	While !QRY->(EOF())     

		C_HTML  := ""	
		If (nOpc == REPRESENTANTE)
			cAuxRep := QRY->C5_VEND1

			cAuxRepAtu := QRY->C5_VEND1
			cAuxAteAtu := '' 
		ElseIf (nOpc == ATENDENTE)
			cAuxRep := QRY->COD_ATEND 

			cAuxRepAtu := QRY->C5_VEND1
			cAuxAteAtu := QRY->COD_ATEND
		Else
			cAuxRep := QRY->A1_COD

			cAuxRepAtu := QRY->A1_COD
			cAuxAteAtu := ''
		EndIf

		If (nOpc == REPRESENTANTE) 
			cAtendeRep := QRY->C5_VEND1
		ElseIf (nOpc == ATENDENTE)
			cAtendeRep := QRY->COD_ATEND
		Else
			cAtendeRep := QRY->A1_COD
		EndIf    

		cSituaca := SubStr(QRY->SITUACA,1,1)

		//Incio do email.
		GeraCab()

		//Cabeçalho para o Tipo de Empenho.
		GeraCabItm(cSituaca)

		//Prenche os Itens Empenhados.
		WHILE !QRY->(EOF()) .And. cAuxRep == cAtendeRep 

			C_HTML += '<font face="Arial" color="black" size = "8px" > '
			C_HTML += '  <tr align=center>   
			C_HTML += '    <td class="style12">'+ QRY->C5_CLIENTE +'</td> '
			C_HTML += '    <td class="style12">'+ Alltrim(Posicione("SA1",1,xFilial("SA1")+QRY->C5_CLIENTE+QRY->C5_LOJACLI,"A1_NOME")) +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->EMPRESA +'</td> '  
			C_HTML += '    <td class="style12">'+ QRY->C5_NUM +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->C9_ITEM +'</td> ' 
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->C5_EMISSAO,7,2)+"/"+SUBSTR(QRY->C5_EMISSAO,5,2)+"/"+SUBSTR(QRY->C5_EMISSAO,1,4) +'</td> '
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->C9_DATALIB,7,2)+"/"+SUBSTR(QRY->C9_DATALIB,5,2)+"/"+SUBSTR(QRY->C9_DATALIB,1,4) +'</td> '
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->C9_PRODUTO) +'</td> '
			C_HTML += '    <td class="style12">'+ Alltrim(Posicione("SB1",1,xFilial("SB1")+QRY->C9_PRODUTO,"B1_DESC")) +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->C9_QTDLIB	,"@E 999,999,999.99") +'</td> '		
			C_HTML += '  </tr>
			C_HTML += '</font>		

			cEmp 	:=  QRY->EMPRESA
			cPedido := 	QRY->C5_NUM
			cCodCli :=  QRY->A1_COD
			cLojaCli:=  QRY->A1_LOJA

			QRY->(DBSKIP())

			If (nOpc == REPRESENTANTE) 
				cAtendeRep := QRY->C5_VEND1
			ElseIf (nOpc == ATENDENTE)
				cAtendeRep := QRY->COD_ATEND
			Else
				cAtendeRep := QRY->A1_COD
			EndIf     

			If cAuxRep == cAtendeRep
				If QRY->(Eof()) .Or. (cSituaca <> SubStr(QRY->SITUACA,1,1))

					cSituaca := SubStr(QRY->SITUACA,1,1)

					C_HTML += '<br></br> '
					C_HTML += '</table> '
					GeraCabItm(cSituaca)

				EndIf
			EndIf

			dbSelectArea('QRY')
		EndDo

		If	QRY->(Eof()) .Or. (cAuxRep != cAtendeRep)

			C_HTML += '</table> '     
			C_HTML += '<font face = "Arial"> <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA190).</p> </font>'  		
			C_HTML += '<p>&nbsp;	</p> '
			C_HTML += '</body> '
			C_HTML += '</html> '

			//SENDMAIL()   
			EnvMailMult()

			If (nOpc == REPRESENTANTE)
				cAuxRep := QRY->C5_VEND1 
			ElseIf (nOpc == ATENDENTE)
				cAuxRep := QRY->COD_ATEND
			Else
				cAuxRep := QRY->A1_COD
			EndIf    

		EndIf 

		C_HTML += '</table> '     
		C_HTML += '<BR><BR><BR><BR>	<u><b>Esta é uma Mensagem Automática. Favor Não Responder.</b></u> '     
		C_HTML += '<p>&nbsp;	</p> '
		C_HTML += '</body> '
		C_HTML += '</html> '

		dbSelectArea('QRY')
	End

RETURN   

/*/{Protheus.doc} GeraCab
@description GERAR CABECALHO DE CADA EMAIL QUE VAI SER ENVIADO
/*/
Static Function GeraCab()

	C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	C_HTML += '<head> '
	C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_HTML += '<title>Untitled Document</title> '
	C_HTML += '<style type="text/css"> '
	C_HTML += '<!-- '
	C_HTML += '.style12 {font face="Arial"; font-size: 9px; color: black; } '
	C_HTML += '.style21 {font face="Arial"; color: #FFFFFF; font-size: 9px; } '
	C_HTML += '--> '
	C_HTML += '</style> '
	C_HTML += '</head> '
	C_HTML += ' '
	C_HTML += '<body> ' 

	//cabecalho	
	C_HTML += '<table width="900" border="0" bgcolor="black" style="color:white"> '
	C_HTML += '  <tr> '                                        
	C_HTML += '    <th scope="col"><div align="center">WORKFLOW DIÁRIO DE ACOMPANHAMENTO DOS ITENS DE PEDIDOS - GERADO EM: '+ SUBSTR(dToS(dDatabase-1),7,2)+"/"+SUBSTR(dToS(dDatabase-1),5,2)+"/"+SUBSTR(dToS(dDatabase-1),1,4) +'  <BR>'				
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#FFFFFF style="color:black"> '
	C_HTML += '<font face="Arial" color="black"> '                          
	C_HTML += '<tr align=center> '
	C_HTML += '<br> '
	C_HTML += '<font face="Arial" color="black" size = "8px" > ' 

	If nOpc == REPRESENTANTE
		C_HTML += '    <th width="900" scope="col"><div align="left"> REPRESENTANTE: '+Alltrim(QRY->C5_VEND1)+ " - " + Alltrim(Posicione("SA3",1,xFilial("SA3")+QRY->C5_VEND1,"A3_NOME"))+' ' 
	ElseIf nOpc == ATENDENTE
		PswOrder(1)
		cNomeAtendente := Alltrim(UsrRetName(QRY->COD_ATEND))
		If Empty(cNomeAtendente)
			C_HTML += '    <th width="900" scope="col"><div align="left"> ATENDENTE: '+Alltrim(QRY->COD_ATEND)+ " - ATENDENTE EXCLUIDO DO SISTEMA 
		Else
			C_HTML += '    <th width="900" scope="col"><div align="left"> ATENDENTE: '+Alltrim(QRY->COD_ATEND)+ " - " + cNomeAtendente+'  '
		EndIf
	Else
		C_HTML += '    <th width="900" scope="col"><div align="left"> CLIENTE: '+Alltrim(QRY->A1_COD)+ " - " + ALLTRIM(Posicione("SA1",1,xFilial("SA1")+QRY->A1_COD+QRY->A1_LOJA,"A1_NOME"))+' '
	EndIf    

	If CEmpAnt = "05"                                                                                                
		C_HTML += '<br><br>  EMPRESA: INCESA REVESTIMENTO CERÂMICO LTDA </th> '
	ElseIf CEmpAnt = "13"
		C_HTML += '<br><br>  EMPRESA: MUNDIALLI  </th> '
	Else                                                                   
		C_HTML += '<br><br>  EMPRESA: BIANCOGRES CERÂMICA S/A </th> '
	EndIf

	C_HTML += '</font>
	C_HTML += '<br><br> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> ' 

Return

Static Function GeraCabItm(cSituaca)   

	Local nPrzCancA		:= GetMV("FA_190PCXA")
	Local nPrzCancB		:= GetMV("FA_190PCXB")

	//cabecalho dos itens do pedido 
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                              
	C_HTML += '</tr> '             
	C_HTML += '</table> ' 

	/*
	O primeiro tem como cabeçalho o título: ITENS EMPENHADOS NO DIA 					->	VERDE
	O segundo tem como cabeçalho o título: ITENS QUE SERÃO DESEMPENHADOS APÓS 7 DIAS 	->	AMARELO	-- DE 7 A 14 DIAS
	O terceiro tem como cabeçalho o título: ITENS DESEMPENHADOS NO DIA 					->	LARANJA --some
	O quarto tem como cabeçalho o título: ITENS CANCELADOS NO DIA						->	VERMELHO
	*/

	If (cSituaca == "1") // DO DIA

		C_HTML += '<table width="900" border="0" bgcolor="#00BB73" style="color:black"> '
		C_HTML += '<font face="Arial" color="black"> '                          
		C_HTML += '<tr> ' 	
		C_HTML += '    <th width="900" scope="col">ITENS EMPENHADOS NO DIA - PROVIDENCIAR CARREGAMENTO IMEDIATO </th> '

		//AVISO DE CANCELAMENTO PRODUTO A
	ElseIf (cSituaca == "2") 

		C_HTML += '<table width="900" border="0" bgcolor="#FAD400"> '
		C_HTML += '<font face="Arial" color="black"> '                          
		C_HTML += '<tr> ' 		
		C_HTML += '    <th width="900" scope="col">PEDIDOS COM ATÉ '+ AllTrim(Str(nPrzCancA)) +' DIAS DE EMPENHO (PRODUTO CLASSE A)</th> '		
		// C_HTML += '    <th width="900" scope="col">PEDIDOS EMPENHADOS COM MAIS DE '+ AllTrim(Str(nPrzCancA)) +' DIAS SERÃO AUTOMATICAMENTE CANCELADOS (PRODUTO CLASSE A)</th> '		

		//CANCELAMENTO PRODUTO A	
	ElseIf (cSituaca == "3")

		C_HTML += '<table width="900" border="0" bgcolor="#FA0400"> '
		C_HTML += '<font face="Arial" color="black"> '                          
		C_HTML += '<tr> ' 
		C_HTML += '    <th width="900" scope="col"> PEDIDOS ACIMA DE ' + AllTrim(Str(nPrzCancA)) + ' DIAS QUE SERÃO CANCELADOS POR FALTA DE CARREGAMENTO (PRODUTO CLASSE A)</th> '
		// C_HTML += '    <th width="900" scope="col">PEDIDOS PARA SEREM CANCELADOS POR FALTA DE CARREGAMENTO (PRODUTO CLASSE A)</th> '

		//AVISO DE CANCELAMENTO PRODUTO B
	ElseIf (cSituaca == "4") 

		C_HTML += '<table width="900" border="0" bgcolor="#FAD400"> '
		C_HTML += '<font face="Arial" color="black"> '                          
		C_HTML += '<tr> ' 		
		C_HTML += '    <th width="900" scope="col">PEDIDOS COM ATÉ '+ AllTrim(Str(nPrzCancB)) +' DIAS DE EMPENHO (PRODUTO CLASSE B) </th> '		
		// C_HTML += '    <th width="900" scope="col">PEDIDOS EMPENHADOS COM MAIS DE '+ AllTrim(Str(nPrzCancB)) +' DIAS SERÃO AUTOMATICAMENTE CANCELADOS (PRODUTO CLASSE B) </th> '		

		//CANCELAMENTO PRODUTO B	
	ElseIf (cSituaca == "5")

		C_HTML += '<table width="900" border="0" bgcolor="#FA0400"> '
		C_HTML += '<font face="Arial" color="black"> '                          
		C_HTML += '<tr> ' 
		C_HTML += '    <th width="900" scope="col">PEDIDOS ACIMA DE ' + AllTrim(Str(nPrzCancB)) + ' DIAS QUE SERÃO CANCELADOS POR FALTA DE CARREGAMENTO (PRODUTO CLASSE B) </th> '
		// C_HTML += '    <th width="900" scope="col">PEDIDOS PARA SEREM CANCELADOS POR FALTA DE CARREGAMENTO (PRODUTO CLASSE B) </th> '
	Else

		C_HTML += '<table width="900" border="0" bgcolor="#14A9C7"> '
		C_HTML += '<font face="Arial" color="black"> '                          
		C_HTML += '<tr> ' 
		C_HTML += '    <th width="900" scope="col">ITENS EMPENHADOS </th> '

	EndIf		

	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '  

	//cabecalho colunas - itens
	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" style="color: black;"> '
	C_HTML += '<font face="Arial" color="black" size="2"> ' 
	C_HTML += '<tr align=center> ' 	
	C_HTML += '    <th width="60" scope="col"> COD. CLIENTE </span></th> '    
	C_HTML += '    <th width="150" scope="col"> CLIENTE </span></th> '  
	C_HTML += '    <th width="50" scope="col" > LOCAL </span></th> ' 
	C_HTML += '    <th width="40" scope="col"> PEDIDO </span></th> '  
	C_HTML += '    <th width="40" scope="col"> ITEM </span></th> '
	C_HTML += '    <th width="80" scope="col"> EMISSÃO DO PEDIDO </span></th> '        
	C_HTML += '    <th width="80" scope="col"> DATA DO EMPENHO </span></th> '        
	C_HTML += '    <th width="60" scope="col"> PRODUTO </span></th> '    
	C_HTML += '    <th width="150" scope="col"> DESC. PRODUTO </span></th> ' 
	C_HTML += '    <th width="40" scope="col"> M2 EMPENHADO </span></th> '    
	C_HTML += '  </tr> '  

Return

//---------------------------------------------------------------------------------------------------
// (Thiago Dantas - 02/06/14) ***  Novo método de envio de email pegando parametros do servidor. ***
//---------------------------------------------------------------------------------------------------
Static Function EnvMailMult()

	If (nOpc == REPRESENTANTE)
		cRecebe     := ALLTRIM(Posicione("SA3",1,xFilial("SA3")+cAuxRep,"A3_EMAIL"))
	ElseIf (nOpc == ATENDENTE)

		cRecebe     := UsrRetMail(cAuxAteAtu)

		If Empty(cRecebe)
			cRecebe     := ALLTRIM(U_MailAtendente(cEmp,cPedido,cAuxRepAtu,cCodCli,cLojaCli))
		EndIf
	Else
		//cRecebe     := ALLTRIM(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojaCli,"A1_EMAIL"))
	EndIf

	cRecebe +=';'
	cRecebe += U_EmailWF('BIA190',cEmpAnt)
	cAssunto := "Listagem de Pedidos Empenhados "
	cMensagem := C_HTML	

	ConOut("HORA: "+TIME()+" - Envio de Email - Processo BIA190 " + cRecebe)
	U_BIAEnvMail(,cRecebe,cAssunto,cMensagem)

Return
//---------------------------------------------------------------------------------------------------


/*/{Protheus.doc} MontaQry
@description MONTAR QUERY
/*/
Static Function MontaQry()

	Local lEnvEmpDia 	:= AllTrim(GetMV("FA_190EDIA")) == "S"
	Local nPrzCancA		:= GetMV("FA_190PCXA")
	Local nPrzCancB		:= GetMV("FA_190PCXB")
	Local nDiasAviA		:= GetMV("FA_190DIAA")
	Local nDiasAviB		:= GetMV("FA_190DIAB")

	CSQL := " WITH TAB_EMP AS ( " +ENTER
	CSQL += " SELECT "                                                              

	CSQL += " ISNULL((SELECT TOP 1 ZZI.ZZI_ATENDE FROM VW_SAP_ZZI ZZI WHERE ZZI.ZZI_VEND = E.C5_VEND1 AND ZZI.ZZI_TPSEG = E.A1_YTPSEG AND ZZI.EMP = E.MARCA),'')  AS COD_ATEND, " +ENTER 
	CSQL += " DIAS_EMP = DATEDIFF(day,case when E.A1_YTPSEG = 'E' and E.C9_DATALIB < C6_YDTNECE then E.C6_YDTNECE else E.C9_DATALIB end,GetDate()), " +ENTER 
	CSQL += " B1_YCLASSE, " +ENTER
	CSQL += " E.* " +ENTER 

	CSQL += " FROM __VW_EMPENHO_WF E WITH (NOLOCK) " +ENTER
	CSQL += " JOIN SB1010 SB1 ON SB1.B1_FILIAL = '  ' AND SB1.B1_COD = E.C9_PRODUTO AND SB1.D_E_L_E_T_=' ' " +ENTER	

	CSQL += " WHERE E.MARCA = '" +cEmpAnt+"'" +ENTER

	CSQL += " ) " +ENTER

	CSQL += " SELECT * FROM
	CSQL += " (
	CSQL += " SELECT " +ENTER

	CSQL += " SITUACA = CASE WHEN B1_YCLASSE = '1' THEN " +ENTER
	CSQL += " 			CASE " +ENTER
	CSQL += " 				WHEN DIAS_EMP <= 0 THEN '1-EMPENHADO NO DIA' " +ENTER
	CSQL += " 				WHEN DIAS_EMP > "+AllTrim(Str(nPrzCancA-nDiasAviA))+" AND DIAS_EMP <= "+AllTrim(Str(nPrzCancA))+" THEN '2-AVISO DE CANCELAMENTO' " +ENTER
	CSQL += " 				WHEN DIAS_EMP > "+AllTrim(Str(nPrzCancA))+" THEN '3-CANCELAR' " +ENTER
	CSQL += " 				ELSE '9-NAO ENVIAR' " +ENTER
	CSQL += " 			END " +ENTER
	CSQL += " 		  ELSE " +ENTER
	CSQL += " 			CASE " +ENTER
	CSQL += " 				WHEN DIAS_EMP <= 0 THEN '1-EMPENHADO NO DIA' " +ENTER
	CSQL += " 				WHEN DIAS_EMP > "+AllTrim(Str(nPrzCancB-nDiasAviB))+" AND DIAS_EMP <= "+AllTrim(Str(nPrzCancB))+" THEN '4-AVISO DE CANCELAMENTO' " +ENTER
	CSQL += " 				WHEN DIAS_EMP > "+AllTrim(Str(nPrzCancB))+" THEN '5-CANCELAR' " +ENTER
	CSQL += " 				ELSE '9-NAO ENVIAR' " +ENTER
	CSQL += " 			END " +ENTER
	CSQL += " 		  END, " +ENTER
	CSQL += " TAB_EMP.* " +ENTER
	CSQL += " FROM TAB_EMP) TAB " +ENTER

	If !lEnvEmpDia

		CSQL += " WHERE SUBSTRING(SITUACA,1,1) not in ('1','9') " +ENTER

	Else

		CSQL += " WHERE SUBSTRING(SITUACA,1,1) not in ('9') " +ENTER

	EndIF

	If (nOpc == REPRESENTANTE)

		CSQL += " ORDER BY C5_VEND1, SUBSTRING(SITUACA,1,1)"

	ElseIf (nOpc == ATENDENTE)

		CSQL += " ORDER BY COD_ATEND, SUBSTRING(SITUACA,1,1)"

	Else

		CSQL += " ORDER BY A1_COD, SUBSTRING(SITUACA,1,1)"

	EndIf

Return()
