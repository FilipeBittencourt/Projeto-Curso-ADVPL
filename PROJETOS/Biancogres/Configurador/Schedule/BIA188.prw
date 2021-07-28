#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA188         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/02/2014               
# DESCRICAO..: Workflow de Pedidos que estao sendo liberados pela rotina BIA319
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function BIA188(cPedOri, cEmpPed, lRpc)

	Local aArea     	:= GetArea()

	Local nCount 		:= 1

	Local N_DESC_INC	:= 0
	Local nTOTAL_QUANT 	:= 0
	Local nTOTAL_TOTAL 	:= 0
	Local TOTAL_COMIPI 
	Local cDescric

	Local I

	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private cEmail
	Private C_HTML  	:= ""
	Private lOK        := .F. 

	// Tiago Rossini Coradini - 31-07-15
	// Tratamentoquando para chamanda via RPC de outra empresa
	Default cPedOri := "" 
	Default cEmpPed := "" 
	Default lRpc := .F.

	// Tiago Rossini Coradini - 31-07-15
	// Posicionar pedido certo da LM quando chamando a funcao via RPC de ourtra empresa
	If lRpc

		//Posiciona no novo Indice C5_YPEDORI + C5_YEMPPED
		SC5->(DbSetOrder(11))
		If !SC5->(DbSeek(xFilial("SC5") + cPedOri + cEmpPed))
			Return()
		EndIf	

	EndIf


	C_HTML  := ""
	cTitulo   := 'Pedido de Venda Num: '+(SC5->C5_NUM)

	C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	C_HTML += '<head> '
	C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_HTML += '<title>Untitled Document</title> '
	C_HTML += '<style type="text/css"> '
	C_HTML += '<!-- '
	C_HTML += '.style12 {font-size: 9px; } '
	C_HTML += '.style21 {color: #FFFFFF; font-size: 9px; } '
	C_HTML += '--> '
	C_HTML += '</style> '
	C_HTML += '</head> '
	C_HTML += ' '
	C_HTML += '<body> '

	//CABECALHO	                                               
	C_HTML += '<table width="900" border="0" bgcolor="black" style="color:white"> '
	C_HTML += '  <tr> '                                        
	// C_HTML += '<font color="white"> '
	C_HTML += '  <th scope="col"><div align="center" >PEDIDO ESTAVA BLOQUEADO POR DESCONTO/MARGEM E FOI LIBERADO <br> LIBERADO POR: ' +Alltrim(SC5->C5_YAPROV) 
	// C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="black" style="color:white"> '
	//C_HTML += '<table width="900" border="0" > '
	C_HTML += '  <tr> '                                        
	//C_HTML += '<font color="black"> '
	// C_HTML += '<font color="white"> '

	DO CASE
		CASE cEmpAnt = "01"
		C_HTML += '  <th scope="col"><div align="center">PEDIDO DE VENDA NA EMPRESA BIANCOGRES - '+(SC5->C5_NUM)+'<br>'			
		CASE cEmpAnt = "05"   
		C_HTML += '  <th scope="col"><div align="center">PEDIDO DE VENDA NA EMPRESA INCESA - '+(SC5->C5_NUM)+'<br>'			
		OTHERWISE
		C_HTML += '  <th scope="col"><div align="center">PEDIDO DE VENDA - '+(SC5->C5_NUM)+'<br>'			
	ENDCASE                        

	// C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="450" scope="col"> DADOS DA EMPRESA </th> '
	C_HTML += '    <th width="450" scope="col"> DADOS DO PEDIDO </th> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2" style="color:black"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> Razão Social do Comprador: <b>'+ UPPER(SM0->M0_NOMECOM) +'</b></td> '
	If cEmpAnt == '07' .And. !Empty(SC5->C5_YPEDORI)
		C_HTML += '    <td><div align="left"> Número do Pedido:: <b>'+ SC5->C5_NUM +'</b>  Pedido Original:: <b>'+AllTrim(SC5->C5_YPEDORI)+'</b></td> '  
	Else
		C_HTML += '    <td><div align="left"> Número do Pedido:: <b>'+ SC5->C5_NUM +'</b></td> '  
	EndIf
	C_HTML += '  </tr> '
	C_HTML += '<tr> '             
	C_HTML += '    <td><div align="left"> CNPJ: <b>' + TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") +'<b></td> '
	C_HTML += '    <td><div align="left"> Data: '+ SUBSTR( DTOS(SC5->C5_EMISSAO),7,2)+"/"+SUBSTR( DTOS(SC5->C5_EMISSAO),5,2)+"/"+SUBSTR( DTOS(SC5->C5_EMISSAO),1,4) +'</td> '                      
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> Endereço: <b>' + SM0->M0_ENDCOB +'</b></td> '
	C_HTML += '    <td><div align="left"> Código Representante: <b>' + Alltrim(SC5->C5_VEND1) +'<b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> Município: <b>' + SM0->M0_CIDCOB +'</b></td> '
	C_HTML += '    <td><div align="left"> Cond. Pagamento: <b>' + Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI") +'<b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> Estado: <b>' + SM0->M0_ESTCOB +'</b></td> '
	C_HTML += '    <td><div align="left"> Nome Representante: <b> '+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NREDUZ")+'<b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> CEP: <b>' + SM0->M0_CEPCOB +'</b></td> '
	C_HTML += '    <td><div align="left"> Forma de Pagamento: <b> '+IIF(SC5->C5_YFORMA=="1","BANCO",IIF(SC5->C5_YFORMA=="2","CHEQUE","OP"))+'<b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> País: <b>BRASIL</b></td> '
	C_HTML += '  </tr> '
	//C_HTML += '<tr> '
	//C_HTML += '    <td><div align="left"> Nome do Contato: <b>'+cContato+'</b></td> '
	//C_HTML += '  </tr> '
	//C_HTML += '<tr> '
	//C_HTML += '    <td><div align="left"> E-mail do Contato: <b>'+cMailContato+'</b></td> '
	//C_HTML += '  </tr> '                                                                           
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> Telefone de Contato: <b>'+SM0->M0_TEL+'</b></td> '
	C_HTML += '  </tr> '

	C_HTML += '</font>'        
	C_HTML += '</table> '    

	C_HTML += '<BR>'      

	//DADOS DO CLIENTE	

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI) 

	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                                   
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col"> DADOS DO CLIENTE:  </th> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '        

	C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2" style="color:black"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> CLIENTE: <b>'+Alltrim(SA1->A1_NOME)+'</b></td> '
	C_HTML += '    <td><div align="left"> CÓDIGO: <b>'+Alltrim(SA1->A1_COD)+'</b></td> '
	C_HTML += '    <td><div align="left"> Cliente Ped. Compra: <b>' + Alltrim(SC5->C5_YPC) + '</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> ENDEREÇO: <b>'+Alltrim(SA1->A1_END)+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> BAIRRO: <b>'+Alltrim(SA1->A1_BAIRRO)+'</b></td> '
	C_HTML += '    <td><div align="left"> CIDADE: <b>'+Alltrim(SA1->A1_MUN)+'</b></td> '
	C_HTML += '    <td><div align="left"> UF: <b>'+Alltrim(SA1->A1_EST)+'</b></td> '
	C_HTML += '  </tr> ' 
	C_HTML += '<tr> '
	If(Alltrim(SA1->A1_PESSOA)=='J')
		C_HTML += '    <td><div align="left"> CNPJ: <b>' + TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99") +'<b></td> '
		If !Empty(SA1->A1_INSCR)
			C_HTML += '    <td><div align="left"> I.E.: <b>' + SA1->A1_INSCR +'<b></td> '
		EndIf                                                                            
	Else
		C_HTML += '    <td><div align="left"> CPF: <b>' + TRANSFORM(SA1->A1_CGC,"@R 999.999.999-99") +'<b></td> '
	EndIf           
	C_HTML += '    <td><div align="left"> CEP: <b>' + SA1->A1_CEP +'<b></td> '             
	C_HTML += '  </tr> ' 
	C_HTML += '  <tr> ' 
	C_HTML += '    <td><div align="left"> COMPRADOR: <b>' + Alltrim(SA1->A1_CONTATO) +'<b></td> '
	C_HTML += '    <td><div align="left"> TELEFONE: <b>' + SA1->A1_TEL +'<b></td> '
	C_HTML += '    <td><div align="left"> FAX: <b>' + SA1->A1_FAX +'<b></td> '
	C_HTML += '  </tr> ' 
	C_HTML += '  <tr> ' 
	C_HTML += '    <td><div align="left"> E-MAIL: <b>' + Alltrim(SA1->A1_EMAIL) +'<b></td> '
	C_HTML += '    <td><div align="left"> TRANSPORTADORA: <b>' + Alltrim(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME")) +'<b></td> '
	C_HTML += '  </tr> ' 

	C_HTML += '</font>'        
	C_HTML += '</table> '   

	C_HTML += '<BR>'      	


	//CABECALHO DOS ITENS DO PEDIDO 
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                                
	C_HTML += '</tr> '             
	C_HTML += '</table> ' 

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col">ITENS DO PEDIDO DE VENDA </th> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '  
	//CABECALHO COLUNAS - ITENS
	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" style="color:black"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> ' 	
	C_HTML += '    <th width="20" scope="col"> ITEM </span></th> '   
	C_HTML += '    <th width="50" scope="col"> QUANTIDADE </span></th> '  
	//C_HTML += '    <th width="200" scope="col"> DESCRIÇÃO </span></th> '
	C_HTML += '    <th width="200" scope="col"> PRODUTO </span></th> '    
	//C_HTML += '    <th width="20" scope="col"> ENTREGA </span></th> '
	C_HTML += '    <th width="20" scope="col"> PREV DISPON </span></th> '                
	C_HTML += '    <th width="40" scope="col"> DT NECES. ENG </span></th> '
	C_HTML += '    <th width="40" scope="col"> PREÇO </span></th> '    
	//C_HTML += '    <th width="40" scope="col"> IPI </span></th> '    
	//C_HTML += '    <th width="40" scope="col"> DT NECES. ENG </span></th> '    
	C_HTML += '    <th width="100" scope="col"> TOTAL </span></th> '    
	C_HTML += '  </tr> '  
	//C_HTML += '</table> '

	N_DESC_INC		:= 0
	nTOTAL_QUANT 	:= 0
	nTOTAL_TOTAL 	:= 0

	dbSelectArea("SC6")
	dbSetOrder(1)
	If dbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
		While ! Eof() .And. SC6->C6_NUM == SC5->C5_NUM

			N_DESC_INC		+= SC6->C6_VALDESC
			nTOTAL_QUANT 	+= SC6->C6_QTDVEN
			nTOTAL_TOTAL 	+= SC6->C6_VALOR + SC6->C6_VALDESC

			C_HTML += '  <tr> '   
			C_HTML += '    <td>'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> ' 
			C_HTML += '    <td>'+ TRANSFORM(SC6->C6_QTDVEN	,"@E 99,999.99") +'</td> '   
			//(Thiago Dantas - 02/03/15) -> Adicionado campo codigo do produto [OS 0938-15]
			C_HTML += '    <td>'+AllTrim(SC6->C6_PRODUTO)+'-'+ Alltrim(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")) +'</td> '		  
			C_HTML += '    <td>'+ SUBSTR(DTOS(SC6->C6_ENTREG),7,2)+"/"+SUBSTR(DTOS(SC6->C6_ENTREG),5,2)+"/"+SUBSTR(DTOS(SC6->C6_ENTREG),1,4) +'</td> '
			C_HTML += '    <td>'+DTOC(SC6->C6_YDTNECE)+'</td> '
			C_HTML += '    <td>'+ Transform(SC6->C6_PRUNIT,"@E 999,999.99") +'</td> '
			//C_HTML += '    <td>0%</td> '
			//C_HTML += '    <td>'+DTOC(SC6->C6_YDTNECE)+'</td> '
			C_HTML += '    <td>'+ Transform(SC6->C6_VALOR + SC6->C6_VALDESC,"@E 99,999,999.99") +'</td> ' 
			C_HTML += '	</tr> '  
			
			SC6->(DBSKIP())
			nCount ++	                              

		EndDo
	EndIf

	

	TOTAL_COMIPI 	:=  ((nTOTAL_TOTAL+SC5->C5_VLRFRET)-N_DESC_INC)

	//TOTALIZADOR
	C_HTML += '  <tr> '   
	C_HTML += '    <td> TOTAL </td> ' 
	C_HTML += '    <td> '+Transform(nTOTAL_QUANT,"@E 999,999.99")+' </td> '
	C_HTML += '    <td>  </td> ' 
	C_HTML += '    <td>  </td> ' 
	C_HTML += '    <td>  </td> ' 
	C_HTML += '    <td>  </td> ' 
	C_HTML += '    <td> '+Transform(nTOTAL_TOTAL,"@E 999,999.99")+' </td> '
	C_HTML += '	</tr> '   

	C_HTML += '</table> '  

	SC6->(DbGoTop())

	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" style="color:black"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> ' 	
	C_HTML += '    <th width="800" scope="col"> SEGURO: '+IIF(SC5->C5_VLRFRET == 0,'NÃO','SIM') +'</span></th> ' 
	C_HTML += '    <th width="100" scope="col"> '+Transform((SC5->C5_VLRFRET*nTOTAL_QUANT),"@E 9,999,999.99") +'</span></th> '    
	C_HTML += '  </tr> '  
	C_HTML += '  <tr> '  
	C_HTML += '    <th width="800" scope="col"> DESCONCONTO INCONDICIONAL: </span></th> '  
	C_HTML += '    <th width="100" scope="col"> '+Transform(N_DESC_INC,"@E 9,999,999.99") +'</span></th> '    
	C_HTML += '  </tr> '  
	C_HTML += '  <tr> '  
	C_HTML += '    <th width="800" scope="col"> TOTAL COM SEGURO E IPI: </span></th> '  
	C_HTML += '    <th width="100" scope="col"> '+Transform(TOTAL_COMIPI+(SC5->C5_VLRFRET*nTOTAL_QUANT),"@E 9,999,999.99") +'</span></th> '   
	C_HTML += '  </tr> '  
	C_HTML += '</table> ' 

	//INFORMACOES OBRIGATORIAS	
	C_HTML += '<br> '       

	C_HTML += '<BR>' 
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                                 
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col"> IMPORTANTE:  </th> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '        

	C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2" style="color:black"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> 1 - Todos os pedidos com produtos disponíveis são para embarque imediato. </td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> 2 - Preço FOB Fábrica.</td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> 3 - Os produtos a serem retirados na fábrica, devem ser programados no setor de expedição com 48 horas de antecededencia. </td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> 4 - Os produtos diponíveis e sem agendamento de embarque bloquearão a entrada de novos pedidos.  </td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> 5 - Para pedido sem seguro, o transporte e por conta e risco cliente.  </td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> 6 - Preços e condição sujeitos a confirmação. Caso a inflação do setor seja superior a 5% entre a digitação do pedido até a entrega, os preços serão renegociados. </td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> 7 - O volume de cada item constante neste pedido pode sofrer variação de 10% para cima ou para baixo.  </td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> 8 - Caso haja alteração na legislação tributária os preços deverão ser ajustados. </td> '
	C_HTML += '  </tr> '

	//IMPORTANTE - SOMENTE PARA CLIENTES DO TIPO ENGENHARIA
	If(Alltrim(SA1->A1_YTPSEG)=='E')
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> <u><b> 9 - Por se tratar de produto cerâmico queimado em altas temperaturas, não garantimos o fornecimento de complementos no mesmo padrão de tonalidade e calibre do pedido anterior, se solicitados após o pedido inicial e fabricado em nova produção; </b></u>  </td> '
		C_HTML += '  </tr> ' 
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 10 - Adquirir no mínimo 10% a mais do produto para efeitos de reserva técnica (indicado inclusive pela norma da ABNT);  </td> '
		C_HTML += '  </tr> ' 
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 11 - A responsabilidade pela quantidade especificada e pedida é do responsável técnico da obra, que deverá observar critérios de compra que garantam a reserva técnica de obra para atender eventuais quebras, perdas e alterações de projeto.  </td> '
		C_HTML += '  </tr> ' 	
	EndIf

	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> (*) A disponibilidade de estoque esta sujeita a alteração sem prévio aviso. </td> '
	C_HTML += '  </tr> '

	C_HTML += '</font>'        
	C_HTML += '</table> '   

	//OBSERVACAO
	cDescric := Alltrim(SC5->C5_YOBS)
	nLinha	:= MLCount(cDescric,90)

	If (!Empty(cDescric))
		C_HTML += '<BR>' 
		C_HTML += '<table width="900" border="0" bgcolor="black"> '
		C_HTML += '  <tr> '                                        
		C_HTML += '</tr> '             
		C_HTML += '</table> '

		C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
		C_HTML += '<font color="black"> '                          
		C_HTML += '<tr> '
		C_HTML += '    <th width="900" scope="col"> OBSERVAÇÃO:  </th> '
		C_HTML += '  </tr> '
		C_HTML += '</font>'        
		C_HTML += '</table> '        

		C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2" style="color:black"> '
		C_HTML += '<font color="black" size="2"> '  


		FOR I := 1 To nLinha                        
			C_HTML += '<tr> '   
			C_HTML += '    <td><div align="left">  '+MemoLine(cDescric,90,I)+'</td> '
			C_HTML += '  </tr> '
		NEXT I       

		C_HTML += '</font>'        
		C_HTML += '</table> ' 
	EndIf

	//ASSINATURA PARA CLIENTES DE ENGENHARIA 
	If(Alltrim(SA1->A1_YTPSEG)=='E')
		C_HTML += '<BR><BR><BR>'
		C_HTML += '<table width="900" border="0" bgcolor="white" style="color:black"> '
		C_HTML += '<font color="black"> '                          
		C_HTML += '<tr> '
		C_HTML += '    <th width="900" scope="col"> ___________________________________________________________  </th> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		C_HTML += '    <th width="900" scope="col">Assinatura do Comprador</th> '
		C_HTML += '  </tr> '
		C_HTML += '</font>'        
		C_HTML += '</table> '    
	EndIf  

	C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder. </b></u> '     
	C_HTML += '<p>&nbsp;	</p> '
	C_HTML += '</body> '
	C_HTML += '</html> '



	IF C_HTML <> ""
		//SENDMAIL()
		EnvMailMult(Alltrim(SA1->A1_YTPSEG))
	ENDIF 

	SA1->(DbCloseArea())
	SC6->(DbCloseArea())

	//DbCloseArea("QRY") 
	RestArea(aArea)

RETURN

//---------------------------------------------------------------------------------------------------
// (Thiago Dantas - 02/06/14) ***  Novo método de envio de email pegando parametros do servidor. ***
//---------------------------------------------------------------------------------------------------
Static Function EnvMailMult(cCliEng)
	
	cRecebe     := ALLTRIM(U_MailAtendente(cEmpAnt,SC5->C5_NUM,SC5->C5_VEND1,SC5->C5_CLIENTE,SC5->C5_LOJACLI)) 	

	If (cEmpAnt == "01" .Or. cEmpAnt == "0101") .And. cCliEng == "E"
		xCLVL   	:= ""
		cRecebeO 	:= U_EmailWF('BIA188', cEmpAnt , xCLVL )	 //LUANA MARIN RIBEIRO - OS 4407-15							// Copia Oculta
	Else
		cRecebeO 	:= ""
	EndIf

	cAssunto	:= "Liberação de Pedido (Desconto/Margem)"

	cMensagem   := C_HTML

	If !Empty(cRecebe)
		U_BIAEnvMail(,cRecebe,cAssunto,cMensagem,,,,,cRecebeO)
	EndIf
Return
//---------------------------------------------------------------------------------------------------

/*
##############################################################################################################
# PROGRAMA...: SENDMAIL
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 14/02/2014            
# DESCRICAO..: Rotina de Envio de Email
##############################################################################################################                                      
*/
STATIC FUNCTION SENDMAIL()

	Local lOk

	cRecebe     := ALLTRIM(U_MailAtendente(cEmpAnt,SC5->C5_NUM,SC5->C5_VEND1,SC5->C5_CLIENTE,SC5->C5_LOJACLI)) 	// ;"+cEmail	// Email do(s) receptor(es)                  
	//cRecebeCC	:= "claudia.carvalho@biancogres.com.br" 	// Com Copia
	cRecebeCC	:= ""
	If cEmpAnt == "01" .Or. cEmpAnt == "0101"
		cRecebeO 	:= U_EmailWF('BIA188', cEmpAnt , "" )	 //LUANA MARIN RIBEIRO - OS 4407-15							// Copia Oculta
	Else
		cRecebeO 	:= ""
	EndIf
	cAssunto	:= "Liberação de Pedido (Desconto/Margem)"			// Assunto do Email          

	If !Empty(cRecebe)
		U_BIAEnvMail(,cRecebe,cAssunto,C_HTML,,,,,cRecebeO)   
	EndIf
RETURN



/*
##############################################################################################################
# PROGRAMA...: GetAtendente
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 11/12/2013                    
# DESCRICAO..: BUSCAR QUAL E O ATENDENTE DE ACORDO COM A LINHA DE PRODUTO/VENDEDOR NO PEDIDO DE VENDA
##############################################################################################################     
*/           
/*
Static Function GetAtendente()

Local cAtendente := '' 
Local cVendedor := SC5->C5_VEND1
Local cTpSeg := ''
Local lAchou := .F.
Local cLinha := ''  

cTpSeg := SA1->A1_YTPSEG

//SE FOR EMPRESA LM, TRATATIVA DIFERENTE PARA BUSCAR DADOS NA TABELA ZZI
If cEmpAnt =='07'	
//IF ALLTRIM(cTrab->C5_YCLIORI) == ''   
//BUSCAR ATENDENTE DE ACORDO COM O VENDEDOR
DbSelectArea("ZZI")
DbSetOrder(1)
If (DbSeek(xFilial("ZZI")+cVendedor))      

//BUSCAR ATENDENTE DE ACORDO COM O SEGMENTO		
While ZZI->(!Eof())
If(ZZI->ZZI_TPSEG == cTpSeg)
cAtendente := ZZI->ZZI_ATENDE
lAchou := .T.
EndIf 

If lAchou
exit
EndIf

ZZI->(DbSkip())
EndDo  
EndIf	     
Else
CSQL := "SELECT C5_YLINHA FROM "+RETSQLNAME("SC5")+" AS SC5_TMP "                                                                               
CSQL += "WHERE SC5_TMP.C5_FILIAL = '"+xFilial("SC5")+"'  "
CSQL += "AND SC5_TMP.C5_NUM = '"+SC5->C5_NUM+"' "

TCQUERY CSQL ALIAS "QRY_SC5" NEW 

cLinha := QRY_SC5->C5_YLINHA
QRY_SC5->(DbCloseArea())

cQuery := ""
cQuery += " SELECT * FROM "

//EMAIL CONFIGURADO DE ACORDO COM A EMPRESA	
Do Case
Case Alltrim(cLinha) == '1' 
cQuery += " ZZI010 ZZI"

Case Alltrim(cLinha) == '2' 
cQuery += " ZZI050 ZZI"

Case Alltrim(cLinha) == '3' 
cQuery += " ZZI050 ZZI"

EndCase

cQuery += " WHERE ZZI.ZZI_VEND =  '" +cVendedor+ "' AND "
cQuery += " ZZI.D_E_L_E_T_= '' "

TCQUERY cQuery ALIAS "QRY_ATEND" NEW   

WHILE !QRY_ATEND->(EOF())

If(QRY_ATEND->ZZI_TPSEG == cTpSeg)
cAtendente := QRY_ATEND->ZZI_ATENDE
lAchou := .T.
EndIf 

If lAchou
exit
EndIf

QRY_ATEND->(DBSKIP())		
ENDDO    
QRY_ATEND->(DbCloseArea())
EndIf  

DbCloseArea("ZZI") 

If !Empty(cAtendente)
cAtendente := UsrRetMail(cAtendente) 
EndIf

If !('@' $ cAtendente)
cAtendente := ''
EndIf

Return cAtendente       
*/
