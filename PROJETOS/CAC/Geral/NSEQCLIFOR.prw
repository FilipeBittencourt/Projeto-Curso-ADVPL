#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function NSEQCLI(nRet)
Local _cAliasTmp
Local aAreaSA1  := SA1->(GetArea())
Local _cCgc    
Local _cRet
Local _cCOD
Local _cLOJA

	IF A1_PESSOA == "F"    
		_nTamCgc := 9
		_cCgc := SUBSTR(M->A1_CGC,1,9)
		_cExpW := "% SUBSTRING(A1_CGC,1,9) = '"+_cCgc+"' %"
	ELSE            
		_cCgc := SUBSTR(M->A1_CGC,1,8)
		_cExpW := "% SUBSTRING(A1_CGC,1,8) = '"+_cCgc+"' %"
	ENDIF
                                  
	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
		%noparser%
		SELECT 
		COD = CASE WHEN (SELECT COUNT(*) FROM %TABLE:SA1% WHERE %EXP:_cExpW% AND %NOTDEL%) > 0
			  THEN (SELECT TOP 1 A1_COD FROM %TABLE:SA1% WHERE %EXP:_cExpW% AND %NOTDEL%)
			  ELSE (SELECT ISNULL(RIGHT('000000'+cast(convert(int, SUBSTRING(MAX(A1_COD),1,6))+1 as varchar(6)),6),'000001') 
				   FROM %TABLE:SA1% WHERE SUBSTRING(A1_COD,1,1) IN ('0','1','2','3','4','5','6','7','8','9') AND %NOTDEL%)
			  END
		,LOJA = CASE WHEN (SELECT COUNT(*) FROM %TABLE:SA1% WHERE %EXP:_cExpW% AND %NOTDEL%) > 0
			  THEN (SELECT ISNULL(RIGHT('00'+cast(convert(int, SUBSTRING(MAX(A1_LOJA),1,2))+1 as varchar(2)),2),'01') 
					FROM %TABLE:SA1% WHERE %EXP:_cExpW% AND %NOTDEL%)
			  ELSE '01'
		  	  END
	EndSql
	
	(_cAliasTmp)->(DbGoTop())
	_cCOD := (_cAliasTmp)->COD
	_cLOJA := (_cAliasTmp)->LOJA	
	(_cAliasTmp)->(DbCloseArea())
	       
	IF nRet == 1
		_cRet := _cCOD
	ELSE              
		_cRet := _cLOJA
	ENDIF
	
	Restarea(aAreaSA1)
Return(_cRet)


User Function NSEQFOR(nRet)
Local _cAliasTmp
Local aAreaSA2  := SA2->(GetArea())
Local _cCgc    
Local _cRet
Local _cCOD
Local _cLOJA

	IF A2_TIPO == "F"    
		_nTamCgc := 9
		_cCgc := SUBSTR(M->A2_CGC,1,9)
		_cExpW := "% SUBSTRING(A2_CGC,1,9) = '"+_cCgc+"' %"
	ELSE            
		_cCgc := SUBSTR(M->A2_CGC,1,8)
		_cExpW := "% SUBSTRING(A2_CGC,1,8) = '"+_cCgc+"' %"
	ENDIF
                                  
	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
		%noparser%
		SELECT 
		COD = CASE WHEN (SELECT COUNT(*) FROM %TABLE:SA2% WHERE %EXP:_cExpW% AND %NOTDEL%) > 0
			  THEN (SELECT TOP 1 A2_COD FROM %TABLE:SA2% WHERE %EXP:_cExpW% AND %NOTDEL%)
			  ELSE (SELECT ISNULL(RIGHT('000000'+cast(convert(int, SUBSTRING(MAX(A2_COD),1,6))+1 as varchar(6)),6),'000001') 
				   FROM %TABLE:SA2% WHERE SUBSTRING(A2_COD,1,1) IN ('0','1','2','3','4','5','6','7','8','9') AND %NOTDEL%)
			  END
		,LOJA = CASE WHEN (SELECT COUNT(*) FROM %TABLE:SA2% WHERE %EXP:_cExpW% AND %NOTDEL%) > 0
			  THEN (SELECT ISNULL(RIGHT('00'+cast(convert(int, SUBSTRING(MAX(A2_LOJA),1,2))+1 as varchar(2)),2),'01') 
					FROM %TABLE:SA2% WHERE %EXP:_cExpW% AND %NOTDEL%)
			  ELSE '01'
		  	  END
	EndSql
	
	(_cAliasTmp)->(DbGoTop())
	_cCOD := (_cAliasTmp)->COD
	_cLOJA := (_cAliasTmp)->LOJA	
	(_cAliasTmp)->(DbCloseArea())
	       
	IF nRet == 1
		_cRet := _cCOD
	ELSE              
		_cRet := _cLOJA
	ENDIF
	
	Restarea(aAreaSA2)
Return(_cRet)