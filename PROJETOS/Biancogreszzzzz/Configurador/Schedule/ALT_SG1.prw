#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณ ALT_SG1  บAutor  ณ MADALENO           บ Data ณ  14/05/09   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR PARA O CUSTOS E INFORMATICA             บฑฑฒ
ฒฑฑบ          ณ COM AS ALTERACOES DIARIAS DA ESTRUTURA DO PRODUTO          บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8 - R4                                                   บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION ALT_SG1(AA_EMPRESA)

	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private C_HTML  	:= ""
	Private lOK        := .F.
	PRIVATE N_FOLOWUP
	PRIVATE D_DATAA

	IF TYPE("DDATABASE") <> "D"
		PREPARE ENVIRONMENT EMPRESA AA_EMPRESA FILIAL "01" MODULO "EST" TABLES "SG1"
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

	CSQL := "SELECT  RTRIM(AT_NAME) AS USUARIO, (SUBSTRING(AT_DATE,5,2) + '/' + SUBSTRING(AT_DATE,1,4)) MES_ANO, CONVERT(VARCHAR(10),CONVERT(DATETIME,AT_DATE),103) AS DATAA, AT_TIME AS HORAA, " + ENTER
	CSQL += "        OPERACAO = CASE  " + ENTER
	CSQL += "                    WHEN AT_OP = 'I' THEN 'INCLUSรO'  " + ENTER
	CSQL += "                    WHEN AT_OP = 'U' THEN 'ALTERAวรO'  " + ENTER
	CSQL += "                    WHEN AT_OP = 'D' THEN 'EXCLUSรO'  " + ENTER
	CSQL += "                    WHEN AT_OP = 'O' THEN 'PROGRAMA'  " + ENTER
	CSQL += "                    WHEN AT_OP = 'X' THEN 'COMANDO SQL'  " + ENTER
	CSQL += "                    ELSE AT_OP END,  " + ENTER
	CSQL += "        RTRIM(AT_TABLE) AS TABELA, AT_RECID AS RECNOO, RTRIM(AT_FIELD) AS CAMPO, RTRIM(AT_CONTENT) AS CONTEUDO,  " + ENTER
	CSQL += "        ISNULL(CONVERT(VARCHAR(500),CONVERT(BINARY(500),AT_EXECUTE)),'') AS 'COMANDO SQL'  " + ENTER
	//CSQL += "FROM AUDITORIA..AUDIT_TRAIL  " + ENTER
	//CSQL += "FROM DADOSAUDIT_2014..AUDIT_TRAIL  " + ENTER
	//CSQL += "FROM DADOSAUDIT_2015..AUDIT_TRAIL  " + ENTER
	//CSQL += "FROM DADOSAUDIT_2016..AUDIT_TRAIL  " + ENTER
	//CSQL += "FROM ZEUS.DADOSAUDIT_2017.dbo.AUDIT_TRAIL  " + ENTER
	//CSQL += "FROM ZEUS.DADOSAUDIT_2019.dbo.AUDIT_TRAIL  " + ENTER
	CSQL += "FROM ZEUS.DADOSAUDIT_2020.dbo.AUDIT_TRAIL  " + ENTER
	CSQL += "WHERE	AT_DATE >= '"+  DTOS(DDATABASE) +"' AND  " + ENTER
	CSQL += "		UPPER(AT_TABLE)    =  UPPER('" + RetSqlName("SG1") + "')  " + ENTER
	CSQL += "ORDER BY AT_DATE, AT_TIME " + ENTER
	IF CHKFILE("FOR_PEED")
		DBSELECTAREA("FOR_PEED")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "AUD_TRA" NEW   

	IF AUD_TRA->(EOF()) 
		DBCLOSEAREA()
		RETURN
	END IF

	C_HTML := ''
	C_HTML += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
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
	C_HTML += '<body> '
	C_HTML += '<table width="1200" border="1"> '
	C_HTML += '  <tr> '
	C_HTML += '    <th width="732" rowspan="3" scope="col"> RELA&Ccedil;&Atilde;O DAS ALTERA&Ccedil;&Otilde;ES DIARIAS NA ESTRUTURA DE PRODUTOS </th> '
	C_HTML += '    <td width="192" class="style12"><div align="right"> DATA EMISSรO: '+ dtoC(DDATABASE) +' </div></td> '
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
	C_HTML += '<table width="1200" border="1"> '
	C_HTML += '  <tr bgcolor="#0066CC"> '
	C_HTML += '    <th width="77"	scope="col"><span class="style21"> USU&Aacute;RIO </span></th> '
	C_HTML += '    <th width="77"	scope="col"><span class="style21"> C&Oacute;D PRODUTO </span></th> '
	C_HTML += '    <th width="218" 	scope="col"><span class="style21"> DESCRI&Ccedil;&Atilde;O </span></th> '

	C_HTML += '    <th width="77"	scope="col"><span class="style21"> COMPONENTE </span></th> '
	C_HTML += '    <th width="218" 	scope="col"><span class="style21"> DESCRIวรO  </span></th> '

	C_HTML += '    <th width="119" 	scope="col"><span class="style21"> DATA / HORA </span></th> '
	C_HTML += '    <th width="111" 	scope="col"><span class="style21"> TIPO</span></th> '
	C_HTML += '    <th width="86" 	scope="col"><span class="style21"> CAMPO </span></th> '
	C_HTML += '    <th width="100" 	scope="col"><span class="style21"> DE CONTEUDO </span></th> '
	C_HTML += '    <th width="100" 	scope="col"><span class="style21"> PARA CONTEUDO </span></th> '


	DO WHILE ! AUD_TRA->(EOF())


		CSQL := "SELECT SB1.B1_DESC, SG1.* " + ENTER
		CSQL += "FROM " + RetSqlName("SG1") + " SG1, SB1010 SB1 " + ENTER
		CSQL += "WHERE	SG1.R_E_C_N_O_ = '"+ALLTRIM(STR(AUD_TRA->RECNOO))+"' AND " + ENTER
		CSQL += "		SG1.G1_COD = SB1.B1_COD AND " + ENTER
		CSQL += "		SB1.D_E_L_E_T_ = '' " + ENTER
		IF CHKFILE("_REGIS")
			DBSELECTAREA("_REGIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_REGIS" NEW   

		IF ! _REGIS->(EOF())
			_AA_ := " "
			IF ALLTRIM(AUD_TRA->CAMPO) <> ""
				_AA_ := "_REGIS->" +  ALLTRIM(AUD_TRA->CAMPO)
			END IF
			C_HTML += '<tr bgcolor="#FFFFFF">
			C_HTML += '<th scope="col"><div align="left" class="style41"> '+ALLTRIM(AUD_TRA->USUARIO)+' </div></th> '
			C_HTML += '<th scope="col"><div align="left" class="style41"> '+ALLTRIM(_REGIS->G1_COD)+' </div></th>  '
			C_HTML += '<th scope="col"><div align="left" class="style41"> '+ALLTRIM(_REGIS->B1_DESC)+' </div></th>  '

			C_HTML += '<th scope="col"><div align="left" class="style41"> '+ALLTRIM(_REGIS->G1_COMP)+' </div></th>  '
			C_HTML += '<th scope="col"><div align="left" class="style41"> '+ALLTRIM(Posicione("SB1",1,xFilial("SB1")+_REGIS->G1_COMP,"B1_DESC"))+' </div></th>  

			C_HTML += '<th scope="col"><div align="left" class="style41"> '+(AUD_TRA->DATAA) +" - " +(AUD_TRA->HORAA)+' </div></th>  '
			C_HTML += '<th scope="col"><div align="left" class="style41"> '+AUD_TRA->OPERACAO+' </div></th>  '
			C_HTML += '<th scope="col"><div align="left" class="style41"> '+ALLTRIM(AUD_TRA->CAMPO)+' </div></th>  '
			C_HTML += '<th scope="col"><div align="left" class="style41"> '+AUD_TRA->CONTEUDO+' </div></th> '

			IF ALLTRIM(AUD_TRA->CAMPO) <> ""
				_AA_ := "_REGIS->" +  ALLTRIM(AUD_TRA->CAMPO)
				IF ALLTRIM(AUD_TRA->CAMPO) $("G1_COD_G1_COMP_G1_TRT_G1_NIV_G1_OBSERV_G1_FIXVAR_G1_NIVINV_G1_GROPC_G1_REVINI_G1_OPC_G1_REVFIM_G1_YEQUIPA_G1_YDENSID_G1_YVISCOS_G1_YCAMADA_G1_YROLCIL")
					C_HTML += '<th scope="col"><div align="left" class="style41"> '+ &_AA_ +' </div></th>  '
				ELSEIF ALLTRIM(AUD_TRA->CAMPO) $("G1_QUANT_G1_PERDA_G1_YINCESP_G1_YPRSESP_G1_YALTCIL_G1_POTENCI")
					C_HTML += '<th scope="col"><div align="left" class="style41"> '+ ALLTRIM(STR(&_AA_)) +' </div></th>  '
				ELSEIF ALLTRIM(AUD_TRA->CAMPO) $("DATA_G1_INI_G1_FIM")
					C_HTML += '<th scope="col"><div align="left" class="style41"> '+ dtoc(stod(&_AA_)) +' </div></th>  '
				END IF
			ELSE
				C_HTML += '<th scope="col"><div align="left" class="style41"> '+ " " +' </div></th>  '
			END IF		

		END IF	  
		AUD_TRA->(DBSKIP())		

	END DO

	C_HTML += '</tr> '
	C_HTML += '</table> '
	C_HTML += '</body> '
	C_HTML += '</html> '

	CLI_EMAIL()   

	AUD_TRA->(DBCLOSEAREA())    
	_REGIS->(DBCLOSEAREA())    

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

	cRecebe   := "jecimar.ferreira@biancogres.com.br"
	cAssunto	:= "Altera็ใo da Estrutura"							// Assunto do Email

	U_BIAEnvMail(,cRecebe,cAssunto,C_HTML)			

RETURN
