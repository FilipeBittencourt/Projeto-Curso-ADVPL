#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

Class TCacDocumentoSaida From LongClassName
	Data nQuantidadeDanfesATransmitir
	Data lPossuiDanfeATransmitir

	Method New() Constructor
	Method PossuiDanfeATransmitir()
End Class

Method New() Class TCacDocumentoSaida
	::nQuantidadeDanfesATransmitir := 0
	::lPossuiDanfeATransmitir := .F.
Return Self

Method PossuiDanfeATransmitir() Class TCacDocumentoSaida
Local cSql   := ""
Local cAlias := "QRYNF"
Local aArea  := GetArea()

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	cSql += "SELECT COUNT(*) DANFES_A_TRANSMITIR " + CRLF
	cSql += "  FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) " + CRLF
	cSql += " WHERE F2_FILIAL BETWEEN '' AND 'ZZ' " + CRLF
	cSql += "   AND F2_FIMP = ' ' " + CRLF
	cSql += "   AND F2_ESPECIE = 'SPED' " + CRLF
	cSql += "   AND F2_CHVNFE NOT IN ('32140839346283000163550010000050681000053580', " + CRLF
	cSql += "                         '32140839346283000163550010000050701000053600', " + CRLF
	cSql += "                         '32140839346283000163550010000050711000053616', " + CRLF
	cSql += "                         '32140839346283000163550010000050641000053573') " + CRLF
	cSql += "   AND SF2.D_E_L_E_T_ = '' " + CRLF
	cSql += "   AND NOT EXISTS ( " + CRLF
	cSql += "       SELECT 1  " + CRLF
	cSql += "	     FROM SPED050 SPED (NOLOCK)  " + CRLF
	cSql += "		WHERE NFE_ID = F2_SERIE + F2_DOC " + CRLF
	cSql += "		  AND D_E_L_E_T_ = '') "

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAlias,.T.,.T.)
		
	DbSelectArea(cAlias)

	::nQuantidadeDanfesATransmitir := 0
		
	If !Eof()	
		::nQuantidadeDanfesATransmitir := (cAlias)->DANFES_A_TRANSMITIR
	EndIf
	
	DbCloseArea()
	
	RestArea(aArea)

	::lPossuiDANFEATransmitir := ::nQuantidadeDanfesATransmitir > 0
Return(::lPossuiDanfeATransmitir)