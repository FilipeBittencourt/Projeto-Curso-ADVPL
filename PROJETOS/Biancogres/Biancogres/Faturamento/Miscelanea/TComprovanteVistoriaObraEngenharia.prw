#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TComprovanteVistoriaObraEngenharia
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe para controle do Comprovante de Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type class
/*/

Class TComprovanteVistoriaObraEngenharia From LongClassName 
	
	Data oParam

	Data dSurveyForecast
	Data dSurveyRealization
	Data cSigned	
	Data c01SourceFile
	Data c02SourceFile
	Data c03SourceFile		
	Data c01FileExtension
	Data c02FileExtension
	Data c03FileExtension
	Data cTargetPath
	Data c01TargetFile
	Data c02TargetFile
	Data c03TargetFile	
	
	Method New() Constructor
	Method SelectFile()
	Method CopyFile()
	Method Copy01File()
	Method Copy02File()
	Method Copy03File()
	Method Rename01File()
	Method Rename02File()
	Method Rename03File()	
	Method Save(aSurvey)
	Method View()
	
EndClass


Method New() Class TComprovanteVistoriaObraEngenharia

	::oParam := TParComprovanteVistoriaObraEngenharia():New()

	::dSurveyForecast := dDataBase
	::dSurveyRealization := dDataBase
	::cSigned := ""
	::c01SourceFile := ""
	::c02SourceFile := ""
	::c03SourceFile := ""		
	::c01FileExtension := ""
	::c02FileExtension := ""
	::c03FileExtension := ""	
	::cTargetPath := "\p10\vistoria_obra\comprovante\"
	::c01TargetFile := ""
	::c02TargetFile := ""
	::c03TargetFile := ""		

Return()


Method SelectFile() Class TComprovanteVistoriaObraEngenharia
Local lRet := .T.
	
	::oParam:dSurveyForecast := ::dSurveyForecast
	::oParam:dSurveyRealization := ::dSurveyRealization	
	
	If (lRet := ::oParam:Box())

		::dSurveyRealization := ::oParam:dSurveyRealization
		::cSigned := SubStr(::oParam:cSigned, 1, 1)

		::c01SourceFile := ::oParam:c01File
		::c01FileExtension := AllTrim(SubStr(::c01SourceFile, Rat('.', ::c01SourceFile)))
		::c01TargetFile := ::cTargetPath + "comprovante-01_" + cEmpAnt + "_" + dToS(::dSurveyRealization) + "_" + StrZero(Seconds() * 3500, 10) + ::c01FileExtension
					
		If File(::oParam:c02File)

			::c02SourceFile := ::oParam:c02File
			::c02FileExtension := AllTrim(SubStr(::c02SourceFile, Rat('.', ::c02SourceFile)))
			::c02TargetFile := ::cTargetPath + "comprovante-02_" + cEmpAnt + "_" + dToS(::dSurveyRealization) + "_" + StrZero(Seconds() * 3500, 10) + ::c02FileExtension

		EndIf
		
		If File(::oParam:c03File)

			::c03SourceFile := ::oParam:c03File
			::c03FileExtension := AllTrim(SubStr(::c03SourceFile, Rat('.', ::c03SourceFile)))
			::c03TargetFile := ::cTargetPath + "comprovante-03_" + cEmpAnt + "_" + dToS(::dSurveyRealization) + "_" + StrZero(Seconds() * 3500, 10) + ::c03FileExtension

		EndIf
				
	EndIf

Return(lRet)


Method CopyFile() Class TComprovanteVistoriaObraEngenharia
Local lRet := .T.
		
	lRet := (::Copy01File() .And. ::Rename01File()) .And. (::Copy02File() .And. ::Rename02File()) .And. (::Copy03File() .And. ::Rename03File()) 
	
Return(lRet)


Method Copy01File() Class TComprovanteVistoriaObraEngenharia
Local lRet := .T.
	
	lRet := CpyT2S(::c01SourceFile, ::cTargetPath)
	
Return(lRet)


Method Copy02File() Class TComprovanteVistoriaObraEngenharia
Local lRet := .T.
	
	If !Empty(::c02SourceFile)
	
		lRet := CpyT2S(::c02SourceFile, ::cTargetPath)
		
	EndIf
	
Return(lRet)


Method Copy03File() Class TComprovanteVistoriaObraEngenharia
Local lRet := .T.
	
	If !Empty(::c03SourceFile)
	
		lRet := CpyT2S(::c03SourceFile, ::cTargetPath)
		
	EndIf
	
Return(lRet)


Method Rename01File() Class TComprovanteVistoriaObraEngenharia
Local lRet := .T.
	
	lRet := FRename(::cTargetPath + RetFileName(::c01SourceFile) + ::c01FileExtension, ::c01TargetFile) == 0

Return(lRet)


Method Rename02File() Class TComprovanteVistoriaObraEngenharia
Local lRet := .T.
	
	If !Empty(::c02SourceFile)
	
		lRet := FRename(::cTargetPath + RetFileName(::c02SourceFile) + ::c02FileExtension, ::c02TargetFile) == 0
		
	EndIf

Return(lRet)


Method Rename03File() Class TComprovanteVistoriaObraEngenharia
Local lRet := .T.
	
	If !Empty(::c03SourceFile)
	
		lRet := FRename(::cTargetPath + RetFileName(::c03SourceFile) + ::c03FileExtension, ::c03TargetFile) == 0
		
	EndIf

Return(lRet)


Method Save(aSurvey) Class TComprovanteVistoriaObraEngenharia
Local aArea := GetArea()
Local nCount := 0
Local nRecNo := 0

	Begin Transaction
	
		For nCount := 1 To Len(aSurvey)
	
			DbSelectArea("ZKS")
			nRecNo := aSurvey[nCount, 2]
			
			If ValType(nRecNo) == 'C'
				
				nRecNo := Val(nRecNo)
				
			EndIf
			
			ZKS->(DbGoTo(nRecNo))
			
			RecLock("ZKS", .F.)
			
				ZKS->ZKS_STATUS := "2"
				ZKS->ZKS_DATVIS := ::dSurveyRealization
				ZKS->ZKS_ASSINA := ::cSigned
				ZKS_ARQCP1 := RetFileName(::c01TargetFile) + ::c01FileExtension
				ZKS_ARQCP2 := RetFileName(::c02TargetFile) + ::c02FileExtension
				ZKS_ARQCP3 := RetFileName(::c03TargetFile) + ::c03FileExtension
				
			ZKS->(MsUnLock())
			
		Next
	
	End Transaction

	RestArea(aArea)

Return()



Method View() Class TComprovanteVistoriaObraEngenharia

Return()