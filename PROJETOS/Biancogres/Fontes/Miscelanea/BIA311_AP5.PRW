#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 17/05/02

User Function bia311()        // incluido pelo assistente de conversao do AP5 IDE em 17/05/02

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//�����������������������������������������������������������������������
	local i
	SetPrvt("WN,LERRO1,LERRO2,WERRO,WI,WDOCS")
	SetPrvt("WQTD,I,N,")

	/*/
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Fun��o    � BIA311   � Autor � MICROSIGA Vitoria     � Data � 28.07.00 ���
	�������������������������������������������������������������������������Ĵ��
	���Descri��o � Cadastro de Precos - atualizacao                           ���
	�������������������������������������������������������������������������Ĵ��
	��� Uso      � RDMAKE                                                     ���
	��������������������������������������������������������������������������ٱ�
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	/*/
	//����������������������������������������������������������������������Ŀ
	//� Verifique duplicidade                                                �
	//������������������������������������������������������������������������
	wn     := n
	lErro1 := .F.
	lErro2 := .F.
	wErro  := .F.

	If  ! aCols[n,nUsado+1]
		If  Empty(aCols[n,1]) .Or. ;
		Empty(aCols[n,2]) .Or. ;
		Empty(aCols[n,3])
			lErro1 := .T.
		Endif
		wi     := i
		wDocs  := aCols[n,1]+aCols[n,2]
		wQtd   := 0
		For  i := 1 to len(aCols)
			If  ! aCols[i,nUsado+1]
				If  aCols[i,1]+aCols[i,2] == wDocs
					wQtd := wQtd + 1
				Endif
			Endif 
		Next
		If  wQtd > 1
			lErro2 := .T.
		Endif
		i := wi
	Endif
	If  lErro1 .or. lErro2
		If  lErro1
			MsgBox("Verifique se todos os campos estao preenchidos nesta linha.","BIA311 - Preenchimento de Campos","STOP")
			wErro := .T.
		Endif
		If  lErro2
			MsgBox("Linha repetida. Verifique.","BIA311 - Duplicidade","STOP")
			wErro := .T.
		Endif
	Endif
	n := wn

	If wErro 
		// Substituido pelo assistente de conversao do AP5 IDE em 17/05/02 ==>    __Return(.F.)
		Return(.F.)        // incluido pelo assistente de conversao do AP5 IDE em 17/05/02
	Else
		// Substituido pelo assistente de conversao do AP5 IDE em 17/05/02 ==>    __Return(.T.)
		Return(.T.)        // incluido pelo assistente de conversao do AP5 IDE em 17/05/02
	EndIf

Return
