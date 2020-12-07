#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณ CLI_SPEEDบAutor  ณ MADALENO           บ Data ณ  14/05/09   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR ENVIAR OS CLIENTES QUE NAO FORAM        บฑฑฒ
ฒฑฑบ          ณ ATUALIZADOS PARA O SPEED E QUE TEM PEDIDOS EM ABERTO       บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8 - R4                                                   บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION CLI_SPEED(AA_EMPRESA)
PRIVATE ENTER		:= CHR(13)+CHR(10)
Private C_HTML  	:= ""
Private lOK        := .F.
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

CSQL := "SELECT A1_COD, A1_NOME, A1_CGC, A1_EST "
CSQL += "FROM "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SA1")+" SA1  "
CSQL += "WHERE	SA1.A1_COD = SC6.C6_CLI AND "
CSQL += "		A1_YATUCLI = 'N' AND "
CSQL += "		SC6.C6_QTDVEN - SC6.C6_QTDENT > 0 AND  "
CSQL += "		SC6.C6_BLQ	<>	'R' AND "
CSQL += "		SC6.D_E_L_E_T_ = '' AND "
CSQL += "		SA1.D_E_L_E_T_ = '' "
CSQL += "GROUP BY A1_COD, A1_NOME, A1_CGC, A1_EST "
CSQL += "ORDER BY A1_COD, A1_NOME "
IF CHKFILE("CLI_PEED")
	DBSELECTAREA("CLI_PEED")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "CLI_PEED" NEW


C_HTML  := ""
IF ! CLI_PEED->(EOF())
        
	C_HTML := ''
	C_HTML += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	C_HTML += '<head> '
	C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_HTML += '<title>Untitled Document</title> '
	C_HTML += '<style type="text/css"> '
	C_HTML += '<!-- '
	C_HTML += '.style12 {font-size: 9px; } '
	C_HTML += '.style18 {font-size: 10} '
	C_HTML += '.style21 {color: #FFFFFF; font-size: 9px; } '
	C_HTML += '.style22 { '
	C_HTML += '	font-size: 10pt; '
	C_HTML += '	font-weight: bold; '
	C_HTML += '} '
	C_HTML += '.style35 {font-size: 10pt; } '
	C_HTML += '.style36 {font-size: 9pt; } '
	C_HTML += '.style39 {font-size: 12pt; } '
	C_HTML += '.style41 { '
	C_HTML += '	font-size: 12px; '
	C_HTML += '	font-weight: bold; '
	C_HTML += '} '
	C_HTML += ' '
	C_HTML += '--> '
	C_HTML += '</style> '
	C_HTML += '</head> '
	C_HTML += ' '
	C_HTML += '<body> '
	C_HTML += '<table width="753" border="1"> '
	C_HTML += '  <tr> '
	C_HTML += '    <th width="568" rowspan="3" scope="col"> RELA&Ccedil;&Atilde;O CLIENTES QUE N&Atilde;O FORAM ATUALIZADOS PARA SPED COM PEDIDOS NรO ATENDIDOS </th> '
	C_HTML += '    <td width="169" class="style12"><div align="right"> DATA EMISSรO: '+ dtoC(DDATABASE) +' </div></td> '
	C_HTML += '  </tr> '
	C_HTML += '  <tr> '
	C_HTML += '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+SUBS(TIME(),1,8)+' </div></td> '
	C_HTML += '  </tr> '
	C_HTML += '  <tr> '
	IF CEMPANT = "05" 
		C_HTML += '    <td><div align="center" class="style41"> INCESA CERAMICA LTDA </div></td> '
	ELSE 
		C_HTML += '    <td><div align="center" class="style41"> BIANCOGRES CERยMICA SA </div></td> '
	END IF
	C_HTML += '  </tr> '
	C_HTML += '</table> '
	C_HTML += '<table width="754" border="1"> '
	C_HTML += '  <tr bgcolor="#0066CC"> '
	C_HTML += '    <th width="77"	scope="col"><span class="style21"> C&Oacute;DIGO</span></th> '
	C_HTML += '    <th width="418" 	scope="col"><span class="style21"> NOME </span></th> '
	C_HTML += '    <th width="164" 	scope="col"><span class="style21"> CNPJ </span></th> '
	C_HTML += '    <th width="67" 	scope="col"><span class="style21"> ESTADO </span></th> '
	C_HTML += '  </tr> '
	  
	DO WHILE ! CLI_PEED->(EOF())
		C_HTML += '  <tr bgcolor="#FFFFFF"> '
		C_HTML += '    <th scope="col"><div align="left" class="style41"> '+ ALLTRIM(CLI_PEED->A1_COD) +' </div></th> '
		C_HTML += '    <th scope="col"><div align="left" class="style41"> '+ ALLTRIM(CLI_PEED->A1_NOME) +' </div></th> '
		C_HTML += '    <th scope="col"><div align="left" class="style41"> '+ ALLTRIM(CLI_PEED->A1_CGC) +' </div></th> '
		C_HTML += '    <th scope="col"><div align="left" class="style41"> '+ ALLTRIM(CLI_PEED->A1_EST) +' </div></th> '
		C_HTML += '  </tr>
	
		CLI_PEED->(DBSKIP())		
	END DO 
	
	C_HTML += '</table> '
	C_HTML += '</body> '
	C_HTML += '</html> '

END IF

CLI_EMAIL()

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

cAssunto	:= "CLIENTES NรO ATUALIZADOS"							// Assunto do Email        

cRecebe := U_EmailWF('CLI_SPEED',CEMPANT)

U_BIAEnvMail(,cRecebe,cAssunto,C_HTML)

RETURN
