/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |TRM060LEG  | Autor | Marcelo Sousa        | Data | 04.10.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |LEGENDAS PARA A TELA DE RESERVAS			                  |
+----------+--------------------------------------------------------------+
|Uso       |TREINAMENTO			                                          |
+----------+-------------------------------------------------------------*/

#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOTVS.CH"

User Function TRM060LEG()

	
	
	// Definindo cores que o array irá receber. 
	Local aRet := {}
	
	aAdd(aRet, {'RA2->RA2_YREP == "S" .AND. RA2->RA2_REALIZA <> "S"', "BR_AZUL", "Reprogramado"}) //"Reprogramado"
	aAdd(aRet, {'RA2->RA2_REALIZA == "S"', "BR_VERMELHO", ""}) //"Encerrado"
	aAdd(aRet, {'RA2->RA2_REALIZA != "S"', "ENABLE"	  , ""}) //"Em Aberto"	
	
Return(aRet)	