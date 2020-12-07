#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIABC009
@author Barbara Coelho
@since 29/04/2019
@version 1.0
@description Workflow - Alteração no parâmetro MV_YULMES
@type function
/*/

User Function BIABC009(VL_POS,VL_ANT)

	Local cGerMail := ""
	Local cEve := ""
	Private cHTML := ""
	Private oLst := ArrayList():New()

	cHTML := GeraHtml(VL_POS,VL_ANT)		
	
	IF cHTML <> ""
		fSendMail(cHTML)
	ENDIF

Return()

Static Function GeraHtml(VL_POS,VL_ANT)
	C_HTML  := ""
     		
    ///////////////////// 		
     		
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
	C_HTML += ' '
	C_HTML += '--> '
	C_HTML += '</style> '
	C_HTML += '</head> '
	C_HTML += ' '
	C_HTML += '<body> '
	C_HTML += '<table width="753" border="0"> '
	C_HTML += '  <tr> '
	
	do case
		CASE cEmpAnt = "01"
			C_HTML += 'Empresa: BIANCOGRES CERÂMICA SA</div></th> '
		CASE cEmpAnt = "05"
		    C_HTML += 'Empresa: INCESA REVESTIMENTO CERÂMICO LTDA</div></th> '
		CASE cEmpAnt = "13"
			C_HTML += 'Empresa: MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA</div></th> '
		CASE cEmpAnt = "14"
		    C_HTML += 'Empresa: VITCER RETIFICA E COMPLEMENTOS CERAMICOS</div></th> '
	endcase	
	
	C_HTML += '    <td width="150" class="style12"><div align="right"> DATA EMISSÃO: '+ dtoC(DDATABASE) +' </div></td> '
	C_HTML += '    <td width="150" class="style12"><div align="right">HORA DA EMISSÃO:'+SUBS(TIME(),1,8)+' </div></td> '	
	C_HTML += '  </tr> '
	C_HTML += '  <trwidth="753" border="0"> '
	C_HTML += '    <th > Alteração do parâmetro MV_YULMES </th> '	
	C_HTML += '  </tr> '
	C_HTML += '</table> '
	C_HTML += '<p>&nbsp;	</p> ' 
	
	C_HTML += '<table width="753"> '
	C_HTML += '  <tr> '
	C_HTML += '    <td width="753"> O valor do parâmetro MV_YULMES foi alterado de '+  dtoC(VL_ANT) + ' para '+  dtoC(VL_POS)+'</td> '
	C_HTML += '  </tr> '
	C_HTML += '</table> '
	
	C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder (by BIABC009).</b></u> '     
	C_HTML += '<p>&nbsp;	</p> '
	C_HTML += '</body> '
	C_HTML += '</html> '          
RETURN C_HTML

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fSendMail(cHTML)
	Local lOk

	Local cMail := AllTrim(U_EmailWF('BIABC009', cEmpAnt))

	lOK := 	U_BIAEnvMail(,cMail, "Alteração no parâmetro MV_YULMES", cHTML)	

	IF !lOK
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIABC009")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIABC009")
	ENDIF	
Return()
