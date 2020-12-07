#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAtualizaProcessoPesagem
@author Tiago Rossini Coradini
@since 07/11/2018
@version 1.0
@description Classe para atualizacao dos processos de pesagem
@obs Projeto PBI: Tickets: 7428, 7429
@type class
/*/

Class TAtualizaProcessoPesagem From LongClassName

	Method New() Constructor
	Method GetNext() // Retorna novo sequencial do ticket
	Method Insert(cEmpOri) // Insere ticket
	Method Update(cEmpOri) // Atualiza ticke
	Method Delete() // Deleta tickets atualizados anteriormente
	Method Backup() // Efetua backup das tabelas
	Method UpdateZ12(cEmpOri) // Atualiza tabela de Z12 Ticket x Nota
	Method UpdateZZV(cEmpOri) // Atualiza tabela de cargas
	Method Execute()

EndClass


Method New() Class TAtualizaProcessoPesagem

Return()


Method GetNext() Class TAtualizaProcessoPesagem
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT MAX(Z11_PESAGE) AS SEQ "
	cSQL += " FROM " + RetSQLName("Z11")
	cSQL += " WHERE D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	cRet := Soma1((cQry)->SEQ)
	
	(cQry)->(DbCloseArea())

Return(cRet)


Method Insert(cEmpOri) Class TAtualizaProcessoPesagem
Local cSQL := ""

	cSQL := " DECLARE @SEQ VARCHAR(6) "
	cSQL += " DECLARE @RECNO INT "

	cSQL += " SET @SEQ = ISNULL((SELECT MAX(Z11_PESAGE) FROM "+ RetSQLName("Z11") +"), '000001') "
	cSQL += " SET @RECNO = ISNULL((SELECT MAX(R_E_C_N_O_) FROM "+ RetSQLName("Z11") +"), 0) "

	cSQL += " INSERT INTO "+ RetSQLName("Z11")
	cSQL += " ( "
	cSQL += " 	Z11_FILIAL, Z11_PESAGE, Z11_MERCAD, Z11_PCAVAL, Z11_UFPLAC, Z11_PCARRE, Z11_MOTORI, Z11_CODTRA, Z11_OPERIN, Z11_DATAIN, Z11_HORAIN, Z11_PESOIN, Z11_OPERSA, Z11_DATASA, " 
	cSQL += " 	Z11_HORASA, Z11_PESOSA, Z11_PESLIQ, Z11_PESCAL, Z11_PESINF, Z11_DESVIO, Z11_LJTRAN, Z11_OBSER, Z11_PALADC, Z11_SEQB, Z11_NF, Z11_PESORI, Z11_GUARDI, "
	cSQL += " 	Z11_PESMAX, Z11_CLVEIC, Z11_NOMCLI, Z11_SITUAC, Z11_MOTPAT, Z11_HORACH, Z11_CODMT, Z11_TARA, Z11_STATUS, Z11_CODMOT, Z11_TKTORI, Z11_EMPORI, D_E_L_E_T_, R_E_C_N_O_ "
	cSQL += " )	"
	cSQL += " 	SELECT Z11_FILIAL, @SEQ + ROW_NUMBER() OVER (ORDER BY Z11_PESAGE), Z11_MERCAD, Z11_PCAVAL, Z11_UFPLAC, Z11_PCARRE, Z11_MOTORI, Z11_CODTRA, Z11_OPERIN, Z11_DATAIN, Z11_HORAIN, Z11_PESOIN, Z11_OPERSA, Z11_DATASA, " 
	cSQL += " 	Z11_HORASA, Z11_PESOSA, Z11_PESLIQ, Z11_PESCAL, Z11_PESINF, Z11_DESVIO, Z11_LJTRAN, Z11_OBSER, Z11_PALADC, Z11_SEQB, Z11_NF, Z11_PESORI, Z11_GUARDI, "
	cSQL += " 	Z11_PESMAX, Z11_CLVEIC, Z11_NOMCLI, Z11_SITUAC, Z11_MOTPAT, Z11_HORACH, Z11_CODMT, Z11_TARA, Z11_STATUS, Z11_CODMOT, Z11_PESAGE, "+ ValToSQL(cEmpOri) +", D_E_L_E_T_, " 
	cSQL += " 	@RECNO + ROW_NUMBER() OVER (ORDER BY Z11_PESAGE) AS R_E_C_N_O_ "
	cSQL += " 	FROM "+ RetFullName("Z11", cEmpOri)
	cSQL += " 	WHERE Z11_FILIAL = '' "
	cSQL += " 	AND D_E_L_E_T_ = '' "

	TcSQLExec(cSQL)

Return()


Method Update(cEmpOri) Class TAtualizaProcessoPesagem

	// Notas x Ticket
	::UpdateZ12(cEmpOri)
	
	// Cargas
	::UpdateZZV(cEmpOri)

Return()


Method UpdateZ12(cEmpOri) Class TAtualizaProcessoPesagem
Local cSQL := ""
	
	// Atualiza Z12 da Biancogres
	cSQL := " UPDATE "+ RetFullName("Z12", "01")
	cSQL += " SET Z12_PESAGE = Z11.Z11_PESAGE "
	cSQL += " FROM "+ RetFullName("Z12", "01") + " Z12 "
	cSQL += " INNER JOIN "+ RetSQLName("Z11") + " Z11 "
	cSQL += " ON Z12_EMP = Z11_EMPORI "
	cSQL += " AND Z12_PESAGE = Z11_TKTORI "
	cSQL += " WHERE Z12_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += " AND Z12.D_E_L_E_T_ = '' "
	cSQL += " AND Z11_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += " AND Z11_EMPORI = " + ValToSQL(cEmpOri)
	cSQL += " AND Z11.D_E_L_E_T_ = '' "

	TcSQLExec(cSQL)
		
	// Atualiza Z12 da Incesa
	cSQL := " UPDATE " + RetFullName("Z12", "05")
	cSQL += " SET Z12_PESAGE = Z11.Z11_PESAGE "
	cSQL += " FROM "+ RetFullName("Z12", "05") + " Z12 "
	cSQL += " INNER JOIN "+ RetSQLName("Z11") + " Z11 "
	cSQL += " ON Z12_EMP = Z11_EMPORI "
	cSQL += " AND Z12_PESAGE = Z11_TKTORI "
	cSQL += " WHERE Z12_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += " AND Z12.D_E_L_E_T_ = '' "
	cSQL += " AND Z11_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += " AND Z11_EMPORI = " + ValToSQL(cEmpOri)
	cSQL += " AND Z11.D_E_L_E_T_ = '' "

	TcSQLExec(cSQL)

Return()


Method UpdateZZV(cEmpOri) Class TAtualizaProcessoPesagem
Local cSQL := ""
	
	cSQL := " UPDATE " + RetFullName("ZZV", cEmpOri)
	cSQL += " SET ZZV_TICKET = Z11.Z11_PESAGE "
	cSQL += " FROM "+ RetFullName("ZZV", cEmpOri) +" ZZV "
	cSQL += " INNER JOIN "+ RetSQLName("Z11") + " Z11 "
	cSQL += " ON ZZV_TICKET = Z11_TKTORI "
	cSQL += " WHERE ZZV_FILIAL = " + ValToSQL(xFilial("ZZV"))
	cSQL += " AND ZZV.D_E_L_E_T_ = '' "
	cSQL += " AND Z11_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += " AND Z11_EMPORI = " + ValToSQL(cEmpOri)
	cSQL += " AND Z11.D_E_L_E_T_ = '' " 

	TcSQLExec(cSQL)
 
Return()


Method Delete() Class TAtualizaProcessoPesagem
Local cSQL := ""

	cSQL := " DELETE " + RetSQLName("Z11")
	cSQL += " WHERE Z11_EMPORI <> '' "
	
	TcSQLExec(cSQL)

Return()


Method Backup() Class TAtualizaProcessoPesagem
Local cSQL := ""

	// Tabela Z11 Biancogres
	cSQL := " IF OBJECT_ID('_BKP_Z11010', 'U') IS NOT NULL "
	cSQL += " 	DROP TABLE _BKP_Z11010 "

	cSQL += " SELECT * INTO _BKP_Z11010 "
	cSQL += " FROM Z11010 "

	// Tabela Z12 Biancogres
	cSQL += " IF OBJECT_ID('_BKP_Z12010', 'U') IS NOT NULL "
	cSQL += " 	DROP TABLE _BKP_Z12010 "

	cSQL += " SELECT * INTO _BKP_Z12010 "
	cSQL += " FROM Z12010 "

	// Tabela Z12 Incesa
	cSQL += " IF OBJECT_ID('_BKP_Z12050', 'U') IS NOT NULL "
	cSQL += " 	DROP TABLE _BKP_Z12050 "

	cSQL += " SELECT * INTO _BKP_Z12050 "
	cSQL += " FROM Z12050 "

	// Tabela ZZV Biancogres
	cSQL += " IF OBJECT_ID('_BKP_ZZV010', 'U') IS NOT NULL "
	cSQL += " 	DROP TABLE _BKP_ZZV010 "

	cSQL += " SELECT * INTO _BKP_ZZV010 "
	cSQL += " FROM ZZV010 "

	// Tabela ZZV Incesa
	cSQL += " IF OBJECT_ID('_BKP_ZZV050', 'U') IS NOT NULL "
	cSQL += " 	DROP TABLE _BKP_ZZV050 "

	cSQL += " SELECT * INTO _BKP_ZZV050 "
	cSQL += " FROM ZZV050 "

	// Tabela ZZV Lm
	cSQL += " IF OBJECT_ID('_BKP_ZZV070', 'U') IS NOT NULL "
	cSQL += " 	DROP TABLE _BKP_ZZV070 "

	cSQL += " SELECT * INTO _BKP_ZZV070 "
	cSQL += " FROM ZZV070 "

	// Tabela ZZV Mundi
	cSQL += " IF OBJECT_ID('_BKP_ZZV130', 'U') IS NOT NULL "
	cSQL += " 	DROP TABLE _BKP_ZZV130 "

	cSQL += " SELECT * INTO _BKP_ZZV130 "
	cSQL += " FROM ZZV130 "

	// Tabela ZZV Vitcer
	cSQL += " IF OBJECT_ID('_BKP_ZZV140', 'U') IS NOT NULL "
	cSQL += " 	DROP TABLE _BKP_ZZV140 "
	
	cSQL += " SELECT * INTO _BKP_ZZV140 "
	cSQL += " FROM ZZV140 "

	TcSQLExec(cSQL)

Return()


Method Execute() Class TAtualizaProcessoPesagem	
Local cHrIni := ""
Local cHrFin := ""

	cHrIni := Time()
	
	// Deleta registros processados anteriormente
	::Delete()
	
	// Backup das tabelas
	::Backup()
	
	// Incesa
	::Insert("05")
	::Update("05")

	// Lm
	::Insert("07")
	::Update("07")
	
	// Mundi
	::Insert("13")
	::Update("13")
	
	// Vitcer
	::Insert("14")
	::Update("14")
	
	cHrFin := Time()
	
	MsgInfo("Tempo de processamento - " + ElapTime(cHrIni, cHrFin))
		
Return()