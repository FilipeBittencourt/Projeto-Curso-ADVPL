#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA192
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 09/04/2014
# DESCRICAO..: Workflow para faturamento de CFOP 5501_5502_6501_6502
#		FATURAMENTO DE DOCUMENTOS COMPROBATORIOS DA OPERACAO POR PARTE DO INTERMEDIARIO (EXPORTADOR) - OS:0153-13
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function BIA192()         

Local lEnvia := .F.  
Private C_HTML  	:= ""
Private lOK        := .F.
PRIVATE CSQL := ""               

//BUSCAR SE EXISTE AS CFOP'S ESPECIFICAS NA NOTA FISCAL
DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)

While ! Eof() .And.;
		SF2->F2_DOC     == SD2->D2_DOC     .And. ;
		SF2->F2_SERIE   == SD2->D2_SERIE   .And. ;
		SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. ;
		SF2->F2_LOJA 	== SD2->D2_LOJA    
		
		//If (Alltrim(SD2->D2_CF) $ "5501_5502_6501_6502") 
		If (Alltrim(SD2->D2_CF) $ GetMv("MV_YBIA192")) 
		
		 	lEnvia := .T.
			exit
		EndIf
			 
		SD2->(DbSkip())	
EndDo		    

SD2->(DbCloseArea())

If lEnvia
	GeraHtml()
EndIf

Return    

/*
##############################################################################################################
# PROGRAMA...: GeraHtml
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 28/02/2014
# DESCRICAO..: GERAR HTML PARA ENVIAR O EMAIL
##############################################################################################################
*/
Static Function GeraHtml()    

	C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	C_HTML += '<head> '
	C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_HTML += '<title>Untitled Document</title> '
	C_HTML += '<style type="text/css"> '
	C_HTML += '<!-- '
	C_HTML += '.style12 {font face="Arial"; font-size: 9px; } '
	C_HTML += '.style21 {font face="Arial"; color: #FFFFFF; font-size: 9px; } '
	C_HTML += '--> '
	C_HTML += '</style> '
	C_HTML += '</head> '
	C_HTML += ' '
	C_HTML += '<body> ' 

	//cabecalho	
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                        
	C_HTML += '<font face="Arial" color="white"> ' 	
	//C_HTML += '  <tr> '
	C_HTML += '    <th scope="col"><div align="center">WORKFLOW DE FATURAMENTO DE CFOP 5501/5502/6501/6502 <BR>'				
	C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '
	
	C_HTML += '<table width="900" border="0" bgcolor="#FFFFFF> '
	C_HTML += '<font face="Arial" color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '<font face="Arial" color="black" size = "8px" > ' 
	C_HTML += '    <th width="900" scope="col"><div align="left"> EMPRESA: '+Upper(SM0->M0_NOMECOM)
	C_HTML += '<br><br>  SERIE: '+Alltrim(SF2->F2_SERIE) 
	C_HTML += '<br><br>  NOTA FISCAL: '+Alltrim(SF2->F2_DOC) 
	C_HTML += '<br><br>  CLIENTE: '+Alltrim(SF2->F2_CLIENTE) 
	C_HTML += '<br><br>  LOJA: '+Alltrim(SF2->F2_LOJA)  
	C_HTML += '<br><br>  NOME CLIENTE: '+Alltrim(POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")) 
	C_HTML += '<br><br>  PEDIDO: '+Alltrim(SF2->F2_YPEDIDO)
//BUSCAR CLIENTE ORIGINAL	
	If (SF2->F2_CLIENTE =='010064')
		cSQL := "SELECT LC5.C5_NUM,LC5.C5_CLIENTE,LC5.C5_LOJACLI FROM SC5070 LC5 WHERE LC5.C5_YPEDORI = '"+SF2->F2_YPEDIDO+"' AND LC5.D_E_L_E_T_='' "    

	  	TCQUERY cSQL ALIAS "QRY" NEW 
	  	
		If !QRY->(EOF()) 
		
			C_HTML += '<br> CLIENTE ORIGINAL: '+Alltrim(QRY->C5_CLIENTE) 
			C_HTML += '<br> LOJA ORIGINAL: '+Alltrim(QRY->C5_LOJA)  
			C_HTML += '<br> NOME CLIENTE ORIGINAL: '+Alltrim(POSICIONE("SA1",1,xFilial("SA1")+QRY->C5_CLIENTE+QRY->C5_LOJA,"A1_NOME")) 
			C_HTML += '<br> PEDIDO ORIGINAL: '+Alltrim(QRY->C5_NUM)
		EndIf    

	 	QRY->(DbCloseArea())         
		
	EndIf
	
	C_HTML += '</th> '
	
	C_HTML += '</font>
	C_HTML += '<br><br> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> ' 

	//cabecalho colunas - itens
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                        
	C_HTML += '<font face="Arial" color="white"> ' 	
	//C_HTML += '  <tr> '
	C_HTML += '    <th scope="col"><div align="center">ITENS DA NOTA FISCAL <BR>'				
	C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '
	
	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2"> '
	C_HTML += '<font face="Arial" color="black" size="2"> ' 
	C_HTML += '<tr> ' 	
	C_HTML += '    <th width="40" scope="col"> ITEM </span></th> '   
	C_HTML += '    <th width="50" scope="col"> COD. PRODUTO </span></th> ' 
	C_HTML += '    <th width="150" scope="col"> DESC. PRODUTO </span></th> '  
	C_HTML += '    <th width="30" scope="col"> QUANTIDADE </span></th> ' 
	C_HTML += '    <th width="40" scope="col"> CFOP </span></th> '  
	C_HTML += '  </tr> '  
	                     	  
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)

	While ! Eof() .And.;
		SF2->F2_DOC     == SD2->D2_DOC     .And. ;
		SF2->F2_SERIE   == SD2->D2_SERIE   .And. ;
		SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. ;
		SF2->F2_LOJA 	== SD2->D2_LOJA    	   
                          
    	C_HTML += '<font face="Arial" color="black" size = "8px" > '
		C_HTML += '  <tr>   
		C_HTML += '    <td class="style12">'+ SD2->D2_ITEM +'</td> '
		C_HTML += '    <td class="style12">'+ SD2->D2_COD +'</td> '
		C_HTML += '    <td class="style12">'+ Alltrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")) +'</td> '
		C_HTML += '    <td class="style12">'+ TRANSFORM(SD2->D2_QUANT	,"@E 999,999,999.99") +'</td> '		
		C_HTML += '    <td class="style12">'+ SD2->D2_CF +'</td> ' 
		C_HTML += '  </tr>
		C_HTML += '</font>		    
                        

		SD2->(DbSkip())	
	EndDo
              
	SD2->(DbCloseArea())
	
	C_HTML += '<br></br>
	C_HTML += '</table> <br></br><br>'   
	 
	C_HTML += '<font face = "Arial"> <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA192).</p> </font>    		
	C_HTML += '<p>&nbsp;	</p> '
	C_HTML += '</body> '
	C_HTML += '</html> '
			
	//SENDMAIL()
	EnvMailMult()   
		 
RETURN   
//---------------------------------------------------------------------------------------------------
// (Thiago Dantas - 02/06/14) ***  Novo método de envio de email pegando parametros do servidor. ***
//---------------------------------------------------------------------------------------------------
Static Function EnvMailMult()

	cRecebe 	:= U_EmailWF('BIA192')
	cAssunto	:= "Faturamento de NF com CFOP 5501/5502/6501/6502 "
    cMensagem   := C_HTML
    
    U_BIAEnvMail(,cRecebe,cAssunto,cMensagem)
    
Return
//---------------------------------------------------------------------------------------------------