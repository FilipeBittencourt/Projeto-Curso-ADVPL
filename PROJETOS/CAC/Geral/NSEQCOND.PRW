#include "rwmake.ch"        
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NSEQCOND	 �Autor  �Fernando Rocha      � Data � 01/02/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho para trazer automatico o numero da cond. pag.      ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Produto                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function NSEQCOND() 
Local _cAliasTmp
Local _cGrupo

Private _cNumPrd	:= ""
Private _cRet		:= ""
Private aAreaSE4  := SE4->(Getarea()) 
   	  
   	_cGrupo := M->E4_YCATEGO
   	
	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
		%noparser%
		SELECT COD = CASE WHEN (SELECT COUNT(*) FROM %Table:SE4% WHERE SUBSTRING(E4_CODIGO,1,1) = %EXP:_cGrupo% AND D_E_L_E_T_=' ') > 0
			  THEN (SELECT ISNULL(RIGHT('00'+cast(convert(int, MAX(SUBSTRING(E4_CODIGO,2,2)) )+1 as varchar(2)),2),'01') FROM %Table:SE4% WHERE SUBSTRING(E4_CODIGO,1,1) = %EXP:_cGrupo% AND D_E_L_E_T_=' ')
			  ELSE '01'
			  END
	EndSql
	
	(_cAliasTmp)->(DbGoTop())
	_cNumPrd := (_cAliasTmp)->COD
	(_cAliasTmp)->(DbCloseArea())
	
	If Alltrim(_cNumPrd) = ""
		_cNumPrd := "01"
	EndIf
	
	_cRet := _cGrupo+_cNumPrd

	//alterado por Rafael - 13/02/07
	//valida��o do c�digo a ser retornado para que n�o ocorre chave duplicada
	SE4->(DbSetOrder(1)) //B1_FILIAL+B1_COD                                                                                                                                                
	While SE4->(Dbseek(xFilial("SE4")+_cRet))
		_cNumPrd := Soma1(_cNumPrd,2)
		_cRet := _cGrupo+_cNumPrd		
	Enddo
	Restarea(aAreaSE4)

return(_cRet)

