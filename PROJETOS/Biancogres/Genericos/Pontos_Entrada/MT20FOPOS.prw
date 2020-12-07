#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT20FOPOS
@author Luana Marin Ribeiro
@since 19/08/2015
@version 1.0
@description P.E. para gravações adicionais após o cadastro do Fornecedor 
@history 19/08/2015, Luana Marin Ribeiro, Verifica se a contábil do fornecedor foi gravada corretamente após a inclusão e caso contrario envia email.
@history 23/11/2017, Ranisses A. Corona, Foi incorporado o fonte MATA020.prw, pois segundo a Totvs estes fontes com nome da funcao não devem ser utilizados. 
@history 23/11/2017, Ranisses A. Corona, Tratamento para retirar do nome os caracteres com "Enter" ou "Tab" 
@type function
/*/

// Fonte Descontinuado - MVC_CUSTOMERVENDOR

/*
User Function MT20FOPOS
Local nOpcA :=PARAMIXB[1] //Incluir = 3 /Alterar = 4 /Excluir = 5

//Para Inclusão e Alteracao
If nOpcA <> 5

	RecLock('SA2',.F.)
	If nOpcA == 3
		//Grava o nome do Colaborador que esta realizando a inclusão do Cadastro	
		SA2->A2_YUSER := cUserName
	EndIf
	
	//Retira dos campos abaixo caracteres especiais (Enter=char(13) / Tab=char(9))	
	SA2->A2_NOME 	:= U_fDelTab(SA2->A2_NOME)
	SA2->A2_NREDUZ	:= U_fDelTab(SA2->A2_NREDUZ)	
	SA2->A2_NUMCON	:= U_fDelTab(SA2->A2_NUMCON)	
	SA2->A2_END		:= U_fDelTab(SA2->A2_END) 
	SA2->A2_TEL		:= U_fDelTab(SA2->A2_TEL)
	SA2->A2_TELEX	:= U_fDelTab(SA2->A2_TELEX)
	SA2->A2_FAX		:= U_fDelTab(SA2->A2_FAX)
	SA2->A2_CONTATO	:= U_fDelTab(SA2->A2_CONTATO)
	SA2->A2_EMAIL	:= U_fDelTab(SA2->A2_EMAIL)
	SA2->A2_HPAGE	:= U_fDelTab(SA2->A2_HPAGE)
	SA2->A2_COMPLEM	:= U_fDelTab(SA2->A2_COMPLEM)			
	SA2->(MsUnLock())	

	//Inclui Conta Contabil  
	ATUALIZA_CT1()

EndIf

//Para Inclusão
If nOpcA == 3 
	
	//Verifica se conta contábil foi preenchida, se não tiver sido preenchida, envia e-mail informando
	If AllTrim(SA2->A2_CONTA)==""
		cDP100110 := '<html xmlns="http://www.w3.org/1999/xhtml">'
		cDP100110 += '<head>'
		cDP100110 += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
		cDP100110 += '<title>Inclusão de Fornecedor sem Conta Contábil</title>'
		cDP100110 += '</head>'
		cDP100110 += '<body>'
		cDP100110 += '	<p>Inclusão de Fornecedor sem Conta Contábil</p>'
		cDP100110 += '  <p>Fornecedor: </p>'
		cDP100110 += '	<p>Código: ' + Trim(SA2->A2_COD) + '</p>'
		cDP100110 += '	<p>Razão Social: ' + Trim(SA2->A2_NOME) + '</p>'
		cDP100110 += '	<p>Nome Fantasia: ' + Trim(SA2->A2_NREDUZ) + '</p>'
		cDP100110 += '	<p>&nbsp;</p>'
		cDP100110 += '  <p>by Protheus (MT20FOPOS)</p>'
		cDP100110 += '</body>'
		cDP100110 += '</html>'
		
		df_Orig := IIF(cEmpAnt == "05", "workflow@incesa.ind.br", "workflow@biancogres.com.br")
		//df_Dest := "luana.ribeiro@biancogres.com.br;"
		//df_Dest := "jecimar.ferreira@biancogres.com.br"
	   	xCLVL   := ""
		df_Dest := U_EmailWF('MT20FOPOS', cEmpAnt , xCLVL )
		
		df_Assu := "Inclusão de Fornecedor sem Conta Contábil"
		df_Erro := ""
		U_BIAEnvMail(df_Orig, df_Dest, df_Assu, cDP100110, df_Erro)
   	EndIf

EndIf

Return

//ROTINA PARA INCLUSÃO DA CONTA CONTABIL
Static Function ATUALIZA_CT1()
Local xCodRe

If Substr(ALLTRIM(SA2->A2_CONTA),9,6) <> ALLTRIM(SA2->A2_COD) .AND. cEmpAnt <> "02"  
	RecLock('SA2',.F.)
	SA2->A2_CONTA := Substr(SA2->A2_CONTA,1,8)+ALLTRIM(SA2->A2_COD)
	SA2->(MsUnLock())
	MsgBox("Conta contabil informada incorretamente! O sistema realizara a correção automaticamente","MT20FOPOS","INFO")
EndIf

//Posiona no indice 2
CT1->(dbSetOrder(2))
CT1->(DbGoBottom())
xCodRe := Soma1(CT1->CT1_RES)

//Posiona no indice 1, e pequisa se a Conta ja existe
CT1->(dbSetOrder(1))
If !CT1->(dbSeek(xFilial('CT1')+SA2->A2_CONTA)) 
	RecLock("CT1",.T.)
	CT1->CT1_FILIAL		:= xFilial("CT1")
	CT1->CT1_CONTA		:= SA2->A2_CONTA
	CT1->CT1_DESC01		:= SA2->A2_NOME
	CT1->CT1_CLASSE		:= "2"
	CT1->CT1_NORMAL		:= "2"
	CT1->CT1_BLOQ 		:= "2"
	CT1->CT1_RES    	:= xCodRe
	IF cEmpAnt == "02"  
		CT1->CT1_CTASUP   	:= "21101"
	ELSE
		CT1->CT1_CTASUP   	:= "21102001"
	END IF		
	CT1->CT1_GRUPO   	:= "2"
	CT1->CT1_CVD02   	:= "5"
	CT1->CT1_CVD03   	:= "5"
	CT1->CT1_CVD04   	:= "5"
	CT1->CT1_CVD05   	:= "5"
	CT1->CT1_CVC02   	:= "5"
	CT1->CT1_CVC03   	:= "5"
	CT1->CT1_CVC04   	:= "5"
	CT1->CT1_CVC05   	:= "5"
	CT1->CT1_DC			:= CTBDIGCONT(CT1->CT1_CONTA)
	CT1->CT1_BOOK		:= "001"
	CT1->CT1_CCOBRG		:= "2"
	CT1->CT1_ITOBRG		:= "2"
	CT1->CT1_CLOBRG		:= "2"
	CT1->CT1_LALUR		:= "0"
	CT1->CT1_DTEXIS		:= dDataBase
	CT1->CT1_INDNAT		:= "2"                    
	CT1->CT1_NTSPED		:= "02"
	CT1->CT1_SPEDST		:= "2"		    		
	CT1->(MsUnLock())  
	
	//OS 0959-16 (Carolina Zanetti) - Luana Marin Ribeiro - 15/03/2016 - foi realizado o complemento do cadastro
	//Pesquisa Plano Referencia
	sPlRef := "001   "
	sCtRef := "2.01.01.01.00"		
	CVN->(dbSetOrder(2))
	CVN->(dbSeek(xFilial('CVN')+sPlRef+sCtRef))
	
	CVD->(dbSetOrder(2))
	If !CVD->(dbSeek(xFilial('CVD')+sPlRef+sCtRef+SA2->A2_CONTA))
		RecLock("CVD",.T.)		
		CVD->CVD_FILIAL	:= XFILIAL("CVD")
		CVD->CVD_ENTREF	:= CVN->CVN_ENTREF
		CVD->CVD_CODPLA	:= CVN->CVN_CODPLA
		CVD->CVD_CONTA	:= SA2->A2_CONTA
		CVD->CVD_CTAREF	:= CVN->CVN_CTAREF
		CVD->CVD_YDESC	:= CVN->CVN_DSCCTA  
		CVD->CVD_TPUTIL	:= CVN->CVN_TPUTIL
		CVD->CVD_CLASSE	:= CVN->CVN_CLASSE
		CVD->CVD_NATCTA	:= CVN->CVN_NATCTA
		CVD->CVD_CTASUP	:= CVN->CVN_CTASUP		
		CVD->(MsUnLock())
	EndIf
	
	//Pesquisa Plano Referencia
	sPlRef := "002   "
	sCtRef := "2.01.01.03.01"		
	CVN->(dbSetOrder(2))
	CVN->(dbSeek(xFilial('CVN')+sPlRef+sCtRef))		

	CVD->(dbSetOrder(2))
	If !CVD->(dbSeek(xFilial('CVD')+sPlRef+sCtRef+SA2->A2_CONTA))
		RecLock("CVD",.T.)	
		CVD->CVD_FILIAL	:= XFILIAL("CVD")
		CVD->CVD_ENTREF	:= CVN->CVN_ENTREF
		CVD->CVD_CODPLA	:= CVN->CVN_CODPLA
		CVD->CVD_CONTA	:= SA2->A2_CONTA
		CVD->CVD_CTAREF	:= CVN->CVN_CTAREF
		CVD->CVD_YDESC	:= CVN->CVN_DSCCTA  
		CVD->CVD_TPUTIL	:= CVN->CVN_TPUTIL
		CVD->CVD_CLASSE	:= CVN->CVN_CLASSE
		CVD->CVD_NATCTA	:= CVN->CVN_NATCTA
		CVD->CVD_CTASUP	:= CVN->CVN_CTASUP
		CVD->(MsUnLock())		
	EndIf
	
	DbCommitAll()
Endif

Return*/