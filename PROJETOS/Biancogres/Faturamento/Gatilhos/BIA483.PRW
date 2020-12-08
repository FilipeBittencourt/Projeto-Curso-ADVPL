#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA483()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA483     � Autor � WANISAY               � Data � 20/10/10 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho CC2_YKM                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BIANCOGRES                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
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