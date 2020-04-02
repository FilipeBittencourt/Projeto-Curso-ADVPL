User Function M410PVNF()
Local oDocSai := TCacDocumentoSaida():New()

	If oDocSai:PossuiDanfeATransmitir()
		Aviso("M410PVNF",OemToAnsi("A emissão de Documentos de Saída estará liberada após transmissão de todas as DANFES."),{"Ok"},2)
	EndIf
Return(!oDocSai:lPossuiDanfeATransmitir)