#INCLUDE "PROTHEUS.CH"
#include "TOTVS.CH" 

//_______________________________________________________________________________
//                                                                               | 
// Tipo de Programa: Ponto de Entrada                                            | 
// Descrição       : Permite adicionar nova opção de menu no Módulo Faturamento  |
// Autor		   : Jessé Augusto	                                             |
// Data 		   : 05/09/2016                                                  |
//_______________________________________________________________________________|


User Function MA410MNU() 


	aAdd(aRotina,{'Reenvio de Boleto'		,"U_TECFAT02()"	 , 0 , 3,0,NIL})     
//	aAdd(aRotina,{'Gerar Poder de Terceiro'	,"U_TECFAT05()"	 , 0 , 4,0,NIL})
//	aAdd(aRotina,{'Amarração de Produtos'	,"U_TECFAT06()"	 , 0 , 4,0,NIL})

Return                                                           

