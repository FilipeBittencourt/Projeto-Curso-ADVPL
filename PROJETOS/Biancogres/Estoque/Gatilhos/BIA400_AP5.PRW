#include "rwmake.ch"       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA400   � Autor � BiancoGres            � Data � 08/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho do Campo D3_YMATRIC - Seq.001                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Estoque  - Joao Carlos                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
User Function Bia400()      

	Local xn

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
	IF Type("_ExecAutoII") <> "U" 
		Return
	ENDIF

	If Upper(Alltrim(FUNNAME())) == "MATA240" .or. UPPER(ALLTRIM(FUNNAME())) == "BIA294"
		If Empty(M->D3_CLVL) .OR. M->D3_CLVL == SRA->RA_CLVL
			wD3_CLVL := SRA->RA_CLVL
		Else
			wD3_CLVL := M->D3_CLVL
		Endif
		Return(wD3_CLVL)
	Elseif UPPER(ALLTRIM(FUNNAME())) == "MATA241" .and. inclui    // Internos Mod.2
		For xn := 1 to Len(aHeader)
			xcCampo := Trim(aHeader[xn][2])
			If xcCampo == "D3_CLVL"                 
				wsCLVL := aCols[n][xn]		
				If Empty(wsCLVL) .OR. wsCLVL == SRA->RA_CLVL
					aCols[n][xn] := SRA->RA_CLVL
				Endif
			Endif
		Next
		Return
	Endif

Return

