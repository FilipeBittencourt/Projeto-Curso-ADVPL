#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: EXPVISION         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 03/02/2014                      
# DESCRICAO..: Rotina para exportacao de dados do produto para o Vision. Chamado no cadastro de novos produtos			 
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function EXPVISION() 

	Local aArea := GetArea()

	PRIVATE cBaseVision     
	PRIVATE cQry
	PRIVATE ENTER		:= CHR(13)+CHR(10)  
	PRIVATE cLinha
	PRIVATE cDescTamProd 
	PRIVATE cDescTamPallets
	PRIVATE cRef_produtos
	PRIVATE cAlias
	PRIVATE cBlql 
	PRIVATE xChave
	PRIVATE lRet := .T.   
	 
	cBaseVision := "ZEUS.DADOSVISIONCER.dbo"                  

	If cEmpant != '01'
		RestArea(aArea)
		return lRet
	EndIf

	//ALTERACAO DE FORMATO DE PRODUTOS
	If (FunName() == "BIA411") 

		LoadVar('ZZ6')

		cQry := ""
		cQry +=" SELECT *" 
		cQry +=" FROM "+cBaseVision+".FORM001 "
		cQry +=" WHERE  FR_CODIGO = '"+Alltrim(M->ZZ6_COD)+"' "

		TCQUERY cQry ALIAS "QRY" NEW   

		If(QRY->(EOF()))					//SE FORMATO NAO EXISTIR NO VISION
			EXPVISION1("FORM001")			//INCLUI FORMATO 
		Else 
			EXPVISION1("FORM001",.T.)		//ALTERA FORMATO 
		EndIf                               

		QRY->(DbCloseArea())

		RestArea(aArea)                	                              
		return lRet
	EndIf

	LoadVar('SB1')

	//ITENS DA FAMILIA E PRODUTO CADASTRADOS NO VISION?  
	If(Len(Alltrim(&(cAlias+"B1_COD"))) == 7) .And. (Substr(Alltrim(&(cAlias+"B1_COD")),4,4) == Alltrim(&(cAlias+"B1_YLINHA")))	
		//	- PRO001: Produtos
		cQry := ""
		cQry +=" SELECT * "          
		cQry +=" FROM "+cBaseVision+".PRO001 "
		cQry +=" WHERE  PR_REF = '"+Alltrim(&(cAlias+"B1_COD"))+"' "

		TCQUERY cQry ALIAS "QRY" NEW   

		If(QRY->(EOF()))                  //INCLUSAO
			EXPVISION1("PRO001")		 //INSERE PRODUTO NO VISION
		Else   
			EXPVISION1("PRO001",.T.)		//ALTERA PRODUTO NO VISION
		EndIf                                                         

		QRY->(DbCloseArea())       

		//	- FORM001: FORMATO
		If (!Empty(&(cAlias+"B1_YFORMAT")))        

			DbSelectArea("ZZ6")
			DbSetOrder(1)
			DbSeek(xFilial("ZZ6")+&(cAlias+"B1_YFORMAT"))
			//FORMATO-ZZ6 = TAMANHO
			cQry := ""
			cQry +=" SELECT *" 
			cQry +=" FROM "+cBaseVision+".FORM001 "
			cQry +=" WHERE  FR_CODIGO = '"+Alltrim(ZZ6->ZZ6_COD)+"' "

			TCQUERY cQry ALIAS "QRY" NEW   

			LoadVar('ZZ6',.T.)

			If(QRY->(EOF())) 
				EXPVISION1("FORM001")   	//INSERE FORMATO NO VISION
			Else
				EXPVISION1("FORM001",.T.)  	//ALTERA FORMATO NO VISION
			EndIf                               

			QRY->(DbCloseArea())                
			ZZ6->(DbCloseArea())	                                 

		EndIf		
	EndIf    	   

	RestArea(aArea)

Return lRet    

/*
##############################################################################################################
# PROGRAMA...: EXPV1         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 03/02/2014                      
# DESCRICAO..: FUNCAO PARA EXECUTAR O INSERT NAS TABELAS DO EXPVISION	 				 
##############################################################################################################
*/
Static Function EXPVISION1(cTabVision,lAltera)   

	Local cSql := ""
	Local cRef_produtos := ''        

	Do Case
		Case cTabVision == "PRO001" .And. !lAltera

		//CONSULTAR CADASTRO DE CLASSE/REFERENCIA ZZ8  - B1_YCLASSE (CHAVE ESTRANGEIRA) 
		If (!Empty(&(cAlias+"B1_YCLASSE")))	                                 

			DbSelectArea("ZZ8")
			DbSetOrder(1)
			If (DbSeek(xFilial("ZZ8")+&(cAlias+"B1_YCLASSE")))		
				cRef_produtos := Substr(Alltrim(ZZ8->ZZ8_DESC),1,30)		
			EndIf                           

			ZZ8->(DbCloseArea())

		EndIf	 

		cSql := ""
		cSql += "INSERT INTO "+cBaseVision+"."+cTabVision+ " (PR_ATIVO,PR_REF,PR_DESCRICAO,PR_CREATEDBY,PR_CREATEDDATA) VALUES " +ENTER
		cSql += " (1,'"+Alltrim(&(cAlias+"B1_COD"))+"','"+Substr(Alltrim(&(cAlias+"B1_DESC")),1,200)+"',1, "
		cSql += " '"+DtoS(dDatabase)+" "+time()+"') "			

		Case cTabVision == "FORM001" .And. !lAltera 
		If VldChave("UNLN001")   //VALIDACAO DA CHAVE ESTRANGEIRA - CAMPO FR_LINHA
			cSql := ""
			cSql += "INSERT INTO "+cBaseVision+"."+cTabVision+ " (FR_ATIVO,FR_DESCRICAO,FR_LINHA,FR_CREATEDBY,FR_CREATEDDATA,"
			cSql += " FR_PECA_N_CAIXA,FR_M2_N_CAIXA,FR_PECA_N_M2,FR_CODIGO) VALUES " +ENTER
			//cSql += " ("+cBlql+",'"+Alltrim(&(cAlias+"ZZ6_DESC"))+"',"+&(cAlias+"ZZ6_LINHA")+",1,'"+DtoS(dDatabase)+" "+time()+"', "
			cSql += " (1,'"+Alltrim(&(cAlias+"ZZ6_DESC"))+"',"+cValtoChar(xChave)+",1,'"+DtoS(dDatabase)+" "+time()+"', "
			cSql += " "+cValtoChar(&(cAlias+"ZZ6_PECA"))+","+cValtoChar(&(cAlias+"ZZ6_CONV"))+","+cValtoChar(&(cAlias+"ZZ6_NPM2"))+",'"+Alltrim(&(cAlias+"ZZ6_COD"))+"' )"			
		Else
			MsgStop("A Linha de Producao "+Alltrim(&(cAlias+"ZZ6_LINHA"))+" nao Esta Cadastrada no Vision.","Falha na Integracao")
			lRet := .F.
		EndIf		                    

		Case cTabVision == "PRO001" .And. lAltera
		cSql := ""
		cSql += "UPDATE "+cBaseVision+"."+cTabVision+ " SET PR_ATIVO = "+cBlql+", PR_DESCRICAO = '"+Substr(Alltrim(&(cAlias+"B1_DESC")),1,200)+"' " +ENTER
		cSql += " WHERE PR_REF = '"+Alltrim(&(cAlias+"B1_COD"))+"' "

		Case cTabVision == "FORM001" .And. lAltera     //CHAMADO PELA ROTINA BIA411
		cSql := ""
		cSql += "UPDATE "+cBaseVision+"."+cTabVision+" SET FR_ATIVO = "+cBlql+", FR_PECA_N_CAIXA = "+cValtoChar(&(cAlias+"ZZ6_PECA"))+", "
		cSql += " FR_M2_N_CAIXA = "+cValtoChar(&(cAlias+"ZZ6_CONV"))+",FR_PECA_N_M2 ="+cValtoChar(&(cAlias+"ZZ6_NPM2"))+", FR_DESCRICAO = '"+Alltrim(&(cAlias+"ZZ6_DESC"))+"' "+ENTER 
		cSql += " WHERE FR_CODIGO = '"+Alltrim(&(cAlias+"ZZ6_COD"))+"' "

	End Case              

	//TcSQLExec(cSql) 
	If !(Empty(cSql))
		If (TCSQLExec(cSql) < 0)
			//MsgStop("TCSQLError() " + TCSQLError())
			MsgStop("Erro ao Integrar com o Vision. Solicite a Equipe de TI que verifique o arquivo: SIGAADV\INTEGRACAO_VISION.TXT")
			//SALVAR LOG DE INTEGRACAO
			MemoWrite(GetSrvProfString ("STARTPATH","")+"\INTEGRACAO_VISION.TXT",TCSQLError()) 
			lRet := .F.   
		EndIf     
	EndIf

Return     


/*
##############################################################################################################
# PROGRAMA...: LOADVAR         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 07/02/2014                      
# DESCRICAO..: FUNCAO PARA AJUSTAR AS VARIAVEIS ANTES DE EXECUTAR O INSERT NAS TABELAS DO EXPVISION	 				 
##############################################################################################################
*/
Static Function LoadVar(cTabela,lBloq)

	If (cTabela == 'ZZ6')      
		If lBloq         
			cAlias := "ZZ6->"               
			cBlql	:= ZZ6->ZZ6_MSBLQL
		Else
			cAlias := "M->"               
			cBlql	:= M->ZZ6_MSBLQL
		EndIf

		If(cBlql == '2') .Or. Empty(cBlql)
			cBlql := '0'
		EndIf                                    
	Else
		If Inclui
			cAlias := "SB1->"	//INCLUSAO
		Else                  
			cAlias := "M->"     //ALTERACAO
		EndIf

		//ARMAZENAR SE REGISTRO ENCONTRA-SE BLOQUEADO OU NAO, NAO BLOQUEADO NO PROTHUES E 2 OU EM BRANCO, E NO VISION E 0
		cBlql	:= &(cAlias+"B1_MSBLQL")

		If(cBlql == '2') .Or. Empty(cBlql)
			cBlql := '0'
		EndIf

	EndIf

Return

/*
##############################################################################################################
# PROGRAMA...: VldChave         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 03/02/2014                      
# DESCRICAO..: FUNCAO PARA REALIZAR A VALIDACAO DE CHAVES ESTRANGEIRAS ANTES DE EXECURAR O INSERT
##############################################################################################################
*/
Static Function VldChave(cTabela)
	Local lRet                      

	Do Case
		Case cTabela == 'UNLN001'
		_cQry := ""
		_cQry +=" SELECT * "          
		_cQry +=" FROM "+cBaseVision+"."+cTabela
		_cQry +=" WHERE  UL_TAG = '"+Substr(&(cAlias+"ZZ6_LINHA"),3,Len(&(cAlias+"ZZ6_LINHA")))+"' "
	EndCase

	TCQUERY _cQry ALIAS "QRY_VLD" NEW   

	If(QRY_VLD->(EOF()))
		lRet := .F.
	Else
		lRet := .T.          
		If(cTabela == 'UNLN001')
			xChave := QRY_VLD->UL_ID
		EndIf
	EndIf                               
	QRY_VLD->(DbCloseArea())       

Return lret
