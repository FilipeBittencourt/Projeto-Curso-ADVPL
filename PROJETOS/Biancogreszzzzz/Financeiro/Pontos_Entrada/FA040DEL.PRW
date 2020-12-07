#include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA040DEL ³ Autor ³ Fernando Rocha        ³ Data ³ 29.10.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apos excluir titulo a receber                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FA040DEL()
Local aArea := GetArea()

IF Type("M->E1_NUM") <> "U"

	IF (!Empty(M->E1_YFLGISE) .AND. Empty(M->E1_YFLGESE))

		// ENVIANCO EMAIL PARA OS RESPONSAVEIS PELAS COMISOES
		C_TITULO 	:= "SERASA - Cancelamento de Fatura"
		C_DESTI		:= "nadine.araujo@biancogres.com.br;wellison.toras@biancogres.com.br"
		
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(XFilial("SA1")+M->E1_CLIENTE+M->E1_LOJA))
		                       
		_CFAT 		:= ALLTRIM(M->E1_TIPO)+" "+ALLTRIM(M->E1_NUM)+"-"+ALLTRIM(M->E1_PARCELA)+" "+ALLTRIM(M->E1_PREFIXO)
		_CCLI		:= M->E1_CLIENTE+"/"+M->E1_CLIENTE+" - "+SA1->A1_NOME
		C_MENS 		:= TRSERWF(_CFAT,_CCLI)  
		
		U_BIAEnvMail(,C_DESTI,C_TITULO,C_MENS)       
		
	ENDIF
ENDIF

RestArea(aArea)
Return(.T.)       

Static function TRSERWF(_CFAT,_CCLI)     
Local _CMENS := "" 
Local _CEMPRESA := ""
Local _CEMIS := DTOC(Date())    
Local _CHORA := SUBSTR(Time(),1,5)

IF CEMPANT = "05"
	_CEMPRESA += 'INCESA REVESTIMENTO CERÂMICO LTDA'
ELSE
	_CEMPRESA += 'BIANCOGRES CERAMICA SA'
END IF

_CMENS += ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
_CMENS += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
_CMENS += ' <head> '
_CMENS += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
_CMENS += ' <title>Untitled Document</title> '
_CMENS += ' <style type="text/css"> '
_CMENS += ' <!-- '
_CMENS += ' .style12 { '
_CMENS += ' 	font-family: Verdana, Geneva, sans-serif; '
_CMENS += ' 	font-size: 12px; '
_CMENS += ' 	font-style: normal; '
_CMENS += ' 	color: #036; '
_CMENS += ' 	text-align: center; '
_CMENS += ' } '
_CMENS += '  '
_CMENS += ' .stylep {font-size: 9px; } '
_CMENS += '  '
_CMENS += ' .styleg { '
_CMENS += ' 	font-size: 12px;  '
_CMENS += ' 	font-weight:bold; '
_CMENS += ' } '
_CMENS += '  '
_CMENS += ' --> '
_CMENS += ' </style> '
_CMENS += ' </head> '
_CMENS += '  '
_CMENS += ' <body> '
_CMENS += ' <table width="101%" border="1"> '
_CMENS += '   <tr> '
_CMENS += '     <td width="209" class="styleg"><div align="center"> '+_CEMPRESA+' </div></td> '
_CMENS += '     <td width="798" rowspan="3" class="style12"><p>A Fatura '+_CFAT+', do  cliente '+_CCLI+' &nbsp;foi cancelada.</p> '
_CMENS += '     <p> Favor  solicitar a baixa no sistema do SERASA.</p></td> '
_CMENS += '   </tr> '
_CMENS += '   <tr> '
_CMENS += '     <td class="stylep"><div align="right">HORA DA EMISS&Atilde;O: '+_CHORA+' </div></td> '
_CMENS += '   </tr> '
_CMENS += '   <tr> '
_CMENS += '     <td class="stylep"><div align="right"> DATA EMISSÃO: '+_CEMIS+' </div></td> '
_CMENS += '   </tr> '
_CMENS += ' </table> '
_CMENS += '  '
_CMENS += ' <p class="style35">Esta é uma mensagem automática, favor não responde-la.</p> '
_CMENS += ' </body> '
_CMENS += ' </html> '


Return _CMENS
