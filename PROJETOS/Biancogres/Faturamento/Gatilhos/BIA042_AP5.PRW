#include "rwmake.ch"

User Function Bia042()

	Local _nseq

	/*/
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Programa  � BIA903   � Autor � SIGA Vitoria          � Data � 13/08/99 ���
	�������������������������������������������������������������������������Ĵ��
	���Descri��o � Atualizacao de romaneio                                    ���
	�������������������������������������������������������������������������Ĵ��
	���Uso       � SIGAFAT                                                    ���
	��������������������������������������������������������������������������ٱ�
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	/*/
	_RetSeq := _Seq := "  "
	_Teste  := ""
	_nSeq   := 0
	//_Item :=

	If aCols[n,wPL_Sequen] == "  "
		//�����������������������������������������������������������������������Ŀ
		//� Calcula a proxima sequencia                                           �
		//�������������������������������������������������������������������������
		_Teste    := Alltrim(aCols[n,wPL_Pedido]+aCols[n,wPL_Produto])
		For _nseq := 1 to Len(Acols)
			If _Teste == Alltrim(aCols[_nseq,wPL_Pedido]+aCols[_nseq,wPL_Produto]) .and.;
			!aCols[_nseq,wPL_Delet]
				//_Item := aCols[n,wPL_Item]
				If _Seq < aCols[_nseq,wPL_Sequen]
					_Seq  := aCols[_nseq,wPL_Sequen]
				EndIf
			EndIf
		Next
	EndIf

	_RetSeq := StrZero(Val(_Seq),2,0)

Return(_RetSeq) 

