#include "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BIA_EP    �Autor  �HARLEY D. KOEHLER   � Data �  26/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Especificacao de Produtos - EP's               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Comercial, Laboratorio e Industrial	                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BIA_EP
	Private cCadastro := "Cadastro de Games"
	private aRotina := {{"Pesquisa","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;					
						{"Excluir","AxDeleta",0,5},;
						{"Legenda","U_Legenda()",0,6}}
						
	
	Private cDelFunc := ".T."
	
	acores := {{"ZT_SITUACA = .F.","BR_VERDE"},;
	           {"ZT_SITUACA = .T.","BR_VERMELHO"}}


	dbSelectArea("SZT")
	dbSetOrder(1)
	mBrowse(6,1,22,75,"SZT",,,,,6,acores)

return

User Function Legenda()

	BrwLegenda(cCadastro,"Valores", {{"BR_VERDE","ABERTO"},;
									 {"BR_VERMELHO","FECHADO"}})
									 

return.T.

