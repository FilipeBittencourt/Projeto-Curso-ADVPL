using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.Financeiro.BoletoNetCore
{
    public static class BancoInterface
    {
        //LEITURA GENERICA DE REGISTRO DE RETRONO CNAB 240 - SEGMENTO G (DDA) - FEBRABAN
        public static void LerDetalheRetornoCNAB240SegmentoG(ref Pagamento pagamento, string registro)
        {
            try
            {
                pagamento.CodigoBarras = registro.Substring(17, 44);

                string str = registro.Substring(62, 15);
                pagamento.CPFCNPJFavorecido = str.Substring(str.Length - 14, 14);

                pagamento.NomeFavorecido = registro.Substring(77, 40);

                //Data Vencimento do Título
                pagamento.DataVencimento = Utils.ToDateTime(Utils.ToInt32(registro.Substring(107, 8)).ToString("##-##-####"));

                //Valor do Título
                pagamento.ValorTitulo = Convert.ToDecimal(registro.Substring(115, 15)) / 100;

                //Nº Controle do Participante
                pagamento.NumeroDocumento = registro.Substring(147, 15);

                //Carteira
                pagamento.Carteira = registro.Substring(178, 1);

                var _especie = registro.Substring(179, 2);
                pagamento.EspecieDocumento = (TipoEspecieDocumento)Enum.Parse(typeof(TipoEspecieDocumento), _especie, true);

                //Data de Emissao
                pagamento.DataEmissao = Utils.ToDateTime(Utils.ToInt32(registro.Substring(181, 8)).ToString("##-##-####"));

                //Juros por dia
                pagamento.PercentualJurosDia = Convert.ToDecimal(registro.Substring(189, 15)) / 100;

                //Registro Completo
                pagamento.RegistroArquivoRetorno = pagamento.RegistroArquivoRetorno + registro + Environment.NewLine;
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler detalhe do arquivo de RETORNO / CNAB 240 / Segmento G.", ex);
            }
        }

        //LEITURA GENERICA DE REGISTRO DE RETRONO CNAB 240 - SEGMENTO A (DOC/TED) - FEBRABAN
        public static void LerDetalheRetornoCNAB240SegmentoA(ref Pagamento pagamento, string registro)
        {
            try
            {
                //Identificação de Ocorrência
                pagamento.CodigoOcorrencia = registro.Substring(15, 2);
                pagamento.DescricaoOcorrencia = pagamento.CodigoOcorrencia == "00" ? "Inclusão" : "Exclusão";
                pagamento.CodigoCameraCentralizadora = registro.Substring(17, 3);

                pagamento.CodigoBancoFavorecido = registro.Substring(20, 3);
                pagamento.AgenciaFavorecido = registro.Substring(23, 5);
                pagamento.DigitoAgenciaFavorecido = registro.Substring(28, 1);
                pagamento.ContaFavorecido = registro.Substring(29, 12);
                pagamento.DigitoContaFavorecido = registro.Substring(41, 1);
                pagamento.SegundoDigitoContaFavorecido = registro.Substring(42, 1);

                pagamento.NomeFavorecido = registro.Substring(43, 30);

                pagamento.NumeroDocumento = registro.Substring(73, 20);

                pagamento.DataPagamento = Utils.ToDateTime(Utils.ToInt32(registro.Substring(93, 8)).ToString("##-##-####"));
                pagamento.ValorTitulo = Convert.ToDecimal(registro.Substring(119, 15)) / 100;

                pagamento.NumeroDocumentoBanco = registro.Substring(134, 20);

                pagamento.DataEfetivacao = Utils.ToDateTime(Utils.ToInt32(registro.Substring(154, 8)).ToString("##-##-####"));
                pagamento.ValorPago = Convert.ToDecimal(registro.Substring(162, 15)) / 100;

                pagamento.OutrasInformacoes = registro.Substring(177, 40);

                pagamento.OcorrenciasRetorno = registro.Substring(230, 10);

                //Registro Completo
                pagamento.RegistroArquivoRetorno = pagamento.RegistroArquivoRetorno + registro + Environment.NewLine;
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler detalhe do arquivo de RETORNO / CNAB 240 / Segmento A.", ex);
            }
        }

        //LEITURA GENERICA DE REGISTRO DE RETRONO CNAB 240 - SEGMENTO B (DOC/TED) - FEBRABAN
        public static void LerDetalheRetornoCNAB240SegmentoB(ref Pagamento pagamento, string registro)
        {
            try
            {
                pagamento.CPFCNPJFavorecido = registro.Substring(18, 14);

                //Registro Completo
                pagamento.RegistroArquivoRetorno = pagamento.RegistroArquivoRetorno + registro + Environment.NewLine;
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler detalhe do arquivo de RETORNO / CNAB 240 / Segmento B.", ex);
            }
        }

        //LEITURA GENERICA DE REGISTRO DE RETRONO CNAB 240 - SEGMENTO Z (COMPROVANTE) - FEBRABAN
        public static void LerDetalheRetornoCNAB240SegmentoZ(ref Pagamento pagamento, string registro)
        {
            try
            {
                pagamento.AutenticacaoBancaria = registro.Substring(78, 25);

                //Registro Completo
                pagamento.RegistroArquivoRetorno = pagamento.RegistroArquivoRetorno + registro + Environment.NewLine;
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler detalhe do arquivo de RETORNO / CNAB 240 / Segmento Z.", ex);
            }
        }

        //LEITURA GENERICA DE REGISTRO DE RETRONO CNAB 240 - SEGMENTO J (BOLETOS) - FEBRABAN
        public static void LerDetalheRetornoCNAB240SegmentoJ(ref Pagamento pagamento, string registro)
        {
            try
            {
                pagamento.CodigoBarras = registro.Substring(17, 44);

                pagamento.NomeFavorecido = registro.Substring(61, 30);

                //Data Vencimento do Título
                pagamento.DataVencimento = Utils.ToDateTime(Utils.ToInt32(registro.Substring(91, 8)).ToString("##-##-####"));

                //Valor do Título
                pagamento.ValorTitulo = Convert.ToDecimal(registro.Substring(99, 15)) / 100;
                pagamento.ValorDesconto = Convert.ToDecimal(registro.Substring(114, 15)) / 100;
                pagamento.ValorMulta = Convert.ToDecimal(registro.Substring(129, 15)) / 100;

                pagamento.DataPagamento = Utils.ToDateTime(Utils.ToInt32(registro.Substring(144, 8)).ToString("##-##-####"));

                pagamento.ValorPago = Convert.ToDecimal(registro.Substring(152, 15)) / 100;

                pagamento.NumeroDocumento = registro.Substring(182, 20);
                pagamento.NumeroDocumentoBanco = registro.Substring(202, 20);

                pagamento.OcorrenciasRetorno = registro.Substring(230, 10);
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler detalhe do arquivo de RETORNO / CNAB 240 / Segmento J.", ex);
            }
        }

        //LEITURA GENERICA DE REGISTRO DE RETRONO CNAB 240 - SEGMENTO E (EXTRATO) - FEBRABAN
        public static void LerDetalheRetornoCNAB240SegmentoE(ref Pagamento pagamento, string registro)
        {
            try
            {
                pagamento.NumeroDocumentoBanco = registro.Substring(8, 5);
                pagamento.Natureza = registro.Substring(108, 3);
                pagamento.TipoComplemento = registro.Substring(111, 2);
                pagamento.Complemento = registro.Substring(113, 20);
                pagamento.DataContabil = Utils.ToDateTime(Utils.ToInt32(registro.Substring(134, 8)).ToString("##-##-####"));
                pagamento.DataLancamento = Utils.ToDateTime(Utils.ToInt32(registro.Substring(142, 8)).ToString("##-##-####"));

                pagamento.ValorTotal = Convert.ToDecimal(registro.Substring(150, 18)) / 100;

                pagamento.TipoLancamento = registro.Substring(168, 20);
                pagamento.Categoria = registro.Substring(169, 3);
                pagamento.CodigoHistorico = registro.Substring(172, 4);
                pagamento.DescricaoHistorico = registro.Substring(176, 20);
                pagamento.NumeroDocumento = registro.Substring(201, 39);
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler detalhe do arquivo de RETORNO / CNAB 240 / Segmento E.", ex);
            }
        }

        public static void LerDetalheRetornoCNAB240SegmentoO(ref Pagamento pagamento, string registro)
        {
            try
            {
                pagamento.CodigoBarras = registro.Substring(17, 44);

                pagamento.NomeFavorecido = registro.Substring(61, 30);
                pagamento.DataVencimento = Utils.ToDateTime(Utils.ToInt32(registro.Substring(91, 8)).ToString("##-##-####"));
                pagamento.DataPagamento = Utils.ToDateTime(Utils.ToInt32(registro.Substring(99, 8)).ToString("##-##-####"));

                pagamento.ValorTitulo = Convert.ToDecimal(registro.Substring(107, 15)) / 100;
                pagamento.ValorPago = Convert.ToDecimal(registro.Substring(107, 15)) / 100;

                pagamento.NumeroDocumento = registro.Substring(122, 20);
                pagamento.NumeroDocumentoBanco = registro.Substring(142, 20);

                pagamento.OcorrenciasRetorno = registro.Substring(230, 10);
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler detalhe do arquivo de RETORNO / CNAB 240 / Segmento O.", ex);
            }
        }
    }
}
