#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������ͻ��
���Programa  � BIA847 �Autor  � Ranisses A. Corona � Data �  10/11/11   ���
�����������������������������������������������������������������������͹��
���Descr.    � Valida campo Regime Especial - A1_YREGESP                ���
�����������������������������������������������������������������������͹��
���Uso       � SigaFat                                                  ���
�����������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/
USER FUNCTION BIA847()
Local lRet := .T.

If !Empty(Alltrim(M->A1_YREGESP))
	If !Alltrim(M->A1_YREGESP) == "EXCECAO" .And. !fValNumber(Alltrim(M->A1_YREGESP)) //( !Substr(Alltrim(M->A1_YREGESP),1,5) $ "16.00_71856_45.00_51224_92966_160/2" )
		MsgBox("Informe neste campo o c�digo do Regime Especial ou a palavra EXCECAO!","BIA847","STOP")
		lRet := .F.
	EndIf
EndIf

Return(lRet)


Static Function fValNumber(nRegime)
Local llRet := .T.
Local i		:= 1

While i <= Len(nRegime) .And. llRet
	llRet	:= IF(SUBSTR(nRegime,i,1) $ "0123456789.-/",.T.,.F.)		
	i		:= i + 1
EndDo

Return(llRet)