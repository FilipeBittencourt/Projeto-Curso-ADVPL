#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0013; Return()

/*
|-----------------------------------------------------------|
| Classe:	| TPolicard													 							|
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				|
| Data:		| 24/08/15																				|
|-----------------------------------------------------------|
| Desc.:	|	Classe para tratamento do layout de creditos da	|
| 				|	Policard - Benefícios														|
| 				|	Layout de pedidos - Versão 2.7									|
|-----------------------------------------------------------|
| OS:			|	2387-15 - Usuário: Claudia Mara   		 					|
|-----------------------------------------------------------|
*/

Class TPolicard From LongClassName

	Data nHandle // Handle do arquivo
	Data cLinha // Linha do arquivo	
	Data cCodCli // Codigo do cliente - Bianco: 126746, Incesa: 112710
	Data cCodPrd // Codigo do produto - Bianco: 0073-Combustivel, Incesa: 0067-Presente
	Data cDia // Dia
	Data cMes // Mes
	Data cAno // Ano
	Data cHora // Hora
	Data cParAnoMes // Parametro de ano mes de referecnia, utilizado para filtrar movimentos por periodo
	Data cTipBen // Tipo de beneficio: 4-Combustivel, 5-Premiação
	Data nQtdReg // Quantidade total de registros do arquivo 0 a 9
	Data nTotReg1 // Somatória dos registros 0 a 4 da coluna 9 até a posição 12
	Data nTotReg2 // Soma dos valores mencionados no registro 4 (seqüência 9)
	Data cNomRes // Nome do responsavel pelo departamento
	Data cCpfRes // Cpf do responsavel pelo departamento
	
	Method New() Constructor
	Method Get(cTipBen, nHandle, cParAnoMes) // Retorna 
	Method GetReg0() // Registro tipo 0 – (Identificação da empresa)
	Method GetReg1() // Registro tipo 1 – (Identificação dos locais)
	Method GetReg2() // Registro tipo 2 – (Identificação cadastro de departamentos)
	Method GetReg3() // Registro tipo 3 – (Identificação cadastro de usuário)
	Method GetReg4() // Registro tipo 4 – (Identificação do produto, quantidade e valor)
	Method GetReg9() // Registro tipo 9 – (Totalizador, finalizador do pedido)
	Method GetNumStr() // Retorna somente numeros de um string
	
EndClass


Method New() Class TPolicard

	::nHandle := 0
	::cLinha := ""
	::cCodCli := ""
	::cCodPrd := ""
	::cDia := Day2Str(dDataBase)
	::cMes := Month2Str(dDataBase)
	::cAno := Year2Str(dDataBase)
	::cHora := SubStr(StrTran(Time(),":", ""), 1, 4)	
	::cTipBen := ""
	::cParAnoMes := ""
	::nQtdReg := 0
	::nTotReg1 := 0
	::nTotReg2 := 0
	::cNomRes := "CLAUDIA MARA GOMES CARDOSO"
	::cCpfRes := "00185100783"
	
Return()


Method Get(cTipBen, nHandle, cParAnoMes) Class TPolicard

	// Define codigo do cliente na Policard
	If cEmpAnt == "01"
		
		::cCodCli := "126746"
		
	ElseIf cEmpAnt == "05"
		
		::cCodCli := "112710"
		
	EndIf
	
	// Define codigo do produto pelo Tipo de beneficio: 4-Combustivel, 5-Premiação
	::cTipBen := cTipBen
	
	If ::cTipBen == "4"
		
		::cCodPrd := "0073"
		
	ElseIf ::cTipBen == "5"

		::cCodPrd := "0068"
		
	EndIf		
		
	// Define Handle do arquivo
	::nHandle := nHandle
	
	// Define parametro de ano/mes para filtro de funcionarios
	::cParAnoMes := cParAnoMes
	
	::nQtdReg := 0
	
	::nTotReg1 := 0
	
	::nTotReg2 := 0
	
	// Retorna Informações do Registro tipo 0 – (Identificação da empresa)
	::GetReg0()	
	
	// Retorna Informações do Registro tipo 1 – (Identificação dos locais)
	::GetReg1()
	
	// Retorna Informações do Registro tipo 2 – (Identificação cadastro de departamentos)
	::GetReg2()
	
	// Retorna Informações do Registro tipo 3 – (Identificação cadastro de usuário)
	::GetReg3()
	
	// Retorna Informações do Registro tipo 4 – (Identificação do produto, quantidade e valor)
	::GetReg4()
	
	// Retorna Informações do Registro tipo 9 – (Totalizador, finalizador do pedido)
	::GetReg9()
	
Return()


Method GetReg0() Class TPolicard
		
	::nQtdReg++
	
	::cLinha := ""
	::cLinha += PadR("0", 1) // TIPO DE REGISTRO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(Val(::cCodCli), 10), 10) // CODIGO DO CLIENTE
	::cLinha += PadR(Space(1), 1)	// FILLER	
	::cLinha += PadR(SM0->M0_NOMECOM, 40) // RAZAO SOCIAL DO CLIENTE
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(::cMes + ::cAno, 6)	// PERIODO DE REFERENCIA
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(::cDia + ::cMes + ::cAno, 8) // DATA DE GERACAO DO ARQUIVO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(::cDia + ::cMes + ::cAno, 8) // DATA DE ENTREGA DO PEDIDO
	::cLinha += PadR(Space(1), 322)	// FILLER
	
	::nTotReg1 += Val(SubStr(::cLinha, 9, 4))
	
	fWrite(::nHandle, ::cLinha + CRLF)

Return()


Method GetReg1() Class TPolicard

	::nQtdReg++
		
	::cLinha := ""	
	::cLinha += PadR("1", 1) // TIPO DE REGISTRO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(1, 10), 10) // CODIGO DO LOCAL
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR("1", 1) // IDENTIFICACAO DO LOCAL - LOCAL DE ENTREGA
	::cLinha += PadR("1", 1) // IDENTIFICACAO DO LOCAL - COBRANCA
	::cLinha += PadR("1", 1) // IDENTIFICACAO DO LOCAL - FATURAMENTO
	::cLinha += PadR("1", 1) // IDENTIFICACAO DO LOCAL - ENTREGA DA FATURA
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(SM0->M0_NOMECOM, 40) // RAZAO SOCIAL DO CLIENTE
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(SubStr(SM0->M0_ENDENT, 1, At(",", SM0->M0_ENDENT)-1), 40) // LOGRADOURO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(SubStr(SM0->M0_ENDENT, At(",", SM0->M0_ENDENT)+1, 5), 5) // NUMERO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(SM0->M0_COMPENT, 30) // COMPLEMENTO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(SM0->M0_BAIRENT, 40) // BAIRRO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(SM0->M0_CIDENT, 40) // CIDADE
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(SM0->M0_ESTENT, 2) // ESTADO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(SM0->M0_CEPENT, 8) // CEP
	::cLinha += PadR(Space(1), 1)	// FILLER
	
	::cLinha += PadR(::cNomRes, 30) // NOME RESPONSAVEL
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(Space(1), 28) // CARGO DO RESPONSAVEL
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(Space(1), 30) // DEPARTAMENTO DO RESPONSAVEL
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(::cCpfRes, 11) // CPF DO RESPONSAVEL
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(0, 2), 2) // DDD
	::cLinha += PadR(StrZero(0, 8), 8) // TEL
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(0, 8), 8) // RAMAL
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(0, 2), 2) // DDD
	::cLinha += PadR(StrZero(0, 8), 8) // CELULAR
	::cLinha += PadR(Space(1), 1)	// FILLER
	
	::cLinha += PadR(StrZero(1, 10), 10) // CDDIGO DO LOCAL DE COBRANCA
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(1, 10), 10) // CDDIGO DO LOCAL PARA FATURAMENTO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(1, 10), 10) // CDDIGO DO LOCAL DE ENTREGA DA FATURA
	::cLinha += PadR(Space(1), 3)	// FILLER

	::nTotReg1 += Val(SubStr(::cLinha, 9, 4))
	
	fWrite(::nHandle, ::cLinha + CRLF)
	
Return()


Method GetReg2() Class TPolicard

	::nQtdReg++
	
	::cLinha := ""
	::cLinha += PadR("2", 1) // TIPO DE REGISTRO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(1, 10), 10) // CODIGO DO DEPARTAMENTO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(1, 10), 10) // CODIGO DO LOCAL
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR("RECURSOS HUMANOS", 30) // DESCRICAO DO DEPARTAMENTO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(::cNomRes, 30) // NOME RESP. DEPTO 1
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(::cCpfRes, 11) // CPF RESP. DEPTO 1
	::cLinha += PadR(Space(1), 303)	// FILLER

	::nTotReg1 += Val(SubStr(::cLinha, 9, 4))
	
	fWrite(::nHandle, ::cLinha + CRLF)
	
Return()


Method GetReg3() Class TPolicard
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSZS := RetSQLName("SZS")
Local cSRA := RetSQLName("SRA")
		
	cSQL := " SELECT RA_CIC, RA_MAT, RA_NOME, RA_NASC, RA_SEXO, RA_NOME, RA_RG, RA_RGUF, RA_DTRGEXP, RA_ENDEREC, RA_NUMENDE, RA_COMPLEM, RA_BAIRRO, RA_MUNICIP, RA_ESTADO, RA_CEP,  "
	cSQL += " RA_MAE, RA_PAI, RA_DDDFONE, RA_TELEFON, RA_DDDCELU, RA_NUMCELU "
	cSQL += " FROM "+ cSZS +" SZS INNER JOIN "+ cSRA +" SRA "
	cSQL += " ON ZS_FILIAL = RA_FILIAL "
	cSQL += " AND ZS_MAT = RA_MAT "
	cSQL += " WHERE ZS_FILIAL = "+ ValToSQL(xFilial("SZS"))
	cSQL += " AND ZS_MESANO = "+ ValToSQL(::cParAnoMes)
	cSQL += " AND ZS_BENEF = "+ ValToSQL(::cTipBen)
	cSQL += " AND ZS_MAT <> '' "
	cSQL += " AND SZS.D_E_L_E_T_ = ''	"
	cSQL += " AND RA_SITFOLH <> 'D'	"
	cSQL += " AND SRA.D_E_L_E_T_ = ''	"
		
	TcQuery cSQL New Alias (cQry)
					
	While !(cQry)->(Eof())

		::nQtdReg++
	
		::cLinha := ""	
		::cLinha += PadR("3", 1) // TIPO DE REGISTRO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_CIC, 11) // CPF DO FUNCIONARIO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(StrZero(1, 10), 10) // CODIGO DO DEPARTAMENTO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_MAT, 10) // MATRICULA DO FUNCIONARIO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_NOME, 40) // NOME DO FUNCIONARIO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SubStr((cQry)->RA_NASC, 7, 2) + SubStr((cQry)->RA_NASC, 5, 2) + SubStr((cQry)->RA_NASC, 1, 4), 8) // DATA NASCIMENTO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_SEXO, 1) // SEXO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(Space(1), 24) // NOME DO FUNCIONARIO - PERSONALIZADO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(::GetNumStr((cQry)->RA_RG), 15) // NUMERO DO RG
		::cLinha += PadR(Space(1), 1)	// FILLER		
		::cLinha += PadR(/*(cQry)->RA_RGUF*/Space(1), 2) // UF EMISSORA DO RG
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SubStr((cQry)->RA_DTRGEXP, 7, 2) + SubStr((cQry)->RA_DTRGEXP, 5, 2) + SubStr((cQry)->RA_DTRGEXP, 1, 4), 8) // DATA EMISSAO DO RG
		::cLinha += PadR(Space(1), 1)	// FILLER
		
		/* Bloco comentado pois alguns funcionarios possuem endereço cadastrado errado		
		::cLinha += PadR((cQry)->RA_ENDEREC, 40) // LOGRADOURO - ENDERECO
		::cLinha += PadR(Space(1), 1)	// FILLER		
		::cLinha += PadR((cQry)->RA_NUMENDE, 5) // NUMERO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_COMPLEM, 20) // COMPLEMENTO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_BAIRRO, 20) // BAIRRO
		::cLinha += PadR(Space(1), 1)	// FILLER				
		::cLinha += PadR((cQry)->RA_MUNICIP, 20) // CIDADE
		::cLinha += PadR(Space(1), 1)	// FILLER						
		::cLinha += PadR((cQry)->RA_ESTADO, 2) // ESTADO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_CEP, 8) // CEP
		::cLinha += PadR(Space(1), 1)	// FILLER
		*/
    
		// Envia endereco da empresa como padrão
		::cLinha += PadR(SubStr(SM0->M0_ENDENT, 1, At(",", SM0->M0_ENDENT)-1), 40) // LOGRADOURO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SubStr(SM0->M0_ENDENT, At(",", SM0->M0_ENDENT)+1, 5), 5) // NUMERO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SM0->M0_COMPENT, 20) // COMPLEMENTO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SM0->M0_BAIRENT, 20) // BAIRRO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SM0->M0_CIDENT, 20) // CIDADE
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SM0->M0_ESTENT, 2) // ESTADO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SM0->M0_CEPENT, 8) // CEP
		::cLinha += PadR(Space(1), 1)	// FILLER
		
		::cLinha += PadR((cQry)->RA_MAE, 40) // NOME DA MAE
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_PAI, 40) // NOME DO PAI
		::cLinha += PadR(Space(1), 1)	// FILLER				
		
		/* Bloco comentado pois alguns funcionarios não possuem telefone cadastrado
		// Telefone fixo
		If !Empty((cQry)->RA_DDDFONE) .And. !Empty((cQry)->RA_TELEFON)
		
			::cLinha += PadR("1", 1) // TIPO DE TELEFONE - 1-FIXO; 2-CELULAR
			::cLinha += PadR(Space(1), 1)	// FILLER
			::cLinha += PadR((cQry)->RA_DDDFONE, 2) // DDD
			::cLinha += PadR(Space(1), 1)	// FILLER
			::cLinha += PadR((cQry)->RA_TELEFON, 9) // NUMERO DO TELEFONE
			::cLinha += PadR(Space(1), 1)	// FILLER
		
		// Telefone celular	
		ElseIf !Empty((cQry)->RA_DDDCELU) .And. !Empty((cQry)->RA_NUMCELU)
		
			::cLinha += PadR("2", 1) // TIPO DE TELEFONE - 1-FIXO; 2-CELULAR
			::cLinha += PadR(Space(1), 1)	// FILLER
			::cLinha += PadR((cQry)->RA_DDDCELU, 2) // DDD
			::cLinha += PadR(Space(1), 1)	// FILLER
			::cLinha += PadR((cQry)->RA_NUMCELU, 9) // NUMERO DO TELEFONE
			::cLinha += PadR(Space(1), 1)	// FILLER
			
		EndIf
		*/
		
		// Envia DDD e Telefone da empresa como padrão
		::cLinha += PadR("1", 1) // TIPO DE TELEFONE - 1-FIXO; 2-CELULAR
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SubStr(SM0->M0_TEL, 4, 2), 2) // DDD
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(SubStr(SM0->M0_TEL, 7, 8), 9) // NUMERO DO TELEFONE
		::cLinha += PadR(Space(1), 1)	// FILLER
			
		::cLinha += PadR("NAO", 3) // PESSOA EXPOSTA POLITICAMENTE (PEP) - SIM/NAO
		::cLinha += PadR(Space(1), 37)	// FILLER

		::nTotReg1 += Val(SubStr(::cLinha, 9, 4))

		fWrite(::nHandle, ::cLinha + CRLF)
		
		(cQry)->(DbSkip())
		
	EndDo

	(cQry)->(DbCloseArea())
		
Return()


Method GetReg4() Class TPolicard
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSZS := RetSQLName("SZS")
Local cSRA := RetSQLName("SRA")
		
	cSQL := " SELECT RA_CIC, RA_MAT, ZS_VALOR "
	cSQL += " FROM "+ cSZS +" SZS INNER JOIN "+ cSRA +" SRA "
	cSQL += " ON ZS_FILIAL = RA_FILIAL "
	cSQL += " AND ZS_MAT = RA_MAT "
	cSQL += " WHERE ZS_FILIAL = "+ ValToSQL(xFilial("SZS"))
	cSQL += " AND ZS_MESANO = "+ ValToSQL(::cParAnoMes)
	cSQL += " AND ZS_BENEF = "+ ValToSQL(::cTipBen)
	cSQL += " AND ZS_MAT <> '' "
	cSQL += " AND SZS.D_E_L_E_T_ = ''	"
	cSQL += " AND RA_SITFOLH <> 'D'	"
	cSQL += " AND SRA.D_E_L_E_T_ = ''	"
		
	TcQuery cSQL New Alias (cQry)
					
	While !(cQry)->(Eof())

		::nQtdReg++
	
		::cLinha := ""	
		::cLinha += PadR("4", 1) // TIPO DE REGISTRO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR((cQry)->RA_CIC, 11) // CPF DO FUNCIONARIO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(::cCodPrd, 4) // CODIGO DO PRODUTO
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(StrZero(1, 4), 4) // QUANTIDADE
		::cLinha += PadR(Space(1), 1)	// FILLER
		::cLinha += PadR(StrZero((cQry)->ZS_VALOR * 100, 8), 8) // VALOR FACIAL / CREDITO
		::cLinha += PadR(Space(1), 1)	// FILLER						
		::cLinha += PadR((cQry)->RA_MAT, 10) // MATRICULA DO FUNCIONARIO
		::cLinha += PadR(Space(1), 357)	// FILLER
		
		::nTotReg1 += Val(SubStr(::cLinha, 9, 4))
		
		::nTotReg2 += Val(SubStr(::cLinha, 25, 8))
		
		fWrite(::nHandle, ::cLinha + CRLF)
		
		(cQry)->(DbSkip())
		
	EndDo

	(cQry)->(DbCloseArea())
	
Return()


Method GetReg9() Class TPolicard

	::nQtdReg++
	
	::cLinha := ""
	::cLinha += PadR("9", 1) // TIPO DE REGISTRO
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(::nQtdReg, 6), 6) // QUANTIDADE DE REGITROS
	::cLinha += PadR(Space(1), 1)	// FILLER
	::cLinha += PadR(StrZero(::nTotReg1 + ::nTotReg2 + ::nQtdReg, 21), 21) // NUMERO DE CONTROLE
	::cLinha += PadR(Space(1), 370)	// FILLER
	
	fWrite(::nHandle, ::cLinha + CRLF)
	
Return()


Method GetNumStr(cPar) Class TPolicard
Local cRet := ""
Local nCount := 0

	For nCount := 1 To Len(cPar)
		
		If IsDigit(Substr(cPar, nCount, 1))
			cRet += Substr(cPar, nCount, 1)
		Endif
		
	Next

Return(cRet)