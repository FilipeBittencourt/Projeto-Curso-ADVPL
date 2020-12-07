#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณ ATRA_FORNบAutor  ณ MADALENO           บ Data ณ  26/01/09   บฑฑฒ
ฒฑฑบ 		  		ณ	         บAlter. ณ Ranisses A. Corona บ Data ณ  29/07/09   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR OS PEDIDOS DE COMPRAS EM ABERTO PARA    บฑฑฒ
ฒฑฑบ          ณ OS FORNECEDORES                                            บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8 - R4                                                   บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION ATRA_FORN()
PRIVATE ENTER := CHR(13)+CHR(10)
Private cEmail := ""
Private C_HTML := ""
Private lOK := .F.
PRIVATE CREMETENTE := ""
PRIVATE N_FOLOWUP
PRIVATE D_DATAA
PRIVATE cCodigo :=  ""
PRIVATE cNome	:= ""
Private lDebug := .F.
Private cNumPed := SC7->C7_NUM

	pswseek(__cUserID,.t.)   
	wUsuario := pswret(1)[1][1]
	CREMETENTE := UsrRetMail(RetCodUsr())

	If CMODULO == "COM" .And. U_VALOPER("010", .F.) .And. SC7->C7_YEMAIL == "S"
		Processa({|| GER_ARQUIV()})
	Else 	
		MsgInfo("Voc๊ nใo possui permissใo para executar essa funcionalidade.","OP 010 - Informa็ใo (ATRA_FORN)") 
	EndIf

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

PRIVATE CEMAIL 	:= ""


CSQL := "SELECT C7_YQUAEMA, A2_NOME, A2_EMAIL, (SC7.C7_QUANT - SC7.C7_QUJE) AS SALDO, SC7.* "
CSQL += "FROM "+RETSQLNAME("SC7")+" SC7 WITH (NOLOCK) , SA2010 SA2 WITH (NOLOCK)"
CSQL += "WHERE	SC7.C7_NUM 		= '"+cNumPed+"'	AND	"    
CSQL += "		SC7.C7_RESIDUO	= '' 				AND	" //ALTERADO POR RANISSES
CSQL += "		SA2.A2_COD 		= SC7.C7_FORNECE 	AND "
CSQL += "		SA2.A2_LOJA		= SC7.C7_LOJA 		AND "
CSQL += "		SC7.C7_QUANT - SC7.C7_QUJE > 0 		AND "
CSQL += "		SC7.D_E_L_E_T_ 	= '' 				AND "
CSQL += "		SA2.D_E_L_E_T_ 	= ''  					"
IF CHKFILE("_PEDIDO")
	DBSELECTAREA("_PEDIDO")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_PEDIDO" NEW


C_HTML  := ""
IF ! _PEDIDO->(EOF())
        
		CEMAIL := _PEDIDO->A2_EMAIL
		IF ALLTRIM(CEMAIL) = ""
			MSGBOX("EMAIL NรO CADASTRADO")
			RETURN
		END IF
        
		N_FOLOWUP 	:= ALLTRIM(STR(_PEDIDO->C7_YQUAEMA + 1))
		D_DATAA		:= DTOS(DDATABASE)

		cCodigo		:= _PEDIDO->C7_FORNECE
		cNome		:= _PEDIDO->A2_NOME
		
		//VERIFICA SE E PARA IMPRIMIR O CABECALHO
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
//		IF CEMPANT = "05"
//			C_HTML += '<p>INCESA REVESTIMENTO CERยMICO LTDA </p> '
//		ELSE
//			C_HTML += '<p>BIANCOGRES CERAMICA SA </p> '
//		END IF
		C_HTML += '<p> '+ Alltrim(SM0->M0_NOMECOM) +' </p> '	
		C_HTML += '<table width="956" border="1"> '
		C_HTML += '  <tr> '
		C_HTML += '    <th scope="col"><div align="left">PREZADO FORNECEDOR: ' + _PEDIDO->A2_NOME +'</div></th> '
		C_HTML += '  </tr> '

		C_HTML += '  <tr> '
		C_HTML += '    <th scope="col"><div align="left">COMPRADOR: '+ Alltrim(CREMETENTE) +' <BR>E-MAIL: '+CREMETENTE+'</div></th> '
		C_HTML += '  </tr> '
		
		C_HTML += '   '
		C_HTML += '  <tr> '
		IF CEMPANT = "05"
			C_HTML += '    <td class="style12">SEGUE ABAIXO A RELA&Ccedil;&Atilde;O DE PEDIDOS DE COMPRAS N&Atilde;O ENTREGUES AT&Eacute; O PRESENTE MOMENTO PARA A EMPRESA INCESA REVESTIMENTO CERยMICO LTDA </td> '
		ELSE
			C_HTML += '    <td class="style12">SEGUE ABAIXO A RELA&Ccedil;&Atilde;O DE PEDIDOS DE COMPRAS N&Atilde;O ENTREGUES AT&Eacute; O PRESENTE MOMENTO PARA A EMPRESA BIANCOGRES CERยMICA SA </td> '
		END IF		
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		C_HTML += '    <td>&nbsp;</td> '
		C_HTML += '  </tr> '
		C_HTML += '</table> '
		C_HTML += '<table width="957" border="1"> '
		C_HTML += '   '
		C_HTML += '  <tr bgcolor="#0066CC"> '
		C_HTML += '    <th width="40" height="40" scope="col"><span class="style21"> PEDIDO </span></th> '
		C_HTML += '    <th width="28" scope="col"><span class="style21"> ITEM </span></th> '
		C_HTML += '    <th width="232" scope="col"><span class="style21"> PRODUTO </span></th> '
		C_HTML += '    <th width="60" scope="col"><span class="style21"> QUANTIDADE (SALDO) </span></th> '
		C_HTML += '    <th width="42" scope="col"><span class="style21"> VALOR UNITมRIO </span></th> '
		C_HTML += '    <th width="62" scope="col"><span class="style21"> TOTAL </span></th> '
		C_HTML += '    <th width="47" scope="col"><span class="style21"> DATA DA ENTREGA </span></th> '
		C_HTML += '    <th width="48" scope="col"><span class="style21"> DATA DA EMISSรO </span></th> '
		C_HTML += '  </tr> '

		DO WHILE ! _PEDIDO->(EOF())
		// IMPRIMINDO OS PEDIDOS		
				C_HTML += '  <tr>
				C_HTML += '    <td class="style12">'+ _PEDIDO->C7_NUM +'</td> '
				C_HTML += '    <td class="style12">'+ _PEDIDO->C7_ITEM +'</td> '
				C_HTML += '    <td class="style12">'+ ALLTRIM(_PEDIDO->C7_DESCRI) +'</td> '
				C_HTML += '    <td class="style12">'+ TRANSFORM(_PEDIDO->SALDO	,"@E 999,999,999.99") +'</td> '
				C_HTML += '    <td class="style12">'+ TRANSFORM(_PEDIDO->C7_PRECO	,"@E 99,999,999.999") +'</td> '
				C_HTML += '    <td class="style12">'+ TRANSFORM(_PEDIDO->SALDO * _PEDIDO->C7_PRECO	,"@E 99,999,999.999") +'</td> '
				C_HTML += '    <td class="style12">'+ DTOC(STOD(_PEDIDO->C7_DATPRF)) +'</td> '
				C_HTML += '    <td class="style12">'+ DTOC(STOD(_PEDIDO->C7_EMISSAO)) +'</td> '
				C_HTML += '  </tr>			
			_PEDIDO->(DBSKIP())		
		END DO 

		// RODAPE DO EMAIL
		C_HTML += ' <tr> '
		C_HTML += '    <td colspan="10" class="style12">&nbsp;</td> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		C_HTML += '    <td colspan="10" class="style12">SOLICITAMOS QUE, CASO A ENTREGA TENHA SIDO PROGRAMADA, NOS RESPONDA ESSE E-MAIL COM OS NฺMEROS DAS NOTAS FISCAIS, DATAS E A TRANSPORTADORA CORRESPONDENTE PARA ACOMPANHAMENTO INTERNO. </td> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		C_HTML += '    <td colspan="10" class="style12"> CASO NรO TENHA SIDO PROGRAMADA, SOLICITAMOS INFORMAR A DATA PREVISTA PARA ENTREGA. FAVOR RESPONDER A TODOS. </td> '
		C_HTML += '  <tr> '
		C_HTML += '    <td colspan="10" class="style12"> CONFERIR SE OS DADOS CADASTRAIS QUE CONSTAM NO PEDIDO ESTรO DE ACORDO COM EMISSรO DA NF. </td> '
		C_HTML += '  </tr> '

		// Implementado por Marcos Alberto Soprani em 29/03/12 atendendo a implemeta็ใo do projeto de importa็ใo de arquivo XML
		C_HTML += '  <tr> '
		C_HTML += '    <td colspan="10" class="style12"> OBS.: Empresa autorizada a emissใo de Nota Fiscal Eletr๔nica deverแ enviar o arquivo XML </td> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		If cEmpAnt == "01"
			C_HTML += '    <td colspan="10" class="style12">             para o endere็o eletr๔nico: nf-e.biancogres@biancogres.com.br "
		ElseIf cEmpAnt == "05"
			C_HTML += '    <td colspan="10" class="style12">             para o endere็o eletr๔nico: nf-e.incesa@incesa.ind.br "
		ElseIf cEmpAnt == "07"
			C_HTML += '    <td colspan="10" class="style12">             para o endere็o eletr๔nico: nf-e.lmcomercio@biancogres.com.br "
		ElseIf cEmpAnt == "12"
			C_HTML += '    <td colspan="10" class="style12">             para o endere็o eletr๔nico: nf-e.stgestao@biancogres.com.br "
		ElseIf cEmpAnt == "13"
			C_HTML += '    <td colspan="10" class="style12">             para o endere็o eletr๔nico: nf-e.mundi@biancogres.com.br "
		Else
			C_HTML += '    <td colspan="10" class="style12">             para o endere็o eletr๔nico: nf-e.biancogres@biancogres.com.br "
		EndIf
		C_HTML += '  </tr> '

		C_HTML += '</table> '
		C_HTML += '<p>&nbsp;	</p> '
		C_HTML += '</body> '
		C_HTML += '</html> '

END IF

IF C_HTML <> ""
	Processa({||COMIS_EMAIL()},"Enviando email..." )
ELSE
	MSGBOX("TODOS OS ITENS Jม FORAM ENTREGUES!")
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

cERRO 		:= ""
cRecebe     := ALLTRIM(CEMAIL) 	// ;"+cEmail	// Email do(s) receptor(es) 
cRecebeCC	:= "vagner.salles@biancogres.com.br" 	// Com Copia
cRecebeCO	:= ""													// Copia Oculta
cAssunto	:= "PEDIDO " + cNumPed + " EM ATRASO" 									// Assunto do Email 

If lDebug
	cRecebe 	:= 'carlos.junqueira@biancogres.com.br'
	cRecebeCC 	:= cRecebe
EndIf

lOk := U_BIAEnvMail(,cRecebe,cAssunto,C_HTML,"","",,cRecebeCC)     

IF (lOK)
	MsgInfo("Email enviado com sucesso!", "Envio FollowUp") 
		
	// ATUALIZANDO A QUANTIDADE DE FOLOW UP QUE FORAM ENVIADOS E A DATA
	TCSQLExec(" UPDATE "+RETSQLNAME("SC7")+" SET C7_YQUAEMA = '"+N_FOLOWUP+"', C7_YDATEMA = '"+D_DATAA+"' WHERE C7_NUM = '"+cNumPed+"' " )
Else
	MSGBOX("ERRO AO ENVIAR EMAIL PARA O FORNECEDOR " + cCodigo + " " + cNome +".")

EndIf

RETURN
