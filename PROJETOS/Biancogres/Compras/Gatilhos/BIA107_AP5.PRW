#include "rwmake.ch"

/*�����������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA107     � Autor � WLADIMIR ILLIUSHENKO  � Data � 07/08/00 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Permite somente a entrada dos almoxarifados contidos na ...  ���
���          � matriz "aAlmox".                                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador xBase                                          ���
����������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/

User Function BIA107()

	Local xxn

	aAlmox := {"01", "02", "03", "04", "05", "6B", "07", "20"}

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "D1_LOCAL"
			wAlmox := aCols[n][xxn]
		Endif
	Next

	If AScan(aAlmox,wAlmox) == 0

		MSGBOX("Almoxarifado '"+wAlmox+"' invalido!")
		wAlmox := ""

	Endif

Return(wAlmox)