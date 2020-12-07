#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณWORK_PC_ENบAutor  ณ FERNANDO ROCHA     บ Data ณ  25/01/01   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA GERAR OS RELATORIOS DE COMISSAO DE TODOS       บฑฑฒ
ฒฑฑบ          ณ OS VENDEDORES E ENVIA POR EMAIL                            บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP7                                                        บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION WORK_PCE()

	Local nI 

	Private C_HTML  	:= ""
	Private lOK        := .F.

	Private xViaSched 	:= (Select("SX6")== 0)
	Private xv_Emps 	:= {} 

	xv_Emps := U_BAGtEmpr("01_05_12_13")

	For nI := 1 to Len(xv_Emps)
		If xViaSched
			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		EndIf

		GERA_WF()

		If xViaSched	
			//Finaliza o ambiente criado
			RpcClearEnv()    
		EndIf       

	Next nI

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ WORK_PC_ENV         บAutor  ณ FERNANDO ROCHA     บ Data ณ  25/01/11   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc. FUNCAO PARA CRIAR O ARQUIVO HTML E DEPOIS GERAR O EMAIL          บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GERA_WF()
	Local cAliasTmp
	Local _aAux
	Local _APEDIDOS := {}


	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp


		SELECT
		C7_NUM
		,A2_NOME
		,C7_EMISSAO                     
		,C7_YOBSCOM
		,C7_APROV
		//Retirado conforme OS 1418-15
		//,ISNULL((SELECT AK_NOME FROM %Table:SAK% SAK WHERE AK_COD = SCR.CR_LIBAPRO AND SAK.D_E_L_E_T_ <> '*'),' ') AS AK_NOME			
		,ISNULL((SELECT Y1_NOME FROM %Table:SY1% SY1 WHERE Y1_USER = SC7.C7_USER AND SY1.D_E_L_E_T_ <> '*'),' ') AS Y1_NOME           
		,SUM(C7_TOTAL) C7_TOTAL

		FROM %Table:SC7% SC7
		JOIN %Table:SA2% SA2 ON SA2.A2_COD = SC7.C7_FORNECE AND SA2.A2_LOJA = SC7.C7_LOJA AND SA2.%NotDel%
		//Retirado conforme OS 1418-15
		//JOIN %Table:SCR% SCR ON SC7.C7_NUM = SCR.CR_NUM	AND SCR.%NotDel%	
		WHERE
		SC7.%NotDel%
		AND SC7.C7_YEMAIL <> 'S'
		AND (SC7.C7_QUANT - SC7.C7_QUJE) > 0
		AND SC7.C7_RESIDUO NOT IN ('S','R')                              
		AND C7_CONAPRO <> 'B'	       
		//Inserido conforme OS 1418-15
		AND C7_PRODUTO < 'A'
		//Retirado conforme OS 1418-15
		//GROUP BY C7_NUM, A2_NOME, C7_YOBSCOM, C7_EMISSAO, C7_APROV, CR_LIBAPRO, C7_USER
		GROUP BY C7_NUM, A2_NOME, C7_YOBSCOM, C7_EMISSAO, C7_APROV, C7_USER	
		ORDER BY SC7.C7_EMISSAO

	EndSql


	(cAliasTmp)->(DbGoTop())
	WHILE !(cAliasTmp)->(EOF())

		_aAux := {}
		AADD(_aAux,(cAliasTmp)->C7_NUM)
		AADD(_aAux,(cAliasTmp)->A2_NOME)
		AADD(_aAux,DTOC(STOD((cAliasTmp)->C7_EMISSAO)))
		AADD(_aAux,Transform((cAliasTmp)->C7_TOTAL,"@E 999,999,999.99"))
		AADD(_aAux,(cAliasTmp)->Y1_NOME)
		//Retirado conforme OS 1418-15
		//AADD(_aAux,(cAliasTmp)->AK_NOME)
		AADD(_aAux,(cAliasTmp)->C7_YOBSCOM)	

		AADD(_APEDIDOS,_aAux)

		(cAliasTmp)->(DBSKIP())
	END DO

	(cAliasTmp)->(DbSkip())
	(cAliasTmp)->(DbCloseArea())

	IF Len(_APEDIDOS) > 0
		C_HTML := MONTAHTML(DTOC(dDataBase),SUBSTR(Time(),1,5),_APEDIDOS)
		PREP_EMAIL(C_HTML)
	ENDIF

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ PREP_EMAIL          บAutor  ณFERNANDO ROCHA      บ Data ณ  25/01/11   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       ROTINA PARA GERAR O EMAIL E ENVIAR O MESMO                 บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION PREP_EMAIL(C_HTML)

	Local lOk
											  // Email do Emissor
	cRecebe     := "vagner.salles@biancogres.com.br;glauco.santos@biancogres.com.br"   // Email Destinatario
	cRecebeCC	:= "" 																		  // Com Copia
	//cRecebeCO	:= "luana.ribeiro@biancogres.com.br"
	cRecebeCO	:= ""
	_NOMEEMP    := ""

	DO CASE
		CASE CEMPANT = "01"
		_NOMEEMP := 'BIANCOGRES CERAMICA SA'
		cRecebe     += ";rosilene.murrer@biancogres.com.br;geovani.gomes@biancogres.com.br;rosicarla.ferreira@biancogres.com.br;avelino.lopes@biancogres.com.br"   
		CASE CEMPANT = "05"	
		_NOMEEMP := 'INCESA REVESTIMENTO CERยMICO LTDA'
		cRecebe     += ";leticia.vicente@biancogres.com.br;leonardo.mengal@biancogres.com.br"
		CASE CEMPANT = "12"	                            
		_NOMEEMP := 'ST GESTAO DE NEGOCIOS LTDA'   
		CASE CEMPANT = "13"	                            
		_NOMEEMP := 'MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA'   
		CASE CEMPANT = "14"	                            
		_NOMEEMP := 'VITCER RETIFICA E COMPLEMENTOS CERAMICOS'   
	ENDCASE

	cAssunto := ""+_NOMEEMP+" PEDIDOS DE COMPRA NรO ENVIADOS PARA FORNECEDOR"    

	lOk := U_BIAEnvMail(,cRecebe,cAssunto,C_HTML,'','',,'',cRecebeCC,cRecebeCO)

	IF !lOK
		CONOUT("ERRO AO ENVIAR EMAIL - WORK_PCE")
	ENDIF

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบMONTAHTML            บAutor  ณ FERNANDO ROCHA     บ Data ณ  05/08/2010 บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       ROTINA PARA GERAR O HTML DO WORKFLOW                       บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MONTAHTML(_CDATAEMIS,_CHORAEMIS,_APEDIDOS)
	Local C_MENS 		:= ""
	Local _CEMPRESA  	:= ""
	Local I

	DO CASE
		CASE CEMPANT = "01"
		_CEMPRESA += 'BIANCOGRES CERAMICA SA'   
		CASE CEMPANT = "05"	
		_CEMPRESA += 'INCESA REVESTIMENTO CERยMICO LTDA'
		CASE CEMPANT = "12"	                            
		_CEMPRESA += 'ST GESTAO DE NEGOCIOS LTDA'     
		CASE CEMPANT = "13"	                            
		_CEMPRESA += 'MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA'  
		CASE CEMPANT = "14"	                            
		_CEMPRESA += 'VITCER RETIFICA E COMPLEMENTOS CERAMICOS'   	
	ENDCASE

	C_MENS 		+= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_MENS 		+= '<html xmlns="http://www.w3.org/1999/xhtml"> '
	C_MENS 		+= '<head> '
	C_MENS 		+= '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_MENS 		+= '<title>Untitled Document</title> '
	C_MENS 		+= '<style type="text/css"> '
	C_MENS 		+= '<!-- '
	C_MENS 		+= '.style12 {font-size: 9px; } '
	C_MENS 		+= '.style41 {font-size: 12px; font-weight: bold; } '
	C_MENS 		+= '.styleT {color: #FFFFFF; font-size: 14px; font-weight: bold; } '
	C_MENS 		+= '.styleL {font-size: 14px; } '
	C_MENS 		+= '--> '
	C_MENS 		+= '</style> '
	C_MENS 		+= '</head> '
	C_MENS 		+= '<body> '
	C_MENS 		+= '<table width="100%" border="1"> '
	C_MENS 		+= '  <tr> '
	C_MENS 		+= '    <th width="751" rowspan="3" scope="col"> PEDIDOS DE COMPRAS NรO ENVIADOS PARA FORNECEDOR </th> '
	C_MENS 		+= '    <td width="189" class="style12"><div align="right"> DATA EMISSรO: '+_CDATAEMIS+' </div></td> '
	C_MENS 		+= '  </tr> '
	C_MENS 		+= '  <tr> '
	C_MENS 		+= '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+_CHORAEMIS+' </div></td> '
	C_MENS 		+= '  </tr> '
	C_MENS 		+= '  <tr> '
	C_MENS 		+= '    <td><div align="center" class="style41">'+_CEMPRESA+'</div></td> '
	C_MENS 		+= '  </tr> '
	C_MENS 		+= '</table> '


	C_MENS 		+= '<table width="100%" border="1"> '
	C_MENS 		+= '	  <tr bgcolor="#FFFFFF"> '
	C_MENS 		+= '	    <td><div align="left"><font size="-1" style="font-weight:bold">CLIENTE:</font></div></td> '
	C_MENS 		+= '	    <th colspan="5" scope="col"> '
	C_MENS 		+= '	    		<div align="left"><font size="-1" style="font-style:normal">CODIGO - NOME</font></div> '
	C_MENS 		+= '	    </th> '
	C_MENS 		+= '	  </tr>  '
	C_MENS 		+= '	  <tr bgcolor="#0066CC"> '
	C_MENS 		+= '	    <th width="113"	scope="col" class="styleT">NUMERO PC</th> '
	C_MENS 		+= '	    <th	width="400" scope="col" class="styleT">NOME DO FORNECEDOR</th> '
	C_MENS 		+= '	    <th	scope="col" class="styleT">DATA DE EMISSรO</th> '
	C_MENS 		+= '	    <th scope="col" class="styleT">VALOR</th> '
	C_MENS 		+= '	    <th width="300" scope="col" class="styleT">COMPRADOR</th> '
	//Retirado conforme OS 1418-15
	//C_MENS 		+= '	    <th width="300" scope="col" class="styleT">APROVADOR</th> '
	C_MENS 		+= '	    <th width="300" scope="col" class="styleT">OBSERVAวรO COMPRAS</th> '
	C_MENS 		+= '	  </tr> '

	FOR I := 1 To Len(_APEDIDOS)
		C_MENS 		+= '	  <tr> '
		C_MENS 		+= '	    <td class="styleL"> '+_APEDIDOS[I][1]+' </td> '
		C_MENS 		+= '	    <td class="styleL"> '+_APEDIDOS[I][2]+' </td> '
		C_MENS 		+= '	    <td class="styleL"> '+_APEDIDOS[I][3]+' </td> '
		C_MENS 		+= '	    <td class="styleL" align="right"> '+_APEDIDOS[I][4]+' </td> '
		C_MENS 		+= '	    <td class="styleL"> '+_APEDIDOS[I][5]+' </td> '
		//Retirado conforme OS 1418-15	
		//C_MENS 		+= '	    <td class="styleL"> '+_APEDIDOS[I][6]+' </td> '
		C_MENS 		+= '	    <td class="styleL"> '+_APEDIDOS[I][6]+' </td> '	
		C_MENS 		+= '	  </tr> '
	NEXT I

	C_MENS 		+= '	  <tr bordercolor="#FFFFFF"> '
	C_MENS 		+= '	    <td colspan="6">&nbsp;</td> '
	C_MENS 		+= '	  </tr> '
	C_MENS 		+= '	</table> '


	C_MENS 		+= '<p class="style35">Esta ้ uma mensagem automแtica, favor nใo responde-la. </p> '
	C_MENS 		+= '</body> '
	C_MENS 		+= '</html> '

Return(C_MENS)
