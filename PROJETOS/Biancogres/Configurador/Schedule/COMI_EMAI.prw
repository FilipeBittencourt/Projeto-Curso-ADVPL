#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณ COMI_EMAIบAutor  ณ MADALENO           บ Data ณ  26/06/07   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA GERAR OS RELATORIOS DE COMISSAO DE TODOS       บฑฑฒ
ฒฑฑบ          ณ OS VENDEDORES E ENVIA POR EMAIL                            บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP7                                                        บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION COMI_EMAI()
PRIVATE ENTER		:= CHR(13)+CHR(10)
Private cEmail    	:= ""
Private C_HTML  	:= ""
Private lOK         := .F.

Pergunte("GERCOM", .F.)

@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Workflow Comissใo"
@ 8,10 TO 84,222

@ 16,12 SAY "Esta rotina tem por finalidade: "
@ 24,12 SAY "Enviar o relat๓rio de Comiss๕es Pagas para os Representantes."

@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("GERCOM", .T.) //ABRE PERGUNTAS

ACTIVATE DIALOG oDlg5 CENTERED

RETURN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณChama rotina que acerta o empenho       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function OkProc()
//Close(oDlg5)
//U_BIAMsgRun("Aguarde... Gerando E-mail...",,{|| GERA_COMISSAO()})

Processa( {|| GERA_COMISSAO() } )
Close(oDlg5)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ GERA_COMISSAO       บAutor  ณ MADALENO           บ Data ณ  26/06/07   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc. FUNCAO PARA CRIAR O ARQUIVO HTML E DEPOIS GERAR O EMAIL          บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GERA_COMISSAO()
PRIVATE CNOME 						:= ""
PRIVATE CEMAIL 						:= ""
PRIVATE CCODIGO 					:= ""
PRIVATE DATADE 						:= DTOS(MV_PAR01)
//PRIVATE DATAATE						:= DTOS(MV_PAR02)
PRIVATE C_IR						:= MV_PAR02
PRIVATE CTOTAL_TITULO 				:= 0
PRIVATE CTOTAL_BASE 				:= 0
PRIVATE CTOTAL_COMISSAO 			:= 0
PRIVATE CTOTAL_PERCENTUAL			:= 0

Private cArqHtml  	:= "\P10\workflow\Comissao.html"
Private cMensagem   := ""
Private aEmp		:= {}
Private cFiltro		:= ""
Private lFiltro 	:= .F.

Private C_HTML1 := ""
Private C_HTML2 := ""
Private C_HTML3 := ""

//Seleciona os Representantes
CSQL := "SELECT A3_NOME, A3_NREDUZ, A3_EMAIL, A3_YEMAIL, A3_COD, A3_YEMP	" + ENTER
CSQL += "FROM SA3010 									" + ENTER
CSQL += "WHERE 	A3_FILIAL 	= '"+xFilial("SA3")+"'	AND	" + ENTER
CSQL += "       A3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND	" + ENTER
//CSQL += "		A3_YENVWF	= 'S' 					AND " + ENTER
CSQL += "		A3_EMAIL 	<> '' 					AND " + ENTER
CSQL += "		D_E_L_E_T_	= ''  						" + ENTER
CSQL += "ORDER BY A3_COD 								" + ENTER
IF CHKFILE("_REPRE")
	DBSELECTAREA("_REPRE")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_REPRE" NEW
DbSelectArea("_REPRE")
_REPRE->(DbGotop())
nTotReg := Contar("_REPRE","!Eof()")
Procregua(nTotReg)
_REPRE->(DbGotop())
DO WHILE ! _REPRE->(EOF())
	
	IncProc("Gerando e-mail para Representante..."+ALLTRIM(_REPRE->A3_NREDUZ))

	CNOME 	:= alltrim(_REPRE->A3_NOME)
	If !Empty(_REPRE->A3_YEMAIL)             
		CEMAIL 	:= alltrim(_REPRE->A3_YEMAIL)
	Else
		CEMAIL 	:= alltrim(_REPRE->A3_EMAIL)    
	EndIf
	CCODIGO := _REPRE->A3_COD

	//Valida se o representante fez Rescisใo em todas as Marcas ou estแ bloqueado		
	aEmp 	:= {}
	cFiltro	:= ""
	lFiltro := .F.
	aEmp 	:= U_fValResc(_REPRE->A3_COD)

	If ASCAN(aEmp, {|x| x[2] == "1" }) == 0
		_REPRE->(DBSKIP())
		Loop
	EndIf
	
	//Ticket 12487- ajuste referente ao Ticket 9802 (Ajuste para aparecer vendas independente da marca vinculada)	
	/*For I := 1 TO LEN(aEmp)
		If cEmpAnt == "01" .And. aEmp[I][2] == "1" .And. aEmp[I][1] == "0101"
			lFiltro := .T.
		ElseIf cEmpAnt == "05" .And. aEmp[I][2] == "1" .And. aEmp[I][1] $ "0501/0599/1399"
			lFiltro := .T.    
		ElseIf cEmpAnt == "07" .And. aEmp[I][2] == "1" .And. aEmp[I][1] $ "0101/0501/0599/1399"
			lFiltro := .T. 
			If aEmp[I][1] == "0101" 
				cFiltro += "1/"
			ElseIf aEmp[I][1] == "0501"
				cFiltro += "2/"
			ElseIf aEmp[I][1] == "0599" 
				cFiltro += "3/"
			ElseIf aEmp[I][1] == "1399"
				cFiltro += "4/"
			EndIf 							
		ElseIf cEmpAnt == "14" .And. aEmp[I][2] == "1" .And. aEmp[I][1] $ "1401"			
			lFiltro := .T.		
		EndIf					
	Next 
 
	If !lFiltro 
		_REPRE->(DBSKIP())
		Loop
	EndIf
 	
	If !Empty(Alltrim(cFiltro))
		cFiltro := Substr( Alltrim(cFiltro) , 1 ,Len(Alltrim(cFiltro))-1) 
		cFiltro := FormatIn(cFiltro,"/")
	EndIf*/
				  
	//(Thiago - 07/04/15) -> Para permitir que a rotina ssja executada em mais de uma mแquina.
	cArqHtml  	:= "\P10\workflow\Comissao_"+AllTrim(CCODIGO)+"_"+cEmpAnt+".html"
	
	CTOTAL_TITULO 			:= 0
	CTOTAL_BASE 			:= 0
	CTOTAL_COMISSAO 		:= 0
	CTOTAL_PERCENTUAL		:= 0
	CTOTAL_QUANTPERCENTUAL	:= 0
	CPERC_COMIS 			:= 0
	
	CSQL := " SELECT A3_COD,A3_NOME, A3_EMAIL, A3_YEMAIL, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_CODCLI, E3_LOJA,  E1_VENCTO, E3_EMISSAO, E3_DATA, E3_PEDIDO, E1_VALOR, E3_BASE, E3_COMIS, E3_BAIEMI, E3_PORC, E3_TIPO " + ENTER
	CSQL += " FROM "+RETSQLNAME("SE3")+" SE3, SA3010 SA3, "+RETSQLNAME("SE1")+" SE1  " + ENTER
	CSQL += " WHERE SE1.E1_FILIAL	= '"+xFilial("SE1")+"' AND " + ENTER 
	CSQL += "	SE3.E3_FILIAL	= '"+xFilial("SE3")+"' AND " + ENTER
	CSQL += "	SE3.E3_VEND = SA3.A3_COD AND " + ENTER
	CSQL += "	SE1.E1_NUM = SE3.E3_NUM AND " + ENTER
	CSQL += "	SE1.E1_PREFIXO = SE3.E3_PREFIXO AND " + ENTER
	CSQL += "	SE1.E1_PARCELA = SE3.E3_PARCELA AND " + ENTER
	CSQL += "	SE1.E1_TIPO = SE3.E3_TIPO AND " + ENTER
	CSQL += "	SE1.E1_CLIENTE = SE3.E3_CODCLI AND " + ENTER
	CSQL += "	A3_COD = '"+CCODIGO+"' AND " + ENTER
	
	//Ticket 9802 - Ajuste para aparecer vendas independente da marca vinculada
	//If !Empty(Alltrim(cFiltro))
	//CSQL += "	SE1.E1_PREFIXO IN "+cFiltro+" AND " + ENTER
	//EndIf

	CSQL += "	SE3.E3_DATA	= '"+DATADE+"' AND " + ENTER	
	CSQL += " SE3.E3_TIPO <> 'RA' AND " + ENTER
	CSQL += "	SE3.D_E_L_E_T_ = '' AND	" + ENTER
	CSQL += "	SA3.D_E_L_E_T_ = '' AND	" + ENTER
	CSQL += "	SE1.D_E_L_E_T_ = '' " + ENTER
	
	CSQL += "UNION ALL " + ENTER
	
	CSQL += " SELECT A3_COD,A3_NOME, A3_EMAIL, A3_YEMAIL,E3_PREFIXO, E3_NUM, E3_PARCELA, E3_CODCLI, E3_LOJA, 	E3_VENCTO, E3_EMISSAO, E3_DATA, E3_PEDIDO, E3_BASE, E3_BASE, E3_COMIS, E3_BAIEMI, E3_PORC, E3_TIPO " + ENTER
	CSQL += " FROM "+RETSQLNAME("SE3")+" SE3, SA3010 SA3  " + ENTER
	CSQL += " WHERE SE3.E3_FILIAL	= '"+xFilial("SE3")+"' AND " + ENTER 
	CSQL += "	SE3.E3_VEND	= SA3.A3_COD AND " + ENTER
	CSQL += "	SA3.A3_COD = '"+CCODIGO+"' AND" + ENTER
	CSQL += "	SE3.E3_DATA	= '"+DATADE+"' AND " + ENTER	
	CSQL += " SE3.E3_TIPO <> 'RA' AND " + ENTER
	CSQL += "	SE3.E3_CODCLI = '999998' AND " + ENTER
	CSQL += "	SE3.D_E_L_E_T_ = '' AND	" + ENTER
	CSQL += "	SA3.D_E_L_E_T_ = '' " + ENTER
	CSQL += " ORDER BY A3_COD, E3_PREFIXO, E3_EMISSAO, E3_CODCLI	" + ENTER
	
	IF CHKFILE("_COMIS")
		DBSELECTAREA("_COMIS")
		DBCLOSEAREA()
	ENDIF
	
	TCQUERY CSQL ALIAS "_COMIS" NEW
	
	IF 	! _COMIS->(EOF())
	
		//Verifica se o arquivo existe
		If file(cArqHtml)
			FErase(cArqHtml)
		EndIf
		
		fHtml := fCreate(cArqHtml)
		cMensagem := ''
		
		C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
		C_HTML += '<head> '
		C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		C_HTML += '<title>Untitled Document</title> '
		C_HTML += '<style type="text/css"> '
		C_HTML += '<!-- '
		C_HTML += '.style12 {font-size: 9px; font-family: Arial, Helvetica, sans-serif;} '
		C_HTML += '.style18 {font-size: 10} '
		C_HTML += '.style21 {color: #FFFFFF; font-size: 9px; } '
		C_HTML += '.style26 {color: #FFFFFF; font-weight: bold; font-family: Geneva, Arial, Helvetica, sans-serif; } '
		C_HTML += '.style27 {font-size: 9px;color: #FFFFFF; font-weight: bold; font-family: Arial, Helvetica, sans-serif; } '
		C_HTML += '.style28 {font-size: 10px;font-family: Arial, Helvetica, sans-serif; font-weight: bold;} '
		C_HTML += '--> '
		C_HTML += '</style> '
		C_HTML += '</head> '
		C_HTML += ' '
		C_HTML += '<body> '                                    

		cMensagem += 'Prezado Representante, '	 +ENTER
		cMensagem += ' '+ENTER				
		//cMensagem += '*** Devido a uma falha em nosso sistema alguns representantes nใo receberam o relat๓rio em anexo, ou at้ mesmo receberam equivocadamente de outro representante. Solicitamos conferir as informa็๕es e em caso de diverg๊ncia, considerar as informa็๕es deste email. Em caso de d๚vidas, favor entrar em contato com Vagner/Elimonda.***'+ENTER + ENTER
		cMensagem += 'Favor emitir sua Nota Fiscal de Comissใo conforme valores do relat๓rio anexo e enviแ-la para o e-mail nf.comissao@biancogres.com.br '+ENTER
		cMensagem += 'At้ o dia '+dtoc(MV_PAR05)+' sem falta.'+ENTER		
		cMensagem += ' ' +ENTER		
		cMensagem += 'Aten็ใo! Caso o valor do Imposto de Renda calculado seja menor ou igual a R$ 10.00,  este imposto nใo poderแ ser destacado na NF a ser emitida.'+ENTER		
		cMensagem += ' '+ENTER		
		cMensagem += 'Favor colocar no corpo da nota fiscal: Banco, Ag๊ncia e Conta Corrente. '+ENTER		
		cMensagem += ' '+ENTER		
		cMensagem += 'Ficar atento para emitir a NF para a empresa correta, deverแ ser sempre a mesma constante no relat๓rio.'+ENTER		
		cMensagem += ' '+ENTER
		cMensagem += 'Importante lembrar que esta comissใo s๓ serแ paga se a nota fiscal do m๊s anterior estiver na fแbrica.'+ENTER + ENTER
		
		C_HTML += '<p>Segue o demostrativo de comissใo...</p> '
		C_HTML += '<table width="1010" border="1"> '
		C_HTML += '  <tr> '
		DO CASE
			CASE CEMPANT = "01"
				C_HTML += '		 <th width="236" rowspan="2" scope="col">BIANCOGRES CERAMICA SA</th> '
			CASE CEMPANT = "05"
				C_HTML += '		 <th width="236" rowspan="2" scope="col">INCESA REVESTIMENTO CERAMICO LTDA</th> '
			CASE CEMPANT = "07"
				C_HTML += '		 <th width="236" rowspan="2" scope="col">LM COMERCIO ATACADISTA DE MATERIAL DE CONSTRUCAO LTDA</th> '
			CASE CEMPANT = "14"
				C_HTML += '		 <th width="236" rowspan="2" scope="col">VITCER RETIFICA E COMPLEMENTOS CERAMICOS LTDA</th> '
			OTHERWISE
				C_HTML += '		 <th width="236" rowspan="2" scope="col">???????????????????</th> '
		ENDCASE
		C_HTML += '    <th width="520" rowspan="2" scope="col">RELATำRIO DE COMISSีES </th> '
		C_HTML += '    <td width="213" class="style12"><div align="right">DATA EMISSรO: '+dtoc(ddatabase)+'</div></td> '
		C_HTML += '		  </tr>
		C_HTML += '			  <tr>
		C_HTML += '  			  <td class="style12"><div align="right">HORA EMISSรO: '+TIME()+' </div></td> '
		C_HTML += ' 		 </tr>
		C_HTML += '		</table>
		C_HTML += '<table width="1010" border="1"> '
		C_HTML += '  <tr bgcolor="#FFFFFF"> '
		C_HTML += '    <th colspan="16" scope="col"><div align="left" class="style18">Vendedor: '+CCODIGO+' '+CNOME+' </div></th> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr bgcolor="#0066CC"> '
		C_HTML += '    <th height="40" colspan="2" scope="col"><span class="style21">PREF/NUM/PARC</span></th> '
		//		C_HTML += '    <th width="40" height="40" scope="col"><span class="style21"> NUM. TITULO </span></th> '
		//		C_HTML += '    <th width="28" scope="col"><span class="style21">PARC.</span></th> '
		C_HTML += '    <th width="28" scope="col"><span class="style21">TIPO</span></th> '
		C_HTML += '    <th width="42" scope="col"><span class="style21">COD. DO CLIENTE</span></th> '
		C_HTML += '    <th width="25" scope="col"><span class="style21">LOJA</span></th> '
		C_HTML += '    <th width="232" scope="col"><span class="style12"><span class="style21">NOME</span></span></th> '
		C_HTML += '    <th width="62" scope="col"><span class="style12"><span class="style21">DT. BASE COMISS&Atilde;O </span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">DATA VENCTO </span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">DATA BAIXA </span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">DATA PAGTO </span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">N&Uacute;MERO PEDIDO </span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">VALOR TITULO </span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">VALOR BASE </span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">%</span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">VALOR COMISS&Atilde;O </span></span></th> '
		C_HTML += '    <th scope="col"><span class="style12"><span class="style21">TIPO COMISS&Atilde;O </span></span></th> '
		C_HTML += '  </tr> '
		
		IF  ! _COMIS->(EOF())
			_C_TITULOS := ALLTRIM(_COMIS->E3_PREFIXO)+ALLTRIM(_COMIS->E3_NUM)+ALLTRIM(_COMIS->E3_PARCELA)+ALLTRIM(_COMIS->E3_CODCLI)+ALLTRIM(_COMIS->E3_LOJA)
			_JJ := 1
		END IF
		
		C_HTML1 += C_HTML
		FWrite(fHtml,C_HTML)
		C_HTML:=''
		
		DO WHILE ! _COMIS->(EOF())
			
			//ALTERACAO PARA BUSCAO OS DADOS DO CLIENTE ORIGINAL QUANDO LM - FERNANDO - 06/08/2010
			SC5->(DbSetOrder(1))
			IF SC5->(DbSeek(XFILIAL("SC5")+_COMIS->E3_PEDIDO)) .AND. (!Empty(SC5->C5_YCLIORI))
				SSCOD_CLI := SC5->C5_YCLIORI
				SSLOJ_CLI := SC5->C5_YLOJORI
				SSNOME_CLI := Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_YCLIORI+SC5->C5_YLOJORI,"A1_NOME")
			ELSE
				SSCOD_CLI := _COMIS->E3_CODCLI
				SSLOJ_CLI := _COMIS->E3_LOJA
				SSNOME_CLI := Posicione("SA1",1,XFILIAL("SA1")+_COMIS->E3_CODCLI+_COMIS->E3_LOJA,"A1_NOME")
			ENDIF
			
			C_HTML += '  <tr> '
			C_HTML += '    <td colspan="2" class="style12"><div align="center">'+ALLTRIM(_COMIS->E3_PREFIXO)+"-"+ALLTRIM(_COMIS->E3_NUM)+"-"+ALLTRIM(_COMIS->E3_PARCELA)+'</td> '
			//C_HTML += '    <td class="style12"><div align="center">'+ALLTRIM(_COMIS->E3_PREFIXO)+"-"+_COMIS->E3_NUM+'</td> '
			//C_HTML += '    <td class="style12"><div align="center">'+IIF(ALLTRIM(_COMIS->E3_PARCELA)="","&nbsp;",_COMIS->E3_PARCELA) +'</td> '
			C_HTML += '    <td class="style12"><div align="center">'+_COMIS->E3_TIPO+'</td> '
			C_HTML += '    <td class="style12"><div align="center">'+SSCOD_CLI+'</td> '
			C_HTML += '    <td class="style12"><div align="center">'+SSLOJ_CLI+'</td> '
			C_HTML += '    <td class="style12">'+ALLTRIM(SSNOME_CLI) +'</td> '
			C_HTML += '    <td class="style12"><div align="center">'+DTOC(STOD(_COMIS->E3_EMISSAO))+'</td> '
			C_HTML += '    <td class="style12"><div align="center">'+DTOC(STOD(_COMIS->E1_VENCTO))+'</td> '
			C_HTML += '    <td class="style12"><div align="center">'+DTOC(STOD(_COMIS->E3_EMISSAO))+'</td> '
			C_HTML += '    <td class="style12"><div align="center">'+DTOC(STOD(_COMIS->E3_DATA))+'</td> '
			C_HTML += '    <td class="style12"><div align="center">'+_COMIS->E3_PEDIDO+'</td> '
			
			IF _C_TITULOS == ALLTRIM(_COMIS->E3_PREFIXO)+ALLTRIM(_COMIS->E3_NUM)+ALLTRIM(_COMIS->E3_PARCELA)+ALLTRIM(_COMIS->E3_CODCLI)+ALLTRIM(_COMIS->E3_LOJA)
				IF _JJ == 1
					_SS_FLAG := "S"
					_JJ ++
					C_HTML += '    <td class="style12"><div align="right">'+TRANSFORM(_COMIS->E1_VALOR	,"@E 999,999,999.99")+'</div></td> '
				ELSE
					_SS_FLAG := "N"
					C_HTML += '    <td class="style12"><div align="right">'+TRANSFORM(0	,"@E 999,999,999.99")+'</div></td> '
				END IF
			ELSE
				_SS_FLAG := "S"
				_C_TITULOS := ALLTRIM(_COMIS->E3_PREFIXO)+ALLTRIM(_COMIS->E3_NUM)+ALLTRIM(_COMIS->E3_PARCELA)+ALLTRIM(_COMIS->E3_CODCLI)+ALLTRIM(_COMIS->E3_LOJA)
				_JJ := 2
				C_HTML += '    <td class="style12"><div align="right">'+TRANSFORM(_COMIS->E1_VALOR	,"@E 999,999,999.99")+'</div></td> '
			END IF
			C_HTML += '    <td class="style12"><div align="right">'+TRANSFORM(_COMIS->E3_BASE	,"@E 999,999,999.99")+'</div></td> '
			C_HTML += '    <td class="style12"><div align="right">'+TRANSFORM(_COMIS->E3_PORC	,"@E 999,999,999.99")+'</div></td> '
			C_HTML += '    <td class="style12"><div align="right">'+TRANSFORM(_COMIS->E3_COMIS	,"@E 999,999,999.99")+'</div></td> '
			C_HTML += '    <td class="style12"><div align="center">'+ALLTRIM(_COMIS->E3_BAIEMI)+'</div></td> '
			C_HTML += '  </tr> '
			
			//Detalhe Faturas
			If Empty(Alltrim(_COMIS->E3_PEDIDO)) .And. Alltrim(_COMIS->E3_TIPO) == "FT"
				cAliasTmp := GetNextAlias()
				//SELECT 'Titulo->'+RTRIM(E1_PREFIXO)+'-'+RTRIM(E1_NUM)+'-'+RTRIM(E1_PARCELA)+' / Pedido->'+E1_PEDIDO AS INFO
				BeginSql Alias cAliasTmp
					SELECT RTRIM(E1_PREFIXO)+'-'+RTRIM(E1_NUM)+'-'+RTRIM(E1_PARCELA) NUM,	E1_VALOR AS VALOR, E1_PEDIDO AS PEDIDO
					FROM %Table:SE1%
					WHERE E1_FATURA = %Exp:_COMIS->E3_NUM% AND E1_PREFIXO = %Exp:_COMIS->E3_PREFIXO% AND E1_TIPO = 'NF' AND E1_YPARCFT = %Exp:_COMIS->E3_PARCELA% AND %NOTDEL%
				EndSql
				C_HTML += '  <tr> '
				C_HTML += '    <td height="95" colspan="16" class="style12"><table width="261" border="1"> '
				C_HTML += '      <tr> '
				C_HTML += '        <td colspan="3" bgcolor="#0066CC"><div align="center" class="style27">INFORMA&Ccedil;&Otilde;ES SOBRE FATURA</div></td> '
				C_HTML += '        </tr> '
				C_HTML += '      <tr> '
				C_HTML += '        <td width="85" bgcolor="#0066CC"><div align="center" class="style27">PREF/NUM/PARC</div></td> '
				C_HTML += '        <td width="44" bgcolor="#0066CC"><div align="center" class="style27">VALOR</div></td> '
				C_HTML += '        <td width="110" bgcolor="#0066CC"> <div align="center" class="style27">PEDIDO</div></td> '
				C_HTML += '      </tr> '
				While  !(cAliasTmp)->(EOF())
					C_HTML += '      <tr> '
					C_HTML += '        <td><div align="center" class="style12">'+(cAliasTmp)->NUM+'</div></td> '
					C_HTML += '        <td><div align="right" class="style12">'+TRANSFORM((cAliasTmp)->VALOR,"@E 999,999,999.99")+'</div></td> '
					C_HTML += '        <td><div align="center" class="style12">'+(cAliasTmp)->PEDIDO+'</div></td> '
					C_HTML += '      </tr> '
					(cAliasTmp)->(dbSkip())
				End
				C_HTML += '    </table></td> '
				C_HTML += '  </tr> '
				/*
				C_HTML += '	<tr>
				C_HTML += '   <td colspan="15" class="style12"><ul>
				C_HTML += '		Informa็๕es de origem da Fatura/Parcela '+Alltrim(_COMIS->E3_NUM)+"-"+Alltrim(_COMIS->E3_PARCELA)
				While  !(cAliasTmp)->(EOF())
				C_HTML += '	<li>'+(cAliasTmp)->INFO+'</li> '
				(cAliasTmp)->(dbSkip())
				End
				C_HTML += '</ul></td> '
				C_HTML += '</tr> '*/
				
				(cAliasTmp)->(dbCloseArea())
			EndIf
			
			CTOTAL_TITULO			+= IIF(_SS_FLAG = "S",_COMIS->E1_VALOR,0)
			CTOTAL_BASE 			+= _COMIS->E3_BASE
			CTOTAL_COMISSAO 		+= _COMIS->E3_COMIS
			CTOTAL_PERCENTUAL 		+= _COMIS->E3_PORC
			CTOTAL_QUANTPERCENTUAL	+=	1
			
			_COMIS->(DBSKIP())
			
			//C_HTML2 += C_HTML
			FWrite(fHtml,C_HTML)
			C_HTML:=''
		END DO
		
		//LINHA EM BRANCO
		C_HTML += '  <tr> '
		C_HTML += '    <td colspan="16" class="style12">&nbsp;</td> '
		C_HTML += '  </tr> '
		
		// LINHA DOS TOTAIS
		C_HTML += ' <tr> '
		C_HTML += '    <td colspan="11" class="style18"><strong>Total do Vendedor: '+CCODIGO+' '+CNOME+' </strong></td> '
		C_HTML += '    <td class="style28"><div align="right">'+TRANSFORM(CTOTAL_TITULO	,"@E 999,999,999.99")+'</td> '
		C_HTML += '    <td class="style28"><div align="right">'+TRANSFORM(CTOTAL_BASE	,"@E 999,999,999.99")+'</td> '
		//Alterado por Wanisay conforme OS 1456-16 no dia 24/01/17
		//C_HTML += '    <td class="style28"><div align="right">'+TRANSFORM(CTOTAL_PERCENTUAL/CTOTAL_QUANTPERCENTUAL	,"@E 999,999,999.99")+'</td> '
		C_HTML += '    <td class="style28"><div align="right">'+TRANSFORM(CTOTAL_COMISSAO/CTOTAL_BASE*100	,"@E 999,999,999.99")+'</td> '		
		C_HTML += '    <td class="style28"><div align="right">'+TRANSFORM(CTOTAL_COMISSAO	,"@E 999,999,999.99")+'</td> '
		C_HTML += '    <td class="style12"></td> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		C_HTML += '    <td colspan="14" class="style18"><strong>Total de IR</strong></td> '
		IF ROUND((CTOTAL_COMISSAO/100) * C_IR,2) < 10
			_CIR_VALOR := 0
		ELSE
			_CIR_VALOR := 	ROUND((CTOTAL_COMISSAO/100) * C_IR,2)
		END IF
		C_HTML += '    <td class="style28"><div align="right">'+TRANSFORM(_CIR_VALOR	,"@E 999,999,999.99")+'</td> '
		C_HTML += '    <td class="style12"></td> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		C_HTML += '    <td colspan="14" class="style18"><strong>Total ( - ) IR</strong></td> '
		C_HTML += '    <td class="style28"><div align="right">'+TRANSFORM(ROUND( CTOTAL_COMISSAO   -  _CIR_VALOR,2) ,"@E 999,999,999.99") +'</td> '
		C_HTML += '    <td class="style12"></td> '
		C_HTML += '  </tr> '
		C_HTML += '</table> '
		C_HTML += '<p>&nbsp;	</p> '
		C_HTML += '</body> '
		C_HTML += '</html> '
		
		C_HTML3 += C_HTML
		FWrite(fHtml,C_HTML)
		C_HTML:=''
		fClose(fHtml)
		
		COMIS_EMAIL(C_HTML1, C_HTML2, C_HTML3)
		C_HTML1 := ""
		C_HTML2 := ""
		C_HTML3 := ""
	END IF
	
	C_HTML := ''
	
	If file(cArqHtml)
		FErase(cArqHtml)
	EndIf
	
	_REPRE->(DBSKIP())
END DO

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
STATIC FUNCTION COMIS_EMAIL(C_HTML1, C_HTML2, C_HTML3)
Local lOk

cRecebe := CEMAIL // Email do(s) receptor(es)
//cRecebe := "wellison.toras@biancogres.com.br"

cAssunto	 := "DEMOSTRATIVOS DE COMISSรO REFERENTE A "+U_DATAR(MV_PAR01,4) //+ ALLTRIM(STR(MONTH(MV_PAR01))) + " DE " + ALLTRIM(STR(YEAR(MV_PAR01))) + "." 				// Assunto do Email
//cMensagem	 += "Segue em anexo o demonstrativo."
 
cArqAnexo := cArqHtml

lOk := U_BIAEnvMail(,cRecebe,cAssunto,cMensagem,,cArqAnexo)

IF !lOK
	ConOut("HORA: "+TIME()+" - COMI_EMAI ERRO AO ENVIAR EMAIL PARA O REPRESENTANTE: " + CCODIGO + " - " + CNOME + " - " + AllTrim(cRecebe))
	MSGBOX("ERRO AO ENVIAR EMAIL PARA O REPRESENTANTE: " + CCODIGO + " - " + CCODIGO + " - " + CNOME + " - " + AllTrim(cRecebe) )
Else
	ConOut("HORA: "+TIME()+" - COMI_EMAI enviado para o representante: " + CCODIGO + " - " + CNOME + " - " + AllTrim(cRecebe))
ENDIF

FErase(cArqHtml)

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ COMZMAIL            บAutor  ณ FERNANDO ROCHA     บ Data ณ  05/08/2010 บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       ROTINA PARA GERAR O EMAIL DE COMISSOES ZERADAS             บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COMZMAIL(_CDATAEMIS,_CHORAEMIS,_CCLIENTE,_CVEND,_ATITULOS)
Local C_MENS 		:= ""
Local _CEMPRESA  	:= ""
Local I

DO CASE
	CASE CEMPANT = "01"
		_CEMPRESA += 'BIANCOGRES CERAMICA SA'
	CASE CEMPANT = "05"
		_CEMPRESA += 'INCESA REVESTIMENTO CERยMICO LTDA'
	CASE CEMPANT = "07"
		_CEMPRESA += 'LM COMERCIO LTDA'
	CASE CEMPANT = "14"
		_CEMPRESA += 'VITCER RETIFICA E COMPLEMENTOS CERAMICOS LTDA'
	OTHERWISE
		_CEMPRESA += '???????????????'
ENDCASE

C_MENS 		+= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
C_MENS 		+= '<html xmlns="http://www.w3.org/1999/xhtml"> '
C_MENS 		+= '<head> '
C_MENS 		+= '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
C_MENS 		+= '<title>Untitled Document</title> '
C_MENS 		+= '<style type="text/css"> '
C_MENS 		+= '<!-- '
C_MENS 		+= '.style12 {font-size: 9px; } '
C_MENS 		+= '.style35 {font-size: 11pt; font-weight: bold; } '
C_MENS 		+= '.style36 {font-size: 9pt; } '
C_MENS 		+= '.style41 { '
C_MENS 		+= '	font-size: 12px; '
C_MENS 		+= '	font-weight: bold; '
C_MENS 		+= '} '
C_MENS 		+= '.style44 {color: #FFFFFF; font-size: 10px; } '
C_MENS 		+= '.style45 {font-size: 10px; }	 '
C_MENS 		+= '--> '
C_MENS 		+= '</style> '
C_MENS 		+= '</head> '
C_MENS 		+= '<body> '
C_MENS 		+= '<table width="100%" border="1"> '
C_MENS 		+= '  <tr> '
C_MENS 		+= '    <th width="751" rowspan="3" scope="col">COMISS&Atilde;O ZERADA NO CONTAS A RECEBER </th> '
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
C_MENS 		+= '  <tr bgcolor="#FFFFFF"> '
C_MENS 		+= '	<td> '
C_MENS 		+= '   		<div align="left"><font size="-1" style="font-weight:bold">CLIENTE:</font></div> '
C_MENS 		+= '    </td>   '
C_MENS 		+= '    <th colspan="4" scope="col"> '
C_MENS 		+= '   		<div align="left"><font size="-1" style="font-style:normal">'+_CCLIENTE+'</font></div> '
C_MENS 		+= '    </th> '
C_MENS 		+= '  </tr> '
C_MENS 		+= '  <tr bgcolor="#FFFFFF">
C_MENS 		+= ' 	<td>
C_MENS 		+= ' 	   	<div align="left"><font size="-1" style="font-weight:bold">REPRESENTANTE:</font></div>
C_MENS 		+= ' 	</td>
C_MENS 		+= ' 	<th colspan="4" scope="col">
C_MENS 		+= '   		<div align="left"><font size="-1" style="font-style:normal">'+_CVEND+'</font></div>
C_MENS 		+= ' 	</th>
C_MENS 		+= '  </tr>
C_MENS 		+= '  <tr bgcolor="#0066CC"> '
C_MENS 		+= '    <th width="100"	scope="col"><span class="style44">PREFIXO </span></th> '
C_MENS 		+= '    <th width="68" scope="col"><span class="style44">NUMERO </span></th> '
C_MENS 		+= '    <th width="79" scope="col"><span class="style44">PARCELA</span></th> '
C_MENS 		+= '    <th width="83" scope="col"><span class="style44">TIPO</span></th> '
C_MENS 		+= '    <th width="412" scope="col"><span class="style44">HISTORICO</span></th> '
C_MENS 		+= '  </tr> '

FOR I := 1 TO LEN(_ATITULOS)
	C_MENS 		+= '  <tr> '
	C_MENS 		+= '    <td class="style45">'+_ATITULOS[I][1]+'</td> '
	C_MENS 		+= '    <td class="style45">'+_ATITULOS[I][2]+'</td> '
	C_MENS 		+= '    <td class="style45">'+_ATITULOS[I][3]+'</td> '
	C_MENS 		+= '    <td class="style45">'+_ATITULOS[I][4]+'</td> '
	C_MENS 		+= '    <td class="style45">'+_ATITULOS[I][5]+'</td> '
	C_MENS 		+= '  </tr> '
NEXT I

C_MENS 		+= '<tr bordercolor="#FFFFFF"> '
C_MENS 		+= '    <td colspan="5">&nbsp;</td> '
C_MENS 		+= '  </tr> '
C_MENS 		+= '</table> '
C_MENS 		+= '<p class="style35">Esta ้ uma mensagem automแtica, favor nใo responde-la. </p> '
C_MENS 		+= '</body> '
C_MENS 		+= '</html> '

Return(C_MENS)