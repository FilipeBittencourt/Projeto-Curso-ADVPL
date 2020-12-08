#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/04/01

User Function BIA452()        // incluido pelo assistente de conversao do AP5 IDE em 23/04/01

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//�����������������������������������������������������������������������


	/*/
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Fun��o    � BIA452   � Autor � Microsiga             � Data � 02/03/09 ���
	�������������������������������������������������������������������������Ĵ��
	���Descri��o � Execblock para nao permitir alteracao de precos de produtos���
	���          � expositores.                                               ���
	���          �                                                            ���
	�������������������������������������������������������������������������Ĵ��
	��� Uso      � Especifico: BIANCOGRES S/A                                 ���
	��������������������������������������������������������������������������ٱ�
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	/*/

	Local xxn

	wProduto := SPACE(15)
	lRet     := .T.

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "C6_PRODUTO"
			wProduto := aCols[n][xxn]
		Endif
	Next

	If Alltrim(M->C5_TIPO) == "N'
		If SUBSTR(wProduto,1,3) == "216" 
			lRet := .F.
		EndIf
	EndIf

Return(lRet) 