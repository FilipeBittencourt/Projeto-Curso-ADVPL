#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FA340FILT � Autor �FERNANDO ROCHA         � Data � 10/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � PONTO DE ENTRADA PARA FILTRAR COMPENSACAO DE TITULOS       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � BIANCOGRES                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER FUNCTION FA340FILT()
Local aArea := GetArea()
Local _cAliasTmp,_aDatOri

_cAliasTmp := GetNextAlias()
BeginSql Alias _cAliasTmp
SELECT E2_PREFIXO,E2_NUM,E2_TIPO,E2_YCONTR FROM SE2010 WHERE R_E_C_N_O_ = %Exp:PARAMIXB[1]%
EndSql

IF !(_cAliasTmp)->(Eof())
	If (!Empty((_cAliasTmp)->E2_YCONTR)) .And. (!Empty(SE2->E2_YCONTR)) .And. ((_cAliasTmp)->E2_YCONTR <> SE2->E2_YCONTR)
		Return(.F.)
	EndIf
ENDIF
(_cAliasTmp)->(DbCloseArea())

RestArea(aArea)
RETURN(.T.)