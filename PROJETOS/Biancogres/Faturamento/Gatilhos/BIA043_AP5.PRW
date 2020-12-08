#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia043()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//�����������������������������������������������������������������������

	Local _nseq

	SetPrvt("_RETITEM,_TESTE,_NSEQ,")

	/*/
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Programa  � BIA904   � Autor � SIGA Vitoria          � Data � 13/08/99 ���
	�������������������������������������������������������������������������Ĵ��
	���Descri��o � Atualizacao de romaneio                                    ���
	�������������������������������������������������������������������������Ĵ��
	���Uso       � SIGAFAT                                                    ���
	��������������������������������������������������������������������������ٱ�
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	/*/
	_RetItem:= "  "
	_Teste  := ""

	If aCols[n,wPL_Item] == "  "
		//�����������������������������������������������������������������������Ŀ
		//� Calcula a proxima sequencia                                           �
		//�������������������������������������������������������������������������
		_Teste    := Alltrim(aCols[n,wPL_Pedido]+aCols[n,wPL_Produto])
		For _nseq := 1 to Len(Acols)
			If _Teste == Alltrim(aCols[_nseq,wPL_Pedido]+aCols[_nseq,wPL_Produto]) .and.;
			!aCols[_nseq,wPL_Delet]
				If _RetItem < aCols[_nseq,wPL_Item]
					_RetItem := aCols[_nseq,wPL_Item]
				EndIf
			EndIf
		Next
	EndIf

	// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return(_RetItem)
Return(_RetItem)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01