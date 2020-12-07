/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |RS150ML    | Autor | Marcelo Sousa        | Data | 31.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |PONTO DE ENTRADA UTILIZADO PARA CRIAR UM BOTÃO NA TELA DE     |
|          |CURRICULOS.									 			      |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEÇÃO                                        |
+----------+-------------------------------------------------------------*/
#include 'protheus.ch'
#include 'parmtype.ch'

user function RSP010BUT()
	
	
Return {{'S4WB005N',{||U_BIAFM001()},'Enviar Email','Enviar Email'}}