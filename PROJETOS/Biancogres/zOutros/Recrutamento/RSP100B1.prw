/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |RSP100B1   | Autor | Marcelo Sousa        | Data | 31.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |PONTO DE ENTRADA UTILIZADO PARA CRIAR UM BOTÃO NA TELA DE     |
|          |VAGA, COM O INTUITO DE REALIZAR A APROVAÇÃO POR PARTE DO 	  |
|		   |APROVADOR				 			      					  |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEÇÃO                                        |
+----------+-------------------------------------------------------------*/
#include 'protheus.ch'
#include 'parmtype.ch'

User Function RSP100B1()
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Local nOpc := ParamIxb[1]
	Local aRet :={}
	
	cUsrtst := __cUserID
	aUsrtst2 := UsrRetGrp(cUsrtst)
	lAlt := .F.
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Verificando permissão do usuário para a ação.                           ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	DBSELECTAREA("ZR3")
	ZR3->(dbsetorder(1))
	ZR3->(DBSEEK(xFilial("ZR3")+cUsrtst))
		
	IF ZR3->ZR3_USUARI == cUsrtst .AND. ZR3->ZR3_RECRUT == "1"
				lAlt := .T.
	ENDIF
	
	If nOpc=4 .AND. lAlt == .T. 
			
			/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ±±
			±±  Sinalizando a aprovação da Vaga e encaminhando o e-mail para o aprovador ±±
			Ù± ±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
			dbselectarea("SRA")
			SRA->(dbsetorder(1))
			SRA->(dbSeek(xFilial("SRA")+SQS->QS_MATRESP))
			
			aRet:={'S4WB005N',{||U_BIAFM004(ALLTRIM(SQS->QS_VAGA),ALLTRIM(SQS->QS_DESCRIC),ALLTRIM(SQS->QS_YCRIA),ALLTRIM(SRA->RA_EMAIL),ALLTRIM(SRA->RA_NOME),"2")},'Aprovar Vaga','Aprovar Vaga'}
	
	EndIf 

Return aRet