#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA483()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA483     � Autor � WANISAY               � Data � 20/10/10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Gatilho CC2_YKM                                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � BIANCOGRES                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/     
PRIVATE nKM     := M->CC2_YKM
PRIVATE nTarifa := '' 

DbSelectArea("SZ4")
DbGoTop()

While !EOF()                                   
	
	nPos := AT('-',SZ4->Z4_KM)
	nKMIni := VAL(SUBSTR(SZ4->Z4_KM,1,nPos-1))
	nKMFim := VAL(SUBSTR(SZ4->Z4_KM,nPos+1,4))
	
	IF nKM >= nKMIni .AND. nKM <= nKMFim
		nTarifa := SZ4->Z4_TARIFA
	ENDIF
	
	DbSelectArea("SZ4") 
	DbSkip()
END

return(nTarifa)