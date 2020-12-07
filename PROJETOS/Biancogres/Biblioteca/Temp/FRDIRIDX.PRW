#include "TOTVS.CH"


User Function FRDIRIDX


	Local nCont := 0
	Local I, J
	Local aFiles
	Local ND

	RPCSetType(3)
	WfPrepEnv("01", "01") 	


	_ADIR := {"\system\asc_*.idx","\system\des_*.idx"}

	FOR ND := 1 to Len(_ADIR)

		aFiles := Directory(_ADIR[ND], "D")

		nCont := Len(aFiles)

		ConOut("FRDIRIDX ==> removendo "+Alltrim(str(nCont))+" arquivos.")

		For I := 1 To nCont

			ConOut("FRDIRIDX ==> processando diretorio "+AllTrim(Str(I))+": "+aFiles[I][1])

			cDelPath := "\system\"+aFiles[I][1]

			_aSubFiles := Directory(cDelPath+"\*.*", "D")

			For J := 1 To Len(_aSubFiles)

				If Len(_aSubFiles[J][1]) > 5

					_cFile := cDelPath+"\"+_aSubFiles[J][1]

					ConOut("FRDIRIDX ==> removendo arquivo "+_cFile)

					_ndel := FErase(_cFile)

					If _ndel <> 0

						ConOut("FRDIRIDX ==> Falha ao remover o arquivo "+_cFile+" ERRO: "+AllTrim(Str(FError())))

					EndIf

				EndIf

			Next J

			lRemoveOk := DirRemove( cDelPath )

			if !lRemoveOk
				ConOut("FRDIRIDX ==> Falha ao remover o diretorio "+cDelPath)
			Else
				ConOut("FRDIRIDX ==> Removido com sucesso o diretorio "+cDelPath)
			endif

		Next I

	NEXT ND

Return