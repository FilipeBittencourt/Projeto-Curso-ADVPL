#include "rwmake.ch"

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � BIA107     � Autor � WLADIMIR ILLIUSHENKO  � Data � 07/08/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Permite somente a entrada dos almoxarifados contidos na ...  潮�
北�          � matriz "aAlmox".                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador xBase                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

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
