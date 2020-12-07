/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |BIAFM012   | Autor | Marcelo Sousa        | Data | 10.10.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |FONTE PARA RETORNAR CONTA CONTÁBIL NO LANÇAMENTO DE PA        |
+----------+--------------------------------------------------------------+
|Uso       |CONTABILIDADE LP 513 - TICKET 7956                            |
+----------+-------------------------------------------------------------*/


#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

user function BIAFM013()

	Local cConta := ""
	
	// Se o título for PA, utiliza variaveis da tela para posicionar a SA6 correta. 
	
	IF ALLTRIM(SE2->E2_TIPO) == 'PA'
	
		DBSELECTAREA("SA6")
		SA6->(DBSETORDER(1))
		SA6->(DBSEEK(xFilial()+cBancoAdt+cAgenciaAdt+cNumCon))
		cConta := SA6->A6_CONTA 
		Return cConta
		
	ELSEIF (SE5->E5_MOTBX == "DEB" .OR. ALLTRIM(SE5->E5_ORIGEM) == "FINA090")
	
		cConta := "11105002"
		
	ELSEIF (SE5->E5_MOTBX == "DES" .AND. ALLTRIM(SE5->E5_ORIGEM) == "FINA080")

		cConta := "41403001"
	
	ELSE
	
		cConta := SA6->A6_CONTA
		
	ENDIF
	
	
	
return cConta