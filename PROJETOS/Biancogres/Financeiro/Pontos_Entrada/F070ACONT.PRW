#INCLUDE 'TOTVS.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � F070ACONT� Autor � FERNANDO ROCHA        � Data � 28/08/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � PE ANTES DA CONTABILIZACAO DE BAIXAS A RECEBER             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function F070ACONT() // Nao eh chamado via execauto

	Local aArea := GetArea()
	Local oObjDepId := TAFProrrogacaoBoletoReceber():New(.F.)

	If Type("__F70TITITEMD") <> "U" .And. Type("__F70TITCTRVER") <> "U"

		SE5->E5_ITEMD := __F70TITITEMD
		SE5->E5_YCTRVER := __F70TITCTRVER
	
		__F70TITITEMD := Nil
		__F70TITCTRVER := Nil
	
	EndIf
	
	If Type("__F70TITDEBITO") <> "U" .And. Type("__F70TITCLVLDB") <> "U"
		
		SE5->E5_DEBITO := __F70TITDEBITO
		SE5->E5_CLVLDB := __F70TITCLVLDB

		__F70TITDEBITO := Nil
		__F70TITCLVLDB := Nil
				
	EndIf
	
	oObjDepId:BaixaDepAntJR() 

	RestArea(aArea)
	
Return()