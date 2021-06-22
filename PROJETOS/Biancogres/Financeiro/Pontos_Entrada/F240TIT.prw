#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F240TIT
@description PE MONTAGEM DO BORDERO 
@author BRUNO MADALENO / Revisado por Fernando
@since 22/06/07
@version 1.0
@type function
/*/

USER FUNCTION F240TIT()
	local aArea:=getArea()
	local aAreaSE2:=getArea()
	local lRet:=.T.
	MsAguarde({||lRet:=F240TIT()})
	restArea(aAreaSE2)
	restArea(aArea)
Return(lRet)

static function F240TIT()

	local aF240TIT:=array(0)
	
	Local cMens:=""
	LOCAL cQUERY	:= ""
	LOCAL lRetorno	:= .T.
	Local lFA240MARK := stackTools():IsInCallStack("FA240MARK")
	local lBAF001FD:=stackTools():IsInCallStack("U_BAF001FD")

	aF240TIT:=cacheData():get("F240TIT","aF240TIT",aF240TIT)

	Enter := chr(13) + Chr(10)

	IF ALLTRIM(SE2->E2_TIPO) <> 'PA'  .AND. SE2->E2_TIPO <> 'NDF' .AND. SE2->E2_YBLQ <> 'XX'

		cQUERY := "SELECT	COUNT(E2_FORNECE) AS cCONT FROM "+RETSQLNAME("SE2")+" " + ENTER
		cQUERY += "WHERE	E2_FORNECE	= '"+SE2->E2_FORNECE+"'	AND " + ENTER
		cQUERY += "			E2_LOJA		= '"+SE2->E2_LOJA+"'	AND " + ENTER
		cQUERY += "			E2_TIPO		IN ('PA','NDF')	AND	" + ENTER
		cQUERY += "			E2_SALDO	<> 0	AND	" + ENTER
		cQUERY += "			D_E_L_E_T_ 	= ''		" + ENTER

		If chkfile("_QUANT")
			dbSelectArea("_QUANT")
			dbCloseArea()
		EndIf

		TCQUERY cQUERY ALIAS "_QUANT" NEW

		IF _QUANT->cCONT <> 0  .AND. CEMPANT <> "02"

			cMens := "O TITULO/FORNECEDOR DESCRITO ABAIXO POSSUI PA/NDF EM ABERTO!" +ENTER
			cMens += ENTER
			cMens += "Número do Titulo:	" + SE2->E2_NUM + ENTER
			cMens += "Cod Fornecedor:	" + SE2->E2_FORNECE + ENTER
			cMens += "Nome Fornecedor:	" + SE2->E2_NOMFOR + ENTER
			cMens += ENTER
			cMens += 	"ESTE TÍTULO TEM QUE SER COMPENSADO COM O PA/NDF."

			If IsBlind()

				ConOut(cMens)
				lRetorno := .F.

			Else

				if (lFA240MARK)
					Help(nil,nil,"__F240TIT__","__F240TIT__","O TITULO/FORNECEDOR DESCRITO ABAIXO POSSUI PA/NDF EM ABERTO!",1,0,nil,nil,nil,nil,nil,{cMens})
				else
					aAdd(aF240TIT,cMens)
				endif

				lRetorno := .F.

			EndIf

			//ATUALIZANDO O CAMPO PARA BLOQUEAR O TITULO
			nRegSE2 := ALLTRIM(STR( SE2->(RecNo()) ))
			CSQL := " UPDATE "+RETSQLNAME("SE2")+" SET E2_YBLQ = '01' WHERE R_E_C_N_O_ = '"+nRegSE2+"' "

			TCSQLExec(CSQL)

			If !IsBlind()

				GeraHtml()

			EndIf

		ENDIF

	ENDIF

	IF (ALLTRIM(SE2->E2_TIPO) == "TX" .OR. ALLTRIM(SE2->E2_TIPO) == "ST") .AND. SE2->E2_SALDO <> 0

		//Analisa se um título de imposto já esteve em borderôs anteriores cancelados com o objetivo de não enviar um mesmo título duas vezes para banco e efetuar o seu pagamento em duplicidade
		//Inserido por Wanisay - 28/08/12

		cQUERY := "SELECT	EA_PREFIXO, EA_NUM, EA_PARCELA, EA_TIPO, EA_FORNECE, EA_LOJA " + ENTER
		cQUERY += "FROM "+RETSQLNAME("SEA")+" " + ENTER
		cQUERY += "WHERE	EA_PREFIXO  =  '"+SE2->E2_PREFIXO+"' AND  " + ENTER
		cQUERY += "	      EA_NUM      =  '"+SE2->E2_NUM+"'     AND  " + ENTER
		cQUERY += "	      EA_PARCELA  =  '"+SE2->E2_PARCELA+"' AND  " + ENTER
		cQUERY += "	      EA_TIPO     =  '"+SE2->E2_TIPO+"'    AND  " + ENTER
		cQUERY += "	      EA_FORNECE  =  '"+SE2->E2_FORNECE+"' AND  " + ENTER
		cQUERY += "	      EA_LOJA     =  '"+SE2->E2_LOJA+"'    AND  " + ENTER
		cQUERY += "       EA_CART     = 'P'                    AND  " + ENTER
		cQUERY += "		    D_E_L_E_T_ 	= '*' " + ENTER

		If chkfile("_QTD")
			dbSelectArea("_QTD")
			dbCloseArea()
		EndIf

		TCQUERY cQUERY ALIAS "_QTD" NEW

		DbSelectArea("_QTD")

		cMens:=""

		While _QTD->(!Eof())
			cMens+="Este título: "
			cMens+=ALLTRIM(EA_PREFIXO)
			cMens+="/"
			cMens+=ALLTRIM(EA_NUM)
			cMens+="/"
			cMens+=ALLTRIM(EA_PARCELA)
			cMens+="/"+ALLTRIM(EA_TIPO)
			cMens+="/"+ALLTRIM(EA_FORNECE)
			cMens+="/"+ALLTRIM(EA_LOJA)
			cMens+=" que está neste borderô, já foi relacionado em borderô anterior já cancelado! Verifique se este título já foi enviado para o banco e pago!"
			aAdd(aF240TIT,cMens)
			_QTD->(DbSkip())
		END

		if (lFA240MARK)
			Help(nil,nil,"__F240TIT__","__F240TIT__","TITULOS JA VINCULADOS A BORDERÔ!",1,0,nil,nil,nil,nil,nil,{cMens})
		else
			If IsBlind()
				ConOut(cMens)
			else
				aAdd(aF240TIT,cMens)
			endif
		endif

	ENDIF

	If Empty(SE2->E2_NUMBOR) .And. SE2->E2_YBLQ <> 'XX' .And. Alltrim(SE2->E2_TIPO) <> 'PA' .And. SE2->E2_TIPO <> 'NDF' .And. U_BIAF076()	

		lRetorno := .F.

	EndIf	

	if ((!lBAF001FD).and.(FIDC():isPGFIDC(.F.)))
		cMens:="Titulos FIDC não podem ser utilizados para geração de Borderô"
		cMens+=ENTER
		cMens+=ENTER
		cMens+="Número do Titulo: "+SE2->E2_NUM
		cMens+=ENTER
		cMens+="Cod Fornecedor:	"+SE2->E2_FORNECE
		cMens+=ENTER
		cMens+="Nome Fornecedor: "+SE2->E2_NOMFOR
		lRetorno := .F.
		if (lFA240MARK)
			Help(nil,nil,"__FIDC__","__FIDC__","Título(s) FIDC",1,0,nil,nil,nil,nil,nil,{cMens})
		else
			aAdd(aF240TIT,cMens)
		endif
	endif

	if (!lRetorno)
		if (IsBlind())
			if (!empty(aF240TIT))
				aEval(aF240TIT,{|e|ConOut(e)})
			endif
		endif
	endif

	if ((lBAF001FD).and.(!lRetorno))
		if (!empty(cMens))
			cacheData():set("F240TIT","cMens",cMens)
		endif
	endif

	cacheData():set("F240TIT","aF240TIT",aF240TIT)

Return(lRetorno)        

Static Function GeraHtml()        

	// ENVIANCO EMAIL PARA OS RESPONSAVEIS PELO FINANCEIRO
	C_TITULO 	:= "Titulo do Contas a Pagar Bloqueado"
	C_DESTI		:= "gardenia.stelzer@biancogres.com.br" 

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

	//CABECALHO	
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                        
	C_HTML += '<font color="white"> '

	DO CASE
		CASE cEmpAnt = "01"
		C_HTML += '  <th scope="col"> TITULO À PAGAR BLOQUEADO NA EMPRESA BIANCOGRES <br>'			
		CASE cEmpAnt = "05"   
		C_HTML += '  <th scope="col"> TITULO À PAGAR BLOQUEADO NA EMPRESA INCESA <br>'			
		OTHERWISE
		C_HTML += '  <th scope="col"> TITULO À PAGAR BLOQUEADO <br>'			
	ENDCASE                        

	C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> ' 

	//DADOS 
	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" bgcolor="#7A67EE"> '
	C_HTML += '<font color="white"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col"> DADOS DO TITULO:  </th> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '        

	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2"> '
	C_HTML += '<font color="black" size="2"> '              

	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> NÚMERO DO TITULO: <b>'+SE2->E2_NUM+'</b></td> '
	C_HTML += '  </tr> '  
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> CÓDIGO DO FORNECEDOR: <b>'+Alltrim(SE2->E2_FORNECE)+'</b></td> '
	C_HTML += '  </tr> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> LOJA DO FORNECEDOR: <b>'+Alltrim(SE2->E2_LOJA)+'</b></td> '
	C_HTML += '  </tr> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> NOME DO FORNECEDOR: <b>'+Alltrim(SE2->E2_NOMFOR)+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> VALOR DO TITULO: <b>'+Transform(SE2->E2_VALOR,"@E 999,999,999.99")+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> SALDO DO TITULO: <b>'+Transform(SE2->E2_SALDO,"@E 999,999,999.99")+'</b></td> '
	C_HTML += '  </tr> '

	C_HTML += '</font>'        
	C_HTML += '</table> '   

	C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '     
	C_HTML += '<p>&nbsp;	</p> '
	C_HTML += '</body> '
	C_HTML += '</html> '

	U_BIAEnvMail(,C_DESTI,C_TITULO,C_HTML)

Return()
