using System;
using Facile.Financeiro.BoletoNetCore.Extensions;
using static System.String;

namespace Facile.Financeiro.BoletoNetCore
{
    [CarteiraCodigo("09")]
    internal class BancoBradescoCarteira09 : ICarteira<BancoBradesco>
    {
        internal static Lazy<ICarteira<BancoBradesco>> Instance { get; } = new Lazy<ICarteira<BancoBradesco>>(() => new BancoBradescoCarteira09());

        private BancoBradescoCarteira09()
        {

        }

        public void FormataNossoNumero(Boleto boleto)
        {
            // Nosso número não pode ter mais de 11 dígitos
            if (IsNullOrWhiteSpace(boleto.NossoNumero) || boleto.NossoNumero == "00000000000")
            {
                // Banco irá gerar Nosso Número
                boleto.NossoNumero = new String('0', 11);
                boleto.NossoNumeroDV = "0";
                boleto.NossoNumeroFormatado = "000/00000000000-0";
            }
            else
            {
                // Nosso Número informado pela empresa
                if (boleto.NossoNumero.Trim().Length > 11)
                    throw new Exception($"Nosso Número ({boleto.NossoNumero.Trim()}) deve conter 11 dígitos.");
                boleto.NossoNumero = boleto.NossoNumero.PadLeft(11, '0');
                boleto.NossoNumeroDV = (boleto.Carteira.Trim() + boleto.NossoNumero.Trim()).CalcularDVBradesco();
                boleto.NossoNumeroFormatado = $"{boleto.Carteira.PadLeft(3, '0')}/{boleto.NossoNumero.Trim()}-{boleto.NossoNumeroDV.Trim()}";
            }
        }

        public string FormataCodigoBarraCampoLivre(Boleto boleto)
        {
            var contaBancaria = boleto.Banco.Cedente.ContaBancaria;
            return $"{contaBancaria.Agencia.Trim()}{boleto.Carteira.Trim()}{boleto.NossoNumero.Trim()}{contaBancaria.Conta.Trim()}{"0"}";
        }
    }
}
