#include "rwmake.ch"
#include "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MT130TOK � Autor � Ranisses A. Corona    � Data � 22.11.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Bloqueia Cotacao de Pedidos MD na Empresa Incesa.          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Compras                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MT130TOK()
Local lret     := .T.
Local wProd		 := ""
Local wLocal	 := ""

//Armazena as variaveis / conteudo de cada linha
wPROD			:= SC1->C1_PRODUTO
wLocal		:= SC1->C1_LOCAL	 

DbSelectArea("SBZ")
DbSetOrder(1)
DbSeek(xFilial("SBZ")+wPROD,.T.)

//Bloqueia entrada de produtos Comum na Incesa

//Fernando/Facile em 03/12/2015 -> acabar com o armazem de produto comum - cada empresa passa a comprar seu produto (Comentado o bloco acima)
//Comentado o Bloco Abaixo para liberar entrada na Incesa no Almoxarifado 01

/*If cEmpAnt == "05" .And. SBZ->BZ_YCOMUM == "S"
	MsgBox("N�o � permitida a inclus�o de Pedido de Compras para Produto Comum na empresa Incesa. Favor verificar procedimento com Almoxarifado!","MT130TOK","ALERT")
	lret := .F.
	Return(lret)
EndIf*/

//�����������������������������������������������Ŀ
//�Executa validacao referente Almoxarifado Comum �
//�������������������������������������������������
If !U_fValProdComum(wProd,wLocal,"MT130TOK","C") //Paramentros da Funcao Produto/Almoxarifado/NomeProgroma/TipoMovimento(C=Compra/T=Transferencia)
	lRet := .F.
	Return(lRet)
EndIf

Return(lret)