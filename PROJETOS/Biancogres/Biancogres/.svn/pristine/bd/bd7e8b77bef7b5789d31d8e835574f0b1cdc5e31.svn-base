#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} MT120GRV
@author Ranisses A. Corona
@since 15/12/05
@version 1.0
@description *Gravacao do TES com as informacoes de Creditos de impostos
.             no Pedido de Compras                                      
.             Valida se a Naturaza do Fornecedor esta bloqueada.        
.             Valida se o Fornecedor esta com o campo Mun. preenchido. 
@obs Em 22/02/17... Por Marcos Alberto Soprani... Incluído uma nota função BValTpForX9 para controlar a inclusao de PO
@type function
/*/

User Function MT120GRV()

	Local xn
	Private xn, nPosProduto, nPosTes, nPosIcms, nPosPis, nPosCofins, nPosIpi, nPosTotal, nPosNumSC := 0
	Private nRet 		:= .T.
	Private lAprovacao 	:= .T.
	Private cFornece 	:= ""
	Private cLoja    	:= ""
	Private nVlrTotal	:= 0
	Private cNumSc		:= ""

	Private lDebug 		:= .F.

	nPosNumSC := AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_NUMSC'})
	cNumSc	  := aCols[1,nPosNumSC]

	//Grava Informacoes do TES no Pedido de Compras
	For xn := 1 to Len(acols)
		If !(aCols[xn][Len(aHeader)+1]  )   //LINHA DELETADA
			nPosProduto	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_PRODUTO'})
			nPosTes	  	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_TES'})
			nPosIcms   	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_YICMS'})
			nPosPis	   	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_YPIS'})
			nPosCofins	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_YCOF'})
			nPosIpi 	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_YIPI'})
			nPosTotal	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_TOTAL'})

			nVlrTotal 	+= aCols[xn,nPosTotal]

			//Pesquisa Cadastro Produto
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+aCols[xn,nPosProduto],.T.)

			If Alltrim(SB1->B1_TE) <> ""

				//Pesquisa Cadastro de TES
				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek(xFilial("SF4")+SB1->B1_TE,.T.)

				aCols[xn,nPosTes]	  	:= SB1->B1_TE
				aCols[xn,nPosIcms]		:= Iif(SF4->F4_CREDICM=="S","S","N")
				aCols[xn,nPosIpi]		:= Iif(SF4->F4_CREDIPI=="S","S","N")
				aCols[xn,nPosPis]		:= Iif(SF4->F4_PISCOF $ "13" .AND. SF4->F4_PISCRED =="1","S","N")
				aCols[xn,nPosCofins]	:= Iif(SF4->F4_PISCOF $ "23" .AND. SF4->F4_PISCRED =="1","S","N")

				nRet := .T.

			EndIf

			IF !SUBSTRING(SB1->B1_GRUPO,1,3) $ "101/102/103/104/105/107/301/302/303/304/305/306/307/308/309" .And. !FwIsInCallStack('U_BIAFG030')

				//Avalia se o número de cotações está adequado ao produto
				cQuery := ""
				cQuery += "SELECT C8_PRODUTO, COUNT(C8_FORNECE) AS QUANT FROM ( "
				cQuery += "SELECT C8_PRODUTO, C8_FORNECE, COUNT(C8_FORNECE) AS QUANT FROM "+RetSqlName("SC8")+" SC8 WHERE C8_EMISSAO BETWEEN '"+DTOS(dDATABASE - 180)+"' AND '"+DTOS(dDATABASE)+"' AND C8_PRODUTO = '"+SB1->B1_COD+"' AND D_E_L_E_T_ = '' "
				cQuery += "GROUP BY C8_PRODUTO, C8_FORNECE) AS WWW GROUP BY C8_PRODUTO ORDER BY C8_PRODUTO"

				If chkfile("_SC8")
					dbSelectArea("_SC8")
					dbCloseArea()
				EndIf
				TCQUERY cQuery ALIAS "_SC8" NEW
				cNumCot := ''

				DO CASE
					CASE SB1->B1_YTPCOT == 'A' .AND. _SC8->QUANT = 0
					MSGBOX("O produto "+Alltrim(SB1->B1_COD)+" deverá ter pelo menos uma cotação no período de SEIS MESES pois o produto está cadastrado como ESPECÍFICO => Comprado apenas de um único fornecedor.","STOP")
					//lAprovacao := .F.
					CASE SB1->B1_YTPCOT == 'B' .AND. _SC8->QUANT < 3
					MSGBOX("O produto "+Alltrim(SB1->B1_COD)+" deverá ter pelo menos três cotações no período de SEIS MESES pois o produto está cadastrado como SEMESTRAL => Deve possuir três cotações no perídodo de seis meses.","STOP")
					//Substituir a busca na query e cadastrar a tabela.
					//lAprovacao := .F.
					CASE SB1->B1_YTPCOT == 'C'
					cQuery := ""
					cQuery += "SELECT C8_PRODUTO, COUNT(C8_FORNECE) AS QUANT FROM ( "
					cQuery += "SELECT C8_PRODUTO, C8_FORNECE, COUNT(C8_FORNECE) AS QUANT FROM "+RetSqlName("SC8")+" SC8 WHERE C8_PRODUTO = '"+Alltrim(SB1->B1_COD)+"' AND C8_NUM = '"+cNumCot+"' AND D_E_L_E_T_ = '' "
					cQuery += "GROUP BY C8_PRODUTO, C8_FORNECE) AS WWW GROUP BY C8_PRODUTO ORDER BY C8_PRODUTO"
					If chkfile("_SC8")
						dbSelectArea("_SC8")
						dbCloseArea()
					EndIf
					TCQUERY cQuery ALIAS "_SC8" NEW
					IF _SC8->QUANT < 3
						MSGBOX("O produto "+SB1->B1_COD+" deverá ter pelo menos três cotações A CADA COMPRA pois o produto está cadastrado como NORMAL => Deve possuir três cotações a cada compra.","STOP")
						//lAprovacao := .F.
					ENDIF
					CASE !SB1->B1_YTPCOT $ "A_B_C"
					MSGBOX("Favor informar o tipo de cotação para o produto "+Alltrim(SB1->B1_COD)+" no cadastro do produto.","STOP")
					//lAprovacao := .F.
				ENDCASE
				_SC8->(DbCloseArea())			
			ENDIF
		EndIf
	Next

	//TELA DE APROVACAO VIA LOGIN E SENHA
	//If !lAprovacao
	//nRet := u_BIA181()
	//EndIf

	If nRet
		//Posiciona na tabela de Fornecedor/Loja
		cQuery := ""
		cQuery += "SELECT * FROM SA2010 WHERE A2_COD = '"+CA120FORN+"' AND A2_LOJA = '"+CA120LOJ+"' AND D_E_L_E_T_ = '' "
		If chkfile("_SA2")
			dbSelectArea("_SA2")
			dbCloseArea()
		EndIf
		TCQUERY cQuery ALIAS "_SA2" NEW

		//Posiciona na tabela de Natureza Financeira
		DbSelectArea("SED")
		DbSetOrder(1)
		If DbSeek(xFilial("SED")+_SA2->A2_NATUREZ,.T.)
			IF SED->ED_MSBLQL == '1'
				nRet := .F.
				MSGBOX("A Natureza Financeira '"+Alltrim(_SA2->A2_NATUREZ)+"', deste Fornecedor está bloqueada. O Pedido de Compras não será salvo. Favor revisá-la antes de prosseguir!","STOP")
			ENDIF
		EndIf

		IF ALLTRIM(_SA2->A2_TIPO) <> "X"
			IF EMPTY(_SA2->A2_COD_MUN)
				nRet := .F.
				MSGBOX("Favor preencher o Código do Município no Cadastro de Fornecedores. O Pedido de Compras não será salvo. Importante: observar também o campo TIPO no cadastro de fornecedor, que para os casos de importação deverá ser X-Outros","STOP")
			ENDIF
		ENDIF

		IF NMOEDAPED = 0
			nRet := .F.
			MSGBOX("A Moeda deste pedido não foi informada. O Pedido de Compras não será salvo.","STOP")
		ENDIF		

	EndIf

	//(Thiago Dantas - 16/09/14) -> [OS 0281-14]
	If Inclui .And. nRet .And. nVlrTotal >= 10000.00

		dbSelectArea("SC1")
		DbSetOrder(1)

		If(DbSeek(xFilial("SC1")+cNumSc,.T.))

			// Notifica o aprovador da Solic.
			If SC1->C1_YCODAPV == '000244' // se for o ELAERCIO
				NotifAprv(SC1->C1_YCODAPV)
			EndIf

		EndIf

		SC1->(dbCloseArea())

	EndIf

Return(nRet)

//-------------------------------------------------------------------------------------
//   FUNÇÕES RELACIONADAS A NOTICIFICAÇÃO DO APROVADOR DA SC -> (NotifAprv)
//-------------------------------------------------------------------------------------
Static Function NotifAprv(cCodAprov)

	Local cMailAprov := ''
	Local cMsgMail	 := ''

	CsqlApv := " SELECT ZZ4_EMAIL
	CsqlApv += " FROM "+ RetSqlName("ZZ4")
	CsqlApv += " WHERE ZZ4_COD = '"+cCodAprov+"' "
	CsqlApv += " AND D_E_L_E_T_ = '' "

	If chkfile("_ZZ4")
		dbSelectArea("_ZZ4")
		dbCloseArea()
	EndIf
	TCQUERY CsqlApv ALIAS "_ZZ4" NEW
	dbSelectArea("_ZZ4")

	If lDebug
		cMailAprov := 'wanisay.william@biancogres.com.br'
	Else
		cMailAprov := _ZZ4->ZZ4_EMAIL 
	EndIf

	_ZZ4->(DbCloseArea())

	If !Empty(cMailAprov)
		cMsgMail := GeraMailSC()
	  					  		
		cRecebe   	:= cMailAprov														 		
		cRecebeCC	:= ''  												 			
		cRecebeCO	:= ''			  								 					
		cAssunto	:= 'Pedido de Compra - Análise de Gastos'

		cMensag := " Seguem os dados do Pedido de Compra "+CA120NUM+"."+ CHR(13)+CHR(10)
		cMensag += cMsgMail
		cArqAnexo := ''

		U_BIAEnvMail(,cRecebe,cAssunto,cMensag,'',cArqAnexo,,cRecebeCC) 
	EndIf

Return

//------------------------------------------------------------------------------------- 
Static Function GeraMailSC()

	Local xn
	Private C_HTML := ''
	Private nPosItem, nPosProd, nPosDesc, nPosQtd, nPosUni, nPosPreco := 0

	// posicao no ACOLS
	nPosItem	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_ITEM'		})
	nPosDesc	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_DESCRI'	})
	nPosQtd		:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_QUANT'		}) 
	nPosUni		:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_UM'		})
	nPosPreco 	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_PRECO'		})
	nPosSC 		:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C7_NUMSC'		})

	GeraCab()
	GeraCabCls()

	For xn := 1 to Len(acols)
		GeraItmTb()	
	Next

	GeraTotItm()
	GeraFtrFim()

Return C_HTML

//---------------------------------------(GeraCab)-------------------------------------
Static Function GeraCab()
	C_HTML := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	C_HTML += '   <html xmlns="http://www.w3.org/1999/xhtml">
	C_HTML += '      <head>
	C_HTML += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	C_HTML += '         <title>Estoque</title>
	C_HTML += '         <style type="text/css">
	C_HTML += '			<!--
	C_HTML += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	C_HTML += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	C_HTML += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	C_HTML += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif } 			
	C_HTML += '			--> 
	C_HTML += '         </style>
	C_HTML += '      </head>
	C_HTML += '      <body>

Return

//---------------------------------------(GeraCabCls)----------------------------------
Static Function GeraCabCls()
	C_HTML += '         <table align="center" width="800" class = "headProd"> '
	C_HTML += '               <tr> '
	C_HTML += '                  <div align="left"> '
	C_HTML += "                  <th width='694' scope='col'> SC - Análise de Gastos</th> '
	C_HTML += '					 </div> '
	C_HTML += '               </tr> '
	C_HTML += '         </table> '
	C_HTML += '         <table align="center" width="800" border="1" cellspacing="0" cellpadding="1"> '
	C_HTML += '            <tr align=center> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> SC </span></th> '
	C_HTML += '               <th class = "cabtab" width="30" scope="col"> ITEM </span></th> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> PRODUTO </span></th> '
	C_HTML += '               <th class = "cabtab" width="100" scope="col"> DESCRICAO </span></th> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col" > QTD </span></th> '
	C_HTML += '               <th class = "cabtab" width="30" scope="col"> UNIDADE </span></th> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> PRECO </span></th> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> TOTAL </span></th> '
	C_HTML += '            </tr> '

Return

//---------------------------------------(GeraItmTb)----------------------------------
Static Function GeraItmTb()

	C_HTML += " 			<tr align=center>
	C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(aCols[xn,nPosSC])			+"</td>
	C_HTML += "                   <td class='style12' width='30'scope='col'>"+ALLTRIM(aCols[xn,nPosItem])		+"</td>
	C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(aCols[xn,nPosProduto])	+"</td>
	C_HTML += "                   <td class='style12' width='100'scope='col'>"+ALLTRIM(aCols[xn,nPosDesc])		+"</td>
	C_HTML += " 				  <td class='style12' width='50'scope='col'>"+TRANSFORM((aCols[xn,nPosQtd]),"@E 9,999,999.99") 			+"</td>
	C_HTML += "                   <td class='style12' width='30'scope='col'>"+ALLTRIM(aCols[xn,nPosUni])								+"</td>
	C_HTML += "                   <td class='style12' width='50'scope='col'>"+TRANSFORM((aCols[xn,nPosPreco]),"@E 9,999,999.99") 		+"</td>
	C_HTML += "                   <td class='style12' width='50'scope='col'>"+TRANSFORM((aCols[xn,nPosTotal]),"@E 9,999,999.99")  		+"</td>
	C_HTML += "             </tr>

Return

//---------------------------------------(GeraTotItm)----------------------------------
Static Function GeraTotItm()

	C_HTML += "		</table> "
	C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'> "
	C_HTML += "            <tr align=center> "
	C_HTML += "               <th class = 'tottab' width='545' scope='col'> Total </span></th> "
	C_HTML += "               <th class = 'tottab' width='40' scope='col'> "+ TRANSFORM(nVlrTotal,"@E 9,999,999.99") +" </span></th> "
	C_HTML += "			</tr>   "
	C_HTML += "		</table> "

Return

//---------------------------------------(GeraFooter)----------------------------------
Static Function GeraFooter()

	C_HTML +="	<div id='psdg-footer'> &nbsp </div>"

Return

//---------------------------------------(GeraFtrFim)----------------------------------
Static Function GeraFtrFim()

	C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'> "
	C_HTML += "            <tr> "
	C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by MT120).</th> "
	C_HTML += "			</tr> "  
	C_HTML += "		</table> "
	C_HTML += "      </body> "
	C_HTML += "   </html> "

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BValTpForX9 ¦ Autor ¦ Marcos Alberto S.  ¦ Data ¦ 22.02.17 ¦¦¦
¦¦¦----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ ValidUser para o campo W2_FORN                             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BValTpForX9()

	Local ksRetChk := .T.
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2") + M->W2_FORN ))

		If Alltrim(SA2->A2_TIPO) == "X"

			IF !Empty(SA2->A2_COD_MUN)

				MSGBOX("Importante: favor observar o campo TIPO no cadastro de fornecedor, que para os casos de importação deverá ser X-Outros", "STOP")
				ksRetChk := .F.

			EndIf

		Else

			MSGBOX("Importante: não é permitido incluir PO para fornecedores nacionais. Favor observar o campo TIPO no cadastro de fornecedor!!!", "STOP")
			ksRetChk := .F.

		EndIf

	EndIf

Return ( ksRetChk )
