#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
/* 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
≤±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤
≤±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±≤
≤±±∫Programa  ≥Env_Pedido∫Autor  ≥ MADALENO           ∫ Data ≥  22/10/07   ∫±±≤
≤±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±≤
≤±±∫Desc.     ≥ ENVIA PEDIDO DE VENDA PARA O REPRESENTANTE / CLIENTE       ∫±±≤
≤±±∫          ≥                                                            ∫±±≤
≤±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±≤
≤±±∫Uso       ≥ AP7                                                        ∫±±≤
≤±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±≤
≤±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

USER FUNCTION Env_Pedido(aaNUM_PED,lDigitou,lAtende,cEmpPed,lRpc,lVitcer)
	Local cAliasTmp,TABSC5, EMPORI
	Local cId
	Local I

	Private cDestinatario
	Private CCOPIA
	Private cRef         := ""
	Private cNomeCliente := "" 
	Private c_Cliente    := ""
	Private c_TpSeg		  := ""
	Private cCodVend     := "" //Codigo do vendedor - para atender a casos LM - Fernando - 05/08/2010
	Private nPed_Imp  //Numero do pedido para impressao - para atender a casos LM - Fernando - 05/08/2010

	Private _cPedVit := ""
	Private _lVitcer 

	//lRpc  -> tratar quando chamando via RPC de outra empresa
	Default lRpc := .F. 
	Default lVitcer := .F.

	_lVitcer := lVitcer

	//POSICIONANDO PEDIDO >> PARA TESTE VIA IDE
	//PREPARE ENVIRONMENT EMPRESA AA_EMPRESA FILIAL "01" MODULO "FAT"
	//SC5->(DbSetOrder(1))
	//SC5->(DbSeek(XFilial("SC5")+aaNUM_PED))   

	//ALTERACOES POR FERNANDO EM 05/08/2010 - REFORMULACAO DAS REGRAS QUANTO A ENVIO DE PEDIDO - E REGRAS PARA LM.

	//Fernando/Facile em 30/07 -> achar o pedido certo da LM quando chamando a funcao via RPC de ourtra empresa
	If lRpc

		/*
		__lAchouOri := .F.                                
		SC5->(DbSetOrder(9))
		If SC5->(DbSeek(XFilial("SC5")+aaNUM_PED))
		While !SC5->(Eof()) .And. SC5->(C5_FILIAL+C5_YPEDORI) == (XFilial("SC5")+aaNUM_PED) 

		If AllTrim(SC5->C5_YEMPPED) == AllTrim(cEmpPed)
		__lAchouOri := .T.
		Exit
		Endif

		SC5->(DbSkip())
		EndDo

		If !__lAchouOri
		RETURN
		EndIf
		EndIf
		*/

		//Posiciona no novo Indice C5_YPEDORI + C5_YEMPPED
		SC5->(DbSetOrder(11))
		If !SC5->(DbSeek(xFilial("SC5")+aaNUM_PED+cEmpPed))
			RETURN
		EndIf

	EndIf

	If ( lVitcer )

		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+aaNUM_PED))

			//buscando dados do pedido vitcer
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				SELECT C5_VEND1, C5_CLIENTE, A1_YTPSEG, A1_NOME, C5_NUM from SC5140 SC5, SA1010 SA1 
				where C5_FILIAL = '01' and C5_YEORIBS = %Exp:AllTrim(CEMPANT)+AllTrim(CFILANT)% and C5_YPEDBAS = %Exp:aaNUM_PED%
				and C5_CLIENTE = A1_COD and C5_LOJACLI = A1_LOJA and SC5.D_E_L_E_T_='' and SA1.D_E_L_E_T_=''
			EndSql
			IF (cAliasTmp)->(Eof())
				RETURN
			ELSE
				cCodVend 		:= (cAliasTmp)->C5_VEND1
				c_Cliente 		:= (cAliasTmp)->C5_CLIENTE
				c_TpSeg			:= (cAliasTmp)->A1_YTPSEG
				cNomeCliente 	:= (cAliasTmp)->A1_NOME
				_cPedVit		:= (cAliasTmp)->C5_NUM
				nPed_Imp 		:= aaNUM_PED
			ENDIF 
			(cAliasTmp)->(DbCloseArea())

			
			oGerenteAtendente	:= TGerenteAtendente():New()
			oResult 			:= oGerenteAtendente:GetCliente(SC5->C5_YEMP, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_VEND1)
			cDestinatario		:= oResult:cEmailAten
			
			/*TESTE*/cDestinatario := "camila.alves@biancogres.com.br" //TESTE
			/*TESTE*/CCOPIA := "fernando@facilesistemas.com.br"		 //TESTE

			IF U_CRIA_ARQUIVO(SC5->C5_NUM, cEmpPed)
				CRIA_EMAIL(SC5->C5_NUM)
			ENDIF

		EndIf

		RETURN //Pedido base vitcer termina aqui

	EndIf


	//POSICIONANDO CLIENTE DO PEDIDO   
	SA1->(DbSetOrder(1))
	IF SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

		//SE CLIENTE << LM >>  NAO ENVIA WORKFLOW
		IF SA1->A1_COD == "010064"
			RETURN
		ENDIF

		//SE PEDIDO << LM >>  IMPRIME O NUMERO DO PEDIDO ORIGINAL
		IF (cEmpAnt == "07") .AND. (!Empty(SC5->C5_YPEDORI)) .AND. (!Empty(SC5->C5_YLINHA))
			nPed_Imp := SC5->C5_YPEDORI 
			cCodVend := SC5->C5_VEND1		
			////Buscando a empresa original do pedido
			//	If SC5->C5_YLINHA == "1"
			//		EMPORI	:= "01"
			//	ElseIf SC5->C5_YLINHA == "2"
			//		EMPORI	:= "05"
			//	Else
			//		EMPORI := cEmpAnt
			//	EndIf

			////Buscando o representante do pedido original
			//	TABSC5 := "% SC5"+AllTrim(EMPORI)+"0 %"
			//	cAliasTmp := GetNextAlias()
			//	BeginSql Alias cAliasTmp
			//	SELECT C5_VEND1 FROM %Exp:TABSC5% WHERE C5_FILIAL = '01' AND C5_NUM = %Exp:SC5->C5_YPEDORI% AND %NotDel%
			//	EndSql
			//	IF (cAliasTmp)->(Eof())
			//		RETURN
			//	ELSE
			//		cCodVend := (cAliasTmp)->C5_VEND1
			//	ENDIF 
			//	(cAliasTmp)->(DbCloseArea())
			//	                       
		ELSE                           
			nPed_Imp := SC5->C5_NUM   
			cCodVend := SC5->C5_VEND1
		ENDIF

		cDestinatario  := Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_EMAIL")  			//DESTINATARIO - EMAIL DO REPRESENTANTE
		CCOPIA 		   := ALLTRIM(SA1->A1_EMAIL)											//COPIA - EMAIL DO CLIENTE
		cNomeCliente   := ALLTRIM(SA1->A1_NOME)    										    //NOME DO CLIENTE PARA IMPRESSAO
		c_Cliente	   := SA1->A1_COD														//CODIGO DO CLIENTE PARA IMPRESSAO

		//RUBENS JUNIOR (FACILE SISTEMAS)
		//ENVIAR TAMBEM PARA QUEM DIGITOU (ATENDENTE)	 
		If lDigitou 
			cId := GetId(SC5->C5_YDIGP)		//RETORNAR ID DO USUARIO		
			If Empty(CCOPIA) 
				CCOPIA := Alltrim(UsrRetMail(cId))	
			Else
				CCOPIA += ";" + Alltrim(UsrRetMail(cId))	
			EndIf
		EndIf

		//Envia e-mail para Atendente
		If lAtende 
			
			oGerenteAtendente	:= TGerenteAtendente():New()
			oResult 			:= oGerenteAtendente:GetCliente(SC5->C5_YEMP, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_VEND1)
			If Empty(CCOPIA) 
				CCOPIA := oResult:cEmailAten
			Else
				CCOPIA += ";" + oResult:cEmailAten
			EndIf
			
			
		EndIf


		IF U_CRIA_ARQUIVO(SC5->C5_NUM, cEmpPed)

			// Cria titulo provisorio referente a pagamento antecipado.
			U_BIAF017(SC5->C5_NUM)

			CRIA_EMAIL(SC5->C5_NUM)

		ENDIF

	ENDIF    

	_AUX_PEDIDO->(DbCloseArea())
RETURN

// User Function TESTEENVPED()

// 	RpcSetEnv('07', '01')
// 	//pedido LM: LG1890
// 	//pedido origme Bianco: BJ8274
// 	//na duvida consultar sl_helpindex SC5070 no banco de dados
	
// 	U_Env_Pedido("BJ8274",.F., .F.,'01',.T.,.F.)
	
// 	// SC5->(DbSetOrder(11))
// 	// If !SC5->(DbSeek(xFilial("SC5")+"BJ8274"+'01'))
// 	// 	RETURN
// 	// EndIf

// 	// nPed_Imp := SC5->C5_YPEDORI 
// 	// cCodVend := SC5->C5_VEND1	

// 	// IF U_CRIA_ARQUIVO(SC5->C5_NUM, '01')
// 	// 	CRIA_EMAIL(SC5->C5_NUM)
// 	// ENDIF

// 	RpcClearEnv()

// Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CRIA_EMAIL     ∫Autor  ≥BRUNO MADALENO      ∫ Data ≥  20/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ROTINA PARA O ECONTEUDO DO EMAIL                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC Function CRIA_EMAIL() 
	local A_empresa   
	Local cContato 
	Local cMailContato 
	Local nCount := 1 
	Local I


	If cempant == "01"
		A_empresa	 := "Biancogres Ceramica SA"
		cContato     := UPPER('Claudeir Fadini')	            
		cMailContato := UPPER('claudeir.fadini@biancogres.com.br')
	elseIf cempant == "05"
		A_empresa	 := "Incesa Revestimento Ceramico Ltda"
		cContato     := UPPER('Luismar AntÙnio Lucchini')	            
		cMailContato := UPPER('luismar.lucchini@biancogres.com.br')
	elseIf cempant == "07"
		A_empresa	 := "Lm Comercio Atacadista de Material de Construcao Ltda"
		IF SC5->C5_YLINHA $ "1_5"
			cContato     := UPPER('Claudeir Fadini')	            
			cMailContato := UPPER('claudeir.fadini@biancogres.com.br')
		ELSE
			cContato     := UPPER('Luismar AntÙnio Lucchini')	            
			cMailContato := UPPER('luismar.lucchini@biancogres.com.br')
		ENDIF
	end if

	cData     := DTOC(DDATABASE)
	//cTitulo   := "Pedido de Venda N˙mero: " + nPed_Imp + " - Cliente " + cNomeCliente
	cTitulo   := 'Pedido de Venda Num: '+(SC5->C5_NUM)

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
	//C_HTML += '<table width="900" border="0" > '
	C_HTML += '  <tr> '                                        
	//C_HTML += '<font color="black"> '
	// C_HTML += '<font color="white"> '

	DO CASE
		CASE cEmpAnt = "01"
		C_HTML += '  <th scope="col"><div align="center" style="color:white">PEDIDO DE VENDA NA EMPRESA BIANCOGRES - '+(SC5->C5_NUM)+IIF(_lVitcer,' - PARA ATENDER PEDIDO RODAP… DA VITCER No:'+_cPedVit,'')+'<br>'			
		CASE cEmpAnt = "05"   
		C_HTML += '  <th scope="col"><div align="center" style="color:white">PEDIDO DE VENDA NA EMPRESA INCESA - '+(SC5->C5_NUM)+'<br>'			
		OTHERWISE
		C_HTML += '  <th scope="col"><div align="center" style="color:white">PEDIDO DE VENDA - '+(SC5->C5_NUM)+'<br>'			
	ENDCASE                        

	// C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="450" scope="col"> DADOS DA EMPRESA </th> '
	C_HTML += '    <th width="450" scope="col"> DADOS DO PEDIDO </th> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> Raz„o Social do Comprador: <b>'+ UPPER(SM0->M0_NOMECOM) +'</b></td> '

	If cEmpAnt == '07' .And. !Empty(SC5->C5_YPEDORI)
		C_HTML += '    <td><div align="left"> N˙mero do Pedido:: <b>'+ SC5->C5_NUM +'</b>  Pedido Original:: <b>'+AllTrim(SC5->C5_YPEDORI)+'</b></td> '  
	Else
		C_HTML += '    <td><div align="left"> N˙mero do Pedido:: <b>'+ SC5->C5_NUM +'</b></td> '  
	EndIf

	C_HTML += '  </tr> '
	C_HTML += '<tr> '             
	C_HTML += '    <td><div align="left"> CNPJ: <b>' + TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") +'</b></td> '
	C_HTML += '    <td><div align="left"> Data: '+ SUBSTR( DTOS(SC5->C5_EMISSAO),7,2)+"/"+SUBSTR( DTOS(SC5->C5_EMISSAO),5,2)+"/"+SUBSTR( DTOS(SC5->C5_EMISSAO),1,4) +'</td> '                      
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> EndereÁo: <b>' + SM0->M0_ENDCOB +'</b></td> '
	C_HTML += '    <td><div align="left"> CÛdigo Representante: <b>' + Alltrim(SC5->C5_VEND1) +'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> MunicÌpio: <b>' + SM0->M0_CIDCOB +'</b></td> '
	C_HTML += '    <td><div align="left"> Cond. Pagamento: <b>' + Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI") +'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> Estado: <b>' + SM0->M0_ESTCOB +'</b></td> '
	C_HTML += '    <td><div align="left"> Nome Representante: <b> '+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NREDUZ")+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> CEP: <b>' + SM0->M0_CEPCOB +'</b></td> '
	C_HTML += '    <td><div align="left"> Forma de Pagamento: <b> '+IIF(SC5->C5_YFORMA=="1","BANCO",IIF(SC5->C5_YFORMA=="2","CHEQUE","OP"))+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> PaÌs: <b>BRASIL</b></td> '
	C_HTML += '  </tr> '
	//C_HTML += '<tr> '
	//C_HTML += '    <td><div align="left"> Nome do Contato: <b>'+cContato+'</b></td> '
	//C_HTML += '  </tr> '
	//C_HTML += '<tr> '
	//C_HTML += '    <td><div align="left"> E-mail do Contato: <b>'+cMailContato+'</b></td> '
	//C_HTML += '  </tr> '                                                                           
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> Telefone de Contato: <b>'+SM0->M0_TEL+'</b></td> '
	C_HTML += '  </tr> '

	C_HTML += '</font>'        
	C_HTML += '</table> '    

	C_HTML += '<BR>'      

	//DADOS DO CLIENTE	
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                        
	// C_HTML += '<font color="white"> '		
	// C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col"> DADOS DO CLIENTE:  </th> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '        

	C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2" style="color:black"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> CLIENTE: <b>'+Alltrim(SA1->A1_NOME)+'</b></td> '
	C_HTML += '    <td><div align="left"> C”DIGO: <b>'+Alltrim(SA1->A1_COD)+'</b></td> '
	C_HTML += '    <td><div align="left"> Cliente Ped. Compra: <b>' + Alltrim(SC5->C5_YPC) + '</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> ENDERE«O: <b>'+Alltrim(SA1->A1_END)+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> BAIRRO: <b>'+Alltrim(SA1->A1_BAIRRO)+'</b></td> '
	C_HTML += '    <td><div align="left"> CIDADE: <b>'+Alltrim(SA1->A1_MUN)+'</b></td> '
	C_HTML += '    <td><div align="left"> UF: <b>'+Alltrim(SA1->A1_EST)+'</b></td> '
	C_HTML += '  </tr> ' 
	C_HTML += '<tr> '
	If(Alltrim(SA1->A1_PESSOA)=='J')
		C_HTML += '    <td><div align="left"> CNPJ: <b>' + TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99") +'</b></td> '
		If !Empty(SA1->A1_INSCR)
			C_HTML += '    <td><div align="left"> I.E.: <b>' + SA1->A1_INSCR +'</b></td> '
		EndIf                                                                            
	Else
		C_HTML += '    <td><div align="left"> CPF: <b>' + TRANSFORM(SA1->A1_CGC,"@R 999.999.999-99") +'</b></td> '
	EndIf           
	C_HTML += '    <td><div align="left"> CEP: <b>' + SA1->A1_CEP +'</b></td> '             
	C_HTML += '  </tr> ' 
	C_HTML += '  <tr> ' 
	C_HTML += '    <td><div align="left"> COMPRADOR: <b>' + Alltrim(SA1->A1_CONTATO) +'</b></td> '
	C_HTML += '    <td><div align="left"> TELEFONE: <b>' + SA1->A1_TEL +'</b></td> '
	C_HTML += '    <td><div align="left"> FAX: <b>' + SA1->A1_FAX +'</b></td> '
	C_HTML += '  </tr> ' 
	C_HTML += '  <tr> ' 
	C_HTML += '    <td><div align="left"> E-MAIL: <b>' + Alltrim(SA1->A1_EMAIL) +'</b></td> '
	C_HTML += '    <td><div align="left"> TRANSPORTADORA: <b>' + Alltrim(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME")) +'</b></td> '
	C_HTML += '  </tr> ' 

	C_HTML += '</font>'        
	C_HTML += '</table> '   

	C_HTML += '<BR>'      	

	//CABECALHO DOS ITENS DO PEDIDO 
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                        
	// C_HTML += '<font color="white"> '		
	// C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> ' 

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col">ITENS DO PEDIDO DE VENDA </th> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '  
	//CABECALHO COLUNAS - ITENS
	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" style="color:black"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> ' 	
	C_HTML += '    <th width="20" scope="col"> ITEM </th> '   
	//C_HTML += '    <th width="50" scope="col"> QUANTIDADE </span></th> '  
	C_HTML += '    <th width="50" scope="col"> QUANT. </th> '
	//C_HTML += '    <th width="200" scope="col"> DESCRI«√O </span></th> '
	C_HTML += '    <th width="200" scope="col"> PRODUTO </th> '    
	//C_HTML += '    <th width="20" scope="col"> ENTREGA </span></th> '
	C_HTML += '    <th width="20" scope="col"> PREV DISPONI </th> '                
	//C_HTML += '    <th width="40" scope="col"> IPI </span></th> '    
	C_HTML += '    <th width="40" scope="col"> DT NECES. ENG </th> '    
	C_HTML += '    <th width="40" scope="col"> PRE«O </th> '    
	C_HTML += '    <th width="100" scope="col"> TOTAL </th> '    
	C_HTML += '  </tr> '  
	//C_HTML += '</table> ' 

	_AUX_PEDIDO->(DbGoTop())

	N_DESC_INC		:= 0
	nTOTAL_QUANT 	:= 0
	nTOTAL_TOTAL 	:= 0

	WHILE !_AUX_PEDIDO->(EOF())    

		N_DESC_INC		+= _AUX_PEDIDO->C6_VALDESC
		nTOTAL_QUANT 	+= _AUX_PEDIDO->C6_QTDVEN
		nTOTAL_TOTAL 	+= _AUX_PEDIDO->C6_VALOR + _AUX_PEDIDO->C6_VALDESC

		C_HTML += '  <tr> '   
		C_HTML += '    <td>'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> ' 
		C_HTML += '    <td>'+ TRANSFORM(_AUX_PEDIDO->C6_QTDVEN	,"@E 99,999.99") +'</td> '   
		//(Thiago Dantas - 02/03/15) -> Adicionado campo codigo do produto [OS 0938-15]
		C_HTML += '    <td>'+ Alltrim(_AUX_PEDIDO->C6_PRODUTO)+'-'+Alltrim(_AUX_PEDIDO->B1_DESC) +'</td> '  
		C_HTML += '    <td>'+ SUBSTR(_AUX_PEDIDO->C6_ENTREG,7,2)+"/"+SUBSTR(_AUX_PEDIDO->C6_ENTREG,5,2)+"/"+SUBSTR(_AUX_PEDIDO->C6_ENTREG,1,4) +'</td> '
		C_HTML += '    <td>'+DTOC(STOD(_AUX_PEDIDO->C6_YDTNECE))+'</td> '
		C_HTML += '    <td>'+ Transform(_AUX_PEDIDO->C6_PRUNIT,"@E 999,999.99") +'</td> '
		//C_HTML += '    <td>0%</td> '    
		//C_HTML += '    <td>'+DTOC(STOD(_AUX_PEDIDO->C6_YDTNECE))+'</td> '
		C_HTML += '    <td>'+ Transform(_AUX_PEDIDO->C6_VALOR + _AUX_PEDIDO->C6_VALDESC,"@E 99,999,999.99") +'</td> ' 
		C_HTML += '	</tr> '  

		_AUX_PEDIDO->(DBSKIP())
		nCount ++	                                          
	EndDo      

	TOTAL_COMIPI 	:=  ((nTOTAL_TOTAL+_AUX_PEDIDO->C5_VLRFRET)-N_DESC_INC)

	//TOTALIZADOR
	C_HTML += '  <tr> '   
	C_HTML += '    <td> TOTAL </td> ' 
	C_HTML += '    <td> '+Transform(nTOTAL_QUANT,"@E 999,999.99")+' </td> '
	C_HTML += '    <td>  </td> ' 
	C_HTML += '    <td>  </td> ' 
	C_HTML += '    <td>  </td> ' 
	C_HTML += '    <td>  </td> ' 
	C_HTML += '    <td> '+Transform(nTOTAL_TOTAL,"@E 999,999.99")+' </td> '
	C_HTML += '	</tr> '   

	C_HTML += '</font>'   
	C_HTML += '</table> '  

	_AUX_PEDIDO->(DbGoTop())

	C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" style="color:black"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> ' 	
	C_HTML += '    <th width="800" scope="col"> SEGURO PRODUTO: '+IIF(_AUX_PEDIDO->C5_VLRFRET == 0,'N√O','SIM') +'</th> ' 
	C_HTML += '    <th width="100" scope="col"> '+Transform((_AUX_PEDIDO->C5_VLRFRET*nTOTAL_QUANT),"@E 9,999,999.99") +'</th> '    
	C_HTML += '  </tr> '  
	C_HTML += '  <tr> '  
	C_HTML += '    <th width="800" scope="col"> DESCONCONTO INCONDICIONAL: </th> '  
	C_HTML += '    <th width="100" scope="col"> '+Transform(N_DESC_INC,"@E 9,999,999.99") +'</th> '    
	C_HTML += '  </tr> '  
	C_HTML += '  <tr> '  
	C_HTML += '    <th width="800" scope="col"> TOTAL COM SEGURO E IPI: </th> '  
	//C_HTML += '    <th width="100" scope="col"> '+Transform(TOTAL_COMIPI+(_AUX_PEDIDO->C5_VLRFRET*nTOTAL_QUANT),"@E 9,999,999.99") +'</span></th> '   
	C_HTML += '    <th width="100" scope="col"> '+Transform(TOTAL_COMIPI-N_DESC_INC,"@E 9,999,999.99") +'</th> '   
	C_HTML += '  </tr> '
	C_HTML += '</font>'     
	C_HTML += '</table> ' 

	//INFORMACOES OBRIGATORIAS	
	C_HTML += '<br> '       

	C_HTML += '<BR>' 
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                        
	// C_HTML += '<font color="white"> '

	// C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col"> IMPORTANTE:  </th> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '        

	C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2"> '
	C_HTML += '<font color="black" size="2"> ' 

	If ( !_lVitcer )

		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 1 - Pedido sujeito a an·lise de crÈdito.</td> '
		// C_HTML += '  </tr> '
		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 2 - PreÁo FOB f·brica. Para pedidos sem seguro, o transporte È por conta e risco do cliente.</td> '
		// C_HTML += '  </tr> '
		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 3 - Os produtos a serem retirados na f·brica devem ser agendados com 48 horas de antecedÍncia.</td> '
		// C_HTML += '  </tr> '
		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 4 - Os produtos disponÌveis para embarque que n„o forem retirados no prazo de 14 dias ser„o automaticamente cancelados.</td> '
		// C_HTML += '  </tr> '
		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 5 - PreÁos e condiÁıes sujeitos a confirmaÁ„o. Caso a inflaÁ„o do setor seja superior a 5% entre a digitaÁ„o do pedido e a data prevista de entrega, os preÁos ser„o renegociados. Caso haja alteraÁ„o na legislaÁ„o tribut·ria os preÁos tambÈm dever„o ser reajustados.</td> '
		// C_HTML += '  </tr> '
		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 6 - O volume de cada item constante neste pedido pode sofrer variaÁ„o de 10% para cima ou para baixo.</td> '
		// C_HTML += '  </tr> '
		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 7 - Adquirir aproximadamente 10% a mais do produto para efeitos de reserva tÈcnica (indicado inclusive pela norma a ABNT).</td> '
		// C_HTML += '  </tr> '
		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 8 - Devido a utilizaÁ„o de matÈrias primas naturais que s„o queimadas em altas temperaturas, sÛ poderemos garantir fornecimento com uniformidade de tonalidade e calibre para produtos do mesmo lote. A data de disponibilidade dos produtos poder· sofrer alteraÁ„o na data de entrega pelo mesmo motivo e uma nova data ser·  informada.</td> '
		// C_HTML += '  </tr> '
		// C_HTML += '<tr> '
		// C_HTML += '    <td><div align="left"> 9 - Para construÁıes acima de 1.000 m≤ orientamos realizar o assentamento completo com rejuntamento em 01 (um) apartamento/casa para aprovaÁ„o do produto/lote. Ressaltamos que reclamaÁıes apÛs o assentamento do produto n„o ser„o aceitas.</td> '
		// C_HTML += '  </tr> '

		//Ticket 33102 - alteraÁ„o do texto
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 01 - PreÁos e condiÁıes sujeitos a confirmaÁ„o no momento da implantaÁ„o do pedido.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 02 - Todo pedido È sujeito a an·lise de crÈdito.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 03 - A quantidade de cada item do pedido pode sofrer variaÁ„o de 10% para cima ou para baixo.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 04 - Os preÁos s„o FOB f·brica.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 05 - A previs„o de disponibilidade dos produtos ser· confirmada no momento da implantaÁ„o do pedido no sistema.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 06 - Caso a inflaÁ„o do setor seja superior a 5% entre a digitaÁ„o do pedido e a data prevista de entrega, os preÁos ser„o renegociados.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 07 - Caso haja alteraÁ„o na legislaÁ„o tribut·ria os preÁos ser„o reajustados.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 08 - O fabricante n„o possui responsabilidade sobre o preÁo do frete e da entrega. O valor do frete (R$/t) È uma estimativa do representante comercial junto com o transportador.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 09 - Os produtos disponÌveis para embarque e n„o carregados ser„o automaticamente cancelados.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 10 ñ O carregamento dos produtos na f·brica devem ser agendados com 48 horas de antecedÍncia.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 11 ñ Garantimos uniformidade de tonalidade e calibre para produtos do mesmo lote.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 12 ñ Reserva tÈcnica para obras: sugerimos adquirir 20% a mais de cada produto para todos os formatos.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 13 - Para construÁıes acima de 1.000 m≤, È necess·rio realizar o assentamento de um apartamento ou casa para aprovaÁ„o do produto. Essa operaÁ„o deve ser repetida a cada lote recebido.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 14 ñ Orientamos que independente da metragem adquirida seja realizado o assentamento de uma pequena metragem para avaliaÁ„o e aprovaÁ„o do produto.</td> '
		C_HTML += '  </tr> '
		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 15 ñ Nosso site e embalagens contemplam informaÁıes importantes para o correto manuseio, instalaÁ„o e manutenÁ„o dos nossos produtos. … imperativo seguir todas as orientaÁıes para a qualidade da sua obra e a garantia do seu produto.</td> '
		C_HTML += '  </tr> '

	Else

		C_HTML += '<tr> '
		C_HTML += '    <td><div align="left"> 1 - Pedido exclusivo para atendimento de RodapÈ e n„o pode ser cancelado.</td> '
		C_HTML += '  </tr> '

	EndIf

	//IMPORTANTE - SOMENTE PARA CLIENTES DO TIPO ENGENHARIA
	//RETIRADO A PEDIDO DO CLAUDEIR - 23/09/2015 - OS: 3638-15
	//If(Alltrim(SA1->A1_YTPSEG)=='E')
	//	C_HTML += '<tr> '
	//	C_HTML += '    <td><div align="left"> <u><b> 9 - Por se tratar de produto cer‚mico queimado em altas temperaturas, n„o garantimos o fornecimento de complementos no mesmo padr„o de tonalidade e calibre do pedido anterior, se solicitados apÛs o pedido inicial e fabricado em nova produÁ„o; </b></u>  </td> '
	//	C_HTML += '  </tr> ' 
	//	C_HTML += '<tr> '
	//	C_HTML += '    <td><div align="left"> 10 - Adquirir no mÌnimo 10% a mais do produto para efeitos de reserva tÈcnica (indicado inclusive pela norma da ABNT);  </td> '
	//	C_HTML += '  </tr> ' 
	//	C_HTML += '<tr> '
	//	C_HTML += '    <td><div align="left"> 11 - A responsabilidade pela quantidade especificada e pedida È do respons·vel tÈcnico da obra, que dever· observar critÈrios de compra que garantam a reserva tÈcnica de obra para atender eventuais quebras, perdas e alteraÁıes de projeto.  </td> '
	//	C_HTML += '  </tr> ' 	
	//EndIf

	//C_HTML += '<tr> '
	//C_HTML += '    <td><div align="left"> (*) A disponibilidade de estoque esta sujeita a alteraÁ„o sem prÈvio aviso. </td> '
	//C_HTML += '  </tr> '

	C_HTML += '</font>'        
	C_HTML += '</table> '   

	//OBSERVACAO
	cDescric := Alltrim(SC5->C5_YOBS)
	nLinha	:= MLCount(cDescric,90)

	If (!Empty(cDescric))
		C_HTML += '<BR>' 
		C_HTML += '<table width="900" border="0" bgcolor="black"> '
		C_HTML += '  <tr> '                                        
		// C_HTML += '<font color="white"> '

		// C_HTML += '</font>'            
		C_HTML += '</tr> '             
		C_HTML += '</table> '

		C_HTML += '<table width="900" border="0" bgcolor="#00FA9A" style="color:black"> '
		C_HTML += '<font color="black"> '                          
		C_HTML += '<tr> '
		C_HTML += '    <th width="900" scope="col"> OBSERVA«√O:  </th> '
		C_HTML += '  </tr> '
		C_HTML += '</font>'        
		C_HTML += '</table> '        

		C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2" style="color:black"> '
		C_HTML += '<font color="black" size="2"> '  


		FOR I := 1 To nLinha                        
			C_HTML += '<tr> '   
			C_HTML += '    <td><div align="left">  '+MemoLine(cDescric,90,I)+'</td> '
			C_HTML += '  </tr> '
		NEXT I       

		C_HTML += '</font>'        
		C_HTML += '</table> ' 
	EndIf

	//ASSINATURA PARA CLIENTES DE ENGENHARIA 
	If(Alltrim(SA1->A1_YTPSEG)=='E')
		C_HTML += '<BR><BR><BR>'
		C_HTML += '<table width="900" border="0" bgcolor="white" style="color:black"> '
		C_HTML += '<font color="black"> '                          
		C_HTML += '<tr> '
		C_HTML += '    <th width="900" scope="col"> ___________________________________________________________  </th> '
		C_HTML += '  </tr> '
		C_HTML += '  <tr> '
		C_HTML += '    <th width="900" scope="col">Assinatura do Comprador</th> '
		C_HTML += '  </tr> '
		C_HTML += '</font>'        
		C_HTML += '</table> '    
	EndIf  

	C_HTML += '<BR><BR>	<u><b>Esta È uma mensagem autom·tica. Favor n„o responder.</b></u> '     
	C_HTML += '<p>&nbsp;	</p> '
	C_HTML += '</body> '
	C_HTML += '</html> '

	ENV_EMAIL(cData,cTitulo,C_HTML,Alltrim(SA1->A1_YTPSEG))

RETURN


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ ENV_EMAIL      ∫Autor  ≥BRUNO MADALENO      ∫ Data ≥  04/12/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ROTINA PARA ENVIAR O EMAIL                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC Function ENV_EMAIL(cData, cTitulo, cMensagem, cCliEng)
Local I   
Local lOk := .T.
Local nCount := 0
Local cRecebe := AllTrim(cDestinatario) + ";" + AllTrim(CCOPIA)
Local cRecebeCC	:= ""
Local cRecebeO := ""
Local cAnexos := ""
Local oRecAnt := Nil
Local aNumBol := {}
Local oWFEng := Nil

	If (cEmpAnt == "01" .Or. cEmpAnt == "0101") .And. cCliEng == "E"
	
		cRecebeO := U_EmailWF('ENV_PEDIDO', cEmpAnt , "" )
		
	EndIf
	
	cAssunto := cTitulo   
	
	//Ticket 33119 - olicitaÁ„o do Cludeir para remover o anexo do email.
	cAnexos	:= "" //"\P10\relato\PV\pv_"+nPed_Imp+".TXT"
	
	oRecAnt := TRecebimentoAntecipado():New()
	
	// Retorna o numero do boleto
	aNumBol := oRecAnt:RetNumBol()

	If Len(aNumBol) > 0

		For nCount := 1 To Len(aNumBol)
		
			cAnexos	+= ",\P10\COB\BOLETO\"+AllTrim(aNumBol[nCount])+".HTML"
			
		Next

		// Workflow para os representantes
		U_BIAF021(SC5->C5_NUM, AllTrim(cDestinatario), cAnexos)

	Endif
	
	// Se o cliente for de Engenharia, envia workflow de orientacoes
	If cCliEng == "E"
		
		If( ((cEmpAnt == "01" .Or. cEmpAnt == "0101") .And. AllTrim(SC5->C5_YSUBTP) $ "A_B_G_M");
	   .Or. ((cEmpAnt == "07" .Or. cEmpAnt == "0701") .And. AllTrim(SC5->C5_YSUBTP) $ "B_G"))
			//Ticket 24991 - solicitaÁ„o da Camila com aval do Alexandre Patelli
			//n„o enviar workflow para pedidos da Biancogres se forem tipo A, B G ou M nem para LM se forem B ou G
		else
			cAnexos	+= ",\P10\vistoria_obra\orientacao\orientacoes_biancogres.pdf"
			
			oWFEng := TWorkflowEngenheiroObraEngenharia():New()

			oWFEng:Send(SC5->C5_YMAILEN, AllTrim(cDestinatario))
		endif
						
	EndIf
			 

	If Upper(AllTrim(getenvserver())) == "PRODUCAO" .OR. Upper(AllTrim(getenvserver())) == "REMOTO" .OR. Upper(AllTrim(getenvserver())) == "SCHEDULE"

		lOK := U_BIAEnvMail(,cRecebe,cTitulo,cMensagem,,cAnexos,.F.,cRecebeCC,cRecebeO)

		If lOk   
			
			DbSelectArea("SC5")
			
			Reclock("SC5",.F.)
				
				SC5->C5_YENVIO := "S"
				
			SC5->(MsUnlock())
			
			CSTATUS := "OK"			
			
		Else  
			
			CSTATUS := "N"
			
			MsgStop("ERRO AO ENVIAR O EMAIL")

			U_GravaPZ2(SC5->(RecNo()),"SC5",SC5->C5_YEMPPED+SC5->C5_NUM,"ENV_PED_3",AllTrim(FunName()),"ENV", CUSERNAME)
			
		Endif

	EndIf

Return lOk

/* 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
≤±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤
≤±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±≤
≤±±∫Programa  ≥CRIA_ARQUIVO∫Autor  ≥ MADALENO           ∫ Data ≥  22/10/07   ∫±±≤
≤±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±≤
≤±±∫Desc.     ≥ ROTINA RESPONSAVEM EM CRIAR O ARQUIVO CONTENDO O PEDIDO      ∫±±≤
≤±±∫          ≥ VEND                                                         ∫±±≤
≤±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±≤
≤±±∫Uso       ≥ AP7                                                          ∫±±≤
≤±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±≤
≤±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
USER FUNCTION CRIA_ARQUIVO(aaNUM_PED,cEmpPed)

	Local J, I

	Private cEOL    := "CHR(13)+CHR(10)"
	Private cArqTxt 
	Private nHdl    
	Private Enter := CHR(13)+CHR(10)
	Private NUM_PEDIDO := aaNUM_PED
	Private EMP_PEDIDO := cEmpPed
	Private cSZ5 := RetSQLName("SZ5")

	If Empty(cSZ5)
		cSZ5 := "SZ5010"
	EndIf

	//≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
	//≤ SELECIONANDO O PEDIDO E A SITUACAO EM QUE O MESMO SE ENCONTRA  ≤
	//≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤

	//ATUALIZA«√O QUERY - SQL ATUAL - 18/01/2016
	cQUERY := "SELECT	 " + Enter
	cQUERY += " C5_NUM" + Enter
	cQUERY += ", C5_EMISSAO" + Enter
	cQUERY += ", C5_CONDPAG" + Enter
	cQUERY += ", C5_YFORMA" + Enter
	cQUERY += ", C5_CLIENTE" + Enter
	cQUERY += ", C5_LOJACLI" + Enter
	cQUERY += ", C5_VLRFRET" + Enter
	cQUERY += ", C5_YMAXCND" + Enter
	cQUERY += ", C5_TRANSP " + Enter
	cQUERY += ", C5_YSUBTP " + Enter
	cQUERY += ", (SELECT MAX(C62.C6_YPERC) FROM "+RETSQLNAME("SC6")+" C62 WHERE C62.C6_NUM = C5_NUM AND C62.D_E_L_E_T_ = '') C6_YPERC" + Enter
	cQUERY += ", (SELECT MAX(C63.C6_YDESC) FROM "+RETSQLNAME("SC6")+" C63 WHERE C63.C6_NUM = C5_NUM AND C63.D_E_L_E_T_ = '') C6_YDESC" + Enter
	cQUERY += ", C6_PRODUTO" + Enter
	cQUERY += ", C6_ITEM" + Enter
	cQUERY += ", C6_QTDVEN" + Enter
	cQUERY += ", C6_PRUNIT" + Enter
	cQUERY += ", C6_VALOR" + Enter
	cQUERY += ", C6_VALDESC" + Enter
	cQUERY += ", C6_QTDVEN  " + Enter
	cQUERY += ", C6_ENTREG  " + Enter
	cQUERY += ", C6_YDTNECE " + Enter
	cQUERY += ", B1_DESC" + Enter
	cQUERY += ",ISNULL(EST.GRUPO,0) GRUPO" + Enter
	cQUERY += ",ISNULL(EST.ESTOQUE,0) ESTOQUE" + Enter
	cQUERY += ",ISNULL(EST.PEDIDO,0) PEDIDO" + Enter
	cQUERY += ",ISNULL(EST.RESERVA,0) RESERVA" + Enter
	cQUERY += "FROM " + RETSQLNAME("SC5") + " SC5 " + Enter
	cQUERY += "	INNER JOIN " + RETSQLNAME("SC6") + " SC6 " + Enter
	cQUERY += "		ON SC6.C6_FILIAL = SC5.C5_FILIAL " + Enter
	cQUERY += "			AND SC6.C6_NUM = SC5.C5_NUM " + Enter
	cQUERY += "			AND SC6.C6_BLQ 		<> 'R' " + Enter  //OS 3265-15 EM 02/09/15
	cQUERY += "			AND SC6.D_E_L_E_T_	= '' " + Enter
	cQUERY += "	INNER JOIN " + RETSQLNAME("SB1") + " SB1 " + Enter
	cQUERY += "		ON SB1.B1_COD = SC6.C6_PRODUTO " + Enter
	cQUERY += "			AND SB1.D_E_L_E_T_ = '' " + Enter
	cQUERY += "	LEFT JOIN (SELECT	B1.B1_COD, " + Enter
	cQUERY += "						SUBSTRING(B1.B1_YREF,8,32) GRUPO, " + Enter
	cQUERY += "						ISNULL(SUM(B2.B2_QATU),0) ESTOQUE, " + Enter
	cQUERY += "						ISNULL((SELECT SUM(C6.C6_QTDVEN-C6.C6_QTDENT) FROM " + RETSQLNAME("SC6") + " C6, " + RETSQLNAME("SF4") + " SF4 " + Enter
	cQUERY += "									WHERE C6.C6_FILIAL = '"+XFILIAL("SC6")+"' AND C6_BLOQUEI = '' AND C6.C6_QTDVEN > C6.C6_QTDENT AND C6.C6_TES = SF4.F4_CODIGO " + Enter
	cQUERY += "										  AND SF4.F4_ESTOQUE = 'S' " + Enter
	cQUERY += "										  AND C6.C6_PRODUTO = B1.B1_COD " + Enter
	cQUERY += "										  AND C6.D_E_L_E_T_ = '' " + Enter
	cQUERY += "										  AND SF4.D_E_L_E_T_ = '') ,0) PEDIDO, " + Enter
	cQUERY += "						ISNULL((SELECT SUM(DC_QUANT) RESERVA " + Enter
	cQUERY += "								   FROM " + RETSQLNAME("SDC") + " DC, " + RETSQLNAME("SC0") + " C0 " + Enter
	cQUERY += "								   WHERE DC.DC_FILIAL = '"+XFILIAL("SDC")+"' " + Enter
	cQUERY += "										 AND C0.C0_FILIAL = '"+XFILIAL("SC0")+"' " + Enter
	cQUERY += "										 AND C0.C0_LOCAL = DC.DC_LOCAL " + Enter
	cQUERY += "										 AND C0.C0_NUM  = DC.DC_PEDIDO " + Enter
	cQUERY += "										 AND C0.C0_PRODUTO = DC.DC_PRODUTO " + Enter
	cQUERY += "										 AND DC.DC_ORIGEM = 'SC0' " + Enter
	cQUERY += "										 AND DC.DC_PRODUTO = B1.B1_COD " + Enter
	cQUERY += "										 AND C0.C0_YPEDIDO NOT IN (SELECT C5_NUM FROM " + RETSQLNAME("SC5") + " C5 WHERE C5_FILIAL='"+XFILIAL("SC5")+"' AND D_E_L_E_T_ = '') " + Enter
	cQUERY += "										 AND DC.D_E_L_E_T_ = '' " + Enter
	cQUERY += "										 AND C0.D_E_L_E_T_ = ''),0) RESERVA " + Enter
	cQUERY += "						FROM " + RETSQLNAME("SB1") + " B1 " + Enter
	cQUERY += "							INNER JOIN " + cSZ5 + " Z5 " + Enter
	cQUERY += "								ON Z5.Z5_DESC = SUBSTRING(B1.B1_YREF,8,32) " + Enter
	cQUERY += "									AND Z5_FILIAL = '01' " + Enter
	cQUERY += "									AND Z5.Z5_ATIVO = 'S' " + Enter
	cQUERY += "									AND Z5.D_E_L_E_T_ = '' " + Enter
	cQUERY += "							LEFT JOIN " + RETSQLNAME("SB2") + " B2 " + Enter
	cQUERY += "								ON B1.B1_COD = B2.B2_COD " + Enter
	cQUERY += "									AND B1.B1_LOCPAD = B2.B2_LOCAL " + Enter
	cQUERY += "									AND B2.B2_FILIAL = '"+XFILIAL("SB2")+"' " + Enter
	cQUERY += "									AND B2.D_E_L_E_T_ = '' " + Enter
	cQUERY += "				WHERE B1.B1_FILIAL = '  ' " + Enter
	cQUERY += "				AND SUBSTRING(B1.B1_COD,6,1) = '1' " + Enter
	cQUERY += "				AND B1.B1_TIPO = 'PA' " + Enter
	cQUERY += "				AND B1.B1_YREF <> '' " + Enter
	cQUERY += "				AND B1.B1_YREFPV <> '' " + Enter
	cQUERY += "				AND B1.D_E_L_E_T_ = '' " + Enter
	cQUERY += "				GROUP BY B1.B1_COD,B1.B1_YREF ) EST " + Enter
	cQUERY += "		ON SB1.B1_COD = EST.B1_COD " + Enter
	cQUERY += "	WHERE	SC5.C5_FILIAL		= '"+XFILIAL("SC5")+"' " + Enter
	cQUERY += "			AND SC5.C5_NUM		= '" + NUM_PEDIDO + "' " + Enter
	If cEmpAnt == '07'
		cQUERY += "			AND SC5.C5_YEMPPED	= '" + EMP_PEDIDO + "' " + Enter
	EndIf
	cQUERY += "			AND SC5.D_E_L_E_T_	= '' " + Enter
	cQUERY += "ORDER BY C5_FILIAL, C5_NUM, C6_ITEM " + Enter




	If chkfile("_AUX_PEDIDO")
		dbSelectArea("_AUX_PEDIDO")
		dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_AUX_PEDIDO" NEW


	IF _AUX_PEDIDO->(EOF()) .And. cEmpAnt <> "06'
		ALERT("PEDIDO N„O ENCONTRADO: " + NUM_PEDIDO + "  FAVOR COMUNICAR O SETOR DE TI")
		RETURN(.F.)
	end if  

	_AUX_PEDIDO->(DbGoTop())

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	cArqTxt := "\P10\relato\PV\PV_"+nPed_Imp+".TXT"
	nHdl    := fCreate(cArqTxt)

	NUM_PEDIDO 	:= _AUX_PEDIDO->C5_NUM 
	DATA_EMISS 	:= alltrim(dtoc(stod(_AUX_PEDIDO->C5_EMISSAO))) //_AUX_PEDIDO->C5_EMISSAO  
	COD_REPRE	:= cCodVend
	cONDICAO_PG := PADR( Posicione("SE4",1,xFilial("SE4")+_AUX_PEDIDO->C5_CONDPAG,"E4_DESCRI"),25) //16
	NOME_REPRE	:= PADR( Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_NREDUZ"),16)
	FORM_PGTO	:= PADR( IIF(_AUX_PEDIDO->C5_YFORMA="1","BANCO",IIF(_AUX_PEDIDO->C5_YFORMA="2","CHEQUE","OP")),16)
	TRANSPO		:= PADR(Posicione("SA4",1,xFilial("SA4")+_AUX_PEDIDO->C5_TRANSP,"A4_NOME"),34) //_AUX_PEDIDO->A4_NOME

	//BUSCANDO INFORNMACOES DO CLIENTE
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+ _AUX_PEDIDO->C5_CLIENTE + _AUX_PEDIDO->C5_LOJACLI ,.T.)

	c_Cliente	:= "CODIGO " + PADR(SA1->A1_COD,6)
	NOMECLIENTE	:= PADR(SA1->A1_NOME,52)  + c_Cliente // SA1->A1_NOME
	ENDERECO	:= PADR(SA1->A1_END,60) // SA1->A1_END
	BAIRRO		:= PADR(SA1->A1_BAIRRO,20) // SA1->A1_BAIRRO						
	CIDADE		:= PADR(SA1->A1_MUN,23)	 // SA1->A1_MUN
	UF			:= PADR(SA1->A1_EST,02) //SA1->A1_EST
	CNPJ		:= Transform(SA1->A1_CGC ,"@R 99.999.999/9999-99") //PADR(SA1->A1_CGC,15) //SA1->A1_CGC
	I_E			:= PADR(SA1->A1_INSCR,18) //SA1->A1_INSCR
	CEP			:= PADR(SA1->A1_CEP,08) //SA1->A1_CEP
	COMPRADOR	:= PADR(SA1->A1_CONTATO,18) //SA1->A1_CONTATO
	TELEFONE	:= PADR(SA1->A1_TEL,15)	 //SA1->A1_TEL
	FAX			:= PADR(SA1->A1_FAX,13) //SA1->A1_FAX
	EMAIL		:= PADR(SA1->A1_EMAIL,34) //SA1->A1_EMAIL


	//fWrite(nHdl,cLin+cEOL)

	If cempant == "01"
		cLin := PADR("___________________________________________________________________________________________________"									,99) + cEOL
		cLin += PADR("|                                                        | PEDIDO             |       DATA        |"									,99) + cEOL
		cLin += PADR("|               BIANCOGRES CER¬MICA SA                   | "+nPed_Imp+"       |   "+DATA_EMISS+"  |"			   			,99) + cEOL
		cLin += PADR("|                                                        |____________________|___________________|"									,99) + cEOL
		cLin += PADR("|                                                        |COD. REPRES.:       |COND. PAGT.∫       |"									,99) + cEOL
		cLin += PADR("|          Av. Talma Rodrigues Ribeiro, Nr.1145          | "+COD_REPRE+"      |"+PADR(AllTrim(cONDICAO_PG),19)+"|"			,99) + cEOL
		cLin += PADR("|     Civit II - Serra - ES - Brasil - Cep 29168-080     |____________________|___________________|"									,99) + cEOL
		cLin += PADR("|          Tel.: 27 3421 9000 - Fax: 27 3421 9045        |NOME REPRES.:       |FORMA DE PAGT.∫    |"									,99) + cEOL
		cLin += PADR("|www.biancogres.com									   | "+NOME_REPRE+"  	| "+FORM_PGTO+"  	|"										,99) + cEOL
		cLin += PADR("|________________________________________________________|____________________|___________________|"									,99) + cEOL
	ELSEIF cempant == "05"
		cLin := PADR("___________________________________________________________________________________________________"									,99) + cEOL
		cLin += PADR("|                                                        | PEDIDO             |       DATA        |"									,99) + cEOL
		cLin += PADR("|        INCESA REVESTIMENTO CERAMICO LTDA               | "+nPed_Imp+"       |     "+DATA_EMISS+"|"						,99) + cEOL
		cLin += PADR("|                                                        |____________________|___________________|"									,99) + cEOL
		cLin += PADR("|                  Rua 3, Nr 648                         |COD. REPRES.:       |COND. PAGT.∫       |"									,99) + cEOL
		cLin += PADR("|     Civit II - Serra - ES - Brasil - Cep 29168-079     | "+COD_REPRE+" 		|"+PADR(AllTrim(cONDICAO_PG),19)+"|"			,99) + cEOL
		cLin += PADR("|          Tel.: 27 3421 9100 - Fax: 27 3421 9126        |____________________|___________________|"									,99) + cEOL
		cLin += PADR("|            site: www.ceramicaincesa.com.br             |NOME REPRES.:       |FORMA DE PAGT.∫    |"									,99) + cEOL
		cLin += PADR("|          							                   | "+NOME_REPRE+"   	| "+FORM_PGTO+"		|"										,99) + cEOL
		cLin += PADR("|________________________________________________________|____________________|___________________|"									,99) + cEOL
	ELSE
		cLin := PADR("___________________________________________________________________________________________________"									,99) + cEOL
		cLin += PADR("|                                                        | PEDIDO             |       DATA        |"									,99) + cEOL
		cLin += PADR("| LM COMERCIO ATACADISTA DE MATERIAL DE CONSTRUCAO LTDA	 | "+nPed_Imp+"     |     "+DATA_EMISS+"|"				   		,99) + cEOL
		cLin += PADR("|                                                        |____________________|___________________|"									,99) + cEOL
		cLin += PADR("|             Rua Dois, Lote 07 Quadra VI                |COD. REPRES.:       |COND. PAGT.∫       |"									,99) + cEOL
		cLin += PADR("|     Civit II - Serra - ES - Brasil - Cep 29168-081     | "+COD_REPRE+"             |"+PADR(AllTrim(cONDICAO_PG),19)+"|"			,99) + cEOL
		cLin += PADR("|          Tel.: 27 3421 9001                            |____________________|___________________|"									,99) + cEOL
		cLin += PADR("|                                                        |NOME REPRES.:       |FORMA DE PAGT.∫    |"									,99) + cEOL
		cLin += PADR("|                                                        | "+NOME_REPRE+"   	| "+FORM_PGTO+" 	|"										,99) + cEOL
		cLin += PADR("|________________________________________________________|____________________|___________________|"									,99) + cEOL
	END IF
	cLin += PADR("|                                                                                                 |"										,99) + cEOL
	cLin += PADR("|CLIENTE:   "+NOMECLIENTE+"                     |"																						,99) + cEOL
	cLin += PADR("|ENDERE«O:  "+ENDERECO+"                          |"																						,99) + cEOL
	cLin += PADR("|BAIRRO:    "+BAIRRO+"               CIDADE: "+CIDADE+" UF: "+UF+"             |"														,99) + cEOL
	cLin += PADR("|CNPJ:      "+CNPJ+"                 I. E.: "+I_E+"      CEP: "+CEP+"       |"															,99) + cEOL
	cLin += PADR("|COMPRADOR: "+COMPRADOR+"                 TELEFONE: "+TELEFONE+"      FAX: "+FAX+"  |"													,99) + cEOL
	cLin += PADR("|E-MAIL:    "+EMAIL+" TRANSPORTADORA: "+TRANSPO+" |"							,99) + cEOL
	cLin += PADR("|_________________________________________________________________________________________________|"										,99) + cEOL
	cLin += PADR("|_________________________________________________________________________________________________|"										,99) + cEOL
	cLin += PADR("|    |         |                               |         |          |             |               |"										,99) + cEOL
	//cLin += PADR("|ORD | QUANT.  |           PRODUTO             | DISPON. | PRE«O UNIT. |DT NECES. | VALOR TOTAL   |"										,99) + cEOL
	cLin += PADR("|ORD | QUANT.  |           PRODUTO             | DISPON. |DT NECES. | PRE«O UNIT. | VALOR TOTAL   |"										,99) + cEOL
	cLin += PADR("|____|_________|_______________________________|_________|__________|_____________|_______________|"										,99) + cEOL
	fWrite(nHdl,cLin)

	aTOTAL_QUANT := 0
	aTOTAL_TOTAL := 0

	//****************************************************************************
	//*************** LOOP PARA PREENCHER TODOS OS ITENS... **********************
	//****************************************************************************
	/*cQUERY := "SELECT SC6.C6_PRODUTO, SC6.C6_ITEM, SC6.C6_QTDVEN,  SB1.B1_DESC, SC6.C6_PRUNIT, SC6.C6_VALOR, SC6.C6_VALDESC, SC6.C6_QTDVEN   " + Enter
	cQUERY += "FROM "+RETSQLNAME("SC6")+" AS SC6, "+RETSQLNAME("SB1")+" AS SB1 " + Enter
	cQUERY += "WHERE	SC6.C6_NUM = '"+NUM_PEDIDO+"' AND " + Enter
	cQUERY += "		SC6.D_E_L_E_T_ = ''  " + Enter
	cQUERY += "		AND C6_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ = '' " + Enter
	cQUERY += "ORDER BY C6_ITEM  " + Enter

	If chkfile("_AUX_ITEM")
	dbSelectArea("_AUX_ITEM")
	dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_AUX_ITEM" NEW*/

	I := 0 
	N_DESC_INC := 0  
	_AUX_PEDIDO->(DbGoTop())
	DO WHILE ! _AUX_PEDIDO->(EOF())

		I ++

		//AA_AA 		:= aaBUSCA_ESTOQUE(ALLTRIM(_AUX_PEDIDO->C6_PRODUTO))
		ORD			:= PADC(ALLTRIM( _AUX_PEDIDO->C6_ITEM ),2)
		QUANT 		:= Transform(_AUX_PEDIDO->C6_QTDVEN ,"@E 99,999.99")
		//(Thiago Dantas - 02/03/15) -> Adicionado campo codigo do produto [OS 0938-15]
		DESCRICAO   := PADR(ALLTRIM(_AUX_PEDIDO->C6_PRODUTO)+'-'+ ALLTRIM(_AUX_PEDIDO->B1_DESC),29)
		//cc_ESTOQUE  := PADR(AA_AA,9)
		cc_ESTOQUE  := PADR(SUBSTR(_AUX_PEDIDO->C6_ENTREG,7,2)+"/"+SUBSTR(_AUX_PEDIDO->C6_ENTREG,5,2)+"/"+SUBSTR(_AUX_PEDIDO->C6_ENTREG,3,2),9)
		PRECO_UNI	:= " " + Transform(_AUX_PEDIDO->C6_PRUNIT,"@E 999,999.99") //PADL("124215.25",11)  // PRECO DE LISTA
		//IPI			:= PADC("0%",8)
		DT_NECESS	:=	DTOC(STOD(_AUX_PEDIDO->C6_YDTNECE))
		VALOR_TOT	:= Transform(_AUX_PEDIDO->C6_VALOR + _AUX_PEDIDO->C6_VALDESC,"@E 99,999,999.99") //PADL("524215.25",13)

		N_DESC_INC		+= _AUX_PEDIDO->C6_VALDESC
		aTOTAL_QUANT 	+= _AUX_PEDIDO->C6_QTDVEN
		aTOTAL_TOTAL 	+= _AUX_PEDIDO->C6_VALOR + _AUX_PEDIDO->C6_VALDESC

		cLin := PADR("| "+ORD+" |"+QUANT+"| "+DESCRICAO+" |"+cc_ESTOQUE+"| "+DT_NECESS+" | "+PRECO_UNI+" | "+VALOR_TOT+" |"										,99) + cEOL
		fWrite(nHdl,cLin)
		_AUX_PEDIDO->(DBSKIP())

	END DO
	cLin := ""
	FOR J:=1 TO 19-I 
		cLin += PADR("|    |         |                               |         |          |             |               |"									,99) + cEOL
	NEXT
	//cLin += PADR("|TOTAL GERAL______________________________________________________________________________________|"									,99) + cEOL
	fWrite(nHdl,cLin)

	//VERIFICANDO SE EXISTE OUTRA FOLHA SE EXISTIR NAO IMPRIME O TOTAL.
	//IF I >= 21
	cLin := PADR("|____|_________|_______________________________|_________|__________|_____________|_______________|"									,99) + cEOL
	cLin += PADR("|    |         |                                         |          |             |               |"									,99) + cEOL
	cLin += PADR("|TOTA|"+Transform(aTOTAL_QUANT,"@E 99,999.99")+"|                                         |          |             | "+Transform(aTOTAL_TOTAL,"@E 99,999,999.99")+" |"			,99) + cEOL
	cLin += PADR("|____|_________|_________________________________________|__________|_____________|_______________|"									,99) + cEOL

	fWrite(nHdl,cLin)
	//END IF       
	_AUX_PEDIDO->(DbGoTop())

	cSEGURO			:=  IIF(_AUX_PEDIDO->C5_VLRFRET == 0,"N„o","Sim")
	SEGURO 			:= Transform((_AUX_PEDIDO->C5_VLRFRET*aTOTAL_QUANT),"@E 9,999,999.999") //PADL("0,58",13) 
	TOTAL_COMIPI 	:=  Transform((aTOTAL_TOTAL-N_DESC_INC),"@E 99,999,999.99")  //PADL("1548721.25",13)
	//TOTAL_COMIPI 	:=  Transform((aTOTAL_TOTAL+_AUX_PEDIDO->C5_VLRFRET+((aTOTAL_TOTAL/100)*5)),"@E 99,999,999.99")  //PADL("1548721.25",13)
	//TOTAL_COMIPI 	:=  Transform(((aTOTAL_TOTAL+(_AUX_PEDIDO->C5_VLRFRET*aTOTAL_QUANT))-N_DESC_INC),"@E 99,999,999.99")  //PADL("1548721.25",13)
	DES_INC			:= Transform(N_DESC_INC,"@E 9,999,999.999")

	// IMPRIMINDO O FRETE TOTAL GERAL COM IPI
	cLin := PADR("|                                                                                 |               |"										,99) + cEOL
	cLin += PADR("|SEGURO PRODUTO: "+cSEGURO+"                                                              | "+SEGURO+" |"									,99) + cEOL
	cLin += PADR("|DESCONCONTO INCONDICIONAL:                                                       | "+DES_INC+" |"									,99) + cEOL
	cLin += PADR("|_________________________________________________________________________________|_______________|"										,99) + cEOL


	// BUISCANDO OS DESCONTOS NOS ITENS DO PEDIDO
	/*cQUERY := "SELECT MAX(C6_YPERC) AS C6_YPERC, MAX(C6_YDESC) AS C6_YDESC FROM "+RETSQLNAME("SC6")+" " + Enter
	cQUERY += "WHERE C6_NUM = '"+NUM_PEDIDO+"' AND D_E_L_E_T_ = '' " + Enter
	If chkfile("_AUX_DESC")
	dbSelectArea("_AUX_DESC")
	dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_AUX_DESC" NEW*/

	//_AUX_PEDIDO->(DbGoTop())

	cLin += PADR("|                                                                                 |               |"										,99) + cEOL
	cLin += PADR("|                                                         TOTAL COM SEGURO E IPI: | "+TOTAL_COMIPI+" |"									,99) + cEOL
	cLin += PADR("|_________________________________________________________________________________|________________|"										,99) + cEOL
	cLin += PADR("|                                                                                                  |"										,99) + cEOL
	cLin += PADR("|__________________________________________________________________________________________________|"										,99) + cEOL


	If ( !_lVitcer )

		// cLin += PADR("| IMPORTANTE:                                                                                      |"										,99) + cEOL
		// cLin += PADR("|    1 - Pedido sujeito a an·lise de crÈdito.                                                      |"										,99) + cEOL
		// cLin += PADR("|    2 - PreÁo FOB f·brica. Para pedidos sem seguro o transporte È por conta e risco do cliente.   |"										,99) + cEOL
		// cLin += PADR("|    3 - Os produtos a serem retirados na f·brica devem ser agendados com 48 horas de antecedÍncia.|"										,99) + cEOL
		// cLin += PADR("|    4 - Os produtos disponÌveis para embarque que n„o forem retirados no prazo de 14 dias ser„o   |"										,99) + cEOL
		// cLin += PADR("|        automaticamente cancelados.                                                               |"										,99) + cEOL
		// cLin += PADR("|    5 - PreÁos e condiÁıes sujeitos a confirmaÁ„o. Caso a inflaÁ„o do setor seja superior a 5%    |"										,99) + cEOL
		// cLin += PADR("|        entre a digitaÁ„o do pedido e a data prevista de entrega, os preÁos ser„o renegociados.   |"										,99) + cEOL
		// cLin += PADR("|        Caso haja alteraÁ„o na legislaÁ„o tribut·ria os preÁos tambÈm dever„o ser reajustados.    |"										,99) + cEOL
		// cLin += PADR("|    6 - O volume de cada item constante no pedido pode sofrer variaÁ„o de 10% para mais e para    |"										,99) + cEOL
		// cLin += PADR("|        menos.                                                                                    |"										,99) + cEOL
		// cLin += PADR("|    7 - Adquirir aproximadamente 10% a mais do produto para efeitos de reserva tÈcnica (indicado  |"										,99) + cEOL
		// cLin += PADR("|        inclusive pela norma a ABNT).                                                             |"										,99) + cEOL
		// cLin += PADR("|    8 - Devido a utilizaÁ„o de matÈrias primas naturais que s„o queimadas em alta temperaturas,   |"										,99) + cEOL
		// cLin += PADR("|        sÛ poderemos garantir fornecimento com uniformidade de tonalidade e calibre para produtos |"										,99) + cEOL
		// cLin += PADR("|        do mesmo lote. A data de disponibilidade dos produtos poder· sofrer alteraÁ„o na data de  |"										,99) + cEOL
		// cLin += PADR("|        entrega pelo mesmo motivo e uma nova data ser·  informada.                                |"										,99) + cEOL
		// cLin += PADR("|    9 - Para construÁıes acima de 1.000 m≤ orientamos realizar o assentamento completo com        |"										,99) + cEOL
		// cLin += PADR("|        rejuntamento em 01 (um) apartamento / casa para aprovaÁ„o do produto / lote. Ressaltamos  |"										,99) + cEOL
		// cLin += PADR("|        que reclamaÁıes apÛs o assentamento do produto n„o ser„o aceitas.                         |"										,99) + cEOL

		//Ticket 33102 - alteraÁ„o no texto
		cLin += PADR("| IMPORTANTE:                                                                                      |"										,99) + cEOL
		cLin += PADR("|    1  - PreÁos e condiÁıes sujeitos a confirmaÁ„o no momento da implantaÁ„o do pedido.           |"										,99) + cEOL
		cLin += PADR("|    2  - Todo pedido È sujeito a an·lise de crÈdito.   											 |"										,99) + cEOL
		cLin += PADR("|    3  - A quantidade de cada item do pedido pode sofrer variaÁ„o de 10% para cima ou para baixo. |"										,99) + cEOL
		cLin += PADR("|    4  - Os preÁos s„o FOB f·brica.                                                               |"										,99) + cEOL
		cLin += PADR("|    5  - A previs„o de disponibilidade dos produtos ser· confirmada no momento da implantaÁ„o do  |"										,99) + cEOL
		cLin += PADR("|    		pedido no sistema.																		 |"										,99) + cEOL
		cLin += PADR("|    6  - Caso a inflaÁ„o do setor seja superior a 5% entre a digitaÁ„o do pedido e a data 		 |"										,99) + cEOL
		cLin += PADR("|    		prevista de entrega, os preÁos ser„o renegociados.                                       |"										,99) + cEOL
		cLin += PADR("|    7  - Caso haja alteraÁ„o na legislaÁ„o tribut·ria os preÁos ser„o reajustados.                |"										,99) + cEOL
		cLin += PADR("|    8  - O fabricante n„o possui responsabilidade sobre o preÁo do frete e da entrega. O valor do |"										,99) + cEOL
		cLin += PADR("|    		frete (R$/t) È uma estimativa do representante comercial junto com o transportador.      |"										,99) + cEOL
		cLin += PADR("|    9  - Os produtos disponÌveis para embarque e n„o carregados ser„o automaticamente cancelados. |"										,99) + cEOL
		cLin += PADR("|    10 ñ O carregamento dos produtos na f·brica devem ser agendados com 48 horas de antecedÍncia. |"										,99) + cEOL
		cLin += PADR("|    11 ñ Garantimos uniformidade de tonalidade e calibre para produtos do mesmo lote.             |"										,99) + cEOL
		cLin += PADR("|    12 ñ Reserva tÈcnica para obras: sugerimos adquirir 20% a mais de cada produto para todos os  |"										,99) + cEOL
		cLin += PADR("|    		formatos.                         														 |"										,99) + cEOL
		cLin += PADR("|    13 - Para construÁıes acima de 1.000 m≤, È necess·rio realizar o assentamento de um 			 |"										,99) + cEOL
		cLin += PADR("|    		apartamento ou casa para aprovaÁ„o do produto. Essa operaÁ„o deve ser repetida a cada    |"										,99) + cEOL
		cLin += PADR("|    		lote recebido.                         													 |"										,99) + cEOL
		cLin += PADR("|    14 ñ Orientamos que independente da metragem adquirida seja realizado o assentamento de uma   |"										,99) + cEOL
		cLin += PADR("|    		pequena metragem para avaliaÁ„o e aprovaÁ„o do produto.                        			 |"										,99) + cEOL
		cLin += PADR("|    15 ñ Nosso site e embalagens contemplam informaÁıes importantes para o correto manuseio, 	 |"										,99) + cEOL
		cLin += PADR("|    		instalaÁ„o e manutenÁ„o dos nossos produtos. … imperativo seguir todas as orientaÁıes    |"										,99) + cEOL
		cLin += PADR("|    		para a qualidade da sua obra e a garantia do seu produto.                        		 |"										,99) + cEOL

	Else

		cLin += PADR("| IMPORTANTE:                                                                                      |"										,99) + cEOL
		cLin += PADR("|    1 - Pedido exclusivo para atendimento de RodapÈ e n„o pode ser cancelado                      |"										,99) + cEOL

	EndIf

	cLin += PADR("|__________________________________________________________________________________________________|"										,99) + cEOL
	fWrite(nHdl,cLin)

	cLin := PADR("|                                                                                                  |"										,99) + cEOL
	cLin += PADR("| OBSERVA«√O                                                                                       |"										,99) + cEOL


	//GERANDO LINHA PARA O CAMPO MEMO C5_YOBS - FERNANDO - 05/08/2010	
	//Retirado por wanisay em 21/01/11- solicitado por Claudeir em 14/01/11
	//Colocado Novamente por Fernando conforme solicitaÁ„o do Claudeir em 15/03/2011
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(XFILIAL("SC5")+_AUX_PEDIDO->C5_NUM))
	cDescric := Alltrim(SC5->C5_YOBS)
	nLinha	:= MLCount(cDescric,90)
	FOR I := 1 To nLinha
		cLin += PADR("|"+PADR(MemoLine(cDescric,90,I),97)+"|",99) + cEOL
	NEXT I

	cLin += PADR("|_________________________________________________________________________________________________|"										,99) + cEOL
	fWrite(nHdl,cLin)

	fClose(nHdl)	
RETURN(.T.) 



/* 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
≤±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤
≤±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±≤
≤±±∫Programa  ≥aaBUSCA_ESTOQUE∫Autor  ≥ MADALENO           ∫ Data ≥  22/10/07   ∫±±≤
≤±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±≤
≤±±∫Desc.     ≥ ROTINA RESPONSAVEM EM CRIAR O ARQUIVO CONTENDO O PEDIDO         ∫±±≤
≤±±∫          ≥ VEND                                                            ∫±±≤
≤±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±≤
≤±±∫Uso       ≥ AP7                                                             ∫±±≤
≤±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±≤
≤±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION aaBUSCA_ESTOQUE(aapRODUTO)
	LOCAL Enter := chr(13) + Chr(10)
	cRef := ""

	/*DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+aapRODUTO,.F.)

	REFER := SUBSTR(SB1->B1_YREF,8,32)

	cSql := "SELECT SUBSTRING(B1.B1_COD,1,1) FORMATO, " + Enter
	cSql += "SUBSTRING(B1.B1_YREF,8,32) GRUPO, " + Enter
	cSql += "ISNULL(SUM(B2.B2_QATU),0) ESTOQUE, " + Enter
	cSql += "ISNULL(SUM(P.PEDIDO),0) PEDIDO, " + Enter
	cSql += "ISNULL(SUM(R.RESERVA),0) RESERVA " + Enter
	cSql += "FROM "+RETSQLNAME("SB1")+" B1 " + Enter
	cSql += "     INNER JOIN "+RETSQLNAME("SZ5")+" Z5 ON SUBSTRING(B1.B1_YREF,8,32) = Z5.Z5_DESC " + Enter
	cSql += "                            AND Z5.D_E_L_E_T_ = '' " + Enter
	cSql += "                            AND Z5.Z5_FILIAL = '"+XFILIAL("SZ5")+"' " + Enter
	cSql += "                            AND Z5.Z5_ATIVO = 'S' " + Enter
	cSql += "     LEFT JOIN "+RETSQLNAME("SB2")+" B2 ON B1.B1_COD = B2.B2_COD " + Enter
	cSql += "                            AND B1.B1_LOCPAD = B2.B2_LOCAL " + Enter
	cSql += "                            AND B2.D_E_L_E_T_ = '' " + Enter
	cSql += "                            AND B2.B2_FILIAL = '"+XFILIAL("SB2")+"' " + Enter
	cSql += "     LEFT JOIN (SELECT C6.C6_PRODUTO, SUM(C6.C6_QTDVEN-C6.C6_QTDENT) PEDIDO " + Enter
	cSql += "                FROM "+RETSQLNAME("SC6")+" C6, "+RETSQLNAME("SF4")+" SF4 " + Enter
	cSql += "                WHERE C6.D_E_L_E_T_ = '' " + Enter
	cSql += "                      AND C6.C6_FILIAL = '"+XFILIAL("SC6")+"' " + Enter
	cSql += "                      AND C6_BLOQUEI = '' " + Enter
	cSql += "                      AND C6.C6_QTDVEN > C6.C6_QTDENT AND " + Enter
	// *********************** ALTERACAO REALIZA POR BRUNO **************************** + Enter
	cSql += "						C6.C6_TES = SF4.F4_CODIGO                   AND " + Enter
	cSql += "						SF4.F4_ESTOQUE = 'S'			   			AND " + Enter
	cSql += "						SF4.D_E_L_E_T_ = '' " + Enter
	//***********************************************************************************			 + Enter
	cSql += "                      GROUP BY C6.C6_PRODUTO) P " + Enter
	cSql += "          ON B1.B1_COD = P.C6_PRODUTO " + Enter
	cSql += "    LEFT JOIN (SELECT DISTINCT DC.DC_PRODUTO, SUM(DC_QUANT) RESERVA " + Enter
	cSql += "               FROM "+RETSQLNAME("SDC")+" DC, "+RETSQLNAME("SC0")+" C0 " + Enter
	cSql += "               WHERE DC.D_E_L_E_T_ = '' " + Enter
	cSql += "                     AND C0.D_E_L_E_T_ = '' " + Enter
	cSql += "                     AND DC.DC_FILIAL = '"+XFILIAL("SDC")+"' " + Enter
	cSql += "                     AND C0.C0_FILIAL = '"+XFILIAL("SC0")+"' " + Enter
	cSql += "                     AND DC.DC_LOCAL = C0.C0_LOCAL " + Enter
	cSql += "                     AND DC.DC_PEDIDO = C0.C0_NUM " + Enter
	cSql += "                     AND DC.DC_PRODUTO = C0.C0_PRODUTO " + Enter
	cSql += "                     AND DC.DC_ORIGEM = 'SC0' " + Enter
	cSql += "                     AND C0.C0_YPEDIDO NOT IN (SELECT C5_NUM FROM "+RETSQLNAME("SC5")+" C5 " + Enter
	cSql += "                                               WHERE C5_FILIAL='"+XFILIAL("SC5")+"' " + Enter
	cSql += "                                                     AND D_E_L_E_T_ = '') " + Enter
	cSql += "               GROUP BY DC.DC_PRODUTO) R " + Enter
	cSql += "          ON B1.B1_COD = R.DC_PRODUTO " + Enter
	cSql += "WHERE B1.D_E_L_E_T_ = '' " + Enter
	cSql += "AND B1.B1_FILIAL = '"+XFILIAL("SB1")+"' " + Enter
	cSql += "AND SUBSTRING(B1.B1_COD,6,1) IN ('1') " + Enter
	cSql += "AND B1.B1_TIPO = 'PA' " + Enter
	cSql += "AND B1.B1_YREF <> '' " + Enter
	cSql += "AND B1.B1_YREFPV <> '' " + Enter
	//if MV_PAR01 = "04" AND MV_PAR02 = "04"
	//cSql += "      AND B1.B1_LOCPAD >='"+MV_PAR01+"' " + Enter
	//cSql += "      AND B1.B1_LOCPAD <= '"+MV_PAR02+"' " + Enter
	cSql += "AND SUBSTRING(B1.B1_YREF,8,32) = '"+REFER+"' " + Enter
	cSql += "GROUP BY SUBSTRING(B1.B1_COD,1,1), SUBSTRING(B1.B1_YREF,8,32) " + Enter
	cSql += "ORDER BY SUBSTRING(B1.B1_COD,1,1), SUBSTRING(B1.B1_YREF,8,32) " + Enter

	If chkfile("TAB2")
	dbSelectArea("TAB2")
	dbCloseArea()
	EndIf
	TcQuery cSql New Alias "TAB2" */


	//buscar quantidade da referencia
	SZ5->(DbSeek(XFilial("SZ5")+_AUX_PEDIDO->GRUPO))

	//calcular a referencia
	nResult := _AUX_PEDIDO->ESTOQUE - _AUX_PEDIDO->PEDIDO - _AUX_PEDIDO->RESERVA

	If nResult < SZ5->Z5_QTDREF //inicial
		cRef := SUBSTR(SZ5->Z5_YOBS,1,9)
	ElseIf nResult > SZ5->Z5_QTDEFIM //final
		cRef := "SIM   "
	ElseIf nResult >= SZ5->Z5_QTDREF .And. nResult <= SZ5->Z5_QTDEFIM
		cRef := SUBSTR(SZ5->Z5_YOBS,1,9)
	EndIf

RETURN(cRef)

//RETORNAR ID DO USUARIO 
Static Function GetID(cName)

	Local cUserId

	Begin Sequence

		PswOrder(2)
		IF !( PswSeek( cName ) )
			Break
		EndIF

		cUserId := PswRet(1)[1][1]

	End Sequence

Return( cUserId )
