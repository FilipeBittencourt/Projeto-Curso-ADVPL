#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณ WORK_RESEบAutor  ณ MADALENO           บ Data ณ  26/01/09   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR AS RESERVAS REALIZADAS A MAIS DE 10 DIASบฑฑฒ
ฒฑฑบ          ณ                                                            บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8 - R4                                                   บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION WORK_RESE(AA_EMPRESA)
PRIVATE ENTER		:= CHR(13)+CHR(10)
Private cEmail    	:= ""
Private C_HTML  	:= ""
Private lOK        	:= .F.
PRIVATE CREMETENTE	:= ""
PRIVATE N_FOLOWUP
PRIVATE D_DATAA

IF TYPE("DDATABASE") <> "D"
	PREPARE ENVIRONMENT EMPRESA AA_EMPRESA FILIAL "01" MODULO "FAT" TABLES "SC5,SC6"
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

PRIVATE CEMAIL := ""


CSQL := "SELECT  C0_NUM, C0_SOLICIT, C0_EMISSAO, C0_VALIDA, C0_PRODUTO, B1_DESC, C0_QUANT, C0_LOTECTL  " + ENTER
CSQL += "FROM "+RETSQLNAME("SC0")+" SC0, SB1010 SB1 " + ENTER
CSQL += "WHERE	SC0.C0_PRODUTO = SB1.B1_COD AND " + ENTER
CSQL += "		DATEADD(DAY,10,SC0.C0_EMISSAO) < GETDATE() AND  " + ENTER
CSQL += "		SC0.C0_QUANT > 0 AND " + ENTER
CSQL += "		SC0.D_E_L_E_T_ = '' AND " + ENTER
CSQL += "		SB1.D_E_L_E_T_ = '' " + ENTER
CSQL += "ORDER BY C0_EMISSAO " + ENTER
IF CHKFILE("_RESERVA")
	DBSELECTAREA("_RESERVA")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_RESERVA" NEW


C_HTML  := ""
IF ! _RESERVA->(EOF())
        
	C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	C_HTML += '<head> '
	C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_HTML += '<title>Untitled Document</title> '
	C_HTML += '<style type="text/css"> '
	C_HTML += '<!-- '
	C_HTML += '.style12 {font-size: 9px; } '
	C_HTML += '.style21 {color: #FFFFFF; font-size: 9px; } '
	C_HTML += '.style41 { '
	C_HTML += '	font-size: 12px; '
	C_HTML += '	font-weight: bold; '
	C_HTML += '} '
	C_HTML += '.style42 {font-size: 10} '
	C_HTML += ' '
	C_HTML += '--> '
	C_HTML += '</style> '
	C_HTML += '</head> '
	C_HTML += ' '
	C_HTML += '<body> '               '
	C_HTML += '<table width="940" border="1"> '
	C_HTML += '  <tr> '
	C_HTML += '    <th width="732" rowspan="3" scope="col"> RELA&Ccedil;&Atilde;O DAS RESERVAS RELAIZADAS A MAIS DE 10 DIAS </th> '
	C_HTML += '    <td width="192" class="style12"><div align="right"> DATA EMISSรO: '+ dtoC(DDATABASE) +' </div></td> '
	C_HTML += '  </tr> '
	C_HTML += '  <tr> '
	C_HTML += '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+SUBS(TIME(),1,8)+' </div></td> '
	C_HTML += '  </tr> '
	C_HTML += '  <tr> '
	C_HTML += ' '
	IF CEMPANT = "05"
	C_HTML += '    <td><div align="center" class="style41"> INCESA REVESTIMENTO CERยMICO LTDA </div></td> '
	ELSE
	C_HTML += '    <td><div align="center" class="style41"> BIANCOGRES CERยMICA SA </div></td> '
	END IF 
	C_HTML += ' '

	C_HTML += '  </tr> '
	C_HTML += '</table> '
	C_HTML += '<table width="940" border="1"> '
	C_HTML += '  <tr bgcolor="#0066CC"> '
	C_HTML += '    <th width="73"	scope="col"><span class="style21"> Nบ RESERVA </span></th> '
	C_HTML += '    <th width="152"	scope="col"><span class="style21"> USUมRIO </span></th> '
	C_HTML += '    <th width="70" 	scope="col"><span class="style21"> EMISSรO </span></th> '
	C_HTML += '	<th width="75" 	scope="col"><span class="style21"> VALIDADE </span></th> '
	C_HTML += '    <th width="103" scope="col"><span class="style21"> PRODUTO </span></th> '
	C_HTML += '    <th width="293" scope="col"><span class="style21"> DESCRIวรO </span></th> '
	C_HTML += '    <th width="37" 	scope="col"><span class="style21"> LOTE </span></th> '
	C_HTML += '    <th width="85" 	scope="col"><span class="style21"> QUANT. </span></th> '


	
	DO WHILE ! _RESERVA->(EOF())
		// IMPRIMINDO OS PEDIDOS		
		C_HTML += '		<tr bgcolor="#FFFFFF"> '
		C_HTML += '		<th scope="col"><div align="left" class="style41"> '+ _RESERVA->C0_NUM +' </div></th> '
		C_HTML += '		<th scope="col"><div align="left" class="style41"> '+ _RESERVA->C0_SOLICIT +' </div></th>  '
		C_HTML += '		<th scope="col"><div align="left" class="style41"> '+ DTOC(STOD(_RESERVA->C0_EMISSAO)) +' </div></th>  '
		C_HTML += '		<th scope="col"><div align="left" class="style41"> '+ DTOC(STOD(_RESERVA->C0_VALIDA)) +' </div></th>  '
		C_HTML += '		<th scope="col"><div align="left" class="style41"> '+ _RESERVA->C0_PRODUTO +' </div></th>  '
		C_HTML += '		<th scope="col"><div align="left" class="style41"> '+ _RESERVA->B1_DESC +' </div></th>  '
		C_HTML += '		<th scope="col"><div align="left" class="style41"> '+ _RESERVA->C0_LOTECTL +' </div></th> '
		C_HTML += '		<th scope="col"><div align="left" class="style41"> '+ TRANSFORM(_RESERVA->C0_QUANT	,"@E 999,999,999.99") +' </div></th>  '
		_RESERVA->(DBSKIP())		
	END DO 

	// RODAPE DO EMAIL
	C_HTML += '	</tr> '
	C_HTML += '	</table> '
	C_HTML += '	</body> '
	C_HTML += '	</html> '

	COMIS_EMAIL()
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
STATIC FUNCTION COMIS_EMAIL()        

IF CEMPANT = "01"
	cRecebe     := "wanisay.william@biancogres.com.br" // CEMAIL
	cRecebeCC	:= "" 
ELSE
	cRecebe     := "wanisay.william@biancogres.com.br" // CEMAIL
	cRecebeCC	:= ""
END IF
cRecebeCO	:= ""
cAssunto	:= "Reservas realizadas a mais de 10 dias"

U_BIAEnvMail(,cRecebe,cAssunto,C_HTML)

RETURN