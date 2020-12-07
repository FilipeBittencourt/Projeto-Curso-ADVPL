#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณW_MOV_INT บAutor  ณ MADALENO           บ Data ณ  14/05/09   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR ENVIAR AS MOVIMENTAวีES INTERNAS        บฑฑฒ
ฒฑฑบ          ณ REFERENTES A PRODUCAO DE DETRMINADOS PRODUTOS.             บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8 - R4                                                   บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION W_MOV_INT(AA_EMPRESA)
PRIVATE ENTER		:= CHR(13)+CHR(10)
Private C_HTML  	:= ""
Private lOK        := .F.
PRIVATE N_FOLOWUP
PRIVATE D_DATAA

IF TYPE("DDATABASE") <> "D"
	PREPARE ENVIRONMENT EMPRESA AA_EMPRESA FILIAL "01" MODULO "FAT" TABLES "SD3"
END IF

Processa({|| GER_ARQUIV()})

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ GER_ARQUIV          บAutor  ณ MADALENO           บ Data ณ  26/06/07   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       FUNCAO PARA CRIAR O ARQUIVO HTML E DEPOIS GERAR O EMAIL    บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GER_ARQUIV()
PRIVATE ENTER := CHR(13) + CHR(10)

CSQL := "SELECT D3_DOC, D3_EMISSAO, D3_COD, D3_QUANT, D3_LOTECTL, B1_DESC " + ENTER
CSQL += "FROM "+RETSQLNAME("SD3")+" SD3, SB1010 SB1 " + ENTER
CSQL += "WHERE	D3_EMISSAO = '"+DTOS(DDATABASE)+"' AND " + ENTER
//CSQL += "WHERE	D3_EMISSAO = '20100225' AND " + ENTER
// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produ็ใo/Apura็ใo de Custo.
//CSQL += "		(D3_TM = '500' OR D3_TM = '501')AND " + ENTER
CSQL += "		( D3_TM = '500' OR D3_TM = '501' OR D3_YORIMOV = 'PR0' )AND " + ENTER
CSQL += "		B1_COD = D3_COD AND  " + ENTER
CSQL += "		(UPPER(B1_DESC) LIKE '%PORFIDO%' OR  " + ENTER
CSQL += "		 UPPER(B1_DESC) LIKE '%VERSATILE%' OR  " + ENTER
CSQL += "		 UPPER(B1_DESC) LIKE '%STRUTTURA%' OR  " + ENTER
CSQL += "		 UPPER(B1_DESC) LIKE '%PIETRA LASCATA%' OR  " + ENTER
CSQL += "		 UPPER(B1_DESC) LIKE '%IMPERIA BIANCO%') AND " + ENTER
CSQL += "		SD3.D_E_L_E_T_ = '' AND " + ENTER
CSQL += "		SB1.D_E_L_E_T_ = '' " + ENTER
IF CHKFILE("_SD3")
	DBSELECTAREA("_SD3")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_SD3" NEW


C_HTML  := ""
IF ! _SD3->(EOF())
        
	C_HTML += ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_HTML += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	C_HTML += ' <head> '
	C_HTML += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_HTML += ' <title>Untitled Document</title> '
	C_HTML += ' <style type="text/css"> '
	C_HTML += ' <!-- '
	C_HTML += ' .style12 {font-size: 9px; } '
	C_HTML += ' .style21 {color: #FFFFFF; font-size: 9px; } '
	C_HTML += ' .style41 { '
	C_HTML += ' 	font-size: 12px; '
	C_HTML += ' 	font-weight: bold; '
	C_HTML += ' } '
	C_HTML += ' .style42 {font-size: 10} '
	C_HTML += '  '
	C_HTML += ' --> '
	C_HTML += ' </style> '
	C_HTML += ' </head> '
	C_HTML += '  '
	C_HTML += ' <body> '
	C_HTML += ' <table width="753" border="1"> '
	C_HTML += '   <tr> '
	C_HTML += '     <th width="568" rowspan="3" scope="col"> RELAวรO DAS MOVIMENTAวีES REFENTE A PRODUวรO </th> '
	C_HTML += '    <td width="169" class="style12"><div align="right"> DATA EMISSรO: '+ dtoC(DDATABASE) +' </div></td> '
	C_HTML += '  </tr> '
	C_HTML += '  <tr> '
	C_HTML += '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+SUBS(TIME(),1,8)+' </div></td> '
	C_HTML += '   </tr> '
	C_HTML += '   <tr> '
	IF CEMPANT = "05" 
		C_HTML += '    <td><div align="center" class="style41"> INCESA CERAMICA LTDA </div></td> '
	ELSE 
		C_HTML += '    <td><div align="center" class="style41"> BIANCOGRES CERยMICA SA </div></td> '
	END IF
	C_HTML += '   </tr> '
	C_HTML += ' </table> '
	C_HTML += ' <table width="754" border="1"> '
	C_HTML += '   <tr bgcolor="#0066CC"> '
	C_HTML += '     <th width="77"	scope="col"><span class="style21"> CำDIGO </span></th> '
	C_HTML += '     <th width="450" 	scope="col"><span class="style21"> PRODUTO </span></th> '
	C_HTML += '     <th width="123" 	scope="col"><span class="style21"> DATA </span></th> '
	C_HTML += '     <th width="76" 	scope="col"><span class="style21"> QUANT </span></th> '
	C_HTML += ' 	<th width="46" 	scope="col"><span class="style21"> LOTE </span></th> '
	C_HTML += '  ' 
	
	DO WHILE ! _SD3->(EOF())
			C_HTML += ' 	</tr> '
			C_HTML += ' 		<tr bgcolor="#FFFFFF">  '
			C_HTML += ' 		<th scope="col"><div align="left" class="style41"> '+ALLTRIM(_SD3->D3_DOC)+' </div></th>  '
			C_HTML += ' 		<th scope="col"><div align="left" class="style41"> '+ALLTRIM(_SD3->D3_COD)+' - ' + ALLTRIM(_SD3->B1_DESC)+' </div></th>  '
			C_HTML += ' 		<th scope="col"><div align="center" class="style41"> '+ALLTRIM(DTOC(STOD(D3_EMISSAO)))+' </div></th>  '
			C_HTML += ' 		<th scope="col"><div align="left" class="style41"> '+TRANSFORM(_SD3->D3_QUANT	,"@E 999,999,999.99")+' </div></th>  '
			C_HTML += ' 		<th scope="col"><div align="left" class="style41"> '+ALLTRIM(_SD3->D3_LOTECTL)+' </div></th> '
			C_HTML += ' 	</tr> '
			_SD3->(DBSKIP())		
	END DO 
	C_HTML += '  '
	C_HTML += ' </table> '
	C_HTML += ' </body> '
	C_HTML += ' </html> '

CLI_EMAIL()
END IF

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ COMIS_EMAIL         บAutor  ณ MADALENO           บ Data ณ  26/06/07   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       ROTINA PARA GERAR O EMAIL E ENVIAR O MESMO                 บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿                                        
*/
STATIC FUNCTION CLI_EMAIL()

cRecebe := U_EmailWF('W_MOV_INT',cEmpAnt)  

If (Empty(cEmail))
	cEmail := "wanisay.william@biancogres.com.br"
EndIf
cAssunto	:= "Movimenta็ใo de produ็ใo."							// Assunto do Email

U_BIAEnvMail(,cRecebe,cAssunto,C_HTML)

RETURN
