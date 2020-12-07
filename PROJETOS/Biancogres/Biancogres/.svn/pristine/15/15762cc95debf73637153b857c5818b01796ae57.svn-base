User Function UPDX3FLD()

RpcSetType(3)
RpcSetEnv('01','01')

_lret := UnLockByName("MT330"+cEmpAnt+cFilAnt,.T.,.F.,.T.)


Return


Static Function ImpCliECO()

	Local aEmp		:= {"01","05","13"}
	Local x			:= 0
	Local nTable	:= ""
	Local cSql 		:= ""
	Local nDB		:= AllTrim(U_DBNAME()) //Retorna a Database utilizada no ambiente.

	//Replica para as empresas que utilizam o Ecosis
	For x := 1 to Len(aEmp)

		//Define a tabela por Empresa
		If aEmp[x] == "01"
			nTable	:= ""
		Else
			nTable	:= "_"+aEmp[x]+"_"
		EndIf	

		cSql := "INSERT INTO DADOS"+nTable+"EOS..EMP_EMPRESA (cod_empresa, emp_razao_social, emp_endereco, emp_endereco_num, emp_cidade, emp_uf, emp_bairro, emp_cep) "
		cSql += "SELECT A1_COD+A1_LOJA AS CODIGO_EMP, SUBSTRING(A1_NOME,1,60) AS RAZAO_SOCIAL, SUBSTRING(A1_END,1,60) AS ENDERECO, SUBSTRING(A1_COMPLEM,1,15) AS COMPLEMENTO, "
		cSql += "       SUBSTRING(A1_MUN,1,60) AS CIDADE, A1_EST AS ESTADO, SUBSTRING(A1_BAIRRO,1,60) AS BAIRRO, A1_CEP AS CEP "      
		cSql += "FROM "+nDB+"..SA1"+aEmp[x]+"0 WITH (NOLOCK) "
		cSql += "LEFT JOIN DADOS"+nTable+"EOS..EMP_EMPRESA WITH (NOLOCK) ON A1_COD+A1_LOJA COLLATE Latin1_General_BIN = cod_empresa "
		cSql += "WHERE A1_FILIAL = '  ' AND A1_MSBLQL <> '1' AND D_E_L_E_T_ = ''  AND cod_empresa is null"
		TcSqlExec(cSql)

	Next

Return


Static Function fprocessa()
	Local _aEmps	:=	{'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','90','91'}
	Local _nI
	
	
	
	For _nI	:= 1 to Len(_aEmps)
		MsgStop(_aEmps[_nI])
		RPCSetType(3)
		RPCSetEnv(_aEmps[_nI], "01")
		
		SX7->(DbSetOrder(1))
		SX3->(DbSetOrder(2))
		
		If SX3->(DbSeek("ZZY_MATRIC"))
		
			RecLock("SX3",.F.)
			SX3->X3_TRIGGER	:=	"S"
			SX3->(MsUnlock())
		
			IF !SX7->(DbSeek("ZZY_MATRIC"+"001")) 
			
				RecLock("SX7",.T.)
				SX7->X7_CAMPO	:=	"ZZY_MATRIC"
				SX7->X7_SEQUENC	:=	"001"
				SX7->X7_REGRA	:=	"U_BIA846XX()"
				SX7->X7_CDOMIN	:=	"ZZY_MATRIC"
				SX7->X7_TIPO	:=	"P"
				SX7->X7_SEEK	:=	"N"
				SX7->X7_CONDIC	:=	"SUBSTR(M->ZZY_MATRIC,1,2) == 'XX'"       
				SX7->(MsUnlock())
			
			ENDIF			

		EndIf
		RpcClearEnv()
	Next _nI
Return
