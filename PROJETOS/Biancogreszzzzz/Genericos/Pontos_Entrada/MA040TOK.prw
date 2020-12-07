#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ MA040TOK       ºAUTOR  ³BRUNO MADALENO      º DATA ³  08/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ VALIDACAO DO CADASTRO DE VENDEDOR                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ AP 8 R4                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION MA040TOK()
	local  i
	Local aEmp := StrTokArr( Alltrim(M->A3_YEMP), "/" ) 
	PRIVATE ENTER := CHR(13)+CHR(10)

	IF EMPTY(M->A3_YEMP)
		ALERT("O CAMPO EMPRESA GMR DEVERÁ SER INFORMADO PARA REALIZAR A ALTERAÇÃO!")
		Return(.F.)
	END IF

	//Valida campo EMPRESA GMR no cadastro de Cliente
	For i := 1 To Len(aEmp)
		If Len(aEmp[i]) <> 4 .Or. !aEmp[i] $ "XXXX_0101_0199_0501_0599_1399_1401_1302"  
			ALERT("Favor corrigir o campo Empresa GMR. Estes são os valores aceitos XXXX/0101/0199/0501/0599/1399/1401/1302.")
			Return(.F.)
		EndIf
	Next i       


	If M->A3_MSBLQL == "1" .And. !Alltrim(M->A3_YEMP) $ "XXXX"	
		If MsgYesNo("Para Representantes com cadastro bloqueado, o campo EMPRESA deverá ser preencido com XXXX. Deseja ajustar o campo antes de continuar? ")
			Return(.F.)	
		EndIf
	EndIf

	//VALIDANDO A COMISSAO DO REPRESENTANTE COM O CLIENTE
	//Validação para Biancogres
	IF ALLTRIM(M->A3_YEMP) $ "0101"
		CC_VEND  := M->A3_COD
		CC_COM	 := STRTRAN(ALLTRIM(STR(M->A3_COMIS)),",",".")	

		//Valida Cliente
		CSQL := "SELECT A1_VEND " + ENTER
		CSQL += "FROM "+RETSQLNAME("SA1")+" " + ENTER
		CSQL += "WHERE	" + ENTER
		CSQL += "   ((A1_VEND 	= '"+CC_VEND+"' AND A1_COMIS  > '"+CC_COM+"') OR  	" + ENTER
		CSQL += "	(A1_YVENDB2 = '"+CC_VEND+"' AND A1_YCOMB2 > '"+CC_COM+"') OR	" + ENTER
		CSQL += "	(A1_YVENDB3 = '"+CC_VEND+"' AND A1_YCOMB3 > '"+CC_COM+"')) 		" + ENTER
		CSQL += "	AND D_E_L_E_T_ = '' " + ENTER	
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW	
		IF ! _COMIS->(EOF())
			MsgBox("Comissão no Representante, MENOR que o informado no Cadastro de Clientes!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MAIOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5010		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' AND 						" + ENTER
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6010 SC6 , SF4010 SF4  		" + ENTER
		CSQL += "					WHERE	C6_FILIAL = '"+xFilial("SC6")+"' AND  	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 AND  			" + ENTER
		CSQL += "							C6_TES	= F4_CODIGO  AND " + ENTER
		CSQL += "							F4_DUPLIC = 'S' 	 AND " + ENTER
		CSQL += "							C6_BLQ <> 'R' 		 AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = ''  AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "   	C5_CLIENTE <> '010064' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND        " + ENTER
		CSQL += "	   ((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))    " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da Biancogres!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MAIOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5070		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' 	AND 					" + ENTER
		CSQL += "		C5_YLINHA = '1' 					AND     				" + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6070 SC6 , SF4070 SF4  		" + ENTER
		CSQL += "					WHERE	C6_FILIAL 	= '"+xFilial("SC6")+"'	AND	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 			AND " + ENTER
		CSQL += "							C6_TES		= F4_CODIGO  			AND " + ENTER
		CSQL += "							F4_DUPLIC 	= 'S' 	 AND " + ENTER
		CSQL += "							C6_BLQ 		<> 'R' 	 AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = ''  AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND        " + ENTER
		CSQL += "	   ((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))    " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da LM!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

	ENDIF

	//Validação para Incesa
	IF ALLTRIM(M->A3_YEMP) $ "0501"
		CC_VEND := M->A3_COD
		CC_COM  := STRTRAN(ALLTRIM(STR(M->A3_YCOMISI)),",",".")    

		CSQL := "SELECT A1_VEND " + ENTER
		CSQL += "FROM "+RETSQLNAME("SA1")+" " + ENTER
		CSQL += "WHERE	" + ENTER
		CSQL += "   	((A1_YVENDI	= '"+CC_VEND+"' AND A1_YCOMISI > '"+CC_COM+"') OR  	" + ENTER
		CSQL += "		(A1_YVENDI2 = '"+CC_VEND+"' AND A1_YCOMI2  > '"+CC_COM+"') OR	" + ENTER
		CSQL += "		(A1_YVENDI3 = '"+CC_VEND+"' AND A1_YCOMI3  > '"+CC_COM+"'))		" + ENTER
		CSQL += "		AND D_E_L_E_T_ = '' " + ENTER	
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW	
		IF ! _COMIS->(EOF())
			MsgBox("Comissão no Representante, MENOR que o informado no Cadastro de Clientes!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MENOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE	" + ENTER
		CSQL += "FROM SC5050		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"'	AND " + ENTER
		CSQL += "		C5_YLINHA = '2' 					AND " + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6050 SC6, SF4050 SF4  " + ENTER
		CSQL += "					WHERE	C6_FILIAL = '"+xFilial("SC6")+"' AND  " + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 AND  " + ENTER
		CSQL += "							C6_TES	= F4_CODIGO AND " + ENTER
		CSQL += "							F4_DUPLIC = 'S' AND " + ENTER
		CSQL += "							C6_BLQ <> 'R' AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "   	C5_CLIENTE <> '010064' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "		((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+")  OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+")  OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+")  OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))  " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da Incesa!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MAIOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5070		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' 	AND 					" + ENTER
		CSQL += "		C5_YLINHA = '2' 					AND     				" + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6070 SC6 , SF4070 SF4  		" + ENTER
		CSQL += "					WHERE	C6_FILIAL 	= '"+xFilial("SC6")+"'	AND	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 			AND " + ENTER
		CSQL += "							C6_TES		= F4_CODIGO  			AND " + ENTER
		CSQL += "							F4_DUPLIC 	= 'S' 	 AND " + ENTER
		CSQL += "							C6_BLQ 		<> 'R' 	 AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = ''  AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND        " + ENTER
		CSQL += "	   ((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))    " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MAIOR do que lançado nos Pedidos de Venda da LM!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

	ENDIF

	//Validação para Bellacasa
	IF ALLTRIM(M->A3_YEMP) $ "0599"
		CC_VEND := M->A3_COD
		CC_COM  := STRTRAN(ALLTRIM(STR(M->A3_YCOMIBE)),",",".")

		CSQL := "SELECT A1_VEND " + ENTER
		CSQL += "FROM "+RETSQLNAME("SA1")+" " + ENTER
		CSQL += "WHERE	" + ENTER
		CSQL += "      ((A1_YVENBE1 = '"+CC_VEND+"' AND A1_YCOMBE1 > '"+CC_COM+"') OR  	" + ENTER
		CSQL += "		(A1_YVENBE2 = '"+CC_VEND+"' AND A1_YCOMBE2 > '"+CC_COM+"') OR	" + ENTER
		CSQL += "		(A1_YVENBE3 = '"+CC_VEND+"' AND A1_YCOMBE3 > '"+CC_COM+"'))		" + ENTER
		CSQL += "		AND D_E_L_E_T_ = '' " + ENTER	
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW	
		IF ! _COMIS->(EOF())
			MsgBox("Comissão no Representante, MENOR que o informado no Cadastro de Clientes!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MENOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5050		 " + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' 	AND " + ENTER
		CSQL += "		C5_YLINHA = '3' 					AND " + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6050 SC6 , SF4050 SF4		" + ENTER
		CSQL += "					WHERE	C6_FILIAL = '"+xFilial("SC5")+"' AND	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 AND  			" + ENTER
		CSQL += "							C6_TES	= F4_CODIGO AND 				" + ENTER
		CSQL += "							F4_DUPLIC = 'S' AND 					" + ENTER
		CSQL += "							C6_BLQ <> 'R' AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "   	C5_CLIENTE <> '010064' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "		((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+")  OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+")  OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+")  OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))  " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da Bellacasa!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MAIOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5070		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' 	AND 					" + ENTER
		CSQL += "		C5_YLINHA = '3' 					AND     				" + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6070 SC6 , SF4070 SF4  		" + ENTER
		CSQL += "					WHERE	C6_FILIAL 	= '"+xFilial("SC6")+"'	AND	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 			AND " + ENTER
		CSQL += "							C6_TES		= F4_CODIGO  			AND " + ENTER
		CSQL += "							F4_DUPLIC 	= 'S' 	 AND " + ENTER
		CSQL += "							C6_BLQ 		<> 'R' 	 AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = ''  AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND        " + ENTER
		CSQL += "	   ((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))    " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da LM!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

	ENDIF

	//Validação para Mundialli
	IF ALLTRIM(M->A3_YEMP) $ "1399"
		CC_VEND := M->A3_COD
		If M->(FieldPos("A3_YCOMIML")) > 0
			CC_COM  := STRTRAN(ALLTRIM(STR(M->A3_YCOMIML)),",",".")
		EndIf

		CSQL := "SELECT A1_VEND " + ENTER
		CSQL += "FROM "+RETSQLNAME("SA1")+" " + ENTER
		CSQL += "WHERE	" + ENTER
		CSQL += "      ((A1_YVENML1 = '"+CC_VEND+"' AND A1_YCOMML1 > '"+CC_COM+"')  OR  " + ENTER
		CSQL += "		(A1_YVENML2 = '"+CC_VEND+"' AND A1_YCOMML2 > '"+CC_COM+"')  OR	" + ENTER
		CSQL += "		(A1_YVENML3 = '"+CC_VEND+"' AND A1_YCOMML3 > '"+CC_COM+"')) OR	" + ENTER
		CSQL += "		AND D_E_L_E_T_ = '' " + ENTER	
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW	
		IF ! _COMIS->(EOF())
			MsgBox("Comissão no Representante, MENOR que o informado no Cadastro de Clientes!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MAIOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5070		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' 	AND 					" + ENTER
		CSQL += "		C5_YLINHA = '4' 					AND     				" + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6070 SC6 , SF4070 SF4  		" + ENTER
		CSQL += "					WHERE	C6_FILIAL 	= '"+xFilial("SC6")+"'	AND	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 			AND " + ENTER
		CSQL += "							C6_TES		= F4_CODIGO  			AND " + ENTER
		CSQL += "							F4_DUPLIC 	= 'S' 	 AND " + ENTER
		CSQL += "							C6_BLQ 		<> 'R' 	 AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = ''  AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND        " + ENTER
		CSQL += "	   ((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))    " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da LM!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

	ENDIF

	//Validação para Vitcer
	IF ALLTRIM(M->A3_YEMP) $ "1401"
		CC_VEND := M->A3_COD
		CC_COM  := STRTRAN(ALLTRIM(STR(M->A3_YCOMIVT)),",",".")
		CSQL := "SELECT A1_VEND " + ENTER
		CSQL += "FROM "+RETSQLNAME("SA1")+" " + ENTER
		CSQL += "WHERE	" + ENTER
		CSQL += "     (	(A1_YVENVT1 = '"+CC_VEND+"' AND A1_YCOMVT1 > '"+CC_COM+"')	OR  " + ENTER
		CSQL += "		(A1_YVENVT2 = '"+CC_VEND+"' AND A1_YCOMVT2 > '"+CC_COM+"') 	OR	" + ENTER
		CSQL += "		(A1_YVENVT3 = '"+CC_VEND+"' AND A1_YCOMVT3 > '"+CC_COM+"') ) 	" + ENTER
		CSQL += "		AND D_E_L_E_T_ = '' " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW

		IF ! _COMIS->(EOF())
			ALERT("COMISSÃO NO REPRESENTANTE MENOR DO QUE NO CLIENTE")
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MAIOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5140		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' 	AND 					" + ENTER
		CSQL += "		C5_YLINHA = '1' 					AND     				" + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6140 SC6 , SF4140 SF4  		" + ENTER
		CSQL += "					WHERE	C6_FILIAL 	= '"+xFilial("SC6")+"'	AND	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 			AND " + ENTER
		CSQL += "							C6_TES		= F4_CODIGO  			AND " + ENTER
		CSQL += "							F4_DUPLIC 	= 'S' 	 AND " + ENTER
		CSQL += "							C6_BLQ 		<> 'R' 	 AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = ''  AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND        " + ENTER
		CSQL += "	   ((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))    " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da Vitcer!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

	ENDIF

	//Validação para Pegasus
	IF ALLTRIM(M->A3_YEMP) $ "0199"
		CC_VEND := M->A3_COD
		//CC_COM  := STRTRAN(ALLTRIM(STR(M->A1_YCOMPEG)),",",".")
		CC_COM  := STRTRAN(ALLTRIM(STR(M->A3_YCOMPEG)),",",".") //Thiago Haagensen - Ticket 23066 - Fazendo referencia a tabela SA1 e não encontrando o valor esperado.

		CSQL := "SELECT A1_VEND " + ENTER
		CSQL += "FROM "+RETSQLNAME("SA1")+" " + ENTER
		CSQL += "WHERE	" + ENTER
		CSQL += "   	A1_YVENPEG	= '"+CC_VEND+"' AND A1_YCOMPEG > '"+CC_COM+"'  " + ENTER
		CSQL += "		AND D_E_L_E_T_ = '' " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW

		IF ! _COMIS->(EOF())
			ALERT("COMISSÃO NO REPRESENTANTE MENOR DO QUE NO CLIENTE")
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MAIOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5070		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' 	AND 					" + ENTER
		CSQL += "		C5_YLINHA = '5' 					AND     				" + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6070 SC6 , SF4070 SF4  		" + ENTER
		CSQL += "					WHERE	C6_FILIAL 	= '"+xFilial("SC6")+"'	AND	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 			AND " + ENTER
		CSQL += "							C6_TES		= F4_CODIGO  			AND " + ENTER
		CSQL += "							F4_DUPLIC 	= 'S' 	 AND " + ENTER
		CSQL += "							C6_BLQ 		<> 'R' 	 AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = ''  AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND        " + ENTER
		CSQL += "	   ((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))    " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da Marca PEGASUS!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

	ENDIF
	
	//Validação para Vinilico
	IF ALLTRIM(M->A3_YEMP) $ "1302"
		CC_VEND := M->A3_COD
		//CC_COM  := STRTRAN(ALLTRIM(STR(M->A1_YCOMVI1)),",",".")
		CC_COM  := STRTRAN(ALLTRIM(STR(M->A3_YCOMVIN)),",",".") //Thiago Haagensen - Ticket 23066 - Fazendo referencia a tabela SA1 e não encontrando o valor esperado. 
		CSQL := "SELECT A1_VEND " + ENTER
		CSQL += "FROM "+RETSQLNAME("SA1")+" " + ENTER
		CSQL += "WHERE	" + ENTER
		CSQL += "   	A1_YVENVI1	= '"+CC_VEND+"' AND A1_YCOMVI1 > '"+CC_COM+"'	" + ENTER
		CSQL += "		AND D_E_L_E_T_ = '' " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW

		IF ! _COMIS->(EOF())
			ALERT("COMISSÃO NO REPRESENTANTE MENOR DO QUE NO CLIENTE")
			Return(.F.)
		END IF

		// VALIDANDO A COMISSAO PARA NAO PERMITIR INFORMAR A COMISSAO DO CLIENTE MAIOR QUE ESTA NO PEDIDO
		CSQL := "SELECT C5_CLIENTE 	" + ENTER
		CSQL += "FROM SC5070		" + ENTER
		CSQL += "WHERE	C5_FILIAL = '"+xFilial("SC5")+"' 	AND 					" + ENTER
		CSQL += "		C5_YLINHA = '6' 					AND     				" + ENTER	
		CSQL += "		C5_NUM IN (SELECT C6_NUM FROM SC6070 SC6 , SF4070 SF4  		" + ENTER
		CSQL += "					WHERE	C6_FILIAL 	= '"+xFilial("SC6")+"'	AND	" + ENTER
		CSQL += "							C6_QTDVEN - C6_QTDENT > 0 			AND " + ENTER
		CSQL += "							C6_TES		= F4_CODIGO  			AND " + ENTER
		CSQL += "							F4_DUPLIC 	= 'S' 	 AND " + ENTER
		CSQL += "							C6_BLQ 		<> 'R' 	 AND " + ENTER
		CSQL += "							SC6.D_E_L_E_T_ = ''  AND " + ENTER
		CSQL += "							SF4.D_E_L_E_T_ = '') AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' AND        " + ENTER
		CSQL += "	   ((C5_VEND1 = '"+CC_VEND+"' AND C5_COMIS1 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND2 = '"+CC_VEND+"' AND C5_COMIS2 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND3 = '"+CC_VEND+"' AND C5_COMIS3 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND4 = '"+CC_VEND+"' AND C5_COMIS4 > "+CC_COM+") OR  " + ENTER
		CSQL += "		(C5_VEND5 = '"+CC_VEND+"' AND C5_COMIS5 > "+CC_COM+"))    " + ENTER
		CSQL += "ORDER BY C5_CLIENTE, C5_VEND1 " + ENTER
		IF CHKFILE("_COMIS")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_COMIS" NEW
		IF ! _COMIS->(EOF())
			MsgBox("Comissão do Representante, está MENOR do que lançado nos Pedidos de Venda da Marca VINILICO!","MA040TOK","STOP")
			DBSELECTAREA("_COMIS")
			DBCLOSEAREA()
			Return(.F.)
		END IF

	ENDIF	

	//(Thiago Dantas - 19/02/15) -> Antes de retornar, verifica se houve alteração do email.
	If (AllTrim(SA3->A3_EMAIL) != AllTrim(M->A3_EMAIL))
		EnviaWfAlt()	
	EndIf

RETURN(.T.)
//---------------------------------------------------------------------------------------
Static Function EnviaWfAlt()
	Local cEmailNovo:= AllTrim(M->A3_EMAIL)
	Local cEmailAnt	:= AllTrim(SA3->A3_EMAIL)
	Local cAssunto	:= 'Notificação de Alteração de Email'
	Local cMensag	:= ''
	Local cArqAnexo := ""
	Local lDebug 	:= .F.
	Local Enter 	:= CHR(13)+CHR(10)
	Local cRecebe   := 'suporte.ti@biancogres.com.br'
	Local nHora		:= val(SubStr(Time(),1,2))

	If nHora >= 0 .And. nHora < 12
		cMensag := "Equipe de TI, bom dia."+Enter+Enter
	ElseIf nHora >= 12 .And. nHora < 18
		cMensag := "Equipe de TI, boa tarde."+Enter+Enter
	Else
		cMensag := "Equipe de TI, boa noite."+Enter+Enter
	EndIf

	cMensag += "O Representante "+AllTrim(SA3->A3_COD)+" - "+AllTrim(SA3->A3_NOME)+" sofreu alteração do seu e-mail no Protheus."+Enter
	cMensag += "Email Anterior: "+cEmailAnt+Enter
	cMensag += "Email Novo    : "+cEmailNovo+Enter+Enter
	cMensag += 'Este e-mail é automático. Não Responda esta mensagem.'

	If lDebug
		cRecebe 	:= 'wanisay.william@biancogres.com.br'
	EndIf

	U_BIAEnvMail(,cRecebe,cAssunto,cMensag,'',cArqAnexo) 
Return 
//---------------------------------------------------------------------------------------
