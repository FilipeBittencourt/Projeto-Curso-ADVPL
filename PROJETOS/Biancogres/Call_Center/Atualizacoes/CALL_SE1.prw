#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณCALL_SE1  บAutor  ณ MADALENO           บ Data ณ  30/03/10   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR OS TITULOS QUE TINHA QUE SER QUITADOS   บฑฑฒ
ฒฑฑบ          ณ E NAO FORAM QUITADOS                                       บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8 - R4                                                   บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION CALL_SE1(AA_EMPRESA)
PRIVATE ENTER		:= CHR(13)+CHR(10)
Private C_HTML  	:= ""
Private lOK        := .F.
PRIVATE N_FOLOWUP

IF TYPE("DDATABASE") <> "D"
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT" TABLES "ACG"
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
PRIVATE ENTER 		:= CHR(13)+CHR(10)
PRIVATE CSQL 		:= ""
PRIVATE S_CLIENTE 	:= ""
PRIVATE CHTML 		:= ''

CSQL := " SELECT '01' AS EMP, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO, " + ENTER
CSQL += " 		E1_VALOR, E1_SALDO, E1_PORCJUR, DATEDIFF(DAY,E1_VENCTO,GETDATE()) AS ATRASO, " + ENTER
CSQL += " 		ACG_CODIGO, ACG_YPREV, ACG_FILORI  " + ENTER
CSQL += " 		--,ACG.*, SE1.* " + ENTER
CSQL += " FROM ACG010 ACG, SE1010 SE1 " + ENTER
CSQL += " WHERE	ACG.ACG_YPREV = '"+DTOS(DDATABASE-1)+"' AND " + ENTER
CSQL += " 		RTRIM(ACG_TITULO)	= RTRIM(E1_NUM) AND " + ENTER
CSQL += " 		RTRIM(ACG_PREFIX)	= RTRIM(E1_PREFIXO) AND " + ENTER
CSQL += " 		RTRIM(ACG_PARCEL)	= RTRIM(E1_PARCELA) AND " + ENTER
CSQL += " 		RTRIM(ACG_TIPO)		= RTRIM(E1_TIPO) AND " + ENTER
CSQL += " 		ACG_FILORI = 'BI' AND " + ENTER
CSQL += " 		E1_SALDO <> 0 AND " + ENTER
CSQL += " 		ACG.D_E_L_E_T_ = '' AND " + ENTER
CSQL += " 		SE1.D_E_L_E_T_ = '' " + ENTER
CSQL += " UNION ALL " + ENTER
CSQL += " SELECT '05' AS EMP, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO, " + ENTER
CSQL += " 		E1_VALOR, E1_SALDO, E1_PORCJUR, DATEDIFF(DAY,E1_VENCTO,GETDATE()) AS ATRASO, " + ENTER
CSQL += " 		ACG_CODIGO, ACG_YPREV, ACG_FILORI  " + ENTER
CSQL += " 		--,ACG.*, SE1.* " + ENTER
CSQL += " FROM ACG010 ACG, SE1050 SE1 " + ENTER
CSQL += " WHERE	ACG.ACG_YPREV = '"+DTOS(DDATABASE-1)+"' AND " + ENTER
CSQL += " 		RTRIM(ACG_TITULO)	= RTRIM(E1_NUM) AND " + ENTER
CSQL += " 		RTRIM(ACG_PREFIX)	= RTRIM(E1_PREFIXO) AND " + ENTER
CSQL += " 		RTRIM(ACG_PARCEL)	= RTRIM(E1_PARCELA) AND " + ENTER
CSQL += " 		RTRIM(ACG_TIPO)		= RTRIM(E1_TIPO) AND " + ENTER
CSQL += " 		ACG_FILORI = 'IN' AND " + ENTER
CSQL += " 		E1_SALDO <> 0 AND " + ENTER
CSQL += " 		ACG.D_E_L_E_T_ = '' AND " + ENTER
CSQL += " 		SE1.D_E_L_E_T_ = '' " + ENTER
CSQL += " UNION ALL " + ENTER
CSQL += " SELECT  '07' AS EMP, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO, " + ENTER
CSQL += " 		E1_VALOR, E1_SALDO, E1_PORCJUR, DATEDIFF(DAY,E1_VENCTO,GETDATE()) AS ATRASO, " + ENTER
CSQL += " 		ACG_CODIGO, ACG_YPREV, ACG_FILORI  " + ENTER
CSQL += " 		--,ACG.*, SE1.* " + ENTER
CSQL += " FROM ACG010 ACG, SE1070 SE1 " + ENTER
CSQL += " WHERE	ACG.ACG_YPREV = '"+DTOS(DDATABASE-1)+"' AND " + ENTER
CSQL += " 		RTRIM(ACG_TITULO)	= RTRIM(E1_NUM) AND " + ENTER
CSQL += " 		RTRIM(ACG_PREFIX)	= RTRIM(E1_PREFIXO) AND " + ENTER
CSQL += " 		RTRIM(ACG_PARCEL)	= RTRIM(E1_PARCELA) AND " + ENTER
CSQL += " 		RTRIM(ACG_TIPO)		= RTRIM(E1_TIPO) AND " + ENTER
CSQL += " 		ACG_FILORI = 'LM' AND " + ENTER
CSQL += " 		E1_SALDO <> 0 AND " + ENTER
CSQL += " 		ACG.D_E_L_E_T_ = '' AND " + ENTER
CSQL += " 		SE1.D_E_L_E_T_ = '' " + ENTER

// Vitcer - OS: 2087-14 - Usuแrio: Clebes Jose Andre
CSQL += " UNION ALL " + ENTER
CSQL += " SELECT  '14' AS EMP, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO, " + ENTER
CSQL += " 		E1_VALOR, E1_SALDO, E1_PORCJUR, DATEDIFF(DAY,E1_VENCTO,GETDATE()) AS ATRASO, " + ENTER
CSQL += " 		ACG_CODIGO, ACG_YPREV, ACG_FILORI  " + ENTER
CSQL += " 		--,ACG.*, SE1.* " + ENTER
CSQL += " FROM ACG010 ACG, SE1140 SE1 " + ENTER
CSQL += " WHERE	ACG.ACG_YPREV = '"+DTOS(DDATABASE-1)+"' AND " + ENTER
CSQL += " 		RTRIM(ACG_TITULO)	= RTRIM(E1_NUM) AND " + ENTER
CSQL += " 		RTRIM(ACG_PREFIX)	= RTRIM(E1_PREFIXO) AND " + ENTER
CSQL += " 		RTRIM(ACG_PARCEL)	= RTRIM(E1_PARCELA) AND " + ENTER
CSQL += " 		RTRIM(ACG_TIPO)		= RTRIM(E1_TIPO) AND " + ENTER
CSQL += " 		ACG_FILORI = 'VC' AND " + ENTER
CSQL += " 		E1_SALDO <> 0 AND " + ENTER
CSQL += " 		ACG.D_E_L_E_T_ = '' AND " + ENTER
CSQL += " 		SE1.D_E_L_E_T_ = '' " + ENTER

CSQL += " 		ORDER BY E1_CLIENTE " + ENTER

IF CHKFILE("_TABELA")
	DBSELECTAREA("_TABELA")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TABELA" NEW


IF ! _TABELA->(EOF())
	S_CLIENTE := _TABELA->E1_CLIENTE
	S_NOME 		:= 	ALLTRIM(Posicione("SA1",1,xFilial("SA1")+_TABELA->E1_CLIENTE+_TABELA->E1_LOJA,"A1_NOME"))
	CHTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	CHTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	CHTML += '<head> '
	CHTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	CHTML += '<title>Untitled Document</title> '
	CHTML += '<style type="text/css"> '
	CHTML += '<!-- '
	CHTML += '.style12 {font-size: 9px; } '
	CHTML += '.style35 {font-size: 10pt; } '
	CHTML += '.style41 { '
	CHTML += '	font-size: 12px; '
	CHTML += '	font-weight: bold; '
	CHTML += '} '
	CHTML += '.style44 {color: #FFFFFF; font-size: 10px; } '
	CHTML += '.style45 {font-size: 10px; } '
	CHTML += ' '
	CHTML += '--> '
	CHTML += '</style> '
	CHTML += '</head> '
	CHTML += ' '
	CHTML += '<body> '
	CHTML += '<table width="956" border="1"> '
	CHTML += '  <tr> '
	CHTML += '    <th width="751" rowspan="3" scope="col"> TอTULOS VENCIDOS NO DIA: '+ dtoC(DDATABASE-1) +'  </th> '
	CHTML += '    <td width="189" class="style12"><div align="right"> DATA EMISSรO: '+ dtoC(DDATABASE) +' </div></td> '
	CHTML += '  </tr> '
	CHTML += '  <tr> '
	CHTML += '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+SUBS(TIME(),1,8)+' </div></td> '
	CHTML += '  </tr> '
	CHTML += '  <tr> '
	CHTML += '    <td><div align="center" class="style41"> BIANCOGRES CERยMICA SA </div></td> '
	CHTML += '  </tr> '
	CHTML += '</table> '
	CHTML += ' '
	CHTML += '<table width="957" border="1"> '
	CHTML += '  <tr bgcolor="#0066CC"> '
	CHTML += '    <th width="100"	scope="col"><span class="style44"> PRF-NUM -PARC </span></th> '
	CHTML += '    <th width="68" scope="col"><span class="style44"> VENC. </span></th> '
	CHTML += '    <th width="79" scope="col"><span class="style44">VAL. TIT.</span></th> '
	CHTML += '    <th width="83" scope="col"><span class="style44">SALDO</span></th> '
	CHTML += '    <th width="80" scope="col"><span class="style44">SAL. JUROS</span></th> '
	CHTML += '    <th width="89" scope="col"><span class="style44"> DIAS DE ATRASO </span></th> '
	CHTML += '    <th width="80" scope="col"><span class="style44"> JUROS </span></th> '
	CHTML += '    <th width="412" scope="col"><span class="style44">HIST&Oacute;RICO </span></th> '
	CHTML += '  </tr> '
	CHTML += ' 		  <tr bgcolor="#FFFFFF"> '
	CHTML += ' 	    <th colspan="8" scope="col"><div align="left" class="style35">CLIENTE: '+S_CLIENTE+' - '+ S_NOME +' </div></th> '
	CHTML += ' 	  </tr> '
ELSE
	RETURN
END IF

I := 1
DO WHILE ! _TABELA->(EOF())
	
	I ++
	IF S_CLIENTE <> _TABELA->E1_CLIENTE
		S_CLIENTE := _TABELA->E1_CLIENTE
		S_NOME := 	ALLTRIM(Posicione("SA1",1,xFilial("SA1")+_TABELA->E1_CLIENTE+_TABELA->E1_LOJA,"A1_NOME"))
		CHTML += ' 	  <tr bordercolor="#FFFFFF"> '
		CHTML += ' 	    <td colspan="8">&nbsp;</td> '
		CHTML += ' 	  </tr> '
		CHTML += ' 	  <tr bgcolor="#FFFFFF"> '
		CHTML += ' 	    <th colspan="8" scope="col"><div align="left" class="style35">CLIENTE: '+S_CLIENTE+' - '+ S_NOME +' </div></th> '
		CHTML += ' 	  </tr>  '
	END IF
	
	
	CHTML += '   <tr> '
	CHTML += '     <td class="style45"> '+ALLTRIM(_TABELA->E1_PREFIXO)+' '+ALLTRIM(_TABELA->E1_NUM)+' '+ALLTRIM(_TABELA->E1_PARCELA)+' '+ALLTRIM(_TABELA->E1_TIPO)+' </td> '
	CHTML += '     <td class="style45"> '+DTOC(STOD(_TABELA->E1_VENCTO))+' </td> '
	CHTML += '     <td class="style45"> '+ TRANSFORM(_TABELA->E1_VALOR	,"@E 999,999,999.99") +' </td> '
	CHTML += '     <td class="style45"> '+ TRANSFORM(_TABELA->E1_SALDO	,"@E 999,999,999.99") +' </td> '
	
	CSALDO_JUROS := (_TABELA->E1_SALDO  / 100)   *    (_TABELA->E1_PORCJUR*_TABELA->ATRASO)
	
	CHTML += '     <td class="style45"> '+ TRANSFORM(_TABELA->E1_SALDO + CSALDO_JUROS	,"@E 999,999,999.99") +' </td> '
	CHTML += '     <td class="style45"> '+ALLTRIM(STR(_TABELA->ATRASO))+' </td> '
	CHTML += '     <td class="style45"> '+ TRANSFORM(CSALDO_JUROS	,"@E 999,999,999.99") +' </td> '
	
	
	CCOBS := ""
	// BUSCANDO O ULTIMO CODIGO DO ATENDIMENTO
	CSQL := " SELECT MAX(R_E_C_N_O_) AS R_E_C_N_O_  " + ENTER
	CSQL += " FROM "+RETSQLNAME("ACG")+" " + ENTER
	CSQL += " WHERE	RTRIM(ACG_TITULO) = '"+ALLTRIM(_TABELA->E1_NUM)+"' AND " + ENTER
	CSQL += " 			RTRIM(ACG_PREFIX) = '"+ALLTRIM(_TABELA->E1_PREFIXO)+"' AND " + ENTER
	CSQL += " 			RTRIM(ACG_PARCEL) = '"+ALLTRIM(_TABELA->E1_PARCELA)+"' AND " + ENTER
	CSQL += " 			RTRIM(ACG_TIPO) = '"+ALLTRIM(_TABELA->E1_TIPO)+"' AND " + ENTER
	CSQL += " 			D_E_L_E_T_ = ''  AND ACG_FILORI = '"+ _TABELA->ACG_FILORI+"' " + ENTER
	IF CHKFILE("_CODIGO")
		DBSELECTAREA("_CODIGO")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_CODIGO" NEW
	
	IF _TABELA->ACG_FILORI = "BI"
		CCOBS := "BIANCO  -  "
	ELSEIF _TABELA->ACG_FILORI = "IN"
		CCOBS := "INCESA  -  "
	ELSE
		CCOBS := "LM  -  "
	END IF
	IF ! _CODIGO->(EOF())
		// BUSCANDO O CODIGO DE OBSERVACAO
		//CSQL := " SELECT ACF_CODOBS FROM "+RETSQLNAME("ACF")+" WHERE ACF_CODIGO = '"+_CODIGO->ACG_CODIGO+"' AND D_E_L_E_T_ = '' "
		CSQL := " SELECT ACG_HIST FROM ACG010 WHERE R_E_C_N_O_ = '"+ALLTRIM(STR(_CODIGO->R_E_C_N_O_))+"' AND D_E_L_E_T_ = '' "
		IF CHKFILE("_OBS")
			DBSELECTAREA("_OBS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_OBS" NEW
		
		
		//CSQL := " SELECT * FROM SYP010 WHERE YP_CHAVE = '"+_OBS->ACF_CODOBS+"' AND D_E_L_E_T_ = '' ORDER BY YP_SEQ "
		//IF CHKFILE("_AUX")
		//	DBSELECTAREA("_AUX")
		//	DBCLOSEAREA()
		//ENDIF
		//TCQUERY CSQL ALIAS "_AUX" NEW
		//DO WHILE ! _AUX->(EOF())
		//	CCOBS += _AUX->YP_TEXTO
		//	_AUX->(DBSKIP())
		//END IF
		CCOBS += ALLTRIM(_OBS->ACG_HIST	)
	END IF
	CHTML += '     <td class="style45"> '+CCOBS+' </td> '
	CHTML += '   </tr> '
	
	_TABELA->(DBSKIP())
	
END DO

CHTML += '   <tr bordercolor="#FFFFFF"> '
CHTML += '     <td colspan="8">&nbsp;</td> '
CHTML += '   </tr> '
CHTML += ' </table> '
CHTML += ' <span class="style35">Esta ้ uma mensagem automแtica, favor nใo responde-la. (Fonte: CALL_SE1.prw) </span> '
CHTML += ' </body> '
CHTML += ' </html> '


cRecebe  := U_EmailWF('CALL_SE1',cEmpAnt)
cAssunto := "TITULOS EM ATRASO."							// Assunto do Email

U_BIAEnvMail(,cRecebe,cAssunto,CHTML)

RETURN