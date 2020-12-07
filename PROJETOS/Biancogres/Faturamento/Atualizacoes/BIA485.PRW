#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "PROTHEUS.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA485     ³ Autor ³ WANISAY               ³ Data ³ 14/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ AXCADASTRO Liberação de Pedidos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIANCOGRES                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA485()

	Local aArea     := GetArea()
	Local aCores    := {}
	Local aIndDAK   := {}
	Local cCondicao := ""

	Private cCadastro 	:= "Liberação de Crédito de Pedidos de Venda"
	Private aRotina 	:= {	{"Pesquisa"  			,"AxPesqui"		,0,1},;
	{"Visualizar"			,"AxVisual"		,0,2},;
	{"Incluir"   			,"u_BIA485INC"	,0,3},;  
	{"Lib. Contratos" 		,"u_BIA485CTR"	,0,4},;  					
	{"Alterar"   			,"u_BIA485ALT"	,0,5},;							
	{"Excluir"   			,"u_BIA485EXC"	,0,6},;
	{"Imprimir Pedido"		,'u_BIA485IMP' ,0,7},;
	{"Legenda"   			,"u_BIA485LEG"	,0,8}}							
	//{"Alterar"   			,"AxAltera"		,0,5},;


	Private aCores		:= { 	{ "ZN_TIPO == '1'", 'BR_VERDE'  	},; //Pedido Normal
	{ "ZN_TIPO == '4'", 'BR_AZUL'  		},; //Termo Resp.
	{ "ZN_TIPO == '3'", 'BR_AMARELO'	},; //Del Créd.
	{ "ZN_TIPO == '2' .And. ZN_BLQPDCT <> 'S' ", 'BR_CINZA'  	},; //Contrato
	{ "ZN_TIPO == '5'", 'BR_PRETO'		},; //Engenharia
	{ "ZN_TIPO == '2' .And. ZN_BLQPDCT == 'S' ", 'BR_VERMELHO'	} } //Pedido de Contrato com Bloqueio

	DbSelectArea("SZN")
	DbSetOrder(1)                                    

	mBrowse(6,1,22,75,"SZN",,,,,,acores)   

Return()      

/*
##############################################################################################################
# PROGRAMA...: BIA485INC         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 10/09/2013                      
# DESCRICAO..: Antes era utilizado somente o AxInclui, agora precisa de ser gerado um Workflow para envio 
#			   informações referente a todo credito cadastrado para algum pedido
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
USer Function BIA485INC()
	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local nOpcao	:= 0
	Local cAlias	:= "SZN" 
	Private cMail	:= ''  //EMAILS QUE RECEBERAO O WORKFLOW

	nOpcao := AxInclui(cAlias)

	If nOpcao == 1   //INCLUSAO CONFIRMADA, CASO POSITIVO ENVIA EMAIL

		//Realiza a liberação para Pedidos de Contrato
		If Alltrim(SZN->ZN_TIPO) == "2"			    
			LibPedCT()		
			MsgInfo("O Pedido de Contrato foi liberado com sucesso!")		
		EndIf

		EmailAtendente()

		If !(Empty(cMail))	
			GeraEmail()
		Endif
		MsgInfo("Operacao realizada com sucesso!")

	Endif

	RestArea(aArea)

Return lRet


/*
##############################################################################################################
# PROGRAMA...: BIA485ALT         
# AUTOR......: Ranisses
# DATA.......: 10/11/2015
# DESCRICAO..: 
#			   
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
USer Function BIA485ALT()
	Local lRet		 := .T.
	Local aArea		 := GetArea()
	Local nOpcao	 := 0
	Private aCpos	 := {"ZN_DATAINI","ZN_DATALIM","ZN_OBS","ZN_VALOR"}  // CAMPOS que permite edição
	Private aButtons := {}

	aAdd( aButtons, { "PEDIDO", {|| wVisual() }, "Pedido", "Visual. Pedido" } ) 

	nOpcao := AxAltera("SZN",SZN->(Recno()),4,,aCpos,,,,"U_BIA485TRS",,aButtons,,,,.T.,,,,,)

	If nOpcao == 1
		MsgInfo("Operacao realizada com sucesso!")
	EndIf

	RestArea(aArea)

Return lRet

/*
##############################################################################################################
# PROGRAMA...: BIA485EXC
# AUTOR......: Ranisses
# DATA.......: 10/11/2015
# DESCRICAO..: 
#			   
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
USer Function BIA485EXC()
	Local lRet		 := .T.
	Local aArea		 := GetArea()

	AxDeleta("SZN",SZN->(Recno()),5)

	RestArea(aArea)

Return lRet               

/*
##############################################################################################################
# PROGRAMA...: BIA485IMP
# AUTOR......: Ranisses
# DATA.......: 21/12/2015
# DESCRICAO..: 
##############################################################################################################
*/
USer Function BIA485IMP()
	Local lRet		 := .T.

	//Chama rotina de impressão
	U_BIAFR006()

Return lRet

/*
##############################################################################################################
# PROGRAMA...: BIA485_CT         
# AUTOR......: Ranisses A. Corona
# DATA.......: 09/10/2015	                      
# DESCRICAO..: 
#			   
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
USer Function BIA485CTR()
	Local aArea		:= GetArea()
	Local cAlias	:= "SZN"           
	Local cSql		:= ""

	//Realiza a liberação para Pedidos de Contrato
	If Alltrim(SZN->ZN_TIPO) <> "2"			    
		MsgInfo("Esta opção está disponível apenas para Pedidos de Contrato!")		
		Return
	EndIf

	//Somente Pedido de Contrato com Bloqueio
	If Alltrim(SZN->ZN_BLQPDCT) <> "S"			    
		MsgInfo("Não existem liberações pendentes para este Pedido!")		
		Return
	EndIf

	//Rotina de Liberação 
	fBlqCont()

Return

/*
##############################################################################################################
# PROGRAMA...: EmailAtendente
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 10/09/2013                    
# DESCRICAO..: BUSCAR QUAL E O ATENDENTE DE ACORDO COM A LINHA DE PRODUTO/VENDEDOR NO PEDIDO DE VENDA
##############################################################################################################     
*/
Static Function EmailAtendente()

	Local cAtendente := '' 
	Local cVendedor := ''
	Local cTpSeg := ''
	Local cLinha := ''
	Local lAchou := .F.

	//TIPO DE SEGMENTO
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+SZN->ZN_CLIENTE+SZN->ZN_LOJA)
		cTpSeg := SA1->A1_YTPSEG
	EndIf
	DbCloseArea("SA1")

	//BUSCA DADOS PELO PEDIDO
	DbSelectArea("SC5")
	DbSetOrder(1)
	If (DbSeek(xFilial("SC5")+SZN->ZN_PEDIDO))    
		cVendedor := SC5->C5_VEND1
		cLinha := Alltrim(SC5->C5_YLINHA)
	Else                     
		//SE NAO ENCONTRAR BUSCA PELO ORCAMENTO
		DbSelectArea("SCJ")
		DbSetOrder(1)
		If (DbSeek(xFilial("SC5")+SZN->ZN_PEDIDO+SZN->ZN_CLIENTE+SZN->ZN_LOJA))   
			cVendedor := SCJ->CJ_YVEND 
			cLinha := Alltrim(SCJ->CJ_YLINHA)
		EndIf
	EndIf
	
	oGerenteAtendente	:= TGerenteAtendente():New()
	oResult 			:= oGerenteAtendente:GetCliente(SC5->C5_YEMP, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_VEND1)
	cMail				:= oResult:cEmailAten
	
	If (Empty(cMail))
		MsgInfo("Falha ao Carregar Pedido para Envio de Workflow")
	EndIf  
	
	/*If !(Empty(cVendedor)) 
		//SE FOR EMPRESA LM, TRATATIVA DIFERENTE PARA BUSCAR DADOS NA TABELA ZZI
		If cEmpAnt =='07'	

			cQuery := ""
			cQuery += " SELECT * FROM "

			//EMAIL CONFIGURADO DE ACORDO COM A EMPRESA	
			Do Case
				Case cLinha == '1' 
				cQuery += " ZZI010 ZZI"

				Case cLinha == '2' 
				cQuery += " ZZI050 ZZI"

				Case cLinha == '3' 
				cQuery += " ZZI050 ZZI"

			EndCase

			//cQuery += "WHERE ZZI.ZZI_FILIAL = '" +xFilial("ZZI")+"' AND "
			cQuery += " WHERE ZZI.ZZI_VEND =  '" +cVendedor+ "' AND "
			cQuery += " ZZI.D_E_L_E_T_= '' "

			TCQUERY cQuery ALIAS "QRY" NEW   

			WHILE !QRY->(EOF())

				If(QRY->ZZI_TPSEG == cTpSeg)
					cAtendente := QRY->ZZI_ATENDE
					lAchou := .T.
				EndIf 

				If lAchou
					exit
				EndIf

				QRY->(DBSKIP())		
			ENDDO 

			If lAchou
				cMail := Alltrim(UsrRetMail(cAtendente))  //RETORNAR EMAIL DO USUARIO PASSANDO LOGIN COMO PARAMETRO
			Else
				MsgInfo("Falha ao Carregar o Atendente para Envio de Workflow")
			EndIf	    

			QRY->(DbCloseArea())

		Else
			//BUSCAR ATENDENTE DE ACORDO COM O VENDEDOR
			DbSelectArea("ZZI")
			DbSetOrder(1)
			If (DbSeek(xFilial("ZZI")+cVendedor))      

				//BUSCAR ATENDENTE DE ACORDO COM O SEGMENTO		
				While ZZI->(!Eof())
					If(ZZI->ZZI_TPSEG == cTpSeg)
						cAtendente := ZZI->ZZI_ATENDE
						lAchou := .T.
					EndIf 

					If lAchou
						exit
					EndIf

					ZZI->(DbSkip())
				EndDo
				  
			Else
				MsgInfo("Falha ao Carregar o Atendente para Envio de Workflow")
			EndIf	     

			cMail := Alltrim(UsrRetMail(cAtendente))  //RETORNAR EMAIL DO USUARIO PASSANDO LOGIN COMO PARAMETRO
		EndIf
	Else
		MsgInfo("Falha ao Carregar Pedido para Envio de Workflow")
	EndIf  
	*/

	DbCloseArea("SC5")
	DbCloseArea("SCJ")
	//DbCloseArea("ZZI")

Return   


/*
##############################################################################################################
# PROGRAMA...: GeraEmail
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 10/09/2013                    
# DESCRICAO..: Rotina para Criacao do HTML para envio do workflow
##############################################################################################################     
*/
Static Function GeraEmail()

	Local cTIpo:= ''
	Private C_HTML 
	Private cTItulo := 'Cadastro de Crédito para o Pedido Num: '+(SZN->ZN_PEDIDO) 

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
		C_HTML += '  <th scope="col"><img width="100" height="70" src="\\srv_app_protheus\PROTHEUS11\PROTHEUS_DATA\Sigaadv\logomarca_biancogres.jpg" / align="left"> <div align="right">CADASTRO DE CRÉDITO - PEDIDO DE VENDA - '+(SZN->ZN_PEDIDO)+'<br>'			
		CASE cEmpAnt = "05"   
		C_HTML += '  <th scope="col"><img width="100" height="70" src="\\srv_app_protheus\PROTHEUS11\PROTHEUS_DATA\Sigaadv\logomarca_incesa.jpg" / align="left"> <div align="right">CADASTRO DE CRÉDITO - PEDIDO DE VENDA - '+(SZN->ZN_PEDIDO)+'<br>'			
		OTHERWISE
		C_HTML += '  <th scope="col"><img src="\\srv_app_protheus\PROTHEUS11\PROTHEUS_DATA\Sigaadv\lgrl'+cEmpAnt+'.bmp" / align="left"> <div align="right">CADASTRO DE CRÉDITO - PEDIDO DE VENDA - '+(SZN->ZN_PEDIDO)+'<br>'			
	ENDCASE                              

	C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	//DADOS DO CLIENTE	 

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SZN->ZN_CLIENTE+SZN->ZN_LOJA)
	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                        
	C_HTML += '<font color="white"> '		
	C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col"> DADOS DO CLIENTE:  </th> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '        

	C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> CLIENTE: <b>'+Alltrim(SA1->A1_NOME)+'</b></td> '
	C_HTML += '    <td><div align="left"> CÓDIGO: <b>'+Alltrim(SA1->A1_COD)+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> ENDEREÇO: <b>'+Alltrim(SA1->A1_END)+'</b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> BAIRRO: <b>'+Alltrim(SA1->A1_BAIRRO)+'</b></td> '
	C_HTML += '    <td><div align="left"> CIDADE: <b>'+Alltrim(SA1->A1_MUN)+'</b></td> '
	C_HTML += '    <td><div align="left"> UF: <b>'+Alltrim(SA1->A1_EST)+'</b></td> '
	C_HTML += '  </tr> ' 
	C_HTML += '<tr> '
	If(Alltrim(SA1->A1_PESSOA)=='J')
		C_HTML += '    <td><div align="left"> CNPJ: <b>' + TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99") +'<b></td> '
		If !Empty(SA1->A1_INSCR)
			C_HTML += '    <td><div align="left"> I.E.: <b>' + SA1->A1_INSCR +'<b></td> '
		EndIf                                                                            
	Else
		C_HTML += '    <td><div align="left"> CPF: <b>' + TRANSFORM(SA1->A1_CGC,"@R 999.999.999-99") +'<b></td> '
	EndIf           
	C_HTML += '    <td><div align="left"> CEP: <b>' + SA1->A1_CEP +'<b></td> '             
	C_HTML += '  </tr> ' 
	C_HTML += '  <tr> ' 
	C_HTML += '    <td><div align="left"> COMPRADOR: <b>' + Alltrim(SA1->A1_CONTATO) +'<b></td> '
	C_HTML += '    <td><div align="left"> TELEFONE: <b>' + SA1->A1_TEL +'<b></td> '
	C_HTML += '    <td><div align="left"> FAX: <b>' + SA1->A1_FAX +'<b></td> '
	C_HTML += '  </tr> ' 
	C_HTML += '  <tr> ' 
	C_HTML += '    <td><div align="left"> E-MAIL: <b>' + Alltrim(SA1->A1_EMAIL) +'<b></td> '
	C_HTML += '  </tr> ' 

	C_HTML += '</font>'        
	C_HTML += '</table> '   

	//INFORMACOES DO CREDITO	
	C_HTML += '<br> '       
	C_HTML += '<BR>'        

	C_HTML += '<table width="900" border="0" bgcolor="black"> '
	C_HTML += '  <tr> '                                        
	C_HTML += '<font color="white"> '

	C_HTML += '</font>'            
	C_HTML += '</tr> '             
	C_HTML += '</table> '

	C_HTML += '<table width="900" border="0" bgcolor="#00FA9A"> '
	C_HTML += '<font color="black"> '                          
	C_HTML += '<tr> '
	C_HTML += '    <th width="900" scope="col"> INFORMAÇÕES DO CRÉDITO:  </th> '
	C_HTML += '    <td>&nbsp;</td> '
	C_HTML += '  </tr> '
	C_HTML += '</font>'        
	C_HTML += '</table> '        

	C_HTML += '<table width="900" border="0" cellspacing="0" cellpadding="2"> '
	C_HTML += '<font color="black" size="2"> ' 
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> NÚMERO DO PEDIDO: <b>'+SZN->ZN_PEDIDO+' </b></td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> DATA INICIO: <b>'+ SUBSTR( DTOS(SZN->ZN_DATAINI),7,2)+"/"+SUBSTR( DTOS(SZN->ZN_DATAINI),5,2)+"/"+SUBSTR( DTOS(SZN->ZN_DATAINI),1,4) +'</b></td> '  
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> DATA LIMITE: <b>'+ SUBSTR( DTOS(SZN->ZN_DATALIM),7,2)+"/"+SUBSTR( DTOS(SZN->ZN_DATALIM),5,2)+"/"+SUBSTR( DTOS(SZN->ZN_DATALIM),1,4) +'</b></td> '  
	C_HTML += '  </tr> '
	C_HTML += '<tr> '       

	If(SZN->ZN_TIPO == '1')
		cTIpo := 'Pedido Normal'
	EndIf
	If(SZN->ZN_TIPO == '2')
		cTIpo := 'Contrato'
	EndIf
	If(SZN->ZN_TIPO == '3')
		cTIpo := 'Del Credere'
	EndIf

	C_HTML += '    <td><div align="left"> TIPO DE LIBERAÇÃO: <b>'+cTIpo+' </b> </td> '
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> VALOR LIBERADO: <b>'+ TRANSFORM(SZN->ZN_VALOR	,"@E 99,999,999.99")+' </b></td> ' 
	C_HTML += '  </tr> '
	C_HTML += '<tr> '
	C_HTML += '    <td><div align="left"> OBSERVAÇÃO: <b>'+SZN->ZN_OBS+' </b></td>  '
	C_HTML += '  </tr> '

	C_HTML += '</font>'        
	C_HTML += '</table> '   

	C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '     
	C_HTML += '<p>&nbsp;	</p> '
	C_HTML += '</body> '
	C_HTML += '</html> '

	DbCloseArea("SA1") 

	SendMail()

Return


/*
##############################################################################################################
# PROGRAMA...: SendMail
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 10/09/2013                    
# DESCRICAO..: Rotina para Criacao do HTML para envio do workflow
##############################################################################################################     
*/                       
Static Function SendMail()     
	Local lOK        := .F.

	lOK := U_BIAEnvMail(,ALLTRIM(cMail),cTitulo,C_HTML)

	IF !lOK
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA485")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA485")
	ENDIF

RETURN                          

/*
##############################################################################################################
# PROGRAMA...: LibPedCT
# AUTOR......: Ranisses A. Corona
# DATA.......: 01/01/2015                    
# DESCRICAO..: Rotina para aprovação do crédito dos pedidos de Contrato
##############################################################################################################     
*/                       
Static Function LibPedCT()     

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+SZN->ZN_PEDIDO))	
		While !SC6->(Eof()) .And. SC6->C6_NUM == SZN->ZN_PEDIDO
			RecLock("SC6",.F.)
			SC6->C6_YVALOR	:= SC6->C6_VALOR
			SC6->C6_YENTREG	:= SC6->C6_YDTNECE //SC6->C6_ENTREG	
			SC6->(MsUnlock())		
			SC6->(DbSkip())
		EndDo
	EndIf

Return


/*
##############################################################################################################
# PROGRAMA...: BIA485LEG
# AUTOR......: Ranisses A. Corona
# DATA.......: 14/10/2015
# DESCRICAO..: Lengenda para facilitar a indenticação dos Pedidos por Tipo
##############################################################################################################     
*/                       
User Function BIA485LEG()     

	aLegenda := {	{ "BR_VERDE"	,	"Pedido Normal"				},;
	{ "BR_AZUL"		,   "Pedido com Termo Resp."	},;
	{ "BR_AMARELO"	,   "Pedido de Del Credere"		},;
	{ "BR_CINZA"	,   "Pedido de Contrato" 		},;								
	{ "BR_PRETO"	,	"Pedido de Engenharia"		},;
	{ "BR_VERMELHO"	,	"Pedido de Contrato com Bloqueio" } }

	BRWLEGENDA( cCadastro, "Legenda", aLegenda )

Return(.T.)


/*
##############################################################################################################
# PROGRAMA...: fBlqCont
# AUTOR......: Ranisses A. Corona
# DATA.......: 23/10/2015
# DESCRICAO..: Rotina de Liberação de Pedidos
##############################################################################################################     
*/                       
Static Function fBlqCont()
	Local cSql		:= ""
	Local nMotivo	:= ""
	Local aStru 	:= {} 			//estrutura do temporario 
	Local aCpoBro 	:= {} 			//array do browse para demonstracao das empresas 
	Private nQtdPed	:= 0			//Quantidade de Itens de Pedido / Utilizado para controle do campo ZN_BLQPDCT
	Private aPedido	:= {} 			//array de retorno com os pedidos escolhidos
	Private lInverte:= .F. 			//Variaveis para o MsSelect 
	Private cMarca 	:= GetMark() 	//Variaveis para o MsSelect 
	Private oMark	 				//objeto do msselect 
	Private oDlg

	//Define campos do TRB 
	AADD(aStru,{"_OK"		,"C",02,0})
	AADD(aStru,{"PEDIDO"	,"C",06,0})
	AADD(aStru,{"PRODUTO"	,"C",15,0})
	AADD(aStru,{"LOTE"		,"C",06,0})
	AADD(aStru,{"ITEM"		,"C",03,0})
	AADD(aStru,{"DESCRICAO"	,"C",30,0})
	AADD(aStru,{"QTDLIBER"  ,"N",14,2})
	AADD(aStru,{"VLRLIBER"  ,"N",14,2})
	AADD(aStru,{"MOTBLOQ"	,"C",40,0})
	AADD(aStru,{"RECNO"		,"N",10,0})
	If chkfile("cTrab")
		dbSelectArea("cTrab")
		dbCloseArea()
	EndIf
	cTrab := Criatrab(aStru,.T.)
	dbUseArea(.T.,,cTrab,"cTrab",.F.,.F.)

	//Define campos do MarkBrowser
	aCpoBro	  := 	{ 	{ "_OK"			,,"  "           	,"@!"},;
	{ "PEDIDO"		,,"PEDIDO"      	,"@!"},;
	{ "PRODUTO"    	,,"PRODUTO"       	,"@!"},;
	{ "LOTE"		,,"LOTE"	      	,"@!"},;
	{ "ITEM"		,,"ITEM"			,"@!"},;
	{ "DESCRICAO"	,,"DESCRIÇÃO"  		,"@!"},;
	{ "QTDLIBER"	,,"QTD.LIBER.(M2)" 	,"@E 999,999.99"},;
	{ "VLRLIBER"	,,"VLR.LIBER.(R$)" 	,"@E 999,999.99"},;
	{ "MOTBLOQ"		,,"MOT. BLOQ." 		,"@!"},;
	{ "RECNO"		,,"RECNO" 			,"@E 999999"} }


	If cEmpAnt == "07" .And. SZN->ZN_PEDIDO <> "010064"
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+SZN->ZN_PEDIDO))	
			//Seleciona Pedidos para MarkBrowser
			cSql := "SELECT SC6_7.C6_YVLIMP/(SC6.C6_QTDVEN/C9_QTDLIB) VALOR, SC9.* "
			cSql += "FROM SC6"+SC5->C5_YEMPPED+"0 SC6 INNER JOIN SC9"+SC5->C5_YEMPPED+"0 SC9 ON "
			cSql += "     C6_NUM	= C9_PEDIDO		AND "
			cSql += "	  C6_PRODUTO = C9_PRODUTO	AND "
			cSql += "	  C6_ITEM	= C9_ITEM "
			cSql += "	INNER JOIN SC6070 SC6_7 ON
			cSql += "	  SC6_7.C6_NUM	 = '"+SZN->ZN_PEDIDO+"' AND 
			cSql += "	  SC6.C6_PRODUTO = SC6_7.C6_PRODUTO AND 
			cSql += "	  SC6.C6_ITEM    = SC6_7.C6_ITEM       
			cSql += "WHERE	SC9.C9_PEDIDO = '"+SC5->C5_YPEDORI+"' AND  "
			cSql += "		SC9.C9_YDTBLCT <> '' AND  "
			cSql += "		SC9.C9_YDTLICT = '' AND "
			cSql += "		SC6.D_E_L_E_T_ = '' AND "
			cSql += "		SC6_7.D_E_L_E_T_ = '' AND "
			cSql += "		SC9.D_E_L_E_T_ = '' "
		EndIf
	Else
		//Seleciona Pedidos para MarkBrowser
		cSql := "SELECT C6_YVLIMP/(C6_QTDVEN/C9_QTDLIB) VALOR, SC9.* "
		cSql += "FROM "+RetSqlName("SC6")+" SC6 INNER JOIN "+RetSqlName("SC9")+" SC9 ON "
		cSql += "     C6_NUM	= C9_PEDIDO		AND "
		cSql += "	 C6_PRODUTO = C9_PRODUTO	AND "
		cSql += "	 C6_ITEM	= C9_ITEM "
		cSql += "WHERE	SC9.C9_PEDIDO = '"+SZN->ZN_PEDIDO+"' AND  "
		cSql += "		SC9.C9_YDTBLCT <> '' AND  "
		cSql += "		SC9.C9_YDTLICT = '' AND "
		cSql += "		SC6.D_E_L_E_T_ = '' AND "
		cSql += "		SC9.D_E_L_E_T_ = '' "
	EndIf
	If chkfile("_SC9")
		dbSelectArea("_SC9")
		dbCloseArea()
	EndIf
	TCQuery cSQL Alias "_SC9" New

	While !_SC9->(EOF())  

		//	
		nQtdPed := nQtdPed + 1

		//Motivo de Bloqueio
		If _SC9->C9_YTPBLCT == "061"
			nMotivo := "ALTERAÇÃO NA DATA DE ENTREGA APROVADA"
		ElseIf _SC9->C9_YTPBLCT == "062"
			nMotivo := "ALTERAÇÃO NO VALOR APROVADO"
		ElseIf _SC9->C9_YTPBLCT == "063"
			nMotivo := "LIBERADO ANTES DA DATA DE NECESSIDADE"
		ElseIf _SC9->C9_YTPBLCT == "064"
			nMotivo := "TITULO DE CONTRATO EM ATRASO"
		EndIf

		RecLock("cTrab",.T.)
		ctrab->_OK			:=  space(2)
		cTrab->PEDIDO		:=  _SC9->C9_PEDIDO
		cTrab->PRODUTO 	 	:=  _SC9->C9_PRODUTO
		cTrab->LOTE			:=  _SC9->C9_LOTECTL
		cTrab->ITEM	   		:=  _SC9->C9_ITEM
		cTrab->DESCRICAO	:=  _SC9->C9_YNOMPRD
		cTrab->QTDLIBER 	:=  _SC9->C9_QTDLIB
		cTrab->VLRLIBER 	:=  _SC9->VALOR
		cTrab->MOTBLOQ 		:=  nMotivo
		cTrab->RECNO		:=  _SC9->R_E_C_N_O_   
		cTrab->(MsUnLock())

		_SC9->(dbSkip())
	End                     

	_SC9->(DbCloseArea())

	cTrab->(DbGotop())

	DEFINE MSDIALOG oDlg TITLE "Pedidos de Contrato com Bloqueio" FROM 000, 000  TO 250, 900 COLORS 0, 16777215 PIXEL //From 009,000 To 040,140
	@005,008   Say "Pedidos de Contrato com Bloqueio:"
	@105,370   BUTTON oButton1 PROMPT "Lib. Pedidos" SIZE 037, 012 OF oDlg ACTION fProcOk() PIXEL
	@105,410   BUTTON oButton2 PROMPT "Cancelar"	 SIZE 037, 012 OF oDlg ACTION fSair() PIXEL
	oMark 		:= MsSelect():New("CTRAB","_OK","",aCpoBro,@lInverte,@cMarca,{016,009,090,440})
	oMark:bMark	:= {|| fDisp()}
	ACTIVATE MSDIALOG oDlg CENTERED

Return

//---------------------------------------------------------------------
//Armazena RECNO selecionado para liberação
//---------------------------------------------------------------------
Static Function fDisp()
	Local nPos := ""

	If !Empty(CTRAB->_OK)//se usuario marcou o registro
		AADD(aPedido,CTRAB->RECNO)
	Else
		nPos	:= aScan(aPedido,CTRAB->RECNO)
		If !Empty(nPos)
			//ADEL(aPedido, nPos)
			aPedido[nPos] := 0
		EndIf
	EndIf

Return


//---------------------------------------------------------------------
//Libera Pedidos selecionados
//---------------------------------------------------------------------
Static Function fProcOk()
	Local nCount := 0
	Local nQtPed := 0 //Quantidade de Itens Marcados
	Local nRecno := ""
	Local cSql   := ""
	Local I

	Close(oDlg)

	//Monta arquvivos dos Titulos para Inclusao
	nCount := Len(aPedido)
	For I := 1 TO nCount
		If aPedido[I] > 0
			nQtPed := nQtPed + 1
		EndIf	
		If nCount == 1
			nRecno := nRecno + "('"+Alltrim(Str(aPedido[I]))+"')"
		EndIf
		If (nCount > 1) .And. (I == 1)
			nRecno := nRecno + "('"+Alltrim(Str(aPedido[I]))+"',"
		EndIf
		If (nCount > 1) .And. (I > 1) .And. (I < nCount)
			nRecno := nRecno + "'"+Alltrim(Str(aPedido[I]))+"',"
		EndIf
		If (nCount > 1) .And. (I > 1) .AND. (I == nCount)
			nRecno := nRecno + "'"+Alltrim(Str(aPedido[I]))+"')"
		EndIf
	Next

	//Realiza Liberação dos Pedidos Selecionados
	If !Empty(Alltrim(nRecno)) 
		If cEmpAnt == "07" .And. SZN->ZN_PEDIDO <> "010064"
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+SZN->ZN_PEDIDO))	
				cSql := "UPDATE SC9"+SC5->C5_YEMPPED+"0 SET C9_YDTLICT = '"+Dtos(dDataBase)+"', C9_MSEXP = '' " 
				cSql += "WHERE	C9_FILIAL  = '"+xFilial("SE1")+"' 	AND " 
				cSql += "		R_E_C_N_O_ IN "+nRecno+"			AND	" 
				cSql += "		D_E_L_E_T_ = ''							" 
			EndIf		
		Else
			cSql := "UPDATE "+RetSqlName("SC9")+" SET C9_YDTLICT = '"+Dtos(dDataBase)+"', C9_MSEXP = '' " 
			cSql += "WHERE	C9_FILIAL  = '"+xFilial("SE1")+"' 	AND " 
			cSql += "		R_E_C_N_O_ IN "+nRecno+"			AND	" 
			cSql += "		D_E_L_E_T_ = ''							" 
		EndIf
		If (TCSQLExec(cSql) < 0)
			MsgStop("TCSQLError() " + TCSQLError())
		Else
			If nQtdPed == nQtPed
				RecLock("SZN",.F.)
				SZN->ZN_BLQPDCT	:= "N"
				SZN->(MsUnlock())		
				SZN->(DbSkip())
			EndIf
			MsgBox("Liberação realizada com sucesso!","BIA485","INFO")	
		EndIf
	EndIf

	//Fecha arquivo temporario
	If Select("CTRAB") > 0
		DbSelectArea("CTRAB") 
		DbCloseArea() 
		Ferase(cTrab+OrdBagExt()) 
	Endif

Return


//---------------------------------------------------------------------
//Fecha tela e arquivo temporarios
//---------------------------------------------------------------------
Static Function fSair()

	//Fecha Tela
	Close(oDlg)

	//Fecha arquivo temporario
	If Select("CTRAB") > 0
		DbSelectArea("CTRAB") 
		DbCloseArea() 
		Ferase(cTrab+OrdBagExt()) 
	Endif

Return


//---------------------------------------------------------------------
//
//---------------------------------------------------------------------
User Function BIA485TRS()
	Local lRet  := .F.
	Local lAprv := .F.

	//Se for pedido de Contrato
	If Alltrim(SZN->ZN_TIPO) == "2" 

		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(xFilial("SC6")+SZN->ZN_PEDIDO))	
			While !SC6->(Eof()) .And. SC6->C6_NUM == SZN->ZN_PEDIDO .And. !lAprv
				If SC6->C6_YVALOR <> 0 .Or. !Empty(Alltrim(SC6->C6_YENTREG))
					lAprv := .T.
				EndIf
				SC6->(DbSkip())
			EndDo
		EndIf

		If lAprv	
			If MsgBox("Este Pedido de Contrato, já foi aprovado. Deseja atualizar com as informações atuais? ","BIA485","YesNo")
				LibPedCT() 
				SZN->ZN_BLQPDCT := "N"
			EndIf
		EndIf

	EndIf

Return .T. 

//*******************************************************
//**  wVisual()						                   **
//*******************************************************
Static Function wVisual()

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(XFilial("SC5")+SZN->ZN_PEDIDO))              
	A410Visual("SC5",SC5->(RecNo()),2)

Return