#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MTCOLSE2
@author Ranisses A. Corona
@since 18/05/2017
@version 1.0
@description Alterar o vencimento das Parcelas, das NFe Intragrupos.
@history 18/05/2017, Por Ranisses A. Corona, Adicionado PE em substiticao ao PE A103CND2
@type function
/*/

USER FUNCTION MTCOLSE2()

Local _aDuplic		:= PARAMIXB[1]
Local I
Local _cAliasTmp	
Local nTable
Local cFil		
Local cCli
Local cLoj	
Local _OkItr296 	:= .F.  // Incluído em 06/09/12 para amarração intragrupo via programa BIA296. Por Marcos Alberto Soprani
Local aInfOri		:= {}	
Local aSE2 := {}

//Tratamento para Totvs Colaboracao 2.0
If GetMv("MV_COMCOL1") <> 2 .And. Upper(Alltrim(FUNNAME())) == "SCHEDCOMCOL"  
	Return _aDuplic
EndIf

If Alltrim(FunName()) == "BIA296"
	_OkItr296	:= _xIntrGrV
	aInfOri		:= U_GetInfO2(_NFNUM,_NFSERIE,_CCODFOR,_CLOJFOR,"","",cEmpAnt)
EndIf

If Alltrim(FunName()) == "MATA103" .Or. IsInCallStack("U_BACP0012")
	aInfOri		:= U_GetInfO2(CNFISCAL,CSERIE,CA100FOR,CLOJA,"","",cEmpAnt)
EndIf

If Alltrim(FunName()) == "U_GATI001"
	aInfOri		:= U_GetInfO2(ZAA->ZAA_DOC,ZAA->ZAA_SERIE,ZAA->ZAA_CODEMI,ZAA->ZAA_LOJEMI,"","",cEmpAnt)
	aSE2 := U_GTPE013()
	_aDuplic := aSE2	
EndIf

Conout("PE:=> MTCOLSE2 => "+ALLTRIM(FUNNAME()))

If (SUBSTR(ALLTRIM(FUNNAME()),1,8) == "REPL_PRE" .OR. SUBSTR(ALLTRIM(FUNNAME()),1,6) == "REPL_I" .or. _OkItr296 .Or. ALLTRIM(FUNNAME()) == "MATA103" .Or. IsInCallStack("U_BACP0012")) .And. aInfOri[1] <> ""
	
	If Alltrim(cEmpAnt) == "07" 
	
		nTable	:= "%SE1"+aInfOri[1]+"0%" 
		cFil	:= aInfOri[2]
		cCli	:= aInfOri[3]
		cLoj	:= aInfOri[4]
		
		//Buscar parcelas da NF de Saida da Biancogres/Incesa/Mundi/LM(Filiais)
		dbSelectArea("SE1")
		_cAliasTmp := GetNextAlias()
		BeginSql Alias _cAliasTmp
			SELECT E1_VENCTO, E1_VALOR
			FROM %EXP:nTable%
			WHERE E1_FILIAL = %EXP:cFil% AND E1_NUM = %EXP:CNFISCAL% AND E1_SERIE = %EXP:CSERIE% AND E1_CLIENTE = %EXP:cCli% AND E1_LOJA = %EXP:cLoj% AND %NotDel%  AND E1_TIPO = 'NF' 
			ORDER BY E1_NUM, E1_PARCELA
		EndSql
		
		I := 1
		(_cAliasTmp)->(DbGoTop())
		While .Not. (_cAliasTmp)->(Eof())
			
			IF Len(_aDuplic) >= I
				
				//Copiar vencimento do titulo da saida Bianco, pois adiciona 7 dias em relacao a condicao de pagamento.
				_aDuplic[I][2] := STOD((_cAliasTmp)->E1_VENCTO)
				
				//Copiar o valor do titulo da saida Bianco , pois as vezes da diferença de arredondamento no calculo do sistema
				_aDuplic[I][3] := (_cAliasTmp)->E1_VALOR
				
			ENDIF
			
			I++
			(_cAliasTmp)->(DbSkip())
		EndDo
		
		(_cAliasTmp)->(DbCloseArea())

	EndIf

EndIf

RETURN _aDuplic
