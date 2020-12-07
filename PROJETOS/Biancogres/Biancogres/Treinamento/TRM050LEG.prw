/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |TRM050LEG  | Autor | Marcelo Sousa        | Data | 02.10.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |LEGENDAS PARA A TELA DE CALENDARIO/TREINAMENTOS               |
+----------+--------------------------------------------------------------+
|Uso       |TREINAMENTO			                                          |
+----------+-------------------------------------------------------------*/

#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOTVS.CH"

User Function TRM050LEG()

	
	
	// Definindo cores que o array irá receber. 
	Local aRet := {}
	
	SETKEY(VK_F7,{|| U_BIAFM008() })
	
	aAdd(aRet, {'RA2->RA2_YREP == "S" .AND. RA2->RA2_REALIZA <> "S"', "BR_AZUL", "Reprogramado"}) //"Remanejado"
	aAdd(aRet, {'RA2->RA2_REALIZA == "S"', "BR_VERMELHO", ""}) //"Encerrado"
	aAdd(aRet, {'RA2->RA2_REALIZA != "S"', "ENABLE"	  , ""}) //"Em Aberto"	
	
Return(aRet)	