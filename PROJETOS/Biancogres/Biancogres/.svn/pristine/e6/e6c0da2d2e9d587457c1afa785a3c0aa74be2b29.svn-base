#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณWORK_INVESบAutor  ณ MADALENO           บ Data ณ  26/01/09   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR OS INVESTIMENTOS QUE NรO FORAM APROVADOSบฑฑฒ
ฒฑฑบ          ณ                                                            บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8 - R4                                                   บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION WORK_INVES(AA_EMPRESA)
	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private C_HTML  	:= ""
	Private lOK        	:= .F.
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
	PRIVATE AARRAY := {}
	PRIVATE _GEREN := ""
	//CSQL := "SELECT ZO_YCOD, ZO_DATA, ZO_CLIENTE, A1_NOME, ZO_REPRE, A3_NREDUZ, ZO_TPDES, ZO_VALOR, ISNULL(ZZI_GERENT,'000000') AS ZZI_GERENT " + ENTER
	//CSQL += "FROM "+RETSQLNAME("SZO")+" SZO, "+RETSQLNAME("SA1")+" SA1, "+RETSQLNAME("SA3")+" SA3, "+RETSQLNAME("ZZI")+" ZZI " + ENTER
	//CSQL += "WHERE	SZO.ZO_CLIENTE = SA1.A1_COD AND " + ENTER
	//CSQL += "		SZO.ZO_REPRE = SA3.A3_COD AND " + ENTER
	//CSQL += "		ZZI.ZZI_VEND =* SZO.ZO_REPRE AND " + ENTER
	//CSQL += "		SZO.ZO_STATUS = 'Aguard. Aprova็ใo' AND " + ENTER
	////CSQL += "		SZO.ZO_STATUS = 'Baixa Total' AND ZO_DATA >= '20090101' AND  " + ENTER
	//CSQL += "		SZO.D_E_L_E_T_ = '' AND " + ENTER
	//CSQL += "		SA1.D_E_L_E_T_ = '' AND " + ENTER
	//CSQL += "		SA3.D_E_L_E_T_ = '' AND " + ENTER
	//CSQL += "		ZZI.D_E_L_E_T_ = ''	 " + ENTER
	//CSQL += "		ORDER BY ZZI_GERENT, ZO_DATA " + ENTER


	//ATUALIZAวรO QUERY - SQL ATUAL - 19/01/2016
	CSQL := "SELECT ZO_YCOD, ZO_DATA, ZO_CLIENTE, A1_NOME, ZO_REPRE, A3_NREDUZ, ZO_TPDES, ZO_VALOR, ISNULL(ZZI_GERENT,'000000') AS ZZI_GERENT " + ENTER
	CSQL += "FROM " + RETSQLNAME("SZO") + " SZO " + ENTER
	CSQL += "	INNER JOIN " + RETSQLNAME("SA1") + " SA1 " + ENTER
	CSQL += "		ON SZO.ZO_CLIENTE = SA1.A1_COD " + ENTER
	CSQL += "			AND SA1.D_E_L_E_T_ = '' " + ENTER
	CSQL += "	INNER JOIN " + RETSQLNAME("SA3") + " SA3 " + ENTER
	CSQL += "		ON SZO.ZO_REPRE = SA3.A3_COD " + ENTER
	CSQL += "			AND SA3.D_E_L_E_T_ = '' " + ENTER
	CSQL += "	LEFT JOIN " + RETSQLNAME("ZZI") + " ZZI " + ENTER
	CSQL += "		ON SZO.ZO_REPRE = ZZI.ZZI_VEND " + ENTER
	CSQL += "			AND ZZI.D_E_L_E_T_ = '' " + ENTER
	CSQL += "WHERE	SZO.ZO_STATUS = 'Aguard. Aprova็ใo' AND  " + ENTER
	//CSQL += "		SZO.ZO_STATUS = 'Baixa Total' AND ZO_DATA >= '20090101' AND " + ENTER
	CSQL += "		SZO.D_E_L_E_T_ = '' " + ENTER
	CSQL += "		ORDER BY ZZI_GERENT, ZO_DATA " + ENTER


	IF CHKFILE("_INVEST")
		DBSELECTAREA("_INVEST")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_INVEST" NEW

	C_HTML  := ""
	IF ! _INVEST->(EOF())

		_GEREN := _INVEST->ZZI_GERENT
		DO WHILE ! _INVEST->(EOF())

			IF _GEREN = _INVEST->ZZI_GERENT
				aAdd(AARRAY,{ ZO_YCOD, DTOC(STOD(ZO_DATA)), A1_NOME, A3_NREDUZ, ZO_TPDES, ZO_VALOR, ZZI_GERENT  })
			ELSE
				MONTA_HTML()
				AARRAY := {}
				_GEREN := _INVEST->ZZI_GERENT
			END IF
			_INVEST->(DBSKIP())	
		END DO
		MONTA_HTML()
		AARRAY := {}
	ENDIF

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ MONTA_HTML          บAutor  ณ MADALENO           บ Data ณ  22/01/10   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       ROTINA PARA MONTAR O HTML                                  บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION MONTA_HTML()

	Local I

	C_HTML := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
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
	C_HTML += ' <table width="919" border="1"> '
	C_HTML += '   <tr> '
	C_HTML += '     <th width="722" rowspan="3" scope="col"> LISTAGEM DOS INVESTIMENTOS N&Atilde;O APROVADO </th> '
	C_HTML += '     <td width="181" class="style12"><div align="right"> DATA EMISSรO:  '+ dtoC(DDATABASE) +' </div></td> '
	C_HTML += '   </tr> '
	C_HTML += '   <tr> '
	C_HTML += '     <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+SUBS(TIME(),1,8)+' </div></td> '
	C_HTML += '   </tr> '
	C_HTML += '   <tr> '
	IF CEMPANT = "05"
		C_HTML += '    <td><div align="center" class="style41"> INCESA REVESTIMENTO CERยMICO LTDA </div></td> '
	ELSE
		C_HTML += '    <td><div align="center" class="style41"> BIANCOGRES CERยMICA SA </div></td> '
	END IF 
	C_HTML += '   </tr> '
	C_HTML += ' </table> '

	C_HTML += '<table width="920" border="1"> '
	C_HTML += '  '
	C_HTML += '  <tr bgcolor="#0066CC"> '
	C_HTML += '	<th width="53"	scope="col"><span class="style21"> C&Oacute;DIGO</span></th> '
	C_HTML += '		<th width="70"	scope="col"><span class="style21"> DATA INVEST.  </span></th> '
	C_HTML += '		<th width="333"	scope="col"><span class="style21"> CLIENTE </span></th> '
	C_HTML += '		<th width="172" 	scope="col"><span class="style21"> REPRESENTANTE </span></th> '
	C_HTML += '		<th width="169" 	scope="col"><span class="style21"> TIPO DESPESA </span></th> '
	C_HTML += '		<th width="83" 	scope="col"><span class="style21"> VALOR </span></th> '
	C_HTML += '	</tr>


	//DO WHILE ! _INVEST->(EOF())
	FOR I:= 1 TO LEN(AARRAY)
		// IMPRIMINDO OS PEDIDOS		
		C_HTML += '<tr bgcolor="#FFFFFF"> '
		C_HTML += '		<th scope="col"><div align="left" class="style12"> '+ AARRAY[I,1] +' </div></th> '
		C_HTML += '		<th scope="col"><div align="left" class="style12"> '+ AARRAY[I,2] +' </div></th> '
		C_HTML += '		<th scope="col"><div align="left" class="style12"> '+ AARRAY[I,3] +' </div></th>  '
		C_HTML += '		<th scope="col"><div align="left" class="style12"> '+ AARRAY[I,4] +' </div></th>  '
		C_HTML += '		<th scope="col"><div align="left" class="style12"> '+ AARRAY[I,5] +' </div></th>  '
		C_HTML += '		<th scope="col"><div align="left" class="style12"> '+ TRANSFORM(AARRAY[I,6]	,"@E 999,999,999.99") +' </div></th>  '
		C_HTML += '	</tr> '

	NEXT

	// RODAPE DO EMAIL
	C_HTML += '</table> '
	C_HTML += '</body> '
	C_HTML += '</html> '

	COMIS_EMAIL()		

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
		IF _GEREN = "000000"
			cRecebe 	:= "claudeir.fadini@biancogres.com.br"
			cAssunto	:= "Listagem de investimentos nใo aprovados - :: Representante sem gerente vinculado ::"
		ELSE
			cRecebe 	:= ALLTRIM(Posicione("SA3",1,xFilial("SA3")+_GEREN,"A3_EMAIL")) // BUSCANDO O EMAIL DO SUPERVISOR.
			cAssunto	:= "Listagem de investimentos nใo aprovados"
		END IF
	ELSE
		IF _GEREN = "000000"
			cRecebe 		:= "luismar.lucchini@biancogres.com.br"
			cAssunto	:= "Listagem de investimentos nใo aprovados - :: Representante sem gerente vinculado ::"
		ELSE
			cRecebe 	:= "luismar.lucchini@biancogres.com.br"
			cAssunto	:= "Listagem de investimentos nใo aprovados"
		END IF
	END IF    

	U_BIAEnvMail(,cRecebe,cAssunto,C_HTML,,,.F.)

RETURN