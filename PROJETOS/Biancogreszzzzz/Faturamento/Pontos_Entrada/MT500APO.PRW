#include "rwMake.ch"
#include "Topconn.ch"
#Include "PROTHEUS.CH"                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT500APO       ºAutor  ³Ranisses A. Corona  º Data ³  29/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a data que foi realizado a Eliminicao por Residuo          º±±
±±º          ³ Envia mensagem apos a eliminacao do PV por Residuo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT500APO()
	Local Enter	:= CHR(13)+CHR(10)
	Local nQuant := 0
	Local nEmail := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_EMAIL")
	Local nVend	:= Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
	Local lFlag	:= .T. 
	Local cMotivo	:= "" 	         
	Local aAreaAnt := GetArea()
	Local cCodVend := SC5->C5_VEND1
	Local cPedNUm	:= SC5->C5_NUM
	Local cMailAnted := ''

	// Tratamento especial - roda via RPC - eliminacao automatica de residuo na LM a partir da origem - PE M410VRES
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","FXRESLM###RPC")
		Return Nil
	EndIf


	// O P.E., passa para todos os itens, porem so envia o e-mail com todos os itens uma unica vez.
	If cContador == 0

		// Busca informações pelo cliente correto
		If !Empty(SC5->C5_YCLIORI)

			cLC5 := " SELECT C5_VEND1, C5_NUM "
			cLC5 += " FROM SC5070 "
			cLC5 += " WHERE C5_YPEDORI = "+ ValToSQL(SC6->C6_NUM)
			cLC5 += " AND C5_YEMPPED = "+ ValToSQL(cEmpAnt)
			cLC5 += " AND D_E_L_E_T_ = '' "

			If chkfile("TLC5")
				dbSelectArea("TLC5")
				dbCloseArea()
			EndIf			

			dbUseArea(.T.,"TOPCONN", TcGenQry(,,cLC5),'TLC5',.T.,.T.)

			DBSelectArea('TLC5')
			dbGoTop()

			If !TLC5->(Eof()) 

				nEmail := Posicione("SA3",1,xFilial("SA3")+TLC5->C5_VEND1,"A3_EMAIL")
				nVend := Posicione("SA3",1,xFilial("SA3")+TLC5->C5_VEND1,"A3_NOME")
				cCodVend := TLC5->C5_VEND1
				cPedNUm := TLC5->C5_NUM

			EndIf

			dbCloseArea('TLC5')

		EndIf	

		// Busca descrição do motivo de cancelamento				
		cMotivo := U_BIAF097(SC6->C6_YMOTIVO)
		
		If Empty(cMotivo)
			cMotivo := "NÃO INFORMADO"
		EndIf
		
		dbSelectArea("SA1")                // * Cadastro de Clientes
		dbSetOrder(1)
		If !Empty(SC5->C5_YCLIORI)
			dbSeek(xFilial('SA1')+SC5->C5_YCLIORI+SC5->C5_YLOJORI)		 	
		Else	
			dbSeek(xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		EndIF
		
		//SELECONANDO EMPRESA MARCA, PARA ENVIAR O E-MAIL PRO ATENDENTE DA EMPRESA CORRETA 
		cSql := " SELECT SUBSTRING(ZZ7.ZZ7_EMP,1,2) AS ZZ7_EMP"
		cSql += " FROM SB1010 SB1"
		cSql += " 	INNER JOIN ZZ7010 ZZ7 ON SB1.B1_YLINHA = ZZ7.ZZ7_COD"
		cSql += " 		AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ"
		cSql += " 		AND ZZ7.ZZ7_FILIAL = ''"
		cSql += " 		AND ZZ7.D_E_L_E_T_ = ''"
		cSql += " WHERE SB1.B1_COD IN ('" + SC6->C6_PRODUTO + "')"
		cSql += " 	AND SB1.B1_FILIAL = ''"
		cSql += " 	AND SB1.D_E_L_E_T_ = ''"

		IF CHKFILE("_EMP")
			DBSELECTAREA("_EMP")
			DBCLOSEAREA()
		ENDIF

		TCQUERY cSql ALIAS "_EMP" NEW

		//cMailAnted := U_MailAtendente(cEmpAnt,SC6->C6_NUM,cCodVend,SA1->A1_COD,SA1->A1_LOJA)
		cMailAnted := U_MailAtendente(Iif(AllTrim(_EMP->ZZ7_EMP) = "" .Or. ValType(_EMP->ZZ7_EMP) == "U", cEmpAnt, _EMP->ZZ7_EMP),SC6->C6_NUM,cCodVend,SA1->A1_COD,SA1->A1_LOJA)
		

		// Selecionando a quantidade de itens a serem eliminados
		cSql := " SELECT COUNT(*) AS QUANT "
		cSql += " FROM "+ RetSqlName("SC6")
		cSql += " WHERE C6_FILIAL	= "+ ValToSQL(xFilial("SC6"))
		cSql += " AND C6_NUM = "+ ValToSQL(SC6->C6_NUM)
		cSql += "	AND C6_CLI = "+ ValToSQL(SC6->C6_CLI)
		cSql += "	AND C6_LOJA = "+ ValToSQL(SC6->C6_LOJA)
		cSql += " AND C6_QTDVEN-C6_QTDENT > 0 "
		cSql += "	AND D_E_L_E_T_ = '' "

		// Verifica se esta sendo executado pela rotina de Eliminar Residuo
		If AllTrim(FunName()) == "MATA500"
			cSql += " AND C6_OK	"+ If (ThisInv(), "<>", "=") + ValToSQL(ThisMark()) // SOMENTE O ITEM QUE ESTA SENDO ELIMINADO
		EndIf

		IF CHKFILE("_PED")
			DBSELECTAREA("_PED")
			DBCLOSEAREA()
		ENDIF

		TCQUERY cSql ALIAS "_PED" NEW


		// Acumula a Quantidade de itens
		nQuant := _PED->QUANT // Utilizado na montagem do HTML
		cContAux := _PED->QUANT // Utilizado no controle do envio do e-mail


		// Selecionando todos os itens
		cSql := " SELECT C6_YEMP, C6_PRODUTO, C6_DESCRI, C6_QTDVEN-C6_QTDENT SALDO "		
		cSql += " FROM "+ RetSqlName("SC6")
		cSql += " WHERE C6_FILIAL	= "+ ValToSQL(xFilial("SC6"))
		cSql += " AND C6_NUM = "+ ValToSQL(SC6->C6_NUM)
		cSql += "	AND C6_CLI = "+ ValToSQL(SC6->C6_CLI)
		cSql += "	AND C6_LOJA = "+ ValToSQL(SC6->C6_LOJA)
		cSql += " AND C6_QTDVEN-C6_QTDENT > 0 "
		cSql += "	AND D_E_L_E_T_ = '' "

		// Verifica se esta sendo executado pela rotina de Eliminar Residuo
		If AllTrim(FunName()) == "MATA500"
			cSql += " AND C6_OK	"+ If (ThisInv(), "<>", "=") + ValToSQL(ThisMark()) // SOMENTE O ITEM QUE ESTA SENDO ELIMINADO
		EndIf

		IF CHKFILE("_PED")
			DBSELECTAREA("_PED")
			DBCLOSEAREA()
		ENDIF

		TCQUERY cSql ALIAS "_PED" NEW  


		//Armazenando o HTML
		C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
		C_HTML += '<head> '
		C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		C_HTML += '<title>Untitled Document</title> '
		C_HTML += '<style type="text/css"> '
		C_HTML += '<!-- '
		C_HTML += '.style12 { '
		C_HTML += '	font-size: 12px; '
		C_HTML += '	font-family: Verdana, Geneva, sans-serif; '
		C_HTML += '} '
		C_HTML += '.style18 { '
		C_HTML += '	font-size: 10; '
		C_HTML += '	font-family: Verdana, Geneva, sans-serif; '
		C_HTML += '} '
		C_HTML += '.style21 { '
		C_HTML += '	color: #FFFFFF; '
		C_HTML += '	font-size: 12px; '
		C_HTML += '	font-family: Verdana, Geneva, sans-serif; '
		C_HTML += '} '
		C_HTML += '.style22 { '
		C_HTML += '	font-size: 10pt; '
		C_HTML += '	font-weight: bold; '
		C_HTML += '	font-family: Verdana, Geneva, sans-serif; '
		C_HTML += '} '
		C_HTML += '.style35 { '
		C_HTML += '	font-size: 10pt; '
		C_HTML += '	font-family: Verdana, Geneva, sans-serif; '
		C_HTML += '} '
		C_HTML += '.style36 { '
		C_HTML += '	font-size: 8pt; '
		C_HTML += '	font-family: Verdana, Geneva, sans-serif; '
		C_HTML += '} '
		C_HTML += '.style39 { '
		C_HTML += '	font-size: 10pt; '
		C_HTML += '	font-family: Verdana, Geneva, sans-serif; '
		C_HTML += '} '
		C_HTML += '.style41 { '
		C_HTML += '	font-size: 12px; '
		C_HTML += '	font-weight: bold; '
		C_HTML += '	font-family: Verdana, Geneva, sans-serif; '
		C_HTML += '} '
		C_HTML += ' '
		C_HTML += '--> '
		C_HTML += '</style> '
		C_HTML += '</head> '
		C_HTML += ' '
		C_HTML += '<body> '
		C_HTML += '<table width="1200" border="1"> '
		C_HTML += '  <tr> '
		C_HTML += '    <th width="719" rowspan="3" class="style41" scope="col">PEDIDOS ELIMINADOS POR RES&Iacute;DUO</th> '
		C_HTML += '    <td width="221" class="style12"><div align="right"> DATA EMISSÃO: '+dtoc(ddatabase)+' </div></td> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		C_HTML += '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+TIME()+' </div></td> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '

		Do Case 
			Case Alltrim(SC6->C6_YEMP) = "0101"
			C_HTML += '    <td><div align="center" class="style41"> BIANCOGRES CERÂMICA SA </div></td> '
			Case Alltrim(SC6->C6_YEMP) $ "0501/1399"
			C_HTML += '    <td><div align="center" class="style41"> INCESA CERAMICA LTDA   </div></td> '
			Case Alltrim(SC6->C6_YEMP) = "0599"
			C_HTML += '    <td><div align="center" class="style41"> BELLACASA CERAMICA     </div></td> '
			Case Alltrim(SC6->C6_YEMP) = "1301"
			C_HTML += '    <td><div align="center" class="style41"> MUNDI                  </div></td> '
			Case Alltrim(SC6->C6_YEMP) = "1401"
			C_HTML += '    <td><div align="center" class="style41"> VITCER                 </div></td> '
			Otherwise
			C_HTML += '    <td><div align="center" class="style41"> EMPRESA NÃO CADASTRADA </div></td> '	   
		EndCase

		C_HTML += '  </tr> '
		C_HTML += '</table> '
		C_HTML += '<table width="1200" border="1"> '
		C_HTML += '  <tr bgcolor="#FFFFFF"> '
		C_HTML += '    <th colspan="7" scope="col"><div align="left" class="style39"> Vendedor: '+cCodVend+' - '+nVend+' </div></th> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr bgcolor="#0066CC"> '
		C_HTML += '    <th width="58"	scope="col"><span class="style21"> Pedido</span></th> '
		C_HTML += '    <th width="79" 	scope="col"><span class="style21">Emiss&atilde;o</span></th> '
		C_HTML += '    <th width="61" 	scope="col"><span class="style21"> Cliente</span></th> '
		C_HTML += '    <th width="254" 	scope="col"><span class="style21">Raz&atilde;o Social</span></th> '
		C_HTML += '	   <th width="254" 	scope="col"><span class="style21">Motivo Canc.</span></th> '
		C_HTML += '    <th width="96" 	scope="col"><span class="style21"> Produto</span></th> '
		C_HTML += '    <th width="269" 	scope="col"><span class="style21"> Descri&ccedil;&atilde;o</span></th> '
		C_HTML += '    <th width="93" 	scope="col"><span class="style21"> Saldo Cancelado</span></th> '
		C_HTML += '  </tr> '

		// Processa os itens do Pedido
		While !_PED->(EOF())

			If lFlag
				C_HTML += '  <tr> '
				C_HTML += '    <td rowspan="'+Alltrim(Str(nQuant))+'" class="style12"><div align="center">'+cPedNUm+'</div>      <div align="center"></div>      <div align="center"></div> </td> '
				C_HTML += '    <td rowspan="'+Alltrim(Str(nQuant))+'" class="style12"><div align="center">'+Dtoc(SC5->C5_EMISSAO)+'</div>      <div align="center"></div>      <div align="center"></div> </td> '
				C_HTML += '    <td rowspan="'+Alltrim(Str(nQuant))+'" class="style12"><div align="center">'+SA1->A1_COD+'</div>      <div align="center"></div>      <div align="center"></div>    </td> '
				C_HTML += '    <td rowspan="'+Alltrim(Str(nQuant))+'" class="style12">'+SA1->A1_NOME+'</td> '
				C_HTML += '    <td rowspan="'+Alltrim(Str(nQuant))+'" class="style12">'+cMotivo+'</td> '
				C_HTML += '    <td class="style12"><div align="left">'+_PED->C6_PRODUTO+' </div></td> '
				C_HTML += '    <td class="style12">'+_PED->C6_DESCRI+' </td> '
				//C_HTML += '    <td class="style12"><div align="right">'+Alltrim(Str(_PED->SALDO))+'</div></td> '
				C_HTML += '    <td class="style12"><div align="right">'+Transform(_PED->SALDO,"@E 999,999.99")+'</div></td> '														
				C_HTML += '  </tr> '
				lFlag  := .F.
			Else
				C_HTML += '  <tr> '
				C_HTML += '    <td class="style12"><div align="left">'+_PED->C6_PRODUTO+' </div></td> '
				C_HTML += '    <td class="style12">'+_PED->C6_DESCRI+' </td> '
				//C_HTML += '    <td class="style12"><div align="right">'+Alltrim(Str(_PED->SALDO))+'</div></td> '
				C_HTML += '    <td class="style12"><div align="right">'+Transform(_PED->SALDO,"@E 999,999.99")+'</div></td> '														
				C_HTML += '  </tr> '
			EndIf

			_PED->(DBSKIP())

		EndDo

		C_HTML += '</table> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="center" class="style12">  '
		C_HTML += '      <div align="left">Esta é uma mensagem automática, favor não responde-la. </div> '
		C_HTML += '    </div></td> '
		C_HTML += '  </tr> '
		C_HTML += '</body> '
		C_HTML += '</html> '

		Do Case 
			Case Alltrim(SC6->C6_YEMP) == "0101"
			aDestinatario	:= nEmail+";dalvina.ferreira@biancogres.com.br" 
			aCC := cMailAnted+"; cancelamento.biancogres@biancogres.com.br"	//"claudeir.fadini@biancogres.com.br"
			aCCO := "" 																					//"ranisses.corona@biancogres.com.br"
			Case Alltrim(SC6->C6_YEMP) $ "0501/1399"		
			aDestinatario	:= nEmail+";william.pernes@biancogres.com.br"
			aCC	:= cMailAnted+"; cancelamento.incesa@incesa.ind.br"					
			aCCO:= "" 																					//"ranisses.corona@biancogres.com.br"
			Case Alltrim(SC6->C6_YEMP) == "0599"
			aDestinatario	:= nEmail+";william.pernes@biancogres.com.br"
			aCC := cMailAnted+"; cancelamento.bellacasa@bellacasaceramica.com.br"	//"carlos.michels@bellacasaceramica.com.br;mateus.fadini@bellacasaceramica.com.br"
			aCCO := "" 																								//"ranisses.corona@biancogres.com.br"
			Case Alltrim(SC6->C6_YEMP) == "1301"
			aDestinatario	:= nEmail+";rodolfo.stanke.mundi@biancogres.com.br"
			aCC	:= cMailAnted+"; cancelamento.biancogres@biancogres.com.br"	//"carlos.michels@bellacasaceramica.com.br;mateus.fadini@bellacasaceramica.com.br"
			aCCO := "" 																								//"ranisses.corona@biancogres.com.br"
			Case Alltrim(SC6->C6_YEMP) == "1401"
			aDestinatario	:= nEmail+";joan.mareto@vitcer.com.br"
			aCC	:= cMailAnted+"; cancelamento.biancogres@biancogres.com.br"	//"carlos.michels@bellacasaceramica.com.br;mateus.fadini@bellacasaceramica.com.br"
			aCCO := "" 																								//"ranisses.corona@biancogres.com.br"
			Otherwise
			aDestinatario	:= cMailAnted+"; suporte.ti@biancogres.com.br"
			aCC := ""
			aCCO := ""			
		EndCase

		cTitulo	:= "PEDIDO ELIMINADO POR RESÍDUO"

		//Envia e-mail
		U_BIAEnvMail(,aDestinatario,cTitulo,C_HTML,,,,aCC,aCCO )

		// Tiago Rossini Coradini - 25/01/16 - OS: 4849-15 - Clebes Jose - Envia workflow caso o pedido esteja associado ao um RA
		U_BIAF018(SC5->C5_NUM, SC5->C5_YCLIORI)

	EndIf

	// Acumula no Contador	
	cContador ++

	RestArea(aAreaAnt)

Return


User Function fPedCan()
Local := cNumPEd := "D33511"

	DbSelectArea("SC5")
	DbSetOrder(1)
	If SC5->(DbSeek(xFilial("SC5") + cNumPed))
	
		DbSelectArea("SC6")
		DbSetOrder(1)
		If SC6->(DbSeek(xFilial("SC6") + cNumPed))
	
			U_MT500APO()
		
		EndIf
		
	EndIf

Return()